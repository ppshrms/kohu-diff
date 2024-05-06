--------------------------------------------------------
--  DDL for Package Body HRBFS1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFS1E" is
-- last update: 14/09/2020 12:03
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
    b_index_codcompy      := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_year          := hcm_util.get_string_t(json_obj,'p_year');
    p_codbenefit          := hcm_util.get_string_t(json_obj,'p_codbenefit');
    p_proccond            := hcm_util.get_string_t(json_obj,'p_proccond');
    p_yearcond            := hcm_util.get_string_t(json_obj,'p_yearcond');
    p_dtetrial            := to_date(hcm_util.get_string_t(json_obj,'p_dtetrial'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index as
  begin
    if b_index_year < to_char(sysdate,'yyyy') then
      param_msg_error := get_error_msg_php('HR4510', global_v_lang);
      return;
    end if;
    if b_index_codcompy is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_data(json_str_output out clob) is
  obj_row         json_object_t;
  obj_data        json_object_t;
  v_rcnt          number := 0;

  cursor c1 is
      select codobf,desobft,typepay,amtvalue,dteeffec
        from TTOBFCDE
       where codcompy = b_index_codcompy
         and dteyear  = b_index_year
         --<<
         and codobf in (select codobf
                          from tobfcompy
                         where codcompy = b_index_codcompy)
         -->>
    order by codobf, dteeffec;
  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codbenefit',i.codobf);
        obj_data.put('desc_codbenefit',i.desobft);
        obj_data.put('typbenefit',i.typepay);
        obj_data.put('value',i.amtvalue);
        obj_data.put('dtetrial',to_char(i.dteeffec,'dd/mm/yyyy'));

        if i.typepay = 'C' then
          obj_data.put('desc_typbenefit',get_label_name('HRBFS1E2',global_v_lang,30));
        elsif i.typepay = 'T' then
          obj_data.put('desc_typbenefit',get_label_name('HRBFS1E2',global_v_lang,40));
        end if;
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail as
    v_codbenefit  tobfcompy.codobf%type;
    v_chkExist  number;
  begin
    --<<
    begin
      select codobf into v_codbenefit
        from tobfcompy
       where codcompy = b_index_codcompy
         and codobf   = p_codbenefit;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBFCOMPY');
      return;
    end;
    -->>
    begin
      select count(*) into v_chkExist
        from ttobfcde
       where codcompy = b_index_codcompy
         and dteyear  = b_index_year
         and codobf   = p_codbenefit
         and dteeffec = p_dtetrial;
--      order by codobf, dteeffec;
    end;
    if v_chkExist = 0 then
      if p_dtetrial < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR8519', global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab1(json_str_output out clob) is
  obj_row         json_object_t;
  obj_data        json_object_t;
  v_rcnt          number := 0;
  v_flgdata       varchar2(2 char) := 'N';
  v_statement     TTOBFCDE.statement%type;
  cursor c1 is
      select codobf,desobft,typepay,amtvalue,dteeffec,codunit,codsize,descsize,flglimit,flgfamily,typrelate,desnote,syncond,statement
        from TTOBFCDE
       where codcompy = b_index_codcompy
         and dteyear = b_index_year
         and codobf = p_codbenefit
         and dteeffec = p_dtetrial
    order by codobf, dteeffec;

  cursor c2 is
      select codobf,desobft,typepay,amtvalue,codunit,codsize,descsize,flglimit,
            flgfamily,typrelate,desnote,syncond, typebf
            ,statement--User37 #6846 08/09/2021 
        from TOBFCDE
       where codobf = p_codbenefit;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
        v_flgdata := 'Y';
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codbenefit',p_codbenefit);
        obj_data.put('desc_codbenefit',r1.desobft);
        obj_data.put('typbenefit',r1.typepay);
        obj_data.put('value',r1.amtvalue);
        obj_data.put('dtetrial',to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('unit',r1.codunit);
        obj_data.put('codsize',r1.codsize);
        obj_data.put('desc_codsize',r1.descsize);
        obj_data.put('flglimit',r1.flglimit);
        obj_data.put('stafam',r1.flgfamily);
        obj_data.put('relation',r1.typrelate);
        obj_data.put('desnote',r1.desnote);
        obj_data.put('syncondRight',r1.syncond);
        if r1.statement is not null then
          v_statement := r1.statement;
        else
          v_statement := '[]';
        end if;
        obj_data.put('statement',v_statement);
        obj_data.put('description',get_logical_desc(v_statement));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
      for r2 in c2 loop
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codbenefit',p_codbenefit);
          obj_data.put('desc_codbenefit',r2.desobft);
          obj_data.put('typbenefit',r2.typebf);
          obj_data.put('value',r2.amtvalue);
          obj_data.put('dtetrial','');
          obj_data.put('unit',r2.codunit);
          obj_data.put('codsize',r2.codsize);
          obj_data.put('desc_codsize',r2.descsize);
          obj_data.put('flglimit',r2.flglimit);
          obj_data.put('stafam',r2.flgfamily);
          obj_data.put('relation',r2.typrelate);
          obj_data.put('desnote',r2.desnote);
          obj_data.put('syncondRight',r2.syncond);
          --<<User37 #6846 08/09/2021 
          --v_statement := '[]';
          if r2.statement is not null then
            v_statement := r2.statement;
          else
            v_statement := '[]';
          end if;
          -->>User37 #6846 08/09/2021 
          obj_data.put('statement',v_statement);
          obj_data.put('description',get_logical_desc(v_statement));
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_tab2(json_str_output out clob) is
  obj_row         json_object_t;
  obj_data        json_object_t;
  v_rcnt          number := 0;
  v_flgdata       boolean := false;
  v_typepay       varchar2(2 char);
  cursor c1 is
      select syncond,qtyalw,qtytalw,statement,numobf
        from TTOBFCDET
       where codcompy = b_index_codcompy
         and dteyear = b_index_year
         and codobf = p_codbenefit
         and dteeffec = p_dtetrial
    order by numobf;

    cursor c2 is
      select syncond,qtyalw,qtytalw,statement,numobf
        from TOBFCDET
       where codobf = p_codbenefit
    order by numobf;
  begin
    begin
      select typepay into v_typepay
          from TTOBFCDE
         where codcompy = b_index_codcompy
           and dteyear = b_index_year
           and codobf = p_codbenefit
           and dteeffec = p_dtetrial
      order by codobf, dteeffec;
    exception when no_data_found then
      v_typepay := 'C';
    end;

    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := true;
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numobf',i.numobf);
        obj_data.put('typbenefit',v_typepay);
        obj_data.put('syncond',i.syncond);
        obj_data.put('statement',i.statement);
        obj_data.put('description', get_logical_desc(i.statement));
        obj_data.put('qtyalw',i.qtyalw);
        obj_data.put('qtytalw',i.qtytalw);
        obj_data.put('flgAdd', false);--User37 #6846 08/09/2021 
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = false then
      for i in c2 loop
          v_flgdata := true;
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numobf',i.numobf);
          obj_data.put('syncond',i.syncond);
          obj_data.put('typbenefit',v_typepay);
          obj_data.put('statement',i.statement);
          obj_data.put('description', get_logical_desc(i.statement));
          obj_data.put('qtyalw',i.qtyalw);
          obj_data.put('qtytalw',i.qtytalw);
          obj_data.put('flgAdd', true);--User37 #6846 08/09/2021 
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_row       json_object_t;

    v_flg	          varchar2(1000 char);
    v_codcompy	    ttobfcde.codcompy%type;
    v_dteyear	      ttobfcde.dteyear%type;
    v_codobf	      ttobfcde.codobf%type;
    v_dteeffec	    ttobfcde.dteeffec%type;

  begin
    initial_value(json_str_input);
    param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    for i in 0..param_json.get_size-1 loop
      param_row     := hcm_util.get_json_t(param_json,to_char(i));
      v_flg     	  := hcm_util.get_string_t(param_row, 'flg');
      v_codobf     	:= hcm_util.get_string_t(param_row, 'codbenefit');
      v_dteeffec    := to_date(hcm_util.get_string_t(param_row, 'dtetrial'),'dd/mm/yyyy');
      v_codcompy     	:= hcm_util.get_string_t(param_row, 'p_codcompy');
      v_dteyear     	:= hcm_util.get_string_t(param_row, 'p_year');

      if v_flg = 'delete' then
        begin
          delete ttobfcde
           where codcompy = v_codcompy
             and dteyear = v_dteyear
             and dteeffec = v_dteeffec
             and codobf = v_codobf;
        end;

        --> Peerasak || Issue#8743 || 30/11/2022
         begin
          delete ttobfinf
           where codcompy = v_codcompy
             and dteyear = v_dteyear
             and trunc(dteeffec) = trunc(v_dteeffec)
             and codobf = v_codobf;
        end;
        --> Peerasak || Issue#8743 || 30/11/2022
      end if;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure check_save(json_str_input in clob) as
    param_tab1      json_object_t;
    param_tab2      json_object_t;
    param_row       json_object_t;
    obj_syncond     json_object_t;

    v_codcodec	        varchar2(1000 char);
    v_flg	              varchar2(1000 char);
    v_codbenefit		    ttobfcde.codobf%type;
    v_desc_codbenefit		ttobfcde.desobft%type;
    v_typbenefit		    ttobfcde.typepay%type;
    v_value		          ttobfcde.amtvalue%type;
    v_dtetrial		      ttobfcde.dteeffec%type;
    v_unit		          ttobfcde.codunit%type;
    v_codsize		        ttobfcde.codsize%type;
    v_desc_codsize		  ttobfcde.descsize%type;
    v_flglimit		      ttobfcde.flglimit%type;
    v_stafam		        ttobfcde.flgfamily%type;
    v_relation		      ttobfcde.typrelate%type;
    v_desnote		        ttobfcde.desnote%type;
    v_syncond		        ttobfcde.syncond%type;
    v_chkSize   number := 0;
    v_amount    number := 0;
    v_number    number := 0;
  begin
    param_tab1  := hcm_util.get_json_t(json_object_t(json_str_input),'tab1');
    param_tab2  := hcm_util.get_json_t(json_object_t(json_str_input),'tab2');
    obj_syncond := hcm_util.get_json_t(param_tab1,'syncondRight');

    v_codbenefit 	      := hcm_util.get_string_t(param_tab1,'codbenefit');
    v_desc_codbenefit		:= hcm_util.get_string_t(param_tab1,'desc_codbenefit');
    v_typbenefit		    := hcm_util.get_string_t(param_tab1,'typbenefit');
    v_value		          := to_number(hcm_util.get_string_t(param_tab1,'value'));
    v_dtetrial		      := to_date(hcm_util.get_string_t(param_tab1,'dtetrial'),'dd/mm/yyyy');
    v_unit		          := hcm_util.get_string_t(param_tab1,'unit');
    v_codsize		        := hcm_util.get_string_t(param_tab1,'codsize');
    v_desc_codsize		  := hcm_util.get_string_t(param_tab1,'desc_codsize');
    v_flglimit		      := hcm_util.get_string_t(param_tab1,'flglimit');
    v_stafam		        := hcm_util.get_string_t(param_tab1,'stafam');
    v_relation		      := hcm_util.get_string_t(param_tab1,'relation');
    v_desnote		        := hcm_util.get_string_t(param_tab1,'desnote');
    v_syncond		        := hcm_util.get_string_t(obj_syncond,'code');

    if v_typbenefit is null or v_desc_codbenefit is null or
       v_unit is null or v_value is null or v_desnote is null or
       v_syncond is null or v_stafam is null or v_flglimit is null then

      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    begin
      select codcodec into v_codcodec
      from TCODUNIT
      where codcodec = v_unit;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODUNIT');
      return;
    end;
    if v_codsize is not null then
      begin
        select codcodec into v_codcodec
        from TCODSIZE
        where codcodec = v_codsize;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSIZE');
        return;
      end;
    end if;
    -- tab2
    for i in 0..param_tab2.get_size-1 loop
      param_row   := hcm_util.get_json_t(param_tab2,to_char(i));
      obj_syncond	:= hcm_util.get_json_t(param_row, 'syncond');
      v_syncond		:= hcm_util.get_string_t(obj_syncond,'code');
      v_amount    := to_number(hcm_util.get_string_t(param_row,'qtyalw'));
      v_number    := to_number(hcm_util.get_string_t(param_row,'qtytalw'));

      if v_syncond is null or v_amount is null or v_number is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        exit;
      end if;
      if v_amount <= 0 or v_number <= 0 then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        exit;
      end if;
    end loop;
  end;
  --
  procedure save_detail (json_str_input in clob, json_str_output out clob) as
    param_tab1      json_object_t;
    param_tab2      json_object_t;
    param_row       json_object_t;
    obj_syncond     json_object_t;

    v_flg	              varchar2(1000 char);
    v_codbenefit		    ttobfcde.codobf%type;
    v_desc_codbenefit		ttobfcde.desobft%type;
    v_typbenefit		    ttobfcde.typepay%type;
    v_value		          ttobfcde.amtvalue%type;
    v_dtetrial		      ttobfcde.dteeffec%type;
    v_unit		          ttobfcde.codunit%type;
    v_codsize		        ttobfcde.codsize%type;
    v_desc_codsize		  ttobfcde.descsize%type;
    v_flglimit		      ttobfcde.flglimit%type;
    v_stafam		        ttobfcde.flgfamily%type;
    v_relation		      ttobfcde.typrelate%type;
    v_desnote		        ttobfcde.desnote%type;
    v_syncond		        ttobfcde.syncond%type;
    v_statement         clob;

    v_codcompy	ttobfcdet.codcompy%type;
    v_dteyear	ttobfcdet.dteyear%type;
    v_codobf	ttobfcdet.codobf%type;
    v_dteeffec	ttobfcdet.dteeffec%type;
    v_numobf	ttobfcdet.numobf%type;
    v_qtyalw	ttobfcdet.qtyalw%type;
    v_qtytalw	ttobfcdet.qtytalw%type;
  begin
    initial_value(json_str_input);

    param_tab1  := hcm_util.get_json_t(json_object_t(json_str_input),'tab1');
    param_tab2  := hcm_util.get_json_t(json_object_t(json_str_input),'tab2');
    obj_syncond := hcm_util.get_json_t(param_tab1,'syncondRight');

    v_codbenefit 	      := hcm_util.get_string_t(param_tab1,'codbenefit');
    v_desc_codbenefit		:= hcm_util.get_string_t(param_tab1,'desc_codbenefit');
    v_typbenefit		    := hcm_util.get_string_t(param_tab1,'typbenefit');
    v_value		          := to_number(hcm_util.get_string_t(param_tab1,'value'));
    v_dtetrial		      := to_date(hcm_util.get_string_t(param_tab1,'dtetrial'),'dd/mm/yyyy hh24mi');
    v_unit		          := hcm_util.get_string_t(param_tab1,'unit');
    v_codsize		        := hcm_util.get_string_t(param_tab1,'codsize');
    v_desc_codsize		  := hcm_util.get_string_t(param_tab1,'desc_codsize');
    v_flglimit		      := hcm_util.get_string_t(param_tab1,'flglimit');
    v_stafam		        := hcm_util.get_string_t(param_tab1,'stafam');
    v_relation		      := hcm_util.get_string_t(param_tab1,'relation');
    v_desnote		        := hcm_util.get_string_t(param_tab1,'desnote');
    v_syncond		        := hcm_util.get_string_t(obj_syncond,'code');
    v_statement         := hcm_util.get_string_t(obj_syncond,'statement');

    check_save(json_str_input);

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    begin
      insert into ttobfcde (codcompy,dteyear,codobf,dteeffec,desobft,typepay,codunit,
                            amtvalue,codsize,descsize,desnote,flglimit,flgfamily,typrelate,
                            syncond,statement,dtecreate,codcreate,coduser)
      values (b_index_codcompy,b_index_year, p_codbenefit, p_dtetrial, v_desc_codbenefit,v_typbenefit,v_unit,
              v_value,v_codsize,v_desc_codsize,v_desnote,v_flglimit,v_stafam,v_relation,
              v_syncond,v_statement,sysdate,global_v_coduser, global_v_coduser);

    exception when dup_val_on_index then

      begin
        update ttobfcde
           set desobft = v_desc_codbenefit,
               typepay = v_typbenefit,
               codunit = v_unit,
               amtvalue = v_value,
               codsize = v_codsize,
               descsize = v_desc_codsize,
               desnote = v_desnote,
               flglimit = v_flglimit,
               flgfamily = v_stafam,
               typrelate = v_relation,
               syncond = v_syncond,
               statement = v_statement,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcompy = b_index_codcompy
           and dteyear = b_index_year
           and dteeffec = p_dtetrial
           and codobf = p_codbenefit;
      end;
    end;

    for i in 0..param_tab2.get_size-1 loop
      param_row     := hcm_util.get_json_t(param_tab2,to_char(i));
      v_flg     	  := hcm_util.get_string_t(param_row, 'flg');
      v_numobf     	:= hcm_util.get_string_t(param_row, 'numobf');
      v_qtyalw		  := hcm_util.get_string_t(param_row, 'qtyalw');
      v_qtytalw		  := hcm_util.get_string_t(param_row, 'qtytalw');
      obj_syncond   := hcm_util.get_json_t(param_row,'syncond');
      v_syncond		  := hcm_util.get_string_t(obj_syncond, 'code');
      v_statement	  := hcm_util.get_string_t(obj_syncond, 'statement');
      v_statement	  := hcm_util.get_string_t(obj_syncond, 'statement');

      if v_flg in ('add','edit') then
        if v_flg = 'add' then--User37 #6847 09/09/2021  
          begin
           select nvl(max(numobf),1)+1 into v_numobf
             from ttobfcdet
            where codcompy = b_index_codcompy
              and dteyear = b_index_year
              and dteeffec = p_dtetrial
              and codobf = p_codbenefit;
          exception when no_data_found then
            v_numobf := 1;
          end;
        end if;

        begin
          insert into ttobfcdet (codcompy, dteyear, codobf, dteeffec,numobf,
                                 syncond,statement,qtyalw,qtytalw,
                                 dtecreate,codcreate, coduser)
               values (b_index_codcompy, b_index_year, p_codbenefit, p_dtetrial, v_numobf,
                       v_syncond, v_statement, v_qtyalw, v_qtytalw,
                       sysdate, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          begin
            update ttobfcdet
               set syncond = v_syncond,
                   statement = v_statement,
                   qtyalw = v_qtyalw,
                   qtytalw = v_qtytalw,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codcompy = b_index_codcompy
               and dteyear = b_index_year
               and dteeffec = p_dtetrial
               and codobf = p_codbenefit
               and numobf = v_numobf;
          end;
        end;

--      elsif v_flg = 'edit' then
--        begin
--          update ttobfcdet
--             set syncond = v_syncond,
--                 statement = v_statement,
--                 qtyalw = v_qtyalw,
--                 qtytalw = v_qtytalw,
--                 dteupd = sysdate,
--                 coduser = global_v_coduser
--           where codcompy = b_index_codcompy
--             and dteyear = b_index_year
--             and dteeffec = p_dtetrial
--             and codobf = p_codbenefit
--             and numobf = v_numobf;
--
--          if SQL%ROWCOUNT = 0 then
--            insert into ttobfcdet (codcompy, dteyear, codobf, dteeffec,numobf,
--                                   syncond,statement,qtyalw,qtytalw,
--                                   dtecreate,codcreate, coduser)
--                 values (b_index_codcompy, b_index_year, p_codbenefit, p_dtetrial, v_numobf,
--                         v_syncond, v_statement, v_qtyalw, v_qtytalw,
--                         sysdate, global_v_coduser, global_v_coduser);
--          end if;
--        end;
      elsif v_flg = 'delete' then
        begin
          delete ttobfcdet
           where codcompy = b_index_codcompy
             and dteyear = b_index_year
             and dteeffec = p_dtetrial
             and codobf = p_codbenefit
             and numobf = v_numobf;
        end;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure get_process_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    gen_data(json_str_output);
  end;

  procedure process_data(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_empbf(json_str_input);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_empbf(json_str_input in clob) is
    param_tab1      json_object_t;
    param_tab2      json_object_t;
    param_row       json_object_t;
    obj_tab2        json_object_t;
    obj_syncond     json_object_t;
    v_cursor_main   number;
    v_cursor_query  number;
    v_dummy         integer;
    v_stmt          varchar2(4000 char);
    v_stmt2         varchar2(4000 char);
    v_chkStmt       varchar2(4000 char);
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_qty           number;
    v_qtyemp        number;

    v_condition     ttobfcde.syncond%type;
    v_typbenefit    ttobfcde.typepay%type;
    v_amtalw        number;
    v_qtyalw        number;
    v_qtytalw       number;
    v_value         number;
    v_cnt           number := 0;
    v_flgsecu       boolean := true;
    v_flgcondbf     boolean;

    cursor c1 is
      select hcm_util.get_codcomp_level(codcomp, 1) codcompy,codempid
        from tobfsum
       where dteyre = p_yearcond
         and codobf = p_codbenefit
         and hcm_util.get_codcomp_level(codcomp, 1) = b_index_codcompy
       group by hcm_util.get_codcomp_level(codcomp, 1),codempid
       order by codempid;
  begin
    param_tab1  := hcm_util.get_json_t(json_object_t(json_str_input),'tab1');
    obj_tab2    := hcm_util.get_json_t(json_object_t(json_str_input),'tab2');
    param_tab2  := hcm_util.get_json_t(obj_tab2,'rows');

    obj_syncond := hcm_util.get_json_t(param_tab1,'syncondRight');
    v_condition := hcm_util.get_string_t(obj_syncond,'code');
    v_typbenefit := hcm_util.get_string_t(param_tab1,'typbenefit');
    v_value := hcm_util.get_string_t(param_tab1,'value');

    -- clear when process
    begin
      delete ttobfinf
       where codcompy = b_index_codcompy
         and dteyear = b_index_year
         and codobf = p_codbenefit
         and dteeffec = p_dtetrial;
      commit;
    end;
    --
    if v_condition is not null then
      v_condition := 'and ' || v_condition;
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    v_chkStmt := 'select count(*) '||
                 '  from v_hrbf41 '||
                 ' where codcomp like '''||b_index_codcompy||'%'' '||
                 '   and staemp in (''1'',''3'') '||
                 v_condition ||'';

    v_stmt := 'select codempid,codcomp '||
              '  from v_hrbf41 '||
              ' where codcomp like '''||b_index_codcompy||'%'' '||
              '   and staemp in (''1'',''3'') '||
              v_condition ||'';
      v_qty := execute_qty(v_chkStmt) ;
      if v_qty > 0 then
--        v_qtyalw := 0;
--        v_qtytalw := 0;
--        for i in 0..param_tab2.get_size-1 loop
--          param_row     := hcm_util.get_json_t(param_tab2,to_char(i));
--          v_qtyalw		  := to_number(hcm_util.get_string_t(param_row, 'qtyalw'/*27/03/2021 'amount'*/));
--          v_qtytalw		  := to_number(hcm_util.get_string_t(param_row, 'qtytalw'/*27/03/2021 'number'*/));
--          obj_syncond   := hcm_util.get_json_t(param_row,'syncond');
--          v_condition		:= hcm_util.get_string_t(obj_syncond, 'code');
--insert_ttemprpt('BFS1E','BFS1E','tab2',substr('v_condition='||v_condition,1,600),'v_qtyalw='||v_qtyalw,'v_qtytalw='||v_qtytalw,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
--          if v_condition is not null then
--            v_qtyemp  := execute_qty(v_chkStmt || 'and ' || v_condition ||' ') ;
--            if v_qtyemp > 0 then
--              v_stmt := v_stmt || 'and ' || v_condition ||' ';
--              exit;
--            end if;
--          end if;
--        end loop;
        v_stmt := v_stmt || ' order by codempid';
        if p_proccond = '1' then
          v_cursor_main   := dbms_sql.open_cursor;
          dbms_sql.parse(v_cursor_main,v_stmt,dbms_sql.native);
          dbms_sql.define_column(v_cursor_main,1,v_codempid,100);
          dbms_sql.define_column(v_cursor_main,2,v_codcomp,100);
          v_dummy := dbms_sql.execute(v_cursor_main);

          while (dbms_sql.fetch_rows(v_cursor_main) > 0) loop
            dbms_sql.column_value(v_cursor_main,1,v_codempid);
            dbms_sql.column_value(v_cursor_main,2,v_codcomp);
            --<<27/03/2021
            v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if v_flgsecu then
              v_qtyalw := 0;
              v_qtytalw := 0;
              v_flgcondbf := false;
              for i in 0..param_tab2.get_size-1 loop
                param_row     := hcm_util.get_json_t(param_tab2,to_char(i));
                obj_syncond   := hcm_util.get_json_t(param_row,'syncond');
                v_condition		:= hcm_util.get_string_t(obj_syncond, 'code');
                if v_condition is not null then
                  v_stmt2 := 'select 1 from v_hrbf41 where codempid = '''||v_codempid||''' and '|| v_condition ||' ';
                  v_flgcondbf := execute_stmt(v_stmt2);
                  if v_flgcondbf then
                    v_qtyalw		  := to_number(hcm_util.get_string_t(param_row, 'qtyalw'));
                    v_qtytalw		  := to_number(hcm_util.get_string_t(param_row, 'qtytalw'));
                    exit;
                  end if;
                end if;
              end loop;

              if v_flgcondbf then
            -->>27/03/2021
                if v_typbenefit = 'T' then
                  v_amtalw := v_qtyalw * v_value;
                else
                  v_amtalw := v_qtyalw;
                end if;
                begin
                  insert into ttobfinf(codcompy, dteyear, codobf, dteeffec, codempid,
                                       amtalw, qtyalw, qtytalw,
                                       dtecreate, codcreate, coduser)
                                 values(b_index_codcompy, b_index_year, p_codbenefit, p_dtetrial, v_codempid,
                                        v_amtalw, v_qtyalw, v_qtytalw,
                                        sysdate,global_v_coduser,global_v_coduser);
                exception when dup_val_on_index then null;
                end;
              end if; --v_flgcondbf
            end if; --v_flgsecu
          end loop;

        elsif p_proccond = '2' then
          v_cnt := 0;
          for r1 in c1 loop
            --<<27/03/2021
            v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if v_flgsecu then
              v_cnt := v_cnt + 1;
              ----<<
              v_qtyalw := 0;
              v_qtytalw := 0;
              v_flgcondbf := false;
              for i in 0..param_tab2.get_size-1 loop
                param_row     := hcm_util.get_json_t(param_tab2,to_char(i));
                obj_syncond   := hcm_util.get_json_t(param_row,'syncond');
                v_condition		:= hcm_util.get_string_t(obj_syncond, 'code');
                if v_condition is not null then
                  v_stmt2 := 'select 1 from v_hrbf41 where codempid = '''||r1.codempid||''' and '|| v_condition ||' ';
                  v_flgcondbf := execute_stmt(v_stmt2);
                  if v_flgcondbf then
                    v_qtyalw		  := to_number(hcm_util.get_string_t(param_row, 'qtyalw'));
                    v_qtytalw		  := to_number(hcm_util.get_string_t(param_row, 'qtytalw'));
                    exit;
                  end if;
                end if;
              end loop;

              if v_flgcondbf then
              ---->>
                if v_typbenefit = 'T' then
                  v_amtalw := v_qtyalw * v_value;
                else
                  v_amtalw := v_qtyalw;
                end if;
              -->>27/03/2021
                begin
                  insert into ttobfinf(codcompy, dteyear, codobf, dteeffec, codempid,
                                       amtalw, qtyalw, qtytalw,
                                       dtecreate, codcreate, coduser)
                                 values(b_index_codcompy, b_index_year, p_codbenefit, p_dtetrial, r1.codempid,
                                        v_amtalw, v_qtyalw, v_qtytalw,
                                        sysdate,global_v_coduser,global_v_coduser);
                exception when dup_val_on_index then null;
                end;
              end if; ----v_flgcondbf
            end if; --v_flgsecu
          end loop;
          if v_cnt = 0 then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobfsum');
          end if;
        end if;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  procedure gen_detail_right(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

  cursor c1 is
      select codcompy,codempid,amtalw,qtyalw,qtytalw
        from ttobfinf
       where codcompy = b_index_codcompy
         and dteyear = b_index_year
         and codobf = p_codbenefit
         and dteeffec = p_dtetrial
    order by codobf, dteeffec;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcomp',r1.codcompy);
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcompy,global_v_lang));
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('codempid',r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('amtalw',r1.amtalw);
        obj_data.put('qtyalw',r1.qtyalw);
        obj_data.put('qtytalw',r1.qtytalw);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttobfinf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  procedure get_detail_right(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_right(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

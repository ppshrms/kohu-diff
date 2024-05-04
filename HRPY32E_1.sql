--------------------------------------------------------
--  DDL for Package Body HRPY32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY32E" as

  procedure initial_value(json_str_input in clob) is
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    -- index param
    p_codcompy        := hcm_util.get_string_t(json_obj,'codcompy');
    p_apcode          := hcm_util.get_string_t(json_obj,'apcode');
    p_typpaymt        := hcm_util.get_string_t(json_obj,'typpaymt');
    p_typpaymt_old    := hcm_util.get_string_t(json_obj,'typpaymt_old');

  end initial_value;

  procedure check_index as
    v_count_compny  number := 0;
    v_count_apcode  number := 0;
  begin
    -- ตรวจสอบรหัสต้องมีอยู่ในตาราง tcompny (hr2010 tcompny)
    begin
      select count(*) into v_count_compny
      from tcompny
      where codcompy = p_codcompy;
    exception when others then null;
    end;
    if v_count_compny < 1 then
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
       return;
    end if;
    -- ตรวจสอบ secure (hr3007)
    if p_codcompy is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    -- ตรวจสอบรหัสต้องมีอยู่ในตาราง tcodgrpgl (hr2010 tcodgrpgl)
    begin
      select count(*) into v_count_apcode
      from tcodgrpgl
      where codcodec = p_apcode;
    exception when others then null;
    end;
    if v_count_apcode < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrpgl');
      return;
    end if;
  end check_index;

  function gen_paycode(v_apgrpcod varchar2) return json_object_t is
    obj_result  json_object_t;
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c2 is
      select apgrpcod,codcompy,codpay
        from tgltabi
      where codcompy = p_codcompy
        and apcode = p_apcode
        and apgrpcod = v_apgrpcod
      order by codpay;
  begin
    obj_result  := json_object_t();
    obj_row     := json_object_t();
    for j in c2 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codcompy',j.codcompy);
      obj_data.put('apgrpcod',j.apgrpcod);
      obj_data.put('codpay',j.codpay);
      obj_data.put('desc_codpay',get_tinexinf_name(j.codpay,global_v_lang));
      obj_result.put(v_row-1,obj_data);
    end loop;
    obj_row.put('rows',obj_result);
    return obj_row;
  end;

  procedure gen_index_table(json_str_output out clob) is
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_row   number := 0;
    cursor c1 is
      select apcode,apgrpcod,codacccr,codaccdr,codcompy,costcentcr,costcentdr,scodacccr,scodaccdr
        from tglhtabi
       where codcompy = p_codcompy
         and apcode = p_apcode
       order by apgrpcod;
  begin
    obj_row     := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('apgrpcod',i.apgrpcod);
      obj_data.put('codaccdr',i.codaccdr);
      obj_data.put('scodaccdr',i.scodaccdr);
      obj_data.put('costcentdr',i.costcentdr);
      obj_data.put('codacccr',i.codacccr);
      obj_data.put('scodacccr',i.scodacccr);
      obj_data.put('costcentcr',i.costcentcr);
      obj_data.put('paycode',gen_paycode(i.apgrpcod));
      obj_data.put('setpaycode','$ pay code');
      obj_row.put(v_row-1,obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_index_table;

  procedure get_index_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_table;

  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_tglhtabi    json_object_t;
    v_tgltabi       json_object_t;
    v_typpaymt      varchar2(4 char) := '';
    v_check_taccap  varchar2(1 char) := 'N';
    v_row           number := 0;

  begin
    begin
      select typpaymt,'Y' into v_typpaymt, v_check_taccap
        from taccap
       where codcompy = p_codcompy
         and apcode = p_apcode;
    exception when no_data_found then
        v_typpaymt := null;
    end;
    obj_data  := json_object_t();

    obj_data.put('coderror', '200');
    obj_data.put('codcompy',p_codcompy);
    obj_data.put('apcode',p_apcode);
    obj_data.put('typpaymt',v_typpaymt);
    if v_check_taccap != 'Y' then
      obj_data.put('typpaymt_old','');
      obj_data.put('flg','Add');
    else
      obj_data.put('typpaymt_old',v_typpaymt);
      obj_data.put('flg','Edit');
    end if;
    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure add_log(p_apgrpcod varchar2,p_fldedit varchar2,p_descold varchar2,p_descnew varchar2)is
    v_numseq   number := 0;
  begin
    select count(*) + 1 into v_numseq from tlogap;
    insert into tlogap(dteupd,codcompy,apcode,apgrpcod,numseq,fldedit,descold,descnew,codcreate,coduser)
         values (sysdate,p_codcompy,p_apcode,p_apgrpcod,v_numseq,p_fldedit,p_descold,p_descnew,global_v_coduser,global_v_coduser);
  end add_log;

  procedure save_taccap is
    v_count_taccap_dup number :=0;
  begin
      -- ตรวจสอบการ dup ของ pk ตาราง taccap
    if p_typpaymt is not null and p_typpaymt_old is null then
      begin
        select count(*) into v_count_taccap_dup
          from taccap
         where codcompy = p_codcompy
           and apcode = p_apcode;
      exception when others then null;
      end;
      if v_count_taccap_dup > 0 then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'taccap');
        return;
      end if;
    end if;
    if p_typpaymt_old is not null and p_typpaymt != p_typpaymt_old then
      update taccap
         set typpaymt = p_typpaymt,
             dteupd = sysdate,
             coduser = global_v_coduser
       where codcompy = p_codcompy and
             apcode = p_apcode;
      -- log แก้ไขข้อมูล
      add_log('-','typpaymt',p_typpaymt_old,p_typpaymt);--User37 Final Test Phase 1 V11 #2859 09/11/2020 add_log('-','typpaymt',null,p_typpaymt);
    elsif p_typpaymt is not null and p_typpaymt_old is null then
      insert into taccap ( codcompy, apcode, typpaymt, dtecreate, codcreate, coduser)
           values ( p_codcompy, p_apcode, p_typpaymt, sysdate, global_v_coduser, global_v_coduser);
      -- log เพิ่มข้อมูล
      add_log('-','codcompy',null,p_codcompy);
      add_log('-','apcode',null,p_apcode);
      add_log('-','typpaymt',null,p_typpaymt);
    end if;
  end save_taccap;

  procedure log_tglhtabi(flg varchar2,input_obj json_object_t) is
    p_apgrpcod    varchar2(4 char);
    p_codaccdr    taccodbc.codacc%type;
    p_scodaccdr   taccodbc.codacc%type;
    p_costcentdr  varchar2(25 char);
    p_codacccr    taccodbc.codacc%type;
    p_scodacccr   taccodbc.codacc%type;
    p_costcentcr  varchar2(25 char);

    p_apgrpcod_old    varchar2(4 char) := null;
    p_codaccdr_old    taccodbc.codacc%type := null;
    p_scodaccdr_old   taccodbc.codacc%type := null;
    p_costcentdr_old  varchar2(25 char) := null;
    p_codacccr_old    taccodbc.codacc%type := null;
    p_scodacccr_old   taccodbc.codacc%type := null;
    p_costcentcr_old  varchar2(25 char) := null;
  begin
    p_apgrpcod    := hcm_util.get_string_t(input_obj,'apgrpcod');
    p_codaccdr    := hcm_util.get_string_t(input_obj,'codaccdr');
    p_scodaccdr   := hcm_util.get_string_t(input_obj,'scodaccdr');
    p_costcentdr  := hcm_util.get_string_t(input_obj,'costcentdr');
    p_codacccr    := hcm_util.get_string_t(input_obj,'codacccr');
    p_scodacccr   := hcm_util.get_string_t(input_obj,'scodacccr');
    p_costcentcr  := hcm_util.get_string_t(input_obj,'costcentcr');

    p_apgrpcod_old    := hcm_util.get_string_t(input_obj,'apgrpcodOld');
    p_codaccdr_old    := hcm_util.get_string_t(input_obj,'codaccdrOld');
    p_scodaccdr_old   := hcm_util.get_string_t(input_obj,'scodaccdrOld');
    p_costcentdr_old  := hcm_util.get_string_t(input_obj,'costcentdrOld');
    p_codacccr_old    := hcm_util.get_string_t(input_obj,'codacccrOld');
    p_scodacccr_old   := hcm_util.get_string_t(input_obj,'scodacccrOld');
    p_costcentcr_old  := hcm_util.get_string_t(input_obj,'costcentcrOld');

    if flg = 'add' then
        add_log(p_apgrpcod,'apgrpcod',null,p_apgrpcod);
    -- dr
        add_log(p_apgrpcod,'codaccdr',null,p_codaccdr);
        if p_scodaccdr is not null then
            add_log(p_apgrpcod,'scodaccdr',null,p_scodaccdr);
        end if;
        if p_costcentdr is not null then
            add_log(p_apgrpcod,'costcentdr',null,p_costcentdr);
        end if;
    -- cr
        add_log(p_apgrpcod,'codacccr',p_codacccr_old,p_codacccr);
        if p_scodacccr is not null  then
            add_log(p_apgrpcod,'scodacccr',p_scodacccr_old,p_scodacccr);
        end if;
        if p_costcentcr is not null then
            add_log(p_apgrpcod,'costcentcr',null,p_costcentcr);
        end if;
    elsif flg = 'edit' then
    --<<User37 Final Test Phase 1 V11 #2859 09/11/2020
    /*-- dr
        if p_codaccdr != p_codaccdr_old and p_codaccdr_old is not null then
            add_log(p_apgrpcod,'codaccdr',p_codaccdr_old,p_codaccdr);
        end if;
        if p_scodaccdr != p_scodaccdr_old then
            add_log(p_apgrpcod,'scodaccdr',p_scodaccdr_old,p_scodaccdr);
        end if;
        if p_costcentdr != p_costcentdr_old then
            add_log(p_apgrpcod,'costcentdr',p_costcentdr_old,p_costcentdr);
        end if;
    -- cr
        if p_codacccr != p_codacccr_old then
            add_log(p_apgrpcod,'codacccr',p_codacccr_old,p_codacccr);
        end if;
        if p_scodacccr != p_scodacccr_old then
            add_log(p_apgrpcod,'scodacccr',p_scodacccr_old,p_scodacccr);
        end if;
        if p_costcentcr != p_costcentcr_old then
            add_log(p_apgrpcod,'costcentcr',p_costcentcr_old,p_costcentcr);
        end if;*/
    -- dr
        if nvl(p_codaccdr,'!@#$') != nvl(p_codaccdr_old,'!@#$') then
            add_log(p_apgrpcod,'codaccdr',p_codaccdr_old,p_codaccdr);
        end if;
        if nvl(p_scodaccdr,'!@#$') != nvl(p_scodaccdr_old,'!@#$') then
            add_log(p_apgrpcod,'scodaccdr',p_scodaccdr_old,p_scodaccdr);
        end if;
        if nvl(p_costcentdr,'!@#$') != nvl(p_costcentdr_old,'!@#$') then
            add_log(p_apgrpcod,'costcentdr',p_costcentdr_old,p_costcentdr);
        end if;
    -- cr
        if nvl(p_codacccr,'!@#$') != nvl(p_codacccr_old,'!@#$') then
            add_log(p_apgrpcod,'codacccr',p_codacccr_old,p_codacccr);
        end if;
        if nvl(p_scodacccr,'!@#$') != nvl(p_scodacccr_old,'!@#$') then
            add_log(p_apgrpcod,'scodacccr',p_scodacccr_old,p_scodacccr);
        end if;
        if nvl(p_costcentcr,'!@#$') != nvl(p_costcentcr_old,'!@#$') then
            add_log(p_apgrpcod,'costcentcr',p_costcentcr_old,p_costcentcr);
        end if;
    -->>User37 Final Test Phase 1 V11 #2859 09/11/2020
    elsif flg = 'delete' then
        add_log(p_apgrpcod,'apgrpcod',p_apgrpcod_old,null);
        add_log(p_apgrpcod,'codaccdr',p_codaccdr_old,null);
        add_log(p_apgrpcod,'scodaccdr',p_scodaccdr_old,null);
        add_log(p_apgrpcod,'costcentdr',p_costcentdr_old,null);
        add_log(p_apgrpcod,'costcentdr',p_codacccr_old,null);
        add_log(p_apgrpcod,'costcentdr',p_scodacccr_old,null);
    end if;
  end;

  procedure update_tgltabi_all(p_codcompy varchar2,p_apcode varchar2,p_apgrpcod varchar2) is
  begin
      update tgltabi
         set dteupd      = sysdate,
             coduser     = global_v_coduser
       where codcompy = p_codcompy
         and apcode = p_apcode
         and apgrpcod = p_apgrpcod;
  end update_tgltabi_all;

  procedure save_tgltabi(flg varchar2,p_codpay varchar2,p_apgrpcod varchar2) is
  begin
      if flg = 'add' then
        insert into tgltabi ( codcompy, apcode, codpay, apgrpcod, dtecreate, codcreate, coduser)
             values ( p_codcompy, p_apcode, p_codpay, p_apgrpcod, sysdate, global_v_coduser, global_v_coduser);
        add_log(p_apgrpcod,'codpay',null,p_codpay);
      elsif flg = 'delete' then
          delete from tgltabi
          where
              codcompy = p_codcompy and
              apcode = p_apcode and
              apgrpcod = p_apgrpcod and
              codpay = p_codpay;
          add_log(p_apgrpcod,'codpay',p_codpay,null);
      end if;
  end save_tgltabi;

  function check_save_tglhtabi(p_apgrpcod varchar2,p_codaccdr varchar2,p_scodaccdr varchar2,p_costcentdr varchar2,
                              p_codacccr varchar2,p_scodacccr varchar2,p_costcentcr varchar2,v_flg varchar2) return boolean is

      v_count_apgrpcod          number := 0;
      v_count_codaccdr          number := 0;
      v_count_codaccdr_company  number := 0;
      v_count_costcentdr        number := 0;
      v_count_codacccr          number := 0;
      v_count_codacccr_company  number := 0;
      v_count_costcentcr        number := 0;
      v_count_tglhtabi_dup      number := 0;
  begin
    -- ฟิลด์ที่บังคับใส่ข้อมูล
    if p_apgrpcod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'apgrpcod');
      return false;
    end if;
    if p_codaccdr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaccdr');
      return false;
    end if;
    if p_codacccr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codacccr');
      return false;
    end if;
    -- กลุ่มรหัสรายได้ จะต้องมีอยู่จริงในตาราง tcodgrpap (hr2010)
    begin
      select count(*) into v_count_apgrpcod
      from tcodgrpap
      where codcodec = p_apgrpcod;
    exception when others then null;
    end;
    if v_count_apgrpcod < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrpap');
      return false;
    end if;
    -- รหัสบัญชี dr จะต้องมีอยู่จริงในตาราง taccodb (hr2010)
    begin
      select count(*) into v_count_codaccdr
      from taccodb
      where codacc = p_codaccdr;
    exception when others then null;
    end;
    if v_count_codaccdr < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'taccodb');
      return false;
    end if;
    -- รหัสบัญชี dr จะต้องใช้รหัสของบริษัทตนเองเท่านั้น ตรวจสอบจากตาราง taccodbc แจ้งเตือน “py0044 - รหัสที่ระบุไม่สามารถใช้กับบริษัทนี้”
    begin
      select count(*) into v_count_codaccdr_company
      from taccodbc
      where codacc = p_codaccdr
      and codcompy = p_codcompy;
    exception when others then null;
    end;
    if v_count_codaccdr_company < 1 then
      param_msg_error := get_error_msg_php('PY0044',global_v_lang,p_codaccdr||' - '||get_taccodb_name('TACCODB',p_codaccdr,global_v_lang));
      return false;
    end if;
    -- รหัส cost center dr จะต้องมีอยู่จริงในตาราง tcoscent (hr2010)
    if p_costcentdr is not null then
      select count(*) into v_count_costcentdr from tcoscent where costcent = upper(p_costcentdr);
      if v_count_costcentdr < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoscent');
        return false;
      end if;
    end if;
    -- รหัสบัญชี cr จะต้องมีอยู่จริงในตาราง taccodb (hr2010)
    begin
      select count(*) into v_count_codacccr
      from taccodb
      where codacc = p_codacccr;
    exception when others then null;
    end;
    if v_count_codacccr < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'taccodb');
      return false;
    end if;
    -- รหัสบัญชี cr จะต้องใช้รหัสของบริษัทตนเองเท่านั้น ตรวจสอบจากตาราง taccodbc แจ้งเตือน “py0044 - รหัสที่ระบุไม่สามารถใช้กับบริษัทนี้”
    begin
      select count(*) into v_count_codacccr_company
      from taccodbc
      where codacc = p_codacccr
      and codcompy = p_codcompy;
    exception when others then null;
    end;
    if v_count_codacccr_company < 1 then
      param_msg_error := get_error_msg_php('PY0044',global_v_lang,p_codacccr||' - '||get_taccodb_name('TACCODB',p_codacccr,global_v_lang));
      return false;
    end if;
    -- รหัส cost center cr จะต้องมีอยู่จริงในตาราง tcoscent (hr2010)
    if p_costcentcr is not null then
      begin
        select count(*) into v_count_costcentcr
        from tcoscent
        where costcent = upper(p_costcentcr);
      exception when others then null;
      end;
      if v_count_costcentcr < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcoscent');
        return false;
      end if;
    end if;
    -- ตรวจสอบ การ dup ของ pk : กรณีรหัสซ้า (hr2005 tglhtabi)
    if v_flg = 'add' then
      begin
        select count(*) into v_count_tglhtabi_dup
        from tglhtabi
        where codcompy = p_codcompy
        and apcode = p_apcode
        and apgrpcod = p_apgrpcod;
      exception when others then null;
      end;
      if v_count_tglhtabi_dup > 0 then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tglhtabi');
        return false;
      end if;
    end if;
    return true;
  end;

  function check_save_tgltabi(p_codpay varchar2) return boolean is
    v_count_codpay          number := 0;
    v_count_codpay_company  number := 0;
    v_count_codpay_dup      number := 0;
  begin
    -- ฟิลด์ที่บังคับใส่ข้อมูล
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return false;
    end if;
    -- จะต้องมีอยู่จริงในตาราง tinexinf (hr2010)
    begin
      select count(*) into v_count_codpay
      from tinexinf
      where codpay = p_codpay;
    exception when others then null;
    end;
    if v_count_codpay < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      return false;
    end if;
    -- ตรวจสอบจากตาราง tinexinfc แจ้งเตือน “py0044 - รหัสที่ระบุไม่สามารถใช้กับบริษัทนี้”
    begin
      select count(*) into v_count_codpay_company
      from tinexinfc
      where codcompy = p_codcompy
      and codpay = p_codpay;
    exception when others then null;
    end;
    if v_count_codpay_company < 1 then
      param_msg_error := get_error_msg_php('PY0044',global_v_lang,p_codpay||' - '||get_tinexinf_name(p_codpay,global_v_lang));
      return false;
    end if;
    -- ไม่สามารถใช้ซ้ากับกลุ่มรหัสรายได้อื่น ในเงื่อนไขบริษัทและกลุ่มบัญชีเดียวกัน (hr2005)
    begin
      select count(*) into v_count_codpay_dup
      from tgltabi
      where codcompy = p_codcompy
      and apcode = p_apcode
      and codpay = p_codpay;
    exception when others then null;
    end;
    if v_count_codpay_dup > 0 then
      param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tgltabi');
      return false;
    end if;
    return true;
  end;

  procedure save_tglhtabi(input_obj json_object_t) is
    p_apgrpcod          varchar2(4 char) := null;
    p_codaccdr          taccodbc.codacc%type := null;
    p_scodaccdr         taccodbc.codacc%type := null;
    p_costcentdr        varchar2(25 char) := null;
    p_codacccr          taccodbc.codacc%type := null;
    p_scodacccr         taccodbc.codacc%type := null;
    p_costcentcr        varchar2(25 char) := null;
    v_flg               varchar2(25 char) := null;
    obj_paycode         json_object_t;
    obj_paycode_row     json_object_t;
    obj_codpay          json_object_t;
    p_codpay            tgltabi.codpay%type := null;
    p_codpay_flg        varchar2(10 char) := null;
    v_count_tgltabi     number;

  begin
    p_apgrpcod    := hcm_util.get_string_t(input_obj,'apgrpcod');
    p_codaccdr    := hcm_util.get_string_t(input_obj,'codaccdr');
    p_scodaccdr   := hcm_util.get_string_t(input_obj,'scodaccdr');
    p_costcentdr  := hcm_util.get_string_t(input_obj,'costcentdr');
    p_codacccr    := hcm_util.get_string_t(input_obj,'codacccr');
    p_scodacccr   := hcm_util.get_string_t(input_obj,'scodacccr');
    p_costcentcr  := hcm_util.get_string_t(input_obj,'costcentcr');
    v_flg         := hcm_util.get_string_t(input_obj,'flg');

      if check_save_tglhtabi(p_apgrpcod ,p_codaccdr ,p_scodaccdr ,p_costcentdr ,p_codacccr ,p_scodacccr ,p_costcentcr ,v_flg ) = false then
          return;
      end if;

      -- บันทึกข้อมูล
      if v_flg = 'add' then
        insert into tglhtabi ( codcompy, apcode, apgrpcod, codaccdr, scodaccdr, costcentdr, codacccr, scodacccr, costcentcr, dtecreate, codcreate, coduser)
             values( p_codcompy, p_apcode, p_apgrpcod, p_codaccdr, p_scodaccdr, p_costcentdr, p_codacccr, p_scodacccr, p_costcentcr,sysdate, global_v_coduser, global_v_coduser);
        log_tglhtabi(v_flg,input_obj);
      elsif v_flg = 'edit' then
          update tglhtabi
             set codaccdr    = p_codaccdr,
                 scodaccdr   = p_scodaccdr,
                 costcentdr  = p_costcentdr,
                 codacccr    = p_codacccr,
                 scodacccr   = p_scodacccr,
                 costcentcr  = p_costcentcr,
                 dteupd      = sysdate,
                 coduser     = global_v_coduser
           where codcompy = p_codcompy
             and apcode = p_apcode
             and apgrpcod = p_apgrpcod;

          log_tglhtabi(v_flg,input_obj);
          update_tgltabi_all(p_codcompy,p_apcode,p_apgrpcod);
      elsif v_flg = 'delete' then
          -- ลบข้อมูล tglhtabi
          delete from tglhtabi
          where
              codcompy = p_codcompy and
              apcode = p_apcode and
              apgrpcod = p_apgrpcod;
          log_tglhtabi(v_flg,input_obj);
          -- ลบข้อมูล tgltabi
          delete from tgltabi
          where
              codcompy = p_codcompy and
              apcode = p_apcode and
              apgrpcod = p_apgrpcod;
--            -- ลบข้อมูล taccap
--            select count(*) into v_count_tglhtabi from tglhtabi where codcompy = p_codcompy and apcode = p_apcode;
--            if v_count_tglhtabi < 1 then
--                delete from taccap where codcompy = p_codcompy and apcode = p_apcode;
--                add_log('-','codcompy',p_codcompy,null);
--                add_log('-','apcode',p_apcode,null);
--                add_log('-','typpaymt',p_typpaymt,null);
--            end if;
      end if;
      obj_paycode   := hcm_util.get_json_t(input_obj,'paycode');
      obj_paycode_row := hcm_util.get_json_t(obj_paycode,'rows');

      for i in 0..obj_paycode_row.get_size-1 loop
          obj_codpay  := hcm_util.get_json_t(obj_paycode_row,to_char(i));
          p_codpay := hcm_util.get_string_t(obj_codpay,'codpay');
          p_codpay_flg := hcm_util.get_string_t(obj_codpay,'flg');
          -- การตรวจสอบก่อนบันทึกข้อมูล
          if p_codpay_flg = 'add' then
              if check_save_tgltabi(p_codpay) = false then
                  exit;
              end if;
--            elsif p_codpay_flg = 'Delete' and v_flg = 'Add' then
--                continue;
          end if;
          -- บันทึกข้อมูล
          if param_msg_error is null then
              save_tgltabi(p_codpay_flg ,p_codpay ,p_apgrpcod  );
          end if;
      end loop;

      /*if v_flg <> 'delete' then
          begin
              select count(*)
                into v_count_tgltabi
                from tgltabi
               where codcompy = p_codcompy
                 and apcode = p_apcode
                 and apgrpcod = p_apgrpcod;
          exception when others then
            v_count_tgltabi := 0;
          end;

          if v_count_tgltabi = 0 then
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'codpay');
            return;
          end if;

      end if;*/

  end save_tglhtabi;

  procedure save_data(json_str_input in clob, json_str_output out clob) is
      obj_tglhtabi       json_object_t;
      v_count_tglhtabi    number := 0;
  begin
      initial_value(json_str_input);
      check_index;
      if param_msg_error is null then
          save_taccap();
          if param_msg_error is not null then
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              return;
          end if;
          param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
          for i in 0..param_json.get_size-1 loop
              obj_tglhtabi := hcm_util.get_json_t(param_json,to_char(i));
              save_tglhtabi(obj_tglhtabi);
              if param_msg_error is not null then
                exit;
              end if;
          end loop;
--            -- ลบข้อมูล taccap
--            select count(*) into v_count_tglhtabi from tglhtabi where codcompy = p_codcompy and apcode = p_apcode;
--            if v_count_tglhtabi < 1 then
--                delete from taccap where codcompy = p_codcompy and apcode = p_apcode;
--                add_log('-','codcompy',p_codcompy,null);
--                add_log('-','apcode',p_apcode,null);
--                add_log('-','typpaymt',p_typpaymt,null);
--            end if;
          if param_msg_error is null then
              commit;
              param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          else
              rollback;
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              return;
          end if;
      end if;

      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure delete_gl (json_str_input in clob, json_str_output out clob) is
    cursor c1 is
      select * from tglhtabi
       where codcompy = p_codcompy
         and apcode = p_apcode;
    cursor c2 is
        select * from tgltabi
        where codcompy = p_codcompy
        and apcode = p_apcode;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      -- log taccap
      add_log('-','codcompy',p_codcompy,null);
      add_log('-','apcode',p_apcode,null);
      add_log('-','typpaymt',p_typpaymt,null);
      -- log tglhtabi
      for i in c1 loop
        add_log(i.apgrpcod,'apgrpcod',i.apgrpcod,null);
        add_log(i.apgrpcod,'codaccdr',i.codaccdr,null);
        add_log(i.apgrpcod,'scodaccdr',i.scodaccdr,null);
        add_log(i.apgrpcod,'costcentdr',i.costcentdr,null);
        add_log(i.apgrpcod,'codacccr',i.codacccr,null);
        add_log(i.apgrpcod,'scodacccr',i.scodacccr,null);
        add_log(i.apgrpcod,'costcentcr',i.costcentcr,null);
      end loop;
      -- log tgltabi
      for j in c2 loop
        add_log(j.apgrpcod,'codpay',j.codpay,null);
      end loop;

      delete from taccap
      where codcompy = p_codcompy
      and apcode = p_apcode;

      delete from tglhtabi
      where codcompy = p_codcompy
      and apcode = p_apcode;

      delete from tgltabi
      where codcompy = p_codcompy
      and apcode = p_apcode;

      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end delete_gl;

  procedure get_codpay_all(json_str_input in clob, json_str_output out clob) is
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
        select codpay
        from TINEXINF
        where typpay like '%'
         and codpay in (select codpay from TINEXINFC where codcompy = p_codcompy)
         and codpay not in (select codpay from tgltabi where codcompy = p_codcompy and apcode = p_apcode)
         order by codpay;
  begin
      initial_value(json_str_input);
      obj_row := json_object_t();
      for i in c1 loop
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codpay',i.codpay);
          obj_data.put('desc_codpay',get_tinexinf_name(i.codpay,global_v_lang));

          obj_row.put(to_char(v_row - 1),obj_data);
      end loop;
      json_str_output := obj_row.to_clob;
  end get_codpay_all;

  function get_apgrpcod_desc (v_apgrpcod varchar2) return varchar2 is
    v_descod  tcodgrpap.descode%type;
  begin
      begin
          select decode(global_v_lang,'101',descode
                                     ,'102',descodt
                                     ,'103',descod3
                                     ,'104',descod4
                                     ,'105',descod5) as descod
          into v_descod
          from tcodgrpap
          where codcodec = v_apgrpcod;
      exception when no_data_found then
          v_descod := '';
      end;
      return v_descod;
  end;

  procedure get_report_data (json_str_input in clob, json_str_output out clob) is
      obj_row         json_object_t;
      obj_data        json_object_t;
      v_row           number := 0;
      v_apgrpcod_desc varchar2(150 char) := '';
      cursor c1 is
        select a.apgrpcod, a.codpay, get_tinexinf_name(a.codpay,global_v_lang) as codpay_desc,
               b.codaccdr, get_taccodb_name('taccodb',b.codaccdr,global_v_lang) as codaccdr_desc,
               b.scodaccdr, b.costcentdr, get_tcoscent_name(b.costcentdr,global_v_lang) as tcoscentdr_name,
               b.codacccr, get_taccodb_name('taccodb',b.codacccr,global_v_lang) as codacccr_desc,
               b.scodacccr, b.costcentcr, get_tcoscent_name(b.costcentcr,global_v_lang) as tcoscentcr_name
          from tgltabi a, tglhtabi b
         where a.codcompy = p_codcompy
           and a.apcode   = p_apcode
           and a.apcode   = b.apcode
           and a.apgrpcod = b.apgrpcod
           and a.codcompy = b.codcompy
         order by apgrpcod,codpay;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      obj_row := json_object_t();
      for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('apgrpcod',i.apgrpcod);
        obj_data.put('apgrpcod_desc',get_apgrpcod_desc(i.apgrpcod));
        obj_data.put('codpay',i.codpay);
        obj_data.put('codpay_desc',i.codpay_desc);
        obj_data.put('codaccdr',i.codaccdr);
        obj_data.put('codaccdr_desc',i.codaccdr_desc);
        obj_data.put('scodaccdr',i.scodaccdr);
        obj_data.put('costcentdr',i.costcentdr);
        obj_data.put('codacccr',i.codacccr);
        obj_data.put('codacccr_desc',i.codacccr_desc);
        obj_data.put('scodacccr',i.scodacccr);
        obj_data.put('costcentcr',i.costcentcr);
        obj_row.put(to_char(v_row-1),obj_data);
        begin
            select descode into v_apgrpcod_desc
            from tcodgrpap
            where codcodec = i.apgrpcod;
        exception when no_data_found then
            v_apgrpcod_desc := '';
        end;
      end loop;
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRPY32E;

/

--------------------------------------------------------
--  DDL for Package Body HRTR69E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR69E" AS

  procedure initial_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');


        p_dteyear         := hcm_util.get_string_t(json_obj,'p_dteyear');
        p_codcompy        := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
        p_codcours        := hcm_util.get_string_t(json_obj,'p_codcours');
        p_numclseq        := hcm_util.get_string_t(json_obj,'p_numclseq');
        p_dtetrain        := to_date(hcm_util.get_string_t(json_obj,'p_dtetrain'),'dd/mm/yyyy');
        p_codempid        := hcm_util.get_string_t(json_obj,'v_codempid');
        p_flgatend          := hcm_util.get_string_t(json_obj,'p_flgatend');
        p_remark          := hcm_util.get_string_t(json_obj,'p_remark');
        p_timin1          := hcm_util.get_string_t(json_obj,'p_timin1');
        p_timin2          := hcm_util.get_string_t(json_obj,'p_timin2');
        p_qtytrabs        := hcm_util.get_string_t(json_obj,'p_qtytrabs');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);


  end initial_value;

  procedure check_index as
    v_temp  varchar2(100 char);
    v_temp2 varchar2(100 char);
    v_temp3 varchar2(1 char);

  begin
--      validate year,codcompy,codcours,numclseq,train date
    if p_dteyear is null or p_codcompy is null or p_codcours is null or p_numclseq is null or p_dtetrain is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

--      check codcompy in tcompy
    begin
      select 'X' into v_temp
      from tcompny
      where codcompy = p_codcompy
      and rownum = 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
      return;
    end;

--      check codcours in tcourse
    begin
      select 'X' into v_temp2
      from tcourse
      where codcours = p_codcours;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
      return;
    end;

--      check data in tyrtrsch
--        begin
--            select 'X' into v_temp3
--            from tyrtrsch
--            where codcompy = p_codcompy
--              and codcours = p_codcours
--              and numclseq = p_numclseq
--              and dteyear = p_dteyear;
--        exception when no_data_found then
--            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tyrtrsch');
--            return;
--        end;

  end check_index;

  procedure check_param as
    v_temp    varchar2(100 char);
    v_codcomp temploy1.codcomp%type;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_flgatend = 'Y' then
      if p_timin1 is not null or p_timin2 is not null then
        if p_timin1 is null or p_timin2 is null then
          if p_remark is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
          end if;
        end if;
      end if;
    end if;

    begin
      select 'X', codcomp
      into v_temp, v_codcomp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;

    begin
      select 'X'
      into v_temp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;

    if secur_main.secur3(v_codcomp, p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) = false then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;

    if p_timin1 > p_timin2 then
      param_msg_error := get_error_msg_php('HR2013',global_v_lang);
      return;
    end if;

    if p_flgatend = 'Y' then
      if p_timin1 is null and p_timin2 is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if (p_timin1 is  null or p_timin2 is null) and p_remark is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    else
      if (p_timin1 is  null and p_timin2 is null) and p_remark is null then
--      if p_qtytrabs is null and p_remark is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;

  end check_param;

  function check_import(data_obj json_object_t) return boolean as
    v_temp      varchar2(100 char);
    v_staemptr  tyrtrsch.staemptr%type;
  begin
    if p_codempid is null then
      v_error_colume := 'codempid';
      v_error := get_errorm_name('HR2045',global_v_lang)||'('||'codempid)';
      return false;
    end if;

    begin
      select 'X' into v_temp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      v_error_colume := 'codempid';
      v_error := get_errorm_name('HR2010',global_v_lang)||'TEMPLOY1'||'('||'codempid)';
      return false;
    end;

    if p_dtetrain_text is not null then
      v_error_colume := 'dtetrain';
      v_error := get_errorm_name('HR2025',global_v_lang)||'('||'dtetrain)';
      return false;
    end if;

    if p_dtetrain is null then
      v_error_colume := 'dtetrain';
      v_error := get_errorm_name('HR2045',global_v_lang)||'('||'dtetrain)';
      return false;
    end if;

    if (length(hcm_util.get_string_t(data_obj,'CODEMPID'))>10) then
      v_error_colume := 'codempid';
      v_error := get_errorm_name('HR6591',global_v_lang)||'('||'codempid)';
      return false;
    end if;
    if (length(hcm_util.get_string_t(data_obj,'FLGATEND'))>1) then
      v_error_colume := 'flgatend';
      v_error := get_errorm_name('HR6591',global_v_lang)||'('||'flgatend)';
      return false;
    end if;

    if p_flgatend != 'Y' and p_flgatend != 'N' then
      v_error_colume := 'flgatend';
      v_error := get_errorm_name('HR2020',global_v_lang)||'('||'flgatend)';
      return false;
    end if;

    if (length(REPLACE(hcm_util.get_string_t(data_obj,'TIMIN'),':'))>4) then
      v_error_colume := 'timin1';
      v_error := get_errorm_name('HR6591',global_v_lang)||'('||'timin1)';
      return false;
    end if;

    if (length(REPLACE(hcm_util.get_string_t(data_obj,'TIMIN2'),':'))>4) then
      v_error_colume := 'timin2';
      v_error := get_errorm_name('HR6591',global_v_lang)||'('||'timin2)';
      return false;
    end if;

    if (length(hcm_util.get_string_t(data_obj,'REMARK'))>500) then
      v_error_colume := 'remark';
      v_error := get_errorm_name('HR6591',global_v_lang)||'('||'remark)';
      return false;
    end if;

    if (p_dtetrain != p_dtetrain2) then
      v_error_colume := 'dtetrain';
      v_error := get_errorm_name('HR2025',global_v_lang)||'('||'dtetrain)';
      return false;
    end if;
    return true;
  end check_import;

  function check_import2 return boolean as
      v_temp     varchar2(100 char);
      v_temp2    varchar2(100 char);
      v_chkdate  varchar2(100 char);
      v_codcomp  temploy1.codcomp%type;
      v_staemptr tyrtrsch.staemptr%type;
  begin
    begin
      select staemptr into v_staemptr
      from tyrtrsch
      where dteyear = p_dteyear
        and codcompy = p_codcompy
        and codcours = p_codcours
        and numclseq = p_numclseq;
    exception when no_data_found then
      v_staemptr := '';
    end;
    if v_staemptr = '2' then
      begin
        select 'Y' into v_temp
          from tpotentp
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and numclseq = p_numclseq
           and codcours = p_codcours
           and codempid = p_codempid;
      exception when no_data_found then
        v_error_colume := 'codempid';
        v_error := get_errorm_name('HR2010',global_v_lang)||'TPOTENTP';
        return false;
      end;
    end if;
    begin
      select codcomp into v_codcomp
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := '';
    end;
    if secur_main.secur3(v_codcomp, p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) = false then
      v_error_colume := 'codempid';
      v_error := get_errorm_name('HR3007',global_v_lang)||'('||'codempid)';
      return false;
    end if;
    if p_timin1 > p_timin2 then
      v_error_colume := 'timin1';
      v_error := get_errorm_name('HR2013',global_v_lang)||'('||'timin1)';
      return false;
    end if;
    if p_flgatend = 'Y' then
      if p_timin1 is null and p_timin2 is null then
        v_error_colume := 'timin1';
        v_error := get_errorm_name('HR2045',global_v_lang)||'('||'timin1, timin2)';
        return false;
      end if;
      if ((p_timin1 is not null and p_timin2 is null) or (p_timin1 is null and p_timin2 is not null)) and p_remark is null then
        v_error := get_errorm_name('HR2045',global_v_lang)||'('||'remark)';
        return false;
      end if;
    else
      if p_qtytrabs is null then
        v_error_colume := 'qtytrabs';
        v_error := get_errorm_name('HR2045',global_v_lang)||'('||'qtytrabs)';
        return false;
      end if;
      if p_remark is null then
        v_error_colume := 'remark';
        v_error := get_errorm_name('HR2045',global_v_lang)||'('||'remark)';
        return false;
      end if;
    end if;

    begin
      v_chkdate := to_number(p_timin1);
      v_chkdate := to_number(p_timin2);
    exception when VALUE_ERROR THEN
      v_error := get_errorm_name('HR2015',global_v_lang);
      return false;
    end;

    return true;
  end check_import2;

  procedure insert_index as
  begin
    begin
        insert into tpotentpd
            (
             dteyear, codcompy, numclseq, codcours, codempid, dtetrain,
             flgatend, timin, remark, codcreate, coduser, timin2, qtytrabs
            )
        values
            (
             p_dteyear, p_codcompy, p_numclseq, p_codcours, p_codempid, p_dtetrain,
             p_flgatend, p_timin1, p_remark, global_v_coduser, global_v_coduser, p_timin2,p_qtytrabs
            );
    exception when dup_val_on_index then
        update tpotentpd
        set flgatend = p_flgatend,
            timin = p_timin1,
            timin2 = p_timin2,
            qtytrabs = p_qtytrabs,
            remark = p_remark,
            coduser = global_v_coduser
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and numclseq = p_numclseq
          and codcours = p_codcours
          and codempid = p_codempid;
    end;
  end insert_index;

  procedure insert_tpotentp(v_codtparg in VARCHAR2, v_dtetrst in date, v_dtetren in date, v_codcours in VARCHAR2, v_numclseq in number) as
    v_numlvl      temploy1.numlvl%type;
  begin
    begin
        select numlvl into v_numlvl
        from temploy1
        where codempid = p_codempid;
    exception when no_data_found then
        v_numlvl := '';
    end;
    insert into tpotentp (dteyear, codcompy, numclseq, codcours, codempid, codcomp, codpos, numlvl, codtparg, flgatend, dtetrst, dtetren, stacours, flgwait, staappr, flgqlify, codcreate, dtecreate, coduser, dteupd)
    values (p_dteyear, p_codcompy, v_numclseq, v_codcours, p_codempid, p_codcomp, p_codpos, v_numlvl,v_codtparg, p_flgatend, v_dtetrst, v_dtetren, 'W', 'N', 'Y', 'N', global_v_coduser, sysdate, global_v_coduser, sysdate);
  end insert_tpotentp;

  procedure update_index as
    v_flgExist number;
  begin
    update tpotentp
    set flgatend = p_flgatend,
        coduser = global_v_coduser,
        codcomp = p_codcomp
    where dteyear = p_dteyear
      and codcompy = p_codcompy
      and numclseq = p_numclseq
      and codcours = p_codcours
      and codempid = p_codempid;
    --
    begin
      select count(*) into v_flgExist
        from tpotentpd
       where dteyear = p_dteyear
        and codcompy = p_codcompy
        and numclseq = p_numclseq
        and codcours = p_codcours
        and codempid = p_codempid
        and dtetrain = p_dtetrain;
    exception when no_data_found then
      v_flgExist := 0;
    end;
    if v_flgExist = 0 then
       insert into tpotentpd ( dteyear, codcompy, numclseq, codcours, codempid, dtetrain,
                               flgatend, timin, remark, timin2, qtytrabs, codcreate, coduser )
            values ( p_dteyear, p_codcompy, p_numclseq, p_codcours, p_codempid, p_dtetrain,
                     p_flgatend, p_timin1, p_remark, p_timin2,p_qtytrabs, global_v_coduser, global_v_coduser );
    else
      update tpotentpd
      set flgatend = p_flgatend,
          timin = p_timin1,
          timin2 = p_timin2,
          qtytrabs = p_qtytrabs,
          remark = p_remark,
          coduser = global_v_coduser
      where dteyear = p_dteyear
        and codcompy = p_codcompy
        and numclseq = p_numclseq
        and codcours = p_codcours
        and codempid = p_codempid
        and dtetrain = p_dtetrain;
    end if;
  end update_index;

  procedure delete_index as
    v_temp varchar2(100 char);
   begin
    begin
        delete tpotentpd
         where dteyear = p_dteyear
          and codcompy = p_codcompy
          and numclseq = p_numclseq
          and codcours = p_codcours
          and codempid = p_codempid
          and dtetrain = p_dtetrain;

        select count(*) into v_temp
        from tpotentpd
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and numclseq = p_numclseq
          and codcours = p_codcours
          and codempid = p_codempid;
    end;
        if v_temp = 0 then
            delete tpotentp
             where dteyear = p_dteyear
              and codcompy = p_codcompy
              and numclseq = p_numclseq
              and codcours = p_codcours
              and codempid = p_codempid;
        end if;
   end delete_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows       json_object_t;
    obj_data       json_object_t;
    obj_result     json_object_t;
    v_row          number := 0;
    p_timin1       tpotentpd.timin%type;
    p_timin2       tpotentpd.timin2%type;
    p_flgatend     tpotentpd.flgatend%type;
    p_flgatend_bool     boolean;
    p_qtytrabs     tpotentpd.qtytrabs%type;
    p_remark       tpotentpd.remark%type;
    v_staemptr     tyrtrsch.staemptr%type;
    v_chk_secur    boolean := false;
    v_count_secur  number := 0;
    v_count        number := 0;

    cursor c1 is
        select codempid,codcomp, codpos, stacours
        from tpotentp
        where dteyear = p_dteyear
        and codcompy = p_codcompy
        and numclseq = p_numclseq
        and codcours = p_codcours
        and p_dtetrain between dtetrst and dtetren
        and staappr = 'Y'
        order by codcompy,codpos,codempid;

  begin
    begin
      select staemptr into v_staemptr
        from tyrtrsch
      where dteyear = p_dteyear
        and codcompy = p_codcompy
        and codcours = p_codcours
        and numclseq = p_numclseq;
    exception when no_data_found then
      v_staemptr := '';
    end;
    obj_rows    := json_object_t();
    for i in c1 loop
      v_count := v_count + 1;
      v_chk_secur := secur_main.secur3(i.codcomp,i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_chk_secur then
        v_count_secur := v_count_secur + 1;
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid',i.codempid);
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('codpos',i.codpos);
        obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
        obj_data.put('tcenter_name',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('codpos_name',get_tpostn_name(i.codpos,global_v_lang));
        obj_data.put('stacours',i.stacours);
        begin
          select nvl(flgatend,'N'),timin,timin2,qtytrabs,remark into p_flgatend,p_timin1,p_timin2,p_qtytrabs,p_remark
          from tpotentpd
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and numclseq = p_numclseq
            and codcours = p_codcours
            and codempid = i.codempid
            and dtetrain = p_dtetrain;
        exception when no_data_found then
          p_flgatend := 'N';
          p_timin1 := '';
          p_timin2 := '';
          p_qtytrabs := '';
          p_remark := '';
        end;
        if p_flgatend = 'Y' then
          p_flgatend_bool := true;
        else
          p_flgatend_bool := false;
        end if;
        obj_data.put('staemptr',v_staemptr);
        obj_data.put('flgatend',p_flgatend_bool);
        obj_data.put('timin', p_timin1);
        obj_data.put('timin2',p_timin2);
        obj_data.put('qtytrabs',hcm_util.convert_minute_to_hour(p_qtytrabs*60));
        obj_data.put('remark',p_remark);
        obj_rows.put(to_char(v_row-1),obj_data);
      end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    else
      obj_result := json_object_t();
      obj_result.put('coderror', '200');
      obj_result.put('table',obj_rows);
      obj_result.put('staemptr',v_staemptr);
      json_str_output := obj_result.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure gen_employee(json_str_output out clob) as
     obj_rows    json_object_t;
     obj_data    json_object_t;
     v_row       number := 0;
     v_secur     varchar2(1 char) := 'N';
     v_data      varchar2(1 char) := 'N';
     v_chk_secur boolean := false;

     cursor c1 is
        select codcomp,codpos
        from temploy1
        where codempid = nvl(p_codempid,codempid);

  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_data := 'Y';
      v_chk_secur := secur_main.secur7(i.codcomp,global_v_coduser);
      if v_chk_secur then
        v_secur := 'Y';
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('codpos',i.codpos);
        obj_data.put('tcenter_name',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('codpos_name',get_tpostn_name(i.codpos,global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
      end if;
    end loop;
    if v_data = 'Y' and v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_employee;

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

  procedure get_employee(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_employee(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_employee;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj    json_object_t;
    data_obj    json_object_t;
    v_item_flgedit varchar2(100 char);
    v_temp         varchar2(100 char);
    v_codtparg     tyrtrsch.codtparg%type;
    v_dtetrst      tyrtrsch.dtetrst%type;
    v_dtetren      tyrtrsch.dtetren%type;
    v_codcours     tyrtrsch.codcours%type;
    v_numclseq     tyrtrsch.numclseq%type;
    v_staemptr     tyrtrsch.staemptr%type;
    v_temp2        varchar2(100 char);
    v_check_del    varchar(1 char);
    v_flgatend_bool    boolean;
  BEGIN
    initial_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size-1 loop
      data_obj          := hcm_util.get_json_t(param_json,to_char(i));
      p_codempid        := hcm_util.get_string_t(data_obj,'codempid');
      p_codcomp         := hcm_util.get_string_t(data_obj,'codcomp');
      p_codpos          := hcm_util.get_string_t(data_obj,'codpos');
      v_flgatend_bool        := hcm_util.get_boolean_t(data_obj,'flgatend');
      p_staemptr        := hcm_util.get_string_t(data_obj,'staemptr');
      p_timin1          := REPLACE(hcm_util.get_string_t(data_obj,'timin'),':');
      p_timin2          := REPLACE(hcm_util.get_string_t(data_obj,'timin2'),':');
      p_qtytrabs        := to_number(REPLACE(hcm_util.get_string_t(data_obj,'qtytrabs'), ':', '.'));
      p_remark          := hcm_util.get_string_t(data_obj,'remark');
      p_stacours        := hcm_util.get_string_t(data_obj,'stacours');
      v_item_flgedit    := hcm_util.get_string_t(data_obj,'flg');

      if v_flgatend_bool then
        p_flgatend  := 'Y';
      else
        p_flgatend  := 'N';
      end if;
      if p_timin1 is not null or p_timin2 is not null then
        p_flgatend  := 'Y';
      end if;
--            p_dteyear         := hcm_util.get_string_t(data_obj,'p_dteyear');
--            p_codcompy        := upper(hcm_util.get_string_t(data_obj,'p_codcompy'));
--            p_codcours        := hcm_util.get_string_t(data_obj,'p_codcours');
--            p_numclseq        := hcm_util.get_string_t(data_obj,'p_numclseq');
--            p_dtetrain        := to_date(hcm_util.get_string_t(data_obj,'p_dtetrain'),'dd/mm/yyyy');

      if v_item_flgedit != 'delete' then
        check_param;
      end if ;
      if (p_timin1 is not null and p_timin2 is null) or (p_timin1 is null and p_timin2 is not null) then
        p_qtytrabs := 4;
      end if;
      if p_timin1 is null and p_timin2 is null then
        p_qtytrabs := 8;
      end if;
      begin
        select codtparg,dtetrst,dtetren,codcours,numclseq,staemptr into v_codtparg,v_dtetrst,v_dtetren,v_codcours,v_numclseq,v_staemptr
          from tyrtrsch
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and numclseq = p_numclseq;
      exception when no_data_found then
        v_codtparg := '';
        v_dtetrst  := '';
        v_dtetren  := '';
        v_codcours := '';
        v_numclseq := '';
        v_staemptr := '';
      end;

      begin
        select count(*) into v_temp2
        from tpotentpd
        where dteyear = p_dteyear
          and codcompy = p_codcompy
          and numclseq = p_numclseq
          and codcours = p_codcours
          and codempid = p_codempid;
      end;

      if param_msg_error is  null then
        v_check_del := 'N';
        if  v_staemptr = 1 then
          if v_item_flgedit = 'add' then
            if v_temp2 > 0 then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpotentpd');
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            end if;
            insert_index;
            begin
              select count(*) into v_temp
              from tpotentp
              where dteyear = p_dteyear
                and codcompy = p_codcompy
                and codcours = p_codcours
                and numclseq = p_numclseq
                and codempid = p_codempid;
            end;
            if v_temp = 0 then
              insert_tpotentp(v_codtparg,v_dtetrst,v_dtetren,v_codcours,v_numclseq);
            end if;
          elsif v_item_flgedit = 'edit' then
            update_index;
          elsif v_item_flgedit = 'delete' then
            v_check_del := 'Y';
            delete_index;
          end if;
        else
          if v_item_flgedit = 'add' then
            if v_temp2 > 0 then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpotentpd');
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
              return;
            end if;
            insert_index;
          elsif v_item_flgedit = 'edit' then
            update_index;
          elsif v_item_flgedit = 'delete' then
            v_check_del := 'Y';
            delete_index;
          end if;
        end if;
      end if;
    end loop;
    if param_msg_error is not null then
      if v_check_del = 'Y' then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure import_data_process(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_text         long;
    v_coderror     terrorm.errorno%type;
    v_rec_err      number := 0;
    v_temp         number;
    v_codtparg     tyrtrsch.codtparg%type;
    v_dtetrst      tyrtrsch.dtetrst%type;
    v_dtetren      tyrtrsch.dtetren%type;
    v_codcours     tyrtrsch.codcours%type;
    v_numclseq     tyrtrsch.numclseq%type;
    v_staemptr     tyrtrsch.staemptr%type;
    v_temp2        number;
    obj_result     json_object_t;
    obj_data       json_object_t;
    obj_rows       json_object_t;
    v_rec_tran     number := 0;
    v_row          number := 0;
    v_validate     boolean;
  BEGIN
        initial_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_rows    := json_object_t();
        for i in 0..param_json.get_size-1 loop
            data_obj          := hcm_util.get_json_t(param_json,to_char(i));
            p_dteyear         := hcm_util.get_string_t(data_obj,'p_dteyear');
            p_codcompy        := upper(hcm_util.get_string_t(data_obj,'p_codcompy'));
            p_codcours        := hcm_util.get_string_t(data_obj,'p_codcours');
            p_numclseq        := to_number(hcm_util.get_string_t(data_obj,'p_numclseq'));
            begin
                p_dtetrain        := to_date(hcm_util.get_string_t(data_obj,'DTETRAIN'),'dd/mm/yyyy');
                p_dtetrain_text   := null;
            exception when others then
                p_dtetrain_text   := hcm_util.get_string_t(data_obj,'DTETRAIN');
            end;
            p_dtetrain2       := to_date(hcm_util.get_string_t(data_obj,'p_dtetrain2'),'dd/mm/yyyy');
            p_codempid        := hcm_util.get_string_t(data_obj,'CODEMPID');
            p_flgatend          := hcm_util.get_string_t(data_obj,'FLGATEND');
            p_remark          := hcm_util.get_string_t(data_obj,'REMARK');
            p_timin1          := REPLACE(hcm_util.get_string_t(data_obj,'TIMIN'),':');
            p_timin2          := REPLACE(hcm_util.get_string_t(data_obj,'TIMIN2'),':');
            p_qtytrabs        := to_number(REPLACE(hcm_util.get_string_t(data_obj,'p_qtytrabs'), ':', '.'));

            if (p_timin1 is not null and p_timin2 is null) or (p_timin1 is null and p_timin2 is not null) then
              p_qtytrabs := 4;
            end if;
            if p_timin1 is null and p_timin2 is null then
              p_qtytrabs := 8;
            end if;
            v_validate := check_import(data_obj);
            if v_validate = true then
                v_validate := check_import2;
            end if;
            if v_validate = false then
                p_dtetrain_text := hcm_util.get_string_t(data_obj,'DTETRAIN');
                v_text := p_codempid||'|'||p_dtetrain_text||'|'||p_flgatend||'|'||p_timin1||'|'||p_timin2||'|'||p_qtytrabs||'|'||
                           '|'||p_remark;
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_error);
                obj_data.put('error_colume',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else

                begin
                    select codpos into p_codpos
                    from temploy1
                    where codempid = p_codempid;
                 exception when no_data_found then
                    p_codpos := '';
                 end;

                begin
                    select codtparg,dtetrst,dtetren,codcours,numclseq,staemptr into v_codtparg,v_dtetrst,v_dtetren,v_codcours,v_numclseq,v_staemptr
                    from tyrtrsch
                    where dteyear = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and numclseq = p_numclseq;
                exception when no_data_found then
                    v_codtparg := '';
                    v_dtetrst  := '';
                    v_dtetren  := '';
                    v_codcours := '';
                    v_numclseq := '';
                    v_staemptr := '';
                end;
                begin
                    select codcomp into p_codcomp
                    from temploy1
                    where codempid = p_codempid;
                exception when no_data_found then
                    p_codcomp := '';
                end;
                if  v_staemptr = 1 then
                    insert_index;
                    select count(*) into v_temp
                    from tpotentp
                    where dteyear = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and numclseq = p_numclseq
                      and codempid = p_codempid;
                    if v_temp = 0 then
                        insert_tpotentp(v_codtparg,v_dtetrst,v_dtetren,v_codcours,v_numclseq);
                    else
                        update tpotentp
                           set tpotentp.flgatend = p_flgatend,
                               coduser = global_v_coduser,
                               codcomp = p_codcomp
                         where dteyear = p_dteyear
                           and codcompy = p_codcompy
                           and numclseq = p_numclseq
                           and codcours = p_codcours
                           and codempid = p_codempid;
                    end if;
                else
                    insert_index;
                    if p_flgatend = 'Y' then
                        update_index;
                    end if;
                end if;
                v_rec_tran := v_rec_tran+1;
            end if;
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
              obj_data    := json_object_t();
              obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
              obj_data.put('rec_trans', v_rec_tran);
              obj_data.put('rec_err', v_rec_err);
              obj_data.put('detail', obj_rows);
              obj_rows    := json_object_t();
              obj_rows.put('datadisp',obj_data);
              json_str_output := obj_rows.to_clob;

        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end import_data_process;

END HRTR69E;

/

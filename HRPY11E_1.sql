--------------------------------------------------------
--  DDL for Package Body HRPY11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY11E" as
  procedure initial_value(json_str_input in clob) as
      json_obj json_object_t;
  begin
      json_obj          := json_object_t(json_str_input);
      global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
      global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_value;

  procedure check_get_index(p_codcompy varchar2) as
    v_count     number := 0;
    v_secure    varchar2(4000 char) := null;
  begin
    select count(*) into v_count from tcompny where codcompy = p_codcompy;
    if v_count < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcompny');
      return;
    end if;

    -- check secure
    v_secure        := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    if v_secure is not null then
      param_msg_error := v_secure;
      return;
    end if;
  end check_get_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
      json_obj            json_object_t;
      obj_data            json_object_t;
      obj_row             json_object_t;
      p_dteyreff          number(4,0);
      p_codcompy          varchar2(4 char);
      p_typincom          varchar2(2 char);
      v_row               number := 0;
      v_count_found       number := 0;
      v_count_not_found   number := 0;
      v_ttaxinf_rec       ttaxinf%rowtype;
      v_other_year        number := null;
      v_flg_add           boolean := false;
      cursor c1 is
          select * from ttaxinf
          where
              dteyreff = p_dteyreff and
              codcompy = p_codcompy and
              typincom = p_typincom
          order by numseq;
      cursor c2 is
          select * from ttaxinf
          where
              dteyreff = v_other_year and
              codcompy = p_codcompy and
              typincom = p_typincom
          order by numseq;
  begin
      initial_value(json_str_input);
      json_obj  := json_object_t(json_str_input);
      obj_row   := json_object_t();
      p_dteyreff := to_number(hcm_util.get_string_t(json_obj,'p_dteyreff'));
      p_codcompy := hcm_util.get_string_t(json_obj,'p_codcompy');
      p_typincom := hcm_util.get_string_t(json_obj,'p_typincom');

      check_get_index(p_codcompy);
      if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
      end if;

      begin
          select count(*) into v_count_found
          from ttaxinf
          where
              dteyreff = p_dteyreff and
              codcompy = p_codcompy and
              typincom = p_typincom
          order by numseq;
      exception when others then null;
      end;

      if v_count_found > 0 then
          -- set obj
          for i in c1 loop
              v_row := v_row + 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('codcompy',i.codcompy);
              obj_data.put('dteyreff',i.dteyreff);
              obj_data.put('typincom',i.typincom);
              obj_data.put('numseq',i.numseq);
              obj_data.put('amtsalst',to_char(i.amtsalst));
              obj_data.put('amtsalen',to_char(i.amtsalen));
              obj_data.put('pcttax',to_char(i.pcttax));
              obj_data.put('amttaxacc',to_char(i.amttaxacc));
              obj_data.put('amtacccal',i.amtacccal);
              obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
              obj_data.put('coduser',i.codcompy);
              obj_data.put('codempid',get_codempid(i.coduser));
              obj_data.put('namedit',get_temploy_name(get_codempid(i.coduser),global_v_lang));
              obj_row.put(to_char(v_row-1),obj_data);
          end loop;
      else
          begin
              select count(*)
              into v_count_not_found
              from ttaxinf
              where dteyreff < p_dteyreff
              and codcompy = p_codcompy
              and typincom = p_typincom
              order by numseq;
          exception when others then null;
          end;
          if v_count_not_found > 0 then
              -- get year
              begin
                select max(dteyreff)
                into v_other_year
                from ttaxinf
                where dteyreff < p_dteyreff
                  and codcompy = p_codcompy
                  and typincom = p_typincom
                order by dteyreff desc;
              exception when others then null;
              end;
              if p_dteyreff >= to_char(sysdate, 'yyyy') then
                v_flg_add := true;
              end if;
              -- set obj
               for i in c2 loop
                  v_row := v_row + 1;
                  obj_data := json_object_t();
                  obj_data.put('coderror','200');
                  obj_data.put('codcompy',i.codcompy);
                  obj_data.put('dteyreff',i.dteyreff);
                  obj_data.put('typincom',i.typincom);
                  obj_data.put('numseq',i.numseq);
                  obj_data.put('amtsalst',to_char(i.amtsalst));
                  obj_data.put('amtsalen',to_char(i.amtsalen));
                  obj_data.put('pcttax',to_char(i.pcttax));
                  obj_data.put('amttaxacc',to_char(i.amttaxacc));
                  obj_data.put('amtacccal',i.amtacccal);
                  obj_data.put('flgAdd',v_flg_add);
                  obj_row.put(to_char(v_row-1),obj_data);
              end loop;
          end if;
      end if;
      json_str_output := obj_row.to_clob;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure validate_save(p_dteyreff number,p_codcompy varchar2,p_typincom varchar2,v_numseq number,v_amtsalst number,v_amtsalen number,v_pcttax number) as
  begin
  --      เงินได้ตั้งแต่ ต้อง <= เงินได้ถึง (hr2022)
      if v_amtsalst > v_amtsalen then
          param_msg_error := get_error_msg_php('HR2022',global_v_lang);
          return;
      end if;
  --      ฟิลด์ ‘อัตราภาษี’ ใส่ข้อมูลได้ตั้งแต่ 0 – 100 เท่านั้น (hr2020)
      if v_pcttax < 0 or v_pcttax > 100 then
          param_msg_error := get_error_msg_php('HR2020',global_v_lang);
          return;
      end if;
  end;

  function check_save_value(param_json json_object_t) return  boolean is
      obj_now         json_object_t;
      obj_compare     json_object_t;
      now_str         number;
      now_end         number;
      now_numseq      number;
      now_editflg     varchar2(10 char);
      compare_str     number;
      compare_end     number;
      compare_numseq  number;
      compare_editflg varchar2(10 char);
  begin
      for i in 0..param_json.get_size-1 loop
          obj_now  := hcm_util.get_json_t(param_json,to_char(i));
          now_str      := to_number(hcm_util.get_string_t(obj_now,'amtsalst'));
          now_end      := to_number(hcm_util.get_string_t(obj_now,'amtsalen'));
          now_numseq   := to_number(hcm_util.get_string_t(obj_now,'numseq'));
          now_editflg  := hcm_util.get_string_t(obj_now,'flg');
          if now_editflg != 'delete' then
              for j in 0..param_json.get_size-1 loop
                  if j > i then
                      obj_compare  := hcm_util.get_json_t(param_json,to_char(j));
                      compare_str      := to_number(hcm_util.get_string_t(obj_compare,'amtsalst'));
                      compare_end      := to_number(hcm_util.get_string_t(obj_compare,'amtsalen'));
                      compare_numseq   := to_number(hcm_util.get_string_t(obj_compare,'numseq'));
                      compare_editflg  := hcm_util.get_string_t(obj_compare,'flg');
                      if (compare_editflg != 'delete') then
                          if (now_str > compare_str or now_str > compare_end or now_end > compare_str or now_end > compare_end) then
                              param_msg_error := get_error_msg_php('HR2020',global_v_lang,'numseq '||now_numseq|| ' and '||compare_numseq);
                              return false;
                          end if;
                      end if;
                  end if;
              end loop;
          end if;
      end loop;
      return true;
  end;

  procedure save_index(json_str_input in clob,json_str_output out clob) as
      param_json      json_object_t;
      json_obj        json_object_t;
      obj_data        json_object_t;
      p_dteyreff      number(4,0);
      p_codcompy      varchar2(4 char);
      p_typincom      varchar2(2 char);
      v_editflg       varchar2(10 char);
      v_numseq        number(2,0);
      v_amtsalst      number;
      v_amtsalen      number;
      v_pcttax        number(5,2);
      v_amttaxacc     number;
      v_amtacccal     number := 0;
      v_count_dup     number := 0;
      v_check_save    boolean;
      iscopy          varchar2(1 char) := 'N';
      --<<User37 #5445 Final Test Phase 1 V11 03/03/2021
      v_cntadd        number := 0;
      v_cntdel        number := 0;
      v_cntedit       number := 0;
      -->>User37 #5445 Final Test Phase 1 V11 03/03/2021

      cursor c1 is
        select *
          from ttaxinf
         where codcompy = upper(p_codcompy)
           and dteyreff = p_dteyreff
           and typincom = p_typincom;
  begin
      initial_value(json_str_input);
      json_obj       := json_object_t(json_str_input);
      param_json     := hcm_util.get_json_t(json_obj,'param_json');
      p_dteyreff     := to_number(hcm_util.get_string_t(json_obj,'dteyreff'));
      p_codcompy     := hcm_util.get_string_t(json_obj,'codcompy');
      p_typincom     := hcm_util.get_string_t(json_obj,'typincom');
      iscopy         := hcm_util.get_string_t(json_obj, 'isCopy');
      -- case copy
      if iscopy = 'Y' then
          delete from ttaxinf
          where
              codcompy = p_codcompy and
              dteyreff = p_dteyreff and
              typincom = p_typincom;
      end if;
      -- /case copy
      if check_save_value(param_json) = false then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
      end if;
      for i in 0..param_json.get_size-1 loop
          obj_data    := hcm_util.get_json_t(param_json,to_char(i));
          v_editflg   := hcm_util.get_string_t(obj_data,'flg');
          -- case copy
          if iscopy = 'Y' then
            if v_editflg = 'delete' then
              continue;
            end if;
            v_editflg := 'add';
          end if;
          -- /case copy
          v_numseq        := to_number(hcm_util.get_string_t(obj_data,'numseq'));
          v_amtsalst      := to_number(hcm_util.get_string_t(obj_data,'amtsalst'));
          v_amtsalen      := to_number(hcm_util.get_string_t(obj_data,'amtsalen'));
          v_pcttax        := to_number(hcm_util.get_string_t(obj_data,'pcttax'));
          v_amttaxacc     := to_number(hcm_util.get_string_t(obj_data,'amttaxacc'));

          validate_save(p_dteyreff,p_codcompy,p_typincom,v_numseq,v_amtsalst,v_amtsalen,v_pcttax);
          if  param_msg_error is not null then
              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              return;
          end if;
          if v_editflg = 'add' then
            -- ตรวจสอบ การ dup ของ pk : กรณีรหัสซ้า (hr2005 ttaxinf)
              begin
                  select count(*) into v_count_dup
                  from ttaxinf
                  where
                  codcompy = upper(p_codcompy) and
                  dteyreff = p_dteyreff and
                  typincom = p_typincom and
                  numseq = v_numseq;
              exception when others then null;
              end;
              if v_count_dup > 0 then
                  param_msg_error := get_error_msg_php('HR2005',global_v_lang,'ttaxinf)' );
                  json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                  return;
              end if;
            insert into ttaxinf (dteyreff,codcompy,typincom,numseq,
                                 amtsalst,amtsalen,pcttax,amttaxacc,
                                 amtacccal,dtecreate,codcreate,coduser)
                 values (p_dteyreff,p_codcompy,p_typincom,v_numseq,
                         v_amtsalst,v_amtsalen,v_pcttax,v_amttaxacc,
                         v_amtacccal,sysdate,global_v_coduser,global_v_coduser);
            v_cntadd    := v_cntadd+1;--User37 #5445 Final Test Phase 1 V11 03/03/2021
          elsif v_editflg = 'edit' then
              update ttaxinf set
                  amtsalst  = v_amtsalst,
                  amtsalen  = v_amtsalen,
                  pcttax    = v_pcttax,
                  amttaxacc = v_amttaxacc,
                  amtacccal = v_amtacccal,
                  dteupd    = sysdate,
                  coduser   = global_v_coduser
              where
                  codcompy = p_codcompy and
                  dteyreff = p_dteyreff and
                  typincom = p_typincom and
                  numseq = v_numseq;
              v_cntedit    := v_cntedit+1;--User37 #5445 Final Test Phase 1 V11 03/03/2021
          elsif v_editflg = 'delete' then
              delete from ttaxinf
              where
                  codcompy = p_codcompy and
                  dteyreff = p_dteyreff and
                  typincom = p_typincom and
                  numseq = v_numseq;
              v_cntdel    := v_cntdel+1;--User37 #5445 Final Test Phase 1 V11 03/03/2021
          end if;
      end loop;
      ---
      for i in c1 loop
          begin
              select amttaxacc into v_amtacccal
              from ttaxinf
              where
                  codcompy = upper(i.codcompy) and
                  dteyreff = i.dteyreff and
                  typincom = i.typincom and
                  numseq < i.numseq
              order by numseq desc
              fetch first row only;
          exception when no_data_found then
              v_amtacccal := 0;
          end;
          update ttaxinf set
                  amtacccal = v_amtacccal
              where
                  codcompy = p_codcompy and
                  dteyreff = p_dteyreff and
                  typincom = p_typincom and
                  numseq = i.numseq;
      end loop;
      if param_msg_error is null then
          --<<User37 #5445 Final Test Phase 1 V11 03/03/2021
          if v_cntdel > 0 and v_cntedit = 0 and v_cntadd = 0 then
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
          else
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          end if;
          --param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          -->>User37 #5445 Final Test Phase 1 V11 03/03/2021
          commit;
      else
          rollback;
      end if;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  function get_typincom_desc(p_typincom varchar2) return varchar2 is
      v_desc      varchar2(150 char) := '';
      tlistval_rec    tlistval%rowtype;
  begin
      select desc_label into v_desc
      from tlistval
      where
          codapp = 'TYPINCOM' and
          list_value = p_typincom and
          codlang = global_v_lang;
      return v_desc;
  exception when no_data_found then
      return '';
  end;

  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    p_dteyreff          number(4,0);
    p_codcompy          varchar2(4 char);
    p_typincom          varchar2(2 char);
    v_secure    varchar2(4000 char) := null;

    cursor c1 is
      select distinct codcompy,dteyreff,typincom
        from ttaxinf
       where codcompy <> p_codcompy
          or dteyreff <> p_dteyreff
          or typincom <> p_typincom
       order by dteyreff desc,codcompy,typincom;
  begin
      initial_value(json_str_input);

      json_obj  := json_object_t(json_str_input);
      obj_row   := json_object_t();

      p_dteyreff := to_number(hcm_util.get_string_t(json_obj,'p_dteyreff'));
      p_codcompy := hcm_util.get_string_t(json_obj,'p_codcompy');
      p_typincom := hcm_util.get_string_t(json_obj,'p_typincom');

      for i in c1 loop
          v_secure := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,i.codcompy);
          if v_secure is null then
              v_row := v_row + 1;
              obj_data    := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('codcompy',i.codcompy);
              obj_data.put('dteyreff',i.dteyreff);
              obj_data.put('typincom',i.typincom);
              obj_data.put('descod',get_typincom_desc(i.typincom));
              obj_row.put(to_char(v_row-1),obj_data);
          end if;
      end loop;
      json_str_output := obj_row.to_clob;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_copy_list;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    json_obj      json_object_t;
    obj_row       json_object_t;
    p_dteyreff    number(4,0);
    p_codcompy    varchar2(4 char);
    p_typincom    varchar2(2 char);
    p_dteyreffQuery    number(4,0);
    p_codcompyQuery    varchar2(4 char);
    p_typincomQuery    varchar2(2 char);
    v_coduser     ttaxinf.coduser%type;
    v_dteupd      ttaxinf.dteupd%type;
    v_count_found   number := 0;
    v_other_year    number := null;
    v_warning      varchar2(4000 char);--User37 #5443 Final Test Phase 1 V11 05/03/2021
  begin
    initial_value (json_str_input);
    json_obj    := json_object_t(json_str_input);
    obj_row     := json_object_t();

    p_dteyreff  := to_number(hcm_util.get_string_t(json_obj,'p_dteyreff'));
    p_codcompy  := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_typincom  := hcm_util.get_string_t(json_obj,'p_typincom');

    p_dteyreffQuery := to_number(hcm_util.get_string_t(json_obj,'p_dteyreffQuery'));
    p_codcompyQuery := hcm_util.get_string_t(json_obj,'p_codcompyQuery');
    p_typincomQuery := hcm_util.get_string_t(json_obj,'p_typincomQuery');

    isCopy := nvl(hcm_util.get_string_t(json_obj,'isCopy'),'N');
--    check_index;
    if param_msg_error is null then
      if p_dteyreff < to_char(sysdate, 'yyyy') then
        isEdit  := false;
        isAdd   := false;
        --<<User37 #5443 Final Test Phase 1 V11 05/03/2021
        v_warning  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
        begin
            select count(*)
            into v_count_found
            from ttaxinf
            where dteyreff <= p_dteyreff
              and codcompy = p_codcompy
              and typincom = p_typincom
            order by numseq;
        end;
        if v_count_found = 0 then
            v_warning  := '';
            isEdit  := true;
            isAdd   := true;
        end if;
        -->>User37 #5443 Final Test Phase 1 V11 05/03/2021
      end if;
      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('isEdit', isEdit);
      obj_data.put('isAdd', isAdd);
      obj_data.put('isCopy',isCopy);
      obj_data.put('warning', v_warning);--User37 #5443 Final Test Phase 1 V11 05/03/2021

      begin
        select count(*)
        into v_count_found
        from ttaxinf
        where dteyreff = p_dteyreff
          and codcompy = p_codcompy
          and typincom = p_typincom
        order by numseq;
      end;
      v_other_year := p_dteyreff;
      if v_count_found = 0 then
        begin
          select max(dteyreff)
          into v_other_year
          from ttaxinf
          where dteyreff < p_dteyreff
            and codcompy = p_codcompy
            and typincom = p_typincom
          order by dteyreff desc;
        exception when others then
          v_other_year := null;
        end;
      end if;
      begin
          select coduser, max(dteupd)
            into v_coduser, v_dteupd
            from ttaxinf
           where dteyreff = v_other_year
             and codcompy = p_codcompy
             and typincom = p_typincom
             and rownum = 1
        group by coduser,dteupd;
      exception when no_data_found then
        v_coduser := null;
        v_dteupd  := null;
      end;
      obj_data.put('editby', get_codempid(v_coduser));
      obj_data.put('coduser', v_coduser);
      obj_data.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;
  --
  procedure get_copy_detail(json_str_input in clob,json_str_output out clob) as
      json_obj            json_object_t;
      obj_data            json_object_t;
      obj_row             json_object_t;
      p_dteyreff          number(4,0);
      p_codcompy          varchar2(4 char);
      p_typincom          varchar2(2 char);
      p_dteyreffQuery     number(4,0);
      p_codcompyQuery     varchar2(4 char);
      p_typincomQuery     varchar2(2 char);
      v_row               number := 0;
      v_count_found       number := 0;
      v_count_not_found   number := 0;
      v_ttaxinf_rec       ttaxinf%rowtype;
      v_other_year        number := null;

      cursor c1 is
        select *
          from ttaxinf
         where dteyreff = p_dteyreffQuery
           and codcompy = p_codcompyQuery
           and typincom = p_typincomQuery
         order by numseq;

      cursor c2 is
          select *
            from ttaxinf
           where dteyreff = v_other_year
             and codcompy = p_codcompyQuery
             and typincom = p_typincomQuery
           order by numseq;
  begin
      initial_value(json_str_input);
      json_obj    := json_object_t(json_str_input);
      obj_row     := json_object_t();
      p_dteyreff  := to_number(hcm_util.get_string_t(json_obj,'p_dteyreff'));
      p_codcompy  := hcm_util.get_string_t(json_obj,'p_codcompy');
      p_typincom  := hcm_util.get_string_t(json_obj,'p_typincom');
      p_dteyreffQuery  := to_number(hcm_util.get_string_t(json_obj,'p_dteyreffQuery'));
      p_codcompyQuery  := hcm_util.get_string_t(json_obj,'p_codcompyQuery');
      p_typincomQuery  := hcm_util.get_string_t(json_obj,'p_typincomQuery');

      check_get_index(p_codcompy);
      if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
      end if;

      begin
        select count(*)
          into v_count_found
          from ttaxinf
         where dteyreff = p_dteyreffQuery
           and codcompy = p_codcompyQuery
           and typincom = p_typincomQuery
         order by numseq;
      exception when others then
        v_count_found := 0;
      end;

      if v_count_found > 0 then
        -- set obj
        for i in c1 loop
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codcompy',p_codcompy);
          obj_data.put('dteyreff',p_dteyreff);
          obj_data.put('typincom',p_typincom);
          obj_data.put('numseq',i.numseq);
          obj_data.put('amtsalst',to_char(i.amtsalst));
          obj_data.put('amtsalen',to_char(i.amtsalen));
          obj_data.put('pcttax',to_char(i.pcttax));
          obj_data.put('amttaxacc',to_char(i.amttaxacc));
          obj_data.put('amtacccal',i.amtacccal);
          obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
          obj_data.put('coduser',i.codcompy);
          obj_data.put('codempid',get_codempid(i.coduser));
          obj_data.put('namedit',get_temploy_name(get_codempid(i.coduser),global_v_lang));
          obj_data.put('flgAdd',true);
          obj_row.put(to_char(v_row-1),obj_data);
        end loop;
      else
        begin
          select count(*)
            into v_count_not_found
            from ttaxinf
           where dteyreff < p_dteyreffQuery
             and codcompy = p_codcompyQuery
             and typincom = p_typincomQuery
           order by numseq;
        exception when others then
          v_count_not_found := 0;
        end;
          if v_count_not_found > 0 then
            -- get year
            begin
              select max(dteyreff)
                into v_other_year
                from ttaxinf
               where dteyreff < p_dteyreffQuery
                 and codcompy = p_codcompyQuery
                 and typincom = p_typincomQuery
               order by dteyreff desc;
            exception when others then
              null;
            end;
            -- set obj
            for i in c2 loop
              v_row := v_row + 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('codcompy',p_codcompy);
              obj_data.put('dteyreff',p_dteyreff);
              obj_data.put('typincom',p_typincom);
              obj_data.put('numseq',i.numseq);
              obj_data.put('amtsalst',to_char(i.amtsalst));
              obj_data.put('amtsalen',to_char(i.amtsalen));
              obj_data.put('pcttax',to_char(i.pcttax));
              obj_data.put('amttaxacc',to_char(i.amttaxacc));
              obj_data.put('amtacccal',i.amtacccal);
              obj_data.put('flgAdd',true);
              obj_row.put(to_char(v_row-1),obj_data);
            end loop;
          end if;
      end if;
      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_copy_detail;

end HRPY11E;

/

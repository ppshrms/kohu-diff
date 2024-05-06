--------------------------------------------------------
--  DDL for Package Body HREL32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL32E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_codcatexm         := hcm_util.get_string_t(json_obj,'p_codcatexm');
    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
        select count(*) into v_count_comp
          from tcenter
         where codcomp like p_codcomp || '%' ;
      exception when others then null;
      end;
      if v_count_comp < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end if;
      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codcours is null and p_codcatexm is null and p_codexam is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codcours is not null then
      begin
        select count(*) into v_chkExist
          from tcourse
         where codcours = p_codcours;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
        return;
      end if;
    end if;
-- #4591 || 20/07/2022    
    if p_codcatexm is not null then
      begin
        select count(*) into v_chkExist
          from tvtest a, tvquest b 
         where a.codexam = b.codexam 
           and a.codcatexm = p_codcatexm
           and b.typeexam = 4;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('EL0060',global_v_lang);
        return;
      end if;
    end if;
-- #4591 || 20/07/2022  
    if p_codexam is not null then
      begin
        select count(*) into v_chkExist
          from tvquest
         where codexam = p_codexam
           and typeexam = 4 ;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('EL0060',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;

    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_codexam           ttestchk.codexam%type;
    v_codpos            ttestchk.codposc%type;
    v_codcomp           ttestchk.codcomp%type;
    v_codempid          ttestchk.codempidc%type;
    v_staemp            temploy1.staemp%type;
    v_examset           tvtest.namexame%type;
    v_flggrade          varchar2(2 char);
    v_table             varchar2(100 char);

    cursor c1 is
      select codcatexm,codexam
      from(
        select b.codcatexm,b.codexam
          from tvcourse a, tvtest b
         where b.codcatexm = nvl(a.codcatpre,b.codcatexm)
           and b.codexam   = nvl(a.codexampr,b.codexam)
           and a.codcours  = p_codcours
           and exists( select codexam 
                       from tvquest
                      where codexam  = b.codexam
                        and typeexam = '4')
      union
        select b.codcatexm,b.codexam
          from tvcourse a, tvtest b
         where b.codcatexm = nvl(a.codcatpo,b.codcatexm)
           and b.codexam   = nvl(a.codexampo,b.codexam)
           and a.codcours  = p_codcours
           and exists( select codexam 
                       from tvquest
                      where codexam  = b.codexam
                        and typeexam = '4')  
      union
        select b.codcatexm,b.codexam
          from tvsubject a, tvtest b
         where b.codcatexm = nvl(a.codcatexm,b.codcatexm)
           and b.codexam = nvl(a.codexam,b.codexam)
           and a.codcours = p_codcours
            and exists( select codexam 
                       from tvquest
                      where codexam  = b.codexam
                        and typeexam = '4')  
      union
        select b.codcatexm,b.codexam
          from tvchapter a, tvtest b
         where b.codcatexm = nvl(a.codcatexm,b.codcatexm)
           and b.codexam = nvl(a.codexam,b.codexam)
           and a.codcours = p_codcours
            and exists( select codexam 
                       from tvquest
                      where codexam  = b.codexam
                        and typeexam = '4'))
      group by codcatexm,codexam
      order by codcatexm,codexam;

    cursor c2 is
      select codcatexm,codexam
        from tvtest
       where codcatexm  = nvl(p_codcatexm,codcatexm)
         and codexam    = nvl(p_codexam,codexam)
        and exists( select codexam 
                       from tvquest
                      where codexam  = tvtest.codexam
                        and typeexam = '4')

       order by codcatexm,codexam;

    cursor c3 is
      select codcomp,codcompc, codposc, codempidc, numseq
        from ttestchk
       where codcomp = p_codcomp
         and codexam = v_codexam
       order by numseq;
  begin
    obj_row := json_object_t();

    if p_codcours is not null then
      v_table := 'TVCOURSE';
      for r1 in c1 loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcatexm', r1.codcatexm);
        obj_data.put('desc_codcate', get_tcodec_name('TCODCATEXM', r1.codcatexm, global_v_lang));
        obj_data.put('codexam', r1.codexam);

        begin 
          select decode(global_v_lang,'101',namexame,
                                  '102',namexam2,
                                  '103',namexam3,
                                  '104',namexam4,
                                  '105',namexam5) as namexam
         into v_examset
         from tvtest
         where codexam = r1.codexam;
        exception when no_data_found then
          v_examset := null;
        end;

        obj_data.put('examset', v_examset);

        obj_row_child := json_object_t();
        v_codexam := r1.codexam;
        v_row_child := 0;
        for r3 in c3 loop
          obj_data_child := json_object_t();
          obj_data_child.put('codcomp', nvl(r3.codcompc,''));
          obj_data_child.put('codpos', nvl(r3.codposc,''));
          obj_data_child.put('codreview', nvl(r3.codempidc,''));
          obj_data_child.put('numseq', nvl(r3.numseq,''));

          obj_row_child.put(to_char(v_row_child), obj_data_child);
          v_row_child := v_row_child + 1;
        end loop;
        if v_row_child = 0 then
          obj_data_child := json_object_t();
          obj_data_child.put('codcomp', '');
          obj_data_child.put('codpos', '');
          obj_data_child.put('codreview', '');
          obj_data_child.put('numseq', '');
          obj_row_child.put(to_char(0), obj_data_child);
        end if;
        obj_data.put('children', obj_row_child);
        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
      end loop;
    else
      v_table := 'TVTEST';
      for r2 in c2 loop
/*-- #4588 || 11/05/2022
        begin 
          select decode(global_v_lang,'101',namexame,
                                  '102',namexam2,
                                  '103',namexam3,
                                  '104',namexam4,
                                  '105',namexam5) as namexam
         into v_examset
         from tvtest
         where codexam = r2.codexam;
        exception when no_data_found then
          v_examset := null;
        end;
*/ -- #4588 || 11/05/2022
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcatexm', r2.codcatexm);
        obj_data.put('desc_codcate', get_tcodec_name('TCODCATEXM', r2.codcatexm, global_v_lang));
        obj_data.put('codexam', r2.codexam);
        obj_data.put('examset', get_tvtest_name(r2.codexam,global_v_lang)); -- #4588 || 11/05/2022
        --obj_data.put('examset', v_examset); -- #4588 || 11/05/2022

        obj_row_child := json_object_t();
        v_codexam := r2.codexam;
        v_row_child := 0;
        for r3 in c3 loop
          obj_data_child := json_object_t();
          obj_data_child.put('codcomp', nvl(r3.codcompc,''));
          obj_data_child.put('codpos', nvl(r3.codposc,''));
          obj_data_child.put('codreview', nvl(r3.codempidc,''));
          obj_data_child.put('numseq', nvl(r3.numseq,''));
          obj_row_child.put(to_char(v_row_child), obj_data_child);
          v_row_child := v_row_child + 1;
        end loop;

        if v_row_child = 0 then
          obj_data_child := json_object_t();
          obj_data_child.put('codcomp', '');
          obj_data_child.put('codpos', '');
          obj_data_child.put('codreview', '');
          obj_data_child.put('numseq', '');
          obj_row_child.put(to_char(0), obj_data_child);
        end if;
        obj_data.put('children', obj_row_child);

        obj_row.put(to_char(v_row), obj_data);
        v_row := v_row + 1;
      end loop;
    end if;
    if v_row = 0 then
--      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
      param_msg_error := get_error_msg_php('EL0062', global_v_lang);
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index();
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --> Peerasak || Issue#9295 || 05042023
  procedure check_save(v_codempid in ttestchk.codempidc%type, v_codcomp in ttestchk.codcomp%type, v_codpos in ttestchk.codposc%type) is
    v_count_comp        number := 0;
    v_count_tpostn      number := 0;
    v_codcompy          VARCHAR2(4 CHAR);
    v_diff_v_codcompy   VARCHAR2(4 CHAR);
    v_secur2            boolean := false;
    v_secur7            boolean := false;
    v_employ_chk        number := 0;
    iv_codempid         temploy1.codempid%type;
    iv_staemp           temploy1.staemp%type;
    v_check_codcomp_in_codcomp          VARCHAR2(4 CHAR);

  begin  
    -- ## 1 codreview
    if v_codempid is not null then
      -- ### 1.1 no_data_found temploy1
      begin
        select codempid, staemp into iv_codempid, iv_staemp
        from temploy1
        where codempid = v_codempid
        and rownum = 1;
      exception when others then null;    
      end;

      if v_count_comp < 1 then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
          return;
      end if;

      -- ### 1.2 secur_main.secur2;
      v_secur2   := secur_main.secur2(v_codcompy,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_secur2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;

      -- ### 1.3 staemp = 9
      if iv_staemp = 9 then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang,'TCENTER');
        return;
      end if;

      -- ### 1.4 staemp = 0
      if iv_staemp = 0 then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang,'TCENTER');
        return;
      end if;

      -- ### 1.5 select codempid where codempid and codcomp like p_codcomp || '%'
       begin
        select 'Y'
          into v_check_codcomp_in_codcomp
          from tcenter
         where codcomp = v_codcompy
           and codcomp like p_codcomp || '%';
      exception when no_data_found then  
        param_msg_error := get_error_msg_php('HR7524',global_v_lang,'TCENTER');
        return;
      end;
    end if;

    -- ## 2 codcomp    
    if v_codcomp is not null then
      -- ### 2.1  
      begin
        select count(*) into v_count_comp
          from tcenter
         where codcomp like v_codcomp || '%';
      exception when others then null;
      end;

      if v_count_comp < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end if;

      -- ### 2.2 
      v_secur7 := secur_main.secur7(v_codcomp, global_v_coduser);
      if not v_secur7 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;

       -- ### 2.3 
        begin
          select hcm_util.get_codcompy(p_codcomp), hcm_util.get_codcompy(v_codcomp) 
          into v_codcompy, v_diff_v_codcompy
          from dual;
        exception when others then null;
        end;    

        if v_codcompy <> v_diff_v_codcompy then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCOMPNY');
          return;
        end if;

        -- ### 2.4        
        begin
          select 'A' into v_check_codcomp_in_codcomp
            from dual
           where v_codcomp like p_codcomp || '%' ;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR7524', global_v_lang, 'TCOMPNY');
          return;
        end;
    end if;

    -- ## 3 codpos
    if v_codpos is not null then
      -- ### 3.1     
      begin
        select count(*) into v_count_tpostn
          from tpostn
         where codpos like v_codpos || '%';
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TPOSTN');
        return;
      end;
    end if;    
  end check_save;
  --> Peerasak || Issue#9295 || 05042023
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) as
    param_json_row        json_object_t;
    param_json            json_object_t;
    param_json_child      json_object_t;
    param_json_row_child  json_object_t;

    type array_t is table of varchar2(4000) index by binary_integer;
    v_arr_item            array_t;

    v_flg                 varchar2(100 char);
    v_numseq              varchar2(100 char);
    v_codexam             ttestchk.codexam%type;
    v_codpos              ttestchk.codposc%type;
    v_codcomp             ttestchk.codcomp%type;
    v_codempid            ttestchk.codempidc%type;

  begin
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codexam       := hcm_util.get_string_t(param_json_row,'codexam');

        param_json_child  := hcm_util.get_json_t(param_json_row,'children');
        for j in 0..param_json_child.get_size-1 loop
          param_json_row_child  := hcm_util.get_json_t(param_json_child,to_char(j));

          v_numseq    := hcm_util.get_string_t(param_json_row_child,'numseq');
          v_codempid  := hcm_util.get_string_t(param_json_row_child,'codreview');
          v_codcomp   := hcm_util.get_string_t(param_json_row_child,'codcomp');
          v_codpos    := hcm_util.get_string_t(param_json_row_child,'codpos');
          v_flg       := hcm_util.get_string_t(param_json_row_child,'flg');


          if v_numseq is null then
            begin
              select nvl(max(numseq),0) + 1 into v_numseq
                from ttestchk
               where codcomp = p_codcomp
                 and codexam = v_codexam;
            end;
          end if;

          if v_flg = 'add' or v_flg = 'edit' then
            check_save(v_codempid, v_codcomp, v_codpos);  --> Peerasak || Issue#9295 || 05042023

            if param_msg_error is not null then            
              json_str_output := get_response_message(400,param_msg_error,global_v_lang);
              return;
            end if;

            begin
              insert into ttestchk(codcomp,codexam,numseq,codempidc,codcompc,codposc,codcreate,coduser)
              values(p_codcomp, v_codexam, v_numseq, v_codempid, get_compful(v_codcomp), v_codpos, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              update ttestchk
                 set codempidc = v_codempid,
                     codcompc = get_compful(v_codcomp),
                     codposc = v_codpos,
                     coduser = global_v_coduser
               where codcomp = p_codcomp
                 and codexam = v_codexam
                 and numseq = v_numseq;
            end;
          else
            begin
              delete ttestchk
               where codcomp = p_codcomp
                 and codexam = v_codexam
                 and numseq = v_numseq;
            end;
          end if;
        end loop;
      end loop;
    end if;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    rollback;
  end save_index;
  --
  procedure post_save_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_index(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrel32e;

/

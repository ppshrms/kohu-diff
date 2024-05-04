--------------------------------------------------------
--  DDL for Package Body HRRP2GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2GX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_compgrp     := hcm_util.get_string_t(json_obj,'p_compgrp');
    b_index_group       := hcm_util.get_string_t(json_obj,'p_group');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
--      gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;
    v_cntemp        number := 0;

    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP2GX';
    v_numseq    ttemprpt.numseq%type := 1;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;

    v_emp       number:= 0;--User37 #7505 1. RP Module 19/01/2022 

--    v_flgdata   varchar2(1 char) := 'N';
--    v_cntemp    number;
--    v_flgsecur  varchar2(1 char) := 'N';

    cursor c_codcompy is
      select codcompy
        from tcompny a
       where compgrp = b_index_compgrp
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp||'%' like a.codcompy||'%')
      order by codcompy;

    cursor c1 is
      select distinct jobgrade datarow,get_tcodec_name('tcodjobg',jobgrade,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'JOBGRADE'
        and   jobgrade is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct codgrpos datarow,codgrpos||'-'||get_tcodec_name('tcodgpos',codgrpos,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'CODGRPOS'
        and   codgrpos is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct codbrlc datarow,get_tcodec_name('tcodloca',codbrlc,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'CODBRLC'
        and   codbrlc is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct genage datarow,get_tcodec_name('tcodgenrt',genage,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'GENAGE'
        and   genage is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        order by 2;

  begin

    for i in c_codcompy loop
        v_flgsecur := 'Y';
        exit;
    end loop;
    if v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    begin
      delete from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
      commit;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;
    --
    obj_row := json_object_t();
    for r1 in c1 loop
        v_flgdata := 'Y';
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('generation', r1.desc_datarow);
        v_col := 0;
        for i in c_codcompy loop
            v_col := v_col + 1;
            begin
                select count(*) into v_cntemp
                from   v_hrrp2gx
                where  codcompy = i.codcompy
                and    staemp in ('1','3')
                and    nvl(decode(b_index_group
                            ,'JOBGRADE',jobgrade
                            ,'CODGRPOS',codgrpos
                            ,'CODBRLC',codbrlc
                            ,'GENAGE',genage
                            )
                        ,'') = r1.datarow;
            end;
            obj_data.put('company'||to_char(v_col), v_cntemp);
             ----------Axis X level 2(from data column)
            v_item7  := i.codcompy;
            v_item8  := get_tcompny_name(i.codcompy,global_v_lang);
            v_item6  := '';
            ----------Axis X level 1(from data row)
            v_item4  := r1.datarow;
            v_item5  := r1.desc_datarow;
            ----------Axis Y Label
            v_item9  := get_label_name('HRRP2GXC2', global_v_lang, '20'); --จำนวนพนักงาน
            ----------Data in table
            v_item10 := v_cntemp;

            ----------Insert ttemprpt
            begin
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq := v_numseq + 1;
        end loop;

        obj_row.put(to_char(v_rcnt-1),obj_data);
      --end if;
    end loop;

    --Summary Data--
    v_rcnt := v_rcnt + 1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('generation', get_label_name('HRRP2GX', global_v_lang, '30'));
    v_col := 0;
    for i in c_codcompy loop
        v_col := v_col + 1;
        begin
            select count(*) into v_cntemp
            from   v_hrrp2gx
            where  codcompy = i.codcompy
            and    staemp in ('1','3');
        end;
        --<<User37 #7505 1. RP Module 19/01/2022 
        v_emp := 0;
        begin
          select count(*) into v_cntemp
            from v_hrrp2gx
           where b_index_group = 'JOBGRADE'
             and jobgrade is not null
             and codcompy = i.codcompy
             and staemp in ('1','3')
             and codcompy in(select codcompy
                                from tcompny a
                               where compgrp = b_index_compgrp
                                 and exists (select codcomp
                                               from tusrcom x
                                              where x.coduser = global_v_coduser
                                                and x.codcomp||'%' like a.codcompy||'%'));
        exception when no_data_found then
          null;
        end;
        v_emp := nvl(v_emp,0)+nvl(v_cntemp,0);
        begin
          select count(*) into v_cntemp
            from v_hrrp2gx
           where b_index_group = 'CODGRPOS'
             and codgrpos is not null
             and codcompy = i.codcompy
             and staemp in ('1','3')
             and codcompy in(select codcompy
                                from tcompny a
                               where compgrp = b_index_compgrp
                                 and exists (select codcomp
                                               from tusrcom x
                                              where x.coduser = global_v_coduser
                                                and x.codcomp||'%' like a.codcompy||'%'));
        exception when no_data_found then
          null;
        end;
        v_emp := nvl(v_emp,0)+nvl(v_cntemp,0);
        begin
          select count(*) into v_cntemp
            from v_hrrp2gx
           where b_index_group = 'CODBRLC'
             and codbrlc is not null
             and codcompy = i.codcompy
             and staemp in ('1','3')
             and codcompy in(select codcompy
                                from tcompny a
                               where compgrp = b_index_compgrp
                                 and exists (select codcomp
                                               from tusrcom x
                                              where x.coduser = global_v_coduser
                                                and x.codcomp||'%' like a.codcompy||'%'));
        exception when no_data_found then
          null;
        end;
        v_emp := nvl(v_emp,0)+nvl(v_cntemp,0);
        begin
          select count(*) into v_cntemp
            from v_hrrp2gx
           where b_index_group = 'GENAGE'
             and genage is not null
             and codcompy = i.codcompy
             and staemp in ('1','3')
             and codcompy in(select codcompy
                                from tcompny a
                               where compgrp = b_index_compgrp
                                 and exists (select codcomp
                                               from tusrcom x
                                              where x.coduser = global_v_coduser
                                                and x.codcomp||'%' like a.codcompy||'%'));
        exception when no_data_found then
          null;
        end;
        v_emp := nvl(v_emp,0)+nvl(v_cntemp,0);
        obj_data.put('company'||to_char(v_col), v_emp);
        --obj_data.put('company'||to_char(v_col), v_cntemp);
        -->>User37 #7505 1. RP Module 19/01/2022 
    end loop;

    obj_row.put(to_char(v_rcnt-1),obj_data);


    if v_flgdata = 'Y' then
      commit;
      obj_data2 := json_object_t();
      obj_data2.put('coderror','200');
      obj_data2.put('rows',obj_row);
      json_str_output := obj_data2.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TEMPLOY1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  procedure get_index_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_detail;

  procedure gen_index_detail(json_str_output out clob) as
    obj_result      json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;
    v_cntemp        number := 0;
    v_desc          varchar2(200);

    cursor c_codcompy is
      select codcompy
        from tcompny a
       where compgrp = b_index_compgrp
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp||'%' like a.codcompy||'%')
      order by codcompy;

  begin
    for i in c_codcompy loop
        v_flgsecur := 'Y';
        exit;
    end loop;
    if v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    --
    obj_result := json_object_t();
    obj_data := json_object_t();
    begin
      select decode(global_v_lang,'101',nambrowe,
                                 '102',nambrowt,
                                 '103',nambrow3,
                                 '104',nambrow4,
                                 '105',nambrow5,null) into v_desc
       from treport2
      where codapp = 'HRRP2GX'
        and namfld = b_index_group
        and rownum = 1;
    exception when no_data_found then
      v_desc := null;
    end;

    for i in c_codcompy loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt + 1;
      obj_data.put('company'||v_rcnt, get_tcompny_name(i.codcompy,global_v_lang));
    end loop;
    obj_result.put('coderror','200');
    obj_result.put('desc_group', v_desc);
    obj_result.put('companyAll',obj_data);

    if v_flgdata = 'Y' then
      json_str_output := obj_result.to_clob;
    else
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP2GX';
    v_numseq    ttemprpt.numseq%type := 1;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;

    v_flgdata   varchar2(1 char) := 'N';
    v_cntemp    number;
    v_flgsecur  varchar2(1 char) := 'N';

    cursor c_codcompy is
      select codcompy
        from tcompny a
       where compgrp = b_index_compgrp
         and exists (select codcomp
                       from tusrcom x
                      where x.coduser = global_v_coduser
                        and x.codcomp||'%' like a.codcompy||'%')
      order by codcompy;

    cursor c1 is
      select distinct jobgrade datarow,get_tcodec_name('tcodjobg',jobgrade,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'JOBGRADE'
        and   jobgrade is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct codgrpos datarow,get_tcodec_name('tcodgpos',codgrpos,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'CODGRPOS'
        and   codgrpos is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct codbrlc datarow,get_tcodec_name('tcodloca',codbrlc,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'CODBRLC'
        and   codbrlc is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        union all
        select distinct genage datarow,get_tcodec_name('tcodgenrt',genage,global_v_lang) desc_datarow
        from  v_hrrp2gx
        where b_index_group = 'GENAGE'
        and   genage is not null
        and   codcompy in(select codcompy
                            from tcompny a
                           where compgrp = b_index_compgrp
                             and exists (select codcomp
                                           from tusrcom x
                                          where x.coduser = global_v_coduser
                                            and x.codcomp||'%' like a.codcompy||'%'))
        order by 2;

  begin
    param_msg_error := null;
    begin
      delete from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
      commit;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;

    v_item31 := get_label_name('HRRP2GXC2', global_v_lang, '10'); --Report Name

    for i in c_codcompy loop
        v_flgdata := 'Y';
        for r1 in c1 loop
            begin
                select count(*) into v_cntemp
                from   v_hrrp2gx
                where  codcompy = i.codcompy
                and    staemp in ('1','3')
                and    nvl(decode(b_index_group
                            ,'JOBGRADE',jobgrade
                            ,'CODGRPOS',codgrpos
                            ,'CODBRLC',codbrlc
                            ,'GENAGE',genage
                            )
                        ,'') = r1.datarow;
            end;
            ----------Axis X level 2(from data column)
            v_item7  := i.codcompy;
            v_item8  := get_tcompny_name(i.codcompy,global_v_lang);
            v_item6  := '';
            ----------Axis X level 1(from data row)
            v_item4  := r1.datarow;
            v_item5  := r1.desc_datarow;
            ----------Axis Y Label
            v_item9  := get_label_name('HRRP2GXC2', global_v_lang, '20'); --จำนวนพนักงาน
            ----------Data in table
            v_item10 := v_cntemp;

            ----------Insert ttemprpt
            begin
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq := v_numseq + 1;
        end loop;
    end loop;

    commit;

    for i in c_codcompy loop
        v_flgsecur := 'Y';
        exit;
    end loop;
    if v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'N' then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'v_hrrp2gx');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --

  procedure get_list_group(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_1 is
      select namfld codgroup,decode(global_v_lang,'101', nambrowe,
                                                  '102', nambrowt,
                                                  '103', nambrow3,
                                                  '104', nambrow4,
                                                  '105', nambrow5) namegroup
      from   treport2
      where  codapp = 'HRRP2GX'
    order by numseq;

  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    for r1 in c_1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('group', r1.codgroup);
      obj_data.put('namegroup', r1.namegroup);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

--    if v_rcnt = 0 then
--        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treport2');
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--     else
        json_str_output := obj_row.to_clob;
--     end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

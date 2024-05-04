--------------------------------------------------------
--  DDL for Package Body HRAPSHX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSHX" as
  procedure initial_value(json_str_input in clob) is
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');

    p_codtency          := hcm_util.get_string_t(json_obj,'p_codtency');
    p_codskill          := hcm_util.get_string_t(json_obj,'p_codskill');
    p_desc_codskill     := hcm_util.get_string_t(json_obj,'p_desc_codskill');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure check_index is
  begin
    if b_index_dteyreap is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_numtime is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
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
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_empdownstd    number := 0;
    v_gradexpct     varchar2(10 char);
    v_codskill      varchar2(10 char);
    v_desccourse    varchar2(2000 char);
    v_descdevtype   varchar2(2000 char);

    cursor c1 is
        select codtency,codskill,gradexpct
        from   tappemp a,tappcmpf b,temploy1 e
        where  a.codempid = b.codempid
        and  a.dteyreap = b.dteyreap
        and  a.numtime  = b.numtime  
        and  a.codcomp  like b_index_codcomp||'%'
        and  a.dteyreap = b_index_dteyreap
        and  a.numtime  = b_index_numtime  
        and  a.codempid = e.codempid
        and  e.numlvl   between global_v_zminlvl and global_v_zwrklvl
        and  exists (select c.coduser
                      from tusrcom c
                     where c.coduser = global_v_coduser
                       and a.codcomp like c.codcomp||'%')
    group by codtency,codskill,gradexpct
    order by codtency,codskill,gradexpct;

    cursor c_course is
        select codcours  
        from   tcomptcr 
        where  codskill = v_codskill 
        and    grade    = v_gradexpct
    group by codcours
    order by codcours;

    cursor c_devtype is
        select coddevp
        from   tcomptdev 
        where  codskill = v_codskill 
        and    grade    = v_gradexpct
    group by coddevp
    order by coddevp;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      --if true then -- check secur7
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;
        --
        v_empdownstd := 0;
        begin
            select count(a.codempid) into v_empdownstd
            from   tappemp a,tappcmpf b,temploy1 e 
            where  a.dteyreap = b.dteyreap 
            and    a.numtime  = b.numtime
            and    a.codempid = b.codempid
            and    a.codcomp  like b_index_codcomp||'%'
            and    a.dteyreap = b_index_dteyreap 
            and    a.numtime  = b_index_numtime  
            and    b.codtency = r1.codtency
            and    b.codskill = r1.codskill
            and    grade      < r1.gradexpct
            and    a.codempid = e.codempid
            and    e.numlvl   between global_v_zminlvl and global_v_zwrklvl
            and    exists (select c.coduser
                              from tusrcom c
                             where c.coduser = global_v_coduser
                               and a.codcomp like c.codcomp||'%');
        exception when no_data_found then null;
        end;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codtency', r1.codtency);
        obj_data.put('codskill', r1.codskill);
        obj_data.put('desc_codskill', get_tcodec_name('TCODSKIL',r1.codskill,global_v_lang));
        obj_data.put('gradexpct', r1.gradexpct);
        obj_data.put('qtyemp', v_empdownstd);

        v_codskill := r1.codskill;
        v_gradexpct := r1.gradexpct;
        v_desccourse := null;
        v_descdevtype := null;
        for i in c_course loop
            v_desccourse := v_desccourse||get_tcourse_name(i.codcours,global_v_lang)||',';
        end loop;
        v_desccourse := substr(v_desccourse,1,length(v_desccourse)-1);
        obj_data.put('desc_couse', v_desccourse);
        for i in c_devtype loop
            v_descdevtype := v_descdevtype||get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang)||',';
        end loop;
        v_descdevtype := substr(v_descdevtype,1,length(v_descdevtype)-1);
        obj_data.put('desc_coddevp', v_descdevtype);

        obj_row.put(to_char(v_rcnt-1),obj_data);

      --end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure get_index_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
  begin
    obj_row := json_object_t();

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('competency', p_codskill ||' - '|| get_tcodec_name('TCODSKIL',p_codskill,global_v_lang));

    --obj_row.put(to_char(v_rcnt-1),obj_data);
    json_str_output := obj_data.to_clob;

    if isInsertReport then
      obj_data.put('item1','DETAIL');
      insert_ttemprpt(obj_data);
    end if;
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_detail(json_str_output);

    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean := false;

    v_day           number;
    v_month         number;
    v_year          number;

    cursor c1 is
      select   a.codcomp,a.codpos,gradexpct,count(a.codempid) qtyemp
        from   tappemp a,tappcmpf b,temploy1 e
        where  a.dteyreap = b.dteyreap 
        and    a.numtime  = b.numtime
        and    a.codempid = b.codempid
        and    a.codcomp  like b_index_codcomp||'%'
        and    a.dteyreap = b_index_dteyreap 
        and    a.numtime  = b_index_numtime  
        and    b.codtency = p_codtency
        and    b.codskill = p_codskill
        and    grade      < gradexpct
        and    a.codempid = e.codempid
        and    e.numlvl   between global_v_zminlvl and global_v_zwrklvl
        and    exists (select c.coduser
                          from tusrcom c
                         where c.coduser = global_v_coduser
                           and a.codcomp like c.codcomp||'%')
    group by a.codcomp,a.codpos,gradexpct
    order by a.codcomp,a.codpos,gradexpct desc;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      --if v_secur then 
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('gradexpct', r1.gradexpct);
        obj_data.put('qtyemp', r1.qtyemp);

        obj_row.put(to_char(v_rcnt-1),obj_data);

        if isInsertReport then
          obj_data.put('item1','TABLE');
          obj_data.put('item4',v_rcnt);
          insert_ttemprpt_table(obj_data);
        end if;
      --end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_report;
---
  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin  
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;   
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows       := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codtency          := hcm_util.get_string_t(p_index_rows,'codtency');
        p_codskill          := hcm_util.get_string_t(p_index_rows,'codskill');   
        gen_index_detail(json_output);
        gen_detail(json_output);
      end loop;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq      number := 0;
    v_image       tempimge.namimage%type;
    v_folder      tfolderd.folder%type;
    v_has_image   varchar2(1) := 'N'; 
    v_image2      tempimge.namimage%type;
    v_folder2     tfolderd.folder%type;
    v_has_image2  varchar2(1) := 'N'; 
    v_codreview   temploy1.codempid%type := ''; 

    v_codempid    varchar2(100 char) := '';
    v_codcomp     temploy1.codcomp%type;
    v_codpos      temploy1.codpos%type;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;
    v_item11      ttemprpt.item11%type;
    v_item12      ttemprpt.item12%type;
    v_item13      ttemprpt.item13%type;
    v_item14      ttemprpt.item14%type;
    v_item15      ttemprpt.item15%type;

  begin    
    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := p_codtency; --nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_item3       := p_codskill; --nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'competency'), '');    

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid 
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
/*
     begin
      select get_tfolderd('HRPMC2E1')||'/'||namimage
        into v_image
        from tempimge
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_image := null;
    end;

    if v_image is not null then
      v_image     := get_tsetup_value('PATHWORKPHP')||v_image;
      v_has_image := 'Y';
    end if;

    begin
      select get_tfolderd('HRPMC2E1')||'/'||namimage
        into v_image2
        from tempimge
       where codempid = v_codreview;
    exception when no_data_found then
      v_image2 := null;
    end;

    if v_image2 is not null then
      v_image2     := get_tsetup_value('PATHWORKPHP')||v_image2;
      v_has_image2 := 'Y';
    end if;
*/
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, 
             item1, item2, item3, item4
           )
      values
           ( global_v_codempid, p_codapp, v_numseq, 
             v_item1, v_item2, v_item3, v_item4
      );
    exception when others then
      null;
    end;
  end;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq      number := 0;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;
  begin
    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := p_codtency; --nvl(hcm_util.get_string_t(obj_data, 'item2'), '');
    v_item3       := p_codskill; --nvl(hcm_util.get_string_t(obj_data, 'item3'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'item4'), '');
    v_item5       := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomp'), '');
    v_item6       := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), '');
    v_item7       := nvl(hcm_util.get_string_t(obj_data, 'gradexpct'), '');
    v_item8       := nvl(hcm_util.get_string_t(obj_data, 'qtyemp'), '');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, 
             item1, item2, item3, item4, item5, 
             item6, item7, item8
           )
      values
           ( global_v_codempid, p_codapp, v_numseq, 
             v_item1, v_item2, v_item3, v_item4, v_item5,
             v_item6, v_item7, v_item8
      );
    exception when others then
      null;
    end;
  end;

end;

/

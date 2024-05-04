--------------------------------------------------------
--  DDL for Package Body HRTR23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR23E" AS

  procedure initial_value(json_str_input in clob) as
     json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query  := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteyear         := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos          := hcm_util.get_string_t(json_obj,'p_codpos');

    param_detail      := hcm_util.get_json_t(json_obj,'param_detail');
    param_tiddplans   := hcm_util.get_json_t(json_obj,'param_tiddplans');
    param_tidpcptc    := hcm_util.get_json_t(json_obj,'param_tidpcptc');
    param_tidpcptcd   := hcm_util.get_json_t(json_obj,'param_tidpcptcd');

    param_flgwarn     := hcm_util.get_string_t(json_obj,'p_flgwarning');--nut
    p_codapp          := 'HRTR23E';
  end initial_value;

  procedure check_index as
      v_temp  varchar2(1 char);
      v_temp2 varchar2(1 char);
  begin
   begin
    select 'X' into v_temp
    from temploy1
    where codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
     end;

   begin
    select 'X' into v_temp2
    from temploy1
    where staemp <> 9
      and codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
    end;

  end check_index;

  procedure check_param as
    v_temp  varchar2(1 char);
    v_temp2 varchar2(1 char);
  begin
    if p_desdevp is null and p_codempid_query is null and  p_dteappr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if p_commtemp is not null then
        if p_commtemp is null and p_dteconf is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end if;

    if p_commtemph is not null then
        if p_commtemph is null and p_dteconf is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    end if;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;

    if p_codappr is not null then
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codappr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;

        begin
            select 'X' into v_temp2
            from temploy1
            where staemp <> 9
              and codempid = p_codappr;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        end;

        if p_dteappr < p_dteconf then
            param_msg_error := get_error_msg_php('TR0051',global_v_lang);
            return;
        end if;

        if p_dteappr < p_dteconfh then
            param_msg_error := get_error_msg_php('TR0051',global_v_lang);
            return;
        end if;
    end if;   -- if p_codappr is not null then
  end check_param;


  procedure update_tidpplan as
  begin
    update tidpplan
    set stadevp = p_stadevp,
        commtemp = p_commtemp,
        commtemph = p_commtemph,
        commtfoll = p_commtfoll,
        dteconf = p_dteconf,
        dteconfh = p_dteconfh,
        dteappr = p_dteappr,
        codappr = p_codappr,
        coduser = global_v_coduser,
        dteinput = trunc(sysdate)
    where dteyear = p_dteyear
      and codempid = p_codempid_query;
  end update_tidpplan;

  procedure insert_tidpplan as
  begin
    begin
        insert into tidpplan (dteyear,codempid,codcomp,codpos,stadevp,
                              commtemp,commtemph,commtfoll,dteconf,dteconfh,dteappr,
                              codappr,dteinput,dtecreate,codcreate,dteupd,coduser)
        values (p_dteyear,p_codempid_query,p_codcomp,p_codpos,p_stadevp,
                p_commtemp,p_commtemph,p_commtfoll,p_dteconf,p_dteconfh,p_dteappr,
                p_codappr,trunc(sysdate),sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update_tidpplan;
    end;
  end insert_tidpplan;

  procedure delete_tidpplan as
  begin
    delete from tidpplan
    where dteyear = p_dteyear
      and codempid = p_codempid_query;
  end delete_tidpplan;

  procedure delete_tidpplans as
  begin
    delete from tidpplans
    where dteyear = p_dteyear
      and codempid = p_codempid_query
      and codcours = p_codcours;
  end delete_tidpplans;

  procedure insert_tiddplans as
  data_obj          json_object_t;
  v_dtestr          tidpplans.dtestr%type;
  v_dteend          tidpplans.dteend%type;
  v_flgDelete       boolean;
  v_count           number:=0;
  v_codcomp         temploy1.codcomp%type;
  begin
    for i in 0..param_tiddplans.get_size-1 loop
        data_obj        := hcm_util.get_json_t(param_tiddplans,to_char(i));
        p_codcours      := hcm_util.get_string_t(data_obj,'codcours');
        p_codcate       := hcm_util.get_string_t(data_obj,'codcat');
        p_typfrom       := hcm_util.get_string_t(data_obj,'typfrom');
        v_dtestr        := to_date(hcm_util.get_string_t(data_obj,'dtestr'),'dd/mm/yyyy');
        v_dteend        := to_date(hcm_util.get_string_t(data_obj,'dteend'),'dd/mm/yyyy');
        p_dtetrst       := to_date(hcm_util.get_string_t(data_obj,'dtetrst'),'dd/mm/yyyy');
        p_dtetren       := to_date(hcm_util.get_string_t(data_obj,'dtetren'),'dd/mm/yyyy');
        v_flgDelete     := hcm_util.get_boolean_t(data_obj,'flgDelete');

        if not v_flgDelete then
            begin --14/05/2021
                insert into tidpplans (dteyear,codempid,codcours,codcate,typfrom,dtestr,dteend,dtetrst,dtetren,dtecreate,codcreate,dteupd,coduser)
                values (p_dteyear,p_codempid_query,p_codcours,p_codcate,p_typfrom,v_dtestr,v_dteend,p_dtetrst,p_dtetren,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tidpplans
                   set codcate = p_codcate,
                       typfrom = p_typfrom,
                       dtestr = v_dtestr,
                       dteend = v_dteend,
                       dtetrst = p_dtetrst,
                       dtetren = p_dtetren,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where dteyear = p_dteyear
                   and codempid = p_codempid_query
                   and codcours = p_codcours;
            end;
        else
            begin
                select codcomp into v_codcomp
                from temploy1
                where codempid = p_codempid_query;
            exception when no_data_found then
                v_codcomp := '';
            end;

            select count(dteyear) into v_count
            from ttpotent
            where dteyear = p_dteyear
              and v_codcomp like codcompy||'%'
              and codempid = p_codempid_query
              and codcours = p_codcours;

              if v_count = 0 then
                delete_tidpplans;
              end if;
        end if;
    end loop;

  end insert_tiddplans;

  procedure delete_tidpcptc as
  begin
    delete from tidpcptc
    where dteyear = p_dteyear
      and codempid = p_codempid_query
      and codskill = p_competency_code;
  end delete_tidpcptc;

  procedure insert_tidpcptc as
    data_obj    json_object_t;
    v_flgDelete boolean;
  begin
    for i in 0..param_tidpcptc.get_size-1 loop
        data_obj := hcm_util.get_json_t(param_tidpcptc,to_char(i));
        p_competency_code     := hcm_util.get_string_t(data_obj,'codtency');
        p_competency_type     := hcm_util.get_string_t(data_obj,'typtency');
        p_grade               := hcm_util.get_string_t(data_obj,'exptlvl');
        p_grdemp              := hcm_util.get_string_t(data_obj,'level');
        v_flgDelete           := hcm_util.get_boolean_t(data_obj,'flgDelete');

        if not v_flgDelete then
            begin
                insert into tidpcptc (dteyear,codempid,codskill,
                                      codtency,grade,grdemp,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_dteyear,p_codempid_query,p_competency_code,
                        p_competency_type,p_grade,p_grdemp,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tidpcptc
                   set codtency = p_competency_type,
                       grade = p_grade,
                       grdemp = p_grdemp
                 where dteyear = p_dteyear
                   and codempid = p_codempid_query
                   and codskill = p_competency_code;
            end;
        else
            delete_tidpcptc;
        end if;
    end loop;
  end insert_tidpcptc;



   procedure clear_ttemprpt is
    begin
        begin
            delete
            from  ttemprpt
            where codempid = global_v_codempid
            and   codapp   = p_codapp;
        exception when others then
    null;
    end;
    end clear_ttemprpt;


  procedure delete_tidpcptcd as
  begin
    delete from tidpcptcd
    where dteyear = p_dteyear
      and codempid = p_codempid_query
      and coddevp = p_coddevp;
  end delete_tidpcptcd;

  procedure update_tidpcptcd as
  begin
    update tidpcptcd
    set dtestr = p_dtestr,
        dteend = p_dteend,
        dteupd = sysdate,
        coduser = global_v_coduser
    where dteyear = p_dteyear
      and codempid = p_codempid_query
      and coddevp = p_coddevp;
  end update_tidpcptcd;

  procedure insert_tidpcptcd as
   data_obj  json_object_t;
   v_flgDelete  boolean;
  begin
    for i in 0..param_tidpcptcd.get_size-1 loop
        data_obj := hcm_util.get_json_t(param_tidpcptcd,to_char(i));
        p_coddevp       := hcm_util.get_string_t(data_obj,'coddev');
        p_desdevp       := hcm_util.get_string_t(data_obj,'devplan');
        p_targetdev     := hcm_util.get_string_t(data_obj,'target');
        p_dtestr        := to_date(hcm_util.get_string_t(data_obj,'dtestrt'),'dd/mm/yyyy');
        p_dteend        := to_date(hcm_util.get_string_t(data_obj,'dteend'),'dd/mm/yyyy');
        p_desresults    := hcm_util.get_string_t(data_obj,'result');
        v_flgDelete     := hcm_util.get_boolean_t(data_obj,'flgDelete');

        if not v_flgDelete then
            begin
                insert into tidpcptcd (dteyear,codempid,coddevp,desdevp,dtestr,dteend,targetdev,desresults,dtecreate,codcreate,dteupd,coduser)
                values (p_dteyear,p_codempid_query,p_coddevp,p_desdevp,p_dtestr,p_dteend,p_targetdev,p_desresults,sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update_tidpcptcd;
            end;
        else
            delete_tidpcptcd;
        end if;
    end loop;
  end insert_tidpcptcd;


  function find_competency(v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_grade     tcmptncy.grade%type;
    cursor c1 is
    select codtency,codskill,grade,grdemp
    from tidpcptc
    where dteyear = p_dteyear
      and codempid = p_codempid_query
    order by codtency,codskill;

    cursor c2 is
        select distinct codtency, codskill, grade --#4845 || USER39 || 01/10/2021
        from tjobposskil
        where codcomp like v_codcomp || '%'
          and codpos = v_codpos
        --group by codtency, codskill, grade
        order by codtency, codskill;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;

        obj_data := json_object_t();
        obj_data.put('typtency',i.codtency);
        obj_data.put('desc_typtency',get_tcomptnc_name(i.codtency,global_v_lang));
        obj_data.put('codtency',i.codskill);
        obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
        obj_data.put('exptlvl',i.grade);
--      obj_data.put('level',i.grdemp);
        begin
            select grade
            into v_grade
            from tcmptncy
            where codempid = p_codempid_query
              and codtency = i.codskill;
        exception when no_data_found then
            v_grade := '';
        end;

        obj_data.put('level',v_grade);
        obj_data.put('gap',v_grade - i.grade);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if v_row = 0 then
        for i in c2 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('typtency',i.codtency);
            obj_data.put('desc_typtency',i.codtency||' '||get_tcomptnc_name(i.codtency,global_v_lang));
            obj_data.put('codtency',i.codskill);
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
            obj_data.put('exptlvl',i.grade);
            begin
                select grade into v_grade
                from tcmptncy
                where codempid = p_codempid_query
                  and codtency = i.codskill;
            exception when no_data_found then
                v_grade := '';
            end;
            obj_data.put('level',v_grade);
            obj_data.put('gap',v_grade-i.grade);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;

    return obj_rows;

  end;

  function find_idp_plan(v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_codcate   tcourse.codcate%type;
    v_grade     tcmptncy.grade%type;

    cursor c1 is
        select codcours,codcate,typfrom,dtetrst,dtetren,dtestr,dteend
          from tidpplans
         where dteyear = p_dteyear
           and codempid = p_codempid_query
      order by codcours,typfrom;

    cursor c2 is 
        select a.codcours
          from tcomptcr a, tjobposskil b
         where a.codskill = b.codskill
           and b.codcomp like v_codcomp || '%'
           and a.grade between (v_grade +1) and b.grade  --#4845 || USER39 || 01/10/2564
           and b.codpos = v_codpos
      group by a.codcours
      order by a.codcours;

    cursor c3 is
        select codtency,codskill
        from tjobposskil
        where codcomp like v_codcomp || '%'
          and codpos = v_codpos
        group by codtency, codskill
        order by codtency, codskill;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('codcat',i.codcate);
        obj_data.put('desc_codcat',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
        obj_data.put('remark', get_tlistval_name('TYPFROM',i.typfrom,global_v_lang));--14/05/2021
        obj_data.put('dtetrst',nvl(to_char(i.dtetrst,'dd/mm/yyyy'),''));
        obj_data.put('dtetren',nvl(to_char(i.dtetren,'dd/mm/yyyy'),''));
        obj_data.put('dtestr',nvl(to_char(i.dtestr,'dd/mm/yyyy'),''));
        obj_data.put('dteend',nvl(to_char(i.dteend,'dd/mm/yyyy'),''));
        obj_data.put('typfrom',i.typfrom);

        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if v_row = 0 then
        for i in c3 loop
            begin
                select grade into v_grade
                from tcmptncy
                where codempid = p_codempid_query
                  and codtency = i.codskill;
            exception when no_data_found then --xx
                v_grade := '';
            end;
            for i2 in c2 loop
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('codcours',i2.codcours);
                obj_data.put('desc_codcours',get_tcourse_name(i2.codcours,global_v_lang));
                begin
                    select codcate into v_codcate
                    from tcourse
                    where codcours = i2.codcours;
                exception when no_data_found then
                    v_codcate := '';
                end;
                obj_data.put('codcat',v_codcate);
                obj_data.put('desc_codcat',get_tcodec_name('TCODCATE',v_codcate,global_v_lang));
                obj_data.put('remark','');
                obj_data.put('dtestrt','');
                obj_data.put('dteend','');
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end loop;
    end if;

    return obj_rows;

  end;

    function find_idp_cptcd(v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;

    cursor c1 is
    select coddevp,desdevp,targetdev,dtestr,desresults,dteend
    from tidpcptcd
    where dteyear = p_dteyear
      and codempid = p_codempid_query
    order by coddevp;

    cursor c2 is
        select a.coddevp, a.desdevp
        from tcomptdev a, tjobposskil b
        where a.codskill = b.codskill
          and a.grade = b.grade
          and b.codcomp like v_codcomp||'%' --#4845 || USER39 || 01/10/2021
          and b.codpos = v_codpos
        group by a.coddevp, a.desdevp
        order by a.coddevp;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();

        obj_data.put('coddev',i.coddevp);
        obj_data.put('desc_coddev',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
        obj_data.put('devplan',i.desdevp);
        obj_data.put('target',i.targetdev);
        obj_data.put('dtestrt',to_char(i.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('result',i.desresults);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if v_row = 0 then
        for i in c2 loop
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('coddev',i.coddevp);
            obj_data.put('desc_coddev',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
            obj_data.put('devplan',i.desdevp);
            obj_data.put('target','');
            obj_data.put('dtestrt','');
            obj_data.put('dteend','');
            obj_data.put('result','');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;
    return obj_rows;
  end;

  function find_idp_emp return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
    select stadevp,commtemp,dteconf,dteconfh,commtemph,codappr,dteappr,commtfoll
    from tidpplan
    where dteyear = p_dteyear
      and codempid = p_codempid_query;


  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('stadevp',i.stadevp);
        obj_data.put('commtfoll',i.commtfoll);
        obj_data.put('commtemp',i.commtemp);
        obj_data.put('dteconf',to_char(i.dteconf,'dd/mm/yyyy'));
        obj_data.put('dteconfh',to_char(i.dteconfh,'dd/mm/yyyy'));
        obj_data.put('commtemph',i.commtemph);
        obj_data.put('codappr',i.codappr);
        obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_rows;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_main            json_object_t;
    obj_detail          json_object_t;
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_row               number := 0;
    res_codcomp         temploy1.codcomp%type;
    res_codpos          temploy1.codpos%type;
    res_talent          varchar2(100 char);
    v_secur             varchar2(1 char) := 'N';
    v_chk_secur         boolean := false;
    v_tidpplan          tidpplan%rowtype;
    obj_cmpt_req        json_object_t;
    obj_course_req      json_object_t;
    obj_dev_req         json_object_t;
    v_count_tidpplan    number;
    v_flgDisabled       boolean := false ;
    v_dteappr           date;
  begin
    begin
        select codcomp, codpos
          into res_codcomp, res_codpos
          from temploy1
         where codempid = p_codempid_query;
    exception when no_data_found then
        res_codcomp := '';
        res_codpos := '';
    end;

    begin
        select 'Y' into res_talent
        from ttalente
        where codempid = p_codempid_query
        and rownum = 1;
    exception when no_data_found then
        res_talent := 'N';
    end;

    begin
        select *
          into v_tidpplan
          from tidpplan
         where codempid = p_codempid_query
           and dteyear = p_dteyear;
        v_count_tidpplan := 1;
    exception when no_data_found then
        v_tidpplan          := null;
        v_count_tidpplan    := 0;
    end;

    obj_detail := json_object_t();
    obj_detail.put('coderror', '200');
    v_chk_secur := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if v_chk_secur then
        v_secur := 'Y';
        obj_detail.put('codempid',p_codempid_query);
        obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
        obj_detail.put('codcomp',res_codcomp);
        obj_detail.put('desc_codcomp',get_tcenter_name(res_codcomp,global_v_lang));
        obj_detail.put('codpos',res_codpos);
        obj_detail.put('desc_codpos',get_tpostn_name(res_codpos,global_v_lang));
        obj_detail.put('grptaln',res_talent);
        if res_talent = 'Y' then
            obj_detail.put('desc_grptaln',get_label_name('HRTR23EC1',global_v_lang,'440'));
        else
            obj_detail.put('desc_grptaln',get_label_name('HRTR23EC1',global_v_lang,'450'));
        end if;
        obj_detail.put('resultaft',v_tidpplan.stadevp);
        obj_detail.put('commtfoll',v_tidpplan.commtfoll);
        obj_detail.put('commtemp',v_tidpplan.commtemp);
        obj_detail.put('dtecomfirme',to_char(v_tidpplan.dteconf,'dd/mm/yyyy'));
        obj_detail.put('commthead',v_tidpplan.commtemph);
        obj_detail.put('dtecomfirmh',to_char(v_tidpplan.dteconfh,'dd/mm/yyyy'));
        obj_detail.put('codappr',nvl(v_tidpplan.codappr,''));
        obj_detail.put('dteappr',to_char(nvl(v_tidpplan.dteappr,''),'dd/mm/yyyy'));

        begin
            select dteappr
              into v_dteappr
              from tidpplan
             where codempid = p_codempid_query
               and dteyear  = p_dteyear;
            v_flgDisabled := true;
          exception when no_data_found then
            v_flgDisabled := false;
        end;
        ------------
        if v_dteappr is not null then
           v_flgDisabled := true;
        else
           v_flgDisabled := false;
        end if;
        obj_detail.put('flgDisabled',v_flgDisabled);
    end if;

    obj_main      := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('detail',obj_detail);
    obj_main.put('cmpt_req',find_competency(res_codcomp, res_codpos));
    obj_main.put('course_req',find_idp_plan(res_codcomp, res_codpos));
    obj_main.put('dev_req',find_idp_cptcd(res_codcomp, res_codpos));

    if v_secur = 'Y' then
        dbms_lob.createtemporary(json_str_output, true);
        obj_main.to_clob(json_str_output);
    else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end gen_index;

  function find_competency_from_tsuccmpc_tcompskil(v_c1_codcomp VARCHAR2, v_c1_codpos VARCHAR2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_lvl_emp   tcmptncy.grade%type;
    cursor c1 is
      select b.codtency,a.grade,b.codskill
            from tsuccmpc a, tcompskil b
            where a.codtency = b.codtency
              and a.codempid = p_codempid_query
              and a.codcomp = v_c1_codcomp
              and a.codpos = v_c1_codpos
        order by b.codtency, b.codskill;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('typtency',i.codtency);
        obj_data.put('desc_typtency',get_tcomptnc_name(i.codtency,global_v_lang));
        obj_data.put('codtency',i.codskill);
        obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
        obj_data.put('exptlvl',i.grade);
        begin
            select grade
            into v_lvl_emp
            from tcmptncy
            where codempid = p_codempid_query
            and codtency = i.codskill;
        exception when no_data_found then
            v_lvl_emp := 0;
        end;
        obj_data.put('level',v_lvl_emp);
        obj_data.put('gap',v_lvl_emp - i.grade);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_course_from_tsucctrn(v_c1_codcomp VARCHAR2, v_c1_codpos VARCHAR2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_codcate   tcourse.codcate%type;
    cursor c1 is
        select codcours, dtestr, dteend, dtetrst, dtetren
            from tsucctrn
            where codempid = p_codempid_query
              and codcomp like v_c1_codcomp || '%'
              and codpos = v_c1_codpos
              and dtetren is null
        order by codcours;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        begin
            select codcate
              into v_codcate
              from tcourse
             where codcours = i.codcours;
        exception when no_data_found then
            v_codcate := null;
        end;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('codcat',v_codcate);
        obj_data.put('desc_codcat',get_tcodec_name('TCODCATE',v_codcate, global_v_lang));
        obj_data.put('remark','');
        obj_data.put('dtetrst',nvl(to_char(i.dtetrst,'dd/mm/yyyy'),''));
        obj_data.put('dtetren',nvl(to_char(i.dtetren,'dd/mm/yyyy'),''));
        obj_data.put('dtestr',nvl(to_char(i.dtestr,'dd/mm/yyyy'),''));
        obj_data.put('dteend',nvl(to_char(i.dteend,'dd/mm/yyyy'),''));
        obj_data.put('typfrom','3');
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_description_from_tsuccdev(v_c1_codcomp VARCHAR2, v_c1_codpos VARCHAR2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
        select coddevp, desdevp, destarget, dtestr, dteend, desresults
        from tsuccdev
        where codempid = p_codempid_query
          and codcomp like v_c1_codcomp || '%'
          and codpos = v_c1_codpos
          and to_char(dteend, 'yyyy') = p_dteyear
    order by coddevp;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coddev',i.coddevp);
        obj_data.put('desc_coddev',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
        obj_data.put('devplan',i.desdevp);
        obj_data.put('target',i.destarget);
        obj_data.put('dtestrt',to_char(i.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('result',i.desresults);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  procedure gen_succession_plan(json_str_output out clob) as
    obj_rows         json_object_t;
    obj_data         json_object_t;
    obj_data2        json_object_t;
    v_row            number := 0;
    v_codcomp        temploy1.codcomp%type;
    v_codpos         temploy1.codpos%type;
    cursor c1 is
        select codcomp,codpos,numseq,stasuccr,dteappr,codappr,remarkap
        from tsuccpln a
        where codempid = p_codempid_query
          and dteeffec is null
          and dteyear||lpad(numtime,2,'0') = (select max(dteyear||lpad(numtime,2,'0'))
                         from tsuccpln b
                         where b.codempid = a.codempid
                           and b.codcomp = a.codcomp
                           and b.codpos = a.codpos)
        group by codcomp, codpos, numseq, stasuccr, dteappr, codappr, remarkap
        order by codcomp,codpos;
  begin
    obj_rows := json_object_t();
--    begin
--        select codpos,codcomp into v_codpos,v_codcomp
--        from temploy1
--        where codempid = p_codempid_query;
--    exception when no_data_found then
--        v_codpos := '';
--        v_codcomp := '';
--    end;
    for i in c1 loop
        v_row := v_row+1;
        obj_data2 := json_object_t();

        obj_data2.put('codcomp',i.codcomp);
        obj_data2.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data2.put('codpos',i.codpos);
        obj_data2.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
        obj_data2.put('seqno',i.numseq);
        obj_data2.put('status',i.stasuccr);
        obj_data2.put('desc_status',get_tlistval_name('STASUCCR',i.stasuccr,global_v_lang));
        obj_data2.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
        obj_data2.put('approver',get_temploy_name(i.codappr,global_v_lang));
        obj_data2.put('remark',i.remarkap);
         obj_rows.put(to_char(v_row-1),obj_data2);
     end loop;

     if obj_rows.get_size = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSUCCPLN');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
     else
         dbms_lob.createtemporary(json_str_output, true);
         obj_rows.to_clob(json_str_output);
     end if;
  end gen_succession_plan;

  procedure gen_next_succession_plan(json_str_output out clob) as
    obj_rows         json_object_t;
    obj_data         json_object_t;
    v_row            number := 0;

  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('cmpt_req',find_competency_from_tsuccmpc_tcompskil(p_codcomp,p_codpos));
    obj_data.put('course_req',find_course_from_tsucctrn(p_codcomp,p_codpos));
    obj_data.put('dev_req',find_description_from_tsuccdev(p_codcomp,p_codpos));

     dbms_lob.createtemporary(json_str_output, true);
     obj_data.to_clob(json_str_output);
  end gen_next_succession_plan;

  function find_next_career_plan_from_tposempd return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
      select codlinef, codcomp, codpos, dteposdue, numseq
      from tposempd
      where codempid = p_codempid_query
        and dteefpos is null
      order by dteposdue, numseq;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codlinef',i.codlinef);
        obj_data.put('codlinef_name',GET_TFUNCLIN_NAME(get_codcompy(i.codcomp),i.codlinef,global_v_lang));
        obj_data.put('codcomp',i.codcomp);
        obj_data.put('codcomp_name',get_tcenter_name(i.codcomp,global_v_lang));
        obj_data.put('codpos',i.codpos);
        obj_data.put('codpos_name',get_tpostn_name(i.codpos,global_v_lang));
        if global_v_lang ='102' then
            i.dteposdue := add_months(i.dteposdue, 543*12);
        end if;
        obj_data.put('dteposdue',to_char(i.dteposdue,'dd/mm/yyyy'));
        obj_data.put('numseq',i.numseq);
        v_c2_numseq := i.numseq;
        obj_rows.put(to_char(v_row-1),obj_data);
        exit;
    end loop;
    return obj_rows;
  end;

   function find_competency_from_tposempc(v_codempid varchar2, v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_lvl_emp   tcmptncy.grade%type;

    cursor c1 is
        select codtency, codskill, grade, grdemp
          from tposempctc
        where codempid = v_codempid
          and codcomp like v_codcomp || '%'
          and codpos = v_codpos
      order by codtency,codskill;


  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();

        obj_data.put('typtency',i.codtency);
        obj_data.put('desc_typtency',get_tcomptnc_name(i.codtency,global_v_lang));
        obj_data.put('codtency',i.codskill);
        obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
        obj_data.put('exptlvl',i.grade);
        begin
            select grade
            into v_lvl_emp
            from tcmptncy
            where codempid = p_codempid_query
              and codtency = i.codskill;
        exception when no_data_found then
            v_lvl_emp := 0;
        end;
        obj_data.put('level',v_lvl_emp);
        obj_data.put('gap',v_lvl_emp - i.grade);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_course_from_tposemptr(v_codempid varchar2, v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_codcate   tcourse.codcate%type;
    cursor c1 is
        select codcours, dtestr, dteend, dtetrst, dtetren
        from tposemptr
        where codempid = v_codempid
          and codcomp like v_codcomp || '%'
          and codpos = v_codpos
          and dtetren is null
        order by codcours;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        begin
            select codcate
              into v_codcate
              from tcourse
             where codcours = i.codcours;
        exception when no_data_found then
            v_codcate := null;
        end;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('codcat',v_codcate);
        obj_data.put('desc_codcat',get_tcodec_name('TCODCATE',v_codcate, global_v_lang));
        obj_data.put('remark','');
        obj_data.put('dtetrst',to_char(i.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('dtestr',to_char(i.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('typfrom','2');
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_description_from_tposempdv(v_codempid varchar2, v_codcomp varchar2, v_codpos varchar2) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;

    cursor c1 is
        select  coddevp, desdevp, targetdev, dtestr, dteend, desresults
        from tposempdev
        where codempid = v_codempid
          and codcomp like v_codcomp || '%'
          and codpos = v_codpos
          and to_char(dtestr,'YYYY') = p_dteyear
        order by coddevp;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coddev',i.coddevp);
        obj_data.put('desc_coddev',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
        obj_data.put('devplan',i.desdevp);
        obj_data.put('target',i.targetdev);
        obj_data.put('dtestrt',to_char(i.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('result',i.desresults);

--        obj_data.put('codskill',i.codskill);
--        obj_data.put('grade',i.grade);
--        obj_data.put('coddevp',i.coddevp);
--        obj_data.put('descoddevp',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
--        obj_data.put('desdevp',i.desdevp);
--        obj_data.put('targetdev',i.targetdev);
--        obj_data.put('target_date1',to_char(i.dtestr,'dd/mm/yyyy'));
--        obj_data.put('target_date2',to_char(i.dteend,'dd/mm/yyyy'));
--        obj_data.put('desresults',i.desresults);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  procedure gen_career_plan(json_str_output out clob) as
    obj_data            json_object_t;
    obj_detail          json_object_t;
    v_flg_data          boolean := false;
    v_dteyear           number;
    cursor c1 is
        select codempid, codpos, codcomp, shorttrm, midterm, longtrm, descstr, descweek, descoop, descthreat, descdevp
          from tposemph
         where codempid = p_codempid_query;

    cursor c2 is
        select *
          from tposempd
         where codempid = p_codempid_query
           and dteefpos is null
      order by numseq ;
  begin
     obj_data := json_object_t();
     obj_data.put('coderror', '200');
     obj_detail := json_object_t();
     for i in c1 loop
        v_flg_data := true;
        obj_detail.put('coderror', '200');
        obj_detail.put('stasucc1', '1');
        obj_detail.put('work_age1', '1-3 ปี');
        obj_detail.put('desc_stasucc1', i.shorttrm);
        obj_detail.put('desc_full1', i.shorttrm);
        obj_detail.put('stasucc2', '2');
        obj_detail.put('work_age2', '3-5 ปี');
        obj_detail.put('desc_stasucc2', i.midterm);
        obj_detail.put('desc_full2', i.midterm);
        obj_detail.put('stasucc3', '3');
        obj_detail.put('work_age3', 'มากกว่า 5 ปี');
        obj_detail.put('desc_stasucc3', i.longtrm);
        obj_detail.put('desc_full3', i.longtrm);
        obj_detail.put('strength', i.descstr);
        obj_detail.put('weakness', i.descweek);
        obj_detail.put('opportunity', i.descoop);
        obj_detail.put('threat', i.descthreat);
        obj_detail.put('devskil', i.descdevp);

        for r2 in c2 loop
            obj_detail.put('fldwork', r2.codlinef);
            obj_detail.put('desc_fldwork',r2.codlinef||' - '||get_tfunclin_name(hcm_util.get_codcomp_level(r2.codcomp,1),r2.codlinef,global_v_lang));
            obj_detail.put('codcomp', r2.codcomp);
            obj_detail.put('desc_codcomp', get_tcenter_name(r2.codcomp,global_v_lang));
            obj_detail.put('codpos', r2.codpos);
            obj_detail.put('desc_codpos', get_tpostn_name(r2.codpos,global_v_lang));
            obj_detail.put('dteprom', to_char(add_months(r2.dteposdue, 6516), 'dd/mm/yyyy'));
            v_c2_numseq := r2.numseq;
            exit;
        end loop;

         obj_data.put('detail', obj_detail);
         obj_data.put('cmpt_req', find_competency_from_tposempc(i.codempid, i.codcomp, i.codpos));
         obj_data.put('course_req', find_course_from_tposemptr(i.codempid, i.codcomp, i.codpos));
         obj_data.put('dev_req', find_description_from_tposempdv(i.codempid, i.codcomp, i.codpos));
     end loop;
     if not v_flg_data then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPOSEMPD');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
     else
         dbms_lob.createtemporary(json_str_output, true);
         obj_data.to_clob(json_str_output);
     end if;
  end gen_career_plan;

  function find_competency_from_tappcmpt(v_c1_numtime number,v_c1_dteyreap number) return json_object_t is
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_lvl_emp   tcmptncy.grade%type;
    cursor c1 is
      select codtency, codskill, grade, gradexpct
       from tappcmpf
     where codempid = p_codempid_query
       and dteyreap = v_c1_dteyreap
       and numtime = v_c1_numtime
    order by codtency,codskill;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('typtency',i.codtency);
        obj_data.put('desc_typtency',get_tcomptnc_name(i.codtency,global_v_lang));
        obj_data.put('codtency',i.codskill);
        obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
        obj_data.put('exptlvl',i.gradexpct);
        begin
            select grade
            into v_lvl_emp
            from tcmptncy
            where codempid = p_codempid_query
              and codtency = i.codskill;
        exception when no_data_found then
            v_lvl_emp := 0;
        end;

        obj_data.put('level',v_lvl_emp);
        obj_data.put('gap',v_lvl_emp - i.gradexpct);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_course_from_tapptrnf(v_c1_numtime number,v_c1_dteyreap number) return json_object_t is
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_codcate   tcourse.codcate%type;
    cursor c1 is
        select codcours
        from tapptrnf
        where codempid = p_codempid_query
          and dteyreap = v_c1_dteyreap
          and numtime = v_c1_numtime
        order by codcours;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        begin
            select codcate
              into v_codcate
              from tcourse
             where codcours = i.codcours;
        exception when no_data_found then
            v_codcate := null;
        end;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('codcat',v_codcate);
        obj_data.put('desc_codcat',get_tcodec_name('TCODCATE',v_codcate, global_v_lang));
        obj_data.put('remark','');
        obj_data.put('dtetrst','');
        obj_data.put('dtetren','');
        obj_data.put('dtestr','');
        obj_data.put('dteend','');
        obj_data.put('typfrom','1');
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  function find_description_from_tappdevf(v_c1_numtime number,v_c1_dteyreap number) return json_object_t is
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    cursor c1 is
        select codskill, grade, coddevp, desdevp, targetdev, dtestr, dteend, desresults
        from tappdevf
        where codempid = p_codempid_query
          and dteyreap = p_dteyear
          and numtime = v_c1_numtime
          and dteend <= sysdate
        order by coddevp;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        obj_data := json_object_t();
        v_row := v_row+1;
        obj_data.put('coddev',i.coddevp);
        obj_data.put('desc_coddev',get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang));
        obj_data.put('devplan',i.desdevp);
        obj_data.put('target',i.targetdev);
        obj_data.put('dtestrt',to_char(i.dtestr,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
        obj_data.put('result',i.desresults);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_rows;
  end;

  procedure gen_evaluation(json_str_output out clob) as
    obj_rows         json_object_t;
    obj_data         json_object_t;
    obj_detail       json_object_t;
    v_row            number := 0;
    v_c1_dteyreap    tappcmpf.dteyreap%type;
    v_leader         tappfm.codapman%type;
    v_leader2        tappfm.codapman%type;
    v_c1_numtime     tappemp.numtime%type;

    cursor c1 is
     select dteyreap,numtime,codcomp,codpos
      from tappemp
      where codempid = p_codempid_query
        and dteyreap = p_dteyear
      order by numtime desc;
  begin
     obj_data := json_object_t();
     obj_data.put('coderror', '200');
     obj_detail := json_object_t();
     obj_detail.put('coderror', '200');

     for i in c1 loop
        v_row := v_row+1;
        begin
            select codapman into v_leader
              from tappfm
             where codempid = p_codempid_query
               and dteyreap = p_dteyear
               and numtime  = i.numtime
               and flgapman = 2
               and rownum = 1
          order by numseq desc;
        exception when no_data_found then
            v_leader := '';
        end;

        begin
            select codapman into v_leader2
              from tappfm
             where codempid = p_codempid_query
               and dteyreap = p_dteyear
               and numtime  = i.numtime
               and flgapman = 3
               and rownum = 1
          order by numseq desc;
        exception when no_data_found then
            v_leader2 := '';
        end;

        v_c1_dteyreap   := to_number(i.dteyreap);
        v_c1_numtime    := i.numtime;
     exit;
     end loop;

    obj_detail.put('year',hcm_util.get_year_buddhist_era(v_c1_dteyreap));
    obj_detail.put('numtime',v_c1_numtime);
    obj_detail.put('codemphf',v_leader);
    obj_detail.put('desc_codemphf',get_temploy_name(v_leader,global_v_lang));
    obj_detail.put('codemphl',v_leader2);
    obj_detail.put('desc_codemphl',get_temploy_name(v_leader2,global_v_lang));
    obj_data.put('detail',obj_detail);
    obj_data.put('cmpt_req',find_competency_from_tappcmpt(v_c1_numtime,v_c1_dteyreap));
    obj_data.put('course_req',find_course_from_tapptrnf(v_c1_numtime,v_c1_dteyreap));
    obj_data.put('dev_req',find_description_from_tappdevf(v_c1_numtime,v_c1_dteyreap));
     dbms_lob.createtemporary(json_str_output, true);
     obj_data.to_clob(json_str_output);
  end gen_evaluation;

  function find_max_numseq return number is
      max_numseq     number;
  begin
      select max(numseq) into max_numseq
        from ttemprpt where codempid = global_v_codempid
        and codapp = p_codapp;
        if max_numseq is null then
            max_numseq := 0 ;
        end if;
    return max_numseq;
  end;

  procedure insert_competency_to_temp as
    p_numseq     number;
    cursor c1 is
    select codtency,codskill,grade,grdemp
    from tidpcptc
    where dteyear = p_dteyear
      and codempid = p_codempid_query
    order by codtency,codskill;
    v_num   number := 0;
  begin
    for i in c1 loop
        v_num := v_num + 1;
        p_numseq := find_max_numseq+1;

        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
        values(global_v_codempid,p_codapp,p_numseq,get_tcomptnc_name(i.codtency,global_v_lang),i.codskill,get_tcodec_name('TCODSKIL',i.codskill,global_v_lang),i.grade,i.grdemp,i.grdemp - i.grade,'table1');

    end loop;
    if v_num = 0 then
        p_numseq := find_max_numseq+1;
        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
        values(global_v_codempid,p_codapp,p_numseq,'','','','','','','table1');
    end if;
  end insert_competency_to_temp;

  procedure insert_idp_to_temp as
    p_numseq       number;

    cursor c1 is
        select codcours,codcate,typfrom,dtetrst,dtetren
          from tidpplans
         where dteyear = p_dteyear
           and codempid = p_codempid_query
      order by codcours,typfrom;
    v_num       number := 0;
  begin
    for i in c1 loop
        v_num       := v_num + 1;
        p_numseq    := find_max_numseq+1;

        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
        values(global_v_codempid,p_codapp,p_numseq,i.codcours,
               get_tcourse_name(i.codcours,global_v_lang),
               get_tcodec_name('TCODCATE',i.codcate,global_v_lang),
               get_tlistval_name('TYPFROM',i.typfrom,global_v_lang),hcm_util.get_date_buddhist_era(i.dtetrst),
               hcm_util.get_date_buddhist_era(i.dtetren),'table2');
    end loop;
    if v_num = 0 then
        p_numseq := find_max_numseq+1;
        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
        values(global_v_codempid,p_codapp,p_numseq,'','','','','','','table2');
    end if;
  end insert_idp_to_temp;

  procedure insert_idp_cptcd_to_temp(v_codcomp varchar,v_codpos varchar) as
    add_month    number:=0;
    p_numseq     number;
    v_tidpcptcd  tidpcptcd%rowtype;
    cursor c1 is
--        select a.coddevp,a.desdevp,a.codskill
--          from tcomptdev a, tjobposskil b
--        where a.codskill = b.codskill
--          and a.grade = b.grade
--          and b.codcomp like v_codcomp || '%'
--          and b.codpos = v_codpos
--    group by a.coddevp,a.desdevp,a.codskill
--    order by a.coddevp;
     select coddevp,desdevp,targetdev,dtestr,desresults,dteend
        from tidpcptcd
        where dteyear = p_dteyear
          and codempid = p_codempid_query
        order by coddevp;

        v_num   number := 0;


  begin
    for i in c1 loop
        v_num := v_num + 1;
        p_numseq := find_max_numseq+1;

        if global_v_lang ='102' then
            add_month := 543*12;
        end if;

        begin
            select * into v_tidpcptcd
            from tidpcptcd
            where dteyear = p_dteyear
              and codempid = p_codempid_query
              and coddevp = i.coddevp;
        exception when no_data_found then
            v_tidpcptcd := null;
        end;
        insert into ttemprpt(codempid,codapp,numseq,
                             item1,item2,item3,
                             item4,item5,item6,item8,item9)
        values(global_v_codempid,p_codapp,p_numseq,
               i.coddevp,get_tcodec_name('TCODDEVT',i.coddevp,global_v_lang),i.desdevp,
        hcm_util.get_date_buddhist_era(v_tidpcptcd.dtestr),hcm_util.get_date_buddhist_era(v_tidpcptcd.dteend),v_tidpcptcd.DESRESULTS,'table3',v_tidpcptcd.targetdev);

    end loop;

    if v_num = 0 then
        p_numseq := find_max_numseq+1;
        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item8)
        values(global_v_codempid,p_codapp,p_numseq,'','','','','','','table3');
    end if;
  end insert_idp_cptcd_to_temp;

  procedure insert_idp_emp_to_temp as
    add_month   number:=0;
    p_numseq    number;
    v_tidpplan  tidpplan%rowtype;
  begin
    begin
        select *
          into v_tidpplan
          from tidpplan
         where dteyear = p_dteyear
           and codempid = p_codempid_query;
    exception when no_data_found then
        v_tidpplan := null;
    end;
    p_numseq := find_max_numseq+1;

    insert into ttemprpt(codempid,codapp,numseq,
                         item1,item2,item3,
                         item4,item5,
                         item6,
                         item7,item8)
    values(global_v_codempid,p_codapp,p_numseq,
           v_tidpplan.stadevp,v_tidpplan.commtemp,hcm_util.get_date_buddhist_era(v_tidpplan.dteconf),
           v_tidpplan.commtemph,get_temploy_name(v_tidpplan.codappr, global_v_lang),
           hcm_util.get_date_buddhist_era(v_tidpplan.dteappr),
           'footer',v_tidpplan.commtfoll);
  end insert_idp_emp_to_temp;

  procedure gen_report(json_str_output out clob) as
    res_codcomp    temploy1.codcomp%type;
    res_codpos     temploy1.codpos%type;
    res_talent     varchar2(1000 char);
    v_year         number := 0;
    v_dteyrepay    varchar2(1000 char) := '';
    p_numseq       number;
    max_numseq     number;

    begin
        begin
            select codcomp,codpos into res_codcomp,res_codpos
            from temploy1
            where codempid = p_codempid_query;
        exception when no_data_found then
            res_codcomp := '';
            res_codpos := '';
        end;

        begin
            select get_label_name('HRTR23EC1',global_v_lang,'440') into res_talent
            from ttalente
            where codempid = p_codempid_query;
        exception when no_data_found then
            res_talent := get_label_name('HRTR23EC1',global_v_lang,'450');
        end;

        begin
            select max(numseq) into max_numseq
              from ttemprpt where codempid = global_v_codempid
               and codapp = p_codapp;
            if max_numseq is null then
                max_numseq := 0 ;
            end if;
        end;

        p_numseq    := max_numseq+1;
        v_year      := hcm_appsettings.get_additional_year;
        v_dteyrepay := p_dteyear + v_year;

        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
        values(global_v_codempid,p_codapp,p_numseq,
               v_dteyrepay,
               get_temploy_name(p_codempid_query,global_v_lang),
               get_tcenter_name(res_codcomp,global_v_lang),
               get_tpostn_name(res_codpos,global_v_lang),res_talent,'header',p_codempid_query);

        insert_competency_to_temp;
        insert_idp_to_temp;
        insert_idp_cptcd_to_temp(res_codcomp,res_codpos);
        insert_idp_emp_to_temp;
  end gen_report;

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

  procedure get_succession_plan(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_succession_plan(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_succession_plan;

  procedure get_next_succession_plan(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_next_succession_plan(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_next_succession_plan;


  procedure get_career_plan(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_career_plan(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_career_plan;

  procedure get_evaluation(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_evaluation(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_evaluation;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
  begin
    initial_value(json_str_input);
    p_codcomp           := hcm_util.get_string_t(param_detail,'codcomp');
    p_codpos            := hcm_util.get_string_t(param_detail,'codpos');
    p_stadevp           := hcm_util.get_string_t(param_detail,'resultaft');
    p_commtemp          := hcm_util.get_string_t(param_detail,'commtemp');
    p_commtemph         := hcm_util.get_string_t(param_detail,'commthead');
    p_commtfoll         := hcm_util.get_string_t(param_detail,'commtfoll');
    p_dteconf           := to_date(hcm_util.get_string_t(param_detail,'dtecomfirme'),'dd/mm/yyyy');
    p_dteconfh          := to_date(hcm_util.get_string_t(param_detail,'dtecomfirmh'),'dd/mm/yyyy');
    p_dteappr           := to_date(hcm_util.get_string_t(param_detail,'dteappr'),'dd/mm/yyyy');
    p_codappr           := hcm_util.get_string_t(param_detail,'codappr');
    check_param;
    if param_msg_error is null then
        insert_tidpplan;
        insert_tiddplans;
        insert_tidpcptc;
        insert_tidpcptcd;
    end if;
    --<<nut
    if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        if p_codappr is not null and p_dteappr is not null and param_flgwarn = 'S' then
            if param_flgwarn = 'S' then
                param_msg_error := get_error_msg_php('TR0053',global_v_lang);
                param_flgwarn := 'WARN1';
                json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
            end if;
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    end if;
    /*if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;*/
    -->>nut

  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_count        number := 0;
    v_codcomp      temploy1.codcomp%type;

    cursor c1 is
        select codcours
        from tidpplans
        where dteyear = p_dteyear
          and codempid = p_codempid_query;
  begin
    initial_value(json_str_input);

    for i in c1 loop
        begin
            select codcomp into v_codcomp
            from temploy1
            where codempid = p_codempid_query;
        exception when no_data_found then
            v_codcomp := '';
        end;

        select count(dteyear) into v_count
        from ttpotent
        where dteyear = p_dteyear
          and v_codcomp like codcompy||'%'
          and codcours = i.codcours
          and codempid = p_codempid_query;
    end loop;

    if v_count = 0 then
        delete_tidpplan;

        delete from tidpplans
         where dteyear = p_dteyear
           and codempid = p_codempid_query;

        delete from tidpcptc
         where dteyear = p_dteyear
           and codempid = p_codempid_query;

        delete from tidpcptcd
        where dteyear = p_dteyear
          and codempid = p_codempid_query;
    end if;
    if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure get_report(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    clear_ttemprpt;
    if param_msg_error is null then
        gen_report(json_str_output);
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_report;
  --
  procedure gen_gap_competency(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row_cmp     json_object_t;
    obj_row_course  json_object_t;
    obj_row_dev     json_object_t;
    obj_data_cmp    json_object_t;
    obj_data_course json_object_t;
    obj_data_dev    json_object_t;
    v_rcnt_cmp      number := 0;
    v_rcnt_course   number := 0;
    v_rcnt_dev      number := 0;

    v_grade     tcomptcr.grade%type;
    v_codskill  tcomptcr.codskill%type;
    cursor c_cmp is
      select jps.codtency,jps.codskill,jps.grade as grd_target,nvl(cmp.grade,0) as grd_emp,
             cmp.grade - jps.grade as gap
        from temploy1 emp, tcmptncy cmp, tjobposskil jps
       where emp.codempid   = p_codempid_query
         and emp.numappl    = cmp.numappl(+)
         and emp.codcomp    = jps.codcomp
         and emp.codpos     = jps.codpos
         and cmp.codtency(+)   = jps.codskill
         and nvl(cmp.grade(+),0) < nvl(jps.grade,99)
      order by cmp.codtency;

    cursor c_course is
      select t1.codcours, t2.codcate
        from tcomptcr t1,tcourse t2
       where t1.codcours    = t2.codcours
         and t1.codskill    = v_codskill
         and t1.grade       >= v_grade
      order by codcours;

    cursor c_dev is
      select coddevp,desdevp
        from tcomptdev
       where codskill   = v_codskill
         and grade      >= v_grade
      order by coddevp;

  begin
    obj_row_cmp     := json_object_t();
    obj_row_course  := json_object_t();
    obj_row_dev     := json_object_t();
    for r_cmp in c_cmp loop
      obj_data_cmp    := json_object_t();
      obj_data_cmp.put('typtency',r_cmp.codtency);
      obj_data_cmp.put('desc_typtency',get_tcomptnc_name(r_cmp.codtency,global_v_lang));
      obj_data_cmp.put('codtency',r_cmp.codskill);
      obj_data_cmp.put('desc_codtency',get_tcodec_name('TCODSKIL',r_cmp.codskill,global_v_lang));
      obj_data_cmp.put('exptlvl',r_cmp.grd_target);
      obj_data_cmp.put('level',r_cmp.grd_emp);
      obj_data_cmp.put('gap',r_cmp.gap);
      obj_row_cmp.put(to_char(v_rcnt_cmp),obj_data_cmp);
      v_rcnt_cmp  := v_rcnt_cmp + 1;
      v_codskill  := r_cmp.codskill;
      v_grade     := r_cmp.grd_emp;
      for r_course in c_course loop
        obj_data_course   := json_object_t();
        obj_data_course.put('codcours',r_course.codcours);
        obj_data_course.put('desc_codcours',get_tcourse_name(r_course.codcours,global_v_lang));
        obj_data_course.put('codcat',r_course.codcate);
        obj_data_course.put('desc_codcat',get_tcodec_name('TCODCATE',r_course.codcate,global_v_lang));
        obj_row_course.put(to_char(v_rcnt_course),obj_data_course);
        v_rcnt_course   := v_rcnt_course + 1;
      end loop;
      for r_dev in c_dev loop
        obj_data_dev   := json_object_t();
        obj_data_dev.put('coddev',r_dev.coddevp);
        obj_data_dev.put('desc_coddev',get_tcodec_name('TCODDEVT',r_dev.coddevp,global_v_lang));
        obj_data_dev.put('devplan',r_dev.desdevp);
        obj_row_dev.put(to_char(v_rcnt_dev),obj_data_dev);
        v_rcnt_dev    := v_rcnt_dev + 1;
      end loop;
    end loop;
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('competency',obj_row_cmp);
    obj_data.put('course',obj_row_course);
    obj_data.put('development',obj_row_dev);
    if v_rcnt_course = 0 and v_rcnt_dev = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcomptcr');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output   := obj_data.to_clob;
    end if;
  end;
  --
  procedure get_gap_competency(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_gap_competency(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
END HRTR23E;

/

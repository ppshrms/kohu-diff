--------------------------------------------------------
--  DDL for Package Body HRTR33E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR33E" AS

  procedure initial_value(json_str_input in clob) is
     json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        p_codcomp         := upper(hcm_util.get_string(json_obj,'p_codcomp'));
        p_codpos          := hcm_util.get_string(json_obj,'p_codpos');
        p_codcours        := hcm_util.get_string(json_obj,'p_codcours');
        p_codcate         := hcm_util.get_string(json_obj,'p_codcate');

  end initial_value;

  procedure check_index as
        v_temp  varchar2(1 char);
        v_temp2 varchar2(1 char);
        v_temp3 varchar2(1 char);
        v_temp4 varchar2(1 char);
  begin
--  validate codcomp,codpos
    if p_codcomp is null or p_codpos is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcomp in tcenter
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp||'%'
        and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
    end;

--   check codpos in tjobpos
     begin
        select distinct 'X' into v_temp4
        from tjobpos
        where codpos = p_codpos;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tjobpos');
        return;
     end;

--  check codpos in tpostn
    begin
        select 'X' into v_temp2
        from tpostn
        where codpos = p_codpos;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
        return;
    end;

--  check codpos and codcomp in tjobpos
    begin
        select 'X' into v_temp3
        from tjobpos
        where codpos = p_codpos
         and codcomp = p_codcomp;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tjobpos');
        return;
     end;

  end check_index;

  procedure check_param as
        v_temp  varchar2(1 char);
        v_temp2 varchar2(1 char);
        v_temp3 varchar2(1 char);
  begin
--  validate codcomp,codpos,qtyposst
    if p_codcomp is null or p_codpos is null or p_qtyposst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--   check null typemp
     if p_typemp is null and p_typemp2 is null  then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

--  check codcours in tcourse
    begin
        select 'X' into v_temp
        from tcourse
        where codcours = p_codcours
        and rownum = 1;
     exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
        return;
     end;

  end check_param;

  function gen_index_children(v_codcours VARCHAR2) return json is
    obj_rows        json;
    obj_data        json;
    v_row           number := 0;
    v_number        number;
    v_typemp2       boolean;
    v_typemp1       boolean;
    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_codcours2     tcourse.codcours%type;
    num_total_rows  NUMBER := 0;
    v_hr            varchar(10 char);
    cursor c1 is
    select codcours,typemp,qtyposst,remark
    from tbasictp
    where codcomp = p_codcomp
      and codpos = p_codpos
      and codcours = v_codcours
    order by codcate,codcours;
  begin
    begin
        select count(*) into num_total_rows
        from tbasictp
        where codcomp = p_codcomp
          and codpos = p_codpos
          and codcours = v_codcours;
    end;
    obj_rows := json();
    for i in c1 loop
        if i.typemp = 'N' then
            v_typemp1 := true;
            v_typemp2 := false;
        else
            v_typemp1 := false;
            v_typemp2 := true;
        end if;
        v_row := v_row+1;
        obj_data := json();
        v_number := v_row;
        obj_data.put('no',v_number);
        obj_data.put('codcours',i.codcours);
        begin
            select qtytrhur,coddevp into v_qtytrhur,v_coddevp
            from tcourse
            where codcours = i.codcours
              and rownum = 1;
        exception when no_data_found then
            v_qtytrhur := '';
            v_coddevp := '';
        end;
        v_hr := replace(v_qtytrhur, '.', ':');
        if instr(v_hr, ':') = 0 then
            obj_data.put('qtytrhur',rpad(v_hr||':',length(v_hr||':')+2,'0'));
        else
            obj_data.put('qtytrhur',rpad(v_hr, length(v_hr)+1, '0'));
        end if;
        obj_data.put('coddevp_name',get_tlistval_name('METTRAIN',v_coddevp,global_v_lang));
        obj_data.put('qtyposst',i.qtyposst);
        obj_data.put('remark',i.remark);

        if num_total_rows > 1 then
            v_typemp1 := true;
            v_typemp2 := true;
        end if;
        obj_data.put('typemp',v_typemp1);
        obj_data.put('typemp2',v_typemp2);
        v_codcours2 := i.codcours;
        obj_rows.put(to_char(v_row-1),obj_data);
        exit;
    end loop;
    return obj_rows;
  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows    json;
    obj_data    json;
    v_row       number := 0;
    v_number    number;
    v_codcours  tbasictp.codcours%type;
    v_codcate   tbasictp.codcate%type;
    v_count     number;
    v_typemp2   boolean;
    v_typemp1   boolean;
    v_qtytrhur  tcourse.qtytrhur%type;
    v_coddevp   tcourse.coddevp%type;
    v_hr        varchar(10 char);
    cursor c1 is
    select codcate,codcours,qtyposst,remark,typemp
    from tbasictp
    where codcomp = p_codcomp
      and codpos = p_codpos
    order by codcate,codcours;

  begin
        obj_rows := json();
        for i in c1 loop
            if v_codcours = i.codcours then
                continue;
            else
                v_codcours := i.codcours;
                begin
                    select count(*) into v_count
                    from tbasictp
                    where codcomp = p_codcomp
                      and codpos = p_codpos
                      and codcours = v_codcours;
                end;
                if v_count > 1 then
                    v_typemp1 := true;
                    v_typemp2 := true;
                else
                    if i.typemp = 'N' then
                        v_typemp1 := true;
                        v_typemp2 := false;
                    else
                        v_typemp1 := false;
                        v_typemp2 := true;
                    end if;
                end if;
                v_row := v_row+1;
                obj_data := json();
                v_number := v_row;
                obj_data.put('no',v_number);
                obj_data.put('codcate',i.codcate);
                obj_data.put('codcate_name',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
                obj_data.put('codcours',i.codcours);
                obj_data.put('codcours_name',get_tcourse_name(i.codcours,global_v_lang));
                begin
                    select qtytrhur,coddevp into v_qtytrhur,v_coddevp
                    from tcourse
                    where codcours = i.codcours
                      and rownum = 1;
                exception when no_data_found then
                    v_qtytrhur := '';
                    v_coddevp := '';
                end;
                v_hr := replace(v_qtytrhur, '.', ':');
                if instr(v_hr, ':') = 0 then
                    obj_data.put('qtytrhur',rpad(v_hr||':',length(v_hr||':')+2,'0'));
                else
                    if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                        obj_data.put('qtytrhur',v_hr);
                    else
                        obj_data.put('qtytrhur',rpad(v_hr,length(v_hr)+1,'0'));
                    end if;
                end if;
                obj_data.put('coddevp_name',get_tlistval_name('METTRAIN',v_coddevp,global_v_lang));
                obj_data.put('qtyposst',i.qtyposst);
                obj_data.put('remark',i.remark);
                obj_data.put('typemp',v_typemp1);
                obj_data.put('typemp2',v_typemp2);
                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
  end gen_index;

  procedure gen_course_from_codcate(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_hr        varchar(10 char);
        cursor c_tcourse is
        select codcours,qtytrhur,coddevp
        from tcourse
        where codcate = p_codcate
        and rownum = 1;
  begin
        obj_rows := json();
        for i in c_tcourse loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('codcours',i.codcours);
            v_hr := replace(i.qtytrhur, '.', ':');
            if instr(v_hr, ':') = 0 then
                obj_data.put('qtytrhur',rpad(v_hr||':',length(v_hr||':')+2,'0'));
            else
                if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                    obj_data.put('qtytrhur',v_hr);
                else
                    obj_data.put('qtytrhur',rpad(v_hr,length(v_hr)+1,'0'));
                end if;
            end if;
            obj_data.put('coddevp',get_tlistval_name('METTRAIN',i.coddevp,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);

    end gen_course_from_codcate;

    procedure gen_course_from_codcours(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_hr        varchar(10 char);
        cursor c_tcourse is
        select qtytrhur,coddevp,codcate
        from tcourse
        where codcours = p_codcours
        and rownum = 1;
  begin
        obj_rows := json();
        for i in c_tcourse loop
            v_row := v_row+1;
            obj_data := json();
            obj_data.put('codcate',i.codcate);
            obj_data.put('codcate_name',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            v_hr := replace(i.qtytrhur, '.', ':');
            if instr(v_hr, ':') = 0 then
                obj_data.put('qtytrhur',rpad(v_hr||':',length(v_hr||':')+2,'0'));
            else
                if length(substr(v_hr, instr(v_hr, ':') + 1)) = 2 then
                    obj_data.put('qtytrhur',v_hr);
                else
                    obj_data.put('qtytrhur',rpad(v_hr,length(v_hr)+1,'0'));
                end if;
            end if;
            obj_data.put('coddevp',get_tlistval_name('METTRAIN',i.coddevp,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_course_from_codcours;

    procedure gen_course_from_competency(json_str_output out clob) as
        obj_rows    json;
        obj_data    json;
        v_row       number := 0;
        v_number    varchar2(100 char);
        cursor c1 is
            select b.codcours as "CODCOURS",c.codcate
             from tcomptcr b,tcourse c
             where b.codcours = c.codcours
              and exists (select c.codskill,c.grade
                            from tjobposskil c
                            where c.codcomp = p_codcomp
                                and c.codpos = p_codpos
                                and c.codskill = b.codskill
                                and b.grade <= c.grade)
                group by b.codcours,c.codcate
                order by b.codcours,c.codcate;
    begin
        obj_rows := json();
        for i in c1 loop
            v_row := v_row+1;
            obj_data := json();
            v_number := v_row;
            obj_data.put('no',v_number);
            obj_data.put('codcours',i.codcours);
            obj_data.put('codcate',i.codcate);
            obj_data.put('cours_des',get_tcourse_name(i.codcours,global_v_lang));
            obj_data.put('codcate_name',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);

    end gen_course_from_competency;

  procedure insert_index(v_tyemp varchar) as
  begin
    begin
        insert into tbasictp (codcomp,codpos,typemp,codcours,codcate,qtyposst,codcreate,coduser,remark)
        values (p_codcomp,p_codpos,v_tyemp,p_codcours,p_codcate,p_qtyposst,global_v_coduser,global_v_coduser,p_remark);
    exception when dup_val_on_index then
        null;
    end;
  end insert_index;

  procedure update_index as
  begin
    update tbasictp
    set qtyposst = p_qtyposst,
        codcours = p_codcours,
        remark = p_remark,
        coduser = global_v_coduser
    where codcomp = p_codcomp
      and codpos = p_codpos
      and codcours = p_codcours;
   end update_index;

  procedure delete_index(v_typemp varchar) as
  begin
    delete from tbasictp
    where codcomp = p_codcomp
      and codpos = p_codpos
      and typemp = v_typemp
      and codcours = p_codcours;
  end delete_index;

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

  procedure get_course_from_codcate(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if p_codcate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
    end if;
    if param_msg_error is null then
            gen_course_from_codcate(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_course_from_codcate;

  procedure get_course_from_codcourse(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if p_codcours is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
      if param_msg_error is null then
            gen_course_from_codcours(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_course_from_codcourse;

  procedure get_course_from_competency(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if p_codcomp is null or p_codpos is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if param_msg_error is null then
            gen_course_from_competency(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  end get_course_from_competency;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
        json_obj    json;
        data_obj    json;
        v_item_flgedit varchar2(10 char);
        v_temp2 varchar2(1 char);
  begin
        json_obj    := json(json_str_input);
        param_json  := hcm_util.get_json(json_obj,'param_json');

        for i in 0..param_json.count-1 loop
            data_obj := hcm_util.get_json(param_json,to_char(i));
            initial_value(json_str_input);

            p_codcomp      := hcm_util.get_string(data_obj,'p_codcomp');
            p_codpos       := hcm_util.get_string(data_obj,'p_codpos');
            p_codcours     := hcm_util.get_string(data_obj,'p_codcours');
            p_typemp       := hcm_util.get_string(data_obj,'p_typemp');
            p_typemp2      := hcm_util.get_string(data_obj,'p_typemp2');
            p_qtyposst     := hcm_util.get_string(data_obj,'p_qtyposst');
            p_codcate      := hcm_util.get_string(data_obj,'p_codcate');
            p_remark       := hcm_util.get_string(data_obj,'p_remark');
            v_item_flgedit := hcm_util.get_string(data_obj,'flag');

            if v_item_flgedit != 'Add' and v_item_flgedit != 'Edit' and v_item_flgedit != 'Delete' then
                continue;
            else
                check_param;
                if param_msg_error is null then
                    if v_item_flgedit = 'Add' then
                        -- insert typeemp M
                        select count(*) into v_temp2
                                from tbasictp
                                where codcours = p_codcours
                                  and codcomp = p_codcomp
                                  and codpos = p_codpos
                                  and typemp = 'N';
                        if p_typemp = 'N' then
                            if v_temp2 > 0  then
                                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tbasictp');
                            else
                                insert_index('N');
                            end if;
                        end if;
                    -- insert typeemp N
                    select count(*) into v_temp2
                            from tbasictp
                            where codcours = p_codcours
                              and codcomp = p_codcomp
                              and codpos = p_codpos
                              and typemp = 'M';
                        if p_typemp2 = 'M' then
                            if v_temp2 > 0 then
                                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tbasictp');
                            else
                                insert_index('M');
                            end if;
                        end if;
                    elsif v_item_flgedit = 'Edit' then
                    --update typemp N
                        if p_typemp = 'N' then
                            insert_index('N');
                            update_index;
                        elsif  p_typemp is null then
                            delete_index('N');
                        end if;
                    --update typemp M
                        if p_typemp2 = 'M' then
                            insert_index('M');
                            update_index;
                        elsif  p_typemp2 is null then
                            delete_index('M');
                        end if;
                    --delete all
                    elsif v_item_flgedit = 'Delete' then
                        delete_index('N');
                        delete_index('M');
                    end if;
                else
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                end if;
            end if;
        end loop;
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

  end save_index;

END HRTR33E;

/

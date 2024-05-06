--------------------------------------------------------
--  DDL for Package Body HRPM75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM75X" as
-- last update: 06/02/2021 17:15 redmine #3249

procedure initial_value(json_str_input in clob) as
    json_obj    json_object_t;
    v_codpunish  json_object_t;

  begin
    json_obj            := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_yearstrt          := hcm_util.get_string_t(json_obj,'p_yearstrt');
    p_monthstrt         := hcm_util.get_string_t(json_obj,'p_monthstrt');
    p_yearend           := hcm_util.get_string_t(json_obj,'p_yearend');
    p_monthend          := hcm_util.get_string_t(json_obj,'p_monthend');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typreport         := hcm_util.get_string_t(json_obj,'p_typreport');

    dataselect          := hcm_util.get_json_t(json_obj,'p_codcodec');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure vadidate_variable_getindex(json_str_input in clob) as
    cursor c_resultcodcomp is
      select CODCOMP
        from TCENTER
       where CODCOMP like p_codcomp||'%';

   objectCursorResultcodcomp       c_resultcodcomp%ROWTYPE;
   v_secur_codcomp    boolean;
   v_zupdsal          varchar2 (1 char);
   v_numlvl           temploy1.numlvl%type;
   v_codcomp          temploy1.codcomp%type;
   v_secur1           boolean;
  BEGIN
    if (p_codcomp is null or p_codcomp = ' ') then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_codcomp');
       return ;
    end if;

    if (p_codcomp is not null) then
    begin
       OPEN c_resultcodcomp;
        FETCH c_resultcodcomp INTO objectCursorResultcodcomp;
        IF (c_resultcodcomp%NOTFOUND) THEN
              param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'p_codcomp');
              return ;
        END IF;
    CLOSE c_resultcodcomp;
    end;
    end if;

    if(p_typreport is null or p_typreport = ' ') then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_typreport');
      return ;
    end if;

    if (p_monthstrt is null or p_monthstrt = ' ') then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_monthstrt');
        return ;
    end if;

    if(p_yearstrt is null or p_yearstrt = ' ') then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_yearstrt');
        return ;
    end if;

    if(p_monthend is null or p_monthend = ' ') then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_monthend');
      return ;
    end if;

    if(p_yearend is null or p_yearend = ' ') then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_yearend');
      return ;
    end if;

    if(p_yearstrt > p_yearend) then
       param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
      return ;
    end if;

    if(p_yearstrt = p_yearend) then
        if(to_number(p_monthstrt) > to_number(p_monthend)) then
            param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
            return ;
        end if;
    end if;

    v_secur1 := secur_main.secur7(p_codcomp , global_v_coduser);

    if (v_secur1 = false ) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
    end if;

  END vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    dstr_tmp        date := to_date('01/'||p_monthstrt||'/'||p_yearstrt,'dd/mm/yyyy');
    dstr2_tmp       date := to_date('01/'||p_monthend||'/'||p_yearend,'dd/mm/yyyy');
    dend_tmp        date := last_day(dstr2_tmp);

    v_data          boolean := false;
    p_codcodec_tmp  varchar2(10 char);
    v_statment      varchar2(1000 char);
    sql_stmt        VARCHAR2(4000 char);
    cur             SYS_REFCURSOR;
    v_codcomp       thispun.codcomp%type;
    v_codcomplv     thispun.codcomp%type;
    v_setcomp       number;
    v_qtyemp        number :=0;
    v_total         number :=0;
    type tmp is table of integer;
    type arr is table of varchar(100);

    tmp_codcodec    varchar2(10 char);
    graph_val       varchar2(10 char);
    idx             number := 0;
    v_idxreport     number := 0;
    v_codcomplvl    varchar2(1000 char);
    v_qtyall        number := 0;
    v_qtyoth        number := 0;
    v_cntpunish      number := 0;

    cursor c1 is
      select hcm_util.get_codcomp_level(t2.codcomp,p_typreport) codcomp
        from thismist t2,thispun a 
       where t2.codcomp like p_codcomp ||'%'
         and t2.codempid = a.codempid and t2.dteeffec  = a.dteeffec
         and to_char(t2.dteeffec,'YYYY-MM-DD') between dstr_tmp and dend_tmp
         and exists (select codcomp from tusrcom b
                      where b.coduser =  global_v_coduser 
                       and t2.codcomp like b.codcomp || '%')
        and t2.numlvl between global_v_zminlvl and global_v_zwrklvl
        group by hcm_util.get_codcomp_level(t2.codcomp,p_typreport)
        order by hcm_util.get_codcomp_level(t2.codcomp,p_typreport);

  begin
    obj_row := json_object_t();

    delete from ttemprpt
          where codapp = 'HRPM75X'
            and codempid = global_v_codempid;

    delete from trepdisp
          where codapp = 'HRPM75X'
            and coduser = global_v_coduser;

    delete from trepapp2
          where codapp = 'HRPM75X'
            and keycolumn like 'punish%';

      for i in 0..dataselect.get_size - 1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        p_codcodec_tmp    := hcm_util.get_string_t(dataselect,to_char(i));
        p_codcodec        := REPLACE(p_codcodec_tmp,'"','');

        INSERT INTO TREPDISP (CODUSER,CODAPP,NUMSEQ,CODDISP,CODCREATE)
        VALUES (global_v_coduser,'HRPM75X',i,p_codcodec,global_v_coduser);
      end loop;
      begin
        select sum(nvl(qtycode ,0)) into v_setcomp
        from tsetcomp
        where numseq <= p_typreport;
      end;
      v_rcnt := 0;

      for r1 in c1 loop
        obj_data := json_object_t();
        v_rcnt      := v_rcnt+1;
        v_total     := 0;

        v_codcomp := r1.codcomp;
        obj_data.put('codcomp', v_codcomp);
        obj_data.put('dep', get_tcenter_name(v_codcomp,global_v_lang));
        v_cntpunish := 0;
        v_idxreport := 0;
        for j in 0..dataselect.get_size - 1 loop
          v_idxreport := v_idxreport + 1;

          v_cntpunish  := v_cntpunish + 1;

          tmp_codcodec := hcm_util.get_string_t(dataselect,to_char(j));
          tmp_codcodec := REPLACE(tmp_codcodec,'"','');

          begin
            select substr(codcomp,1,v_setcomp),sum(decode(codpunsh,tmp_codcodec,1,0)) qtypunsh
                 into v_codcomplv,v_qtyemp
             from (select distinct a.codcomp,a.codpunsh,a.codempid 
                    from thispun a 
                    where a.dteeffec between dstr_tmp and dend_tmp
                    and a.codcomp like v_codcomp || '%'
                    and exists (select codcomp from tusrcom b 
                                where b.coduser = global_v_coduser
                                and a.codcomp like b.codcomp ||'%')
                    and a.numlvl between global_v_zminlvl and global_v_zwrklvl ) 
            group by substr(codcomp,1,v_setcomp)
            order by substr(codcomp,1,v_setcomp);
          exception when no_data_found then 
            v_qtyemp := 0;
          end;

          v_total := v_total + v_qtyemp;
          begin
            Insert into TREPAPP2 (CODAPP,KEYCOLUMN,STYLE_COLUMN,STYLE_DATA,CODCREATE,CODUSER)
                          values ('HRPM75X','punish'||v_idxreport,'text-align: center; vertical-align: middle; width: 50px;','text-align: center;',global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          obj_data.put('punish'||(j+1), v_qtyemp);
          v_qtyemp :=0;
        end loop;
        begin
          select substr(codcomp,1,v_setcomp),count(codpunsh) into v_codcomplvl, v_qtyall
            from (select distinct a.codcomp,a.codpunsh,a.codempid
                    from thispun a
                    where a.dteeffec between dstr_tmp and dend_tmp
                    and a.codcomp like v_codcomp||'%'
                    and exists (select codcomp
                                from tusrcom b
                                where b.coduser = global_v_coduser
                                and a.codcomp like b.codcomp||'%')
                    and a.numlvl between global_v_zminlvl and global_v_zwrklvl )
            group by substr(codcomp,1,v_setcomp)
            order by substr(codcomp,1,v_setcomp);
        exception when others then
          v_qtyall := 0;
        end;
        v_qtyoth := v_qtyall - v_total;
        obj_data.put('punish'||(v_cntpunish+1), v_qtyoth);
        begin
           Insert into TREPAPP2 (CODAPP,KEYCOLUMN,STYLE_COLUMN,STYLE_DATA,CODCREATE,CODUSER)
                        values ('HRPM75X','punish'||(v_cntpunish+1),'text-align: center; vertical-align: middle; width: 50px;','text-align: center;',global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          null;
        end;

        obj_data.put('sum', (v_total + v_qtyoth));
        if v_total > 0 then
          v_data := true;
        end if;
        -- + 1 for other punish
        obj_data.put('punishnum', dataselect.get_size + 1);
        v_total :=0;

        obj_data.put('coderror', '200');
        obj_row.put(to_char(v_rcnt-1),obj_data);

      end loop;

      if v_data then
          insert_graph(obj_row,dataselect);
          json_str_output := obj_row.to_clob();
      else
          param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'THISPUN');
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
      end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure insert_graph(list_json in json_object_t,data_select in json_object_t) as
    v_item_listjson       json_object_t;
    v_item_dataselect     trepdisp.coddisp%type;
    v_des_tcodpunh        tcodpunh.descode%type;
    v_count_row           number := 1;
    v_cbtcodpun           number := 0;
    v_codcomp             varchar2(1000 char);
    v_dep                 varchar2(1000 char);
    v_punish               varchar2(1000 char);
  begin
    for i in 0..list_json.get_size - 1 loop
      v_item_listjson := hcm_util.get_json_t(list_json,i);
      v_cbtcodpun := 0;
      for j in 0..data_select.get_size - 1 loop

--        v_item_dataselect := dataselect.get(j).get_string();
        v_item_dataselect := hcm_util.get_string_t(dataselect,to_char(j));
        v_des_tcodpunh := get_tcodec_name('TCODPUNH',v_item_dataselect,global_v_lang);
        v_cbtcodpun :=  v_cbtcodpun + 1;
        begin
          v_codcomp := hcm_util.get_string_t(v_item_listjson,'codcomp');
          v_dep     := hcm_util.get_string_t(v_item_listjson,'dep');
          v_punish   := hcm_util.get_string_t(v_item_listjson,'punish'||(j+1));
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,
                                item9,item10,
                                item31)
            values (global_v_codempid,'HRPM75X',v_count_row,
                    v_codcomp,
                    v_dep,
                    v_item_dataselect, v_des_tcodpunh,
--                    'OTH', v_des_tcodpunh,
                    get_label_name('HRPM75X',global_v_lang,10),
                    v_punish,
                    get_label_name('HRPM75X_GRAPH',global_v_lang,1));
        end;
        v_count_row := v_count_row + 1;
      end loop;
      begin
        v_codcomp := hcm_util.get_string_t(v_item_listjson,'codcomp');
        v_dep     := hcm_util.get_string_t(v_item_listjson,'dep');
        v_punish   := hcm_util.get_string_t(v_item_listjson,'punish'||(v_cbtcodpun+1));
        insert into ttemprpt (codempid,codapp,numseq,
                              item4,item5,
                              item7,item8,
                              item9,item10,
                              item31)
            values (global_v_codempid,'HRPM75X',v_count_row,
                    v_codcomp, v_dep,
                    'OTH', get_label_name('HRPM75XC2',global_v_lang,90),
                    get_label_name('HRPM75X',global_v_lang,10),
                    v_punish,
                    get_label_name('HRPM75X_GRAPH',global_v_lang,1));

        v_count_row := v_count_row + 1;
      end;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_graph;

  procedure gen_label(json_str_output out clob) as
    json_obj    json_object_t;
    json_obj2   json_object_t;
    json_obj3   json_object_t;
    json_row    json_object_t;
    json_row2   json_object_t;
    v_count     number := 0;
    v_count2    number := 0;
    v_codcompy  tcenter.codcompy%type;

    cursor c1 is
        select a.*
        from tcodpunh a
        where not exists
        (select b.coddisp from trepdisp b
        where b.coduser = global_v_coduser
        and b.codapp = 'HRPM75X'
        and b.coddisp = a.codcodec)
        order by a.codcodec;
    cursor c2 is
        select  *
        from    trepdisp b
        where   b.coduser = global_v_coduser
        and b.codapp = 'HRPM75X'
        order by b.numseq;
  begin
    json_obj := json_object_t();
    json_obj2 := json_object_t();
    json_obj3 := json_object_t();

    for r1 in c1 loop

            json_row := json_object_t();
            json_row.put('listValue',r1.codcodec);
            json_row.put('listDesc',get_tcodec_name('TCODPUNH',r1.codcodec,global_v_lang));
            json_obj2.put(to_char(v_count),json_row);
            v_count := v_count + 1;

    end loop;
    json_obj3.put('rows',json_obj2);
    json_obj.put('listFields',json_obj3);
    json_obj2 := json_object_t();
    json_obj3 := json_object_t();
    v_count := 0;

    for r2 in c2 loop
            json_row := json_object_t();
            json_row.put('listValue',r2.CODDISP);
            json_row.put('listDesc',get_tcodec_name('TCODPUNH',r2.CODDISP,global_v_lang));
            json_obj2.put(to_char(v_count),json_row);
            v_count := v_count + 1;

    end loop;
    json_obj3.put('rows',json_obj2);
    json_obj.put('formatFields',json_obj3);
    json_obj.put('coderror','200');

     if param_msg_error is null then
    json_str_output := json_obj.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_label;

  procedure get_label(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
  if param_msg_error is null then
    gen_label(json_str_output);
  else
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_label;
end HRPM75X;

/

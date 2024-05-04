--------------------------------------------------------
--  DDL for Package Body HRALS1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRALS1X" as

  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
    v_token       varchar2(4000 char) := '';
    v_token2      varchar2(4000 char) := '';
    v_codleave    json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_monthst           := hcm_util.get_string_t(json_obj,'p_monthst');
    p_monthen           := hcm_util.get_string_t(json_obj,'p_monthen');
    p_typhr             := hcm_util.get_string_t(json_obj,'p_typhr'); -- (1 - 5)
    p_codleave3         := hcm_util.get_string_t(json_obj,'p_codleave');
    --
    begin
      v_codleave        := hcm_util.get_json_t(json_obj,'codleave');
      if v_codleave.get_size = 0 then
        v_codleave := null;
      end if;
    exception when others then
      null;
    end;
    --
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_syncond           := hcm_util.get_string_t(json_obj,'p_syncond');
    --
    if v_codleave is not null then
        p_codleave := '''';
        p_codleave2 := t_codleave();
        for i in 0..(v_codleave.get_size-1) loop
            v_token := hcm_util.get_string_t(v_codleave,to_char(i));
            p_codleave :=  p_codleave || v_token2 ||v_token;
            v_token2 := ',';
            p_codleave2.extend();
            p_codleave2(i+1) := v_token;
            p_codleave2_size := i+1;
        end loop;
        p_codleave := p_codleave || '''';
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function hrmi_to_hr(v_time varchar2) return number as
    v_hr          number;
    v_mi          number;
    v_token       number;
    l_input       varchar2(100 char) := replace(v_time, ':', ',');
    l_count binary_integer;
    l_array dbms_utility.lname_array;
  begin
    if v_time is null then
      return 0;
    else
      dbms_utility.comma_to_table
      ( list   => regexp_replace(l_input,'(^|,)','\1x')
      , tablen => l_count
      , tab    => l_array
      );
      v_hr      := to_number(substr(l_array(1), 2));
      v_mi      := to_number(substr(l_array(2), 2));
      v_token   := 0;
      v_token   := v_token + (v_hr * 60);
      v_token   := v_token + v_mi;
      v_token   := v_token / 60;
      return v_token;
    end if;
  exception when others then
    return 0;
  end;

 procedure gen_graph(obj_row in json_object_t) as
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRALS1X';
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

    v_codleave       varchar2(10 char);
    v_desc_codleave  varchar2(1000 char);
    v_month          varchar2(10 char);
    v_desc_month     varchar2(1000 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;

    v_hours          varchar2(4000 char);
    v_othersleave    varchar2(4000 char);
    v_numseq2        number;
  begin
    v_item31 := get_label_name('HRALS1XC2', global_v_lang, '40');
    begin
      delete
        from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;

    for v_filter in 1..2 LOOP
      if v_filter = 1 then
        for v_row in 1..obj_row.get_size loop
          v_numitem7    := 0;
          obj_data      := hcm_util.get_json_t(obj_row, to_char(v_row - 1));
          v_month       := hcm_util.get_string_t(obj_data,'month');
          v_desc_month  := hcm_util.get_string_t(obj_data,'desc_month');
          v_hours       := hcm_util.get_string_t(obj_data,'hours');
          v_othersleave := hcm_util.get_string_t(obj_data,'othersleave');
          --

          if p_typhr = '6' then
            v_item1       := get_label_name('HRALS1XC2', global_v_lang, '60');
            v_item2       := null;
            v_item3       := null;
            v_item4       := lpad(v_month, 2, '0');
            v_item5       := v_desc_month;
            v_item6       := get_label_name('HRALS1XC2', global_v_lang, '60');
            v_item9       := get_label_name('HRALS1XC2', global_v_lang, '70');
            v_numitem7    := v_numitem7 + 1;
            v_item7       := v_numitem7;
            v_item8       := get_tlistval_name('TYPHR',p_typhr,global_v_lang);
            v_item10      := hrmi_to_hr(v_hours);
            v_item14      := '1';
            --
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

            begin
              v_item14  := '2';
              v_numseq2 := obj_row.get_size*(p_codleave2_size + 2) + (v_row - 1)*(p_codleave2_size + 2) + 1;
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq2,
                 get_label_name('HRALS1XC2', global_v_lang, '100'),
                 v_item2, v_item3, v_item7, v_item8,
                 get_label_name('HRALS1XC2', global_v_lang, '100'),
                 v_item4, v_item5, v_item9, v_item10, v_item31, v_item14);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            v_numseq := v_numseq + 1;

            for i in 1..p_codleave2_size loop
              v_codleave := p_codleave2(i);
              begin
                select codleave, decode(global_v_lang,'101',namleavcde,
                                                      '102',namleavcdt,
                                                      '103',namleavcd3,
                                                      '104',namleavcd4,
                                                      '105',namleavcd5) desc_codleave
                  into v_codleave, v_desc_codleave
                  from tleavecd
                 where codleave = v_codleave;
              exception when no_data_found then
                v_desc_codleave := '';
              end;
              v_numitem7 := v_numitem7 + 1;
              v_item7 := v_numitem7;
              v_item8 := v_desc_codleave;
              v_item10 := hrmi_to_hr(hcm_util.get_string_t(obj_data, 'leave' || i));
              v_item14 := '1';
              begin
                insert into ttemprpt
                  (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10 ,item31, item14)
                values
                  (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10 ,v_item31 ,v_item14);
              exception when dup_val_on_index then
                rollback;
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                return;
              end;
              begin
                v_item14      := '2';
                insert into ttemprpt
                  (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                values
                  (v_codempid, v_codapp, v_numseq2 + i,
                   get_label_name('HRALS1XC2', global_v_lang, '100'),
                   v_item2, v_item3, v_item7, v_item8,
                   get_label_name('HRALS1XC2', global_v_lang, '100'),
                   v_item4, v_item5, v_item9, v_item10, v_item31, v_item14);
              exception when dup_val_on_index then
                rollback;
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                return;
              end;

              v_numseq := v_numseq + 1;
            end loop;


            v_numitem7    := v_numitem7 + 1;
            v_item7       := v_numitem7;
            v_item8       := get_label_name('HRALS1XC2',global_v_lang,'90');
            v_item10      := hrmi_to_hr(v_othersleave);
            v_item14      := '1';
            begin
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31 , v_item14);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
            --
            begin
              v_item14      := '2';
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq2 + p_codleave2_size + 1,
                 get_label_name('HRALS1XC2', global_v_lang, '100'),
                 v_item2, v_item3, v_item7, v_item8,
                 get_label_name('HRALS1XC2', global_v_lang, '100'),
                 v_item4, v_item5, v_item9, v_item10, v_item31, v_item14);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
          else
            v_item1       := '';
            v_item2       := '';
            v_item3       := '';
            v_item4       := lpad(v_month, 2, '0');
            v_item5       := v_desc_month;
            v_item6       := get_label_name('HRALS1XC2', global_v_lang, '60');
            v_item9       := get_label_name('HRALS1XC2', global_v_lang, '70');
            v_numitem7    := v_numitem7 + 1;
            v_item7       := v_numitem7;
            v_item8       := get_tlistval_name('TYPHR',p_typhr,global_v_lang);
            v_item10      := hrmi_to_hr(v_hours);
            v_item14      := '';
            --
            begin
              insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14);
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
          end if;
          v_numseq := v_numseq + 1;
        end loop;
      end if;
    end loop;
  end gen_graph;

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

  procedure check_index as
  begin
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_monthst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_monthen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_monthst > p_monthen then
        param_msg_error := get_error_msg_php('HR2029',global_v_lang);
        return;
    end if;
    if p_typhr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    type t_leave is table of varchar2(4000 char);
    type r_codcalen is record (
      codcalen varchar2(4000 char),
      syncond  varchar2(4000 char));
    type t_codcalen is table of r_codcalen;
    v_typleave t_leave := t_leave();
    v_codcalen t_codcalen;
    v_count     number := 0;
    v_count_leave number := 0;
    v_size1     number;
    v_size2     number;
    v_token     number;
    v_token2    varchar2(4000 char);
    json_obj    json_object_t := json_object_t();
    json_obj2   json_object_t := json_object_t();
    json_obj3   json_object_t := json_object_t();
    json_row    json_object_t := json_object_t();
    obj_data    json_object_t := json_object_t();
    v_first     boolean;
    v_syncond   varchar2(4000 char);
    v_flg_data  varchar2(1 char) := 'N';
    v_stmt      varchar2(4000 char);
    v_stmt2     varchar2(4000 char) :=
    ' and 0 <> (select count(ts.codcomp)
                from tusrcom ts
                where ts.coduser = ''' || global_v_coduser ||'''
                and b.codcomp like ts.codcomp || ''%''
                and rownum <= 1 )
     and b.numlvl between ' || to_char(global_v_zminlvl) || ' and ' || to_char(global_v_zwrklvl);
    v_min number;
  begin
    v_count := 0;
    v_codcalen := t_codcalen();
    v_codcalen.extend();
    v_codcalen(v_count+1).codcalen := p_codcalen;
    v_codcalen(v_count+1).syncond  := p_syncond;
    v_count := v_count + 1;
    v_size2 := v_count-1;
    v_count := 0;
    v_flg_data := 'N';
    v_count := 0;
    json_obj := json_object_t();
    for i in 0..v_size2 loop
        v_syncond := nvl(v_codcalen(i+1).syncond,'1 = 1');
        v_syncond := replace(v_syncond,'TEMPLOY1.','b.');
        json_obj3 := json_object_t();
        v_count := 0;
        v_first := true;     
        for j in to_number(p_monthst)..to_number(p_monthen) loop   
            if v_flg_data <> 'Y' then -- secure
              if p_typhr = '1' then
                v_stmt := ' select count(*)
                 from tovrtime a,temploy1 b
                 where a.codempid = b.codempid
                 and '|| v_syncond ||
                ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
                ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
                v_min := execute_qty(v_stmt|| v_stmt2);
                if v_min > 0 then
                      v_flg_data := 'Y';
                end if;
              end if;
              if p_typhr = '2' or p_typhr = '3' or p_typhr = '4' then
                v_stmt := ' select count(*)
                 from tlateabs a,temploy1 b
                 where a.codempid = b.codempid
                 and '|| v_syncond ||
                ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
                ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
                v_min := execute_qty(v_stmt|| v_stmt2);
                if v_min > 0 then
                      v_flg_data := 'Y';
                end if;
              end if;
              if p_typhr = '5' then
                v_stmt := ' select count(*)
                 from tattence a,temploy1 b
                 where a.codempid = b.codempid
                 and '|| v_syncond ||
                ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
                ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) ||
                ''' and (a.typwork = ''W'')';
                v_min := execute_qty(v_stmt|| v_stmt2);
                if v_min > 0 then
                      v_flg_data := 'Y';
                end if;
              end if;
              v_stmt := ' select count(*)
               from tleavetr a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year || '''
               and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt|| v_stmt2);
              if v_min > 0 then
                    v_flg_data := 'Y';
              end if;
        end if;
            json_row := json_object_t();           
            if v_first then
                json_row.put('codcalen',v_codcalen(i+1).codcalen);
                v_first := false;
            end if;        
            if p_typhr = '1' then
              v_stmt := ' select nvl(sum(qtyminot),0)
               from tovrtime a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
              ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('hours',v_token2);
              end if;
            end if;       
            if p_typhr = '2' then
              v_stmt := ' select nvl(sum(qtylate),0)
               from tlateabs a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
              ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('hours',v_token2);
              end if;
            end if;
            if p_typhr = '3' then
              v_stmt := ' select nvl(sum(qtyearly),0)
               from tlateabs a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
              ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('hours',v_token2);
              end if;
            end if;
            if p_typhr = '4' then
              v_stmt := ' select nvl(sum(qtyabsent),0)
               from tlateabs a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
              ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('hours',v_token2);
              end if;
            end if;
            if p_typhr = '5' then
              v_stmt := ' select nvl(sum(qtyhwork),0)
               from tattence a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year ||
              ''' and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) ||
              ''' and (a.typwork = ''W'')';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('hours',v_token2);
              end if;
            end if;
            for k in 1..p_codleave2_size loop
              v_stmt := ' select nvl(sum(qtymin),0)
               from tleavetr a,temploy1 b
               where a.codempid = b.codempid
               and '|| v_syncond ||
              ' and a.codleave = ''' || p_codleave2(k) || '''
               and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year || '''
               and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
              v_min := execute_qty(v_stmt || v_stmt2);
              if v_min <> 0 then
                  hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                  json_row.put('leave' || to_char(k),v_token2);
              else
                  json_row.put('leave'|| to_char(k),'');
              end if;
            end loop;

            json_row.put('leavenum',to_char(p_codleave2_size));
            v_stmt := ' select nvl(sum(qtymin),0)
             from tleavetr a,temploy1 b
             where a.codempid = b.codempid
             and '|| v_syncond ||
            ' and a.codleave not in ' || '(select trim(regexp_substr(' || p_codleave || ',''[^,]+'',1,level)) codleave
             from   dual  connect by level <= regexp_count(' || p_codleave || ','','')+1)' || '
             and to_number(to_char(a.dtework,''yyyy'')) = ''' || p_year || '''
             and to_number(to_char(a.dtework,''mm'')) = ''' || to_char(j) || '''';
            v_min := execute_qty(v_stmt || v_stmt2);
            if v_min <> 0 then
                hcm_util.cal_dhm_hm(0,0,v_min,null,'2',v_token,v_token,v_token,v_token2);
                json_row.put('othersleave',v_token2);
            else
                json_row.put('othersleave',' ');
            end if;
            json_row.put('month',to_char(j));
            json_row.put('codleave',p_codleave);
            json_row.put('desc_month',get_tlistval_name('NAMMTHFUL', j ,global_v_lang)); -- get_tlistval_name('NAMMTHFUL', j ,global_v_lang)
            json_obj3.put(to_char(v_count),json_row);
            --
            if isInsertReport and j = to_number(p_monthen) then
              insert_ttemprpt(json_obj3);
            end if;
            --
            v_count := v_count + 1;
            v_flg_data:='Y';
        end loop;
    end loop;
    if v_flg_data like 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    gen_graph(json_obj3);

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := json_obj3.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
    v_token varchar2(4000 char) := '';
    v_token2 varchar2(4000 char) := '';
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    begin
      json_codcalen_arr  := hcm_util.get_json_t(json_obj,'p_codcalen');
      if json_codcalen_arr.get_size = 0 then
        json_codcalen_arr := null;
      end if;
    exception when others then
      null;
    end;
    --
    begin
      json_codleave_arr          := hcm_util.get_json_t(json_obj,'codleave');
      if json_codleave_arr.get_size = 0 then
        json_codleave_arr := null;
      end if;
    exception when others then
      null;
    end;
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_monthst           := hcm_util.get_string_t(json_obj,'p_monthst');
    p_monthen           := hcm_util.get_string_t(json_obj,'p_monthen');
    p_typhr             := hcm_util.get_string_t(json_obj,'p_typhr');
    p_codleave3         := hcm_util.get_string_t(json_obj,'p_codleave');

    if json_codleave_arr is not null then
        p_codleave := '''';
        p_codleave2 := t_codleave();
        for i in 0..(json_codleave_arr.get_size-1) loop
            v_token := hcm_util.get_string_t(json_codleave_arr,to_char(i));
            p_codleave :=  p_codleave || v_token2 ||v_token;
            v_token2 := ',';
            p_codleave2.extend();
            p_codleave2(i+1) := v_token;
            p_codleave2_size := i+1;
        end loop;
        p_codleave := p_codleave || '''';
    end if;
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_codleave_arr    json_object_t;
    p_codcalen_arr    json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;

      for i in 0..json_codcalen_arr.get_size-1 loop
        p_codcalen_arr      := hcm_util.get_json_t(json_codcalen_arr, to_char(i));
        p_codcalen          := hcm_util.get_string_t(p_codcalen_arr, 'codcalen');
        p_syncond           := hcm_util.get_string_t(p_codcalen_arr, 'syncond');

        gen_index(json_output);
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

  function explode(p_delimiter varchar2, p_string long, p_limit number default 99) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    for i in 1..p_limit loop
      arr_result(i) := null;
    end loop;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    obj_param           json_object_t;
    v_numseq            number := 0;
    v_year              number := 0;
    v_codcalen          varchar2(100 char);
    v_desc_month        varchar2(100 char);
    v_hours             varchar2(100 char);
    v_othersleave       varchar2(100 char);
    v_leave1            varchar2(100 char);
    v_leave2            varchar2(100 char);
    v_leave3            varchar2(100 char);
    v_leave4            varchar2(100 char);
    v_leave5            varchar2(100 char);
    v_leave6            varchar2(100 char);
    v_leave7            varchar2(100 char);
    v_leave8            varchar2(100 char);
    v_leave9            varchar2(100 char);
    v_leave10           varchar2(100 char);
    v_leave11           varchar2(100 char);
    v_leave12           varchar2(100 char);
    v_leave13           varchar2(100 char);
    v_leave14           varchar2(100 char);
    v_leave15           varchar2(100 char);
    v_leave16           varchar2(100 char);
    v_leave17           varchar2(100 char);
    v_leave18           varchar2(100 char);
    v_leave19           varchar2(100 char);
    v_leave20           varchar2(100 char);
    v_codleave          varchar2(100 char);
    v_codleave_length   number := 6;
    arr_result          arr_1d;
    v_desc_codleave     arr_1d;
    o_desc_codleave     arr_1d;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
     -- insert header --
    p_codapp := 'HRALS1X1';
    v_numseq := v_numseq + 1;

    v_year      := hcm_appsettings.get_additional_year;
    v_codleave  := replace(p_codleave, '''');
    arr_result := explode(',', v_codleave, v_codleave_length);

    for i_codleave in 1..v_codleave_length loop
      o_desc_codleave(i_codleave) := get_tleavecd_name(arr_result(i_codleave),global_v_lang);
    end loop;
    for i_codleave in 1..v_codleave_length loop
      v_desc_codleave(i_codleave) := o_desc_codleave(i_codleave);
    end loop;
    --
    begin
      insert
         into ttemprpt
             (
             codempid, codapp, numseq,item1, item2, item3, item4, item5, item6, item7, item8, item9
             )
        values
             ( global_v_codempid, p_codapp, v_numseq,
               nvl((to_char(to_number( p_year)+ v_year)), ' ') || ' / ' || get_tlistval_name('NAMMTHFUL', p_monthst, global_v_lang) || ' - ' || get_tlistval_name('NAMMTHFUL', p_monthen, global_v_lang),
               nvl(get_tlistval_name('TYPHR',p_typhr, global_v_lang), ' '),
               p_codcalen,
               v_desc_codleave(1), v_desc_codleave(2), v_desc_codleave(3), v_desc_codleave(4), v_desc_codleave(5), v_desc_codleave(6)
        );
    exception when others then
      null;
    end;
    -- insert table --
    p_codapp := 'HRALS1X2';
    for i in 0..obj_data.get_size-1 loop
      obj_param     := hcm_util.get_json_t(obj_data, to_char(i));
      v_codcalen    := nvl(hcm_util.get_string_t(obj_param, 'codcalen'), ' ');
      v_desc_month  := nvl(hcm_util.get_string_t(obj_param, 'desc_month'), ' ');
      v_hours       := nvl(hcm_util.get_string_t(obj_param, 'hours'), ' ');
      v_othersleave := nvl(hcm_util.get_string_t(obj_param, 'othersleave'), ' ');
      v_leave1      := nvl(hcm_util.get_string_t(obj_param, 'leave1'), ' ');
      v_leave2      := nvl(hcm_util.get_string_t(obj_param, 'leave2'), ' ');
      v_leave3      := nvl(hcm_util.get_string_t(obj_param, 'leave3'), ' ');
      v_leave4      := nvl(hcm_util.get_string_t(obj_param, 'leave4'), ' ');
      v_leave5      := nvl(hcm_util.get_string_t(obj_param, 'leave5'), ' ');
      v_leave6      := nvl(hcm_util.get_string_t(obj_param, 'leave6'), ' ');
      --re
      v_numseq      := v_numseq + 1;
      begin
        insert
           into ttemprpt
               (
               codempid, codapp, numseq,item1, item2, item3, item4, item5, item6, item7, item8, item9, item10
               )
          values
               ( global_v_codempid, p_codapp, v_numseq,
                 p_codcalen, v_desc_month, v_hours,
                 v_leave1, v_leave2, v_leave3, v_leave4, v_leave5,v_leave6,
                 v_othersleave
          );
      exception when others then
        null;
      end;
    end loop;
  end insert_ttemprpt;

  procedure gen_label(json_str_output out clob) as
    json_obj    json_object_t;
    json_obj2   json_object_t;
    json_obj3   json_object_t;
    json_row    json_object_t;
    json_row2   json_object_t;
    v_count     number := 0;
    v_count2    number := 0;
    v_codleave  tleavecd.codleave%type;
    v_codcompy  tcenter.codcompy%type;
    cursor c1 is
        select  t1.codleave,decode(global_v_lang,'101',t1.namleavcde,
                                                 '102',t1.namleavcdt,
                                                 '103',t1.namleavcd3,
                                                 '104',t1.namleavcd4,
                                                 '105',t1.namleavcd5) desc_codleave
        from    tleavecd t1
        where   t1.codleave not in (select trim(regexp_substr(p_codleave3,'[^,]+',1,level)) codleave
                                    from   dual
                                    connect by level <= regexp_count(p_codleave3,',')+1)
                or p_codleave is null
        order by t1.codleave;
    cursor c2 is
        select  t1.codleave,decode(global_v_lang,'101',t1.namleavcde,
                                                 '102',t1.namleavcdt,
                                                 '103',t1.namleavcd3,
                                                 '104',t1.namleavcd4,
                                                 '105',t1.namleavcd5) desc_codleave
        from    tleavecd t1
        where   t1.codleave     in (select trim(regexp_substr(p_codleave3,'[^,]+',1,level)) codleave
                                    from   dual
                                    connect by level <= regexp_count(p_codleave3,',')+1)
        order by t1.codleave;
  begin
    json_obj := json_object_t();
    json_obj2 := json_object_t();
    json_obj3 := json_object_t();
    v_codleave := null;
    for r1 in c1 loop
      json_row := json_object_t();
      json_row.put('codleave',r1.codleave);
      json_row.put('desc_codleave',r1.desc_codleave);
      json_obj2.put(to_char(v_count),json_row);
      v_count := v_count + 1;
      v_codleave := r1.codleave;
    end loop;
    json_obj3.put('rows',json_obj2);
    json_obj.put('listFields',json_obj3);
    json_obj2 := json_object_t();
    json_obj3 := json_object_t();
    v_count := 0;
    v_codleave := null;
    for r2 in c2 loop
      json_row := json_object_t();
      json_row.put('codleave',r2.codleave);
      json_row.put('desc_codleave',r2.desc_codleave);
      json_obj2.put(to_char(v_count),json_row);
      v_count := v_count + 1;
      v_codleave := r2.codleave;
    end loop;
    json_obj3.put('rows',json_obj2);
    json_obj.put('formatFields',json_obj3);
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_label;

  procedure get_label(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
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
end HRALS1X;

/

--------------------------------------------------------
--  DDL for Package Body HRAPS8X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPS8X" is
-- last update: 29/08/2020 15:17

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    --block b_index

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'codcomp');
    b_index_jobgrade    := hcm_util.get_string_t(json_obj,'jobgrade');
    b_index_salarymin   := to_number(hcm_util.get_string_t(json_obj,'salarymin'));
    b_index_salarymax   := to_number(hcm_util.get_string_t(json_obj,'salarymax'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
      gen_index_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_chksecu       varchar2(1);
    v_salarymin     number;
    v_salarymax     number;
    v_amtmin        number;
    v_amtmax        number;
    v_amtavg        number;
    cs_emp_min      number;
    cs_emp_max      number;
    
    cursor c1 is
        select jobgrade,count(a.codempid) c_emp
          from temploy1 a, temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp||'%'
           and a.staemp in ('1','3')
           and ((v_chksecu = '1' )
			  		or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                     where x.coduser = global_v_coduser
                       and a.codcomp like a.codcomp||'%')
             and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen))
        group by jobgrade
        order by jobgrade;
  begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;
    v_chksecu := '2';
    for i in c1 loop
        v_flgsecu := 'Y';
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        begin
            select amtminsa,amtmaxsa
              into v_salarymin,v_salarymax
              from tsalstr
             where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
               and jobgrade = i.jobgrade
               and dteyreap = (select max(dteyreap)
                                 from tsalstr
                                where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
                                  and jobgrade = i.jobgrade
                                  and trunc(dteyreap) <=  to_number(to_char(trunc(sysdate),'yyyy')));--User37 29/09/2020 stuctor เปลี่ยน trunc(sysdate));
        exception when no_data_found then
            v_salarymin := null;
            v_salarymax := null;
        end;
        obj_data.put('salarymin', to_char(v_salarymin,'fm999,999,990.00'));
        obj_data.put('salarymax', to_char(v_salarymax,'fm999,999,990.00'));
        obj_data.put('salary_avg', to_char((v_salarymin+v_salarymax)/2,'fm999,999,990.00'));
        begin
            select min(stddec(b.amtincom1,a.codempid,v_chken)),max(stddec(b.amtincom1,a.codempid,v_chken)),avg(stddec(b.amtincom1,a.codempid,v_chken))
              into v_amtmin,v_amtmax,v_amtavg
              from temploy1 a, temploy3 b
             where a.codempid = b.codempid
               and a.codcomp like b_index_codcomp||'%'
               and a.staemp in ('1','3')
               and a.jobgrade = i.jobgrade
               and exists (select codcomp from tusrcom x
                         where x.coduser = global_v_coduser
                           and a.codcomp like a.codcomp||'%')
               and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen;
        exception when no_data_found then
            v_amtmin := null;
            v_amtmax := null;
            v_amtavg := null;
        end;
        obj_data.put('amt_min', to_char(v_amtmin,'fm999,999,990.00'));
        obj_data.put('amt_max', to_char(v_amtmax,'fm999,999,990.00'));
        obj_data.put('amt_avg', to_char(round(v_amtavg,2),'fm999,999,990.00'));
        obj_data.put('cnt', i.c_emp);
        if v_salarymin is not null then
            begin
                select count(a.codempid)
                  into cs_emp_min
                  from temploy1 a, temploy3 b
                 where a.codempid = b.codempid
                   and a.codcomp like b_index_codcomp||'%'
                   and a.staemp in ('1','3')
                   and a.jobgrade = i.jobgrade
                   and (stddec(b.amtincom1,a.codempid,v_chken) < v_salarymin
                        and stddec(b.amtincom1,a.codempid,v_chken) > 0)
                   and exists (select codcomp from tusrcom x
                             where x.coduser = global_v_coduser
                               and a.codcomp like a.codcomp||'%')
                   and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen;
            exception when no_data_found then
                cs_emp_min := null;
            end;
        else
            cs_emp_min := null;
        end if;
        obj_data.put('below_min', cs_emp_min);
        if v_salarymax is not null then
            begin
                select count(a.codempid)
                  into cs_emp_max
                  from temploy1 a, temploy3 b
                 where a.codempid = b.codempid
                   and a.codcomp like b_index_codcomp||'%'
                   and a.staemp in ('1','3')
                   and a.jobgrade = i.jobgrade
                   and stddec(b.amtincom1,a.codempid,v_chken) > v_salarymax
                   and exists (select codcomp from tusrcom x
                             where x.coduser = global_v_coduser
                               and a.codcomp like a.codcomp||'%')
                   and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen;
            exception when no_data_found then
                cs_emp_max := null;
            end;
        else
            cs_emp_max := null;
        end if;
        obj_data.put('over_max', cs_emp_max);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_detail_min(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_min(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_min(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    obj_rowmain     json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_year          number;
	v_month         number;
    v_day           number;

    cursor c1 is
        select a.codempid,a.codcomp,a.codpos,a.dteempmt,stddec(b.amtincom1,a.codempid,v_chken) amtincom1
          from temploy1 a, temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp||'%'
           and a.staemp in ('1','3')
           and a.jobgrade = b_index_jobgrade
           and (stddec(b.amtincom1,a.codempid,v_chken) < b_index_salarymin
           and stddec(b.amtincom1,a.codempid,v_chken) > 0)
        order by a.codempid;
  begin
    obj_row := json_object_t();
    --insert into nut values ('b_index_codcomp-'||b_index_codcomp||'-b_index_jobgrade-'||b_index_jobgrade||'-b_index_salarymin-'||b_index_salarymin); commit;
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        --insert into nut values ('codcomp-'||i.codcomp||'-global_v_numlvlsalst-'||global_v_numlvlsalst||'-global_v_numlvlsalen-'||global_v_numlvlsalen); commit;
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_pos',get_tpostn_name(i.codpos,global_v_lang));
            get_service_year(i.dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
            obj_data.put('dteempmt',v_year||'('||v_month||')');
            obj_data.put('amt1',to_char(i.amtincom1,'fm999,999,990.00'));
            obj_data.put('min',to_char(b_index_salarymin,'fm999,999,990.00'));
            obj_data.put('below_min',to_char(b_index_salarymin - i.amtincom1,'fm999,999,990.00'));
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_detail_max(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_max(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_max(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_year          number;
	v_month         number;
    v_day           number;

    cursor c1 is
        select a.codempid,a.codcomp,a.codpos,a.dteempmt,stddec(b.amtincom1,a.codempid,v_chken) amtincom1,a.numlvl
          from temploy1 a, temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp||'%'
           and a.staemp in ('1','3')
           and a.jobgrade = b_index_jobgrade
           and stddec(b.amtincom1,a.codempid,v_chken) > b_index_salarymax;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_pos',get_tpostn_name(i.codpos,global_v_lang));
            get_service_year(i.dteempmt,trunc(sysdate),'Y',v_year,v_month,v_day);
            obj_data.put('dteempmt',v_year||'('||v_month||')');
            obj_data.put('amt1',to_char(i.amtincom1,'fm999,999,990.00'));
            obj_data.put('max',to_char(b_index_salarymax,'fm999,999,990.00'));
            obj_data.put('over_max',to_char(i.amtincom1 - b_index_salarymax,'fm999,999,990.00'));
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
--  procedure get_index_graph(json_str_input in clob, json_str_output out clob) as
--    obj_row json_object_t;
--  begin
--    initial_value(json_str_input);
--    if param_msg_error is null then
--      gen_index_graph(json_str_output);
--    else
--      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--    end if;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
--  end;
  --

  procedure gen_index_graph is
    v_rcnt          number := 1;
    v_chksecu       varchar2(1);
    v_amtavg        number;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPS8X';
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
    cursor c1 is
        select jobgrade,count(a.codempid) c_emp
          from temploy1 a, temploy3 b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp||'%'
           and a.staemp in ('1','3')
           and ((v_chksecu = '1' )
			  		or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                     where x.coduser = global_v_coduser
                       and a.codcomp like a.codcomp||'%')
             and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen))
        group by jobgrade
        order by jobgrade;
  begin
    
    delete ttemprpt where codempid = v_codempid and codapp = v_codapp; commit;
    
    v_item31 := get_label_name('HRAPS8XC1', global_v_lang, '50'); --'จำนวนเงินที่จ่าย' 
    v_chksecu := '2';
    
    for i in c1 loop
        v_item4  := i.jobgrade;
        v_item5  := get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang);
--        v_item7  := i.jobgrade;
        v_item8  := get_tcenter_name(b_index_codcomp,global_v_lang);
        v_item9  := get_label_name('HRAPS8XC1', global_v_lang, '60'); --'เงินเดือนเฉลี่ย (บาท)'; 
        begin
            select avg(stddec(b.amtincom1,a.codempid,v_chken))
              into v_amtavg
              from temploy1 a, temploy3 b
             where a.codempid = b.codempid
               and a.codcomp like b_index_codcomp||'%'
               and a.staemp in ('1','3')
               and a.jobgrade = i.jobgrade
               and exists (select codcomp from tusrcom x
                         where x.coduser = global_v_coduser
                           and a.codcomp like a.codcomp||'%')
               and a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen;
        exception when no_data_found then
            v_amtavg := null;
        end;
        v_item10  := round(v_amtavg,2); --'เงินเดือนเฉลี่ย (บาท)'; 
        
        ----------Insert ttemprpt
        begin
            insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
            values
                (v_codempid, v_codapp, v_rcnt, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
        exception when dup_val_on_index then
            rollback;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
            return;
        end;
        v_rcnt := v_rcnt+1;
    end loop;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/

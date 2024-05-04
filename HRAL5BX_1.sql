--------------------------------------------------------
--  DDL for Package Body HRAL5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5BX" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');

    b_codleave_e        := get_label_name('HRAL5BXC1', global_v_lang, '150');
    b_codleave_l        := get_label_name('HRAL5BXC1', global_v_lang, '160');
    b_codleave_a        := get_label_name('HRAL5BXC1', global_v_lang, '170');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

--//cal_hm_concat
  function cal_hm_concat(p_qtymin number) return varchar2 is
    v_min 	number(2);
    v_hour  number;
    v_hm    varchar2(10);
  begin
    if p_qtymin is not null and p_qtymin > 0 then
        v_hour	:= trunc(p_qtymin / 60,0);
        v_min		:= mod(p_qtymin,60);
        v_hm    := to_char(v_hour,'fm999,999,990')||':'||lpad(to_char(v_min),2,'0');
    else
        v_hm    := '0'||':'||'00';
    end if;
    return(v_hm);
  end;
--//check_index
  procedure check_index is
    v_flgsecu  boolean := true;
  begin
    if b_index_codcomp is not null then
      if length(b_index_codcomp) < 30 then
        b_index_codcomp := b_index_codcomp||'%';
      end if;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
          return;
      end if;
    end if;

    if b_index_codempid is not null then
      begin
        select codempid into b_index_codempid
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if b_index_month is null and b_index_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

  end check_index;
--

--//get_calendar
  procedure get_calendar(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_calendar(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_calendar;
--
--//gen_calendar
  procedure gen_calendar (json_str_output out clob) as
    obj_rows       json_object_t := json_object_t();
    obj_data       json_object_t;
    obj_tmp        json_object_t;

    v_codcomp      tcenter.codcomp%type;
    v_codcalen     temploy1.codcalen%type;
    v_desholdy     tgholidy.desholdye%type;

    v_current_date date;
    v_dtestr       date := to_date('01/01/'||b_index_year,'dd/mm/yyyy');
    v_dteend       date := to_date('31/12/'||b_index_year,'dd/mm/yyyy');

    v_codleave     tleavetr.codleave%type;
    v_typwork      tattence.typwork%type;

    v_codleave_all varchar2(4000 char);
    v_qtymin_all   number;
    v_comma        varchar2(1 char);
    v_comp_holidy tgholidy.codcomp%type;

    v_qtylate      number;
    v_qtyearly     number;
    v_qtyabsent    number;
    v_day          number := 1;
    v_codshift     varchar2(4 char);
    first_date     date;
    end_date       date;
    v_date         date;
    v_row		       number := 0;

    v_traditional_hol     varchar2(1) := 'T';
    v_shutdown_hol        varchar2(1) := 'S';

    v_numofweek           number := 0;
    arr_week_day          typ_char_number;
    arr_week_codshift     typ_char_number;
    arr_week_desc         typ_char_number;
    arr_week_typwork      typ_char_number;

    cursor c_tleavetr is
      select codleave,nvl(sum(qtymin),0) qtymin
        from tleavetr
       where codempid = b_index_codempid
         and dtework  = v_current_date
    group by codleave
    order by codleave;
  begin
    if isInsertReport then
      for d in 1 .. 7 loop
        arr_week_day(d)      := '';
        arr_week_codshift(d) := '';
        arr_week_desc(d)     := '';
        arr_week_typwork(d)  := '';
      end loop;
    end if;

    first_date   := to_date('01/'|| nvl(b_index_month, '01') ||'/'||b_index_year,'dd/mm/yyyy');
    if b_index_month is not null then
      end_date := last_day(first_date);
    else
      end_date := to_date('31/12/'||b_index_year,'dd/mm/yyyy');
    end if;

    begin
      select get_tgholidy_codcomp(codcomp,codcalen,to_number(b_index_year)), codcalen
        into v_codcomp, v_codcalen
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end;
    v_comp_holidy   := get_tgholidy_codcomp(v_codcomp,v_codcalen,b_index_year);

--    for v_count in 0..v_dteend - v_dtestr loop
--      v_current_date := v_dtestr + v_count;
    for i in 0 .. end_date - first_date loop
      v_current_date := to_date(first_date + i);

      v_row          := v_row + 1;
      obj_data       := json_object_t();
	    v_typwork      := '';
  	  v_desholdy     := '';
  	  v_codleave_all := '';
  	  v_qtymin_all   := 0;
  	  v_comma        := '';
      begin -- a??a?#a??a??a? a??a??a??a??a??a??a?'a?sa??a??a?'a??a??a?? (W-a??a??a??a??a??a??a??a??, H-a??a??a??a?<a??a??a??, T-a??a??a??a?<a??a??a??a??a?#a??a??a?za??a??, L-a??a??a??a?Ya??, S-Shutdown)
      	select typwork
      	  into v_typwork
      	  from tattence
      	 where codempid = b_index_codempid
      	   and dtework  = v_current_date;
        for r_tleavetr in c_tleavetr loop
          v_codleave_all := v_codleave_all || v_comma || r_tleavetr.codleave;
          v_qtymin_all   := v_qtymin_all + r_tleavetr.qtymin;
          v_comma        := ',';
        end loop;
      	if v_typwork = 'T' or v_typwork = 'S' then
      	  begin
      	  	select decode(global_v_lang,'101', desholdye,
      	  		                          '102', desholdyt,
      	  		                          '103', desholdy3,
      	  		                          '104', desholdy4,
      	  		                          '105', desholdy5, '')
      	  	  into v_desholdy
      	  	  from tgholidy
      	  	 where codcomp  = v_codcomp
      	  	   and codcalen = v_codcalen
      	  	   and dteyear  = to_number(b_index_year)
      	  	   and dtedate  = v_current_date
      	  	   and typwork  = v_typwork;
      	  exception when no_data_found then
      	  	v_desholdy := get_tlistval_name('TYPWORK',v_typwork,global_v_lang);
      	  end;
      	elsif v_typwork = 'W' then
      	  begin
      	    select nvl(sum(qtylate)  ,0),
                   nvl(sum(qtyearly) ,0),
                   nvl(sum(qtyabsent),0)
              into v_qtylate,
                   v_qtyearly,
                   v_qtyabsent
              from tlateabs
             where codempid = b_index_codempid
               and dtework  = v_current_date;
          exception when no_data_found then
          	v_qtylate   := 0;
            v_qtyearly  := 0;
            v_qtyabsent := 0;
          end;
          if v_qtylate <> 0 then
  	      	v_codleave_all := v_codleave_all || v_comma || 'L';
  	      	v_qtymin_all   := v_qtymin_all + v_qtylate;
  	      	v_comma        := ',';
          end if;
          if v_qtyearly <> 0 then
  	      	v_codleave_all := v_codleave_all || v_comma || 'E';
  	      	v_qtymin_all   := v_qtymin_all + v_qtyearly;
  	      	v_comma        := ',';
          end if;
          if v_qtyabsent <> 0 then
  	      	v_codleave_all := v_codleave_all || v_comma || 'A';
  	      	v_qtymin_all   := v_qtymin_all + v_qtyabsent;
          end if;
      	end if;
      exception when no_data_found then
      	null;
      end;
      if v_codleave_all is not null then
        obj_data.put('codleave' ,v_codleave_all || ' (' || hcm_util.convert_minute_to_hour(v_qtymin_all) || ')');
      end if;
      obj_data.put('typwork'  ,v_typwork);
      obj_data.put('desholdy' ,v_desholdy);
      obj_data.put('dtedate'  ,to_char(v_current_date,'dd/mm/yyyy'));
      obj_data.put('coderror','200');
      --report--
        if isInsertReport then
          if nvl(b_index_month, '99') <> to_char(v_current_date, 'mm') then
            b_index_month      := to_char(v_current_date, 'mm');
            obj_tmp            := json_object_t();
            obj_tmp.put('month1', get_tlistval_name('NAMMTHFUL', to_char(to_number(b_index_month)), global_v_lang));
            obj_tmp.put('month2', get_tlistval_name('NAMMTHABB', to_char(to_number(b_index_month)), global_v_lang));
            obj_tmp.put('year1', to_char(to_number(b_index_year) + to_number(hcm_appsettings.get_additional_year)));
            b_codapp := p_codapp;
            insert_ttemprpt_calendar(obj_tmp);
          end if;

          if v_typwork in (v_traditional_hol,v_shutdown_hol) then
            b_codapp := p_codapp || '2';
            insert_ttemprpt_calendar(obj_data);
          end if;

          v_numofweek := to_number(to_char(v_current_date, 'D'));
          arr_week_day(v_numofweek)      := to_char(v_current_date,'dd');
          arr_week_codshift(v_numofweek) := v_codshift;
          arr_week_desc(v_numofweek)     := v_desholdy;
          arr_week_typwork(v_numofweek)  := v_typwork;

          if v_numofweek = 7 or v_current_date = last_day(v_current_date) then
            b_codapp := p_codapp || '1';
            insert_ttemprpt_emp(arr_week_day, arr_week_codshift, arr_week_desc, arr_week_typwork);
            for d in 1 .. 7 loop
              arr_week_day(d)      := '';
              arr_week_codshift(d) := '';
              arr_week_desc(d)     := '';
              arr_week_typwork(d)  := '';
            end loop;
          end if;
        end if;
        --
      obj_rows.put(to_char(i),obj_data);
    end loop;

    --report--
    if isInsertReport then
      if v_numofweek < 7 then
        for d in (v_numofweek + 1) .. 7 loop
          arr_week_day(d)      := '';
          arr_week_codshift(d) := '';
          arr_week_desc(d)     := '';
          arr_week_typwork(d)  := '';
        end loop;
        b_codapp := p_codapp || '1';
        insert_ttemprpt_emp(arr_week_day, arr_week_codshift, arr_week_desc, arr_week_typwork);
      end if;
    end if;
    --
		json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--
--//get_data_comp
  procedure get_data_comp(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_comp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data_comp;
--
--//gen_data_comp
  procedure gen_data_comp (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row		        number := 0;
    v_codempid	    TEMPLOY1.CODEMPID%TYPE;
    v_codleave      varchar2(1000);
    v_qtylate       number;
    v_qtyearly	    number;
    v_qtyabsent     number;
    v_con           varchar2(10);
    v_dtestr        date;
    v_dteend        number;
    v_typwork       varchar2(1);
    v_codshift      varchar2(4);
    b_index_dtestr  date;
    b_index_dteend  date;
    v_qtymin	      qtymin;

    v_secur         boolean;
    v_flg_found     boolean := false;
    v_flg_secur     boolean := false;
    cursor c1_temploy1 is
       select a.codempid,a.codcomp
         from temploy1 a,
              ((select codempid
                  from tleavetr
                 where dtework between b_index_dtestr and b_index_dteend
                   and codcomp like b_index_codcomp || '%'
                   and qtymin > 0)
            union all
               (select codempid
                  from tlateabs
                 where dtework between b_index_dtestr and b_index_dteend
                   and codcomp like b_index_codcomp || '%'
                   and (qtylate > 0 or qtyearly > 0 or qtyabsent > 0))) b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp || '%'
      group by a.codcomp,a.codempid
      order by a.codcomp,a.codempid;

    cursor c2_tleavetr is
       select codleave,nvl(sum(qtymin),0) qtymin
         from tleavetr
        where codempid = v_codempid
          and dtework  = v_dtestr
     group by codleave
     order by codleave;
  begin
    obj_row := json_object_t();

    b_index_dtestr := to_date('01/'||b_index_month||'/'||b_index_year,'dd/mm/yyyy');
    b_index_dteend := last_day(b_index_dtestr);
    for c1 in c1_temploy1 loop
      v_flg_found := true;
      exit;
    end loop;
    if not v_flg_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlateabs');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;

    for c1 in c1_temploy1 loop
      v_secur := secur_main.secur2(c1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_secur then
        v_flg_secur := true;
        v_codempid := c1.codempid;
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcomp',c1.codcomp);
        obj_data.put('month',lpad(to_char(b_index_month),2,'0'));
        obj_data.put('year',b_index_year);
        obj_data.put('image',get_emp_img(c1.codempid));
        obj_data.put('codempid',c1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(c1.codempid,global_v_lang));
        v_dtestr := b_index_dtestr;
        v_dteend := to_number(to_char(b_index_dteend,'dd'));
        for i in 1..v_dteend loop
          v_qtymin(i) := 0;
          v_codleave := null;
          v_con      := null;
          for c2 in c2_tleavetr loop
              v_codleave := v_codleave||v_con||c2.codleave;
              v_qtymin(i):= v_qtymin(i) + c2.qtymin;
              v_con      := ', ';
          end loop;
          v_qtylate   := 0;
          v_qtyearly  := 0;
          v_qtyabsent := 0;
          begin
            select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0)
              into v_qtylate, v_qtyearly, v_qtyabsent
              from tlateabs
             where codempid = c1.codempid
               and dtework  = v_dtestr;
          exception when no_data_found then null;
          end;
          v_con := ', ';
          if v_qtylate > 0 then
            if v_codleave is not null then
              v_codleave := b_codleave_l||v_con||v_codleave;
            else
              v_codleave := b_codleave_l;
            end if;
            v_qtymin(i) := v_qtymin(i) + v_qtylate;
          end if;
          if v_qtyearly > 0  then
            if v_codleave is not null then
              v_codleave := b_codleave_e||v_con||v_codleave;
            else
              v_codleave := b_codleave_e;
            end if;
            v_qtymin(i) := v_qtymin(i) + v_qtyearly;
          end if;
          if v_qtyabsent > 0 then
            if v_codleave is not null then
              v_codleave := b_codleave_a||v_con||v_codleave;
            else
              v_codleave := b_codleave_a;
            end if;
            v_qtymin(i) := v_qtymin(i) + v_qtyabsent;
          end if;
          begin
            select typwork, codshift
              into v_typwork, v_codshift
              from tattence
             where codempid = c1.codempid
               and dtework  = v_dtestr;
          exception when no_data_found then
            v_typwork  := null;
            v_codshift := null;
          end;
          if v_typwork != 'W' then
            v_codshift := null;
          end if;

          obj_data.put('dtework'||to_char(v_dtestr,'dd'),to_char(v_dtestr,'dd/mm/yyyy'));
          obj_data.put('codleave'||to_char(v_dtestr,'dd'),v_codleave);
          obj_data.put('codshift'||to_char(v_dtestr,'dd'),v_codshift);
          if v_qtymin(i) > 0 then
            obj_data.put('hour'||to_char(v_dtestr,'dd'),cal_hm_concat(v_qtymin(i)));
          else
            obj_data.put('hour'||to_char(v_dtestr,'dd'),'');
          end if;
          obj_data.put('typwork'||to_char(v_dtestr,'dd'),v_typwork);
          v_dtestr := v_dtestr + 1;
        end loop;
        obj_row.put(to_char(v_row-1), obj_data);
      end if;
    end loop;

    if not v_flg_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      return;
    else
			json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data_comp;
--//
  procedure get_data_comp_summary(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_comp_summary(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data_comp_summary;

  procedure gen_data_comp_summary(json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_rcnt_leave        number := 0;
    v_codempid	        varchar2(4000 char);
    b_index_dtestr      date;
    b_index_dteend      date;
    v_qtylate           number := 0;
    v_qtyearly          number := 0;
    v_qtyabsent         number := 0;

    v_secur             boolean;
    v_flg_found         boolean := false;
    v_flg_secur         boolean := false;

    cursor c1_temploy1 is
       select a.codempid,a.codcomp
         from temploy1 a,
              ((select codempid
                  from tleavetr
                 where dtework between b_index_dtestr and b_index_dteend
                   and codcomp like b_index_codcomp
                   and qtymin > 0)
            union all
               (select codempid
                  from tlateabs
                 where dtework between b_index_dtestr and b_index_dteend
                   and codcomp like b_index_codcomp
                   and (qtylate > 0 or qtyearly > 0 or qtyabsent > 0))) b
         where a.codempid = b.codempid
           and a.codcomp like b_index_codcomp
      group by a.codcomp,a.codempid
      order by a.codcomp,a.codempid;

    cursor c2_tleavetr is
       select codleave, get_tleavecd_name(codleave, global_v_lang) desc_codleave, nvl(sum(qtymin),0) qtymin
         from tleavetr
        where codempid = v_codempid
          and dtework  between b_index_dtestr and b_index_dteend
     group by codleave
     order by codleave;
  begin
    obj_row := json_object_t();

    b_index_dtestr := to_date('01/'||b_index_month||'/'||b_index_year,'dd/mm/yyyy');
    b_index_dteend := last_day(b_index_dtestr);

    for c1 in c1_temploy1 loop
      v_flg_found := true;
      exit;
    end loop;
    if not v_flg_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlateabs');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for c1 in c1_temploy1 loop
      v_secur := secur_main.secur2(c1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_secur then
        v_flg_secur := true;
        v_rcnt := v_rcnt + 1;
        v_codempid := c1.codempid;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image',get_emp_img(c1.codempid));
        obj_data.put('codempid',c1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(c1.codempid,global_v_lang));

        obj_data.put('codleave', '');
        obj_data.put('desc_codleave', '');
        obj_data.put('qtyleave', '');

        v_qtylate   := 0;
        v_qtyearly  := 0;
        v_qtyabsent := 0;
        begin
          select nvl(sum(qtylate),0),nvl(sum(qtyearly),0),nvl(sum(qtyabsent),0)
            into v_qtylate, v_qtyearly, v_qtyabsent
            from tlateabs
           where codempid = c1.codempid
             and dtework  between b_index_dtestr and b_index_dteend;
        exception when no_data_found then null;
        end;

        obj_data.put('qtylate'  , cal_hm_concat(nvl(v_qtylate, 0)));
        obj_data.put('qtyearly' , cal_hm_concat(nvl(v_qtyearly, 0)));
        obj_data.put('qtyabsent', cal_hm_concat(nvl(v_qtyabsent, 0)));

        v_rcnt_leave := 0;
        for c2 in c2_tleavetr loop
          v_rcnt := v_rcnt + v_rcnt_leave;
          v_rcnt_leave := v_rcnt_leave + 1;
          obj_data.put('codleave', c2.codleave);
          obj_data.put('desc_codleave', c2.desc_codleave);
          obj_data.put('qtyleave', cal_hm_concat(nvl(c2.qtymin, 0)));

          obj_row.put(to_char(v_rcnt - 1), obj_data);
          obj_data.put('qtylate'  , '');
          obj_data.put('qtyearly' , '');
          obj_data.put('qtyabsent', '');
        end loop;
        if v_rcnt_leave = 0 then
          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end if;
    end loop;
    if not v_flg_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
		json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data_comp_summary;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like p_codapp || '%';
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end clear_ttemprpt;

  procedure initial_report (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempidQuery');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');

    -- set to use
    b_index_month       := lpad(b_index_month, 2, '0');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    b_codapp            := p_codapp;

  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    obj_data          json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
      b_codapp := p_codapp;
      clear_ttemprpt;
      gen_calendar(json_output);

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

  procedure insert_ttemprpt_emp(arr_week_day in typ_char_number, arr_week_codshift in typ_char_number, arr_week_desc in typ_char_number, arr_week_typwork in typ_char_number) is
    v_numseq            number := 0;
    v_item1             ttemprpt.item1%type;    v_item2             ttemprpt.item2%type;    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;    v_item5             ttemprpt.item5%type;    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;    v_item8             ttemprpt.item8%type;    v_item9             ttemprpt.item9%type;
    v_item11            ttemprpt.item11%type;   v_item12            ttemprpt.item12%type;   v_item13            ttemprpt.item13%type;
    v_item14            ttemprpt.item14%type;   v_item15            ttemprpt.item15%type;   v_item16            ttemprpt.item16%type;
    v_item17            ttemprpt.item17%type;
    v_item21            ttemprpt.item21%type;   v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;
    v_item24            ttemprpt.item24%type;   v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;
    v_item27            ttemprpt.item27%type;
    v_item31            ttemprpt.item31%type;   v_item32            ttemprpt.item32%type;   v_item33            ttemprpt.item33%type;
    v_item34            ttemprpt.item34%type;   v_item35            ttemprpt.item35%type;   v_item36            ttemprpt.item36%type;
    v_item37            ttemprpt.item37%type;

  begin
    v_item1  := arr_week_day(1);
    v_item2  := arr_week_day(2);
    v_item3  := arr_week_day(3);
    v_item4  := arr_week_day(4);
    v_item5  := arr_week_day(5);
    v_item6  := arr_week_day(6);
    v_item7  := arr_week_day(7);
    v_item8  := b_index_month;
    v_item9  := b_index_year;

    v_item11 := arr_week_codshift(1);
    v_item12 := arr_week_codshift(2);
    v_item13 := arr_week_codshift(3);
    v_item14 := arr_week_codshift(4);
    v_item15 := arr_week_codshift(5);
    v_item16 := arr_week_codshift(6);
    v_item17 := arr_week_codshift(7);

    v_item21 := arr_week_desc(1);
    v_item22 := arr_week_desc(2);
    v_item23 := arr_week_desc(3);
    v_item24 := arr_week_desc(4);
    v_item25 := arr_week_desc(5);
    v_item26 := arr_week_desc(6);
    v_item27 := arr_week_desc(7);

    v_item31 := arr_week_typwork(1);
    v_item32 := arr_week_typwork(2);
    v_item33 := arr_week_typwork(3);
    v_item34 := arr_week_typwork(4);
    v_item35 := arr_week_typwork(5);
    v_item36 := arr_week_typwork(6);
    v_item37 := arr_week_typwork(7);

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = b_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6,
            item7,  item8,  item9,
            item11, item12, item13, item14, item15, item16,
            item17,
            item21, item22, item23, item24, item25, item26,
            item27,
            item31, item32, item33, item34, item35, item36,
            item37
          )
      values
          (
            global_v_codempid, b_codapp, v_numseq,
            v_item1,  v_item2,  v_item3,  v_item4,  v_item5,  v_item6,
            v_item7,  v_item8,  v_item9,
            v_item11, v_item12, v_item13, v_item14, v_item15, v_item16,
            v_item17,
            v_item21, v_item22, v_item23, v_item24, v_item25, v_item26,
            v_item27,
            v_item31, v_item32, v_item33, v_item34, v_item35, v_item36,
            v_item37
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_emp;

  procedure insert_ttemprpt_calendar(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_item1             ttemprpt.item1%type;
    v_item2             ttemprpt.item2%type;
    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;
    v_item5             ttemprpt.item5%type;
    v_item6             ttemprpt.item6%type;

  begin
    v_item1  := b_index_month;
    v_item2  := b_index_year;
    if b_codapp = 'HRAL5BX' then
      v_item3  := hcm_util.get_string_t(obj_data, 'month1');
      v_item4  := hcm_util.get_string_t(obj_data, 'month2');
      v_item5  := hcm_util.get_string_t(obj_data, 'year1');
      v_item6  := get_tlistval_name('NAMDAYFUL', to_char(to_date('01/' || v_item1 || '/' || v_item2, 'DD/MM/YYYY'), 'D'), global_v_lang);
    else
      v_item3  := hcm_util.get_string_t(obj_data, 'typwork');
      v_item4  := hcm_util.get_string_t(obj_data, 'dtedate');
      v_item4  := to_char(to_date(v_item4, 'dd/mm/yyyy'), 'dd/mm') || '/' || to_char(to_number(to_char(to_date(v_item4, 'dd/mm/yyyy'), 'yyyy')) + to_number(hcm_appsettings.get_additional_year));
      v_item5  := hcm_util.get_string_t(obj_data, 'desholdy');
    end if;

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = b_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    begin
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6
          )
      values
          (
            global_v_codempid, b_codapp, v_numseq,
            v_item1,  v_item2,  v_item3,  v_item4,  v_item5,  v_item6
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_calendar;

end HRAL5BX;

/

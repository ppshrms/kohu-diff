--------------------------------------------------------
--  DDL for Package Body HRAL4IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4IX" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_deffecst1   := to_date(hcm_util.get_string_t(json_obj,'p_deffecst'),'dd/mm/yyyy');
--    b_index_v_othour    := hcm_util.get_string_t(json_obj,'p_othour');
    b_index_typehour    := hcm_util.get_string_t(json_obj,'p_typot'); --user36 TDKU-SM2101 28/07/2021 -->'1'-o.t. Only, '2'-Work+o.t.
    b_index_type_rep    := hcm_util.get_string_t(json_obj,'p_type_rep');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

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

--//min_to_num
  function min_to_num(p_min number) return number is
    v_num		number;
  begin
    v_num := trunc(p_min / 60,0) + (mod(p_min,60) / 100);
    return(v_num);
  end;
--

--check_index
  procedure check_index is
    v_flgsecu 	boolean := true;
    v_min       number;
  begin
    if b_index_codcomp is not null then
      if length(b_index_codcomp) < 21 then
        b_index_codcomp := b_index_codcomp||'%';
      end if;
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
          return;
      end if;
    end if;

    if b_index_codcalen is not null then
      begin
        select codcodec into b_index_codcalen
          from tcodwork
         where codcodec = b_index_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodwork');
        return;
      end;
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
--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
--      if param_msg_error is not null then
--          return;
--      end if;
      if not secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if b_index_deffecst1 is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    /*TDKU
    if b_index_type_rep	= 'O' then
      if b_index_v_othour is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;

    if b_index_v_othour is not null then
      v_min := to_number(substr(to_char(b_index_v_othour,'fm990000.00'),instr(b_index_v_othour,'.')+1));
      if v_min < 1 then
        param_msg_error := get_error_msg_php('HR2015',global_v_lang);
        return;
      end if;
    end if;*/

  end check_index;
--
--//gen_index
  procedure gen_index (json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_result    json_object_t; ----
    v_row		      number := 0;
    v_deffecst    darr;
    v_deffecen    darr;

    v_deffecst_c	date;
    v_deffecen_c	date;
    v_dtestrt		  darr;
		v_dteend		  darr;
    v_dtest			  date;
    v_dteen       date;
    v_qtyminot	  number;
    flg_data      varchar2(1) := 'N';
    flg_othour    varchar2(1) := 'N';
    v_flgsecur    varchar2(1 char) := 'N';
    v_check_secur boolean;
    --<<user36 TDKU-SM2101 28/07/2021
    v_codcompy    temploy1.codcomp%type;
    v_qtyhwork    number;
    v_qtyleave    number;
    v_qtymxotwk   number;
    v_qtymxallwk  number;
    v_deffecst1   date; --user36 TDKU-SM2101 18/08/2021
    -->>user36 TDKU-SM2101 28/07/2021

    cursor c_emp is
      select t1.codempid
        from temploy1 t1,tovrtime t2
       where t2.codempid = t1.codempid
         and t1.codcomp  like nvl(b_index_codcomp,'%')
         and t1.codcalen = nvl(b_index_codcalen,t1.codcalen)
         and t1.codempid = nvl(b_index_codempid,t1.codempid)
         and t2.dtework between v_deffecst_c and v_deffecen_c
    group by t1.codempid
    order by t1.codempid;
  begin
    obj_row := json_object_t();
    --<<user36 TDKU-SM2101 28/07/2021
    if b_index_codempid is not null then
      begin
        select codcomp
        into   v_codcompy
        from   temploy1
        where  codempid = b_index_codempid;
        v_codcompy := hcm_util.get_codcomp_level(v_codcompy,1);
      exception when no_data_found then
        v_codcompy := null;
      end;
    else
      v_codcompy := hcm_util.get_codcomp_level(b_index_codcomp,1);
    end if;
    begin
      select nvl(decode(b_index_typehour,'1',nvl(QTYMXOTWK,0) ,'2',nvl(QTYMXALLWK,0) ,nvl(QTYMXALLWK,0)),0),
             nvl(qtymxotwk,0),nvl(qtymxallwk,0)
      into   b_index_v_othour,
             v_qtymxotwk,v_qtymxallwk
      from   tcontrot
      where  codcompy = v_codcompy
      and    dteeffec = (select max(dteeffec)
                         from  tcontrot
                         where codcompy  = v_codcompy
                         and   dteeffec <= trunc(sysdate));
    exception when no_data_found then
      b_index_v_othour := 0;
      v_qtymxotwk := 0;
      v_qtymxallwk := 0;
    end;
    v_deffecst1 := get_startday(b_index_deffecst1); --user36 TDKU-SM2101 18/08/2021
    -->>user36 TDKU-SM2101 28/07/2021
    if b_index_deffecst1 is not null then
      v_deffecst(1) := v_deffecst1; --user36 TDKU-SM2101 18/08/2021 ||:= to_date(to_char(trunc(b_index_deffecst1,'IW'),'dd/mm/yyyy'),'dd/mm/yyyy');
      v_deffecen(1) := v_deffecst(1)+6;--week1
      v_deffecst(2) := v_deffecen(1)+1;
      v_deffecen(2) := v_deffecst(2)+6;--week2
      v_deffecst(3) := v_deffecen(2)+1;
      v_deffecen(3) := v_deffecst(3)+6;--week3
      v_deffecst(4) := v_deffecen(3)+1;
      v_deffecen(4) := v_deffecst(4)+6;--week4
      v_deffecst(5) := v_deffecen(4)+1;
      v_deffecen(5) := v_deffecst(5)+6;--week5
      v_deffecst(6) := v_deffecen(5)+1;
      v_deffecen(6) := v_deffecst(6)+6;--week6

      for i in 1..6 loop
        --cursor c_emp
        v_dtestrt(i):=	null;
        v_dteend(i)	:=	null;
        v_dtest     :=	null;
        v_dteen   	:=	null;

        v_dtest := v_deffecst(i);
        v_dteen := v_deffecen(i);
        v_dtestrt(i) := v_dtest;
        v_dteend(i)  := v_dteen;
        v_deffecst_c := least(nvl(v_deffecst_c,v_dtest),v_dtest);
        v_deffecen_c := greatest(nvl(v_deffecen_c,v_dteen),v_dteen);
          --
      end loop;
    end if;

    if param_msg_error is null then
      for c1 in c_emp loop
--        flg_data    := 'Y'; --/--
        v_check_secur     := secur_main.secur2(c1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if v_check_secur then
          flg_othour := 'N';
          v_flgsecur := 'Y';
          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(c1.codempid));
          obj_data.put('codempid',c1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(c1.codempid,global_v_lang));
          obj_data.put('othour', b_index_v_othour); ----, b_index_v_othour*60
  --        obj_data.put('othour', hcm_util.convert_minute_to_hour(b_index_v_othour));

          for i in 1..6 loop
            if v_dteend(i) is not null then
              v_qtyminot := 0;
              begin
                select nvl(sum(nvl(qtyminot,0)),0) into v_qtyminot
                  from tovrtime
                 where codempid = c1.codempid
                   and dtework between v_dtestrt(i) and v_dteend(i);
              exception when no_data_found then null;
              end;
              --<<user36 TDKU-SM2101 28/07/2021
              if b_index_typehour = '2' then
                v_qtyhwork := 0;
                begin
                  select nvl(sum(nvl(qtyhwork,0)),0) into v_qtyhwork
                    from tattence
                   where codempid = c1.codempid
                     and dtework between v_dtestrt(i) and v_dteend(i);
                exception when no_data_found then null;
                end;
                v_qtyleave := 0;
                begin
                  select nvl(sum(nvl(qtymin,0)),0) into v_qtyleave
                    from tleavetr
                   where codempid = c1.codempid
                     and dtework between v_dtestrt(i) and v_dteend(i);
                exception when no_data_found then null;
                end;
                v_qtyminot := v_qtyminot + greatest((v_qtyhwork - v_qtyleave) ,0); -- = o.t. min + work min
              end if;
              -->>user36 TDKU-SM2101 28/07/2021
              if v_qtyminot <> 0 then
                obj_data.put('week'||i, v_qtyminot);
  --               obj_data.put('week'||i, hcm_util.convert_minute_to_hour(v_qtyminot));
              else
                obj_data.put('week'||i,'');
              end if;

              if v_qtyminot > b_index_v_othour then
--/--                flg_data    := 'Y';
                flg_othour  := 'Y' ;
                /*v_check_secur     := secur_main.secur2(c1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                if v_check_secur then
                  v_flgsecur := 'Y';
                end if;*/
              /*else
                v_check_secur     := secur_main.secur2(c1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
                if v_check_secur then
                  v_flgsecur := 'Y';
                end if;*/
              end if;
            end if;--v_dteend(i)
          end loop;--1..6

          if b_index_type_rep = 'O' and flg_othour = 'N' then
             flg_othour := 'N' ;
          else
            flg_data :='Y';
            obj_row.put(to_char(v_row-1),obj_data);
          end if;

        end if;
      end loop;-- c_emp
      --<<----
      obj_result := json_object_t();
      obj_result.put('coderror', '200');
      obj_result.put('qtymxotwk', hcm_util.convert_minute_to_hour(v_qtymxotwk));
      obj_result.put('qtymxallwk', hcm_util.convert_minute_to_hour(v_qtymxallwk));
      obj_result.put('table', obj_row);
      -->>----

      if flg_data = 'N' then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tovrtime');
      elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
			json_str_output := obj_result.to_clob; ----obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index_head(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_head(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_head;

  procedure gen_index_head (json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		      number := 0;
    v_deffecst    darr;
    v_deffecen    darr;
    v_deffecst_c	date;
    v_deffecen_c	date;
    v_dtestrt		  darr;
		v_dteend		  darr;
    v_dtest			  date;
    v_dteen       date;
    v_deffecst1   date; ----varchar2(200);

  begin
    obj_row := json_object_t();
    if b_index_deffecst1 is not null then
      /*--user36 TDKU-SM2101 18/08/2021
      begin
        select to_char(trunc(b_index_deffecst1,'IW'),'dd/mm/yyyy')
          into v_deffecst1
          from dual;
      exception when others then
        v_deffecst1 := null;
      end;*/
      v_deffecst1 := get_startday(b_index_deffecst1); --user36 TDKU-SM2101 18/08/2021
      v_deffecst(1) := v_deffecst1; --user36 TDKU-SM2101 18/08/2021 || := to_date(hcm_util.get_date_buddhist_era(to_date(v_deffecst1,'dd/mm/yyyy')),'dd/mm/yyyy');      
      v_deffecen(1) := v_deffecst(1)+6;--week1
      v_deffecst(2) := v_deffecen(1)+1;
      v_deffecen(2) := v_deffecst(2)+6;--week2
      v_deffecst(3) := v_deffecen(2)+1;
      v_deffecen(3) := v_deffecst(3)+6;--week3
      v_deffecst(4) := v_deffecen(3)+1;
      v_deffecen(4) := v_deffecst(4)+6;--week4
      v_deffecst(5) := v_deffecen(4)+1;
      v_deffecen(5) := v_deffecst(5)+6;--week5
      v_deffecst(6) := v_deffecen(5)+1;
      v_deffecen(6) := v_deffecst(6)+6;--week6

      obj_data := json_object_t();
      obj_data.put('coderror','200');

      for i in 1..6 loop
        v_dtest     :=	null;
        v_dteen   	:=	null;
        v_dtest := v_deffecst(i);
        v_dteen := v_deffecen(i);
        obj_data.put('week'||i,(to_char(v_dtest,'dd/mm/yyyy') || ' - ' || to_char(v_dteen,'dd/mm/yyyy')));   --
      end loop;
      obj_row.put(to_char(0),obj_data);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
			json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index_head;

  function get_startday(p_date in date) return date is --user36 TDKU-SM2101 18/08/2021
    v_dtestartweek  date;
    v_codcompy      temploy1.codcomp%type;
    v_startday      tcontrot.startday%type;
  begin
    --<<user36 TDKU-SM2101 28/07/2021
    if b_index_codempid is not null then
      begin
        select codcomp
        into   v_codcompy
        from   temploy1
        where  codempid = b_index_codempid;
        v_codcompy := hcm_util.get_codcomp_level(v_codcompy,1);
      exception when no_data_found then
        v_codcompy := null;
      end;
    else
      v_codcompy := hcm_util.get_codcomp_level(b_index_codcomp,1);
    end if;
    begin
      select startday
      into   v_startday
      from   tcontrot
      where  codcompy = v_codcompy
      and    dteeffec = (select max(dteeffec)
                         from  tcontrot
                         where codcompy  = v_codcompy
                         and   dteeffec <= trunc(sysdate));
    exception when no_data_found then
      v_startday := 0; 
    end;
    --<<user36 TDKU-SM2101 18/08/2021
    if nvl(v_startday,0) > 0 then
--      next_day(trunc(b_index_deffecst1,'IW'),v_startday);
      begin
        select next_day(p_date,v_startday) - 7 -- - 7 forbackward 1 week
          into v_dtestartweek
          from dual;
      exception when no_data_found then
        v_dtestartweek := null;
      end;
    else
      v_dtestartweek := to_date(to_char(trunc(p_date,'IW'),'dd/mm/yyyy'),'dd/mm/yyyy'); --If not set startday, default Monday.
    end if;
    return v_dtestartweek;
  end;

end HRAL4IX;

/

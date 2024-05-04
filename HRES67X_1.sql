--------------------------------------------------------
--  DDL for Package Body HRES67X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES67X" AS

  -- last update: 26/07/2016 08:33
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    p_start             := hcm_util.get_string_t(json_obj,'p_start');
    p_end               := hcm_util.get_string_t(json_obj,'p_end');
    p_limit             := hcm_util.get_string_t(json_obj,'p_limit');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_stdate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    b_index_endate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');

  end initial_value;
  --

  procedure get_index_tab1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_time          varchar2(1000 char);
    v_comma         varchar2(1000 char);
    v_dtework       date;
    v_item7         varchar2(4000 char);
    v_item8         varchar2(4000 char);
    v_item9         varchar2(4000 char);
    v_item10        varchar2(4000 char);
    v_item11        varchar2(4000 char);
    v_item12        varchar2(4000 char);
    v_item13        varchar2(4000 char);

    cursor c1 is
      select  dtework,codcalen,typwork,codshift,
                  timstrtw,timendw,timin,timout
           from  tattence
           where codempid = b_index_codempid
           and   dtework between b_index_stdate and b_index_endate
           order by dtework;

    cursor c2  is
        select timtime
        from   tatmfile
        where  (codempid = b_index_codempid or codbadge  = b_index_codempid)
        and    dtedate   = v_dtework
        order by dtetime ;
  begin

    --total
    begin
      select count(*)
        into v_total
        from tattence
       where codempid = b_index_codempid
         and dtework between b_index_stdate and b_index_endate;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
      --
      begin
        select substr(timstrtw,1,2)||':'||substr(timstrtw,3,2)||' - '
               ||substr(timendw,1,2)||':'||substr(timendw,3,2)
          into v_time
          from tshiftcd
          where codshift = i.codshift;
        exception when no_data_found then v_time := ' ';
      end;
      --
      v_dtework     := i.dtework;
      v_item7       := to_char(i.dtework,'dd/mm/yyyy');
      v_item8       := i.codcalen;
      v_item9       := i.codshift||'  '||v_time;
      v_item10      := get_tlistval_name('TYPWRKFUL',i.typwork,global_v_lang);
      v_item11      := call_formattime(i.timstrtw)||' - '||call_formattime(i.timendw);
      v_item12      := call_formattime(i.timin)||' - '||call_formattime(i.timout);
      v_comma       := null ;
      v_item13      := '';
      --
      for j in c2 loop
        v_item13 := v_item13||v_comma||substr(j.timtime,1,2)||':'||substr(j.timtime,3,2) ;
        v_comma := ' , ' ;
      end loop;

      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dtework',v_item7);
      obj_data.put('codcalen',v_item8);
      obj_data.put('shift',v_item9);
      obj_data.put('typwork',v_item10);
      obj_data.put('stime',v_item11);
      obj_data.put('etime',v_item12);
      obj_data.put('atmtime',v_item13);

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;
    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_index_tab2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab2 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_time          varchar2(1000 char);
    v_comma         varchar2(1000 char);
    v_item7         varchar2(4000 char);
    v_item8         varchar2(4000 char);
    v_item9         varchar2(4000 char);
    v_item10        varchar2(4000 char);
    sum_qtyminot    number := 0;

    cursor c1 is
      select dtework,codleave,timstrt,timend,
             trunc(QTYMIN/60)||':'||to_char(mod(QTYMIN,60),'fm00') QTYMIN,
             QTYMIN QTYMIN2
        from  tleavetr
        where codempid = b_index_codempid
        and   dtework between b_index_stdate  and b_index_endate
        order by dtework;

  begin
    --total
    begin
      select count(*)
        into v_total
        from tleavetr
       where codempid = b_index_codempid
         and dtework between b_index_stdate and b_index_endate;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for k in c1 loop
      --
      v_item7  := to_char(k.dtework,'dd/mm/yyyy');
      v_item8  := k.codleave||'   '||get_tleavecd_name(k.codleave,global_v_lang);
      v_item9  := call_formattime(k.timstrt)||' - '||call_formattime(k.timend);
      --
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dtework',v_item7);
      obj_data.put('codleave',v_item8);
      obj_data.put('leave_hrs',v_item9);
      obj_data.put('qtyminot',k.QTYMIN2);
      sum_qtyminot := sum_qtyminot + k.QTYMIN2;
      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

--    if v_rcnt > 0 then
--      v_rcnt := v_rcnt+1;
--
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('desc_coderror', ' ');
--      obj_data.put('httpcode', '');
--      obj_data.put('flg', '');
--      obj_data.put('total', v_total);
--      obj_data.put('rcnt', v_rcnt);
--      obj_data.put('leave_hrs', get_label_name('HRES67XC2',global_v_lang,70));
--      obj_data.put('qtyminot',trunc(sum_qtyminot/60)||':'||to_char(mod(sum_qtyminot,60),'fm00'));
--
--      obj_row.put(to_char(v_rcnt-1),obj_data);
--    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index_tab3(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab3 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_time          varchar2(1000 char);
    v_comma         varchar2(1000 char);
    v_item7         varchar2(4000 char);
    v_item8         varchar2(4000 char);
    v_item9         varchar2(4000 char);
    v_item10        varchar2(4000 char);
    v_item11        varchar2(4000 char);
    v_item12        varchar2(4000 char);
    v_item13        varchar2(4000 char);
--    v_item14        varchar2(4000 char);
--    v_item15        varchar2(4000 char);
    sum_qtylate     number := 0;
    sum_qtyearly    number := 0;
    sum_qtyabsent   number := 0;

    cursor c1 is
      select  a.dtework,trunc(qtylate/60)||':'||to_char(mod(qtylate,60),'fm00') qtylate,
                trunc(qtyearly/60)||':'||to_char(mod(qtyearly,60),'fm00') qtyearly,
                trunc(qtyabsent/60)||':'||to_char(mod(qtyabsent,60),'fm00') qtyabsent,
                b.codshift,b.timstrtw,b.timendw,b.timin,b.timout, a.codempid,
                qtylate qtylate2, qtyearly qtyearly2, qtyabsent qtyabsent2
          from  tlateabs a,tattence b
          where a.codempid = b_index_codempid
          and   a.codempid = b.codempid
          and   a.dtework  = b.dtework
          and   a.dtework between b_index_stdate  and b_index_endate
          order by a.dtework;
  begin

    --total
    begin
      select count(*)
        into v_total
        from tlateabs a,tattence b
       where a.codempid = b_index_codempid
         and a.codempid = b.codempid
         and a.dtework  = b.dtework
         and  a.dtework between b_index_stdate  and b_index_endate;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for j in c1 loop
      --
      v_item7    := to_char(j.dtework,'dd/mm/yyyy');
      v_item11   := j.qtylate2;
      v_item12   := j.qtyearly2;
      v_item13   := j.qtyabsent2;


      sum_qtylate     := sum_qtylate + j.qtylate2;
      sum_qtyearly    := sum_qtyearly + j.qtyearly2;
      sum_qtyabsent   := sum_qtyabsent + j.qtyabsent2;

      --
      begin
        select substr(timstrtw,1,2)||':'||substr(timstrtw,3,2)||' - '
               ||substr(timendw,1,2)||':'||substr(timendw,3,2)
          into v_time
          from tshiftcd
          where codshift = j.codshift;
        exception when no_data_found then v_time := ' ';
      end;

--        begin
--          select b.rteotpay, nvl(a.qtyminot, b.qtyminot) qtyminot
--            into v_item14, v_item15
--            from tovrtime a, totpaydt b
--           where a.codempid = j.codempid
--             and a.codempid = b.codempid
--             and a.dtework  = b.dtework
--             and a.typot  = b.typot
--             and a.dtework = j.dtework;
--        exception when no_data_found then
--          v_item14 := 0;
--          v_item15 := 0;
--        end;

      --
      v_item8      := j.codshift||'  '||v_time;
      v_item9      := call_formattime(j.timstrtw)||' - '||call_formattime(j.timendw);
      v_item10     := call_formattime(j.timin)||' - '||call_formattime(j.timout);
      --
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dtework',v_item7);
      obj_data.put('shift',v_item8);
      obj_data.put('stime',v_item9);
      obj_data.put('etime',v_item10);
      obj_data.put('qtylate',v_item11);
      obj_data.put('qtyearly',v_item12);
      obj_data.put('qtyabsent',v_item13);
--      obj_data.put('rteotpay',v_item14);
--      obj_data.put('qtyminot',trunc(v_item15/60)||':'||to_char(mod(v_item15,60),'fm00'));

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

--    if v_rcnt > 0 then
--      v_rcnt := v_rcnt+1;
--
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('desc_coderror', ' ');
--      obj_data.put('httpcode', '');
--      obj_data.put('flg', '');
--      obj_data.put('total', v_total);
--      obj_data.put('rcnt', v_rcnt);
--      obj_data.put('etime',get_label_name('HRES67XC2',global_v_lang,70));
--      obj_data.put('qtylate',trunc(sum_qtylate/60)||':'||to_char(mod(sum_qtylate,60),'fm00'));
--      obj_data.put('qtyearly',trunc(sum_qtyearly/60)||':'||to_char(mod(sum_qtyearly,60),'fm00'));
--      obj_data.put('qtyabsent',trunc(sum_qtyabsent/60)||':'||to_char(mod(sum_qtyabsent,60),'fm00'));
--      obj_row.put(to_char(v_rcnt-1),obj_data);
--    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index_tab4(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_tab4(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tab4(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_time          varchar2(1000 char);
    v_comma         varchar2(1000 char);
    v_item7         varchar2(4000 char);
    v_item8         varchar2(4000 char);
    v_item9         varchar2(4000 char);
    v_item10        varchar2(4000 char);
    v_item11        varchar2(4000 char);
    v_item12        varchar2(4000 char);
    v_rteotpay      totpaydt.rteotpay%type;
    v_qtyminot      totpaydt.qtyminot%type;
    sum_qtyminot    number := 0;

    cursor c1 is
      select a.dtework,a.typwork,a.typot,a.timstrt,a.timend, b.rteotpay, nvl(b.qtyminot,a.qtyminot) qtyminot
        from  tovrtime a, totpaydt b
        where a.codempid = b_index_codempid
        and   a.dtework between b_index_stdate  and b_index_endate
        and   a.codempid = b.codempid(+)
        and   a.dtework = b.dtework(+)
        and   a.typot = b.typot(+)
        order by a.dtework,a.typwork,a.typot, b.rteotpay;

  begin

    --total
    begin
      select count(*)
        into v_total
        from tovrtime
       where codempid = b_index_codempid
         and  dtework between b_index_stdate  and b_index_endate;
    exception when no_data_found then
      v_total := 0;
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for l in c1 loop
      v_item7         := to_char(l.dtework,'dd/mm/yyyy');
      v_item8         := get_tlistval_name('TYPWRKFUL',l.typwork,global_v_lang);
      v_item9         := get_tlistval_name('TYPOT',l.typot,global_v_lang);
      v_item10        := call_formattime(l.timstrt)||' - '||call_formattime(l.timend);
      v_item11        := l.rteotpay;
--      v_item12        := trunc(l.qtyminot/60)||':'||to_char(mod(l.qtyminot,60),'fm00');
      v_item12        := l.qtyminot;
      sum_qtyminot  := sum_qtyminot + l.qtyminot;
      --
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total);
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dtework',v_item7);
      obj_data.put('typwork',v_item8);
      obj_data.put('typot',v_item9);
      obj_data.put('stime',v_item10);
      obj_data.put('rteotpay',v_item11);
      obj_data.put('qtyminot',v_item12);

      obj_row.put(to_char(v_rcnt-1),obj_data);
      --next_record;
    end loop;

--    if v_rcnt > 0 then
--      v_rcnt := v_rcnt+1;
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('desc_coderror', ' ');
--      obj_data.put('httpcode', '');
--      obj_data.put('flg', '');
--      obj_data.put('total', v_total);
--      obj_data.put('rcnt', v_rcnt);
--      obj_data.put('rteotpay',get_label_name('HRES67XC2',global_v_lang,70));
--      obj_data.put('qtyminot',trunc(sum_qtyminot/60)||':'||to_char(mod(sum_qtyminot,60),'fm00'));
--
--      obj_row.put(to_char(v_rcnt-1),obj_data);
--    end if;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure check_index is
  begin
    -- check secure
    /*-- ST11 #7491 || 09/05/2022
    if global_v_codempid <> b_index_codempid then
        param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
        if param_msg_error is not null then
          return;
        end if;
    end if;
    */
    if b_index_stdate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_endate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_stdate > b_index_endate  then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;
  --
  function call_formattime(ptime varchar2) return varchar2 is
    v_time varchar2(20);
    hh     varchar2(2);
    mm     varchar2(2);
  begin
    v_time := ptime;
    hh     := substr(v_time,1,2);
    mm     := substr(v_time,3,2);
    if(v_time = '') or (v_time is null)then
      return v_time;
    else
      return (hh || ':' || mm);
    end if;
  end;
  --

END HRES67X;

/

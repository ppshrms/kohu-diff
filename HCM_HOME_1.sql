--------------------------------------------------------
--  DDL for Package Body HCM_HOME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_HOME" AS
-- update 21/09/2022 14:29

  procedure initial_value(json_str_input in clob) is
    json_obj            json_object_t;
  begin
    global_v_prefix_emp := '>>>';
    json_obj        	  := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_year              := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    p_month             := to_number(hcm_util.get_string_t(json_obj,'p_month'));

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');

    p_img           	  := hcm_util.get_string_t(json_obj,'p_img');

    p_grpseq           	:= hcm_util.get_string_t(json_obj,'p_grpseq');
    p_grpnam           	:= hcm_util.get_string_t(json_obj,'p_grpnam');

   	p_grpempid         	:= hcm_util.get_string_t(json_obj,'p_grpempid');
   	p_flgused			      := hcm_util.get_string_t(json_obj,'p_flgused');
   	p_layoutcol			    := hcm_util.get_string_t(json_obj,'p_layoutcol');
   	p_layoutrow		      := hcm_util.get_string_t(json_obj,'p_layoutrow');
  	p_layoutposition	  := hcm_util.get_string_t(json_obj,'p_layoutposition');
    p_codwg				      := hcm_util.get_string_t(json_obj,'p_codwg');
    p_temphead_codempid	:= hcm_util.get_temphead_codempid(global_v_codempid, global_v_prefix_emp);
    p_codcomp_level		  := hcm_util.get_codcomp_level(p_codcomp, 1);
    p_codapp			      := hcm_util.get_string_t(json_obj,'p_codapp');
    p_comlevel          := hcm_util.get_string_t(json_obj,'p_complvl');

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  function get_calendar(json_str_input in clob) return clob is
    json_str_output   clob;
    v_dtestrt         date;
    v_dteend          date;
    v_dtework         date;
    v_row             number;
    v_row_event       number;
    v_flgdata         boolean;
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_events    json_object_t;
    obj_data_events   json_object_t;

    cursor c_holiday is
      select  decode(global_v_lang ,'101',desholdye
                                   ,'102',desholdyt
                                   ,'103',desholdy3
                                   ,'104',desholdy4
                                   ,'105',desholdy5)  title,
              ''                                      qtymin,
              decode(global_v_lang ,'101',desholdye
                                   ,'102',desholdyt
                                   ,'103',desholdy3
                                   ,'104',desholdy4
                                   ,'105',desholdy5)  remark,
              ''                                      place,
              to_char(hol.dtedate, 'dd/mm/yyyy')      dtestrt,
              to_char(hol.dtedate, 'dd/mm/yyyy')      dteend,
              ''                                      timstrt,
              ''                                      timend
         from   temploy1 emp, tattence att, tgholidy hol
        where   emp.codempid = global_v_codempid
          and   emp.codempid = att.codempid
          and   att.typwork in ('H','T','S')
          and   att.dtework = hol.dtedate
          and   att.codcalen = hol.codcalen
          and   hol.codcomp = get_tgholidy_codcomp(att.codcomp,att.codcalen,to_char(v_dtework,'yyyy'))
          and   hol.dtedate = v_dtework;

    cursor c_leave is
      select * from (
        select get_tleavecd_name(a.codleave,global_v_lang)                  title,
               a.staappr                                                    qtymin,
               a.deslereq                                                   remark,
               get_tlistval_name('ESSTAREQ',trim(a.staappr),global_v_lang)  place,
               to_char(a.dtestrt,'dd/mm/yyyy')                              dtestrt,
               to_char(a.dteend,'dd/mm/yyyy')                               dteend,
               a.timstrt,
               a.timend
          from tleaverq a
         where a.codempid = global_v_codempid
           and v_dtework between trunc(a.dtestrt) and trunc(a.dteend)
           and staappr in ('P', 'A')
        union
        select get_tleavecd_name(a.codleave,global_v_lang)      title,
               'Y'                                              qtymin,
               deslereq                                         remark,
               get_tlistval_name('ESSTAREQ','Y',global_v_lang)  place,
               to_char(b.dtestrt,'dd/mm/yyyy')                  dtestrt,
               to_char(b.dteend,'dd/mm/yyyy')                   dteend,
               a.timstrt,
               a.timend
          from tlereqd a ,tlereqst b
         where a.numlereq = b.numlereq(+)
           and a.codempid = global_v_codempid
           and b.stalereq <> 'C'
           and a.dayeupd is null
           and v_dtework between trunc(b.dtestrt) and trunc(b.dteend)
        union
        select get_tleavecd_name(codleave,global_v_lang)        title,
               'Y'                                              qtymin,
               deslereq                                         remark,
               get_tlistval_name('ESSTAREQ','Y',global_v_lang)  place,
               to_char(dtework,'dd/mm/yyyy')                    dtestrt,
               to_char(dtework,'dd/mm/yyyy')                    dteend,
               timstrt,
               timend
          from tleavetr
         where codempid = global_v_codempid
           and dtework  = v_dtework
      )
      order by timstrt,timend;

    cursor c_appointment is
      select get_tlistval_name('TYPAPPTY', a.TYPAPPTY, global_v_lang) title,
             ''                                                       qtymin,
             a.descnote                                               remark,
             a.location                                               place,
             to_char(a.dteappoi,'dd/mm/yyyy')                         dtestrt,
             to_char(a.dteappoi,'dd/mm/yyyy')                         dteend,
             a.timappoi                                               timstrt,
             ''                                                       timend
        from tappoinf a,tapplinf b,tappoinfint c
       where a.numappl  = c.numappl(+)
         and a.numreqrq = c.numreqrq(+)
         and a.codposrq = c.codposrq(+)
         and a.numapseq = c.numapseq(+)
         and c.codempts = global_v_codempid
         and a.numappl  = b.numappl(+)
         and a.dteappoi = v_dtework
    order by a.dteappoi,a.numappl,a.numapseq;

    cursor c_training is
      select get_tcourse_name(p.codcours, global_v_lang)  title,
             ''                                           qtymin,
             y.remark                                     remark,
             get_thotelif_name(y.CODHOTEL, global_v_lang) place,
             to_char(p.dtetrst,'dd/mm/yyyy')              dtestrt,
             to_char(p.dtetren,'dd/mm/yyyy')              dteend,
             y.timestr                                    timstrt,
             y.timeend                                    timend
        from tpotentp p, tyrtrsch y
       where p.codempid = global_v_codempid
         and p.codcours = y.codcours(+)
         and p.dteyear  = y.dteyear(+)
         and p.numclseq = y.numclseq(+)
         and p.staappr  = 'Y'
         and p.dtetrst is not null
         and v_dtework between trunc(p.dtetrst) and trunc(p.dtetren)
      order by p.codcours, p.numclseq;

      Cursor c_todolist is
        select  to_char(todo.dtework, 'dd/mm/yyyy') dtework,
                todo.NUMSEQ                         numseq,
                todo.TIMSTRT                        timstrt,
                todo.TIMEND                         timend,
                todo.TITLE                          title,
                todo.DETAIL                         detail,
                todo.FLGCHK                         flgchk
         from   ttodolist todo
        where   todo.codempid = global_v_codempid
          and   todo.dtework = v_dtework
        order by todo.numseq;

  begin
    initial_value(json_str_input);

    v_dtestrt := to_date('01/'||p_month||'/'||p_year,'dd/mm/yyyy');
    v_dteend  := last_day(v_dtestrt);

    v_row := 0;
    obj_row := json_object_t();
    v_dtework := v_dtestrt;
    while v_dtework <= v_dteend
    loop
      v_flgdata       := false;
      v_row_event     := 0;
      obj_row_events  := json_object_t();

      for r_holiday in c_holiday loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type','holiday');
        obj_data_events.put('numtype','1');
        obj_data_events.put('title',r_holiday.title);
        obj_data_events.put('qtymin',r_holiday.qtymin);
        obj_data_events.put('remark',r_holiday.remark);
        obj_data_events.put('place',r_holiday.place);
        obj_data_events.put('dtestrt',r_holiday.dtestrt);
        obj_data_events.put('dteend',r_holiday.dteend);
        obj_data_events.put('timstrt',r_holiday.timstrt);
        obj_data_events.put('timend',r_holiday.timend);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      for r_leave in c_leave loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type','leave');
        obj_data_events.put('numtype','2');
        obj_data_events.put('title',r_leave.title);
        obj_data_events.put('qtymin',r_leave.qtymin);
        obj_data_events.put('remark',r_leave.remark);
        obj_data_events.put('place',r_leave.place);
        obj_data_events.put('dtestrt',r_leave.dtestrt);
        obj_data_events.put('dteend',r_leave.dteend);
        obj_data_events.put('timstrt',r_leave.timstrt);
        obj_data_events.put('timend',r_leave.timend);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      for r_appointment in c_appointment loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type','appointment');
        obj_data_events.put('numtype','3');
        obj_data_events.put('title',r_appointment.title);
        obj_data_events.put('qtymin',r_appointment.qtymin);
        obj_data_events.put('remark',r_appointment.remark);
        obj_data_events.put('place',r_appointment.place);
        obj_data_events.put('dtestrt',r_appointment.dtestrt);
        obj_data_events.put('dteend',r_appointment.dteend);
        obj_data_events.put('timstrt',r_appointment.timstrt);
        obj_data_events.put('timend',r_appointment.timend);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      for r_training in c_training loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type','training');
        obj_data_events.put('numtype','4');
        obj_data_events.put('title',r_training.title);
        obj_data_events.put('qtymin',r_training.qtymin);
        obj_data_events.put('remark',r_training.remark);
        obj_data_events.put('place',r_training.place);
        obj_data_events.put('dtestrt',r_training.dtestrt);
        obj_data_events.put('dteend',r_training.dteend);
        obj_data_events.put('timstrt',r_training.timstrt);
        obj_data_events.put('timend',r_training.timend);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      for r_todolist in c_todolist loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type','todolist');
        obj_data_events.put('numtype','5');
        obj_data_events.put('dtestrt',r_todolist.dtework); 
        obj_data_events.put('dteend', r_todolist.dtework);
        obj_data_events.put('numseq', r_todolist.numseq);
        obj_data_events.put('timstrt',r_todolist.timstrt);
        obj_data_events.put('timend', r_todolist.timend);
        obj_data_events.put('title',  r_todolist.title);
        obj_data_events.put('detail', r_todolist.detail);
        obj_data_events.put('flgchk', r_todolist.flgchk);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      if v_flgdata then
        v_row   := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('v_date',to_char(v_dtework,'dd'));
        obj_data.put('v_month',to_char(v_dtework,'mm'));
        obj_data.put('v_year',to_char(v_dtework,'yyyy'));
        obj_data.put('dtedate',to_char(v_dtework,'dd/mm/yyyy'));
        obj_data.put('events',obj_row_events);
        obj_row.put(to_char(v_row-1),obj_data);
      end if;
      v_dtework := v_dtework + 1;
    end loop;

    json_str_output := obj_row.to_clob;

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function count_leave_month return varchar2 is
    v_sday		number;
  begin
    begin
      select sum(qtyday)
      into v_sday
      from tleavetr
      where instr(p_temphead_codempid, global_v_prefix_emp||codempid) > 0
      and dtework  between  to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy') and  last_day(to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy')) ;
    exception when others then
      v_sday := 0;
    end;
    return to_char(v_sday);
  end;

  function count_late_month return varchar2 is
    v_cday		number;
  begin
    begin
      select count(*)
      into v_cday
      from tlateabs tlat, tattence tatt
      where instr(p_temphead_codempid, global_v_prefix_emp||tlat.codempid) > 0
       and tlat.dtework  between  to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy') and  last_day(to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy')) 
       and tlat.qtylate > 0
       and tlat.codempid = tatt.codempid
       and tlat.dtework = tatt.dtework;
    exception when others then
      v_cday := 0;
    end;
    return to_char(v_cday);
  end;

  function count_early_month return varchar2 is
    v_cday		number;
  begin
    begin
      select count(*)
      into v_cday
      from tlateabs tlat, tattence tatt
      where instr(p_temphead_codempid, global_v_prefix_emp||tlat.codempid) > 0
       and tlat.dtework  between  to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy') and  last_day(to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy')) 
       and tlat.qtyearly > 0
       and tlat.codempid = tatt.codempid
       and tlat.dtework = tatt.dtework;
    exception when others then
      v_cday := 0;
    end;
    return to_char(v_cday);
  end;

  function count_absence_month return varchar2 is
    v_sday		varchar2(5000 char);
  begin
    begin
      select hcm_util.convert_minute_to_hour(sum(tlat.qtyabsent))
      into v_sday
      from tlateabs tlat, tattence tatt
      where instr(p_temphead_codempid, global_v_prefix_emp||tlat.codempid) > 0
       and tlat.dtework  between  to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy') and  last_day(to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy')) 
       and tlat.qtyabsent > 0
       and tlat.codempid = tatt.codempid
       and tlat.dtework = tatt.dtework;
    exception when others then
      v_sday := '';
    end;
    return v_sday;
  end;

  function count_ot_month return varchar2 is
    v_sday		varchar2(5000 char);
  begin
    begin
      select hcm_util.convert_minute_to_hour(sum(qtyminot))
      into v_sday
      from tovrtime
      where instr(p_temphead_codempid, global_v_prefix_emp||codempid) > 0
       and dtework  between  to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy') and  last_day(to_date('01'||lpad(p_month,2,'0')||p_year||'','ddmmyyyy')) ;
    exception when others then
      v_sday := '';
    end;
    return v_sday;
  end;

  function get_calendar_manager(json_str_input in clob) return clob is
    json_str_output     clob;
    v_dtestrt           date;
    v_dteend            date;
    v_dtework           date;
    v_row               number;
    v_row_event         number;
    v_flgdata           boolean;
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_row_events      json_object_t;
    obj_data_events     json_object_t;

    r_operate           number;
    r_codempid          clob;
    r_typeabs1          varchar2(100 char):= get_tlistval_name('TYPEABS', '1', global_v_lang);
    r_typeabs2          varchar2(100 char):= get_tlistval_name('TYPEABS', '2', global_v_lang);
    r_typeabs3          varchar2(100 char):= get_tlistval_name('TYPEABS', '3', global_v_lang);
    v_timin             varchar2(10 char);
    v_timout            varchar2(10 char);

    cursor c1 is
      select v_type,
             r_operate operate,
             --
             codempid,
             get_temploy_name(codempid, global_v_lang) title,
             get_tpostn_name(hcm_util.get_temploy_field(codempid, 'codpos'), '102') detail,
             remark, qtymin, timstrt, timend, to_char(dtework, 'dd/mm/yyyy') dtework
        from (
        -- late
        select 'late' v_type,
               tlat.codempid,
               r_typeabs1 || ' : (' || hcm_util.convert_minute_to_hour(tlat.qtylate) || ')' remark,
               --
               tlat.qtylate as qtymin,
               null as timstrt,
               null as timend,
               tlat.dtework
          from tlateabs tlat
         where instr(r_codempid, tlat.codempid) > 0
         --
           and tlat.dtework = v_dtework
           and tlat.qtylate > 0
        union
        -- early
        select 'early' v_type,
               tlat.codempid,
               r_typeabs2 || ' : (' || hcm_util.convert_minute_to_hour(tlat.qtyearly) || ')' remark,
               --
               tlat.qtyearly as qtymin,
               null as timstrt,
               null as timend,
               tlat.dtework
          from tlateabs tlat
         where instr(r_codempid, tlat.codempid) > 0
           and tlat.dtework = v_dtework
           and tlat.qtyearly > 0
        union
        -- absence
        select 'absence' v_type,
               tlat.codempid,
               r_typeabs3 || ' : (' || hcm_util.convert_minute_to_hour(tlat.qtyabsent) || ')' remark,
               --
               tlat.qtyabsent as qtymin,
               null as timstrt,
               null as timend,
               tlat.dtework
          from tlateabs tlat
         where instr(r_codempid, tlat.codempid) > 0
         --
           and tlat.dtework  = v_dtework
           and tlat.qtyabsent > 0
        union
        -- leave
        select 'leave' v_type,
               codempid,
               get_tleavety_name(typleave, global_v_lang) || ' : (' || hcm_util.convert_minute_to_hour(qtymin) || ')' remark,
               qtymin as qtymin,
               timstrt,
               timend,
               dtework
          from tleavetr
         where instr(r_codempid, codempid) > 0
         --
           and dtework = v_dtework      
        union
        -- ot
        select 'ot' v_type,
               codempid,
               get_tlistval_name('TYPOT', typot, global_v_lang) || ' : (' || hcm_util.convert_minute_to_hour(qtyminot) || ')' remark,
               qtyminot as qtymin,
               timstrt,
               timend,
               dtework
          from tovrtime
         where instr( r_codempid , codempid) > 0
         --
            and dtework = v_dtework    
      );

  begin
    initial_value(json_str_input);
    r_operate     := hcm_util.count_temphead_codempid(global_v_codempid);
    r_codempid    := hcm_util.get_temphead_codempid(global_v_codempid);

    v_dtestrt := to_date('01/'||p_month||'/'||p_year,'dd/mm/yyyy');
    v_dteend  := last_day(v_dtestrt);

    v_row := 0;
    obj_row := json_object_t();
    v_dtework := v_dtestrt;

    while v_dtework <= v_dteend
    loop
      v_flgdata       := false;
      v_row_event     := 0;
      obj_row_events  := json_object_t();

      for r1 in c1 loop
        v_row_event := v_row_event + 1;
        v_flgdata := true;
        obj_data_events := json_object_t();
        obj_data_events.put('v_type',r1.v_type);
        obj_data_events.put('operate',r1.operate);
        obj_data_events.put('codempid',r1.codempid);
        obj_data_events.put('title',r1.title);
        obj_data_events.put('detail',r1.detail);
        obj_data_events.put('remark',r1.remark);
        obj_data_events.put('qtymin',r1.qtymin);
        if r1.v_type in ('late','early','absence') then   
          v_timin := null; v_timout := null; 
          begin
            select timin,timout
              into v_timin,v_timout
              from tattence
             where codempid = r1.codempid
               and dtework  = to_date(r1.dtework,'dd/mm/yyyy');
          exception when no_data_found then null;
          end;
          obj_data_events.put('timstrt',v_timin);
          obj_data_events.put('timend',v_timout);          
        else
          obj_data_events.put('timstrt',r1.timstrt);
          obj_data_events.put('timend',r1.timend);
        end if;
        obj_data_events.put('dtework',r1.dtework);
        obj_row_events.put(to_char(v_row_event-1),obj_data_events);
      end loop;

      if v_flgdata then
        v_row   := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('v_date',to_char(v_dtework,'dd'));
        obj_data.put('v_month',to_char(v_dtework,'mm'));
        obj_data.put('v_year',to_char(v_dtework,'yyyy'));
        obj_data.put('dtedate',to_char(v_dtework,'dd/mm/yyyy'));
        obj_data.put('events',obj_row_events);
        obj_row.put(to_char(v_row-1),obj_data);
      end if;
      v_dtework := v_dtework + 1;
    end loop;

    json_str_output := obj_row.to_clob;

    return json_str_output;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function get_announcement(json_str_input in clob) return clob IS
    obj_row 		    json_object_t;
   	obj_data		    json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;

	cursor cl is
  	  select  rowid id,
              get_tcenter_name(codcomp,global_v_lang) company,
              decode(global_v_lang, '101', subjecte,
              						'102', subjectt,
              						'103', subject3,
              						'104', subject4,
              						'105', subject5,subjecte) title,
              decode(global_v_lang, '101', messagee,
              						'102', messaget,
              						'103', message3,
              						'104', message4,
              						'105', message5,messagee) description,
							hcm_util.get_date_buddhist_era(dteeffec) time, to_char(dteeffec,'hh24:mi') time2, numseq, url,
              (select folder from tfolderd where codapp = 'HRCO1BE')||'/'|| filename as attachfile, filename as filenameReal
        from  tannounce
       where  codcomp like p_codcomp_level||'%'
         and trunc(dteeffec) <= trunc(sysdate)
         and (trunc(dteeffecend) >= trunc(sysdate) or dteeffecend is null)
		 and  typemsg ='A'
    order by  dteeffec desc,numseq ;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
  	for rl in cl loop
     if rl.title is not null then
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('id',v_row);
        obj_data.put('company',rl.company);
        obj_data.put('title',rl.title);
        obj_data.put('description',to_clob(rl.description));
        obj_data.put('time',rl.time);
        obj_data.put('time2',rl.time2);
        obj_data.put('attachfile',rl.attachfile);
        obj_data.put('filename',rl.filenameReal);
        obj_data.put('itemno',rl.numseq);
        obj_data.put('url',rl.url);
        obj_data.put('coderror', '200');
        obj_row.put(to_char(v_row-1),obj_data);
     end if;
    end loop; -- end while
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

 function get_knowledge(json_str_input in clob) return clob IS
    obj_row 		    json_object_t;
   	obj_data		    json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;
    v_codcompy          tcompny.codcompy%type;

	cursor cl is
  	  select  rowid  id,
              itemno,
          	  subject title,
              details description,
              (select folder from tfolderd where codapp = 'HRES56E')||'/'|| attfile as attachfile, attfile as attfileReal,
              url,
		      hcm_util.get_date_buddhist_era(dtetrst) time,
              to_char(dtetrst,'hh24:mi') time2
        from  tknowleg
        where codempid = global_v_codempid
          and codcompy = v_codcompy
    order by  dtetrst desc,itemno desc ;

  begin
    initial_value(json_str_input);
    begin
      select get_codcompy(codcomp) into v_codcompy
      from temploy1
      where codempid = global_v_codempid;
    exception when no_data_found then
      v_codcompy := '';
    end;

    obj_row := json_object_t();
  	for rl in cl loop
	    v_row := v_row+1;
	    obj_data := json_object_t();
	    obj_data.put('id',v_row);
	    obj_data.put('itemno',rl.itemno);
	    obj_data.put('title',rl.title);
	    obj_data.put('description',rl.description);
	    obj_data.put('attachfile',rl.attachfile);
      obj_data.put('filename',rl.attfileReal);
	    obj_data.put('url',rl.url);
	    obj_data.put('time' ,rl.time);
	    obj_data.put('time2' ,rl.time2);
	    obj_data.put('coderror', '200');
	    obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end while
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function get_warning(json_str_input in clob) return clob is
  	obj_row 		    json_object_t;
   	obj_data		    json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;

	cursor cl is
  	  select  get_tcenter_name(codcompy, global_v_lang) company,
              decode(global_v_lang, '101', subjecte,
              						'102', subjectt,
              						'103', subject3,
              						'104', subject4,
              						'105', subject5,subjecte) title,
              decode(global_v_lang, '101', messagee,
              						'102', messaget,
              						'103', message3,
              						'104', message4,
              						'105', message5,messagee) message,
              hcm_util.get_date_buddhist_era(dtestrt) strttime,
              hcm_util.get_date_buddhist_era(dteend) endtime
        from  tmessage
       where  codcompy like p_codcomp_level ||'%'
         and  trunc(sysdate) between  trunc(dtestrt) and nvl(trunc(dteend),trunc(sysdate))
    order by  dtestrt desc;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('company',rl.company);
    	obj_data.put('title',rl.title);
    	obj_data.put('message',rl.message);
    	obj_data.put('strttime',rl.strttime);
    	obj_data.put('endtime',rl.endtime);
    	obj_data.put('coderror','200');
    	obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function get_news(json_str_input in clob) return clob is
   	obj_row 		    json_object_t;
   	obj_data		    json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;

	cursor cl is
   	  select  get_tcenter_name(codcomp, global_v_lang) company,
              decode(global_v_lang, '101', subjecte,
              						'102', subjectt,
              						'103', subject3,
              						'104', subject4,
              						'105', subject5,subjecte) title,
              decode(global_v_lang, '101', messagee,
              						'102', messaget,
              						'103', message3,
              						'104', message4,
              						'105', message5,messagee) news,
							decode(dteeffec,trunc(sysdate),to_char(dteeffec, 'hh24:mi'),to_char(dteeffec, 'fmdd Mon')) time,
              (select folder from tfolderd where codapp = 'HRCO1BE2')||'/'|| namimgnews as img, namimgnews as imgReal,
							url
        from  tannounce
       where  codcomp like p_codcomp_level||'%'
         and trunc(dteeffec) <= trunc(sysdate)
         and (trunc(dteeffecend) >= trunc(sysdate) or dteeffecend is null)
		 and  typemsg ='N'
    order by  dteeffec desc,numseq;

  begin
    initial_value(json_str_input);
	  obj_row := json_object_t();
	  for rl in cl loop
      if rl.title is not null then
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('company',rl.company);
      obj_data.put('title',rl.title);
      obj_data.put('news',rl.news);
      obj_data.put('time',rl.time);
      obj_data.put('img',rl.img);
      obj_data.put('namimgnews',rl.imgReal);
      obj_data.put('url',rl.url);
      obj_data.put('coderror','200');
      obj_row.put(to_char(v_row-1),obj_data);
      end if;
      end loop;
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function get_banner(json_str_input in clob) return clob is
    obj_row             json_object_t;
   	obj_data	        json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;
    v_folder            tfolderd.folder%type;
	cursor cl is
	  select  get_tcenter_name(codcompy, global_v_lang) company,
            get_temploy_name(global_v_codempid, global_v_lang) name,
            decode(global_v_lang, '101', welcomemsge,
                                  '102', welcomemsgt,
                                  '103', welcomemsg3,
                                  '104', welcomemsg4,
                                  '105', welcomemsg5, welcomemsge) message,
            namimgcover img,
            namimgmobi imgmobile
      from  tcompny
     where  codcompy like p_codcomp_level||'%';

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('company',rl.company);
      obj_data.put('name',rl.name);
      obj_data.put('message',rl.message);
      if rl.img is not null then
          begin
              select folder into v_folder from tfolderd where codapp = 'HRCO01E2';
              rl.img := v_folder||'/'||rl.img;
          exception when no_data_found then
              v_folder := '';
          end;
      end if;
      if rl.imgmobile is not null then
          begin
              select folder into v_folder from tfolderd where codapp = 'HRCO01E2';
              rl.imgmobile := v_folder||'/'||rl.imgmobile;
          exception when no_data_found then
              v_folder := '';
          end;
      end if;
      obj_data.put('img',rl.img);
      obj_data.put('imgmobile',rl.imgmobile);
      obj_data.put('coderror','200');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

   function get_profile_img(json_str_input in clob) return clob is
    obj_row 		    json_object_t;
   	obj_data		    json_object_t;
    json_obj            json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;

    cursor cl IS
        SELECT (SELECT folder FROM tfolderd WHERE codapp = 'PROFILEIMG')||'/'|| VALUE img
        FROM tusrconfig
        WHERE coduser = global_v_coduser
        AND codvalue = 'PROFILEIMG';

  begin
    initial_value(json_str_input);
    json_obj        	  := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');

    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('img',rl.img);
      obj_data.put('coderror','200');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

  function change_profile_img(json_str_input in clob) return clob is
    obj_row 				json_object_t;
    json_str_output         clob;
   	PRAGMA AUTONOMOUS_TRANSACTION;
  begin
	  initial_value(json_str_input);
    UPDATE tusrconfig
    SET VALUE = p_img
    WHERE coduser = global_v_coduser
    AND codvalue = 'PROFILEIMG';
    if sql%notfound then
      insert into tusrconfig (coduser,codvalue,value)
      values (global_v_coduser,'PROFILEIMG',p_img);
    end if;

    commit;
    obj_row := json_object_t();
    obj_row.put('code','200');
    return obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure insert_group_contact(json_str_input in clob) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_grpname_count		number := 0;
    v_lastseq		    number := 0;
    v_grpseq		    number := 0;
  begin
		initial_value(json_str_input);
		if (upper(p_grpnam) = 'SUBORDINATE') then
				param_msg_error := get_error_msg_php('HR2005',global_v_lang);
				return;
		end if;
		begin
				select max(numseq) into v_lastseq
				from tusrconth
				where CODUSER = global_v_coduser;
		exception when others then
				v_lastseq := 0;
		end;
		v_grpseq := nvl(v_lastseq,0)+1;
		begin
				SELECT DISTINCT count(namgrp)
				INTO v_grpname_count
				FROM tusrconth
				WHERE UPPER(namgrp) LIKE UPPER(p_grpnam)
				and coduser = global_v_coduser;
		exception when no_data_found then
				v_grpname_count := 0;
		end;
		if (v_grpname_count > 0) then
				param_msg_error := get_error_msg_php('HR2005',global_v_lang);
				return;
		else
				insert into tusrconth
				(coduser, numseq, namgrp, dtecreate, codcreate)
				values
				(global_v_coduser, v_grpseq, p_grpnam, sysdate, global_v_coduser);
				commit;
    end if;
  end;

  function create_group_contact(json_str_input in clob) return clob is
    json_str_output clob;
  begin
    insert_group_contact(json_str_input);

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    else
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

 function get_group_contact(json_str_input in clob) return clob is
    json_str_output     clob;
    v_lastseq		    number := 0;
    v_grpseq		    number := 0;
    v_peoplegroup	    number  := 0;
    v_row               number := 0;
    v_child_row         number := 0;
    v_groupseq          tusrconth.numseq%type;
    v_child_obj_data    json_object_t;
    v_child_obj_row     json_object_t;
    v_parent_obj_data   json_object_t;
    v_parent_obj_row    json_object_t;

    cursor c_group is
        select numseq groupseq, namgrp groupname 
          from tusrconth 
         where coduser = global_v_coduser
        union 
        select 0 groupseq,'Subordinate' groupname 
          from dual 
        order by groupseq;

    cursor c_contact is
        select emp.codempid,
               get_tcenter_name(emp.codcomp, global_v_lang) company,
               decode(global_v_lang, '101', emp.namfirste,
                             '102', emp.namfirstt,
                             '103', emp.namfirst3,
                             '104', emp.namfirst4,
                             '105', emp.namfirst5,
                          emp.namfirste) namfirst,
               decode(global_v_lang, '101', emp.namlaste,
                             '102', emp.namlastt,
                             '103', emp.namlast3,
                             '104', emp.namlast4,
                             '105', emp.namlast5,
                          emp.namlaste) namlast,
               get_tpostn_name (emp.codpos, global_v_lang) desc_codpos,
               get_tcenter_name (emp.codcomp,global_v_lang) desc_codcomp,
               emp2.NUMTELEC numtelof,emp.nummobile, emp.email
        ,(select folder from tfolderd where codapp = 'HRPMC2E1')||'/'|| tempimge.namimage img ,tempimge.namimage img_emp,
               decode(global_v_lang, '101', emp.nickname,
                      '102', emp.nicknamt,
                      '103', emp.nicknam3,
                      '104', emp.nicknam4,
                      '105', emp.nicknam5,emp.nickname) nicknam
                 from temploy1 emp
        left join tempimge tempimge
                   on emp.codempid = tempimge.codempid
        left join temploy2 emp2
                on emp.codempid = emp2.codempid
        where instr(p_temphead_codempid, global_v_prefix_emp||emp.codempid) > 0 and v_groupseq = 0 and emp.staemp <> 9
        union
       select emp.codempid,
               get_tcenter_name(emp.codcomp, global_v_lang) company,
               decode(global_v_lang, '101', emp.namfirste,
                             '102', emp.namfirstt,
                             '103', emp.namfirst3,
                             '104', emp.namfirst4,
                             '105', emp.namfirst5,
                          emp.namfirste) namfirst,
               decode(global_v_lang, '101', emp.namlaste,
                             '102', emp.namlastt,
                             '103', emp.namlast3,
                             '104', emp.namlast4,
                             '105', emp.namlast5,
                          emp.namlaste) namlast,
               get_tpostn_name (emp.codpos, global_v_lang) desc_codpos,
               get_tcenter_name (emp.codcomp,global_v_lang) desc_codcomp,
               emp2.NUMTELEC numtelof,emp.nummobile, emp.email
        ,(select folder from tfolderd where codapp = 'HRPMC2E1')||'/'|| tempimge.namimage img ,tempimge.namimage img_emp,
               decode(global_v_lang, '101', emp.nickname,
                      '102', emp.nicknamt,
                      '103', emp.nicknam3,
                      '104', emp.nicknam4,
                      '105', emp.nicknam5,emp.nickname) nicknam
                 from temploy1 emp
        left join tempimge tempimge
                   on emp.codempid = tempimge.codempid
        left join temploy2 emp2
                on emp.codempid = emp2.codempid
        where emp.codempid in(
            select codempid from tusrcontd where coduser = global_v_coduser and numseq = v_groupseq
        ) and emp.staemp <> 9
        order by namfirst;
  begin
    initial_value(json_str_input);
    begin
      select count(*)
      into v_peoplegroup
      from tusrconth
      where coduser = global_v_coduser and namgrp ='people' ;
      exception when others then
      v_peoplegroup := 0;
    end;

    --people not exist
    if v_peoplegroup = 0 THEN
      v_lastseq := 0;
      begin
          select max(numseq) into v_lastseq
          from tusrconth
          where CODUSER = global_v_coduser;
      exception when others then
          v_lastseq := 0;
      end;
      v_grpseq := nvl(v_lastseq,0)+1;

      insert into tusrconth (coduser, numseq, namgrp, dtecreate, codcreate)
      values (global_v_coduser, v_grpseq, 'people', sysdate, global_v_coduser);
      commit;
    end if;

    v_parent_obj_row := json_object_t();
    for r_group in c_group loop
        v_groupseq := r_group.groupseq;
        v_child_obj_row := json_object_t();
        v_child_row := 0;
        for r_contact in c_contact loop
            v_child_row := v_child_row + 1;
            v_child_obj_data := json_object_t();
            v_child_obj_data.put('codempid', r_contact.codempid);
            v_child_obj_data.put('company', nvl(r_contact.company,''));
            v_child_obj_data.put('desc_codcomp', nvl(r_contact.desc_codcomp,''));
            v_child_obj_data.put('desc_codpos', nvl(r_contact.desc_codpos,''));
            v_child_obj_data.put('email', nvl(r_contact.email,''));
            v_child_obj_data.put('img', nvl(r_contact.img,''));
            v_child_obj_data.put('img_emp', nvl(r_contact.img_emp,''));
            v_child_obj_data.put('namfirst', nvl(r_contact.namfirst,''));
            v_child_obj_data.put('namlast', nvl(r_contact.namlast,''));
            v_child_obj_data.put('nicknam', nvl(r_contact.nicknam,''));
            v_child_obj_data.put('nummobile', nvl(r_contact.nummobile,''));
            v_child_obj_data.put('numtelof', nvl(r_contact.numtelof,''));

            v_child_obj_row.put(to_char(v_child_row - 1), v_child_obj_data);
        end loop;
        v_parent_obj_data := json_object_t();
        v_parent_obj_data.put('groupseq',r_group.groupseq);
        v_parent_obj_data.put('groupname',r_group.groupname);
        v_parent_obj_data.put('lists',v_child_obj_row);

        v_row := v_row + 1;
        v_parent_obj_row.put(to_char(v_row - 1),v_parent_obj_data);
    end loop;

    json_str_output := v_parent_obj_row.to_clob;
    return json_str_output;

  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure update_groupname_contact(json_str_input in clob) is
    v_grpname_count	number := 0;
  begin
    initial_value(json_str_input);

    if (upper(p_grpnam) = 'SUBORDINATE') then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
        return;
    end if;
    if (upper(p_grpnam) = 'PEOPLE') then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
        return;
    end if;
    begin
        SELECT DISTINCT count(namgrp)
        INTO v_grpname_count
        FROM tusrconth
        WHERE UPPER(namgrp) LIKE UPPER(p_grpnam)
        and coduser = global_v_coduser
        and numseq <> p_grpseq;
    exception when no_data_found then
        v_grpname_count := 0;
    end;
    if (v_grpname_count > 0) then
        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
        return;
    else
        update 	tusrconth
           set 	namgrp  = p_grpnam
         where 	coduser = global_v_coduser
           and 	numseq  = p_grpseq;
        if sql%rowcount = 0 then
            param_msg_error := 'no_data_found';
        end if;
    end if;
  end;

  function rename_group_contact(json_str_input in clob) return clob is
    json_str_output clob;
  begin
    update_groupname_contact(json_str_input);
    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
        json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure delete_group_contact(json_str_input in clob) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    initial_value(json_str_input);
    delete
      from tusrconth
     where coduser = global_v_coduser
       and numseq  = p_grpseq;
      commit;
    delete
      from tusrcontd
     where coduser = global_v_coduser
       and numseq  = p_grpseq;
    commit;
	exception when others then
    param_msg_error := 'delete failed';
  end;

  function remove_group_contact(json_str_input in clob) return clob is
    json_str_output clob;
  begin
    delete_group_contact(json_str_input);

    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
        json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure insert_member_group_contact(json_str_input in clob,param_grpempid json_object_t) is
    v_grpempid tusrcontd.codempid%type;
  begin
    initial_value(json_str_input);
    for i in 0..param_grpempid.get_size - 1 loop
      v_grpempid   := hcm_util.get_string_t(param_grpempid,to_char(i));
      insert into tusrcontd
      (coduser, numseq, codempid, dtecreate, codcreate)
      values
      (global_v_coduser, p_grpseq, v_grpempid, sysdate, global_v_coduser);
    end loop;
	exception when dup_val_on_index then
    param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tusrcontd');
  end;

  function add_member_group_contact(json_str_input in clob) return clob is
    json_str_output clob;
    json_obj 				json_object_t;
    param_grpempid 	json_object_t;
  begin
    json_obj    := json_object_t(json_str_input);
    param_grpempid  := hcm_util.get_json_t(json_obj,'p_grpempid');
    insert_member_group_contact(json_str_input,param_grpempid);

    if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
        json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure delete_member_group_contact(json_str_input in clob) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_count_people	number := 0;
  begin
    initial_value(json_str_input);

    select count(*)
    into v_count_people
    from tusrconth
    where coduser  = global_v_coduser
    and namgrp = 'people'
    and numseq   = p_grpseq;
    if (v_count_people > 0) then
      delete
          from tusrcontd
          where coduser  = global_v_coduser
          and codempid = p_grpempid;
      commit;
    else
      delete
          from tusrcontd
          where coduser  = global_v_coduser
          and numseq   = p_grpseq
          and codempid = p_grpempid;
      commit;
    end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  function remove_member_group_contact(json_str_input in clob) return clob is
    json_str_output clob;
  begin
    delete_member_group_contact(json_str_input);

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
	return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  function get_empcontact_all(json_str_input in clob) return clob is
   	obj_row 				json_object_t;
   	obj_data				json_object_t;
   	v_row			  		number := 0;
    json_str_output clob;

	cursor cl is
   		  select emp.codempid,
			   get_tcenter_name(emp.codcomp, global_v_lang) company,
               decode(global_v_lang, '101', emp.namfirste,
               						 '102', emp.namfirstt,
               						 '103', emp.namfirst3,
               						 '104', emp.namfirst4,
               						 '105', emp.namfirst5,emp.namfirste) namfirst,
			   decode(global_v_lang, '101', emp.namlaste,
			   						 '102', emp.namlastt,
			   						 '103', emp.namlast3,
			   						 '104', emp.namlast4,
			   						 '105', emp.namlast5,emp.namlaste) namlast,
			   get_tpostn_name (emp.codpos, global_v_lang) desc_codpos,
			   get_tcenter_name (emp.codcomp, global_v_lang) desc_codcomp,
			   emp2.NUMTELEC numtelof,emp.nummobile,emp.email,
			  	(select folder from tfolderd where codapp = 'HRPMC2E1')||'/'|| tempimge.namimage img,tempimge.namimage img_emp
		 from temploy1 emp
		  left join tempimge tempimge
		   on emp.codempid = tempimge.codempid
          left join temploy2 emp2
           on emp.codempid = emp2.codempid
		where emp.codempid in ( select contd.codempid
		          from tusrconth conth
                  left join tusrcontd contd
                    on conth.numseq = contd.numseq
                    and conth.coduser = contd.coduser
		          where conth.coduser = global_v_coduser
                    and conth.namgrp = 'people')
        and emp.staemp <> 9
        order by namfirst;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codempid',rl.codempid);
      obj_data.put('company',rl.company);
      obj_data.put('namfirst',rl.namfirst);
      obj_data.put('namlast',rl.namlast);
      obj_data.put('desc_codpos',rl.desc_codpos);
      obj_data.put('desc_codcomp',rl.desc_codcomp);
      obj_data.put('numtelof',rl.numtelof);
      obj_data.put('nummobile',rl.nummobile);
      obj_data.put('email',rl.email);
      obj_data.put('img',rl.img);
      obj_data.put('img_emp',rl.img_emp);
      obj_data.put('coderror', '200');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_row.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  function get_all_emp(json_str_input in clob) return clob is
   	obj_row 				json_object_t;
   	obj_data				json_object_t;
   	v_row			  		number := 0;
    json_str_output clob;

	cursor cl is
   		  select emp.codempid,
			   get_tcenter_name(emp.codcomp, global_v_lang) company,
               decode(global_v_lang, '101', emp.namfirste,
               						 '102', emp.namfirstt,
               						 '103', emp.namfirst3,
               						 '104', emp.namfirst4,
               						 '105', emp.namfirst5,emp.namfirste) namfirst,
			   decode(global_v_lang, '101', emp.namlaste,
			   						 '102', emp.namlastt,
			   						 '103', emp.namlast3,
			   						 '104', emp.namlast4,
			   						 '105', emp.namlast5,emp.namlaste) namlast,
			   get_tpostn_name (emp.codpos, global_v_lang) desc_codpos,
			   get_tcenter_name (emp.codcomp, global_v_lang) desc_codcomp,
               emp.codcompr desc_codcompr,
			   emp2.NUMTELEC  numtelof,emp.nummobile,emp.email
			  	,(select folder from tfolderd where codapp = 'HRPMC2E1')||'/'|| tempimge.namimage img,tempimge.namimage img_emp              
		 from temploy1 emp
		  left join tempimge tempimge
		   on emp.codempid = tempimge.codempid
          left join temploy2 emp2
           on emp.codempid = emp2.codempid

		where emp.staemp in  ('1','3')
        order by namfirst;

    --getallemp above
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for rl in cl loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('codempid',rl.codempid);
	    obj_data.put('company',rl.company);
	    obj_data.put('namfirst',rl.namfirst);
	    obj_data.put('namlast',rl.namlast);
	    obj_data.put('desc_codpos',rl.desc_codpos);
	    obj_data.put('desc_codcomp',rl.desc_codcomp);
	    obj_data.put('desc_codcompr',rl.desc_codcompr);
        obj_data.put('numtelof',rl.numtelof);
	    obj_data.put('nummobile',rl.nummobile);
	    obj_data.put('email',rl.email);
	    obj_data.put('img',rl.img);
        obj_data.put('img_emp',rl.img_emp);
	    obj_data.put('coderror', '200');
    	obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_row.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  ------------------------------------End Group Contact ---------------------------------------------

  function get_wg_adj_flg(json_str_input in clob) return clob is
    obj_row 		    json_object_t;
   	obj_data		    json_object_t;
   	v_row			    number := 0;
    json_str_output     clob;
    v_codcompy          varchar2(100 char);

--	cursor cl is
--  	  select to_char(codwg) codwg,flgadjust, wgname,positionmetric,flgdefault
--	      from twidget
--       where (case when module = 'STD' then 999 else get_license('', module) end) > 0
--      order by codwg asc;
    cursor cl is
        select to_char(b.codwg) codwg,b.flgadjust, b.wgname,b.positionmetric,b.flgdefault
          from twidgetcom a,twidget b
         where a.codwg    = b.codwg
           and a.codcompy = v_codcompy
           and (case when b.module = 'STD' then 999 else get_license('', b.module) end) > 0
        order by b.codwg asc;

  begin
    initial_value(json_str_input);

    begin
        select hcm_util.get_codcompy(b.codcomp)
          into v_codcompy
          from tusrprof a, temploy1 b
         where a.codempid = b.codempid
           and a.coduser  = global_v_coduser;
    exception when no_data_found then
        v_codcompy := null;
    end;

    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codwg',rl.codwg);
      obj_data.put('flgadjust',rl.flgadjust);
      obj_data.put('wgname',rl.wgname);
      obj_data.put('flgused',rl.flgdefault);
      obj_data.put('positionmetric',rl.positionmetric);
      obj_data.put('coderror','200');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_row.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure get_default_position_wg is
    v_codcompy       varchar2(100 char);

--    cursor cl is
--  		select codwg, flgdefault, positionmetric
--  		from   twidget
--      where (case when module = 'STD' then 999 else get_license('', module) end) > 0;
    cursor cl is
  		select a.codwg, a.flgdefault, b.positionmetric
  		  from twidgetcom a,twidget b
         where a.codwg    = b.codwg
           and a.codcompy = v_codcompy
           and (case when b.module = 'STD' then 999 else get_license('', b.module) end) > 0
        order by b.codwg;
  begin
    begin
        select hcm_util.get_codcompy(b.codcomp)
          into v_codcompy
          from tusrprof a, temploy1 b
         where a.codempid = b.codempid
           and a.coduser  = global_v_coduser;
    exception when no_data_found then
        v_codcompy := null;
    end;

    for r1 in cl loop
      begin
        insert into twidgetusr
        (coduser, codwg, flgused, layoutcol, layoutrow,layoutposition, codcreate)
        values
        (global_v_coduser, to_char(r1.codwg), r1.flgdefault, 0, 0,r1.positionmetric, global_v_coduser);
			exception when dup_val_on_index then
        update twidgetusr
        set flgused        = r1.flgdefault,
            layoutcol      = 0,
            layoutrow      = 0,
            layoutposition = r1.positionmetric
        where coduser      = global_v_coduser
		  and codwg        = to_char(r1.codwg);
      end;
    end loop;
	commit;
  end;

  function delete_all_wg(json_str_input in clob) return clob is
    obj_row 		    json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    delete from twidgetusr where coduser  = global_v_coduser;
    get_default_position_wg;
    commit;
    obj_row := json_object_t();
    obj_row.put('code','200');

    return obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  function change_position_wg(json_str_input in clob) return clob is
    obj_row 		    json_object_t;
    json_str_output clob;
  begin
    initial_value(json_str_input);
    begin
      insert into twidgetusr (coduser,codwg,layoutcol,layoutrow,layoutposition,flgused)
        values(global_v_coduser,p_codwg,0,p_layoutrow,p_layoutposition,p_flgused);
    exception when dup_val_on_index then
      update twidgetusr
         set layoutcol  = 0, -- p_layoutcol
             layoutrow  = p_layoutrow,
             layoutposition = p_layoutposition,
             flgused  = p_flgused
       where coduser  = global_v_coduser
         and codwg    = p_codwg;
    end;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    return json_str_output;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  function get_wg_usr_by_codusr(json_str_input in clob) return varchar2 is
    obj_row         	json_object_t;
    obj_data        	json_object_t;

    json_str_output 	clob;
    v_row           	number  := 0;
    v_extwg			    number  := 0;
    v_inssts		    varchar2(5000 char);

	cursor cl is
  		select to_char(twidgetusr.codwg) codwg,twidget.wgname wgname, flgused, to_char(layoutcol) layoutcol, to_char(layoutrow) layoutrow,layoutposition
		    from twidgetusr,twidget
			 where twidgetusr.codwg = twidget.codwg(+)
  		   and coduser = global_v_coduser
         and (case when twidget.module = 'STD' then 999 else get_license('', twidget.module) end) > 0
    order by twidgetusr.layoutrow asc;
  begin
    initial_value(json_str_input);

    begin
      select count(*)
      into v_extwg
      from twidgetusr
      where coduser = global_v_coduser;
    exception when others then
      v_extwg := 0;
    end;

    --twidgetusr not exist
    if v_extwg = 0 then
			get_default_position_wg;
    end if;

    --get widget position
    obj_row := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codwg',rl.codwg);
      obj_data.put('wgname',rl.wgname);
      obj_data.put('flgused',rl.flgused);
      obj_data.put('layoutcol',rl.layoutcol);
      obj_data.put('layoutrow',rl.layoutrow);
      obj_data.put('layoutposition',rl.layoutposition);
      obj_data.put('coderror','200');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    return obj_row.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  function get_labels(json_str_input in clob) return clob is
  	obj_row 		    json_object_t;
    obj_data_en		    json_object_t;
    obj_data_th		    json_object_t;
    obj_data_103	    json_object_t;
    obj_data_104	    json_object_t;
    obj_data_105	    json_object_t;
    obj_labels	        json_object_t;
    obj_dashboard_en    json_object_t;
    obj_dashboard_th    json_object_t;
    obj_dashboard_103   json_object_t;
    obj_dashboard_104   json_object_t;
    obj_dashboard_105   json_object_t;
   	v_row			    number := 0;
    json_str_output clob;

	cursor cl IS
  	    select desclabele,
               desclabelt,
               desclabel3,
               desclabel4,
               desclabel5,
               numseq
          from tapplscr
         where codapp = upper(p_codapp)
      order by numseq asc;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_data_en  := json_object_t();
    obj_data_th  := json_object_t();
    obj_data_103 := json_object_t();
    obj_data_104 := json_object_t();
    obj_data_105 := json_object_t();
    obj_labels   := json_object_t();
    obj_dashboard_en   := json_object_t();
    obj_dashboard_th   := json_object_t();
    obj_dashboard_103  := json_object_t();
    obj_dashboard_104  := json_object_t();
    obj_dashboard_105  := json_object_t();
    for rl in cl loop
      v_row := v_row + 1;
      obj_dashboard_en.put(to_char(rl.numseq),rl.desclabele);
      obj_data_en.put(upper(p_codapp),obj_dashboard_en);
      obj_dashboard_th.put(to_char(rl.numseq),rl.desclabelt);
      obj_data_th.put(upper(p_codapp),obj_dashboard_th);
      obj_dashboard_103.put(to_char(rl.numseq),rl.desclabel3);
      obj_data_103.put(upper(p_codapp),obj_dashboard_103);
      obj_dashboard_104.put(to_char(rl.numseq),rl.desclabel4);
      obj_data_104.put(upper(p_codapp),obj_dashboard_104);
      obj_dashboard_105.put(to_char(rl.numseq),rl.desclabel5);
      obj_data_105.put(upper(p_codapp),obj_dashboard_105);
    end loop;
    obj_row.put('objLang1',obj_data_en);
    obj_row.put('objLang2',obj_data_th);
    obj_row.put('objLang3',obj_data_103);
    obj_row.put('objLang4',obj_data_104);
    obj_row.put('objLang5',obj_data_105);
    obj_labels.put('labels',obj_row);
    return obj_labels.to_clob;
  exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		return json_str_output;
  end;

  procedure get_atktest(json_str_input in clob,json_str_output out clob) as
    obj_data            json_object_t;
    arr_labels          json_array_t;
    arr_data            json_array_t;
    arr_datasets_atk    json_array_t;
    arr_datasets_pcr    json_array_t;
    arr_datasets_total  json_array_t;
    v_dtetest           tatkpcr.dtetest%type;
    v_count_atk         number := 0;
    v_count_pcr         number := 0;
    v_atk_detected      number := 0;
    v_atk_not_detected  number := 0;
    v_pcr_detected      number := 0;
    v_pcr_not_detected  number := 0;
    v_total_detected    number := 0;

    cursor c_tatkpcr is
        select count(*) count_emp,
               count( case when typetest = '1' and result = 'Y' then 'x' end ) count_atk_y,
               count( case when typetest = '1' and result = 'N' then 'x' end ) count_atk_n,
               count( case when typetest = '2' and result = 'Y' then 'x' end ) count_pcr_y,
               count( case when typetest = '2' and result = 'N' then 'x' end ) count_pcr_n
          from (
            select a.typetest,a.result,a.codempid
              from tatkpcr a,temploy1 b
             where a.codempid = b.codempid
               and a.dtetest  = v_dtetest
               and b.codcomp  like p_codcomp||'%'
               and b.staemp   in ('1','3')
               and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
            group by a.typetest,a.result,a.codempid);

  begin
    initial_value(json_str_input);

    arr_labels          := json_array_t();
    arr_datasets_atk    := json_array_t();
    arr_datasets_pcr    := json_array_t();
    arr_datasets_total  := json_array_t();

    for i in 1..to_number(to_char(last_day(to_date(lpad(p_month,2,'0')||lpad(p_year,4,'0'),'mmyyyy')),'dd')) loop 
        v_dtetest := to_date(lpad(i,2,'0')||'/'||lpad(p_month,2,'0')||'/'||lpad(p_year,4,'0'),'dd/mm/yyyy');
        arr_labels.append(to_char(v_dtetest,'dd/mm/yyyy'));

        v_count_atk := 0;
        v_count_pcr := 0;
        for r_tatkpcr in c_tatkpcr loop
            v_count_atk := r_tatkpcr.count_atk_y;
            v_count_pcr := r_tatkpcr.count_pcr_y;
        end loop;
        arr_datasets_atk.append(v_count_atk);
        arr_datasets_pcr.append(v_count_pcr);
        arr_datasets_total.append(v_count_atk + v_count_pcr);
    end loop;

    v_atk_detected      := 0;
    v_atk_not_detected  := 0;
    v_pcr_detected      := 0;
    v_pcr_not_detected  := 0;
    v_dtetest := trunc(sysdate);
    p_codcomp := '';
    for r_tatkpcr in c_tatkpcr loop
        v_atk_detected      := r_tatkpcr.count_atk_y;
        v_atk_not_detected  := r_tatkpcr.count_atk_n;
        v_pcr_detected      := r_tatkpcr.count_pcr_y;
        v_pcr_not_detected  := r_tatkpcr.count_pcr_n;
    end loop;

    -- total
    begin
        select count(*)
          into v_total_detected
          from (
            select a.result,a.codempid
              from tatkpcr a,temploy1 b
             where a.codempid = b.codempid
               and b.codcomp  like p_codcomp||'%'
               and b.staemp   in ('1','3')
               and result = 'Y'
               and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
            group by a.result,a.codempid);
    exception when others then
        v_total_detected := 0;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', '');
    obj_data.put('dtework', to_char(sysdate,'dd/mm/yyyy'));
    obj_data.put('atkDetected', to_char(v_atk_detected,'fm999,999,990'));
    obj_data.put('atkNotDetected', to_char(v_atk_not_detected,'fm999,999,990'));
    obj_data.put('pcrDetected', to_char(v_pcr_detected,'fm999,999,990'));
    obj_data.put('pcrNotDetected', to_char(v_pcr_not_detected,'fm999,999,990'));
    obj_data.put('totalDetected', to_char(v_total_detected,'fm999,999,990'));
    obj_data.put('labels', arr_labels);

    arr_data := json_array_t();
    arr_data.append(arr_datasets_atk);
    arr_data.append(arr_datasets_pcr);
    arr_data.append(arr_datasets_total);
    obj_data.put('data', arr_data);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function explode(p_delimiter varchar2, p_string varchar2, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
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

  procedure get_atktest_department(json_str_input in clob,json_str_output out clob) as
    obj_data            json_object_t;
    arr_labels          json_array_t;
    arr_labels_temp     json_array_t;
    arr_data            json_array_t;
    arr_datasets_atk    json_array_t;
    arr_datasets_pcr    json_array_t;
    arr_datasets_total  json_array_t;

    arr_label           arr_1d;

    cursor c_tatkpcr is
        select hcm_util.get_codcomp_level(codcomp,p_comlevel) codcomp,
               count( case when typetest = '1' and result = 'Y' then 'x' end ) count_atk_y,
               count( case when typetest = '1' and result = 'N' then 'x' end ) count_atk_n,
               count( case when typetest = '2' and result = 'Y' then 'x' end ) count_pcr_y,
               count( case when typetest = '2' and result = 'N' then 'x' end ) count_pcr_n
          from (
            select a.typetest,a.result,b.codcomp
              from tatkpcr a,temploy1 b
             where a.codempid = b.codempid
               and a.dtetest  between p_dtestrt and p_dteend
               and b.codcomp  like p_codcomp||'%'
               and b.staemp   in ('1','3')
               and hcm_secur.secur2_cursor(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, a.codempid) = 'Y'
            group by a.typetest,a.result,a.codempid,b.codcomp)
        group by hcm_util.get_codcomp_level(codcomp,p_comlevel)
        order by hcm_util.get_codcomp_level(codcomp,p_comlevel);

  begin
    initial_value(json_str_input);

    arr_labels          := json_array_t();
    arr_datasets_atk    := json_array_t();
    arr_datasets_pcr    := json_array_t();
    arr_datasets_total  := json_array_t();
    for r_tatkpcr in c_tatkpcr loop
--        arr_label := explode(' ', get_tcenter_name(r_tatkpcr.codcomp,global_v_lang));
--        for i in 1..arr_label.count loop
--            arr_labels_temp.append(arr_label(i));
--        end loop;
--        arr_labels_temp     := json_array_t();
--        arr_labels_temp.append(r_tatkpcr.codcomp);
--        arr_labels_temp.append(get_tcenter_name(r_tatkpcr.codcomp,global_v_lang));
--        arr_labels.append(arr_labels_temp);
        arr_labels.append(get_tcenter_name(r_tatkpcr.codcomp,global_v_lang));
--        arr_labels.append(r_tatkpcr.codcomp);
        arr_datasets_atk.append(r_tatkpcr.count_atk_y);
        arr_datasets_pcr.append(r_tatkpcr.count_pcr_y);
        arr_datasets_total.append(r_tatkpcr.count_atk_y + r_tatkpcr.count_pcr_y);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets_atk);
    arr_data.append(arr_datasets_pcr);
--    arr_data.append(arr_datasets_total);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', '');
    obj_data.put('labels', arr_labels);
    obj_data.put('data', arr_data);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure insert_todo_list(json_str_input in clob,json_str_output out clob) is
        v_row_in    json_object_t;
        obj_row     json_object_t;
        v_grpseq    number;
        v_lastseq   number;
    begin
        initial_value(json_str_input);

        v_row_in   := json_object_t(json_str_input);
        v_flgsta    := hcm_util.get_string_t(v_row_in,'flgsta');
        v_dtework   := to_date(hcm_util.get_string_t(v_row_in,'dtework'),'DDMMYYYY');
        v_nummseq   := hcm_util.get_number_t(v_row_in,'numseq');

        begin
            select nvl(max(numseq),0) into v_lastseq
             from ttodolist
            where dtework = v_dtework
              and codempid = global_v_codempid;
        exception when others then
            v_lastseq := 0;
        end;

		v_grpseq := v_lastseq+1;
        if v_nummseq = 0 then
            v_grpseq := v_grpseq;
        else
            v_grpseq := v_nummseq;
        end if;

        v_timstrt   := replace(hcm_util.get_string_t(v_row_in,'timstrt'),':','');
        v_timend    := replace(hcm_util.get_string_t(v_row_in,'timend'),':','');
        v_title     := hcm_util.get_string_t(v_row_in,'title');
        v_detail    := hcm_util.get_string_t(v_row_in,'detail');
        v_flgchk    := hcm_util.get_string_t(v_row_in,'flgchk');

        begin
            insert into ttodolist (codempid, dtework, numseq, timstrt, timend, title, detail, flgchk, dtecreate, codcreate) 
            values (global_v_codempid,v_dtework,v_grpseq,v_timstrt,v_timend,v_title,v_detail,v_flgchk,sysdate,global_v_coduser);
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        exception when dup_val_on_index then
            update ttodolist 
             set timstrt  = v_timstrt, 
                 timend   = v_timend, 
                 title    = v_title, 
                 detail   = v_detail,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser,
                 flgchk   = v_flgchk
           where codempid = global_v_codempid 
             and dtework  = v_dtework
             and numseq   = v_grpseq;
            param_msg_error := get_error_msg_php('HR2410',global_v_lang);
        end;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;  
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END;

    procedure delete_todo_list(json_str_input in clob,json_str_output out clob) is
        v_row_in    json_object_t;
        obj_row     json_object_t;
      begin
        initial_value(json_str_input);

        v_row_in   := json_object_t(json_str_input);
        v_flgsta    := hcm_util.get_string_t(v_row_in,'flgsta');
        v_dtework   := to_date(hcm_util.get_string_t(v_row_in,'dtework'),'DDMMYYYY');
        v_nummseq   := hcm_util.get_number_t(v_row_in,'numseq');

        delete from ttodolist 
         where codempid = global_v_codempid
          and dtework   = v_dtework
          and numseq    = v_nummseq;

        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;  
        exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end;

END HCM_HOME;

/

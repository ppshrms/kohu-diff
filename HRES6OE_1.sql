--------------------------------------------------------
--  DDL for Package Body HRES6OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES6OE" is
-- last update: 04/12/2017 16:22
  procedure get_tattence (p_codempid in temploy1.codempid%type,
                          p_dtework  in tattence.dtework%type,
                          r_tattence in out tattence%rowtype) is
  begin
      select * into r_tattence
      from   tattence
      where  codempid = p_codempid
      and    dtework  = p_dtework;
  exception when no_data_found then
      r_tattence := null;
  end;
  --
  procedure time_stamp (p_codshift   in tattence.codshift%type,
                        p_dtework  	 in tattence.dtework%type,
                        p_stampinst  out tatmfile.dtetime%type,
                        p_stampinen  out tatmfile.dtetime%type,
                        p_stampoutst out tatmfile.dtetime%type,
                        p_stampouten out tatmfile.dtetime%type) is
  rt_tshiftcd tshiftcd%rowtype;
  v_dtework   tattence.dtework%type;
  begin
    select * into rt_tshiftcd
    from tshiftcd
    where codshift = p_codshift
    order by codshift;
      if to_number(rt_tshiftcd.stampinst) > to_number(rt_tshiftcd.timstrtw) then
        v_dtework := p_dtework - 1;
      else
        v_dtework := p_dtework;
      end if;
      p_stampinst := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampinst,'dd/mm/yyyyhh24mi');
      if to_number(rt_tshiftcd.stampinen) < to_number(rt_tshiftcd.stampinst) then
        v_dtework := v_dtework + 1;
      end if;
      p_stampinen := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampinen,'dd/mm/yyyyhh24mi');

      if to_number(rt_tshiftcd.timstrtw) > to_number(rt_tshiftcd.timendw) then
        v_dtework := p_dtework + 1;
      else
        v_dtework := p_dtework;
      end if;
      if to_number(rt_tshiftcd.stampoutst) > to_number(rt_tshiftcd.timendw) then
        v_dtework := v_dtework - 1;
      end if;
      p_stampoutst := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampoutst,'dd/mm/yyyyhh24mi');
      if to_number(rt_tshiftcd.stampouten) < to_number(rt_tshiftcd.stampoutst) then
        v_dtework := v_dtework + 1;
      end if;
      p_stampouten := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampouten,'dd/mm/yyyyhh24mi');
  exception when no_data_found then
    p_stampinst  := null;
    p_stampinen  := null;
    p_stampoutst := null;
    p_stampouten := null;
  end;
  --
  function get_datework(p_codempid varchar2,p_date varchar2, p_time varchar2, p_flgchkin varchar2 default 'I') return varchar2 as
    v_date        date := to_date(p_date,'dd/mm/yyyy');
    v_dtework     date;
    v_dtetime     date := to_date(p_date||p_time,'dd/mm/yyyyhh24mi');
    rt_tattence   tattence%rowtype;
    v_stampinst   tatmfile.dtetime%type;
    v_stampinen   tatmfile.dtetime%type;
    v_stampoutst  tatmfile.dtetime%type;
    v_stampouten  tatmfile.dtetime%type;

    v_lst_flgchkin  tchkinraw.flgchkin%type;
    v_lst_dtework   tchkinraw.dtework%type;

    cursor c_tchkinraw is
      select flgchkin,dtework
        from tchkinraw
       where codempid = p_codempid
       order by dtechkin desc;

  begin
    -- get last check in/out
    v_lst_flgchkin := 'O';
    for r_tchkinraw in c_tchkinraw loop
      v_lst_flgchkin  := r_tchkinraw.flgchkin;
      v_lst_dtework   := r_tchkinraw.dtework;
      exit;
    end loop;

    v_dtework := v_date - 2;
    for i in 1..3 loop
      v_dtework := v_dtework + 1;
      get_tattence(p_codempid,v_dtework,rt_tattence);
      time_stamp(rt_tattence.codshift,rt_tattence.dtework,
                 v_stampinst,v_stampinen,v_stampoutst,v_stampouten);

      if p_flgchkin = 'I' then
        if v_dtetime between v_stampinst and v_stampinen then
          return to_char(v_dtework,'dd/mm/yyyy');
        end if;
      elsif p_flgchkin = 'O' then
        if v_dtetime between v_stampoutst and v_stampouten then
          -- check if last record is check in then check dtework must >= last dtework
          if (v_lst_flgchkin = 'I' and v_dtework >= v_lst_dtework) or (v_lst_flgchkin = 'O') then
            return to_char(v_dtework,'dd/mm/yyyy');
          end if;
        end if;
      end if;


    end loop;
    --
    return to_char(v_dtework - 1,'dd/mm/yyyy');
  end;
  --

  procedure upd_tchkin(p_codempid temploy1.codempid%type,
                       p_coduser  in varchar2,
                       p_dtestrt  in date,
                       p_dteend   in date) is
    v_dtework		date;
    v_dteI			date;
    v_dteO			date;
    v_date			date;
    p_sysdate          date   := sysdate;

  cursor c_tattence is
    select dtework,dtein,timin,dteout,timout,rowid
    from   tattence
    where  codempid = p_codempid
    and    dtework between p_dtestrt and p_dteend
    order by codempid,dtework;

  cursor c_tchkin is
    select dtein,timin,dteout,timout
    from 	 tchkin
    where  codempid = p_codempid
    and    dtework  = v_dtework;

  begin
    for r1 in c_tattence loop
      v_dtework := r1.dtework;
      v_dteI := to_date(to_char(r1.dtein,'dd/mm/yyyy')||r1.timin,'dd/mm/yyyyhh24mi');
      v_dteO := to_date(to_char(r1.dteout,'dd/mm/yyyy')||r1.timout,'dd/mm/yyyyhh24mi');
      --
      for r2 in c_tchkin loop
        if r2.dtein is not null then
          v_date := to_date(to_char(r2.dtein,'dd/mm/yyyy')||r2.timin,'dd/mm/yyyyhh24mi');
          v_dteI := least(nvl(v_dteI,(sysdate+99999)),v_date);
        end if;
        if r2.dteout is not null then
          v_date := to_date(to_char(r2.dteout,'dd/mm/yyyy')||r2.timout,'dd/mm/yyyyhh24mi');
          v_dteO := greatest(nvl(v_dteO,(sysdate-99999)),v_date);
        end if;
      end loop;
      --
      if v_dteI is not null then
        update tattence
           set dtein  = trunc(v_dteI),
               timin  = to_char(v_dteI,'hh24mi')
         where rowid = r1.rowid;
      end if;
      if v_dteO is not null then
        update tattence
           set dteout = trunc(v_dteO),
               timout = to_char(v_dteO,'hh24mi')
         where rowid = r1.rowid;
      end if;
    end loop;--r1 in c_tattence
  end;
  --
  function timformat(p_tim varchar2) return varchar2 is
    v_ret varchar2(100);
  begin
    if p_tim is not null then
      v_ret := substr(p_tim,1,2)||':'||substr(p_tim,3,2);
    end if;
    return v_ret;
  end;
  --
  procedure checksave is
    v_code    varchar2(4000);
  begin
    if v_typplace = '2' then
      begin
        select  zipcode
        into    v_code
        from    tcust
        where   codcust   = v_codcust;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('ES0070',global_v_lang);
      end;
    elsif v_typplace = '1' then
      begin
        select  zipcode
        into    v_code
        from    tcust
        where   codcust   = v_codcust
        and     (trunc(2 * p_radius * asin(sqrt(power((sin(((v_latitude - latitude)/p_deg_to_rad)/2)), 2) +
                cos(latitude/p_deg_to_rad) * cos(v_latitude/p_deg_to_rad) *
                power((sin(((v_longitude - longitude)/p_deg_to_rad) / 2)),2))) * p_km) <= radius + 500); -- user4 || 25/10/2018 || add 500 metre for inaccuracy gps of user
      exception when no_data_found then
        param_msg_error := get_error_msg_php('ES0070',global_v_lang);
      end;
    end if;
  end;
  --
  procedure initial_value(json_str_input in clob) is
    json_obj      json_object_t;
  begin
    param_msg_error       := null;
    json_obj              := json_object_t(json_str_input);
    --global
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');

    --value
    v_start               := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    v_end                 := to_number(hcm_util.get_string_t(json_obj,'p_end'));
    v_codempid            := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    v_namcust             := upper(hcm_util.get_string_t(json_obj,'p_namcust'));
    v_codcust             := upper(hcm_util.get_string_t(json_obj,'p_codcust'));
    v_typplace            := upper(hcm_util.get_string_t(json_obj,'p_typplace'));
    v_dtework             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    v_seqno               := to_number(hcm_util.get_string_t(json_obj,'p_seqno'));
    v_codprovr            := upper(hcm_util.get_string_t(json_obj,'p_codprovr'));
    v_zipcode             := hcm_util.get_string_t(json_obj,'p_zipcode');

    -- check in/out
    v_flgchkin            := upper(hcm_util.get_string_t(json_obj,'p_flgchkin')); -- I = Check In, O = Check Out
    v_dte                 := to_date(trim(hcm_util.get_string_t(json_obj,'p_dte')),'dd/mm/yyyy');
    v_tim                 := hcm_util.get_string_t(json_obj,'p_tim');
    v_codreason           := upper(hcm_util.get_string_t(json_obj,'p_codreason'));
    v_activity            := hcm_util.get_string_t(json_obj,'p_activity');
    v_latitude            := hcm_util.get_string_t(json_obj,'p_latitude');
    v_longitude           := hcm_util.get_string_t(json_obj,'p_longitude');
    v_accuracy            := hcm_util.get_string_t(json_obj,'p_accuracy');
    v_ipaddr              := hcm_util.get_string_t(json_obj,'p_ipaddr');
    v_devicenam           := hcm_util.get_string_t(json_obj,'p_devicenam');
    v_new_namcust         := hcm_util.get_string_t(json_obj,'p_new_namcust');
    v_namcontact          := hcm_util.get_string_t(json_obj,'p_namcontact');
    v_phone               := hcm_util.get_string_t(json_obj,'p_phone');
    v_filenamei           := hcm_util.get_string_t(json_obj,'p_filenamei');
    v_filenameo           := hcm_util.get_string_t(json_obj,'p_filenameo');
    v_zipcode             := hcm_util.get_string_t(json_obj,'p_zipcode');
    v_adrcust             := hcm_util.get_string_t(json_obj,'p_adrcust');
    p_latitude            := to_number(hcm_util.get_string_t(json_obj,'p_latitude'));
    p_longitude           := to_number(hcm_util.get_string_t(json_obj,'p_longitude'));

    v_default_radius      := get_tsetup_value('RADIUS_CHECKIN');
    v_default_radiuso     := get_tsetup_value('RADIUS_CHECKOUT');
  end initial_value;
  --
  procedure get_cust(json_str_input in clob,json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_position  json_object_t;
    v_rcnt		    number := 0;
    v_chk_data    boolean := false;
    v_last_output clob;
    cursor c1 is
      select codcust,get_tcust_name(codcust,global_v_lang) namcust,latitude,longitude,radius,
             decode(global_v_lang, '101', adrcuste
                                 , '102', adrcustt
                                 , '103', adrcust3
                                 , '104', adrcust4
                                 , '105', adrcust5
                                 , adrcuste) as adrcust,zipcode,
            trunc(2 * p_radius * asin(sqrt(power((sin(((p_latitude - latitude)/p_deg_to_rad)/2)), 2) +
             cos(latitude/p_deg_to_rad) * cos(p_latitude/p_deg_to_rad) *
             power((sin(((p_longitude - longitude)/p_deg_to_rad) / 2)),2))) * p_km) xxx
        from tcust
       where nvl(flgact,1) = 1
         and latitude is not null
         and longitude is not null
         and (trunc(2 * p_radius * asin(sqrt(power((sin(((p_latitude - latitude)/p_deg_to_rad)/2)), 2) +
             cos(latitude/p_deg_to_rad) * cos(p_latitude/p_deg_to_rad) *
             power((sin(((p_longitude - longitude)/p_deg_to_rad) / 2)),2))) * p_km)
             <=
             case when last_codcust = codcust and last_flg_inout = 'I' then nvl(radiuso,v_default_radiuso) else nvl(radius,v_default_radius) end) -- user4 || 25/10/2018 || add 500 metre for inaccuracy gps of user

      order by codcust, namcust;
  begin
    initial_value(json_str_input);
    get_last_checkin(json_str_input,v_last_output);
    obj_row     := json_object_t();
    for r1 in c1 loop
      v_chk_data    := true;
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_position  := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', '');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codcust',nvl(r1.codcust,''));
      obj_data.put('namcust',nvl(r1.namcust,''));
      obj_data.put('title',nvl(r1.namcust,''));
      obj_position.put('lat',nvl(to_number(r1.latitude),0));
      obj_position.put('lng',nvl(to_number(r1.longitude),0));
      obj_data.put('position',obj_position);

      obj_data.put('radius',nvl(to_number(r1.radius),0));
      obj_data.put('address',nvl(r1.adrcust,''));
      obj_data.put('zipcode',nvl(r1.zipcode,''));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_chk_data = false then
      param_msg_error := get_error_msg_php('ES0070',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_cust_no_location(json_str_input in clob,json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_position  json_object_t;
    v_rcnt		    number := 0;
    v_chk_data    boolean := false;
    cursor c1 is
      select codcust,get_tcust_name(codcust,global_v_lang) namcust,latitude,longitude,radius,
             decode(global_v_lang, '101', adrcuste
                                 , '102', adrcustt
                                 , '103', adrcust3
                                 , '104', adrcust4
                                 , '105', adrcust5
                                 , adrcuste) as adrcust,zipcode
        from tcust
       where nvl(flgact,1) = 1
         and (latitude is null or longitude is null)
         and codcust like v_codcust||'%'
         and get_tcust_name(codcust,global_v_lang) like '%'||v_namcust||'%'
         and ((v_codprovr is not null and codprovr = v_codprovr) or (v_codprovr is null))
         and ((v_zipcode is not null and zipcode = v_zipcode) or (v_zipcode is null))
      order by codcust, namcust;
  begin
    initial_value(json_str_input);
    obj_row     := json_object_t();
    for r1 in c1 loop
      v_chk_data    := true;
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_position  := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', '');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codcust',nvl(r1.codcust,''));
      obj_data.put('namcust',nvl(r1.namcust,''));
      obj_data.put('title',nvl(r1.namcust,''));
      obj_position.put('lat',nvl(to_number(r1.latitude),0));
      obj_position.put('lng',nvl(to_number(r1.longitude),0));
      obj_data.put('position',obj_position);

      obj_data.put('radius',nvl(to_number(r1.radius),0));
      obj_data.put('address',nvl(r1.adrcust,''));
      obj_data.put('zipcode',nvl(r1.zipcode,''));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_chk_data = false then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcust');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else

      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcodreason(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_obj        json_object_t;
    v_row           number := 0;
    p_codapp        varchar2(4000 char);
    p_coduser       varchar2(4000 char);
    p_codpswd       varchar2(4000 char);
    p_codlang       varchar2(4000 char);
    p_lang          varchar2(4000 char) := '102';

    cursor c1 is
      select
        codcodec as codreason,descode,descodt,descod3,descod4,descod5
      from tcodreason;

  begin

        initial_value(json_str_input);
        obj_data  := json_object_t();
        obj_row   := json_object_t();
        for i in c1 loop
          obj_data  := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codreason', i.codreason);

          if global_v_lang = '101' then
              obj_data.put('desc_codreason', i.descode);
            elsif global_v_lang = '102' then
              obj_data.put('desc_codreason', i.descodt);
            elsif global_v_lang = '103' then
              obj_data.put('desc_codreason', i.descod3);
            elsif global_v_lang = '104' then
              obj_data.put('desc_codreason', i.descod4);
            elsif global_v_lang = '105' then
              obj_data.put('desc_codreason', i.descod5);
            end if;
          obj_row.put(to_char(v_row), obj_data);
          v_row := v_row + 1;
        end loop;


    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,p_lang);
  end;
  --
  function gen_codcustsurv return varchar2 is
    v_prefix    varchar2(10 char) := 'S';
    v_codcust   varchar2(4000 char);
    v_digit     number := 5;
  begin

    begin
      select v_prefix||to_char(sysdate,'yymm')||lpad(nvl(max(to_number(substr(codcustsurv,6))+1),'1'),v_digit,'0')
        into v_codcustsurv
        from tcustsurv;
    exception when no_data_found then
      v_codcustsurv := v_prefix||to_char(sysdate,'yymm')||lpad('1',v_digit,'0');
    end;
    return v_codcustsurv;
  end;
  --
  procedure save_tchkin_master(p_table in varchar2) as
    o_seqno         number := 0;
    o_codcust       varchar2(100 char) := '!@#$';
    o_codjob        varchar2(500 char) := '!@#$';
    o_timchkin      varchar2(40 char) := '!@#$';
    o_flgchkin      varchar2(10 char) := 'N';
    o_dtework       date;

    v_dtechkin      date   := v_dte;
    v_timchkin      varchar2(40 char);
    v_latitudei     varchar2(500 char);
    v_longitudei    varchar2(500 char);
    v_accuracyi     varchar2(500 char);
    v_ipaddri       varchar2(500 char);
    v_devicenami    varchar2(500 char);
    v_dtechkout     date   := v_dte;
    v_timchkout     varchar2(40 char);
    v_latitudeo     varchar2(500 char);
    v_longitudeo    varchar2(500 char);
    v_accuracyo     varchar2(500 char);
    v_ipaddro       varchar2(500 char);
    v_devicenamo    varchar2(500 char);

    v_flginsert     boolean := false;
    v_flgupdate     boolean := false;

    cursor c_tchkinraw is
      select codcust, timchkin, flgchkin
        from tchkinraw
       where codempid = v_codempid
         and dtework  = v_dtework
       order by dtechkin desc;
  begin
    o_codcust   := '!@#$';
    o_codjob    := '!@#$';
    o_timchkin  := '!@#$';
    o_flgchkin  := 'N';
    for r_tchkinraw in c_tchkinraw loop
        o_codcust  := r_tchkinraw.codcust;
        o_timchkin := r_tchkinraw.timchkin;
        o_flgchkin := r_tchkinraw.flgchkin;
        exit;
    end loop;

    if upper(p_table) = 'TCHKINC' then
      null;
    elsif upper(p_table) = 'TCHKIN' then
      begin
        select nvl(max(seqno),0)
          into o_seqno
          from tchkin
         where codempid = v_codempid
           and dtework  = v_dtework;
      exception when no_data_found then
        o_seqno := 0;
      end;
      begin
        select max(dtework)
          into o_dtework
          from tchkin
         where codempid = v_codempid;
      exception when no_data_found then
        o_dtework := v_dtework;
      end;
    end if;

    if v_codcust <> o_codcust then--or nvl(v_codjob,'#$%') <> nvl(o_codjob,'#$%') then
      v_flginsert := true;
      v_flgupdate := false;
      if v_flgchkin = 'I' then
        v_dtechkin  := v_dte;
        v_timchkin  := v_tim;
        v_latitudei := v_latitude;
        v_longitudei:= v_longitude;
        v_accuracyi := v_accuracy;
        v_ipaddri   := v_ipaddr;
        v_devicenami:= v_devicenam;
        v_dtechkout := null;
        v_timchkout := null;
        v_latitudeo := null;
        v_longitudeo:= null;
        v_accuracyo := null;
        v_ipaddro   := null;
        v_devicenamo:= null;
      elsif v_flgchkin = 'O' then
        v_dtechkin  := null;
        v_timchkin  := null;
        v_latitudei := null;
        v_longitudei:= null;
        v_accuracyi := null;
        v_ipaddri   := null;
        v_devicenami:= null;
        v_dtechkout := v_dte;
        v_timchkout := v_tim;
        v_latitudeo := v_latitude;
        v_longitudeo:= v_longitude;
        v_accuracyo := v_accuracy;
        v_ipaddro   := v_ipaddr;
        v_devicenamo:= v_devicenam;
      end if;
    else  -- new cust = pld cust && new job = old job
     if v_flgchkin <> o_flgchkin then
        v_flginsert := false;
        v_flgupdate := false;
        if v_flgchkin = 'I' then
          v_dtechkin  := v_dte;
          v_timchkin  := v_tim;
          v_latitudei := v_latitude;
          v_devicenami:= v_devicenam;
          v_longitudei:= v_longitude;
          v_accuracyi := v_accuracy;
          v_ipaddri   := v_ipaddr;
          v_dtechkout := null;
          v_timchkout := null;
          v_latitudeo := null;
          v_longitudeo:= null;
          v_accuracyo := null;
          v_ipaddro   := null;
          v_devicenamo:= null;
          v_flginsert := true;
        elsif v_flgchkin = 'O' then
          v_dtechkout := v_dte;
          v_timchkout := v_tim;
          v_latitudeo := v_latitude;
          v_longitudeo:= v_longitude;
          v_accuracyo := v_accuracy;
          v_ipaddro   := v_ipaddr;
          v_devicenamo:= v_devicenam;
          v_flgupdate := true;

          -- case check out to check out more than 1 day
          if o_dtework < v_dtework then
            v_dtechkin  := null;
            v_timchkin  := null;
            v_latitudei := null;
            v_longitudei:= null;
            v_accuracyi := null;
            v_ipaddri   := null;
            v_devicenami:= null;
            v_flginsert := true;
            v_flgupdate := false;
          end if;
        end if;
      else
        v_flginsert := false;
        v_flgupdate := false;
        if v_flgchkin = 'I' and v_codcust = v_key_undefinded_codcust then  -- check in '999' other
          v_dtechkin  := v_dte;
          v_timchkin  := v_tim;
          v_latitudei := v_latitude;
          v_longitudei:= v_longitude;
          v_accuracyi := v_accuracy;
          v_ipaddri   := v_ipaddr;
          v_devicenami:= v_devicenam;
          v_dtechkout := null;
          v_timchkout := null;
          v_latitudeo := null;
          v_longitudeo:= null;
          v_accuracyo := null;
          v_ipaddro   := null;
          v_devicenamo:= null;
          v_flginsert := true;
        elsif v_flgchkin = 'O' then
          v_dtechkout := v_dte;
          v_timchkout := v_tim;
          v_latitudeo := v_latitude;
          v_longitudeo:= v_longitude;
          v_accuracyo := v_accuracy;
          v_ipaddro   := v_ipaddr;
          v_devicenamo:= v_devicenam;
          v_flgupdate := true;
          --
          if v_codcust = v_key_undefinded_codcust then -- check out '999' other
            v_dtechkin  := null;
            v_timchkin  := null;
            v_latitudei := null;
            v_longitudei:= null;
            v_accuracyi := null;
            v_ipaddri   := null;
            v_devicenami:= null;
            v_flginsert := true;
            v_flgupdate := false;
          end if;
        end if;
      end if;
    end if;

    if v_flginsert then
      v_seqno := o_seqno + 1;
      if upper(p_table) = 'TCHKINC' then
      null;
      elsif upper(p_table) = 'TCHKIN' then
        if v_typplace = '2' and v_flgchkin = 'I' then
          update  tcust
          set     latitude    = v_latitude
          ,       longitude   = v_longitude
          ,       radius      = nvl(radius,v_default_radius)
          ,       radiuso     = nvl(radiuso,v_default_radiuso)
          where   codcust     = v_codcust;
        end if;
        begin
          insert into tchkin (codempid, dtework, seqno, dtein, timin, dteout, timout, codcust, codreason, activity,
                               latitudei, longitudei, accuracyi, ipaddri, devicenami,
                               latitudeo, longitudeo, accuracyo, ipaddro, devicenamo,
                               codcustsurv, coduser, typplace, filenamei)
          values (v_codempid, v_dtework, v_seqno, v_dtechkin, v_timchkin, v_dtechkout, v_timchkout, v_codcust, v_codreason, v_activity,
                  v_latitudei, v_longitudei, v_accuracyi, v_ipaddri, v_devicenami,
                  v_latitudeo, v_longitudeo, v_accuracyo, v_ipaddro, v_devicenamo,
                  v_codcustsurv, global_v_coduser, v_typplace, v_filenamei);
        exception when dup_val_on_index then
          null;
        end;
      end if;
    end if;
    if v_flgupdate then

      -- update new customer survey
      if upper(p_table) = 'TCHKINC' then
      null;
      end if;
      --

      if upper(p_table) = 'TCHKINC' then
      null;
      elsif upper(p_table) = 'TCHKIN' then
        begin
          update tchkin  set dteout     = v_dtechkout,
                             timout     = v_timchkout,
                             latitudeo  = v_latitudeo,
                             longitudeo = v_longitudeo,
                             accuracyo  = v_accuracyo,
                             ipaddro    = v_ipaddro,
                             devicenamo = v_devicenamo,
                             activity   = v_activity,
                             codreason  = v_codreason,
                             coduser    = global_v_coduser,
                             filenameo  = v_filenameo
           where codempid = v_codempid
             and dtework  = v_dtework
             and seqno    = o_seqno;
        end;
      end if;
    end if;
  end;

  /*
  * PROCEDURE : check_in_out
  * PARAMETER: p_flgchkin,p_codempid,p_dte,p_tim,p_codcust,p_codjob,p_codreason,p_activity,p_latitude,p_longitude,p_accuracy,p_ipaddr,p_devicenam,p_new_namcust,p_phone
  * RETURN   : varchar2[json_str]
  */
  procedure check_in_out(json_str_input in clob, json_str_output out clob) as
    resp_obj          json_object_t :=  json_object_t();
    resp_str          varchar2(4000 char);
  begin
--    resp_str  := '(ERROR)NO PERMISSION';
    initial_value(json_str_input);
    v_dte     := trunc(sysdate);
    v_tim     := to_char(sysdate,'hh24mi');
    v_dtework := to_date(get_datework(v_codempid,to_char(v_dte,'dd/mm/yyyy'),v_tim,v_flgchkin),'dd/mm/yyyy');
    checksave;

    if param_msg_error is null then
      -- insert tchkin
      if v_typplace = '3' then
        if v_codcust = v_key_undefinded_codcust then
          -- insert new customer survey
          v_codcustsurv := gen_codcustsurv();
          v_codcust     := v_codcustsurv;
          begin
            insert into tcustsurv(codcustsurv, namcust, namcontact, numtele)
            values(v_codcustsurv, v_new_namcust, v_namcontact, v_phone);
          exception when dup_val_on_index then
            null;
          end;

          begin
            insert into tcust(codcust,namcuste,namcustt,namcust3,namcust4,namcust5,
                              adrcuste,adrcustt,adrcust3,adrcust4,adrcust5,
                              zipcode,numtele,latitude,longitude,radius,
                              codcreate,coduser,radiuso)
                       values(v_codcust,v_new_namcust,v_new_namcust,v_new_namcust,v_new_namcust,v_new_namcust,
                              v_adrcust,v_adrcust,v_adrcust,v_adrcust,v_adrcust,
                              v_zipcode,v_phone,v_latitude,v_longitude,v_default_radius,
                              global_v_coduser,global_v_coduser,v_default_radiuso);
          exception when dup_val_on_index then
            update tcust
               set namcuste  = v_new_namcust,
                   namcustt  = v_new_namcust,
                   namcust3  = v_new_namcust,
                   namcust4  = v_new_namcust,
                   namcust5  = v_new_namcust,
                   adrcuste  = v_adrcust,
                   adrcustt  = v_adrcust,
                   adrcust3  = v_adrcust,
                   adrcust4  = v_adrcust,
                   adrcust5  = v_adrcust,
                   zipcode   = v_zipcode,
                   numtele   = v_phone,
                   latitude  = v_latitude,
                   longitude = v_longitude,
                   coduser   = global_v_coduser,
                   radius    = nvl(radius,v_default_radius),
                   radiuso   = nvl(radiuso,v_default_radiuso)
             where codcust   = v_codcust;
          end;
        else
          begin
            update tcustsurv
            set namcust = v_new_namcust,
                namcontact = v_namcontact,
                numtele = v_phone
            where codcustsurv = v_codcust;
          end;

          begin
            update tcust
            set namcuste = v_new_namcust,
                namcustt = v_new_namcust,
                namcust3 = v_new_namcust,
                namcust4 = v_new_namcust,
                namcust5 = v_new_namcust,
                numtele = v_phone
            where codcust = v_codcust;
          end;
        end if;
      end if;
      save_tchkin_master('TCHKIN');
      -- insert tchkinraw
      begin
        insert into tchkinraw(codempid,dtechkin,timchkin,flgchkin,codcust,codreason,activity,latitude,longitude,accuracy,ipaddr,devicenam,codcustsurv,typplace,dtework)
        values(v_codempid,sysdate,v_tim,v_flgchkin,v_codcust,v_codreason,v_activity,v_latitude,v_longitude,v_accuracy,v_ipaddr,v_devicenam,v_codcustsurv,v_typplace,v_dtework);
      exception when dup_val_on_index then
        null;
      end;

      -- transfer date time to tattence
      upd_tchkin(v_codempid,global_v_coduser,v_dtework,v_dtework);
    end if;

    if param_msg_error is not null then
      rollback;
    else
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  /*
  * FUNCTION : get_last_checkin
  * PARAMETER: p_codempid
  * RETURN   : table[total,rcnt,flgcanedit,dtework,seqno,dtein,timin,dteout,timout,codcust,namcust,codjob,codreason,namreason,activity,new_namcust,phone]
  */
  procedure get_last_checkin(json_str_input in clob,json_str_output out clob) as
    obj_data    json_object_t;
    v_exit      boolean := false;
    t_dtework   date;
    v_flgchkin  varchar2(10 char);

    cursor c1 is
      select a.dtework,a.seqno,a.dtein,a.timin,
             a.dteout,a.timout,a.codcust,
             a.codreason,a.activity,b.namcust,b.namcontact,b.numtele,
             decode(a.dteout,null,'I','O') as flg_inout,
             decode(global_v_lang , '101', adrcuste
                                  , '102', adrcustt
                                  , '103', adrcust3
                                  , '104', adrcust4
                                  , '105', adrcust5
                                  , adrcuste) as adrcust,a.typplace,
             a.filenamei,a.filenameo
        from tchkin a, tcust c, tcustsurv b
       where a.codcust      = c.codcust(+)
         and a.codcustsurv  = b.codcustsurv(+)
         and codempid       = v_codempid
--         and rownum         <= 1
      order by dtework desc,seqno desc;
  begin
    initial_value(json_str_input);
    obj_data    := json_object_t();
    for r1 in c1 loop
      v_exit      := true;

      if r1.flg_inout = 'I' then -- last check in then now is check out
        v_flgchkin := 'O';
      else -- last check out then now is check in
        v_flgchkin := 'I';
      end if;

      t_dtework := to_date(get_datework(v_codempid,to_char(trunc(sysdate),'dd/mm/yyyy'),to_char(sysdate,'hh24mi'),v_flgchkin),'dd/mm/yyyy');
      obj_data.put('coderror','200');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_data.put('dtework',nvl(to_char(r1.dtework,'dd/mm/yyyy'),''));
      obj_data.put('seqno',nvl(to_char(r1.seqno),''));
      obj_data.put('dtein',nvl(to_char(r1.dtein,'dd/mm/yyyy'),''));
      obj_data.put('timin',nvl(timformat(r1.timin),''));
      obj_data.put('dteout',nvl(to_char(r1.dteout,'dd/mm/yyyy'),''));
      obj_data.put('timout',nvl(timformat(r1.timout),''));
      obj_data.put('codcust',nvl(r1.codcust,''));
      obj_data.put('typplace',nvl(r1.typplace,''));
      obj_data.put('namcust',nvl(get_tcust_name(r1.codcust,global_v_lang),''));
      obj_data.put('codreason',nvl(r1.codreason,''));
      obj_data.put('namreason',nvl(get_tcodec_name('TCODREASON',r1.codreason,global_v_lang),''));
      obj_data.put('activity',nvl(r1.activity,''));
      obj_data.put('new_namcust',nvl(r1.namcust,''));
      obj_data.put('namcontact',nvl(r1.namcontact,''));
      obj_data.put('phone',nvl(r1.numtele,''));
      obj_data.put('flg_inout',nvl(r1.flg_inout,''));
      obj_data.put('address',nvl(r1.adrcust,''));
      obj_data.put('filenamei',nvl(r1.filenamei,''));
      obj_data.put('filenameo',nvl(r1.filenameo,''));
      if r1.dtework < t_dtework then
        obj_data.put('o_dtework','Y');
      else
        obj_data.put('o_dtework','N');
      end if;
      last_codcust    := r1.codcust;
      last_flg_inout  := r1.flg_inout;
      exit;
    end loop;

    if not v_exit then
      obj_data.put('coderror','200');
      obj_data.put('desc_coderror','');
      obj_data.put('httpcode','');
      obj_data.put('flg','');
      obj_data.put('dtework','');
      obj_data.put('seqno','');
      obj_data.put('dtein','');
      obj_data.put('timin','');
      obj_data.put('dteout','');
      obj_data.put('timout','');
      obj_data.put('codcust','');
      obj_data.put('namcust','');
      obj_data.put('codreason','');
      obj_data.put('namreason','');
      obj_data.put('activity','');
      obj_data.put('new_namcust','');
      obj_data.put('namcontact','');
      obj_data.put('phone','');
      obj_data.put('flg_inout','O');
      obj_data.put('address','');
      obj_data.put('filenamei','');
      obj_data.put('filenameo','');
      obj_data.put('o_dtework','Y');
    end if;

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  /*
  * FUNCTION : get_history
  * PARAMETER: p_codempid,p_start,p_end
  * RETURN   : table[total,rcnt,flgcanedit,dtework,seqno,dtein,timin,dteout,timout,codcust,namcust,codjob,codreason,namreason,activity,new_namcust,phone]
  */
  procedure get_history(json_str_input in clob,json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_days        json_object_t;
    obj_days_row    json_object_t;
    obj_monyear     json_object_t;
    obj_my_row      json_object_t;
    v_rcnt		      number := 0;
    v_dcnt		      number := 0;
    v_mcnt		      number := 0;
    v_monyear       varchar2(100);
    v_days          varchar2(100);
    v_dayweek       varchar2(100);

    v_count         number := 0;
    v_flgcanedit    varchar2(1 char) := 'Y'; -- Y=can edit, R=record is in requesting, N=record is pass today

    o_dtework       date;

    cursor c_chkin is
      select dtework,seqno,dtein,timin,dteout,
              timout,codcust,codreason,activity,
              namcust,namcontact,numtele,filenamei,filenameo,
              typplace, rcnt
        from (select dtework,seqno,dtein,timin,dteout,
                      timout,codcust,codreason,activity,
                      namcust,namcontact,numtele,filenamei,filenameo,
                      typplace, rownum rcnt
                from (select  dtework,seqno,dtein,timin,dteout,
                              timout,codcust,codreason,activity,
                              namcust,namcontact,numtele,filenamei,filenameo,
                              typplace
                      from    tchkin a, tcustsurv b
                      where   a.codcustsurv = b.codcustsurv(+)
                      and     codempid = v_codempid
                      order by dtework desc,seqno desc))
       where rcnt between to_char(1) and to_char(200);

  begin
    initial_value(json_str_input);

    obj_my_row    := json_object_t();
    obj_days_row  := json_object_t();
    obj_row       := json_object_t();
    for r1 in c_chkin loop
      o_dtework     := r1.dtework;
      v_flgcanedit  := 'Y';

      -- check is today
      if trunc(r1.dtein) <> trunc(sysdate) then
        v_flgcanedit := 'N';
      end if;

      if nvl(v_monyear,to_char(o_dtework,'mmyyyy')) <> to_char(o_dtework,'mmyyyy') then
        v_dcnt    := v_dcnt + 1;
        obj_days  := json_object_t();
        obj_days.put('day',v_days);
        obj_days.put('dayweek',v_dayweek);
        obj_days.put('details',obj_row);
        obj_days_row.put(to_char(v_dcnt-1),obj_days);

        v_mcnt      := v_mcnt + 1;
        obj_monyear := json_object_t();
        obj_monyear.put('month',substr(v_monyear,1,2));

        obj_monyear.put('year',substr(v_monyear,3,4));
        obj_monyear.put('days',obj_days_row);
        obj_my_row.put(to_char(v_mcnt-1),obj_monyear);
        v_monyear     := to_char(o_dtework,'mmyyyy');
        v_days        := to_char(o_dtework,'dd');
        v_dayweek     := to_char(o_dtework,'Dy');
        v_dcnt        := 0;
        v_rcnt        := 1;
        obj_days_row  := json_object_t();
        obj_row       := json_object_t();
      else
        v_monyear   := to_char(o_dtework,'mmyyyy');
        if nvl(v_days,to_char(o_dtework,'dd')) <> to_char(o_dtework,'dd') then
          v_dcnt    := v_dcnt + 1;
          obj_days  := json_object_t();
          obj_days.put('day',v_days);
          obj_days.put('dayweek',v_dayweek);
          obj_days.put('details',obj_row);
          obj_days_row.put(to_char(v_dcnt-1),obj_days);
          v_days    := to_char(o_dtework,'dd');
          v_dayweek := to_char(o_dtework,'Dy');
          v_rcnt    := 1;
          obj_row   := json_object_t();
        else
          v_rcnt    := v_rcnt + 1;
          v_days    := to_char(o_dtework,'dd');
          v_dayweek := to_char(o_dtework,'Dy');
        end if;
      end if;
      obj_data  := json_object_t();
      obj_data.put('dtework',nvl(to_char(o_dtework,'dd/mm/yyyy'),''));
      obj_data.put('flgcanedit',nvl(v_flgcanedit,''));
      obj_data.put('seqno',nvl(to_char(r1.seqno),''));
      obj_data.put('dtein',nvl(to_char(r1.dtein,'dd/mm/yyyy'),''));
      obj_data.put('timin',nvl(timformat(r1.timin),''));
      obj_data.put('dteout',nvl(to_char(r1.dteout,'dd/mm/yyyy'),''));
      obj_data.put('timout',nvl(timformat(r1.timout),''));
      obj_data.put('codcust',nvl(r1.codcust,''));
      obj_data.put('namcust',nvl(nvl(r1.namcust,get_tcust_name(r1.codcust,global_v_lang)),''));
      obj_data.put('codreason',nvl(r1.codreason,''));
      obj_data.put('namreason',nvl(get_tcodec_name('TCODREASON',r1.codreason,global_v_lang),''));
      obj_data.put('activity',nvl(r1.activity,''));
      obj_data.put('new_namcust',nvl(r1.namcust,''));
      obj_data.put('namcontact',nvl(r1.namcontact,''));
      obj_data.put('phone',nvl(r1.numtele,''));
      obj_data.put('filenamei',nvl(r1.filenamei,''));
      obj_data.put('filenameo',nvl(r1.filenameo,''));
      obj_data.put('typplace',nvl(r1.typplace,''));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop; --for r1 in c_chkin
    v_dcnt    := v_dcnt + 1;
    obj_days  := json_object_t();
    obj_days.put('day',v_days);
    obj_days.put('dayweek',v_dayweek);
    obj_days.put('details',obj_row);
    obj_days_row.put(to_char(v_dcnt-1),obj_days);

    v_mcnt      := v_mcnt + 1;
    obj_monyear := json_object_t();
    obj_monyear.put('month',substr(nvl(v_monyear,'0'),1,2));
    obj_monyear.put('year',substr(v_monyear,3,4));
    obj_monyear.put('days',obj_days_row);
    obj_my_row.put(to_char(v_mcnt-1),obj_monyear);

    json_str_output := obj_my_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  /*
  * PROCEDURE : modify_chkin
  * PARAMETER: p_codempid,p_dtework,p_seqno,p_codcust,p_codjob,p_codreason,p_activity,p_new_namcust,p_phone
  * RETURN   : varchar2[json_str]
  */
  procedure modify_chkin(json_str_input in clob, json_str_output out clob) as
    resp_obj        json_object_t :=  json_object_t();
    resp_str        varchar2(4000 char);
  begin
    initial_value(json_str_input);

    begin
      update tchkin
         set --codjob    = v_codjob,
             codreason = v_codreason,
             activity  = v_activity
       where codempid  = v_codempid
         and dtework   = v_dtework
         and seqno     = v_seqno
         and codcust   = v_codcust;
    end;

    -- update codcustsurv
    begin
      select codcustsurv
        into v_codcustsurv
        from tchkin
       where codempid  = v_codempid
         and dtework   = v_dtework
         and seqno     = v_seqno
         and codcust   = v_codcust;
    exception when no_data_found then
      v_codcustsurv := null;
    end;
    --
    begin
      update tcustsurv
         set namcust       = v_new_namcust,
             namcontact    = v_namcontact,
             numtele       = v_phone
       where codcustsurv   = v_codcustsurv;
    end;

    if substr(v_codcust,1,1) = 'S' then
      begin
        update tcust
        set namcuste = v_new_namcust,
            namcustt = v_new_namcust,
            namcust3 = v_new_namcust,
            namcust4 = v_new_namcust,
            namcust5 = v_new_namcust,
            numtele = v_phone
        where codcust = v_codcust;
      end;
    end if;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

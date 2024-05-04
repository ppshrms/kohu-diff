--------------------------------------------------------
--  DDL for Package Body HRES82E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES82E" is
-- last update: 26/07/2016 11:58


  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');



    p_dtereq            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    p_dteend            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
    p_stabook           := hcm_util.get_string_t(json_obj,'p_stabook');
    p_typasset          := hcm_util.get_string_t(json_obj,'p_typasset');
    ---------------------------------------------
    p_dtereserv         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereserv')),'dd/mm/yyyy');
    p_roomno            := hcm_util.get_string_t(json_obj,'p_roomno');
    p_timstrt           := trim(REPLACE(hcm_util.get_string_t(json_obj,'p_timstrt'),':',''));
    p_timend            := trim(REPLACE(hcm_util.get_string_t(json_obj,'p_timend'),':',''));
    p_seqno             := hcm_util.get_string_t(json_obj,'p_seqno');

    p_qtypers           := hcm_util.get_string_t(json_obj,'p_qtypers');
    p_object            := hcm_util.get_string_t(json_obj,'p_object');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
    p_flgwarning        := hcm_util.get_string_t(json_obj,'p_flgwarning');


  end initial_value;

  function char_time_to_format_time (p_tim varchar2) return varchar2 is
  begin
    if p_tim is not null then
      return substr(p_tim, 1, 2) || ':' || substr(p_tim, 3, 2);
    else
      return p_tim;
    end if;
  exception when others then
    return p_tim;
  end;

  procedure check_index is
    v_count_comp  number := 0;
    v_secur  boolean := false;
  begin
    null;

  end;
  --
 procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt2          number := 0;
    v_pathweb       varchar2(4000 char);
    v_roomno      troomreq.roomno%type;
    v_dte_tempst    date;
    v_dte_tempend   date;

    cursor c1 is
      select roomno, decode(global_v_lang,'101', roomname ,
                                 '102', roomnamt,
                                 '103', roomnam3,
                                 '104', roomnam4,
                                 '105', roomnam5,roomname) roomnam ,
            floor,building,remark,accessori,qtypers,status,codrespon1,codrespon2,namimgroom
        from tcodroom
        where roomno = nvl(p_roomno,roomno)
          and status = 'A'
          order by roomno;

     cursor c2 is
      select roomno,dtereserv,seqno,dtereq,codempid,codcomp,
             remark,timstrt,timend,qtypers,stabook,get_codempid(codcancel) codcancel
        from troomreq
        where roomno = v_roomno
          and dtereserv = p_dtereserv
          and (  v_dte_tempst between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
         and to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or v_dte_tempend between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
         and to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
            between v_dte_tempst and v_dte_tempend
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
            between v_dte_tempst and v_dte_tempend
          )
          order by timstrt;
  begin
    v_dte_tempst := to_date(to_char(p_dtereserv,'dd/mm/yyyy') || ' ' || p_timstrt, 'dd/mm/yyyy hh24mi');
    v_dte_tempend := to_date(to_char(p_dtereserv,'dd/mm/yyyy') || ' ' || p_timend, 'dd/mm/yyyy hh24mi');

    v_rcnt := 0;
    v_rcnt2 := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_rcnt2 := 0;


      for r2 in c2 loop
      v_rcnt2 := v_rcnt ;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seqno', r2.seqno);
      obj_data.put('roomno', r1.roomno);
      obj_data.put('roomnam', r1.roomnam);
      obj_data.put('staasset', 'B');
      if r2.stabook = 'B' then
         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,100));
      elsif r2.stabook = 'C' then
         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,110));
      else
         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,130));
      end if;
      obj_data.put('timeperiod', char_time_to_format_time(r2.timstrt)|| ' - ' || char_time_to_format_time(r2.timend));
      obj_data.put('codbooking', r2.codempid);
      obj_data.put('desc_codbooking', get_temploy_name(r2.codempid,global_v_lang));
      obj_data.put('dtereserv', to_char(r2.dtereserv,'dd/mm/yyyy'));
      obj_data.put('codcancel', r2.codcancel);
      obj_data.put('desc_codcancel', get_temploy_name(r2.codcancel,global_v_lang));

      obj_row.put(to_char(v_rcnt2-1),obj_data);
      v_rcnt := v_rcnt + 1;
      end loop;

      if v_rcnt2 = 0 then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('roomno', r1.roomno);
        obj_data.put('roomnam', r1.roomnam);
        obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,130));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;



      --next_record;
    end loop;


    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcodroom');
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_row.to_clob;
  end;

 procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_popup(json_str_output out clob) is
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_pathweb       varchar2(4000 char);
    v_codasset      tasetinf.codasset%type;
    v_namimage      varchar2(300 char);

    cursor c1 is
      select roomno, decode(global_v_lang,'101', roomname ,
                                 '102', roomnamt,
                                 '103', roomnam3,
                                 '104', roomnam4,
                                 '105', roomnam5,roomname) roomnam ,
            floor,building,remark,accessori,qtypers,status,codrespon1,codrespon2,namimgroom
        from tcodroom
        where roomno = nvl(p_roomno,roomno)
          and status = 'A'
          order by roomno;

  begin

    v_rcnt := 0;
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('roomno', r1.roomno);
      obj_data.put('roomnam', r1.roomnam);
      obj_data.put('staasset', 'B');

      obj_data.put('qtypers', r1.qtypers);
      obj_data.put('accessori', r1.accessori);
      obj_data.put('building', r1.building);
      obj_data.put('floor', r1.floor);
      obj_data.put('codrespon1', get_temploy_name(get_codempid(r1.codrespon1),global_v_lang));
      obj_data.put('codrespon2', get_temploy_name(get_codempid(r1.codrespon2),global_v_lang));

      if r1.namimgroom is not null then
        v_namimage := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO1DE')|| '/' || r1.namimgroom;
      end if;

      obj_data.put('namimgroom', v_namimage);

    end loop;


    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tasetinf');
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_data.to_clob;
  end;

  procedure get_popup (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_popup(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail(json_str_output out clob) is
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt2          number := 0;
    v_pathweb       varchar2(4000 char);
    v_codasset      tasetinf.codasset%type;

    cursor c1 is
      select roomno, decode(global_v_lang,'101', roomname ,
                                 '102', roomnamt,
                                 '103', roomnam3,
                                 '104', roomnam4,
                                 '105', roomnam5,roomname) roomnam ,
            floor,building,remark,accessori,qtypers,status,codrespon1,codrespon2,namimgroom
        from tcodroom
        where roomno = nvl(p_roomno,roomno)
          and status = 'A'
          order by roomno;

     cursor c2 is
      select roomno,dtereserv,seqno,dtereq,codempid,codcomp,
             remark,timstrt,timend,qtypers,object,stabook
        from troomreq
        where roomno = p_roomno
          and dtereserv = p_dtereserv
          and seqno = p_seqno;

  begin

    v_rcnt := 0;
    v_rcnt2 := 0;
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_rcnt2 := 0;

      for r2 in c2 loop
      v_rcnt2 := v_rcnt2 + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('roomno', r1.roomno);
      obj_data.put('dtereq', to_char(r2.dtereq,'dd/mm/yyyy'));
      obj_data.put('dtereserv', to_char(r2.dtereserv,'dd/mm/yyyy'));
      obj_data.put('timstrt', char_time_to_format_time(r2.timstrt));
      obj_data.put('timend', char_time_to_format_time(r2.timend));
      obj_data.put('object', r2.object);
      obj_data.put('remark', r2.remark);


      obj_data.put('staasset', 'B');
      obj_data.put('stabook', r2.stabook);
      obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,100));

      obj_data.put('seqno', r2.seqno);
      obj_data.put('qtypers', r2.qtypers);

      if global_v_codempid = r1.codrespon1 or global_v_codempid = r1.codrespon2 or global_v_codempid = r2.codempid then
     -- flgDisable = (คนจอง === คน login || คนที่มีสิทธิ์ยกเลิก => false , (dtereserv น้อยกว่า sysdate => true)
       if trunc(r2.dtereserv) < trunc(sysdate) then
          obj_data.put('flgDisable', true);
       else
          obj_data.put('flgDisable', false);
       end if;
      else
        obj_data.put('flgDisable', true);
      end if;

      end loop;
      if v_rcnt2 = 0 then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('roomno', r1.roomno);
        obj_data.put('dtereserv', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('flgDisable', false);
      end if;
    end loop;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_detail (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail_save as
   p_temp         varchar2(100 char);
   v_secur        boolean := false;
   v_dte_tempst   date;
   v_dte_tempend  date;
   v_temp         number :=0;
   v_exist        varchar2(1 char) := 'N';
  begin
    v_dte_tempst := to_date(to_char(p_dtereserv,'dd/mm/yyyy') || ' ' || p_timstrt, 'dd/mm/yyyy hh24mi')+(+1/1440);
    v_dte_tempend := to_date(to_char(p_dtereserv,'dd/mm/yyyy') || ' ' || p_timend, 'dd/mm/yyyy hh24mi');
    if v_dte_tempend < sysdate  then
      param_msg_error := get_error_msg_php('ES0072',global_v_lang);
      return;
    end if;

    if p_seqno is not null then
       v_exist := 'Y';
    end if;
    begin
      select count(*)
        into v_temp
        from troomreq
       where roomno = p_roomno
         and stabook = 'B'
         and
          (  v_dte_tempst between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')+(+1/1440)
         and to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or v_dte_tempend between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi') +(+1/1440)
         and to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi') +(+1/1440)
            between v_dte_tempst and v_dte_tempend
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
            between v_dte_tempst and v_dte_tempend

          )
          and ((p_seqno is null) or (p_seqno is not null and seqno <> p_seqno) )
         ;
     exception when no_data_found then
      v_temp := 0;
    end;


    if v_temp > 0 then
      param_msg_error := get_error_msg_php('HR3009',global_v_lang);
      return;
    end if;


  end;

  procedure detail_save(json_str_output out clob) as
    param_json_row    json_object_t;
    obj_data        json_object_t;
    v_flg             varchar2(100 char);
    v_codcomp         temploy1.codcomp%type;
    v_seqno           tassetreq.seqno%type;
    v_codcancel       tassetreq.codcancel%type;
    v_qtypers         tcodroom.qtypers%type;
    v_flgsave         boolean := true;
  begin

    begin
      select qtypers into v_qtypers
      from tcodroom
      where roomno = p_roomno;
    exception when no_data_found then
      v_qtypers := 0;
    end;

    if p_qtypers > v_qtypers then
       if p_flgwarning = 'Y' then
          v_flgsave := true;
        else
          v_flgsave := false;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('response',replace(get_error_msg_php('ES0073',global_v_lang),'@#$%400',''));
          obj_data.put('flg','Y');
          json_str_output := obj_data.to_clob;
        end if;
      end if;

      if v_flgsave then
          if p_seqno is null then
                begin
                  select count(seqno)+1
                    into v_seqno
                    from troomreq
                   where roomno = p_roomno
                     and dtereserv = p_dtereserv;
                exception when no_data_found then
                  v_seqno := 1;
                end;
              else
                v_seqno := p_seqno;
              end if;

              begin
                select codcomp
                  into v_codcomp
                  from temploy1
                 where codempid = global_v_codempid;
              exception when no_data_found then
                  v_codcomp := null;
              end;

              if p_stabook = 'C' then
                v_codcancel := global_v_coduser;
              end if;

              begin
                  insert into troomreq (roomno,dtereserv,seqno,dtereq,codempid,codcomp,
                                        object,remark,timstrt,timend,qtypers,stabook,codcancel,
                                        dtecreate,codcreate,dteupd,coduser)
                  values (p_roomno,p_dtereserv,v_seqno,p_dtereq,global_v_codempid,v_codcomp,
                                        p_object,p_remark,p_timstrt,p_timend,p_qtypers,p_stabook ,v_codcancel,
                                         sysdate, global_v_coduser, sysdate, global_v_coduser);
              exception when dup_val_on_index then
                  update troomreq
                     set object     = p_object,
                         timstrt    = p_timstrt,
                         timend     = p_timend,
                         stabook    = p_stabook,
                         qtypers    = p_qtypers,
                         codcancel  = v_codcancel,
                         remark     = p_remark,
                         dteupd     = sysdate,
                         coduser    = global_v_coduser
                   where roomno     = p_roomno
                         and dtereserv = p_dtereserv
                         and seqno     = v_seqno;
              end;

              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('response',replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201',''));
              obj_data.put('flg','');
              obj_data.put('seqno',v_seqno);
              json_str_output := obj_data.to_clob;

--              param_msg_error := get_error_msg_php('HR2401',global_v_lang);
--              json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  end ;

  procedure post_detail_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail_save;
    if param_msg_error is null or param_msg_error = 'ES0073' then
      detail_save(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_schedule(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt2          number := 0;
    v_pathweb       varchar2(4000 char);
    v_roomno      troomreq.roomno%type;
    v_stdate    date;
    v_endate   date;
    v_year          varchar2(4 char);

--    cursor c1 is
--      select roomno, decode(global_v_lang,'101', roomname ,
--                                 '102', roomnamt,
--                                 '103', roomnam3,
--                                 '104', roomnam4,
--                                 '105', roomnam5,roomname) roomnam ,
--            floor,building,remark,accessori,qtypers,status,codrespon1,codrespon2,namimgroom
--        from tcodroom
--        where roomno = nvl(p_roomno,roomno)
--          and status = 'A'
--          order by roomno;
--
--     cursor c2 is
--      select roomno,dtereserv,seqno,dtereq,codempid,codcomp,
--             remark,timstrt,timend,qtypers,stabook
--        from troomreq
--        where roomno = v_roomno
--          and dtereserv = p_dtereserv
--          and stabook = 'B'
--          order by timstrt;

      cursor c1 is
      select a.roomno,a.dtereserv,a.seqno,a.dtereq,a.codempid,a.codcomp,
             a.remark,a.timstrt,a.timend,a.qtypers,a.stabook,
             decode(global_v_lang,'101', roomname ,
                                 '102', roomnamt,
                                 '103', roomnam3,
                                 '104', roomnam4,
                                 '105', roomnam5,roomname) roomnam
        from troomreq a, tcodroom b
        where dtereserv between v_stdate and v_endate
          and stabook = 'B'
          and a.roomno = b.roomno
          order by timstrt;

  begin
     v_year := to_char(p_dtereserv,'YYYY');
     v_stdate := to_date('01/01/'||to_char(v_year),'dd/mm/yyyy');
     v_endate := to_date('31/12/'||to_char(v_year),'dd/mm/yyyy');

    v_rcnt := 0;
    v_rcnt2 := 0;
    obj_row := json_object_t();
    obj_data := json_object_t();
--    for r1 in c1 loop
--      v_rcnt := v_rcnt+1;
--      v_rcnt2 := 0;
--      v_roomno := r1.roomno;
--
--      for r2 in c2 loop
--      v_rcnt2 := v_rcnt ;
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('seqno', r2.seqno);
--      obj_data.put('roomno', r1.roomno);
--      obj_data.put('desc_roomno', r1.roomnam);
--      obj_data.put('stabook', r2.stabook);
--      if r2.stabook = 'B' then
--         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,100));
--      elsif r2.stabook = 'C' then
--         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,110));
--      else
--         obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,130));
--      end if;
--      obj_data.put('timstrt', char_time_to_format_time(r2.timstrt));
--      obj_data.put('timend', char_time_to_format_time(r2.timend));
--      obj_data.put('codbooking', r2.codempid);
--      obj_data.put('codempid', r2.codempid);
--      obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
--      obj_data.put('dtereserv', to_char(r2.dtereserv,'dd/mm/yyyy'));
--      obj_row.put(to_char(v_rcnt2-1),obj_data);
--      v_rcnt := v_rcnt + 1;
--      end loop;
--    end loop;
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seqno', r1.seqno);
      obj_data.put('roomno', r1.roomno);
      obj_data.put('desc_roomno', r1.roomnam);
      obj_data.put('stabook', r1.stabook);
      obj_data.put('desc_stabook',  get_label_name('HRES83EC2',global_v_lang,100));
      obj_data.put('timstrt', char_time_to_format_time(r1.timstrt));
      obj_data.put('timend', char_time_to_format_time(r1.timend));
      obj_data.put('codbooking', r1.codempid);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('dtereserv', to_char(r1.dtereserv,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
      v_rcnt := v_rcnt + 1;
      end loop;


    json_str_output := obj_row.to_clob;
  end;

 procedure get_schedule (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
--        check_index();
        if param_msg_error is null then
            gen_schedule(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

--------------------------------------------------------
--  DDL for Package Body HRES83E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES83E" is
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

    p_dtereserv         := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereserv')),'dd/mm/yyyy');
    p_codasset          := hcm_util.get_string_t(json_obj,'p_codasset');
    p_timstrt           := trim(REPLACE(hcm_util.get_string_t(json_obj,'p_timstrt'),':',''));
    p_timend            := trim(REPLACE(hcm_util.get_string_t(json_obj,'p_timend'),':',''));
    p_seqno             := hcm_util.get_string_t(json_obj,'p_seqno');

    p_dtereq            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    p_dteend            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
    p_object            := hcm_util.get_string_t(json_obj,'p_object');
    p_stabook           := hcm_util.get_string_t(json_obj,'p_stabook');
    p_typasset          := hcm_util.get_string_t(json_obj,'p_typasset');



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
    v_codasset      tasetinf.codasset%type;
    v_dte_tempst    date;
    v_dte_tempend   date;
    cursor c1 is
      select codasset, decode(global_v_lang,'101', desassee ,
                                 '102', desasset,
                                 '103', desasse3,
                                 '104', desasse4,
                                 '105', desasse5,desassee) desasse ,dterec,
             desnote,srcasset,typasset,namimage,comimage,staasset
        from tasetinf
        where codasset = nvl(p_codasset,codasset)
          and flgasset = 2
          order by codasset;

     cursor c2 is
      select assetno,dtereserv,seqno,dtereq,codempid,typasset,codcomp,
             object,timstrt,timend,stabook
        from tassetreq
        where assetno = v_codasset
          and dtereserv = p_dtereserv
          and not (  v_dte_tempst between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
         and to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or v_dte_tempend between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
         and to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')
            between v_dte_tempst and v_dte_tempend
         or to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
            between v_dte_tempst and v_dte_tempend
         and stabook <> 'B'
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
      v_codasset := r1.codasset;

      for r2 in c2 loop
      v_rcnt2 := v_rcnt ;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('seqno', r2.seqno);
      obj_data.put('codasset', r1.codasset);
      obj_data.put('desc_codasset', r1.desasse);
      obj_data.put('staasset', 'B');
      if r2.stabook = 'B' then
         obj_data.put('desc_staasset',  get_label_name('HRES83EC2',global_v_lang,100));
      elsif r2.stabook = 'C' then
         obj_data.put('desc_staasset',  get_label_name('HRES83EC2',global_v_lang,110));
      else
         obj_data.put('desc_staasset',  get_label_name('HRES83EC2',global_v_lang,130));
      end if;
      obj_data.put('timeperiod', char_time_to_format_time(r2.timstrt)|| ' - ' || char_time_to_format_time(r2.timend));
      obj_data.put('codbooking', r2.codempid);
      obj_data.put('desc_codbooking', get_temploy_name(r2.codempid,global_v_lang));
      obj_data.put('dtereserv', to_char(r2.dtereserv,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt2-1),obj_data);
      v_rcnt := v_rcnt + 1;
      end loop;

      if v_rcnt2 = 0 then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codasset', r1.codasset);
        obj_data.put('desc_codasset', r1.desasse);
        obj_data.put('desc_staasset',  get_label_name('HRES83EC2',global_v_lang,130));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;



      --next_record;
    end loop;


    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tasetinf');
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
      select codasset, decode(global_v_lang,'101', desassee ,
                                 '102', desasset,
                                 '103', desasse3,
                                 '104', desasse4,
                                 '105', desasse5,desassee) desasse ,dterec,
             desnote,srcasset,typasset,namimage,comimage,staasset
        from tasetinf
        where codasset = p_codasset
          and flgasset = 2
          order by codasset;

  begin

    v_rcnt := 0;
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codasset', r1.codasset);
      obj_data.put('desasse', r1.desasse);
      obj_data.put('dterec', to_char(r1.dterec,'dd/mm/yyyy'));
      obj_data.put('desnote', r1.desnote);
      obj_data.put('srcasset', r1.srcasset);
      obj_data.put('typasset', get_tcodec_name('tcodasst' ,r1.typasset ,global_v_lang));
      obj_data.put('comimage', r1.comimage);
      obj_data.put('staasset', r1.staasset);

      if r1.namimage is not null then
        v_namimage := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPM1EE')|| '/' || r1.namimage;
      end if;

      obj_data.put('namimage', v_namimage);

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
      select codasset, decode(global_v_lang,'101', desassee ,
                                 '102', desasset,
                                 '103', desasse3,
                                 '104', desasse4,
                                 '105', desasse5,desassee) desasse ,dterec,
             desnote,srcasset,typasset,namimage,comimage,staasset,codrespon,codrespon2
        from tasetinf
        where codasset = p_codasset
          and flgasset = 2
          order by codasset;

     cursor c2 is
      select assetno,dtereserv,seqno,dtereq,codempid,typasset,codcomp,
             object,timstrt,timend,dteend,stabook
        from tassetreq
        where assetno = p_codasset
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
      obj_data.put('codasset', r1.codasset);
      obj_data.put('typasset', r1.typasset);
      obj_data.put('desc_typasset', get_tcodec_name('tcodasst' ,r1.typasset ,global_v_lang));
      obj_data.put('dtereq', to_char(r2.dtereq,'dd/mm/yyyy'));
      obj_data.put('dtereserv', to_char(r2.dtereserv,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(r2.dteend,'dd/mm/yyyy'));
      obj_data.put('timstrt', char_time_to_format_time(r2.timstrt));
      obj_data.put('timend', char_time_to_format_time(r2.timend));
      obj_data.put('object', r2.object);


      obj_data.put('staasset', 'B');
      obj_data.put('stabook', r2.stabook);
      obj_data.put('desc_staasset',  get_label_name('HRES83EC2',global_v_lang,100));

      obj_data.put('seqno', r2.seqno);

      if global_v_codempid = r1.codrespon or global_v_codempid = r1.codrespon2 or global_v_codempid = r2.codempid then
        obj_data.put('flgDisable', false);
      else
        obj_data.put('flgDisable', true);
      end if;

      end loop;
      if v_rcnt2 = 0 then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codasset', r1.codasset);
        obj_data.put('desc_codasset', r1.desasse);
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
    v_dte_tempst := to_date(to_char(p_dtereserv,'dd/mm/yyyy') || ' ' || p_timstrt, 'dd/mm/yyyy hh24mi');
    v_dte_tempend := to_date(to_char(p_dteend,'dd/mm/yyyy') || ' ' || p_timend, 'dd/mm/yyyy hh24mi');
    if v_dte_tempend < sysdate  then
      param_msg_error := get_error_msg_php('ES0071',global_v_lang);
      return;
    end if;

    if p_seqno is not null then
       v_exist := 'Y';
    end if;
    begin
      select count(*)
        into v_temp
        from tassetreq
       where assetno = p_codasset
         and stabook = 'B'
         and
          (  v_dte_tempst between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi')+(+1/1440)
         and to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or v_dte_tempend between
             to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi') +(+1/1440)
         and to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
         or to_date(to_char(dtereserv,'dd/mm/yyyy') || ' ' || timstrt, 'dd/mm/yyyy hh24mi') +(+1/1440)
            between v_dte_tempst and v_dte_tempend
         or to_date(to_char(dteend,'dd/mm/yyyy') || ' ' || timend, 'dd/mm/yyyy hh24mi')
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
    param_json        json_object_t;
    v_flg             varchar2(100 char);
    v_codcomp         temploy1.codcomp%type;
    v_seqno           tassetreq.seqno%type;
    v_codcancel       tassetreq.codcancel%type;
  begin

    if p_seqno is null then
      begin
        select nvl(max(seqno),0)+1
          into v_seqno
          from tassetreq
         where assetno = p_codasset
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
        insert into tassetreq (assetno,dtereserv,seqno,dtereq,codempid,typasset,codcomp,
                              object,timstrt,timend,dteend,stabook,codcancel,
                              dtecreate,codcreate,dteupd,coduser)
        values (p_codasset,p_dtereserv,v_seqno,p_dtereq,global_v_codempid,p_typasset,v_codcomp,
                              p_object,p_timstrt,p_timend,p_dteend,p_stabook,v_codcancel,
                sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tassetreq
           set object = p_object,
               timstrt = p_timstrt,
               timend = p_timend,
               stabook = p_stabook,
               codcancel = v_codcancel,
               dteupd = sysdate,
               coduser = global_v_coduser
         where assetno = p_codasset
               and dtereserv = p_dtereserv
               and seqno = v_seqno;
    end;


    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  end ;

  procedure post_detail_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail_save;
    if param_msg_error is null then
      detail_save(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


end;

/

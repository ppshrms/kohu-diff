--------------------------------------------------------
--  DDL for Package Body HRAL22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL22E" is
-- last update : 10/08/2020
  function get_codcenter(p_codcomp in varchar2) return varchar2 is
    v_codcenter  varchar2(1000 char);
  begin
    begin
     select costcent into v_codcenter
        from tcenter
       where codcomp = p_codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;
    return v_codcenter;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    p_codcompo          := replace(hcm_util.get_string_t(json_obj,'p_codcompo'),'-','');
    p_codcomp           := replace(hcm_util.get_string_t(json_obj,'p_codcompn'),'-','');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalenn');
    p_codcaleno         := hcm_util.get_string_t(json_obj,'p_codcaleno');
    p_codshifto         := hcm_util.get_string_t(json_obj,'p_codshold');
    p_codshift          := hcm_util.get_string_t(json_obj,'p_codshnew');
    p_timoutst          := hcm_util.get_string_t(json_obj,'p_v_timoutst');
    p_timouten          := hcm_util.get_string_t(json_obj,'p_v_timouten');
    p_flghead           := hcm_util.get_string_t(json_obj,'p_chnghead');
    p_codempidh         := hcm_util.get_string_t(json_obj,'p_codhead');
    p_deschhr           := hcm_util.get_string_t(json_obj,'p_noteupdate');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_approvby');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteapprov'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_code    varchar2(100);
  begin

    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codempid');
      return;
    else
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtestrt');
      return;
    end if;

--    if p_dteend is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteend');
--      return;
--    end if;

  end check_index;

  procedure check_detail is
    v_code    varchar2(100);
    v_count   number  := 0;
    v_chk     number  := 0;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codempid');
      return;
    else
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtestrt');
      return;
    end if;

    --<<User37 #5147 Final Test Phase 1 V11 09/03/2021  
    begin
     select count(*) into v_count
        from twkchhr
       where codempid = p_codempid
         and dtestrt  = p_dtestrt 
         and dteend   = p_dteend;
    exception when no_data_found then
      v_count := 0;
    end;

    if nvl(v_count,0) = 0 then
        begin
            select count(*) into v_chk
            from twkchhr
           where codempid =  p_codempid
             and (dtestrt between p_dtestrt and p_dteend
              or   dteend between p_dtestrt and p_dteend
              or p_dtestrt between dtestrt  and dteend
              or p_dteend  between dtestrt  and dteend)
             and rownum = 1;
        end;
        if nvl(v_chk,0) > 0   then
            param_msg_error := get_error_msg_php('AL0062',global_v_lang);
            return;
        end if;
    end if;
    /*begin
     select count(*) into v_count
        from twkchhr
       where codempid = p_codempid
         and dtestrt  = p_dtestrt ;
    exception when no_data_found then
      v_count := 0;
    end;

    if nvl(v_count,0) = 0 then
      select count(*) into v_chk
        from twkchhr
       where codempid =  p_codempid
         and dtestrt  <> p_dtestrt
         and (dtestrt between p_dtestrt and p_dteend
          or   dteend between p_dtestrt and p_dteend
          or p_dtestrt between dtestrt  and dteend
          or p_dteend  between dtestrt  and dteend)
         and rownum = 1;

      if nvl(v_chk,0) > 0   then
        param_msg_error := get_error_msg_php('AL0062',global_v_lang);
        return;
      end if;
    end if;*/
    -->>User37 #5147 Final Test Phase 1 V11 09/03/2021   
  end check_detail;

  procedure check_save is
    v_code    varchar2(100);
    v_count   number := 0;
    v_codshift  tshifcom.codshift%type;
  begin
    if p_codcomp  is null and p_codcalen is null and
		   p_timoutst is null and p_timouten is null and
		   p_codshift is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_codcalen is not null then
      begin
        select count(*) into v_count
          from tcodwork
         where codcodec = p_codcalen;
      exception when no_data_found then
        null;
      end;

      if nvl(v_count,0) = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcalen');
        return;
      end if;
    end if;

    if p_codshift is not null then
      begin
        select count(*) into v_count
          from tshiftcd
         where codshift = p_codshift;
      exception when no_data_found then
        null;
      end;

      if nvl(v_count,0) = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codshift');
        return;
      end if;

      begin
        select codshift into v_codshift
          from tshifcom a, temploy1 b
         where a.codcompy = hcm_util.get_codcomp_level(b.codcomp,1)
           and b.codempid = p_codempid
           and a.codshift = p_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('AL0061',global_v_lang);
        return;
      end;
    end if;

    if p_codempidh is not null then
      if not secur_main.secur2(p_codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_codappr is not null then
      if not secur_main.secur2(p_codappr,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_deschhr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'deschhr');
      return;
    end if;

    if p_flghead = 'Y' then
      if p_codempidh is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempidh');
        return;
      end if;
    end if;
  end check_save;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_timoutst      varchar2(10);
	  v_timouten      varchar2(10);
    v_timoutside    varchar2(100);
    v_pathfile      varchar2(100);

    cursor c1 is
      select codempid, codcomp, dtestrt, dteend, codcalen, codshift, timoutst, timouten
        from twkchhr
       where codempid = p_codempid
         and ((dtestrt between p_dtestrt and p_dteend)
          or  (dteend  between p_dtestrt and p_dteend)
          or  (p_dtestrt between dtestrt and dteend))
        order by dtestrt;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt+1;

--      if i.codshift is not null then
        v_timoutst  := null;
        v_timouten  := null;
        v_timoutside := null;
        --
        if i.timoutst is not null then
          v_timoutst	:=	substr(i.timoutst,1,2)||':'||substr(i.timoutst,3,2);
        end if;
        if i.timouten is not null then
          v_timouten	:=	substr(i.timouten,1,2)||':'||substr(i.timouten,3,2);
        end if;
        if v_timoutst is not null and i.timouten is not null then
          v_timoutside := v_timoutst ||' - '|| v_timouten;
        end if;
--      end if;

--      if i.codshnew is not null then
--        if :lst_twkchhr.timin is not null then
--            v_timein := substr(:lst_twkchhr.timin,1,2)||':'||substr(:lst_twkchhr.timin,3,2);
--        end if ;
--        if :lst_twkchhr.timout is not null then
--            v_timeout := substr(:lst_twkchhr.timout,1,2)||':'||substr(:lst_twkchhr.timout,3,2);
--        end if ;
--        :lst_twkchhr.timewk := v_timein ||' - '|| v_timeout;
--        end if;
--      end if;

      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('codempid',i.codempid);
      obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('codcalen',i.codcalen);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));
      obj_data.put('codshnew',i.codshift);
      obj_data.put('desc_codshnew',get_tshiftcd_name(i.codshift,global_v_lang));
      obj_data.put('timewk',v_timoutside);
      v_pathfile := get_emp_img (i.codempid);
      obj_data.put('image', v_pathfile);
--      obj_data.put('timoutside',v_timoutside);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data;

  procedure get_index_head(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
    v_codempid    varchar2(1000 char);
    v_namimage    varchar2(1000 char);
    v_pathfile    varchar2(1000 char);
    v_folder      varchar2(1000 char);
    v_dtestrt     date;
    v_dteend      date;
    v_total       number := 0;

  begin
    initial_value(json_str_input);
    begin
      select codempid, dtestrt, dteend
        into v_codempid, v_dtestrt, v_dteend
        from twkchhr
       where codempid = p_codempid
         and rownum <= 1;
    exception when no_data_found then
       v_total := 0;
    end;

    begin
      select folder
        into v_folder
        from tfolderd
       where codapp = 'HRAL22E';
    exception when no_data_found then
      v_folder := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
    obj_row.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));
    obj_row.put('codempid', v_codempid);
    obj_row.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));

    v_pathfile := get_emp_img (v_codempid);
    obj_row.put('image', v_pathfile);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_worktime_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_index;

    check_detail;
    if param_msg_error is null then
      gen_worktime_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_worktime_detail;

  procedure gen_worktime_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number := 0;
    v_total2        number := 0;
    cursor c1 is
      select codcompo, codcomp, codcaleno, codcalen, codshifto, codshift,
             timoutst, timouten, flghead, codempidh, deschhr, codappr, dteappr
        from twkchhr
       where codempid = p_codempid
         and dtestrt  = p_dtestrt;

    cursor c2 is
      select codcomp, codcalen, codshift
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtestrt;
  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for i in c1 loop
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');

        obj_data.put('codcompo',i.codcompo);
        obj_data.put('desc_codcompo',get_tcenter_name(i.codcompo,global_v_lang));
        obj_data.put('codcompn',i.codcomp);
        obj_data.put('codcentero',get_codcenter(i.codcompo));
        obj_data.put('codcentern',get_codcenter(i.codcomp));
        obj_data.put('codcaleno',i.codcaleno);
        obj_data.put('desc_codcaleno',get_tcodec_name('TCODWORK',i.codcaleno,global_v_lang));
        obj_data.put('codcalenn',i.codcalen);
        obj_data.put('codshold',i.codshifto);
        obj_data.put('desc_codshold',get_tshiftcd_name(i.codshifto,global_v_lang));
        obj_data.put('codshnew',i.codshift);
        obj_data.put('v_timoutst',i.timoutst);
        obj_data.put('v_timouten',i.timouten);
        obj_data.put('chnghead',i.flghead);
        obj_data.put('codhead',i.codempidh);
        obj_data.put('noteupdate',i.deschhr);
        obj_data.put('approvby',i.codappr);
        obj_data.put('dteapprov',to_char(i.dteappr,'dd/mm/yyyy'));
      end loop;
    else
      for i in c2 loop
        v_total2 := v_total2 + 1;
      end loop;
      if v_total2 > 0 then
        for i in c2 loop
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('codcompo', i.codcomp);
          obj_data.put('codcentero',get_codcenter(i.codcomp));
          obj_data.put('codcaleno', i.codcalen);
          obj_data.put('codshold', i.codshift);
          obj_data.put('approvby',b_index_codempid);
          obj_data.put('dteapprov',to_char(sysdate,'dd/mm/yyyy'));
        end loop;
      else
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('codcompo', '');
          obj_data.put('codcaleno', '');
          obj_data.put('codshold', '');
      end if;
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_worktime_detail;

  procedure post_worktime_detail(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      save_worktime_detail;
      update_tattence(p_codempid, p_dtestrt, global_v_coduser, 'I');
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    END IF;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_worktime_detail;

  procedure save_worktime_detail is
    v_count     number := 0;
  begin
    begin
      select count(*) into v_count
        from twkchhr
       where codempid = p_codempid
         and dtestrt  = p_dtestrt;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      insert into twkchhr (codempid, dtestrt, dteend, codcompo, codcomp, codcaleno, codcalen, codshifto, codshift,
                           timoutst, timouten, flghead, codempidh, deschhr, codappr, dteappr, dteupd, coduser, codcreate)
           values (p_codempid, p_dtestrt, p_dteend, p_codcompo, p_codcomp, p_codcaleno, p_codcalen, p_codshifto, p_codshift,
                   p_timoutst, p_timouten, p_flghead, p_codempidh, p_deschhr, nvl(p_codappr, p_codempid), nvl(p_dteappr, trunc(sysdate)),
                   trunc(sysdate), global_v_coduser, global_v_coduser);
    else
      update twkchhr set dteend    = p_dteend,
                         codcompo  = p_codcompo,
                         codcomp   = p_codcomp,
                         codcaleno = p_codcaleno,
                         codcalen  = p_codcalen,
                         codshifto = p_codshifto,
                         codshift  = p_codshift,
                         timoutst  = p_timoutst,
                         timouten  = p_timouten,
                         flghead   = p_flghead,
                         codempidh = p_codempidh,
                         deschhr   = p_deschhr,
                         codappr   = nvl(p_codappr, p_codempid),
                         dteappr   = nvl(p_dteappr, trunc(sysdate)),
                         dteupd    = trunc(sysdate),
                         coduser   = global_v_coduser,
                         codcreate = global_v_coduser
                   where codempid  = p_codempid
                     and dtestrt   = p_dtestrt;

    end if;
  end save_worktime_detail;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    json_obj        json_object_t;
    json_obj2       json_object_t;

  begin
    json_obj     :=  hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..json_obj.get_size-1 loop
        json_obj2   := hcm_util.get_json_t(json_obj,to_char(i));

        p_codempid       := hcm_util.get_string_t(json_obj2,'codempid');
        p_dtestrt        := to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy');

        begin
          delete from twkchhr
                where codempid  = p_codempid
                  and dtestrt   = p_dtestrt;
        end;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure get_codcenter(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codcenter   varchar2(1000 char);
    v_codcomp     varchar2 (1000 char);
    v_total       number := 0;
  begin
    v_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
    begin
      select costcent into v_codcenter
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcenter', v_codcenter);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure update_tattence(p_codempid varchar2, p_dtewoek varchar2, p_coduser varchar2, p_type varchar2) is --p_type = I (insert TWKCHHR), D (Delete TWKCHHR) ไม่ต้องทำกรณีลบ เผื่อไว้
    v_dtestrt			tattence.dtework%type;
    v_dteend			tattence.dtework%type;
    v_dtestrtw	  tattence.dtework%type;
    v_dteendw  		tattence.dtework%type;
    v_timstrtw 		tattence.timstrtw%type;
    v_timendw  		tattence.timendw%type;
    v_typwork  		tattence.typwork%type;
    v_typworko 		tattence.typwork%type;
    v_codshift    tattence.codshift%type;
    v_codshifto   tattence.codshift%type;
    v_codcalen    tattence.codcalen%type;
    v_codcaleno   tattence.codcalen%type;

    cursor c_twkchhr is
      select codempid,dtestrt,dteend,codcalen,codshift
        from twkchhr
       where codempid   = p_codempid
         and dtestrt    = p_dtewoek
         and(codcalen   is not null
          or codshift   is not null);

    cursor c_tattence is
      select rowid,codempid,dtework,codcomp,codcalen,typwork,codshift
        from tattence
       where codempid   = p_codempid
         and dtework    between v_dtestrt and v_dteend
         and dtework    >= trunc(sysdate)
         and dtein      is null
         and dteout     is null
    order by dtework;

  begin
    for r_twkchhr in c_twkchhr loop
      v_dtestrt := r_twkchhr.dtestrt;
      v_dteend  := r_twkchhr.dteend;

      if p_type = 'I' then -- insert

        for r_tattence in c_tattence loop
          v_codcalen := null;
          v_codshift := null;
          v_typwork  := null;

          if r_twkchhr.codcalen is not null then
            begin
              select codshift,typwork,codcalen into v_codshift,v_typwork,v_codcalen
                from tgrpplan
               where codcomp  = get_tgrpwork_codcomp(r_tattence.codcomp,r_tattence.codcalen)
                 and codcalen = r_twkchhr.codcalen
                 and dtework  = r_tattence.dtework;
            exception when no_data_found then null;
            end;

          elsif r_twkchhr.codshift is not null then
            v_codcalen := r_tattence.codcalen;
            v_codshift := r_twkchhr.codshift;
            v_typwork  := r_tattence.typwork;
          end if;

          if v_codcalen <> r_tattence.codcalen or v_codshift <> r_tattence.codshift or v_typwork <> r_tattence.typwork then
            v_dtestrtw := null; v_timstrtw := null;
            v_dteendw  := null; v_timendw  := null;
            begin
              select timstrtw,timendw into v_timstrtw,v_timendw
                from tshiftcd
               where codshift = v_codshift;
            exception when no_data_found then null;
            end;

            v_dtestrtw := r_tattence.dtework;
            v_dteendw  := r_tattence.dtework;
            if to_number(v_timstrtw) >= to_number(v_timendw) then
              v_dteendw := v_dtestrtw + 1;
            end if;
            update tattence
               set codcalen = v_codcalen,
                   codshift = v_codshift,
                   dtestrtw = v_dtestrtw,
                   timstrtw = v_timstrtw,
                   dteendw  = v_dteendw,
                   timendw  = v_timendw,
                   typwork  = v_typwork
             where rowid    = r_tattence.rowid;

            -- insert tlogtime
            if v_codcalen = r_tattence.codcalen then
              v_codcaleno 	:= null;
              v_codcalen		:= null;
            else
              v_codcaleno 	:= r_tattence.codcalen;
            end if;

            if v_codshift = r_tattence.codshift then
              v_codshifto 	:= null;
              v_codshift		:= null;
            else
              v_codshifto 	:= r_tattence.codshift;
            end if;

            if v_typwork = r_tattence.typwork then
              v_typworko   	:= null;
              v_typwork  		:= null;
            else
              v_typworko  	:= r_tattence.typwork;
            end if;

            insert into tlogtime(codempid,dtework,dteupd,
                                 codshift,codcomp,
                                 codcalennew,codcalenold,codshifnew,codshifold,typworknew,typworkold,
                                 coduser,dtecreate,codcreate)
                          values(r_tattence.codempid,r_tattence.dtework,sysdate,
                                 nvl(v_codshift,r_tattence.codshift),r_tattence.codcomp,
                                 v_codcalen,v_codcaleno,v_codshift,v_codshifto,v_typwork,v_typworko,
                                 p_coduser,sysdate,p_coduser);
            -- update tattence
/*            if v_codcalen <> r_tattence.codcalen or v_codshift <> r_tattence.codshift then
              v_dtestrtw := null; v_timstrtw := null;
              v_dteendw  := null; v_timendw  := null;
              begin
                select timstrtw,timendw into v_timstrtw,v_timendw
                  from tshiftcd
                 where codshift = v_codshift;
              exception when no_data_found then null;
              end;

              v_dtestrtw := r_tattence.dtework;
              v_dteendw  := r_tattence.dtework;
              if to_number(v_timstrtw) >= to_number(v_timendw) then
                v_dteendw := v_dtestrtw + 1;
              end if;
              --
              update tattence
                 set codcalen = v_codcalen,
                     codshift = v_codshift,
                     dtestrtw = v_dtestrtw,
                     timstrtw = v_timstrtw,
                     dteendw  = v_dteendw,
                     timendw  = v_timendw
               where rowid    = r_tattence.rowid;
            end if;
            --
            if v_typwork <> r_tattence.typwork then
              update tattence
                 set typwork  = v_typwork
               where rowid    = r_tattence.rowid;
            end if; -- v_codshift <> r_tattence.codshift
            */
          end if; -- v_codshift <> r_tattence.codshift or v_typwork <> r_tattence.typwork
        end loop; -- for r_tattence
      elsif p_type = 'D' then -- delete
        null;--ไม่ต้องทำกรณีลบ เผื่อไว้
      end if; -- p_type = 'I'
      commit;
    end loop; -- for c_twkchhr
  end;
END HRAL22E;

/

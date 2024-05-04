--------------------------------------------------------
--  DDL for Package Body HRAL59E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL59E" is
  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dtereq  :=  to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy');

    p_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_stdate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_stdate')),'dd/mm/yyyy');
    p_endate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_endate')),'dd/mm/yyyy');
    p_numlereqg   := hcm_util.get_string_t(json_obj,'p_numlereqg');
    p_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_codleave    := hcm_util.get_string_t(json_obj,'p_codleave');
    p_dteleave    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteleave')),'dd/mm/yyyy');
    p_dtestrt     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestrt')),'dd/mm/yyyy');
    p_timstrt     := replace(hcm_util.get_string_t(json_obj,'p_timstrt'),':');
    p_dteend      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
    p_timend      := replace(hcm_util.get_string_t(json_obj,'p_timend'),':');
    p_deslereq    := hcm_util.get_string_t(json_obj,'p_deslereq');
    p_dteappr     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteappr')),'dd/mm/yyyy');
    p_codappr     := hcm_util.get_string_t(json_obj,'p_codappr');
    p_flgleave    := hcm_util.get_string_t(json_obj,'p_flgleave');
    --
    param_flgwarn := hcm_util.get_string_t(json_obj,'flgwarning');
    p_codshift    := hcm_util.get_string_t(json_obj,'p_codshift');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
    v_secur boolean := false;
  begin
    if p_codcomp is not null then
      if p_stdate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_stdate');
        return;
      elsif p_endate is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_endate');
        return;
      end if;
      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    end if;

    if p_stdate > p_endate then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'p_stdate > p_endate');
      return;
    end if;
  end check_index;
  --
  procedure check_getleave is
    v_numlereq  tlereqg.numlereqg%type;
    v_secur     boolean := false;
  begin
    if p_numlereqg is not null then
      begin
        select numlereqg,codcomp,codempid
          into v_numlereq,v_codcomp,v_codempid
          from tlereqg
         where numlereqg = p_numlereqg;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlereqg');
        return;
      end;
    end if;
    if v_numlereq is not null then
      if v_codcomp is not null then
        v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
        if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
      end if;
    end if;
  end check_getleave;
  --
  procedure chk_insert is
    v_code        varchar2(100);
    v_flgsecu     boolean;
    v_dtestrt     date;
    v_dteend      date;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    elsif p_codleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codleave');
      return;
    elsif p_dteleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteleave');
      return;
    elsif p_dtestrt is null and p_flgleave in ('A','H') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestrt');
      return;
    elsif p_timstrt is null and p_flgleave = 'H' then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstrt');
      return;
    elsif p_dteend is null and p_flgleave in ('A','H') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    elsif p_timend is null and p_flgleave = 'H' then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timend');
      return;
    elsif p_dteappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteappr');
      return;
    elsif p_codappr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codappr');
      return;
    end if;
    if p_codcomp is not null then
      v_flgsecu := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
        return;
      end if;
    end if;
    if p_codcalen is not null then
      begin
        select codcodec into v_code
          from tcodwork
         where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcalen');
        return;
      end;
    end if;
    if p_flgleave = 'A' then
      if p_dtestrt > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dteend');
        return;
      end if;
    elsif p_flgleave = 'H' then
      v_dtestrt := to_date(to_char(p_dtestrt,'dd/mm/yyyy')||to_char(to_date(p_timstrt,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');
      v_dteend  := to_date(to_char(p_dteend,'dd/mm/yyyy')||to_char(to_date(p_timend,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');
      if v_dtestrt > v_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dteend');
        return;
      end if;
    end if;
  end;
  --
  procedure check_save is
    param_row       json_object_t;
    v_codleave      tleavecdatt.codleave%type;
    v_numseq        tleavecdatt.numseq%type;
    v_attachname    tlereqattch.filename%type;
    v_flgattach     tleavecdatt.flgattach%type;
  begin
      if param_flgwarn = 'S' then
        param_flgwarn := 'WARN1';
      end if;

      if param_flgwarn = 'WARN1' then
        for i in 0..param_file.get_size-1 loop
          param_row      := json_object_t(param_file.get(to_char(i)));
          v_codleave     := hcm_util.get_string_t(param_row,'codleave');
          v_numseq       := hcm_util.get_string_t(param_row,'numseq');
          v_attachname   := hcm_util.get_string_t(param_row,'attachname');
          v_flgattach    := hcm_util.get_string_t(param_row,'flgattach');

          if v_flgattach = 'Y' and v_attachname is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            param_flgwarn := 'WARN2';
          end if;
        end loop;
      end if;
  end;

  procedure chk_empleave is
    v_flgsecu     boolean;
    v_dtestrt     date;
    v_dteend      date;
  begin
    if p_codleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codleave');
      return;
    elsif p_dteleave is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteleave');
      return;
    elsif p_dtestrt is null and p_flgleave in ('A','H') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestrt');
      return;
    elsif p_timstrt is null and p_flgleave = 'H' then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timstrt');
      return;
    elsif p_dteend is null and p_flgleave in ('A','H') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    elsif p_timend is null and p_flgleave = 'H' then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'timend');
      return;
    end if;
    if p_flgleave = 'A' then
      if p_dtestrt > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dteend');
        return;
      end if;
    elsif p_flgleave = 'H' then
      v_dtestrt := to_date(to_char(p_dtestrt,'dd/mm/yyyy')||to_char(to_date(p_timstrt,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');
      v_dteend  := to_date(to_char(p_dteend,'dd/mm/yyyy')||to_char(to_date(p_timend,'hh24mi'),'hh24mi'),'dd/mm/yyyyhh24mi');

      if v_dtestrt > v_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dteend');
        return;
      end if;
    end if;
    if v_codempid is not null then
      v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure cal_dhm_char (p_qtyday in number, p_day out varchar2) is
    v_min   number(2) := 0;
    v_hour  number(2) := 0;
    v_day   number := 0;
    v_num   number := 0;
  begin
    p_day := null;
    if nvl(p_qtyday,0) > 0 then
      v_day   := trunc(p_qtyday / 1);
      v_num   := round(mod((p_qtyday * v_qtyavgwk),v_qtyavgwk),0);
      v_hour  := trunc(v_num / 60);
      v_min   := mod(v_num,60);
      if v_day > 99 then
        p_day := v_day||':'||lpad(v_hour,2,'0')||':'||lpad(v_min,2,'0');
      else
        p_day := lpad(v_day,2,'0')||':'||lpad(v_hour,2,'0')||':'||lpad(v_min,2,'0');
      end if;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    v_secur     boolean := false;
    v_exist     boolean := false;
    cursor c1 is
      select numlereqg,codcomp,codcalen,nvl(dtestrt,dteleave) dtestrt,nvl(dteend,dteleave) dteend,codleave,dteappr,codappr
        from tlereqg a
       where (dtestrt  between nvl(p_stdate,dtestrt) and nvl(p_endate,dteend)
          or dteend    between nvl(p_stdate,dtestrt) and nvl(p_endate,dteend)
          or nvl(p_stdate,dtestrt)  between dtestrt and dteend
          or nvl(p_endate,dteend)  between dtestrt and dteend)
         and codcomp   like p_codcomp||'%'
         and numlereqg = nvl(p_numlereqg,numlereqg)
    order by numlereqg;

/*    cursor c2 is
      select numlereqg,codcomp,codcalen,nvl(dtestrt,dteleave) dtestrt,nvl(dteend,dteleave) dteend,codleave,dteappr,codappr
        from tlereqg a
       where numlereqg = p_numlereqg
    order by numlereqg;*/

  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      obj_row := json_object_t();
      --if p_numlereqg is not null then
        for i in c1 loop
         v_secur := secur_main.secur7(i.codcomp,global_v_coduser);
         if v_secur  then
            v_row := v_row + 1;
            obj_data := json_object_t();

            obj_data.put('coderror','200');
            obj_data.put('numlereqg',i.numlereqg);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp, global_v_lang));
            obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));
            obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('codleave',i.codleave);
            obj_data.put('desc_codleave',get_tleavecd_name(i.codleave,global_v_lang));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',i.codappr);

            obj_row.put(to_char(v_row-1),obj_data);
          end if;
        end loop;
     /* else
       for i in c1 loop
         v_secur := secur_main.secur7(i.codcomp,global_v_coduser);
         if v_secur  then
            v_row := v_row + 1;
            obj_data := json_object_t();

            obj_data.put('coderror','200');
            obj_data.put('numlereqg',i.numlereqg);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp, global_v_lang));
            obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));
            obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('codleave',i.codleave);
            obj_data.put('desc_codleave',get_tleavecd_name(i.codleave,global_v_lang));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',i.codappr);

            obj_row.put(to_char(v_row-1),obj_data);
          end if;
        end loop;
      end if;*/
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure get_groupleave_detail(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_codcomp     tlereqg.codcomp%type;
    v_codcalen    tlereqg.codcalen%type;
    v_codleave    tlereqg.codleave%type;
    v_dteleave    date;
    v_dtestrt     date;
    v_timstrt     varchar2(10 char);
    v_dteend      date;
    v_timend      varchar2(10 char);
    v_flgleave    varchar2(1 char);
    v_deslereq    tlereqg.deslereq%type;
    v_dteappr     date;
    v_codappr     tlereqg.codappr%type;
    v_flgstat     varchar2(10 char) := 'edit';
    v_codshift    varchar2(10 char) := '';
  begin
    initial_value(json_str_input);
    check_getleave;

    if param_msg_error is null then
      begin
        select codcomp,codcalen,codleave,dteleave,dtestrt,timstrt,codshift,
               dteend,timend,flgleave,deslereq,dteappr,codappr
          into v_codcomp,v_codcalen,v_codleave,v_dteleave,v_dtestrt,v_timstrt,v_codshift,
               v_dteend,v_timend,v_flgleave,v_deslereq,v_dteappr,v_codappr
          from tlereqg
         where numlereqg = p_numlereqg;
      exception when no_data_found then
        v_flgstat  := 'add';
      end;

      if v_timstrt is null then
        v_timstrt := null;
      else
        v_timstrt := substr(v_timstrt,1,2)||':'||substr(v_timstrt,3,2);
      end if;
      if v_timend is null then
        v_timend := null;
      else
        v_timend := substr(v_timend,1,2)||':'||substr(v_timend,3,2);
      end if;

      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('numlereqg', p_numlereqg);
      obj_row.put('codcomp', v_codcomp);
      obj_row.put('codcalen', v_codcalen);
      obj_row.put('codleave', v_codleave);
      obj_row.put('dteleave', to_char(v_dteleave,'dd/mm/yyyy'));
      obj_row.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
      obj_row.put('timstrt', v_timstrt);
      obj_row.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));
      obj_row.put('timend', v_timend);
      obj_row.put('flgleave', v_flgleave);
      obj_row.put('deslereq', v_deslereq);
      obj_row.put('dteappr', to_char(v_dteappr,'dd/mm/yyyy'));
      obj_row.put('codappr', v_codappr);
      obj_row.put('flgstat', v_flgstat);
      obj_row.put('codshift', v_codshift);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_groupleave_detail;
  --
  procedure get_groupleave_attch(json_str_input in clob, json_str_output out clob) is
    json_row_att  json_object_t;
    json_obj_att  json_object_t;
    v_numlereqg   tlereqgattch.numlereq%type;
    v_codleave    tlereqg.codleave%type;
    tmp_codleave  tlereqg.codleave%type;
    v_flgstat     varchar2(10 char) := 'edit';
    v_rcnt        number := 0;
    cursor c_leave_addnew is
      select filename, numseq, flgattach
        from tleavecdatt
       where codleave = p_codleave
      order by numseq;

    cursor c_leave_edit is
      select b.filename, nvl(b.numseq,c.numseq) numseq, c.filename filedesc,
              nvl(b.flgattach,c.flgattach) flgattach
        from tlereqgattch b, tleavecdatt c
      where  c.numseq       = b.numseq(+)
        and  c.codleave     = b.codleave(+)
        and  c.codleave     = v_codleave
        and  b.numlereq(+)  = p_numlereqg
      order by numseq;
  begin
    initial_value(json_str_input);
--    check_getleave;
    if param_msg_error is null then
      begin
        select numlereqg,codleave
          into v_numlereqg,v_codleave
          from tlereqg
         where numlereqg = p_numlereqg
         and codleave = nvl(p_codleave,codleave);
      exception when no_data_found then
        v_flgstat   := 'add';
        v_numlereqg := '';
        v_codleave  := '';
      end;
       -- get attachment document --
      json_row_att     := json_object_t();
      if v_flgstat = 'add' then
        if p_numlereqg is null then
          tmp_codleave := p_codleave;
        end if;
        for r1 in c_leave_addnew loop
          json_obj_att := json_object_t();
          json_obj_att.put('codleave',v_codleave);
          json_obj_att.put('numseq',r1.numseq);
          json_obj_att.put('filename',r1.filename);
          json_obj_att.put('attachname','');
          json_obj_att.put('flgattach',r1.flgattach);

          json_row_att.put(to_char(v_rcnt),json_obj_att);
          v_rcnt := v_rcnt + 1;
        end loop;
      elsif v_flgstat = 'edit' then
        for r1 in c_leave_edit loop
          json_obj_att := json_object_t();
          json_obj_att.put('codleave',v_codleave);
          json_obj_att.put('numseq',r1.numseq);
          json_obj_att.put('filename',r1.filedesc);
          json_obj_att.put('attachname',r1.filename);
          json_obj_att.put('flgattach',r1.flgattach);

          json_row_att.put(to_char(v_rcnt),json_obj_att);
          v_rcnt := v_rcnt + 1;
        end loop;
      end if;
      json_str_output := json_row_att.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_groupleave_attch;
  --
  procedure get_groupleave_table(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row         number := 0;
    v_flgsecu     boolean := false;
    codempid      tlereqst.codempid%type;
    desc_codempid varchar2(500 char);
    numlereq      varchar2(100 char);
    flg_query     varchar2(1 char);
    v_status      varchar2(100 char);
    dayeupd       date;
    qtyday1       number;
    qtyday2       number;
    qtyday3       number;
    qtyday4       number;
    qtyday5       number;
    v_qtyday1     varchar2(100 char);
    v_qtyday2     varchar2(100 char);
    v_qtyday3     varchar2(100 char);
    v_qtyday4     varchar2(100 char);
    v_qtyday5     varchar2(100 char);

    cursor c1 is
      select codempid,numlereq,dayeupd,nvl(qtyentitle,0) as qtyentitle,nvl(qtysdayle,0) as qtysdayle,nvl(qtydayrq,0) as qtydayrq,nvl(qtydayle,0) as qtydayle
        from tlereqst
       where numlereqg = p_numlereqg
    order by codempid;

  begin
    initial_value(json_str_input);
    check_getleave;
    obj_row := json_object_t();

    for i in c1 loop
      v_flgsecu := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        codempid      := i.codempid;
        desc_codempid := get_temploy_name(codempid,global_v_lang);
        numlereq      := i.numlereq;
        flg_query     := 'E'; -- Exist
        dayeupd       := i.dayeupd;
        if i.dayeupd is not null then
          flg_query   := 'U'; -- Cal leave
          v_status    := get_label_name('HRAL59E2',global_v_lang,'300');
        else
          v_status    := get_label_name('HRAL59E2',global_v_lang,'310');
        end if;
        --
        begin
          select a.codshift
            into v_codshift
            from tattence a
           where a.codempid = i.codempid
             and a.dtework  = (select max(dtework) from tlereqd where numlereq = i.numlereq);
        exception when no_data_found then null;
        end;
        begin
          select qtydaywk
            into v_qtyavgwk
            from tshiftcd
           where codshift = v_codshift;
        exception when no_data_found then v_qtyavgwk := 480;
        end;

        qtyday1 := i.qtyentitle;
        qtyday2 := i.qtysdayle;
        qtyday3 := i.qtydayrq;
        qtyday4 := i.qtyentitle - (i.qtysdayle + i.qtydayrq);
        qtyday5 := i.qtydayle;
        cal_dhm_char(qtyday1,v_qtyday1);
        cal_dhm_char(qtyday2,v_qtyday2);
        cal_dhm_char(qtyday3,v_qtyday3);
        cal_dhm_char(qtyday4,v_qtyday4);
        cal_dhm_char(qtyday5,v_qtyday5);

        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image',get_emp_img(codempid));
        obj_data.put('codempid',codempid);
        obj_data.put('desc_codempid',desc_codempid);
        obj_data.put('numlereq',numlereq);
        obj_data.put('dayeupd',dayeupd);
        obj_data.put('flg_query',flg_query);
        obj_data.put('qtyday1',v_qtyday1);
        obj_data.put('qtyday2',v_qtyday2);
        obj_data.put('qtyday3',v_qtyday3);
        obj_data.put('qtyday4',v_qtyday4);
        obj_data.put('qtyday5',v_qtyday5);
        obj_data.put('status',v_status);

        obj_row.put(to_char(v_row-1),obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_groupleave_table;
  --
  procedure process_data(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_result    json_object_t;
    v_row         number := 0;
    v_flgsecu     boolean := false;
    codempid      tlereqst.codempid%type;
    desc_codempid varchar2(500 char);
    numlereq      varchar2(100 char);
    flg_query     varchar2(1 char);
    v_status      varchar2(100 char);
    dayeupd       date;
    qtyday1       number;
    qtyday2       number;
    qtyday3       number;
    qtyday4       number;
    qtyday5       number;
    qtyday6       number;
    v_qtyday1     varchar2(100 char);
    v_qtyday2     varchar2(100 char);
    v_qtyday3     varchar2(100 char);
    v_qtyday4     varchar2(100 char);
    v_qtyday5     varchar2(100 char);
    v_qtytimle    number;
    v_qtytimrq    number;
    v_coderr      varchar2(20 char);
    v_sumday        number;
    v_summin        number;

    cursor c_emp1 is
      select codempid,numlereq,dayeupd,nvl(qtyentitle,0) as qtyentitle,nvl(qtysdayle,0) as qtysdayle,nvl(qtydayrq,0) as qtydayrq,nvl(qtydayle,0) as qtydayle
        from tlereqst
       where numlereqg = p_numlereqg
    order by codempid;

    cursor c_emp2 is
      select codempid
        from temploy1
       where exists(select b.codempid
                      from tattence b
                     where temploy1.codempid = b.codempid
                       and b.dtework  = p_dteleave
                       and b.codshift = nvl(p_codshift,b.codshift)
                       and codcomp  like p_codcomp||'%'
                       and codcalen = nvl(p_codcalen,codcalen))
         and not exists(select b.codempid
                          from tlereqst b
                         where temploy1.codempid = b.codempid
                           and b.numlereqg       = p_numlereqg)
    order by codempid;

  begin
    initial_value(json_str_input);
    chk_insert;

    if p_numlereqg is not null then
      delete tlereqst where numlereqg = p_numlereqg and dayeupd is null;
    end if;

    obj_row    := json_object_t();
    obj_result := json_object_t();
    for r_emp in c_emp1 loop
      v_flgsecu := secur_main.secur2(r_emp.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        codempid      := r_emp.codempid;
        desc_codempid := get_temploy_name(codempid,global_v_lang);
        numlereq      := r_emp.numlereq;
        flg_query     := 'E'; -- Exist
        dayeupd       := r_emp.dayeupd;
        if r_emp.dayeupd is not null then
          flg_query   := 'U'; -- Cal leave
          v_status    := get_label_name('HRAL59E2',global_v_lang,'300');
        else
          v_status    := get_label_name('HRAL59E2',global_v_lang,'310');
        end if;
        --
        begin
          select a.codshift
            into v_codshift
            from tattence a
           where a.codempid = r_emp.codempid
             and a.dtework  = (select max(dtework) from tlereqd where numlereq = r_emp.numlereq);
        exception when no_data_found then null;
        end;
        begin
          select qtydaywk
            into v_qtyavgwk
            from tshiftcd
           where codshift = v_codshift;
        exception when no_data_found then null;
        end;
        --
        qtyday1 := r_emp.qtyentitle;
        qtyday2 := r_emp.qtysdayle;
        qtyday3 := r_emp.qtydayrq;
        qtyday4 := r_emp.qtyentitle - (r_emp.qtysdayle + r_emp.qtydayrq);
        qtyday5 := r_emp.qtydayle;

        if qtyday4 > 0 then
          cal_dhm_char(nvl(qtyday1,0),v_qtyday1);
          cal_dhm_char(nvl(qtyday2,0),v_qtyday2);
          cal_dhm_char(nvl(qtyday3,0),v_qtyday3);
          cal_dhm_char(nvl(qtyday4,0),v_qtyday4);
          cal_dhm_char(nvl(qtyday5,0),v_qtyday5);

          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(codempid));
          obj_data.put('codempid',codempid);
          obj_data.put('desc_codempid',desc_codempid);
          obj_data.put('numlereq',numlereq);
          obj_data.put('dayeupd',dayeupd);
          obj_data.put('flg_query',flg_query);
          obj_data.put('status',v_status);
          obj_data.put('qtyday1',v_qtyday1);
          obj_data.put('qtyday2',v_qtyday2);
          obj_data.put('qtyday3',v_qtyday3);
          obj_data.put('qtyday4',v_qtyday4);
          obj_data.put('qtyday5',v_qtyday5);
          obj_data.put('qtyday1_used',qtyday1);
          obj_data.put('qtyday2_used',qtyday2);
          obj_data.put('qtyday3_used',qtyday3);
          obj_data.put('qtyday4_used',qtyday4);
          obj_data.put('qtyday5_used',qtyday5);
          obj_data.put('qtyday6_used',qtyday6);
          obj_data.put('dteleave_used',to_char(p_dteleave, 'dd/mm/yyyy'));
          obj_data.put('flgAdd',true);
          obj_data.put('flgProcess',true);

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end if;--v_flgsecu
    end loop;--r_emp1
    --
    for r_emp in c_emp2 loop
      v_flgsecu := secur_main.secur2(r_emp.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        hral56b_batch.gen_entitlement(r_emp.codempid, p_numlereqg,  dayeupd,
                                      p_flgleave, p_codleave, p_dteleave,
                                      p_dtestrt,  p_timstrt,  p_dteend, p_timend,
                                      null,
                                      global_v_zyear, global_v_coduser,
                                      v_coderr, qtyday1,  qtyday2,  qtyday3,
                                      qtyday4,  qtyday5,  qtyday6,  v_qtytimle, v_qtytimrq, v_qtyavgwk);
        --
        if (v_coderr is null and nvl(qtyday1,0) > 0 and (nvl(qtyday5,0) + nvl(qtyday6,0)) > 0) then          
          codempid      := r_emp.codempid;
          desc_codempid := get_temploy_name(codempid,global_v_lang);

          cal_dhm_char(nvl(qtyday1,0),v_qtyday1);
          cal_dhm_char(nvl(qtyday2,0),v_qtyday2);
          cal_dhm_char(nvl(qtyday3,0),v_qtyday3);
          cal_dhm_char(nvl(qtyday4,0),v_qtyday4);
          cal_dhm_char((nvl(qtyday5,0) + nvl(qtyday6,0)),v_qtyday5);

          v_row := v_row + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('image',get_emp_img(r_emp.codempid));
          obj_data.put('codempid',r_emp.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r_emp.codempid,global_v_lang));
          obj_data.put('dayeupd',dayeupd);
          obj_data.put('flg_query',nvl(flg_query,'E'));
          obj_data.put('status',get_label_name('HRAL59E2',global_v_lang,'310'));
          obj_data.put('qtyday1',v_qtyday1);
          obj_data.put('qtyday2',v_qtyday2);
          obj_data.put('qtyday3',v_qtyday3);
          obj_data.put('qtyday4',v_qtyday4);
          obj_data.put('qtyday5',v_qtyday5);
          obj_data.put('qtyday1_used',qtyday1);
          obj_data.put('qtyday2_used',qtyday2);
          obj_data.put('qtyday3_used',qtyday3);
          obj_data.put('qtyday4_used',qtyday4);
          obj_data.put('qtyday5_used',qtyday5);
          obj_data.put('qtyday6_used',qtyday6);
          obj_data.put('dteleave_used',to_char(p_dteleave, 'dd/mm/yyyy'));
          obj_data.put('flgAdd',true);
          obj_data.put('flgProcess',true);

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end if;--v_flgsecu
    end loop;--r_emp2

    obj_result.put('coderror', '200');
    obj_result.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    obj_result.put('table',obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;
  --
  procedure get_empleave(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    qtyday1       number;
    qtyday2       number;
    qtyday3       number;
    qtyday4       number;
    qtyday5       number;
    qtyday6       number;
    v_qtyday1     varchar2(100 char); --number;
    v_qtyday2     varchar2(100 char); --number;
    v_qtyday3     varchar2(100 char); --number;
    v_qtyday4     varchar2(100 char); --number;
    v_qtyday5     varchar2(100 char); --number;
    v_qtytimle    number;
    v_qtytimrq    number;
    v_coderr      varchar2(20 char);
  begin
    initial_value(json_str_input);
    chk_empleave;

    if param_msg_error is null then
      hral56b_batch.gen_entitlement(p_codempid, p_numlereqg,  sysdate,
                                    p_flgleave, p_codleave, p_dteleave,
                                    p_dtestrt,  p_timstrt,  p_dteend, p_timend,
                                    null,
                                    global_v_zyear, global_v_coduser,
                                    v_coderr, qtyday1,  qtyday2,  qtyday3,
                                    qtyday4,  qtyday5,  qtyday6,  v_qtytimle, v_qtytimrq, v_qtyavgwk);

      if (v_coderr is null and nvl(qtyday1,0) > 0 and (nvl(qtyday5,0) + nvl(qtyday6,0)) > 0) then --user36 SEA-SS2201 #803 22/03/2023 do as save btn ||if v_coderr is null then
        cal_dhm_char(qtyday1,v_qtyday1);
        cal_dhm_char(qtyday2,v_qtyday2);
        cal_dhm_char(qtyday3,v_qtyday3);
        cal_dhm_char(qtyday4,v_qtyday4);
        cal_dhm_char((nvl(qtyday5,0) + nvl(qtyday6,0)),v_qtyday5);

        obj_row := json_object_t();
        obj_row.put('coderror','200');
        obj_row.put('numlereq','');
        obj_row.put('image',get_emp_img(p_codempid));
        obj_row.put('codempid',p_codempid);
        obj_row.put('qtyday1',v_qtyday1);
        obj_row.put('qtyday2',v_qtyday2);
        obj_row.put('qtyday3',v_qtyday3);
        obj_row.put('qtyday4',v_qtyday4);
        obj_row.put('qtyday5',v_qtyday5);
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php(v_coderr,global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_empleave;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        p_numlereqg     := hcm_util.get_string_t(param_json_row,'numlereqg');

        delete tlereqg
         where numlereqg = p_numlereqg;
        delete tlereqst
         where numlereqg = p_numlereqg;
        delete tlereqgattch
         where numlereq = p_numlereqg;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;
  --
  procedure save_data(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    param_row_file  json_object_t;
    v_flgsecu       boolean;
    v_coderr        varchar2(20 char);
    v_sumday        number;
    v_summin        number;
    v_flgfound      boolean;
    v_code          varchar2(100 char);
    v_codcomp       varchar2(100 char);
    v_numlvl        number;
    v_codempid      varchar2(100 char);
    v_numlereq      varchar2(100 char);
    v_dayeupd       date;
    v_qtyday1       varchar2(100 char);
    v_qtyday2       varchar2(100 char);
    v_qtyday3       varchar2(100 char);
    v_qtyday4       varchar2(100 char);
    v_qtyday5       varchar2(100 char);
    v_qtyday6       varchar2(100 char);
    v_qtyday1_used  number;
    v_qtyday2_used  number;
    v_qtyday3_used  number;
    v_qtyday4_used  number;
    v_qtyday5_used  number;
    v_qtyday6_used  number;
    v_dteleave_used date;
    v_qtytimle      number;
    v_qtytimrq      number;
    v_flg           varchar2(10);
    v_flgProcess    boolean;

    v_codleave      tleavecdatt.codleave%type;
    v_numseq        tleavecdatt.numseq%type;
    v_attachname    tlereqattch.filename%type;
    v_flgattach     tleavecdatt.flgattach%type;
    v_filename      tleavecdatt.filename%type;
    v_qtyminunit    tleavecd.qtyminunit%type;

    v_dayeupdate    date;--user37 #5263 Final Test Phase 1 V11 03/03/2021
  begin
    initial_value(json_str_input);
    param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json2 := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str2');
    param_file  := hcm_util.get_json_t(param_json2,'rows');
    chk_insert;
    check_save;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
      return;
    end if;
    begin
      select qtyminunit
      into   v_qtyminunit
      from   tleavecd
      where  codleave = p_codleave;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codleave');
    end;

    if p_numlereqg is null then
      p_numlereqg := std_al.gen_req('LEAT','tlereqg','numlereqg',global_v_zyear,get_codcompy(get_compful(p_codcomp)),'G');
      std_al.upd_req('LEAT',p_numlereqg,global_v_coduser,global_v_zyear,get_codcompy(get_compful(p_codcomp)),'G');
    end if;
    --
    begin
      insert into tlereqg(numlereqg,codempid,codcomp,codcalen,codleave,dteleave,codshift,
                          dtestrt,timstrt,dteend,timend,flgleave,deslereq,dteappr,
                          codappr,dteupd,coduser,codcreate)
               values(p_numlereqg,null,p_codcomp,p_codcalen,p_codleave,p_dteleave,p_codshift,
                      p_dtestrt,p_timstrt,p_dteend,p_timend,nvl(p_flgleave,'A'),p_deslereq,p_dteappr,
                      p_codappr,sysdate,global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tlereqg set codcomp  = p_codcomp,
                         codcalen = p_codcalen,
                         codleave = p_codleave,
                         dteleave = p_dteleave,
                         dtestrt  = p_dtestrt,
                         timstrt  = p_timstrt,
                         dteend   = p_dteend,
                         timend   = p_timend,
                         flgleave = nvl(p_flgleave,'A'),
                         deslereq = p_deslereq,
                         codshift = p_codshift,
                         --
                         dteappr  = p_dteappr,
                         codappr  = p_codappr,
                         dteupd   = sysdate,
                         coduser  = global_v_coduser
                   where numlereqg = p_numlereqg;
    end;
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        v_numlereq      := hcm_util.get_string_t(param_json_row,'numlereq');
        v_dayeupd       := sysdate;--to_date(trim(hcm_util.get_string(param_json_row,'dayeupd')),'dd/mm/yyyy');
        v_qtyday1       := hcm_util.get_string_t(param_json_row,'qtyday1');
        v_qtyday2       := hcm_util.get_string_t(param_json_row,'qtyday2');
        v_qtyday3       := hcm_util.get_string_t(param_json_row,'qtyday3');
        v_qtyday4       := hcm_util.get_string_t(param_json_row,'qtyday4');
        v_qtyday5       := hcm_util.get_string_t(param_json_row,'qtyday5');
        v_qtyday1_used  := hcm_util.get_number_t(param_json_row,'qtyday1_used');
        v_qtyday2_used  := hcm_util.get_number_t(param_json_row,'qtyday2_used');
        v_qtyday3_used  := hcm_util.get_number_t(param_json_row,'qtyday3_used');
        v_qtyday4_used  := hcm_util.get_number_t(param_json_row,'qtyday4_used');
        v_qtyday5_used  := hcm_util.get_number_t(param_json_row,'qtyday5_used');
        v_qtyday6_used  := hcm_util.get_number_t(param_json_row,'qtyday6_used');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        v_flgProcess    := hcm_util.get_boolean_t(param_json_row,'flgProcess');
        v_dteleave_used := to_date(hcm_util.get_string_t(param_json_row,'dteleave_used'), 'dd/mm/yyyy');

        if v_codempid is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
          exit;
        end if;
        if v_flg = 'delete' then
          if v_numlereq is not null then
              --<<user37 #5263 Final Test Phase 1 V11 03/03/2021
              begin
                select dayeupd
                  into v_dayeupdate
                  from tlereqst
                 where numlereq = v_numlereq;
              exception when no_data_found then
                v_dayeupdate := null;
              end;
              if v_dayeupdate is not null then
                param_msg_error := get_error_msg_php('HR8836',global_v_lang);
                --exit;
              end if;
              -->>user37 #5263 Final Test Phase 1 V11 03/03/2021
              delete from tlereqst where numlereq = v_numlereq;
          end if;
        else
          begin
            select numlereqg
              into p_numlereqg
              from tlereqg
             where numlereqg = p_numlereqg;
          exception when no_data_found then null;
            param_msg_error := get_error_msg_php('HR2055',global_v_lang);
            exit;
          end;
          -- todo flgProcess skip this
          if not v_flgProcess then
            begin
              select a.codempid,a.codcomp,a.numlvl
                into v_code,v_codcomp,v_numlvl
                from temploy1 a ,temploy2 b
               where a.codempid = v_codempid
                and  a.codempid = b.codempid;
              v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              if not v_flgsecu then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
                exit;
              end if;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
              exit;
            end;
          end if;
          begin
            select codempid into v_code
              from tlereqst
             where numlereqg = p_numlereqg
               and numlereq <> nvl(v_numlereq,'!@#$%')
               and codempid  = v_codempid;
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'codempid');
            exit;
          exception when no_data_found then null;
          end;
          -- todo p_dteleave = v_dteleave && not flgProcess skip this
          if v_flgProcess and v_dteleave_used = p_dteleave then
            v_qtyday1 := v_qtyday1_used;
            v_qtyday2 := v_qtyday2_used;
            v_qtyday3 := v_qtyday3_used;
            v_qtyday4 := v_qtyday4_used;
            v_qtyday5 := v_qtyday5_used;
            v_qtyday6 := v_qtyday6_used;
          else
            hral56b_batch.gen_entitlement(v_codempid, v_numlereq, v_dayeupd,
                                        p_flgleave, p_codleave, p_dteleave,
                                        p_dtestrt,  p_timstrt,  p_dteend, p_timend,
                                        null,
                                        global_v_zyear,global_v_coduser,
                                        v_coderr,   v_qtyday1,  v_qtyday2,  v_qtyday3,
                                        v_qtyday4,  v_qtyday5,  v_qtyday6,  v_qtytimle, v_qtytimrq, v_qtyavgwk);
          end if;
          if v_coderr is not null then
            param_msg_error := get_error_msg_php(v_coderr,global_v_lang);
            exit;
          end if;
          if v_numlereq is null then
            v_numlereq := std_al.gen_req('LEAV','tlereqst','numlereq',global_v_zyear,get_codcompy(get_compful(v_codcomp)),'');
            std_al.upd_req('LEAV',v_numlereq,global_v_coduser,global_v_zyear,get_codcompy(get_compful(v_codcomp)),'G');
          end if;
          --
          /*--user36 SEA-SS2201 #803 22/03/2023 cancel
          hral56b_batch.gen_min_req(true,v_numlereq,v_codempid,p_flgleave,p_codleave,p_dteleave,p_dtestrt,p_timstrt,p_dteend,p_timend,global_v_coduser,
                              v_summin,v_sumday,v_qtyavgwk,v_coderr);*/
          --
          if (v_coderr is null and nvl(v_qtyday1,0) > 0 and (nvl(v_qtyday5,0) + nvl(v_qtyday6,0)) > 0) then --user36 SEA-SS2201 #803 22/03/2023 do as save btn ||if v_sumday > 0 then
            begin
              select codshift into v_codshift
                from tattence
               where codempid = v_codempid
                 and dtework  = p_dteleave;
            exception when no_data_found then v_codshift := null;
            end;
            begin
              -- todo refactor this
              insert into tlereqst(numlereq,dterecod,dtereq,codempid,codleave,dtestrt,timstrt,dteend,timend,qtymin,qtyday,
                                   deslereq,stalereq,codappr,dteappr,codcomp,numlvl,dtecancl,codshift,dayeupd,qtydlemx,
                                   filename,flgleave,dteleave,numlereqg,qtyentitle,qtysdayle,qtydayrq,qtydayle,dteupd,coduser,codcreate)
                            values(v_numlereq,sysdate,null,v_codempid,p_codleave,p_dtestrt,p_timstrt,p_dteend,p_timend,v_summin,v_sumday,
                                   p_deslereq,'A',p_codappr,p_dteappr,v_codcomp,v_numlvl,null,v_codshift,null,0,
                                   null,p_flgleave,p_dteleave,p_numlereqg,nvl(v_qtyday1,0),nvl(v_qtyday2,0),nvl(v_qtyday3,0),(nvl(v_qtyday5,0) + nvl(v_qtyday6,0)),sysdate,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then null;
            end;
          end if;
        end if;
      end loop;

      for i in 0..param_file.get_size-1 loop
        param_row_file := hcm_util.get_json_t(param_file,to_char(i));
        v_codleave     := hcm_util.get_string_t(param_row_file,'codleave');
        v_numseq       := hcm_util.get_string_t(param_row_file,'numseq');
        v_attachname   := hcm_util.get_string_t(param_row_file,'attachname');
        v_filename      := hcm_util.get_string_t(param_row_file,'filename');
        v_flgattach    := hcm_util.get_string_t(param_row_file,'flgattach');
        begin
          insert into tlereqgattch (numlereq, numseq, filename, flgattach, filedesc, codleave, codcreate, dtecreate,coduser)
            values (p_numlereqg, v_numseq, v_attachname, v_flgattach, v_filename, p_codleave, global_v_coduser, trunc(sysdate), global_v_coduser);
        exception when dup_val_on_index then
          begin
            update tlereqgattch
              set filename  = v_attachname,
                  coduser   = global_v_coduser
            where numlereq  = p_numlereqg
              and numseq    = v_numseq;
            exception when others then
              rollback;
            end;
        end;
      end loop;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;
    end if;

    obj_row := json_object_t();
    obj_row.put('coderror', '201');
    obj_row.put('response', replace(param_msg_error,'@#$%201',null));
    obj_row.put('numlereqg', p_numlereqg);

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;
  --
  procedure get_check_flgleave (json_str_input in clob, json_str_output out clob) is
    v_flg           tleavecd.flgleave%type;
    v_flgtype       tleavety.flgtype%type;
    json_obj        json_object_t;
    obj_data        json_object_t;
    v_count_lvprgnt number  := 0;
    v_codshift      tgrpplan.codshift%type;

    v_timstrtw      varchar2(1000 char);
    v_timendw       varchar2(1000 char);
    v_timstrtw_cd   varchar2(1000 char);
    v_timendw_cd    varchar2(1000 char);
    v_timstrtb_cd   varchar2(1000 char);
    v_timendb_cd    varchar2(1000 char);

    m_dtestrt       varchar2(100 char);
    m_dteend        varchar2(100 char);
    e_dtestrt       varchar2(100 char);
    e_dteend        varchar2(100 char);
    m_timstrt       varchar2(100 char);
    m_timend        varchar2(100 char);
    e_timstrt       varchar2(100 char);
    e_timend        varchar2(100 char);
    v_desshift      varchar2(100 char);
    v_m_dtestrt     date;
    v_m_dteend      date;
    v_e_dtestrt     date;
    v_e_dteend      date;
    v_m_timstrt     date;
    v_m_timend      date;
    v_e_timstrt     date;
    v_e_timend      date;
  begin
--    initial_value(json_str_input);
    json_obj      := json_object_t(json_str_input);
    p_codleave    := hcm_util.get_string_t(json_obj, 'p_codleave');
    p_codcomp     := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codcalen    := hcm_util.get_string_t(json_obj, 'p_codcalen');
    p_dteleave    := to_date(hcm_util.get_string_t(json_obj, 'p_dteleave'),'dd/mm/yyyy');
    begin
      select t1.flgleave, t2.flgtype
        into v_flg, v_flgtype
        from tleavecd t1, tleavety t2
       where t1.typleave  = t2.typleave
         and t1.codleave  = p_codleave;
    exception when others then
        v_flg     := null;
        v_flgtype := null;
    end;

    -- check tleavety.codlvprgn --
    if v_flgtype != 'M' then
      obj_data        := json_object_t();
      obj_data.put('coderror', 200);
      if v_flg = 'A' then
        obj_data.put('flgleave_r2','F');
        obj_data.put('flgleave_r3','F');
        obj_data.put('flgleave_r4','F');
        obj_data.put('flgleave_r1','T');
      elsif v_flg = 'F' then
        obj_data.put('flgleave_r4','F');
        obj_data.put('flgleave_r2','T');
        obj_data.put('flgleave_r3','T');
        obj_data.put('flgleave_r1','T');
      elsif v_flg = 'H' then
        obj_data.put('flgleave_r1','T');
        obj_data.put('flgleave_r2','T');
        obj_data.put('flgleave_r3','T');
        obj_data.put('flgleave_r4','T');
      else
        obj_data.put('flgleave_r1','T');
        obj_data.put('flgleave_r2','T');
        obj_data.put('flgleave_r3','T');
        obj_data.put('flgleave_r4','T');
      end if;
      --

      begin
      select timstrtw, timendw, timstrtb, timendb
          into v_timstrtw_cd, v_timendw_cd, v_timstrtb_cd, v_timendb_cd
          from tshiftcd
         where codshift = (select a.codshift
                            from tgrpplan a
                           where a.codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
                             and a.dtework = p_dteleave
                             and a.codcalen = p_codcalen);
      exception when no_data_found then
        v_timstrtw_cd := ''; v_timendw_cd := ''; v_timstrtb_cd := ''; v_timendb_cd := '';
      end;

      v_m_timstrt     := to_date(v_timstrtw_cd, 'hh24mi');
      v_m_timend      := to_date(v_timstrtb_cd, 'hh24mi');
      v_e_timstrt     := to_date(v_timendb_cd, 'hh24mi');
      v_e_timend      := to_date(v_timendw_cd, 'hh24mi');

      m_timstrt   := to_char(v_m_timstrt, 'hh24:mi');
      m_timend    := to_char(v_m_timend, 'hh24:mi');
      e_timstrt   := to_char(v_e_timstrt, 'hh24:mi');
      e_timend    := to_char(v_e_timend, 'hh24:mi');
      v_m_dtestrt := p_dteleave;
      v_m_dteend  := p_dteleave;
      v_e_dtestrt := p_dteleave;
      v_e_dteend  := p_dteleave;
      if v_m_timstrt > v_m_timend then
        v_m_dtestrt := p_dteleave;
        v_m_dteend  := p_dteleave + 1;
      end if;

      if v_m_timstrt > v_e_timstrt then
        v_e_dtestrt := p_dteleave + 1;
        v_e_dteend  := p_dteleave + 1;
      elsif v_m_timstrt > v_e_timend then
        v_e_dtestrt := p_dteleave;
        v_e_dteend  := p_dteleave + 1;
      end if;

      m_dtestrt     := to_char(v_m_dtestrt, 'dd/mm/yyyy');
      m_dteend      := to_char(v_m_dteend, 'dd/mm/yyyy');
      e_dtestrt     := to_char(v_e_dtestrt, 'dd/mm/yyyy');
      e_dteend      := to_char(v_e_dteend, 'dd/mm/yyyy');

      obj_data.put('m_timstrt', m_timstrt);
      obj_data.put('m_timend', m_timend);
      obj_data.put('e_timstrt', e_timstrt);
      obj_data.put('e_timend', e_timend);
      obj_data.put('m_dtestrt', m_dtestrt);
      obj_data.put('m_dteend', m_dteend);
      obj_data.put('e_dtestrt', e_dtestrt);
      obj_data.put('e_dteend', e_dteend);
      json_str_output := obj_data.to_clob;
    else
      param_msg_error := get_error_msg_php('AL0070',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_check_flgleave;
  --
   procedure get_shiftcd (json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    v_codshift      tattence.codshift%type;
    v_timstrtw      tattence.timstrtw%type;
    v_timendw       tattence.timendw%type;
    v_timstrtw_cd   tattence.timstrtw%type;
    v_timendw_cd    tattence.timendw%type;
    v_timstrtb_cd   tshiftcd.timstrtb%type;
    v_timendb_cd    tshiftcd.timendb%type;

    m_dtestrt       varchar2(100 char);
    m_dteend        varchar2(100 char);
    e_dtestrt       varchar2(100 char);
    e_dteend        varchar2(100 char);
    m_timstrt       varchar2(100 char);
    m_timend        varchar2(100 char);
    e_timstrt       varchar2(100 char);
    e_timend        varchar2(100 char);
    v_desshift      varchar2(100 char);
    v_m_dtestrt     date;
    v_m_dteend      date;
    v_e_dtestrt     date;
    v_e_dteend      date;
    v_m_timstrt     date;
    v_m_timend      date;
    v_e_timstrt     date;
    v_e_timend      date;

  begin
    initial_value(json_str_input);
    json_obj := json_object_t();

    json_obj.put('desshift', get_tshiftcd_name(p_codshift, global_v_lang));
    json_obj.put('codshift', p_codshift);
    begin
      select timstrtw, timendw, timstrtb, timendb
        into v_timstrtw_cd, v_timendw_cd, v_timstrtb_cd, v_timendb_cd
        from tshiftcd
       where codshift = p_codshift;
    exception when others then
      null;
    end;

    v_m_timstrt     := to_date(v_timstrtw_cd, 'hh24mi');
    v_m_timend      := to_date(v_timstrtb_cd, 'hh24mi');
    v_e_timstrt     := to_date(v_timendb_cd, 'hh24mi');
    v_e_timend      := to_date(v_timendw_cd, 'hh24mi');

    m_timstrt   := to_char(v_m_timstrt, 'hh24:mi');
    m_timend    := to_char(v_m_timend, 'hh24:mi');
    e_timstrt   := to_char(v_e_timstrt, 'hh24:mi');
    e_timend    := to_char(v_e_timend, 'hh24:mi');
    v_m_dtestrt := p_dteleave;
    v_m_dteend  := p_dteleave;
    v_e_dtestrt := p_dteleave;
    v_e_dteend  := p_dteleave;
    if v_m_timstrt > v_m_timend then
      v_m_dtestrt := p_dteleave;
      v_m_dteend  := p_dteleave + 1;
    end if;

    if v_m_timstrt > v_e_timstrt then
      v_e_dtestrt := p_dteleave + 1;
      v_e_dteend  := p_dteleave + 1;
    elsif v_m_timstrt > v_e_timend then
      v_e_dtestrt := p_dteleave;
      v_e_dteend  := p_dteleave + 1;
    end if;

    m_dtestrt     := to_char(v_m_dtestrt, 'dd/mm/yyyy');
    m_dteend      := to_char(v_m_dteend, 'dd/mm/yyyy');
    e_dtestrt     := to_char(v_e_dtestrt, 'dd/mm/yyyy');
    e_dteend      := to_char(v_e_dteend, 'dd/mm/yyyy');

    json_obj.put('m_timstrt', m_timstrt);
    json_obj.put('m_timend', m_timend);
    json_obj.put('e_timstrt', e_timstrt);
    json_obj.put('e_timend', e_timend);
    json_obj.put('m_dtestrt', m_dtestrt);
    json_obj.put('m_dteend', m_dteend);
    json_obj.put('e_dtestrt', e_dtestrt);
    json_obj.put('e_dteend', e_dteend);
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_shiftcd;
end HRAL59E;

/

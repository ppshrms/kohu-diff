--------------------------------------------------------
--  DDL for Package Body HRAL4JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4JX" as
  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_dte               := to_date(hcm_util.get_string_t(json_obj,'p_dte'),'ddmmyyyy');
    p_timstr            := hcm_util.get_string_t(json_obj,'p_timstr');
    p_timend            := hcm_util.get_string_t(json_obj,'p_timend');
    p_timstr2           := hcm_util.get_string_t(json_obj,'p_timstr2');
    p_timend2           := hcm_util.get_string_t(json_obj,'p_timend2');
    p_timstr3           := hcm_util.get_string_t(json_obj,'p_timstr3');
    p_timend3           := hcm_util.get_string_t(json_obj,'p_timend3');
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

  procedure check_index as
  begin
    if p_dte is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_timstr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_timend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcalen is not null then
        begin
            select codcodec into p_codcalen
            from tcodwork
            where codcodec = p_codcalen;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodwork');
            return;
        end;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj        json_object_t := json_object_t();
    json_row        json_object_t;
    v_count         number := 0;
    v_count_time    number := 0;
    v_secur         varchar2(4000 char);
    v_permis        boolean := false;
    v_exist         boolean := false;
    v_dtestr        date;
    v_dteend        date;
    v_desc_codcalen tcodwork.descode%type;
    v_r_time        totreqd.timend%type := null;
    v_r_codbusno    temploy1.codbusno%type := null;
    v_r_codbusrt    temploy1.codbusrt%type := null;
    v_r_codempid    temploy1.codempid%type := null;
    v_c_codbusno    number := 0;
    v_c_codbusrt    number := 0;
    v_c_codempid    number := 0;
    v_time_chk      varchar2(1000 char);
/*
    cursor c1 is
        select	distinct t1.codempid,t2.codbusno,t2.codbusrt,
                t1.dtewkreq,decode(t1.qtyminr,null,t1.timend,to_char(get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.qtyminr),'hh24mi')) v_time,
                t2.codcomp,t2.codpos,t2.codcalen,
                t1.dteend, t1.timend
          from	totreqd t1, temploy1 t2
         where	t1.codempid = t2.codempid
           and	t2.codcomp  like p_codcomp || '%'
           and	t2.codcalen = nvl(p_codcalen,t2.codcalen)
           and  t1.typot    in ('D','A')
           and (
                (t1.qtyminr is null and t1.dteend is not null and to_date(to_char(t1.dteend ,'dd/mm/yyyy')|| ' ' ||t1.timend,'dd/mm/yyyy hh24mi') between v_dtestr and v_dteend)
                or
                (t1.qtyminr is not null   and get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.qtyminr) between v_dtestr and v_dteend)
               )
            and t2.codbusno is not null
      order by	t1.dtewkreq,decode(t1.qtyminr,null,t1.timend,to_char(get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.qtyminr),'hh24mi'))
               ,t2.codbusno,t2.codbusrt,t1.codempid;

    cursor c1 is
      select distinct t1.codempid,t2.codbusno,t2.codbusrt,t1.dtewkreq,
             get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.dteend,t1.timend,t1.qtyminr) v_date,
             to_char(get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.dteend,t1.timend,t1.qtyminr),'hh24mi') v_time,
             t2.codcomp,t2.codpos,t2.codcalen
        from totreqd t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp  like p_codcomp || '%'
         and t2.codcalen = nvl(p_codcalen,t2.codcalen)
         and t1.typot    in ('D','A')
         and get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.dteend,t1.timend,t1.qtyminr) between v_dtestr and v_dteend
         and t2.codbusno is not null
    order by get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.dteend,t1.timend,t1.qtyminr),
             t2.codbusno,t2.codbusrt,t1.codempid;
*/

    cursor c1 is
      select distinct t1.codempid,t2.codbusno,t2.codbusrt,t1.dtewkreq,
             t2.codcomp,t2.codpos,t2.codcalen
        from totreqd t1, temploy1 t2
       where t1.codempid = t2.codempid
         and t2.codcomp  like p_codcomp || '%'
         and t2.codcalen = nvl(p_codcalen,t2.codcalen)
         and t1.typot    in ('D','A')
         and get_ot_date(t1.codempid,t1.dtewkreq,t1.typot,t1.dteend,t1.timend,t1.qtyminr) between v_dtestr and v_dteend
         and t2.codbusno is not null
         order by t2.codbusno,t2.codbusno,t2.codbusrt,t1.codempid;

  begin
    for first_loop in 1..3 loop
      v_count_time := v_count_time + 1;
      v_dtestr     := null;
      v_dteend     := null;
      if v_count_time = 1 then
        v_dtestr	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timstr,'ddmmyyyy hh24mi');
        v_dteend 	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timend,'ddmmyyyy hh24mi');
        --
        if p_timstr > p_timend then
          v_dteend := v_dteend + 1;
        end if;
      elsif v_count_time = 2 and (p_timstr2 is not null and p_timend2 is not null)then
        v_dtestr	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timstr2,'ddmmyyyy hh24mi');
        v_dteend 	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timend2,'ddmmyyyy hh24mi');
        --
        if p_timstr2 > p_timend2 then
          v_dteend := v_dteend + 1;
        end if;
      elsif v_count_time = 3 and (p_timstr3 is not null and p_timend3 is not null)then
        v_dtestr	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timstr3,'ddmmyyyy hh24mi');
        v_dteend 	:= to_date(to_char(p_dte,'ddmmyyyy') || ' ' || p_timend3,'ddmmyyyy hh24mi');
        --
        if p_timstr3 > p_timend3 then
          v_dteend := v_dteend + 1;
        end if;
      end if;
      --
      for r1 in c1 loop
          v_exist := true;
          if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
              v_permis := true;
              /*if v_r_time is not null and v_r_time <> r1.v_time then
                  json_row := json();
                  json_row.put('otend',get_tlistval_name('HRAL4JX','1',global_v_lang));
                  json_row.put('busno',to_char(v_c_codbusno));
                  json_row.put('busrt',to_char(v_c_codbusrt));
                  json_row.put('desc_codempid',to_char(v_c_codempid));
                  json_row.put('coderror','200');
                  json_obj.put(to_char(v_count),json_row);
                  v_count := v_count + 1;
                  v_c_codbusno := 0;
                  v_c_codbusrt := 0;
                  v_c_codempid := 0;
                  v_r_codbusno := null;
                  v_r_codbusrt := null;
                  v_r_codempid := null;
              end if;*/
              if v_time_chk <> to_char(v_dteend,'hh24:mi') and v_time_chk is not null then
                json_row := json_object_t();
                json_row.put('otend',get_tlistval_name('HRAL4JX','1',global_v_lang));
                json_row.put('busno',to_char(v_c_codbusno));
                json_row.put('busrt',to_char(v_c_codbusrt));
                json_row.put('desc_codempid',to_char(v_c_codempid));
                json_row.put('flgskip','Y');
                json_row.put('coderror','200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_c_codbusno := 0;
                v_c_codbusrt := 0;
                v_c_codempid := 0;
                v_r_codbusno := null;
                v_r_codbusrt := null;
                v_r_codempid := null;
                v_time_chk   := to_char(v_dteend,'hh24:mi');
              end if;
              --
              if v_r_codbusno is null or v_r_codbusno <> r1.codbusno then
                  v_c_codbusno := v_c_codbusno + 1;
              end if;
              if v_r_codbusrt is null or v_r_codbusrt <> r1.codbusrt then
                  v_c_codbusrt := v_c_codbusrt + 1;
              end if;
              if v_r_codempid is null or v_r_codempid <> r1.codempid then
                  v_c_codempid := v_c_codempid + 1;
              end if;

              json_row := json_object_t();
              json_row.put('index',to_char(v_count + 1));
              -- json_row.put('otend',to_char(to_date(r1.v_time,'hh24mi'),'hh24:mi'));
              json_row.put('otend',to_char(v_dteend,'hh24:mi'));
              json_row.put('busno',get_tcodec_name('TCODBUSNO',r1.codbusno,global_v_lang));
              json_row.put('busrt',get_tcodec_name('TCODBUSRT',r1.codbusrt,global_v_lang));
              json_row.put('image',get_emp_img(r1.codempid));
              json_row.put('codempid',r1.codempid);
              json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
              json_row.put('codcomp',hcm_util.get_codcomp_level(r1.codcomp,1) || ' - ' || get_tcenter_name(r1.codcomp,global_v_lang));
              json_row.put('codcalen',r1.codcalen || ' - ' || get_tcodec_name('tcodwork',r1.codcalen,global_v_lang));
              json_row.put('flgskip','N');
              json_row.put('coderror','200');
              json_obj.put(to_char(v_count),json_row);
--                v_r_time     := r1.v_time;
              v_r_codbusno := r1.codbusno;
              v_r_codbusrt := r1.codbusrt;
              v_r_codempid := r1.codempid;
              v_count := v_count +1 ;
              --
              v_time_chk   := to_char(v_dteend,'hh24:mi');
          end if;
      end loop;
    end loop;
    json_row := json_object_t();
    json_row.put('otend',get_tlistval_name('HRAL4JX','1',global_v_lang));
    json_row.put('busno',to_char(v_c_codbusno));
    json_row.put('busrt',to_char(v_c_codbusrt));
    json_row.put('desc_codempid',to_char(v_c_codempid));
    json_row.put('flgskip','Y');
    json_row.put('coderror','200');
    json_obj.put(to_char(v_count),json_row);
    v_count := v_count + 1;
    --
    if not v_exist then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'totreqd');
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    if not v_permis then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    /*json_row := json();
    json_row.put('otend',get_tlistval_name('HRAL4JX','1',global_v_lang));
    json_row.put('busno',to_char(v_c_codbusno));
    json_row.put('busrt',to_char(v_c_codbusrt));
    json_row.put('desc_codempid',to_char(v_c_codempid));
    json_row.put('flgsum','Y');
    json_row.put('coderror','200');
    json_obj.put(to_char(v_count),json_row);*/
		json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  function get_ot_date (p_codempid varchar2,p_dtewkreq date,p_typot varchar2,p_dteend date,p_timend varchar2,p_qtyminr number) return date is
    --date end of OT.
    v_dteend_ot  date;
    v_dteendw    date;
    v_timendw    varchar2(10);
    v_timstotd   varchar2(10);
    v_timstota   varchar2(10);
  begin
    if p_dteend is not null then
      v_dteend_ot := to_date(to_char(p_dteend,'dd/mm/yyyy')||p_timend,'dd/mm/yyyyhh24mi');
    else
      begin
        select a.dteendw,a.timendw,b.timstotd,b.timstota
          into v_dteendw,v_timendw,v_timstotd,v_timstota
          from tattence a,tshiftcd b
         where a.codempid  = p_codempid
           and a.dtework   = p_dtewkreq
           and a.codshift  = b.codshift;
      exception when no_data_found then
        return null;
      end;
      if p_typot = 'D' then            --(typot = D)
        v_dteend_ot := to_date(to_char(p_dtewkreq,'dd/mm/yyyy')||v_timstotd,'dd/mm/yyyyhh24mi') + (p_qtyminr / 1440);
      elsif p_typot = 'A' then
        if v_timstota < v_timendw then --(typot = A)
          v_dteend_ot := v_dteendw + 1;
        else
          v_dteend_ot := v_dteendw;
        end if;
        v_dteend_ot := to_date(to_char(v_dteend_ot,'dd/mm/yyyy')||v_timstota,'dd/mm/yyyyhh24mi') + (p_qtyminr / 1440);
      end if;
    end if;
    return v_dteend_ot;
  end;

end HRAL4JX;

/

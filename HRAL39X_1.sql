--------------------------------------------------------
--  DDL for Package Body HRAL39X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL39X" is

  procedure initial_value(json_str_input in clob) is
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');

    p_typabs            := hcm_util.get_string_t(json_obj,'p_typabs');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index(json_str_input in clob,json_str_output out clob) is
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

  procedure check_index is
  begin
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) is
    json_obj     json_object_t;
    json_row     json_object_t;
    v_codshift   varchar2(4 char);
    v_timstrtw   varchar2(4 char);
    v_timendw    varchar2(4 char);
    v_timin      varchar2(4 char);
    v_timout     varchar2(4 char);
    v_codrecod   varchar2(1 char);
    v_timtime    varchar2(4 char);
    v_dtedate    date;
    v_secur      boolean;
    v_count      number := 0;
    v_codempid   varchar2(10 char);
    v_detail     varchar2(4000 char) := null;
    v_token      varchar2(4 char);
    v_char       varchar2(4000 char);
    v_permission boolean := false; -- true pass , false not pass
    v_data_exist boolean := false;
    v_tostr      varchar2(200 char);
    v_codcomp    varchar2(50 char);
    v_lvlst      number;
    v_lvlen      number;
    v_namcentlvl varchar2(4000 char);
    v_namcent    varchar2(4000 char);
    v_comlevel   tcenter.comlevel%type;
    v_qtylate    varchar2(10 char);
    v_qtyyearly  varchar2(10 char);
    v_qtyabsent  varchar2(10 char);
    v_qtynostam  varchar2(10 char);
    cursor c1 is
        select	t1.codempid		,   t2.codcomp,
                t2.numlvl		,   t2.codpos,
                t1.dtework		,   t1.qtylate,
                t1.qtyearly		,   t1.qtyabsent,
                t1.qtynostam	,   t1.rowid
        from	tlateabs t1		,   temploy1 t2
        where	t1.codempid 	=	t2.codempid
        and		t1.codempid 	=	nvl(p_codempid,t1.codempid)
        and		t2.codcomp	like	p_codcomp || '%'
        and		t1.dtework	between p_dtestr and p_dteend
        and		((p_typabs	like '1'	and	nvl(t1.qtylate  ,0)	> 0) or
                (p_typabs	like '2'	and	nvl(t1.qtyearly ,0)	> 0) or
                (p_typabs	like '3'	and	nvl(t1.qtyabsent,0)	> 0) or
                (p_typabs like '4'	and	nvl(t1.qtynostam,0)	> 0) or
                (p_typabs	like '5'	and	(
                    nvl(t1.qtylate  ,0)	> 0	or
                    nvl(t1.qtyearly ,0)	> 0 or
                    nvl(t1.qtyabsent,0)	> 0 or
                    nvl(t1.qtynostam,0)	> 0)))
        order by	t1.codempid	,t2.codcomp,t1.dtework,t1.codempid;
    cursor c2 is
        select  codrecod,timtime,dtedate
        from    tatmfile
        where   codempid = v_codempid
        and     dtetime between (v_dtedate - 1) and (v_dtedate + 1)
        order by dtetime;
  begin
    json_obj := json_object_t();
    for r1 in c1 loop
        v_data_exist := true;
        v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur then
            v_permission  := true;
            v_codrecod  := null;
            v_timtime   := null;
            v_dtedate   := r1.dtework;
            v_codempid  := r1.codempid;
            v_token     := null;
            v_detail    := '';
            v_qtylate   := '';
            v_qtyyearly := '';
            v_qtyabsent := '';
            v_qtynostam := '';

            for r2 in c2 loop
              v_codrecod  := r2.codrecod;
              v_timtime   := r2.timtime;
              if v_codrecod is not null then
                v_detail    := v_detail || v_token || v_codrecod || '-' || substr(v_timtime,1,2) || ':' || substr(v_timtime,3,2);
              else
                v_detail    := v_detail || v_token || substr(v_timtime,1,2) || ':' || substr(v_timtime,3,2);
              end if;
              v_token     := ',';
            end loop;

            if r1.qtylate > 0 then
              v_qtylate := to_char(floor(r1.qtylate/60  )) || ':' || lpad(to_char(mod(r1.qtylate,60  )),2,'0');
            end if;
            if r1.qtyearly > 0 then
              v_qtyyearly := to_char(floor(r1.qtyearly/60 )) || ':' || lpad(to_char(mod(r1.qtyearly,60 )),2,'0');
            end if;
            if r1.qtyabsent > 0 then
              v_qtyabsent := to_char(floor(r1.qtyabsent/60 )) || ':' || lpad(to_char(mod(r1.qtyabsent,60 )),2,'0');
            end if;

            if r1.qtynostam > 0 then
              v_qtynostam := to_char(r1.qtynostam);
            end if;

            json_row := json_object_t();
            json_row.put('image',get_emp_img(r1.codempid));
            json_row.put('codempid',r1.codempid);
            json_row.put('codcomp',r1.codcomp);
            json_row.put('desc_codempid',get_temploy_name(r1.codempid ,global_v_lang));
            json_row.put('codpos',r1.codpos);
            json_row.put('desc_codpos',get_tpostn_name(r1.codpos    ,global_v_lang));
            json_row.put('dtedate',to_char(v_dtedate,'dd/mm/yyyy'));
            json_row.put('qtylate',v_qtylate);
            json_row.put('qtyearly',v_qtyyearly);
            json_row.put('qtyabsent',v_qtyabsent);
            json_row.put('qtynostam',v_qtynostam);
            json_row.put('detail',v_detail);
            json_row.put('coderror','200');
            begin
              select codshift,   timstrtw,   timendw,   timin,   timout
                into v_codshift, v_timstrtw, v_timendw, v_timin, v_timout
                from tattence
               where r1.codempid like codempid
                 and r1.dtework  = dtework;
              v_char := '';
              if v_codshift is not null then
                v_char := '(' || v_codshift || ')';
              end if;
              if v_timstrtw is not null and v_timendw is not null then
                v_char := v_char || ' ' || substr(v_timstrtw,1,2) || ':' || substr(v_timstrtw,3,2) || ' - ' || substr(v_timendw,1,2) || ':' || substr(v_timendw,3,2);
              end if;
              json_row.put('timwrk',v_char);
              if not(v_timin is null and v_timout is null) then
                if v_timin is null then
                  json_row.put('timinout' , ' - ' || substr(v_timout,1,2) || ':' || substr(v_timout,3,2));
                elsif v_timout is null then
                  json_row.put('timinout' ,substr(v_timin,1,2) || ':' || substr(v_timin,3,2));
                else
                  json_row.put('timinout' ,substr(v_timin,1,2) || ':' || substr(v_timin,3,2) || ' - ' || substr(v_timout,1,2) || ':' || substr(v_timout,3,2));
                end if;
              end if;
            exception when no_data_found then
                v_codshift := null;
                v_timstrtw := null;
                v_timin    := null;
                v_timendw  := null;
                v_timout   := null;
            end;
            json_obj.put(to_char(v_count),json_row);
            v_count := v_count + 1;
        end if;
    end loop;
    if v_data_exist then
      if v_permission then
      -- 200 OK
        json_str_output := json_obj.to_clob;
--        dbms_lob.createtemporary(json_str_output, true);
--        json_obj.to_clob(json_str_output);
      else
        -- error permisssion denied HR3007
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      end if;
    else
      -- error data not found HR2055
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlateabs');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end HRAL39X;

/

--------------------------------------------------------
--  DDL for Package Body HRAL4BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4BX" as

  procedure initial_value(json_str_input in clob) as
    json_obj 				json_object_t;
  begin
    json_obj        		:= json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');

    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');

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
    v_token 	varchar2(4 char);
    v_codcomp varchar2(4000 char);
    v_numlvl  temploy1.numlvl%type;
  begin
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
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codempid is not null then
      begin
        select codempid,codcomp,numlvl
          into p_codempid,v_codcomp, v_numlvl
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
--      if not secur_main.secur3(v_codcomp,p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
--        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'temploy1');
--        return;
--      end if;
      if not secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'temploy1');
        return;
      end if;
    end if;
    if p_codcalen is not null then
        begin
            select codcodec
              into v_token
              from tcodwork
             where codcodec = p_codcalen;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
            return;
        end;
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj    json_object_t := json_object_t();
    json_row    json_object_t;
    v_count     number := 0;
    v_secur     varchar2(4000 char);
    v_exist     boolean := false;
    v_permis    boolean := false;
    v_r_codcomp temploy1.codcomp%type := null;
    v_comlevel  tcenter.comlevel%type;
    v_complb1   varchar2(4000 char);
    v_complb2   varchar2(4000 char);
    v_timin     tattence.timin%type;
    v_timout    tattence.timout%type;
    v_codshift  tattence.codshift%type;
    flgpass     boolean := true;
    cursor c1 is
        select	a.codcomp,a.codempid,a.dtewkreq,a.timstrt,a.timend,a.numotreq,a.typot, a.qtyminr,a.rowid
          from	totreqd a
         where	a.codempid = nvl(p_codempid,a.codempid)
           and	a.codcomp  like p_codcomp || '%'
           and	a.dtewkreq between p_dtestr and p_dteend
           and	nvl(a.codcalen,'@#$%') = nvl(p_codcalen,nvl(a.codcalen,'@#$%'))
           and (not exists (select	t.codempid,t.dtework
                              from	tovrtime t
                             where	t.codempid = a.codempid
                               and	t.dtework  = a.dtewkreq
                               and	t.typot    = a.typot
                               and	t.qtyminot > 0))
      order by	a.codcomp,a.dtewkreq,a.codempid,a.numotreq;
  begin
    for r1 in c1 loop
        v_exist := true;
        exit;
    end loop;
    if not v_exist then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'totreqd');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
        return;
    end if;
    for r1 in c1 loop
      flgpass	:= secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
        --if secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) is null then
            v_permis := true;
            begin
                select	timin,timout,codshift
                  into	v_timin,v_timout,v_codshift
                  from	tattence
                 where	codempid  = r1.codempid
                   and	dtework   = r1.dtewkreq;
            exception when no_data_found then
                v_timin   := '';
                v_timout  := '';
                v_codshift := '';
            end;
            json_row := json_object_t();
            json_row.put('dtework',to_char(r1.dtewkreq,'dd/mm/yyyy'));
            json_row.put('image',get_emp_img(r1.codempid));
            json_row.put('codempid',r1.codempid);
            json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            json_row.put('codcomp',r1.codcomp);
            json_row.put('codshift',v_codshift);
            json_row.put('timin' ,to_char(to_date(v_timin   ,'hh24mi'),'hh24:mi'));
            json_row.put('timout',to_char(to_date(v_timout  ,'hh24mi'),'hh24:mi'));
            json_row.put('qtyminr',to_char(hcm_util.convert_minute_to_hour(r1.qtyminr)));
            json_row.put('timstr',to_char(to_date(r1.timstrt,'hh24mi'),'hh24:mi'));
            json_row.put('timend',to_char(to_date(r1.timend ,'hh24mi'),'hh24:mi'));
            json_row.put('numotreq',r1.numotreq);
            json_row.put('typot',r1.typot);
            json_row.put('coderror','200');
            json_obj.put(to_char(v_count),json_row);
            v_count := v_count + 1;
        end if;
    end loop;
    if not v_permis then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
		json_str_output := json_obj.to_clob;
--    new swd and struc fix 8/5/2018
--    json_obj        json;
--    json_row        json;
--    v_count         number := 0;
--    v_exist         boolean := false;
--    v_permission    boolean := false;
--    v_secur         boolean;
--    v_timin         varchar2(4 char);
--    v_timout        varchar2(4 char);
--    v_codshift      varchar2(4 char);
--    v_codempid      varchar2(10 char);
--    v_dtewkreq      date;
--    v_codcomp       varchar2(40 char);
--
--    v_r_datewrk     date;
--    v_r_codempid    varchar2(10 char); -- desc,img
--    v_r_codcomp     varchar2(40 char); -- desc,namcent
--    v_r_codshift    varchar2(4 char);
--    v_i_datewrk     varchar2(100 char);
--    v_i_codempid    varchar2(10 char);
--    v_i_codcomp     varchar2(40 char);
--    v_i_codshift    varchar2(4 char);
--    v_lvlst         number;
--    v_lvlen         number;
--    v_namcentlvl    varchar2(4000 char);
--    v_namcent       varchar2(4000 char);
--    cursor c1 is
--        select	a.codcomp,a.codempid,a.dtewkreq,a.timstrt1,a.timend1,a.timstrt2,a.timend2,a.numotreq,a.codshift,a.rowid
--        from	totreqd a
--        where	a.codempid	=	    nvl(p_codempid,a.codempid)
--        and	    a.codcomp	like    p_codcomp || '%'
--        and	    a.dtewkreq  between p_dtestr and p_dteend
--        and	    a.codcalen  like    nvl(p_codcalen,a.codcalen)
--        and	    (not exists (	select	t.codempid,t.dtework
--                                from	tovrtime t
--                                where	t.codempid	= a.codempid
--                                and	    t.dtework	= a.dtewkreq
--                                and	    t.typot		= a.typot
--                                and	    t.qtyminot	> 0))
--        order by a.codcomp,a.dtewkreq,a.codempid;
--  begin
--    json_obj := json();
--    for r1 in c1 loop
--        v_codempid := r1.codempid;
--        v_dtewkreq := r1.dtewkreq;
--        v_codshift := r1.codshift;
--        v_codcomp  := r1.codcomp;
--        if v_codcomp <> v_r_codcomp or v_r_codcomp is null then-- codcomp change or strt
--            cmp_codcomp(v_r_codcomp,v_codcomp,v_lvlst,v_lvlen);
--            for lvl in v_lvlst..v_lvlen loop
--                get_center_name_lvl(v_codcomp,lvl,global_v_lang,v_namcentlvl,v_namcent);
--                json_row := json();
--                json_row.put('codempid'      , v_namcentlvl);
--                json_row.put('desc_codempid' , v_namcent);
--                json_row.put('coderror'      , '200');
--                json_obj.put(to_char(v_count),json_row);
--                v_count := v_count + 1;
--            end loop;
--        end if;
--        v_i_datewrk  :='';
--        v_i_codempid :='';
--        v_i_codcomp  :='';
--        v_i_codshift :='';
--        if ((v_dtewkreq <> v_r_datewrk  or v_r_datewrk  is null) or (v_codempid <> v_r_codempid or v_r_codempid is null) or
--            (v_codshift <> v_r_codshift or v_r_codshift is null) or (v_codcomp  <> v_r_codcomp  or v_r_codcomp  is null)) then --date change or codempid change or codshift change or codcomp change or strt
--            v_i_datewrk  := to_char(v_dtewkreq,'dd/mm/yyyy');
--            v_i_codempid := v_codempid;
--            v_i_codshift := v_codshift;
--        end if;
--        v_r_datewrk  := v_dtewkreq;
--        v_r_codempid := v_codempid;
--        v_r_codshift := v_codshift;
--        v_r_codcomp  := v_codcomp;
----        v_secur := (r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--        v_secur := true;
--        begin
--            select	timin,timout
--            into	v_timin,v_timout
--            from	tattence
--            where	codempid	=	v_codempid
--            and		dtework     = 	v_dtewkreq;
--            v_exist := true;
--            if v_secur then
--                v_permission := true;
--                json_row := json();
--                json_row.put('codempid' , v_i_codempid);
--                json_row.put('desc_codempid' , get_temploy_name(v_i_codempid,global_v_lang));
--                json_row.put('image' , get_emp_img(v_i_codempid));
--                json_row.put('dtework'  , v_i_datewrk);
--                json_row.put('timstr'   , substr(r1.timstrt1,1,2) || ':' || substr(r1.timstrt1,3,2));
--                json_row.put('timend'   , substr(r1.timend1,1,2) || ':' || substr(r1.timend1,3,2));
--                json_row.put('numotreq' , r1.numotreq);
--                json_row.put('timin'    , substr(v_timin,1,2) || ':' || substr(v_timin,3,2));
--                json_row.put('timout'   , substr(v_timout,1,2) || ':' || substr(v_timout,3,2));
--                json_row.put('codshift' , v_i_codshift);
--                json_row.put('coderror' , '200');
--                json_obj.put(to_char(v_count),json_row);
--                v_count := v_count + 1;
--                if r1.timstrt2 is not null and r1.timend2 is not null then
--                    json_row := json();
--                    json_row.put('codempid' , v_i_codempid);
--                    json_row.put('desc_codempid' , get_temploy_name(v_i_codempid,global_v_lang));
--                    json_row.put('image' , get_emp_img(v_i_codempid));
--                    json_row.put('dtework'  , v_i_datewrk);
--                    json_row.put('timstr'   , substr(r1.timstrt2,1,2) || ':' || substr(r1.timstrt2,3,2));
--                    json_row.put('timend'   , substr(r1.timend2,1,2) || ':' || substr(r1.timend2,3,2));
--                    json_row.put('numotreq' , r1.numotreq);
--                    json_row.put('timin'    , substr(v_timin,1,2) || ':' || substr(v_timin,3,2));
--                    json_row.put('timout'   , substr(v_timout,1,2) || ':' || substr(v_timout,3,2));
--                    json_row.put('codshift' , v_i_codshift);
--                    json_row.put('coderror' , '200');
--                    json_obj.put(to_char(v_count),json_row);
--                    v_count := v_count + 1;
--                end if;
--            end if;
--        exception when no_data_found then
--            if v_secur then
--                v_permission := true;
--                json_row := json();
--                json_row.put('codempid' , v_i_codempid);
--                json_row.put('desc_codempid' , get_temploy_name(v_i_codempid,global_v_lang));
--                json_row.put('image' , get_emp_img(v_i_codempid));
--                json_row.put('dtework'  , v_i_datewrk);
--                json_row.put('timstr'   , substr(r1.timstrt1,1,2) || ':' || substr(r1.timstrt1,3,2));
--                json_row.put('timend'   , substr(r1.timend1,1,2) || ':' || substr(r1.timend1,3,2));
--                json_row.put('numotreq' , r1.numotreq);
--                json_row.put('timin'    , '');
--                json_row.put('timout'   , '');
--                json_row.put('codshift' , v_i_codshift);
--                json_row.put('coderror' , '200');
--                json_obj.put(to_char(v_count),json_row);
--                v_count := v_count + 1;
--                if r1.timstrt2 is not null and r1.timend2 is not null then
--                    json_row := json();
--                    json_row.put('codempid' , v_i_codempid);
--                    json_row.put('desc_codempid' , get_temploy_name(v_i_codempid,global_v_lang));
--                    json_row.put('image' , get_emp_img(v_i_codempid));
--                    json_row.put('dtework'  , v_i_datewrk);
--                    json_row.put('timstr'   , substr(r1.timstrt2,1,2) || ':' || substr(r1.timstrt2,3,2));
--                    json_row.put('timend'   , substr(r1.timend2,1,2) || ':' || substr(r1.timend2,3,2));
--                    json_row.put('numotreq' , r1.numotreq);
--                    json_row.put('timin'    , '');
--                    json_row.put('timout'   , '');
--                    json_row.put('codshift' , v_i_codshift);
--                    json_row.put('coderror' , '200');
--                    json_obj.put(to_char(v_count),json_row);
--                    v_count := v_count + 1;
--                end if;
--            end if;
--        end;
--
--    end loop;
--
--
--    if v_exist then
--        if v_permission then
--            -- 200 OK
--            dbms_lob.createtemporary(json_str_output, true);
--            json_obj.to_clob(json_str_output);
--        else
--            -- error permisssion denied HR3007
--            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
--        end if;
--    else
--        -- error data not found HR2055
--        param_msg_error := get_error_msg_php('HR2055',global_v_lang);
--        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
--    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end HRAL4BX;

/

--------------------------------------------------------
--  DDL for Package Body HRAL48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL48X" as

  procedure initial_value(json_str_input in clob) as
    json_obj 						json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');

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
    v_codcomp temploy1.codcomp%type;
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
          into p_codempid,v_codcomp,v_numlvl
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
        return;
      end;
      if not secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj        json_object_t;
    json_row        json_object_t;
    v_count         number := 0;
    v_exist         boolean := false;
    v_permission    boolean := false;
    v_secur         boolean;
    v_codempid      temploy1.codempid%type;
    v_dtework       date;
    v_typot         varchar2(1 char);
    v_dtetimupd     date;
    v_detail        varchar2(500 char);
    v_detailn       varchar2(500 char);
    v_detailo       varchar2(500 char);
    v_first         boolean;
    v_numlvl        number;
    v_index         number := 0;
    v_amtmealo      number := 0;
    v_amtmealn      number := 0;
    v_codcompwo     varchar2(500 char);
    v_codcompwn     varchar2(500 char);

    v_numlvl1       number;
    v_token         number;
  	cursor c1 is
      select	a.codempid,a.dtetimupd,a.dtework,a.typot,a.codcomp,a.coduser,a.rowid,
                  a.dtestoto,a.timstoto,dteenoto,a.timenoto,a.amtmealo,a.qtyleaveo,
                  a.dtestotn,a.timstotn,dteenotn,a.timenotn,a.amtmealn,a.qtyleaven,
                  a.codcompwo,a.codcompwn
      from	tlogot a
      where	a.codempid	=	    nvl(p_codempid,a.codempid)
      and	    a.codcomp	like	p_codcomp || '%'
      and     a.dtework between p_dtestr and p_dteend
      order by a.dtetimupd,a.codempid , a.dtework,a.typot;

    cursor c2 is
      select	rteotpay,qtyminoto,qtyminotn,rowid
      from	tlogot2 b
      where	codempid	= v_codempid
      and     dtework		= v_dtework
      and     typot		= v_typot
      and     dtetimupd	= v_dtetimupd
      order by rteotpay;

  begin
    json_obj    := json_object_t();
    for r1 in c1 loop
        v_codempid      := r1.codempid;
        v_dtework       := r1.dtework;
        v_typot         := r1.typot;
        v_dtetimupd     := r1.dtetimupd;
        -- decode amtmeal --
        v_amtmealo      := stddec(r1.amtmealo,r1.codempid,v_chken);
        v_amtmealn      := stddec(r1.amtmealn,r1.codempid,v_chken);
        v_codcompwo     := r1.codcompwo;
        v_codcompwn     := r1.codcompwn;
        v_exist := true;
        begin
          v_secur   := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        exception when no_data_found then
          v_numlvl1 := null;
          v_secur := false;
        end;
--            v_secur := true;
        if v_secur then
            v_permission    := true;
            v_first         := true;
            v_detailo := to_char(r1.dtestoto,'dd/mm/yyyy')||' '||to_char(to_date(r1.timstoto,'HH24:MI'),'HH24:MI');
            v_detailn := to_char(r1.dtestotn,'dd/mm/yyyy')||' '||to_char(to_date(r1.timstotn,'HH24:MI'),'HH24:MI');
            if  v_detailo <> v_detailn then
                v_detail  := get_tlistval_name('HRAL48X',1,global_v_lang);
                json_row        := json_object_t();
                if v_first then
                    v_index := v_index + 1;
                end if;
                json_row.put('index'        , v_index);
                json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                json_row.put('coduser'      , r1.coduser);
                json_row.put('codempid'     , r1.codempid);
                json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp'      , r1.codcomp);
                json_row.put('image'        , get_emp_img(r1.codempid));
                json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                json_row.put('typot'        , r1.typot);
                json_row.put('old'          , v_detailo);
                json_row.put('new'          , v_detailn);
                json_row.put('detail'       , v_detail);
                json_row.put('coderror'     , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_first   := false;
                v_detailo := null;
                v_detailn := null;
            end if;

            v_detailo := to_char(r1.dteenoto,'dd/mm/yyyy')||' '||to_char(to_date(r1.timenoto,'HH24:MI'),'HH24:MI');
            v_detailn := to_char(r1.dteenotn,'dd/mm/yyyy')||' '||to_char(to_date(r1.timenotn,'HH24:MI'),'HH24:MI');
            if  v_detailo <> v_detailn then
                v_detail := get_tlistval_name('HRAL48X',2,global_v_lang);
                json_row        := json_object_t();
                if v_first then
                    v_index := v_index + 1;
                end if;
                json_row.put('index'        , v_index);
                json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                json_row.put('coduser'      , r1.coduser);
                json_row.put('codempid'     , r1.codempid);
                json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp'      , r1.codcomp);
                json_row.put('image'        , get_emp_img(r1.codempid));
                json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                json_row.put('typot'        , r1.typot);
                json_row.put('old'          , v_detailo);
                json_row.put('new'          , v_detailn);
                json_row.put('detail'       , v_detail);
                json_row.put('coderror'     , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_first   := false;
                v_detailo := null;
                v_detailn := null;
            end if;

            if  nvl(v_amtmealo,0) <> nvl(v_amtmealn,0) then
                v_detail := get_tlistval_name('HRAL48X',3,global_v_lang);
                v_detailo := v_amtmealo;
                v_detailn := v_amtmealn;
                json_row        := json_object_t();
                if v_first then
                    v_index := v_index + 1;
                end if;
                json_row.put('index'        , v_index);
                json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                json_row.put('coduser'      , r1.coduser);
                json_row.put('codempid'     , r1.codempid);
                json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp'      , r1.codcomp);
                json_row.put('image'        , get_emp_img(r1.codempid));
                json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                json_row.put('typot'        , r1.typot);
                begin
                    select  numlvl
                      into  v_numlvl
                      from  temploy1
                     where  codempid = r1.codempid;
                exception when others then
                    v_numlvl := null;
                end;
                if v_numlvl is not null and v_numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
                    json_row.put('old'          , v_detailo);
                    json_row.put('new'          , v_detailn);
                end if;
                json_row.put('detail'       , v_detail);
                json_row.put('coderror'     , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_first   := false;
                v_detailo := null;
                v_detailn := null;
            end if;

            if  nvl(r1.qtyleaveo,0) <> nvl(r1.qtyleaven,0) then
                v_detail := get_tlistval_name('HRAL48X',4,global_v_lang);
--                v_detailo := r1.qtyleaveo;
--                v_detailn := r1.qtyleaven;
                hcm_util.cal_dhm_hm (0,0,r1.qtyleaveo,null,'2',v_token,v_token,v_token,v_detailo);
                hcm_util.cal_dhm_hm (0,0,r1.qtyleaven,null,'2',v_token,v_token,v_token,v_detailn);
                json_row        := json_object_t();
                if v_first then
                    v_index := v_index + 1;
                end if;
                json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                json_row.put('coduser'      , r1.coduser);
                json_row.put('codempid'     , r1.codempid);
                json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp'      , r1.codcomp);
                json_row.put('image'        , get_emp_img(r1.codempid));
                json_row.put('index'        , v_index);
                json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                json_row.put('typot'        , r1.typot);
                json_row.put('old'          , v_detailo);
                json_row.put('new'          , v_detailn);
                json_row.put('detail'       , v_detail);
                json_row.put('coderror'     , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_first   := false;
                v_detailo := null;
                v_detailn := null;
            end if;

            if  nvl(v_codcompwo,'xxxxxxx') <> nvl(v_codcompwn,'xxxxxxx') then
                v_detail := get_tlistval_name('HRAL48X',6,global_v_lang);
                v_detailo := v_codcompwo;
                v_detailn := v_codcompwn;
                json_row        := json_object_t();
                if v_first then
                    v_index := v_index + 1;
                end if;
                json_row.put('index'        , v_index);
                json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                json_row.put('coduser'      , r1.coduser);
                json_row.put('codempid'     , r1.codempid);
                json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                json_row.put('codcomp'      , r1.codcomp);
                json_row.put('image'        , get_emp_img(r1.codempid));
                json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                json_row.put('typot'        , r1.typot);
                begin
                    select  numlvl
                      into  v_numlvl
                      from  temploy1
                     where  codempid = r1.codempid;
                exception when others then
                    v_numlvl := null;
                end;
                if v_numlvl is not null and v_numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
                --<<user25 Date : 28/10/2021 2.AL Module #6196
--                    json_row.put('old'          , v_detailo); 
--                    json_row.put('new'          , v_detailn);
                    json_row.put('old'          , hcm_util.get_codcomp_level(v_detailo,null,'-','Y'));
                    json_row.put('new'          , hcm_util.get_codcomp_level(v_detailn,null,'-','Y'));
                -->>user25 Date : 28/10/2021 2.AL Module #6196
                end if;
                json_row.put('detail'       , v_detail);
                json_row.put('coderror'     , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
                v_first   := false;
                v_detailo := null;
                v_detailn := null;
            end if;

            for r2 in c2 loop
                if  nvl(r2.qtyminoto,99999999999) <> nvl(r2.qtyminotn,99999999999) then
                    v_detail := get_tlistval_name('HRAL48X',5,global_v_lang)||' '||r2.rteotpay;
--                    v_detailo := r2.qtyminoto;
--                    v_detailn := r2.qtyminotn;
                    hcm_util.cal_dhm_hm (0,0,r2.qtyminoto,null,'2',v_token,v_token,v_token,v_detailo);
                    hcm_util.cal_dhm_hm (0,0,r2.qtyminotn,null,'2',v_token,v_token,v_token,v_detailn);
                    json_row        := json_object_t();
                    if v_first then
                        v_index := v_index + 1;
                    end if;
                    --
                    json_row.put('dtetimupd'    , to_char((r1.dtetimupd) ,'dd/mm/yyyy hh24:mi:ss'));
                    json_row.put('coduser'      , r1.coduser);
                    json_row.put('codempid'     , r1.codempid);
                    json_row.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
                    json_row.put('codcomp'      , r1.codcomp);
                    json_row.put('image'        , get_emp_img(r1.codempid));
                    json_row.put('index'        , v_index);
                    json_row.put('dtework'      , to_char((r1.dtework)   ,'dd/mm/yyyy'));
                    json_row.put('typot'        , r1.typot);
                    json_row.put('old'          , v_detailo);
                    json_row.put('new'          , v_detailn);
                    json_row.put('detail'       , v_detail);
                    json_row.put('rteotpay'     , r2.rteotpay);
                    json_row.put('coderror'     , '200');
                    json_obj.put(to_char(v_count),json_row);
                    v_count := v_count + 1;
                    v_first   := false;
                    v_detailo := null;
                    v_detailn := null;
                end if;
            end loop;
        end if;
    end loop;
    if v_exist then
        if v_permission then
            -- 200 OK
						json_str_output := json_obj.to_clob;
        else
            -- error permisssion denied HR3007
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        end if;
    else
        -- error data not found HR2055
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlogot');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end HRAL48X;

/

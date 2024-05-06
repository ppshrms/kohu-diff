--------------------------------------------------------
--  DDL for Package Body HRAL3NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3NX" is

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    p_codcomp			:= hcm_util.get_string_t(json_obj,'p_codcomp_query');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
  	p_flg 			    := hcm_util.get_string_t(json_obj,'p_flg');
  	p_flgn_in 		    := hcm_util.get_string_t(json_obj,'p_flgn_in');
  	p_flgn_out 		    := hcm_util.get_string_t(json_obj,'p_flgn_out');
  	p_flgy_in 		    := hcm_util.get_string_t(json_obj,'p_flgy_in');
  	p_flgy_out 		    := hcm_util.get_string_t(json_obj,'p_flgy_out');
  	p_timstrtw 		    := hcm_util.get_string_t(json_obj,'p_timstrtw');
  	p_dtestr 			:= to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
  	p_dteend 			:= to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index (json_str_input,json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_index is
  begin
    if p_flg is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_flg like '1' then
        if p_flgn_in is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if p_flgn_out is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
    elsif p_flg like '2' then
        if p_flgy_in is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        if p_flgy_out is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
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

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
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
  end check_index;

  procedure gen_index (json_str_input in clob, json_str_output out clob) is
  	json_obj 	   json_object_t;
  	json_row	   json_object_t;
    v_dtework    date;
  	v_count 	   number := 0;
    v_lvlst      number;
    v_lvlen      number;
    v_exist      boolean := false; -- data not found
    v_permis     boolean := false; -- permission
    v_secur      boolean;
	  v_concat  	 varchar2(2 char);
    v_codempid   varchar2(10 char);
  	v_detail	   varchar2(4000 char);
    v_codcomp    varchar2(4000 char);
    v_codempid2  varchar2(4000 char);
    v_namcentlvl varchar2(4000 char);
    v_namcent    varchar2(4000 char);
    v_comlevel  tcenter.comlevel%type;
  	cursor c1 is
      select t1.codempid,t1.dtework,t1.typwork,t1.timstrtw,t1.timendw,
             t1.timin   ,t1.timout ,t1.codcomp,t1.rowid
        from tattence t1
       where t1.codcomp  like p_codcomp || '%'
         and t1.codcalen like nvl(p_codcalen,'%')
         and t1.dtework  between p_dtestr and p_dteend
         and t1.timstrtw <= nvl(p_timstrtw,t1.timstrtw)
         and ((p_flg like '1' and
            (((p_flgn_in  like 'Y' and t1.timin  is NOT NULL) or (p_flgn_in	 like 'N')) and
             ((p_flgn_out like 'Y' and t1.timout is NOT NULL) or (p_flgn_out like 'N'))))
          or  (p_flg like '2' and
             ((p_flgy_in	like 'Y' and t1.timin  is NULL) 	  or (p_flgy_in	 like 'N')) and
             ((p_flgy_out like 'Y' and t1.timout is NULL)     or (p_flgy_out like 'N')))
          or  (p_flg like '3'))
	  order by /*t1.codcomp,*/ t1.codempid, t1.dtework;

    cursor c2 is
      select dtetime,codrecod,timtime,rowid
        from tatmfile
       where codempid = v_codempid
         and trunc(dtetime) = trunc(v_dtework);
  begin
  	json_obj 	:= json_object_t(json_str_input);
  	json_row	:= json_object_t();
  	for r1 in c1 loop
  		v_exist  := true; -- data found
      v_secur  := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

      if v_secur then
        v_permis := true;
        json_obj := json_object_t();
        json_obj.put('codempid'	     , r1.codempid);
        json_obj.put('codcomp'	     , r1.codcomp);
        json_obj.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
        json_obj.put('image'	       , get_emp_img(r1.codempid));
        v_codcomp := r1.codcomp;
        v_codempid2 := r1.codempid;
        json_obj.put('dtework'	 , to_char(r1.dtework,'dd/mm/yyyy'));
        json_obj.put('typwork'	 , r1.typwork);
        if r1.timstrtw is not null then
          json_obj.put('timstrtw'	, substr(r1.timstrtw,1,2)|| ':' || substr(r1.timstrtw,3,2));
        end if;
        if r1.timendw is not null then
          json_obj.put('timendw'	, substr(r1.timendw ,1,2)|| ':' || substr(r1.timendw ,3,2));
          end if;
        if r1.timin is not null then
          json_obj.put('timin'	  , substr(r1.timin   ,1,2)|| ':' || substr(r1.timin   ,3,2));
        end if;
        if r1.timout is not null then
          json_obj.put('timout'	  , substr(r1.timout  ,1,2)|| ':' || substr(r1.timout  ,3,2));
        end if;
        v_detail := '';
        v_concat := '';
        v_codempid := r1.codempid;
        v_dtework := r1.dtework;
        for r2 in c2 loop
          if r2.codrecod is not null then
            v_detail := v_detail||v_concat||r2.codrecod||'-'||
            substr(r2.timtime,1,2)||':'||substr(r2.timtime,3,2);
          else
            v_detail := v_detail||v_concat||
            substr(r2.timtime,1,2)||':'||substr(r2.timtime,3,2);
          end if;
          v_concat := ',';
        end loop;
        json_obj.put('detail'	, v_detail);
        json_obj.put('coderror' ,'200');
        json_row.put(to_char(v_count),json_obj);
        v_count := v_count + 1;
      end if;

    end loop;
    if v_exist then
      if v_permis then
        -- 200 OK
        dbms_lob.createtemporary(json_str_output, true);
        json_row.to_clob(json_str_output);
      else
        -- error permisssion denied HR3007
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'tattence');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    end if;
    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
end HRAL3NX;

/

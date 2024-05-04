--------------------------------------------------------
--  DDL for Package Body HRPMSAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMSAX" as

  procedure initial_value(json_str_input in clob) as
		json_obj		json_object_t;
		v_token			varchar2(4000 char) := '';
		v_token2		varchar2(4000 char) := '';
		v_codleave		json_object_t;

	begin
		json_obj          := json_object_t(json_str_input);
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');

		p_yearstrt    := hcm_util.get_string_t(json_obj,'p_yearstrt');
		p_monthstrt   := hcm_util.get_string_t(json_obj,'p_monthstrt');
		p_yearend     := hcm_util.get_string_t(json_obj,'p_yearend');

		p_monthend    := hcm_util.get_string_t(json_obj,'p_monthend');
		p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
		p_typreport   := hcm_util.get_string_t(json_obj,'p_typreport');

		dataselect := hcm_util.get_json_t(json_obj,'p_codcodec');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;


procedure vadidate_variable_getindex(json_str_input in clob) as
        date1 date;
        date2 date;
        v_chk number :=0;--08/12/2020

  BEGIN
    date1       :=  to_date(lpad(p_monthstrt,2,'0')||p_yearstrt,'MMYYYY');
    date2       :=  to_date(lpad(p_monthend,2,'0')||p_yearend,'MMYYYY');

    if (date1 > date2) then
      param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
      return ;
    end if;
    if (p_yearstrt > p_yearend) then
      param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
      return ;
    end if;
    if (p_yearstrt = p_yearend) then
      if (p_monthstrt > p_monthend) then
        param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
        return ;
      end if;
    end if;
    if (p_codcomp is null or p_codcomp = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_codcomp');
      return ;
    end if;
    if (p_monthstrt is null or p_monthstrt = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_monthstrt');
      return ;
    end if;
    if(p_yearstrt is null or p_yearstrt = ' ') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_yearstrt');
      return ;
    end if;
    if(p_monthend is null or p_monthend = ' ') then
      param_msg_error := get_error_msg_php('HR2027',global_v_lang, 'p_monthend');
      return ;
    end if;
    if(p_yearend is null or p_yearend = ' ') then
      param_msg_error := get_error_msg_php('HR2027',global_v_lang, 'p_yearend');
      return ;
    end if;
    if(p_typreport is null or p_typreport = ' ') then
      param_msg_error := get_error_msg_php('HR2027',global_v_lang, 'p_typreport');
      return ;
    end if;

    param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,p_codcomp);
    if(param_msg_error is not null ) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'');
        return;
    end if;
END vadidate_variable_getindex;

procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_index(json_str_output out clob) as
		obj_data		  json_object_t;
		obj_row			  json_object_t;
		obj_result		json_object_t;
		v_rcnt			  number := 0;
		dstr_tmp		  date := to_date('01/'||p_monthstrt||'/'||p_yearstrt,'dd/mm/yyyy');
		dstr2_tmp		  date := to_date('01/'||p_monthend||'/'||p_yearend,'dd/mm/yyyy');
		dend_tmp		  date := last_day(dstr2_tmp);

		dstr			        varchar2(100) := to_char(dstr_tmp,'YYYY-MM-DD');
		dend			        varchar2(100) := to_char(dend_tmp,'YYYY-MM-DD');
		p_codcodec_tmp		varchar2(10);
		v_statment		    varchar2(4000);
		sql_stmt		      VARCHAR2(200);
		cur SYS_REFCURSOR;
		v_codcomp		      thismist.codcomp%type;
		v_qtyemp		      number := 0;
		v_total			      number := 0;
		type tmp is table of integer;
		sto tmp := tmp();
		type			v_tmp is table of varchar2(100);
		tmp_codc v_tmp    := v_tmp();
        v_chk    number :=0;  --08/12/2020
        v_data   number :=0;  --08/12/2020

       dup_codcomp v_tmp := v_tmp();
		tmp_codcodec		  varchar2(10);
		graph_val tmp     := tmp();
		gv			          number := 0;
		v_data_exist		  boolean := false;
		idx			          number := 1;
		v_item4			      number := 0;
		v_item7			      number := 0;
		v_codmist		      varchar2(100);
    count_codcomp     number :=0;
    tmp_codcomp       thismist.codcomp%type;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();

		delete from ttemprpt
		where codapp = 'HRPMSAX'
		and codempid = global_v_codempid;

    --p_codcomp := hcm_util.get_codcomp_level(p_codcomp, to_number(p_typreport));

    v_chk :=0;  
    for i in 0..dataselect.get_size -1 loop
      p_codcodec_tmp := hcm_util.get_string_t(dataselect,to_char(i));

--      p_codcodec_tmp := dataselect.get(i).to_char();
			p_codcodec := REPLACE(p_codcodec_tmp,'"','');
			v_statment := 'select hcm_util.get_codcomp_level(t2.codcomp,'||p_typreport||',null,null) as codcomp ' ||
			' from thismist t2'||
			' where t2.codcomp like '||''''|| p_codcomp ||'%'''||
			' and t2.codmist in ('''||p_codcodec||''')'||
			' and to_char(t2.dtemistk,'''||'YYYY-MM-DD'||''')'|| 'between '||''''||dstr||''''||' and '||''''||dend||''''|| 
       --08/12/2020            
        /*
            ' and exists (select codcomp from tusrcom a'||
			' where a.coduser ='||''''|| global_v_coduser ||''''||
		    ' and t2.codcomp like a.codcomp||'''||'%'||''')'||
			' and t2.numlvl between '||global_v_zminlvl||' and '||global_v_zwrklvl||   
       */  
       --08/12/2020
			' group by t2.codcomp '||
			' order by t2.codcomp ';

			OPEN cur FOR v_statment;
			FETCH cur INTO v_codcomp;

 --08/12/2020 
    begin
      select t2.numlvl
        into v_chk
        from thismist t2
       where t2.codcomp like p_codcomp ||'%'
         and t2.codmist = p_codcodec
		 and to_char(t2.dtemistk,'YYYY-MM-DD') between  dstr and dend
         and rownum <= 1;                    
   exception when no_data_found then    
            v_chk := null;
     end;

     if v_chk  between   global_v_zminlvl   and     global_v_zwrklvl  then 
            v_data :=  nvl(v_data,0) + 1;
     else
            v_data :=  nvl(v_data,0) + 0;
     end if;
--08/12/2020

	  if cur%NOTFOUND then
         tmp_codc.extend;
         tmp_codc(i+1) := null;
      else
         tmp_codc.extend;
         tmp_codc(i+1) := v_codcomp;
      end if;
    end loop;

    dup_codcomp := tmp_codc;
    tmp_codc    := tmp_codc MULTISET UNION DISTINCT dup_codcomp;

    CLOSE cur;
    obj_row := json_object_t();
		for i in 1..tmp_codc.count loop
			obj_data := json_object_t();
        tmp_codcomp := tmp_codc(i);
          if tmp_codcomp is not null then
            v_rcnt := v_rcnt+1;
            obj_data.put('dep', get_tcenter_name(get_compful(tmp_codcomp),global_v_lang));
            v_item4 := 0;
            for j in 0..dataselect.get_size - 1 loop
              tmp_codcodec := hcm_util.get_string_t(dataselect,to_char(j));
--              tmp_codcodec := dataselect.get(j).to_char();
              tmp_codcodec := REPLACE(tmp_codcodec,'"','');
              sto.extend;
              graph_val.extend;
              v_item4 := v_item4+1;
              v_item7 := v_item7+1;

              sql_stmt := 'select count(*) from thismist a where a.codcomp like '||''''||tmp_codcomp||'%'''||
              ' and a.codmist = '''||tmp_codcodec||''''||
              ' and to_char(a.dtemistk,'''||'YYYY-MM-DD'||''')'|| 'between '||''''||dstr||''''||' and '||''''||dend||'''';

              EXECUTE IMMEDIATE sql_stmt into v_qtyemp;

              sto(j+1)  := v_qtyemp;
              v_total := v_total+sto(j+1);
              obj_data.put('leave'||(j+1), sto(j+1));
              obj_data.put('sum', v_total);

              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                          ITEM1,
                          ITEM4,ITEM5,
                          ITEM7,ITEM8,
                          ITEM9,ITEM10,ITEM31)
                   VALUES (global_v_codempid, 'HRPMSAX',idx,
                           get_label_name('HRPMSAX_GRAPH',global_v_lang,2),
                           '',get_tcenter_name(get_compful(tmp_codcomp),global_v_lang),
                           '',get_tcodec_name('tcodmist', tmp_codcodec,global_v_lang),
                           get_label_name('HRPMSAX_GRAPH',global_v_lang,4),v_qtyemp,get_label_name('HRPMSAX_GRAPH',global_v_lang,1));
              idx := idx+1;
              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                          ITEM1,
                          ITEM4,ITEM5,
                          ITEM7,ITEM8,
                          ITEM9,ITEM10,ITEM31)
                  VALUES (global_v_codempid, 'HRPMSAX',idx,
                          get_label_name('HRPMSAX_GRAPH',global_v_lang,3),
                          v_item4,get_tcodec_name('tcodmist', tmp_codcodec,global_v_lang),
                          '',get_tcenter_name(get_compful(tmp_codcomp),global_v_lang),
                          get_label_name('HRPMSAX_GRAPH',global_v_lang,4),v_qtyemp,get_label_name('HRPMSAX_GRAPH',global_v_lang,1));
              idx := idx+1;
              v_qtyemp := 0;
            end loop;
          obj_data.put('leavenum', dataselect.get_size);
          obj_data.put('coderror', '200');
          obj_data.put('rcnt', to_char(v_rcnt));
          obj_row.put(to_char(v_rcnt-1),obj_data);
          v_total := 0;
          v_data_exist := true;
      end if;
		end loop;

		if v_rcnt > 0 then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'THISMIST');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return ;
        end if;

          --<<08/12/2020
          if v_data = 0  then 
            param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return ;
          end if;        
         -->>08/12/2020

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_index;

	procedure check_label as
	begin
		null;
	end;

	procedure gen_label(json_str_output out clob) as
		json_obj		json_object_t;
		json_obj2		json_object_t;
		json_obj3		json_object_t;
		json_row		json_object_t;
		json_row2		json_object_t;
		v_count			number := 0;
		v_count2		number := 0;
		v_codcompy		tcenter.codcompy%type;

		cursor c1 is
		select codcodec
		from tcodmist
		order by codcodec;

	begin
		json_obj := json_object_t();
		json_obj2 := json_object_t();
		json_obj3 := json_object_t();
		for r1 in c1 loop
			json_row := json_object_t();
			json_row.put('listValue',r1.codcodec);
			json_row.put('listDesc',get_tcodec_name('TCODMIST',r1.codcodec,global_v_lang));
			json_obj2.put(to_char(v_count),json_row);
			v_count := v_count + 1;
		end loop;
		json_obj3.put('rows',json_obj2);
		json_obj.put('listFields',json_obj3);
		json_obj2 := json_object_t();
		json_obj3 := json_object_t();
		v_count := 0;

		json_obj3.put('rows',json_obj2);
		json_obj.put('formatFields',json_obj3);
		json_obj.put('coderror','200');
		json_str_output := json_obj.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_label;

	procedure get_label(json_str_input in clob,json_str_output out clob) as
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			gen_label(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
			return;
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_label;

end HRPMSAX;

/

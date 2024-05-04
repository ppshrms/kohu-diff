--------------------------------------------------------
--  DDL for Package Body HRPMS6X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS6X" AS

  procedure initial_value(json_str_input in clob) as
		json_obj		    json_object_t;
		logic			      json_object_t;
    p_param_json    json_object_t;
		count_codcomp		number := 0;
	begin
		json_obj := json_object_t(json_str_input);
		--global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

		p_choose      := hcm_util.get_string_t(json_obj,'p_choose');
		p_logic       := hcm_util.get_json_t(json_obj,'p_condition');
		p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		    boolean;
		tmp_v           varchar2(1000 char);
		comp_tmp		    varchar2(1000 char);
		count_dup		    number;
    v_codcomp       varchar2(100 char);
    v_secur         varchar2(1000 char);
    param_json_row  json_object_t;
		chk_dup tmp := tmp();
	BEGIN
		if (p_choose is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_choose');
			return ;
		end if;
    if p_choose = 1 then
      p_param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
      for i in 0..p_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(p_param_json,to_char(i));
        v_codcomp         := hcm_util.get_string_t(param_json_row,'codcomp');

        v_secur := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,v_codcomp);
        /*User37 #4945 1.PM Module 16/04/2021 if(v_secur is not null ) then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang, v_codcomp);
          return;
        end if;*/
      end loop;
    elsif p_choose = 2 then
      p_param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    end if;
	END vadidate_variable_getindex;


	procedure get_detail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			gen_detail(json_str_output);
            --<<User37 #4945 Final Test Phase 1 V11 26/02/2021
            if param_msg_error is not null then
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            end if;
            -->>User37 #4945 Final Test Phase 1 V11 26/02/2021
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_detail(json_str_output out clob)as
		obj_data		    json_object_t;
		obj_row			    json_object_t;
        param_row           json_object_t;
        v_syncond           json_object_t;
		v_rcnt			    number := 0;
		v_state			    varchar2(30000);
		v_code			    varchar2(4000);
		v_count			    number;
		v_count_all	        number;
		ratio			    varchar2(100);
		v_data_exist	    boolean := false;
		v_codcomp		    varchar2(100);
		v_res			    varchar2(100);
		v_total			    number;
		v_numemp		    number;
		v_seqno		        number := 0;
		idx			        varchar2(2);
        v_item5             clob;
        v_count_data        number := 0;--User37 #4945 Final Test Phase 1 V11 26/02/2021
        v_codcompin         varchar2(30000 char);--User37 #5688 Final Test Phase 1 V11 07/04/2021
    type t_array is table of varchar2(4000) index by binary_integer;
        v_array   t_array;
	begin
		obj_row   := json_object_t();
		obj_data  := json_object_t();
    -- clear ttemprpt
    begin
      delete
        from ttemprpt
       where codapp = 'HRPMS6X'
         and codempid = global_v_codempid;
    end;

    if(p_choose = 1) then
      v_code  :=  hcm_util.get_string_t(p_logic,'code');
      idx := 0;

      --<<User37 #4945 Final Test Phase 1 V11 26/02/2021
      for i in 0..p_param_json.get_size-1 loop
        param_row       := hcm_util.get_json_t(p_param_json,to_char(i));
        v_codcomp       := hcm_util.get_string_t(param_row,'codcomp');
        --<<User37 #5688 Final Test Phase 1 V11 07/04/2021
        if i = 0 then
            v_codcompin     := v_codcompin||'codcomp like '''||v_codcomp||'%''';
        else
            v_codcompin     := v_codcompin||' or codcomp like '''||v_codcomp||'%''';
        end if;
        /* v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||v_codcomp||'%'' and staemp in (1,3)'||
                   ' and hcm_secur.secur_main7(codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
                     and numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||
                   ' and ('|| v_code || ')';
        v_count_all     := execute_qty(v_state)+nvl(v_count_all,0);*/
        -->>User37 #5688 Final Test Phase 1 V11 07/04/2021
        /* User37 #4945 1.PM Module 16/04/2021 v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||v_codcomp||'%'' and staemp in (1,3)'||
                   ' and ('|| v_code || ')';
        v_count_data    := execute_qty(v_state)+nvl(v_count_data,0);*/
      end loop;

      --<<User37 #5688 Final Test Phase 1 V11 07/04/2021
      --v_codcompin := substr(v_codcompin,2);
      v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where ('||v_codcompin||') and staemp in (1,3)'||
                   ' and hcm_secur.secur_main7(codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
                     and numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||
                   ' and ('|| v_code || ')';
      v_count_all     := execute_qty(v_state)+nvl(v_count_all,0);

      --<<User37 #4945 1.PM Module 16/04/2021  
      v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where ('||v_codcompin||') and staemp in (1,3)'||
                   ' and ('|| v_code || ')';
      v_count_data    := execute_qty(v_state);
      -->>User37 #4945 1.PM Module 16/04/2021  
      -->>User37 #5688 Final Test Phase 1 V11 07/04/2021

      if v_count_data = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
        return;
      elsif v_count_all = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      -->>User37 #4945 Final Test Phase 1 V11 26/02/2021

      for i in 0..p_param_json.get_size-1 loop
        param_row    := hcm_util.get_json_t(p_param_json,to_char(i));
        v_codcomp    := hcm_util.get_string_t(param_row,'codcomp');

        obj_data := json_object_t();
				v_rcnt := v_rcnt+1;
				obj_data.put('coderror', '200');
				obj_data.put('rcnt', to_char(v_rcnt));
				obj_data.put('fst', get_tcenter_name(v_codcomp,global_v_lang));
				obj_data.put('codcomp', v_codcomp);

        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||v_codcomp||'%'' and staemp in (1,3)';

        --User37 #4945 Final Test Phase 1 V11 26/02/2021 v_count_all := execute_qty(v_state);
				obj_data.put('total',to_char(v_count_all,'fm99,999,990'));--User37 #4945 1.PM Module 16/04/2021 obj_data.put('total',v_count_all);

        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||v_codcomp||'%'' and staemp in (1,3)'||
                   --<<User37 #4945 Final Test Phase 1 V11 26/02/2021
                   ' and hcm_secur.secur_main7(codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
                     and numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||
                   -->>User37 #4945 Final Test Phase 1 V11 26/02/2021
                   ' and ('|| v_code || ')';

        v_count := execute_qty(v_state);
				obj_data.put('numemp',to_char(v_count,'fm99,999,990'));--User37 #4945 1.PM Module 16/04/2021 obj_data.put('numemp',v_count);

        if(v_count_all > 0 ) then
					ratio := to_char(round(v_count/v_count_all,4),'fm99,999,990.0000');
				else
					ratio := to_char(0,'fm99,999,990.0000');
				end if;

        obj_data.put('ratio', ratio);
				obj_row.put(to_char(v_rcnt-1),obj_data);
        idx := idx+1;
        v_seqno := v_seqno + 1;
        begin
          insert into ttemprpt(codempid,codapp,numseq,
                               item4,item5,item8,
                               item9,item10,item31)
               values (global_v_codempid, 'HRPMS6X',idx,
                       v_seqno,get_tcenter_name(get_compful(v_codcomp),global_v_lang),get_label_name('HRPMS6X2',global_v_lang,20),
                       get_label_name('HRPMS6X2',global_v_lang,60),v_count_all,get_label_name('HRPMS6X2',global_v_lang,70));

          idx := idx+1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,item8,
                                item9,item10,item31)
               values (global_v_codempid, 'HRPMS6X',idx,
                       v_seqno,get_tcenter_name(get_compful(v_codcomp),global_v_lang),get_label_name('HRPMS6X2',global_v_lang,30),
                       get_label_name('HRPMS6X2',global_v_lang,60),v_count,get_label_name('HRPMS6X2',global_v_lang,70));
        end;
      end loop;

			if (v_rcnt > 0) then
				v_data_exist := true;
			end if;
		end if;

if(p_choose = 2) then
      idx := 0;

      --<<User37 #4945 Final Test Phase 1 V11 26/02/2021
      for i in 0..p_param_json.get_size-1 loop
        param_row   := hcm_util.get_json_t(p_param_json,to_char(i));
        v_syncond   := hcm_util.get_json_t(param_row,'condition');
        v_code      := hcm_util.get_string_t(v_syncond,'code');
        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||p_codcomp||'%'' and staemp in (1,3)'||
                   ' and hcm_secur.secur_main7(codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
                     and numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||
                   ' and ('|| v_code || ')';
        v_count_all     := execute_qty(v_state)+nvl(v_count_all,0);
        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||p_codcomp||'%'' and staemp in (1,3)'||
                   ' and ('|| v_code || ')';
        v_count_data    := execute_qty(v_state)+nvl(v_count_data,0);
      end loop;

      if v_count_data = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
        return;
      elsif v_count_all = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      -->>User37 #4945 Final Test Phase 1 V11 26/02/2021

      for i in 0..p_param_json.get_size-1 loop
        param_row   := hcm_util.get_json_t(p_param_json,to_char(i));
        v_syncond   := hcm_util.get_json_t(param_row,'condition');
        v_code      := hcm_util.get_string_t(v_syncond,'code');
        v_array(i)  := v_code;

        obj_data := json_object_t();
        v_rcnt := v_rcnt+1;
        obj_data.put('coderror', '200');
        obj_data.put('rcnt', to_char(v_rcnt));
        obj_data.put('fst', get_logical_desc(hcm_util.get_string_t(v_syncond,'statement')));

        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||p_codcomp||'%'' and staemp in (1,3)';

        v_count_all := execute_qty(v_state);
				obj_data.put('total',to_char(v_count_all,'fm99,999,990'));--User37 #4945 1.PM Module 16/04/2021 obj_data.put('total',v_count_all);

        v_state := 'select count(distinct(codempid))'||
                   ' from V_HRPMA1 '||
                   ' where codcomp like '''||p_codcomp||'%'' and staemp in (1,3)'||
                   --<<User37 #4945 Final Test Phase 1 V11 26/02/2021
                   ' and hcm_secur.secur_main7(codcomp, ''' ||to_char(global_v_coduser) || ''') = ''Y''
                     and numlvl between '||to_char(global_v_numlvlsalst) ||' and '||to_char(global_v_numlvlsalen)||
                   -->>User37 #4945 Final Test Phase 1 V11 26/02/2021
                   ' and ('|| v_code || ')';

        v_count := execute_qty(v_state);
				obj_data.put('numemp',to_char(v_count,'fm99,999,990'));--User37 #4945 1.PM Module 16/04/2021 obj_data.put('numemp',v_count);

        if(v_count_all > 0 ) then
					ratio := to_char(round(v_count/v_count_all,4),'fm99,999,990.0000');
				else
					ratio := to_char(0,'fm99,999,990.0000');
				end if;

				obj_data.put('ratio', ratio);
				obj_row.put(to_char(v_rcnt-1),obj_data);
        v_item5 := get_logical_desc(hcm_util.get_string_t(v_syncond,'statement'));
        begin
          v_seqno := v_seqno + 1;
          idx := idx+1;
          insert into ttemprpt(codempid,codapp,numseq,
                               item4,item5,item8,
                               item9,item10,item31)
               values (global_v_codempid, 'HRPMS6X',idx,
                       v_seqno,v_item5,get_label_name('HRPMS6X2',global_v_lang,20),
                       get_label_name('HRPMS6X2',global_v_lang,60),v_count_all,get_label_name('HRPMS6X2',global_v_lang,70));

          idx := idx+1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,item8,
                                item9,item10,item31)
               values (global_v_codempid, 'HRPMS6X',idx,
                       v_seqno,v_item5,get_label_name('HRPMS6X2',global_v_lang,30),
                       get_label_name('HRPMS6X2',global_v_lang,60),v_count,get_label_name('HRPMS6X2',global_v_lang,70));
        end;
      end loop;

              for j in 0..v_array.count - 1 loop
                for k in 0..v_array.count - 1 loop
                  if j <> k and v_array(j) = v_array(k) then
                    param_msg_error := get_error_msg_php('HR8863',global_v_lang,null);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    rollback;
                    return;
                  end if;
                end loop;
              end loop;

			if (v_rcnt > 0) then
				v_data_exist := true;
			end if;


    end if;
        json_str_output := obj_row.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
---

procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_index(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		v_rcnt			number := 0;
		cursor c1 is
      select rownum,codcomp,
             decode(global_v_lang,'101',namcente,
                                  '102',namcentt,
                                  '103',namcent3,
                                  '104',namcent4,
                                  '105',namcent5) desc_codcomp
         from tcenter
     order by rownum;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
			obj_data := json_object_t();
			v_rcnt := v_rcnt+1;
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('numseq',r1.rownum);
			obj_data.put('codcomp',r1.CODCOMP);
			obj_data.put('desc_codcomp', r1.desc_codcomp);
			obj_row.put(to_char(v_rcnt-1),obj_data);

		end loop;
		if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);--User37 #4945 Final Test Phase 1 V11 26/02/2021 json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

END HRPMS6X;

/

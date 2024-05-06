--------------------------------------------------------
--  DDL for Package Body HRPMS7X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS7X" AS
--09/10/2019
	procedure initial_value (json_str in clob) AS
		json_obj		json_object_t;
	BEGIN
		json_obj := json_object_t(json_str);

		v_chken := hcm_secur.get_v_chken;
		global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');

		pa_codcomp := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_year := hcm_util.get_string_t(json_obj,'pa_year');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

	END initial_value;

	procedure get_index(json_str_input in clob, json_str_output out clob) AS
	BEGIN
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if (param_msg_error = ' ' or param_msg_error is null ) then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END get_index;

	procedure gen_index(json_str_output out clob) AS
		obj_row			json_object_t;
		obj_result		json_object_t;
		type			monthsarray is varray(12) of varchar2(3 char);
		type			monthsnamearray is varray(12) of varchar2(50 char);
		list_months monthsarray;
		list_namemonths monthsnamearray;
		v_qtyexman		number;
		v_dtestr		date ;
		v_dteend		date;
		v_qty_in		number;
		v_qty_out		number;
		count_row		number;
		numseq			number;

		cursor c_codcomp is
		select codcomp,codpos,count(*) qtyemp
		from   temploy1
		where  codcomp like pa_codcomp||'%'
    and    (staemp in ('1','3') or  (staemp = '9' and (dteeffex - 1) >= v_dtestr))
		group by codcomp,codpos
		order by codcomp,codpos;


        has_data       number := 0;
        numseq_graph number := 0 ;

        v_list_main_item_month json_object_t := json_object_t();
        v_list_main_item_deparment json_object_t := json_object_t();

        v_list_detail_item_month json_object_t := json_object_t();
        v_list_detail_item_deparment json_object_t := json_object_t();

        v_item_month  json_object_t ;
        v_item_deparment json_object_t ;

        v_count_item number := 0;


	BEGIN
		obj_result := json_object_t();
		count_row := 0;
		numseq := 1;
		list_months := monthsarray( 'm1','m2','m3','m4','m5','m6','m7','m8','m9','m10','m11','m12');
		list_namemonths := monthsnamearray(
		get_label_name('HRPMS7X1',global_v_lang,'50'),
		get_label_name('HRPMS7X1',global_v_lang,'60'),
		get_label_name('HRPMS7X1',global_v_lang,'70'),
		get_label_name('HRPMS7X1',global_v_lang,'80'),
		get_label_name('HRPMS7X1',global_v_lang,'90'),
		get_label_name('HRPMS7X1',global_v_lang,'100'),
		get_label_name('HRPMS7X1',global_v_lang,'110'),
		get_label_name('HRPMS7X1',global_v_lang,'120'),
		get_label_name('HRPMS7X1',global_v_lang,'130'),
		get_label_name('HRPMS7X1',global_v_lang,'140'),
		get_label_name('HRPMS7X1',global_v_lang,'150'),
		get_label_name('HRPMS7X1',global_v_lang,'160'));

		-- graph
		DELETE FROM TTEMPRPT
		WHERE CODAPP = 'HRPMS7X'
		AND CODEMPID = global_v_codempid;
    v_dtestr := to_date('01/01/'||pa_year,'dd/mm/yyyy');
    v_dteend := to_date('31/12/'||pa_year,'dd/mm/yyyy');

		for itemCursor in c_codcomp loop
			obj_row := json_object_t();

			obj_row.put('codcomp',get_tcenter_name(itemCursor.CODCOMP,global_v_lang));
			obj_row.put('codpos',get_tpostn_name(itemCursor.CODPOS,global_v_lang));
			obj_row.put('qtyemp',itemCursor.qtyemp);
			obj_row.put('namecomp',get_tcenter_name(itemCursor.CODCOMP,global_v_lang));
			obj_row.put('namepos',GET_TPOSTN_NAME(itemCursor.CODPOS,global_v_lang));

            for k in 1..12 loop
				begin
					select qtyexman into v_qtyexman
					from tmanpwm
					where codcomp = itemCursor.CODCOMP
					and codpos = itemCursor.CODPOS
					and dteyrbug = pa_year
					and dtemthbug = k ;
				exception when NO_DATA_FOUND THEN
					v_qtyexman := 0 ;
				end;

				obj_row.put(to_char( list_months(k)),v_qtyexman);

                v_item_month := json_object_t ();
                v_item_month.put('namemonth',list_namemonths(k));
                v_item_month.put('qtyexman',v_qtyexman);
                v_item_month.put('tcentername',get_tcenter_name(itemCursor.CODCOMP,global_v_lang));
                v_item_month.put('tpostnname',get_tpostn_name(itemCursor.CODPOS,global_v_lang));
                v_item_month.put('sortitem4',k);
                v_item_month.put('global_v_codempid',global_v_codempid);
                v_item_month.put('item4',numseq_graph);

                for i in 1..1 loop

                v_item_deparment := json_object_t();

                v_item_deparment.put('sortitem5',i);
                v_item_deparment.put('qtyexman',v_qtyexman);
                v_item_deparment.put('namemonths',list_namemonths(k));
                v_item_deparment.put('tcentername',get_tcenter_name(itemCursor.CODCOMP,global_v_lang));
                v_item_deparment.put('tpostnname',get_tpostn_name(itemCursor.CODPOS,global_v_lang));
                v_item_deparment.put('item4',numseq_graph);
                end loop;

                v_list_detail_item_month.put(k,v_item_month);
                v_list_detail_item_deparment.put(k,v_item_deparment);

                 numseq_graph := numseq_graph + 1;

			end loop;

               v_list_main_item_month.put(v_count_item,v_list_detail_item_month);
               v_list_main_item_deparment.put(v_count_item,v_list_detail_item_deparment);

               v_count_item := v_count_item + 1;

			v_dtestr := to_date('01/01/'||pa_year,'dd/mm/yyyy');
			v_dteend := to_date('31/12/'||pa_year,'dd/mm/yyyy');
			begin
				select count(*) into v_qty_in
				from temploy1
				where codcomp = itemCursor.CODCOMP
				and codpos = itemCursor.CODPOS
				and DTEEMPMT BETWEEN v_dtestr and v_dteend;
				obj_row.put('qtyin',v_qty_in);

			exception when NO_DATA_FOUND THEN
				v_qty_in := 0;
				obj_row.put('qtyin',v_qty_in);
			end ;
			begin
				select count(*) into v_qty_out
				from temploy1
				where codcomp = itemCursor.CODCOMP
				and codpos = itemCursor.CODPOS
				and (DTEEFFEX - 1) BETWEEN v_dtestr and v_dteend;
				obj_row.put('qtyout',v_qty_out);
			exception when NO_DATA_FOUND THEN
				v_qty_out := 0;
				obj_row.put('qtyout',v_qty_out);
			end ;

            if v_qty_in != 0 and v_qty_out != 0 then
                has_data := has_data +1;
            end if;

			obj_result.put(count_row,obj_row);
			count_row := count_row + 1;
		end loop;

        if count_row != 0 then

            insert_graph (v_list_main_item_month,v_list_main_item_deparment);


            json_str_output := obj_result.to_clob;

        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TEMPLOY1');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

	exception when others then
	  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	END gen_index;


     procedure  insert_graph (v_item_month_json in json_object_t,v_item_deparment_json in json_object_t) as
     v_item_main json_object_t;
     v_item_detail json_object_t;
     v_seq number := 1;
     v_item2 varchar2(1000 char);
     v_item3 varchar2(1000 char);           
     v_item5 varchar2(1000 char);
     v_item10 varchar2(1000 char);                                    
     v_item12  varchar2(1000 char);

     begin
            --- Month
           for i in 1..v_item_month_json.get_size
           loop
                    v_item_main := hcm_util.get_json_t (v_item_month_json,i);
                    for j in  1..v_item_main.get_size 
                    loop
                            v_item_detail := hcm_util.get_json_t(v_item_main,j);
                            v_item2 := hcm_util.get_string_t(v_item_detail,'namemonth');
                            v_item3 := hcm_util.get_string_t(v_item_detail,'tcentername');           
                            v_item5 := hcm_util.get_string_t(v_item_detail,'tpostnname');
                            v_item10 := hcm_util.get_string_t(v_item_detail,'qtyexman');                                    
                            v_item12 := lpad(hcm_util.get_string_t(v_item_detail,'sortitem4'),2,'0');
                                        INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM9,ITEM10,ITEM8,ITEM31,ITEM12,ITEM13)
                                        VALUES (global_v_codempid, 'HRPMS7X', 
                                        v_seq,
                                        get_label_name('HRPMS7X1',global_v_lang,190), 
                                        v_item2,
                                        v_item3,
                                        v_seq, 
                                        v_item5,get_label_name('HRPMS7X2',global_v_lang,100),
                                        v_item10, 
                                        get_label_name('HRPMS7X2',global_v_lang,110),
                                        get_label_name('HRPMS7X_GRAPH',global_v_lang,1),
                                        v_item12,null);
                                        v_seq := v_seq + 1;
                    end loop;
           end loop;

           --- Deparment
              for i in 1..v_item_deparment_json.get_size
           loop
                    v_item_main := hcm_util.get_json_t(v_item_deparment_json,i);
                    for j in  1..v_item_main.get_size 
                    loop
                            v_item_detail := hcm_util.get_json_t(v_item_main,j);
                            v_item2 := hcm_util.get_string_t(v_item_detail,'tcentername');
                            v_item3 := hcm_util.get_string_t(v_item_detail,'tpostnname');
                            v_item10 := hcm_util.get_string_t(v_item_detail,'qtyexman');
                            v_item5 := hcm_util.get_string_t(v_item_detail,'namemonths');

                                         INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM10,ITEM5,ITEM9,ITEM8,ITEM31,ITEM12,ITEM13)
                                        VALUES (global_v_codempid, 'HRPMS7X', v_seq,
                                         get_label_name('HRPMS7X1',global_v_lang,30),
                                         v_item2,
                                         v_item3,
                                         v_seq,
                                         v_item10,
                                         v_item5,
                                         get_label_name('HRPMS7X2',global_v_lang,100),
                                         get_label_name('HRPMS7X2',global_v_lang,110),
                                         get_label_name('HRPMS7X_GRAPH',global_v_lang,1),
                                         null,
                                         null);

                                        v_seq := v_seq + 1;
                    end loop;
           end loop;

     end;

	procedure vadidate_variable_getindex(json_str_input in clob) AS

		cursor c_resultcodcomp is select CODCOMP
		from TCENTER
		where CODCOMP like pa_codcomp||'%';
		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;

        sysyear varchar2(4);

	BEGIN
		if (pa_codcomp is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		if (pa_year is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang);
			return;
		end if;

		if (pa_codcomp is not null and pa_codcomp <> ' ') then
			OPEN c_resultcodcomp;
			FETCH c_resultcodcomp INTO objectCursorResultcodcomp ;
			IF (c_resultcodcomp%NOTFOUND) THEN
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TCENTER');
				return;
			END IF;
			CLOSE c_resultcodcomp;
		end if;

		if(pa_codcomp is not null ) then
			param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
			if(param_msg_error is not null ) then
				return;
			end if;
		end if;
	END vadidate_variable_getindex;

END HRPMS7X;

/

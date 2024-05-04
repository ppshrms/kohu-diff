--------------------------------------------------------
--  DDL for Package Body HRPMS4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS4X" is
-- last update: 17/09/2020 11:00

  procedure initial_value(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj      := json_object_t(json_str);
		v_chken       := hcm_secur.get_v_chken;

		global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
		pa_codcomp              := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_quantity             := hcm_util.get_string_t(json_obj,'pa_quantity');
		pa_condition            := hcm_util.get_string_t(json_obj,'pa_condition');
		pa_ability              := hcm_util.get_string_t(json_obj,'pa_ability');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_variable_getindex(json_str_input in clob) as

		v_codcodec		TCODSKIL.CODCODEC%type;
		cursor c_resultcodcomp is
      select CODCOMP
        from TCENTER
       where CODCOMP like pa_codcomp||'%';

		objectCursorResultcodcomp c_resultcodcomp%ROWTYPE;

	begin
		if (pa_quantity is null or TO_CHAR(pa_quantity) = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;

		if (pa_quantity is null or TO_CHAR(pa_quantity) = '0') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;
		if (pa_condition is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;

		if (pa_condition = '18' and pa_ability is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;
		if (pa_condition is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;

		if (pa_codcomp is not null) then
			begin
				OPEN c_resultcodcomp;
				FETCH c_resultcodcomp INTO objectCursorResultcodcomp;
				IF (c_resultcodcomp%NOTFOUND) THEN
					param_msg_error := get_error_msg_php('HR2010',global_v_lang, '');
					return ;
				END IF;
				CLOSE c_resultcodcomp;
			end;
		end if;
		if (pa_ability is not null and pa_ability <> ' ') then
			begin
				select CODCODEC into v_codcodec
				from TCODSKIL
				where CODCODEC = pa_ability;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang, '');
				return;
			end;
		end if;


		if(pa_codcomp is not null) then
			param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,pa_codcomp);
			if(param_msg_error is not null ) then
				return;
			end if;
		end if;
	end vadidate_variable_getindex;

	procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
	begin
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			gen_index(json_str_output);
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_index(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;

		cursor c1 is
      select a.codempid,a.codcomp,a.codpos,a.dteempdb,a.numlvl
        from temploy1 a
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
       order by a.dteempdb,a.codempid;

		cursor c2 is
      select a.codempid,a.codcomp,a.codpos,a.dteempmt,a.numlvl
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and a.dteempmt is not null
       order by a.dteempmt,codempid;

		cursor c3 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl
        from temploy1 a
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
       order by a.numlvl desc;

		cursor c4 is
      select a.codempid,a.codcomp,a.codpos,codedlv,a.numlvl
        from temploy1 a
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codedlv is not null
       order by a.codedlv desc,codempid;

       cursor c5 is  --for pa_condition = 5-codpos,19-jobgrade
      select a.codempid,a.codcomp,a.numlvl,a.codpos,
               decode (pa_condition,'5',a.codpos,a.jobgrade) colmn_cond
        from temploy1 a
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
       order by decode (pa_condition,'5',a.codpos,a.jobgrade) desc,a.codempid;

		/*16 - weight*/
		cursor c6 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.weight
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and b.weight is not null
       order by b.weight desc,a.codempid asc;

		/*17 - high*/
		cursor c7 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.high
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and b.high is not null
       order by b.high desc,a.codempid asc;

		cursor c8 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,d.grade
        from temploy1 a,temploy2 b,temploy3 c,tcmptncy d
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and d.codtency = pa_ability
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and a.numappl = d.numappl
         and d.numappl is not null
         and d.grade is not null
       order by d.grade desc,a.codempid asc;

		cursor cin1 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom1
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom1,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom1,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin2 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom2
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom2,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom2,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin3 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom3
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom3,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom3,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin4 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom4
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom4,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom4,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin5 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom5
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom5,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom5,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin6 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom6
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom6,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom6,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin7 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom7
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom7,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom7,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin8 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom8
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom8,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom8,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin9 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom9
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom9,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom9,b.codempid,v_chken)) desc,a.codempid asc;

		cursor cin10 is
      select a.codempid,a.codcomp,a.codpos,a.numlvl,b.codempid codempid2,c.amtincom10
        from temploy1 a,temploy2 b,temploy3 c
       where a.codcomp like nvl(pa_codcomp||'%','%')
         and a.staemp in('1','3')
         and a.codempid = b.codempid
         and c.codempid = c.codempid
         and a.codempid = c.codempid
         and c.amtincom10 is not null
         and stddec(c.amtincom10,b.codempid,v_chken)>0
       order by to_number(stddec(c.amtincom10,b.codempid,v_chken)) desc,a.codempid asc;

      passsecur1		    boolean;
      count_data_row		number;
      v_statment		    varchar2(2000 char);
      seqgraph		      number;
      flgsecur_sla      boolean := false;
      data_salary       varchar2(2000 char) := '';
      data_salary2      varchar2(2000 char) := '';

      t_year		        number  := 0;
      t_month   	      number  := 0;
      t_day 		        number  := 0;

      v_flgdata           varchar2(1):= 'N';                     
      v_flgsecu           varchar2(1):= 'N';  
      v_columndesc     tcodjobg.descodt%TYPE;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
		count_data_row := 0;
		/* Remove Data Graph*/
		delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRPMS4X';
		/* */
		seqgraph := 0;

		if pa_condition = '1' then
			for r1 in c1 loop
            v_flgdata  := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', get_age(r1.dteempdb,null));
					obj_row.put(to_char(v_rcnt-1),obj_data);

          -- find age
          get_service_year(r1.dteempdb,sysdate,'Y',t_year,t_month,t_day);
					insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRPMS4X',v_rcnt,
                        r1.codempid,get_temploy_name(r1.codempid,global_v_lang),
--                        t_year||''||t_month||''||t_day,get_temploy_name(r1.codempid,global_v_lang),
                        get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                        t_year||'.'||t_month,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

				end if;
				count_data_row := count_data_row + 1;
				if (count_data_row = pa_quantity ) then
					exit ;
				end if;

			end loop;
		elsif pa_condition = '2' then
			for r1 in c2 loop
            v_flgdata  := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', get_age(r1.dteempmt,null));
					obj_row.put(to_char(v_rcnt-1),obj_data);

          -- find work age
          get_service_year(r1.dteempmt,sysdate,'Y',t_year,t_month,t_day);
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRPMS4X',v_rcnt,
                        r1.codempid,get_temploy_name(r1.codempid,global_v_lang),
--                        t_year||''||t_month||''||t_day,get_temploy_name(r1.codempid,global_v_lang),
                        get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                        t_year||'.'||t_month,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '3' then
			for r1 in c3 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';  
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', r1.numlvl);
					obj_row.put(to_char(v_rcnt-1),obj_data);

          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRPMS4X',v_rcnt,
                        r1.numlvl,get_temploy_name(r1.codempid,global_v_lang),
                        get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                        r1.numlvl,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '4' then
			for r1 in c4 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y'; 
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', get_tcodec_name('TCODEDUC',r1.codedlv,global_v_lang));
					obj_row.put(to_char(v_rcnt-1),obj_data);

          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item8,item9,
                                item10,item31)
               values (global_v_codempid, 'HRPMS4X',v_rcnt,
                        seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                        get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                        get_tcodec_name('TCODEDUC',r1.codedlv,global_v_lang),get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition in ('5' ,'19') then  --codpos,jobgrade
			for r1 in c5 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
--<<redmine 1971					
               if pa_condition = '5' then  
                  --codpos 
                  v_columndesc := get_tpostn_name(r1.colmn_cond,global_v_lang);                  
               else--19
                  --jobgrade
                  v_columndesc := get_tcodec_name('TCODJOBG',r1.colmn_cond,global_v_lang);                  
               end if;
               obj_data.put('condition', v_columndesc);
-->>redmine 1971					

               obj_row.put(to_char(v_rcnt-1),obj_data);

          insert into ttemprpt (codempid,codapp,numseq,
                                         item4,item5,
                                         item8,item9,
                                         item10,item31)
                              values (global_v_codempid, 'HRPMS4X',v_rcnt,
                                          seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                                          get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                                          v_columndesc,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

               if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '6' then
			for r1 in cin1 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
                --check secure salary
                flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

                if v_zupdsal = 'Y' then
                  data_salary := to_char(stddec(r1.amtincom1,r1.codempid2,v_chken),'fm999,999,999,990.00');
                  data_salary2 := to_char(stddec(r1.amtincom1,r1.codempid2,v_chken));
                else
                  data_salary := '';
                end if;

                obj_data.put('condition', data_salary);
                obj_row.put(to_char(v_rcnt-1),obj_data);
                insert into ttemprpt (codempid,codapp,numseq,
                            item4,item5,item8,item9,
                            item10,item31)
                 values (global_v_codempid, 'HRPMS4X',v_rcnt,
                          seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                          get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                          data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

                     if (v_rcnt = pa_quantity ) then
                        exit ;
                     end if;
                  end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '7' then
			for r1 in cin2 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom2,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom2,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '8' then
			for r1 in cin3 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom3,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom3,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;

				end if;
				count_data_row := count_data_row + 1;
			end loop;
		elsif pa_condition = '9' then
			for r1 in cin4 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom4,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom4,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;
			end loop;
		elsif pa_condition = '10' then
			for r1 in cin5 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom5,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom5,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition',data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;
			end loop;
		elsif pa_condition = '11' then
			for r1 in cin6 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom6,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom6,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;

				end if;
				count_data_row := count_data_row + 1;
			end loop;
		elsif pa_condition = '12' then
			for r1 in cin7 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom7,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom7,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '13' then
			for r1 in cin8 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';  
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom8,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom8,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition', data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '14' then
			for r1 in cin9 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y'; 
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom9,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom9,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition',data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '15' then
			for r1 in cin10 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
           --check secure salary
          flgsecur_sla := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

          if v_zupdsal = 'Y' then
            data_salary := to_char(stddec(r1.amtincom10,r1.codempid2,v_chken),'fm999,999,999,990.00');
            data_salary2 := to_char(stddec(r1.amtincom10,r1.codempid2,v_chken));
          else
            data_salary := '';
          end if;
					obj_data.put('condition',data_salary);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    data_salary2,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		elsif pa_condition = '16' then
			for r1 in c6 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', r1.weight);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    r1.weight,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;

				end if;
				count_data_row := count_data_row + 1;
			end loop;
		elsif pa_condition = '17' then
			for r1 in c7 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal); 
        if(v_zupdsal = 'Y') then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;
					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', r1.high);
					obj_row.put(to_char(v_rcnt-1),obj_data);

					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    r1.high,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));
					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;

				end if;
				count_data_row := count_data_row + 1;
			end loop;
		else
			for r1 in c8 loop
            v_flgdata   := 'Y';
				passsecur1 := secur_main.secur1(pa_codcomp ,r1.numlvl ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
				if(passsecur1 = true) then
               v_flgsecu  := 'Y';
					v_rcnt := v_rcnt+1;
					seqgraph := seqgraph +1;

					obj_data := json_object_t();
					obj_data.put('coderror', '200');
					obj_data.put('rcnt', to_char(v_rcnt));
					obj_data.put('image', get_emp_img(r1.codempid));
					obj_data.put('codempid', r1.codempid);
					obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
					obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
					obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));
					obj_data.put('condition', r1.grade);
					obj_row.put(to_char(v_rcnt-1),obj_data);
					insert into ttemprpt (codempid,codapp,numseq,
                      item4,item5,
                      item8,item9,
                      item10,item31)
           values (global_v_codempid, 'HRPMS4X',v_rcnt,
                    seqgraph,get_temploy_name(r1.codempid,global_v_lang),
                    get_tcenter_name(get_compful(pa_codcomp),global_v_lang),get_tlistval_name('HRPMS4X',pa_condition,global_v_lang),
                    r1.grade,get_label_name('HRPMS4X_GRAPH',global_v_lang,1));

					if (v_rcnt = pa_quantity ) then
						exit ;
					end if;
				end if;
				count_data_row := count_data_row + 1;

			end loop;
		end if;
--<<redmine PM-1860
		  --json_str_output := obj_row.to_clob;         
        if v_flgdata = 'N' then
         param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TEMPLOY1');
         json_str_output := get_response_message(null, param_msg_error, global_v_lang);
       elsif v_flgsecu = 'N' then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       else
         json_str_output := obj_row.to_clob;
       end if;
-->>redmine PM-1860

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
end HRPMS4X;

/

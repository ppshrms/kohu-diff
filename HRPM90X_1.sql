--------------------------------------------------------
--  DDL for Package Body HRPM90X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM90X" is

	procedure initial_value(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj          := json_object_t(json_str);
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    v_chken           := hcm_secur.get_v_chken;
		pa_codcomp        := hcm_util.get_string_t(json_obj,'pa_codcomp');
		pa_codempid       := hcm_util.get_string_t(json_obj,'pa_codempid');
		pa_typmove        := hcm_util.get_string_t(json_obj,'pa_typmove');
		pa_dtestr         := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dtestr')),'dd/mm/yyyy');
		pa_dteend         := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dteend')),'dd/mm/yyyy');
		v_codempid        := hcm_util.get_string_t(json_obj,'p_codempid');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		    boolean;
		v_codcomp       temploy1.codcomp%type;
    v_numlvl        temploy1.numlvl%type;
    tmp             tcenter.codcomp%type;
	BEGIN
		if pa_codcomp is not null and pa_codempid is not null then
			pa_codcomp := '';
		end if;
		if pa_codempid is not null and pa_dtestr is not null and pa_dteend is not null then
			pa_dtestr := '';
			pa_dteend := '';
		end if;

		if pa_codcomp is not null and pa_dtestr is null and pa_dteend is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;
		if pa_codcomp is null and pa_codempid is null and pa_dtestr is null and pa_dteend is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;

		if (pa_codcomp is null and pa_codempid is null) then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
			return ;
		end if;
		if pa_typmove is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_typmove');
			return ;
		end if;

		if (pa_codcomp is not null) then
			begin
				select codcomp into tmp
          from tcenter
				 where codcomp like pa_codcomp||'%'
           and rownum <=1;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'p_codcomp');
				return;
			end;
		end if;
		if (pa_codempid is not null) then
			begin
				select codcomp,numlvl into v_codcomp,v_numlvl
          from temploy1
				 where codempid = pa_codempid
           and rownum <=1;
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'p_codempid');
				return;
			end;
		end if;

		if pa_dtestr > pa_dteend then
			param_msg_error := get_error_msg_php('HR2021',global_v_lang,'');
			return;
		end if;

    if (pa_codcomp is not null) then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,pa_codcomp);
      if(param_msg_error is not null ) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
      end if;
    end if;

    if (pa_codempid is not null) then
      chk_bool := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if(chk_bool = false ) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
      end if;
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

	procedure gen_index(json_str_output out clob)as
		obj_data		          json_object_t;
		obj_row			          json_object_t;
		v_rcnt			          number := 0;
    v_codpos              temploy1.codpos%type;
    v_dteempmt            temploy1.dteempmt%type;
    v_dteretire           temploy1.dteretire%type;
    v_staemp              temploy1.staemp%type;
    v_codcomp             temploy1.codcomp%type;
    v_ttrehire_dtereemp   ttrehire.dtereemp%type;
    v_ttrehire_codpos     ttrehire.codpos%type;
    v_table_error         varchar2(50 char);
		cursor c1 is
      select codempid,codcomp,codpos,numlvl,'T' typmove,dtereemp dtetranquit
        from ttrehire t1
       where flgmove = 'T'
         and pa_codempid is null
         and codcomp like nvl(pa_codcomp||'%','%')
         and dtereemp between pa_dtestr and pa_dteend
         and pa_typmove = 'T'
      union all
      select codempid,codcomp,codpos,numlvl,'Q' typmove,dteeffec dtetranquit
        from ttexempt
       where codcomp like nvl(pa_codcomp||'%','%')
         and dteeffec between pa_dtestr and pa_dteend
         and pa_codempid is null
         and pa_typmove = 'Q'
      union all
      select codempid,codcomp,codpos,numlvl,'E' typmove,null dtetranquit
        from temploy1
       where pa_codempid is not null
         and codempid = pa_codempid
    order by codempid;

	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
      v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
			obj_data.put('codempid', r1.codempid);
			obj_data.put('name', get_temploy_name(r1.codempid,global_v_lang));
			obj_data.put('dep', get_tcenter_name(r1.codcomp,global_v_lang));
			obj_data.put('pos', get_tpostn_name(r1.codpos,global_v_lang));

      begin
        select codpos,dteempmt,dteeffex,staemp
          into v_codpos,v_dteempmt,v_dteretire,v_staemp
          from temploy1 
         where codempid = r1.codempid;

      exception when no_data_found then
        null;
      end;
      begin
--        select codcomp 
--          into v_codcomp
--          from ttrehire
--         where codempid = r1.codempid
--           and DTEREEMP = decode(r1.dtetranquit,null,DTEREEMP,r1.dtetranquit);
--           
         select dtereemp,codpos,codcomp
           into v_ttrehire_dtereemp,v_ttrehire_codpos,v_codcomp
           from ttrehire
          where dtereemp = (select max(dtereemp)
                              from ttrehire
                             where codempid = r1.codempid)
           and  codempid = r1.codempid;
      exception when no_data_found then
        v_codcomp := null;
      end;
      obj_data.put('codpos', get_tpostn_name(v_codpos,global_v_lang));
      obj_data.put('dteempmt', to_char(v_dteempmt,'dd/mm/yyyy'));
			obj_data.put('dteretire', to_char(r1.dtetranquit,'dd/mm/yyyy'));
			obj_data.put('dtetran', to_char(v_ttrehire_dtereemp,'dd/mm/yyyy') );
			obj_data.put('dtetranquit', to_char(r1.dtetranquit,'dd/mm/yyyy'));
			obj_data.put('staemp', get_tlistval_name('FSTAEMP', v_staemp,global_v_lang));
      obj_data.put('codcomp', nvl(r1.codcomp,v_codcomp));
--      obj_data.put('codcomp', get_tcenter_name(v_codcomp,global_v_lang));
--      obj_data.put('codbrlc', get_tpostn_name(v_ttrehire_codpos,global_v_lang));
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
    if pa_typmove = 'T' then
      v_table_error := 'TTREHIRE';
    elsif pa_typmove = 'Q' then
      v_table_error := 'ttexempt';
    else
      v_table_error := 'temploy1';
    end if;
		if v_rcnt > 0 then
			json_str_output := obj_row.to_clob;
		else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, v_table_error);
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure initial_report(json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj          := json_object_t(json_str);
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    v_chken           := hcm_secur.get_v_chken;
		json_codshift     := hcm_util.get_json_t(json_obj, 'p_codshift');
    json_dteeff       := hcm_util.get_json_t(json_obj, 'p_dteeff');


    pa_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
		pa_typmove := hcm_util.get_string_t(json_obj,'p_typmove');
		pa_dtestr := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestr')),'dd/mm/yyyy');
		pa_dteend := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
	end initial_report;

	procedure gen_report(json_str_input in clob,json_str_output out clob) is
		json_param_in     clob;
		json_param_out    clob;
    obj_data          json_object_t;
	begin
		initial_report(json_str_input);
		isInsertReport  := true;
        numYearReport   := HCM_APPSETTINGS.get_additional_year();

		if param_msg_error is null then
			clear_ttemprpt;
			for i in 0..json_codshift.get_size-1 loop
				v_codempid  := hcm_util.get_string_t(json_codshift, to_char(i));
                v_dteeff    := hcm_util.get_string_t(json_dteeff, to_char(i));
                str_dteeff  := to_date(v_dteeff,'dd/mm/yyyy');
                begin
                  select codcomp
                    into pa_codcomp
                    from temploy1
                   where codempid = v_codempid;
                end;
                obj_data := json_object_t(); 
                obj_data.put('p_coduser', global_v_coduser);
                obj_data.put('p_codpswd', global_v_codpswd);
                obj_data.put('p_lang', global_v_lang);
                obj_data.put('p_codempid', global_v_codempid);
                obj_data.put('psearch_codempid', v_codempid);
                obj_data.put('psearch_codcomp', pa_codcomp);
                obj_data.put('psearch_codapp', 'HRPM90X');
                json_param_in := obj_data.to_clob;

                begin
                    delete
                      from ttemprpt
                     where codempid = global_v_codempid
                       and codapp = 'HRPM90X'
                       and item2 = v_codempid;
                exception when others then
                    null;
                end;

                std_pmdetail.get_emp_info(json_param_in, json_param_out);
                std_pmdetail.get_approve_remain(json_param_in, json_param_out);
                std_pmdetail.get_tloaninf_info(json_param_in, json_param_out);
                std_pmdetail.get_trepay_info(json_param_in, json_param_out);
                std_pmdetail.get_tfunddet_info(json_param_in, json_param_out);
                std_pmdetail.get_tassets_info(json_param_in, json_param_out);
                std_pmdetail.get_tleavsum_info(json_param_in, json_param_out);
                std_pmdetail.get_tempinc_info(json_param_in, json_param_out);
                std_pmdetail.get_tothinc_info(json_param_in, json_param_out);
                std_pmdetail.get_tguarntr_info(json_param_in, json_param_out);
                std_pmdetail.get_tcolltrl_info(json_param_in, json_param_out);
        commit;
			end loop;

		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;
	procedure clear_ttemprpt is
	begin
		begin
			delete
			from ttemprpt
			where codempid = global_v_codempid
			and codapp = 'HRPM90X';
		exception when others then
			null;
		end;
	end clear_ttemprpt;
end HRPM90X;

/

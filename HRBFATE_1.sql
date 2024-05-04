--------------------------------------------------------
--  DDL for Package Body HRBFATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBFATE" as

    procedure initial_value (json_str in clob) as
        json_obj            json_object_t;
    begin
        json_obj            := json_object_t(json_str);
        -- global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

        p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
        p_mailalno          := hcm_util.get_string_t(json_obj,'p_mailalno');
        p_typsubj           := hcm_util.get_string_t(json_obj,'p_typsubj');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    end initial_value;

    procedure get_index (json_str_input in clob, json_str_output out clob) as
        obj_row       json_object_t;
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
    end get_index;

    procedure gen_index (json_str_output out clob) as
        obj_row            json_object_t     := json_object_t();
        obj_data           json_object_t;
        v_count_codcompy   number   := 0;
        v_rcnt             number   := 0;
        v_status           varchar2(100 char);
        v_flg_secure7      boolean  := false;

        cursor c1 is
          select codcompy,mailalno,dteeffec, subject, message, flgeffec
            from tbfalert
           where codcompy = p_codcompy
        order by mailalno, dteeffec desc;
    begin
        -- check codcompy exists in tcompny
        select count(codcompy) into v_count_codcompy
          from tcompny
         where codcompy = p_codcompy;
        if v_count_codcompy = 0 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
             json_str_output := get_response_message('400',param_msg_error,global_v_lang);
             return;
        end if;

        -- secur_main.secur7
        v_flg_secure7 := secur_main.secur7(p_codcompy, global_v_coduser);
        if not v_flg_secure7 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        for r1 in c1 loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcompy', r1.codcompy);
          obj_data.put('desc_codcompy', get_tcompny_name(r1.codcompy,global_v_lang));
          obj_data.put('mailalno', r1.mailalno);
          obj_data.put('subject', r1.subject);
          obj_data.put('dteeffec', to_char(r1.dteeffec, 'dd/mm/yyyy'));
          obj_data.put('desc_flgeffec', get_tlistval_name('FLGAPPRS',r1.flgeffec,global_v_lang));
          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt := v_rcnt + 1;
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    end gen_index;

    procedure getDestroy (json_str_input in clob, json_str_output out clob) as
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			number;
        p_codcompy      tbfalert.codcompy%type;
		p_mailalno		tbfalert.mailalno%type;
		p_dteeffec		tbfalert.dteeffec%type;
		arr_destroy		json_object_t;
    begin
		obj_data        := json_object_t(json_str_input);
		arr_destroy     := hcm_util.get_json_t(obj_data,'params');

		obj_row         := json_object_t();
		v_rcnt          := 0;

		for i in 0..arr_destroy.get_size-1 loop
			obj_row     := json_object_t();
			obj_row     := hcm_util.get_json_t(arr_destroy,to_char(i));
			p_codcompy  := hcm_util.get_string_t(obj_row, 'codcompy');
			p_mailalno  := hcm_util.get_string_t(obj_row, 'mailalno');
			p_dteeffec  := to_date(hcm_util.get_string_t(obj_row, 'dteeffec'), 'dd/mm/yyyy');
			begin
				delete from tbfalert where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tbfparam where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tbfasign where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tmailrbf where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
			end;
		end loop;

		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end getDestroy;

    function get_seqno (v_codcompy varchar2, v_mailalno varchar2, v_dteeffec date) return number is
        v_number  number;
    begin
        begin
          select nvl(max(seqno), 0) + 1
            into v_number
            from tbfasign
           where codcompy = v_codcompy
             and mailalno = v_mailalno
             and dteeffec = v_dteeffec;
        end;
        return v_number;
    end;

	procedure getParams (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		genParams(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end getParams;

	procedure genParams (json_str_output out clob) is
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		flg_data		boolean := true;
        v_row			number := 0;
        v_desc			varchar2(200 char);

		cursor c_params is
            select *
              from tbfparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
          order by fparam;
	begin
		obj_row := json_object_t();
		v_rcnt  := 0;

        for r2 in c_params loop
            v_rcnt := v_rcnt + 1;

            obj_data := json_object_t();
            obj_data.put('numseq', r2.numseq);
            obj_data.put('param', r2.fparam);
            obj_data.put('paramdesc', r2.descript);
            obj_data.put('parameter', r2.ffield);
            obj_data.put('flginput', 'Y');
            obj_data.put('codtable', r2.codtable);
            obj_data.put('flgdesc', r2.flgdesc);
            obj_row.put(v_rcnt - 1, obj_data);
        end loop;

		json_str_output := obj_row.to_clob;
	end genParams;

	procedure getAssign (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		genAssign(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end getAssign;

	procedure genAssign (json_str_output out clob) is
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		flg_data		boolean := true;
        v_row			number := 0;
        v_desc			varchar2(200 char);

       cursor c_assign is
            select *
              from tbfasign
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
          order by seqno;

	begin
		obj_row := json_object_t();
		v_rcnt  := 0;

        for r1 in c_assign loop
            v_row       := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('seqno', r1.seqno);
            obj_data.put('flgappr', r1.flgappr);
            obj_data.put('codcompap', r1.codcompap);
            obj_data.put('codposap', r1.codposap);
            obj_data.put('codempap', r1.codempap);
            obj_data.put('message', r1.message);
            obj_row.put(v_row - 1, obj_data);
        end loop;

		json_str_output := obj_row.to_clob;
	end genAssign;

	procedure getDetail (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		genDetail(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end getDetail;

    procedure genDetail (json_str_output out clob) as
        v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		flg_data		boolean := false;
        obj_syncond     json_object_t;
        obj_params      json_object_t;
        obj_params_row	json_object_t;
        obj_assign      json_object_t;
        obj_assign_row	json_object_t;
        obj_mailrbf     json_object_t;
        obj_mailrbf_row json_object_t;
        v_row			number := 0;
        v_desc			varchar2(200 char);
        v_message_display tbfalert.message%type;

		cursor c1 is
            select codcompy, mailalno, dteeffec, codsend, qtydayb, message,
                   qtydayr, subject, typemail, flgeffec, running,
                   syncond, nvl(statement,'') as statement, get_logical_desc(statement) as description
              from tbfalert
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and trunc(dteeffec) = p_dteeffec;

		cursor c_params is
            select *
              from tbfparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and trunc(dteeffec) = p_dteeffec
          order by fparam;
	begin
		obj_row := json_object_t();
		v_rcnt  := 0;
		for r1 in c1 loop
			obj_data        := json_object_t();
            obj_params      := json_object_t();
            obj_syncond     := json_object_t();
            obj_params_row  := json_object_t();
            obj_assign_row  := json_object_t();
            obj_mailrbf_row := json_object_t();
            v_message_display   := r1.message;
			obj_data.put('coderror', '200');
			flg_data        := true;
            
            obj_data.put('codcompy', r1.codcompy);
			obj_data.put('mailalno', r1.mailalno);
			obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('typemail', r1.typemail);
            obj_data.put('flgeffec', r1.flgeffec);
            obj_data.put('subject', r1.subject);

            obj_syncond.put('code', nvl(r1.syncond,''));
            obj_syncond.put('statement', nvl(r1.statement,''));
            obj_syncond.put('description', nvl(r1.description,''));
            obj_data.put('syncond', obj_syncond);
            obj_data.put('codsend', r1.codsend);
			obj_data.put('qtydayb', r1.qtydayb);
			obj_data.put('qtydayr', r1.qtydayr);
			obj_data.put('status', 'edit');
			obj_data.put('dteeffec_old', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('mailalno_old', r1.mailalno);
            obj_data.put('message_display', r1.message);
            for r2 in c_params loop
                v_message_display :=  replace(v_message_display ,r2.fparam,'['||r2.descript||']');
            end loop;
            obj_data.put('message', v_message_display);
			obj_row.put(to_char(v_rcnt), obj_data);
			v_rcnt := v_rcnt + 1;
		end loop;

		if not flg_data then
			obj_data    := json_object_t();
			obj_row     := json_object_t();
            obj_syncond := json_object_t();
			v_rcnt      := 0;
            obj_data.put('codcompy', p_codcompy);
			obj_data.put('mailalno', p_mailalno);
			obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
			obj_data.put('flgeffec', 'A');
            obj_data.put('codsend', global_v_codempid);
            obj_syncond.put('code', '');
            obj_syncond.put('statement', '');
            obj_syncond.put('description', '');
            obj_data.put('syncond', obj_syncond);
			obj_row.put(to_char(v_rcnt), obj_data);
		end if;

		json_str_output := obj_row.to_clob;
    end genDetail;

    procedure get_define_reciver(json_str_input in clob, json_str_output out clob) as
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		gen_define_reciver(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_define_reciver;

    procedure gen_define_reciver (json_str_output out clob) as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;

		cursor list_codtable is
           select *
             from tbfasign
            where codcompy = p_codcompy
              and mailalno = p_mailalno
              and dteeffec = p_dteeffec
            order by seqno;

	begin
		obj_data := json_object_t();
		obj_row := json_object_t();
		v_rcnt := 0;
		for r1 in list_codtable loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('seqno', r1.seqno);
            obj_data.put('flgappr', r1.flgappr);
            obj_data.put('codcompap', r1.codcompap);
            obj_data.put('codposap', r1.codposap);
            obj_data.put('codempap', r1.codempap);
            obj_data.put('message', r1.message);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		dbms_lob.createtemporary(json_str_output, true);
		obj_row.to_clob(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end gen_define_reciver;

    procedure post_report_format (json_str_input in clob, json_str_output out clob) is
		json_obj		    json_object_t;
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		param_json		    json_object_t;
		param_json_table	json_object_t;
		param_json_row		json_object_t;
		v_rcnt			    number := 0;
		is_found_rec		boolean := false;
		cursor c1 is
            select *
              from tmailrbf
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
         order by numseq;
	begin
		initial_value(json_str_input);
		obj_row     := json_object_t();
		obj_data    := json_object_t();
		for r1 in c1 loop
			v_rcnt      := v_rcnt+1;
			obj_data    := json_object_t();
			is_found_rec := true;
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('codcompy', r1.codcompy);
			obj_data.put('mailalno', r1.mailalno);
			obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
			obj_data.put('codtable', substr(r1.pfield,1,instr(r1.pfield,'.')-1));
			obj_data.put('pfield', substr(r1.pfield,instr(r1.pfield,'.')+1));
			obj_data.put('numseq', r1.numseq);
			obj_data.put('pdesct', r1.pdesct);
			if r1.flgdesc = 'Y' then
				obj_data.put('flgdesc', true);
			else
				obj_data.put('flgdesc', false);
			end if;
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		dbms_lob.createtemporary(json_str_output, true);
		obj_row.to_clob(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

    procedure post_delete_report_format (json_str_input in clob/*, json_str_output out clob*/) as
		json_str		    json_object_t;
		param_json		    json_object_t;
		param_json_row		json_object_t;
		v_numseq		    number := 0;
		v_flag			    varchar2(10 char);
        p_mailalno          tmailrbf.mailalno%type;
        p_flgDelete         boolean;
        p_flgdesc           tmailrbf.flgdesc%type;
        p_numseq            tmailrbf.numseq%type;
        p_pfield            tmailrbf.pfield%type;
        p_pdesct            tmailrbf.pdesct%type;
	begin
		initial_value(json_str_input);
		json_str    := json_object_t(json_str_input);
		param_json  := json_object_t(hcm_util.get_string_t(json_str, 'dataRows'));
		for i in 0..param_json.get_size-1 loop
			param_json_row  := json_object_t(param_json.get(to_char(i)));
            p_flgDelete     := hcm_util.get_boolean_t(param_json_row, 'flgDelete');
            p_flgdesc       := hcm_util.get_string_t(param_json_row, 'flgdesc');
            p_mailalno      := hcm_util.get_string_t(param_json_row, 'mailalno');
            p_numseq        := hcm_util.get_string_t(param_json_row,'numseq');

			if p_flgDelete then
				begin
					delete tmailrbf
					 where codcompy = p_codcompy
                       and mailalno = p_mailalno
					   and dteeffec = p_dteeffec
					   and numseq = p_numseq;
				exception when others then
                    null;
				end;
			else null;
				begin
					update tmailrbf
					   set pfield = pfield,
					       flgdesc = v_flag,
					       pdesct = p_pdesct,
                           coduser = global_v_coduser
                     where codcompy = p_codcompy
                       and mailalno = p_mailalno
					   and dteeffec = p_dteeffec
					   and numseq = p_numseq;

					if sql%rowcount = 0 then
                        begin
                            select max(numseq)
                              into v_numseq
                              from tmailrbf
                             where codcompy = p_codcompy
                               and mailalno = p_mailalno
                               and dteeffec = p_dteeffec;
                        exception when others then
                            v_numseq := 1;
                        end;
                        if v_numseq is null then
                            v_numseq := 1;
                        end if;

						insert into tmailrbf (codcompy, mailalno, dteeffec, pfield,
                                              pdesct, flgdesc,numseq,coduser,codcreate)
						              values (p_codcompy, p_mailalno, p_dteeffec, p_pfield,
                                              p_pdesct, v_flag, v_numseq + 1, global_v_coduser, global_v_coduser);
					end if;
                exception when others then
                    null;
				end;
			end if;
		end loop;
	end;

    procedure get_list_detail_param (json_str_input in clob, json_str_output out clob) as
		json_obj		json_object_t;
        obj_item		json_object_t;
	begin
		json_obj   := json_object_t(json_str_input);
		p_typsubj  := hcm_util.get_string_t(json_obj, 'p_typsubj');
        if param_msg_error is null then
            gen_list_detail_param(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_list_detail_param;

    procedure gen_list_detail_param (json_str_output out clob) as
		obj_row			json_object_t   := json_object_t();
        obj_list    	json_object_t   := json_object_t();

		cursor c1 is select * from tfmtable where codapp = 'HRBFATE1' /*and numseq = p_typsubj*/ order by codtable desc;
        cursor c2 is select * from tfmtable where codapp = 'HRBFATE2' /*and numseq = p_typsubj*/ order by codtable desc;
        cursor c3 is select * from tfmtable where codapp = 'HRBFATE3' /*and numseq = p_typsubj*/ order by codtable desc;

	begin
		obj_row := json_object_t();
        
		obj_row.put('0','Please select');
		obj_row.put('coderror', '200');
        if p_typsubj = '1' then
            for r1 in c1 loop
                obj_row.put(r1.codtable, r1.codtable);
            end loop;
        elsif p_typsubj = '2' then
            for r2 in c2 loop
                obj_row.put(r2.codtable, r2.codtable);
            end loop;
        elsif p_typsubj = '3' then
            for r3 in c3 loop
                obj_row.put(r3.codtable, r3.codtable);
            end loop;
        end if;
		json_str_output := obj_row.to_clob;
	end gen_list_detail_param;

    procedure get_running_param (json_str_input in clob, json_str_output out clob) as
        obj_row         json_object_t;
		json_obj		json_object_t;
        obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		g_mailalno := hcm_util.get_string_t(json_obj, 'p_mailalno');
		g_dteeffec := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'),'dd/mm/yyyy');
		if g_mailalno is not null and g_dteeffec is not null then
			gen_running_param(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_running_param;

	procedure gen_running_param (json_str_output out clob)as
		obj_row			json_object_t   := json_object_t();
		obj_result		json_object_t;
		v_rcnt			number := 0;
		str_running		varchar2(200 char);
	begin
		begin
           select running into str_running
             from tbfalert
            where codcompy = p_codcompy
              and mailalno = g_mailalno
              and dteeffec = g_dteeffec;
		exception when no_data_found then
			str_running := null;
		end;
		obj_row.put('coderror', '200');
		obj_row.put('running', str_running);

		dbms_lob.createtemporary(json_str_output, true);
		obj_row.to_clob(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end gen_running_param;

    procedure get_list_detail_table(json_str_input in clob, json_str_output out clob) as
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj   := json_object_t(json_str_input);
		p_codtable := hcm_util.get_string_t(json_obj, 'p_codtable');
        
		if p_codtable is not null then
			gen_list_detail_table(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

    procedure gen_list_detail_table(json_str_output out clob)as
        obj_data		json_object_t;
        obj_row			json_object_t;
        v_rcnt			number := 0;

    cursor c_tcoldesc is
        select *
          from tcoldesc
         where codtable = p_codtable
      order by column_id;
	begin
		obj_row     := json_object_t();
		v_rcnt      := 0;

		for r1 in c_tcoldesc loop
			v_rcnt      := v_rcnt + 1;
			obj_data    := json_object_t();
			obj_data.put('coderror','200');
            obj_data.put('codtable',r1.codtable);
			obj_data.put('codcolmn',r1.codcolmn);
            if global_v_lang = '101' then
                obj_data.put('desc',r1.descole);
    		elsif global_v_lang = '102' then
                obj_data.put('desc',r1.descolt);
        	elsif global_v_lang = '103' then
                obj_data.put('desc',r1.descol3);
            elsif global_v_lang = '104' then
				obj_data.put('desc',r1.descol4);
            elsif global_v_lang = '105' then
				obj_data.put('desc',r1.descol5);
    		else
        		obj_data.put('desc',r1.descole);
            end if;
			obj_data.put('flgdesc',r1.flgdisp);
			obj_data.put('checbox',false);
			obj_row.put(v_rcnt - 1, obj_data);
		end loop;

		dbms_lob.createtemporary(json_str_output, true);
		obj_row.to_clob(json_str_output);
    end gen_list_detail_table;

    procedure get_list_item_table (json_str_input in clob, json_str_output out clob) as
        obj_row         json_object_t;
		json_obj		json_object_t;
        obj_item		json_object_t;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		gen_list_item_table(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_list_item_table;

    procedure gen_list_item_table (json_str_output out clob)as
        obj_data        json_object_t;
        obj_row         json_object_t   := json_object_t();
        obj_result      json_object_t;
        v_rcnt          number := 0;
        v_row           number := 0;
        v_desc          varchar2(200 char);

        cursor c_listitemtable is
            select *
              from tbfparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec;

    begin
        for r1 in c_listitemtable loop
            v_row := v_row + 1;
            begin
                if global_v_lang = '101' then
                    select descole into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                elsif global_v_lang = '102' then
                    select descolt into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                elsif global_v_lang = '103' then
                    select descol3 into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                elsif global_v_lang = '104' then
                    select descol4 into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                elsif global_v_lang = '105' then
                    select descol5 into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                else
                    select descole into v_desc from tcoldesc where codtable = r1.codtable and codcolmn = r1.ffield;
                end if;
            exception when others then
                v_desc := '';
            end;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('paramname',r1.fparam);
            obj_data.put('paramdesc',v_desc);
            obj_data.put('param',r1.ffield);
            obj_data.put('numseq',r1.numseq);
            obj_data.put('codtable',r1.codtable);
            obj_row.put(v_row - 1, obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end gen_list_item_table;

    procedure saveData (json_str_input in clob, json_str_output out clob) as
        json_obj                json_object_t;
        json_str                json_object_t;
        obj_row                 json_object_t;
        p_qtydayb               tbfalert.qtydayb%type;
        p_message               tbfalert.message%type;
        p_qtydayr               tbfalert.qtydayr%type;
        p_subject               tbfalert.subject%type;
        p_typemail              tbfalert.typemail%type;
        p_status                varchar2(10 char);
        p_flgeffec              tbfalert.flgeffec%type;
        p_syncond               json_object_t;
        p_codsend               tbfalert.codsend%type;
        p_code                  tbfalert.syncond%type;
        p_statement             tbfalert.statement%type;
        arr_params		        json_object_t;
		arr_assign	            json_object_t;
        arr_report              json_object_t;
		obj_row_param		    json_object_t;
		v_sysdate		        varchar2(50 char);
		p_ffield		        tbfparam.ffield%type;
        p_descript              tbfparam.descript%type;
		p_codtable		        tbfparam.codtable%type;
		p_fparam		        tbfparam.fparam%type;
		p_flgdesc	            tbfparam.flgdesc%type;
		p_flgdesc_b	            boolean;
		p_numseq		        tbfparam.numseq%type;
		v_numseq		        number := 0;
		p_flgDelete		        boolean;
        v_flgDelete_assign      boolean;

        p_pfield                tmailrbf.pfield%type;
        p_pdesct                tmailrbf.pdesct%type;
        v_flgappr               tbfasign.flgappr%type;
        v_codcompap             tbfasign.codcompap%type;
        v_codposap              tbfasign.codposap%type;
        v_codempap              tbfasign.codempap%type;
        v_message               tbfasign.message%type;
        v_seqno                 tbfasign.seqno%type;
        v_tmp                   varchar2(10);
	begin
		initial_value(json_str_input);
		json_obj            := json_object_t(json_str_input);
		p_qtydayb           := hcm_util.get_string_t(json_obj,'p_qtydayb');
		p_message           := hcm_util.get_string_t(json_obj,'p_message');
		p_qtydayr           := hcm_util.get_string_t(json_obj,'p_qtydayr');
		p_subject           := hcm_util.get_string_t(json_obj,'p_subject');
		p_typemail          := hcm_util.get_string_t(json_obj,'p_typemail');
		p_status            := hcm_util.get_string_t(json_obj,'p_status');
		p_flgeffec          := hcm_util.get_string_t(json_obj,'p_flgeffec');
        p_syncond           := hcm_util.get_json_t(json_obj,'p_syncond');
        p_code              := hcm_util.get_string_t(p_syncond,'code');
        p_statement         := hcm_util.get_string_t(p_syncond,'statement');
        p_codsend           := hcm_util.get_string_t(json_obj,'p_codsend');
		arr_params          := hcm_util.get_json_t(json_obj,'params');
		arr_assign          := hcm_util.get_json_t(json_obj,'assign');
		arr_report          := hcm_util.get_json_t(json_obj,'report');
        
        for i in 0..arr_params.get_size-1 loop
			obj_row             := json_object_t();
			obj_row             := json_object_t(arr_params.get(to_char(i)));
			p_flgdesc           := hcm_util.get_string_t(obj_row, 'flgdesc');
			p_ffield            := hcm_util.get_string_t(obj_row, 'parameter');
            p_descript          := hcm_util.get_string_t(obj_row, 'paramdesc');
			p_fparam            := hcm_util.get_string_t(obj_row, 'param');
			p_flgDelete         := hcm_util.get_boolean_t(obj_row, 'flgDelete') ;
			p_codtable          := hcm_util.get_string_t(obj_row, 'codtable');
			p_numseq            := hcm_util.get_string_t(obj_row, 'numseq');
            if p_flgDelete then
                begin
                    delete from tbfparam
                     where codcompy = p_codcompy
                       and mailalno = p_mailalno
                       and dteeffec = p_dteeffec
                       and numseq = p_numseq;
                end;
            else
                begin
                    update tbfparam
                       set codtable = p_codtable,
                           fparam = p_fparam,
                           ffield = p_ffield,
                           descript = p_descript,
                           flgdesc = p_flgdesc,
                           coduser = global_v_coduser
                     where codcompy = p_codcompy
                       and mailalno = p_mailalno
                       and dteeffec = p_dteeffec
                       and numseq = p_numseq;
                    if sql%rowcount = 0 then
                        -- find max numseq for running
                        begin
                            select max(numseq)
                              into v_numseq
                              from tbfparam
                             where codcompy = p_codcompy
                               and mailalno = p_mailalno
                               and dteeffec = p_dteeffec;
                        exception when others then
                            v_numseq := 0;
                        end;
                        v_numseq := nvl(v_numseq,0) + 1;
                        insert into tbfparam (codcompy, mailalno,dteeffec,numseq,fparam,ffield,descript,
                                              codtable,flgdesc,coduser,codcreate)
                                      values (p_codcompy, p_mailalno,p_dteeffec,v_numseq,p_fparam,p_ffield,p_descript,
                                              p_codtable,p_flgdesc,global_v_coduser,global_v_coduser);
                    end if;
                end;
            end if;
		end loop;
        
        begin
            select 'x' 
              into v_tmp
              from tbfparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
          group by codtable,ffield,flgdesc 
            having count(*) > 1 ;
        exception when no_data_found then
            v_tmp   := null;
        end;
        
        if v_tmp is not null then
            param_msg_error := get_error_msg_php('HR1503',global_v_lang,get_label_name('HRTRATE1',global_v_lang,'120'));
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            rollback;
            return;
        end if;
        
        merge into tbfparam upd
            using (
              select rowid, row_number() over (order by numseq) rnum 
                from tbfparam
               where codcompy = p_codcompy
                 and mailalno = p_mailalno
                 and dteeffec = p_dteeffec
            ) s
        on (upd.rowid = s.rowid)
        when matched then update set upd.numseq = s.rnum;

        begin
			INSERT INTO tbfalert (codcompy,mailalno,dteeffec,typemail,flgeffec,subject, message,syncond,codsend,qtydayb, qtydayr,statement,codcreate,coduser)
			VALUES (p_codcompy,p_mailalno,p_dteeffec, p_typemail,p_flgeffec, p_subject, p_message,p_code,p_codsend,p_qtydayb, p_qtydayr,p_statement,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
			update tbfalert
			   set typemail = p_typemail,
                   flgeffec = p_flgeffec,
                   subject = p_subject,
                   message = p_message,
                   syncond = p_code,
                   codsend = p_codsend,
                   qtydayb = p_qtydayb,
                   qtydayr = p_qtydayr,
                   statement = p_statement,
                   coduser = global_v_codempid
			 where codcompy = p_codcompy
               and mailalno = p_mailalno
			   and dteeffec = p_dteeffec;
        end;

		if arr_assign is not null then
			for i in 0..arr_assign.get_size-1 loop
				obj_row             := json_object_t();
				obj_row             := hcm_util.get_json_t(arr_assign,to_char(i));
                v_seqno             := hcm_util.get_string_t(obj_row, 'seqno');
                v_flgDelete_assign  := hcm_util.get_boolean_t(obj_row,'flgDelete');
				if v_flgDelete_assign or hcm_util.get_string_t(obj_row, 'flg') = 'delete' then
					begin
						delete tbfasign
						 where codcompy = p_codcompy
                           and mailalno = p_mailalno
						   and dteeffec = p_dteeffec
					   	   and seqno = v_seqno;
					exception when others then
                        null;
					end;
				else
                    v_flgappr   := hcm_util.get_string_t(obj_row,'flgappr');
                    v_codcompap := hcm_util.get_string_t(obj_row,'codcompap');
                    v_codposap  := hcm_util.get_string_t(obj_row,'codposap');
                    v_codempap  := hcm_util.get_string_t(obj_row,'codempap');
                    v_message   := hcm_util.get_string_t(obj_row, 'message');
					begin
						update tbfasign
						   set flgappr = v_flgappr,
                               codcompap = v_codcompap,
                               codposap = v_codposap,
                               codempap = v_codempap,
                               message = v_message,
                               coduser = global_v_coduser
						 where codcompy = p_codcompy
                           and mailalno = p_mailalno
						   and dteeffec = p_dteeffec
                           and seqno = v_seqno;
						if sql%rowcount = 0 then
							insert into tbfasign (codcompy, mailalno, dteeffec, seqno,flgappr,codcompap,codposap,codempap,message,coduser,codcreate)
							values (p_codcompy, p_mailalno, p_dteeffec,
                                    get_seqno(p_codcompy,p_mailalno,p_dteeffec),
                                    v_flgappr,
                                    v_codcompap,
                                    v_codposap,
                                    v_codempap,
                                    v_message,
                                    global_v_coduser,global_v_coduser);
						end if;
					end;
				end if;
			end loop;
		end if;

		if arr_report is not null then
			for i in 0..arr_report.get_size-1 loop
				obj_row     := json_object_t();
				obj_row     := hcm_util.get_json_t(arr_report,to_char(i));
                p_numseq    := hcm_util.get_string_t(obj_row,'numseq');
                p_codtable  := hcm_util.get_string_t(obj_row,'codtable');
                p_pfield    := hcm_util.get_string_t(obj_row,'pfield');
                p_flgdesc_b := hcm_util.get_boolean_t(obj_row,'flgdesc');
                if p_flgdesc_b then
                    p_flgdesc := 'Y';
                else
                    p_flgdesc := 'N';
                end if;
                p_pdesct    := hcm_util.get_string_t(obj_row,'pdesct');
                p_flgDelete := hcm_util.get_boolean_t(obj_row,'flgDelete');

				if hcm_util.get_boolean_t(obj_row,'flgDelete') then
					begin
                        delete tmailrbf
                         where codcompy = p_codcompy
                           and mailalno = p_mailalno
                           and dteeffec = p_dteeffec
                           and numseq = p_numseq;
					exception when others then
                        null;
					end;
				else
					begin
                        update tmailrbf
                           set pfield = p_codtable||'.'||p_pfield,
                               flgdesc = p_flgdesc,
                               pdesct = p_pdesct,
                               coduser = global_v_coduser
                         where codcompy = p_codcompy
                           and mailalno = p_mailalno
                           and dteeffec = p_dteeffec
                           and numseq = p_numseq;
						if sql%rowcount = 0 then
                            begin
                                select max(numseq)
                                  into v_numseq
                                  from tmailrbf
                                 where codcompy = p_codcompy
                                   and mailalno = p_mailalno
                                   and dteeffec = p_dteeffec;
                            exception when others then
                                v_numseq := 0;
                            end;
                            if v_numseq is null then
                                v_numseq := 0;
                            end if;
                            insert into tmailrbf (codcompy, mailalno, dteeffec, pfield,
                                                  pdesct, flgdesc,numseq,coduser,codcreate)
                                          values (p_codcompy, p_mailalno, p_dteeffec, p_codtable||'.'||p_pfield,
                                                  p_pdesct, p_flgdesc, v_numseq + 1, global_v_coduser, global_v_coduser);
						end if;
					end;
				end if;
			end loop;
            
            v_tmp   := null;
            
            begin
                select 'x' 
                  into v_tmp
                  from tmailrbf
                 where codcompy = p_codcompy
                   and mailalno = p_mailalno
                   and dteeffec = p_dteeffec
              group by pfield,flgdesc 
                having count(*) > 1 ;
            exception when no_data_found then
                v_tmp   := null;
            end;
            
            if v_tmp is not null then
                param_msg_error := get_error_msg_php('HR1503',global_v_lang,get_label_name('HRTRATE1',global_v_lang,'80'));
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                rollback;
                return;
            end if;
            
            merge into tmailrbf upd
                using (
                  select rowid, row_number() over (order by numseq) rnum 
                    from tmailrbf
                   where codcompy = p_codcompy
                     and mailalno = p_mailalno
                     and dteeffec = p_dteeffec
                ) s
            on (upd.rowid = s.rowid)
            when matched then update set upd.numseq = s.rnum;
		end if;
        commit;
    	param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
        rollback;
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end saveData;

    procedure post_send_mail (json_str_input in clob, json_str_output out clob) is
		v_number_mail       number := 0;
        json_obj            json_object_t;
        p_typemail		    varchar2(10);
      begin
        initial_value(json_str_input);
        json_obj            := json_object_t(json_str_input);
		p_typemail      := hcm_util.get_string_t(json_obj, 'p_typemail');
        
        begin
          select count(*)
            into v_number_mail
            from tbfalert
           where codcompy = p_codcompy
             and mailalno = p_mailalno
             and dteeffec = p_dteeffec;
        end;
		if v_number_mail > 0 then
            case p_typemail
				when '1' then ALERTMSG_BF.gen_thealcde(p_codcompy,p_mailalno,p_dteeffec,'N');
				when '2' then ALERTMSG_BF.gen_empfollow_heal(p_codcompy,p_mailalno,p_dteeffec,'N');
				when '3' then ALERTMSG_BF.gen_thwccase(p_codcompy,p_mailalno,p_dteeffec,'N');
            end case;
            param_msg_error := get_error_msg_php('HR2046', global_v_lang);
            json_str_output := get_response_message('200', param_msg_error, global_v_lang);
        else
            param_msg_error := get_error_msg_php('HR7522', global_v_lang);
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('444', param_msg_error, global_v_lang);
	end post_send_mail;

end HRBFATE;

/

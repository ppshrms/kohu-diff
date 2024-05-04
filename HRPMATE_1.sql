--------------------------------------------------------
--  DDL for Package Body HRPMATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMATE" is
-- last update: 25/05/2018 12:23
  procedure initial_value(json_str in clob) is
		json_obj		    json_object_t;
	begin
		json_obj            := json_object_t(json_str);
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

        p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
		p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'dd/mm/yyyy');
		p_mailalno          := hcm_util.get_string_t(json_obj, 'p_mailalno');
		p_date              := hcm_util.get_string_t(json_obj,'p_date');
		p_message           := hcm_util.get_string_t(json_obj,'p_message');
		p_subject           := hcm_util.get_string_t(json_obj,'p_subject');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end;

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
		obj_result		json_object_t;
		v_rcnt			number := 0;
        v_data			varchar2(1) := 'N';
        flgsecure       boolean;

		cursor c1 is
            select codcompy,mailalno,dteeffec,subject,message,flgeffec
              from tpmalert
             where codcompy = p_codcompy
          order by mailalno, dteeffec desc ;
	begin
		obj_row     := json_object_t();
		obj_data    := json_object_t();
        flgsecure   := secur_main.secur7(p_codcompy, global_v_coduser);

        if not flgsecure and p_codcompy != 'STD' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        else
            for r1 in c1 loop
                v_rcnt      := v_rcnt+1;
                obj_data    := json_object_t();
                v_data      := 'Y';
                obj_data.put('coderror', '200');
                obj_data.put('rcnt', to_char(v_rcnt));
                obj_data.put('codcompy', r1.codcompy);
                obj_data.put('desc_codcompy', get_tcompny_name(r1.codcompy,global_v_lang));
                obj_data.put('mailalno', r1.mailalno);
                obj_data.put('subject', r1.subject );
                obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
                obj_data.put('desc_flgeffec', get_tlistval_name('FLGAPPRS',r1.flgeffec,global_v_lang));
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;
        end if;

        if param_msg_error is null then
			json_str_output := obj_row.to_clob;
		else
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure getDestroy (json_str_input in clob, json_str_output out clob) is
		obj_row			json_object_t;
		obj_data		json_object_t;
		v_rcnt			number;
        p_codcompy      tpmalert.codcompy%type;
		p_mailalno		tpmalert.mailalno%type;
		p_dteeffec		tpmalert.dteeffec%type;
        p_typemail      tpmalert.typemail%type;
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
				delete from tpmalert where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tpmparam where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tpmasign where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;
				delete from tmailrpm where codcompy = p_codcompy and mailalno = p_mailalno and dteeffec = p_dteeffec;

                begin
                    select typemail 
                      into p_typemail
                      from tpmalert 
                     where codcompy = p_codcompy 
                       and mailalno = p_mailalno 
                       and dteeffec = p_dteeffec;
                exception when others then
                    p_typemail := null;
                end;   

                if p_typemail = '10' then
                    delete from tpmimagebd where codcompy = p_codcompy;
                elsif p_typemail = '50' then
                    delete from tpmpublic where codcompy = p_codcompy;
                end if;
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
            from tpmasign
           where codcompy = v_codcompy
             and mailalno = v_mailalno
             and dteeffec = v_dteeffec;
        end;
        return v_number;
  end;

	procedure saveData (json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		        json_object_t;
		json_str		        json_object_t;
		obj_rows		        json_object_t;
		p_qtydayb		        varchar2(50 char);
		p_message		        clob;
		p_qtydayr		        varchar2(50 char);
		p_subject		        varchar2(1250 char);
		p_typemail		        varchar2(50 char);
		p_status		        varchar2(50 char);
		p_flgeffec		        varchar2(1 char);
        p_syncond               json_object_t;
        p_codsend               tpmalert.codsend%type;
        p_code                  tpmalert.syncond%type;
        p_statement             tpmalert.statement%type;
		v_rcnt			        number := 0;
		arr_params		        json_object_t;
		arr_assign	            json_object_t;
        arr_report              json_object_t;
        arr_calendar            json_object_t;
        arr_birthdaycard        json_object_t;
		obj_row_param		    json_object_t;
		v_sysdate		        varchar2(50 char);
		p_ffield		        tpmparam.ffield%type;
        p_descript              tpmparam.descript%type;
		p_codtable		        tpmparam.codtable%type;
		p_fparam		        tpmparam.fparam%type;
		p_flgdesc	            tpmparam.flgdesc%type;
		p_flgdesc_b	            boolean;
		p_numseq		        tpmparam.numseq%type;
		v_numseq		        number := 0;
		p_flgDelete		        boolean;
        v_flgDelete_assign      boolean;

        p_pfield                tmailrpm.pfield%type;
        p_pdesct                tmailrpm.pdesct%type;
        v_flgappr               tpmasign.flgappr%type;
        v_codcompap             tpmasign.codcompap%type;
        v_codposap              tpmasign.codposap%type;
        v_codempap              tpmasign.codempap%type;
        v_message               tpmasign.message%type;
        v_seqno                 tpmasign.seqno%type;
        p_namimage              tpmpublic.namimage%type;
        p_flg                   varchar2(500);
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
        arr_calendar        := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'calendar'),'rows');
        arr_birthdaycard    := hcm_util.get_json_t(json_obj,'birthdaycard');

		for i in 0..arr_params.get_size-1 loop
			v_rcnt              := v_rcnt+1;
			obj_row             := json_object_t();
			obj_row             := hcm_util.get_json_t(arr_params,to_char(i));
			p_flgdesc           := hcm_util.get_string_t(obj_row, 'flgdesc');
			p_ffield            := hcm_util.get_string_t(obj_row, 'parameter');
            p_descript          := hcm_util.get_string_t(obj_row, 'paramdesc');
			p_fparam            := hcm_util.get_string_t(obj_row, 'param');
			p_flgDelete         := hcm_util.get_boolean_t(obj_row, 'flgDelete') ;
			p_codtable          := hcm_util.get_string_t(obj_row, 'codtable');
			p_numseq            := hcm_util.get_string_t(obj_row, 'numseq');
            if p_flgDelete then
                begin
                    delete from tpmparam
                     where codcompy = p_codcompy
                       and mailalno = p_mailalno
                       and dteeffec = p_dteeffec
                       and numseq = p_numseq;
                end;
            else
                begin
                    update tpmparam
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
                              from tpmparam
                             where codcompy = p_codcompy
                               and mailalno = p_mailalno
                               and dteeffec = p_dteeffec;
                        exception when others then
                            v_numseq := 0;
                        end;
                        v_numseq := nvl(v_numseq,0) + 1;
                        insert into tpmparam (codcompy, mailalno,dteeffec,numseq,fparam,ffield,descript,
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
              from tpmparam
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

        merge into tpmparam upd
            using (
              select rowid, row_number() over (order by numseq) rnum 
                from tpmparam
               where codcompy = p_codcompy
                 and mailalno = p_mailalno
                 and dteeffec = p_dteeffec
            ) s
        on (upd.rowid = s.rowid)
        when matched then update set upd.numseq = s.rnum;

        begin
			INSERT INTO tpmalert (codcompy,mailalno,dteeffec,typemail,flgeffec,subject, message,syncond,codsend,qtydayb, qtydayr,statement,codcreate,coduser)
			VALUES (p_codcompy,p_mailalno,p_dteeffec, p_typemail,p_flgeffec, p_subject, p_message,p_code,p_codsend,p_qtydayb, p_qtydayr,p_statement,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
			update tpmalert
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

        if arr_calendar is not null then
            for i in 0..arr_calendar.get_size-1 loop
                obj_row             := json_object_t();
				obj_row             := hcm_util.get_json_t(arr_calendar,to_char(i));
                p_date              := hcm_util.get_string_t(obj_row,'dtedate');
                p_message           := hcm_util.get_string_t(obj_row,'message');
                p_subject           := hcm_util.get_string_t(obj_row,'subject');
                p_namimage          := hcm_util.get_string_t(obj_row,'namimage');
--                p_dteeffec          := hcm_util.get_string_t(obj_row,'dteeffec');
--                p_mailalno          := hcm_util.get_string_t(obj_row,'mailalno');
                begin
                    update tpmpublic
                       set subject = p_subject,
                           message = p_message,
                           namimage = p_namimage,
                           coduser = global_v_coduser
                     where codcompy = p_codcompy
                       and dtepublic = to_date(p_date,'dd/mm/yyyy') ;
                    if sql%rowcount = 0 then
                        insert into tpmpublic (codcompy, dtepublic,subject,message,namimage,coduser,codcreate)
                        values (p_codcompy, to_date(p_date,'dd/mm/yyyy'), p_subject,p_message,p_namimage,global_v_coduser,global_v_coduser);
                    end if;
                end;                
            end loop;
        end if;

		if arr_assign is not null then
			for i in 0..arr_assign.get_size-1 loop
				obj_row             := json_object_t();
				obj_row             := hcm_util.get_json_t(arr_assign,to_char(i));
                v_seqno             := hcm_util.get_string_t(obj_row, 'seqno');
                v_flgDelete_assign  := hcm_util.get_boolean_t(obj_row,'flgDelete');
				if v_flgDelete_assign or hcm_util.get_string_t(obj_row, 'flg') = 'delete' then
					begin
						delete tpmasign
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
						update tpmasign
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
							insert into tpmasign (codcompy, mailalno, dteeffec, seqno,flgappr,codcompap,codposap,codempap,message,coduser,codcreate)
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
                        delete tmailrpm
                         where codcompy = p_codcompy
                           and mailalno = p_mailalno
                           and dteeffec = p_dteeffec
                           and numseq = p_numseq;
					exception when others then
                        null;
					end;
				else
					begin
                        update tmailrpm
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
                                  from tmailrpm
                                 where codcompy = p_codcompy
                                   and mailalno = p_mailalno
                                   and dteeffec = p_dteeffec;
                            exception when others then
                                v_numseq := 0;
                            end;
                            if v_numseq is null then
                                v_numseq := 0;
                            end if;
                            insert into tmailrpm (codcompy, mailalno, dteeffec, pfield,
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
                  from tmailrpm
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

            merge into tmailrpm upd
                using (
                  select rowid, row_number() over (order by numseq) rnum 
                    from tmailrpm
                   where codcompy = p_codcompy
                     and mailalno = p_mailalno
                     and dteeffec = p_dteeffec
                ) s
            on (upd.rowid = s.rowid)
            when matched then update set upd.numseq = s.rnum;
		end if;

        if arr_birthdaycard is not null and p_typemail = '10' then
            for i in 0..arr_birthdaycard.get_size-1 loop
                obj_row     := json_object_t();
                obj_row     := hcm_util.get_json_t(arr_birthdaycard,to_char(i));
                p_date      := hcm_util.get_string_t(obj_row,'dtedate');
                p_flg       := hcm_util.get_string_t(obj_row,'flg');
                p_numseq    := hcm_util.get_number_t(obj_row,'numseq');
                p_namimage  := hcm_util.get_string_t(obj_row,'namimage');

                if p_flg = 'delete' then
                    begin
                        delete tpmimagebd 
                         where codcompy = p_codcompy
                           and numseq = p_numseq;
                    exception when others then
                        null;
                    end;
                else
                    begin
                        select max(numseq)
                          into v_numseq 
                          from tpmimagebd
                         where codcompy = p_codcompy;
                    exception when others then
                        p_numseq := 0;
                    end;
                    v_numseq := nvl(v_numseq,0) + 1;
                    begin

                        insert into tpmimagebd (codcompy,numseq,namimage,dtecreate,
                                                codcreate,dteupd,coduser) 
                        values(p_codcompy,v_numseq,p_namimage,sysdate,
                               global_v_coduser,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        update tpmimagebd
                           set namimage = p_namimage
                         where codcompy = p_codcompy
                           and numseq = p_numseq;
                    end;
                end if;
            end loop;
        end if;
		param_msg_error := get_error_msg_php('HR2401',global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end saveData;

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
              from tpmparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
          order by fparam;
	begin
		obj_row := json_object_t();
		v_rcnt  := 0;

        for r2 in c_params loop
            v_rcnt := v_rcnt + 1;
            begin
                select decode(global_v_lang,'101',descole,
                                            '102',descolt,
                                            '103',descol3,
                                            '104',descol4,
                                            '105',descol5,descole)
                  into v_desc
                  from tcoldesc
                 where codtable = r2.codtable
                   and codcolmn = r2.ffield;
            exception when others then
                v_desc := '';
            end;
            obj_data := json_object_t();
            obj_data.put('numseq', r2.numseq);
            obj_data.put('param', r2.fparam);
--            obj_data.put('paramdesc', v_desc);DESCRIPT
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
              from tpmasign
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

	procedure getDetail (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		genDetail(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end getDetail;

	procedure genDetail (json_str_output out clob) is
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		flg_data		boolean := false;
        obj_syncond     json_object_t;
        obj_params      json_object_t;
        obj_params_row	json_object_t;
        obj_assign      json_object_t;
        obj_assign_row	json_object_t;
        obj_mailrpm     json_object_t;
        obj_mailrpm_row	json_object_t;
        v_row			number := 0;
        v_desc			varchar2(200 char);
        v_message_display tpmalert.message%type;

		cursor c1 is
            select codcompy, mailalno, dteeffec, codsend, qtydayb, message,
                   qtydayr, subject, typemail, flgeffec,
                   syncond, statement, get_logical_desc(statement) as description
              from tpmalert
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec;

		cursor c_params is
            select *
              from tpmparam
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
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
            obj_mailrpm_row := json_object_t();
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

	procedure post_delete_holiday (json_str_input in clob, json_str_output out clob) as
		json_str		    json_object_t;
		param_json		    json_object_t;
		param_json_row		json_object_t;

	begin
		initial_value(json_str_input);
		begin
			delete tpmpublic
			 where codcompy = p_codcompy
               and dtepublic = to_date(p_date,'dd/mm/yyyy');
		end;
		param_msg_error := get_error_msg_php('HR2425', global_v_lang);
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_delete_report_format (json_str_input in clob, json_str_output out clob) as
		json_str		    json_object_t;
		param_json		    json_object_t;
		param_json_row		json_object_t;
		v_numseq		    number := 0;
		v_flag			    varchar2(10 char);
        p_mailalno          tmailrpm.mailalno%type;
        p_flgDelete         boolean;
        p_flgdesc           tmailrpm.flgdesc%type;
        p_numseq            tmailrpm.numseq%type;
        p_pfield            tmailrpm.pfield%type;
        p_pdesct            tmailrpm.pdesct%type;
	begin
		initial_value(json_str_input);
		json_str    := json_object_t(json_str_input);
		param_json  := json_object_t(hcm_util.get_string_t(json_str, 'dataRows'));
		for i in 0..param_json.get_size-1 loop
			param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
            p_flgDelete     := hcm_util.get_boolean_t(param_json_row, 'flgDelete');
            p_flgdesc       := hcm_util.get_string_t(param_json_row, 'flgdesc');
            p_mailalno      := hcm_util.get_string_t(param_json_row, 'mailalno');
            p_numseq        := hcm_util.get_string_t(param_json_row,'numseq');

			if p_flgDelete then
				begin
					delete tmailrpm
					 where codcompy = p_codcompy
                       and mailalno = p_mailalno
					   and dteeffec = p_dteeffec
					   and numseq = p_numseq;
				exception when others then
                    null;
				end;
			else
				begin
					update TMAILRPM
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
                              from tmailrpm
                             where codcompy = p_codcompy
                               and mailalno = p_mailalno
                               and dteeffec = p_dteeffec;
                        exception when others then
                            v_numseq := 1;
                        end;
                        if v_numseq is null then
                            v_numseq := 1;
                        end if;

						insert into tmailrpm (codcompy, mailalno, dteeffec, pfield,
                                              pdesct, flgdesc,numseq,coduser,codcreate)
						              values (p_codcompy, p_mailalno, p_dteeffec, p_pfield,
                                              p_pdesct, v_flag, v_numseq + 1, global_v_coduser, global_v_coduser);
					end if;
                exception when others then
                    null;
				end;
			end if;
		end loop;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure post_save_new_holiday (json_str_input in clob, json_str_output out clob) is
		json_obj		json_object_t;
		obj_row			json_object_t;
		obj_data		json_object_t;
		param_json		json_object_t;
		param_json_table	json_object_t;
		param_json_row		json_object_t;
		arr_params		json_object_t;
        p_namimage      tpmpublic.namimage%type;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		arr_params := hcm_util.get_json_t(json_obj,'params');
		for i in 0..arr_params.get_size-1 loop
			obj_row     := json_object_t();
			obj_row     := hcm_util.get_json_t(arr_params,to_char(i));
			p_date      := hcm_util.get_string_t(obj_row,'dtedate');
			p_message   := hcm_util.get_string_t(obj_row,'message');
			p_subject   := hcm_util.get_string_t(obj_row,'subject');
			p_dteeffec  := hcm_util.get_string_t(obj_row,'dteeffec');
			p_mailalno  := hcm_util.get_string_t(obj_row,'mailalno');
            p_namimage  := hcm_util.get_string_t(obj_row,'namimage');
			begin
				update tpmpublic
				   set subject = p_subject,
                       message = p_message,
                       coduser = global_v_coduser,
                       namimage = p_namimage
				 where codcompy = p_codcompy
				   and dtepublic = to_date(p_date,'dd/mm/yyyy') ;
				if sql%rowcount = 0 then
					insert into tpmpublic (codcompy, dtepublic,subject,message,coduser,codcreate,namimage)
					values (p_codcompy, to_date(p_date,'dd/mm/yyyy'), p_subject,p_message,global_v_coduser,global_v_coduser,p_namimage);
				end if;
			end;
		end loop;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_holiday (json_str_input in clob, json_str_output out clob) is
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
              from tpmpublic
             where codcompy = p_codcompy;
	begin
		initial_value(json_str_input);
		obj_row := json_object_t();
		obj_data := json_object_t();
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			is_found_rec := true;
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt));
			obj_data.put('codcompy', r1.codcompy);
			obj_data.put('dtepublic', to_char(r1.DTEPUBLIC,'dd/mm/yyyy'));
			obj_data.put('dtedate', to_char(r1.DTEPUBLIC,'dd/mm/yyyy'));
			obj_data.put('subject', r1.SUBJECT);
			obj_data.put('typwork', 'S');
			obj_data.put('desholdy', r1.SUBJECT);
			obj_data.put('message', r1.MESSAGE);
			obj_data.put('filename', r1.FILENAME);
			obj_data.put('dteupd', r1.DTEUPD);
			obj_data.put('coduser', r1.CODUSER);
			obj_data.put('namimage', r1.namimage);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

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
              from tmailrpm
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
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_list_detail_param(json_str_input in clob, json_str_output out clob) as obj_row json;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj    := json_object_t(json_str_input);
		p_typsubj   := hcm_util.get_string_t(json_obj, 'p_typsubj');

		if p_typsubj is not null then
			gen_list_detail_param(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_list_detail_param(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		name_tcodec		varchar2(200 char);
		name_tcenter	varchar2(200 char);
		name_tpostn		varchar2(200 char);

		cursor list_codtable is
            select *
              from tfmtable
             where codapp = 'HRPMATE'
               AND numseq = p_typsubj
             order by codtable desc;
	begin
		obj_row := json_object_t();

		obj_row.put('0','Please select');
		obj_row.put('coderror', '200');
		for r1 in list_codtable loop
			obj_row.put('coderror', '200');
			obj_row.put(r1.codtable, r1.codtable);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

	procedure get_list_detail_table(json_str_input in clob, json_str_output out clob) as obj_row json;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
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

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

	procedure post_send_mail (json_str_input in clob, json_str_output out clob) is
		v_number_mail		number := 0;
		json_obj		    json_object_t;
		p_typemail		    varchar2(500);
	begin
		initial_value(json_str_input);
		json_obj        := json_object_t(json_str_input);
		p_typemail      := hcm_util.get_string_t(json_obj, 'p_typemail');
		begin
			select count(*)
			  into v_number_mail
			  from tpmalert
			 where mailalno = p_mailalno
               and codcompy = p_codcompy;
		end;
		if v_number_mail > 0 then
			case p_typemail
				when '10' then ALERTMSG_PM.gen_birthday(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '20' then ALERTMSG_PM.gen_probation(p_codcompy,'N',p_mailalno,p_dteeffec);
                when '22' then ALERTMSG_PM.gen_probationn(p_codcompy,'N',p_mailalno,p_dteeffec);
                when '24' then ALERTMSG_PM.gen_probationp(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '30' then ALERTMSG_PM.gen_ttmovemt(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '40' then ALERTMSG_PM.gen_prbcodpos(p_codcompy,'N',p_mailalno,p_dteeffec);
                when '42' then ALERTMSG_PM.gen_prbcodposn(p_codcompy,'N',p_mailalno,p_dteeffec);
                when '44' then ALERTMSG_PM.gen_prbcodposp(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '50' then ALERTMSG_PM.gen_public_holiday(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '60' then ALERTMSG_PM.gen_resign(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '70' then ALERTMSG_PM.gen_retire(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '80' then ALERTMSG_PM.gen_newemp(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '90' then ALERTMSG_PM.gen_exprworkpmit(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '100' then ALERTMSG_PM.gen_exprvisa(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '110' then ALERTMSG_PM.gen_exprdoc(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '120' then ALERTMSG_PM.gen_congratpos(p_codcompy,'N',p_mailalno,p_dteeffec);
				when '130' then ALERTMSG_PM.gen_congratnewemp(p_codcompy,'N',p_mailalno,p_dteeffec);
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

	procedure get_define_reciver(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
		initial_value(json_str_input);
		json_obj := json_object_t(json_str_input);
		gen_define_reciver(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_define_reciver(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;

		cursor list_codtable is
            select *
              from tpmasign
             where codcompy = p_codcompy
               and mailalno = p_mailalno
               and dteeffec = p_dteeffec
          order by seqno;
	begin
		obj_data    := json_object_t();
		obj_row     := json_object_t();
		v_rcnt      := 0;
		for r1 in list_codtable loop
			v_rcnt      := v_rcnt+1;
			obj_data    := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('seqno', r1.seqno);
			obj_data.put('flgappr', r1.flgappr);
			obj_data.put('codcompap', r1.codcompap);
			obj_data.put('codposap', r1.codposap);
			obj_data.put('codempap', r1.codempap);
			obj_data.put('message', r1.message);
			obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;
		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

    procedure post_test_syntax (json_str_input in clob, json_str_output out clob) is
		json_str		json_object_t;
		param_json		json_object_t;
		cur SYS_REFCURSOR;
		v_query			VARCHAR2(1000);
		v_num			number;
	begin
		json_str    := json_object_t(json_str_input);
		param_json  := json_object_t(hcm_util.get_string_t(json_str, 'json_input_str'));
		p_syncond   := hcm_util.get_string_t(param_json, 'syncond');
		p_table     := hcm_util.get_string_t(param_json, 'table');
		v_query     := 'select *' || ' from ' ||p_table||' where '||p_syncond;

		begin
			OPEN cur FOR v_query;
		exception when others then
			param_msg_error := get_error_msg_php('HR2810',global_v_lang);
		end;
		if param_msg_error is null then
			param_msg_error := get_error_msg_php('HR2820',global_v_lang);
		end if;
		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure getBirthdayCard (json_str_input in clob, json_str_output out clob) is
	begin
		initial_value(json_str_input);
		genBirthdayCard(json_str_output);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end getBirthdayCard;

	procedure genBirthdayCard (json_str_output out clob) is
		v_rcnt			number;
		obj_row			json_object_t;
		obj_data		json_object_t;
		flg_data		boolean := true;
        v_row			number := 0;
        v_desc			varchar2(200 char);

       cursor c_tpmimagebd is
            select *
              from tpmimagebd
             where codcompy = p_codcompy
          order by numseq;

	begin
		obj_row := json_object_t();
		v_rcnt  := 0;
        for r1 in c_tpmimagebd loop
            v_row       := v_row + 1;
            obj_data    := json_object_t();
            obj_data.put('numseq', r1.numseq);
            obj_data.put('namimage', r1.namimage);
            obj_row.put(v_row - 1, obj_data);
        end loop;

		json_str_output := obj_row.to_clob;
	end genBirthdayCard;

end HRPMATE;

/

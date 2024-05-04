--------------------------------------------------------
--  DDL for Package Body HRPM88X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM88X" is

  procedure initial_value (json_str in clob) is
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str);

		--global
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
		p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
		p_startdate         := hcm_util.get_string_t(json_obj,'p_strdate');
		p_enddate           := hcm_util.get_string_t(json_obj,'p_enddate');
		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

	end initial_value;

	procedure vadidate_variable_getindex(json_str_input in clob) as
		chk_bool		boolean;
		v_codcomp		varchar2(50);
	BEGIN
        begin
            select codcomp
              into v_codcomp
              from temploy1
             where codempid = p_codempid_query;
        exception when no_data_found then
            v_codcomp := null;
        end;
		if (p_codempid_query is null or p_codempid_query = ' ') then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'P_CODEMPID');
			return ;
		end if;
		if(to_number(p_startdate) > to_number(p_enddate)) then
			param_msg_error := get_error_msg_php('HR2027',global_v_lang, '');
			return ;
		end if;
		chk_bool := secur_main.secur3(v_codcomp,p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
		if(chk_bool = false ) then
			param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
			return;
		end if;

	END vadidate_variable_getindex;

	procedure getDetail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;

	begin
		json_obj := json_object_t(json_str_input);
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			genDetail(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDetail(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
        v_insertNumdeq		number := 0;
		v_data_THISPUN			varchar2(1) := 'N';
        v_data_THISMIST			varchar2(1) := 'N';
		v_count_thispund	number;
        v_thispund	varchar2(100 char);
		v_thispund_CODPAY	varchar2(100 char);
		v_thispund_NUMPRDST	varchar2(100 char);
		v_thispund_NUMPRDEN	varchar2(100 char);
		v_thispund_AMTTOTDED	varchar2(100 char);
        v_ocodempid varchar2(200 char):=GET_OCODEMPID(P_CODEMPID);
		cursor c1 is select a.DTEMISTK,a.NUMHMREF,a.CODEMPID,a.DESMIST1,a.CODMIST, b.DTESTART, b.DTEEND, b.FLGEXEMPT, b.TYPPUN,nvl(b.CODEXEMP,'-') as CODEXEMP, b.FLGBLIST,a.DTEEFFEC,nvl(b.codpunsh,'no') as codpunsh
		from thismist a
		LEFT OUTER JOIN thispun b on a.codempid=b.codempid and a.DTEEFFEC=b.DTEEFFEC
		where (a.codempid = P_CODEMPID or
               v_ocodempid like '[%'||a.codempid||'%]' )
        and TO_NUMBER(to_char(a.DTEEFFEC,'YYYY')) BETWEEN to_number(STARTDATE) AND to_number(ENDDATE)
		order by a.DTEEFFEC desc;

        cursor c2 is select a.DTEMISTK,a.NUMHMREF,a.DTEEFFEC,a.DESMIST1,a.CODMIST,get_tcodec_name('TCODMIST',a.CODMIST,global_v_lang) as TCODMIST
        from thismist a
        LEFT OUTER JOIN thispun b on a.codempid=b.codempid and a.DTEEFFEC=b.DTEEFFEC
        where (a.codempid = P_CODEMPID or
               v_ocodempid like '[%'||a.codempid||'%]' )
        and TO_NUMBER(to_char(a.DTEEFFEC,'YYYY')) BETWEEN to_number(STARTDATE) AND to_number(ENDDATE)
        and b.codpunsh is not null
        group by a.DTEMISTK,a.NUMHMREF,a.DTEEFFEC,a.DESMIST1,a.CODMIST
        order by a.DTEEFFEC desc;
	begin
		obj_row := json_object_t();
		obj_data := json_object_t();
        numYearReport := HCM_APPSETTINGS.get_additional_year();
		for r1 in c1 loop
      v_data_THISMIST := 'Y';
			v_rcnt := v_rcnt+1;
      v_insertNumdeq := v_insertNumdeq+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
			obj_data.put('rcnt', to_char(v_rcnt - 1));
			obj_data.put('dtemistk', r1.DTEMISTK );
      obj_data.put('numhmref', r1.NUMHMREF );
			obj_data.put('CODMIST', r1.CODMIST );
			obj_data.put('CODMISTText', get_tcodec_name('TCODMIST',r1.CODMIST,global_v_lang) );
      obj_data.put('DTEEFFEC',to_char(r1.DTEEFFEC,'DD/MM/YYYY'));
      obj_data.put('DESMIST1', r1.DESMIST1 );
			obj_data.put('DTESTART',to_char(r1.DTESTART,'DD/MM/YYYY'));
			obj_data.put('DTEEND',to_char(r1.DTEEND,'DD/MM/YYYY'));
			obj_data.put('FLGEXEMPT', get_tlistval_name('TFLGBLST',r1.FLGEXEMPT,global_v_lang) );
			obj_data.put('TYPPUN', get_tlistval_name('NAMTPUN',r1.TYPPUN,global_v_lang) );
			if r1.FLGBLIST = 'Y' then
				obj_data.put('FLGBLIST', get_label_name('HRPM88X4',global_v_lang,'0') );
			else
				obj_data.put('FLGBLIST', get_label_name('HRPM88X4',global_v_lang,'1') );
			end if;

			obj_data.put('CODEXEMP', r1.CODEXEMP ||' - ' || get_tcodec_name('TCODEXEM',r1.CODEXEMP,global_v_lang) );
			obj_data.put('codpunsh', r1.codpunsh );
			obj_data.put('codpunshtext', get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang));
      begin
          select count(*) into v_count_thispund
          from thispund
          where DTEEFFEC = r1.DTEEFFEC AND CODEMPID = r1.CODEMPID and codpunsh = r1.codpunsh;
      end;
      v_thispund := r1.codpunsh;
			if v_count_thispund = 0 then
				obj_data.put('CODPAY', '-' );
				obj_data.put('NUMPRDST', '-' );
				obj_data.put('NUMPRDEN', '-' );
				obj_data.put('AMTTOTDED', '-' );
			else
                begin
                    select
                    nvl(CODPAY,'-'),
                    to_char(NUMPRDST)||'/'||get_tlistval_name('NAMMTHFUL',DTEMTHST, global_v_lang)||'/'||to_char(numYearReport+DTEYEARST)
                    ,to_char(NUMPRDEN)||'/'|| get_tlistval_name('NAMMTHFUL',DTEMTHEN, global_v_lang)||'/'||to_char(numYearReport+DTEYEAREN)
                    ,nvl(stddec(AMTTOTDED, p_codempid, global_v_chken),'-')
                    into v_thispund_CODPAY,v_thispund_NUMPRDST,v_thispund_NUMPRDEN,v_thispund_AMTTOTDED
                    from thispund
                    where DTEEFFEC = r1.DTEEFFEC AND CODEMPID = r1.CODEMPID and codpunsh = r1.codpunsh;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                null;
                end;
				obj_data.put('CODPAY', v_thispund_CODPAY||' - '||get_tinexinf_name(v_thispund_CODPAY,global_v_lang));
				obj_data.put('NUMPRDST', v_thispund_NUMPRDST );
				obj_data.put('NUMPRDEN', v_thispund_NUMPRDEN );

				obj_data.put('AMTTOTDED',to_char(v_thispund_AMTTOTDED,'fm999,999,999,990.00'));
			end if;
            obj_data.put('pinCollapse', false );
			obj_data.put('flgCollapse', true );
            if r1.codpunsh != 'no'  then
                v_data_THISPUN := 'Y';
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
		end loop;

        if v_data_THISMIST = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISMIST');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		else if v_data_THISPUN = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISPUN');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		else
			json_str_output := obj_row.to_clob;
		end if;
        end if;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure getIndex(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
		json_obj		json_object_t;
	begin
		json_obj := json_object_t(json_str_input);
		initial_value(json_str_input);
		vadidate_variable_getindex(json_str_input);
		if param_msg_error is null then
			genIndex(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genIndex(json_str_output out clob)as
		obj_data		        json_object_t;
		obj_data_child		    json_object_t;
		obj_row			        json_object_t;
		obj_result		        json_object_t;
		v_rcnt			        number := 0;
		v_rcnt_child			number := 0;
        v_insertNumdeq		    number := 0;
		v_data_THISPUN			varchar2(1) := 'N';
        v_data_THISMIST			varchar2(1) := 'N';
		v_count_thispund	    number;
        v_thispund	            varchar2(100 char);
		v_thispund_CODPAY	    varchar2(100 char);
		v_thispund_NUMPRDST	    varchar2(100 char);
		v_thispund_NUMPRDEN	    varchar2(100 char);
		v_thispund_AMTTOTDED	varchar2(100 char);
        v_ocodempid             varchar2(200 char):= get_ocodempid(p_codempid_query);
		obj_subDetail           json_object_t;
        obj_subDetail_row       json_object_t;

        v_dteeffec              thismist.dteeffec%type;
        v_codempid              thismist.codempid%type;

        cursor c1 is
            select a.dteeffec,a.dtemistk,a.numhmref,
                   a.codempid,a.desmist1,a.codmist
              from thismist a
             where (a.codempid = p_codempid_query
                    or v_ocodempid like '[%'||a.codempid||'%]' )
               and to_number(to_char(a.dteeffec,'YYYY')) between to_number(p_startdate) and to_number(p_enddate)
		order by a.dteeffec desc;

        cursor c2 is
            select *
              from thispun
             where codempid = v_codempid
               and dteeffec = v_dteeffec
         order by codpunsh,numseq;--dteeffec,numseq,codpunsh;

	begin
		obj_row             := json_object_t();
		obj_data            := json_object_t();
        obj_subDetail       := json_object_t();

        numYearReport       := HCM_APPSETTINGS.get_additional_year();
		for r1 in c1 loop
            v_dteeffec          := r1.dteeffec;
            v_codempid          := r1.codempid;
            v_data_THISMIST     := 'Y';
			v_rcnt              := v_rcnt+1;
            v_insertNumdeq      := v_insertNumdeq+1;
			obj_data            := json_object_t();
			obj_data.put('coderror', '200');
            obj_data.put('codmist', r1.codmist);
            obj_data.put('codmisttext', get_tcodec_name('TCODMIST',r1.codmist,global_v_lang));
            obj_data.put('desmist1', r1.desmist1);
            obj_data.put('dtemistk', to_char(r1.dtemistk,'DD/MM/YYYY'));
            obj_data.put('numhmref', r1.numhmref);
            obj_data.put('dteeffec', to_char(r1.dteeffec,'DD/MM/YYYY'));

            if v_rcnt = 1 then
                obj_data.put('flgCollapse', false);
            else
                obj_data.put('flgCollapse', true);
            end if;

            obj_data.put('pinCollapse', false);
            obj_data.put('rcnt', to_char(v_rcnt - 1));
            v_rcnt_child        := 0;
            obj_subDetail_row   := json_object_t();
            for r2 in c2 loop
                v_rcnt_child        := v_rcnt_child+1;
                obj_data_child      := json_object_t();
                obj_data_child.put('coderror', '200');
                obj_data_child.put('codpunsh', r2.codpunsh);
                obj_data_child.put('codpunshtext', get_tcodec_name('TCODPUNH',r2.codpunsh,global_v_lang));
                obj_data_child.put('typpun', get_tlistval_name('NAMTPUN',r2.typpun,global_v_lang));
                obj_data_child.put('dtestart', nvl(to_char(r2.dtestart,'DD/MM/YYYY'),'-'));
                obj_data_child.put('dteend', nvl(to_char(r2.dteend,'DD/MM/YYYY'),'-'));
                obj_data_child.put('flgexempt', get_tlistval_name('TFLGBLST',r2.flgexempt,global_v_lang));
                obj_data_child.put('codexemp', r2.codexemp ||' - ' || get_tcodec_name('TCODEXEM',r2.codexemp,global_v_lang));
                obj_data_child.put('flgblist', get_tlistval_name('TFLGBLST',r2.flgblist,global_v_lang));

                begin
                    select count(*)
                      into v_count_thispund
                      from thispund
                     where dteeffec = r2.dteeffec
                       and codempid = r2.codempid
                       and codpunsh = r2.codpunsh;
                end;

                if v_count_thispund = 0 then
                    obj_data_child.put('codpay', '-');
                    obj_data_child.put('numprden', '-');
                    obj_data_child.put('numprdst', '-');
                    obj_data_child.put('amttotded', '-');
                else
                    begin
                        select nvl(CODPAY,'-'),
                               to_char(numprdst)||'/'||get_tlistval_name('NAMMTHFUL',dtemthst, global_v_lang)||'/'||to_char(numYearReport+dteyearst),
                               to_char(numprden)||'/'|| get_tlistval_name('NAMMTHFUL',dtemthen, global_v_lang)||'/'||to_char(numYearReport+dteyearen),
                               nvl(stddec(amttotded, v_codempid, global_v_chken),'-')
                          into v_thispund_codpay,v_thispund_numprdst,v_thispund_numprden,v_thispund_amttotded
                          from thispund
                         where dteeffec = r2.dteeffec
                           AND codempid = r2.codempid
                           and codpunsh = r2.codpunsh;
                    exception when no_data_found then
                        null;
                    end;
                    obj_data_child.put('codpay', v_thispund_codpay||' - '||get_tinexinf_name(v_thispund_codpay,global_v_lang));
                    obj_data_child.put('numprden', v_thispund_numprden);
                    obj_data_child.put('numprdst', v_thispund_numprdst);
                    obj_data_child.put('amttotded', to_char(v_thispund_amttotded,'fm999,999,999,990.00'));
                end if;

                obj_subDetail_row.put(to_char(v_rcnt_child-1),obj_data_child);
            end loop;

            obj_subDetail.put('rows', obj_subDetail_row);
            obj_data.put('subDetail', obj_subDetail);

            obj_row.put(to_char(v_rcnt-1),obj_data);
		end loop;

        if v_data_THISMIST = 'N' then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISMIST');
			json_str_output := get_response_message('400',param_msg_error,global_v_lang);
		else
--            if v_data_THISPUN = 'N' then
--                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISPUN');
--                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--            else
                json_str_output := obj_row.to_clob;
--            end if;
        end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

procedure get_insert_report(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  json_obj		json_object_t;
  param_json_row      json_object_t;
  begin

    json_obj            := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    global_v_coduser    := hcm_util.get_string_t(json_object_t(json_str_input),'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_object_t(json_str_input),'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_object_t(json_str_input),'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_object_t(json_str_input),'p_codempid');
    p_codempid_query    := hcm_util.get_string_t(json_object_t(json_str_input),'codempid');
    p_startdate         := hcm_util.get_string_t(json_object_t(json_str_input),'yearst');
    p_enddate           := hcm_util.get_string_t(json_object_t(json_str_input),'yearen');
    begin
      delete from TTEMPRPT
       where codapp = 'HRPM88X'
         and codempid = global_v_codempid;
    end;

    gen_insert_report();
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_insert_report as
    obj_data		            json_object_t;
		obj_row			        json_object_t;
		obj_result		        json_object_t;
		v_rcnt			        number := 0;
        v_insertNumdeq		    number := 0;
		v_data_THISPUN			varchar2(1) := 'N';
		v_count_thispund	    number;
        v_thispund	            varchar2(100 char);
		v_thispund_CODPAY	    varchar2(100 char);
		v_thispund_desc_CODPAY	varchar2(1000 char);
		v_thispund_NUMPRDST	    varchar2(100 char);
		v_thispund_NUMPRDEN	    varchar2(100 char);
		v_thispund_AMTTOTDED	varchar2(100 char);
        v_imageh                tempimge.namimage%type;
        v_folder                tfolderd.folder%type;
        v_has_image             varchar2(1) := 'N';

        v_ocodempid             varchar2(200 char) := get_ocodempid(p_codempid_query);
        v_dteeffec              thismist.dteeffec%type;
        v_codempid              thismist.codempid%type;

        cursor c1 is
            select a.dteeffec,a.dtemistk,a.numhmref,
                   a.codempid,a.desmist1,a.codmist
              from thismist a
             where (a.codempid = p_codempid_query
                    or v_ocodempid like '[%'||a.codempid||'%]' )
               and to_number(to_char(a.dteeffec,'YYYY')) between to_number(p_startdate) and to_number(p_enddate)
		order by a.dteeffec desc;

        cursor c2 is
            select *
              from thispun
             where codempid = v_codempid
               and dteeffec = v_dteeffec
          order by codpunsh,numseq;

--        cursor c1 is
--            select a.DTEMISTK,a.NUMHMREF,a.CODEMPID,a.DESMIST1,a.CODMIST, b.DTESTART,
--                   b.DTEEND, b.FLGEXEMPT, b.TYPPUN,nvl(b.CODEXEMP,'-') as CODEXEMP,
--                   b.FLGBLIST,a.DTEEFFEC,nvl(b.codpunsh,'no') as codpunsh
--		      from thismist a
--   LEFT OUTER JOIN thispun b on a.codempid=b.codempid and a.DTEEFFEC=b.DTEEFFEC
--		     where (a.codempid = P_CODEMPID or
--                    v_ocodempid like '[%'||a.codempid||'%]' )
--               and TO_NUMBER(to_char(a.DTEEFFEC,'YYYY')) BETWEEN to_number(STARTDATE) AND to_number(ENDDATE)
--		  order by a.DTEEFFEC;
--
--        cursor c2 is
--            select a.DTEMISTK,a.NUMHMREF,a.DTEEFFEC,a.DESMIST1,a.CODMIST,get_tcodec_name('TCODMIST',a.CODMIST,global_v_lang) as TCODMIST
--              from thismist a
--   LEFT OUTER JOIN thispun b on a.codempid=b.codempid and a.DTEEFFEC=b.DTEEFFEC
--             where (a.codempid = P_CODEMPID or
--                    v_ocodempid like '[%'||a.codempid||'%]' )
--               and TO_NUMBER(to_char(a.DTEEFFEC,'YYYY')) BETWEEN to_number(STARTDATE) AND to_number(ENDDATE)
--               and b.codpunsh is not null
--          group by a.dtemistk,a.numhmref,a.dteeffec,a.desmist1,a.codmist
--          order by a.DTEEFFEC;
	begin
        begin
            delete from TTEMPRPT
             where codapp = 'HRPM88X'
               and codempid = global_v_codempid;
        end;

		obj_row     := json_object_t();
		obj_data    := json_object_t();
        numYearReport := HCM_APPSETTINGS.get_additional_year();
        for r1 in c1 loop
            v_dteeffec          := r1.dteeffec;
            v_codempid          := r1.codempid;
            v_insertNumdeq := v_insertNumdeq + 1;
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,
                                  item5,item6,item7,item8)
				 values (global_v_codempid, 'HRPM88X',v_insertNumdeq,
                         'HEAD',hcm_util.get_date_buddhist_era(r1.dtemistk),r1.numhmref,hcm_util.get_date_buddhist_era(r1.Dteeffec),
                         r1.desmist1,nvl(r1.codmist,' '),nvl(get_tcodec_name('TCODMIST',r1.codmist,global_v_lang),' '),
                hcm_util.get_date_buddhist_era(r1.dteeffec));

            for r2 in c2 loop
                v_insertNumdeq      := v_insertNumdeq + 1;

                begin
                    select count(*)
                      into v_count_thispund
                      from thispund
                     where dteeffec = r2.dteeffec
                       and codempid = r2.codempid
                       and codpunsh = r2.codpunsh;
                end;

                if v_count_thispund = 0 then
                    v_thispund_codpay           := null;
                    v_thispund_numprdst         := null;
                    v_thispund_numprden         := null;
                    v_thispund_amttotded        := null;
                    v_thispund_desc_codpay      := null;
                else
                    begin
                        select CODPAY,
                               to_char(numprdst)||'/'||get_tlistval_name('NAMMTHFUL',dtemthst, global_v_lang)||'/'||to_char(numYearReport+dteyearst),
                               to_char(numprden)||'/'|| get_tlistval_name('NAMMTHFUL',dtemthen, global_v_lang)||'/'||to_char(numYearReport+dteyearen),
                               nvl(stddec(amttotded, v_codempid, global_v_chken),'-')
                          into v_thispund_codpay,v_thispund_numprdst,v_thispund_numprden,v_thispund_amttotded
                          from thispund
                         where dteeffec = r2.dteeffec
                           AND codempid = r2.codempid
                           and codpunsh = r2.codpunsh;
                    exception when no_data_found then
                        null;
                    end;
                    if v_thispund_codpay is null then
                        v_thispund_desc_codpay := null;
                    else
                        v_thispund_desc_codpay := v_thispund_codpay||' - '||get_tinexinf_name(v_thispund_codpay,global_v_lang);
                    end if;
                end if;

                begin
                  select get_tfolderd('HRPMC2E1')||'/'||namimage
                   into v_imageh
                   from tempimge
                   where codempid = v_codempid;
                exception when no_data_found then
                  v_imageh := null;
                end;
                if v_imageh is not null then
                  v_imageh     := get_tsetup_value('PATHWORKPHP')||v_imageh;
                  v_has_image   := 'Y';
                end if;

                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,
                ITEM2,ITEM3
                ,ITEM4,ITEM5
                ,ITEM6,ITEM7
                ,ITEM8,ITEM9
                ,ITEM10,ITEM11
                ,ITEM12,ITEM13
                ,ITEM14,ITEM15
                ,ITEM16,ITEM17
                ,ITEM18,ITEM19
                ,ITEM20,ITEM21
                ,ITEM22,ITEM23
                ,ITEM24,ITEM25
                ,ITEM26,ITEM27)
				VALUES (global_v_codempid,'HRPM88X',v_insertNumdeq,
                'DETAIL',
                hcm_util.get_date_buddhist_era(r1.dtemistk),
                r1.NUMHMREF
                ,r1.CODMIST,
                get_tcodec_name('TCODPUNH',r2.codpunsh,global_v_lang)
                ,hcm_util.get_date_buddhist_era(r1.DTEEFFEC),
                r1.DESMIST1
                ,hcm_util.get_date_buddhist_era(r2.DTESTART)
                ,hcm_util.get_date_buddhist_era(r2.DTEEND)
                ,get_tlistval_name('TFLGBLST',r2.FLGEXEMPT,global_v_lang)
                ,get_tlistval_name('NAMTPUN',r2.TYPPUN,global_v_lang)
                ,r2.FLGBLIST
                ,get_tlistval_name('TFLGBLST',r2.flgblist,global_v_lang)
                ,''
                ,r2.CODEXEMP ||' - ' || get_tcodec_name('TCODEXEM',r2.CODEXEMP,global_v_lang)
                ,r2.codpunsh
                ,get_tcodec_name('TCODPUNH',r2.codpunsh,global_v_lang)
                ,nvl(v_thispund_desc_codpay,'-')
                ,nvl(v_thispund_NUMPRDST,'-')
                ,nvl(v_thispund_NUMPRDEN,'-')
                ,nvl(to_char(v_thispund_AMTTOTDED,'fm999,999,999,990.00'),'-')
                ,v_codempid
                ,numYearReport + p_startdate
                ,numYearReport + p_enddate
                ,get_temploy_name(v_codempid,global_v_lang)
                ,v_has_image
                ,v_imageh
                );
--                obj_data_child.put('codpunsh', r2.codpunsh);
--                obj_data_child.put('codpunshtext', get_tcodec_name('TCODPUNH',r2.codpunsh,global_v_lang));
--                obj_data_child.put('typpun', get_tlistval_name('NAMTPUN',r2.typpun,global_v_lang));
--                obj_data_child.put('dtestart', nvl(to_char(r2.dtestart,'DD/MM/YYYY'),'-'));
--                obj_data_child.put('dteend', nvl(to_char(r2.dteend,'DD/MM/YYYY'),'-'));
--                obj_data_child.put('flgexempt', get_tlistval_name('TFLGBLST',r2.flgexempt,global_v_lang));
--                obj_data_child.put('codexemp', r2.codexemp ||' - ' || get_tcodec_name('TCODEXEM',r2.codexemp,global_v_lang));
--                obj_data_child.put('flgblist', get_tlistval_name('TFLGBLST',r2.flgblist,global_v_lang));
            end loop;



        end loop;

--		for r1 in c2 loop
--			v_rcnt              := v_rcnt+1;
--            v_insertNumdeq      := v_insertNumdeq+1;
--            begin
--                select count(*)
--                  into v_count_thispund
--                  from thispund
--                 where dteeffec = r1.dteeffec
--                   and codempid = r1.codempid
--                   and codpunsh = r1.codpunsh;
--            end;
--
--            v_thispund          := r1.codpunsh;
--
--			if v_count_thispund = 0 then
--				v_thispund_CODPAY       := '-';
--                v_thispund_NUMPRDST     := '-';
--                v_thispund_NUMPRDEN     := '-';
--                v_thispund_AMTTOTDED    := '-';
--			else
--                begin
--                    select nvl(CODPAY,'-'),to_char(NUMPRDST)||'/'||get_tlistval_name('NAMMTHFUL',DTEMTHST, global_v_lang)||'/'||to_char(numYearReport+DTEYEARST)
--                    ,to_char(NUMPRDEN)||'/'||get_tlistval_name('NAMMTHFUL',DTEMTHEN, global_v_lang)||'/'||to_char(numYearReport+DTEYEAREN)
--                    ,nvl(stddec(AMTTOTDED, p_codempid, global_v_chken),'-')
--                    into v_thispund_CODPAY,v_thispund_NUMPRDST,v_thispund_NUMPRDEN,v_thispund_AMTTOTDED
--                    from thispund
--                    where DTEEFFEC = r1.DTEEFFEC AND CODEMPID = r1.CODEMPID and codpunsh = r1.codpunsh;
--                EXCEPTION WHEN NO_DATA_FOUND THEN
--                    null;
--                end;
--                v_thispund_CODPAY := v_thispund_CODPAY||' - '||get_tinexinf_name(v_thispund_CODPAY,global_v_lang);
--            end if;
--
--            if r1.codpunsh != 'no'  then
--                v_data_THISPUN := 'Y';
--
--                 begin
--                  select get_tfolderd('HRPMC2E1')||'/'||namimage
--                   into v_imageh
--                   from tempimge
--                   where codempid = p_codempid;
--                exception when no_data_found then
--                  v_imageh := null;
--                end;
--                if v_imageh is not null then
--                  v_imageh     := get_tsetup_value('PATHWORKPHP')||'/'||v_imageh;
--                  v_has_image   := 'Y';
--                end if;
--
--                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
--                ,ITEM1,ITEM2,ITEM3
--                ,ITEM4,ITEM5
--                ,ITEM6,ITEM7
--                ,ITEM8,ITEM9
--                ,ITEM10,ITEM11
--                ,ITEM12,ITEM13
--                ,ITEM14,ITEM15
--                ,ITEM16,ITEM17
--                ,ITEM18,ITEM19
--                ,ITEM20,ITEM21
--                ,ITEM22,ITEM23
--                ,ITEM24,ITEM25
--                ,ITEM26,ITEM27)
--				VALUES (global_v_codempid
--                ,'HRPM88X'
--                ,v_insertNumdeq
--                ,'detail'
--                ,r1.DTEMISTK
--                ,r1.NUMHMREF
--                ,r1.CODMIST
--                ,get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang)
--                ,to_char(r1.DTEEFFEC,'dd/mm/yyyy')
--                ,r1.DESMIST1
--                ,to_char(add_months(to_date(to_char(r1.DTESTART,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy')
--                ,to_char(add_months(to_date(to_char(r1.DTEEND,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy')
--                ,get_tlistval_name('TFLGBLST',r1.FLGEXEMPT,global_v_lang)
--                ,get_tlistval_name('NAMTPUN',r1.TYPPUN,global_v_lang)
--                ,r1.FLGBLIST
--                ,get_label_name('HRPM88X4',global_v_lang,'0')
--                ,get_label_name('HRPM88X4',global_v_lang,'1')
--                ,r1.CODEXEMP ||' - ' || get_tcodec_name('TCODEXEM',r1.CODEXEMP,global_v_lang)
--                ,r1.codpunsh
--                ,get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang)
--                ,v_thispund_CODPAY
--                ,v_thispund_NUMPRDST
--                ,v_thispund_NUMPRDEN
--                ,to_char(v_thispund_AMTTOTDED,'fm999,999,999,990.00')
--                ,P_CODEMPID
--                ,numYearReport + STARTDATE
--                ,numYearReport + ENDDATE
--                ,get_temploy_name(p_codempid,global_v_lang)
--                ,v_has_image
--                ,v_imageh
--                );
--
----                obj_row.put(to_char(v_rcnt-1),obj_data);
--            end if;
--		end loop;

--        for r1 in c2 loop
--            v_insertNumdeq := v_insertNumdeq+1;
--            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
--                ,ITEM1,ITEM2,ITEM3,ITEM4
--                ,ITEM5,ITEM6,ITEM7,ITEM8)
--				VALUES (global_v_codempid, 'HRPM88X',v_insertNumdeq
--                ,'head',r1.DTEMISTK,r1.NUMHMREF,to_char(r1.DTEEFFEC,'dd/mm/yyyy')
--                ,r1.DESMIST1,nvl(r1.CODMIST,' '),nvl(get_tcodec_name('TCODMIST',r1.CODMIST,global_v_lang),' '),
--                to_char(add_months(to_date(to_char(r1.DTEEFFEC,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'));
--        end loop;
--		for r1 in c1 loop
--			v_rcnt := v_rcnt+1;
--            v_insertNumdeq := v_insertNumdeq+1;
--            begin
--                select count(*) into v_count_thispund
--                from thispund
--                where DTEEFFEC = r1.DTEEFFEC AND CODEMPID = r1.CODEMPID and codpunsh = r1.codpunsh;
--            end;
--            v_thispund := r1.codpunsh;
--			if v_count_thispund = 0 then
--				v_thispund_CODPAY := '-';
--                v_thispund_NUMPRDST := '-';
--                v_thispund_NUMPRDEN := '-';
--                v_thispund_AMTTOTDED := '-';
--			else
--                begin
--                    select nvl(CODPAY,'-'),to_char(NUMPRDST)||'/'||get_tlistval_name('NAMMTHFUL',DTEMTHST, global_v_lang)||'/'||to_char(numYearReport+DTEYEARST)
--                    ,to_char(NUMPRDEN)||'/'||get_tlistval_name('NAMMTHFUL',DTEMTHEN, global_v_lang)||'/'||to_char(numYearReport+DTEYEAREN)
--                    ,nvl(stddec(AMTTOTDED, p_codempid, global_v_chken),'-')
--                    into v_thispund_CODPAY,v_thispund_NUMPRDST,v_thispund_NUMPRDEN,v_thispund_AMTTOTDED
--                    from thispund
--                    where DTEEFFEC = r1.DTEEFFEC AND CODEMPID = r1.CODEMPID and codpunsh = r1.codpunsh;
--                EXCEPTION WHEN NO_DATA_FOUND THEN
--                null;
--                end;
--                v_thispund_CODPAY := v_thispund_CODPAY||' - '||get_tinexinf_name(v_thispund_CODPAY,global_v_lang);
--            end if;
--            if r1.codpunsh != 'no'  then
--                v_data_THISPUN := 'Y';
--
--                 begin
--                  select get_tfolderd('HRPMC2E1')||'/'||namimage
--                   into v_imageh
--                   from tempimge
--                   where codempid = p_codempid;
--                exception when no_data_found then
--                  v_imageh := null;
--                end;
--                if v_imageh is not null then
--                  v_imageh     := get_tsetup_value('PATHWORKPHP')||'/'||v_imageh;
--                  v_has_image   := 'Y';
--                end if;
--
--                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
--                ,ITEM1,ITEM2,ITEM3
--                ,ITEM4,ITEM5
--                ,ITEM6,ITEM7
--                ,ITEM8,ITEM9
--                ,ITEM10,ITEM11
--                ,ITEM12,ITEM13
--                ,ITEM14,ITEM15
--                ,ITEM16,ITEM17
--                ,ITEM18,ITEM19
--                ,ITEM20,ITEM21
--                ,ITEM22,ITEM23
--                ,ITEM24,ITEM25
--                ,ITEM26,ITEM27)
--				VALUES (global_v_codempid
--                ,'HRPM88X'
--                ,v_insertNumdeq
--                ,'detail'
--                ,r1.DTEMISTK
--                ,r1.NUMHMREF
--                ,r1.CODMIST
--                ,get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang)
--                ,to_char(r1.DTEEFFEC,'dd/mm/yyyy')
--                ,r1.DESMIST1
--                ,to_char(add_months(to_date(to_char(r1.DTESTART,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy')
--                ,to_char(add_months(to_date(to_char(r1.DTEEND,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy')
--                ,get_tlistval_name('TFLGBLST',r1.FLGEXEMPT,global_v_lang)
--                ,get_tlistval_name('NAMTPUN',r1.TYPPUN,global_v_lang)
--                ,r1.FLGBLIST
--                ,get_label_name('HRPM88X4',global_v_lang,'0')
--                ,get_label_name('HRPM88X4',global_v_lang,'1')
--                ,r1.CODEXEMP ||' - ' || get_tcodec_name('TCODEXEM',r1.CODEXEMP,global_v_lang)
--                ,r1.codpunsh
--                ,get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang)
--                ,v_thispund_CODPAY
--                ,v_thispund_NUMPRDST
--                ,v_thispund_NUMPRDEN
--                ,to_char(v_thispund_AMTTOTDED,'fm999,999,999,990.00')
--                ,P_CODEMPID
--                ,numYearReport + STARTDATE
--                ,numYearReport + ENDDATE
--                ,get_temploy_name(p_codempid,global_v_lang)
--                ,v_has_image
--                ,v_imageh
--                );
--
--                obj_row.put(to_char(v_rcnt-1),obj_data);
--            end if;
--		end loop;
    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
END HRPM88X;

/

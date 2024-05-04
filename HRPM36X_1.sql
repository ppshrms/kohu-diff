--------------------------------------------------------
--  DDL for Package Body HRPM36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM36X" is
--3/09/2019
 procedure initial_value ( json_str		IN clob ) is
		json_obj		json_object_t := json_object_t(json_str);
	begin
		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
		p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
		p_staupd          := hcm_util.get_string_t(json_obj,'p_staupd');
		p_codempid        := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codemployid     := hcm_util.get_string_t(json_obj,'p_codemployid');
		p_typproba        := hcm_util.get_string_t(json_obj,'p_typproba');
		p_dteduepr_str    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteduepr_str') ),'dd/mm/yyyy');
		p_dteduepr_end    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteduepr_end') ),'dd/mm/yyyy');

		hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
	end initial_value;

	procedure get_index ( json_str_input in clob, json_str_output out clob ) as
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			if p_typproba = 1 then
				if p_staupd = 'T' then
					gen_data_1(json_str_output);
				elsif p_staupd = 'N' then
					gen_data_2(json_str_output);
				elsif p_staupd = 'P' then
					gen_data_3(json_str_output);
				elsif p_staupd = 'C' then
					gen_data_4(json_str_output);
				elsif p_staupd = 'U' then
					gen_data_5(json_str_output);
				elsif p_staupd = 'E' then
					gen_data_6(json_str_output);
				end if;
			elsif p_typproba = 2 then
				if p_staupd = 'T' then
					gen_data_7(json_str_output);
				elsif p_staupd = 'N' then
					gen_data_8(json_str_output);
				elsif p_staupd = 'P' then
					gen_data_9(json_str_output);
				elsif p_staupd = 'C' then
					gen_data_10(json_str_output);
				elsif p_staupd = 'U' then
					gen_data_11(json_str_output);
				elsif p_staupd = 'E' then
					gen_data_12(json_str_output);
				end if;
			end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure get_index_with_empid ( json_str_input IN CLOB, json_str_output out clob ) AS
	begin
		initial_value(json_str_input);
		param_msg_error := null;
		if param_msg_error is null then
			gen_data_with_empid(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure check_getindex is
		v_codcomp		varchar2(100);
		v_secur_codcomp		boolean;
	begin
		if p_codcomp is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
			return;
		end if;
		if p_dteduepr_str is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_str');
			return;
		end if;
		if p_dteduepr_end is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_end');
			return;
		end if;
		if p_typproba is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_typproba');
			return;
		end if;
		if p_staupd is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_staupd');
			return;
		end if;
		if p_dteduepr_str is null then
			param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dteduepr_str');
			return;
		end if;
		if p_dteduepr_str > p_dteduepr_end then
			param_msg_error := get_error_msg_php('HR2021',global_v_lang);
			return;
		end if;
		if p_codcomp is NOT null then
			begin
				SELECT COUNT(*)
				INTO v_codcomp
				FROM tcenter
				WHERE codcomp LIKE p_codcomp || '%';
			exception when no_data_found then
				param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
				return;
			end;
			v_secur_codcomp := secur_main.secur7(p_codcomp || '%',global_v_coduser);
			if v_secur_codcomp = false then -- Check User authorize view codcomp
				param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
				return;
			end if;
		end if;
	end;

	procedure gen_data_with_empid ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100);
		v_codrespr		    varchar2(100);
    v_temp_str        varchar2(1000);

    cursor c1 is
      SELECT a.codempid, a.dteduepr, a.codpos, a.codcomp, a.codrespr,
      a.staupd, a.dteefpos, a.typproba, a.dteoccup, '' scorepr, a.qtyexpand, a.desnote, b.dteempmt, a.codeval, a.dteeval
      FROM ttprobat a, temploy1 b
      WHERE a.codempid = p_codemployid
      and a.codempid = b.codempid
      ORDER BY a.dteduepr;

	begin
		obj_row			:= json_object_t ();
    v_rcnt      := 0;
    v_temp_str  := 'p_codeempid '||p_codemployid;

		for i in c1 loop
			v_secur_codempid := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap);
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid = true then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('codempid',i.codempid);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dtestrt',to_char(i.dteefpos,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );
				obj_data.put('typproba',get_tlistval_name('NAMTPRO', i.typproba , global_v_lang));
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('scorepr',i.scorepr);
				obj_data.put('qtyexpand',i.qtyexpand);
                obj_data.put('dteredue',to_char(func_get_next_assessment(i.codcomp,i.codpos,i.codempid,'1'),'dd/mm/yyyy') );
				obj_data.put('desnote',i.desnote);
				obj_data.put('codeval',i.codeval);
				obj_data.put('desc_codeval',get_temploy_name(i.codeval,global_v_lang) );
				obj_data.put('dteeval',to_char(i.dteeval,'dd/mm/yyyy') );
				obj_data.put('codrespr',get_tlistval_name ('NAMEVAL', i.codrespr , global_v_lang));
                obj_data.put('chk_probation',chk_probation(i.codempid));
--        obj_data.put('timeofeva',func_get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),i.codempid,p_typproba));
				obj_row.put(to_char(v_rcnt_found - 1),obj_data);
			end if;
		end loop;

		if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
    end if;
		if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
			json_str_output := obj_row.to_clob;
    end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_with_empid;

	procedure gen_data_1 (json_str_output out clob) is
		v_rcnt_found		    number := 0;
		v_secur_codempid	    boolean;
		v_p_zupdzap		        varchar2(100 char);
		v_qtymax		        number;
		v_dtedueprn		        varchar2(100 char);
		v_numtime		        number;
        v_qtyduepr              number;
        cursor c1 is
          select  a.codempid,a.dteduepr,a.numlvl,a.codcomp,a.dteempmt,a.staemp,
                  a.codpos,a.codjob,a.dteoccup,a.codempmt,a.dteredue,a.typemp
             from temploy1 a
            where a.codcomp  like p_codcomp||'%'
              and a.staemp = '1'
              and ((a.dteduepr between p_dteduepr_str and p_dteduepr_end
                    and not (exists(select codempid
                                     from  tappbath b
                                     where a.codempid = codempid
                                     and   a.dteduepr = dteduepr)) ) or
                    (a.dteredue between p_dteduepr_str and p_dteduepr_end
                     and not (exists(select codempid
                                      from  tappbath b
                                      where a.codempid = codempid
                                      and   a.dteredue = dteduepr)) ))
             order by a.codcomp,a.codempid	;

	begin
		obj_row   := json_object_t ();
        v_rcnt    := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data := json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('codjob',i.codjob);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,1,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);

				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_1;

	procedure gen_data_2 ( json_str_output out clob ) is
		v_rcnt_found		    number := 0;
		v_secur_codempid	    boolean;
		v_p_zupdzap		        varchar2(100 char);
        v_qtymax                number;
        v_numtime               number;
		v_dtedueprn		        varchar2(100 char);
        v_qtyduepr              number;
        cursor c1 is
           select a.codempid,a.numlvl,a.codcomp,a.dteempmt,a.typemp,
                  a.codpos,a.codjob,a.dteoccup,a.codempmt,a.dteredue,a.staemp,
                  b.dteduepr, b.numtime
             from temploy1 a, ttprobatd b
           where a.codcomp   like p_codcomp||'%'
             and a.staemp    = '1'
             and a.codempid  = b.codempid
             and b.dtedueprn between p_dteduepr_str and p_dteduepr_end
             and not exists(select codempid
                             from ttprobatd
                            where b.codempid = codempid
                              and b.dteduepr = dteduepr
                              and b.numtime + 1 = numtime)
             and not exists(select codempid
                                 from ttprobat
                                where b.codempid = codempid
                                  and b.dteduepr = dteduepr)
          order by a.codcomp,a.codempid;
	begin
		obj_row	  := json_object_t ();
        v_rcnt    := 0;
		for i in c1 loop
            v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),i.numtime);

                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,i.numtime,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,i.numtime);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_2;

	procedure gen_data_3 ( json_str_output out clob ) is
		v_rcnt_found		number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_dtedueprn		    varchar2(100 char);
        v_qtymax            number;
        v_numtime           number;

        v_typemp            temploy1.typemp%type;
        v_dteredue          temploy1.dteredue%type;
        v_dteduepr          temploy1.dteduepr%type;
        v_staemp            temploy1.staemp%type;
        v_qtyduepr          number;

    cursor c1 is
      select a.codempid,b.dteduepr,a.numlvl,a.codcomp,a.dteempmt,
             b.codpos,a.codjob,b.qtyexpand,b.dteoccup,
             b.dteexpand,b.flgadjin,b.codempmt,a.dteredue,a.typemp,a.staemp,
             b.rowid,qtywkday ,a.dteeffex
        from temploy1 a,ttprobat b
       where b.codcomp  like p_codcomp||'%'
         and b.dteduepr between p_dteduepr_str and p_dteduepr_end
         and b.staupd in ('P','A')
         and a.codempid  = b.codempid
         and b.typproba = 1
       order by a.codcomp,a.codempid;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
                /*obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);*/
				--<< user18 10/03/2021 evalutation complete
                obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----
  when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_3;

	procedure gen_data_4 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
        v_qtymax          number;
        v_numtime         number;
        v_dtedueprn       varchar2(100 char);

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

		cursor c1 is
          select a.codempid,b.dteduepr,a.numlvl,a.codcomp,a.dteempmt,
                 b.codpos,a.codjob,b.qtyexpand,b.dteoccup,
                 b.dteexpand,b.flgadjin,b.codempmt,
                 b.rowid ,qtywkday ,a.dteeffex,a.staemp,a.typemp,a.dteredue
            from temploy1 a,ttprobat b
           where a.codcomp   like p_codcomp||'%'
             and b.dteduepr between p_dteduepr_str and p_dteduepr_end
             and a.staemp    = '1'
             and a.codempid  = b.codempid
             and b.staupd in ( 'N','C')
             and b.typproba = 1
             and ((b.numlettr = ' ') or (b.numlettr is null))
          order by a.codcomp,a.codempid;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
--                obj_data.put('dtedueprn',v_dtedueprn);
--                obj_data.put('codcompap',v_codcompap);
--                obj_data.put('codposap',v_codposap);
--                obj_data.put('codempap',v_codempap);
--                obj_data.put('desc_codempap',v_desc_codempap);
                --<< user18 10/03/2021
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

		if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_4;

	procedure gen_data_5 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_dtedueprn		    varchar2(100 char);
        v_qtymax          number;
        v_numtime         number;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

    cursor c1 is
      select a.codempid,b.dteduepr,a.numlvl,a.codcomp,a.dteempmt,
             b.codpos,a.codjob,b.qtyexpand,b.dteoccup,
             b.dteexpand,b.flgadjin,b.codempmt,
             b.rowid,qtywkday ,a.dteeffex,a.dteredue,a.typemp,a.staemp
        from temploy1 a,ttprobat b
       where b.codcomp like p_codcomp||'%'
         and b.dteduepr between p_dteduepr_str and p_dteduepr_end
         and b.staupd = 'U'
         and a.codempid = b.codempid
         and b.typproba = 1
      order by a.codcomp,a.codempid ;

	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
                /*obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);*/
                --<< user18 10/03/2021 evalutation complete
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_5;

	procedure gen_data_6 ( json_str_output out clob ) is

		v_rcnt_found		  number := 0;
		v_qtyscor		      varchar2(100 char);
		v_qtyday		      varchar2(100 char);
		v_qtymax		      varchar2(100 char);
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_dtedueprn		    varchar2(100 char);
        v_numtime         number := 0;
        v_qtymax_tmp      number := 0;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

		cursor c1 is
      select  a.codempid,a.dteduepr,a.numlvl,a.codcomp,a.dteempmt,a.typemp,a.staemp,
                      a.codpos,a.codjob,a.dteoccup,a.codempmt,a.dteredue
               from   temploy1 a
               where a.codcomp  like p_codcomp||'%'
                 and a.staemp = '1'
                  and a.dteduepr between p_dteduepr_str and p_dteduepr_end
                 and exists(select codempid
                              from ttprobat b
                             where a.codempid = b.codempid and b.typproba = '1'
                               and a.dteduepr = b.dteexpand and b. codrespr = 'E'
                               and b.staupd = ('U') )
               order by a.codcomp,a.codempid	;
--        SELECT a.codempid, a.dteduepr, a.numlvl, a.codcomp, a.dteempmt, a.codpos, a.codjob, a.dteoccup, a.codempmt, a.dteredue
--        FROM temploy1 a
--        WHERE a.codcomp LIKE p_codcomp || '%'
--        and ( ( a.dteduepr BETWEEN p_dteduepr_str and p_dteduepr_end )
--        OR ( a.dteredue BETWEEN p_dteduepr_str and p_dteduepr_end ) )
--        ORDER BY a.codcomp, a.codempid;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteempmt is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteempmt + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteempmt);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
                /*obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);*/
                --<< user18 10/03/2021 evalutation complete
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_6;

	procedure gen_data_7 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_dtedueprn		    varchar2(100 char);
		v_qtyscor		      varchar2(100 char);
		v_qtyday		      varchar2(100 char);
		v_qtymax		      varchar2(100 char);
        v_numtime         number := 0;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

		cursor c1 is
            select a.dteeffec,a.codempid,a.dteduepr,a.numlvl,a.codcomp,b.dteempmt,b.dteredue,b.typemp,b.staemp,
               a.codpos,a.codjob,b.dteoccup,a.codempmt,a.rowid,qtywkday ,dteeffex
              from ttmovemt a,temploy1 b, tcodmove c
             where a.codcomp  like p_codcomp||'%'
                and a.dteduepr between p_dteduepr_str and p_dteduepr_end
                and a.codtrn = c.codcodec
                and c.typmove = 'M'
                and a.staupd = 'U'
                and a.codempid = b.codempid
                and not exists(select codempid
                                 from tappbath
                                where a.codempid = codempid
                                  and a.dteduepr = dteduepr)
              order by a.codcomp,a.codempid;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
--				obj_data.put('dteempmt',to_char(i.dteempmt,'dd/mm/yyyy') );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);
                obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTMOVEMT');
        elsif v_rcnt_found = 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := obj_row.to_clob;
        end if;
	exception
	/*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTMOVEMT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack
		|| ' '
		|| dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_7;

	procedure gen_data_8 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_qtymax		      number;
		v_dtedueprn		    varchar2(100 char);
		v_numtime		      number;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

    cursor c1 is
      select  c.dteeffec,a.codempid,a.numlvl,a.codcomp,a.dteempmt,
              a.codpos,a.codjob,a.dteoccup,a.codempmt,a.dteredue,
              b.dteduepr, b.numtime,a.typemp,a.staemp
         from temploy1 a, ttprobatd b,ttmovemt c
       where a.codcomp   like p_codcomp||'%'
         and a.staemp    = '3'
         and a.codempid  = b.codempid
         and b.codempid  = c.codempid
         and b.dteduepr = c.dteduepr
         and b.dtedueprn between p_dteduepr_str and p_dteduepr_end
         and not exists(select codempid
                             from ttprobatd
                            where b.codempid = codempid
                              and b.dteduepr = dteduepr
                              and b.numtime + 1 = numtime)
         and not exists(select codempid
                             from ttprobat
                            where b.codempid = codempid
                              and b.dteduepr = dteduepr)
      order by a.codcomp,a.codempid;

	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
            v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),i.numtime);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,i.numtime,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,i.numtime);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
        elsif v_rcnt_found = 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
        if param_msg_error is not null then
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_8;

	procedure gen_data_9 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_qtymax		      number;
		v_dtedueprn		    varchar2(100 char);
		v_numtime		      number;

    v_typemp          temploy1.typemp%type;
    v_dteredue        temploy1.dteredue%type;
    v_dteduepr        temploy1.dteduepr%type;
    v_staemp          temploy1.staemp%type;
    v_qtyduepr        number;

    cursor c1 is
      select b.dteeffec,b.codempid,b.dteduepr,b.numlvl,b.codcomp,c.dteempmt,
             b.codpos,b.qtyexpand,b.dteoccup,
             b.dteexpand,b.flgadjin,b.codempmt,
             b.rowid,qtywkday ,c.dteeffex, c.codjob,c.dteredue,c.typemp,c.staemp
        from ttprobat b,temploy1 c
       where b.codcomp like p_codcomp||'%'
         and b.dteduepr between p_dteduepr_str and p_dteduepr_end
         and b.codempid = c.codempid
         and b.staupd in ('P','A')
         and b.typproba = 2
      order by b.codcomp,b.codempid	;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021
--                obj_data.put('dtedueprn',v_dtedueprn);
--                obj_data.put('codcompap',v_codcompap);
--                obj_data.put('codposap',v_codposap);
--                obj_data.put('codempap',v_codempap);
--                obj_data.put('desc_codempap',v_desc_codempap);
                --<< user18 10/03/2021
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

		if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_9;

	procedure gen_data_10 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_qtymax		      number;
		v_dtedueprn		    varchar2(100 char);
		v_numtime		      number;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

        cursor c1 is
        select b.dteeffec,b.codempid,b.dteduepr,b.numlvl,b.codcomp,c.dteempmt,
               b.codpos,b.qtyexpand,b.dteoccup,b.dteexpand,b.flgadjin,b.codempmt,
               b.rowid,qtywkday ,c.dteeffex,c.codjob,c.dteredue,c.staemp,c.typemp
          from ttprobat b,temploy1 c
         where b.codcomp like p_codcomp || '%'
           and b.dteduepr between p_dteduepr_str and p_dteduepr_end
           and b.codempid = c.codempid
           and b.staupd in ('N','C')
           and b.typproba = 2
           and (b.numlettr = ' ' or b.numlettr is null)
         order by b.codcomp,b.codempid ;

	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
--				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1 ;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
--                obj_data.put('dtedueprn',v_dtedueprn);
--                obj_data.put('codcompap',v_codcompap);
--                obj_data.put('codposap',v_codposap);
--                obj_data.put('codempap',v_codempap);
--                obj_data.put('desc_codempap',v_desc_codempap);
                --<< user18 10/03/2021
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_10;

	procedure gen_data_11 ( json_str_output out clob ) is

		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_qtymax		      number;
		v_dtedueprn		    varchar2(100 char);
		v_numtime		      number;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

		cursor c1 is
          select b.dteeffec,b.codempid,b.dteduepr,b.numlvl,b.codcomp,c.dteempmt,
                 b.codpos,b.qtyexpand,b.dteoccup,
                 b.dteexpand,b.flgadjin,b.codempmt,
                 b.rowid,qtywkday ,c.dteeffex,c.codjob,c.dteredue,c.typemp,c.staemp
            from ttprobat b,temploy1 c
         where b.codcomp like p_codcomp || '%'
           and b.dteduepr between p_dteduepr_str and p_dteduepr_end
           and b.codempid = c.codempid
           and b.staupd = 'U'      --Exe.  STAUPD  -  U-ประมวลผลแล้ว
           and b.TYPPROBA =  2
         order by b.codcomp,b.codempid;
	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
		for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
--				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
                /*obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);*/
                --<< user18 10/03/2021 evalutation complete
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

		if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_11;

	procedure gen_data_12 ( json_str_output out clob ) is
		v_rcnt_found		  number := 0;
		v_secur_codempid	boolean;
		v_p_zupdzap		    varchar2(100 char);
		v_qtymax		      number;
		v_dtedueprn		    varchar2(100 char);
		v_numtime		      number;

        v_typemp          temploy1.typemp%type;
        v_dteredue        temploy1.dteredue%type;
        v_dteduepr        temploy1.dteduepr%type;
        v_staemp          temploy1.staemp%type;
        v_qtyduepr        number;

		cursor c1 is
          select a.dteeffec,a.codempid,a.dteduepr,a.numlvl,a.codcomp,b.dteempmt,
                 a.codpos,a.codjob,b.dteoccup,a.codempmt,a.rowid,qtywkday ,dteeffex,b.dteredue,b.typemp,b.staemp
            from ttmovemt a,temploy1 b, tcodmove c
           where a.codcomp  like p_codcomp || '%'
             and a.dteduepr between p_dteduepr_str and p_dteduepr_end
             and a.codtrn = c.codcodec
             and c.typmove = 'M' and a.staupd = 'U'
             and a.codempid = b.codempid
             and exists(select codempid
                          from ttprobat b
                         where a.codempid =  b.codempid and b.typproba = '2'
                           and a.dteduepr = b.dteexpand
                           and b.staupd in ('U') )
           order by a.codcomp,a.codempid	;

	begin
		obj_row			:= json_object_t ();
        v_rcnt          := 0;
    for i in c1 loop
			v_secur_codempid := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_p_zupdzap );
			v_rcnt := v_rcnt + 1;
			if v_secur_codempid then
				v_rcnt_found := v_rcnt_found + 1;
				obj_data		:= json_object_t ();
				obj_data.put('coderror','200');
				obj_data.put('image',get_emp_img(i.codempid));
				obj_data.put('codempid',i.codempid);
				obj_data.put('codcomp',i.codcomp);
				obj_data.put('codpos',i.codpos);
				obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang) );
				obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang) );
				obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang) );
				obj_data.put('dteempmt',to_char(i.dteeffec,'dd/mm/yyyy') );
				obj_data.put('codempmt',i.codempmt);
--				obj_data.put('codjob',i.codjob);
				obj_data.put('numlvl',i.numlvl);
				obj_data.put('dteoccup',to_char(i.dteoccup,'dd/mm/yyyy') );
				obj_data.put('dteduepr',to_char(i.dteduepr,'dd/mm/yyyy') );

                obj_data.put('dteredue',nvl(to_char(i.dteredue,'dd/mm/yyyy'),'-'));
				obj_data.put('typemp',get_tcodec_name('TCODCATG',i.typemp,global_v_lang) );
				obj_data.put('desc_codjob',get_tjobcode_name(i.codjob,global_v_lang));
				obj_data.put('desc_codempmt',get_tcodec_name('TCODEMPL',i.codempmt,global_v_lang));
                v_qtyduepr := null;
                if i.dteduepr is not null and i.dteeffec is not null then
                  v_qtyduepr  :=  i.dteduepr - i.dteeffec + 1;
                end if;
                obj_data.put('qtyduepr', v_qtyduepr);

                if i.staemp = 1 then
                  obj_data.put('typoccup',get_tlistval_name('NAMTPRO',1,global_v_lang));
                else
                  obj_data.put('typoccup', get_tlistval_name('NAMTPRO',2,global_v_lang));
                end if;

                v_qtymax    := get_qtymax(i.codcomp,i.codpos,i.codempid,p_typproba);
                v_numtime   := get_numtime(i.codempid,to_char(i.dteduepr,'dd/mm/yyyy'),null);
                v_dtedueprn := get_dtedueprn(i.codcomp,i.codpos,i.codempid,i.dteduepr,null,i.dteeffec);
                get_next_appr(i.codcomp,i.codpos,i.codempid,i.dteduepr,null);

                obj_data.put('qtymax',v_qtymax);
                obj_data.put('numtime',v_numtime);
                -->> user18 10/03/2021 evalutation complete
                /*obj_data.put('dtedueprn',v_dtedueprn);
                obj_data.put('codcompap',v_codcompap);
                obj_data.put('codposap',v_codposap);
                obj_data.put('codempap',v_codempap);
                obj_data.put('desc_codempap',v_desc_codempap);*/
                --<< user18 10/03/2021 evalutation complete
				obj_row.put(to_char(v_rcnt - 1),obj_data);
			else
				v_rcnt_found := 0;
			end if;
		end loop;

        if v_rcnt = 0 then
			param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		elsif v_rcnt_found = 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang,null);
        end if;
		if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
			json_str_output := obj_row.to_clob;
        end if;
	exception
  /*----when no_data_found then
		param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTPROBAT');
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);*/
	when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_data_12;

  procedure gen_report(json_str_input in clob, json_str_output out clob) as
    v_codempid    varchar2(10 char);
    v_codapp      varchar2(30 char);
    v_numseq      number;
    numYearReport number;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;
    v_item11      ttemprpt.item11%type;
    v_item12      ttemprpt.item12%type;
    v_item13      ttemprpt.item13%type;
    v_item14      ttemprpt.item14%type;
    v_item15      ttemprpt.item15%type;
    v_item16      ttemprpt.item16%type;
    v_item17      ttemprpt.item17%type;
    v_item18      ttemprpt.item18%type;
    v_item19      ttemprpt.item19%type;
    v_item20      ttemprpt.item20%type;
    v_item21      ttemprpt.item21%type;
    v_objitem     json_object_t ;
    obj_row       json_object_t ;
    obj_data      json_object_t ;
    v_objlistofselect                   json_object_t;
    v_objitemlistofselect               json_object_t;
    v_in_parameter_get_index_with_empid clob;
    v_out_parmeter_get_index_with_empid clob;
    v_outindexemp                       json_object_t;
    v_avgscor                           ttprobatd.avgscor%type;
    v_codrespr                          ttprobatd.codrespr%type;
    v_dteduepr                          date;
  begin
    initial_value (json_str_input);
    v_objitem := json_object_t(json_str_input);
    obj_row   := hcm_util.get_json_t(v_objitem,'p_index_rows');
    numYearReport := HCM_APPSETTINGS.get_additional_year();
    begin
      delete from ttemprpt where codapp = 'HRPM36X' and codempid = p_codempid;
    end;
    for i in 0..obj_row.get_size - 1 loop
      obj_data  := hcm_util.get_json_t(obj_row,i);
      v_item1   := hcm_util.get_string_t(obj_data,'codempid'); --รหัสพนักงานที่ถูกประเมิน
      v_item2   := hcm_util.get_string_t(obj_data,'desc_codempid'); --ชื่อรหัสพนักงานที่ถูกประเมิน
      v_item3   := hcm_util.get_string_t(obj_data,'desc_codcomp');
      v_item4   := hcm_util.get_string_t(obj_data,'desc_codpos');
      v_item5   := hcm_util.get_string_t(obj_data,'desc_codjob');
      v_item6   := hcm_util.get_string_t(obj_data,'desc_codempmt');
      v_item7   := hcm_util.get_string_t(obj_data,'typemp');
      v_item8   := replace(hcm_util.get_string_t(obj_data,'dteempmt'),'-','');
      v_item9   := replace(hcm_util.get_string_t(obj_data,'dteredue'),'-','');
      v_item10  := hcm_util.get_string_t(obj_data,'qtyduepr');
      v_item11  := replace(hcm_util.get_string_t(obj_data,'dteduepr'),'-','');
      v_item12  := hcm_util.get_string_t(obj_data,'typoccup');
      v_dteduepr := to_date(v_item11,'dd/mm/yyyy');
      v_item8 := to_char(add_months(to_date(v_item8,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
      v_item9 := to_char(add_months(to_date(v_item9,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');
      v_item11 := to_char(add_months(to_date(v_item11,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy');

      begin
          select AVGSCOR, codrespr, nvl(to_char(qtyexpand),'-'), codexemp
            into v_item17 , v_codrespr, v_item18, v_item20
            from ttprobatd
           where codempid = v_item1
             and dteduepr = v_dteduepr
             and numtime = (select max(numtime)
                              from ttprobatd
                             where codempid = v_item1
                               and dteduepr = v_dteduepr);
      exception when others then
        v_item17 := 0;
        v_item18 := '-';
        v_item20 := '';
      end;

      begin
        select nvl(hcm_util.get_date_buddhist_era(dteoccup),'-')
          into v_item16
          from ttprobat
         where codempid = v_item1
           and dteduepr = v_dteduepr;
      exception when others then
        v_item16 := '-';
      end;

      begin
          select nvl(hcm_util.get_date_buddhist_era(dteeval),'-'), codeval
            into v_item19, v_item21
            from tappbath
           where codempid = v_item1
             and dteduepr = v_dteduepr
             and dteeval = (select max(dteeval)
                              from tappbath
                             where codempid = v_item1
                               and dteduepr = v_dteduepr)
        order by numtime desc,numseq desc
        fetch first 1 row only;
      exception when others then
        v_item19 := '-';
        v_item21 := '';
      end;

      begin
        select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_item14
          from tempimge
         where codempid = v_item1
         and namimage is not null;
         v_item13 := 'Y';
      exception when no_data_found then
        v_item14 := '';
        v_item13 := 'N';
      end;
      begin
        insert into ttemprpt(codempid,codapp,numseq,
                             item1,item2,item3,item4,item5,
                             item6,item7,item8,item9,item10,
                             item11,item12,item13,item14,item15,
                             item16,item17,item18,item19,item20,item21)
                      values(p_codempid,'HRPM36X',i + 1,
                             v_item1,v_item2,v_item3,v_item4,v_item5,
                             v_item6,v_item7,v_item8,v_item9,v_item10,
                             v_item11,v_item12,v_item13,v_item14,get_tlistval_name('CODRESPR', v_codrespr, global_v_lang),
                             v_item16,v_item17,v_item18,v_item19,get_tcodec_name('TCODEXEM',v_item20,global_v_lang),v_item21 || ' - ' ||get_temploy_name(v_item21,global_v_lang));
      end;
    end loop;
--
    param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    json_str_output :=  get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  function chk_probation (p_codempid IN varchar2) RETURN  number is
    v_tappbath		number;
  begin
    select count(*) into v_tappbath
      from tappbath
     where codempid  = p_codempid;
    return v_tappbath;
  end chk_probation;

  function get_numtime (v_codempid in varchar2, v_dteduepr in varchar2, v_numtime in number) return  number is
    v_numtimepr	number;
  begin

    begin
      select max(numtime) into v_numtimepr

        from tappbath
       where codempid = v_codempid
         and dteduepr = to_date(v_dteduepr,'dd/mm/yyyy')
         and numtime  = nvl(v_numtime,numtime)
         and dteeval is not null;

    exception when no_data_found then
      v_numtimepr := 1;
    end;
    if v_qtymax_g is null then
        return v_numtimepr;
    else
        return nvl(v_numtimepr,0);
    end if;

  end get_numtime;

  procedure get_next_appr (v_codcomp in varchar2, v_codpos in varchar2,
                           v_codempid in varchar2, v_dteduepr in date,
                           v_numtime in number) is
    tmp_codcompap       varchar2(1000 char);
    tmp_codposap        varchar2(1000 char);
    tmp_codempap        varchar2(1000 char);
    tmp_desc_codempap   varchar2(1000 char);

    temphead_codcomph   varchar2(1000 char);
    temphead_codempidh  varchar2(1000 char);
    temphead_codposh    varchar2(1000 char);

    v_noappr          number;
    v_flgappr          number;

    cursor c2 is
      select qtymax ,codcomp,codpos,codempid
        from tproasgh
       where v_codcomp like codcomp || '%'
         and v_codpos like codpos
         and v_codempid like codempid
         and typproba = p_typproba
       order by codempid desc,codcomp desc;
    cursor c3 is
      select numseq from tappbath
       where codempid = v_codempid
         and dteduepr = v_dteduepr
         and numtime = v_numtime
         and dteeval is null
       order by numseq ;
  begin
--    tmp_codcompap       := get_tcenter_name(i.codcomp,global_v_lang);
--    tmp_codposap        := get_tpostn_name(i.codpos,global_v_lang);
--    tmp_codempap        := i.codempid;
--    tmp_desc_codempap   := get_temploy_name(i.codcomp,global_v_lang);
    for i in c2 loop
      tmp_codcompap       := i.codcomp;
      tmp_codposap        := i.codpos;
      tmp_codempap        := i.codempid;
    end loop;
    v_noappr := 1;
    for i in c3 loop
      v_noappr := i.numseq;
      exit;
    end loop;

    begin
      select codcompap,codempap,codposap,flgappr
        into v_codcompap,v_codempap,v_codposap,v_flgappr
        from tproasgn
       where codcomp = tmp_codcompap
         and codpos = tmp_codposap
         and codempid = tmp_codempap
         and typproba = p_typproba
         and numseq = v_noappr;
    exception when no_data_found then
      v_codcompap := '';
      v_codempap := '';
      v_codposap := '';
      v_flgappr := '';
    end;
    v_desc_codempap := get_temploy_name(v_codempap,global_v_lang);
    if v_flgappr is not null then
      if v_flgappr = 1 then
        begin
          select replace(codcomph,'%',null) codcomph,
                 replace(codempidh,'%',null) codempidh,
                 replace(codposh,'%',null) codposh
            into temphead_codcomph,temphead_codempidh,temphead_codposh
            from temphead
           where codempid = v_codempid
           and rownum = 1;
        exception when no_data_found then
            begin
              select replace(codcomph,'%',null) codcomph,
                     replace(codempidh,'%',null) codempidh,
                     replace(codposh,'%',null) codposh
                into temphead_codcomph,temphead_codempidh,temphead_codposh
                from temphead
               where codcomp = v_codcomp
                 and codpos = v_codpos;
            exception when no_data_found then
              v_codcompap     := '';
              v_codposap      := '';
              v_codempap      := '';
              v_desc_codempap := '';
            end;
        end;
        IF temphead_codempidh IS NOT NULL THEN
          v_codcompap     := '';
          v_codposap      := '';
          v_codempap      := temphead_codempidh;
          v_desc_codempap := get_temploy_name(temphead_codempidh,global_v_lang);
        else
          v_codcompap     := get_tcenter_name(temphead_codcomph,global_v_lang);
          v_codposap      := get_tpostn_name(temphead_codposh,global_v_lang);
          v_codempap      := '';
          v_desc_codempap := '';
        end if;
--        if temphead_codempidh <> '%' then
--          v_codcompap     := '';
--          v_codposap      := '';
--          v_codempap      := temphead_codempidh;
--          v_desc_codempap := get_temploy_name(temphead_codempidh,global_v_lang);
--        else
--          v_codcompap     := get_tcenter_name(temphead_codcomph,global_v_lang);
--          v_codposap      := get_tpostn_name(temphead_codposh,global_v_lang);
--          v_codempap      := '';
--          v_desc_codempap := '';
--        end if;
      end if;
    end if;
  end get_next_appr;

  function func_get_next_assessment (p_codcomp in varchar2 , p_codpos in varchar2 , p_codempid in varchar2 , p_typproba in varchar2) return  date is
    v_start_day_assessment     date;
    v_next_day_assessment      number;
    v_next_date_assessment		 date;
  begin
    begin
       select dtecreate into v_start_day_assessment
         from tappbath
        where numtime = (select max(numtime) from tappbath where codempid = p_codempid)
          and numseq = (select min(numseq) from tappbath where codempid = p_codempid)
          and codempid = p_codempid;
    exception when no_data_found then
       v_start_day_assessment := null;
    end;
    begin
      select qtyday into v_next_day_assessment
        from tproasgh
       where codempid = p_codempid
         and codcomp = '%'
         and codpos = '%'
         and typproba = p_typproba;
    exception when no_data_found then
      begin
      select qtyday into v_next_day_assessment
        from tproasgh
       where codempid = '%'
         and get_compful(codcomp) = p_codcomp
         and codpos = p_codpos
         and typproba = p_typproba;
      exception when no_data_found then
        v_next_day_assessment  :=  0;
      end;
    end;
    v_next_date_assessment := (v_start_day_assessment + v_next_day_assessment);
    return v_next_date_assessment;
--           begin
--            SELECT qtyday
--            INTO v_next_day_assessment
--            FROM tproasgh
--            WHERE p_codcomp LIKE codcomp || '%'
--                and p_codpos LIKE codpos
--                and codempid = ( SELECT MAX(
--                            CASE when p_codempid = codempid then
--                                    codempid
--                                else
--                                    '%'
--                            end
--                        )
--                    FROM
--                        tproasgh
--                    WHERE
--                        p_codcomp LIKE codcomp || '%'
--                        and p_codpos LIKE codpos
--                        and typproba = p_typproba
--                )
--                and typproba = p_typproba;
--           exception when no_data_found then
--               v_next_day_assessment := null;
--           end;
  end func_get_next_assessment;

  function get_qtymax (v_codcomp in varchar2, v_codpos in varchar2, v_codempid in varchar2, p_typproba in varchar2) return  number is
    v_qtymax  tproasgh.qtymax%type;
  begin
    begin
      select qtymax
        into v_qtymax
        from tproasgh
       where v_codcomp like codcomp || '%'
         and v_codpos like codpos
         and v_codempid like codempid
         and typproba = p_typproba
         and rownum = 1;
    exception when no_data_found then
      v_qtymax  :=  null;
    end;
    v_qtymax_g := v_qtymax;
    return v_qtymax;
  end get_qtymax;

  function get_dtedueprn (v_codcomp in varchar2, v_codpos in varchar2,v_codempid in varchar2, v_dteduepr in date, v_numtime in number,v_dteempmt in date) return varchar2 is
    v_dtedueprn       varchar2(100 char);
    v_next_day_appr   number;
  begin
    begin
      select to_char(dtedueprn, 'dd/mm/yyyy') into v_dtedueprn
        from ttprobatd
       where codempid = v_codempid
         and dteduepr = v_dteduepr
         and numtime = v_numtime;
    exception when no_data_found then
      v_dtedueprn := null;
    end;
    if v_dtedueprn is null then
      begin
        select qtyday into v_next_day_appr
          from tproasgh
         where v_codcomp like codcomp || '%'
           and v_codpos like codpos
           and v_codempid like codempid
           and typproba = p_typproba
           and rownum = 1;
      exception when no_data_found then
        v_next_day_appr  := null;
      end;

      if v_next_day_appr is not null then
         v_dtedueprn  :=  to_char(v_dteempmt + v_next_day_appr -1, 'dd/mm/yyyy');
      end if;
    end if;
    return v_dtedueprn;
  end get_dtedueprn;
end hrpm36x;

/

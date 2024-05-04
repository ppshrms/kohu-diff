--------------------------------------------------------
--  DDL for Package Body HRPMB8E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB8E" is
	procedure initial_value (json_str in clob) is
		json_obj		      json_object_t;
		obj_data_global		json_object_t;
	begin
		v_chken := hcm_secur.get_v_chken;
		json_obj := json_object_t(json_str);

		global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
		global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
		global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
		global_v_lrunning := hcm_util.get_string_t(json_obj,'p_lrunning');
		p_codcompy        := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
		p_dteeffec        := to_date(hcm_util.get_string_t(json_obj,'p_dteeffect'), 'ddmmyyyy');

	end initial_value;

	procedure get_detail (json_str_input in clob, json_str_output out clob) as
	begin
		initial_value(json_str_input);
		gen_detail(json_str_output);

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure gen_detail (json_str_output out clob) as
		obj_row			    json_object_t;
		obj_data		    json_object_t;
		v_rcnt			    number := 0;
		v_codempid		  varchar2( 100 char);
		v_flag_found    char(1 char) := 'N';
		full_emp_name		varchar2( 100 char);

		p_codincom1		    TCONTPMS.CODINCOM1%type;
    p_codincom2		    TCONTPMS.CODINCOM2%type;
    p_codincom3		    TCONTPMS.CODINCOM3%type;
    p_codincom4		    TCONTPMS.CODINCOM4%type;
    p_codincom5		    TCONTPMS.CODINCOM5%type;
    p_codincom6		    TCONTPMS.CODINCOM6%type;
    p_codincom7		    TCONTPMS.CODINCOM7%type;
    p_codincom8		    TCONTPMS.CODINCOM8%type;
    p_codincom9		    TCONTPMS.CODINCOM9%type;
    p_codincom10	    TCONTPMS.CODINCOM10%type;
		p_codretro1		    TCONTPMS.CODRETRO1%type;
    p_codretro2		    TCONTPMS.CODRETRO2%type;
    p_codretro3		    TCONTPMS.CODRETRO3%type;
    p_codretro4		    TCONTPMS.CODRETRO4%type;
    p_codretro5		    TCONTPMS.CODRETRO5%type;
    p_codretro6		    TCONTPMS.CODRETRO6%type;
    p_codretro7		    TCONTPMS.CODRETRO7%type;
    p_codretro8		    TCONTPMS.CODRETRO8%type;
    p_codretro9		    TCONTPMS.CODRETRO9%type;
    p_codretro10	    TCONTPMS.CODRETRO10%type;
    msg               varchar2( 1000 char);
		p_coduser		      TSEMPIDH.CODUSER%type;
		p_dteupd		      varchar2( 100 char);

		p_flag_edit		      varchar2( 10 char);
		p_flag_have_data	  number := 0;
    v_found_count       number := 0;
    v_not_found_count   number := 0;
    v_dteeffec          date;
    tcontpms_rec        tcontpms%rowtype;
    obj                 json_object_t;
    cursor c1 is
           select coduser,TO_CHAR(dteupd, 'dd/mm/yyyy')as dteupd,codincom1,codincom2,codincom3,codincom4,codincom5,
                codincom6,codincom7,codincom8,codincom9,codincom10,
                codretro1,codretro2,codretro3,codretro4,codretro5,
                codretro6,codretro7,codretro8,codretro9,codretro10
           from tcontpms
          where codcompy = p_codcompy
            and dteeffec <= p_dteeffec ;

   cursor c_foundcount is
        select count(*) as found_count
        from tcontpms
        where codcompy = p_codcompy
        and trunc(dteeffec) = p_dteeffec;

    cursor c_notfoundcount is
        select count(*) as notfound_count,max(dteeffec) as dteeffec
        from tcontpms
        where codcompy = p_codcompy
        and dteeffec = (
                        select max(dteeffec)
                        from tcontpms
                        where dteeffec <= p_dteeffec
                        and codcompy = p_codcompy
                    );

	begin

        if (p_codcompy is not null) then
           param_msg_error := HCM_SECUR.SECUR_CODCOMP(global_v_coduser,global_v_lang,p_codcompy);
           if(param_msg_error is not null ) then
             param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
           end if;
        end if;

		obj_row := json_object_t();
		obj_data := json_object_t();
     -- c_vfoundcount
    for r1 in c_foundcount loop
        v_found_count := r1.found_count;
        exit;
    end loop;

    -- c_vnotfoundcount
    for r2 in c_notfoundcount loop
        v_not_found_count := r2.notfound_count;
        v_dteeffec := r2.dteeffec;
        exit;
    end loop;


    if v_found_count > 0 then
        begin
            select * into tcontpms_rec
            from tcontpms
            where codcompy = p_codcompy and
                trunc(dteeffec) = p_dteeffec
            order by dteeffec;
            obj_data := set_index_obj_data(tcontpms_rec);
            if (p_dteeffec <  trunc(sysdate)) then

                obj_data.put('canedit',false);
                obj_data.put('warning',get_error_msg_php('HR1501',global_v_lang));
            else
                obj_data.put('flgsave','edit');
                obj_data.put('canedit',true);
            end if;
        exception when others then null;
        end;
    else
        if v_not_found_count > 0 then
            begin
                select * into tcontpms_rec
                from tcontpms
                where
                    codcompy = p_codcompy and
                    dteeffec = v_dteeffec
                order by dteeffec desc;
            exception when others then
               null;
            end;

            obj_data := set_index_obj_data(tcontpms_rec);
            if p_dteeffec >= trunc(sysdate) then
                obj_data.put('flgsave','add');
                obj_data.put('flgDisable',false);
            else
                obj_data.put('flgDisable',false);
                obj_data.put('warning',get_error_msg_php('HR1501',global_v_lang));
            end if;
        else

            obj_data.put('coderror','200');
            obj_data.put('codcompy',p_codcompy);
            obj_data.put('dteeffec',to_char(p_dteeffec, 'dd/mm/yyyy'));

            obj_data.put('flgsave','add');
            obj_data.put('flgDisable',false);
        end if;
    end if;

        --<<user37 #1447 Final Test Phase 1 V11 05/02/2021  
        if trunc(p_dteeffec) >= trunc(sysdate) then
            obj_data.put('dteeffec',to_char(p_dteeffec, 'dd/mm/yyyy'));
        end if;
        -->>user37 #1447 Final Test Phase 1 V11 05/02/2021   

        json_str_output := obj_data.to_clob;
    end;

    function set_index_obj_data(tcontpms_rec tcontpms%rowtype) return json_object_t is
    obj_data    json_object_t;
    v_codempid  varchar2(10 char) := '';
    begin

      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codcompy',tcontpms_rec.codcompy);
      obj_data.put('dteeffec',to_char(tcontpms_rec.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('codincom1',tcontpms_rec.codincom1);
      obj_data.put('codincom2',tcontpms_rec.codincom2);
      obj_data.put('codincom3',tcontpms_rec.codincom3);
      obj_data.put('codincom4',tcontpms_rec.codincom4);
      obj_data.put('codincom5',tcontpms_rec.codincom5);
      obj_data.put('codincom6',tcontpms_rec.codincom6);
      obj_data.put('codincom7',tcontpms_rec.codincom7);
      obj_data.put('codincom8',tcontpms_rec.codincom8);
      obj_data.put('codincom9',tcontpms_rec.codincom9);
      obj_data.put('codincom10',tcontpms_rec.codincom10);
      obj_data.put('codretro1',tcontpms_rec.codretro1);
      obj_data.put('codretro2',tcontpms_rec.codretro2);
      obj_data.put('codretro3',tcontpms_rec.codretro3);
      obj_data.put('codretro4',tcontpms_rec.codretro4);
      obj_data.put('codretro5',tcontpms_rec.codretro5);
      obj_data.put('codretro6',tcontpms_rec.codretro6);
      obj_data.put('codretro7',tcontpms_rec.codretro7);
      obj_data.put('codretro8',tcontpms_rec.codretro8);
      obj_data.put('codretro9',tcontpms_rec.codretro9);
      obj_data.put('codretro10',tcontpms_rec.codretro10);

      obj_data.put('dteupd',to_char(tcontpms_rec.dteupd, 'dd/mm/yyyy'));
      obj_data.put('coduser',nvl(tcontpms_rec.coduser,tcontpms_rec.codcreate));
      obj_data.put('desc_coduser',(get_temploy_name(get_codempid(nvl(tcontpms_rec.coduser,tcontpms_rec.codcreate)),global_v_lang)));
      obj_data.put('userid',(get_codempid(nvl(tcontpms_rec.coduser,tcontpms_rec.codcreate))));

      return obj_data;
    end;

	procedure updateUponRow (obj_str_codcompy in varchar2,obj_str_dteeffec in varchar2,v_rownumber in varchar2,v_income in varchar2,v_obackpay in varchar2) as
		v_found_olddata		varchar2(10 char) := 'N';
		cursor c_temploy1 is
		select * from TCONTPMS
		where codcompy = obj_str_codcompy
		and DTEEFFEC = obj_str_dteeffec;
	begin
		for r1 in c_temploy1 loop
			v_found_olddata := 'Y';
		end loop;

		if v_found_olddata = 'N' then
			insert into tcontpms (codcompy,dteeffec)values(obj_str_codcompy,obj_str_dteeffec);
		end if;
		case
            when v_rownumber = 1 then

                update tcontpms set codincom1 = v_income,codretro1 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 2 then

                update tcontpms set codincom2 = v_income
                ,codretro2 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 3 then

                update tcontpms set codincom3 = v_income
                ,codretro3 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 4 then

                update tcontpms set codincom4 = v_income
                ,codretro4 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 5 then

                update tcontpms set codincom5 = v_income
                ,codretro5 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 6 then

                update tcontpms set codincom6 = v_income
                ,codretro6 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 7 then

                update tcontpms set codincom7 = v_income
                ,codretro7 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 8 then

                update tcontpms set codincom8 = v_income
                ,codretro8 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 9 then

                update tcontpms set codincom9 = v_income
                ,codretro9 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
            when v_rownumber = 10 then

                update tcontpms set codincom10 = v_income
                ,codretro10 = v_obackpay
                where codcompy = obj_str_codcompy and dteeffec = obj_str_dteeffec;
        end case;

    end;


  procedure check_dup_codpay(v_codpay1 in varchar2, v_codpay2 in varchar2,v_codpay3 in varchar2,v_codpay4 in varchar2,
                            v_codpay5 in varchar2,v_codpay6 in varchar2,v_codpay7 in varchar2,v_codpay8 in varchar2,
                            v_codpay9 in varchar2,v_codpay10 in varchar2) as
    type tcodpay IS TABLE OF varchar2(200);
    orig tcodpay;
    tmp  tcodpay;
    begin
      orig := tcodpay(nvl(v_codpay1,'v_codpay1'), nvl(v_codpay2,'v_codpay2'), nvl(v_codpay3,'v_codpay3'),
                      nvl(v_codpay4,'v_codpay4'), nvl(v_codpay5,'v_codpay5'), nvl(v_codpay6,'v_codpay6'),
                      nvl(v_codpay7,'v_codpay7'), nvl(v_codpay8,'v_codpay8'), nvl(v_codpay9,'v_codpay9'),
                      nvl(v_codpay10,'v_codpay10'));
      tmp  := SET(orig);


      if (tmp.count <> orig.count) then
          param_msg_error := get_error_msg_php('HR2005',global_v_lang);
      end if;

  end;

  procedure save_detail (json_str_input in clob, json_str_output out clob) as
    json_obj          json_object_t;
    p_codcompy        TCONTPMS.codcompy%type;
    p_dteeffec        TCONTPMS.dteeffec%type;
    p_codincom1		    TCONTPMS.CODINCOM1%type;
    p_codincom2		    TCONTPMS.CODINCOM2%type;
    p_codincom3		    TCONTPMS.CODINCOM3%type;
    p_codincom4		    TCONTPMS.CODINCOM4%type;
    p_codincom5		    TCONTPMS.CODINCOM5%type;
    p_codincom6		    TCONTPMS.CODINCOM6%type;
    p_codincom7		    TCONTPMS.CODINCOM7%type;
    p_codincom8		    TCONTPMS.CODINCOM8%type;
    p_codincom9		    TCONTPMS.CODINCOM9%type;
    p_codincom10	    TCONTPMS.CODINCOM10%type;
		p_codretro1		    TCONTPMS.CODRETRO1%type;
    p_codretro2		    TCONTPMS.CODRETRO2%type;
    p_codretro3		    TCONTPMS.CODRETRO3%type;
    p_codretro4		    TCONTPMS.CODRETRO4%type;
    p_codretro5		    TCONTPMS.CODRETRO5%type;
    p_codretro6		    TCONTPMS.CODRETRO6%type;
    p_codretro7		    TCONTPMS.CODRETRO7%type;
    p_codretro8		    TCONTPMS.CODRETRO8%type;
    p_codretro9		    TCONTPMS.CODRETRO9%type;
    p_codretro10	    TCONTPMS.CODRETRO10%type;
	begin
		initial_value(json_str_input);
    json_obj   := json_object_t(json_str_input);

    p_codcompy      := hcm_util.get_string_t(json_obj,'codcompy');
    p_dteeffec      := to_date(hcm_util.get_string_t(json_obj,'dteeffec'),'dd/mm/yyyy');
    p_codincom1     := hcm_util.get_string_t(json_obj,'codincom1');
    p_codincom2     := hcm_util.get_string_t(json_obj,'codincom2');
    p_codincom3     := hcm_util.get_string_t(json_obj,'codincom3');
    p_codincom4     := hcm_util.get_string_t(json_obj,'codincom4');
    p_codincom5     := hcm_util.get_string_t(json_obj,'codincom5');
    p_codincom6     := hcm_util.get_string_t(json_obj,'codincom6');
    p_codincom7     := hcm_util.get_string_t(json_obj,'codincom7');
    p_codincom8     := hcm_util.get_string_t(json_obj,'codincom8');
    p_codincom9     := hcm_util.get_string_t(json_obj,'codincom9');
    p_codincom10    := hcm_util.get_string_t(json_obj,'codincom10');
    p_codretro1     := hcm_util.get_string_t(json_obj,'codretro1');
    p_codretro2     := hcm_util.get_string_t(json_obj,'codretro2');
    p_codretro3     := hcm_util.get_string_t(json_obj,'codretro3');
    p_codretro4     := hcm_util.get_string_t(json_obj,'codretro4');
    p_codretro5     := hcm_util.get_string_t(json_obj,'codretro5');
    p_codretro6     := hcm_util.get_string_t(json_obj,'codretro6');
    p_codretro7     := hcm_util.get_string_t(json_obj,'codretro7');
    p_codretro8     := hcm_util.get_string_t(json_obj,'codretro8');
    p_codretro9     := hcm_util.get_string_t(json_obj,'codretro9');
    p_codretro10    := hcm_util.get_string_t(json_obj,'codretro10');

    if check_codincom(p_codincom1) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom2) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom3) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom4) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom5) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom6) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom7) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom8) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom9) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codincom(p_codincom10) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if check_codretro(p_codretro1) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro2) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro3) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro4) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro5) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro6) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro7) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro8) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro9) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    if check_codretro(p_codretro10) = false then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    check_dup_codpay(p_codincom1,p_codincom2,p_codincom3,p_codincom4,p_codincom5,p_codincom6,p_codincom7,p_codincom8,p_codincom9,p_codincom10);
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    check_dup_codpay(p_codretro1,p_codretro2,p_codretro3,p_codretro4,p_codretro5,p_codretro6,p_codretro7,p_codretro8,p_codretro9,p_codretro10);
    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    begin
      insert into tcontpms (codcompy,dteeffec,codcreate,
                            codincom1,codincom2,codincom3,codincom4,codincom5,
                            codincom6,codincom7,codincom8,codincom9,codincom10,
                            codretro1,codretro2,codretro3,codretro4,codretro5,
                            codretro6,codretro7,codretro8,codretro9,codretro10)
				values(p_codcompy,p_dteeffec,global_v_coduser,
                            p_codincom1,p_codincom2,p_codincom3,p_codincom4,
                            p_codincom5,p_codincom6,p_codincom7,p_codincom8,p_codincom9,p_codincom10,
                            p_codretro1,p_codretro2,p_codretro3,p_codretro4,p_codretro5,p_codretro6,
                            p_codretro7,p_codretro8,p_codretro9,p_codretro10);
    exception when dup_val_on_index then
        update tcontpms
           set coduser =  global_v_coduser,
               codincom1 = p_codincom1,
               codincom2 = p_codincom2,
               codincom3 = p_codincom3,
               codincom4 = p_codincom4,
               codincom5 = p_codincom5,
               codincom6 = p_codincom6,
               codincom7 = p_codincom7,
               codincom8 = p_codincom8,
               codincom9 = p_codincom9,
               codincom10 = p_codincom10,
               codretro1 = p_codretro1,
               codretro2 = p_codretro2,
               codretro3 = p_codretro3,
               codretro4 = p_codretro4,
               codretro5 = p_codretro5,
               codretro6 = p_codretro6,
               codretro7 = p_codretro7,
               codretro8 = p_codretro8,
               codretro9 = p_codretro9,
               codretro10 = p_codretro10
         where codcompy  = p_codcompy
           and dteeffec  = p_dteeffec;
         end;

   if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
    else
        rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

  function check_codincom(p_codincom varchar2) return boolean is
    v_result    boolean := true;
    v_typpay    varchar2(1 char);
  begin

    if p_codincom is not null then
        begin
            select typpay into v_typpay
            from tinexinf
            where codpay = p_codincom;
        exception when others then
          null;
        end;

        if v_typpay is null or v_typpay <> '1' then
            param_msg_error := get_error_msg_php('PM0011',global_v_lang);
            v_result := false;
            return v_result;
        end if;
    end if;
    return v_result;
  end;

  function check_codretro(p_codretro varchar2) return boolean is
    v_result    boolean := true;
    v_typpay    varchar2(1 char);
  begin

    if p_codretro is not null then
        begin
            select typpay into v_typpay
            from tinexinf
            where codpay = p_codretro;
        exception when others then
          null;
        end;

        if v_typpay is null or (v_typpay <> '2' and v_typpay <> '3') then
            param_msg_error := get_error_msg_php('PM0051',global_v_lang);
            v_result := false;
            return v_result;
        end if;
    end if;
    return v_result;
  end;

	procedure saveData (json_str_input in clob, json_str_output out clob) as

		json_row		        json_object_t;
		json_obj		        json_object_t;
		obj_data		        json_object_t;
		obj_item		        json_object_t;
		obj_str_codcompy	  varchar2(100 char);
		obj_str_dteeffec    varchar2(100 char);
		new_obj_row		      json_object_t;
		new_json_obj		    json_object_t;
		v_income		        varchar2(100 char);
		v_obackpay		      varchar2(100 char);
		v_flag			        varchar2(100 char);
		v_rownumber		      varchar2(10 char);
		p_codcomp		        varchar2(100 char);
		v_agem			        varchar2(100 char);
		v_agef			        varchar2(100 char);

		count_item		          number := 0;
		count_income		        number := 0;
		count_obackpay		      number := 0;
		count_income_compy	    number := 0;
		count_obackpay_compy	  number := 0;
		count_loop		          number := 0;
		sql_str_income		      varchar2(4000 char);
		str_income		          varchar2(4000 char);
		str_count_into_income	  varchar2(4000 char);
		sql_str_obackpay	      varchar2(4000 char);
		str_obackpay		        varchar2(4000 char);
		str_count_into_obackpay	varchar2(4000 char);
		str_codempid		        varchar2(100 char);
		flag_is_null		        number := 0;
	begin

		json_obj         := json_object_t(json_str_input);
    global_v_coduser := hcm_util.get_string_t(json_obj,'p_coduser');
		str_codempid     := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
--		obj_data         := json(json_obj.get('params'));
		obj_data         := hcm_util.get_json_t(json_obj,'params');
		obj_str_codcompy := hcm_util.get_string_t(obj_data, 'codcompy');
		obj_str_dteeffec := to_date(hcm_util.get_string_t(obj_data,'dteeffec'), 'ddmmyyyy');
--		obj_item         := json(obj_data.get('item'));
		obj_item         := hcm_util.get_json_t(obj_data,'item');

        begin
            select count(CODCOMPY) into count_item
            from tcontpms
            where CODCOMPY = obj_str_codcompy
            and DTEEFFEC = obj_str_dteeffec;
        exception when no_data_found then
            count_item := null;
        end;


		if count_item = 0 then
			v_flag := 'add';
		else
			v_flag := 'update';
		end if;

		new_json_obj    := json_object_t();
		new_obj_row     := json_object_t();

		for i in 0..obj_item.get_size-1 loop
			json_row    := json_object_t();
--			json_row    := json(obj_item.get(to_char(i)));
			json_row    := hcm_util.get_json_t(obj_item,to_char(i));
			v_income    := hcm_util.get_string_t(json_row, 'p_income');
			v_obackpay  := hcm_util.get_string_t(json_row, 'p_obackpay');
			p_codcomp   := hcm_util.get_string_t(json_row, 'p_codcomp');
			v_rownumber := hcm_util.get_string_t(json_row, 'rownumber');

--			v_agef := hcm_util.get_string_t(json_row, 'p_agef');
--			v_agem := hcm_util.get_string_t(json_row, 'p_agem');

            if v_income IS NOT NULL then
                flag_is_null := 1;
                begin
                    select count(codpay) into count_income from TINEXINF where codpay = v_income;
                exception when no_data_found then
                    count_income := null;
                end;
                begin
                    select count(codpay) into count_obackpay from TINEXINF where codpay = v_obackpay;
                exception when no_data_found then
                    count_obackpay := null;
                end;


                if v_income IS NOT NULL AND v_obackpay IS NOT NULL then
                    if count_income = 0 or count_obackpay = 0 then
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
                        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                        return;
                    end if;
                end if;
                begin
                    select count(codpay) into count_income_compy from TINEXINFC where CODCOMPY = obj_str_codcompy and CODPAY = v_income;
                exception when no_data_found then
                    count_income_compy := null;
                end;
                begin
                    select count(codpay) into count_obackpay_compy from TINEXINFC where CODCOMPY = obj_str_codcompy and CODPAY = v_obackpay;
                exception when no_data_found then
                    count_obackpay_compy := null;
                end;
                if v_income IS NOT NULL AND v_obackpay IS NOT NULL then
                    if count_income_compy = 0 or count_obackpay_compy = 0 then
                        param_msg_error := get_error_msg_php('PY0044',global_v_lang);
                        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                        return;
                    end if;
                end if;

                if v_income IS NOT NULL then
                    new_obj_row := json_object_t();
                    new_obj_row.put('income', v_income);
                    new_obj_row.put('obackpay', v_obackpay);
                    new_json_obj.put(to_char(count_loop+1), new_obj_row);
                    count_loop := count_loop+1;
                end if;
            end if;

		end loop;
		if flag_is_null > 0 then
			sql_str_income := 'select nvl(sum(count(income)),''0'') from ( ';
			sql_str_obackpay := 'select nvl(sum(count(obackpay)),''0'') from ( ';
			for i in 0..new_json_obj.get_size-1 loop
				json_row := json_object_t();
				json_row := json_object_t(hcm_util.get_string_t(new_json_obj,to_char(i+1)));
				v_income := hcm_util.get_string_t(json_row, 'income');
				v_obackpay := hcm_util.get_string_t(json_row, 'obackpay');

				if i = new_json_obj.get_size-1 then
					str_income := 'select '''||v_income|| '''as income from dual ';
					str_obackpay := 'select '''||v_obackpay|| '''as obackpay from dual ';
				else
					str_income := 'select '''||v_income|| '''as income from dual union all ';
					str_obackpay := 'select '''||v_obackpay|| '''as obackpay from dual union all ';
				end if;
				sql_str_income := concat(sql_str_income,str_income);
				sql_str_obackpay := concat(sql_str_obackpay,str_obackpay);
			end loop;

			sql_str_income := concat(sql_str_income,') group by income having count(income) > 1');
			sql_str_obackpay := concat(sql_str_obackpay,') group by obackpay having count(obackpay) > 1');

			execute immediate sql_str_income into str_count_into_income;
			execute immediate sql_str_obackpay into str_count_into_obackpay;
		end if;

		if str_count_into_income > 0 or str_count_into_obackpay > 0 then
			param_msg_error := get_error_msg_php('HR2005',global_v_lang);
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
			return;
		else
			if v_flag = 'add' then
				insert into tcontpms (codcompy,dteeffec,CODCREATE)
				values(obj_str_codcompy,obj_str_dteeffec,global_v_coduser);
			else if v_flag = 'update' then
				update tcontpms set codincom1 = null,
				codincom2   = null,
				codincom3   = null,
				codincom4   = null,
				codincom5   = null,
				codincom6   = null,
				codincom7   = null,
				codincom8   = null,
				codincom9   = null,
				codincom10  = null,
				codretro1   = null,
				codretro2   = null,
				codretro3   = null,
				codretro4   = null,
				codretro5   = null,
				codretro6   = null,
				codretro7   = null,
				codretro8   = null,
				codretro9   = null,
				codretro10  = null,
				CODUSER     = global_v_coduser
				where codcompy = obj_str_codcompy
        and dteeffec = obj_str_dteeffec;
			end if;
		end if;

		for i in 0..new_json_obj.get_size-1 loop
			json_row    := json_object_t();
			json_row    := json_object_t(hcm_util.get_string_t(new_json_obj,to_char(i+1)));
			v_income    := hcm_util.get_string_t(json_row, 'income');
			v_obackpay  := hcm_util.get_string_t(json_row, 'obackpay');

			updateUponRow(obj_str_codcompy,obj_str_dteeffec,i+1,v_income,v_obackpay);
		end loop;

	end if;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);

    end;



end HRPMB8E;

/

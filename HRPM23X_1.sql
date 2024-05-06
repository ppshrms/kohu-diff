--------------------------------------------------------
--  DDL for Package Body HRPM23X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM23X" AS
-- 4/05/2019
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := get_codempid(global_v_coduser);

    p_codcomp    := hcm_util.get_string_t(json_obj,'codcomp');
    p_codmov    := hcm_util.get_string_t(json_obj,'codmov');
    p_codmovdetail    := hcm_util.get_string_t(json_obj,'codmovdetail');
    p_dtestr    := to_date(hcm_util.get_string_t(json_obj,'dtestr'), 'dd/mm/yyyy');
    p_dteend    := to_date(hcm_util.get_string_t(json_obj,'dteend'), 'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  END initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_index(json_str_output);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    v_secur            boolean;
    v_flgpass          boolean;
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);
    obj_json           json_object_t;
    v_codcomp          number;
    get_codcomp        temploy1.codcomp%type;
    get_codpos         temploy1.codpos%type;
    v_Stmt             VARCHAR2(500);
    v_Stmt0            VARCHAR2(500);
    v_Stmt1            VARCHAR2(2000);
    cursor1            SYS_REFCURSOR;
    v_chksecu          varchar(1);
    v_DTEEFFEC         thismove.DTEEFFEC%type;
    v_data             varchar(1);
    v_zupdsal          varchar(1 char);

    cursor datarows is
      select a.codcomp, a.codempid, a.dtereemp, a.codnewid ,a.numreqst ,
             a.staupd,numlvl,a.flgmove,a.rowid,a.codpos,a.FLGREEMP,a.codexemp,a.typpayroll,a.codcurr
        from ttrehire a
       where a.codcomp like nvl ('%'||p_codcomp||'%',a.codcomp )
         and ((a.flgmove = p_codmov and p_codmov <> 'A') or (p_codmov = 'A'))
         and ((a.staupd = p_codmovdetail and p_codmovdetail <> 'A') or (p_codmovdetail = 'A'))
         and (a.dtereemp between p_dtestr and p_dteend  or p_dtestr  is null )
      order by a.dtereemp,a.codcomp, a.codempid;

    begin
    select count(*) into v_codcomp
    from tcenter
    where codcomp like '%'||p_codcomp||'%' 
    and rownum = 1;
    v_rcnt := 0;
    v_secur := secur_main.secur7(p_codcomp,global_v_coduser);
    if (p_dtestr is null OR p_dteend  is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return ;
    elsif (p_dtestr > p_dteend) then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return ;
    elsif v_codcomp = '0' then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return ;
    elsif p_codcomp is not null and v_secur = false then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return ;
    end if ;

    obj_row := json_object_t();
    v_rcnt := 0;

    for i in datarows loop
      v_flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if(v_flgpass) then
        obj_data := json_object_t();
        v_rcnt := v_rcnt + 1;
        obj_data.put('codempid',i.codempid);
        obj_data.put('name',get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp',get_tcenter_name(i.codcomp ,global_v_lang));
        obj_data.put('codpos',get_tpostn_name(i.codpos , global_v_lang));
        obj_data.put('dtereemp',To_char(i.dtereemp, 'dd/mm/yyyy'));
        obj_data.put('codnewid',i.codnewid);
        obj_data.put('flgreem', GET_TLISTVAL_NAME ('NAMREHIR', i.FLGREEMP, global_v_lang));
        obj_data.put('staupd', GET_TLISTVAL_NAME ('NAMMSTAT', i.staupd, global_v_lang));
        obj_data.put('flgmove',GET_TLISTVAL_NAME ('TYPREHIRE', i.FLGMOVE, global_v_lang) );
        obj_data.put('fullcodcomp',i.codcomp);
        obj_data.put('codexemp',i.codexemp);
        obj_data.put('typpayroll',i.typpayroll);
        obj_data.put('codcurr',i.codcurr);
        begin
          select max(DTEEFFEC) into v_DTEEFFEC
            from thismove b
           where b.codempid = i.codempid
             and b.dteeffec < i.dtereemp;
        end;

        begin
          select a.codcomp,a.codpos into get_codcomp,get_codpos
            from thismove a
           where codempid = i.codempid
             and dteeffec = v_DTEEFFEC
             and numseq = (select max(b.numseq)
                             from thismove b
                            where b.codempid = a.codempid
                              and b.dteeffec = v_DTEEFFEC);
        EXCEPTION WHEN no_data_found THEN
          get_codcomp := i.codcomp;
          get_codpos :=  i.codpos;
        END;
        obj_data.put('codcomp_old',get_tcenter_name(get_codcomp ,global_v_lang));
        obj_data.put('codcos_old',get_tpostn_name(get_codpos , global_v_lang));
        obj_data.put('coderror','200');

        obj_row.put(to_char(v_rcnt), obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_index;

  PROCEDURE Get_detail (json_str_input  IN CLOB, json_str_output OUT CLOB) IS
    json_obj json_object_t;
  BEGIN
    Initial_value(json_str_input);
    json_obj := json_object_t(json_str_input);

    p_detail_codempid := hcm_util.get_string_t(json_obj, 'p_codempid');
    p_dtereemp        := to_date(hcm_util.get_string_t(json_obj,'p_dtereemp'), 'dd/mm/yyyy');

    Gen_detail(json_str_output);

  END get_detail;
  PROCEDURE Gen_detail (json_str_output OUT CLOB) IS
    v_rcnt            NUMBER;
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_yearnow         NUMBER;
    v_monthnow        NUMBER;
    v_yearbirth       NUMBER;
    v_monthbirth      NUMBER;
    obj_row2          json_object_t;
    v_datasal         CLOB;
    obj_data_salary   json_object_t;
    cnt_row			      NUMBER := 0;
    v_row			        NUMBER := 0;
    param_json_row    json_object_t;
     TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        v_amtincom          p_num;
        v_codempid    ttrehire.codempid%type;
        v_codempmt    ttrehire.codempmt%type;
        v_codcomp     ttrehire.codcomp%type;
    obj_sum           json_object_t;
    v_numoffid        temploy2.numoffid%TYPE;
    v_findemp         VARCHAR(50);
    flg_data          BOOLEAN := FALSE;
    codincom_dteeffec VARCHAR(321);
    codincom_codempmt VARCHAR(321);
    DATENOW           VARCHAR(321);
    v_listfilter      json_object_t ;
    v_amtothr_income	NUMBER;
		v_amtday_income		NUMBER;
		v_sumincom_income	NUMBER;
    param_codcomp     temploy1.codcomp%type;
    v_codincom		    tinexinf.codpay%TYPE;
		v_desincom		    tinexinf.descpaye%TYPE;
    v_itemfilter      json_object_t ;
    v_itemclonevalue  json_object_t;
    CURSOR tbdata IS
      SELECT a.*,
             a.dteduepr - a.dtereemp daytest
      FROM   ttrehire a
      WHERE  codempid = p_detail_codempid
        and dtereemp = p_dtereemp;
  BEGIN

    begin
      SELECT numoffid
      INTO   v_numoffid
      FROM   temploy2
      WHERE  codempid = p_detail_codempid;
    exception when no_data_found then
      v_numoffid := null;
    end;

    begin
      SELECT Count(*)
      INTO   v_findemp
      FROM   tbcklst
      WHERE  numoffid = v_numoffid;
    exception when no_data_found then
      v_findemp := null;
    end;
      /*if v_FindEmp <> 0 then
      param_msg_error := get_error_msg_php('HR2006',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
      end if;*/
      obj_row := json_object_t();

      v_rcnt := 0;

      FOR r1 IN tbdata LOOP
          obj_data := json_object_t();

          flg_data := TRUE;

          obj_data.Put('coderror', '200');

          obj_data.Put('daytest', r1.daytest);

          obj_data.Put('flgmov', r1.flgmove);

          obj_data.Put('codempmt', r1.codempmt);

          obj_data.Put('datetrans', To_char(r1.dtereemp, 'dd/mm/yyyy'));

          obj_data.Put('codpos', r1.codpos);

          obj_data.Put('flgtaemp', r1.staemp);

          obj_data.Put('glcode', r1.codgrpgl);

          obj_data.Put('groupemp', r1.codcalen);

          obj_data.Put('CODJOB', r1.codjob);

          obj_data.Put('jobgrade', r1.jobgrade);

          obj_data.Put('location', r1.codbrlc);

          obj_data.Put('lving', r1.numlvl);

          obj_data.Put('namrhir', r1.flgreemp);

          obj_data.Put('namstamp', r1.typemp);

          obj_data.Put('newcodempid', r1.codnewid);

          obj_data.Put('operator', r1.codsend);

          obj_data.Put('codcomp', r1.codcomp);

          obj_data.Put('codcurr', r1.codcurr);

          obj_data.Put('codcomp_name', get_tcenter_name(r1.codcomp ,global_v_lang));

          obj_data.Put('refnumber', r1.numreqst);

          obj_data.Put('savetime', r1.flgatten);

          obj_data.Put('keycodempid', r1.codempid);

          obj_data.Put('idp', r1.codempid);

          v_rcnt := v_rcnt + 1;
          param_codcomp := hcm_util.get_codcomp_level(r1.codcomp,1);
          obj_row.Put(0, obj_data);
      END LOOP;

     begin
      SELECT To_char((SELECT Max(dteeffec)
                      FROM   tcontpms
                      WHERE  codcompy = hcm_util.get_codcomp_level(param_codcomp,1)), 'ddmmyyyy'),
             codempmt
      INTO   codincom_dteeffec, codincom_codempmt
      FROM   temploy1
      WHERE  codempid = p_detail_codempid;
      exception when no_data_found then
      codincom_dteeffec := sysdate;
      codincom_codempmt := null;
      end;
    SELECT hcm_pm.Get_codincom('{"p_codcompy":'''||param_codcomp||''',"p_dteeffec":'''||codincom_dteeffec||''',"p_codempmt":'''||codincom_codempmt||''',"p_lang":'''||global_v_lang||'''}')
    into v_datasal
      FROM   dual;

     v_listfilter := json_object_t(v_datasal);
      v_itemfilter := json_object_t();

     FOR i IN 0..v_listfilter.get_size-1 LOOP
				param_json_row := hcm_util.Get_json_t(v_listfilter, To_char(i));
				v_desincom := hcm_util.Get_string_t(param_json_row, 'desincom');
				if v_desincom is null or v_desincom = '   ' then
					exit;
				else
					cnt_row := cnt_row + 1;
				end if;
			end loop;

        BEGIN
			SELECT codempid,
			codempmt,
			codcomp,
			Stddec(amtincom1, codempid, global_v_chken),
			Stddec(amtincom2, codempid, global_v_chken),
			Stddec(amtincom3, codempid, global_v_chken),
			Stddec(amtincom4, codempid, global_v_chken),
			Stddec(amtincom5, codempid, global_v_chken),
			Stddec(amtincom6, codempid, global_v_chken),
			Stddec(amtincom7, codempid, global_v_chken),
			Stddec(amtincom8, codempid, global_v_chken),
			Stddec(amtincom9, codempid, global_v_chken),
			Stddec(amtincom10, codempid, global_v_chken)

			INTO v_codempid, v_codempmt, v_codcomp, V_amtincom(1),
			V_amtincom(2), V_amtincom(3), V_amtincom(4), V_amtincom(5),
			V_amtincom(6), V_amtincom(7), V_amtincom(8), V_amtincom(9), V_amtincom(10)
			FROM ttrehire where codempid = p_detail_codempid and dtereemp = p_dtereemp;


		EXCEPTION
		WHEN no_data_found THEN
			for i in 1..10 loop
                V_amtincom(i) := 0;
            end loop;

		END;

            FOR i IN 0..cnt_row-1 LOOP
				param_json_row := hcm_util.Get_json_t(v_listfilter, To_char(i));

				v_row := v_row + 1;
				obj_data_salary := json_object_t();

				obj_data_salary.Put('coderror', '200');
				obj_data_salary.Put('codincom', hcm_util.Get_string_t(param_json_row, 'codincom'));

				obj_data_salary.Put('desincom', hcm_util.Get_string_t(param_json_row, 'desincom'));
				obj_data_salary.Put('desunit', hcm_util.Get_string_t(param_json_row, 'desunit'));

				obj_data_salary.Put('amtmax', V_amtincom(i+1));
				v_itemfilter.Put(v_row, obj_data_salary);
			END LOOP;



        Get_wage_income(param_codcomp, codincom_codempmt, V_amtincom(1),
			V_amtincom(2), V_amtincom(3), V_amtincom(4), V_amtincom(5),
			V_amtincom(6), V_amtincom(7), V_amtincom(8), V_amtincom(9), V_amtincom(10), v_amtothr_income, v_amtday_income, v_sumincom_income);

      obj_sum := json_object_t();

      obj_sum := json_object_t();

      obj_sum.Put('t1', obj_data);
      obj_sum.Put('t2', v_itemfilter);
      obj_sum.Put('v_amtothr_income', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
      obj_sum.Put('v_amtday_income', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
      obj_sum.Put('v_sumincom_income', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
      param_msg_error := Get_error_msg_php('HR2401', global_v_lang);

      obj_sum.Put('response', param_msg_error);

      obj_sum.Put('coderror', '200');


      json_str_output := obj_sum.To_clob;
  END gen_detail;

  procedure init_report(json_str_input in clob) as
    v_objrow json_object_t;
    v_objrowparams  json_object_t;
  begin
    v_objrow := json_object_t(json_str_input);

     global_v_lang       := hcm_util.get_string_t(v_objrow,'p_lang');
     global_v_coduser    := hcm_util.get_string_t(v_objrow,'p_coduser');
     global_v_codempid := get_codempid(global_v_coduser);

    v_objrowparams := hcm_util.get_json_t(v_objrow,'p_params');
    p_datarows := hcm_util.get_json_t(v_objrowparams,'p_datarows');
    p_codapp := hcm_util.get_string_t(v_objrowparams,'p_codapp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end init_report;

  procedure get_report(json_str_input in clob, json_str_output out clob) as
  begin

      init_report(json_str_input);
      gen_report;

      if (param_msg_error is null or length(param_msg_error) = 0 ) then
          param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      end if ;

      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
 --   exception when others then
--		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  --      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_report;

  procedure gen_report as
     v_objdetail          json_object_t;
     v_in_str_objdetail   clob;
     v_out_str_objdetail  clob;
     v_objdetail_tab1     json_object_t;
     v_objdetail_tab2     json_object_t;
     v_objrow_tab2        json_object_t;
     v_out_objrow_tab     json_object_t;
     v_desc_typrehire     tlistval.desc_label%type;
     v_desc_namrhir       tlistval.desc_label%type;
     v_desc_flgstaemp     tlistval.desc_label%type;
     v_codempid           temploy1.codempid%type;
     v_desc_flgatten      tlistval.desc_label%type;
     v_running_seqreport  number:= 1;
     v_codpos             temploy1.codpos%type;
     v_codcomp            temploy1.codcomp%type;
     v_imageh             varchar2(1000 char);
     v_flgimg             varchar2(2 char) := 'N';
     v_item6		          varchar2(1000 char);
     v_item7		          varchar2(1000 char);
     v_item8		          varchar2(1000 char);
     v_item9		          varchar2(1000 char);
     v_item10		          varchar2(1000 char);
     v_item12		          varchar2(1000 char);
     v_item13		          varchar2(1000 char);
     v_item16		          varchar2(1000 char);
     v_item17		          varchar2(1000 char);
     v_item18		          varchar2(1000 char);
     v_item19		          varchar2(1000 char);
     v_item20		          varchar2(1000 char);
     v_item21		          varchar2(1000 char);
     v_item22		          varchar2(1000 char);
     v_item23		          varchar2(1000 char);
     v_item24		          varchar2(1000 char);
     v_item26		          varchar2(1000 char);
     v_item27		          varchar2(1000 char);
     v_item28		          varchar2(1000 char);
     v_item29		          varchar2(1000 char);
     v_gl_code		        varchar2(1000 char); --user56--
  begin

    delete from ttemprpt
    where codapp = 'HRPM23X'
    and codempid = global_v_codempid;

    for v_indexrow in 0..p_datarows.get_size - 1 loop
      v_objdetail := hcm_util.get_json_t(p_datarows,v_indexrow);
      v_codempid := hcm_util.get_string_t(v_objdetail, 'codempid');
      v_in_str_objdetail := '{';
      v_in_str_objdetail  := v_in_str_objdetail||'"p_codempid":'||'"'||v_codempid|| '"'||',';
      v_in_str_objdetail  := v_in_str_objdetail||'"p_dtereemp":'||'"'||hcm_util.get_string_t(v_objdetail, 'dtereemp')|| '"'||',';
      v_in_str_objdetail  := v_in_str_objdetail||'"p_coduser":'||'"'||global_v_coduser||'"'||',';
      v_in_str_objdetail  := v_in_str_objdetail||'"p_lang":'||'"'||global_v_lang||'"';
      v_in_str_objdetail := v_in_str_objdetail|| '}';

      get_detail (v_in_str_objdetail, v_out_str_objdetail);


      v_out_objrow_tab := json_object_t(v_out_str_objdetail);


      v_objdetail_tab1 := hcm_util.get_json_t(v_out_objrow_tab,'t1');
      v_objdetail_tab2 := hcm_util.get_json_t(v_out_objrow_tab,'t2');

      v_desc_typrehire := get_tlistval(
                                      global_v_lang,
                                      hcm_util.get_string_t(v_objdetail_tab1,'flgmov'),
                                      'TYPREHIRE');
      v_desc_namrhir := get_tlistval(
                                      global_v_lang,
                                      hcm_util.get_string_t(v_objdetail_tab1,'namrhir'),
                                      'NAMREHIR');

      v_desc_flgstaemp := get_tlistval(
                                      global_v_lang,
                                      hcm_util.get_string_t(v_objdetail_tab1,'flgtaemp'),
                                      'FLGSTAEMP');

      v_desc_flgatten := get_tlistval(
                                      global_v_lang,
                                      hcm_util.get_string_t(v_objdetail_tab1,'savetime'),
                                      'NAMSTAMP');

       begin
                select codpos,codcomp into v_codpos,v_codcomp
                from temploy1
                where codempid = v_codempid;
       exception
               when no_data_found then
               v_codpos := '';
               v_codcomp := '';
       end;

       begin
          select namimage
           into v_imageh
           from tempimge
           where codempid = v_codempid
          and namimage is not null;
           v_flgimg := 'Y';
        exception when no_data_found then
          v_imageh := '';
          v_flgimg := 'N';
        end;
       if v_imageh is not null then
        v_imageh  := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
       end if;
       v_item6 := hcm_util.GET_DATE_BUDDHIST_ERA(to_date(hcm_util.get_string_t(v_objdetail, 'dtereemp'),'dd/mm/yyyy'));
       v_item7 := hcm_util.get_string_t(v_objdetail_tab1,'newcodempid');
       v_item8 := hcm_util.get_string_t(v_objdetail_tab1,'refnumber');
       v_item10 := concat(hcm_util.get_string_t(v_objdetail_tab1,'daytest'),' '||get_label_name('HRPM23X2',global_v_lang,350));
       v_item12 := concat(concat(hcm_util.get_string_t(v_objdetail_tab1,'operator'),' - '),get_temploy_name(hcm_util.get_string_t(v_objdetail_tab1,'operator'),global_v_lang));
       v_item13 := get_tcodec_name('tcodexem',hcm_util.get_string_t(v_objdetail,'codexemp'),global_v_lang);
       v_item16 := hcm_util.get_string_t(v_objdetail,'fullcodcomp');
       v_item17 := concat(concat(hcm_util.get_string_t(v_objdetail_tab1,'location'),' - '),get_tcodloca_name(hcm_util.get_string_t(v_objdetail_tab1,'location'),global_v_lang));
       v_item18 := concat(concat(hcm_util.get_string_t(v_objdetail_tab1,'codempmt'),' - '),get_tcodec_name('tcodempl',hcm_util.get_string_t(v_objdetail_tab1,'codempmt'),global_v_lang));
       v_item19 := concat(concat(hcm_util.get_string_t(v_objdetail,'typpayroll'),' - '),get_tcodec_name('tcodtypy',hcm_util.get_string_t(v_objdetail,'typpayroll'),global_v_lang) );
       v_item20 := concat(concat (hcm_util.get_string_t(v_objdetail_tab1,'namstamp'),' - '),get_tcodec_name('tcodcatg',hcm_util.get_string_t(v_objdetail_tab1,'namstamp'),global_v_lang));
       v_item21 := concat(concat (hcm_util.get_string_t(v_objdetail_tab1,'groupemp'),' - '),get_tcodec_name('tcodwork',hcm_util.get_string_t(v_objdetail_tab1,'groupemp'),global_v_lang));
       v_item22 := concat(concat (hcm_util.get_string_t(v_objdetail_tab1,'CODJOB'),' - '),get_tjobcode_name(hcm_util.get_string_t(v_objdetail_tab1,'CODJOB'),global_v_lang));
       v_item23 := concat(concat (hcm_util.get_string_t(v_objdetail_tab1,'jobgrade'),' - '), get_tcodec_name('tcodjobg',hcm_util.get_string_t(v_objdetail_tab1,'jobgrade'),global_v_lang));
       v_item24 := hcm_util.get_string_t(v_objdetail_tab1,'lving');
       v_item26 := concat(concat(hcm_util.get_string_t(v_objdetail_tab1,'codcurr'),' - '), get_tcodec_name('tcodcurr',hcm_util.get_string_t(v_objdetail_tab1,'codcurr'),global_v_lang) );
       v_item27 := hcm_util.get_string_t(v_out_objrow_tab,'v_amtothr_income');
       v_item28 := hcm_util.get_string_t(v_out_objrow_tab,'v_amtday_income');
       v_item29 := hcm_util.get_string_t(v_out_objrow_tab,'v_sumincom_income');
       v_gl_code := concat(concat (hcm_util.get_string_t(v_objdetail_tab1,'glcode'),' - '), get_tcodec_name('tcodjobg',hcm_util.get_string_t(v_objdetail_tab1,'glcode'),global_v_lang));

       insert into ttemprpt (
       CODEMPID,CODAPP,NUMSEQ,
       ITEM1,ITEM2,ITEM3,
       ITEM4 ,ITEM5,ITEM6,
       ITEM7,ITEM8,ITEM9,
       ITEM10,ITEM11,ITEM12,
       ITEM13,ITEM14,ITEM15,
       ITEM16,ITEM17,ITEM18,
       ITEM19,ITEM20,ITEM21,
       ITEM22,ITEM23,ITEM24,
       ITEM25,ITEM26,ITEM27,
       ITEM28,ITEM31,ITEM32,
       ITEM33
       ) values (
       global_v_codempid,'HRPM23X',v_running_seqreport,
       'HEAD',
       get_temploy_name(v_codempid,global_v_lang),
       v_codempid,
       v_desc_typrehire,
  --                         get_dteempmt(global_v_lang,v_codempid),
       v_item6,
       v_item7,
       v_item8,
       v_desc_namrhir,
       v_item10,
       v_desc_flgstaemp,
       v_item12,
       v_item13,
       get_tcenter_name(v_codcomp,global_v_lang),
       concat(concat(v_codpos,' - '),get_tpostn_name(v_codpos,global_v_lang)),
       v_item16,
       v_item17,
       v_item18,
       v_item19,
       v_item20,
       v_item21,
       v_item22,
       v_item23,
       v_item24,
       v_desc_flgatten,
       v_item26,
       v_item27,
       v_item28,
       v_item29,
  --                        'file_uploads'||'/'|| get_tfolderd('HRPM23X') ||'/'||get_emp_img(v_codempid)
      v_imageh,v_flgimg,
      v_gl_code
      );
      v_running_seqreport := v_running_seqreport + 1;

      for v_indexrowtab2 in 1..v_objdetail_tab2.get_size
      loop

          v_objrow_tab2 := hcm_util.get_json_t(v_objdetail_tab2,v_indexrowtab2);

           v_item6 := hcm_util.get_string_t(v_objrow_tab2,'codincom');
           v_item7 := hcm_util.get_string_t(v_objrow_tab2,'desincom');
           v_item8 := hcm_util.get_string_t(v_objrow_tab2,'desunit');
--           v_item9 := hcm_util.get_string_t(v_objrow_tab2,'amtmax');
           v_item9 := nvl(to_char(hcm_util.get_string_t(v_objrow_tab2, 'amtmax'), 'fm999,999,990.00'), ' ');

           insert into ttemprpt (
                  codempid,codapp,numseq,
                  item1,item2,item3,
                  item4,item5,item6,
                  item7
                  ) values (
           global_v_codempid,'HRPM23X',v_running_seqreport,
           'DETAIL',
           v_indexrowtab2,
           v_item6,
           v_item7,
           v_item8,
           v_item9,
           v_codempid);

           v_running_seqreport := v_running_seqreport + 1;

      end loop;

    end loop;

     --exception when others then
	--	param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_report;

  function get_dteempmt(global_v_lang in varchar2,v_codempid in varchar2)  return varchar2 is
  v_dteempmt temploy1.dteempmt%type;
  begin
        begin
                select dteempmt into v_dteempmt
                from temploy1
                where codempid  = v_codempid;

                return display_year(global_v_lang,v_dteempmt);
                  exception when no_data_found then
                return '';
        end ;
  end get_dteempmt;


  function get_tlistval (global_v_lang in varchar2, v_where_value in varchar2, v_codapp in varchar2) return varchar2 is
    v_desc_label tlistval.desc_label%type;
  begin
        begin
            select desc_label into v_desc_label
              from tlistval
             where lower(codapp) = lower(v_codapp)
             and codlang = global_v_lang
             and list_value = v_where_value
            order by codlang, numseq;

            return v_desc_label;
          exception when no_data_found then
                return '';
        end ;
  end get_tlistval ;


  function display_year(global_v_lang in varchar2,v_date in date) return varchar2 is
  v_out_number_year number;
  v_out_str_day varchar2 (2 char);
  v_out_str_month varchar2 (2 char);
  v_out_str_year varchar2 (4 char);
  begin
                v_out_str_day := to_char(v_date,'dd');
                v_out_str_month :=  to_char(v_date,'mm');
                v_out_str_year := to_char(v_date,'yyyy');

                v_out_number_year := (to_number(v_out_str_year))  + HCM_APPSETTINGS.get_additional_year ;

                return  v_out_str_day||'/'||v_out_str_month||'/'||v_out_number_year;
  end display_year;

END HRPM23X;

/

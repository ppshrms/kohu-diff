--------------------------------------------------------
--  DDL for Package Body HRPM21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM21E" AS
 PROCEDURE Initial_value (json_str IN CLOB) IS
    json_obj JSON_object_t;
  BEGIN
      json_obj := JSON_object_t(json_str);

      flgContinue         := hcm_util.Get_string_t(json_obj, 'flgContinue');
      p_typpayroll        := hcm_util.Get_string_t(json_obj, 'typpayroll');
      global_v_lang       := hcm_util.Get_string_t(json_obj, 'p_lang');
      global_v_coduser    := hcm_util.Get_string_t(json_obj, 'p_coduser');
      global_v_codempid   := hcm_util.Get_string_t(json_obj, 'p_codempid');
      p_codcompindex      := SUBSTR(hcm_util.Get_string_t(json_obj,'p_codcompindex'), 1, 3);
      p_codmov            := hcm_util.Get_string_t(json_obj, 'codmov');
      p_codcomp           := hcm_util.Get_string_t(json_obj, 'codcomp');
      p_codempid          := hcm_util.Get_string_t(json_obj, 'codempid');
      p_datestrart        := To_date(hcm_util.Get_string_t(json_obj, 'datestrart'),'dd/mm/yyyy');
      p_dateend           := To_date(hcm_util.Get_string_t(json_obj, 'dateend'),'dd/mm/yyyy');
      pa_flgmove           := hcm_util.Get_string_t(json_obj, 'pa_flgmove');

      p_flgmove           := hcm_util.Get_string_t(json_obj, 'flgmove');
      p_keycodempid       := hcm_util.Get_string_t(json_obj, 'keycodempid');
      p_newcodempid       := hcm_util.Get_string_t(json_obj, 'newcodempid');
      p_flgtaemp          := hcm_util.Get_string_t(json_obj, 'flgtaemp');
      p_datetrans         := To_date(hcm_util.Get_string_t(json_obj, 'datetrans'),'dd/mm/yyyy');
      p_datetranso        := To_date(hcm_util.Get_string_t(json_obj, 'datetranso'),'dd/mm/yyyy');
      p_daytest           := hcm_util.Get_string_t(json_obj, 'daytest');
      p_date              := p_datetrans + p_daytest - 1;
      p_numreqst          := hcm_util.Get_string_t(json_obj, 'numreqst');
      p_codsend           := hcm_util.Get_string_t(json_obj, 'codsend');
      p_flgreemp          := hcm_util.Get_string_t(json_obj, 'flgreemp');
      p_codpos            := hcm_util.Get_string_t(json_obj, 'codpos');
      p_codbrlc           := hcm_util.Get_string_t(json_obj, 'codbrlc');
      p_codempmt          := hcm_util.Get_string_t(json_obj, 'codempmt');
      p_typemp            := hcm_util.Get_string_t(json_obj, 'typemp');
      p_codcalen          := hcm_util.Get_string_t(json_obj, 'codcalen');
      p_codjob            := hcm_util.Get_string_t(json_obj, 'codjob');
      p_jobgrade          := hcm_util.Get_string_t(json_obj, 'jobgrade');
      p_codgrpgl          := hcm_util.Get_string_t(json_obj, 'codgrpgl');
      p_numlvl            := hcm_util.Get_string_t(json_obj, 'numlvl');
      p_savetime          := hcm_util.Get_string_t(json_obj, 'savetime');
      p_idp               := hcm_util.Get_string_t(json_obj, 'idp');
      pa_codempid         := hcm_util.Get_string_t(json_obj, 'pa_codempid');
      p_flag              := hcm_util.Get_string_t(json_obj, 'p_flag');
      p_codexemp          := hcm_util.Get_string_t(json_obj, 'pa_codexemp');
      p_codcurr           := hcm_util.Get_string_t(json_obj, 'p_codcurr');
      p_objectsal         := hcm_util.get_json_t(json_obj, 'p_datasal');
      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  PROCEDURE Get_index21e (json_str_input  IN CLOB, json_str_output OUT CLOB) IS
    v_chk_deprived NUMBER;
  BEGIN
      Initial_value(json_str_input);
      if p_codmov = 'T' then

          SELECT Count(*)
            INTO v_chk_deprived
            FROM temploy1
           WHERE codempid = p_codempid
             AND staemp = 9;

          /*User37 #5678 1.PM Module 19/04/2021 IF ( v_chk_deprived >= 1 ) THEN
            param_msg_error := get_error_msg_php('HR2101', global_v_lang);
            json_str_output := Get_response_message(null, param_msg_error,global_v_lang);
            return ;
          end if;*/
      end if;

      IF (( p_datestrart IS NOT NULL AND p_dateend IS NULL )OR ( p_datestrart IS NULL AND p_dateend IS NOT NULL ) ) THEN
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
        RETURN;
      ELSIF ( p_datestrart > p_dateend ) THEN
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
        RETURN;
--      ELSIF ( v_chk_deprived >= 1 ) THEN
--        param_msg_error := get_error_msg_php('HR2101', global_v_lang);
--        json_str_output := Get_response_message(null, param_msg_error,global_v_lang);
--        return ;
      elsif (p_codcomp is null AND p_codempid is null) then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        json_str_output := Get_response_message('403', param_msg_error,global_v_lang);
        RETURN;
      END IF;
      Gen_index21e(json_str_output);
  END get_index21e;

  PROCEDURE Gen_index21e (json_str_output OUT CLOB) IS
    obj_row         JSON_object_t;
    obj_data        JSON_object_t;
    v_rcnt          NUMBER;
    flgsecur        boolean := false;

    v_Stmt          VARCHAR2(500);
    v_Stmt0         VARCHAR2(500);
    v_Stmt1         VARCHAR2(500);
    v_Update        VARCHAR2(500);
    cursor1         SYS_REFCURSOR;
    col_dtereemp    ttrehire.dtereemp%type;
    col_codempid    ttrehire.codempid%type;
    col_codnewid    ttrehire.codnewid%type;
    col_numreqst    ttrehire.numreqst%type;
    col_codcomp     ttrehire.codcomp%type;
    col_codpos      ttrehire.codpos%type;
    col_staupd      ttrehire.staupd%type;
    col_flgmove      ttrehire.flgmove%type;
  BEGIN
    v_Stmt := 'select dtereemp, codempid, codnewid, numreqst, codcomp, codpos, staupd, flgmove
                 from ttrehire
                where codempid is not null' ;
    IF(p_codempid is not null) then
        v_Stmt0 := ' AND codempid = '''||p_codempid||'''  ';
    END IF;
    IF(p_codcomp is not null) then
        v_Stmt0 := ' AND codcomp LIKE ''%' || p_codcomp || '%''';
    END IF;
    IF(p_codmov is not null and p_codmov <> 'A') then
        v_Stmt0 := v_Stmt0 || ' AND flgmove = '''|| p_codmov ||''' ';
    END IF;
    IF(p_datestrart is not null ) and (p_dateend is not null) then
        v_Stmt0 := v_Stmt0 || ' AND dtereemp BETWEEN to_date('''|| p_datestrart ||''',''YYYY-MM-DD HH24:MI:SS'') AND  to_date('''|| p_dateend ||''',''YYYY-MM-DD HH24:MI:SS'')  ';
    END IF;

    v_Update  := ' order by codempid, dtereemp';
    v_Stmt1   :=  v_Stmt || v_Stmt0 || v_Update;
    obj_row   := JSON_object_t();
    v_rcnt    := 0;
    open cursor1 for
      v_Stmt1;
    LOOP
      FETCH  cursor1 into col_dtereemp,
                          col_codempid,
                          col_codnewid,
                          col_numreqst,
                          col_codcomp,
                          col_codpos,
                          col_staupd,
                          col_flgmove;
      EXIT WHEN cursor1%NOTFOUND;
      flgsecur := secur_main.secur2(col_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if flgsecur then
        obj_data   := JSON_object_t();
        obj_data.Put('dtereemp', To_char(col_dtereemp, 'dd/mm/yyyy'));
        obj_data.Put('codempid', col_codempid);
        obj_data.Put('codnewid', col_codnewid);
        obj_data.Put('namelastname', Get_temploy_name(col_codempid,global_v_lang));
        obj_data.Put('numreqst', col_numreqst);
        obj_data.Put('namcentt', Get_tcenter_name(get_codcompy(col_codcomp), global_v_lang));
        obj_data.Put('codcomp', col_codcomp);
        obj_data.Put('flgmove', col_flgmove);
        obj_data.Put('nampost', Get_tpostn_name (col_codpos, global_v_lang));
        obj_data.Put('namcomp', Get_tcenter_name(col_codcomp, global_v_lang));
        obj_data.put('staupd', get_tlistval_name('STAUPD', col_staupd, global_v_lang));
        obj_data.put('staupdf', col_staupd);
        v_rcnt := v_rcnt + 1;
        obj_data.Put('coderror', '200');
        obj_data.Put('rownumber', v_rcnt);
        obj_row.put(to_char(v_rcnt), obj_data);
      end if;
    END LOOP;
    json_str_output := obj_row.To_clob;
  END gen_index21e;

  PROCEDURE Get_save_21e (json_str_input  IN CLOB,json_str_output OUT CLOB) IS
    Out_of_condition temploy1.staemp%type;
    v_count          number;
    v_staemp         temploy1.staemp%type;
    v_emp_return     number;
  BEGIN
    Initial_value(json_str_input);
    if(p_keycodempid = p_codsend) then
      param_msg_error := get_error_msg_php('PM0139',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;

     if p_flgmove = 'R' then
        --<<User37 #5470 Final Test Phase 1 V11 10/03/2021
        /*if(p_keycodempid = p_newcodempid) then
          param_msg_error := get_error_msg_php('PM0079',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;*/

        if p_newcodempid is not null then
        begin
            select count(*)
              into v_count
              from temploy1
             where codempid =  p_newcodempid;
        exception when no_data_found then
            v_count := 0;
        end;
        if v_count > 0 then
          param_msg_error := get_error_msg_php('PM0079',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;
        end if;
        -->>User37 #5470 Final Test Phase 1 V11 10/03/2021
    end if;

    --<<User37 #5470 Final Test Phase 1 V11 09/04/2021
    if p_newcodempid is not null then
        begin
            select count(*)
              into v_count
              from temploy1
             where codempid =  p_newcodempid;
        exception when no_data_found then
            v_count := 0;
        end;
        if v_count > 0 then
          param_msg_error := get_error_msg_php('PM0079',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;
    end if;
    -->>User37 #5470 Final Test Phase 1 V11 09/04/2021

    if p_flgmove = 'T' then
        begin
            select staemp into Out_of_condition
              from temploy1
             where codempid = p_keycodempid
               and staemp <> '9';
        exception when no_data_found then
             param_msg_error := get_error_msg_php('HR2101',global_v_lang);
             json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        end;

        select count(*)
          into v_count
          from temploy1
         where ocodempid =  p_keycodempid
           and ((codempid = nvl(ocodempid,codempid) and staemp <> '9')
            or codempid <> nvl(ocodempid,codempid));

        if v_count > 0 then
           -- param_msg_error := get_error_msg_php('HR2101',global_v_lang);
               param_msg_error := get_error_msg_php('HR2010',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        end if;

    end if;

    if p_flgmove = 'R' then
        begin
            select staemp into v_staemp
              from temploy1
             where codempid = p_keycodempid;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        end;
        if v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        elsif v_staemp = '1' then
            param_msg_error := get_error_msg_php('HR2103',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        elsif v_staemp = '3' then
            param_msg_error := get_error_msg_php('PM0016',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        end if;

        begin
            select count(*)
              into v_emp_return
              from temploy1
             where ocodempid =  p_keycodempid
               and ((codempid = nvl(ocodempid,codempid)and staemp = '9')
                or codempid <> nvl(ocodempid,codempid));
        end;

        if v_count > 0 then
            param_msg_error := get_error_msg_php('PM0058',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
        end if;
    end if;

    Save_data21e(json_str_output);

  END get_save_21e;
  PROCEDURE Save_data21e (json_str_output OUT CLOB)
  IS
    v_rcnt              NUMBER;
    obj_row             JSON_object_t;
    obj_data            JSON_object_t;
    v_yearnow           NUMBER;
    v_monthnow          NUMBER;
    v_yearbirth         NUMBER;
    v_monthbirth        NUMBER;
    obj_row2            JSON_object_t;
    v_datasal           CLOB;
    obj_sum             JSON_object_t;
    v_numoffid          temploy2.numoffid%TYPE;
    v_findemp           VARCHAR(50);
    flg_data            BOOLEAN := FALSE;
    v_chk_repeatedly    NUMBER;
    codincom_dteeffec   VARCHAR(50);
    codincom_codempmt   VARCHAR(50);
    response_msg        JSON_object_t;
    obj_data_obj        varchar(1000);
    obj                 JSON_object_t;
    v_stareq            treqest1.stareq%type;

    v_codempid          ttrehire.codempid%type;
    v_codempmt          ttrehire.codempmt%type;
    v_codcomp           ttrehire.codcomp%type;

--    v_checkapp          boolean := false;
--    v_check             varchar2(500 char);

    v_msg_to            LONG;
    v_template_to       LONG;
    v_func_appr         VARCHAR2(50);
    rowidmail           VARCHAR2(50);
    v_codform           tfwmailh.codform%TYPE;
    v_error             varchar2(4000 char);
--    v_approvno          ttrehire.approvno%type;

    v_amtincom1         ttrehire.amtincom1%type;
    v_amtincom2         ttrehire.amtincom2%type;
    v_amtincom3         ttrehire.amtincom3%type;
    v_amtincom4         ttrehire.amtincom4%type;
    v_amtincom5         ttrehire.amtincom5%type;
    v_amtincom6         ttrehire.amtincom6%type;
    v_amtincom7         ttrehire.amtincom7%type;
    v_amtincom8         ttrehire.amtincom8%type;
    v_amtincom9         ttrehire.amtincom9%type;
    v_amtincom10         ttrehire.amtincom10%type;
    param_json_row      JSON_object_t;

    v_amt               number;
    v_amtmax            number;
    v_item_index        number;
    flgsecur            boolean;

    CURSOR tbdata IS
      SELECT a.*, a.dteduepr - a.dtereemp + 1 daytest,a.rowid
        FROM ttrehire a
       WHERE codempid = p_keycodempid
         and dtereemp = p_datetrans;

    v_listfilter JSON_object_t ;
    v_itemfilter JSON_object_t ;
    v_itemclonevalue JSON_object_t;
    type p_num is table of number index by binary_integer;
    v_amtincom              p_num;
    v_amtothr_income	    NUMBER;
    v_amtday_income		    NUMBER;
    v_sumincom_income	    NUMBER;
    v_checkapp              boolean;
    v_approvno              number;
    v_check                 varchar2(4000);
    v_dteeffex              temploy1.dteeffex%type;
    v_codcompemp            temploy1.codcomp%type;

  BEGIN

      SELECT Count(*)
      INTO   v_chk_repeatedly
      FROM   ttrehire
      WHERE  codempid = p_newcodempid
        AND ( codempid = p_newcodempid
             OR codnewid = p_newcodempid )
        and dtereemp <> p_datetrans;

      IF ( v_chk_repeatedly = 1 ) THEN
        param_msg_error := get_error_msg_php('HR2006', global_v_lang);
        json_str_output := Get_response_message('403', param_msg_error, global_v_lang);
        return;
      END IF;


      begin
        select dteeffex, codcomp
        into  v_dteeffex, v_codcompemp
        from  temploy1
        where codempid = p_keycodempid;
        exception when no_data_found then
         v_dteeffex     := null;
         v_codcompemp   := null;
      end;
      IF p_datetrans < v_dteeffex THEN
        param_msg_error := get_error_msg_php('PM0048', global_v_lang);
        json_str_output := Get_response_message('400', param_msg_error, global_v_lang);
        return;
      END IF;

        if p_flgmove = 'T' then --โอนย้าย
              IF hcm_util.get_codcomp_level(v_codcompemp,1) = hcm_util.get_codcomp_level(p_codcomp,1) THEN
                 param_msg_error := get_error_msg_php('PM0141', global_v_lang);
                 json_str_output := Get_response_message('400', param_msg_error, global_v_lang);
                return;
              END IF;
        else    --กลับเข้าทำงานใหม่
              IF hcm_util.get_codcomp_level(v_codcompemp,1) <> hcm_util.get_codcomp_level(p_codcomp,1) THEN
                if p_newcodempid is null then
                     param_msg_error := get_error_msg_php('HR2045', global_v_lang, null,'newcodempid');
                     json_str_output := Get_response_message(null, param_msg_error, global_v_lang);
                    return;
                end if;
              END IF;
        end if;

       IF p_datetrans < v_dteeffex THEN
         param_msg_error := get_error_msg_php('PM0048', global_v_lang);
         json_str_output := Get_response_message('400', param_msg_error, global_v_lang);
         return;
       END IF;

      v_approvno := 1;
      IF p_idp IS NULL THEN
        v_checkapp := chk_flowmail.check_approve ('HRPM21E', p_keycodempid, v_approvno, global_v_codempid, p_codcomp, p_codpos, v_check);
      ELSE
        v_checkapp := chk_flowmail.check_approve ('HRPM21E', p_idp, v_approvno, global_v_codempid, p_codcomp, p_codpos, v_check);
      END IF;

      IF NOT v_checkapp AND v_check = 'HR2010' THEN
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
        json_str_output := Get_response_message(400, param_msg_error, global_v_lang);
        return;
      END IF;

        for i in 0..p_objectsal.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(p_objectsal,i);
            v_amt           := to_number(hcm_util.get_string_t(param_json_row,'amt'));
            v_amtmax        := to_number(hcm_util.get_string_t(param_json_row,'amtmax'));
            v_item_index    := to_number(hcm_util.get_string_t(param_json_row,'rowID'));

            if (v_amtmax is not null and v_amt > 0) then
                if v_amt > v_amtmax then
                    param_msg_error := get_error_msg_php('PM0066',global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    return;
                end if;
            end if;

			if (v_item_index = '1') then
				v_amtincom1 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '2') then
				v_amtincom2 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '3') then
				v_amtincom3 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '4') then
				v_amtincom4 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '5') then
				v_amtincom5 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '6') then
				v_amtincom6 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '7') then
				v_amtincom7 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '8') then
				v_amtincom8 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '9') then
				v_amtincom9 := stdenc(v_amt, p_keycodempid, global_v_chken);
			elsif (v_item_index = '10') then
				v_amtincom10 := stdenc(v_amt, p_keycodempid, global_v_chken);
			end if;
        end loop;

        begin
            select codform
            into v_codform
            from tfwmailh
            where codapp = 'HRPM21E';
        exception when no_data_found then
            v_codform := null;
        end;

      IF p_idp IS NULL THEN
          begin
            select stareq
              into v_stareq
              from treqest1
             where numreqst = p_numreqst;
          exception when no_data_found then
              v_stareq := null;
              if v_stareq = 'C' OR v_stareq = 'X' THEN
                  param_msg_error := get_error_msg_php('HR4502',global_v_lang);
                  json_str_output := get_response_message('403',param_msg_error,global_v_lang);
                  return;
              end if ;
          end;
            BEGIN

                if  p_flgmove = 'T' then --โอนย้าย
                    p_codexemp := '0009';
                else
                    p_codexemp := '';
                end if;

                INSERT INTO ttrehire
                            (flgmove, codempmt, dtereemp, codpos, staemp, codgrpgl, codcalen, codjob,
                             jobgrade, codbrlc, numlvl, flgreemp, typemp, codnewid, codsend, codcomp,
                             numreqst, flgatten, codempid, dteduepr, codcreate, STAUPD, typpayroll, approvno, codexemp, codcurr,
                             amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10)
                VALUES      (p_flgmove, p_codempmt, p_datetrans, p_codpos, p_flgtaemp, p_codgrpgl, p_codcalen, p_codjob,
                             p_jobgrade, p_codbrlc, p_numlvl, p_flgreemp, p_typemp, p_newcodempid, p_codsend, p_codcomp,
                             p_numreqst, p_savetime, p_keycodempid, p_date, global_v_coduser, 'P', p_typpayroll, 0, p_codexemp, p_codcurr,
                             v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5, v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10);
            EXCEPTION WHEN OTHERS THEN
                rollback;
            END;
      ELSE
          BEGIN
            UPDATE ttrehire
            SET    dteduepr = p_date,
                   flgmove = p_flgmove,
                   codempmt = p_codempmt,
                   dtereemp = p_datetrans,
                   codpos = p_codpos,
                   staemp = p_flgtaemp,
                   codgrpgl = p_codgrpgl,
                   codcalen = p_codcalen,
                   codjob = p_codjob,
                   jobgrade = p_jobgrade,
                   codbrlc = p_codbrlc,
                   numlvl = p_numlvl,
                   flgreemp = p_flgreemp,
                   typemp = p_typemp,
                   codnewid = p_newcodempid,
                   codsend = p_codsend,
                   codcomp = p_codcomp,
                   numreqst = p_numreqst,
                   flgatten = p_savetime,
                   codempid = p_keycodempid,
                   CODUSER = global_v_coduser,
                   typpayroll = p_typpayroll,
                   codexemp = p_codexemp,
                   codcurr = p_codcurr,
                   amtincom1 = v_amtincom1,
                   amtincom2 = v_amtincom2,
                   amtincom3 = v_amtincom3,
                   amtincom4 = v_amtincom4,
                   amtincom5 = v_amtincom5,
                   amtincom6 = v_amtincom6,
                   amtincom7 = v_amtincom7,
                   amtincom8 = v_amtincom8,
                   amtincom9 = v_amtincom9,
                   amtincom10 = v_amtincom10
            WHERE  codempid = p_idp
              and  dtereemp = p_datetranso;
          EXCEPTION WHEN OTHERS THEN
            rollback;
          END;
      END IF;
--      obj_row := JSON_object_t();
--      v_rcnt := 0;
--
--        for i in 1..10 loop
--            v_amtincom(i)   := 0;
--        end loop;
--
--      if (flgContinue is null) then
--          FOR r1 IN tbdata LOOP
--              flgsecur := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              obj_data := JSON_object_t();
--              flg_data := TRUE;
--              obj_data.Put('coderror', '200');
--              obj_data.Put('daytest', nvl(to_char(r1.daytest),''));
--              obj_data.Put('flgmove', r1.flgmove);
--              obj_data.Put('typpayroll', r1.typpayroll);
--              obj_data.Put('codempmt', r1.codempmt);
--              obj_data.Put('datetrans', To_char(r1.dtereemp, 'dd/mm/yyyy'));
--              obj_data.Put('datetranso', To_char(r1.dtereemp, 'dd/mm/yyyy'));
--              obj_data.Put('codcomp', r1.codcomp);
--              obj_data.Put('flgtaemp', r1.staemp);
--              obj_data.Put('codgrpgl', r1.codgrpgl);
--              obj_data.Put('codcalen', r1.codcalen);
--              obj_data.Put('codjob', r1.codjob);
--              obj_data.Put('jobgrade', r1.jobgrade);
--              obj_data.Put('codbrlc', r1.codbrlc);
--              obj_data.Put('numlvl', r1.numlvl);
--              obj_data.Put('flgreemp', r1.flgreemp);
--              obj_data.Put('typemp', r1.typemp);
--              obj_data.Put('newcodempid', r1.codnewid);
--              obj_data.Put('codsend', r1.codsend);
--              obj_data.Put('codpos', r1.codpos);
--              obj_data.Put('numreqst', nvl(r1.numreqst,''));
--              obj_data.Put('savetime', r1.flgatten);
--              obj_data.Put('keycodempid', r1.codempid);
--              obj_data.Put('idp', r1.codempid);
--              obj_data.Put('codexemp', nvl(r1.codexemp,''));
--              obj_data.Put('codcurr', r1.codcurr);
--              obj_data.Put('v_rowid', r1.rowid);
--              obj_data.Put('v_zupdsal', v_zupdsal);
--              v_rcnt := v_rcnt + 1;
--              obj_row.Put(0, obj_data);
--
--              v_amtincom(1) := Stddec(r1.amtincom1, r1.codempid, global_v_chken);
--              v_amtincom(2) := Stddec(r1.amtincom2, r1.codempid, global_v_chken);
--              v_amtincom(3) := Stddec(r1.amtincom3, r1.codempid, global_v_chken);
--              v_amtincom(4) := Stddec(r1.amtincom4, r1.codempid, global_v_chken);
--              v_amtincom(5) := Stddec(r1.amtincom5, r1.codempid, global_v_chken);
--              v_amtincom(6) := Stddec(r1.amtincom6, r1.codempid, global_v_chken);
--              v_amtincom(7) := Stddec(r1.amtincom7, r1.codempid, global_v_chken);
--              v_amtincom(8) := Stddec(r1.amtincom8, r1.codempid, global_v_chken);
--              v_amtincom(9) := Stddec(r1.amtincom9, r1.codempid, global_v_chken);
--              v_amtincom(10) := Stddec(r1.amtincom10, r1.codempid, global_v_chken);
--
--          END LOOP;
--      else
--          FOR r1 IN tbdata LOOP
--              flgsecur := secur_main.secur2(r1.codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              obj_data := JSON_object_t();
--              flg_data := TRUE;
--              obj_data.Put('coderror', '200');
----              obj_data.Put('daytest', r1.daytest);
--              obj_data.Put('daytest', '');
--              obj_data.Put('flgmove', r1.flgmove);
--              obj_data.Put('codempmt', r1.codempmt);
----              obj_data.Put('datetrans', To_char(r1.dtereemp, 'dd/mm/yyyy'));
--              obj_data.Put('datetrans', '');
--              obj_data.Put('codcomp', r1.codcomp);
--              obj_data.Put('flgtaemp', r1.staemp);
--              obj_data.Put('codgrpgl', r1.codgrpgl);
--              obj_data.Put('codcalen', r1.codcalen);
--              obj_data.Put('codjob', r1.codjob);
--              obj_data.Put('jobgrade', r1.jobgrade);
--              obj_data.Put('codbrlc', r1.codbrlc);
--              obj_data.Put('numlvl', r1.numlvl);
--              obj_data.Put('flgreemp', r1.flgreemp);
--              obj_data.Put('typemp', r1.typemp);
----              obj_data.Put('newcodempid', r1.codnewid);
--              obj_data.Put('newcodempid', '');
--              obj_data.Put('codsend', r1.codsend);
--              obj_data.Put('codpos', r1.codpos);
--              obj_data.Put('numreqst', r1.numreqst);
--              obj_data.Put('savetime', r1.flgatten);
--              obj_data.Put('keycodempid', r1.codempid);
--              obj_data.Put('typpayroll', r1.typpayroll);
--              obj_data.Put('idp', r1.codempid);
--              obj_data.Put('FlagSave','1');
--              obj_data.Put('v_zupdsal', v_zupdsal);
--              v_rcnt := v_rcnt + 1;
--              obj_row.Put(0, obj_data);
--
--              v_amtincom(1) := Stddec(r1.amtincom1, r1.codempid, global_v_chken);
--              v_amtincom(2) := Stddec(r1.amtincom2, r1.codempid, global_v_chken);
--              v_amtincom(3) := Stddec(r1.amtincom3, r1.codempid, global_v_chken);
--              v_amtincom(4) := Stddec(r1.amtincom4, r1.codempid, global_v_chken);
--              v_amtincom(5) := Stddec(r1.amtincom5, r1.codempid, global_v_chken);
--              v_amtincom(6) := Stddec(r1.amtincom6, r1.codempid, global_v_chken);
--              v_amtincom(7) := Stddec(r1.amtincom7, r1.codempid, global_v_chken);
--              v_amtincom(8) := Stddec(r1.amtincom8, r1.codempid, global_v_chken);
--              v_amtincom(9) := Stddec(r1.amtincom9, r1.codempid, global_v_chken);
--              v_amtincom(10) := Stddec(r1.amtincom10, r1.codempid, global_v_chken);
--          END LOOP;
--      end if;
--
--      begin
--        select codcomp
--          into p_codcompindex
--          from ttrehire
--         where codempid = p_idp
--           and dtereemp = p_datetrans;
--      exception when no_data_found then
--        p_codcompindex := null;
--      end;
--
--      begin
--          SELECT To_char((SELECT Max(dteeffec)
--                          FROM   tcontpms
--                          WHERE  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)), 'ddmmyyyy'),
--                 codempmt
--          INTO   codincom_dteeffec, codincom_codempmt
--          FROM   temploy1
--          WHERE  codempid = detail_codempid;
--      exception when no_data_found then
--          codincom_dteeffec := to_char(sysdate,'ddmmyyyy');
--          codincom_codempmt := 'M';
--      end;
--
--      v_datasal := hcm_pm.Get_codincom('{"p_codcompy":'''||hcm_util.get_codcomp_level(p_codcomp,1)||''',"p_dteeffec":'''||codincom_dteeffec||''',"p_codempmt":'''||p_codempmt||''',"p_lang":'''||global_v_lang||'''}');
--      v_listfilter := JSON_object_t(v_datasal);
--      v_itemfilter := JSON_object_t();
--
--      for index_item in  0..v_listfilter.get_size-1
--        loop
--             begin
--                 if (hcm_util.get_string_t(hcm_util.get_json_t(v_listfilter,index_item),'codincom') != ' ' and
--                     hcm_util.get_string_t(hcm_util.get_json_t(v_listfilter,index_item),'desincom') != ' ' ) then
--                     v_itemclonevalue := hcm_util.get_json_t(v_listfilter,index_item);
--                     v_itemclonevalue.put('amt', v_amtincom(index_item+1));
--                     v_itemfilter.put(to_char(index_item) ,v_itemclonevalue );
--                 end if ;
--             end;
--       end loop;
--
--      obj_sum := Json_object_t();
--      obj_sum.Put('t1', obj_data);
--      obj_sum.Put('t2', v_itemfilter);
--      get_wage_income(p_codcomp, p_codempmt, v_amtincom(1),v_amtincom(2), v_amtincom(3), v_amtincom(4), v_amtincom(5),
--                        v_amtincom(6), v_amtincom(7), v_amtincom(8), v_amtincom(9), v_amtincom(10), v_amtothr_income, v_amtday_income, v_sumincom_income);
--      obj_sum.put('v_sumincom_income', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
--      obj_sum.put('v_amtday_income', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
--      obj_sum.put('v_amtothr_income', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
--      obj_sum.put('v_amtothr_income', v_datasal);

      --data respone
      param_msg_error   := get_error_msg_php('HR2401', global_v_lang);
      json_str_output   := Get_response_message(NULL, param_msg_error, global_v_lang);
--      obj               := json_object_t(json_str_output);
--      obj_data_obj      := hcm_util.get_string_t(obj, 'desc_coderror');
--      obj_sum.Put('response', obj_data_obj);
--      obj_sum.Put('coderror', '200');
--      json_str_output := obj_sum.To_clob();

  END save_data21e;
  PROCEDURE Get_detail21e (json_str_input  IN CLOB, json_str_output OUT CLOB) IS
    json_obj        JSON_object_t;
    chk_emp         varchar(1);
    v_staemp_upd    temploy1.staemp%type;
  BEGIN
      Initial_value(json_str_input);
      json_obj := JSON_object_t(json_str_input);
      detail_codempid := hcm_util.Get_string_t(json_obj, 'pa_codempid');

      /*User37 #5678 1.PM Module 19/04/2021 select staemp
        into chk_emp
        from temploy1
       where codempid = detail_codempid;

      if(chk_emp = '3' and pa_flgmove = 'R') then
          param_msg_error := get_error_msg_php('PM0016',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
      end if;

      if(chk_emp = '9' and pa_flgmove = 'T') then
          begin
            select t1.staemp into v_staemp_upd
              from temploy1 t1, ttrehire t2
             where t1.codempid = t2.codempid
               and t2.staupd = 'U'
               and t1.codempid = detail_codempid;
          exception when no_data_found then
            v_staemp_upd  :=  null;
          end;
          if v_staemp_upd is null then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            return;
          end if;
      end if;*/

      Gen_detail21e(json_str_output);
  END get_detail21e;

  PROCEDURE Gen_detail21e (json_str_output OUT CLOB) IS
    v_rcnt              NUMBER;
    obj_row             JSON_object_t;
    obj_data            JSON_object_t;
    v_yearnow           NUMBER;
    v_monthnow          NUMBER;
    v_yearbirth         NUMBER;
    v_monthbirth        NUMBER;
    obj_row2            JSON_object_t;
    v_datasal           CLOB;
    obj_sum             JSON_object_t;
    v_numoffid          temploy2.numoffid%TYPE;
    v_findemp           number;
    flg_data            BOOLEAN := FALSE;
    flgsecur_amt        BOOLEAN := FALSE;
    codincom_dteeffec   VARCHAR(50);
    codincom_codempmt   VARCHAR(50);
    v_codempid          ttrehire.codempid%type;
    v_codempmt          ttrehire.codempmt%type;
    v_codcomp           ttrehire.codcomp%type;
    obj json_object_t;
    obj_data_obj        varchar(500);
    v_amtincom1         number;
    v_amtincom2         number;
    v_amtincom3         number;
    v_amtincom4         number;
    v_amtincom5         number;
    v_amtincom6         number;
    v_amtincom7         number;
    v_amtincom8         number;
    v_amtincom9         number;
    v_amtincom10        number;
    v_amtothr_income	  NUMBER;
    v_amtday_income		  NUMBER;
    v_sumincom_income	  NUMBER;

    P_CODCOMP           temploy1.CODCOMP%type;
    P_CODCALEN          temploy1.CODCALEN%type;
    P_CODPOS            temploy1.CODPOS%type;
    P_CODJOB            temploy1.CODJOB%type;
    P_TYPPAYROLL        temploy1.TYPPAYROLL%type;
    P_JOBGRADE          temploy1.JOBGRADE%type;
    P_CODBRLC           temploy1.CODBRLC%type;
    P_CODGRPGL          temploy1.CODGRPGL%type;
    P_CODEMPMT          temploy1.CODEMPMT%type;
    P_NUMLVL            temploy1.NUMLVL%type;
    P_TYPEMP           temploy1.TYPEMP%type;
    P_FLGATTEN          temploy1.FLGATTEN%type;
    v_staemp            temploy1.staemp%type;
    v_codcurr          temploy3.codcurr%type;
    v_flag_view_only    boolean;

    CURSOR tbdata IS
      SELECT a.*,
             nvl(a.dteduepr - a.dtereemp + 1,'') daytest,
             rowid
        FROM ttrehire a
       WHERE codempid = detail_codempid
         AND flgmove = pa_flgmove;
         --AND staupd <> 'N';
    v_listfilter      JSON_object_t ;
    v_itemfilter      JSON_object_t ;
    v_itemclonevalue  JSON_object_t;
    type p_num is table of number index by binary_integer;
    v_amtincom          p_num;
  BEGIN
        begin
            SELECT numoffid
              INTO v_numoffid
              FROM temploy2
             WHERE codempid = detail_codempid ;
        exception when no_data_found then
            v_numoffid := null;
        end;

        begin
            SELECT Count(*)
              INTO v_findemp
              FROM tbcklst
             WHERE numoffid = v_numoffid;
        end;

        begin
            select codcomp,codempmt, staemp
              into v_codcomp,v_codempmt, v_staemp
              from temploy1
             where codempid = detail_codempid;
        end;

      obj_row := JSON_object_t();
      v_rcnt := 0;

      flgsecur_amt := secur_main.secur2(detail_codempid ,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);


      if  not flgsecur_amt  then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
      end if;

      FOR r1 IN tbdata LOOP
          obj_data := JSON_object_t();
          flg_data := TRUE;
          p_codcompindex := r1.codcomp;
          P_CODEMPMT := r1.codempmt;
          obj_data.Put('coderror', '200');
          if r1.daytest is not null then
            obj_data.Put('daytest', nvl(r1.daytest,''));
          else
            obj_data.Put('daytest', '');
          end if;
          obj_data.Put('flgmove', r1.flgmove);
          obj_data.Put('codempmt', r1.codempmt);
          obj_data.Put('datetrans', To_char(r1.dtereemp, 'dd/mm/yyyy'));
          obj_data.Put('datetranso', To_char(r1.dtereemp, 'dd/mm/yyyy'));
          obj_data.Put('codcomp', r1.codcomp);
          obj_data.Put('flgtaemp', r1.staemp);
          obj_data.Put('typpayroll', r1.typpayroll);
          obj_data.Put('codgrpgl', r1.codgrpgl);
          obj_data.Put('codcalen', r1.codcalen);
          obj_data.Put('codjob', r1.codjob);
          obj_data.Put('jobgrade', r1.jobgrade);
          obj_data.Put('codbrlc', r1.codbrlc);
          obj_data.Put('numlvl', r1.numlvl);
          obj_data.Put('flgreemp', r1.flgreemp);
          obj_data.Put('typemp', r1.typemp);
          obj_data.Put('newcodempid', r1.codnewid);
          obj_data.Put('codsend', r1.codsend);
          obj_data.Put('codpos', r1.codpos);
          obj_data.Put('numreqst', nvl(r1.numreqst,''));
          obj_data.Put('savetime', r1.flgatten);
          obj_data.Put('keycodempid', r1.codempid);
          obj_data.Put('idp', r1.codempid);
          obj_data.Put('lastcodcomp', v_codcomp);
          obj_data.Put('lastcodempmt', v_codempmt);
          obj_data.Put('codexemp', nvl(r1.codexemp,''));
          obj_data.Put('codcurr', nvl(r1.codcurr,''));
          obj_data.Put('v_rowid', r1.rowid);
          obj_data.Put('v_zupdsal', v_zupdsal);

          --<<User37 #5678 1.PM Module 19/04/2021 
          obj_data.Put('desc_flgmove', get_tlistval_name('HRPM21E',r1.flgmove,global_v_lang));
          obj_data.Put('desc_keycodempid', get_temploy_name(r1.codempid,global_v_lang));
          -->>User37 #5678 1.PM Module 19/04/2021 

          if r1.staupd = 'P' then
            v_flag_view_only := false;
          else
            v_flag_view_only := true;
          end if;
          obj_data.Put('flag_view_only', v_flag_view_only);
          v_rcnt := v_rcnt + 1;

          if(pa_flgmove = 'T') then
            obj_data.Put('flgreemp', '1');
            obj_data.Put('flgreemp_disable', true);
          end if;

          obj_row.Put(0, obj_data);
      END LOOP;

      IF NOT flg_data THEN
        obj_data := JSON_object_t();
        obj_row := JSON_object_t();
        v_rcnt := 1;

        begin
            select a.codcomp,a.codcalen,a.codpos,a.codjob,a.typpayroll,
                   a.jobgrade,a.codbrlc,a.codgrpgl,a.codempmt,a.numlvl,a.typemp,a.flgatten,b.codcurr
              into p_codcomp,p_codcalen,p_codpos,p_codjob,p_typpayroll,
              p_jobgrade,p_codbrlc,p_codgrpgl,p_codempmt,p_numlvl,p_typemp,p_flgatten,v_codcurr
              from temploy1 a,temploy3 b
             where a.codempid = detail_codempid
                and a.codempid = b.codempid;
        end;
        p_codcompindex := P_CODCOMP;
        obj_data.Put('keycodempid', detail_codempid);
        obj_data.Put('flgmove', pa_flgmove);
        obj_data.Put('codpos', P_CODPOS);
        obj_data.Put('codcalen', P_CODCALEN);
        obj_data.Put('codcomp', P_CODCOMP);
        obj_data.Put('codjob', P_CODJOB);
        obj_data.Put('typpayroll', P_TYPPAYROLL);
        obj_data.Put('jobgrade', P_JOBGRADE);
        obj_data.Put('codbrlc', P_CODBRLC);
        obj_data.Put('codgrpgl', P_CODGRPGL);
        obj_data.Put('codempmt', P_CODEMPMT);
        obj_data.Put('numlvl', P_NUMLVL);
        obj_data.Put('typemp', P_TYPEMP);
        obj_data.Put('savetime', P_FLGATTEN);
        obj_data.Put('lastcodcomp', v_codcomp);
        obj_data.Put('lastcodempmt', v_codempmt);
        obj_data.Put('newcodempid', '');
        obj_data.Put('codsend',global_v_codempid);
        obj_data.Put('v_zupdsal', v_zupdsal);
        obj_data.Put('numreqst', '');
        obj_data.Put('codexemp', '');
        obj_data.Put('codcurr', v_codcurr);

        --<<User37 #5678 1.PM Module 19/04/2021 
        obj_data.Put('desc_flgmove', get_tlistval_name('HRPM21E',pa_flgmove,global_v_lang));
        obj_data.Put('desc_keycodempid', get_temploy_name(detail_codempid,global_v_lang));
        -->>User37 #5678 1.PM Module 19/04/2021 


        if v_FindEmp <> 0 then
            obj_data.Put('v_FindEmp', true);
            param_msg_error := get_error_msg_php('HR2006',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
            obj             := JSON_object_t(json_str_output);
            obj_data_obj    := hcm_util.get_string_t(obj, 'desc_coderror');
            obj_data.Put('response', obj_data_obj);
        end if;

        if(pa_flgmove = 'T') then
        obj_data.Put('flgreemp', '1');
        obj_data.Put('flgreemp_disable', true);
        end if;

        obj_row.Put(0, obj_data);
      END IF;

      begin
          SELECT To_char((SELECT Max(dteeffec)
                          FROM   tcontpms
                          WHERE  codcompy  = hcm_util.get_codcomp_level(v_codcomp,1) AND DTEEFFEC <= TRUNC(SYSDATE)), 'ddmmyyyy'),
                 codempmt
          INTO   codincom_dteeffec, codincom_codempmt
          FROM   temploy1
          WHERE  codempid = detail_codempid;
      exception when no_data_found then
          codincom_dteeffec := to_char(sysdate,'ddmmyyyy');
          codincom_codempmt := 'M';
      end;
--        begin
--        select codcomp
--          into p_codcompindex
--          from ttrehire
--         where codempid = detail_codempid
--           AND flgmove = pa_flgmove ;
--        exception when no_data_found then
--          p_codcompindex := null;
--        end;
        for i in 1..10 loop
            v_amtincom(i)   := 0;
        end loop;
       BEGIN
			SELECT  codempid, codempmt, codcomp,
                    greatest(0, Stddec(amtincom1, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom2, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom3, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom4, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom5, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom6, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom7, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom8, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom9, codempid, global_v_chken)),
                    greatest(0, Stddec(amtincom10, codempid, global_v_chken))

			INTO    v_codempid, v_codempmt, v_codcomp, v_amtincom(1),
                    v_amtincom(2), v_amtincom(3), v_amtincom(4), v_amtincom(5),
                    v_amtincom(6), v_amtincom(7), v_amtincom(8), v_amtincom(9), v_amtincom(10)
			FROM ttrehire
           where codempid = detail_codempid
             and flgmove = pa_flgmove;
		EXCEPTION WHEN no_data_found THEN
            SELECT greatest(0, Stddec(amtincom1, codempid, global_v_chken)), greatest(0, Stddec(amtincom2, codempid, global_v_chken)), greatest(0, Stddec(amtincom3, codempid, global_v_chken)),
                   greatest(0, Stddec(amtincom4, codempid, global_v_chken)), greatest(0, Stddec(amtincom5, codempid, global_v_chken)), greatest(0, Stddec(amtincom6, codempid, global_v_chken)),
                   greatest(0, Stddec(amtincom7, codempid, global_v_chken)), greatest(0, Stddec(amtincom8, codempid, global_v_chken)), greatest(0, Stddec(amtincom9, codempid, global_v_chken)),
                   greatest(0, Stddec(amtincom10, codempid, global_v_chken))
              INTO v_amtincom(1), v_amtincom(2), v_amtincom(3),
                   v_amtincom(4), v_amtincom(5), v_amtincom(6),
                   v_amtincom(7), v_amtincom(8), v_amtincom(9), v_amtincom(10)
              FROM temploy3
             WHERE codempid = detail_codempid;
		END;

      v_datasal:= hcm_pm.Get_codincom('{"p_codcompy":'''||hcm_util.get_codcomp_level(p_codcompindex, 1)||''',"p_dteeffec":'''||codincom_dteeffec||''',"p_codempmt":'''||P_CODEMPMT||''',"p_lang":'''||global_v_lang||'''}');

      v_listfilter := JSON_object_t(v_datasal);
      v_itemfilter := JSON_object_t();
      for index_item in  0..v_listfilter.get_size-1
        loop
             begin
                 if (hcm_util.get_string_t(hcm_util.get_json_t(v_listfilter,index_item),'codincom') != ' ' and
                     hcm_util.get_string_t(hcm_util.get_json_t(v_listfilter,index_item),'desincom') != ' ' ) then
                     v_itemclonevalue := hcm_util.get_json_t(v_listfilter,index_item);
                     --<<User37 NXP-HR2101 #6592 
                     /*if index_item+1 = 1 then
                        v_itemclonevalue.put('amt', v_amtincom(index_item+1));
                     else
                        v_itemclonevalue.put('amt', 0);
                     end if;*/
                     v_itemclonevalue.put('amt', v_amtincom(index_item+1));
                     -->>User37 NXP-HR2101 #6592  
                     v_itemfilter.put(to_char(index_item) ,v_itemclonevalue );
                 end if ;
             end;
       end loop;

        Get_wage_income(p_codcompindex, P_CODEMPMT, v_amtincom(1),
                        0, 0, 0,
                        0, 0, 0,
                        0, 0, 0,
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

      obj_sum := Json_object_t();

--    if v_zupdsal = 'N' then
--      v_amtothr_income := '';
--      v_amtday_income := '';
--      v_sumincom_income := '';
--    end if;
      obj_sum.Put('t1', obj_data);
      obj_sum.Put('t2', v_itemfilter);
      obj_sum.Put('v_amtothr_income', to_char(v_amtothr_income,'fm999,999,999,990.00'));
      obj_sum.Put('v_amtday_income', to_char(v_amtday_income,'fm999,999,999,990.00'));
      obj_sum.Put('v_sumincom_income', to_char(v_sumincom_income,'fm999,999,999,990.00'));
      --<<User37 #5476 Final Test Phase 1 V11 10/03/2021
      if v_flag_view_only then
        obj_sum.Put('warning', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400'));
      else
        obj_sum.Put('warning', '');
      end if;
      -->>User37 #5476 Final Test Phase 1 V11 10/03/2021

--      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      obj_sum.Put('response', param_msg_error);
      obj_sum.Put('coderror', '200');
      json_str_output := obj_sum.To_clob();
  END gen_detail21e;

  PROCEDURE Get_delete21e (json_str_input  IN CLOB, json_str_output OUT CLOB) IS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              NUMBER;
    p_codempid_query    ttrehire.codempid%type;
    p_dtereemp          varchar2(10);
    p_paramsdelete      json_object_t;
    v_count             NUMBER :=0;

  BEGIN
      obj_data          := json_object_t(json_str_input);
      p_paramsdelete    := hcm_util.get_Json_t(obj_data,'params');
      obj_row           := json_object_t();
      v_rcnt            := 0;

      FOR i IN 0..p_paramsdelete.get_size-1 LOOP
          obj_row           := json_object_t();
          obj_row           := hcm_util.get_Json_t(p_paramsdelete,To_char(i));
          p_codempid_query  := hcm_util.Get_string_t(obj_row, 'codempid');
          p_dtereemp        := hcm_util.Get_string_t(obj_row, 'dtereemp');


         begin
                   SELECT count(*)
                     INTO v_count
                     FROM ttrehire
                    WHERE codempid = p_codempid_query
                      AND dtereemp = to_date(p_dtereemp,'dd/mm/yyyy')
                      AND nvl(staupd,'P') <> 'P';
         end;

         IF v_count > 0 THEN
            param_msg_error := get_error_msg_php('HR1501', global_v_lang);
            json_str_output := Get_response_message(400, param_msg_error, global_v_lang);
            return;
          END IF;

          BEGIN
              DELETE FROM ttrehire
                    WHERE codempid = p_codempid_query
                      and dtereemp = to_date(p_dtereemp,'dd/mm/yyyy');
          END;
      END LOOP;

      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output := Get_response_message(NULL, param_msg_error,global_v_lang);

  END get_delete21e;

  PROCEDURE gen_id (json_str_input IN CLOB, json_str_output OUT CLOB) IS
    obj_row             JSON_object_t;
    obj_data            JSON_object_t;
    json_obj            JSON_object_t;
    v_rcnt              NUMBER;
    v_dteyear	        number;
    v_codnewid          temploy1.codempid%type;
    v_groupid           varchar2(10);
    v_table             varchar2(10);
    v_error             varchar2(10);
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    work_codcomp        varchar2(4000 char);
    work_codempmt       varchar2(4000 char);
    work_codbrlc        temploy1.codbrlc%type;
    work_dteempmt       date;
    parameter_groupid   varchar2(100);
    parameter_year      number;
    parameter_month     number;
    parameter_running   varchar2(100);
    --<<User37 #6760 10/09/2021 
    v_flgmove           varchar2(10);
    v_datetrans         date;
    v_codbrlc           temploy1.codbrlc%type;
    v_codempmt          temploy1.codempmt%type;
    -->>User37 #6760 10/09/2021 

  begin
    obj_data      := Json_object_t();
    obj_row       := Json_object_t();
    json_obj      := Json_object_t(json_str_input);
    v_codempid    := hcm_util.Get_string_t(json_obj, 'codempid');
    v_codcomp    := hcm_util.Get_string_t(json_obj, 'codcomp');
    --<<User37 #6760 10/09/2021 
    v_flgmove     := hcm_util.Get_string_t(json_obj, 'flgmove');
    v_datetrans   := to_date(hcm_util.Get_string_t(json_obj, 'datetrans'),'dd/mm/yyyy');
    v_codbrlc     := hcm_util.Get_string_t(json_obj, 'codbrlc');
    v_codempmt    := hcm_util.Get_string_t(json_obj, 'codempmt');
      
    if v_flgmove = 'T' then --โอนย้าย
      begin
        select dteempmt
          into work_dteempmt
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        work_dteempmt := null;
      end;
    else--กลับเข้าทำงานใหม่
      work_dteempmt := v_datetrans;
    end if;
    work_codcomp    := v_codcomp;
    work_codempmt   := v_codempmt;
    work_codbrlc    := v_codbrlc;
      /*begin
        select codcomp, codempmt, dteempmt, codbrlc
          into work_codcomp, work_codempmt, work_dteempmt, work_codbrlc
          from temploy1
         where codempid = v_codempid;
      end;
      work_codcomp := v_codcomp;*/
      -->>User37 #6760 10/09/2021 
    v_rcnt := 0;

    std_genid2.gen_id(work_codcomp,work_codempmt,work_codbrlc,work_dteempmt,parameter_groupid,v_codnewid,parameter_year,parameter_month,parameter_running,v_table,v_error);
    obj_data.Put('coderror', '200');
    obj_data.Put('codempid', v_codnewid);

    obj_row.Put(v_rcnt, obj_data);
    if v_error is not null then
        param_msg_error   := get_error_msg_php(v_error,global_v_lang,v_table);
        json_str_output := Get_response_message(NULL, param_msg_error,global_v_lang);
    else
        json_str_output := obj_row.To_clob;
    end if;
  END gen_id;

  procedure get_list_typrehire (json_str_input in clob, json_str_output out clob) as
    obj_data        Json_object_t;
    obj_row         Json_object_t;
    v_rcnt          number := 0;

    cursor c_ttexttrn is
      select LIST_VALUE, DESC_LABEL
        from TLISTVAL
       where codapp='TYPREHIRE'
         AND list_value <> 'A'
         AND CODLANG = global_v_lang
      order by LIST_VALUE;
  begin
    initial_value(json_str_input);
    obj_row := Json_object_t();
    for r1 in c_ttexttrn loop
      v_rcnt      := v_rcnt+1;
      obj_data     := Json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('value', r1.LIST_VALUE);
      obj_data.put('label', r1.DESC_LABEL);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_list_namhir (json_str_input in clob, json_str_output out clob) as
    obj_data        Json_object_t;
    obj_row         Json_object_t;
    v_rcnt          number := 0;

    cursor c_ttexttrn is
      select LIST_VALUE, DESC_LABEL
        from TLISTVAL
       where codapp='NAMREHIR'
         AND numseq <> '3' AND LIST_VALUE is not null
         AND CODLANG = global_v_lang
      order by LIST_VALUE;
  begin
    initial_value(json_str_input);
    obj_row := Json_object_t();
    for r1 in c_ttexttrn loop
      v_rcnt      := v_rcnt+1;
      obj_data     := Json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('value', r1.LIST_VALUE);
      obj_data.put('label', r1.DESC_LABEL);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

	procedure funcSendmail (json_str_input in clob, json_str_output out clob) as
		json_obj		    Json_object_t;
		v_codform		    tfwmailh.codform %type;
		v_msg_to            clob;
		v_template_to       clob;
		v_func_appr         tfwmailh.codappap%type;
		v_rowid             rowid;
		v_error			    terrorm.errorno%type;
		ttmistk_codempid	ttmistk.codempid%type;
		ttmistk_codreq		ttmistk.codempid%type;
		flg			        number;
		obj_respone		    Json_object_t;
		obj_respone_data    varchar(500);
		obj_sum			    Json_object_t;
        v_approvno          ttmistk.approvno%type;

        v_codcomp           TTREHIRE.codcomp%type;
        v_codpos            TTREHIRE.codpos%type;

        v_checkapp          boolean := false;
        v_check             varchar2(500 char);
	begin
        initial_value(json_str_input);
		json_obj            := Json_object_t(json_str_input);
		v_rowid             := hcm_util.get_string_t(json_obj,'v_rowid');
		ttmistk_codempid    := hcm_util.get_string_t(json_obj,'param_codempid');
		ttmistk_codreq      := hcm_util.get_string_t(json_obj,'param_codsend');
		flg                 := hcm_util.get_string_t(json_obj,'v_flag_confirm');
		if (flg = '0') then
			param_msg_error     := get_error_msg_php('HR0007', global_v_lang);
			json_str_output     := Get_response_message(NULL, param_msg_error,global_v_lang);
			obj_respone         := Json_object_t(json_str_output);
			obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
			obj_sum             := Json_object_t();
			obj_sum.put('coderror','200');
			obj_sum.put('flg_send',true);
			obj_sum.put('desc_coderror',obj_respone_data);
			json_str_output := obj_sum.to_clob;
		else
            begin
                select nvl(approvno,0) + 1
                  into v_approvno
                  from TTREHIRE
                 where rowid = v_rowid;
            exception when no_data_found then
				v_approvno := 1;
			end;

            v_checkapp := chk_flowmail.check_approve ('HRPM21E', ttmistk_codempid, v_approvno, global_v_codempid, p_codcomp, p_codpos, v_check);
            IF NOT v_checkapp AND v_check = 'HR2010' THEN
                param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfwmailc');
                json_str_output := Get_response_message(400, param_msg_error, global_v_lang);
                return;
            END IF;

			v_error := chk_flowmail.send_mail_for_approve('HRPM21E', ttmistk_codempid, ttmistk_codreq, global_v_coduser, null, 'HRPM21E1', 230, 'E', 'P', v_approvno , null, null,'TTREHIRE', v_rowid, '1', null);

      param_msg_error := get_error_msg_php('HR'||v_error, global_v_lang);
			json_str_output := Get_response_message(NULL, param_msg_error,global_v_lang);
			obj_respone := Json_object_t(json_str_output);
			obj_respone_data := hcm_util.get_string_t(obj_respone, 'response');
			obj_sum := Json_object_t();
			obj_sum.put('coderror','200');
			obj_sum.put('flg_send',false);
			obj_sum.put('desc_coderror',obj_respone_data);
			json_str_output := obj_sum.to_clob;
		end if;
	end ;

	PROCEDURE genallowance ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
		json_obj		            Json_object_t;
		TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		sal_amtincom                p_num;
		v_sal_allowance             p_num;
        v_amtincom                  p_num;
		v_temploy1                  temploy1%rowtype;
		v_flg			            VARCHAR2(10 CHAR);
		v_datasal                   CLOB;
		get_allowance               CLOB;
		codincom_dteeffec           VARCHAR(20);
		codincom_codempmt           VARCHAR(20);
		param_json		            Json_object_t;
		obj_rowsal		            Json_object_t;
		v_row			            NUMBER := 0;
		param_json_row		        Json_object_t;
		v_codincom		            tinexinf.codpay%TYPE;
		v_desincom		            tinexinf.descpaye%TYPE;
		v_desunit		            VARCHAR2(150 CHAR);
		v_amtmax		            NUMBER;
		sal_allowance		        NUMBER;
		obj_data_salary		        Json_object_t;
		param_json_allowance	    Json_object_t;
		param_json_row_allowance	Json_object_t;
		obj_sum			            Json_object_t;
		v_amtothr_income	        NUMBER := 0;
		v_amtday_income		        NUMBER := 0;
		v_sumincom_income	        NUMBER := 0;
	BEGIN
		json_obj        := Json_object_t(json_str_input);
		p_codempid      := hcm_util.get_string_t(json_obj, 'p_codempid_query');
		p_codcomp       := hcm_util.get_string_t(json_obj, 'p_codcomp');
		p_codpos        := hcm_util.get_string_t(json_obj, 'p_codpos');
		p_numlvl        := hcm_util.get_number_t(json_obj, 'p_numlvl');
		p_jobgrade      := hcm_util.get_string_t(json_obj, 'p_jobgrade');
		p_codjob        := hcm_util.get_string_t(json_obj, 'p_codjob');
		p_typpayroll    := hcm_util.get_string_t(json_obj, 'p_typpayroll');
		p_codempmt      := hcm_util.get_string_t(json_obj, 'p_codempmt');
		p_codbrlc       := hcm_util.get_string_t(json_obj, 'p_codbrlc');
--		p_codbrlc       := json_ext.get_string_t(json_obj, 'p_codbrlc');
        p_amtincom1     := to_number(hcm_util.get_string_t(json_obj, 'p_amtincom1'));
		v_flg           := 2;

		SELECT greatest(0, stddec(amtincom1, codempid, global_v_chken)),
               greatest(0, stddec(amtincom2, codempid, global_v_chken)),
               greatest(0, stddec(amtincom3, codempid, global_v_chken)),
               greatest(0, stddec(amtincom4, codempid, global_v_chken)),
               greatest(0, stddec(amtincom5, codempid, global_v_chken)),
               greatest(0, stddec(amtincom6, codempid, global_v_chken)),
               greatest(0, stddec(amtincom7, codempid, global_v_chken)),
               greatest(0, stddec(amtincom8, codempid, global_v_chken)),
               greatest(0, stddec(amtincom9, codempid, global_v_chken)),
               greatest(0, stddec(amtincom10, codempid, global_v_chken))
		  INTO sal_amtincom(1),
               sal_amtincom(2),
               sal_amtincom(3),
               sal_amtincom(4),
               sal_amtincom(5),
               sal_amtincom(6),
               sal_amtincom(7),
               sal_amtincom(8),
               sal_amtincom(9),
               sal_amtincom(10)
		  FROM temploy3
		 WHERE codempid = p_codempid;

		FOR i IN 1..10 LOOP
            IF ( sal_amtincom(i) IS NULL ) THEN
                sal_amtincom(i) := 0;
            END IF;
        END LOOP;
        BEGIN
            SELECT codcomp, codpos, numlvl, jobgrade,
                   codjob, typpayroll, codempmt, codbrlc
              INTO v_temploy1.codcomp, v_temploy1.codpos, v_temploy1.numlvl, v_temploy1.jobgrade,
                   v_temploy1.codjob, v_temploy1.typpayroll, v_temploy1.codempmt, v_temploy1.codbrlc
              FROM temploy1
             WHERE codempid = p_codempid;
        EXCEPTION WHEN no_data_found THEN
            v_temploy1.codcomp      := NULL;
            v_temploy1.codpos       := NULL;
            v_temploy1.numlvl       := NULL;
            v_temploy1.jobgrade     := NULL;
            v_temploy1.codjob       := NULL;
            v_temploy1.typpayroll   := NULL;
            v_temploy1.codempmt     := NULL;
            v_temploy1.codbrlc      := NULL;
        END;
        get_allowance := hcm_pm.get_tincpos('{"p_amtincom1":''' || 0
                            || ''',"p_amtincom2":''' || sal_amtincom(2)
                            || ''',"p_amtincom3":''' || sal_amtincom(3)
                            || ''',"p_amtincom4":''' || sal_amtincom(4)
                            || ''',"p_amtincom5":''' || sal_amtincom(5)
                            || ''',"p_amtincom6":''' || sal_amtincom(6)
                            || ''',"p_amtincom7":''' || sal_amtincom(7)
                            || ''',"p_amtincom8":''' || sal_amtincom(8)
                            || ''',"p_amtincom9":''' || sal_amtincom(9)
                            || ''',"p_amtincom10":''' || sal_amtincom(10)
                            || ''',"p_codcomp":''' || p_codcomp
                            || ''',"p_codpos":''' || p_codpos
                            || ''',"p_numlvl":''' || p_numlvl
                            || ''',"p_jobgrade":''' || p_jobgrade
                            || ''',"p_codjob":''' || p_codjob
                            || ''',"p_typpayroll":''' || p_typpayroll
                            || ''',"p_codempmt":''' || p_codempmt
                            || ''',"p_codbrlc":''' || p_codbrlc
                            || ''',"p_flgtype":''' || v_flg || '''}');

        BEGIN
            SELECT TO_CHAR(( SELECT MAX(dteeffec)
                               FROM tcontpms
                              WHERE codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                AND dteeffec <= trunc(sysdate)), 'ddmmyyyy'),
                   codempmt
              INTO codincom_dteeffec,
                   codincom_codempmt
              FROM temploy1
             WHERE codempid = p_codempid;
        EXCEPTION WHEN no_data_found THEN
            codincom_dteeffec := NULL;
            codincom_codempmt := NULL;
        END;

        v_datasal := hcm_pm.get_codincom('{"p_codcompy":'''
                        || hcm_util.get_codcomp_level(p_codcomp, 1)
                        || ''',"p_dteeffec":''' || NULL
                        || ''',"p_codempmt":''' || p_codempmt
                        || ''',"p_lang":''' || global_v_lang || '''}');
        BEGIN
            SELECT greatest(0, stddec(amtincom1, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom2, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom3, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom4, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom5, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom6, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom7, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom8, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom9, codempid, global_v_chken)),
                   greatest(0, stddec(amtincom10, codempid, global_v_chken))
              INTO sal_amtincom(1),
                   sal_amtincom(2),
                   sal_amtincom(3),
                   sal_amtincom(4),
                   sal_amtincom(5),
                   sal_amtincom(6),
                   sal_amtincom(7),
                   sal_amtincom(8),
                   sal_amtincom(9),
                   sal_amtincom(10)
              FROM temploy3
             WHERE codempid = p_codempid;
        EXCEPTION WHEN no_data_found THEN
            sal_amtincom(1) := 0;
            sal_amtincom(2) := 0;
            sal_amtincom(3) := 0;
            sal_amtincom(4) := 0;
            sal_amtincom(5) := 0;
            sal_amtincom(6) := 0;
            sal_amtincom(7) := 0;
            sal_amtincom(8) := 0;
            sal_amtincom(9) := 0;
            sal_amtincom(10) := 0;
        END;

        param_json              := json_object_t(v_datasal);
        param_json_allowance    := json_object_t(get_allowance);
        obj_rowsal              := json_object_t();
        v_row                   := -1;

        FOR i IN 0..9 LOOP
            v_sal_allowance(i+1) := 0;
            v_amtincom(i+1) := 0;
        end loop;

        FOR i IN 0..9 LOOP
            param_json_row              := hcm_util.get_json_t(param_json, TO_CHAR(i));
            param_json_row_allowance    := hcm_util.get_json_t(param_json_allowance, TO_CHAR(i));
            sal_allowance               := hcm_util.get_string_t(param_json_row_allowance, 'amtincom');
            v_codincom                  := hcm_util.get_string_t(param_json_row, 'codincom');
            v_desincom                  := hcm_util.get_string_t(param_json_row, 'desincom');
            v_amtmax                    := hcm_util.get_string_t(param_json_row, 'amtmax');
            v_desunit                   := hcm_util.get_string_t(param_json_row, 'desunit');
            IF v_codincom IS NULL OR v_codincom = ' ' THEN
                EXIT;
            END IF;
            v_row               := v_row + 1;
            obj_data_salary     := json_object_t();
            obj_data_salary.put('codincom', v_codincom);
            obj_data_salary.put('desincom', v_desincom);
            obj_data_salary.put('desunit', v_desunit);
            obj_data_salary.put('amtmax', v_amtmax);

            if (i =0) then
--                obj_data_salary.put('amt', sal_amtincom(i + 1) );
                obj_data_salary.put('amt', p_amtincom1 );
            else
                obj_data_salary.put('amt', sal_allowance );
            end if;
            if (i =0) then
                v_sal_allowance(i+1) := p_amtincom1;
            elsIF ( sal_allowance = 0 OR sal_allowance IS NULL OR sal_allowance = '' ) THEN
                v_sal_allowance(i+1) := 0;
            ELSE
                v_sal_allowance(i+1) := sal_allowance;
            END IF;
            obj_rowsal.put(v_row, obj_data_salary);
        END LOOP;

		get_wage_income(p_codcomp, p_codempmt, v_sal_allowance(1),v_sal_allowance(2), v_sal_allowance(3), v_sal_allowance(4), v_sal_allowance(5),
                        v_sal_allowance(6), v_sal_allowance(7), v_sal_allowance(8), v_sal_allowance(9), v_sal_allowance(10), v_amtothr_income, v_amtday_income, v_sumincom_income);

        obj_sum := json_object_t();
        obj_sum.put('coderror', '200');
        obj_sum.put('datasal', obj_rowsal);
		obj_sum.put('v_sumincom_income', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
		obj_sum.put('v_amtday_income', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
		obj_sum.put('v_amtothr_income', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
        json_str_output := obj_sum.to_clob;
    END genallowance;

	PROCEDURE getincome ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
		TYPE p_num          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		obj_row			    json_object_t;
		dataadj0		    json_object_t;
		v_rcnt			    NUMBER := 0;
		v_codcomp		    temploy1.codcomp%TYPE;
		v_codempid		    temploy1.codempid%TYPE;
		v_codempmt		    temploy1.codempmt%TYPE;
		v_salchage1		    NUMBER;
		v_salchage2		    NUMBER;
		v_salchage3		    NUMBER;
		v_salchage4		    NUMBER;
		v_salchage5		    NUMBER;
		v_salchage6		    NUMBER;
		v_salchage7		    NUMBER;
		v_salchage8		    NUMBER;
		v_salchage9		    NUMBER;
		v_salchage10	    NUMBER;
		v_amtincom1		    NUMBER;
		v_amtincom2		    NUMBER;
		v_amtincom3		    NUMBER;
		v_amtincom4		    NUMBER;
		v_amtincom5		    NUMBER;
		v_amtincom6		    NUMBER;
		v_amtincom7		    NUMBER;
		v_amtincom8		    NUMBER;
		v_amtincom9		    NUMBER;
		v_amtincom10		NUMBER;
		v_amtothr_income	NUMBER := 0;
		v_amtday_income		NUMBER := 0;
		v_sumincom_income	NUMBER := 0;
		v_amtothr_adj		NUMBER := 0;
		v_amtday_adj		NUMBER := 0;
		v_sumincom_adj		NUMBER := 0;
		v_amtothr_simple	NUMBER := 0;
		v_amtday_simple		NUMBER := 0;
		v_sumincom_simple	NUMBER := 0;
		obj_sum			    json_object_t;
		count_arr_income	NUMBER := 0;
		obj_sal_sum		    json_object_t;
		obj_sal			    json_object_t;
		obj_data		    json_object_t;
--        v_codcomp           temploy1.codcomp%type;
--        v_codempmt          temploy1.codempmt%type;
	BEGIN
		obj_data        := json_object_t(json_str_input);
		v_amtincom1     := hcm_util.get_string_t(obj_data, 'dataIncome1');
		v_amtincom2     := hcm_util.get_string_t(obj_data, 'dataIncome2');
		v_amtincom3     := hcm_util.get_string_t(obj_data, 'dataIncome3');
		v_amtincom4     := hcm_util.get_string_t(obj_data, 'dataIncome4');
		v_amtincom5     := hcm_util.get_string_t(obj_data, 'dataIncome5');
		v_amtincom6     := hcm_util.get_string_t(obj_data, 'dataIncome6');
		v_amtincom7     := hcm_util.get_string_t(obj_data, 'dataIncome7');
		v_amtincom8     := hcm_util.get_string_t(obj_data, 'dataIncome8');
		v_amtincom9     := hcm_util.get_string_t(obj_data, 'dataIncome9');
		v_amtincom10    := hcm_util.get_string_t(obj_data, 'dataIncome10');
		v_codempid      := hcm_util.get_string_t(obj_data, 'dataCodempid');
		v_codcomp       := hcm_util.get_string_t(obj_data, 'dataCodcomp');
		v_codempmt      := hcm_util.get_string_t(obj_data, 'dataCodempmt');
		v_codempid      := hcm_util.get_string_t(obj_data, 'dataCodempid');
--		BEGIN
--			SELECT codempmt, hcm_util.get_codcomp_level(codcomp, 1)
--			  INTO v_codempmt, v_codcomp
--			  FROM temploy1
--			 WHERE codempid = v_codempid;
--		EXCEPTION
--		WHEN no_data_found THEN
--			v_codempmt  := NULL;
--			v_codcomp   := NULL;
--		END;

		get_wage_income(v_codcomp, v_codempmt, v_amtincom1,v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                        v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_amtothr_income, v_amtday_income, v_sumincom_income);

		obj_sal := json_object_t();
        obj_sal.put('coderror', '200');
		obj_sal.put('v_sumincom_income', trim(TO_CHAR(v_sumincom_income, '999,999,990.00')));
		obj_sal.put('v_amtday_income', trim(TO_CHAR(v_amtday_income, '999,999,990.00')));
		obj_sal.put('v_amtothr_income', trim(TO_CHAR(v_amtothr_income, '999,999,990.00')));
		json_str_output := obj_sal.to_clob;
	END getincome;
END hrpm21e;

/

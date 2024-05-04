--------------------------------------------------------
--  DDL for Package Body HRPM93X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM93X" is

 procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    pa_codempid         := hcm_util.get_string_t(json_obj,'pa_codempid');
    pa_dtestr           := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dtestr')),'dd/mm/yyyy');
    pa_dteend           := to_date(trim(hcm_util.get_string_t(json_obj,'pa_dteend')),'dd/mm/yyyy');

    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    p_codempid          := hcm_util.get_string_t(param_json,'p_codempid');
    p_numseq            := hcm_util.get_string_t(param_json,'p_numseq');
    p_dteeffec          := to_date(trim(hcm_util.get_string_t(param_json,'p_dteeffec')),'dd/mm/yyyy');
    p_codtrn            := hcm_util.get_string_t(param_json,'p_codtrn');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as
    chk_bool boolean;
    tmp      number;
  BEGIN
    if (pa_codempid is null or pa_codempid = ' ') then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'pa_codempid');
        return ;
    end if;

    if (pa_codempid is not null) then
      begin
         select count(*) into tmp
          from TEMPLOY1
         where codempid = pa_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'pa_codempid');
        return;
      end;
    end if;

    if (pa_dtestr is not null) then
      if(pa_dtestr > pa_dteend) then
         param_msg_error := get_error_msg_php('HR2021',global_v_lang, '');
        return ;
      end if;
    end if;
    if p_codempid = global_v_codempid then
        chk_bool := true;
        v_zupdsal := 'Y';
    else
        chk_bool := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    end if;
    if(chk_bool = false ) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
    return;
  end if;

  END vadidate_variable_getindex;

  procedure get_insert_report(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
    json_obj		      json_object_t;
    param_json_row    json_object_t;
  begin
    begin
      delete from TTEMPRPT
      where CODAPP = 'HRPM93X';
    end;
    json_obj            := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    global_v_coduser    := hcm_util.get_string_t(json_object_t(json_str_input),'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_object_t(json_str_input),'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_object_t(json_str_input),'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_object_t(json_str_input),'p_codempid');

    for i in 0..json_obj.get_size-1 loop
      param_json_row := hcm_util.get_json_t(json_obj,to_char(i));
      p_codempid            := hcm_util.get_string_t(param_json_row,'codempid');
      p_numseq              := hcm_util.get_string_t(param_json_row,'numseq');
      p_dteeffec            := to_date(trim(hcm_util.get_string_t(param_json_row,'dteeffec')),'dd/mm/yyyy');
      p_dteeffecChar        := hcm_util.get_string_t(param_json_row,'dteeffec');
      p_codtrn              := hcm_util.get_string_t(param_json_row,'codtrnnum');
      p_dtestr              := hcm_util.get_string_t(param_json_row,'dtestr');
      p_dteend              := hcm_util.get_string_t(param_json_row,'dteend');
      gen_insert_report();
    end loop;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    /*if param_msg_error is null then
        gen_insert_report(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if; */
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_insert_report as
    --detail
    obj_data         json_object_t;
    obj_row          json_object_t;
    obj_result       json_object_t;
    v_rcnt           NUMBER := 0;
    flag_has_data    NUMBER := 0;
    str_yearmonth    NUMBER;
    str_simplejob    NUMBER;
    str_year         NUMBER;
    str_month        NUMBER;
    str_flgadjin     VARCHAR2(10 CHAR);
    str_codrespr     VARCHAR2(10 CHAR);

    --table
    v_json_input      clob;
    v_json_codincom   clob;
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_codcompy      tcompny.codcompy%type;
    v_codempid      temploy1.codempid%type;
    t_codempid      temploy1.codempid%type;
    v_codempmt      temploy1.codempmt%type;
    v_codcomp       temploy1.codcomp%type;
    type p_num is table of number index by binary_integer;
           v_amtincom  p_num;
           v_amtincadj p_num;
    v_codincom      varchar2(50 char);
    v_desincom      tinexinf.descpaye%type;
    v_desunit       varchar2(150 char);
    v_amtmax        number;
    v_amount        number;
    v_row           number := 0;

    v_amtothr_income      number;
    v_amtday_income       number;
    v_sumincom_income     number;

    v_amtothr_adj         number;
    v_amtday_adj          number;
    v_sumincom_adj        number;

    v_amtothr_simple      number;
    v_amtday_simple       number;
    v_sumincom_simple     number;
    v_image               tempimge.namimage%type;
    v_flgimg              varchar2(2 char) := 'N';

    CURSOR tempdatadefault IS
      SELECT *
      FROM   temploy1
      WHERE  codempid = p_codempid;
    CURSOR tempdatathismove IS
      SELECT *
      FROM   thismove
      WHERE  codempid = p_codempid
             AND numseq = p_numseq
             AND codtrn = p_codtrn
             and DTEEFFEC = p_dteeffec;

  BEGIN

      numYearReport := HCM_APPSETTINGS.get_additional_year();


      SELECT Count(*)
      INTO   flag_has_data
      FROM   thismove
      WHERE  codempid = p_codempid
             AND numseq = p_numseq
             AND codtrn = p_codtrn;
      IF flag_has_data > 0 THEN
        FOR r1 IN tempdatathismove LOOP
            v_rcnt := v_rcnt + 1;
            IF r1.qtydatrq >= 12 THEN
              str_year := Floor(r1.qtydatrq / 12);
              str_month := MOD(r1.qtydatrq, 12);
            ELSE
              str_year := 0;
              str_month := r1.qtydatrq;
            END IF;
            str_simplejob := Floor(r1.dteduepr - r1.dteeffec) + 1;
            IF r1.flgadjin = 'Y' THEN
              str_flgadjin := 'TRUE';
            ELSE
              str_flgadjin := 'FALSE';
            END IF;

            begin
              select '/'||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E1')||'/'||namimage
                into v_image
               from tempimge
               where codempid = p_codempid;
               v_flgimg := 'Y';
            exception when no_data_found then
              v_image := '';
              v_flgimg := 'N';
            end;

            IF r1.qtydatrq >= 12 THEN
              str_year := Floor(r1.qtydatrq / 12);

              str_month := MOD(r1.qtydatrq, 12);
            ELSE
              str_year := 0;

--              str_month := r1.qtydatrq;
              str_month := 0;
            END IF;

            /* format month to year */

            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                  ITEM1,ITEM2,ITEM3,
                                  ITEM4,ITEM5,
                                  ITEM6,ITEM7,
                                  ITEM8,ITEM9,
                                  ITEM10,ITEM11,
                                  ITEM12,ITEM13,
                                  ITEM14,ITEM15,
                                  ITEM16,ITEM17,
                                  ITEM18,ITEM19,
                                  ITEM20,ITEM21,
                                  ITEM22,ITEM23,
                                  ITEM24,ITEM25,
                                  ITEM26,ITEM27,
                                  ITEM28,ITEM29,ITEM30,ITEM31,
                                  ITEM32,ITEM33,
                                  ITEM34,ITEM35,
                                  ITEM36,ITEM37,ITEM38,ITEM39,
                                  ITEM40,ITEM41,
                                  ITEM42,ITEM43,Item44,Item45,
                                  Item46,Item47,Item48,Item49,
                                  item50,item51)
                VALUES (global_v_codempid, 'HRPM93X',nvl(r_numseq,''),
                        nvl(get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang),''), nvl(p_numseq,''), 'detail',
                        nvl(r1.typemp,''), nvl(get_tcodec_name('TCODCATG',r1.typemp,global_v_lang),''),
                        nvl(hcm_util.get_codcomp_level(r1.codcomp, 1),''), nvl(get_tcenter_name(r1.codcomp,global_v_lang),''),
                        nvl(r1.typpayroll,''),
                        nvl(get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang),''),
                        nvl(r1.codpos,''),
                        nvl(get_tpostn_name (r1.codpos,global_v_lang),''),
                        nvl(r1.jobgrade,' '),
                        nvl(get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang),''),
                        nvl(r1.codjob,''),
                        nvl(get_tjobcode_name(r1.codjob,global_v_lang),''),
                        nvl(r1.staemp,''),
                        nvl(get_tlistval_name ('FSTAEMP',r1.staemp,global_v_lang),''),
                        nvl(r1.stapost2,''),
                        nvl(get_tlistval_name ('STAPOST2',r1.stapost2,global_v_lang),''),
                        nvl(r1.codbrlc,''),
                        nvl(get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang),''),
                        nvl(r1.codempmt,''),
                        nvl(get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang),''),
                        nvl(r1.codcalen,''),
                        nvl(get_tcodec_name('TCODWORK',r1.codcalen,global_v_lang),''),
                        nvl(r1.codcurr,' '),
                        nvl(get_tcodec_name('TCODCURR',r1.codcurr,global_v_lang),''),
                        nvl(p_codempid,''),
                        nvl(str_simplejob,0),to_char(nvl(r1.QTYDATRQ,0)),
                        nvl(to_char(add_months(to_date(to_char(r1.dteduepr,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),''),
                        nvl(to_char(add_months(to_date(to_char(r1.dteeval,'dd/mm/yyyy'),'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),''),
                        nvl(r1.scoreget,''),
                        nvl(get_temploy_name(p_codempid,global_v_lang),''),
                        nvl(get_tlistval_name ('NAMEVAL',r1.codrespr,global_v_lang),''),
                        nvl(r1.numannou,''),
                        nvl(r1.numlvl,''),nvl(r1.desnote,''),
                        nvl(p_dteeffecChar,''),
                        nvl(r1.codgrpgl,''),
                        nvl(get_tcodec_name('TCODGRPGL',r1.codgrpgl,global_v_lang),''),
                        nvl(to_char(add_months(to_date(p_dtestr,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),''),
                        nvl(to_char(add_months(to_date(p_dteend,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),''),
                        nvl(r1.flgadjin,''),
                        nvl(to_char(add_months(to_date(p_dteeffecChar,'dd/mm/yyyy'),numYearReport*12),'dd/mm/yyyy'),''),
                        nvl(v_image,''),nvl(v_flgimg,''),nvl(str_year,''),nvl(str_month,''),
                        nvl(r1.ocodempid,''), r1.codexemp||' - '||get_tcodec_name('TCODEXEM',r1.codexemp, global_v_lang));
                        r_numseq := r_numseq + 1;
        END LOOP;
      ELSE
        FOR r1 IN tempdatadefault LOOP
            v_rcnt := v_rcnt + 1;
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
                ,ITEM1,ITEM2,ITEM3
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
                ,ITEM26,ITEM27
                ,ITEM28,ITEM29,ITEM30,ITEM31
                ,ITEM32,ITEM33
                ,ITEM34,ITEM35
                ,ITEM36,ITEM37,ITEM38,ITEM39
                ,ITEM40,ITEM41
                ,ITEM42,ITEM43)
				VALUES (global_v_codempid, 'HRPM93X',r_numseq
                ,get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang),p_numseq,'table'
                ,r1.typemp,get_tcodec_name('codtypemp',r1.typemp,global_v_lang)
                ,r1.codcomp,get_tcenter_name(r1.codcomp,global_v_lang)
                ,r1.typpayroll,get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang)
                ,r1.codpos,get_tpostn_name (r1.codpos,global_v_lang)
                ,r1.jobgrade,get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang)
                ,r1.codjob,get_tcodec_name('TCODJOBG',r1.codjob,global_v_lang)
                ,r1.staemp,get_tlistval_name ('FLGSTAEMP',r1.staemp,global_v_lang)
                ,'',''
                ,r1.codbrlc,get_tcodec_name('TCODLOCA',r1.codbrlc,global_v_lang)
                ,r1.codempmt,get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang)
                ,r1.codcalen,get_tcodec_name('TCODWORK',r1.codcalen,global_v_lang)
                ,'',''
                ,p_codempid,'','',''
                ,get_temploy_name(p_codempid,global_v_lang),''
                ,'',''
                ,r1.numreqc,r1.numlvl,'',p_dteeffecChar
                ,r1.codgrpgl,get_tcodec_name('TCODGRPGL',r1.codgrpgl,global_v_lang)
                ,p_dtestr,p_dteend);
                r_numseq := r_numseq + 1;
        END LOOP;
      END IF;
      -- table
      begin
      select  codempid,codempmt,codcomp,
              stddec(AMTINCOM1,p_codempid,global_v_chken),
              stddec(AMTINCOM2,p_codempid,global_v_chken),
              stddec(AMTINCOM3,p_codempid,global_v_chken),
              stddec(AMTINCOM4,p_codempid,global_v_chken),
              stddec(AMTINCOM5,p_codempid,global_v_chken),
              stddec(AMTINCOM6,p_codempid,global_v_chken),
              stddec(AMTINCOM7,p_codempid,global_v_chken),
              stddec(AMTINCOM8,p_codempid,global_v_chken),
              stddec(AMTINCOM9,p_codempid,global_v_chken),
              stddec(AMTINCOM10,p_codempid,global_v_chken),
              stddec(AMTINCADJ1,p_codempid,global_v_chken),
              stddec(AMTINCADJ2,p_codempid,global_v_chken),
              stddec(AMTINCADJ3,p_codempid,global_v_chken),
              stddec(AMTINCADJ4,p_codempid,global_v_chken),
              stddec(AMTINCADJ5,p_codempid,global_v_chken),
              stddec(AMTINCADJ6,p_codempid,global_v_chken),
              stddec(AMTINCADJ7,p_codempid,global_v_chken),
              stddec(AMTINCADJ8,p_codempid,global_v_chken),
              stddec(AMTINCADJ9,p_codempid,global_v_chken),
              stddec(AMTINCADJ10,p_codempid,global_v_chken)
      into    v_codempid, v_codempmt, v_codcomp,
              v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
              v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),v_amtincadj(4),v_amtincadj(5),
              v_amtincadj(6),v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),v_amtincadj(10)
      FROM  THISMOVE
      where codempid = p_codempid
      and DTEEFFEC = p_dteeffec
      and NUMSEQ = p_numseq
      order by DTEEFFEC ;
    exception when no_data_found then
      v_amtincom(1)   := 0;
      v_amtincom(2)   := 0;
      v_amtincom(3)   := 0;
      v_amtincom(4)   := 0;
      v_amtincom(5)   := 0;
      v_amtincom(6)   := 0;
      v_amtincom(7)   := 0;
      v_amtincom(8)   := 0;
      v_amtincom(9)   := 0;
      v_amtincom(10)  := 0;
      v_amtincadj(1)   := 0;
      v_amtincadj(2)   := 0;
      v_amtincadj(3)   := 0;
      v_amtincadj(4)   := 0;
      v_amtincadj(5)   := 0;
      v_amtincadj(6)   := 0;
      v_amtincadj(7)   := 0;
      v_amtincadj(8)   := 0;
      v_amtincadj(9)   := 0;
      v_amtincadj(10)  := 0;
    end;

      SELECT codempmt,
             codcomp,
             hcm_util.get_codcomp_level(codcomp,1)
      INTO   v_codempmt,v_codcomp,v_codcompy
      FROM   temploy1
      WHERE  codempid = p_codempid
      and rownum = 1;
    v_json_input := '{"p_codcompy":"'
                      ||v_codcompy
                      ||'","p_dteeffec":"'
                      ||To_char(SYSDATE, 'ddmmyyyy')
                      ||'","p_codempmt":"'
                      ||v_codempmt
                      ||'","p_lang":"'
                      ||global_v_lang
                      ||'"}';
    v_json_codincom   := hcm_pm.get_codincom(v_json_input);
    param_json        := json_object_t(v_json_codincom);
    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codincom          := nvl(hcm_util.get_string_t(param_json_row,'codincom'),'no_data');
      v_desincom          := hcm_util.get_string_t(param_json_row,'desincom');
      v_desunit           := hcm_util.get_string_t(param_json_row,'desunit');
      v_amtmax            := hcm_util.get_string_t(param_json_row,'amtmax');
      v_row       := v_row + 1;


        if v_amtmax is null then
            v_amtmax := 0;
        end if;

        if v_amount is null then
            v_amount := 0;
        end if;
        if v_codincom != 'no_data' then
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
                    ,ITEM1,ITEM2,ITEM3
                    ,ITEM4,ITEM5,ITEM6
                    ,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
            VALUES (global_v_codempid, 'HRPM93X',r_numseq
                    ,p_codtrn,p_numseq,'table'
                    ,v_codincom,v_desincom,v_desunit
                    ,to_char(v_amtincom(i + 1) - v_amtincadj(i + 1),'999,999,990.00')
                    ,to_char(v_amtincadj(i + 1),'999,999,990.00')
                    ,to_char(v_amtincom(i + 1),'999,999,990.00')
                    ,p_dteeffecChar,p_codempid);
                    r_numseq := r_numseq + 1;

        end if;
       /*
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',v_codempid);
        obj_data.put('codincom',v_codincom);
        obj_data.put('desincom',v_desincom);
        obj_data.put('desunit',v_desunit);
        obj_data.put('amtmax',to_char(v_amtincadj(i + 1),'999,999,990.00'));
        obj_data.put('amtincom',to_char(v_amtincom(i + 1),'999,999,990.00'));
        obj_data.put('amount',to_char(v_amtincom(i + 1) + v_amtincadj(i + 1),'999,999,990.00'));
        obj_row.put(v_row - 1, obj_data);  */
   end loop;
    -- income
		Get_wage_income(v_codcompy, v_codempmt,
                        v_amtincom(1) - v_amtincadj(1),
                        v_amtincom(2) - v_amtincadj(2),
                        v_amtincom(3) - v_amtincadj(3),
                        v_amtincom(4) - v_amtincadj(4),
                        v_amtincom(5) - v_amtincadj(5),
                        v_amtincom(6) - v_amtincadj(6),
                        v_amtincom(7) - v_amtincadj(7),
                        v_amtincom(8) - v_amtincadj(8),
                        v_amtincom(9) - v_amtincadj(9),
                        v_amtincom(10) - v_amtincadj(10), 
                        v_amtothr_simple,v_amtday_simple,v_sumincom_simple);

        Get_wage_income(v_codcompy, v_codempmt, v_amtincadj(1), v_amtincadj(2),
		v_amtincadj(3), v_amtincadj(4), v_amtincadj(5), v_amtincadj(6), v_amtincadj(7), v_amtincadj(8),
		v_amtincadj(9), v_amtincadj(10), v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

        Get_wage_income(v_codcompy, v_codempmt, v_amtincom(1), v_amtincom(2),
		v_amtincom(3),v_amtincom(4), v_amtincom(5), v_amtincom(6), v_amtincom(7), v_amtincom(8),
		v_amtincom(9),v_amtincom(10), v_amtothr_income, v_amtday_income, v_sumincom_income);


           INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
                    ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5
                    ,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
            VALUES (global_v_codempid, 'HRPM93X',r_numseq
                    ,p_codtrn,p_numseq,'table'
                    ,'','',get_label_name('HRPM93X3',global_v_lang,440)
                    ,TRIM(to_char(v_sumincom_simple,'999,999,990.00'))
                    ,TRIM(to_char(v_sumincom_adj,'999,999,990.00'))
                    ,TRIM(to_char(v_sumincom_income,'999,999,990.00'))
                    ,p_dteeffecChar,p_codempid);
           r_numseq := r_numseq + 1;
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
                    ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5
                    ,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
            VALUES (global_v_codempid, 'HRPM93X',r_numseq
                    ,p_codtrn,p_numseq,'table'
                    ,'','',get_label_name('HRPM93X3',global_v_lang,450)
                    ,TRIM(to_char(v_amtday_simple,'999,999,990.00'))
                    ,TRIM(to_char(v_amtday_adj,'999,999,990.00'))
                    ,TRIM(to_char(v_amtday_income,'999,999,990.00'))
                    ,p_dteeffecChar,p_codempid);
           r_numseq := r_numseq + 1;
            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ
                    ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5
                    ,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
            VALUES (global_v_codempid, 'HRPM93X',r_numseq
                    ,p_codtrn,p_numseq,'table'
                    ,'','',get_label_name('HRPM93X3',global_v_lang,460)
                    ,TRIM(to_char(v_amtothr_simple,'999,999,990.00'))
                    ,TRIM(to_char(v_amtothr_adj,'999,999,990.00'))
                    ,TRIM(to_char(v_amtothr_income,'999,999,990.00'))
                    ,p_dteeffecChar,p_codempid);
            r_numseq := r_numseq + 1;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_data			    varchar2(1) := 'N';
    v_ocodempid     varchar2(200)  := GET_OCODEMPID(pa_codempid);

    cursor c1 is
      select codempid,desnote,codcurr,codcomp,codempmt,numseq,codtrn,codpos,codjob,dteeffec,numlvl,typpayroll,flgadjin,codappr,rowid,jobgrade
        from thismove
       where (codempid = pa_codempid or v_ocodempid like '[%'||codempid||']%')
         and dteeffec between pa_dtestr and pa_dteend
    order by dteeffec desc,numseq desc;


  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_data := 'Y';
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('codcomp', nvl(get_tcenter_name(r1.codcomp,global_v_lang),''));
      obj_data.put('codempmt', r1.codempmt);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('codtrn', get_tcodec_name('TCODMOVE',r1.codtrn, global_v_lang));
      obj_data.put('codtrnnum', r1.codtrn);
      obj_data.put('codpos', nvl(get_tpostn_name(r1.codpos,global_v_lang),''));
      obj_data.put('codjob', nvl(get_tjobcode_name(r1.codjob, global_v_lang ),''));
      obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('numlvl', r1.numlvl );
      obj_data.put('typpayroll', r1.typpayroll );
      obj_data.put('flgadjin', r1.flgadjin );
      obj_data.put('desnote', r1.desnote );
      obj_data.put('codcurr', nvl(get_tcodec_name('TCODCURR',r1.codcurr,global_v_lang),''));
      obj_data.put('jobgrade', get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang));
      obj_data.put('rowid', r1.rowid );
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_data = 'N' then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'THISMOVE');
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

  procedure get_detail(json_str_input  in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_detail(json_str_output);
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack ||' ' ||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  PROCEDURE gen_detail(json_str_output OUT CLOB) AS
    obj_data         json_object_t;
    obj_data_typwork json_object_t;
    obj_data_table   json_object_t;
    obj_sub_json     json_object_t;
    obj_row          json_object_t;
    obj_result       json_object_t;
    v_rcnt           number := 0;
    flag_has_data    number := 0;
    str_yearmonth    number;
    str_simplejob    number;
    str_year         number;
    str_month        number;
    str_flgadjin     boolean;
    str_codrespr     varchar2(10 char);

    cursor tempdatadefault is
      select *
      from   temploy1
      where  codempid = p_codempid;
    cursor tempdatathismove is
      select *
      from   thismove
      where  codempid = p_codempid
             and numseq = p_numseq
             and codtrn = p_codtrn
             and dteeffec = p_dteeffec;
    chk_bool boolean;
    v_saldisabled boolean;
  begin
      select count(*)
        into flag_has_data
        from thismove
       where codempid = p_codempid
         and numseq = p_numseq
         and codtrn = p_codtrn;

     if p_codempid = global_v_codempid then
        v_zupdsal   := 'Y';
        chk_bool    := true;
     else
        chk_bool := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
     end if;

     if v_zupdsal = 'Y' then
        v_saldisabled := false;
     else
        v_saldisabled := true;
     end if;

      /* check search has data in system*/
      IF flag_has_data > 0 THEN
        obj_row           := json_object_t();
        obj_data          := json_object_t();
        obj_sub_json      := json_object_t();
        obj_data_typwork  := json_object_t();

        FOR r1 IN tempdatathismove LOOP
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_sub_json := json_object_t();
          obj_data.Put('coderror', '200');
          obj_data.Put('rcnt', To_char(v_rcnt));
          obj_data.Put('numreqc', r1.numannou);
          obj_data.Put('typemp', r1.typemp);
          obj_data.Put('codcomp', nvl(r1.codcomp,''));
          obj_data.Put('typpayroll', r1.typpayroll);
          obj_data.Put('codpos', nvl(r1.codpos,''));
          obj_data.Put('jobgrade', r1.jobgrade);
          obj_data.Put('numlvl', r1.numlvl);
          obj_data.Put('codjob', nvl(r1.codjob,''));
          obj_data.Put('codgrpgl', nvl(r1.codgrpgl,''));
          obj_data.Put('numlvl2', r1.numlvl);
          obj_data.Put('staemp', r1.staemp);
          obj_data.Put('stapost2', r1.stapost2);
          obj_data.Put('codbrlc', nvl(r1.codbrlc,''));
          obj_data.Put('typemp2', r1.typemp);
          obj_data.Put('codempmt1', nvl(r1.codempmt,''));
          obj_data.Put('codempmt2', nvl(r1.CODCALEN,''));
          obj_data.Put('desnote', r1.desnote);
          obj_data.Put('codcurr', nvl(r1.codcurr,''));
          obj_data.Put('ocodempid', r1.ocodempid);
          obj_data.Put('saldisabled', v_saldisabled);
          --<<User37 #5533 Final Test Phase 1 V11 23/03/2021
          obj_data.Put('desc_codcomp', nvl(get_tcenter_name(r1.codcomp,global_v_lang),''));
          obj_data.Put('desc_codpos', nvl(get_tpostn_name(r1.codpos,global_v_lang),''));
          obj_data.put('desc_codjob', nvl(get_tjobcode_name(r1.codjob,global_v_lang),''));
          obj_data.put('desc_codbrlc', nvl(get_tcodloca_name(r1.codbrlc,global_v_lang),''));
          obj_data.put('desc_codempmt1', nvl(get_tcodec_name('TCODEMPL', r1.codempmt, global_v_lang),''));
          obj_data.Put('codcalen', nvl(r1.codcalen,''));
          obj_data.put('desc_codcalen', nvl(get_tcodec_name('TCODWORK',r1.codcalen,global_v_lang),''));
          obj_data.put('desc_typemp', nvl(get_tcodec_name('TCODCATG', r1.typemp, global_v_lang),''));
          obj_data.put('desc_typpayroll', nvl(get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang),''));
          obj_data.put('desc_jobgrade', nvl(get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang),''));
          obj_data.put('desc_codgrpgl', nvl(get_tcodec_name('TCODGRPGL',r1.codgrpgl,global_v_lang),''));
          obj_data.put('desc_staemp', nvl(get_tlistval_name('NAMESTAT',r1.staemp,global_v_lang),''));
          obj_data.put('desc_stapost2', nvl(get_tlistval_name('STAPOST2',r1.stapost2,global_v_lang),''));
          obj_data.put('desc_codcurr', nvl(get_tcodec_name('TCODCURR',r1.codcurr,global_v_lang),''));
          -->>User37 #5533 Final Test Phase 1 V11 23/03/2021
          obj_sub_json.Put('syncond', obj_data);

          /* format month to year */
          IF r1.qtydatrq >= 12 THEN
            str_year := Floor(r1.qtydatrq / 12);
            str_month := MOD(r1.qtydatrq, 12);
          ELSE
            str_year := 0;
            str_month := r1.qtydatrq;
          END IF;

          /* format month to year */
          str_simplejob := Floor(r1.dteduepr - r1.dteeffec) + 1;
          IF r1.flgadjin = 'Y' THEN
            str_flgadjin := TRUE;
          ELSE
            str_flgadjin := FALSE;
          END IF;

          obj_data_typwork.Put('samplejob', str_simplejob);
          obj_data_typwork.Put('hireyear', str_year);
          obj_data_typwork.Put('hiremonth', str_month);
          obj_data_typwork.Put('dteduepr', nvl(To_char(r1.dteduepr, 'dd/mm/yyyy'),''));
          obj_data_typwork.Put('dteeval', nvl(To_char(r1.dteeval, 'dd/mm/yyyy'),''));
          obj_data_typwork.Put('scoreget', r1.scoreget);
          obj_data_typwork.Put('status', r1.codrespr);
          obj_data_typwork.Put('flgadjin', r1.flgadjin);--User37 #5533 Final Test Phase 1 V11 23/03/2021 obj_data_typwork.Put('flgadjin', str_flgadjin);
          obj_data_typwork.Put('codexemp', nvl(r1.codexemp,''));
          --<<User37 #5533 Final Test Phase 1 V11 23/03/2021
          obj_data.put('desc_status', nvl(get_tlistval_name('CODRESPR', r1.codrespr, global_v_lang),''));
          obj_data.put('desc_codexemp', nvl(get_tcodec_name('TCODEXEM',r1.codexemp,global_v_lang),''));
          -->>User37 #5533 Final Test Phase 1 V11 23/03/2021
          obj_sub_json.Put('typwork', obj_data_typwork);
          obj_row.Put(To_char(v_rcnt - 1), obj_sub_json);
        END LOOP;
      ELSE
        obj_row           := json_object_t();
        obj_data          := json_object_t();
        obj_sub_json      := json_object_t();
        obj_data_typwork  := json_object_t();

        FOR r1 IN tempdatadefault LOOP
            v_rcnt := v_rcnt + 1;
            obj_data := json_object_t();
            obj_sub_json := json_object_t();
            obj_data.Put('coderror', '200');
            obj_data.Put('rcnt', To_char(v_rcnt));
            obj_data.Put('numreqc', r1.numreqc);
            obj_data.Put('typemp', r1.typemp);
            obj_data.Put('codcomp', nvl(r1.codcomp,''));
            obj_data.Put('typpayroll', r1.typpayroll);
            obj_data.Put('codpos', nvl(r1.codpos,''));
            obj_data.Put('jobgrade', r1.jobgrade);
            obj_data.Put('numlvl', r1.numlvl);
            obj_data.Put('codjob', nvl(r1.codjob,''));
            obj_data.Put('codgrpgl', nvl(r1.codgrpgl,''));
            obj_data.Put('numlvl2', r1.numlvl);
            obj_data.Put('staemp', r1.staemp);
            obj_data.Put('stapost2', '');
            obj_data.Put('codbrlc', nvl(r1.codbrlc,''));
            obj_data.Put('typemp2', r1.typemp);
            obj_data.Put('codempmt1', nvl(r1.codempmt,''));
            obj_data.Put('codempmt2', nvl(r1.CODCALEN,''));
            obj_data.Put('desnote', '');
            obj_data.Put('ocodempid', '');
            obj_data.Put('saldisabled', v_saldisabled);
            --<<User37 #5533 Final Test Phase 1 V11 23/03/2021
            obj_data.Put('desc_codcomp', nvl(get_tcenter_name(r1.codcomp,global_v_lang),''));
            obj_data.Put('desc_codpos', nvl(get_tpostn_name(r1.codpos,global_v_lang),''));
            obj_data.put('desc_codjob', nvl(get_tjobcode_name(r1.codjob,global_v_lang),''));
            obj_data.put('desc_codbrlc', nvl(get_tcodloca_name(r1.codbrlc,global_v_lang),''));
            obj_data.put('desc_codempmt1', nvl(get_tcodec_name('TCODEMPL', r1.codempmt, global_v_lang),''));
            obj_data.Put('codcalen', nvl(r1.codcalen,''));
            obj_data.put('desc_codcalen', nvl(get_tcodec_name('TCODWORK',r1.codcalen,global_v_lang),''));
            obj_data.put('desc_typemp', nvl(get_tcodec_name('TCODCATG', r1.typemp, global_v_lang),''));
            obj_data.put('desc_typpayroll', nvl(get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang),''));
            obj_data.put('desc_jobgrade', nvl(get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang),''));
            obj_data.put('desc_codgrpgl', nvl(get_tcodec_name('TCODGRPGL',r1.codgrpgl,global_v_lang),''));
            obj_data.put('desc_staemp', nvl(get_tlistval_name('NAMESTAT',r1.staemp,global_v_lang),''));
            -->>User37 #5533 Final Test Phase 1 V11 23/03/2021
            obj_sub_json.Put('syncond', obj_data);
            obj_data_typwork.Put('samplejob', '');
            obj_data_typwork.Put('hireyear', '');
            obj_data_typwork.Put('hiremonth', '');
            obj_data_typwork.Put('dteduepr', '');
            obj_data_typwork.Put('dteeval', '');
            obj_data_typwork.Put('scoreget', '');
            obj_data_typwork.Put('status', '1');
            --<<User37 #5533 Final Test Phase 1 V11 23/03/2021
            --obj_data_typwork.Put('flgadjin', FALSE);
            obj_data_typwork.Put('flgadjin', 'N');
            obj_data.put('desc_status', nvl(get_tlistval_name('CODRESPR', '1', global_v_lang),''));
            -->>User37 #5533 Final Test Phase 1 V11 23/03/2021
            obj_sub_json.Put('typwork', obj_data_typwork);

            obj_row.Put(To_char(v_rcnt - 1), obj_sub_json);
        END LOOP;
      END IF;
      json_str_output := obj_row.to_clob;
  EXCEPTION WHEN OTHERS THEN
    param_msg_error := dbms_utility.format_error_stack ||' ' ||dbms_utility.format_error_backtrace;
    json_str_output := Get_response_message('400', param_msg_error, global_v_lang) ;
  END;
  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as obj_row json;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_table(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob)as
    obj_data          json_object_t;
    obj_row           json_object_t;
    obj_result        json_object_t;
    v_json_codincom   clob;
    v_rcnt            number := 0;
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_json_input      clob;
    v_codcompy        tcompny.codcompy%type;
    v_codempid        temploy1.codempid%type;
    v_codempmt        temploy1.codempmt%type;
    v_codcomp         temploy1.codcomp%type;
    type p_num is table of number index by binary_integer;
           v_amtincom  p_num;
           v_amtincadj p_num;
    v_codincom      tinexinf.codpay%type;
    v_desincom      tinexinf.descpaye%type;
    v_desunit       varchar2(150 char);
    v_amtmax        number;
    v_amount        number;
    v_row           number := 0;

    v_amtothr_income     number;
    v_amtday_income      number;
    v_sumincom_income    number;
    v_amtothr_adj        number;
    v_amtday_adj         number;
    v_sumincom_adj       number;
    v_amtothr_simple     number;
    v_amtday_simple      number;
    v_sumincom_simple    number;

    v_ocodempid   varchar2(200)  := GET_OCODEMPID(pa_codempid);

      /*  cursor c1 is    select * from THISMOVE
                        where codempid = p_codempid
                        and to_char(DTEEFFEC) = p_dteeffec
                        and NUMSEQ = p_numseq
                        order by DTEEFFEC ;
*/

  begin
    obj_row    := json_object_t();
    begin
      select  codempid,codempmt,codcomp,
              --<<User37 #5533 Final Test Phase 1 V11 23/03/2021
              /*stddec(AMTINCOM1,p_codempid,global_v_chken),
              stddec(AMTINCOM2,p_codempid,global_v_chken),
              stddec(AMTINCOM3,p_codempid,global_v_chken),
              stddec(AMTINCOM4,p_codempid,global_v_chken),
              stddec(AMTINCOM5,p_codempid,global_v_chken),
              stddec(AMTINCOM6,p_codempid,global_v_chken),
              stddec(AMTINCOM7,p_codempid,global_v_chken),
              stddec(AMTINCOM8,p_codempid,global_v_chken),
              stddec(AMTINCOM9,p_codempid,global_v_chken),
              stddec(AMTINCOM10,p_codempid,global_v_chken),
              stddec(AMTINCADJ1,p_codempid,global_v_chken),
              stddec(AMTINCADJ2,p_codempid,global_v_chken),
              stddec(AMTINCADJ3,p_codempid,global_v_chken),
              stddec(AMTINCADJ4,p_codempid,global_v_chken),
              stddec(AMTINCADJ5,p_codempid,global_v_chken),
              stddec(AMTINCADJ6,p_codempid,global_v_chken),
              stddec(AMTINCADJ7,p_codempid,global_v_chken),
              stddec(AMTINCADJ8,p_codempid,global_v_chken),
              stddec(AMTINCADJ9,p_codempid,global_v_chken),
              stddec(AMTINCADJ10,p_codempid,global_v_chken)*/
              greatest(0,stddec(AMTINCOM1,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM2,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM3,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM4,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM5,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM6,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM7,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM8,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM9,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCOM10,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ1,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ2,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ3,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ4,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ5,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ6,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ7,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ8,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ9,p_codempid,global_v_chken)),
              greatest(0,stddec(AMTINCADJ10,p_codempid,global_v_chken))
              -->>User37 #5533 Final Test Phase 1 V11 23/03/2021
      into    v_codempid, v_codempmt, v_codcomp,
              v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
              v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
              v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),v_amtincadj(4),v_amtincadj(5),
              v_amtincadj(6),v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),v_amtincadj(10)
      FROM  THISMOVE
      where codempid = p_codempid
      and DTEEFFEC = p_dteeffec
      and NUMSEQ = p_numseq
      order by DTEEFFEC ;
    exception when no_data_found then
      v_amtincom(1)   := 0;
      v_amtincom(2)   := 0;
      v_amtincom(3)   := 0;
      v_amtincom(4)   := 0;
      v_amtincom(5)   := 0;
      v_amtincom(6)   := 0;
      v_amtincom(7)   := 0;
      v_amtincom(8)   := 0;
      v_amtincom(9)   := 0;
      v_amtincom(10)  := 0;
      v_amtincadj(1)   := 0;
      v_amtincadj(2)   := 0;
      v_amtincadj(3)   := 0;
      v_amtincadj(4)   := 0;
      v_amtincadj(5)   := 0;
      v_amtincadj(6)   := 0;
      v_amtincadj(7)   := 0;
      v_amtincadj(8)   := 0;
      v_amtincadj(9)   := 0;
      v_amtincadj(10)  := 0;
    end;
      SELECT codempmt,
             codcomp,
             hcm_util.get_codcomp_level(codcomp,1)
      INTO   v_codempmt,v_codcomp,v_codcompy
      FROM   temploy1
      WHERE  codempid = p_codempid and rownum = 1;

    v_json_input := '{"p_codcompy":"'
                      ||v_codcompy
                      ||'","p_dteeffec":"'
                      ||To_char(SYSDATE, 'ddmmyyyy')
                      ||'","p_codempmt":"'
                      ||v_codempmt
                      ||'","p_lang":"'
                      ||global_v_lang
                      ||'"}';
    v_json_codincom   := hcm_pm.get_codincom(v_json_input);
    param_json        := json_object_t(v_json_codincom);

    for i in 0..param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codincom          := hcm_util.get_string_t(param_json_row,'codincom');
      v_desincom          := hcm_util.get_string_t(param_json_row,'desincom');
      v_desunit           := hcm_util.get_string_t(param_json_row,'desunit');
      v_amtmax            := hcm_util.get_string_t(param_json_row,'amtmax');


        if v_amtmax is null then
            v_amtmax := 0;
        end if;

        if v_amount is null then
            v_amount := 0;
        end if;

        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codempid',v_codempid);
        obj_data.put('codincom',v_codincom);
        obj_data.put('desincom',v_desincom);
        obj_data.put('desunit',v_desunit);
--        obj_data.put('amtmax',to_char(v_amtincadj(i + 1),'999,999,990.00'));
--        obj_data.put('amtincom',to_char(v_amtincom(i + 1),'999,999,990.00'));
--        obj_data.put('amount',to_char(v_amtincom(i + 1) + v_amtincadj(i + 1),'999,999,990.00'));
        obj_data.put('amtmax',to_char(v_amtincadj(i + 1),'999,999,990.00'));
        obj_data.put('amtincom',to_char(v_amtincom(i + 1) - v_amtincadj(i + 1),'999,999,990.00'));
        obj_data.put('amount',to_char(v_amtincom(i + 1),'999,999,990.00'));
        if v_codincom is not null then
          v_row       := v_row + 1;
          obj_row.put(v_row - 1, obj_data);
        end if;
    end loop;

    -- income
--		Get_wage_income(v_codcompy, v_codempmt, v_amtincom(1), v_amtincom(2),
--		v_amtincom(3),v_amtincom(4), v_amtincom(5), v_amtincom(6), v_amtincom(7), v_amtincom(8),
--		v_amtincom(9),v_amtincom(10), v_amtothr_income, v_amtday_income, v_sumincom_income);
		Get_wage_income(v_codcompy, v_codempmt,
                        v_amtincom(1) - v_amtincadj(1),
                        v_amtincom(2) - v_amtincadj(2),
                        v_amtincom(3) - v_amtincadj(3),
                        v_amtincom(4) - v_amtincadj(4),
                        v_amtincom(5) - v_amtincadj(5),
                        v_amtincom(6) - v_amtincadj(6),
                        v_amtincom(7) - v_amtincadj(7),
                        v_amtincom(8) - v_amtincadj(8),
                        v_amtincom(9) - v_amtincadj(9),
                        v_amtincom(10) - v_amtincadj(10), 
                        v_amtothr_income, v_amtday_income, v_sumincom_income);

        Get_wage_income(v_codcompy, v_codempmt, v_amtincadj(1), v_amtincadj(2),
		v_amtincadj(3), v_amtincadj(4), v_amtincadj(5), v_amtincadj(6), v_amtincadj(7), v_amtincadj(8),
		v_amtincadj(9), v_amtincadj(10), v_amtothr_adj, v_amtday_adj, v_sumincom_adj);

--        Get_wage_income(v_codcompy, v_codempmt,
--    v_amtincom(1) + v_amtincadj(1),
--		v_amtincom(2) + v_amtincadj(2),
--    v_amtincom(3) + v_amtincadj(3),
--		v_amtincom(4) + v_amtincadj(4),
--    v_amtincom(5) + v_amtincadj(5),
--		v_amtincom(6) + v_amtincadj(6),
--		v_amtincom(7) + v_amtincadj(7),
--    v_amtincom(8) + v_amtincadj(8),
--		v_amtincom(9) + v_amtincadj(9),
--    v_amtincom(10) + v_amtincadj(10), v_amtothr_simple,v_amtday_simple,v_sumincom_simple);
		Get_wage_income(v_codcompy, v_codempmt, v_amtincom(1), v_amtincom(2),
		v_amtincom(3),v_amtincom(4), v_amtincom(5), v_amtincom(6), v_amtincom(7), v_amtincom(8),
		v_amtincom(9),v_amtincom(10), v_amtothr_simple,v_amtday_simple,v_sumincom_simple);

     v_row       := v_row +1;
     obj_data   := json_object_t();
     obj_data.put('coderror','200');
     obj_data.put('desunit',get_label_name('HRPM93X3',global_v_lang,440));
     obj_data.put('amount',TRIM(to_char(v_sumincom_simple,'999,999,990.00')));
     obj_data.put('amtmax',TRIM(to_char(v_sumincom_adj,'999,999,990.00')));
     obj_data.put('amtincom',TRIM(to_char(v_sumincom_income,'999,999,990.00')));
     obj_row.put(v_row - 1, obj_data);
     v_row       := v_row +1;
     obj_data   := json_object_t();
     obj_data.put('coderror','200');
     obj_data.put('desunit',get_label_name('HRPM93X3',global_v_lang,450));
     obj_data.put('amount',TRIM(to_char(v_amtday_simple,'999,999,990.00')));
     obj_data.put('amtmax',TRIM(to_char(v_amtday_adj,'999,999,990.00')));
     obj_data.put('amtincom',TRIM(to_char(v_amtday_income,'999,999,990.00')));
     obj_row.put(v_row - 1, obj_data);
     v_row       := v_row +1;
     obj_data   := json_object_t();
     obj_data.put('coderror','200');
     obj_data.put('desunit',get_label_name('HRPM93X3',global_v_lang,460));
     obj_data.put('amount',TRIM(to_char(v_amtothr_simple,'999,999,990.00')));
     obj_data.put('amtmax',TRIM(to_char(v_amtothr_adj,'999,999,990.00')));
     obj_data.put('amtincom',Trim(To_char(v_amtothr_income, '999,999,990.00')));
     obj_row.put(v_row - 1, obj_data);

    json_str_output := obj_row.to_clob;
    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

end HRPM93X;

/

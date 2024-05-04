--------------------------------------------------------
--  DDL for Package Body HRPM43X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM43X" is

  PROCEDURE initial_value ( json_str IN CLOB ) IS
    json_obj   json_object_t := json_object_t(json_str);
  BEGIN
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcodec          := hcm_util.get_string_t(json_obj,'p_codcodec');
    p_staupd            := hcm_util.get_string_t(json_obj,'p_staupd');
    p_dtestr            := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dtestrt') ),'dd/mm/yyyy');
    p_dteend            := TO_DATE(trim(hcm_util.get_string_t(json_obj,'p_dteend') ),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  PROCEDURE check_getindex IS
      v_codcomp         VARCHAR2(100);
      v_typmove         VARCHAR2(100);
      v_secur_codcomp   BOOLEAN;
  BEGIN
      IF p_codcomp IS NULL THEN
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      END IF;

      IF p_dtestr IS NULL THEN
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      END IF;

      IF p_dteend IS NULL THEN
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      END IF;

      IF p_dteend < p_dtestr THEN
          param_msg_error := get_error_msg_php('HR2021',global_v_lang);
          return;
      END IF;

      IF p_codcodec IS NOT NULL THEN
          BEGIN
              SELECT
                  codcodec,
                  typmove
              INTO
                  v_codcodec,
                  v_typmove
              FROM
                  tcodmove
              WHERE
                  codcodec = p_codcodec;

          EXCEPTION
              WHEN no_data_found THEN
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODMOVE');
                  return;
              WHEN OTHERS THEN
                  param_msg_error := dbms_utility.format_error_stack
                                     || ' '
                                     || dbms_utility.format_error_backtrace;
                  return;
          END;


          IF v_typmove IN (
              '1',
              '2',
              '3',
              '4'
          ) THEN
              param_msg_error := get_error_msg_php('PM0040',global_v_lang);
              return;
          END IF;
      END IF;

      v_secur_codcomp := secur_main.secur7(v_codcomp,global_v_coduser);
      IF v_secur_codcomp = false THEN  -- Check User authorize view codcomp
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
      END IF;

  END;

  PROCEDURE gen_data ( json_str_output OUT CLOB ) IS
      v_rcnt             NUMBER := 0;
      v_rcnt_main        NUMBER := 0;
      v_secur_codempid   BOOLEAN;
      countrow           number;
      v_imageh           tempimge.namimage%type;
      v_folder           tfolderd.folder%type;
      v_has_image        varchar2(1) := 'N';
      v_table            varchar2(500);
      v_numseq_secpos   number;

      CURSOR c_tcodmove IS
          SELECT codcodec, typmove
            FROM tcodmove
           WHERE codcodec LIKE nvl(p_codcodec,codcodec);

      c2                 SYS_REFCURSOR;
  BEGIN
      obj_main    := json_object_t ();
      obj_main1   := json_object_t ();
      obj_main.put('coderror',200);
      v_rcnt      := 0;
      countrow    := 0;
      v_rcnt_main := 0;
      FOR i IN c_tcodmove LOOP
          IF ( i.codcodec = '0005' AND p_codcodec IS NULL ) OR p_codcodec = '0005' THEN
              v_table := 'TTMISTK';
              v_rcnt := 0;
              obj_row := json_object_t ();

              OPEN c2 FOR
                  SELECT a.codcomp, a.codpos, a.codjob, a.numlvl, a.codempmt,
                         a.typemp, b.typpayroll, b.codbrlc, b.flgatten, b.codcalen,
                         NULL AS codpunsh, NULL AS codexemp, a.jobgrade, a.codgrpgl,
                         NULL AS amtincom1, NULL AS amtincom2, NULL AS amtincom3, NULL AS amtincom4,
                         NULL AS amtincom5, NULL AS amtincom6, NULL AS amtincom7, NULL AS amtincom8,
                         NULL AS amtincom9, NULL AS amtincom10, a.codempid, a.staupd, a.dteeffec,
                         a.approvno, a.dteappr
                    FROM ttmistk a, temploy1 b
                   WHERE a.codcomp like p_codcomp||'%'
                     AND a.codempid = b.codempid
                     AND a.dteeffec >= nvl(p_dtestr,dteeffec)
                     AND a.dteeffec <= nvl(p_dteend,dteeffec)
                     AND ((a.staupd = p_staupd) or (nvl(p_staupd,'T') = 'T'))
                ORDER BY a.codcomp,a.codempid,a.dteeffec;

              LOOP
                  FETCH c2 INTO
                      v_codcomp, v_codpos, v_codjob, v_numlvl, v_codempmt, v_typemp,
                      v_typpayroll, v_codbrlc, v_flgatten, v_codcalen, v_codpunsh, v_codexemp,
                      v_jobgrade, v_codgrpgl, v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4,
                      v_amtincom5, v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                      v_codempid, v_staupd, v_dteeffec, v_approvno, v_dteappr;
                  EXIT WHEN c2%notfound;

                  v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

                  IF v_secur_codempid THEN
                      if isInsertReport then
                          if p_codempid = v_codempid and p_dteeffec = v_dteeffec then
                              template2_main1;
                              template2_main2;
                              template2_main3;

                              begin
                                select namimage
                                  into v_imageh
                                  from tempimge
                                 where codempid = v_codempid;
                              exception when no_data_found then
                                v_imageh := null;
                              end;

                              if v_imageh is not null then
                                v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                                v_has_image   := 'Y';
                              end if;

                              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,
                                                    ITEM8,ITEM9,ITEM10 ,ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,ITEM16,
                                                    ITEM17,ITEM18,ITEM19,ITEM20,ITEM21,ITEM22,ITEM23,ITEM24,
                                                    ITEM25,ITEM26,ITEM27 ,ITEM28,ITEM29,ITEM30,ITEM31,ITEM32, item33, item34 )
                              VALUES (global_v_codempid, 'HRPM43X',v_numseq_report, v_codempid, get_temploy_name(v_codempid,global_v_lang),
                                      v_codempid, get_tcenter_name(v_codcomp,global_v_lang), to_char(add_months(p_dtestr,(543*12)),'dd/mm/yyyy'),
                                      to_char(add_months(p_dteend,(543*12)),'dd/mm/yyyy'), i.codcodec, get_tcodec_name('TCODMOVE', i.codcodec, global_v_lang),
                                      get_tlistval_name('STAUPD',v_staupd,global_v_lang), to_char(add_months(v_dteeffec,(543*12)),'dd/mm/yyyy'),
                                      p_numhmref, p_dtemistk, p_refdoc, p_desmist1, p_numseq_report, p_codpunsh, get_tlistval_name('NAMTPUN',p_typpun,global_v_lang),
                                      p_dtestart_report, p_dteend_report, p_remark, get_tlistval_name('TFLGBLST',p_flgexempt,global_v_lang),
                                      get_tcodec_name('TCODEXEM',p_codexemp,global_v_lang), get_tlistval_name('FLGSSM',p_flgssm,global_v_lang),
                                      get_tlistval_name('TFLGBLST',p_flgblist,global_v_lang), p_numprdst, p_numprden, p_codpay,
                                      to_char(p_amtded, 'fm9,999,999,999,990.00'), to_char(p_amttotded, 'fm9,999,999,999,990.00'),
                                      v_zupdsal, v_has_image, v_imageh, v_approvno, to_char(v_dteappr, 'DD/MM/YYYY') );
                              commit;

                              v_numseq_report     := v_numseq_report + 1;
                              p_dteeffec_report   := add_months(v_dteeffec,(543*12));
                              template2_table;
                          end if;
                          v_rcnt := 1;
                      else
                          v_rcnt      := v_rcnt + 1;
                          obj_data    := json_object_t ();
                          obj_data.put('coderror','200');
                          obj_data.put('codempid',v_codempid);
                          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                          obj_data.put('codcomp',v_codcomp);
                          obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang) );
                          obj_data.put('codpos',v_codpos);
                          obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang) );
                          obj_data.put('numlvl',v_numlvl);
                          obj_data.put('codempmt',get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                          obj_data.put('typemp',get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                          obj_data.put('typpayroll',get_tcodec_name('TCODTYP',v_typpayroll,global_v_lang) );
                          obj_data.put('codbrlc',get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                          obj_data.put('flgatten',v_flgatten);
                          obj_data.put('codcalen',get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                          obj_data.put('codpunsh',get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                          obj_data.put('codexemp',get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                          obj_data.put('jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                          obj_data.put('codgrpgl',get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                          obj_data.put('fullname',get_temploy_name(v_codempid,global_v_lang));
                          obj_data.put('image',get_emp_img(v_codempid));
                          obj_data.put('staupd',get_tlistval_name ('NAMMSTAT2', v_staupd , global_v_lang));
                          obj_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy') );
                          obj_data.put('viewsalary',v_zupdsal );
                          obj_data.put('numseq',countrow+1);
                          obj_data.put('last_approvno', nvl(v_approvno,0));
                          obj_data.put('last_dteappr', to_char(v_dteappr, 'DD/MM/YYYY'));
                          obj_row.put(to_char(v_rcnt - 1),obj_data);
                      end if;
                  END IF;
                  countrow := countrow + 1;
              END LOOP;

              CLOSE c2;

              obj_row1 := json_object_t ();
              obj_row1.put('codcode','0005');
              obj_row1.put('rows',obj_row);
              v_rcnt_main := v_rcnt_main + 1;
              obj_main1.put(to_char(v_rcnt_main - 1),obj_row1);
          ELSIF ( i.codcodec = '0006' AND p_codcodec IS NULL ) OR p_codcodec = '0006' THEN
              v_table     := 'TTEXEMPT';
              obj_row     := json_object_t ();
              v_rcnt      := 0;
              OPEN c2 FOR
                  SELECT a.codcomp, a.codpos, b.codjob AS codjob, a.numlvl, a.codempmt, b.typemp,
                         b.typpayroll, b.codbrlc, b.flgatten, b.codcalen, NULL AS codpunsh,
                         a.codexemp, a.jobgrade, b.codgrpgl,
                         NULL AS amtincom1, NULL AS amtincom2, NULL AS amtincom3,
                         NULL AS amtincom4, NULL AS amtincom5, NULL AS amtincom6,
                         NULL AS amtincom7, NULL AS amtincom8, NULL AS amtincom9,
                         NULL AS amtincom10, a.codempid, a.staupd, a.dteeffec,
                         a.approvno, a.dteappr
                    FROM ttexempt a, temploy1 b
                   WHERE a.codcomp like p_codcomp||'%'
                     AND a.codempid = b.codempid
                     AND a.dteeffec >= nvl(p_dtestr,a.dteeffec)
                     AND a.dteeffec <= nvl(p_dteend,a.dteeffec)
                     AND ((a.staupd = p_staupd) or (nvl(p_staupd,'T') = 'T'))
                ORDER BY a.codcomp,a.codempid,a.dteeffec;

              LOOP
                  FETCH c2 INTO
                      v_codcomp, v_codpos, v_codjob, v_numlvl, v_codempmt,
                      v_typemp, v_typpayroll, v_codbrlc, v_flgatten, v_codcalen,
                      v_codpunsh, v_codexemp, v_jobgrade, v_codgrpgl,
                      v_amtincom1, v_amtincom2, v_amtincom3,
                      v_amtincom4, v_amtincom5, v_amtincom6,
                      v_amtincom7, v_amtincom8, v_amtincom9,
                      v_amtincom10, v_codempid, v_staupd, v_dteeffec,
                      v_approvno, v_dteappr;
                  EXIT WHEN c2%notfound;
                  v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

                  IF v_secur_codempid THEN
                      if isInsertReport then
                          if p_codempid = v_codempid and p_dteeffec = v_dteeffec then
                              template3_main;
                              begin
                                  select namimage
                                    into v_imageh
                                    from tempimge
                                   where codempid = v_codempid;
                              exception when no_data_found then
                                v_imageh := null;
                              end;

                              if v_imageh is not null then
                                v_imageh     := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                                v_has_image   := 'Y';
                              end if;

                              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                                    ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                                                    ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                                    ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                                    ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,
                                                    ITEM21, ITEM22)
                              VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                                      v_codempid, get_temploy_name(v_codempid,global_v_lang), v_codempid,
                                      get_tcenter_name(v_codcomp,global_v_lang),
                                      to_char(add_months(p_dtestr,(543*12)),'dd/mm/yyyy'),
                                      to_char(add_months(p_dteend,(543*12)),'dd/mm/yyyy'), i.codcodec,
                                      get_tcodec_name('TCODMOVE', i.codcodec, global_v_lang),
                                      get_tlistval_name('STAUPD',v_staupd,global_v_lang),
                                      to_char(add_months(v_dteeffec,(543*12)),'dd/mm/yyyy'), p_numexemp,
                                      get_tlistval_name('TFLGBLST',p_flgblist,global_v_lang),
                                      get_tcodec_name('TCODEXEM',p_codexemp,global_v_lang),
                                      get_tlistval_name('FLGSSM',p_flgssm,global_v_lang),
                                      p_desnote_report, p_dteupd, p_coduser,
                                      v_zupdsal, v_has_image, v_imageh,
                                      v_approvno, to_char(v_dteappr,'dd/mm/yyyy'));
                              commit;
                              v_numseq_report     := v_numseq_report + 1;
                              p_dteeffec_report   := v_dteeffec;
                              template3_table;
                          end if;
                          v_rcnt := 1;
                      else
                          v_rcnt      := v_rcnt + 1;
                          obj_data    := json_object_t ();
                          obj_data.put('coderror','200');
                          obj_data.put('codempid',v_codempid);
                          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                          obj_data.put('codcomp',v_codcomp);
                          obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang) );
                          obj_data.put('codpos',v_codpos);
                          obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang) );
                          obj_data.put('numlvl',v_numlvl);
                          obj_data.put('codempmt',get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                          obj_data.put('typemp',get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                          obj_data.put('typpayroll',get_tcodec_name('TCODTYP',v_typpayroll,global_v_lang) );
                          obj_data.put('codbrlc',get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                          obj_data.put('flgatten',v_flgatten);
                          obj_data.put('codcalen',get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                          obj_data.put('codpunsh',get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                          obj_data.put('codexemp',get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                          obj_data.put('jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                          obj_data.put('codgrpgl',get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                          obj_data.put('fullname',get_temploy_name(v_codempid,global_v_lang));
                          obj_data.put('image',get_emp_img(v_codempid));
                          obj_data.put('staupd',get_tlistval_name ('NAMMSTAT2', v_staupd , global_v_lang));
                          obj_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy') );
                          obj_data.put('viewsalary',v_zupdsal );
                          obj_data.put('numseq',countrow+1);
                          obj_data.put('last_approvno', nvl(v_approvno,0));
                          obj_data.put('last_dteappr', to_char(v_dteappr, 'DD/MM/YYYY'));
                          obj_row.put(to_char(v_rcnt - 1),obj_data);
                      end if;
                  END IF;
                  countrow := countrow + 1;
              END LOOP;

              CLOSE c2;

              obj_row1 := json_object_t ();
              obj_row1.put('codcode','0006');
              obj_row1.put('rows',obj_row);
              v_rcnt_main := v_rcnt_main + 1;
              obj_main1.put(to_char(v_rcnt_main - 1),obj_row1);
          ELSIF ( i.codcodec = '0007' AND p_codcodec IS NULL ) OR p_codcodec = '0007' THEN
              v_table := 'TTMOVEMT';
              obj_row := json_object_t ();
              OPEN c2 FOR
                  SELECT a.codcomp, a.codpos, a.codjob, a.numlvl, a.codempmt, a.typemp,
                         a.typpayroll, a.codbrlc, a.flgatten, a.codcalen, NULL AS codpunsh,
                         NULL AS codexemp, a.jobgrade, a.codgrpgl,
                         amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                         amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                         a.codempid, a.staupd, a.dteeffec, a.numseq,
                         a.approvno, a.dteappr
                    FROM ttmovemt a, temploy1 b
                   WHERE a.codcomp like p_codcomp||'%'
                     AND a.codempid = b.codempid
                     AND a.dteeffec >= nvl(p_dtestr,dteeffec)
                     AND a.dteeffec <= nvl(p_dteend,dteeffec)
                     AND ((a.staupd = p_staupd) or (nvl(p_staupd,'T') = 'T'))
                     AND a.CODTRN = '0007'
                ORDER BY a.codcomp,a.codempid,a.dteeffec,a.codcompt,a.numseq;

              LOOP
                  FETCH c2 INTO
                      v_codcomp, v_codpos, v_codjob, v_numlvl, v_codempmt,
                      v_typemp, v_typpayroll, v_codbrlc, v_flgatten, v_codcalen,
                      v_codpunsh, v_codexemp, v_jobgrade, v_codgrpgl,
                      v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                      v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                      v_codempid, v_staupd, v_dteeffec, v_numseq,
                      v_approvno, v_dteappr;
                  EXIT WHEN c2%notfound;

                  v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

                  BEGIN
                      select stapost2, dteend, dteeffec, numseq
                        into v_stapost2, v_dteend, v_dtestr, v_numseq_secpos
                        from tsecpos
                       where codempid = nvl(v_codempid,codempid)
                         and dtecancel = v_dteeffec
                         and seqcancel = v_numseq ;
                  exception when no_data_found then
                      v_stapost2  := null;
                      v_dteend    := null;
                      v_dtestr    := null;
                  END;

                  IF v_secur_codempid THEN
                      if isInsertReport then
                          if p_codempid = v_codempid and p_dteeffec = v_dteeffec then
                              p_codempid  := v_codempid;
                              p_dtecancel := v_dteeffec;
                              p_seqcancel := '1';

                              template1_main;

                              begin
                                select namimage
                                  into v_imageh
                                  from tempimge
                                 where codempid = v_codempid;
                              exception when no_data_found then
                                v_imageh := null;
                              end;
                              if v_imageh is not null then
                                v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                                v_has_image   := 'Y';
                              end if;

                              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                                    ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                                                    ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                                    ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                                    ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,
                                                    ITEM21,ITEM22,ITEM23,ITEM24,ITEM25,
                                                    ITEM26,ITEM27,ITEM28, ITEM29, ITEM30)
                              VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                                      v_codempid, get_temploy_name(v_codempid,global_v_lang), v_codempid,
                                      get_tcenter_name(v_codcomp,global_v_lang),
                                      to_char(add_months(p_dtestr,(543*12)),'dd/mm/yyyy'),
                                      to_char(add_months(p_dteend,(543*12)),'dd/mm/yyyy'),
                                      i.codcodec, get_tcodec_name('TCODMOVE', i.codcodec, global_v_lang),
                                      get_tlistval_name('STAUPD',v_staupd,global_v_lang),
                                      v_codpos||' - '||get_tpostn_name(v_codpos,global_v_lang),
                                      get_tlistval_name('STAPOST2',v_stapost2,global_v_lang),
                                      to_char(add_months(v_dteeffec,(543*12)),'dd/mm/yyyy'),
                                      p_dteend_report, p_dtecancel_report,
                                      p_numseq_report, p_desnote_report,
                                      to_char(p_amtincom_all, '999,999,999.99'),
                                      to_char(p_amtincadj_all, '999,999,999.99'),
                                      to_char(p_amount_all, '999,999,999.99'),
                                      to_char(p_amtincom_day_all, '999,999,999.99'),
                                      to_char(p_amtincadj_day_all, '999,999,999.99'),
                                      to_char(p_amount_day_all, '999,999,999.99'),
                                      to_char(p_amtincom_hour_all, '999,999,999.99'),
                                      to_char(p_amtincadj_hour_all, '999,999,999.99'),
                                      to_char(p_amount_hour_all, '999,999,999.99'),
                                      v_zupdsal, v_has_image, v_imageh,
                                      v_approvno, to_char(v_dteappr,'dd/mm/yyyy'));
                              commit;
                              v_numseq_report     := v_numseq_report + 1;
                              p_dteeffec_report   := v_dteeffec;
                              template1_table;
                          end if;
                          v_rcnt := 1;
                      else
                          v_rcnt      := v_rcnt + 1;
                          obj_data    := json_object_t ();
                          obj_data.put('coderror','200');
                          obj_data.put('codempid',v_codempid);
                          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                          obj_data.put('codcomp',v_codcomp);
                          obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang) );
                          obj_data.put('codpos',v_codpos);
                          obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang) );
                          obj_data.put('numlvl',v_numlvl);
                          obj_data.put('codempmt',get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                          obj_data.put('typemp',get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                          obj_data.put('typpayroll',get_tcodec_name('TCODTYP',v_typpayroll,global_v_lang) );
                          obj_data.put('codbrlc',get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                          obj_data.put('flgatten',v_flgatten);
                          obj_data.put('codcalen',get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                          obj_data.put('codpunsh',get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                          obj_data.put('codexemp',get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                          obj_data.put('jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                          obj_data.put('codgrpgl',get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                          obj_data.put('fullname',get_temploy_name(v_codempid,global_v_lang));
                          obj_data.put('image',get_emp_img(v_codempid));
                          obj_data.put('staupd',get_tlistval_name ('NAMMSTAT2', v_staupd , global_v_lang));
                          obj_data.put('dteeffec',nvl(to_char(v_dteeffec,'dd/mm/yyyy'),''));
                          obj_data.put('dtestr',nvl(to_char(v_dtestr,'dd/mm/yyyy'),''));
                          obj_data.put('dteend',nvl(to_char(v_dteend,'dd/mm/yyyy'),''));
                          obj_data.put('desc_stapost2',nvl(get_tlistval_name('STAPOST2',v_stapost2,global_v_lang),''));
                          obj_data.put('stapost2',v_stapost2);
                          obj_data.put('viewsalary',v_zupdsal );
                          obj_data.put('seqcancel',v_numseq );
                          obj_data.put('numseq',v_numseq_secpos);
                          obj_data.put('last_approvno', nvl(v_approvno,0));
                          obj_data.put('last_dteappr', to_char(v_dteappr, 'DD/MM/YYYY'));
                          obj_row.put(to_char(v_rcnt - 1),obj_data);
                      end if;
                  END IF;
                  countrow := countrow + 1;
              END LOOP;

              CLOSE c2;

              obj_row1 := json_object_t ();
              obj_row1.put('codcode',nvl(p_codcodec,i.codcodec) );
              obj_row1.put('rows',obj_row);
              v_rcnt_main := v_rcnt_main + 1;
              obj_main1.put(to_char(v_rcnt_main - 1),obj_row1);
          ELSE
              v_table := 'TTMOVEMT';
              obj_row := json_object_t ();
              OPEN c2 FOR
                  SELECT a.numseq, a.codcomp, a.codpos, a.codjob, a.numlvl,
                         a.codempmt, a.typemp, a.typpayroll, a.codbrlc, a.flgatten,
                         a.codcalen, NULL AS codpunsh, NULL AS codexemp, a.jobgrade, a.codgrpgl,
                         amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                         amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                         a.codempid, a.staupd, a.dteeffec, a.approvno, a.dteappr
                    FROM ttmovemt a, temploy1 b
                   WHERE a.codcomp LIKE p_codcomp || '%'
                     AND a.codempid = b.codempid
                     AND a.codtrn = nvl(p_codcodec,i.codcodec)
                     AND a.dteeffec >= nvl(p_dtestr,dteeffec)
                     AND a.dteeffec <= nvl(p_dteend,dteeffec)
                     AND ((a.staupd = p_staupd) or (nvl(p_staupd,'T') = 'T'))
                ORDER BY a.codcomp,a.codempid,a.dteeffec,a.codcompt,a.numseq;

              LOOP
                  FETCH c2 INTO
                      v_numseq, v_codcomp, v_codpos, v_codjob, v_numlvl,
                      v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_flgatten,
                      v_codcalen, v_codpunsh, v_codexemp, v_jobgrade, v_codgrpgl,
                      v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                      v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                      v_codempid, v_staupd, v_dteeffec, v_approvno, v_dteappr;
                  EXIT WHEN c2%notfound;

                  v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

                  IF v_secur_codempid THEN
                      if isInsertReport then
                          if p_codempid = v_codempid and p_dteeffec = v_dteeffec then
                              template4_main;
                              p_dteeffec_report := v_dteeffec;
                              template4_table;

                              begin
                                select namimage
                                  into v_imageh
                                  from tempimge
                                 where codempid = v_codempid;
                              exception when no_data_found then
                                v_imageh := null;
                              end;
                              if v_imageh is not null then
                                v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                                v_has_image   := 'Y';
                              end if;

                              INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                                    ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                                                    ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                                    ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                                    ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,
                                                    ITEM21,ITEM22, ITEM23, ITEM24)
                              VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                                      v_codempid, get_temploy_name(v_codempid,global_v_lang), v_codempid,
                                      get_tcenter_name(v_codcomp,global_v_lang),
                                      to_char(add_months(p_dtestr,(543*12)),'dd/mm/yyyy'),
                                      to_char(add_months(p_dteend,(543*12)),'dd/mm/yyyy'),
                                      i.codcodec,
                                      get_tcodec_name('TCODMOVE', i.codcodec, global_v_lang),
                                      get_tlistval_name('STAUPD',v_staupd,global_v_lang),
                                      to_char(add_months(v_dteeffec,(543*12)),'dd/mm/yyyy'),
                                      p_dteend_report, p_numseq_report,
                                      get_tlistval_name('STAPOST2',p_stapost2,global_v_lang),
                                      p_numreqst, get_flgduepr(p_flgduepr), p_countday,
                                      p_dteduepr, p_desnote_report, p_codcurr,
                                      v_zupdsal, v_has_image, v_imageh, v_approvno, to_char(v_dteappr,'dd/mm/yyyy') );
                              commit;
                              v_numseq_report := v_numseq_report + 1;
                          end if;
                          v_rcnt := 1;
                      else
                          v_rcnt      := v_rcnt + 1;
                          obj_data    := json_object_t ();
                          obj_data.put('coderror','200');
                          obj_data.put('codempid',v_codempid);
                          obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang) );
                          obj_data.put('codcomp',v_codcomp);
                          obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang) );
                          obj_data.put('codpos',v_codpos);
                          obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang) );
                          obj_data.put('numseq',v_numseq);
                          obj_data.put('numlvl',v_numlvl);
                          obj_data.put('codempmt',get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang) );
                          obj_data.put('typemp',get_tcodec_name('TCODCATG',v_typemp,global_v_lang) );
                          obj_data.put('typpayroll',get_tcodec_name('TCODTYP',v_typpayroll,global_v_lang) );
                          obj_data.put('codbrlc',get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang) );
                          obj_data.put('flgatten',v_flgatten);
                          obj_data.put('codcalen',get_tcodec_name('TCODWORK',v_codcalen,global_v_lang) );
                          obj_data.put('codpunsh',get_tcodec_name('TCODPUNSH',v_codpunsh,global_v_lang) );
                          obj_data.put('codexemp',get_tcodec_name('TCODEXEM',v_codexemp,global_v_lang) );
                          obj_data.put('jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang) );
                          obj_data.put('codgrpgl',get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang) );
                          obj_data.put('fullname',get_temploy_name(v_codempid,global_v_lang));
                          obj_data.put('image',get_emp_img(v_codempid));
                          obj_data.put('staupd',get_tlistval_name ('NAMMSTAT2', v_staupd , global_v_lang));
                          obj_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy') );
                          obj_data.put('viewsalary',v_zupdsal );
                          obj_data.put('last_approvno', nvl(v_approvno,0));
                          obj_data.put('last_dteappr', to_char(v_dteappr, 'DD/MM/YYYY'));
                          obj_row.put(to_char(v_rcnt - 1),obj_data);
                      end if;
                  END IF;
                  countrow := countrow + 1;
              END LOOP;

              CLOSE c2;

              obj_row1 := json_object_t ();
              obj_row1.put('codcode',nvl(p_codcodec,i.codcodec) );
              obj_row1.put('rows',obj_row);
              v_rcnt_main := v_rcnt_main + 1;
              obj_main1.put(to_char(v_rcnt_main - 1),obj_row1);
          END IF;
      END LOOP;

      obj_main.put('detail',obj_main1);
      if countrow <= 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang, v_table);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      elsif v_rcnt <= 0 then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      elsif v_rcnt > 0 then
          json_str_output := obj_main.to_clob;
      end if;
  EXCEPTION
      WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack
                             || ' '
                             || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END gen_data;

  PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
  BEGIN
      initial_value(json_str_input);
      check_getindex;
      IF param_msg_error IS NULL THEN
          gen_data(json_str_output);
      ELSE
          json_str_output := get_response_message(NULL,param_msg_error,global_v_lang);
      END IF;

  EXCEPTION
      WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack
                             || ' '
                             || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END;

  procedure initial_report(json_str in clob) is
  json_obj		json_object_t;
begin
  json_obj                        := json_object_t(json_str);
  p_index_rows                    := hcm_util.get_json_t(json_obj, 'p_index_rows');
      p_codtrn                        := hcm_util.get_string_t(json_obj,'p_codtrn');
      p_codcodec                      := p_codtrn;
end initial_report;

	procedure gen_report(json_str_input in clob,json_str_output out clob) is
		json_output     clob;
        obj_row         json_object_t;
	begin
        initial_value(json_str_input);
		initial_report(json_str_input);
		isInsertReport  := true;
        numYearReport   := HCM_APPSETTINGS.get_additional_year();
        v_numseq_report := 1;
		if param_msg_error is null then
			clear_ttemprpt;
            for i in 0..p_index_rows.get_size-1 loop
                obj_row := hcm_util.get_json_t(p_index_rows, to_char(i));
                p_codempid  := hcm_util.get_string_t(obj_row, 'codempid');
                p_dteeffec  := TO_DATE(hcm_util.get_string_t(obj_row, 'dteeffec'),'dd/mm/yyyy');
                p_numseq    := hcm_util.get_string_t(obj_row, 'numseq');
                p_seqcancel    := hcm_util.get_string_t(obj_row, 'seqcancel');
                insert_report(json_str_output);
              commit;
			end loop;
		end if;

		json_str_output := get_response_message(null,param_msg_error,global_v_lang);
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end gen_report;

  PROCEDURE insert_report ( json_str_output OUT CLOB ) IS
      v_rcnt             NUMBER := 0;
      v_rcnt_main        NUMBER := 0;
      v_secur_codempid   BOOLEAN;
      countrow           number;
      v_imageh           tempimge.namimage%type;
      v_folder           tfolderd.folder%type;
      v_has_image        varchar2(1) := 'N';
      v_table            varchar2(500);
      v_seqpos_numseq    number;

      CURSOR c_tcodmove IS
          SELECT codcodec, typmove
            FROM tcodmove
           WHERE codcodec LIKE nvl(p_codcodec,codcodec);

      cursor c1 is
          SELECT a.codcomp, a.codpos, a.codjob, a.numlvl, a.codempmt,
                 a.typemp, b.typpayroll, b.codbrlc, b.flgatten, b.codcalen,
                 NULL AS codpunsh, NULL AS codexemp, a.jobgrade, a.codgrpgl,
                 NULL AS amtincom1, NULL AS amtincom2, NULL AS amtincom3, NULL AS amtincom4,
                 NULL AS amtincom5, NULL AS amtincom6, NULL AS amtincom7, NULL AS amtincom8,
                 NULL AS amtincom9, NULL AS amtincom10, a.codempid, a.staupd, a.dteeffec,
                 a.approvno, a.dteappr, a.numhmref, a.desmist1, a.refdoc, a.dtemistk
            FROM ttmistk a, temploy1 b
           WHERE a.codempid = p_codempid
             and a.codempid = b.codempid
             AND a.dteeffec = p_dteeffec
        ORDER BY a.codcomp,a.codempid,a.dteeffec;

      cursor c2 is
          SELECT a.numseq, a.codcomp, a.codpos, a.codjob, a.numlvl,
                 a.codempmt, a.typemp, a.typpayroll, a.codbrlc, a.flgatten,
                 a.codcalen, NULL AS codpunsh, NULL AS codexemp, a.jobgrade, a.codgrpgl,
                 amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                 amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                 a.codempid, a.staupd, a.dteeffec, a.approvno, a.dteappr,a.codcurr,a.desnote,
                 a.numreqst,a.stapost2,a.dteend,a.codtrn,
                 a.dteduepr
            FROM ttmovemt a, temploy1 b
           WHERE a.codempid = p_codempid
             AND a.codempid = b.codempid
             AND a.codtrn = p_codtrn
             ANd a.numseq = nvl(p_numseq,a.numseq)
             AND a.dteeffec = p_dteeffec
        ORDER BY a.codcomp,a.codempid,a.dteeffec,a.codcompt,a.numseq;
     -- '0006'
      cursor c3 is
          SELECT a.codcomp, a.codpos, b.codjob AS codjob, a.numlvl, a.codempmt, b.typemp,
                 b.typpayroll, b.codbrlc, b.flgatten, b.codcalen, NULL AS codpunsh,
                 a.codexemp, a.jobgrade, b.codgrpgl,
                 NULL AS amtincom1, NULL AS amtincom2, NULL AS amtincom3,
                 NULL AS amtincom4, NULL AS amtincom5, NULL AS amtincom6,
                 NULL AS amtincom7, NULL AS amtincom8, NULL AS amtincom9,
                 NULL AS amtincom10, a.codempid, a.staupd, a.dteeffec,
                 a.approvno, a.dteappr
            FROM ttexempt a, temploy1 b
           WHERE a.codempid = p_codempid
             AND a.codempid = b.codempid
             AND a.dteeffec = p_dteeffec
        ORDER BY a.codcomp,a.codempid,a.dteeffec;
      -- 0007
      cursor c4 is
          SELECT a.codcomp, a.codpos, a.codjob, a.numlvl, a.codempmt, a.typemp,
                 a.typpayroll, a.codbrlc, a.flgatten, a.codcalen, NULL AS codpunsh,
                 NULL AS codexemp, a.jobgrade, a.codgrpgl,
                 amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
                 amtincom6, amtincom7, amtincom8, amtincom9, amtincom10,
                 amtincadj1, amtincadj2, amtincadj3, amtincadj4, amtincadj5,
                 amtincadj6, amtincadj7, amtincadj8, amtincadj9, amtincadj10,
                 a.codempid, a.staupd, a.dteeffec, a.numseq,
                 a.approvno, a.dteappr, a.desnote, a.stapost2
            FROM ttmovemt a, temploy1 b
           WHERE a.codempid = p_codempid
             AND a.codempid = b.codempid
             AND a.dteeffec = p_dteeffec
             and a.numseq = p_seqcancel
             AND a.CODTRN = p_codtrn
        ORDER BY a.codcomp,a.codempid,a.dteeffec,a.codcompt,a.numseq;

  type p_num is table of number index by binary_integer;
  v_amtincom          p_num;
  v_amtincadj         p_num;

  BEGIN
      v_rcnt      := 0;
      countrow    := 0;
      v_rcnt_main := 0;

      if p_codtrn = '0005' then
          v_table := 'TTMISTK';
          for r1 in c1 loop
              v_codcomp   := r1.codcomp;
              v_numlvl    := r1.numlvl;
              v_codempid  := r1.codempid;
              v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              IF v_secur_codempid THEN
                  template2_main1;
                  template2_main2;
                  template2_main3;

                  begin
                    select namimage
                      into v_imageh
                      from tempimge
                     where codempid = r1.codempid;
                  exception when no_data_found then
                    v_imageh := null;
                  end;

                  if v_imageh is not null then
                    v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                    v_has_image   := 'Y';
                  end if;

                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,
                                        ITEM8,ITEM9,ITEM10 ,ITEM11,ITEM12,ITEM13,ITEM14)
                  VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                          r1.codempid,to_char(r1.dteeffec,'dd/mm/yyyy'),1,p_codtrn,
                          get_temploy_name(r1.codempid,global_v_lang),r1.codempid,
                          hcm_util.get_date_buddhist_era(r1.dteeffec),
                          r1.numhmref,hcm_util.get_date_buddhist_era(r1.dtemistk),r1.refdoc,r1.desmist1,
                          v_zupdsal, v_has_image, v_imageh);
                  commit;
                  v_numseq_report     := v_numseq_report + 1;
                  p_dteeffec_report   := r1.dteeffec;
                  template2_table;
              end if;
          end loop;
      elsif p_codtrn = '0006' then
          v_table := 'TTEXEMPT';
          for r3 in c3 loop
              v_codcomp   := r3.codcomp;
              v_numlvl    := r3.numlvl;
              v_codempid  := r3.codempid;
              v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              IF v_secur_codempid THEN
                  template3_main;
                  begin
                      select namimage
                        into v_imageh
                        from tempimge
                       where codempid = v_codempid;
                  exception when no_data_found then
                    v_imageh := null;
                  end;

                  if v_imageh is not null then
                    v_imageh     := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                    v_has_image   := 'Y';
                  end if;

                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                        ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                                        ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                        ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                        ITEM16,ITEM17)
                  VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                          r3.codempid,to_char(r3.dteeffec,'dd/mm/yyyy'),1,p_codtrn,
                          get_temploy_name(r3.codempid,global_v_lang), r3.codempid,
                          hcm_util.get_date_buddhist_era(r3.dteeffec),
                          p_numexemp,
                          get_tlistval_name('TFLGBLST',p_flgblist,global_v_lang),
                          get_tcodec_name('TCODEXEM',p_codexemp,global_v_lang),
                          get_tlistval_name('FLGSSM',p_flgssm,global_v_lang),
                          p_desnote_report, p_dteupd, p_coduser,
                          v_zupdsal, v_has_image, v_imageh);
                  commit;
                  v_numseq_report     := v_numseq_report + 1;
                  p_dteeffec_report   := v_dteeffec;
                  template3_table;
              end if;
          end loop;
      elsif p_codtrn = '0007' then
          v_table := 'TTMOVEMT';
          for r4 in c4 loop
              v_codempid  := r4.codempid;
              v_codcomp   := r4.codcomp;
              v_numlvl    := r4.numlvl;
              v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              IF v_secur_codempid THEN
                  BEGIN
                      select stapost2, dteend, dteeffec, numseq
                        into v_stapost2, v_dteend, v_dtestr, v_seqpos_numseq
                        from tsecpos
                       where codempid = r4.codempid
                         and dtecancel = r4.dteeffec
                         and seqcancel = r4.numseq ;
                  exception when no_data_found then
                      v_stapost2  := null;
                      v_dteend    := null;
                      v_dtestr    := null;
                  END;

                  p_codempid  := r4.codempid;
                  p_dtecancel := r4.dteeffec;
                  p_seqcancel := r4.numseq;

                  template1_main;

                  begin
                    select namimage
                      into v_imageh
                      from tempimge
                     where codempid = r4.codempid;
                  exception when no_data_found then
                    v_imageh := null;
                  end;
                  if v_imageh is not null then
                    v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                    v_has_image   := 'Y';
                  end if;

                  for i in 1..10 loop
                      v_amtincom(i)   := 0;
                      v_amtincadj(i)  := 0;
                  end loop;

                  v_amtincom(1) := stddec(r4.amtincom1,v_codempid,global_v_chken);
                  v_amtincom(2) := stddec(r4.amtincom2,v_codempid,global_v_chken);
                  v_amtincom(3) := stddec(r4.amtincom3,v_codempid,global_v_chken);
                  v_amtincom(4) := stddec(r4.amtincom4,v_codempid,global_v_chken);
                  v_amtincom(5) := stddec(r4.amtincom5,v_codempid,global_v_chken);
                  v_amtincom(6) := stddec(r4.amtincom6,v_codempid,global_v_chken);
                  v_amtincom(7) := stddec(r4.amtincom7,v_codempid,global_v_chken);
                  v_amtincom(8) := stddec(r4.amtincom8,v_codempid,global_v_chken);
                  v_amtincom(9) := stddec(r4.amtincom9,v_codempid,global_v_chken);
                  v_amtincom(10) := stddec(r4.amtincom10,v_codempid,global_v_chken);
                  v_amtincadj(1)  := stddec(r4.amtincadj1,v_codempid,global_v_chken);
                  v_amtincadj(2)  := stddec(r4.amtincadj2,v_codempid,global_v_chken);
                  v_amtincadj(3)  := stddec(r4.amtincadj3,v_codempid,global_v_chken);
                  v_amtincadj(4)  := stddec(r4.amtincadj4,v_codempid,global_v_chken);
                  v_amtincadj(5)  := stddec(r4.amtincadj5,v_codempid,global_v_chken);
                  v_amtincadj(6)  := stddec(r4.amtincadj6,v_codempid,global_v_chken);
                  v_amtincadj(7)  := stddec(r4.amtincadj7,v_codempid,global_v_chken);
                  v_amtincadj(8)  := stddec(r4.amtincadj8,v_codempid,global_v_chken);
                  v_amtincadj(9)  := stddec(r4.amtincadj9,v_codempid,global_v_chken);
                  v_amtincadj(10)  := stddec(r4.amtincadj10,v_codempid,global_v_chken);

                  get_wage_income(
                      hcm_util.get_codcomp_level(r4.codcomp, 1),
                      v_codempmt,
                      v_amtincom(1),v_amtincom(2),v_amtincom(3),
                      v_amtincom(4),v_amtincom(5),v_amtincom(6),
                      v_amtincom(7),v_amtincom(8),v_amtincom(9),
                      v_amtincom(10),
                      p_amtincom_hour_all, p_amtincom_all, p_amtincom_day_all);

                  get_wage_income(
                      hcm_util.get_codcomp_level(r4.codcomp, 1),
                      v_codempmt,
                      v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),
                      v_amtincadj(4),v_amtincadj(5),v_amtincadj(6),
                      v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),
                      v_amtincadj(10),
                      p_amtincadj_hour_all, p_amtincadj_day_all, p_amtincadj_all );

                  get_wage_income(
                      hcm_util.get_codcomp_level(r4.codcomp, 1),
                      v_codempmt,
                      (v_amtincom(1) - v_amtincadj(1)), (v_amtincom(2) - v_amtincadj(2)),
                      (v_amtincom(3) - v_amtincadj(3)),(v_amtincom(4) - v_amtincadj(4)),
                      (v_amtincom(5) - v_amtincadj(5)),(v_amtincom(6) - v_amtincadj(6)),
                      (v_amtincom(7) - v_amtincadj(7)),(v_amtincom(8) - v_amtincadj(8)),
                      (v_amtincom(9) - v_amtincadj(9)),(v_amtincom(10) - v_amtincadj(10)),
                       p_amount_hour_all, p_amount_day_all, p_amount_all);

                  if v_dteend is null then
                      v_dteend_str := '';
                  else
                      v_dteend_str := hcm_util.get_date_buddhist_era(v_dteend);
                  end if;

                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                        ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,
                                        ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                        ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                        ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,
                                        ITEM21,ITEM22,ITEM23,ITEM24,ITEM25,
                                        ITEM26)
                  VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                          r4.codempid, to_char(r4.dteeffec,'dd/mm/yyyy'),r4.numseq, p_codtrn,
                          get_temploy_name(r4.codempid,global_v_lang), r4.codempid,
                          r4.codpos||' - '||get_tpostn_name(r4.codpos,global_v_lang),
                          get_tlistval_name('STAPOST2',v_stapost2,global_v_lang),
                          hcm_util.get_date_buddhist_era(r4.dteeffec),
                          v_dteend_str,
                          hcm_util.get_date_buddhist_era(r4.dteeffec),
                          v_seqpos_numseq,
                          r4.desnote, get_tlistval_name('STAUPD',r4.staupd,global_v_lang),
                          to_char(p_amtincom_all, '999,999,990.99'),
                          to_char(p_amtincadj_all, '999,999,990.99'),
                          to_char(p_amount_all, '999,999,990.99'),
                          to_char(p_amtincom_day_all, '999,999,990.99'),
                          to_char(p_amtincadj_day_all, '999,999,990.99'),
                          to_char(p_amount_day_all, '999,999,990.99'),
                          to_char(p_amtincom_hour_all, '999,999,990.99'),
                          to_char(p_amtincadj_hour_all, '999,999,990.99'),
                          to_char(p_amount_hour_all, '999,999,990.99'),
                          v_zupdsal, v_has_image, v_imageh);
                  commit;
                  v_numseq_report     := v_numseq_report + 1;
                  p_dteeffec_report   := r4.dteeffec;
                  template1_table;
              end if;
          end loop;
--        elsif p_codtrn = '0009' then
      else
          v_table := 'TTMOVEMT';
          for r2 in c2 loop
              v_codcomp   := r2.codcomp;
              v_numlvl    := r2.numlvl;
              v_secur_codempid := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              IF v_secur_codempid THEN
                  template4_main;

                  p_dteeffec_report := r2.dteeffec;
                  template4_table;

                  begin
                    select namimage
                      into v_imageh
                      from tempimge
                     where codempid = r2.codempid;
                  exception when no_data_found then
                    v_imageh := null;
                  end;
                  if v_imageh is not null then
                    v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
                    v_has_image   := 'Y';
                  end if;


                  if r2.dteend is not null then
                      v_dteend_str := hcm_util.get_date_buddhist_era(r2.dteend);
                  else
                      v_dteend_str := '';
                  end if;
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                                        ITEM1,ITEM2,ITEM3,ITEM4,
                                        ITEM5,
                                        ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,
                                        ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                        ITEM16,ITEM17,ITEM18,ITEM19,ITEM20,
                                        ITEM21,ITEM22,
                                        ITEM23,ITEM24,ITEM25,
                                        ITEM26,ITEM27,ITEM28,
                                        ITEM29,ITEM30,ITEM31)
                  VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                          r2.codempid, to_char(r2.dteeffec,'dd/mm/yyyy') , r2.numseq, r2.codtrn,
                          get_temploy_name(r2.codempid,global_v_lang),r2.codempid,
                          hcm_util.get_date_buddhist_era(r2.dteeffec),
                          v_dteend_str,
                          r2.numseq,get_tlistval_name('STAPOST2',r2.stapost2,global_v_lang),
                          r2.numreqst,get_flgduepr(p_flgduepr),p_countday,
                          hcm_util.get_date_buddhist_era(r2.dteduepr),
                          r2.desnote,
                          get_tlistval_name('STAUPD',r2.staupd,global_v_lang),
                          r2.CODCURR,get_tcodec_name('TCODCURR',r2.codcurr,global_v_lang),
                          v_zupdsal, v_has_image, v_imageh, r2.approvno,
                           -- total
                          to_char(p_summary1, '999,999,990.99'), --new
                          to_char(p_summary2, '999,999,990.99'), --adj
                          to_char(p_summary3, '999,999,990.99'),
                          -- Daily
                          to_char(p_summary4, '999,999,990.99'),--new
                          to_char(p_summary5, '999,999,990.99'), --adj
                          to_char(p_summary6, '999,999,990.99'),
                          -- Per Hour
                          to_char(p_summary7, '999,999,990.99'),--new
                          to_char(p_summary8, '999,999,990.99'), --adj
                          to_char(p_summary9, '999,999,990.99'));
                  commit;
                  v_numseq_report     := v_numseq_report + 1;
              end if;
          end loop;
      end if;

      param_msg_error := p_codempid||'-'||get_error_msg_php('HR2715',global_v_lang, v_table);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  EXCEPTION
      WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack
                             || ' '
                             || dbms_utility.format_error_backtrace;
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END insert_report;

	procedure clear_ttemprpt is
	begin
		begin
			delete
			  from ttemprpt
             where codempid = global_v_codempid
			   and codapp = 'HRPM43X';
		exception when others then
			null;
		end;
	end clear_ttemprpt;

  procedure template1_main is
      cursor c_TTMOVEMT is
          select *
            from TTMOVEMT
           where codempid = p_codempid
             and dteeffec = p_dtecancel
             and numseq = p_seqcancel;
begin
  FOR i IN c_TTMOVEMT LOOP
          if i.DTEEND is not null then
              p_dteend_report := to_char(i.DTEEND,'dd/mm/yyyy');
          else
              p_dteend_report := '';
          end if;

          if i.DTECANCEL is not null then
              p_dtecancel_report := to_char(i.DTECANCEL,'dd/mm/yyyy');
          else
              p_dtecancel_report := '';
          end if;

          p_numseq_report := i.NUMSEQ;
          p_desnote_report := i.DESNOTE;
      end loop;
end template1_main;

  procedure template1_table is
      cursor c_TTMOVEMT_detail is
          select *
            from TEMPLOY1
           where codempid = p_codempid;

      rowTemp         c_TTMOVEMT_detail%ROWTYPE;
      codempmt		    varchar2( 100 char) := '';
      codcompy		    varchar2( 100 char) := '';
      obj_row			    json_object_t;
      v_json_input    clob;
      v_json_codincom clob;
      param_json_row	json_object_t;
      type p_num is table of number index by binary_integer;
      v_amtincom      p_num;
      v_amtincadj     p_num;
      v_row			      number := 0;
      flgpass         boolean;
      v_item6         varchar2(1000 char);
      v_item7         varchar2(1000 char);
      v_item8         varchar2(1000 char);
begin
      OPEN c_TTMOVEMT_detail;
  FETCH c_TTMOVEMT_detail INTO rowTemp;
          codcompy := hcm_util.get_codcomp_level(rowTemp.codcomp,1);
          codempmt := rowTemp.CODEMPMT;
          obj_row := json_object_t();

          v_json_input    := '{"p_codcompy":"'||codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||codempmt||'","p_lang":"'||global_v_lang||'"}';
          v_json_codincom := hcm_pm.get_codincom(v_json_input);

          obj_row         := json_object_t(v_json_codincom);
          param_json_row  := hcm_util.get_json_t(obj_row,to_char(0));
          for i in 1..10 loop
              v_amtincom(i)   := 0;
              v_amtincadj(i)  := 0;
          end loop;

          BEGIN
              select stddec(amtincom1,p_codempid,global_v_chken),
                     stddec(amtincom2,p_codempid,global_v_chken),
                     stddec(amtincom3,p_codempid,global_v_chken),
                     stddec(amtincom4,p_codempid,global_v_chken),
                     stddec(amtincom5,p_codempid,global_v_chken),
                     stddec(amtincom6,p_codempid,global_v_chken),
                     stddec(amtincom7,p_codempid,global_v_chken),
                     stddec(amtincom8,p_codempid,global_v_chken),
                     stddec(amtincom9,p_codempid,global_v_chken),
                     stddec(amtincom10,p_codempid,global_v_chken),
                     stddec(amtincadj1,p_codempid,global_v_chken),
                     stddec(amtincadj2,p_codempid,global_v_chken),
                     stddec(amtincadj3,p_codempid,global_v_chken),
                     stddec(amtincadj4,p_codempid,global_v_chken),
                     stddec(amtincadj5,p_codempid,global_v_chken),
                     stddec(amtincadj6,p_codempid,global_v_chken),
                     stddec(amtincadj7,p_codempid,global_v_chken),
                     stddec(amtincadj8,p_codempid,global_v_chken),
                     stddec(amtincadj9,p_codempid,global_v_chken),
                     stddec(amtincadj10,p_codempid,global_v_chken)
                into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                     v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                     v_amtincadj(1),v_amtincadj(2),v_amtincadj(3),v_amtincadj(4),v_amtincadj(5),
                     v_amtincadj(6),v_amtincadj(7),v_amtincadj(8),v_amtincadj(9),v_amtincadj(10)
                from ttmovemt
               where codempid = p_codempid
                 and dteeffec = p_dtecancel
                 and numseq = p_seqcancel;

              for i in 1..10 loop
                  param_json_row := hcm_util.get_json_t(obj_row,i-1);

                  IF hcm_util.get_string_t(param_json_row,'codincom') IS NULL OR hcm_util.get_string_t(param_json_row,'codincom') = ' ' THEN
                      EXIT;
                  END IF;

                  v_item6 := hcm_util.get_string_t(param_json_row,'codincom');
                  v_item7 := hcm_util.get_string_t(param_json_row,'desincom');
                  v_item8 := hcm_util.get_string_t(param_json_row,'desunit');

                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10)
                       VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                               v_codempid,to_char(p_dtecancel,'dd/mm/yyyy'),p_seqcancel, 'TABLE',
                               v_item6,
                               v_item7,
                               v_item8,
                               to_char(v_amtincom(i), '999,999,990.99'),
                               to_char(v_amtincadj(i), '999,999,990.99'),
                               to_char(TO_NUMBER(v_amtincom(i)) + TO_NUMBER(v_amtincadj(i)), '999,999,990.99'));
                  commit;
                  v_numseq_report := v_numseq_report + 1;
              end loop;
          EXCEPTION WHEN NO_DATA_FOUND then
              begin
                  select stddec(AMTINCOM1,p_codempid,global_v_chken),
                         stddec(AMTINCOM2,p_codempid,global_v_chken),
                         stddec(AMTINCOM3,p_codempid,global_v_chken),
                         stddec(AMTINCOM4,p_codempid,global_v_chken),
                         stddec(AMTINCOM5,p_codempid,global_v_chken),
                         stddec(AMTINCOM6,p_codempid,global_v_chken),
                         stddec(AMTINCOM7,p_codempid,global_v_chken),
                         stddec(AMTINCOM8,p_codempid,global_v_chken),
                         stddec(AMTINCOM9,p_codempid,global_v_chken),
                         stddec(AMTINCOM10,p_codempid,global_v_chken)
                    into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                         v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10)
                    from TEMPLOY3 where codempid = p_codempid
                     and rownum <=1;
              end;
              for i in 1..10 loop
                  param_json_row :=  hcm_util.get_json_t(obj_row,i-1);
                  IF hcm_util.get_string_t(param_json_row,'codincom') IS NULL OR hcm_util.get_string_t(param_json_row,'codincom') = ' ' THEN
                      EXIT;
                  END IF;

                  v_row := v_row + 1;
                  v_item6 := hcm_util.get_string_t(param_json_row,'codincom');
                  v_item7 := hcm_util.get_string_t(param_json_row,'desincom');
                  v_item8 := hcm_util.get_string_t(param_json_row,'desunit');
                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
                       VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                               v_codempid,to_char(p_dtecancel,'dd/mm/yyyy'),p_seqcancel, 'TABLE',
                               v_item6,
                               v_item7,
                               v_item8,
                               to_char(v_amtincom(i), '999,999,990.99'),
                               '0.00',
                               '0.00',
                               to_char(p_dteeffec_report,'dd/mm/yyyy') );
                  commit;
                  v_numseq_report := v_numseq_report + 1;
              end loop;
      END;
end template1_table;

  procedure template2_main1 is
      cursor c_ttmistk2 is
          select codreq,rowid,STAUPD,DTEMISTK,CODMIST,CODEMPID,DTEEFFEC,DESMIST1,NUMHMREF,REFDOC,add_months(DTECREATE,6516) as DTECREATE
            from ttmistk
           where codempid = p_codempid
             and dteeffec = p_dteeffec;
begin

  FOR i IN c_ttmistk2 LOOP
          p_numhmref := i.NUMHMREF;
          p_dtemistk := i.DTEMISTK;
          if p_dtemistk is not null then
             p_dtemistk := hcm_util.get_date_buddhist_era(p_dtemistk);
          end if;
          p_refdoc := i.REFDOC;
          p_desmist1 := i.DESMIST1;
      end loop;
end template2_main1;

  procedure template2_main2 is
  cursor c_TTPUNSH is
  select *
        from TTPUNSH
   where codempid = p_codempid
     and dteeffec = p_dteeffec
   order by NUMSEQ;
begin
  FOR i IN c_TTPUNSH LOOP
          p_numseq_report     := i.numseq;
          p_codpunsh          := i.codpunsh||' - '||get_tcodec_name('TCODPUNSH',i.codpunsh,global_v_lang);
          p_typpun            := i.typpun;
          p_dtestart_report   := i.dtestart;
          if p_dtestart_report is not null then
             p_dtestart_report := hcm_util.get_date_buddhist_era(p_dtestart_report);
          end if;
          p_dteend_report := i.dteend;
          if p_dteend_report is not null then
             p_dteend_report := hcm_util.get_date_buddhist_era(p_dteend_report);
          end if;
          p_remark        := i.remark;
          p_flgexempt     := i.flgexempt;
          p_codexemp      := i.codexemp;
          p_flgssm        := i.flgssm;
          p_flgblist      := i.flgblist;
      end loop;
end template2_main2;

  procedure template2_main3 is
  v_rcnt			number := 0;
  is_found_rec	boolean := false;
  v_start			varchar2( 100 char) ;
  v_end			varchar2( 100 char);
  v_typpayroll	varchar2( 100 char);
  v_count			number := 1;
  v_codcompy		varchar2( 100 char);
  cursor c_TTPUNSH is
          select *
            from ttpunded
           where codempid = p_codempid
             and dteeffec = p_dteeffec ;
begin
  for r1 in c_TTPUNSH loop
    v_rcnt := v_rcnt + 1;
    begin
      select typpayroll
                into v_typpayroll
        from temploy1
       where codempid = p_codempid ;
    end;
    begin
      select codcomp as codcomp
                into v_codcompy
                from TEMPLOY1
       where codempid = p_codempid;
    end;
    begin
      v_start     := r1.DTEYEARST||lpad(r1.DTEMTHST,2,'0')||lpad(r1.NUMPRDST,2,'0');
      v_end       := r1.DTEYEAREN||lpad(r1.DTEMTHEN,2,'0')||lpad(r1.NUMPRDEN,2,'0');
              select count(*)
                into v_count
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(v_codcompy,1)
         and TYPPAYROLL = v_typpayroll
         and DTEYREPAY||lpad(dtemthpay,2,'0')||lpad(NUMPERIOD,2,'0') BETWEEN v_start and v_end;
    end;

          if v_count = 0 then
              v_count := 1;
          end if;
    is_found_rec := true;

          p_numprdst := r1.NUMPRDST||' '||get_tlistval_name('NAMMTHFUL',r1.DTEMTHST,global_v_lang)||' '||hcm_util.get_year_buddhist_era(r1.DTEYEARST);
          p_numprden := r1.NUMPRDEN||' '||get_tlistval_name('NAMMTHFUL',r1.DTEMTHEN,global_v_lang)||' '||hcm_util.get_year_buddhist_era(r1.DTEYEAREN);
          p_codpay := r1.codpay ||' - '|| GET_TINEXINF_NAME(r1.codpay,global_v_lang);
  end loop;
  if not is_found_rec then
          p_numprdst := ' ';
          p_numprden := ' ';
          p_codpay := ' ';
  end if;
end template2_main3;

  procedure template2_table is
      obj_row			        json_object_t;
  obj_test		        json_object_t;
  obj_data		        json_object_t;
  obj_detail		      json_object_t;
  obj_row_temp		    json_object_t;
  jsonParam		        json_object_t;
  json_str_output1    clob;
  getData             clob;
  v_rcnt			    number := 0;
  codcompy		    varchar2( 100 char) := '';
  dteeffe			    varchar2( 100 char) := '';
  codempmt		    varchar2( 100 char) := '';
      p_amtincadj         varchar(100 char);
  v_json_input        clob;
  v_json_codincom     clob;
  param_json_row		json_object_t;
  v_counter		    number := 0;
  total			    number := 0;
  v_item6			  varchar2(1000 char);
  v_item7			  varchar2(1000 char);
  v_item8			  varchar2(1000 char);
  type p_char is table of TTPUNDED.amtincom1%type index by binary_integer;
  v_amtincom          p_char;
  v_amtincded         p_char;
      v_codpunsh          TTPUNSH.codpunsh%type;

  cursor c_TTMISTK_detail is
          select hcm_util.get_codcomp_level(codcomp,1) as codcomp,codempmt
            from TEMPLOY1
           where codempid = p_codempid;
  rowTemp c_TTMISTK_detail%ROWTYPE;

      cursor c_TTPUNSH is
          select *
            from TTPUNSH
           where codempid = p_codempid
             and dteeffec = p_dteeffec
             order by numseq
            ;

      tmp c_TTPUNSH%ROWTYPE;
      v_count_ttpunsh     number := 1;
      v_flgpunded         varchar2(1);
      v_period            varchar2(1000);
      v_codpay            varchar2(1000);
      v_amtdoth           ttpunded.amtdoth%type;
      v_amtded            ttpunded.amtded%type;
      v_amttotded         ttpunded.amttotded%type;
begin

  OPEN c_TTMISTK_detail;
  FETCH c_TTMISTK_detail INTO rowTemp;

--        OPEN c_TTPUNSH;
--		FETCH c_TTPUNSH INTO tmp;
      for r_ttpunsh in c_TTPUNSH loop
          if r_ttpunsh.typpun = '1' or r_ttpunsh.typpun = '5' then
              v_flgpunded := 'Y';
              v_period    := p_numprdst||' - '||p_numprden;
              v_codpay    := p_codpay;
          else
              v_flgpunded := 'N';
              v_period    := '';
              v_codpay    := '';
          end if;



          if v_flgpunded = 'Y' then
              v_codpunsh      := r_ttpunsh.codpunsh;
              codcompy        := rowTemp.codcomp;
              codempmt        := rowTemp.codempmt;
              obj_row         := json_object_t();
              obj_test        := json_object_t();
              v_json_input    := '{"p_codcompy":"'||codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||codempmt||'","p_lang":"'||global_v_lang||'"}';
              v_json_codincom := hcm_pm.get_codincom(v_json_input);
              obj_row         := json_object_t(v_json_codincom);
              param_json_row  := hcm_util.get_json_t(obj_row,to_char(1));
              for i in 1..10 loop
                  v_amtincom(i)   := null;
                  v_amtincded(i)  := null;
              end loop;

              BEGIN
                  select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                         amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                         amtincded1,amtincded2,amtincded3,amtincded4,amtincded5,
                         amtincded6,amtincded7,amtincded8,amtincded9,amtincded10,
                         amtdoth,amtded,amttotded
                    into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                         v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                         v_amtincded(1),v_amtincded(2),v_amtincded(3),v_amtincded(4),v_amtincded(5),
                         v_amtincded(6),v_amtincded(7),v_amtincded(8),v_amtincded(9),v_amtincded(10),
                         v_amtdoth, v_amtded, v_amttotded
                    from TTPUNDED
                   where codempid = p_codempid
                     and dteeffec = p_dteeffec
                     and codpunsh = v_codpunsh;
                  if stddec(v_amttotded, p_codempid, global_v_chken) > 0 then
                      for i in 1..10 loop
                          param_json_row := hcm_util.get_json_t(obj_row, i-1);
                          if stddec(v_amtincom(i), p_codempid, global_v_chken) != 0 then
                              p_amtincadj := (stddec(v_amtincded(i), p_codempid, global_v_chken) * 100)/stddec(v_amtincom(i), p_codempid, global_v_chken);
                          else
                              p_amtincadj := 0;
                          end if;
                          total := total + stddec(v_amtincded(i), p_codempid, global_v_chken);

                          IF hcm_util.get_string_t(param_json_row,'codincom') IS NULL OR hcm_util.get_string_t(param_json_row,'codincom') = ' ' THEN
                              EXIT;
                          END IF;

                          v_item6 := hcm_util.get_string_t(param_json_row,'codincom');
                          v_item7 := hcm_util.get_string_t(param_json_row,'desincom');
                          v_item8 := hcm_util.get_string_t(param_json_row,'desunit');
--                          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
--                               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
--                                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),1,v_count_ttpunsh,
--                                       'DETAIL3',r_ttpunsh.numseq,
--                                       v_item6,
--                                       v_item7,
--                                       v_item8,
--                                       to_char(stddec(v_amtincom(i), p_codempid, global_v_chken),'999,999,990.00'),
--                                       to_char(p_amtincadj, '999,999,990.99'),
--                                       to_char(stddec(v_amtincded(i), p_codempid, global_v_chken), '999,999,990.99'));
--                          commit;
--                          v_numseq_report := v_numseq_report + 1;
                      end loop;
                  else
                    v_flgpunded := 'N';
                  end if;
              EXCEPTION
              WHEN OTHERS then
                  null;
              END;
          else
              v_amtdoth       := null;
              v_amtded        := null;
              v_amttotded     := null;
          end if;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,
                                ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12,ITEM13,ITEM14,ITEM15,
                                ITEM16,ITEM17,ITEM18,ITEM19,ITEM20)
          VALUES (global_v_codempid, 'HRPM43X', v_numseq_report,
                  p_codempid, to_char(p_dteeffec,'dd/mm/yyyy'), 1, v_count_ttpunsh,
                  'DETAIL2', r_ttpunsh.numseq,
                  r_ttpunsh.codpunsh||' - '||get_tcodec_name('TCODPUNH',r_ttpunsh.codpunsh,global_v_lang),
                  get_tlistval_name('NAMTPUN',r_ttpunsh.typpun,global_v_lang),
                  hcm_util.get_date_buddhist_era(r_ttpunsh.dtestart) ||' - '||hcm_util.get_date_buddhist_era(r_ttpunsh.dteend),
                  r_ttpunsh.remark,
                  get_tlistval_name('TFLGBLST',r_ttpunsh.FLGEXEMPT,global_v_lang),
                  get_tcodec_name('TCODEXEM',r_ttpunsh.codexemp,global_v_lang),
                  nvl(get_tlistval_name('FLGSSM',r_ttpunsh.flgssm,global_v_lang),''),
                  get_tlistval_name('TFLGBLST',r_ttpunsh.flgblist,global_v_lang),
                  v_flgpunded, v_period, v_codpay,
                  to_char(stddec(v_amtdoth, p_codempid, global_v_chken), '999,999,990.99'),
                  to_char(stddec(v_amtded, p_codempid, global_v_chken), '999,999,990.99'),
                  to_char(stddec(v_amttotded, p_codempid, global_v_chken), '999,999,990.99')
                  );
          commit;
          v_count_ttpunsh     := v_count_ttpunsh + 1;
          v_numseq_report     := v_numseq_report + 1;
      end loop;
      for r_ttpunsh in c_TTPUNSH loop
          if r_ttpunsh.typpun = '1' or r_ttpunsh.typpun = '5' then
              v_flgpunded := 'Y';
              v_period    := p_numprdst||' - '||p_numprden;
              v_codpay    := p_codpay;
          else
              v_flgpunded := 'N';
              v_period    := '';
              v_codpay    := '';
          end if;



          if v_flgpunded = 'Y' then
              v_codpunsh      := r_ttpunsh.codpunsh;
              codcompy        := rowTemp.codcomp;
              codempmt        := rowTemp.codempmt;
              obj_row         := json_object_t();
              obj_test        := json_object_t();
              v_json_input    := '{"p_codcompy":"'||codcompy||'","p_dteeffec":"'||to_char(sysdate,'ddmmyyyy')||'","p_codempmt":"'||codempmt||'","p_lang":"'||global_v_lang||'"}';
              v_json_codincom := hcm_pm.get_codincom(v_json_input);
              obj_row         := json_object_t(v_json_codincom);
              param_json_row  := hcm_util.get_json_t(obj_row,to_char(1));
              for i in 1..10 loop
                  v_amtincom(i)   := null;
                  v_amtincded(i)  := null;
              end loop;

              BEGIN
                  select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                         amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                         amtincded1,amtincded2,amtincded3,amtincded4,amtincded5,
                         amtincded6,amtincded7,amtincded8,amtincded9,amtincded10,
                         amtdoth,amtded,amttotded
                    into v_amtincom(1),v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),
                         v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10),
                         v_amtincded(1),v_amtincded(2),v_amtincded(3),v_amtincded(4),v_amtincded(5),
                         v_amtincded(6),v_amtincded(7),v_amtincded(8),v_amtincded(9),v_amtincded(10),
                         v_amtdoth, v_amtded, v_amttotded
                    from TTPUNDED
                   where codempid = p_codempid
                     and dteeffec = p_dteeffec
                     and codpunsh = v_codpunsh;
                  if stddec(v_amttotded, p_codempid, global_v_chken) > 0 then
                      for i in 1..10 loop
                          param_json_row := hcm_util.get_json_t(obj_row, i-1);
                          if stddec(v_amtincom(i), p_codempid, global_v_chken) != 0 then
                              p_amtincadj := (stddec(v_amtincded(i), p_codempid, global_v_chken) * 100)/stddec(v_amtincom(i), p_codempid, global_v_chken);
                          else
                              p_amtincadj := 0;
                          end if;
                          total := total + stddec(v_amtincded(i), p_codempid, global_v_chken);

                          IF hcm_util.get_string_t(param_json_row,'codincom') IS NULL OR hcm_util.get_string_t(param_json_row,'codincom') = ' ' THEN
                              EXIT;
                          END IF;

                          v_item6 := hcm_util.get_string_t(param_json_row,'codincom');
                          v_item7 := hcm_util.get_string_t(param_json_row,'desincom');
                          v_item8 := hcm_util.get_string_t(param_json_row,'desunit');
                          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11,ITEM12)
                               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),1,v_count_ttpunsh,
                                       'DETAIL3',r_ttpunsh.numseq,
                                       v_item6,
                                       v_item7,
                                       v_item8,
                                       to_char(stddec(v_amtincom(i), p_codempid, global_v_chken),'999,999,990.90'),
                                       to_char(p_amtincadj, '999,999,990.99'),
                                       to_char(stddec(v_amtincded(i), p_codempid, global_v_chken), '999,999,990.90'));
                          commit;
                          v_numseq_report := v_numseq_report + 1;
                      end loop;
                  else
                    v_flgpunded := 'N';
                  end if;
              EXCEPTION
              WHEN OTHERS then
                  null;
              END;
          else
              v_amtdoth       := null;
              v_amtded        := null;
              v_amttotded     := null;
          end if;
          commit;
          v_count_ttpunsh     := v_count_ttpunsh + 1;
          v_numseq_report     := v_numseq_report + 1;
      end loop;

end template2_table;

  procedure template3_main is
      obj_row         json_object_t;

      r_codempid      ttexempt.CODEMPID%type;
      r_dteeffec      ttexempt.DTEEFFEC%type;
      r_numexemp      ttexempt.NUMEXEMP%type;
      r_flgblist      ttexempt.FLGBLIST%type;
      r_codexemp      ttexempt.CODEXEMP%type;
      r_flgssm        ttexempt.FLGSSM%type;
      r_numlvl        ttexempt.NUMLVL%type;
      r_desnote       ttexempt.DESNOTE%type;
      r_codreq        ttexempt.CODREQ%type;
      r_dtecreate     ttexempt.DTECREATE%type;
      r_staupd        ttexempt.STAUPD%type;

      v_codcomp       temploy1.codcomp%type;

      cursor c_ttexempt is
          select CODEMPID, DTEEFFEC, NUMEXEMP, FLGBLIST, CODEXEMP, FLGSSM, NUMLVL, DESNOTE, CODREQ, DTECREATE, STAUPD, DTEUPD, CODUSER
            from ttexempt
           where codempid = p_codempid
             and dteeffec = (select max(dteeffec)
                               from ttexempt
                              where codempid = p_codempid);

      ttexempt_rec        c_ttexempt%ROWTYPE;
      datattexempt_found  boolean := false;

      r_flgrp             ttpminf.flgrp%type;
      v_del               boolean := false ;

  begin
      begin
           select codempid,  dteeffec  , numexemp, flgblist, codexemp,
                  flgssm, numlvl, desnote, codreq,dtecreate, staupd
             into r_codempid,r_dteeffec,r_numexemp,r_flgblist,r_codexemp,
                  r_flgssm,r_numlvl,r_desnote,r_codreq,r_dtecreate,r_staupd
             from ttexempt
            where codempid = p_codempid
              and dteeffec = p_dteeffec;

            datattexempt_found := true;
       exception when no_data_found then
          datattexempt_found := false;
       end;

       obj_row := json_object_t();

       if (datattexempt_found) then
         if upper(r_staupd) = 'U' then
              FOR ttexempt_rec IN c_ttexempt LOOP
                  p_numexemp := ttexempt_rec.numexemp;
                  p_flgblist := ttexempt_rec.flgblist;
                  p_codexemp := ttexempt_rec.codexemp;
                  p_flgssm := ttexempt_rec.flgssm;
                  p_desnote_report := ttexempt_rec.desnote;
                  p_dteupd := ttexempt_rec.dteupd;
                  if p_dteupd is not null then
                     p_dteupd := hcm_util.get_date_buddhist_era(p_dteupd);
                  end if;
                  p_coduser := get_temploy_name(get_codempid(ttexempt_rec.coduser),global_v_lang);
              END LOOP;
          elsif (upper(r_staupd) = 'C') then
              begin
                  select flgrp
                    into r_flgrp
                    from ttpminf
                   where codempid = p_codempid
                     and dteeffec =  r_dteeffec
                     and codtrn   = '0006'
                     and numseq   = 1;

                  if nvl(r_flgrp,'N') = 'N' and
                         nvl(r_flgrp,'N') = 'N' and
                         nvl(r_flgrp,'N') = 'N' and
                         nvl(r_flgrp,'N') = 'N' and
                         nvl(r_flgrp,'N') = 'N' and
                         nvl(r_flgrp,'N') = 'N' then
                     v_del 	   := true ;
                  end if;
              exception when others then
                  v_del 	   := true ;
              end ;

              FOR  ttexempt_rec IN c_ttexempt LOOP
                  p_numexemp          := ttexempt_rec.numexemp;
                  p_flgblist          := ttexempt_rec.flgblist;
                  p_codexemp          := ttexempt_rec.codexemp;
                  p_flgssm            := ttexempt_rec.flgssm;
                  p_desnote_report    := ttexempt_rec.desnote;
                  p_dteupd            := ttexempt_rec.dteupd;
                  if p_dteupd is not null then
                     p_dteupd := hcm_util.get_date_buddhist_era(p_dteupd);
                  end if;
                  p_coduser           := get_temploy_name(get_codempid(ttexempt_rec.coduser),global_v_lang);
              END LOOP;
          elsif (upper(r_staupd) in ('P','N')) then
              obj_row.put('error','');
              FOR  ttexempt_rec IN c_ttexempt LOOP
                  p_numexemp          := ttexempt_rec.numexemp;
                  p_flgblist          := ttexempt_rec.flgblist;
                  p_codexemp          := ttexempt_rec.codexemp;
                  p_flgssm            := ttexempt_rec.flgssm;
                  p_desnote_report    := ttexempt_rec.desnote;
                  p_dteupd            := ttexempt_rec.dteupd;
                  if p_dteupd is not null then
                      p_dteupd        := hcm_util.get_date_buddhist_era(p_dteupd);
                  end if;
                  p_coduser           := get_temploy_name(get_codempid(ttexempt_rec.coduser),global_v_lang);
              END LOOP;
          else

              FOR  ttexempt_rec IN c_ttexempt LOOP
                  p_numexemp          := ttexempt_rec.numexemp;
                  p_flgblist          := ttexempt_rec.flgblist;
                  p_codexemp          := ttexempt_rec.codexemp;
                  p_flgssm            := ttexempt_rec.flgssm;
                  p_desnote_report    := ttexempt_rec.desnote;
                  p_dteupd            := ttexempt_rec.dteupd;
                  if p_dteupd is not null then
                      p_dteupd        := hcm_util.get_date_buddhist_era(p_dteupd);
                  end if;
                  p_coduser           := get_temploy_name(get_codempid(ttexempt_rec.coduser),global_v_lang);
              END LOOP;
         end if;
      else
          p_numexemp := '';
          p_flgblist := '';
          p_codexemp := '';
          p_flgssm := '';
          p_desnote_report := '';
          p_dteupd := '';
          p_coduser := '';
      end if ;

      begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
          v_codcomp := null;
      end;
  exception when others then
      null;
  end template3_main;

  procedure template3_table is
      obj_row         json_object_t;
      v_rcnt          number;
      v_intwo         texintwh.intwno%type;
      v_numcate       texintws.numcate%type;
      v_namcate       texintws.namcatee%type;
      v_typeques      texintws.typeques%type;
      v_response      tresintw.response%type;
      v_numqes        tresintw.numqes%type;
      cursor c_tresintw is
          select a.dtereq,a.numseq,a.numqes,a.details,
                 a.response ans,a.typeques,b.intwno,a.numcate
            from tresintw a, tresreq b
           where a.codempid = b.codempid
             and a.dtereq   = b.dtereq
             and a.numseq   = b.numseq
             and a.codempid = p_codempid
             and b.staappr  = 'Y';

      cursor c3 is
          select a.dtereq,a.numseq,a.numqes,a.details,
                 a.response ans,a.typeques,b.intwno
            from tresintw a, tresreq b
           where a.codempid = b.codempid
             and a.dtereq   = b.dtereq
             and a.numseq   = b.numseq
             and a.codempid = p_codempid
             and a.numqes = v_numqes
             and a.numcate = v_numcate
             and b.staappr  = 'Y';
      cursor c1 is
          select numcate,
                 decode(global_v_lang,'101',namcatee,
                          '102',namcatet,
                          '103',namcate3,
                          '104',namcate4,
                          '105',namcate5,namcatee) as namcate,
                 typeques
            from texintws
           where INTWNO = v_intwo
           order by numcate;

      cursor c2 is
          select numseq,
                 decode(global_v_lang,'101',detailse,
                          '102',detailst,
                          '103',details3,
                          '104',details4,
                          '105',details5,detailse) as details
            from texintwd
           where INTWNO = v_intwo
             and numcate = v_numcate;

  begin

      v_rcnt := 1;
--        v_intwo :='8888';
--        for r1 in c1 loop -- category
--            v_numcate       := r1.numcate;
--            v_namcate       := r1.namcate;
--            v_typeques      := r1.typeques;
--            for r2 in c2 loop -- question
--                v_numqes := r2.numseq;
--                v_response := '';
--                for r3 in c3 loop
--                    v_response := r3.ans;
--                end loop;
--
--                if v_typeques = '1' then
--                    v_response := v_response;
--                elsif v_typeques = '2' then
--                    begin
--                    select decode(global_v_lang,'101',detailse,
--                            '102',detailst,
--                            '103',details3,
--                            '104',details4,
--                            '105',details5,detailse)
--                      into v_response
--                      from texintwc
--                     where intwno = v_intwo
--                       and  numcate = v_numcate
--                       and numseq = v_numqes
--                       and numans = v_response;
--                    exception when others then
--                      null;
--                    end;
--                end if;
--                v_response := 'ทดสอบคำตอบ ทดสอบคำตอบ ทดสอบคำตอบ ทดสอบคำตอบ ทดสอบคำตอบ ทดสอบคำตอบ ทดสอบคำตอบ';
--                INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
--                                      ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
--                     VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
--                             p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),1, 'TABLE',
--                             v_rcnt,r2.details,v_response );
--
--                v_numseq_report := v_numseq_report + 1;
--                v_rcnt          := v_rcnt + 1;
--            end loop;
--
--            commit;
--        end loop;
      for r1 in c_tresintw loop
          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),1, 'TABLE',
                       v_rcnt, r1.details, r1.ans);
          commit;
          v_numseq_report := v_numseq_report + 1;
          v_rcnt          := v_rcnt + 1;
      end loop;
  exception when others then
      null;
end template3_table;

  procedure template4_main is
      CURSOR c1 IS
          select round( dteduepr - dteeffec ) + 1 countday, dteend,
                 numseq, stapost2, numreqst, flgduepr,
                 dteduepr, desnote
            from ttmovemt
           where codempid = p_codempid
             and numseq = p_numseq
             and dteeffec = p_dteeffec
             and codtrn > '0007'
        order by dteeffec desc,
                 numseq;
  BEGIN
      FOR r1 IN c1 LOOP
          p_dteend_report     := to_char(r1.dteend, 'dd/mm/yyyy');
          p_numseq_report     := r1.numseq;
          p_stapost2          := r1.STAPOST2;
          p_numreqst          := r1.NUMREQST;
          p_flgduepr          := r1.FLGDUEPR;
          p_countday          := r1.countday;
          p_dteduepr          := r1.DTEDUEPR;
          if p_dteduepr is not null then
             p_dteduepr := hcm_util.get_date_buddhist_era(p_dteduepr);
          end if;
          p_desnote_report := r1.DESNOTE;
      END LOOP;
  EXCEPTION WHEN OTHERS THEN
      null;
end template4_main;

  procedure template4_table is
      TYPE p_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      v_rcnt                  NUMBER;
      v_total                 p_num;
      v_adjust                p_num;
      v_amont                 p_num;
      countloop               NUMBER := 0;
      v_countrow_ttmovemt     NUMBER;
      v_total2                p_num;
      v_adjust2               p_num;
      v_amont2                p_num;
      v_total3                p_num;
      v_adjust3               p_num;
      v_amont3                p_num;
      obj_row1                json_object_t;
      obj_row2                json_object_t;
      obj_row3                json_object_t;
      obj_row4                json_object_t;
      obj_row5                json_object_t;
      obj_row6                json_object_t;
      obj_row7                json_object_t;
      obj_row8                json_object_t;
      obj_row9                json_object_t;
      obj_row10               json_object_t;
      obj_row11               json_object_t;
      obj_row12               json_object_t;
      obj_data1               json_object_t;
      obj_data2               json_object_t;
      obj_data3               json_object_t;
      obj_data4               json_object_t;
      obj_data5               json_object_t;
      obj_data6               json_object_t;
      obj_data7               json_object_t;
      obj_data8               json_object_t;
      obj_data9               json_object_t;
      obj_data10              json_object_t;
      obj_data11              json_object_t;
      obj_data12              json_object_t;
      obj_row                 json_object_t;
      obj_data                json_object_t;
      obj_data_sal            json_object_t;
      obj_sal                 json_object_t;
      obj_sal_sum             json_object_t;
      obj_field               json_object_t;
      v_codcomp               ttmovemt.codcomp%TYPE;
      v_codpos                ttmovemt.codpos%TYPE;
      v_numlvl                ttmovemt.numlvl%TYPE;
      v_codjob                ttmovemt.codjob%TYPE;
      v_codempmt              ttmovemt.codempmt%TYPE;
      v_typemp                ttmovemt.typemp%TYPE;
      v_typpayroll            ttmovemt.typpayroll%TYPE;
      v_codbrlc               ttmovemt.codbrlc%TYPE;
      v_flgatten              ttmovemt.flgatten%TYPE;
      v_codcalen              ttmovemt.codcalen%TYPE;
      v_jobgrade              ttmovemt.jobgrade%TYPE;
      v_codgrpgl              ttmovemt.codgrpgl%TYPE;
      v_codcompt              ttmovemt.codcompt%TYPE;
      v_codposnow             ttmovemt.codposnow%TYPE;
      v_numlvlt               ttmovemt.numlvlt%TYPE;
      v_codjobt               ttmovemt.codjobt%TYPE;
      v_codempmtt             ttmovemt.codempmtt%TYPE;
      v_typempt               ttmovemt.typempt%TYPE;
      v_typpayrolt            ttmovemt.typpayrolt%TYPE;
      v_codbrlct              ttmovemt.codbrlct%TYPE;
      v_flgattet              ttmovemt.flgattet%TYPE;
      v_codcalet              ttmovemt.codcalet%TYPE;
      v_jobgradet             ttmovemt.jobgrade%TYPE;
      v_codgrpglt             ttmovemt.codgrpglt%TYPE;
      v_stapost2              ttmovemt.stapost2%TYPE;
      codincom_dteeffec       VARCHAR(200);
      codincom_codempmt       VARCHAR(200);
      v_datasal               CLOB;
      paramsearchdetail       json_object_t;
      v_amtothr_income        NUMBER := 0;
      v_amtday_income         NUMBER := 0;
      v_sumincom_income       NUMBER := 0;
      v_amtothr_adj           NUMBER := 0;
      v_amtday_adj            NUMBER := 0;
      v_sumincom_adj          NUMBER := 0;
      v_amtothr_simple        NUMBER := 0;
      v_amtday_simple         NUMBER := 0;
      v_sumincom_simple       NUMBER := 0;
      sal_amtincom            p_num;
      sal_amtincadj           p_num;
      sal_pctadj              p_num;
      param_json              json_object_t;
      obj_sum                 json_object_t;
      v_countday              VARCHAR2(200 CHAR);
      obj_rowsal              json_object_t;
      param_json_row          json_object_t;
      v_codincom              tinexinf.codpay%TYPE;
      v_desincom              tinexinf.descpaye%TYPE;
      cnt_row                 NUMBER := 0;
      v_desunit               VARCHAR2(150 CHAR);
      v_amtmax                NUMBER;
      v_amount                NUMBER;
      v_row                   NUMBER := 0;
      obj_data_salary         json_object_t;
      temp1_codcomp           temploy1.codcomp%TYPE;
      temp1_codpos            temploy1.codpos%TYPE;
      temp1_numlvl            temploy1.numlvl%TYPE;
      temp1_codjob            temploy1.codjob%TYPE;
      temp1_codempmt          temploy1.codempmt%TYPE;
      temp1_typemp            temploy1.typemp%TYPE;
      temp1_typpayroll        temploy1.typpayroll%TYPE;
      temp1_codbrlc           temploy1.codbrlc%TYPE;
      temp1_flgatten          temploy1.flgatten%TYPE;
      temp1_codcalen          temploy1.codcalen%TYPE;
      temp1_jobgrade          temploy1.jobgrade%TYPE;
      temp1_codgrpgl          temploy1.codgrpgl%TYPE;
      tt_stapost2             ttmovemt.stapost2%TYPE;
      tt_flgduepr             ttmovemt.flgduepr%TYPE;
      v_flgtype               NUMBER;
      data_in                 CLOB;
      data_out                CLOB;
      paramjson               json_object_t;
      objtemp                 json_object_t;
      detail_flag             VARCHAR2(100 CHAR) := 'selectIndex';
      t_persent               VARCHAR2(100 CHAR);
      t_amtmax                VARCHAR2(100 CHAR);
      v_flgadjin              ttmovemt.flgadjin%type;

      CURSOR detailmodal IS
          SELECT *
            FROM ttmovemt
           WHERE codempid = p_codempid;

      CURSOR c1 IS
          SELECT ttmovemt.*, ttmovemt.rowid
            FROM ttmovemt
           WHERE codempid = p_codempid
             AND dteeffec = p_dteeffec
             AND numseq = p_numseq
             AND codtrn = p_codcodec;

      flgpass               BOOLEAN;
      v_qtybud              NUMBER;
      modal_tab             json_object_t;
      v_qtyman              NUMBER;
      v_qtyret              NUMBER;
      v_qtynew1             NUMBER;
      v_qtynew2             NUMBER;
      v_qtynew              NUMBER;
      v_qtywip              NUMBER;
      v_qtywipemp           NUMBER;
      v_qtyvac              NUMBER;
      detail_modal          json_object_t;
      chk_staemp_9          temploy1.staemp%type;
      v_dteempmt            temploy1.dteempmt%type;
  BEGIN
      begin
          select dteempmt
            into v_dteempmt
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
          v_dteempmt := null;
      end;

      if (v_dteempmt > p_dteeffec) then
          return;
      end if;

      begin
          select staemp
            into chk_staemp_9
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
          chk_staemp_9 := null;
      end;

      obj_sum         := json_object_t();
      obj_row         := json_object_t();
      obj_data        := json_object_t();
      v_rcnt          := 0;
      obj_row1        := json_object_t();
      detail_modal    := json_object_t;
      obj_data1       := json_object_t();
      obj_data2       := json_object_t();
      obj_data3       := json_object_t();
      obj_data4       := json_object_t();
      obj_data5       := json_object_t();
      obj_data6       := json_object_t();
      obj_data7       := json_object_t();
      obj_data8       := json_object_t();
      obj_data9       := json_object_t();
      obj_data10      := json_object_t();
      obj_data11      := json_object_t();
      obj_data12      := json_object_t();
      modal_tab       := json_object_t();

          BEGIN
              SELECT round( dteduepr - dteeffec ) countday,
                     codcompt, codposnow, numlvlt, codjobt,
                     codempmtt, typempt, typpayrolt,
                     codbrlct, flgattet, codcalet, jobgradet, codgrpglt,
                     codcomp, codpos, numlvl, codjob, codempmt,
                     typemp, typpayroll, codbrlc, flgatten,
                     codcalen, jobgrade, codgrpgl, flgadjin
                INTO v_countday, v_codcompt, v_codposnow, v_numlvlt, v_codjobt,
                     v_codempmtt, v_typempt, v_typpayrolt, v_codbrlct, v_flgattet,
                     v_codcalet, v_jobgradet, v_codgrpglt,
                     v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt,
                     v_typemp, v_typpayroll, v_codbrlc, v_flgatten,
                     v_codcalen, v_jobgrade, v_codgrpgl, v_flgadjin
                FROM ttmovemt
               WHERE codempid = p_codempid
                 AND dteeffec = p_dteeffec
                 AND numseq = p_numseq
                 AND codtrn = p_codcodec;
          EXCEPTION
              WHEN no_data_found THEN
                  v_countday      := NULL;
                  v_codcompt      := NULL;
                  v_codposnow     := NULL;
                  v_numlvlt       := NULL;
                  v_codjobt       := NULL;
                  v_codempmtt     := NULL;
                  v_typempt       := NULL;
                  v_typpayrolt    := NULL;
                  v_codbrlct      := NULL;
                  v_flgattet      := NULL;
                  v_codcalet      := NULL;
                  v_jobgradet     := NULL;
                  v_codgrpglt     := NULL;
          END;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL', get_label_name('HRPM44U', global_v_lang, 10),
                       v_codcompt, v_codcomp);
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL', '',
                       get_tcenter_name(v_codcompt,global_v_lang),
                       get_tcenter_name(v_codcomp,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL',
                       get_label_name('HRPM44U', global_v_lang, 20),
                       v_codposnow||' - '||get_tpostn_name(v_codposnow,global_v_lang),
                       v_codpos||' - '||get_tpostn_name(v_codpos,global_v_lang));
          commit;

          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL',
                       get_label_name('HRPM44U', global_v_lang, 30), v_numlvlt, v_numlvl);
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL',
                       get_label_name('HRPM44U', global_v_lang, 40),
                       v_codjobt||' - '||get_tjobcode_name(v_codjobt,global_v_lang),
                       v_codjob||' - '||get_tjobcode_name(v_codjob,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL',
                      get_label_name('HRPM44U', global_v_lang, 50),
                      v_codempmtt||' - '||get_tcodec_name('TCODEMPL',v_codempmtt,global_v_lang),
                      v_codempmt||' - '||get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                       'TABLE1_DETAIL',
                      get_label_name('HRPM44U', global_v_lang, 60),
                      v_typempt||' - '||get_tcodec_name('TCODCATG',v_typempt,global_v_lang),
                      v_typemp||' - '||get_tcodec_name('TCODCATG',v_typemp,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
          VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                  p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq, 'TABLE1_DETAIL',
                  get_label_name('HRPM44U', global_v_lang, 70),
                  v_typpayrolt||' - '||get_tcodec_name('TCODTYPY',v_typpayrolt,global_v_lang),
                  v_typpayroll||' - '||get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
          VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                  p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,'TABLE1_DETAIL',
                  get_label_name('HRPM44U', global_v_lang, 80),
                  v_codbrlct||' - '||get_tcodec_name('TCODLOCA',v_codbrlct,global_v_lang),
                  v_codbrlc||' - '||get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,'TABLE1_DETAIL',
                       get_label_name('HRPM44U', global_v_lang, 90),
                       GET_TLISTVAL_NAME('NAMSTAMP',v_flgattet,global_v_lang),
                       GET_TLISTVAL_NAME('NAMSTAMP',v_flgatten,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
          VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                  p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq, 'TABLE1_DETAIL',
                  get_label_name('HRPM44U', global_v_lang, 100),
                  v_codcalet||' - '||get_tcodec_name('TCODWORK',v_codcalet,global_v_lang),
                  v_codcalen||' - '||get_tcodec_name('TCODWORK',v_codcalen,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
          VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                  p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq, 'TABLE1_DETAIL',
                  get_label_name('HRPM44U', global_v_lang, 110),
                  v_jobgradet||' - '||get_tcodec_name('TCODJOBG',v_jobgradet,global_v_lang),
                  v_jobgrade||' - '||get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

          INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7)
               VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                       p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq, 'TABLE1_DETAIL',
                       get_label_name('HRPM44U', global_v_lang, 120),
                       v_codgrpglt||' - '||get_tcodec_name('TCODGRPGL',v_codgrpglt,global_v_lang),
                       v_codgrpgl||' - '||get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang));
          commit;
          v_numseq_report := v_numseq_report + 1;

--            IF ( p_codcodec = '0015' OR  p_codcodec = '0009'  ) THEN

              if v_flgadjin = 'Y' then

              BEGIN
                  SELECT stddec(amtincom1, codempid, global_v_chken),
                         stddec(amtincom2, codempid, global_v_chken),
                         stddec(amtincom3, codempid, global_v_chken),
                         stddec(amtincom4, codempid, global_v_chken),
                         stddec(amtincom5, codempid, global_v_chken),
                         stddec(amtincom6, codempid, global_v_chken),
                         stddec(amtincom7, codempid, global_v_chken),
                         stddec(amtincom8, codempid, global_v_chken),
                         stddec(amtincom9, codempid, global_v_chken),
                         stddec(amtincom10, codempid, global_v_chken),

                         stddec(amtincadj1, codempid, global_v_chken),
                         stddec(amtincadj2, codempid, global_v_chken),
                         stddec(amtincadj3, codempid, global_v_chken),
                         stddec(amtincadj4, codempid, global_v_chken),
                         stddec(amtincadj5, codempid, global_v_chken),
                         stddec(amtincadj6, codempid, global_v_chken),
                         stddec(amtincadj7, codempid, global_v_chken),
                         stddec(amtincadj8, codempid, global_v_chken),
                         stddec(amtincadj9, codempid, global_v_chken),
                         stddec(amtincadj10, codempid, global_v_chken),
                           pctadj1, pctadj2, pctadj3, pctadj4, pctadj5,
                           pctadj6, pctadj7, pctadj8, pctadj9, pctadj10
                    INTO sal_amtincom(1),
                         sal_amtincom(2),
                         sal_amtincom(3),
                         sal_amtincom(4),
                         sal_amtincom(5),
                         sal_amtincom(6),
                         sal_amtincom(7),
                         sal_amtincom(8),
                         sal_amtincom(9),
                         sal_amtincom(10),
                         sal_amtincadj(1),
                         sal_amtincadj(2),
                         sal_amtincadj(3),
                         sal_amtincadj(4),
                         sal_amtincadj(5),
                         sal_amtincadj(6),
                         sal_amtincadj(7),
                         sal_amtincadj(8),
                         sal_amtincadj(9),
                         sal_amtincadj(10),
                           sal_pctadj(1), sal_pctadj(2),
                           sal_pctadj(3), sal_pctadj(4),
                           sal_pctadj(5), sal_pctadj(6),
                           sal_pctadj(7), sal_pctadj(8),
                           sal_pctadj(9), sal_pctadj(10)
                     FROM ttmovemt
                    WHERE codempid = p_codempid
                      AND dteeffec = p_dteeffec
                      AND numseq = p_numseq
                      AND codtrn = p_codcodec;
              EXCEPTION WHEN no_data_found THEN
                  sal_amtincadj(1) := 0;
                  sal_amtincadj(2) := 0;
                  sal_amtincadj(3) := 0;
                  sal_amtincadj(4) := 0;
                  sal_amtincadj(5) := 0;
                  sal_amtincadj(6) := 0;
                  sal_amtincadj(7) := 0;
                  sal_amtincadj(8) := 0;
                  sal_amtincadj(9) := 0;
                  sal_amtincadj(10) := 0;
              END;

              else
				BEGIN
					SELECT greatest(0,stddec(amtincom1, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom2, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom3, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom4, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom5, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom6, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom7, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom8, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom9, codempid, global_v_chken)),
                           greatest(0,stddec(amtincom10, codempid, global_v_chken))
					  INTO sal_amtincom(1), sal_amtincom(2),
                           sal_amtincom(3), sal_amtincom(4),
                           sal_amtincom(5), sal_amtincom(6),
                           sal_amtincom(7), sal_amtincom(8),
                           sal_amtincom(9), sal_amtincom(10)
					  FROM temploy3
					 WHERE codempid = p_codempid;
				EXCEPTION WHEN no_data_found THEN
					sal_amtincom(1)     := 0;
					sal_amtincom(2)     := 0;
					sal_amtincom(3)     := 0;
					sal_amtincom(4)     := 0;
					sal_amtincom(5)     := 0;
					sal_amtincom(6)     := 0;
					sal_amtincom(7)     := 0;
					sal_amtincom(8)     := 0;
					sal_amtincom(9)     := 0;
					sal_amtincom(10)    := 0;
				END;
                    sal_amtincadj(1) := 0;
                    sal_amtincadj(2) := 0;
                    sal_amtincadj(3) := 0;
                    sal_amtincadj(4) := 0;
                    sal_amtincadj(5) := 0;
                    sal_amtincadj(6) := 0;
                    sal_amtincadj(7) := 0;
                    sal_amtincadj(8) := 0;
                    sal_amtincadj(9) := 0;
                    sal_amtincadj(10) := 0;
                    sal_pctadj(1) := 0;
                    sal_pctadj(2) := 0;
                    sal_pctadj(3) := 0;
                    sal_pctadj(4) := 0;
                    sal_pctadj(5) := 0;
                    sal_pctadj(6) := 0;
                    sal_pctadj(7) := 0;
                    sal_pctadj(8) := 0;
                    sal_pctadj(9) := 0;
                    sal_pctadj(10) := 0;
              end if;

              BEGIN
                  SELECT to_char(( SELECT MAX(dteeffec)
                                     FROM tcontpms
                                    WHERE codcompy LIKE '%' || v_codcomp || '%' ), 'ddmmyyyy'),
                         codempmt
                    INTO codincom_dteeffec, codincom_codempmt
                    FROM temploy1
                   WHERE codempid = p_codempid;
              EXCEPTION WHEN no_data_found THEN
                  v_codcomp := NULL;
                  codincom_dteeffec := NULL;
                  codincom_codempmt := NULL;
              END;

--              v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcomp, 1)
--                                               || ''',"p_dteeffec":''' || codincom_dteeffec
--                                               || ''',"p_codempmt":''' || v_codempmt
--                                               || ''',"p_lang":''' || global_v_lang || '''}');
			  v_datasal := hcm_pm.get_codincom('{"p_codcompy":''' || hcm_util.get_codcomp_level(v_codcomp, 1)
                        || ''',"p_dteeffec":''' || NULL
                        || ''',"p_codempmt":''' || v_codempmt
                        || ''',"p_lang":''' || global_v_lang || '''}');
              param_json := json_object_t(v_datasal);
              obj_rowsal := json_object_t();
              v_row := -1;
              FOR i IN 0..param_json.get_size - 1 LOOP
                  param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
                  v_codincom      := hcm_util.get_string_t(param_json_row, 'codincom');
                  v_desincom      := hcm_util.get_string_t(param_json_row, 'desincom');
                  v_amtmax        := hcm_util.get_string_t(param_json_row, 'amtmax');
                  v_desunit       := hcm_util.get_string_t(param_json_row, 'desunit');
                  IF v_codincom IS NULL OR v_codincom = ' ' THEN
                      EXIT;
                  END IF;
                  v_row := v_row + 1;
                  IF ( sal_amtincom(i + 1)-sal_amtincadj(i + 1) = 0 ) THEN
                      t_persent := 0;
                  ELSE
--                      t_persent := (sal_amtincadj(i + 1) * 100) / sal_amtincom(i + 1);
                      t_persent := nvl(to_char(sal_pctadj(i + 1)),'');
                  END IF;

                  INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,ITEM9,ITEM10,ITEM11)
                       VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
                              p_codempid, to_char(p_dteeffec,'dd/mm/yyyy'), p_numseq,
                              'TABLE2_DETAIL', v_desincom,
                              to_char(sal_amtincom(i + 1) - sal_amtincadj(i + 1), '999,999,990.00'),
                              nvl(to_char(t_persent, '999,999,990.00'),' '),
                              to_char(sal_amtincadj(i + 1), '999,999,990.00'),
                              to_char(sal_amtincom(i + 1), '999,999,990.00'),
                              v_codincom,v_desunit );
                  commit;
                  v_numseq_report := v_numseq_report + 1;
              END LOOP;

              get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt, nvl(sal_amtincom(1), 0),
                              nvl(sal_amtincom(2), 0), nvl(sal_amtincom(3), 0), nvl(sal_amtincom(4), 0),
                              nvl(sal_amtincom(5), 0), nvl(sal_amtincom(6), 0), nvl(sal_amtincom(7), 0),
                              nvl(sal_amtincom(8), 0), nvl(sal_amtincom(9), 0), nvl(sal_amtincom(10), 0),
                              v_amtothr_income, v_amtday_income, v_sumincom_income);


  -- adj
              get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt, nvl(sal_amtincadj(1), 0),
                              nvl(sal_amtincadj(2), 0), nvl(sal_amtincadj(3), 0), nvl(sal_amtincadj(4), 0), nvl(sal_amtincadj(5), 0),
                              nvl(sal_amtincadj(6), 0), nvl(sal_amtincadj(7), 0), nvl(sal_amtincadj(8), 0), nvl(sal_amtincadj(9), 0),
                              nvl(sal_amtincadj(10), 0), v_amtothr_adj , v_amtday_adj, v_sumincom_adj);
  -- simple

              get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt, nvl(sal_amtincom(1), 0) - nvl(sal_amtincadj(1), 0),
                              nvl(sal_amtincom(2), 0) - nvl(sal_amtincadj(2), 0), nvl(sal_amtincom(3), 0) - nvl(sal_amtincadj(3), 0),
                              nvl(sal_amtincom(4), 0) - nvl(sal_amtincadj(4), 0), nvl(sal_amtincom(5), 0) - nvl(sal_amtincadj(5), 0),
                              nvl(sal_amtincom(6), 0) - nvl(sal_amtincadj(6), 0), nvl(sal_amtincom(7), 0) - nvl(sal_amtincadj(7), 0),
                              nvl(sal_amtincom(8), 0) - nvl(sal_amtincadj(8), 0), nvl(sal_amtincom(9), 0) - nvl(sal_amtincadj(9), 0),
                              nvl(sal_amtincom(10), 0) - nvl(sal_amtincadj(10), 0), v_amtothr_simple, v_amtday_simple, v_sumincom_simple);
--            END IF;

      p_summary1       := v_sumincom_simple;
      p_summary2       := v_sumincom_adj;
      p_summary3       := v_sumincom_income;
      p_summary4       := v_amtday_simple;
      p_summary5       := v_amtday_adj;
      p_summary6       := v_amtday_income;
      p_summary7       := v_amtothr_simple;
      p_summary8       := v_amtothr_adj;
      p_summary9       := v_amtothr_income;
      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8,
      ITEM9,ITEM10,ITEM11,ITEM12,ITEM13,ITEM14)
      VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
      p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),p_numseq,
      'TABLE3_DETAIL',
      null,--get_label_name('HRPM4DE2', global_v_lang, 650),
      -- total
      to_char(v_sumincom_simple, '999,999,990.99'), --new
      to_char(v_sumincom_adj, '999,999,990.99'), --adj
      to_char(v_sumincom_income, '999,999,990.99'),
      -- Daily
      to_char(v_amtday_simple, '999,999,990.99'),--new
      to_char(v_amtday_adj, '999,999,990.99'), --adj
      to_char(v_amtday_income, '999,999,990.99'),
      -- Per Hour
      to_char(v_amtothr_simple, '999,999,990.99'),--new
      to_char(v_amtothr_adj, '999,999,990.99'), --adj
      to_char(v_amtothr_income, '999,999,990.99')
      );
      commit;
      v_numseq_report := v_numseq_report + 1;


--      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8)
--      VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
--      p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),p_numseq,
--      'TABLE3_DETAIL',
--      get_label_name('HRPM4DE2', global_v_lang, 650),
--      to_char(v_amtothr_income, '999,999,990.99'),
--      to_char(v_amtday_income, '999,999,990.99'),
--      to_char(v_sumincom_income, '999,999,990.99')
--      );
--      commit;
--      v_numseq_report := v_numseq_report + 1;
--
--      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8)
--      VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
--      p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),p_numseq,
--      'TABLE3_DETAIL',
--      get_label_name('HRPM4DE2', global_v_lang, 660),
--      to_char(v_amtothr_adj, '999,999,990.99'),
--      to_char(v_amtday_adj, '999,999,990.99'),
--      to_char(v_sumincom_adj, '999,999,990.99')
--      );
--      commit;
--      v_numseq_report := v_numseq_report + 1;
--
--      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,ITEM1,ITEM2,ITEM3,ITEM4,ITEM5,ITEM6,ITEM7,ITEM8)
--      VALUES (global_v_codempid, 'HRPM43X',v_numseq_report,
--      p_codempid,to_char(p_dteeffec,'dd/mm/yyyy'),p_numseq,
--      'TABLE3_DETAIL',
--      get_label_name('HRPM4DE2', global_v_lang, 670),
--      to_char(v_amtothr_simple, '999,999,990.99'),
--      to_char(v_amtday_simple, '999,999,990.99'),
--      to_char(v_sumincom_simple, '999,999,990.99')
--      );
--      commit;
--      v_numseq_report := v_numseq_report + 1;

end template4_table;

  function get_flgduepr(
      p_flgduepr in varchar2)
      return varchar2 is
  begin
      if p_flgduepr is not null then
          if p_flgduepr = 'Y' then
              return get_label_name('HRPM43X2', global_v_lang, 190);
          end if;
          if p_flgduepr = 'N' then
              return get_label_name('HRPM43X2', global_v_lang, 200);
          end if;
      else
          return '';
      end if;
  end get_flgduepr;

END HRPM43X;

/

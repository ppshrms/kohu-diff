--------------------------------------------------------
--  DDL for Package Body HRPM31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM31E" IS
--28/01/2023||SEA-HR2201||redmine680  
  PROCEDURE initial_value (json_str IN CLOB) IS
    json_obj    json_object_t;
    BEGIN
        json_obj              := json_object_t(json_str);
        global_v_coduser      := hcm_util.get_string_t(json_obj, 'p_coduser');
        global_v_codpswd      := hcm_util.get_string_t(json_obj, 'p_codpswd');
        global_v_lang         := hcm_util.get_string_t(json_obj, 'p_lang');
        global_v_codempid     := hcm_util.get_string_t(json_obj, 'p_codempid');
        p_codempid_query      := hcm_util.get_string_t(json_obj, 'p_codempid_query');
        p_dtestr              := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dtestr')), 'dd/mm/yyyy');
        p_dteend              := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteend')), 'dd/mm/yyyy');
        p_codcomp             := hcm_util.get_string_t(json_obj, 'p_codcomp');
        p_codpos              := hcm_util.get_string_t(json_obj, 'p_codpos');
        p_typproba            := hcm_util.get_string_t(json_obj, 'p_typproba');
        p_numseq              := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
        p_numtime             := to_number(hcm_util.get_string_t(json_obj, 'p_numtime'));
        p_dteduepr            := TO_DATE(hcm_util.get_string_t(json_obj, 'p_dteduepr'), 'dd/mm/yyyy');
        p_flgfixcodempid      := hcm_util.get_boolean_t(json_obj, 'p_flgfixcodempid');
        detail_codempid       := p_codempid_query;
        p_flgsubmit_disable   := hcm_util.get_boolean_t(json_obj, 'p_flgsubmit_disable');
        global_v_codapp       := hcm_util.get_string_t(json_obj,'p_codapp');
        p_modal_dteeffec      := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_modal_dteeffec')), 'dd/mm/yyyy');
        p_modal_numseq        := hcm_util.get_string_t(json_obj, 'p_modal_numseq');
        tab3_dtestrt          := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dtestrt')), 'dd/mm/yyyy');
        tab3_dteend           := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dteend')), 'dd/mm/yyyy');

        detail_flag_tab3      := hcm_util.get_boolean_t(json_obj, 'detail_flag_tab3');
        detail_numseq         := hcm_util.get_string_t(json_obj, 'detail_numseq');
        detail_numtime        := hcm_util.get_string_t(json_obj, 'detail_numtime');
        detail_flag           := hcm_util.get_string_t(json_obj, 'p_detail_flag');
        display_codeval       := hcm_util.get_string_t(json_obj, 'display_codeval');
        hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  END initial_value;

  PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB) AS
    v_staemp        temploy1.staemp%type;
    v_flgsecure     boolean;
  BEGIN
      initial_value(json_str_input);

      IF p_codempid_query IS NOT NULL THEN
          SELECT staemp
            INTO v_staemp
            FROM temploy1
           WHERE codempid = p_codempid_query;
      END IF;

      IF ( p_codempid_query IS NULL AND p_codcomp IS NULL ) THEN
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
          return;
      END IF;
      IF ( p_codcomp IS NOT NULL AND ( p_dtestr IS NULL OR p_dteend IS NULL ) ) THEN
          param_msg_error := get_error_msg_php('HR2045', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
          return;
      END IF;
      IF v_staemp not in ('1','3') THEN
          param_msg_error := get_error_msg_php('PM0033', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
          return;
      END IF;

      if p_codempid_query is not null then
        v_flgsecure := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecure then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
        end if;
      end if;

      if p_codcomp is not null then
        v_flgsecure := secur_main.secur7(p_codcomp, global_v_coduser);
        if not v_flgsecure then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
        end if;
      end if;

      IF param_msg_error IS NULL THEN
          gen_index(json_str_output);
      ELSE
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END IF;

  EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index;

  PROCEDURE gen_index ( json_str_output OUT CLOB ) AS
    obj_row                 json_object_t;
    obj_data                json_object_t;
    obj_result              json_object_t;
    v_rcnt                  NUMBER := 0;
    v_count_tproasgn        NUMBER := 0;
    v_zupdsal               VARCHAR(1 CHAR);
    v_stapud                ttprobat.staupd%TYPE;
    flgpass                 BOOLEAN;
    obj_data_obj            VARCHAR(200);
    obj                     json_object_t;
    temp1_dteempmt          temploy1.dteempmt%TYPE;
    v_codempid              temploy1.codempid%type;
    v_dteduepr              tappbath.dteduepr%type;
    v_codrespr              tappbath.codrespr%type;
    v_flgdata               boolean := false;
    v_flgsecure             boolean := false;
    v_chk_exists_ttprobat   boolean;
    v_chk_exitst_notpass    boolean;
    v_chk_codempid          temploy1.codempid%type;

    v_max_numtime           number;
    v_max_numseq            number;

      CURSOR c1 IS
          SELECT '1' typproba, t1.codempid, t1.codcomp, t1.codpos, t1.dteempmt,
                 nvl(t1.dteredue, t1.dteduepr) dteduepr, t1.numlvl, t1.staemp, NULL dteeffec, NULL numseq
            FROM temploy1 t1
           WHERE t1.codcomp LIKE p_codcomp || '%'
             AND t1.codempid = nvl(p_codempid_query, t1.codempid)
             AND t1.staemp IN ( 1 )
             AND nvl(t1.dteredue, t1.dteduepr) BETWEEN nvl(p_dtestr, nvl(t1.dteredue, t1.dteduepr)) AND nvl(p_dteend, nvl(t1.dteredue , t1.dteduepr))
--             AND NOT EXISTS ( SELECT codempid
--                                FROM ttprobat
--                               WHERE t1.codempid = codempid
--                                 AND t1.dteduepr = dteduepr )
           UNION
          SELECT '2' typproba, t2.codempid, t2.codcomp, t2.codpos, NULL dteempmt,
                 t2.dteduepr, t2.numlvl, t2.staupd, t2.dteeffec, t2.numseq
            FROM ttmovemt   t2,
                 tcodmove   t3
           WHERE t2.codcomp LIKE p_codcomp || '%'
             AND t2.codempid = nvl(p_codempid_query, t2.codempid)
             AND t3.typmove in ( 'M','8')
             AND t2.staupd = 'U'
             AND t2.dteduepr BETWEEN nvl(p_dtestr, dteduepr) AND nvl(p_dteend, dteduepr)
             AND t2.codtrn = t3.codcodec (+)
             AND NOT EXISTS ( SELECT codempid
                                FROM temploy1
                               WHERE codempid = t2.codempid
                                 AND staemp = '9' )
--             AND NOT EXISTS ( SELECT codempid
--                                FROM ttprobat
--                               WHERE t2.codempid = codempid
--                                 AND t2.dteduepr = dteduepr)
            ;
        v_flgfixcodempidpass boolean;
        v_maxnumtime    number;
        v_maxnumseq     number;
        v_codeval       temploy1.codempid%type;

    cursor c2 is
        select codrespr
          from tappbath
         where codempid = v_codempid
           and dteduepr = v_dteduepr
           and dteeval is not null
      order by numtime desc, numseq desc;
  BEGIN
      obj_row := json_object_t();
      flgpass := false;
      v_flgfixcodempidpass := false;

      FOR r1 IN c1 LOOP
        v_codempid      := r1.codempid;
        v_dteduepr      := r1.dteduepr;

        v_max_numtime   := get_max_numtime(v_codempid,v_dteduepr);
        v_max_numseq    := get_max_numseq(v_codempid,v_dteduepr,v_max_numtime);

        begin
            select codempid
              into v_chk_codempid
              from ttprobat
             where codempid = v_codempid
               and dteduepr = v_dteduepr;
            v_chk_exists_ttprobat := true;
        exception when no_data_found then
            v_chk_exists_ttprobat := false;
        end;

        begin
            select t1.codempid
              into v_chk_codempid
              from ttprobat t1, tappbath t2
             where t1.codempid = v_codempid
               and t1.dteduepr = v_dteduepr
               and t1.staupd in ('P')
               and t1.codempid = t2.codempid
               and t1.dteduepr = t2.dteduepr
               and t2.numtime = v_max_numtime
               and t2.numseq = v_max_numseq
               and t2.codrespr = 'N'
               and t2.staeval = 'N';
            v_chk_exitst_notpass := true;
        exception when no_data_found then
            v_chk_exitst_notpass := false;
        end;
        if not v_chk_exists_ttprobat or v_chk_exitst_notpass then
--        if true then
            v_flgdata   := true;
            v_flgsecure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if v_flgsecure then
                IF p_flgfixcodempid then
                    begin
                        SELECT nvl(max(numtime) ,0)
                          into v_maxnumtime
                          from ttprobatd
                         where codempid = r1.codempid
                           and dteduepr = r1.dteduepr;
                    EXCEPTION WHEN no_data_found THEN
                        v_maxnumtime := 0;
                    end;

                    v_maxnumtime    := nvl(v_maxnumtime,0) + 1 ;
                    begin
                        SELECT nvl(max(numseq),0)
                          into v_maxnumseq
                          from tappbath
                         where codempid = r1.codempid
                           and dteduepr = r1.dteduepr
                           and numtime = v_maxnumtime
                           and flgappr = 'C';
                    EXCEPTION WHEN no_data_found THEN
                        v_maxnumseq := 0;
                    end;

                    v_maxnumseq := nvl(v_maxnumseq,0) + 1;

                    p_typproba := r1.typproba;
                    v_codeval := gen_codeval(r1.codempid, r1.dteduepr, v_maxnumtime, v_maxnumseq, global_v_codempid,p_typproba);

                    if v_codeval is not null then
                        v_flgfixcodempidpass := true;
                    else
                        v_flgfixcodempidpass := false;
                    end if;
                ELSE
                    v_flgfixcodempidpass := true;
                END IF;

                IF v_flgfixcodempidpass then
                    flgpass := true;
    --                  IF ( p_codempid_query IS NULL OR p_codempid_query = '' ) THEN
    --                      flgpass := secur_main.secur7(r1.codcomp, global_v_coduser);
    --                  ELSE
    --                      flgpass := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    --                  END IF;
                      v_codrespr := null;
                      FOR r2 IN c2 LOOP
                        v_codrespr := r2.codrespr;
                        exit;
                      end loop;

                      v_rcnt := v_rcnt + 1;
                      obj_data := json_object_t();
                      obj_data.put('coderror', '200');
                      obj_data.put('numseq', TO_CHAR(v_rcnt));
                      obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
                      obj_data.put('codempid', r1.codempid);
                      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
                      obj_data.put('codcomp', r1.codcomp);
                      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
                      obj_data.put('codpos', r1.codpos);
                      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
                      obj_data.put('typproba', r1.typproba);
                      obj_data.put('desc_typproba', get_tlistval_name('NAMTPRO', r1.typproba, global_v_lang));
                      obj_data.put('dteempmt', TO_CHAR(nvl(r1.dteempmt,r1.dteeffec), 'dd/mm/yyyy'));
                      obj_data.put('dteduepr', TO_CHAR(r1.dteduepr, 'dd/mm/yyyy'));
                      obj_data.put('desc_codrespr', get_tlistval_name('CODRESPR', v_codrespr, global_v_lang));
                      obj_data.put('detail_flag', 1);
                      obj_data.put('modal_dteeffec', TO_CHAR(r1.dteeffec, 'dd/mm/yyyy'));
                      obj_data.put('modal_numseq', r1.numseq);
                      obj_row.put(TO_CHAR(v_rcnt - 1), obj_data);
                END IF;
            end if;
        end if;
      END LOOP;

      if not v_flgdata then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TEMPLOY1');
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
          return;
      elsif  NOT flgpass then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          json_str_output := get_response_message('403', param_msg_error, global_v_lang);
          return;
      end if;

      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
  END gen_index;

  PROCEDURE gettab3 ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
      obj_sum           json_object_t;
      obj_row1          json_object_t;
      obj_row2          json_object_t;
      obj_row3          json_object_t;
      json_obj          json_object_t;
      obj_data          json_object_t;
      cursort301        SYS_REFCURSOR;
      cursort302        SYS_REFCURSOR;
      cursort303        SYS_REFCURSOR;
      detail_codempid   ttmovemt.codempid%TYPE;

      v_qtyavgwk        NUMBER;
      o_day             NUMBER;
      o_hr              NUMBER;
      o_min             NUMBER;
      o_dhm             VARCHAR(15 CHAR);
      v_rcnt            NUMBER := 0;
      t303_dteeffec     ttmistk.dteeffec%TYPE;
      t303_codmist      ttmistk.codmist%TYPE;
      t303_desmist1     ttmistk.desmist1%TYPE;
      t303_numseq       ttpunsh.numseq%TYPE;
      t303_codpunsh     ttpunsh.codpunsh%TYPE;
      t303_typpun       ttpunsh.typpun%TYPE;
      t303_dtestart     ttpunsh.dtestart%TYPE;
      t303_dteend       ttpunsh.dteend%TYPE;
      t303_codempid     ttpunsh.codempid%TYPE;
      t301_typleave     VARCHAR(200);
      t301_deslereq     VARCHAR(200);
      t301_qtyday       VARCHAR(200);

      cursor c_leaveabs is
        SELECT 1 numseq,get_label_name('HRPM31E', global_v_lang, 10) typcolumn,
               SUM(daylate) qtyday,
               SUM(qtytlate) qty_sum
          FROM tlateabs
         WHERE codempid = detail_codempid
           AND dtework BETWEEN tab3_dtestrt AND tab3_dteend
         UNION
         SELECT 2 numseq,
             get_label_name('HRPM31E', global_v_lang, 20) typcolumn,
             SUM(dayearly) qtyday,
             SUM(qtytearly) qty_sum
         FROM
             tlateabs
         WHERE
             codempid = detail_codempid
         AND dtework BETWEEN tab3_dtestrt AND tab3_dteend
         UNION
         SELECT 3 numseq,
             get_label_name('HRPM31E', global_v_lang, 30) typcolumn,
             SUM(dayabsent) qtyday,
             SUM(qtytabs) qty_sum
         FROM
             tlateabs
         WHERE
             codempid = detail_codempid
         AND dtework BETWEEN tab3_dtestrt AND tab3_dteend;
  BEGIN
      json_obj          := json_object_t(json_str_input);
      global_v_lang     := hcm_util.get_string_t(json_obj, 'p_lang');
      detail_codempid   := hcm_util.get_string_t(json_obj, 'detail_codempid');
      detail_codcomp    := hcm_util.get_string_t(json_obj, 'detail_codcomp');
      tab3_dtestrt      := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dtestrt')), 'dd/mm/yyyy');

      tab3_dteend       := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dteend')), 'dd/mm/yyyy');

      OPEN cursort301 FOR
        SELECT SUM(qtyday) qtyday, typleave
          FROM tleavetr
         WHERE codempid = detail_codempid
           AND dtework BETWEEN tab3_dtestrt AND tab3_dteend
      GROUP BY typleave
      ORDER BY typleave;

      OPEN cursort303 FOR SELECT
                             a.dteeffec,
                             a.codmist,
                             a.desmist1,
                             b.numseq,
                             b.codpunsh,
                             b.typpun,
                             b.dtestart,
                             b.dteend,
                             b.codempid
                         FROM
                             ttmistk   a,
                             ttpunsh   b
                         WHERE
                             a.codempid = detail_codempid
                             AND a.codempid = b.codempid
                             AND a.dteeffec = b.dteeffec
                             AND a.staupd IN ('C','U')
                             AND a.dteeffec BETWEEN nvl(tab3_dtestrt, a.dteeffec) AND nvl(tab3_dteend, a.dteeffec)
                         ORDER BY
                             a.dteeffec,
                             b.codpunsh,
                             b.numseq;

      obj_row1 := json_object_t();
      obj_row2 := json_object_t();
      obj_row3 := json_object_t();

      v_rcnt := 0;
      LOOP
          FETCH cursort301 INTO
              t301_qtyday,
              t301_typleave;
          EXIT WHEN cursort301%notfound;
          obj_data := json_object_t();
          obj_data := json_object_t();
          obj_data.put('typleave', t301_typleave);
          obj_data.put('desc_typleave', get_tleavety_name(t301_typleave, global_v_lang));
          v_qtyavgwk := func_get_qtyavgwk (detail_codcomp);
          hcm_util.cal_dhm_hm(t301_qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);

          obj_data.put('numleave', o_dhm);
          v_rcnt := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_row1.put(TO_CHAR(v_rcnt), obj_data);
      END LOOP;

      v_rcnt := 0;
      for r_leaveabs in c_leaveabs loop
          obj_data      := json_object_t();
          v_qtyavgwk    := func_get_qtyavgwk (detail_codcomp);
          hcm_util.cal_dhm_hm(r_leaveabs.qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          obj_data.put('coderror', '200');
          obj_data.put('totalcount', o_dhm);
          obj_data.put('typecolum', r_leaveabs.typcolumn);
          obj_data.put('quantity', nvl(r_leaveabs.qty_sum, 0));
          v_rcnt        := v_rcnt + 1;
          obj_row2.put(TO_CHAR(v_rcnt), obj_data);
      end loop;

      v_rcnt := 0;
      LOOP
          FETCH cursort303 INTO
              t303_dteeffec,
              t303_codmist,
              t303_desmist1,
              t303_numseq,
              t303_codpunsh,
              t303_typpun,
              t303_dtestart,
              t303_dteend,
              t303_codempid;

          EXIT WHEN cursort303%notfound;
          obj_data := json_object_t();
          obj_data.put('dteeffec', TO_CHAR(t303_dteeffec, 'dd/mm/yyyy'));
          obj_data.put('codmist', get_tcodec_name('TCODMIST', t303_codmist, global_v_lang));
          obj_data.put('desmist1', t303_desmist1);
          obj_data.put('numseq', t303_numseq);
          obj_data.put('codpunsh', get_tcodec_name('TCODPUNH', t303_codpunsh, global_v_lang));
          obj_data.put('typpun', get_tlistval_name('NAMTPUN', t303_typpun, global_v_lang));
          obj_data.put('dtestart', TO_CHAR(t303_dtestart, 'dd/mm/yyyy'));
          obj_data.put('dteend', TO_CHAR(t303_dteend, 'dd/mm/yyyy'));
          v_rcnt := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_row3.put(TO_CHAR(v_rcnt), obj_data);
      END LOOP;

      obj_sum := json_object_t();
      obj_sum.put('coderror', '200');
      obj_sum.put('table1', obj_row1);
      obj_sum.put('table2', obj_row2);
      obj_sum.put('table3', obj_row3);
      dbms_lob.createtemporary(json_str_output, true);
      obj_sum.to_clob(json_str_output);

  END gettab3;

  PROCEDURE getdetail (json_str_input IN CLOB, json_str_output OUT CLOB) IS
      json_obj json_object_t;
  BEGIN
      initial_value(json_str_input);
      gendetail(json_str_output);
  END getdetail;

  PROCEDURE gendetail (json_str_output OUT CLOB) IS
      v_min_qtyscor             tproasgh.qtyscor%type;
      v_codform                 tproasgh.codform%type;
      v_numtime                 number;
      v_numtimeeva              number;
      v_numseq                  NUMBER;
      v_display_codeval         tappbath.codeval%TYPE;

      v_qcodform                tintvews.codform%TYPE;
      v_qnumgrup                tintvews.numgrup%TYPE;
      v_qdesgrupt               tintvews.desgrupt%TYPE;
      v_qqtyfscor               tintvews.qtyfscor%TYPE;

      v_numanswer               NUMBER := 0;
      v_numquestion             NUMBER := 0;
      v_flg_ans                 boolean;
      v_grdscor                 tappbati.grdscor%type;
      v_qtyscor                 tappbati.qtyscor%type;
      v_rcnt                    NUMBER := 0;
      obj_data                  json_object_t;
      obj_question_row          json_object_t;
      obj_question              json_object_t;
      obj_row2                  json_object_t;
      obj_row3                  json_object_t;
      obj_row4                  json_object_t;
      obj_row5                  json_object_t;

      obj_summary               json_object_t;
      obj_data_tappbath         json_object_t;
      obj_flgCollapse           json_object_t;
      obj_pinCollapse           json_object_t;
      obj_data_modal            json_object_t;

      obj_detail                json_object_t;
      obj_ttprobatd             json_object_t;
      obj_row_ttprobatd         json_object_t;
      v_qtyavgwk                NUMBER;
      o_day                     NUMBER;
      o_hr                      NUMBER;
      o_min                     NUMBER;
      o_dhm                     VARCHAR(15 CHAR);
      v_aday                    NUMBER;

      count_ttprobat            NUMBER;

      val_flgappr               tproasgn.flgappr%TYPE;
      val_codcompap             tproasgn.codcompap%TYPE;
      val_codposap              tproasgn.codposap%TYPE;
      val_codempap              tproasgn.codempap%TYPE;
      val_qtymax                NUMBER;
      tproasgn_numseq           NUMBER;
      max_numseq                NUMBER;
      max_numseq_complete       NUMBER;
      max_numseq_of_max_numtime NUMBER;
      max_numtime               NUMBER;
      v_counttappbath           NUMBER := 0;
      v_counttproasgh           NUMBER := 0;

      pm_qtyscor                tappbath.qtyscor%TYPE;
      pm_codempid               tappbath.codempid%TYPE;
      pm_dteduepr               tappbath.dteduepr%TYPE;
      pm_numtime                tappbath.numtime%TYPE;
      pm_numseq                 tappbath.numseq%TYPE;
      pm_codeval                tappbath.codeval%TYPE;
      pm_dteeval                tappbath.dteeval%TYPE;
      pm_codform                tappbath.codform%TYPE;
      pm_commboss               tappbath.commboss%TYPE;
      pm_flgappr                tappbath.flgappr%TYPE;
      pm_codcomp                tappbath.codcomp%TYPE;
      pm_codrespr               tappbath.codrespr%TYPE;
      pm_qtyexpand              tappbath.qtyexpand%TYPE;
      pm_codexemp               tappbath.codexemp%TYPE;
      pm_desnote                tappbath.desnote%TYPE;

      max_numtime_37x           NUMBER;
      max_numseq_37x            NUMBER;
      v_btnDisable              boolean;
      v_codappr2                ttprobat.codappr%type;
      v_lcodrespr               tappbath.codrespr%TYPE;
      v_lflgappr                tappbath.flgappr%TYPE;

      m_codcomp                 temploy1.codcomp%TYPE;
      m_codpos                  temploy1.codcomp%TYPE;
      m_codjob                  temploy1.codcomp%TYPE;
      m_codempmt                temploy1.codcomp%TYPE;
      m_typemp                  temploy1.codcomp%TYPE;
      m_dteempmt                temploy1.codcomp%TYPE;
      m_date2                   DATE;
      m_dteduepr                temploy1.dteduepr%TYPE;

      v_flgrepos                tappbath.flgrepos%TYPE;
      v_staeval                 tappbath.staeval%TYPE;

      v_count_numseq            number;
      v_last_dteeval            date;
      v_qtyday                  tproasgh.qtyday%type;
      v_typscore                tproasgh.typscore%type;
      v_beforescore             tappbath.qtyscor%type;
      v_sendmail_disable        boolean;
      v_count_ttprobat          number;
      v_max_complete            number;
      v_codempcondition         varchar2(4000);
      v_codeval_disable         boolean;
      v_flgdisable              boolean := true;
      v_max_numtime_canselect   number;

      v_dteeval                 tappbath.dteeval%type;

      v_dtestrt                 date;
      v_dteend                  date;

      tmp_codrespr              tappbath.codrespr%type;
      tmp_staeval               tappbath.staeval%type;
      tmp_staupd                ttprobat.staupd%type;
      v_flgsecure   boolean;
      v_zupdsal     varchar2(1000);

      CURSOR c_tproasgh IS
          SELECT qtyday, qtymax, qtyscor, codform, typscore
            FROM tproasgh
           WHERE p_codcomp LIKE codcomp || '%'
             AND p_codpos LIKE codpos
             AND p_codempid_query LIKE codempid
             AND p_typproba = typproba
        ORDER BY codempid DESC, codcomp DESC;

      CURSOR c_tleavetr IS
          SELECT SUM(qtyday) qtyday, typleave
            FROM tleavetr
           WHERE codempid = p_codempid_query
             AND ( (detail_flag = '2' AND dtework between tab3_dtestrt  AND tab3_dteend )
                   OR detail_flag != '2' )
        GROUP BY typleave
        ORDER BY typleave;

     CURSOR c_tlateabs IS
        SELECT 1 numseq,get_label_name('HRPM31E', global_v_lang, 10) typcolumn,
               SUM(daylate) qtyday,
               SUM(qtytlate) qty_sum
          FROM tlateabs
         WHERE codempid = p_codempid_query
           AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework)
         UNION
        SELECT 2 numseq,get_label_name('HRPM31E', global_v_lang, 20) typcolumn,
               SUM(dayearly) qtyday,
               SUM(qtytearly) qty_sum
          FROM tlateabs
         WHERE codempid = p_codempid_query
           AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework)
         UNION
        SELECT 3 numseq,get_label_name('HRPM31E', global_v_lang, 30) typcolumn,
               SUM(dayabsent) qtyday,
               SUM(qtytabs) qty_sum
          FROM tlateabs
         WHERE codempid = p_codempid_query
           AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework);

      CURSOR c_ttmistk IS
          SELECT a.dteeffec, a.codmist, a.desmist1,
                 b.numseq, b.codpunsh, b.typpun,
                 b.dtestart, b.dteend, b.codempid
            FROM ttmistk a, ttpunsh b
           WHERE a.codempid = p_codempid_query
             AND a.codempid = b.codempid
             AND a.dteeffec = b.dteeffec
             AND a.staupd IN ( 'C', 'U' )
             AND a.dteeffec BETWEEN nvl(tab3_dtestrt,a.dteeffec) AND nvl(tab3_dteend,a.dteeffec)
        ORDER BY a.dteeffec, b.codpunsh, b.numseq;

      CURSOR c_questiongroup IS
        SELECT codform, numgrup, qtyfscor,
               decode(global_v_lang,
                     101,desgrupe,
                     102,desgrupt,
                     103,desgrup3,
                     104,desgrup4,
                     105,desgrup5) desgrup
          FROM tintvews
         WHERE codform = v_codform
      order by numgrup;

      CURSOR c_question IS
        SELECT qtyfscor, numitem, qtywgt,
               decode(global_v_lang,
                         101,desiteme,
                         102,desitemt,
                         103,desitem3,
                         104,desitem4,
                         105,desitem5) desitem,
               decode(global_v_lang,
                         101,definite,
                         102,definitt,
                         103,definit3,
                         104,definit4,
                         105,definit5) definit
          FROM tintvewd
         WHERE codform = v_qcodform
           AND numgrup = v_qnumgrup
      ORDER BY numgrup,numitem;

      cursor c_ttprobatd is
        select *
          from ttprobatd
         where codempid = p_codempid_query
           and dteduepr = p_dteend
      order by numtime;

  BEGIN

      -- 1.find codform and minscore
      FOR i IN c_tproasgh LOOP
          v_min_qtyscor     := i.qtyscor;
          v_codform         := i.codform;
          val_qtymax        := i.qtymax;
          v_qtyday          := i.qtyday;
          v_typscore        := i.typscore;
          EXIT;
      END LOOP;

      -- 2.find max numtime
      BEGIN
          SELECT nvl(MAX(numtime),1)
            INTO max_numtime
            FROM tappbath
           WHERE codempid = p_codempid_query
             AND dteduepr = p_dteend;
      EXCEPTION WHEN no_data_found THEN
        max_numtime := 1;
      END;

      BEGIN
          SELECT nvl(MAX(numseq),1)
            INTO max_numseq_of_max_numtime
            FROM tappbath
           WHERE codempid = p_codempid_query
             AND dteduepr = p_dteend
             AND numtime = max_numtime
             AND flgappr is not null;
      EXCEPTION WHEN no_data_found THEN
        max_numseq_of_max_numtime := 1;
      END;

      BEGIN
          SELECT MAX(numtime)
            INTO v_numtime
            FROM tappbath
           WHERE codempid = p_codempid_query
             AND dteduepr = p_dteend
             AND flgappr = 'C';
      EXCEPTION WHEN no_data_found THEN
        v_numtime := null;
      END;

      if v_numtime is null then
          v_numtime := max_numtime;
      end if;

      BEGIN
          SELECT MAX(numseq)
            INTO v_numseq
            FROM tappbath
           WHERE codempid = p_codempid_query
             AND dteduepr = p_dteend
             AND numtime = v_numtime;
      EXCEPTION WHEN no_data_found THEN
        v_numseq := null;
      END;

      max_numseq := v_numseq;
      obj_detail := json_object_t();
      SELECT nvl(MAX(numseq), 0)
        INTO max_numseq_complete
        FROM tappbath
       WHERE codempid = detail_codempid
         AND dteduepr = p_dteend
         AND numtime = v_numtime
         AND flgappr = 'C';
      v_max_complete := max_numseq_complete;

      SELECT MAX(numseq)
        INTO tproasgn_numseq
        FROM tproasgn
       WHERE p_codcomp LIKE codcomp || '%'
             AND p_codpos LIKE codpos
             AND codempid = ( SELECT MAX( CASE
                                          WHEN p_codempid_query = codempid THEN codempid
                                          ELSE '%' END )
                                FROM tproasgh
                               WHERE p_codcomp LIKE codcomp || '%'
                                 AND p_codpos LIKE codpos
                                 AND typproba = p_typproba)
             AND typproba = p_typproba;

      v_max_numtime_canselect := max_numtime;
      if max_numseq_complete < tproasgn_numseq then
        v_numseq := max_numseq_complete + 1;
      elsif max_numseq_complete = tproasgn_numseq then
          BEGIN
              SELECT codrespr, staeval
                into pm_codrespr, v_staeval
                FROM tappbath
               WHERE codempid = p_codempid_query
                 AND dteduepr = p_dteend
                 AND numseq = max_numseq_complete
                 AND numtime = v_numtime;
          EXCEPTION WHEN no_data_found THEN
            pm_codrespr := null;
          END;

          IF /*pm_codrespr ='P' and*/ v_staeval = 'Y' and val_qtymax > v_numtime THEN
            v_numtime   := v_numtime + 1;
            v_max_numtime_canselect := v_numtime;
            v_numseq    := 1;
            max_numseq  := 0;
            max_numseq_complete := 0;
          END IF;
      end if;
      pm_codrespr := null;

      if detail_numseq is not null then
        v_numtime   := detail_numtime;
        v_numseq    := detail_numseq;
      end if;


      IF v_numseq IS NOT NULL THEN
          BEGIN
              SELECT codeval, dteeval
                INTO v_display_codeval, v_dteeval
                FROM tappbath
               WHERE codempid = p_codempid_query
                 AND dteduepr = p_dteend
                 AND numseq = v_numseq
                 AND numtime = v_numtime;
          EXCEPTION WHEN OTHERS THEN
            v_display_codeval := null;
            p_flgsubmit_disable := false;
          END;
--          if v_dteeval is null and p_flgsubmit_disable = true then
--              param_msg_error := '01'||get_error_msg_php('PM0099', global_v_lang);
--              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
--              return;
--          end if;
          if v_display_codeval is null then
            if detail_flag != '2' then
                p_flgsubmit_disable := false;
                display_codeval := null;
            else
                p_flgsubmit_disable := true;
            end if;
            v_display_codeval := gen_codeval(p_codempid_query, p_dteend, v_numtime, v_numseq, display_codeval, p_typproba);
            if v_display_codeval is not null then
                v_flgsecure := secur_main.secur2(v_display_codeval,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if not v_flgsecure then
                  param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                  json_str_output := get_response_message('403', param_msg_error, global_v_lang);
                  return;
                end if;
            end if;
            if detail_flag in ('2') and nvl(v_display_codeval,'xxx') != display_codeval then
              param_msg_error := '02'||get_error_msg_php('PM0099', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
            elsif display_codeval is null and v_display_codeval is null then
              param_msg_error := get_error_msg_php('PM0108', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
            end if;

            if detail_flag = '2' then
                v_codeval_disable := true;
            end if;
          else
              v_codeval_disable := true;
              p_codempcondition := 'emp1.codempid = '''||v_display_codeval||'''';
          end if;
      ELSE
          v_numseq  := 1;
          v_display_codeval := gen_codeval(p_codempid_query, p_dteend, v_numtime, v_numseq, display_codeval,p_typproba);
          if display_codeval is null and v_display_codeval is null then
              param_msg_error := get_error_msg_php('PM0108', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
          end if;
          if v_display_codeval is not null then
            v_flgsecure := secur_main.secur2(v_display_codeval,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if not v_flgsecure then
              param_msg_error := get_error_msg_php('HR3007', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
            end if;
          end if;
      END IF;

      BEGIN
          SELECT codcompap, codposap, codempap, flgappr
            INTO val_codcompap, val_codposap, val_codempap, val_flgappr
            FROM tproasgn
           WHERE p_codcomp LIKE codcomp || '%'
             AND p_codpos LIKE codpos
             AND codempid = ( SELECT MAX( CASE WHEN p_codempid_query = codempid
                                          THEN codempid
                                          ELSE '%' END )
                                FROM tproasgn
                               WHERE p_codcomp LIKE codcomp || '%'
                                 AND p_codpos LIKE codpos
                                 AND typproba = p_typproba
                                 AND numseq = v_numseq)
             AND typproba = p_typproba
             AND numseq = v_numseq
        order by codcomp desc
        fetch first 1 rows only;
      EXCEPTION WHEN no_data_found THEN
          val_codcompap     := NULL;
          val_codposap      := NULL;
          val_codempap      := NULL;
          val_flgappr       := NULL;
      END;

      begin
        select (dteduepr - DTEEMPMT) +1
          into v_aday
          from TEMPLOY1
         where CODEMPID = p_codempid_query;
      exception when no_data_found then
        v_aday := null;
      end;

      begin
      select count(codempid)
        into v_count_ttprobat
        from ttprobat
       where codempid = p_codempid_query
         and dteduepr = p_dteend;
      exception when others then
        v_count_ttprobat := 0;
      end;


      obj_data_tappbath := json_object_t();
      obj_detail.put('codempcondition', nvl(p_codempcondition,''));
      obj_detail.put('flgsubmit_disable', p_flgsubmit_disable);
      obj_detail.put('flgcodeval_disable', v_codeval_disable);

      BEGIN
          SELECT qtyscor, codempid, dteduepr, numtime, numseq,
                 codeval, dteeval, codform, commboss, flgappr,
                 codcomp, codrespr,  qtyexpand, codexemp,flgrepos, staeval,
                 desnote
            INTO pm_qtyscor, pm_codempid, pm_dteduepr, pm_numtime, pm_numseq,
                 pm_codeval, pm_dteeval, pm_codform, pm_commboss, pm_flgappr,
                 pm_codcomp, pm_codrespr,  pm_qtyexpand, pm_codexemp,v_flgrepos, v_staeval,
                 pm_desnote
            FROM tappbath
           WHERE codempid = p_codempid_query
             and dteduepr = p_dteend
             AND numseq = v_numseq
             AND numtime = v_numtime;
      EXCEPTION WHEN no_data_found THEN
          pm_numtime    := v_numtime;
          pm_numseq     := v_numseq;
          obj_data_tappbath.put('codeval', v_display_codeval);
          obj_detail.put('FlgEdit', '0');
          obj_detail.put('flg_disable', false);
          obj_detail.put('set_flag_insert', true);
          pm_flgappr := 'P';
      END;

      if detail_flag = '2' or detail_flag = '3' then
          if v_numseq > 1 then
              begin
                select flgappr
                  into v_lflgappr
                  FROM tappbath
                 WHERE codempid = p_codempid_query
                   AND dteduepr = p_dteend
                   AND numseq = v_numseq - 1
                   AND numtime = v_numtime;
              EXCEPTION WHEN no_data_found THEN
                v_lflgappr := null;
              end;
          elsif v_numtime > 1 then
              begin
                select flgappr
                  into v_lflgappr
                  FROM tappbath
                 WHERE codempid = p_codempid_query
                   and dteduepr = p_dteend
                   AND numseq = tproasgn_numseq
                   AND numtime = v_numtime - 1 ;
              EXCEPTION WHEN no_data_found THEN
                v_lflgappr := null;
              end;
          else
              v_lflgappr := 'C';
          end if;

          if v_lflgappr is null then
--              param_msg_error := get_error_msg_php('PM0101', global_v_lang);
              param_msg_error := get_error_msg_php('PM0099', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
          elsif v_lflgappr = 'P' then
              param_msg_error := '03'||get_error_msg_php('PM0099', global_v_lang);
              json_str_output := get_response_message('403', param_msg_error, global_v_lang);
              return;
          end if;
      end if;
      IF ( pm_codempid IS NOT NULL ) THEN
          obj_detail.put('set_flag_insert', false);
          obj_detail.put('FlgEdit', '1');
          v_flgdisable := true;  -- disable input
      else
          obj_detail.put('FlgEdit', '0');
          obj_detail.put('set_flag_insert', true);
          v_flgdisable := false;  -- enable input
      END IF;

      if detail_flag = '1' then
          obj_detail.put('detail_flag_1', true);
          if v_codappr2 is not null then
              v_flgdisable := true;  -- disable input
          else
              v_flgdisable := false;  -- enable input
          end if;
      elsif detail_flag = '2' then
        obj_detail.put('detail_flag_1', false);

        if max_numseq_of_max_numtime = v_numseq then
            v_flgdisable := false;  -- enable input
        elsif v_numseq = 1 and v_numtime = (max_numtime + 1) then
            v_flgdisable := false;  -- enable input
        elsif v_numseq = max_numseq_of_max_numtime + 1 and max_numtime = v_numtime then
            v_flgdisable := false;  -- enable input
        else
            v_flgdisable := true;  -- disable input

            obj_detail.put('max_numseq_of_max_numtime', max_numseq_of_max_numtime);
            obj_detail.put('v_numseq', v_numseq);
            obj_detail.put('max_numtime', max_numtime);
            obj_detail.put('v_numtime', v_numtime);
        end if;
      elsif detail_flag = '3' then
        obj_detail.put('detail_flag_1', false);
        if (max_numseq_of_max_numtime = v_numseq and max_numtime = v_numtime) then
            v_flgdisable := false;  -- enable input
        elsif v_numseq = 1 and v_numtime = (max_numtime + 1) then
            v_flgdisable := false;  -- enable input
        elsif (v_numseq > max_numseq_of_max_numtime and max_numtime = v_numtime) then
            v_flgdisable := false;  -- enable input
        elsif v_numtime > max_numtime and v_numseq > max_numseq_of_max_numtime then
            v_flgdisable := false;  -- enable input
        else
            v_flgdisable := true;  -- disable input
        end if;
      else
          obj_detail.put('detail_flag_1', false);
          v_flgdisable := true;  -- disable input
      end if;

      if v_count_ttprobat > 0 then
        begin
            select staupd
              into tmp_staupd
              from ttprobat
             where codempid = p_codempid_query
               and dteduepr = p_dteend;
        exception when others then
            tmp_staupd := null;
        end;

        begin
            select codrespr, staeval
              into tmp_codrespr, tmp_staeval
              from tappbath
             where codempid = p_codempid_query
               and dteduepr = p_dteend
               and numtime  = max_numtime
               and numseq = max_numseq_of_max_numtime;
        exception when others then
            tmp_codrespr    := null;
            tmp_staeval     := null;
        end;

        if tmp_codrespr = 'N' and tmp_staeval = 'N' and tmp_staupd = 'P' then
            v_flgdisable := false;  -- enable input
        else
            v_flgdisable := true;  -- disable input
        end if;
      end if;
      obj_detail.put('flg_disable', v_flgdisable);

      if (detail_flag = '1') then
        if (pm_codempid IS NOT NULL) then
            v_btnDisable := true;
        end if;
      elsif (detail_flag = '2') then
        if (pm_codempid IS NOT NULL or detail_flag_tab3) then
            v_btnDisable := true;
        end if;
      elsif (detail_flag = '3') then
        if ( pm_flgappr = 'C' ) THEN
            v_btnDisable := true;
        else
            v_btnDisable := false;
        end if;
      end if;

      obj_data_modal := json_object_t();
      IF ( p_typproba = 1 ) THEN
          BEGIN
              SELECT codcomp, codpos, codjob, codempmt,
                     typemp, dtereemp, dteduepr, dteempmt,
                     dteduepr
                INTO m_codcomp, m_codpos, m_codjob, m_codempmt,
                     m_typemp, m_date2, m_dteduepr,v_dtestrt,
                     v_dteend
                FROM temploy1
               WHERE codempid = p_codempid_query;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
              m_date2       := NULL;
              v_dtestrt     := NULL;
              v_dteend      := NULL;
          END;
      ELSE
          BEGIN
              SELECT codcomp, codpos, codjob,
                     codempmt, typemp, dteeffec,
                     dteeffec, dteduepr,
                     (dteduepr - dteeffec) + 1
                INTO m_codcomp, m_codpos, m_codjob,
                     m_codempmt, m_typemp, m_dteduepr,
                     v_dtestrt, v_dteend,
                     v_aday
                FROM ttmovemt
               WHERE codempid = p_codempid_query
                 AND dteeffec = p_modal_dteeffec
                 AND numseq = p_modal_numseq;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
              v_dtestrt     := NULL;
              v_dteend      := NULL;
          END;
      END IF;

      obj_data_modal.put('desc_codcomp', get_tcenter_name(m_codcomp, global_v_lang));
      obj_data_modal.put('desc_codpos', get_tpostn_name(m_codpos, global_v_lang));
      obj_data_modal.put('desc_codjob', get_tjobcode_name(m_codjob, global_v_lang));
      obj_data_modal.put('desc_codempmt', get_tcodec_name('TCODEMPL', m_codempmt, global_v_lang));
      obj_data_modal.put('desc_typemp', get_tcodec_name('TCODCATG', m_typemp, global_v_lang));
      obj_data_modal.put('dtereemp', TO_CHAR(m_date2, 'dd/mm/yyyy'));
      obj_data_modal.put('dteduepr', TO_CHAR(pm_dteduepr, 'dd/mm/yyyy'));
      obj_data_modal.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
      obj_data_modal.put('dteempmt', to_char(p_dtestr,'dd/mm/yyyy'));
      obj_data_modal.put('day_probation', v_aday);

      obj_detail.put('codeval_hide', nvl(v_display_codeval,''));
      obj_detail.put('numseq', v_numseq);
      obj_detail.put('numseq_hidden', tproasgn_numseq);
      obj_detail.put('numtime', v_numtime);
      obj_detail.put('numtime_hidden', v_numtime);

      if ( val_flgappr = '3' ) then
        obj_detail.put('val_codcompap_flg', true);
        obj_detail.put('val_codcompap', val_codcompap);
        obj_detail.put('val_codposap', val_codposap);
      elsif ( val_flgappr = '4' ) then
        obj_detail.put('val_codempap_flg', true);
      elsif ( val_flgappr = '5' ) then
        obj_detail.put('val_codempap_flg', true);
      end if;
      begin
      select nvl(sum(nvl(qtyscor,0)),0)
        into v_beforescore
        from tappbath
       where codempid = p_codempid_query
         and dteduepr = p_dteend
         and numtime = v_numtime
         and numseq <> tproasgn_numseq;
      exception when others then
        v_beforescore := 0;
      end;
      obj_detail.put('tproasgh_qtymax', val_qtymax);
      obj_detail.put('tproasgh_qtyscor', v_min_qtyscor);
      obj_detail.put('tproasgn_numseq', tproasgn_numseq);
      obj_detail.put('tproasgh_qtyday', v_qtyday);
      obj_detail.put('tproasgh_typscore', v_typscore);
      obj_detail.put('before_score', v_beforescore);


      if (v_count_ttprobat > 0 and v_numseq = tproasgn_numseq) or (v_numseq < tproasgn_numseq and v_numseq = max_numseq_complete) then
        v_sendmail_disable := false;
      else
        v_sendmail_disable := true;
      end if;

      if v_count_ttprobat > 0 then
        if tmp_codrespr = 'N' and tmp_staeval = 'N' and tmp_staupd = 'P' then
            obj_detail.put('flgdelete_disable', false);
        else
            obj_detail.put('flgdelete_disable', true);
        end if;
      else
        obj_detail.put('flgdelete_disable', false);
      end if;
      obj_detail.put('numtime_max', v_max_numtime_canselect);
      obj_detail.put('flgsendmail_disable', v_sendmail_disable);
      -- get leave detail
      obj_row2  := json_object_t();
      v_rcnt    := 0;

      if ( tab3_dtestrt is null ) THEN
        tab3_dtestrt    := p_dtestr;
        tab3_dteend     := p_dteend;
      end if;

      FOR r_tleavetr IN c_tleavetr LOOP
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          v_qtyavgwk    := func_get_qtyavgwk (p_codcomp);
          hcm_util.cal_dhm_hm(r_tleavetr.qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          obj_data.put('typleave', r_tleavetr.typleave);
          obj_data.put('desc_typleave', get_tleavety_name(r_tleavetr.typleave, global_v_lang));
          obj_data.put('numleave', o_dhm);
          obj_data.put('coderror', '200');
          obj_row2.put(TO_CHAR(v_rcnt), obj_data);
      END LOOP;

      -- detail tlateabs
      obj_row3 := json_object_t();
      v_rcnt := 0;

      FOR r_tlateabs IN c_tlateabs LOOP
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          v_qtyavgwk    := func_get_qtyavgwk (p_codcomp);
          hcm_util.cal_dhm_hm(r_tlateabs.qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          obj_data.put('totalcount', o_dhm);
          obj_data.put('typecolum', r_tlateabs.typcolumn);
          obj_data.put('quantity', nvl(r_tlateabs.qty_sum, 0));
          obj_data.put('coderror', '200');
          obj_row3.put(TO_CHAR(v_rcnt), obj_data);
      END LOOP;

      -- detail mistake and punnishment
      obj_row4  := json_object_t();
      v_rcnt    := 0;
      FOR r_ttmistk IN c_ttmistk LOOP
          IF (( detail_flag = '2' AND tab3_dtestrt <= r_ttmistk.dteeffec AND tab3_dteend >= r_ttmistk.dteeffec )
              OR detail_flag != '2') THEN
              obj_data := json_object_t();
              obj_data.put('dteeffec', to_char(r_ttmistk.dteeffec, 'dd/mm/yyyy'));
              obj_data.put('codmist', get_tcodec_name('TCODMIST', r_ttmistk.codmist, global_v_lang));
              obj_data.put('desmist1', r_ttmistk.desmist1);
              obj_data.put('numseq', r_ttmistk.numseq);
              obj_data.put('codpunsh', get_tcodec_name('TCODPUNH', r_ttmistk.codpunsh, global_v_lang));
              obj_data.put('typpun', get_tlistval_name('NAMTPUN', r_ttmistk.typpun, global_v_lang));
              obj_data.put('dtestart', TO_CHAR(r_ttmistk.dtestart, 'dd/mm/yyyy'));
              obj_data.put('dteend', TO_CHAR(r_ttmistk.dteend, 'dd/mm/yyyy'));
              v_rcnt := v_rcnt + 1;
              obj_data.put('coderror', '200');
              obj_row4.put(TO_CHAR(v_rcnt), obj_data);
          END IF;
      END LOOP;

      -- detail evaluation
      obj_row5  := json_object_t();
      v_rcnt    := 0;
      IF ( pm_dteeval IS NOT NULL OR v_numseq = 1 ) THEN
        null;
      ELSE
        pm_qtyscor := 0;
      END IF;
      FOR r_questiongroup in c_questiongroup LOOP
          v_qcodform     := r_questiongroup.codform;
          v_qnumgrup     := r_questiongroup.numgrup;
          v_qdesgrupt    := r_questiongroup.desgrup;
          v_qqtyfscor    := r_questiongroup.qtyfscor;

          obj_data := json_object_t();
          obj_data.put('codform', v_qcodform);
          obj_data.put('numgrup', v_qnumgrup);
          obj_data.put('desgrupt', v_qdesgrupt);
          obj_data.put('qtyfscor', v_qqtyfscor);
          obj_question_row := json_object_t();
          v_numquestion := 0;

          FOR r_question in c_question LOOP
              obj_question := json_object_t();
              v_flg_ans := func_get_choose_ans(p_codempid_query, p_dteend, v_qnumgrup, v_numtime, v_numseq, r_question.numitem, v_grdscor, v_qtyscor);
              -->> Pitsamai/Pongsapat req.2020/09/10
              IF ( pm_dteeval IS NOT NULL OR v_numseq = 1 ) THEN
                v_flg_ans := func_get_choose_ans(p_codempid_query,p_dteend, v_qnumgrup, v_numtime, v_numseq, r_question.numitem, v_grdscor, v_qtyscor);
              ELSE
                v_flg_ans := func_get_choose_ans(p_codempid_query,p_dteend, v_qnumgrup, v_numtime, v_numseq - 1 , r_question.numitem, v_grdscor, v_qtyscor);
                pm_qtyscor := pm_qtyscor + v_qtyscor;

                begin
                    select codrespr, codexemp,qtyscor
                      into pm_codrespr, pm_codexemp,pm_qtyscor
                      from tappbath
                     where codempid = p_codempid_query
                       and dteduepr = p_dteend
                       and numtime  = v_numtime
                       and numseq = v_numseq - 1;
                exception when others then
                    pm_codrespr := 'P';
                end;
              END IF;
              --<< Pitsamai/Pongsapat req.2020/09/10
              obj_question.put('pm_codempid', pm_codempid);
              obj_question.put('v_numtime', v_numtime);
              obj_question.put('v_numseq', v_numseq);
              obj_question.put('choose_ans', v_grdscor);
              obj_question.put('qtyfscor', r_question.qtyfscor);
              obj_question.put('qtywgt', r_question.qtywgt);
              obj_question.put('desitem', r_question.desitem);
              obj_question.put('definit', r_question.definit);
              obj_question.put('numitem', r_question.numitem);
              obj_question.put('index', v_numquestion + 1);
              obj_question_row.put(TO_CHAR(v_numquestion), obj_question);
              v_numquestion := v_numquestion + 1;
          END LOOP;

          v_rcnt := v_rcnt + 1;
          obj_data.put('question', obj_question_row);
          obj_row5.put(TO_CHAR(v_rcnt), obj_data);
      END LOOP;

      obj_flgCollapse := json_object_t();
      obj_pinCollapse := json_object_t();
      FOR i IN 1..obj_row5.get_size LOOP
        if i = 1 then
            obj_flgCollapse.put('group'||i, false);
        else
            obj_flgCollapse.put('group'||i, true);
        end if;
        obj_pinCollapse.put('group'||i, false);
      END LOOP;

      obj_detail.put('codempid',p_codempid_query);
      obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query, global_v_lang));
      obj_detail.put('codeval',nvl(nvl(pm_codeval,v_display_codeval),''));
      obj_detail.put('typproba',p_typproba);
      obj_detail.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
      obj_detail.put('dteempmt', to_char(nvl(p_dtestr,v_dtestrt),'dd/mm/yyyy'));
      obj_detail.put('dteduepr', to_char(p_dteend,'dd/mm/yyyy'));
      obj_detail.put('dteeval', to_char(nvl(pm_dteeval,trunc(sysdate)),'dd/mm/yyyy'));
      obj_detail.put('codrespr', nvl(pm_codrespr,'P'));
      IF (v_numseq = tproasgn_numseq) AND v_numtime >= val_qtymax THEN
        obj_detail.put('codrespr_list', 3);
      ELSIF v_numseq = tproasgn_numseq THEN
        obj_detail.put('codrespr_list', 1);
      ELSE
        obj_detail.put('codrespr_list', 2);
      END IF;
      obj_detail.put('qtyscor', nvl(pm_qtyscor||'',''));
      obj_detail.put('staeval', nvl(v_staeval,'Y'));
      obj_detail.put('flgrepos', nvl(v_flgrepos,'Y'));
      obj_detail.put('codexemp', nvl(pm_codexemp,''));
      obj_detail.put('qtyexpand', nvl(pm_qtyexpand||'',''));
      obj_detail.put('flgappr', nvl(pm_flgappr,'P'));
      obj_detail.put('flgcal', false);
      obj_detail.put('flgdefault', false);
      obj_detail.put('flgfirstload', true);
      obj_detail.put('commboss', nvl(pm_commboss,''));
      obj_detail.put('codform', v_codform);
      obj_detail.put('desc_codform', v_codform || ' - ' || get_tintview_name(v_codform, global_v_lang));
      obj_detail.put('formtype', 1);
      obj_detail.put('codpos', p_codpos);
      obj_detail.put('codcomp', p_codcomp);
      if tab3_dtestrt is null then
          obj_detail.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
          obj_detail.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));
      else
          obj_detail.put('dtestrt', to_char(tab3_dtestrt,'dd/mm/yyyy'));
          obj_detail.put('dteend', to_char(tab3_dteend,'dd/mm/yyyy'));
      end if;
      v_rcnt := 0;
      obj_ttprobatd     := json_object_t();
      obj_row_ttprobatd := json_object_t();
      obj_data          := json_object_t();
      for r_ttprobatd in c_ttprobatd loop
        obj_data          := json_object_t();
        select count(*), max(dteeval)
          into v_count_numseq, v_last_dteeval
          from tappbath
         where codempid = p_codempid_query
           and dteduepr = p_dteend
           and numtime = r_ttprobatd.numtime;

        v_rcnt := v_rcnt + 1;
        obj_data.put('numtime', r_ttprobatd.numtime);
        obj_data.put('avgscor', r_ttprobatd.avgscor);
        obj_data.put('codrespr', r_ttprobatd.codrespr);
        obj_data.put('desc_codrespr', get_tlistval_name('CODRESPR', r_ttprobatd.codrespr, global_v_lang));
        obj_data.put('count_numseq', v_count_numseq);
        obj_data.put('last_dteeval', to_char(v_last_dteeval,'dd/mm/yyyy'));
        obj_row_ttprobatd.put(to_char(v_rcnt-1), obj_data); -- leave
      end loop;
      obj_ttprobatd.put('rows', obj_row_ttprobatd);
      obj_summary   := json_object_t();
      obj_summary.put('coderror', '200');
      obj_summary.put('t2', obj_row2); -- leave
      obj_summary.put('t3', obj_row3); -- absleave
      obj_summary.put('t4', obj_row4); -- mistake / punnishment
      obj_summary.put('tab_evalform', obj_row5); -- evaluation form
      obj_summary.put('flgcollapse', obj_flgCollapse);
      obj_summary.put('pincollapse', obj_pinCollapse);
      obj_summary.put('intscor', func_get_intscor (v_codform));
      obj_summary.put('detail_modal', obj_data_modal);
      obj_summary.put('detail', obj_detail);
      obj_summary.put('ttprobatd', obj_ttprobatd);

      dbms_lob.createtemporary(json_str_output, true);
      obj_summary.to_clob(json_str_output);
  END gendetail;

  PROCEDURE savedetail ( json_str_input IN CLOB, json_str_output OUT CLOB) IS
      ttprobat_staupd           ttprobat.staupd%TYPE;
      detail_typproba           ttprobat.typproba%TYPE;
      json_obj                  json_object_t;
      pm_codempid               tappbath.codempid%TYPE;
      pm_dteduepr               tappbath.dteduepr%TYPE;
      pm_numtime                tappbath.numtime%TYPE;
      pm_numseq                 tappbath.numseq%TYPE;
      pm_codeval                tappbath.codeval%TYPE;
      pm_dteeval                tappbath.dteeval%TYPE;
      pm_codform                tappbath.codform%TYPE;
      pm_commboss               tappbath.commboss%TYPE;
      pm_flgappr                tappbath.flgappr%TYPE;
      pm_codcomp                tappbath.codcomp%TYPE;
      pm_codrespr               tappbath.codrespr%TYPE;
      pm_qtyexpand              tappbath.qtyexpand%TYPE;
      pm_codexemp               tappbath.codexemp%TYPE;
      pm_desnote                tappbath.desnote%TYPE;
      pm_flgsave                VARCHAR(1);
      v_num                     NUMBER;
      v_codcomp                 temploy1.codcomp%TYPE;
      v_codpos                  temploy1.codpos%TYPE;
      v_typproba                VARCHAR(1);
      v_tmp1_dteoccup           temploy1.dteoccup%TYPE;
      v_tmp1_numlvl             temploy1.numlvl%TYPE;
      ttmovemt_dteeffec         ttmovemt.dteeffec%TYPE;
      ttmovemt_numseq           ttmovemt.numseq%TYPE;
      ttmovemt_dteduepr         ttmovemt.dteduepr%TYPE;
      obj_sum                   json_object_t;
      obj_data_tappbath         json_object_t;
      obj_data_obj              VARCHAR(200);
      obj                       json_object_t;
      obj_row                   json_object_t;
      obj_row_question          json_object_t;
      v_choose_ans              tappbati.grdscor%type;
      pm_qtyscor                number;
      pm_evalform               json_object_t;
      v_codform                 tintvewd.codform%TYPE;
      v_numgrup                 tintvewd.numgrup%TYPE;
      v_numitem                 tintvewd.numitem%type;
      v_qtyfscor                tintvewd.qtyfscor%TYPE;
      v_qtywgt                  tintvewd.qtywgt%TYPE;
      v_grad                    tintscor.grad%TYPE;
      v_qtyscor                 tappbati.qtyscor%TYPE;
      ttprobat_codpos           ttprobat.codpos%TYPE;
      ttprobat_codempmt         ttprobat.codempmt%TYPE;
      v_jobgrade                temploy1.jobgrade%TYPE;
      v_codgrpgl                temploy1.codgrpgl%TYPE;
      v_numlvl                  temploy1.numlvl%TYPE;
      v_codbrlc                 temploy1.codbrlc%TYPE;
      v_typemp                  temploy1.typemp%TYPE;
      v_typpayroll              temploy1.typpayroll%TYPE;
      v_codcalen                temploy1.codcalen%TYPE;
      v_codcurr                 temploy3.codcurr%TYPE;
      p_sum_avascore            NUMBER;

      v_checkapp                boolean := false;
      v_approvno2               number;
      v_check                   varchar2(500 char);
      v_error                   varchar2(4000 char);
      pm_flgrepos               tappbath.flgrepos%TYPE;
      pm_staeval                tappbath.staeval%TYPE;
      pm_tproasgn_numseq        number;
      pm_tproasgh_typscore      VARCHAR2(1 CHAR);
      pm_tproasgh_qtyday        number;
      pm_tproasgh_qtymax        number;
      v_avgscor                 number;
      v_question                json_object_t;
      v_dtedueprn               date;
      v_dteempmt                temploy1.dteempmt%type;
      pm_typproba               varchar2(1);

      v_flgInsert_ttprobat      boolean := false;
      v_count_tappbath          number;

      v_dteexpand               ttprobat.dteexpand%type;
      v_count_answer            number;
      v_count_not_answer        number;
  BEGIN
      initial_value(json_str_input);
      json_obj              := json_object_t(json_str_input);
      detail_typproba       := hcm_util.get_string_t(json_obj, 'p_typproba');
      pm_codempid           := hcm_util.get_string_t(json_obj, 'p_codempid_query');
      pm_dteduepr           := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteduepr')), 'dd/mm/yyyy');

      pm_qtyscor            := to_number(hcm_util.get_string_t(json_obj, 'p_qtyscor'));
      pm_numtime            := hcm_util.get_string_t(json_obj, 'p_numtime');
      pm_numseq             := hcm_util.get_string_t(json_obj, 'p_numseq');
      pm_codeval            := hcm_util.get_string_t(json_obj, 'p_codeval');
      pm_dteeval            := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteeval')), 'dd/mm/yyyy');
      pm_codform            := hcm_util.get_string_t(json_obj, 'p_codform');
      pm_commboss           := hcm_util.get_string_t(json_obj, 'p_commboss');
      pm_flgappr            := hcm_util.get_string_t(json_obj, 'p_flgappr');
      pm_codcomp            := hcm_util.get_string_t(json_obj, 'p_codcomp');
      pm_codrespr           := hcm_util.get_string_t(json_obj, 'p_codrespr');
      pm_qtyexpand          := hcm_util.get_string_t(json_obj, 'p_qtyexpand');
      pm_codexemp           := hcm_util.get_string_t(json_obj, 'p_codexemp');
      pm_desnote            := hcm_util.get_string_t(json_obj, 'p_desnote');
      pm_flgsave            := hcm_util.get_string_t(json_obj, 'p_flgsave');
      pm_evalform           := hcm_util.get_json_t(json_obj, 'p_evalform');
      pm_flgrepos           := hcm_util.get_string_t(json_obj, 'p_flgrepos');
      pm_staeval            := hcm_util.get_string_t(json_obj, 'p_staeval');
      pm_tproasgn_numseq    := to_number(hcm_util.get_string_t(json_obj, 'p_tproasgn_numseq'));
      pm_tproasgh_qtyday    := to_number(hcm_util.get_string_t(json_obj, 'p_tproasgh_qtyday'));
      pm_tproasgh_qtymax    := to_number(hcm_util.get_string_t(json_obj, 'p_tproasgh_qtymax'));
      pm_tproasgh_typscore  := to_number(hcm_util.get_string_t(json_obj, 'p_tproasgh_typscore'));
      pm_typproba           := hcm_util.get_string_t(json_obj, 'p_typproba');
      if pm_numseq = 1 then
          select count(codempid)
            into v_count_tappbath
            from tappbath
           where numtime = pm_numtime
             and codempid = pm_codempid
             and dteduepr = pm_dteduepr;

--          if v_count_tappbath = 0 then
            hrpm31e.insert_tappbath (pm_codempid, pm_dteduepr, pm_numtime, pm_typproba);
--          end if;
      end if;

      BEGIN
          SELECT t1.jobgrade, t1.codgrpgl, t1.numlvl, t1.codbrlc,
                 t1.typemp, t1.typpayroll, t1.codcalen,t3.codcurr
            INTO v_jobgrade, v_codgrpgl, v_numlvl, v_codbrlc,
                 v_typemp, v_typpayroll, v_codcalen, v_codcurr
            FROM temploy1 t1, temploy3 t3
           WHERE t1.codempid = t3.codempid
             AND t1.codempid = pm_codempid;
      EXCEPTION WHEN no_data_found THEN
          v_jobgrade    := NULL;
          v_codgrpgl    := NULL;
          v_numlvl      := NULL;
          v_codbrlc     := NULL;
          v_typemp      := NULL;
          v_typpayroll  := NULL;
          v_codcalen    := NULL;
          v_codcurr     := NULL;
      END;

      BEGIN
          SELECT codpos, codempmt, dteempmt
            into ttprobat_codpos, ttprobat_codempmt, v_dteempmt
            FROM temploy1
           WHERE codempid = pm_codempid;
      EXCEPTION WHEN no_data_found THEN
          ttprobat_codpos   := NULL;
          ttprobat_codempmt := NULL;
      END;
      BEGIN
          SELECT MAX(dteeffec)
            INTO ttmovemt_dteeffec
            FROM ttmovemt   a,
                 tcodmove   b
           WHERE codempid = detail_codempid
             AND dteduepr IS NOT NULL
             AND staupd = 'U'
             AND b.codcodec = a.codtrn
             AND b.typmove = 'M';
      EXCEPTION WHEN no_data_found THEN
        ttmovemt_dteeffec := NULL;
      END;

      BEGIN
          SELECT MAX(numseq)
            INTO ttmovemt_numseq
            FROM ttmovemt   a,
                 tcodmove   b
           WHERE codempid = detail_codempid
             AND dteeffec = ttmovemt_dteeffec
             AND dteduepr IS NOT NULL
             AND staupd = 'U'
             AND b.codcodec = a.codtrn
             AND b.typmove = 'M';
      EXCEPTION WHEN no_data_found THEN
        ttmovemt_numseq := NULL;
      END;

      BEGIN
          SELECT dteeffec, numseq, dteduepr
            INTO ttmovemt_dteeffec, ttmovemt_numseq, ttmovemt_dteduepr
            FROM ttmovemt a,
                 tcodmove b
           WHERE codempid = detail_codempid
             AND dteeffec = ttmovemt_dteeffec
             AND numseq = ttmovemt_numseq
             AND b.codcodec = a.codtrn
             AND b.typmove in ('M',8);
      EXCEPTION WHEN no_data_found THEN
          ttmovemt_dteeffec     := NULL;
          ttmovemt_numseq       := NULL;
          ttmovemt_dteduepr     := pm_dteduepr;
      END;
      v_count_answer        := 0;
      v_count_not_answer    := 0;
      FOR i IN 0..pm_evalform.get_size-1 LOOP
          obj_row       := json_object_t(pm_evalform.get(i));
          v_codform     := hcm_util.get_string_t(obj_row, 'codform');
          v_numgrup     := hcm_util.get_string_t(obj_row, 'numgrup');
          v_question    := hcm_util.get_json_t(obj_row, 'question');
          v_qtyfscor    := 0;

          FOR j IN 0..v_question.get_size-1 LOOP
            obj_row_question    := json_object_t(v_question.get(j));
            v_choose_ans        := hcm_util.get_string_t(obj_row_question, 'choose_ans');
            v_qtywgt            := hcm_util.get_string_t(obj_row_question, 'qtywgt');
            v_numitem           := hcm_util.get_string_t(obj_row_question, 'numitem');

            if v_choose_ans <> '0' or v_choose_ans is null then
                v_count_answer := v_count_answer + 1;
            else
                v_count_not_answer := v_count_not_answer + 1;
            end if;

            BEGIN
              SELECT qtyscor * v_qtywgt
                INTO v_qtyscor
                FROM tintscor
               WHERE codform = pm_codform
                 AND grad = v_choose_ans;
            EXCEPTION WHEN no_data_found THEN
                v_qtyscor := 0;
            END;

            BEGIN
                INSERT INTO tappbati ( codempid, dteduepr, numtime, numseq, numgrup,
                                     numitem, grdscor, qtyscor, dtecreate, codcreate, coduser)
                            VALUES ( pm_codempid, ttmovemt_dteduepr, pm_numtime, pm_numseq, v_numgrup,
                                     v_numitem, v_choose_ans, v_qtyscor, SYSDATE, global_v_coduser,global_v_coduser );
            EXCEPTION when dup_val_on_index then
                UPDATE tappbati
                   SET grdscor = v_choose_ans,
                       qtyscor = v_qtyscor,
                       dteupd = SYSDATE,
                       coduser = global_v_coduser
                  WHERE dteduepr = pm_dteduepr
                   AND numgrup = v_numgrup
                   AND numseq = pm_numseq
                   AND numtime = pm_numtime
                   AND numitem = v_numitem
                   AND codempid = pm_codempid;
            END;

            v_qtyfscor := v_qtyfscor + v_qtyscor;
          END LOOP;
          BEGIN
              DECLARE
                  json_str_input    CLOB;
                  json_str_output   CLOB;
              BEGIN
                  json_str_input    := NULL;
                  json_str_output   := NULL;
                  hrpm31e.get_index(json_str_input => json_str_input, json_str_output => json_str_output);
              END;
          END;

          BEGIN
              INSERT INTO tappbatg ( codempid, dteduepr, numtime, numseq, numgrup,
                                     qtyscor, dtecreate, codcreate, coduser )
                            VALUES ( pm_codempid, ttmovemt_dteduepr, pm_numtime, pm_numseq, v_numgrup,
                                     v_qtyfscor, SYSDATE, global_v_coduser, global_v_coduser );
          EXCEPTION when dup_val_on_index then
              UPDATE tappbatg
                 SET numgrup = v_numgrup,
                     qtyscor = v_qtyfscor,
                     dteupd = SYSDATE,
                     coduser = global_v_coduser
               WHERE dteduepr = pm_dteduepr
                 AND numgrup = v_numgrup
                 AND numseq = pm_numseq
                 AND numtime = pm_numtime
                 AND codempid = pm_codempid;
          END;
      END LOOP;

      if (v_count_answer > 0 and v_count_not_answer > 0) or (upper(global_v_codapp) = 'HRMS31E' and v_count_not_answer > 0) then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang,get_label_name('HRPM31E2',global_v_lang,140));
        json_str_output := get_response_message('403', param_msg_error, global_v_lang);
        rollback;
        return;
      end if;

      UPDATE tappbath
         SET qtyscor = pm_qtyscor,
             codempid = pm_codempid,
             dteduepr = pm_dteduepr,
             numtime = pm_numtime,
             numseq = pm_numseq,
             codeval = pm_codeval,
             dteeval = pm_dteeval,
             codform = pm_codform,
             commboss = pm_commboss,
             flgappr = pm_flgappr,
             codcomp = pm_codcomp,
             codrespr = pm_codrespr,
             qtyexpand = pm_qtyexpand,
             codexemp = pm_codexemp,
             desnote = pm_desnote,
             flgrepos = pm_flgrepos,
             staeval = pm_staeval
       WHERE numtime = pm_numtime
         AND numseq = pm_numseq
         AND dteduepr = pm_dteduepr
         AND codempid = pm_codempid;

      ttprobat_staupd := 'P';
      if pm_numseq = pm_tproasgn_numseq then
        if pm_tproasgh_typscore = '1' then
          select avg(qtyscor)
            into v_avgscor
            from tappbath
           where codempid = pm_codempid
             and dteduepr = pm_dteduepr
             and numtime = pm_numtime;
        else
          v_avgscor := pm_qtyscor;
        end if;

        if pm_flgappr = 'C' then
            if (pm_codrespr = 'N' and pm_staeval = 'N') or
               (pm_codrespr = 'P' and (pm_numtime = pm_tproasgh_qtymax
                                      or (pm_numtime <> pm_tproasgh_qtymax and pm_staeval = 'N'))) or
                pm_codrespr = 'E' then

                v_dtedueprn := null;
                -- insert ttprobat
                v_flgInsert_ttprobat := true;
            else
                if pm_typproba = '1' then
                    v_dtedueprn := v_dteempmt + (pm_tproasgh_qtyday * (pm_numtime + 1)) - 1;
                else
                    v_dtedueprn := ttmovemt_dteeffec + (pm_tproasgh_qtyday * (pm_numtime + 1)) - 1;
                end if;
                -- not insert ttprobat
                v_flgInsert_ttprobat := false;
            end if;

            if pm_codrespr = 'E' then
                v_dteexpand := pm_dteduepr + pm_qtyexpand;
            else
                v_dteexpand := null;
            end if;

            begin
                insert into ttprobatd (numtime,dteduepr,codempid,coduser,qtyexpand,
                                       dtedueprn,dtecreate,codcreate,codrespr,
                                       avgscor,codform,codexemp)
                     values ( pm_numtime, pm_dteduepr, pm_codempid,global_v_coduser, pm_qtyexpand,
                              v_dtedueprn , sysdate, global_v_coduser, pm_codrespr,
                              v_avgscor, pm_codform, pm_codexemp ) ;
            exception when dup_val_on_index then
                update ttprobatd
                   set qtyexpand = pm_qtyexpand,
                       dtedueprn = v_dtedueprn,
                       codrespr = pm_codrespr,
                       avgscor = v_avgscor,
                       codform = pm_codform,
                       codexemp = pm_codexemp,
                       coduser = global_v_coduser,
                       dteupd = sysdate
                 where numtime = pm_numtime
                   and dteduepr = pm_dteduepr
                   and codempid = pm_codempid;
            end;
        end if;

        if v_flgInsert_ttprobat then
          BEGIN
              SELECT dteoccup, numlvl
                INTO v_tmp1_dteoccup, v_tmp1_numlvl
                FROM temploy1
               WHERE codempid = pm_codempid;
          EXCEPTION WHEN no_data_found THEN
              v_tmp1_dteoccup   := NULL;
              v_tmp1_numlvl     := NULL;
          END;

          if pm_typproba = 2 then
            begin
              INSERT INTO ttprobat ( codempmt, codpos, dteeffec, dteoccup,
                                     dteduepr, numseq, staupd, typproba, codempid,
                                     codeval, dteeval, codform,
                                     codcomp, codrespr, qtyexpand, dteexpand, codexemp,
                                     desnote, codcreate, jobgrade, codgrpgl, numlvl,
                                      codbrlc, typemp, typpayroll, codcalen, codcurr, avascore)
                            VALUES ( ttprobat_codempmt, ttprobat_codpos, ttmovemt_dteeffec, ttmovemt_dteduepr + 1,
                                     ttmovemt_dteduepr, ttmovemt_numseq, ttprobat_staupd, pm_typproba, pm_codempid,
                                     pm_codeval, pm_dteeval, pm_codform,
                                     pm_codcomp, pm_codrespr, pm_qtyexpand, v_dteexpand, pm_codexemp,
                                     pm_desnote, global_v_coduser, v_jobgrade, v_codgrpgl, v_numlvl,
                                     v_codbrlc, v_typemp, v_typpayroll, v_codcalen, v_codcurr,v_avgscor );
            exception when dup_val_on_index then
              UPDATE ttprobat
                 SET dteeffec = ttmovemt_dteeffec,
                     codempmt = ttprobat_codempmt,
                     codpos = ttprobat_codpos,
                     dteoccup = ttmovemt_dteduepr + 1,
                     dteduepr = ttmovemt_dteduepr,
                     staupd = ttprobat_staupd,
                     typproba = pm_typproba,
                     codempid = pm_codempid,
                     codeval = pm_codeval,
                     dteeval = pm_dteeval,
                     codform = pm_codform,
                     codcomp = pm_codcomp,
                     codrespr = pm_codrespr,
                     qtyexpand = pm_qtyexpand,
                     dteexpand = v_dteexpand,
                     codexemp = pm_codexemp,
                     desnote = pm_desnote,
                     coduser = global_v_coduser,
                     numseq = ttmovemt_numseq,
                     avascore = v_avgscor
               WHERE dteduepr = pm_dteduepr
                 AND codempid = pm_codempid;
            end;
          else
            begin
              INSERT INTO ttprobat ( codempmt, codpos, /*approvno,*/ dteoccup, dteduepr,
                                     staupd, typproba, codempid, codeval,
                                     dteeval, codform, codcomp, codrespr,
                                     qtyexpand, dteexpand, codexemp, desnote, codcreate,
                                     jobgrade, codgrpgl, numlvl, codbrlc, typemp,
                                     typpayroll, codcalen, codcurr, numseq, avascore)
                            VALUES ( ttprobat_codempmt, ttprobat_codpos, /*pm_numseq,*/ ttmovemt_dteduepr + 1, ttmovemt_dteduepr,
                                     ttprobat_staupd, pm_typproba, pm_codempid, pm_codeval,
                                     pm_dteeval, pm_codform, pm_codcomp, pm_codrespr,
                                     pm_qtyexpand, v_dteexpand, pm_codexemp, pm_desnote, global_v_coduser,
                                     v_jobgrade, v_codgrpgl, v_numlvl, v_codbrlc, v_typemp,
                                     v_typpayroll,v_codcalen, v_codcurr, pm_numseq, v_avgscor);
            exception when dup_val_on_index then
              UPDATE ttprobat
                 SET codempmt = ttprobat_codempmt,
                     codpos = ttprobat_codpos,
                     /*approvno = pm_numseq,*/
                     numseq = pm_numseq,
                     staupd = ttprobat_staupd,
                     typproba = pm_typproba,
                     codempid = pm_codempid,
                     codeval = pm_codeval,
                     dteeval = pm_dteeval,
                     codform = pm_codform,
                     codcomp = pm_codcomp,
                     codrespr = pm_codrespr,
                     qtyexpand = pm_qtyexpand,
                     dteexpand = v_dteexpand,
                     codexemp = pm_codexemp,
                     desnote = pm_desnote,
                     coduser = global_v_coduser,
                     avascore = v_avgscor
               WHERE codempid = pm_codempid
                 and dteduepr = pm_dteduepr;
            end;
          end if;
        end if;
      end if;
      BEGIN
          SELECT codcomp, codpos
            INTO v_codcomp, v_codpos
            FROM temploy1
           WHERE codempid = pm_codempid;
      EXCEPTION WHEN no_data_found THEN
          v_codcomp     := '';
          v_codpos      := '';
      END;

      BEGIN
          SELECT MAX(numseq)
            INTO v_num
            FROM tproasgn
           WHERE codcomp like v_codcomp
             AND codpos like v_codpos
             AND codempid like pm_codempid
             AND typproba = pm_typproba;
      EXCEPTION WHEN no_data_found THEN
        v_num := 0;
      END;
      commit;
      param_msg_error   := get_error_msg_php('HR2401', global_v_lang);
      json_str_output   := get_response_message(NULL, param_msg_error, global_v_lang);
      obj               := json_object_t(json_str_output);
      obj_data_obj      := hcm_util.get_string_t(obj, 'desc_coderror');
      obj_sum           := json_object_t();
      obj_sum.put('response', obj_data_obj);
      obj_sum.put('coderror', '200');
      dbms_lob.createtemporary(json_str_output, true);
      obj_sum.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  END savedetail;

  PROCEDURE send_mail_appr ( p_codempid VARCHAR2, p_dteduepr date, p_numtime number,  p_numseq NUMBER, p_typproba VARCHAR2 ) IS
      v_msg_to        clob;
      v_template_to   clob;
      v_func_appr     VARCHAR2(20);
      v_error         VARCHAR2(20);
      v_stderror      VARCHAR2(20);
      v_numseq        NUMBER := 0;
      v_codcompap     temploy1.codcomp%TYPE;
      v_codposap      temploy1.codpos%TYPE;
      v_data          VARCHAR2(1) := 'N';
      v_lstcheck      VARCHAR2(1) := 'Y';
      v_codcomp       temploy1.codcomp%TYPE;
      v_codempid      temploy1.codempid%TYPE;
      v_approvno      NUMBER := 0;
      v_seqno         NUMBER := 0;
      v_seqappno      NUMBER := 0;
      v_seq           NUMBER;
      v_codcompemp    temploy1.codcomp%TYPE;
      v_codposemp     temploy1.codpos%TYPE;
      v_flgappr       VARCHAR2(1);
      v_chkappr       VARCHAR2(1);
      v_codcompy      tcompny.codcompy%TYPE;
      v_codlinef      VARCHAR2(4);
      v_dteeffec      DATE;
      v_pageno        NUMBER;
      v_rowno         NUMBER;
      v_columnno      NUMBER;
      v_torgprt       VARCHAR2(1) := 'N';
      v_setorg2       VARCHAR2(1) := 'N';
      v_codapman      temploy1.codempid%TYPE;
      v_codcompapr    temploy1.codcomp%TYPE;
      v_codposapr     temploy1.codpos%TYPE;
      v_email         VARCHAR2(50);
      v_coduser       temploy1.coduser%TYPE;
      v_msg           LONG;
      v_codpos        temploy1.codpos%TYPE;
      v_flag          VARCHAR2(4);
      v_num           NUMBER;
      v_numlvl        NUMBER;
      v_numlvlemp     NUMBER;
      v_codeval       tappbath.codeval%type;
      v_compeval      tappbath.compeval%type;
      v_codposeval    tappbath.codposeval%type;
      v_rowid         rowid;
      v_maillang      varchar2(10);
      CURSOR tproasgh IS
          SELECT codcomp, codpos, codempid, codform
            FROM tproasgh
           WHERE v_codcompemp LIKE codcomp
             AND v_codposemp LIKE codpos
             AND p_codempid LIKE codempid
             AND p_typproba = typproba
        ORDER BY codempid DESC, codcomp DESC;

      CURSOR c_tproasgn IS
          SELECT numseq, flgappr, codcompap, codposap, codempap
            FROM tproasgn
           WHERE codcomp = v_codcomp
             AND codpos = v_codpos
             AND codempid = v_codempid
             AND typproba = p_typproba
             AND numseq > p_numseq
        ORDER BY numseq;

      CURSOR c_codapman IS
          SELECT codempid
            FROM ( SELECT codempid
                     FROM temploy1
                    WHERE codcomp = v_codcompapr
                      AND codpos = v_codposapr
                      AND staemp IN ('1','3')
                    UNION
                   SELECT codempid
                     FROM tsecpos
                    WHERE codcomp = v_codcompapr
                      AND codpos = v_codposapr
                      AND dteeffec <= SYSDATE
                      AND ( nvl(dtecancel, dteend) >= trunc(SYSDATE)
                            OR nvl(dtecancel, dteend) IS NULL ) ) a
--           WHERE a.codempid NOT IN ( SELECT b.codempid
--                                       FROM torgprt2 b
--                                      WHERE b.codempid = a.codempid )
;

      CURSOR c_temphead1 IS
          select replace(codempidh,'%',null) codempidh,
                 replace(codcomph,'%',null) codcomph,
                 replace(codposh,'%',null) codposh
            FROM temphead
           WHERE codempid = p_codempid
        ORDER BY codempidh;

      CURSOR c_temphead2 IS
          select replace(codempidh,'%',null) codempidh,
                 replace(codcomph,'%',null) codcomph,
                 replace(codposh,'%',null) codposh
            FROM temphead
           WHERE codcomp = v_codcompemp
             AND codpos = v_codposemp
        ORDER BY codcomph, codposh;

      CURSOR c_sendmail IS
          SELECT item1 codempid
            FROM ttemprpt
           WHERE codempid = p_codempid
             AND codapp = 'HRPM31E'
        ORDER BY numseq;

  BEGIN
      DELETE ttemprpt
       WHERE codempid = p_codempid
         AND codapp = 'HRPM31E';

      BEGIN
          SELECT codcomp, codpos, numlvl
            INTO v_codcompemp, v_codposemp, v_numlvlemp
            FROM temploy1
           WHERE codempid = p_codempid;
      EXCEPTION WHEN no_data_found THEN
        NULL;
      END;

      FOR i IN tproasgh LOOP
          v_codcomp     := i.codcomp;
          v_codpos      := i.codpos;
          v_codempid    := i.codempid;
          EXIT;
      END LOOP;

      begin
          select codeval, compeval, codposeval
            into v_codeval, v_compeval, v_codposeval
            from tappbath
           where codempid = p_codempid
             and dteduepr = p_dteduepr
             and numtime = p_numtime
             and numseq = p_numseq + 1;
      exception when others then
        null;
      end;

      if v_codeval is not null then
          v_numseq := v_numseq + 1;
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
               VALUES ( p_codempid, 'HRPM31E', v_numseq, v_codeval );
          v_data := 'Y';
      elsif v_compeval is not null and v_codposeval is not null then
          v_codcompapr := v_compeval;
          v_codposapr := v_codposeval;
          FOR r_codapman IN c_codapman LOOP
              v_numseq := v_numseq + 1;
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
                   VALUES ( p_codempid, 'HRPM31E', v_numseq, r_codapman.codempid );
              v_data := 'Y';
          END LOOP;
      else
          FOR j IN c_temphead1 LOOP
            IF j.codempidh IS NOT NULL THEN
              v_numseq := v_numseq + 1;
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
                   VALUES ( p_codempid, 'HRPM31E', v_numseq, j.codempidh );
              v_data := 'Y';
              EXIT;
            ELSE
              v_codcompapr := j.codcomph;
              v_codposapr := j.codposh;
              FOR r_codapman IN c_codapman LOOP
                  v_numseq := v_numseq + 1;
                  INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
                       VALUES ( p_codempid, 'HRPM31E', v_numseq, r_codapman.codempid );
                  v_data := 'Y';
              END LOOP;
              EXIT;
            END IF;
          END LOOP;

          IF v_data <> 'Y' THEN
              FOR j IN c_temphead2 LOOP
                  IF j.codempidh IS NOT NULL THEN
                      v_numseq := v_numseq + 1;
                      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
                           VALUES ( p_codempid, 'HRPM31E', v_numseq, j.codempidh );

                      v_data := 'Y';
                      EXIT;
                  ELSE
                      v_codcompapr  := j.codcomph;
                      v_codposapr   := j.codposh;
                      FOR r_codapman IN c_codapman LOOP
                          v_numseq := v_numseq + 1;
                          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1 )
                               VALUES ( p_codempid, 'HRPM31E', v_numseq, r_codapman.codempid );
                          v_data := 'Y';
                      END LOOP;
                      EXIT;
                  END IF;
              END LOOP;
          END IF;
      end if;

      v_func_appr := 'HRPM31E';

      v_stderror := 'HR2046';
      FOR i IN c_sendmail LOOP
          begin
              select rowid
                into v_rowid
                from V_TEMPLOY
               WHERE codempid = p_codempid;
          exception when no_data_found then
            v_rowid := null;
          end;
          v_maillang := chk_flowmail.get_emp_mail_lang(i.codempid);
          chk_flowmail.get_message_result('HRPM31E1', v_maillang, v_msg_to, v_template_to);
          chk_flowmail.replace_text_frmmail(v_template_to, 'V_TEMPLOY', v_rowid, get_label_name('HRPM31E1',v_maillang,210), 'HRPM31E1', '1', null, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N');

          begin
              select rowid
                into v_rowid
                from tappbath
               where codempid = p_codempid
                 and dteduepr = p_dteduepr
                 and numtime = p_numtime
                 and numseq = p_numseq;
          exception when no_data_found then
            v_rowid := null;
          end;
          chk_flowmail.replace_param('TAPPBATH',v_rowid,'HRPM31E1','1',v_maillang,v_msg_to,'N');
          v_error := chk_flowmail.send_mail_to_emp (i.codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRPM31E1',v_maillang,210), 'E', v_maillang, null, null,null,null,null,'HRMS31E',i.codempid);
          IF v_error = '2046' THEN
              v_stderror := 'HR2046';
          ELSIF v_error = '7526'   then
            v_stderror := 'HR7526';
          ELSE
              v_stderror := 'HR7522';
          END IF;
      END LOOP;

      BEGIN
          SELECT MAX(numseq)
            INTO v_num
            FROM tproasgn
           WHERE codcomp = v_codcomp
             AND codpos = v_codpos
             AND codempid = v_codempid
             AND typproba = p_typproba;

      EXCEPTION WHEN no_data_found THEN
        v_num := NULL;
      END;

      IF nvl(v_num, 0) = p_numseq THEN
          param_msg_error := get_error_msg_php('HR8839', global_v_lang);
      ELSE
          param_msg_error := get_error_msg_php(v_stderror, global_v_lang);
      END IF;
  END;

  PROCEDURE send_mail_apprco (p_codempid VARCHAR2, p_dteduepr	DATE, p_approvno NUMBER) IS
    v_codform		    tfwmailh.codform %type;
    v_msg_to            clob;
    v_template_to       clob;
    v_func_appr         tfwmailh.CODAPPAP%type;
    v_rowid             rowid;
    v_error			    terrorm.errorno%type;
    v_stderror          VARCHAR2(20);

    BEGIN
        begin
            select rowid
              into v_rowid
              from TTPROBAT
             where CODEMPID = p_codempid
             AND DTEDUEPR = p_dteduepr;
        exception when no_data_found then
            v_codform := null;
        end;

        begin
            v_error := chk_flowmail.send_mail_for_approve('HRPM31E', p_codempid, global_v_codempid, global_v_coduser, null, 'HRPM31E4', 20, 'E', 'P', p_approvno, null, null,'TTPROBAT',v_rowid, '1', null);        
        EXCEPTION WHEN OTHERS THEN
            v_error := '7522';
        END;

        IF v_error = '2046' THEN
            v_stderror := 'HR2046';
        ELSIF v_error = '7526'   then
            v_stderror := 'HR7526';
        ELSE
            v_stderror := 'HR7522';
        END IF;
        param_msg_error := get_error_msg_php(v_stderror, global_v_lang);
  END send_mail_apprco;

  PROCEDURE send_mailappr ( json_str_input IN CLOB, json_str_output OUT CLOB ) IS
      json_obj          json_object_t;
      v_codfrm_to       tfwmailh.codform%TYPE;
      v_msg_to          LONG;
      v_template_to     LONG;
      v_func_appr       VARCHAR2(100 CHAR);
      v_error           VARCHAR2(100 CHAR);
      v_countttprobat   number;
  BEGIN
      initial_value(json_str_input);
      json_obj := json_object_t(json_str_input);

      select count(codempid)
        into v_countttprobat
        from ttprobat
       where codempid = p_codempid_query
         and dteduepr = p_dteduepr
         and typproba = p_typproba;

      if v_countttprobat > 0 then
        hrpm31e.send_mail_apprco (p_codempid_query, p_dteduepr, 1);
      else
        hrpm31e.send_mail_appr (p_codempid_query, p_dteduepr, p_numtime, p_numseq , p_typproba);
      end if;

      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  END send_mailappr;

  function gen_codeval (
      p_codempid   varchar2,
      p_dteduepr   date,
      p_numtime    number,
      p_numseq     number,
      p_codappr    varchar2,
      p_typproba   varchar2
  ) return varchar2 is

      v_codcomp      temploy1.codcomp%TYPE;
      v_codpos       temploy1.codpos%TYPE;
      v_codempid     temploy1.codempid%TYPE;
      u_codcomp      temploy1.codcomp%TYPE;
      u_codpos       temploy1.codpos%TYPE;
      u_codempid     temploy1.codempid%TYPE;
      v_codcompemp   temploy1.codcomp%TYPE;
      v_codposemp    temploy1.codpos%TYPE;
      v_codcompapr   temploy1.codcomp%TYPE;
      v_codposapr    temploy1.codpos%TYPE;
      v_codcompy     tcompny.codcompy%TYPE;
      v_codlinef     VARCHAR2(4);
      v_dteeffec     DATE;
      v_pageno       NUMBER;
      v_rowno        NUMBER;
      v_columnno     NUMBER;
      v_numlvl       NUMBER;
      v_concat       varchar2(1);
      v_lstappr        varchar2(1);
      v_flgsecure   boolean;
      v_zupdsal     varchar2(1000);

      CURSOR c_tproasgh IS
          SELECT codcomp, codpos, codempid
            FROM tproasgh
           WHERE v_codcompemp LIKE codcomp  || '%'
             AND v_codposemp LIKE codpos
             AND p_codempid LIKE codempid
             AND p_typproba = typproba
        ORDER BY codempid DESC, codcomp DESC;

      CURSOR c_tproasgn IS
          SELECT numseq, flgappr, codcompap, codposap, codempap
            FROM tproasgn
           WHERE codcomp = v_codcomp
             AND codpos = v_codpos
             AND codempid = v_codempid
             AND p_typproba = typproba
             AND numseq = p_numseq;

      CURSOR c_temphead1 IS
         SELECT replace(codempidh,'%',null) codempidh,
                replace(codcomph,'%',null) codcomph,
                replace(codposh,'%',null) codposh
           FROM temphead
          WHERE codempid = u_codempid
       ORDER BY codempidh;

      CURSOR c_temphead2 IS
         SELECT replace(codempidh,'%',null) codempidh,
                replace(codcomph,'%',null) codcomph,
                replace(codposh,'%',null) codposh
           FROM temphead
          WHERE codcomp = u_codcomp
            AND codpos = u_codpos
       ORDER BY codcomph, codposh;

      CURSOR c_codapman IS
          SELECT codempid
            FROM ( SELECT codempid
                     FROM temploy1
                    WHERE codcomp like v_codcompapr ||'%'
                      AND codpos = v_codposapr
                      AND staemp IN ( '1', '3')
                    UNION
                   SELECT codempid
                     FROM tsecpos
                    WHERE codcomp like v_codcompapr ||'%'
                      AND codpos = v_codposapr
                      AND dteeffec <= SYSDATE
                      AND ( nvl(dtecancel, dteend) >= trunc(SYSDATE)
                            OR nvl(dtecancel, dteend) IS NULL ) ) a
--           WHERE a.codempid NOT IN ( SELECT b.codempid
--                                       FROM torgprt2 b
--                                      WHERE b.codempid = a.codempid )
        ORDER BY codempid;

  BEGIN
      BEGIN
          SELECT codcomp, codpos, numlvl
            INTO v_codcompemp, v_codposemp, v_numlvl
            FROM temploy1
           WHERE codempid = p_codempid;
      EXCEPTION WHEN no_data_found THEN
        NULL;
      END;

      u_codempid    := p_codempid;
      u_codcomp     := v_codcompemp;
      u_codpos      := v_codposemp;

      BEGIN
          SELECT a.codempid, b.codcomp, b.codpos
            INTO u_codempid, u_codcomp, u_codpos
            FROM tappbath   a, temploy1   b
           WHERE a.codempid = b.codempid
             AND a.codempid = p_codempid
             AND a.dteduepr = p_dteduepr
             AND a.numseq = ( p_numseq - 1 )
             AND a.numtime = p_numtime;
      EXCEPTION WHEN no_data_found THEN
        NULL;
      END;

--in sert_temp2('HRPM31E','HRPM31E','XX','p_numseq='||p_numseq ,  'u_codempid='||u_codempid , 'u_codpos='||u_codpos , null ,null,null,null,null,null);

      FOR i IN c_tproasgh LOOP
          v_codcomp     := i.codcomp;
          v_codpos      := i.codpos;
          v_codempid    := i.codempid;
          EXIT;
      END LOOP;

      FOR i IN c_tproasgn LOOP
       IF i.flgappr = '1' THEN
--          gen condition for lov
--<<28/01/2023||SEA-HR2201||redmine680
           begin
                select   flgappr   into v_lstappr
                from tproasgn
                where codcomp = v_codcomp
                and codpos = v_codpos
                and codempid = v_codempid
                and p_typproba = typproba
                and numseq = (p_numseq-1);
                exception when no_data_found then
                  v_lstappr  := null;
            end;     
          if  v_lstappr  = '1' then  
                        begin
                        select a.codeval, b.codcomp, b.codpos
                        into u_codempid, u_codcomp, u_codpos
                        from tappbath   a, temploy1   b
                        where a.codempid = b.codempid
                        and a.codempid = p_codempid
                        and a.dteduepr = p_dteduepr
                        and a.numseq = ( p_numseq - 1 )
                        and a.numtime = p_numtime;
                        exception when no_data_found then
                            null;
                        end;
          end if;
 -->>28/01/2023||SEA-HR2201||redmine680

          FOR j IN c_temphead1 LOOP
            IF j.codempidh IS NOT NULL THEN
                p_codempcondition := p_codempcondition||v_concat||''''||j.codempidh||'''';
                v_concat := ',';
            ELSE
              v_codcompapr  := j.codcomph;
              v_codposapr   := j.codposh;
              FOR r_codapman IN c_codapman LOOP
                p_codempcondition := p_codempcondition||v_concat||''''||r_codapman.codempid||'''';
                v_concat := ',';
              END LOOP;
            END IF;
          END LOOP;

          FOR j IN c_temphead2 LOOP
              IF j.codempidh IS NOT NULL THEN
                  p_codempcondition := p_codempcondition||v_concat||''''||j.codempidh||'''';
                  v_concat := ',';
              ELSE
                  v_codcompapr := j.codcomph;
                  v_codposapr := j.codposh;
                  FOR r_codapman IN c_codapman LOOP
                      p_codempcondition := p_codempcondition||v_concat||''''||r_codapman.codempid||'''';
                      v_concat := ',';
                  END LOOP;
              END IF;
          END LOOP;

          if p_codempcondition is not null or nvl(p_codempcondition,'') != '' then
            p_codempcondition := 'emp1.codempid in (' || p_codempcondition || ')';
          end if;

--in sert_temp2('HRPM31E','HRPM31E','XX','p_numseq='||p_numseq ,  p_codempcondition , 'p_codappr='||p_codappr , null ,null,null,null,null,null);

          FOR j IN c_temphead1 LOOP
            IF j.codempidh IS NOT NULL THEN
              IF j.codempidh = nvl(p_codappr, j.codempidh) THEN
--                  v_flgsecure := secur_main.secur2(j.codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--                  if not v_flgsecure then return null; end if;
                  return(j.codempidh);
              END IF;
            ELSE
              v_codcompapr  := j.codcomph;
              v_codposapr   := j.codposh;
              FOR r_codapman IN c_codapman LOOP
                IF r_codapman.codempid = nvl(p_codappr, r_codapman.codempid) THEN
--                  v_flgsecure := secur_main.secur2(r_codapman.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--                  if not v_flgsecure then return null; end if;
                  return(r_codapman.codempid);
                END IF;
              END LOOP;
            END IF;
          END LOOP;

          FOR j IN c_temphead2 LOOP
              IF j.codempidh IS NOT NULL THEN
                  IF j.codempidh = nvl(p_codappr, j.codempidh) THEN
--                      v_flgsecure := secur_main.secur2(j.codempidh,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--                      if not v_flgsecure then return null; end if;
                      return(j.codempidh);
                  END IF;
              ELSE
                  v_codcompapr := j.codcomph;
                  v_codposapr := j.codposh;
                  FOR r_codapman IN c_codapman LOOP
                      IF r_codapman.codempid = nvl(p_codappr, r_codapman.codempid) THEN
--                          v_flgsecure := secur_main.secur2(r_codapman.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--                          if not v_flgsecure then return null; end if;
                          return(r_codapman.codempid);
                      END IF;
                  END LOOP;
              END IF;
          END LOOP;
--       ELSIF i.flgappr = '2' THEN
--          FOR r_torgprt IN c_torgprt LOOP
--              v_codcompy    := r_torgprt.codcompy;
--              v_codlinef    := r_torgprt.codlinef;
--              v_dteeffec    := r_torgprt.dteeffec;
--              v_pageno      := r_torgprt.pagenoh;
--              v_rowno       := r_torgprt.rownoh;
--              v_columnno    := r_torgprt.columnnoh;
--              FOR r_torgprt2_set IN c_torgprt2_set LOOP
--                  IF r_torgprt2_set.codempid = nvl(p_codappr, r_torgprt2_set.codempid) THEN
--                      return(r_torgprt2_set.codempid);
--                  END IF;
--              END LOOP;
--
--              FOR r_torgprt2_notset IN c_torgprt2_notset LOOP
--                  v_codcompapr  := r_torgprt2_notset.codcompp;
--                  v_codposapr   := r_torgprt2_notset.codpospr;
--                  FOR r_codapman IN c_codapman LOOP
--                      IF r_codapman.codempid = nvl(p_codappr, r_codapman.codempid) THEN
--                          return(r_codapman.codempid);
--                      END IF;
--                  END LOOP;
--              END LOOP;
--
--              EXIT;
--          END LOOP;
--
--          FOR r_torgprt2_no IN c_torgprt2_no LOOP
--              v_codcompy    := r_torgprt2_no.codcompy;
--              v_codlinef    := r_torgprt2_no.codlinef;
--              v_dteeffec    := r_torgprt2_no.dteeffec;
--              v_pageno      := r_torgprt2_no.pagenoh;
--              v_rowno       := r_torgprt2_no.rownoh;
--              v_columnno    := r_torgprt2_no.columnnoh;
--
--              FOR r_torgprt2_set IN c_torgprt2_set LOOP
--                  IF r_torgprt2_set.codempid = nvl(p_codappr, r_torgprt2_set.codempid) THEN
--                      return(r_torgprt2_set.codempid);
--                  END IF;
--              END LOOP;
--
--              FOR r_torgprt2_notset IN c_torgprt2_notset LOOP
--                  v_codcompapr := r_torgprt2_notset.codcompp;
--                  v_codposapr := r_torgprt2_notset.codpospr;
--                  FOR r_codapman IN c_codapman LOOP
--                      IF r_codapman.codempid = nvl(p_codappr, r_codapman.codempid) THEN
--                          return(r_codapman.codempid);
--                      END IF;
--                  END LOOP;
--              END LOOP;
--              EXIT;
--          END LOOP;
       ELSIF i.flgappr = '2' THEN
          v_codcompapr  := i.codcompap;
          v_codposapr   := i.codposap;

--          p_codempcondition := 'emp1.codempid in (';
--
--          FOR r_codapman IN c_codapman LOOP
--            p_codempcondition := p_codempcondition||v_concat||''''||r_codapman.codempid||'''';
--            v_concat := ',';
--          END LOOP;
--          p_codempcondition := p_codempcondition||')';
          p_codempcondition := 'emp1.codempid in( SELECT codempid FROM ( SELECT codempid FROM temploy1 WHERE codcomp like '''|| v_codcompapr ||'%'' AND codpos = '''|| v_codposapr ||''' AND staemp IN ( ''1'', ''3'') UNION SELECT codempid FROM tsecpos WHERE codcomp like '''|| v_codcompapr ||'%'' AND codpos = '''|| v_codposapr ||''' AND dteeffec <= SYSDATE AND ( nvl(dtecancel, dteend) >= trunc(SYSDATE) OR nvl(dtecancel, dteend) IS NULL ) ) a )';
          FOR r_codapman IN c_codapman LOOP
              IF r_codapman.codempid = nvl(p_codappr, r_codapman.codempid) THEN
--                  v_flgsecure := secur_main.secur2(r_codapman.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--                  if not v_flgsecure then return null; end if;
                  return(r_codapman.codempid);
              END IF;
          END LOOP;
       ELSIF i.flgappr = '3' THEN
          IF i.codempap = nvl(p_codappr, i.codempap) THEN
              p_codempcondition := 'emp1.codempid = '''||i.codempap||'''';
--              v_flgsecure := secur_main.secur2(i.codempap,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              if not v_flgsecure then return null; end if;
              return(i.codempap);
          END IF;
       ELSIF i.flgappr = '4' THEN
          IF p_codempid = nvl(p_codappr, p_codempid) THEN
              p_codempcondition := 'emp1.codempid = '''||p_codempid||'''';
--              v_flgsecure := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              if not v_flgsecure then return null; end if;
              return(p_codempid);
          END IF;
       END IF;
      END LOOP;
      return(NULL);
  END; --  function gen_codeval

  PROCEDURE getdelete (
      json_str_input    IN    CLOB,
      json_str_output   OUT   CLOB
  ) IS

      json_obj          json_object_t;
      p_codempid   tappbath.codempid%TYPE;
      p_numseq     tappbath.numseq%TYPE;
      p_numtime    tappbath.numtime%TYPE;
      p_maxnumseq     tproasgn.numseq%type;
      count_rows        NUMBER;
  BEGIN
      json_obj          := json_object_t(json_str_input);
      p_codempid        := hcm_util.get_string_t(json_obj, 'p_codempid');
      p_numseq          := hcm_util.get_string_t(json_obj, 'p_numseq');
      p_numtime         := hcm_util.get_string_t(json_obj, 'p_numtime');
      p_typproba        := hcm_util.get_string_t(json_obj, 'p_typproba');
      p_dteduepr        := to_date(hcm_util.get_string_t(json_obj, 'p_dteduepr'),'dd/mm/yyyy');
      p_maxnumseq       := to_number(hcm_util.get_string_t(json_obj, 'p_maxnumseq'));
      SELECT COUNT(*)
        INTO count_rows
        FROM tappbath
       WHERE numseq = p_numseq
         AND numtime = p_numtime
         AND codempid = p_codempid;

      IF ( count_rows >= 1 ) THEN
          DELETE
            FROM tappbath
           WHERE numseq >= p_numseq
             AND numtime = p_numtime
             AND codempid = p_codempid;
          if p_numseq > 1 then
            hrpm31e.insert_tappbath (p_codempid, p_dteduepr, p_numtime, p_typproba);
          end if;

          if p_numseq = p_maxnumseq then
            begin
                delete from ttprobatd
                where codempid = p_codempid
                  and dteduepr = p_dteduepr
                  and numtime = p_numtime;

                delete from ttprobat
                where codempid = p_codempid
                  and dteduepr = p_dteduepr;
            exception when others then
                null;
            end;
          end if;
          param_msg_error := get_error_msg_php('HR2425', global_v_lang);
          json_str_output := get_response_message('200', param_msg_error, global_v_lang);
          return;
      ELSE
          param_msg_error := get_error_msg_php('HR2010', global_v_lang);
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
          return;
      END IF;
  END getdelete;

  PROCEDURE initial_report ( json_str IN CLOB ) IS
      json_obj json_object_t;
  BEGIN
      json_obj          := json_object_t(json_str);
      global_v_coduser  := hcm_util.get_string_t(json_obj, 'p_coduser');
      global_v_codempid := hcm_util.get_string_t(json_obj, 'p_codempid');
      global_v_lang     := hcm_util.get_string_t(json_obj, 'p_lang');
      r_codeval         := hcm_util.get_string_t(json_obj, 'r_codeval');
      detail_numseq     := hcm_util.get_string_t(json_obj, 'r_numseq');
      detail_numtime    := hcm_util.get_string_t(json_obj, 'r_numtime');
      detail_codempid   := hcm_util.get_string_t(json_obj, 'r_codempid');
      detail_typproba   := hcm_util.get_string_t(json_obj, 'r_typproba');
      detail_codcomp    := hcm_util.get_string_t(json_obj, 'r_codcomp');
      detail_codpos     := hcm_util.get_string_t(json_obj, 'r_codpos');
      p_formtype        := hcm_util.get_string_t(json_obj, 'p_formtype');
      tab3_dtestrt      := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dtestrt')), 'dd/mm/yyyy');
      tab3_dteend       := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'tab3_dteend')), 'dd/mm/yyyy');
      p_dteduepr       := TO_DATE(trim(hcm_util.get_string_t(json_obj, 'p_dteduepr')), 'dd/mm/yyyy');
  END initial_report;

  PROCEDURE gen_report (
      json_str_input    IN    CLOB,
      json_str_output   OUT   CLOB
  ) IS

      json_output         CLOB;
      cursorquestion      SYS_REFCURSOR;
      cursoranswer        SYS_REFCURSOR;
      v_codform           tproasgh.codform%TYPE;
      q_codform           tintvews.codform%TYPE;
      q_numgrup           tintvews.numgrup%TYPE;
      q_desgrupt          tintvews.desgrupt%TYPE;
      q_qtyfscor          tintvews.qtyfscor%TYPE;
      v_maxscore          NUMBER;
      v_qtywgt            NUMBER;
      obj_data            json_object_t;
      obj_row6            json_object_t;
      numanswer           NUMBER := 0;
      v_qtyfscor          tintvewd.qtyfscor%TYPE;
      v_desitemt          tintvewd.desitemt%TYPE;
      v_numitem           tintvewd.numitem%TYPE;
      obj_col6            json_object_t;
      tappbati_numitem    tappbati.numitem%TYPE;
      v_rcnt              NUMBER := 0;
      obj_row5            json_object_t;
      tappbati_qtyscor    tappbati.qtyscor%TYPE;
      h_codempid          VARCHAR(500);
      h_codpos            VARCHAR(500);
      h_tcenter_level     VARCHAR(500);
      h_tcenter_name      VARCHAR(500);
      h_typproba          VARCHAR(500);
      h_dteefpos_normal   VARCHAR(500);
      h_dteduepr_normal   VARCHAR(500);
      h_dteefpos          VARCHAR(500);
      h_dteduepr          VARCHAR(500);

      v_codrespr          VARCHAR(500);
      obj_row             json_object_t;
  BEGIN
      initial_report(json_str_input);
      isinsertreport    := true;
      numyearreport     := hcm_appsettings.get_additional_year();
      obj_row           := json_object_t();
      clear_ttemprpt;
      BEGIN
          SELECT codrespr
            INTO v_codrespr
            FROM tappbath
           WHERE codempid = detail_codempid
             and dteduepr = p_dteduepr
             AND numseq = detail_numseq
             AND numtime = detail_numtime;
      EXCEPTION WHEN no_data_found THEN
        v_codrespr := NULL;
      END;

      v_type := '';
      IF p_formtype = '2' THEN
          v_type := 'main';
      ELSE
          v_type := 'forms';
      END IF;
      get_detail_report_forms;
      get_detail_report;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('type', v_type);
      obj_row.put((1), obj_data);
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
  EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack
                         || ' '
                         || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END gen_report;

  PROCEDURE get_detail_report IS
      json_output         CLOB;
      cursorquestion      SYS_REFCURSOR;
      cursoranswer        SYS_REFCURSOR;
      v_codform           tproasgh.codform%TYPE;
      q_codform           tintvews.codform%TYPE;
      q_numgrup           tintvews.numgrup%TYPE;
      q_desgrup           tintvews.desgrupt%TYPE;
      q_qtyfscor          tintvews.qtyfscor%TYPE;
      v_maxscore          NUMBER;
      v_qtywgt            NUMBER;
      v_qtywgt_tintvewd   NUMBER;
      obj_data            json_object_t;
      obj_row6            json_object_t;
      numanswer           NUMBER := 0;
      v_qtyfscor          tintvewd.qtyfscor%TYPE;
      v_desitem           tintvewd.desitemt%TYPE;
      v_definit           tintvewd.definitt%TYPE;
      v_numitem           tintvewd.numitem%TYPE;
      obj_col6            json_object_t;
      tappbati_numitem    tappbati.numitem%TYPE;
      v_rcnt              NUMBER := 0;
      obj_row5            json_object_t;
      tappbati_qtyscor    tappbati.qtyscor%TYPE;
      tappbati_grdscor    tappbati.grdscor%TYPE;
      h_codempid          VARCHAR(500);
      h_codpos            VARCHAR(500);
      h_tcenter_level     VARCHAR(500);
      h_tcenter_name      VARCHAR(500);
      h_typproba          VARCHAR(500);
      h_dteefpos_normal   VARCHAR(500);
      h_dteduepr_normal   VARCHAR(500);
      h_dteefpos          VARCHAR(500);
      h_dteduepr          VARCHAR(500);
      assessor_codeval    VARCHAR(500);
      assessor_codpos     VARCHAR(500);
      assessor_pos        VARCHAR(500);
      v_commboss          tappbath.commboss%TYPE;
      v_codrespr          tappbath.codrespr%TYPE;
      v_qtyexpand         tappbath.qtyexpand%TYPE;
      v_desnote           tappbath.desnote%TYPE;
      v_pointsum          tintvewd.qtyfscor%TYPE;
      v_imageh            tempimge.namimage%type;
      v_folder            tfolderd.folder%type;
      v_has_image         varchar2(1) := 'N';
      v_staeval           tappbath.staeval%type;
      v_flgrepos            tappbath.flgrepos%type;

      CURSOR c_questiongroup IS
        SELECT codform, numgrup, qtyfscor,
               decode(global_v_lang,
                     101,desgrupe,
                     102,desgrupt,
                     103,desgrup3,
                     104,desgrup4,
                     105,desgrup5) desgrup
          FROM tintvews
         WHERE codform = v_codform;

      CURSOR c_question IS
        SELECT qtyfscor, desitemt, numitem, qtywgt,
               decode(global_v_lang,
                     101,desiteme,
                     102,desitemt,
                     103,desitem3,
                     104,desitem4,
                     105,desitem5) desitem,
               decode(global_v_lang,
                     101,definite,
                     102,definitt,
                     103,definit3,
                     104,definit4,
                     105,definit5) definit

          FROM tintvewd
         WHERE codform = q_codform
           AND numgrup = q_numgrup
      ORDER BY numgrup, numitem;
  BEGIN
      v_pointsum := 0;
      BEGIN
          SELECT codform
           INTO v_codform
           FROM tproasgh
          WHERE detail_codcomp LIKE codcomp || '%'
            AND detail_codpos LIKE codpos
            AND detail_codempid LIKE codempid
            AND typproba = detail_typproba
            AND ROWNUM = 1
       ORDER BY codempid DESC, codcomp DESC;
      EXCEPTION WHEN no_data_found THEN
        v_codform := NULL;
      END;

      BEGIN
          SELECT TO_CHAR(dteefpos, 'dd/mm/yyyy') AS dteefpos,
                 TO_CHAR(dteduepr, 'dd/mm/yyyy') AS dteduepr
            INTO h_dteefpos_normal,
                 h_dteduepr_normal
            FROM temploy1
           WHERE codempid = detail_codempid;
       EXCEPTION WHEN no_data_found THEN
          h_dteefpos_normal := NULL;
          h_dteduepr_normal := NULL;
      END;

      h_codempid        := detail_codempid
                            || ' - '
                            || get_temploy_name(detail_codempid, global_v_lang);
      h_tcenter_level   := hcm_util.get_codcomp_level(detail_codcomp, 1);
      h_tcenter_name    := h_tcenter_level
                            || ' - '
                            || get_tcenter_name(h_tcenter_level, global_v_lang);
      h_codpos          := detail_codpos
                            || ' - '
                            || get_tpostn_name(detail_codpos, global_v_lang);
      h_typproba        := get_tlistval_name('NAMTPRO', detail_typproba, global_v_lang);
      BEGIN
          SELECT codpos
            INTO assessor_pos
            FROM temploy1
           WHERE codempid = r_codeval;
      EXCEPTION WHEN no_data_found THEN
        assessor_pos := NULL;
      END;

      assessor_codeval := r_codeval
                          || ' - '
                          || get_temploy_name(r_codeval, global_v_lang);
      assessor_codpos := assessor_pos
                         || ' - '
                         || get_tpostn_name(assessor_pos, global_v_lang);
      BEGIN
          SELECT commboss, codrespr, qtyexpand, desnote,staeval,flgrepos
            INTO v_commboss, v_codrespr, v_qtyexpand, v_desnote,v_staeval,v_flgrepos
            FROM tappbath
           WHERE codempid = detail_codempid
             and dteduepr = p_dteduepr
             AND numtime = detail_numtime
             AND numseq = detail_numseq;
      EXCEPTION WHEN no_data_found THEN
          v_commboss    := NULL;
          v_codrespr    := NULL;
          v_qtyexpand   := NULL;
      END;

        begin
          select namimage
            into v_imageh
            from tempimge
           where codempid = detail_codempid;
        exception when no_data_found then
          v_imageh := null;
        end;

        if v_imageh is not null then
          v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
          v_has_image   := 'Y';
        end if;

      if p_formtype ='1' then
        v_staeval   := null;
        v_flgrepos  := null;
        v_commboss  := '';
        v_codrespr  := null;
      end if;

      if detail_typproba ='1' then
        v_flgrepos  := null;
      end if;

     INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2, item5,
                             item6, item7, item8,item9,item10,
                             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,item21)
                    VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'HEAD', detail_codempid, h_codempid,
                             h_tcenter_name, h_codpos, h_typproba,
                             TO_CHAR(add_months(TO_DATE(h_dteefpos_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             TO_CHAR(add_months(TO_DATE(h_dteduepr_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                             assessor_codeval, assessor_codpos, detail_numtime, detail_numseq, v_codrespr, v_qtyexpand, v_desnote,
                             v_has_image, v_imageh,v_staeval,v_flgrepos );

      r_numseq := r_numseq + 1;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                             item2, item5, item6 )
                    VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'HEADTABLE',
                             detail_codempid, v_codform || ' - ' || get_tintview_name(v_codform, global_v_lang), v_commboss );

      r_numseq := r_numseq + 1;
      FOR r1 in c_questiongroup LOOP
        q_codform   := r1.codform;
        q_numgrup   := r1.numgrup;
        q_desgrup  := r1.desgrup;
        q_qtyfscor  := r1.qtyfscor;
        INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2, item5,
                             item6, item7, item8, item9, item10, item11 )
                    VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE', detail_codempid, q_numgrup,
                             '', q_desgrup, '', '', '', '' );

        r_numseq := r_numseq + 1;
        numanswer := 0;

        FOR r2 in c_question LOOP
            v_qtyfscor  := r2.qtyfscor;
            v_desitem   := r2.desitem;
            v_definit   := r2.definit;
            v_numitem   := r2.numitem;
            v_qtywgt    := r2.qtywgt;

            if v_type = 'main' then
                BEGIN
                    SELECT numitem, qtyscor, grdscor
                      INTO tappbati_numitem, tappbati_qtyscor, tappbati_grdscor
                      FROM tappbati
                     WHERE codempid = detail_codempid
                       and dteduepr = p_dteduepr
                       AND numgrup = q_numgrup
                       AND numtime = detail_numtime
                       AND numseq = detail_numseq
                       AND numitem = v_numitem;
                EXCEPTION WHEN no_data_found THEN
                    tappbati_numitem := 0;
                    tappbati_qtyscor := 0;
                    tappbati_grdscor := '';
                END;
            else
                tappbati_numitem := '';
                tappbati_qtyscor := '';
                tappbati_grdscor := '';
            end if;

            INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                   item5, item6, item7, item8, item9,
                                   item10, item11 )
                          VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE', detail_codempid,
                                   '', v_numitem, v_desitem, v_definit, v_qtywgt,
                                   tappbati_grdscor, tappbati_qtyscor );

            v_pointsum  := v_pointsum + tappbati_qtyscor;
            r_numseq    := r_numseq + 1;
            numanswer   := numanswer + 1;
        END LOOP;
      END LOOP;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                             item5, item6, item7, item8, item9,
                             item10, item11 )
                    VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE', detail_codempid,
                             '', '', get_label_name('HRPM37X3', global_v_lang, 180), '', '',
                             '', v_pointsum );
      r_numseq := r_numseq + 1;
  END get_detail_report;

  PROCEDURE get_detail_report_forms IS
      json_output         CLOB;
      cursorquestion      SYS_REFCURSOR;
      cursoranswer        SYS_REFCURSOR;
      v_codform           tproasgh.codform%TYPE;
      q_codform           tintvews.codform%TYPE;
      q_numgrup           tintvews.numgrup%TYPE;
      q_desgrupt          tintvews.desgrupt%TYPE;
      q_qtyfscor          tintvews.qtyfscor%TYPE;
      v_maxscore          NUMBER;
      v_qtywgt            NUMBER;
      obj_data            json_object_t;
      obj_row6            json_object_t;
      numanswer           NUMBER := 0;
      v_qtyfscor          tintvewd.qtyfscor%TYPE;
      v_desitemt          tintvewd.desitemt%TYPE;
      v_numitem           tintvewd.numitem%TYPE;
      obj_col6            json_object_t;
      tappbati_numitem    tappbati.numitem%TYPE;
      v_rcnt              NUMBER := 0;
      obj_row5            json_object_t;
      tappbati_qtyscor    tappbati.qtyscor%TYPE;
      h_codempid          VARCHAR(500);
      h_codpos            VARCHAR(500);
      h_tcenter_level     VARCHAR(500);
      h_tcenter_name      VARCHAR(500);
      h_typproba          VARCHAR(500);
      h_dteefpos_normal   VARCHAR(500);
      h_dteduepr_normal   VARCHAR(500);
      h_dteefpos          VARCHAR(500);
      h_dteduepr          VARCHAR(500);
      assessor_codeval    VARCHAR(500);
      assessor_codpos     VARCHAR(500);
      assessor_pos        VARCHAR(500);
      flgdata_t301        boolean := false;
      flgdata_t302        boolean := false;
      flgdata_t303        boolean := false;
      v_qtyavgwk                NUMBER;
      o_day                     NUMBER;
      o_hr                      NUMBER;
      o_min                     NUMBER;
      o_dhm                     VARCHAR(15 CHAR);
      v_aday                    NUMBER;
      CURSOR t301 IS
          SELECT SUM(qtyday) numleave, typleave
            FROM tleavetr
           WHERE codempid = detail_codempid
             AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework)
        GROUP BY typleave
        ORDER BY typleave;

      CURSOR t302 IS
          SELECT 1 numseq,get_label_name('HRPM31E', global_v_lang, 10) typcolumn,
                 SUM(daylate) qtyday,
                 SUM(qtytlate) qty_sum
            FROM tlateabs
           WHERE codempid = detail_codempid
             AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework)
           UNION
          SELECT 2 numseq,get_label_name('HRPM31E', global_v_lang, 20),
                 SUM(dayearly) qtyday,
                 SUM(qtytearly) qty_sum
            FROM tlateabs
           WHERE codempid = detail_codempid
             AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework)
           UNION
          SELECT 3 numseq,get_label_name('HRPM31E', global_v_lang, 30),
                 SUM(dayabsent) qtyday,
                 SUM(qtytabs) qty_sum
            FROM tlateabs
           WHERE codempid = detail_codempid
             AND dtework BETWEEN nvl(tab3_dtestrt,dtework) AND nvl(tab3_dteend,dtework);

      CURSOR t303 IS
          SELECT TO_CHAR(a.dteeffec, 'dd/mm/yyyy') AS dteeffec,
                 a.codmist,
                 a.desmist1,
                 b.numseq,
                 b.codpunsh,
                 b.typpun,
                 TO_CHAR(b.dtestart, 'dd/mm/yyyy') AS dtestart,
                 TO_CHAR(b.dteend, 'dd/mm/yyyy') AS dteend,
                 b.codempid
            FROM ttmistk   a,
                 ttpunsh   b
           WHERE a.codempid = detail_codempid
             AND a.codempid = b.codempid
             AND a.dteeffec = b.dteeffec
             AND a.staupd IN ( 'C', 'U' )
             AND a.dteeffec BETWEEN nvl(tab3_dtestrt, a.dteeffec) AND nvl(tab3_dteend, a.dteeffec)
        ORDER BY a.dteeffec,
                 b.codpunsh,
                 b.numseq;

  BEGIN
      BEGIN
          SELECT TO_CHAR(dteefpos, 'dd/mm/yyyy') AS dteefpos,
                 TO_CHAR(dteduepr, 'dd/mm/yyyy') AS dteduepr
            INTO h_dteefpos_normal,
                 h_dteduepr_normal
            FROM temploy1
           WHERE codempid = detail_codempid;
      EXCEPTION WHEN no_data_found THEN
          h_dteefpos_normal := NULL;
          h_dteduepr_normal := NULL;
      END;

      h_codempid        := detail_codempid || ' - ' || get_temploy_name(detail_codempid, global_v_lang);
      h_tcenter_level   := hcm_util.get_codcomp_level(detail_codcomp, 1);
      h_tcenter_name    := h_tcenter_level || ' - ' || get_tcenter_name(h_tcenter_level, global_v_lang);
      h_codpos          := detail_codpos || ' - ' || get_tpostn_name(detail_codpos, global_v_lang);
      h_typproba        := get_tlistval_name('NAMTPRO', detail_typproba, global_v_lang);

--      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
--                             item5, item6, item7, item8,
--                             item9,
--                             item10 )
--                    VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'HEAD', detail_codempid, h_codempid,
--                             h_tcenter_name, h_codpos, h_typproba,
--                             TO_CHAR(add_months(TO_DATE(h_dteefpos_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
--                             TO_CHAR(add_months(TO_DATE(h_dteduepr_normal, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy') );

--      r_numseq := r_numseq + 1;
      FOR r2 IN t301 LOOP
          flgdata_t301 := true;
          v_qtyavgwk := func_get_qtyavgwk (detail_codcomp);
          hcm_util.cal_dhm_hm(r2.numleave, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                 item2, item5, item6, item7 )
                        VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE1',
                                 detail_codempid,r2.typleave, get_tleavety_name(r2.typleave, global_v_lang), o_dhm );
          r_numseq := r_numseq + 1;
      END LOOP;

      IF NOT flgdata_t301 THEN
          FOR i IN 1..2 LOOP
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                     item2, item5, item6, item7 )
                            VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE1',
                                     detail_codempid, '', '', '' );
              r_numseq := r_numseq + 1;
          END LOOP;
      END IF;

      FOR i IN t302 LOOP
          flgdata_t302 := true;
          v_qtyavgwk    := func_get_qtyavgwk (detail_codcomp);
          hcm_util.cal_dhm_hm(i.qtyday, 0, 0, v_qtyavgwk, '1', o_day, o_hr, o_min, o_dhm);
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                                 item2, item5, item6, item7 )
                        VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE2',
                                 detail_codempid, i.typcolumn, i.qty_sum, o_dhm );

          r_numseq := r_numseq + 1;
      END LOOP;

      FOR r4 IN t303 LOOP
          flgdata_t303 := true;
          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                 item5,
                                 item6, item7, item8,
                                 item9,
                                 item10,
                                 item11,
                                 item12 )
                        VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE3', detail_codempid,
                                 TO_CHAR(add_months(TO_DATE(r4.dteeffec, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                                 get_tcodec_name('tcodmist', r4.codmist, global_v_lang), r4.desmist1, r4.numseq,
                                 r4.codpunsh || ' - ' || get_tcodec_name('TCODPUNH', r4.codpunsh, global_v_lang),
                                 get_tlistval_name('NAMTPUN', r4.typpun, global_v_lang),
                                 TO_CHAR(add_months(TO_DATE(r4.dtestart, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy'),
                                 TO_CHAR(add_months(TO_DATE(r4.dteend, 'dd/mm/yyyy'), numyearreport * 12), 'dd/mm/yyyy') );
          r_numseq := r_numseq + 1;
      END LOOP;
      IF NOT flgdata_t303 THEN
          FOR i IN 1..2 LOOP
              INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                     item5, item6, item7, item8, item9, item10, item11, item12 )
                            VALUES ( global_v_codempid, 'HRPM31E', r_numseq, 'TABLE3', detail_codempid,
                                     '', '', '', '', '', '', '', '' );
              r_numseq := r_numseq + 1;
          END LOOP;
      END IF;
  END get_detail_report_forms;

  PROCEDURE clear_ttemprpt IS
  BEGIN
      BEGIN
          DELETE FROM ttemprpt
          WHERE
              codempid = global_v_codempid
              AND codapp = 'HRPM31E';

      EXCEPTION
          WHEN OTHERS THEN
              NULL;
      END;
  END clear_ttemprpt;

  function func_get_grade (p_codform IN VARCHAR2,p_grade_item IN NUMBER) RETURN  VARCHAR2 IS
  v_grade		varchar(1);
BEGIN
         begin
             select grad
             into   v_grade
             from   TINTSCOR
             where  grditem  = p_grade_item and codform = p_codform  ;
         exception when no_data_found then
             v_grade := null;
         end;
        RETURN v_grade;
  END func_get_grade;

  function get_max_numtime (p_codempid IN VARCHAR2,p_dteduepr IN date) RETURN  number IS
    v_numtime		number;
  BEGIN
    begin
        select max(numtime)
          into v_numtime
          from tappbath
         where p_codempid = codempid
           and p_dteduepr = dteduepr;
    exception when no_data_found then
        v_numtime := null;
    end;
    RETURN v_numtime;
  END get_max_numtime;

  function get_max_numseq (p_codempid IN VARCHAR2,p_dteduepr IN date, p_numtime number) RETURN  number IS
    v_numseq		number;
  BEGIN
    begin
        select max(numseq)
          into v_numseq
          from tappbath
         where codempid = p_codempid
           and dteduepr = p_dteduepr
           and numtime = p_numtime;
    exception when no_data_found then
        v_numseq := null;
    end;
    RETURN v_numseq;
  END get_max_numseq;


  function func_get_intscor (p_codform IN VARCHAR2) RETURN  json_object_t IS
  intscor		json_object_t;
  obj_data      json_object_t;
  v_rcnt        NUMBER := 0;
  cursor c_intscor is
     select GRDITEM,GRAD,QTYSCOR,
            decode(global_v_lang,
                     101,DESCGRDE,
                     102,DESCGRDT,
                     103,DESCGRD3,
                     104,DESCGRD4,
                     105,DESCGRD5) DESCGRD
     from   TINTSCOR
     where  codform = p_codform  ;
  BEGIN
    intscor := json_object_t();
    FOR r1 IN c_intscor LOOP
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('grditem', r1.GRDITEM);
        obj_data.put('grad', r1.GRAD);
        obj_data.put('qtyscor', r1.QTYSCOR);
        obj_data.put('descgrd', r1.DESCGRD);
        intscor.put(TO_CHAR(v_rcnt - 1), obj_data);
    END LOOP;
    RETURN intscor;
  END func_get_intscor;

  function func_get_choose_ans (
        p_codempid IN temploy1.codempid%type,
        p_dteduepr IN tappbati.dteduepr%type,
        p_numgrup IN tappbati.numgrup%type,
        p_numtime IN tappbati.numtime%type,
        p_numseq IN tappbati.numseq%type,
        p_numitem IN tappbati.numitem%type,
        tappbati_grdscor in OUT tappbati.grdscor%type ,
        tappbati_qtyscor in OUT tappbati.qtyscor%type ) RETURN  boolean IS
  BEGIN
      BEGIN
          SELECT grdscor, qtyscor
            INTO tappbati_grdscor, tappbati_qtyscor
            FROM tappbati
           WHERE codempid = p_codempid
             AND dteduepr = p_dteduepr
             AND numgrup = p_numgrup
             AND numtime = p_numtime
             AND numseq = p_numseq
             AND numitem = p_numitem ;
      EXCEPTION WHEN no_data_found THEN
        tappbati_grdscor := 0;
        tappbati_qtyscor := 0;
      END;
    RETURN true ;
  END func_get_choose_ans;

  function func_get_qtyavgwk (p_codcomp IN temploy1.codcomp%type) RETURN  tcontral.qtyavgwk%type IS
    v_qtyavgwk    temploy1.codcomp%type;
  BEGIN
      BEGIN
          SELECT qtyavgwk
            INTO v_qtyavgwk
            FROM tcontral
           WHERE codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
              AND dteeffec = ( SELECT MAX(dteeffec)
                                 FROM tcontral
                                WHERE codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                  AND dteeffec <= trunc(SYSDATE));
      EXCEPTION WHEN no_data_found THEN
        v_qtyavgwk := NULL;
      END;
    RETURN v_qtyavgwk;
  END func_get_qtyavgwk;

  PROCEDURE insert_tappbath (p_codempid VARCHAR2, p_dteduepr date, p_numtime NUMBER, p_typproba VARCHAR2) IS
      v_msg_to          LONG;
      v_template_to     LONG;
      v_func_appr       VARCHAR2(20);
      v_error           VARCHAR2(20);
      v_stderror        VARCHAR2(20);
      v_numseq          NUMBER := 0;
      v_codcompap       temploy1.codcomp%TYPE;
      v_codposap        temploy1.codpos%TYPE;
      v_data            VARCHAR2(1) := 'N';
      v_lstcheck        VARCHAR2(1) := 'Y';
      v_codcomp         temploy1.codcomp%TYPE;
      v_codempid        temploy1.codempid%TYPE;
      v_approvno        NUMBER := 0;
      v_seqno           NUMBER := 0;
      v_seqappno        NUMBER := 0;
      v_seq             NUMBER;
      v_codcompemp      temploy1.codcomp%TYPE;
      v_codposemp       temploy1.codpos%TYPE;
      v_flgappr         VARCHAR2(1);
      v_chkappr         VARCHAR2(1);
      v_codcompy        tcompny.codcompy%TYPE;
      v_codlinef        VARCHAR2(4);
      v_dteeffec        DATE;
      v_pageno          NUMBER;
      v_rowno           NUMBER;
      v_columnno        NUMBER;
      v_torgprt         VARCHAR2(1) := 'N';
      v_setorg2         VARCHAR2(1) := 'N';
      v_codapman        temploy1.codempid%TYPE;
      v_codcompapr      temploy1.codcomp%TYPE;
      v_codposapr       temploy1.codpos%TYPE;
      v_email           VARCHAR2(50);
      v_coduser         temploy1.coduser%TYPE;
      v_msg             LONG;
      v_codpos          temploy1.codpos%TYPE;
      v_flag            VARCHAR2(4);
      v_num             NUMBER;
      v_numlvl          NUMBER;
      v_numlvlemp       NUMBER;
      v_codform         VARCHAR2(4);-- tproasgh.codform%type;
      v_codeval         tappbath.codeval%type;
      v_compeval        tappbath.compeval%type;
      v_codposeval      tappbath.codposeval%type;
      v_count_appr      number := 0;

    v_codempidh         temploy1.codempid%type:= null;
    last_emphead         varchar2(1):= 'N';

      CURSOR tproasgh IS
          SELECT codcomp, codpos, codempid, codform
            FROM tproasgh
           WHERE v_codcompemp LIKE codcomp  || '%'
             AND v_codposemp LIKE codpos
             AND p_codempid LIKE codempid
             AND p_typproba = typproba
        ORDER BY codempid DESC, codcomp DESC;

      CURSOR c_tproasgn IS
          SELECT numseq, flgappr, codcompap, codposap, codempap
            FROM tproasgn
           WHERE codcomp = v_codcomp
             AND codpos = v_codpos
             AND codempid = v_codempid
             AND typproba = p_typproba
        ORDER BY numseq;

      CURSOR c_codapman IS
          SELECT codempid
            FROM ( SELECT codempid
                     FROM temploy1
                    WHERE codcomp = v_codcompapr
                      AND codpos = v_codposapr
                      AND staemp IN ('1','3')
                    UNION
                   SELECT codempid
                     FROM tsecpos
                    WHERE codcomp = v_codcompapr
                      AND codpos = v_codposapr
                      AND dteeffec <= SYSDATE
                      AND ( nvl(dtecancel, dteend) >= trunc(SYSDATE)
                            OR nvl(dtecancel, dteend) IS NULL ) ) a
--           WHERE a.codempid NOT IN ( SELECT b.codempid
--                                       FROM torgprt2 b
--                                      WHERE b.codempid = a.codempid )
;

      CURSOR c_temphead1 IS
          select replace(codempidh,'%',null) codempidh,
                 replace(codcomph,'%',null) codcomph,
                 replace(codposh,'%',null) codposh
            FROM temphead
           --WHERE codempid = p_codempid
           where codempid = nvl(v_codempidh,p_codempid)
        ORDER BY codempidh;

      CURSOR c_temphead2 IS
          select replace(codempidh,'%',null) codempidh,
                 replace(codcomph,'%',null) codcomph,
                 replace(codposh,'%',null) codposh
            FROM temphead
           WHERE codcomp = v_codcompemp
             AND codpos = v_codposemp
        ORDER BY codcomph, codposh;
  BEGIN

      begin
          select codcomp, codpos, numlvl
            into v_codcompemp, v_codposemp, v_numlvlemp
            from temploy1
           where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
      FOR i IN tproasgh LOOP
          v_codcomp := i.codcomp;
          v_codpos := i.codpos;
          v_codempid := i.codempid;
          v_codform := i.codform;
          EXIT;
      END LOOP;

      FOR i IN c_tproasgn LOOP
--          v_numseq := v_numseq + 1;
          v_numseq := i.numseq;
          IF i.flgappr = '1' THEN
              v_count_appr := 0;
 --<<28/01/2023||SEA-HR2201||redmine680
          if   last_emphead = 'Y' then 
                  if v_codempidh is not null then
                       begin
                          select codcomp, codpos, numlvl
                            into v_codcompemp, v_codposemp, v_numlvlemp
                            from temploy1
                           where codempid = v_codempidh;
                      exception when no_data_found then
                        null;
                      end; 
                end if;
           else
               begin
                  select codcomp, codpos, numlvl
                    into v_codcompemp, v_codposemp, v_numlvlemp
                    from temploy1
                   where codempid = p_codempid;
              exception when no_data_found then
                null;
              end;
           end if;
 -->>28/01/2023||SEA-HR2201||redmine680
              FOR j IN c_temphead1 LOOP
                v_count_appr  := v_count_appr + 1;             
                IF j.codempidh IS NOT NULL THEN
                  v_codeval     := j.codempidh;
                  v_compeval    := null;
                  v_codposeval  := null;
                  v_data        := 'Y';
                ELSE
                  v_codeval     := null;
                  v_compeval    := j.codcomph;
                  v_codposeval  := j.codposh;
                  v_data        := 'Y';
                END IF;
              END LOOP;

              if v_data = 'Y' and v_count_appr > 1 then
                  v_codeval     := null;
                  v_compeval    := null;
                  v_codposeval  := null;
              end if;
              IF v_data <> 'Y' THEN
                  FOR j IN c_temphead2 LOOP
                      IF j.codempidh IS NOT NULL THEN
                          v_codeval     := j.codempidh;
                          v_compeval    := null;
                          v_codposeval  := null;
                          v_data        := 'Y';
                      ELSE
                          v_codeval     := null;
                          v_compeval    := j.codcomph;
                          v_codposeval  := j.codposh;
                          v_data        := 'Y';
                      END IF;
                  END LOOP;
              END IF;
--<<28/01/2023||SEA-HR2201||redmine680
                v_codempidh  := v_codeval; 
                last_emphead  := 'Y';
-->>28/01/2023||SEA-HR2201||redmine680
--flgappr  =1-emp.head

          ELSIF i.flgappr = '2' THEN
              v_codeval     := null;
              v_compeval    := i.codcompap;
              v_codposeval  := i.codposap;
--<<28/01/2023||SEA-HR2201||redmine680          
                last_emphead  := 'N';
                v_codempidh  := null;
-->>28/01/2023||SEA-HR2201||redmine680
          ELSIF i.flgappr = '3' THEN
              v_codeval     := i.codempap;
              v_compeval    := null;
              v_codposeval  := null;
--<<28/01/2023||SEA-HR2201||redmine680          
                last_emphead  := 'N';
                v_codempidh  := null;
-->>28/01/2023||SEA-HR2201||redmine680
          END IF;

--in sert_temp2('HRPM31E','HRPM31E',v_numseq,'i.flgappr='||i.flgappr,'v_codeval='||v_codeval,'v_compeval='||v_compeval,'v_codposeval='||v_codposeval,null,null,null,null,null);
          begin
              INSERT INTO tappbath (codempid, dteduepr, numtime, numseq, codeval,
                                    codform, codcomp, compeval,codposeval, dtecreate,codcreate)
                   VALUES ( p_codempid, p_dteduepr, p_numtime, v_numseq, v_codeval,
                            v_codform, v_codcomp, v_compeval, v_codposeval, sysdate, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end ;
      END LOOP;
  END;

  PROCEDURE get_codevallist ( json_str_input IN CLOB, json_str_output OUT CLOB) AS

  BEGIN
      initial_value(json_str_input);
      IF param_msg_error IS NULL THEN
          gen_codevallist(json_str_output);
      ELSE
          json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      END IF;
  EXCEPTION WHEN OTHERS THEN
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_codevallist;

  PROCEDURE gen_codevallist ( json_str_output OUT CLOB ) AS
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_rcnt      number := 0;
    cursor c_tappbath is
        select numtime,numseq,dteeval,codeval,qtyscor,codrespr
          from tappbath
         where codempid = p_codempid_query
           and dteduepr = p_dteduepr
           and numtime = p_numtime
           order by numtime, numseq;
  BEGIN
      obj_row := json_object_t();
      FOR r1 IN c_tappbath LOOP
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numtime', r1.numtime);
          obj_data.put('numseq', r1.numseq);
          obj_data.put('dteeval', to_char(r1.dteeval,'dd/mm/yyyy'));
          obj_data.put('codeval', r1.codeval);
          obj_data.put('desc_codeval', get_temploy_name(r1.codeval, global_v_lang));
          obj_data.put('qtyscor', to_char(r1.qtyscor,'fm990.00'));--User37 #5188 Final Test Phase 1 V11 26/02/2021 r1.qtyscor);
          obj_data.put('desc_codrespr',get_tlistval_name('CODRESPR', r1.codrespr, global_v_lang));
          obj_row.put(TO_CHAR(v_rcnt - 1), obj_data);
      END LOOP;
      dbms_lob.createtemporary(json_str_output, true);
      obj_row.to_clob(json_str_output);
  END gen_codevallist;

  PROCEDURE getDetailPopup (json_str_input IN CLOB, json_str_output OUT CLOB) IS
      json_obj json_object_t;
  BEGIN
      initial_value(json_str_input);
      gendetailPopup(json_str_output);
  END getDetailPopup;


  PROCEDURE genDetailPopup (json_str_output OUT CLOB) IS
      v_min_qtyscor             tproasgh.qtyscor%type;
      v_codform                 tproasgh.codform%type;
      v_numtime                 number;
      v_numtimeeva              number;
      v_numseq                  NUMBER;
      v_display_codeval         tappbath.codeval%TYPE;

      v_qcodform                tintvews.codform%TYPE;
      v_qnumgrup                tintvews.numgrup%TYPE;
      v_qdesgrupt               tintvews.desgrupt%TYPE;
      v_qqtyfscor               tintvews.qtyfscor%TYPE;

      v_numanswer               NUMBER := 0;
      v_numquestion             NUMBER := 0;
      v_flg_ans                 boolean;
      v_grdscor                 tappbati.grdscor%type;
      v_qtyscor                 tappbati.qtyscor%type;
      v_rcnt                    NUMBER := 0;
      obj_data                  json_object_t;
      obj_question_row          json_object_t;
      obj_question              json_object_t;
      obj_row2                  json_object_t;
      obj_row3                  json_object_t;
      obj_row4                  json_object_t;
      obj_row5                  json_object_t;

      obj_summary               json_object_t;
      obj_data_tappbath         json_object_t;
      obj_flgCollapse           json_object_t;
      obj_pinCollapse           json_object_t;
      obj_data_modal            json_object_t;

      obj_detail                json_object_t;
      obj_ttprobatd             json_object_t;
      obj_row_ttprobatd         json_object_t;
      v_qtyavgwk                NUMBER;
      o_day                     NUMBER;
      o_hr                      NUMBER;
      o_min                     NUMBER;
      o_dhm                     VARCHAR(15 CHAR);
      v_aday                    NUMBER;

      count_ttprobat            NUMBER;

      val_flgappr               tproasgn.flgappr%TYPE;
      val_codcompap             tproasgn.codcompap%TYPE;
      val_codposap              tproasgn.codposap%TYPE;
      val_codempap              tproasgn.codempap%TYPE;
      val_qtymax                NUMBER;
      tproasgn_numseq           NUMBER;
      max_numseq                NUMBER;
      max_numseq_complete       NUMBER;
      max_numseq_of_max_numtime NUMBER;
      max_numtime               NUMBER;
      v_counttappbath           NUMBER := 0;
      v_counttproasgh           NUMBER := 0;

      pm_qtyscor                tappbath.qtyscor%TYPE;
      pm_codempid               tappbath.codempid%TYPE;
      pm_dteduepr               tappbath.dteduepr%TYPE;
      pm_numtime                tappbath.numtime%TYPE;
      pm_numseq                 tappbath.numseq%TYPE;
      pm_codeval                tappbath.codeval%TYPE;
      pm_dteeval                tappbath.dteeval%TYPE;
      pm_codform                tappbath.codform%TYPE;
      pm_commboss               tappbath.commboss%TYPE;
      pm_flgappr                tappbath.flgappr%TYPE;
      pm_codcomp                tappbath.codcomp%TYPE;
      pm_codrespr               tappbath.codrespr%TYPE;
      pm_qtyexpand              tappbath.qtyexpand%TYPE;
      pm_codexemp               tappbath.codexemp%TYPE;
      pm_desnote                tappbath.desnote%TYPE;

      max_numtime_37x           NUMBER;
      max_numseq_37x            NUMBER;
      v_btnDisable              boolean;
--      v_codappr2                ttprobat.codappr2%type;
      v_codappr2                ttprobat.codappr%type;
      v_lcodrespr               tappbath.codrespr%TYPE;
      v_lflgappr                tappbath.flgappr%TYPE;

      m_codcomp                 temploy1.codcomp%TYPE;
      m_codpos                  temploy1.codcomp%TYPE;
      m_codjob                  temploy1.codcomp%TYPE;
      m_codempmt                temploy1.codcomp%TYPE;
      m_typemp                  temploy1.codcomp%TYPE;
      m_dteempmt                temploy1.codcomp%TYPE;
      m_date2                   DATE;
      m_dteduepr                temploy1.dteduepr%TYPE;

      v_flgrepos                tappbath.flgrepos%TYPE;
      v_staeval                 tappbath.staeval%TYPE;

      v_count_numseq            number;
      v_last_dteeval            date;
      v_qtyday                  tproasgh.qtyday%type;
      v_typscore                tproasgh.typscore%type;
      v_beforescore             tappbath.qtyscor%type;
      v_sendmail_disable        boolean;
      v_count_ttprobat          number;
      v_max_complete            number;
      v_codempcondition         varchar2(4000);
      v_codeval_disable         boolean;
      v_flgdisable              boolean := true;
      v_dteempmt                temploy1.dteempmt%type;

  BEGIN

      begin
        select (dteduepr - DTEEMPMT) +1
          into v_aday
          from TEMPLOY1
         where CODEMPID = p_codempid_query;
      exception when no_data_found then
        v_aday := null;
      end;

      obj_data_modal := json_object_t();
      IF ( p_typproba = 1 ) THEN
          BEGIN
              SELECT codcomp, codpos, codjob, codempmt,
                     typemp, dtereemp, dteduepr, dteempmt
                INTO m_codcomp, m_codpos, m_codjob, m_codempmt,
                     m_typemp, m_date2, m_dteduepr, v_dteempmt
                FROM temploy1
               WHERE codempid = p_codempid_query;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
              m_date2       := NULL;
          END;
      ELSE
          BEGIN
              SELECT codcomp, codpos, codjob,
                     codempmt, typemp, dteeffec, null,
                     (dteduepr - dteeffec) + 1,p_modal_dteeffec
                INTO m_codcomp, m_codpos, m_codjob,
                     m_codempmt, m_typemp, m_dteduepr, v_dteempmt,
                     v_aday,v_dteempmt
                FROM ttmovemt
               WHERE codempid = p_codempid_query
                 AND dteeffec = p_modal_dteeffec
                 AND numseq = p_modal_numseq;
          EXCEPTION WHEN no_data_found THEN
              m_codcomp     := NULL;
              m_codpos      := NULL;
              m_codjob      := NULL;
              m_codempmt    := NULL;
              m_typemp      := NULL;
          END;
      END IF;

      obj_data_modal.put('coderror', '200');
      obj_data_modal.put('codempid', p_codempid_query);
      obj_data_modal.put('desc_codempid', get_temploy_name(p_codempid_query, global_v_lang));
      obj_data_modal.put('desc_codcomp', get_tcenter_name(m_codcomp, global_v_lang));
      obj_data_modal.put('desc_codpos', get_tpostn_name(m_codpos, global_v_lang));
      obj_data_modal.put('desc_codjob', get_tjobcode_name(m_codjob, global_v_lang));
      obj_data_modal.put('desc_codempmt', get_tcodec_name('TCODEMPL', m_codempmt, global_v_lang));
      obj_data_modal.put('desc_typemp', get_tcodec_name('TCODCATG', m_typemp, global_v_lang));
      obj_data_modal.put('dtereemp', TO_CHAR(m_date2, 'dd/mm/yyyy'));
      obj_data_modal.put('dteduepr', TO_CHAR(p_dteduepr, 'dd/mm/yyyy'));
      obj_data_modal.put('desc_typproba',get_tlistval_name('NAMTPRO', p_typproba, global_v_lang));
      obj_data_modal.put('dteempmt', to_char(v_dteempmt,'dd/mm/yyyy'));
      obj_data_modal.put('day_probation', v_aday);

      dbms_lob.createtemporary(json_str_output, true);
      obj_data_modal.to_clob(json_str_output);
  END genDetailPopup;

END HRPM31E;

/

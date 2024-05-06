--------------------------------------------------------
--  DDL for Package Body HRCO06E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO06E" AS
--user14  18/03/2021
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
--   v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codlegald         := hcm_util.get_string_t(json_obj, 'p_codlegald');
    p_typcode           := hcm_util.get_string_t(json_obj, 'p_typcode');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) is
    obj_row            json_object_t := json_object_t();
    obj_data           json_object_t;
    v_rcnt             number  := 0;
    v_table            varchar2(100 char);
    v_cursor_id        integer;
    v_col              number;
    v_count            number := 0;
    v_desctab          dbms_sql.desc_tab;
    v_stmt             varchar2(4000 char);

    v_varchar2       varchar2(4000 char);
    v_number         number;
    v_date           date;
    v_fetch          integer;
    v_col_num        number := 0;

    type table_cursor is ref cursor;
    hrco06e_cursor    table_cursor;

    v_codcodec  varchar2(200 char);
    v_descod    varchar2(200 char);
    v_descode   varchar2(200 char);
    v_descodt   varchar2(200 char);
    v_descod3   varchar2(200 char);
    v_descod4   varchar2(200 char);
    v_descod5   varchar2(200 char);
    cursor c1 is
      select typcode,tablename,destyp3,destyp4,destyp5,destype,destypt,
             decode( global_v_lang,'101',destype,
                                   '102',destypt,
                                   '103',destyp3,
                                   '104',destyp4,
                                   '105',destyp5) destyp
        from ttypcode
       order by typcode asc;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;

    for r1 in c1 loop
      v_rcnt          := v_rcnt+1;
      obj_data        := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('typcode', r1.typcode);
      obj_data.put('desc_typcode', r1.destyp);
      obj_data.put('desc_typcodee', r1.destype);
      obj_data.put('desc_typcodet', r1.destypt);
      obj_data.put('desc_typcode3', r1.destyp3);
      obj_data.put('desc_typcode4', r1.destyp4);
      obj_data.put('desc_typcode5', r1.destyp5);
      obj_data.put('tablename', r1.tablename);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure gen_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number  := 0;
    v_table         varchar2(100 char);
    v_cursor_id     integer;
    v_col           number;
    v_count         number := 0;
    v_desctab       dbms_sql.desc_tab;
    v_stmt          varchar2(4000 char);
    v_varchar2      varchar2(4000 char);
    v_number        number;
    v_date          date;
    v_fetch         integer;
    v_col_num       number := 0;
    v_extra_col     varchar2(200 char) := '';
    v_extra_col2     varchar2(200 char) := '';

  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    begin
      select tablename into v_table
      from ttypcode
      where typcode = p_typcode;
    exception when no_data_found then
      v_table := '';
    end;
    v_rcnt          := v_rcnt+1;
    obj_data        := json_object_t();
    if p_typcode = 'MV' then
      v_extra_col := 'a.typmove,';
    end if;
--
--    --09/12/2020
--    if p_typcode in ('SZ','TUNT') then
--      v_extra_col2 := 'a.flgactive flgact , ';
--    else
--      v_extra_col2 := 'a.flgact, ';
--    end if;
--    --09/12/2020
     v_extra_col2 := 'a.flgact, ';

    v_stmt := ' select  a.codcodec, to_char(a.flgcorr) flgcorr ,'||v_extra_col2||'a.descode,a.descodt,a.descod3,a.descod4,a.descod5,'||v_extra_col||
                        'decode( '||global_v_lang||',''101'',a.descode,
                                ''102'',a.descode,
                                ''103'',a.descod3,
                                ''104'',a.descod4,
                                ''105'',a.descod5,null) descod
                from ' || v_table || ' a order by a.codcodec';

    begin
      v_cursor_id := dbms_sql.open_cursor;
      dbms_output.put_line(v_cursor_id);
      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);


      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);
      for i in 1 .. v_col loop
        if v_desctab(i).col_type = 1 then
          dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
        elsif v_desctab(i).col_type = 2 then
          dbms_sql.define_column(v_cursor_id, i, v_number);
        elsif v_desctab(i).col_type = 12 then
          dbms_sql.define_column(v_cursor_id, i, v_date);
        end if;
      end loop;
      v_fetch := dbms_sql.execute(v_cursor_id);

      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
        obj_data := json_object_t();
        dbms_sql.column_value(v_cursor_id, 1, v_codcodec);
        obj_data.put('codcodec',v_codcodec);
        dbms_sql.column_value(v_cursor_id, 2, v_flgcorr);
        obj_data.put('flgcorr',v_flgcorr);
        dbms_sql.column_value(v_cursor_id, 3, v_flgact);
        obj_data.put('flgact',v_flgact);
        dbms_sql.column_value(v_cursor_id, 4, v_descode);
        obj_data.put('descode',v_descode);
        dbms_sql.column_value(v_cursor_id, 5, v_descodt);
        obj_data.put('descodt',v_descodt);
        dbms_sql.column_value(v_cursor_id, 6, v_descod3);
        obj_data.put('descod3',v_descod3);
        dbms_sql.column_value(v_cursor_id, 7, v_descod4);
        obj_data.put('descod4',v_descod4);
        dbms_sql.column_value(v_cursor_id, 8, v_descod5);
        obj_data.put('descod5',v_descod5);
        if p_typcode = 'MV' then
          dbms_sql.column_value(v_cursor_id, 9, v_typmove);
          obj_data.put('typmove',v_typmove);
          dbms_sql.column_value(v_cursor_id, 10, v_descod);
          obj_data.put('descod',v_descod);
        else
          dbms_sql.column_value(v_cursor_id, 9, v_descod);
          obj_data.put('descod',v_descod);
        end if;

        obj_data.put('desc_flgact',get_tlistval_name('STACODEC' ,v_flgact, global_v_lang ) );
        obj_data.put('desc_typmove',get_tlistval_name('TYPMOVE' ,v_typmove, global_v_lang ) );
        obj_data.put('typcode',p_typcode);
        obj_data.put('tablename',v_table );
        obj_data.put('coderror','200');
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end loop;
       dbms_sql.close_cursor(v_cursor_id);
      exception when others then
        if dbms_sql.is_open(v_cursor_id) then
          dbms_sql.close_cursor(v_cursor_id);
        end if;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;
    json_str_output := obj_row.to_clob;
  end gen_detail;

  procedure check_del_detail(p_codcodec varchar2) as
    v_chk               number := 0;
  begin

           if  p_typcode = 'AG' then --
                  begin
                    select count(*)
                      into v_chk
                      from taplvl
                     where codaplvl = p_codcodec;
                  end;
                  ---
                  if v_chk = 0 then
                      begin
                        select count(*)
                          into v_chk
                          from tattpreh
                         where codaplvl = p_codcodec;
                      end;
                  end if;
                  ---
                  if v_chk = 0 then
                      begin
                        select count(*)
                          into v_chk
                          from tstdisd
                         where codaplvl = p_codcodec;
                      end;
                  end if;
                  ---
                    if v_chk = 0 then
                      begin
                        select count(*)
                          into v_chk
                          from tappfm
                         where codaplvl = p_codcodec;
                      end;
                  end if;
               --------------------------------------------------------------
                elsif p_typcode = 'AL' then
                    begin
                        select count(*)
                          into v_chk
                          from TWKCHHR
                         where CODCHNG = p_codcodec;
                      end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TATTENCE
                             where CODCHNG = p_codcodec;
                          end;
                      end if;
               --------------------------------------------------------------
                elsif p_typcode = 'AP' then
                      begin
                        select count(*)
                          into v_chk
                          from TAPPOINF
                         where TYPAPPTY = p_codcodec;
                      end;
               --------------------------------------------------------------
                elsif p_typcode = 'AS' then
                     begin
                        select count(*)
                          into v_chk
                          from tassetreq
                         where TYPASSET = p_codcodec;
                      end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TASETINF
                             where TYPASSET = p_codcodec;
                          end;
                      end if;
               --------------------------------------------------------------
                elsif p_typcode = 'AW' then
                     begin
                        select count(*)
                          into v_chk
                          from tcontraw
                         where CODAWARD = p_codcodec;
                      end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from tempawrd
                             where CODAWARD = p_codcodec;
                          end;
                      end if;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from tempawrd2
                             where CODAWARD = p_codcodec;
                          end;
                      end if;
               --------------------------------------------------------------
                elsif p_typcode = 'BF' then
                      begin
                        select count(*)
                          into v_chk
                          from tclnsinf
                         where CODDC = p_codcodec;
                      end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TMEDREQ
                             where CODDC = p_codcodec;
                          end;
                      end if;
                      ---
                elsif p_typcode = 'BK' then     null;
                      begin
                        select count(*)
                          into v_chk
                          from TEMPLOY3
                         where CODBANK = p_codcodec;
                      end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY3
                             where CODBANK2 = p_codcodec;
                          end;
                      end if;

                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from tbnkmdi2
                             where CODBANK = p_codcodec;
                          end;
                      end if;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where CODBANK = p_codcodec;
                          end;
                      end if;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where CODBANK2 = p_codcodec;
                          end;
                      end if;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR2
                             where CODBANK = p_codcodec;
                          end;
                      end if;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR2
                             where CODBANK2 = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'BN' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODBUSNO = p_codcodec;
                    end;
                elsif p_typcode = 'BO' then
                    begin
                        select count(*)
                          into v_chk
                          from tbonparh
                         where CODBON = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from tbonus
                             where CODBON = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'BR' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODBUSRT = p_codcodec;
                    end;
                elsif p_typcode = 'CE' then
                    begin
                        select count(*)
                          into v_chk
                          from TTRNEEDP
                         where CODCATE = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TYRTRSCH
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVCOURSE
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TIDPPLANS
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCOURSE
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TYRTRPLN
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TBASICTP
                             where CODCATE = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTSET
                             where CODCATEXM = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVTEST
                             where CODCATEXM = p_codcodec;
                          end;
                      end if;
--                elsif p_typcode = 'CF' then
--                    begin
--                        select count(*)
--                          into v_chk
--                          from TREFREQ
--                         where TYPCERTIF = p_codcodec;
--                    end;
                elsif p_typcode = 'CG' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where TYPEMP = p_codcodec ;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                              where TYPEMP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where (TYPEMP = p_codcodec or TYPEMPT = p_codcodec);
                          end;
                      end if;
                elsif p_typcode = 'CL' then
                    begin
                        select count(*)
                          into v_chk
                          from TLOANREQ2
                         where CODCOLLA = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLOANCOL
                             where CODCOLLA = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'CP' then
                    begin
                        select count(*)
                          into v_chk
                          from TCOMPLN
                         where TYPCOMPL = p_codcodec;
                    end;
                elsif p_typcode = 'CR' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODCURR = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY3
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTNEWEMP
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR2
                             where CODCURR = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'CS' then
                    begin
                        select count(*)
                          into v_chk
                          from TREPLACERQ
                         where CODCHGSH = p_codcodec;
                    end;
                elsif p_typcode = 'CT' then
                     begin
                        select count(*)
                          into v_chk
                          from TEMPLOY2
                         where (CODCNTYC = p_codcodec or CODCNTYR = p_codcodec) ;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPLINF
                             where (CODCNTYC = p_codcodec or CODCNTYI = p_codcodec) ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TGRPCNTY
                             where CODCNTY = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEDUCATN
                             where CODCOUNT = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRAVINF
                             where CODCNTY = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRAVREQ
                             where CODCNTY = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSTEDU
                             where CODCNTY = p_codcodec ;
                          end;
                     end if;
                elsif p_typcode = 'CX' then
                     begin
                        select count(*)
                          into v_chk
                          from TVSUBJECT
                         where CODCATEXM = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVCHAPTER
                             where CODCATEXM = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVTEST
                             where CODCATEXM = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTSET
                             where CODCATEXM = p_codcodec ;
                          end;
                     end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVCOURSE
                             where (CODCATPRE = p_codcodec or CODCATPO = p_codcodec);
                          end;
                     end if;
                elsif p_typcode = 'DG' then
                    begin
                        select count(*)
                          into v_chk
                          from TEDUCATN
                         where CODDGLV = p_codcodec;
                    end;
                elsif p_typcode = 'DP' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where TYPDISP = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY1
                             where TYPDISP = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'DT' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPDEV
                         where CODDEVP = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPDEVF
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCOMPTDEV
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCOURSE
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TIDPCPTCD
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPOSEMPDEV
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPOSEMPDV
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSUCCDEV
                             where CODDEVP = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'ED' then
                    begin
                        select count(*)
                          into v_chk
                          from TCHILDRN
                         where CODEDLV = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEDUCATN
                             where CODEDLV = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TJOBEDUC
                             where CODEDLV = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY1
                             where CODEDLV = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSTEDU
                             where CODEDLV = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'EM' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPOINF
                         where CODEXAM = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEXAMPOS
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEXAMSQH
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISCLSS
                             where (CODEXAMPO = p_codcodec or CODEXAMPR = p_codcodec);
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLRNCHAP
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLRNCOURSE
                             where (CODEXAMPO = p_codcodec or CODEXAMPR = p_codcodec);
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLRNSUBJ
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTCHK
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTCHK
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTEMP
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTEMPD
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTOTR1
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTRCR1
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTRCR2
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTSET
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTSETD
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTESTTRR1
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
-- SA  พี่บอล เเจ้งว่า ไม่ได้ใช้เเล้ว 16/03/2021
--                    if v_chk = 0 then
--                          begin
--                            select count(*)
--                              into v_chk
--                              from TTRTESTD
--                             where CODEXAM = p_codcodec;
--                          end;
--                    end if;
--                    if v_chk = 0 then
--                          begin
--                            select count(*)
--                              into v_chk
--                              from TTRTESTD2
--                             where CODEXAM = p_codcodec;
--                          end;
--                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRTESTH
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVCHAPTER
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVCOURSE
                             where (CODEXAMPO = p_codcodec or CODEXAMPR = p_codcodec);
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVQUEST
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVQUESTD1
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVQUESTD2
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVSUBJECT
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TVTEST
                             where CODEXAM = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TYRTRSCH
                             where (CODEXAMPO = p_codcodec or CODEXAMPR = p_codcodec);
                          end;
                    end if;
                elsif p_typcode = 'EX' then
                   begin
                        select count(*)
                          into v_chk
                          from TTEXEMPT
                         where CODEXEMP = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTREHIRE
                             where CODEXEMP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TBCKLST
                             where CODEXEMP = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFREGST
                             where CODRETI = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFMEMB
                             where CODRETI = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFMEMRQ
                             where CODRETI = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'FP' then
                    begin
                        select count(*)
                          into v_chk
                          from TPFMEMB
                         where CODPLAN = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFIRINF
                             where CODPLAN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFREGST
                             where CODPLAN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFPCINF
                             where CODPLAN = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'FX' then
                    begin
                        select count(*)
                          into v_chk
                          from tshiftcd
                         where grpshift = p_codcodec;
                    end;
                elsif p_typcode = 'GA' then
                    begin
                        select count(*)
                          into v_chk
                          from tglhtabi
                         where apgrpcod = p_codcodec;
                    end;
                elsif p_typcode = 'GB' then
                    begin
                        select count(*)
                          into v_chk
                          from ttbudsal
                         where codgrbug = p_codcodec;
                    end;
                elsif p_typcode = 'GC' then
                    begin
                        select count(*)
                          into v_chk
                          from THISORG
                         where CODCOMPY = p_codcodec
                         and nvl(FLGGROUP,'N') = 'Y';
                    end;
                elsif p_typcode = 'GL' then
                     begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODGRPGL = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where CODGRPGL = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where CODGRPGL = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTEXEMPT
                             where CODGRPGL = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMISTK
                             where CODGRPGL = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'GPC' then
                    begin
                        select count(*)
                          into v_chk
                          from tpriodal
                         where grpcodpay = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPRIODALGP
                             where grpcodpay = p_codcodec;
                          end;
                      end if;

                elsif p_typcode = 'GR' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODCALEN = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTPMINF
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TGRPPLAN
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TGRPWORK
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TGRPYEAR
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TATTENCE
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TMANPWH
                             where CODCALEN = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'HL' then
                    begin
                        select count(*)
                          into v_chk
                          from THEALRQ1
                         where CODHEAL = p_codcodec;
                    end;

                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THEALINF2
                             where CODHEAL = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THEALCDE2
                             where CODHEAL = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'IN' then
                    begin
                        select count(*)
                          into v_chk
                          from TEDUCATN
                         where CODINST = p_codcodec;
                    end;
                elsif p_typcode = 'JG' then
                    begin
                        select count(*)
                          into v_chk
                          from TTPMINF
                         where JOBGRADE = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY1
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSALSTR
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TMANPWH
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPRAIS
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TBONUS
                             where JOBGRADE = p_codcodec;
                          end;
                    end if;
                elsif p_typcode = 'JM' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODMEDIA = p_codcodec;
                    end;
                elsif p_typcode = 'JN' then
                    begin
                        select count(*)
                          into v_chk
                          from TJOBPOSTE
                         where codjobpost = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TJOBPOST
                             where codjobpost = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'JO' then
                    begin
                        select count(*)
                          into v_chk
                          from tgrppos
                         where codgrpos = p_codcodec;
                    end;
                elsif p_typcode = 'LA' then
                     begin
                        select count(*)
                          into v_chk
                          from TLANGABI
                         where CODLANG = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLANGUAGE
                             where CODLANG = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'LE' then
                    begin
                        select count(*)
                          into v_chk
                          from TLEGALEXE
                         where CODLEGALD = p_codcodec;
                    end;
                elsif p_typcode = 'LG' then
                     begin
                        select count(*)
                          into v_chk
                          from TCMPTNCY
                         where CODTENCY = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TJOBPOSSKIL
                             where CODTENCY = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPOSEMPC
                             where CODTENCY = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSUCCMPC
                             where CODTENCY = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRNEEDC
                             where CODTENCY = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TIDPCPTC
                             where CODTENCY = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'LO' then
                     begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODBRLC = p_codcodec;
                    end;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPLINF
                             where (CODBRLC1 = p_codcodec or CODBRLC2 = p_codcodec or CODBRLC3 = p_codcodec);
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCODSOC
                             where CODBRLC = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where CODBRLC = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where CODBRLC = p_codcodec;
                          end;
                      end if;
                    if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where CODBRLC = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'MI' then
                     begin
                        select count(*)
                          into v_chk
                          from TTMISTK
                         where CODMIST = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMIST
                             where CODMIST = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'MS' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODMAJSB = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEDUCATN
                             where CODMAJSB = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TJOBEDUC
                             where CODMAJSB = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'MV' then
                    begin
                        select count(*)
                          into v_chk
                          from TTPMINF
                         where CODTRN = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where CODTRN = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTMOVEMT
                             where CODTRN = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRANPM
                             where CODTRN = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPRAIS
                             where CODTRN = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'NT' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODORGIN = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY2
                             where CODORGIN = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TFAMILY
                             where (CODFNATN = p_codcodec or CODMNATN = p_codcodec);
                          end;
                      end if;
                elsif p_typcode = 'OC' then
                     begin
                        select count(*)
                          into v_chk
                          from TAPPLREF
                         where CODOCCUP = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TGUARNTR
                             where CODOCCUP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISGUARN
                             where CODOCCUP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TFAMILY
                             where (CODFOCCU = p_codcodec or CODMOCCU = p_codcodec);
                          end;
                      end if;
                elsif p_typcode = 'OR' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODORGIN = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY2
                             where CODORGIN = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TFAMILY
                             where (CODFRELG = p_codcodec or CODMRELG = p_codcodec);
                          end;
                      end if;
                elsif p_typcode = 'OT' then
                    begin
                        select count(*)
                          into v_chk
                          from TOTREQST
                         where codrem = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TOVRTIME
                             where codrem = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTOTREQST
                             where codrem = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTOTREQ
                             where codrem = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'PC' then
                    begin
                        select count(*)
                          into v_chk
                          from TCOMPPLCY
                         where CODPLCY = p_codcodec;
                    end;
                elsif p_typcode = 'PF' then
                    begin
                        select count(*)
                          into v_chk
                          from TPFPAY
                         where CODPFINF = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFMEMB
                             where CODPFINF = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFIRINF
                             where CODPFINF = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFREGST
                             where CODPFINF = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFPHINF
                             where CODPFINF = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFPCINF
                             where CODPFINF = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'PN' then
                    begin
                        select count(*)
                          into v_chk
                          from TPFPCINF
                         where CODPOLICY = p_codcodec;
                    end;
                elsif p_typcode = 'PU' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPEMPMT
                         where CODPUNSH = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TATTPRE3
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TATTPRE4
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TFHISPUN
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISPUN
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISPUND
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTPUNDED
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTPUNSH
                             where CODPUNSH = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'PV' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODPROV = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY2
                             where CODDOMCL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCLNINF
                             where CODPROVR = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THOTELIF
                             where CODPROVR = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSTITU
                             where CODPROVR = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSTRUC
                             where CODPROVR = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'PY' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where TYPPAYROLL = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLOANINF
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPFMEMB
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISMOVE
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTPMINF
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TPAYSUM
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TBONUS
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TOVRTIME
                             where TYPPAYROLL = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'RE' then
                    begin
                        select count(*)
                          into v_chk
                          from TCHKIN
                         where CODREASON = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCHKINRAW
                             where CODREASON = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'RL' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLINF
                         where CODRELGN = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TEMPLOY2
                             where CODRELGN = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'RT' then
                    begin
                        select count(*)
                          into v_chk
                          from TRESREQ
                         where CODEXEMP = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTEXEMPT
                             where CODEXEMP = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'RW' then     null;
                    begin
                        select count(*)
                          into v_chk
                          from THISREWD
                         where TYPREWD = p_codcodec;
                    end;
                elsif p_typcode = 'SB' then     null;
                    begin
                        select count(*)
                          into v_chk
                          from TEDUCATN
                         where CODMINSB = p_codcodec;
                    end;
                elsif p_typcode = 'SIZE' then
                    begin
                        select count(*)
                          into v_chk
                          from TOBFCDE
                         where CODSIZE = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTOBFCDE
                             where CODSIZE = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'ST' then     null;
                    begin
                        select count(*)
                          into v_chk
                          from THOTELSE
                         where CODSERV = p_codcodec;
                    end;
                elsif p_typcode = 'SZ' then
                    begin
                        select count(*)
                          into v_chk
                          from TINSRER
                         where CODISRP = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TISRPRE
                             where CODISRP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TISRPINF
                             where CODISRP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSDINF
                             where CODISRP = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TB' then     null;
                    begin
                        select count(*)
                          into v_chk
                          from TSALARY
                         where CODTYPWRK = p_codcodec;
                    end;
                      ---
                      if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPLWEX
                             where CODTYPWRK = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TD' then
                    begin
                        select count(*)
                          into v_chk
                          from TAPPLDOC
                         where TYPDOC = p_codcodec;
                    end;
                elsif p_typcode = 'TE' then
                    begin
                        select count(*)
                          into v_chk
                          from TEMPLOY1
                         where CODEMPMT = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TAPPLINF
                             where CODEMPMT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCONTPMD
                             where CODEMPMT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TATTENCE
                             where CODEMPMT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTPMINF
                             where CODEMPMT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXCUR
                             where CODEMPMT = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TI' then
                    begin
                        select count(*)
                          into v_chk
                          from TINEXINF
                         where TYPINC = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINCTXPND
                             where TYPINC = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSINCEXP
                             where TYPINC = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXINC
                             where TYPINC = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TP' then
                    begin
                        select count(*)
                          into v_chk
                          from TYTDINC
                         where TYPPAYR = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINEXINF
                             where TYPPAYR = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSINCEXP
                             where TYPPAYR = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TS' then
                    begin
                        select count(*)
                          into v_chk
                          from TCOURSE
                         where CODSUBJ = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCOURSUB
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCRSINST
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from THISINST
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TINSTAPH
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TLRNSUBJ
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRSUBJD
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TYRTRSUBJ
                             where CODSUBJ = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TT' then
                    begin
                        select count(*)
                          into v_chk
                          from TINEXINF
                         where TYPPAYT = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TSINCEXP
                             where TYPPAYT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TYTDINC
                             where TYPPAYT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTAXINC
                             where TYPPAYT = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TUNT' then
                    begin
                        select count(*)
                          into v_chk
                          from TTRAVEXP
                         where CODTRAVUNIT = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRAVINFD
                             where CODTRAVUNIT = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCONTTRAV
                             where CODTRAVUNIT = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'TV' then
                    begin
                        select count(*)
                          into v_chk
                          from TTRAVEXP
                         where CODEXP = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTRAVINFD
                             where CODEXP = p_codcodec;
                          end;
                      end if;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TCONTTRAV
                             where CODEXP = p_codcodec;
                          end;
                      end if;
                elsif p_typcode = 'UN' then
                    begin
                        select count(*)
                          into v_chk
                          from TOBFCDE
                         where CODUNIT = p_codcodec;
                    end;
                     if v_chk = 0 then
                          begin
                            select count(*)
                              into v_chk
                              from TTOBFCDE
                             where CODUNIT = p_codcodec;
                          end;
                      end if;
               --------------------------------------------------------------
                else
                  v_chk := 0;
                end if;

             if v_chk > 0 then
                  param_msg_error := get_error_msg_php('HR1500',global_v_lang);
             end if;


--      end loop;
--    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure check_save_index is
  begin
    if length(v_descode) > 150 or length(v_descodt) > 150 or length(v_descod3) > 150 or length(v_descod4) > 150 or length(v_descod5) > 150 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;

  procedure check_save_detail is
    type v_array IS TABLE OF VARCHAR2(200);
    ais_array v_array;
  begin
    if v_codcodec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcodec');
      return;
    else
      if v_flg = 'add' then
        begin
          v_stmt := 'select codcodec from  ' || v_table || ' Where codcodec = ''' || v_codcodec || ''' ';
          execute immediate v_stmt into v_stmt2;
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,v_table);
        exception when no_data_found then
          return;
        end;
      else
          if v_flg = 'delete' and v_table = 'TCODMOVE' then
              ais_array := v_array('0001','0002','0003','0004','0005','0006','0007');
              if v_codcodec member of ais_array then
                param_msg_error := get_error_msg_php('HR1500',global_v_lang);
              end if;
          end if;
          --check_del_detail;
      end if;
    end if;
  end;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    param_json         json_object_t;
    param_json_row     json_object_t;
    v_stmt2            varchar2(100 char) := '';
    v_stmt3            varchar2(100 char) := '';
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        --
        v_typcode   := hcm_util.get_string_t(param_json_row,'typcode');
        v_descode   := hcm_util.get_string_t(param_json_row,'desc_typcodee');
        v_descodt   := hcm_util.get_string_t(param_json_row,'desc_typcodet');
        v_descod3   := hcm_util.get_string_t(param_json_row,'desc_typcode3');
        v_descod4   := hcm_util.get_string_t(param_json_row,'desc_typcode4');
        v_descod5   := hcm_util.get_string_t(param_json_row,'desc_typcode5');
        v_table     := hcm_util.get_string_t(param_json_row,'tablename');
        v_flg       := hcm_util.get_string_t(param_json_row,'flg');
        check_save_index;

        if param_msg_error is null then
          if v_flg = 'edit' then
            update ttypcode
               set destype = v_descode,
                   destypt = v_descodt,
                   destyp3 = v_descod3,
                   destyp4 = v_descod4,
                   destyp5 = v_descod5
             where typcode = v_typcode
               and tablename = v_table;
          end if;
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
      end loop;
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    param_json         json_object_t;
    param_json_row     json_object_t;
    v_stmt2            varchar2(100 char) := '';
    v_stmt3            varchar2(100 char) := '';
    v_stmt4            varchar2(100 char) := '';--11/12/2020
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      select tablename
      into v_table
      from ttypcode
      where typcode = p_typcode;

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        --
        v_codcodec  := hcm_util.get_string_t(param_json_row,'codcodec');
        v_flgcorr   := hcm_util.get_string_t(param_json_row,'flgcorr');
        v_flgact    := hcm_util.get_string_t(param_json_row,'flgact');
        v_typmove   := hcm_util.get_string_t(param_json_row,'typmove');
        v_descode   := hcm_util.get_string_t(param_json_row,'descode');
        v_descodt   := hcm_util.get_string_t(param_json_row,'descodt');
        v_descod3   := hcm_util.get_string_t(param_json_row,'descod3');
        v_descod4   := hcm_util.get_string_t(param_json_row,'descod4');
        v_descod5   := hcm_util.get_string_t(param_json_row,'descod5');

        v_descode   := replace(v_descode,'''','''''');
        v_descodt   := replace(v_descodt,'''','''''');
        v_descod3   := replace(v_descod3,'''','''''');
        v_descod4   := replace(v_descod4,'''','''''');
        v_descod5   := replace(v_descod5,'''','''''');

        v_flg       := hcm_util.get_string_t(param_json_row,'flg');
        v_stmt2     := '';
        v_stmt3     := '';
        check_save_index;
        if param_msg_error is null then
          if v_flg = 'add' then
            begin
              if v_table = 'TCODMOVE' then
                v_stmt2 := ' , typmove ';
                v_stmt3 := ' , ''M'' ';
              end if;

--              if v_table in ('TCODISRP','TCODTRAVUNIT') then -- table <> flgact >> flgactive
--                v_stmt4 := ' , flgactive ';
--              else
--                v_stmt4 := ' , flgact ';
--              end if;
                v_stmt4 := ' , flgact ';
              --<<User37 Final Test Phase 1 V11 #3610 11/12/2020
              /*v_stmt := 'insert into ' || v_table || '(codcodec, flgcorr, flgact, descode, descodt, descod3, descod4, descod5, dteupd, coduser ' || v_stmt2 || ')
                        values(''' || v_codcodec || ''', ''' || v_flgcorr || ''', ''' || v_flgact || ''', ''' || v_descode || ''',
                        ''' || v_descodt || ''', ''' || v_descod3 || ''', ''' || v_descod4 || ''', ''' || v_descod5 || ''',
                        ''' || TRUNC(sysdate) || ''', ''' || global_v_coduser || ''' ' || v_stmt3 || ') ';*/
           --   v_stmt := 'insert into ' || v_table || '(codcodec, flgcorr, flgact, descode, descodt, descod3, descod4, descod5, dteupd, coduser, codcreate ' || v_stmt2 || ')
                v_stmt := 'insert into ' || v_table || '(codcodec, flgcorr '||v_stmt4||', descode, descodt, descod3, descod4, descod5, dteupd, coduser, codcreate ' || v_stmt2 || ')
                        values(''' || v_codcodec || ''', ''' || v_flgcorr || ''', ''' || v_flgact || ''', ''' || v_descode || ''',
                        ''' || v_descodt || ''', ''' || v_descod3 || ''', ''' || v_descod4 || ''', ''' || v_descod5 || ''',
                        ''' || TRUNC(sysdate) || ''', ''' || global_v_coduser || '' || ''', ''' || global_v_coduser || ''' ' || v_stmt3 || ') ';
              -->>User37 Final Test Phase 1 V11 #3610 11/12/2020
              execute immediate v_stmt ;
            end;
          elsif v_flg = 'edit' then
            begin
              if v_table = 'TCODMOVE' then
                v_stmt2 := ' ,typmove = '''||v_typmove || '''';
              end if;

--              if v_table in ('TCODISRP','TCODTRAVUNIT') then -- table <> flgact >> flgactive
--                v_stmt4 :=  ' ,flgactive = '''||v_flgact || '''';
--              else
--                v_stmt4 :=  ' ,flgact = '''||v_flgact || '''';
--              end if;
               v_stmt4 :=  ' ,flgact = '''||v_flgact || '''';
              --<<User37 Final Test Phase 1 V11 #3610 11/12/2020
              /*v_stmt := 'Update ' || v_table || ' Set
                        flgcorr = ''' || v_flgcorr || ''',
                        flgact = ''' || v_flgact || ''',
                        descode = ''' || v_descode || ''',
                        descodt = ''' || v_descodt || ''',
                        descod3 = ''' || v_descod3 || ''',
                        descod4 = ''' || v_descod4 || ''',
                        descod5 = ''' || v_descod5 || ''''
                        ||v_stmt2||
                        'Where codcodec = ''' || v_codcodec || ''' ';*/
               v_stmt := 'Update ' || v_table || ' Set
                        dteupd = ''' || TRUNC(sysdate) || ''',
                        coduser = ''' || global_v_coduser || ''',
                        flgcorr = ''' || v_flgcorr || ''''
                        ||v_stmt4|| ',
                        descode = ''' || v_descode || ''',
                        descodt = ''' || v_descodt || ''',
                        descod3 = ''' || v_descod3 || ''',
                        descod4 = ''' || v_descod4 || ''',
                        descod5 = ''' || v_descod5 || ''''
                        ||v_stmt2||
                        'Where codcodec = ''' || v_codcodec || ''' ';
               -->>User37 Final Test Phase 1 V11 #3610 11/12/2020
               execute immediate v_stmt;
            end;
          elsif v_flg = 'delete' then
            check_del_detail(v_codcodec);
            if param_msg_error is null then
              begin
                v_stmt := 'Delete from  ' || v_table || ' Where codcodec = ''' || v_codcodec || ''' ';
                execute immediate v_stmt;
              end;
            else
               exit;
            end if;
          end if;

         else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         end if;
      end loop;
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

  end;
--  procedure gen_index(json_str_output out clob) is
--    obj_row            json := json();
--    obj_data           json;
--    obj_row            json_object_t := json_object_t();
--    obj_data           json_object_t;
--    v_rcnt             number  := 0;
--    v_table            varchar2(100 char);
--    v_cursor_id        integer;
--    v_col              number;
--    v_count            number := 0;
--    v_desctab          dbms_sql.desc_tab;
--    v_stmt             varchar2(4000 char);
--    v_varchar2       varchar2(4000 char);
--    v_number         number;
--    v_date           date;
--    v_fetch          integer;
--    v_col_num        number := 0;
--
--  begin
--    obj_row   := json();
--    obj_row   := json_object_t();
--    v_rcnt    := 0;
--
--    select tablename
--      into v_table
--      from ttypcode
--      where typcode = p_typcode;
--    v_stmt := ' select  a.codcodec,a.flgcorr,a.flgact,a.descode,a.descodt,a.descod3,a.descod4,a.descod5,
--                        decode( ''101'',''101'',a.descode,
--                                ''102'',a.descode,
--                                ''103'',a.descod3,
--                                ''104'',a.descod4,
--                                ''105'',a.descod5,null) descod
--                from ' || v_table || ' a order by a.codcodec';
--    begin
--      v_cursor_id := dbms_sql.open_cursor;
--      dbms_output.put_line(v_cursor_id);
--      dbms_sql.parse(v_cursor_id, v_stmt, dbms_sql.native);
--      dbms_sql.describe_columns(v_cursor_id, v_col, v_desctab);
--      for i in 1 .. v_col loop
--        if v_desctab(i).col_type = 1 then
--          dbms_sql.define_column(v_cursor_id, i, v_varchar2, 4000);
--        elsif v_desctab(i).col_type = 2 then
--          dbms_sql.define_column(v_cursor_id, i, v_number);
--        elsif v_desctab(i).col_type = 12 then
--          dbms_sql.define_column(v_cursor_id, i, v_date);
--        end if;
--      end loop;
--
--      v_fetch := dbms_sql.execute(v_cursor_id);
--      while dbms_sql.fetch_rows(v_cursor_id) > 0 loop
--        obj_data := json();
--        obj_data := json_object_t();
--        dbms_sql.column_value(v_cursor_id, 1, v_codcodec);
--        obj_data.put('codcodec',v_codcodec);
--        dbms_sql.column_value(v_cursor_id, 2, v_flgcorr);
--        obj_data.put('flgcorr',v_flgcorr);
--        dbms_sql.column_value(v_cursor_id, 3, v_flgact);
--        obj_data.put('flgact',v_flgact);
--        dbms_sql.column_value(v_cursor_id, 4, v_descode);
--        obj_data.put('descode',v_descode);
--        dbms_sql.column_value(v_cursor_id, 5, v_descodt);
--        obj_data.put('descodt',v_descodt);
--        dbms_sql.column_value(v_cursor_id, 6, v_descod3);
--        obj_data.put('descod3',v_descod3);
--        dbms_sql.column_value(v_cursor_id, 7, v_descod4);
--        obj_data.put('descod4',v_descod4);
--        dbms_sql.column_value(v_cursor_id, 8, v_descod5);
--        obj_data.put('descod5',v_descod5);
--        dbms_sql.column_value(v_cursor_id, 9, v_descod);
--        obj_data.put('descod',v_descod);
--        obj_data.put('desc_flgact',get_tlistval_name('STACODEC' ,v_flgact, global_v_lang ) );
--        obj_data.put('typcode',p_typcode );
--        obj_data.put('coderror','200');
--        obj_row.put(to_char(v_count),obj_data);
--        v_count := v_count + 1;
--      end loop;
--       dbms_sql.close_cursor(v_cursor_id);
--      exception when others then
--        if dbms_sql.is_open(v_cursor_id) then
--            dbms_sql.close_cursor(v_cursor_id);
--        end if;
--        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--    end;
--
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
--    json_str_output := obj_row.to_clob;
--
--  end gen_index;
END HRCO06E;

/

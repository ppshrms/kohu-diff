--------------------------------------------------------
--  DDL for Package Body HRRC1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC1FX" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereqst    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    b_index_dtereqen    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    b_index_numreqst    := hcm_util.get_string_t(json_obj,'p_numreqst');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin
    if b_index_codcomp is null and b_index_dtereqst is null and b_index_dtereqen is null and b_index_numreqst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;

      if b_index_dtereqst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if b_index_dtereqen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if b_index_dtereqen < b_index_dtereqst then
        param_msg_error := get_error_msg_php('HR6625',global_v_lang);
        return;
      end if;
    end if;

    /*if b_index_numreqst is not null then
        begin
            select numreqst into b_index_numreqst
             from treqest1
            where numreqst = b_index_numreqst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'treqest1');
            return;
        end;
    end if;

     if b_index_codpos is not null then
        begin
            select codpos into b_index_codpos
             from tpostn
            where codpos = b_index_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
    end if;*/

  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_remark_detail (p_statappl in varchar2,p_codapp in varchar2) return json_object_t as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;

    cursor c_tappfoll is
        select codrej ,count(distinct numappl) qtyrej
          from tappfoll t1
         where numappl  in (select numappl
                              from tapplinf a
                             where a.numreqc  in (select a.numreqst
                                                    from treqest1 a,treqest2 b
                                                   where a.numreqst  = b.numreqst
                                                     and ((a.codcomp like  b_index_codcomp||'%'  and a.dtereq between b_index_dtereqst and b_index_dtereqen)
                                                       or (a.numreqst = b_index_numreqst))
                                                     and b.codpos    =  nvl(b_index_codpos,b.codpos) )
                                and a.codposl =  nvl(b_index_codpos,a.codposl))
            and statappl  = p_statappl
        group by codrej
        order by codrej ;

    begin
        obj_rows := json_object_t();
        if p_codapp = 'HRRC1FX1' then
            for i in c_tappfoll loop
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('remarkwintv',get_tcodec_name('TCODREJE',i.codrej,global_v_lang) );
                obj_data.put('qtywintv',i.qtyrej);

                --report--
                if isInsertReport then
                    insert_ttemprpt_waiverint(obj_data);
                end if;

                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        else
            for i in c_tappfoll loop
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('remarkwwork',get_tcodec_name('TCODREJE',i.codrej,global_v_lang) );
                obj_data.put('qtywwork',i.qtyrej); 

                --report--
                if isInsertReport then
                    insert_ttemprpt_waiverint(obj_data);
                end if;

                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end if;
        obj_result := json_object_t();
        obj_result.put('rows',obj_rows);
        return obj_result;
  end get_remark_detail;

  procedure gen_index(json_str_output out clob) as
        obj_result  json_object_t;
        obj_rows    json_object_t;
        v_row       number := 0;
    begin
        obj_rows    := json_object_t();
        obj_result  := json_object_t();
        obj_result  := gen_data;
        obj_result.put('remark1',get_remark_detail('42','HRRC1FX1'));
        obj_result.put('remark2',get_remark_detail('62','HRRC1FX2'));
        obj_rows.put('0',obj_result);

        if v_data = 'N' then
            param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'treqest1');
            json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
        else
            json_str_output := obj_rows.to_clob;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  function gen_data return json_object_t as
    obj_data                    json_object_t;
    obj_row                     json_object_t;
    obj_rows                    json_object_t;
    obj_result                  json_object_t;
    obj_waiverin_result         json_object_t;
    obj_waiverint_data          json_object_t;
    obj_waiverint_row           json_object_t;
    obj_waiveriwrk_result       json_object_t;
    obj_waiveriwrk_data         json_object_t;
    obj_waiveriwrk_row          json_object_t;

    v_row		    number := 0;
    v_rcnt          number := 0;
    v_rcnt42        number := 0;
    v_rcnt62        number := 0;
    v_qtynumreq     number := 0;
    v_qtypos        number := 0;
    v_qtyreq        number := 0;
    v_qtyapp        number := 0;
    v_statappl_31   number := 0;
    v_statappl_21   number := 0;
    v_statappl_22   number := 0;
    v_statappl_40   number := 0;
    v_statappl_no   number := 0;
    v_statappl_ap   number := 0;
    v_statappl_63   number := 0;
    v_statappl_52   number := 0;
    v_statappl_42   number := 0;
    v_statappl_62   number := 0;
    v_statappl      varchar2(10 char);

    cursor c_tapplinf is
        select numappl,statappl
          from tapplinf t1
         where t1.numreqc  in (select a.numreqst
                                from treqest1 a,treqest2 b
                               where a.numreqst  = b.numreqst
                                 and ((a.codcomp like  b_index_codcomp||'%'  and a.dtereq between b_index_dtereqst and b_index_dtereqen)
                                   or (a.numreqst = b_index_numreqst))
                                 and b.codpos    =  nvl(b_index_codpos,b.codpos) )
            and t1.codposl =  nvl(b_index_codpos,t1.codposl)
        order by  statappl;

  begin

    begin
      select count(distinct a.numreqst),count (b.codpos),sum(b.qtyreq)
        into v_qtynumreq,v_qtypos ,v_qtyreq
        from treqest1 a , treqest2 b
       where a.numreqst  = b.numreqst
         and ((a.codcomp like  b_index_codcomp||'%'  and a.dtereq between b_index_dtereqst and b_index_dtereqen)
           or (a.numreqst = b_index_numreqst))
         and b.codpos  =  nvl(b_index_codpos,b.codpos);
    exception when no_data_found then
        null;
    end;
    v_data := 'N';
    if nvl(v_qtynumreq,0) <> 0 then
        v_data := 'Y';
    end if;

    obj_result := json_object_t();
    obj_data   := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('qtynumreq', v_qtynumreq);
    obj_result.put('qtypos', v_qtypos);
    obj_result.put('qtyreq', nvl(v_qtyreq,0));

    for i in c_tapplinf loop
        v_qtyapp := v_qtyapp + 1;
        if i.statappl >=  '31' then
            v_statappl_31 := v_statappl_31 + 1;
        end if;
        if i.statappl =  '21' then
            v_statappl_21 := v_statappl_21 + 1;
        end if;
        if i.statappl =  '22' then
            v_statappl_22 := v_statappl_22 + 1;
        end if;
        if i.statappl =  '40' then
            v_statappl_40 := v_statappl_40 + 1;
        end if;
        if i.statappl in  ('53','54','55') then
            v_statappl_no := v_statappl_no + 1;
        end if;
        if i.statappl in  ('51','61','56') then
            v_statappl_ap := v_statappl_ap + 1;
        end if;
        if i.statappl =  '63' then
            v_statappl_63 := v_statappl_63 + 1;
        end if;
        if i.statappl =  '52' then
            v_statappl_52 := v_statappl_52 + 1;
        end if;
        if i.statappl =  '42' then
            v_statappl_42 := v_statappl_42 + 1;
        end if;
        if i.statappl =  '62' then
            v_statappl_62 := v_statappl_62 + 1;
        end if;
    end loop;
    obj_result.put('qtyapp', v_qtyapp);
    obj_result.put('qtyinterview', (v_statappl_31 + v_statappl_21) );
    obj_result.put('qtyeliminate', v_statappl_22);
    obj_result.put('qtypassintv',  (v_statappl_40 + v_statappl_31) );
    obj_result.put('qtynotpassintv', v_statappl_no );
    obj_result.put('qtyaccept', v_statappl_ap );
    obj_result.put('qtynotaccept', v_statappl_63 );
    obj_result.put('qtyreserve', v_statappl_52 );
    obj_result.put('qtywavintv', v_statappl_42 );
    obj_result.put('qtywavwork', v_statappl_62 );
    --report--
    if isInsertReport then
        p_codapp := 'HRRC1FX';
        insert_ttemprpt_data(obj_result);
    end if;
    return obj_result;
  end;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure get_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      p_codapp := 'HRRC1FX';
      clear_ttemprpt;
      gen_index(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_report;

  procedure insert_ttemprpt_data(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;

    v_qtynumreq         number := 0;
    v_qtypos            number := 0;
    v_qtyreq            number := 0;
    v_qtyapp            number := 0;
    v_qtyinterview      number := 0;
    v_qtyeliminate      number := 0;
    v_qtypassintv       number := 0;
    v_qtynotpassintv    number := 0;
    v_qtyaccept         number := 0;
    v_qtynotaccept      number := 0;
    v_qtyreserve        number := 0;
    v_qtywavintv        number := 0;
    v_qtywavwork        number := 0;

  begin
    v_qtynumreq         := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtynumreq'),'FM9,999'), ' ');
    v_qtypos            := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtypos'),'FM9,999'), ' ');
    v_qtyreq            := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyreq'),'FM9,999'), ' ');
    v_qtyapp            := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyapp'),'FM9,999'), ' ');
    v_qtyinterview      := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyinterview'),'FM9,999'), ' ');
    v_qtyeliminate      := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyeliminate'),'FM9,999'), ' ');
    v_qtypassintv       := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtypassintv'),'FM9,999'), ' ');
    v_qtynotpassintv    := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtynotpassintv'),'FM9,999'), ' ');
    v_qtyaccept         := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyaccept'),'FM9,999'), ' ');
    v_qtynotaccept      := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtynotaccept'),'FM9,999'), ' ');
    v_qtyreserve        := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtyreserve'),'FM9,999'), ' ');
    v_qtywavintv        := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtywavintv'),'FM9,999'), ' ');
    v_qtywavwork        := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtywavwork'),'FM9,999'), ' ');

    v_numseq := 1;
    begin
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,
                              item4,item5,item6,
                              item7,item8,item9,
                              item10,item11,item12,
                              item13,item14
                              )
               values        (global_v_codempid,p_codapp,v_numseq,
                              'DETAIL',v_qtynumreq,v_qtypos,v_qtyreq,
                              v_qtyapp,v_qtyinterview,v_qtyeliminate,
                              v_qtypassintv,v_qtynotpassintv,v_qtyaccept,
                              v_qtynotaccept,v_qtyreserve,v_qtywavintv,
                              v_qtywavwork);
--      null;
    end;

  end insert_ttemprpt_data;

  procedure insert_ttemprpt_waiverint(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;
    v_item1             varchar2(1000 char);
    v_item2             varchar2(1000 char);
    v_item3             varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0) into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;

    v_numseq        := v_numseq + 1;
    v_item1 := nvl(hcm_util.get_string_t(obj_data, 'remarkwintv'), ' ');
    v_item2 := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtywintv'),'FM9,999,999,990'), ' ');

    begin
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3
                            )
             values        (global_v_codempid,p_codapp,v_numseq,
                            'TABLE1',v_item1,v_item2);
    exception when others then
      null;
    end;
  end insert_ttemprpt_waiverint;

  procedure insert_ttemprpt_waiverwrk(obj_data in json_object_t) is
    json_data_rows      json_object_t;
    v_data_rows         json_object_t;
    v_numseq            number := 0;
    v_item1             varchar2(1000 char);
    v_item2             varchar2(1000 char);
    v_item3             varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0) into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;

    v_numseq        := v_numseq + 1;
    v_item1 := nvl(hcm_util.get_string_t(obj_data, 'remarkwwork'), ' ');
    v_item2 := nvl(to_char(hcm_util.get_string_t(obj_data, 'qtywwork'),'FM9,999,999,990'), ' ');

    begin
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3
                            )
             values        (global_v_codempid,p_codapp,v_numseq,
                            'TABLE2',v_item1,v_item2);
    exception when others then
      null;
    end;
  end insert_ttemprpt_waiverwrk;

END HRRC1FX;

/

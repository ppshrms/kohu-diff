--------------------------------------------------------
--  DDL for Package Body HRAL9DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL9DE" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy        := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codpay          := hcm_util.get_string_t(json_obj,'p_codpay');
    p_dteeffec        := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteeffec')),'dd/mm/yyyy');
    p_typwork         := hcm_util.get_string_t(json_obj,'p_typwork');
    p_syncond_json    := hcm_util.get_json_t(json_obj, 'p_syncond');
    p_synconds        := hcm_util.get_string_t(p_syncond_json,'code');
    p_statement       := hcm_util.get_string_t(p_syncond_json,'statement');
    p_typpayot        := hcm_util.get_string_t(json_obj,'p_typpayot');
    p_flgotb          := hcm_util.get_string_t(json_obj,'p_flgotb');
    p_flgotd          := hcm_util.get_string_t(json_obj,'p_flgotd');
    p_flgota          := hcm_util.get_string_t(json_obj,'p_flgota');

    --p_codcompy_lv1    := HCM_UTIL.get_codcomp_level(p_codcompy, 1);
    p_dteeffecold       := p_dteeffec;
    forceadd            := hcm_util.get_string_t(json_obj,'forceAdd');
    p_codcompyquery     := upper(hcm_util.get_string_t(json_obj,'p_codcompyQuery'));
    p_codpayquery       := upper(hcm_util.get_string_t(json_obj,'p_codpayQuery'));
    p_dteeffecquery     := to_date(hcm_util.get_string_t(json_obj,'p_dteeffecQuery'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_codcompy	varchar2(100);
 	  v_secur			boolean;
  begin
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
		end if;

    if p_codcompy  is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcompy');
      return;
    end if;

    if p_dteeffec is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end check_index;

  procedure check_pay_detail is
    v_valid_codpay  tinexinf.codpay%type;
    v_own_codpay    tinexinfc.codpay%type;
  begin
    if p_codpay is not null then
      begin
        select codpay
          into v_valid_codpay
          from tinexinf
          where upper(codpay) like upper(p_codpay)
            --and typpay = '3'
          fetch next 1 rows only;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tinexinf');
      end;
    end if;

    begin
      select codpay
        into v_own_codpay
        from tinexinfc
       where codcompy = p_codcompy
         and upper(codpay) like upper(p_codpay)
       fetch next 1 rows only;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('PY0044', global_v_lang);
    end;
  end check_pay_detail;

  procedure check_getindex is
    v_codcompy	varchar2(100);
 	  v_secur			boolean;
  begin
    if p_codcompy  is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcompy');
      return;
    end if;

    begin
      select codcompy into v_codcompy
      from 	 tcompny
      where  codcompy = p_codcompy;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcompny');
      return;
    end;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
	if param_msg_error is not null then
      return;
	end if;
  end;

  procedure check_save is
  begin
    if p_timstrtw is null and p_timendw is null then
      if p_qtyhrwks is null and p_qtyhrwke is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;

    if p_timstrtw is not null then
      if p_timendw is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'timendw');
        return;
      end if;
    end if;

    if p_qtyhrwks is not null then
      if p_qtyhrwke is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'qtyhrwke');
        return;
      end if;

      if nvl(p_qtyhrwks,0) > nvl(p_qtyhrwke,0) then
        param_msg_error := get_error_msg_php('HR2014',global_v_lang, 'qtyhrwks');
        return;
      end if;
    end if;

    if p_timstrtw is not null and p_timendw is not null then
      p_qtyhrwks  := null;
      p_qtyhrwke  := null;
    end if;

    begin
      select numseq into p_numseq
        from tcontald
       where codcompy = p_codcompy
         and codpay   = p_codpay
         and dteeffec = p_dteeffec
         and numseq   = p_numseq ;
      param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'tcontald');
      return;
     exception when no_data_found then null;
    end;
  end;

  procedure gen_data(json_str_output out clob) is
    v_rcnt          number := 0;
    v_timoutst      varchar2(10);
    v_timouten      varchar2(10);
    v_timoutside    varchar2(100);

    cursor c1 is
      select codcompy,codpay,dteeffec,typwork,syncond
        from tcontals
       where codcompy  = p_codcompy
    order by codpay, dteeffec desc;

  begin
    obj_row := json_object_t();

    for i in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('codpay',i.codpay);
      obj_data.put('despay',get_tinexinf_name(i.codpay,global_v_lang));
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('typwork',i.typwork);
      obj_data.put('flgtran',chk_flgtran(p_codcompy,i.codpay,i.dteeffec));

      if i.typwork = '1' then
        obj_data.put('deswork',get_label_name('HRAL9DE1', global_v_lang, '50'));
      elsif i.typwork = '2' then
        obj_data.put('deswork',get_label_name('HRAL9DE1', global_v_lang, '60'));
      elsif i.typwork = '3' then
        obj_data.put('deswork',get_label_name('HRAL9DE1', global_v_lang, '70'));
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_data;

  function gen_numseq return number is
    v_num  number:=0;
  begin
    begin
      select nvl(max(numseq),0) + 1
        into v_num
        from tcontald
       where codcompy = p_codcompy
         and codpay   = p_codpay
         and dteeffec = p_dteeffec;
    end;
  return(v_num);
  end;

  procedure save_tcontals is
    v_count   number;
  begin
    if param_msg_error is null then
      begin
        select count(*) into v_count
          from tcontals
         where codcompy = p_codcompy
           and codpay   = p_codpay
           and dteeffec = p_dteeffec;
      exception when others then
         v_count := 0;
      end;

      if v_count = 0 then
        begin
          insert into tcontals(codcompy, codpay, dteeffec, typwork,
                               syncond, statement, 
                               typpayot,flgotb,flgotd,flgota, 
                               dtecreate,codcreate, coduser)
                        values(p_codcompy, p_codpay, p_dteeffec, p_typwork,
                               p_synconds, p_statement, 
                               p_typpayot,p_flgotb,p_flgotd,p_flgota, 
                               trunc(sysdate),global_v_coduser, global_v_coduser);
        end;
      else
        begin
          update tcontals
             set typwork   = p_typwork,
                 syncond   = p_synconds,
                 statement = p_statement,
                 typpayot  = p_typpayot,
                 flgotb    = p_flgotb,
                 flgotd    = p_flgotd,
                 flgota    = p_flgota,
                 dteupd    = trunc(sysdate),
                 coduser   = global_v_coduser
            where codcompy = p_codcompy
              and codpay   = p_codpay
              and dteeffec = p_dteeffec;
        end;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure save_tcontald is
    v_numseq  number;
  begin
    if p_flg = 'add' or p_flg = 'edit' then
      begin
        insert into tcontald(codcompy, codpay, dteeffec, numseq, syncond, statement, qtyhrwks,
                         qtyhrwke, timstrtw, timendw, formula, dtecreate, codcreate, coduser)
                   values(p_codcompy, p_codpay, p_dteeffec, p_numseq, p_syncondd, p_statement, p_qtyhrwks,
                          p_qtyhrwke, p_timstrtw, p_timendw, p_formula, trunc(sysdate), global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then null;
      end;
    elsif p_flg = 'delete' then
      begin
        delete from tcontald
              where codcompy = p_codcompy
                and codpay   = p_codpay
                and dteeffec = p_dteeffec
                and numseq   = p_numseq;
      end;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_getindex;

    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detailpay_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detailpay_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detailpay_detail(json_str_output out clob) is
    v_total         number;
    obj_row         json_object_t;
    v_typpayot      tcontals.typpayot%type;
    v_flgotb        tcontals.flgotb%type;
    v_flgotd        tcontals.flgotd%type;
    v_flgota        tcontals.flgota%type;    
    v_coduser       tcontals.coduser%type;
    v_dteupd        tcontals.dteupd%type;
    v_flgtran       boolean;

  begin
--    initial_value(json_str_input);
--    check_index;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    check_getindex;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    check_pay_detail;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    gen_flg_status;
    begin
      select typwork, syncond, rownum, statement,
             typpayot,flgotb,flgotd,flgota,
             coduser,dteupd
       into  v_typwork, v_syncond, v_total, v_statement,
             v_typpayot,v_flgotb,v_flgotd,v_flgota,
             v_coduser,v_dteupd
        from tcontals
       where codcompy = nvl(p_codcompyquery, p_codcompy)
         and codpay   = nvl(p_codpayquery, p_codpay)
         and dteeffec = nvl(p_dteeffecquery, p_dteeffec);
    exception when no_data_found then
      v_total := 0;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('dteeffec', to_char(v_indexdteeffec,'dd/mm/yyyy'));
    obj_row.put('codcompy', p_codcompy);
    obj_row.put('codpay', p_codpay);
    obj_row.put('typwork', v_typwork);
    obj_row.put('syncond', v_syncond);
--    obj_row.put('desc_syncond', get_logical_name('HRAL9DE2',v_syncond,global_v_lang));
    obj_row.put('desc_syncond', get_logical_desc(v_statement));
    obj_row.put('statement', v_statement);
    obj_row.put('typpayot', v_typpayot);
    obj_row.put('flgotb', v_flgotb);
    obj_row.put('flgotd', v_flgotd);
    obj_row.put('flgota', v_flgota);
    obj_row.put('codimage', get_codempid(v_coduser));
    obj_row.put('desc_coduser',  v_coduser || ' - ' || get_temploy_name(get_codempid(v_coduser), global_v_lang));
    obj_row.put('dteupd', to_char(v_dteupd,'dd/mm/yyyy'));
    v_flgtran := chk_flgtran(p_codcompy,p_codpay,v_indexdteeffec);
    obj_row.put('flgtran', v_flgtran);

    if v_flgtran then
        obj_row.put('msqerror', replace(get_error_msg_php('HR1510',global_v_lang),'@#$%400',''));  
    end if;
--    if isedit or isadd then
--        obj_row.put('msqerror', '');  
--    else
--        obj_row.put('msqerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',''));  
--    end if;

    --gen report--
    if isInsertReport then
      insert_ttemprpt(obj_row);
    end if;
    --

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detailpay_table (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detailpay_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detailpay_table(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_timstrtw      varchar2(10);
    v_timendw       varchar2(10);
    v_qtyhrwks      varchar2(10);
    v_qtyhrwke      varchar2(10);
    v_timetypst     varchar2(10);
    v_timetypen     varchar2(10);
    v_typformat     varchar2(1);

    cursor c1 is
      select rowid, numseq,syncond,statement,qtyhrwks,qtyhrwke,timstrtw,timendw,formula
        from tcontald
       where codcompy = nvl(p_codcompyquery, p_codcompy)
         and codpay   = nvl(p_codpayquery, p_codpay)
         and dteeffec = nvl(p_dteeffecquery, p_dteeffec)
    order by numseq;
  begin
--    initial_value(json_str_input);
--    check_index;
    obj_row := json_object_t();

    gen_flg_status;

    for r1 in c1 loop
      v_row    := v_row+1;
      obj_data := json_object_t();

      if r1.qtyhrwks is not null and r1.qtyhrwke is not null then
        v_typformat   := 'H';
        v_qtyhrwks    := null;
        v_qtyhrwke    := null;
        v_timetypst   := hcm_util.convert_minute_to_hour(r1.qtyhrwks);
        v_timetypen   := hcm_util.convert_minute_to_hour(r1.qtyhrwke);
      elsif r1.timstrtw is not null and r1.timendw is not null then
        v_typformat   := 'T';
        v_qtyhrwks    := null;
        v_qtyhrwke    := null;
        v_timetypst   := lpad(r1.timstrtw, 4, '0');
        v_timetypen   := lpad(r1.timendw, 4, '0');
        v_timetypst   := substr(v_timetypst,1,2)||':'||substr(v_timetypst,3,2);
        v_timetypen   := substr(v_timetypen,1,2)||':'||substr(v_timetypen,3,2);
      else
        v_typformat   := 'H';
        v_timetypst   := null;
        v_timetypen   := null;
      end if;

      if isadd = true then
        v_rowid := null;
      else
        v_rowid := r1.rowid;
      end if;
      obj_data.put('coderror', '200');
      obj_data.put('rowidOld', v_rowid);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('syncond', r1.syncond);
--      obj_data.put('desc_syncond', get_logical_name('HRAL9DE2',r1.syncond,global_v_lang));
      obj_data.put('desc_syncond', get_logical_desc(r1.statement));
      obj_data.put('desc_syncond_report', get_logical_desc(r1.statement));
      obj_data.put('statement', r1.statement);
      obj_data.put('typformat', v_typformat);
      obj_data.put('timetypst', v_timetypst);
      obj_data.put('timetypen', v_timetypen);
      obj_data.put('qtyhrwks', v_qtyhrwks);
      obj_data.put('qtyhrwke', v_qtyhrwke);
      obj_data.put('amtpay', r1.formula);
      obj_data.put('codcompy', p_codcompy);
      obj_data.put('codpay', p_codpay);
      obj_data.put('dteeffec',to_char(p_dteeffec,'dd/mm/yyyy'));
      -- obj_data.put('desc_amtpay', get_logical_name('HRAL9DE2', r1.formula,global_v_lang));
      obj_data.put('desc_amtpay', hcm_formula.get_description(r1.formula, global_v_lang));
      obj_data.put('flgAdd',true);
--      obj_data.put('flgAdd',isAdd);
      --gen report--
      if isInsertReport then
        insert_ttemprpt_table(obj_data);
      end if;
      --
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_copy_list(json_str_input in clob, json_str_output out clob) is
    v_row      number := 0;
    v_secur    varchar2(1000 char);

    cursor c1 is
      select codcompy,codpay,dteeffec,typwork,syncond
        from tcontals
       where codcompy like nvl(p_codcompy,'%')
    order by codcompy,codpay,dteeffec desc;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    for r1 in c1 loop
      v_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, r1.codcompy);
      if v_secur is null then
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('codpay', r1.codpay);
        obj_data.put('despay',get_tinexinf_name(r1.codpay,global_v_lang));
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_row.put(to_char(v_row-1),obj_data);
      end if;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codpay          := hcm_util.get_string_t(p_index_rows, 'codpay');
        p_dteeffec        := to_date(hcm_util.get_string_t(p_index_rows, 'dteeffec'), 'DD/MM/YYYY');
        p_codapp := 'HRAL9DE';
        gen_detailpay_detail(json_output);
        p_codapp := 'HRAL9DE1';
        gen_detailpay_table(json_output);
      end loop;
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
  end gen_report;

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

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_typwork           varchar2(100 char);
    v_typpayot          varchar2(100 char);
    v_flgotb            varchar2(100 char);
    v_flgotd            varchar2(100 char);
    v_flgota            varchar2(100 char);

    v_desc_codcomp      varchar2(1000 char) := '';
    v_codpay    			  varchar2(1000 char) := '';
    v_desc_codpay       varchar2(1000 char) := '';
    v_desc_syncond      varchar2(1000 char) := '';
    v_codcompy    			varchar2(1000 char) := '';
  begin
    v_desc_codcomp       	:= get_tcompny_name(hcm_util.get_string_t(obj_data, 'codcompy'),global_v_lang);
    v_codpay            	:= nvl(hcm_util.get_string_t(obj_data, 'codpay'), ' ');
    v_desc_codpay       	:= get_tinexinf_name(hcm_util.get_string_t(obj_data, 'codpay'), global_v_lang);
    v_desc_syncond      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_syncond'), '');
    v_codcompy      			:= nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq     := v_numseq + 1;
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);
    v_typwork    := nvl(hcm_util.get_string_t(obj_data, 'typwork'), ' ');
    v_typpayot   := nvl(hcm_util.get_string_t(obj_data, 'typpayot'), ' ');
    v_flgotb     := nvl(hcm_util.get_string_t(obj_data, 'flgotb'), ' ');
    v_flgotd     := nvl(hcm_util.get_string_t(obj_data, 'flgotd'), ' ');
    v_flgota     := nvl(hcm_util.get_string_t(obj_data, 'flgota'), ' ');
    if v_typwork = '1' then
      v_typwork := get_label_name('HRAL9DE2', global_v_lang, '80');
    elsif v_typwork = '2' then
      v_typwork := get_label_name('HRAL9DE2', global_v_lang, '90');
    elsif v_typwork = '3' then
      v_typwork := get_label_name('HRAL9DE2', global_v_lang, '100');
    end if;
    --typpayot--
    if v_typpayot = '1' then
      v_typpayot := get_label_name('HRAL9DE2', global_v_lang, '300');
    elsif v_typpayot = '2' then
      v_typpayot := get_label_name('HRAL9DE2', global_v_lang, '270');
    end if;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7,
             item8 ,item9, item10, item11
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_desc_codcomp,
             v_codpay || ' - ' || v_desc_codpay,
             v_dteeffec_,
             v_desc_syncond,
             v_typwork,
             v_codcompy,
             v_codpay,
             v_typpayot,
             v_flgotb,
             v_flgotd,
             v_flgota
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dteeffec          date;
    v_dteeffec_         varchar2(100 char) := '';
    v_typwork           varchar2(100 char);
    v_typformat         varchar2(100 char);

    v_numseq_      				varchar2(1000 char) := '';
    v_desc_syncond_report varchar2(1000 char) := '';
    v_timetypst       		varchar2(1000 char) := '';
    v_timetypen      			varchar2(1000 char) := '';
    v_desc_amtpay    			varchar2(1000 char) := '';
    v_codcompy    	  		varchar2(1000 char) := '';
    v_codpay    	  			varchar2(1000 char) := '';

  begin
    v_numseq_       				:= nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
    v_desc_syncond_report   := nvl(hcm_util.get_string_t(obj_data, 'desc_syncond_report'), ' ');
    v_timetypst       			:= nvl(hcm_util.get_string_t(obj_data, 'timetypst'), '');
    v_timetypen      				:= nvl(hcm_util.get_string_t(obj_data, 'timetypen'), '');
    v_desc_amtpay      			:= nvl(hcm_util.get_string_t(obj_data, 'desc_amtpay'), '');
    v_codcompy      				:= nvl(hcm_util.get_string_t(obj_data, 'codcompy'), '');
    v_codpay      					:= nvl(hcm_util.get_string_t(obj_data, 'codpay'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq     := v_numseq + 1;
    v_year       := hcm_appsettings.get_additional_year;
    v_dteeffec   := to_date(hcm_util.get_string_t(obj_data, 'dteeffec'), 'DD/MM/YYYY');
    v_dteeffec_  := to_char(v_dteeffec, 'DD/MM/') || (to_number(to_char(v_dteeffec, 'YYYY')) + v_year);
    v_typformat    := nvl(hcm_util.get_string_t(obj_data, 'typformat'), ' ');

    if v_typformat = 'T' then
      v_typformat := get_label_name('HRAL9DE2', global_v_lang, '130');
    elsif v_typformat = 'H' then
      v_typformat := get_label_name('HRAL9DE2', global_v_lang, '250');
    end if;

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7, item8, item9
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             v_dteeffec_,
             v_numseq_,
             v_desc_syncond_report,
             v_typformat,
             v_timetypst,
             v_timetypen,
             v_desc_amtpay,
             v_codcompy,
             v_codpay
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_table;

  procedure save_data(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    param_syncond   json_object_t;
    v_timetypst     varchar2(10);
    v_timetypen     varchar2(10);
    v_typformat     varchar2(1);
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      save_tcontals;
      begin
        delete from tcontald
          where codcompy = p_codcompy
            and codpay   = p_codpay
            and dteeffec = p_dteeffec;
      end;
      --
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_rowid         := hcm_util.get_string_t(param_json_row,'rowidOld');
        p_numseq        := to_number(hcm_util.get_string_t(param_json_row,'numseq'));
        p_numseqold     := to_number(hcm_util.get_string_t(param_json_row,'numseqOld'));
        param_syncond   := hcm_util.get_json_t(param_json_row, 'syncond');
        p_syncondd      := hcm_util.get_string_t(param_syncond, 'code');
        p_statement     := hcm_util.get_string_t(param_syncond, 'statement');
        p_formula       := hcm_util.get_string_t(param_json_row,'amtpay');
        p_flg           := hcm_util.get_string_t(param_json_row,'flg');

        v_typformat     := hcm_util.get_string_t(param_json_row, 'typformat');
        v_timetypst     := hcm_util.get_string_t(param_json_row, 'timetypst');
        v_timetypen     := hcm_util.get_string_t(param_json_row, 'timetypen');
        if v_typformat = 'H' then
          p_qtyhrwks    := hcm_util.convert_hour_to_minute(v_timetypst);
          p_qtyhrwke    := hcm_util.convert_hour_to_minute(v_timetypen);
          p_timstrtw    := null;
          p_timendw     := null;
        elsif v_typformat = 'T' then
          p_qtyhrwks    := null;
          p_qtyhrwke    := null;
          v_timetypst   := replace(v_timetypst, ':');
          v_timetypen   := replace(v_timetypen, ':');
          p_timstrtw    := lpad(v_timetypst, 4, '0');
          p_timendw     := lpad(v_timetypen, 4, '0');
        else
          p_qtyhrwks    := null;
          p_qtyhrwke    := null;
          p_timstrtw    := null;
          p_timendw     := null;
        end if;

        if p_numseq is null or p_numseq = 0 then
          p_numseq := gen_numseq;
        end if;
        check_save;
        save_tcontald;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
        p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
        p_dteeffec      := to_date(trim(hcm_util.get_string_t(param_json_row,'dteeffec')),'dd/mm/yyyy');

        begin
          delete from tcontals
                where codcompy = p_codcompy
                  and codpay   = p_codpay
                  and dteeffec = p_dteeffec;
        end;
        begin
          delete from tcontald
                where codcompy = p_codcompy
                  and codpay   = p_codpay
                  and dteeffec = p_dteeffec;
        end;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t := json_object_t();
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    check_getindex;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    check_pay_detail;
    if param_msg_error is null then
      gen_flg_status;
      obj_data.put('coderror', 200);
      obj_data.put('isEdit', isedit);
      obj_data.put('isAdd', isadd);
      obj_data.put('isCopy', nvl(forceadd, 'N'));
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_flg_status;

  procedure gen_flg_status is
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    if forceadd = 'Y' then
      isedit := false;
      isadd  := true;
      v_indexdteeffec := p_dteeffec;
    else
      begin
        select count(*) into v_count
          from tcontals
         where codcompy = p_codcompy
           and dteeffec  = p_dteeffec
           and upper(codpay) like upper(p_codpay);
        v_indexdteeffec := p_dteeffec;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
        select max(dteeffec) into v_maxdteeffec
          from tcontals
         where codcompy = p_codcompy
           and dteeffec <= p_dteeffec
           and upper(codpay) like upper(p_codpay);
        if p_dteeffec < trunc(sysdate) then
          v_indexdteeffec := v_maxdteeffec;
          isedit := false;
        else
          v_indexdteeffec := p_dteeffec;
          isedit := false;
          isadd  := true;
        end if;

        if v_maxdteeffec is null then
            select min(dteeffec) into v_maxdteeffec
              from tcontals
             where codcompy = p_codcompy
               and dteeffec > p_dteeffec
               and upper(codpay) like upper(p_codpay); 
            if v_maxdteeffec is null then
              v_indexdteeffec       := p_dteeffec;
              isedit                := true;
              isadd                 := true;
            else
                isedit              := false;
                isAdd               := false;
                v_indexdteeffec     := v_maxdteeffec;
                p_dteeffec          := v_maxdteeffec;
            end if;
        else
            p_dteeffec := v_maxdteeffec;
        end if;
      else
        if p_dteeffec < trunc(sysdate) then
          isedit := false;
        else
          isedit := true;
        end if;
        v_indexdteeffec := p_dteeffec;
      end if;
    end if;
  end gen_flg_status;

  function chk_flgtran(p_codcompy in varchar2, p_codpay in varchar2, p_dteeffec in date) return boolean is
    v_count_paysum number;
    v_dteeffec      date;
  begin
      begin
        select min(dteeffec)
          into v_dteeffec
          from tcontals
         where codcompy like p_codcompy || '%'
           and codpay   = p_codpay
           and dteeffec > p_dteeffec;
      exception when others then
        v_dteeffec := null;
      end;
      v_dteeffec := nvl(v_dteeffec,sysdate);
--      begin
--          select 1
--            into v_count_paysum
--            from TPAYSUM a, TPAYSUM2 b
--           where a.dteyrepay = b.dteyrepay
--             and a.dtemthpay = b.dtemthpay
--             and a.numperiod = b.numperiod
--             and a.codempid  = b.codempid
--             and a.codalw    = b.codalw
--             and a.codpay    = b.codpay
--             and a.flgtran   = 'Y'
--             and b.codalw    = 'PAY_OTHER'
--             and b.codcomp   like p_codcompy || '%'
--             and b.codpay    = p_codpay
--             and b.dtework  >= p_dteeffec
--             and b.dtework  < v_dteeffec
--             and rownum     = 1;    
--      exception when others then
--        v_count_paysum := 0;
--      end;
      v_count_paysum := 0;
      if v_count_paysum > 0 then
        return true;
      else
        return false;
      end if;      

  exception when others then
    return false;
  end;

end hral9de;

/

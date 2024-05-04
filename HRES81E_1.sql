--------------------------------------------------------
--  DDL for Package Body HRES81E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES81E" as
  procedure initial_value(json_str_input in clob) is
      json_obj json_object_t;
  begin
      json_obj          := json_object_t(json_str_input);
      global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
      global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

      p_codempid        := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));
      p_dtereq          := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
      p_numseq          := hcm_util.get_string_t(json_obj,'p_numseq');
      p_numtravrq       := hcm_util.get_string_t(json_obj,'numtravrq');
      p_codcomp         := upper(hcm_util.get_string_t(json_obj,'codcomp'));
      p_dtereq_start    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
      p_dtereq_end      := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
      p_codprov         := hcm_util.get_string_t(json_obj,'p_codprov');
      p_codcnty         := hcm_util.get_string_t(json_obj,'p_codcnty');
      p_codexp          := hcm_util.get_string_t(json_obj,'p_codexp');
      p_dtestrt_start   := to_date(hcm_util.get_string_t(json_obj,'dtestrt_start'),'dd/mm/yyyy');
      p_dtestrt_end     := to_date(hcm_util.get_string_t(json_obj,'dtestrt_end'),'dd/mm/yyyy');

      obj_ttravreq      := hcm_util.get_json_t(json_obj,'ttravreq');
      obj_tcontrbf      := hcm_util.get_json_t(json_obj,'tcontrbf');
      param_json        := hcm_util.get_json_t(json_obj,'param_json');

      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
      v_temp varchar2(1 char);
  begin
    if p_dtereq_start is not null and p_dtereq_end is not null then
      if p_dtereq_start > p_dtereq_end then
         param_msg_error := get_error_msg_php('HR2021', global_v_lang);
         return;
      end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
      obj_rows    json_object_t;
      obj_data    json_object_t;
      v_row       number := 0;
      cursor c1 is
        select *
          from ttravreq
         where codempid = p_codempid
           and dtereq between nvl(p_dtereq_start,dtereq) and nvl(p_dtereq_end,dtereq)
         order by dtereq desc,numseq desc;
  begin
      obj_rows := json_object_t();
      for r1 in c1 loop
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('numseq', r1.numseq );
          obj_data.put('numtravrq', '' );
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy') );
          obj_data.put('location', r1.location );
          obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy') );
          obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy') );
          obj_data.put('remarkap', r1.remarkap );
          obj_data.put('status', get_tlistval_name('ESSTAREQ',trim(r1.staappr),global_v_lang) );
          obj_data.put('staappr', r1.staappr );
          obj_data.put('desc_codappr', r1.codappr || ' ' ||get_temploy_name(r1.codappr,global_v_lang)  );
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES81E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang));
          obj_rows.put(to_char(v_row-1),obj_data);
      end loop;
      json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      check_index;
      if param_msg_error is null then
          gen_index(json_str_output);
      else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_detail as
      v_temp varchar2(1 char);
  begin
      if p_codempid is not null then
          begin
              select 'X' into v_temp
              from TEMPLOY1
              where codempid = p_codempid;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
              return;
          end;
          if secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal, global_v_numlvlsalst, global_v_numlvlsalen) = false then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              return;
          end if;
      end if;

  end check_detail;

  procedure check_detail_add as
      v_temp varchar2(1 char);
  begin
      if p_codempid is null or p_dtereq is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
  end check_detail_add;

  procedure gen_detail(json_str_output out clob) as
      obj_rows        json_object_t;
      obj_data        json_object_t;
      v_ttravreq      ttravreq%rowtype;
      v_flag          varchar2(10 char);
      v_codgrpprov    tgrpprov.codgrpprov%type;
      v_codgrpcnty    tgrpcnty.codgrpcnty%type;
  begin
      obj_rows := json_object_t();
          -- check numseq
      if p_numseq is null then
        begin
          select nvl(max(numseq),0) + 1 into p_numseq
            from ttravreq
           where codempid = p_codempid
             and dtereq = p_dtereq;
        exception when no_data_found then
          p_numseq := 1;
        end;
      end if;
      begin
        select * into v_ttravreq
          from ttravreq
         where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq;
           v_flag := 'edit';
      exception when no_data_found then
        v_flag := 'add';
        v_ttravreq := null;
      end;

      if v_flag = 'edit' then
        begin
            select codgrpprov into v_codgrpprov
            from tgrpprov
            where codprov = v_ttravreq.codprov;
        exception when no_data_found then
            v_codgrpprov := '';
        end;
        begin
            select codgrpcnty into v_codgrpcnty
            from tgrpcnty
            where codcnty = v_ttravreq.codcnty;
        exception when no_data_found then
            v_codgrpcnty := '';
        end;
        obj_data := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('codempid', v_ttravreq.codempid );
        obj_data.put('numtravrq', v_ttravreq.numtravrq );
        obj_data.put('numseq', v_ttravreq.numseq );
        obj_data.put('staappr', v_ttravreq.staappr );
        obj_data.put('dtereq', to_char(v_ttravreq.dtereq,'dd/mm/yyyy') );
        obj_data.put('typetrav', v_ttravreq.typetrav );
        obj_data.put('location', v_ttravreq.location );
        obj_data.put('codprov', v_ttravreq.codprov );
        obj_data.put('codgrpprov', get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang));
        obj_data.put('codcnty', v_ttravreq.codcnty );
        obj_data.put('codgrpcnty', get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang) );
        obj_data.put('dtestrt', to_char(v_ttravreq.dtestrt,'dd/mm/yyyy') );
        obj_data.put('timstrt', v_ttravreq.timstrt );
        obj_data.put('dteend', to_char(v_ttravreq.dteend,'dd/mm/yyyy') );
        obj_data.put('timend', v_ttravreq.timend );
        obj_data.put('qtyday', v_ttravreq.qtyday );
        obj_data.put('qtydistance', v_ttravreq.qtydistance );
        obj_data.put('remark', v_ttravreq.remark );
        obj_data.put('typepay', v_ttravreq.typepay );
      elsif v_flag = 'add' then
        obj_data := json_object_t();
        obj_data.put('coderror',200);
        obj_data.put('codempid', p_codempid );
        obj_data.put('numtravrq', '' );
        obj_data.put('numseq', p_numseq );
        obj_data.put('staappr', '' );
        obj_data.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy') );
        obj_data.put('typetrav', '' );
        obj_data.put('location', '' );
        obj_data.put('codprov', '' );
        obj_data.put('codgrpprov', '');
        obj_data.put('codcnty', '' );
        obj_data.put('codgrpcnty', '' );
        obj_data.put('dtestrt', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('timstrt', '' );
        obj_data.put('dteend', to_char(sysdate,'dd/mm/yyyy'));
        obj_data.put('timend','' );
        obj_data.put('qtyday', '' );
        obj_data.put('qtydistance', '');
        obj_data.put('remark', '');
        obj_data.put('typepay', '1' );
      end if;
      json_str_output := obj_data.to_clob;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
      v_temp varchar2(1);
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail_attach(json_str_output out clob) as
      obj_data        json_object_t;
      obj_data_child  json_object_t;
      v_row_child     number := 0;

      cursor c1attach is
        select seqno,filename,descfile
          from ttravreqf
         where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq
         order by seqno;

  begin
      if p_numseq is null then
        begin
          select nvl(max(numseq),0) + 1 into p_numseq
            from ttravreq
           where codempid = p_codempid
             and dtereq = p_dtereq;
        exception when no_data_found then
          p_numseq := 1;
        end;
      end if;
      obj_data  := json_object_t();
      v_row_child := 0;
      for j in c1attach loop
          v_row_child := v_row_child+1;
          obj_data_child := json_object_t();
          obj_data_child.put('numseq',j.seqno);
          obj_data_child.put('filename',j.filename);
          obj_data_child.put('descattch',j.descfile);
          obj_data.put(v_row_child-1,obj_data_child);
      end loop;
      json_str_output :=  obj_data.to_clob;
  end gen_detail_attach;

  procedure get_detail_attach(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_detail_attach(json_str_output);
      if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_attach;

  procedure gen_detail_expense(json_str_output out clob) as
      obj_data        json_object_t;
      obj_data_child  json_object_t;
      v_row_child     number := 0;
      v_codcompy      tconttrav.codcompy%type;
      cursor c1expense is
          select *
          from ttravexp
          where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq
          order by codexp;

  begin
      if p_numseq is null then
        begin
          select nvl(max(numseq),0) + 1 into p_numseq
            from ttravreq
           where codempid = p_codempid
             and dtereq = p_dtereq;
        exception when no_data_found then
          p_numseq := 1;
        end;
      end if;
      obj_data  := json_object_t();
      v_row_child := 0;
      for k in c1expense loop
          v_row_child := v_row_child+1;
          obj_data_child := json_object_t();
          obj_data_child.put('codexp',k.codexp);
          obj_data_child.put('codtravunit', k.codtravunit);
          obj_data_child.put('desc_codtravunit', get_tcodec_name('TCODTRAVUNIT', k.CODTRAVUNIT, global_v_lang));
          obj_data_child.put('amtalw',k.amtalw);
          obj_data_child.put('qtyunit',k.qtyunit);
          obj_data_child.put('amtreq',k.amtreq);
          obj_data.put(v_row_child-1,obj_data_child);
      end loop;
      json_str_output :=  obj_data.to_clob;
  end gen_detail_expense;

  procedure get_detail_expense(json_str_input in clob, json_str_output out clob) as
      v_temp varchar2(1 char);
  begin
      initial_value(json_str_input);
      gen_detail_expense(json_str_output);
      if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_expense;

  procedure gen_codexp(json_str_input  in clob, json_str_output out clob) as
      json_obj        json_object_t;
      obj_rows        json_object_t;
      obj_head        json_object_t;
      v_codcompy      tconttrav.codcompy%type;
      v_codexp        tconttrav.codexp%type;
      v_dteeffec      tconttrav.dteeffec%type;
      v_codprov       TTRAVINF.codprov%type;
      v_codcnty       TTRAVINF.codcnty%type;
      v_row           number := 0;
      v_row_2           number := 0;

      v_syncond       TCONTTRAVD.syncond%TYPE;
      v_stmt          long;
      v_flg           boolean;
      v_codcomp       temploy1.codcomp%TYPE;
      v_codpos        temploy1.codpos%TYPE;
      v_numlvl        temploy1.numlvl%TYPE;
      v_jobgrade      temploy1.jobgrade%TYPE;
      v_typemp        temploy1.typemp%TYPE;
      v_codbrlc       temploy1.codbrlc%TYPE;
      cursor c1 is
          select codexp, codtravunit, a.dteeffec
          from tconttrav  a
          where codcompy = v_codcompy
          and  codexp = p_codexp
          and dteeffec = (select max(dteeffec)
                          from TCONTTRAV
                          where codcompy = v_codcompy
                          and  codexp = p_codexp
                          and dteeffec <= p_dtestrt_start);
      cursor c2 is
      select syncond,amtalw
      from TCONTTRAVD
      where codcompy = v_codcompy
      and codexp = p_codexp
      and dteeffec = (select max(dteeffec)
                      from TCONTTRAVD
                      where codcompy = v_codcompy
                      and codexp = p_codexp
                      and dteeffec <= v_dteeffec)
      order by numseq;
  begin
      begin
          select codcomp,codpos,numlvl,jobgrade,typemp,codbrlc
          into v_codcomp,v_codpos,v_numlvl,v_jobgrade,v_typemp,v_codbrlc
          from temploy1
          where codempid = p_codempid;
      end;
      v_codcompy := hcm_util.get_codcomp_level(v_codcomp,1);
      v_flg := false;
      obj_rows := json_object_t();
      obj_head := json_object_t();
      obj_head.put('coderror',200);
      for i in c1 loop
          v_dteeffec := i.dteeffec;
          v_row := v_row+1;
          obj_head.put('codtravunit', i.codtravunit);
          obj_head.put('desc_codtravunit', get_tcodec_name('TCODTRAVUNIT', i.CODTRAVUNIT, global_v_lang));
              v_row_2 := 0;
              for k in c2 loop
                  if k.syncond is not null then
                      v_row_2 := v_row_2+1;
                      v_syncond := k.syncond;
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.NUMLVL',v_numlvl);
                      v_syncond := replace(v_syncond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                      v_syncond := replace(v_syncond,'TGRPPROV.CODGRPPROV',''''||v_codprov||'''');
                      v_syncond := replace(v_syncond,'TGRPCNTY.CODGRPCNTY',''''||v_codcnty||'''');

                      v_stmt := 'select count(*) from TEMPLOY1 where codempid = '''||p_codempid||''' and '||v_syncond;
                      v_flg := v_flg or execute_stmt(v_stmt);
                      if v_flg = true then
                          obj_head.put('amtalw',k.amtalw);
                          exit;
                      end if;
                      if v_flg = false then
                          obj_head.put('amtalw','0');
                      end if;
                  end if;
              end loop;
              if v_flg = true then
                  exit;
              end if;
      end loop;
      if v_row = 0 or v_flg = false then
          param_msg_error := get_error_msg_php('BF0049',global_v_lang);
      end if;
      if v_row_2 = 0 or v_flg = false then
          param_msg_error := get_error_msg_php('BF0049',global_v_lang);
      end if;
      json_str_output := obj_head.to_clob;
  end gen_codexp;

  procedure get_codexp(json_str_input in clob, json_str_output out clob) as
      v_codcompy      tconttrav.codcompy%type;
  begin
      initial_value(json_str_input);
      gen_codexp(json_str_input, json_str_output);
      if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codexp;

  procedure gen_codprov(json_str_input  in clob, json_str_output out clob) as
      json_obj        json_object_t;
      obj_head        json_object_t;
      v_codprov       TTRAVINF.codprov%type;
      v_codcnty       TTRAVINF.CODCNTY%type;
      v_codgrpprov    TGRPPROV.codgrpprov%type;
      v_codgrpcnty    TGRPCNTY.codgrpcnty%type;
  begin
      obj_head := json_object_t();
      obj_head.put('coderror',200);
      obj_head.put('codprov',p_codprov);
      begin
          select CODGRPPROV into v_codgrpprov
          from tgrpprov
          where codprov = p_codprov;
      exception when no_data_found then
          v_codgrpprov := '';
      end;
      obj_head.put('codgrpprov',v_codgrpprov);
      obj_head.put('desc_codgrpprov', get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang));

      obj_head.put('codcnty',p_codcnty);
      begin
          select CODGRPCNTY into v_codgrpcnty
          from tgrpcnty
          where codcnty = p_codcnty;
      exception when no_data_found then
          v_codgrpcnty := '';
      end;
      obj_head.put('codgrpcnty',v_codgrpcnty);
      obj_head.put('desc_codgrpcnty', get_tcodec_name('TCODGRPCNTY', v_codgrpcnty, global_v_lang));
      json_str_output :=  obj_head.to_clob;
  end gen_codprov;

  procedure get_codprov(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      gen_codprov(json_str_input, json_str_output);
      if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codprov;

  procedure check_param_detail as
      v_temp          varchar2(1 char);
      v_staemp        temploy1.staemp%type;
      v_typpayroll    tdtepay.typpayroll%type;
      v_dteeffex      temploy1.dteeffex%type;
  begin
      if p_location is null or ( p_codprov is null and  p_codcnty is null )
          or p_dtestrt_start is null or p_dtestrt_end is null
          or (p_timstrt is null  and p_timend is not null) or (p_timstrt is not null  and p_timend is null)
          or p_qtyday is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
              return;
      end if;

      if p_codcnty is not null then
          begin
              select 'x' into v_temp
              from TCODCNTY
              where codcodec = p_codcnty;
              exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCNTY');
              return;
          end;
      end if;

      if p_codprov is not null then
          begin
              select 'x' into v_temp
              from TCODPROV
              where codcodec = p_codprov;
              exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV');
              return;
          end;
      end if;

      if (p_dtestrt_start > p_dtestrt_end) or (p_dtestrt_start||p_timstrt > p_dtestrt_end||p_timend) then
          param_msg_error := get_error_msg_php('HR2021',global_v_lang);
          return;
      end if;
      v_staemp := '';
      v_dteeffex := null;
      begin
          select staemp,dteeffex  into v_staemp, v_dteeffex
          from TEMPLOY1
          where codempid = p_codempid;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
          return;
      end;
      if v_staemp = '9' then
          if p_dtestrt_start >= v_dteeffex then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
          end if;
      end if;
  end check_param_detail;

  procedure check_child_attach as
      detail_obj      json_object_t;
      param_table     json_object_t;
      v_flg           varchar2(10 char);

      v_numseq     ttravattch.numseq%TYPE;
      v_filename    ttravattch.filename%TYPE;
      v_descattch     ttravattch.descattch%TYPE;
  BEGIN
      param_table  := hcm_util.get_json_t(obj_ttravreq,'table');
      FOR i IN 0..param_table.get_size - 1 LOOP
          detail_obj  := hcm_util.get_json_t(param_table, to_char(i));
          v_flg       := hcm_util.get_string_t(detail_obj, 'flg');
          if v_flg = 'add' or v_flg = 'edit' then
              v_filename  := hcm_util.get_string_t(detail_obj, 'filename');
              v_descattch := hcm_util.get_string_t(detail_obj, 'descfile');
              if ( v_descattch is not null and v_filename is null ) then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
          end if;
      END LOOP;
  end check_child_attach;

  procedure check_child_expense as
      v_temp          varchar2(1 char);
      detail_obj      json_object_t;
      v_item_flgedit  varchar2(10 char);
      v_row           number := 0;

      v_codexp        TTRAVINFD.codexp%TYPE;
      v_codtravunit   TTRAVINFD.codtravunit%TYPE;
      v_amtalw        TTRAVINFD.amtalw%TYPE;
      v_qtyunit       TTRAVINFD.qtyunit%TYPE;
      v_amtreq        TTRAVINFD.amtreq%TYPE;

      v_codcompy      TCONTTRAVD.codcompy%TYPE;
      v_syncond      TCONTTRAVD.syncond%TYPE;
      v_stmt          long;
      v_flg           boolean;
      v_codcomp       temploy1.codcomp%TYPE;
      v_codpos        temploy1.codpos%TYPE;
      v_numlvl        temploy1.numlvl%TYPE;
      v_jobgrade      temploy1.jobgrade%TYPE;
      v_typemp        temploy1.typemp%TYPE;
      v_codbrlc       temploy1.codbrlc%TYPE;
      v_size          number := 0;
      v_chkExist      number := 0;
      cursor c1 is
        select syncond
          from tconttravd
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codexp = v_codexp
           and dteeffec = (select max(dteeffec)
                             from tconttravd
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and codexp = v_codexp
                              and dteeffec <= p_dtestrt_start)
        order by numseq;

  BEGIN
      v_size  :=  obj_tcontrbf.get_size;
      begin
        select count(*) into v_chkExist
        from ttravexp
        where codempid = p_codempid
         and dtereq = p_dtereq
          and numseq = p_numseq;
      exception when no_data_found then
        v_chkExist := 0;
      end;
      if v_size = 0 and v_chkExist = 0 then
        param_msg_error := get_error_msg_php('HR7598',global_v_lang);
        return;
      end if;
      FOR i IN 0..obj_tcontrbf.get_size - 1 LOOP
          detail_obj := hcm_util.get_json_t(obj_tcontrbf, to_char(i));
          v_item_flgedit := hcm_util.get_string_t(detail_obj, 'flg');
          IF v_item_flgedit = 'add' or v_item_flgedit = 'edit' THEN
              v_codexp := upper(hcm_util.get_string_t(detail_obj, 'codexp'));
--              v_codtravunit := upper(hcm_util.get_string_t(detail_obj, 'codtravunit'));
              v_amtalw := to_number(hcm_util.get_string_t(detail_obj, 'amtalw'));
              v_qtyunit := to_number(hcm_util.get_string_t(detail_obj, 'qtyunit'));
              v_amtreq := to_number(hcm_util.get_string_t(detail_obj, 'amtreq'));

              if v_codexp is null or v_amtalw is null or v_qtyunit is null or v_amtreq is null then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
              if v_amtalw <= 0 then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
              begin
                  SELECT 'x' into v_temp
                  from TCODEXP
                  where codcodec = v_codexp;
              exception when no_data_found then
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXP');
                  return;
              END;
              begin
                  select codcomp,codpos,numlvl,jobgrade,typemp,codbrlc
                  into v_codcomp,v_codpos,v_numlvl,v_jobgrade,v_typemp,v_codbrlc
                  from temploy1
                  where codempid = p_codempid;
              end;
              v_flg := false;
              for k in c1 loop
                  v_row := v_row+1;
                  if k.syncond is not null then
                      v_syncond := k.syncond;
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.NUMLVL',v_numlvl);
                      v_syncond := replace(v_syncond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
                      v_syncond := replace(v_syncond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
                      v_syncond := replace(v_syncond,'TGRPPROV.CODGRPPROV',''''||p_codprov||'''');
                      v_syncond := replace(v_syncond,'TGRPCNTY.CODGRPCNTY',''''||p_codcnty||'''');
                      v_stmt := 'select count(*) from TEMPLOY1 where codempid = '''||p_codempid||''' and '||v_syncond;
                      v_flg := v_flg or execute_stmt(v_stmt);
                  end if;
                  if v_flg then
                    exit;
                  end if;
              end loop;
              if v_flg = false then
                  param_msg_error := get_error_msg_php('BF0049',global_v_lang);
                  return;
              end if;
          END IF;
      END LOOP;
  end check_child_expense;
  procedure initial_save is
    param_detail    json_object_t;
  begin
    param_detail  := hcm_util.get_json_t(obj_ttravreq,'detail');
    p_codempid	  := hcm_util.get_string_t(param_detail,'codempid');
    p_numtravrq	  := hcm_util.get_string_t(param_detail,'numtravrq');
    p_numseq	    := hcm_util.get_string_t(param_detail,'numseq');
    p_staappr	    := hcm_util.get_string_t(param_detail,'staappr');
    p_dtereq	    := to_date(hcm_util.get_string_t(param_detail,'dtereq'),'dd/mm/yyyy');
    p_typetrav	  := hcm_util.get_string_t(param_detail,'typetrav');
    p_location	  := hcm_util.get_string_t(param_detail,'location');
    p_codprov	    := hcm_util.get_string_t(param_detail,'codprov');
    p_codcnty	    := hcm_util.get_string_t(param_detail,'codcnty');
    p_dtestrt_start	:= to_date(hcm_util.get_string_t(param_detail,'dtestrt'),'dd/mm/yyyy');
    p_dtestrt_end	  := to_date(hcm_util.get_string_t(param_detail,'dteend'),'dd/mm/yyyy');
    p_timstrt	    := replace(hcm_util.get_string_t(param_detail,'timstrt'),':','');
    p_timend	    := replace(hcm_util.get_string_t(param_detail,'timend'),':','');
    p_qtyday	    := hcm_util.get_string_t(param_detail,'qtyday');
    p_qtydistance	:= hcm_util.get_string_t(param_detail,'qtydistance');
    p_remark	    := hcm_util.get_string_t(param_detail,'remark');
    p_typepay	    := hcm_util.get_string_t(param_detail,'typepay');
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES81E';
    v_count      number := 0;
    v_approvno   number := 0;
    v_codempid_next  temploy1.codempid%type;
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(4 char);
    v_remark     varchar2(200 char) := substr(get_label_name('HRESZXEC1',global_v_lang,99),1,200);
    v_routeno    varchar2(100 char);

    v_ok        boolean;

    v_flgfwbwlim  varchar2(1);
    v_qtyminle    number;
    v_qtydlefw    number;
    v_qtydlebw    number;

    v_dtefw       date;
    v_dteaw       date;
    v_typleave	  varchar2(4 char);
    v_table			  varchar2(50 char);
    v_error			  varchar2(50 char);
  begin
    v_approvno       := 0 ;
    v_codempap       := p_codempid ;
    p_staappr  := 'P';
    chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');

    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,v_table,v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
      return;
    end if;
     --Loop Check Next step
    loop
      v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid);
      if  v_codempid_next is not null then
        v_approvno         := v_approvno + 1 ;
        p_codappr    := v_codempid_next ;
        p_staappr    := 'A' ;
        p_dteappr    := trunc(sysdate);
        p_remarkap   := v_remark;
        p_approvno   := v_approvno ;
        begin
            select  count(*) into v_count
             from   taptrvrq
             where  codempid = p_codempid
             and    dtereq   = p_dtereq
             and    numseq   = p_numseq
             and    approvno = v_approvno;
        exception when no_data_found then  v_count := 0;
        end;

        if v_count = 0 then
          insert into taptrvrq (codempid, dtereq, numseq, approvno, typepay,
                                codappr, dteappr, staappr, remark, dtesnd, dteapph,
                                dtecreate, codcreate, coduser)
              values (p_codempid, p_dtereq, p_numseq, v_approvno, p_typepay,
                      v_codempid_next, trunc(sysdate), 'A', v_remark, sysdate, sysdate,
                      sysdate, global_v_coduser, global_v_coduser);
        else
          update taptrvrq
             set codappr = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = v_remark ,
                 coduser   = global_v_coduser,
                 dteapph   = sysdate
           where codempid = p_codempid
             and dtereq   = p_dtereq
             and numseq   = p_numseq
             and approvno = v_approvno;
        end if;
        chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');--user22 : 02/08/2016 : HRMS590307 || chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid);
      else
        exit ;
      end if;
    end loop ;

    p_approvno     := v_approvno ;
    p_routeno      := v_routeno ;
  end;
  --
  procedure save_ttravreq is
    v_count         number := 0;
    data_row        json_object_t;
    param_table     json_object_t;
    v_flg     	    varchar2(10 char);
    v_filename		  ttravreqf.filename%type;
    v_descfile		  ttravreqf.descfile%type;
    v_seqno		      ttravreqf.seqno%type;

    v_codexp        ttravexp.codexp%TYPE;
    v_codtravunit   ttravexp.codtravunit%TYPE;
    v_amtalw        ttravexp.amtalw%TYPE;
    v_qtyunit       ttravexp.qtyunit%TYPE;
    v_amtreq        ttravexp.amtreq%TYPE;
    v_sumamtreq     number := 0;
  begin
    begin
      select count(*) into v_count
        from ttravreq
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    end;
    if v_count = 0 then
      begin
        insert into ttravreq ( codempid,dtereq,numseq,
                               typetrav,location,codprov,codcnty,dtestrt,timstrt,dteend,timend,
                               qtyday,qtydistance,remark,typepay,
                               routeno, approvno, staappr, remarkap,
                               flgsend, flgagency, codinput,
                               dtecreate, codcreate, coduser )
          values (p_codempid, p_dtereq, p_numseq,
                  p_typetrav,p_location,p_codprov,p_codcnty,p_dtestrt_start,p_timstrt,p_dtestrt_end,p_timend,
                  p_qtyday,p_qtydistance,p_remark,p_typepay,
                  p_routeno, p_approvno, p_staappr, p_remarkap,
                  'N', 'N', global_v_codempid,
                  trunc(sysdate), global_v_coduser, global_v_coduser );
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        end;
    else
      begin
        update ttravreq
          set typetrav = p_typetrav,
              location = p_location,
              codprov = p_codprov,
              codcnty = p_codcnty,
              dtestrt = p_dtestrt_start,
              timstrt = p_timstrt,
              dteend = p_dtestrt_end,
              timend = p_timend,
              qtyday = p_qtyday,
              qtydistance = p_qtydistance,
              remark = p_remark,
              typepay = p_typepay,
              routeno = p_routeno,
              approvno  = p_approvno,
              staappr = p_staappr,
              remarkap  = p_remarkap,
              flgsend = 'N',
              flgagency = 'N',
              dteupd  = sysdate,
              coduser = global_v_coduser
        where codempid = p_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;
      end;
    end if;
    param_table  := hcm_util.get_json_t(obj_ttravreq,'table');
    for i in 0..param_table.get_size-1 loop
      data_row  := hcm_util.get_json_t(param_table,to_char(i));
      v_flg     		  := hcm_util.get_string_t(data_row, 'flg');
      v_filename		  := hcm_util.get_string_t(data_row, 'filename');
      v_descfile		  := hcm_util.get_string_t(data_row, 'descfile');
      v_seqno		      := hcm_util.get_string_t(data_row, 'numseq');

      if v_flg = 'add' then
        begin
          select nvl(max(seqno),1)+1 into v_seqno
          from ttravreqf
          where codempid = p_codempid
           and dtereq = p_dtereq
            and numseq = p_numseq;
        exception when no_data_found then
          v_seqno := 1;
        end;
        begin
          insert into ttravreqf (codempid, dtereq, numseq, seqno, filename, descfile, dtecreate, codcreate, coduser)
          values (p_codempid, p_dtereq, p_numseq, v_seqno, v_filename, v_descfile, sysdate, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      elsif v_flg = 'delete' then
        delete ttravreqf
         where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq
           and seqno = v_seqno;
      end if;
    end loop;
    FOR i IN 0..obj_tcontrbf.get_size - 1 LOOP
        data_row  := hcm_util.get_json_t(obj_tcontrbf, to_char(i));
        v_flg     := hcm_util.get_string_t(data_row, 'flg');
        v_codexp  := upper(hcm_util.get_string_t(data_row, 'codexp'));
        v_codtravunit := upper(hcm_util.get_string_t(data_row, 'codtravunit'));
        v_amtalw      := to_number(hcm_util.get_string_t(data_row, 'amtalw'));
        v_qtyunit     := to_number(hcm_util.get_string_t(data_row, 'qtyunit'));
        v_amtreq      := to_number(hcm_util.get_string_t(data_row, 'amtreq'));

        IF v_flg = 'add' THEN
          insert into ttravexp ( codempid, dtereq, numseq, codexp, codtravunit, amtalw, qtyunit, amtreq, codcreate, coduser )
          values ( p_codempid, p_dtereq, p_numseq, v_codexp, v_codtravunit, v_amtalw, v_qtyunit, v_amtreq, global_v_coduser, global_v_coduser );

        elsif v_flg = 'edit' then 
          update ttravexp set qtyunit = v_qtyunit,
                              amtreq  = v_amtreq,
                              coduser = global_v_coduser
          where codempid = p_codempid
            and dtereq = p_dtereq
            and numseq = p_numseq
            and codexp = v_codexp;

        elsif v_flg = 'delete' then
          begin
            delete ttravexp
            where codempid = p_codempid
            and dtereq = p_dtereq
            and numseq = p_numseq
            and codexp = v_codexp;
          exception when others then
            null;
          end;
          commit;
        END IF;        
    END LOOP;

    begin 
      select nvl(sum(nvl(amtreq,0)),0) into v_sumamtreq
      from   ttravexp
      where codempid = p_codempid
      and   dtereq   = p_dtereq
      and   numseq   = p_numseq;

      update ttravreq set amtreq = v_sumamtreq
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq; 
    end;
  end;
  --
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
      json_obj        json_object_t;
      param_json      json_object_t;
      child_attach    json_object_t;
      child_expense   json_object_t;

      v_codprov       TTRAVINF.codprov%type;
      v_codcnty       TTRAVINF.codcnty%type;
      v_flag      varchar2(10 char);
  begin
      initial_value(json_str_input);
      initial_save;
      check_param_detail;
      check_child_attach;
      check_child_expense;
      if param_msg_error is null then
        insert_next_step;
        if param_msg_error is null then
          save_ttravreq;
          commit;
        end if;
      end if;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        commit;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        rollback;
      end if;
  exception when others then
      rollback;
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  PROCEDURE delete_index( detail_obj json_object_t) AS
      v_numtravrq     ttravinf.numtravrq%TYPE;
  BEGIN
      v_numtravrq := upper(hcm_util.get_string_t(detail_obj, 'numtravrq'));

      DELETE ttravattch
          where numtravrq = v_numtravrq;
      DELETE ttravinf
          where numtravrq = v_numtravrq;

  EXCEPTION WHEN OTHERS THEN
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  END delete_index;

  procedure save_index (json_str_input in clob, json_str_output out clob) as
    v_flg	            varchar2(1000 char);
    v_flgupd	        varchar2(1000 char);
    v_numvcher	      varchar2(1000 char);
    v_dtereq          varchar2(1000 char);
    v_numseq          number;
  begin
    initial_value(json_str_input);
    p_dtereq    := to_date(hcm_util.get_string_t(param_json,'dtereq'),'dd/mm/yyyy');
    p_numseq    := hcm_util.get_string_t(param_json,'numseq');
    p_codempid  := hcm_util.get_string_t(param_json,'codempid');
    begin
      update ttravreq
         set staappr = 'C',
             dtecancel = trunc(sysdate),
             coduser = global_v_coduser
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    exception when no_data_found then
      null;
    end;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
end hres81e;

/

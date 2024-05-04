--------------------------------------------------------
--  DDL for Package Body HRES74E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES74E" as
  procedure initial_value(json_str_input in clob) is
    json_obj          json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_query_codempid  := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtereq          := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq          := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codrel          := hcm_util.get_string_t(json_obj,'p_typrelate');
    p_dtereqst        := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    p_dtereqen        := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    p_codobf          := hcm_util.get_string_t(json_obj,'p_codobf');
    param_json        := hcm_util.get_json_t(json_obj,'param_json');
    param_detail      := hcm_util.get_json_t(json_obj,'detail');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_temp     varchar(1 char);
  begin
    if p_dtereqst is not null and p_dtereqen is not null then
      if p_dtereqst > p_dtereqen then
         param_msg_error := get_error_msg_php('HR2021', global_v_lang);
         return;
      end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    v_secur      varchar2(1 char) := 'N';
    v_chk_secur  boolean := false;
    cursor c1 is
      select *
      from tobfreq
      where codempid = p_query_codempid
      and dtereq between nvl(p_dtereqst,dtereq) and nvl(p_dtereqen,dtereq)
      order by dtereq desc,numseq desc;
  begin
    obj_rows := json_object_t();
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('numseq', r1.numseq );
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy') );
      obj_data.put('numvcher', r1.numvcher );
      obj_data.put('codobf', r1.codobf );
      obj_data.put('desc_codobf', get_tobfcde_name(r1.codobf,global_v_lang) );
      obj_data.put('desc_typrelate', get_tlistval_name('TYPERELATE',r1.typrelate,global_v_lang) );
      obj_data.put('amtreq', r1.amtwidrw );
      obj_data.put('status', get_tlistval_name('ESSTAREQ',trim(r1.staappr),global_v_lang) );
      obj_data.put('staappr', r1.staappr );
      obj_data.put('desnote', r1.desnote );
      obj_data.put('desc_codappr', r1.codappr || ' ' ||get_temploy_name(r1.codappr,global_v_lang) );
      obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES74E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang) );
      obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure gen_detail(json_str_output out clob) as
    obj_data    json_object_t;
    v_tobfreq   tobfreq%rowtype;
    v_flag      varchar(50 char) := '';
    v_codcomp   temploy1.codcomp%type;
    v_codpos    temploy1.codpos%type;
    v_costcenter  tcenter.costcent%type;
    v_amtvalue    tobfcde.amtvalue%type;
    v_codunit     tobfcde.codunit%type;
    v_typebf     tobfcde.typebf%type;
  begin
    -- check numseq
    if p_numseq is null then
      begin
        select nvl(max(numseq),0) + 1 into p_numseq
          from tobfreq
         where codempid = p_query_codempid
           and dtereq = p_dtereq;
      exception when no_data_found then
        p_numseq := 1;
      end;
    end if;
--  get data from TOBFREQ
    begin
      select * into v_tobfreq
        from tobfreq
       where codempid = p_query_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
      v_flag := 'edit';
    exception when no_data_found then
      v_tobfreq := null;
      v_flag    := 'add';
    end;
    begin
      select codcomp,codpos into v_codcomp,v_codpos
      from temploy1
      where codempid = p_query_codempid;
    exception when no_data_found then null;
    end;
    if v_flag = 'add' then
      begin
        select costcent into v_costcenter
        from tcenter
        where codcomp = v_codcomp;
      exception when no_data_found then null;
      end;
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codempid', p_query_codempid );
      obj_data.put('desc_codempid', get_temploy_name(p_query_codempid, global_v_lang) );
      obj_data.put('codcomp', v_codcomp );
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang) );
      obj_data.put('codcenter', v_costcenter );
      obj_data.put('desc_codcenter', get_tcoscent_name(v_costcenter,global_v_lang) );
      obj_data.put('codobf', '' );
      obj_data.put('codunit', '' );
      obj_data.put('amtvalue', '' );
      obj_data.put('typrelate', '' );
      obj_data.put('nameobf', '' );
      obj_data.put('numtsmit', '' );
      obj_data.put('qtywidrw', '0' );
      obj_data.put('amtwidrw', '' );
      obj_data.put('typepay', '' );
      obj_data.put('desnote', '' );
      obj_data.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy') );
      obj_data.put('numseq', p_numseq );
      obj_data.put('typebf', '' );
    elsif v_flag = 'edit' then
      begin
        select costcent into v_costcenter
        from tcenter
        where codcomp = v_codcomp;
      exception when no_data_found then null;
      end;
      begin
        select amtvalue, codunit, typebf into v_amtvalue, v_codunit, v_typebf
        from tobfcde
        where codobf = v_tobfreq.codobf;
      exception when no_data_found then null;
      end;
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codempid', p_query_codempid );
      obj_data.put('desc_codempid', get_temploy_name(p_query_codempid, global_v_lang) );
      obj_data.put('codcomp', v_codcomp );
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang) );
      obj_data.put('codcenter', v_costcenter );
      obj_data.put('desc_codcenter', get_tcoscent_name(v_costcenter,global_v_lang) );
      obj_data.put('codobf', v_tobfreq.codobf );
      obj_data.put('codunit', v_codunit );
      obj_data.put('amtvalue', v_amtvalue );
      obj_data.put('typrelate', v_tobfreq.typrelate );
      obj_data.put('nameobf', v_tobfreq.nameobf );
      obj_data.put('numtsmit', v_tobfreq.numtsmit );
      obj_data.put('qtywidrw', v_tobfreq.qtywidrw );
      obj_data.put('amtwidrw', v_tobfreq.amtwidrw );
      obj_data.put('typepay', v_tobfreq.typepay );
      obj_data.put('desnote', v_tobfreq.desnote );
      obj_data.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy') );
      obj_data.put('numseq', p_numseq );
      obj_data.put('typebf', v_typebf );
    end if;
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure gen_detail_table(json_str_output out clob) as
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
        select filename,descfile,seqno
        from tobfreqf
        where codempid = p_query_codempid
        and dtereq = p_dtereq
        and numseq = p_numseq;
  begin
    -- check numseq
    if p_numseq is null then
      begin
        select nvl(max(numseq),0) + 1 into p_numseq
          from tobfreq
         where codempid = p_query_codempid
           and dtereq = p_dtereq;
      exception when no_data_found then
        p_numseq := 1;
      end;
    end if;
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('numseq',i.seqno);
        obj_data.put('filename',i.filename);
        obj_data.put('descattch',i.descfile);
        obj_data.put('coderror',200);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_detail_table;

  procedure gen_relation(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_amount        number := 0;

    v_namsick       tmedreq.namsick%type;

  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    if p_codrel = 'E' then
      obj_data.put('namsick', get_temploy_name(p_query_codempid,global_v_lang));
    elsif p_codrel = 'S' then
      begin
        select decode(global_v_lang,'101',namspe
                           ,'102',namspt
                           ,'103',namsp3
                           ,'104',namsp4
                           ,'105',namsp5) as namsp
          into v_namsick
          from tspouse
         where codempid = p_query_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
    elsif p_codrel = 'F' then
      begin
        select decode(global_v_lang,'101',namfathe
                                   ,'102',namfatht
                                   ,'103',namfath3
                                   ,'104',namfath4
                                   ,'105',namfath5) as namfath
          into v_namsick
          from tfamily
         where codempid = p_query_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
    elsif p_codrel = 'M' then
      begin
        select decode(global_v_lang,'101',nammothe
                                   ,'102',nammotht
                                   ,'103',nammoth3
                                   ,'104',nammoth4
                                   ,'105',nammoth5) as nammoth
          into v_namsick
          from tfamily
         where codempid = p_query_codempid;
      exception when no_data_found then
        v_namsick := '';
      end;
      obj_data.put('namsick', v_namsick);
    else
      obj_data.put('namsick', '');
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_relation(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_relation(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tobfcde(json_str_output out clob) as
    obj_data    json_object_t;
    v_codunit   tobfcde.codunit%type;
    v_amtvalue  tobfcde.amtvalue%type;
    v_syncond   tobfcde.syncond%type;
    v_typepay   tobfcde.typepay%type;
    v_flglimit  tobfcde.flglimit%type;
    v_typebf    tobfcde.typebf%type;
    v_dtestart  tobfcft.dtestart%type;
    v_amtalwyr  tobfcft.amtalwyr%type;
    v_qtyalw    tobfcdet.qtyalw%type;
    v_qtytalw   tobfcdet.qtytalw%type;
    v_cond      tobfcde.syncond%type;
    v_cond2     tobfcde.syncond%type;
    v_flgExist  varchar2(2 char);
    v_stmt      varchar2(4000 char);
    v_stmt2     varchar2(4000 char);
    v_flgcond1  number;
    v_flgcond2  number;
    v_qtytacc   number;
    v_amtacc    number;
    v_errorno   varchar2(30 char);
    v_flgsecur  boolean := false;
    v_qtywidrw  number;
    v_amtwidrw  number;
    v_qty_tobfreq number;

    /*cursor c1 is
      select *
        from tobfcdet
       where codobf = p_codobf
       order by numobf;*/
  begin
    std_bf.get_benefit(p_query_codempid,p_codobf,p_codrel,p_dtereq,p_numseq,null,p_amtwidrw,'Y',
                       v_codunit,v_amtvalue,v_typepay,v_typebf,v_flglimit,
                       v_qtytacc,v_amtacc,v_qtywidrw,v_amtwidrw,v_qtytalw,
                       v_errorno);
    /*----
    begin
      select codunit,amtvalue,typepay, flglimit, typebf
        into v_codunit,v_amtvalue,v_typepay, v_flglimit, v_typebf
        from tobfcde
       where codobf = p_codobf;
    exception when no_data_found then
        v_codunit  := '';
        v_amtvalue := '';
    end;
    -- Default
    v_qty_tobfreq := 0;
    v_qtywidrw := 0;
    v_amtwidrw := 0;
    begin
      select dtestart, amtalwyr into v_dtestart, v_amtalwyr
          from tobfcft
         where codempid =  p_query_codempid
           and dtestart = (select max(dtestart)
                             from tobfcft
                            where codempid = p_query_codempid
                              and dtestart <= p_dtereq
                              or nvl(dteend, p_dtereq) >= p_dtereq);
      v_flgExist := 'Y';
    exception when no_data_found then
      v_dtestart  := null;
      v_amtalwyr  := null;
      v_flgExist  := 'N';
    end;

    if v_flgExist = 'Y' then
      begin
        select qtyalw,qtytalw into v_qtyalw, v_qtytalw
          from tobfcftd
         where codempid = p_query_codempid
           and dtestart = v_dtestart
           and codobf = p_codobf;
      exception when no_data_found then
        v_qtyalw := null;
        v_qtytalw := null;
      end;
      if v_typebf = 'C' then
        v_qtywidrw := v_qtyalw;
        v_amtwidrw := v_qtyalw;
      elsif v_typebf = 'T' then
        v_qtywidrw := v_qtyalw;
        v_amtwidrw := v_amtvalue * v_qtyalw;
      end if;
    elsif v_flgExist = 'N' then
      begin
      select syncond into v_syncond
        from tobfcde
       where codobf = p_codobf
         and dtestart = (select max(dtestart)
                           from tobfcde
                          where codobf = p_codobf
                            and (nvl(dtestart, p_dtereq) <= p_dtereq
                            or nvl(dteend, p_dtereq) >= p_dtereq));
      exception when no_data_found then
        v_syncond := null;
      end;
      if v_syncond is not null then
        v_cond := 'and ' || v_syncond;
        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
        v_stmt :=  'select count(*)'||
                   'from V_HRBF41,tobfcde,TCLNSINF '||
                   'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
                   'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
                   v_cond||' '||
                   'and rownum = 1';

        execute immediate v_stmt into v_flgcond1;
        if v_flgcond1 > 0 then
          for r1 in c1 loop
            if r1.syncond is not null then
              v_cond2 := 'and ' || r1.syncond;
              v_cond2 := replace(v_cond2,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
              v_stmt2 := 'select count(*)'||
                         'from V_HRBF41,tobfcde,TCLNSINF '||
                         'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
                         'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
                         v_cond2||' '||
                         'and rownum = 1';
              execute immediate v_stmt2 into v_flgcond2;
              if v_flgcond2 > 0 then
                v_qtyalw := r1.qtyalw;
                v_qtytalw := r1.qtytalw;
                if v_typebf = 'C' then
                  v_qtywidrw := v_qtyalw;
                  v_amtwidrw := v_qtyalw;
                elsif v_typebf = 'T' then
                  v_qtywidrw := r1.qtytalw;
                  v_amtwidrw := v_amtvalue * r1.qtytalw;
                end if;
                v_flgsecur := true;
                exit;
              end if;
            end if;
          end loop;
        end if;
      end if;
    end if;
    if v_flglimit = 'M' then
--สิทธิเป็นต่อเดือน count(*) from tobfreq where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = เดือนของ ‘วันที่ขอ’
      begin
        select count(*)  into v_qty_tobfreq
          from tobfreq
         where codempid = p_query_codempid
           and codobf = p_codobf
           and to_char(dtereq,'YYYYMM') = to_char(sysdate,'YYYYMM')
           and staappr in ('P','A');
      exception when no_data_found then
        v_qty_tobfreq := 0;
      end;
      --
 ----      v_amtalw := r2.qtyalw * 12;
      begin
        select nvl(qtytwidrw,0) + 1 into v_qtytwidrw
          from tobfsum
         where codempid = p_query_codempid
           and codobf = p_codobf
           and dteyre = to_char(sysdate,'yyyy')
           and dtemth = to_char(sysdate,'mm');
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw + v_qty_tobfreq;

    elsif v_flglimit = 'Y' then
--	ถ้าสิทธิเป็นต่อปี count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = ปีของ ‘วันที่ขอ’
      begin
        select count(*)  into v_qty_tobfreq
          from tobfreq
         where codempid = p_query_codempid
           and codobf = p_codobf
           and to_char(dtereq,'YYYY') = to_char(sysdate,'YYYY')
           and staappr in ('P','A');
      exception when no_data_found then
        v_qty_tobfreq := 0;
      end;

      begin
        select nvl(qtytwidrw,0) + 1 into v_qtytwidrw
          from tobfsum
         where codempid = p_query_codempid
           and codobf = p_codobf
           and dteyre = to_char(sysdate,'yyyy')
           and dtemth = 13;
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw + v_qty_tobfreq;

    elsif v_flglimit = 'A' then
--	ถ้าสิทธิเป็นตลอดอายุงาน count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A
      begin
        select count(*)  into v_qty_tobfreq
          from tobfreq
         where codempid = p_query_codempid
           and codobf = p_codobf
           and staappr in ('P','A');
      exception when no_data_found then
        v_qty_tobfreq := 0;
      end;

      begin
        select count(qtytwidrw) + 1 into v_qtytwidrw
          from tobfsum
         where codempid = p_query_codempid
           and codobf = p_codobf;
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw + v_qty_tobfreq;
    end if;*/

--    if v_flgsecur then
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codunit',v_codunit);
      obj_data.put('amtvalue',v_amtvalue);
      obj_data.put('typepay',v_typepay);
      obj_data.put('typrelate', 'E' );
      obj_data.put('typebf', v_typebf );
      obj_data.put('nameobf', get_temploy_name(p_query_codempid, global_v_lang));
      obj_data.put('numtsmit', v_qtytacc + 1); -- เบิกครั้งที่
--<<Error STT 02/03/2023      
      --obj_data.put('qtywidrw', v_qtywidrw ); -- จำนวนที่ขอเบิก
      v_qtytalw := nvl(v_qtytalw,0);
      if v_qtytalw > 0 then
        obj_data.put('qtywidrw', v_qtywidrw /nvl(v_qtytalw,0)); -- จำนวนที่ขอเบิก
      else
        obj_data.put('qtywidrw', '0'); -- จำนวนที่ขอเบิก
      end if;
----Error STT 02/03/2023            
      obj_data.put('amtwidrw', v_amtwidrw ); -- คิดเป็นเงิน

      json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tobfcde;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
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
  END get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_table;

  procedure get_tobfcde(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_tobfcde(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_tobfcde;

  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json_row      json_object_t;
    param_index         json_object_t;

    v_flg	            varchar2(1000 char);
    v_flgupd	        varchar2(1000 char);
    v_numvcher	      varchar2(1000 char);
    v_dtereq          varchar2(1000 char);
    v_numseq          number;
  begin
    initial_value(json_str_input);
    p_dtereq    := to_date(hcm_util.get_string_t(param_json,'dtereq'),'dd/mm/yyyy');
    p_numseq    := hcm_util.get_string_t(param_json,'numseq');
    begin
      update tobfreq
         set staappr = 'C',
             dtecancel = trunc(sysdate),
             coduser = global_v_coduser
       where codempid = p_query_codempid
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

  procedure initial_save (json_str in clob)is
  begin
    p_codempid       := hcm_util.get_string_t(param_detail,'codempid');
    p_codcomp        := hcm_util.get_string_t(param_detail,'codcomp');
    p_codobf         := hcm_util.get_string_t(param_detail,'codobf');
    p_amtvalue       := hcm_util.get_string_t(param_detail,'amtvalue');
    p_typrelate      := hcm_util.get_string_t(param_detail,'typrelate');
    p_nameobf        := hcm_util.get_string_t(param_detail,'nameobf');
    p_numtsmit       := hcm_util.get_string_t(param_detail,'numtsmit');
    p_qtywidrw       := hcm_util.get_string_t(param_detail,'qtywidrw');
    p_amtwidrw       := hcm_util.get_string_t(param_detail,'amtwidrw');
    p_typepay        := hcm_util.get_string_t(param_detail,'typepay');
    p_desnote        := hcm_util.get_string_t(param_detail,'desnote');
    p_dtereq         := to_date(hcm_util.get_string_t(param_detail,'dtereq'),'dd/mm/yyyy');
    p_numseq         := hcm_util.get_string_t(param_detail,'numseq');
    p_typebf         := hcm_util.get_string_t(param_detail,'typebf');
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure check_save is
    v_errorno       varchar2(10 char);
    v_namsp         tspouse.namspe%type;
    v_chkExist      number;

  begin
    if p_codobf is null or p_typrelate is null or p_nameobf is null or
      p_qtywidrw is null or p_typepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    v_errorno  :=  benefit_secure;
    if v_errorno is not null then
      if v_errorno = 'HR2055' then
        param_msg_error := get_error_msg_php(v_errorno,global_v_lang,'TOBFCFTD');
        return;
      else
        param_msg_error := get_error_msg_php(v_errorno,global_v_lang);
        return;
      end if;
    end if;

    if p_typrelate = 'S' then
      begin
        select decode(global_v_lang,'101',namspe
                                   ,'102',namspt
                                   ,'103',namsp3
                                   ,'104',namsp4
                                   ,'105',namsp5) as namsp
        into v_namsp
        from tspouse
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR6525',global_v_lang);
        return;
      end;
    elsif p_typrelate = 'C' then
      begin
        select count(*)
        into v_chkExist
        from tchildrn
        where codempid = p_codempid;
      exception when no_data_found then
        v_chkExist := 0;
      end;
      if v_chkExist = 0 then
        param_msg_error := get_error_msg_php('HR6526',global_v_lang);
        return;
      end if;
    elsif p_typrelate = 'F' then
      begin
        select count(*)
        into v_chkExist
        from tfamily
        where codempid = p_codempid;
      exception when no_data_found then
        v_chkExist := 0;
      end;
      if v_chkExist = 0 then
        param_msg_error := get_error_msg_php('HR6530',global_v_lang);
        return;
      end if;
    end if;

  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES74E';
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
             from   tapobfrq
             where  codempid = p_codempid
             and    dtereq   = p_dtereq
             and    numseq   = p_numseq
             and    approvno = v_approvno;
        exception when no_data_found then  v_count := 0;
        end;

        if v_count = 0 then
          insert into tapobfrq (codempid, dtereq, numseq, approvno, typepay,
                                codappr, dteappr, staappr, remark, dtesnd, dteapph,
                                dtecreate, codcreate, coduser)
              values (p_codempid, p_dtereq, p_numseq, v_approvno, p_typepay,
                      v_codempid_next, trunc(sysdate), 'A', v_remark, sysdate, sysdate,
                      sysdate, global_v_coduser, global_v_coduser);
        else
          update tapobfrq
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
  procedure save_tobfreq is
    v_count         number := 0;
    data_row        json_object_t;
    v_flg     	    varchar2(10 char);
    v_filename		  tobfreqf.filename%type;
    v_descfile		  tobfreqf.descfile%type;
    v_seqno		      tobfreqf.seqno%type;
  begin
    begin
      select count(*) into v_count
        from tobfreq
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    end;
    if v_count = 0 then
      begin
      insert into tobfreq ( codempid,dtereq,numseq,codobf,typrelate,nameobf,
                            numtsmit,qtywidrw,amtwidrw,typepay,desnote,
                            routeno, approvno, staappr, remarkap,
                            flgsend, flgagency,
                            dtecreate, codcreate, coduser )
          values (p_codempid, p_dtereq, p_numseq, p_codobf, p_typrelate, p_nameobf,
                  p_numtsmit, p_qtywidrw, p_amtwidrw, p_typepay, p_desnote,
                  p_routeno, p_approvno, p_staappr, p_remarkap,
                  'N', 'N',
                  trunc(sysdate), global_v_coduser, global_v_coduser );
        exception when others then
          param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        end;
    else
      begin
        update tobfreq
          set codobf = p_codobf,
              typrelate = p_typrelate,
              nameobf = p_nameobf,
              numtsmit = p_numtsmit,
              qtywidrw = p_qtywidrw,
              amtwidrw = p_amtwidrw,
              typepay = p_typepay,
              desnote = p_desnote,
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
    for i in 0..param_json.get_size-1 loop
      data_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flg     		  := hcm_util.get_string_t(data_row, 'flg');
      v_filename		  := hcm_util.get_string_t(data_row, 'filename');
      v_descfile		  := hcm_util.get_string_t(data_row, 'descfile');
      v_seqno		      := hcm_util.get_string_t(data_row, 'numseq');

      if v_flg = 'add' then
        begin
          select nvl(max(seqno),0)+1 into v_seqno
          from tobfreqf
          where codempid = p_codempid
           and dtereq = p_dtereq
            and numseq = p_numseq;
        exception when no_data_found then
          v_seqno := 1;
        end;
        begin
          insert into tobfreqf (codempid, dtereq, numseq, seqno, filename, descfile, dtecreate, codcreate, coduser)
          values (p_codempid, p_dtereq, p_numseq, v_seqno, v_filename, v_descfile, sysdate, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      elsif v_flg = 'edit' then
        update tobfreqf
           set filename = v_filename,
               descfile = v_descfile
         where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq
           and seqno  = v_seqno;
      elsif v_flg = 'delete' then
        delete tobfreqf
         where codempid = p_codempid
           and dtereq = p_dtereq
           and numseq = p_numseq
           and seqno = v_seqno;
      end if;
    end loop;
  end;
  --
  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    json_obj       json_object_t;
    data_obj       json_object_t;
  begin
    initial_value(json_str_input);
    initial_save(json_str_input);
    check_save;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_tobfreq;
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
  --
  function benefit_secure return varchar2 is
    v_codunit   tobfcde.codunit%type;
    v_amtvalue  tobfcde.amtvalue%type;
    v_syncond   tobfcde.syncond%type;
    v_typepay   tobfcde.typepay%type;
    v_flglimit  tobfcde.flglimit%type;
    v_typebf    tobfcde.typebf%type;
    v_dtestart  tobfcft.dtestart%type;
    v_amtalwyr  tobfcft.amtalwyr%type;
    v_qtyalw    tobfcdet.qtyalw%type;
    v_qtytalw   tobfcdet.qtytalw%type;
    v_cond      tobfcde.syncond%type;
    v_cond2     tobfcde.syncond%type;
    v_flgExist  varchar2(2 char);
    v_stmt      varchar2(4000 char);
    v_stmt2     varchar2(4000 char);
    v_flgcond1  number;
    v_flgcond2  number;
    v_qtytacc   number;
    v_amtacc    number;
    v_errorno   varchar2(30 char);
    v_flgsecur  boolean := false;
    v_qtywidrw_tobfreq  number;
    v_qtywidrw  number;
    v_amtwidrw  number;
  begin
    std_bf.get_benefit(p_query_codempid,p_codobf,p_codrel,p_dtereq,p_numseq,null,p_amtwidrw,'Y',
                       v_codunit,v_amtvalue,v_typepay,v_typebf,v_flglimit,
                       v_qtytacc,v_amtacc,v_qtywidrw,v_amtwidrw,v_qtytalw,
                       v_errorno);

    return v_errorno;
  end;
--  function benefit_secure return varchar2 is
--    obj_data    json_object_t;
--    v_codunit   tobfcde.codunit%type;
--    v_amtvalue  tobfcde.amtvalue%type;
--    v_syncond   tobfcde.syncond%type;
--    v_typepay   tobfcde.typepay%type;
--    v_flglimit  tobfcde.flglimit%type;
--    v_typebf    tobfcde.typebf%type;
--    v_dtestart  tobfcft.dtestart%type;
--    v_amtalwyr  tobfcft.amtalwyr%type;
--    v_qtyalw    tobfcdet.qtyalw%type;
--    v_qtytalw   tobfcdet.qtytalw%type;
--    v_cond      tobfcde.syncond%type;
--    v_cond2     tobfcde.syncond%type;
--    v_flgExist  varchar2(2 char);
--    v_stmt      varchar2(4000 char);
--    v_stmt2     varchar2(4000 char);
--    v_flgcond1  number;
--    v_flgcond2  number;
--    v_qtytwidrw number;
--    v_flgsecur  boolean := false;
--    v_qtywidrw_tobfreq  number;
--    v_qtywidrw  number;
--    v_amtwidrw  number;
--
--    v_errorno    varchar2(10 char);
--    cursor c1 is
--      select *
--        from tobfcdet
--       where codobf = p_codobf
--       order by numobf;
--  begin
--    begin
--      select codunit,amtvalue,typepay, flglimit, typebf
--        into v_codunit,v_amtvalue,v_typepay, v_flglimit, v_typebf
--        from tobfcde
--       where codobf = p_codobf;
--    exception when no_data_found then
--        v_codunit  := '';
--        v_amtvalue := '';
--    end;
--    -- Default
--    v_qtywidrw_tobfreq := 0;
--    v_qtywidrw := 0;
--    v_amtwidrw := 0;
--    begin
--      select dtestart, amtalwyr into v_dtestart, v_amtalwyr
--        from tobfcft
--       where codempid = p_query_codempid
--         and dtestart = (select max(dtestart)
--                           from tobfcft
--                          where codempid = p_query_codempid
--                            and (dtestart <= p_dtereq
--                            and  nvl(dteend, p_dtereq) >= p_dtereq) );--redmine4758
--      v_flgExist := 'Y';
--    exception when no_data_found then
--      v_dtestart  := null;
--      v_amtalwyr  := null;
--      v_flgExist  := 'N';
--    end;
--
--    if v_flgExist = 'Y' then
--      v_flgsecur  := true;
--      begin
--        select nvl(qtyalw,0) qtyalw,nvl(qtytalw,0) qtytalw
--          into v_qtyalw, v_qtytalw
--          from tobfcftd
--         where codempid = p_query_codempid
--           and dtestart = v_dtestart
--           and codobf = p_codobf;
--      exception when no_data_found then
--        v_qtyalw  := null;
--        v_qtytalw := null;
--      end;
--
--      if p_numtsmit > v_qtytalw then
--        v_errorno := 'BF0054';
--      end if;
--      --
--
--    -----------------
--    elsif v_flgExist = 'N' then
--      begin
--        select syncond into v_syncond
--          from tobfcde
--         where codobf = p_codobf
--           and dtestart = (select max(dtestart)
--                             from tobfcde
--                            where codobf = p_codobf
--                              and (nvl(dtestart, p_dtereq) <= p_dtereq    --and nvl(dtestart, p_dtereq) <= p_dtereq --#6974 || User39 || 26/10/2021
--                                or nvl(dteend, p_dtereq) >= p_dtereq)); --or nvl(dteend, p_dtereq) >= p_dtereq); --#6974 || User39 || 26/10/2021
--      exception when no_data_found then
--        v_syncond := null;
--      end;
--      if v_syncond is not null then
--        v_cond := 'and ' || v_syncond;
--        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--        v_stmt :=  'select count(*)'||
--                   'from V_HRBF41,tobfcde '||
--                   'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                   'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
--                   v_cond||' '||
--                   'and rownum = 1';
--
--        execute immediate v_stmt into v_flgcond1;
--        if v_flgcond1 > 0 then
--          for r1 in c1 loop
--            if r1.syncond is not null then
--              v_cond2 := 'and ' || r1.syncond;
--              v_cond2 := replace(v_cond2,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--              v_stmt2 := 'select count(*)'||
--                         'from V_HRBF41,tobfcde '||
--                         'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                         'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
--                         v_cond2||' '||
--                         'and rownum = 1';
--              execute immediate v_stmt2 into v_flgcond2;
--              if v_flgcond2 > 0 then
--                v_qtyalw    := r1.qtyalw;
--                v_qtytalw   := r1.qtytalw;
--                v_flgsecur  := true;
--                exit;
--              end if;
--            end if;
--          end loop; --for r1 in c1 loop
--        end if;
--      end if;--v_syncond is not null then
--      --
--      if v_flglimit = 'M' then
-- --สิทธิเป็นต่อเดือน count(*) from tobfreq where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = เดือนของ ‘วันที่ขอ’
--        begin
--          select  sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--            from tobfreq
--           where codempid = p_query_codempid
--             and codobf = p_codobf
--             and to_char(dtereq,'YYYYMM') = to_char(sysdate,'YYYYMM')
--             and staappr in ('P','A')
--             and not(dtereq = p_dtereq and numseq = p_numseq);
--        exception when no_data_found then
--          v_qtywidrw_tobfreq := 0;
--        end;
--        --
--        begin
--          select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--            from tobfsum
--           where codempid = p_query_codempid
--             and codobf = p_codobf
--             and dteyre = to_char(sysdate,'yyyy')
--             and dtemth = to_char(sysdate,'mm');
--        exception when no_data_found then
--          v_qtywidrw := nvl(p_amtwidrw,0);
--        end;
--        v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      ----
--      elsif v_flglimit = 'Y' then
----	ถ้าสิทธิเป็นต่อปี count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = ปีของ ‘วันที่ขอ’
--        begin
--          select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--            from tobfreq
--           where codempid = p_query_codempid
--             and codobf = p_codobf
--             and to_char(dtereq,'YYYY') = to_char(sysdate,'YYYY')
--             and staappr in ('P','A')
--             and not(dtereq = p_dtereq and numseq = p_numseq);
--        exception when no_data_found then
--          v_qtywidrw_tobfreq := 0;
--        end;
--        --
--        begin
--          select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--            from tobfsum
--           where codempid = p_query_codempid
--             and codobf = p_codobf
--             and dteyre = to_char(sysdate,'yyyy')
--             and dtemth = 13;
--        exception when no_data_found then
--          v_qtytwidrw := nvl(p_amtwidrw,0);
--        end;
--        v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      ----
--      elsif v_flglimit = 'A' then
----	ถ้าสิทธิเป็นตลอดอายุงาน count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A
--        begin
--          select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--            from tobfreq
--           where codempid = p_query_codempid
--             and codobf = p_codobf
--             and staappr in ('P','A')
--             and not(dtereq = p_dtereq and numseq = p_numseq);
--        exception when no_data_found then
--          v_qtywidrw_tobfreq := 0;
--        end;
--        --
--        begin
--          select nvl(sum(qtywidrw),0) + nvl(p_amtwidrw,0) into v_qtywidrw
--            from tobfsum
--           where codempid = p_query_codempid
--             and codobf   = p_codobf;
--        exception when no_data_found then
--          v_qtytwidrw := nvl(p_amtwidrw,0);
--        end;
--        v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      end if;
--      --
--      if not v_flgsecur then
--        v_errorno := 'HR2055';
--      else
----insert_temp2('ES74E','ES74E',p_query_codempid,p_dtereq,p_numseq,p_codobf,'chk BF0054: '||p_numtsmit ||' vs '|| v_qtytalw,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));    
--        if p_numtsmit > v_qtytalw then
--          v_errorno := 'BF0054';
--        end if;
--
----insert_temp2('ES74E','ES74E',p_query_codempid,p_dtereq,p_numseq,p_codobf,'chk BF0053: '||v_qtywidrw ||' vs '|| v_qtyalw,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));    
--        if v_qtywidrw > v_qtyalw then
--          v_errorno := 'BF0053';
--        end if;
--      end if;
--      --
--    end if; --if v_flglimit = 'M'
--
--    return v_errorno;
--  end benefit_secure;

--  function benefit_secure return varchar2 is
--    obj_data    json_object_t;
--    v_codunit   tobfcde.codunit%type;
--    v_amtvalue  tobfcde.amtvalue%type;
--    v_syncond   tobfcde.syncond%type;
--    v_typepay   tobfcde.typepay%type;
--    v_flglimit  tobfcde.flglimit%type;
--    v_typebf    tobfcde.typebf%type;
--    v_dtestart  tobfcft.dtestart%type;
--    v_amtalwyr  tobfcft.amtalwyr%type;
--    v_qtyalw    tobfcdet.qtyalw%type;
--    v_qtytalw   tobfcdet.qtytalw%type;
--    v_cond      tobfcde.syncond%type;
--    v_cond2     tobfcde.syncond%type;
--    v_flgExist  varchar2(2 char);
--    v_stmt      varchar2(4000 char);
--    v_stmt2     varchar2(4000 char);
--    v_flgcond1  number;
--    v_flgcond2  number;
--    v_qtytwidrw number;
--    v_flgsecur  boolean := false;
--    v_qtywidrw_tobfreq  number;
--    v_qtywidrw  number;
--    v_amtwidrw  number;
--
--    v_errorno    varchar2(10 char);
--    cursor c1 is
--      select *
--        from tobfcdet
--       where codobf = p_codobf
--       order by numobf;
--  begin
--        begin
--      select codunit,amtvalue,typepay, flglimit, typebf
--        into v_codunit,v_amtvalue,v_typepay, v_flglimit, v_typebf
--        from tobfcde
--       where codobf = p_codobf;
--    exception when no_data_found then
--        v_codunit  := '';
--        v_amtvalue := '';
--    end;
--    -- Default
--    v_qtywidrw_tobfreq := 0;
--    v_qtywidrw := 0;
--    v_amtwidrw := 0;
--    begin
--      select dtestart, amtalwyr into v_dtestart, v_amtalwyr
--          from tobfcft
--         where codempid =  p_query_codempid
--           and dtestart = (select max(dtestart)
--                             from tobfcft
--                            where codempid = p_query_codempid
--                              and (dtestart <= p_dtereq
--                                     and  nvl(dteend, p_dtereq) >= p_dtereq) );--redmine4758
--      v_flgExist := 'Y';
--    exception when no_data_found then
--      v_dtestart  := null;
--      v_amtalwyr  := null;
--      v_flgExist  := 'N';
--    end;
--
--    if v_flgExist = 'Y' then
--          v_flgsecur  := true;
--          begin
--            select nvl(qtyalw,0) qtyalw,nvl(qtytalw,0) qtytalw
--              into v_qtyalw, v_qtytalw
--              from tobfcftd
--             where codempid = p_query_codempid
--               and dtestart = v_dtestart
--               and codobf = p_codobf;
--          exception when no_data_found then
--            v_qtyalw := null;
--            v_qtytalw := null;
--          end;
--
--          if p_numtsmit > v_qtytalw then
--            v_errorno := 'BF0054';
--          end if;
--          --
--      if v_flglimit = 'M' then
--
-- --สิทธิเป็นต่อเดือน count(*) from tobfreq where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = เดือนของ ‘วันที่ขอ’
--              begin
--                select  sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--                  from tobfreq
--                 where codempid = p_query_codempid
--                   and codobf = p_codobf
--                   and to_char(dtereq,'YYYYMM') = to_char(sysdate,'YYYYMM')
--                   and staappr in ('P','A');
--              exception when no_data_found then
--                v_qtywidrw_tobfreq := 0;
--              end;
--    ----
--              begin
--                  select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                    from tobfsum
--                   where codempid = p_query_codempid
--                     and codobf = p_codobf
--                     and dteyre = to_char(sysdate,'yyyy')
--                     and dtemth = to_char(sysdate,'mm');
--              exception when no_data_found then
--                  v_qtywidrw := nvl(p_amtwidrw,0);
--              end;
--              v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      elsif v_flglimit = 'Y' then
----	ถ้าสิทธิเป็นต่อปี count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = ปีของ ‘วันที่ขอ’
--              begin
--                select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--                  from tobfreq
--                 where codempid = p_query_codempid
--                   and codobf = p_codobf
--                   and to_char(dtereq,'YYYY') = to_char(sysdate,'YYYY')
--                   and staappr in ('P','A');
--              exception when no_data_found then
--                v_qtywidrw_tobfreq := 0;
--              end;
--              ---
--              begin
--                  select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                    from tobfsum
--                   where codempid = p_query_codempid
--                     and codobf = p_codobf
--                     and dteyre = to_char(sysdate,'yyyy')
--                     and dtemth = 13;
--              exception when no_data_found then
--                  v_qtytwidrw := nvl(p_amtwidrw,0);
--              end;
--              v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      elsif v_flglimit = 'A' then
----	ถ้าสิทธิเป็นตลอดอายุงาน count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A
--               begin
--                select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--                  from tobfreq
--                 where codempid = p_query_codempid
--                   and codobf = p_codobf
--                   and staappr in ('P','A');
--               exception when no_data_found then
--                 v_qtywidrw_tobfreq := 0;
--               end;
--
--                begin
--                  select nvl(sum(qtywidrw),0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                    from tobfsum
--                   where codempid = p_query_codempid
--                     and codobf = p_codobf;
--                exception when no_data_found then
--                  v_qtytwidrw := nvl(p_amtwidrw,0);
--                end;
--                v_qtywidrw := v_qtywidrw + nvl(v_qtywidrw_tobfreq,0);
--      end if;
--
--      if v_qtywidrw > v_qtyalw then
--        v_errorno := 'BF0053';
--      end if;
--  -----------------
--  elsif v_flgExist = 'N' then
--      begin
--      select syncond into v_syncond
--        from tobfcde
--       where codobf = p_codobf
--         and dtestart = (select max(dtestart)
--                           from tobfcde
--                          where codobf = p_codobf
--                            and (nvl(dtestart, p_dtereq) <= p_dtereq    --and nvl(dtestart, p_dtereq) <= p_dtereq --#6974 || User39 || 26/10/2021
--                                 or nvl(dteend, p_dtereq) >= p_dtereq)); --or nvl(dteend, p_dtereq) >= p_dtereq); --#6974 || User39 || 26/10/2021
--      exception when no_data_found then
--        v_syncond := null;
--      end;
--      if v_syncond is not null then
--        v_cond := 'and ' || v_syncond;
--        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--        v_stmt :=  'select count(*)'||
--                   'from V_HRBF41,tobfcde '||
--                   'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                   'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
--                   v_cond||' '||
--                   'and rownum = 1';
--
--        execute immediate v_stmt into v_flgcond1;
--        if v_flgcond1 > 0 then
--          for r1 in c1 loop
--            if r1.syncond is not null then
--              v_cond2 := 'and ' || r1.syncond;
--              v_cond2 := replace(v_cond2,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--              v_stmt2 := 'select count(*)'||
--                         'from V_HRBF41,tobfcde '||
--                         'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                         'and V_HRBF41.codempid = '||''''||p_query_codempid||''''||' '||
--                         v_cond2||' '||
--                         'and rownum = 1';
--              execute immediate v_stmt2 into v_flgcond2;
--              if v_flgcond2 > 0 then
--                v_qtyalw := r1.qtyalw;
--                v_qtytalw := r1.qtytalw;
--                if v_flglimit = 'M' then
--                  begin
--                    select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_query_codempid
--                       and codobf = p_codobf
--                       and dteyre = to_char(sysdate,'yyyy')
--                       and dtemth = to_char(sysdate,'mm');
--                  exception when no_data_found then
--                    v_qtywidrw := nvl(p_amtwidrw,0);
--                  end;
--                elsif v_flglimit = 'Y' then
--                  begin
--                    select nvl(qtywidrw,0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_query_codempid
--                       and codobf = p_codobf
--                       and dteyre = to_char(sysdate,'yyyy')
--                       and dtemth = 13;
--                  exception when no_data_found then
--                    v_qtytwidrw := nvl(p_amtwidrw,0);
--                  end;
--                elsif v_flglimit = 'A' then
--                  begin
--                    select nvl(sum(qtywidrw),0) + nvl(p_amtwidrw,0) into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_query_codempid
--                       and codobf = p_codobf;
--                  exception when no_data_found then
--                    v_qtytwidrw := nvl(p_amtwidrw,0);
--                  end;
--                end if;
--                v_flgsecur := true;
--                exit;
--              end if;
--            end if;
--          end loop; --for r1 in c1 loop
--        end if;
--      end if;--v_syncond is not null then
--
--      if not v_flgsecur then
--        v_errorno := 'HR2055';
--      else
--            if p_numtsmit > v_qtytalw then
--              v_errorno := 'BF0054';
--            end if;
--
--            if v_qtywidrw > v_qtyalw then
--              v_errorno := 'AL0051';--test-- 'BF0053'
--            end if;
--      end if;
--
--   end if;
--
--    -- return error no
--    return v_errorno;
--  end benefit_secure;

end hres74e;

/

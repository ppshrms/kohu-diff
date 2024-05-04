--------------------------------------------------------
--  DDL for Package Body HRBF43E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF43E" as
  procedure initial_value(json_str_input in clob) is
    json_obj          json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_query_codempid  := hcm_util.get_string_t(json_obj,'p_query_codempid');
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtereq          := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq          := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codrel          := hcm_util.get_string_t(json_obj,'p_typrelate');
    p_dtereqst        := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    p_dtereqen        := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    p_codobf          := hcm_util.get_string_t(json_obj,'p_codobf');
    param_json        := hcm_util.get_json_t(json_obj,'param_json');
    param_detail      := hcm_util.get_json_t(json_obj,'detail');
    p_numvcher        := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_codempid        := hcm_util.get_string_t(json_obj,'p_codempid');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_temp     varchar(1 char);
  begin

    if p_codcomp is not null then
      begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = '1';
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return;
      end;

      if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_query_codempid is not null then
      begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
        return;
      end;

      if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

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
    v_flgvoucher     tobfinf.flgvoucher%type;
    v_flgtranpy      tobfinf.flgtranpy%type;
    cursor c1 is
      select dtereq,numvcher,codobf,typrelate,qtywidrw,codempid
        from tobfinf
        where codempid = nvl(p_query_codempid,codempid)
          and codcomp like nvl(p_codcomp,codcomp)||'%'
          and dtereq between p_dtereqst and p_dtereqen;

  begin
    obj_rows := json_object_t();
    for r1 in c1 loop
      v_row := nvl(v_row,0)+1;
      obj_data := json_object_t();
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy') );
      obj_data.put('numvcher', r1.numvcher );
      obj_data.put('codobf', r1.codobf );
      obj_data.put('desc_codobf', get_tobfcde_name(r1.codobf,global_v_lang) );
      obj_data.put('desc_typrelate', get_tlistval_name('TYPERELATE',r1.typrelate,global_v_lang) );
      obj_data.put('codempid',r1.codempid);
      obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('typrelate',r1.typrelate);
      obj_data.put('typrelate_name',get_tlistval_name('TYPERELATE',r1.typrelate,global_v_lang));
      obj_data.put('status',get_tlistval_name('STAUPD','C',global_v_lang));
      begin
        select flgvoucher, flgtranpy
          into v_flgvoucher, v_flgtranpy
          from tobfinf
         where numvcher = r1.numvcher;
      exception when no_data_found then
        v_flgvoucher := '';
        v_flgtranpy  := '';
      end;
      obj_data.put('flgtranpy',v_flgtranpy);
      obj_data.put('flgvoucher',v_flgvoucher);
      obj_data.put('qtywidrw',r1.qtywidrw);
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
    v_tobfinf   tobfinf%rowtype;
  begin
    begin
      select * into v_tobfinf
      from tobfinf
      where numvcher = p_numvcher;
      v_flag    := 'edit';
    exception when no_data_found then
      v_tobfinf := null;
      v_flag    := 'add';
    end;

    begin
      select codcomp,codpos into v_codcomp,v_codpos
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    if v_flag = 'add' then
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codempid', p_codempid );
      obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang) );
      obj_data.put('codcomp', v_codcomp );
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang) );
      begin
        select costcent into v_costcenter
        from tcenter
        where codcomp = v_codcomp;
      exception when no_data_found then null;
      end;

      obj_data.put('codcenter', v_costcenter );
      obj_data.put('desc_codcenter', get_tcoscent_name(v_costcenter,global_v_lang) );
      obj_data.put('codobf','');
      obj_data.put('codunit', '' );
      obj_data.put('amtvalue', '' );
      obj_data.put('typrelateobf', '' ); ----
      obj_data.put('flgfamily', '' ); ----
      obj_data.put('typrelate','');
      obj_data.put('nameobf','');
      obj_data.put('numtsmit','');
      obj_data.put('qtywidrw','');
      obj_data.put('amtwidrw','');
      obj_data.put('typepay','');
      obj_data.put('typebf', '' );
      obj_data.put('flag',v_flag);
      obj_data.put('dtereq',to_char(p_dtereq,'dd/mm/yyyy'));
      obj_data.put('dtepay',to_char(v_tobfinf.dtepay,'dd/mm/yyyy'));
      obj_data.put('numperiod',v_tobfinf.numperiod);
      obj_data.put('dtemthpay',v_tobfinf.dtemthpay);
      obj_data.put('dteyrepay',v_tobfinf.dteyrepay);
      obj_data.put('desnote',v_tobfinf.desnote);
      obj_data.put('flgtranpy',v_tobfinf.flgtranpy);
      obj_data.put('flgvoucher',v_tobfinf.flgvoucher);
      obj_data.put('codappr',v_tobfinf.codappr);
      obj_data.put('dteappr',to_char(v_tobfinf.dteappr,'dd/mm/yyyy'));
      obj_data.put('numvcher',p_numvcher);
      obj_data.put('msgerror', '');

    elsif v_flag = 'edit' then
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codempid', v_tobfinf.codempid );
      obj_data.put('desc_codempid', get_temploy_name(v_tobfinf.codempid, global_v_lang) );
      obj_data.put('codcomp', v_tobfinf.codcomp );
      obj_data.put('desc_codcomp', get_tcenter_name(v_tobfinf.codcomp, global_v_lang) );
      begin
        select costcent into v_costcenter
        from tcenter
        where codcomp = v_tobfinf.codcomp;
      exception when no_data_found then null;
      end;
      begin
        select amtvalue, codunit, typebf
          into v_amtvalue, v_codunit, v_typebf
          from tobfcde
         where codobf = v_tobfinf.codobf;
      exception when no_data_found then null;
      end;
      obj_data.put('codcenter', v_costcenter );
      obj_data.put('desc_codcenter', get_tcoscent_name(v_costcenter,global_v_lang) );
      obj_data.put('codobf',v_tobfinf.codobf);
      obj_data.put('codunit', v_codunit );
      obj_data.put('msgerror', '');
      obj_data.put('amtvalue',v_tobfinf.amtvalue );
      obj_data.put('amtwidrw',v_tobfinf.amtwidrw);
      if nvl(v_tobfinf.flgtranpy,'N') <> 'Y' then
        if v_typebf = 'T' then
          obj_data.put('amtvalue',v_amtvalue );
          obj_data.put('amtwidrw',v_amtvalue*v_tobfinf.qtywidrw);
          if  v_tobfinf.amtvalue <> v_amtvalue then
            obj_data.put('msgerror', replace(get_error_msg_php('BF0074',global_v_lang),'@#$%400') );
          end if;
        end if;
      end if;
      obj_data.put('typrelate',v_tobfinf.typrelate);
      obj_data.put('nameobf',v_tobfinf.nameobf);
      obj_data.put('numtsmit',v_tobfinf.numtsmit);
      obj_data.put('qtywidrw',v_tobfinf.qtywidrw);
      obj_data.put('typepay',v_tobfinf.typepay);
      obj_data.put('typebf', v_typebf );
      obj_data.put('flag',v_flag);
      obj_data.put('dtereq',to_char(v_tobfinf.dtereq,'dd/mm/yyyy'));
      obj_data.put('dtepay',to_char(v_tobfinf.dtepay,'dd/mm/yyyy'));
      obj_data.put('numperiod',v_tobfinf.numperiod);
      obj_data.put('dtemthpay',v_tobfinf.dtemthpay);
      obj_data.put('dteyrepay',v_tobfinf.dteyrepay);
      obj_data.put('desnote',v_tobfinf.desnote);
      obj_data.put('flgtranpy',v_tobfinf.flgtranpy);
      obj_data.put('flgvoucher',v_tobfinf.flgvoucher);
      obj_data.put('codappr',v_tobfinf.codappr);
      obj_data.put('dteappr',to_char(v_tobfinf.dteappr,'dd/mm/yyyy'));
      obj_data.put('numvcher',p_numvcher);
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
      select numseq,filename,descattch
      from tobfattch
      where numvcher = p_numvcher;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('numseq',i.numseq);
      obj_data.put('filename',i.filename);
      obj_data.put('descfile',i.descattch);
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
      obj_data.put('namsick', get_temploy_name(p_codempid,global_v_lang));
    elsif p_codrel = 'S' then
      begin
        select decode(global_v_lang,'101',namspe
                           ,'102',namspt
                           ,'103',namsp3
                           ,'104',namsp4
                           ,'105',namsp5) as namsp
          into v_namsick
          from tspouse
         where codempid = p_codempid;
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
         where codempid = p_codempid;
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
         where codempid = p_codempid;
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
    v_nameobf   varchar2(4000 char);

    /*cursor c1 is
      select *
        from tobfcdet
       where codobf = p_codobf
       order by numobf;*/
  begin
    std_bf.get_benefit(p_codempid,p_codobf,p_codrel,p_dtereq,null,nvl(p_numvcher,'-'),p_amtwidrw,'Y',
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
      ----
      v_typepay   := '';
      v_flglimit  := '';
      v_typebf    := '';
    end;
    -- Default
    v_qty_tobfreq := 0;
    v_qtywidrw := 0;
    v_amtwidrw := 0;
    begin
      select dtestart, amtalwyr into v_dtestart, v_amtalwyr
          from tobfcft
         where codempid =  p_codempid
           and dtestart = (select max(dtestart)
                             from tobfcft
                            where codempid = p_codempid
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
         where codempid = p_codempid
           and dtestart = v_dtestart
           and codobf = p_codobf;
      exception when no_data_found then
        v_qtyalw := null;
        v_qtytalw := null;
      end;
      if v_typebf = 'C' then
        v_qtywidrw := v_amtvalue;
        v_amtwidrw := v_amtvalue;
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
                            and nvl(dtestart, p_dtereq) <= p_dtereq
                            or nvl(dteend, p_dtereq) >= p_dtereq);
      exception when no_data_found then
        v_syncond := null;
      end;
      if v_syncond is not null then
        v_cond := 'and ' || v_syncond;
        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
        v_stmt :=  'select count(*)'||
                   'from V_HRBF41,tobfcde,TCLNSINF '||
                   'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
                   'and V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                   v_cond||' '||
                   'and rownum = 1';

        execute immediate v_stmt into v_flgcond1;
        if v_flgcond1 > 0 then
          for r1 in c1 loop
            if r1.syncond is not null then
              v_cond2 := 'and ' || r1.syncond;
              v_cond2 := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
              v_stmt2 := 'select count(*)'||
                         'from V_HRBF41,tobfcde,TCLNSINF '||
                         'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
                         'and V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
                         v_cond2||' '||
                         'and rownum = 1';
              execute immediate v_stmt2 into v_flgcond2;
              if v_flgcond2 > 0 then
                v_qtyalw := r1.qtyalw;
                v_qtytalw := r1.qtytalw;
                if v_typebf = 'C' then
                  v_qtywidrw := v_amtvalue;
                  v_amtwidrw := v_amtvalue;
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
         where codempid = p_codempid
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
         where codempid = p_codempid
           and codobf = p_codobf
           and dteyre = to_char(sysdate,'yyyy')
           and dtemth = to_char(sysdate,'mm');
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw+v_qty_tobfreq;

    elsif v_flglimit = 'Y' then
--	ถ้าสิทธิเป็นต่อปี count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = ปีของ ‘วันที่ขอ’
      begin
        select count(*)  into v_qty_tobfreq
          from tobfreq
         where codempid = p_codempid
           and codobf = p_codobf
           and to_char(dtereq,'YYYY') = to_char(sysdate,'YYYY')
           and staappr in ('P','A');
      exception when no_data_found then
        v_qty_tobfreq := 0;
      end;

      begin
        select nvl(qtytwidrw,0) + 1 into v_qtytwidrw
          from tobfsum
         where codempid = p_codempid
           and codobf = p_codobf
           and dteyre = to_char(sysdate,'yyyy')
           and dtemth = 13;
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw+v_qty_tobfreq;

    elsif v_flglimit = 'A' then
--	ถ้าสิทธิเป็นตลอดอายุงาน count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A
      begin
        select count(*)  into v_qty_tobfreq
          from tobfreq
         where codempid = p_codempid
           and codobf = p_codobf
           and staappr in ('P','A');
      exception when no_data_found then
        v_qty_tobfreq := 0;
      end;

      begin
        select nvl(max(qtytwidrw),0) + 1-- v_qty_tobfreq + count(qtytwidrw) + 1
          into v_qtytwidrw
          from tobfsum
         where codempid = p_codempid
           and codobf = p_codobf;
      exception when no_data_found then
        v_qtytwidrw := 1;
      end;
      v_qtytwidrw := v_qtytwidrw+v_qty_tobfreq;
    end if;*/

--    if v_flgsecur then
      obj_data := json_object_t();
      obj_data.put('coderror',200);
      obj_data.put('codunit',v_codunit);
      obj_data.put('codunit_name',get_tcodec_name('TCODUNIT',v_codunit,global_v_lang));
      obj_data.put('amtvalue',v_amtvalue);
      obj_data.put('typepay',v_typepay);
      obj_data.put('typrelate', 'E' );
      obj_data.put('typebf', v_typebf );
      obj_data.put('nameobf', get_temploy_name(p_codempid, global_v_lang));
      obj_data.put('numtsmit', v_qtytacc + 1 ); -- เบิกครั้งที่
      --<< user4 || 29/03/2023 || 4449#820
      -- obj_data.put('qtywidrw', v_qtywidrw ); -- จำนวนที่ขอเบิก
      v_qtytalw := nvl(v_qtytalw,0);
      if v_qtytalw > 0 then
        obj_data.put('qtywidrw', v_qtywidrw /nvl(v_qtytalw,0)); -- จำนวนที่ขอเบิก
      else
        obj_data.put('qtywidrw', '0'); -- จำนวนที่ขอเบิก
      end if;
      -->> user4 || 29/03/2023 || 4449#820
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
    param_json_row  json_object_t;
    param_index     json_object_t;
    data_row        json_object_t;

    v_flg	        varchar2(1000 char);
    v_flgupd	    varchar2(1000 char);
    v_numvcher	    varchar2(1000 char);
    v_dtereq        varchar2(1000 char);
    v_numseq        number;
    v_tobfinf       tobfinf%rowtype;
  begin
    initial_value(json_str_input);
    for i in 0..param_json.get_size-1 loop
        data_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_numvcher    := hcm_util.get_string_t(data_row,'numvcher');
        begin
          select * into v_tobfinf
            from tobfinf
           where numvcher = v_numvcher;
        exception when no_data_found then
            null;
        end;

        delete tobfinf where numvcher = v_numvcher;
        delete tobfattch where numvcher = v_numvcher;

        save_tobfsum(v_tobfinf.codempid, v_tobfinf.dtereq, v_tobfinf.codobf,
                     v_tobfinf.codcomp, v_tobfinf.qtyalw, v_tobfinf.qtytalw);
        save_tobfdep(v_tobfinf.dtereq,v_tobfinf.codobf,v_tobfinf.codcomp);
    end loop;

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
    p_amtvalue       := to_number(hcm_util.get_string_t(param_detail,'amtvalue'));
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
    p_dtepay         := to_date(hcm_util.get_string_t(param_detail,'dtepay'),'dd/mm/yyyy');
    p_dteyrepay      := to_number(hcm_util.get_string_t(param_detail,'dteyrepay'));
    p_dtemthpay      := to_number(hcm_util.get_string_t(param_detail,'dtemthpay'));
    p_numperiod      := to_number(hcm_util.get_string_t(param_detail,'numperiod'));
    p_codappr         := hcm_util.get_string_t(param_detail,'codappr');
    p_dteappr         := to_date(hcm_util.get_string_t(param_detail,'dteappr'),'dd/mm/yyyy');
    p_numvcher        := hcm_util.get_string_t(param_detail,'numvcher');
  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure check_save is
    v_errorno       varchar2(10 char);
    v_namsp         tspouse.namspe%type;
    v_chkExist      number;
    v_flgfamily     tobfcde.flgfamily%type; ----
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
    ----<<
    --check use for family
    if p_typrelate <> 'E' then
      begin
        select nvl(flgfamily,'N') ----
          into v_flgfamily ----
          from tobfcde
         where codobf = p_codobf;
      exception when no_data_found then null;
      end;
      if v_flgfamily <> 'Y' then
        param_msg_error := get_error_msg_php('BF0081',global_v_lang);
        return;
      end if;
    end if;
    ---->>

  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;
  --
  procedure save_tobfinf is
    v_count         number := 0;
    data_row        json_object_t;
    v_flg     	    varchar2(10 char);
    v_filename		tobfreqf.filename%type;
    v_descfile		tobfreqf.descfile%type;
    v_seqno		    tobfreqf.seqno%type;
    v_qtywidrw      number;
    v_amtwidrw      number;
    v_numvcher     tobfinf.numvcher%type;
    v_numvcher2    tobfinf.numvcher%type;
  begin
    begin
      select count(*) into v_count
        from tobfinf
       where numvcher = p_numvcher;
    exception when no_data_found then
        null;
    end;

    if p_typebf = 'T' then
        v_qtywidrw := p_qtywidrw;
        v_amtwidrw := nvl(p_amtvalue,0) * nvl(p_qtywidrw,0);
    elsif p_typebf = 'C' then
        v_qtywidrw := p_qtywidrw;
        v_amtwidrw := p_qtywidrw;
    end if;

    if v_count = 0 then

        p_numvcher := get_codcompy(p_codcomp)||to_char(p_dtereq,'yy')||to_char(p_dtereq,'mm');

        begin
            select max(numvcher) into v_numvcher
            from tobfinf
            where numvcher like p_numvcher || '%';
        exception when no_data_found then null;
        end;

        v_numvcher2 := substr(v_numvcher,-8,4);

        if substr(p_numvcher,-4,4) = v_numvcher2 then
            v_numvcher := lpad(substr(v_numvcher,-4,4)+1,4,1);
            p_numvcher := p_numvcher||v_numvcher;
        else
            p_numvcher := p_numvcher||'0000';
        end if;

        insert into tobfinf(numvcher,codempid,codcomp,dtereq,codobf,typrelate,nameobf,numtsmit,qtywidrw,amtwidrw,qtyalw,
                                qtytalw,typepay,dtepay,flgtranpy,dteyrepay,dtemthpay,numperiod,desnote,codappr,dteappr,codcreate,coduser,amtvalue)
            values(p_numvcher,p_codempid,p_codcomp,p_dtereq,p_codobf,p_typrelate,p_nameobf,p_numtsmit,v_qtywidrw,v_amtwidrw,
                   p_qtyalw,p_qtytalw,p_typepay,p_dtepay,'N',p_dteyrepay,p_dtemthpay,p_numperiod,p_desnote,p_codappr,p_dteappr,global_v_coduser,global_v_coduser,p_amtvalue);
    else
        update tobfinf
            set codempid = p_codempid,
                codcomp = p_codcomp,
                dtereq = p_dtereq,
                codobf = p_codobf,
                typrelate = p_typrelate,
                nameobf = p_nameobf,
                numtsmit = p_numtsmit,
                qtywidrw = v_qtywidrw,
                amtwidrw = v_amtwidrw,
                qtyalw = p_qtyalw,
                qtytalw = p_qtytalw,
                typepay = p_typepay,
                dtepay = p_dtepay,
                dteyrepay = p_dteyrepay,
                dtemthpay = p_dtemthpay,
                numperiod = p_numperiod,
                desnote = p_desnote,
                codappr = p_codappr,
                dteappr = p_dteappr,
                coduser = global_v_coduser,
                amtvalue = p_amtvalue
            where numvcher = p_numvcher;
    end if;

    save_tobfdep(p_dtereq,p_codobf,p_codcomp);
    save_tobfsum( p_codempid, p_dtereq, p_codobf,
                   p_codcomp, p_qtyalw, p_qtytalw);

    for i in 0..param_json.get_size-1 loop
      data_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flg     		  := hcm_util.get_string_t(data_row, 'flg');
      v_filename		  := hcm_util.get_string_t(data_row, 'filename');
      v_descfile		  := hcm_util.get_string_t(data_row, 'descfile');
      v_seqno		      := hcm_util.get_string_t(data_row, 'numseq');

      if v_flg = 'add' then
        begin
          select nvl(max(numseq),0)+1 into v_seqno
          from tobfattch
          where numvcher = p_numvcher;
        exception when no_data_found then
          v_seqno := 1;
        end;
        begin
          insert into tobfattch (numvcher, numseq, filename, descattch, dtecreate, codcreate, dteupd, coduser)
                         values (p_numvcher, v_seqno, v_filename, v_descfile, sysdate, global_v_coduser, sysdate, global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      elsif v_flg = 'delete' then
        delete tobfattch
         where numvcher = p_numvcher
           and numseq = v_seqno;
      end if;
    end loop;
  end;
  --

  procedure save_detail(json_str_input in clob, json_str_output out clob) as
    --json_obj       json_object_t;
    data_obj       json_object_t;
    json_obj       json;
  begin
    initial_value(json_str_input);
    initial_save(json_str_input);
    check_save;
    if param_msg_error is null then
      if param_msg_error is null then
        save_tobfinf;
        commit;
      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201');
      json_obj   := json();
      json_obj.put('flg','');
      json_obj.put('coderror','');
      json_obj.put('desc_coderror','');
      json_obj.put('response','');
      json_obj.put('field_name','');
      json_obj.put('numvcher',p_numvcher);
      json_obj.put('response',param_msg_error);

      json_str_output := json_obj.to_char;
      --param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      --json_str_output := get_response_message(null,param_msg_error,global_v_lang);
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
    v_flgsecur  boolean := false;
    v_qtywidrw_tobfreq  number;
    v_qtywidrw  number;
    v_amtwidrw  number;
    v_errorno   varchar2(10 char);
  begin
    std_bf.get_benefit(p_codempid,p_codobf,p_codrel,p_dtereq,null,nvl(p_numvcher,'-'),p_amtwidrw,'Y',
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
--        begin
--      select codunit,amtvalue,typepay, flglimit, typebf
--        into v_codunit,v_amtvalue,v_typepay, v_flglimit, v_typebf
--        from tobfcde
--       where codobf = p_codobf;
--    exception when no_data_found then
--        v_codunit  := '';
--        v_amtvalue := '';
--    end;
--    p_typebf := v_typebf;
--    -- Default
--    v_qtywidrw_tobfreq := 0;
--    v_qtywidrw := 0;
--    v_amtwidrw := 0;
--    begin
--      select a.dtestart, a.amtalwyr
--        into v_dtestart, v_amtalwyr
--          from tobfcft a
--         where a.codempid =  p_codempid
--           and a.dtestart = (select max(b.dtestart)
--                             from tobfcft b, tobfcftd c
--                            where b.codempid = p_codempid
--                              and c.codobf = p_codobf
--                              and b.codempid = c.codempid
--                              and b.dtestart = c.dtestart
--                              and (b.dtestart <= p_dtereq
--                                     and  nvl(b.dteend, p_dtereq) >= p_dtereq) );--redmine4758
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
--         where codempid = p_codempid
--           and dtestart = v_dtestart
--           and codobf = p_codobf;
--      exception when no_data_found then
--        v_qtyalw := null;
--        v_qtytalw := null;
--        --v_errorno := 'HR2055';
--      end;
--
--      p_qtyalw  := v_qtyalw;
--      p_qtytalw := v_qtytalw;
--
--      --if v_errorno is null then
--      if p_numtsmit > v_qtytalw then
--        v_errorno := 'BF0054';
--      end if;
--      --
--      if v_flglimit = 'M' then
--
-- --สิทธิเป็นต่อเดือน count(*) from tobfreq where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = เดือนของ ‘วันที่ขอ’
--          begin
--            select  sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--              from tobfreq
--             where codempid = p_codempid
--               and codobf = p_codobf
--               and to_char(dtereq,'YYYYMM') = to_char(p_dtereq,'YYYYMM')
--               and staappr in ('P','A');
--          exception when no_data_found then
--            v_qtywidrw_tobfreq := 0;
--          end;
--    ----
--        /*begin
--          select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
--            from tobfsum
--           where codempid = p_codempid
--             and codobf = p_codobf
--             and dteyre = to_char(p_dtereq,'yyyy')
--             and dtemth = to_char(p_dtereq,'mm');
--        exception when no_data_found then
--          v_qtywidrw := p_amtwidrw;
--        end;*/
--        begin
--          select nvl(qtywidrw,0) + p_qtywidrw into v_qtywidrw
--          from tobfinf
--          where codempid = p_codempid
--            and codobf = p_codobf
--            and to_char(dtereq,'YYYYMM') = to_char(p_dtereq,'YYYYMM')
--            and numvcher <> nvl(p_numvcher,'');
--        exception when no_data_found then
--          v_qtywidrw := p_amtwidrw;
--        end;
--
--        v_qtywidrw := nvl(v_qtywidrw,0) + nvl(v_qtywidrw_tobfreq,0);
--      elsif v_flglimit = 'Y' then
----	ถ้าสิทธิเป็นต่อปี count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A and dtereq = ปีของ ‘วันที่ขอ’
--      begin
--        select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--          from tobfreq
--         where codempid = p_codempid
--           and codobf = p_codobf
--           and to_char(dtereq,'YYYY') = to_char(p_dtereq,'YYYY')
--           and staappr in ('P','A');
--      exception when no_data_found then
--        v_qtywidrw_tobfreq := 0;
--      end;
--      ---
--        /*begin
--          select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
--            from tobfsum
--           where codempid = p_codempid
--             and codobf = p_codobf
--             and dteyre = to_char(p_dtereq,'yyyy')
--             and dtemth = 13;
--        exception when no_data_found then
--          v_qtytwidrw := p_amtwidrw;
--        end;*/
--        begin
--          select nvl(qtywidrw,0) + p_qtywidrw into v_qtywidrw
--          from tobfinf
--          where codempid = p_codempid
--            and codobf = p_codobf
--            and to_char(dtereq,'yyyy') = to_char(p_dtereq,'yyyy')
--            and numvcher <> nvl(p_numvcher,'');
--        exception when no_data_found then
--          v_qtywidrw := p_amtwidrw;
--        end;
--         v_qtywidrw := nvl(v_qtywidrw,0) + nvl(v_qtywidrw_tobfreq,0);
--      elsif v_flglimit = 'A' then
----	ถ้าสิทธิเป็นตลอดอายุงาน count(*) from TOBFREQ where รหัสพนักงาน and รหัสสวัสดิการ and staappr = P, A
--      begin
--        select sum(nvl(amtwidrw,0)) into v_qtywidrw_tobfreq
--          from tobfreq
--         where codempid = p_codempid
--           and codobf = p_codobf
--           and staappr in ('P','A');
--      exception when no_data_found then
--        v_qtywidrw_tobfreq := 0;
--      end;
--
--        /*begin
--          select nvl(sum(qtywidrw),0) + p_amtwidrw into v_qtywidrw
--            from tobfsum
--           where codempid = p_codempid
--             and codobf = p_codobf;
--        exception when no_data_found then
--          v_qtytwidrw := p_amtwidrw;
--        end;
--        v_qtywidrw := nvl(v_qtywidrw,0) + nvl(v_qtywidrw_tobfreq,0);*/
--        begin
--          select nvl(qtywidrw,0) + p_qtywidrw into v_qtywidrw
--          from tobfinf
--          where codempid = p_codempid
--            and codobf = p_codobf
--            and numvcher <> nvl(p_numvcher,'');
--        exception when no_data_found then
--          v_qtywidrw := nvl(v_qtywidrw,0) + nvl(v_qtywidrw_tobfreq,0);
--        end;
--      end if;
--
--      if v_qtywidrw > v_qtyalw then
--        v_errorno := 'BF0053';
--      end if;
--      --end if;
--  -----------------
--    elsif v_flgExist = 'N' then
--      begin
--      select syncond into v_syncond
--        from tobfcde
--       where codobf = p_codobf
--         and dtestart = (select max(dtestart)
--                           from tobfcde
--                          where codobf = p_codobf
--                            and (nvl(dtestart, p_dtereq) <= p_dtereq
--                            or nvl(dteend, p_dtereq) >= p_dtereq));
--      exception when no_data_found then
--        v_syncond := null;
--      end;
--      if v_syncond is not null then
--        v_cond := 'and ' || v_syncond;
--        v_cond := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--        v_stmt :=  'select count(*)'||
--                   'from V_HRBF41,tobfcde '||
--                   'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                   'and V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
--                   v_cond||' '||
--                   'and rownum = 1';
--        execute immediate v_stmt into v_flgcond1;
--        if v_flgcond1 > 0 then
--          for r1 in c1 loop
--            if r1.syncond is not null then
--              v_cond2 := 'and ' || r1.syncond;
--              v_cond2 := replace(v_cond,'V_HRBF41.CODREL',''''||p_codrel||'''') ;
--              v_stmt2 := 'select count(*)'||
--                         'from V_HRBF41,tobfcde '||
--                         'where tobfcde.codobf = '||''''||p_codobf||''''||' '||
--                         'and V_HRBF41.codempid = '||''''||p_codempid||''''||' '||
--                         v_cond2||' '||
--                         'and rownum = 1';
--              execute immediate v_stmt2 into v_flgcond2;
--              if v_flgcond2 > 0 then
--                v_qtyalw := r1.qtyalw;
--                v_qtytalw := r1.qtytalw;
--
--                p_qtyalw  := v_qtyalw;
--                p_qtytalw := v_qtytalw;
--
--                if v_flglimit = 'M' then
--                  /*begin
--                    select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_codempid
--                       and codobf = p_codobf
--                       and dteyre = to_char(p_dtereq,'yyyy')
--                       and dtemth = to_char(p_dtereq,'mm');
--                  exception when no_data_found then
--                    v_qtywidrw := p_amtwidrw;
--                  end;*/
--                  begin
--                      select nvl(qtywidrw,0) + p_qtywidrw into v_qtywidrw
--                      from tobfinf
--                      where codempid = p_codempid
--                        and codobf = p_codobf
--                        and to_char(dtereq,'YYYYMM') = to_char(p_dtereq,'YYYYMM')
--                        and numvcher <> nvl(p_numvcher,'');
--                  exception when no_data_found then
--                      v_qtywidrw := p_qtywidrw;
--                  end;
--                elsif v_flglimit = 'Y' then
--                  /*begin
--                    select nvl(qtywidrw,0) + p_amtwidrw into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_codempid
--                       and codobf = p_codobf
--                       and dteyre = to_char(p_dtereq,'yyyy')
--                       and dtemth = 13;
--                  exception when no_data_found then
--                    v_qtytwidrw := p_amtwidrw;
--                  end;*/
--                  begin
--                      select sum(nvl(qtywidrw,0)) + p_qtywidrw into v_qtywidrw
--                      from tobfinf
--                      where codempid = p_codempid
--                        and codobf = p_codobf
--                        and to_char(dtereq,'yyyy') = to_char(p_dtereq,'yyyy')
--                        and numvcher <> nvl(p_numvcher,'');
--                  exception when no_data_found then
--                      v_qtywidrw := p_qtywidrw;
--                  end;
--                elsif v_flglimit = 'A' then
--                  /*begin
--                    select nvl(sum(qtywidrw),0) + p_amtwidrw into v_qtywidrw
--                      from tobfsum
--                     where codempid = p_codempid
--                       and codobf = p_codobf;
--                  exception when no_data_found then
--                    v_qtytwidrw := p_amtwidrw;
--                  end;*/
--                  begin
--                      select nvl(qtywidrw,0) + p_qtywidrw into v_qtywidrw
--                      from tobfinf
--                      where codempid = p_codempid
--                        and codobf = p_codobf
--                        and numvcher <> nvl(p_numvcher,'');
--                  exception when no_data_found then
--                      v_qtywidrw := p_qtywidrw;
--                  end;
--                end if;
--                v_flgsecur := true;
--                exit;
--              end if;
--            end if;
--          end loop;
--        end if;
--      end if;--v_syncond is not null then
--
--      if not v_flgsecur then
--        v_errorno := 'HR2055';
--      else
--
--            if p_numtsmit > v_qtytalw then
--              v_errorno := 'BF0054';
--            end if;
--
--            if v_qtywidrw > v_qtyalw then
--              v_errorno := 'BF0053';
--            end if;
--
--          end if;
--      end if;
--
--    -- return error no
--    return v_errorno;
--  end benefit_secure;

  procedure check_header as
      v_temp         varchar(1 char);
  begin
    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
       return;
    end;

    if secur_main.secur2(p_query_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
    end if;

    begin
        select 'X' into v_temp
        from temploy1
        where codempid = p_query_codempid
          and staemp <> '9';
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang);
        return;
    end;

  end check_header;

  procedure gen_header(json_str_output out clob) as
    obj_data    json;
    v_codcomp   temploy1.codcomp%type;
    v_costcent  tcenter.costcent%type;
  begin
--  get codcomp
    begin
        select codcomp into v_codcomp
        from temploy1
        where codempid = nvl(p_query_codempid, codempid)
          and codcomp like nvl(p_codcomp||'%', codcomp)
          and rownum = 1;
    exception when no_data_found then
        v_codcomp := '';
    end;
--  get cost center
    begin
        select costcent into v_costcent
        from tcenter
        where codcomp = v_codcomp;
    exception when no_data_found then
        v_costcent := '';
    end;
    obj_data := json();
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('codcenter',v_costcent);
    obj_data.put('coderror',200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_header;

  procedure get_header(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_header;
    if param_msg_error is null then
        gen_header(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_header;

  procedure save_tobfsum(c_codempid in varchar2, c_dtereq in date, c_codobf in varchar2,
                         c_codcomp in varchar2, c_qtyalw in number, c_qtytalw in number) as
    v_qtywidrw      number;
    v_amtwidrw      number;
    v_qtytwidrw     number;
    v_count         number;
    v_qtyhuman      number;
  begin

    begin
        select sum(qtywidrw),sum(amtwidrw),count(numtsmit)
          into v_qtywidrw,v_amtwidrw,v_qtytwidrw
          from tobfinf
         where codempid = c_codempid
           and to_number(to_char(dtereq,'yyyy')) = to_number(to_char(c_dtereq,'yyyy'))
           and to_number(to_char(dtereq,'mm')) = to_number(to_char(c_dtereq,'mm'))
           and codobf = c_codobf;
    exception when no_data_found then
        v_qtywidrw  := 0;
        v_amtwidrw  := 0;
        v_qtytwidrw := 0;
    end;

    if nvl(v_amtwidrw,0) = 0 then
        delete tobfsum where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
                         and dtemth   = to_number(to_char(c_dtereq,'mm'))
                         and codempid  = c_codempid
                         and codobf   = c_codobf;
    else
        begin
            select count(*)
              into v_count
              from tobfsum
             where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
               and dtemth   = to_number(to_char(c_dtereq,'mm'))
               and codempid  = c_codempid
               and codobf   = c_codobf;
        exception when no_data_found then
            v_count := 0;
        end;
        if v_count = 0 then
            insert into tobfsum (codempid, dteyre, dtemth, codobf,
                             qtywidrw, qtytwidrw, amtwidrw, qtyalw,
                             qtytalw, codcomp, dtelwidrw, dtecreate,
                             codcreate, dteupd, coduser)
                     values (c_codempid, to_number(to_char(c_dtereq,'yyyy')), to_number(to_char(c_dtereq,'mm')), c_codobf,
                             v_qtywidrw, v_qtytwidrw, v_amtwidrw, c_qtyalw,
                             c_qtytalw, c_codcomp, c_dtereq ,sysdate,
                             global_v_coduser, sysdate, global_v_coduser);
        else
            update tobfsum set qtywidrw  = v_qtywidrw, --จำนวนที่เบิกสะสม
                               qtytwidrw = v_qtytwidrw,--จำนวนครั้งที่เบิกสะสม
                               amtwidrw	 = v_amtwidrw,--จำนวนเงินที่ขอเบิก (มูลค่า x จำนวนที่ขอเบิก)
                               qtyalw    = c_qtyalw,
                               qtytalw   = c_qtytalw,
                               codcomp   = c_codcomp,
                               dteupd    = sysdate,
                               coduser   = global_v_coduser
                         where codempid   = c_codempid
                           and dteyre    = to_number(to_char(c_dtereq,'yyyy'))
                           and dtemth    = to_number(to_char(c_dtereq,'mm'))
                           and codobf     = c_codobf;
        end if;
    end if;

    ---year
    begin
        select sum(qtywidrw),sum(amtwidrw),count(numtsmit)
          into v_qtywidrw,v_amtwidrw,v_qtytwidrw
          from tobfinf
         where codempid = c_codempid
           and to_number(to_char(dtereq,'yyyy')) = to_number(to_char(c_dtereq,'yyyy'))
           and codobf = c_codobf;
    exception when no_data_found then
        v_qtywidrw  := 0;
        v_amtwidrw  := 0;
        v_qtytwidrw := 0;
    end;

    if nvl(v_amtwidrw,0) = 0 then
        delete tobfsum where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
                         and dtemth   = 13
                         and codempid  = c_codempid
                         and codobf   = c_codobf;
    else
        begin
            select count(*)
              into v_count
              from tobfsum
             where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
               and dtemth   = 13
               and codempid  = c_codempid
               and codobf   = c_codobf;
        exception when no_data_found then
            v_count := 0;
        end;
        if v_count = 0 then
            insert into tobfsum (codempid, dteyre, dtemth, codobf,
                             qtywidrw, qtytwidrw, amtwidrw, qtyalw,
                             qtytalw, codcomp, dtelwidrw, dtecreate,
                             codcreate, dteupd, coduser)
                     values (c_codempid, to_number(to_char(c_dtereq,'yyyy')), 13, c_codobf,
                             v_qtywidrw, v_qtytwidrw, v_amtwidrw, c_qtyalw,
                             c_qtytalw, c_codcomp, c_dtereq ,sysdate,
                             global_v_coduser, sysdate, global_v_coduser);
        else
            update tobfsum set qtywidrw  = v_qtywidrw, --จำนวนที่เบิกสะสม
                               qtytwidrw = v_qtytwidrw,--จำนวนครั้งที่เบิกสะสม
                               amtwidrw	 = v_amtwidrw,--จำนวนเงินที่ขอเบิก (มูลค่า x จำนวนที่ขอเบิก)
                               qtyalw    = c_qtyalw,
                               qtytalw   = c_qtytalw,
                               codcomp   = c_codcomp,
                               dteupd    = sysdate,
                               coduser   = global_v_coduser
                         where codempid   = c_codempid
                           and dteyre    = to_number(to_char(c_dtereq,'yyyy'))
                           and dtemth    = 13
                           and codobf     = c_codobf;
        end if;
    end if;
  end save_tobfsum;

procedure save_tobfdep(c_dtereq in date, c_codobf in varchar2, c_codcomp in varchar2) as
    v_qtywidrw      number;
    v_amtwidrw      number;
    v_qtytwidrw     number;
    v_count         number;
    v_qtyhuman      number;
  begin
    begin
        select sum(qtywidrw),sum(amtwidrw),count(distinct codempid),count(*)
          into v_qtywidrw,v_amtwidrw,v_qtyhuman,v_qtytwidrw
          from tobfinf
         where codcomp = c_codcomp
           and to_number(to_char(dtereq,'yyyy')) = to_number(to_char(c_dtereq,'yyyy'))
           and to_number(to_char(dtereq,'mm')) = to_number(to_char(c_dtereq,'mm'))
           and codobf = c_codobf;
    exception when no_data_found then
        v_qtywidrw  := 0;
        v_amtwidrw  := 0;
        v_qtytwidrw := 0;
    end;

    if v_qtytwidrw = 0 then
        delete tobfdep where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
                         and dtemth   = to_number(to_char(c_dtereq,'mm'))
                         and codcomp  = c_codcomp
                         and codobf   = c_codobf;
    else
        begin
            select count(*)
              into v_count
              from tobfdep
             where dteyre   = to_number(to_char(c_dtereq,'yyyy'))
               and dtemth   = to_number(to_char(c_dtereq,'mm'))
               and codcomp  = c_codcomp
               and codobf   = c_codobf;
        exception when no_data_found then
            v_count := 0;
        end;

        if v_count = 0 then
            insert into tobfdep (dteyre, dtemth, codcomp, codobf,
                                 qtyhuman, qtywidrw, qtytwidrw, amtwidrw,
                                 dtecreate, codcreate, dteupd, coduser)
                         values (to_number(to_char(c_dtereq,'yyyy')), to_number(to_char(c_dtereq,'mm')), c_codcomp, c_codobf,
                                 v_qtyhuman, v_qtywidrw, v_qtytwidrw, v_amtwidrw,
                                 sysdate, global_v_coduser, sysdate, global_v_coduser);
        else
            update tobfdep set qtyhuman  = v_qtyhuman, --จำนวนคนที่ขอเบิก
                               qtywidrw  = v_qtywidrw, --จำนวนที่เบิกสะสม
                               qtytwidrw = v_qtytwidrw,--จำนวนครั้งที่เบิกสะสม
                               amtwidrw	 = v_amtwidrw,--จำนวนเงินที่ขอเบิก (มูลค่า x จำนวนที่ขอเบิก)
                               dteupd    = sysdate,
                               coduser   = global_v_coduser
                         where codcomp   = c_codcomp
                           and dteyre    = to_number(to_char(c_dtereq,'yyyy'))
                           and dtemth    = to_number(to_char(c_dtereq,'mm'))
                           and codobf     = c_codobf;
        end if;
    end if;
  end save_tobfdep;
end hrbf43e;

/

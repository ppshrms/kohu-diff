--------------------------------------------------------
--  DDL for Package Body M_HRPMZ3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPMZ3X" as
/* Cust-Modify: KOHU-HR2301 */
-- last update: 12/06/2023 11:15

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_typedata          := upper(hcm_util.get_string_t(json_obj, 'p_typedata'));
    p_status            := upper(hcm_util.get_string_t(json_obj, 'p_status'));
    p_dteimpt           := to_date(hcm_util.get_string_t(json_obj, 'p_dteimpt'), 'DD/MM/YYYY hh24:mi');
    --p_dteimpt           := trunc(to_date(hcm_util.get_string_t(json_obj, 'p_dteimpt'), 'DD/MM/YYYY hh:mi:ss'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');
    p_namefile          := hcm_util.get_string_t(json_obj, 'p_namefile');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_secur            varchar2(1 char) := 'N';
    v_checkSecur       BOOLEAN;
    v_codempid         varchar2(100 char);
    v_codcomp          varchar2(400 char);

    cursor c1 is
      select to_char(dteimpt, 'dd/mm/yyyy hh24:mi') as dtetransfer,namefile,typedata,
             sum(decode(status, 'Y', 1, 0)) as completed,
             sum(decode(status, 'N', 1, 0)) as error
      from timpfiles
      where (typedata = p_typedata or p_typedata = 'A')
        and (status = p_status or p_status = 'A')
        and trunc(dteimpt) between p_dtestrt and p_dteend
      group by to_char(dteimpt, 'dd/mm/yyyy hh24:mi'), namefile, typedata
      order by to_date(to_char(dteimpt, 'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi') desc , namefile, typedata;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';

    for r1 in c1 loop
        v_flgdata            := 'Y';
        begin
            select codempid,codcomp
            into v_codempid,v_codcomp
            from timpfiles
            where --trunc(dteimpt) = r1.dtetransfer
                to_char(dteimpt, 'dd/mm/yyyy hh24:mi') = r1.dtetransfer
                and typedata = r1.typedata
                and namefile = r1.namefile
                and rownum = 1;
        exception when no_data_found then
            v_codempid := '';
            v_codcomp  := '';
        end;
        if r1.typedata = 10 then
            v_checkSecur := secur_main.secur7(v_codcomp,global_v_coduser);
        else
            v_checkSecur := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        end if;
        if v_checkSecur = true then
          v_secur               := 'Y';

          obj_data         := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('dtetransfer', r1.dtetransfer);
          obj_data.put('namefile', r1.namefile);
          obj_data.put('typedata', r1.typedata);
          obj_data.put('desc_typedata', get_tlistval_name('TYPEDATA2',r1.typedata,global_v_lang));
          obj_data.put('typeid', r1.typedata);
          obj_data.put('flgbreak', 'N');
          obj_data.put('completed', r1.completed);
          obj_data.put('error', r1.error);
          obj_data.put('total', r1.completed + r1.error);

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt           := v_rcnt + 1;
        end if;
    end loop;
    if v_flgdata = 'Y' then
        if v_secur = 'Y' then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TIMPFILES');
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;


  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_row            json_object_t;
    obj_col             json_object_t;
    obj_detail         json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_secur            varchar2(1 char) := 'N';
    v_checkSecur       BOOLEAN;

    cursor c1 is
      select numseq,dteimpt,to_char(dteeffec,'dd/mm/yyyy') dteeffec,codtrn,codexemp,dteyrepay,dtemthpay,numperiod,codpay,
             status,remark,typedata, codcomp, codempid, datafile
        from timpfiles
       where typedata = p_typedata
         and to_date(to_char(dteimpt, 'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi') = p_dteimpt
      order by numseq;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in c1 loop
      v_flgdata            := 'Y';
      v_flgdata            := 'Y';
      if r1.typedata = 10 then
            v_checkSecur := secur_main.secur7(r1.codcomp,global_v_coduser);
      else
            v_checkSecur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      end if;
      if v_checkSecur = true then
          v_secur         := 'Y';
          obj_col         := json_object_t();
          obj_col.put('coderror', '200');
          obj_col.put('numseq', r1.numseq);
          obj_col.put('datafile', r1.datafile);
          if r1.typedata = 50 then -- ข้อมูลการเคลื่อนไหว
            obj_col.put('tcodmove', get_tcodec_name('TCODMOVE', r1.codtrn, global_v_lang));
            obj_col.put('dteeffec', r1.dteeffec);
          elsif r1.typedata = 60 then -- ข้อมูลพ้นสภาพ
            obj_col.put('tcodretm', get_tcodec_name('TCODRETM', r1.codexemp, global_v_lang));
            obj_col.put('dteeffec', r1.dteeffec);
          elsif r1.typedata = 70 then -- ข้อมูลกลับเข้าทำงานใหม่ 
            obj_col.put('dteeffec', r1.dteeffec);
            obj_col.put('tcodmove', get_tcodec_name('TCODMOVE', r1.codtrn, global_v_lang));
            obj_col.put('dtereemp', r1.dteeffec);
          elsif r1.typedata = 80 then -- ข้อมูลรายได้อื่นๆ 
            obj_col.put('codpay', get_tinexinf_name(r1.codpay, global_v_lang));
            obj_col.put('installment', r1.numperiod|| '/' ||r1.dtemthpay|| '/' ||r1.dteyrepay);
          end if;

          obj_col.put('statusid', r1.status);
          obj_col.put('status', get_tlistval_name('STATUS', to_char(r1.status), global_v_lang));
          obj_col.put('remark', r1.remark);
          obj_col.put('flgbreak', 'Y');

          obj_row.put(to_char(v_rcnt), obj_col);
          v_rcnt := v_rcnt + 1;
      end if;
    end loop;
    if v_flgdata = 'Y' then
        if v_secur = 'Y' then
            json_str_output := obj_row.to_clob;
        else
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TIMPFILES');
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;
end M_HRPMZ3X;

/

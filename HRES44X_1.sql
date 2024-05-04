--------------------------------------------------------
--  DDL for Package Body HRES44X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES44X" as
   procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numisr            := hcm_util.get_string_t(json_obj,'p_numisr');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    obj_result          json_object_t;

    v_row               number := 0;
    v_count             number := 0;
    v_namisrco          tisrinf.namisrco%type;
    v_namisr            tisrinf.namisre%type;

    cursor c1 is
      select numisr,codisrp,flgisr,dtehlpst,dtehlpen,flgemp
        from tinsrer
       where codempid = b_index_codempid
       order by dtehlpst;

  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      begin
        select namisrco, decode(global_v_lang,'101',namisre
                                             ,'102',namisrt
                                             ,'103',namisr3
                                             ,'104',namisr4
                                             ,'105',namisr5) as namisr
          into v_namisrco, v_namisr
          from tisrinf 
         where numisr = r1.numisr;
      exception when no_data_found then
        v_namisrco := '';
        v_namisr := '';
      end;
      obj_data.put('coderror', '200');  
      obj_data.put('numisr', r1.numisr);
      obj_data.put('desc_numisr', v_namisr);
      obj_data.put('amisrco', v_namisrco);
      obj_data.put('codisrp', r1.codisrp);
      obj_data.put('dtehlpst', to_char(r1.dtehlpst, 'dd/mm/yyyy'));
      obj_data.put('dtehlpen', to_char(r1.dtehlpen, 'dd/mm/yyyy'));
      obj_data.put('flgemp', get_tlistval_name('FLGEMP', r1.flgemp, global_v_lang));

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');  
    obj_result.put('codempid', b_index_codempid);
    obj_result.put('desc_codempid', get_temploy_name(b_index_codempid, global_v_lang));
    obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  --  
  procedure get_index (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_tinsrer(json_str_output out clob) is
    obj_data            json_object_t;
    v_tinsrer           tinsrer%rowtype;
    v_nameinsr          varchar2(1000 char);
    v_qtyemp            number := 0;
    v_dteeffec          date;
    v_remark            tchgins1.remark%type;
  begin
    begin
      select * into v_tinsrer
        from tinsrer
       where codempid = b_index_codempid
         and numisr = p_numisr;
    exception when no_data_found then
      v_tinsrer := null;
    end;
    if v_tinsrer.codecov = 'Y' then
      v_nameinsr := get_label_name('HRES44X2', global_v_lang, 300);
    else
      v_nameinsr := get_label_name('HRES44X2', global_v_lang, 310);
    end if;
    begin
      select count(*) into v_qtyemp
        from tinsrdp 
       where codempid = b_index_codempid
         and numisr = p_numisr;
    end;
    --
    begin
      select max(dteeffec) into v_dteeffec
        from tchgins1  
       where codempid = b_index_codempid
         and numisr = p_numisr;
    exception when no_data_found then 
      v_dteeffec  := '';
    end;
    begin
      select remark into v_remark
        from tchgins1  
       where codempid = b_index_codempid
         and numisr = p_numisr
         and dteeffec = v_dteeffec;
    exception when no_data_found then 
      v_remark  := '';
    end;
    obj_data   := json_object_t();
    obj_data.put('coderror', '200');  
    obj_data.put('dtechange', to_char(v_dteeffec, 'dd/mm/yyyy'));
    obj_data.put('codisrp', v_tinsrer.codisrp);
    obj_data.put('desc_codisrp', get_tcodec_name('TCODISRP',v_tinsrer.codisrp, global_v_lang));
    obj_data.put('flgemp', get_tlistval_name('FLGEMP', v_tinsrer.flgemp, global_v_lang));
    obj_data.put('dtehlpst', to_char(v_tinsrer.dtehlpst,'dd/mm/yyyy'));
    obj_data.put('dtehlpen', to_char(v_tinsrer.dtehlpen,'dd/mm/yyyy'));
    obj_data.put('amtisrp', to_char(v_tinsrer.amtisrp,'fm999,999,990.00'));
    obj_data.put('nameinsr', v_nameinsr);
    obj_data.put('qtyemp', v_qtyemp);
    obj_data.put('amtpmiumme', to_char(v_tinsrer.amtpmiumme,'fm999,999,990.00'));
    obj_data.put('amtpmiumye', to_char(v_tinsrer.amtpmiumye,'fm999,999,990.00'));
    obj_data.put('amtpmiummc', to_char(v_tinsrer.amtpmiummc,'fm999,999,990.00'));
    obj_data.put('amtpmiumyc', to_char(v_tinsrer.amtpmiumyc,'fm999,999,990.00'));
    obj_data.put('remark', v_remark);
    obj_data.put('codemp_upd', get_codempid(v_tinsrer.coduser));
    obj_data.put('dteupd', to_char(v_tinsrer.dteupd,'dd/mm/yyyy'));
    obj_data.put('coduser', v_tinsrer.coduser);
    obj_data.put('desc_coduser', get_temploy_name(get_codempid(v_tinsrer.coduser),global_v_lang));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --  
  procedure get_detail_tinsrer (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tinsrer(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_tinsrdp(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_tinsrer           tinsrer%rowtype;
    v_nameinsr          varchar2(1000 char);
    v_count            number := 0;

    cursor c1 is
      select *
        from tinsrdp 
       where codempid = b_index_codempid
         and numisr = p_numisr
       order by numseq;
  begin

    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      v_count    := v_count + 1;

      obj_data   := json_object_t();
      obj_data.put('coderror', '200');  
      obj_data.put('nameinsr', r1.nameinsr);
      obj_data.put('typrelate', get_tlistval_name('TYPRELATE', r1.typrelate, global_v_lang));
      obj_data.put('dteempdb', to_char(r1.dteempdb,'dd/mm/yyyy'));

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --  
  procedure get_detail_tinsrdp (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tinsrdp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
    --
  procedure gen_detail_tbficinf(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_tinsrer           tinsrer%rowtype;
    v_nameinsr          varchar2(1000 char);
    v_count            number := 0;

    cursor c1 is
      select *
        from tbficinf 
       where codempid = b_index_codempid
         and numisr = p_numisr
       order by numseq;
  begin

    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      v_count    := v_count + 1;

      obj_data   := json_object_t();
      obj_data.put('coderror', '200');  
      obj_data.put('nameinsr', r1.nambfisr);
      obj_data.put('typrelate', get_tlistval_name('TYPRELATE', r1.typrelate, global_v_lang));
      obj_data.put('ratebf', r1.ratebf);

      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --  
  procedure get_detail_tbficinf (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tbficinf(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hres44x;

/

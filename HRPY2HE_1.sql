--------------------------------------------------------
--  DDL for Package Body HRPY2HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2HE" as

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
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codlegald         := hcm_util.get_string_t(json_obj, 'p_codlegald');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codlegald tcodlegald.codcodec%type;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      p_codcomp := p_codcomp||'%';
    end if;
    --
    if p_codlegald is not null then
      begin
        select codcodec
          into v_codlegald
          from tcodlegald
         where codcodec = p_codlegald;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodlegald');
        return;
      end;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_flgdata          varchar2(1 char) := 'N';
    v_flg_secur        boolean := false;
    v_flg_permission   boolean := false;
    v_total            number := 0;
    v_codapp           varchar2(100 char) := 'HRPY2HE';
    v_numseq           number := 1;
    v_temp_id          varchar2(100);

    cursor c1 is
      select a.codempid,a.codcomp,a.numtime,a.numcaselw,
             nvl(stddec(a.amtded,a.codempid,v_chken),0) amtded,
             a.dtepay,a.typpaymt,a.numref,b.codlegald
        from tlegalprd a, tlegalexe b
       where a.codempid  = b.codempid
         and a.numcaselw = b.numcaselw
         and a.codcomp like p_codcomp||'%'
         and a.dtemthpay = p_dtemthpay
         and a.dteyrepay = p_dteyrepay
         and b.codlegald = nvl(p_codlegald,b.codlegald)
       order by a.codempid,a.codcomp,a.numtime;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    v_flgdata              := 'N';
    --
    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;
    --
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlegalprd');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secur := secur_main.secur3(r1.codcomp, r1.codempid, global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal);
      if v_flg_secur then
        v_flg_permission := true;
        v_flgdata        := 'Y';

        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('desc_codlegald', get_tcodec_name('tcodlegald' ,r1.codlegald ,global_v_lang));
        obj_data.put('numcaselw', r1.numcaselw);
--<<user46 14/12/2021
--        obj_data.put('numtime', r1.numtime);
          if v_temp_id is null then
            v_temp_id   := r1.codempid;
          elsif r1.codempid <> v_temp_id then
            v_numseq    := 1;
            v_temp_id   := r1.codempid;
          end if;
          obj_data.put('numseq', v_numseq);
          obj_data.put('numtime', r1.numtime);
          v_numseq  := v_numseq + 1;
-->>user46 14/12/2021
        if r1.amtded < 0 then
          obj_data.put('amtded', 0);
        else
          obj_data.put('amtded', r1.amtded);
        end if;
        obj_data.put('dtepay', to_char(r1.dtepay,'dd/mm/yyyy'));
        obj_data.put('typpaymt', r1.typpaymt);
        obj_data.put('desc_typpaymt', get_tlistval_name('TYPPAYMT',r1.typpaymt,global_v_lang));
        obj_data.put('numref', r1.numref);

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    obj_param_json json_object_t;
    param_json_row json_object_t;
    -- get param json
    v_codempid      tlegalprd.codempid%type;
    v_dtepay        tlegalprd.dtepay%type;
    v_typpaymt      tlegalprd.typpaymt%type;
    v_numref        tlegalprd.numref%type;
    v_numcaselw     tlegalprd.numcaselw%type;
    v_numtime       tlegalprd.numtime%type;
    v_flg           varchar2(100 char);
    v_amtded        tlegalprd.amtded %type;
  begin 
    initial_value(json_str_input);
    check_index;
    obj_param_json        := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json,to_char(i));
        --
        v_codempid        := hcm_util.get_string_t(param_json_row,'codempid');
        v_dtepay          := to_date(hcm_util.get_string_t(param_json_row,'dtepay'),'dd/mm/yyyy');
        v_typpaymt        := hcm_util.get_string_t(param_json_row,'typpaymt');
        v_numref          := hcm_util.get_string_t(param_json_row,'numref');
        v_numcaselw       := hcm_util.get_string_t(param_json_row,'numcaselw');
        v_numtime         := hcm_util.get_string_t(param_json_row,'numtime');
        v_flg             := hcm_util.get_string_t(param_json_row,'flg');
        v_amtded          := hcm_util.get_string_t(param_json_row,'amtded'); --   nvl(stddec(a.amtded,a.codempid,v_chken),0) amtded
        --
        if v_codempid is not null then
          param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, v_codempid);
        end if;
        if param_msg_error is null then
          if v_flg = 'edit' then
            begin
              update tlegalprd set dtepay    =  v_dtepay,
                                   typpaymt  =  v_typpaymt,
                                   numref    =  v_numref,
                                   amtded    =  nvl(stdenc(v_amtded,v_codempid,v_chken),0),
                                   coduser   =  global_v_coduser
                             where codempid  =  v_codempid
                               and numcaselw =  v_numcaselw
                               and numtime   =  v_numtime;
            end;
          end if;
        end if;
      end loop;
      --
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

end HRPY2HE;

/

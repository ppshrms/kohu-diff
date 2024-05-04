--------------------------------------------------------
--  DDL for Package Body HRESH4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRESH4X" is
-- last update: 15/04/2019 14:08

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_module            := hcm_util.get_string_t(json_obj,'p_module');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_stdate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtest')),'dd/mm/yyyy');
    b_index_endate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteen')),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    begin
      select codcomp
      into   global_v_codcomp
      from   temploy1
      where  codempid = b_index_codempid;
    exception when no_data_found then
      null;
    end;
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_data(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_ocodempid     varchar2(200 char);
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_amtincadj     varchar2(100 char);
    v_amtincom      varchar2(100 char);

    cursor c1 is
        select codempid,dteeffec,codpos,codcomp,numlvl,
               amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
               amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
               codtrn
          from thismove
         where (codempid = b_index_codempid
            or v_ocodempid  like '[%'||codempid||']%' )
           and dteeffec between b_index_stdate and b_index_endate
        order by dteeffec desc;

  begin
    v_ocodempid :=  get_ocodempid(b_index_codempid );
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('numlvl',to_char(r1.numlvl));
      v_amtincadj := to_char(get_wage_income_func(r1.codempid,r1.amtincadj1,r1.amtincadj2,r1.amtincadj3,
                                                              r1.amtincadj4,r1.amtincadj5,r1.amtincadj6,r1.amtincadj7,
                                                              r1.amtincadj8,r1.amtincadj9,r1.amtincadj10),'fm99,999,999,990.00');
      obj_data.put('amtincadj',v_amtincadj);
      v_amtincom := to_char(get_wage_income_func(r1.codempid,r1.amtincom1,r1.amtincom2,r1.amtincom3,
                                                             r1.amtincom4,r1.amtincom5,r1.amtincom6,r1.amtincom7,
                                                             r1.amtincom8,r1.amtincom9,r1.amtincom10),'fm99,999,999,990.00');
      obj_data.put('amtincom',v_amtincom);
      obj_data.put('desc_codtrn',get_tcodec_name('tcodmove',r1.codtrn,global_v_lang));
      obj_data.put('codpos',r1.codpos);
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('codtrn',r1.codtrn);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
  procedure check_index is
  begin
    -- check secure
    param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
    if param_msg_error is not null then
      return;
    end if;

    if b_index_stdate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_endate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_stdate > b_index_endate  then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;

  function get_wage_income_func(  p_codempid  in varchar2,
                                  p_amt1      in varchar2,
                                  p_amt2      in varchar2,
                                  p_amt3      in varchar2,
                                  p_amt4      in varchar2,
                                  p_amt5      in varchar2,
                                  p_amt6      in varchar2,
                                  p_amt7      in varchar2,
                                  p_amt8      in varchar2,
                                  p_amt9      in varchar2,
                                  p_amt10     in varchar2) return number is
    v_codempmt    varchar2(10);
    v_amt1        number;
    v_amt2        number;
    v_amt         number;
    v_flg         boolean;
    v_zupdsal     varchar2(4);
  begin
    v_flg := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

    if p_module = 'ES' then
      if b_index_codempid = global_v_codempid then
        v_zupdsal := 'Y';
      end if;
    end if;
    if v_zupdsal = 'Y' then
      begin
        select codempmt
          into v_codempmt
          from temploy1
         where codempid = p_codempid;
      exception when others then
         null;
      end;

      get_wage_income(hcm_util.get_codcomp_level(global_v_codcomp,'1'),upper(v_codempmt),
                      stddec(p_amt1,p_codempid,global_v_chken), stddec(p_amt2,p_codempid,global_v_chken),
                      stddec(p_amt3,p_codempid,global_v_chken), stddec(p_amt4,p_codempid,global_v_chken),
                      stddec(p_amt5,p_codempid,global_v_chken), stddec(p_amt6,p_codempid,global_v_chken),
                      stddec(p_amt7,p_codempid,global_v_chken), stddec(p_amt8,p_codempid,global_v_chken),
                      stddec(p_amt9,p_codempid,global_v_chken), stddec(p_amt10,p_codempid,global_v_chken),
                      v_amt1,v_amt2,v_amt);
    end if;
    return v_amt;
  end;
end;

/

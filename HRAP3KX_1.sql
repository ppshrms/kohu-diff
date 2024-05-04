--------------------------------------------------------
--  DDL for Package Body HRAP3KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3KX" is
-- last update: 15/04/2019 17:53

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');

    --block b_index
    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_typpayroll  := hcm_util.get_string_t(json_obj,'p_typpayroll');
    b_index_periodpay   := hcm_util.get_string_t(json_obj,'p_periodpay');
    b_index_dtemthpay   := hcm_util.get_string_t(json_obj,'p_dtemthpay');
    b_index_dteyrepay   := hcm_util.get_string_t(json_obj,'p_dteyrepay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);
    v_secur      boolean;
    flgpass      boolean;
    v_codcomp       tposempd.codcomp%type;

    v_codcalen      varchar2(100 char);
    v_amtceiling    number := 0;
    v_amtsal        number := 0;
    v_amtadj        number := 0;
    v_amtsaln       number := 0;
    v_amtlums       number := 0;
    v_jobgrade      varchar2(100 char);
    v_zupdsal   	varchar2(4);--nut

    cursor c1 is
      select b.codcalen ,a.codempid,
             b.codcomp --<<user25 Date: 15/09/2021 3. AP Module #4348
        from tapprais a , temploy1 b
        where a.codempid = b.codempid
        and a.dteyreap   = b_index_dteyreap
        and a.typpayroll = b_index_typpayroll
        and a.periodpay  = b_index_periodpay
        and a.dtemthpay  = b_index_dtemthpay
        and a.dteyrepay  = b_index_dteyrepay
        and a.flgtrnpy   = 'Y'
        group by b.codcalen ,a.codempid,b.codcomp
        order by b.codcalen, a.codempid ;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
        v_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);--User37 #4351 AP - PeoplePlus 20/02/2021 secur_main.secur7(b_index_codcomp, global_v_coduser);
        if v_secur then

             begin
                    select  stddec(amtceiling,codempid,v_chken),
                            stddec(amtsal,codempid,v_chken),
                            stddec(amtbudg,codempid,v_chken) + stddec(amtadj,codempid,v_chken),
                            stddec(amtsaln,codempid,v_chken),
                            stddec(amtlums,codempid,v_chken),
                            jobgrade
                    into    v_amtceiling , -- col.5
                            v_amtsal ,     -- col.6
                            v_amtadj ,     -- col.7
                            v_amtsaln ,    -- col.8
                            v_amtlums ,    -- col.9
                            v_jobgrade
                    from    tapprais
                    where   codempid = i.codempid
                    and     dteyreap = b_index_dteyreap;
             exception when no_data_found then
                    v_amtceiling    := 0;   -- col.5
                    v_amtsal        := 0;   -- col.6
                    v_amtadj        := 0;   -- col.7
                    v_amtsaln       := 0;   -- col.8
                    v_amtlums       := 0;   -- col.9
                    v_jobgrade      := null;
             end;
             v_rcnt := v_rcnt+1;
             obj_data := json_object_t();
             obj_data.put('coderror','200');
             obj_data.put('image',get_emp_img(i.codempid));                                         -- col.1
             obj_data.put('codempid',i.codempid);                                                   -- col.2
             obj_data.put('codcomp',i.codcomp);--<<user25 Date: 15/09/2021 3. AP Module #4348
             obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));              -- col.3
             obj_data.put('desc_jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));    -- col.4
             obj_data.put('amtceiling',to_char(nvl(v_amtceiling,0),'fm9999999999990.00'));          -- col.5
             obj_data.put('amtsal',to_char(nvl(v_amtsal,0),'fm9999999999990.00'));                  -- col.6
             obj_data.put('amtadj',to_char(nvl(v_amtadj,0),'fm9999999999990.00'));                  -- col.7
             obj_data.put('amtsaln',to_char(nvl(v_amtsaln,0),'fm9999999999990.00'));                -- col.8
             obj_data.put('amtlums',to_char(nvl(v_amtlums,0),'fm9999999999990.00'));                -- col.9
             obj_data.put('codcalen',i.codcalen);                                                   -- col.for break1
             obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK',i.codcalen,global_v_lang));    -- col.for break2

             obj_data.put('dteyreap',b_index_dteyreap);--User37 #4352 AP - PeoplePlus 20/02/2021
--  --  --  --  --  --  --  --  --  --  --  --  --  --  --
             obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;

    if v_flgdata = 'Y' then
          if v_rcnt > 0 then
                obj_result := json_object_t();
                obj_result.put('date', '26/08/2020');
                obj_result.put('table', obj_row);
                json_str_output := obj_row.to_clob;
          else
                param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          end if;
    else
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPRAIS');
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
  procedure check_index(json_str_output out clob) is
    v_chk           varchar2(1);
  begin
    begin
        select 'Y'
          into v_chk
          from tcodtypy
         where codcodec = b_index_typpayroll;
    exception when no_data_found then
        v_chk := 'N';
    end;
    if v_chk = 'N' then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
end;

/

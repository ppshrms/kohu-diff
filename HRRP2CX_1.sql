--------------------------------------------------------
--  DDL for Package Body HRRP2CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2CX" is
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
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');

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
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_cntman        number;
    v_cntamt        number;
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    cursor c1 is
       select dteyrbug,codcomp,codpos,qtypromote,amtprosal
         from tbudget
        where dteyrbug  = b_index_year
          and codcomp   like b_index_codcomp||'%'
          and nvl(qtypromote,0) <> 0
     order by codcomp,codpos;

    cursor c_ttmovemt is
        select  a.codempid,codcomp,codempmt,
                a.amtincom1,a.amtincom2,
                a.amtincom3,a.amtincom4,
                a.amtincom5,a.amtincom6,
                a.amtincom7,a.amtincom8,
                a.amtincom9,a.amtincom10
        from ttmovemt a,tcodmove b
        where a.codtrn = b.codcodec
        and b.typmove = '8'
        and a.staupd in ('C','U')
        and to_char(a.dteeffec,'yyyy')  = b_index_year
        and a.codcomp = v_codcomp
        and a.codpos  = v_codpos
        and exists (select  codcomp  from tusrcom x
                     where  x.coduser = global_v_coduser
                       and  a.codcomp like a.codcomp||'%')
        and a.numlvl between global_v_zminlvl and global_v_zwrklvl
        order by a.codempid,a.dteeffec;

  begin
    obj_row := json_object_t();
    for i in c1 loop
          v_flgdata := 'Y';
          v_rcnt := v_rcnt+1;
          v_codcomp   := i.codcomp;
          v_codpos    := i.codpos;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('codpos',i.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('qty_promt',i.qtypromote);
          obj_data.put('salary_promt',i.amtprosal);

          v_cntamt    := 0;
          v_cntman    := 0;
          v_codempid  := '!@#$%';

          for k in c_ttmovemt loop
              flgpass := secur_main.secur3(k.codcomp,k.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
              if v_zupdsal = 'Y' then
                  get_wage_income(hcm_util.get_codcomp_level(k.codcomp,'1'),k.codempmt,
                                  stddec(k.amtincom1,k.codempid,v_chken),stddec(k.amtincom2,k.codempid,v_chken),
                                  stddec(k.amtincom3,k.codempid,v_chken),stddec(k.amtincom4,k.codempid,v_chken),
                                  stddec(k.amtincom5,k.codempid,v_chken),stddec(k.amtincom6,k.codempid,v_chken),
                                  stddec(k.amtincom7,k.codempid,v_chken),stddec(k.amtincom8,k.codempid,v_chken),
                                  stddec(k.amtincom9,k.codempid,v_chken),stddec(k.amtincom10,k.codempid,v_chken),
                                  v_sumhur,v_sumday,v_summth);
                  v_cntamt := nvl(v_cntamt,0)+v_summth;
              end if;
              if k.codempid <> v_codempid then
                v_codempid  := k.codempid;
                v_cntman    := nvl(v_cntman,0) + 1;
              end if;
          end loop;

          obj_data.put('qty_real',to_char(v_cntman,'fm999,990'));
          obj_data.put('salary_real',to_char(v_cntamt,'fm999,999,990.00'));
          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;


    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttmovemt');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;
  --
end;

/

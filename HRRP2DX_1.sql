--------------------------------------------------------
--  DDL for Package Body HRRP2DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2DX" is
-- last update: 15/04/2019 17:53

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');
    
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
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
    v_chksecu       varchar2(1);

    cursor c1 is
      select a.codcomp,a.codpos
        from ttmovemt a, tcodmove b
       where a.codtrn = b.codcodec 
         and b.typmove = '8'
         and a.staupd in ('C','U')
         and to_char(a.dteeffec,'yyyy') = b_index_year
         and a.codcomp like b_index_codcomp||'%'
         and ((v_chksecu = 1 )
             or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                     where x.coduser = global_v_coduser
                       and a.codcomp like a.codcomp||'%')
             and a.numlvl between global_v_zminlvl and global_v_zwrklvl))
         group by a.codcomp,a.codpos
         order by a.codcomp,a.codpos;
    
    cursor c2 is
      select a.codempid,codcomp,codempmt,
             a.amtincom1,a.amtincom2,
             a.amtincom3,a.amtincom4,
             a.amtincom5,a.amtincom6,
             a.amtincom7,a.amtincom8,
             a.amtincom9,a.amtincom10
        from ttmovemt a, tcodmove b
       where a.codtrn = b.codcodec
         and b.typmove = '8'
         and a.staupd in ('C','U')
         and to_char(a.dteeffec,'yyyymm') = b_index_year||v_month
         and a.codcomp = v_codcomp
         and a.codpos  = v_codpos
         and exists (select codcomp from tusrcom x
                     where x.coduser = global_v_coduser
                       and a.codcomp like a.codcomp||'%')
         and a.numlvl between global_v_zminlvl and global_v_zwrklvl
         order by a.codempid,a.dteeffec;

  begin
    obj_row := json_object_t();
    
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;
    
    if v_flgdata = 'Y' then
        v_chksecu := '2';
        for i in c1 loop
          v_flgsecu := 'Y';
          v_rcnt := v_rcnt+1;
          v_codcomp   := i.codcomp;
          v_codpos    := i.codpos;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('codpos',i.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          for j in 1..12 loop
            v_month     := lpad(j,2,0);
            v_cntamt    := 0;
            v_cntman    := 0;
            v_codempid  := '!@#$%';
            for k in c2 loop
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
            obj_data.put('qty'||j,to_char(v_cntman,'fm999,990'));
            obj_data.put('salary'||j,to_char(v_cntamt,'fm999,999,990.00'));
            obj_data.put('month'||j,j);
          end loop;
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if;
    
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttmovemt');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean; 
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;

    cursor c1 is
      select a.codempid,
             --ข้อมูลใหม่
             codcomp,codpos,codempmt,
             a.amtincom1,a.amtincom2,
             a.amtincom3,a.amtincom4,
             a.amtincom5,a.amtincom6,
             a.amtincom7,a.amtincom8,
             a.amtincom9,a.amtincom10,
             --ข้อมูลเก่า
             codcompt,codempmtt,codposnow,
             amtincadj1,amtincadj2,
             amtincadj3,amtincadj4,
             amtincadj5,amtincadj6,
             amtincadj7,amtincadj8,
             amtincadj9,amtincadj10
        from ttmovemt a, tcodmove b
       where a.codtrn = b.codcodec
         and b.typmove = '8'
         and a.staupd in ('C','U')
         and to_char(a.dteeffec,'yyyymm') = b_index_year||lpad(b_index_month,2,0)
         and a.codcomp = b_index_codcomp
         and a.codpos  = b_index_codpos
         and exists (select codcomp from tusrcom x
                     where x.coduser = global_v_coduser
                       and a.codcomp like a.codcomp||'%')
         and a.numlvl between global_v_zminlvl and global_v_zwrklvl
         order by a.codempid,a.dteeffec;

  begin

    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(i.codempid));
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('desc_codcompo',get_tcenter_name(i.codcompt,global_v_lang));
      obj_data.put('desc_codposo',get_tpostn_name(i.codposnow,global_v_lang));
      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_zupdsal = 'Y' then
        get_wage_income(hcm_util.get_codcomp_level(i.codcompt,'1'),i.codempmtt,
                              stddec(i.amtincadj1,i.codempid,v_chken),stddec(i.amtincadj2,i.codempid,v_chken),
                              stddec(i.amtincadj3,i.codempid,v_chken),stddec(i.amtincadj4,i.codempid,v_chken),
                              stddec(i.amtincadj5,i.codempid,v_chken),stddec(i.amtincadj6,i.codempid,v_chken),
                              stddec(i.amtincadj7,i.codempid,v_chken),stddec(i.amtincadj8,i.codempid,v_chken),
                              stddec(i.amtincadj9,i.codempid,v_chken),stddec(i.amtincadj10,i.codempid,v_chken),
                              v_sumhur,v_sumday,v_summth);
        obj_data.put('salaryo',to_char(v_summth,'fm999,999,990.00'));                     
        get_wage_income(hcm_util.get_codcomp_level(i.codcomp,'1'),i.codempmt,
                              stddec(i.amtincom1,i.codempid,v_chken),stddec(i.amtincom2,i.codempid,v_chken),
                              stddec(i.amtincom3,i.codempid,v_chken),stddec(i.amtincom4,i.codempid,v_chken),
                              stddec(i.amtincom5,i.codempid,v_chken),stddec(i.amtincom6,i.codempid,v_chken),
                              stddec(i.amtincom7,i.codempid,v_chken),stddec(i.amtincom8,i.codempid,v_chken),
                              stddec(i.amtincom9,i.codempid,v_chken),stddec(i.amtincom10,i.codempid,v_chken),
                              v_sumhur,v_sumday,v_summth);
        obj_data.put('salaryn',to_char(v_summth,'fm999,999,990.00'));
      else
        obj_data.put('salaryo','0.00');
        obj_data.put('salaryn','0.00');
      end if;
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

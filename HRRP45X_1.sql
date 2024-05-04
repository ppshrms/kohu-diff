--------------------------------------------------------
--  DDL for Package Body HRRP45X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP45X" is
-- last update: 11/08/2020 10:07

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    --block b_index
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index as
  begin
    if b_index_year > to_char(sysdate,'yyyy') then
      param_msg_error := get_error_msg_php('HR4509', global_v_lang);
      return;
    end if;
    if b_index_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);
    v_secur     	  boolean;
    flgpass     	  boolean;
    v_year          number := 0;
    v_month         number := 0;
    v_day           number := 0;
    v_codcomp       tposempd.codcomp%type;
    v_codpos        tposempd.codpos%type;
    v_present       number := 0;
    v_moveout1      number := 0;
    v_moveout2      number := 0;
    v_procur        number := 0;
    v_procur1       number := 0;
    v_procur2       number := 0;
    flg_procur1     boolean := false;
    flg_procur2     boolean := false;
    v_dtereq        date;
    v_codcompy    tcenter.codcompy%type;

    v_numseq        number := 0;
    v_codep         number := 0;

    cursor c1 is
      select b.codgrpos, codcomp, sum(qtybudgt) qtybudgt
        from TBUDGETM a, TGRPPOS b
       where a.codpos = b.codpos
         and dteyrbug = b_index_year
         and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)--ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
         and codcomp like b_index_codcomp || '%'
         --User37 #7127 1. RP Module 11/12/2021 and b.codcompy = v_codcompy
         and dtereq = v_dtereq
    group by b.codgrpos, codcomp--qtybudgt     -- #7230 || USER39 || 20/11/2021
    order by b.codgrpos, codcomp;
  begin
    begin
      select max(dtereq)
       into v_dtereq
       from TBUDGETM
      where dteyrbug = b_index_year
        and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)--ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
        and codcomp like b_index_codcomp || '%' ;
    exception when others then
      v_dtereq := null;
    end;
    obj_row := json_object_t();
    --User37 #7127 1. RP Module 11/12/2021 v_codcompy := hcm_util.get_codcomp_level(b_index_codcomp,1);

    -- clear ttemprpt
    begin
      delete
        from ttemprpt
       where codapp = 'HRRP45X'
         and codempid = global_v_codempid;
    end;
    --
    for i in c1 loop
        v_flgdata := 'Y';
        v_secur := secur_main.secur7(b_index_codcomp, global_v_coduser);
        if v_secur then
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codposg',i.codgrpos);
          obj_data.put('desc_codposg',get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang));
          obj_data.put('budget',i.qtybudgt);

          begin
            select count(codempid) into v_present
             from temploy1
            where codcomp = i.codcomp
              and codpos in (select codpos
                               from tgrppos
                              where codgrpos = i.codgrpos)
              and staemp in (1,3);
          exception when others then
            v_present := 0;
          end;
          obj_data.put('present',v_present);
          --
          begin
            select sum(qtyreq) into v_procur1
             from treqest1 a, treqest2 b
            where a.numreqst = b.numreqst
              and a.codcomp = i.codcomp
              and codpos in (select codpos
                               from tgrppos
                              where codgrpos = i.codgrpos)
              and a.stareq = 'P';
            flg_procur1 := true;
          exception when no_data_found then
            v_procur1 := 0;
            flg_procur1 := false;
          end;
          begin
            select sum(qtyreq-qtyact) into v_procur2
             from treqest1 a, treqest2 b
            where a.numreqst = b.numreqst
              and a.codcomp = i.codcomp
              and codpos in (select codpos
                               from tgrppos
                              where codgrpos = i.codgrpos)
              and a.stareq = 'F';
            flg_procur2 := true;
          exception when no_data_found then
            v_procur2 := 0;
            flg_procur2 := false;
          end;
          v_procur := v_procur1 + v_procur2;
          if flg_procur1 = false and flg_procur2 = false then
            begin
              select count(codempid)
                into v_procur
                from temploy1
               where codcomp = i.codcomp
                 and codpos in (select codpos
                                  from tgrppos
                                 where codgrpos = i.codgrpos )
                 and staemp = 0;
            exception when others then
              v_procur := 0;
            end;
          end if;
          v_procur := nvl(v_procur,0);
          obj_data.put('procur',v_procur);
          --
          begin
            select count(codempid) into v_moveout1
              from ttexempt
             where codcomp = i.codcomp
               and codpos in (select codpos
                               from tgrppos
                              where codgrpos = i.codgrpos)
              and staupd = 'C'
              and dteeffec > sysdate;
          exception when others then
            v_moveout1 := 0;
          end;
          --
          begin
            select count(codempid) into v_moveout2
             from ttmovemt
            where codcompt = i.codcomp
              and codposnow in (select codpos
                                  from tgrppos
                                  where codgrpos = i.codgrpos)
              and (codcomp <> i.codcomp or codpos not in (select codpos
                                                            from tgrppos
                                                            where codgrpos = i.codgrpos))
              and staupd = 'C'
              and dteeffec > sysdate;
          exception when others then
            v_moveout2 := 0;
          end;
          obj_data.put('moveout', v_moveout1 + v_moveout2);

          obj_data.put('net',i.qtybudgt - v_present + v_procur - v_moveout1 - v_moveout2);
          --
          v_numseq := v_numseq + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31 )
                 values (global_v_codempid, 'HRRP45X',v_numseq,
                          i.codgrpos, get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang),
                          v_codep, get_label_name('HRRP45X',global_v_lang,50),get_label_name('HRRP1AX1',global_v_lang,120),
                          i.qtybudgt,get_label_name('HRRP45X',global_v_lang,100) );

          v_numseq := v_numseq + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31 )
                 values (global_v_codempid, 'HRRP45X',v_numseq,
                          i.codgrpos, get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang),
                          v_codep, get_label_name('HRRP45X',global_v_lang,60),get_label_name('HRRP1AX1',global_v_lang,120),
                          v_present,get_label_name('HRRP45X',global_v_lang,100) );

          v_numseq := v_numseq + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31 )
                 values (global_v_codempid, 'HRRP45X',v_numseq,
                          i.codgrpos, get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang),
                          v_codep, get_label_name('HRRP45X',global_v_lang,70),get_label_name('HRRP1AX1',global_v_lang,120),
                          v_procur,get_label_name('HRRP45X',global_v_lang,100) );

          v_numseq := v_numseq + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,
                                item4,item5,
                                item7,item8,item9,
                                item10,item31 )
                 values (global_v_codempid, 'HRRP45X',v_numseq,
                          i.codgrpos, get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang),
                          v_codep, get_label_name('HRRP45X',global_v_lang,80),get_label_name('HRRP1AX1',global_v_lang,120),
                          v_moveout1 + v_moveout2,get_label_name('HRRP45X',global_v_lang,100) );
          v_codep := 0;
          --
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;

    if v_flgdata = 'Y' then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBUDGETM');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --

  procedure get_index_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_detail(json_str_output out clob) is
    obj_data        json_object_t;
    v_dtereq        date;
  begin
    begin
      select max(dtereq)
       into v_dtereq
       from TBUDGETM
      where dteyrbug = b_index_year
        and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)--ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
        and codcomp like b_index_codcomp||'%';
    exception when others then
      v_dtereq := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtereq',to_char(v_dtereq,'dd/mm/yyyy'));
    json_str_output := obj_data.to_clob;
  end;
  --
end;

/

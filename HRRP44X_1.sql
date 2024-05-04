--------------------------------------------------------
--  DDL for Package Body HRRP44X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP44X" is
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
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

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
     check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
      gen_graph;
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
    obj_tmp_row     json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);
    v2_date         varchar2(100 char);
    v_secur     	boolean;
    flgpass     	boolean;
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

    cursor c1 is
      select codcomp ,codpos ,qtybudgt
        from TBUDGETM a
       where dteyrbug  = b_index_year
         and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)   --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
         and codcomp   like b_index_codcomp || '%'
         and dtereq    = (select max(dtereq)
                             from TBUDGETM
                            where codpos    = a.codpos
                              and dteyrbug  = b_index_year
                              and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)  --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
                              and codcomp   like b_index_codcomp || '%')
      order by codcomp ,codpos;


  begin
    obj_row := json_object_t();

    if  to_char(b_index_year) =  to_char(sysdate,'yyyy') then
        v2_date := to_char(sysdate,'dd/mm/yyyy');
    else
        v2_date := '31/12/'||b_index_year;
    end if;

    for i in c1 loop
        v_flgdata := 'Y';
        v_secur := secur_main.secur7(b_index_codcomp, global_v_coduser);
        if v_secur then
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));   --get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang)
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          -- col.1
          obj_data.put('qtybudget',i.qtybudgt);

          -- col.2
          begin
            select count(codempid) into v_present
             from temploy1
            where codcomp = i.codcomp
              and codpos = i.codpos
              and staemp in ('1','3');
          exception when others then
            v_present := 0;
          end;
          obj_data.put('present',v_present);
          --

          -- col.3
          begin
            select count(codempid) into v_moveout1
              from ttexempt
             where codcomp = i.codcomp
               and codpos = i.codpos
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
              and codposnow = i.codpos
              and (codcomp <> i.codcomp or codpos <> i.codpos)
              and staupd = 'C'
              and dteeffec > sysdate;
          exception when others then
            v_moveout2 := 0;
          end;
          obj_data.put('moveout', v_moveout1 + v_moveout2);
          --

          -- col.4
          begin
            select sum(qtyreq) into v_procur1
             from treqest1 a, treqest2 b
            where a.numreqst = b.numreqst
              and a.codcomp = i.codcomp
              and codpos = i.codpos
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
              and codpos = i.codpos
              and a.stareq = 'F';
            flg_procur2 := true;
          exception when no_data_found then
            v_procur2 := 0;
            flg_procur2 := false;
          end;
          v_procur := nvl(v_procur1,0) + nvl(v_procur2,0);

          if flg_procur1 = false and flg_procur2 = false then
            begin
              select count(codempid)
                into v_procur
                from temploy1
               where codcomp = i.codcomp
                 and codpos = i.codpos
                 and staemp = '0';
            exception when others then
              v_procur := 0;
            end;
          end if;
          obj_data.put('during',v_procur);
          --

          -- col.5
          obj_data.put('rate',greatest((i.qtybudgt - v_present + v_procur - v_moveout1 - v_moveout2), 0)); ---- ,i.qtybudgt - v_present + v_procur - v_moveout1 - v_moveout2);

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --
          obj_row.put(to_char(v_rcnt-1),obj_data);

        end if;
    end loop;

    if v_flgdata = 'Y' then
      if v_rcnt > 0 then
        obj_tmp_row   := json_object_t();
        obj_tmp_row.put('rows', obj_row);

        obj_result    := json_object_t();
        obj_result.put('coderror','200');
        obj_result.put('date', v2_date);
        obj_result.put('table', obj_tmp_row);
        json_str_output := obj_result.to_clob;

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
 procedure check_index is
    v_codcompy  tcompny.codcompy%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';

  begin
    if b_index_year > to_char(sysdate,'yyyy') then
      param_msg_error := get_error_msg_php('HR4509',global_v_lang);
      return;
    end if;
  end;

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRRP44X';
    v_numseq    ttemprpt.numseq%type := 1;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;

    v_flgdata   varchar2(1 char) := 'N';
    v_cntemp    number;
    v_secur     boolean;
    v_present   number := 0;
    v_moveout1  number := 0;
    v_moveout2  number := 0;
    v_procur    number := 0;
    v_procur1   number := 0;
    v_procur2   number := 0;
    flg_procur1 boolean := false;
    flg_procur2 boolean := false;

    v_seq       number := 0;

    cursor c1 is
      select codcomp ,codpos ,qtybudgt
        from TBUDGETM a
       where dteyrbug  = b_index_year
         and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)   --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
         and codcomp   like b_index_codcomp||'%'
         and dtereq    = (select max(dtereq)
                             from TBUDGETM
                            where codpos    = a.codpos
                              and dteyrbug  = b_index_year
                              and dtemthbug = decode(b_index_year,to_char(sysdate,'yyyy'),to_number(to_char(sysdate,'mm')),12)  --ถ้าระบุปีปัจจุบัน ให้ใช้เดือนปัจจุบัน แต่ถ้าระบุปีย้อนหลัง ให้ Fix เดือน = 12
                              and codcomp   like b_index_codcomp||'%')
      order by codcomp ,codpos;

  begin
    param_msg_error := null;
    begin
      delete from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
         commit;

    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
      return;
    end;

    v_item31 := get_label_name('HRRP44XC2', global_v_lang, '70');   -- ชื่อกราฟ
--    v_item14 := b_index_typerep;
--    v_item1  := b_index_typerep; --get_label_name('HRRP2GXC2', global_v_lang, '40');

    for i in c1 loop
        v_flgdata := 'Y';
        v_secur := secur_main.secur7(b_index_codcomp, global_v_coduser);
        if v_secur then

          v_seq := v_seq + 1;

          for n in 1..5 loop

                  -- col.1
                  if n = 1 then
                     ----------Axis X detail(from data row)
                     v_item7  := '01'; --'qtybudget';
                     v_item8  := get_label_name('HRRP44XC2', global_v_lang, '60'); --ตามงบประมาณ
                     -- col.1  Data in table
                     v_item10 := i.qtybudgt;
                  end if;

                  -- col.2
                  begin
                    select count(codempid) into v_present
                     from temploy1
                    where codcomp = i.codcomp
                      and codpos = i.codpos
                      and staemp in ('1','3');
                  exception when others then
                    v_present := 0;
                  end;
                  if n = 2 then

                  ----------Axis X detail(from data row)
                     v_item7  := '02'; --'qtypresent';
                     v_item8  := get_label_name('HRRP44XC2', global_v_lang, '50'); --พนักงานปัจจุบัน
                     -- col.2  Data in table
                     v_item10 := v_present;
                  end if;


                  -- col.3
                  begin
                    select count(codempid) into v_moveout1
                      from ttexempt
                     where codcomp = i.codcomp
                       and codpos = i.codpos
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
                      and codposnow = i.codpos
                      and (codcomp <> i.codcomp or codpos <> i.codpos)
                      and staupd = 'C'
                      and dteeffec > sysdate;
                  exception when others then
                    v_moveout2 := 0;
                  end;

                  if n = 3 then
                  ----------Axis X detail(from data row)
                     v_item7  := '03'; --'moveout';
                     v_item8  := get_label_name('HRRP44XC2', global_v_lang, '40'); --ยื่นใบลาออก
                     -- col.3  Data in table
                     v_item10 := v_moveout1 + v_moveout2;
                  end if;
                  --

                  -- col.4
                  begin
                    select sum(qtyreq) into v_procur1
                     from treqest1 a, treqest2 b
                    where a.numreqst = b.numreqst
                      and a.codcomp = i.codcomp
                      and codpos = i.codpos
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
                      and codpos = i.codpos
                      and a.stareq = 'F';
                    flg_procur2 := true;
                  exception when no_data_found then
                    v_procur2 := 0;
                    flg_procur2 := false;
                  end;
                  v_procur := nvl(v_procur1,0) + nvl(v_procur2,0);

                  if flg_procur1 = false and flg_procur2 = false then
                    begin
                      select count(codempid)
                        into v_procur
                        from temploy1
                       where codcomp = i.codcomp
                         and codpos = i.codpos
                         and staemp = '0';
                    exception when others then
                      v_procur := 0;
                    end;
                  end if;

                  if n = 4 then
                  ----------Axis X detail(from data row)
                     v_item7  := '04'; --'during';
                     v_item8  := get_label_name('HRRP44XC2', global_v_lang, '30'); --ระหว่างจัดจ้าง
                     -- col.4  Data in table
                     v_item10 := v_procur;
                  end if;
                  --

                  if n = 5 then
                  ----------Axis X detail(from data row)
                       v_item7  := '05'; --'rate';
                       v_item8  := get_label_name('HRRP44XC2', global_v_lang, '20'); --อัตราว่าง
                       -- col.5  Data in table
                       v_item10 := i.qtybudgt - v_present + v_procur - v_moveout1 - v_moveout2 ;
                  end if;

                  ----------Axis X(from data column)
                  v_item4  := v_seq;
                  v_item5  := get_tpostn_name(i.codpos,global_v_lang);  --get_tcenter_name(i.codcomp,global_v_lang);


                  v_item6  := get_label_name('HRRP44XC2', global_v_lang, '80'); --ตำแหน่ง

                  ----------Axis Y Label
                  v_item9  := get_label_name('HRRP44XC2', global_v_lang, '10'); --จำนวนพนักงาน

                  ----------Insert ttemprpt
                   begin
                      insert into ttemprpt
                        (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
                      values
                        (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
                      commit;

                    exception when dup_val_on_index then
                      rollback;
                      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
                      return;
                    end;
                    v_numseq := v_numseq + 1;
           end loop;
        end if;
    end loop;

    commit;

    if v_numseq > 1 then
        param_msg_error := get_error_msg_php('HR2720', global_v_lang);
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBUDGETM');
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/

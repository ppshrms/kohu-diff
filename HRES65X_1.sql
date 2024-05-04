--------------------------------------------------------
--  DDL for Package Body HRES65X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES65X" is
-- last update: 15/04/2019 17:22

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_year        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_leave_type  := hcm_util.get_string_t(json_obj,'p_typeleave');

    begin
     select codcomp,dteempmt into global_v_codcomp ,global_v_dteempmt
     from   temploy1
     where codempid =  b_index_codempid;
    exception when no_data_found then
      null;
    end ;
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
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    v_typleave   tleavety.typleave%type;
    v_codleave   tleavecd.codleave%type;
    v_codempid   temploy1.codempid%type;
    v_codcomp    temploy1.codcomp%type;
    v_balance    number;
    v_overlimit  number;
    v_qtywkday   number;
    v_flgfound   boolean;
    v_syncond    varchar2(4000 char);
    v_stmt       varchar2(4000 char);
    v_qtypri     number;
    v_qtyleave   number;
    v_qtypriyr   number;
    v_qtyvacat   number;
    v_qtypriot   number;
    v_qtydleot   number;
    v_qtyprimx   number;
    v_qtydlemx   number;
    t_qtypri     number;
    t_qtyleave   number;
    v_remain1    number;
    v_remain2    number;
    v_remain3    number;
    v_use1       number;
    v_use2       number;
    v_use3       number;
    v_bal        number;
    v_over       number;
    v_svyre      number;
    v_svmth      number;
    v_svday      number;
    v_qtyday     number;

    v_dteeffec   date;
    v_qtylepay   number;

    obj_data     json_object_t;
    obj_row      json_object_t := json_object_t();
    v_count      number := 0;
    v_exist      boolean := false;
    v_permission boolean := false;
    v_date       date := to_date('3112'||to_char(b_index_year),'ddmmyyyy');
    v_qtyavgwk   number;

    v_dtecycst	 date;
		v_dtecycen	 date;

     cursor c1_temploy1 is
        select a.codempid,codcomp,typpayroll,dteempmt,dteeffex,
               staemp,numlvl,codpos,codsex,codempmt,typemp,nvl(qtywkday,0) qtywkday,codrelgn,jobgrade
          from temploy1 a, temploy2 b
         where a.codempid = b.codempid
           and a.codempid = b_index_codempid
      order by codcomp,a.codempid;

     cursor c2_tleavety is
        select typleave, flgdlemx, nvl(qtydlepay, 0) qtydlepay
          from tleavety
         where typleave like b_index_leave_type
      order by typleave;

     cursor c3_tleavecd is
        select c.*,rownum --15/02/2021
          from (select a.codleave,a.staleave,a.syncond
                  from tleavecd a, tleavcom b
                 where a.typleave = b.typleave
                   and a.typleave = v_typleave
                   and b.codcompy = (select hcm_util.get_codcomp_level(codcomp,1)
                                       from temploy1
                                      where codempid = b_index_codempid)
              order by a.codleave) c;

    cursor c4_tleavsum is
      select a.codleave,nvl(a.qtypriyr,0) qtypriyr,nvl(a.qtyvacat,0) qtyvacat,nvl(a.qtypriot,0) qtypriot,
             nvl(a.qtydleot,0) qtydleot,nvl(a.qtyprimx,0) qtyprimx,nvl(a.qtydlemx,0) qtydlemx,nvl(a.qtydayle,0) qtydayle,nvl(a.qtylepay,0) qtylepay
        from tleavsum a
       where a.codempid = b_index_codempid
         and a.dteyear  = b_index_year
         and a.typleave = v_typleave;
  begin
    for r1 in c1_temploy1 loop
      for r2 in c2_tleavety loop
        v_flgfound          := false;
        v_balance           := 0;
        v_overlimit         := 0;
        v_qtypri            := 0;
        v_qtyleave          := 0;
        v_qtypriyr          := 0;
        v_qtyvacat          := 0;
        v_qtypriot          := 0;
        v_qtydleot          := 0;
        v_qtyprimx          := 0;
        v_qtydlemx          := 0;
        t_qtypri            := 0;
        t_qtyleave          := 0;
        v_remain1           := 0;
        v_remain2           := 0;
        v_remain3           := 0;
        v_use1              := 0;
        v_use2              := 0;
        v_use3              := 0;
        v_bal               := 0;
        v_over              := 0;
        v_svyre             := 0;
        v_svmth             := 0;
        v_svday             := 0;
        v_qtyday            := 0;
        v_typleave          := r2.typleave;

        for r3 in c3_tleavecd loop
          v_codleave := r3.codleave;
          --<<15/02/2021
          if r3.rownum = 1 then
            std_al.cycle_leave2(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codempid,v_codleave,b_index_year,v_dtecycst,v_dtecycen);
            v_date := v_dtecycen;
          end if;
          -->>15/02/2021
          v_flgfound := false;
          v_flgfound := hral56b_batch.check_condition_leave(r1.codempid,v_codleave,sysdate,'1');
          if v_flgfound then
            v_exist      := true;
            if r3.staleave in ('V','C') or r2.flgdlemx = 'Y' then
              begin
                select nvl(qtypriyr,0),nvl(qtyvacat,0), nvl(qtypriot,0),nvl(qtydleot,0), nvl(qtyprimx,0),nvl(qtydlemx,0),nvl(qtylepay,0)
                  into v_qtypriyr,v_qtyvacat, v_qtypriot,v_qtydleot, v_qtyprimx,v_qtydlemx,v_qtylepay
                  from tleavsum
                 where codempid = r1.codempid
                   and dteyear  = b_index_year
                   and codleave = v_codleave;
              exception when no_data_found then
                v_qtypriyr := 0;
                v_qtyvacat := 0;
                v_qtypriot := 0;
                v_qtydleot := 0;
                v_qtyprimx := 0;
                v_qtydlemx := 0;
                v_qtylepay := 0;
              end;
              if r3.staleave = 'V' then
                v_qtypri   := v_qtypriyr;
                v_qtyleave := v_qtyvacat - v_qtypriyr + v_qtylepay;
              elsif r3.staleave = 'C' then
                v_qtypri   := v_qtypri + v_qtypriot;
                v_qtyleave := v_qtyleave + v_qtydleot - v_qtypriot;
              elsif r2.flgdlemx = 'Y' then
                if (nvl(v_qtyprimx,0) > 0 or nvl(v_qtydlemx,0) > 0) then
                  v_qtypri   := v_qtypri + v_qtyprimx;
                  v_qtyleave := v_qtyleave + (v_qtydlemx - v_qtyprimx);
                else
                  std_al.entitlement(r1.codempid, v_codleave, v_date, 0, v_qtyleave, v_qtypri, v_dteeffec);
                  v_qtypri   := v_qtypri;
                  v_qtyleave := v_qtyleave;
                end if;
              end if;
            else
              std_al.entitlement(r1.codempid, v_codleave, v_date, 0, v_qtyleave, v_qtypri, v_dteeffec);
            end if;

            if r2.flgdlemx = 'Y' and ((nvl(v_qtyprimx,0) > 0 or nvl(v_qtydlemx,0) > 0)) then
              null;
            else
              exit;
            end if;
          end if;
        end loop; -- c3_tleavecd

        if v_flgfound then
          v_remain1  := nvl(v_qtypri,0);
          v_remain2  := nvl(v_qtyleave,0);
          v_remain3  := v_remain1 + v_remain2;
          v_codempid := r1.codempid;
          for r4 in c4_tleavsum loop
            v_use1    := v_use1 + r4.qtydayle;
            v_use2    := v_use2 + r4.qtylepay;
          end loop;
          v_use3    := v_use1 + v_use2;
          v_bal       := nvl(v_remain3,0) - nvl(v_use3,0);
          v_bal       := v_bal + v_balance + (-1*v_overlimit);
          if v_bal > 0 then
            v_balance := v_bal;
            v_overlimit := 0;
          else
            v_balance := 0;
            v_overlimit := (-1)*v_bal;
          end if;

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('leave_of_type',v_typleave||' : '||get_tleavety_name(v_typleave,global_v_lang));
          obj_data.put('bal_forward',cal_dhm_concat(v_remain1));
          obj_data.put('this_year',cal_dhm_concat(v_remain2));
          obj_data.put('total_day',cal_dhm_concat(v_remain3));
          obj_data.put('leave_used',cal_dhm_concat(v_use1));
          obj_data.put('qtylepay',cal_dhm_concat(v_use2));
          obj_data.put('balance',cal_dhm_concat(v_bal));

          obj_row.put(to_char(v_count),obj_data);
          v_count := v_count + 1;
        end if;
      end loop;
--
    end loop;
    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tleavsum');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure check_index is
    v_count   number;
  begin
    -- check secure
/*
    param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
    if param_msg_error is not null then
      return;
    end if;
*/
    if b_index_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if b_index_leave_type is null then
      b_index_leave_type := '%';
    end if;

    global_v_qtyavgwk := hcm_util.get_qtyavgwk(global_v_codcomp,b_index_codempid);

  end check_index;
  --
  function cal_dhm_concat (p_qtyday   in  number) return varchar2 is
    v_min   number;
    v_hour  number;
    v_day   number;
    v_num   number;
    v_dhm   varchar2(30 char);
    v_qtyday number;
    v_con   varchar2(30 char);
  begin
    v_qtyday := p_qtyday;
    if v_qtyday is not null then
      if v_qtyday < 0 then
          v_qtyday := v_qtyday * (-1);
          v_con    := '-';
      end if;

      v_day   := trunc(v_qtyday / 1);
      v_num   := round(mod((v_qtyday * global_v_qtyavgwk),global_v_qtyavgwk),0);
      v_hour  := trunc(v_num / 60);
      v_min   := mod(v_num,60);
      v_dhm   := v_con||to_char(v_day)||':'||
                 nvl(lpad(to_char(v_hour),2,'0'),'00')||':'||
                 nvl(lpad(to_char(v_min),2,'0'),'00');
    else
      v_dhm := '-';
    end if;
    return(v_dhm);
  end cal_dhm_concat;
end;

/

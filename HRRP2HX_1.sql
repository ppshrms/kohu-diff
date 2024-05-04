--------------------------------------------------------
--  DDL for Package Body HRRP2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2HX" is
-- last update: 15/04/2019 17:53

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    v_chk_year      varchar2(10 char);    --#7124 || User39 || 28/10/2021
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
    b_index_month       := hcm_util.get_string_t(json_obj,'p_month');

--#7124 || User39 || 28/10/2021
    v_chk_year := to_char(sysdate,'yyyy');
    if b_index_year > v_chk_year then
        param_msg_error := get_error_msg_php('HR4509',global_v_lang);
--        return;
    end if;
--#7124 || User39 || 28/10/2021

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
    v_secur     	boolean;
    flgpass     	boolean;
    v_year          number := 0;
    v_month         number := 0;
    v_day           number := 0;
    v_codcomp       tposempd.codcomp%type;
    v_codpos        tposempd.codpos%type;
    v_present       number := 0;
    v_movin         number := 0;
    v_moveout1      number := 0;
    v_moveout2      number := 0;
    v_procur        number := 0;
    v_procur1       number := 0;
    v_procur2       number := 0;
    flg_procur1     boolean := false;
    flg_procur2     boolean := false;
    v_promote       number := 0;
    v_sum_budget    number := 0;
    v_sum_movein    number := 0;
    v_sum_moveout   number := 0;
    v_sum_promote   number := 0;
    v_sum_present   number := 0;
    v_sum_blank     number := 0;

    cursor c1 is
      select codcomp ,codpos ,qtybudgt
        from TBUDGETM a
       where dteyrbug  = b_index_year
         and dtemthbug = b_index_month
         and codcomp   like b_index_codcomp||'%'
         and dtereq    = (select max(dtereq)
                             from TBUDGETM
                            where codpos    = a.codpos
                              and dteyrbug  = b_index_year
                              and dtemthbug = b_index_month
                              and codcomp   like b_index_codcomp||'%' )
      order by codcomp ,codpos;


  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
        v_secur := secur_main.secur7(b_index_codcomp, global_v_coduser);
        if v_secur then
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp',i.codcomp);
          -- col.1
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));   --get_tcodec_name('TCODGPOS',i.codgrpos,global_v_lang)
          obj_data.put('codpos',i.codpos);
          -- col.2
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          -- col.3
          obj_data.put('budget',nvl(i.qtybudgt,0));
          v_sum_budget    := v_sum_budget + nvl(i.qtybudgt,0);

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
                 and staemp = 0;
            exception when others then
              v_procur := 0;
            end;
          end if;
          begin
            select count(codempid) into v_movin
              from ttmovemt
             where codcomp = i.codcomp
               and codpos = i.codpos
               and (codcompt <> i.codcomp
                or codposnow <> i.codpos)
               and staupd = 'C' 
               and dteeffec > sysdate;
          exception when others then
              v_movin := 0;
          end;
          obj_data.put('movein',v_procur + v_movin);
          v_sum_movein := v_sum_movein + nvl(v_procur,0) + nvl(v_movin,0);
          --

          -- col.5
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
          v_sum_moveout  :=  v_sum_moveout + (v_moveout1 + v_moveout2);
          --

          -- col.6
          begin
            select count(codempid) into v_promote
             from ttmovemt
            where codcomp = i.codcomp
              and codposnow <> codpos
              and codpos <> i.codpos
              and staupd = 'C'
              and dteeffec >= sysdate;
          exception when others then
            v_promote := 0;
          end;
          obj_data.put('promote', v_promote);
          v_sum_promote  :=  v_sum_promote + v_promote;
          --

          -- col.7
          begin
            select count(codempid) into v_present
             from temploy1
            where codcomp = i.codcomp
              and codpos = i.codpos
              and staemp in (1,3);
          exception when others then
            v_present := 0;
          end;
          obj_data.put('present',v_present);
          v_sum_present  :=  v_sum_present + v_present;
          --

          -- col.8
          obj_data.put('blank',i.qtybudgt - v_present + v_procur - v_moveout1 - v_moveout2);
          v_sum_blank := v_sum_blank + (nvl(i.qtybudgt,0) - v_present + v_procur - v_moveout1 - v_moveout2);

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --
          obj_row.put(to_char(v_rcnt-1),obj_data);

        end if;
    end loop;


    if v_flgdata = 'Y' then
      if v_rcnt > 0 then
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codcomp','');
            obj_data.put('desc_codcomp','');
            obj_data.put('codpos','');
            obj_data.put('desc_codpos',get_label_name('HRRP2HX', global_v_lang, 140));
            ----------------------------------
            obj_data.put('budget',v_sum_budget);
            obj_data.put('movein',v_sum_movein);
            obj_data.put('moveout',v_sum_moveout);
            obj_data.put('promote',v_sum_promote);
            obj_data.put('present',v_sum_present);
            obj_data.put('blank',v_sum_blank);
            ---------------------------------------
            obj_row.put(to_char(v_rcnt-1),obj_data);
            ---------------------------------------
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
end;

/

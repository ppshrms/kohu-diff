--------------------------------------------------------
--  DDL for Package Body HRAL44X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL44X" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    -- special
    v_text_key    := 'otrate';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_count     number;
  begin
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
    if p_codempid is not null then
      p_codcomp := null;
      p_codcalen := null;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codcalen is not null then
        v_count := 0;
        begin
            select  count(*)
              into  v_count
              from  tcodwork
             where  codcodec = p_codcalen;
        exception when others then
            v_count := 0;
        end;
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
            return;
        end if;
    end if;
  end;

  procedure gen_index(json_str_output out clob) is
    type t_otrate is table of totratep2.rteotpay%type;
    type t_sum_otrate is table of number;
    v_otrate            t_otrate    := t_otrate();
    v_otrate_count      number      := 1;
    v_exist             boolean     := false;
    v_secur             boolean     := false;
    v_token_vchar       varchar2(4000 char);
    json_obj            json_object_t        := json_object_t();
    json_obj1           json_object_t        := json_object_t();
    json_obj2           json_object_t        := json_object_t();
    json_row            json_object_t;
    v_index             number      := 0;
    v_count             number      := 0;
    v_token_number      number;
    v_numlvl            number;
    v_before            number;
    v_during            number;
    v_after             number;
    v_qtyavgwk          number;
    v_dtework           date;
    v_typot             tovrtime.typot%type;
 -- v_typwork           tattence.typwork%type;
    v_typwork           tovrtime.typwork%type;
    v_codcompw          tovrtime.codcompw%type;
    v_timin             tattence.timin%type;
    v_timout            tattence.timout%type;
    v_codcompy          tcenter.codcomp%type;
    v_codempid          temploy1.codempid%type;
    v_qtyminot          tovrtime.qtyminot%type;
    v_sum_otrate        t_sum_otrate    := t_sum_otrate();
    v_sum_after         number          := 0;
    v_sum_before        number          := 0;
    v_sum_during        number          := 0;
    v_sum_amtmeal       number          := 0;
    v_sum_qtyleave      number          := 0;
    v_coscent           varchar2(1000 char);

    cursor c_totratep2_1 is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy like v_codcompy || '%'
    order by rteotpay;

    cursor c_totratep2_2 is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,tusrcom t2
       where t2.coduser = global_v_coduser
         and t1.codcompy like hcm_util.get_codcomp_level(t2.codcomp, 1) || '%'
    order by t1.rteotpay;

    cursor c1 is
        select  a.codempid,a.codcomp,nvl(a.codcompw,a.codcomp) as codcompw ,a.dtework,
                sum(nvl(stddec(a.amtmeal,a.codempid,v_chken),0)) amtmeal,sum(nvl(a.qtyleave,0)) qtyleave,
                b.typwork
          from  tovrtime a, tattence b
         where  a.codempid = b.codempid
           and  a.dtework  = b.dtework
           and  a.codcomp  like p_codcomp||'%'
           and  a.codcalen = nvl(p_codcalen,a.codcalen)
           and  a.codempid = nvl(p_codempid,a.codempid)
           and  a.dtework  between p_dtestrt and p_dteend
      group by  a.codempid,a.codcomp,a.codcompw,a.dtework,b.typwork
      order by  a.codcomp,a.codempid,a.dtework,b.typwork;

    cursor c_typot is
        select  typot,nvl(qtyminot,0) qtyminot
          from  tovrtime
         where  codempid  = v_codempid
           and  dtework   = v_dtework
           and  nvl(codcompw,codcomp)  = v_codcompw;

  begin
    if p_codcomp is not null then
        v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif p_codempid is not null then
        begin
            select  hcm_util.get_codcomp_level(codcomp, 1)
              into  v_codcompy
              from  temploy1
             where  codempid = p_codempid;
        exception when no_data_found then null;
        end;
    end if;
    for r_totratep2_1 in c_totratep2_1 loop
        v_sum_otrate.extend();
        v_sum_otrate(v_otrate_count) := 0;
        v_otrate.extend();
        v_otrate(v_otrate_count) := r_totratep2_1.rteotpay;
        v_otrate_count := v_otrate_count + 1;
    end loop;

    for r1 in c1 loop
        v_exist := true;
        if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
            v_secur     := true;
            json_row    := json_object_t();
            v_codempid  := r1.codempid;
            v_dtework   := r1.dtework;
            v_before    := 0;
            v_during    := 0;
            v_after     := 0;
            v_index := v_index + 1;
            -- get costcenter --
            begin
              select costcent into v_coscent
                from tcenter
               where codcomp = r1.codcompw
                 and rownum <= 1
            order by codcomp;
            exception when no_data_found then
              v_coscent := null;
            end;
            --
            json_row.put('index',to_char(v_index));
            json_row.put('dtework',to_char(r1.dtework,'dd/mm/yyyy'));
            json_row.put('image',get_emp_img(r1.codempid));
            json_row.put('codempid',r1.codempid);
            json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            json_row.put('codcomp',r1.codcomp);
            json_row.put('typwork',r1.typwork);
            json_row.put('coscent',v_coscent);
            json_row.put('codcomp_charge',get_tcenter_name(r1.codcompw, global_v_lang));

            begin
                select  timin,timout
                  into  v_timin,v_timout
                  from  tattence
                 where  codempid = r1.codempid
                   and  dtework  = r1.dtework;

                if v_timin is not null then
                    json_row.put('timin' ,substr(lpad(v_timin ,4,'0'),1,2) || ':' || substr(lpad(v_timin ,4,'0'),3,2));
                end if;
                if v_timout is not null then
                    json_row.put('timout',substr(lpad(v_timout,4,'0'),1,2) || ':' || substr(lpad(v_timout,4,'0'),3,2));
                end if;
            exception when no_data_found then
                null;
            end;

            v_typwork := r1.typwork;
            v_codcompw := r1.codcompw;
            for r2 in c_typot loop
                if r2.typot = 'B' then
                    v_before := v_before + r2.qtyminot;
                elsif r2.typot = 'D' then
                    v_during := v_during + r2.qtyminot;
                elsif r2.typot = 'A' then
                    v_after  := v_after  + r2.qtyminot;
                end if;
            end loop;
            if v_before != 0 then
                v_sum_before := v_sum_before + v_before;
                json_row.put('before'      , to_char(v_before));
                json_row.put('amtbefore'   ,v_before);
            end if;
            if v_during != 0 then
                v_sum_during := v_sum_during + v_before;
                json_row.put('during'      , (v_during));
                json_row.put('amtduring'   ,v_during);
            end if;
            if v_after  != 0 then
                v_sum_after := v_sum_after + v_before;
                json_row.put('after'       , to_char(v_after));
                json_row.put('amtafter'    ,v_after);
            end if;
            json_row.put('otrate_count',to_char(v_otrate_count-1));
            for i in 1..(v_otrate_count-1) loop
              begin
                select  sum(nvl(a.qtyminot,0))
                  into  v_qtyminot
                  from  totpaydt a,tovrtime b
                 where  a.codempid = b.codempid
                   and  a.dtework  = b.dtework
                   and  a.typot    = b.typot
                   and  a.codempid = v_codempid
                   and  a.dtework  = v_dtework
                   and  a.rteotpay = v_otrate(i)
                   and  nvl(b.codcompw,b.codcomp) = v_codcompw;

                if v_qtyminot is not null and v_qtyminot != 0 then
                    json_row.put('rteotpay'||to_char(i), to_char(v_qtyminot));
                    v_sum_otrate(i) := v_sum_otrate(i) + nvl(v_qtyminot,0);
                end if;
              exception when others then null;
              end;
            end loop;
            v_qtyavgwk := hcm_util.get_qtyavgwk(null,r1.codempid);
            -- check permissions
            if nvl(v_zupdsal, 'Y') = 'Y' then
              v_sum_amtmeal := v_sum_amtmeal + nvl(r1.amtmeal,0);
              if r1.amtmeal <> 0 then
                  json_row.put('amtmeal' ,nvl(r1.amtmeal,0));
              end if;
            end if;
            v_sum_qtyleave := v_sum_qtyleave + nvl(r1.qtyleave,0);
            json_row.put('qtyleave', nvl(r1.qtyleave,0));
            json_obj.put(to_char(v_count),json_row);
            v_count := v_count + 1;
        end if;
    end loop;
    if not v_exist then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tovrtime');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
        return;
    end if;
    if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    json_obj2.put('table',json_obj);
    json_obj2.put('coderror','200');
		json_str_output := json_obj2.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
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

  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_ot_head;
    if param_msg_error is null then
      gen_ot_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
    obj_data           json_object_t;
    obj_row            json_object_t;
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
  begin
    obj_data           := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif p_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', obj_ot_col.get_size);
    for i in 1..obj_ot_col.get_size loop
      obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
    end loop;
    obj_row.put(0, obj_data);
		json_str_output := obj_row.to_clob;
  end gen_ot_head;

  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
--         and dteeffec = (select max(b.dteeffec)
--                           from totratep2 b
--                          where b.codcompy = v_codcompy
--                            and b.dteeffec <= sysdate)
    order by rteotpay;
  begin
    obj_ot_col := json_object_t();
    for row_ot in max_ot_col loop
      v_max_ot_col := v_max_ot_col + 1;
      obj_ot_col.put(to_char(v_max_ot_col), row_ot.rteotpay);
    end loop;
    return obj_ot_col;
  exception
  when others then
    return json_object_t();
  end;

end hral44x;

/

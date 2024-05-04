--------------------------------------------------------
--  DDL for Package Body HRAL3AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3AX" as

  procedure initial_value (json_str_input in clob) as
    json_obj 				json_object_t;
  begin
    json_obj        		:= json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteyear       := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_stmonth       := hcm_util.get_string_t(json_obj,'p_stmonth');
    p_enmonth       := hcm_util.get_string_t(json_obj,'p_enmonth');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index as
  begin
    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_stmonth is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_enmonth is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if to_number(p_stmonth) > to_number(p_enmonth) then
      param_msg_error := get_error_msg_php('HR2032',global_v_lang);
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    json_row            json_object_t;
    json_obj            json_object_t;
    v_codempid          varchar2(4000 char);
    v_stdate            date;
    v_endate            date;
    v_count             number  := 0;
    v_secur             boolean := false;
    v_permission        boolean := false;
    v_data_exist        boolean := false;
    v_codcomp           varchar2(4000 char);
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_comlevel          tcenter.comlevel%type;
    v_codpos            temploy1.codpos%type;

    cursor c1 is
      select codempid
      from tattence
      where codcomp like p_codcomp ||'%'
      and to_char(dtework, 'yyyymm') between p_dteyear||lpad(p_stmonth,2,'0') and p_dteyear||lpad(p_enmonth,2,'0')
      group by codempid
      order by codempid;

    cursor c2 is
        select  sum(nvl(t1.qtylate,0))     v_qtylate   , sum(nvl(t1.qtytlate,0))   v_qtytlate,
                sum(nvl(t1.qtyearly,0))    v_qtyearly  , sum(nvl(t1.qtytearly,0))  v_qtytearly,
                sum(nvl(t1.qtyabsent,0))   v_qtyabsent , sum(nvl(t1.qtytabs,0))    v_qtytabs,
                sum(nvl(t1.qtynostam,0))   v_qtynostam
        from    tlateabs t1
        where   t1.codempid = v_codempid
        and     to_char(dtework, 'yyyymm') = p_dteyear||lpad(p_enmonth,2,'0') ;

    cursor c3 is
        select  sum(nvl(t1.qtylate,0))     v_qtylate   , sum(nvl(t1.qtytlate,0))   v_qtytlate,
                sum(nvl(t1.qtyearly,0))    v_qtyearly  , sum(nvl(t1.qtytearly,0))  v_qtytearly,
                sum(nvl(t1.qtyabsent,0))   v_qtyabsent , sum(nvl(t1.qtytabs,0))    v_qtytabs,
                sum(nvl(t1.qtynostam,0))   v_qtynostam
        from    tlateabs t1
        where   t1.codempid = v_codempid
        and     to_char(dtework, 'yyyymm') between p_dteyear||lpad(p_stmonth,2,'0') and p_dteyear||lpad(p_enmonth,2,'0') ;

  begin
    v_stdate := to_date('01'|| lpad(p_stmonth,2,'0') ||p_dteyear,'ddmmyyyy');
    v_endate := last_day(to_date('01'|| lpad(p_enmonth,2,'0') ||p_dteyear,'ddmmyyyy'));

    json_obj := json_object_t();
    for r1 in c1 loop
        -- check permission here
        v_codempid := r1.codempid;
        v_data_exist := true;
        v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_secur then
            v_permission := true;

            begin
              select codpos
              into v_codpos
              from temploy1
              where codempid = r1.codempid;
            exception when no_data_found then
              v_codpos := null;
            end;

            json_row := json_object_t();
            json_row.put('image', get_emp_img(r1.codempid));--User37 #5627 Final Test Phase 1 V11 30/03/2021 
            json_row.put('codempid'      , r1.codempid);
            json_row.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
            json_row.put('codpos'        , v_codpos);
            json_row.put('desc_codpos'   , get_tpostn_name(v_codpos,global_v_lang));
            json_row.put('datarange'     , get_label_name('HRAL3AX', global_v_lang, 180));
            for r2 in c2 loop

                --<<User37 #5021 Final Test Phase 1 V11 29/03/2021 
                if r2.v_qtylate <> 0 and r2.v_qtylate is not null then
                    json_row.put('qtylate'   , to_char(floor(nvl(r2.v_qtylate,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtylate,0),60)),2,'0'));--
                else
                    json_row.put('qtylate'   , '0:00');
                end if;
                if r2.v_qtytlate <> 0 and  r2.v_qtytlate is not null then
                    json_row.put('qtytlate'  , nvl(r2.v_qtytlate,0));
                else
                    json_row.put('qtytlate'   , '0');
                end if;
                if r2.v_qtyearly <> 0 and r2.v_qtyearly is not null then
                    json_row.put('qtyearly'  , to_char(floor(nvl(r2.v_qtyearly,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtyearly,0),60)),2,'0'));--
                else
                    json_row.put('qtyearly'   , '0:00');
                end if;
                if r2.v_qtytearly <> 0 and r2.v_qtytearly is not null then
                    json_row.put('qtytearly' , nvl(r2.v_qtytearly,0));
                else
                    json_row.put('qtytearly'   , '0');
                end if;
                if r2.v_qtyabsent <> 0 and r2.v_qtyabsent is not null then
                    json_row.put('qtyabsent' , to_char(floor(nvl(r2.v_qtyabsent,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtyabsent,0),60)),2,'0'));--
                else
                    json_row.put('qtyabsent'   , '0:00');
                end if;
                if r2.v_qtytabs <> 0 and r2.v_qtytabs is not null then
                    json_row.put('qtytabs'   , nvl(r2.v_qtytabs,0));
                else
                    json_row.put('qtytabs'   , '0');
                end if;
                if r2.v_qtynostam <> 0 and r2.v_qtynostam is not null then
                    json_row.put('qtynostam' , to_char(r2.v_qtynostam));--
                else
                    json_row.put('qtynostam'   , '0');
                end if;
                /*if r2.v_qtylate <> 0 and r2.v_qtylate is not null then
                    json_row.put('qtylate'   , to_char(floor(nvl(r2.v_qtylate,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtylate,0),60)),2,'0'));--
                end if;
                if r2.v_qtytlate <> 0 and  r2.v_qtytlate is not null then
                    json_row.put('qtytlate'  , nvl(r2.v_qtytlate,0));
                end if;
                if r2.v_qtyearly <> 0 and r2.v_qtyearly is not null then
                    json_row.put('qtyearly'  , to_char(floor(nvl(r2.v_qtyearly,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtyearly,0),60)),2,'0'));--
                end if;
                if r2.v_qtytearly <> 0 and r2.v_qtytearly is not null then
                    json_row.put('qtytearly' , nvl(r2.v_qtytearly,0));
                end if;
                if r2.v_qtyabsent <> 0 and r2.v_qtyabsent is not null then
                    json_row.put('qtyabsent' , to_char(floor(nvl(r2.v_qtyabsent,0)/60)) || ':' || lpad(to_char(mod(nvl(r2.v_qtyabsent,0),60)),2,'0'));--
                end if;
                if r2.v_qtytabs <> 0 and r2.v_qtytabs is not null then
                    json_row.put('qtytabs'   , nvl(r2.v_qtytabs,0));
                end if;
                if r2.v_qtynostam <> 0 and r2.v_qtynostam is not null then
                    json_row.put('qtynostam' , to_char(r2.v_qtynostam));--
                end if;*/
                -->>User37 #5021 Final Test Phase 1 V11 29/03/2021 
                json_row.put('coderror'      , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
            end loop;
            json_row := json_object_t();
            json_row.put('image', get_emp_img(r1.codempid));--User37 #5627 Final Test Phase 1 V11 30/03/2021 
            json_row.put('codempid'      , r1.codempid);
            json_row.put('desc_codempid' , get_temploy_name(r1.codempid,global_v_lang));
            json_row.put('codpos'        , v_codpos);
            json_row.put('desc_codpos'   , get_tpostn_name(v_codpos,global_v_lang));
            json_row.put('datarange' , 'YTH');
            json_row.put('datarange' , get_label_name('HRAL3AX', global_v_lang, 190));

            for r3 in c3 loop

                --<<User37 #5021 Final Test Phase 1 V11 29/03/2021 
                if r3.v_qtylate <> 0 and r3.v_qtylate is not null then
                    json_row.put('qtylate'   , to_char(floor(nvl(r3.v_qtylate,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtylate,0),60)),2,'0'));--
                else
                    json_row.put('qtylate'   , '0:00');
                end if;
                if r3.v_qtytlate <> 0 and  r3.v_qtytlate is not null then
                    json_row.put('qtytlate'  , nvl(r3.v_qtytlate,0));
                else
                    json_row.put('qtytlate'   , '0');
                end if;
                if r3.v_qtyearly <> 0 and r3.v_qtyearly is not null then
                    json_row.put('qtyearly'  , to_char(floor(nvl(r3.v_qtyearly,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtyearly,0),60)),2,'0'));--
                else
                    json_row.put('qtyearly'   , '0:00');
                end if;
                if r3.v_qtytearly <> 0 and r3.v_qtytearly is not null then
                    json_row.put('qtytearly' , nvl(r3.v_qtytearly,0));
                else
                    json_row.put('qtytearly'   , '0');
                end if;
                if r3.v_qtyabsent <> 0 and r3.v_qtyabsent is not null then
                    json_row.put('qtyabsent' , to_char(floor(nvl(r3.v_qtyabsent,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtyabsent,0),60)),2,'0'));--
                else
                    json_row.put('qtyabsent'   , '0:00');
                end if;
                if r3.v_qtytabs <> 0 and r3.v_qtytabs is not null then
                    json_row.put('qtytabs'   , nvl(r3.v_qtytabs,0));
                else
                    json_row.put('qtytabs'   , '0');
                end if;
                if r3.v_qtynostam <> 0 and r3.v_qtynostam is not null then
                    json_row.put('qtynostam' , to_char(r3.v_qtynostam));--
                else
                    json_row.put('qtynostam'   , '0');
                end if;
                /*if r3.v_qtylate <> 0 and r3.v_qtylate is not null then
                    json_row.put('qtylate'   , to_char(floor(nvl(r3.v_qtylate,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtylate,0),60)),2,'0'));--
                end if;
                if r3.v_qtytlate <> 0 and  r3.v_qtytlate is not null then
                    json_row.put('qtytlate'  , nvl(r3.v_qtytlate,0));
                end if;
                if r3.v_qtyearly <> 0 and r3.v_qtyearly is not null then
                    json_row.put('qtyearly'  , to_char(floor(nvl(r3.v_qtyearly,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtyearly,0),60)),2,'0'));--
                end if;
                if r3.v_qtytearly <> 0 and r3.v_qtytearly is not null then
                    json_row.put('qtytearly' , nvl(r3.v_qtytearly,0));
                end if;
                if r3.v_qtyabsent <> 0 and r3.v_qtyabsent is not null then
                    json_row.put('qtyabsent' , to_char(floor(nvl(r3.v_qtyabsent,0)/60)) || ':' || lpad(to_char(mod(nvl(r3.v_qtyabsent,0),60)),2,'0'));--
                end if;
                if r3.v_qtytabs <> 0 and r3.v_qtytabs is not null then
                    json_row.put('qtytabs'   , nvl(r3.v_qtytabs,0));
                end if;
                if r3.v_qtynostam <> 0 and r3.v_qtynostam is not null then
                    json_row.put('qtynostam' , to_char(r3.v_qtynostam));--
                end if;*/
                -->>User37 #5021 Final Test Phase 1 V11 29/03/2021 
                json_row.put('coderror'      , '200');
                json_obj.put(to_char(v_count),json_row);
                v_count := v_count + 1;
            end loop;
        end if;
    end loop;
    if v_data_exist then
        if v_permission then
            -- 200 OK
						json_str_output := json_obj.to_clob;
        else
            -- error permisssion denied HR3007
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        end if;
    else
        -- error data not found HR2055
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlateabs');
        json_str_output := get_response_message('404',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end HRAL3AX;

/

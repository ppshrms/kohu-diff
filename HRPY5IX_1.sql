--------------------------------------------------------
--  DDL for Package Body HRPY5IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5IX" as
  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_month      := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;

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
    obj_data          json_object_t;
    obj_rows          json_object_t := json_object_t();
    v_count           number := 0;
    v_flg_exist       boolean := false;
    v_flg_secure      boolean := false;
    v_flg_permission  boolean := false;
    v_flgpass			    boolean := true;

    v_codempid        temploy1.codempid%type;
  	v_dtestr          date;
  	v_dteend          date;



    cursor c1 is
      select b.codcomp,b.codempid,a.numlvl,a.dteeffex,
             stddec(b.amtcalt,b.codempid,global_v_chken)   amtcalt,
             stddec(b.amtincct,b.codempid,global_v_chken)  amtincct,
             stddec(b.amtinclt,b.codempid,global_v_chken)  amtinclt,
             stddec(b.amtgrstxt,b.codempid,global_v_chken) amtgrstxt,
             stddec(b.amtexpct,b.codempid,global_v_chken)  amtexpct,
             stddec(b.amtexplt,b.codempid,global_v_chken)  amtexplt,
             stddec(b.amttaxt,b.codempid,global_v_chken)   amttaxt,
             stddec(b.amtsocat,b.codempid,global_v_chken)  amtsocat,
             b.rowid,b.dteyrepay
        from temploy1 a,ttaxmas b
       where a.codempid = b.codempid
         and a.staemp   = '9'
         and a.dteeffex between v_dtestr and v_dteend
         and b.dteyrepay = p_year
         and b.codcomp like p_codcomp || '%'
    order by b.codcomp,a.codempid;
    cursor c2 is
      select stddec(amtnet,codempid,global_v_chken) amtnet,
             numperiod,dtemthpay,dteyrepay
        from ttaxcur
       where codempid  = v_codempid
         and dteyrepay = p_year
    order by dtemthpay desc,numperiod desc;


  begin
--    v_dtestr := to_date('01/' || to_char(p_month,'00') || to_char(p_year,'0000'),'dd/mm/yyyy') + 1;
--  	v_dteend := last_day(v_dtestr) + 1;
    -- user32: 04/10/2019
  	v_dtestr := to_date('01/' || to_char(p_month,'00') || to_char(p_year,'0000'),'dd/mm/yyyy');
  	v_dteend := last_day(v_dtestr);
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxmas');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        v_codempid := r1.codempid;
        obj_data := json_object_t();
        obj_data.put('codcomp'         ,r1.codcomp);
        obj_data.put('image'           ,get_emp_img(r1.codempid));
        obj_data.put('codempid'        ,r1.codempid);
        obj_data.put('dteyrepay'        ,r1.dteyrepay);
        obj_data.put('desc_codempid'   ,get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dteeffex'        ,to_char(r1.dteeffex,'dd/mm/yyyy'));
        if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          obj_data.put('acc_inc'         ,to_char(nvl(r1.amtcalt  ,0) +
                                                  nvl(r1.amtincct ,0) +
                                                  nvl(r1.amtinclt ,0) +
                                                  nvl(r1.amtgrstxt,0) -
                                                  nvl(r1.amtexpct ,0) -
                                                  nvl(r1.amtexplt ,0) ,
                                                  'fm99999999990.00'));
          obj_data.put('acc_tax'         ,to_char(nvl(r1.amttaxt  ,0),'fm99999999990.00'));
          obj_data.put('acc_ins'         ,to_char(nvl(r1.amtsocat ,0),'fm99999999990.00'));
        end if;
        for r2 in c2 loop
          obj_data.put('last_numperiod'  ,to_char(r2.numperiod) || '/' ||
                                        lpad(r2.dtemthpay,2,'0') || '/' ||
                                        lpad(r2.dteyrepay,4,'0'));
          if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
            obj_data.put('amount'        ,to_char(nvl(r2.amtnet   ,0),'fm99999999990.00'));
          end if;
          exit;
        end loop;
        obj_data.put('coderror'          ,'200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;

    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end hrpy5ix;

/

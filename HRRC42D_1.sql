--------------------------------------------------------
--  DDL for Package Body HRRC42D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC42D" is
-- last update: 04/02/2021 18:20
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := (hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    json_params         := hcm_util.get_json_t(json_obj, 'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  ----------------------------------------------------------------------------------
  procedure check_index is
    v_flgsecu2        boolean := false;
  begin
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
        return;
      end if;
    end if;
  end check_index;
  ----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    v_secur     boolean := false;
    v_data      boolean := false;

    cursor c1 is
      select  t.codempid, t.dteempmt, t.codcomp, t.staemp, t.numlvl,
            (select codrej  
             from  tappfoll b
             where b.numappl = t.numappl 
             and   codrej is not null
             and   dtefoll = (select max(dtefoll) 
                              from  tappfoll c
                              where b.numappl = c.numappl 
                              and   codrej is not null)
             ) as codrej
      from  temploy1 t
      where t.codcomp like p_codcomp||'%'
      and   t.dteempmt between  p_dtestrt and  p_dteend
      and   t.staemp = '0'
      order by t.codempid;
  begin
    obj_row     := json_object_t();
    for r1 in c1 loop
      v_data := true;
      v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');

        obj_data.put('codimage', get_emp_img (r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('dteempmt', to_char(r1.dteempmt, 'dd/mm/yyyy'));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('desc_staemp', get_tlistval_name('NAMSTATA',r1.staemp, global_v_lang));
        obj_data.put('desc_codrej', get_tcodec_name('TCODREJE', r1.codrej, global_v_lang));

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_data and v_rcnt = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_rcnt = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST1');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    json_str_output := obj_row.to_clob;

  end gen_index;
----------------------------------------------------------------------------------
procedure delete_newemp (json_str_input in clob, json_str_output out clob) is
    json_row               json_object_t;
    v_flg               varchar2(100 char);
    v_codempid             varchar2(100 char);

  begin

    initial_value (json_str_input);

    if param_msg_error is null then
      for i in 0..json_params.get_size() - 1 loop
        json_row          := hcm_util.get_json_t(json_params, to_char(i));
        v_flg             := hcm_util.get_string_t(json_row, 'flg');
        v_codempid        := hcm_util.get_string_t(json_row, 'codempid');

           if v_flg = 'delete' then
             begin
            update tapplinf
             set   codempid = ''
             where codempid = v_codempid;

             update tappldoc
             set   codempid = ''
             where codempid = v_codempid;

             update tapplref
             set   codempid = ''
             where codempid = v_codempid;

             update tapplwex
             set   codempid = ''
             where codempid = v_codempid;

             update teducatn
             set   codempid = ''
             where codempid = v_codempid;

             update ttrainbf
             set   codempid = ''
             where codempid = v_codempid;

             update tcmptncy
             set   codempid = ''
             where codempid = v_codempid;

             update tcmptncy2
             set   codempid = ''
             where codempid = v_codempid;

             update tlangabi
             set   codempid = ''
             where codempid = v_codempid;

             delete
             from temploy1
             where codempid = v_codempid
             and   staemp   = '0';
               exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                json_str_output := get_response_message(400, param_msg_error , global_v_lang);
                rollback ;
                return ;
             end;
           end if ;
      end loop;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end delete_newemp;
----------------------------------------------------------------------------------

end HRRC42D;

/

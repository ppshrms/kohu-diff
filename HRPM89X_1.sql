--------------------------------------------------------
--  DDL for Package Body HRPM89X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM89X" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    pa_codempid         := hcm_util.get_string_t(json_obj,'pa_codempid');
    pa_dtestr           := hcm_util.get_string_t(json_obj,'pa_dtestr');
    pa_dteend           := hcm_util.get_string_t(json_obj,'pa_dteend');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure vadidate_variable_getindex(json_str_input in clob) as

   cursor c_resultcodempid is  select codempid
          from temploy1
           where codempid like pa_codempid||'%';
   objectCursorResultcodempid       c_resultcodempid%ROWTYPE;

   secur        boolean;
   v_codcodec     varchar2(4 char);
  BEGIN
        if (pa_codempid is null or pa_codempid = ' ') then
           param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
           return ;
        end if;

        if (pa_dtestr is null or pa_dtestr = ' ') then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;

        if(pa_dteend is null or pa_dteend = ' ') then
           param_msg_error := get_error_msg_php('HR2045',global_v_lang, '');
            return ;
        end if;


        if( pa_dteend <  pa_dtestr) then
           param_msg_error := get_error_msg_php('HR2027',global_v_lang, '');
          return ;
        end if;


         OPEN c_resultcodempid;
            FETCH c_resultcodempid INTO objectCursorResultcodempid ;
            IF (c_resultcodempid%NOTFOUND) THEN
                  param_msg_error := get_error_msg_php('HR2010',global_v_lang, '');
            END IF;
        CLOSE c_resultcodempid;


       secur := secur_main.secur2(pa_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
       if secur = false then
       param_msg_error := get_error_msg_php('HR3007',global_v_lang, '');
        return;
       end if;

  END vadidate_variable_getindex;

  procedure get_index(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
  begin
    initial_value(json_str_input);
    vadidate_variable_getindex(json_str_input);
    if param_msg_error is null then
        gen_index(json_str_output);
    else
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_amtcost       number := 0;
    v_data_exist    boolean := false;

    v_ocodempid   varchar2(400)  := GET_OCODEMPID(pa_codempid);

        cursor c1 is
            select a.numclseq,a.dteyear,a.dtetrst,a.dtetren,a.codsubj,a.destrevl,
                   to_number(to_char(a.dtetrst,'mm')) dtemonth,grade,a.codcours,a.codcompy,qtyscore,
                   a.codinst
              from thisinst a
             where a.dteyear >= pa_dtestr
               and a.dteyear <= pa_dteend
               and a.codinst in (select distinct b.codinst from tinstruc b
             where (codempid = pa_codempid or v_ocodempid like '[%'||codempid||']%'))
          order by a.numclseq, a.dteyear, a.dtetrst;

  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      v_data_exist := true;


     begin
        select amtcost
          into v_amtcost
          from tcosttr
         where dteyear  = r1.dteyear
           and codcompy = r1.codcompy
           and codcours = r1.codcours
           and numclseq = r1.numclseq
           and codexpn  = '0001';
        exception when no_data_found then
            v_amtcost := 0;
     end;

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', to_char(v_rcnt));
      obj_data.put('dteyear', to_char(r1.dteyear));--+HCM_APPSETTINGS.get_additional_year());
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('desc_codcompy', get_tcompny_name(r1.codcompy,global_v_lang));
      obj_data.put('codcours', r1.codcours);
      obj_data.put('desc_codcours', get_tcourse_name(r1.codcours,global_v_lang));
      obj_data.put('numclseq', r1.numclseq);
      obj_data.put('dtemonth', get_nammthful(r1.dtemonth,global_v_lang));
      obj_data.put('dtetrst', to_char(r1.dtetrst,'dd/mm/yyyy'));
      obj_data.put('dtetren', to_char(r1.dtetren,'dd/mm/yyyy'));
      obj_data.put('codsubj', get_tsubject_name(r1.codsubj,global_v_lang));
      obj_data.put('grade', r1.grade );
      obj_data.put('qtyscore', r1.qtyscore );
      obj_data.put('codempid', pa_codempid );
      obj_data.put('desc_codempid', get_temploy_name(pa_codempid,global_v_lang) );

      obj_data.put('codinst', r1.codinst );
      obj_data.put('codsubjc', r1.codsubj);

      if v_amtcost > 0 then
        obj_data.put('amtchginc', TO_CHAR(v_amtcost, '999,999.99'));
      else
        obj_data.put('amtchginc', TO_CHAR(v_amtcost, '0.00'));
      end if;

      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'THISINST');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end HRPM89X;

/

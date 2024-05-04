--------------------------------------------------------
--  DDL for Package Body HRES7OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES7OE" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_registeren        := hcm_util.get_string_t(json_obj,'p_registeren');
    p_registerst        := hcm_util.get_string_t(json_obj,'p_registerst');
    p_latitude          := hcm_util.get_string_t(json_obj,'p_latitude');
    p_longitude         := hcm_util.get_string_t(json_obj,'p_longitude');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
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
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
    v_codhotel      tyrtrsch.codhotel%type;
    v_timstrt       ttrsched.timstrt%type;
    v_timend        ttrsched.timend%type;
    v_latitude      thotelif.latitude%type;
    v_longitude     thotelif.longitude%type;
    v_radius        thotelif.radius%type;

    v_tpotentpd     tpotentpd%rowtype;

	cursor c_tpotentp is
		select *
          from tpotentp 
         where codempid = global_v_codempid
           and trunc(sysdate) between dtetrst and dtetren
           and flgatend = 'N'
      order by codcours, numclseq;
  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c_tpotentp loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();

        begin
            select codhotel
              into v_codhotel
              from tyrtrsch 
             where dteyear = r1.dteyear
               and codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
               and codcours = r1.codcours
               and numclseq = r1.numclseq;        
        exception when no_data_found then
            v_codhotel := null;
        end;

        begin
            select timstrt, timend
              into v_timstrt, v_timend
              from ttrsched
             where dteyear = r1.dteyear
               and codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
               and codcours = r1.codcours
               and numclseq = r1.numclseq
               and dtetrain = trunc(sysdate);        
        exception when no_data_found then
            select timestr, timeend
              into v_timstrt, v_timend
              from tyrtrsch 
             where dteyear = r1.dteyear
               and codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
               and codcours = r1.codcours
               and numclseq = r1.numclseq;            
        end;

        begin
            select latitude, longitude, radius
              into v_latitude, v_longitude, v_radius
              from thotelif
             where codhotel = v_codhotel;
        exception when no_data_found then
            v_latitude      := null;
            v_longitude     := null;
            v_radius        := null;
        end;


        begin 
            select *
              into v_tpotentpd
              from tpotentpd
             where dteyear = r1.dteyear
               and codcompy = r1.codcompy
               and numclseq = r1.numclseq
               and codcours = r1.codcours
               and codempid = global_v_codempid
               and dtetrain = trunc(sysdate);
        exception when no_data_found then
            v_tpotentpd      := null;
        end;

        obj_data.put('coderror', '200');
        obj_data.put('numseq', v_rcnt);
        obj_data.put('codcours', r1.codcours);
        obj_data.put('desc_codcours', get_tcourse_name( r1.codcours, global_v_lang));
        obj_data.put('numclseq', r1.numclseq);
        obj_data.put('dtetrain', to_char(trunc(sysdate),'dd/mm/yyyy'));
        obj_data.put('timstrt', to_char(to_date(v_timstrt,'hh24mi'),'hh24:mi'));
        obj_data.put('timend', to_char(to_date(v_timend,'hh24mi'),'hh24:mi'));
        obj_data.put('codhotel', v_codhotel);
        obj_data.put('desc_codhotel', get_thotelif_name(v_codhotel, global_v_lang));
        obj_data.put('flgcheck', '');
        obj_data.put('latitude', v_latitude);
        obj_data.put('longitude', v_longitude);
        obj_data.put('radius', v_radius);
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('codempid', r1.codempid);
        if (to_number(to_char(sysdate,'hh24mi')) <  1300 and to_date(v_tpotentpd.timin,'hh24mi') is null) or
           (to_number(to_char(sysdate,'hh24mi')) >=  1300 and to_date(v_tpotentpd.timin2,'hh24mi') is null)then
            obj_data.put('flgDisabled',false);
        else 
            obj_data.put('flgDisabled',true);
        end if;

        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
--
  procedure save_checkin(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    v_flg                   varchar2(100 char);

    v_flgcheck              varchar2(10 char);
    v_codcours              tpotentpd.codcours%type;
    v_codhotel              thotelif.codhotel%type;
    v_numclseq              tpotentpd.numclseq%type;
    v_dtetrain              tpotentpd.dtetrain%type;
    v_timstrt               tpotentpd.timin%type;
    v_timend                tpotentpd.timin%type;
    v_dteyear               tpotentp.dteyear%type;
    v_codcompy              tpotentp.codcompy%type;
    v_codempid              tpotentp.codempid%type;
    v_timin                 tpotentpd.timin%type;
    v_timin2                tpotentpd.timin2%type;
    v_qtytrabs              tpotentpd.qtytrabs%type;
    p_radius              number  := 6387.7;
    p_deg_to_rad          number  := 57.29577951;
    p_km                  number  := 1000;
  begin
    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_flgcheck          := hcm_util.get_string_t(param_json_row,'flgcheck');
        v_dteyear           := hcm_util.get_string_t(param_json_row,'dteyear');
        v_codcompy          := hcm_util.get_string_t(param_json_row,'codcompy');
        v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
        v_codcours          := hcm_util.get_string_t(param_json_row,'codcours');
        v_codhotel          := hcm_util.get_string_t(param_json_row,'codhotel');
        v_numclseq          := hcm_util.get_string_t(param_json_row,'numclseq');
        v_dtetrain          := to_date(hcm_util.get_string_t(param_json_row,'dtetrain'),'dd/mm/yyyy');
        v_timstrt           := to_char(to_date(hcm_util.get_string_t(param_json_row,'timstrt'),'hh24:mi'),'hh24mi');
        v_timend            := to_char(to_date(hcm_util.get_string_t(param_json_row,'timend'),'hh24:mi'),'hh24mi');
        if v_flgcheck = 'Y' then
            begin
                select codhotel
                  into v_codhotel
                  from thotelif
                 where codhotel = v_codhotel
                   and (trunc(2 * p_radius * asin(sqrt(power((sin(((p_latitude - latitude)/p_deg_to_rad)/2)), 2) +
                       cos(latitude/p_deg_to_rad) * cos(p_latitude/p_deg_to_rad) *
                       power((sin(((p_longitude - longitude)/p_deg_to_rad) / 2)),2))) * p_km)
                       <= nvl(radius,0));
            exception when no_data_found then
                param_msg_error := get_error_msg_php('ES0058',global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end;

            begin
                insert into tpotentpd (dteyear,codcompy,numclseq,
                                       codcours,codempid,dtetrain,
                                       dtecreate,codcreate,dteupd,coduser)
                values (v_dteyear,v_codcompy,v_numclseq,
                        v_codcours,p_codempid_query,v_dtetrain,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);            
            exception when dup_val_on_index then
                null;
            end;

            select timin, timin2
              into v_timin, v_timin2
              from tpotentpd
             where dteyear = v_dteyear
               and codcompy = v_codcompy
               and numclseq = v_numclseq
               and codcours = v_codcours
               and codempid = p_codempid_query
               and dtetrain = v_dtetrain;

            if p_registerst = 'Y' then
                v_timin     := to_char(sysdate,'hh24mi');
            end if;

            if p_registeren = 'Y' then
                v_timin2    := to_char(sysdate,'hh24mi');
            end if;

            if to_number(v_timstrt) <  1300 and v_timin is null then
                v_qtytrabs := 4;
            end if;

            update tpotentpd
               set dtetrain = v_dtetrain,
                   flgatend = 'Y',
                   timin = v_timin,
                   timin2 = v_timin2,
                   qtytrabs = v_qtytrabs
             where dteyear = v_dteyear
               and codcompy = v_codcompy
               and numclseq = v_numclseq
               and codcours = v_codcours
               and codempid = p_codempid_query
               and dtetrain = v_dtetrain;
        end if;
      end loop;
    end if;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_checkin;
  --
  procedure post_save_checkin(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_checkin(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  


end;

/

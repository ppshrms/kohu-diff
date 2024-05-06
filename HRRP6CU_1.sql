--------------------------------------------------------
--  DDL for Package Body HRRP6CU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP6CU" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_year        := hcm_util.get_string_t(json_obj,'p_year');

    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');

    params_json         := hcm_util.get_json_t(json_obj,'params');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if b_index_codcomp is null or b_index_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    begin
      select codcomp into v_codcomp
      from tcenter
      where codcomp = get_compful(b_index_codcomp);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
      return;
    end;
    if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
  end;

  procedure gen_index(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data_detail json_object_t;
    obj_row_output  json_object_t;
    v_rcnt          number := 0;
    v_flgAppr       boolean;
    v_flgData       boolean := false;

    v_namgroupt     tninebox.namgroupt%type;
    v_approvno      number := 0;
    p_check         varchar2(10 char);
    v_dteeffec      date;


    cursor c1 is
      select *
        from tnineboxe
       where codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
         and dteyear = b_index_year
         and staappr in ('P','A')
       order by codempid;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_flgData   := true;
      v_approvno  := nvl(r1.approvno,0) + 1;
      v_flgAppr   := chk_flowmail.check_approve('HRRP6AB',r1.codempid,v_approvno,global_v_codempid,'','',p_check);
      if v_flgAppr then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('numseq', v_rcnt);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp, global_v_lang));
        obj_data.put('jobgrade', r1.codgroup);
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('staappr', r1.staappr);
        obj_data.put('desc_staappr',GET_TLISTVAL_NAME('STAAPPR',r1.staappr,global_v_lang));
        obj_data.put('approvno', v_approvno);
        obj_data.put('remarkap', r1.remarkap);     --19/10/2021

        v_dteeffec  :=  to_date('31/12'||b_index_year,'dd/mm/yyyy');
        begin
          select namgroupt into v_namgroupt
          from tninebox
          where codcompy = r1.codcompy
          and codgroup = r1.codgroup
          and dteeffec = (select max(dteeffec)
                            from tninebox
                           where codcompy = r1.codcompy
                             and dteeffec <= v_dteeffec);
        exception when no_data_found then
          v_namgroupt :=  '';
        end;
        obj_data.put('codgroup', r1.codgroup);
        obj_data.put('desc_codgroup', v_namgroupt);
        obj_data.put('dtechoose', to_char(r1.dtechoose,'dd/mm/yyyy'));
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgData then
      if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TNINEBOXE');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
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
  procedure gen_drilldown(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgsecu       boolean;

    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_year          number;
    v_month         number;
    v_day           number;
    v_amount        number := 0;
    v_dteeffec      date;
    v_amountemp   varchar2(100 char);
    v_percntemp   varchar2(100 char);
    cursor c1 is
      select a.codgroup,a.namgroupt,a.descgroup,a.syncond,a.codcompy
        from tninebox a
        where b_index_codcomp like codcompy||'%'
        and dteeffec = (select max(dteeffec)
                        from tninebox
                        where codcompy = a.codcompy
                        and dteeffec <= v_dteeffec)
        order by codgroup;
  begin
    v_dteeffec  :=  to_date('31/12'||b_index_year,'dd/mm/yyyy');
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('boxno', v_rcnt);
      obj_data.put('codgroup', r1.codgroup);
      obj_data.put('namgroupt', r1.namgroupt);
      obj_data.put('desc_codgroup', r1.descgroup);

      get_data_box(b_index_year, r1.codcompy, r1.codgroup, v_amountemp, v_percntemp);
      obj_data.put('qtyemp', v_amountemp);
      obj_data.put('perqty', v_percntemp);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_rcnt <> 0 then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TNINEBOXE');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := 'b_index_year' || dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_drilldown(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    gen_drilldown(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_data_box(v_year in varchar2, v_codcompy in tninebox.codcompy%type, v_codgroup in tninebox.codgroup%type,
                         v_amountemp out varchar,
                         v_percntemp out varchar) as
    v_empall number := 0;
  begin
    begin
      select count(codempid)
        into v_amountemp
        from tnineboxe
       where codcompy = v_codcompy
         and dteyear = v_year
         and codgroup = v_codgroup
         and staappr = 'Y'
         and exists (select codcomp
                       from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%');
    exception when no_data_found then
      v_amountemp := 0;
    end;
    begin
      select count(codempid)
        into v_empall
        from tnineboxe
       where codcompy = v_codcompy
         and dteyear = v_year
         and staappr = 'Y'
         and exists (select codcomp
                       from tusrcom a
                      where a.coduser = global_v_coduser
                        and codcomp like a.codcomp||'%');
    exception when no_data_found then
      v_empall := 0;
    end;
    -- calculate percent
--    (5/200)*100 = 2.5%
    if v_empall > 0 then
      v_percntemp := to_char((v_amountemp/v_empall) * 100, 'fm990.90');
    else
      v_percntemp := 0;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  procedure save_index(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
    obj_syncond       json_object_t;
    param_json_row    json_object_t;
    param_object      json_object_t;

    v_flg             varchar2(10 char);
    r_tnineboxe       tnineboxe%rowtype;
    v_codempid     		tnineboxe.codempid%type;
    v_codgroup     		tnineboxe.codgroup%type;
    v_codgroupOld     tnineboxe.codgroup%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then

      for i in 0..params_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(params_json,to_char(i));
        v_flg     		  := hcm_util.get_string_t(param_json_row, 'flg');
        v_codempid     		  := hcm_util.get_string_t(param_json_row, 'codempid');
        v_codgroup     		  := hcm_util.get_string_t(param_json_row, 'codgroup');
        v_codgroupOld     		  := hcm_util.get_string_t(param_json_row, 'codgroupOld');
        begin
          select * into r_tnineboxe
          from tnineboxe
          where DTEYEAR = b_index_year
          and CODCOMPY = hcm_util.get_codcomp_level(b_index_codcomp, 1)
          and CODGROUP = v_codgroupOld
          and CODEMPID = v_codempid;
        exception when no_data_found then
          r_tnineboxe :=  null;
        end;
        if v_flg = 'edit' then
          begin
            update tnineboxe
               set codgroup = v_codgroup
             where dteyear  = b_index_year
               and codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
               and codgroup = v_codgroupold
               and codempid = v_codempid;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj            json_object_t;
    obj_data            json_object_t;
    param_json_row      json_object_t;

    v_codempid	        tapnineboxe.codempid%type;
    v_codgroup	        tapnineboxe.codgroup%type;
    v_codgroupOld	    tapnineboxe.codgroup%type;
    v_codcomp	        tnineboxe.codcomp%type;
    v_codpos	        tnineboxe.codpos%type;
    v_dtechoose	        tnineboxe.dtechoose%type;
    v_staappr	        tapnineboxe.staappr%type;
    v_approvno	        tapnineboxe.approvno%type;
    v_dteeffec	        tnineboxe.dteeffec%type;
    v_flgStaappr	    varchar2(10 char);
    v_remark	        varchar2(1000 char);
    v_flgAppr           boolean;
    p_check             varchar2(10 char);
    v_error_sendmail    varchar2(4000 char):= '9999';
    v_error			    varchar2(4000);
    v_error_cc          varchar2(4000);
	v_rowid             ROWID;

  begin
    initial_value(json_str_input);
    for i in 0..params_json.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(params_json,to_char(i));
      v_codempid		:= hcm_util.get_string_t(param_json_row,'codempid');
      v_codgroup		:= hcm_util.get_string_t(param_json_row,'codgroup');
      v_codgroupOld     := hcm_util.get_string_t(param_json_row,'codgroupOld');
      v_codcomp		    := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos		    := hcm_util.get_string_t(param_json_row,'codpos');
      v_dtechoose		:= to_date(hcm_util.get_string_t(param_json_row,'dtechoose'),'dd/mm/yyyy');
      v_staappr		    := hcm_util.get_string_t(param_json_row,'staappr');
      v_approvno		:= hcm_util.get_string_t(param_json_row,'approvno');
      v_dteeffec		:= to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_flgStaappr	    := hcm_util.get_string_t(param_json_row,'flgStaappr');

      if v_flgStaappr = 'A' then
            v_remark := p_remark;
      elsif v_flgStaappr = 'N' then
            v_remark := p_remark;
      end if;

      v_remark      := replace(v_remark,'.',chr(13));
      v_remark      := replace(replace(v_remark,'^$','&'),'^@','#');
      v_codcomp     :=  hcm_util.get_codcomp_level(b_index_codcomp, 1);
      v_flgAppr     := chk_flowmail.check_approve('HRRP6AB',v_codempid,v_approvno,p_codappr,'','',p_check);

      if v_flgStaappr = 'N' then
        begin
          insert into tapnineboxe (dteyear,codcompy,codgroup,codempid,approvno,dteappr,codappr,staappr,remarkap,dtecreate,codcreate,coduser)
               values (b_index_year, v_codcomp, v_codgroup, v_codempid, v_approvno, p_dteappr, p_codappr,'N',v_remark,p_dteappr, global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          null;
        end;
        begin
          update tnineboxe
             set codgroup = v_codgroup,
                 staappr = 'N',
                 dteappr = p_dteappr,
                 codappr = p_codappr,
                 remarkap = v_remark,
                 dteeffec = null,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where dteyear  = b_index_year
             and codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
             and codgroup = v_codgroupold
             and codempid = v_codempid;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      elsif v_flgStaappr = 'A' then
        if p_check = 'N' then
          begin
            insert into tapnineboxe (dteyear,codcompy,codgroup,codempid,approvno,dteappr,codappr,staappr,remarkap,dtecreate,codcreate,coduser)
                 values (b_index_year, v_codcomp, v_codgroup, v_codempid, v_approvno, p_dteappr, p_codappr,'Y',v_remark,p_dteappr, global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            update tnineboxe
               set codgroup = v_codgroup,
                   staappr = 'A',
                   approvno = v_approvno,
                   dteappr = p_dteappr,
                   codappr = p_codappr,
                   remarkap = v_remark,
                   dteeffec = null,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where dteyear  = b_index_year
               and codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
               and codgroup = v_codgroupold
               and codempid = v_codempid;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
--          insert_ttemprpt(global_v_coduser,'HRRP6CU'||'REPLY', v_codempid,  null ,null,null,null);
        elsif p_check = 'Y' then
          begin
            insert into tapnineboxe (dteyear,codcompy,codgroup,codempid,approvno,dteappr,codappr,staappr,remarkap,dtecreate,codcreate,coduser)
                 values (b_index_year, v_codcomp, v_codgroup, v_codempid, v_approvno, p_dteappr, p_codappr,'Y',v_remark,p_dteappr, global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            update tnineboxe
               set codgroup = v_codgroup,
                   staappr = 'Y',
                   approvno = v_approvno,
                   dteappr = p_dteappr,
                   codappr = p_codappr,
                   remarkap = v_remark,
                   dteeffec = p_dteeffec,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where dteyear  = b_index_year
               and codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
               and codgroup = v_codgroupold
               and codempid = v_codempid;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end;
        end if;
      end if;
      begin--<<user25 Date:19/10/2021 #7128
        select rowid
          into v_rowid
          from tnineboxe
         where dteyear  = b_index_year
           and codcompy = hcm_util.get_codcomp_level(b_index_codcomp, 1)
           and codgroup = v_codgroupold
           and codempid = v_codempid;
           exception when no_data_found then v_rowid := null; --<<user25 Date:19/10/2021 #7128
       end;--<<user25 Date:19/10/2021 #7128
      begin
        if v_flgStaappr = 'N' then
            v_error_cc := chk_flowmail.send_mail_reply('HRRP6CU', v_codempid, null , global_v_codempid, global_v_coduser, null, 'HRRP6CU3', 70, 'U', 'N', v_approvno, null, null, 'TNINEBOXE', v_rowid, '1', null);
        else
            v_error_cc := chk_flowmail.send_mail_reply('HRRP6CU', v_codempid, null , global_v_codempid, global_v_coduser, null, 'HRRP6CU3', 70, 'U', 'Y', v_approvno, null, null, 'TNINEBOXE', v_rowid, '1', null);
        end if;
      EXCEPTION WHEN OTHERS THEN
          v_error_sendmail := '2403';
      END;

       if v_flgAppr AND p_check = 'N' AND v_flgStaappr <> 'N' then
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRRP6AB', v_codempid, global_v_codempid, global_v_coduser, null, 'HRRP6CU3', 70, 'E', 'P', v_approvno, null, null,'TAPNINEBOXE',v_rowid, '1', null);
            EXCEPTION WHEN OTHERS THEN
                v_error_sendmail := '2403';
            END;
        else
            v_error:= '2402';
        end if;

        IF v_error in ('2046','2402') THEN
            null;
        ELSE
            v_error_sendmail := '2403';
        END IF;
    end loop;
    if param_msg_error is null then
        IF v_error_sendmail <> '2403' THEN
            param_msg_error := get_error_msg_php('HR2402', global_v_lang);
            json_str_output := get_response_message(201,param_msg_error,global_v_lang);
        ELSE
            param_msg_error := get_error_msg_php('HR2403', global_v_lang);
            json_str_output := get_response_message(201,param_msg_error,global_v_lang);
        END IF;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrrp6cu;

/

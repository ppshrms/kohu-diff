--------------------------------------------------------
--  DDL for Package Body HRBF26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF26E" as
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year              := hcm_util.get_string_t(json_obj,'p_dteyear');

    p_numvcher          := hcm_util.get_string_t(json_obj,'p_numvcher');
    p_codrel            := hcm_util.get_string_t(json_obj,'p_codrel');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_dtecrest          := to_date(hcm_util.get_string_t(json_obj,'p_dtecrest'),'dd/mm/yyyy');
    p_typamt            := hcm_util.get_string_t(json_obj,'p_typamt');
    p_typrel            := hcm_util.get_string_t(json_obj,'p_typrel');
    p_amtexp            := nvl(hcm_util.get_string_t(json_obj,'p_amtexp'),0);

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
  begin
    if p_codcomp is not null then
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_codempid is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(p_codempid, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
    end if;
  end;
  procedure gen_index_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_approvno      number := 0;
    v_crrntApprno   number := 0;
    v_flgSecur      boolean;
    v_flgExist      boolean := false;
    p_check         varchar2(10 char);

    v_amount        number := 0;
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_dtebfst       date;
    v_dtebfen       date;

    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;

    v_amtavai       number;
    v_amtalw        number;
    v_amtovrpay     number;

    cursor c1 is
      select *
        from taccmexp
       where dteyre = p_year
         and codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid,codempid)
         and dtemonth = 13
       order by codempid,typamt,typrelate;
  begin
    /*User37 #4066 5. BF Module 21/04/2021 begin
      select daybfst,mthbfst into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
          and dteeffec = (select max(dteeffec)
                                  from TCONTRBF
                                where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                   and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;

    v_dtebfst := to_date(v_daybfst||'/'||v_mthbfst||'/'||p_year,'dd/mm/yyyy');
    v_dtebfen := add_months(v_dtebfst,12) - 1;*/

    obj_row := json_object_t();
    obj_data := json_object_t();

    for r1 in c1 loop
      v_flgSecur := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgSecur then

        v_rcnt := v_rcnt + 1;
        obj_data.put('codempid', r1.codempid);
        obj_data.put('typamt', r1.typamt);
        obj_data.put('typrelate', r1.typrelate);
        obj_data.put('amtwidrwt', r1.amtwidrwt);
        obj_data.put('amtsumin', r1.amtsumin);
        obj_data.put('qtysumin', r1.qtysumin);
        obj_data.put('dteulast', to_char(r1.dteulast,'dd/mm/yyyy'));
        obj_data.put('dteupd',to_char(r1.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser', r1.coduser);
        obj_data.put('desc_coduser', get_temploy_name(get_codempid(r1.coduser),global_v_lang));

        --<<User37 #4066 5. BF Module 21/04/2021 
        begin
          select daybfst,mthbfst into v_daybfst, v_mthbfst
            from tcontrbf
           where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
              and dteeffec = (select max(dteeffec)
                                      from TCONTRBF
                                    where codcompy = hcm_util.get_codcomp_level(r1.codcomp, 1)
                                       and dteeffec <= sysdate);
        exception when no_data_found then
          v_daybfst := 1; v_mthbfst := 1;
        end;

        v_dtebfst := to_date(v_daybfst||'/'||v_mthbfst||'/'||p_year,'dd/mm/yyyy');
        v_dtebfen := add_months(v_dtebfst,12) - 1;
        -->>User37 #4066 5. BF Module 21/04/2021 

        std_bf.get_medlimit(r1.codempid, v_dtebfst, v_dtebfen, '', r1.typamt, r1.typrelate,
                            v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);

        obj_data.put('amtavai', v_amtwidrwy - r1.amtsumin);--User37 #4071 BF - PeoplePlus 05/04/2021  obj_data.put('amtavai', v_amtbal);
        obj_data.put('dtebfst', to_char(v_dtebfst,'dd/mm/yyyy'));
        obj_data.put('dtebfend', to_char(v_dtebfen,'dd/mm/yyyy'));
        obj_data.put('o_amtwidrwy', v_amtwidrwy);
        obj_data.put('o_qtywidrwy', v_qtywidrwy);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
--
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index_header(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_dtebfst       date;
    v_dtebfen       date;
    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;

    v_amtavai       number;
    v_amtalw        number;
    v_amtovrpay     number;
    v_codcomp       temploy1.codcomp%type;--User37 #4066 BF - PeoplePlus 02/04/2021
  begin
    --<<User37 #4066 BF - PeoplePlus 02/04/2021
    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
    exception when no_data_found then
        v_codcomp := null;
    end;
    -->>User37 #4066 BF - PeoplePlus 02/04/2021
    begin
      select daybfst,mthbfst into v_daybfst, v_mthbfst
        from tcontrbf
       where codcompy = hcm_util.get_codcomp_level(nvl(p_codcomp,v_codcomp), 1)--User37 #4066 BF - PeoplePlus 02/04/2021 hcm_util.get_codcomp_level(p_codcomp, 1)
          and dteeffec = (select max(dteeffec)
                                  from TCONTRBF
                                where codcompy = hcm_util.get_codcomp_level(nvl(p_codcomp,v_codcomp), 1)--User37 #4066 BF - PeoplePlus 02/04/2021 codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                                   and dteeffec <= sysdate);
    exception when no_data_found then
      v_daybfst := 1; v_mthbfst := 1;
    end;
    v_dtebfst := to_date(v_daybfst||'/'||v_mthbfst||'/'||p_year,'dd/mm/yyyy');
    v_dtebfen := add_months(v_dtebfst,12) - 1;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteyear', p_year);
    obj_data.put('codcomp', p_codcomp);
    obj_data.put('codempid', p_codempid);
    obj_data.put('dtebfst', to_char(v_dtebfst,'dd/mm/yyyy'));
    obj_data.put('dtebfend', to_char(v_dtebfen,'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_header(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_header(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_amount(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_amount        number := 0;

    v_namsick       tclnsinf.namsick%type;
    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;

    v_amtavai       number;
    v_amtalw        number;
    v_amtovrpay     number;
  begin

    std_bf.get_medlimit(p_codempid, p_dtereq, p_dtecrest, p_numvcher, p_typamt, p_typrel,
                        v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('o_amtwidrwy', v_amtwidrwy);
    obj_data.put('o_qtywidrwy', v_qtywidrwy);
    obj_data.put('o_amtwidrwt', v_amtwidrwt);
    obj_data.put('o_amtacc', v_amtacc);
    obj_data.put('o_amtacc_typ', v_amtacc_typ);
    obj_data.put('o_qtyacc', v_qtyacc);
    obj_data.put('o_qtyacc_typ', v_qtyacc_typ);
    obj_data.put('o_amtbal', v_amtbal);

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_amount(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_amount(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    param_index         json_object_t;

    v_flg	      varchar2(1000 char);
    v_codempid	varchar2(1000 char);
    v_codcomp	  varchar2(1000 char);
    v_typamt	  varchar2(1000 char);
    v_typrelate	varchar2(1000 char);
    --User37 #4069 BF - PeoplePlus 05/04/2021 v_amtwidrwt	varchar2(1000 char);
    v_amtsumin	varchar2(1000 char);
    v_amtsuminOld	varchar2(1000 char);
    v_qtysumin	varchar2(1000 char);
    v_qtysuminOld	varchar2(1000 char);
    v_amtavai	  varchar2(1000 char);
    v_dteulast	date;
    v_dteulastOld	date;
    v_dteupd	      varchar2(1000 char);
    v_desc_coduser	varchar2(1000 char);
    v_dtebfst	      varchar2(1000 char);
    v_dtebfend	    varchar2(1000 char);
    v_o_amtwidrwy	  varchar2(1000 char);
    v_o_qtywidrwy	  varchar2(1000 char);

    v_dteyre	  varchar2(1000 char);
    --<<User37 #4069 BF - PeoplePlus 05/04/2021
    v_daybfst       tcontrbf.daybfst%type;
    v_mthbfst       tcontrbf.mthbfst%type;
    v_amtwidrwy     number;
    v_qtywidrwy     number;
    v_amtwidrwt     number;
    v_amtacc        number;
    v_amtacc_typ    number;
    v_qtyacc        number;
    v_qtyacc_typ    number;
    v_amtbal        number;
    v_dtebfen       date;
    -->>User37 #4069 BF - PeoplePlus 05/04/2021
  begin
    initial_value(json_str_input);
    param_json  := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_index := hcm_util.get_json_t(json_object_t(json_str_input),'indexHead');
    v_dteyre := hcm_util.get_string_t(param_index,'dteyear');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      v_flg         := hcm_util.get_string_t(param_json_row,'flg');
      v_codempid		:= hcm_util.get_string_t(param_json_row,'codempid');
      v_typamt		  := hcm_util.get_string_t(param_json_row,'typamt');
      v_typrelate		:= hcm_util.get_string_t(param_json_row,'typrelate');
      --User37 #4069 BF - PeoplePlus 05/04/2021 hcm_util.get_string_t(param_json_row,'amtwidrwt');
      v_amtsumin		:= hcm_util.get_string_t(param_json_row,'amtsumin');
      v_qtysumin		:= hcm_util.get_string_t(param_json_row,'qtysumin');
      v_dteulast		:= to_date(hcm_util.get_string_t(param_json_row,'dteulast'),'dd/mm/yyyy');
      v_amtsuminOld		:= hcm_util.get_string_t(param_json_row,'amtsuminOld');
      v_qtysuminOld		:= hcm_util.get_string_t(param_json_row,'qtysuminOld');
      v_dteulastOld		:= to_date(hcm_util.get_string_t(param_json_row,'dteulastOld'),'dd/mm/yyyy');

      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = v_codempid;
      end;

      --<<User37 #4069 BF - PeoplePlus 05/04/2021
      begin
        select daybfst,mthbfst into v_daybfst, v_mthbfst
          from tcontrbf
         where codcompy = hcm_util.get_codcomp_level(nvl(p_codcomp,v_codcomp), 1)--User37 #4066 BF - PeoplePlus 02/04/2021 hcm_util.get_codcomp_level(p_codcomp, 1)
           and dteeffec = (select max(dteeffec)
                             from TCONTRBF
                            where codcompy = hcm_util.get_codcomp_level(nvl(p_codcomp,v_codcomp), 1)--User37 #4066 BF - PeoplePlus 02/04/2021 codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                              and dteeffec <= sysdate);
      exception when no_data_found then
        v_daybfst := 1; v_mthbfst := 1;
      end;
      v_dtebfst := to_date(v_daybfst||'/'||v_mthbfst||'/'||v_dteyre,'dd/mm/yyyy');
      v_dtebfen := add_months(v_dtebfst,12) - 1;
      std_bf.get_medlimit(v_codempid, v_dtebfst, v_dtebfst, '', v_typamt, v_typrelate,
                            v_amtwidrwt, v_qtywidrwy, v_amtwidrwy, v_amtacc, v_amtacc_typ, v_qtyacc, v_qtyacc_typ, v_amtbal);
      -->>User37 #4069 BF - PeoplePlus 05/04/2021

      if v_flg = 'add' then
        begin
          insert into taccmexp (codempid,dteyre,dtemonth,typamt,typrelate,
                                codcomp,amtsumin,qtysumin,amtwidrwt,dteulast,
                                dtecreate , codcreate , coduser)
              values (v_codempid, v_dteyre, 13, v_typamt, v_typrelate,
                      v_codcomp, v_amtsumin, v_qtysumin, v_amtwidrwt, v_dteulast,
                      sysdate, global_v_coduser, global_v_coduser );
        exception when dup_val_on_index then
          update taccmexp
             set amtsumin = v_amtsumin,
                 qtysumin = v_qtysumin,
                 amtwidrwt = v_amtwidrwt,
                 dteulast = v_dteulast,
                 dteupd = sysdate
           where codempid = v_codempid
             and dteyre = v_dteyre
             and dtemonth = 13
             and typamt = v_typamt
             and typrelate = v_typrelate;
        end;
      elsif v_flg = 'edit' then
          update taccmexp
             set amtsumin = v_amtsumin,
                 qtysumin = v_qtysumin,
                 amtwidrwt = v_amtwidrwt,
                 dteulast = v_dteulast,
                 dteupd = sysdate
           where codempid = v_codempid
             and dteyre = v_dteyre
             and dtemonth = 13
             and typamt = v_typamt
             and typrelate = v_typrelate;
             insert_log('amtsumin',v_amtsuminOld,v_amtsumin,v_codempid,v_dteyre,v_typamt,v_typrelate);
             insert_log('qtysumin',v_qtysuminOld,v_qtysumin,v_codempid,v_dteyre,v_typamt,v_typrelate);
             --<<User37 #4073 BF - PeoplePlus 02/04/2021
             --insert_log('dteulast',v_dteulastOld,v_dteulast,v_codempid,v_dteyre,v_typamt,v_typrelate);
             insert_log('dteulast',to_char(v_dteulastOld,'dd/mm/yyyy'),to_char(v_dteulast,'dd/mm/yyyy'),v_codempid,v_dteyre,v_typamt,v_typrelate);
             -->>User37 #4073 BF - PeoplePlus 02/04/2021
      elsif v_flg = 'delete' then
          delete taccmexp
           where codempid = v_codempid
             and dteyre = v_dteyre
             and dtemonth = 13
             and typamt = v_typamt
             and typrelate = v_typrelate;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure insert_log(v_fldedit in varchar2, v_desold in varchar2, v_desnew in varchar2,
                       v_codempid in varchar2,v_dteyre in varchar2,v_typamt in varchar2, v_typrelate  in varchar2) is
  begin
    null;
    if v_desold <> v_desnew then
      begin
         insert into taccmlog(codempid,dteyre,dtemonth,typamt,typrelate,
                             dteedit,fldedit,desold,desnew,
                             dtecreate,codcreate,coduser)
                      values(v_codempid,v_dteyre,13,v_typamt,v_typrelate,
                             sysdate,upper(v_fldedit), v_desold, v_desnew,
                             sysdate, global_v_coduser, global_v_coduser);
      end;
    end if;
  end;
end hrbf26e;

/

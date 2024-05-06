--------------------------------------------------------
--  DDL for Package Body HRCO05E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO05E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_comlevel          := hcm_util.get_string_t(json_obj,'p_comlevel');
    p_copy              := hcm_util.get_string_t(json_obj,'p_copy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  function get_qtycode(p_numseq   number) return number is
    v_qtycode   tsetcomp.qtycode%type;
  begin
    begin
      select qtycode
        into v_qtycode
        from tsetcomp
       where numseq   = p_numseq;
    exception when no_data_found then null;
    end;
    return v_qtycode;
  end;
  --
  procedure check_index is
    v_error   varchar2(1000 char);
  begin
    if p_codcompy is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_comlevel is not null then
      begin
        select 'Y'
          into v_error
          from tsetcomp
         where numseq   = p_comlevel;
      exception when no_data_found then
        param_msg_error   := get_error_msg_php('HR2010', global_v_lang, 'tsetcomp');
      end;
    else
      param_msg_error   := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure gen_dropdown_comlevel(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number  := 0;
    cursor c1 is
      select numseq
        from tsetcomp
       where numseq   > 1
      order by numseq;
  begin
    obj_row   := json_object_t();
    for i in c1 loop
      obj_data  := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('key',i.numseq);
      obj_data.put('value',i.numseq);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_dropdown_comlevel(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dropdown_comlevel(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_data        json_object_t;
    v_codcompy      tcompnyc.codcompy%type;
    v_comlevel      tcompnyc.comlevel%type;
    v_namcent       tcompnyc.namcente%type;
    v_namcente      tcompnyc.namcente%type;
    v_namcentt      tcompnyc.namcentt%type;
    v_namcent3      tcompnyc.namcent3%type;
    v_namcent4      tcompnyc.namcent4%type;
    v_namcent5      tcompnyc.namcent5%type;
    v_qtycode       tsetcomp.qtycode%type;
  begin
    begin
      select cc.codcompy,cc.comlevel,cc.namcente,cc.namcentt,cc.namcent3,cc.namcent4,cc.namcent5,
             decode(global_v_lang, '101', cc.namcente
                                 , '102', cc.namcentt
                                 , '103', cc.namcent3
                                 , '104', cc.namcent4
                                 , '105', cc.namcent5
                                 , cc.namcente)
        into v_codcompy,v_comlevel,v_namcente,v_namcentt,v_namcent3,v_namcent4,v_namcent5,
             v_namcent
        from tcompnyc cc
       where cc.codcompy  = p_codcompy
         and cc.comlevel  = p_comlevel;
    exception when no_data_found then
      null;
    end;

    v_qtycode   := get_qtycode(p_comlevel);

    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codcompy',v_codcompy);
    obj_data.put('comlevel',v_comlevel);
    obj_data.put('namcent',v_namcent);
    obj_data.put('namcente',v_namcente);
    obj_data.put('namcentt',v_namcentt);
    obj_data.put('namcent3',v_namcent3);
    obj_data.put('namcent4',v_namcent4);
    obj_data.put('namcent5',v_namcent5);
    obj_data.put('qtycode',v_qtycode);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_table(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number  := 0;
    v_qtycode       tsetcomp.qtycode%type;
    cursor c1 is
      select codcompy,comlevel,codcomp,
             namcompe,namcompt,namcomp3,namcomp4,namcomp5,
             decode(global_v_lang, '101', namcompe
                                 , '102', namcompt
                                 , '103', namcomp3
                                 , '104', namcomp4
                                 , '105', namcomp5
                                 , namcompt) as namcomp,
             dteupd,coduser,flgact
        from tcompnyd
       where codcompy   = p_codcompy
         and comlevel   = p_comlevel
         order by codcomp;
  begin
    obj_row    := json_object_t();
    v_qtycode  := get_qtycode(p_comlevel);
    for r1 in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codcompy',r1.codcompy);
      obj_data.put('comlevel',r1.comlevel);
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('namcomp',r1.namcomp);
      obj_data.put('namcompe',r1.namcompe);
      obj_data.put('namcompt',r1.namcompt);
      obj_data.put('namcomp3',r1.namcomp3);
      obj_data.put('namcomp4',r1.namcomp4);
      obj_data.put('namcomp5',r1.namcomp5);
      obj_data.put('qtycode',v_qtycode);
      obj_data.put('flgact',r1.flgact);
      if p_copy = 'Y' then
        obj_data.put('flgAdd',true);
      else
        obj_data.put('dteupd',to_char(r1.dteupd,'dd/mm/yyyy hh24:mi'));
        obj_data.put('coduser',get_temploy_name(get_codempid(r1.coduser),global_v_lang));
      end if;
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt    := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_comlevel_copy(json_str_input in clob,json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_rcnt        number  := 0;
    v_qtycode     tsetcomp.qtycode%type;
    v_secur       boolean := false;
    cursor c1 is
      select codcompy,comlevel
        from tsetcomp sc, tcompnyc cc
       where sc.numseq     = cc.comlevel
         and cc.codcompy   <> p_codcompy
         and sc.qtycode    = v_qtycode;
  begin
    initial_value(json_str_input);
    v_qtycode   := get_qtycode(p_comlevel);

    obj_row     := json_object_t();
    for r1 in c1 loop
      v_secur   := secur_main.secur7(r1.codcompy,global_v_coduser);
      if v_secur then
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcompy',r1.codcompy);
        obj_data.put('desc_codcompy',get_tcompny_name(r1.codcompy,global_v_lang));
        obj_data.put('comlevel',r1.comlevel);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
      end if;
    end loop;
    json_str_output   := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_tcompnyc(t_tcompnyc tcompnyc%rowtype) is
  begin
    begin
      insert into tcompnyc (codcompy,comlevel,
                            namcente,namcentt,namcent3,namcent4,namcent5,
                            codcreate,coduser)
      values (t_tcompnyc.codcompy,t_tcompnyc.comlevel,
              t_tcompnyc.namcente,t_tcompnyc.namcentt,t_tcompnyc.namcent3,t_tcompnyc.namcent4,t_tcompnyc.namcent5,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update tcompnyc
         set namcente   = t_tcompnyc.namcente,
             namcentt   = t_tcompnyc.namcentt,
             namcent3   = t_tcompnyc.namcent3,
             namcent4   = t_tcompnyc.namcent4,
             namcent5   = t_tcompnyc.namcent5,
             coduser    = global_v_coduser
       where codcompy   = t_tcompnyc.codcompy
         and comlevel   = t_tcompnyc.comlevel;
    end;
  end;
  --
  procedure insert_tcompnyd(t_tcompnyd tcompnyd%rowtype) is
  begin
    begin
      insert into tcompnyd (codcompy,comlevel,codcomp,
                            namcompe,namcompt,namcomp3,namcomp4,namcomp5,
                            codcreate,coduser,flgact)
      values (t_tcompnyd.codcompy,t_tcompnyd.comlevel,t_tcompnyd.codcomp,
              t_tcompnyd.namcompe,t_tcompnyd.namcompt,t_tcompnyd.namcomp3,t_tcompnyd.namcomp4,t_tcompnyd.namcomp5,
              global_v_coduser,global_v_coduser,t_tcompnyd.flgact);
    exception when dup_val_on_index then
      update tcompnyd
         set namcompe   = t_tcompnyd.namcompe,
             namcompt   = t_tcompnyd.namcompt,
             namcomp3   = t_tcompnyd.namcomp3,
             namcomp4   = t_tcompnyd.namcomp4,
             namcomp5   = t_tcompnyd.namcomp5,
             coduser    = global_v_coduser,
             flgact     = t_tcompnyd.flgact
       where codcompy   = t_tcompnyd.codcompy
         and comlevel   = t_tcompnyd.comlevel
         and codcomp    = t_tcompnyd.codcomp;
    end;
  end;
  --
  procedure save_data(json_str_input in clob,json_str_output out clob) is
    v_json_input    json_object_t := json_object_t(json_str_input);
    v_json_comp     json_object_t;
    v_json_comp_row json_object_t;

    t_tcompnyc    tcompnyc%rowtype;
    t_tcompnyd    tcompnyd%rowtype;

    v_qtycode     tsetcomp.qtycode%type;
    v_flg         varchar2(100);
    v_chk         varchar2(1);
  begin
    initial_value(json_str_input);
    t_tcompnyc.codcompy     := p_codcompy;
    t_tcompnyc.comlevel     := p_comlevel;
    t_tcompnyc.namcente     := hcm_util.get_string_t(v_json_input,'namcente');
    t_tcompnyc.namcentt     := hcm_util.get_string_t(v_json_input,'namcentt');
    t_tcompnyc.namcent3     := hcm_util.get_string_t(v_json_input,'namcent3');
    t_tcompnyc.namcent4     := hcm_util.get_string_t(v_json_input,'namcent4');
    t_tcompnyc.namcent5     := hcm_util.get_string_t(v_json_input,'namcent5');
    v_qtycode               := hcm_util.get_string_t(v_json_input,'qtycode');

    v_json_comp   := hcm_util.get_json_t(v_json_input,'param_json');
    insert_tcompnyc(t_tcompnyc);
    for i in 0..(v_json_comp.get_size - 1) loop
      v_json_comp_row         := hcm_util.get_json_t(v_json_comp,to_char(i));
      t_tcompnyd.codcompy     := t_tcompnyc.codcompy;
      t_tcompnyd.comlevel     := t_tcompnyc.comlevel;
      t_tcompnyd.codcomp      := hcm_util.get_string_t(v_json_comp_row,'codcomp');
      t_tcompnyd.namcompe     := hcm_util.get_string_t(v_json_comp_row,'namcompe');
      t_tcompnyd.namcompt     := hcm_util.get_string_t(v_json_comp_row,'namcompt');
      t_tcompnyd.namcomp3     := hcm_util.get_string_t(v_json_comp_row,'namcomp3');
      t_tcompnyd.namcomp4     := hcm_util.get_string_t(v_json_comp_row,'namcomp4');
      t_tcompnyd.namcomp5     := hcm_util.get_string_t(v_json_comp_row,'namcomp5');
      v_flg                   := hcm_util.get_string_t(v_json_comp_row,'flg');
      t_tcompnyd.flgact       := hcm_util.get_string_t(v_json_comp_row,'flgact');

      if length(t_tcompnyd.codcomp) <> v_qtycode then
        param_msg_error   := replace(get_error_msg_php('CO0027', global_v_lang),'[P-DIGITS]',v_qtycode);
        exit;
      end if;

      if replace(t_tcompnyd.codcomp,'0',null) is null then
        param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
        exit;
      end if;

      if v_flg in ('add', 'edit') then
        insert_tcompnyd(t_tcompnyd);
      elsif v_flg = 'delete' then
        begin
          select 'Y'
            into v_chk
            from tcenter
           where codcompy   = t_tcompnyd.codcompy
             and nvl(codcom2,'$@%#')    = decode(t_tcompnyd.comlevel,2,t_tcompnyd.codcomp,nvl(codcom2,'$@%#'))
             and nvl(codcom3,'$@%#')    = decode(t_tcompnyd.comlevel,3,t_tcompnyd.codcomp,nvl(codcom3,'$@%#'))
             and nvl(codcom4,'$@%#')    = decode(t_tcompnyd.comlevel,4,t_tcompnyd.codcomp,nvl(codcom4,'$@%#'))
             and nvl(codcom5,'$@%#')    = decode(t_tcompnyd.comlevel,5,t_tcompnyd.codcomp,nvl(codcom5,'$@%#'))
             and nvl(codcom6,'$@%#')    = decode(t_tcompnyd.comlevel,6,t_tcompnyd.codcomp,nvl(codcom6,'$@%#'))
             and nvl(codcom7,'$@%#')    = decode(t_tcompnyd.comlevel,7,t_tcompnyd.codcomp,nvl(codcom7,'$@%#'))
             and nvl(codcom8,'$@%#')    = decode(t_tcompnyd.comlevel,8,t_tcompnyd.codcomp,nvl(codcom8,'$@%#'))
             and nvl(codcom9,'$@%#')    = decode(t_tcompnyd.comlevel,9,t_tcompnyd.codcomp,nvl(codcom9,'$@%#'))
             and nvl(codcom10,'$@%#')   = decode(t_tcompnyd.comlevel,10,t_tcompnyd.codcomp,nvl(codcom10,'$@%#'))
             and rownum = 1 --User37 #3817 Final Test Phase 1 V11 22/11/2020   
             ;
          param_msg_error   := get_error_msg_php('HR1450', global_v_lang);
          exit;
        exception when no_data_found then
          delete tcompnyd
           where codcompy   = t_tcompnyd.codcompy
             and comlevel   = t_tcompnyd.comlevel
             and codcomp    = t_tcompnyd.codcomp;
        end;
      end if;
    end loop;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

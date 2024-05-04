--------------------------------------------------------
--  DDL for Package Body HRPM38E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM38E" is
  procedure initial_value ( json_str in clob ) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid     := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp             := hcm_util.get_string_t(json_obj,'b_index_codcomp');
    p_codempid            := hcm_util.get_string_t(json_obj,'b_index_codempid');
    p_codpos              := hcm_util.get_string_t(json_obj,'b_index_codpos');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  procedure initial_save ( json_str in clob ) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    param_json            := json_object_t(hcm_util.get_string_t(json_obj,'param_json'));
    param_probation       := hcm_util.get_json_t(param_json,'probation');
    param_testPosition    := hcm_util.get_json_t(param_json,'testPosition');
  end initial_save;

  procedure check_getindex is
    v_codcomp          varchar2(100);
    v_codempid         varchar2(100);
    v_codcomp_empid    varchar2(100);
    v_numlvl           varchar2(100);
    v_codpos           varchar2(100);
    v_staemp           varchar2(1);
    v_secur_codempid   boolean;
    v_secur_codcomp    boolean;
    v_secur            boolean;
  begin
    if ( p_codcomp is null or p_codpos is null ) and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codempid is not null then
        p_codcomp := '';
        p_codpos := '';
    end if;

    if p_codcomp is not null then
      begin
        select count(*)
        into v_codcomp
        from tcenter
        where codcomp like p_codcomp || '%';
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
        return;
      end;
    end if;
    if p_codcomp is not null then
      v_secur_codcomp := secur_main.secur7(p_codcomp,global_v_coduser);
      if v_secur_codcomp = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'tcenter');
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
        return;
      end;
    end if;
    if p_codempid is not null then
      begin
        select codempid, staemp, codcomp, numlvl
          into v_codempid, v_staemp, v_codcomp_empid, v_numlvl
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if v_codcomp_empid is not null and v_numlvl is not null then
        v_secur_codempid := secur_main.secur1(v_codcomp_empid,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl ,v_zupdsal);
        if v_secur_codempid = false then 
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,v_codcomp_empid);
          return;
        end if;
      end if;
    end if;
  end;

--  procedure check_save_1 is
--    v_count      number;
--    v_codform    tproasgh.codform%type;
--    v_typscore   tproasgh.typscore%type;
--    v_qtymax     tproasgh.qtymax%type;
--    v_qtyday     tproasgh.qtyday%type;
--    v_qtyscor    tproasgh.qtyscor%type;
--    v_codempid   tproasgh.codempid%type;
--    v_codpos     tproasgh.codpos%type;
--    v_codcomp    tproasgh.codcomp%type;
--  begin
----      commit;
--    for i in 0..p_eval_1.count - 1 loop
--      param_json_row  := json(p_eval_1.get(to_char(i) ) );
--      v_codform       := hcm_util.get_string(param_json_row,'p_codform');
--      v_typscore      := hcm_util.get_string(param_json_row,'p_typscore');
--      v_qtymax        := hcm_util.get_string(param_json_row,'p_qtymax');
--      v_qtyday        := hcm_util.get_string(param_json_row,'p_qtyday');
--      v_qtyscor       := hcm_util.get_string(param_json_row,'p_qtyscor');
--      v_codempid      := hcm_util.get_string(param_json_row,'p_codempid');
--      v_codpos        := hcm_util.get_string(param_json_row,'p_codpos');
--      v_codcomp       := hcm_util.get_string(param_json_row,'p_codcomp');
--
--      if v_codform is null or v_typscore is null or v_qtymax is null or v_qtyday is null or v_qtyscor is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        return;
--      end if;
--      if v_qtymax > 4 then
--        param_msg_error := get_error_msg_php('PM0098',global_v_lang);
--        return;
--      end if;
--      v_count := 0;
--      begin
--        select count(*)
--          into v_count
--          from tintview
--         where codform = v_codform;
--      end;
--      if v_count = 0 then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tintview ' || v_codform);
--        return;
--      end if;
--      v_count := 0;
--      if v_codcomp is not null then
--        begin
--          select count(*)
--          into v_count
--          from tcenter
--          where codcomp like v_codcomp || '%';
--        end;
--        if v_count = 0 then
--          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
--          return;
--        end if;
--      end if;
--      if v_codpos is not null then
--        v_count := 0;
--        begin
--          select count(*)
--          into v_count
--          from tpostn
--          where codpos = v_codpos;
--        end;
--        if v_count = 0 then
--          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
--          return;
--        end if;
--      end if;
--    end loop;
--  
--  end;
--
--  procedure check_save_2 is
--    v_count       number;
--    v_codform     tproasgh.codform%type;
--    v_codempid    tproasgh.codempid%type;
--    v_codpos      tproasgh.codpos%type;
--    v_codcomp     tproasgh.codcomp%type;
--    v_flagappr    tproasgn.flgappr%type;
--    v_codempap    tproasgn.codempap%type;
--    v_codempap1   tproasgn.codempap%type;
--  
--    p_typproba    tproasgh.codpos%type;
--    v_table_1     tproasgh.codpos%type;
--    v_table_2     tproasgh.codpos%type;
--  begin
----      COMMIT;
--    v_table_1 := 0;
--    v_table_2 := 0;
--    for i in 0..p_eval_2.count - 1 loop
--      param_json_row  := json(p_eval_2.get(to_char(i) ) );
--      p_typproba      := hcm_util.get_string(param_json_row,'p_typproba');
--      if v_table_1 = 0 then
--        if p_typproba = 1 then
--          v_table_1 := 1;
--        end if;
--      end if;
--      if v_table_2 = 0 then
--        if p_typproba = 2 then
--          v_table_2 := 1;
--        end if;
--      end if;
--    end loop;
--    if v_table_1 = 0 or v_table_2 = 0 then
--      param_msg_error := get_error_msg_php('PM0106',global_v_lang);
--      return;
--    end if;
--    for i in 0..p_eval_2.count - 1 loop
--      param_json_row  := json(p_eval_2.get(to_char(i) ) );
--      v_codform       := hcm_util.get_string(param_json_row,'p_codform');
--      v_codempid      := hcm_util.get_string(param_json_row,'p_codempid');
--      v_codpos        := hcm_util.get_string(param_json_row,'p_codpos');
--      v_codcomp       := hcm_util.get_string(param_json_row,'p_codcomp');
--      v_flagappr      := hcm_util.get_string(param_json_row,'p_flagpappr');
--      v_codempap      := hcm_util.get_string(param_json_row,'p_codempap');
--      v_count := 0;
--      
--      select count(*)
--        into v_count
--        from tintview
--       where codform = v_codform;
--      if v_count = 0 then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tintview ' || v_codform);
--        return;
--      end if;
--      v_count := 0;
--      if v_codcomp is not null then
--        select count(*)
--        into v_count
--        from tcenter
--        where codcomp like v_codcomp || '%';
--        if v_count = 0 then
--          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
--          return;
--        end if;
--      end if;
--
--      if v_codpos is not null then
--        v_count := 0;
--        select count(*)
--        into v_count
--        from tpostn
--        where codpos = v_codpos;
--
--        if v_count = 0 then
--          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
--          return;
--        end if;
--      end if;
--
--      for j in 0..p_eval_2.count - 1 loop
--        param_json_row1 := json(p_eval_2.get(to_char(j) ) );
--        v_codempap1 := hcm_util.get_string(param_json_row1,'codempap');
--        if i <> j then
--          if v_codempap1 = v_codempap then
--            param_msg_error := get_error_msg_php('HR2005',global_v_lang);
--            return;
--          end if;
--        end if;
--      end loop;
--    end loop;
--  end;

  procedure get_tproasgh_detail_1 (json_str_output out clob) is
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt_found    number := 0;
    v_codform       tproasgh.codform%type; 
    v_qtyscor       tproasgh.qtyscor%type; 
    v_qtymax        tproasgh.qtymax%type; 
    v_qtyday        tproasgh.qtyday%type; 
    v_typscore      tproasgh.typscore%type; 
    v_staemp        temploy1.staemp%type;
    v_flgRequired   boolean;

  begin
    begin
        select codform, qtyscor, qtymax, qtyday, typscore
          into v_codform, v_qtyscor, v_qtymax, v_qtyday, v_typscore
          from (  select codform, qtyscor, qtymax, qtyday, typscore
                    from tproasgh
                   where typproba = 1
                     and codcomp  = nvl(p_codcomp,codcomp)
                     and codpos   = nvl(p_codpos,codpos)
                     and codempid = nvl(p_codempid,codempid)
                ORDER BY codempid DESC, codcomp DESC) xx 
          where rownum =1; 
    exception when no_data_found then
      v_codform   := ''; 
      v_qtyscor   := ''; 
      v_qtymax    := ''; 
      v_qtyday    := ''; 
      v_typscore  := '2';
    end;

    if p_codempid is not null then
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codempid;

        if v_staemp = '3' then
            v_flgRequired := false;
        else
            v_flgRequired := true;
        end if;
    else
        v_flgRequired := true;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codform',v_codform);
    obj_data.put('typscore',v_typscore);
    obj_data.put('qtymax',v_qtymax);
    obj_data.put('qtyday',v_qtyday);
    obj_data.put('qtyscor',v_qtyscor);
    obj_data.put('flgRequired',v_flgRequired);

    json_str_output := obj_data.to_clob;

  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPROASGH');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then 
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tproasgh_detail_1;

  procedure get_tproasgh_detail_2 ( json_str_output out clob ) is
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt_found    number := 0;
    v_codform       tproasgh.codform%type; 
    v_qtyscor       tproasgh.qtyscor%type; 
    v_qtymax        tproasgh.qtymax%type; 
    v_qtyday        tproasgh.qtyday%type; 
    v_typscore      tproasgh.typscore%type; 
  begin
    begin
        select codform, qtyscor, qtymax, qtyday, typscore    
          into v_codform, v_qtyscor, v_qtymax, v_qtyday, v_typscore
          from ( select codform, qtyscor, qtymax, qtyday, typscore    
                   from tproasgh
                  where typproba = 2
                    and codcomp  = nvl(p_codcomp,codcomp)
                    and codpos   = nvl(p_codpos,codpos)
                    and codempid = nvl(p_codempid,codempid)
               ORDER BY codempid DESC, codcomp DESC) xx
         where rownum = 1; 
    exception when no_data_found then
      v_codform   := ''; 
      v_qtyscor   := ''; 
      v_qtymax    := ''; 
      v_qtyday    := ''; 
      v_typscore  := '';
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codform',v_codform);
    obj_data.put('typscore',v_typscore);
    obj_data.put('qtymax',v_qtymax);
    obj_data.put('qtyday',v_qtyday);
    obj_data.put('qtyscor',v_qtyscor);

    json_str_output := obj_data.to_clob;
  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tproasgh');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tproasgh_detail_2;

  procedure get_tproasgn_detail_1 ( json_str_output out clob ) is
    v_rcnt      number := 0;
    v_namemp    temploy1.namempe%type;
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_codcomp   tproasgn.codcomp%type;
    v_codpos    tproasgn.codpos%type;
    v_codempid  tproasgn.codempid%type;
    cursor c1 is 
        select codcomp, codpos, codempid
          from tproasgh
         where typproba = 1
           and codcomp  = nvl(p_codcomp,codcomp)
           and codpos   = nvl(p_codpos,codpos)
           and codempid = nvl(p_codempid,codempid)
      ORDER BY codempid DESC, codcomp DESC;

    cursor c_tproasgn is 
      select codpos, codempap, numseq, flgappr, codcompap, codposap, codempid
        from tproasgn
       where typproba = 1
         and codcomp = v_codcomp
         AND codpos = v_codpos
         AND codempid = v_codempid
    order by numseq;
  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_codcomp := i.codcomp;
        v_codpos := i.codpos;
        v_codempid := i.codempid;
        exit;
    end loop;

    for i in c_tproasgn loop
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codpos',i.codpos);
      obj_data.put('codempap',i.codempap);
      obj_data.put('numseq',i.numseq);
      obj_data.put('flgappr',i.flgappr);
      obj_data.put('codcompap',i.codcompap);
      obj_data.put('codposap',i.codposap);
      obj_data.put('image',get_emp_img(i.codempap));
      obj_data.put('numseq',i.numseq);
      obj_data.put('namemp',get_temploy_name(i.codempap,global_v_lang));
      obj_row.put(to_char(v_rcnt - 1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tproasgn');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tproasgn_detail_1;

  procedure get_tproasgn_detail_2 ( json_str_output out clob ) is
    v_rcnt      number := 0;
    v_namemp    temploy1.namempe%type;
    obj_row     json_object_t;
    obj_data    json_object_t;
    v_codcomp   tproasgn.codcomp%type;
    v_codpos    tproasgn.codpos%type;
    v_codempid  tproasgn.codempid%type;
    cursor c1 is 
        select codcomp, codpos, codempid
          from tproasgh
         where typproba = 2
           and codcomp  = nvl(p_codcomp,codcomp)
           and codpos   = nvl(p_codpos,codpos)
           and codempid = nvl(p_codempid,codempid)
      ORDER BY codempid DESC, codcomp DESC;

    cursor c_tproasgn is 
      select codpos, codempap, numseq, flgappr, codcompap, codposap, codempid
        from tproasgn
       where typproba = 2
         and codcomp = v_codcomp
         AND codpos = v_codpos
         AND codempid = v_codempid
    order by numseq;

  begin
    obj_row := json_object_t ();

    for i in c1 loop
        v_codcomp := i.codcomp;
        v_codpos := i.codpos;
        v_codempid := i.codempid;
        exit;
    end loop;

    for i in c_tproasgn loop
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t ();
      obj_data.put('coderror','200');
      obj_data.put('codpos',i.codpos);
      obj_data.put('codempap',i.codempap);
      obj_data.put('numseq',i.numseq);
      obj_data.put('flgappr',i.flgappr);
      obj_data.put('codcompap',i.codcompap);
      obj_data.put('codposap',i.codposap);
      obj_data.put('image',get_emp_img(i.codempap));
      obj_data.put('numseq',i.numseq);
      obj_data.put('namemp',get_temploy_name(i.codempap, global_v_lang));
      obj_row.put(to_char(v_rcnt - 1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when no_data_found then
    param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tproasgn');
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tproasgn_detail_2;

  procedure get_index_tproasgh_1 ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_getindex;
    if param_msg_error is null then
      get_tproasgh_detail_1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_tproasgh_2 ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_getindex;
    if param_msg_error is null then
      get_tproasgh_detail_2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_tproasgn_1 ( json_str_input in clob, json_str_output out clob ) as
  begin
    initial_value(json_str_input);
    check_getindex;
    if param_msg_error is null then
      get_tproasgn_detail_1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_tproasgn_2 (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_getindex;
    if param_msg_error is null then
      get_tproasgn_detail_2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_data ( json_str_input in clob, json_str_output out clob ) is
    obj_probation_detail      json_object_t;
    obj_probation_table       json_object_t;
    obj_testPosition_detail   json_object_t;
    obj_testPosition_table    json_object_t;
    param_json_row            json_object_t;

    v_count          number;
    v_chkExist       number := 0;
    v_codform        tproasgh.codform%type;
    v_typscore       tproasgh.typscore%type;
    v_qtymax         tproasgh.qtymax%type;
    v_qtyday         tproasgh.qtyday%type;
    v_qtyscor        tproasgh.qtyscor%type;
    v_codempid       tproasgh.codempid%type;
    v_codpos         tproasgh.codpos%type;
    v_codcomp        tproasgh.codcomp%type;
    c_codempid       tproasgh.codempid%type;
    c_codpos         tproasgh.codpos%type;
    c_codcomp        tproasgh.codcomp%type;
    v_typproba       tproasgh.typproba%type;
    v_codcompap      tproasgn.codcompap%type;
    v_codposap       tproasgn.codposap%type;
    v_codempap       tproasgn.codempap%type;
    v_flgappr        tproasgn.flgappr%type;

    v_codcompapOld   tproasgn.codcompap%type;
    v_codposapOld    tproasgn.codposap%type;
    v_codempapOld    tproasgn.codempap%type;
    v_flgapprOld     tproasgn.flgappr%type;

    v_numseq         tproasgn.numseq%type;
    v_numseqn        tproasgn.numseq%type;
    v_flg            varchar2(30);

    cursor c1 is 
        select * 
          from tproasgn 
         where codempid = c_codempid
           and codcomp  = c_codcomp
           and codpos   = c_codpos
           and typproba = v_typproba
      order by numseq;    

  begin
    initial_value(json_str_input);
    initial_save(json_str_input);

    if p_codempid is not null then
      c_codpos    := '%';
      c_codcomp   := '%';
      c_codempid  := p_codempid;
    else
      c_codpos    := p_codpos;
      c_codcomp   := p_codcomp;
      c_codempid  := '%';
    end if;

    -- save_probation
    obj_probation_detail  :=  hcm_util.get_json_t(param_probation,'detail');
    obj_probation_table   :=  hcm_util.get_json_t(param_probation,'table1');
    v_codform             :=  hcm_util.get_string_t(obj_probation_detail,'codform');
    v_typscore            :=  hcm_util.get_string_t(obj_probation_detail,'typscore');
    v_qtymax              :=  hcm_util.get_string_t(obj_probation_detail,'qtymax');
    v_qtyday              :=  hcm_util.get_string_t(obj_probation_detail,'qtyday');
    v_qtyscor             :=  hcm_util.get_string_t(obj_probation_detail,'qtyscor');
    v_typproba            :=  1;
    if v_qtymax > 4 then
      param_msg_error := get_error_msg_php('PM0098',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
      return;
    end if;

    begin
      select count(*)
        into v_chkExist
        from tproasgh
       where codempid = c_codempid
         and codcomp  = c_codcomp
         and codpos   = c_codpos
         and typproba = v_typproba; 
      if v_chkExist = 0 then
        insert into tproasgh (codcomp, codpos, codempid, typproba, 
                              qtyday, qtymax, qtyscor, typscore, codform, 
                              dtecreate, codcreate, coduser) 
             values (c_codcomp, c_codpos, c_codempid, v_typproba, 
                     v_qtyday, v_qtymax, v_qtyscor, v_typscore, v_codform, 
                     sysdate, global_v_coduser, global_v_coduser );
      else
        update tproasgh
           set qtyday   = v_qtyday,
               typproba = v_typproba,
               qtymax   = v_qtymax,
               qtyscor  = v_qtyscor,
               typscore = v_typscore,
               codform  = v_codform,
               coduser  = global_v_coduser
         where codcomp  = c_codcomp
           and codpos   = c_codpos
           and codempid = c_codempid
           and typproba = v_typproba;
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end;

    for i in 0..obj_probation_table.get_size - 1 loop
      param_json_row  := hcm_util.get_json_t(obj_probation_table,to_char(i) );
      v_flg         := hcm_util.get_string_t(param_json_row,'flg');
      v_flgappr     := hcm_util.get_string_t(param_json_row,'flgappr');
      v_codcompap   := hcm_util.get_string_t(param_json_row,'codcompap');
      v_codposap    := hcm_util.get_string_t(param_json_row,'codposap');
      v_codempap    := hcm_util.get_string_t(param_json_row,'codempap');

      v_flgapprOld    := hcm_util.get_string_t(param_json_row,'flgapprOld');
      v_codcompapOld  := hcm_util.get_string_t(param_json_row,'codcompapOld');
      v_codposapOld   := hcm_util.get_string_t(param_json_row,'codposapOld');
      v_codempapOld   := hcm_util.get_string_t(param_json_row,'codempapOld');

      v_numseq        := to_number(hcm_util.get_string_t(param_json_row,'numseq'));

      if v_flgappr = 2 then
        if (v_codcompap = p_codcomp) and (v_codposap = p_codpos) then
          param_msg_error := get_error_msg_php('PM0124',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      elsif v_flgappr = 3 then
        if v_codempap = p_codempid then
          param_msg_error := get_error_msg_php('PM0125',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      end if;

      if v_flg = 'add' then
        select nvl(max(numseq),0) + 1
          into v_numseq
          from tproasgn
         where codempid = c_codempid
           and codcomp = c_codcomp
           and codpos = c_codpos
           and typproba = v_typproba;

          insert into tproasgn (codcomp, codpos, codempid, typproba, 
                                numseq, flgappr, codcompap, codposap, codempap, 
                                dtecreate, codcreate, coduser) 
               values (c_codcomp, c_codpos, c_codempid, v_typproba, 
                       v_numseq, v_flgappr, v_codcompap, v_codposap, v_codempap, 
                       sysdate, global_v_coduser, global_v_coduser );

      elsif v_flg = 'edit' then
        update tproasgn
           set flgappr   = v_flgappr,
               codcompap = v_codcompap,
               codposap  = v_codposap,
               codempap  = v_codempap,
               coduser   = global_v_coduser
         where codcomp   = c_codcomp
           and codpos    = c_codpos
           and codempid  = c_codempid
           and typproba  = v_typproba
           and numseq    = v_numseq;

      elsif v_flg = 'delete' then
        delete tproasgn
         where codcomp   = c_codcomp
           and codpos    = c_codpos
           and codempid  = c_codempid
           and typproba  = v_typproba
           and numseq    = v_numseq;
      end if;
    end loop;

    v_numseqn := 0;
    for r1 in c1 loop
        v_numseqn := v_numseqn + 1;
        update tproasgn 
           set numseq = v_numseqn * 100
         where codcomp   = r1.codcomp
           and codpos    = r1.codpos
           and codempid  = r1.codempid
           and typproba  = r1.typproba
           and numseq = r1.numseq;
    end loop;
    for r1 in c1 loop
        update tproasgn 
           set numseq = numseq / 100
         where codcomp   = r1.codcomp
           and codpos    = r1.codpos
           and codempid  = r1.codempid
           and typproba  = r1.typproba
           and numseq = r1.numseq;
    end loop;    
    -- save_testPosition
    obj_testPosition_detail  :=  hcm_util.get_json_t(param_testPosition,'detail');
    obj_testPosition_table   :=  hcm_util.get_json_t(param_testPosition,'table2');
    v_codform             :=  hcm_util.get_string_t(obj_testPosition_detail,'codform');
    v_typscore            :=  hcm_util.get_string_t(obj_testPosition_detail,'typscore');
    v_qtymax              :=  hcm_util.get_string_t(obj_testPosition_detail,'qtymax');
    v_qtyday              :=  hcm_util.get_string_t(obj_testPosition_detail,'qtyday');
    v_qtyscor             :=  hcm_util.get_string_t(obj_testPosition_detail,'qtyscor');
    v_typproba            :=  2;
    if v_qtymax > 4 then
      param_msg_error := get_error_msg_php('PM0098',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
      return;
    end if;

    begin
      select count(*)
        into v_chkExist
        from tproasgh
       where codempid = c_codempid
         and codcomp  = c_codcomp
         and codpos   = c_codpos
         and typproba = v_typproba; 
      if v_chkExist = 0 then
        insert into tproasgh (codcomp, codpos, codempid, typproba, 
                              qtyday, qtymax, qtyscor, typscore, codform, 
                              dtecreate, codcreate, coduser) 
             values (c_codcomp, c_codpos, c_codempid, v_typproba, 
                     v_qtyday, v_qtymax, v_qtyscor, v_typscore, v_codform, 
                     sysdate, global_v_coduser, global_v_coduser );
      else
        update tproasgh
           set qtyday   = v_qtyday,
               typproba = v_typproba,
               qtymax   = v_qtymax,
               qtyscor  = v_qtyscor,
               typscore = v_typscore,
               codform  = v_codform,
               coduser  = global_v_coduser
         where codcomp  = c_codcomp
           and codpos   = c_codpos
           and codempid = c_codempid
           and typproba = v_typproba;
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      rollback;
      return;
    end;

    for i in 0..obj_testPosition_table.get_size - 1 loop
      param_json_row  := hcm_util.get_json_t(obj_testPosition_table,to_char(i) );
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_flgappr       := hcm_util.get_string_t(param_json_row,'flgappr');
      v_codcompap     := hcm_util.get_string_t(param_json_row,'codcompap');
      v_codposap      := hcm_util.get_string_t(param_json_row,'codposap');
      v_codempap      := hcm_util.get_string_t(param_json_row,'codempap');

      v_flgapprOld    := hcm_util.get_string_t(param_json_row,'flgapprOld');
      v_codcompapOld  := hcm_util.get_string_t(param_json_row,'codcompapOld');
      v_codposapOld   := hcm_util.get_string_t(param_json_row,'codposapOld');
      v_codempapOld   := hcm_util.get_string_t(param_json_row,'codempapOld');

      v_numseq        := to_number(hcm_util.get_string_t(param_json_row,'numseq'));

      if v_flgappr = 2 then
        if (v_codcompap = p_codcomp) and (v_codposap = p_codpos) then
          param_msg_error := get_error_msg_php('PM0124',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      elsif v_flgappr = 3 then
        if v_codempap = p_codempid then
          param_msg_error := get_error_msg_php('PM0125',global_v_lang);
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          rollback;
          return;
        end if;
      end if;

      if v_flg = 'add' then
        select nvl(max(numseq),0) + 1
          into v_numseq
          from tproasgn
         where codempid = c_codempid
           and codcomp = c_codcomp
           and codpos = c_codpos
           and typproba = v_typproba;

          insert into tproasgn (codcomp, codpos, codempid, typproba, 
                                numseq, flgappr, codcompap, codposap, codempap, 
                                dtecreate, codcreate, coduser) 
               values (c_codcomp, c_codpos, c_codempid, v_typproba, 
                       v_numseq, v_flgappr, v_codcompap, v_codposap, v_codempap, 
                       sysdate, global_v_coduser, global_v_coduser );

      elsif v_flg = 'edit' then
        update tproasgn
           set flgappr   = v_flgappr,
               codcompap = v_codcompap,
               codposap  = v_codposap,
               codempap  = v_codempap,
               coduser   = global_v_coduser
         where codcomp   = c_codcomp
           and codpos    = c_codpos
           and codempid  = c_codempid
           and typproba  = v_typproba
           and numseq    = v_numseq;

      elsif v_flg = 'delete' then
        delete tproasgn
         where codcomp   = c_codcomp
           and codpos    = c_codpos
           and codempid  = c_codempid
           and typproba  = v_typproba
           and numseq    = v_numseq;
      end if;

    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index ( json_str_input in clob, json_str_output out clob ) is
  begin
    initial_value(json_str_input);
    if p_codempid is not null then
      p_codpos  := '%';
      p_codcomp := '%';
    else
      p_codempid := '%';
    end if;

    begin
      delete 
        from tproasgn
       where codcomp  = p_codcomp
         and codpos   = p_codpos
         and codempid = p_codempid;
    end;

    begin
      delete 
        from tproasgh
       where codcomp  = p_codcomp
         and codpos   = p_codpos
         and codempid = p_codempid;
    end;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      commit;
    else
      rollback;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure get_emp_image ( json_str_input in clob, json_str_output out clob ) as
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        obj_data    :=  json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('image',get_emp_img(p_codempid));
        json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  
end hrpm38e;

/

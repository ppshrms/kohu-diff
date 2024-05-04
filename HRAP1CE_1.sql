--------------------------------------------------------
--  DDL for Package Body HRAP1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP1CE" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    b_index_dteyreap        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_dteyreapQuery   := to_number(hcm_util.get_string_t(json_obj,'p_yearQuery'));
    b_index_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcompQuery    := hcm_util.get_string_t(json_obj,'p_codcompQuery');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    --<<User37 #4130 AP - PeoplePlus 19/02/2021
    v_flgDisable    boolean := false;
    v_dteyreap      number;
    -->>User37 #4130 AP - PeoplePlus 19/02/2021
    v_cnt           number := 0;--nut
    obj_formula     json_object_t;
    cursor c1 is
      select grade,desgrade,desgradt,desgrad3,desgrad4,desgrad5,
             pctemp,pctwkstr,pctwkend,
             pctpostr,pctpoend,pctactstr,pctactend,
             decode(global_v_lang,'101',desgrade
                                 ,'102',desgradt
                                 ,'103',desgrad3
                                 ,'104',desgrad4
                                 ,'105',desgrad5) as desgrad
        from tstdis
       where codcomp = b_index_codcomp
         and dteyreap = v_dteyreap--User37 #4130 AP - PeoplePlus 19/02/2021 b_index_dteyreap
       order by pctwkend desc;
    cursor c2 is
      select grade,desgrade,desgradt,desgrad3,desgrad4,desgrad5,
             pctemp,pctwkstr,pctwkend,
             pctpostr,pctpoend,pctactstr,pctactend,
             decode(global_v_lang,'101',desgrade
                                 ,'102',desgradt
                                 ,'103',desgrad3
                                 ,'104',desgrad4
                                 ,'105',desgrad5) as desgrad
        from tstdis
       where codcomp = b_index_codcomp
         and dteyreap = v_dteyreap--User37 #4130 AP - PeoplePlus 19/02/2021 b_index_dteyreap
       order by pctwkend desc;

  begin
    if b_index_codcompQuery is not null and b_index_dteyreapQuery is not null then
      p_isCopy  :=  'Y';
      v_flgAdd  := true;
    end if;

    --<<User37 #4130 AP - PeoplePlus 19/02/2021
    if b_index_dteyreap >= to_number(to_char(sysdate,'yyyy')) then
        v_dteyreap          := b_index_dteyreap;
        v_flgDisable        := false;
    else
       begin
            select max(dteyreap)
              into v_dteyreap
              from tstdis
             where codcomp = b_index_codcomp
               and dteyreap <= b_index_dteyreap;
       exception when no_data_found then
            v_dteyreap := null;
       end;
       if v_dteyreap is null then
           v_dteyreap          := b_index_dteyreap;
           v_flgDisable        := false;
       else
           v_msqerror           := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
           v_flgDisable         := true;
       end if;
    end if;
    -->>User37 #4130 AP - PeoplePlus 19/02/2021
    --<<User37 #4130 AP - PeoplePlus 18/03/2021
    begin
        select count(*)
          into v_cnt
          from tapprais
         where codcomp like b_index_codcomp||'%'
           and dteyreap = v_dteyreap
           and staappr = 'Y';
    exception when no_data_found then
        v_cnt := 0;
    end;
    if v_cnt > 0 then
        v_msqerror           := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400','');
        v_flgDisable         := true;
    else
        v_msqerror           := '';
        v_flgDisable         := false;
    end if;
    -->>User37 #4130 AP - PeoplePlus 18/03/2021
    begin
      select flggrade,formusal,statement
        into v_flggrade,v_formusal,v_statement
        from tapbudgt
       where codcomp = b_index_codcomp
         and dteyreap = v_dteyreap;
    exception when no_data_found then
      null;
    end;
    obj_row := json_object_t();
    if v_flggrade <> '3' then
        for i in c1 loop
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');

          obj_data.put('flggrade', v_flggrade);
          obj_data.put('grade', i.grade);
          obj_data.put('desgrad', i.desgrad);
          obj_data.put('desgrade', i.desgrade);
          obj_data.put('desgradt', i.desgradt);
          obj_data.put('desgrad3', i.desgrad3);
          obj_data.put('desgrad4', i.desgrad4);
          obj_data.put('desgrad5', i.desgrad5);
          obj_data.put('pctemp', i.pctemp);
          obj_data.put('pctwkstr', i.pctwkstr);
          obj_data.put('pctwkend', i.pctwkend);
          obj_data.put('pctpostr', i.pctpostr);
          obj_data.put('pctpoend', i.pctpoend);
          obj_data.put('pctactstr', i.pctactstr);
          obj_data.put('pctactend', i.pctactend);
          obj_data.put('flgAdd', v_flgAdd);
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    else
        for i in c2 loop
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');

          obj_data.put('flggrade', v_flggrade);
          obj_data.put('grade', i.grade);
          obj_data.put('desgrad', i.desgrad);
          obj_data.put('desgrade', i.desgrade);
          obj_data.put('desgradt', i.desgradt);
          obj_data.put('desgrad3', i.desgrad3);
          obj_data.put('desgrad4', i.desgrad4);
          obj_data.put('desgrad5', i.desgrad5);
          obj_data.put('pctemp', i.pctemp);
          obj_data.put('pctwkstr', i.pctwkstr);
          obj_data.put('pctwkend', i.pctwkend);
          obj_data.put('pctpostr', i.pctpostr);
          obj_data.put('pctpoend', i.pctpoend);
          obj_data.put('pctactstr', i.pctactstr);
          obj_data.put('pctactend', i.pctactend);
          obj_data.put('flgAdd', v_flgAdd);
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('isCopy', p_isCopy);
    obj_result.put('flggrade', v_flggrade);
    --<<User37 #4130 AP - PeoplePlus 19/02/2021
    obj_result.put('flgDisable', v_flgDisable);
    obj_result.put('dteyreap', nvl(b_index_dteyreapQuery,v_dteyreap));
    obj_result.put('warning', v_msqerror);

    obj_formula := json_object_t();
    obj_formula.put('code', trim(nvl(v_formusal,' ')));
    obj_formula.put('description', trim(nvl(v_statement,' ')));
    obj_result.put('formula', obj_formula);
    -->>User37 #4130 AP - PeoplePlus 19/02/2021
    obj_result.put('table', obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcomp   tcenter.codcomp%type;
  begin

    if b_index_codcomp is not null then
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(b_index_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copy_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flggrade      tapbudgt.flggrade%type;
    cursor c1 is
      select distinct codcomp, dteyreap
        from tstdis
       where dteyreap||codcomp <> b_index_dteyreap||b_index_codcomp
    order by dteyreap  desc , codcomp asc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codcomp', i.codcomp);
            obj_data.put('dteyreap', i.dteyreap);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(json_str_input in clob) is
     v_codcomp      tcenter.codcomp%type;
     param_json     json_object_t;
     obj_table      json_object_t;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    obj_table     := hcm_util.get_json_t(param_json,'table');
  end;
  --
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    obj_table       json_object_t;

    v_flg	        varchar2(1000 char);
    v_flggrade	    varchar2(100 char);
    v_grade	        tstdis.grade%type;
    v_pctemp	    tstdis.pctemp%type;
    v_pctwkstr	    tstdis.pctwkstr%type;
    v_pctwkend	    tstdis.pctwkend%type;
    v_desgrade	    tstdis.desgrade%type;
    v_desgradt	    tstdis.desgradt%type;
    v_desgrad3	    tstdis.desgrad3%type;
    v_desgrad4	    tstdis.desgrad4%type;
    v_desgrad5	    tstdis.desgrad5%type;
    v_sumpctemp     number;
    v_flgDup        varchar2(2 char);
    v_isCopy        varchar2(2 char);
    obj_formula     json_object_t;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    v_pctpostr      tstdis.pctpostr%type;
    v_pctpoend      tstdis.pctpoend%type;
    v_pctactstr     tstdis.pctactstr%type;
    v_pctactend     tstdis.pctactend%type;
    cursor c1 is
      select grade,pctwkstr,pctwkend
        from tstdis
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
       order by grade;
  begin
    initial_value(json_str_input);
--    check_save(json_str_input);
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'params');
    v_flggrade    := hcm_util.get_string_t(param_json,'flggrade');
    v_isCopy      := hcm_util.get_string_t(param_json,'isCopy');
    obj_formula   := hcm_util.get_json_t(param_json,'formula');
    v_formusal    := hcm_util.get_string_t(obj_formula,'code');
    v_statement   := hcm_util.get_clob_t(obj_formula,'description');

    obj_table     := hcm_util.get_json_t(param_json,'table');

    begin
      insert into tapbudgt(dteyreap, codcomp, flggrade,formusal,statement,
                            dtecreate,codcreate,dteupd,coduser)
      values (b_index_dteyreap, b_index_codcomp/*get_compful(b_index_codcomp)*/, v_flggrade,
               v_formusal,v_statement,
               sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
      update tapbudgt
         set flggrade =	v_flggrade,
             formusal = v_formusal,
             statement = v_statement ,
             dteupd = sysdate,
             coduser = global_v_coduser
       where codcomp = b_index_codcomp/*get_compful(b_index_codcomp)*/
         and dteyreap = b_index_dteyreap;
    end;
    if v_isCopy = 'Y' then
      begin
        delete tstdis
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap;
      end;
    end if;
    for i in 0..obj_table.get_size-1 loop
      param_json_row    := hcm_util.get_json_t(obj_table,to_char(i));
      v_flg             := hcm_util.get_string_t(param_json_row,'flg');
      v_grade           := hcm_util.get_string_t(param_json_row,'grade');
      v_pctemp          := hcm_util.get_string_t(param_json_row,'pctemp');
      v_pctwkstr	    := hcm_util.get_string_t(param_json_row,'pctwkstr');
      v_pctwkend	    := hcm_util.get_string_t(param_json_row,'pctwkend');
      v_desgrade		:= hcm_util.get_string_t(param_json_row,'desgrade');
      v_desgradt		:= hcm_util.get_string_t(param_json_row,'desgradt');
      v_desgrad3		:= hcm_util.get_string_t(param_json_row,'desgrad3');
      v_desgrad4	    := hcm_util.get_string_t(param_json_row,'desgrad4');
      v_desgrad5	    := hcm_util.get_string_t(param_json_row,'desgrad5');
      v_pctpostr        := hcm_util.get_string_t(param_json_row,'pctpostr');
      v_pctpoend        := hcm_util.get_string_t(param_json_row,'pctpoend');
      v_pctactstr       := hcm_util.get_string_t(param_json_row,'pctactstr');
      v_pctactend       := hcm_util.get_string_t(param_json_row,'pctactend');

      if v_flg = 'add' then
        begin
          delete tstdis where codcomp = b_index_codcomp and dteyreap = b_index_dteyreap and grade = v_grade;

          insert into tstdis(codcomp, dteyreap, grade,
                             desgrade,desgradt,desgrad3,desgrad4,desgrad5,
                             pctwkstr,pctwkend,pctemp,
                             pctpostr,pctpoend,pctactstr,pctactend,
                             codcreate,coduser)
          values (b_index_codcomp, b_index_dteyreap, v_grade,
                  v_desgrade,v_desgradt,v_desgrad3,v_desgrad4,v_desgrad5,
                  v_pctwkstr,v_pctwkend,v_pctemp,
                  v_pctpostr,v_pctpoend,v_pctactstr,v_pctactend,
                  global_v_coduser,global_v_coduser);
        end;
      elsif v_flg = 'delete' then
        begin
          delete tstdis where codcomp = b_index_codcomp and dteyreap = b_index_dteyreap and grade = v_grade;
        end;
      elsif v_flg = 'edit' then
        begin
          update tstdis
             set desgrade	=	v_desgrade,
                 desgradt	=	v_desgradt,
                 desgrad3	=	v_desgrad3,
                 desgrad4	=	v_desgrad4,
                 desgrad5	=	v_desgrad5,
                 pctwkstr	=	v_pctwkstr,
                 pctwkend	=	v_pctwkend,
                 pctemp	    =	v_pctemp,
                 pctpostr = v_pctpostr,
                 pctpoend = v_pctpoend,
                 pctactstr = v_pctactstr,
                 pctactend = v_pctactend,
                 dteupd  = trunc(sysdate),
                 coduser = global_v_coduser
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and grade = v_grade;
        end;
      end if;
    end loop;
    if v_flggrade = '2' then
      begin
        select sum(pctemp) into v_sumpctemp
          from tstdis
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap;
      exception when no_data_found then
        v_sumpctemp := 0;
      end;
      if v_sumpctemp <> 100 then
        param_msg_error := get_error_msg_php('AP0040',global_v_lang);
      end if;
    end if;
    for r1 in c1 loop
      begin
        select 'Y' into v_flgDup
          from tstdis
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and grade <> r1.grade
           and (pctwkstr between r1.pctwkstr and r1.pctwkend or pctwkend between r1.pctwkstr and r1.pctwkend)
           and rownum = 1;
      exception when no_data_found then
        v_flgDup := 'N';
      end;
      if v_flgDup = 'Y' then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        exit;
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
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
  end;

  procedure gen_ninebox(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flggrade      tapbudgt.flggrade%type;
    cursor c1 is
      select *
        from tnineboxap
       where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tnineboxap
                          where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
                            and to_char(dteeffec,'YYYY') <= b_index_dteyreap)
    order by codgroup desc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
--        if secur_main.secur7(i.codcomp, global_v_coduser) then
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');

              obj_data.put('flggrade', '3');
              obj_data.put('grade', i.codgroup);
              obj_data.put('desgrad', i.namgroupt);
              obj_data.put('desgrade', i.namgroupt);
              obj_data.put('desgradt', i.namgroupt);
              obj_data.put('desgrad3', i.namgroupt);
              obj_data.put('desgrad4', i.namgroupt);
              obj_data.put('desgrad5', i.namgroupt);
              obj_data.put('pctemp', '');
              obj_data.put('pctwkstr', '');
              obj_data.put('pctwkend', '');
              obj_data.put('pctpostr', '');
              obj_data.put('pctpoend', '');
              obj_data.put('pctactstr', '');
              obj_data.put('pctactend', '');
              obj_data.put('flgAdd', true);
            obj_row.put(to_char(v_rcnt-1),obj_data);
--        end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_ninebox(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_ninebox(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
end hrap1ce;

/

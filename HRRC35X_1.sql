--------------------------------------------------------
--  DDL for Package Body HRRC35X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC35X" as
   procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    v_chken             := hcm_secur.get_v_chken;

    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_stasign     := hcm_util.get_string_t(json_obj,'p_stasign');

    p_numappl     := hcm_util.get_string_t(json_obj,'p_numappl');
    p_numreqrq    := hcm_util.get_string_t(json_obj,'p_numreqrq');
    p_codform     := hcm_util.get_string_t(json_obj,'p_codform');
    p_dteprint    := to_date(hcm_util.get_string_t(json_obj,'p_dteprint'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_chkdata   varchar2(10 char);
    v_codcomp   tcenter.codcomp%type;
    v_codpos    tpostn.codpos%type;
  begin
    begin
      select codcomp into v_codcomp
        from tcenter
       where codcomp = get_compful(p_codcomp);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
      return;
    end;
    if not secur_main.secur7(p_codcomp, global_v_coduser) then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    begin
      select codpos into v_codpos
        from tpostn
       where codpos = p_codpos;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPOSTN');
      return;
    end;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         boolean;
    v_stasign       tapplcfm.stasign%type;

/*--<<  #5771 || User39 || 7/9/2021
    cursor c1 is
      select *
      from tapplcfm
      where codcomp like p_codcomp||'%'
      and codposc = p_codpos
      and dteappr between p_dtestrt and p_dteend
      and stasign = 'Y'
      order by numappl ;

    cursor c2 is
      select *
      from tapplcfm
      where codcomp like p_codcomp||'%'
      and codposrq = p_codpos
      and dteappr between p_dtestrt and p_dteend
      and stasign = 'N'
     order by numappl ;
*/

    cursor c1 is
      select decode(p_stasign,'Y',codposc,codposrq) codpos ,numappl ,
             numreqrq ,dteappr ,codappr ,stasign ,dteprint ,codform ,numdoc
        from tapplcfm
       where codcomp   like p_codcomp||'%'
         and dteappr   between p_dtestrt and p_dteend
         and stasign   = p_stasign
         and((codposc  = p_codpos and p_stasign = 'Y')
          or (codposrq = p_codpos and p_stasign = 'N'))
    order by numappl ;
-->>  #5771 || User39 || 7/9/2021

  begin
    obj_row := json_object_t();
    if p_stasign = 'Y' then
      for r1 in c1 loop
        v_flgdata := 'Y';
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', r1.numappl);
        obj_data.put('desc_numappl', get_tapplinf_name(r1.numappl, global_v_lang));
        obj_data.put('numreqrq', r1.numreqrq);
        --obj_data.put('codpos', r1.codposc); --#5771 || User39 || 7/9/2021
        obj_data.put('codpos', r1.codpos);    --#5771 || User39 || 7/9/2021
        --obj_data.put('desc_codpos', get_tpostn_name(r1.codposc, global_v_lang));   --#5771 || User39 || 7/9/2021
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));      --#5771 || User39 || 7/9/2021
        obj_data.put('dteappr', to_char(r1.dteappr, 'dd/mm/yyyy'));
        obj_data.put('desc_codempap', get_temploy_name(r1.codappr, global_v_lang));
        obj_data.put('results', get_tlistval_name('STASIGN', r1.stasign, global_v_lang));
        obj_data.put('dteprint', to_char(r1.dteprint, 'dd/mm/yyyy'));
        obj_data.put('codform', r1.codform);
        obj_data.put('numdoc', r1.numdoc);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    else
      for r2 in c1 loop
        v_flgdata := 'Y';
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numappl', r2.numappl);
        obj_data.put('desc_numappl', get_tapplinf_name(r2.numappl, global_v_lang));
        obj_data.put('numreqrq', r2.numreqrq);
        --obj_data.put('codpos', r2.codposrq);   --#5771 || User39 || 7/9/2021
        obj_data.put('codpos', r2.codpos);       --#5771 || User39 || 7/9/2021
        --obj_data.put('desc_codpos', get_tpostn_name(r2.codposrq, global_v_lang));  --#5771 || User39 || 7/9/2021
        obj_data.put('desc_codpos', get_tpostn_name(r2.codpos, global_v_lang));      --#5771 || User39 || 7/9/2021
        obj_data.put('dteappr', to_char(r2.dteappr, 'dd/mm/yyyy'));
        obj_data.put('desc_codempap', get_temploy_name(r2.codappr, global_v_lang));
        obj_data.put('results', get_tlistval_name('STASIGN', r2.stasign, global_v_lang));
        obj_data.put('dteprint', to_char(r2.dteprint, 'dd/mm/yyyy'));
        obj_data.put('codform', r2.codform);
        obj_data.put('numdoc', r2.numdoc);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TAPPLCFM');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
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
  end get_index;
  --
  procedure gen_detail_tab1 (json_str_output out clob) as
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_stasign       tapplcfm.stasign%type;

    rec_tapplcfm    tapplcfm%rowtype;
  begin
    begin
      select *
        into rec_tapplcfm
        from tapplcfm
       where numappl = p_numappl
         and numreqrq = p_numreqrq
         and codposrq = p_codpos;
    exception when no_data_found then
      null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numappl', rec_tapplcfm.numappl);
    obj_data.put('desc_numappl', get_tapplinf_name(rec_tapplcfm.numappl, global_v_lang));
    obj_data.put('codpos', rec_tapplcfm.codposrq);
    obj_data.put('desc_codpos', get_tpostn_name(rec_tapplcfm.codposrq, global_v_lang));
    obj_data.put('numappr', rec_tapplcfm.numreqrq);
    if rec_tapplcfm.stasign = 'Y' then
      obj_data.put('desc_codcomp', get_tcenter_name(rec_tapplcfm.codcomp, global_v_lang));
    else
      obj_data.put('desc_codcomp', get_tcenter_name(rec_tapplcfm.codcompl, global_v_lang));
    end if;
    obj_data.put('dteefpos', to_char(rec_tapplcfm.dteempmt,'dd/mm/yyyy'));
    obj_data.put('codjob', get_tpostn_name(rec_tapplcfm.codposrq, global_v_lang));
    obj_data.put('typproba', get_tcodec_name('TCODEMPL', rec_tapplcfm.codempmt , global_v_lang));
    obj_data.put('qtydatrqy', rec_tapplcfm.qtywkemp);
    obj_data.put('day_probation', rec_tapplcfm.qtyduepr);
    obj_data.put('stasign', rec_tapplcfm.stasign);
    obj_data.put('codform', rec_tapplcfm.codform);
    obj_data.put('dateprint', to_char(rec_tapplcfm.dteprint,'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail_tab1;

  procedure get_detail_tab1 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_tab1;
  --
  procedure gen_detail_tab2 (json_str_output out clob) as
    obj_data       json_object_t;
    obj_data_row   json_object_t;
    obj_row        json_object_t;
    v_rcnt          number := 0;
    v_stasign       tapplcfm.stasign%type;

    rec_tapplcfm    tapplcfm%rowtype;
  begin
    begin
      select *
        into rec_tapplcfm
        from tapplcfm
       where numappl = p_numappl
         and numreqrq = p_numreqrq
         and codposrq = p_codpos;
    exception when no_data_found then
      null;
    end;

    obj_data := json_object_t();
    obj_row := json_object_t();

    -- codincom1
    if rec_tapplcfm.codincom1 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom1);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom1, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal1, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom1, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom2
    if rec_tapplcfm.codincom2 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom2);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom2, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal2, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom2, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom3
    if rec_tapplcfm.codincom3 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom3);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom3, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal3, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom3, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom4
    if rec_tapplcfm.codincom4 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom4);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom4, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal4, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom4, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom5
    if rec_tapplcfm.codincom5 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom5);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom5, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal5, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom5, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom6
    if rec_tapplcfm.codincom6 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom6);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom6, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal6, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom6, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom7
    if rec_tapplcfm.codincom7 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom7);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom7, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal7, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom7, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom8
    if rec_tapplcfm.codincom8 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom8);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom8, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal8, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom8, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom9
    if rec_tapplcfm.codincom9 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom9);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom9, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal9, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom9, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    -- codincom10
    if rec_tapplcfm.codincom10 is not null then
      obj_data_row:= json_object_t();
      obj_data_row.put('coderror', '200');
      obj_data_row.put('codincom', rec_tapplcfm.codincom10);
      obj_data_row.put('desincom', get_tinexinf_name ( rec_tapplcfm.codincom10, global_v_lang));
      obj_data_row.put('unit', get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal10, global_v_lang));
      obj_data_row.put('amtincom', stddec(rec_tapplcfm.amtincom10, rec_tapplcfm.numappl, v_chken));
      obj_row.put(to_char(v_rcnt),obj_data_row);
      v_rcnt := v_rcnt+1;
    end if;
    --
    obj_data.put('coderror', '200');
    obj_data.put('codcurr', rec_tapplcfm.codcurr);
    obj_data.put('desc_codcur', rec_tapplcfm.codcurr || ' - '||get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang));
    obj_data.put('afpro', stddec(rec_tapplcfm.amtsalpro, rec_tapplcfm.numappl, v_chken));
    obj_data.put('welfare', rec_tapplcfm.welfare);
    obj_data.put('table', obj_row);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab2 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_tab3 (json_str_output out clob) as
    obj_data       json_object_t;
    obj_row        json_object_t;
    v_rcnt          number := 0;
    v_stasign       tapplcfm.stasign%type;
    v_codcomp       tapplcfm.codcomp%type;
    v_codposc       tapplcfm.codposc%type;

    rec_tapplcfm    tapplcfm%rowtype;
    cursor c1 is
      select coddoc, descdoc
        from tnempdoc
       where codcomp = v_codcomp
         and codpos = v_codposc;
  begin
    begin
      select codcomp, codposc
        into v_codcomp, v_codposc
        from tapplcfm
       where numappl = p_numappl
         and numreqrq = p_numreqrq
         and codposrq = p_codpos;
    exception when no_data_found then
      null;
    end;

    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data:= json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('coddoc', r1.coddoc);
      obj_data.put('desc_coddoc', r1.descdoc);

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt := v_rcnt+1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_tab3 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_tab3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;
  --
	procedure gen_parameter_report (json_str_output out clob) as
		cursor c1 is
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
       order by ffield ;

		obj_data		json_object_t;
		obj_row			json_object_t;
		v_rcnt			number := 0;
    v_numseq    number;
    v_value     varchar2(1000 char);
	begin
		obj_row := json_object_t();
    v_numseq := 23;
		for r1 in c1 loop
			v_rcnt := v_rcnt+1;
			obj_data := json_object_t();
			obj_data.put('coderror', '200');
      obj_data.put('codform',r1.codform);
      obj_data.put('codtable',r1.codtable);
      obj_data.put('ffield',r1.ffield);
      obj_data.put('flgdesc',r1.flgdesc);
      obj_data.put('flginput',r1.flginput);
      obj_data.put('flgstd',r1.flgstd);
      obj_data.put('fparam',r1.fparam);
      obj_data.put('numseq',r1.numseq);
      obj_data.put('section',r1.section);
      obj_data.put('descript',r1.descript);
      begin
        select datainit1 into v_value
          from tinitial
         where codapp = 'HRRC35X'
           and numseq = v_numseq;
      exception when no_data_found then
        v_value := '';
      end;
      obj_data.put('value',v_value);
			obj_row.put(to_char(v_rcnt-1),obj_data);
      v_numseq := v_numseq + 1;
		end loop;

		json_str_output := obj_row.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
  --
  procedure get_parameter_report(json_str_input in clob, json_str_output out clob) as
	begin
    initial_value(json_str_input);
		if param_msg_error is null then
			gen_parameter_report(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
  --
  procedure gen_message ( p_codform in varchar2, o_message1 out clob, o_namimglet out varchar2,
                          o_message2 out clob, o_typemsg2 out long, o_message3 out clob) is
  begin
    begin
      select message, namimglet into o_message1, o_namimglet
        from tfmrefr
       where codform = p_codform;
    exception when no_data_found then
      o_message1  := null;
      o_namimglet := null;
    end;
    begin
      select message, typemsg
        into o_message2, o_typemsg2
        from tfmrefr2
       where codform = p_codform;
    exception when no_data_found then
      o_message2 := null;
      o_typemsg2 := null;
    end;
    begin
      select message
        into o_message3
        from tfmrefr3
       where codform = p_codform;
    exception when no_data_found then
      o_message3 := null;
    end;
  end;
  --
  procedure gen_html_message (json_str_output out clob) AS

    o_message1        clob;
    o_namimglet       tfmrefr.namimglet%type;
    o_message2        clob;
    o_typemsg2        tfmrefr2.typemsg%type;
    o_message3        clob;

		obj_data		      json_object_t;
		v_rcnt			      number := 0;

    v_namimglet       tfmrefr.namimglet%type;
    tfmrefr_message   tfmrefr.message%type;
    tfmrefr2_message  tfmrefr2.message%type;
    tfmrefr2_typemsg  tfmrefr2.typemsg%type;
    tfmrefr3_message  tfmrefr3.message%type;
	begin
    gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);

    if o_namimglet is not null then
       o_namimglet := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMB9E')||'/'||o_namimglet;
    end if;
		obj_data := json_object_t();
		obj_data.put('coderror', '200');
    obj_data.put('head_html',o_message1);
    obj_data.put('body_html',o_message2);
    obj_data.put('footer_html',o_message3);
    obj_data.put('head_letter', o_namimglet);

		json_str_output := obj_data.to_clob;

	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);

	end gen_html_message;
  procedure get_html_message(json_str_input in clob, json_str_output out clob) AS
	begin
		initial_value(json_str_input);
		if param_msg_error is null then
			gen_html_message(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end get_html_message;
  --

  procedure validate_print_report(json_str_input in clob) as
		json_obj		json_object_t;
		codform			varchar2(10 char);
	begin
		json_obj      := json_object_t(json_str_input);
		global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    v_chken             := hcm_secur.get_v_chken;

    p_details     := hcm_util.get_json_t(json_object_t(json_obj),'indexSearch');
    p_data_row    := hcm_util.get_json_t(json_object_t(json_obj),'dataRows');
    p_data_fparam := hcm_util.get_json_t(json_object_t(json_obj),'fparam');
		p_url         := hcm_util.get_string_t(json_object_t(json_obj),'url');

    p_codcomp     := hcm_util.get_string_t(p_details,'codcomp');
    p_codpos      := hcm_util.get_string_t(p_details,'codpos');
    p_dtestrt     := to_date(hcm_util.get_string_t(p_details,'dteapplst'),'dd/mm/yyyy');
    p_dteend      := to_date(hcm_util.get_string_t(p_details,'dteapplen'),'dd/mm/yyyy');
    p_stasign     := hcm_util.get_string_t(p_details,'hcmhrrc35x');
	end;
  --
  procedure check_gen_report as
    v_chkdata   varchar2(10 char);
    v_codform   varchar2(100 char);
    v_numappl   varchar2(100 char);
    v_codcomp   varchar2(100 char);
    v_codcompy  varchar2(10 char);
    json_obj		json_object_t;
    itemSelected		json_object_t;
  begin
    for i in 0..p_data_row.get_size - 1 loop
      itemSelected  := hcm_util.get_json_t( p_data_row,to_char(i));
      v_codform    := hcm_util.get_string_t(itemSelected,'codform');
      v_numappl    := hcm_util.get_string_t(itemSelected,'numappl');
      if v_codform is null then
        param_msg_error := get_error_msg_php('RC0037',global_v_lang);
        return;
      end if;
      begin
				select codcomp into v_codcomp
          from tapplcfm
				 where numappl = v_numappl;
			exception when no_data_found then null;
			end;
      begin
				select codcompy into v_codcompy
          from tdocrnum
				 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and typdoc = '4';
			exception when no_data_found then
        param_msg_error := get_error_msg_php('PM0067',global_v_lang);
        return;
			end;
    end loop;
  end;
  --
    procedure check_gen_report_detail as
    v_chkdata   varchar2(10 char);
    v_codform   varchar2(100 char);
    v_numappl   varchar2(100 char);
    v_codcomp   varchar2(100 char);
    v_codcompy  varchar2(10 char);
    json_obj		json_object_t;
    itemSelected		json_object_t;
  begin
    v_codform    := hcm_util.get_string_t(p_data_row,'codform');
    v_numappl    := hcm_util.get_string_t(p_data_row,'numappl');

    if v_codform is null then
      param_msg_error := get_error_msg_php('RC0037',global_v_lang);
      return;
    end if;
    begin
      select codcomp into v_codcomp
        from tapplcfm
       where numappl = v_numappl;
    exception when no_data_found then null;
    end;
    begin
      select codcompy into v_codcompy
        from tdocrnum
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
       and typdoc = '4';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('PM0067',global_v_lang);
      return;
    end;
  end;
  --
  procedure gen_report_data ( json_str_output out clob) as
		itemSelected		json_object_t := json_object_t();

    v_codlang		    tfmrefr.codlang%type;
    v_day			      number;
    v_desc_month		varchar2(50 char);
    v_year			    varchar2(4 char);
    tdata_dteprint	varchar2(100 char);

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_numlettr      varchar2(1000 char);
    v_dteduepr      ttprobat.dteduepr%type;
    temploy1_obj		temploy1%rowtype;
    temploy3_obj		temploy3%rowtype;

    fparam_codform      varchar2(1000 char);
    fparam_codtable     varchar2(1000 char);
    fparam_ffield       varchar2(1000 char);
    fparam_flgdesc      varchar2(1000 char);
    fparam_flginput     varchar2(1000 char);
    fparam_flgstd       varchar2(1000 char);
    fparam_fparam       varchar2(1000 char);
    fparam_numseq       varchar2(1000 char);
    fparam_section      varchar2(1000 char);
    fparam_descript     varchar2(1000 char);
    fparam_value        varchar2(1000 char);

    data_file           clob;
		v_flgstd		        tfmrefr.flgstd%type;
		v_namimglet		      tfmrefr.namimglet%type;
		v_folder		        tfolderd.folder%type;
    o_message1          clob;
    o_namimglet         tfmrefr.namimglet%type;
    o_message2          clob;
    o_typemsg2          tfmrefr2.typemsg%type;
    o_message3          clob;
--    v_qtyexpand         ttprobat.qtyexpand%type;
--    v_amtinmth          ttprobat.amtinmth%type;
    p_signid            varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_namesign          varchar2(1000 char);
    v_pathimg           varchar2(1000 char);

    rec_tapplcfm        tapplcfm%rowtype;
    v_codform           tapplcfm.codform%type;
    v_numappl           tapplcfm.numappl%type;
    v_numreqrq          tapplcfm.numreqrq%type;
    v_codposrq          tapplcfm.codposrq%type;
    v_dteprint          tapplcfm.dteprint%type;
    v_numdoc            tapplcfm.numdoc%type;
    v_sysdate           varchar2(1000 char);
    v_desc_tabsal       varchar2(4000 char);
    v_sumamt            number := 0;
    type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    -- Return Data
		v_resultcol		json_object_t ;
		v_resultrow		json_object_t := json_object_t();
		v_countrow		number := 0;
		v_numseq		  number;
    v_value       varchar2(1000 char);

    obj_fparam      json_object_t := json_object_t();
    obj_rows        json_object_t;
    obj_result      json_object_t;
    v_amttotal    number;

    cursor c1 is
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
       order by ffield ;
	begin
    begin
      select get_tsetup_value('PATHWORKPHP')||folder into v_folder
        from tfolderd
       where codapp = 'HRPMB9E';
    exception when no_data_found then
			v_folder := '';
    end;
		v_codlang := nvl(v_codlang,global_v_lang);

		for i in 0..p_data_row.get_size - 1 loop
			itemSelected  := hcm_util.get_json_t( p_data_row,to_char(i));
      v_codform     := hcm_util.get_string_t(itemSelected,'codform');
      v_numappl     := hcm_util.get_string_t(itemSelected,'numappl');
      v_numreqrq    := hcm_util.get_string_t(itemSelected,'numreqrq');
      v_codposrq    := hcm_util.get_string_t(itemSelected,'codpos');
      v_numdoc      := hcm_util.get_string_t(itemSelected,'numdoc');
      v_dteprint    := to_date(hcm_util.get_string_t(itemSelected,'dteprint'),'dd/mm/yyyy');

      p_codform := v_codform;
      begin
        select *
          into rec_tapplcfm
          from tapplcfm
         where numappl = v_numappl
           and numreqrq = v_numreqrq
           and codposrq = v_codposrq;
      exception when no_data_found then
        null;
      end;
      if v_numdoc is null then
        v_numdoc := get_docnum('4',hcm_util.get_codcomp_level(rec_tapplcfm.codcomp,1),global_v_lang);
--        begin
--          update ttprobat
--             set numlettr = v_numlettr
--           where codempid = v_codempid
--             and dteduepr = v_dteduepr;
--        end;
      end if;
        -- Read Document HTML
        gen_message(v_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
				list_msg_html := html_array(o_message1,o_message2,o_message3);

        v_day         := to_number(to_char(sysdate,'dd'),'99');
        v_desc_month  := get_nammthful(to_number(to_char(sysdate,'mm')),v_codlang);
        v_year        := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(sysdate,'yyyy')));
        v_sysdate := v_day ||' '||v_desc_month||' '||v_year;
				for i in 1..3 loop
					data_file := list_msg_html(i);
--          data_file := std_replace(data_file,p_codform,i,itemSelected, v_numappl, v_numreqrq, v_codposrq );
          data_file := std_replace_exist(data_file, v_numappl, v_numreqrq, v_codposrq );
          data_file := replace(data_file,'[PARAM-DOCID]', v_numdoc);
					data_file := replace(data_file,'[PARAM-DATE]', v_sysdate);
          v_amttotal  := stddec(rec_tapplcfm.amttotal,rec_tapplcfm.numappl,v_chken);
          data_file := replace(data_file,'[PARAM-AMTNET]', to_char(v_amttotal,'fm9,999,990.00'));
          data_file := replace(data_file,'[PARAM-BAHTNET]', get_amount_name(v_amttotal,v_codlang));

          --
          v_sumamt := stddec(rec_tapplcfm.amtincom2,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom3,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom4,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom5,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom6,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom7,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom8,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom9,rec_tapplcfm.numappl,v_chken) +
                      stddec(rec_tapplcfm.amtincom10,rec_tapplcfm.numappl,v_chken);
          data_file := replace(data_file,'[PARAM-AMTOTH]', v_sumamt);
          data_file := replace(data_file,'[PARAM-BAHTOTH]', get_amount_name(v_sumamt,v_codlang));
          --
          data_file := replace(data_file,'[PARAM-COMPANY]', get_tcenter_name(rec_tapplcfm.codcomp, global_v_lang));
          -- codincom1
          v_desc_tabsal := '';
          if rec_tapplcfm.codincom1 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom1, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom1, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom2
          if rec_tapplcfm.codincom2 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom2, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom2, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom3
          if rec_tapplcfm.codincom3 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom3, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom3, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom4
          if rec_tapplcfm.codincom4 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom4, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom4, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom5
          if rec_tapplcfm.codincom5 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom5, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom5, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom6
          if rec_tapplcfm.codincom6 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom6, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom6, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom7
          if rec_tapplcfm.codincom7 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom7, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom7, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom8
          if rec_tapplcfm.codincom8 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom8, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom8, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom9
          if rec_tapplcfm.codincom9 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom9, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom9, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;
          -- codincom10
          if rec_tapplcfm.codincom10 is not null then
            v_desc_tabsal := v_desc_tabsal || '' ||
                             get_tinexinf_name ( rec_tapplcfm.codincom10, global_v_lang)|| ' ' ||
                             get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                             to_char(stddec(rec_tapplcfm.amtincom10, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                             get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
          end if;

					data_file := replace(data_file,'[PARAM-TABSAL]', v_desc_tabsal);
          --
          v_numseq := 23;
          for r1 in c1 loop
            begin
              select datainit1 into v_value
                from tinitial
               where codapp = 'HRRC35X'
                 and numseq = v_numseq;
            exception when no_data_found then
              v_value := '';
            end;
            v_numseq := v_numseq + 1;
            --
            fparam_fparam   := r1.fparam;
            fparam_numseq   := r1.numseq;
            fparam_section  := r1.section;
            fparam_value    := v_value;

            if fparam_fparam = '[PARAM-SIGNID]' then
              begin
                select get_temploy_name(codempid,global_v_lang) into v_namesign
                  from temploy1
                 where codempid = fparam_value;
                fparam_value := v_namesign;

              exception when no_data_found then
                null;
              end;
            end if;
            if fparam_fparam = '[PARAM-SIGNPIC]' then
              begin
                select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E2') || '/' ||NAMSIGN
                into p_signpic
                from TEMPIMGE
                 where codempid = fparam_value;
                if p_signpic is not null then
                  fparam_value := '<img src="'||p_url||'/'||p_signpic||'"width="100" height="60">';
                else
                  fparam_value := '';
                end if;
              exception when no_data_found then null;
              end ;
            end if;
            data_file := replace(data_file, fparam_fparam, fparam_value);
          end loop;
          data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
          data_file := replace(data_file, chr(9), '&nbsp;');
          list_msg_html(i) := data_file;
        end loop;
        begin
          select codlang,namimglet,flgstd into v_codlang, v_namimglet,v_flgstd
          from tfmrefr
          where codform = v_codform;
        exception when no_data_found then
          v_codlang := global_v_lang;
        end;
        v_resultcol		:= json_object_t ();
--
        v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
        v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
        v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
        if v_namimglet is not null then
          v_pathimg := v_folder||'/'||v_namimglet;
        end if;
        v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
--
        v_resultcol.put('numdoc',v_numdoc);
        v_resultrow.put(to_char(v_countrow), v_resultcol);
--
        v_countrow := v_countrow + 1;
    end loop; -- end of loop data

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numdoc',v_numdoc);
    obj_result.put('table',v_resultrow);

    json_str_output := obj_result.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end gen_report_data;
  --
  procedure gen_report_detail ( json_str_output out clob) as
		itemSelected		json_object_t := json_object_t();

    v_codlang		    tfmrefr.codlang%type;
    v_day			      number;
    v_desc_month		varchar2(50 char);
    v_year			    varchar2(4 char);
    tdata_dteprint	varchar2(100 char);

    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_numlettr      varchar2(1000 char);
    v_dteduepr      ttprobat.dteduepr%type;
    temploy1_obj		temploy1%rowtype;
    temploy3_obj		temploy3%rowtype;

    fparam_codform      varchar2(1000 char);
    fparam_codtable     varchar2(1000 char);
    fparam_ffield       varchar2(1000 char);
    fparam_flgdesc      varchar2(1000 char);
    fparam_flginput     varchar2(1000 char);
    fparam_flgstd       varchar2(1000 char);
    fparam_fparam       varchar2(1000 char);
    fparam_numseq       varchar2(1000 char);
    fparam_section      varchar2(1000 char);
    fparam_descript     varchar2(1000 char);
    fparam_value        varchar2(1000 char);

    data_file           clob;
		v_flgstd		        tfmrefr.flgstd%type;
		v_namimglet		      tfmrefr.namimglet%type;
		v_folder		        tfolderd.folder%type;
    o_message1          clob;
    o_namimglet         tfmrefr.namimglet%type;
    o_message2          clob;
    o_typemsg2          tfmrefr2.typemsg%type;
    o_message3          clob;
--    v_qtyexpand         ttprobat.qtyexpand%type;
--    v_amtinmth          ttprobat.amtinmth%type;
    p_signid            varchar2(1000 char);
    p_signpic           varchar2(1000 char);
    v_namesign          varchar2(1000 char);
    v_pathimg           varchar2(1000 char);

    rec_tapplcfm        tapplcfm%rowtype;
    v_codform           tapplcfm.codform%type;
    v_numappl           tapplcfm.numappl%type;
    v_numreqrq          tapplcfm.numreqrq%type;
    v_codposrq          tapplcfm.codposrq%type;
    v_dteprint          tapplcfm.dteprint%type;
    v_numdoc            tapplcfm.numdoc%type;
    v_sysdate           varchar2(1000 char);
    v_desc_tabsal       varchar2(4000 char);
    v_sumamt            number := 0;
    v_desc_sumamt       varchar2(4000 char);
    type html_array   is varray(3) of clob;
		list_msg_html     html_array;
    -- Return Data
		v_resultcol		json_object_t ;
		v_resultrow		json_object_t := json_object_t();
		v_countrow		number := 0;
		v_numseq		  number;
    v_value       varchar2(1000 char);

    obj_fparam      json_object_t := json_object_t();
    obj_rows        json_object_t;
    obj_result      json_object_t;
    v_amttotal      number;
    cursor c1 is
      select *
        from tfmparam
       where codform = p_codform
         and flginput = 'Y'
       order by ffield ;
	begin
    begin
      select get_tsetup_value('PATHWORKPHP')||folder into v_folder
        from tfolderd
       where codapp = 'HRPMB9E';
    exception when no_data_found then
			v_folder := '';
    end;
		v_codlang := nvl(v_codlang,global_v_lang);

    v_codform     := hcm_util.get_string_t(p_data_row,'codform');
    v_numappl     := hcm_util.get_string_t(p_data_row,'numappl');
    v_numreqrq    := hcm_util.get_string_t(p_data_row,'numreqrq');
    v_codposrq    := hcm_util.get_string_t(p_data_row,'codpos');
    v_numdoc      := hcm_util.get_string_t(p_data_row,'numdoc');
    v_dteprint    := to_date(hcm_util.get_string_t(p_data_row,'dteprint'),'dd/mm/yyyy');

    p_codform := v_codform;
    begin
      select *
        into rec_tapplcfm
        from tapplcfm
       where numappl = v_numappl
         and numreqrq = v_numreqrq
         and codposrq = v_codposrq;
    exception when no_data_found then
      null;
    end;
    if v_numdoc is null then
      v_numdoc := get_docnum('4',hcm_util.get_codcomp_level(rec_tapplcfm.codcomp,1),global_v_lang);
      begin
        update tapplcfm
           set numdoc = v_numdoc,
               codform = p_codform,
               dteprint = sysdate
         where numappl = v_numappl
           and numreqrq = v_numreqrq
           and codposrq = v_codposrq;
      end;
      begin
        update tapplinf
           set numdoc = v_numdoc
         where numappl = v_numappl;
      end;      
    end if;
    -- Read Document HTML
    gen_message(v_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
    list_msg_html := html_array(o_message1,o_message2,o_message3);

    v_day         := to_number(to_char(sysdate,'dd'),'99');
    v_desc_month  := get_nammthful(to_number(to_char(sysdate,'mm')),v_codlang);
    v_year        := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(sysdate,'yyyy')));
    v_sysdate := v_day ||' '||v_desc_month||' '||v_year;
    begin
      delete tapplcfmd
       where numappl = v_numappl
         and numreqrq = v_numreqrq
         and codposrq = v_codposrq;
    end;
    for i in 1..3 loop
      data_file := list_msg_html(i);
      data_file := std_replace(data_file, p_codform,i,p_data_row ,v_numappl , v_numreqrq , v_codposrq );
--      data_file := std_replace_exist(data_file, v_numappl, v_numreqrq, v_codposrq );

      data_file := replace(data_file,'[PARAM-DOCID]', v_numdoc);
      data_file := replace(data_file,'[PARAM-DATE]', v_sysdate);
      v_amttotal  := stddec(rec_tapplcfm.amttotal,rec_tapplcfm.numappl,v_chken);
      data_file := replace(data_file,'[PARAM-AMTNET]', to_char(v_amttotal,'fm9,999,990.00'));
      data_file := replace(data_file,'[PARAM-BAHTNET]', get_amount_name(v_amttotal,v_codlang));
      --
      v_sumamt := stddec(rec_tapplcfm.amtincom2,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom3,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom4,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom5,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom6,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom7,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom8,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom9,rec_tapplcfm.numappl,v_chken) +
                  stddec(rec_tapplcfm.amtincom10,rec_tapplcfm.numappl,v_chken);
      if v_sumamt < 0 then
        v_desc_sumamt :=  get_amount_name(v_sumamt,v_codlang);
      end if;
      data_file := replace(data_file,'[PARAM-AMTOTH]', v_sumamt);
      data_file := replace(data_file,'[PARAM-BAHTOTH]', v_desc_sumamt);
      data_file := replace(data_file,'[PARAM-COMPANY]', get_tcenter_name(rec_tapplcfm.codcomp, global_v_lang));

      -- codincom1
      v_desc_tabsal := '';
      if rec_tapplcfm.codincom1 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom1, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom1, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom2
      if rec_tapplcfm.codincom2 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom2, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom2, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom3
      if rec_tapplcfm.codincom3 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom3, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom3, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom4
      if rec_tapplcfm.codincom4 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom4, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom4, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom5
      if rec_tapplcfm.codincom5 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom5, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom5, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom6
      if rec_tapplcfm.codincom6 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom6, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom6, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom7
      if rec_tapplcfm.codincom7 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom7, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom7, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom8
      if rec_tapplcfm.codincom8 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom8, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom8, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom9
      if rec_tapplcfm.codincom9 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom9, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom9, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;
      -- codincom10
      if rec_tapplcfm.codincom10 is not null then
        v_desc_tabsal := v_desc_tabsal || '' ||
                         get_tinexinf_name ( rec_tapplcfm.codincom10, global_v_lang)|| ' ' ||
                         get_label_name('HRRC35XC1', global_v_lang, 160) || ' ' ||
                         to_char(stddec(rec_tapplcfm.amtincom10, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')|| ' ' ||
                         get_tcodec_name('TCODCURR',rec_tapplcfm.codcurr, global_v_lang)||'<br>';
      end if;

      data_file := replace(data_file,'[PARAM-TABSAL]', v_desc_tabsal);
      --
      for j in 0..p_data_fparam.get_size - 1 loop
        obj_fparam      := hcm_util.get_json_t( p_data_fparam,to_char(j));
        fparam_fparam   := hcm_util.get_string_t(obj_fparam,'fparam');
        fparam_numseq   := hcm_util.get_string_t(obj_fparam,'numseq');
        fparam_section  := hcm_util.get_string_t(obj_fparam,'section');
        fparam_value    := hcm_util.get_string_t(obj_fparam,'value');
        if fparam_fparam = '[PARAM-SIGNID]' then
          begin
            select get_temploy_name(codempid,global_v_lang) into v_namesign
              from temploy1
             where codempid = fparam_value;
            fparam_value := v_namesign;

          exception when no_data_found then
            null;
          end;
        end if;
        if fparam_fparam = '[PARAM-SIGNPIC]' then
          begin
            select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E2') || '/' ||NAMSIGN
            into p_signpic
            from TEMPIMGE
             where codempid = fparam_value;
             if p_signpic is not null then
              fparam_value := '<img src="'||p_url||'/'||p_signpic||'"width="100" height="60">';
            else
              fparam_value := '';
            end if;
          exception when no_data_found then null;
          end ;
        end if;
        data_file := replace(data_file, fparam_fparam, fparam_value);
      end loop;
      
      data_file := replace(data_file, rec_tapplcfm.amtincom1, to_char(stddec(rec_tapplcfm.amtincom1, rec_tapplcfm.numappl, v_chken),'fm999,999,990.00')); -- softberry || 29/03/2023 || #9249
      
      data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
      data_file := replace(data_file, chr(9), '&nbsp;');
      list_msg_html(i) := data_file;
    end loop;
    begin
      select codlang,namimglet,flgstd into v_codlang, v_namimglet,v_flgstd
      from tfmrefr
      where codform = v_codform;
    exception when no_data_found then
      v_codlang := global_v_lang;
    end;
    v_resultcol		:= json_object_t ();
    v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
    v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
    v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
    if v_namimglet is not null then
      v_pathimg := v_folder||'/'||v_namimglet;
    end if;
    v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
    v_resultcol.put('numdoc',v_numdoc);
    v_resultrow.put(to_char(v_countrow), v_resultcol);
    v_countrow := v_countrow + 1;

    obj_result :=  json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('numdoc',v_numdoc);
    obj_result.put('table',v_resultrow);

    json_str_output := obj_result.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t is
    v_convert_json_to_clob   clob;
    v_new_json_clob          clob;
    v_summany_json_clob      clob;
    v_size number;
  begin
    v_size := v_original_json.get_size;

    if ( v_size = 0 ) then
      v_summany_json_clob := '{';
    else
      v_convert_json_to_clob :=  v_original_json.to_clob;
      v_summany_json_clob := substr(v_convert_json_to_clob,1,length(v_convert_json_to_clob) -1) ;
      v_summany_json_clob := v_summany_json_clob || ',' ;
    end if;

    v_new_json_clob :=  v_summany_json_clob || '"' ||v_key|| '"' || ' : '|| '"' ||esc_json(v_value)|| '"' ||  '}';

    return json_object_t (v_new_json_clob);
  end;
  function esc_json(message in clob)return clob is
    v_message clob;

    v_result  clob := '';
    v_char varchar2 (2 char);
  BEGIN
    v_message := message ;
    if (v_message is null) then
      return v_result;
    end if;

    for i in 1..length(v_message) loop
      v_char := SUBSTR(v_message,i,1);

      if (v_char = '"') then
          v_char := '\"' ;
      elsif (v_char = '/') then
          v_char := '\/' ;
      elsif (v_char = '\') then
          v_char := '\\' ;
      elsif (v_char =  chr(8) ) then
          v_char := '\b' ;
      elsif (v_char = chr(12) ) then
          v_char := '\b' ;
      elsif (v_char = chr(10)) then
          v_char :=  '\n' ;
      elsif (v_char = chr(13)) then
          v_char :=  '\r' ;
      elsif (v_char = chr(9)) then
          v_char :=  '\t' ;
      end if ;
      v_result := v_result||v_char;
    end loop;
    return v_result;
  end esc_json;
  --
  function std_replace(p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t,
                       v_numappl in varchar2, v_numreqrq in varchar2, v_codposrq in varchar2 ) return clob is
    v_statmt		    long;
    v_statmt_sub		long;

    v_message 	    clob;
    obj_json 	      json_object_t := json_object_t();
    v_codtable      tcoldesc.codtable%type;
    v_codcolmn      tcoldesc.codcolmn%type;
    v_codlang       tfmrefr.codlang%type;

    v_funcdesc      tcoldesc.funcdesc%type;
    v_flgchksal     tcoldesc.flgchksal%type;

    v_dataexct      varchar(1000);
    v_day           varchar(1000);
    v_month         varchar(1000);
    v_year          varchar(1000);
    v_numseq        number := 0;
    arr_result      arr_1d;
    cursor c1 is
      select fparam,ffield,descript,a.codtable,fwhere,
             'select '||ffield||' from '||a.codtable ||' where '||fwhere stm ,flgdesc
                from tfmtable a,tfmparam b ,tfmrefr c
                where b.codform  = c.codform
                  and a.codapp   = c.typfm
                  and a.codtable = b.codtable
                  and b.flgstd   = 'N'
                  and b.section = p_section
                  and nvl(b.flginput,'N') <> 'Y'
                  and b.codform  = p_codform
                 order by b.numseq;
  begin
    v_message := p_message;
    begin
      select codlang
        into v_codlang
        from tfmrefr
       where codform = p_codform;
    exception when no_data_found then
      v_codlang := global_v_lang;
    end;
    v_codlang := nvl(v_codlang,global_v_lang);
    for i in c1 loop
      v_codtable := i.codtable;
      v_codcolmn := i.ffield;
      /* find description sql */
      begin
        select funcdesc ,flgchksal into v_funcdesc,v_flgchksal
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
          v_funcdesc := null;
          v_flgchksal:= 'N' ;
      end;
      if nvl(i.flgdesc,'N') = 'N' then
        v_funcdesc := null;
      end if;
      if v_flgchksal = 'Y' then
         v_statmt  := 'select to_char(stddec('||i.ffield||','||''''||hcm_util.get_string_t(p_itemson,'codempid')||''''||','||''''||hcm_secur.get_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where '||i.fwhere ;
      elsif v_funcdesc is not null then
        v_statmt_sub := std_get_value_replace(i.stm, p_itemson, v_codtable);
        v_statmt_sub := execute_desc(v_statmt_sub);
        v_funcdesc := replace(v_funcdesc,'P_CODE',''''||v_statmt_sub||'''') ;
        v_funcdesc := replace(v_funcdesc,'P_LANG',''''||v_codlang||'''') ;
        v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
        v_funcdesc := replace(v_funcdesc,'P_TEXT',hcm_secur.get_v_chken) ;
        v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where '||i.fwhere ;
      else
         v_statmt  := i.stm ;
      end if;
      if get_item_property(v_codtable,v_codcolmn) = 'DATE' then
        if nvl(i.flgdesc,'N') = 'N' then
          v_statmt := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where '||i.fwhere;
          v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
          v_dataexct := execute_desc(v_statmt);
        else
          v_statmt := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where '||i.fwhere;
          v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
          v_dataexct := execute_desc(v_statmt);

          if v_dataexct is not null then
            arr_result := explode('/', v_dataexct, 3);
            v_day := arr_result(1);
            v_month := arr_result(2);
            v_year := arr_result(3);
          end if;
          v_dataexct := to_number(v_day) ||' '||
                        get_label_name('HRPM55R2',global_v_lang,220) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' ||
                        get_label_name('HRPM55R2',global_v_lang,230) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
        end if;
      else
        v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
        v_dataexct := execute_desc(v_statmt);
      end if;

      begin
        select nvl(max(numseq),0) + 1 into v_numseq
          from tapplcfmd
         where numappl = v_numappl
           and numreqrq = v_numreqrq
           and codposrq = v_codposrq;
      end;
      insert into tapplcfmd(numappl, numreqrq, codposrq, numseq, fparam, fvalue, codcreate, coduser)
                     values(v_numappl, v_numreqrq, v_codposrq, v_numseq, i.fparam, v_dataexct, global_v_coduser, global_v_coduser);

      v_message := replace(v_message,i.fparam,v_dataexct);
    end loop; -- loop main

    return v_message;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end std_replace;
  --
  function std_replace_exist(p_message in clob, v_numappl in varchar2, v_numreqrq in varchar2, v_codposrq in varchar2 ) return clob is
    v_statmt		    long;
    v_statmt_sub		long;

    v_message 	    clob;
    obj_json 	      json_object_t := json_object_t();
    v_codtable      tcoldesc.codtable%type;
    v_codcolmn      tcoldesc.codcolmn%type;
    v_codlang       tfmrefr.codlang%type;

    v_funcdesc      tcoldesc.funcdesc%type;
    v_flgchksal     tcoldesc.flgchksal%type;

    v_dataexct      varchar(1000);
    v_day           varchar(1000);
    v_month         varchar(1000);
    v_year          varchar(1000);
    arr_result      arr_1d;
    cursor c1 is
      select fparam,fvalue
        from tapplcfmd
       where numappl = v_numappl
         and numreqrq = v_numreqrq
         and codposrq = v_codposrq;
  begin
    v_message := p_message;
    begin
      select codlang
        into v_codlang
        from tfmrefr
       where codform = p_codform;
    exception when no_data_found then
      v_codlang := global_v_lang;
    end;
    v_codlang := nvl(v_codlang,global_v_lang);

    for i in c1 loop
      v_message := replace(v_message,i.fparam,i.fvalue);
    end loop; -- loop main

    return v_message;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
	begin
		if ( hcm_util.get_string_t(objItem,bykey) = null or hcm_util.get_string_t(objItem,bykey) = ' ') then
			return '';
		else
			return hcm_util.get_string_t(objItem,bykey);
		end if;
	end name_in ;
  --
  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t , v_codtable in varchar2) return long is
    v_statmt		long;
    v_itemson  json_object_t;
    v_item_field_original    varchar2(500 char);
    v_item			varchar2(500 char);
    v_value     varchar2(500 char);
  begin
    v_statmt  := v_in_statmt;
    v_itemson := p_in_itemson;
    loop
      v_item    := substr(v_statmt,instr(v_statmt,'[') +1,(instr(v_statmt,']') -1) - instr(v_statmt,'['));
      v_item_field_original := v_item;
      v_item     :=   substr(v_item, instr(v_item,'.')+1);
      exit when v_item is null;

      v_value := name_in(v_itemson , lower(v_item));

      if get_item_property(v_codtable,v_item) = 'DATE' then
        v_value   := 'to_date('''||to_char(to_date(v_value),'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ;
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      else
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      end if;
     end loop;
    return v_statmt;
  end std_get_value_replace;
  --
  function get_item_property (p_table in VARCHAR2,p_field in VARCHAR2) return varchar2 is
		valueDataType json_object_t := json_object_t();

		cursor c_datatype is
      select t.data_type as DATATYPE
        from user_tab_columns t
       where t.TABLE_NAME = p_table
         and t.COLUMN_NAME = substr(p_field, instr(p_field,'.')+1);
	begin
		for i in c_datatype loop
			valueDataType.put('DATATYPE',i.DATATYPE);
		end loop;
		return hcm_util.get_string_t(valueDataType,'DATATYPE');
	end get_item_property;
  --
  procedure print_report(json_str_input in clob, json_str_output out clob) as
	begin
		validate_print_report(json_str_input);
    check_gen_report;
		if (param_msg_error is null or param_msg_error = ' ' ) then
      gen_report_data(json_str_output);
      if (param_msg_error is not null) then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
  --
  procedure print_report_detail(json_str_input in clob, json_str_output out clob) as
	begin
		validate_print_report(json_str_input);
    check_gen_report_detail;
		if (param_msg_error is null or param_msg_error = ' ' ) then
      gen_report_detail(json_str_output);
      if (param_msg_error is not null) then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;
  --
  procedure send_mail(json_str_input in clob, json_str_output out clob) AS
    json_obj        json_object_t;
    data_obj        json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_msg_to        clob;
    v_templete_to   clob;
    v_numappl       tapplcfmd.numappl%type;
    v_numreqrq      tapplcfmd.numreqrq%type;
    v_codposrq      tapplcfmd.codposrq%type;
    v_subject       tfrmmail.descode%type;
    v_rowid         varchar2(200);
    v_codform       tfwmailh.codform%TYPE := 'HRRC35XTO';
    v_send_success  varchar2(1) := 'N';
    v_email         tapplinf.email%type;
    v_codappr       temploy1.codempid%type;
    v_sender        temploy1.email%type;
    v_errorno       varchar2(4000);
    v_namemp        tapplinf.namempe%type;
    v_reportname    varchar2(200);
    v_url           varchar2(1000);
    v_typefile      varchar2(50);
    v_path_file     varchar2(2000);
    v_staresp       varchar2(10);
  begin
    initial_value(json_str_input);
    param_msg_error     := '';
    json_obj            := json_object_t(json_str_input);
    v_reportname        := hcm_util.get_string_t(json_obj,'reportname');
    v_url               := hcm_util.get_string_t(json_obj,'url');
    v_typefile          := hcm_util.get_string_t(json_obj,'typefile');
    v_path_file         := v_url||get_tsetup_value('PATHWORKPHP')||v_reportname||'.'||v_typefile;
    v_staresp           := hcm_util.get_string_t(json_obj,'staresp');

    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    chk_flowmail.get_message_result(v_codform, global_v_lang, v_msg_to, v_templete_to);
    begin
      select decode(global_v_lang,'101',messagee,
                                  '102',messaget,
                                  '103',message3,
                                  '104',message4,
                                  '105',message5,
                                  '101',messagee) msg
        into v_templete_to
        from tfrmmail
     where codform = 'TEMPLATE' ;
    exception when others then
      v_templete_to := null ;
    end ;

    if v_staresp = 'Y' then
      v_subject   := get_label_name('HRRC35XC1',global_v_lang,810);
      v_codform   := 'HRRC35XTO';
    else
      v_subject   := get_label_name('HRRC35XC1',global_v_lang,820);
      v_codform   := 'HRRC35XNO';
    end if;
--    for i in 0..param_json.get_size - 1 loop
--			param_json_row  := hcm_util.get_json_t( param_json,to_char(i));
      v_numappl       := hcm_util.get_string_t(param_json,'numappl');
      v_numreqrq      := hcm_util.get_string_t(param_json,'numreqrq');
      v_codposrq      := hcm_util.get_string_t(param_json,'codpos');
      begin
        select rowid, codappr
          into v_rowid, v_codappr
          from tapplcfm
         where numappl    = v_numappl
           and numreqrq   = v_numreqrq
           and (
            (stasign = 'Y' and codposrq = v_codposrq) or
            (stasign = 'N' and codposc = v_codposrq)
           )
           and rownum     = 1;
      exception when no_data_found then
        v_rowid   := null;
        v_codappr := null;
      end;
      --
      begin
        select email
          into v_sender
          from temploy1
--         where codempid = v_codappr;
         where codempid = get_codempid(global_v_coduser);
      exception when no_data_found then
        v_email   := null;
      end;
      --
      begin
        select email,
               decode(global_v_lang, '101', namempe
                                   , '102', namempt
                                   , '103', namemp3
                                   , '104', namemp4
                                   , '105', namemp5
                                   , namempe)
          into v_email, v_namemp
          from tapplinf
         where numappl    = v_numappl;
      exception when no_data_found then
        v_email   := null;
      end;

      v_msg_to    := replace(v_msg_to,'[PARAM-TO]',v_namemp);
      chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPLCFM', v_rowid, v_subject, v_codform, '1', null, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N',p_file => v_reportname);
      v_errorno   := sendmail_attachfile(v_sender,v_email,v_subject,v_msg_to,v_path_file,null,null,null,null);
      if param_msg_error is null then
        v_send_success  := 'Y';
      end if;
--    end loop;

    if v_send_success = 'Y' then
      param_msg_error := get_error_msg_php('HR2046',global_v_lang);
    else
      param_msg_error := get_error_msg_php(v_errorno,global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrrc35x;

/

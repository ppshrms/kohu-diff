--------------------------------------------------------
--  DDL for Package Body HRES36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES36E" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'ddmmyyyy');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj, 'p_dtereq'), 'ddmmyyyy');
    p_dtereq2save       := to_date(hcm_util.get_string_t(json_obj, 'dtereq'), 'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'numseq');
    p_desnote           := hcm_util.get_string_t(json_obj, 'desnote');
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 p_flginc            := hcm_util.get_string_t(json_obj, 'flginc');
    p_dteuse            := to_date(hcm_util.get_string_t(json_obj, 'dteuse'), 'dd/mm/yyyy');
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 p_codtypcrt         := hcm_util.get_string_t(json_obj, 'codtypcrt');
    p_codform           := hcm_util.get_string_t(json_obj, 'codform');--User37 NXP-HR2101 #6370 ST11 28/07/2021 
    p_staappr           := hcm_util.get_string_t(json_obj, 'staappr');
    p_travel_period     := hcm_util.get_string_t(json_obj, 'travel_period');
    p_country           := hcm_util.get_string_t(json_obj, 'country');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;

    cursor cl is
      select dtereq, staappr, numcerti, remarkap, codappr, /*User37 NXP-HR2101 #6370 ST11 28/07/2021 flginc,*/ desnote, numseq, codempid, approvno
        from trefreq
       where codempid = global_v_codempid
         and dtereq between p_dtestrt and p_dteend
       order by dtereq desc, numseq desc;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
      obj_data.put('numseq', to_char(r1.numseq));
      obj_data.put('staappr', r1.staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', r1.staappr, global_v_lang));
      obj_data.put('numcerti', r1.numcerti);
      obj_data.put('remarkap', replace(r1.remarkap, chr(13) || chr(10), ' '));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', r1.codappr || ' ' || get_temploy_name(r1.codappr, global_v_lang));
      obj_data.put('codempap', chk_workflow.get_next_approve('HRES36E', r1.codempid, to_char(r1.dtereq, 'dd/mm/yyyy'), r1.numseq, r1.approvno, global_v_lang));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    -- check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data           json_object_t;
    v_desnote          trefreq.desnote%type;
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 v_flginc           trefreq.flginc%type;
    v_dteuse           trefreq.dteuse%type;
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 v_codtypcrt        trefreq.typcertif%type;
    v_codform          trefreq.codform%type;--User37 NXP-HR2101 #6370 ST11 28/07/2021 
    v_staappr          trefreq.staappr%type;
    v_travel_period    trefreq.travel_period%type;
    v_country          trefreq.country%type;

  begin
    begin
      select desnote,
             --User37 NXP-HR2101 #6370 ST11 28/07/2021 flginc,
             dteuse,
             --User37 NXP-HR2101 #6370 ST11 28/07/2021 typcertif,
             codform,--User37 NXP-HR2101 #6370 ST11 28/07/2021 
             staappr,
             travel_period,
             country
        into v_desnote,
             --User37 NXP-HR2101 #6370 ST11 28/07/2021 v_flginc,
             v_dteuse,
             --User37 NXP-HR2101 #6370 ST11 28/07/2021 v_codtypcrt,
             v_codform,--User37 NXP-HR2101 #6370 ST11 28/07/2021 
             v_staappr,
             v_travel_period,
             v_country
      from trefreq
      where codempid = global_v_codempid
        and dtereq   = p_dtereq
        and numseq   = p_numseq;
    exception when no_data_found then
      null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
    obj_data.put('numseq', p_numseq);
    obj_data.put('desnote', v_desnote);
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 obj_data.put('flginc', v_flginc);
    obj_data.put('dteuse', to_char(v_dteuse, 'dd/mm/yyyy'));
    --User37 NXP-HR2101 #6370 ST11 28/07/2021 obj_data.put('codtypcrt', v_codtypcrt);
    obj_data.put('codform', v_codform);--User37 NXP-HR2101 #6370 ST11 28/07/2021 
    obj_data.put('staappr', v_staappr);
    obj_data.put('travel_period', v_travel_period);
    obj_data.put('country', v_country);

    json_str_output := obj_data.to_clob;
  end gen_detail;

  function gen_numseq(v_dtereq date) return number is
    v_numseq        trefreq.numseq%type;
  begin
    begin
      select (nvl(max(numseq), 0) + 1) numseq
        into v_numseq
        from trefreq
       where codempid = global_v_codempid
         and dtereq   = v_dtereq;
    exception when others then
      null;
    end;
    return v_numseq;
  end gen_numseq;

  procedure get_numseq (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtereq', to_char(p_dtereq, 'dd/mm/yyyy'));
      obj_data.put('dteuse', to_char(sysdate, 'dd/mm/yyyy'));
      obj_data.put('numseq', gen_numseq(p_dtereq));

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_numseq;

  procedure check_save is
    v_numseq      trefreq.numseq%type;
    v_chk         varchar2(1) := 'N';--User37 NXP-HR2101 #6370 ST11 28/07/2021  
  begin
    if trunc(p_dteuse) < trunc(p_dtereq2save) then
      param_msg_error := get_error_msg_php('HR2051', global_v_lang);
      return;
    end if;
    if p_numseq is null then
      p_numseq := gen_numseq(p_dtereq2save);
    end if;
    --<<User37 NXP-HR2101 #6370 ST11 28/07/2021  
    if p_codform is not null then
      begin
        select 'Y'
          into v_chk
          from tfmrefr 
         where typfm = 'HRPM55R'
           and codform = p_codform;
      end;
      if v_chk = 'N' then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'tfmrefr');
        return;
      end if;
    end if;
    -->>User37 NXP-HR2101 #6370 ST11 28/07/2021  
  end check_save;

  procedure save_trefreq AS
    v_codcomp     temploy1.codcomp%type;
  begin
    v_codcomp := hcm_util.get_temploy_field(global_v_codempid, 'codcomp');
    begin
      --<<User37 NXP-HR2101 #6370 ST11 28/07/2021 
      /*insert into trefreq (codempid, numseq, dtereq, numcerti,
                          codappr, staappr, codcomp, remarkap,
                          dteuse, dteappr, flgagency, codform,
                          routeno, 
                          flgsend, dtecancel, dteinput, dtesnd,
                          dteupd, coduser, dteapph, flginc,
                          desnote, typcertif, travel_period, country, approvno)
                  values (global_v_codempid, p_numseq, p_dtereq2save, null,
                          p_codappr, p_staappr, v_codcomp, p_remarkap,
                          p_dteuse, p_dteappr, null, null,
                          p_routeno, 
                          'N', p_dtecancel, sysdate, null,
                          trunc(sysdate), global_v_coduser, sysdate, p_flginc,
                          p_desnote, p_codtypcrt, p_travel_period, p_country, p_approvno);*/
      insert into trefreq (codempid, numseq, dtereq, numcerti,
                          codappr, staappr, codcomp, remarkap,
                          dteuse, dteappr, flgagency, codform,
                          routeno, 
                          flgsend, dtecancel, dteinput, dtesnd,
                          dteupd, coduser, dteapph, 
                          desnote, travel_period, country, approvno)
                  values (global_v_codempid, p_numseq, p_dtereq2save, null,
                          p_codappr, p_staappr, v_codcomp, p_remarkap,
                          p_dteuse, p_dteappr, null, p_codform,
                          p_routeno, 
                          'N', p_dtecancel, sysdate, null,
                          trunc(sysdate), global_v_coduser, sysdate, 
                          p_desnote, p_travel_period, p_country, p_approvno);
      -->>User37 NXP-HR2101 #6370 ST11 28/07/2021 
      exception when dup_val_on_index then
        update trefreq
           set numcerti      = null,
               codappr       = p_codappr,
               staappr       = p_staappr,
               codcomp       = v_codcomp,
               remarkap      = p_remarkap,
               dteuse        = p_dteuse,
               dteappr       = p_dteappr,
               flgagency     = null,
               codform       = p_codform,--User37 NXP-HR2101 #6370 ST11 28/07/2021 null,
               routeno       = p_routeno,

               flgsend       = null,
               dtecancel     = p_dtecancel,
               dteinput      = sysdate,
               dtesnd        = null,
               dteupd        = trunc(sysdate),
               coduser       = global_v_coduser,
               dteapph       = sysdate,
               --User37 NXP-HR2101 #6370 ST11 28/07/2021 flginc        = p_flginc,
               desnote       = p_desnote,
               --User37 NXP-HR2101 #6370 ST11 28/07/2021 typcertif     = p_codtypcrt,
               travel_period = p_travel_period,
               country       = p_country,
               approvno      = p_approvno
         where codempid = global_v_codempid
           and dtereq   = p_dtereq2save
           and numseq   = p_numseq;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end;

  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRES36E';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  trefreq.approvno%type;
    v_routeno             trefreq.routeno%type;
    v_desc                trefreq.remarkap%type := substr(get_label_name('HRESZXEC1', global_v_lang, 99), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);

  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';

    chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, global_v_codempid);
    -- <<
    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_table, v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error, global_v_lang, v_table);
      return;
    end if;
    -- >>

    loop

      v_codempid_next := chk_workflow.check_next_step2(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, v_codapp, null, parameter_v_approvno, global_v_codempid);
      if v_codempid_next is not null then
         parameter_v_approvno := parameter_v_approvno + 1 ;
         p_codappr         := v_codempid_next ;
         p_staappr         := 'A' ;
         p_dteappr         := trunc(sysdate);
         p_remarkap        := v_desc;
         p_approvno        := parameter_v_approvno ;
         v_approv          := v_codempid_next;

        begin
          insert into tapempch (codempid, dtereq, typreq, numseq,
                                approvno, codappr, dteappr,
                                staappr, remark, coduser
                                )
                values         (global_v_codempid, p_dtereq2save, v_codapp, p_numseq,
                                parameter_v_approvno, v_codempid_next, trunc(sysdate),
                                'A', v_desc, global_v_coduser
                                );
        exception when dup_val_on_index then
          update tapempch
             set codappr   = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = v_desc,
                 coduser   = global_v_coduser


           where codempid  = global_v_codempid
             and dtereq    = p_dtereq2save
             and typreq    = v_codapp
             and numseq    = p_numseq
             and approvno  = parameter_v_approvno;
        end;

        chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop ;
    p_approvno     := parameter_v_approvno;
    p_routeno      := v_routeno;
  end;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_trefreq;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    obj_data        := json_object_t(get_response_message(null, param_msg_error, global_v_lang));
    obj_data.put('numseq', to_char(p_numseq));
    json_str_output := obj_data.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;

  procedure cancel_request (json_str_input in clob, json_str_output out clob) AS
    v_staappr       trefreq.staappr%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if p_dtereq2save is not null then
        if p_staappr = 'P' then
          v_staappr := 'C';
          begin
            update trefreq
              set staappr   = v_staappr,
                  dtecancel = sysdate,
                  coduser   = global_v_coduser
            where codempid  = global_v_codempid
              and dtereq    = p_dtereq2save
              and numseq    = p_numseq;
          end;
        elsif p_staappr = 'C' then
          param_msg_error := get_error_msg_php('HR1506', global_v_lang);
        else
          param_msg_error := get_error_msg_php('HR1490', global_v_lang);
        end if;
      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2421', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end cancel_request;

  function get_codtypcrt(json_str_input in clob) return clob is
    v_rcnt          number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;

    cursor c1 is
      select codcodec,
             descode,
             descodt,
             descod3,
             descod4,
             descod5
        from tcodtypcrt
       where nvl(flgact, '1') = '1'
       order by codcodec;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    obj_lang1       := json_object_t();
    obj_lang2       := json_object_t();
    obj_lang3       := json_object_t();
    obj_lang4       := json_object_t();
    obj_lang5       := json_object_t();
    for i in c1 loop
      v_rcnt   := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codtypcrt', i.codcodec);
      obj_data.put('destypcrt', i.descode);
      obj_lang1.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('destypcrt', i.descodt);
      obj_lang2.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('destypcrt', i.descod3);
      obj_lang3.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('destypcrt', i.descod4);
      obj_lang4.put(to_char(v_rcnt-1), obj_data);
      obj_data.put('destypcrt', i.descod5);
      obj_lang5.put(to_char(v_rcnt-1), obj_data);
    end loop;
    obj_row.put('coderror', '200');
    obj_row.put('lang1', obj_lang1);
    obj_row.put('lang2', obj_lang2);
    obj_row.put('lang3', obj_lang3);
    obj_row.put('lang4', obj_lang4);
    obj_row.put('lang5', obj_lang5);

    return obj_row.to_clob;
  exception when others then
    obj_data := json_object_t();
    obj_data.put('coderror', '400');
    obj_data.put('response', dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
    return obj_data.to_clob;
  END;
end HRES36E;

/

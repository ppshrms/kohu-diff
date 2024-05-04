--------------------------------------------------------
--  DDL for Package Body HRRC31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC31E" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  get index parameter
        p_codcomp       := hcm_util.get_string_t(data_obj, 'p_codcomp');
        p_codemprc      := hcm_util.get_string_t(data_obj, 'p_codemprc');
        p_numreqst      := hcm_util.get_string_t(data_obj, 'p_numreqst');
        p_codpos        := hcm_util.get_string_t(data_obj, 'p_codpos');
        p_dteappoist    := to_date(hcm_util.get_string_t(data_obj, 'p_dteappoist'), 'dd/mm/yyyy');
        p_dteappoien    := to_date(hcm_util.get_string_t(data_obj, 'p_dteappoien'), 'dd/mm/yyyy');
        p_numappl       := hcm_util.get_string_t(data_obj, 'p_numappl');
--  save index parameter
        p_codform       := hcm_util.get_string_t(data_obj, 'p_codform');
        p_codexam       := hcm_util.get_string_t(data_obj, 'p_codexam');
        p_numapseq      := hcm_util.get_string_t(data_obj, 'p_numapseq');
        p_dteappoi      := to_date(hcm_util.get_string_t(data_obj, 'p_dteappoi'), 'dd/mm/yyyy');
        p_timappoi      := REPLACE(hcm_util.get_string_t(data_obj, 'p_timappoi'),':','');
        p_qtyfscore     := hcm_util.get_string_t(data_obj, 'p_qtyfscore');
        p_typappty      := hcm_util.get_string_t(data_obj, 'p_typappty');
        p_descnote      := hcm_util.get_string_t(data_obj, 'p_descnote');
        p_stapphinv     := hcm_util.get_string_t(data_obj, 'p_stapphinv');
        p_codasapl      := hcm_util.get_string_t(data_obj, 'p_codasapl');
        p_qtyfscore     := hcm_util.get_string_t(data_obj, 'p_qtyfscore');
        p_location      := hcm_util.get_string_t(data_obj, 'p_location');

        p_statappl      := hcm_util.get_string_t(data_obj, 'p_statappl');

        p_stasign       := hcm_util.get_string_t(data_obj, 'p_stasign');
        p_qtyfscoresum  := to_number(hcm_util.get_string_t(data_obj, 'p_qtyfscoresum'));
        p_qtyscoresum   := to_number(hcm_util.get_string_t(data_obj, 'p_qtyscoresum'));

  end initial_params;

  procedure initial_params_index1(data_obj json_object_t) as
  begin
        p_codform       := hcm_util.get_string_t(data_obj, 'p_codform');
        p_codexam       := hcm_util.get_string_t(data_obj, 'p_codexam');
        p_numapseq      := hcm_util.get_string_t(data_obj, 'p_numapseq');
        p_dteappoi      := to_date(hcm_util.get_string_t(data_obj, 'p_dteappoi'), 'dd/mm/yyyy');
        p_timappoi      := hcm_util.get_string_t(data_obj, 'p_timappoi');
        p_qtyfscore     := hcm_util.get_string_t(data_obj, 'p_qtyfscore');
        p_typappty      := hcm_util.get_string_t(data_obj, 'p_typappty');
        p_descnote      := hcm_util.get_string_t(data_obj, 'p_descnote');
        p_stapphinv     := hcm_util.get_string_t(data_obj, 'p_stapphinv');
        p_codasapl      := hcm_util.get_string_t(data_obj, 'p_codasapl');
        p_qtyfscore     := hcm_util.get_string_t(data_obj, 'p_qtyfscore');
        p_location      := hcm_util.get_string_t(data_obj, 'p_location');

        p_statappl      := hcm_util.get_string_t(data_obj, 'p_statappl');

        p_stasign       := hcm_util.get_string_t(data_obj, 'p_stasign');
        p_qtyfscoresum  := to_number(hcm_util.get_string_t(data_obj, 'p_qtyfscoresum'));
        p_qtyscoresum   := to_number(hcm_util.get_string_t(data_obj, 'p_qtyscoresum'));

  end initial_params_index1;

  function check_index return boolean as
    v_temp   varchar(1 char);
  begin
--  check recruiter
    if p_codemprc is not null then
        begin
            select 'X' into v_temp
            from temploy1
            where codempid = p_codemprc;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TEMPLOY1');
            return false;
        end;
    end if;

--  check secur2
    if secur_main.secur2(p_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

    if p_codcomp is not null then
        begin
            select 'X' into v_temp
            from tcenter
            where codcomp like p_codcomp || '%'
              and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
            return false;
        end;
    end if;

--  check secur7
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

--  check position
    if p_codpos is not null then
        begin
            select 'X' into v_temp
            from tpostn
            where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
            return false;
        end;
    end if;

    begin
        select 'X' into v_temp
        from treqest2
        where codemprc = nvl(p_codemprc,codemprc)
          and codcomp like p_codcomp||'%'
          and codpos = nvl(p_codpos,codpos)
          and flgrecut in ('E','O')
          and qtyact < qtyreq
          and dteopen = (select max(dteopen)
                           from treqest2
                          where codemprc = nvl(p_codemprc,codemprc)
                            and codcomp  like p_codcomp||'%'
                            and codpos = nvl(p_codpos,codpos)
                            and flgrecut in ('E','O')
                            and qtyact < qtyreq)
            and rownum=1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
        return false;
    end;

    if p_numreqst is not null and p_codpos is not null then
        begin
            select 'X' into  v_temp
              from treqest2
             where codpos = p_codpos
               and numreqst = p_numreqst
               and flgrecut in ('E','O');
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
            return false;
        end;

        begin
            select 'X' into v_temp
              from tpostn
             where codpos = p_codpos;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TPOSTN');
            return false;
        end;
    end if;

    return true;

  end;

  function check_params return boolean as
    v_temp     varchar(1 char);
  begin
--  check date
    if p_dteappoi < sysdate then
        param_msg_error := get_error_msg_php('HR8519', global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;

    cursor c1 is
       select numreql,numappl,namemp,codcompl,codposl,codpos2,statappl,stasign
         from (
               select a.numreql,a.numappl,
                      decode(global_v_lang,'101', a.namempe,'102', a.namempt,'103', a.namemp3,'104', a.namemp4,'105', a.namemp5) namemp,
                      a.codcompl,a.codposl, a.codpos2, a.statappl, null as stasign
                 from tapplinf a
                where a.numreql   in (select numreqst
                                        from treqest2
                                       where numreql    = nvl(p_numreqst,numreqst)
                                         and codemprc   = nvl(p_codemprc,codemprc)
                                         and codcomp    like p_codcomp||'%'
                                         and codpos     = nvl(p_codpos,codpos)
                                         and flgrecut   in ('E','O')
                                         and nvl(qtyact,0) < nvl(qtyreq,0))
                  and a.codposl    = p_codpos
                  and a.statappl   = '31'
        union
               select a.numreql, a.numappl,
                      decode(global_v_lang,'101', a.namempe,'102', a.namempt,'103', a.namemp3,'104', a.namemp4,'105', a.namemp5) namemp,
                      a.codcompl,a.codposl, a.codpos2, a.statappl, b.stasign
                 from tapplinf a, tapphinv b
                where b.numappl    = a.numappl
                  and b.numreqrq   = a.numreql
                  and b.codposrq   = a.codposl
                  and b.numreqrq   in (select numreqst
                                         from treqest2
                                        where numreql    = nvl(p_numreqst,numreqst)
                                          and codemprc   = nvl(p_codemprc,codemprc)
                                          and codcomp    like p_codcomp||'%'
                                          and codpos     = nvl(p_codpos,codpos)
                                          and flgrecut   in ('E','O'))
                  and a.codposl    = p_codpos
                  and(b.dteappoi   between p_dteappoist and p_dteappoien
                   or b.dteappoist between p_dteappoist and p_dteappoien
                   or b.dteappoien between p_dteappoist and p_dteappoien
                   or p_dteappoist between b.dteappoist and b.dteappoien
                   or p_dteappoien between b.dteappoist and b.dteappoien)
                  )
     order by numreql, codposl, numappl;

/*    cursor c1 is
       select a.numreqst, a.numappl,
              decode(global_v_lang,'101', b.namempe,'102', b.namempt,'103', b.namemp3,'104', b.namemp4,'105', b.namemp5) namemp,
              a.codposrq, b.codpos2, a.statappl, a.stasign, a.stapphinv
         from tapphinv a, tapplinf b
        where a.numappl    = nvl(p_numappl,a.numappl)
          and a.numreqst   = nvl(p_numreqst,a.numreqst)
          and a.codposrq   = nvl(p_codpos,a.codposrq)
          and a.numappl    = b.numappl
          and(a.dteappoist between p_dteappoist and p_dteappoien
           or a.dteappoien between p_dteappoist and p_dteappoien
           or p_dteappoist between a.dteappoist and a.dteappoien
           or p_dteappoien between a.dteappoist and a.dteappoien)
     order by a.numreqst, a.numappl;


    cursor c2 is
        select  b.numreql, b.numappl, decode(global_v_lang, '101', b.namempe,
                                                            '102', b.namempt,
                                                            '103', b.namemp3,
                                                            '104', b.namemp4,
                                                            '105', b.namemp5) namemp,
                b.codposl, b.codpos2, b.statappl
        from tapplinf b
        where b.numreql = p_numreqst
          and b.codposl = p_codpos
          and b.statappl = '31'
        order by b.numreql, b.numappl;
*/
  begin
    obj_rows := json_object_t();
    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('numreqst', i.numreql);
      obj_data.put('desc_codpos', get_tpostn_name(i.codposl, global_v_lang));
      obj_data.put('dterange', '-');
      obj_data.put('numappl', i.numappl);
      obj_data.put('name', i.namemp);
      obj_data.put('codposrq', get_tpostn_name(i.codposl, global_v_lang));
      obj_data.put('codpos2', get_tpostn_name(i.codpos2, global_v_lang));
      obj_data.put('statappl', i.statappl);
      obj_data.put('desc_statappl', get_tlistval_name('STATAPPL',i.statappl, global_v_lang));
      obj_data.put('stasign', i.stasign);
      obj_data.put('desc_stasign', get_tlistval_name('STASIGN', i.stasign, global_v_lang));
      obj_data.put('codpos', i.codposl);
      obj_data.put('codcomp', i.codcompl);
      obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
   /* for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('numreqst', i.numreqst);
        obj_data.put('desc_codpos', get_tpostn_name(i.codposrq, global_v_lang));
        obj_data.put('dterange', '-');
        obj_data.put('numappl', i.numappl);
        obj_data.put('name', i.namemp);
        obj_data.put('codposrq', get_tpostn_name(i.codposrq, global_v_lang));
        obj_data.put('codpos2', get_tpostn_name(i.codpos2, global_v_lang));
--        obj_data.put('statappl', i.stapphinv);
--        obj_data.put('desc_statappl', get_tlistval_name('STAPPHINV',i.stapphinv, global_v_lang));
        obj_data.put('statappl', i.statappl);
        obj_data.put('desc_statappl', get_tlistval_name('STATAPPL',i.statappl, global_v_lang));
        obj_data.put('stasign', i.stasign);
        obj_data.put('desc_stasign', get_tlistval_name('STASIGN', i.stasign, global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;

    if v_row = 0 then
        for i in c2 loop
            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('numreqst', i.numreql);
            obj_data.put('numappl', i.numappl);
            obj_data.put('desc_codpos', get_tpostn_name(p_codpos, global_v_lang));
            obj_data.put('dterange', '-');
            obj_data.put('name', i.namemp);
            obj_data.put('codposrq', get_tpostn_name(i.codposl, global_v_lang));
            obj_data.put('codpos2', get_tpostn_name(i.codpos2, global_v_lang));
            obj_data.put('statappl', i.statappl);
            obj_data.put('desc_statappl', get_tlistval_name('STATAPPL', i.statappl, global_v_lang));
            obj_data.put('stasign', '');
            obj_data.put('desc_stasign', '');
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
    end if;*/

    if v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPHINV');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;

  end gen_index;

  function gen_tappoinf_table return json_object_t as

    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_total_qtyscoreavg     number := 0;
    v_total_codasapl        number := 0;
    v_total_result          tappoinf.codasapl%type := 'P';
    v2_scorfull      number := 0;  

    cursor c1 is
        select a.numapseq, a.dteappoi, a.typappty, a.descnote, a.stapphinv,
               a.qtyfscore, a.qtyscoreavg, a.codasapl,
               a.codposrq, a.codexam
        from tappoinf a
        where a.numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos
        order by a.numapseq;

  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('numapseq', i.numapseq);
        obj_data.put('dteappt', to_char(i.dteappoi, 'dd/mm/yyyy'));
        obj_data.put('desc_typappt', get_tlistval_name('TYPAPPOINT', i.typappty, global_v_lang));
        obj_data.put('typappt', i.typappty);
        obj_data.put('desc_oth', i.descnote);
        obj_data.put('status', i.stapphinv);
        obj_data.put('desc_status', get_tlistval_name('STAPPHINV', i.stapphinv, global_v_lang));
-- #7855 || 13/07/2022        
        if i.typappty = '1' then
            begin
                select scorfull into v2_scorfull 
                from texampos
                where codcomp like p_codcomp||'%'
                and codexam = i.codexam
                and codpos = i.codposrq;
            exception when others then
                v2_scorfull := 0;            
            end;
        else
            v2_scorfull := i.qtyfscore;
        end if;
        obj_data.put('scorfull', v2_scorfull);
        --obj_data.put('scorfull', i.qtyfscore); 
-- #7855 || 13/07/2022        
        obj_data.put('qtyscore', i.qtyscoreavg);
        obj_data.put('result', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));
        obj_rows.put(to_char(v_row-1),obj_data);
        v_total_qtyscoreavg := v_total_qtyscoreavg + nvl(i.qtyfscore,0);
        v_total_codasapl := v_total_codasapl + nvl(i.qtyscoreavg,0);
        if i.codasapl = 'F' then
            v_total_result := i.codasapl;
        end if;
    end loop;

    return obj_rows;

  end gen_tappoinf_table;

  procedure gen_detail(json_str_output out clob) as
    obj_data        json_object_t;
    v_stapphinv     tapphinv.stapphinv%type;
    v_stasign       tapphinv.stasign%type;
    v_dteappoist    tapphinv.dteappoist%type;
    v_dteappoien    tapphinv.dteappoien%type;
    v_qtyfscoresum  tapphinv.qtyfscoresum%type;
    v_qtyscoresum   tapphinv.qtyscoresum%type;

  begin
    begin
        select dteappoist, dteappoien, stapphinv, stasign, qtyfscoresum, qtyscoresum
        into v_dteappoist, v_dteappoien, v_stapphinv, v_stasign, v_qtyfscoresum, v_qtyscoresum
        from tapphinv
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos;
    exception when no_data_found then
        v_stapphinv := '';
        v_stasign   := '';
    end;

    obj_data := json_object_t();
    obj_data.put('dteappoist', to_char(v_dteappoist, 'dd/mm/yyyy'));
    obj_data.put('dteappoien', to_char(v_dteappoien, 'dd/mm/yyyy'));
    obj_data.put('stasign', v_stasign);
    obj_data.put('stapphinv', v_stapphinv);
    obj_data.put('qtyfscore', v_qtyfscoresum);
    obj_data.put('qtyscoreavg', v_qtyscoresum);
    obj_data.put('codasapl', '');
    obj_data.put('coderror', 200);
    obj_data.put('table', gen_tappoinf_table);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_detail;

  procedure gen_detail_sub(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_emp         json_object_t;
    v_tappoinf      tappoinf%rowtype;
    v_row           number := 0;
    v_new_numapseq  tappoinf.numapseq%type;
    cursor c1 is
        select a.codempts, b.codpos
        from tappoinfint a, temploy1 b
        where a.numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos
          and numapseq = p_numapseq
          and b.codempid = a.codempts
        order by a.numapseq;

  begin
    begin
        select * into v_tappoinf
        from tappoinf
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos
          and numapseq = p_numapseq;
    exception when no_data_found then
        v_tappoinf := null;
    end;

    obj_data := json_object_t();
    obj_data.put('numappl', v_tappoinf.numappl);
    if v_tappoinf.numapseq is null then
        begin
            select max(numapseq) into v_new_numapseq
            from tappoinf
            where numappl = p_numappl
              and numreqrq = p_numreqst
              and codposrq = p_codpos;
        exception when no_data_found then
            null;
        end;
        v_new_numapseq := nvl(v_new_numapseq,0);
        obj_data.put('numapseq', v_new_numapseq+1);
    else
        obj_data.put('numapseq', v_tappoinf.numapseq);
    end if;
    obj_data.put('codappl', '');
    obj_data.put('desc_codappl', '');
    obj_data.put('codposrq', v_tappoinf.codposrq);
    obj_data.put('desc_codposrq', get_tpostn_name(v_tappoinf.codposrq, global_v_lang));
    obj_data.put('typappty', v_tappoinf.typappty);
    obj_data.put('dteappoi', to_char(v_tappoinf.dteappoi, 'dd/mm/yyyy'));
    obj_data.put('timappoi',(substr(v_tappoinf.timappoi,1,2)||':'||substr(v_tappoinf.timappoi,3)));
    obj_data.put('location', v_tappoinf.location);
    obj_data.put('codform', v_tappoinf.codform);
    obj_data.put('codexam', v_tappoinf.codexam);
    obj_data.put('descnote', v_tappoinf.descnote);
    obj_data.put('codlogin', v_tappoinf.codlogin);
    obj_data.put('codpwd', v_tappoinf.codpwd);
    obj_data.put('status', v_tappoinf.stapphinv);
    obj_data.put('desc_status', get_tlistval_name('STAPPHINV', v_tappoinf.stapphinv, global_v_lang));

    obj_row := json_object_t();
    for i in c1 loop
        v_row:= v_row+1;
        obj_emp := json_object_t();
        obj_emp.put('codempts',i.codempts);
        obj_emp.put('codpos',i.codpos);
        obj_emp.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
        obj_row.put(v_row-1,obj_emp);
    end loop;
    obj_data.put('table', obj_row);
    obj_data.put('coderror', 200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_detail_sub;

  procedure insert_or_update_tappoinf as
    v_user      long;
    v_pass      long;

  begin
    v_user := p_numappl||lpad(floor(dbms_random.value(0, 9999)),4,0);
    v_pass := lpad(floor(dbms_random.value(0, 9999)),4,0);

    begin
        insert into tappoinf
            (
                numappl, numreqrq, codposrq, numapseq, typappty, dteappoi,
                timappoi, location, codform, codexam, descnote, qtyfscore, codasapl,
                stapphinv, codlogin, codpwd, codcreate, coduser
            )
        values
            (
                p_numappl, p_numreqst, p_codpos, p_numapseq, p_typappty, p_dteappoi,
                p_timappoi, p_location, p_codform, p_codexam, p_descnote, p_qtyfscore, p_codasapl,
                'P', v_user, v_pass, global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
        update tappoinf
        set typappty = p_typappty,
            dteappoi = p_dteappoi,
            timappoi = p_timappoi,
            codform = p_codform,
            codexam = p_codexam,
            location = p_location,
            descnote = p_descnote,
            qtyfscore = p_qtyfscore,
            codasapl = p_codasapl,
            coduser = global_v_coduser
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos
          and numapseq = p_numapseq;

    end;

  end insert_or_update_tappoinf;

  procedure insert_or_update_tappoinfint(v_codempts tappoinfint.codempts%type,v_codemptsOld tappoinfint.codempts%type) as
  begin
    if v_codempts = v_codemptsOld then
        begin
            insert into tappoinfint
                (
                    numappl, numreqrq, codposrq, numapseq, codempts,
                    dteappoi, qtyfscore, stapphinv, codcreate, coduser
                )
            values
                (
                    p_numappl, p_numreqst, p_codpos, p_numapseq, v_codempts,
                    p_dteappoi, p_qtyfscore, 'P', global_v_coduser, global_v_coduser
                );
        exception when dup_val_on_index then
            update tappoinfint
            set dteappoi = p_dteappoi,
                qtyfscore = p_qtyfscore,
                coduser = global_v_coduser
            where numappl = p_numappl
              and numreqrq = p_numreqst
              and codposrq = p_codpos
              and numapseq = p_numapseq
              and codempts = v_codempts;
        end;
    else
            update tappoinfint
            set dteappoi = p_dteappoi,
                qtyfscore = p_qtyfscore,
                codempts = v_codempts,
                coduser = global_v_coduser
            where numappl = p_numappl
              and numreqrq = p_numreqst
              and codposrq = p_codpos
              and numapseq = p_numapseq
              and codempts = v_codemptsOld;
    end if;

  end insert_or_update_tappoinfint;

  procedure insert_or_update_tapphinv as
    v_codcomp   treqest1.codcomp%type;
  begin
    begin
        select codcomp into v_codcomp
          from treqest1
         where numreqst = p_numreqst;
    exception when no_data_found then
        v_codcomp := p_codcomp;
    end;
    begin
        insert into tapphinv
            (
                numappl, numreqrq, codposrq, codcomp, stapphinv,
                statappl, dteappoi, codcreate, coduser
            )
        values
            (
                p_numappl, p_numreqst, p_codpos, v_codcomp, 'P',
                '41', p_dteappoi, global_v_coduser, global_v_coduser
            );
    exception when dup_val_on_index then
        update tapphinv
        set stapphinv = p_stapphinv,
            codcomp = v_codcomp,
            statappl = p_statappl,
            dteappoi = p_dteappoi,
            coduser = global_v_coduser
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos;
    end;

  end insert_or_update_tapphinv;

  procedure update_tapphinv as
  begin
    update tapphinv
    set stapphinv = p_stapphinv,
        statappl = '50',
        stasign = p_stasign,
        qtyfscoresum = p_qtyfscoresum,
        qtyscoresum = p_qtyscoresum,
        coduser = global_v_coduser
    where numappl = p_numappl
      and numreqrq = p_numreqst
      and codposrq = p_codpos;

  end update_tapphinv;

  procedure update_tapplinf(v_statappl varchar2) as
  begin
    update tapplinf
    set statappl = v_statappl,
        dtefoll = sysdate,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tapplinf;

  procedure insert_tappfoll(v_statappl varchar2) as
  begin
    insert into tappfoll
        (
            numappl, dtefoll, statappl, numreqst, codpos, codcreate,
            coduser
        )
    values
        (
            p_numappl, sysdate, v_statappl, p_numreqst, p_codpos, global_v_coduser,
            global_v_coduser
        );

  end insert_tappfoll;

  procedure gen_drilldown_result(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_codform       tappoinf.codform%type;
    v_stasign       tapphinv.stasign%type;

    cursor c1 is
        select a.codempts, b.codpos, a.qtyscore, a.codasapl, a.descnote
        from tappoinfint a, temploy1 b
        where a.codempts = b.codempid
          and a.numappl = p_numappl
          and a.numreqrq = p_numreqst
          and a.codposrq = p_codpos
          and a.numapseq = p_numapseq
        order by a.codempts;

  begin
    obj_rows := json_object_t();
    begin
        select codform into v_codform
        from tappoinf
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos
          and numapseq = p_numapseq;
    exception when no_data_found then
        v_codform := '';
    end;

    begin
        select stasign into v_stasign
        from tapphinv
        where numappl = p_numappl
          and numreqrq = p_numreqst
          and codposrq = p_codpos;
    exception when no_data_found then
        v_stasign := '';
    end;
    obj_data := json_object_t();
    obj_data.put('codform', v_codform);
    obj_data.put('stasign', v_stasign);
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('desc_codempts', get_temploy_name(i.codempts, global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('qtyscore', i.qtyscore);
        obj_data.put('codasapl', get_tlistval_name('CODASAPL', i.codasapl, global_v_lang));
        obj_data.put('descnote', i.descnote);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    obj_data.put('table', obj_rows);
    obj_data.put('coderror', 200);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  end gen_drilldown_result;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail;

  procedure get_detail_sub(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_detail_sub(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_detail_sub;

  procedure get_drilldown_result(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    gen_drilldown_result(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_drilldown_result;

  procedure save_index(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    v_codempts       tappoinfint.codempts%type;
    v_codemptsOld    tappoinfint.codempts%type;
    v_temp          varchar2(1 char);
    v_staemp        temploy1.staemp%type;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    initial_params(json_obj);
    if p_dteappoi < trunc(sysdate) then
        param_msg_error := get_error_msg_php('HR8519', global_v_lang);
    end if;
    if param_msg_error is null then
        if p_codform is not null then
            begin
                select scorfull into p_qtyfscore
                from tintvewp
                where codpos = p_codpos
                  and rownum = 1;
            exception when no_data_found then
                p_qtyfscore := 0;
            end;
         end if;
        insert_or_update_tappoinf;
        insert_or_update_tapphinv;
        update_tapplinf('41');
        insert_tappfoll('41');
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            data_obj    := hcm_util.get_json_t(param_json, to_char(i));
            v_codempts  := hcm_util.get_string_t(data_obj, 'codempts');
            v_codemptsOld   := nvl(hcm_util.get_string_t(data_obj, 'codemptsOld'),v_codempts);
            if hcm_util.get_string_t(data_obj, 'flg') != 'delete' then
                begin
                    select staemp into v_staemp
                      from temploy1
                     where codempid = v_codempts;
                exception when no_data_found then
                    param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
                    exit;
                end;
                if v_staemp = '9' then
                    param_msg_error := get_error_msg_php('HR2101', global_v_lang);
                    exit;
                elsif v_staemp = '0' then
                    param_msg_error := get_error_msg_php('HR2102', global_v_lang);
                    exit;
                end if;
            end if;
            if hcm_util.get_string_t(data_obj, 'flg') = 'delete' then
                begin
                    delete from tappoinfint
                    where numappl = p_numappl
                    and numreqrq = p_numreqst
                    and codposrq = p_codpos
                    and codempts = v_codempts;
                end;
            else
                insert_or_update_tappoinfint(v_codempts,v_codemptsOld);
            end if;
        end loop;
    end if;

    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END save_index;

    procedure send_mail_a(data_obj json_object_t) as
        v_rowid         varchar(20);

        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg           clob;

        v_email         varchar(200);
        v_codappchse     treqest1.codappchse%type;


    begin

        v_subject  := get_label_name('HRRC31EC1', global_v_lang, 310);
        v_codapp   := 'HRRC31E';
        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC31E';
        end;

        chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

        -- replace employee param
        begin
            select rowid into v_rowid
            from tapplinf
            where numappl = p_numappl;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPLINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace employee param email reciever param
        begin
            select rowid,codappchse  into v_rowid,v_codappchse
            from treqest1
            where numreqst = p_numreqst;
        exception when no_data_found then
            v_rowid := '';
            v_codappchse := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace sender
        begin
            select rowid into v_rowid
            from temploy1
            where codempid = global_v_codempid;
        exception when no_data_found then
            v_rowid := '';
        end;

        chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        begin
            select email into v_email
            from temploy1
            where codempid = v_codappchse;
        exception when no_data_found then
            v_email := '';
        end;
        v_error := chk_flowmail.send_mail_to_emp (v_codappchse, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);

    end send_mail_a;

    procedure save_index2(json_str_input in clob, json_str_output out clob) AS
    json_obj       json_object_t;
    data_obj       json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        initial_params(json_obj);
        update_tapphinv;
        update_tapplinf('50');
        begin
            update treqest2
               set  dteintview = sysdate,
                    coduser = global_v_coduser
             where numreqst = p_numappl
               and codpos = p_codpos;
        end;
        insert_tappfoll('50');

        if p_stapphinv = 'C' and p_stasign = 'Y' then
            send_mail_a(json_obj);
        end if;
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            data_obj  := hcm_util.get_json_t(param_json, to_char(i));
            p_numapseq      := hcm_util.get_string_t(data_obj, 'numapseq');
            p_dteappoi      := to_date(hcm_util.get_string_t(data_obj,'dteappt'), 'dd/mm/yyyy');
            if p_dteappoi < sysdate then
                param_msg_error := get_error_msg_php('HR8519', global_v_lang);
                exit;
            end if;
            if hcm_util.get_string_t(data_obj, 'flg') = 'delete' then
                begin
                    delete from tappoinf
                    where numappl = p_numappl
                    and numreqrq = p_numreqst
                    and codposrq = p_codpos
                    and numapseq = p_numapseq;
                end;
            end if;
        end loop;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    END save_index2;

    function validate_import_data(json_obj json_object_t, v_coderror out varchar, v_text out varchar2, v_error_fld out varchar2) return boolean as
        v_numappl       varchar2(1000);
        v_numreqrq      varchar2(1000);
        v_codposrq      varchar2(1000);
        v_numapseq      varchar2(1000);
        v_qtyfscore      varchar2(1000);
        v_qtyscoreavg   varchar2(1000);
        v_table         varchar2(10 char) := 'ttappoinf';
        v_temp          varchar2(1);
    begin
        v_numappl       := upper(hcm_util.get_string_t(json_obj,'numappl'));
        v_numreqrq      := upper(hcm_util.get_string_t(json_obj,'numreqrq'));
        v_codposrq      := upper(hcm_util.get_string_t(json_obj,'codposrq'));
        v_numapseq      := hcm_util.get_string_t(json_obj,'numapseq');
        v_qtyfscore      := hcm_util.get_string_t(json_obj,'qtyfscore');
        v_qtyscoreavg   := hcm_util.get_string_t(json_obj,'qtyscoreavg');
        v_text          := v_numappl||'|'||v_numreqrq||'|'||v_codposrq||'|'||
                           v_numapseq||'|'||v_qtyfscore||'|'||v_qtyscoreavg;

        if v_numappl is null then
            v_coderror  := 'HR2045';
            v_error_fld :=  v_table||'('||'numappl)';
            return false;
        end if;
        if v_numreqrq is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'numreqrq)';
            return false;
        end if;
        if v_codposrq is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'codposrq)';
            return false;
        end if;
        if v_numapseq is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'numapseq)';
            return false;
        end if;
        if v_qtyfscore is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'qtyfscore)';
            return false;
        end if;
        if v_qtyscoreavg is null then
            v_coderror  := 'HR2045';
            v_error_fld := v_table||'('||'qtyscoreavg)';
            return false;
        end if;
        if (length(v_numappl)>10) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'numappl)';
            return false;
        end if;
        if (length(v_numreqrq)>15) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'numreqrq)';
            return false;
        end if;
        if (length(v_codposrq)>4) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'codposrq)';
            return false;
        end if;
        if (length(v_numapseq)>2) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'numapseq)';
            return false;
        end if;
        if (length(v_qtyscoreavg)>5) then
            v_coderror  := 'HR6591';
            v_error_fld := v_table||'('||'qtyscoreavg)';
            return false;
        end if;
        begin
            select 'X' into v_temp
              from tappoinf
             where numappl = v_numappl
               and numreqrq = v_numreqrq
               and numapseq = v_numapseq;
        exception when no_data_found then
            v_coderror  := 'HR2055';
            v_error_fld := v_table;
            return false;
        end;
        if to_number(v_qtyscoreavg) > to_number(v_qtyfscore) then
            v_coderror  := 'HR2020';
            v_error_fld := v_table||'('||'qtyscoreavg,qtyscore)';
            return false;
        end if;
        return true;
    end validate_import_data;

    procedure save_impport_data(data_obj json_object_t) as
        v_numappl       tappoinf.numappl%type;
        v_numreqrq      tappoinf.numreqrq%type;
        v_codposrq      tappoinf.codposrq%type;
        v_numapseq      tappoinf.numapseq%type;
        v_qtyfscore     tappoinf.qtyfscore%type;
        v_qtyscoreavg   tappoinf.qtyscoreavg%type;
        v_codasapl      tappoinf.codasapl%type;
        v_scorpass      texampos.scorpass%type;
        v_codexam       tappoinf.codexam%type;
        v_codcomp       tapphinv.codcomp%type;
        v_codpos        tapphinv.codposrq%type;
    begin
        v_numappl       := upper(hcm_util.get_string_t(data_obj,'numappl'));
        v_numreqrq      := upper(hcm_util.get_string_t(data_obj,'numreqrq'));
        v_codposrq      := upper(hcm_util.get_string_t(data_obj,'codposrq'));
        v_numapseq      := to_number(hcm_util.get_string_t(data_obj,'numapseq'));
        v_qtyfscore      := to_number(hcm_util.get_string_t(data_obj,'qtyfscore'));
        v_qtyscoreavg   := to_number(hcm_util.get_string_t(data_obj,'qtyscoreavg'));
        begin
            select a.codexam,b.codcomp,b.codposrq
              into v_codexam,v_codcomp,v_codpos
              from tappoinf a,tapphinv b
             where a.numappl = v_numappl
               and a.numreqrq = v_numreqrq
               and a.numapseq = v_numapseq
               and b.numappl = a.numappl
               and b.numreqrq = a.numreqrq
               and b.codposrq = a.codposrq;
        exception when no_data_found then
            v_codexam := '';
            v_codcomp := '';
            v_codpos := '';
        end;
        begin
            select scorpass into v_scorpass
              from texampos
             where codcomp = v_codcomp
               and codpos = v_codpos
               and codexam = v_codexam;
        exception when no_data_found then
            v_scorpass := 0;
        end;
        if v_qtyscoreavg >= v_scorpass then
            v_codasapl := 'P';
        else
            v_codasapl := 'F';
        end if;
        begin
            update tappoinf
               set qtyfscore = v_qtyfscore,
                   qtyscoreavg = v_qtyscoreavg,
                   stapphinv = 'C',
                   codasapl = v_codasapl,
                   coduser = global_v_coduser
             where numappl = v_numappl
               and numreqrq = v_numreqrq
               and numapseq = v_numapseq;
        end;
    end save_impport_data;

    procedure import_data_process(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        data_obj    json_object_t;
        obj_excel   json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        obj_result  json_object_t;
        v_coderror  terrorm.errorno%type;
        v_text      varchar2(5000 char);
        v_error_fld varchar2(100 char);
        v_row       number := 0;
        v_rec_err   number := 0;
        v_rec_tran  number := 0;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        obj_excel   := hcm_util.get_json_t(param_json,'p_filename');
        obj_rows    := json_object_t();
        for i in 0..obj_excel.get_size-1 loop
            data_obj := hcm_util.get_json_t(obj_excel,to_char(i));
            if (validate_import_data(data_obj,v_coderror,v_text,v_error_fld)) = false then
                v_row := v_row+1;
                v_rec_err := v_rec_err+1;
                obj_data := json_object_t();
                obj_data.put('numseq',i + 1);
                obj_data.put('error_code',v_coderror||' '||get_errorm_name(v_coderror,global_v_lang)||' '||v_error_fld);
                obj_data.put('text',v_text);
                obj_rows.put(to_char(v_row-1),obj_data);
            else
                v_rec_tran := v_rec_tran+1;
                save_impport_data(data_obj);
            end if;
        end loop;
        commit;
        obj_result  := json_object_t();

        obj_data    := json_object_t();
        obj_data.put('rec_tran', v_rec_tran);
        obj_data.put('rec_err', v_rec_err);
        obj_data.put('response',replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_result.put('detail',obj_data);

        obj_data    := json_object_t();
        obj_data.put('rows',obj_rows);
        obj_result.put('table',obj_data);

        obj_rows    := json_object_t();
        obj_rows.put('datadisp',obj_result);

        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end import_data_process;

    PROCEDURE get_interviewer( json_str_input IN CLOB, json_str_output OUT CLOB ) AS
        json_obj     json_object_t;
        v_codempid   temploy1.codempid%TYPE;
        v_codpos     temploy1.codpos%TYPE;
        v_codcomp    temploy1.codcomp%TYPE;
        v_dteefpos   temploy1.dteefpos%TYPE;
        t_year    number          := 0;
        t_month     number          := 0;
        t_day     number          := 0;
        obj_data     json_object_t;
    BEGIN
        json_obj := json_object_t(json_str_input);
        v_codempid := upper(hcm_util.get_string_t(json_obj, 'codempid'));
        BEGIN
            SELECT codpos INTO v_codpos
            FROM temploy1
            WHERE codempid = v_codempid;
        exception when no_data_found then
            v_codpos := '';
        END;
        obj_data := json_object_t;
        obj_data.put('codempid', v_codempid);
        obj_data.put('codpos', v_codpos);
        obj_data.put('codpos_desc', get_tpostn_name(v_codpos, global_v_lang));
        obj_data.put('coderror', '200');
        dbms_lob.createtemporary(json_str_output, true);
        obj_data.to_clob(json_str_output);
        IF param_msg_error IS NOT NULL THEN
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        END IF;

    EXCEPTION WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_interviewer;


    procedure check_probation_form is
        v_chk_exist        varchar2(4 char);
    begin
        if p_codform is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codform');
        else
          begin
            select 'x' into v_chk_exist
              from TFMREFR
             where TYPFM = 'HRRC31E'
               and codform = p_codform;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TFMREFR');
          end;
        end if;
    end;

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
      select message, typemsg into o_message2, o_typemsg2
        from tfmrefr2
       where codform = p_codform;
    exception when no_data_found then
      o_message2 := null;
      o_typemsg2 := null;
    end;
    begin
      select message into o_message3
        from tfmrefr3
       where codform = p_codform;
    exception when no_data_found then
      o_message3 := null;
    end;
  end;

  procedure gen_html_message (json_str_output out clob) AS

    o_message1        clob;
    o_namimglet       clob;
    o_message2        clob;
  o_typemsg2        clob;
    o_message3        clob;

    obj_data          json_object_t;
    v_rcnt            number := 0;

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

    procedure get_html_message ( json_str_input in clob, json_str_output out clob ) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        check_probation_form;
        if param_msg_error is null then
          gen_html_message(json_str_output);
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure gen_probation_form ( json_str_output out clob ) is
        v_rcnt              number := 0;
        v_flg_permission    boolean := false;
        v_flg_found         boolean := false;
        v_secur_codempid    boolean;
        v_codrespr          varchar2(100 char);
        v_value             varchar2(1000 char);
        v_numseq            number;

        cursor c1 is
          select *
            from tfmparam
           where codform = p_codform
             and flginput = 'Y'
           order by ffield ;
    begin
        obj_row := json_object_t ();
        v_numseq := 23;
        for i in c1 loop
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t ();
          obj_data.put('coderror','200');
          obj_data.put('codform',i.codform);
          obj_data.put('codtable',i.codtable);
          obj_data.put('ffield',i.ffield);
          obj_data.put('flgdesc',i.flgdesc);
          obj_data.put('flginput',i.flginput);
          obj_data.put('flgstd',i.flgstd);
          obj_data.put('fparam',i.fparam);
          obj_data.put('numseq',i.numseq);
          obj_data.put('section',i.section);
          obj_data.put('descript',i.descript);

          begin
            select datainit1 into v_value
              from tinitial
             where codapp = 'HRRC49X'
               and numseq = v_numseq;
          exception when no_data_found then
            v_value := '';
          end;

          obj_data.put('value',v_value);
          obj_row.put(to_char(v_rcnt - 1),obj_data);

          v_numseq := v_numseq + 1;
        end loop;
        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_probation_form;

    procedure get_probation_form ( json_str_input in clob, json_str_output out clob ) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        check_probation_form;
        if param_msg_error is null then
          gen_probation_form(json_str_output);
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;

    function name_in (objItem in json_object_t , bykey VARCHAR2) return varchar2 is
    begin
        if ( hcm_util.get_string_t(objItem,bykey) = null or hcm_util.get_string_t(objItem,bykey) = ' ') then
            return '';
        else
            return hcm_util.get_string_t(objItem,bykey);
        end if;
    end name_in ;

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

  function get_item_property (p_table in VARCHAR2,p_field in VARCHAR2) return varchar2 is

    cursor c_datatype is
      select t.data_type as DATATYPE
      from user_tab_columns t
      where t.TABLE_NAME = p_table
      and t.COLUMN_NAME= substr(p_field, instr(p_field,'.')+1);
    valueDataType   json_object_t := json_object_t();
  begin

    for i in c_datatype loop
      valueDataType.put('DATATYPE',i.DATATYPE);
    end loop;
    return hcm_util.get_string_t(valueDataType,'DATATYPE');
  end get_item_property;

  function std_get_value_replace (v_in_statmt in  long, p_in_itemson in json_object_t , v_codtable in varchar2) return long is
    v_statmt    long;
    v_itemson  json_object_t;
    v_item_field_original    varchar2(500 char);
    v_item      varchar2(500 char);
    v_value     varchar2(500 char);
  begin
    v_statmt  := v_in_statmt;
    v_itemson := p_in_itemson;
    loop
      v_item    := substr(v_statmt,instr(v_statmt,'[') +1,(instr(v_statmt,']') -1) - instr(v_statmt,'['));
      v_item_field_original := v_item;
      v_item     :=   substr(v_item, instr(v_item,'.')+1);
      exit when v_item is null;
        param_msg_error := param_msg_error||v_statmt;
      v_value := name_in(v_itemson , lower(v_item));
      if get_item_property(v_codtable,v_item) = 'DATE' then
        v_value   := 'to_date('''||to_char(to_date(v_value),'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ;
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
      else
        v_statmt  := replace(v_statmt,'['||v_item_field_original||']',v_value) ;
                param_msg_error := param_msg_error||v_statmt;

      end if;

     end loop;
    return v_statmt;
  end std_get_value_replace;

  function std_replace(p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob is
    v_statmt        long;
    v_statmt_sub    long;

    v_message       clob;
    obj_json        json_object_t := json_object_t();
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
                        get_label_name('HRPM33R1',global_v_lang,30) || ' ' ||get_tlistval_name('NAMMTHFUL',to_number(v_month),global_v_lang) || ' ' ||
                        get_label_name('HRPM33R1',global_v_lang,220) || ' ' ||hcm_util.get_year_buddhist_era(v_year);
        end if;
      else
        v_statmt := std_get_value_replace(v_statmt, p_itemson, v_codtable);
        v_dataexct := execute_desc(v_statmt);
      end if;
      v_message := replace(v_message,i.fparam,v_dataexct);
    end loop; -- loop main

    return v_message;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end std_replace;

    procedure gen_email_data ( json_str_output out clob) as
        itemSelected    json_object_t := json_object_t();
        v_email         varchar(200);

        v_codlang       tfmrefr.codlang%type;
        v_day         number;
        v_desc_month    varchar2(50 char);
        v_year          varchar2(4 char);
        tdata_dteprint      varchar2(100 char);

        v_codempid      temploy1.codempid%type;
        v_codcomp       temploy1.codcomp%type;
        v_numlettr      varchar2(1000 char);
        v_dteduepr      ttprobat.dteduepr%type;
        temploy1_obj    temploy1%rowtype;
        temploy3_obj    temploy3%rowtype;

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
        v_flgstd            tfmrefr.flgstd%type;
        v_namimglet         tfmrefr.namimglet%type;
        v_folder            tfolderd.folder%type;

        o_message1          clob;
        o_namimglet         tfmrefr.namimglet%type;
        o_message2          clob;
        o_typemsg2          tfmrefr2.typemsg%type;
        o_message3          clob;
        v_qtyexpand         ttprobat.qtyexpand%type;
        v_amtinmth          ttprobat.amtinmth%type;
        p_signid            varchar2(1000 char);
        p_signpic           varchar2(1000 char);
        v_namesign          varchar2(1000 char);
        v_pathimg           varchar2(1000 char);
        type html_array   is varray(3) of clob;
            list_msg_html     html_array;
        -- Return Data
            v_resultcol   json_object_t ;
            v_resultrow   json_object_t := json_object_t();
            v_countrow    number := 0;

        obj_fparam      json_object_t := json_object_t();
        obj_rows        json_object_t;
        obj_result      json_object_t;

        v_numappl       tapplinf.numappl%type;
        v_numreqst      tappoinfint.numreqrq%type;
        v_codpos        tappoinfint.codposrq%type;

        v_typemsg       tfmrefr2.typemsg%type;
        v_namemp        tapplinf.namempe%type;

        v_msg_to            clob;
        v_error             varchar2(4000 char);

        v_coduser           temploy1.coduser%type;
        v_subject           varchar2(500 char);

        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_rowid         varchar(20);

        cursor c_interviewer is
            select a.codempts, b.email
                from tappoinfint a, temploy1 b
                where a.numappl = v_numappl
                  and numreqrq = v_numreqst
                  and codposrq = p_codpos
                  and b.codempid = a.codempts
                order by a.numapseq;
    begin

    begin
      select codlang,namimglet,flgstd into v_codlang, v_namimglet,v_flgstd
      from tfmrefr
      where codform = p_codform;
    exception when no_data_found then
      v_codlang := global_v_lang;
    end;
        begin
          select get_tsetup_value('PATHWORKPHP')||folder into v_folder
            from tfolderd
           where codapp = 'HRRC31E';
        exception when no_data_found then
                v_folder := '';
        end;
        v_codlang := nvl(v_codlang,global_v_lang);
        v_subject  := get_label_name('HRRC31EC1', global_v_lang, 310);

        -- dateprint
        v_day           := to_number(to_char(p_dateprint_date,'dd'),'99');
        v_desc_month    := get_nammthful(to_number(to_char(p_dateprint_date,'mm')),v_codlang);
        v_year          := get_ref_year(v_codlang,global_v_zyear,to_number(to_char(p_dateprint_date,'yyyy')));
        tdata_dteprint  := v_day||' '||v_desc_month||' '||v_year;
        --
        for i in 0..p_dataSelectedObj.get_size - 1 loop
            itemSelected  := hcm_util.get_json_t( p_dataSelectedObj,to_char(i));
            v_numappl    := hcm_util.get_string_t(itemSelected,'numappl');
            v_numreqst    := hcm_util.get_string_t(itemSelected,'numreqst');

            -- Read Document HTML
            gen_message(p_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
                    list_msg_html := html_array(o_message1,o_message2,o_message3);

            for i in 1..3 loop
                data_file := list_msg_html(i);
                data_file := std_replace(data_file,p_codform,i,itemSelected );
                for j in 0..p_resultfparam.get_size - 1 loop
                    obj_fparam      := hcm_util.get_json_t( p_resultfparam,to_char(j));
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

                    data_file := replace(data_file, fparam_fparam, fparam_value);
                end loop;
                data_file := replace(data_file, '\t', '&nbsp;&nbsp;&nbsp;');
                data_file := replace(data_file, chr(9), '&nbsp;');
                list_msg_html(i) := data_file;
            end loop;

            v_resultcol   := json_object_t ();

            v_resultcol := append_clob_json(v_resultcol,'headhtml',list_msg_html(1));
            v_resultcol := append_clob_json(v_resultcol,'bodyhtml',list_msg_html(2));
            v_resultcol := append_clob_json(v_resultcol,'footerhtml',list_msg_html(3));
            if v_namimglet is not null then
              v_pathimg := v_folder||'/'||v_namimglet;
            end if;
            v_resultcol := append_clob_json(v_resultcol,'imgletter',v_pathimg);
            v_resultcol.put('numberdocument',v_numappl);
            v_resultrow.put(to_char(v_countrow), v_resultcol);

            v_countrow := v_countrow + 1;

            v_codapp   := 'HRRC31E';
            begin
                select codform into v_codform
                from tfwmailh
                where codapp = v_codapp;
            exception when no_data_found then
                v_codform  := 'HRRC31E';
            end;
            chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);
            v_msg_to := list_msg_html(1)||list_msg_html(2)||list_msg_html(3);

            begin
                select rowid into v_rowid
                from temploy1
                where codempid = global_v_codempid;
            exception when no_data_found then
                v_rowid := '';
            end;
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

            -- send mail applicant '1'
            if p_flgappr_mail = '1' or p_flgappr_mail = '3' then
                begin
                    select email into v_email
                    from tapplinf
                    where numappl = v_numappl;
                exception when no_data_found then
                    v_email := '';
                end;

                v_msg_to   := replace(v_msg_to ,'[PARA_DATE]'  ,to_char(sysdate,'dd/mm/yyyy'));
                v_msg_to   := replace(v_msg_to ,'[P_CODUSER]'  ,v_coduser);
                v_msg_to   := replace(v_msg_to ,'[P_LANG]'        ,global_v_lang);
                v_msg_to   := replace(v_msg_to ,'[PARAM1]'       ,get_temploy_name(global_v_coduser, global_v_lang));
                v_msg_to   := replace(v_msg_to ,'[PARAM2]'       ,v_subject);
                v_msg_to   := replace(v_msg_to ,'[P_EMAIL]'      ,v_email);
               v_error := send_mail(p_email    => v_email,
                                     p_msg     => v_msg_to,
                                     p_codappr  => null,
                                     p_codapp  => null,
                                     p_filename1 => p_refdoc,
                                     p_filename2 => null,
                                     p_filename3 => null,
                                     p_filename4 => null,
                                     p_filename5 => null,
                                     p_attach_mode1 => null);
            end if;

            -- send mail interviewer '2'
            if p_flgappr_mail = '2'  or p_flgappr_mail = '3' then
                for i in c_interviewer loop
                    v_error := chk_flowmail.send_mail_to_emp(i.codempts, global_v_coduser, v_msg_to, NULL, get_label_name('HRRC31E', global_v_lang, 10), 'U', global_v_lang, null);
                end loop;
            end if;
        end loop; -- end of loop data
        obj_result :=  json_object_t();
        obj_result.put('coderror', '200');

        json_str_output := obj_result.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end gen_email_data;

  procedure validateprintreport(json_str_input in clob) as
    json_obj    json_object_t;
    codform     varchar2(10 char);
  begin
    v_chken   := hcm_secur.get_v_chken;
    json_obj  := json_object_t(json_str_input);

    --initial global
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd  := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid'); -- softberry || 27/02/2023 || #9143


        global_v_zyear := hcm_appsettings.get_additional_year() ;
    -- index
    p_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos         := hcm_util.get_string_t(json_obj,'p_codpos');

        p_detail_obj      := hcm_util.get_json_t(json_object_t(json_obj),'detail');
        p_flgappr_mail    := hcm_util.get_string_t(p_detail_obj,'flgappr');
    p_codform         := hcm_util.get_string_t(p_detail_obj,'codform');
        p_refdoc          := hcm_util.get_string_t(p_detail_obj,'refdoc');

    p_dataSelectedObj := hcm_util.get_json_t(json_object_t(json_obj),'dataselected');
    p_resultfparam    := hcm_util.get_json_t(json_obj,'fparam');

    if (p_codform is not null and p_codform <> ' ') then
      begin
        select codform into codform
        from tfmrefr
        where codform = p_codform;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TFMREFR');
        return;
      end;
    end if;

  end validateprintreport;

    procedure sendemail(json_str_input in clob, json_str_output out clob) as
    begin
        validateprintreport(json_str_input);
        if (param_msg_error is null or param_msg_error = ' ' ) then
            gen_email_data(json_str_output);
        end if;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end sendemail;

END HRRC31E;

/

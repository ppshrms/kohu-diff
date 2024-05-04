--------------------------------------------------------
--  DDL for Package Body HRAP31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP31E" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_dteyreap          := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    p_codapman          := hcm_util.get_string_t(json_obj,'p_codapman');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codaplvl          := hcm_util.get_string_t(json_obj,'p_codaplvl');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codform           := hcm_util.get_string_t(json_obj,'p_codform');
    p_codkpi            := hcm_util.get_string_t(json_obj,'p_codkpi');

    p_codskill          := hcm_util.get_string_t(json_obj,'p_codskill');
    p_expectgrade       := hcm_util.get_string_t(json_obj,'p_grade');
    p_grade             := hcm_util.get_string_t(json_obj,'p_gradeInput');
    p_grade1            := hcm_util.get_string_t(json_obj,'p_grade1');
    p_grade2            := hcm_util.get_string_t(json_obj,'p_grade2');
    p_grade3            := hcm_util.get_string_t(json_obj,'p_grade3');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  --Redmine #5552
  function get_codaplvl(p_dteyreap in number,
                        p_numseq   in number,
                        p_codempid in varchar2) return varchar2 is
    l_num   number;
    v_codaplvl      tstdisd.codaplvl%type;
  begin
      begin
           select codaplvl into v_codaplvl
            from tempaplvl
           where dteyreap = p_dteyreap
             and numseq  = p_numseq
             and codempid = p_codempid;
      exception when others then
        v_codaplvl := null;
      end;

    return v_codaplvl;
  exception when value_error then return Null;
  end;

  --Redmine #5552
  procedure check_index is
    v_error   varchar2(4000);
  begin
    null;
--    if b_index_codempid is not null then
--      v_error   := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
--      if v_error is not null then
--        param_msg_error   := v_error;
--        return;
--      end if;
--    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    count_numseq        number;
    v_flgRightDisable   boolean;
    v_flgtypap          tstdisd.flgtypap%type;
    v_last_flgappr      tappfm.flgappr%type;
    v_next_flgappr      tappfm.flgappr%type;
    v_flgappr           tappemp.flgappr%type;
    v_flgdata           boolean;
    v_codaplvl          tstdisd.codaplvl%type;
    v_next_dteapman     tappfm.dteapman%type;
    cursor c_tappfm is
        select *
          from tappfm
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and ((codapman is not null and codapman = p_codapman)
                or (codapman is null and exists
                    (  select codempid
                         from temploy1
                        WHERE codcomp like codcompap||'%'
                          and codpos = codposap
                          and staemp IN ('1','3')
                          and codempid = p_codapman
                        union
                       select codempid
                         from tsecpos
                        where codcomp like codcompap||'%'
                          and codpos = codposap
                          and dteeffec <= SYSDATE
                          and ( nvl(dtecancel, dteend) >= trunc(SYSDATE)
                                or nvl(dtecancel, dteend) IS NULL )
                          and codempid = p_codapman
                    ))
               )
           and (codempid = nvl(p_codempid_query , codempid)
                or (p_codcomp is not null and codcomp like p_codcomp||'%')
                or (p_codaplvl is not null and codaplvl = nvl(p_codaplvl,codaplvl)) )
      order by codempid,numseq;
  begin
    obj_row := json_object_t();

    for i in c_tappfm loop
      v_flgdata := true;
      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteyreap',i.dteyreap);
      obj_data.put('numtime',i.numtime);
      obj_data.put('image',get_emp_img(i.codempid));
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid, global_v_lang));
      obj_data.put('codaplvl',i.codaplvl);
      obj_data.put('desc_codaplvl',get_tcodec_name('TCODAPLV', i.codaplvl, global_v_lang));
      obj_data.put('dteapman',to_char(i.dteapman,'dd/mm/yyyy'));
      obj_data.put('numseq',i.numseq);
      obj_data.put('codapman',p_codapman);

      select count(numseq)
        into count_numseq
        from tappfm
       where codempid = i.codempid
         and dteyreap = i.dteyreap
         and numtime = i.numtime;

      obj_data.put('count_numseq',count_numseq);

--Redmine #5552
      v_codaplvl := get_codaplvl(i.dteyreap, i.numtime, i.codempid);
--Redmine #5552

      obj_data.put('flgappr', i.flgappr);
      obj_data.put('desc_flgappr',get_tlistval_name('APSTATUS',i.flgappr,global_v_lang));
      v_flgRightDisable := false;
      begin
          select flgtypap into v_flgtypap
            from tstdisd
           where codcomp  = hcm_util.get_codcomp_level(i.codcomp,1)
             and dteyreap = i.dteyreap
             and numtime  = i.numtime
--Redmine #5552
             and codaplvl = v_codaplvl;
--Redmine #5552
      exception when others then
        v_flgtypap := 'T';
      end;

      if v_flgtypap = 'T' then
        begin
            select flgappr
              into v_last_flgappr
              from tappfm
             where codempid = i.codempid
               and dteyreap = i.dteyreap
               and numtime = i.numtime
               and numseq = i.numseq - 1;
        exception when no_data_found then
            v_last_flgappr := 'P';
        end;
        begin
            select flgappr, dteapman
              into v_next_flgappr, v_next_dteapman
              from tappfm
             where codempid = i.codempid
               and dteyreap = i.dteyreap
               and numtime = i.numtime
               and numseq = i.numseq + 1;
        exception when no_data_found then
            v_next_flgappr := 'P';
            v_next_dteapman := null;
        end;
        if (nvl(v_last_flgappr,'P') != 'C' and i.numseq > 1) or v_next_dteapman is not null  then
            v_flgRightDisable := true;
        end if;
      end if;

      obj_data.put('flgRightDisable',v_flgRightDisable);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt  := v_rcnt + 1;
    end loop;

    if v_flgdata then
        json_str_output   := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPFM');
    end if;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
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
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    obj_table           json_object_t;
    clob_table          clob;
    obj_course          json_object_t;
    clob_course         clob;
    obj_develop         json_object_t;
    clob_develop        clob;
    v_rcnt              number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    count_numseq        number;
    v_flgRightDisable   boolean;
    v_flgtypap          tstdisd.flgtypap%type;
    v_last_flgappr      tappfm.flgappr%type;
    v_flgdata           boolean;

    v_flgapman          tappfm.flgapman%type;
    v_remark            tappemp.remark%type;
    v_remark2           tappemp.remark2%type;
    v_remark3           tappemp.remark3%type;
    v_commtimpro        tappemp.commtimpro%type;
    v_flgappr           tappfm.flgappr%type;
    v_dteapstr          tappfm.dteapstr%type;
    v_dteapend          tappfm.dteapend%type;
    v_dteapman          tappfm.dteapman%type;
    v_codcompy          tcompny.codcompy%type;
    v_flgconfemp        tappemp.flgconfemp%type;
    v_dteconfemp        tappemp.dteconfemp%type;
    v_flgconfhd         tappemp.flgconfhd%type;
    v_dteconfhd         tappemp.dteconfhd%type;
    v_flgconflhd        tappemp.flgconflhd%type;
    v_dteconflhd        tappemp.dteconflhd%type;
    v_flgconf           tappemp.flgconfemp%type;
    v_dteconf           tappemp.dteconfemp%type;
    v_max_numseq        tappfm.numseq%type;
    v_response          clob;
    v_flgSendmailDisable    boolean;
    v_count_tappfm          number;
    v_codaplvl          tstdisd.codaplvl%type;

  begin
    select count (*)
      into v_count_tappfm
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    begin
       select remark, remark2, remark3, commtimpro,
             flgconfemp, dteconfemp,flgconfhd,dteconfhd,flgconflhd,dteconflhd
        into v_remark, v_remark2, v_remark3, v_commtimpro,
             v_flgconfemp, v_dteconfemp,v_flgconfhd,v_dteconfhd,v_flgconflhd,v_dteconflhd
        from tappemp
       where codempid = p_codempid_query
         and dteyreap = p_dteyreap
         and numtime = p_numtime;
    exception when no_data_found then
       null;
    end;

    if p_numtime = 0 then
        v_response := get_error_msg_php('HR2490',global_v_lang);
    elsif v_count_tappfm = 0 then
        v_response := get_error_msg_php('HR2495',global_v_lang);
    end if;

    if v_response is not null then
      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(v_response,'@#$%400',null));
    else
      begin
          select flgapman, flgappr, dteapstr, dteapend, dteapman, hcm_util.get_codcomp_level(codcomp,1),codcomp
            into v_flgapman, v_flgappr, v_dteapstr, v_dteapend, v_dteapman, v_codcompy, v_codcomp
            from tappfm
           where codempid = p_codempid_query
             and dteyreap = p_dteyreap
             and numtime = p_numtime
             and numseq = p_numseq;
      exception when no_data_found then
        null;
      end;

--Redmine #5552
      v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

      begin
          select flgtypap into v_flgtypap
            from tstdisd
           where codcomp = v_codcompy
             and dteyreap = p_dteyreap
             and numtime = p_numtime
--Redmine #5552
             and codaplvl = v_codaplvl;
--Redmine #5552
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSTDISD');
        return;
      end;

      select max(numseq)
        into v_max_numseq
        from tappfm
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codempid = p_codempid_query
         and dteapman is not null;

      if v_flgconfemp = 'Y'
         or (v_flgtypap ='T' and v_max_numseq > p_numseq)
         or (v_selected_numseq is not null
             and p_codempid_query||p_dteyreap||p_numtime||p_numseq <>
                 v_selected_codempid||v_selected_dteyreap||v_selected_numtime||v_selected_numseq)then
        v_flgRightDisable           := true ;
        v_global_flgRightDisable    := true ;
      else
        v_flgRightDisable           := false ;
        v_global_flgRightDisable    := false ;
      end if;

      if v_flgapman = '1' then
        v_flgconf   := v_flgconfemp;
        v_dteconf   := v_dteconfemp;
      elsif v_flgapman = '2' then
        v_flgconf   := v_flgconfhd;
        v_dteconf   := v_dteconfhd;
      elsif v_flgapman = '3' then
        v_flgconf   := v_flgconflhd;
        v_dteconf   := v_dteconflhd;
      end if;

      select max(numseq)
        into v_max_numseq
        from tappfm
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codempid = p_codempid_query;

      v_flgSendmailDisable := true;
      if nvl(v_flgappr,'P') = 'C' and v_flgtypap ='T' and p_numseq < v_max_numseq then
        v_flgSendmailDisable := false;
      end if;

      v_flgdata         := true;
      obj_detail        := json_object_t();
      obj_detail.put('coderror','200');
      obj_detail.put('codempid',p_codempid_query);
      obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
      obj_detail.put('dteyreap',p_dteyreap);
      obj_detail.put('numtime',p_numtime);
      obj_detail.put('numseq',p_numseq);
      obj_detail.put('codapman',p_codapman);
      obj_detail.put('desc_codapman',get_temploy_name(p_codapman,global_v_lang));
      obj_detail.put('dteapman',to_char(nvl(v_dteapman,trunc(sysdate)),'dd/mm/yyyy'));
      obj_detail.put('dteapstr',to_char(v_dteapstr,'dd/mm/yyyy'));
      obj_detail.put('dteapend',to_char(v_dteapend,'dd/mm/yyyy'));
      obj_detail.put('flgappr',nvl(v_flgappr,'P'));
      obj_detail.put('flgapman',v_flgapman);
      obj_detail.put('desc_flgapman',get_tlistval_name('FLGDISP',v_flgapman,global_v_lang));
      obj_detail.put('flgconf',v_flgconf);
      obj_detail.put('dteconf',to_char(v_dteconf,'dd/mm/yyyy'));
      obj_detail.put('remark', v_remark);
      obj_detail.put('remark2', v_remark2);
      obj_detail.put('remark3', v_remark3);
      obj_detail.put('commtimpro',v_commtimpro);
      obj_detail.put('codcompy',v_codcompy);
      obj_detail.put('codcomp',v_codcomp);
      obj_detail.put('codaplvl',p_codaplvl);
      obj_detail.put('flgRightDisable',v_flgRightDisable);
      obj_detail.put('flgSendmailDisable',v_flgSendmailDisable);
      obj_detail.put('flgtypap',v_flgtypap);


      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);

      gen_detail_course_table(clob_course);
      obj_course    := json_object_t(clob_course);

      gen_detail_develop_table(clob_develop);
      obj_develop   := json_object_t(clob_develop);

      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('detail',obj_detail);
      obj_data.put('table',obj_table);
      obj_data.put('courseTable',obj_course);
      obj_data.put('developTable',obj_develop);
      obj_data.put('response','');

    end if;

      json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob,json_str_output out clob) is
    json_obj            json_object_t;
    obj_indexSelected   json_object_t;
  begin
    initial_value(json_str_input);
    json_obj            := json_object_t(json_str_input);
    obj_indexSelected   := json_object_t(nvl(hcm_util.get_string_t(json_obj,'indexSelected'),'{}'));
    v_selected_codempid := hcm_util.get_string_t(obj_indexSelected,'codempid');
    v_selected_dteyreap := hcm_util.get_string_t(obj_indexSelected,'dteyreap');
    v_selected_numtime  := hcm_util.get_string_t(obj_indexSelected,'numtime');
    v_selected_numseq   := hcm_util.get_string_t(obj_indexSelected,'numseq');

--    check_index;
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
  procedure gen_detail_table(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    count_numseq        number;
    v_flgRightDisable   boolean;
    v_flgtypap          tstdisd.flgtypap%type;
    v_last_flgappr      tappfm.flgappr%type;
    v_flgappr           tappemp.flgappr%type;
    v_flgdata           boolean;

    v_dteapend          tstdisd.dteapend%type;

    v_pctbeh            taplvl.pctbeh%type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpicp          taplvl.pctkpicp%type;
    v_pctkpiem          taplvl.pctkpiem%type;
    v_pctkpirt          taplvl.pctkpirt%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;

    v_sum_emp_qty       number  := 0;
    v_sum_leader_qty    number  := 0;
    v_sum_last_qty      number  := 0;

    v_emp_qty           number;
    v_leader_qty        number;
    v_last_qty          number;
    v_flgapman          tappfm.flgapman%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_qtykpid           tappemp.qtykpid%type;
    v_qtykpic           tappemp.qtykpic%type;
    v_qtybeh            tappfm.qtybeh%type;
    v_qtycmp            tappfm.qtycmp%type;
    v_qtykpi            tappfm.qtykpi%type;
    v_max_numseq        number;
    v_qtybehf           tappfm.qtybehf%type;
    v_qtycmpf           tappfm.qtycmpf%type;
    v_qtykpif           tappfm.qtykpif%type;

    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_sum_weight        number := 0;

    v_scoreta           number := 0;
    v_scorepunsh        number := 0;
    v_dteeffec          date;
    v_dtebhstr          date;
    v_dtebhend          date;
    v_qtyleav           number;
    v_qtyscor           number;
    v_qtypunsh          number;
    v_codaplvl          tstdisd.codaplvl%type;

    cursor c_behavior is
        select qtybeh,qtybehf
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = v_max_numseq;

    cursor c_competency is
        select qtycmp,qtycmpf
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = v_max_numseq;

    cursor c_kpi is
        select qtykpi,qtykpif
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = v_max_numseq;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
      group by flgapman;

    cursor c_tattpre1 is
        select 1 type,codgrplv
          from tattpre1
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'N'
         union
        select 2 type,codgrplv
          from tattpre1
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'Y'
         union
        select 3 type,codgrplv
          from tattpre1
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'Y'
           and flglate = 'N'
      order by type;

    cursor c_tattpre3 is
        select codpunsh
          from tattpre3
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
      order by codpunsh;
  begin
    obj_row := json_object_t();

    select flgapman, codcomp, qtybeh, qtycmp, qtykpi, qtybehf, qtycmpf, qtykpif
      into v_flgapman, v_codcomp, v_qtybeh, v_qtycmp, v_qtykpi, v_qtybehf, v_qtycmpf, v_qtykpif
      from tappfm
     where dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq
       and codempid = p_codempid_query;

--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

    begin
        select dtebhstr, dtebhend, dteapend, flgtypap
          into v_dtebhstr, v_dtebhend, v_dteapend, v_flgtypap
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when no_data_found then
        v_flgtypap := 'T';
    end;

    v_global_dteapend := v_dteapend;
    get_taplvl_where(v_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

    begin
        select pctbeh,pctcmp,pctkpicp,pctkpiem,pctkpirt,pctta,pctpunsh
          into v_pctbeh,v_pctcmp,v_pctkpicp,v_pctkpiem,v_pctkpirt,v_pctta,v_pctpunsh
          from taplvl
         where codcomp = v_taplvl_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
        null;
    end;

    if (nvl(v_pctta,0) + nvl(v_pctpunsh,0) > 0) then
        begin
            select qtyta ,qtypuns
              into v_qtyta , v_qtypuns
              from tappemp
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime;
        exception when no_data_found then
            v_qtyta     := null;
            v_qtypuns   := null;
        end;

        begin
            select dteeffec, scorfta, scorfpunsh
              into v_dteeffec,v_scorfta, v_scorfpunsh
              from tattpreh
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and codaplvl = p_codaplvl
               and dteeffec = (select max(dteeffec)
                                 from tattpreh
                                where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                  and codaplvl = p_codaplvl
                                  and dteeffec <= trunc(sysdate));
        exception when no_data_found then
            null;
        end;

        if v_qtyta is null and v_qtypuns is null then
          v_scoreta     := v_scorfta;

          for r_tattpre1 in c_tattpre1 loop
            if r_tattpre1.type = 1 then
                select nvl(sum(qtyday),0)
                  into v_qtyleav
                  from tleavetr a, tattprelv b
                 where a.codempid = p_codempid_query
                   and a.dtework between v_dtebhstr and v_dtebhend
                   and a.codleave = b.codleave
                   and b.codaplvl = p_codaplvl
                   and b.dteeffec = v_dteeffec
                   and b.codgrplv = r_tattpre1.codgrplv;
            elsif r_tattpre1.type = 2 then
                select sum(nvl(qtytlate,0) + nvl(qtytearly,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = p_codempid_query
                   and dtework between v_dtebhstr and v_dtebhend;
            elsif r_tattpre1.type = 3 then
                select sum(nvl(qtytabs,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = p_codempid_query
                   and dtework between v_dtebhstr and v_dtebhend;
            end if;

            begin
                select scorded
                  into v_qtyscor
                  from tattpre2
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and codaplvl = p_codaplvl
                   and dteeffec = v_dteeffec
                   and codgrplv = r_tattpre1.codgrplv
                   and v_qtyleav between qtymin and qtymax
              order by qtymin;
            exception when no_data_found then
                v_qtyscor := 0;
            end;

            v_scoreta           := v_scoreta - nvl(v_qtyscor,0);
          end loop;


          v_scorepunsh   := v_scorfpunsh;

          for r_tattpre3 in c_tattpre3 loop
            select count(*)
              into v_qtypunsh
              from thispun
             where codempid = p_codempid_query
               and codpunsh = r_tattpre3.codpunsh
               and dteeffec between v_dtebhstr and v_dtebhend;

            begin
                select scoreded
                  into v_qtyscor
                  from tattpre4
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and codaplvl = p_codaplvl
                   and dteeffec = v_dteeffec
                   and codpunsh = r_tattpre3.codpunsh
                   and v_qtypunsh between qtymin and qtymax
                order by qtymin;
            exception when no_data_found then
                v_qtyscor       := 0;
            end;

            v_scorepunsh            := v_scorepunsh - nvl(v_qtyscor,0);
          end loop;
          v_scoreta             := greatest(v_scoreta,0);
          v_scorepunsh          := greatest(v_scorepunsh,0);
          v_qtyta               := round((v_pctta * v_scoreta)/(v_pctta * v_scorfta) * 100,2);
          v_qtypuns             := round((v_pctpunsh * v_scorepunsh) / (v_pctpunsh * v_scorfpunsh) * 100,2);
        end if;

        if v_flgapman in ('1','4') then
            v_emp_qty       := round((v_qtyta + v_qtypuns)/2,2);
            v_sum_emp_qty   := v_sum_emp_qty + round(nvl(v_qtyta,0)/100 * nvl(v_pctta,0),2) + round(nvl(v_qtypuns,0)/100 * nvl(v_pctpunsh,0),2);
        elsif v_flgapman = '2' then
            v_leader_qty        := round((v_qtyta + v_qtypuns)/2,2);
            v_sum_leader_qty    := v_sum_leader_qty + round(nvl(v_qtyta,0)/100 * nvl(v_pctta,0),2) + round(nvl(v_qtypuns,0)/100 * nvl(v_pctpunsh,0),2);
--            if v_flgtypap = 'T' then
                v_emp_qty       := v_leader_qty;
                v_sum_emp_qty   := v_sum_leader_qty;
--            end if;
        elsif v_flgapman = '3' then
            v_last_qty      := round((v_qtyta + v_qtypuns)/2,2);
            v_sum_last_qty  := v_sum_last_qty + round(nvl(v_qtyta,0)/100 * nvl(v_pctta,0),2) + round(nvl(v_qtypuns,0)/100 * nvl(v_pctpunsh,0),2);
--            if v_flgtypap = 'T' then
                v_emp_qty           := v_last_qty;
                v_sum_emp_qty       := v_sum_last_qty;
                v_leader_qty        := v_last_qty;
                v_sum_leader_qty    := v_sum_last_qty;
--            end if;
        end if;

        v_sum_weight := v_sum_weight + nvl(v_pctta,0) + nvl(v_pctpunsh,0);

        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        if v_global_flgRightDisable then
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
        else
            obj_data.put('icon','<i class="fa fa-pencil"></i>');
        end if;
        obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 170));
        obj_data.put('weight',nvl(v_pctta,0) + nvl(v_pctpunsh,0));
        obj_data.put('emp_qty',to_char(v_emp_qty,'fm9,999,990.00'));
        obj_data.put('leader_qty',to_char(v_leader_qty,'fm9,999,990.00'));
        obj_data.put('last_qty',to_char(v_last_qty,'fm9,999,990.00'));
        obj_data.put('flgTopic','workingTime');
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
    end if;

    if (nvl(v_pctbeh,0) > 0) then
        obj_data        := json_object_t();
        v_emp_qty       := 0;
        v_leader_qty    := 0;
        v_last_qty      := 0;

        v_sum_weight := v_sum_weight + nvl(v_pctbeh,0);

        for r_flgapman in c_flgapman loop
            v_max_numseq    := r_flgapman.numseq;
            for r_behavior in c_behavior loop
                if r_flgapman.flgapman in ('1','4') then
                    v_emp_qty           := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                elsif  r_flgapman.flgapman = '2' then
                    v_leader_qty        := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                elsif  r_flgapman.flgapman = '3' then
                    v_last_qty          := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                end if;
            end loop;
        end loop;

        if v_flgapman in ('1','4') then
            v_emp_qty           := round(v_qtybeh / v_qtybehf * 100,2);
        elsif  v_flgapman = '2' then
            v_leader_qty        := round(v_qtybeh / v_qtybehf * 100,2);
        elsif  v_flgapman = '3' then
            v_last_qty          := round(v_qtybeh / v_qtybehf * 100,2);
        end if;

        -- default from before evalation
        if v_flgtypap = 'T' and v_qtybeh is null then
            v_max_numseq    := p_numseq - 1;
            for r_behavior in c_behavior loop
                if v_flgapman in ('1','4') then
                    v_emp_qty           := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                elsif  v_flgapman = '2' then
                    v_leader_qty        := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                elsif  v_flgapman = '3' then
                    v_last_qty          := round(r_behavior.qtybeh / r_behavior.qtybehf * 100,2);
                end if;
            end loop;
        end if;

        v_sum_emp_qty       := v_sum_emp_qty + round(nvl(v_emp_qty,0)/100 * nvl(v_pctbeh,0),2);
        v_sum_leader_qty    := v_sum_leader_qty + round(nvl(v_leader_qty,0)/100 * nvl(v_pctbeh,0),2);
        v_sum_last_qty      := v_sum_last_qty + round(nvl(v_last_qty,0)/100 * nvl(v_pctbeh,0),2);

        obj_data.put('coderror','200');
        if v_global_flgRightDisable then
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
        else
            obj_data.put('icon','<i class="fa fa-pencil"></i>');
        end if;
        obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 180));
        obj_data.put('weight',nvl(v_pctbeh,0));
        obj_data.put('emp_qty',to_char(v_emp_qty,'fm9,999,990.00'));
        obj_data.put('leader_qty',to_char(v_leader_qty,'fm9,999,990.00'));
        obj_data.put('last_qty',to_char(v_last_qty,'fm9,999,990.00'));
        obj_data.put('flgTopic','behavior');
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
    end if;

    if (nvl(v_pctcmp,0) > 0) then
        obj_data    := json_object_t();
        v_emp_qty       := 0;
        v_leader_qty    := 0;
        v_last_qty      := 0;

        for r_flgapman in c_flgapman loop
            v_max_numseq    := r_flgapman.numseq;
            for r_competency in c_competency loop
                if r_flgapman.flgapman in ('1','4') then
                    v_emp_qty := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                elsif  r_flgapman.flgapman = '2' then
                    v_leader_qty := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                elsif  r_flgapman.flgapman = '3' then
                    v_last_qty := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                end if;
            end loop;
        end loop;

        if v_flgapman in ('1','4') then
            v_emp_qty           := round(v_qtycmp / v_qtycmpf * 100,2);
        elsif  v_flgapman = '2' then
            v_leader_qty        := round(v_qtycmp / v_qtycmpf * 100,2);
        elsif  v_flgapman = '3' then
            v_last_qty          := round(v_qtycmp / v_qtycmpf * 100,2);
        end if;

        -- default from before evalation
        if v_flgtypap = 'T' and v_qtycmp is null then
            v_max_numseq    := p_numseq - 1;
            for r_competency in c_competency loop
                if v_flgapman in ('1','4') then
                    v_emp_qty           := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                elsif  v_flgapman = '2' then
                    v_leader_qty        := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                elsif  v_flgapman = '3' then
                    v_last_qty          := round(r_competency.qtycmp / r_competency.qtycmpf * 100,2);
                end if;
            end loop;
        end if;

        v_sum_emp_qty       := v_sum_emp_qty + round(nvl(v_emp_qty,0)/100 * nvl(v_pctcmp,0),2);
        v_sum_leader_qty    := v_sum_leader_qty + round(nvl(v_leader_qty,0)/100 * nvl(v_pctcmp,0),2);
        v_sum_last_qty      := v_sum_last_qty + round(nvl(v_last_qty,0)/100 * nvl(v_pctcmp,0),2);

        v_sum_weight := v_sum_weight + nvl(v_pctcmp,0);

        obj_data.put('coderror','200');
        if v_global_flgRightDisable then
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
        else
            obj_data.put('icon','<i class="fa fa-pencil"></i>');
        end if;
        obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 190));
        obj_data.put('weight',nvl(v_pctcmp,0));
        obj_data.put('emp_qty',to_char(v_emp_qty,'fm9,999,990.00'));
        obj_data.put('leader_qty',to_char(v_leader_qty,'fm9,999,990.00'));
        obj_data.put('last_qty',to_char(v_last_qty,'fm9,999,990.00'));
        obj_data.put('flgTopic','competency');
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
    end if;

    if (nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0) > 0) then
        obj_data        := json_object_t();
        v_emp_qty       := 0;
        v_leader_qty    := 0;
        v_last_qty      := 0;

        begin
            select qtykpid, qtykpic
              into v_qtykpid, v_qtykpic
              from tappemp
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime;
        exception when no_data_found then
            v_qtykpid     := 0;
            v_qtykpic     := 0;
        end;

        for r_flgapman in c_flgapman loop
            v_max_numseq    := r_flgapman.numseq;
            for r_kpi in c_kpi loop
                if r_flgapman.flgapman in ('1','4') then
                    v_emp_qty           := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                elsif  r_flgapman.flgapman = '2' then
                    v_leader_qty        := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                elsif  r_flgapman.flgapman = '3' then
                    v_last_qty          := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                end if;
            end loop;
        end loop;

        if v_flgapman in ('1','4') then
            v_emp_qty := round(v_qtykpi / v_qtykpif * 100,2);
        elsif  v_flgapman = '2' then
            v_leader_qty := round(v_qtykpi / v_qtykpif * 100,2);
        elsif  v_flgapman = '3' then
            v_last_qty := round(v_qtykpi / v_qtykpif * 100,2);
        end if;

        -- default from before evalation
        if v_flgtypap = 'T' and v_qtykpi is null then
            v_max_numseq    := p_numseq - 1;
            for r_kpi in c_kpi loop
                if v_flgapman in ('1','4') then
                    v_emp_qty           := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                elsif  v_flgapman = '2' then
                    v_leader_qty        := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                elsif  v_flgapman = '3' then
                    v_last_qty          := round(r_kpi.qtykpi / r_kpi.qtykpif * 100,2);
                end if;
            end loop;
        end if;

        v_sum_emp_qty       := v_sum_emp_qty +
                               round(nvl(v_emp_qty,0)/100 * nvl(v_pctkpiem,0),2) +
                               round(nvl(v_qtykpic,0)/100 * nvl(v_pctkpicp,0),2) +
                               round(nvl(v_qtykpid,0)/100 * nvl(v_pctkpirt,0),2);
        v_sum_leader_qty    := v_sum_leader_qty +
                               round(nvl(v_leader_qty,0)/100 * nvl(v_pctkpiem,0),2) +
                               round(nvl(v_qtykpic,0)/100 * nvl(v_pctkpicp,0),2) +
                               round(nvl(v_qtykpid,0)/100 * nvl(v_pctkpirt,0),2);
        v_sum_last_qty      := v_sum_last_qty +
                               round(nvl(v_last_qty,0)/100 * nvl(v_pctkpiem,0),2) +
                               round(nvl(v_qtykpic,0)/100 * nvl(v_pctkpicp,0),2) +
                               round(nvl(v_qtykpid,0)/100 * nvl(v_pctkpirt,0),2);

        v_sum_weight := v_sum_weight + nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0);
        obj_data.put('coderror','200');
        if v_global_flgRightDisable then
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
        else
            obj_data.put('icon','<i class="fa fa-pencil"></i>');
        end if;
        obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 200));
        obj_data.put('weight', nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0));
        obj_data.put('emp_qty',to_char(v_emp_qty,'fm9,999,990.00'));
        obj_data.put('leader_qty',to_char(v_leader_qty,'fm9,999,990.00'));
        obj_data.put('last_qty',to_char(v_last_qty,'fm9,999,990.00'));
        obj_data.put('flgTopic','kpi');
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt          := v_rcnt + 1;
    end if;

    obj_data    := json_object_t();obj_data.put('coderror','200');
    obj_data.put('icon','');
    obj_data.put('desc_codform',get_label_name('HRAP31E2', global_v_lang, 200));
    obj_data.put('weight', v_sum_weight);
    obj_data.put('emp_qty',to_char(v_sum_emp_qty,'fm9,999,990.00'));
    obj_data.put('leader_qty',to_char(v_sum_leader_qty,'fm9,999,990.00'));
    obj_data.put('last_qty',to_char(v_sum_last_qty,'fm9,999,990.00'));
    obj_data.put('flgTopic','kpi');
    obj_row.put(to_char(v_rcnt),obj_data);

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_detail_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_course_table(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_numseq            tapptrn.numseq%type;
    v_qtycmp            tappemp.qtycmp%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgtypap          tstdisd.flgtypap%type;

    cursor c_tapptrn is
        select *
          from tapptrn
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = v_numseq
      order by codcours;
  begin
    begin
        select codcomp, qtycmp
          into p_codcomp, v_qtycmp
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
    exception when others then
        p_codcomp   := null;
        v_qtycmp    := null;
    end;

    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);

    begin
        select flgtypap
          into v_flgtypap
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and codaplvl = v_codaplvl;
    exception when others then
        v_flgtypap := 'T';
    end;

    v_numseq := p_numseq;

    if v_qtycmp is null and v_flgtypap = 'T' then
        v_numseq := v_numseq - 1;
    end if;

    obj_row := json_object_t();
    for r_tapptrn in c_tapptrn loop
        obj_data      := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcours',r_tapptrn.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(r_tapptrn.codcours,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1 ;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_detail_course_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_course_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_develop_table(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_numseq            tapptrn.numseq%type;
    v_qtycmp            tappemp.qtycmp%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgtypap          tstdisd.flgtypap%type;

    cursor c_tappdev is
        select *
          from tappdev
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = v_numseq
      order by coddevp;
  begin
    begin
        select codcomp, qtycmp
          into p_codcomp, v_qtycmp
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
    exception when others then
        p_codcomp   := null;
        v_qtycmp    := null;
    end;

    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);

    begin
        select flgtypap
          into v_flgtypap
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and codaplvl = v_codaplvl;
    exception when others then
        v_flgtypap := 'T';
    end;

    v_numseq := p_numseq;

    if v_qtycmp is null and v_flgtypap = 'T' then
        v_numseq := v_numseq - 1;
    end if;

    obj_row := json_object_t();
    for r_tappdev in c_tappdev loop
        obj_data      := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('coddevp',r_tappdev.coddevp);
        obj_data.put('desdevp',r_tappdev.desdevp);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_detail_develop_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail_develop_table(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_otherassessments(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_flgtypap          tstdisd.flgtypap%type;
    v_flgapman          tappfm.flgapman%type;
    v_codaplvl          tstdisd.codaplvl%type;

    cursor c_tappfm is
        select *
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and (flgappr = 'C' or numseq = p_numseq)
      order by numseq;
  begin

--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

    begin
        select flgtypap into v_flgtypap
          from tstdisd
         where codcomp = p_codcompy
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    select flgapman
      into v_flgapman
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    obj_row := json_object_t();
    for r_tappfm in c_tappfm loop
        if v_flgtypap = 'C' then
            if v_flgapman = '3' or p_codapman = r_tappfm.codapman or r_tappfm.numseq = p_numseq then
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('image',get_emp_img(r_tappfm.codapman));
                obj_data.put('codapman',r_tappfm.codapman);
                obj_data.put('desc_codapman',get_temploy_name(r_tappfm.codapman,global_v_lang));
                obj_data.put('codcompap',r_tappfm.codcompap);
                obj_data.put('desc_codcompap',get_tcenter_name(r_tappfm.codcompap,global_v_lang));
                obj_data.put('codposap',r_tappfm.codposap);
                obj_data.put('desc_codposap',get_tpostn_name(r_tappfm.codposap,global_v_lang));
                obj_data.put('dteapman',to_char(r_tappfm.dteapman,'dd/mm/yyyy'));
                obj_data.put('flgapman',r_tappfm.flgapman);
                obj_data.put('desc_flgapman',get_tlistval_name('FLGDISP',r_tappfm.flgapman,global_v_lang));
                obj_data.put('numseq',r_tappfm.numseq);
                obj_row.put(to_char(v_rcnt),obj_data);
                v_rcnt := v_rcnt + 1;
            end if;
        else
            if (v_flgapman in ('1','4') and p_codapman = r_tappfm.codapman) or
               (v_flgapman = '2' and (r_tappfm.flgapman in ('1','4') or p_codapman = r_tappfm.codapman)) or
               (v_flgapman = '3') or
               (r_tappfm.numseq = p_numseq) then
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('image',get_emp_img(r_tappfm.codapman));
                obj_data.put('codapman',r_tappfm.codapman);
                obj_data.put('desc_codapman',get_temploy_name(r_tappfm.codapman,global_v_lang));
                obj_data.put('codcompap',r_tappfm.codcompap);
                obj_data.put('desc_codcompap',get_tcenter_name(r_tappfm.codcompap,global_v_lang));
                obj_data.put('codposap',r_tappfm.codposap);
                obj_data.put('desc_codposap',get_tpostn_name(r_tappfm.codposap,global_v_lang));
                obj_data.put('dteapman',to_char(r_tappfm.dteapman,'dd/mm/yyyy'));
                obj_data.put('flgapman',r_tappfm.flgapman);
                obj_data.put('desc_flgapman',get_tlistval_name('FLGDISP',r_tappfm.flgapman,global_v_lang));
                obj_data.put('numseq',r_tappfm.numseq);
                obj_row.put(to_char(v_rcnt),obj_data);
                v_rcnt := v_rcnt + 1;
            end if;
        end if;

    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_otherassessments(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_otherassessments(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure gen_workingtime_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    obj_grpleave_row    json_object_t;
    obj_punnish_row     json_object_t;
    obj_discipline_row  json_object_t;
    v_rcnt              number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    count_numseq        number;
    v_flgRightDisable   boolean;
    v_flgtypap          tstdisd.flgtypap%type;
    v_last_flgappr      tappfm.flgappr%type;
    v_flgdata           boolean;

    v_flgapman          tappfm.flgapman%type;
    v_flgappr           tappfm.flgappr%type;
    v_dteapstr          tappfm.dteapstr%type;
--    v_dteapend          tappfm.dteapend%type;
    v_dteapman          tappfm.dteapman%type;

    v_dtebhstr          tstdisd.dtebhstr%type;
    v_dtebhend          tstdisd.dtebhend%type;
    v_dteapend          tstdisd.dteapend%type;

    v_dteeffec          tattpreh.dteeffec%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;

    v_qtyleav           number;
    v_qtyscor           number;
    v_flgsal            tattpre2.flgsal%type;
    v_summary_flgsal    tattpre2.flgsal%type := 'Y';
    v_pctdedsal         tattpre2.pctdedsal%type;
    v_sum_pctdedsal     tattpre2.pctdedsal%type := 0;
    v_flgbonus          tattpre2.flgbonus%type;
    v_summary_flgbonus  tattpre2.flgbonus%type := 'Y';
    v_pctdedbon         tattpre2.pctdedbon%type;
    v_sum_pctdedbon     tattpre2.pctdedbon%type := 0;
    v_qtypunsh          number;
    v_scoreta           number;
    v_scorepunsh        number;

    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;

    v_tappemp_qtyta     tappemp.qtyta%type;
    v_tappemp_qtypuns   tappemp.qtypuns%type;
    v_tappemp_flgsal    tappemp.flgsal%type;
    v_tappemp_flgbonus  tappemp.flgbonus%type;
    v_tappemp_pctdbon   tappemp.pctdbon%type;
    v_tappemp_pctdsal   tappemp.pctdsal%type;
    v_codaplvl          tstdisd.codaplvl%type;

    cursor c_tappempta is
        select *
          from tappempta
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;

    cursor c_tappempmt is
        select *
          from tappempmt
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;

    cursor c_tattpre1 is
        select 1 type,codgrplv
          from tattpre1
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'N'
         union
        select 2 type,codgrplv
          from tattpre1
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'Y'
         union
        select 3 type,codgrplv
          from tattpre1
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'Y'
           and flglate = 'N'
      order by type;

    cursor c_tattpre3 is
        select codpunsh
          from tattpre3
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
      order by codpunsh;

  begin

--Redmine #5552
      v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

      select dtebhstr, dtebhend, dteapend
        into v_dtebhstr, v_dtebhend, v_dteapend
        from tstdisd
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codcomp = p_codcompy
--Redmine #5552
             and codaplvl = v_codaplvl;
--Redmine #5552

      begin
        select dteapstr, dteapend, dteapman, codaplvl, codcomp
          into v_dteapstr, v_dteapend, v_dteapman, p_codaplvl, p_codcomp
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
      exception when no_data_found then
        p_codaplvl  := null;
        p_codcomp   := null;
      end;

      if v_dteapend is null then
          begin
              select dteapstr,dteapend
                into v_dteapstr,v_dteapend
                from tstdisd
               where dteyreap = p_dteyreap
                 and numtime = p_numtime
                 and codcomp = p_codcompy
                 and codaplvl = v_codaplvl;
          exception when no_data_found then
            v_dteapstr  := null;
            v_dteapend   := null;
          end;
      end if;

      begin
        select qtyta, qtypuns, flgsal, flgbonus, pctdbon, pctdsal
          into v_tappemp_qtyta, v_tappemp_qtypuns, v_tappemp_flgsal, v_tappemp_flgbonus, v_tappemp_pctdbon, v_tappemp_pctdsal
          from tappemp
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
      exception when no_data_found then
        null;
      end;

      begin
          select dteeffec, scorfta, scorfpunsh
            into v_dteeffec, v_scorfta, v_scorfpunsh
            from tattpreh
           where codcompy = p_codcompy
             and codaplvl = p_codaplvl
             and dteeffec = (select max(dteeffec)
                               from tattpreh
                              where codcompy = p_codcompy
                                and codaplvl = p_codaplvl
                                and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        null;
      end;

      v_global_dteapend := v_dteapend;
      get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

      begin
          select pctta, pctpunsh
            into v_pctta, v_pctpunsh
            from taplvl
           where codcomp = v_taplvl_codcomp
             and codaplvl = p_codaplvl
             and dteeffec = v_taplvl_dteeffec;
      exception when no_data_found then
        v_pctta     := 0;
        v_pctpunsh  := 0;
      end;

      if v_tappemp_qtyta is not null or v_tappemp_qtypuns is not null then
          v_summary_flgsal      := v_tappemp_flgsal;
          v_summary_flgbonus    := v_tappemp_flgbonus;
          v_sum_pctdedsal       := v_tappemp_pctdsal;
          v_sum_pctdedbon       := v_tappemp_pctdbon;

          v_rcnt                := 0;
          v_scoreta             := v_scorfta;
          obj_grpleave_row      := json_object_t();
          for r_tappempta in c_tappempta loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codgrplv',r_tappempta.codgrplv);
            obj_data.put('desc_codgrplv',get_tlistval_name('GRPLEAVE',r_tappempta.codgrplv,global_v_lang));
            obj_data.put('qtyleav', nvl(r_tappempta.qtyleav,0));
            obj_data.put('qtyscor',nvl(r_tappempta.qtyscor,0));
            obj_grpleave_row.put(to_char(v_rcnt-1),obj_data);
            v_scoreta       := v_scoreta - nvl(r_tappempta.qtyscor,0);
          end loop;

          v_rcnt            := 0;
          v_scorepunsh      := v_scorfpunsh;
          obj_punnish_row   := json_object_t();
          for r_tappempmt in c_tappempmt loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();

            obj_data.put('coderror','200');
            obj_data.put('codpunsh',r_tappempmt.codpunsh);
            obj_data.put('desc_codpunsh',get_tcodec_name('TCODPUNH', r_tappempmt.codpunsh, global_v_lang));
            obj_data.put('qtypunsh', nvl(r_tappempmt.qtypunsh,0));
            obj_data.put('qtyscor',nvl(r_tappempmt.qtyscor,0));
            obj_punnish_row.put(to_char(v_rcnt-1),obj_data);
            v_scorepunsh            := v_scorepunsh - nvl(r_tappempmt.qtyscor,0);
          end loop;
      else
          v_rcnt    := 0;
          v_scoreta := v_scorfta;
          obj_grpleave_row := json_object_t();
          for r_tattpre1 in c_tattpre1 loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codgrplv',r_tattpre1.codgrplv);
            obj_data.put('desc_codgrplv',get_tlistval_name('GRPLEAVE',r_tattpre1.codgrplv,global_v_lang));

            if r_tattpre1.type = 1 then
                select nvl(sum(qtyday),0)
                  into v_qtyleav
                  from tleavetr a, tattprelv b
                 where a.codempid = p_codempid_query
                   and a.dtework between v_dtebhstr and v_dtebhend
                   and a.codleave = b.codleave
                   and b.codaplvl = p_codaplvl
                   and b.dteeffec = v_dteeffec
                   and b.codgrplv = r_tattpre1.codgrplv;
            elsif r_tattpre1.type = 2 then
                select sum(nvl(qtytlate,0) + nvl(qtytearly,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = p_codempid_query
                   and dtework between v_dtebhstr and v_dtebhend;
            elsif r_tattpre1.type = 3 then
                select sum(nvl(qtytabs,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = p_codempid_query
                   and dtework between v_dtebhstr and v_dtebhend;
            end if;

            begin
                select scorded, flgsal, pctdedsal, flgbonus, pctdedbon
                  into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
                  from tattpre2
                 where codcompy = p_codcompy
                   and codaplvl = p_codaplvl
                   and dteeffec = v_dteeffec
                   and codgrplv = r_tattpre1.codgrplv
                   and v_qtyleav between qtymin and qtymax
              order by qtymin;
            exception when no_data_found then
                v_qtyscor := 0;
                v_flgsal    := 'Y';
                v_pctdedsal := 0;
                v_flgbonus  := 'Y';
                v_pctdedbon := 0;
            end;

            obj_data.put('qtyleav', nvl(v_qtyleav,0));
            obj_data.put('qtyscor',nvl(v_qtyscor,0));
            obj_grpleave_row.put(to_char(v_rcnt-1),obj_data);
            v_scoreta           := v_scoreta - nvl(v_qtyscor,0);
            v_sum_pctdedsal     := v_sum_pctdedsal + v_pctdedsal;
            v_sum_pctdedbon     := v_sum_pctdedbon + v_pctdedbon;
            if v_flgsal = 'N' then
                v_summary_flgsal := 'N';
            end if;
            if v_flgbonus = 'N' then
                v_summary_flgbonus := 'N';
            end if;
          end loop;

          v_rcnt            := 0;
          v_scorepunsh      := v_scorfpunsh;
          obj_punnish_row   := json_object_t();

          for r_tattpre3 in c_tattpre3 loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();

            select count(*)
              into v_qtypunsh
              from thispun
             where codempid = p_codempid_query
               and codpunsh = r_tattpre3.codpunsh
               and dteeffec between v_dtebhstr and v_dtebhend;

            begin
                select scoreded, flgsal, pctdedsal, flgbonus, pctdedbonus
                  into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
                  from tattpre4
                 where codcompy = p_codcompy
                   and codaplvl = p_codaplvl
                   and dteeffec = v_dteeffec
                   and codpunsh = r_tattpre3.codpunsh
                   and v_qtypunsh between qtymin and qtymax
                order by qtymin;
            exception when no_data_found then
                v_qtyscor       := 0;
                v_flgsal        := 'Y';
                v_pctdedsal     := 0;
                v_flgbonus      := 'Y';
                v_pctdedbon     := 0;
            end;

            obj_data.put('coderror','200');
            obj_data.put('codpunsh',r_tattpre3.codpunsh);
            obj_data.put('desc_codpunsh',get_tcodec_name('TCODPUNH', r_tattpre3.codpunsh, global_v_lang));
            obj_data.put('qtypunsh', nvl(v_qtypunsh,0));
            obj_data.put('qtyscor',nvl(v_qtyscor,0));
            obj_punnish_row.put(to_char(v_rcnt-1),obj_data);
            v_scorepunsh            := v_scorepunsh - nvl(v_qtyscor,0);
            v_sum_pctdedsal         := v_sum_pctdedsal + v_pctdedsal;
            v_sum_pctdedbon         := v_sum_pctdedbon + v_pctdedbon;
            if v_flgsal = 'N' then
                v_summary_flgsal := 'N';
            end if;
            if v_flgbonus = 'N' then
                v_summary_flgbonus := 'N';
            end if;
          end loop;

          if v_summary_flgsal = 'N' then
            v_sum_pctdedsal := 0;
          end if;
          if v_summary_flgbonus = 'N' then
            v_sum_pctdedbon := 0;
          end if;
      end if;

      v_rcnt                := 0;
      obj_discipline_row    := json_object_t();
      v_rcnt                := v_rcnt + 1;
      obj_data              := json_object_t();
      v_scoreta             := greatest(v_scoreta,0);
      obj_data.put('description',get_label_name('HRAP31E1', global_v_lang, 210));
      obj_data.put('fullscore',v_scorfta);
      obj_data.put('reducescore',v_scorfta-v_scoreta);
      obj_data.put('qtyscore',v_scoreta);
      obj_data.put('weight',v_pctta);
      obj_data.put('netscore',round((v_pctta * v_scoreta)/(v_pctta * v_scorfta) * 100,2));
--      obj_data.put('netscore',round((v_pctta * v_scoreta),2));
      obj_discipline_row.put(to_char(v_rcnt-1),obj_data);

      v_rcnt                := v_rcnt + 1;
      obj_data              := json_object_t();
      v_scorepunsh          := greatest(v_scorepunsh,0);
      obj_data.put('description',get_label_name('HRAP31E1', global_v_lang, 220));
      obj_data.put('fullscore',v_scorfpunsh);
      obj_data.put('reducescore',v_scorfpunsh-v_scorepunsh);
      obj_data.put('qtyscore',v_scorepunsh);
      obj_data.put('weight',v_pctpunsh);
      obj_data.put('netscore',round((v_pctpunsh * v_scorepunsh) / (v_pctpunsh * v_scorfpunsh) * 100,2));
      obj_discipline_row.put(to_char(v_rcnt-1),obj_data);


      obj_detail      := json_object_t();
      obj_detail.put('coderror','200');
      obj_detail.put('codempid',p_codempid_query);
      obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
      obj_detail.put('dteyreap',p_dteyreap);
      obj_detail.put('numtime',p_numtime);
      obj_detail.put('numseq',p_numseq);
      obj_detail.put('codapman',p_codapman);
      obj_detail.put('desc_codapman',get_temploy_name(p_codapman,global_v_lang));
      obj_detail.put('dteapman',to_char(v_dteapman,'dd/mm/yyyy'));
      obj_detail.put('dteapstr',to_char(v_dteapstr,'dd/mm/yyyy'));
      obj_detail.put('dteapend',to_char(v_dteapend,'dd/mm/yyyy'));
      obj_detail.put('flgsal',v_summary_flgsal);
      obj_detail.put('flgbonus',v_summary_flgbonus);
      obj_detail.put('pctdsal',v_sum_pctdedsal);
      obj_detail.put('pctdbon',v_sum_pctdedbon);
      obj_detail.put('scorf',v_scorfta + v_scorfpunsh);
      obj_detail.put('score',v_scoreta + v_scorepunsh);
      obj_detail.put('scorfta',v_scorfta);      
      obj_detail.put('scoreta',v_tappemp_qtyta);
      --obj_detail.put('scoreta',v_scoreta);  --#7434     
      obj_detail.put('scorfpunsh',v_scorfpunsh);     
      obj_detail.put('scorepunsh',v_tappemp_qtypuns);
      --obj_detail.put('scorepunsh',v_scorepunsh);  --#7434

      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('detail', obj_detail);
      obj_data.put('leaveGroupTable', obj_grpleave_row);
      obj_data.put('workTable', obj_punnish_row);
      obj_data.put('disciplineTable', obj_discipline_row);

      json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_workingtime_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_workingtime_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_behavior_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    v_dteapend          tstdisd.dteapend%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_codform           taplvl.codform%type;
    v_flgapman          tappfm.flgapman%type;
    v_numseq            tappfm.numseq%type;
    v_remarkbeh         tappfm.remarkbeh%type;
    v_commtbeh          tappfm.commtbeh%type;
    v_qtyscorn          tappbehg.qtyscorn%type;
    v_qtyscorn1         tappbehg.qtyscorn%type;
    v_qtyscorn2         tappbehg.qtyscorn%type;
    v_qtyscorn3         tappbehg.qtyscorn%type;
    v_max_numseq        tappfm.numseq%type;
    v_numgrup           tappbehg.numgrup%type;
    v_codaplvl          tstdisd.codaplvl%type;

    cursor c_tintvews is
        select numgrup, decode(global_v_lang, '101', desgrupe,
                                   '102', desgrupt,
                                   '103', desgrup3,
                                   '104', desgrup4,
                                   '105', desgrup5,
                                   '') desgrup,qtyfscor
          from tintvews
         where codform = v_codform
      order by numgrup;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
      group by flgapman;

    cursor c_tappbehg is
        select qtyscorn
          from tappbehg
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numgrup = v_numgrup
           and numseq = v_max_numseq;
  begin
    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select dteapend, flgtypap
          into v_dteapend, v_flgtypap
          from tstdisd
         where codcomp = p_codcompy
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when no_data_found then
        v_dteapend := null;
    end;

    begin
        select remarkbeh, commtbeh, codaplvl, codcomp, flgapman
          into v_remarkbeh, v_commtbeh, p_codaplvl, p_codcomp, v_flgapman
          from tappfm
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
           and codempid = p_codempid_query;
    exception when others then
        v_remarkbeh := null;
        v_commtbeh  := null;
    end;

    v_global_dteapend := v_dteapend;
    get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

    begin
        select codform
          into v_codform
          from taplvl
         where codcomp =  v_taplvl_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
        v_codform := null;
    end;

    if v_codform is null then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPLVL');
        return;
    end if;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('codcompy',p_codcompy);
    obj_detail.put('codempid',p_codempid_query);
    obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
    obj_detail.put('dteyreap',p_dteyreap);
    obj_detail.put('numtime',p_numtime);
    obj_detail.put('numseq',p_numseq);
    obj_detail.put('codapman',p_codapman);
    obj_detail.put('desc_codapman',get_temploy_name(p_codapman,global_v_lang));
    obj_detail.put('codform',v_codform);
    obj_detail.put('desc_codform', get_tintview_name(v_codform,global_v_lang));
    obj_detail.put('remarkbeh',v_remarkbeh);
    obj_detail.put('commtbeh',v_commtbeh);

    v_rcnt := 0;
    obj_row := json_object_t();
    for r_tintvews in c_tintvews loop
        obj_data    := json_object_t();
        v_numgrup   := r_tintvews.numgrup;
        obj_data.put('numgrup',r_tintvews.numgrup);
        obj_data.put('desgrup',r_tintvews.desgrup);

        begin
            select qtyscorn
              into v_qtyscorn
              from tappbehg
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numgrup = v_numgrup
               and numseq = p_numseq;
        exception when no_data_found then
            if v_flgtypap = 'T' then
                begin
                    select qtyscorn
                      into v_qtyscorn
                      from tappbehg
                     where codempid = p_codempid_query
                       and dteyreap = p_dteyreap
                       and numtime = p_numtime
                       and numgrup = v_numgrup
                       and numseq = p_numseq - 1;
                exception when no_data_found then
                    v_qtyscorn := null;
                end;
            else
                v_qtyscorn := null;
            end if;
        end;
        if v_flgapman in ('1','4') then
            v_qtyscorn1 := v_qtyscorn;
        elsif v_flgapman = '2' then
            v_qtyscorn2 := v_qtyscorn;
        elsif v_flgapman = '3' then
            v_qtyscorn3 := v_qtyscorn;
        end if;

        for r2 in c_flgapman loop
            v_max_numseq := r2.numseq;
            for r3 in c_tappbehg loop
                if r2.flgapman in ('1','4') then
                    v_qtyscorn1 := r3.qtyscorn;
                elsif r2.flgapman = '2' then
                    v_qtyscorn2 := r3.qtyscorn;
                elsif r2.flgapman = '3' then
                    v_qtyscorn3 := r3.qtyscorn;
                end if;
            end loop;
        end loop;

        if v_flgtypap = 'C' then
            if v_flgapman != '3' then
                if v_flgapman in ('1','4') then
                    v_qtyscorn2  := null;
                    v_qtyscorn3  := null;
                elsif v_flgapman = '2' then
                    v_qtyscorn1  := null;
                    v_qtyscorn3  := null;
                end if;
            end if;
        elsif v_flgtypap = 'T' then
            if v_flgapman in ('1','4') then
                v_qtyscorn2  := null;
                v_qtyscorn3  := null;
            elsif v_flgapman = '2' then
                v_qtyscorn3  := null;
            end if;
        end if;

        obj_data.put('qtyscorn1',v_qtyscorn1);
        obj_data.put('qtyscorn2',v_qtyscorn2);
        obj_data.put('qtyscorn3',v_qtyscorn3);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
    end loop;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('table',obj_row);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_behavior_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_behavior_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure gen_behaviorSub(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    v_dteapend          tstdisd.dteapend%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_flgapman          tappfm.flgapman%type;
    v_qtyscorn          tappbehi.qtyscorn%type;
    v_qtyscorn1         tappbehi.qtyscorn%type;
    v_qtyscorn2         tappbehi.qtyscorn%type;
    v_qtyscorn3         tappbehi.qtyscorn%type;
    v_grdscor           tappbehi.grdscor%type;
    v_grdscor1          tappbehi.grdscor%type;
    v_grdscor2          tappbehi.grdscor%type;
    v_grdscor3          tappbehi.grdscor%type;
    v_numgrup           tintvewd.numgrup%type;
    v_numitem           tintvewd.numgrup%type;
    v_remark            tappbehi.remark%type;
    v_max_numseq        tappfm.numseq%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgEdit           boolean;
    cursor c_tintvews is
        select numgrup, decode(global_v_lang, '101', desgrupe,
                                   '102', desgrupt,
                                   '103', desgrup3,
                                   '104', desgrup4,
                                   '105', desgrup5,
                                   '') desgrup
          from tintvews
         where codform = p_codform
      order by numgrup;

    cursor c_tintvewd is
        select numitem,qtywgt,
               decode(global_v_lang, '101', desiteme,
                                     '102', desitemt,
                                     '103', desitem3,
                                     '104', desitem4,
                                     '105', desitem5,
                                     '') desitem,
               decode(global_v_lang, '101', definite,
                                     '102', definitt,
                                     '103', definit3,
                                     '104', definit4,
                                     '105', definit5,
                                    '') definit
          from tintvewd
         where codform = p_codform
           and numgrup = v_numgrup
      order by numitem;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
        group by flgapman;

    cursor c_tappbehi is
            select qtyscorn, grdscor
              from tappbehi
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numgrup = v_numgrup
               and numitem  = v_numitem
               and numseq = v_max_numseq;
  begin
    select flgapman, hcm_util.get_codcomp_level(codcomp,1)
      into v_flgapman, p_codcompy
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

    select flgtypap
      into v_flgtypap
      from tstdisd
     where codcomp = p_codcompy
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--Redmine #5552
       and codaplvl = v_codaplvl;
--Redmine #5552
    v_rcnt := 0;
    obj_row := json_object_t();
    for r_tintvews in c_tintvews loop
        v_numgrup := r_tintvews.numgrup;
        obj_data := json_object_t();
        obj_data.put('numitem',get_label_name('HRAP31E1', global_v_lang, 230)||r_tintvews.numgrup);
        obj_data.put('numgrup','');
        obj_data.put('desitem',r_tintvews.desgrup);
        obj_data.put('definit','');
        obj_data.put('qtywgt','');
        obj_data.put('grdscor1','');
        obj_data.put('grdscor2','');
        obj_data.put('grdscor3','');
        obj_data.put('qtyscorn1','');
        obj_data.put('qtyscorn2','');
        obj_data.put('qtyscorn3','');
        obj_data.put('remark','');
        obj_data.put('flgNumgrup','Y');
        obj_data.put('flgapman',v_flgapman);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;

        for r_tintvewd in c_tintvewd loop
            v_numitem := r_tintvewd.numitem;
            v_flgEdit   := false;
            begin
                select qtyscorn, grdscor, remark
                  into v_qtyscorn, v_grdscor, v_remark
                  from tappbehi
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numgrup = v_numgrup
                   and numitem  = v_numitem
                   and numseq = p_numseq;
            exception when no_data_found then
                if v_flgtypap = 'T' then
                    begin
                        select qtyscorn, grdscor, remark
                          into v_qtyscorn, v_grdscor, v_remark
                          from tappbehi
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numgrup = v_numgrup
                           and numitem  = v_numitem
                           and numseq = p_numseq - 1 ;
                        v_flgEdit   := true;
                    exception when no_data_found then
                        v_qtyscorn  := 0;
                        v_grdscor   := '';
                        v_remark    := '';
                    end;
                else
                    v_qtyscorn  := 0;
                    v_grdscor   := '';
                    v_remark    := '';
                end if;

            end;

            for r3 in c_flgapman loop
                v_max_numseq := r3.numseq;
                for r4 in c_tappbehi loop
                    if r3.flgapman in ('1','4') then
                        v_qtyscorn1     := r4.qtyscorn;
                        v_grdscor1      := r4.grdscor;
                    elsif r3.flgapman = '2' then
                        v_qtyscorn2     := r4.qtyscorn;
                        v_grdscor2      := r4.grdscor;
                    elsif r3.flgapman = '3' then
                        v_qtyscorn3     := r4.qtyscorn;
                        v_grdscor3      := r4.grdscor;
                    end if;
                end loop;
            end loop;

            if v_flgapman in ('1','4') then
                v_qtyscorn1 := v_qtyscorn;
                v_grdscor1 := v_grdscor;
            elsif v_flgapman = '2' then
                v_qtyscorn2 := v_qtyscorn;
                v_grdscor2 := v_grdscor;
            elsif v_flgapman = '3' then
                v_qtyscorn3 := v_qtyscorn;
                v_grdscor3 := v_grdscor;
            end if;

            if v_flgtypap = 'C' then
                if v_flgapman != '3' then
                    if v_flgapman in ('1','4') then
                        v_qtyscorn2     := null;
                        v_grdscor2      := null;
                        v_qtyscorn3     := null;
                        v_grdscor3      := null;
                    elsif v_flgapman = '2' then
                        v_qtyscorn1     := null;
                        v_grdscor1      := null;
                        v_qtyscorn3     := null;
                        v_grdscor3      := null;
                    end if;
                end if;
            elsif v_flgtypap = 'T' then
                if v_flgapman in ('1','4') then
                    v_grdscor2      := null;
                    v_qtyscorn2     := null;
                    v_grdscor3      := null;
                    v_qtyscorn3     := null;
                elsif v_flgapman = '2' then
                    v_grdscor3      := null;
                    v_qtyscorn3     := null;
                end if;
            end if;

            obj_data := json_object_t();
            obj_data.put('numitem',r_tintvewd.numitem);
            obj_data.put('numgrup',r_tintvews.numgrup);
            obj_data.put('desitem',r_tintvewd.desitem);
            obj_data.put('definit',r_tintvewd.definit);
            obj_data.put('qtywgt',r_tintvewd.qtywgt);
            obj_data.put('grdscor1',v_grdscor1);
            obj_data.put('grdscor2',v_grdscor2);
            obj_data.put('grdscor3',v_grdscor3);
            obj_data.put('qtyscorn1',v_qtyscorn1);
            obj_data.put('qtyscorn2',v_qtyscorn2);
            obj_data.put('qtyscorn3',v_qtyscorn3);
            obj_data.put('remark',v_remark);
            obj_data.put('flgNumgrup','N');
            obj_data.put('flgapman',v_flgapman);
            obj_data.put('flgEdit',v_flgEdit);

            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_behaviorSub(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_behaviorSub(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure gen_competency_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    obj_row_competency  json_object_t;
    obj_row_course      json_object_t;
    obj_row_develop     json_object_t;
    v_codform           taplvl.codform%type;
    v_flgapman          tappfm.flgapman%type;
    v_dteapman          tappfm.dteapman%type;
    v_dteapstr          tappfm.dteapstr%type;
--    v_dteapend          tappfm.dteapend%type;
    v_numseq            tappfm.numseq%type;
    v_max_numseq        tappfm.numseq%type;

    v_qtyscor           tappcmpc.qtyscor%type;
    v_qtyscor1          tappcmpc.qtyscor%type;
    v_qtyscor2          tappcmpc.qtyscor%type;
    v_qtyscor3          tappcmpc.qtyscor%type;
    v_qtyscorn          tappcmpc.qtyscorn%type;
    v_qtyscorn1         tappcmpc.qtyscorn%type;
    v_qtyscorn2         tappcmpc.qtyscorn%type;
    v_qtyscorn3         tappcmpc.qtyscorn%type;
    v_remarkcmp         tappfm.remarkcmp%type;
    v_commtcmp          tappfm.commtcmp%type;
    v_codpos            tappfm.codpos%type;
    v_jobgrade          tappfm.jobgrade%type;
    v_dteapend          tstdisd.dteapend%type;
    v_taplvld_codcomp   taplvld.codcomp%type;
    v_taplvld_dteeffec  taplvld.dteeffec%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_codtency          tappcmpc.codtency%type;
    v_qtycmp            tappfm.qtycmp%type;
    v_count_tapptrn     number;

    cursor c_taplvld_where is
      select dteeffec,codcomp
        from taplvld
       where p_codcomp like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_dteapend
      order by codcomp desc,dteeffec desc;

    cursor c_taplvld is
        select *
          from taplvld
         where codcomp = v_taplvld_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_taplvld_dteeffec
      order by codtency;

    cursor c_tapptrn is
        select *
          from tapptrn
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
      order by codcours;

    cursor c_tappdev is
        select *
          from tappdev
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
      order by numseq2;

    cursor c_tapptrn_pre is
        select *
          from tapptrn
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq - 1
      order by codcours;

    cursor c_tappdev_pre is
        select *
          from tappdev
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq - 1
      order by numseq2;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
      group by flgapman;

    cursor c_tappcmpc is
        select a.qtyscor,a.qtyscorn
          from tappcmpc a
         where a.codempid = p_codempid_query
           and a.dteyreap = p_dteyreap
           and a.numtime = p_numtime
           and a.numseq = v_max_numseq
           and a.codtency = v_codtency;
  begin
    begin
    select flgapman, dteapman, dteapstr,  remarkcmp, commtcmp, codpos, jobgrade, codaplvl, codcomp, qtycmp
      into v_flgapman, v_dteapman, v_dteapstr, v_remarkcmp, v_commtcmp, v_codpos, v_jobgrade, p_codaplvl,p_codcomp, v_qtycmp
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;
    exception when others then
        null;
    end;

    begin
        select count(codcours)
          into v_count_tapptrn
          from tapptrn
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
    exception when others then
        v_count_tapptrn := 0;
    end;

--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

    select dteapend,flgtypap
      into v_dteapend, v_flgtypap
      from tstdisd
     where codcomp = p_codcompy
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--Redmine #5552
       and codaplvl = v_codaplvl;
--Redmine #5552

    for r_taplvld in c_taplvld_where loop
      v_taplvld_dteeffec    := r_taplvld.dteeffec;
      v_taplvld_codcomp     := r_taplvld.codcomp;
      exit;
    end loop;

    if v_jobgrade is null then
        begin
            select jobgrade
              into v_jobgrade
              from temploy1
             where codempid = p_codempid_query;
        exception when others then
            v_jobgrade := null;
        end;
    end if;

    v_rcnt := 0;
    obj_row_competency := json_object_t();
    for r1 in c_taplvld loop
        v_codtency  := r1.codtency;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codtency',get_tcomptnc_name(r1.codtency, global_v_lang));
        obj_data.put('codtency_',r1.codtency);
        obj_data.put('qtywgt',r1.qtywgt);

        begin
            select qtyscor,qtyscorn
              into v_qtyscor,v_qtyscorn
              from tappcmpc
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and codtency = r1.codtency;
        exception when no_data_found then
            if v_flgtypap = 'T' then
                begin
                    select qtyscor,qtyscorn
                      into v_qtyscor,v_qtyscorn
                      from tappcmpc
                     where codempid = p_codempid_query
                       and dteyreap = p_dteyreap
                       and numtime = p_numtime
                       and numseq = p_numseq - 1
                       and codtency = r1.codtency;
                exception when no_data_found then
                    v_qtyscor   := 0;
                    v_qtyscorn  := 0;
                end;
            else
                v_qtyscor   := 0;
                v_qtyscorn  := 0;
            end if;
        end;

        for r3 in c_flgapman loop
            v_max_numseq := r3.numseq;
            for r4 in c_tappcmpc loop
                if r3.flgapman in ('1','4') then
                    v_qtyscor1      := r4.qtyscor;
                    v_qtyscorn1     := r4.qtyscorn;
                elsif r3.flgapman = '2' then
                    v_qtyscor2      := r4.qtyscor;
                    v_qtyscorn2     := r4.qtyscorn;
                elsif r3.flgapman = '3' then
                    v_qtyscor3      := r4.qtyscor;
                    v_qtyscorn3     := r4.qtyscorn;
                end if;
            end loop;
        end loop;

        if v_flgapman in ('1','4') then
            v_qtyscor1  := v_qtyscor;
            v_qtyscorn1 := v_qtyscorn;
        elsif v_flgapman = '2' then
            v_qtyscor2  := v_qtyscor;
            v_qtyscorn2 := v_qtyscorn;
        elsif v_flgapman = '3' then
            v_qtyscor3  := v_qtyscor;
            v_qtyscorn3 := v_qtyscorn;
        end if;

        obj_data.put('qtyscor1',v_qtyscor1);
        obj_data.put('qtyscor2',v_qtyscor2);
        obj_data.put('qtyscor3',v_qtyscor3);

        obj_data.put('qtyscorn1',v_qtyscor1 * r1.qtywgt);
        obj_data.put('qtyscorn2',v_qtyscor2 * r1.qtywgt);
        obj_data.put('qtyscorn3',v_qtyscor3 * r1.qtywgt);

--        obj_data.put('qtyscorn1',v_qtyscorn1);
--        obj_data.put('qtyscorn2',v_qtyscorn2);
--        obj_data.put('qtyscorn3',v_qtyscorn3);
        obj_row_competency.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
    end loop;

    if obj_row_competency.get_size = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPLVLD');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    if v_qtycmp is not null or v_count_tapptrn > 0 then
        v_rcnt := 0;
        obj_row_course := json_object_t();
        for r1 in c_tapptrn loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcours',r1.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
            obj_row_course.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;

        v_rcnt := 0;
        obj_row_develop := json_object_t();
        for r1 in c_tappdev loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('coddevp',r1.coddevp);
            obj_data.put('desdevp',r1.desdevp);
            obj_row_develop.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;
    elsif v_qtycmp is null and v_flgtypap = 'T' then
        v_rcnt := 0;
        obj_row_course := json_object_t();
        for r1 in c_tapptrn_pre loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcours',r1.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
            obj_data.put('flgAdd',true);
            obj_row_course.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;

        v_rcnt := 0;
        obj_row_develop := json_object_t();
        for r1 in c_tappdev_pre loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('coddevp',r1.coddevp);
            obj_data.put('desdevp',r1.desdevp);
            obj_data.put('flgAdd',true);
            obj_row_develop.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;
    end if;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('codcompy',p_codcompy);
    obj_detail.put('codempid',p_codempid_query);
    obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
    obj_detail.put('dteyreap',p_dteyreap);
    obj_detail.put('numtime',p_numtime);
    obj_detail.put('numseq',p_numseq);
    obj_detail.put('codapman',p_codapman);
    obj_detail.put('desc_codapman',get_temploy_name(p_codapman,global_v_lang));
    obj_detail.put('codpos',v_codpos);
    obj_detail.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_detail.put('jobgrade',v_jobgrade);
    obj_detail.put('desc_jobgrade',get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));
    obj_detail.put('remarkcmp',v_remarkcmp);
    obj_detail.put('commtcmp',v_commtcmp);

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('competencyTable',obj_row_competency);
    obj_data.put('courseTable',obj_row_course);
    obj_data.put('developTable',obj_row_develop);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_competency_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_competency_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure gen_competencysub(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_dteapend          tstdisd.dteapend%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_expectgrade       tjobposskil.grade%type;
    v_grade             tappcmps.grade%type;
    v_grade1            tappcmps.grade%type;
    v_grade2            tappcmps.grade%type;
    v_grade3            tappcmps.grade%type;
    v_qtyscor           tappcmps.qtyscor%type;
    v_qtyscor1          tappcmps.qtyscor%type;
    v_qtyscor2          tappcmps.qtyscor%type;
    v_qtyscor3          tappcmps.qtyscor%type;
    v_flgapman          tappfm.flgapman%type;
    v_remark            tappcmps.remark%type;
    v_codtency          tappcmps.codtency%type;
    v_codskill          tappcmps.codskill%type;
    v_max_numseq        tappfm.numseq%type;
    v_rcnt_tcomptcr     number := 0;
    obj_row_tcomptcr    json_object_t;
    obj_data_tcomptcr   json_object_t;
    v_rcnt_tcomptdev    number := 0;
    obj_row_tcomptdev   json_object_t;
    obj_data_tcomptdev  json_object_t;
    v_taplvld_codcomp   taplvld.codcomp%type;
    v_taplvld_dteeffec  taplvld.dteeffec%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgEdit           boolean;
    v_count_course      number;

    cursor c_taplvld_where is
      select dteeffec,codcomp
        from taplvld
       where p_codcomp like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_dteapend
      order by codcomp desc,dteeffec desc;

    cursor c_taplvld is
        select *
          from taplvld
         where v_taplvld_codcomp = codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_taplvld_dteeffec
      order by codtency;

    cursor c_tjobposskil is
        select *
          from tjobposskil
         where codpos = p_codpos
           and codcomp = p_codcomp
           and codtency = v_codtency
      order by codskill;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
      group by flgapman;

    cursor c_tappcmps is
        select a.grade, a.qtyscor
          from tappcmps a
         where a.codempid = p_codempid_query
           and a.dteyreap = p_dteyreap
           and a.numtime = p_numtime
           and a.numseq = v_max_numseq
           and a.codtency = v_codtency
           and a.codskill = v_codskill;

    cursor c_tcomptcr is
        select *
          from tcomptcr
         where codskill = v_codskill
           and grade between v_grade + 1 and v_expectgrade
      order by codcours;

    cursor c_tcomptdev is
        select *
          from tcomptdev
         where codskill = v_codskill
           and grade between v_grade + 1 and v_expectgrade
      order by coddevp;
  begin
    select flgapman, codcomp, codaplvl, codpos
      into v_flgapman, p_codcomp, p_codaplvl, p_codpos
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552

    select dteapend, flgtypap
      into v_dteapend, v_flgtypap
      from tstdisd
     where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--Redmine #5552
       and codaplvl = v_codaplvl;
--Redmine #5552

    for r_taplvld in c_taplvld_where loop
      v_taplvld_dteeffec    := r_taplvld.dteeffec;
      v_taplvld_codcomp     := r_taplvld.codcomp;
      exit;
    end loop;

    obj_row := json_object_t();
    for r1 in c_taplvld loop
        obj_data            := json_object_t();
        obj_row_tcomptcr    := json_object_t();
        obj_row_tcomptdev   := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('icon','');
        obj_data.put('codtency','');
        obj_data.put('codskill',get_tcomptnc_name(r1.codtency, global_v_lang));
        obj_data.put('desc_codskill','');
        obj_data.put('grade','');
        obj_data.put('grade1','');
        obj_data.put('grade2','');
        obj_data.put('grade3','');
        obj_data.put('qtyscor1','');
        obj_data.put('qtyscor2','');
        obj_data.put('qtyscor3','');
        obj_data.put('remark','');
        obj_data.put('flgCodtency','Y');
        obj_data.put('flgapman','');
        obj_data.put('codcomp',p_codcomp);
        obj_data.put('codpos',p_codpos);
        obj_data.put('courseTable',obj_row_tcomptcr);
        obj_data.put('developTable',obj_row_tcomptdev);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
        v_codtency := r1.codtency;
        for r2 in c_tjobposskil loop
            v_expectgrade := r2.grade;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('icon','<i class="fa fa-book"></i>');
            obj_data.put('codtency',r2.codtency);
            obj_data.put('codskill',r2.codskill);
            obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r2.codskill, global_v_lang));
            obj_data.put('grade',r2.grade);
            obj_data.put('exp_score',r2.score);


            v_codskill := r2.codskill;

            v_flgEdit   := false;

            begin
                select grade, qtyscor, remark
                  into v_grade, v_qtyscor, v_remark
                  from tappcmps
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq
                   and codtency = r2.codtency
                   and codskill = r2.codskill;
            exception when no_data_found then
                if v_flgtypap = 'T' then
                    begin
                        select grade, qtyscor, remark
                          into v_grade, v_qtyscor, v_remark
                          from tappcmps
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq - 1
                           and codtency = r2.codtency
                           and codskill = r2.codskill;
                        v_flgEdit := true;
                    exception when no_data_found then
                        v_grade     := '';
                        v_qtyscor   := 0;
                        v_remark    := '';
                    end;
                else
                    v_grade     := '';
                    v_qtyscor   := 0;
                    v_remark    := '';
                end if;
            end;

            for r3 in c_flgapman loop
                v_max_numseq := r3.numseq;
                for r4 in c_tappcmps loop
                    if r3.flgapman in ('1','4') then
                        v_qtyscor1 := r4.qtyscor;
                        v_grade1    := r4.grade;
                    elsif r3.flgapman = '2' then
                        v_qtyscor2 := r4.qtyscor;
                        v_grade2    := r4.grade;
                    elsif r3.flgapman = '3' then
                        v_qtyscor3 := r4.qtyscor;
                        v_grade3    := r4.grade;
                    end if;
                end loop;
            end loop;

            if v_flgapman in ('1','4') then
                v_qtyscor1 := v_qtyscor;
                v_grade1    := v_grade;
            elsif v_flgapman = '2' then
                v_qtyscor2 := v_qtyscor;
                v_grade2    := v_grade;
            elsif v_flgapman = '3' then
                v_qtyscor3 := v_qtyscor;
                v_grade3    := v_grade;
            end if;

            if v_flgtypap = 'C' then
                if v_flgapman != '3' then
                    if v_flgapman in ('1','4') then
                        v_qtyscor2  := null;
                        v_grade2    := null;
                        v_qtyscor3  := null;
                        v_grade3    := null;
                    elsif v_flgapman = '2' then
                        v_qtyscor1  := null;
                        v_grade1    := null;
                        v_qtyscor3  := null;
                        v_grade3    := null;
                    end if;
                end if;
            elsif v_flgtypap = 'T' then
                if v_flgapman in ('1','4') then
                    v_qtyscor2  := null;
                    v_grade2    := null;
                    v_qtyscor3  := null;
                    v_grade3    := null;
                elsif v_flgapman = '2' then
                    v_qtyscor3  := null;
                    v_grade3    := null;
                end if;
            end if;

            v_rcnt_tcomptcr     := 0;
            obj_row_tcomptcr    := json_object_t();
            for r_tcomptcr in c_tcomptcr loop
                obj_data_tcomptcr := json_object_t();
                obj_data_tcomptcr.put('coderror','200');
                if v_flgEdit and v_flgtypap = 'T' then
                    begin
                        select count(*)
                          into v_count_course
                          from tapptrn
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq - 1
                           and codcours = r_tcomptcr.codcours;
                    exception when others then
                        v_count_course := 0;
                    end;

                    if v_count_course > 0 then
                        obj_data_tcomptcr.put('flgcours','Y');
                        obj_data_tcomptcr.put('flgcours_',true);
                    else
                        obj_data_tcomptcr.put('flgcours','');
                        obj_data_tcomptcr.put('flgcours_','');
                    end if;
                else
                    begin
                        select count(*)
                          into v_count_course
                          from tapptrn
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq
                           and codcours = r_tcomptcr.codcours;
                    exception when others then
                        v_count_course := 0;
                    end;

                    if v_count_course > 0 then
                        obj_data_tcomptcr.put('flgcours','Y');
                        obj_data_tcomptcr.put('flgcours_',true);
                    else
                        obj_data_tcomptcr.put('flgcours','');
                        obj_data_tcomptcr.put('flgcours_','');
                    end if;
                end if;
                obj_data_tcomptcr.put('codcours',r_tcomptcr.codcours);
                obj_data_tcomptcr.put('desc_codcours',get_tcourse_name(r_tcomptcr.codcours,global_v_lang));
                obj_row_tcomptcr.put(to_char(v_rcnt_tcomptcr),obj_data_tcomptcr);
                v_rcnt_tcomptcr := v_rcnt_tcomptcr + 1;
            end loop;

            v_rcnt_tcomptdev    := 0;
            obj_row_tcomptdev   := json_object_t();
            for r_tcomptdev in c_tcomptdev loop
                obj_data_tcomptdev := json_object_t();
                obj_data_tcomptdev.put('coderror','200');

                if v_flgEdit and v_flgtypap = 'T' then
                    begin
                        select count(*)
                          into v_count_course
                          from tappdev
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq - 1
                           and coddevp = r_tcomptdev.coddevp;
                    exception when others then
                        v_count_course := 0;
                    end;

                    if v_count_course > 0 then
                        obj_data_tcomptdev.put('flgcours','Y');
                        obj_data_tcomptdev.put('flgcours_',true);
                    else
                        obj_data_tcomptdev.put('flgcours','');
                        obj_data_tcomptdev.put('flgcours_','');
                    end if;
                else
                    begin
                        select count(*)
                          into v_count_course
                          from tappdev
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq
                           and coddevp = r_tcomptdev.coddevp;
                    exception when others then
                        v_count_course := 0;
                    end;

                    if v_count_course > 0 then
                        obj_data_tcomptdev.put('flgcours','Y');
                        obj_data_tcomptdev.put('flgcours_',true);
                    else
                        obj_data_tcomptdev.put('flgcours','');
                        obj_data_tcomptdev.put('flgcours_','');
                    end if;
                end if;
                obj_data_tcomptdev.put('coddevp',r_tcomptdev.coddevp);
                obj_data_tcomptdev.put('desdevp',r_tcomptdev.desdevp);
                obj_row_tcomptdev.put(to_char(v_rcnt_tcomptdev),obj_data_tcomptdev);
                v_rcnt_tcomptdev := v_rcnt_tcomptdev + 1;
            end loop;

            obj_data.put('grade1',v_grade1);
            obj_data.put('grade2',v_grade2);
            obj_data.put('grade3',v_grade3);
            obj_data.put('qtyscor1',v_qtyscor1);
            obj_data.put('qtyscor2',v_qtyscor2);
            obj_data.put('qtyscor3',v_qtyscor3);
            obj_data.put('remark',v_remark);
            obj_data.put('flgCodtency','N');
            obj_data.put('flgapman',v_flgapman);
            obj_data.put('codcomp',p_codcomp);
            obj_data.put('codpos',p_codpos);
            obj_data.put('courseTable',obj_row_tcomptcr);
            obj_data.put('developTable',obj_row_tcomptdev);
            obj_data.put('flgEdit',v_flgEdit);

            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt := v_rcnt + 1;
        end loop;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_competencysub(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_competencysub(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_kpi_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    v_codform           taplvl.codform%type;
    v_flgapman          tappfm.flgapman%type;
    v_dteapman          tappfm.dteapman%type;
    v_dteapstr          tappfm.dteapstr%type;
    v_dteapend          tappfm.dteapend%type;
    v_numseq            tappfm.numseq%type;
    v_score             tappkpid.qtyscorn%type := 0;
    v_qtyscorn          tappkpid.qtyscorn%type;
    v_qtyscorn1         tappkpid.qtyscorn%type;
    v_qtyscorn2         tappkpid.qtyscorn%type;
    v_qtyscorn3         tappkpid.qtyscorn%type;
    v_grade             tappkpid.grade%type;
    v_grade1            tappkpid.grade%type;
    v_grade2            tappkpid.grade%type;
    v_grade3            tappkpid.grade%type;
    v_typkpi            tkpiemp.typkpi%type := 'x';
    v_remark            tappkpid.remark%type;
    v_remarkkpi         tappfm.remarkkpi%type;
    v_commtkpi          tappfm.commtkpi%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_max_numseq        tappfm.numseq%type;
    v_codkpi            tappkpid.kpino%type;
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgEdit           boolean;
    cursor c_tkpiemp is
        select tkpiemp.*,decode(typkpi,'D',1,'J',2,'I',3,9) order_field
          from tkpiemp
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = p_codempid_query
      order by order_field,codkpi;

    cursor c_flgapman is
        select flgapman, max(numseq) numseq
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           /*and numseq <> p_numseq
           and flgapman <> v_flgapman*/
           and ((v_flgapman in (1) and flgapman <> 4) or
                (v_flgapman in (4) and flgapman <> 1) or
                (v_flgapman not in (1,4)))
           and dteapman is not null
        group by flgapman;

    cursor c_tappkpid is
        select qtyscorn, grade
          from tappkpid
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and kpino = v_codkpi
           and numseq = v_max_numseq;
  begin
    select flgapman, dteapman, dteapstr, dteapend, remarkkpi, commtkpi,codcomp
      into v_flgapman, v_dteapman, v_dteapstr, v_dteapend, v_remarkkpi, v_commtkpi,p_codcomp
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    begin
--Redmine #5552
    v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
    select flgtypap into v_flgtypap
      from tstdisd
     where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--Redmine #5552
       and codaplvl = v_codaplvl;
--Redmine #5552
    exception when no_data_found then
      v_flgtypap := 'T';
    end;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r_tkpiemp in c_tkpiemp loop
        if v_typkpi != r_tkpiemp.typkpi then
            v_typkpi := r_tkpiemp.typkpi;
            obj_data := json_object_t();
            obj_data.put('typkpi',v_typkpi);
            obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',v_typkpi,global_v_lang));
            obj_data.put('codkpi','');
            obj_data.put('kpides',get_tlistval_name('TYPKPI',v_typkpi,global_v_lang));
            obj_data.put('pctwgt','');
            obj_data.put('inconInfo','');
            obj_data.put('remark','');
            obj_data.put('flgKpi','Y');
            obj_data.put('flgapman',v_flgapman);
            obj_data.put('dteyreap',p_dteyreap);
            obj_data.put('numtime',p_numtime);
            obj_data.put('codempid',p_codempid_query);
            obj_data.put('target','');
            obj_data.put('mtrfinish','');
            obj_data.put('qtyscorn1','');
            obj_data.put('qtyscorn2','');
            obj_data.put('qtyscorn3','');
            obj_data.put('grade1','');
            obj_data.put('grade2','');
            obj_data.put('grade3','');
            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end if;

        obj_data := json_object_t();
        obj_data.put('typkpi',v_typkpi);
        obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',v_typkpi,global_v_lang));
        obj_data.put('codkpi',r_tkpiemp.codkpi);
        obj_data.put('kpides',r_tkpiemp.kpides);
        obj_data.put('pctwgt',r_tkpiemp.pctwgt);
        obj_data.put('inconInfo','<i class="fa fa-info-circle" aria-hidden="true"></i>');
        obj_data.put('flgKpi','N');
        obj_data.put('flgapman',v_flgapman);
        obj_data.put('dteyreap',p_dteyreap);
        obj_data.put('numtime',p_numtime);
        obj_data.put('codempid',p_codempid_query);
        obj_data.put('target',r_tkpiemp.target);
        obj_data.put('mtrfinish',r_tkpiemp.mtrfinish);

        v_flgEdit := false;
        begin
            select qtyscorn, grade, remark
              into v_qtyscorn, v_grade, v_remark
              from tappkpid
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and kpino = r_tkpiemp.codkpi
               and numseq = p_numseq;
        exception when no_data_found then
            if v_flgtypap = 'T' then
                begin
                    select qtyscorn, grade, remark
                      into v_qtyscorn, v_grade, v_remark
                      from tappkpid
                     where codempid = p_codempid_query
                       and dteyreap = p_dteyreap
                       and numtime = p_numtime
                       and kpino = r_tkpiemp.codkpi
                       and numseq = p_numseq - 1;
                    v_flgEdit := true;
                exception when no_data_found then
                    v_qtyscorn  := 0;
                    v_grade     := '';
                    v_remark    := '';
                end;
            else
                v_qtyscorn  := 0;
                v_grade     := '';
                v_remark    := '';
            end if;
        end;

        v_score := nvl(v_score,0) + nvl(v_qtyscorn,0);

        v_codkpi := r_tkpiemp.codkpi;
        for r3 in c_flgapman loop
            v_max_numseq := r3.numseq;
            for r4 in c_tappkpid loop
                if r3.flgapman in ('1','4') then
                    v_qtyscorn1 := r4.qtyscorn;
                    v_grade1    := r4.grade;
                elsif r3.flgapman = '2' then
                    v_qtyscorn2 := r4.qtyscorn;
                    v_grade2    := r4.grade;
                elsif r3.flgapman = '3' then
                    v_qtyscorn3 := r4.qtyscorn;
                    v_grade3    := r4.grade;
                end if;
            end loop;
        end loop;

        if v_flgapman in ('1','4') then
            v_qtyscorn1 := v_qtyscorn;
            v_grade1    := v_grade;
        elsif v_flgapman = '2' then
            v_qtyscorn2 := v_qtyscorn;
            v_grade2    := v_grade;
        elsif v_flgapman = '3' then
            v_qtyscorn3 := v_qtyscorn;
            v_grade3    := v_grade;
        end if;

        if v_flgtypap = 'C' then
            if v_flgapman != '3' then
                if v_flgapman in ('1','4') then
                    v_qtyscorn2  := null;
                    v_grade2    := null;
                    v_qtyscorn3  := null;
                    v_grade3    := null;
                elsif v_flgapman = '2' then
                    v_qtyscorn1  := null;
                    v_grade1    := null;
                    v_qtyscorn3  := null;
                    v_grade3    := null;
                end if;
            end if;
        elsif v_flgtypap = 'T' then
            if v_flgapman in ('1','4') then
                v_qtyscorn2  := null;
                v_grade2    := null;
                v_qtyscorn3  := null;
                v_grade3    := null;
            elsif v_flgapman = '2' then
                v_qtyscorn3  := null;
                v_grade3    := null;
            end if;
        end if;
        obj_data.put('remark',v_remark);
        obj_data.put('qtyscorn1',v_qtyscorn1);
        obj_data.put('qtyscorn2',v_qtyscorn2);
        obj_data.put('qtyscorn3',v_qtyscorn3);
        obj_data.put('grade1',v_grade1);
        obj_data.put('grade2',v_grade2);
        obj_data.put('grade3',v_grade3);
        obj_data.put('flgEdit',v_flgEdit);

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
    end loop;

    if obj_row.get_size = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TKPIEMP');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('codcompy',p_codcompy);
    obj_detail.put('codempid',p_codempid_query);
    obj_detail.put('desc_codempid',get_temploy_name(p_codempid_query,global_v_lang));
    obj_detail.put('dteyreap',p_dteyreap);
    obj_detail.put('numtime',p_numtime);
    obj_detail.put('numseq',p_numseq);
    obj_detail.put('codapman',p_codapman);
    obj_detail.put('desc_codapman',get_temploy_name(p_codapman,global_v_lang));
    obj_detail.put('dteapman',to_char(v_dteapman,'dd/mm/yyyy'));
    obj_detail.put('dteapstr',to_char(v_dteapstr,'dd/mm/yyyy'));
    obj_detail.put('dteapend',to_char(v_dteapend,'dd/mm/yyyy'));
    obj_detail.put('score',v_score);
    obj_detail.put('remarkkpi', v_remarkkpi);
    obj_detail.put('commtkpi', v_commtkpi);

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('table',obj_row);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_kpi_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_kpi_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure gen_kpisub_table1(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    cursor c_tappkpimth is
        select *
          from tappkpimth
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and codkpi = p_codkpi
      order by dtemonth;
  begin
    obj_row := json_object_t();
    for r1 in c_tappkpimth loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('dtemonth',get_nammthful(r1.dtemonth,global_v_lang));
        obj_data.put('dteinput',to_char(r1.dteinput,'dd/mm/yyyy'));
        obj_data.put('descwork',r1.descwork);
        obj_data.put('kpivalue',r1.kpivalue);
        obj_data.put('dtereview',to_char(r1.dtereview,'dd/mm/yyyy'));
        obj_data.put('commtimpro',r1.commtimpro);
        obj_data.put('codreview',r1.codreview);
        obj_data.put('desc_codreview',get_temploy_name(r1.codreview,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    if obj_row.get_size = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPKPIMTH');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_kpisub_table1(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_kpisub_table1(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure gen_kpisub_table2(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    cursor c_tkpiemppl is
        select *
          from tkpiemppl
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and codkpi = p_codkpi
      order by planno;
  begin
    obj_row := json_object_t();
    for r1 in c_tkpiemppl loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('plandes',r1.plandes);
        obj_data.put('descwork','');
        obj_data.put('targtstr',to_char(r1.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend',to_char(r1.targtend,'dd/mm/yyyy'));
        obj_data.put('dtewstr',to_char(r1.dtewstr,'dd/mm/yyyy'));
        obj_data.put('workdesc',r1.workdesc);
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_kpisub_table2(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_kpisub_table2(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure gen_popup_coursetrain(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row_competency  json_object_t;
    obj_row_develop     json_object_t;
    v_rcnt              number := 0;

    cursor c_tcomptcr is
        select distinct codcours
          from tcomptcr
         where codskill = p_codskill
           and grade between p_grade + 1 and p_expectgrade
      order by codcours;

    cursor c_tcomptdev is
        select distinct coddevp, desdevp
          from tcomptdev
         where codskill = p_codskill
           and grade between p_grade + 1 and p_expectgrade
      order by coddevp;
  begin
    v_rcnt := 0;
    obj_row_competency := json_object_t();
    for r1 in c_tcomptcr loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgcours','');
        obj_data.put('flgcours_','');
        obj_data.put('codcours',r1.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
        obj_row_competency.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;

    v_rcnt := 0;
    obj_row_develop := json_object_t();
    for r1 in c_tcomptdev loop
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('flgcours','');
        obj_data.put('flgcours_','');
        obj_data.put('coddevp',r1.coddevp);
        obj_data.put('desdevp',r1.desdevp);
        obj_row_develop.put(to_char(v_rcnt),obj_data);
        v_rcnt := v_rcnt + 1;
    end loop;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codskill',p_codskill);
    obj_data.put('grade1',p_grade1);
    obj_data.put('grade2',p_grade2);
    obj_data.put('grade3',p_grade3);
    obj_data.put('clone_grade1',p_grade1);
    obj_data.put('clone_grade2',p_grade2);
    obj_data.put('clone_grade3',p_grade3);
    obj_data.put('courseTable', obj_row_competency);
    obj_data.put('developTable', obj_row_develop);

    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_popup_coursetrain(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_popup_coursetrain(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --

  function is_number( p_str in varchar2 ) return varchar2 is
    l_num   number;
  begin
    l_num   := to_number( p_str );
    return 'Y';
  exception when value_error then return 'N';
  end;
  --
  --
  procedure save_behavior(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    v_codkpi              tkpiemp.codkpi%type;
    v_objective           tobjemp.objective%type;
    v_codcomp             temploy1.codcomp%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';

    param_behavior          json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;
    v_commtbeh              tappfm.commtbeh%type;
    v_remarkbeh             tappfm.remarkbeh%type;
    v_codform               tappfm.codform%type;
    v_count_tappbehi        number;
    v_numgrup               tappbehg.numgrup%type;
    v_qtyscor               tappbehg.qtyscor%type;
    v_qtyscorn              tappbehg.qtyscorn%type;
    v_pctwgt                tappbehg.pctwgt%type;
    v_flgapman              tappfm.flgapman%type;
    v_qtybehf               tappfm.qtybehf%type;
    v_qtybeh                tappfm.qtybeh%type := 0;

    v_qtybeh1               tappemp.qtybeh%type;
    v_qtybeh2               tappemp.qtybeh2%type;
    v_qtybeh3               tappemp.qtybeh3%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;
    v_codaplvl              tstdisd.codaplvl%type;
  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    p_dteapman              := to_date(hcm_util.get_string_t(json_input,'p_dteapman'),'dd/mm/yyyy');
    param_behavior          := hcm_util.get_json_t(json_input,'param_behavior');
    param_detail            := hcm_util.get_json_t(param_behavior,'detail');
    param_table             := hcm_util.get_json_t(param_behavior,'table');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    p_codempid_query        := hcm_util.get_string_t(param_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(param_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(param_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(param_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(param_detail,'codapman');
    v_commtbeh              := hcm_util.get_string_t(param_detail,'commtbeh');
    v_remarkbeh             := hcm_util.get_string_t(param_detail,'remarkbeh');
    v_codform               := hcm_util.get_string_t(param_detail,'codform');

    select count(*)
      into v_count_tappbehi
      from tappbehi
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    if v_count_tappbehi = 0 then
        param_msg_error   := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRAP31E4', global_v_lang, 140));
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    select flgapman, codcomp, codaplvl
      into v_flgapman, p_codcomp, p_codaplvl
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_numgrup           := hcm_util.get_string_t(param_json_row,'numgrup');

        if v_flgapman in ('1','4')  then
            v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn1');
        elsif v_flgapman = '2'  then
            v_qtyscorn := hcm_util.get_string_t(param_json_row,'qtyscorn2');
        elsif v_flgapman = '3'  then
            v_qtyscorn := hcm_util.get_string_t(param_json_row,'qtyscorn3');
        end if;
        v_qtybeh    := v_qtybeh + v_qtyscorn;

        begin
            insert into tappbehg (codempid,dteyreap,numtime,numseq,numgrup,qtyscor,qtyscorn,pctwgt,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,v_numgrup,v_qtyscor,v_qtyscorn,v_pctwgt,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappbehg
               set qtyscor = v_qtyscor,
                   qtyscorn = v_qtyscorn,
                   pctwgt = v_pctwgt,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and numgrup = v_numgrup;
        end ;
    end loop;

    select qtytscor
      into v_qtybehf
      from tintview
     where codform = v_codform;

    update tappfm
       set codform = v_codform,
           qtybehf = v_qtybehf,
           qtybeh = v_qtybeh,
           remarkbeh = v_remarkbeh,
           commtbeh = v_commtbeh,
           dteapman = p_dteapman,
           codapman = p_codapman,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select flgtypap , dteapend
          into v_flgtypap , v_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    if v_flgtypap = 'C' and v_flgapman = '3' then
        v_qtybeh3 := round(v_qtybeh*100 / v_qtybehf,2);
    elsif v_flgtypap = 'T' then
        if v_flgapman in ('1')  then
            v_qtybeh1  := round(v_qtybeh*100 / v_qtybehf,2);
        elsif v_flgapman = '2'  then
            v_qtybeh2 := round(v_qtybeh*100 / v_qtybehf,2);
        elsif v_flgapman = '3'  then
            v_qtybeh3 := round(v_qtybeh*100 / v_qtybehf,2);
        end if;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    update tappemp
       set codform = v_codform,
           qtybeh = nvl(v_qtybeh1,qtybeh),
           qtybeh2 = nvl(v_qtybeh2,qtybeh2),
           qtybeh3 = nvl(v_qtybeh3,qtybeh3),
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap,  p_numtime, v_flgapman, v_dteapend, null, null);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(param_msg_error,'@#$%201',null));

      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('table',obj_table);

      gen_detail_course_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('courseTable',obj_table);

      gen_detail_develop_table(clob_table);
      obj_table   := json_object_t(clob_table);
      obj_data.put('developTable',obj_table);

      json_str_output := obj_data.to_clob;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_behavior_sub(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;

    param_behavior          json_object_t;
    param_behaviorsub       json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;
    v_commtbeh              tappfm.commtbeh%type;
    v_remarkbeh             tappfm.remarkbeh%type;
    v_codform               tappfm.codform%type;
    v_count_tappbehi        number;
    v_numgrup               tappbehi.numgrup%type;
    v_numitem               tappbehi.numitem%type;
    v_grdscor               tappbehi.grdscor%type;
    v_qtyscorn              tappbehi.qtyscorn%type;
    v_remark                tappbehi.remark%type;
    v_pctwgt                tappbehi.pctwgt%type;
    v_flgapman              tappfm.flgapman%type;
    v_qtybehf               tappfm.qtybehf%type;
    v_qtybeh                tappfm.qtybeh%type := 0;
    v_qtyscor               tappbehg.qtyscor%type;

    v_qtybeh1               tappemp.qtybeh%type;
    v_qtybeh2               tappemp.qtybeh2%type;
    v_qtybeh3               tappemp.qtybeh3%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;
    v_codaplvl              tstdisd.codaplvl%type;
  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    p_dteapman              := to_date(hcm_util.get_string_t(json_input,'p_dteapman'),'dd/mm/yyyy');
    param_behavior          := hcm_util.get_json_t(json_input,'param_behavior');
    param_detail            := hcm_util.get_json_t(param_behavior,'detail');
    p_codcompy              := hcm_util.get_string_t(param_detail,'codcompy');
    p_codempid_query        := hcm_util.get_string_t(param_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(param_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(param_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(param_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(param_detail,'codapman');
    v_commtbeh              := hcm_util.get_string_t(param_detail,'commtbeh');
    v_remarkbeh             := hcm_util.get_string_t(param_detail,'remarkbeh');
    v_codform               := hcm_util.get_string_t(param_detail,'codform');

    param_behaviorsub       := hcm_util.get_json_t(json_input,'param_behaviorsub');
    param_json              := hcm_util.get_json_t(param_behaviorsub,'rows');

    select flgapman, codcomp, codaplvl
      into v_flgapman, p_codcomp, p_codaplvl
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        if hcm_util.get_string_t(param_json_row,'flgNumgrup') = 'N' then
            v_numgrup           := hcm_util.get_string_t(param_json_row,'numgrup');
            v_numitem           := hcm_util.get_string_t(param_json_row,'numitem');
            v_pctwgt            := hcm_util.get_string_t(param_json_row,'qtywgt');
            v_remark            := hcm_util.get_string_t(param_json_row,'remark');
            if v_flgapman in ('1','4')  then
                v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn1');
                v_grdscor   := hcm_util.get_string_t(param_json_row,'grdscor1');
            elsif v_flgapman = '2'  then
                v_qtyscorn := hcm_util.get_string_t(param_json_row,'qtyscorn2');
                v_grdscor   := hcm_util.get_string_t(param_json_row,'grdscor2');
            elsif v_flgapman = '3'  then
                v_qtyscorn := hcm_util.get_string_t(param_json_row,'qtyscorn3');
                v_grdscor   := hcm_util.get_string_t(param_json_row,'grdscor3');
            end if;
            v_qtybeh    := v_qtybeh + v_qtyscorn;

            begin
                insert into tappbehi (codempid,dteyreap,numtime,numseq,
                                      numgrup,numitem,grdscor,qtyscorn,pctwgt,remark,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                        v_numgrup, v_numitem, v_grdscor, v_qtyscorn, v_pctwgt, v_remark,
                        sysdate, global_v_coduser, sysdate, global_v_coduser);
            exception when dup_val_on_index then
                update tappbehi
                   set grdscor = v_grdscor,
                       qtyscorn = v_qtyscorn,
                       pctwgt = v_pctwgt,
                       remark = v_remark,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq
                   and numgrup = v_numgrup
                   and numitem = v_numitem;
            end ;
        end if;

    end loop;

    param_table             := hcm_util.get_json_t(param_behavior,'table');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_numgrup           := hcm_util.get_string_t(param_json_row,'numgrup');
        v_pctwgt            := null;
        v_qtyscor           := null;

        select sum(qtyscorn)
          into v_qtyscorn
          from tappbehi
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
           and numgrup = v_numgrup;

--        v_qtybeh    := v_qtybeh + v_qtyscorn;

        begin
            insert into tappbehg (codempid,dteyreap,numtime,numseq,numgrup,qtyscor,qtyscorn,pctwgt,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,v_numgrup,v_qtyscor,v_qtyscorn,v_pctwgt,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappbehg
               set qtyscor = v_qtyscor,
                   qtyscorn = v_qtyscorn,
                   pctwgt = v_pctwgt,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and numgrup = v_numgrup;
        end ;
    end loop;

    select qtytscor
      into v_qtybehf
      from tintview
     where codform = v_codform;

    update tappfm
       set codform = v_codform,
           qtybehf = v_qtybehf,
           qtybeh = v_qtybeh,
           remarkbeh = v_remarkbeh,
           commtbeh = v_commtbeh,
           codapman = p_codapman,
           dteapman = p_dteapman,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select flgtypap , dteapend
          into v_flgtypap , v_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    if v_flgtypap = 'C' and v_flgapman = '3' then
        v_qtybeh3 := round(v_qtybeh*100 / v_qtybehf,2);
    elsif v_flgtypap = 'T' then
        if v_flgapman in ('1')  then
            v_qtybeh1  := round(v_qtybeh*100 / v_qtybehf,2);
        elsif v_flgapman = '2'  then
            v_qtybeh2 := round(v_qtybeh*100 / v_qtybehf,2);
        elsif v_flgapman = '3'  then
            v_qtybeh3 := round(v_qtybeh*100 / v_qtybehf,2);
        end if;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    update tappemp
       set codform = v_codform,
           qtybeh = nvl(v_qtybeh1,qtybeh),
           qtybeh2 = nvl(v_qtybeh2,qtybeh2),
           qtybeh3 = nvl(v_qtybeh3,qtybeh3),
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap,  p_numtime, v_flgapman, v_dteapend, null, null);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(param_msg_error,'@#$%201',null));

      gen_behavior_detail(clob_table);
      obj_table     := hcm_util.get_json_t(json_object_t(clob_table),'table');
      obj_data.put('behaviorTable',obj_table);

      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('table',obj_table);

      gen_detail_course_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('courseTable',obj_table);

      gen_detail_develop_table(clob_table);
      obj_table   := json_object_t(clob_table);
      obj_data.put('developTable',obj_table);

      json_str_output := obj_data.to_clob;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure save_kpi(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    v_codkpi              tkpiemp.codkpi%type;
    v_objective           tobjemp.objective%type;
    v_codcomp             temploy1.codcomp%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';

    param_kpi               json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;
    v_commtkpi              tappfm.commtkpi%type;
    v_remarkkpi             tappfm.remarkkpi%type;

    v_codform               tappfm.codform%type;
    v_count_tappbehi        number;
    v_typkpi                tappkpid.typkpi%type;
    v_kpiitem               tappkpid.kpiitem%type;
    v_grade                 tappkpid.grade%type;
    v_qtyscor               tappkpid.qtyscor%type;
    v_qtyscorn              tappkpid.qtyscorn%type;
    v_pctwgt                tappkpid.pctwgt%type;
    v_remark                tappkpid.remark%type;

    v_flgapman              tappfm.flgapman%type;
    v_qtykpif               tappfm.qtykpif%type;
    v_qtykpi                tappfm.qtykpi%type := 0;

    v_qtykpie1              tappemp.qtykpie%type;
    v_qtykpie2              tappemp.qtykpie2%type;
    v_qtykpie3              tappemp.qtykpie3%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    t_taplvl                taplvl%rowtype;
    t_tappfm                tappfm%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;
    v_max_score             tkpiempg.score%type;
    v_codaplvl              tstdisd.codaplvl%type;

  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    p_dteapman              := to_date(hcm_util.get_string_t(json_input,'p_dteapman'),'dd/mm/yyyy');
    param_kpi               := hcm_util.get_json_t(json_input,'param_kpi');
    param_detail            := hcm_util.get_json_t(param_kpi,'detail');
    param_table             := hcm_util.get_json_t(param_kpi,'table');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    p_codempid_query        := hcm_util.get_string_t(param_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(param_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(param_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(param_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(param_detail,'codapman');
    v_commtkpi              := hcm_util.get_string_t(param_detail,'commtkpi');
    v_remarkkpi             := hcm_util.get_string_t(param_detail,'remarkkpi');

    select flgapman, codcomp, codaplvl
      into v_flgapman, p_codcomp, p_codaplvl
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        if hcm_util.get_string_t(param_json_row,'flgKpi') = 'N' then
            v_codkpi            := hcm_util.get_string_t(param_json_row,'codkpi');
            v_pctwgt            := hcm_util.get_string_t(param_json_row,'pctwgt');
            v_remark            := hcm_util.get_string_t(param_json_row,'remark');
            v_typkpi            := hcm_util.get_string_t(param_json_row,'typkpi');
            v_kpiitem           := hcm_util.get_string_t(param_json_row,'kpides');
            if v_flgapman in ('1','4')  then
                v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn1');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor1');
                v_grade     := hcm_util.get_string_t(param_json_row,'grade1');
            elsif v_flgapman = '2'  then
                v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn2');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor2');
                v_grade     := hcm_util.get_string_t(param_json_row,'grade2');
            elsif v_flgapman = '3'  then
                v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn3');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor3');
                v_grade     := hcm_util.get_string_t(param_json_row,'grade3');
            end if;
            v_qtykpi    := v_qtykpi + v_qtyscorn;

            select nvl(max(score),0)
              into v_max_score
              from tkpiempg
             where dteyreap = p_dteyreap
               and numtime = p_numtime
               and codempid = p_codempid_query
               and codkpi = v_codkpi;

            v_qtykpif :=    nvl(v_qtykpif,0) + (v_max_score * v_pctwgt);

            begin
                insert into tappkpid (codempid,dteyreap,numtime,numseq,kpino,
                                      typkpi,kpiitem,grade,qtyscor,qtyscorn,pctwgt,remark,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,v_codkpi,
                        v_typkpi,v_kpiitem,v_grade,v_qtyscor,v_qtyscorn,v_pctwgt,v_remark,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tappkpid
                   set typkpi = v_typkpi,
                       kpiitem = v_kpiitem,
                       grade = v_grade,
                       qtyscor = v_qtyscor,
                       qtyscorn = v_qtyscorn,
                       pctwgt = v_pctwgt,
                       remark = v_remark,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq
                   and kpino = v_codkpi;
            end ;

            update tkpiemp
              set grade = v_grade,
                  qtyscor = v_qtyscor,
                  qtyscorn = v_qtyscorn
            where codempid = p_codempid_query
              and dteyreap = p_dteyreap
              and numtime = p_numtime
              and codkpi = v_codkpi;
        end if;

    end loop;

    update tappfm
       set qtykpif = v_qtykpif,
           qtykpi = v_qtykpi,
           remarkkpi = v_remarkkpi,
           commtkpi = v_commtkpi,
           codapman = p_codapman,
           dteapman = p_dteapman,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552


        select flgtypap,dteapend
          into v_flgtypap,v_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    if v_flgtypap = 'C' and v_flgapman = '3' then
        v_qtykpie3 := round(v_qtykpi*100 / v_qtykpif,2);
    elsif v_flgtypap = 'T' then
        if v_flgapman in ('1')  then
            v_qtykpie1  := round(v_qtykpi*100 / v_qtykpif,2);
        elsif v_flgapman = '2'  then
            v_qtykpie2 := round(v_qtykpi*100 / v_qtykpif,2);
        elsif v_flgapman = '3'  then
            v_qtykpie3 := round(v_qtykpi*100 / v_qtykpif,2);
        end if;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    update tappemp
       set qtykpie = nvl(v_qtykpie1,qtykpie),
           qtykpie2 = nvl(v_qtykpie2,qtykpie2),
           qtykpie3 = nvl(v_qtykpie3,qtykpie3),
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap,  p_numtime, v_flgapman, v_dteapend, null, null);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(param_msg_error,'@#$%201',null));

      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('table',obj_table);

      gen_detail_course_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('courseTable',obj_table);

      gen_detail_develop_table(clob_table);
      obj_table   := json_object_t(clob_table);
      obj_data.put('developTable',obj_table);
      json_str_output := obj_data.to_clob;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_competency(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    v_codkpi              tkpiemp.codkpi%type;
    v_objective           tobjemp.objective%type;
    v_codcomp             temploy1.codcomp%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';

    param_competency        json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;
    v_commtcmp              tappfm.commtcmp%type;
    v_remarkcmp             tappfm.remarkcmp%type;
    v_count_tappcmps        number;
    v_codtency              tappcmpc.codtency%type;
    v_numgrup               tappbehg.numgrup%type;
    v_qtyscor               tappbehg.qtyscor%type;
    v_qtyscorn              tappbehg.qtyscorn%type;
    v_pctwgt                tappbehg.pctwgt%type;
    v_flgapman              tappfm.flgapman%type;
    v_qtycmpf               tappfm.qtycmpf%type;
    v_qtycmp                tappfm.qtycmp%type := 0;

    v_qtycmp1               tappemp.qtybeh%type;
    v_qtycmp2               tappemp.qtybeh2%type;
    v_qtycmp3               tappemp.qtybeh3%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;
    v_codcours              tapptrn.codcours%type;
    v_coddevp               tappdev.coddevp%type;
    v_desdevp               tappdev.desdevp%type;
    v_flgDelete             boolean;
    max_numseq2             number;
    count_tappdev           number;
    v_codaplvl          tstdisd.codaplvl%type;

  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    p_dteapman              := to_date(hcm_util.get_string_t(json_input,'p_dteapman'),'dd/mm/yyyy');
    param_competency        := hcm_util.get_json_t(json_input,'param_competency');
    param_detail            := hcm_util.get_json_t(param_competency,'detail');
    param_table             := hcm_util.get_json_t(param_competency,'competencyTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    p_codempid_query        := hcm_util.get_string_t(param_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(param_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(param_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(param_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(param_detail,'codapman');
    v_commtcmp              := hcm_util.get_string_t(param_detail,'commtcmp');
    v_remarkcmp             := hcm_util.get_string_t(param_detail,'remarkcmp');

    select count(*)
      into v_count_tappcmps
      from tappcmps
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    if v_count_tappcmps = 0 then
        param_msg_error     := get_error_msg_php('HR2045',global_v_lang,get_label_name('HRAP31E4', global_v_lang, 140));
        json_str_output     := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;

    select flgapman, codcomp, codaplvl, codpos
      into v_flgapman, p_codcomp, p_codaplvl, p_codpos
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codtency          := hcm_util.get_string_t(param_json_row,'codtency_');
        v_pctwgt            := hcm_util.get_string_t(param_json_row,'qtywgt');
        if v_flgapman in ('1','4')  then
            v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor1');
            v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn1');
        elsif v_flgapman = '2'  then
            v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor2');
            v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn2');
        elsif v_flgapman = '3'  then
            v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor3');
            v_qtyscorn  := hcm_util.get_string_t(param_json_row,'qtyscorn3');
        end if;
--        v_qtycmp    := v_qtycmp + v_qtyscorn;
        v_qtycmp    := v_qtycmp + v_qtyscor;

        begin
            insert into tappcmpc (codempid,dteyreap,numtime,numseq,
                                  codtency,qtyscor,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                    v_codtency,v_qtyscor,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappcmpc
               set qtyscor = v_qtyscor,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and codtency = v_codtency;
        end ;
    end loop;

    param_table             := hcm_util.get_json_t(param_competency,'developTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_coddevp          := hcm_util.get_string_t(param_json_row,'coddevp');
        v_desdevp          := hcm_util.get_string_t(param_json_row,'desdevp');
        v_flgDelete         := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_flgDelete then
            delete tappdev
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and coddevp = v_coddevp;
        else
            select count(*)
              into count_tappdev
              from tappdev
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and coddevp = v_coddevp;
            if count_tappdev = 0 then
                select max(numseq2)
                  into max_numseq2
                  from tappdev
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq;

                max_numseq2 := nvl(max_numseq2,0) + 1;
                begin
                    insert into tappdev (codempid,dteyreap,numtime,numseq,
                                         numseq2,coddevp,desdevp,codapman,
                                         dtecreate,codcreate,dteupd,coduser)
                    values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                            max_numseq2, v_coddevp,v_desdevp, p_codapman,
                            sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when dup_val_on_index then
                    null;
                end ;
            end if;
        end if;
    end loop;

    param_table             := hcm_util.get_json_t(param_competency,'courseTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codcours          := hcm_util.get_string_t(param_json_row,'codcours');
        v_flgDelete         := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_flgDelete then
            delete tapptrn
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and codcours = v_codcours;
        else
            begin
                insert into tapptrn (codempid,dteyreap,numtime,numseq,
                                     codcours,codapman,
                                     dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                        v_codcours, p_codapman,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end ;
        end if;
    end loop;

--    select sum(fscore)
    select sum(greatest(fscore,score))
      into v_qtycmpf
      from tjobposskil
     where codpos = p_codpos
       and codcomp = p_codcomp;

    update tappfm
       set qtycmpf = v_qtycmpf,
           qtycmp = v_qtycmp,
           remarkcmp = v_remarkcmp,
           commtcmp = v_commtcmp,
           codapman = p_codapman,
           dteapman = p_dteapman,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select flgtypap, dteapend
          into v_flgtypap, v_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    if v_flgtypap = 'C' and v_flgapman = '3' then
        v_qtycmp3 := round(v_qtycmp*100 / v_qtycmpf,2);
    elsif v_flgtypap = 'T' then
        if v_flgapman in ('1')  then
            v_qtycmp1  := round(v_qtycmp*100 / v_qtycmpf,2);
        elsif v_flgapman = '2'  then
            v_qtycmp2 := round(v_qtycmp*100 / v_qtycmpf,2);
        elsif v_flgapman = '3'  then
            v_qtycmp3 := round(v_qtycmp*100 / v_qtycmpf,2);
        end if;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    update tappemp
       set qtycmp = nvl(v_qtycmp1,qtycmp),
           qtycmp2 = nvl(v_qtycmp2,qtycmp2),
           qtycmp3 = nvl(v_qtycmp3,qtycmp3),
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap,  p_numtime, v_flgapman, v_dteapend, null, null);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(param_msg_error,'@#$%201',null));

      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('table',obj_table);

      gen_detail_course_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('courseTable',obj_table);

      gen_detail_develop_table(clob_table);
      obj_table   := json_object_t(clob_table);
      obj_data.put('developTable',obj_table);

      json_str_output := obj_data.to_clob;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_competency_sub(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    t_tkpiemp             tkpiemp%rowtype;
    v_codkpi              tkpiemp.codkpi%type;
    v_objective           tobjemp.objective%type;
    v_codcomp             temploy1.codcomp%type;
    v_flg                 varchar2(50);
    v_flg_delete          varchar2(1) := 'N';
    v_eval                varchar2(1) := 'N';
    v_found               varchar2(1) := 'N';

    param_competency        json_object_t;
    param_competencySub     json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;
    v_commtcmp              tappfm.commtcmp%type;
    v_remarkcmp             tappfm.remarkcmp%type;
    v_count_tappcmps        number;
    v_codtency              tappcmpc.codtency%type;
    v_codskill              tappcmps.codskill%type;
    v_gradexpct             tappcmps.gradexpct%type;
    v_exp_score             tappcmps.qtyscor%type;
    v_remark                tappcmps.remark%type;
    v_grade                 tappcmps.grade%type;
    v_qtyscor               tappcmps.qtyscor%type;
    v_qtyscorn              tappcmps.qtyscor%type;

    v_flgapman              tappfm.flgapman%type;
    v_qtycmpf               tappfm.qtycmpf%type;
    v_qtycmp                tappfm.qtycmp%type := 0;

    v_qtycmp1               tappemp.qtybeh%type;
    v_qtycmp2               tappemp.qtybeh2%type;
    v_qtycmp3               tappemp.qtybeh3%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;
    v_codcours              tapptrn.codcours%type;
    v_coddevp               tappdev.coddevp%type;
    v_desdevp               tappdev.desdevp%type;
    v_flgDelete             boolean;
    max_numseq2             number;
    count_tappdev           number;
    obj_courseTable         json_object_t;
    obj_developTable        json_object_t;
    course_json             json_object_t;
    develop_json            json_object_t;
    course_json_row         json_object_t;
    develop_json_row        json_object_t;
    flgcours                boolean;
    v_codaplvl          tstdisd.codaplvl%type;
    v_taplvld_codcomp   taplvld.codcomp%type;
    v_taplvld_dteeffec  taplvld.dteeffec%type;
    v_qtywgt               taplvld.qtywgt%type;

    cursor c_taplvld_where is
      select dteeffec,codcomp
        from taplvld
       where p_codcomp like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_dteapend
      order by codcomp desc,dteeffec desc;

  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    p_dteapman              := to_date(hcm_util.get_string_t(json_input,'p_dteapman'),'dd/mm/yyyy');
    param_competency        := hcm_util.get_json_t(json_input,'param_competency');
    param_detail            := hcm_util.get_json_t(param_competency,'detail');
    p_codcompy              := hcm_util.get_string_t(param_detail,'codcompy');
    p_codempid_query        := hcm_util.get_string_t(param_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(param_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(param_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(param_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(param_detail,'codapman');
    v_commtcmp              := hcm_util.get_string_t(param_detail,'commtcmp');
    v_remarkcmp             := hcm_util.get_string_t(param_detail,'remarkcmp');

    select flgapman, codcomp, codaplvl, codpos
      into v_flgapman, p_codcomp, p_codaplvl, p_codpos
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    begin
        select dteapend
          into v_dteapend
          from tstdisd
         where codcomp = p_codcompy
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and codaplvl = p_codaplvl;
    exception when no_data_found then
        null;
    end;

    v_global_dteapend := v_dteapend;

    for r_taplvld in c_taplvld_where loop
      v_taplvld_dteeffec    := r_taplvld.dteeffec;
      v_taplvld_codcomp     := r_taplvld.codcomp;
      exit;
    end loop;


    param_table             := hcm_util.get_json_t(param_competency,'developTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_coddevp           := hcm_util.get_string_t(param_json_row,'coddevp');
        v_desdevp           := hcm_util.get_string_t(param_json_row,'desdevp');
        v_flgDelete         := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_flgDelete then
            delete tappdev
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and coddevp = v_coddevp;
        end if;
    end loop;

    param_table             := hcm_util.get_json_t(param_competency,'courseTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');
    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codcours          := hcm_util.get_string_t(param_json_row,'codcours');
        v_flgDelete         := hcm_util.get_boolean_t(param_json_row,'flgDelete');

        if v_flgDelete then
            delete tapptrn
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and codcours = v_codcours;
        end if;
    end loop;

    param_competencySub     := hcm_util.get_json_t(json_input,'param_competencySub');
    param_json              := hcm_util.get_json_t(param_competencySub,'rows');

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        if hcm_util.get_string_t(param_json_row,'flgCodtency') = 'N' then
            v_codtency          := hcm_util.get_string_t(param_json_row,'codtency');
            v_codskill          := hcm_util.get_string_t(param_json_row,'codskill');
            v_gradexpct         := hcm_util.get_string_t(param_json_row,'grade');
            v_remark            := hcm_util.get_string_t(param_json_row,'remark');
            obj_courseTable     := hcm_util.get_json_t(param_json_row,'courseTable');
            obj_developTable    := hcm_util.get_json_t(param_json_row,'developTable');
            v_exp_score         := hcm_util.get_string_t(param_json_row,'exp_score');

            if v_flgapman in ('1','4')  then
                v_grade     := hcm_util.get_string_t(param_json_row,'grade1');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor1');
            elsif v_flgapman = '2'  then
                v_grade     := hcm_util.get_string_t(param_json_row,'grade2');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor2');
            elsif v_flgapman = '3'  then
                v_grade     := hcm_util.get_string_t(param_json_row,'grade3');
                v_qtyscor   := hcm_util.get_string_t(param_json_row,'qtyscor3');
            end if;

            if v_grade >= v_gradexpct then
                v_qtyscor := v_exp_score;
            end if;

--            v_qtycmp    := v_qtycmp + v_qtyscorn;

            begin
                insert into tappcmps (codempid,dteyreap,numtime,numseq,
                                      codtency,codskill,gradexpct,grade,qtyscor,remark,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                        v_codtency,v_codskill,v_gradexpct,v_grade,v_qtyscor,v_remark,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                update tappcmps
                   set qtyscor = v_qtyscor,
                       gradexpct = v_gradexpct,
                       grade = v_grade,
                       remark = v_remark,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codempid = p_codempid_query
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq
                   and codtency = v_codtency
                   and codskill = v_codskill;
            end ;

            course_json         := hcm_util.get_json_t(obj_courseTable,'rows');
            for j in 0..(course_json.get_size - 1) loop
                course_json_row     := hcm_util.get_json_t(course_json,to_char(j));
                flgcours            := hcm_util.get_boolean_t(course_json_row,'flgcours_');
                v_codcours          := hcm_util.get_string_t(course_json_row,'codcours');
                if flgcours then
                    begin
                        insert into tapptrn (codempid,dteyreap,numtime,numseq,
                                             codcours,codapman,
                                             dtecreate,codcreate,dteupd,coduser)
                        values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                                v_codcours, p_codapman,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
                    exception when dup_val_on_index then
                        null;
                    end ;
                else
                    begin
                        delete tapptrn
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq
                           and codcours = v_codcours;
                    exception when others then
                        null;
                    end;
                end if;
            end loop;

            develop_json            := hcm_util.get_json_t(obj_developTable,'rows');
            for i in 0..(develop_json.get_size - 1) loop
                develop_json_row      := hcm_util.get_json_t(develop_json,to_char(i));
                v_coddevp           := hcm_util.get_string_t(develop_json_row,'coddevp');
                v_desdevp           := hcm_util.get_string_t(develop_json_row,'desdevp');
                flgcours            := hcm_util.get_boolean_t(develop_json_row,'flgcours_');

                if flgcours then
                    select count(*)
                      into count_tappdev
                      from tappdev
                     where codempid = p_codempid_query
                       and dteyreap = p_dteyreap
                       and numtime = p_numtime
                       and numseq = p_numseq
                       and coddevp = v_coddevp;
                    if count_tappdev = 0 then
                        select max(numseq2)
                          into max_numseq2
                          from tappdev
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq;

                        max_numseq2 := nvl(max_numseq2,0) + 1;
                        begin
                            insert into tappdev (codempid,dteyreap,numtime,numseq,
                                                 numseq2,coddevp,desdevp,codapman,
                                                 dtecreate,codcreate,dteupd,coduser)
                            values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                                    max_numseq2, v_coddevp,v_desdevp, p_codapman,
                                    sysdate,global_v_coduser,sysdate,global_v_coduser);
                        exception when dup_val_on_index then
                            null;
                        end ;
                    end if;
                else
                    begin
                        delete tappdev
                         where codempid = p_codempid_query
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and numseq = p_numseq
                           and coddevp = v_coddevp;
                    exception when others then
                        null;
                    end;
                end if;
            end loop;
        end if;
    end loop;

    param_table             := hcm_util.get_json_t(param_competency,'competencyTable');
    param_json              := hcm_util.get_json_t(param_table,'rows');

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codtency          := hcm_util.get_string_t(param_json_row,'codtency_');

        select sum(qtyscor)
          into v_qtyscor
          from tappcmps
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
           and codtency = v_codtency;

        begin
            select qtywgt
              into v_qtywgt
              from taplvld
             where codcomp = v_taplvld_codcomp
               and codaplvl = p_codaplvl
               and dteeffec = v_taplvld_dteeffec
               and codtency = v_codtency;
        exception when others then
            v_qtywgt := 0;
        end;


        v_qtycmp  := v_qtycmp + (v_qtyscor /** v_qtywgt*/);

        begin
            insert into tappcmpc (codempid,dteyreap,numtime,numseq,
                                  codtency,qtyscor,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,p_numseq,
                    v_codtency,v_qtyscor,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappcmpc
               set qtyscor = v_qtyscor,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and numseq = p_numseq
               and codtency = v_codtency;
        end ;
    end loop;


--    select sum(fscore)
    select sum(greatest(fscore,score))
      into v_qtycmpf
      from tjobposskil
     where codpos = p_codpos
       and codcomp = p_codcomp;

    update tappfm
       set qtycmpf = v_qtycmpf,
           qtycmp = v_qtycmp,
           remarkcmp = v_remarkcmp,
           commtcmp = v_commtcmp,
           codapman = p_codapman,
           dteapman = p_dteapman,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select flgtypap, dteapend
          into v_flgtypap, v_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    if v_flgtypap = 'C' and v_flgapman = '3' then
        v_qtycmp3 := round(v_qtycmp*100 / v_qtycmpf,2);
    elsif v_flgtypap = 'T' then
        if v_flgapman in ('1')  then
            v_qtycmp1  := round(v_qtycmp*100 / v_qtycmpf,2);
        elsif v_flgapman = '2'  then
            v_qtycmp2 := round(v_qtycmp*100 / v_qtycmpf,2);
        elsif v_flgapman = '3'  then
            v_qtycmp3 := round(v_qtycmp*100 / v_qtycmpf,2);
        end if;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    update tappemp
       set qtycmp = nvl(v_qtycmp1,qtycmp),
           qtycmp2 = nvl(v_qtycmp2,qtycmp2),
           qtycmp3 = nvl(v_qtycmp3,qtycmp3),
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap,  p_numtime, v_flgapman, v_dteapend, null, null);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('response',replace(param_msg_error,'@#$%201',null));
      gen_competency_detail(clob_table);
      obj_table     := hcm_util.get_json_t(json_object_t(clob_table),'competencyTable');
      obj_data.put('competencyTable',obj_table);
      obj_table     := hcm_util.get_json_t(json_object_t(clob_table),'courseTable');
      obj_data.put('courseTable',obj_table);
      obj_table     := hcm_util.get_json_t(json_object_t(clob_table),'developTable');
      obj_data.put('developTable',obj_table);

      gen_detail_table(clob_table);
      obj_table     := json_object_t(clob_table);
      obj_data.put('table',obj_table);

      json_str_output := obj_data.to_clob;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob,json_str_output out clob) is
    json_input              json_object_t;
    param_json              json_object_t;
    param_json_row          json_object_t;

    obj_detail              json_object_t;
    param_detail            json_object_t;
    param_table             json_object_t;


    v_flgapman              tappfm.flgapman%type;
    v_flgtypap              tstdisd.flgtypap%type;
    v_dteapend              tstdisd.dteapend%type;
    v_dteapstr              tappfm.dteapstr%type;
    v_flgappr               tappfm.flgappr%type;
    v_remark                tappemp.remark%type;
    v_remark2               tappemp.remark2%type;
    v_remark3               tappemp.remark3%type;
    v_commtimpro            tappemp.commtimpro%type;

    v_flgconf               tappemp.flgconfemp%type;
    v_dteconf               tappemp.dteconfemp%type;

    v_codgrplv              tappempta.codgrplv%type;
    v_qtyleav               tappempta.qtyleav%type;
    v_qtyscor               tappempta.qtyscor%type;

    v_codpunsh              tappempmt.codpunsh%type;
    v_qtypunsh              tappempmt.qtypunsh%type;

    v_flgbonus              tappemp.flgbonus%type;
    v_flgsal                tappemp.flgsal%type;
    v_pctdbon               tappemp.pctdbon%type;
    v_pctdsal               tappemp.pctdsal%type;
    v_scorepunsh            tappempmt.qtyscor%type;
    v_scoreta               tappempta.qtyscor%type;
    v_scorfpunsh            tattpreh.scorfpunsh%type;
    v_scorfta               tattpreh.scorfta%type;

    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;
    obj_data                json_object_t;
    clob_table              clob;
    obj_table               json_object_t;

    v_flgconfemp            tappemp.flgconfemp%type;
    v_dteconfemp            tappemp.dteconfemp%type;
    v_flgconfhd             tappemp.flgconfhd%type;
    v_dteconfhd             tappemp.dteconfhd%type;
    v_flgconflhd            tappemp.flgconflhd%type;
    v_dteconflhd            tappemp.dteconflhd%type;
    v_codaplvl              tstdisd.codaplvl%type;

    v_qtyta                 number :=0;
    v_qtypuns               number :=0;

  begin
    initial_value(json_str_input);
    json_input              := json_object_t(json_str_input);
    param_detail            := hcm_util.get_json_t(json_input,'param_detail');

    obj_detail              := hcm_util.get_json_t(param_detail,'detail');
    p_codcompy              := hcm_util.get_string_t(obj_detail,'codcompy');
    p_codempid_query        := hcm_util.get_string_t(obj_detail,'codempid');
    p_dteyreap              := hcm_util.get_string_t(obj_detail,'dteyreap');
    p_numtime               := hcm_util.get_string_t(obj_detail,'numtime');
    p_numseq                := hcm_util.get_string_t(obj_detail,'numseq');
    p_codapman              := hcm_util.get_string_t(obj_detail,'codapman');
    p_dteapman              := to_date(hcm_util.get_string_t(obj_detail,'dteapman'),'dd/mm/yyyy');
    v_dteapstr              := to_date(hcm_util.get_string_t(obj_detail,'dteapstr'),'dd/mm/yyyy');
    v_dteapend              := to_date(hcm_util.get_string_t(obj_detail,'dteapend'),'dd/mm/yyyy');
    v_flgappr               := hcm_util.get_string_t(obj_detail,'flgappr');
    v_flgconf               := hcm_util.get_string_t(obj_detail,'flgconf');
    v_dteconf               := to_date(hcm_util.get_string_t(obj_detail,'dteconf'),'dd/mm/yyyy');
    v_remark                := hcm_util.get_string_t(obj_detail,'remark');
    v_remark2               := hcm_util.get_string_t(obj_detail,'remark2');
    v_remark3               := hcm_util.get_string_t(obj_detail,'remark3');
    v_commtimpro            := hcm_util.get_string_t(obj_detail,'commtimpro');

    select flgapman, codcomp, codaplvl
      into v_flgapman, p_codcomp, p_codaplvl
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    gen_workingtime_detail(clob_table);
    obj_detail      := hcm_util.get_json_t(json_object_t(clob_table),'detail');
    v_flgbonus      := hcm_util.get_string_t(obj_detail,'flgbonus');
    v_flgsal        := hcm_util.get_string_t(obj_detail,'flgsal');
    v_pctdbon       := hcm_util.get_string_t(obj_detail,'pctdbon');
    v_pctdsal       := hcm_util.get_string_t(obj_detail,'pctdsal');
    v_scorepunsh    := hcm_util.get_string_t(obj_detail,'scorepunsh');
    v_scoreta       := hcm_util.get_string_t(obj_detail,'scoreta');
    v_scorfpunsh    := hcm_util.get_string_t(obj_detail,'scorfpunsh');
    v_scorfta       := hcm_util.get_string_t(obj_detail,'scorfta');

    obj_table       := hcm_util.get_json_t(json_object_t(clob_table),'leaveGroupTable');
    param_json      := obj_table;


    begin
        delete tappempta
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
    exception when others then
        null;
    end;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codgrplv           := hcm_util.get_string_t(param_json_row,'codgrplv');
        v_qtyleav           := hcm_util.get_string_t(param_json_row,'qtyleav');
        v_qtyscor           := hcm_util.get_string_t(param_json_row,'qtyscor');

        begin
            insert into tappempta (codempid,dteyreap,numtime,
                                  codgrplv,qtyleav,qtyscor,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,
                    v_codgrplv,v_qtyleav,v_qtyscor,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappempta
               set qtyscor = v_qtyscor,
                   qtyleav = v_qtyleav,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and codgrplv = v_codgrplv;
        end ;
    end loop;

    obj_table     := hcm_util.get_json_t(json_object_t(clob_table),'workTable');
    param_json    := obj_table;

    begin
        delete tappempmt
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
    exception when others then
        null;
    end;

    for i in 0..(param_json.get_size - 1) loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_codpunsh          := hcm_util.get_string_t(param_json_row,'codpunsh');
        v_qtypunsh          := hcm_util.get_string_t(param_json_row,'qtypunsh');
        v_qtyscor           := hcm_util.get_string_t(param_json_row,'qtyscor');

        begin
            insert into tappempmt (codempid,dteyreap,numtime,
                                  codpunsh,qtypunsh,qtyscor,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dteyreap,p_numtime,
                    v_codpunsh,v_qtypunsh,v_qtyscor,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
            update tappempmt
               set qtyscor = v_qtyscor,
                   qtypunsh = v_qtypunsh,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid = p_codempid_query
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and codpunsh = v_codpunsh;
        end ;
    end loop;

    begin
--Redmine #5552
        v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid_query);
--Redmine #5552
        select flgtypap , dteapend
          into v_flgtypap , v_global_dteapend
          from tstdisd
         where codcomp = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteyreap = p_dteyreap
           and numtime = p_numtime
--Redmine #5552
           and codaplvl = v_codaplvl;
--Redmine #5552
    exception when others then
        v_flgtypap := 'T';
    end;

    update tappfm
       set codapman = p_codapman,
           dteapman = p_dteapman,
           dteapstr = v_dteapstr,
           dteapend = v_dteapend,
           flgappr = v_flgappr,
           flgapman = v_flgapman,
           flgtypap = v_flgtypap,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    if v_flgapman != '3' then
        v_flgappr := null;
    end if;

    insert_tappemp(p_codempid_query, p_dteyreap, p_numtime, p_numseq);

    if v_scorfta is null then
        v_scorfta := 0;
    end if;
    if v_scorfpunsh is null then
        v_scorfpunsh := 0;
    end if;
    if v_scoreta is null then
        v_scoreta := 0;
    end if;
    if v_scorepunsh is null then
        v_scorepunsh := 0;
    end if;

    if v_scoreta <> 0 then
        v_qtyta := round((v_scoreta/v_scorfta*100),2);
    end if;

     if v_scorepunsh <> 0 then
        v_qtypuns := round((v_scorepunsh/v_scorfpunsh*100),2);
    end if;

    update tappemp
       set flgappr = nvl(v_flgappr,flgappr),
           remark = v_remark,
           remark2 = v_remark2,
           remark3 = v_remark3,
           commtimpro = v_commtimpro,
           qtyta = v_qtyta,
           qtypuns = v_qtypuns,
           flgsal = v_flgsal,
           flgbonus = v_flgbonus,
           pctdbon = v_pctdbon,
           pctdsal = v_pctdsal,
           dteupd = sysdate,
           coduser = global_v_coduser
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;


    if v_flgapman = '3' and v_flgappr = 'C' then
        save_lastapp;
    end if;

    upd_tappemp_qtytot(p_codempid_query, p_dteyreap, p_numtime, v_flgapman, v_global_dteapend, v_flgconf, v_dteconf);

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_lastapp is
    cursor c_tappcmps is
        select *
          from tappcmps
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
           and grade < gradexpct;

    cursor c_tapptrn is
        select *
          from tapptrn
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;

    cursor c_tappdev is
        select *
          from tappdev
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
  begin

    begin
        for r1 in c_tappcmps loop
            begin
                insert into tappcmpf (codempid,dteyreap,numtime,
                                      codtency,codskill,gradexpct,grade,qtyscor,remark,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,
                                      r1.codtency,r1.codskill,r1.gradexpct,r1.grade,r1.qtyscor,r1.remark,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end;
        end loop;

        for r2 in c_tapptrn loop
            begin
                insert into tapptrnf (codempid,dteyreap,numtime,codcours,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,r2.codcours,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                null;
            end;
        end loop;

        for r3 in c_tappdev loop
            begin
                insert into tappdevf (codempid,dteyreap,numtime,
                                      coddevp,desdevp,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dteyreap,p_numtime,
                        r3.coddevp,r3.desdevp,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when dup_val_on_index then
                null;
            when others then
                null;
            end;
        end loop;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure sendmail(json_str_input in clob,json_str_output out clob) is
    json_input              json_object_t;
    param_json              json_object_t;
    param_json_row          json_object_t;
    v_rowid                 rowid;

    v_msg_to        clob;
	v_templete_to   clob;

    v_codempid          tappfm.codapman%type;
    v_error			    terrorm.errorno%type;
    v_codapman          tappfm.codapman%type;
    v_codposap          tappfm.codposap%type;
    v_codcompap         tappfm.codcompap%type;

    cursor c_codapman is
        select codempid
          from temploy1
         WHERE codcomp = v_codcompap
           and codpos = v_codposap
           and staemp IN ('1','3')
         union
        select codempid
          from tsecpos
         where codcomp = v_codcompap
           and codpos = v_codposap
           and dteeffec <= SYSDATE
           and ( nvl(dtecancel, dteend) >= trunc(SYSDATE)
                 or nvl(dtecancel, dteend) IS NULL ) ;

  begin
    initial_value(json_str_input);
--    json_input              := json_object_t(json_str_input);
--    p_codempid_query        := hcm_util.get_string_t(json_input,'p_codempid_query');
--    p_dteyreap              := hcm_util.get_string_t(json_input,'dteyreap');
--    p_numtime               := hcm_util.get_string_t(json_input,'p_numtime');
--    p_numseq                := hcm_util.get_string_t(json_input,'p_numseq');

    begin
        select rowid, codapman, codposap, codcompap
          into v_rowid, v_codapman, v_codposap, v_codcompap
          from tappfm
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq + 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPFM');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end;
    if v_codapman is not null then
        v_codempid := v_codapman;
        chk_flowmail.get_message_result('HRAP31ETO', global_v_lang, v_msg_to, v_templete_to);
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPFM', v_rowid, get_label_name('HRAP31E1', global_v_lang, 160), 'HRAP31ETO', '1', null, global_v_coduser, global_v_lang, v_msg_to);
        v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRBF3ZU1', global_v_lang, 250), 'U', global_v_lang, null);
    else
        for r1 in c_codapman loop
            v_codempid :=  r1.codempid;
            chk_flowmail.get_message_result('HRAP31ETO', global_v_lang, v_msg_to, v_templete_to);
            chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPFM', v_rowid, get_label_name('HRAP31E1', global_v_lang, 160), 'HRAP31ETO', '1', null, global_v_coduser, global_v_lang, v_msg_to);
            v_error := chk_flowmail.send_mail_to_emp (v_codempid, global_v_coduser, v_msg_to, NULL, get_label_name('HRBF3ZU1', global_v_lang, 250), 'U', global_v_lang, null);
        end loop;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2046',global_v_lang);
      json_str_output := get_response_message(201,param_msg_error,global_v_lang);
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date) as
    cursor c_taplvl is
      select dteeffec,codcomp
        from taplvl
       where p_codcomp_in like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_global_dteapend
      order by codcomp desc,dteeffec desc;
  begin
    for r_taplvl in c_taplvl loop
      p_dteeffec := r_taplvl.dteeffec;
      p_codcomp_out := r_taplvl.codcomp;
      exit;
    end loop;
  end;

  procedure insert_tappemp(p_codempid_query varchar2, p_dteyreap number,  p_numtime number, p_numseq number) as
    t_tappfm                tappfm%rowtype;
    v_numlvl                temploy1.numlvl%type;
    v_jobgrade              temploy1.jobgrade%type;
  begin
    select *
      into t_tappfm
      from tappfm
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq ;

    begin
        select numlvl ,jobgrade
          into v_numlvl,v_jobgrade
          from temploy1
         where codempid = p_codempid_query;
    exception when no_data_found then
        v_numlvl    := null;
        v_jobgrade  := null;
    end;
    begin
        insert into tappemp (codempid,dteyreap,numtime,
                             codcomp,codpos,numlvl,codaplvl,jobgrade,
                             dtecreate,codcreate,dteupd,coduser,flgappr)
        values ( p_codempid_query,p_dteyreap,p_numtime,
                 t_tappfm.codcomp,t_tappfm.codpos,v_numlvl,t_tappfm.codaplvl,nvl(t_tappfm.jobgrade,v_jobgrade),
                 sysdate,global_v_coduser,sysdate,global_v_coduser,'P');
    exception when dup_val_on_index then
        null;
    end;
  end;

  procedure upd_tappemp_qtytot(p_codempid_query varchar2, p_dteyreap number,  p_numtime number, p_flgapman varchar2,
                               p_dteapend date, p_flgconf varchar2, p_dteconf date) as
    t_tappfm                tappfm%rowtype;
    v_numlvl                temploy1.numlvl%type;
    v_jobgrade              temploy1.jobgrade%type;
    t_taplvl                taplvl%rowtype;
    t_tappemp               tappemp%rowtype;
    v_qtytot1               tappemp.qtytot%type;
    v_qtytot2               tappemp.qtytot2%type;
    v_qtytot3               tappemp.qtytot3%type;

  begin
    v_global_dteapend := p_dteapend;
    get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

    select *
      into t_taplvl
      from taplvl
     where codcomp = v_taplvl_codcomp
       and codaplvl = p_codaplvl
       and dteeffec = v_taplvl_dteeffec;

    select *
      into t_tappemp
      from tappemp
     where codempid = p_codempid_query
       and dteyreap = p_dteyreap
       and numtime = p_numtime;

    if p_flgapman in ('1','4')  then
        v_qtytot1  := ((nvl(t_tappemp.qtybeh,0) * nvl(t_taplvl.pctbeh,0)) /100) +
                      ((nvl(t_tappemp.qtycmp,0) * nvl(t_taplvl.pctcmp,0)) /100) +
                      ((nvl(t_tappemp.qtykpic,0) * nvl(t_taplvl.pctkpirt,0)) /100) +
                      ((nvl(t_tappemp.qtykpid,0) * nvl(t_taplvl.pctkpicp,0)) /100) +
                      ((nvl(t_tappemp.qtykpie,0) * nvl(t_taplvl.pctkpiem,0)) /100) +
                      ((nvl(t_tappemp.qtyta,0) * nvl(t_taplvl.pctta,0)) /100) +
                      ((nvl(t_tappemp.qtypuns,0) * nvl(t_taplvl.pctpunsh,0)) /100);

        update tappemp
           set codform = t_taplvl.codform,
               qtytot = v_qtytot1,
               flgconfemp = nvl(p_flgconf,flgconfemp),
               dteconfemp =  nvl(p_dteconf,dteconfemp),
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
    elsif p_flgapman = '2'  then
        v_qtytot2  := ((nvl(t_tappemp.qtybeh2,0) * nvl(t_taplvl.pctbeh,0)) /100) +
                      ((nvl(t_tappemp.qtycmp2,0) * nvl(t_taplvl.pctcmp,0)) /100) +
                      ((nvl(t_tappemp.qtykpic,0) * nvl(t_taplvl.pctkpirt,0)) /100) +
                      ((nvl(t_tappemp.qtykpid,0) * nvl(t_taplvl.pctkpicp,0)) /100) +
                      ((nvl(t_tappemp.qtykpie2,0) * nvl(t_taplvl.pctkpiem,0)) /100) +
                      ((nvl(t_tappemp.qtyta,0) * nvl(t_taplvl.pctta,0)) /100) +
                      ((nvl(t_tappemp.qtypuns,0) * nvl(t_taplvl.pctpunsh,0)) /100);

        update tappemp
           set codform = t_taplvl.codform,
               qtytot2 = v_qtytot2,
               flgconfhd = nvl(p_flgconf,flgconfhd),
               dteconfhd = nvl(p_dteconf,dteconfhd),
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
    elsif p_flgapman = '3'  then
        v_qtytot3  := ((nvl(t_tappemp.qtybeh3,0) * nvl(t_taplvl.pctbeh,0)) /100) +
                      ((nvl(t_tappemp.qtycmp3,0) * nvl(t_taplvl.pctcmp,0)) /100) +
                      ((nvl(t_tappemp.qtykpic,0) * nvl(t_taplvl.pctkpirt,0)) /100) +
                      ((nvl(t_tappemp.qtykpid,0) * nvl(t_taplvl.pctkpicp,0)) /100) +
                      ((nvl(t_tappemp.qtykpie3,0) * nvl(t_taplvl.pctkpiem,0)) /100) +
                      ((nvl(t_tappemp.qtyta,0) * nvl(t_taplvl.pctta,0)) /100) +
                      ((nvl(t_tappemp.qtypuns,0) * nvl(t_taplvl.pctpunsh,0)) /100);

        update tappemp
           set codform = t_taplvl.codform,
               qtytot3 = v_qtytot3,
               flgconflhd = nvl(p_flgconf,flgconflhd),
               dteconflhd = nvl(p_dteconf,dteconflhd),
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
    end if;
  end;
end;

/

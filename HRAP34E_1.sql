--------------------------------------------------------
--  DDL for Package Body HRAP34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP34E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
    v_codaplvl tstdisd.codaplvl%type;
  begin
    global_v_coduser          := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid         := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang             := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap          := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_codapman          := hcm_util.get_string_t(json_obj,'p_codapman');
    b_index_dteapman          := to_date(hcm_util.get_string_t(json_obj,'p_dteapman'),'dd/mm/yyyy');
    b_index_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_flgtypap          := hcm_util.get_string_t(json_obj,'p_flgtypap'); -- B= BEH, C = CMP
    b_index_codaplvl          := hcm_util.get_string_t(json_obj,'p_codaplvl');
    v_global_codempid_query   := hcm_util.get_string_t(json_obj,'p_codempid_query');
    v_global_numseq           := hcm_util.get_string_t(json_obj,'p_numseq');
    v_global_flgapman         := hcm_util.get_string_t(json_obj,'p_flgapman');
    v_global_codform          := hcm_util.get_string_t(json_obj,'p_codform');
    v_total_numtime           := to_number(hcm_util.get_string_t(json_obj,'total_numtime'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    begin
      select dteapstr,dteapend,flgtypap
        into v_global_dteapstr,v_global_dteapend,v_global_flgtypap
        from tstdisd
       where codcomp  = hcm_util.get_codcomp_level(b_index_codcomp,1)
         and codaplvl = b_index_codaplvl
         and dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and rownum = 1  ;
    exception when no_data_found then
      v_global_dteapstr := null;
      v_global_dteapend := null;
    end;
    if v_global_dteapend is null then
      v_global_dteapend := to_date(hcm_util.get_string_t(json_obj,'p_dteapend'),'dd/mm/yyyy');
    end if;

  end initial_value;
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
  --
  procedure check_index is
    v_secur       boolean := false;
  begin
    if b_index_codapman is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codapman);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dteapman is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteapman');
      return;
    else
      if b_index_dteapman not between v_global_dteapstr and v_global_dteapend then
        param_msg_error := get_error_msg_php('AP0039',global_v_lang);
        return;
      end if;
    end if;
  end check_index;
  --
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
  --
  function get_codform(p_codcomp varchar2,p_codaplvl varchar2,p_dteapend date) return varchar2 is
    v_codform             taplvl.codform%type;
    v_taplvl_codcomp      taplvl.codcomp%type;
    v_taplvl_dteeffec     taplvl.dteeffec%type;
  begin
    get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);
    begin
        select codform
          into v_codform
          from taplvl
         where codcomp  = v_taplvl_codcomp
           and codaplvl = p_codaplvl
           and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
        v_codform := null;
    end;
    return v_codform;
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

  procedure get_taplvld_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date) as
    cursor c_taplvld is
      select dteeffec,codcomp
        from taplvld
       where p_codcomp_in like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_global_dteapend
      order by codcomp desc,dteeffec desc;
  begin
    for r_taplvld in c_taplvld loop
      p_dteeffec := r_taplvld.dteeffec;
      p_codcomp_out := r_taplvld.codcomp;
      exit;
    end loop;
  end;

  procedure cal_all_score(
            p_codempid        in varchar2,
            p_dteyreap        in varchar2,
            p_numtime         in number,
            p_numseq          in number,
            p_codform         in varchar2,
            p_codcomp         in varchar2,
            p_codpos          in varchar2,
            p_codaplvl        in varchar2,
            obj_beh           in out json_object_t,
            obj_cmp           in out json_object_t,
            p_qtyscornet      out number,  -- net score of beh or cmp
            p_qtyta           out number,  -- time attendance score          (score/fscore*100)
            p_qtypuns         out number,  -- punish score                   (score/fscore*100)
            p_qtyta_puns      out number,  -- time attendance + punish score (score/fscore*100)
            p_qtybeh          out number,  -- behavior score                 (score/fscore*100)
            p_qtycmp          out number,  -- competency score               (score/fscore*100)
            p_qtykpi          out number,  -- kpi score                      (score/fscore*100)
            p_qtytot          out number,  -- total of all score weight 100%
            p_total_numitem   out number,  -- amount of beh or cmp item
            obj_numtime       out json_object_t,
            obj_numtime_label out json_object_t
  ) as
    t_tappfm                      tappfm%rowtype;
    t_tappemp                     tappemp%rowtype;
    t_taplvl                      taplvl%rowtype;
    v_taplvl_codcomp              taplvl.codcomp%type;
    v_taplvl_dteeffec             taplvl.dteeffec%type;
    v_taplvld_codcomp             taplvld.codcomp%type;
    v_taplvld_dteeffec            taplvld.dteeffec%type;
    v_count_numitem               number := 0;
    v_total_numitem               number := 0;
    v_max_numitem                 number := 0;
    v_codtency                    tjobposskil.codtency%type;
    v_numitem                     varchar2(100 char);
    v_qtyscor                     number := 0;

    obj_data_input_worktime       json_object_t;
    obj_data_output_worktime      json_object_t;
    obj_worktime_detail           json_object_t;
    json_str_input_worktime       clob;
    json_str_output_worktime      clob;

    v_scoreta                     tappempta.qtyscor%type;
    v_scorfta                     tattpreh.scorfta%type;
    v_scorepunsh                  tappempmt.qtyscor%type;
    v_scorfpunsh                  tattpreh.scorfpunsh%type;

    v_flg_has_beh                 boolean := false;
    v_flg_has_cmp                 boolean := false;
    v_qtybeh_sum                  number := 0;
    v_qtycmp_sum                  number := 0;
    v_qtybehf_sum                 number := 0;
    v_qtycmpf_sum                 number := 0;

    v_qtycmp_group_sum            number := 0;
    v_qtycmpf_group_sum           number := 0;
    v_qtycmp_sum_with_weight      number := 0;

    cursor c_beh is
      select a.numgrup,a.numitem,a.qtyfscor,a.qtywgt,nvl(b.grdscor,'') qtyscor,nvl(b.qtyscorn,'') qtyscorn
        from tintvewd a, tappbehi b
       where a.numgrup     = b.numgrup(+)
         and a.numitem     = b.numitem(+)
         and a.codform     = p_codform
         and b.codempid(+) = p_codempid
         and b.dteyreap(+) = p_dteyreap
         and b.numtime(+)  = p_numtime
         and b.numseq(+)   = p_numseq
      order by a.numgrup,a.numitem;

    cursor c_cmp is
      select a.codtency,b.codskill,a.qtywgt,b.fscore,c.grade,c.qtyscor
        from taplvld a, tjobposskil b, tappcmps c
       where a.codcomp     = v_taplvld_codcomp
         and a.codaplvl    = p_codaplvl
         and a.dteeffec    = v_taplvld_dteeffec
         and a.codtency    = b.codtency
         and b.codcomp     = p_codcomp
         and b.codpos      = p_codpos
         and b.codtency    = c.codtency(+)
         and b.codskill    = c.codskill(+)
         and c.codempid(+) = p_codempid
         and c.dteyreap(+) = p_dteyreap
         and c.numtime(+)  = p_numtime
         and c.numseq(+)   = p_numseq
      order by a.codtency,b.codskill;
  begin
    obj_numtime := json_object_t();
    obj_numtime_label := json_object_t();

    -- beh item
    v_count_numitem := 0;
    for r_beh in c_beh loop
      -- sum score of all beh item
      if obj_beh.get_size = 0 then -- cal score from tappfm
        v_qtyscor := r_beh.qtyscorn;
      else -- cal score from input display
        v_count_numitem := v_count_numitem + 1;
        v_numitem := hcm_util.get_string_t(obj_beh,to_char(v_count_numitem));
        -- get score from grade
        begin
          select qtyscor
            into v_qtyscor
            from tintscor
           where codform = p_codform
             and grad    = v_numitem;
        exception when no_data_found then
          v_qtyscor := null;
        end;
        v_qtyscor := v_qtyscor * nvl(r_beh.qtywgt,0);
      end if;

      v_flg_has_beh := v_qtyscor is not null;
      v_qtybeh_sum  := v_qtybeh_sum + nvl(v_qtyscor,0);        -- sum score of all beh item

      v_qtybehf_sum := v_qtybehf_sum + nvl(r_beh.qtyfscor,0);  -- sum full score of all beh item

      if b_index_flgtypap = 'B' then
        v_total_numitem := v_total_numitem + 1;
        obj_numtime.put('flgNumitem'||v_total_numitem,false);
        obj_numtime.put('qtywgt'||v_total_numitem,to_char(r_beh.qtywgt));
        obj_numtime.put('numitem'||v_total_numitem,to_char(r_beh.qtyscor));
        obj_numtime.put('numitem'||v_total_numitem||'CheckChange',to_char(r_beh.qtyscor));
        obj_numtime.put('qtyscorn'||v_total_numitem,to_char(r_beh.qtyscorn));
        obj_numtime.put('numgrup'||v_total_numitem,to_char(r_beh.numgrup));
        obj_numtime.put('numitem_grup'||v_total_numitem,to_char(r_beh.numitem));

        -- set label for item
        obj_numtime_label.put('numitem'||v_total_numitem,to_char(v_total_numitem));
      end if;
    end loop;

    -- cmp item
    v_count_numitem := 0;
    get_taplvld_where(p_codcomp,p_codaplvl,v_taplvld_codcomp,v_taplvld_dteeffec);
    for r_cmp in c_cmp loop
      -- sum score of all cmp item
      if obj_cmp.get_size = 0 then -- cal score from tappfm
        v_qtyscor := r_cmp.qtyscor;
      else -- cal score from input display
        v_count_numitem := v_count_numitem + 1;
        v_numitem := hcm_util.get_string_t(obj_cmp,to_char(v_count_numitem));
        v_qtyscor := get_competency_score(p_codcomp,p_codpos,r_cmp.codtency,r_cmp.codskill,v_numitem);
      end if;

      v_flg_has_cmp := v_qtyscor is not null;
      v_qtycmp_sum  := v_qtycmp_sum  + nvl(v_qtyscor,0);     -- sum score of all cmp item
      v_qtycmpf_sum := v_qtycmpf_sum + nvl(r_cmp.fscore,0);  -- sum full score of all cmp item

      if b_index_flgtypap = 'C' then
        v_total_numitem := v_total_numitem + 1;
        obj_numtime.put('flgNumitem'||v_total_numitem,false);
        obj_numtime.put('qtywgt'||v_total_numitem,to_char(r_cmp.qtywgt));
        obj_numtime.put('numitem'||v_total_numitem,to_char(r_cmp.grade));
        obj_numtime.put('qtyscorn'||v_total_numitem,to_char(r_cmp.qtyscor));
        obj_numtime.put('codtency'||v_total_numitem,r_cmp.codtency);
        obj_numtime.put('codskill'||v_total_numitem,r_cmp.codskill);

        -- set label for item
        obj_numtime_label.put('numitem'||v_total_numitem,to_char(v_total_numitem));
      end if;

      -- sum qtycmp for each codtency
      if nvl(v_codtency,'$#@') <> r_cmp.codtency then
        v_codtency := r_cmp.codtency;
        if v_qtycmpf_group_sum > 0 then
          v_qtycmp_sum_with_weight := v_qtycmp_sum_with_weight + (v_qtycmp_group_sum/v_qtycmpf_group_sum);
        end if;
        v_qtycmp_group_sum  := 0;
        v_qtycmpf_group_sum := 0;
      end if;
      v_qtycmp_group_sum  := v_qtycmp_group_sum  + (nvl(v_qtyscor,0) * nvl(r_cmp.qtywgt,0));
      v_qtycmpf_group_sum := v_qtycmpf_group_sum + nvl(r_cmp.fscore,0);
    end loop;

    p_total_numitem := v_total_numitem;

    -- for last codtency
    if v_qtycmpf_group_sum > 0 then
      v_qtycmp_sum_with_weight := v_qtycmp_sum_with_weight + (v_qtycmp_group_sum/v_qtycmpf_group_sum);
    end if;

    -- call workingtime from hrap31e
    begin
      obj_data_input_worktime := json_object_t();
      obj_data_input_worktime.put('p_lang',global_v_lang);
      obj_data_input_worktime.put('p_dteyreap',p_dteyreap);
      obj_data_input_worktime.put('p_numtime',p_numtime);
      obj_data_input_worktime.put('p_numseq',p_numseq);
      obj_data_input_worktime.put('p_codempid_query',p_codempid);
      obj_data_input_worktime.put('p_codcompy',hcm_util.get_codcomp_level(p_codcomp,1));
      obj_data_input_worktime.put('p_codcomp',p_codcomp);
      obj_data_input_worktime.put('p_codaplvl',p_codaplvl);
      json_str_input_worktime := obj_data_input_worktime.to_clob;

      hrap31e.get_workingtime_detail(json_str_input_worktime,json_str_output_worktime);

      obj_data_output_worktime := json_object_t(json_str_output_worktime);
      obj_worktime_detail := hcm_util.get_json_t(obj_data_output_worktime,'detail');
      v_scoreta    := to_number(hcm_util.get_string_t(obj_worktime_detail,'scoreta'));
      v_scorfta    := to_number(hcm_util.get_string_t(obj_worktime_detail,'scorfta'));
      v_scorepunsh := to_number(hcm_util.get_string_t(obj_worktime_detail,'scorepunsh'));
      v_scorfpunsh := to_number(hcm_util.get_string_t(obj_worktime_detail,'scorfpunsh'));
      p_qtyta      := (v_scoreta / v_scorfta) * 100;
      p_qtypuns    := (v_scorepunsh / v_scorfpunsh) * 100;
      p_qtyta_puns := (nvl(v_scoreta,0) + nvl(v_scorepunsh,0)) / 2; -- #7434
      --p_qtyta_puns := ((v_scoreta + v_scorepunsh) / (v_scorfta + v_scorfpunsh)) * 100;  --#7434
    exception when others then
      p_qtyta   := null;
      p_qtypuns := null;
      p_qtyta_puns := null;
      param_msg_error := sqlerrm;
    end;

    if v_qtybehf_sum > 0 then
      p_qtybeh := (v_qtybeh_sum / v_qtybehf_sum) * 100;
    end if;
    if not v_flg_has_beh then
      p_qtybeh := null;
    end if;

    if v_qtycmpf_sum > 0 then
      p_qtycmp := (v_qtycmp_sum / v_qtycmpf_sum) * 100;
    end if;
    if not v_flg_has_cmp then
      p_qtycmp := null;
    end if;

    if b_index_flgtypap = 'B' then    -- beh
      p_qtyscornet := v_qtybeh_sum;
    elsif b_index_flgtypap = 'C' then -- cmp
      p_qtyscornet := v_qtycmp_sum;
    end if;

    begin
      select *
        into t_tappfm
        from tappfm
       where codempid = p_codempid
         and dteyreap = p_dteyreap
         and numtime  = p_numtime
         and numseq   = p_numseq;
    exception when no_data_found then
      t_tappfm := null;
    end;
    if t_tappfm.qtykpif > 0 then
      p_qtykpi := (t_tappfm.qtykpi / t_tappfm.qtykpif) * 100;
    end if;

    -- get total score with weight from taplvl and taplvld (hrrp14e)
    get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);
    begin
      select *
        into t_taplvl
        from taplvl
       where codcomp  = v_taplvl_codcomp
         and codaplvl = p_codaplvl
         and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
      t_taplvl := null;
    end;

    begin
      select *
        into t_tappemp
        from tappemp
       where codempid = p_codempid
         and dteyreap = p_dteyreap
         and numtime  = p_numtime;
    exception when no_data_found then
      t_tappemp := null;
    end;

    p_qtytot := ((nvl(p_qtybeh,0) * t_taplvl.pctbeh) /100) +
                (nvl(v_qtycmp_sum_with_weight,0)) +
                ((nvl(t_tappemp.qtykpic,0) * t_taplvl.pctkpirt) /100) +
                ((nvl(t_tappemp.qtykpid,0) * t_taplvl.pctkpicp) /100) +
                ((nvl(p_qtykpi,0) * t_taplvl.pctkpiem) /100) +
                ((nvl(p_qtyta,0) * t_taplvl.pctta) /100) +
                ((nvl(p_qtypuns,0) * t_taplvl.pctpunsh) /100);

    -- set format 2 digit
    p_qtyta       := to_char(p_qtyta,'fm999999.90');
    p_qtypuns     := to_char(p_qtypuns,'fm999999.90');
    p_qtyta_puns  := to_char(p_qtyta_puns,'fm999999.90');
    p_qtybeh      := to_char(p_qtybeh,'fm999999.90');
    p_qtycmp      := to_char(p_qtycmp,'fm999999.90');
    p_qtyscornet  := to_char(p_qtyscornet,'fm999999.90');
    p_qtykpi      := to_char(p_qtykpi,'fm999999.90');
    p_qtytot      := to_char(p_qtytot,'fm999999.90');

  end;

  procedure gen_index_record(r_tappfm          in tappfm%rowtype,
                             p_total_numitem   out number,
                             obj_data          out json_object_t,
                             obj_numtime_label out json_object_t
  ) as
    obj_numtime                 json_object_t;
    v_taplvl_codcomp            taplvl.codcomp%type;
    v_taplvl_dteeffec           taplvl.dteeffec%type;

    v_weight                    number;
    v_flg_chk_disable           boolean := false;
    v_qty_codapman              number;
    v_flgconfemp                tappemp.flgconfemp%type;
    v_remark                    varchar2(4000 char);
    v_flgappr_p                 varchar2(10 char);
    v_flgappr_n                 varchar2(10 char);

    -- parameter for cal_all_score
    v_qtyta_puns                number;
    v_qtyta                     number;
    v_qtypuns                   number;
    v_qtybeh                    number;
    v_qtycmp                    number;
    v_qtykpi                    number;
    v_qtyscornet                number := 0;
    v_qtytot                    number;
    obj_beh                     json_object_t := json_object_t();
    obj_cmp                     json_object_t := json_object_t();

  begin
    obj_data := json_object_t();

    -- check exists beh and cmp setting
    get_taplvl_where(r_tappfm.codcomp,r_tappfm.codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);
    begin
      select decode(b_index_flgtypap,'B',pctbeh,'C',pctcmp,0) weight
        into v_weight
        from taplvl
       where codcomp  = v_taplvl_codcomp
         and codaplvl = r_tappfm.codaplvl
         and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
      v_weight := 0;
    end;

    if v_weight > 0 then
      obj_data.put('coderror','200');

      -- 0.check disable record
      v_flg_chk_disable := false; -- enable record
      begin
        select flgconfemp
          into v_flgconfemp
          from tappemp
         where codempid = r_tappfm.codempid
           and dteyreap = r_tappfm.dteyreap
           and numtime  = r_tappfm.numtime;
      exception when no_data_found then
        v_flgconfemp := null;
      end;

      if nvl(v_flgconfemp,'N') = 'Y' then
        v_flg_chk_disable := true; -- disable record
      end if;

      --check bottom up / 360
      if v_global_flgtypap = 'T' then
        -- get flgappr of previous approval
        begin
          select nvl(flgappr,'P')
            into v_flgappr_p
            from tappfm
           where codempid = r_tappfm.codempid
             and dteyreap = r_tappfm.dteyreap
             and numtime  = r_tappfm.numtime
             and numseq   = r_tappfm.numseq - 1;
        exception when no_data_found then
          v_flgappr_p := 'X';
        end;

        -- get flgappr of next approval
        begin
          select nvl(flgappr,'X')
            into v_flgappr_n
            from tappfm
           where codempid = r_tappfm.codempid
             and dteyreap = r_tappfm.dteyreap
             and numtime  = r_tappfm.numtime
             and numseq   = r_tappfm.numseq + 1;
        exception when no_data_found then
          v_flgappr_n := 'X';
        end;
        -- disabled record
        if v_flgappr_p = 'P' or v_flgappr_n in ('P','C') then
          v_flg_chk_disable := true;
        end if;
      end if;

      obj_data.put('flgChkDisable',v_flg_chk_disable);

      -- 1.image + codempid
      obj_data.put('image',get_emp_img(r_tappfm.codempid));
      obj_data.put('codempid',r_tappfm.codempid);

      -- 2.codform
      obj_data.put('codform',r_tappfm.codform);

      -- 3.qty_codapman
      begin
        select count(numseq)
        into v_qty_codapman
          from tappfm
         where codempid = r_tappfm.codempid
           and dteyreap = r_tappfm.dteyreap
           and numtime  = r_tappfm.numtime
           and flgappr  = 'C';
      exception when others then
        v_qty_codapman := 0;
      end;
      obj_data.put('qty_codapman',to_char(v_qty_codapman));

      -- get all score
      cal_all_score(
        p_codempid        => r_tappfm.codempid,
        p_dteyreap        => r_tappfm.dteyreap,
        p_numtime         => r_tappfm.numtime,
        p_numseq          => r_tappfm.numseq,
        p_codform         => r_tappfm.codform,
        p_codcomp         => r_tappfm.codcomp,
        p_codpos          => r_tappfm.codpos,
        p_codaplvl        => r_tappfm.codaplvl,
        obj_beh           => obj_beh,
        obj_cmp           => obj_cmp,
        p_qtyscornet      => v_qtyscornet,
        p_qtyta           => v_qtyta,
        p_qtypuns         => v_qtypuns,
        p_qtyta_puns      => v_qtyta_puns,
        p_qtybeh          => v_qtybeh,
        p_qtycmp          => v_qtycmp,
        p_qtykpi          => v_qtykpi,
        p_qtytot          => v_qtytot,
        p_total_numitem   => p_total_numitem,
        obj_numtime       => obj_numtime,
        obj_numtime_label => obj_numtime_label
      );
      obj_data.put('obj_numtime',obj_numtime);      -- object beh or cmp

      if v_flg_chk_disable and r_tappfm.flgappr is null then -- disable record then display blank score
        v_qtyscornet := null;
        v_qtyta_puns := null;
        v_qtybeh     := null;
        v_qtycmp     := null;
        v_qtykpi     := null;
        v_qtytot     := null;
      end if;
      obj_data.put('qtyscornet',v_qtyscornet);      -- 4.qtyscornet
      obj_data.put('qtyta',to_char(v_qtyta_puns));  -- 5.qtyta
      obj_data.put('qtybeh',to_char(v_qtybeh));     -- 6.qtybeh
      obj_data.put('qtycmp',to_char(v_qtycmp));     -- 7.qtycmp
      obj_data.put('qtykpi',to_char(v_qtykpi));     -- 8.qtykpi
      obj_data.put('qtyscore',to_char(v_qtytot));   -- 9.qtyscore

      -- 10.flgapman
      obj_data.put('flgapman',r_tappfm.flgapman);
      obj_data.put('desc_flgapman',get_tlistval_name('FLGDISP',r_tappfm.flgapman,global_v_lang));

      -- 11.flgappr
      obj_data.put('flgappr',r_tappfm.flgappr);

      -- 12.commtapman
      if b_index_flgtypap = 'B' then
        v_remark := r_tappfm.remarkbeh;
      elsif b_index_flgtypap = 'C' then
        v_remark := r_tappfm.remarkcmp;
      else
        v_remark := r_tappfm.commtapman;
      end if;
      obj_data.put('commtapman',v_remark);

      -- other field
      obj_data.put('codaplvl',r_tappfm.codaplvl);
      obj_data.put('codcomp',r_tappfm.codcomp);
      obj_data.put('codpos',r_tappfm.codpos);
      obj_data.put('iconCodtency','<i class="fa fa-info-circle"></i>');
      obj_data.put('codskill','');
      obj_data.put('dteyreap',to_char(r_tappfm.dteyreap));
      obj_data.put('numtime',to_char(r_tappfm.numtime));
      obj_data.put('numseq',to_char(r_tappfm.numseq));

    end if; -- if v_weight > 0 then
  end;

  procedure gen_index(json_str_output out clob) as
    obj_result          json_object_t;
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_codform           tappfm.codform%type;
    v_max_numitem       number := 0;
    v_total_numitem     number := 0;
    obj_numtime_label   json_object_t;

    cursor c_tappfm is
      select *
        from tappfm
       where dteyreap  = b_index_dteyreap
         and numtime   = b_index_numtime
         and codaplvl  = b_index_codaplvl
         and ((codapman is not null and codapman = b_index_codapman)
          or (codapman is null and exists (
                select codempid
                  from temploy1
                 where codcomp = tappfm.codcompap
                   and codpos  = tappfm.codposap
                   and staemp in ('1','3')
                   and codempid = b_index_codapman
                union
                select codempid
                  from tsecpos
                 where codcomp = tappfm.codcompap
                   and codpos = tappfm.codposap
                   and dteeffec <= sysdate
                   and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))
                   and codempid = b_index_codapman
          ))
         and codcomp like b_index_codcomp||'%'
         and codpos = nvl(b_index_codpos,codpos)
      order by codempid,numseq;
  begin
    obj_row := json_object_t();

    v_codform := get_codform(b_index_codcomp,b_index_codaplvl,v_global_dteapend);
    for r_tappfm in c_tappfm loop
      r_tappfm.codform := v_codform;
      gen_index_record(
          r_tappfm          => r_tappfm,
          p_total_numitem   => v_total_numitem,
          obj_data          => obj_data,
          obj_numtime_label => obj_numtime_label
      );
      v_max_numitem := greatest(nvl(v_max_numitem,0),v_total_numitem);
      if obj_data.get_size > 0 then
        v_rcnt := v_rcnt + 1;
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt <= 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tappfm');
    end if;

    if param_msg_error is null then
      obj_result := json_object_t();
      obj_result.put('coderror','200');
      obj_result.put('dteapstr',to_char(v_global_dteapstr,'dd/mm/yyyy'));
      obj_result.put('dteapend',to_char(v_global_dteapend,'dd/mm/yyyy'));
      obj_result.put('codform',v_codform);
      obj_result.put('desc_codform',get_tintview_name(v_codform,global_v_lang));
      obj_result.put('total_numitem',to_char(v_max_numitem));
      obj_result.put('numitem',obj_numtime_label);
      obj_result.put('table',obj_row);
      json_str_output := obj_result.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_behavior_form_popup(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_behavior_form_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_behavior_form_popup(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_numgrup       tintvews.numgrup%type;
    v_rcnt          number := 0;

    cursor c_tintvews is
      select numgrup,
             decode(global_v_lang, '101', desgrupe,
                                   '102', desgrupt,
                                   '103', desgrup3,
                                   '104', desgrup4,
                                   '105', desgrup5,
                                   '') desgrup
        from tintvews
       where codform = v_global_codform
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
       where codform = v_global_codform
         and numgrup = v_numgrup
    order by numitem;
  begin
    obj_row := json_object_t();
    for r_tintvews in c_tintvews loop
      v_numgrup := r_tintvews.numgrup;
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('numitem',get_label_name('HRAP34E2',global_v_lang,'70')||' '||r_tintvews.numgrup);
      obj_data.put('desitem',r_tintvews.desgrup);
      obj_data.put('definit','');
      obj_data.put('qtywgt','');
      obj_row.put(to_char(v_rcnt - 1), obj_data);

      for r_tintvewd in c_tintvewd loop
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numitem',r_tintvewd.numitem);
        obj_data.put('desitem',r_tintvewd.desitem);
        obj_data.put('definit',r_tintvewd.definit);
        obj_data.put('qtywgt',r_tintvewd.qtywgt);
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end loop;
    end loop;

    if param_msg_error is null then
      obj_result := json_object_t();
      obj_result.put('coderror','200');
      obj_result.put('codform',v_global_codform);
      obj_result.put('desform',get_tintview_name(v_global_codform,global_v_lang));
      obj_result.put('table',obj_row);
      json_str_output := obj_result.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_competency_popup(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_competency_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_competency_popup(json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_rcnt                number := 0;
    v_numseq              number := 0;
    v_numgrup             number := 0;
    v_codtency            tjobposskil.codtency%type;
    v_wgt                 varchar2(1000 char);
    v_taplvld_codcomp     taplvld.codcomp%type;
    v_taplvld_dteeffec    taplvld.dteeffec%type;

    cursor c_tjobposskil is
      select a.codtency,b.codskill,b.grade,a.qtywgt
        from taplvld a, tjobposskil b
       where a.codcomp     = v_taplvld_codcomp
         and a.codaplvl    = b_index_codaplvl
         and a.dteeffec    = v_taplvld_dteeffec
         and a.codtency    = b.codtency
         and b.codcomp     = b_index_codcomp
         and b.codpos      = b_index_codpos
      order by a.codtency,b.codskill;

  begin
    obj_row := json_object_t();
    get_taplvld_where(b_index_codcomp,b_index_codaplvl,v_taplvld_codcomp,v_taplvld_dteeffec);
    for r_tjobposskil in c_tjobposskil loop
      if nvl(v_codtency,'$#@') <> r_tjobposskil.codtency then
        v_codtency := r_tjobposskil.codtency;
        v_wgt := nvl(to_char(r_tjobposskil.qtywgt),'-');

        v_numgrup := v_numgrup + 1;
        v_rcnt := v_rcnt + 1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numseq',get_label_name('HRAP34E2',global_v_lang,'70')||' '||v_numgrup);
        obj_data.put('codskill',v_codtency);
        obj_data.put('desc_codskill',get_tcomptnc_name(v_codtency, global_v_lang));
        obj_data.put('grade','Weight: '||v_wgt);
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;

      v_numseq := v_numseq + 1;
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('numseq',to_char(v_numseq));
      obj_data.put('codskill',r_tjobposskil.codskill);
      obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r_tjobposskil.codskill, global_v_lang));
      obj_data.put('grade',r_tjobposskil.grade);
      obj_row.put(to_char(v_rcnt - 1), obj_data);

    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_assessors_popup(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_assessors_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_assessors_popup(json_str_output out clob) as
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_numtime       json_object_t;
    obj_numtime_label json_object_t;
    obj_result        json_object_t;
    v_rcnt            number := 0;
    v_codskill        tjobposskil.codskill%type;
    v_numitem         number := 0;
    v_total_numitem   number := 0;

    -- parameter for cal_all_score
    v_qtyta_puns      number;
    v_qtyta           number;
    v_qtypuns         number;
    v_qtybeh          number;
    v_qtycmp          number;
    v_qtykpi          number;
    v_qtyscornet      number := 0;
    v_qtytot          number;
    obj_beh           json_object_t := json_object_t();
    obj_cmp           json_object_t := json_object_t();

    cursor c_tappfm is
      select numseq,codapman,codcompap,codposap,flgapman,dteapman,flgappr,
             qtybeh,qtycmp,qtykpi,
             codempid,dteyreap,numtime,codcomp,codpos,codform,codaplvl
        from tappfm
       where codempid = v_global_codempid_query
         and dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and flgappr  = 'C'
         and (
              (v_global_flgtypap = 'C' and v_global_flgapman = '3')                                    -- 360, last
           or (v_global_flgtypap = 'C' and v_global_flgapman <> '3' and codapman = global_v_codempid)  -- 360, not last
           or (v_global_flgtypap = 'T' and v_global_flgapman = '1'  and codapman = global_v_codempid)  -- Bottom Up, employee
           or (v_global_flgtypap = 'T' and v_global_flgapman = '2'  and numseq <= v_global_numseq)     -- Bottom Up, head
           or (v_global_flgtypap = 'T' and v_global_flgapman = '3')                                    -- Bottom Up, last
           or (v_global_flgtypap = 'T' and v_global_flgapman = '4'  and codapman = global_v_codempid)  -- Bottom Up, other
         )
      order by numseq;
  begin
    obj_row := json_object_t();
    for r_tappfm in c_tappfm loop
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',r_tappfm.codapman);
      obj_data.put('numseq',to_char(r_tappfm.numseq));
      obj_data.put('codapman',r_tappfm.codapman);
      obj_data.put('desc_codapman',get_temploy_name(r_tappfm.codapman,global_v_lang));
      obj_data.put('codcompap',r_tappfm.codcompap);
      obj_data.put('desc_codcompap',get_tcenter_name(r_tappfm.codcompap,global_v_lang));
      obj_data.put('codposap',r_tappfm.codposap);
      obj_data.put('desc_codposap',get_tpostn_name(r_tappfm.codposap,global_v_lang));
      obj_data.put('flgapman',r_tappfm.flgapman);
      obj_data.put('desc_flgapman',get_tlistval_name('FLGDISP',r_tappfm.flgapman,global_v_lang));
      obj_data.put('dteapman',to_char(r_tappfm.dteapman,'dd/mm/yyyy'));
      obj_data.put('flgappr',r_tappfm.flgappr);
      obj_data.put('desc_flgappr',get_tlistval_name('APSTATUS',r_tappfm.flgappr,global_v_lang));

      -- get all score
      cal_all_score(
        p_codempid        => r_tappfm.codempid,
        p_dteyreap        => r_tappfm.dteyreap,
        p_numtime         => r_tappfm.numtime,
        p_numseq          => r_tappfm.numseq,
        p_codform         => r_tappfm.codform,
        p_codcomp         => r_tappfm.codcomp,
        p_codpos          => r_tappfm.codpos,
        p_codaplvl        => r_tappfm.codaplvl,
        obj_beh           => obj_beh,
        obj_cmp           => obj_cmp,
        p_qtyscornet      => v_qtyscornet,
        p_qtyta           => v_qtyta,
        p_qtypuns         => v_qtypuns,
        p_qtyta_puns      => v_qtyta_puns,
        p_qtybeh          => v_qtybeh,
        p_qtycmp          => v_qtycmp,
        p_qtykpi          => v_qtykpi,
        p_qtytot          => v_qtytot,
        p_total_numitem   => v_total_numitem,
        obj_numtime       => obj_numtime,
        obj_numtime_label => obj_numtime_label
      );
      obj_data.put('obj_numtime',obj_numtime);      -- object beh or cmp

      obj_data.put('qtyscornet',v_qtyscornet);
      obj_data.put('qtyta',v_qtyta_puns);
      obj_data.put('qtybeh',v_qtybeh);
      obj_data.put('qtycmp',v_qtycmp);
      obj_data.put('qtykpi',v_qtykpi);
      obj_data.put('qtyscore',v_qtytot);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    if v_global_flgtypap = 'C' and v_global_flgapman <> '3' and v_rcnt = 0 then ----
        param_msg_error := get_error_msg_php('AP0038',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    obj_numtime_label := json_object_t();
    for i in 1..v_total_numitem loop
      obj_numtime_label.put('numitem'||i,to_char(i));
    end loop;
    if param_msg_error is null then
      obj_result := json_object_t();
      obj_result.put('coderror','200');
      obj_result.put('total_numitem',to_char(v_total_numitem));
      obj_result.put('numitem',obj_numtime_label);
      obj_result.put('table',obj_row);
      json_str_output := obj_result.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure post_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_input);
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

  procedure update_total_score(p_codempid_query varchar2,p_dteyreap varchar2,p_numtime varchar2,p_numseq varchar2,p_codaplvl varchar2,p_codcomp varchar2,p_flgapman varchar2) is
    v_taplvl_codcomp              taplvl.codcomp%type;
    v_taplvl_dteeffec             taplvl.dteeffec%type;
    t_taplvl                      taplvl%rowtype;
    t_tappemp                     tappemp%rowtype;
    v_qtycmp_sum                  number;

    v_qtytot1                     tappemp.qtytot%type;
    v_qtytot2                     tappemp.qtytot2%type;
    v_qtytot3                     tappemp.qtytot3%type;
  begin

    -- get total score with weight from taplvl and taplvld (hrrp14e)
    get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);
    begin
      select *
        into t_taplvl
        from taplvl
       where codcomp  = v_taplvl_codcomp
         and codaplvl = p_codaplvl
         and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
      t_taplvl := null;
    end;

    begin
      select *
        into t_tappemp
        from tappemp
       where codempid = p_codempid_query
         and dteyreap = p_dteyreap
         and numtime  = p_numtime;
    exception when no_data_found then
      t_tappemp := null;
    end;

    -- sum competency
    begin
      select sum(qtyscorn * pctwgt / 100)
        into v_qtycmp_sum
        from tappcmpc a, tjobposskil b
       where a.codempid = p_codempid_query
         and a.dteyreap = p_dteyreap
         and a.numtime  = p_numtime
         and a.numseq   = p_numseq;
    exception when others then
      v_qtycmp_sum := 0;
    end;

    if p_flgapman in ('1','4')  then
      v_qtytot1  := ((nvl(t_tappemp.qtybeh,0) * t_taplvl.pctbeh) /100) +
                    (nvl(v_qtycmp_sum,0)) +
                    ((nvl(t_tappemp.qtykpic,0) * t_taplvl.pctkpirt) /100) +
                    ((nvl(t_tappemp.qtykpid,0) * t_taplvl.pctkpicp) /100) +
                    ((nvl(t_tappemp.qtykpie,0) * t_taplvl.pctkpiem) /100) +
                    ((nvl(t_tappemp.qtyta,0) * t_taplvl.pctta) /100) +
                    ((nvl(t_tappemp.qtypuns,0) * t_taplvl.pctpunsh) /100);

      begin
        update tappemp
           set qtytot   = v_qtytot1,
               coduser  = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime  = p_numtime;
      exception when others then null;
      end;
    elsif p_flgapman = '2'  then
      v_qtytot2  := ((nvl(t_tappemp.qtybeh2,0) * t_taplvl.pctbeh) /100) +
                    (nvl(v_qtycmp_sum,0)) +
                    ((nvl(t_tappemp.qtykpic,0) * t_taplvl.pctkpirt) /100) +
                    ((nvl(t_tappemp.qtykpid,0) * t_taplvl.pctkpicp) /100) +
                    ((nvl(t_tappemp.qtykpie2,0) * t_taplvl.pctkpiem) /100) +
                    ((nvl(t_tappemp.qtyta,0) * t_taplvl.pctta) /100) +
                    ((nvl(t_tappemp.qtypuns,0) * t_taplvl.pctpunsh) /100);

      begin
        update tappemp
           set qtytot2  = v_qtytot2,
               coduser  = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime  = p_numtime;
      exception when others then null;
      end;
    elsif p_flgapman = '3'  then
      v_qtytot3  := ((nvl(t_tappemp.qtybeh3,0) * t_taplvl.pctbeh) /100) +
                    (nvl(v_qtycmp_sum,0)) +
                    ((nvl(t_tappemp.qtykpic,0) * t_taplvl.pctkpirt) /100) +
                    ((nvl(t_tappemp.qtykpid,0) * t_taplvl.pctkpicp) /100) +
                    ((nvl(t_tappemp.qtykpie3,0) * t_taplvl.pctkpiem) /100) +
                    ((nvl(t_tappemp.qtyta,0) * t_taplvl.pctta) /100) +
                    ((nvl(t_tappemp.qtypuns,0) * t_taplvl.pctpunsh) /100);

      begin
        update tappemp
           set qtytot3  = v_qtytot3,
               coduser  = global_v_coduser
         where codempid = p_codempid_query
           and dteyreap = p_dteyreap
           and numtime  = p_numtime;
      exception when others then null;
      end;
    end if;
  end;

  procedure sendmail_to_next_approve(p_codempid_query varchar2,p_dteyreap varchar2,p_numtime varchar2,p_numseq varchar2) is
    json_input      json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_rowid         rowid;

    v_msg_to        clob;
	  v_templete_to   clob;

    v_codempid      tappfm.codapman%type;
    v_error			    terrorm.errorno%type;
    v_codapman      tappfm.codapman%type;
    v_codposap      tappfm.codposap%type;
    v_codcompap     tappfm.codcompap%type;

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
    begin
      select rowid, codapman, codposap, codcompap
        into v_rowid, v_codapman, v_codposap, v_codcompap
        from tappfm
       where codempid = p_codempid_query
         and dteyreap = p_dteyreap
         and numtime  = p_numtime
         and numseq   = p_numseq + 1;
    exception when no_data_found then null;
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

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  function get_competency_score(p_codcomp varchar2,p_codpos varchar2,p_codtency varchar2,p_codskill varchar2,p_grade number) return number as
    v_score           tjobscore.score%type;
    v_expect_grade    tjobposskil.grade%type;
    v_expect_score    tjobposskil.score%type;
    v_fscore          tjobposskil.fscore%type;
  begin
    begin
      select score
        into v_score
        from tjobscore
       where codpos   = p_codpos
         and codcomp  = p_codcomp
         and codtency = p_codtency
         and codskill = p_codskill
         and grade    = p_grade;
    exception when no_data_found then
      v_score := null;
    end;

    begin
      select grade,score,fscore
        into v_expect_grade,v_expect_score,v_fscore
        from tjobposskil
       where codpos   = p_codpos
         and codcomp  = p_codcomp
         and codtency = p_codtency
         and codskill = p_codskill;
    exception when no_data_found then
      v_expect_grade := null;
      v_expect_score := null;
      v_fscore := null;
    end;

    if p_grade >= v_expect_grade then
      v_score := v_expect_score;
    end if;
    return v_score;
  end;

  procedure save_detail(json_str_input in clob) as
    param_json_row        json_object_t;
    param_json            json_object_t;
    v_taplvld_codcomp     taplvld.codcomp%type;
    v_taplvld_dteeffec    taplvld.dteeffec%type;
    v_total_numtime       number;
    v_flg_disable         boolean;
    v_codempid            tappfm.codempid%type;
    v_numseq              tappfm.numseq%type;
    v_codform             tappemp.codform%type;
    v_qtyscornet          number;
    v_qtyta               number;
    v_flgapman            tappfm.flgapman%type;
    v_flgappr             tappfm.flgappr%type;
    v_commtapman          tappfm.remarkbeh%type;
    v_codaplvl            tappfm.codaplvl%type;
    v_codcomp             tappfm.codcomp%type;
    v_codpos              tappfm.codpos%type;

    v_flgNumitem		      boolean;
    v_qtywgt			        number;
    v_qtywgt_group        number;
    v_numitem			        varchar2(100 char);
    v_qtyscorn			      number;
    v_numgrup			        tintvewd.numgrup%type;
    v_numitem_grup	      tintvewd.numitem%type;
    v_codtency			      tjobposskil.codtency%type;
    v_codskill			      tjobposskil.codskill%type;
    v_runno               number;
    v_group_fscore        number;
    v_group_score         number;
    v_numgrup_f		        tintvewd.numgrup%type;
    v_numitem_f		        tintvewd.numitem%type;
    v_codtency_f		      tjobposskil.codtency%type;
    v_codskill_f		      tjobposskil.codskill%type;

    obj_data_input_worktime       json_object_t;
    obj_data_output_worktime      json_object_t;
    json_str_input_worktime       clob;
    json_str_output_worktime      clob;
    obj_score_detail              json_object_t;
    obj_leavegroup                json_object_t;
    obj_leavegroup_data           json_object_t;
    v_tappempta_qtyleav           tappempta.qtyleav%type;
    v_tappempta_qtyscor           tappempta.qtyscor%type;
    obj_work                      json_object_t;
    obj_work_data                 json_object_t;
    v_tappempmt_codpunsh          tappempmt.codpunsh%type;
    v_tappempmt_qtypunsh          tappempmt.qtypunsh%type;
    v_tappempmt_qtyscor           tappempmt.qtyscor%type;

    v_qtybeh                      tappfm.qtybeh%type;
    v_qtybehf                     tappfm.qtybehf%type;
    v_qtybeh1                     tappemp.qtybeh%type;
    v_qtybeh2                     tappemp.qtybeh2%type;
    v_qtybeh3                     tappemp.qtybeh3%type;

    v_qtycmp                      tappfm.qtycmp%type;
    v_qtycmpf                     tappfm.qtycmpf%type;
    v_qtycmp1                     tappemp.qtycmp%type;
    v_qtycmp2                     tappemp.qtycmp2%type;
    v_qtycmp3                     tappemp.qtycmp3%type;

    v_qtykpi                      number;
    v_qtyscore                    number;

    v_remarkbeh                   tappfm.remarkbeh%type;
    v_remarkcmp                   tappfm.remarkcmp%type;

    v_numlvl                      tappemp.numlvl%type;
    v_jobgrade                    tappemp.jobgrade%type;
    v_qtypuns                     tappemp.qtypuns%type;
    v_flgsal                      tappemp.flgsal%type;
    v_flgbonus                    tappemp.flgbonus%type;
    v_pctdbon                     tappemp.pctdbon%type;
    v_pctdsal                     tappemp.pctdsal%type;
    v_scoreta                     tappempta.qtyscor%type;
    v_scorfta                     tattpreh.scorfta%type;
    v_scorepunsh                  tappempmt.qtyscor%type;
    v_scorfpunsh                  tattpreh.scorfpunsh%type;
    v_remark1                     tappemp.remark%type;
    v_remark2                     tappemp.remark2%type;
    v_remark3                     tappemp.remark3%type;

    v_qtyscor                     tappbehi.qtyscorn%type;

    cursor c_tintvews is
      select numgrup,qtyfscor
        from tintvews
       where codform = v_codform
      order by numgrup;

    cursor c_tintvewd is
      select numgrup,numitem,qtywgt
        from tintvewd
       where codform = v_codform
         and numgrup = v_numgrup_f
    order by numitem;

    cursor c_taplvld is
      select codtency,qtywgt
        from taplvld
       where codcomp  = v_taplvld_codcomp
         and codaplvl = v_codaplvl
         and dteeffec = v_taplvld_dteeffec
      order by codtency;

    cursor c_tjobposskil is
      select codskill,grade,score,fscore
        from tjobposskil
       where codpos   = v_codpos
         and codcomp  = v_codcomp
         and codtency = v_codtency_f
      order by codskill;

    cursor c_tappcmps is
     select codempid,dteyreap,numtime,codtency,codskill,gradexpct,grade,qtyscor,remark
       from tappcmps
      where codempid = v_codempid
        and dteyreap = b_index_dteyreap
        and numtime  = b_index_numtime
        and numseq   = v_numseq
        and grade    < gradexpct
      order by codtency,codskill;

  begin
    param_json      := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    for i in 0..param_json.get_size-1 loop -- each employee record
      v_remarkbeh := null;
      v_remarkcmp := null;
      v_qtybeh1   := null;
      v_qtybeh2   := null;
      v_qtybeh3   := null;
      v_qtycmp1   := null;
      v_qtycmp2   := null;
      v_qtycmp3   := null;

      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flg_disable   := nvl(hcm_util.get_boolean_t(param_json_row,'flgChkDisable'),true);
      v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_codform       := hcm_util.get_string_t(param_json_row,'codform');
      v_qtyscornet    := to_number(replace(hcm_util.get_string_t(param_json_row,'qtyscornet'),','));
      v_qtyta         := to_number(replace(hcm_util.get_string_t(param_json_row,'qtyta'),','));
      v_qtybeh        := to_number(replace(hcm_util.get_string_t(param_json_row,'qtybeh'),','));
      v_qtycmp        := to_number(replace(hcm_util.get_string_t(param_json_row,'qtycmp'),','));
      v_qtykpi        := to_number(replace(hcm_util.get_string_t(param_json_row,'qtykpi'),','));
      v_qtyscore      := to_number(replace(hcm_util.get_string_t(param_json_row,'qtyscore'),','));
      v_flgapman      := hcm_util.get_string_t(param_json_row,'flgapman');
      v_flgappr       := hcm_util.get_string_t(param_json_row,'flgappr');
      v_commtapman    := hcm_util.get_string_t(param_json_row,'commtapman');
      v_codaplvl      := hcm_util.get_string_t(param_json_row,'codaplvl');
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      v_codpos        := hcm_util.get_string_t(param_json_row,'codpos');

      begin
          select dteapstr,dteapend,flgtypap
            into v_global_dteapstr,v_global_dteapend,v_global_flgtypap
            from tstdisd
           where codcomp  = hcm_util.get_codcomp_level(b_index_codcomp,1)
             and codaplvl = v_codaplvl
             and dteyreap = b_index_dteyreap
             and numtime  = b_index_numtime
             and rownum = 1  ;
      exception when no_data_found then
          v_global_dteapstr := null;
          v_global_dteapend := null;
      end;


      -- check row disable
      if not v_flg_disable then

        -- save behavior
        if b_index_flgtypap = 'B' then

          -- delete before insert
          begin
            delete from tappbehi
            where codempid = v_codempid
              and dteyreap = b_index_dteyreap
              and numtime  = b_index_numtime
              and numseq   = v_numseq;
          exception when others then null;
          end;
          begin
            delete from tappbehg
            where codempid = v_codempid
              and dteyreap = b_index_dteyreap
              and numtime  = b_index_numtime
              and numseq   = v_numseq;
          exception when others then null;
          end;

          -- get full score
          begin
            select qtytscor
              into v_qtybehf
              from tintview
             where codform = v_codform;
          exception when no_data_found then
            v_qtybehf := null;
          end;

          v_runno := 0;
          v_remarkbeh := v_commtapman;
          for r_tintvews in c_tintvews loop -- loop group
            v_numgrup_f := r_tintvews.numgrup;
            v_group_fscore := 0;
            v_group_score  := 0;
            for r_tintvewd in c_tintvewd loop -- loop numitem
              v_runno := v_runno + 1;
              v_numitem_f     := r_tintvewd.numitem;
              v_flgNumitem    := hcm_util.get_boolean_t(param_json_row,'flgNumitem'||to_char(v_runno));
              v_numitem       := hcm_util.get_string_t(param_json_row,'numitem'||to_char(v_runno));
--              v_qtyscorn      := to_number(replace(hcm_util.get_string_t(param_json_row,'qtyscorn'||to_char(v_runno)),','));
              v_numgrup       := hcm_util.get_string_t(param_json_row,'numgrup'||to_char(v_runno));
              v_numitem_grup  := hcm_util.get_string_t(param_json_row,'numitem_grup'||to_char(v_runno));
              v_codtency      := hcm_util.get_string_t(param_json_row,'codtency'||to_char(v_runno));
              v_codskill      := hcm_util.get_string_t(param_json_row,'codskill'||to_char(v_runno));

              begin
                  select qtyscor
                    into v_qtyscor
                    from tintscor
                   where codform = v_codform
                     and grad    = v_numitem;
              exception when no_data_found then
                v_qtyscor := null;
              end;
              v_qtyscorn := v_qtyscor * nvl(r_tintvewd.qtywgt,0);



              if not (v_numgrup_f = v_numgrup and v_numitem_f = v_numitem_grup) then
                v_numitem := null;
                v_qtyscorn := null;
              end if;

              -- insert beh item score
              begin
                insert into tappbehi (codempid,dteyreap,numtime,numseq,numgrup,numitem,
                                      grdscor,qtyscorn,pctwgt,
                                      codcreate,coduser)
                     values (v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,v_numgrup_f,v_numitem_f,
                             v_numitem,v_qtyscorn,r_tintvewd.qtywgt,
                             global_v_coduser,global_v_coduser);
              exception when others then
                update tappbehi
                   set grdscor  = v_numitem,
                       qtyscorn = v_qtyscorn,
                       pctwgt   = r_tintvewd.qtywgt,
                       coduser  = global_v_coduser
                 where codempid = v_codempid
                   and dteyreap = b_index_dteyreap
                   and numtime  = b_index_numtime
                   and numseq   = v_numseq
                   and numgrup  = v_numgrup_f
                   and numitem  = v_numitem_f;
              end;
              v_group_score  := nvl(v_group_score,0) + nvl(v_qtyscorn,0); -- sum score for group
            end loop; -- end loop numitem
            v_group_fscore := r_tintvews.qtyfscor; -- full score for group

            -- insert beh group score
            begin
              insert into tappbehg (codempid,dteyreap,numtime,numseq,numgrup,
                                    qtyscor,qtyscorn,
                                    codcreate,coduser)
                   values (v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,v_numgrup_f,
                           v_group_score,v_group_score,
--                           v_group_score,v_group_fscore,
                           global_v_coduser,global_v_coduser);
            exception when others then
              update tappbehg
                 set qtyscor  = v_group_score,
                     qtyscorn = v_group_score,
--                     qtyscorn = v_group_fscore,
                     coduser  = global_v_coduser
               where codempid = v_codempid
                 and dteyreap = b_index_dteyreap
                 and numtime  = b_index_numtime
                 and numseq   = v_numseq
                 and numgrup  = v_numgrup_f;
            end;
          end loop; -- end loop group

        end if; -- if b_index_flgtypap = 'B'

        -- save competency
        if b_index_flgtypap = 'C' then

          -- delete before insert
          begin
            delete from tappcmps
            where codempid = v_codempid
              and dteyreap = b_index_dteyreap
              and numtime  = b_index_numtime
              and numseq   = v_numseq;
          exception when others then null;
          end;
          begin
            delete from tappcmpc
            where codempid = v_codempid
              and dteyreap = b_index_dteyreap
              and numtime  = b_index_numtime
              and numseq   = v_numseq;
          exception when others then null;
          end;

          get_taplvld_where(v_codcomp,v_codaplvl,v_taplvld_codcomp,v_taplvld_dteeffec);
          -- get full score
          begin
            select sum(fscore)
              into v_qtycmpf
              from tjobposskil
             where codcomp = v_codcomp
               and codpos  = v_codpos
               and codtency in (select codtency
                                  from taplvld
                                 where codcomp  = v_taplvld_codcomp
                                   and codaplvl = v_codaplvl
                                   and dteeffec = v_taplvld_dteeffec);
          exception when no_data_found then
            v_qtycmpf := null;
          end;

          v_runno := 0;
          v_remarkcmp := v_commtapman;
          for r_taplvld in c_taplvld loop -- loop codtency
            v_codtency_f := r_taplvld.codtency;
            v_group_fscore := 0;
            v_group_score  := 0;
            v_qtywgt_group := nvl(r_taplvld.qtywgt,0);

            for r_tjobposskil in c_tjobposskil loop -- loop codskill
              v_runno         := v_runno + 1;
              v_codskill_f    := r_tjobposskil.codskill;
              v_flgNumitem    := hcm_util.get_boolean_t(param_json_row,'flgNumitem'||to_char(v_runno));
              v_numitem       := hcm_util.get_string_t(param_json_row,'numitem'||to_char(v_runno));
              v_qtyscorn      := to_number(replace(hcm_util.get_string_t(param_json_row,'qtyscorn'||to_char(v_runno)),','));
              v_codtency      := hcm_util.get_string_t(param_json_row,'codtency'||to_char(v_runno));
              v_codskill      := hcm_util.get_string_t(param_json_row,'codskill'||to_char(v_runno));
              v_qtyscorn      := get_competency_score(v_codcomp,v_codpos,v_codtency,v_codskill,v_qtyscorn); -- find expected score from grade
              if not (v_codtency_f = v_codtency and v_codskill_f = v_codskill) then
                v_numitem := null;
                v_qtyscorn := null;
              end if;

              -- insert cmp codskill score
              begin
                insert into tappcmps (codempid,dteyreap,numtime,numseq,codtency,codskill,
                                      gradexpct,grade,qtyscor,
                                      codcreate,coduser)
                     values (v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,v_codtency_f,v_codskill_f,
                             r_tjobposskil.grade,v_numitem,v_qtyscorn,
                             global_v_coduser,global_v_coduser);
              exception when others then
                update tappcmps
                   set gradexpct= r_tjobposskil.grade,
                       grade    = v_numitem,
                       qtyscor  = v_qtyscorn,
                       coduser  = global_v_coduser
                 where codempid = v_codempid
                   and dteyreap = b_index_dteyreap
                   and numtime  = b_index_numtime
                   and numseq   = v_numseq
                   and codtency = v_codtency_f
                   and codskill = v_codskill_f;
              end;
              v_group_score := nvl(v_group_score,0) + nvl(v_qtyscorn,0);
              v_group_fscore := v_group_fscore + nvl(r_tjobposskil.fscore,0); -- full score for group
            end loop; -- end loop codskill

            -- insert cmp codtency score
            begin
              insert into tappcmpc (codempid,dteyreap,numtime,numseq,codtency,
                                    qtyscor,qtyscorn,pctwgt,
                                    codcreate,coduser)
                   values (v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,v_codtency_f,
                           v_group_score,v_group_score*nvl(r_taplvld.qtywgt,0),r_taplvld.qtywgt,
--                           v_group_score,v_group_fscore,r_taplvld.qtywgt,
                           global_v_coduser,global_v_coduser);
            exception when others then
              update tappcmpc
                 set qtyscor  = v_group_score,
                     qtyscorn = v_group_score*nvl(r_taplvld.qtywgt,0),
--                     qtyscorn = v_group_fscore,
                     pctwgt   = r_taplvld.qtywgt,
                     coduser  = global_v_coduser
               where codempid = v_codempid
                 and dteyreap = b_index_dteyreap
                 and numtime  = b_index_numtime
                 and numseq   = v_numseq
                 and codtency = v_codtency_f;
            end;
          end loop; -- end loop codtency

          -- save for last approval to tappcmpf
          if v_flgapman = '3' and v_flgappr = 'C' then
            for r_tappcmps in c_tappcmps loop
              begin
                update tappcmpf
                   set gradexpct  = r_tappcmps.gradexpct,
                       grade      = r_tappcmps.grade,
                       qtyscor    = r_tappcmps.qtyscor,
                       remark     = r_tappcmps.remark
                 where codempid   = r_tappcmps.codempid
                   and dteyreap   = r_tappcmps.dteyreap
                   and numtime    = r_tappcmps.numtime
                   and codtency   = r_tappcmps.codtency
                   and codskill   = r_tappcmps.codskill;
              exception when dup_val_on_index then null;
              end;
            end loop;
          end if;

        end if; -- if b_index_flgtypap = 'C'

        -- call workingtime from hrap31e
        begin
          obj_data_input_worktime := json_object_t();
          obj_data_input_worktime.put('p_lang',global_v_lang);
          obj_data_input_worktime.put('p_dteyreap',b_index_dteyreap);
          obj_data_input_worktime.put('p_numtime',b_index_numtime);
          obj_data_input_worktime.put('p_numseq',v_numseq);
          obj_data_input_worktime.put('p_codempid_query',v_codempid);
          obj_data_input_worktime.put('p_codcompy',hcm_util.get_codcomp_level(v_codcomp,1));
          obj_data_input_worktime.put('p_codcomp',v_codcomp);
          obj_data_input_worktime.put('p_codaplvl',v_codaplvl);
          json_str_input_worktime := obj_data_input_worktime.to_clob;
          hrap31e.get_workingtime_detail(json_str_input_worktime,json_str_output_worktime);
          obj_data_output_worktime := json_object_t(json_str_output_worktime);

          -- save tappempta
          obj_leavegroup := hcm_util.get_json_t(obj_data_output_worktime,'leaveGroupTable');
          for index_leavegroup in 0..obj_leavegroup.get_size-1 loop
            obj_leavegroup_data := hcm_util.get_json_t(obj_leavegroup,to_char(index_leavegroup));
            v_tappempta_qtyleav := to_number(hcm_util.get_string_t(obj_leavegroup_data,'qtyleav'));
            v_tappempta_qtyscor := to_number(hcm_util.get_string_t(obj_leavegroup_data,'qtyscor'));

            begin
              insert into tappempta (codempid,dteyreap,numtime,
                                     codgrplv,qtyleav,qtyscor,
                                     codcreate,coduser)
                   values(v_codempid,b_index_dteyreap,b_index_numtime,
                          v_codaplvl,v_tappempta_qtyleav,v_tappempta_qtyscor,
                          global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
              update tappempta
                 set qtyleav  = v_tappempta_qtyleav,
                     qtyscor  = v_tappempta_qtyscor,
                     coduser  = global_v_coduser
               where codempid = v_codempid
                 and dteyreap = b_index_dteyreap
                 and numtime  = b_index_numtime
                 and codgrplv = v_codaplvl;
            end;
          end loop;

          -- save tappempmt
          obj_work := hcm_util.get_json_t(obj_data_output_worktime,'workTable');
          for index_work in 0..obj_work.get_size-1 loop
            obj_work_data := hcm_util.get_json_t(obj_work,to_char(index_work));
            v_tappempmt_codpunsh := hcm_util.get_string_t(obj_work_data,'codpunsh');
            v_tappempmt_qtypunsh := to_number(hcm_util.get_string_t(obj_work_data,'qtypunsh'));
            v_tappempmt_qtyscor  := to_number(hcm_util.get_string_t(obj_work_data,'qtyscor'));

            begin
              insert into tappempmt (codempid,dteyreap,numtime,
                                     codpunsh,qtypunsh,qtyscor,
                                     codcreate,coduser)
                   values(v_codempid,b_index_dteyreap,b_index_numtime,
                          v_tappempmt_codpunsh,v_tappempmt_qtypunsh,v_tappempmt_qtyscor,
                          global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
              update tappempmt
                 set qtypunsh = v_tappempmt_qtypunsh,
                     qtyscor  = v_tappempmt_qtyscor,
                     coduser  = global_v_coduser
               where codempid = v_codempid
                 and dteyreap = b_index_dteyreap
                 and numtime  = b_index_numtime
                 and codpunsh  = v_tappempmt_codpunsh;
            end;
          end loop;

          obj_score_detail := hcm_util.get_json_t(obj_data_output_worktime,'detail');
          v_flgbonus      := hcm_util.get_string_t(obj_score_detail,'flgbonus');
          v_flgsal        := hcm_util.get_string_t(obj_score_detail,'flgsal');
          v_pctdbon       := to_number(hcm_util.get_string_t(obj_score_detail,'pctdbon'));
          v_pctdsal       := to_number(hcm_util.get_string_t(obj_score_detail,'pctdsal'));
          v_scorepunsh    := to_number(hcm_util.get_string_t(obj_score_detail,'scorepunsh'));
          v_scoreta       := to_number(hcm_util.get_string_t(obj_score_detail,'scoreta'));
          v_scorfpunsh    := to_number(hcm_util.get_string_t(obj_score_detail,'scorfpunsh'));
          v_scorfta       := to_number(hcm_util.get_string_t(obj_score_detail,'scorfta'));
          v_qtyta         := (nvl(v_scoreta,0) / v_scorfta) * 100;
          v_qtypuns       := (nvl(v_scorepunsh,0) / v_scorfpunsh) * 100;
        exception when others then null;
          v_flgbonus      := null;
          v_flgsal        := null;
          v_pctdbon       := null;
          v_pctdsal       := null;
          v_scorepunsh    := null;
          v_scoreta       := null;
          v_scorfpunsh    := null;
          v_scorfta       := null;
          v_qtyta         := null;
          v_qtypuns       := null;
          param_msg_error := sqlerrm;
        end;

        begin
          select numlvl,jobgrade
            into v_numlvl,v_jobgrade
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_numlvl := null;
          v_jobgrade := null;
        end;

        -- save tappfm (for each approve-step)
        begin
          insert into tappfm (codempid,dteyreap,numtime,numseq,
                              jobgrade,codapman,dteapman,dteapstr,dteapend,
                              flgappr,flgapman,flgtypap,codform,
                              qtybehf,qtybeh,remarkbeh,
                              qtycmpf,qtycmp,remarkcmp,
                              codcreate,coduser)
              values (v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,
                      v_jobgrade,global_v_codempid,b_index_dteapman,v_global_dteapstr,v_global_dteapend,
                      v_flgappr,v_flgapman,v_global_flgtypap,v_codform,
                      v_qtybehf,v_qtybeh,v_remarkbeh,
                      v_qtycmpf,v_qtycmp,v_remarkcmp,
                      global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tappfm
             set jobgrade  = v_jobgrade,
                 codapman  = global_v_codempid,
                 dteapman  = b_index_dteapman,
                 dteapstr  = v_global_dteapstr,
                 dteapend  = v_global_dteapend,
                 flgappr   = v_flgappr,
                 flgapman  = v_flgapman,
                 flgtypap  = v_global_flgtypap,
                 codform   = v_codform,
                 qtybehf   = nvl(v_qtybehf,qtybehf), -- not update when select competency
                 qtybeh    = v_qtybeh,
                 remarkbeh = nvl(v_remarkbeh,remarkbeh),
                 qtycmpf   = nvl(v_qtycmpf,qtycmpf), -- not update when select behavior
                 qtycmp    = v_qtycmp,
                 remarkcmp = nvl(v_remarkcmp,remarkcmp),
                 coduser   = global_v_coduser
           where codempid  = v_codempid
             and dteyreap  = b_index_dteyreap
             and numtime   = b_index_numtime
             and numseq    = v_numseq;
        when others then
          null; -- ora-01400 insert numseq null -> case add employee
        end;

        -- Behavior weight score to 100%
        if b_index_flgtypap = 'B' then
          v_qtybeh := v_qtybeh * 100 / v_qtybehf;
          if v_flgapman in ('1','4') then
            v_qtybeh1 := v_qtybeh;
          elsif v_flgapman = '2' then
            v_qtybeh2 := v_qtybeh;
          elsif v_flgapman = '3' then
            v_qtybeh3 := v_qtybeh;
          end if;
        end if;

        -- Competency
        if b_index_flgtypap = 'C' then
          v_qtycmp := (v_qtycmp / v_qtycmpf) * 100;
          if v_flgapman in ('1','4') then
            v_qtycmp1 := v_qtycmp;
          elsif v_flgapman = '2' then
            v_qtycmp2 := v_qtycmp;
          elsif v_flgapman = '3' then
            v_qtycmp3 := v_qtycmp;
          end if;
        end if;

        -- 360 and not last approve => not save score
        if v_global_flgtypap = 'C' and v_flgapman <> '3' then
          v_qtybeh1 := null;
          v_qtybeh2 := null;
          v_qtybeh3 := null;
          v_qtycmp1 := null;
          v_qtycmp2 := null;
          v_qtycmp3 := null;
        end if;
        if v_flgapman <> '3' then
          v_flgappr := 'P';
        end if;

        -- save tappemp
        begin
          insert into tappemp (codempid,dteyreap,numtime,
                               codcomp,codpos,numlvl,codaplvl,jobgrade,
                               codform,flgappr,qtybeh,qtybeh2,qtybeh3,
                               qtycmp,qtycmp2,qtycmp3,
                               qtykpie,qtykpie2,qtykpie3,qtykpid,qtykpic,
                               qtyta,qtypuns,flgsal,flgbonus,
                               pctdbon,pctdsal,
                               grdappr,grdadj,codadj,dteadj,grdap,qtyadjtot,
                               remark,remark2,remark3,
                               qtytotnet,commtimpro,flgconfemp,dteconfemp,
                               flgconfhd,dteconfhd,flgconflhd,dteconflhd,
                               codcreate,coduser)
               values (v_codempid,b_index_dteyreap,b_index_numtime,
                       v_codcomp,v_codpos,v_numlvl,v_codaplvl,v_jobgrade,
                       v_codform,v_flgappr,v_qtybeh1,v_qtybeh2,v_qtybeh3,
                       v_qtycmp1,v_qtycmp2,v_qtycmp3,
                       null,null,null,null,null,
                       v_qtyta,v_qtypuns,v_flgsal,v_flgbonus,
                       v_pctdbon,v_pctdsal,
                       null,null,null,null,null,null,
                       v_remark1,v_remark2,v_remark3,
                       null,null,null,null,
                       null,null,null,null,
                       global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tappemp
             set codcomp     = v_codcomp,
                 codpos      = v_codpos,
                 numlvl      = v_numlvl,
                 codaplvl    = v_codaplvl,
                 jobgrade    = v_jobgrade,
                 codform     = v_codform,
                 flgappr     = nvl(v_flgappr,flgappr),
                 qtybeh      = nvl(v_qtybeh1,qtybeh),
                 qtybeh2     = nvl(v_qtybeh2,qtybeh2),
                 qtybeh3     = nvl(v_qtybeh3,qtybeh3),
                 qtycmp      = nvl(v_qtycmp1,qtycmp),
                 qtycmp2     = nvl(v_qtycmp2,qtycmp2),
                 qtycmp3     = nvl(v_qtycmp3,qtycmp3),
                 qtyta       = v_qtyta,
                 qtypuns     = v_qtypuns,
                 flgsal      = v_flgsal,
                 flgbonus    = v_flgbonus,
                 pctdbon     = v_pctdbon,
                 pctdsal     = v_pctdsal,
                 remark      = v_remark1,
                 remark2     = v_remark2,
                 remark3     = v_remark3,
                 coduser     = global_v_coduser
           where codempid    = v_codempid
             and dteyreap    = b_index_dteyreap
             and numtime     = b_index_numtime;
        end;

        -- update total score
        update_total_score(v_codempid,b_index_dteyreap,b_index_numtime,v_numseq,v_codaplvl,v_codcomp,v_flgapman);

        -- send mail to next approval
        if v_flgappr = 'C' and v_global_flgtypap = 'T' and v_flgapman <> '3' then
          sendmail_to_next_approve(v_codempid,b_index_dteyreap,b_index_numtime,v_numseq);
        end if;

      end if;  -- end check row disable

    end loop;
    commit;
  end save_detail;
  --
  procedure check_employee_data is
    v_codempid  temploy1.codempid%type;
  begin
    begin
      select codempid
        into v_codempid
        from tappfm
       where codempid = v_global_codempid_query
         and dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
         and rownum <= 1;
      param_msg_error := get_error_msg_php('HR1520',global_v_lang);
      return;
    exception when no_data_found then null;
    end;
  end;
  --
  procedure get_employee_data(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_employee_data;
    if param_msg_error is null then
      gen_employee_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_employee_data(json_str_output out clob) as
    obj_data            json_object_t;
    r_tappfm            tappfm%rowtype;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_total_numitem     number := 0;
    obj_numtime_label   json_object_t;
    v_codaplvl          tstdisd.codaplvl%type;

  begin
    begin
      select codcomp,codpos
        into v_codcomp,v_codpos
        from temploy1
       where codempid = v_global_codempid_query;
    exception when no_data_found then
      v_codcomp := null;
      v_codpos  := null;
    end;

    begin
--Redmine #5552
      v_codaplvl := get_codaplvl(b_index_dteyreap, b_index_numtime, v_global_codempid_query);
--Redmine #5552
      select dteapstr,dteapend,flgtypap
        into v_global_dteapstr,v_global_dteapend,v_global_flgtypap
        from tstdisd
       where codcomp  = hcm_util.get_codcomp_level(v_codcomp,1)
         and codaplvl = b_index_codaplvl
         and dteyreap = b_index_dteyreap
         and numtime  = b_index_numtime
--Redmine #5552
         and codaplvl = nvl(v_codaplvl, codaplvl)
         and rownum = 1;
--Redmine #5552
    exception when no_data_found then
      v_global_dteapstr := null;
      v_global_dteapend := null;
    end;

    r_tappfm.codempid := v_global_codempid_query;
    r_tappfm.dteyreap := b_index_dteyreap;
    r_tappfm.numtime  := b_index_numtime;
    r_tappfm.numseq   := 1;
    r_tappfm.codaplvl := b_index_codaplvl;
    r_tappfm.codcomp  := v_codcomp;
    r_tappfm.codpos   := v_codpos;
    r_tappfm.flgapman := '3';
    r_tappfm.codform  := get_codform(v_codcomp,b_index_codaplvl,v_global_dteapend);

    gen_index_record(
        r_tappfm          => r_tappfm,
        p_total_numitem   => v_total_numitem,
        obj_data          => obj_data,
        obj_numtime_label => obj_numtime_label
    );

    obj_data.put('total_numitem',to_char(v_total_numitem));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_all_score(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_all_score(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_all_score(json_str_input in clob, json_str_output out clob) as
    json_obj            json_object_t;
    obj_data            json_object_t;
    v_flgtypap          tappfm.flgtypap%type;
    v_codempid          tappfm.codempid%type;
    v_dteyreap          tappfm.dteyreap%type;
    v_numtime           tappfm.numtime%type;
    v_numseq            tappfm.numseq%type;
    v_codform           tappfm.codform%type;
    v_codcomp           tappfm.codcomp%type;
    v_codpos            tappfm.codpos%type;
    v_codaplvl          tappfm.codaplvl%type;

    -- parameter for cal_all_score
    v_total_numitem     number := 0;
    v_qtyta_puns        number;
    v_qtyta             number;
    v_qtypuns           number;
    v_qtybeh            number;
    v_qtycmp            number;
    v_qtykpi            number;
    v_qtyscornet        number := 0;
    v_qtytot            number;
    obj_beh             json_object_t := json_object_t();
    obj_cmp             json_object_t := json_object_t();
    obj_numtime         json_object_t;
    obj_numtime_label   json_object_t;
  begin
    json_obj   := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    v_flgtypap := hcm_util.get_string_t(json_obj,'flgtypap');
    v_codempid := hcm_util.get_string_t(json_obj,'codempid');
    v_dteyreap := hcm_util.get_string_t(json_obj,'dteyreap');
    v_numtime  := hcm_util.get_string_t(json_obj,'numtime');
    v_numseq   := hcm_util.get_string_t(json_obj,'numseq');
    v_codform  := hcm_util.get_string_t(json_obj,'codform');
    v_codcomp  := hcm_util.get_string_t(json_obj,'codcomp');
    v_codpos   := hcm_util.get_string_t(json_obj,'codpos');
    v_codaplvl := hcm_util.get_string_t(json_obj,'codaplvl');
    v_total_numitem := to_number(hcm_util.get_string_t(json_obj,'totalNumitem'));

--Redmine #5552
      v_codaplvl := get_codaplvl(v_dteyreap, v_numtime, v_codempid);
--Redmine #5552

    begin
      select dteapstr,dteapend,flgtypap
        into v_global_dteapstr,v_global_dteapend,v_global_flgtypap
        from tstdisd
       where codcomp  = hcm_util.get_codcomp_level(v_codcomp,1)
         and codaplvl = v_codaplvl
         and dteyreap = v_dteyreap
         and numtime  = v_numtime
--Redmine #5552
         and codaplvl = nvl(v_codaplvl, codaplvl)
         and rownum = 1;
--Redmine #5552
    exception when no_data_found then
      v_global_dteapstr := null;
      v_global_dteapend := null;
    end;

    obj_beh := json_object_t();
    obj_cmp := json_object_t();
    for i in 1..v_total_numitem loop
      if v_flgtypap = 'B' then    -- beh
        obj_beh.put(to_char(i), hcm_util.get_string_t(json_obj,'numitem'||to_char(i)));
      elsif v_flgtypap = 'C' then -- cmp
        obj_cmp.put(to_char(i), hcm_util.get_string_t(json_obj,'numitem'||to_char(i)));
      end if;
    end loop;

    -- get all score
    b_index_flgtypap := v_flgtypap;
    cal_all_score(
      p_codempid        => v_codempid,
      p_dteyreap        => v_dteyreap,
      p_numtime         => v_numtime,
      p_numseq          => v_numseq,
      p_codform         => v_codform,
      p_codcomp         => v_codcomp,
      p_codpos          => v_codpos,
      p_codaplvl        => v_codaplvl,
      obj_beh           => obj_beh,
      obj_cmp           => obj_cmp,
      p_qtyscornet      => v_qtyscornet,
      p_qtyta           => v_qtyta,
      p_qtypuns         => v_qtypuns,
      p_qtyta_puns      => v_qtyta_puns,
      p_qtybeh          => v_qtybeh,
      p_qtycmp          => v_qtycmp,
      p_qtykpi          => v_qtykpi,
      p_qtytot          => v_qtytot,
      p_total_numitem   => v_total_numitem,
      obj_numtime       => obj_numtime,
      obj_numtime_label => obj_numtime_label
    );
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('qtyscornet',v_qtyscornet);
    obj_data.put('qtyscornet',v_qtyscornet);
    obj_data.put('qtyta',v_qtyta_puns);
    obj_data.put('qtybeh',v_qtybeh);
    obj_data.put('qtycmp',v_qtycmp);
    obj_data.put('qtykpi',v_qtykpi);
    obj_data.put('qtyscore',v_qtytot);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

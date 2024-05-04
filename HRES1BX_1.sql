--------------------------------------------------------
--  DDL for Package Body HRES1BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES1BX" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_dteyreap          := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
  end initial_value;

  procedure convert_month_to_year_month(in_month in number, out_year out number, out_month out number)as
  begin
    out_year := (in_month/12);
    out_year := FLOOR(out_year);
    out_month := in_month - (out_year *12) ;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_score         tcmptncy.grade%type;
    v_gapcom        number;
    v_idx           number := 0;
	cursor c_tappfm is
		select *
          from tappfm
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by numseq;
  begin

    select codpos, codcomp
      into v_codpos, v_codcomp
      from temploy1
     where codempid = global_v_codempid;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c_tappfm loop

        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();

        begin
            select codcomp, codpos
              into v_codcomp, v_codpos
              from temploy1
             where codempid = r1.codapman;
        exception when others then
            v_codcomp   := null;
            v_codpos    := null;
        end;

        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('image', get_emp_img (r1.codapman));
        obj_data.put('codapman', r1.codapman);
        obj_data.put('desc_codapman', get_temploy_name(r1.codapman,global_v_lang));
        if r1.FLGAPPR = 'C' and r1.flgapman = '3' then
            obj_data.put('info', '<i class="fa fa-info-circle"></i>');
            obj_data.put('flgDisabled',false);
        else
            obj_data.put('info', '<i class="fa fa-info-circle _text-grey"></i>');
            obj_data.put('flgDisabled',true);
        end if;

        if r1.codcompap is not null then
            obj_data.put('codcompap', r1.codcompap);
            obj_data.put('desc_codcompap', get_tcenter_name(r1.codcompap,global_v_lang));
        else
            obj_data.put('codcompap', v_codcomp);
            obj_data.put('desc_codcompap', get_tcenter_name(v_codcomp,global_v_lang));
        end if;
        if r1.codposap is not null then
            obj_data.put('codposap', r1.codposap);
            obj_data.put('desc_codposap', get_tpostn_name(r1.codposap,global_v_lang));
        else
            obj_data.put('codposap', v_codpos);
            obj_data.put('desc_codposap', get_tpostn_name(v_codpos,global_v_lang));
        end if;
        obj_data.put('flgapman', r1.flgapman);
        obj_data.put('desc_flgapman', get_tlistval_name('FLGDISP',  r1.flgapman ,global_v_lang));
        obj_data.put('dteapman', to_char(r1.dteapman,'dd/mm/yyyy'));
        obj_data.put('flgappr', r1.flgappr);
        obj_data.put('desc_flgappr', get_tlistval_name('FLAGAPPR', r1.flgappr, global_v_lang));
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_detail_header(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_all_emp           number := 0;
    v_array             number := 0;
    v_sum_per           number := 0;
    v_qtywork           number := 0;
    v_codapman          temploy1.codempid%type;
    v_codapman_a        temploy1.codempid%type;
    v_year              number:=0;
    v_month             number:=0;
    v_codcomp           tappemp.codcomp%type;

    cursor c1 is
      select dteapstr,dteapend
        from tstdisd
       where v_codcomp  like codcomp || '%'
         and dteyreap = (select max(dteyreap)
                           from tstdisd
                          where v_codcomp  like codcomp || '%'
                            and dteyreap <= p_dteyreap
                            and numtime = p_numtime
--#5552
                            and exists(select codaplvl
                                         from tempaplvl
                                        where dteyreap = tstdisd.dteyreap
                                          and numseq  = tstdisd.numtime
                                          and codaplvl = tstdisd.codaplvl )
--#5552 
                        )
          and numtime = p_numtime;

      cursor c2 is
          select codcomp,codpos,flgsal,flgbonus,pctdbon,pctdsal
            from tappemp
           where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codempid  = global_v_codempid;

      cursor c3 is
          select codapman,codposap,codcompap
            from tappfm
           where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codempid  = global_v_codempid
             and flgapman = '2'
             and numseq = ( select max(numseq)
                              from tappfm
                             where dteyreap = p_dteyreap
                               and numtime = p_numtime
                               and codempid = global_v_codempid
                               and flgapman = '2');

      cursor c4 is
          select codapman,codposap,codcompap
            from tappfm
           where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codempid  = global_v_codempid
             and flgapman = '3'
             and numseq = ( select max(numseq)
                              from tappfm
                             where dteyreap = p_dteyreap
                               and numtime = p_numtime
                               and codempid = global_v_codempid
                               and flgapman = '3');

  begin
    obj_result  := json_object_t;
    obj_row     := json_object_t();

    begin
        select codcomp
          into v_codcomp
          from tappemp
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = global_v_codempid;
    exception when others then
        v_codcomp := null;
    end;

    begin
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        for r1 in c1 loop
          obj_data.put('dteapstr',to_char(r1.dteapstr,'dd/mm/yyyy'));
          obj_data.put('dteapend',to_char(r1.dteapend,'dd/mm/yyyy'));
         end loop;
         for r2 in c2 loop
          obj_data.put('codcomp',r2.codcomp);
          obj_data.put('codpos',r2.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r2.codpos,global_v_lang));
          obj_data.put('pctupsalbrkn',r2.pctdsal);
         end loop;
         for r3 in c3 loop
          v_codapman := r3.codapman;
          if v_codapman is null then
            begin
              select codempid
                into v_codapman
              from temploy1
              where codpos = r3.codposap
                and codcomp = r3.codcompap
                and rownum = 1;
            end;
          end if;
          obj_data.put('codsuprvisr',v_codapman);
         end loop;

         for r4 in c4 loop
          v_codapman := r4.codapman;
          if v_codapman is null then
            begin
              select codempid
                into v_codapman
              from temploy1
              where codpos = r4.codposap
                and codcomp = r4.codcompap
                and rownum = 1;
            end;
          end if;
          obj_data.put('codappr',v_codapman);
         end loop;

          begin
              select qtywork
                into v_qtywork
              from v_temploy
              where codempid = global_v_codempid;
          end;
          convert_month_to_year_month(v_qtywork,v_year,v_month);

        obj_data.put('agewrkyr',v_year);
        obj_data.put('agewrkmth',v_month);
    exception when others then
     null;
    end;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_detail_header (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_header(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;
    v_flggrade          varchar2(2 char);
    v_codform           tappemp.codform%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_pctbeh            taplvl.pctbeh%type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpiem          taplvl.pctkpiem%type;

    v_qtyta             tappemp.qtyta%type;
    v_qtybeh            tappemp.qtybeh%type;
    v_qtybeh2           tappemp.qtybeh2%type;
    v_qtybeh3           tappemp.qtybeh3%type;
    v_qtycmp            tappemp.qtycmp%type;
    v_qtycmp2           tappemp.qtycmp2%type;
    v_qtycmp3           tappemp.qtycmp3%type;
    v_qtykpie           tappemp.qtykpie%type;
    v_qtykpie2          tappemp.qtykpie2%type;
    v_qtykpie3          tappemp.qtykpie3%type;
    v_codcomp           tappemp.codcomp%type;

  begin
    begin
        select codform,(qtyta + qtypuns), qtybeh, qtybeh2, qtybeh3,
               qtycmp, qtycmp2, qtycmp3, qtykpie, qtykpie2, qtykpie3
          into v_codform,v_qtyta, v_qtybeh, v_qtybeh2, v_qtybeh3,
               v_qtycmp, v_qtycmp2, v_qtycmp3, v_qtykpie, v_qtykpie2, v_qtykpie3
          from tappemp
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = global_v_codempid;
    end;

    begin
        select pctta,pctpunsh,pctbeh,pctcmp,pctkpiem
          into v_pctta,v_pctpunsh,v_pctbeh,v_pctcmp,v_pctkpiem
          from taplvl
         where v_codcomp  like  codcomp || '%'
           and codform = v_codform
           and dteeffec = ( select max(dteeffec)
                              from taplvl
                             where v_codcomp  like codcomp || '%'
                               and codform = v_codform
                               and dteeffec <= (select dteapend
                                                  from tstdisd
                                                 where v_codcomp  like codcomp || '%'
                                                   and dteyreap = p_dteyreap
                                                   and numtime = p_numtime 
--#5552
                                                   and exists(select codaplvl
                                                              from tempaplvl
                                                             where dteyreap = p_dteyreap
                                                               and numseq  = p_numtime
                                                               and codaplvl = tstdisd.codaplvl
                                                               and codempid = nvl(global_v_codempid, codempid) )
--#5552 
                                                   ));
    end;

    obj_result  := json_object_t;
    obj_row     := json_object_t();
    begin
        if (v_pctta + v_pctpunsh) > 0 then
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('numseq',v_row + 1);
            obj_data.put('assecompnt',get_label_name('HRAP14E',global_v_lang,140) || '/' || get_label_name('HRAP14E',global_v_lang,150));
            obj_data.put('weight',(v_pctta + v_pctpunsh));
            obj_data.put('empother',v_pctta);
            obj_data.put('supervisor','');
            obj_data.put('approval','');
            obj_row.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end if;
        if v_pctbeh > 0 then
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('numseq',v_row + 1);
            obj_data.put('assecompnt',get_label_name('HRAP14E',global_v_lang,180));
            obj_data.put('weight',v_pctbeh);
            obj_data.put('empother',v_qtybeh);
            obj_data.put('supervisor',v_qtybeh2);
            obj_data.put('approval',v_qtybeh3);
            obj_row.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end if;
        if v_pctcmp > 0 then
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('numseq',v_row + 1);
            obj_data.put('assecompnt',get_label_name('HRAP34EP1',global_v_lang,130));
            obj_data.put('weight',v_pctcmp);
            obj_data.put('empother',v_qtycmp);
            obj_data.put('supervisor',v_qtycmp2);
            obj_data.put('approval',v_qtycmp3);
            obj_row.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end if;
        if v_pctkpiem > 0 then
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('numseq',v_row + 1);
            obj_data.put('assecompnt',get_label_name('HRAP34EP1',global_v_lang,320));
            obj_data.put('weight',v_pctkpiem);
            obj_data.put('empother',v_qtykpie);
            obj_data.put('supervisor',v_qtykpie2);
            obj_data.put('approval',v_qtykpie3);
            obj_row.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end if;

    exception when others then
        null;
    end;
    json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_table (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_table(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_meaasge(json_str_output out clob) is
    obj_data            json_object_t;
    cursor c1 is
        select remark,remark2,remark3,commtimpro
          from tappemp
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = global_v_codempid;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    for r1 in c1 loop
        obj_data.put('remark',r1.remark);
        obj_data.put('remark2',r1.remark2);
        obj_data.put('remark3',r1.remark3);
        obj_data.put('commtimpro',r1.commtimpro);
    end loop;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_detail_meaasge (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_meaasge(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_competency_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;

    cursor c1 is
        select codskill,codtency,grade,gradexpct
          from tappcmpf
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and grade < gradexpct
      order by codskill;
  begin
    obj_result  := json_object_t;
    obj_row     := json_object_t();
    begin
        for r1 in c1 loop
            v_count     := v_count +1;
            v_chksecu   := true;
            obj_data    := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codtency',r1.codtency);
            obj_data.put('codskill',r1.codskill);
            obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
            obj_data.put('gradexpct',r1.gradexpct);
            obj_data.put('grade',r1.grade);
            obj_row.put(to_char(v_row), obj_data);
            v_row       := v_row + 1;
        end loop;
    exception when others then
        null;
    end;
    json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_table (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index();
    if param_msg_error is null then
        gen_detail_competency_table(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_competency_course(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;

    cursor c1 is
        select codcours
          from tapptrnf
         where codempid  = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by codcours;
  begin
    obj_result := json_object_t;
    obj_row := json_object_t();
    begin
        for r1 in c1 loop
            v_count := v_count +1;
            v_chksecu := true;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcours',r1.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
            obj_row.put(to_char(v_row), obj_data);
            v_row := v_row + 1;
        end loop;
    exception when others then
        null;
    end;
    json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_course (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_competency_course(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_competency_develop(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;

    cursor c1 is
        select coddevp,desdevp
          from tappdevf
         where codempid  = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by coddevp;
  begin
    obj_result  := json_object_t;
    obj_row     := json_object_t();
    begin
        for r1 in c1 loop
            v_count     := v_count +1;
            obj_data    := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('coddevp',r1.coddevp);
            obj_data.put('desdevp',r1.desdevp);
            obj_row.put(to_char(v_row), obj_data);
            v_row       := v_row + 1;
        end loop;
    exception when others then
        null;
    end;
    json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_develop (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_competency_develop(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure gen_detail(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_result          json_object_t;


    obj_tappcmpf        json_object_t;
    obj_courseTable     json_object_t;
    obj_developTable    json_object_t;

    v_row               number := 0;
    v_all_emp           number := 0;
    v_array             number := 0;
    v_sum_per           number := 0;
    v_qtywork           number := 0;
    v_codapman          temploy1.codempid%type;
    v_codapman_a        temploy1.codempid%type;
    v_year              number:=0;
    v_month             number:=0;
    v_codcomp           tappemp.codcomp%type;

    v_codapman2         tappfm.codapman%type;
    v_codapman3         tappfm.codapman%type;
    v_dteapstr          tstdisd.dteapstr%type;
    v_dteapend          tstdisd.dteapend%type;

    v_tappemp           tappemp%rowtype;
    v_tappfm            tappfm%rowtype;

    v_pctbeh            taplvl.pctbeh%type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpicp          taplvl.pctkpicp%type;
    v_pctkpiem          taplvl.pctkpiem%type;
    v_pctkpirt          taplvl.pctkpirt%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_taplvl_codcomp    taplvl.codcomp%type;
    v_taplvl_dteeffec   taplvl.dteeffec%type;

    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_last_qty          number;
    v_sum_last_qty      number  := 0;
    v_sum_weight        number  := 0;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    cursor c1 is
      select dteapstr,dteapend
        from tstdisd
       where codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteyreap = (select max(dteyreap)
                           from tstdisd
                          where codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteyreap <= p_dteyreap
                            and numtime = p_numtime)
--#5552
         and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = tstdisd.dteyreap
                       and numseq  = tstdisd.numtime
                       and codaplvl = tstdisd.codaplvl
                       and codempid = nvl(global_v_codempid, codempid) )
--#5552 
         and numtime = p_numtime;

    cursor c3 is
        select codapman,codposap,codcompap
          from tappfm
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = global_v_codempid
           and flgapman = '2'
           and numseq = ( select max(numseq)
                            from tappfm
                           where dteyreap = p_dteyreap
                             and numtime = p_numtime
                             and codempid = global_v_codempid
                             and flgapman = '2');

    cursor c4 is
        select codapman,codposap,codcompap
          from tappfm
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = global_v_codempid
           and flgapman = '3'
           and numseq = ( select max(numseq)
                            from tappfm
                           where dteyreap = p_dteyreap
                             and numtime = p_numtime
                             and codempid = global_v_codempid
                             and flgapman = '3');

    cursor c_tappcmpf is
        select *
          from tappcmpf
         where codempid  = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and grade < gradexpct
      order by codskill;

    cursor c_tapptrnf is
        select codcours
          from tapptrnf
         where codempid  = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by codcours;

    cursor c_tappdevf is
        select coddevp,desdevp
          from tappdevf
         where codempid  = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by coddevp;

    cursor c_taplvl is
        select dteeffec,codcomp
          from taplvl
         where v_codcomp like codcomp||'%'
           and codaplvl = v_tappemp.codaplvl
           and dteeffec <= v_dteapend
      order by codcomp desc,dteeffec desc;
  begin
    obj_row             := json_object_t();
    obj_tappcmpf        := json_object_t();
    obj_courseTable     := json_object_t();
    obj_developTable    := json_object_t();
    obj_result    := json_object_t();
    obj_result.put('coderror','200');

    begin
        select *
          into v_tappemp
          from tappemp
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = global_v_codempid;
    exception when others then
        v_tappemp := null;
    end;

    v_codcomp   := v_tappemp.codcomp;

    begin
        select *
          into v_tappfm
          from tappfm
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = global_v_codempid
           and flgapman = '3'
           and numseq = ( select max(numseq)
                            from tappfm
                           where dteyreap = p_dteyreap
                             and numtime = p_numtime
                             and codempid = global_v_codempid
                             and flgapman = '3');
    exception when others then
        v_tappfm := null;
    end;

    begin
        obj_detail  := json_object_t();
        obj_detail.put('coderror','200');
        for r1 in c1 loop
            v_dteapstr  := r1.dteapstr;
            v_dteapend  := r1.dteapend;
        end loop;

        for r_taplvl in c_taplvl loop
            v_taplvl_dteeffec   := r_taplvl.dteeffec;
            v_taplvl_codcomp    := r_taplvl.codcomp;
            exit;
        end loop;

        begin
            select pctbeh,pctcmp,pctkpicp,pctkpiem,pctkpirt,pctta,pctpunsh
              into v_pctbeh,v_pctcmp,v_pctkpicp,v_pctkpiem,v_pctkpirt,v_pctta,v_pctpunsh
              from taplvl
             where codcomp = v_taplvl_codcomp
               and codaplvl = v_tappemp.codaplvl
               and dteeffec = v_taplvl_dteeffec;
        exception when no_data_found then
            null;
        end;

        for r3 in c3 loop
            v_codapman2 := r3.codapman;
            if v_codapman2 is null then
                begin
                    select codempid
                      into v_codapman2
                      from temploy1
                     where codpos = r3.codposap
                       and codcomp like r3.codcompap || '%'
                       and rownum = 1;
                exception when no_data_found then
                    v_codapman2 := null;
                end;
            end if;
        end loop;

        for r4 in c4 loop
            v_codapman3 := r4.codapman;
            if v_codapman3 is null then
                begin
                    select codempid
                      into v_codapman3
                      from temploy1
                     where codpos = r4.codposap
                       and codcomp like r4.codcompap || '%'
                       and rownum = 1;
                exception when no_data_found then
                    v_codapman3 := null;
                end;
            end if;
        end loop;

        begin
            select qtywork
              into v_qtywork
              from v_temploy
             where codempid = global_v_codempid;
        end;
        convert_month_to_year_month(v_qtywork,v_year,v_month);

        obj_detail.put('codempid',global_v_codempid);
        obj_detail.put('desc_codempid',get_temploy_name(global_v_codempid,global_v_lang));--tappemp
        obj_detail.put('codcomp',v_tappemp.codcomp);
        obj_detail.put('desc_codcomp',get_tcenter_name(v_tappemp.codcomp,global_v_lang));--tappemp
        obj_detail.put('codpos',v_tappemp.codpos);
        obj_detail.put('desc_codpos',get_tpostn_name(v_tappemp.codpos,global_v_lang));--tappemp
        obj_detail.put('agewrkyr',v_year);
        obj_detail.put('agewrkmth',v_month);
        obj_detail.put('agework',v_year||' ' ||get_label_name('HRES1BXC2',global_v_lang,370)|| v_month||' ' ||get_label_name('HRES1BXC2',global_v_lang,380));
        obj_detail.put('codapman',v_codapman2);
        obj_detail.put('desc_codapman',get_temploy_name(v_codapman2,global_v_lang));
        obj_detail.put('codappr',v_codapman3);
        obj_detail.put('desc_codappr',get_temploy_name(v_codapman3,global_v_lang));
        obj_detail.put('dteyreap',p_dteyreap);
        obj_detail.put('numtime',p_numtime);
        obj_detail.put('numseq',p_numseq);
        obj_detail.put('dteapstr',to_char(v_dteapstr,'dd/mm/yyyy'));
        obj_detail.put('dteapend',to_char(v_dteapend,'dd/mm/yyyy'));

        obj_detail.put('qtyscore',v_tappemp.qtytot3);
        obj_detail.put('grade',v_tappemp.grdappr);
        obj_detail.put('flgupsal',v_tappemp.flgsal);
        obj_detail.put('percentUpSalaryBroken',v_tappemp.pctdsal);
        obj_detail.put('percentAdjustSalary',v_tappemp.pctdsal);
        obj_detail.put('flgbonus',v_tappemp.flgbonus);
        obj_detail.put('percentbonus',v_tappemp.pctdbon);
        obj_detail.put('remark',v_tappemp.remark);
        obj_detail.put('commtapman',v_tappemp.remark3);
        obj_detail.put('commtimpro',v_tappemp.commtimpro);

        v_row := 0;
        for r_tappcmpf in c_tappcmpf loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codtency',r_tappcmpf.codtency);
            obj_data.put('codskill',r_tappcmpf.codskill);
            obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r_tappcmpf.codskill, global_v_lang));
            obj_data.put('gradexpct',r_tappcmpf.gradexpct);
            obj_data.put('grade',r_tappcmpf.grade);
            obj_tappcmpf.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end loop;

        v_row := 0;
        for r_tapptrnf in c_tapptrnf loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcours',r_tapptrnf.codcours);
            obj_data.put('desc_codcours',get_tcourse_name(r_tapptrnf.codcours,global_v_lang));
            obj_courseTable.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end loop;

        v_row := 0;
        for r_tappdevf in c_tappdevf loop
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('coddevp',r_tappdevf.coddevp);
            obj_data.put('desdevp',r_tappdevf.desdevp);
            obj_developTable.put(to_char(v_row), obj_data);
            v_row        := v_row + 1;
        end loop;

        v_row := 0;
        if (nvl(v_pctta,0) + nvl(v_pctpunsh,0) > 0) then
            begin
                select qtyta ,qtypuns
                  into v_qtyta, v_qtypuns
                  from tappemp
                 where codempid = global_v_codempid
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime;
            exception when no_data_found then
                v_qtyta     := 0;
                v_qtypuns   := 0;
            end;

            begin
                select scorfta, scorfpunsh
                  into v_scorfta, v_scorfpunsh
                  from tattpreh
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and codaplvl = v_tappemp.codaplvl
                   and dteeffec = (select max(dteeffec)
                                     from tattpreh
                                    where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                      and codaplvl = v_tappemp.codaplvl
                                      and dteeffec <= trunc(sysdate));
            exception when no_data_found then
                null;
            end;

            v_last_qty      := round((v_qtyta + v_qtypuns)/2,2);
            v_sum_last_qty  := v_sum_last_qty + round(nvl(v_qtyta,0)/100 * nvl(v_pctta,0),2) + round(nvl(v_qtypuns,0)/100 * nvl(v_pctpunsh,0),2);
            v_sum_weight := v_sum_weight + nvl(v_pctta,0) + nvl(v_pctpunsh,0);

            obj_data    := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
            obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 170));
            obj_data.put('weight',nvl(v_pctta,0) + nvl(v_pctpunsh,0));
            obj_data.put('leader_qty',to_char(v_last_qty,'fm9,999,999.00'));
            obj_data.put('flgTopic','workingTime');
            obj_row.put(to_char(v_row),obj_data);
            v_row      := v_row + 1;
        end if;

        if (nvl(v_pctbeh,0) > 0) then
            v_last_qty          := round(v_tappfm.qtybeh / v_tappfm.qtybehf * 100,2);
            v_sum_last_qty      := v_sum_last_qty + round(v_last_qty/100 * nvl(v_pctbeh,0),2);
            v_sum_weight := v_sum_weight + nvl(v_pctbeh,0);

            obj_data    := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
            obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 180));
            obj_data.put('weight',nvl(v_pctbeh,0));
            obj_data.put('leader_qty',to_char(v_last_qty,'fm9,999,999.00'));
            obj_data.put('flgTopic','behavior');
            obj_row.put(to_char(v_row),obj_data);
            v_row      := v_row + 1;
        end if;

        if (nvl(v_pctcmp,0) > 0) then
            v_last_qty          := round(v_tappfm.qtycmp / v_tappfm.qtycmpf * 100,2);
            v_sum_last_qty      := v_sum_last_qty + round(v_last_qty/100 * nvl(v_pctcmp,0),2);
            v_sum_weight        := v_sum_weight + nvl(v_pctcmp,0);

            obj_data            := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
            obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 190));
            obj_data.put('weight',nvl(v_pctcmp,0));
            obj_data.put('leader_qty',to_char(v_last_qty,'fm9,999,999.00'));
            obj_data.put('flgTopic','competency');
            obj_row.put(to_char(v_row),obj_data);
            v_row      := v_row + 1;
        end if;

        if (nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0) > 0) then
            v_last_qty          := round(v_tappfm.qtykpi / v_tappfm.qtykpif * 100,2);
            v_sum_last_qty      := v_sum_last_qty + round(v_last_qty/100 * (nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0)),2);
            v_sum_weight        := v_sum_weight + nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0);
            obj_data            := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('icon','<i class="fa fa-info-circle"></i>');
            obj_data.put('desc_codform',get_label_name('HRAP31E1', global_v_lang, 200));
            obj_data.put('weight', nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0));
            obj_data.put('leader_qty',to_char(v_last_qty,'fm9,999,999.00'));
            obj_data.put('flgTopic','kpi');
            obj_row.put(to_char(v_row),obj_data);
            v_row          := v_row + 1;
        end if;

        obj_data    := json_object_t();obj_data.put('coderror','200');
        obj_data.put('icon','');
        obj_data.put('desc_codform',get_label_name('HRAP31E2', global_v_lang, 200));
        obj_data.put('weight', v_sum_weight);
        obj_data.put('leader_qty',to_char(v_sum_last_qty,'fm9,999,999.00'));
        obj_data.put('flgTopic','total');
        obj_row.put(to_char(v_row),obj_data);

        obj_result.put('detail',obj_detail);
        obj_result.put('tappcmpf',obj_tappcmpf);
        obj_result.put('table',obj_row);
        obj_result.put('courseTable',obj_courseTable);
        obj_result.put('developTable',obj_developTable);
--    exception when others then
--        null;
    end;
    json_str_output := obj_result.to_clob;
  end;
  procedure get_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
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
    v_qtyscorn_sum      number := 0;
    v_weigth_sum        number := 0;
    v_max_numseq        tappfm.numseq%type;
    v_numgrup           tappbehg.numgrup%type;
    v_numitem           tintvewd.numgrup%type;
    v_grdscor           tappbehi.grdscor%type;
    v_remark            tappbehi.remark%type;

    cursor c_tintvews is
        select numgrup, decode(global_v_lang, '101', desgrupe,
                                   '102', desgrupt,
                                   '103', desgrup3,
                                   '104', desgrup4,
                                   '105', desgrup5,
                                   '') desgrup
          from tintvews
         where codform = v_codform
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
         where codform = v_codform
           and numgrup = v_numgrup
      order by numitem;

  begin

    begin
        select remarkbeh, commtbeh, flgapman, codform
          into v_remarkbeh, v_commtbeh, v_flgapman, v_codform
          from tappfm
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq
           and codempid = global_v_codempid;
    exception when others then
        v_remarkbeh := null;
        v_commtbeh  := null;
    end;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('codform',v_codform);
    obj_detail.put('desc_codform', get_tintview_name(v_codform,global_v_lang));

    v_rcnt  := 0;
    obj_row := json_object_t();

    for r_tintvews in c_tintvews loop
        v_numgrup := r_tintvews.numgrup;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('numitem',get_label_name('HRAP31E1', global_v_lang, 230)||r_tintvews.numgrup);
        obj_data.put('numgrup','');
        obj_data.put('desitem',r_tintvews.desgrup);
        obj_data.put('qtywgt','');
        obj_data.put('grdscor_appr','');
        obj_data.put('qtyscorn_appr','');
        obj_data.put('remark','');
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;

        for r_tintvewd in c_tintvewd loop
            v_numitem := r_tintvewd.numitem;
            begin
                select qtyscorn, grdscor, remark
                  into v_qtyscorn, v_grdscor, v_remark
                  from tappbehi
                 where codempid = global_v_codempid
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numgrup = v_numgrup
                   and numitem  = v_numitem
                   and numseq = p_numseq;
            exception when no_data_found then
                v_qtyscorn  := 0;
                v_grdscor   := '';
                v_remark    := '';
            end;
            v_weigth_sum    := v_weigth_sum + nvl(r_tintvewd.qtywgt,0);
            v_qtyscorn_sum  := v_qtyscorn_sum + nvl(v_qtyscorn,0);
            obj_data := json_object_t();
            obj_data.put('numitem',r_tintvewd.numitem);
            obj_data.put('numgrup',r_tintvews.numgrup);
            obj_data.put('desitem',r_tintvewd.desitem);
            obj_data.put('qtywgt',r_tintvewd.qtywgt);
            obj_data.put('grdscor_appr',v_grdscor);
            obj_data.put('qtyscorn_appr',v_qtyscorn);
            obj_data.put('remark',v_remark);
            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end loop;
    end loop;

    obj_data := json_object_t();
    obj_data.put('numitem','');
    obj_data.put('numgrup','');
    obj_data.put('desitem',get_label_name('HRES1BXC4', global_v_lang, 100));
    obj_data.put('qtywgt',v_weigth_sum);
    obj_data.put('grdscor_appr','');
    obj_data.put('qtyscorn_appr',v_qtyscorn_sum);
    obj_data.put('remark','');
    obj_row.put(to_char(v_rcnt),obj_data);
    v_rcnt  := v_rcnt + 1;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('table',obj_row);

    json_str_output   := obj_data.to_clob;
  end;

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
    v_taplvld_codcomp             taplvld.codcomp%type;
    v_taplvld_dteeffec            taplvld.dteeffec%type;
    v_codaplvl          tappfm.codaplvl%type;
    v_codcomp           tappfm.codcomp%type;
    v_codpos            tappfm.codpos%type;
    cursor c_taplvld_where is
      select dteeffec,codcomp
        from taplvld
       where v_codcomp like codcomp||'%'
         and codaplvl = v_codaplvl
         and dteeffec <= v_dteapend
      order by codcomp desc,dteeffec desc;

    cursor c_taplvld is
        select *
          from taplvld
         where v_taplvld_codcomp = codcomp
           and codaplvl = v_codaplvl
           and dteeffec = v_taplvld_dteeffec
      order by codtency;

    cursor c_tjobposskil is
        select *
          from tjobposskil
         where codpos = v_codpos
           and codcomp = v_codcomp
           and codtency = v_codtency
      order by codskill;
  begin
    select flgapman, codcomp, codaplvl, codpos
      into v_flgapman, v_codcomp, v_codaplvl, v_codpos
      from tappfm
     where codempid = global_v_codempid
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    select dteapend, flgtypap
      into v_dteapend, v_flgtypap
      from tstdisd
     where codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--#5552
         and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = tstdisd.dteyreap
                       and numseq  = tstdisd.numtime
                       and codaplvl = tstdisd.codaplvl
                       and codempid = nvl(global_v_codempid, codempid) )
--#5552 
       ;

    for r_taplvld in c_taplvld_where loop
      v_taplvld_dteeffec    := r_taplvld.dteeffec;
      v_taplvld_codcomp     := r_taplvld.codcomp;
      exit;
    end loop;

    obj_row := json_object_t();
    for r1 in c_taplvld loop
        obj_data            := json_object_t();

        v_codtency  := r1.codtency;
        for r2 in c_tjobposskil loop
            begin
                select grade, qtyscor, remark
                  into v_grade, v_qtyscor, v_remark
                  from tappcmps
                 where codempid = global_v_codempid
                   and dteyreap = p_dteyreap
                   and numtime = p_numtime
                   and numseq = p_numseq
                   and codtency = r2.codtency
                   and codskill = r2.codskill;
            exception when no_data_found then
                v_grade     := '';
                v_qtyscor   := 0;
                v_remark    := '';
            end;

            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codtency',get_tcomptnc_name(r1.codtency, global_v_lang));
            obj_data.put('weight',r1.qtywgt);
            obj_data.put('codskill',r2.codskill);
            obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r2.codskill, global_v_lang));
            obj_data.put('grade',r2.grade);
            obj_data.put('grdscor_appr',v_grade);
            obj_data.put('qtyscor_appr',v_qtyscor);
            obj_data.put('remark',v_remark);
            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt := v_rcnt + 1;
        end loop;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;



  procedure gen_kpi_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;

    v_codform           taplvl.codform%type;
    v_dteapend          tappfm.dteapend%type;
    v_numseq            tappfm.numseq%type;
    v_score             tappkpid.qtyscorn%type := 0;
    v_qtyscorn          tappkpid.qtyscorn%type;
    v_qtyscorn1         tappkpid.qtyscorn%type;
    v_qtyscorn2         tappkpid.qtyscorn%type;
    v_qtyscorn3         tappkpid.qtyscorn%type;
    v_grade             tappkpid.grade%type;
    v_typkpi            tkpiemp.typkpi%type := 'x';
    v_remark            tappkpid.remark%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_max_numseq        tappfm.numseq%type;
    v_codkpi            tappkpid.kpino%type;
    v_codcomp           tappfm.codcomp%type;
    v_pctwgt_sum        number;

    cursor c_tkpiemp is
        select tkpiemp.*,decode(typkpi,'D',1,'I',2,'J',3,9) order_field
          from tkpiemp
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codempid = global_v_codempid
      order by order_field,codkpi;

  begin
    select codcomp
      into v_codcomp
      from tappfm
     where codempid = global_v_codempid
       and dteyreap = p_dteyreap
       and numtime = p_numtime
       and numseq = p_numseq;

    select flgtypap
      into v_flgtypap
      from tstdisd
     where codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
       and dteyreap = p_dteyreap
       and numtime = p_numtime
--#5552
         and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = tstdisd.dteyreap
                       and numseq  = tstdisd.numtime
                       and codaplvl = tstdisd.codaplvl
                       and codempid = nvl(global_v_codempid, codempid) )
--#5552 
       ;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r_tkpiemp in c_tkpiemp loop
        if v_typkpi != r_tkpiemp.typkpi then
            v_typkpi := r_tkpiemp.typkpi;
            obj_data := json_object_t();
            obj_data.put('codkpi',get_tlistval_name('TYPKPI',v_typkpi,global_v_lang));
            obj_data.put('kpides','');
            obj_data.put('target','');
            obj_data.put('mtrfinish','');
            obj_data.put('pctwgt','');
            obj_data.put('achieve', '');
            obj_data.put('grdscor_appr','');
            obj_data.put('qtyscor_appr','');
            obj_data.put('remark','');
            obj_row.put(to_char(v_rcnt),obj_data);
            v_rcnt  := v_rcnt + 1;
        end if;

        obj_data := json_object_t();

        begin
            select qtyscorn, grade, remark
              into v_qtyscorn, v_grade, v_remark
              from tappkpid
             where codempid = global_v_codempid
               and dteyreap = p_dteyreap
               and numtime = p_numtime
               and kpino = r_tkpiemp.codkpi
               and numseq = p_numseq;
        exception when no_data_found then
            v_qtyscorn  := 0;
            v_grade     := '';
            v_remark    := '';
        end;

        v_score         := nvl(v_score,0) + nvl(v_qtyscorn,0);
        v_pctwgt_sum    := nvl(v_pctwgt_sum,0) + nvl(r_tkpiemp.pctwgt,0);
        obj_data := json_object_t();
        obj_data.put('codkpi',r_tkpiemp.codkpi);
        obj_data.put('kpides',r_tkpiemp.kpides);
        obj_data.put('target',r_tkpiemp.target);
        obj_data.put('mtrfinish',r_tkpiemp.mtrfinish);
        obj_data.put('pctwgt',r_tkpiemp.pctwgt);
        obj_data.put('achieve', r_tkpiemp.achieve);
        obj_data.put('grdscor_appr',v_grade);
        obj_data.put('qtyscor_appr',v_qtyscorn);
        obj_data.put('remark',v_remark);

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt  := v_rcnt + 1;
    end loop;
    obj_data := json_object_t();
    obj_data.put('codkpi','');
    obj_data.put('kpides',get_label_name('HRES1BXC4', global_v_lang, 100));
    obj_data.put('target','');
    obj_data.put('mtrfinish','');
    obj_data.put('pctwgt',v_pctwgt_sum);
    obj_data.put('achieve', '');
    obj_data.put('grdscor_appr','');
    obj_data.put('qtyscor_appr',v_score);
    obj_data.put('remark','');

    obj_row.put(to_char(v_rcnt),obj_data);
    v_rcnt  := v_rcnt + 1;

    obj_detail := json_object_t();
    obj_detail.put('coderror','200');
    obj_detail.put('qtyscorn',v_score);

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('detail',obj_detail);
    obj_data.put('table',obj_row);

    json_str_output   := obj_data.to_clob;
  end;

  procedure gen_workingtime_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_row             json_object_t;
    obj_grpleave_row    json_object_t;
    obj_punnish_row     json_object_t;
    obj_discipline_row  json_object_t;
    v_rcnt              number := 0;
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
    v_codaplvl          tappfm.codaplvl%type;
    v_codcomp           tappfm.codcomp%type;

    cursor c_tappempta is
        select *
          from tappempta
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime;

    cursor c_tappempmt is
        select *
          from tappempmt
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime;

    cursor c_tattpre1 is
        select 1 type,codgrplv
          from tattpre1
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'N'
         union
        select 2 type,codgrplv
          from tattpre1
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'Y'
         union
        select 3 type,codgrplv
          from tattpre1
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'Y'
           and flglate = 'N'
      order by type;

    cursor c_tattpre3 is
        select codpunsh
          from tattpre3
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codaplvl = v_codaplvl
           and dteeffec = v_dteeffec
      order by codpunsh;

  begin

      begin
        select dteapstr, dteapend, dteapman, codaplvl, codcomp
          into v_dteapstr, v_dteapend, v_dteapman, v_codaplvl, v_codcomp
          from tappfm
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
           and numseq = p_numseq;
      exception when no_data_found then
        v_codaplvl  := null;
        v_codcomp   := null;
      end;

      select dtebhstr, dtebhend, dteapend
        into v_dtebhstr, v_dtebhend, v_dteapend
        from tstdisd
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codcomp = hcm_util.get_codcomp_level(v_codcomp,1)
--#5552
         and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = tstdisd.dteyreap
                       and numseq  = tstdisd.numtime
                       and codaplvl = tstdisd.codaplvl
                       and codempid = nvl(global_v_codempid, codempid) )
--#5552 
         ;

      begin
        select qtyta, qtypuns, flgsal, flgbonus, pctdbon, pctdsal
          into v_tappemp_qtyta, v_tappemp_qtypuns, v_tappemp_flgsal, v_tappemp_flgbonus, v_tappemp_pctdbon, v_tappemp_pctdsal
          from tappemp
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime;
      exception when no_data_found then
        null;
      end;

      begin
          select dteeffec, scorfta, scorfpunsh
            into v_dteeffec, v_scorfta, v_scorfpunsh
            from tattpreh
           where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
             and codaplvl = v_codaplvl
             and dteeffec = (select max(dteeffec)
                               from tattpreh
                              where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                and codaplvl = v_codaplvl
                                and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        null;
      end;

      get_taplvl_where(v_codcomp,v_codaplvl,v_dteapend,v_taplvl_codcomp,v_taplvl_dteeffec);

      begin
          select pctta, pctpunsh
            into v_pctta, v_pctpunsh
            from taplvl
           where codcomp = v_taplvl_codcomp
             and codaplvl = v_codaplvl
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
                 where a.codempid = global_v_codempid
                   and a.dtework between v_dtebhstr and v_dtebhend
                   and a.codleave = b.codleave
                   and b.codaplvl = v_codaplvl
                   and b.dteeffec = v_dteeffec
                   and b.codgrplv = r_tattpre1.codgrplv;
            elsif r_tattpre1.type = 2 then
                select sum(nvl(qtytlate,0) + nvl(qtytearly,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = global_v_codempid
                   and dtework between v_dtebhstr and v_dtebhend;
            elsif r_tattpre1.type = 3 then
                select sum(nvl(qtytabs,0))
                  into v_qtyleav
                  from tlateabs
                 where codempid = global_v_codempid
                   and dtework between v_dtebhstr and v_dtebhend;
            end if;

            begin
                select scorded, flgsal, pctdedsal, flgbonus, pctdedbon
                  into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
                  from tattpre2
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and codaplvl = v_codaplvl
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
             where codempid = global_v_codempid
               and codpunsh = r_tattpre3.codpunsh
               and dteeffec between v_dtebhstr and v_dtebhend;

            begin
                select scoreded, flgsal, pctdedsal, flgbonus, pctdedbonus
                  into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
                  from tattpre4
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and codaplvl = v_codaplvl
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
      obj_data.put('description',get_label_name('HRAP31E1', global_v_lang, 210));
      obj_data.put('fullscore',v_scorfta);
      obj_data.put('reducescore',v_scorfta-v_scoreta);
      obj_data.put('qtyscore',v_scoreta);
      obj_data.put('weight',v_pctta);
      obj_data.put('netscore',round((v_pctta * v_scoreta)/(v_pctta * v_scorfta) * 100,2));
      obj_discipline_row.put(to_char(v_rcnt-1),obj_data);

      v_rcnt                := v_rcnt + 1;
      obj_data              := json_object_t();
      obj_data.put('description',get_label_name('HRAP31E1', global_v_lang, 220));
      obj_data.put('fullscore',v_scorfpunsh);
      obj_data.put('reducescore',v_scorfpunsh-v_scorepunsh);
      obj_data.put('qtyscore',v_scorepunsh);
      obj_data.put('weight',v_pctpunsh);
      obj_data.put('netscore',round((v_pctpunsh * v_scorepunsh) / (v_pctpunsh * v_scorfpunsh) * 100,2));
      obj_discipline_row.put(to_char(v_rcnt-1),obj_data);

      obj_detail      := json_object_t();
      obj_detail.put('coderror','200');
      obj_detail.put('scorf',v_scorfta + v_scorfpunsh); -- คะแนนเต็ม เวลามาทำงาน/ผิดวินัย
      obj_detail.put('score',v_scoreta + v_scorepunsh); -- คะแนนที่ได้ เวลามาทำงาน/ผิดวินัย
      obj_detail.put('scorfta',v_scorfta); -- คะแนนเต็ม รายละเอียดกลุ่มการลา
      obj_detail.put('scoreta',v_scoreta); -- คะแนนที่ได้ รายละเอียดกลุ่มการลา
      obj_detail.put('scorfpunsh',v_scorfpunsh); -- คะแนนเต็ม การมาทำงานผิดวินัย
      obj_detail.put('scorepunsh',v_scorepunsh); -- คะแนนที่ได้ การมาทำงานผิดวินัย

      obj_data      := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('detail', obj_detail);
      obj_data.put('leaveGroupTable', obj_grpleave_row);
      obj_data.put('workTable', obj_punnish_row);
      obj_data.put('disciplineTable', obj_discipline_row);

      json_str_output   := obj_data.to_clob;
  end;

  procedure get_detail_sub (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail_sub(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_sub (json_str_output out clob) is
    obj_data            json_object_t;
    v_rcnt              number := 0;
    obj_workingtime     json_object_t;
    obj_behavior        json_object_t;
    obj_competency      json_object_t;
    obj_kpi             json_object_t;
    clob_table          clob;
	cursor c_tappfm is
		select *
          from tappfm
         where codempid = global_v_codempid
           and dteyreap = p_dteyreap
           and numtime = p_numtime
      order by numseq;
  begin
    obj_workingtime     := json_object_t();
    obj_behavior        := json_object_t();
    obj_competency      := json_object_t();
    obj_kpi             := json_object_t();

    gen_workingtime_detail(clob_table);
    obj_workingtime        := json_object_t(clob_table);

    gen_behavior_detail(clob_table);
    obj_behavior        := json_object_t(clob_table);

    gen_competencysub(clob_table);
    obj_competency.put('coderror','200');
    obj_competency.put('table',json_object_t(clob_table));

    gen_kpi_detail(clob_table);
    obj_kpi             := json_object_t(clob_table);

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('workingtime', obj_workingtime);
    obj_data.put('behavior', obj_behavior);
    obj_data.put('competency',obj_competency);
    obj_data.put('kpi', obj_kpi);
    json_str_output := obj_data.to_clob;
  end;

  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_dteapend date,p_codcomp_out out varchar2,p_dteeffec out date) as
    cursor c_taplvl is
      select dteeffec,codcomp
        from taplvl
       where p_codcomp_in like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= p_dteapend
      order by codcomp desc,dteeffec desc;
  begin
    for r_taplvl in c_taplvl loop
      p_dteeffec := r_taplvl.dteeffec;
      p_codcomp_out := r_taplvl.codcomp;
      exit;
    end loop;
  end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRES17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES17E" is
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

    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'ddmmyyyy');

    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codkpi           := hcm_util.get_string_t(json_obj,'p_codkpi');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');
  end initial_value;
  --
  procedure check_save(json_str in clob) is
    json_obj        json_object_t;
    v_dteyear       tpotentp.dteyear%type;
    v_codcompy      tpotentp.codcompy%type;
    v_numclseq      tpotentp.numclseq%type;
    v_codcours      tpotentp.codcours%type;
    v_codempid      tpotentp.codempid%type;
    v_count_tpotentp    number;
    v_tpotentp          tpotentp%rowtype;
  begin
    json_obj            := json_object_t(json_str);
    v_dteyear           := hcm_util.get_string_t(json_obj,'dteyear');
    v_codcompy          := hcm_util.get_string_t(json_obj,'codcompy');
    v_numclseq          := hcm_util.get_string_t(json_obj,'numclseq');
    v_codcours          := hcm_util.get_string_t(json_obj,'codcours');
    v_codempid          := hcm_util.get_string_t(json_obj,'codempid');

    select count(*)
      into v_count_tpotentp
      from tpotentp
     where dteyear = v_dteyear
       and codcompy = v_codcompy
       and numclseq = v_numclseq
       and codcours = v_codcours
       and codempid = v_codempid
       and flgatend not in ('Y','C');

    if v_count_tpotentp = 0 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPOTENTP');
        return;
    end if;

    begin
        select codtparg
          into p_codtparg
          from tpotentp
         where dteyear = v_dteyear
           and codcompy = v_codcompy
           and numclseq = v_numclseq
           and codcours = v_codcours
           and codempid = v_codempid;        
    exception when no_data_found then
        p_codtparg := null;
    end;

  end check_save;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
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
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    v_next_codappr  varchar2(1000);

	cursor c1 is
		select *
          from tkpireq
         where dtereq between nvl(p_dtestr,dtereq) and nvl(p_dteend,dtereq)
           and dteyreap = p_dteyear
           and numtime = p_numtime
           and codempid = global_v_codempid
      order by dtereq desc, numseq desc;

  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        v_next_codappr := chk_workflow.get_next_approve('HRES17E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),
                                        r1.numseq, r1.approvno,global_v_lang);

        obj_data.put('coderror', '200');
        obj_data.put('numseq', r1.numseq);
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('staappr', r1.staappr);
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('desc_codappr', r1.codappr || ' - ' || get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('desc_codempap', v_next_codappr);
        obj_data.put('dteyreap', r1.dteyreap);
        obj_data.put('numtime', r1.numtime);
        obj_data.put('codempid', r1.codempid);

        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index_data(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure gen_index_data (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codpos        temploy1.codpos%type;
    v_tkpireq       tkpireq%rowtype;

    v_next_codappr  varchar2(1000);
    v_kpides        tkpireq2.kpides%type;

	cursor c1 is
		select *
          from tkpireq2
         where dtereq = p_dtereq
           and numseq = p_numseq
           and codempid = global_v_codempid
           and dteyreap = v_tkpireq.dteyreap
           and numtime = v_tkpireq.numtime
      order by codkpi;

	cursor c2 is
		select *
          from tkpidpem
         where codempid = global_v_codempid
           and dteyreap = p_dteyear
           and numtime = p_numtime
      order by codkpino;

  begin
    v_rcnt := 0;
    obj_main := json_object_t();
    obj_row := json_object_t();
    
    if p_numseq = 0 or p_numseq is null then
        begin
            select max(numseq)
              into p_numseq
              from tkpireq
             where dtereq = p_dtereq
               and codempid = global_v_codempid;            
        exception when no_data_found then
            p_numseq := 0;
        end;
        p_numseq := nvl(p_numseq,0) + 1;
    end if;

    begin
        select *
          into v_tkpireq
          from tkpireq
         where dtereq = p_dtereq
           and numseq = p_numseq
           and codempid = global_v_codempid;
    exception when no_data_found then
        v_tkpireq := null;
    end;

    select codpos
      into v_codpos
      from temploy1 
     where codempid = global_v_codempid;
    v_rcnt := 0;
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('typkpi',  r1.typkpi);
        obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_data.put('codkpi', r1.codkpi);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('target', r1.target);
        obj_data.put('mtrfinish', r1.mtrfinish);
        obj_data.put('pctwgt', r1.pctwgt);
        obj_data.put('targtstr', to_char(r1.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend', to_char(r1.targtend,'dd/mm/yyyy'));
        obj_data.put('flgdefault', 'N');
        obj_data.put('flgAdd', false);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    
    if v_rcnt = 0 then
    for r2 in c2 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('typkpi',  'D');
        obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI','D',global_v_lang));
        obj_data.put('codkpi', r2.codkpino);
        
        begin
            select kpides 
              into v_kpides
              from tkpidph
             where dteyreap = r2.dteyreap
               and numtime = r2.numtime
               and codcomp = r2.codcomp
               and codkpino = r2.codkpino;
        exception when no_data_found then
            v_kpides := null;
        end;   
        obj_data.put('kpides', v_kpides);
        obj_data.put('target', r2.target);
        obj_data.put('mtrfinish', r2.kpivalue);
        obj_data.put('pctwgt', '');
        obj_data.put('targtstr', to_char(r2.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend', to_char(r2.targtend,'dd/mm/yyyy'));
        obj_data.put('flgdefault', 'Y');
        obj_data.put('flgAdd', true);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;    
    end if;

    obj_main.put('coderror', '200');
    obj_main.put('objective', v_tkpireq.objective);
    obj_main.put('codcomp', v_tkpireq.codcomp);
    obj_main.put('desc_codcomp', get_tcenter_name(v_tkpireq.codcomp,global_v_lang));
    obj_main.put('codpos', v_codpos);
    obj_main.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
    obj_main.put('codempid', p_codempid_query);
    obj_main.put('dtereq', to_char(p_dtereq,'dd/mm/yyyy'));
    obj_main.put('numseq', p_numseq);
    obj_main.put('staappr', v_tkpireq.staappr);
    obj_main.put('dteyreap',p_dteyear);
    obj_main.put('numtime', p_numtime);
    obj_main.put('kpi_index', obj_row);

    json_str_output := obj_main.to_clob;
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail (json_str_output out clob) is
    obj_detail      json_object_t;
    obj_main        json_object_t;
    obj_data        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_count_found   number := 0;
    max_numseq      number;

    obj_score       json_object_t;
    obj_plan        json_object_t;
    v_staappr       tkpireq.staappr%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_tkpidpem      tkpidpem%rowtype;
    v_tjobkpig      tjobkpig%rowtype;    

	cursor c_tkpireq2 is
		select *
          from tkpireq2
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
           and dteyreap = p_dteyear
           and numtime = p_numtime
           and codkpi = p_codkpi;

	cursor c_tkpireq4 is
		select *
          from tkpireq4
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
           and dteyreap = p_dteyear
           and numtime = p_numtime
           and codkpi = p_codkpi;

	cursor c_tkpireq3 is
		select *
          from tkpireq3
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
           and dteyreap = p_dteyear
           and numtime = p_numtime
           and codkpi = p_codkpi;      

	cursor c_tkpidph is
		select *
          from tkpidph
         where dteyreap = p_dteyear
           and numtime = p_numtime
           and codcomp = v_codcomp
           and codkpino = p_codkpi;       

	cursor c_tjobkpi is
		select *
          from tjobkpi
         where codpos = v_codpos
           and codcomp = v_codcomp
           and codkpi = p_codkpi;        

	cursor c_tjobkpip is
		select *
          from tjobkpip
         where codpos = v_codpos
           and codcomp = v_codcomp
           and codkpi = p_codkpi
      order by planlvl;       

	cursor c_tgradekpi is
        select *
          from tgradekpi
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteyreap = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteyreap <= to_number(to_char(sysdate,'YYYY'))
                           )
     order by grade ;        
  begin
    obj_main        := json_object_t();
    obj_detail      := json_object_t();

    obj_score       := json_object_t();
    obj_plan        := json_object_t();

    obj_detail.put('coderror', '200');
    
    select codcomp,codpos
      into v_codcomp,v_codpos
      from temploy1
     where codempid = p_codempid_query;
    
    begin
        select staappr 
          into v_staappr
          from tkpireq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq
           and dteyreap = p_dteyear
           and numtime = p_numtime;
    exception when no_data_found then
        v_staappr := '';
    end;
    
    obj_detail.put('codempid', p_codempid_query);
    obj_detail.put('numseq', p_numseq);
    obj_detail.put('dteyreap', p_dteyear);
    obj_detail.put('numtime', p_numtime); 

    for r1 in c_tkpireq2 loop
        v_count_found := 1;
        obj_detail.put('typkpi', r1.typkpi);
        obj_detail.put('desc_typkpi', get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_detail.put('codkpi', r1.codkpi);
        obj_detail.put('kpides', r1.kpides);
        obj_detail.put('target', r1.target);
        obj_detail.put('mtrfinish', r1.mtrfinish);
        obj_detail.put('pctwgt', r1.pctwgt);
        obj_detail.put('targtstr', to_char(r1.targtstr,'dd/mm/yyyy'));
        obj_detail.put('targtend', to_char(r1.targtend,'dd/mm/yyyy'));
        obj_detail.put('flgdefault', 'N');
        obj_detail.put('staappr', v_staappr); 

        v_rcnt := 0;
        for r2 in c_tkpireq4 loop
            v_rcnt      := v_rcnt +1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('grade', r2.grade);
            obj_data.put('desgrade', r2.desgrade);
            obj_data.put('score', r2.score);
            obj_data.put('color', r2.color);
            obj_data.put('desc_color', '<i class=''fas fa-circle'' style=''color: '||r2.color||';''></i>');
            obj_data.put('kpides', r2.kpides);
            obj_data.put('stakpi', r2.stakpi);
            obj_data.put('flgAdd', false);
            obj_score.put(to_char(v_rcnt-1), obj_data);
        end loop;

        v_rcnt := 0;
        for r3 in c_tkpireq3 loop
            v_rcnt      := v_rcnt +1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('planno', r3.planno);
            obj_data.put('plandes', r3.plandes);
            obj_data.put('targtstr', to_char(r3.targtstr,'dd/mm/yyyy'));
            obj_data.put('targtend', to_char(r3.targtend,'dd/mm/yyyy'));
            obj_data.put('flgAdd', false);
            obj_plan.put(to_char(v_rcnt-1), obj_data);
        end loop;
    end loop;
    
    if v_count_found = 0 then
        for r1 in c_tkpidph loop
            v_count_found := 1;
            
            begin
                select *
                  into v_tkpidpem
                  from tkpidpem
                 where dteyreap = r1.dteyreap
                   and numtime = r1.numtime
                   and codcomp = r1.codcomp
                   and codkpino = r1.codkpino
                   and codempid = p_codempid_query;            
            exception when no_data_found then
                v_tkpidpem := null;
            end;
               
            obj_detail.put('typkpi', 'D');
            obj_detail.put('desc_typkpi', get_tlistval_name('TYPKPI','D',global_v_lang));
            obj_detail.put('codkpi', r1.codkpino);
            obj_detail.put('kpides', r1.kpides);
            obj_detail.put('target', v_tkpidpem.target);
            obj_detail.put('mtrfinish', v_tkpidpem.kpivalue);
            obj_detail.put('pctwgt', '');
            obj_detail.put('targtstr', to_char(v_tkpidpem.targtstr,'dd/mm/yyyy'));
            obj_detail.put('targtend', to_char(v_tkpidpem.targtend,'dd/mm/yyyy'));
            obj_detail.put('flgdefault', 'Y');
            obj_detail.put('staappr', v_staappr); 
    
            v_rcnt := 0;
            for r2 in c_tgradekpi loop
                v_rcnt      := v_rcnt +1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('grade', r2.grade);
                obj_data.put('desgrade', r2.desgrade);
                obj_data.put('score', r2.score);
                obj_data.put('color', r2.color);
                obj_data.put('desc_color', '<i class=''fas fa-circle'' style=''color: '||r2.color||';''></i>');
                obj_data.put('kpides', r2.measuredes);
                obj_data.put('stakpi', '');
                obj_data.put('flgAdd', true);
                obj_score.put(to_char(v_rcnt-1), obj_data);
            end loop;
        end loop;
    end if;

    if v_count_found = 0 then
        for r1 in c_tjobkpi loop
            v_count_found := 1;
            
            obj_detail.put('typkpi', 'J');
            obj_detail.put('desc_typkpi', get_tlistval_name('TYPKPI','J',global_v_lang));
            obj_detail.put('codkpi', r1.codkpi);
            obj_detail.put('kpides', r1.kpiitem);
            obj_detail.put('target', r1.target);
            obj_detail.put('mtrfinish', r1.kpivalue);
            obj_detail.put('pctwgt', '');
            obj_detail.put('targtstr', '');
            obj_detail.put('targtend','');
            obj_detail.put('flgdefault', 'Y');
            obj_detail.put('staappr', v_staappr); 
    
            v_rcnt := 0;
            for r2 in c_tgradekpi loop
                begin
                    select *
                      into v_tjobkpig
                      from tjobkpig
                     where CODPOS = v_codpos
                     and CODCOMP = v_codcomp
                     and codkpi = r1.codkpi
                     and qtyscor = r2.score;           
                exception when no_data_found then
                    v_tjobkpig := null;
                end;            
            
                v_rcnt      := v_rcnt +1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('grade', r2.grade);
                obj_data.put('desgrade', r2.desgrade);
                obj_data.put('score', r2.score);
                obj_data.put('color', r2.color);
                obj_data.put('desc_color', '<i class=''fas fa-circle'' style=''color: '||r2.color||';''></i>');
                obj_data.put('kpides', v_tjobkpig.descgrd);
                obj_data.put('stakpi', v_tjobkpig.flgkpi);
                obj_data.put('flgAdd', true);
                obj_score.put(to_char(v_rcnt-1), obj_data);
            end loop;

            v_rcnt := 0;
            for r3 in c_tjobkpip loop
                v_rcnt      := v_rcnt +1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('planno', r3.planlvl);
                obj_data.put('plandes', r3.plandesc);
                obj_data.put('targtstr', '');
                obj_data.put('targtend', '');
                obj_data.put('flgAdd', true);
                obj_plan.put(to_char(v_rcnt-1), obj_data);
            end loop;
        end loop;
    end if;

    if v_count_found = 0 then
        obj_detail.put('typkpi', 'I');
        obj_detail.put('desc_typkpi', get_tlistval_name('TYPKPI','I',global_v_lang));
        obj_detail.put('codkpi', p_codkpi);
        obj_detail.put('kpides', '');
        obj_detail.put('target', '');
        obj_detail.put('mtrfinish', '');
        obj_detail.put('pctwgt', '');
        obj_detail.put('targtstr', '');
        obj_detail.put('targtend','');
        obj_detail.put('flgdefault', 'N');
        obj_detail.put('staappr', v_staappr); 

        v_rcnt := 0;
        for r2 in c_tgradekpi loop
            v_rcnt      := v_rcnt +1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('grade', r2.grade);
            obj_data.put('desgrade', r2.desgrade);
            obj_data.put('score', r2.score);
            obj_data.put('color', r2.color);
            obj_data.put('desc_color', '<i class=''fas fa-circle'' style=''color: '||r2.color||';''></i>');
            obj_data.put('kpides', r2.measuredes);
            obj_data.put('stakpi', '');
            obj_data.put('flgAdd', true);
            obj_score.put(to_char(v_rcnt-1), obj_data);
        end loop;
    end if;
    
    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('scr_cond', obj_score);
    obj_main.put('act_plan', obj_plan);    
    json_str_output := obj_main.to_clob;
  end;
--

  procedure get_detail_create(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_create(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail_create (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    obj_score       json_object_t;
    obj_plan        json_object_t;

    max_numseq      number;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();

    obj_score       := json_object_t();
    obj_plan        := json_object_t();

    obj_detail.put('coderror', '200');
    obj_detail.put('typkpi', '');
    obj_detail.put('desc_typkpi', '');
    obj_detail.put('codkpi', '');
    obj_detail.put('kpides', '');
    obj_detail.put('target', '');
    obj_detail.put('mtrfinish', '');
    obj_detail.put('pctwgt', '');
    obj_detail.put('targtstr', '');
    obj_detail.put('targtend', '');
    obj_detail.put('flgdefault', '');
    obj_detail.put('codempid', p_codempid_query);
    obj_detail.put('numseq', p_numseq);
    obj_detail.put('staappr', '');
    obj_detail.put('dteyreap', p_dteyear);
    obj_detail.put('numtime', p_numtime);

    obj_main.put('coderror', '200');
    obj_main.put('detail', obj_detail);
    obj_main.put('scr_cond', obj_score);
    obj_main.put('act_plan', obj_plan);

    json_str_output := obj_main.to_clob;
  end;


  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRES17E';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  tkpireq.approvno%type;
    v_routeno             tkpireq.routeno%type;
    v_desc                tkpireq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);
  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';
    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, global_v_codempid);

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
         parameter_v_approvno := parameter_v_approvno + 1;
         p_codappr         := v_codempid_next;
         p_staappr         := 'A';
         p_dteappr         := trunc(sysdate);
         p_remarkap        := v_desc;
         p_approvno        := parameter_v_approvno;
         v_approv          := v_codempid_next;

        begin
          insert into tapkpirq (codempid,dtereq,numseq,approvno,
                                codappr,dteappr,staappr,remark,
                                dteapph,dtesnd,
                                dtecreate,codcreate,dteupd,coduser)
                values         (p_codempid_query, p_dtereq2save, p_numseq, parameter_v_approvno, 
                                v_codempid_next, trunc(sysdate), 'A',v_desc,
                                sysdate,null,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
          update tapkpirq
             set codappr = v_codempid_next,
                 dteappr = trunc(sysdate),
                 staappr = 'A',
                 remark = v_desc,
                 dteapph = sysdate,
                 coduser   = global_v_coduser,
                 dteupd    = sysdate
           where codempid  = p_codempid_query
             and dtereq    = p_dtereq2save
             and numseq    = p_numseq
             and approvno  = parameter_v_approvno;
        end;

        chk_workflow.find_next_approve(v_codapp, v_routeno, global_v_codempid, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, v_codempid_next);
      else
        exit;
      end if;
    end loop;
    p_approvno     := parameter_v_approvno;
    p_routeno      := v_routeno;
  end;  

  procedure save_tkpireq(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
    param_json_row          json_object_t;
    v_flg                   varchar2(100 char);

    v_codcomp               tkpireq.codcomp%type;
    v_codpos                tkpireq2.codpos%type;
    v_objective             tkpireq.objective%type;
    v_flgDefault            varchar2(100 char);

    v_codkpi                tkpireq2.codkpi%type;
    v_kpides                tkpireq2.kpides%type;
    v_mtrfinish             tkpireq2.mtrfinish%type;
    v_pctwgt                tkpireq2.pctwgt%type;
    v_target                tkpireq2.target%type;
    v_targtend              tkpireq2.targtend%type;
    v_targtstr              tkpireq2.targtstr%type;
    v_typkpi                tkpireq2.typkpi%type;
    v_count_kpi             number;                 

	cursor c1 is
        select *
          from tkpidph a , tkpidpemp b 
         where a.dteyreap =  b.dteyreap
           and a.numtime =  b.numtime
           and a.codcomp =  b.codcomp
           and a.codkpino = b.codkpino
           and a.dteyreap = p_dteyear
           and a.numtime = p_numtime
           and b.codempid = p_codempid_query;

	cursor c2 is
        select *
          from tjobkpi
         where codpos = v_codpos
           and codcomp = v_codcomp;

	cursor c3 is
        select *
          from tgradekpi
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteyreap = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteyreap <= to_number(to_char(sysdate,'YYYY'))
                           );
  begin
    json_obj            := json_object_t(json_str_input);
    v_objective	        := hcm_util.get_string_t(json_obj,'p_objective');


    select codcomp,codpos
      into v_codcomp,v_codpos
      from temploy1
     where codempid = p_codempid_query;

    begin
        insert into tkpireq (codempid,dtereq,numseq,dteyreap,numtime,
                             objective,staappr,codappr,dteappr,remarkap,
                             approvno,routeno,codcomp,flgsend,dtecancel,
                             dteinput,dtesnd,dteapph,flgagency,
                             dtecreate,codcreate,dteupd,coduser)
        values ( p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                 v_objective,p_staappr,p_codappr,p_dteappr,p_remarkap,
                 p_approvno,p_routeno,v_codcomp,'N',null,
                 sysdate,null,sysdate,'N',
                 sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tkpireq
           set dteyreap = p_dteyear,
               numtime = p_numtime,
               objective = v_objective,
               staappr = p_staappr,
               codappr = p_codappr,
               dteappr = p_dteappr,
               remarkap = p_remarkap,
               approvno = p_approvno,
               routeno = p_routeno,
               codcomp = v_codcomp,
               flgsend = 'N',
               dtecancel = null,
               dteinput = sysdate,
               dtesnd = null,
               dteapph = sysdate,
               flgagency = 'N',
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dtereq = p_dtereq2save
           and numseq = p_numseq;
    end;

    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');
        v_flgDefault        := hcm_util.get_string_t(param_json_row,'flgDefault');
        v_codkpi            := hcm_util.get_string_t(param_json_row,'codkpi');
        v_kpides            := hcm_util.get_string_t(param_json_row,'kpides');
        v_mtrfinish         := hcm_util.get_string_t(param_json_row,'mtrfinish');
        v_pctwgt            := hcm_util.get_string_t(param_json_row,'pctwgt');
        v_target            := hcm_util.get_string_t(param_json_row,'target');
        v_targtend          := to_date(hcm_util.get_string_t(param_json_row,'targtend'),'dd/mm/yyyy');
        v_targtstr          := to_date(hcm_util.get_string_t(param_json_row,'targtstr'),'dd/mm/yyyy');
        v_typkpi            := hcm_util.get_string_t(param_json_row,'typkpi');

        if v_flg = 'add' then
            begin
                insert into tkpireq2 (codempid,dtereq,numseq,dteyreap,numtime,
                                      codkpi,typkpi,kpides,TARGET,mtrfinish,pctwgt,
                                      targtstr,targtend,codcomp,codpos,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                        v_codkpi,v_typkpi,v_kpides,v_target,v_mtrfinish,v_pctwgt,
                        v_targtstr,v_targtend,v_codcomp,v_codpos,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);               
            exception when dup_val_on_index then
                null;            
            end;
        elsif v_flg = 'delete' then
            delete tkpireq2 
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi;
               
            delete tkpireq3 
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi;
               
            delete tkpireq4 
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi;
        end if;

      end loop;
    end if;

    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_tkpireq;
  --
  procedure post_save(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
  begin
    initial_value(json_str_input);
    p_dtereq2save       := p_dtereq; 

--    check_save(json_str_input);
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_tkpireq(json_str_input ,json_str_output);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_tkpireq_kpi(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
    param_json_row          json_object_t;
    v_flg                   varchar2(100 char);
    return_obj              json_object_t;

    v_codcomp               tkpireq.codcomp%type;
    v_codpos                tkpireq2.codpos%type;
    v_objective             tkpireq.objective%type;
    v_flgDefault            varchar2(100 char);

    v_codkpi                tkpireq2.codkpi%type;
    v_kpides                tkpireq2.kpides%type;
    v_mtrfinish             tkpireq2.mtrfinish%type;
    v_pctwgt                tkpireq2.pctwgt%type;
    v_target                tkpireq2.target%type;
    v_targtend              tkpireq2.targtend%type;
    v_targtstr              tkpireq2.targtstr%type;
    v_typkpi                tkpireq2.typkpi%type;
    v_count_kpi             number;  
    indextable_json         json_object_t;  
    tkpireq3_json           json_object_t;  
    tkpireq4_json           json_object_t;
    detail_json             json_object_t;

    v_grade                 tkpireq4.grade%type;
    v_desgrade              tkpireq4.desgrade%type;
    v_score                 tkpireq4.score%type;
    v_color                 tkpireq4.color%type;
    v_stakpi                tkpireq4.stakpi%type;

    v_planno                tkpireq3.planno%type;
    v_plandes               tkpireq3.plandes%type;
    max_planno              number;
    max_kpi                 number;

	cursor c1 is
        select *
          from tkpidph a , tkpidpemp b 
         where a.dteyreap =  b.dteyreap
           and a.numtime =  b.numtime
           and a.codcomp =  b.codcomp
           and a.codkpino = b.codkpino
           and a.dteyreap = p_dteyear
           and a.numtime = p_numtime
           and b.codempid = p_codempid_query;

	cursor c2 is
        select *
          from tjobkpi
         where codpos = v_codpos
           and codcomp = v_codcomp;

	cursor c3 is
        select *
          from tgradekpi
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteyreap = (select max(dteyreap)
                             from tgradekpi
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteyreap <= to_number(to_char(sysdate,'YYYY'))
                           );
  begin
    json_obj            := json_object_t(json_str_input);
    v_objective	        := hcm_util.get_string_t(json_obj,'p_objective');
    indextable_json     := hcm_util.get_json_t(param_json,'indexDataTable');
    tkpireq4_json       := hcm_util.get_json_t(param_json,'scr_cond');
    tkpireq3_json       := hcm_util.get_json_t(param_json,'act_plan');
    detail_json         := hcm_util.get_json_t(param_json,'detail');

    select codcomp,codpos
      into v_codcomp,v_codpos
      from temploy1
     where codempid = p_codempid_query;

    begin
        insert into tkpireq (codempid,dtereq,numseq,dteyreap,numtime,
                             objective,staappr,codappr,dteappr,remarkap,
                             approvno,routeno,codcomp,flgsend,dtecancel,
                             dteinput,dtesnd,dteapph,flgagency,
                             dtecreate,codcreate,dteupd,coduser)
        values ( p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                 v_objective,p_staappr,p_codappr,p_dteappr,p_remarkap,
                 p_approvno,p_routeno,v_codcomp,'N',null,
                 sysdate,null,sysdate,'N',
                 sysdate, global_v_coduser, sysdate, global_v_coduser);
    exception when dup_val_on_index then
        update tkpireq
           set dteyreap = p_dteyear,
               numtime = p_numtime,
               objective = v_objective,
               staappr = p_staappr,
               codappr = p_codappr,
               dteappr = p_dteappr,
               remarkap = p_remarkap,
               approvno = p_approvno,
               routeno = p_routeno,
               codcomp = v_codcomp,
               flgsend = 'N',
               dtecancel = null,
               dteinput = sysdate,
               dtesnd = null,
               dteapph = sysdate,
               flgagency = 'N',
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dtereq = p_dtereq2save
           and numseq = p_numseq;
    end;

    if indextable_json.get_size > 0 then
      for i in 0..indextable_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(indextable_json,to_char(i));
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');
        v_flgDefault        := hcm_util.get_string_t(param_json_row,'flgDefault');
        v_codkpi            := hcm_util.get_string_t(param_json_row,'codkpi');
        v_kpides            := hcm_util.get_string_t(param_json_row,'kpides');
        v_mtrfinish         := hcm_util.get_string_t(param_json_row,'mtrfinish');
        v_pctwgt            := hcm_util.get_string_t(param_json_row,'pctwgt');
        v_target            := hcm_util.get_string_t(param_json_row,'target');
        v_targtend          := to_date(hcm_util.get_string_t(param_json_row,'targtend'),'dd/mm/yyyy');
        v_targtstr          := to_date(hcm_util.get_string_t(param_json_row,'targtstr'),'dd/mm/yyyy');
        v_typkpi            := hcm_util.get_string_t(param_json_row,'typkpi');

        if v_flg = 'add' then
            begin
                insert into tkpireq2 (codempid,dtereq,numseq,dteyreap,numtime,
                                      codkpi,typkpi,kpides,TARGET,mtrfinish,pctwgt,
                                      targtstr,targtend,codcomp,codpos,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                        v_codkpi,v_typkpi,v_kpides,v_target,v_mtrfinish,v_pctwgt,
                        v_targtstr,v_targtend,v_codcomp,v_codpos,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);               
            exception when dup_val_on_index then
                null;            
            end;
        elsif v_flg = 'delete' then
            delete tkpireq2 
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi;
        end if;

      end loop;
    end if;

    v_codkpi            := hcm_util.get_string_t(detail_json,'codkpi');
    v_kpides            := hcm_util.get_string_t(detail_json,'kpides');
    v_mtrfinish         := hcm_util.get_string_t(detail_json,'mtrfinish');
    v_pctwgt            := hcm_util.get_string_t(detail_json,'pctwgt');
    v_target            := hcm_util.get_string_t(detail_json,'target');
    v_targtend          := to_date(hcm_util.get_string_t(detail_json,'targtend'),'dd/mm/yyyy');
    v_targtstr          := to_date(hcm_util.get_string_t(detail_json,'targtstr'),'dd/mm/yyyy');
    v_typkpi            := hcm_util.get_string_t(detail_json,'typkpi');

    if v_codkpi is null then
        begin
            select max(to_number(substr(codkpi,2,3))) 
              into max_kpi
              from tkpireq2 
             where codempid = p_codempid_query
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and typkpi = 'I';        
        exception when no_data_found then
            max_kpi := 0;
        end;
        max_kpi := nvl(max_kpi,0) + 1;
        v_codkpi := 'I'||lpad(to_number(max_kpi),3,'0');
        v_typkpi := 'I';
    end if;

    begin
        insert into tkpireq2 (codempid,dtereq,numseq,dteyreap,numtime,
                              codkpi,typkpi,kpides,target,mtrfinish,pctwgt,
                              targtstr,targtend,codcomp,codpos,
                              dtecreate,codcreate,dteupd,coduser)
        values (p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                v_codkpi,v_typkpi,v_kpides,v_target,v_mtrfinish,v_pctwgt,
                v_targtstr,v_targtend,v_codcomp,v_codpos,
                sysdate,global_v_coduser,sysdate,global_v_coduser);               
    exception when dup_val_on_index then
        update tkpireq2 
           set typkpi = v_typkpi,
               kpides = v_kpides,
               target = v_target,
               mtrfinish = v_mtrfinish,
               pctwgt = v_pctwgt,
               targtstr = v_targtstr,
               targtend = v_targtend,
               codcomp = v_codcomp,
               codpos = v_codpos,
               coduser = global_v_coduser,
               dteupd = sysdate
         where codempid = p_codempid_query
           and dtereq = p_dtereq2save
           and numseq = p_numseq
           and dteyreap = p_dteyear
           and numtime = p_numtime
           and codkpi = v_codkpi;            
    end;

    for i in 0..tkpireq4_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(tkpireq4_json,to_char(i));
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');
        v_grade             := hcm_util.get_string_t(param_json_row,'grade');
        v_desgrade          := hcm_util.get_string_t(param_json_row,'desgrade');
        v_score             := to_number(hcm_util.get_string_t(param_json_row,'score'));
        v_color             := hcm_util.get_string_t(param_json_row,'color');
        v_kpides            := hcm_util.get_string_t(param_json_row,'kpides');
        v_stakpi            := hcm_util.get_string_t(param_json_row,'stakpi');

        v_mtrfinish         := hcm_util.get_string_t(param_json_row,'mtrfinish');
        v_pctwgt            := hcm_util.get_string_t(param_json_row,'pctwgt');
        v_target            := hcm_util.get_string_t(param_json_row,'target');
        v_targtend          := to_date(hcm_util.get_string_t(param_json_row,'targtend'),'dd/mm/yyyy');
        v_targtstr          := to_date(hcm_util.get_string_t(param_json_row,'targtstr'),'dd/mm/yyyy');
        v_typkpi            := hcm_util.get_string_t(param_json_row,'typkpi');

        if v_flg = 'add' then
            begin
                insert into tkpireq4 (codempid,dtereq,numseq,dteyreap,numtime,
                                      codkpi,grade,desgrade,score,color,kpides,stakpi,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                        v_codkpi,v_grade,v_desgrade,v_score,v_color,v_kpides,v_stakpi,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);             
            exception when dup_val_on_index then
                null;            
            end;
        elsif v_flg = 'edit' then
            update tkpireq4 
               set desgrade = v_desgrade,
                   score = v_score,
                   color = v_color,
                   kpides = v_kpides,
                   stakpi = v_stakpi,
                   coduser = global_v_coduser,
                   dteupd = sysdate
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi
               and grade = v_grade;
        end if;
    end loop;

    for i in 0..tkpireq3_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(tkpireq3_json,to_char(i));
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');
        v_planno            := hcm_util.get_string_t(param_json_row,'planno');
        v_plandes           := hcm_util.get_string_t(param_json_row,'plandes');
        v_targtstr          := to_date(hcm_util.get_string_t(param_json_row,'targtstr'),'dd/mm/yyyy');
        v_targtend          := to_date(hcm_util.get_string_t(param_json_row,'targtend'),'dd/mm/yyyy');

        if v_flg = 'add' then
            begin
                select max(to_number(planno))
                  into max_planno
                  from tkpireq3
                 where codempid  = p_codempid_query
                   and dtereq  = p_dtereq
                   and numseq  = p_numseq
                   and dteyreap = p_dteyear
                   and numtime = p_numtime
                   and codkpi = v_codkpi;            
            exception when no_data_found then
                max_planno := 0;
            end;    

            max_planno      := nvl(max_planno,0) +1 ;

            begin
                insert into tkpireq3 (codempid,dtereq,numseq,dteyreap,numtime,
                                      codkpi,planno,plandes,targtstr,targtend,
                                      dtecreate,codcreate,dteupd,coduser)
                values (p_codempid_query,p_dtereq2save,p_numseq,p_dteyear,p_numtime,
                        v_codkpi,lpad(to_number(max_planno),4,'0'),v_plandes,v_targtstr,v_targtend,
                        sysdate,global_v_coduser,sysdate,global_v_coduser);             
            exception when dup_val_on_index then
                null;            
            end;
        elsif v_flg = 'edit' then
            update tkpireq3 
               set plandes = v_plandes,
                   targtstr = v_targtstr,
                   targtend = v_targtend,
                   coduser = global_v_coduser,
                   dteupd = sysdate
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and dteyreap = p_dteyear
               and numtime = p_numtime
               and codkpi = v_codkpi
               and planno = v_planno;
        end if;
    end loop;

    commit;
    return_obj    := json_object_t();
    return_obj.put('coderror', '200');
    return_obj.put('response', replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201',''));
    return_obj.put('codkpi', v_codkpi);
    return_obj.put('typkpi', v_typkpi);
    json_str_output := return_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_tkpireq_kpi;
  --  
  --
  procedure post_savekpi(json_str_input in clob,json_str_output out clob) as
    json_obj                json_object_t;
  begin
    initial_value(json_str_input);
    p_dtereq2save       := p_dtereq; 

--    check_save(json_str_input);
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_tkpireq_kpi(json_str_input ,json_str_output);
    end if;
    if param_msg_error is null then
--      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      commit;
      return;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  

  procedure save_cancel(json_str_input in clob,json_str_output out clob) as
  begin
    update tkpireq
       set staappr = 'C',
           dtecancel = sysdate,
           coduser = global_v_coduser,
           dteupd = sysdate
     where codempid = p_codempid_query
       and dtereq = p_dtereq
       and numseq = p_numseq;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end save_cancel;
  --
  procedure post_cancel(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_cancel(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;  

  procedure get_lov(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_lov(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure gen_lov (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    v_codpos        tjobkpi.codpos%type;
    v_codcomp       tjobkpi.codcomp%type;

	cursor c1 is
        select a.codkpino codkpi,a.kpides , 'D' typkpi 
          from tkpidph a , tkpidpemp b 
         where a.dteyreap =  b.dteyreap
           and a.numtime =  b.numtime
           and a.codcomp =  b.codcomp
           and a.codkpino = b.codkpino
           and a.dteyreap = p_dteyear
           and a.numtime = p_numtime
           and b.codempid = p_codempid_query
         union 
        select codkpi,kpiitem,'J' typkpi
          from tjobkpi
         where codpos = v_codpos
           and codcomp = v_codcomp
         union 
        select codkpi, kpides, typkpi
          from tkpireq2
         where dteyreap = p_dteyear
           and numtime = p_numtime
           and codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq =  p_numseq
      order by codkpi;

  begin

    select codpos,codcomp
      into v_codpos,v_codcomp
      from temploy1
     where codempid = p_codempid_query;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codkpi', r1.codkpi);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('typkpi', r1.typkpi);
        obj_data.put('desc_typkpi', get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;


  procedure get_jobKpi(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_jobKpi(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure gen_jobKpi (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    v_codpos        tjobkpi.codpos%type;
    v_codcomp       tjobkpi.codcomp%type;

	cursor c1 is
        select codkpi,kpiitem kpides,'J' typkpi,target,kpivalue mtrfinish
          from tjobkpi
         where codpos = v_codpos
           and codcomp = v_codcomp
      order by codkpi;
  begin

    select codpos,codcomp
      into v_codpos,v_codcomp
      from temploy1
     where codempid = p_codempid_query;

    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codkpi', r1.codkpi);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('typkpi', r1.typkpi);
        obj_data.put('desc_typkpi', get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_data.put('target', r1.target);
        obj_data.put('mtrfinish', r1.mtrfinish);
        obj_data.put('pctwgt', 0);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;  
end;

/

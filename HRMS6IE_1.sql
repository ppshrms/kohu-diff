--------------------------------------------------------
--  DDL for Package Body HRMS6IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS6IE" is
-- last update: 26/07/2016 13:16

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_registeren        := hcm_util.get_string_t(json_obj,'p_registeren');
    p_registerst        := hcm_util.get_string_t(json_obj,'p_registerst');
    p_latitude          := hcm_util.get_string_t(json_obj,'p_latitude');
    p_longitude         := hcm_util.get_string_t(json_obj,'p_longitude');
    param_json          := hcm_util.get_json_t(json_obj,'param_json');

    p_dtereqst          := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'ddmmyyyy');
    p_dtereqen          := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'ddmmyyyy');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_numclseq          := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');
    p_flgConfirm        := hcm_util.get_string_t(json_obj,'p_flgconfirm');
  end initial_value;
  --
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
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
    v_codhotel      tyrtrsch.codhotel%type;
    v_timstrt       ttrsched.timstrt%type;
    v_timend        ttrsched.timend%type;
    v_latitude      thotelif.latitude%type;
    v_longitude     thotelif.longitude%type;
    v_radius        thotelif.radius%type;

    v_tpotentpd     tpotentpd%rowtype;
    v_next_codappr  varchar2(1000);

	cursor c1 is
		select a.*,b.codhotel
          from tpotentp a, tyrtrsch b, ttpotent c
         where a.codempid = nvl(p_codempid_query,a.codempid)
           and a.codcomp like p_codcomp||'%' 
           and a.dteyear = b.dteyear
           and a.codcompy = b.codcompy
           and a.codcours = b.codcours
           and a.numclseq = b.numclseq
           and a.dteyear = c.dteyear
           and a.codcompy = c.codcompy
           and a.codcours = c.codcours
           and a.codempid = c.codempid
           and b.staemptr = '2'
           and a.dteregis is null
           and trunc(sysdate) between b.dteregst and b.dteregen
           and not exists (select x.codempid
                             from ttrnreq x
                            where x.staappr in ('P','A','Y')
                              and x.codempid = a.codempid
                              and x.codcours = b.codcours
                              and x.numclseq = b.numclseq
                              and x.dteyear = c.dteyear )
      order by a.dtetrst;

	cursor c2 is
		select *
          from ttrnreq
         where codinput = global_v_codempid
           and dtereq between p_dtereqst and p_dtereqen
           and codempid = nvl(p_codempid_query,codempid)
           and codcomp like p_codcomp||'%' 
      order by dtereq desc,numseq desc;
  begin
    v_rcnt := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numseq', '');
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', '');
        obj_data.put('desc_course', get_tcourse_name(r1.codcours,global_v_lang));
        obj_data.put('place', get_thotelif_name(r1.codhotel,global_v_lang));
        obj_data.put('dtetrst', to_char(r1.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(r1.dtetren,'dd/mm/yyyy'));
        obj_data.put('cod_place', r1.codhotel);
        obj_data.put('waiting_list', 'Yes');
        obj_data.put('status', get_label_name('HRES6IEC1',global_v_lang,130));
        obj_data.put('remark', '');
        obj_data.put('remarkap', '');
        obj_data.put('codappr', '');
        obj_data.put('next_codappr', '');
        obj_data.put('staappr', '');
        obj_data.put('flgconfirm', 'Y');
        obj_data.put('dteyear', r1.dteyear);
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('numclseq', to_char(r1.numclseq));
        obj_data.put('codcours', r1.codcours);
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;
    for r2 in c2 loop
        v_rcnt      := v_rcnt +1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numseq', r2.numseq);
        obj_data.put('codempid', r2.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r2.dtereq,'dd/mm/yyyy'));
        if r2.namcourse is not null then
            obj_data.put('desc_course', r2.namcourse);
        else
            obj_data.put('desc_course', get_tcourse_name(r2.codcours,global_v_lang));
        end if;

        if r2.namhotel is not null then
            obj_data.put('place', r2.namhotel);
        else
            obj_data.put('place', get_thotelif_name(r2.codhotel,global_v_lang));
        end if;

        v_next_codappr := chk_workflow.get_next_approve('HRES6IE',r2.codempid,to_char(r2.dtereq,'dd/mm/yyyy'),
                                        r2.numseq, r2.approvno,global_v_lang);

        obj_data.put('dtetrst', to_char(r2.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(r2.dtetren,'dd/mm/yyyy'));
        obj_data.put('cod_place', r2.codhotel);
        obj_data.put('waiting_list', 'Yes');
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r2.staappr,global_v_lang));
        obj_data.put('remark', r2.remark);
        obj_data.put('remarkap', r2.remarkap);
        obj_data.put('codappr', r2.codappr || ' - ' || get_temploy_name(r2.codappr,global_v_lang));
        obj_data.put('next_codappr', v_next_codappr);
        obj_data.put('staappr', r2.staappr);
        obj_data.put('flgconfirm', 'N');   
        obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;
  --

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        if p_numseq = 0 then
            gen_detail_create(json_str_output);
        else
            gen_detail(json_str_output);
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_detail (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_qtytrhur      tcourse.qtytrhur%type;
    v_coddevp       tcourse.coddevp%type;
    v_objective     tobjemp.objective%type;
    v_codhotel      tyrtrsch.codhotel%type;
    v_timstrt       ttrsched.timstrt%type;
    v_timend        ttrsched.timend%type;
    v_latitude      thotelif.latitude%type;
    v_longitude     thotelif.longitude%type;
    v_radius        thotelif.radius%type;

    v_tpotentpd     tpotentpd%rowtype;
    v_tyrtrsch      tyrtrsch%rowtype;
    v_next_codappr  varchar2(1000);

    v_thistrnn      thistrnn%rowtype;
    v_plancond      tyrtrpln.plancond%type;
    max_numseq      number;
    v_flg_thistrnn  boolean;

	cursor c1 is
		select a.codcours,a.codcompy,a.dteyear,a.codempid,
               b.codhotel, b.timestr, b.timeend, b.dteregst, b.dteregen,
               b.qtytrmin, b.amttremp , b.staemptr, b.codinsts, b.costcent,
               b.dtetren,b.dtetrst,a.numclseq,a.codtparg,a.codcomp
          from tpotentp a, tyrtrsch b, ttpotent c
         where a.codempid = p_codempid_query
           and a.dteyear = p_dteyear
           and a.codcompy = p_codcompy
           and a.numclseq = p_numclseq
           and a.codcours = p_codcours
           and a.dteyear = b.dteyear
           and a.codcompy = b.codcompy
           and a.codcours = b.codcours
           and a.numclseq = b.numclseq
           and a.dteyear = c.dteyear
           and a.codcompy = c.codcompy
           and a.codcours = c.codcours
           and a.codempid = c.codempid;

	cursor c2 is
		select *
          from ttrnreq
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;

    cursor c3 is       
        select *
          from ttrnreqf
         where codempid  = p_codempid_query
           and dtereq  = p_dtereq
           and numseq  = p_numseq;  

    cursor c4 is
        select *
          from thistrnn
         where codempid = p_codempid_query
           and codcours = p_codcours
      order by dtetrst desc, numclseq desc;    
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();
    v_flg_thistrnn := false;

    for r4 in c4 loop
        v_thistrnn.dtetrst  := r4.dtetrst;
        v_thistrnn.dtetren  := r4.dtetren;
        v_thistrnn.numclseq := r4.numclseq;
        v_flg_thistrnn      := true;
        exit;
    end loop;

    if p_flgConfirm = 'Y' then
        for r1 in c1 loop
            begin
                select plancond 
                  into v_plancond
                  from tyrtrpln
                 where dteyear = r1.dteyear
                   and codcompy = r1.codcompy
                   and codcours = r1.codcours;
            exception when no_data_found then
                v_plancond := null;
            end;

            begin
                select max(numseq)
                  into max_numseq
                  from ttrnreq
                 where codempid = p_codempid_query
                   and dtereq = trunc(sysdate);
            exception when others then
                max_numseq := 0;
            end;

            max_numseq := nvl(max_numseq,0) + 1;   

            obj_detail.put('coderror', '200');
            obj_detail.put('codempid', r1.codempid);
            obj_detail.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
            obj_detail.put('numseq', max_numseq);
            obj_detail.put('codcours', r1.codcours);
            obj_detail.put('dtetrst', to_char(r1.dtetrst,'dd/mm/yyyy'));
            obj_detail.put('dtetren', to_char(r1.dtetren,'dd/mm/yyyy'));
            obj_detail.put('amtbudg', r1.amttremp);
            obj_detail.put('remark', '');
            obj_detail.put('codhotel', r1.codhotel);
            obj_detail.put('numclseq', to_char(r1.numclseq));
            obj_detail.put('namcourse', get_tcourse_name(r1.codcours,global_v_lang));
            obj_detail.put('staappr', '');
            obj_detail.put('codinsts', r1.codinsts);
            obj_detail.put('codinput', global_v_codempid);
            obj_detail.put('filename', '');
            obj_detail.put('desc_codcours', '');
            obj_detail.put('desc_codhotel', get_thotelif_name(r1.codhotel,global_v_lang));
            obj_detail.put('desc_codinsts', get_tinstitu_name(r1.codinsts, global_v_lang));
            obj_detail.put('name_codinput', '');
            obj_detail.put('codtparg', r1.codtparg);
            if v_flg_thistrnn then 
                obj_detail.put('attend', 'Y');
            else
                obj_detail.put('attend', 'N');
            end if;
            obj_detail.put('dtetrsto', to_char(v_thistrnn.dtetrst,'dd/mm/yyyy'));
            obj_detail.put('dtetreno', to_char(v_thistrnn.dtetren,'dd/mm/yyyy'));
            obj_detail.put('source', get_tlistval_name('STACOURS',v_plancond,global_v_lang));
            obj_detail.put('otrain', r1.staemptr);
            obj_detail.put('numclseq1', to_char(v_thistrnn.numclseq));
            obj_detail.put('dteregisst', to_char(r1.dteregst,'dd/mm/yyyy'));
            obj_detail.put('dteregisen', to_char(r1.dteregen,'dd/mm/yyyy'));
            obj_detail.put('daysum', '');
            obj_detail.put('coscent', r1.costcent);
            obj_detail.put('timst', to_char(to_date(r1.timestr,'hh24:mi'),'hh24mi'));
            obj_detail.put('timen', to_char(to_date(r1.timeend,'hh24:mi'),'hh24mi'));
            obj_detail.put('dtepay', '');
            obj_detail.put('qtyhour', trunc(r1.qtytrmin/60)||':'||lpad(mod(r1.qtytrmin,60),2,'0'));
            obj_detail.put('dteyear', r1.dteyear);
            obj_detail.put('flgconfirm',p_flgConfirm);
            obj_detail.put('codcompy', r1.codcompy);
            obj_detail.put('codcomp', r1.codcomp);
            obj_detail.put('flgreq', '1');
        end loop;
    else
        for r2 in c2 loop
            begin
                select plancond 
                  into v_plancond
                  from tyrtrpln
                 where dteyear = r2.dteyear
                   and codcompy = hcm_util.get_codcomp_level(r2.codcomp,1)
                   and codcours = r2.codcours;
            exception when no_data_found then
                v_plancond := null;
            end;

            begin
                select * 
                  into v_tyrtrsch
                  from tyrtrsch
                 where dteyear = r2.dteyear
                   and codcompy = hcm_util.get_codcomp_level(r2.codcomp,1)
                   and codcours = r2.codcours
                   and numclseq = r2.numclseq;
            exception when no_data_found then
                v_tyrtrsch := null;
            end;    
            obj_detail.put('coderror', '200');
            obj_detail.put('codempid', r2.codempid);
            obj_detail.put('dtereq', to_char(r2.dtereq,'dd/mm/yyyy'));
            obj_detail.put('numseq', r2.numseq);
            obj_detail.put('codcours', r2.codcours);
            obj_detail.put('dtetrst', to_char(r2.dtetrst,'dd/mm/yyyy'));
            obj_detail.put('dtetren', to_char(r2.dtetren,'dd/mm/yyyy'));
            obj_detail.put('amtbudg', r2.amttremp);
            obj_detail.put('remark', r2.remark);
            obj_detail.put('codhotel', r2.codhotel);
            obj_detail.put('numclseq', to_char(r2.numclseq));
            if r2.codcours is not null then
                obj_detail.put('namcourse', get_tcourse_name(r2.codcours,global_v_lang));
            else
                obj_detail.put('namcourse', r2.namcourse);
            end if;
            obj_detail.put('staappr', r2.staappr);
            obj_detail.put('codinsts', r2.codinsts);
            obj_detail.put('codinput', r2.codinput);
            obj_detail.put('filename', '');
            if r2.codcours is null then
                obj_detail.put('desc_codcours', r2.namcourse);
            else
                obj_detail.put('desc_codcours', get_tcourse_name(r2.codcours,global_v_lang));
            end if;

            if r2.codhotel is null then
                obj_detail.put('desc_codhotel', r2.namhotel);
            else
                obj_detail.put('desc_codhotel', get_thotelif_name(r2.codhotel,global_v_lang));
            end if;

            if r2.codinsts is null then
                obj_detail.put('desc_codinsts', r2.naminsts);
            else
                obj_detail.put('desc_codinsts', get_tinstitu_name(r2.codinsts, global_v_lang));
            end if;
            obj_detail.put('name_codinput', get_temploy_name(r2.codinput,global_v_lang));
            obj_detail.put('codtparg', r2.codtparg);
            if v_flg_thistrnn then 
                obj_detail.put('attend', 'Y');
            else
                obj_detail.put('attend', 'N');
            end if;
            obj_detail.put('dtetrsto', to_char(v_thistrnn.dtetrst,'dd/mm/yyyy'));
            obj_detail.put('dtetreno', to_char(v_thistrnn.dtetren,'dd/mm/yyyy'));
            obj_detail.put('source', get_tlistval_name('STACOURS',v_plancond,global_v_lang));
            obj_detail.put('otrain', r2.staemptr);
            obj_detail.put('numclseq1', to_char(v_thistrnn.numclseq));
            obj_detail.put('dteregisst', to_char(v_tyrtrsch.dteregst,'dd/mm/yyyy'));
            obj_detail.put('dteregisen', to_char(v_tyrtrsch.dteregen,'dd/mm/yyyy'));
            obj_detail.put('daysum', r2.qtytrflw);
            obj_detail.put('coscent', r2.costcent);
            obj_detail.put('timst', to_char(to_date(r2.timestr,'hh24:mi'),'hh24mi'));
            obj_detail.put('timen', to_char(to_date(r2.timeend,'hh24:mi'),'hh24mi'));
            obj_detail.put('dtepay', to_char(r2.dteduepay,'dd/mm/yyyy'));
            obj_detail.put('qtyhour', trunc(r2.qtytrmin/60)||':'||lpad(mod(r2.qtytrmin,60),2,'0'));
            obj_detail.put('dteyear', r2.dteyear);
            obj_detail.put('flgconfirm',p_flgConfirm);
            obj_detail.put('codcompy', hcm_util.get_codcomp_level(r2.codcomp,1));
            obj_detail.put('codcomp', r2.codcomp);
            obj_detail.put('flgreq', r2.flgreq);
        end loop; 

        v_rcnt := 0;
        for r3 in c3 loop
            v_rcnt      := v_rcnt +1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('seqno', r3.seqno);
            obj_data.put('filename', r3.filename);
            obj_data.put('descfile', r3.descfile);
            obj_data.put('flgattach', '');
            obj_row.put(to_char(v_rcnt-1), obj_data);
        end loop;
    end if;

    obj_main.put('coderror', '200');  
    obj_main.put('detail', obj_detail);    
    obj_main.put('table', obj_row);  
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

  procedure gen_detail_create (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_costcent      tcenter.costcent%type;
    v_codcomp       temploy1.codcomp%type;

    max_numseq      number;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();
    begin
        select max(numseq)
          into max_numseq
          from ttrnreq
         where codempid = p_codempid_query
           and dtereq = trunc(sysdate);
    exception when others then
        max_numseq  := 0;
    end;

    max_numseq := nvl(max_numseq,0) + 1;

    begin 
        select codcomp
          into v_codcomp
          from temploy1 
         where codempid = p_codempid_query;
    exception when others then
        v_codcomp  := null;
    end;

    begin 
        select costcent 
          into v_costcent
          from tcenter
         where codcomp = v_codcomp
           and rownum <= 1
      order by codcomp;
    exception when others then
        v_costcent  := null;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('codempid', p_codempid_query);
    obj_detail.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
    obj_detail.put('numseq', max_numseq);
    obj_detail.put('codcours', '');
    obj_detail.put('dtetrst', '');
    obj_detail.put('dtetren', '');
    obj_detail.put('amtbudg', '');
    obj_detail.put('remark', '');
    obj_detail.put('codhotel', '');
    obj_detail.put('numclseq', '');
    obj_detail.put('namcourse', '');
    obj_detail.put('staappr', '');
    obj_detail.put('codinsts', '');
    obj_detail.put('codinput', global_v_codempid);
    obj_detail.put('filename', '');
    obj_detail.put('desc_codcours', '');
    obj_detail.put('desc_codhotel', '');
    obj_detail.put('desc_codinsts', '');
    obj_detail.put('name_codinput', '');
    obj_detail.put('codtparg', '1');
    obj_detail.put('attend', '');
    obj_detail.put('dtetrsto', '');
    obj_detail.put('dtetreno', '');
    obj_detail.put('source', '');
    obj_detail.put('otrain', '1');
    obj_detail.put('numclseq1', '');
    obj_detail.put('dteregisst', '');
    obj_detail.put('dteregisen', '');
    obj_detail.put('daysum', '');
    obj_detail.put('coscent', v_costcent);
    obj_detail.put('coscent_def', v_costcent);
    obj_detail.put('timst', '');
    obj_detail.put('timen', '');
    obj_detail.put('dtepay', '');
    obj_detail.put('qtyhour', '');
    obj_detail.put('dteyear', to_char(sysdate,'yyyy'));
    obj_detail.put('codcompy', hcm_util.get_codcomp_level(v_codcomp,1));
    obj_detail.put('codcomp', v_codcomp);

    obj_main.put('coderror', '200');  
    obj_main.put('detail', obj_detail);    
    obj_main.put('table', obj_row);  
    json_str_output := obj_main.to_clob;
  end;


  procedure get_codcours(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_codcours(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_codcours (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    max_numseq      number;
    v_flg_thistrnn  boolean;
    v_thistrnn      thistrnn%rowtype;

    cursor c1 is
        select *
          from thistrnn
         where codempid = p_codempid_query
           and codcours = p_codcours
      order by dtetrst desc, numclseq desc;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();
    v_flg_thistrnn := false; 

    for r1 in c1 loop
        v_thistrnn.dtetrst  := r1.dtetrst;
        v_thistrnn.dtetren  := r1.dtetren;
        v_thistrnn.numclseq := r1.numclseq;
        v_flg_thistrnn      := true;
        exit;
    end loop;

    obj_detail.put('coderror', '200');
    if v_flg_thistrnn then 
        obj_detail.put('attend', 'Y');
    else
        obj_detail.put('attend', 'N');
    end if;
    obj_detail.put('dtetrsto', to_char(v_thistrnn.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetreno', to_char(v_thistrnn.dtetren,'dd/mm/yyyy'));
    obj_detail.put('numclseq1', to_char(v_thistrnn.numclseq));

    json_str_output := obj_detail.to_clob;
  end;

  procedure get_numclseq(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_numclseq(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_numclseq (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_main        json_object_t;
    v_numseq        number := 0;
    v_rcnt          number := 0;

    max_numseq      number;
    v_flg_thistrnn  boolean;
    v_tyrtrsch      tyrtrsch%rowtype;
    v_codcompy      tcompny.codcompy%type;
  begin
    v_rcnt := 0;
    obj_main        := json_object_t();
    obj_row         := json_object_t();
    obj_detail      := json_object_t();

    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = p_codempid_query;
    exception when no_data_found then
        v_codcompy := null;
    end;

    begin
        select *
          into v_tyrtrsch
          from tyrtrsch
         where numclseq = p_numclseq
           and codcours = p_codcours
           and dteyear = to_char(sysdate,'YYYY')
           and codcompy = v_codcompy
      order by dtetrst desc;     
        v_flg_thistrnn := true;
    exception when no_data_found then
        v_tyrtrsch      := null;
    end;

    obj_detail.put('coderror', '200');
    obj_detail.put('codcours',p_codcours);
    obj_detail.put('dtetrst', to_char(v_tyrtrsch.dtetrst,'dd/mm/yyyy'));
    obj_detail.put('dtetren', to_char(v_tyrtrsch.dtetren,'dd/mm/yyyy'));
    obj_detail.put('timst', v_tyrtrsch.timestr);
    obj_detail.put('timen', v_tyrtrsch.timeend);
    obj_detail.put('qtyhour', trunc(v_tyrtrsch.qtytrmin/60)||':'||lpad(mod(v_tyrtrsch.qtytrmin,60),2,'0'));
    obj_detail.put('dteregisst', to_char(v_tyrtrsch.dteregst,'dd/mm/yyyy'));
    obj_detail.put('dteregisen', to_char(v_tyrtrsch.dteregen,'dd/mm/yyyy'));
    obj_detail.put('desc_codhotel', get_thotelif_name(v_tyrtrsch.codhotel,global_v_lang));
    obj_detail.put('desc_codinsts', get_tinstitu_name(v_tyrtrsch.codinsts, global_v_lang));
    obj_detail.put('amtbudg', v_tyrtrsch.amttremp);
    obj_detail.put('daysum', '');
    obj_detail.put('coscent', v_tyrtrsch.costcent);

    json_str_output := obj_detail.to_clob;
  end;  


  procedure insert_next_step IS
    v_codapp              varchar2(10 char) := 'HRES6IE';
    v_codempid_next       temploy1.codempid%type;
    v_approv              temploy1.codempid%type;
    parameter_v_approvno  ttrnreq.approvno%type;
    v_routeno             ttrnreq.routeno%type;
    v_desc                ttrnreq.remarkap%type := substr(get_label_name('HCM_APPRFLW',global_v_lang,10), 1, 200);
    v_table               varchar2(50 char);
    v_error               varchar2(50 char);
  begin
    parameter_v_approvno  :=  0;
    --
    p_dtecancel           := null;
    p_staappr             := 'P';

    chk_workflow.find_next_approve(v_codapp, v_routeno, p_codempid_query, to_char(p_dtereq2save, 'dd/mm/yyyy'), p_numseq, parameter_v_approvno, global_v_codempid,p_codtparg);

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
          insert into taptrnrq (codempid,dtereq,numseq,
                                approvno, codappr, dteappr,
                                dteyear, codcompy,codcours,numclseq,
                                staappr,remark,
                                dteapph,dtesnd,
                                dtecreate,codcreate,dteupd,coduser)
                values         (global_v_codempid, p_dtereq2save, p_numseq,
                                parameter_v_approvno, v_codempid_next, trunc(sysdate), 
                                p_dteyear,p_codcompy,p_codcours,p_numclseq,
                                'A', v_desc, 
                                sysdate, null,
                                sysdate,global_v_coduser,sysdate,global_v_coduser);
        exception when dup_val_on_index then
          update taptrnrq
             set codappr   = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 dteyear = p_dteyear,
                 codcompy = p_codcompy,
                 codcours = p_codcours,
                 numclseq = p_numclseq,
                 staappr   = 'A',
                 remark    = v_desc,
                 dteapph   = sysdate,
                 coduser   = global_v_coduser,
                 dteupd    = sysdate
           where codempid  = global_v_codempid
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

  procedure save_ttrnreq(json_str_input in clob,json_str_output out clob) as
    param_json_row          json_object_t;
    param_json_child        json_object_t;
    param_json_row_child    json_object_t;
    file_json               json_object_t;
    v_flg                   varchar2(100 char);

    v_numseq                ttrnreq.numseq%type;
    v_dtetrst               ttrnreq.dtetrst%type;
    v_dtetren               ttrnreq.dtetren%type;
    v_amtbudg               ttrnreq.amttremp%type;
    v_remark                ttrnreq.remark%type;
    v_codhotel              ttrnreq.codhotel%type;
    v_desc_course           ttrnreq.namcourse%type;
    v_staappr               ttrnreq.staappr%type;
    v_codinsts              ttrnreq.codinsts%type;
    v_codinput              ttrnreq.codinput%type;
    v_place                 ttrnreq.namhotel%type;
    v_desc_codinsts         ttrnreq.naminsts%type;
    v_codtparg              ttrnreq.codtparg%type;
    v_codcomp               ttrnreq.codcomp%type;
    v_qtytrflw              ttrnreq.qtytrflw%type;
    v_dteduepay             ttrnreq.dteduepay%type;
    v_costcent              ttrnreq.costcent%type;
    v_staemptr              ttrnreq.staemptr%type;
    v_flgreq                ttrnreq.flgreq%type;
    v_filename              ttrnreqf.filename%type;
    v_descfile              ttrnreqf.descfile%type;
    v_seqno                 ttrnreqf.seqno%type;
    v_qtytrmin              ttrnreq.qtytrmin%type;
    v_timeend               ttrnreq.timeend%type;
    v_timestr               ttrnreq.timestr%type;

  begin
    file_json           := hcm_util.get_json_t(param_json,'table');
    v_dtetrst	        := to_date(hcm_util.get_string_t(param_json,'dtetrst'),'dd/mm/yyyy');
    v_dtetren	        := to_date(hcm_util.get_string_t(param_json,'dtetren'),'dd/mm/yyyy');
    v_amtbudg	        := hcm_util.get_string_t(param_json,'amtbudg');
    v_remark	        := hcm_util.get_string_t(param_json,'remark');
    v_codhotel	        := hcm_util.get_string_t(param_json,'codhotel');
    v_desc_course	    := hcm_util.get_string_t(param_json,'desc_course');
    v_staappr	        := hcm_util.get_string_t(param_json,'staappr');
    v_codinsts	        := hcm_util.get_string_t(param_json,'codinsts');
    v_codinput	        := hcm_util.get_string_t(param_json,'codinput');
    v_place	            := hcm_util.get_string_t(param_json,'place');
    v_desc_codinsts	    := hcm_util.get_string_t(param_json,'desc_codinsts');

    p_flgConfirm	    := hcm_util.get_string_t(param_json,'flgconfirm');
    v_codcomp	        := hcm_util.get_string_t(param_json,'codcomp');
    v_costcent          := hcm_util.get_string_t(param_json,'coscent');

    v_qtytrflw          := hcm_util.get_string_t(param_json,'qtytrflw');
    v_dteduepay         := to_date(hcm_util.get_string_t(param_json,'dteduepay'),'dd/mm/yyyy');
    v_staemptr          := hcm_util.get_string_t(param_json,'staemptr');
    v_qtytrmin          := hcm_util.convert_hour_to_minute (hcm_util.get_string_t(param_json,'qtytrmin'));
    v_timeend           := replace(hcm_util.get_string_t(param_json,'timeend'),':','');
    v_timestr           := replace(hcm_util.get_string_t(param_json,'timestr'),':','');

    if p_flgConfirm = 'Y' then
        v_flgreq := '1';
    else
        v_flgreq := '2';
    end if;

    begin
        insert into ttrnreq (codempid,dtereq,numseq,
                             codcomp,codtparg,codcours,namcourse,numclseq,
                             dteyear,flgreq,staemptr,dtetrst,dtetren,
                             namhotel,naminsts,codhotel,codinsts,amttremp,
                             qtytrflw,costcent,remark,codappr,dteappr,
                             remarkap,approvno,staappr,dteyrtr,numseqtr,
                             routeno,flgsend,codinput,dteinput,dtesnd,
                             dteapph,flgagency,dteduepay,
                             qtytrmin,timeend,timestr,
                             dtecreate,codcreate,dteupd,coduser)
        values ( p_codempid_query,p_dtereq,p_numseq,
                 v_codcomp,p_codtparg,p_codcours,v_desc_course,p_numclseq,
                 p_dteyear,v_flgreq,v_staemptr,v_dtetrst,v_dtetren,
                 v_place,v_desc_codinsts,v_codhotel,v_codinsts,v_amtbudg,
                 v_qtytrflw,v_costcent,v_remark,p_codappr,p_dteappr,
                 p_remarkap,p_approvno,p_staappr,null,null,
                 p_routeno,null,v_codinput,sysdate,null,
                 sysdate,null,v_dteduepay,
                 v_qtytrmin,v_timeend,v_timestr,
                 sysdate,global_v_coduser,sysdate,global_v_coduser);
    exception when dup_val_on_index then
        update ttrnreq
           set codtparg = p_codtparg,
               codcours = p_codcours,
               namcourse = v_desc_course,
               numclseq = p_numclseq,
               dteyear = p_dteyear,
               flgreq = v_flgreq,
               staemptr = v_staemptr,
               dtetrst = v_dtetrst,
               dtetren = v_dtetren,
               namhotel = v_place,
               naminsts = v_desc_codinsts,
               codhotel = v_codhotel,
               codinsts = v_codinsts,
               amttremp = v_amtbudg,
               qtytrflw = v_qtytrflw,
               costcent = v_costcent,
               remark = v_remark,
               codappr = p_codappr,
               dteappr = p_dteappr,
               remarkap = p_remarkap,
               approvno = p_approvno,
               staappr = p_staappr,
               routeno = p_routeno,
               codinput = v_codinput,
               dteinput = sysdate,
               dteapph = sysdate,
               dteduepay = v_dteduepay,
               qtytrmin = v_qtytrmin,
               timeend = v_timeend,
               timestr = v_timestr,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codempid = p_codempid_query
           and dtereq = p_dtereq
           and numseq = p_numseq;
    end;

    if file_json.get_size > 0 then
      for i in 0..file_json.get_size-1 loop
        param_json_row      := hcm_util.get_json_t(file_json,to_char(i));
        v_flg               := hcm_util.get_string_t(param_json_row,'flg');
        v_filename          := hcm_util.get_string_t(param_json_row,'filename');
        v_descfile          := hcm_util.get_string_t(param_json_row,'descfile');
        v_seqno             := hcm_util.get_string_t(param_json_row,'seqno');

        if v_flg = 'add' then
            begin
                select max(seqno)
                  into v_seqno
                  from ttrnreqf
                 where codempid  = p_codempid_query
                   and dtereq  = p_dtereq
                   and numseq  = p_numseq;
            exception when no_data_found then
                v_seqno := 0;
            end;
            v_seqno := nvl(v_seqno,0) + 1;
            insert into ttrnreqf (codempid,dtereq,numseq,seqno,
                                  filename,descfile,
                                  dtecreate,codcreate,dteupd,coduser)
            values (p_codempid_query,p_dtereq,p_numseq,v_seqno,
                    v_filename,v_descfile,
                    sysdate,global_v_coduser,sysdate,global_v_coduser);        
        elsif v_flg = 'edit' then
            update ttrnreqf 
               set filename = v_filename,
                   descfile = v_descfile,
                   dteupd = sysdate,
                   coduser = global_v_coduser
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and seqno = v_seqno;    
        elsif v_flg = 'delete' then
            delete ttrnreqf 
             where codempid  = p_codempid_query
               and dtereq  = p_dtereq
               and numseq  = p_numseq
               and seqno = v_seqno;
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
  end save_ttrnreq;
  --

  procedure check_save as
    v_temp   varchar(1 char);
  begin
     if p_numclseq <> 0 then
        begin
            select 'X' 
              into v_temp
              from tyrtrsch
             where codcours = p_codcours
               and dteyear = p_dteyear
               and numclseq = p_numclseq
               and codcompy = p_codcompy
               and staemptr = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tyrtrsch');
            return;
        end;

        begin
            select 'X' 
              into v_temp
              from thisclss
             where codcours = p_codcours
               and dteyear = p_dteyear
               and numclseq = p_numclseq
               and codcompy = p_codcompy;
            param_msg_error := get_error_msg_php('ES0023',global_v_lang);
            return;
        exception when no_data_found then
            null;
        end;

        begin
            select 'X' 
              into v_temp
              from tpotentp
             where codcours = p_codcours
               and dteyear = p_dteyear
               and numclseq = p_numclseq
               and codcompy = p_codcompy
               and codempid = p_codempid_query;
            param_msg_error := get_error_msg_php('ES0060',global_v_lang);
            return;
        exception when no_data_found then
            null;
        end;
     end if;
  end check_save;  

  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    p_codempid_query	:= hcm_util.get_string_t(param_json,'codempid');
    p_dtereq	        := to_date(hcm_util.get_string_t(param_json,'dtereq'),'dd/mm/yyyy');
    p_codcours	        := hcm_util.get_string_t(param_json,'codcours');
    p_numclseq	        := hcm_util.get_string_t(param_json,'numclseq');
    p_dteyear	        := hcm_util.get_string_t(param_json,'dteyear');
    p_codcompy	        := hcm_util.get_string_t(param_json,'codcompy');
    p_dtereq2save       := p_dtereq;    
    p_numseq            := hcm_util.get_string_t(param_json,'numseq');
    p_codtparg	        := hcm_util.get_string_t(param_json,'codtparg');
    check_save;
    if param_msg_error is null then
      insert_next_step;
    end if;
    if param_msg_error is null then
      save_ttrnreq(json_str_input ,json_str_output);
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

  procedure save_cancel(json_str_input in clob,json_str_output out clob) as
  begin
    update ttrnreq
       set staappr = 'C',
           dtecancel = sysdate
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

end;

/

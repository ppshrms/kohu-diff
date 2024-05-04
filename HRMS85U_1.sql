--------------------------------------------------------
--  DDL for Package Body HRMS85U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS85U" is
-- last update: 27/09/2022 10:44

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    -- global value
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    -- block value
    json_obj              := json_object_t(json_str);
    p_dtest               := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen               := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr             := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid            := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq              := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq              := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_approvno            := to_number(hcm_util.get_string_t(json_obj,'p_approvno'));
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;
  --
  function call_formattime(ptime varchar2) return varchar2 is
    v_time varchar2(20 char);
    hh     varchar2(2 char);
    mm     varchar2(2 char);
  begin
    v_time := ptime;
    hh     := substr(v_time,1,2);
    mm     := substr(v_time,3,2);
    if(v_time = '') or (v_time is null)then
      return v_time;
    else
      return (hh || ':' || mm);
    end if;
  end;
  --
  procedure hrms85u(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_codappr     varchar2(10 char);
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_row         number;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_date        varchar2(200 char);

    v_codempid    varchar2(4000 char);
    v_numseq      number;
    v_dtereq      varchar2(10 char);
    v_amtappr     varchar2(4000 char);
    v_approvno    number;

       cursor c_hrms85u_c1 is
       select codempid,dtereq,numseq,location,remark,
               dtestrt,timstrt,dteend,timend,amtreq,staappr,dteappr,codappr
               typepay,amtappr,remarkap,
               a.approvno appno,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,b.approvno qtyapp,
               codappr
         from  ttravreq a ,twkflowh b
        where  staappr  in ('P','A')
--          and  ('Y' = chk_workflow.check_privilege('HRES81E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
--               -- Replace Approve
--                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
--                                                          from   twkflowde c
--                                                          where  c.routeno  = a.routeno
--                                                          and    c.codempid = v_codappr)
--                and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES81E')))

          and a.routeno = b.routeno
          and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
          order by  codempid,dtereq,numseq;

    cursor c_hrms85u_c2 is
      select codempid,dtereq,numseq,location,remark,
             dtestrt,timstrt,dteend,timend,amtreq,staappr,dteappr,codappr
             typepay,amtappr,remarkap,
             approvno ,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,codappr
      from ttravreq
      where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        and (codempid ,dtereq, numseq) in
                                 ( select codempid, dtereq, numseq
                                     from taptrvrq
                                    where staappr = decode(p_staappr,'Y','A',p_staappr)
                                      and codappr = v_codappr
                                      and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
          order by  codempid,dtereq,numseq;

    cursor c_taptrvrq is
     select codappr , get_temploy_name(codappr,global_v_lang) aname,approvno,
            to_char(dteappr ,'dd/mm/yyyy') dteappr ,typepay,staappr,
            amtappr,to_char(dtepay,'dd/mm/yyyy') dtepay,numperiod,dteyrepay,dtemthpay,remark
       from taptrvrq
      where codempid =  v_codempid
        and dtereq   =  to_date(v_dtereq,'dd/mm/yyyy')
        and numseq   =  v_numseq
        and approvno =  v_approvno;

    begin
      initial_value(json_str_input);
      v_codappr := pdk.check_codempid(global_v_coduser);

      obj_row   := json_object_t();
      v_row     := 0;
      v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
      v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');

      -- get data
      if p_staappr = 'P' then
        for r1 in c_hrms85u_c1 loop
          v_appno  := nvl(r1.appno,0) + 1;
          if nvl(r1.appno,0)+1 = r1.qtyapp then
             v_chk := 'E' ;
          else
             v_chk := v_appno;
          end if;

          v_date := to_char(r1.dtestrt,'dd/mm/yyyy')||' '||call_formattime(r1.timstrt) ||' - '||to_char(r1.dteend,'dd/mm/yyyy')||' '|| call_formattime(r1.timend);
          --
          v_dtereq   := to_char(r1.dtereq,'dd/mm/yyyy');
          v_codempid := r1.codempid;
          v_numseq   := r1.numseq;
          v_approvno := v_appno - 1;
          v_amtappr  := null;
          for r_taptrvrq in c_taptrvrq loop
            v_amtappr := to_char(r_taptrvrq.amtappr);
          end loop;
          --
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('approvno', v_appno);
          obj_data.put('chk_appr', v_chk);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('numseq', to_char(r1.numseq));
          obj_data.put('location', r1.location);
          obj_data.put('dteperiod', v_date);
          obj_data.put('amtreq', trim(to_char(to_number(r1.amtreq),'fm9,999,999,990.90')));
          obj_data.put('amtappr',nvl(to_char(v_amtappr,'fm9,999,999,990.90'),trim(to_char(to_number(r1.amtreq),'fm9,999,999,990.90'))));
          obj_data.put('remark', r1.remark);
          obj_data.put('status', r1.status);
          obj_data.put('codappr', r1.codappr);
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap', r1.remarkap);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('desc_codempap', get_temploy_name(global_v_codempid,global_v_lang));

          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
        end loop;
      else
        for r1 in c_hrms85u_c2 loop
          v_date := to_char(r1.dtestrt,'dd/mm/yyyy')||' '||call_formattime(r1.timstrt) ||' - '||to_char(r1.dteend,'dd/mm/yyyy')||' '|| call_formattime(r1.timend);
          v_nextappr := null;
          if r1.staappr = 'A' then
            v_nextappr := chk_workflow.get_next_approve('HRES81E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
          end if;
          --
          v_dtereq   := to_char(r1.dtereq,'dd/mm/yyyy');
          v_codempid := r1.codempid;
          v_numseq   := r1.numseq;
          v_approvno := r1.approvno;
          v_amtappr     := null;
          for r_taptrvrq in c_taptrvrq loop
            v_amtappr     := to_char(r_taptrvrq.amtappr);
          end loop;
          --
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('approvno', v_appno);
          obj_data.put('chk_appr', v_chk);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('numseq', to_char(r1.numseq));
          obj_data.put('location', r1.location);
          obj_data.put('dteperiod', v_date);
          obj_data.put('amtreq', trim(to_char(to_number(r1.amtreq),'fm9,999,999,990.90')));
          obj_data.put('amtappr',nvl(to_char(v_amtappr,'fm9,999,999,990.90'),trim(to_char(to_number(r1.amtreq),'fm9,999,999,990.90'))));
          obj_data.put('remark', r1.remark);
          obj_data.put('status', r1.status);
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap', r1.remarkap);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('desc_codempap', v_nextappr);

          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
        end loop;
      end if;

      json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms85u;
  --
  procedure hrms85u_detail(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    v_codgrpprov  tgrpprov.codgrpprov%type;

    cursor c1 is
      select location,codprov,codcnty,dtestrt,timstrt,dteend,timend,qtyday,qtydistance,remark,typepay,dteappr
        from ttravreq
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq;
  begin
    initial_value(json_str_input);

    obj_data := json_object_t();
    for r1 in c1 loop
      obj_data.put('coderror','200');
      obj_data.put('location',r1.location);
      obj_data.put('codprov',r1.codprov);
      obj_data.put('desc_codprov',get_tcodec_name('TCODPROV',r1.codprov,global_v_lang));
      begin
          select codgrpprov into v_codgrpprov
          from tgrpprov
          where codprov = r1.codprov;
      exception when no_data_found then
          v_codgrpprov := '';
      end;
      obj_data.put('desc_grpprov',get_tcodec_name('TCODGRPPROV', v_codgrpprov, global_v_lang));
      obj_data.put('codcnty',r1.codcnty);
      obj_data.put('desc_codcnty',get_tcodec_name('TCODCNTY',r1.codcnty,global_v_lang));
      obj_data.put('dtestrt',to_char(r1.dtestrt,'dd/mm/yyyy'));
      obj_data.put('timstrt',call_formattime(r1.timstrt));
      obj_data.put('dteend',to_char(r1.dteend,'dd/mm/yyyy'));
      obj_data.put('timend',call_formattime(r1.timend));
      obj_data.put('qtyday',to_char(r1.qtyday,'fm999,999,990'));
      obj_data.put('qtydistance',to_char(r1.qtydistance,'fm999,999,990'));
      obj_data.put('remark',r1.remark);
      obj_data.put('typepay',r1.typepay);
      obj_data.put('dtepay','');
    end loop;

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure hrms85u_detail_table_file(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number;
    v_folder      tfolderd.folder%type;

    cursor c1 is
      select filename,descfile
        from ttravreqf
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq
      order by seqno;
  begin
    initial_value(json_str_input);

    begin
      select folder into v_folder
        from tfolderd
       where codapp = 'HRES81E';
    exception when no_data_found then
      null;
    end;

    v_row := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('filename',r1.filename);
      obj_data.put('path_filename', get_tsetup_value('PATHDOC')||v_folder||'/'||r1.filename);
      obj_data.put('descfile',r1.descfile);

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure hrms85u_detail_table_exp(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_row         number;

    cursor c1 is
      select codexp,codtravunit,amtalw,qtyunit,amtreq
        from ttravexp
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq
      order by codexp;
  begin
    initial_value(json_str_input);

    v_row := 0;
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codexp',r1.codexp);
      obj_data.put('desc_codexp',get_tcodec_name('TCODEXP',r1.codexp,global_v_lang));
      obj_data.put('codtravunit',r1.codtravunit);
      obj_data.put('desc_codtravunit', get_tcodec_name('TCODTRAVUNIT', r1.codtravunit, global_v_lang));
      obj_data.put('amtalw',r1.amtalw);
      obj_data.put('qtyunit',r1.qtyunit);
      obj_data.put('amtreq',r1.amtreq);

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function gen_numtravrq(p_codcomp varchar2) return varchar2 is
   v_count      number      := 0;
   v_seq        number      := 0;
   v_buddha     number(4)   := 543;
   v_codcompy   varchar2(4 char) := hcm_util.get_codcomp_level(p_codcomp,1);
   v_numtravrq  varchar2(100 char);
	 v_year		    varchar2(4 char);
	 v_mm         varchar2(2 char);

  begin
    v_year    := to_number(to_char(sysdate,'yyyy'));
		v_mm      := lpad(to_char(sysdate,'mm'),2,'0');

    if v_year > 2500 then
        v_year := substr(v_year - v_buddha,3,2);--2564
    else
        v_year := substr((v_year),3,2); --2021
    end if;
     --------------
    begin
      select count(*)
        into v_count
        from ttravinf
       where numtravrq = p_codcomp||lpad(v_year,2,'0')||v_mm;
    end;
    v_seq       := v_count+1;
    v_numtravrq := v_codcompy||lpad(v_year,2,'0')||v_mm||lpad(v_seq,4,0);
    return v_numtravrq;
  end;
  --
  function gen_numpaymt(p_codcomp varchar2) return varchar2 is
   v_count      number      := 0;
   v_seq        number      := 0;
   v_buddha     number(4)   := 543;
   v_codcompy   varchar2(4 char) := hcm_util.get_codcomp_level(p_codcomp,1);
   v_numpaymt   varchar2(100 char);
	 v_year		   varchar2(4 char);

  begin
    v_year    := to_number(to_char(sysdate,'yyyy'));

    if v_year > 2500 then
        v_year := substr(v_year - v_buddha,3,2);--2564
    else
        v_year := substr((v_year),3,2); --2021
    end if;
     --------------
    begin
      select count(*)
        into v_count
        from ttravinf
       where numpaymt = 'TV'||p_codcomp||lpad(v_year,2,'0');
    end;
    v_seq      := v_count+1;
    v_numpaymt := 'TV'||v_codcompy||lpad(v_year,2,'0')||lpad(v_seq,7,0);
    return v_numpaymt;
  end;
  --
  procedure approve(p_coduser         in varchar2,
                    p_lang            in varchar2,
                    p_total           in varchar2,
                    p_status          in varchar2,
                    p_remark_appr     in varchar2,
                    p_remark_not_appr in varchar2,
                    p_dteappr         in varchar2,
                    p_appseq          in number,
                    p_chk             in varchar2,
                    p_codempid        in varchar2,
                    p_numseq          in number,
                    p_dtereq          in varchar2,
                    p_amtalw          in varchar2,
                    p_typpay          in varchar2,
                    p_dtepay          in varchar2,
                    p_dteyrepay       in varchar2,
                    p_dtemthpay       in varchar2,
                    p_numperiod       in varchar2) is
    rq_numseq       number                  := p_numseq;
    rq_codempid     temploy1.codempid%type  := p_codempid;
    rq_dtereq       date                    := to_date(p_dtereq,'dd/mm/yyyy');
    rq_chk          varchar2(10 char)       := p_chk;
    v_appseq        number := p_appseq;
    r_ttravreq      ttravreq%rowtype;
    v_approvno      number := null;
    ap_approvno     number := null;
    v_count         number := 0;
    v_staappr       varchar2(1 char);
    v_codeappr      temploy1.codempid%type;
    v_approv        temploy1.codempid%type;
    v_desc          varchar2(600 char)      := get_label_name('HCM_APPRFLW', p_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_remark        varchar2(2000 char);
    p_codappr       temploy1.codempid%type  := pdk.check_codempid(p_coduser);
    v_max_approv    number;
    v_row_id        varchar2(200 char);
    v_dteyrepay     varchar2(100 char);
    v_dtemthpay     varchar2(100 char);
    v_numperiod     varchar2(400 char);
    v_dtepay        date;
    v_numtravrq     ttravinf.numtravrq%type;
    v_numpaymt      ttravinf.numpaymt%type;
    v_codpay        ttravinf.codpay%type;
    v_codcomp       temploy1.codcomp%type;

    cursor c_ttravreqf is
      select seqno,filename,descfile
        from ttravreqf
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq
      order by seqno;

    cursor c_ttravexp is
      select codexp,codtravunit,amtalw,qtyunit,amtreq
        from ttravexp
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq
      order by codexp;
  begin
    v_staappr := p_status ;
    v_zyear   := pdk.check_year(p_lang);
    if v_staappr = 'A' then -- check status = Approve
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then  -- check status = Not  Approve
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

    begin
     select *
       into r_ttravreq
       from ttravreq
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_numseq;
    exception when others then
      r_ttravreq := null;
    end;

    begin
      select approvno -- check Max seq Approve
      into   v_max_approv
      from   twkflowh
      where  routeno = r_ttravreq.routeno;
    exception when no_data_found then
      v_max_approv := 0;
    end;

    if nvl(r_ttravreq.approvno,0) < v_appseq then
      ap_approvno := v_appseq;
      begin
         select count(*) into v_count
           from taptrvrq
          where codempid = rq_codempid
            and dtereq   = rq_dtereq
            and numseq   = rq_numseq
            and approvno = ap_approvno;
      exception when others then
         v_count := 0;
      end;

      v_dtepay    := to_date(rtrim(ltrim(p_dtepay)),'dd/mm/yyyy');
      v_dteyrepay := p_dteyrepay;
      v_dtemthpay := p_dtemthpay;
      v_numperiod := p_numperiod;
      if p_typpay = '1' then
        v_dteyrepay := null;
        v_dtemthpay := null;
        v_numperiod := null;
      elsif p_typpay = '2' then
        v_dtepay    := null;
      end if;

      if v_count = 0 then
         insert into taptrvrq(codempid,dtereq,numseq,approvno,
                              amtappr,typepay,dtepay,dteyrepay,dtemthpay,numperiod,
                              codappr,dteappr,staappr,remark,
                              dteapph,dteupd,coduser,codcreate)
                values(rq_codempid,rq_dtereq,rq_numseq,ap_approvno,
                       p_amtalw,p_typpay,v_dtepay,v_dteyrepay,v_dtemthpay,v_numperiod,
                       p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,
                       sysdate,trunc(sysdate),p_coduser,p_coduser);
      else
         update taptrvrq
            set amtappr   = p_amtalw,
                typepay   = p_typpay,
                dtepay    = v_dtepay,
                dteyrepay = v_dteyrepay,
                dtemthpay = v_dtemthpay,
                numperiod = v_numperiod,
                codappr   = p_codappr,
                dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                staappr   = v_staappr,
                remark    = v_remark,
                dteupd    = trunc(sysdate),
                coduser   = p_coduser,
                dteapph   = sysdate
           where codempid = rq_codempid
             and dtereq   = rq_dtereq
             and numseq   = rq_numseq
             and approvno = ap_approvno;
      end if;

      -- Check Next Step
      v_codeappr  :=  p_codappr ;
      v_approvno  :=  ap_approvno;

      chk_workflow.find_next_approve('HRES81E',r_ttravreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr,null);

      if p_status = 'A' and rq_chk <> 'E' then
        loop
          v_approv := chk_workflow.check_next_step('HRES81E',r_ttravreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);

          if v_approv is not null then
            v_remark   := v_desc;
            v_approvno := v_approvno + 1 ;
            v_codeappr := v_approv ;

            begin
               select count(*)
                 into v_count
                 from taptrvrq
                where codempid  =  rq_codempid
                  and dtereq    =  rq_dtereq
                  and numseq    =  rq_numseq
                  and approvno  =  v_approvno;
            exception when no_data_found then  v_count := 0;
            end;

            if v_count = 0  then
              insert into taptrvrq(codempid,dtereq,numseq,approvno,
                                  amtappr,typepay,dtepay,dteyrepay,dtemthpay,numperiod,
                                  codappr,dteappr,staappr,remark,
                                  dteapph,dteupd,coduser,codcreate)
                    values(rq_codempid,rq_dtereq,rq_numseq,
                           p_amtalw,p_typpay,v_dtepay,v_dteyrepay,v_dtemthpay,v_numperiod,
                           ap_approvno,p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,
                           sysdate,trunc(sysdate),p_coduser,p_coduser);
              insert into taptrvrq(codempid,dtereq,numseq,
                   approvno,
                   codappr,dteappr,staappr,remark,
                   dteupd,coduser,codcreate,
                   dteapph)
                  values(rq_codempid,rq_dtereq, rq_numseq,
                   v_approvno,
                   v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),'A',v_remark,
                   trunc(sysdate),p_coduser,p_coduser,
                   sysdate);
            else
              update taptrvrq
                set amtappr   = p_amtalw,
                    typepay   = p_typpay,
                    dtepay    = v_dtepay,
                    dteyrepay = v_dteyrepay,
                    dtemthpay = v_dtemthpay,
                    numperiod = v_numperiod,
                    codappr   = p_codappr,
                    dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                    staappr   = v_staappr,
                    remark    = v_remark,
                    dteupd    = trunc(sysdate),
                    coduser   = p_coduser,
                    dteapph   = sysdate
               where codempid = rq_codempid
                 and dtereq   = rq_dtereq
                 and numseq   = rq_numseq
                 and approvno = ap_approvno;
            end if;
            chk_workflow.find_next_approve('HRES81E',r_ttravreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr,null);
          else
            exit;
          end if;
        end loop;
      end if; --p_status = 'A' and rq_chk <> 'E'   then

      if v_max_approv = v_approvno then
        rq_chk := 'E';
      end if;
      v_staappr := nvl(p_status,'A');
      if rq_chk = 'E' and p_status = 'A' then
        v_staappr := 'Y';

        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = rq_codempid;
        exception when no_data_found then
          v_codcomp := null;
        end;

        begin
          select codinctv
            into v_codpay
            from tcontrbf
           where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontrbf
                              where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                and dteeffec <= sysdate);
        exception when no_data_found then
          v_codpay := null;
        end;

        v_numtravrq := gen_numtravrq(v_codcomp);
        v_numpaymt := gen_numpaymt(v_codcomp);
        begin
          insert into ttravinf (numtravrq,codempid,dtereq,
                                typetrav,location,codprov,
                                codcnty,dtestrt,timstrt,
                                dteend,timend,qtyday,
                                qtydistance,remark,amtreq,
                                typepay,flgvoucher,dtepay,
                                codpay,dteyrepay,dtemthpay,
                                numperiod,flgtranpy,codcomp,
                                codappr,dteappr,numpaymt,
                                codcreate,coduser)
                      values (v_numtravrq,rq_codempid,rq_dtereq,
                              r_ttravreq.typetrav,r_ttravreq.location,r_ttravreq.codprov,
                              r_ttravreq.codcnty,r_ttravreq.dtestrt,r_ttravreq.timstrt,
                              r_ttravreq.dteend,r_ttravreq.timend,r_ttravreq.qtyday,
                              r_ttravreq.qtydistance,r_ttravreq.remark,r_ttravreq.amtreq,
                              r_ttravreq.typepay,'N',v_dtepay,
                              v_codpay,v_dteyrepay,v_dtemthpay,
                              v_numperiod,'N',v_codcomp,
                              v_codeappr,trunc(sysdate),v_numpaymt,
                              p_coduser,p_coduser);
        exception when others then null;
        end;

        -- delete file before insert
        begin
          delete from ttravattch where numtravrq = v_numtravrq;
        exception when others then null;
        end;
        for r_ttravreqf in c_ttravreqf loop
          begin
            insert into ttravattch (numtravrq,numseq,filename,
                                    descattch,codcreate,coduser)
                        values (v_numtravrq,r_ttravreqf.seqno,r_ttravreqf.filename,
                                r_ttravreqf.descfile,p_coduser,p_coduser);
          exception when others then null;
          end;
        end loop;

        for r_ttravexp in c_ttravexp loop
        begin
          insert into ttravinfd (numtravrq,codexp,codtravunit,
                                 amtalw,qtyunit,amtreq,codcreate,coduser)
                      values (v_numtravrq,r_ttravexp.codexp,r_ttravexp.codtravunit,
                              r_ttravexp.amtalw,r_ttravexp.qtyunit,r_ttravexp.amtreq,p_coduser,p_coduser);
          exception when others then null;
          end;
        end loop;
      end if; -- if rq_chk = 'E' and p_status = 'A' then

      update ttravreq
          set staappr   = v_staappr,
              codappr   = v_codeappr,
              approvno  = v_approvno,
              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
              coduser   = p_coduser,
              remarkap  = v_remark,
              dteapph   = sysdate,
              numtravrq = v_numtravrq,
              amtappr   = p_amtalw
        where codempid  = rq_codempid
         and  dtereq    = rq_dtereq
         and  numseq    = rq_numseq;

        begin
            select rowid
              into v_row_id
              from ttravreq
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq;
        exception when others then
            v_row_id := null;
        end;

        begin 
          chk_workflow.sendmail_to_approve(   p_codapp        => 'HRES81E',
                                              p_codtable_req  => 'ttravreq',
                                              p_rowid_req     => v_row_id,
                                              p_codtable_appr => 'taptrvrq',
                                              p_codempid      => rq_codempid,
                                              p_dtereq        => rq_dtereq,
                                              p_seqno         => rq_numseq,
                                              p_staappr       => v_staappr,
                                              p_approvno      => v_approvno,
                                              p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                              p_subject_mail_numseq  => '150',
                                              p_lang          => global_v_lang,
                                              p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
    end if; -- if nvl(r_ttrncerq.approvno,0) < v_appseq then
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100 char);
    v_appseq        number;
    v_chk           varchar2(10 char);
    v_seqno         number;
    v_codempid      varchar2(100 char);
    v_dtereq        varchar2(100 char);
    v_amtalw        varchar2(100 char);
    v_typpay        varchar2(100 char);
    v_dtepay        varchar2(100 char);
    v_dteyrepay     varchar2(100 char);
    v_dtemthpay     varchar2(100 char);
    v_numperiod     varchar2(100 char);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');

    v_staappr   := hcm_util.get_string_t(json_obj, 'p_staappr');
    v_appseq    := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
    v_chk       := hcm_util.get_string_t(json_obj, 'p_chk_appr');
    v_seqno     := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
    v_codempid  := hcm_util.get_string_t(json_obj, 'p_codempid');
    v_dtereq    := hcm_util.get_string_t(json_obj, 'p_dtereq');
    v_amtalw    := hcm_util.get_string_t(json_obj, 'p_amtalw');
    v_typpay    := hcm_util.get_string_t(json_obj, 'p_typpay');
    v_dtepay    := hcm_util.get_string_t(json_obj, 'p_dtepay');
    v_dteyrepay := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    v_dtemthpay := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    v_numperiod := hcm_util.get_string_t(json_obj, 'p_numperiod');

    v_staappr := nvl(v_staappr, 'A');
    approve(global_v_coduser,global_v_lang,to_char(v_rowcount),
            v_staappr,p_remark_appr,p_remark_not_appr,
            to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,
            v_codempid,v_seqno,v_dtereq,
            v_amtalw,v_typpay,v_dtepay,
            v_dteyrepay,v_dtemthpay,v_numperiod);

    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      if param_msg_error_mail is not null then
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_approve;
  --
  procedure get_approve(json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    r_ttravreq    ttravreq%rowtype;
    v_flgdata     boolean := false;

    cursor c_taptrvrq is
       select dteappr,amtappr,staappr,typepay,dtepay,numperiod,dteyrepay,dtemthpay
         from taptrvrq
        where codempid =  p_codempid
          and dtereq   =  p_dtereq
          and numseq   =  p_numseq
          and approvno =  p_approvno - 1;
  begin
    initial_value(json_str_input);

    begin
      select * into r_ttravreq
        from ttravreq
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq;
    exception when no_data_found then
      r_ttravreq := null;
    end;

    for r_taptrvrq in c_taptrvrq loop
      v_flgdata := true;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('desc_codappr',chk_workflow.get_next_approve('HRES81E',p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_approvno - 1,global_v_lang));
      obj_data.put('dteappr',to_char(sysdate,'dd/mm/yyyy'));
      obj_data.put('amtalw',r_taptrvrq.amtappr);
      obj_data.put('status',get_tlistval_name('ESSTAREQ',r_taptrvrq.staappr,global_v_lang));
      obj_data.put('typpay',r_taptrvrq.typepay);
      obj_data.put('dtepay',to_char(r_taptrvrq.dtepay,'dd/mm/yyyy'));
      obj_data.put('numperiod',r_taptrvrq.numperiod);
      obj_data.put('dtemthpay',r_taptrvrq.dtemthpay);
      obj_data.put('dteyrepay',r_taptrvrq.dteyrepay);
      obj_data.put('remark','');
    end loop;

    if not v_flgdata then
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('desc_codappr',chk_workflow.get_next_approve('HRES81E',p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_approvno - 1,global_v_lang));
      obj_data.put('dteappr',to_char(sysdate,'dd/mm/yyyy'));
      obj_data.put('amtalw',r_ttravreq.amtreq);
      obj_data.put('status',get_tlistval_name('ESSTAREQ',r_ttravreq.staappr,global_v_lang));
      obj_data.put('typpay',r_ttravreq.typepay);
      obj_data.put('dtepay','');
      obj_data.put('numperiod','');
      obj_data.put('dtemthpay','');
      obj_data.put('dteyrepay','');
      obj_data.put('remark','');
    end if;

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

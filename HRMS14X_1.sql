--------------------------------------------------------
--  DDL for Package Body HRMS14X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS14X" is

  procedure initial_value(json_str in clob) is
    json_obj      json_object_t;
    v_test  varchar2(100 char);
  begin
    json_obj           := json_object_t(json_str);
    --global
    global_v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd   := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codempid   := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codapp     := hcm_util.get_string_t(json_obj,'p_codapp');
    b_index_stdate     := to_date(trim(hcm_util.get_string_t(json_obj,'p_stdate')),'dd/mm/yyyy');
    b_index_endate     := to_date(trim(hcm_util.get_string_t(json_obj,'p_endate')),'dd/mm/yyyy');
    b_index_codcomp    := hcm_util.get_string_t(json_obj, 'p_codcomp');
    b_index_staappr    := replace(hcm_util.get_string_t(json_obj, 'p_staappr'),'ALL','%');

    b_index_dtereq     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    b_index_numseq     := hcm_util.get_string_t(json_obj,'p_numseq');
    b_index_routeno    := hcm_util.get_string_t(json_obj,'p_routeno');
    b_index_approvno   := nvl(hcm_util.get_string_t(json_obj,'p_approvno'),0);
    b_index_typreq     := hcm_util.get_string_t(json_obj,'p_typreq');
    b_index_dtework    := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    b_index_codlon     := hcm_util.get_string_t(json_obj,'p_codlon');
    b_index_codpos     := hcm_util.get_string_t(json_obj,'p_codpos');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  function secur_codempid(p_coduser in varchar2, p_lang in varchar2, p_codempid in varchar2) return varchar2 is
    v_count               number;
    v_flgsecu             boolean := false;
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    v_zupdsal             varchar2(4000 char);
    v_codempid            varchar2(10 char);
  begin
    begin
      select count(*) into v_count
        from temploy1
       where codempid like p_codempid
         and staemp in ('1','3','9');
    exception when no_data_found then
      null;
    end;
    if v_count = 0 then
      return get_error_msg_php('HR2010', p_lang, 'temploy1');
    END IF;

    begin
      select codempid into  v_codempid
      from  tusrprof
      where coduser = upper(p_coduser) ;
    exception when  others then
      v_codempid := ' ' ;
    end ;

    if v_codempid <> p_codempid then
        hcm_secur.get_global_secur(p_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        v_flgsecu := secur_main.secur2(p_codempid,p_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu  then
          return get_error_msg_php('HR3007', p_lang);
        END IF;
    end if;
    return null;
  end;

  procedure check_index is
    v_codapp   tempaprq.codapp%type;
  begin
    if b_index_codempid is not null then
      b_index_codcomp := null;
      param_msg_error := secur_codempid(global_v_coduser,global_v_lang,b_index_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if b_index_codapp is not null then
      begin
         select codapp
           into v_codapp
           from tempaprq
          where codapp = b_index_codapp
            and rownum = 1;
      exception
      when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPAPRQ');
        return;
      end;
    end if;
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;


  procedure gen_hres32e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,routeno,typchg,
		       decode(typchg,'1','HRES32E1',
												 '2','HRES32E2',
												 '3','HRES32E3',
												 '4','HRES32E4',
												 '5','HRES32E5','HRES32E6') typreq,
					decode(typchg,'1',get_label_name('HRES32EC1',global_v_lang,60),
												'2',get_label_name('HRES32EC1',global_v_lang,70),
												'3',get_label_name('HRES32EC1',global_v_lang,80),
												'4',get_label_name('HRES32EC1',global_v_lang,90),
												'5',get_label_name('HRES32EC1',global_v_lang,100),get_label_name('HRES32EC1',global_v_lang,110)) typnam,
					staappr,codappr,dteappr,remarkap,approvno,
                    desnote,    -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
					codcomp,dtesnd,dtecancel,rowid
		 from tempch
		where codcomp like b_index_codcomp||'%'
		  and codempid = nvl(b_index_codempid,codempid)
		  and dtereq between b_index_stdate and b_index_endate
		  and staappr like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', r1.typnam);                                                   --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES32E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('typreq', r1.typreq);
          obj_data.put('typchg', r1.typchg);
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));
          -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

          obj_data.put('detail', r1.desnote);
          obj_data.put('dteperiod', '');

          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tempch');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output:= obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres34e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char); -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,remarkap,
               descreq1,dtemov, -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       codcomp,dtesnd,dtecancel,approvno,rowid
		  from tmovereq
		where codcomp like b_index_codcomp||'%'
		  and codempid = nvl(b_index_codempid,codempid)
		  and dteinput between b_index_stdate and b_index_endate
		  and staappr like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', replace(r1.remarkap,chr(13)||chr(10),' '));                   --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES34E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));
           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.descreq1);
          v_dte_period := hcm_util.get_date_config(r1.dtemov);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tmovereq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres36e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
    select codempid,dtereq,dteinput,numseq,staappr,
		       codappr,dteappr,remarkap,codcomp,
		       desnote,routeno,dtesnd,
               dteuse,   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from trefreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', replace(r1.remarkap,chr(13)||chr(10),''));                     --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES36E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desnote);
          v_dte_period := hcm_util.get_date_config(r1.dteuse);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'trefreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres62e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
    v_dte_period    varchar2(200 char);
    v_timstrt       varchar2(10 char);
    v_timend        varchar2(10 char);
    -- END >>

	cursor c1 is
		select codempid,dtereq,dteinput,seqno,staappr,
		       codappr,codleave,dteappr,remarkap,
		       codcomp,routeno,dtesnd,
               deslereq,dteleave,dtestrt,timstrt,dteend,timend,  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tleaverq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
           and dtestrt between b_index_stdate and b_index_endate ---<<Pratya 07/12/2023 change dtereq -> dtestrt
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_timstrt := null;
          v_timend := null;
          v_dte_period := '';

          if r1.timstrt is not null then
            v_timstrt := substr(r1.timstrt, 1, 2) || ':' || substr(r1.timstrt, 3, 2);
          else
            v_timstrt := '00:00';
          end if;

          if r1.timend is not null then
            v_timend := substr(r1.timend, 1, 2) || ':' || substr(r1.timend, 3, 2);
          else
            v_timend := '00:00';
          end if;

          if v_timstrt <> '00:00' then
            v_dte_period := hcm_util.get_date_config(r1.dtestrt)||' '||to_char(to_date(v_timstrt,'hh24:mi'),'hh24:mi');
          else
            v_dte_period := hcm_util.get_date_config(r1.dtestrt);

          end if;

          if r1.dtestrt <> r1.dteend then
             if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteend)||' '||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             else               
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteend);
             end if;
          else
            if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             end if;
          end if;
          -- END >>
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.seqno);                                                    --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tleavecd_name(r1.codleave,global_v_lang));                --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES62E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.deslereq);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tleaverq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres6ae(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';
    v_timstrt       varchar2(10 char);
    v_timend        varchar2(10 char);
    v_dte_period    varchar2(200 char);

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       codappr,dteappr,dtework,remarkap,
		       codcomp,codreqst,routeno,
               remark,dtein,timin,dteout,timout,  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtesnd,dtecancel,approvno,rowid
		  from ttimereq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtework between b_index_stdate and b_index_endate --< Pratya 07/12/2023 change dtereq - > dtework
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_timstrt := null;
          v_timend := null;
          v_dte_period := '';

          if r1.timin is not null then
            v_timstrt := substr(r1.timin, 1, 2) || ':' || substr(r1.timin, 3, 2);
          else
            v_timstrt := '00:00';
          end if;

          if r1.timout is not null then
            v_timend := substr(r1.timout, 1, 2) || ':' || substr(r1.timout, 3, 2);
          else
            v_timend := '00:00';
          end if;

          if v_timstrt <> '00:00' then
            v_dte_period := hcm_util.get_date_config(r1.dtein)||' '||to_char(to_date(v_timstrt,'hh24:mi'),'hh24:mi');
          else
            v_dte_period := hcm_util.get_date_config(r1.dtein);
          end if;
          if r1.dtein <> r1.dteout then
             if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteout)||' '||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             else
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteout);
             end if;
          else
            if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             end if;
          end if;
          -- END >>

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('TCODTIME',r1.codreqst,global_v_lang));       --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES6AE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));
          obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('dteperiod', v_dte_period);
          obj_data.put('detail', r1.remark);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttimereq');
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres6de(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,seqno,staappr,
		       routeno,codappr,dteappr,dtework,typwrkn,
		       remarkap,codcomp,
               remark,   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtesnd,dtecancel,approvno,rowid
		  from tworkreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtework between b_index_stdate and b_index_endate ---<<Pratya 07/12/2023 change dtereq -> dtework
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.seqno);                                                    --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tlistval_name('TYPWRKFUL',r1.typwrkn,global_v_lang));     --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES6DE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_dte_period := hcm_util.get_date_config(r1.dtework);
          obj_data.put('dteperiod', v_dte_period);
          obj_data.put('detail', r1.remark);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tworkreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres6ie(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    v_remark      varchar2(4000 char);
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period   varchar2(200 char);   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,remarkap,codcomp,
               dtesnd,dtecancel,
               remark,dtetrst,dtetren,   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       codtparg,namcourse,codcours,approvno,rowid
		  from ttrnreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_remark := get_tlistval_name('TCODTPARG',r1.codtparg,global_v_lang);
          if r1.codtparg = '1' then
            v_remark := v_remark||'  '||get_tcourse_name(r1.codcours,global_v_lang);
          else
            if r1.namcourse is not null then
              v_remark := v_remark||'  '||r1.namcourse;
            else
              v_remark := v_remark||'  '||get_tcourse_name(r1.codcours,global_v_lang);
            end if;
          end if;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_dte_period := hcm_util.get_date_config(r1.dtetrst);

          if r1.dtetrst <> r1.dtetren then
            v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dtetren);
          end if;
          -- END >>

          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', v_remark);                                                    --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES6IE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remark);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttrnreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres6ke(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
    v_dte_period    varchar2(200 char); 

    v_timdstr       varchar2(100 char);
    v_timdend       varchar2(100 char);
    v_timbstr       varchar2(100 char);
    v_timbend       varchar2(100 char);
    v_timastr       varchar2(100 char);
    v_timaend       varchar2(100 char);

    v_timd          varchar2(100 char);
    v_timb          varchar2(100 char);
    v_tima          varchar2(100 char);
    -- NED >>

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       codappr,dteappr,remarkap,codcomp,
		       codrem,routeno,dtesnd,
                -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
               remark,
               dtestrt,dteend,
               timdstr,timdend,
               timbstr,timbend,
               timastr,timaend,
               -- END >>
		       dtecancel,approvno,rowid
		  from ttotreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtestrt between b_index_stdate and b_index_endate ---<<Pratya 07/12/2023 change dtereq -> dtestrt
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_dte_period  := '';          

          v_timbstr       := null;
          v_timbend       := null;          
          v_timdstr       := null;
          v_timdend       := null;
          v_timastr       := null;
          v_timaend       := null;
          v_timd          := null;
          v_timb          := null;
          v_tima          := null;

            ------- Before-----
          if r1.timbstr is not null then
            v_timbstr := substr(r1.timbstr, 1, 2) || ':' || substr(r1.timbstr, 3, 2);
          end if;

          if r1.timbend is not null then
            v_timbend := substr(r1.timbend, 1, 2) || ':' || substr(r1.timbend, 3, 2);
          end if;
            ------- During-----
          if r1.timdstr is not null then
            v_timdstr := substr(r1.timdstr, 1, 2) || ':' || substr(r1.timdstr, 3, 2);
          end if;

          if r1.timdend is not null then
            v_timdend := substr(r1.timdend, 1, 2) || ':' || substr(r1.timdend, 3, 2);
          end if;
            ------- After-----
          if r1.timastr is not null then
            v_timastr := substr(r1.timastr, 1, 2) || ':' || substr(r1.timastr, 3, 2);
          end if;          

          if r1.timaend is not null then
            v_timaend := substr(r1.timaend, 1, 2) || ':' || substr(r1.timaend, 3, 2);
--          else
--            v_timaend := '00:00';
          end if;
          --------------------------

         if v_timbstr is not null then
            v_timb := ', '||v_timbstr||'-'||v_timbend;
         else
            v_timb := null;
         end if;
         ----
         if v_timdstr is not null then
            v_timd := ', '||v_timdstr||'-'||v_timdend;
         else
            v_timd := null;
         end if;
         ----
         if v_timastr is not null then
            v_tima := ', '||v_timastr||'-'||v_timaend;
         else
            v_tima := null;
         end if;             
         ----

          if r1.dtestrt <> r1.dteend then
                v_dte_period := hcm_util.get_date_config(r1.dtestrt)||'-'||hcm_util.get_date_config(r1.dteend)||' '||v_timb||v_timd||v_tima;                    
          else
                v_dte_period := hcm_util.get_date_config(r1.dteend)||' '||v_timb||v_timd||v_tima;
          end if;
          -- END >>

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('TCODOTRQ',r1.codrem,global_v_lang));         --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES6KE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remark);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttotreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres6me(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period   varchar2(200 char);   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,seqno,staappr,
		       codappr,codleave,dteappr,remarkap,
		       codcomp,routeno,dtesnd,
               desreq,dtestrt,dteend,    -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tleavecc
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtestrt between b_index_stdate and b_index_endate ---<<Pratya 07/12/2023 change dtereq -> dtestrt
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_dte_period := '';
          if r1.dtestrt <> r1.dteend then
                v_dte_period := hcm_util.get_date_config(r1.dtestrt)||'-'||hcm_util.get_date_config(r1.dteend);
          else
                v_dte_period := hcm_util.get_date_config(r1.dtestrt);
          end if;
          -- END >>

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.seqno);                                                    --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tleavecd_name(r1.codleave,global_v_lang));                --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES6ME',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desreq);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tleavecc');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres71e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period   varchar2(200 char);   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,codrel,remarkap,
		       codcomp,dtesnd,
               dtecrest,dtecreen,    -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tmedreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_dte_period := '';
          if r1.dtecrest <> r1.dtecreen then
                v_dte_period := hcm_util.get_date_config(r1.dtecrest)||'-'||hcm_util.get_date_config(r1.dtecreen);
          else
                v_dte_period := hcm_util.get_date_config(r1.dtecreen);
          end if;

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tlistval_name('TTYPRELATE',r1.codrel,global_v_lang));      --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES71E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', '');
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tmedreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres74e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,routeno,
		       staappr,codappr,dteappr,codobf,remarkap,
		       /*codcomp,*/dtesnd,
               desnote,  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tobfreq
		 where /*codcomp like b_index_codcomp||'%'
		   and*/ codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tobfcde_name(r1.codobf,global_v_lang));                  --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES74E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desnote);
          obj_data.put('dteperiod', '');
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tobfreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres77e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       codappr,dteappr,codlon,remarkap,
		       codcomp,routeno,dtesnd,
               reaslon,dtelonst,     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
	    from tloanreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_ttyplone_name(r1.codlon,global_v_lang));                 --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES77E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));
          obj_data.put('codlon', r1.codlon);

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.reaslon);
          v_dte_period := hcm_util.get_date_config(r1.dtelonst);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tloanreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres81e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
    v_dte_period   varchar2(200 char);
    v_timstrt   varchar2(10 char);
    v_timend   varchar2(10 char);
    -- END >>

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,routeno,
		       staappr,codappr,dteappr,remarkap,
		       /*codcomp,*/dtesnd,
               remark,dtestrt,timstrt,dteend,timend,     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,location,approvno,rowid
		  from ttravreq
		 where /*codcomp like b_index_codcomp||'%'
		   and */codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_timstrt := null;
          v_timend := null;
          v_dte_period := '';  

          if r1.timstrt is not null then
            v_timstrt := substr(r1.timstrt, 1, 2) || ':' || substr(r1.timstrt, 3, 2);
          else
            v_timstrt := '00:00';
          end if;

          if r1.timend is not null then
            v_timend := substr(r1.timend, 1, 2) || ':' || substr(r1.timend, 3, 2);
          else
            v_timend := '00:00';
          end if;

          if v_timstrt <> '00:00' then
             v_dte_period := hcm_util.get_date_config(r1.dtestrt)||' '||to_char(to_date(v_timstrt,'hh24:mi'),'hh24:mi');
          else
            v_dte_period := hcm_util.get_date_config(r1.dtestrt);
          end if;

          if r1.dtestrt <> r1.dteend then
             if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteend)||' '||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             else
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dteend);
             end if;
          else
            if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             end if;
          end if;
          -- END >>

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', r1.location);                                                 --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES81E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remark);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttravreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres86e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       codappr,dteappr,remarkap,codcomp,
		       codexemp,routeno,dtesnd,
               desnote,  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tresreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dteeffec between b_index_stdate and b_index_endate ---<<Pratya 07/12/2023 change dtereq -> dteeffec
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('TCODEXEM',r1.codexemp,global_v_lang));       --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES86E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desnote);
          obj_data.put('dteperiod', '');
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tresreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres88e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,remarkap,
		       codempmt,codcomp,codpos,
               remark,   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtesnd,dtecancel,approvno,rowid
		  from tjobreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput,numseq;

  begin
    obj_row  := json_object_t();

    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang));      --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES88E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));
          obj_data.put('codcomp', r1.codcomp);
          obj_data.put('codpos', r1.codpos);

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remark);
          obj_data.put('dteperiod', '');
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tjobreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres91e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
    select codempid,dtereq,dteinput,numseq,staappr staappr,routeno,
           codappr,dteappr,remarkap,codcomp,
           desreq,   -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
           dtesnd,dtecancel,codcours,approvno,rowid
      from ttrncerq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcourse_name(r1.codcours,global_v_lang));                 --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES91E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desreq);
          obj_data.put('dteperiod', '');
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttrncerq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output:= obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres93e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
    v_dte_period   varchar2(200 char);
    v_timstrt   varchar2(10 char);
    v_timend   varchar2(10 char);
    -- END >>

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,stappr staappr,
		       routeno,codappr,dteappr,remarkap,
		       codcomp,dtesnd,
               desreq,dtetrst,dtetren,timestr,timeend,
		       dtecancel,codcours,approvno,rowid
		  from ttrncanrq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and stappr  like nvl(b_index_staappr,stappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          v_timstrt := null;
          v_timend := null;
          v_dte_period := '';

          if r1.timestr is not null then
            v_timstrt := substr(r1.timestr, 1, 2) || ':' || substr(r1.timestr, 3, 2);
          else
            v_timstrt := '00:00';
          end if;

          if r1.timeend is not null then
            v_timend := substr(r1.timeend, 1, 2) || ':' || substr(r1.timeend, 3, 2);
          else
            v_timend := '00:00';
          end if;

          if v_timstrt <> '00:00' then
             v_dte_period := hcm_util.get_date_config(r1.dtetrst)||' '||to_char(to_date(v_timstrt,'hh24:mi'),'hh24:mi');
          else
            v_dte_period := hcm_util.get_date_config(r1.dtetrst);
          end if;

          if r1.dtetrst <> r1.dtetren then
             if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dtetren)||' '||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             else
                v_dte_period := v_dte_period || ' - ' ||hcm_util.get_date_config(r1.dtetren);
             end if;
          else
            if v_timend <> '00:00' then
                v_dte_period := v_dte_period || ' - ' ||to_char(to_date(v_timend,'hh24:mi'),'hh24:mi');
             end if;
          end if;
          -- END

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcourse_name(r1.codcours,global_v_lang));                 --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES93E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.desreq);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttrncanrq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hress2e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,seqno numseq,staappr,
		       codappr,routeno,dteappr,remarkap,
		       codcomp,codpfinf,dtesnd,
               remark,dteeffec,  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tpfmemrq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('tcodpfinf',r1.codpfinf,global_v_lang));      --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRESS2E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remark);
          v_dte_period := hcm_util.get_date_config(r1.dteeffec);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpfmemrq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hress4e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,remarkap,
		       codcomp,codpos,dtesnd,
               remarks,dtestart,     -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from tircreq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tpostn_name(r1.codpos,global_v_lang));                    --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRESS4E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.remarks);
          v_dte_period := hcm_util.get_date_config(r1.dtestart);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tircreq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres95e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

    v_dte_period    varchar2(200 char);  -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,staappr,
		       routeno,codappr,dteappr,remarkap,
		       codcomp,dtesnd,codchgsh,
               reason,dtechq,    -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno,rowid
		  from treplacerq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', get_tcodec_name('TCODCHGSH',r1.codchgsh,global_v_lang));                    --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRESS4E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.reason);
          v_dte_period := hcm_util.get_date_config(r1.dtechq);
          obj_data.put('dteperiod', v_dte_period);
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'treplacerq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_hres17e(json_str_output out clob) is
    v_total       number := 0;
    v_row         number := 0;
    flgpass   		boolean;
    flg_secur 		varchar2(1 char)  := 'N';

	cursor c1 is
		select codempid,dtereq,dteinput,numseq,routeno,
		       staappr,codappr,dteappr,remarkap,
		       dtesnd,
               objective,    -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
		       dtecancel,approvno
		  from tkpireq
		 where codcomp like b_index_codcomp||'%'
		   and codempid = nvl(b_index_codempid,codempid)
		   and dtereq between b_index_stdate and b_index_endate
		   and staappr  like nvl(b_index_staappr,staappr)
		order by codempid,dteinput;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r1 in c1 loop
        flgpass := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          flg_secur := 'Y';
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);                                               --ITEM01
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));          --ITEM02
          obj_data.put('dteinput', to_char(r1.dteinput,'dd/mm/yyyy hh24:mi'));                 --DATE01
          obj_data.put('numseq', r1.numseq);                                                   --TEMP02
          obj_data.put('desc_staappr', get_tlistval_name('STAAPPR',r1.staappr,global_v_lang)); --ITEM03
          obj_data.put('routeno', r1.routeno);                                                 --ITEM09
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));            --ITEM04
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));                           --DATE02
          obj_data.put('remark', r1.remarkap);                                                 --ITEM05
          obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES17E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang)); --ITEM10
          obj_data.put('desc_routeno', get_twkflowh_name(r1.routeno,global_v_lang));
          obj_data.put('approvno', nvl(r1.approvno,0));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('staappr', r1.staappr);
          obj_data.put('dtecancel', to_char(r1.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dtesnd', to_char(r1.dtesnd,'dd/mm/yyyy'));

           -- << Apisit || 30/10/2023 || issue 4449: #1393,#1417,#1418
          obj_data.put('detail', r1.objective);
          obj_data.put('dteperiod', '');
          -- END >>

          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if flg_secur = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tkpireq');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;



  procedure gen_step_hres32e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
    select distinct numseq,approvno
      from tempaprq
      where codapp   = 'HRES32E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
    order by numseq,approvno;

  cursor c1 is
    select approvno,codappr,dteapph,dtesnd,staappr,
           remark
      from tapempch
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and typreq   = b_index_typreq
        and approvno = v_approvno
    order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;
        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;

        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres34e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
    select distinct numseq,approvno
      from tempaprq
      where codapp   = 'HRES34E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
    order by numseq,approvno;

  cursor c1 is
		select approvno,codappr,dteapph,dtesnd,staappr,
		       remarkap remark
      from tapmoverq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
    order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres36e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
    select distinct numseq,approvno
      from tempaprq
      where codapp   = 'HRES36E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
    order by numseq,approvno;

  cursor c1 is
    select approvno,codappr,dteapph,dtesnd,staappr,
			       remark
      from tapempch
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and typreq    = 'HRES36E'
        and approvno = v_approvno
    order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres62e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES62E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark,seqno
       from taplverq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and seqno    = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;

        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres6ae(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES6AE'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptimrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and dtework  = b_index_dtework
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;

        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

    procedure gen_step_hres6de(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES6DE'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remarkap remark
       from tapwrkrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and seqno    = v_numseq
        and dtework  = b_index_dtework
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;

        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres6ie(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES6IE'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,dteapph,dtesnd,staappr, -- user32 || 18/07/2019 || select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptrnrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
--          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres6ke(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES6KE'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptotrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres6me(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES6ME'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taplvecc
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and seqno    = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres71e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES71E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapmedrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres74e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES74E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapobfrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres77e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES77E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taploanrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
--        and codlon   = b_index_codlon
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres81e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES81E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptrvrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres86e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES86E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapresrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres88e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES88E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapjobrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
--        and codcomp  = b_index_codcomp
--        and codpos   = b_index_codpos
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres91e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES91E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptrcerq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres93e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES93E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taptrcanrq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hress2e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRESS2E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapempch
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and typreq    = 'HRESS2E'
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hress4e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRESS4E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapempch
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and typreq   = 'HRESS4E'
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres95e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES95E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from taprplerq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_step_hres17e(json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    v_numseq        number;
    v_approvno      number;
    v_typeapp       number;
    v_typeapp_name  varchar2(1000 char);
    v_staappr       varchar2(1000 char);
    o_dtesnd        varchar2(1000 char);
    o_dteapph       varchar2(1000 char);
    o_desc_codempap varchar2(1000 char);
    o_nam_status    varchar2(1000 char);
    o_remark        varchar2(1000 char);
    o_staappr       varchar2(1000 char);

  cursor c_tempaprq is
     select distinct numseq,approvno
       from tempaprq
      where codapp   = 'HRES17E'
        and codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = b_index_numseq
        and approvno <= b_index_approvno + 1
   order by numseq,approvno;

  cursor c1 is
     select approvno,codappr,dteapph,dtesnd,staappr,
            remark
       from tapkpirq
      where codempid = b_index_codempid
        and dtereq   = b_index_dtereq
        and numseq   = v_numseq
        and approvno = v_approvno
   order by approvno;

  begin
    obj_row  := json_object_t();
    for r1 in c_tempaprq loop
      v_total := v_total + 1;
    end loop;
    if v_total > 0 then
      for r_tempaprq in c_tempaprq loop
        v_numseq 		 := r_tempaprq.numseq;
        v_approvno 	 := r_tempaprq.approvno;
        begin
          select typeapp into v_typeapp
            from twkflowd
          where routeno = b_index_routeno
            and numseq  = r_tempaprq.approvno;
        exception when no_data_found then
          v_typeapp := null;
        end;

        if v_typeapp = 1 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif v_typeapp = 2 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif v_typeapp = 3 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif v_typeapp = 4 then
          v_typeapp_name := get_label_name('HRMS14XC3',global_v_lang,170);
        end if;

        o_dtesnd        := null;
        o_dteapph       := null;
        o_desc_codempap := null;
        o_nam_status    := null;
        o_remark        := null;
        o_staappr       := null;
        for r1 in c1 loop
          if r1.staappr = 'A' then
            v_staappr := 'Y';
          else
            v_staappr := r1.staappr;
          end if;

          o_dtesnd        := to_char(r1.dtesnd,'dd/mm/yyyy');
          o_dteapph       := to_char(r1.dteapph,'dd/mm/yyyy');
          o_desc_codempap := r1.codappr||' '||get_temploy_name(r1.codappr,global_v_lang);
          o_nam_status    := get_tlistval_name('STAAPPR',v_staappr,global_v_lang);
          o_remark        := replace(r1.remark,chr(13)||chr(10),'');
          o_staappr       := r1.staappr;
        end loop;

        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total);
        obj_data.put('seqno', v_approvno);
        obj_data.put('numseq', v_numseq);
        obj_data.put('typeapp', v_typeapp_name);
        obj_data.put('dtesnd', o_dtesnd);
        obj_data.put('dteapph', o_dteapph);
        obj_data.put('desc_codempap', o_desc_codempap);
        obj_data.put('nam_status', o_nam_status);
        obj_data.put('remark', o_remark);
        obj_data.put('staappr', o_staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure break_data(p_break_lv in number, arr_col in out arr) is
    v_concat_data   varchar2(4000 char);
  begin
    for i in 1..p_break_lv loop
      if not global_v_break.exists(i) then
        global_v_break(i) := '';
      end if;
    end loop;

    for i in reverse 1..p_break_lv loop
      v_concat_data := null;
      for j in 1..i loop
        v_concat_data := v_concat_data||arr_col(j);
      end loop;
      if v_concat_data = nvl(global_v_break(i), '$#@') then
        arr_col(i) := '';
      end if;
      global_v_break(i) := v_concat_data;
    end loop;
  end;

  procedure get_approve_name(p_numseq    in number,
                             p_namtype   in varchar2,
                             p_num       in out number,
                             obj_row in out json_object_t) is

		v_staemp          varchar2(1);
		v_namsta          varchar2(200);
		v_num       			number;
		v_exists    			varchar2(1)  	:= 'N';
		v_app							varchar2(100)	:= '!@#$%';

		v_flgflow         varchar2(1);
		v_flgasgn         varchar2(1);
		v_flgasem         varchar2(1);

		v_codempap        temploy1.codempid%type;
		v_codcompap       temploy1.codcomp%type;
		v_codposap        temploy1.codpos%type;

     cursor c_assign_emp  is
        select codempas codempid, '3' staappr  --assign by Employee
          from tassignm
           where codempid  = v_codempap
           and dtestrt  <= sysdate
           and (dteend  >= trunc(sysdate) or dteend is null )
           and flgassign = 'E'
        union
        select codempid, '3' staappr           --assign by Division/Position
          from temploy1
         where (staemp in ('1','3') and v_staemp = '3')
       --           or (staemp = '9' and v_staemp = '9') )
           and (codcomp,codpos) in (select codcomas,codposas
                                                  from tassignm
                                                   where codempid  = v_codempap
                                                   and dtestrt  <= sysdate
                                                   and (dteend  >= trunc(sysdate) or dteend is null )
                                                   and flgassign = 'P')
      order by codempid;

		cursor c_ttemprpt is
			select item1 codappr,item2 codempap,item3 codcompap,item4 codposap
			  from ttemprpt
			 where codapp   = 'HRMS14X'
		 	   and codempid = global_v_coduser
			order by item3,item4,item2,item1;

  begin
    for r1 in c_ttemprpt loop
      v_total1 := v_total1 + 1;
    end loop;
    v_num    := p_num;
    for i in c_ttemprpt loop
      v_exists  := 'N';
      if i.codempap||i.codcompap||i.codposap <> v_app then
        v_app := i.codempap||i.codcompap||i.codposap;
        v_num := 0;
      end if;
      if i.codempap is not null then
        v_exists  := 'Y';
        v_namsta  := get_label_name('HRMS14XC4',global_v_lang,950);
        v_row1 := v_row1+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total1);

        --check_break6
        arr_col := arr_empty;
        arr_col(1) := to_char(p_numseq);
        arr_col(2) := p_namtype;
        arr_col(3) := i.codempap;
        arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
        arr_col(5) := '';
        arr_col(6) := '';
        break_data(arr_col.count, arr_col);
        obj_data.put('numseq', arr_col(1));         --temp01
        obj_data.put('namtype', arr_col(2));        --item01
        obj_data.put('codempap', arr_col(3));       --item02
        obj_data.put('desc_codempap', arr_col(4));  --item03
        obj_data.put('desc_codcompap', arr_col(5)); --item04
        obj_data.put('desc_codposap', arr_col(6));  --item05
        --break6

--        obj_data.put('desc_staappr', v_namsta); --item08
        obj_data.put('status', v_namsta);
        obj_data.put('staappr', 'P');           --item09

        obj_row.put(to_char(v_row1-1),obj_data);
        v_staemp := '3';
        v_codempap := i.codempap;
        for l in c_assign_emp loop  -- assign
          v_flgasem := 'Y';
          v_namsta  := get_label_name('HRMS14XC4',global_v_lang,970);
          v_row1 := v_row1 + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total1);

          --check_break6
          arr_col := arr_empty;
          arr_col(1) := to_char(p_numseq);
          arr_col(2) := p_namtype;
          arr_col(3) := i.codempap;
          arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
          arr_col(5) := get_tcenter_name(i.codcompap,global_v_lang);
          arr_col(6) := get_tpostn_name(i.codposap,global_v_lang);
          break_data(arr_col.count, arr_col);
          obj_data.put('numseq', arr_col(1));         --temp01
          obj_data.put('namtype', arr_col(2));        --item01
          obj_data.put('codempap', arr_col(3));       --item02
          obj_data.put('desc_codempap', arr_col(4));  --item03
          obj_data.put('desc_codcompap', arr_col(5)); --item04
          obj_data.put('desc_codposap', arr_col(6));  --item05
          --break6

          v_num := v_num + 1;
          obj_data.put('num', v_num);             --temp02
          obj_data.put('codempid', l.codempid);   --item06
          obj_data.put('desc_codempid', get_temploy_name(l.codempid,global_v_lang)); --item07
--          obj_data.put('desc_staappr', v_namsta); --item08
          obj_data.put('status', v_namsta);
          obj_data.put('staappr', 'P');           --item09

          obj_row.put(to_char(v_row1-1),obj_data);
        end loop;

        if v_flgasem = 'N' then
          v_staemp := '9';
          for l in c_assign_emp loop  -- assign
            v_flgasem  := 'Y';
            v_namsta  := get_label_name('HRMS14XC4',global_v_lang,970);
            v_row1 := v_row1 + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', '');
            obj_data.put('flg', '');
            obj_data.put('total', v_total1);

            --check_break6
            arr_col := arr_empty;
            arr_col(1) := to_char(p_numseq);
            arr_col(2) := p_namtype;
            arr_col(3) := i.codempap;
            arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
            arr_col(5) := get_tcenter_name(i.codcompap,global_v_lang);
            arr_col(6) := get_tpostn_name(i.codposap,global_v_lang);
            break_data(arr_col.count, arr_col);
            obj_data.put('numseq', arr_col(1));         --temp01
            obj_data.put('namtype', arr_col(2));        --item01
            obj_data.put('codempap', arr_col(3));       --item02
            obj_data.put('desc_codempap', arr_col(4));  --item03
            obj_data.put('desc_codcompap', arr_col(5)); --item04
            obj_data.put('desc_codposap', arr_col(6));  --item05
            --break6

            v_num := v_num + 1;
            obj_data.put('num', v_num);             --temp02
            obj_data.put('codempid', l.codempid);   --item06
            obj_data.put('desc_codempid', get_temploy_name(l.codempid,global_v_lang)); --item07
--            obj_data.put('desc_staappr', v_namsta); --item08
            obj_data.put('status', v_namsta); --item08
            obj_data.put('staappr', 'C');           --item09

            obj_row.put(to_char(v_row1-1),obj_data);
          end loop;
        end if; --v_flgasem = 'Y'
      else
        v_staemp := '3';

        v_exists  := 'Y';
        v_flgflow := 'Y';
        v_namsta  := get_label_name('HRMS14XC4',global_v_lang,950);
        v_row1 := v_row1 + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total1);

        --check_break6
        arr_col := arr_empty;
        arr_col(1) := to_char(p_numseq);
        arr_col(2) := p_namtype;
        arr_col(3) := i.codempap;
        arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
        arr_col(5) := get_tcenter_name(i.codcompap,global_v_lang);
        arr_col(6) := get_tpostn_name(i.codposap,global_v_lang);
        break_data(arr_col.count, arr_col);
        obj_data.put('numseq', arr_col(1));         --temp01
        obj_data.put('namtype', arr_col(2));        --item01
        obj_data.put('codempap', arr_col(3));       --item02
        obj_data.put('desc_codempap', arr_col(4));  --item03
        obj_data.put('desc_codcompap', arr_col(5)); --item04
        obj_data.put('desc_codposap', arr_col(6));  --item05
        --break6

        v_num := v_num + 1;
        obj_data.put('num', v_num);             --temp02
        obj_data.put('codempid', i.codappr);    --item06
        obj_data.put('desc_codempid', get_temploy_name(i.codappr,global_v_lang)); --item07
--        obj_data.put('desc_staappr', v_namsta); --item08
        obj_data.put('status', v_namsta); --item08
        obj_data.put('staappr', 'P');           --item09

        obj_row.put(to_char(v_row1-1),obj_data);
        v_staemp := '3';
        for l in c_assign_emp loop  -- assign
          v_exists  := 'Y';
          v_flgasgn := 'Y';
          v_namsta  := get_label_name('HRMS14XC4',global_v_lang,970);
          v_row1 := v_row1 + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total1);

          --check_break6
          arr_col := arr_empty;
          arr_col(1) := to_char(p_numseq);
          arr_col(2) := p_namtype;
          arr_col(3) := i.codempap;
          arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
          arr_col(5) := get_tcenter_name(i.codcompap,global_v_lang);
          arr_col(6) := get_tpostn_name(i.codposap,global_v_lang);
          break_data(arr_col.count, arr_col);
          obj_data.put('numseq', arr_col(1));         --temp01
          obj_data.put('namtype', arr_col(2));        --item01
          obj_data.put('codempap', arr_col(3));       --item02
          obj_data.put('desc_codempap', arr_col(4));  --item03
          obj_data.put('desc_codcompap', arr_col(5)); --item04
          obj_data.put('desc_codposap', arr_col(6));  --item05
          --break6

          v_num := v_num + 1;
          obj_data.put('num', v_num);             --temp02
          obj_data.put('codempid', l.codempid);    --item06
          obj_data.put('desc_codempid', get_temploy_name(l.codempid,global_v_lang)); --item07
--          obj_data.put('desc_staappr', v_namsta); --item08
          obj_data.put('status', v_namsta); --item08
          obj_data.put('staappr', 'P');           --item09

          obj_row.put(to_char(v_row1-1),obj_data);
        end loop;

        if v_flgasgn = 'N' then
          v_staemp := '9';
          for l in c_assign_emp loop  -- assign
            v_exists  := 'Y';
            v_flgasgn := 'Y';
            v_namsta  := get_label_name('HRMS14XC4',global_v_lang,970);
            v_row1 := v_row1 + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', '');
            obj_data.put('flg', '');
            obj_data.put('total', v_total1);

            --check_break6
            arr_col := arr_empty;
            arr_col(1) := to_char(p_numseq);
            arr_col(2) := p_namtype;
            arr_col(3) := i.codempap;
            arr_col(4) := get_temploy_name(i.codempap,global_v_lang);
            arr_col(5) := get_tcenter_name(i.codcompap,global_v_lang);
            arr_col(6) := get_tpostn_name(i.codposap,global_v_lang);
            break_data(arr_col.count, arr_col);
            obj_data.put('numseq', arr_col(1));         --temp01
            obj_data.put('namtype', arr_col(2));        --item01
            obj_data.put('codempap', arr_col(3));       --item02
            obj_data.put('desc_codempap', arr_col(4));  --item03
            obj_data.put('desc_codcompap', arr_col(5)); --item04
            obj_data.put('desc_codposap', arr_col(6));  --item05
            --break6

            v_num := v_num + 1;
            obj_data.put('num', v_num);             --temp02
            obj_data.put('codempid', l.codempid);   --item06
            obj_data.put('desc_codempid', get_temploy_name(l.codempid,global_v_lang)); --item07
--            obj_data.put('desc_staappr', v_namsta); --item08
            obj_data.put('status', v_namsta); --item08
            obj_data.put('staappr', 'C');           --item09

            obj_row.put(to_char(v_row1-1),obj_data);
          end loop;
        end if;  --v_flgasgn = 'N'
      end if;

      if v_exists  = 'N' then
        v_row1 := v_row1 + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('total', v_total1);

        --check_break6
        arr_col := arr_empty;
        arr_col(1) := to_char(p_numseq);
        arr_col(2) := p_namtype;
        arr_col(3) := '';
        arr_col(4) := '';
        arr_col(5) := '';
        arr_col(6) := '';
        break_data(arr_col.count, arr_col);
        obj_data.put('numseq', arr_col(1));         --temp01
        obj_data.put('namtype', arr_col(2));        --item01
        obj_data.put('codempap', arr_col(3));       --item02
        obj_data.put('desc_codempap', arr_col(4));  --item03
        obj_data.put('desc_codcompap', arr_col(5)); --item04
        obj_data.put('desc_codposap', arr_col(6));  --item05
        --break6

        obj_row.put(to_char(v_row1-1),obj_data);
      end if;
    end loop; --for i in c_ttemprpt loop
    p_num := v_num;
  end;

  procedure get_approve_twkflowde(p_codempap  in varchar2,
			                            p_codcompap in varchar2,
			                            p_codposap  in varchar2,
																	p_numseq    in number,
		                            	p_namtype   in varchar2,
                                  p_num       in out number,
		                            	obj_row in out json_object_t) is

		v_namsta          varchar2(200);
		v_num       			number;
		v_exists    			varchar2(1)  := 'N';

--<<     old version
--		cursor c_twkflowde is
--			select codempid,'2' staappr  -- Assign Approve By
--			  from twkflowde
--			 where routeno  = b_index_routeno
--		 	   and numseq   = p_numseq
--			order by codempid;		
-->>

--<< redmine 4448#6159 kowit 23/12/2023
		cursor c_twkflowde is
			select t1.codempid,'2' staappr  -- Assign Approve By
			  from twkflowde t1, temploy1 t2
			 where t1.routeno  = b_index_routeno
		 	   and t1.numseq   = p_numseq
               and t1.codempid = t2.codempid 
               and staemp in ('1','3')
			order by t1.codempid;
-->> redmine 4448#6159 kowit 23/12/2023      


  begin
    v_num := p_num;
    for r1 in c_twkflowde loop
      v_total1 := v_total1 + 1;
    end loop;
    -- approve assign
    for k in c_twkflowde loop
      v_exists  := 'Y';
      --break6
      v_namsta  := get_label_name('HRMS14XC4',global_v_lang,960);
      v_row1 := v_row1 + 1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total1);

      --check_break6
      arr_col := arr_empty;
      arr_col(1) := to_char(p_numseq);
      arr_col(2) := p_namtype;
      arr_col(3) := p_codempap;
      arr_col(4) := get_temploy_name(p_codempap,global_v_lang);
      arr_col(5) := get_tcenter_name(p_codcompap,global_v_lang);
      arr_col(6) := get_tpostn_name(p_codposap,global_v_lang);
      break_data(arr_col.count, arr_col);
      obj_data.put('numseq', arr_col(1));         --temp01
      obj_data.put('namtype', arr_col(2));        --item01
      obj_data.put('codempap', arr_col(3));       --item02
      obj_data.put('desc_codempap', arr_col(4));  --item03
      obj_data.put('desc_codcompap', arr_col(5)); --item04
      obj_data.put('desc_codposap', arr_col(6));  --item05
      --break6

      v_num := v_num + 1;
      obj_data.put('num', to_char(v_num));             --temp02
      obj_data.put('codempid', k.codempid);   --item06
      obj_data.put('desc_codempid', get_temploy_name(k.codempid,global_v_lang)); --item07
--      obj_data.put('desc_staappr', v_namsta); --item08
      obj_data.put('status', v_namsta); --item08
      obj_data.put('staappr', 'P');           --item09
      obj_row.put(to_char(v_row1-1),obj_data);
    end loop;
    if v_exists  = 'N' then
      v_row1 := v_row1 + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('total', v_total1);

      --check_break6
      arr_col := arr_empty;
      arr_col(1) := to_char(p_numseq);
      arr_col(2) := p_namtype;
      arr_col(3) := '';
      arr_col(4) := '';
      arr_col(5) := '';
      arr_col(6) := '';
      break_data(arr_col.count, arr_col);
      obj_data.put('numseq', 'arr_col(1)');         --temp01
      obj_data.put('namtype', arr_col(2));        --item01
      obj_data.put('codempap', arr_col(3));       --item02
      obj_data.put('desc_codempap', arr_col(4));  --item03
      obj_data.put('desc_codcompap', arr_col(5)); --item04
      obj_data.put('desc_codposap', arr_col(6));  --item05
      --break6

      obj_row.put(to_char(v_row1-1),obj_data);
    end if;
    p_num := v_num;
  end;

  procedure save_tempaprq (p_codapp     in varchar2,
                           p_codempid   in varchar2,
                           p_dtereq     in date,
                           p_numseq     in varchar2,
                           p_approvno   in varchar2,
                           p_seqno      in varchar2,
                           p_codempap   in varchar2,
                           p_codcompap  in varchar2,
                           p_codposap   in varchar2) is
      v_count      number;
      v_codapp     varchar2(100 char);
      v_codempid   varchar2(100 char);
      v_dtereq     date;
      v_numseq     varchar2(100 char);
      v_approvno   varchar2(100 char);
      v_seqno      varchar2(100 char);
      v_codempap   varchar2(100 char);
      v_codcompap  varchar2(100 char);
      v_codposap   varchar2(100 char);
  begin
      v_codapp     := p_codapp;
      v_codempid   := p_codempid;
      v_dtereq     := p_dtereq;
      v_numseq     := p_numseq;
      v_approvno   := p_approvno;
      v_seqno      := p_seqno;
      v_codempap   := p_codempap;
      v_codcompap  := p_codcompap;
      v_codposap   := p_codposap;
      v_count := 0;
      if v_seqno is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if v_codcompap is null and v_codposap is null and v_codempap is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if v_codcompap is not null then
        v_codcompap := rpad(v_codcompap, 21, '0');
        begin
          select codcomp into v_codcompap
            from tcenter
           where codcomp like upper(v_codcompap) and rownum <= 1;
        exception when others then
          v_codcompap := null;
        end;
        if v_codcompap is null then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcompap');
          return;
        end if;
      end if;
--      begin
--        select seqno into v_seqno
--          from tempaprq
--         where codapp   = v_codapp
--		       and codempid = v_codempid
--		       and dtereq   = v_dtereq
--	 	       and numseq   = v_numseq
--		       and approvno = v_approvno
--		       and seqno    = v_seqno;
--      exception when others then
--        v_seqno := null;
--      end;
--
--      if v_seqno is not null then
--        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
--        return;
--      end if;
      if v_codcompap is not null or v_codposap is not null then
        v_codempap := null;
        if v_codcompap is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
        end if;
        if v_codposap is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
        else
          begin
            select codpos into v_codposap
              from tpostn
             where codpos = v_codposap;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
          end;
        end if;
      end if;
      if v_codempap is not null then
        begin
          select codempid into v_codempap
            from temploy1
           where codempid = v_codempap;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        end;
      end if;

      begin
        select count(*) into v_count
          from tempaprq
         where codapp   = v_codapp
		       and codempid = v_codempid
		       and dtereq   = v_dtereq
	 	       and numseq   = v_numseq
		       and approvno = v_approvno
		       and seqno    = v_seqno;
      exception when no_data_found then
        v_count := 0;
      end;
      if b_index_flg = 'delete' then

          delete from tempaprq
                where codapp   = v_codapp
                  and codempid = v_codempid
                  and dtereq   = v_dtereq
                  and numseq   = v_numseq
                  and approvno = v_approvno
                  and seqno    = v_seqno;
      else
        if v_count = 0 then
          insert into tempaprq (codapp, codempid, dtereq, numseq, approvno, seqno,
                                codempap, codcompap, codposap, dteupd, coduser)
               values (v_codapp, v_codempid, v_dtereq, v_numseq, v_approvno, v_seqno,
                       v_codempap, v_codcompap, v_codposap,trunc(sysdate), global_v_coduser);
        else
          update tempaprq set codempap  = v_codempap,
                              codcompap = v_codcompap,
                              codposap  = v_codposap,
                              dteupd    = trunc(sysdate),
                              coduser   = global_v_coduser
           where codapp   = v_codapp
             and codempid = v_codempid
             and dtereq   = v_dtereq
             and numseq   = v_numseq
             and approvno = v_approvno
             and seqno    = v_seqno;
        end if;
      end if;

--      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
--  exception when others then
--    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    return;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) is
    obj_row json_object_t;
    v_chk   number;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      if b_index_codapp = 'HRES32E' then
        gen_hres32e(json_str_output);
      elsif b_index_codapp = 'HRES34E' then
        gen_hres34e(json_str_output);
      elsif b_index_codapp = 'HRES36E' then
        gen_hres36e(json_str_output);
      elsif b_index_codapp = 'HRES62E' then
        gen_hres62e(json_str_output);
      elsif b_index_codapp = 'HRES6AE' then
        gen_hres6ae(json_str_output);
      elsif b_index_codapp = 'HRES6DE' then
        gen_hres6de(json_str_output);
      elsif b_index_codapp = 'HRES6IE' then
        gen_hres6ie(json_str_output);
      elsif b_index_codapp = 'HRES6KE' then
        gen_hres6ke(json_str_output);
      elsif b_index_codapp = 'HRES6ME' then
        gen_hres6me(json_str_output);
      elsif b_index_codapp = 'HRES71E' then
        gen_hres71e(json_str_output);
      elsif b_index_codapp = 'HRES74E' then
        gen_hres74e(json_str_output);
      elsif b_index_codapp = 'HRES77E' then
        gen_hres77e(json_str_output);
      elsif b_index_codapp = 'HRES81E' then
        gen_hres81e(json_str_output);
      elsif b_index_codapp = 'HRES86E' then
        gen_hres86e(json_str_output);
      elsif b_index_codapp = 'HRES88E' then
        gen_hres88e(json_str_output);
      elsif b_index_codapp = 'HRES91E' then
        gen_hres91e(json_str_output);
      elsif b_index_codapp = 'HRES93E' then
        gen_hres93e(json_str_output);
      elsif b_index_codapp = 'HRESS2E' then
        gen_hress2e(json_str_output);
      elsif b_index_codapp = 'HRESS4E' then
        gen_hress4e(json_str_output);
      elsif b_index_codapp = 'HRES95E' then
        gen_hres95e(json_str_output);
      elsif b_index_codapp = 'HRES17E' then
        gen_hres17e(json_str_output);
      end if;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_table1popup1(json_str_input in clob, json_str_output out clob) is
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      if b_index_codapp = 'HRES32E' then
        gen_step_hres32e(json_str_output);
      elsif b_index_codapp = 'HRES34E' then
        gen_step_hres34e(json_str_output);
      elsif b_index_codapp = 'HRES36E' then
        gen_step_hres36e(json_str_output);
      elsif b_index_codapp = 'HRES62E' then
        gen_step_hres62e(json_str_output);
      elsif b_index_codapp = 'HRES6AE' then
        gen_step_hres6ae(json_str_output);
      elsif b_index_codapp = 'HRES6DE' then
        gen_step_hres6de(json_str_output);
      elsif b_index_codapp = 'HRES6IE' then
        gen_step_hres6ie(json_str_output);
      elsif b_index_codapp = 'HRES6KE' then
        gen_step_hres6ke(json_str_output);
      elsif b_index_codapp = 'HRES6ME' then
        gen_step_hres6me(json_str_output);
      elsif b_index_codapp = 'HRES71E' then
        gen_step_hres71e(json_str_output);
      elsif b_index_codapp = 'HRES74E' then
        gen_step_hres74e(json_str_output);
      elsif b_index_codapp = 'HRES77E' then
        gen_step_hres77e(json_str_output);
      elsif b_index_codapp = 'HRES81E' then
        gen_step_hres81e(json_str_output);
      elsif b_index_codapp = 'HRES86E' then
        gen_step_hres86e(json_str_output);
      elsif b_index_codapp = 'HRES88E' then
        gen_step_hres88e(json_str_output);
      elsif b_index_codapp = 'HRES91E' then
        gen_step_hres91e(json_str_output);
      elsif b_index_codapp = 'HRES93E' then
        gen_step_hres93e(json_str_output);
      elsif b_index_codapp = 'HRESS2E' then
        gen_step_hress2e(json_str_output);
      elsif b_index_codapp = 'HRESS4E' then
        gen_step_hress4e(json_str_output);
      elsif b_index_codapp = 'HRES95E' then
        gen_step_hres95e(json_str_output);
      elsif b_index_codapp = 'HRES17E' then
        gen_step_hres17e(json_str_output);
      end if;
    else
      obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',param_msg_error);
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_table1popup2(json_str_input in clob, json_str_output out clob) is
    obj_row json_object_t;

    flg_data    			varchar2(1)  := 'N';
		v_codapp    			varchar2(30) := 'HRMS14X2';
		v_where     			varchar2(1000);
		v_num       			number := 0;
		flgpass     			boolean;
		v_zupdsal   			varchar2(1);
		v_codcomp       	temploy1.codcomp%type;
		v_codpos        	temploy1.codpos%type;
		v_codempap        temploy1.codempid%type;
		v_codcompap       temploy1.codcomp%type;
		v_codposap        temploy1.codpos%type;
		v_namtype         varchar2(200);
		v_flgflow         varchar2(1);
		v_flgasgn         varchar2(1);
		v_flgasem         varchar2(1);

		-- ad by pratay 12/05/2010 -----------
		v_codcompy       varchar2(4);
		v_codlinef       varchar2(4);
		v_dteeffec       date;
		v_pageno         number;
		v_rowno          number;
		v_columnno       number;
		v_setorg2        varchar2(1) := 'N';
		v_typedata			 varchar2(1);

		v_codempid			temploy1.codempid%type;
		v_first					varchar2(1);

    json_obj          json_object_t;
    json_obj_output   json_object_t;
    t_numseq			    varchar2(4000 char);
    t_namtype			    varchar2(4000 char);
    t_codempap			  varchar2(4000 char);
    t_desc_codempap		varchar2(4000 char);
    t_desc_codcompap	varchar2(4000 char);
    t_desc_codposap		varchar2(4000 char);
    t_num		          varchar2(4000 char);
    v_row             number := 0;

    cursor c1 is
			select numseq,routeno,typeapp
			  from twkflowd
			 where routeno = b_index_routeno
			order by numseq;

		cursor c_emp is
			select codempid
			  from temploy1
			 where codcomp = v_codcomp
			 	 and codpos  = v_codpos
                 and staemp in ('1','3')
			order by codempid;

		cursor c_emphead is
			select distinct item1 codempid
				from ttemprpt
			 where codapp 	= 'HRMS14X'
			 	 and codempid = global_v_coduser
			order by item1;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    if param_msg_error is null then
      v_row1   := 0;
      v_total1 := 0;
      v_codempid  := b_index_codempid;
      v_first		 	:= 'Y';
      for i in c1 loop
        flg_data  := 'Y';
        v_num     := 0;

        if i.typeapp = 1 then 		-- Supervisor
          v_namtype  := get_label_name('HRMS14XC3',global_v_lang,140);
        elsif i.typeapp = 2 then 	-- By Organization
          v_namtype  := get_label_name('HRMS14XC3',global_v_lang,150);
        elsif i.typeapp = 3 then 	-- Position
          v_namtype  := get_label_name('HRMS14XC3',global_v_lang,160);
        elsif i.typeapp = 4 then 	--Employee
          v_namtype  := get_label_name('HRMS14XC3',global_v_lang,170);
        end if; --typeapp
        --
        if v_first = 'Y' then
          gen_approval_list(v_codempid,b_index_routeno,i.numseq,'HRMS14X',global_v_coduser);
          get_approve_name(i.numseq,v_namtype,v_num,obj_row);
        else
          for k in c_emphead loop
            v_codempid := k.codempid;
            gen_approval_list(v_codempid,b_index_routeno,i.numseq,'HRMS14X',global_v_coduser);
            get_approve_name(i.numseq,v_namtype,v_num,obj_row);
          end loop;
        end if;
        --
        --<<Find last codempap,codcompap,codposap
        begin
          select item2 codempap,item3 codcompap,item4 codposap
            into v_codempid,v_codcomp,v_codpos
            from ttemprpt
           where codapp 	= 'HRMS14X'
             and codempid = global_v_coduser
             and numseq		= (	select max(numseq)
                          from ttemprpt
                         where codapp 	= 'HRMS14X'
                           and codempid = global_v_coduser);
        exception when no_data_found then
          v_codempid := null; v_codcomp := null; v_codpos := null;
        end;
        -->>Find last codempap,codcompap,codposap
        get_approve_twkflowde(v_codempid,v_codcomp,v_codpos,i.numseq,v_namtype,v_num,obj_row);

        v_first		 := 'N';
      end loop; -- for i in c1 loop

      -- remove empty row
      v_row := 0;
      json_obj_output := json_object_t();
      for i in 0..obj_row.get_size-1 loop
        json_obj := hcm_util.get_json_t(obj_row,to_char(i));
        t_numseq          := hcm_util.get_string_t(json_obj,'numseq');
        t_namtype         := hcm_util.get_string_t(json_obj,'namtype');
        t_codempap        := hcm_util.get_string_t(json_obj,'codempap');
        t_desc_codempap   := hcm_util.get_string_t(json_obj,'desc_codempap');
        t_desc_codcompap  := hcm_util.get_string_t(json_obj,'desc_codcompap');
        t_desc_codposap   := hcm_util.get_string_t(json_obj,'desc_codposap');
        t_num             := hcm_util.get_string_t(json_obj,'num');

        if t_numseq is null and t_namtype is null and t_codempap is null and t_desc_codempap is null and t_desc_codcompap is null and t_desc_codposap is null then
          obj_row.remove(to_char(i));
        else
          json_obj_output.put(to_char(v_row),json_obj);
          v_row := v_row + 1;
        end if;

      end loop;
      --
      json_str_output := json_obj_output.to_clob;
    else
      obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',param_msg_error);
      json_str_output := obj_row.to_clob;
    end if;


  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_table1popup1popup1(json_str_output out clob) is
   obj_row     json_object_t;
    v_total     number := 0;
    v_row       number := 0;

  cursor c1 is
    select seqno,codcompap,codposap,codempap
      from tempaprq
     where codapp 	= b_index_codapp
       and codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and approvno = b_index_approvno
       order by seqno;
  begin
      obj_row  := json_object_t();
      for r1 in c1 loop
        v_total := v_total + 1;
      end loop;
      if v_total > 0 then
        for r1 in c1 loop
          v_row := v_row+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total', v_total);
          obj_data.put('seqno', r1.seqno);
          obj_data.put('codcompap', r1.codcompap);
          obj_data.put('codposap', r1.codposap);
          obj_data.put('codempap', r1.codempap);
          obj_data.put('desc_codempap', get_temploy_name(r1.codempap,global_v_lang));

          obj_row.put(to_char(v_row-1),obj_data);
        end loop;
      end if;
      json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_table1popup1popup1(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_table1popup1popup1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_table1popup1popup1(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    json_obj2       json_object_t;
    v_rowcount      number:= 0;
    v_codapp        varchar2(1000 char);
    v_codempid      varchar2(1000 char);
    v_dtereq        date;
    v_numseq        varchar2(1000 char);
    v_approvno      varchar2(1000 char);
    v_seqno         varchar2(1000 char);
    v_codempap      varchar2(1000 char);
    v_codcompap     varchar2(1000 char);
    v_codposap      varchar2(1000 char);

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      json_obj := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
      for i in 0..json_obj.get_size-1 loop
        json_obj2   := hcm_util.get_json_t(json_obj,to_char(i));

        v_seqno     := hcm_util.get_string_t(json_obj2,'seqno');
        v_codempap  := hcm_util.get_string_t(json_obj2,'codempap');
        v_codcompap := hcm_util.get_string_t(json_obj2,'codcompap');
        v_codposap  := hcm_util.get_string_t(json_obj2,'codposap');
        b_index_flg := hcm_util.get_string_t(json_obj2,'flg');

        save_tempaprq(b_index_codapp,b_index_codempid,b_index_dtereq,b_index_numseq,b_index_approvno,v_seqno,v_codempap,v_codcompap,v_codposap);
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;

end;

/

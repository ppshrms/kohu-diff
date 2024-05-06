--------------------------------------------------------
--  DDL for Package Body M_HRES62E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRES62E" is
  /* Cust-Modify: KOHU-SM2301 */
  -- last update: 14/12/2023 12:00

  procedure get_tleavecc_detail(p_codempid in varchar2,p_seqnor in varchar2,p_dtereqr in date) is
  begin
    begin
      select staappr,remarkap,codappr,dteappr,
             chk_workflow.get_next_approve('HRES6ME',codempid,to_char(dtereq,'dd/mm/yyyy'),seqno,nvl(trim(approvno),'0'),global_v_lang)
        into tleavecc_staappr,tleavecc_remarkap,tleavecc_codappr,tleavecc_dteappr,tleavecc_codempap
        from tleavecc
       where dtereqr  = p_dtereqr
         and seqnor   = p_seqnor
         and codempid = p_codempid
         and seqno    = (select max(seqno)
                           from tleavecc
                          where dtereqr  = p_dtereqr
                            and seqnor   = p_seqnor
                            and codempid = p_codempid);
    exception when no_data_found then
      tleavecc_staappr  := null;
      tleavecc_remarkap := null;
      tleavecc_codappr  := null;
      tleavecc_codempap := null;
    end;
  end;

  procedure check_index as
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if b_index_codempid is not null and b_index_codempid <> global_v_codempid then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dtereq_st is not null and b_index_dtereq_en is not null then
      if b_index_dtereq_st > b_index_dtereq_en then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_empid          := hcm_util.get_string_t(json_obj,'codinput');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index
    b_index_codempid        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    if b_index_codempid is null then
       b_index_codempid := global_v_codempid;
    end if;

    b_index_seqno           := to_number(hcm_util.get_string_t(json_obj,'seqno'));
    b_index_dtereq          := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    b_index_codcomp         := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereq_st       := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en       := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    b_index_dtework         := to_date(hcm_util.get_string_t(json_obj,'p_dtework'),'dd/mm/yyyy');

    --block tleaverq
    tleaverq_codempid       := hcm_util.get_string_t(json_obj,'codempid_query');
    tleaverq_seqno          := to_number(hcm_util.get_string_t(json_obj,'seqno'));
    tleaverq_dtereq         := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    tleaverq_codleave       := hcm_util.get_string_t(json_obj,'codleave');
    tleaverq_desc_codleave  := null;
    tleaverq_deslereq       := hcm_util.get_string_t(json_obj,'deslereq');
    tleaverq_codshift       := hcm_util.get_string_t(json_obj,'codshift');
    tleaverq_dteleave       := to_date(trim(hcm_util.get_string_t(json_obj,'dteleave')),'dd/mm/yyyy');
    tleaverq_flgleave       := hcm_util.get_string_t(json_obj,'flgleave');
    tleaverq_dtestrt        := to_date(trim(hcm_util.get_string_t(json_obj,'dtestrt')),'dd/mm/yyyy');
    tleaverq_dteend         := to_date(trim(hcm_util.get_string_t(json_obj,'dteend')),'dd/mm/yyyy');
    tleaverq_codinput       := hcm_util.get_string_t(json_obj,'codinput');
    tleaverq_v_filenam1     := hcm_util.get_string_t(json_obj,'filenam1');
    tleaverq_filenam1       := null;
    tleaverq_codcomp        := null;
    tleaverq_v_timstrt      := trim(REPLACE(hcm_util.get_string_t(json_obj,'timstrt'),':',''));
    p_timstrt               := hcm_util.get_string_t(json_obj,'timstrt');
    tleaverq_timstrt        := trim(REPLACE(hcm_util.get_string_t(json_obj,'timstrt'),':',''));
    tleaverq_v_timend       := trim(REPLACE(hcm_util.get_string_t(json_obj,'timend'),':',''));
    p_timend                := hcm_util.get_string_t(json_obj,'timend');
    tleaverq_timend         := trim(REPLACE(hcm_util.get_string_t(json_obj,'timend'),':',''));
    tleaverq_numlereq       := null;
    tleaverq_codappr        := null;
    tleaverq_staappr        := hcm_util.get_string_t(json_obj,'staappr');
    tleaverq_dteupd         := to_date(trim(to_char(sysdate,'dd/mm/yyyy')),'dd/mm/yyyy');
    tleaverq_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    tleaverq_approvno       := null;
    tleaverq_remarkap       := null;
    tleaverq_dteappr        := null;
    tleaverq_routeno        := hcm_util.get_string_t(json_obj,'routeno');
    tleaverq_dteinput       := to_date(trim(hcm_util.get_string_t(json_obj,'dteinput')),'dd/mm/yyyy');
    tleaverq_desleave       := null;
    tleaverq_param_json     := hcm_util.get_json_t(json_obj, 'param_json');

    -- paternity leave --
    tleaverq_timprgnt       := hcm_util.get_string_t(json_obj,'timprgnt');
    tleaverq_dteprgntst     := to_date(trim(hcm_util.get_string_t(json_obj,'dteprgntst')),'dd/mm/yyyy');
    --
    p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
    p_dayeupd           := null;

    --block details
    details_staleave        := '';
    --block detail2
    detail2_qtyday1         := 0;
    detail2_qtyday2         := 0;
    detail2_qtyday3         := 0;
    detail2_qtyday4         := 0;
    detail2_qtyday5         := 0;
    detail2_qtyday6         := 0;
    detail2_flgdlemx        := '';
    detail2_staleave        := '';
    detail2_typleave        := 'A';
    detail2_destype         := '';
    detail2_qtytime         := 0;
    detail2_day1            := 0;
    detail2_day2            := 0;
    detail2_day3            := 0;
    detail2_day4            := 0;
    detail2_day5            := 0;
    detail2_day6            := 0;
    detail2_hur1            := 0;
    detail2_hur2            := 0;
    detail2_hur3            := 0;
    detail2_hur4            := 0;
    detail2_hur5            := 0;
    detail2_hur6            := 0;
    detail2_min1            := 0;
    detail2_min2            := 0;
    detail2_min3            := 0;
    detail2_min4            := 0;
    detail2_min5            := 0;
    detail2_min6            := 0;
    --param
    param_flgwarn           := hcm_util.get_string_t(json_obj,'flgwarning');
    param_msg_error         := null;
    param_warn              := null;
    param_v_summin          := 0;
    param_qtyavgwk          := 0;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  function gen_numseq return number is
    v_num  number :=0;
  begin
    begin
      select nvl(max(seqno),0) + 1
        into v_num
        from tleaverq
       where codempid = b_index_codempid
         and dtereq = trunc(sysdate);
    end;

    return(v_num);
  end;
  --
  procedure cal_dhm
    (p_qtyavgwk in  number,
     p_qtyday   in  number,
     p_day      out number,
     p_hour     out number,
     p_min      out number)
  IS
    v_min   number;
    v_hour  number(2) := 0;
    v_day   number := 0;
    v_num   number := 0;

  begin
      if nvl(p_qtyday,0) > 0 then
          v_day   := trunc(p_qtyday / 1);
          v_num   := round(mod((p_qtyday * p_qtyavgwk),p_qtyavgwk),0);
          v_hour  := trunc(v_num / 60);
          v_min   := mod(v_num,60);

      end if;
        p_day := nvl(v_day,0); p_hour := nvl(v_hour,0); p_min := nvl(v_min,0);
  end;
--

  procedure check_data is
    v_numlvl      temploy1.numlvl%type;
    v_dteeffex    temploy1.dteeffex%type;
    v_codpos      temploy1.codpos%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_codsex      temploy1.codsex%type;
    v_codempmt    temploy1.codempmt%type;
    v_typemp      temploy1.typemp%type;
    v_codcomp     temploy1.codcomp%type;
    v_codleave    tleavecd.codleave%type;
    v_typleave    tleavecd.typleave%type;
    v_staleave    tleavecd.staleave%type;
    v_descond     tleavecd.syncond%type;
    v_flgdlemx    tleavety.flgdlemx%type;
    v_staemp      temploy1.staemp%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codcalen    temploy1.codcalen%type;
    v_codjob      temploy1.codjob%type;
    v_codbrlc     temploy1.codbrlc%type;
    v_codgrpgl    temploy1.codgrpgl%type;
    v_typpayroll  temploy1.typpayroll%type;
    v_codrelgn    temploy2.codrelgn%type;
    v_dtestrt     date;
    v_dteend      date;
    v_sum         number;
    v_year        number;
    v_month       number;
    v_day         number;
    v_yrecycle    number(4);
    v_dtecycst    date;
    v_dtecycen    date;
    v_sum_min     number;
    v_sum_hour    number;
    v_sum_day     number;
    v_tattence    number;
    v_qtyday      number(2);
    v_seqno       tleaverq.seqno%type;
    v_qtydlepery  number;
    v_chk1        number:=0;
    v_chk2        number:=0;

    v_flgfwbwlim  varchar2(1);
    v_qtyminle    number;
    v_qtydlefw    number;
    v_qtydlebw    number;

    v_dtefw       date;
    v_dteaw       date;

    v_timeEF      number;
    v_timeEE      number;
    v_min         number;
    v_flg_leave   varchar2(1 char);
    v_codshift    varchar2(100 char);
    v_timstrtw    varchar2(100 char);
    v_timendw     varchar2(100 char);
    v_timstrtb    varchar2(100 char);
    v_timendb     varchar2(100 char);
    v_timreq      varchar2(4 char);
    v_timleave    varchar2(4 char);

    v_flg         varchar2(1 char);
    v_count       number;

    v_coderror    varchar2(100 char);
    v_qtytimle2   tleavety.qtytimle%type;
    v_flgtimle2   tleavety.flgtimle%type;
    v_qtyminrq    number;
    v_qtyavgwk    number;
    v_chkleave    number;
    v_flgdlebw    varchar2(2 char);
    v_flgdlefw    varchar2(2 char);

    v_check_emp_flow    number;
  begin
      tleaverq_codempid      := b_index_codempid;
      tleaverq_desc_codleave := get_tleavecd_name(tleaverq_codleave, global_v_lang);
      if b_index_dtereq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleaverq_codleave is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleaverq_dtestrt is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleaverq_v_timstrt is null and tleaverq_v_timend is not null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleaverq_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
      if tleaverq_v_timend is null and tleaverq_v_timstrt is not null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;

      if tleaverq_staappr is null then
        begin
            select count(*)
            into v_check_emp_flow
            from tempflow
            where codempid = b_index_codempid
                and codapp = 'HRES62E';
        end;

        if v_check_emp_flow = 0 then
            param_msg_error := get_error_msg_php('ESZ004', global_v_lang);

            return;
        end if;
      end if;

      begin
        select codcomp,numlvl,staemp,dteeffex,codpos,
               dteempmt,codsex,codempmt,typemp ,codrelgn,
               jobgrade,codcalen,codjob,codbrlc,codgrpgl
        into   tleaverq_codcomp,v_numlvl,v_staemp,v_dteeffex,v_codpos,
               v_dteempmt,v_codsex,v_codempmt,v_typemp,v_codrelgn,
               v_jobgrade,v_codcalen,v_codjob,v_codbrlc,v_codgrpgl
        from   temploy1 a,temploy2 b
        where  a.codempid = b.codempid
        and    a.codempid = b_index_codempid;
        if v_staemp = '0' then
          param_msg_error := get_error_msg_php('HR2102',global_v_lang);
          return;
        elsif v_staemp = '9' and tleaverq_dtestrt >= v_dteeffex then
          param_msg_error := get_error_msg_php('HR2101',global_v_lang);
          return;
        end if;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      begin
        select qtyavgwk into param_qtyavgwk
        from   tcontral
        where  codcompy = hcm_util.get_codcomp_level(tleaverq_codcomp,'1')
        and    dteeffec = (select max(dteeffec)
                           from   tcontral
                           where  codcompy = hcm_util.get_codcomp_level(tleaverq_codcomp,'1')
                           and    dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
        and    rownum <= 1
        order by codcompy,dteeffec;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontral');
        return;
      end;

      begin
        select codleave,typleave,staleave,syncond
        into   v_codleave,v_typleave,v_staleave,v_descond
        from   tleavecd
        where  codleave = tleaverq_codleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tleavecd');
        return;
      end;
      begin
        select typleave,flgdlemx,nvl(qtydlepery,0),qtytimle,flgtimle
        into   v_typleave,v_flgdlemx,v_qtydlepery,v_qtytimle2,v_flgtimle2
        from   tleavety
        where  typleave = v_typleave;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tleavety');
        return;
      end;
      v_dtestrt := to_date(to_char(tleaverq_dtestrt,'dd/mm/yyyy')||' '||tleaverq_v_timstrt,'dd/mm/yyyy hh24mi');
      v_dteend  := to_date(to_char(tleaverq_dteend,'dd/mm/yyyy')||' '||tleaverq_v_timend,'dd/mm/yyyy hh24mi');

      if v_dtestrt > v_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
      end if;
      if get_payroll_active('HRES62E',tleaverq_codempid,tleaverq_dtestrt,tleaverq_dteend) = 'Y' then
        param_msg_error := get_error_msg_php('ES0057',global_v_lang);
        return;
      end if;
--<< user22 : 14/03/2016 : STA3590240 ||
      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = tleaverq_codempid;
      exception when no_data_found then null;
      end;
-->> user22 : 14/03/2016 : STA3590240 ||

      if tleaverq_v_filenam1 is not null then
        tleaverq_filenam1 := substr(tleaverq_v_filenam1,instr(tleaverq_v_filenam1,'\',-1)+1);
      end if;
      if tleaverq_seqno is null then
          tleaverq_seqno    := gen_numseq;--b_index_seqno ;
          b_index_seqno     := tleaverq_seqno;
          tleaverq_dtereq   := b_index_dtereq;
      end if;

  -----------------------------user46------------------------------------
      begin
        select qtyminle,qtydlefw,qtydlebw
        into   v_qtyminle,v_qtydlefw,v_qtydlebw
        from   tleavecd
        where  codleave = tleaverq_codleave;
      exception when no_data_found then null;
      end;

      v_flgfwbwlim :=  'N';
      if v_qtydlefw is not null or v_qtydlebw is not null then
        v_flgfwbwlim :=  'Y';
      end if;

      v_flg_leave := 'N';

      if b_index_dtereq = tleaverq_dteleave then
        v_timreq := to_number(to_char(sysdate,'hh24mi'));

        begin
          select  codshift,timstrtw,timendw,timstrtb,timendb
          into    v_codshift, v_timstrtw,v_timendw,v_timstrtb,v_timendb
          from    tshiftcd
          where   codshift  = (select codshift from tattence
                               where  codempid  = b_index_codempid
                               and    dtework   = tleaverq_dteleave);
        exception when others then null;
        end;

        if tleaverq_flgleave in ('A','M') then
          v_timleave := to_number(v_timstrtw);
        elsif tleaverq_flgleave = 'E' then
          v_timleave := to_number(nvl(v_timendb,v_timstrtw));
        elsif tleaverq_flgleave = 'H' then
          v_timleave := tleaverq_v_timstrt;
        end if;

        if v_timreq > v_timleave then
          v_flg_leave := 'A';
        else
          v_flg_leave := 'B';
        end if;

      end if;

    if tleaverq_dteleave >= b_index_dtereq or v_flg_leave = 'B' then
      --Before
        if v_qtydlefw is not null then
          v_dtefw := b_index_dtereq + nvl(v_qtydlefw,0);
--          v_flgdlefw := check_leave_before(b_index_codempid,b_index_dtereq,tleaverq_dteleave,nvl(v_qtydlefw,0));
--          if v_flgdlefw = 'N' then

          if tleaverq_dteleave < v_dtefw then
            if v_flgfwbwlim = 'N' then
              param_msg_error := get_error_msg_php('AL0047',global_v_lang);
              return;
            else
--              if nvl(param_flgwarn, 'N') = 'N' then
--                param_msg_error := get_error_msg_php('AL0047',global_v_lang);
--                param_warn := 'warning';
--                return;
--              else
--                if param_flgwarn <> 'Y' then
                  param_msg_error := get_error_msg_php('AL0047',global_v_lang);
                  return;
--                end if;
--              end if;

              --v_ok := alert_error.alert_data('AL0047',global_v_lang);
              --if not v_ok then
              --  go_item('tleaverq_dteleave');
              --  raise form_trigger_failure;
              --end if;
            end if;
          end if;
        end if;
    elsif  tleaverq_dteleave < b_index_dtereq or v_flg_leave = 'A' then
      --After
      if v_qtydlebw is not null then
        v_dteaw := b_index_dtereq - nvl(v_qtydlebw,0);
        v_flgdlebw := check_leave_after(b_index_codempid,b_index_dtereq,tleaverq_dteleave,nvl(v_qtydlebw,0));
--          if v_dteaw > tleaverq_dteleave then
        if v_flgdlebw = 'N' then
            if v_flgfwbwlim = 'N' then
              param_msg_error := get_error_msg_php('AL0048',global_v_lang);
              return;
            else
--              if nvl(param_flgwarn, 'N') = 'N' then
--                param_msg_error := get_error_msg_php('AL0048',global_v_lang);
--                param_msg_error := param_msg_error;
--                param_warn := 'warning';
--                return;
--              else
--                if param_flgwarn <> 'Y' then
                  param_msg_error := get_error_msg_php('AL0048',global_v_lang);
                  return;
--                end if;
--              end if;
              --v_ok := alert_error.alert_data('AL0048',global_v_lang);
              --if not v_ok then
              --  go_item('tleaverq_dteleave');
              --  raise form_trigger_failure;
              --end if;
            end if;
        end if;
      end if;
    end if;

    if tleaverq_flgleave = 'H' then
      if tleaverq_v_timend is null and tleaverq_v_timstrt is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end if;
    end if;
    begin
      select count(*) into v_chkleave
      from tleaverq
      where codempid  = tleaverq_codempid
      and    dtereq   = tleaverq_dtereq
      and    seqno    = tleaverq_seqno;
    end;
    if v_chkleave = 0 then
      v_coderror := null;
      hral56b_batch.gen_entitlement(tleaverq_codempid, tleaverq_numlereq, p_dayeupd, tleaverq_flgleave,
                                    tleaverq_codleave, tleaverq_dteleave, tleaverq_dtestrt, tleaverq_timstrt,
                                    tleaverq_dteend, tleaverq_timend,
                                    tleaverq_dteprgntst,
                                    0, global_v_coduser,
                                    v_coderror, v_count, v_count, v_count,
                                    v_count, v_count ,v_count ,v_qtytimle2,
                                    v_qtyminrq ,v_qtyavgwk);

      tleaverq_qtyday  := 0;
      tleaverq_qtymin  := 0;
      if v_coderror is not null then
          param_msg_error := get_error_msg_php(v_coderror,global_v_lang);
          return;
      end if;
    end if;
  ------------------------------user46-----------------------------------
  end check_data;
  --
  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES62E';
    v_count      number := 0;
    v_approvno   number := 0;
    v_codempid_next  temploy1.codempid%type;
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(4);
    v_remark     varchar2(200) := substr(get_label_name('HRESZXEC1',global_v_lang,99),1,200);
    v_routeno    varchar2(100);

    v_ok        boolean;

    v_flgfwbwlim  varchar2(1);
    v_qtyminle    number;
    v_qtydlefw    number;
    v_qtydlebw    number;

    v_dtefw       date;
    v_dteaw       date;
    v_typleave	  varchar2(4 char);
    v_table			  varchar2(50 char);
    v_error			  varchar2(50 char);
  begin
    --<< user22 : 02/08/2016 : HRMS590307 ||
    begin
      select typleave
        into v_typleave
        from tleavecd
       where codleave = tleaverq_codleave;
    exception when no_data_found then	null;
    end;
    -->> user22 : 02/08/2016 : HRMS590307 ||
     v_approvno         :=  0 ;
     v_codempap         := b_index_codempid ;
     tleaverq_staappr  := 'P';
     chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),tleaverq_seqno,v_approvno,b_index_codempid,v_typleave); --user22 : 02/08/2016 : HRMS590307 || chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),tleaverq_seqno,v_approvno,b_index_codempid);
    --<< user22 : 20/08/2016 : HRMS590307 ||

    --> [START] [KOHU-SM2301] bow.sarunya || remove code - 07/12/2023
--      if v_routeno is null then
--        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
--        return;
--      end if;
--      --
--      chk_workflow.find_approval(v_codapp,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),tleaverq_seqno,v_approvno,v_table,v_error);
--      if v_error is not null then
--        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
--        return;
--      end if;
--      -->> user22 : 20/08/2016 : HRMS590307 ||
--     --Loop Check Next step
--     loop
--       v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid);
--       -- user22 : 18/07/2016 : HRMS590287 || v_codempid_next := chk_workflow.Chk_NextStep('HRES62E',v_routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
--       if  v_codempid_next is not null then
--         v_approvno           := v_approvno + 1 ;
--         tleaverq_codappr    := v_codempid_next ;
--         tleaverq_staappr    := 'A' ;
--         tleaverq_dteappr    := trunc(sysdate);
--         tleaverq_remarkap   := v_remark;
--         tleaverq_approvno   := v_approvno ;
--          begin
--              select  count(*) into v_count
--               from   taplverq
--               where  codempid = b_index_codempid
--               and    dtereq   = tleaverq_dtereq
--               and    seqno    = tleaverq_seqno
--               and    approvno =  v_approvno;
--          exception when no_data_found then  v_count := 0;
--          end;
--
--          if v_count = 0 then
--            insert into taplverq
--                    (codempid,dtereq,seqno,approvno,codappr,dteappr,
--                     staappr,remark,coduser,
--                     dterec, dteapph)
--            values  (b_index_codempid,tleaverq_dtereq,tleaverq_seqno,v_approvno,
--                     v_codempid_next,trunc(sysdate),
--                     'A',v_remark,global_v_coduser,
--                     sysdate,sysdate);
--          else
--            update taplverq  set codappr   = v_codempid_next,
--                                dteappr   = trunc(sysdate),
--                                staappr   = 'A',
--                                remark    = v_remark ,
--                                coduser   = global_v_coduser,
--                                dterec    = sysdate,
--                                dteapph   = sysdate
--
--            where codempid  = b_index_codempid
--            and    dtereq   = tleaverq_dtereq
--            and    seqno    = tleaverq_seqno
--            and   approvno  = v_approvno;
--          end if;
--
--          chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid,v_typleave);--user22 : 02/08/2016 : HRMS590307 || chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid);
--       else
--          exit ;
--       end if;
--     end loop ;
    --< [END] [KOHU-SM2301] bow.sarunya || remove code - 07/12/2023 

    tleaverq_approvno     := v_approvno ;
    tleaverq_routeno      := v_routeno ;
  end;
  --
  procedure save_tleaverq is
    v_qtyday1       number;
    v_qtyday2       number;
    v_qtyday3       number;
    v_qtyday4       number;
    v_qtyday5       number;
    v_qtyday6       number;
    v_qtytimle2     tleavety.qtytimle%type;
    v_qtyminrq      number;
    v_qtyavgwk      number;
    v_qtyhwork      tattence.qtyhwork%type;
    v_qtydayleav    tleaverq.qtyday%type;
    v_qtyminleav    tleaverq.qtymin%type;
    v_coderror      varchar2(100 char);
  begin
    tleaverq_codempid := b_index_codempid;
    tleaverq_dtereq   := b_index_dtereq;
    tleaverq_timstrt  := tleaverq_v_timstrt;
    tleaverq_timend   := tleaverq_v_timend;
    tleaverq_dteinput := sysdate;
    tleaverq_coduser  := global_v_coduser;
    tleaverq_codinput := global_v_codempid;
    begin
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      begin
        delete from tleaverqattch
         where codempid = tleaverq_codempid
           and dtereq   = tleaverq_dtereq
           and seqno    = to_number(tleaverq_seqno)
           and codleave <> tleaverq_codleave;
      exception when others then
        null;
      end;
      -- find dtyday leave, qtymin leave
      hral56b_batch.gen_entitlement(tleaverq_codempid, tleaverq_numlereq, p_dayeupd, tleaverq_flgleave,
                                tleaverq_codleave, tleaverq_dteleave, tleaverq_dtestrt, tleaverq_timstrt,
                                tleaverq_dteend, tleaverq_timend,
                                tleaverq_dteprgntst,
                                0, global_v_coduser,
                                v_coderror, v_qtyday1, v_qtyday2, v_qtyday3,
                                v_qtyday4, v_qtyday5 ,v_qtyday6 ,v_qtytimle2,
                                v_qtyminrq ,v_qtyavgwk);
      begin
        select qtyhwork into v_qtyhwork
        from   tattence
        where  codempid = tleaverq_codempid
        and    dtework  = tleaverq_dteleave
        and    codshift = tleaverq_codshift;
      exception when no_data_found then
        v_qtyhwork  := 0;
      end;
      v_qtydayleav    :=  v_qtyday5 + v_qtyday6;
      v_qtyminleav    :=  (v_qtydayleav * (v_qtyhwork/60)) * 60;
      --
      insert into tleaverq
      (codempid,    seqno,        dtereq,       codleave,     deslereq,
       codshift,    dteleave,     flgleave,     dtestrt,      dteend,
       codinput,    filenam1,     codcomp,      timstrt,      timend,
       numlereq,    codappr,      staappr,      dteupd,       coduser,
       approvno,    remarkap,     dteappr,      routeno,      dteinput,
       dtecancel,   qtyday,       qtymin,
       -- paternity leave --
       dteprgntst , timprgnt
       )
      values
      (tleaverq_codempid,     tleaverq_seqno,        tleaverq_dtereq,       tleaverq_codleave,    tleaverq_deslereq,
       tleaverq_codshift,     tleaverq_dteleave,     tleaverq_flgleave,     tleaverq_dtestrt,     tleaverq_dteend,
       tleaverq_codinput,     tleaverq_filenam1,     tleaverq_codcomp,      tleaverq_timstrt,     tleaverq_timend,
       tleaverq_numlereq,     tleaverq_codappr,      tleaverq_staappr,      tleaverq_dteupd,      tleaverq_coduser,
       tleaverq_approvno,     tleaverq_remarkap,     tleaverq_dteappr,      tleaverq_routeno,     tleaverq_dteinput,
       tleaverq_dtecancel,    v_qtydayleav,          v_qtyminleav,
       -- paternity leave --
       tleaverq_dteprgntst ,  tleaverq_timprgnt
       );
    exception when dup_val_on_index then
      tleaverq_timstrt  := tleaverq_v_timstrt;
      tleaverq_timend   := tleaverq_v_timend;
      tleaverq_coduser  := global_v_coduser;
      tleaverq_codinput := global_v_codempid;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      begin
        update tleaverq
        set   codleave  = tleaverq_codleave,
              deslereq  = tleaverq_deslereq,
              codshift  = tleaverq_codshift,
              dteleave  = tleaverq_dteleave,
              flgleave  = tleaverq_flgleave,
              dtestrt   = tleaverq_dtestrt,
              dteend    = tleaverq_dteend,
              codinput  = tleaverq_codinput,
              filenam1  = tleaverq_filenam1,
              codcomp   = tleaverq_codcomp,
              timstrt   = tleaverq_timstrt,
              timend    = tleaverq_timend,
              numlereq  = tleaverq_numlereq,
              codappr   = tleaverq_codappr,
              staappr   = tleaverq_staappr,
              dteupd    = tleaverq_dteupd,
              coduser   = tleaverq_coduser,
              approvno  = tleaverq_approvno,
              remarkap  = tleaverq_remarkap,
              dteappr   = tleaverq_dteappr,
              routeno   = tleaverq_routeno,
              dteinput  = tleaverq_dteinput,
              dtecancel = tleaverq_dtecancel,
              qtyday    = v_qtydayleav,
              qtymin    = v_qtyminleav,
              -- paternity leave --
              dteprgntst = tleaverq_dteprgntst,
              timprgnt   = tleaverq_timprgnt
        where codempid  = tleaverq_codempid
          and seqno     = tleaverq_seqno
          and dtereq    = tleaverq_dtereq;
        exception when others then
          rollback;
        end;
    end;

    for i in 0..tleaverq_param_json.get_size-1 loop
      json_obj2        := hcm_util.get_json_t(tleaverq_param_json,to_char(i));
      att_attachname   := hcm_util.get_string_t(json_obj2, 'attachname');
      att_codleave     := hcm_util.get_string_t(json_obj2, 'codleave');
      att_flg          := hcm_util.get_string_t(json_obj2, 'flg');
      att_numseq       := to_number(hcm_util.get_string_t(json_obj2,'numseq'));
      att_flgattach    := hcm_util.get_string_t(json_obj2,'flgattach');
      att_filedesc    := hcm_util.get_string_t(json_obj2,'filename');
      if att_flg = 'edit' then
        begin

          insert into tleaverqattch (codempid, dtereq, seqno, numseq, filename,flgattach,filedesc,codleave,dtecreate,codcreate,coduser)
          values (b_index_codempid, b_index_dtereq, b_index_seqno, att_numseq, att_attachname,att_flgattach,att_filedesc,tleaverq_codleave,sysdate,global_v_codempid,global_v_coduser);
        exception when dup_val_on_index then
          begin
            update tleaverqattch
            set   filename  = att_attachname
            where codempid  = b_index_codempid
              and dtereq    = b_index_dtereq
              and seqno     = b_index_seqno
              and numseq    = att_numseq;
            exception when others then
              rollback;
            end;
        end;
      elsif  att_flg = 'delete' then
         begin
            delete tleaverqattch
            where codempid  = b_index_codempid
              and dtereq    = b_index_dtereq
              and seqno     = b_index_seqno
              and numseq    = att_numseq;
            exception when others then
              rollback;
          end;
      end if;
    end loop;

  end;
  --
  function var_dump_json_obj(json_obj json_object_t) return json_object_t is
    json_obj2             json_object_t;
    tleaverq_obj          json_object_t;
    details_obj           json_object_t;
    detail2_obj           json_object_t;
    detail2_qtyday_obj    json_object_t;
    detail2_day_obj       json_object_t;
    detail2_hur_obj       json_object_t;
    detail2_min_obj       json_object_t;
  begin
    json_obj2           := json_obj;
    tleaverq_obj        :=  json_object_t();
    details_obj         :=  json_object_t();
    detail2_obj         :=  json_object_t();
    detail2_qtyday_obj  :=  json_object_t();
    detail2_day_obj     :=  json_object_t();
    detail2_hur_obj     :=  json_object_t();
    detail2_min_obj     :=  json_object_t();
    --obj tleaverq
    tleaverq_obj.put('codempid',tleaverq_codempid);
    tleaverq_obj.put('seqno',tleaverq_seqno);
    tleaverq_obj.put('dtereq',tleaverq_dtereq);
    tleaverq_obj.put('staappr',tleaverq_staappr);
    tleaverq_obj.put('codleave',tleaverq_codleave);
    tleaverq_obj.put('desc_codleave',tleaverq_desc_codleave);
    tleaverq_obj.put('flgleave',tleaverq_flgleave);
    tleaverq_obj.put('dteleave',tleaverq_dteleave);
    tleaverq_obj.put('dtestrt',tleaverq_dtestrt);
    tleaverq_obj.put('dteend',tleaverq_dteend);
    tleaverq_obj.put('timstrt',tleaverq_timstrt);
    tleaverq_obj.put('timend',tleaverq_timend);
    tleaverq_obj.put('deslereq',tleaverq_deslereq);
    tleaverq_obj.put('dteinput',tleaverq_dteinput);
    tleaverq_obj.put('routeno',tleaverq_routeno);
    tleaverq_obj.put('codshift',tleaverq_codshift);
    tleaverq_obj.put('codcomp',tleaverq_codcomp);
    tleaverq_obj.put('filenam1',tleaverq_filenam1);
    tleaverq_obj.put('numlereq',tleaverq_numlereq);
    tleaverq_obj.put('desleave',tleaverq_desleave);
    tleaverq_obj.put('codappr',tleaverq_codappr);
    tleaverq_obj.put('dteappr',tleaverq_dteappr);
    tleaverq_obj.put('remarkap',tleaverq_remarkap);
    tleaverq_obj.put('approvno',tleaverq_approvno);
    --
    tleaverq_obj.put('dteprgntst',tleaverq_dteprgntst);
    tleaverq_obj.put('timprgnt',tleaverq_timprgnt);
    --

    --obj details
    details_obj.put('staleave',details_staleave);
    --obj detail2
    detail2_qtyday_obj.put('1',detail2_qtyday1);
    detail2_qtyday_obj.put('2',detail2_qtyday2);
    detail2_qtyday_obj.put('3',detail2_qtyday3);
    detail2_qtyday_obj.put('4',detail2_qtyday4);
    detail2_qtyday_obj.put('5',detail2_qtyday5);
    detail2_qtyday_obj.put('6',detail2_qtyday6);
    detail2_day_obj.put('1',detail2_day1);
    detail2_day_obj.put('2',detail2_day2);
    detail2_day_obj.put('3',detail2_day3);
    detail2_day_obj.put('4',detail2_day4);
    detail2_day_obj.put('5',detail2_day5);
    detail2_day_obj.put('6',detail2_day6);
    detail2_hur_obj.put('1',detail2_hur1);
    detail2_hur_obj.put('2',detail2_hur2);
    detail2_hur_obj.put('3',detail2_hur3);
    detail2_hur_obj.put('4',detail2_hur4);
    detail2_hur_obj.put('5',detail2_hur5);
    detail2_hur_obj.put('6',detail2_hur6);
    detail2_min_obj.put('1',detail2_min1);
    detail2_min_obj.put('2',detail2_min2);
    detail2_min_obj.put('3',detail2_min3);
    detail2_min_obj.put('4',detail2_min4);
    detail2_min_obj.put('5',detail2_min5);
    detail2_min_obj.put('6',detail2_min6);

    detail2_obj.put('qtyday',detail2_qtyday_obj);
    detail2_obj.put('day',detail2_day_obj);
    detail2_obj.put('hur',detail2_hur_obj);
    detail2_obj.put('min',detail2_min_obj);
    detail2_obj.put('flgdlemx',detail2_flgdlemx);
    detail2_obj.put('staleave',detail2_staleave);
    detail2_obj.put('typleave',detail2_typleave);
    detail2_obj.put('destype',detail2_destype);
    detail2_obj.put('qtytime',detail2_qtytime);

    json_obj2.put('tleaverq',tleaverq_obj);
    json_obj2.put('details',details_obj);
    json_obj2.put('detail2',detail2_obj);
    return json_obj2;
  end var_dump_json_obj;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    v_cursor        number;
    v_dummy         integer;
    v_stmt          varchar2(5000 char);
    v_remarkapcc    varchar2(4000 char);
    v_staapprcc     varchar2(4000 char);
    v_staapprccname varchar2(4000 char);

    v_rcnt          number := 0;
    v_num           number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_timstrt       varchar2(10 char);
    v_timend        varchar2(10 char);

    cursor c1 is
      select a.codempid, a.dtereq, a.seqno, a.codleave, a.dtestrt, a.timstrt, a.dteend, a.timend, a.deslereq, a.numlereq, a.staappr, a.dteappr,
             a.codappr, a.codcomp, a.remarkap, a.approvno, a.routeno, a.flgsend, a.dteupd, a.coduser,
             a.filenam1, a.codinput, a.dtecancel, a.dteinput, a.dtesnd, a.dteapph, a.flgagency, a.flgleave, a.codshift, a.dteleave
        from tleaverq a, temploy1 b
       where a.codempid = b.codempid(+)
         and a.codempid like nvl(b_index_codempid,a.codempid)
         and a.seqno like nvl(b_index_seqno,a.seqno)
         and a.codcomp like b_index_codcomp||'%'
--       and a.dtereq between nvl(b_index_dtereq_st,a.dtereq) and nvl(b_index_dtereq_en,a.dtereq)
         and (
                a.dtestrt  between nvl(b_index_dtereq_st,a.dtestrt) and nvl(b_index_dtereq_en,a.dtestrt)
                    or
                a.dteend  between nvl(b_index_dtereq_st,a.dteend) and nvl(b_index_dtereq_en,a.dteend)
                    or
                b_index_dtereq_st between     a.dtestrt  and a.dteend
                    or
                b_index_dtereq_en between     a.dtestrt  and a.dteend
              )
         and (a.codempid = global_v_codempid or
               (a.codempid <> global_v_codempid
                and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                and 0 <> (select count(ts.codcomp)
                            from tusrcom ts
                           where ts.coduser = global_v_coduser
                             and a.codcomp like ts.codcomp||'%'
                             and rownum    <= 1 )))
    order by a.codempid, a.dtereq desc, a.seqno desc;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_data := json_object_t();
    check_index;
    if param_msg_error is null then
      begin
        select count(*)
          into v_rcnt
          from tleaverq
        where codempid like nvl(b_index_codempid,codempid)
          and seqno like nvl(b_index_seqno,seqno)
          and codcomp like b_index_codcomp||'%'
--          and dtereq between nvl(b_index_dtereq_st,dtereq) and nvl(b_index_dtereq_en,dtereq)
          and (
                dtestrt  between nvl(b_index_dtereq_st,dtestrt) and nvl(b_index_dtereq_en,dtestrt)
                    or
                dteend  between nvl(b_index_dtereq_st,dteend) and nvl(b_index_dtereq_en,dteend)
                    or
                b_index_dtereq_st between     dtestrt  and dteend
                    or
                b_index_dtereq_en between     dtestrt  and dteend
              )
          ;
      end;

      if v_rcnt > 0 then
        for i in c1 loop
          v_num := v_num + 1;

          v_timstrt := '';
          v_timend  := '';

          if i.timstrt is not null then
            v_timstrt := substr(i.timstrt, 1, 2)||':'||substr(i.timstrt, 3, 2);
          end if;
          if i.timend is not null then
            v_timend := substr(i.timend, 1, 2)||':'||substr(i.timend, 3, 2);
          end if;
          --
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', '');
          obj_data.put('flg', '');
          obj_data.put('total',v_rcnt);
          obj_data.put('rcnt',v_rcn);
          obj_data.put('codempid_query',i.codempid);
          obj_data.put('desc_codempid_query',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
          obj_data.put('seqno',i.seqno);
          obj_data.put('codleave',i.codleave);
          obj_data.put('desc_codleave',get_tleavecd_name(i.codleave,global_v_lang));
          obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
          obj_data.put('timstrt',v_timstrt);
          obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
          obj_data.put('timend',v_timend);
          obj_data.put('deslereq',i.deslereq);
          obj_data.put('numlereq',i.numlereq);
          obj_data.put('staappr',i.staappr);
          obj_data.put('status',get_tlistval_name('ESSTAREQ',trim(i.staappr),global_v_lang));
          obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
          obj_data.put('codappr',i.codappr);
          obj_data.put('desc_codappr',i.codappr || ' ' ||get_temploy_name(i.codappr,global_v_lang));
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          obj_data.put('remarkap',i.remarkap);
          obj_data.put('approvno',i.approvno);
          obj_data.put('routeno',i.routeno);

          obj_data.put('desc_codempap',chk_workflow.get_next_approve('HRES62E',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.seqno,nvl(trim(i.approvno),'0'),global_v_lang));

          obj_data.put('flgsend',i.flgsend);
          obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
          obj_data.put('coduser',i.coduser);
          obj_data.put('filenam1',i.filenam1||'$##$'||get_tsetup_value('PATHDOC'));
          obj_data.put('codinput',i.codinput);
          obj_data.put('desc_codinput',get_temploy_name(i.codinput,global_v_lang));
          obj_data.put('dtecancel',to_char(i.dtecancel,'dd/mm/yyyy'));
          obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
          obj_data.put('dtesnd',to_char(i.dtesnd,'dd/mm/yyyy'));
          obj_data.put('dteapph',to_char(i.dteapph,'dd/mm/yyyy'));
          obj_data.put('flgagency',i.flgagency);
          obj_data.put('flgleave',i.flgleave);
          obj_data.put('codshift',i.codshift);
          obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift,global_v_lang));
          obj_data.put('dteleave',to_char(i.dteleave,'dd/mm/yyyy'));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));

          obj_row.put(to_char(v_num-1),obj_data);
        end loop; -- end for
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_timework(json_str_input in clob, json_str_output out clob) as
    json_obj          json_object_t;
    p_lang            varchar2(100 char);
    p_codempid        varchar2(100 char);
    p_dtework         varchar2(100 char);

    v_codshift        varchar2(1000);
    v_leave_timstrtw  varchar2(1000);
    v_leave_timendw   varchar2(1000);
    v_timstrtw        varchar2(1000);
    v_timendw         varchar2(1000);
    v_timstrtb        varchar2(1000);
    v_timendb         varchar2(1000);
    v_dtestrtw        date;
    v_dteendw         date;
    v_dte_temp_st     date;
    v_dte_temp_en1    date;
    v_dte_temp_en2    date;
  begin

    initial_value(json_str_input);
    begin
      select a.codshift,a.timstrtw,a.timendw,b.timstrtw,b.timendw,b.timstrtb,b.timendb,a.dtestrtw,a.dteendw
        into v_codshift,v_leave_timstrtw,v_leave_timendw,v_timstrtw,v_timendw,v_timstrtb,v_timendb,
             v_dtestrtw,v_dteendw
        from tattence a,tshiftcd b
       where a.codshift = b.codshift
         and a.codempid = b_index_codempid
--         and a.dtework = to_date(p_dtework,'dd/mm/yyyy');
         and a.dtework = tleaverq_dteleave;
    v_dte_temp_st := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')|| ' '||v_timstrtw,'dd/mm/yyyy hh24mi');
    v_dte_temp_en1 := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')|| ' '||v_timstrtb,'dd/mm/yyyy hh24mi');
    v_dte_temp_en2 := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')|| ' '||v_timendb,'dd/mm/yyyy hh24mi');
    exception when no_data_found then
      v_codshift        := '';
      v_leave_timstrtw  := '';
      v_leave_timendw   := '';
      v_timstrtw        := '';
      v_timendw         := '';
      v_timstrtb        := '';
      v_timendb         := '';
      v_dtestrtw         := '';
      v_dteendw         := '';
    end;

    if v_dte_temp_en1 < v_dte_temp_st then
      v_dte_temp_en1 := v_dte_temp_en1+1;
    end if;

    if v_dte_temp_en2 < v_dte_temp_st then
      v_dte_temp_en2 := v_dte_temp_en2+1;
    end if;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('codshift', nvl(v_codshift,''));
--    obj_row.put('dtestrt', nvl(v_dtestrtw,''));
--    obj_row.put('dteend', nvl(v_dteendw,''));
    obj_row.put('m_timstrt', nvl(v_timstrtw,''));
    obj_row.put('m_timend', nvl(v_timstrtb,''));
    obj_row.put('e_timstrt', nvl(v_timendb,''));
    obj_row.put('e_timend', nvl(v_timendw,''));
    obj_row.put('m_dtestrt', nvl(to_char(v_dtestrtw,'dd/mm/yyyy'),''));
    obj_row.put('m_dteend', nvl(to_char(v_dte_temp_en1,'dd/mm/yyyy'),''));
    obj_row.put('e_dtestrt', nvl(to_char(v_dte_temp_en2,'dd/mm/yyyy'),''));
    obj_row.put('e_dteend', nvl(to_char(v_dteendw,'dd/mm/yyyy'),''));
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
--
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    obj_row         json_object_t;
    v_codleave      tleavecd.codleave%type;
    v_descond       tleavecd.syncond%type;
    v_typleave      tleavecd.typleave%type;
    v_staleave      tleavecd.staleave%type;
    v_flgchol       tleavety.flgchol%type;
    v_statement     tleavecd.statement%type;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    begin
      select a.codleave, a.syncond, a.typleave, a.staleave, b.flgchol, a.statement
        into v_codleave, v_descond, v_typleave, v_staleave, v_flgchol, v_statement
        from tleavecd a, tleavety b
       where a.typleave = b.typleave
         and a.codleave = tleaverq_codleave;
    exception when no_data_found then
       v_codleave := null;
       v_descond  := null;
       v_typleave := null;
       v_flgchol  := null;
       v_statement  := null;
    end;

    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('codleave', v_codleave);
    obj_row.put('desc_codleave',get_tleavecd_name(v_codleave,global_v_lang));
    obj_row.put('descond', v_descond);
    obj_row.put('typleave', v_typleave);
    obj_row.put('staleave', v_staleave);
    obj_row.put('condition', get_logical_desc(v_statement));
    obj_row.put('flgchol', v_flgchol);
    obj_row.put('desc_flgchol', get_tlistval_name('LVCDAY', v_flgchol, global_v_lang));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_create(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    obj_row         json_object_t;
    v_codleave      varchar2(4000);
    v_descond       varchar2(4000);
    v_typleave      varchar2(4000);
    v_staleave      varchar2(4000);
    v_flgchol       varchar2(4000);
    v_seqno         varchar2(10);
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    v_seqno := gen_numseq;

    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('codempid', global_v_codempid);
    obj_row.put('codempid_query', b_index_codempid);
    obj_row.put('desc_codempid', '');
    obj_row.put('desc_codempid_query', '');
    obj_row.put('staappr', '');
    obj_row.put('seqno', v_seqno);
    obj_row.put('codleave', '');
    obj_row.put('flgleave', 'A');
    obj_row.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
    obj_row.put('dteleave', to_char(sysdate,'dd/mm/yyyy'));
    obj_row.put('dtestrt', to_char(sysdate,'dd/mm/yyyy'));
    obj_row.put('dteend', to_char(sysdate,'dd/mm/yyyy'));
    obj_row.put('timstrt', '');
    obj_row.put('timend', '');
    obj_row.put('deslereq', '');
    obj_row.put('dteinput', to_char(sysdate,'dd/mm/yyyy'));
    obj_row.put('routeno', '');
    obj_row.put('filenam1', '');
    obj_row.put('flgwarning', 'N');
    obj_row.put('flgleaveprgnt', 'N');
    obj_row.put('flgstat', 'add');

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_leave(json_str in clob, json_str_output out varchar2) is
  begin
    initial_value(json_str);
    check_data;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null then
        save_tleaverq;
        commit;
      end if;
    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_warn);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;
--
  procedure cancel_tleaverq(json_str in clob, json_str_output out varchar2) is
    json_obj    json_object_t;
  begin
    initial_value(json_str);
    if tleaverq_dtereq is not null then
      if tleaverq_staappr is null then
        begin
          select staappr
            into tleaverq_staappr
          from tleaverq
          where codempid = b_index_codempid
             and dtereq   = tleaverq_dtereq
             and seqno    = tleaverq_seqno;
        exception when no_data_found then null;
        end;
      end if;
      if tleaverq_staappr = 'P' then
        begin
          update tleaverq set staappr   = 'C',
                              dtecancel = trunc(sysdate),
                              coduser   = global_v_coduser
                 where codempid = b_index_codempid
                   and dtereq   = tleaverq_dtereq
                   and seqno    = tleaverq_seqno;
          commit;
          param_msg_error := get_error_msg_php('HR2421',global_v_lang);
          commit;
        exception when others then
          param_msg_error := sqlerrm;
          rollback;
        end;
      elsif tleaverq_staappr = 'C' then
        param_msg_error := get_error_msg_php('HR1506',global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR1490',global_v_lang);
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure get_entitlement(json_str in clob, json_str_output out clob) as
    json_obj        json_object_t;
    p_codempid      varchar2(100 char);
    v_tleaverq      tleaverq%rowtype;
    v_codempid      temploy1.codempid%type;
    v_qtyavgwk      number := 0;
    v_qtyday1       number := 0;
    v_qtyday2       number := 0;
    v_qtyday3       number := 0;
    v_qtyday4       number := 0;
    v_qtyday5       number := 0;
    v_qtyday6       number := 0;
    v_typleave      tleavecd.typleave%type;
    v_staleave      tleavecd.staleave%type;
    v_dteleve       date;

    v_day1          number;
    v_hur1          number;
    v_min1          number;
    v_day2          number;
    v_hur2          number;
    v_min2          number;
    v_day3          number;
    v_hur3          number;
    v_min3          number;
    v_day4          number;
    v_hur4          number;
    v_min4          number;
    v_day5          number;
    v_hur5          number;
    v_min5          number;
    v_day6          number;
    v_hur6          number;
    v_min6          number;

    v_codcomp       temploy1.codcomp%type;
    v_qtyday        tlereqd.qtyday%type;
    v_error_msg     varchar2(2000 char);
    v_summin        number := 0;
    v_dtestrtw      date;
    v_dteendw       date;
    v_flgtype       varchar2(1000 char);
    v_dteprgntst    temploy1.dteprgntst%type;

    v_coderror    varchar2(100 char);
    v_qtytimle2   tleavety.qtytimle%type;
    v_qtyminrq	number;

  begin
    initial_value(json_str);

    v_tleaverq.codempid     := b_index_codempid;
    v_tleaverq.dtereq       := tleaverq_dtereq;
    v_tleaverq.seqno        := b_index_seqno;
    v_tleaverq.codleave     := tleaverq_codleave;
    v_tleaverq.dtestrt      := tleaverq_dtestrt;
    v_tleaverq.dteend       := tleaverq_dteend;
    v_tleaverq.timstrt      := tleaverq_v_timstrt;
    v_tleaverq.timend       := tleaverq_v_timend;
    v_dteleve               := tleaverq_dteleave;
    p_codempid              := b_index_codempid;

    begin
      select dtestrtw,dteendw
      into v_dtestrtw,v_dteendw
      from tattence
      where dtework = v_dteleve
        and codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('ES0044',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;
    v_tleaverq.dtestrt  := v_dtestrtw;
    v_tleaverq.dteend   := v_dteendw;
    begin
        select codempid into v_codempid
        from   tattence
        where  codempid = b_index_codempid
        and    dtework  between v_dtestrtw and v_dteendw
        and rownum <= 1;
    exception when no_data_found then

      param_msg_error := get_error_msg_php('ES0044',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

    <<main_loop>>
    loop
      if p_codempid is null or v_tleaverq.codleave is null or v_tleaverq.dtestrt is null  or v_tleaverq.dteend is null then
        exit main_loop;
      end if;

      begin
          select codempid,codcomp
            into v_codempid,v_codcomp
            from temploy1
           where codempid = v_tleaverq.codempid;
      exception when no_data_found then
          exit main_loop;
      end;

      begin
          select qtyavgwk into v_qtyavgwk
            from tcontral
           where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
             and dteeffec = (select max(dteeffec)
                               from tcontral
                              where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
                                and dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
             and    rownum <= 1
          order by codcompy,dteeffec;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tcontral');
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
           exit main_loop;
      end;
      begin
          select typleave,staleave into v_typleave,v_staleave
            from tleavecd
           where codleave = v_tleaverq.codleave;
      exception when no_data_found then
        exit main_loop;
      end;
      begin
        select flgtype
          into v_flgtype
          from tleavety
         where typleave  = v_typleave;
      exception when no_data_found then
        v_flgtype := null;
      end;

      hral56b_batch.gen_entitlement(p_codempid, tleaverq_numlereq, p_dayeupd, tleaverq_flgleave,
                                    v_tleaverq.codleave, tleaverq_dteleave, tleaverq_dtestrt, tleaverq_timstrt,
                                    tleaverq_dteend, tleaverq_timend,
                                    tleaverq_dteprgntst,
                                    0, global_v_coduser,
                                    v_coderror ,v_qtyday1      ,v_qtyday2,         -- output
                                    v_qtyday3   ,v_qtyday4      ,v_qtyday5,
                                    v_qtyday6  ,v_qtytimle2,
                                    v_qtyminrq ,v_qtyavgwk);
      if v_coderror is not null then
          v_error_msg := get_error_msg_php(v_coderror,global_v_lang);
      end if;

      v_qtyday1 := nvl(v_qtyday1,0) ;
      param_qtyavgwk := v_qtyavgwk;

      cal_dhm(v_qtyavgwk,v_qtyday1,v_day1,v_hur1,v_min1);
      cal_dhm(v_qtyavgwk,v_qtyday2,v_day2,v_hur2,v_min2);
      cal_dhm(v_qtyavgwk,v_qtyday4,v_day3,v_hur3,v_min3);
      cal_dhm(v_qtyavgwk,v_qtyday3,v_day4,v_hur4,v_min4);
      cal_dhm(v_qtyavgwk,v_qtyday5,v_day5,v_hur5,v_min5);
      cal_dhm(v_qtyavgwk,v_qtyday6,v_day6,v_hur6,v_min6);
      --
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('desc_coderror', ' ');
      obj_row.put('httpcode', '');
      obj_row.put('flg', '');
      obj_row.put('error_msg', nvl(v_error_msg,' '));
      obj_row.put('day1', nvl(to_char(v_day1),' '));
      obj_row.put('hur1', nvl(to_char(v_hur1),' '));
      obj_row.put('min1', nvl(to_char(v_min1),' '));
      obj_row.put('day2', nvl(to_char(v_day2),' '));
      obj_row.put('hur2', nvl(to_char(v_hur2),' '));
      obj_row.put('min2', nvl(to_char(v_min2),' '));
      obj_row.put('day3', nvl(to_char(v_day3),' '));
      obj_row.put('hur3', nvl(to_char(v_hur3),' '));
      obj_row.put('min3', nvl(to_char(v_min3),' '));
      obj_row.put('day4', nvl(to_char(v_day4),' '));
      obj_row.put('hur4', nvl(to_char(v_hur4),' '));
      obj_row.put('min4', nvl(to_char(v_min4),' '));
      obj_row.put('day5', nvl(to_char(v_day5),' '));
      obj_row.put('hur5', nvl(to_char(v_hur5),' '));
      obj_row.put('min5', nvl(to_char(v_min5),' '));
      obj_row.put('day6', nvl(to_char(v_day6),' '));
      obj_row.put('hur6', nvl(to_char(v_hur6),' '));
      obj_row.put('min6', nvl(to_char(v_min6),' '));
      obj_row.put('qtyday1', nvl(to_char(v_qtyday1),' '));
      obj_row.put('qtyday2', nvl(to_char(v_qtyday2),' '));
      obj_row.put('qtyday3', nvl(to_char(v_qtyday3),' '));
      obj_row.put('qtyday4', nvl(to_char(v_qtyday4),' '));
      obj_row.put('qtyday5', nvl(to_char(v_qtyday5),' '));
      obj_row.put('qtyday6', nvl(to_char(v_qtyday6),' '));
      obj_row.put('summin', nvl(to_char(v_summin),' '));

      -- paternity leave --
      begin
        select dteprgntst into v_dteprgntst
          from temploy1
         where codempid = p_codempid
           and v_dteleve between add_months(dteprgntst, -9) and dteprgntst;
      exception when others then
        v_dteprgntst := null;
      end;

      if v_flgtype = 'M' then
        obj_row.put('flgleaveprgnt','Y');
        obj_row.put('dteprgntst',to_char(v_dteprgntst,'dd/mm/yyyy'));
      else
        obj_row.put('flgleaveprgnt','N');
        obj_row.put('dteprgntst' ,'');
      end if;
      obj_row.put('timprgnt' ,'');

      json_str_output := obj_row.to_clob;
      exit main_loop;
    end loop; -- main_loop

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure enable_flgleave(json_str_input in clob, json_str_output out clob) is
    json_obj          json_object_t;
    resp_json_obj     json_object_t;
    v_flg             varchar2(10 char);
    v_codleave        varchar2(10 char);
  begin
    initial_value(json_str_input);
    begin
        select flgleave into v_flg
        from tleavecd
        where codleave = tleaverq_codleave;
    exception when others then
      null;
    end;
    resp_json_obj         := json_object_t();

    resp_json_obj.put('coderror','200');
    resp_json_obj.put('desc_coderror', ' ');
    resp_json_obj.put('httpcode', '');
    resp_json_obj.put('flgleave','A');

    if v_flg = 'A' then
      resp_json_obj.put('enableflagleaveR1','T');
      resp_json_obj.put('enableflagleaveR2','F');
      resp_json_obj.put('enableflagleaveR3','F');
      resp_json_obj.put('enableflagleaveR4','F');
    elsif v_flg = 'F' then
      resp_json_obj.put('enableflagleaveR1','T');
      resp_json_obj.put('enableflagleaveR2','T');
      resp_json_obj.put('enableflagleaveR3','T');
      resp_json_obj.put('enableflagleaveR4','F');
    elsif v_flg = 'H' then
      resp_json_obj.put('enableflagleaveR1','T');
      resp_json_obj.put('enableflagleaveR2','T');
      resp_json_obj.put('enableflagleaveR3','T');
      resp_json_obj.put('enableflagleaveR4','T');
    else
      resp_json_obj.put('enableflagleaveR1','T');
      resp_json_obj.put('enableflagleaveR2','T');
      resp_json_obj.put('enableflagleaveR3','T');
      resp_json_obj.put('enableflagleaveR4','T');
    end if;
    json_str_output := resp_json_obj.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_codleave(json_str_input in clob, json_str_output out clob) is
    json_obj      json_object_t;
    obj_row       json_object_t;
    obj_data_new  json_object_t;
    v_dteleave    date;
    v_cursor			number;
		v_dummy       integer;
		v_stmt			  varchar2(5000 char);
    v_where       varchar2(4000 char);
    v_flgsecur    varchar2(4000 char);
    v_codcomp     temploy1.codcomp%type;
    v_typpayroll  temploy1.typpayroll%type;
    v_dteempmt    temploy1.dteempmt%type;
    v_dteeffex    temploy1.dteeffex%type;
    v_staemp      temploy1.staemp%type;
    v_numlvl      temploy1.numlvl%type;
    v_codpos      temploy1.codpos%type;
    v_codsex      temploy1.codsex%type;
    v_codempmt    temploy1.codempmt%type;
    v_typemp      temploy1.typemp%type;
    v_qtywkday    temploy1.qtywkday%type;
    v_codrelgn    temploy2.codrelgn%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_codcalen    temploy1.codcalen%type;
    v_codjob      temploy1.codjob%type;
    v_codbrlc      temploy1.codbrlc%type;
    v_codgrpgl    temploy1.codgrpgl%type;

    v_flgcal      tratevac2.flgcal%type;
    v_yrecycle    number;
    v_dtecycst    date;
    v_dtecycen    date;
    v_dteefflv    date;
    v_qtyday      number;
    v_qtyday1     number;
    v_svmth       number;
    v_svyre       number;
    v_svday       number;
    v_svmth_acc   number;
    v_flgfound    boolean;
    v_codleave    varchar2(4000 char);
    v_namleavcde  varchar2(4000 char);
    v_namleavcdt  varchar2(4000 char);
    v_namleavcd3  varchar2(4000 char);
    v_namleavcd4  varchar2(4000 char);
    v_namleavcd5  varchar2(4000 char);
    v_staleave    varchar2(4000 char);
    v_descond     varchar2(4000 char);
    v_desc        varchar2(4000 char);
    v_rcnt        number := 0;
    v_count_tmp   number := 0;
    v_flg_data    boolean := false;
  begin
      initial_value(json_str_input);
      json_obj       := json_object_t(json_str_input);
      v_dteleave     := to_date(hcm_util.get_string_t(json_obj,'p_dteleave'),'dd/mm/yyyy');
      v_where        := hcm_util.get_string_t(json_obj,'p_where');
      v_flgsecur     := hcm_util.get_string_t(json_obj,'p_flgsecur');
      obj_row        := json_object_t();
      obj_data       := json_object_t();
      obj_data_new   := json_object_t();

      begin
        select codcomp,typpayroll,dteempmt,dteeffex,staemp,numlvl,codpos,codsex,codempmt,typemp,nvl(qtywkday,0),codrelgn,jobgrade,codcalen,codjob,codbrlc,codgrpgl
          into v_codcomp,v_typpayroll,v_dteempmt,v_dteeffex,v_staemp,v_numlvl,v_codpos,v_codsex,v_codempmt,v_typemp,v_qtywkday,v_codrelgn,v_jobgrade,v_codcalen,v_codjob,v_codbrlc,v_codgrpgl
          from temploy1 a, temploy2 b
         where a.codempid = b_index_codempid
           and a.codempid = b.codempid;
      exception when no_data_found then
        null;
      end;
      --
      if v_where is not null then
        v_where := ' where '||v_where;
      end if;
      v_stmt := 'select codleave,namleavcde,namleavcdt,namleavcd3,namleavcd4,namleavcd5,staleave,syncond
                   from tleavecd'||v_where||' order by codleave';

      v_cursor  := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
      dbms_sql.define_column(v_cursor,1,v_codleave,1000);
      dbms_sql.define_column(v_cursor,2,v_namleavcde,1000);
      dbms_sql.define_column(v_cursor,3,v_namleavcdt,1000);
      dbms_sql.define_column(v_cursor,4,v_namleavcd3,1000);
      dbms_sql.define_column(v_cursor,5,v_namleavcd4,1000);
      dbms_sql.define_column(v_cursor,6,v_namleavcd5,1000);
      dbms_sql.define_column(v_cursor,7,v_staleave,1000);
      dbms_sql.define_column(v_cursor,8,v_descond,1000);
      v_dummy := dbms_sql.execute(v_cursor);
      while (dbms_sql.fetch_rows(v_cursor) > 0) loop
        dbms_sql.column_value(v_cursor,1,v_codleave);
        dbms_sql.column_value(v_cursor,2,v_namleavcde);
        dbms_sql.column_value(v_cursor,3,v_namleavcdt);
        dbms_sql.column_value(v_cursor,4,v_namleavcd3);
        dbms_sql.column_value(v_cursor,5,v_namleavcd4);
        dbms_sql.column_value(v_cursor,6,v_namleavcd5);
        dbms_sql.column_value(v_cursor,7,v_staleave);
        dbms_sql.column_value(v_cursor,8,v_descond);
        v_rcnt := v_rcnt + 1;
        if nvl(v_flgsecur,'Y') = 'Y' then
          v_count_tmp := 0;
          begin
            select  count(*)
            into    v_count_tmp
            from    tleavcomess a, temploy1 b
            where   a.codcompy = hcm_util.get_codcomp_level(b.codcomp,'1')
            and     a.codleave = v_codleave
            and     b.codempid = b_index_codempid;
          exception when others then
            v_count_tmp := 0;
          end;
          if v_count_tmp > 0 then
            v_flg_data := true;
            std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,'1'),global_v_codempid,tleaverq_codleave,v_dteleave,v_yrecycle,v_dtecycst,v_dtecycen);
            if v_staleave = 'V' then
              begin
                select dteeffec,nvl(qtyday,0),flgcal
                  into v_dteefflv,v_qtyday,v_flgcal
                  from tcontrlv
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
                   and dteeffec = (select max(dteeffec)
                                     from tcontrlv
                                    where codcompy  = hcm_util.get_codcomp_level(v_codcomp,'1')
                                      and dteeffec <= v_dtecycen);
              exception when no_data_found then
                null;
              end;
            end if;

            v_dteempmt  := v_dteempmt + v_qtywkday;
--            get_service_year(v_dteempmt,least(nvl((v_dteeffex - 1),v_dteleave),v_dteleave),'Y',v_svyre,v_svmth,v_svday);
            get_service_year(v_dteempmt,sysdate,'Y',v_svyre,v_svmth,v_svday);
            v_svmth     := v_svmth + (v_svyre * 12);
            v_svmth_acc := v_svmth + nvl((v_svday/30),0);
            if v_staleave = 'V' then
              if v_qtyday > 0 and v_svday > v_qtyday then
                v_svmth := v_svmth + 1;
              end if;
            end if;

            v_flgfound := true;
            if v_descond is not null then
              v_desc := v_descond;
              v_desc := replace(v_desc,'TEMPLOY1.NUMLVL',v_numlvl);
              v_desc := replace(v_desc,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODPOS',''''||v_codpos||'''');
              v_desc := replace(v_desc,'TEMPLOY1.QTYWKDAY',v_svmth);-- user22 : 08/11/2016 : STA3590336 || v_desc := replace(v_desc,'TEMPLOY1.QTYWKDAY',''''||v_svmth||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODSEX',''''||v_codsex||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''');
              v_desc := replace(v_desc,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
              v_desc := replace(v_desc,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
              v_desc := replace(v_desc,'TEMPLOY2.CODRELGN',''''||v_codrelgn||'''');
              v_desc := replace(v_desc,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');-- user22 : 14/03/2016 : STA3590240 ||
              v_desc := replace(v_desc,'TEMPLOY1.CODCALEN',''''||v_codcalen||'''');-- user55 : 22/09/2021
              v_desc := replace(v_desc,'TEMPLOY1.CODJOB',''''||v_codjob||'''');-- user55 : 22/09/2021
              v_desc := replace(v_desc,'TEMPLOY1.TYPPAYROLL',''''||v_typpayroll||'''');-- user55 : 22/09/2021
              v_desc := replace(v_desc,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');-- user55 : 22/09/2021
              v_desc := replace(v_desc,'TEMPLOY1.CODGRPGL',''''||v_codgrpgl||'''');-- user55 : 22/09/2021
              v_stmt := 'select count(*) from dual where '||v_desc;
              v_flgfound := execute_stmt(v_stmt);
            end if;

            if v_flgfound then
              obj_data_new.put('codleave', v_codleave);
              if global_v_lang = '101' then
                  obj_data_new.put('desc_codleave', v_namleavcde);
                elsif global_v_lang = '102' then
                  obj_data_new.put('desc_codleave', v_namleavcdt);
                elsif global_v_lang = '103' then
                  obj_data_new.put('desc_codleave', v_namleavcd3);
                elsif global_v_lang = '104' then
                  obj_data_new.put('desc_codleave', v_namleavcd4);
                elsif global_v_lang = '105' then
                  obj_data_new.put('desc_codleave', v_namleavcd5);
                end if;
                obj_row.put(to_char(v_rcnt-1), obj_data_new);
            end if;
          end if; -- if v_count_tmp > 0 then
        else
          v_flg_data := true;
          obj_data_new.put('codleave', v_codleave);
          if global_v_lang = '101' then
              obj_data_new.put('desc_codleave', v_namleavcde);
            elsif global_v_lang = '102' then
              obj_data_new.put('desc_codleave', v_namleavcdt);
            elsif global_v_lang = '103' then
              obj_data_new.put('desc_codleave', v_namleavcd3);
            elsif global_v_lang = '104' then
              obj_data_new.put('desc_codleave', v_namleavcd4);
            elsif global_v_lang = '105' then
              obj_data_new.put('desc_codleave', v_namleavcd5);
            end if;
            obj_row.put(to_char(v_rcnt-1), obj_data_new);
        end if;
        obj_data_new.put('coderror', '200');
      end loop; -- end while
      if v_flg_data then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tleavcom');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_datail(json_str_input in clob, json_str_output out clob) as
    json_obj                json_object_t;
    v_cursor                number;
    v_dummy                 integer;
    v_stmt                  varchar2(5000 char);
    v_remarkapcc            varchar2(4000 char);
    v_staapprcc             varchar2(4000 char);
    v_staapprccname         varchar2(4000 char);

    v_rcnt                  number := 0;
    v_num                   number := 0;
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_typleave              varchar2(4000 char);
    v_flgtype               varchar2(1000 char);

    v_codpos                temploy1.codpos%type;
    v_codcomp               temploy1.codcomp%type;
    v_count_flow_appr       number := 0;
    obj_row_flow_appr       json_object_t := json_object_t();
    obj_table_flow_appr     json_object_t := json_object_t();
    obj_data_flow_appr      json_object_t;

    cursor c1 is
      select a.codempid, a.dtereq, a.seqno, a.codleave, a.dtestrt, a.timstrt, a.dteend, a.timend, a.deslereq, a.numlereq, a.staappr, a.dteappr,
             a.codappr, a.codcomp, a.remarkap, a.approvno, a.routeno, a.flgsend, a.dteupd, a.coduser,
             a.filenam1, a.codinput, a.dtecancel, a.dteinput, a.dtesnd, a.dteapph, a.flgagency, a.flgleave, a.codshift, a.dteleave,
             -- paternity leave --
             a.timprgnt,a.dteprgntst
        from tleaverq a, temploy1 b
       where a.codempid = b.codempid(+)
         and a.codempid like nvl(b_index_codempid,a.codempid)
         and a.seqno like nvl(b_index_seqno,a.seqno)
         and a.codcomp like nvl(b_index_codcomp||'%','%')
         and a.dtereq between nvl(b_index_dtereq_st,a.dtereq) and nvl(b_index_dtereq_en,a.dtereq)
         and (a.codempid = global_v_codempid or
             (a.codempid <> global_v_codempid
               and b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and 0 <> (select count(ts.codcomp)
                           from tusrcom ts
                          where ts.coduser = global_v_coduser
                            and a.codcomp like ts.codcomp||'%'
                            and rownum    <= 1 )))
    order by a.codempid, a.dtereq desc, a.seqno desc;

    cursor c_tempaprq is
        select * 
        from tempaprq
        where codempid = b_index_codempid
            and dtereq = b_index_dtereq_st
            and numseq = b_index_seqno
            and codapp = 'HRES62E'
        order by approvno;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_data := json_object_t();
       check_index;
      if param_msg_error is null then
        begin
          select count(*)
            into v_rcnt
            from tleaverq a,temploy1 b
          where a.codempid = b.codempid(+)
            and a.codempid like nvl(b_index_codempid,a.codempid)
            and a.seqno like nvl(b_index_seqno,a.seqno)
            and a.codcomp like nvl(b_index_codcomp||'%','%')
            and a.dtereq between nvl(b_index_dtereq_st,a.dtereq) and nvl(b_index_dtereq_en,a.dtereq)
           and (a.codempid = global_v_codempid or
               (a.codempid <> global_v_codempid
                and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                and 0 <> (select count(ts.codcomp)
                            from tusrcom ts
                           where ts.coduser = global_v_coduser
                             and a.codcomp like ts.codcomp||'%'
                             and rownum    <= 1 ))) ;
        end;

        if v_rcnt > 0 then
          for i in c1 loop
            v_num := v_num + 1;
            --
            begin
                select typleave into v_typleave
                  from tleavecd
                 where codleave = i.codleave;
            exception when no_data_found then
              v_typleave := null;
            end;

            begin
              select FLGTYPE
                into v_flgtype
                from TLEAVETY
               where TYPLEAVE  = v_typleave;
            exception when no_data_found then
              v_flgtype := null;
            end;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', '');
            obj_data.put('flg', '');
            obj_data.put('total',v_rcnt);
            obj_data.put('rcnt',v_rcn);
            obj_data.put('codempid_query',i.codempid);
            obj_data.put('desc_codempid_query',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('seqno',i.seqno);
            obj_data.put('codleave',i.codleave);
            obj_data.put('desc_codleave',get_tleavecd_name(i.codleave,global_v_lang));
            obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
            obj_data.put('timstrt',i.timstrt);
            obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
            obj_data.put('timend',i.timend);
            obj_data.put('deslereq',i.deslereq);
            obj_data.put('numlereq',i.numlereq);
            obj_data.put('staappr',i.staappr);
            obj_data.put('status',get_tlistval_name('ESSTAREQ',trim(i.staappr),global_v_lang));
            obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',i.codappr);
            obj_data.put('desc_codappr',i.codappr || ' ' ||get_temploy_name(i.codappr,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('remarkap',i.remarkap);
            obj_data.put('approvno',i.approvno);
            obj_data.put('routeno',i.routeno);

            obj_data.put('desc_codempap',chk_workflow.get_next_approve('HRES62E',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.seqno,nvl(trim(i.approvno),'0'),global_v_lang));

            obj_data.put('flgsend',i.flgsend);
            obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
            obj_data.put('coduser',i.coduser);
            obj_data.put('filenam1',i.filenam1||'$##$'||get_tsetup_value('PATHDOC'));
            obj_data.put('codinput',i.codinput);
            obj_data.put('desc_codinput',get_temploy_name(i.codinput,global_v_lang));
            obj_data.put('dtecancel',to_char(i.dtecancel,'dd/mm/yyyy'));
            obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
            obj_data.put('dtesnd',to_char(i.dtesnd,'dd/mm/yyyy'));
            obj_data.put('dteapph',to_char(i.dteapph,'dd/mm/yyyy'));
            obj_data.put('flgagency',i.flgagency);
            obj_data.put('flgleave',i.flgleave);
            obj_data.put('codshift',i.codshift);
            obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift,global_v_lang));
            obj_data.put('dteleave',to_char(i.dteleave,'dd/mm/yyyy'));
            obj_data.put('flgstat', 'edit');

            -- paternity leave --
            if v_flgtype = 'M' then
                obj_data.put('timprgnt',i.timprgnt);
                obj_data.put('dteprgntst',to_char(i.dteprgntst,'dd/mm/yyyy'));
                obj_data.put('flgleaveprgnt','Y');
            else
                obj_data.put('flgleaveprgnt','N');
                obj_data.put('timprgnt','');
                obj_data.put('dteprgntst','');
            end if;

            for tempaprq in c_tempaprq loop
                obj_data_flow_appr := json_object_t();

                begin
                    select codpos, codcomp
                    into v_codpos, v_codcomp
                    from temploy1
                    where codempid = tempaprq.codempap;
                exception when no_data_found then
                    v_codpos := null;
                    v_codcomp := null;
                end;

                obj_data_flow_appr.put('numseq', (v_count_flow_appr + 1));
                obj_data_flow_appr.put('codappr', tempaprq.codempap);
                obj_data_flow_appr.put('desc_codappr', get_temploy_name(tempaprq.codempap, global_v_lang));
                obj_data_flow_appr.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
                obj_data_flow_appr.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));

                obj_row_flow_appr.put(to_char(v_count_flow_appr), obj_data_flow_appr);
                v_count_flow_appr := v_count_flow_appr + 1;
            end loop;

            obj_table_flow_appr.put('rows', obj_row_flow_appr);
            obj_data.put('approver_table', obj_table_flow_appr);

            obj_row.put(to_char(v_num-1), obj_data);
          end loop; -- end for
        end if;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_datail;
  --
  procedure get_leaveatt(json_str_input in clob,json_str_output out clob) as
    obj_data      json_object_t;
    json_obj      json_object_t;
    obj_data2     json_object_t;
    obj_temp      json_object_t;
    obj_row       json_object_t;
    v_rcnt		    number := 0;
    v_chk_data    boolean := false;
    v_dtereq      tleaverqattch.dtereq%type;   --date
    cursor c1 is
      select c.codleave, nvl(b.numseq,c.numseq) numseq  , nvl(b.filedesc,c.filename) filename,b.filename attachname,nvl(b.flgattach,c.flgattach) flgattach
        from tleaverqattch b, tleavecdatt c
      where  c.numseq   = b.numseq(+)
         and b.codempid(+) = b_index_codempid
         and b.dtereq (+)  = tleaverq_dtereq
         and b.seqno (+)    = tleaverq_seqno
         and b.codleave (+)    = c.codleave
        and c.codleave = tleaverq_codleave
        order by numseq;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for r1 in c1 loop
      v_chk_data    := true;
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();

      obj_data.put('rcnt', v_rcnt);
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('codleave',nvl(r1.codleave,''));
      obj_data.put('numseq',nvl(r1.numseq,''));
      obj_data.put('filename',nvl(r1.filename,''));
      obj_data.put('attachname',nvl(r1.attachname,''));
      obj_data.put('flgattach',nvl(r1.flgattach,''));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    obj_data2      := json_object_t();
    obj_temp       := json_object_t();
    obj_data2.put('coderror', '200');
    obj_temp.put('rows',obj_row);
    obj_data2.put('table', obj_temp);

    json_str_output := obj_data2.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_flgtype_leave (json_str_input in clob, json_str_output out clob) is
    v_flgtype       tleavety.flgtype%type;
    p_codleave      tleavecd.codleave%type;
    json_obj        json_object_t;
    obj_data        json_object_t;
  begin
    json_obj      := json_object_t(json_str_input);
    p_codleave    := hcm_util.get_string_t(json_obj, 'p_codleave');
    -- check type leave --
    begin
      select t2.flgtype into v_flgtype
        from tleavecd t1, tleavety t2
       where t1.typleave  = t2.typleave
         and t1.codleave  = p_codleave;
    exception when others then
        v_flgtype  := null;
    end;
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('flgtype',v_flgtype);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_flgtype_leave;

  procedure get_paternity_date (json_str_input in clob, json_str_output out clob) is
    v_flgtype       tleavety.flgtype%type;
    v_dteprgntst    temploy1.dteprgntst%type;
    p_codempid      temploy1.codempid%type;
    p_dteleave      date;
    json_obj        json_object_t;
    obj_data        json_object_t;
  begin
    json_obj      := json_object_t(json_str_input);
    p_codempid    := hcm_util.get_string_t(json_obj, 'p_codempid');
    p_dteleave    := to_date(hcm_util.get_string_t(json_obj, 'p_dteleave'),'dd/mm/yyyy');
    -- default dteprgntst --
    begin
      select dteprgntst into v_dteprgntst
        from temploy1
       where codempid = p_codempid
         and p_dteleave between add_months(dteprgntst, -9) and dteprgntst;
    exception when others then
      v_dteprgntst := null;
    end;
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('dteprgntst',to_char(v_dteprgntst,'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_paternity_date;

  function check_leave_after(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2 is
    v_flgworkth 	varchar2(10);
    v_date				date := p_dteleave + 1;
    v_codcompy  	tattence.codcomp%type;
    v_codcalen  	tattence.codcalen%type;
    v_typwork		  tattence.typwork%type;
    v_dtein				tattence.dtein%type;
    v_dteout			tattence.dteout%type;
    v_daydelay		number := 0;

  begin
    if p_dtereq is null or p_dteleave is null or p_daydelay is null then
      return 'Y';
    end if;
    if p_dtereq < v_date then
      return 'Y';
    end if;
    --
    loop
      begin
        select hcm_util.get_codcomp_level(a.codcomp,'1'),a.codcalen,a.typwork,a.dtein,a.dteout
          into v_codcompy,v_codcalen,v_typwork,v_dtein,v_dteout
          from tattence a
         where a.codempid = p_codempid
           and a.dtework  = v_date;
      exception when no_data_found then null;
      end;
      if p_dtereq < trunc(sysdate) then
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      else
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      end if;
      --
      if v_date >= p_dtereq or v_daydelay >= p_daydelay then
        exit;
      end if;
      v_date := v_date + 1;
    end loop;
    --
    if p_dtereq > v_date or v_daydelay > p_daydelay then
      return 'N';
    else
      return 'Y';
    end if;
  end;

  function check_leave_before(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2 is
    v_flgworkth 	varchar2(10);
    v_date				date := p_dtereq + 1;
    v_codcompy  	tattence.codcomp%type;
    v_codcalen  	tattence.codcalen%type;
    v_typwork		  tattence.typwork%type;
    v_dtein				tattence.dtein%type;
    v_dteout			tattence.dteout%type;
    v_daydelay		number := 0;

  begin
    if p_dtereq is null or p_dteleave is null or p_daydelay is null then
      return 'Y';
    end if;
    if p_dtereq > v_date then
      return 'Y';
    end if;
    --
    loop
      begin
        select hcm_util.get_codcomp_level(a.codcomp,'1'),a.codcalen,a.typwork,a.dtein,a.dteout
          into v_codcompy,v_codcalen,v_typwork,v_dtein,v_dteout
          from tattence a
         where a.codempid = p_codempid
           and a.dtework  = v_date;
      exception when no_data_found then null;
      end;

      if p_dtereq < trunc(sysdate) then
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      else
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      end if;
      --
      if v_date >= p_dteleave or v_daydelay >= p_daydelay then
        exit;
      end if;
      v_date := v_date + 1;
    end loop;

    if v_date < p_dteleave or v_daydelay < p_daydelay then
      return 'N';
    else
      return 'Y';
    end if;
    return 'Y';
  end;

 procedure get_list_appr(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;

    v_num           number := 0;
    obj_row         json_object_t := json_object_t();
    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t := json_object_t();

    type t_codappr is table of varchar2(30) index by pls_integer;
    v_codappr               t_codappr   := t_codappr();

    p_codempid_query        temploy1.codempid%type;
    v_codpos                temploy1.codpos%type;
    v_codcomp               temploy1.codcomp%type;
  begin
    json_obj                := json_object_t(json_str_input);
    p_codempid_query        := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    global_v_lang           := hcm_util.get_string_t(json_obj, 'p_lang');

    begin
        select codappr1, codappr2, codappr3, codappr4
        into v_codappr(1), v_codappr(2), v_codappr(3), v_codappr(4)
        from tempflow
        where codempid = p_codempid_query
            and codapp = 'HRES62E';
    exception when no_data_found then
        param_msg_error := get_error_msg_php('ESZ004', global_v_lang);
        json_str_output := get_response_message('404', param_msg_error, global_v_lang);

        return;
    end;

    for i in 1..4 loop
        if v_codappr(i) is not null then
            begin
                select codpos, codcomp
                into v_codpos, v_codcomp
                from temploy1
                where codempid = v_codappr(i);
            exception when no_data_found then
                v_codpos := null;
                v_codcomp := null;
            end;

            obj_data.put('numseq', i);
            obj_data.put('codappr', v_codappr(i));
            obj_data.put('desc_codappr', get_temploy_name(v_codappr(i), global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
            obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));

            obj_rows.put(to_char(v_num), obj_data);
            v_num := v_num + 1;
        end if;
    end loop;

    obj_row.put('rows', obj_rows);

    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_list_appr;
end;

/

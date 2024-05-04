--------------------------------------------------------
--  DDL for Package Body HRPYBGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYBGB" as

-- error pbin 13/01/2023 14:24  
-- last update: 16/12/2021 17:01||redmine#7357 user14

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure upd_log(p_codempid temploy1.codempid%type,
                    p_numpage varchar2,
                    p_fldedit varchar2,
                    p_typkey varchar2,
                    p_desold varchar2,
                    p_desnew varchar2,
                    p_codtable varchar2,
                    p_numseq number,
                    p_codseq number default null,
                    p_dteseq date default null) as

    v_datenew 	date;
    v_dateold 	date;
    v_desnew 	  varchar2(500) ;
    v_desold 	  varchar2(500) ;
    v_codcomp   varchar2(40) ;
  begin
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
      v_desnew := p_desnew ;
      v_desold := p_desold ;
      if  p_typkey = 'D' then
        if  p_desnew is not null and global_v_zyear = 543 then
          v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
          v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
        end if;
        if  p_desold is not null and global_v_zyear = 543 then
          v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
          v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
        end if;
      end if;

      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = p_codempid;
      end;

      insert into tpfmlog (codempid,dteedit,numpage,numseq,fldedit,typkey,fldkey,
                           codcomp,desold,desnew,codtable,codseq,codcreate,coduser,dteseq)
      values (p_codempid,sysdate,p_numpage,p_numseq,p_fldedit,p_typkey,p_fldedit,
              v_codcomp,v_desold,v_desnew,p_codtable,p_codseq,global_v_coduser,global_v_coduser,p_dteseq);
    end if;
  exception when others then
    rollback;
  end upd_log;
  --
  procedure check_index is
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang,'codcompy');
    else
      begin
        select	codcompy
          into	p_codcompy
          from	tcompny
         where	codcompy like p_codcompy;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        end;
    end if;

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcompy);
    if param_msg_error is not null then
      return;
    end if;
  end check_index;
  --
  procedure process_qtywken(p_sum_rec in out number,
                                           p_data in out varchar2,
                                           p_secur in out varchar2) is
    v_codcompy          tcompny.codcompy%type;
    v_ratecsbt1         tpfdinf.ratecsbt%type;
    v_ratecsbt2         tpfdinf.ratecsbt%type;
    v_rateesbt          tpfdinf.rateesbt%type;
    v_ratecret          tpfmemrt.ratecret%type;
    v_flgconded         tpfmemb.flgconded%type;
    v_numseq            tpfdinf.numseq%type;
    v_qtywken           tpfdinf.qtywken%type;
    v_flgdpvf           tpfmemrt.flgdpvf%type;
    v_dteeffec          tpfmemrt.dteeffec%type;

    v_qtywork           number;
    v_workage_day       number;
    v_workage_month     number;
    v_workage_year      number;
    v_empage_day        number;
    v_empage_month      number;
    v_empage_year       number;
    v_cond              varchar2(4000 char);
    v_stmt              varchar2(4000 char);
    v_day2              number;
    v_month2            number;
    v_year2             number;
    v_flgfound          boolean;
    v_row_id            varchar2(500);
    v_log_seq           number;

    v_secur			        boolean;
    flg_secur           varchar2(1) := 'N';
    cursor c_tpfmemb_rate is
      select a.codempid,b.dteempmt,b.dteempdb,b.codcomp,a.flgconded,
             b.codpos,b.typemp,b.codempmt,b.typpayroll,b.staemp,
             b.numlvl,b.jobgrade,a.codpfinf,a.dteeffec,a.rowid
        from tpfmemb a,temploy1 b
       where a.codempid = b.codempid
         and a.codcomp like (p_codcompy||'%') --and a.codempid = '0000039020'

/* Redmine #2497
         and (
              ( flgconded = '1' and months_between (trunc(sysdate),a.dteeffec) > nvl(qtywken,0) )
           or ( flgconded = '2' and months_between (trunc(sysdate),b.dteempmt) > nvl(qtywken,0) )
             )
Redmine #2497 */
--Redmine #2497
         and ((
              ( flgconded = '1' and months_between (trunc(sysdate),a.dteeffec) > nvl(qtywken,0) )
           or ( flgconded = '2' and months_between (trunc(sysdate),b.dteempmt) > nvl(qtywken,0) )
             ) or check_setup(p_codcompy, a.codempid) = 'Y' )
--Redmine #2497

         and a.codempid not in (select codempid
                                 from ttpminf where codcomp like (p_codcompy||'%')
                                  and dteeffec <= nvl(p_dteeffec, trunc(sysdate))
                                  and flgpy = 'N'
                                  and codtrn not in ('0001','0002','0003','0005')
                                  and codtrn not in (select codcodec
                                                       from tcodmove
                                                      where typmove = 'A'))
      order by a.codempid;

    cursor c_tpfeinf is
      select numseq,syncond,flgconded,flgconret
        from tpfeinf
       where codcompy   = v_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tpfhinf
                            where codcompy  = v_codcompy
                              and dteeffec  <= trunc(sysdate))
      order by numseq;
  begin
    for r3 in c_tpfmemb_rate loop
      p_data  := 'Y';
      v_secur	:= secur_main.secur3(r3.codcomp,r3.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_secur then
        p_secur := 'Y';

--p_secur :=  check_setup(p_codcompy, r3.codempid) ;


        v_codcompy  := get_codcompy(r3.codcomp);

--msg_err2(r3.codempid||'='||p_secur||'==IN  process_qtywken##2  v_codcompy  =  '||v_codcompy); --***** 0008

        get_service_year(r3.dteempmt,sysdate,'Y',v_workage_year,v_workage_month,v_workage_day);
        get_service_year(r3.dteempdb,sysdate,'Y',v_empage_year ,v_empage_month ,v_empage_day);

/*
msg_err2('IN  process_qtywken##3  flgconded *************  =  '||r3.flgconded);
msg_err2('IN  process_qtywken##3  v_workage_year  =  '||v_workage_year);
msg_err2('IN  process_qtywken##3  v_workage_month  =  '||v_workage_month);
msg_err2('IN  process_qtywken##3  v_workage_day  =  '||v_workage_day);
msg_err2('IN  process_qtywken##3  v_empage_year  =  '||v_empage_year);
msg_err2('IN  process_qtywken##3  v_empage_month  =  '||v_empage_month);
msg_err2('IN  process_qtywken##3  v_empage_day  =  '||v_empage_day);
*/
        for r2 in c_tpfeinf loop
          v_qtywork := v_workage_year * 12 + v_workage_month;
          v_cond := r2.syncond;
/*
msg_err2('IN  process_qtywken##4  v_cond  =  '||v_cond);
msg_err2('IN  process_qtywken##4  v_qtywork  =  '||v_qtywork);
*/
          v_cond := replace(v_cond,'V_TEMPLOY.CODEMPID'  ,''''||r3.codempid||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODCOMP'   ,''''||r3.codcomp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODPOS'    ,''''||r3.codpos||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.TYPEMP'    ,''''||r3.typemp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.CODEMPMT'  ,''''||r3.codempmt||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.TYPPAYROLL',''''||r3.typpayroll||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.STAEMP'    ,''''||r3.staemp||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.DTEEMPMT'  ,'to_date('''||to_char(r3.dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
          v_cond := replace(v_cond,'V_TEMPLOY.QTYWORK'   ,v_qtywork);
          v_cond := replace(v_cond,'V_TEMPLOY.NUMLVL'    ,''''||r3.numlvl||'''');
          v_cond := replace(v_cond,'V_TEMPLOY.JOBGRADE'  ,''''||r3.jobgrade||'''');
          v_cond := replace(v_cond,'TPFMEMB.CODPFINF'    ,''''||r3.codpfinf||'''');
--msg_err2('IN  process_qtywken##5  v_cond  =  '||v_cond);
          v_stmt := 'select count(*) from dual where '||v_cond;
          v_flgfound := execute_stmt(v_stmt);
          if v_flgfound then
--msg_err2('IN  process_qtywken##6');

            if r2.flgconded = '1' then
              get_service_year(r3.dteeffec,sysdate,'Y',v_year2 ,v_month2 ,v_day2);
              v_month2 := (v_year2 * 12) + v_month2;
--msg_err2('IN  process_qtywken##7  v_month2  =  '||v_month2);
            elsif r2.flgconded = '2' then
              get_service_year(r3.dteempmt,sysdate,'Y',v_year2 ,v_month2 ,v_day2);
              v_month2 := (v_year2 * 12) + v_month2;
--msg_err2('IN  process_qtywken##8  v_month2  =  '||v_month2);
            else
              v_year2  := null;
              v_month2 := null;
              v_day2   := null;
--msg_err2('IN  process_qtywken##9  v_month2  =  '||v_month2);
            end if;
            v_numseq    := r2.numseq;
            v_flgconded := r2.flgconded;
            exit;
          end if;
        end loop;

        if v_flgfound then
--msg_err2('IN  process_qtywken##10');

--v_ratecsbt1  --setup/comp
--v_rateesbt    --setup/emp

          begin
            select ratecsbt, rateesbt, qtywken
              into v_ratecsbt1, v_rateesbt, v_qtywken
              from tpfdinf
             where codcompy   = v_codcompy
               and numseq     = v_numseq
               and dteeffec   = (select max(dteeffec)
                                   from tpfdinf
                                  where dteeffec  <= trunc(sysdate)
                                    and codcompy  = v_codcompy
                                    and numseq    = v_numseq
                                    and v_month2 between qtywkst and qtywken)
               and v_month2 between qtywkst and qtywken
               and rownum   <= 1;
          exception when no_data_found then
            v_ratecsbt1   := null;
            v_rateesbt    := null;
          end;

--v_ratecret     --pvf/emp
--v_ratecsbt2   --pvf/comp
--v_flgdpvf       --(1-ตามนโยบาย,2-กำหนดเอง)
          begin
            select ratecret,ratecsbt,flgdpvf,dteeffec,rowid
              into v_ratecret,v_ratecsbt2,v_flgdpvf,v_dteeffec,v_row_id
              from tpfmemrt
             where codempid   = r3.codempid
               and dteeffec   = (select max(dteeffec)
                                   from tpfmemrt
                                  where codempid   = r3.codempid
                                    and dteeffec   <= trunc(sysdate));
          exception when no_data_found then
            v_ratecret  := null;
            v_ratecsbt2 := null;
--<<user14 16/12/2021 17:01||redmine#7357               
            --v_flgdpvf   := null;
            v_flgdpvf   := '1';
-->>user14 16/12/2021 17:01||redmine#7357               
            v_dteeffec  := null;
            v_row_id    := null;
          end;
          --

--<<error pbin 13/01/2023 14:24    
--v_ratecsbt1  --setup/comp
--v_ratecret     --pvf/emp
            if v_flgdpvf = '2' then
                v_rateesbt  := greatest(v_rateesbt,v_ratecret);
            end if;            
-->>error pbin 13/01/2023 14:24

          begin
            update tpfmemb
               set rateeret   = v_rateesbt,
                   ratecret   = v_ratecret,
                   qtywken    = v_qtywken,
                   flgconded  = v_flgconded,
                   coduser	  = global_v_coduser
            where rowid = r3.rowid;
          end;
          --
--<<user14 16/12/2021 17:01||redmine#7357           
          --if (v_flgdpvf = '1' and v_ratecret <> v_rateesbt) or (v_ratecsbt2 <> v_ratecsbt1) then
          if  (v_flgdpvf = '1' and nvl(v_ratecret,0) <> nvl(v_rateesbt,0) )   or (  nvl(v_ratecsbt2,0) <> nvl(v_ratecsbt1,0) ) then
-->>user14 16/12/2021 17:01||redmine#7357                     
            begin
              select nvl(max(numseq),0)+1 into v_log_seq
                from tpfmlog
               where codempid       = r3.codempid
                 and trunc(dteedit) = trunc(sysdate)
                 and numpage = 'HRPYBGB';
            end;

--msg_err2(r3.codempid||'===Insert tpfmemrt===');


            upd_log(r3.codempid,'HRPYBGB','RATECRET','C',v_ratecret,v_rateesbt,'TPFMEMRT',v_log_seq, null, v_dteeffec);
            upd_log(r3.codempid,'HRPYBGB','RATECSBT','N',v_ratecsbt2,v_ratecsbt1,'TPFMEMRT',v_log_seq, null, v_dteeffec);

            begin
              insert into tpfmemrt(codempid,dteeffec,flgdpvf,ratecret,ratecsbt,codcreate,coduser)
              values (r3.codempid,trunc(sysdate),v_flgdpvf,v_rateesbt,v_ratecsbt1,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
              update tpfmemrt
                 set ratecret = v_rateesbt,
                     ratecsbt = v_ratecsbt1,
                     coduser  = global_v_coduser
               where rowid    = v_row_id;
            end;

--Redmine #2497
          begin
            update tpfmemb
               set ratecret   = v_rateesbt,
                   coduser	  = global_v_coduser
            where rowid = r3.rowid;
          end;
--Redmine #2497

            p_sum_rec := nvl(p_sum_rec,0) + 1;
          end if;
        end if;
      end if;
    end loop;
  end;  -- procedure process_qtywken
  --
  procedure get_process (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- set complete batch process
    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_oracode   => param_msg_error
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end get_process;

  procedure process_data(json_str_output out clob) is
    obj_data      json_object_t;
    v_secur			  boolean;
    v_codempid	  varchar2(100 char);
    v_chk         varchar2(1);
    v_sumrec      number :=0;
    v_response	  varchar2(4000 char);
    flg_data      varchar2(1) := 'N';
    flg_secur     varchar2(1) := 'N';
    v_timest      date;
    v_timediff    varchar2(100 char);

    cursor c_ttpminf is
      select codempid, codcomp, codtrn, dteeffec, rowid, typpayroll ,codexemp ,numseq
       from ttpminf
      where	codcomp like (p_codcompy||'%')
        and	flgpy = 'N'
        and	dteeffec <= nvl(p_dteeffec, trunc(sysdate))
        and codtrn not in ('0001','0002','0003','0005')  --new emp.,punish,rehire.
        and codtrn not in (select codcodec
                             from tcodmove
                            where typmove = 'A')
      order by codempid;

    cursor c_tpfmemb is
      select tpfmemb.*, rowid
        from tpfmemb
       where codempid = v_codempid
         and dtereti is null
       order by codempid;
  begin
    v_timest := systimestamp;
--    for i in c_ttpminf loop
--      v_sumrec := v_sumrec+1;
--    end loop;

    for i in c_ttpminf loop
      flg_data := 'Y';
      v_secur	:= secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_secur then
        flg_secur := 'Y';
        v_codempid	:= i.codempid;
        if i.codtrn = '0006' then
          /* begin
            select 'Y'
            into  v_chk
            from  ttpminf
            where codempid = i.codempid
            and   dteeffec = i.dteeffec
            and   codtrn   = '0002' --rehire
            and   numseq   > i.numseq;
          exception when  others then
            v_chk := 'N' ;
          end ;

          if v_chk = 'N' then*/
          for j in c_tpfmemb loop
            update tpfmemb
               set dtereti    = i.dteeffec,
                   codreti    = i.codexemp,
                   coduser	  = global_v_coduser,
                   flgemp = '2'
            where rowid = j.rowid;

            begin
              insert into tpfregst (codempid,dtereti,dteeffec,codreti,
                                    codpfinf,codplan,amtcaccu,amtcretn,
                                    amteaccu,amteretn,amtinteccu,amtintaccu,rateeret,
                                    ratecret,codcreate,coduser)
              values (i.codempid,i.dteeffec,j.dteeffec,i.codexemp,
                      j.codpfinf,j.codplan,j.amtcaccu,j.amtcretn,
                      j.amteaccu,j.amteretn,j.amtinteccu,j.amtintaccu,j.rateeret,
                      j.ratecret,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
              update tpfregst
                 set dteeffec      = j.dteeffec,
                     codreti       = i.codexemp,
                     codpfinf      = j.codpfinf,
                     codplan       = j.codplan,
                     amtcaccu      = j.amtcaccu,
                     amtcretn      = j.amtcretn,
                     amteaccu      = j.amteaccu,
                     amteretn      = j.amteretn,
                     amtinteccu    = j.amtinteccu,
                     amtintaccu    = j.amtintaccu,
                     rateeret      = j.rateeret,
                     ratecret      = j.ratecret,
                     coduser       = global_v_coduser
               where codempid      = i.codempid
                 and dtereti       = i.dteeffec;
            end;
          end loop;
--          end if;
        else
          for j in c_tpfmemb loop
            update tpfmemb
               set codcomp = i.codcomp,
                   typpayroll = i.typpayroll,
                   coduser = global_v_coduser
            where rowid = j.rowid;
          end loop;
        end if;

        update ttpminf
           set flgpy =	'Y',
              coduser	= global_v_coduser
        where rowid = i.rowid;
        v_sumrec := v_sumrec + 1;
      end if;

    end loop;
    --
    process_qtywken(v_sumrec,flg_data,flg_secur);
    begin
      select to_char(trunc(extract( hour   from timediff )),'FM00')||':'||
             to_char(trunc(extract( minute from timediff )),'FM00')||':'||
             to_char(trunc(extract( second from timediff )),'FM00')
        into v_timediff
        from (select systimestamp - v_timest timediff from dual);
    exception when others then null;
    end;
    --
    if flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttpminf');
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
      return;
    elsif flg_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
      return;
    else
      commit;
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);

      -- set complete batch process
      global_v_batch_flgproc  := 'Y';
      global_v_batch_qtyproc  := nvl(v_sumrec,0);
    end if;
--    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('sumrec', nvl(v_sumrec,0));
    obj_data.put('time', v_timediff);
--    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response := get_response_message(null,param_msg_error,global_v_lang);
    obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end process_data;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;

  --Redmine #2497
  function check_setup(p_codcompy  varchar2,p_codempid  varchar2) return varchar2 is
    v_chksetup  varchar2(30) := 'N';
    v_dteeffec1 date;
    v_dteeffec2 date;
    v_flgdpvf   tpfmemrt.flgdpvf%type;
  begin
--msg_err2('IN  check_setup##1 p_codcompy = '||p_codcompy);
--msg_err2('IN  check_setup##1 p_codempid = '||p_codempid);
    begin
       select dteeffec,flgdpvf into  v_dteeffec1 ,v_flgdpvf
         from tpfmemrt
        where codempid  = p_codempid
          and dteeffec  = (select max(dteeffec) from tpfmemrt
                             where codempid  = p_codempid
                               and dteeffec <= trunc(sysdate));
--msg_err2('IN  check_setup##1 aa');
         exception when no_data_found then
           v_dteeffec1 := null;

--<< user14 16/12/2021 17:01||redmine#7357  
           --v_flgdpvf   := null;
           v_flgdpvf   := 1;
-->> user14 16/12/2021 17:01||redmine#7357  

--msg_err2('IN  check_setup##1 bb');
    end;

--msg_err2('IN  v_flgdpvf##1 bb = '||v_flgdpvf);
    if v_flgdpvf  = 1 then --ตามนโยบาย
        begin
            select x.dteeffec into v_dteeffec2
             from tpfhinf x
             where x.codcompy = p_codcompy
             and x.dteeffec  = (select max(y.dteeffec)
                                  from tpfhinf y
                                 where y.CODCOMPY =p_codcompy
                                   and y.dteeffec  <= trunc(sysdate) );
             exception when no_data_found then
                v_dteeffec2  := null;
         end;

--msg_err2('IN  v_dteeffec1##1 bb = '||v_dteeffec1);
--msg_err2('IN  v_dteeffec2##1 bb = '||v_dteeffec2);

         if v_dteeffec1 < v_dteeffec2 then
              v_chksetup := 'Y';
--<< user14 16/12/2021 17:01||redmine#7357                
         elsif v_dteeffec1 is null then
              v_chksetup := 'Y';
-->> user14 16/12/2021 17:01||redmine#7357                
         end if;
    end if;--if v_flgdpvf  = 1 then --ตามนโยบาย

    return(v_chksetup);
  end;
  --Redmine #2497

  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
/*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = global_v_coduser;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(global_v_coduser,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;


end HRPYBGB;

/

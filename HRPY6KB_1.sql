--------------------------------------------------------
--  DDL for Package Body HRPY6KB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY6KB" as
  function cal_hhmiss (p_st date,p_en date) return varchar2 is
    v_num  number := 0;
    v_sc   number := 0;
    v_mi   number := 0;
    v_hr   number := 0;
    v_time varchar2(500 char);
  begin
    v_num  := ((p_en - p_st) * 86400) + 1;
    v_hr   := trunc(v_num/3600);
    v_mi   := mod  (v_num,3600);
    v_sc   := mod  (v_mi ,60);
    v_mi   := trunc(v_mi /60);
    v_time := lpad(v_hr,2,0) || ':' || lpad(v_mi,2,0) || ':' || lpad(v_sc,2,0);
    return (v_time);
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(obj_detail,'p_dtetim'),'dd/mm/yyyyhh24miss');
    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codempid          := hcm_util.get_string_t(obj_detail,'codempid_query');
    p_year              := to_number(hcm_util.get_string_t(obj_detail,'year'));
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_process as
  v_count number :=0;
  v_typpayroll  temploy1.typpayroll%type;
  v_codcomp     temploy1.codcomp%type;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
--2446
    if (to_number(to_char(sysdate,'yyyy'))) < p_year then
      param_msg_error := get_error_msg_php('PY0009',global_v_lang,'year');
      return;
    end if;
--2446
    if p_codempid is null and p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp , codempid');
      return;
    end if;
    if p_codempid is not null then
      p_codcomp := '';
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_numlvlsalst, global_v_numlvlsalen, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
      -----
         begin
           select   typpayroll,codcomp
             into   v_typpayroll,v_codcomp
             from   temploy1
             where  codempid = p_codempid;
           exception when no_data_found then
            v_typpayroll    := null;
            v_codcomp       := null;
        end;
      -----
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
   --------------------

    begin
        select count(*)
          into v_count
          from tdtepay
         where codcompy   = nvl(hcm_util.get_codcomp_level(p_codcomp,1),hcm_util.get_codcomp_level(v_codcomp,1))
           and typpayroll = nvl(v_typpayroll,typpayroll)
           and dteyrepay  = p_year
           and nvl(flgcal,'N') = 'N';
    end;
    if v_count > 0  then
      param_msg_error := get_error_msg_php('PY0069',global_v_lang);
      return;
    end if;
   ----
       begin
        select count(*)
          into v_count
          from tdtepay
         where codcompy   = nvl(hcm_util.get_codcomp_level(p_codcomp,1),hcm_util.get_codcomp_level(v_codcomp,1))
           and typpayroll = nvl(v_typpayroll,typpayroll)
           and dteyrepay  = p_year;
    end;
    if v_count = 0  then
      param_msg_error := get_error_msg_php('PY0069',global_v_lang);
      return;
    end if;
   ----

  end check_process;
  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
        gen_process(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
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

  procedure gen_process(json_str_output out clob) as
    obj_detail        json_object_t := json_object_t();
    v_numrec          number := 0;
    v_time            varchar2(4000 char);
  begin
    start_process(p_year,p_codcomp,p_codempid,v_numrec,v_time);
    obj_detail.put('numrec',to_char(v_numrec,'fm99999999990'));
    obj_detail.put('time',v_time);
    obj_detail.put('response',hcm_secur.get_response('200',get_error_msg_php('HR2715',global_v_lang),global_v_lang));
    obj_detail.put('coderror','200');
    json_str_output := obj_detail.to_clob;

    -- set complete batch process
    global_v_batch_flgproc := 'Y';
    global_v_batch_qtyproc := nvl(v_numrec,0);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );

  end gen_process;
  procedure start_process(p_dteyrepay in number,
                          p_codcomp   in varchar2,
                          p_codempid  in varchar2,
                          o_numrec    out number,
                          o_time      out varchar2) as

    v_count            number := 0;
    v_sysdate_before   date;
    v_sysdate_after    date;
    v_codempid         temploy1.codempid%type;
    v_flg_secure       boolean := false;

    cursor c1 is
      select a.codempid,b.dtebf,a.codcomp,a.numlvl,typtax,flgtax,amtincbf,amttaxbf,
             amtpf,amtsaid,amtincsp,amttaxsp,amtsasp,amtpfsp,stamarry,
             dteyrrelf,dteyrrelt,amtrelas,amttaxrel,qtychldb,qtychlda,qtychldd,qtychldi
         from temploy1 a,temploy3 b
       where a.codempid = b.codempid
          and a.codempid = nvl(p_codempid,a.codempid)
           and codcomp like p_codcomp || '%'
           and ((staemp in ('1','3')) or
                   ((staemp = '9') and
                    (to_number(to_char(nvl(dteeffex,sysdate),'yyyy')) >= p_dteyrepay)))
    order by a.codempid;

    cursor c2 is
       select coddeduct,amtdeduct,amtspded
         from tempded
       where codempid = v_codempid
    order by coddeduct;

    cursor c3 is
      select coddeduct,flgclear
        from tdeductd
       where codcompy = nvl(hcm_util.get_codcomp_level(p_codcomp, 1),codcompy)
         and dteyreff = (select max(dteyreff)
                                   from tdeductd
                                  where codcompy  = nvl(hcm_util.get_codcomp_level(p_codcomp, 1),codcompy)
                                    and dteyreff <= p_dteyrepay)
    order by coddeduct;

  begin

    v_sysdate_before  := sysdate;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
                 v_codempid := r1.codempid;
                 if to_number(to_char(r1.dtebf,'yyyy')) < to_number(to_char(sysdate,'yyyy')) then
                            begin
                              delete tlastempd
                               where dteyrepay = p_dteyrepay
                                 and codempid  = r1.codempid;
                            exception when others then
                              null;
                            end;
                            for r2 in c2 loop
                              insert into tlastempd
                                          (dteyrepay,codempid,coddeduct,codcomp,
                                           amtdeduct,amtspded,
                                           codcreate)
                                 values (p_dteyrepay ,r1.codempid,r2.coddeduct  ,r1.codcomp,
                                            r2.amtdeduct,r2.amtspded,
                                            global_v_coduser);
                            end loop;
                            begin
                              insert into tlastded
                                          (dteyrepay ,codempid  ,codcomp  ,typtax   ,
                                           flgtax    ,amtincbf  ,amttaxbf ,amtpf    ,
                                           amtsaid   ,amtincsp  ,amttaxsp ,amtsasp  ,
                                           amtpfsp    ,stamarry ,
                                           dteyrrelf ,dteyrrelt ,amtrelas ,amttaxrel,
                                           qtychldb, qtychlda, qtychldd, qtychldi,
                                           codcreate   )
                              values   (p_dteyrepay ,r1.codempid       ,r1.codcomp     ,r1.typtax,
                                           r1.flgtax       ,r1.amtincbf       ,r1.amttaxbf    ,r1.amtpf     ,
                                           r1.amtsaid    ,r1.amtincsp       ,r1.amttaxsp    ,r1.amtsasp   ,
                                           r1.amtpfsp   ,r1.stamarry  ,
                                           r1.dteyrrelf   ,r1.dteyrrelt      ,r1.amtrelas    ,r1.amttaxrel ,
                                           r1.qtychldb, r1.qtychlda, r1.qtychldd, r1.qtychldi,
                                           global_v_coduser);
                            exception when dup_val_on_index then
                              update tlastded
                                 set codcomp   = r1.codcomp,
                                     typtax    = r1.typtax,
                                     flgtax    = r1.flgtax,
                                     amtincbf  = r1.amtincbf,
                                     amttaxbf  = r1.amttaxbf,
                                     amtpf     = r1.amtpf,
                                     amtsaid   = r1.amtsaid,
                                     amtincsp  = r1.amtincsp,
                                     amttaxsp  = r1.amttaxsp,
                                     amtsasp   = r1.amtsasp,
                                     amtpfsp   = r1.amtpfsp,
                                     stamarry  = r1.stamarry,
                                     dteyrrelf = r1.dteyrrelf,
                                     dteyrrelt = r1.dteyrrelt,
                                     amtrelas  = r1.amtrelas,
                                     amttaxrel = r1.amttaxrel,
                                     qtychldb = r1.qtychldb, 
                                     qtychlda = r1.qtychlda, 
                                     qtychldd = r1.qtychldd, 
                                     qtychldi = r1.qtychldi,
                                     coduser   = global_v_coduser
                               where dteyrepay = p_dteyrepay
                                 and codempid  = r1.codempid;
                            end;
                            update temploy3
                               set amtincbf = stdenc(0,codempid,global_v_chken),
                                   amttaxbf = stdenc(0,codempid,global_v_chken),
                                   amtpf    = stdenc(0,codempid,global_v_chken),
                                   amtsaid  = stdenc(0,codempid,global_v_chken),
                                   dtebf    = to_date('01/01/'||(p_dteyrepay+1),'dd/mm/yyyy'),
                                   amtincsp = stdenc(0,codempid,global_v_chken),
                                   amttaxsp = stdenc(0,codempid,global_v_chken),
                                   amtpfsp  = stdenc(0,codempid,global_v_chken),
                                   amtsasp  = stdenc(0,codempid,global_v_chken),
                                   dtebfsp  = to_date('01/01/'||(p_dteyrepay+1),'dd/mm/yyyy'),
                                   coduser   = global_v_coduser
                             where codempid = r1.codempid;
                            for r3 in c3 loop
                              if r3.flgclear = 'Y' then
                                delete tempded
                                 where codempid  = r1.codempid
                                   and coddeduct = r3.coddeduct;
                              end if;
                            end loop;
                 end if;

                 v_count := v_count+1;
                 if mod(v_count,100) = 0 then
                   commit;
                 end if;
      end if;
    end loop;

    v_sysdate_after  := sysdate;
    o_numrec         := v_count;
    o_time           := cal_hhmiss(v_sysdate_before,v_sysdate_after);
  end start_process;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;
end hrpy6kb;

/

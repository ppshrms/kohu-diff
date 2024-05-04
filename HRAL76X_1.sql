--------------------------------------------------------
--  DDL for Package Body HRAL76X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL76X" is
-- last update: 08/05/2019 16:15
-- last update: 24/11/2020  st11-error log#3341  15:56
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    -- index
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_comgrp            := upper(hcm_util.get_string_t(json_obj,'p_comgrp'));
    p_typpayroll        := upper(hcm_util.get_string_t(json_obj,'p_typpayroll'));
    p_codrep            := upper(hcm_util.get_string_t(json_obj, 'p_codrep'));
    p_namrep            := hcm_util.get_string_t(json_obj, 'p_namrep');
    p_namrepe           := hcm_util.get_string_t(json_obj, 'p_namrepe');
    p_namrept           := hcm_util.get_string_t(json_obj, 'p_namrept');
    p_namrep3           := hcm_util.get_string_t(json_obj, 'p_namrep3');
    p_namrep4           := hcm_util.get_string_t(json_obj, 'p_namrep4');
    p_namrep5           := hcm_util.get_string_t(json_obj, 'p_namrep5');
    p_typcode           := hcm_util.get_string_t(json_obj, 'p_typcode');
    p_codinc            := hcm_util.get_json_t(json_obj, 'p_codinc');

    -- detail
    p_flgrpttype        := hcm_util.get_string_t(json_obj, 'p_flgrpttype');
    p_flgtransfer       := hcm_util.get_string_t(json_obj, 'p_flgtransfer');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid');
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll        varchar2(100 char);
    v_comgrp            varchar2(100 char);
    v_codempid          varchar2(100 char);
  begin
    if p_codcomp is not null then
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;

    if p_comgrp is not null then
      begin
        select codcodec
          into v_comgrp
          from tcompgrp
         where codcodec = p_comgrp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompgrp');
        return;
      end;
    end if;

    if p_codempid is not null then
        begin
            select codempid
              into v_codempid
              from TEMPLOY1
             where codempid = p_codempid;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompgrp');
            return;
        end;
        begin
          if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
        end;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_data            json_object_t;
    v_rcnt_codinc       number := 0;

    obj_codinc          json_object_t;

    cursor c_tinitregh is
      select descode, descodt, descod3, descod4, descod5,
             decode(global_v_lang, '101', descode
                                 , '102', descodt
                                 , '103', descod3
                                 , '104', descod4
                                 , '105', descod5, '') namrep
        from tinitregh
       where codapp  = p_codapp
         and codrep  = nvl(p_codrep, 'TEMP');

    cursor c_tinitregd is
        select      numseq, codinc
        from        tinitregd
        where       codapp = p_codapp
        and         codrep = p_codrep
        order by    numseq;

	cursor c_tpaysum is
		select codpay
		  from tpaysum
		 where numperiod  = p_numperiod
		   and dtemthpay  = p_dtemthpay
		   and dteyrepay  = p_dteyrepay
		   and codempid   = nvl(p_codempid,codempid)
		   and codcomp like nvl(p_codcomp||'%','%')
		   and hcm_util.get_codcompy(codcomp)   in (select codcompy
                                                               from tcompny
                                                              where compgrp = nvl(p_comgrp,compgrp)
                                                              or (compgrp is null and p_comgrp is null))
  		   and typpayroll = nvl(p_typpayroll,typpayroll)
		   and flgtran    = decode(p_flgtransfer,'A',flgtran,p_flgtransfer)
		   and (p_flgrpttype = '1'
		    or (p_flgrpttype = '2' and codalw not in ('AWARD','RET_AWARD')))
	group by codpay
	order by codpay;

  begin
    obj_codinc         := json_object_t();
    obj_data           := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('namrep', '');
    obj_data.put('namrepe', '');
    obj_data.put('namrept', '');
    obj_data.put('namrep3', '');
    obj_data.put('namrep4', '');
    obj_data.put('namrep5', '');
    obj_data.put('codinc', obj_codinc);
    for r1 in c_tinitregh loop
      obj_data.put('coderror', '200');
      obj_data.put('namrep', r1.namrep);
      obj_data.put('namrepe', r1.descode);
      obj_data.put('namrept', r1.descodt);
      obj_data.put('namrep3', r1.descod3);
      obj_data.put('namrep4', r1.descod4);
      obj_data.put('namrep5', r1.descod5);

      for r2 in c_tinitregd loop
        if r2.codinc is not null then
          v_rcnt_codinc   := v_rcnt_codinc + 1;
          obj_codinc.put(to_char(v_rcnt_codinc - 1), to_char(r2.codinc));
        end if;
      end loop;

      obj_data.put('codinc', obj_codinc);
    end loop;

      if v_rcnt_codinc = 0 then
          for r3 in c_tpaysum loop
            if r3.codpay is not null then
              v_rcnt_codinc   := v_rcnt_codinc + 1;
              obj_codinc.put(to_char(v_rcnt_codinc - 1), to_char(r3.codpay));
            end if;
          end loop;
          obj_data.put('codinc', obj_codinc);
      end if;

    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure get_codpay (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_codpay (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end get_codpay;

  procedure gen_codpay (json_str_output out clob) is
    obj_data          json_object_t;
    obj_codinc        json_object_t;
/*
    cursor c_tinexinf_codinc is
      select codpay, decode(global_v_lang, '101', descpaye
                                          , '102', descpayt
                                          , '103', descpay3
                                          , '104', descpay4
                                          , '105', descpay5
                                          , '') descpay
        from tinexinf
       where typpay in (1, 2, 3, 4, 5, 6)
    order by codpay ;
*/

    cursor c_tinexinf_codinc is
      select distinct  codpay, decode(global_v_lang, '101', descpaye
                                          , '102', descpayt
                                          , '103', descpay3
                                          , '104', descpay4
                                          , '105', descpay5
                                          , '') descpay
        from tinexinf
       where typpay in (1, 2, 3, 4, 5, 6)
         and codpay in (select codpay
                      from tpaysum
                     where numperiod  = p_numperiod
                       and dtemthpay  = p_dtemthpay
                       and dteyrepay  = p_dteyrepay
                       )
    order by codpay ;

  begin
    obj_codinc        := json_object_t();

      for c1 in c_tinexinf_codinc loop
        obj_codinc.put(c1.codpay, c1.descpay);

      end loop;

    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codinc', obj_codinc);

    json_str_output := obj_data.to_clob;
  end gen_codpay;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
    v_maxrcnt           number := 0;
    v_rcnt              number := 0;
    v_tmprcnt           number := 0;
    v_codinc            varchar2(4 char);
    v_codpayhavedata    number;
    v_codpayotcnt       number := 0;
    v_flghasot          boolean := false;
    obj_data            json_object_t;
    obj_codinc          json_object_t;
  begin
    initial_value (json_str_input);
    if global_v_lang = '101' then
      p_namrepe := p_namrep;
    elsif global_v_lang = '102' then
      p_namrept := p_namrep;
    elsif global_v_lang = '103' then
      p_namrep3 := p_namrep;
    elsif global_v_lang = '104' then
      p_namrep4 := p_namrep;
    elsif global_v_lang = '105' then
      p_namrep5 := p_namrep;
    end if;
    obj_codinc        := json_object_t();
    begin
      insert
        into tinitregh (
          codapp, codrep, typcode,
          descode, descodt, descod3, descod4, descod5,
          codcreate
        )
      values (
        p_codapp, nvl(p_codrep, 'TEMP'), 1,
        p_namrepe, p_namrept, p_namrep3, p_namrep4, p_namrep5,
        global_v_coduser
      );
    exception when dup_val_on_index then
      update tinitregh
          set typcode = 1,
              descode = p_namrepe,
              descodt = p_namrept,
              descod3 = p_namrep3,
              descod4 = p_namrep4,
              descod5 = p_namrep5,
              coduser = global_v_coduser
        where codapp = p_codapp
          and codrep = nvl(p_codrep, 'TEMP');
    end;
    if param_msg_error is null /*AND p_codrep is not null*/ then
      v_maxrcnt        := p_codinc.get_size;

      for i in 0..v_maxrcnt - 1 loop

        v_codinc        := hcm_util.get_string_t(p_codinc, to_char(i));

        begin
            select 1
              into v_codpayhavedata
              from tpaysum
             where numperiod  = p_numperiod
               and dtemthpay  = p_dtemthpay
               and dteyrepay  = p_dteyrepay
               and codempid   = nvl(p_codempid,codempid)
               and codcomp like nvl(p_codcomp||'%','%')
               and hcm_util.get_codcompy(codcomp)   in (select codcompy
                                                               from tcompny
                                                              where compgrp = nvl(p_comgrp,compgrp)
                                                              or (compgrp is null and p_comgrp is null))
            and typpayroll = nvl(p_typpayroll,typpayroll)
               and flgtran    = decode(p_flgtransfer,'A',flgtran,p_flgtransfer)
               and (p_flgrpttype = '1'
                or (p_flgrpttype = '2' and codalw not in ('AWARD','RET_AWARD')))
               and codpay = v_codinc
               and codalw <> 'OT'
               and rownum =1;
            exception when others then
                v_codpayhavedata := 0;
        end;

        begin
            select count(codpay) + v_codpayotcnt
              into v_codpayotcnt
              from tpaysum
             where numperiod  = p_numperiod
               and dtemthpay  = p_dtemthpay
               and dteyrepay  = p_dteyrepay
               and codempid   = nvl(p_codempid,codempid)
               and codcomp like nvl(p_codcomp||'%','%')
               and hcm_util.get_codcompy(codcomp)   in (select codcompy
                                                               from tcompny
                                                              where compgrp = nvl(p_comgrp,compgrp)
                                                              or (compgrp is null and p_comgrp is null))
               and typpayroll = nvl(p_typpayroll,typpayroll)
               and flgtran    = decode(p_flgtransfer,'A',flgtran,p_flgtransfer)
               and (p_flgrpttype = '1'
                or (p_flgrpttype = '2' and codalw not in ('AWARD','RET_AWARD')))
               and codpay = v_codinc
               and codalw = 'OT';
        end;

        begin
        v_rcnt          := v_rcnt + 1;
          insert
            into tinitregd (
              codapp, codrep, numseq, codinc, codded, codcreate
            )
          values (
            p_codapp, nvl(p_codrep, 'TEMP'), v_rcnt, v_codinc, null, global_v_coduser
          );
        exception when dup_val_on_index then
          update tinitregd
            set codinc = v_codinc,
                codded = null,
                coduser = global_v_coduser
          where codapp = p_codapp
            and codrep = nvl(p_codrep, 'TEMP')
            and numseq = v_rcnt;
        end;

        begin
          insert
            into tinitregd (
              codapp, codrep, numseq, codinc, codded, codcreate
            )
          values (
            p_codapp, 'TEMP', v_rcnt, v_codinc, null, global_v_coduser
          );
        exception when dup_val_on_index then
          update tinitregd
            set codinc = v_codinc,
                codded = null,
                coduser = global_v_coduser
          where codapp = p_codapp
            and codrep = 'TEMP'
            and numseq = v_rcnt;
        end;

        if v_codpayhavedata > 0 then
        v_tmprcnt          := v_tmprcnt + 1;
            /*begin

              insert
                into tinitregd (
                  codapp, codrep, numseq, codinc, codded, codcreate
                )
              values (
                p_codapp, 'TEMP', v_tmprcnt, v_codinc, null, global_v_coduser
              );
            exception when dup_val_on_index then
              update tinitregd
                set codinc = v_codinc,
                    codded = null,
                    coduser = global_v_coduser
              where codapp = p_codapp
                and codrep = 'TEMP'
                and numseq = v_tmprcnt;
            end;
*/
            obj_codinc.put(to_char(v_tmprcnt - 1), v_codinc);
       end if;
      end loop;
      delete from tinitregd
       where codapp = p_codapp
         and (  (codrep = p_codrep and numseq > v_rcnt) or
                (codrep = 'TEMP' and numseq > v_rcnt) );

         if v_codpayotcnt > 0 then
            v_flghasot := true;
         end if;

        obj_data          := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codinc', obj_codinc);
        obj_data.put('flghasot', v_flghasot);

        json_str_output := obj_data.to_clob;

    end if;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end save_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_rcnt        number;
    v_exist       boolean := false;
    v_flgpass     boolean := false;
    v_flg3007     boolean := false;
    v_codempid    varchar2(30 char);
    v_numseq      number  := 0;

    r1_numlvl     number;
    r1_codcomp    tcenter.codcomp%type;
    v_typpayroll  varchar2(10 char);

    v_stmt        clob;
    v_stmt_inc    clob;
    v_stmt_timinc clob;
    v_stmt_codinc_cond clob;

    v_amtot10 number;
    v_timot10 number;
    v_amtot15 number;
    v_timot15 number;
    v_amtot20 number;
    v_timot20 number;
    v_amtot30 number;
    v_timot30 number;
    v_amtototh number;
    v_timototh number;

    v_amtot10ch varchar2(1000 char);
    v_amtot15ch varchar2(1000 char);
    v_amtot20ch varchar2(1000 char);
    v_amtot30ch varchar2(1000 char);
    v_amtotothch varchar2(1000 char);

    v_concat      varchar2(2 char);

    curid         number;
    desctab       dbms_sql.desc_tab;
    colcnt        number;
    namevar       varchar2(4000 char);
    numvar        number;
    datevar       date;
    v_dtework     varchar2(10 char);
    empno         number := 100;
    v_dummy       integer;

    v_row           number := 0;
    v_timrcnt       number := 0;
    v_rcnt_inc      number := 0;
    v_rcnt_timinc   number := 0;
    v_count         number := 0;
    v_codempid_tmp  varchar2(10 char) := '#$%%';
    type amtinc_arr is table of  varchar2(400 char) index by binary_integer;
      v_amtinc_arr  amtinc_arr;
      v_timinc_arr  amtinc_arr;
      cntNotOT number := 0;

    cursor c_tcontrpy is
        select codcompy
          from tcontrpy
      group by codcompy
      order by codcompy;

    cursor c_tinitregd is
      select a.numseq, a.codinc, a.codded
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = p_codapp
         and a.codapp  = b.codapp
--         and a.codrep  = nvl(p_codrep, 'TEMP')
         and a.codrep  = 'TEMP'
         and b.typcode = p_typcode
         and nvl(a.coduser,a.codcreate) = global_v_coduser
       order by a.numseq;
  begin
    obj_row          := json_object_t();

    if p_flgrpttype = '1' then
        v_stmt := 'select b.codcomp,a.codempid,TO_CHAR(sysdate, ''DD/MM/YYYY'') as dtework';
        v_concat := ',';
        for r0 in c_tinitregd loop
          if r0.codinc is not null then
              BEGIN
                    SELECT  count(codalw)
                    INTO    cntNotOT
                    FROM    tpaysum
                    WHERE   codpay = r0.codinc
                    AND     codalw <> 'OT';
                  exception when others then
                        cntNotOT := 0;
               END;
                v_rcnt_inc := v_rcnt_inc + 1;
                if cntNotOT > 0 then
                    -- Amount
                    v_stmt_inc := v_stmt_inc || v_concat || '
                    sum(decode(codpay,''' || r0.codinc || ''',nvl(stddec(amtpay,a.codempid, ''' || v_chken || ''' ),0),0)) amtinc' || to_char(r0.numseq);
                    --Time
                    v_rcnt_timinc := v_rcnt_timinc + 1;
                    v_stmt_timinc := v_stmt_timinc || v_concat || '
                    sum(decode(codpay,''' || r0.codinc || ''',qtyday,0)) timinc' || to_char(r0.numseq);
                end if;

                v_stmt_codinc_cond := v_stmt_codinc_cond || case when v_stmt_codinc_cond is null then '' else v_concat end || '''' || r0.codinc || '''';
          end if;


        end loop;

        v_stmt := v_stmt || v_stmt_inc || v_stmt_timinc;
        v_stmt := v_stmt || '
              from tpaysum a ,temploy1 b
             where numperiod  = nvl(' || (p_numperiod) || ', numperiod)
               and dtemthpay  = nvl(' || (p_dtemthpay) || ', dtemthpay)
               and dteyrepay  = ' || (p_dteyrepay) || '
               and a.codempid   = b.codempid
               and a.codempid   = nvl(''' || p_codempid || ''',a.codempid)
               and a.codcomp like nvl(''' || p_codcomp || '%'',''%'')
               and hcm_util.get_codcomp_level(a.codcomp, 1)   in ( select codcompy                                
                                                                   from tcompny 
                                                                  where (compgrp = nvl(''' || p_comgrp || ''',compgrp)
                                                                    or (compgrp is null and ''' || p_comgrp || ''' is null ) )
                                                                  )
               and a.typpayroll = nvl(''' || p_typpayroll || ''',a.typpayroll)
               and flgtran    = decode(''' || p_flgtransfer || ''',''A'',flgtran,''' || p_flgtransfer || ''')
               and codpay in (' || v_stmt_codinc_cond || ')
        group by b.codcomp,a.codempid
        order by b.codcomp,a.codempid';
    elsif p_flgrpttype = '2' then
        v_stmt := 'select a.codcomp,a.codempid,TO_CHAR(b.dtework, ''DD/MM/YYYY'') as dtework';
        v_concat := ',';
        for r0 in c_tinitregd loop
          if r0.codinc is not null then
              BEGIN
                    SELECT  count(codalw)
                    INTO    cntNotOT
                    FROM    tpaysum
                    WHERE   codpay = r0.codinc
                    AND     codalw <> 'OT';
                  exception when others then
                        cntNotOT := 0;
               END;

            -- Amount
            v_rcnt_inc := v_rcnt_inc + 1;
            if cntNotOT > 0 then
                v_stmt_inc := v_stmt_inc || v_concat || '
                sum(decode(b.codpay,''' || r0.codinc || ''',nvl(stddec(b.amtpay,a.codempid,''' || v_chken || '''),0),0)) amtinc' || to_char(r0.numseq);
                --Time
                v_rcnt_timinc := v_rcnt_timinc + 1;
                v_stmt_timinc := v_stmt_timinc || v_concat || '
                sum(decode(b.codpay,''' || r0.codinc || ''',b.qtymin,0)) timinc' || to_char(r0.numseq);
            end if;
            v_stmt_codinc_cond := v_stmt_codinc_cond || case when v_stmt_codinc_cond is null then '' else v_concat end || '''' || r0.codinc || '''';
          end if;
        end loop;

        v_stmt := v_stmt || v_stmt_inc || v_stmt_timinc;
        v_stmt := v_stmt || '
              from tpaysum a,tpaysum2 b
             where a.dteyrepay  = b.dteyrepay
               and a.dtemthpay  = b.dtemthpay
               and a.numperiod  = b.numperiod
               and a.codempid   = b.codempid
               and a.codalw     = b.codalw
               and a.codpay     = b.codpay
               and a.numperiod  = ' || (p_numperiod) || '
               and a.dtemthpay  = ' || (p_dtemthpay) || '
               and a.dteyrepay  = ' || (p_dteyrepay) || '
               and a.codempid   = nvl(''' || p_codempid || ''',a.codempid)
               and a.codcomp      like nvl(''' || p_codcomp || '%'',''%'')
               and hcm_util.get_codcomp_level(a.codcomp, 1)    in ( select codcompy
                                                                      from tcompny
                                                                     where (compgrp = nvl(''' || p_comgrp || ''',compgrp)
                                                                        or (compgrp is null and ''' || p_comgrp || ''' is null  ) )
                                                                  )
               and a.typpayroll = nvl(''' || p_typpayroll || ''',a.typpayroll)
               and a.flgtran    = decode(''' || p_flgtransfer || ''',''A'',a.flgtran,''' || p_flgtransfer || ''')
               and a.codalw     not in (''AWARD'',''RET_AWARD'')
               and b.codpay     in (' || v_stmt_codinc_cond || ')
        group by a.codcomp,a.codempid,b.dtework
        order by a.codcomp,a.codempid,b.dtework';
    end if;


    for i in 1..40 loop
      v_amtinc_arr(i) := 0;
      v_timinc_arr(i) := 0;
    end loop;

    curid  := dbms_sql.open_cursor;
    dbms_sql.parse(curid, v_stmt, dbms_sql.native);
    dbms_sql.describe_columns(curid, colcnt, desctab);
    -- Define columns:
    for i in 1 .. colcnt loop
      if desctab(i).col_type = 2 then
        dbms_sql.define_column(curid, i, numvar);
      elsif desctab(i).col_type = 12 then
        dbms_sql.define_column(curid, i, datevar);
      else
        dbms_sql.define_column(curid, i, namevar, 4000);
      end if;
    end loop;

    -- Fetch rows with DBMS_SQL package:
    v_dummy := dbms_sql.execute(curid);
    if v_rcnt_inc > 0 then
    while dbms_sql.fetch_rows(curid) > 0 loop
      v_rcnt      := 0;
      v_timrcnt   := 0;
      obj_data    := json_object_t();
      for i in 1 .. colcnt loop
        if (desctab(i).col_name = upper('codempid')) then
          dbms_sql.column_value(curid, 2, v_codempid);
          -- v_flgpass := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        elsif (desctab(i).col_name = upper('codcomp')) then
          dbms_sql.column_value(curid, i, r1_codcomp);
        elsif (desctab(i).col_name = upper('dtework')) then
          dbms_sql.column_value(curid, i, v_dtework);
        elsif (desctab(i).col_name like upper('amtinc%')) then
          v_rcnt := v_rcnt + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_rcnt <= v_rcnt_inc then
                v_amtinc_arr(v_rcnt) := to_char(numvar);
          end if;
        elsif (desctab(i).col_name like upper('timinc%')) then
          v_timrcnt := v_timrcnt + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_timrcnt <= v_rcnt_inc then
            v_timinc_arr(v_timrcnt) := numvar;
          end if;
        end if;
      end loop;

      if v_codempid_tmp <> v_codempid then
         v_flgpass := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      end if;

      v_codempid_tmp :=  v_codempid ;
      v_numseq := v_numseq + 1;
      if v_flgpass then
          v_flg3007 := true;
          v_exist := true;
           v_count := v_count+1;
          select
           sum(decode(b.rteotpay,1,nvl(stddec(b.amtottot,v_codempid, v_chken),0),0)) amtot10,
           sum(decode(b.rteotpay,1,b.qtyminot,0)) timot10,
           sum(decode(b.rteotpay,1.5,nvl(stddec(b.amtottot,v_codempid, v_chken),0),0)) amtot15,
           sum(decode(b.rteotpay,1.5,b.qtyminot,0)) timot15,
           sum(decode(b.rteotpay,2,nvl(stddec(b.amtottot,v_codempid, v_chken),0),0)) amtot20,
           sum(decode(b.rteotpay,2,b.qtyminot,0)) timot20,
           sum(decode(b.rteotpay,3,nvl(stddec(b.amtottot,v_codempid, v_chken),0),0)) amtot30,
           sum(decode(b.rteotpay,3,b.qtyminot,0)) timot30,
           sum(decode(b.rteotpay, 1,0,
                                  1.5,0,
                                  2,0,
                                  3,0,
                                  nvl(stddec(b.amtottot,v_codempid, v_chken),0))) amtototh,
           sum(decode(b.rteotpay, 1,0,
                                  1.5,0,
                                  2,0,
                                  3,0,
                                  b.qtyminot)) timototh
           into v_amtot10, v_timot10,v_amtot15, v_timot15, v_amtot20, v_timot20, v_amtot30, v_timot30, v_amtototh, v_timototh
            from tovrtime a, totpaydt b
           where a.codempid  = b.codempid
             and a.dtework   = b.dtework
             and a.typot     = b.typot
             and a.codempid  = v_codempid
             and a.dteyrepay = p_dteyrepay
             and a.dtemthpay = p_dtemthpay
             and a.numperiod = p_numperiod
             and a.dtework   = decode(p_flgrpttype,'1',a.dtework,to_date(v_dtework,'DD/MM/YYYY'));

          if global_v_zupdsal = 'Y' then
              v_amtot10ch := to_char(nvl(v_amtot10,0));
              v_amtot15ch := to_char(nvl(v_amtot15,0));
              v_amtot20ch := to_char(nvl(v_amtot20,0));
              v_amtot30ch := to_char(nvl(v_amtot30,0));
              v_amtotothch := to_char(nvl(v_amtototh,0));
          else
              v_amtot10ch := '';
              v_amtot15ch := '';
              v_amtot20ch := '';
              v_amtot30ch := '';
              v_amtotothch := '';
          end if;

          obj_data.put('coderror', 200);
          obj_data.put('response',' ');
          obj_data.put('image',get_emp_img(v_codempid));
          obj_data.put('codcomp',nvl(r1_codcomp, ' '));
          obj_data.put('numseq',nvl(to_char(v_numseq), ' '));
          obj_data.put('codempid',nvl(v_codempid, ' '));
          obj_data.put('desc_codempid',nvl(get_temploy_name(v_codempid,global_v_lang), ' '));
          obj_data.put('dtework',v_dtework);
/*
          for i in 1 .. v_timrcnt loop
              obj_data.put('ti'||to_char(i),v_timinc_arr(i));
              obj_data.put('ai'||to_char(i),v_amtinc_arr(i));
          end loop;

          obj_data.put('tot10',to_char(nvl(v_timot10,0)));
          obj_data.put('tot15',to_char(nvl(v_timot15,0)));
          obj_data.put('tot20',to_char(nvl(v_timot20,0)));
          obj_data.put('tot30',to_char(nvl(v_timot30,0)));
          obj_data.put('tototh',to_char(nvl(v_timototh,0)));
          obj_data.put('aot10',v_amtot10ch);
          obj_data.put('aot15',v_amtot15ch);
          obj_data.put('aot20',v_amtot20ch);
          obj_data.put('aot30',v_amtot30ch);
          obj_data.put('aototh',v_amtotothch);
 */
          for i in 1 .. v_timrcnt loop
              obj_data.put('ti'||to_char(i),v_timinc_arr(i));
              if global_v_zupdsal = 'Y' then
                 obj_data.put('ai'||to_char(i),to_char(v_amtinc_arr(i),'fm9,999,999,990.00'));
              else
                 obj_data.put('ai'||to_char(i),'');
              end if;
          end loop;
/*
          obj_data.put('tot10',to_char(nvl(v_timot10,0),'fm9,999,999,990.00'));
          obj_data.put('tot15',to_char(nvl(v_timot15,0),'fm9,999,999,990.00'));
          obj_data.put('tot20',to_char(nvl(v_timot20,0),'fm9,999,999,990.00'));
          obj_data.put('tot30',to_char(nvl(v_timot30,0),'fm9,999,999,990.00'));
          obj_data.put('tototh',to_char(nvl(v_timototh,0),'fm9,999,999,990.00'));
          obj_data.put('aot10',to_char(v_amtot10ch,'fm9,999,999,990.00'));
          obj_data.put('aot15',to_char(v_amtot15ch,'fm9,999,999,990.00'));
          obj_data.put('aot20',to_char(v_amtot20ch,'fm9,999,999,990.00'));
          obj_data.put('aot30',to_char(v_amtot30ch,'fm9,999,999,990.00'));
          obj_data.put('aototh',to_char(v_amtotothch,'fm9,999,999,990.00'));
*/

          obj_data.put('tot10',nvl(v_timot10,0));
          obj_data.put('tot15',nvl(v_timot15,0));
          obj_data.put('tot20',nvl(v_timot20,0));
          obj_data.put('tot30',nvl(v_timot30,0));
          obj_data.put('tototh',nvl(v_timototh,0));
          obj_data.put('aot10',v_amtot10ch);
          obj_data.put('aot15',v_amtot15ch);
          obj_data.put('aot20',v_amtot20ch);
          obj_data.put('aot30',v_amtot30ch);
          obj_data.put('aototh',v_amtotothch);

          obj_row.put(to_char(v_row), obj_data);
          v_row        := v_row + 1;
      end if;
    end loop;
    dbms_sql.close_cursor(curid);
    --
    end if;
/*
    if not v_exist then
        if p_flgrpttype = '1' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM');
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM2');
        end if;
    elsif not v_flg3007 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'TPAYSUM');
    end if;
*/
   if v_numseq =  0  then
        if p_flgrpttype = '1' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM');
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM2');
        end if;
    elsif not v_flg3007 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;

    if param_msg_error is not null then
       json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

end HRAL76X;

/

--------------------------------------------------------
--  DDL for Package Body HRAL76X1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL76X1" is
-- last update: 08/05/2019 16:15
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
		   and codcomp like nvl(p_codcomp,'%')
		   and codcomp   in (select codcomp
		                       from tcenter
		                      where compgrp = nvl(p_comgrp,compgrp)
                              or (compgrp is null and p_comgrp is null))
		   and typpayroll = nvl(p_typpayroll,typpayroll)
		   and flgtran    = decode(p_flgtransfer,'A',flgtran)
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

    cursor c_tinexinf_codinc is
      select codpay, decode(global_v_lang, '101', descpaye
                                          , '102', descpayt
                                          , '103', descpay3
                                          , '104', descpay4
                                          , '105', descpay5
                                          , '') descpay
        from tinexinf
       where typpay in (1, 2, 3, 4, 5, 6);

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
    v_codinc            varchar2(4 char);
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
        v_rcnt          := i + 1;
        v_codinc        := hcm_util.get_string_t(p_codinc, to_char(i));
        begin
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
      end loop;
      delete from tinitregd
       where codapp = p_codapp
         and codrep = nvl(p_codrep, 'TEMP')
         and numseq > v_rcnt;

      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    end if;

    json_str_output   := get_response_message(null,param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end save_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value (json_str_input);
    gen_detail(json_str_output);
   exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;


  procedure gen_detail1 (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number;
    v_status           varchar2(100 char);
    cursor cl is
        select      object_type, object_name, status
        from        user_objects
        where       status = 'INVALID'
        and         object_type in ('TRIGGER','PACKAGE','PACKAGE BODY','PROCEDURE','VIEW','FUNCTION')
        and object_name like 'HRAL%'
        order by    object_type, object_name;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;

    for r1 in cl loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('objectname', r1.object_name);
      obj_data.put('objecttype', r1.object_type);
      obj_data.put('status', r1.status);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  END gen_detail1;

  procedure gen_detail (json_str_output out clob) AS
    v_exist       boolean := false;
    v_secur       boolean := false;
    v_flgsecu     boolean := false;
    v_flgpass     boolean := false;
    v_flg3007     boolean := false;
    v_codempid    varchar2(30 char);
    v_numseq      number  := 0;

    r1_numlvl     number;
    r1_codcomp    tcenter.codcomp%type;
    v_typpayroll  varchar2(10 char);
    v_num         number := 0;

    obj_row       json_object_t;
    obj_data      json_object_t;

    v_stmt        clob;
    v_stmt_inc    clob;
    v_stmt_timinc clob;

    v_concat      varchar2(2 char);

    curid         number;
    desctab       dbms_sql.desc_tab;
    colcnt        number;
    namevar       varchar2(4000 char);
    numvar        number;
    datevar       date;
    v_dtework     varchar2(10 char);
    v_dummy       integer;
    v_rcnt        number := 0;
    v_timrcnt     number := 0;
    v_rcnt_inc    number := 0;
    v_rcnt_timinc    number := 0;
    v_ccnt_inc    number := 0;
    v_ccnt_timinc    number := 0;
    type amtinc_arr is table of  varchar2(400 char) index by binary_integer;
      v_amtinc_arr  amtinc_arr;
      v_timinc_arr  amtinc_arr;

    cursor c_tinitregd is
      select a.numseq, a.codinc, a.codded
        from tinitregd a, tinitregh b
       where a.codrep  = b.codrep
         and a.codapp  = p_codapp
         and a.codapp  = b.codapp
         and a.codrep  = nvl(p_codrep, 'TEMP')
         and b.typcode = p_typcode
       order by a.numseq;

  begin
    obj_row         := json_object_t();
    v_rcnt          := 0;
    if p_flgrpttype = '1' then
        v_stmt := 'select codcomp,codempid,TO_CHAR(sysdate, ''DD/MM/YYYY'') as dtework';
        v_concat := ',';
        for r0 in c_tinitregd loop
          if r0.codinc is not null then
            -- Amount
            v_rcnt_inc := v_rcnt_inc + 1;
            v_stmt_inc := v_stmt_inc || v_concat || '
            sum(decode(codpay,''' || r0.codinc || ''',nvl(stddec(amtpay,codempid, ''' || v_chken || ''' ),0),0)) amtinc' || to_char(r0.numseq);
            --Time
            v_rcnt_timinc := v_rcnt_timinc + 1;
            v_stmt_timinc := v_stmt_timinc || v_concat || '
            sum(decode(codpay,''' || r0.codinc || ''',qtymin,0)) timinc' || to_char(r0.numseq);

          end if;
        end loop;

        v_stmt := v_stmt || v_stmt_inc || v_stmt_timinc;
        v_stmt := v_stmt || '
              from tpaysum
             where numperiod  = nvl(''' || to_char(p_numperiod) || ''', numperiod)
               and dtemthpay  = nvl(''' || to_char(p_dtemthpay) || ''', dtemthpay)
               and dteyrepay  = ''' || to_char(p_dteyrepay) || '''
               and codempid   = nvl(''' || p_codempid || ''',codempid)
               and codcomp like nvl(''' || p_codcomp || ''',''%'')
               and codcomp   in (select codcomp
                                   from tcenter
                                  where compgrp = nvl(''' || p_comgrp || ''',compgrp)
                                  or (compgrp is null and ''' || p_comgrp || ''' is null   )
                                  )
               and typpayroll = nvl(''' || p_typpayroll || ''',typpayroll)
               and flgtran    = decode(''' || p_flgtransfer || ''',''A'',flgtran,''' || p_flgtransfer || ''')
        group by codcomp,codempid
        order by codcomp,codempid';
    elsif p_flgrpttype = '2' then
        v_stmt := 'select a.codcomp,a.codempid,TO_CHAR(b.dtework, ''DD/MM/YYYY'') as dtework';
        v_concat := ',';
        for r0 in c_tinitregd loop
          if r0.codinc is not null then
            -- Amount
            v_rcnt_inc := v_rcnt_inc + 1;
            v_stmt_inc := v_stmt_inc || v_concat || '
            sum(decode(b.codpay,''' || r0.codinc || ''',nvl(stddec(b.amtpay,a.codempid,''' || v_chken || '''),0),0)) amtinc' || to_char(r0.numseq);
            --Time
            v_rcnt_timinc := v_rcnt_timinc + 1;
            v_stmt_timinc := v_stmt_timinc || v_concat || '
            sum(decode(b.codpay,''' || r0.codinc || ''',b.qtymin,0)) timinc' || to_char(r0.numseq);
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
               and a.numperiod  = ''' || to_char(p_numperiod) || '''
               and a.dtemthpay  = ''' || to_char(p_dtemthpay) || '''
               and a.dteyrepay  = ''' || to_char(p_dteyrepay) || '''
               and a.codempid   = nvl(''' || p_codempid || ''',a.codempid)
               and codcomp      like nvl(''' || p_codcomp || ''',''%'')
               and a.codcomp    in (select codcomp
                                      from tcenter
                                     where compgrp = nvl(''' || p_comgrp || ''',compgrp)
                                        or (compgrp is null and ''' || p_comgrp || ''' is null   )
                                  )
               and a.typpayroll = nvl(''' || p_typpayroll || ''',a.typpayroll)
               and a.flgtran    = decode(''' || p_flgtransfer || ''',''A'',a.flgtran)
               and a.codalw     not in (''AWARD'',''RET_AWARD'')
        group by a.codcomp,a.codempid,b.dtework
        order by a.codcomp,a.codempid,b.dtework';
    end if;

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
    while dbms_sql.fetch_rows(curid) > 0 loop
      v_ccnt_inc    := 0;
      v_ccnt_timinc := 0;
      v_timrcnt     := 0;

      for i in 1 .. colcnt loop
        if (desctab(i).col_name = upper('codempid')) then
          dbms_sql.column_value(curid, 2, v_codempid);
          v_flgpass := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        elsif (desctab(i).col_name = upper('codcomp')) then
          dbms_sql.column_value(curid, i, r1_codcomp);
        elsif (desctab(i).col_name = upper('dtework')) then
          dbms_sql.column_value(curid, i, v_dtework);
        elsif (desctab(i).col_name like upper('amtinc%')) then
          v_ccnt_inc := v_ccnt_inc + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_ccnt_inc <= v_rcnt_inc then
            if global_v_zupdsal = 'Y' then
                v_amtinc_arr(v_ccnt_inc) := to_char(numvar,'fm999,999,990.00');
            else
                v_amtinc_arr(v_ccnt_inc) := '';
            end if;
          end if;
        elsif (desctab(i).col_name like upper('timinc%')) then
          v_ccnt_timinc := v_ccnt_timinc + 1;
          dbms_sql.column_value(curid, i, numvar);
          if v_ccnt_timinc <= v_rcnt_inc then
            v_timinc_arr(v_ccnt_timinc) := numvar;
          end if;
        end if;
      end loop;

      v_exist := true;
      v_flgsecu := true;-- secur_main.secur1(r1_codcomp,r1_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,global_v_zupdsal);
      if v_flgsecu then
        v_secur := true;

        v_numseq := v_numseq + 1;

        if v_flgpass then
            v_flg3007   := true;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(v_codempid, ' '));
            obj_data.put('codcomp', nvl(r1_codcomp, ' '));
            obj_data.put('numseq', nvl(to_char(v_numseq), ' '));
            obj_data.put('codempid', nvl(v_codempid, ' '));
            obj_data.put('desc_codempid', nvl(get_temploy_name(v_codempid,global_v_lang), ' '));
            obj_data.put('dtework', v_dtework);
            obj_data.put('amtinc1', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(1),60),0),2,'0'));
            obj_data.put('amtinc2', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(2),60),0),2,'0'));
            obj_data.put('amtinc3', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(3),60),0),2,'0'));
            obj_data.put('amtinc4', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(4),60),0),2,'0'));
            obj_data.put('amtinc5', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(5),60),0),2,'0'));
            obj_data.put('amtinc6', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(6),60),0),2,'0'));
            obj_data.put('amtinc7', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(7),60),0),2,'0'));
            obj_data.put('amtinc8', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(8),60),0),2,'0'));
            obj_data.put('amtinc9', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(9),60),0),2,'0'));
            obj_data.put('amtinc10', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(10),60),0),2,'0'));
            obj_data.put('amtinc11', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(11),60),0),2,'0'));
            obj_data.put('amtinc12', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(12),60),0),2,'0'));
            obj_data.put('amtinc13', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(13),60),0),2,'0'));
            obj_data.put('amtinc14', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(14),60),0),2,'0'));
            obj_data.put('amtinc15', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(15),60),0),2,'0'));
            obj_data.put('amtinc16', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(16),60),0),2,'0'));
            obj_data.put('amtinc17', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(17),60),0),2,'0'));
            obj_data.put('amtinc18', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(18),60),0),2,'0'));
            obj_data.put('amtinc19', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(19),60),0),2,'0'));
            obj_data.put('amtinc20', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(20),60),0),2,'0'));
            obj_data.put('amtinc21', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(21),60),0),2,'0'));
            obj_data.put('amtinc22', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(22),60),0),2,'0'));
            obj_data.put('amtinc23', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(23),60),0),2,'0'));
            obj_data.put('amtinc24', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(24),60),0),2,'0'));
            obj_data.put('amtinc25', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(25),60),0),2,'0'));
            obj_data.put('amtinc26', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(26),60),0),2,'0'));
            obj_data.put('amtinc27', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(27),60),0),2,'0'));
            obj_data.put('amtinc28', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(28),60),0),2,'0'));
            obj_data.put('amtinc29', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(29),60),0),2,'0'));
            obj_data.put('amtinc30', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(30),60),0),2,'0'));
            obj_data.put('amtinc31', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(31),60),0),2,'0'));
            obj_data.put('amtinc32', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(32),60),0),2,'0'));
            obj_data.put('amtinc33', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(33),60),0),2,'0'));
            obj_data.put('amtinc34', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(34),60),0),2,'0'));
            obj_data.put('amtinc35', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(35),60),0),2,'0'));
            obj_data.put('amtinc36', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(36),60),0),2,'0'));
            obj_data.put('amtinc37', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(37),60),0),2,'0'));
            obj_data.put('amtinc38', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(38),60),0),2,'0'));
            obj_data.put('amtinc39', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(39),60),0),2,'0'));
            obj_data.put('amtinc40', trunc(v_timinc_arr(1) /60,0)||':'||lpad(round(mod(v_timinc_arr(40),60),0),2,'0'));
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt      := v_rcnt + 1;

           /* obj_data    := json();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(v_codempid, ' '));
            obj_data.put('codcomp', nvl(r1_codcomp, ' '));
            obj_data.put('numseq', nvl(to_char(v_numseq), ' '));
            obj_data.put('codempid', nvl(v_codempid, ' '));
            obj_data.put('desc_codempid', nvl(get_temploy_name(v_codempid,global_v_lang), ' '));
            obj_data.put('dtework', v_dtework);
            obj_data.put('amtinc1', v_amtinc_arr(1));
            obj_data.put('amtinc2', v_amtinc_arr(2));
            obj_data.put('amtinc3', v_amtinc_arr(3));
            obj_data.put('amtinc3', v_amtinc_arr(4));
            obj_data.put('amtinc5', v_amtinc_arr(5));
            obj_data.put('amtinc6', v_amtinc_arr(6));
            obj_data.put('amtinc7', v_amtinc_arr(7));
            obj_data.put('amtinc8', v_amtinc_arr(8));
            obj_data.put('amtinc9', v_amtinc_arr(9));
            obj_data.put('amtinc10', v_amtinc_arr(10));
            obj_data.put('amtinc11', v_amtinc_arr(11));
            obj_data.put('amtinc12', v_amtinc_arr(12));
            obj_data.put('amtinc13', v_amtinc_arr(13));
            obj_data.put('amtinc14', v_amtinc_arr(14));
            obj_data.put('amtinc15', v_amtinc_arr(15));
            obj_data.put('amtinc16', v_amtinc_arr(16));
            obj_data.put('amtinc17', v_amtinc_arr(17));
            obj_data.put('amtinc18', v_amtinc_arr(18));
            obj_data.put('amtinc19', v_amtinc_arr(19));
            obj_data.put('amtinc20', v_amtinc_arr(20));
            obj_data.put('amtinc21', v_amtinc_arr(21));
            obj_data.put('amtinc22', v_amtinc_arr(22));
            obj_data.put('amtinc23', v_amtinc_arr(23));
            obj_data.put('amtinc23', v_amtinc_arr(24));
            obj_data.put('amtinc25', v_amtinc_arr(25));
            obj_data.put('amtinc26', v_amtinc_arr(26));
            obj_data.put('amtinc27', v_amtinc_arr(27));
            obj_data.put('amtinc28', v_amtinc_arr(28));
            obj_data.put('amtinc29', v_amtinc_arr(29));
            obj_data.put('amtinc30', v_amtinc_arr(30));
            obj_data.put('amtinc31', v_amtinc_arr(31));
            obj_data.put('amtinc32', v_amtinc_arr(32));
            obj_data.put('amtinc33', v_amtinc_arr(33));
            obj_data.put('amtinc34', v_amtinc_arr(34));
            obj_data.put('amtinc35', v_amtinc_arr(35));
            obj_data.put('amtinc36', v_amtinc_arr(36));
            obj_data.put('amtinc37', v_amtinc_arr(37));
            obj_data.put('amtinc38', v_amtinc_arr(38));
            obj_data.put('amtinc39', v_amtinc_arr(39));
            obj_data.put('amtinc40', v_amtinc_arr(40));
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt      := v_rcnt + 1;   */

        end if;

      end if; -- v_flgsecu
    end loop;
   -- dbms_lob.createtemporary(json_str_output, true);
   -- obj_row.to_clob(json_str_output);
    dbms_sql.close_cursor(curid);
    --
 /*   if not v_exist then
        if p_flgrpttype = '1' then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM');
        else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPAYSUM2');
        end if;
    elsif not v_flg3007 then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'TPAYSUM');
    end if;*/

--    if param_msg_error is not null then
--      json_str_output := json(get_response_message(null,param_msg_error,global_v_lang));
--    end if;
--
v_rcnt := 0;
    for r1 in c_tinitregd loop
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('objectname', '555');
      obj_data.put('objecttype','5555');
      obj_data.put('status', '5');

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt               := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;

  end gen_detail;
end HRAL76X1;

/

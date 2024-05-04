--------------------------------------------------------
--  DDL for Package Body HRAL4KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL4KE" as
  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    -- index head
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codempid_index    := hcm_util.get_string_t(json_obj,'p_codempid_index');

    if p_codcomp is not null then
      begin
        select count(distinct(rteotpay))
          into p_rateotcount
          from totratep2
         where codcompy = hcm_util.get_codcompy(p_codcomp);
      end;
    else
      begin
        select count(distinct(rteotpay))
          into p_rateotcount
          from totratep2
         where codcompy = (select hcm_util.get_codcompy(codcomp) from temploy1
                           where codempid = p_codempid_index);
      end;
    end if;

    p_date              := to_date(hcm_util.get_string_t(json_obj,'p_date'),'dd/mm/yyyy');
    p_dtework           := to_date(hcm_util.get_string_t(json_obj,'p_dtework'),'dd/mm/yyyy');
    p_dtein             := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'p_dtetimin' ));
    p_dteout            := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'p_dtetimout'));
    p_dtestr            := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'p_dtetimstr'));
    p_dteend            := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'p_dtetimend'));
    p_timin             := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'p_dtetimin' ));
    p_timout            := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'p_dtetimout'));
    p_timstrt           := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'p_dtetimstr'));
    p_timend            := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'p_dtetimend'));

    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');
    p_codshift          := hcm_util.get_string_t(json_obj,'p_codshift');
    p_typot             := hcm_util.get_string_t(json_obj,'p_typot');
    p_qtyotmin          := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtyminot'));

    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_daywork(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_daywork;
    if param_msg_error is null then
        gen_daywork(json_str_output);
    end if;
    if param_msg_error is null then
      commit;
    else
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_daywork as
    v_token tcodwork.codcodec%type;
  begin
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang,'p_dtestr > p_dteend');
        return;
    end if;

    if p_codempid is not null then
        p_codcomp := '';
        p_codcalen := '';
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codcalen is not null then
        begin
            select codcodec
              into v_token
              from tcodwork
             where codcodec = p_codcalen;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
            return;
        end;
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_daywork;

  procedure gen_daywork(json_str_output out clob) as
    json_obj        json_object_t;
    json_row        json_object_t;
    v_secur         boolean;
    v_dtemovemt		  date;
    v_codcomp       temploy1.codcomp%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_codcompy      temploy1.codcomp%type;
    v_condot        tcontrot.condot%type;
    v_condextr      tcontrot.condextr%type;
    v_flgot         boolean;
    v_meal          boolean;
    v_cond          tcontrot.condot%type;
    v_stmt          varchar2(4000 char);
    v_chken         varchar2(10 char) := hcm_secur.get_v_chken;
    v_amtincom1     number;
    v_codpos        temploy1.codpos%type;
    v_numlvl        number;
    v_typemp        temploy1.typemp%type;
    v_codempmt      temploy1.codempmt%type;
    v_codjob			  temploy1.codjob%type;
    v_num           number;
    v_st_codempid   temploy1.codempid%type := null;
    v_typpayroll	  temploy1.typpayroll%type;
    v_codbrlc	  	  temploy1.codbrlc%type;
    v_codcalen		  temploy1.codcalen%type;
    v_codgrpgl		  temploy1.codgrpgl%type;
    v_st_date       date := null;
    v_dtework       date := null;
    v_permission    varchar2(1 char) := 'N';
    v_exist         varchar2(1 char) := 'N';

    type qtyminot is table of number index by binary_integer;
		v_qtyminot	qtyminot;
    v_amtincom	qtyminot;
    cursor c_tattence is
        select  a.codempid,a.dtework
          from  tattence a
         where  ((p_codempid is not null and a.codempid = p_codempid)
            or   (p_codempid is null     and a.codcomp  like p_codcomp || '%'
                                         and a.codcalen = nvl(p_codcalen,a.codcalen)))
           and  a.dtework = v_dtework
--           and  a.dtework between p_dtestr and p_dteend
      group by  a.codempid,a.dtework
      order by  a.codempid;

    cursor c_dtework is
        select  t1.dtework
          from  tattence t1,ttemprpt t2
         where  t1.codempid = t2.item1
           and  t2.codapp   = p_codapp
           and  t2.codempid = global_v_coduser
           and  t1.dtework between p_dtestr and p_dteend
      group by  t1.dtework
      order by  t1.dtework;
  begin
    json_obj := json_object_t();
    json_row := json_object_t();
    v_num    := 0;
    begin
      delete  ttemprpt
      where   codempid = global_v_coduser
        and   codapp   = p_codapp;
    exception when others then
      null;
    end;
    for i in 1..10 loop
			v_amtincom(i) := null;
		end loop;
    begin
        select  distinct a.dtework into v_dtework
          from  tattence a
         where  ((p_codempid is not null and a.codempid = p_codempid)
            or   (p_codempid is null     and a.codcomp  like p_codcomp || '%'
                                         and a.codcalen = nvl(p_codcalen,a.codcalen)))
           and  a.dtework between p_dtestr and p_dteend
           and  rownum = 1
      group by  a.dtework;
    exception when no_data_found then
      v_dtework := null;
    end;
    for r1 in c_tattence loop
        v_secur := secur_main.secur2(r1.codempid,global_v_coduser,
                                     global_v_zminlvl,global_v_zwrklvl,
                                     v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        v_exist := 'Y';
        if v_secur then
          v_permission := 'Y';
          begin
              std_al.get_movemt2(r1.codempid,r1.dtework,'C','U',
                         v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                         v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                         v_amtincom1,v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
              begin
                select condot,condextr
                  into v_condot,v_condextr
                  from tcontrot
                 where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                   and dteeffec = (select max(dteeffec)
                                     from tcontrot
                                    where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                      and dteeffec < sysdate)
                   and rownum <= 1
                order by  dteeffec desc;
              exception when no_data_found then null;
              end;
              --
              v_flgot := true;
              if v_condot is not null then
                  v_cond := v_condot;
                  v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
                  v_cond := replace(v_cond,'V_HRAL92M1.CODJOB',''''||v_codjob||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.TYPPAYROLL',''''||v_typpayroll||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.CODBRLC',''''||v_codbrlc||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.CODCALEN',''''||v_codcalen||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.CODGRPGL',''''||v_codgrpgl||'''');
                  v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);
                  v_stmt := 'select count(*) from dual where ' || v_cond;
                  v_flgot := execute_stmt(v_stmt);
              end if;
              v_meal := true;
              if v_condextr is not null then
                  v_cond := v_condextr;
                  v_cond := replace(v_cond,'V_HRAL92M2.CODCOMP',''''||v_codcomp||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.CODPOS',''''||v_codpos||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.NUMLVL',v_numlvl);
                  v_cond := replace(v_cond,'V_HRAL92M2.CODJOB',''''||v_codjob||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.CODEMPMT',''''||v_codempmt||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.TYPEMP',''''||v_typemp||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.TYPPAYROLL',''''||v_typpayroll||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.CODBRLC',''''||v_codbrlc||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.CODCALEN',''''||v_codcalen||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.JOBGRADE',''''||v_jobgrade||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.CODGRPGL',''''||v_codgrpgl||'''');
                  v_cond := replace(v_cond,'V_HRAL92M2.AMTINCOM1',v_amtincom1);
                  v_stmt := 'select count(*) from dual where ' || v_cond;
                  v_meal := execute_stmt(v_stmt);
              end if;
              if v_flgot or v_meal then
                  insert into ttemprpt(codempid,codapp,numseq,item1)
                  values(global_v_coduser,p_codapp,v_num,r1.codempid);
                  json_row.put(to_char(v_num),r1.codempid);
                  if v_st_codempid is null then
                      v_st_codempid := r1.codempid;
                  end if;
                  v_num := v_num + 1;
              end if;
          exception when others then
            null;
          end;
        end if;
--        if v_num = 1 then
--          exit;
--        end if;
    end loop;
    v_num := 0;
    json_row := json_object_t();
    for r2 in c_dtework loop
      json_row.put(to_char(v_num),to_char(r2.dtework,'dd/mm/yyyy'));
      if v_st_date is null then
        v_st_date := r2.dtework;
      end if;
      v_num := v_num + 1;
    end loop;
    json_obj.put('dtework', json_row);
    json_obj.put('coderror','200');
    if v_exist = 'N' then
      param_msg_error     := get_error_msg_php('HR2055', global_v_lang,'tattence');

      return;
    elsif v_permission = 'N' then
      param_msg_error     := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    if json_row.get_size > 0 then
      json_str_output := json_obj.to_clob;
    else
      param_msg_error     := get_error_msg_php('HR2055', global_v_lang,'tattence');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_daywork;

  procedure check_employee as
    v_token varchar2(10 char);
  begin
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang,'p_dtestr > p_dteend');
        return;
    end if;
    if p_codempid is not null then
        p_codcomp := '';
        p_codcalen := '';
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      begin
        select codempid
          into p_codempid
          from temploy3
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy3');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codcalen is not null then
        begin
            select codcodec
              into v_token
              from tcodwork
             where codcodec = p_codcalen;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
            return;
        end;
        if param_msg_error is not null then
            return;
        end if;
    end if;
  end check_employee;

  procedure get_employee(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_employee;
    if param_msg_error is null then
        gen_employee(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_employee;

  procedure gen_employee(json_str_output out clob) as
    json_obj        json_object_t;
    json_row        json_object_t;
    v_secur         boolean;
    v_codcomp       temploy1.codcomp%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_codcompy      temploy1.codcomp%type;
    v_condot        tcontrot.condot%type;
    v_condextr      tcontrot.condextr%type;
    v_flgot         boolean;
    v_meal          boolean;
    v_cond          tcontrot.condot%type;
    v_stmt          varchar2(4000 char);
    v_chken         varchar2(10 char) := hcm_secur.get_v_chken;
    v_amtincom1     number;
    v_num           number;
    v_codpos        temploy1.codpos%type;
    v_numlvl        number;
    v_typemp        temploy1.typemp%type;
    v_codempmt      temploy1.codempmt%type;
    v_codjob			  temploy1.codjob%type;
    v_st_codempid   temploy1.codempid%type := '';
    v_typpayroll	  temploy1.typpayroll%type;
    v_codbrlc	  	  temploy1.codbrlc%type;
    v_codcalen		  temploy1.codcalen%type;
    v_codgrpgl		  temploy1.codgrpgl%type;

    v_st_date       date := null;
    v_permission    varchar2(1 char) := 'N';
    v_exist         varchar2(1 char) := 'N';
    type qtyminot is table of number index by binary_integer;
		v_qtyminot	qtyminot;
    v_amtincom	qtyminot;
    cursor c_tattence is
        select  a.codempid,a.dtework
          from  tattence a
         where  ((p_codempid is not null and a.codempid = p_codempid)
            or   (p_codempid is null     and a.codcomp  like p_codcomp || '%'
                                         and a.codcalen = nvl(p_codcalen,a.codcalen)))
           and  a.dtework between p_dtestr and p_dteend
      group by  a.codempid,a.dtework
      order by  a.codempid;

    cursor c_dtework is
        select  t1.dtework
          from  tattence t1,ttemprpt t2
         where  t1.codempid = t2.item1
           and  t2.codapp   = p_codapp
           and  t2.codempid = global_v_coduser
           and  t1.dtework between p_dtestr and p_dteend
      group by  t1.dtework
      order by  t1.dtework;
  begin
    json_obj := json_object_t();
    json_row := json_object_t();
    v_num    := 0;
    begin
      delete ttemprpt
      where codempid = global_v_coduser
        and codapp   = p_codapp;
    exception when others then
      null;
    end;
    for i in 1..10 loop
			v_amtincom(i) := null;
		end loop;
    for r1 in c_tattence loop
        v_secur := secur_main.secur2(r1.codempid,global_v_coduser,
                                         global_v_zminlvl,global_v_zwrklvl,
                                         v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        v_exist := 'Y';
        if v_secur then
            v_permission := 'Y';
            begin
              std_al.get_movemt2(r1.codempid,r1.dtework,'C','U',
                                 v_codcomp,v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                                 v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                                 v_amtincom1,v_amtincom(2),v_amtincom(3),v_amtincom(4),v_amtincom(5),v_amtincom(6),v_amtincom(7),v_amtincom(8),v_amtincom(9),v_amtincom(10));
              begin
                select  condot, condextr
                  into  v_condot, v_condextr
                  from  tcontrot
                 where  codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                   and  dteeffec = (select max(dteeffec)
                                      from tcontrot
                                     where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                                       and dteeffec < sysdate);
              exception when no_data_found then
                null;
              end;
                v_flgot := true;
                if v_condot is not null then
                    v_cond := v_condot;
                    v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'V_HRAL92M1.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.CODGRPGL',''''||v_codgrpgl||'''');
                    v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);
                    v_stmt := 'select count(*) from dual where ' || v_cond;
                    v_flgot := execute_stmt(v_stmt);
                end if;
                v_meal := true;
                if v_condextr is not null then
                    v_cond := v_condextr;
                    v_cond := replace(v_cond,'V_HRAL92M2.CODCOMP',''''||v_codcomp||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.CODPOS',''''||v_codpos||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.NUMLVL',v_numlvl);
                    v_cond := replace(v_cond,'V_HRAL92M2.CODJOB',''''||v_codjob||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.CODEMPMT',''''||v_codempmt||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.TYPEMP',''''||v_typemp||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.TYPPAYROLL',''''||v_typpayroll||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.CODBRLC',''''||v_codbrlc||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.CODCALEN',''''||v_codcalen||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.JOBGRADE',''''||v_jobgrade||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.CODGRPGL',''''||v_codgrpgl||'''');
                    v_cond := replace(v_cond,'V_HRAL92M2.AMTINCOM1',v_amtincom1);
                    v_stmt := 'select count(*) from dual where ' || v_cond;
                    v_meal := execute_stmt(v_stmt);
                end if;
                if v_flgot or v_meal then
                    if v_st_codempid is null or v_st_codempid <> r1.codempid then
                      insert into ttemprpt(codempid, codapp, numseq, item1)
                      values(global_v_coduser, p_codapp, v_num, r1.codempid);
                      json_row.put(to_char(v_num), r1.codempid);
                      v_num := v_num + 1;
                    end if;
                    v_st_codempid := r1.codempid;
--                    if v_st_codempid <> r1.codempid then
--                        v_st_codempid := r1.codempid;
--                    end if;
                end if;
            exception when no_data_found then
              null;
            end;
        end if;
    end loop;
    json_obj.put('codempid', json_row);
    json_obj.put('coderror', '200');
    if v_exist = 'Y' then
      if v_permission = 'N' then
        param_msg_error     := get_error_msg_php('HR3007', global_v_lang);
        return;
      else
        json_str_output := json_obj.to_clob;
      end if;
    else
      param_msg_error     := get_error_msg_php('HR2055', global_v_lang,'tattence');
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_employee;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_index as
  begin
    if p_flg = '1' then
      null;
    elsif p_flg = '2' then
      if p_codempid is not null then
        begin
          select codempid
            into p_codempid
            from temploy1
          where codempid = p_codempid;
        exception when no_data_found then null;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
          return;
        end;
        if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
        end if;
      end if;
      if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2032',global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'p_flg');
      return;
    end if;
  end;

  procedure gen_index(json_str_output out clob) as
  begin
    if p_flg = '1' then
      gen_st_index_by_date(p_date, json_str_output);
    elsif p_flg = '2' then
      gen_st_index_by_codempid(p_codempid, json_str_output);
    end if;
    if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_TimeAttendant(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_TimeAttendant;
    if param_msg_error is null then
      gen_TimeAttendant(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_TimeAttendant;

  procedure check_TimeAttendant as
    v_count number;
  begin
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codempid is not null and p_dtework is not null and p_typot is not null then
      begin
        select  count(*)
          into  v_count
          from  tattence
         where  codempid = p_codempid
           and  dtework  = p_dtework;
      exception when others then
        v_count := 0;
      end;
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tattence');
        return;
      end if;
    end if;
  end check_TimeAttendant;

  procedure gen_TimeAttendant(json_str_output out clob) as
    json_obj      json_object_t := json_object_t();
    json_obj2     json_object_t := json_object_t();
    json_row      json_object_t := json_object_t();
    v_codcompy    tcenter.codcompy%TYPE;
    v_dteeffec    tcontrot.dteeffec%TYPE;
    v_condot      tcontrot.condot%TYPE;
    v_condextr    tcontrot.condextr%TYPE;
    v_a_tovrtime  tovrtime%rowtype;
    v_a_rteotpay  hral85b_batch.a_rteotpay;
    v_a_qtyminot  hral85b_batch.a_qtyminot;
    v_codshift    tattence.codshift%TYPE;
    v_rteotpay    totpaydt.rteotpay%TYPE;
    v_qtyminot    totpaydt.qtyminot%TYPE;
    v_qtyminot1   totpaydt.qtyminot%TYPE := 0;
    v_qtyminot1_5 totpaydt.qtyminot%TYPE := 0;
    v_qtyminot2   totpaydt.qtyminot%TYPE := 0;
    v_qtyminot3   totpaydt.qtyminot%TYPE := 0;
    v_qtyminotx   totpaydt.qtyminot%TYPE := 0;
    v_typwork     tattence.typwork%type;
    v_typot       varchar2(2 char);
    v_ratenum     number;
    v_codempid      tusrprof.codempid%type;
    v_desc_codempid varchar2(150 char);
    v_token       number;
    v_token2      varchar2(100 char);
    v_chken       varchar2(100 char) := hcm_secur.get_v_chken;
    v_dtestr      date;
    v_dteend      date;
    v_timstr      tovrtime.timstrt%type;
    v_timend      tovrtime.timend%type;
    v_qtydedbrk   number;
    v_amtmeal     tovrtime.amtmeal%type;
    v_dteappr     date;
    v_codappr     tovrtime.codappr%type;
    v_qtyminot_1  number;
    v_qtyleave    number;
    v_countpaydt  number;
    v_codrem      tovrtime.codrem%type;
    v_codcompw    tovrtime.codcompw%type;
    v_flgotcal    tovrtime.flgotcal%type;
    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = p_codempid
    order by t1.rteotpay;
  begin
    begin
        select codempid, get_temploy_name(codempid, global_v_lang)
          into v_codempid, v_desc_codempid
          from tusrprof
         where coduser = global_v_coduser;
    exception when others then
      null;
    end;
    begin
      select  hcm_util.get_codcomp_level(codcomp,1)
        into  v_codcompy
        from  temploy1
       where  codempid = p_codempid;
    exception when no_data_found then
      v_codcompy := '';
    end;
    begin
      select  dteeffec,condot,condextr
        into  v_dteeffec,v_condot,v_condextr
        from  tcontrot
       where  codcompy = v_codcompy
         and  dteeffec = (select  max(dteeffec)
                            from  tcontrot
                           where  codcompy = v_codcompy
                             and  dteeffec < sysdate)
         and  rownum <= 1;
    exception when no_data_found then null;
      v_dteeffec := null;
      v_condot   := '';
      v_condextr := '';
    end;
    begin
        select  codshift,typwork
          into  v_codshift,v_typwork
          from  tattence
         where  codempid = p_codempid
           and  dtework  = p_dtework;
    exception when others then
        v_codshift := '';
    end;
    --
    begin
        select  dtestrt,dteend,
                timstrt,timend,
                qtydedbrk,amtmeal,
                dteappr,codappr,
                qtyleave,codrem,
                qtyminot,codcompw,
                flgotcal
          into  v_dtestr,v_dteend,
                v_timstr,v_timend,
                v_qtydedbrk,v_amtmeal,
                v_dteappr,v_codappr,
                v_qtyleave,v_codrem,
                v_qtyminot_1,v_codcompw,
                v_flgotcal
          from  tovrtime
         where  dtework = p_dtework
           and  codempid = p_codempid
           and  typot = 'B';
        hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                  null,p_codempid,p_dtework,'B',p_codshift,
                                  p_dtein ,p_timin,
                                  p_dteout,p_timout,
                                  p_dtestrt,p_timstrt,p_dteend,p_timend,p_qtyminreq,
                                  null,null,null,null,'Y',
                                  v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);

        json_obj.put('typot','B');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'B',global_v_lang));
        json_obj.put('flgappr','A');
        json_obj.put('flgotcal',v_flgotcal);
        json_obj.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
        --
--        json_obj.put('dtestrt',to_char(v_dtestr,'dd/mm/yyyy'));
--        json_obj.put('dteend' ,to_char(v_dteend ,'dd/mm/yyyy'));
--        json_obj.put('timstrt',to_char(to_date(v_timstr,'hh24mi'),'hh24:mi'));
--        json_obj.put('timend' ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
--        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_dtestr,v_timstr));
--        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_dteend,v_timend));

        json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
        json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
        json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
        json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
--        if v_qtydedbrk is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtydedbrk',v_token2);
--        end if;
--        if v_qtyminot_1 is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot_1,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtyminot',v_token2);
--        end if;
        if v_a_tovrtime.qtydedbrk is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtydedbrk',v_token2);
        end if;
        if v_a_tovrtime.qtyminot is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtyminot',v_token2);
        end if;
--        json_obj.put('amtmeal',stddec(v_amtmeal,p_codempid,v_chken));
        json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
        json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
        json_obj.put('codappr',v_codappr);
        json_obj.put('desc_codappr',get_temploy_name(v_codappr,global_v_lang));
        json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_qtyleave));
        json_obj.put('codrem',v_codrem);
        json_obj.put('codcompw',v_codcompw);
        json_obj.put('desc_codcompw',get_tcenter_name(v_codcompw,global_v_lang));
        json_obj.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
        --
        v_typot := 'B';
        v_ratenum := 1;
        v_qtyminotx := 0;
        --
        select count(codempid)
         into v_countpaydt
         from totpaydt
        where codempid = P_codempid
          and dtework  = p_dtework
          and typot    = v_typot;
        --tar1
        if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,p_codempid,hcm_secur.get_v_chken)) > 0 then
          json_obj.put('flgtypot','Y');
        else
          json_obj.put('flgtypot','N');
        end if;

--        for r_rteotpay in c_rteotpay loop
--          begin
--            select  nvl(sum(nvl(qtyminot,0)),0)
--              into  v_qtyminot1
--              from  totpaydt
--             where  dtework = p_dtework
--               and  codempid = p_codempid
--               and  typot = v_typot
--               and  rteotpay = r_rteotpay.rteotpay;
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
--            v_qtyminotx := v_qtyminotx + v_qtyminot1;
--          exception when others then
--            hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
--          end;
--          json_obj.put('rate'||to_char(v_ratenum),v_token2);
--          v_ratenum := v_ratenum + 1;
--        end loop;
--        json_obj.put('numrate' ,to_char(v_ratenum-1));
        for r_rteotpay in c_rteotpay loop
          v_qtyminot1 := 0;
          for i in 1..p_rateotcount loop
            if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
              v_rteotpay := v_a_rteotpay(i);
              v_qtyminot := v_a_qtyminot(i);
              if v_rteotpay = r_rteotpay.rteotpay then
                v_qtyminot1 := v_qtyminot1 + v_qtyminot;
              end if;
            end if;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
          json_obj.put('rate'||to_char(v_ratenum),v_token2);
          v_ratenum := v_ratenum + 1;
        end loop;
        json_obj.put('numrate' ,to_char(v_ratenum-1));
        begin
          select  nvl(sum(nvl(qtyminot,0)),0)
            into  v_qtyminot1
            from  totpaydt
           where  dtework = p_dtework
             and  codempid = p_codempid
             and  typot = v_typot;
          hcm_util.cal_dhm_hm (0,0,v_qtyminot1-v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
        exception when others then
          hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
        end;
        json_obj.put('ratex',v_token2);
    exception when others then
        hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                  null,p_codempid,p_dtework,'B',p_codshift,
                                  p_dtein ,p_timin,
                                  p_dteout,p_timout,
                                  p_dtestrt,p_timstrt,p_dteend,p_timend,p_qtyminreq,
                                  null,null,null,null,'Y',
                                  v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); -- tpayvac
        v_ratenum := 1;
        json_obj.put('typot','B');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'B',global_v_lang));
        if v_a_tovrtime.typot is not null then
          for r_rteotpay in c_rteotpay loop
            v_qtyminot1 := 0;
            for i in 1..p_rateotcount loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                v_rteotpay := v_a_rteotpay(i);
                v_qtyminot := v_a_qtyminot(i);
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot1 := v_qtyminot1 + v_qtyminot;
                end if;
              end if;
            end loop;
            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('rate'||to_char(v_ratenum),v_token2);
            v_ratenum := v_ratenum + 1;
          end loop;
          json_obj.put('numrate' ,to_char(v_ratenum-1));
          v_qtyminotx := 0;
          for i in 1..p_rateotcount loop
            v_rteotpay := v_a_rteotpay(i);
            v_qtyminot := v_a_qtyminot(i);
            for r_rteotpay in c_rteotpay loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot := 0;
                end if;
              end if;
            end loop;
            v_qtyminotx := v_qtyminotx + v_qtyminot;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
          json_obj.put('rate'||to_char(v_ratenum),v_token2);
          json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
          json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
          json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
          json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
          json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
          json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
          if v_a_tovrtime.qtydedbrk is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtydedbrk',v_token2);
          end if;
          if v_a_tovrtime.qtyminot is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtyminot',v_token2);
          end if;
          json_obj.put('flgmeal',v_a_tovrtime.flgmeal);
          json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
          json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
          json_obj.put('codappr',v_codempid);
          json_obj.put('desc_codappr',v_desc_codempid);
          json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_a_tovrtime.qtyleave));
          json_obj.put('codrem',v_a_tovrtime.codrem);
          json_obj.put('codcompw',v_a_tovrtime.codcompw);
          json_obj.put('desc_codcompw',get_tcenter_name(v_a_tovrtime.codcompw,global_v_lang));
          json_obj.put('flgtypot', 'Y');
        end if;
    end;
    json_row.put('0',json_obj);
    --
    json_obj := json_object_t();
    begin
        select  dtestrt,dteend,
                timstrt,timend,
                qtydedbrk,amtmeal,
                dteappr,codappr,
                qtyleave,codrem,
                qtyminot,codcompw,
                flgotcal
          into  v_dtestr,v_dteend,
                v_timstr,v_timend,
                v_qtydedbrk,v_amtmeal,
                v_dteappr,v_codappr,
                v_qtyleave,v_codrem,
                v_qtyminot_1,v_codcompw,
                v_flgotcal
          from  tovrtime
         where  dtework = p_dtework
           and  codempid = p_codempid
           and  typot = 'D';

        json_obj.put('typot','D');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'D',global_v_lang));
        json_obj.put('flgappr','A');
        json_obj.put('flgotcal',v_flgotcal);
        json_obj.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
--        json_obj.put('dtestrt',to_char(v_dtestr,'dd/mm/yyyy'));
--        json_obj.put('dteend' ,to_char(v_dteend ,'dd/mm/yyyy'));
--        json_obj.put('timstrt',to_char(to_date(v_timstr,'hh24mi'),'hh24:mi'));
--        json_obj.put('timend' ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
--        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_dtestr,v_timstr));
--        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_dteend,v_timend));

        json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
        json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
        json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
        json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
--        if v_qtydedbrk is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtydedbrk',v_token2);
--        end if;
--        if v_qtyminot_1 is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot_1,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtyminot',v_token2);
--        end if;
        if v_a_tovrtime.qtydedbrk is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtydedbrk',v_token2);
        end if;
        if v_a_tovrtime.qtyminot is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtyminot',v_token2);
        end if;
--        json_obj.put('amtmeal',stddec(v_amtmeal,p_codempid,v_chken));
        json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
        json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
        json_obj.put('codappr',v_codappr);
        json_obj.put('desc_codappr',get_temploy_name(v_codappr,global_v_lang));
        json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_qtyleave));
        json_obj.put('codrem',v_codrem);
        json_obj.put('codcompw',v_codcompw);
        json_obj.put('desc_codcompw',get_tcenter_name(v_codcompw,global_v_lang));
        json_obj.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
        --
        v_typot := 'D';
        v_ratenum := 1;
        v_qtyminotx := 0;
        --
        select count(codempid)
         into v_countpaydt
         from totpaydt
        where codempid = P_codempid
          and dtework  = p_dtework
          and typot    = v_typot;

        if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,p_codempid,hcm_secur.get_v_chken)) > 0 then
          json_obj.put('flgtypot','Y');
        else
          json_obj.put('flgtypot','N');
        end if;
--        for r_rteotpay in c_rteotpay loop
--          begin
--            select  nvl(sum(nvl(qtyminot,0)),0)
--              into  v_qtyminot1
--              from  totpaydt
--             where  dtework = p_dtework
--               and  codempid = p_codempid
--               and  typot = v_typot
--               and  rteotpay = r_rteotpay.rteotpay;
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
--            v_qtyminotx := v_qtyminotx + v_qtyminot1;
--          exception when others then
--            hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
--          end;
--          json_obj.put('rate'||to_char(v_ratenum),v_token2);
--          v_ratenum := v_ratenum + 1;
--        end loop;
--        json_obj.put('numrate' ,to_char(v_ratenum-1));
        for r_rteotpay in c_rteotpay loop
            v_qtyminot1 := 0;
            for i in 1..p_rateotcount loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                v_rteotpay := v_a_rteotpay(i);
                v_qtyminot := v_a_qtyminot(i);
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot1 := v_qtyminot1 + v_qtyminot;
                end if;
              end if;
            end loop;
            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('rate'||to_char(v_ratenum),v_token2);
            v_ratenum := v_ratenum + 1;
          end loop;
          json_obj.put('numrate' ,to_char(v_ratenum-1));
        begin
          select  nvl(sum(nvl(qtyminot,0)),0)
            into  v_qtyminot1
            from  totpaydt
           where  dtework = p_dtework
             and  codempid = p_codempid
             and  typot = v_typot;
          hcm_util.cal_dhm_hm (0,0,v_qtyminot1-v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
        exception when others then
          hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
        end;
        json_obj.put('ratex',v_token2);
    exception when others then
        hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                  null,p_codempid,p_dtework,'D',p_codshift,
                                  p_dtein ,p_timin,
                                  p_dteout,p_timout,
                                  p_dtestrt,p_timstrt,p_dteend,p_timend,p_qtyminreq,
                                  null,null,null,null,'Y',
                                  v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); -- tpayvac
        v_ratenum := 1;
        json_obj.put('typot','D');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'D',global_v_lang));
        if v_a_tovrtime.typot is not null then
          for r_rteotpay in c_rteotpay loop
            v_qtyminot1 := 0;
            for i in 1..p_rateotcount loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                v_rteotpay := v_a_rteotpay(i);
                v_qtyminot := v_a_qtyminot(i);
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot1 := v_qtyminot1 + v_qtyminot;
                end if;
              end if;
            end loop;
            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('rate'||to_char(v_ratenum),v_token2);
            v_ratenum := v_ratenum + 1;
          end loop;
          json_obj.put('numrate' ,to_char(v_ratenum-1));
          v_qtyminotx := 0;
          for i in 1..p_rateotcount loop
            v_rteotpay := v_a_rteotpay(i);
            v_qtyminot := v_a_qtyminot(i);
            for r_rteotpay in c_rteotpay loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot := 0;
                end if;
              end if;
            end loop;
            v_qtyminotx := v_qtyminotx + v_qtyminot;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
          json_obj.put('rate'||to_char(v_ratenum),v_token2);
          json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
          json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
          json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
          json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
          json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
          json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
          if v_a_tovrtime.qtydedbrk is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtydedbrk',v_token2);
          end if;
          if v_a_tovrtime.qtyminot is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtyminot',v_token2);
          end if;
          json_obj.put('flgmeal',v_a_tovrtime.flgmeal);
          json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
          json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
          json_obj.put('codappr',v_codempid);
          json_obj.put('desc_codappr',v_desc_codempid);
          json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_a_tovrtime.qtyleave));
          json_obj.put('codrem',v_a_tovrtime.codrem);
          json_obj.put('codcompw',v_a_tovrtime.codcompw);
          json_obj.put('desc_codcompw',get_tcenter_name(v_a_tovrtime.codcompw,global_v_lang));
          json_obj.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_a_tovrtime.codcompw, null, '', 'Y')));
          json_obj.put('flgtypot', 'Y');
        end if;
    end;
    json_row.put('1',json_obj);
    --
    json_obj := json_object_t();
    begin
        select  dtestrt,dteend,
                timstrt,timend,
                qtydedbrk,amtmeal,
                dteappr,codappr,
                qtyleave,codrem,
                qtyminot,codcompw,
                flgotcal
          into  v_dtestr,v_dteend,
                v_timstr,v_timend,
                v_qtydedbrk,v_amtmeal,
                v_dteappr,v_codappr,
                v_qtyleave,v_codrem,
                v_qtyminot_1,v_codcompw,
                v_flgotcal
          from  tovrtime
         where  dtework = p_dtework
           and  codempid = p_codempid
           and  typot = 'A';
        --
        hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                  null,p_codempid,p_dtework,'A',p_codshift,
                                  p_dtein ,p_timin,
                                  p_dteout,p_timout,
                                  p_dtestrt,p_timstrt,p_dteend,p_timend,p_qtyminreq,
                                  null,null,null,null,'Y',
                                  v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);

        --
        json_obj.put('typot','A');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'A',global_v_lang));
        json_obj.put('flgappr','A');
        json_obj.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
        json_obj.put('flgotcal',v_flgotcal);
--        json_obj.put('dtestrt',to_char(v_dtestr,'dd/mm/yyyy'));
--        json_obj.put('dteend' ,to_char(v_dteend ,'dd/mm/yyyy'));
--        json_obj.put('timstrt',to_char(to_date(v_timstr,'hh24mi'),'hh24:mi'));
--        json_obj.put('timend' ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
--        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_dtestr,v_timstr));
--        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_dteend,v_timend));
        --
        json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
        json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
        json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
        json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
        json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
        json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
--        if v_qtydedbrk is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtydedbrk',v_token2);
--        end if;
--        if v_qtyminot_1 is not null then
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot_1,null,'2',v_token,v_token,v_token,v_token2);
--            json_obj.put('qtyminot',v_token2);
--        end if;
        if v_a_tovrtime.qtydedbrk is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtydedbrk',v_token2);
        end if;
        if v_a_tovrtime.qtyminot is not null then
            hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('qtyminot',v_token2);
        end if;
--        json_obj.put('amtmeal',stddec(v_amtmeal,p_codempid,v_chken));
        json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
        json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
        json_obj.put('codappr',v_codappr);
        json_obj.put('desc_codappr',get_temploy_name(v_codappr,global_v_lang));
        json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_qtyleave));
        json_obj.put('codrem',v_codrem);
        json_obj.put('codcompw',v_codcompw);
        json_obj.put('desc_codcompw',get_tcenter_name(v_codcompw,global_v_lang));
        json_obj.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
        --
        v_typot := 'A';
        v_ratenum := 1;
        v_qtyminotx := 0;
        --
        select count(codempid)
         into v_countpaydt
         from totpaydt
        where codempid = P_codempid
          and dtework  = p_dtework
          and typot    = v_typot;

        if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,p_codempid,hcm_secur.get_v_chken)) > 0 then
          json_obj.put('flgtypot','Y');
        else
          json_obj.put('flgtypot','N');
        end if;

--        for r_rteotpay in c_rteotpay loop
--          begin
--            select  nvl(sum(nvl(qtyminot,0)),0)
--              into  v_qtyminot1
--              from  totpaydt
--             where  dtework = p_dtework
--               and  codempid = p_codempid
--               and  typot = v_typot
--               and  rteotpay = r_rteotpay.rteotpay;
--            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
--            v_qtyminotx := v_qtyminotx + v_qtyminot1;
--          exception when others then
--            hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
--          end;
--          json_obj.put('rate'||to_char(v_ratenum),v_token2);
--          v_ratenum := v_ratenum + 1;
--        end loop;
--        json_obj.put('numrate' ,to_char(v_ratenum-1));
        for r_rteotpay in c_rteotpay loop
          v_qtyminot1 := 0;
          for i in 1..p_rateotcount loop
            if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
              v_rteotpay := v_a_rteotpay(i);
              v_qtyminot := v_a_qtyminot(i);
              if v_rteotpay = r_rteotpay.rteotpay then
                v_qtyminot1 := v_qtyminot1 + v_qtyminot;
              end if;
            end if;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
          json_obj.put('rate'||to_char(v_ratenum),v_token2);
          v_ratenum := v_ratenum + 1;
        end loop;
        json_obj.put('numrate' ,to_char(v_ratenum-1));
        begin
          select  nvl(sum(nvl(qtyminot,0)),0)
            into  v_qtyminot1
            from  totpaydt
           where  dtework = p_dtework
             and  codempid = p_codempid
             and  typot = v_typot;
          hcm_util.cal_dhm_hm (0,0,v_qtyminot1-v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
        exception when others then
          hcm_util.cal_dhm_hm (0,0,0,null,'2',v_token,v_token,v_token,v_token2);
        end;
        json_obj.put('ratex',v_token2);
    exception when others then
        hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                  null,p_codempid,p_dtework,'A',p_codshift,
                                  p_dtein ,p_timin,
                                  p_dteout,p_timout,
                                  p_dtestrt,p_timstrt,p_dteend,p_timend,p_qtyminreq,
                                  null,null,null,null,'Y',
                                  v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); -- tpayvac
        v_ratenum := 1;
        json_obj.put('typot','A');
        json_obj.put('desc_typot',get_tlistval_name(p_codapp,'A',global_v_lang));
        if v_a_tovrtime.typot is not null then
          for r_rteotpay in c_rteotpay loop
            v_qtyminot1 := 0;
            for i in 1..p_rateotcount loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                v_rteotpay := v_a_rteotpay(i);
                v_qtyminot := v_a_qtyminot(i);
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot1 := v_qtyminot1 + v_qtyminot;
                end if;
              end if;
            end loop;
            hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
            json_obj.put('rate'||to_char(v_ratenum),v_token2);
            v_ratenum := v_ratenum + 1;
          end loop;
          json_obj.put('numrate' ,to_char(v_ratenum-1));
          v_qtyminotx := 0;
          for i in 1..p_rateotcount loop
            v_rteotpay := v_a_rteotpay(i);
            v_qtyminot := v_a_qtyminot(i);
            for r_rteotpay in c_rteotpay loop
              if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                if v_rteotpay = r_rteotpay.rteotpay then
                  v_qtyminot := 0;
                end if;
              end if;
            end loop;
            v_qtyminotx := v_qtyminotx + v_qtyminot;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
          json_obj.put('rate'||to_char(v_ratenum),v_token2);
          json_obj.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
          json_obj.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
          json_obj.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
          json_obj.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
          json_obj.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
          json_obj.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
          if v_a_tovrtime.qtydedbrk is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtydedbrk',v_token2);
          end if;
          if v_a_tovrtime.qtyminot is not null then
              hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
              json_obj.put('qtyminot',v_token2);
          end if;
          json_obj.put('flgmeal',v_a_tovrtime.flgmeal);
          json_obj.put('amtmeal',stddec(v_a_tovrtime.amtmeal,p_codempid,v_chken));
          json_obj.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
          json_obj.put('codappr',v_codempid);
          json_obj.put('desc_codappr',v_desc_codempid);
          json_obj.put('qtyleave',hcm_util.convert_minute_to_hour(v_a_tovrtime.qtyleave));
          json_obj.put('codrem',v_a_tovrtime.codrem);
          json_obj.put('codcompw',v_a_tovrtime.codcompw);
          json_obj.put('desc_codcompw',get_tcenter_name(v_a_tovrtime.codcompw,global_v_lang));
          json_obj.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_a_tovrtime.codcompw, null, '', 'Y')));
          json_obj.put('flgtypot', 'Y');
        end if;
    end;
    json_row.put('2',json_obj);
    --
    json_obj2 := json_object_t();
    json_obj2.put('children',json_row);
    json_obj2.put('codshift',v_codshift);
    json_obj2.put('dtework',to_char(p_dtework,'dd/mm/yyyy'));
    json_obj2.put('typwork',v_typwork);
    json_obj2.put('codempid',p_codempid);
    json_obj2.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
    json_obj2.put('image',get_emp_img(p_codempid));
    json_obj2.put('dtein' ,to_char(p_dtein ,'dd/mm/yyyy'));
    json_obj2.put('dteout',to_char(p_dteout,'dd/mm/yyyy'));
    json_obj2.put('timin' ,to_char(to_date(p_timin ,'hh24mi'),'hh24:mi'));
    json_obj2.put('timout',to_char(to_date(p_timout,'hh24mi'),'hh24:mi'));
    json_obj2.put('dtetimin' ,hcm_util.convert_date_time_to_dtetime(p_dtein ,p_timin ));
    json_obj2.put('dtetimout',hcm_util.convert_date_time_to_dtetime(p_dteout,p_timout));
    json_obj2.put('coderror','200');
    json_str_output := json_obj2.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_TimeAttendant;

  procedure gen_st_index_by_codempid(v_i_codempid in varchar2, json_str_output out clob) as
    json_obj        json_object_t := json_object_t();
    json_children   json_object_t;
    json_row        json_object_t;
    json_row1       json_object_t;
    v_permission    boolean := false;
    v_exist         boolean := false;
    v_count         number := 0;
    v_secur         boolean;
    v_dtework       date;
    v_typot         varchar2(2 char);
    v_codcompy      tcenter.codcompy%type;
    cursor c1 is
        select  codempid,typwork,codshift,dtein,dteout,timin,timout,dtework,codcomp
          from  tattence t1
         where  t1.codempid = v_i_codempid
           and  t1.dtework between p_dtestr and p_dteend
      order by  t1.dtework,t1.codempid;

    cursor c_rateot is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy = nvl(v_codcompy,codcompy)
    order by rteotpay;
    v_dtestrt       date;
    v_dteend        date;
    v_timstrt       tovrtime.timstrt%type;
    v_timend        tovrtime.timend%type;
    v_qtydedbrk     number;
    v_qtyminot      number;
    v_flgotcal      varchar2(1 char);
    v_flgotcal_h    varchar2(1 char);
    v_countot       number := 0;
    v_amtmeal       tovrtime.amtmeal%type;
    v_qtyleave      number;
    v_codrem        tovrtime.codrem%type;
    v_codappr       tovrtime.codappr%type;
    v_dteappr       date;
    v_numotreq      tovrtime.numotreq%type;
    v_desc_codcompw tcenter.namcente%type;
    v_codcompw      tcenter.codcomp%type;
    v_token         number;
    v_token2        varchar2(100 char);
    v_chken         varchar2(100 char);
    v_dteeffec      date;
    v_condot        tcontrot.condot%type;
    v_condextr      tcontrot.condextr%type;
    v_flgrateot     tcontrot.flgrateot%type;
    v_ot            boolean;
    v_codempid      temploy1.codempid%type;
    v_coduser       temploy1.coduser%type;
    v_a_tovrtime    tovrtime%rowtype;
    v_a_rteotpay    hral85b_batch.a_rteotpay;
    v_a_qtyminot    hral85b_batch.a_qtyminot;
    v_rteotpay      number;
    v_qtyminot1     number;
    v_qtyminot1_5   number;
    v_qtyminot2     number;
    v_qtyminot3     number;
    v_qtyminot4     number;
    v_qtyminot5     number;
    v_qtyminot6     number;
    v_qtyminotx     number;
    v_ratenum       number;
    v_countpaydt    number;
    v_index         number  := 0;
    type rateOt     is table of number index by binary_integer;
		list_rateot     rateOt;
    cursor c3 is
        select  dtewkreq
          from  totreqd
         where  codempid = v_codempid
           and  typot    = v_typot
           and  numotreq = v_numotreq
      order by  dtewkreq;
    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = v_i_codempid
    order by t1.rteotpay;
  begin
    v_count := 0;
    v_chken := hcm_secur.get_v_chken;
    --
    v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    if p_codcomp is null then
      begin
        select hcm_util.get_codcomp_level(codcomp,1)
        into v_codcompy
        from temploy1
        where codempid = v_i_codempid;
      exception when no_data_found then null;
      end;
    end if;

    for i in 1..7 loop -- SEA-Chai
      list_rateot(i) := null;
    end loop;

    for r_rateot in c_rateot loop
      v_index := v_index + 1;
      list_rateot(v_index) := r_rateot.rteotpay;
--      if v_index = 4 then
--        exit;
--      end if;
    end loop;
    --
    for r1 in c1 loop
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      v_exist := true;
      if v_secur then
          v_permission := true;
          v_dtework := r1.dtework;
          v_codempid := r1.codempid;
          json_row := json_object_t();
          json_row.put('codempid',r1.codempid);
          json_row.put('dtework',to_char(r1.dtework ,'dd/mm/yyyy'));
          json_row.put('typwork',r1.typwork);
          json_row.put('codshift',r1.codshift);
          json_row.put('dtein' ,to_char(r1.dtein ,'dd/mm/yyyy'));
          json_row.put('dteout',to_char(r1.dteout,'dd/mm/yyyy'));
          json_row.put('timin' ,to_char(to_date(r1.timin ,'hh24mi'),'hh24:mi'));
          json_row.put('timout',to_char(to_date(r1.timout,'hh24mi'),'hh24:mi'));
          json_row.put('dtetimin' ,hcm_util.convert_date_time_to_dtetime(r1.dtein ,r1.timin ));
          json_row.put('dtetimout',hcm_util.convert_date_time_to_dtetime(r1.dteout,r1.timout));

          -- check ว่ามีการ Cal ส่ง OT  ไป PY  หรือ ยัง
          begin
            select  count(*)
              into  v_countot
              from  tovrtime
             where  codempid          = r1.codempid
               and  dtework           = r1.dtework
               and  nvl(flgotcal,'N') = 'Y';
          end;

          if v_countot > 0 then
            v_flgotcal_h := 'Y';
          else
           v_flgotcal_h := 'N';
          end if;
          json_row.put('flgotcal',v_flgotcal_h);
          ---------------------
          json_children := json_object_t();
          for i in 1..3 loop
            if i = 1 then
              v_typot := 'B';
            elsif i = 2 then
              v_typot := 'D';
            else
              v_typot := 'A';
            end if;
            json_row1 := json_object_t();
            v_dtestrt        := null;
            v_dteend         := null;
            v_timstrt        := null;
            v_timend         := null;
            v_qtydedbrk      := null;
            v_qtyminot       := null;
            v_flgotcal       := null;
            v_amtmeal        := null;
            v_qtyleave       := null;
            v_codrem         := null;
            v_codappr        := null;
            v_dteappr        := null;
            v_numotreq       := null;
            v_desc_codcompw  := null;
            v_codcompw       := null;
            v_coduser        := null;
            begin
                json_row1.put('typot',v_typot);
                json_row1.put('desc_typot',get_tlistval_name(p_codapp,v_typot,global_v_lang));
                json_row1.put('codempid2',r1.codempid);

                select dtestrt ,dteend ,timstrt ,timend ,qtydedbrk,qtyminot,
                       flgotcal,amtmeal,qtyleave,codrem ,codappr  ,dteappr ,
                       numotreq,get_tcenter_name(codcompw,global_v_lang) desc_codcompw,codcompw,coduser
                  into v_dtestrt ,v_dteend ,v_timstrt ,v_timend ,v_qtydedbrk,v_qtyminot,
                       v_flgotcal,v_amtmeal,v_qtyleave,v_codrem ,v_codappr  ,v_dteappr ,
                       v_numotreq,v_desc_codcompw     ,v_codcompw,v_coduser
                  from tovrtime
                 where dtework  = v_dtework
                   and codempid = r1.codempid
                   and typot    = v_typot;

                json_row1.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
                json_row1.put('dteend' ,to_char(v_dteend ,'dd/mm/yyyy'));
                json_row1.put('timstrt',to_char(to_date(v_timstrt,'hh24mi'),'hh24:mi'));
                json_row1.put('timend' ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
                json_row1.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_dtestrt,v_timstrt));
                json_row1.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_dteend ,v_timend ));
                hcm_util.cal_dhm_hm(0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtydedbrk',v_token2);
                hcm_util.cal_dhm_hm(0,0,v_qtyminot,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtyminot',v_token2);
                json_row1.put('flgotcal',v_flgotcal);
                json_row1.put('flgappr','A');
                json_row1.put('amtmeal',nvl(to_number(stddec(v_amtmeal,r1.codempid,v_chken)),0));
                hcm_util.cal_dhm_hm(0,0,v_qtyleave,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtyleave',v_token2);
                json_row1.put('codrem',v_codrem);
                json_row1.put('codappr',v_codappr);
                json_row1.put('dteappr',to_char(v_dteappr,'dd/mm/yyyy'));
                json_row1.put('numotreq',v_numotreq);
                json_row1.put('desc_codcompw',v_desc_codcompw);
                json_row1.put('codcompw',v_codcompw);
                json_row1.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
                json_row1.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
                v_ratenum := 1;

                begin
                select sum(decode(rteotpay,list_rateot(1),qtyminot,0)) timot10,
                       sum(decode(rteotpay,list_rateot(2),qtyminot,0)) timot15,
                       sum(decode(rteotpay,list_rateot(3),qtyminot,0)) timot20,
                       sum(decode(rteotpay,list_rateot(4),qtyminot,0)) timot30,
                       sum(decode(rteotpay,list_rateot(5),qtyminot,0)) timot40,
                       sum(decode(rteotpay,list_rateot(6),qtyminot,0)) timot50,
                       sum(decode(rteotpay,list_rateot(7),qtyminot,0)) timot60,
                       sum(decode(rteotpay, list_rateot(1),0,
                                            list_rateot(2),0,
                                            list_rateot(3),0,
                                            list_rateot(4),0,
                                            list_rateot(5),0,
                                            list_rateot(6),0,
                                            list_rateot(7),0,
                                            qtyminot)) timototh
                  into v_qtyminot1, v_qtyminot1_5, v_qtyminot2, v_qtyminot3, v_qtyminot4, v_qtyminot5, v_qtyminot6, v_qtyminotx
                  from totpaydt
                 where codempid = v_codempid
                   and dtework  = v_dtework
                   and typot    = v_typot;
                 exception when no_data_found then
                     null;
                 end;

                 hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate1',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot1_5,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate2',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot2,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate3',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot3,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate4',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot4,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate5',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot5,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate6',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminot6,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('rate7',v_token2);
                 hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
                 json_row1.put('ratex',v_token2);
                 json_row1.put('numrate' ,to_char(7));
                 select count(codempid)
                   into v_countpaydt
                   from totpaydt
                  where codempid = v_codempid
                    and dtework  = v_dtework
                    and typot    = v_typot;
                 if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,r1.codempid,v_chken)) > 0 then
                    json_row1.put('flgtypot','Y');
                 else
                    json_row1.put('flgtypot','N');
                 end if;
            exception when no_data_found then
                begin
                    select  dteeffec,condot,condextr,flgrateot
                      into  v_dteeffec,v_condot,v_condextr,v_flgrateot
                      from  tcontrot
                     where  codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                       and  dteeffec = (select  max(dteeffec)
                                          from  tcontrot
                                         where  codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                           and  dteeffec < sysdate)
                       and  rownum <= 1;
                    v_codempid := r1.codempid;
                    v_qtyminot1   := 0;
                    v_qtyminot1_5 := 0;
                    v_qtyminot2   := 0;
                    v_qtyminot3   := 0;
                    v_qtyminotx   := 0;
                    hral85b_batch.cal_time_ot(hcm_util.get_codcomp_level(r1.codcomp,1),v_dteeffec,
                                                         v_condot,v_condextr,null,r1.codempid,r1.dtework,v_typot, --B,D,A
                                                         r1.codshift,r1.dtein,r1.timin,r1.dteout,r1.timout,
                                                         null,null,null,null,null,null,null,null,null,'Y',
                                                         v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
                    v_ratenum := 1;
                    json_row1.put('rate1','');
                    json_row1.put('rate2','');
                    json_row1.put('rate3','');
                    json_row1.put('rate4','');
                    json_row1.put('rate5','');
                    json_row1.put('rate6','');
                    json_row1.put('rate7','');
                    json_row1.put('numrate' ,4);
                    if v_a_tovrtime.typot is not null then
                      for r_rteotpay in c_rteotpay loop
                        v_qtyminotx := 0;
                        for i in 1..p_rateotcount loop
                          if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                            v_rteotpay := v_a_rteotpay(i);
                            v_qtyminot := v_a_qtyminot(i);
                            if v_rteotpay = r_rteotpay.rteotpay then
                              v_qtyminotx := v_qtyminotx + v_qtyminot;
                            end if;
                          end if;
                        end loop;
                        hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
                        json_row1.put('rate' || to_char(v_ratenum),v_token2);
                        v_ratenum := v_ratenum + 1;
                      end loop;
                      json_row1.put('numrate' ,to_char(v_ratenum-1));
                      v_qtyminotx := 0;
                      for i in 1..p_rateotcount loop
                        v_qtyminot1 := v_a_qtyminot(i);
                        for r_rteotpay in c_rteotpay loop
                          if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                            v_qtyminot1 := 0;
                          end if;
                        end loop;
                        v_qtyminotx := v_qtyminotx + v_qtyminot1;
                      end loop;
                      hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
                      json_row1.put('ratex',v_token2);
                      begin
                        select get_tcenter_name(codcompw,global_v_lang),codcompw
                          into v_desc_codcompw,v_codcompw
                          from v_tattence_cc
                         where codempid = r1.codempid
                           and dtework = v_a_tovrtime.dtework;
                      exception when no_data_found then
                          v_desc_codcompw := '';
                          v_codcompw := '';
                      end;
                      json_row1.put('typot',v_typot);
                      json_row1.put('desc_typot',get_tlistval_name(p_codapp,v_typot,global_v_lang));
                      json_row1.put('codempid2',r1.codempid);
                      json_row1.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
                      json_row1.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
                      json_row1.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
                      json_row1.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
                      json_row1.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
                      json_row1.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
                      hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
                      json_row1.put('qtydedbrk',v_token2);
                      hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
                      json_row1.put('qtyminot',v_token2);
                      json_row1.put('flgotcal',v_a_tovrtime.flgotcal);
                      json_row1.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
                      json_row1.put('amtmeal',nvl(to_number(stddec(v_a_tovrtime.amtmeal,r1.codempid,v_chken)),0));
                      hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyleave,null,'2',v_token,v_token,v_token,v_token2);
                      json_row1.put('qtyleave',v_token2);
                      json_row1.put('codrem',v_a_tovrtime.codrem);
                      begin
                        select  codempid
                          into  v_token2
                          from  tusrprof
                         where  coduser = global_v_coduser;
                      exception when others then
                        v_token2 := '';
                      end;
                      json_row1.put('codappr',v_token2);
                      json_row1.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
                      json_row1.put('numotreq',v_a_tovrtime.numotreq);
                      json_row1.put('desc_codcompw',v_desc_codcompw);
                      json_row1.put('codcompw',v_codcompw);
                      json_row1.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
                    end if;
                exception when others then null;
                end;
                if v_a_tovrtime.dtestrt is not null then
                    json_row1.put('flgtypot','Y');
                end if;
            end;
            json_children.put(to_char(i-1),json_row1);
          end loop;
          json_row.put('children',json_children);
          json_row.put('flg',p_flg);
          json_row.put('coderror'   ,'200');
          json_obj.put(to_char(v_count),json_row);
          v_count := v_count + 1;
      end if;
    end loop;
    if v_exist then
      if not v_permission then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      else
        json_str_output := json_obj.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_st_index_by_codempid;

  procedure gen_st_index_by_date(v_date in date, json_str_output out clob) as
    json_obj        json_object_t := json_object_t();
    json_row        json_object_t;
    json_row1       json_object_t;
    json_children   json_object_t;
    v_permission    boolean := false;
    v_exist         boolean := false;
    v_count         number := 0;
    v_secur         boolean;
    v_dtework       date;
    v_typot          varchar2(2 char);
    v_codcompy      tcenter.codcompy%type;
    cursor c2 is
        select  t1.codempid,t1.dtework,t1.typwork,t1.codshift,t1.dtein,t1.dteout,t1.timin,t1.timout,t1.codcomp
          from  tattence t1,ttemprpt t2
         where  t1.codempid = t2.item1
           and  t2.codapp   = p_codapp
           and  t2.codempid = global_v_coduser
           and  t1.dtework  = v_date
      order by  t1.codempid,t1.dtework;

    cursor c_rateot is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy = nvl(v_codcompy,codcompy)
    order by rteotpay;
      --tovrtime
    v_dtestrt       date;
    v_dteend        date;
    v_timstrt       tovrtime.timstrt%type;
    v_timend        tovrtime.timend%type;
    v_qtydedbrk     number;
    v_qtyminot      number;
    v_flgotcal      varchar2(1 char);
    v_flgotcal_h    varchar2(1 char);
    v_countot       number := 0;
    v_amtmeal       tovrtime.amtmeal%type;
    v_qtyleave      number;
    v_codrem        varchar2(4 char);
    v_codappr       varchar2(10 char);
    v_dteappr       date;
    v_numotreq      tovrtime.numotreq%type;
    v_desc_codcompw tcenter.namcente%type;
    v_codcompw      tcenter.codcomp%type;
    v_token         number;
    v_token2        varchar2(100 char);
    v_chken         varchar2(10 char) := hcm_secur.get_v_chken;
    v_dteeffec      date;
    v_condot        tcontrot.condot%type;
    v_condextr      tcontrot.condextr%type;
    v_flgrateot     tcontrot.flgrateot%type;
    v_ot            boolean;
    v_codempid      temploy1.codempid%type;
    v_coduser       temploy1.coduser%type;
    v_a_tovrtime  tovrtime%rowtype;
    v_a_rteotpay  hral85b_batch.a_rteotpay;
    v_a_qtyminot  hral85b_batch.a_qtyminot;
    v_rteotpay  number;
    v_ratenum       number;
    v_qtyminot1     totpaydt.qtyminot%type;
    v_qtyminot1_5    totpaydt.qtyminot%type;
    v_qtyminot2     totpaydt.qtyminot%type;
    v_qtyminot3     totpaydt.qtyminot%type;
    v_qtyminot4     totpaydt.qtyminot%type;
    v_qtyminot5     totpaydt.qtyminot%type;
    v_qtyminot6     totpaydt.qtyminot%type;
    v_qtyminotx     totpaydt.qtyminot%type;
    v_countpaydt    number;
    v_index         number;
    type rateOt     is table of number index by binary_integer;
		list_rateot     rateOt;

    cursor c3 is
      select  dtewkreq
        from  totreqd
       where  codempid = v_codempid
         and  typot    = v_typot
         and  numotreq = v_numotreq
    order by  dtewkreq;

    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = v_codempid
    order by t1.rteotpay;
  begin
        
    for r1 in c2 loop
      v_exist := true;
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_secur then
        v_permission := true;
        v_codempid := r1.codempid;
        v_dtework := r1.dtework;
        json_row := json_object_t();
        json_row.put('dtework',to_char(v_date,'dd/mm/yyyy'));
        json_row.put('image',get_emp_img(r1.codempid));
        json_row.put('codempid',r1.codempid);
        json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        json_row.put('typwork',r1.typwork);
        json_row.put('codshift',r1.codshift);
        json_row.put('dtein' ,to_char(r1.dtein ,'dd/mm/yyyy'));
        json_row.put('dteout',to_char(r1.dteout,'dd/mm/yyyy'));
        json_row.put('timin' ,to_char(to_date(r1.timin ,'hh24mi'),'hh24:mi'));
        json_row.put('timout',to_char(to_date(r1.timout,'hh24mi'),'hh24:mi'));
        json_row.put('dtetimin' ,hcm_util.convert_date_time_to_dtetime(r1.dtein ,r1.timin ));
        json_row.put('dtetimout',hcm_util.convert_date_time_to_dtetime(r1.dteout,r1.timout));
        -- find rate ot of emp
        v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
        if p_codcomp is null then
          begin
            select hcm_util.get_codcomp_level(codcomp,1)
            into v_codcompy
            from temploy1
            where codempid = v_codempid;
          exception when no_data_found then null;
          end;
        end if;
        v_index := 0;
        for i in 1..7 loop -- SEA-Chai
          list_rateot(i) := null;
        end loop;
        for r_rateot in c_rateot loop
          v_index := v_index + 1;
          list_rateot(v_index) := r_rateot.rteotpay;
--          if v_index = 4 then
--            exit;
--          end if;
        end loop;
        --
          -- check ว่ามีการ Cal ส่ง OT  ไป PY  หรือ ยัง
          begin
            select  count(*)
              into  v_countot
              from  tovrtime
             where  codempid          = r1.codempid
               and  dtework           = r1.dtework
               and  nvl(flgotcal,'N') = 'Y';
          end;

          if v_countot > 0 then
            v_flgotcal_h := 'Y';
          else
           v_flgotcal_h := 'N';
          end if;
        json_row.put('flgotcal',v_flgotcal_h);

        json_children := json_object_t();
        for i in 1..3 loop
          if i = 1 then
            v_typot := 'B';
          elsif i = 2 then
            v_typot := 'D';
          else
            v_typot := 'A';
          end if;
          json_row1 := json_object_t();
          begin
            json_row1.put('typot',v_typot);
            json_row1.put('desc_typot',get_tlistval_name(p_codapp,v_typot,global_v_lang));
            select  dtestrt ,dteend ,timstrt ,timend ,qtydedbrk,qtyminot,
                    flgotcal,amtmeal,qtyleave,codrem ,codappr  ,dteappr ,
                    numotreq,get_tcenter_name(codcompw,global_v_lang) desc_codcompw,codcompw,coduser
              into  v_dtestrt ,v_dteend ,v_timstrt ,v_timend ,v_qtydedbrk,v_qtyminot,
                    v_flgotcal,v_amtmeal,v_qtyleave,v_codrem ,v_codappr  ,v_dteappr ,
                    v_numotreq,v_desc_codcompw     ,v_codcompw,v_coduser
              from  tovrtime
              where  dtework  = v_dtework
                and  codempid = r1.codempid
                and  typot    = v_typot;
            json_row1.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
            json_row1.put('dteend' ,to_char(v_dteend ,'dd/mm/yyyy'));
            json_row1.put('timstrt',to_char(to_date(v_timstrt,'hh24mi'),'hh24:mi'));
            json_row1.put('timend' ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
            json_row1.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_dtestrt,v_timstrt));
            json_row1.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_dteend ,v_timend ));
            hcm_util.cal_dhm_hm (0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
            json_row1.put('qtydedbrk',v_token2);
            hcm_util.cal_dhm_hm (0,0,v_qtyminot,null,'2',v_token,v_token,v_token,v_token2);
            json_row1.put('qtyminot',v_token2);
            json_row1.put('flgotcal',v_flgotcal);
            json_row1.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
            json_row1.put('flgappr','A');
            json_row1.put('amtmeal',nvl(to_number(stddec(v_amtmeal,r1.codempid,v_chken)),0));
            hcm_util.cal_dhm_hm (0,0,v_qtyleave,null,'2',v_token,v_token,v_token,v_token2);
            json_row1.put('qtyleave',v_token2);
            json_row1.put('codrem',v_codrem);
            json_row1.put('codappr',v_codappr);
            json_row1.put('dteappr',to_char(v_dteappr,'dd/mm/yyyy'));
            json_row1.put('numotreq',v_numotreq);
            json_row1.put('desc_codcompw',v_desc_codcompw);
            json_row1.put('codcompw',v_codcompw);
            json_row1.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
            v_ratenum := 1;
            begin
            select sum(decode(rteotpay,list_rateot(1),qtyminot,0)) timot10,
                   sum(decode(rteotpay,list_rateot(2),qtyminot,0)) timot15,
                   sum(decode(rteotpay,list_rateot(3),qtyminot,0)) timot20,
                   sum(decode(rteotpay,list_rateot(4),qtyminot,0)) timot30,
                   sum(decode(rteotpay,list_rateot(5),qtyminot,0)) timot40,
                   sum(decode(rteotpay,list_rateot(6),qtyminot,0)) timot50,
                   sum(decode(rteotpay,list_rateot(7),qtyminot,0)) timot60,
                   sum(decode(rteotpay, list_rateot(1),0,
                                        list_rateot(2),0,
                                        list_rateot(3),0,
                                        list_rateot(4),0,
                                        list_rateot(5),0,
                                        list_rateot(6),0,
                                        list_rateot(7),0,
                                        qtyminot)) timototh
              into v_qtyminot1, v_qtyminot1_5, v_qtyminot2, v_qtyminot3, v_qtyminot4, v_qtyminot5, v_qtyminot6, v_qtyminotx
              from totpaydt
             where codempid = v_codempid
               and dtework  = v_dtework
               and typot    = v_typot;
             exception when no_data_found then
                 null;
             end;

             hcm_util.cal_dhm_hm (0,0,v_qtyminot1,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate1',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot1_5,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate2',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot2,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate3',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot3,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate4',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot4,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate5',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot5,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate6',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminot6,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('rate7',v_token2);
             hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
             json_row1.put('ratex',v_token2);

  
             select count(codempid)
               into v_countpaydt
               from totpaydt
              where codempid = v_codempid
                and dtework  = v_dtework
                and typot    = v_typot;
             if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,r1.codempid,v_chken)) > 0 then
                json_row1.put('flgtypot','Y');
             else
                json_row1.put('flgtypot','N');
             end if;
            json_row1.put('numrate' ,to_char(7));
          exception when no_data_found then
            begin
              select  dteeffec,condot,condextr,flgrateot
                into  v_dteeffec,v_condot,v_condextr,v_flgrateot
                from  tcontrot
               where  codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                 and  dteeffec = (select  max(dteeffec)
                                    from  tcontrot
                                   where  codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                     and  dteeffec < sysdate)
                 and  rownum <= 1;
              v_codempid    := r1.codempid;
              v_qtyminot1   := 0;
              v_qtyminot1_5 := 0;
              v_qtyminot2   := 0;
              v_qtyminot3   := 0;
              v_qtyminotx   := 0;
              hral85b_batch.cal_time_ot(hcm_util.get_codcomp_level(r1.codcomp,1),v_dteeffec,
                                                    v_condot,v_condextr,null,r1.codempid,r1.dtework,v_typot, --B,D,A
                                                    r1.codshift,r1.dtein,r1.timin,r1.dteout,r1.timout,
                                                    null,null,null,null,null,null,null,null,null,'Y',
                                                    v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
              v_ratenum := 1;
              json_row1.put('rate1','');
              json_row1.put('rate2','');
              json_row1.put('rate3','');
              json_row1.put('rate4','');
              json_row1.put('rate5','');
              json_row1.put('rate6','');
              json_row1.put('rate7','');
              json_row1.put('numrate' ,7);
              if v_a_tovrtime.typot is not null then
                for r_rteotpay in c_rteotpay loop
                  v_qtyminotx := 0;
                  for i in 1..p_rateotcount loop
                    if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                      v_rteotpay := v_a_rteotpay(i);
                      v_qtyminot := v_a_qtyminot(i);
                      if v_rteotpay = r_rteotpay.rteotpay then
                        v_qtyminotx := v_qtyminotx + v_qtyminot;
                      end if;
                    end if;
                  end loop;
                  hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
                  json_row1.put('rate' || to_char(v_ratenum),v_token2);
                  v_ratenum := v_ratenum + 1;
                end loop;
                json_row1.put('numrate' ,to_char(v_ratenum-1));
                v_qtyminotx := 0;
                for i in 1..p_rateotcount loop
                  v_qtyminot1 := v_a_qtyminot(i);
                  for r_rteotpay in c_rteotpay loop
                    if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
                      v_qtyminot1 := 0;
                    end if;
                  end loop;
                  v_qtyminotx := v_qtyminotx + v_qtyminot1;
                end loop;
                hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('ratex',v_token2);
                begin
                  select get_tcenter_name(codcompw,global_v_lang),codcompw
                          into v_desc_codcompw,v_codcompw
                          from v_tattence_cc
                         where codempid = r1.codempid
                           and dtework = v_a_tovrtime.dtework;
                exception when no_data_found then
                  v_desc_codcompw := '';
                  v_codcompw := '';
                end;
                json_row1.put('typot',v_typot);
                json_row1.put('desc_typot',get_tlistval_name(p_codapp,v_typot,global_v_lang));
                json_row1.put('dtestrt',to_char(v_a_tovrtime.dtestrt,'dd/mm/yyyy'));
                json_row1.put('dteend' ,to_char(v_a_tovrtime.dteend ,'dd/mm/yyyy'));
                json_row1.put('timstrt',to_char(to_date(v_a_tovrtime.timstrt,'hh24mi'),'hh24:mi'));
                json_row1.put('timend' ,to_char(to_date(v_a_tovrtime.timend ,'hh24mi'),'hh24:mi'));
                json_row1.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dtestrt,v_a_tovrtime.timstrt));
                json_row1.put('dtetimend',hcm_util.convert_date_time_to_dtetime(v_a_tovrtime.dteend ,v_a_tovrtime.timend ));
                hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtydedbrk',v_token2);
                hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyminot,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtyminot',v_token2);
                json_row1.put('flgotcal',v_a_tovrtime.flgotcal);
                json_row1.put('desc_flgotcal',get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
                json_row1.put('amtmeal',nvl(to_number(stddec(v_a_tovrtime.amtmeal,r1.codempid,v_chken)),0));
                hcm_util.cal_dhm_hm (0,0,v_a_tovrtime.qtyleave,null,'2',v_token,v_token,v_token,v_token2);
                json_row1.put('qtyleave',v_token2);
                json_row1.put('codrem',v_a_tovrtime.codrem);
                begin
                  select  codempid
                    into  v_token2
                    from  tusrprof
                    where  coduser = global_v_coduser;
                exception when others then
                  v_token2 := '';
                end;
                json_row1.put('codappr',v_token2);
                json_row1.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
                json_row1.put('numotreq',v_a_tovrtime.numotreq);
                json_row1.put('desc_codcompw',v_desc_codcompw);
                json_row1.put('codcompw',v_codcompw);
                json_row1.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
              end if;
            exception when others then null;
            end;
            if v_a_tovrtime.dtestrt is not null then
                json_row1.put('flgtypot','Y');
            end if;
          end;
          json_children.put(to_char(i-1),json_row1);
        end loop;
        json_row.put('children',json_children);
        json_row.put('flg',p_flg);
        json_row.put('coderror'   ,'200');
        json_obj.put(to_char(v_count),json_row);
        v_count := v_count + 1;
      end if;
    end loop;
    if v_exist then
      if not v_permission then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
      else
        json_str_output := json_obj.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_st_index_by_date;

  function timeformat_to_number(v_time varchar2)return number as
    v_time2     varchar2(100 char);
    v_lenght    number;
    v_timehr    varchar2(100 char);
    v_timemi    varchar2(100 char);
  begin
    v_time2 := replace(v_time, ':', '');
    v_time2 := replace(v_time2, '.', '');
    v_lenght := length(v_time2);
    if v_lenght < 4 then
        v_time2 := lpad(v_time2, 4, '0');
        v_lenght := length(v_time2);
    end if;
    v_timehr := substr(v_time,1,v_lenght-2);
    v_timemi := substr(v_time,-2,2);
    return  to_number(v_timehr)*60 + to_number(v_timemi);
  end timeformat_to_number;

  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    save_data(json_str_output);
    -- check_save;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    else
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end post_save;

  procedure check_save (p_key_row varchar2,
                        v_dtestr date,
                        v_timstr varchar2,
                        v_dteend date,
                        v_timend varchar2,
                        p_dtepstr date,
                        p_timpstr varchar2,
                        p_dtepend date,
                        p_timpend varchar2) as
    v_dtetimst    date;
    v_dtetimen    date;
    v_dtetimpst   date;
    v_dtetimpen   date;
  begin
    if v_dtestr is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang,'dtestr');
      return;
    end if;
    if v_timstr is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang,'timstr');
      return;
    end if;
    if v_dteend is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    end if;
    if v_timend is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang,'timend');
      return;
    end if;
    --validate table--
    v_dtetimst    := to_date(to_char(v_dtestr,'dd/mm/yyyy')||' '||v_timstr,'dd/mm/yyyy hh24:mi');
    v_dtetimen    := to_date(to_char(v_dteend,'dd/mm/yyyy')||' '||v_timend,'dd/mm/yyyy hh24:mi');
    v_dtetimpst   := to_date(to_char(p_dtepstr,'dd/mm/yyyy')||' '||p_timpstr,'dd/mm/yyyy hh24:mi');
    v_dtetimpen   := to_date(to_char(p_dtepend,'dd/mm/yyyy')||' '||p_timpend,'dd/mm/yyyy hh24:mi');

    if v_dtetimst > v_dtetimen then
      param_msg_error  := get_error_msg_php('HR2021',global_v_lang, p_key_row);
      return;
    end if;

    if (v_dtetimst not between v_dtetimpst and v_dtetimpen) or (v_dtetimen not between v_dtetimpst and v_dtetimpen) then
      param_msg_error  := get_error_msg_php('HR2047',global_v_lang, p_key_row);
      return;
    end if;
    --
  end check_save;

  procedure save_data(json_str_output out clob) as
    json_obj           json_object_t;
    json_children      json_object_t;
    json_children_data json_object_t;
    v_dtework          date;
    v_codempid         temploy1.codempid%type;
    v_flg              varchar2(10 char);
    v_flg_child        varchar2(10 char);
    v_codshift         tattence.codshift%type;
    v_dtein            date;
    v_timin            tattence.timin%type;
    v_dteout           date;
    v_timout           tattence.timout%type;
    v_typot            tovrtime.typot%type;
    v_staappr          varchar2(2 char);
    v_dtestr           date;
    v_timstr           tattence.timin%type;
    v_dteend           date;
    v_timend           tattence.timout%type;
    v_qtyminot         totpaydt.qtyminot%type;
    v_ratex            number;
    v_amtmeal          number;
    v_qtyleave         number;
    v_codrem           tovrtime.codrem%type;
    v_codcompw         tovrtime.codcompw%type;
    v_count            number;
    v_key_row          varchar2(1000 char);

    v_qtyminot_pay      totpaydt.qtyminot%type;

  begin
    v_dteupd_log  := sysdate;
    for i in 0..param_json.get_size-1 loop
      json_obj      := hcm_util.get_json_t(param_json,to_char(i));
      v_dtework     := to_date(hcm_util.get_string_t(json_obj,'dtework'),'dd/mm/yyyy');
      v_codempid    := hcm_util.get_string_t(json_obj,'codempid');
      v_flg         := hcm_util.get_string_t(json_obj,'flg');
      json_children := hcm_util.get_json_t(json_obj,'children');
      v_codshift := hcm_util.get_string_t(json_obj,'codshift');
      v_dtein    := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'dtetimin' ));
      v_timin    := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'dtetimin' ));
      v_dteout   := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_obj,'dtetimout'));
      v_timout   := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_obj,'dtetimout'));
      if v_flg = 'edit' then
        edit_tattence(v_codempid,v_dtework,v_codshift,v_dtein,v_timin,v_dteout,v_timout);
      end if;
      for j in 0..json_children.get_size-1 loop
        json_children_data := hcm_util.get_json_t(json_children,to_char(j));
        v_typot            := hcm_util.get_string_t(json_children_data,'typot');
        v_flg_child        := hcm_util.get_string_t(json_children_data,'flg');
        if v_typot is null then
          param_msg_error  := get_error_msg_php('HR2045',global_v_lang,'typot');
          return;
        end if;
        if v_flg_child = 'edit' then
          v_staappr := hcm_util.get_string_t(json_children_data,'flgStaappr');

          if v_staappr = 'A' then
            v_dtestr   := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_children_data,'dtetimstr'));
            v_timstr   := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_children_data,'dtetimstr'));
            v_dteend   := hcm_util.convert_dtetime_to_date(hcm_util.get_string_t(json_children_data,'dtetimend'));
            v_timend   := hcm_util.convert_dtetime_to_time(hcm_util.get_string_t(json_children_data,'dtetimend'));
            v_qtyminot := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_children_data,'qtyminot'));
            v_amtmeal  := to_number(hcm_util.get_string_t(json_children_data,'amtmeal'));
            v_qtyleave := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_children_data,'qtyleave'));
            v_codrem   := hcm_util.get_string_t(json_children_data,'codrem');
            v_codcompw := hcm_util.get_string_t(json_children_data,'codcompw');
            p_flgtypot := hcm_util.get_string_t(json_children_data,'flgtypot');
            v_count := 0;
            if p_flgtypot = 'Y' then
                v_qtyleave := 0;
            end if;
            v_key_row   := get_label_name('HRAL4KE1', global_v_lang, 50)||' '||v_codempid||' '||get_label_name('HRAL4KE1', global_v_lang, 90)||' '||to_char(v_dtework,'dd/mm/yyyy');
            check_save (v_key_row,v_dtestr,v_timstr,v_dteend,v_timend,v_dtein,v_timin,v_dteout,v_timout);
            if param_msg_error is not null then
              return;
            end if;
            --

            --
            begin
                select  count(*)
                  into  v_count
                  from  tovrtime
                  where  dtework = v_dtework
                    and  codempid = v_codempid
                    and  typot = v_typot
                    and  flgotcal = 'Y';
            exception when others then
                v_count := 0;
            end;
            if v_count = 0 then
                edit_OT(v_codempid ,v_dtework  ,v_typot   ,
                        v_dtestr   ,v_timstr   ,v_dteend  ,
                        v_timend   ,v_qtyminot ,json_children_data  ,
                        v_ratex    ,v_amtmeal  ,v_qtyleave,
                        v_codrem   ,v_codcompw);
              begin
                select nvl(sum(nvl(qtyminot,0)),0)
                  into v_qtyminot_pay
                  from totpaydt
                 where codempid = v_codempid
                   and dtework  = v_dtework
                   and typot	= v_typot;
              exception when no_data_found then
                v_qtyminot  := 0;
                v_qtyleave  := 0;
              end;


              if p_flgtypot = 'Y' then
                if v_amtmeal is null or v_amtmeal = 0 then
                  if v_qtyminot <> v_qtyminot_pay then
                      param_msg_error     := get_error_msg_php('AL0072', global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                      return;
                  end if;
                end if;
              else
                if v_qtyminot < v_qtyleave then
                    param_msg_error     := get_error_msg_php('AL0073', global_v_lang);
                    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                     return;
                end if;
              end if;
            else
                null;
            end if;
          elsif v_staappr is null then
            cancel_ot(v_codempid,v_dtework,v_typot);
          end if;
        end if;
        if param_msg_error is not null then
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
        end if;
      end loop;
      if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure cancel_ot (v_codempid in varchar2,v_dtework in date,v_typot in varchar2)as
    v_codcomp     temploy1.codcomp%TYPE;
    v_codcalen    temploy1.codcalen%TYPE;
    v_typpayroll  temploy1.typpayroll%TYPE;
    v_numrec      number;
    v_error       terrorm.errorno%type;
    v_err_table   varchar2(50 char);
    cursor c_totpaydt is
      select  dtework,typot,rteotpay,qtyminot
        from  totpaydt
       where  codempid = v_codempid
         and  dtework  = v_dtework
         and  typot    = v_typot
    order by  rteotpay;
    cursor c_tovrtime is
      select typot,dtestrt,timstrt,dteend,timend,stddec(amtmeal,codempid,global_v_chken) amtmeal,qtyleave
        from tovrtime
       where codempid = v_codempid
         and dtework  = v_dtework
         and typot    = v_typot;
  begin
    begin
      select  codcomp,codcalen,typpayroll
        into  v_codcomp,v_codcalen,v_typpayroll
        from  temploy1
       where  codempid = v_codempid;
    exception when no_data_found then
      v_codcomp := '';
      v_codcalen := '';
      v_typpayroll := '';
    end;

    for i in c_totpaydt loop
      if i.qtyminot > 0 then
        begin
          insert into tlogot2(codempid,dtetimupd,dtework,typot,
                              rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                       values(v_codempid,v_dteupd_log,i.dtework,i.typot,
                              i.rteotpay,i.qtyminot,null,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      end if;
    end loop;
    for i in c_tovrtime loop
      begin
        insert into tlogot(codempid,dtetimupd,dtework,typot,codcomp,
                           dtestoto,timstoto,dteenoto,timenoto,amtmealo,qtyleaveo,coduser)
                    values(v_codempid,v_dteupd_log,v_dtework,i.typot,v_codcomp,
                           i.dtestrt,i.timstrt,i.dteend,i.timend,stdenc(i.amtmeal,v_codempid,global_v_chken),decode(i.qtyleave,0,null,i.qtyleave),global_v_coduser);
     exception when dup_val_on_index then null;
      end;
    end loop;
    delete  tovrtime
     where  codempid = v_codempid
       and  dtework  = v_dtework
       and  typot    = v_typot;
    delete  totpaydt
     where  codempid = v_codempid
       and  dtework  = v_dtework
       and  typot    = v_typot;
    hral85b_batch.gen_compensate(v_codempid,v_codcomp,v_codcalen,v_typpayroll,v_dtework,global_v_coduser,
                                 v_numrec,v_error,v_err_table);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end cancel_ot;

  procedure edit_tattence (v_codempid in varchar2 ,v_dtework in date    ,v_codshift in varchar2,
                           v_dtein    in date     ,v_timin   in varchar2,
                           v_dteout   in date     ,v_timout  in varchar2) as
    v_codcomp    tattence.codcomp%type;
    v_o_dtein    date;
    v_o_timin    tattence.timin%type;
    v_o_dteout   date;
    v_o_timout   tattence.timout%type;
    v_n_dtein    date;
    v_n_timin    tattence.timin%type;
    v_n_dteout   date;
    v_n_timout   tattence.timout%type;
    v_codchng    tattence.codchng%type;
    v_qtynostam  tattence.qtynostam%type;
    v_o_codshift tattence.codshift%type;
    v_n_codshift tattence.codshift%type;
    v_typwork    tattence.typwork%type;
    v_codcalen   tattence.codcalen%type;
    v_flgatten   tattence.flgatten%type;
    v_timstrtw   tshiftcd.timstrtw%type;
    v_timendw    tshiftcd.timendw%type;
    v_dtestrtw   date;
    v_dteendw    date;
  begin
    begin
      begin
        select  codcomp      ,dtein        ,
                timin        ,dteout       ,
                timout       ,codchng      ,
                qtynostam    ,codshift     ,
                typwork      ,codcalen     ,
                flgatten
          into  v_codcomp    ,v_o_dtein    ,
                v_o_timin    ,v_o_dteout   ,
                v_o_timout   ,v_codchng    ,
                v_qtynostam  ,v_o_codshift ,
                v_typwork    ,v_codcalen   ,
                v_flgatten
          from  tattence
         where  codempid = v_codempid
           and  dtework  = v_dtework;
        v_n_dtein    := v_dtein;
        v_n_timin    := v_timin;
        v_n_dteout   := v_dteout;
        v_n_timout   := v_timout;
        v_n_codshift := v_codshift;
        if v_o_dtein = v_dtein then
          v_o_dtein := '';
          v_n_dtein := '';
        end if;
        if v_o_timin = v_timin then
          v_o_timin := '';
          v_n_timin := '';
        end if;
        if v_o_dteout = v_dteout then
          v_o_dteout := '';
          v_n_dteout := '';
        end if;
        if v_o_timout = v_timout then
          v_o_timout := '';
          v_n_timout := '';
        end if;
        if v_o_codshift = v_codshift then
          v_o_codshift := '';
          v_n_codshift := '';
        end if;
        begin
          insert into tlogtime(codempid    ,dtework     ,dteupd ,
                               codshift    ,coduser     ,codcomp,
                               dteinold    ,timinold    ,
                               dteoutold   ,timoutold   ,
                               dteinnew    ,timinnew    ,
                               dteoutnew   ,timoutnew   ,
                               codchngold  ,codchngnew  ,
                               qtynostamo  ,qtynostamn  ,
                               codshifold  ,codshifnew  ,
                               typworkold  ,typworknew  ,
                               codcalenold ,codcalennew ,
                               flgattenold ,flgattennew ,
                               codcreate
                               )
                        values(v_codempid  ,v_dtework   ,sysdate,
                               v_codshift  ,global_v_coduser,v_codcomp,
                               v_o_dtein   ,v_o_timin   ,
                               v_o_dteout  ,v_o_timout  ,
                               v_n_dtein     ,v_n_timin     ,
                               v_n_dteout    ,v_n_timout    ,
                               v_codchng   ,v_codchng   ,
                               v_qtynostam ,v_qtynostam ,
                               v_o_codshift,v_n_codshift  ,
                               v_typwork   ,v_typwork   ,
                               v_codcalen  ,v_codcalen  ,
                               v_flgatten  ,v_flgatten  ,
                               global_v_coduser
                               );
        exception when dup_val_on_index then null;
        end;
      exception when no_data_found then null;
      end;
      v_dtestrtw := v_dtework;
      v_dteendw := v_dtework;
      begin
        select timstrtw, timendw
          into v_timstrtw, v_timendw
          from tshiftcd
         where codshift = v_codshift;
        if to_number(v_timstrtw) > to_number(v_timendw) then
          v_dteendw := v_dteendw + 1;
        end if;
      exception when no_data_found then
        v_timstrtw := '';
        v_timendw := '';
      end;
      update tattence
         set codshift = v_codshift,
             dtein    = v_dtein,
             timin    = v_timin,
             dteout   = v_dteout,
             timout   = v_timout,
             dtestrtw = v_dtestrtw,
             dteendw  = v_dteendw,
             timstrtw = v_timstrtw,
             timendw  = v_timendw,
             coduser  = global_v_coduser,
             dteupd   = sysdate
       where codempid = v_codempid
         and dtework  = v_dtework;
    exception when others then null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end edit_tattence;

  procedure edit_OT (v_codempid in varchar2 ,v_dtework  in date     ,v_typot    in varchar2 ,
                     v_dtestr   in date     ,v_timstr   in varchar2 ,v_dteend   in date     ,
                     v_timend   in varchar2 ,v_qtyminot in number   ,v_rate     json_object_t        ,
                     v_ratex    in number   ,v_amtmeal  in number   ,v_qtyleave in number   ,
                     v_codrem   in varchar2 ,v_codcompw in varchar2) as
    v_codcompy    tcenter.codcompy%type;
    v_codcomp     tcenter.codcomp%type;
    v_dteeffec    tcontrot.dteeffec%type;
    v_condot      tcontrot.condot%type;
    v_condextr    tcontrot.condextr%type;
    v_dtein       tattence.dtein%type;
    v_dteout      tattence.dteout%type;
    v_timin       tattence.timin%type;
    v_timout      tattence.timout%type;
    v_codcalen    tattence.codcalen%type;
    v_typwork     tattence.typwork%type;
    v_codshift    tattence.codshift%type;
    v_a_tovrtime  tovrtime%rowtype;
    v_dtestr2     tovrtime.dtestrt%type;
    v_timstr2     tovrtime.timstrt%type;
    v_dteend2     tovrtime.dteend%type;
    v_timend2     tovrtime.timend%type;
    v_a_rteotpay  hral85b_batch.a_rteotpay;
    v_a_qtyminot  hral85b_batch.a_qtyminot;
    v_typpayroll  temploy1.typpayroll%type;
    v_flgmeal     varchar2(1 char) := 'N';
    v_chken       varchar2(10 char) := hcm_secur.get_v_chken;
    v_numrec      number;
    v_error       terrorm.errorno%type;
    v_err_table   varchar2(50 char);
    v_codappr     tovrtime.codappr%type;
    v_dteappr     date;

    v_tovrtime_o    tovrtime%rowtype;
    v_dtestr_n     tovrtime.dtestrt%type;
    v_timstr_n     tovrtime.timstrt%type;
    v_dteend_n     tovrtime.dteend%type;
    v_timend_n     tovrtime.timend%type;
    v_amtmeal_n    tovrtime.amtmeal%type;
    v_qtyleave_n   tovrtime.qtyleave%type;
    v_codcompw_n   tovrtime.codcompw%type;
  begin
    v_codappr := hcm_util.get_string_t(v_rate,'codappr');
    v_dteappr := to_date(hcm_util.get_string_t(v_rate,'dteappr'),'dd/mm/yyyy');
    begin
      select *
        into v_tovrtime_o
        from tovrtime
       where codempid   = v_codempid
         and dtework    = v_dtework
         and typot      = v_typot
         and flgotcal   = 'N';
    exception when no_data_found then v_tovrtime_o := null;
    end;
    if v_amtmeal is not null then
      v_flgmeal := 'Y';
    end if;
    begin
      select  t1.codcompy,t1.codcomp
        into  v_codcompy,v_codcomp
        from  tcenter t1,temploy1 t2
       where  t1.codcomp  = t2.codcomp
         and  t2.codempid = v_codempid;
      begin
        select  --to_char(dteeffec,'dd/mm/yyyy')
                dteeffec,condot,condextr
          into  v_dteeffec,v_condot,v_condextr
          from  tcontrot
         where  codcompy = v_codcompy
           and  dteeffec = (select  max(dteeffec)
                              from  tcontrot
                             where  codcompy = v_codcompy
                               and  dteeffec < sysdate)
           and  rownum <= 1;
      exception when no_data_found then null;
        v_dteeffec := null;
        v_condot   := '';
        v_condextr := '';
      end;
    exception when others then null;
    end;
      begin
        select  dtein  ,dteout  ,timin  ,timout  ,codcalen  ,typwork  ,codshift
          into  v_dtein,v_dteout,v_timin,v_timout,v_codcalen,v_typwork,v_codshift
          from  tattence
         where  dtework  = v_dtework
           and  codempid = v_codempid;
      exception when others then null;
      end;
      -- gen qtyleave
      hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                              null,v_codempid,v_dtework,v_typot,v_codshift,
                              v_dtein,v_timin,v_dteout,v_timout,
                              v_dtestr2,v_timstr2,v_dteend2,v_timend2,null,
                              null,null,null,global_v_coduser,'Y',
                              v_a_tovrtime,v_a_rteotpay,v_a_qtyminot);
      begin
        select  typpayroll
          into  v_typpayroll
          from  temploy1
         where  codempid = v_codempid;
      exception when others then null;
      end;
      begin
        begin
          insert into tovrtime(codempid           ,dtework            ,typot            ,codcomp          ,
                               typpayroll         ,codcalen           ,codshift         ,typwork          ,
                               dtestrt            ,timstrt            ,dteend           ,timend           ,
                               qtyminot           ,flgmeal            ,amtmeal          ,qtyleave         ,
                               codrem             ,flgotcal           ,codappr          ,dteappr          ,
                               flgadj             ,codcompw           ,coduser          ,numotreq         ,
                               qtydedbrk          ,amtothr            ,amtottot         ,codcreate)
                        values(v_codempid         ,v_dtework          ,v_typot          ,v_codcomp        ,
                               v_typpayroll       ,v_codcalen         ,v_codshift       ,v_typwork        ,
                               v_dtestr           ,v_timstr           ,v_dteend         ,v_timend         ,
                               v_qtyminot                      ,v_flgmeal,
                               stdenc(v_amtmeal,v_codempid,v_chken)             ,
                               v_qtyleave,
                               v_codrem           ,'N'                ,v_codappr         ,v_dteappr          ,
                               'Y'                ,v_codcompw         ,global_v_coduser ,v_a_tovrtime.numotreq,
                               v_a_tovrtime.qtydedbrk                 ,v_a_tovrtime.amtothr               ,
                               v_a_tovrtime.amtottot                  ,global_v_coduser);
        exception when dup_val_on_index then
          update tovrtime
             set codcomp    = v_codcomp,
                 typpayroll = v_typpayroll,
                 codcalen   = v_codcalen,
                 codshift   = v_codshift,
                 typwork    = v_typwork,
                 numotreq   = v_a_tovrtime.numotreq,
                 dtestrt    = v_dtestr,
                 timstrt    = v_timstr,
                 dteend     = v_dteend,
                 timend     = v_timend,
                 qtyminot   = v_qtyminot,
                 qtydedbrk  = v_a_tovrtime.qtydedbrk,
                 amtothr    = v_a_tovrtime.amtothr,
                 amtottot   = v_a_tovrtime.amtottot,
                 flgmeal    = v_flgmeal,
                 amtmeal    = stdenc(v_amtmeal,v_codempid,v_chken),
                 qtyleave   = nvl(v_qtyleave,0),
                 codrem     = v_codrem,
                 flgotcal   = 'N',
                 flgadj     = 'Y', -- SEA-Chai
                 codappr    = v_codappr,
                 dteappr    = v_dteappr,
                 codcompw   = v_codcompw,
                 dteupd     = sysdate,
                 coduser    = global_v_coduser
           where codempid   = v_codempid
             and dtework    = v_dtework
             and typot      = v_typot
             and flgotcal   = 'N';
        end;
        v_dtestr_n  := v_dtestr;
        if v_tovrtime_o.dtestrt = v_dtestr then
          v_tovrtime_o.dtestrt := '';
          v_dtestr_n  := '';
        end if;
        v_timstr_n  := v_timstr;
        if v_tovrtime_o.timstrt = v_timstr then
          v_tovrtime_o.timstrt := '';
          v_timstr_n  := '';
        end if;
        --
        v_dteend_n  := v_dteend;
        if v_tovrtime_o.dteend = v_dteend then
          v_tovrtime_o.dteend := '';
          v_dteend_n  := '';
        end if;
        v_timend_n  := v_timend;
        if v_tovrtime_o.timend = v_timend then
          v_tovrtime_o.timend := '';
          v_timend_n  := '';
        end if;

        v_amtmeal_n  := v_amtmeal;
        v_qtyleave_n  := v_qtyleave;
        v_codcompw_n  := v_codcompw;
        if stddec(v_tovrtime_o.amtmeal,v_codempid,v_chken) = v_amtmeal then
          v_tovrtime_o.amtmeal := '';
          v_amtmeal_n  := '';
        end if;
        if v_tovrtime_o.codcompw = v_codcompw then
          v_tovrtime_o.codcompw := '';
          v_codcompw_n  := '';
        end if;
        begin
          insert into tlogot(codempid   ,dtetimupd ,dtework  ,typot    ,codcomp  ,
                             dtestoto   ,timstoto  ,dteenoto ,timenoto ,amtmealo ,qtyleaveo, codcompwo,
                             dtestotn   ,timstotn  ,dteenotn ,timenotn ,amtmealn ,qtyleaven, codcompwn,
                             coduser)
                      values(v_codempid ,v_dteupd_log   ,v_dtework,v_typot  ,v_codcomp,
                             v_tovrtime_o.dtestrt  ,v_tovrtime_o.timstrt  ,v_tovrtime_o.dteend ,v_tovrtime_o.timend ,v_tovrtime_o.amtmeal ,decode(v_tovrtime_o.qtyleave,0,null,v_tovrtime_o.qtyleave), v_tovrtime_o.codcompw,
                             v_dtestr_n   ,v_timstr_n  ,v_dteend_n ,v_timend_n ,stdenc(v_amtmeal_n,v_codempid,v_chken),decode(v_qtyleave_n,0,null,v_qtyleave_n),v_codcompw_n,
                             global_v_coduser);
        exception when dup_val_on_index then null;
        end;

        insert_totpaydt(v_codempid,v_dtework,v_typot,v_rate);
      exception when others then null;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        return;
      end;
      hral85b_batch.gen_compensate(v_codempid,v_codcomp,v_codcalen,v_typpayroll,v_dtework,global_v_coduser,
                                   v_numrec  ,v_error  ,v_err_table);
      if v_error is not null then
        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_err_table);
        return;
      end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end edit_OT;

  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_ot_head;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_ot_head;
    if param_msg_error is null then
      gen_ot_head(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
    json_obj            json_object_t    := json_object_t();
    json_row            json_object_t;
    v_codcompy          tcenter.codcomp%type;
    v_index             number  := 0;
    v_rteotpay          number  := 0;
    cursor c1 is
      select distinct(rteotpay) rteotpay
        from totratep2
       where codcompy = nvl(v_codcompy,codcompy)
    order by rteotpay;
  begin
    json_row := json_object_t();
    if p_codcomp is null then
      begin
        select  hcm_util.get_codcomp_level(codcomp,1)
          into  v_codcompy
          from  temploy1
          where  codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    else
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    end if;
    for r1 in c1 loop
      v_rteotpay  :=  r1.rteotpay;
--      if v_index = 5 then
--        exit;
--      end if;
      json_row.put('rate' || to_char(v_index),to_char(v_rteotpay));
      v_index := v_index + 1;
    end loop;
    json_obj.put('otrate', json_row);
    json_obj.put('otrate_size', v_index);
    json_obj.put('coderror', '200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_ot_head;

  procedure get_cost_center(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codcomp     tcenter.codcomp%type;
    v_total       number := 0;
  begin
    v_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('desc_costcenter', gen_codcenter(v_codcomp));
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_cost_center;

  function gen_codcenter (v_codcomp in varchar2) return varchar2 as
    v_codcenter         tcenter.costcent%type;
  begin
    begin
      select costcent into v_codcenter
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;
    return v_codcenter;
  end gen_codcenter;

  procedure get_OT (json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_OT;
  if param_msg_error is null then
    gen_OT(json_str_output);
  end if;
  if param_msg_error is not null then
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_OT;

  procedure check_OT as
  begin
    if p_typot is not null and not (p_typot = 'B' or p_typot = 'D' or p_typot = 'A') then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_typot');
      return;
    end if;
    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end check_OT;

  procedure gen_OT (json_str_output out clob) as
    json_row      json_object_t := json_object_t();
    v_codcompy    tcenter.codcomp%type;
    v_dteeffec    date;
    v_condot      tcontrot.condot%type;
    v_condextr    tcontrot.condextr%type;
    v_a_tovrtime  tovrtime%rowtype;
    v_a_rteotpay  hral85b_batch.a_rteotpay;
    v_a_qtyminot  hral85b_batch.a_qtyminot;
    v_rteotpay    number;
    v_qtyminotx   number;
    v_qtyminot    number;
    v_ratenum     number;
    v_token       number;
    v_countpaydt  number;
    v_token2      varchar2(20 char);
    v_typot         tovrtime.typot%type;
    v_desc_typot    varchar2(150 char);
    v_dtestrt       tovrtime.dtestrt%type;
    v_dteend        tovrtime.dteend%type;
    v_timstrt       tovrtime.timstrt%type;
    v_timend        tovrtime.timend%type;
    v_qtydedbrk     tovrtime.qtydedbrk%type;
    v_flgotcal      tovrtime.flgotcal%type;
    v_desc_flgotcal varchar2(150 char);
    v_amtmeal       tovrtime.amtmeal%type;
    v_qtyleave      tovrtime.qtyleave%type;
    v_codrem        tovrtime.codrem%type;
    v_codappr       tovrtime.codappr%type;
    v_dteappr       tovrtime.dteappr%type;
    v_numotreq      tovrtime.numotreq%type;
    v_desc_codcompw tcenter.namcente%type;
    v_codcompw      tovrtime.codcompw%type;
    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = p_codempid
    order by t1.rteotpay;
  begin
    begin
      select  t1.codcompy
        into  v_codcompy
        from  tcenter t1,temploy1 t2
       where  t1.codcomp  = t2.codcomp
         and  t2.codempid = p_codempid;
    exception when no_data_found then null;
      v_codcompy := '';
    end;
    begin
      select  dteeffec,condot,condextr
        into  v_dteeffec,v_condot,v_condextr
        from  tcontrot
       where  codcompy = v_codcompy
         and  dteeffec = (select  max(dteeffec)
                            from  tcontrot
                           where  codcompy = v_codcompy
                             and  dteeffec < sysdate)
         and  rownum <= 1;
    exception when no_data_found then
      v_dteeffec := null;
      v_condot   := '';
      v_condextr := '';
    end;
    begin
      select typot      , dtestrt    , dteend    , timstrt   , timend  ,
             qtydedbrk  , qtyminot   , flgotcal  , amtmeal   , qtyleave,
             codrem     , codappr    , dteappr   , numotreq  , codcompw
        into v_typot    , v_dtestrt  , v_dteend  , v_timstrt , v_timend  ,
             v_qtydedbrk, v_qtyminot , v_flgotcal, v_amtmeal , v_qtyleave,
             v_codrem   , v_codappr  , v_dteappr , v_numotreq, v_codcompw
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = p_typot
         ;
      --
      hral85b_batch.cal_time_ot (v_codcompy   ,v_dteeffec   ,v_condot     ,v_condextr   ,null         ,p_codempid   ,
                                 p_dtework    ,p_typot      ,p_codshift   ,p_dtein      ,p_timin      ,p_dteout     ,
                                 p_timout     ,p_dtestr     ,p_timstrt    ,p_dteend     ,p_timend     ,p_qtyotmin   ,
                                 null         ,null         ,null         ,null         ,'Y',
                                 v_a_tovrtime ,v_a_rteotpay ,v_a_qtyminot );
      --
      json_row.put('typot'         ,v_typot);
      json_row.put('desc_typot'    ,get_tlistval_name(p_codapp,v_typot,global_v_lang));
--      json_row.put('dtestrt'       ,to_char(v_dtestrt,'dd/mm/yyyy'));
--      json_row.put('dteend'        ,to_char(v_dteend ,'dd/mm/yyyy'));
--      json_row.put('timstrt'       ,to_char(to_date(v_timstrt,'hh24mi'),'hh24:mi'));
--      json_row.put('timend'        ,to_char(to_date(v_timend ,'hh24mi'),'hh24:mi'));
--      json_row.put('dtetimstr'     ,hcm_util.convert_date_time_to_dtetime(v_dtestrt,v_timstrt));
--      json_row.put('dtetimend'     ,hcm_util.convert_date_time_to_dtetime(v_dteend ,v_timend ));
      json_row.put('dtestrt'       ,to_char(p_dtestr ,'dd/mm/yyyy'));
      json_row.put('dteend'        ,to_char(p_dteend ,'dd/mm/yyyy'));
      json_row.put('timstrt'       ,to_char(to_date(p_timstrt,'hh24mi'),'hh24:mi'));
      json_row.put('timend'        ,to_char(to_date(p_timend ,'hh24mi'),'hh24:mi'));
      json_row.put('dtetimstr'     ,hcm_util.convert_date_time_to_dtetime(p_dtestr ,p_timstrt));
      json_row.put('dtetimend'     ,hcm_util.convert_date_time_to_dtetime(p_dteend ,p_timend ));

      hcm_util.cal_dhm_hm (0,0,v_qtydedbrk,null,'2',v_token,v_token,v_token,v_token2);
--      json_row.put('qtydedbrk',v_token2);
--      json_row.put('qtyminot'      ,hcm_util.convert_minute_to_hour(nvl(v_qtyminot ,0)));
--      json_row.put('amtmeal'       ,nvl(to_number(stddec(v_amtmeal,p_codempid,hcm_secur.get_v_chken)),0));
--      json_row.put('qtyleave'      ,hcm_util.convert_minute_to_hour(v_qtyleave));
      json_row.put('qtydedbrk'     ,hcm_util.convert_minute_to_hour(nvl(v_a_tovrtime.qtydedbrk,0)));
      json_row.put('qtyminot'      ,hcm_util.convert_minute_to_hour(nvl(v_a_tovrtime.qtyminot,0)));
      json_row.put('amtmeal'       ,nvl(to_number(stddec(v_a_tovrtime.amtmeal,p_codempid,hcm_secur.get_v_chken)),0));
      json_row.put('qtyleave'      ,hcm_util.convert_minute_to_hour(v_a_tovrtime.qtyleave));
      --
      json_row.put('flgotcal'      ,v_flgotcal);
      json_row.put('desc_flgotcal' ,get_tlistval_name(p_codapp,v_flgotcal,global_v_lang));
      json_row.put('codrem'        ,v_codrem);
      json_row.put('codappr'       ,v_codappr);
      json_row.put('dteappr'       ,to_char(v_dteappr,'dd/mm/yyyy'));
      json_row.put('numotreq'      ,v_numotreq);
      json_row.put('desc_codcompw' ,get_tcenter_name(v_codcompw,global_v_lang));
      json_row.put('codcompw'      ,v_codcompw);
      json_row.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_codcompw, null, '', 'Y')));
      select count(codempid)
       into v_countpaydt
       from totpaydt
      where codempid = p_codempid
        and dtework  = p_dtework
        and typot    = p_typot;

      if v_countpaydt  > 0 or to_number(stddec(v_amtmeal,p_codempid,hcm_secur.get_v_chken)) > 0 then
        json_row.put('flgtypot','Y');
      else
        json_row.put('flgtypot','N');
      end if;
      v_ratenum := 0;
      v_qtyminot := 0;
      -- Don't rely delete
--      for r_rteotpay in c_rteotpay loop
--        v_qtyminotx := 0;
--        begin
--          select sum(qtyminot)
--            into v_qtyminotx
--            from totpaydt
--           where codempid = p_codempid
--             and dtework  = p_dtework
--             and typot    = p_typot
--             and rteotpay = r_rteotpay.rteotpay;
--        exception when no_data_found then null;
--        end;
--        v_qtyminot := v_qtyminot + v_qtyminotx;
--        hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
--        v_ratenum := v_ratenum + 1;
--        json_row.put('rate' || to_char(v_ratenum),v_token2);
--      end loop;
--      json_row.put('numrate',v_ratenum);
      --
      for r_rteotpay in c_rteotpay loop
        v_qtyminotx := 0;
        for i in 1..p_rateotcount loop
          if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
            v_rteotpay := v_a_rteotpay(i);
            v_qtyminot := v_a_qtyminot(i);
            if v_rteotpay = r_rteotpay.rteotpay then
              v_qtyminotx := v_qtyminotx + v_qtyminot;
            end if;
          end if;
        end loop;
        hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
        v_ratenum := v_ratenum + 1;
        json_row.put('rate' || to_char(v_ratenum),v_token2);
      end loop;
      json_row.put('numrate',v_ratenum);
      --
      v_qtyminotx := 0;
      begin
        select sum(qtyminot)
          into v_qtyminotx
          from totpaydt
         where codempid = p_codempid
           and dtework  = p_dtework
           and typot    = p_typot;
        v_qtyminotx := v_qtyminotx - v_qtyminotx;
      exception when no_data_found then null;
      end;
      hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
      json_row.put('ratex',v_token2);
    exception when no_data_found then
      hral85b_batch.cal_time_ot (v_codcompy   ,v_dteeffec   ,v_condot     ,v_condextr   ,null         ,p_codempid   ,
                                 p_dtework    ,p_typot      ,p_codshift   ,p_dtein      ,p_timin      ,p_dteout     ,
                                 p_timout     ,p_dtestr     ,p_timstrt    ,p_dteend     ,p_timend     ,p_qtyotmin   ,
                                 null         ,null         ,null         ,null         ,'Y',
                                 v_a_tovrtime ,v_a_rteotpay ,v_a_qtyminot );
      json_row.put('typot'         ,p_typot);
      json_row.put('desc_typot'    ,get_tlistval_name(p_codapp,p_typot,global_v_lang));
      json_row.put('dtestrt'       ,to_char(p_dtestr ,'dd/mm/yyyy'));
      json_row.put('dteend'        ,to_char(p_dteend ,'dd/mm/yyyy'));
      json_row.put('timstrt'       ,to_char(to_date(p_timstrt,'hh24mi'),'hh24:mi'));
      json_row.put('timend'        ,to_char(to_date(p_timend ,'hh24mi'),'hh24:mi'));
      json_row.put('dtetimstr',hcm_util.convert_date_time_to_dtetime(p_dtestr ,p_timstrt));
      json_row.put('dtetimend',hcm_util.convert_date_time_to_dtetime(p_dteend ,p_timend ));
      if v_a_tovrtime.typot is not null then
        json_row.put('qtydedbrk'     ,hcm_util.convert_minute_to_hour(nvl(v_a_tovrtime.qtydedbrk,0)));
        json_row.put('qtyminot'      ,hcm_util.convert_minute_to_hour(nvl(v_a_tovrtime.qtyminot,0)));
        json_row.put('amtmeal'       ,nvl(to_number(stddec(v_a_tovrtime.amtmeal,p_codempid,hcm_secur.get_v_chken)),0));
        json_row.put('qtyleave'      ,hcm_util.convert_minute_to_hour(v_a_tovrtime.qtyleave));
        json_row.put('flgotcal'      ,'');
        json_row.put('desc_flgotcal' ,get_tlistval_name(p_codapp,'',global_v_lang));
        json_row.put('codrem'        ,v_a_tovrtime.codrem);
        json_row.put('codappr'       ,v_a_tovrtime.codappr);
        json_row.put('dteappr'       ,to_char(v_a_tovrtime.dteappr,'dd/mm/yyyy'));
        json_row.put('numotreq'      ,v_a_tovrtime.numotreq);
        json_row.put('desc_codcompw' ,get_tcenter_name(v_a_tovrtime.codcompw,global_v_lang));
        json_row.put('codcompw'      ,v_a_tovrtime.codcompw);
        json_row.put('codcompgl'     , gen_codcenter(hcm_util.get_codcomp_level(v_a_tovrtime.codcompw, null, '', 'Y')));
        json_row.put('flgtypot'      ,'Y');
        v_ratenum := 1;
        for r_rteotpay in c_rteotpay loop
          v_qtyminotx := 0;
          for i in 1..p_rateotcount loop
            if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
              v_rteotpay := v_a_rteotpay(i);
              v_qtyminot := v_a_qtyminot(i);
              if v_rteotpay = r_rteotpay.rteotpay then
                v_qtyminotx := v_qtyminotx + v_qtyminot;
              end if;
            end if;
          end loop;
          hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
          json_row.put('rate' || to_char(v_ratenum),v_token2);
          v_ratenum := v_ratenum + 1;
        end loop;
        json_row.put('numrate',v_ratenum-1);
        v_qtyminotx := 0;
        for i in 1..p_rateotcount loop
          v_qtyminot := v_a_qtyminot(i);
          for r_rteotpay in c_rteotpay loop
            if v_a_rteotpay(i) is not null and v_a_qtyminot(i) is not null then
              v_qtyminot := 0;
            end if;
          end loop;
          v_qtyminotx := v_qtyminotx + v_qtyminot;
        end loop;
        hcm_util.cal_dhm_hm (0,0,v_qtyminotx,null,'2',v_token,v_token,v_token,v_token2);
        json_row.put('ratex',v_token2);
      end if;
    end;
    json_row.put('coderror','200');
    json_str_output := json_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end gen_OT;

  procedure insert_tlogot2 (v_codempid varchar2,v_dtework date,v_typot varchar2,v_rate json_object_t) as
    v_index     number := 1;
    v_rteotpay  number;
    v_qtyminoto number;
    v_qtyminotn number;
    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = v_codempid
    order by t1.rteotpay;
  begin
    for r_rteotpay in c_rteotpay loop
      v_rteotpay  := r_rteotpay.rteotpay;
      v_qtyminotn := nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(v_rate,'rate'||to_char(v_index))),0);

      if v_qtyminotn > 0 then
        begin
          insert into tlogot2(codempid,dtetimupd,
                              dtework,typot,
                              rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                       values(v_codempid,v_dteupd_log,
                              v_dtework,v_typot,
                              v_rteotpay,null,v_qtyminotn,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then null;
        end;
      end if;
      v_index := v_index + 1;
    end loop;
  end insert_tlogot2;

  procedure insert_totpaydt (v_codempid varchar2,v_dtework date,v_typot varchar2,v_rate json_object_t) as
    v_index     number := 1;
    v_rteotpay  number;
    v_qtyminoto number;
    v_qtyminotn number;
    v_log_qtyminoto number;
    v_log_qtyminotn number;
    cursor c_rteotpay is
      select distinct(t1.rteotpay) rteotpay
        from totratep2 t1,temploy1 t2,tcenter t3
       where t1.codcompy = t3.codcompy
         and t2.codcomp  = t3.codcomp
         and t2.codempid = v_codempid
    order by t1.rteotpay;
--    cursor c_rteotpay is
--      select 1 rteotpay from dual
--       union
--      select 1.5 rteotpay from dual
--       union
--      select 2 rteotpay from dual
--       union
--      select 3 rteotpay from dual;

    cursor c_totpaydt is
      select rteotpay, qtyminot
        from totpaydt
       where codempid   = v_codempid
         and dtework    = v_dtework
         and typot      = v_typot
    order by rteotpay;

  begin
    if p_flgtypot = 'Y' then
        for r_rteotpay in c_rteotpay loop
          v_rteotpay  := r_rteotpay.rteotpay;
          v_qtyminoto := nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(v_rate,'rate'||to_char(v_index)||'Old')),0);
          v_qtyminotn := nvl(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(v_rate,'rate'||to_char(v_index))),0);
          if v_qtyminoto > 0 and v_qtyminotn = 0 then
            delete totpaydt
             where codempid   = v_codempid
               and dtework    = v_dtework
               and rteotpay   = v_rteotpay
               and typot      = v_typot;

            insert into tlogot2(codempid,dtetimupd, dtework,typot,
                                rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                         values(v_codempid,v_dteupd_log, v_dtework,v_typot,
                                v_rteotpay,v_qtyminoto,null,global_v_coduser,global_v_coduser);
          end if;

          if v_qtyminotn <> 0 then --and v_qtyminotn <> v_qtyminoto then
            begin
              v_log_qtyminoto := null;
              insert into totpaydt(codempid,dtework,typot,
                                   rteotpay,qtyminot,coduser, codcreate)
                            values(v_codempid,v_dtework,v_typot,
                                   v_rteotpay,v_qtyminotn,global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              v_log_qtyminoto := v_qtyminoto;
              update totpaydt
                 set qtyminot = v_qtyminotn,
                     coduser  = global_v_coduser,
                     dteupd   = sysdate
               where codempid = v_codempid
                 and dtework = v_dtework
                 and rteotpay = v_rteotpay
                 and typot = v_typot;
            end;

            insert into tlogot2(codempid,dtetimupd, dtework,typot,
                               rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                        values(v_codempid,v_dteupd_log, v_dtework,v_typot,
                               v_rteotpay,v_log_qtyminoto,v_qtyminotn,global_v_coduser,global_v_coduser);
          end if;

          v_index := v_index + 1;
--          if v_index > 4 then
--            exit;
--          end if;
        end loop;
    else
        for r_totpaydt in c_totpaydt loop
            insert into tlogot2(codempid,dtetimupd, dtework,typot,
                                rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                         values(v_codempid,v_dteupd_log, v_dtework,v_typot,
                                r_totpaydt.rteotpay,r_totpaydt.qtyminot,null,global_v_coduser,global_v_coduser);
        end loop;

        delete totpaydt
         where codempid   = v_codempid
           and dtework    = v_dtework
           and typot      = v_typot;
    end if;
  end insert_totpaydt;
end HRAL4KE;

/

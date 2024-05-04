--------------------------------------------------------
--  DDL for Package Body HRRC15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC15E" as

    procedure initial_current_user_value(json_str_input in clob) as
        json_obj        json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    end initial_current_user_value;

    procedure initial_params(data_obj json_object_t) as
    begin
        p_codcomp         := upper(hcm_util.get_string_t(data_obj,'p_codcompl'));
        p_codpos          := hcm_util.get_string_t(data_obj,'p_codposl');
        p_numreqst        := upper(hcm_util.get_string_t(data_obj,'p_numreqst'));
        p_codbrlc         := hcm_util.get_string_t(data_obj,'p_codbrlc');
    end initial_params;

    procedure check_index as
      v_temp      varchar(1 char);
      v_data      varchar(1 char) := 'N';
      v_check     varchar(1 char) := 'N';

      cursor c1 is
        select numreqst,qtyreq,qtyact
          from treqest2
         where codcomp  like p_codcomp || '%'
           and codpos   = nvl(p_codpos,codpos)
           and numreqst = nvl(p_numreqst,numreqst)
           and flgrecut in ('E','O')
      order by numreqst desc;

    begin
      if p_codcomp is not null then
          begin
              select 'X' into v_temp
                from tcenter
               where codcomp like p_codcomp || '%'
                 and rownum = 1;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
              return;
          end;
      end if;

      if secur_main.secur7(p_codcomp,global_v_coduser) = false then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
      end if;

      if p_codpos is not null then
          begin
              select 'X' into v_temp
                from tpostn
               where codpos = p_codpos;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
              return;
          end;
      end if;

      for i in c1 loop
        v_data := 'Y';
        if nvl(i.qtyreq,0) > nvl(i.qtyact,0) then
          v_check := 'Y';
          exit;
        end if;
      end loop; -- c1
      if v_data = 'N' then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
        return;
      elsif v_check = 'N' then
        param_msg_error := get_error_msg_php('HR4502', global_v_lang);
        return;
      end if;
    end check_index;

    function gen_tposcond return json_object_t is
        obj_row             json_object_t;
        obj_syncond         json_object_t;
        obj_data            json_object_t;
        v_row               number  := 0;
        v_syncond           tposcond.syncond%type;
        v_qtyscore          tposcond.qtyscore%type;
        v_statement         tposcond.statement%type;
        v_desc_statement    varchar2(2000 char);

    begin
        obj_row := json_object_t();

        for i in reverse 1..5 loop
            obj_data := json_object_t();
            obj_data.put('code','');
            obj_data.put('description','');
            obj_data.put('statement','');
        end loop;

        for i in reverse 1..5 loop
            v_row := v_row + 1;
            begin
                select syncond, qtyscore ,statement,get_logical_desc(statement) abc
                  into v_syncond,v_qtyscore,v_statement,v_desc_statement
                  from tposcond
                 where codapp = 'HRRC15E'
                   and codpos = p_codpos
                   and qtyscore = to_char(i);
            exception when no_data_found then
                v_syncond   := '';
                v_statement := '';
                v_qtyscore  := i;
            end;
            obj_data := json_object_t();
            obj_data.put('code',v_syncond);
--            obj_data.put('description',v_desc_statement);
            obj_data.put('description',get_logical_desc(v_statement));

            if v_statement is not null then
                obj_data.put('statement',v_statement);
            else
                obj_data.put('statement','');
            end if;

            obj_syncond := json_object_t();
            obj_syncond.put('syncond',obj_data);
            obj_syncond.put('qtyscore',v_qtyscore);
            obj_syncond.put('grade','');
            obj_row.put(to_char(v_row-1),obj_syncond);
        end loop;
        return obj_row;
    end gen_tposcond;

    procedure gen_index(json_str_output out clob) as
        obj_data            json_object_t;
        json_result         json_object_t;
        v_numreqst          treqest2.numreqst%type;
        v_codcomp           treqest2.codcomp%type;
        v_codpos            treqest2.codpos%type;
        v_codbrlc           treqest2.codbrlc%type;
        v_flgcond           treqest2.flgcond%type;
        v_syncond           treqest2.syncond%type;
        v_statement         treqest2.statement%type;
        obj_table           json_object_t;
        obj_syncond         json_object_t;

        cursor c1 is
            select numreqst,codcomp,codpos,codbrlc,flgcond,
                   syncond,statement,codjob,flgjob
              from treqest2
             where codcomp like p_codcomp || '%'
               and codpos = nvl(p_codpos,codpos)
               and numreqst = nvl(p_numreqst,numreqst)
               and flgrecut in ('E','O')
               and qtyact < qtyreq
          order by numreqst desc;
    begin

        for i in 1..10 loop
            obj_syncond := json_object_t();
            obj_syncond.put('code','');
            obj_syncond.put('description','');
            obj_syncond.put('statement','');
        end loop;

        for i in c1 loop
            obj_table   := gen_tposcond();
            obj_data    := json_object_t();
            obj_syncond := json_object_t();
            obj_syncond.put('code',i.syncond);
            obj_syncond.put('description',get_logical_desc(i.statement));
            /*if i.statement = 'null' then
                i.statement := null;
            end if;
            if i.statement is not null then
                obj_syncond.put('statement',i.statement);
            else
                obj_syncond.put('statement','');
            end if;*/
            obj_syncond.put('statement',nvl(i.statement,'[]'));
            obj_data.put('numreqst',i.numreqst);
            obj_data.put('codcompl',i.codcomp);
            obj_data.put('codposl',i.codpos);
            obj_data.put('codbrlc',i.codbrlc);
            obj_data.put('flgcond',i.flgcond);
            obj_data.put('syncond',obj_syncond);

            --<< user4 || 14/10/2022 || issue 8539
            if i.flgjob = 'Y' then
              begin
                  select statement into v_statement
                    from tjobcode
                   where codjob = i.codjob;
              exception when no_data_found then
                  v_statement := '';
              end;
              obj_data.put('statement_default',get_logical_desc(v_statement));
            elsif i.flgcond = 'Y' then
              obj_data.put('statement_default',get_logical_desc(i.statement));
            else
              obj_data.put('statement_default','');
            end if;
            -->> user4 || 14/10/2022 || issue 8539

            obj_data.put('table',obj_table);
            json_result := json_object_t();
            json_result.put('0',obj_data);
            dbms_lob.createtemporary(json_str_output, true);
            json_result.to_clob(json_str_output);
            return;
        end loop;
        param_msg_error := get_error_msg_php('HR2055',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure save_tposcond(json_obj json_object_t) as
        obj_data        json_object_t;
        obj_table       json_object_t;
        obj_rows        json_object_t;
        obj_syncode     json_object_t;
        v_numseq        tposcond.numseq%type;
        v_qtyscore      tposcond.qtyscore%type;
        v_syncond       tposcond.syncond%type;
        v_statement     tposcond.statement%type;
    begin
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        obj_table       := hcm_util.get_json_t(param_json,'table');
        obj_rows        := hcm_util.get_json_t(obj_table,'rows');
        for i in 0..obj_rows.get_size-1 loop
            obj_data    := hcm_util.get_json_t(obj_rows,to_char(i));
            obj_syncode := hcm_util.get_json_t(obj_data,'syncond');
            v_numseq    := i+1;
            v_qtyscore  := to_char(5-i);
            v_syncond   := hcm_util.get_string_t(obj_syncode,'code');
            v_statement := hcm_util.get_string_t(obj_syncode,'statement');
            begin
                insert into tposcond(codapp,codpos,numseq,qtyscore,syncond,statement,codcreate,coduser)
                values('HRRC15E',p_codpos,v_numseq,v_qtyscore,v_syncond,v_statement,global_v_coduser,global_v_coduser);
            exception when dup_val_on_index then
                update tposcond
                   set syncond = v_syncond,
                       statement = v_statement,
                       qtyscore = v_qtyscore,
                       coduser = global_v_coduser
                 where codapp = 'HRRC15E'
                   and codpos = p_codpos
                   and numseq = v_numseq;
            end;
        end loop;
    end save_tposcond;

  procedure gen_detail(json_obj json_object_t,json_str_output out clob) as
    obj_json    json_object_t;
    p_flgcond   varchar2(1 char);
    p_obj_syncond   json_object_t := json_object_t();
    p_syncond   treqest2.syncond%type;
    v_flgcond   treqest2.flgcond%type;
    v_codjob    treqest2.codjob%type;
    v_flgjob    treqest2.flgjob%type;
    v_syncond   treqest2.syncond%type;
    v_syncond2  tjobcode.syncond%type;
    v_statement     long;
    v_count_stmt    number := 0;
    v_namdoc    tappldoc.namdoc%type;
    v_filedoc   tappldoc.filedoc%type;
    obj_score1  json_object_t := json_object_t();
    obj_score2  json_object_t := json_object_t();
    obj_score3  json_object_t := json_object_t();
    obj_score4  json_object_t := json_object_t();
    obj_score5  json_object_t := json_object_t();
    v_row1      number :=0;
    v_row2      number :=0;
    v_row3      number :=0;
    v_row4      number :=0;
    v_row5      number :=0;
    obj_data    json_object_t;
    obj_rows    json_object_t := json_object_t();
    v_codcompl  treqest2.codcomp%type;
    v_codempts  treqest2.codemprc%type;
    sv_age      number;
    v_qtyscore  number;
    v_data      varchar2(1) := 'N';
    v_numappl   tapplinf.numappl%type;

    cursor c1 is
      select numappl,decode(global_v_lang,'101',namempe,'102',namempt,'103',namemp3,'104',namemp4,'105',namemp5) namempe,
             dteappl,codpos1,codpos2,statappl,codempid,dteempdb
        from tapplinf
       where nvl(numreql,p_numreqst) = p_numreqst
--         and(codpos1   = p_codpos or (codpos2 is not null and codpos2 = p_codpos))
--         and(codbrlc1  = nvl(p_codbrlc,codbrlc1)
--          or(codbrlc2  is not null and codbrlc2 = p_codbrlc)
--          or(codbrlc3  is not null and codbrlc3 = p_codbrlc))
         and statappl = '10'
    order by numappl;

    cursor c2 is
      select syncond,qtyscore
        from tposcond
       where codapp = 'HRRC15E'
         and codpos = p_codpos
         and syncond is not null
    order by numseq;
  begin
    for i in c1 loop
      param_json      := hcm_util.get_json_t(json_obj,'param_json');
      p_flgcond       := upper(hcm_util.get_string_t(param_json,'flgcond'));
      p_obj_syncond   := hcm_util.get_json_t(param_json,'syncond');
      p_syncond       := hcm_util.get_string_t(p_obj_syncond,'code');
      if p_flgcond = 'N' then
        v_syncond   := p_syncond;
        if v_syncond is not null then
          v_syncond := 'and '||v_syncond;
          sv_age := trunc(( months_between(sysdate,i.dteempdb)/12));
          v_syncond := replace(v_syncond,'TAPPLINF.SV_AGE',nvl(sv_age,0));
          v_syncond := replace(v_syncond,'V_HRRC26.CODLANG','TLANGABI.CODLANG');  -- softberry || 20/03/2023 || #8694      
        end if;
        v_statement := 'select count(tapplinf.numappl) '||
                       '  from tapplinf, tapplfm, teducatn, tapplref, tapplwex, tcmptncy, V_HRRC26, tlangabi '|| -- softberry || 20/03/2023 || #8694 || '  from tapplinf, tapplfm, teducatn, tapplref, tapplwex, tcmptncy,V_HRRC26 '||
                       ' where tapplinf.numappl = '||''''||i.numappl||''''||' '||
                       '   and tapplinf.numappl = tapplfm.numappl(+) '||
                       '   and tapplinf.numappl = teducatn.numappl(+) '||
                       '   and tapplinf.numappl = tapplref.numappl(+) '||
                       '   and tapplinf.numappl = tapplwex.numappl(+) '||
                       '   and tapplinf.numappl = tlangabi.numappl(+) '|| -- softberry || 20/03/2023 || #8694
                       '   and tapplinf.numappl = tcmptncy.numappl(+) '||v_syncond;
        execute immediate v_statement into v_count_stmt;
      elsif p_flgcond = 'Y' then
        v_flgjob    := null;
        v_codjob    := null;
        v_flgcond   := null;
        v_syncond   := null;
        begin
          select flgjob,codjob,flgcond,syncond
            into v_flgjob,v_codjob,v_flgcond,v_syncond
            from treqest2
           where codpos   = p_codpos
             and numreqst = p_numreqst;
        exception when no_data_found then null;
        end;
        if v_flgcond = 'Y' then
          if v_syncond is not null then
            v_syncond := 'and '||v_syncond;
          end if;
          v_statement := 'select count(v_hrrc26.numappl) '||
                         '  from v_hrrc26 '||
                         ' where v_hrrc26.numappl = '||''''||i.numappl||''''||' '||v_syncond;
          execute immediate v_statement into v_count_stmt;
        end if;
        if v_flgjob = 'Y' then
          begin
            select syncond
              into v_syncond
              from tjobcode
             where codjob = v_codjob;
          exception when no_data_found then
            v_syncond := null;
          end;
          if v_syncond is not null then
            v_syncond := 'and '||v_syncond;
            v_syncond := replace(v_syncond,'V_HRCO21','V_HRCO21_TAPPLINF');
            /*v_syncond := replace(v_syncond,'V_HRCO21.NUMAPPL','V_HRCO21_TAPPLINF.NUMAPPL');
            v_syncond := replace(v_syncond,'V_HRCO21.CODCOMP','V_HRCO21_TAPPLINF.CODCOMP');
            v_syncond := replace(v_syncond,'V_HRCO21.CODPOS','V_HRCO21_TAPPLINF.CODPOS');
            v_syncond := replace(v_syncond,'V_HRCO21.CODBRLC','V_HRCO21_TAPPLINF.CODBRLC');
            v_syncond := replace(v_syncond,'V_HRCO21.CODSEX','V_HRCO21_TAPPLINF.CODSEX');
            v_syncond := replace(v_syncond,'V_HRCO21.AGEEMP','V_HRCO21_TAPPLINF.AGEEMP');
            v_syncond := replace(v_syncond,'V_HRCO21.SV_EXP','V_HRCO21_TAPPLINF.SV_EXP');
            v_syncond := replace(v_syncond,'V_HRCO21.CODEDLV','V_HRCO21_TAPPLINF.CODEDLV');
            v_syncond := replace(v_syncond,'V_HRCO21.CODDGLV','V_HRCO21_TAPPLINF.CODDGLV');
            v_syncond := replace(v_syncond,'V_HRCO21.CODMAJSB','V_HRCO21_TAPPLINF.CODMAJSB');
            v_syncond := replace(v_syncond,'V_HRCO21.CODINST','V_HRCO21_TAPPLINF.CODINST');
            v_syncond := replace(v_syncond,'V_HRCO21.CODCNTY','V_HRCO21_TAPPLINF.CODCNTY');
            v_syncond := replace(v_syncond,'V_HRCO21.CODMINSB','V_HRCO21_TAPPLINF.CODMINSB');
            v_syncond := replace(v_syncond,'V_HRCO21.NUMGPA','V_HRCO21_TAPPLINF.NUMGPA');*/
          end if;
          v_statement := 'select count(v_hrco21_tapplinf.numappl) '||
                         '  from v_hrco21_tapplinf '||
                         ' where v_hrco21_tapplinf.numappl = '||''''||i.numappl||''''||' '||v_syncond;
          execute immediate v_statement into v_count_stmt;
        end if;
      end if;
      if v_count_stmt > 0 then
        v_data       := 'Y';
        v_count_stmt := 0;
        v_syncond    := null;
        v_qtyscore   := 0;
        for i2 in c2 loop
          if i2.syncond is not null then
            v_syncond := 'and '||i2.syncond;
            v_syncond := replace(v_syncond,'V_HRRC15E','v_hrrc26');-- boy 02/04/2022 : delete this line when fix error
          end if;
          v_statement := 'select count(v_hrrc26.numappl) '||
                         '  from v_hrrc26 '||
                         ' where v_hrrc26.numappl = '||''''||i.numappl||''''||' '||v_syncond;
          execute immediate v_statement into v_count_stmt;
          if v_count_stmt > 0 then
            v_qtyscore := i2.qtyscore;
            exit;
          end if;
        end loop; -- c2
        obj_data := json_object_t();
        obj_data.put('numappl',i.numappl);
        obj_data.put('namempe',i.namempe);
        obj_data.put('codpos1',i.codpos1);
        obj_data.put('desc_codpos1',get_tpostn_name(i.codpos1,global_v_lang));
        obj_data.put('codpos2',i.codpos2);
        obj_data.put('desc_codpos2',get_tpostn_name(i.codpos2,global_v_lang));
        obj_data.put('statappl',i.statappl);
        obj_data.put('qtyscore',v_qtyscore);
        obj_data.put('dteappl',to_char(i.dteappl,'dd/mm/yyyy'));

        begin
          select namdoc, filedoc
            into v_namdoc, v_filedoc
            from tappldoc
           where numappl = i.numappl
             and flgresume = 'Y';
        exception when no_data_found then
          v_namdoc := null;
          v_filedoc := null;
        end;

        obj_data.put('resume',v_namdoc);
--        obj_data.put('path_filename',v_filedoc);
        obj_data.put('path_filename',get_tsetup_value('PATHWORKPHP') || get_tfolderd('HRPMC2E') || '/' || v_filedoc); -- Adisak 24/03/202317:43 redmine 4448#9226
        if v_qtyscore = '1' then
          v_row1 := v_row1+1;
          obj_score1.put(to_char(v_row1-1),obj_data);
        elsif v_qtyscore = '2' then
          v_row2 := v_row2+1;
          obj_score2.put(to_char(v_row2-1),obj_data);
        elsif v_qtyscore = '3' then
          v_row3 := v_row3+1;
          obj_score3.put(to_char(v_row3-1),obj_data);
        elsif v_qtyscore = '4' then
          v_row4 := v_row4+1;
          obj_score4.put(to_char(v_row4-1),obj_data);
        elsif v_qtyscore = '5' then
          v_row5 := v_row5+1;
          obj_score5.put(to_char(v_row5-1),obj_data);
        end if;
      end if; -- v_count_stmt > 0
    end loop; -- c1
    v_row1 := 0;
    for i in 0..obj_score5.get_size-1 loop
        v_row1 := v_row1+1;
        obj_rows.put(to_char(v_row1-1),obj_score5.get(to_char(i)));
    end loop;
    for i in 0..obj_score4.get_size-1 loop
        v_row1 := v_row1+1;
        obj_rows.put(to_char(v_row1-1),obj_score4.get(to_char(i)));
    end loop;
    for i in 0..obj_score3.get_size-1 loop
        v_row1 := v_row1+1;
        obj_rows.put(to_char(v_row1-1),obj_score3.get(to_char(i)));
    end loop;
    for i in 0..obj_score2.get_size-1 loop
        v_row1 := v_row1+1;
        obj_rows.put(to_char(v_row1-1),obj_score2.get(to_char(i)));
    end loop;
    for i in 0..obj_score1.get_size-1 loop
        v_row1 := v_row1+1;
        obj_rows.put(to_char(v_row1-1),obj_score1.get(to_char(i)));
    end loop;

    if v_data = 'N' then -- if obj_rows.get_size = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    begin
        select codcomp,codemprc
          into v_codcompl,v_codempts
          from treqest2
         where codpos = p_codpos
           and numreqst = p_numreqst;
    exception when no_data_found then
        v_codcompl  := null;
        v_codempts  := null;
    end;
    begin
      select numappl into v_numappl
        from tapplinf
       where codcompl = p_codcomp
         and codposl   = p_codpos
         and rownum = 1;
    exception when no_data_found then
        v_numappl  := null;
    end;

    obj_data := json_object_t();
    obj_data.put('codcompl',v_codcompl);
    obj_data.put('desc_codcompl',get_tcenter_name(v_codcompl,global_v_lang));
    obj_data.put('codposl',p_codpos);
    obj_data.put('desc_codposl',get_tpostn_name(p_codpos,global_v_lang));
    obj_data.put('codempts',v_codempts);
    obj_data.put('desc_codempts',get_temploy_name(v_codempts,global_v_lang));
    obj_data.put('numappl',v_numappl);
    obj_data.put('table',obj_rows);

    obj_rows := json_object_t();
    obj_rows.put('0',obj_data);
    dbms_lob.createtemporary(json_str_output, true);
    obj_rows.to_clob(json_str_output);
    return;
  end gen_detail;

    procedure check_get_detail(json_obj json_object_t) as
        obj_data        json_object_t;
        obj_table       json_object_t;
        obj_rows        json_object_t;
        obj_syncode     json_object_t;
        v_numseq        tposcond.numseq%type;
        v_qtyscore      tposcond.qtyscore%type;
        v_syncond       tposcond.syncond%type;
    begin
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        obj_table       := hcm_util.get_json_t(param_json,'table');
        obj_rows        := hcm_util.get_json_t(obj_table,'rows');
        for i in 0..obj_rows.get_size-1 loop
            obj_data    := hcm_util.get_json_t(obj_rows,to_char(i));
            obj_syncode := hcm_util.get_json_t(obj_data,'syncond');
            v_syncond   := hcm_util.get_string_t(obj_syncode,'code');
            if v_syncond is not null then
                return;
            end if;
        end loop;
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
    end check_get_detail;

    procedure get_detail(json_str_input in clob,json_str_output out clob) as
        json_obj        json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        initial_params(json_obj);
        check_index;
--        check_get_detail(json_obj);
        if param_msg_error is null then
            save_tposcond(json_obj);
            gen_detail(json_obj,json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure save_detail(json_str_input in clob,json_str_output out clob) as
        json_obj        json_object_t;
        obj_data        json_object_t;
        v_numappl       tapplinf.numappl%type;
        v_statappl      tapplinf.statappl%type;
        v_qtyscore      tapplinf.qtyscore%type;
        v_numreql       tapplinf.numreql%type;
        v_codcompl      treqest1.codcomp%type;
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
        json_obj        := json_object_t(json_str_input);
        param_json      := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            obj_data    := hcm_util.get_json_t(param_json,to_char(i));
            v_numappl   := hcm_util.get_string_t(obj_data,'numappl');
            v_statappl  := hcm_util.get_string_t(obj_data,'statappl');
            v_qtyscore  := to_number(hcm_util.get_string_t(obj_data,'desc_qtyscore'));

            begin
                select numreql
                  into v_numreql
                  from tapplinf
                 where numappl = v_numappl;
            exception when no_data_found then
                v_numreql := null;
            end;

            begin
              select codcomp
                into v_codcompl
                from treqest1
               where numreqst = p_numreqst;
            exception when no_data_found then
              v_codcompl  := null;
            end;

            update tapplinf
               set numreql  = p_numreqst,
                   codposl  = p_codpos,
                   codcompl = v_codcompl,
                   statappl = v_statappl,
                   qtyscore = v_qtyscore,
                   dtefoll  = sysdate,
                   coduser  = global_v_coduser
            where numappl = v_numappl;

            insert into tappfoll(numappl,dtefoll,statappl,codrej,remark,codappr,numreqst,codpos,codcreate,coduser)
            values(v_numappl,sysdate,v_statappl,null,null,null,v_numreql,p_codpos,global_v_coduser,global_v_coduser);

            update treqest1
               set dterec = sysdate,
                   coduser = global_v_coduser
             where numreqst = v_numreql;

            update treqest2
               set dtechoose = sysdate,
                   coduser = global_v_coduser
             where numreqst = v_numreql
               and codpos = p_codpos;

        end loop;
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure send_mail_a( p_numappl tapplinf.numappl%type) as
        v_rowid         varchar(20);

        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;

        v_error             varchar2(4000 char);
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);

        v_msg           clob;

        v_email         varchar(200);
        v_codintview    treqest1.codintview%type;

        v_numreqst      tappeinf.numreqst%type;
        v_numreql       tapplinf.numreql%type;

    begin

        v_subject  := get_label_name('HRRC15E', global_v_lang, 10);
        v_codapp   := 'HRRC15E';

        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC15E';
        end;
        chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);

        -- replace employee param
        begin
            select rowid,numreql into v_rowid, v_numreql
            from TAPPLINF
            where numappl = p_numappl;
        exception when no_data_found then
            v_rowid := '';
            v_numreql  := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TAPPLINF', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace employee param email reciever param
        begin
            select rowid,codintview into v_rowid,v_codintview
            from treqest1
            where numreqst = v_numreql;
        exception when no_data_found then
            v_rowid := '';
            v_codintview := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TREQEST1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');

        -- replace sender
        begin
            select rowid into v_rowid
            from temploy1
            where codempid = global_v_codempid;
        exception when no_data_found then
            v_rowid := '';
        end;
        chk_flowmail.replace_text_frmmail(v_templete_to, 'TEMPLOY1', v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to, p_chkparam => 'N');
        begin
            select email into v_email
            from temploy1
            where codempid = v_codintview;
        exception when no_data_found then
            v_email := '';
        end;

        v_error := chk_flowmail.send_mail_to_emp (v_codintview, global_v_coduser, v_msg_to, NULL, v_subject, 'E', global_v_lang, null,null,null, null);

    end send_mail_a;

  procedure send_email(json_str_input in clob, json_str_output out clob) AS
        json_obj        json_object_t;
        data_obj        json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            p_numappl    := hcm_util.get_string_t(param_json, to_char(i));
            send_mail_a(p_numappl);
        end loop;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end send_email;

end HRRC15E;

/

--------------------------------------------------------
--  DDL for Package Body HRAP51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP51E" as
   procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    b_index_dteyreap  := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codbon          := hcm_util.get_string_t(json_obj,'p_codbon');
    p_numtime         := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    b_dteyreapQuery   := to_number(hcm_util.get_string_t(json_obj,'p_dteyreapQuery'));
    b_codcompQuery    := hcm_util.get_string_t(json_obj,'p_codcompQuery');
    p_codbonQuery     := hcm_util.get_string_t(json_obj,'p_codbonQuery');
    p_numtimeQuery    := hcm_util.get_string_t(json_obj,'p_numtimeQuery');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_result        json_object_t;
		obj_respone		    json_object_t;
		obj_respone_data  varchar2(1000 char);

    tbonparh_rec    tbonparh%ROWTYPE;
    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;

  begin
    if b_codcompQuery is not null and b_dteyreapQuery is not null and
       p_codbonQuery is not null and p_numtimeQuery is not null then
      p_isCopy  :=  'Y';
      v_flgAdd  := true;
    end if;

    --<<User37 #4408 10/09/2021 
    if p_isCopy = 'Y' then
      begin
        select * into tbonparh_rec
          from tbonparh
         where codcomp = b_codcompQuery
           and dteyreap = b_dteyreapQuery
           and codbon = p_codbonQuery
           and numtime = p_numtimeQuery;
      exception when no_data_found then
        tbonparh_rec  :=  null;
      end;
      tbonparh_rec.flgcal := 'N';
    else
      begin
        select * into tbonparh_rec
          from tbonparh
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      exception when no_data_found then
        tbonparh_rec  :=  null;
      end;
    end if;
    /*begin
      select * into tbonparh_rec
        from tbonparh
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
         and codbon = p_codbon
         and numtime = p_numtime;
    exception when no_data_found then
      tbonparh_rec  :=  null;
    end;*/
    -->>User37 #4408 10/09/2021 

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('isCopy', p_isCopy);
    obj_data.put('flgcal', tbonparh_rec.flgcal);
    obj_data.put('dtestr', to_char(tbonparh_rec.dtestr,'dd/mm/yyyy'));
    obj_data.put('dteend', to_char(tbonparh_rec.dteend,'dd/mm/yyyy'));
    obj_data.put('typbon', tbonparh_rec.typbon);
    obj_data.put('grdyear', tbonparh_rec.grdyear);
    obj_data.put('grdnumtime', tbonparh_rec.grdnumtime);
    obj_data.put('amtbudg', tbonparh_rec.amtbudg);
    obj_data.put('boncond', tbonparh_rec.boncond);
    obj_data.put('salcond', tbonparh_rec.salcond);
    obj_data.put('formula', tbonparh_rec.formula);
    obj_data.put('stmtboncond', tbonparh_rec.stmtboncond);
    obj_data.put('stmtsalcond', tbonparh_rec.stmtsalcond);
    obj_data.put('stmtformula', tbonparh_rec.stmtformula);
    obj_data.put('desc_boncond', get_logical_desc(tbonparh_rec.stmtboncond));
    obj_data.put('flgprorate', tbonparh_rec.flgprorate);
    obj_data.put('dteeffsal', to_char(tbonparh_rec.dteeffsal,'dd/mm/yyyy'));
    if tbonparh_rec.flgcal = 'Y' and p_isCopy <> 'Y' then
      obj_respone_data    := get_error_msg_php('HR1507', global_v_lang);
      json_str_output     := get_response_message(NULL, obj_respone_data, global_v_lang);
      obj_respone         := json_object_t(json_str_output);
      obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
      obj_data.put('msgerror', obj_respone_data);
    else
      obj_data.put('msgerror', '');
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcomp   tcenter.codcomp%type;
     v_codbon    tcodbons.codcodec%type;
  begin
    if b_index_codcomp is not null then
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(b_index_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(b_index_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codbon is not null then
      begin
        select codcodec into v_codbon
          from tcodbons
         where codcodec = p_codbon;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODBONS');
        return;
      end;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
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
  procedure gen_index_table1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    cursor c1 is
      select numseq,grade,ratebonc,amttbonc,ratebon,amttbon
        from tbonpard
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
         and codbon = p_codbon
         and numtime = p_numtime
       order by numseq;

    cursor c2 is
      select grade
        from tstdis
        where codcomp = b_index_codcomp
          and dteyreap = b_index_dteyreap;

  begin
    --<<User37 #4408 10/09/2021 
    if b_codcompQuery is not null and b_dteyreapQuery is not null and
       p_codbonQuery is not null and p_numtimeQuery is not null then
      p_isCopy  :=  'Y';
      v_flgAdd  := true;
      b_index_codcomp   := b_codcompQuery;
      b_index_dteyreap  := b_dteyreapQuery;
      p_codbon          := p_codbonQuery;
      p_numtime         := p_numtimeQuery;
    end if;
    -->>User37 #4408 10/09/2021 
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', r1.numseq);
      obj_data.put('grade', r1.grade);
      obj_data.put('ratebonc', r1.ratebonc);
      obj_data.put('amttbonc', r1.amttbonc);
      obj_data.put('ratebon', r1.ratebon);
      obj_data.put('amttbon', r1.amttbon);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt = 0 then
      for r1 in c2 loop
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq', v_rcnt);
          obj_data.put('grade', r1.grade);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_index_table1(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_table2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    cursor c1 is
      select numseq,ratecond,statement,ratebonc,amttbonc,ratebon,amttbon
        from tbonparc
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
         and codbon = p_codbon
         and numtime = p_numtime
       order by numseq;

  begin
    --<<User37 #4408 10/09/2021 
    if b_codcompQuery is not null and b_dteyreapQuery is not null and
       p_codbonQuery is not null and p_numtimeQuery is not null then
      p_isCopy  :=  'Y';
      v_flgAdd  := true;
      b_index_codcomp   := b_codcompQuery;
      b_index_dteyreap  := b_dteyreapQuery;
      p_codbon          := p_codbonQuery;
      p_numtime         := p_numtimeQuery;
    end if;
    -->>User37 #4408 10/09/2021 
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', r1.numseq);
      obj_data.put('ratecond', r1.ratecond);
      obj_data.put('statement', r1.statement);
      obj_data.put('desc_ratecond', get_logical_desc(r1.statement));
      obj_data.put('ratebonc', r1.ratebonc);
      obj_data.put('amttbonc', r1.amttbonc);
      obj_data.put('ratebon', r1.ratebon);
      obj_data.put('amttbon', r1.amttbon);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_index_table2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copy_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    cursor c1 is
      select codcomp,dteyreap,codbon,numtime
        from tbonparh
       --where codcomp = b_index_codcomp
    order by dteyreap desc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      if secur_main.secur7(i.codcomp, global_v_coduser) then
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('dteyreap', i.dteyreap);
      obj_data.put('codbon', i.codbon);
      obj_data.put('numtime', i.numtime);
      obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure check_save(json_str_input in clob) is
    v_codcomp     tcenter.codcomp%type;
    param_json    json_object_t;
    obj_detail    json_object_t;
    obj_stmt      json_object_t;
    obj_form1     json_object_t;
    obj_form2     json_object_t;

    v_typbon      tbonparh.typbon%type;
    v_grdyear     tbonparh.grdyear%type;
    v_grdnumtime  tbonparh.grdnumtime%type;
    v_amtbudg     tbonparh.amtbudg%type;
    v_flgprorate  tbonparh.flgprorate%type;
    v_dteeffsal   tbonparh.dteeffsal%type;
    v_boncond     tbonparh.boncond%type;
    v_salcond     tbonparh.salcond%type;
    v_formula     tbonparh.formula%type;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'indexData');
    obj_detail    := hcm_util.get_json_t(param_json,'detail');
    obj_stmt      := hcm_util.get_json_t(obj_detail,'boncond');
    obj_form1     := hcm_util.get_json_t(obj_detail,'salcond');
    obj_form2     := hcm_util.get_json_t(obj_detail,'formula');

    v_boncond     := hcm_util.get_string_t(obj_stmt,'code');
    v_salcond     := hcm_util.get_string_t(obj_form1,'code');
    v_formula     := hcm_util.get_string_t(obj_form2,'code');
    v_typbon      := hcm_util.get_string_t(obj_detail,'typbon');
    v_grdyear     := hcm_util.get_string_t(obj_detail,'grdyear');
    v_grdnumtime  := hcm_util.get_string_t(obj_detail,'grdnumtime');
    v_amtbudg     := hcm_util.get_string_t(obj_detail,'amtbudg');
    v_flgprorate  := hcm_util.get_string_t(obj_detail,'flgprorate');
    v_dteeffsal   := hcm_util.get_string_t(obj_detail,'dteeffsal');

    if v_typbon is null or v_amtbudg is null or v_flgprorate is null or v_dteeffsal is null or
       v_boncond is null or v_salcond is null or v_formula is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if v_typbon = '1' then
      if v_grdyear is null or v_grdnumtime is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
      end if;
    end if;
  end;
  --
  procedure save_data (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    obj_detail    json_object_t;
    obj_stmt      json_object_t;
    obj_form1     json_object_t;
    obj_form2     json_object_t;
    obj_table1    json_object_t;
    obj_table2    json_object_t;

    v_typbon      tbonparh.typbon%type;
    v_grdyear     tbonparh.grdyear%type;
    v_grdnumtime  tbonparh.grdnumtime%type;
    v_amtbudg     tbonparh.amtbudg%type;
    v_flgprorate  tbonparh.flgprorate%type;
    v_dteeffsal   tbonparh.dteeffsal%type;
    v_boncond     tbonparh.boncond%type;
    v_salcond     tbonparh.salcond%type;
    v_formula     tbonparh.formula%type;
    v_flgcal      varchar2(2 char);
    v_dtestr      tbonparh.dtestr%type;
    v_dteend      tbonparh.dteend%type;
    v_stmtboncond	tbonparh.stmtboncond%type;
    v_stmtsalcond	tbonparh.stmtsalcond%type;
    v_stmtformula	tbonparh.stmtformula%type;
    v_flg	          varchar2(1000 char);
    v_isCopy        varchar2(2 char);

    v_numseq      tbonparc.numseq%type;
    v_grade       tbonpard.grade%type;
    v_ratebonc    tbonparc.ratebonc%type;
    v_amttbonc    tbonparc.amttbonc%type;
    v_ratebon     tbonparc.ratebon%type;
    v_amttbon     tbonparc.amttbon%type;
    v_ratecond    tbonparc.ratecond%type;
    v_statement   tbonparc.statement%type;
    v_flgAdd      boolean;
    v_flgEdit     boolean;
    v_flgDelete   boolean;
  begin
    initial_value(json_str_input);
    check_save(json_str_input);
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'indexData');
    obj_detail    := hcm_util.get_json_t(param_json,'detail');
    obj_table1    := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'evaluation'),'rows');
    obj_table2    := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'condition'),'rows');
    obj_stmt      := hcm_util.get_json_t(obj_detail,'boncond');
    obj_form1     := hcm_util.get_json_t(obj_detail,'salcond');
    obj_form2     := hcm_util.get_json_t(obj_detail,'formula');

    v_boncond     := hcm_util.get_string_t(obj_stmt,'code');
    v_salcond     := hcm_util.get_string_t(obj_form1,'code');
    v_formula     := hcm_util.get_string_t(obj_form2,'code');
    v_stmtboncond := hcm_util.get_string_t(obj_stmt,'statement');
    v_stmtsalcond := hcm_util.get_string_t(obj_form1,'description');
    v_stmtformula := hcm_util.get_string_t(obj_form2,'description');

    v_typbon      := hcm_util.get_string_t(obj_detail,'typbon');
    v_grdyear     := hcm_util.get_string_t(obj_detail,'grdyear');
    v_grdnumtime  := hcm_util.get_string_t(obj_detail,'grdnumtime');
    v_amtbudg     := hcm_util.get_string_t(obj_detail,'amtbudg');
    v_flgprorate  := hcm_util.get_string_t(obj_detail,'flgprorate');
    v_dteeffsal   := to_date(hcm_util.get_string_t(obj_detail,'dteeffsal'),'dd/mm/yyyy');
    v_isCopy      := hcm_util.get_string_t(obj_detail,'isCopy');
    v_flgcal      := nvl(hcm_util.get_string_t(obj_detail,'flgcal'),'N');
    v_dtestr      := to_date(hcm_util.get_string_t(obj_detail,'dtestr'),'dd/mm/yyyy');
    v_dteend      := to_date(hcm_util.get_string_t(obj_detail,'dteend'),'dd/mm/yyyy');

    if param_msg_error is null then
      if v_isCopy = 'Y' then
        begin
          delete tbonparh
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime;
        end;
        begin
          delete tbonpard
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime;
        end;
        begin
          delete tbonparc
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime;
        end;
      end if;
      begin
        insert into tbonparh(codcomp,codbon,dteyreap,numtime,dtestr,dteend,
                             typbon,dteeffsal,boncond,salcond,formula,stmtboncond,stmtsalcond,stmtformula,
                             flgcal,grdyear,grdnumtime,amtbudg,flgprorate,
                             codcreate,coduser)
        values (b_index_codcomp, p_codbon, b_index_dteyreap, p_numtime, v_dtestr, v_dteend,
                v_typbon, v_dteeffsal, v_boncond, v_salcond, v_formula, v_stmtboncond, v_stmtsalcond, v_stmtformula,
                v_flgcal, v_grdyear, v_grdnumtime, v_amtbudg, v_flgprorate,
                global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tbonparh
           set  dtestr	=	v_dtestr,
                dteend	=	v_dteend,
                typbon	=	v_typbon,
                dteeffsal	=	v_dteeffsal,
                boncond	=	v_boncond,
                salcond	=	v_salcond,
                formula	=	v_formula,
                stmtboncond	=	v_stmtboncond,
                stmtsalcond	=	v_stmtsalcond,
                stmtformula	=	v_stmtformula,
                flgcal	=	v_flgcal,
                grdyear	=	v_grdyear,
                grdnumtime	=	v_grdnumtime,
                amtbudg	=	v_amtbudg,
                flgprorate	=	v_flgprorate,
                dteupd = sysdate,
                coduser = global_v_coduser
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end;
      --

    end if;
    begin
      delete tbonpard
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
         and codbon = p_codbon
         and numtime = p_numtime;
    end;
    for i in 0..obj_table1.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(obj_table1,to_char(i));
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_grade         := hcm_util.get_string_t(param_json_row,'grade');
      v_ratebonc      := hcm_util.get_string_t(param_json_row,'ratebonc');
      v_amttbonc      := hcm_util.get_string_t(param_json_row,'amttbonc');
      v_ratebon       := hcm_util.get_string_t(param_json_row,'ratebon');
      v_amttbon       := hcm_util.get_string_t(param_json_row,'amttbon');

      if v_numseq is null then
        select nvl(max(numseq),0) + 1 into v_numseq
          from tbonpard
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end if;

      begin
        insert into tbonpard(codcomp,codbon,dteyreap,numtime,numseq,
                    grade,ratebonc,amttbonc,ratebon,amttbon,
                    codcreate,coduser)
        values (b_index_codcomp, p_codbon, b_index_dteyreap, p_numtime, v_numseq,
                v_grade, v_ratebonc, v_amttbonc, v_ratebon, v_amttbon,
                global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tbonpard
           set grade	=	v_grade,
               ratebonc	=	v_ratebonc,
               amttbonc	=	v_amttbonc,
               ratebon	=	v_ratebon,
               amttbon	=	v_amttbon,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime
           and numseq = v_numseq;
      end;
    end loop;
    -- typbon = 2
--    begin
--      delete tbonparc
--       where codcomp = b_index_codcomp
--         and dteyreap = b_index_dteyreap
--         and codbon = p_codbon
--         and numtime = p_numtime;
--    end;
    for i in 0..obj_table2.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(obj_table2,to_char(i));
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_ratebonc      := hcm_util.get_string_t(param_json_row,'ratebonc');
      v_amttbonc      := hcm_util.get_string_t(param_json_row,'amttbonc');
      v_ratebon       := hcm_util.get_string_t(param_json_row,'ratebon');
      v_amttbon       := hcm_util.get_string_t(param_json_row,'amttbon');
      obj_stmt        := hcm_util.get_json_t(param_json_row,'ratecond');
      v_ratecond      := hcm_util.get_string_t(obj_stmt,'code');
      v_statement     := hcm_util.get_string_t(obj_stmt,'statement');

      v_flgAdd        := hcm_util.get_boolean_t(param_json_row,'flgAdd');
      v_flgEdit       := hcm_util.get_boolean_t(param_json_row,'flgEdit');
      v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');
      if v_numseq is null then
        select nvl(max(numseq),0) + 1 into v_numseq
          from tbonparc
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end if;
      if v_flgAdd = true or v_flgEdit = true then
        begin
          insert into tbonparc(codcomp,codbon,dteyreap,numtime,numseq,
                      ratecond, statement,ratebonc,amttbonc,ratebon,amttbon,
                      codcreate,coduser)
          values (b_index_codcomp, p_codbon, b_index_dteyreap, p_numtime, v_numseq,
                  v_ratecond, v_statement, v_ratebonc, v_amttbonc, v_ratebon, v_amttbon,
                  global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tbonparc
             set ratecond	=	v_ratecond,
                 statement	=	v_statement,
                 ratebonc	=	v_ratebonc,
                 amttbonc	=	v_amttbonc,
                 ratebon	=	v_ratebon,
                 amttbon	=	v_amttbon,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime
             and numseq = v_numseq;
        end;
      elsif v_flgDelete = true then
        begin
          delete tbonparc
           where codcomp = b_index_codcomp
             and dteyreap = b_index_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime
             and numseq = v_numseq;
        end;
      end if;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure delete_data (json_str_input in clob, json_str_output out clob) as
    v_flgcal      varchar2(2 char);
  begin
    initial_value(json_str_input);

    begin
      select flgcal into v_flgcal
        from tbonparh
       where codcomp = b_index_codcomp
         and dteyreap = b_index_dteyreap
         and codbon = p_codbon
         and numtime = p_numtime;
    exception when no_data_found then
      v_flgcal  :=  null;
    end;
    if v_flgcal = 'Y' then
      param_msg_error   := get_error_msg_php('HR1507', global_v_lang);
    end if;
    if param_msg_error is null then
      begin
        delete tbonparh
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end;
      begin
        delete tbonpard
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end;
      begin
        delete tbonparc
         where codcomp = b_index_codcomp
           and dteyreap = b_index_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
end hrap51e;

/

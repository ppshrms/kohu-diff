--------------------------------------------------------
--  DDL for Package Body HRAPS9B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPS9B" as

  procedure initial_value (json_str in clob) is
      json_obj        json;
  begin
      v_chken             := hcm_secur.get_v_chken;

      json_obj            := json(json_str);
      -- global
      global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
      global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

      -- index params
      p_dteyreap          := to_number(hcm_util.get_string(json_obj,'p_dteyreap'));
      p_numtime           := to_number(hcm_util.get_string(json_obj,'p_numtime'));
      p_codbon            := hcm_util.get_string(json_obj,'p_codbon');
      p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
      p_typbon            := hcm_util.get_string(json_obj,'p_typbon');
      p_codreq            := hcm_util.get_string(json_obj,'p_codreq');

      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
      v_flgsecu		boolean;
      v_numlvl		temploy1.numlvl%type;
      v_staemp    temploy1.staemp%type;
      v_codreq    varchar2(40 char);
      v_codbon    varchar2(40 char);
      v_codcomp   tcenter.codcomp%type;
      v_flgSecur  boolean;
  begin
      if p_dteyreap is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
          return;
      end if;

      if p_numtime is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numtime');
          return;
      end if;

      if p_codbon is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codbon');
          return;
      end if;

      if p_codcomp is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
          return;
      end if;

--      if p_codreq is null then
--          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codreq');
--          return;
--      end if;

      if p_dteyreap <= 0 then
          param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
          return;
      end if;

--      b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);
--
--      v_flgSecur := secur_main.secur7(p_codcomp, global_v_coduser);
--      if param_msg_error is not null then
--        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
--        return;
--      end if;
      begin
        select codcomp into v_codcomp
        from tcenter
        where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
--      if length(p_codcomp) < 40 then
--          p_codcomp := p_codcomp||'%';
--      end if;

      begin
          select codcodec into v_codbon
            from tcodbons
           where codcodec = p_codbon;
      exception when no_data_found then
          v_codbon := null;
      end;
      if v_codbon is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODBONS');
          return;
      end if;
--
--      begin
--          select codempid,staemp
--            into v_codreq,v_staemp
--            from temploy1
--           where codempid = p_codreq;
--      exception when no_data_found then
--          param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
--          return;
--      end;
--
--      if v_staemp = '0' then
--          param_msg_error := get_error_msg_php('HR2102', global_v_lang,'p_codreq');
--          return;
--      elsif v_staemp = '9' then
--          param_msg_error := get_error_msg_php('HR2101', global_v_lang,'p_codreq');
--          return;
--      end if;

  end;

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_desc_stacard  varchar2(1000 char);
    v_stacard       varchar2(1000 char);
    v_flgdata       varchar2(1 char) := 'N';
    t_tbonparh      tbonparh%rowtype;
    t_ttbonparh     ttbonparh%rowtype;

/*
    cursor c_tjobposte is
      select codjobpost,dtepost,codcomp,dtepay,amtpay,qtypos,remark
        from tjobposte
       where codcomp  like b_index_codcomp||'%'
         and ((b_index_mthpost is not null and to_char(dtepost,'mmyyyy') = lpad(b_index_mthpost,2,0)||b_index_yrepost)
             or (b_index_mthpost is null and dtepost = nvl(b_index_dtepost,dtepost) ) )
      order by dtepost;*/

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    begin
      select * into t_ttbonparh
        from ttbonparh
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime;
         v_flgdata := 'Y';
    exception when no_data_found then
      t_ttbonparh := null;
    end;
    begin
      select * into t_tbonparh
        from tbonparh
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime;
    exception when no_data_found then
      t_tbonparh := null;
    end;
    if v_flgdata = 'Y' then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtestr', to_char(t_ttbonparh.dtestr,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(t_ttbonparh.dteend,'dd/mm/yyyy'));
      obj_data.put('typbon', t_ttbonparh.typbon);
      obj_data.put('dteeffsal', to_char(t_ttbonparh.dteeffsal,'dd/mm/yyyy'));
      obj_data.put('boncond', t_ttbonparh.boncond);
      obj_data.put('salcond', t_ttbonparh.salcond);
      obj_data.put('formula', t_ttbonparh.formula);
      obj_data.put('stmtboncond', nvl(t_ttbonparh.stmtboncond,'[]'));
      obj_data.put('stmtsalcond', nvl(t_ttbonparh.stmtsalcond,''));
      obj_data.put('stmtformula', nvl(t_ttbonparh.stmtformula,''));
      obj_data.put('desc_boncond', get_logical_desc(t_ttbonparh.stmtboncond));
      obj_data.put('flgcal', t_ttbonparh.flgcal);
      obj_data.put('typsal', t_ttbonparh.typsal);
      obj_data.put('grdyear', t_ttbonparh.grdyear);
      obj_data.put('grdnumtime', t_ttbonparh.grdnumtime);
      obj_data.put('flgprorate', t_ttbonparh.flgprorate);
      obj_data.put('codappr', t_ttbonparh.codappr);
      obj_data.put('dteappr', to_char(t_ttbonparh.dteappr,'dd/mm/yyyy'));
      obj_data.put('amtbudg', t_ttbonparh.amtbudg);--User37 #4442 07/10/2021
    else
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtestr', to_char(t_tbonparh.dtestr,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(t_tbonparh.dteend,'dd/mm/yyyy'));
      obj_data.put('typbon', t_tbonparh.typbon);
      obj_data.put('dteeffsal', to_char(t_tbonparh.dteeffsal,'dd/mm/yyyy'));
      obj_data.put('boncond', t_tbonparh.boncond);
      obj_data.put('salcond', t_tbonparh.salcond);
      obj_data.put('formula', t_tbonparh.formula);
      obj_data.put('stmtboncond', nvl(t_tbonparh.stmtboncond,'[]'));
      obj_data.put('stmtsalcond', nvl(t_tbonparh.stmtsalcond,''));
      obj_data.put('stmtformula', nvl(t_tbonparh.stmtformula,''));
      obj_data.put('desc_boncond', get_logical_desc(t_tbonparh.stmtboncond));
      obj_data.put('flgcal', t_tbonparh.flgcal);
      obj_data.put('typsal', t_tbonparh.typsal);
      obj_data.put('grdyear', t_tbonparh.grdyear);
      obj_data.put('grdnumtime', t_tbonparh.grdnumtime);
      obj_data.put('flgprorate', t_tbonparh.flgprorate);
      obj_data.put('codappr', '');
      obj_data.put('dteappr', '');
      obj_data.put('amtbudg', t_tbonparh.amtbudg);--User37 #4442 07/10/2021
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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

  procedure gen_index_table2 (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_desc_stacard  varchar2(1000 char);
    v_stacard       varchar2(1000 char);
    v_flgdata       varchar2(1 char) := 'N';
    t_tbonparh      tbonparh%rowtype;

    cursor c1 is
      select grade,ratebonc,amttbonc,ratebon,amttbon,numseq
        from tbonpard
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime
      order by numseq;

    --<<User37 #4442 07/10/2021
    cursor c2 is
      select grade,ratebon,amttbon,numseq
        from ttbonpard
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime
      order by numseq;
    -->>User37 #4442 07/10/2021

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    --<<User37 #4442 07/10/2021
    begin
      select 'Y' into v_flgdata
        from ttbonparh
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime;
         v_flgdata := 'Y';
    exception when no_data_found then
      v_flgdata := 'N';
    end;
    if v_flgdata = 'Y' then
      for i in c2 loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('grade', i.grade);
        obj_data.put('numseq', i.numseq);
        obj_data.put('int', i.ratebon);
        obj_data.put('price', i.amttbon);
        if i.grade = 'A' then
          obj_data.put('tag','<i class="fa fa-circle _text-blue"></i>');
        elsif i.grade = 'B' then
          obj_data.put('tag','<i class="fa fa-circle _text-green"></i>');
        elsif i.grade = 'C' then
          obj_data.put('tag','<i class="fa fa-circle _text-yellow"></i>');
        elsif i.grade = 'D' then
          obj_data.put('tag','<i class="fa fa-circle _text-orange"></i>');
        elsif i.grade = 'F' then
          obj_data.put('tag','<i class="fa fa-circle _text-red"></i>');
        end if;
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    else
      for i in c1 loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('grade', i.grade);
        obj_data.put('numseq', i.numseq);
        obj_data.put('int', i.ratebonc);
        obj_data.put('price', i.amttbonc);
        if i.grade = 'A' then
          obj_data.put('tag','<i class="fa fa-circle _text-blue"></i>');
        elsif i.grade = 'B' then
          obj_data.put('tag','<i class="fa fa-circle _text-green"></i>');
        elsif i.grade = 'C' then
          obj_data.put('tag','<i class="fa fa-circle _text-yellow"></i>');
        elsif i.grade = 'D' then
          obj_data.put('tag','<i class="fa fa-circle _text-orange"></i>');
        elsif i.grade = 'F' then
          obj_data.put('tag','<i class="fa fa-circle _text-red"></i>');
        end if;
        obj_data.put('flgAdd', true);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;
    /*for i in c1 loop
      v_flgdata   := 'Y';
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('grade', i.grade);
      obj_data.put('numseq', i.numseq);
      obj_data.put('int', i.ratebonc);
      obj_data.put('price', i.amttbonc);
      if i.grade = 'A' then
        obj_data.put('tag','<i class="fa fa-circle _text-blue"></i>');
      elsif i.grade = 'B' then
        obj_data.put('tag','<i class="fa fa-circle _text-green"></i>');
      elsif i.grade = 'C' then
        obj_data.put('tag','<i class="fa fa-circle _text-yellow"></i>');
      elsif i.grade = 'D' then
        obj_data.put('tag','<i class="fa fa-circle _text-orange"></i>');
      elsif i.grade = 'F' then
        obj_data.put('tag','<i class="fa fa-circle _text-red"></i>');
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;*/
    -->>User37 #4442 07/10/2021

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_table2 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
  procedure gen_index_table1 (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_desc_stacard  varchar2(1000 char);
    v_stacard       varchar2(1000 char);
    v_flgdata       varchar2(1 char) := 'N';
    t_tbonparh      tbonparh%rowtype;

    cursor c1 is
      select ratecond,statement,ratebonc,amttbonc,ratebon,amttbon,numseq
        from tbonparc
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime
      order by numseq;

    --<<User37 #4442 07/10/2021
    cursor c2 is
      select ratecond,statement,ratebon,amttbon,numseq
        from ttbonparc
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime
      order by numseq;
    -->>User37 #4442 07/10/2021

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    --<<User37 #4442 07/10/2021
    begin
      select 'Y' into v_flgdata
        from ttbonparh
       where codcomp = p_codcomp
         and codbon = p_codbon
         and dteyreap = p_dteyreap
         and numtime = p_numtime;
         v_flgdata := 'Y';
    exception when no_data_found then
      v_flgdata := 'N';
    end;
    if v_flgdata = 'Y' then
      for i in c2 loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', i.numseq);
        obj_data.put('ratecond', i.ratecond);
        obj_data.put('statement', nvl(i.statement,'[]'));
        obj_data.put('description', get_logical_desc(i.statement));
        obj_data.put('ratebonc', i.ratebon);
        obj_data.put('amttbonc', i.amttbon);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    else
      for i in c1 loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', i.numseq);
        obj_data.put('ratecond', i.ratecond);
        obj_data.put('statement', nvl(i.statement,'[]'));
        obj_data.put('description', get_logical_desc(i.statement));
        obj_data.put('ratebonc', i.ratebonc);
        obj_data.put('amttbonc', i.amttbonc);
        obj_data.put('flgAdd', true);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;
    /*for i in c1 loop
      v_flgdata   := 'Y';
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', i.numseq);
      obj_data.put('ratecond', i.ratecond);
      obj_data.put('statement', nvl(i.statement,'[]'));
      obj_data.put('description', get_logical_desc(i.statement));
      obj_data.put('ratebonc', i.ratebonc);
      obj_data.put('amttbonc', i.amttbonc);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;*/
    -->>User37 #4442 07/10/2021

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_index_table1 (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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

  procedure check_process is
      v_flgsecu		boolean;
      v_numlvl		temploy1.numlvl%type;
      v_staemp        temploy1.staemp%type;
      v_codreq        varchar2(40 char);
      v_codbon        varchar2(40 char);
  begin
      if p_dteyreap is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
          return;
      end if;

      if p_numtime is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numtime');
          return;
      end if;

      if p_codbon is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codbon');
          return;
      end if;

      if p_codcomp is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
          return;
      end if;

--      if p_codreq is null then
--          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codreq');
--          return;
--      end if;

      if p_dteyreap <= 0 then
          param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
          return;
      end if;

      b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);

      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
          return;
      end if;
--      if length(p_codcomp) < 40 then
--          p_codcomp := p_codcomp||'%';
--      end if;

      begin
          select codcodec into v_codbon
            from tcodbons
           where codcodec = p_codbon;
      exception when no_data_found then
          v_codbon := null;
      end;
      if v_codbon is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODBONS');
          return;
      end if;

--      begin
--          select codempid,staemp
--            into v_codreq,v_staemp
--            from temploy1
--           where codempid = p_codreq;
--      exception when no_data_found then
--          param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
--          return;
--      end;
--
--      if v_staemp = '0' then
--          param_msg_error := get_error_msg_php('HR2102', global_v_lang,'p_codreq');
--          return;
--      elsif v_staemp = '9' then
--          param_msg_error := get_error_msg_php('HR2101', global_v_lang,'p_codreq');
--          return;
--      end if;

  end;

  procedure  insert_data_parallel (p_codapp  in varchar2,
                                   p_coduser in varchar2,
                                   p_proc    in out number) is

      v_num       number ;
      v_proc      number := p_proc ;
      v_numproc   number ;
      v_rec       number ;
      v_flgsecu   boolean := false;
      v_secur     boolean := false;
      v_flgfound  boolean := false;
      v_zupdsal   varchar2(1);

      cursor c_temploy is
          select codempid,codcomp,numlvl
            from temploy1
           where codcomp  like p_codcomp||'%'
             and staemp   in('1','3')
          order by codempid;

  begin
      delete tprocemp where codapp = p_codapp and coduser = p_coduser  ; commit;
      commit ;

      begin
          select count(codempid) into  v_rec
            from temploy1
           where codcomp  like p_codcomp||'%'
             and staemp   in('1','3');
      end;
      v_num    := greatest(trunc(v_rec/v_proc),1);
      v_rec    := 0;

      for i in c_temploy loop
          v_flgfound := true;
          v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
          if v_flgsecu then
              v_secur   := true;
              v_rec     := v_rec + 1 ;
              v_numproc := trunc(v_rec / v_num) + 1 ;
              if v_numproc > v_proc then
                  v_numproc  := v_proc ;
              end if;

              insert into tprocemp (codapp,coduser,numproc,codempid)
                     values        (p_codapp,p_coduser,v_numproc,i.codempid);
          end if;
      end loop;

      if not v_flgfound then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
      end if;

      if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;

      p_proc := v_numproc;
      commit;

  end;

  procedure get_process (json_str_input in clob, json_str_output out clob) is
  begin
      initial_value(json_str_input);
      check_process;
      if param_msg_error is null then
        process_data(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure process_data(json_str_output out clob) is
      obj_row         json_object_t := json_object_t();
      obj_row2        json_object_t := json_object_t();
      obj_data        json_object_t;
      obj_data2       json_object_t;
      v_row           number := 0;
      v_flgpass		    boolean := true;
      p_codapp        varchar2(100 char) := 'HRAPS9B';
      v_numproc       number := nvl(get_tsetup_value('QTYPARALLEL'),2);
      v_response      varchar2(4000);
      v_countemp      number := 0 ;
      v_data          varchar2(1 char) := 'N';
      v_check         varchar2(1 char) := 'Y';

      v_numemp        number := 0 ;
      v_amtbon        number := 0 ;
      v_amtsal        number := 0 ;
      v_qtybon        number := 0 ;
  begin
      insert_data_parallel(p_codapp,global_v_coduser,v_numproc)  ;

      hraps9b_batch.start_process('HRAPS9B',global_v_coduser,global_v_lang,v_numproc,p_codapp,p_dteyreap,p_numtime,p_codcomp,p_codbon)  ;

      -->> Output
      begin
          select count(codempid), sum(stddec(amtbon,codempid,v_chken)), sum(stddec(amtsal,codempid,v_chken))
            into v_numemp,v_amtbon,v_amtsal
            from ttbonus
           where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codcomp  like p_codcomp||'%'
             and codbon   = p_codbon;
      exception when no_data_found then
          null;
      end;

      if nvl(v_amtsal,0) <> 0 then
          v_qtybon := round(v_amtbon / v_amtsal,2);
      end if;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('qtyemp', nvl(v_numemp,0));
      obj_data.put('bonus', nvl(v_amtbon,0));
      obj_data.put('salary', nvl(v_qtybon,0));

      if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2715',global_v_lang);
          v_response      := get_response_message(null,param_msg_error,global_v_lang);
          obj_data.put('response', hcm_util.get_string(json(v_response),'response'));
          dbms_lob.createtemporary(json_str_output, true);
          obj_row.to_clob(json_str_output);
          json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_payment(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_data_head   json_object_t;
    obj_row         json_object_t;
    v_row		    number := 0;
    v_amtpay        number := 0;
    v_amtbon        number := 0;
    v_difbudg       number := 0;
    v_amtbudg       number;
    v_ratecond      varchar2(1000 char);
    v_typbon        varchar2(1 char);
    --<<User37 #4485 12/10/2021
    v_grade         varchar2(10 char) := '!@#$';
    v_numcond       varchar2(10 char) := '!@#$';
    v_sumamt        number := 0;
    v_sumall        number := 0;
    v_statement     ttbonparc.statement%type;
    v_image         varchar2(1000 char) := '';
    -->>User37 #4485 12/10/2021


    cursor c_ttbonus is
      select codempid,codcomp,codpos,jobgrade,dteempmt,grade,numcond,qtybon,pctdedbo,
             stddec(amtsal,codempid,v_chken) amtsal,
             stddec(amtbon,codempid,v_chken) amtbon
        from ttbonus
       where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codbon   = p_codbon
         and codcomp like p_codcomp||'%'
      order by grade,numcond,codcomp,codempid,codpos;--user37 #4482 08/10/2021

  begin
    initial_value(json_str_input);

    begin
        select typbon,amtbudg into v_typbon,v_amtbudg
          from ttbonparh
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codbon   = p_codbon;
    exception when no_data_found then
        v_typbon  := 1;
        v_amtbudg := 0;
    end;

    --<<User37 #4442 07/10/2021
    begin
        select amtbudg into v_amtbudg
          from tbonparh
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codbon   = p_codbon;
    exception when no_data_found then
        v_amtbudg := 0;
    end;
    -->>User37 #4442 07/10/2021

    obj_row := json_object_t();
    for i in c_ttbonus loop
        --<<User37 #4485 12/10/2021
        if v_typbon = 1 then

            if v_grade <> nvl(i.grade,'!@#$%') then--nvl(v_grade,'!@#$%') <> i.grade then
              if v_grade <> '!@#$' then
                v_row      := v_row + 1;
                obj_data.put('coderror', '200');
                obj_data.put('amtbon', v_sumamt);
                obj_data.put('amtsal', get_label_name('HRAPS9B4',global_v_lang,80));
                obj_data.put('codempid', '');
                obj_data.put('codpos', '');
                obj_data.put('desc_codempid', '');
                obj_data.put('desc_codpos', '');
                obj_data.put('jobgrade','');
                obj_data.put('dteempmt','');
                obj_data.put('qtybon', '');
                obj_data.put('pctdedbo', '');
                obj_data.put('grade', '');
                obj_row.put(to_char(v_row-1),obj_data);
                v_sumamt := 0;
              end if;
              v_grade := nvl(i.grade,'!@#$%');
            end if;
        else
          if v_numcond <> nvl(to_char(i.numcond),'!@#$%') then--nvl(v_grade,'!@#$%') <> i.grade then
              if v_numcond <> '!@#$' then
                v_row      := v_row + 1;
                obj_data.put('coderror', '200');
                obj_data.put('amtbon', v_sumamt);
                obj_data.put('amtsal', get_label_name('HRAPS9B4',global_v_lang,80));
                obj_data.put('codempid', '');
                obj_data.put('codpos', '');
                obj_data.put('desc_codempid', '');
                obj_data.put('desc_codpos', '');
                obj_data.put('jobgrade','');
                obj_data.put('dteempmt','');
                obj_data.put('qtybon', '');
                obj_data.put('pctdedbo', '');
                obj_row.put(to_char(v_row-1),obj_data);
                v_sumamt := 0;
              end if;
              v_numcond := nvl(to_char(i.numcond),'!@#$%');
          end if;
        end if;
        v_sumamt := nvl(i.amtbon,0)+nvl(v_sumamt,0);
        v_sumall := nvl(i.amtbon,0)+nvl(v_sumall,0);
        -->>User37 #4485 12/10/2021
        v_row      := v_row + 1;
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        if v_typbon = 1 then
            obj_data.put('grade', i.grade);
            obj_data.put('grade_s', i.grade);
        else
            obj_data.put('numcond', i.numcond);
            begin
                select ratecond,statement into v_ratecond,v_statement --User37 #4485 12/10/2021 ratecond into v_ratecond
                  from ttbonparc
                 where codcomp  = p_codcomp
                   and dteyreap = p_dteyreap
                   and numtime  = p_numtime
                   and codbon   = p_codbon
                   and numseq   = i.numcond;
            exception when no_data_found then
                null;
            end;
            --<<User37 #4485 12/10/2021
            --obj_data.put('ratecond', v_ratecond);
            obj_data.put('ratecond', get_logical_desc(v_statement));
            -->>User37 #4485 12/10/2021
        end if;
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('dteempmt', to_char(i.dteempmt,'dd/mm/yyyy'));
        obj_data.put('amtsal', to_char(i.amtsal,'fm999,999,990.00') );--User37 #4485 12/10/2021 obj_data.put('amtsal', i.amtsal );
        obj_data.put('qtybon', i.qtybon);
        obj_data.put('pctdedbo', i.pctdedbo);
        obj_data.put('amtbon', i.amtbon);
        v_amtbon := v_amtbon + nvl(i.amtbon,0);
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    --<<User37 #4485 12/10/2021
    if v_row > 0 then
      if v_typbon = 1 then
        v_row      := v_row + 1;
        obj_data.put('coderror', '200');
        obj_data.put('amtbon', v_sumamt);
        obj_data.put('amtsal', get_label_name('HRAPS9B4',global_v_lang,80));
        obj_data.put('codempid', '');
        obj_data.put('codpos', '');
        obj_data.put('desc_codempid', '');
        obj_data.put('desc_codpos', '');
        obj_data.put('jobgrade','');
        obj_data.put('dteempmt','');
        obj_data.put('qtybon', '');
        obj_data.put('pctdedbo', '');
        obj_data.put('grade', '');
        obj_row.put(to_char(v_row-1),obj_data);
        v_row      := v_row + 1;
        obj_data.put('coderror', '200');
        obj_data.put('amtbon', v_sumall);
        obj_data.put('amtsal',get_label_name('HRAPS9B4',global_v_lang,90));
        obj_row.put(to_char(v_row-1),obj_data);
      else
        v_row      := v_row + 1;
        obj_data.put('coderror', '200');
        obj_data.put('amtbon', v_sumamt);
        obj_data.put('amtsal', get_label_name('HRAPS9B4',global_v_lang,80));
        obj_data.put('codempid', '');
        obj_data.put('codpos', '');
        obj_data.put('desc_codempid', '');
        obj_data.put('desc_codpos', '');
        obj_data.put('jobgrade','');
        obj_data.put('dteempmt','');
        obj_data.put('qtybon', '');
        obj_data.put('pctdedbo', '');
        obj_row.put(to_char(v_row-1),obj_data);
        v_row      := v_row + 1;
        obj_data.put('coderror', '200');
        obj_data.put('amtbon', v_sumall);
        obj_data.put('amtsal',get_label_name('HRAPS9B4',global_v_lang,90));
        obj_row.put(to_char(v_row-1),obj_data);
      end if;
    end if;
    -->>User37 #4485 12/10/2021

    v_difbudg := v_amtbon - v_amtbudg;
    obj_data_head := json_object_t();
    obj_data_head.put('coderror', '200');
    obj_data_head.put('amtbon', to_char(nvl(v_amtbudg,0),'fm999,999,999,990.00'));
    obj_data_head.put('difbudg', to_char(nvl(v_difbudg,0),'fm999,999,999,990.00'));
    obj_data_head.put('table', obj_row);

    if param_msg_error is null then
      json_str_output := obj_data_head.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_payment;
  --
  --
  procedure check_save(json_str_input in clob) is
    v_codcomp     tcenter.codcomp%type;
    param_json    json_object_t;
    obj_detail    json_object_t;
    obj_stmt      json_object_t;
    obj_form1     json_object_t;
    obj_form2     json_object_t;

    v_dtestr      tbonparh.dtestr%type;
    v_dteend      tbonparh.dteend%type;
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
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    obj_detail    := hcm_util.get_json_t(param_json,'detail');
    obj_stmt      := hcm_util.get_json_t(obj_detail,'syncond1');
    obj_form1     := hcm_util.get_json_t(obj_detail,'syncond3');
    obj_form2     := hcm_util.get_json_t(obj_detail,'syncond2');

    v_boncond     := hcm_util.get_string_t(obj_stmt,'code');
    v_salcond     := hcm_util.get_string_t(obj_form1,'code');
    v_formula     := hcm_util.get_string_t(obj_form2,'code');
    v_dtestr      := hcm_util.get_string_t(obj_detail,'dtestrt');
    v_dteend      := hcm_util.get_string_t(obj_detail,'dteend');
    v_typbon      := hcm_util.get_string_t(obj_detail,'typbon');
    v_grdyear     := hcm_util.get_string_t(obj_detail,'grdyear');
    v_grdnumtime  := hcm_util.get_string_t(obj_detail,'numtime');
    v_flgprorate  := hcm_util.get_string_t(obj_detail,'flgprort');
    v_dteeffsal   := to_date(hcm_util.get_string_t(obj_detail,'dteeffsal'),'dd/mm/yyyy');

    if v_typbon is null or v_flgprorate is null or v_dteeffsal is null or
       v_boncond is null or v_salcond is null or v_formula is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
--    if v_typbon = '1' then
--      if v_grdyear is null or v_grdnumtime is null then
--        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
--        return;
--      end if;
--    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
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
    v_codappr     ttbonparh.codappr%type;
    v_dteappr     ttbonparh.dteappr%type;
    v_flg	          varchar2(100 char);
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
    v_staemp        temploy1.staemp%type;
    --<<nut 
    cursor c_ttbonparc is
      select ratebon,amttbon,numseq,ratecond,statement
        from ttbonparc
       where codcomp  = p_codcomp
         and codbon   = p_codbon
         and dteyreap = p_dteyreap
         and numtime  = p_numtime;

    cursor c_ttbonpard is
      select ratebon,amttbon,numseq,grade
        from ttbonpard
       where codcomp  = p_codcomp
         and codbon   = p_codbon
         and dteyreap = p_dteyreap
         and numtime  = p_numtime;
    -->>nut 

  begin
    initial_value(json_str_input);
    check_index;
    check_save(json_str_input);
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    obj_detail    := hcm_util.get_json_t(param_json,'detail');
    obj_table1    := hcm_util.get_json_t(param_json,'table1');
    obj_table2    := hcm_util.get_json_t(param_json,'table2');
    obj_stmt      := hcm_util.get_json_t(obj_detail,'syncond1');
    obj_form1     := hcm_util.get_json_t(obj_detail,'syncond2');
    obj_form2     := hcm_util.get_json_t(obj_detail,'syncond3');

    v_boncond     := hcm_util.get_string_t(obj_stmt,'code');
    v_salcond     := hcm_util.get_string_t(obj_form1,'code');
    v_formula     := hcm_util.get_string_t(obj_form2,'code');
    v_stmtboncond     := hcm_util.get_string_t(obj_stmt,'statement');
    v_stmtsalcond     := hcm_util.get_string_t(obj_form1,'description');
    v_stmtformula     := hcm_util.get_string_t(obj_form2,'description');
    v_dtestr      := to_date(hcm_util.get_string_t(obj_detail,'dtestrt'),'dd/mm/yyyy');
    v_dteend      := to_date(hcm_util.get_string_t(obj_detail,'dteend'),'dd/mm/yyyy');
    v_typbon      := hcm_util.get_string_t(obj_detail,'typbon');
    v_grdyear     := hcm_util.get_string_t(obj_detail,'grdyear');
    v_grdnumtime  := hcm_util.get_string_t(obj_detail,'numtime');
    v_flgprorate  := hcm_util.get_string_t(obj_detail,'flgprort');
    v_dteeffsal   := to_date(hcm_util.get_string_t(obj_detail,'dteeffsal'),'dd/mm/yyyy');
    v_flgcal      := nvl(hcm_util.get_string_t(obj_detail,'flgcal'),'N');
    v_codappr     := hcm_util.get_string_t(obj_detail,'codappr');
    v_dteappr     := to_date(hcm_util.get_string_t(obj_detail,'dteappr'),'dd/mm/yyyy');
    v_amtbudg     := hcm_util.get_string_t(obj_detail,'amtbudg');--User37 #4442 07/10/2021

    begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = v_codappr;
    exception when others then
        v_staemp := null;
    end;

    if v_staemp = '9' then
      param_msg_error := get_error_msg_php('HR2101', global_v_lang);
    elsif  v_staemp = '0' then
      param_msg_error := get_error_msg_php('HR2102', global_v_lang);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
--
--    if param_msg_error is null then
      begin
        insert into ttbonparh(codcomp,codbon,dteyreap,numtime,dtestr,dteend,
                             typbon,dteeffsal,boncond,salcond,formula,stmtboncond,stmtsalcond,stmtformula,
                             flgcal,grdyear,grdnumtime,flgprorate,
                             amtbudg,--User37 #4442 07/10/2021
                             codappr,dteappr,codcreate,coduser)
        values (p_codcomp, p_codbon, p_dteyreap, p_numtime, v_dtestr, v_dteend,
                v_typbon, v_dteeffsal, v_boncond, v_salcond, v_formula, v_stmtboncond, v_stmtsalcond, v_stmtformula,
                v_flgcal, v_grdyear, v_grdnumtime, v_flgprorate,
                v_amtbudg,--User37 #4442 07/10/2021
                v_codappr, v_dteappr, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update ttbonparh
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
                flgprorate	=	v_flgprorate,
                codappr = v_codappr,
                dteappr = v_dteappr,
                dteupd = sysdate,
                amtbudg = v_amtbudg,--User37 #4442 07/10/2021
                coduser = global_v_coduser
         where codcomp = p_codcomp
           and dteyreap = p_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime;
      end;
--      --
--
--    end if;
--    begin
--      delete tbonpard
--       where codcomp = b_index_codcomp
--         and dteyreap = b_index_dteyreap
--         and codbon = p_codbon
--         and numtime = p_numtime;
--    end;
    for i in 0..obj_table1.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(obj_table1,to_char(i));
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_grade         := hcm_util.get_string_t(param_json_row,'grade');
      v_ratebonc      := hcm_util.get_string_t(param_json_row,'int');
      v_amttbonc      := hcm_util.get_string_t(param_json_row,'price');

      --<<nut 
      /*if v_codappr is not null and v_dteappr is not null then--User37 #4442 07/10/2021 if v_flg = 'edit' then

        begin
          update tbonpard
             set grade	=	v_grade,
                 ratebonc	=	v_ratebonc,
                 amttbonc	=	v_amttbonc,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcomp = p_codcomp
             and dteyreap = p_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime
             and numseq = v_numseq;
        exception when others then
          null;
        end;
      end if;*/
      -->>nut 

      --<<User37 #4442 07/10/2021
      begin
        insert into ttbonpard(codcomp,codbon,dteyreap,numtime,
                              numseq,grade,ratebon,amttbon,
                              dtecreate,codcreate,dteupd,coduser)
                      values (p_codcomp, p_codbon, p_dteyreap, p_numtime,
                                v_numseq, v_grade, v_ratebonc, v_amttbonc,
                                sysdate,global_v_coduser,sysdate, global_v_coduser);
      exception when dup_val_on_index then
        update ttbonpard
           set grade = v_grade,
               ratebon = v_ratebonc,
               amttbon = v_amttbonc,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcomp = p_codcomp
           and dteyreap = p_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime
           and numseq = v_numseq;
      end;
      -->>User37 #4442 07/10/2021
    end loop;
--
    for i in 0..obj_table2.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(obj_table2,to_char(i));
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_ratebonc      := hcm_util.get_string_t(param_json_row,'rtepay');
      v_amttbonc      := hcm_util.get_string_t(param_json_row,'total');
      obj_stmt        := hcm_util.get_json_t(param_json_row,'syncond');
      v_ratecond      := hcm_util.get_string_t(obj_stmt,'code');
      v_statement     := hcm_util.get_string_t(obj_stmt,'statement');

      --<<nut 
      /*if v_codappr is not null and v_dteappr is not null then--User37 #4442 07/10/2021 if v_flg = 'edit' then
        begin
          update tbonparc
             set ratecond	=	v_ratecond,
                 statement	=	v_statement,
                 ratebonc	=	v_ratebonc,
                 amttbonc	=	v_amttbonc,
                 dteupd = sysdate,
                 coduser = global_v_coduser
           where codcomp = p_codcomp
             and dteyreap = p_dteyreap
             and codbon = p_codbon
             and numtime = p_numtime
             and numseq = v_numseq;
        exception when others then
          null;
        end;
      end if;*/
      -->>nut 

      --<<User37 #4485 12/10/2021
      begin
        insert into ttbonparc(codcomp,codbon,dteyreap,numtime,
                              numseq,ratecond,statement,ratebon,amttbon,
                              dtecreate,codcreate,dteupd,coduser)
                      values (p_codcomp, p_codbon, p_dteyreap, p_numtime,
                                v_numseq, v_ratecond,v_statement, v_ratebonc, v_amttbonc,
                                sysdate,global_v_coduser,sysdate, global_v_coduser);
      exception when dup_val_on_index then
        update ttbonparc
           set ratecond = v_ratecond,
               statement = v_statement,
               ratebon = v_ratebonc,
               amttbon = v_amttbonc,
               dteupd = sysdate,
               coduser = global_v_coduser
         where codcomp = p_codcomp
           and dteyreap = p_dteyreap
           and codbon = p_codbon
           and numtime = p_numtime
           and numseq = v_numseq;
      end;
      -->>User37 #4485 12/10/2021
    end loop;

    --<<nut 
    if v_codappr is not null and v_dteappr is not null then
      if v_typbon = '1' then--1-ตามผลการประเมิน tbonpard, 2-ตามเงื่อนไข tbonparc
        for r_ttbonpard in c_ttbonpard loop
          begin
            update tbonpard
               set grade     = r_ttbonpard.grade,
                   ratebon   = r_ttbonpard.ratebon,
                   amttbon   = r_ttbonpard.amttbon,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where codcomp   = p_codcomp
               and dteyreap  = p_dteyreap
               and codbon    = p_codbon
               and numtime   = p_numtime
               and numseq    = r_ttbonpard.numseq;
          exception when others then
            null;
          end;
        end loop;
      elsif v_typbon = '2' then
        for r_ttbonparc in c_ttbonparc loop
          begin
            update tbonparc
               set ratecond  = r_ttbonparc.ratecond,
                   statement = r_ttbonparc.statement,
                   ratebon   = r_ttbonparc.ratebon,
                   amttbon   = r_ttbonparc.amttbon,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where codcomp   = p_codcomp
               and dteyreap  = p_dteyreap
               and codbon    = p_codbon
               and numtime   = p_numtime
               and numseq    = r_ttbonparc.numseq;
          exception when others then
            null;
          end;
        end loop;
      end if;
    end if;
    -->>nut 

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
end HRAPS9B;

/

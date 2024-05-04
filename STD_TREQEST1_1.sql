--------------------------------------------------------
--  DDL for Package Body STD_TREQEST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_TREQEST1" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_numreqst          := hcm_util.get_string_t(json_obj,'p_numreqst');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure get_tab1(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tab1(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tab1(json_str_output out clob)as
    obj_data        json_object_t;
    treqest1_rec    treqest1%ROWTYPE;
  begin
    begin
      select * into treqest1_rec
        from treqest1
       where numreqst = p_numreqst;
    exception when no_data_found then
      treqest1_rec := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', '');
    obj_data.put('numreqst', p_numreqst);
    obj_data.put('numreqstcopy', nvl(treqest1_rec.numreqstcopy,'-') ) ;
    obj_data.put('codcomp', treqest1_rec.codcomp ) ;
    obj_data.put('desc_codcomp', get_tcenter_name(treqest1_rec.codcomp,global_v_lang) ) ;
    obj_data.put('codemprq', treqest1_rec.codemprq ) ;
    obj_data.put('desc_codemprq', get_temploy_name(treqest1_rec.codemprq, global_v_lang) ) ;
    obj_data.put('dtereq', to_char(treqest1_rec.dtereq, 'dd/mm/yyyy') ) ;
    obj_data.put('codempap', treqest1_rec.codempap ) ;
    obj_data.put('desc_codempap', get_temploy_name(treqest1_rec.codempap, global_v_lang) ) ;
    obj_data.put('dteaprov',  to_char(treqest1_rec.dteaprov, 'dd/mm/yyyy') ) ;
    obj_data.put('codemprc', treqest1_rec.codemprc ) ;
    obj_data.put('desc_codemprc', get_temploy_name(treqest1_rec.codemprc, global_v_lang) ) ;
    obj_data.put('codintview', treqest1_rec.codintview ) ;
    obj_data.put('desc_codintview', get_temploy_name(treqest1_rec.codintview, global_v_lang)) ;
    obj_data.put('codappchse', treqest1_rec.codappchse ) ;
    obj_data.put('desc_codappchse', get_temploy_name(treqest1_rec.codappchse, global_v_lang) ) ;
    obj_data.put('stareq', treqest1_rec.stareq ) ;
    obj_data.put('dterec',  to_char(treqest1_rec.dterec, 'dd/mm/yyyy') ) ;
    obj_data.put('filename', treqest1_rec.filename ) ;
    obj_data.put('desnote', treqest1_rec.desnote ) ;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tab1;
  --
   procedure gen_tab2(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_data2       json_object_t;
    obj_row2        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_statement     tjobcode.statement%type;
    v_codpos        tjobpost.codpos%type;
    cursor c1 is
      select *
        from treqest2
       where numreqst = p_numreqst
       order by codpos;
    cursor c2 is
      select dtepost, codjobpost
        from tjobpost
       where numreqst = p_numreqst
         and codpos = v_codpos
       order by dtepost;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response','');
      obj_data.put('codpos',r1.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos, global_v_lang));
      obj_data.put('codjob', r1.codjob );
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob, global_v_lang) );
      obj_data.put('codempmt', r1.codempmt );
      obj_data.put('desc_codempmt', get_tcodec_name('TCODEMPL', r1.codempmt, global_v_lang) );
      obj_data.put('codbrlc', r1.codbrlc );
      obj_data.put('desc_codbrlc', get_tcodec_name('TCODLOCA', r1.codbrlc, global_v_lang) );
      obj_data.put('amtincom', to_char(r1.amtincom,'fm999,999,990.00') );
      obj_data.put('flgrecut', get_tlistval_name('FLGRECUT', r1.flgrecut, global_v_lang) );
      obj_data.put('dtereqm', to_char(r1.dtereqm,'dd/mm/yyyy') );
      obj_data.put('dteopen', to_char(r1.dteopen,'dd/mm/yyyy') );
      obj_data.put('dteclose', to_char(r1.dteclose,'dd/mm/yyyy') );
      obj_data.put('codrearq', r1.codrearq );
      obj_data.put('desc_codrearq', get_tlistval_name('TCODREARQ', r1.codrearq ,global_v_lang) );
      obj_data.put('codempr', r1.codempr );
      obj_data.put('desc_codempr', get_temploy_name(r1.codempr, global_v_lang) );
      obj_data.put('syncond', get_logical_desc(r1.statement) );
      obj_data.put('flgjob', r1.flgjob);
      obj_data.put('flgcond', r1.flgcond );
      obj_data.put('desnote', r1.desnote );
      obj_data.put('qtyreq', r1.qtyreq );
      obj_data.put('qtyact', r1.qtyact );
      obj_data.put('qtymin', r1.qtyreq - r1.qtyact );
      if r1.flgjob = 'Y' then
        begin
          select statement into v_statement
          from tjobcode
          where codjob = r1.codjob;
        exception when no_data_found then
          v_statement := null;
        end;
        obj_data.put('syncond_flgjob', get_logical_desc(v_statement) );
      else
        obj_data.put('syncond', '-' );
      end if;

      if (trunc(sysdate) - trunc(r1.dtereqm)) > 0 then
        obj_data.put('over_due', (trunc(sysdate) - trunc(r1.dtereqm) + 1) );
      else
        obj_data.put('over_due', '-' );
      end if;

      v_codpos := r1.codpos;
      obj_row2 := json_object_t();
      v_rcnt2 := 0;
      for r2 in c2 loop
        obj_data2 := json_object_t();
        obj_data2.put('coderror', '200');
        obj_data2.put('response','');
        obj_data2.put('dtepost', to_char(r2.dtepost,'dd/mm/yyyy'));
       -- obj_data2.put('codjobpost',r2.codjobpost);  --#7261 || USER39 || 08/12/2021
        obj_data2.put('codjobpost',get_tcodec_name('TCODJOBPOST',r2.codjobpost,global_v_lang)); --#7261 || USER39 || 08/12/2021

        obj_row2.put(to_char(v_rcnt2), obj_data2);
        v_rcnt2 := v_rcnt2 + 1;
      end loop;
      obj_data.put('children', obj_row2 );
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

  procedure get_tab2(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tab2(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end std_treqest1;

/

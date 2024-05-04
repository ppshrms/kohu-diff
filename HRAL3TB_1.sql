--------------------------------------------------------
--  DDL for Package Body HRAL3TB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3TB" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
--    p_timtran           := hcm_util.get_string_t(json_obj,'p_timtran');
    p_stdate            := to_date(hcm_util.get_string_t(json_obj,'p_stdate'),'dd/mm/yyyy');
    p_endate            := to_date(hcm_util.get_string_t(json_obj,'p_endate'),'dd/mm/yyyy');
    p_filetype          := hcm_util.get_string_t(json_obj,'p_filetype');
    p_typmatch          := hcm_util.get_string_t(json_obj,'p_typmatch');
    p_filename          := hcm_util.get_string_t(json_obj,'p_filename');
    p_dayetrn           := to_date(hcm_util.get_string_t(json_obj,'p_dayetrn'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_staemp      varchar2(1 char);
    v_flgsecu     boolean	:= null;
    v_codcomp     varchar2(4000 char);
  begin
    if p_codempid is not null then
      begin
        select codcomp, staemp
          into p_codcomp, v_staemp
          from temploy1
         where codempid = p_codempid;
        v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
          return;
        end if;
        /*if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2101',global_v_lang);
          return;
        end if;*/
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codempid');
        return;
      end;
    else
      begin
        select codcompy
          into v_codcomp
          from tcenter
         where codcomp like p_codcomp||'%'
           and rownum <= 1;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcomp');
        return;
      end;
      v_flgsecu := secur_main.secur7(v_codcomp, global_v_coduser);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
        return;
      end if;
    end if;
  end;

  function check_date (p_date in varchar2) return boolean is
    v_date		date;
    v_error		boolean := true;
  begin
    if p_date is not null then
      begin
        v_date := to_date(p_date,'dd/mm/yyyy');
      exception when others then
        v_error := false;
        return(v_error);
      end;
    end if;
    return(v_error);
  end;

  function check_time (p_time in varchar2) return boolean is
    v_stmt			varchar2(500);
    v_time			varchar2(4);
  begin
    v_stmt := 'select to_char(to_date('''||p_time||
              ''',''hh24mi''),''hh24mi'') from dual';
    v_time := execute_desc(v_stmt);
    if v_time is null then
      return(false);
    else
      return(true);
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_codcompy      tcontral.codcompy%type;
    v_dayetrn       date;
  begin
  	if p_codcomp is not null then
      v_codcompy := get_comp_split(p_codcomp,1);
    else
      begin
        select get_comp_split(codcomp,1) into v_codcompy
        from   temploy1
        where  codempid = p_codempid;
      exception when no_data_found then
        v_codcompy := null;
      end;
    end if;
    begin
      select dayetrn into v_dayetrn
      from tcontral
      where codcompy = v_codcompy
        and dteeffec = (select max(dteeffec)
                       from tcontral
                       where codcompy = v_codcompy
                       and   dteeffec <= sysdate)
        and rownum <= 1;
    exception when no_data_found then
      v_dayetrn := null;
    end;
    obj_row    := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('dayetrn', to_char(v_dayetrn,'dd/mm/yyyy'));

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure data_process(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      if p_filetype = '1' then
        gen_file_of_time(json_str_input, json_str_output);
      elsif p_filetype = '2' then
        gen_text_file(json_str_input, json_str_output);
      elsif p_filetype = '3' then
        gen_transfer_time(json_str_output);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

    -- finish batch process
    hcm_batchtask.finish_batch_process(
      p_codapp   => global_v_batch_codapp,
      p_coduser  => global_v_coduser,
      p_codalw   => global_v_batch_codalw,
      p_dtestrt  => global_v_batch_dtestrt,
      p_flgproc  => global_v_batch_flgproc,
      p_qtyproc  => global_v_batch_qtyproc,
      p_qtyerror => global_v_batch_qtyerror,
      p_oracode  => param_msg_error
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end;

  procedure gen_file_of_time(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_sumtrn        number  := 0;
    v_sumerr        number  := 0;
    v_flgsecu       boolean := false;
    v_rcnt          number  := 0;
    --
    v_text          data_error_array;
    v_numseq        data_error_array;
  begin
    v_text   := new data_error_array();
    v_numseq := new data_error_array();
    --
    if param_msg_error is null then
      hral3tb_batch.import_text_file (json_str_input,p_typmatch,global_v_coduser,v_error,v_sumtrn,v_sumerr,v_text,v_numseq);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', to_char(v_sumtrn));
    obj_row.put('rec_err', to_char(v_sumerr));
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if v_numseq.exists(v_numseq.first) then
      for i in v_numseq.first .. v_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', v_text(i)||' ['||v_error||']');
        obj_data.put('error_code', '');
        obj_data.put('numseq', v_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;
    --
    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_text_file(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);
    --
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_transfer_time(json_str_output out clob) as
    obj_row         json_object_t;
    obj_result      json_object_t;
    obj_error       json_object_t;
    obj_row_error   json_object_t;
    v_rec_tran      number := 0;
    v_rec_err       number := 0;
    v_sumtrn        number := 0;
    v_sumerr        number := 0;
    v_rcnt          number := 0;
    v_count         number := 0;
    v_typmatch      varchar2(1000 char);
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_secur         boolean := false;
    v_codempid      varchar2(1000 char);
    v_dayetrn       date;
    v_codcompy      varchar2(1000 char);
    v_numrec        number := 0;    

    /*cursor c_emp is
      select codempid,codcomp,codcalen
        from temploy1
       where codempid = nvl(p_codempid,codempid)
         and codcomp  like p_codcomp
         and (staemp  in ('1','3')
          or (staemp  = '9' and dteeffex > p_stdate))
      order by codempid;*/

    cursor c_emp is
      select codempid,codcomp,codcalen
        from temploy1 a
       where codempid = nvl(p_codempid,codempid)
         and codcomp  like p_codcomp
         and exists (select b.codempid
                       from tattence b
                      where a.codempid = b.codempid
                        and b.dtework between p_stdate and p_endate)
      order by codempid;

    cursor c_tempcard is
      select numcard,dtestrt,dteend,codempid
        from tempcard
       where codempid  = v_codempid
      order by numcard,dtestrt;

    cursor c_tcontral is
      select codcompy,dteeffec,rowid
        from tcontral
       where codcompy = v_codcompy
      order by codcompy,dteeffec for update;

    cursor c_terror is
        select codbadge,coderr,codrecod,dtework,timtime
        from terror
       where dtework between p_stdate and p_endate
    order by dtework;        
  begin
    check_index;
    if param_msg_error is null then
      for r_emp in c_emp loop
        v_flgsecu := secur_main.secur2(r_emp.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
          v_secur := true;
          v_codempid := r_emp.codempid;
          for r_tempcard in c_tempcard loop
            update tatmfile
               set codempid  = r_tempcard.codempid
             where codbadge  = r_tempcard.numcard
               and(dtedate between r_tempcard.dtestrt and r_tempcard.dteend
                or(dtedate >= r_tempcard.dtestrt      and r_tempcard.dteend is null));
            commit;
          end loop;
          hral3tb_batch.transfer_time(r_emp.codempid,
                                      p_stdate,p_endate,global_v_coduser,
                                      'M',v_rec_tran,v_rec_err);
          --
          hral3tb_batch.upd_att_log(r_emp.codempid,global_v_coduser,p_stdate,p_endate,'M');
          std_al.cal_tattence(r_emp.codempid,p_stdate,p_endate,global_v_coduser,v_numrec);
        end if;
        v_count := v_count+1;
      end loop;
      if p_endate > p_dayetrn or p_dayetrn is null then
          for r_tcontral in c_tcontral loop
              update tcontral set dayetrn = p_endate,
                                  coduser = global_v_coduser
              where rowid = r_tcontral.rowid;
          end loop;
          v_dayetrn := p_endate;
      end if;
      obj_error := json_object_t();

      for r1 in c_terror loop
        v_rcnt          := v_rcnt + 1;
        obj_row_error   := json_object_t();
        obj_row_error.put('numseq', v_rcnt);
        obj_row_error.put('text', r1.codbadge || '|' || r1.dtework || '|' ||r1.timtime);
        obj_row_error.put('error_code', get_errorm_name(r1.coderr,global_v_lang));
        obj_row_error.put('codrecod', r1.codrecod);
        obj_error.put(to_char(v_rcnt-1),obj_row_error);

        -- insert batch process detail
        hcm_batchtask.insert_batch_detail(
          p_codapp   => global_v_batch_codapp,
          p_coduser  => global_v_coduser,
          p_codalw   => global_v_batch_codalw,
          p_dtestrt  => global_v_batch_dtestrt,
          p_item01  => to_char(v_rcnt),
          p_item02  => r1.codbadge || '|' || r1.dtework || '|' ||r1.timtime,
          p_item03  => get_errorm_name(r1.coderr,global_v_lang),
          p_item04  => r1.codrecod
        );
      end loop;
      global_v_batch_qtyerror := v_rcnt;

      if v_secur and v_count > 0 then
        commit;
        obj_row    := json_object_t();
        obj_result := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('rec_tran', v_rec_tran);
        obj_row.put('rec_err', v_rec_err);
        obj_row.put('dayetrn', to_char(v_dayetrn,'dd/mm/yyyy'));
        obj_row.put('err_import', v_error);
        obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        obj_row.put('datadisp', obj_error);
        obj_row.put('details', obj_result);

        -- set complete batch process
        global_v_batch_flgproc  := 'Y';
        global_v_batch_qtyproc  := v_rec_tran;

      else
        rollback;
        obj_row    := json_object_t();
        obj_result := json_object_t();
        obj_row.put('coderror', '401');
        obj_row.put('response', replace(get_error_msg_php('HR3005',global_v_lang),'@#$%401',null));
        obj_row.put('details', obj_result);
        param_msg_error := replace(get_error_msg_php('HR3005',global_v_lang),'@#$%401',null);
      end if;
      json_str_output := obj_row.to_clob;
    else
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '400');
      obj_row.put('response', replace(param_msg_error,'@#$%400',null));
      obj_row.put('details', obj_result);
      param_msg_error := replace(param_msg_error,'@#$%401',null);

      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );

  end;

  procedure get_transfer_report(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgsecu     boolean := false;
    v_exists      boolean := false;
    cursor c1 is
      select b.codempid,b.codcomp,a.dtedate,a.timtime,a.codbadge,a.codrecod,a.flgtranal,a.rowid
        from tatmfile a,temploy1 b
       where a.codempid = b.codempid
         and b.codempid = nvl(p_codempid,b.codempid)
         and b.codcomp like nvl(p_codcomp,'%')
         and a.dtedate between p_stdate and p_endate
      order by b.codcomp,b.codempid,a.dtetime,a.codbadge;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        v_exists   := true;
        -- break codcomp 10 level
--          for i in 1..10 loop
--            comp_label(r1.codcomp,v_codcomp,i,global_v_lang,v_complb1,v_complb2,v_comlevel);
--            if v_comlb2 in not null then
--              v_item01  := v_complb1;
--              v_item02  := v_complb2;
--              v_flgbrk  := i;
--            end if;
--          end loop;
        --
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtedate', to_char(r1.dtedate,'dd/mm/yyyy'));
        obj_data.put('timtime', substr(r1.timtime,1,2)||':'||substr(r1.timtime,3,2));
        obj_data.put('codbadge', r1.codbadge);
        obj_data.put('codrecod', r1.codrecod);
        obj_data.put('flgtranal', r1.flgtranal);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_exists then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_list_ttexttrn (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_ttexttrn is
      select typmatch, nammatch
        from ttexttrn
      order by typmatch;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for r1 in c_ttexttrn loop
      v_rcnt      := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('typmatch', r1.typmatch);
      obj_data.put('nammatch', r1.nammatch);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    data_file 	     varchar2(6000);
    linebuf  		     varchar2(6000);
    v_codempid	     varchar2(4000);
    v_dtework        tattence.dtework%type;
    v_codshift       varchar2(4000);
    v_dtestrtw       tattence.dtework%type;
    v_dteendw        tattence.dtework%type;
    v_timstrtw       varchar2(4000);
    v_timendw        varchar2(4000);
    v_typwork        varchar2(4000);
    v_codchng 	     varchar2(4000); --24/09/2021
    v_flgfound       boolean;
    v_error			     boolean;
    i 					     number;
    j 					     number;
    k 					     number;
    v_filename       varchar2(100);
    v_err_code       varchar2(1000);
    v_err_table      varchar2(1000);
    v_err_filed      varchar2(1000);
    v_found          varchar2(1);
    v_numseq         number := 0  ;
    v_comments       varchar2(1000);
    v_namtbl         varchar2(100);
    v_timeout        number:= get_tsetup_value('TIMEOUT') ;
    v_codapp  	     varchar2(15);
    v_cnt					   number := 0;
    v_rownum    	   number := 0;
    v_num            number := 0;
    v_column			   number := 9; --24/09/2021|| 8;
    -- log value --
    v_dtein 	       date;
    v_timin		       varchar2(10);
    v_dteout         date;
    v_timout	       varchar2(10);

    v_dtein_o 	     date;
    v_timin_o		     varchar2(10);
    v_dteout_o       date;
    v_timout_o	     varchar2(10);

    v_typwork_o      varchar2(10);
    v_codshift_o     varchar2(10);
    v_codchng_o	     varchar2(4); --24/09/2021
    v_typwork_n      varchar2(10);
    v_codshift_n     varchar2(10);
    v_codchng_n	     varchar2(4); --24/09/2021
    --<<user36 SEA-HR2201 #731 09/02/2023
    v_qtylate       number;
    v_qtyearly      number;
    v_qtyabsent     number;
    v_numrec        number;
    -->>user36 SEA-HR2201 #731 09/02/2023
    --
    TYPE text IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
      v_text   text;
      t_date   text;
      v_label  text;
      v_filed  text;
    TYPE timchar IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
      v_time	timchar;
    TYPE dtedate IS TABLE OF DATE INDEX BY BINARY_INTEGER;
      v_date	dtedate;

    cursor c_tattence is
      select codempid,dtework,dtein,timin,dteout,timout,
             codshift,dtestrtw,timstrtw,dteendw,timendw,typwork,rowid,
             codcomp,codchng
      from   tattence
      where  codempid = v_codempid
      and    dtework  = v_dtework
      order by codempid,dtework
      for update;
  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(i));
--      json_obj_list   := param_json_row.get_values;
      v_rownum        := v_rownum + 1;
      --
      v_codapp   := 'HRAL32BC1';
      v_label(1) := get_label_name(v_codapp,global_v_lang,910);
      v_label(2) := get_label_name(v_codapp,global_v_lang,920);
      v_label(3) := get_label_name(v_codapp,global_v_lang,930);
      v_label(4) := get_label_name(v_codapp,global_v_lang,940);
      begin
        linebuf     := i;
        v_comments  := null;
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;
        v_found     := 'F';
        --
        if v_numseq = 0 then
          <<cal_loop>>
          loop
            for i in 1 .. 14 loop
              if  i <= 4 then
                v_date(i) := null;
              end if;
              v_text(i) := null;
            end loop;
            -- clear data --
            v_timstrtw  := null; v_timendw  := null;
            v_dtestrtw  := null; v_dteendw  := null;

            -- get param from json --
            v_text(1)   := hcm_util.get_string_t(param_json_row,'codempid');
            v_text(2)   := hcm_util.get_string_t(param_json_row,'dtework');
            v_text(3)   := hcm_util.get_string_t(param_json_row,'dtein');
            v_text(4)   := hcm_util.get_string_t(param_json_row,'timin');
            v_text(5)   := hcm_util.get_string_t(param_json_row,'dteout');
            v_text(6)   := hcm_util.get_string_t(param_json_row,'timout');
            v_text(7)   := hcm_util.get_string_t(param_json_row,'codshift');
            v_text(8)   := hcm_util.get_string_t(param_json_row,'typwork');
            v_text(9)   := hcm_util.get_string_t(param_json_row,'codchng'); --24/09/2021
            --
            data_file := null;
            for i in 1..14 loop
              if data_file is null then
                data_file := v_text(i);
              else
                data_file := data_file||','||v_text(i);
              end if;
            end loop;
            --
            if length(v_text(1)) > 10 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(1);
              exit cal_loop; --24/09/2021
            end if;
            --<<24/09/2021
            if length(v_text(4)) > 4 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(4);
              exit cal_loop;
            end if;
            if length(v_text(6)) > 4 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(6);
              exit cal_loop;
            end if;
            if length(v_text(7)) > 4 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(7);
              exit cal_loop;
            end if;
            if length(v_text(8)) > 1 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(8);
              exit cal_loop;
            end if;
            if length(v_text(9)) > 4 then
              v_error    := true;
              v_err_code := 'HR2020';
              v_err_filed := v_filed(9);
              exit cal_loop;
            end if;
            -->>
            --
            /*24/09/2021
            if v_error then
              exit cal_loop;
            end if;*/
            -- CODEMPID
            if v_text(1) is null then --24/09/2021
              v_error    := true;
              v_err_code := 'HR2045';
              v_err_filed := v_filed(1);
              exit cal_loop;
            else
              begin
                select codempid into v_codempid
                from  temploy1
                where codempid = upper(v_text(1));
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TEMPLOY1';
                v_err_filed := v_filed(1);
                exit cal_loop;
              end;
            end if;
            v_codempid := upper(v_text(1));
            -- DTEWORK
            v_flgfound := check_date(v_text(2));
            if not v_flgfound or v_text(2) is null then --24/09/2021 || or v_codempid is null then
              v_error    := true;
              v_err_code := 'HR2045'; --24/09/2021 'HR2010';
              v_err_filed := v_filed(2);
              exit cal_loop;
            else
              v_dtework := to_date(v_text(2),'dd/mm/yyyy');
              begin --24/09/2021
                select codempid into v_codempid
                from  tattence
                where codempid = v_codempid
                and   dtework  = v_dtework;
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2055';
                v_err_table := 'TATTENCE';
                v_err_filed := v_filed(2);
                exit cal_loop;
              end;
            end if;
            --
            t_date(1) 	:= v_text(3);
            v_time(1) 	:= v_text(4);
            t_date(2) 	:= v_text(5);
            v_time(2) 	:= v_text(6);
            --
            v_codshift 	:= upper(v_text(7));
            v_typwork 	:= upper(v_text(8));
            v_codchng 	:= upper(v_text(9)); --24/09/2021
            --
            for i in 1..2 loop
              if t_date(i) is not null and v_time(i) is null then
                v_error    := true;
                v_err_code := 'HR2045';
                if i=1 and v_time(1) is null then
                  v_comments  := '('||v_label(2)||')';
                  v_err_filed := v_filed(2);
                elsif i=2 and v_time(2) is null then
                  v_comments  := '('||v_label(4)||')';
                  v_err_filed := v_filed(4);
                end if;
                exit cal_loop;
              elsif t_date(i) is null and v_time(i) is not null then
                v_error    := true;
                v_err_code := 'HR2045';
                if i=1 and t_date(1) is null then
                  v_comments  := '('||v_label(1)||')';
                  v_err_filed := v_filed(1);
                elsif i=2 and t_date(2) is null then
                  v_comments  := '('||v_label(3)||')';
                  v_err_filed := v_filed(3);
                end if;
                exit cal_loop;
              elsif t_date(i) is not null and v_time(i) is not null then
                v_flgfound := check_date(t_date(i));
                if v_flgfound then
                  v_date(i) := to_date(t_date(i),'dd/mm/yyyy');
                else
                  v_error     := true;
                  v_err_code  := 'HR2025';
                  --
                  if (i = '1') then
                    v_err_filed := v_filed(3);
                  elsif (i = '2') then
                    v_err_filed := v_filed(5);
                  end if;
                  --
                  exit cal_loop;
                end if;
                v_flgfound := check_time(v_time(i));
                if not v_flgfound then
                  v_error     := true;
                  v_err_code  := 'HR2015';
                  --
                  if (i = '1') then
                    v_err_filed := v_filed(4);
                  elsif (i = '2') then
                    v_err_filed := v_filed(6);
                  end if;
                  --
                  exit cal_loop;
                end if;
              end if;
            end loop; -- for i
            exit cal_loop;
          end loop; -- cal_loop

          if not v_error then
            if v_codshift is not null then
              begin
                select timstrtw,timendw into v_timstrtw,v_timendw
                from   tshiftcd
                where  codshift = v_codshift;
                v_dtestrtw := v_dtework;
                if to_number(v_timstrtw) >= to_number(v_timendw) then
                  v_dteendw := v_dtework + 1;
                else
                  v_dteendw := v_dtework;
                end if;
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TSHIFTCD';
                v_err_filed := v_filed(7);
              end;
              /*24/09/2021
              if v_typwork  not in ('W','H','T','L','S') then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(8);
              end if;*/
            end if;
            --<<24/09/2021
            if v_typwork is not null then
              if v_typwork  not in ('W','H','T','L','S') then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(8);
              end if;
            end if;
            if v_codchng is not null then
              begin
                select codcodec into v_codchng
                from   tcodtime
                where  codcodec = v_codchng;
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TCODTIME';
                v_err_filed := v_filed(9);
              end;
            end if;
            -->>
          end if;
          --
          if not v_error then
            if to_date(to_char(v_date(1),'dd/mm/yyyy')||v_time(1),'dd/mm/yyyyhh24mi') > to_date(to_char(v_date(2),'dd/mm/yyyy')||v_time(2),'dd/mm/yyyyhh24mi') then
              v_error    := true;
              v_err_code := 'HR2021';
            end if;
          end if;
          if not v_error then
            if v_date(1) is not null or v_time(1) is not null or
               v_date(2) is not null or v_time(2) is not null or
               v_codshift is not null or v_typwork is not null or
               v_codchng is not null --24/09/2021
               then
               v_found      := 'N';
               for r_tattence in c_tattence loop
                update tattence
                  set dtein    = nvl(v_date(1),r_tattence.dtein),
                      timin    = nvl(v_time(1),r_tattence.timin),
                      dteout   = nvl(v_date(2),r_tattence.dteout),
                      timout   = nvl(v_time(2),r_tattence.timout),
                      codshift = nvl(v_codshift,r_tattence.codshift),
                      dtestrtw = nvl(v_dtestrtw,r_tattence.dtestrtw),
                      timstrtw = nvl(v_timstrtw,r_tattence.timstrtw),
                      dteendw  = nvl(v_dteendw,r_tattence.dteendw),
                      timendw  = nvl(v_timendw,r_tattence.timendw),
                      typwork  = nvl(v_typwork,r_tattence.typwork),
                      codchng  = nvl(v_codchng,r_tattence.codchng), --24/09/2021
                      coduser  = global_v_coduser
                  where rowid = r_tattence.rowid;

                -- check different data --
                -----------------------------------------
                if r_tattence.dtein = v_date(1) then
                  v_dtein_o := null;
                  v_dtein   := null;
                else
                  v_dtein_o := r_tattence.dtein;
                  v_dtein   := v_date(1);
                end if;
                ------------------------------------------
                if r_tattence.timin = v_time(1) then
                  v_timin_o := null;
                  v_timin   := null;
                else
                  v_timin_o := r_tattence.timin;
                  v_timin   := v_time(1);
                end if;
                ------------------------------------------
                if r_tattence.dteout = v_date(2) then
                  v_dteout_o := null;
                  v_dteout   := null;
                else
                  v_dteout_o := r_tattence.dteout;
                  v_dteout   := v_date(2);
                end if;
                ------------------------------------------
                if r_tattence.timout = v_time(2) then
                  v_timout_o := null;
                  v_timout   := null;
                else
                  v_timout_o := r_tattence.timout;
                  v_timout   := v_time(2);
                end if;
                ------------------------------------------
                if r_tattence.typwork = nvl(v_typwork,r_tattence.typwork) then
                  v_typwork_o := null;
                  v_typwork_n := null;
                else
                  v_typwork_o := r_tattence.typwork;
                  v_typwork_n := v_typwork;
                end if;
                ------------------------------------------
                if r_tattence.codshift = nvl(v_codshift,r_tattence.codshift) then
                  v_codshift_o := null;
                  v_codshift_n := null;
                else
                  v_codshift_o := r_tattence.codshift;
                  v_codshift_n := v_codshift;
                end if;
                ------------------------------------------
                if r_tattence.codchng = nvl(v_codchng,r_tattence.codchng) then --24/09/2021
                  v_codchng_o := null;
                  v_codchng_n := null;
                else
                  v_codchng_o := r_tattence.codchng;
                  v_codchng_n := v_codchng;
                end if;
                ------------------------------------------
                -- insert log when data changed --
                if nvl(v_dtein_o,trunc(sysdate)) <> nvl(v_dtein,trunc(sysdate))
                or nvl(v_dteout_o,trunc(sysdate)) <> nvl(v_dteout,trunc(sysdate))
                or nvl(v_timin_o,'-') <> nvl(v_timin,'-')
                or nvl(v_timout_o,'-') <> nvl(v_timout,'-')
                or nvl(v_typwork_o,'-') <> nvl(v_typwork_n,'-')
                or nvl(v_codshift_o,'-') <> nvl(v_codshift_n,'-')
                or nvl(v_codchng_o,'-') <> nvl(v_codchng_n,'-') --24/09/2021
                then --25/03/2021
                  insert into tlogtime
                              (codempid,dtework,dteupd,codshift,codcreate,coduser,codcomp,
                               dteinold,timinold,dteoutold,timoutold,typworkold,codshifold,codchngold,
                               dteinnew,timinnew,dteoutnew,timoutnew,typworknew,codshifnew,codchngnew)
                  values
                              (v_codempid,v_dtework,sysdate,nvl(v_codshift,r_tattence.codshift),global_v_coduser,global_v_coduser,r_tattence.codcomp,
                               v_dtein_o,v_timin_o,v_dteout_o,v_timout_o,v_typwork_o,v_codshift_o,v_codchng_o,
                               v_dtein,v_timin,v_dteout,v_timout,v_typwork_n,v_codshift_n,v_codchng_n);
                end if;
                ------------------------------------------
                --<<user36 SEA-HR2201 #731 09/02/2023  
                std_al.cal_tlateabs(r_tattence.codempid,r_tattence.dtework,
                                    nvl(v_typwork,r_tattence.typwork),nvl(v_codshift,r_tattence.codshift),
                                    nvl(v_date(1),r_tattence.dtein),nvl(v_time(1),r_tattence.timin),
                                    nvl(v_date(2),r_tattence.dteout),nvl(v_time(2),r_tattence.timout),
                                    global_v_coduser,'Y',v_qtylate,v_qtyearly,v_qtyabsent,v_numrec,'Y');
                ------------------------------------------
                -->>user36 SEA-HR2201 #731 09/02/2023
                v_rec_tran := v_rec_tran + 1;
                v_found    := 'Y';
              end loop; -- for c_tattence
              if v_found = 'N' then
                v_err_code := 'HR2010';
                v_err_table := 'tattence';
              end if;
            end if;
          end if;
          if v_found = 'N' then
             v_error := true;
          end if;
          --
          if v_err_code is not null  then
            v_rec_error := v_rec_error + 1;
            v_cnt       := v_cnt + 1;
            --
            if v_err_filed is null then
              v_err_filed := null;
            else
              v_err_filed := '['||v_err_filed||']';
            end if;
            --
            p_text(v_cnt)       := data_file;
            p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||v_err_filed;
            p_numseq(v_cnt)     := v_rownum;
          end if;
        end if;
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

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

end HRAL3TB;

/

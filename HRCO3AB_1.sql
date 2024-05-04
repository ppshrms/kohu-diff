--------------------------------------------------------
--  DDL for Package Body HRCO3AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO3AB" is
-- last update: 26/11/2019 12:00
  procedure initial_value(json_str in clob) is
    json_obj   json := json(json_str);
  begin
    global_v_coduser  := json_ext.get_string(json_obj,'p_coduser');
    global_v_codempid := json_ext.get_string(json_obj,'p_codempid');
    global_v_lang     := json_ext.get_string(json_obj,'p_lang');

    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));
    p_codapp_rep        := hcm_util.get_string(json_obj,'p_codapp_rep');
    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');

  end initial_value;

----------------------------------------------------------------------------------
  procedure get_index_tautoexe (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_tautoexe (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index_tautoexe;
----------------------------------------------------------------------------------
procedure gen_index_tautoexe(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    obj_result  json;
    v_rcnt      number := 0;
    v_status    varchar2(20 char);
    v_next_time_process varchar2(20 char);
    cursor c_tautoexe is
            select codapp, jobid, dtestr,
            case
                   when timestr is not null then SUBSTR(timestr, 0, 2)||':'||SUBSTR(timestr, 3, 2)
                   else timestr end as timestr ,
            --qtyday,qtyhour,
            case
                   when qtyday is not null then to_char(qtyday) ||' '|| get_label_name('HRCO3AB2',global_v_lang,'80')
                   else
                   (case when qtyhour is not null then floor(qtyhour/60) ||':'||lpad(mod(qtyhour,60), 2, '0')||' '|| get_label_name('HRCO3AB2',global_v_lang,'90') ELSE '' END)
            end as qty_excute
            from tautoexe
            order by numseq;
  begin
    obj_row     := json();
    obj_result  := json();
    for t1 in c_tautoexe loop
      -----------------------------------------------
      v_status  := null;
      v_next_time_process := null;

     if t1.jobid is not null then
        begin
        select decode(broken, 'N', 'Active', 'Error') ,
               to_char(next_date, 'dd/mm/yyyy hh24:mi')
        into v_status , v_next_time_process
        from user_jobs
        where job = t1.jobid
        and log_user = user;
      exception when others then
          v_status := 'Not found';
          v_next_time_process := null;
      end;
      end if ;
      -----------------------------------------------
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('codapp', t1.codapp);
      obj_data.put('codapp_desc', get_tappprof_name(t1.codapp , 2 , global_v_lang));
      obj_data.put('jobid', t1.jobid);
      obj_data.put('dtestr', to_char(t1.dtestr, 'dd/mm/yyyy'));
      obj_data.put('timestr', t1.timestr);
      obj_data.put('status', v_status);
      obj_data.put('qty_excute', t1.qty_excute);
      obj_data.put('next_time_process', v_next_time_process);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_index_tautoexe;
----------------------------------------------------------------------------------

  procedure get_tautoexe_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tautoexe_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tautoexe_detail;

----------------------------------------------------------------------------------

  procedure gen_tautoexe_detail (json_str_output out clob) is
    obj_data               json;
    v_codapp        tautoexe.codapp%type;
    v_jobid         tautoexe.jobid%type;
    v_dtestr        tautoexe.dtestr%type;
    v_timestr       tautoexe.timestr%type;
    v_qtyday        tautoexe.qtyday%type;
    v_qtyhour       varchar2(4 char);
    ----------------------------------
  begin
    begin

      select codapp, jobid, dtestr, timestr,  qtyday,
      lpad(trunc(mod(qtyhour,600)/60), 2, '0')||lpad(mod(qtyhour,60), 2, '0') as qtyhour
      into   v_codapp, v_jobid, v_dtestr, v_timestr,  v_qtyday, v_qtyhour
      from tautoexe
      where codapp = p_codapp;

    exception when no_data_found then
      null;
    end;

    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codapp', p_codapp);

    obj_data.put('jobid', v_jobid);
    obj_data.put('dtestr',  to_char(v_dtestr, 'dd/mm/yyyy'));
    obj_data.put('timestr', v_timestr);
    obj_data.put('qtyday', v_qtyday);
    obj_data.put('qtyhour', v_qtyhour);
    ------------------------------------
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tautoexe_detail;

----------------------------------------------------------------------------------
  procedure get_dba_jobs_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_dba_jobs_detail (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_dba_jobs_detail;

----------------------------------------------------------------------------------
  procedure gen_dba_jobs_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    obj_result  json;
    v_rcnt      number := 0;
    cursor job_oth is
        /* select
                jobid as job,
                'N' as status,
                dtestr as last_exec,
                dtestr as next_exec
            from tautoexe; */


        --ต้องใช้ตัวนี้ แต่ขึ้น error "table does not exist"
        select a.job job_id,
            replace(a.WHAT,';','') procname,
            decode(
                    a.BROKEN, 'N','Active',
                    'Error'
            ) as status,
            to_char(a.LAST_DATE,'dd/mm/yyyy') || ' ' || substr(a.LAST_SEC,1,5) last_exec,
            to_char(a.NEXT_DATE,'dd/mm/yyyy') || ' ' || substr(a.NEXT_SEC,1,5) next_exec
        from user_jobs a
        where a.LOG_USER = user
        and a.JOB not in (select jobid from tautoexe where jobid is not null)
        order by a.WHAT;
  begin

    obj_row     := json();
    obj_result  := json();

    for oth in job_oth loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('job', oth.job_id);
      obj_data.put('procname', oth.procname);
      obj_data.put('status', oth.status);
      obj_data.put('last_exec',  oth.last_exec);
      obj_data.put('next_exec',  oth.next_exec);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_dba_jobs_detail;
----------------------------------------------------------------------------------
procedure save_job_tautoexe (json_str_input in clob, json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    obj_result  json;
    v_min number;
    v_interval varchar2(100 char);
    v_nextdate varchar2(100 char);
    v_procname_db   tautoexe.procname%type;
    v_jobid_db      tautoexe.jobid%type;
    v_date     date;
    v_codapp        tautoexe.codapp%type;
    v_dtestr        tautoexe.dtestr%type;
    v_jobid         tautoexe.jobid%type;
    v_qtyday        tautoexe.qtyday%type;
    --v_qtyhour       tautoexe.qtyhour%type;
    v_qtyhour       varchar2(100 char);
    v_timestr       tautoexe.timestr%type;
    ----------------------------------
    v_qtyhour_count number;
    v_qtyhour_sum_total number;
    v_qtyhour_one varchar2(2 char);
    v_qtyhour_two varchar2(2 char);
    interval INTERVAL DAY TO SECOND;
    ----------------------------------

begin
   initial_value(json_str_input);
   v_codapp    := hcm_util.get_string(json_params, 'codapp');
   v_dtestr    := to_date(trim(hcm_util.get_string(json_params, 'dtestr')),'dd/mm/yyyy');
   v_jobid     := hcm_util.get_string(json_params, 'jobid');
   v_qtyday    := hcm_util.get_string(json_params, 'qtyday');
   v_qtyhour   := hcm_util.get_string(json_params, 'qtyhour');
   v_timestr   := lpad(hcm_util.get_string(json_params, 'timestr'), 4, '0');

  /*param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', 'v_qtyhour/'||v_qtyhour ||'', global_v_lang);
    return; */

   select INSTR(to_char(v_qtyhour), ':') into  v_qtyhour_count from dual;

   if v_qtyhour_count > 0 then
         select SUBSTR(to_char(v_qtyhour), 1, INSTR(to_char(v_qtyhour), ':')-1) as qtyhour_one,
         SUBSTR(to_char(v_qtyhour), INSTR(to_char(v_qtyhour), ':')+1) as qtyhour_two
         into  v_qtyhour_one, v_qtyhour_two
         from dual;

         if v_qtyhour_one is null then
            v_qtyhour_one := 0;
         end if;

         v_qtyhour_sum_total := (to_number(v_qtyhour_one)*60) + to_number(rpad(v_qtyhour_two, 2, '0'));
   else
      v_qtyhour_sum_total := v_qtyhour*60;
   end if;
   ---------------------------
   begin
      select t.procname , t.jobid
      into   v_procname_db , v_jobid_db
      from tautoexe t
      where  t.codapp = v_codapp ;
   exception when no_data_found then
      null;
   end;
   ---------------------------
   if v_qtyday is not null then
      v_min := to_char( to_date(v_timestr,'hh24mi') , 'hh24') * 60 ;
      v_min := v_min + to_char( to_date(v_timestr,'hh24mi') , 'mi');
      v_interval := 'TRUNC(SYSDATE)+' || v_qtyday || '+(' || v_min || '/1440)';
      v_nextdate := to_char(v_dtestr, 'dd/mm/yyyy') || ' ' || to_char(to_date(v_timestr, 'hh24miss'), 'hh24mi') || ':00';
      v_date := to_date(v_nextdate, 'dd/mm/yyyy hh24:mi:ss') + v_qtyday ;
   else
-- Adisak redmine#8576 11/04/2023 19:22
      v_min       := v_qtyhour_sum_total;
      interval    := numtodsinterval(v_min / 60, 'HOUR');  
      v_interval  := 'TRUNC(SYSDATE+' || v_min || '/1440, ''MI'')';
      v_nextdate  := to_char(v_dtestr, 'dd/mm/yyyy') || ' ' || to_char(to_date(v_timestr, 'hh24miss'), 'hh24mi') || ':00';

      v_date := to_date(v_nextdate,'dd/mm/yyyy hh24:mi:ss');                              

      if trunc(v_date) < trunc(sysdate) then
        v_date := to_date(to_char(trunc(sysdate), 'dd/mm/yyyy') || ' ' || to_char(to_date(v_timestr, 'hh24miss'), 'hh24mi') || ':00', 'dd/mm/yyyy hh24:mi:ss');
      end if;

      while v_date <= sysdate loop
        -- Do something with current_time, e.g. insert into a table
        v_date := v_date + interval;
      end loop;
-- Adisak redmine#8576 11/04/2023 19:22
   end if;
   -----------------------------------------------

/*param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',
    'v_min/'|| v_min ||
    'v_interval/'|| v_interval ||
    'v_nextdate/'|| v_nextdate ||
    'v_date/'|| v_date
    , global_v_lang);
    return; */

   if v_jobid_db is null then  --ถ้ายังไม่เคย Create job มาก่อน
      sys.dbms_job.submit(
          job => v_jobid_db , --ตัวแปรที่ใช้เก็บชื่อ jobid
          what => v_procname_db || ';',
          next_date => v_date,
          interval => v_interval,
          no_parse => FALSE
      );
   else
      sys.dbms_job.change(
         job => v_jobid_db ,
         what => v_procname_db|| ';',
         next_date => v_date,
         interval => v_interval
      );
   end if;
   -----------------------------------------------
   update tautoexe
   set    jobid = v_jobid_db ,
          dtestr = v_dtestr , -- วันที่เริ่มประมวลผล,
          timestr = v_timestr,  --เวลาที่เริ่มปะมวลผลที่ระบุ
          procname = v_procname_db , --tautoexe.procname,
          qtyday = v_qtyday , --จำนวนวันที่ประมวลผลทุกๆกี่วัน,
          qtyhour = v_qtyhour_sum_total , --จำนวนชั่วโมง:นาที ที่ระบุ แปลงเป็นนาที,
          coduser = global_v_coduser, --:global.v_coduser
          codcreate = global_v_coduser
    where codapp = v_codapp ; --tautoexe.codapp; */
   -----------------------------------------------
   commit;
   -----------------------------------------------
   if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      commit;
   else
      rollback;
   end if;
   /*obj_data          := json();
   obj_data.put('codapp', v_codapp);
   obj_data.put('dtestr', v_dtestr);
   obj_data.put('jobid', v_jobid);
   obj_data.put('qtyday', v_qtyday);
   obj_data.put('qtyhour', v_qtyhour);
   obj_data.put('timestr', v_timestr);
   dbms_lob.createtemporary(json_str_output, true);
   obj_data.to_clob(json_str_output);*/
exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end save_job_tautoexe ;
----------------------------------------------------------------------------------
procedure remove_job_tautoexe (json_str_input in clob, json_str_output out clob) is
    v_codapp        tautoexe.codapp%type;
    v_jobid         tautoexe.jobid%type;
    ----------------------------------
begin
   initial_value(json_str_input);
   v_codapp    := hcm_util.get_string(json_params, 'codapp');
   v_jobid     := hcm_util.get_string(json_params, 'jobid');
   --------------------------------------------
   update tautoexe t
   set    t.jobid = null ,
          t.dtestr = null ,
          t.timestr = null ,
          t.qtyday = null ,
          t.qtyhour = null ,
          t.coduser = global_v_coduser
   where  t.codapp  =  v_codapp ;
   --------------------------------------------
   dbms_job.remove(v_jobid) ;
   commit;
   param_msg_error := get_error_msg_php('HR2401', global_v_lang);
   json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end remove_job_tautoexe ;
------------------------------------------------------
procedure remove_job_other (json_str_input in clob, json_str_output out clob) is
    json_row        json;
    v_jobid         number;
    ----------------------------------
begin
   initial_value(json_str_input);
 /*param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', 'json_str_input/'||json_str_input, global_v_lang);
    return; */
   for i in 0..json_params.count - 1 loop
   ----------------------------------
   json_row    := hcm_util.get_json(json_params, to_char(i));
   v_jobid     := hcm_util.get_string(json_row, 'job');
   ----------------------------------
   dbms_job.remove(v_jobid) ;
   ----------------------------------
   end loop;
   if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;

   json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
exception when others then
rollback;
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end remove_job_other ;
---------------------------------------------------------

procedure test is
v_job number;
begin
          sys.dbms_job.submit(
          job => v_job, --ตัวแปรที่ใช้เก็บชื่อ jobid
          what =>'AUTO_SENDMAIL.HRES72U;', --tautoexe.procname || ';',
          next_date => SYSDATE,
          --interval => 'TRUNC(SYSDATE)+' || '1' || '+(' || '1' || '/1440)', --'SYSDATE + 1/24',
          interval => 'TRUNC(SYSDATE+1.0391666666666666666666666666666666666667/1440, ''MI'')',
          no_parse => FALSE

          /*sys.dbms_job.submit(
          job => v_job, --ตัวแปรที่ใช้เก็บชื่อ jobid
          what =>'AUTO_SENDMAIL.HRES72U;', --tautoexe.procname || ';',
          next_date => to_date('2019/10/02 09:30:00', 'dd/mm/yyyy hh24:mi:ss'),
          interval => 'TRUNC(SYSDATE)+1+(0/1440)', --'SYSDATE + 1/24',
          no_parse => FALSE*/
      );
end test ;
---------------------------------------------------------------
procedure test_drop is
v_job number;
begin
      dbms_job.remove(15);
end test_drop ;

end HRCO3AB;

/

--------------------------------------------------------
--  DDL for Package Body HRAP58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP58X" is
-- last update: 11/08/2020 14:00

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
    b_index_dteyear    := hcm_util.get_string_t(json_obj,'p_year');
    b_index_numtime    := hcm_util.get_string_t(json_obj,'p_seqno');
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codbon     := hcm_util.get_string_t(json_obj,'p_codbonus');

    --block drilldown
    b_index_codcompd   := hcm_util.get_string_t(json_obj,'p_codcompd');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_head(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_head(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_head(json_str_output out clob) is
    obj_data        json_object_t;
    v_seq           number := 0;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_codcompy      varchar2(400 char);
    v_descodcompy   varchar2(400 char);
    v_amtbudg       number := 0;
    v_amtbon        number := 0;

  begin
    --HEAD REPORT
    obj_data := json_object_t();
    v_codcompy := hcm_util.get_codcomp_level(b_index_codcomp,1);
    v_descodcompy := v_codcompy ||' - '||get_tcompny_name(v_codcompy,global_v_lang);
    begin
        select sum(amtbudg) into v_amtbudg       -- จำนวนเงินงบประมาณ
          from tbonparh
         where codcomp like v_codcompy||'%'
           and dteyreap = to_number(b_index_dteyear)
           and numtime = to_number(b_index_numtime)
           and codbon = b_index_codbon
           and rownum <= 1;
        exception when others then
          v_amtbudg := null;
    end;
/*
    begin
      select sum(nvl(stddec(amtbon,codempid,v_chken),0))   -- จำนวนเงินโบนัสที่คำนวณได้
        into v_amtbon
        from tbonus
       where codcomp like v_codcompy||'%'
         and dteyreap = to_number(b_index_dteyear)
         and numtime = to_number(b_index_numtime)
         and codbon = b_index_codbon;
        exception when others then
          v_amtbon := null;
    end;
*/
--    obj_data := json_object_t();
    v_rcnt := v_rcnt + 1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codcompy', v_descodcompy);
    obj_data.put('amtbudg', v_amtbudg);
--    obj_data.put(to_char(v_rcnt-1),obj_data);

    if v_rcnt > 0 then
      json_str_output := obj_data.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONPARH');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_qtyemp1       number;
    v_qtyemp2       number;
    v_qtyemp3       number;

    cursor c1 is
--      select codcomp, count(codempid)qtyemp2,             -- Adisak 26/04/2023 12:26 | fix case count codempid ต้องมีโบนัสสุทธิมากกว่า 0 
      select codcomp, sum(case when nvl(stddec(amtnbon,codempid,v_chken),0) > 0 then 1 else 0 end) qtyemp2,
             sum(nvl(stddec(amtsal,codempid,v_chken),0)) amtsal, -- เงินเดือนปัจจุบัน (บาท)
             sum(nvl(stddec(amtbon,codempid,v_chken),0)) amtbon  -- จำนวนเงินโบนัสที่คำนวณได้
        from tbonus
       where codcomp like b_index_codcomp||'%'
         and dteyreap = to_number(b_index_dteyear)
         and numtime = to_number(b_index_numtime)
         and codbon = nvl(b_index_codbon,codbon)
         and count_emp('',codempid) > 0
      group by codcomp
      order by codcomp;

  begin

    obj_row := json_object_t();
    for i in c1 loop
          v_flgdata := 'Y';
          v_qtyemp2 := nvl(i.qtyemp2, 0);

          v_qtyemp1 := count_emp(i.codcomp,null);   -- หาคน
          v_qtyemp3 := v_qtyemp1 - v_qtyemp2;
          if v_qtyemp3 < 0 then
            v_qtyemp3 := null;
          end if;
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp',i.codcomp); --หน่วยงาน
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang)); --หน่วยงาน

          obj_data.put('qtyemp',v_qtyemp1);
          obj_data.put('qtybonus',v_qtyemp2);
          obj_data.put('qtynon',v_qtyemp3);
          obj_data.put('salary',i.amtsal);     -- เงินเดือนปัจจุบัน (บาท)
          obj_data.put('paybonus',i.amtbon);     -- จำนวนเงินโบนัสที่คำนวณได้
          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_qtyta         number;
    v_qtypuns       number;
    v_dteend        date;
    v_year          number;
    v_month         number;
    v_day           number;

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos, a.jobgrade, a.amtsal, a.qtybon,
             a.amtadjbo, a.pctdedbo, a.amtnbon, a.dteempmt, a.grade, a.remarkadj
        from tbonus a
       where a.codcomp = b_index_codcompd
         and dteyreap = to_number(b_index_dteyear)
         and numtime = to_number(b_index_numtime)
         and codbon = nvl(b_index_codbon,codbon)
         and nvl(stddec(amtnbon,codempid,v_chken),0) > 0 -- Adisak 26/04/2023 12:26 | เปลี่ยนจาก amtbon => amtnbon ตาม SWD ต้องเช็คจากโบนัสสุทธิมากกว่า 0
      order by a.codempid;

  begin

    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';


      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
          begin
            select dteend into v_dteend
              from tbonparh
             where codbon   = b_index_codbon
               and dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and i.codcomp like codcomp||'%'
               and codcomp = (select max(codcomp)
                                from tbonparh
                               where codbon   = b_index_codbon
                                 and dteyreap = b_index_dteyear
                                 and numtime  = b_index_numtime
                                 and i.codcomp	like codcomp||'%')
                                 and rownum <= 1;
			exception when no_data_found then
              v_dteend := sysdate;
          end;
          get_service_year(i.dteempmt,v_dteend,'Y',v_year,v_month,v_day);

          v_rcnt := v_rcnt+1;

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('seq',v_rcnt);
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('jobgrade',i.jobgrade);
          obj_data.put('qtywork',to_char(v_year)||':'||to_char(v_month));  -- อายุงาน
          obj_data.put('grade',i.grade);
          obj_data.put('detail',get_tlistval_name('INSTGRD',i.grade,global_v_lang));  --รายละเอียดเกรด
          obj_data.put('salary',stddec(i.amtsal,i.codempid,v_chken));  -- เงินเดือนปัจจุบัน
          obj_data.put('rate',i.qtybon);  -- อัตราการจ่าย
          obj_data.put('increate',stddec(i.amtadjbo,i.codempid,v_chken));  -- จำนวนเงินที่ปรับ
          obj_data.put('percent',i.pctdedbo);  -- % การหัก
          obj_data.put('total',stddec(i.amtnbon,i.codempid,v_chken));  -- โบนัสสุทธิ
          obj_data.put('remark',i.remarkadj);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_popup2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup2(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_qtytotnet     number;
    v_qtyta         number;
    v_qtypuns       number;

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos, a.jobgrade, a.dteempmt, a.grade, a.remarkadj
        from tbonus a
       where a.codcomp = b_index_codcompd
         and dteyreap = to_number(b_index_dteyear)
         and numtime = to_number(b_index_numtime)
         and codbon = nvl(b_index_codbon,codbon)
         and nvl(stddec(amtnbon,codempid,v_chken),0) <= 0 -- Adisak 26/04/2023 12:26 | เปลี่ยนจาก amtbon => amtnbon ตาม SWD ต้องเช็คจากโบนัสสุทธิน้อยกว่าหรือเท่ากับ 0
      order by a.codempid;

  begin

    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';


      flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
          begin
            select qtyta, qtypuns, qtytotnet
              into v_qtyta, v_qtypuns, v_qtytotnet
              from tappemp
             where codempid = i.codempid
               and dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and rownum  <= 1;
			exception when no_data_found then
               v_qtyta     := 0;
               v_qtypuns   := 0;
               v_qtytotnet := 0;
          end;

          v_rcnt := v_rcnt+1;

          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('seq',v_rcnt);
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('jobgrade',i.jobgrade);
          obj_data.put('dtein',to_char(i.dteempmt,'dd/mm/yyyy'));
          obj_data.put('score',v_qtytotnet);  --คะแนนที่ได้
          obj_data.put('grade',i.grade);
          obj_data.put('detail',get_tlistval_name('INSTGRD',i.grade,global_v_lang));  --รายละเอียดเกรด
          obj_data.put('discout',v_qtyta);  --คะแนนที่หัก
          obj_data.put('discard',v_qtypuns);  --คะแนนที่หักผิดวินัย
          obj_data.put('remark',i.remarkadj);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TBONUS');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function count_emp(p_codcomp varchar2,p_codempid varchar2) return number is
	v_codcomp           temploy1.codcomp%type;
	v_codempid		    temploy1.codempid%type;
	v_dtestr			date;
	v_dteend			date;
	v_typbon			tbonparh.typbon%type;
	v_boncond			varchar2(6000);

	v_flgsecu			boolean;
	v_flgfound          boolean;
	v_stmt				varchar2(6000);
	v_amtincom		    temploy3.amtincom1%type;

	v_formula           tbonparh.formula%type;
	v_zupdsal			varchar2(1);
	v_sumemp			number :=0;

	cursor c_temploy is
		select a.codempid,dteempdb,stamarry,codsex,dteempmt,
                 codcomp,codpos,numlvl,staemp,dteeffex,flgatten,
                 codbrlc,codempmt,typpayroll,typemp,codcalen,
                 codjob,codcompr,codposre,dteeflvl,dteefpos,
                 dteduepr,dteoccup,qtydatrq,numappl,flgreemp,
                 dtereemp,dteredue,codedlv,codmajsb,jobgrade,
                 dteefstep,codgrpgl,stadisb,numdisab,typdisp,
                 dtedisb,dtedisen,codcurr,numtaxid,numsaid,
                 stddec(b.amtincom1,a.codempid,v_chken) amtincom1,
                 stddec(b.amtincom2,a.codempid,v_chken) amtincom2,
                 stddec(b.amtincom3,a.codempid,v_chken) amtincom3,
                 stddec(b.amtincom4,a.codempid,v_chken) amtincom4,
                 stddec(b.amtincom5,a.codempid,v_chken) amtincom5,
                 stddec(b.amtincom6,a.codempid,v_chken) amtincom6,
                 stddec(b.amtincom7,a.codempid,v_chken) amtincom7,
                 stddec(b.amtincom8,a.codempid,v_chken) amtincom8,
                 stddec(b.amtincom9,a.codempid,v_chken) amtincom9,
                 stddec(b.amtincom10,a.codempid,v_chken) amtincom10	,
                 stddec(b.amtothr,a.codempid,v_chken)   amtothr	,
                 stddec(b.amtday,a.codempid,v_chken)    amtday
		 from  temploy1 a,temploy3 b
		where  a.codcomp  like p_codcomp||'%'
		  and  a.codempid = b.codempid
      and  a.codempid = nvl(p_codempid,a.codempid)
		  and  a.staemp in ('1','3');

begin
	for r_temploy in c_temploy loop
		<<cal_loop>>
		loop
			v_codempid  := r_temploy.codempid;
            v_flgsecu   := secur_main.secur3(r_temploy.codcomp,r_temploy.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);

			if not v_flgsecu then
				exit cal_loop;
			end if;

			begin
				select codcomp,dtestr,typbon,boncond,formula
				  into v_codcomp,v_dtestr,v_typbon,v_boncond,v_formula
				  from tbonparh
				 where codbon   = nvl(b_index_codbon,codbon)
				   and dteyreap = b_index_dteyear
				   and numtime  = b_index_numtime
				   and r_temploy.codcomp like codcomp||'%'
				   and codcomp = (select max(codcomp)
                            from tbonparh
                           where codbon   = nvl(b_index_codbon,codbon)
                             and dteyreap = b_index_dteyear
                             and numtime  = b_index_numtime
                             and r_temploy.codcomp	like codcomp||'%')
                             and rownum <= 1
           and rownum = 1;
			exception when no_data_found then
				exit cal_loop;
			end;

			if r_temploy.dteempmt >= v_dteend then
				exit cal_loop;
			end if;

			v_stmt := null;
			if v_boncond is not null then
				v_boncond := replace(v_boncond,'V_HRAP51.TEMPLOY1.',null);
				v_boncond := replace(v_boncond,'V_HRAP51.TEMPLOY3.',null);
--#3629				v_boncond := replace(v_boncond,'V_HRAP51.AGE_POS.',null);
				v_boncond := replace(v_boncond,'V_HRAP51.CODEMPID',''''||r_temploy.codempid||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEEMPDB','to_date('''||to_char(r_temploy.dteempdb,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.STAMARRY',''''||r_temploy.stamarry||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODSEX',''''||r_temploy.codsex||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEEMPMT','to_date('''||to_char(r_temploy.dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.CODCOMP',''''||r_temploy.codcomp||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODPOS',''''||r_temploy.codpos||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.NUMLVL',r_temploy.numlvl);
				v_boncond := replace(v_boncond,'V_HRAP51.STAEMP',''''||r_temploy.staemp||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEEFFEX','to_date('''||to_char(r_temploy.dteeffex,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.FLGATTEN',''''||r_temploy.flgatten||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODBRLC',''''||r_temploy.codbrlc||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODEMPMT',''''||r_temploy.codempmt||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.TYPPAYROLL',''''||r_temploy.typpayroll||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.TYPEMP',''''||r_temploy.typemp||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODCALEN',''''||r_temploy.codcalen||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODJOB',''''||r_temploy.codjob||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODCOMPR',''''||r_temploy.codcompr||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODPOSRE',''''||r_temploy.codposre||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEEFPOS','to_date('''||to_char(r_temploy.dteefpos,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEDUEPR','to_date('''||to_char(r_temploy.dteduepr,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEOCCUP','to_date('''||to_char(r_temploy.dteoccup,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.QTYDATRQ',r_temploy.qtydatrq);
				v_boncond := replace(v_boncond,'V_HRAP51.NUMAPPL',''''||r_temploy.numappl||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.FLGREEMP',''''||r_temploy.flgreemp||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEREEMP','to_date('''||to_char(r_temploy.dtereemp,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEREDUE','to_date('''||to_char(r_temploy.dteredue,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.CODEDLV',''''||r_temploy.codedlv||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.CODMAJSB',''''||r_temploy.codmajsb||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.JOBGRADE',''''||r_temploy.jobgrade||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEEFSTEP','to_date('''||to_char(r_temploy.dteefstep,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.CODGRPGL',''''||r_temploy.codgrpgl||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.STADISB',''''||r_temploy.stadisb||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.NUMDISAB',''''||r_temploy.numdisab||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.TYPDISP',''''||r_temploy.typdisp||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEDISB','to_date('''||to_char(r_temploy.dtedisb,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.DTEDISEN','to_date('''||to_char(r_temploy.dtedisen,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
				v_boncond := replace(v_boncond,'V_HRAP51.CODCURR',''''||r_temploy.codcurr||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM1',r_temploy.amtincom1);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM2',r_temploy.amtincom2);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM3',r_temploy.amtincom3);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM4',r_temploy.amtincom4);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM5',r_temploy.amtincom5);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM6',r_temploy.amtincom6);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM7',r_temploy.amtincom7);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM8',r_temploy.amtincom8);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM9',r_temploy.amtincom9);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTINCOM10',r_temploy.amtincom10);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTOTHR',r_temploy.amtothr);
				v_boncond := replace(v_boncond,'V_HRAP51.AMTDAY',r_temploy.amtday);
				v_boncond := replace(v_boncond,'V_HRAP51.NUMTAXID',''''||r_temploy.numtaxid||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.NUMSAID',''''||r_temploy.numsaid||'''');
				v_boncond := replace(v_boncond,'V_HRAP51.AGE_POS',( months_between(sysdate,r_temploy.dteempmt)));

                --<<User37 #4490 AP - PeoplePlus 20/02/2021
                v_boncond := replace(v_boncond,'V_TEMPLOY.STAEMP',''''||r_temploy.staemp||'''');
                v_boncond := replace(v_boncond,'V_TEMPLOY.DTEEMPMT','to_date('''||to_char(r_temploy.dteempdb,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
                v_boncond := replace(v_boncond,'V_TEMPLOY.CODCOMP',''''||r_temploy.codcomp||'''');
                v_boncond := replace(v_boncond,'V_TEMPLOY.TYPEMP',''''||r_temploy.typemp||'''');
                v_boncond := replace(v_boncond,'V_TEMPLOY.CODPOS',''''||r_temploy.codpos||'''');
                v_boncond := replace(v_boncond,'V_TEMPLOY.JOBGRADE',''''||r_temploy.jobgrade||'''');
                -->>User37 #4490 AP - PeoplePlus 20/02/2021

				v_stmt := 'select count(*) from dual where '||v_boncond;

				v_flgfound := execute_stmt(v_stmt);
				if not v_flgfound then
                    exit cal_loop;
				else
					v_sumemp := v_sumemp + 1;
				end if;
			else
                v_sumemp := v_sumemp + 1;
            end if;

          exit cal_loop;
		end loop; -- end <<cal_loop>>
	end loop; -- end c_temploy
  return(v_sumemp);
end;
  --

end;

/

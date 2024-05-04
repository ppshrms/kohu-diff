--------------------------------------------------------
--  DDL for Package Body HRAL3EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3EX" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtestrt     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestrt')),'dd/mm/yyyy');
    p_dteend      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
    p_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_dtework     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index is
    v_secur     boolean := false;
    v_code      varchar2(100 char);
    v_codcomp   varchar2(1000 char);
  begin
  	if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestrt');
      return;
    elsif p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
      return;
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'dtestrt > dteend');
      return;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
--    begin
--      select codcomp into v_codcomp
--      from   tcenter
--      where  codcomp = p_codcomp;
--      v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
--      if not v_secur then
--        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
--        return;
--      end if;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codcomp');
--      return;
--    end;
    if p_codcalen is not null then
      begin
        select codcodec into v_code
          from tcodwork
         where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodwork');
        return;
      end;
    end if;
  end check_index;
  --
  --get index graph--
  procedure gen_graph(obj_row in json_object_t) as
    obj_data    json_object_t;

    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAL3EX';
    v_numseq    ttemprpt.numseq%type := 0;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item31    ttemprpt.item31%type;
    v_dtework   date;
    v_additional_year   number;

    type a_string is table of varchar2(1000 char) index by binary_integer;
      v_arr_item1  	  a_string;
  begin
    v_arr_item1(0) := get_label_name('HRAL3EXC3', global_v_lang, '30'); --'??????';
    v_arr_item1(1) := get_label_name('HRAL3EXC3', global_v_lang, '40'); --'????????';
    v_item31       := get_label_name('HRAL3EXC3', global_v_lang, '10'); --'header';
    begin
      delete
        from ttemprpt
       where codempid = v_codempid
         and codapp = v_codapp;
    exception when others then
      rollback;
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
      return;
    end;

    v_additional_year  := hcm_appsettings.get_additional_year;

    for i in 0..1 loop -- loop item1
      for v_row in 1..obj_row.get_size loop
        obj_data := hcm_util.get_json_t(obj_row, to_char(v_row - 1));
        v_numseq := v_numseq + 1;
        v_dtework := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'dd/mm/yyyy');
        if i = 0 then -- dtework filter
          v_item1 := v_arr_item1(i);
--          v_item2 := to_char(v_dtework, 'dd')||'/'||to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item3 := '';
          v_item4 := hcm_util.get_string_t(obj_data, 'codcomp');
          v_item5 := hcm_util.get_string_t(obj_data, 'desc_codcomp');
          v_item6 := '';
          v_item7 := to_char(v_dtework, 'dd')||'/'||to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item8 := to_char(v_dtework, 'dd')||'/'||to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item9 := get_label_name('HRAL3EXC3', global_v_lang, '20');
          v_item10:= replace(hcm_util.get_string_t(obj_data, 'ratio'), '%', '');
        elsif i = 1 then -- codcomp filter
          v_item1 := v_arr_item1(i);
--          v_item2 := hcm_util.get_string_t(obj_data, 'desc_codcomp');
          v_item3 := to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item4 := to_char(v_dtework, 'dd');
          v_item5 := to_char(v_dtework, 'dd');
          v_item6 := '';
          v_item7 := hcm_util.get_string_t(obj_data, 'desc_codcomp') || ' - ' || to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item8 := hcm_util.get_string_t(obj_data, 'desc_codcomp') || ' - ' || to_char(v_dtework, 'mm')||'/'||to_char(to_number(to_char(v_dtework, 'yyyy')) + v_additional_year);
          v_item9 := get_label_name('HRAL3EXC3', global_v_lang, '20');
          v_item10:= replace(hcm_util.get_string_t(obj_data, 'ratio'), '%', '');
        end if;
        begin
          insert into ttemprpt
            (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31)
          values
            (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31);
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang);
          return;
        end;
      end loop;
    end loop;
    commit;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_exist     varchar2(10 char);
    v_flg_data  varchar2(4000 char) := 'N';
    v_row		    number := 0;

    cursor c1 is
      select a.dtework,a.codcomp,count(a.codempid) v_cnt,sum(decode(a.timin||a.timout,null,0,1)) v_act
        from tattence a,temploy1 b
       where a.codempid = b.codempid
         and a.codcomp like p_codcomp||'%'
         and a.codcalen = nvl(p_codcalen,b.codcalen)
         and a.dtework between p_dtestrt and p_dteend
         and ((v_exist = '1')
         or   (v_exist = '2' and b.numlvl between global_v_zminlvl and global_v_zwrklvl
                             and exists (select c.coduser
                                           from tusrcom c
                                          where c.coduser = global_v_coduser
                                            and b.codcomp like c.codcomp||'%')))
       group by a.dtework,a.codcomp
       order by a.dtework,a.codcomp;

  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;

    obj_row := json_object_t();
    v_exist := '1';
    for r1 in c1 loop
      v_flg_data := 'Y';
      exit;
    end loop;
    if v_flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tattence');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;
    --
    v_flg_data := 'N';
    v_exist    := '2';
    for i in c1 loop
      v_flg_data := 'Y';
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dtework',to_char(i.dtework,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp', hcm_util.get_codcompy(i.codcomp) || '-' || get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('desc_codcomp2', get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('v_cnt',i.v_cnt);
      obj_data.put('v_act',i.v_act);
      obj_data.put('ratio',to_char(round((100 * to_number(i.v_act))/to_number(i.v_cnt),2))||'%');
      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    --
    if v_flg_data = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    gen_graph(obj_row);
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
			json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_detail(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    json_obj    json_object_t;
    data_row    clob;
    v_row		    number := 0;
    v_qtyhwork	number := 0;
    v_late      number;
    v_early     number;
    v_leave     number;
    v_timin     varchar2(10 char);
    v_timout    varchar2(10 char);
    v_response  varchar2(1000);

    cursor c1 is
      select a.codempid, a.timin, a.timout, a.qtyhwork, a.codcomp, a.codcalen, a.dtework
        from tattence a, temploy1 b
       where a.codempid = b.codempid
         and a.dtework  = p_dtework
         and a.codcomp  = p_codcomp
         and a.codcalen = nvl(p_codcalen,a.codcalen)
         and (a.timin is not null or a.timout is not null)
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and exists (select d.coduser
                     from tusrcom d
                    where d.coduser = global_v_coduser
                      and a.codcomp like d.codcomp||'%')
       order by codempid;
  begin


    json_obj := json_object_t();
    obj_row  := json_object_t();
    for i in c1 loop
      v_late  := 0;
      v_early := 0;
      begin
        select qtylate,qtyearly
          into v_late,v_early
          from tlateabs
         where dtework  = p_dtework
           and codempid = i.codempid;
      exception when no_data_found then null;
      end;
      v_leave  := 0;
      begin
        select sum(qtymin)
          into v_leave
          from tleavetr
         where dtework  = p_dtework
           and codempid = i.codempid;
      exception when no_data_found then null;
      end;

      if i.timin is null then
        v_timin := null;
      else
        v_timin := substr(i.timin,1,2)||':'||substr(i.timin,3,2);
      end if;
      if i.timout is null then
        v_timout := null;
      else
        v_timout := substr(i.timout,1,2)||':'||substr(i.timout,3,2);
      end if;
      v_qtyhwork := v_qtyhwork + (nvl(i.qtyhwork,0) - (nvl(v_late,0) + nvl(v_early,0) + nvl(v_leave,0)));

      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('image',get_emp_img(i.codempid));
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('timstrt',v_timin);
      obj_data.put('timend',v_timout);
      obj_data.put('numseq',v_row);
      obj_data.put('codcomp',hcm_util.get_codcomp_level(p_codcomp,null));
      obj_data.put('codcalen',p_codcalen);
      obj_data.put('dtework',to_char(p_dtework,'dd/mm/yyyy'));
      obj_row.put(to_char(v_row-1),obj_data);

      if isInsertReport then
        insert_ttemprpt_table(obj_data);
      end if;
    end loop;
		data_row := obj_row.to_clob;

    v_response := get_response_message(null,param_msg_error,global_v_lang);
    json_obj.put('coderror',hcm_util.get_string(json(v_response),'coderror'));
    json_obj.put('response',hcm_util.get_string(json(v_response),'response'));
    json_obj.put('qtyhwork',hcm_util.convert_minute_to_hour(v_qtyhwork));
    json_obj.put('codcomp',hcm_util.get_codcomp_level(p_codcomp,null) || '-' || get_tcenter_name(p_codcomp,global_v_lang));
    json_obj.put('ccodcomp',hcm_util.get_codcomp_level(p_codcomp,null));
    json_obj.put('codcalen',p_codcalen);
    json_obj.put('dtework',to_char(p_dtework,'dd/mm/yyyy'));
    json_obj.put('table',data_row);

    if isInsertReport then
      insert_ttemprpt_detail(json_obj);
		end if;
		json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;
    v_tmp             clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows      := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_dtework         := to_date(hcm_util.get_string_t(p_index_rows, 'dtework'), 'dd/mm/yyyy');
        p_codcomp         := hcm_util.get_string_t(p_index_rows, 'codcomp');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
        gen_detail(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp ;
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure insert_ttemprpt_detail(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dtework           date;
    v_dtework_          varchar2(100 char) := '';

    v_ccodcomp          varchar2(1000 char) := '';
    v_codcalen    			varchar2(1000 char) := '';
    v_qtyhwork       		varchar2(1000 char) := '';
  begin
    v_ccodcomp       		:= nvl(hcm_util.get_string_t(obj_data, 'ccodcomp'), '');
    v_codcalen          := nvl(hcm_util.get_string_t(obj_data, 'codcalen'), ' ');
    v_qtyhwork       		:= nvl(hcm_util.get_string_t(obj_data, 'qtyhwork'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_year      := hcm_appsettings.get_additional_year;
    v_dtework   := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework_  := to_char(v_dtework, 'DD/MM/') || (to_number(to_char(v_dtework, 'YYYY')) + v_year);
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4, item5,item6
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'detail',
             v_dtework_,
             v_ccodcomp,
             v_codcalen,
             v_qtyhwork,
             get_tcenter_name(v_ccodcomp,global_v_lang)
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_detail;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_year              number := 0;
    v_dtework           date;
    v_dtework_          varchar2(100 char) := '';

    v_codcomp          	varchar2(1000 char) := '';
    v_codcalen    			varchar2(1000 char) := '';
    v_numseq_       	  varchar2(1000 char) := '';
    v_codempid         	varchar2(1000 char) := '';
    v_desc_codempid    	varchar2(1000 char) := '';
    v_timstrt    	  		varchar2(1000 char) := '';
    v_timend    	  		varchar2(1000 char) := '';
  begin
    v_codcomp       		  := nvl(hcm_util.get_string_t(obj_data, 'codcomp'), '');
    v_codcalen            := nvl(hcm_util.get_string_t(obj_data, 'codcalen'), ' ');
    v_numseq_       		  := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
    v_codempid      			:= nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_desc_codempid      	:= nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_timstrt      				:= nvl(hcm_util.get_string_t(obj_data, 'timstrt'), '');
    v_timend      				:= nvl(hcm_util.get_string_t(obj_data, 'timend'), '');
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_year      := hcm_appsettings.get_additional_year;
    v_dtework   := to_date(hcm_util.get_string_t(obj_data, 'dtework'), 'DD/MM/YYYY');
    v_dtework_  := to_char(v_dtework, 'DD/MM/') || (to_number(to_char(v_dtework, 'YYYY')) + v_year);
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1, item2, item3, item4,item5, item6, item7, item8, item9
           )
      values
           ( global_v_codempid, p_codapp, v_numseq,
             'table',
              v_dtework_,
              v_codcomp,
              v_codcalen,
              v_numseq_,
              v_codempid,
              v_desc_codempid,
              v_timstrt,
              v_timend
      );
    exception when others then
      null;
    end;
  end insert_ttemprpt_table;

end HRAL3EX;

/

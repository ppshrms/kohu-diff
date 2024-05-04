--------------------------------------------------------
--  DDL for Package Body HCM_LAST_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LAST_ID" is
  procedure initial_value(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    --global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string(json_obj,'codcomp');
    p_codempmt          := hcm_util.get_string(json_obj,'codempmt');
    p_codbrlc           := hcm_util.get_string(json_obj,'codbrlc');
  end; -- end initial_value
  --

  procedure get_last_id_data(json_str_input in clob, json_str_output out clob) is
    obj_row         json;
    obj_data        json;
    v_numseq        number  := 0;

    json_obj        json;

    v_flgfound	    boolean;
    v_cond			varchar2(1000 char);
    v_groupid       varchar2(10 char);
   v_desc_groupid   varchar2(150 char);
    v_stmt		    varchar2(4000 char);
    v_id            varchar2(100 char);
    v_last_id       varchar2(100 char);
    v_exam_format   varchar2(2000 char);
    v_constnt       varchar2(100 char);
    v_concat        varchar2(5 char);
    v_addyear       number; -- user4 || 13/10/2022

    cursor c_tsempidh is
			select groupid,
             decode(global_v_lang, '101', namempide
                                 , '102', namempidt
                                 , '103', namempid3
                                 , '104', namempid4
                                 , '105', namempid5
                                 , namempidt) as desc_groupid,
             syncond
			from tsempidh
			order by groupid;

    cursor c_tsempidd is
      select  typgrpid,typeval
      from    tsempidd
      where   groupid   = v_groupid
      order by numseq;

    cursor c_trunempid is
     select groupid,
            dteyear,
            dtemonth,
            running,
            desc_groupid
    from (
             select  hd.groupid,
--                      decode(dteyear,9999,'',dteyear+543) as dteyear,--User37 #6760 03/09/2021 decode(dteyear,9999,'',dteyear) as dteyear
                      decode(dteyear,9999,'',dteyear) as dteyear,--User37 #6760 03/09/2021 decode(dteyear,9999,'',dteyear) as dteyear
                      decode(dtemonth,99,'',dtemonth) as dtemonth,
                      running,
                      decode(global_v_lang , '101', namempide
                                           , '102', namempidt
                                           , '103', namempid3
                                           , '104', namempid4
                                           , '105', namempid5
                                           , namempidt) as desc_groupid
              from    tsempidh hd, trunempid rn
              where   hd.groupid    = rn.groupid
         --     and     rn.groupid    = nvl(v_groupid,rn.groupid)
              and     rn.groupid    = v_groupid
        --    and     (to_number(rn.dteyear||lpad(dtemonth,2,'0')) >= to_number(to_char(add_months(sysdate,-2),'yyyymm'))
        --            or to_number(rn.dteyear||lpad(dtemonth,2,'0')) >= to_number(to_char(add_months(sysdate,-2),'yyyymm','NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')) - 2)
        --     and     rownum        <= 2
              order by groupid,nvl(dteyear,0) desc,nvl(dtemonth,0) desc
        )
     where  rownum        <= 2;

  begin
    initial_value(json_str_input);
    obj_row    := json();
    << tsempidh_loop >>

    for r_tsempidh in c_tsempidh loop
      v_flgfound := false;
      if r_tsempidh.syncond is not null then
        v_cond := r_tsempidh.syncond;
        v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||p_codcomp ||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODEMPMT',''''||p_codempmt||'''');
        v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||p_codbrlc||'''');
        v_stmt := 'select count(*) from dual where '||v_cond;
        v_flgfound := execute_stmt(v_stmt);
      end if;
      if v_flgfound then
        v_groupid       := r_tsempidh.groupid;
        v_desc_groupid  := r_tsempidh.desc_groupid;
        exit tsempidh_loop;
      end if;
    end loop;
    for r_runemp in c_trunempid loop
      obj_data    := json();
      v_numseq    := v_numseq + 1;
      v_groupid   := r_runemp.groupid;
      v_id        := null;
      v_constnt   := null;
      for r_empidd in c_tsempidd loop
        if r_runemp.dteyear is not null	then
          if r_empidd.typgrpid in ('CE','BE','AD') then
            if r_runemp.dteyear = 9999 then
              v_id := v_id||null;
            else
--              v_id := v_id||to_char(substr(r_runemp.dteyear,3,2));--Final Test Phase 1 V11 #2493
--              v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,30)||' (YY)';--Final Test Phase 1 V11 #2493
              --<< user4 || 13/10/2022
              --v_id := v_id||to_char(substr(r_runemp.dteyear,3,2));--User37 #6760 03/09/2021 v_id := v_id||to_char(r_runemp.dteyear);
              --v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,30)||' (YY)';
              if r_empidd.typgrpid = 'AD' then -- 2022
                v_addyear := 0;
                v_id := v_id||to_char(substr(r_runemp.dteyear,3,2));--User37 #6760 03/09/2021 v_id := v_id||to_char(r_runemp.dteyear);
                v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,120)||' (YY)';
              else -- 2565
                v_addyear := 543;
                v_id := v_id||to_char(substr(r_runemp.dteyear + 543,3,2));--User37 #6760 03/09/2021 v_id := v_id||to_char(r_runemp.dteyear);
                v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,30)||' (YY)';
              end if;
              -->> user4 || 13/10/2022
            end if;
          elsif r_empidd.typgrpid = 'MT' then
            if r_runemp.dtemonth = 99 then
              v_id := v_id||null;
            else
              v_id := v_id||lpad(r_runemp.dtemonth,2,'0');
              v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,40)||' (MM)';
            end if;
          elsif r_empidd.typgrpid = 'RN' then
            v_id := v_id||lpad(r_runemp.running,length(r_empidd.typeval),'0');
            v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,50)||' ('||lpad('0',length(r_empidd.typeval),'0')||')';
          elsif r_empidd.typgrpid = 'ST' then
            v_id := v_id||r_empidd.typeval;
            if v_constnt is null then
              v_constnt     := r_empidd.typeval;
            else
              v_constnt     := v_constnt||','||r_empidd.typeval;
            end if;
            v_exam_format := v_exam_format||v_concat||get_label_name('HRPM15EC2',global_v_lang,20)||' ('||r_empidd.typeval||')';
          end if;
        end if;
        v_concat    := ' - ';
      end loop;
      v_last_id   := v_id;

      obj_data.put('coderror','200');
      obj_data.put('groupid',r_runemp.groupid);
      obj_data.put('desc_groupid',r_runemp.desc_groupid);
      obj_data.put('format_exam',v_exam_format);
      obj_data.put('dteyear',r_runemp.dteyear + v_addyear); -- user4 || 13/10/2022 || obj_data.put('dteyear',r_runemp.dteyear);
      obj_data.put('dtemonth',r_runemp.dtemonth);
      if r_runemp.dtemonth is null then
        obj_data.put('desc_dtemonth','');
      else
        obj_data.put('desc_dtemonth',get_nammthful(r_runemp.dtemonth,global_v_lang));
      end if;
      obj_data.put('constnt',v_constnt);
      obj_data.put('running',r_runemp.running);
      obj_data.put('last_id',v_last_id);
      obj_row.put(v_numseq - 1,obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end gen_last_id_data
  --
  procedure save_last_id(json_str_input in clob, json_str_output out clob) is
    param_json                      json;
    param_json_last_id              json;
    json_last_id_row                json;
    v_groupid                       varchar2(4000 char);
    v_dtemonth                      varchar2(4000 char);
    v_dteyear                       varchar2(4000 char);
    v_running                       varchar2(4000 char);
  begin
    initial_value(json_str_input);
    param_json                  := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
    param_json_last_id          := json(param_json.get('dataRows'));
    for i in 0..param_json_last_id.count-1 loop
      json_last_id_row   := json(param_json_last_id.get(to_char(i)));
      v_groupid          := hcm_util.get_string(json_last_id_row,'groupid');
      v_dtemonth         := hcm_util.get_string(json_last_id_row,'dtemonth');
      v_dteyear          := hcm_util.get_string(json_last_id_row,'dteyear');
      v_running          := hcm_util.get_string(json_last_id_row,'running');
      --<< user4 || 13/10/2022
      if v_dteyear > 2300 then
        v_dteyear := v_dteyear-543;
      end if;
      -->> user4 || 13/10/2022
     begin
        update  trunempid
        set     running   = v_running,
                coduser   = global_v_coduser
        where   groupid   = v_groupid
        and     dteyear   = nvl(v_dteyear,'9999') -- user4 || and     dteyear   = nvl(v_dteyear-543,'9999')--User37 #6760 03/09/2021 nvl(v_dteyear,'9999')
        and     dtemonth  = nvl(v_dtemonth,'99')
        and     running   <> v_running;
      end;
  --    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end loop;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end save_personal_tax
  --
end;

/

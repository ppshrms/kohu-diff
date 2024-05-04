--------------------------------------------------------
--  DDL for Package Body HRAL3FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3FE" is

  procedure check_index is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end If;

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
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure check_insert is
    v_count     number := 0;
    v_codempid  varchar2(1000 char);
    v_dtemax    date   := to_date('01/01/9999','dd/mm/yyyy');
  begin
    if p_numcard is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    else
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if p_stacard is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_dteend < p_dtestrt then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;

    begin
    select codempid into v_codempid
      from tempcard
     where numcard = p_numcard
       and dtestrt <> p_dtestrt
       and ((p_dtestrt between dtestrt and nvl(nvl(dtereturn,dteend),v_dtemax) or
            (p_dteend  is not null and
       	     p_dteend  between dtestrt and nvl(nvl(dtereturn,dteend),v_dtemax))) or
            (dtestrt between p_dtestrt and nvl(p_dteend,v_dtemax)) or
            (nvl(dtereturn,dteend) is not null and
             nvl(dtereturn,dteend) between p_dtestrt and nvl(p_dteend,v_dtemax)))
       and rownum = 1;
--			select codempid into v_codempid
--			from 	 tempcard
--			where  numcard = p_numcard
--			and	dtestrt <> p_dtestrt
--			and p_dtestrt between
--      and (p_dteend)
--          p_dteend between
--          (dtestrt between p_dtestrt and nvl(p_dteend,v_dtemax) or
--			 		 nvl(dteend,v_dtemax) between p_dtestrt and nvl(p_dteend,v_dtemax) or
--			 		 p_dtestrt between dtestrt and nvl(dteend,v_dtemax) or
--			 		 nvl(p_dteend,v_dtemax) between dtestrt and nvl(dteend,v_dtemax))
--			and rownum = 1;
        param_msg_error := get_error_msg_php('AL0016',global_v_lang);
        return;
		exception when no_data_found then
			null;
		end;
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numcard           := hcm_util.get_string_t(json_obj,'p_numcard');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_stacard           := hcm_util.get_string_t(json_obj,'p_stacard');
    p_desnote           := hcm_util.get_string_t(json_obj,'p_desnote');
    p_dtereturn         := to_date(hcm_util.get_string_t(json_obj,'p_dtereturn'),'dd/mm/yyyy');
    -- new param --
    p_dteuseen          := to_date(hcm_util.get_string_t(json_obj,'p_dteuseen'),'dd/mm/yyyy');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
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

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_desc_stacard  varchar2(1000 char);
    v_stacard       varchar2(1000 char);

    cursor c1 is
      select a.numcard, a.dtestrt, a.dteend, a.codempid, a.stacard, a.dtereturn
        from tempcard a, temploy1 b
       where a.numcard  = nvl(p_numcard,a.numcard)
         and a.codempid = nvl(p_codempid,a.codempid)
         and a.codempid = b.codempid
         and b.codcomp like p_codcomp||'%'
      order by numcard,dtestrt;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    obj_result := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      if r1.stacard = '1' then
        v_stacard := '90';
      elsif r1.stacard = '2' then
        v_stacard := '100';
      end if;

      begin
        select decode(global_v_lang, '101', desclabele,
                                     '102', desclabelt,
                                     '103', desclabel3,
                                     '104', desclabel4,
                                     '105', desclabel5)
          into v_desc_stacard
          from tapplscr
         where codapp = 'HRAL3FE2'
           and numseq = v_stacard;
      exception when no_data_found then
        v_desc_stacard := null;
      end;

      obj_data.put('coderror', '200');
      obj_data.put('numcard', r1.numcard);
      obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
      obj_data.put('dtereturn', to_char(r1.dtereturn,'dd/mm/yyyy'));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
      obj_data.put('v_stacard', v_desc_stacard);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail (json_str_output out clob) as
    obj_data       json_object_t;
    v_total        number := 0;
    v_count        number := 0;
    v_count_rn     number := 0;
    v_numcard      varchar2(1000 char);
    v_dtestrt      date;
    v_dteend       date;
    v_codempid     varchar2(1000 char);
    v_codempid2    varchar2(1000 char);
    v_stacard      varchar2(1000 char);
    v_desnote      varchar2(1000 char);
    v_dtereturn    date;
  begin
    if p_numcard is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
		end if;
		if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
		end if;
    if param_msg_error is null then
      begin
        select numcard, dtestrt, dteend, codempid, stacard, desnote, dtereturn,
               rownum
         into  v_numcard, v_dtestrt, v_dteend, v_codempid, v_stacard, v_desnote, v_dtereturn,
               v_total
          from tempcard
         where numcard = p_numcard
           and dtestrt = p_dtestrt;
      exception when no_data_found then
         v_total := 0;
      end;
      if v_total > 0 then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numcard', v_numcard);
        obj_data.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));
        obj_data.put('codempid', v_codempid);
        obj_data.put('desc_codempid', get_temploy_name(v_codempid, global_v_lang));
        obj_data.put('stacard', v_stacard);
        obj_data.put('desnote', v_desnote);
        obj_data.put('dtereturn', to_char(v_dtereturn,'dd/mm/yyyy'));

        json_str_output := obj_data.to_clob;
      else
        if p_codempid is null then
        	-----[[CHK]] Can Not Add/Update Data Backword-------------------------------------
          begin
            select codempid into v_codempid2
            from   tempcard
            where  numcard = p_numcard
            and	   p_dtestrt between dtestrt and nvl(nvl(dtereturn,dteend),p_dtestrt)
            and rownum = 1;
            --
--1705            param_msg_error := get_error_msg_php('AL0014',global_v_lang);
            param_msg_error := get_error_msg_php('AL0014',global_v_lang,'('||v_codempid2||')');
--1705
          exception when no_data_found then
            null;
          end;
          -----[[CHK]] This card in used----------------------------------------------------
          begin
            select dtestrt into v_dtestrt
            from 	 tempcard
            where  numcard = p_numcard
            and		 dtestrt > p_dtestrt
            and rownum = 1;
            param_msg_error := get_error_msg_php('HR1501',global_v_lang);
          exception when no_data_found then
            null;
          end;
        end if;
        --
        if param_msg_error is null then
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('dteend', '');
          obj_data.put('codempid', '');
          obj_data.put('desc_codempid', '');
          obj_data.put('stacard', '');
          obj_data.put('desnote', '');
          obj_data.put('dtereturn', '');

          json_str_output := obj_data.to_clob;
        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure post_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_input);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_detail;

  procedure save_detail(json_str_input in clob) is
    json_obj        json_object_t;
    json_obj2       json_object_t;

  begin
    check_insert;
    begin
      insert into tempcard (numcard, dtestrt, dteend, codempid, desnote, stacard, dtereturn, codcreate, coduser)
           values (p_numcard, p_dtestrt, p_dteend, p_codempid, p_desnote, p_stacard, p_dtereturn, global_v_coduser, global_v_coduser);
    exception when DUP_VAL_ON_INDEX then
      update tempcard set dteend   = p_dteend,
                          codempid = p_codempid,
                          desnote  = p_desnote,
                          stacard  = p_stacard,
                          dtereturn = p_dtereturn,
                          coduser  = global_v_coduser
                    where numcard  = p_numcard
                      and dtestrt  = p_dtestrt;
    end;
  end save_detail;

  procedure delete_detail(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_flg           varchar2(1000);
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        p_numcard       := hcm_util.get_string_t(param_json_row,'numcard');
        p_dtestrt       := to_date(hcm_util.get_string_t(param_json_row,'dtestrt'),'dd/mm/yyyy');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');

        if v_flg = 'delete' then
          begin
            delete from tempcard
                  where numcard = p_numcard
                    and dtestrt = p_dtestrt;
          exception when others then null;
          end;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_detail;

END HRAL3FE;

/

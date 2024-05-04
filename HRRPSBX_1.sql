--------------------------------------------------------
--  DDL for Package Body HRRPSBX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRPSBX" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    logic			json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_comlevel          := hcm_util.get_string_t(json_obj,'p_comlevel');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'codcompy');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'codcomp');
    b_index_codwork     := hcm_util.get_string_t(json_obj,'codwork');
    b_index_splitrow    := hcm_util.get_string_t(json_obj,'splitrow');
    b_index_splitcol    := hcm_util.get_string_t(json_obj,'splitcol');

    p_logic1       := hcm_util.get_json_t(json_obj,'syncond1');
    p_logic2       := hcm_util.get_json_t(json_obj,'syncond2');
    p_logic3       := hcm_util.get_json_t(json_obj,'syncond3');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
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
  procedure gen_data(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_code1         varchar2(3000);
    v_code2         varchar2(3000);
    v_code3         varchar2(3000);
    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;

    v_cursor       number;
    v_codcomp      varchar2(100);
    v_idx           number := 0;

    cursor c1 is
      select hcm_util.get_codcomp_level (codcomp,p_comlevel) codcomp,
             count( case when codsex = 'M' then 'x' end ) count_m,
             count( case when codsex = 'F' then 'x' end ) count_f,
             count(codempid) count_all,
             min(qtywork) min_qtywork,
             max(qtywork) max_qtywork,
             avg(qtywork) avg_qtywork,
             min(ages_month) min_age,
             max(ages_month) max_age
        from v_temploy
       where hcm_util.get_codcomp_level (codcomp,1) = p_codcompy
         and staemp in ('1','3') ----
    group by hcm_util.get_codcomp_level (codcomp,p_comlevel)
    order by hcm_util.get_codcomp_level (codcomp,p_comlevel);
  begin
    --table
    v_rcnt  := 0;
    obj_row := json_object_t();
      begin
        delete
          from ttemprpt
         where codapp = 'HRRPSBX'
           and codempid = global_v_codempid;
      end;
    for i in c1 loop
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      v_codcomp   := i.codcomp;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcompy',p_codcompy);
      obj_data.put('desc_codcompy', get_tcompny_name(p_codcompy ,global_v_lang));
      obj_data.put('codcomp',v_codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
      obj_data.put('count_m',i.count_m);
      obj_data.put('count_f',i.count_f);
      obj_data.put('count_all',i.count_all);
      obj_data.put('min_qtywork',trunc(i.min_qtywork/12)||':'||(i.min_qtywork - (trunc(i.min_qtywork/12)*12)));
      obj_data.put('max_qtywork',trunc(i.max_qtywork/12)||':'||(i.max_qtywork - (trunc(i.max_qtywork/12)*12)));
      obj_data.put('avg_qtywork',trunc(i.avg_qtywork/12)||':'||trunc(i.avg_qtywork - (trunc(i.avg_qtywork/12)*12)));
      obj_data.put('min_age',trunc(i.min_age/12)||':'||(i.min_age - (trunc(i.min_age/12)*12)));
      obj_data.put('max_age',trunc(i.max_age/12)||':'||(i.max_age - (trunc(i.max_age/12)*12)));
      obj_row.put(to_char(v_rcnt-1),obj_data);

      /*Type1 QTY employees*/
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,20), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,30),get_label_name('HRRPSBX2',global_v_lang,20),
              i.count_m,get_label_name('HRRPSBX2',global_v_lang,10));
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,20), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,40),get_label_name('HRRPSBX2',global_v_lang,20),
              i.count_f,get_label_name('HRRPSBX2',global_v_lang,10));
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,20), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,50),get_label_name('HRRPSBX2',global_v_lang,20),
              i.count_all,get_label_name('HRRPSBX2',global_v_lang,10));

      /*Type2 employees work years*/
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,60), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,70),get_label_name('HRRPSBX2',global_v_lang,60),
              round(i.min_qtywork/12,1),get_label_name('HRRPSBX2',global_v_lang,10));
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,60), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,80),get_label_name('HRRPSBX2',global_v_lang,60),
              round(i.max_qtywork/12,1),get_label_name('HRRPSBX2',global_v_lang,10));
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRPSBX',v_idx,
              get_label_name('HRRPSBX2',global_v_lang,60), v_codcomp, get_tcenter_name(v_codcomp,global_v_lang),
              get_label_name('HRRPSBX2',global_v_lang,90),get_label_name('HRRPSBX2',global_v_lang,60),
              round(i.avg_qtywork/12,1),get_label_name('HRRPSBX2',global_v_lang,10));
    end loop;

    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'v_temploy');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
  procedure get_date(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
    obj_data        json_object_t;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if param_msg_error is null then
        obj_row.put('date',to_char(sysdate,'dd/mm/yyyy'));
        obj_row.put('coderror', '200');
        json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';

    cursor c1 is
      select codcompy
        from tcompny
       where codcompy = p_codcompy;
  begin
    if  p_codcompy is not null then
        for i in c1 loop
            v_data  := 'Y';
            v_flgSecur := secur_main.secur7(p_codcompy,global_v_coduser);
            if v_flgSecur then
                v_chkSecur  := 'Y';
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        elsif v_chkSecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
  end;

	procedure getDropdowns(json_str_input in clob, json_str_output out clob) as obj_row json;
		json_obj		json_object_t;
		obj_item		json_object_t;
	begin
        initial_value(json_str_input);

		if p_codcompy is not null then
			genDropdowns(json_str_output);
		else
			json_str_output := get_response_message(null,param_msg_error,global_v_lang);
		end if;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400',param_msg_error,global_v_lang);
	end;

	procedure genDropdowns(json_str_output out clob)as
		obj_data		json_object_t;
		obj_row			json_object_t;
		obj_main		json_object_t;
		obj_result		json_object_t;
		v_rcnt			number := 0;
		name_tcodec		varchar2(200 char);
		name_tcenter	varchar2(200 char);
		name_tpostn		varchar2(200 char);

		cursor list_comlevel is
            select comlevel
              from tcompnyc
             where codcompy = p_codcompy
               AND comlevel <> 1
             order by comlevel;
	begin
        obj_main:= json_object_t();
		obj_row := json_object_t();
		v_rcnt  := 0;

		for r1 in list_comlevel loop
			obj_row.put(to_char(r1.comlevel), get_label_name('HRRPSBX',global_v_lang,140) || ' ' || r1.comlevel);
		end loop;
        obj_main.put('coderror', '200');
        obj_main.put('comlevel', obj_row);
		json_str_output := obj_main.to_clob;
	exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end;

end;

/

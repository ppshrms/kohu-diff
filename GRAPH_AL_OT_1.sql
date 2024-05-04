--------------------------------------------------------
--  DDL for Package Body GRAPH_AL_OT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_AL_OT" AS
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_year      := hcm_util.get_string_t(json_obj,'p_year');
    b_index_month     := nvl(hcm_util.get_string_t(json_obj,'p_month'),'A');
    b_index_comgrp    := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_complvl   := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_codcalen  := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_codshift  := hcm_util.get_string_t(json_obj,'p_codshift');
    b_index_codrem    := hcm_util.get_string_t(json_obj,'p_codrem');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    -- configuration
    conf_display_codcomp  := false;
    conf_defalut_complvl  := '2';

    b_index_complvl := nvl(b_index_complvl,conf_defalut_complvl);  -- set default complvl

  end initial_value;
  --
  function get_ot_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    v_percent     number;
    v_flgdata     boolean;

    cursor c_ovrtimesum is
      select nvl(sum(b.qtyminwrkw),0) qtyminwrkw,
             nvl(sum(a.qtyminot),0) qtyminot,
             nvl(sum(a.qtydayot),0) qtydayot
        from v_graph_al_ot a, v_graph_al_attence b
       where a.dteyre   = b.dteyre(+)
         and a.dtemonth = b.dtemonth(+)
         and a.codcomp  = b.codcomp(+)
         and a.codcalen = b.codcalen(+)
         and a.codshift = b.codshift(+)
         and a.numlvl   = b.numlvl(+)
         and a.dteyre   = b_index_year
         and a.dtemonth = decode(b_index_month,'A',a.dtemonth,b_index_month)
         and (b_index_comgrp is null or a.compgrp  = nvl(b_index_comgrp,a.compgrp))
         and a.codcomp  like b_index_codcomp
         and a.codcalen = nvl(b_index_codcalen,a.codcalen)
         and a.codshift = nvl(b_index_codshift,a.codshift)
         and a.codrem   = nvl(b_index_codrem,a.codrem)
       --  and (b_index_complvl is null or a.comlevel = nvl(b_index_complvl,a.comlevel))
         and a.numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and a.codcomp like tusrcom.codcomp||'%');
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    obj_row.put('coderror','200');

		for r1 in c_ovrtimesum loop
			obj_row.put('qtydayhour',to_char(r1.qtyminwrkw/60,'fm999,999,999,990'));
			obj_row.put('ot',to_char(r1.qtyminot/60,'fm999,999,999,990'));
			v_percent := 0;
			if r1.qtyminwrkw > 0 then
				v_percent := (r1.qtyminot*100)/r1.qtyminwrkw;
			end if;
			obj_row.put('pcot',to_char(v_percent,'fm999,999,999,990.90'));
		end loop;

    return obj_row.to_clob;
  end;
  --
  function get_ot_by_department(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_codcomp       varchar2(100 char);
    v_desc_codcomp  varchar2(4000 char);

    cursor c_ovrtimesum is
    select hcm_util.get_codcomp_level(codcomp,b_index_complvl) codcomp,
             nvl(sum(qtyminot),0) qtyminot,
             nvl(sum(qtydayot),0) qtydayot
        from v_graph_al_ot
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
         and codrem   = nvl(b_index_codrem,codrem)
         --and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and v_graph_al_ot.codcomp like tusrcom.codcomp||'%')
      group by hcm_util.get_codcomp_level(codcomp,b_index_complvl)
      order by hcm_util.get_codcomp_level(codcomp,b_index_complvl);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();
    for r1 in c_ovrtimesum loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r1.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r1.codcomp,global_v_lang));
      arr_datasets.append(to_char(r1.qtyminot/60,'fm99999999999999999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_ot_by_month(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
		v_ot					number;

    cursor c_ovrtimesum is
      select dtemonth,
             nvl(sum(qtyminot),0) qtyminot,
             nvl(sum(qtydayot),0) qtydayot
        from graph_tovrtime--v_graph_al_ot
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
         and codrem   = nvl(b_index_codrem,codrem)
        -- and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and graph_tovrtime.codcomp like tusrcom.codcomp||'%')
      group by dtemonth
      order by to_number(dtemonth);
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

		if b_index_month = 'A' then
			for i in 1..to_number(to_char(sysdate,'mm')) loop--for i in 1..12 loop
				b_index_month := i;
				v_ot := 0;
				for r1 in c_ovrtimesum loop
					v_ot := r1.qtyminot/60;
				end loop;
				arr_labels.append(get_tlistval_name('MONTH',i,global_v_lang));
				arr_datasets.append(to_char(v_ot,'fm99999999999999999990.90'));
			end loop;
		else
			for r1 in c_ovrtimesum loop
				arr_labels.append(get_tlistval_name('MONTH',r1.dtemonth,global_v_lang));
				arr_datasets.append(to_char(r1.qtyminot/60,'fm99999999999999999990.90'));
			end loop;
		end if;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_ot_by_cause(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_ovrtimesum is
      select codrem,
             nvl(sum(qtyminot),0) qtyminot,
             nvl(sum(qtydayot),0) qtydayot
        from graph_tovrtime--v_graph_al_ot
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
         and codrem   = nvl(b_index_codrem,codrem)
        -- and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and graph_tovrtime.codcomp like tusrcom.codcomp||'%')
      group by codrem
      order by codrem;
  begin

    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r1 in c_ovrtimesum loop
      arr_labels.append(r1.codrem||' : '||get_tcodec_name('tcodotrq',r1.codrem,global_v_lang));
      arr_datasets.append(to_char(r1.qtyminot/60,'fm99999999999999999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_percent_ot(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_codcomp       varchar2(100 char);
    v_desc_codcomp  varchar2(4000 char);
    v_percent       number;

    cursor c_ovrtimesum is
      select hcm_util.get_codcomp_level(a.codcomp,b_index_complvl) codcomp,
             nvl(sum(b.qtyminwrkw),0) qtyminwrkw,
             nvl(sum(a.qtyminot),0) qtyminot,
             nvl(sum(a.qtydayot),0) qtydayot
        from v_graph_al_ot a, v_graph_al_attence b
       where a.dteyre   = b.dteyre(+)
         and a.dtemonth = b.dtemonth(+)
         and a.codcomp  = b.codcomp(+)
         and a.codcalen = b.codcalen(+)
         and a.codshift = b.codshift(+)
         and a.numlvl   = b.numlvl(+)
         and a.dteyre   = b_index_year
         and a.dtemonth = decode(b_index_month,'A',a.dtemonth,b_index_month)
         and (b_index_comgrp is null or a.compgrp  = nvl(b_index_comgrp,a.compgrp))
         and a.codcomp  like b_index_codcomp
         and a.codcalen = nvl(b_index_codcalen,a.codcalen)
         and a.codshift = nvl(b_index_codshift,a.codshift)
         and a.codrem   = nvl(b_index_codrem,a.codrem)
     --    and (b_index_complvl is null or a.comlevel = nvl(b_index_complvl,a.comlevel))
         and a.numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and a.codcomp like tusrcom.codcomp||'%')
      group by hcm_util.get_codcomp_level(a.codcomp,b_index_complvl)
      order by hcm_util.get_codcomp_level(a.codcomp,b_index_complvl);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();
    for r1 in c_ovrtimesum loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r1.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r1.codcomp,global_v_lang));

      v_percent := 0;
      if r1.qtyminwrkw > 0 then
        v_percent := r1.qtyminot*100/r1.qtyminwrkw;
      end if;
      arr_datasets.append(to_char(v_percent,'fm999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
end;


/

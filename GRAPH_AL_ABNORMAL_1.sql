--------------------------------------------------------
--  DDL for Package Body GRAPH_AL_ABNORMAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GRAPH_AL_ABNORMAL" AS
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
    b_index_month     := hcm_util.get_string_t(json_obj,'p_month');
    b_index_comgrp    := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp')||'%';
    b_index_complvl   := hcm_util.get_string_t(json_obj,'p_complvl');
    b_index_codcalen  := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_codshift  := hcm_util.get_string_t(json_obj,'p_codshift');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    -- configuration
    conf_display_codcomp  := false;
    conf_defalut_complvl  := '2';

    b_index_complvl := nvl(b_index_complvl,conf_defalut_complvl);  -- set default complvl

  end initial_value;
  --
  function get_absence_summary(json_str_input clob) return clob is
    obj_row       json_object_t;
    v_percent     number;

    cursor c_lateabssum is
      select nvl(sum(b.qtydaywrkw),0)   qtydaywrkw,
             nvl(sum(a.qtytlate),0)   	qtytlate,
             nvl(sum(a.qtytearly),0)  	qtytearly,
             nvl(sum(a.qtydaylate),0)   qtydaylate,
             nvl(sum(a.qtydayearly),0)  qtydayearly,
             nvl(sum(a.qtydayabsent),0) qtydayabsent
        from graph_tlateabs a, graph_tattence b--from v_graph_al_abnormal a, v_graph_al_attence b
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
         --and (b_index_complvl is null or a.comlevel = nvl(b_index_complvl,a.comlevel))
         and a.numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and a.codcomp like tusrcom.codcomp||'%');
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    obj_row.put('coderror','200');

    for r1 in c_lateabssum loop
      obj_row.put('qtydaywork',to_char(r1.qtydaywrkw,'fm999,999,999,990'));
      obj_row.put('qtytlate',to_char(r1.qtytlate,'fm999,999,999,990'));
      obj_row.put('qtytearly',to_char(r1.qtytearly,'fm999,999,999,990'));
      obj_row.put('qtydayabsence',to_char(r1.qtydayabsent,'fm999,999,999,990'));
      v_percent := 0;
      if r1.qtydaywrkw > 0 then
        v_percent := ((r1.qtydaylate + r1.qtydayearly + r1.qtydayabsent)*100)/r1.qtydaywrkw;
      end if;
			v_percent := least(v_percent,100);
      obj_row.put('pcabnormal',to_char(v_percent,'fm999,999,999,990.90'));
      obj_row.put('pcwork',to_char(100 - v_percent,'fm999,999,999,990.90'));
    end loop;
    return obj_row.to_clob;
  end;
  --
  function get_absence_by_department(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_codcomp       varchar2(100 char);
    v_desc_codcomp  varchar2(4000 char);

    cursor c_lateabssum is
      select hcm_util.get_codcomp_level(codcomp,b_index_complvl) codcomp,
             nvl(sum(qtyminlate),0)   qtyminlate,
             nvl(sum(qtyminearly),0)  qtyminearly,
             nvl(sum(qtyminabsent),0) qtyminabsent,
             nvl(sum(qtydaylate),0)   qtydaylate,
             nvl(sum(qtydayearly),0)  qtydayearly,
             nvl(sum(qtydayabsent),0) qtydayabsent
        from v_graph_al_abnormal
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
         --and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and v_graph_al_abnormal.codcomp like tusrcom.codcomp||'%')
      group by hcm_util.get_codcomp_level(codcomp,b_index_complvl)
      order by hcm_util.get_codcomp_level(codcomp,b_index_complvl);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();
    for r1 in c_lateabssum loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r1.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r1.codcomp,global_v_lang));
      arr_datasets.append(to_char(r1.qtydayabsent,'fm999999999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_late_early_by_department(json_str_input clob) return clob is
    obj_row         json_object_t;
    arr_labels      json_array_t;
    arr_datasets_late    json_array_t;
    arr_datasets_early   json_array_t;
    arr_data        json_array_t;
    v_codcomp       varchar2(100 char);
    v_desc_codcomp  varchar2(4000 char);

    cursor c_lateabssum is
      select hcm_util.get_codcomp_level(codcomp,b_index_complvl) codcomp,
             nvl(sum(qtytlate),0)   qtytlate,
             nvl(sum(qtytearly),0)  qtytearly
        from v_graph_al_abnormal
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
        -- and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and v_graph_al_abnormal.codcomp like tusrcom.codcomp||'%')
      group by hcm_util.get_codcomp_level(codcomp,b_index_complvl)
      order by hcm_util.get_codcomp_level(codcomp,b_index_complvl);
  begin
    initial_value(json_str_input);

    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets_late  := json_array_t();
    arr_datasets_early := json_array_t();
    for r1 in c_lateabssum loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r1.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r1.codcomp,global_v_lang));
      arr_datasets_late.append(r1.qtytlate);
      arr_datasets_early.append(r1.qtytearly);
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets_late);
    arr_data.append(arr_datasets_early);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_absence_by_month(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
		v_percent			number;

    cursor c_lateabssum is
      select a.dtemonth,
						 nvl(sum(b.qtydaywrkw),0)   qtydaywrkw,
             nvl(sum(a.qtyminlate),0)   qtyminlate,
             nvl(sum(a.qtyminearly),0)  qtyminearly,
             nvl(sum(a.qtyminabsent),0) qtyminabsent,
             nvl(sum(a.qtydaylate),0)   qtydaylate,
             nvl(sum(a.qtydayearly),0)  qtydayearly,
             nvl(sum(a.qtydayabsent),0) qtydayabsent
        from v_graph_al_abnormal a, v_graph_al_attence b
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
        -- and (b_index_complvl is null or a.comlevel = nvl(b_index_complvl,a.comlevel))
         and a.numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and a.codcomp like tusrcom.codcomp||'%')
      group by a.dtemonth
      order by to_number(a.dtemonth);
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

		if b_index_month = 'A' then
			for i in 1..12 loop
				b_index_month := i;
				v_percent := 0;
				for r1 in c_lateabssum loop
				  if r1.qtydaywrkw > 0 then
						v_percent := (r1.qtydaylate + r1.qtydayearly + r1.qtydayabsent) * 100 / r1.qtydaywrkw;
					end if;
				end loop;
				arr_labels.append(get_tlistval_name('MONTH',i,global_v_lang));
				arr_datasets.append(to_char(v_percent,'fm9999999990.90'));
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
  function get_absence_by_cause(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;

    cursor c_lateabssum is
      select codreqst,
             nvl(sum(qtyminlate),0)   qtyminlate,
             nvl(sum(qtyminearly),0)  qtyminearly,
             nvl(sum(qtyminabsent),0) qtyminabsent,
             nvl(sum(qtydaylate),0)   qtydaylate,
             nvl(sum(qtydayearly),0)  qtydayearly,
             nvl(sum(qtydayabsent),0) qtydayabsent
        from v_graph_al_abnormal
       where dteyre   = b_index_year
         and dtemonth = decode(b_index_month,'A',dtemonth,b_index_month)
         and (b_index_comgrp is null or compgrp  = nvl(b_index_comgrp,compgrp))
         and codcomp  like b_index_codcomp
         and codcalen = nvl(b_index_codcalen,codcalen)
         and codshift = nvl(b_index_codshift,codshift)
         --and (b_index_complvl is null or comlevel = nvl(b_index_complvl,comlevel))
         and numlvl   between global_v_zminlvl and global_v_zwrklvl
         and exists   (select tusrcom.coduser
                         from tusrcom
                        where tusrcom.coduser = global_v_coduser
                          and v_graph_al_abnormal.codcomp like tusrcom.codcomp||'%')
      group by codreqst
      order by codreqst;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    arr_labels := json_array_t();
    arr_datasets := json_array_t();

    for r1 in c_lateabssum loop
      arr_labels.append(r1.codreqst||' : '||get_tcodec_name('tcodtime',r1.codreqst,global_v_lang));
      arr_datasets.append(to_char(r1.qtydayabsent,'fm999999999990.90'));
    end loop;

    arr_data := json_array_t();
    arr_data.append(arr_datasets);

    obj_row.put('coderror','200');
    obj_row.put('labels',arr_labels);
    obj_row.put('data',arr_data);
    return obj_row.to_clob;
  end;
  --
  function get_percent_abnormal(json_str_input clob) return clob is
    obj_row       json_object_t;
    arr_labels    json_array_t;
    arr_datasets  json_array_t;
    arr_data      json_array_t;
    v_codcomp       varchar2(100 char);
    v_desc_codcomp  varchar2(4000 char);
    v_percent       number;

    cursor c_lateabssum is
      select hcm_util.get_codcomp_level(a.codcomp,b_index_complvl) codcomp,
             nvl(sum(b.qtydaywrkw),0) qtydaywrkw,
             nvl(sum(qtyminlate),0)   qtyminlate,
             nvl(sum(qtyminearly),0)  qtyminearly,
             nvl(sum(qtyminabsent),0) qtyminabsent,
             nvl(sum(qtydaylate),0)   qtydaylate,
             nvl(sum(qtydayearly),0)  qtydayearly,
             nvl(sum(qtydayabsent),0) qtydayabsent
        from v_graph_al_abnormal a, v_graph_al_attence b
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
        -- and (b_index_complvl is null or a.comlevel = nvl(b_index_complvl,a.comlevel))
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
    for r1 in c_lateabssum loop
      v_desc_codcomp := null;
      if conf_display_codcomp then
        v_desc_codcomp := hcm_util.get_codcomp_level(r1.codcomp,b_index_complvl,'-')||' : ';
      end if;
      arr_labels.append(v_desc_codcomp||get_tcenter_name(r1.codcomp,global_v_lang));

      v_percent := 0;
      if r1.qtydaywrkw > 0 then
        v_percent := (r1.qtydaylate + r1.qtydayearly + r1.qtydayabsent)*100/r1.qtydaywrkw;
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
  --
end;

/

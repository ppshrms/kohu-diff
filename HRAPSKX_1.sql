--------------------------------------------------------
--  DDL for Package Body HRAPSKX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPSKX" is
-- last update: 02/09/2020 21:00
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken             := hcm_secur.get_v_chken;
        json_obj            := json_object_t(json_str);
        --global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
       --b_index
        b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyear');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numseq');
        b_index_stakpi      := hcm_util.get_string_t(json_obj,'p_stakpi');
        b_index_color       := hcm_util.get_string_t(json_obj,'p_color');
        --screen
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_codkpino    := hcm_util.get_string_t(json_obj,'p_codkpi');
        b_index_kpides      := hcm_util.get_string_t(json_obj,'p_kpides'); ----

        p_index_rows        := hcm_util.get_json_t(json_obj,'p_index_rows'); ----

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --
  procedure get_data1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_output);
        --delete
        param_msg_error := null;
        v_numseq := 1;
        begin
          delete from ttemprpt
           where codempid = global_v_codempid
             and codapp   = 'HRAPSKX';
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	  boolean;
    v_typkpi        varchar2(1 char); ----

    cursor c1 is
      select  a.codcomp , b.color ,a.codkpino, a.kpides ,a.target , a.kpivalue , a.achieve ,  a.mtrfinish , nvl(a.stakpi,'N') stakpi,
              check_type_kpi(a.dteyreap , a.numtime  ,a.codcomp,a.codkpino) type_kpi,a.qtyscor
      from    tkpidph a , tkpidpg b
      where   a.codcomp      like b_index_codcompy||'%'
      and     a.dteyreap      = b_index_dteyreap
      and     a.numtime       = b_index_numtime
      and     (
      (
      (nvl(a.stakpi,'N')   like b_index_stakpi||'%' and (b_index_stakpi is not null and b_index_stakpi<>'A')) or b_index_stakpi ='A'  )----
            or (b.color    like b_index_color||'%' and  b_index_color is not null))
--      and     ((nvl(a.stakpi,'N')   like b_index_stakpi||'%' and a.stakpi is not null)
--            or (b.color    like b_index_color||'%' and  b.color is not null))
      and     a.dteyreap      = b.dteyreap
      and     a.numtime       = b.numtime
      and     a.codcomp       = b.codcomp
      and     a.codkpino      = b.codkpino
      and     a.grade         = b.grade
    order by a.codcomp , b.color ,a.codkpino;

  begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
      v_flgdata := 'Y';
    end loop;
    if v_flgdata = 'Y' then
      v_chksecu := '2';
      for i in c1 loop
        flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
        if flgpass then
          v_flgsecu := 'Y';
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
        --  obj_data.put('codcomp',i.codcomp);
          obj_data.put('codcomp',i.codcomp); ----
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
          --obj_data.put('bgcolor',i.color); ----
          if i.color is null then ----
            obj_data.put('bgcolor','');
          else
            obj_data.put('bgcolor','<i class="fas fa-circle" style="color: '||i.color||';"></i>');
          end if;
          if i.type_kpi = '1' then ----
            v_typkpi := 'D'; --D-Department KPI
          elsif i.type_kpi = '2' then
            v_typkpi := 'J'; --J-Funtional KPI
          else
            v_typkpi := 'I'; --I-Individual KPI
          end if;
          obj_data.put('typkpi',get_tlistval_name('TYPKPI',v_typkpi,global_v_lang)); ----i.type_kpi);
          obj_data.put('codkpi',i.codkpino);
          obj_data.put('kpides',i.kpides);
          obj_data.put('target',i.target);
          obj_data.put('mtrfinish_1',i.kpivalue);
          obj_data.put('desc_result',i.achieve);
          obj_data.put('mtrfinish_2',nvl(i.mtrfinish,0));
          obj_data.put('qtyscor',nvl(i.qtyscor,0));
          obj_data.put('stakpi',get_tlistval_name('STAKPI',i.stakpi,global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    end if; --v_flgdata
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tkpidph');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --

  procedure get_data2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data2(json_str_output out clob) is
    obj_row         json_object_t;
    data_row        clob; ----
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	  boolean;
    v_codempid      varchar2(40);
    v_codkpi        varchar2(4);
    obj_result      json_object_t; ----

  cursor c1 is
    ----add where new index
  /*  select  a.codempid , a.codcomp, codpos , b.color ,a.CODKPI, a.kpides , a.target , a.mtrfinish, a.achieve , a.mtrrn, a.qtyscor , b.stakpi
    from    tkpiemp a, tkpidpg b
           ,tkpidph c
    where   a.dteyreap  = b_index_dteyreap
    and     a.numtime   = b_index_numtime
    and     a.codcomp   = b_index_codcomp
    and     a.CODKPI    = b_index_codkpino
    and     a.dteyreap  = b.dteyreap
    and     a.numtime   = b.numtime
    and     a.codcomp   = b.codcomp
    and     a.codkpi    = b.codkpino ----
    and     a.grade     = b.grade
    ----
    and     b.dteyreap  = c.dteyreap
    and     b.numtime   = c.numtime
    and     b.codcomp   = c.codcomp
    and     b.codkpino  = c.codkpino
    and     a.grade     = c.grade
    and     ((nvl(c.stakpi,'N')   like b_index_stakpi||'%' and b_index_stakpi is not null)
          or (b.color    like b_index_color||'%' and  b_index_color is not null))
  order by a.codempid;*/
    ----
    select   a.codempid , a.codcomp, codpos , b.color ,a.CODKPI, a.kpides , a.target , a.mtrfinish, a.achieve , a.mtrrn, a. qtyscor , b.stakpi
    from    tkpiemp a, tkpidpg b
    where   a.dteyreap = b_index_dteyreap
    and     a.numtime = b_index_numtime
    and     a.codcomp = b_index_codcomp
    and     a.CODKPI = b_index_codkpino
    and     a.dteyreap = b.dteyreap
    and     a.numtime = b.numtime
    and     a.codcomp = b.codcomp
    and     a.grade = b.grade
    and     a.codkpi = b.codkpino
  order by a.codempid ;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';

    for i in c1 loop
      v_flgdata := 'Y';
    end loop;

    if v_flgdata = 'Y' then
      for i in c1 loop
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
          v_flgsecu := 'Y';
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('#',v_rcnt);
          --obj_data.put('bgcolor',i.color); ----
          if i.color is null then ----
            obj_data.put('bgcolor','');
          else
            obj_data.put('bgcolor','<i class="fas fa-circle" style="color: '||i.color||';"></i>');
          end if;
          obj_data.put('image',get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
    --      obj_data.put('codpos',i.codpos);
          obj_data.put('desc_position',get_tpostn_name(i.codpos,global_v_lang));
          obj_data.put('target',i.target);
          obj_data.put('mtrfinish_1',i.mtrfinish);
          obj_data.put('desc_result',i.achieve);
          obj_data.put('mtrfinish_2',nvl(i.mtrrn,0));
          obj_data.put('qtyscor',nvl(i.qtyscor,0));
      --    obj_data.put('stakpi',i.stakpi);
          obj_data.put('stakpi',get_tlistval_name('STAKPI',i.stakpi,global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;  --flgpass
      end loop; --c1
    end if; --v_flgdata
    --<<----
    data_row := obj_row.to_clob;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('codkpi', b_index_codkpino);
    obj_result.put('kpides', b_index_kpides);
    obj_result.put('table', data_row);
    -->>----

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TKPIEMP');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_result.to_clob; ----obj_row.to_clob;
    end if;
  end;
  -----
  procedure get_graph(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_graph;
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAPSKX';
--    v_numseq    ttemprpt.numseq%type := 0;
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
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;
    j                varchar2(10 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;
    v_numseq2        number;
    v_flgdata        varchar2(1 char) := 'N';
  --  v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre        number :=0;
    v_cs1            number :=0;
    v_cs             number :=0;
    flgpass          boolean;
    v_per_policy    varchar2(40 char);
    v_chksecu       varchar2(1);

    cursor c1 is
      select  a.codcomp , b.color ,a.codkpino, a.kpides ,a.target , a.kpivalue , a.achieve ,  a.mtrfinish , nvl(a.stakpi,'N') stakpi,
              check_type_kpi(a.dteyreap , a.numtime  ,a.codcomp,a.codkpino) type_kpi,a.qtyscor
      from    tkpidph a , tkpidpg b
      where   a.codcomp      like b_index_codcompy||'%'
      and     a.dteyreap      = b_index_dteyreap
      and     a.numtime       = b_index_numtime
      and     (
      (
      (nvl(a.stakpi,'N')   like b_index_stakpi||'%' and (b_index_stakpi is not null and b_index_stakpi<>'A')) or b_index_stakpi ='A'  )----
            or (b.color    like b_index_color||'%' and  b_index_color is not null))
      and     a.dteyreap      = b.dteyreap
      and     a.numtime       = b.numtime
      and     a.codcomp       = b.codcomp
      and     a.codkpino      = b.codkpino
      and     a.grade         = b.grade
    order by a.codcomp , b.color ,a.codkpino;
--      select  a.codkpino, avg(a.mtrfinish) mtrfinish
--      from    tkpidph a , tkpidpg b
--      where   a.dteyreap  = b_index_dteyreap
--      and     a.numtime   = b_index_numtime
--      and     a.codcomp   like b_index_codcomp||'%'
--      and     a.dteyreap  = b.dteyreap
--      and     a.numtime   = b.numtime
--      and     a.codcomp   = b.codcomp
--      and     a.grade     = b.grade
--      and     (
--      (
--      (nvl(a.stakpi,'N')   like b_index_stakpi||'%' and (b_index_stakpi is not null and b_index_stakpi<>'A')) or b_index_stakpi ='A'  )----
--            or (b.color    like b_index_color||'%' and  b_index_color is not null))
----      and     ((nvl(a.stakpi,'N')   like b_index_stakpi||'%' and a.stakpi is not null)
----            or (b.color    like b_index_color||'%' and  b.color is not null))
--      and  ((v_chksecu = '1' )
--         or (v_chksecu = '2' and exists (select codcomp
--                                           from tusrcom x
--                                          where x.coduser = global_v_coduser
--                                            and a.codcomp like a.codcomp||'%')))
--    group by a.codkpino;

begin
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;
    v_chksecu := '2';
    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := '';
        v_item14 := '';
        v_seq_grd := 0;
        for i in c1 loop
            v_flgdata := 'Y';
            v_seq_grd := v_seq_grd+1;
            ----------แกน X
            v_item6  := null;
            v_item4  := v_seq_grd;
            v_item5  := i.codkpino;
            v_item31 := get_label_name('HRAPSKX3', global_v_lang, '10');
            ----------แกน Y
            v_item7  := null;
            v_item8  := get_label_name('HRAPSKX3', global_v_lang, '30');
            v_item9  := get_label_name('HRAPSKX3', global_v_lang, '30');
--            v_item10 := i.mtrfinish;   ----------ค่าข้อมูล
            v_item10 := i.qtyscor;   ----------ค่าข้อมูล
           ----------Insert ttemprpt
            begin
             insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
             v_numseq := v_numseq + 1;
        end loop;--loop i
        commit;
     end if;-- if flgdata
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --


  procedure get_report(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_report;
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_report is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_codcomp   temploy1.codcomp%type;
    v_codkpi    tkpiemp.codkpi%type;
    v_kpides    tkpiemp.kpides%type;
    v_numseq    number := 0;
    v_seqno     number := 0;
    cursor c1 is
     select   a.codempid , a.codcomp, codpos , b.color ,a.CODKPI, a.kpides , a.target , a.mtrfinish, a.achieve , a.mtrrn, a.qtyscor , b.stakpi
      from    tkpiemp a, tkpidpg b
      where   a.dteyreap = b_index_dteyreap
      and     a.numtime = b_index_numtime
      and     a.codcomp = v_codcomp
      and     a.CODKPI = v_codkpi
      and     a.dteyreap = b.dteyreap
      and     a.numtime = b.numtime
      and     a.codcomp = b.codcomp
      and     a.grade = b.grade
      and     a.codkpi = b.codkpino
    order by a.codempid ;
  begin
    delete ttemprpt where codapp = 'HRAPSKX' and codempid = global_v_codempid;
--    insert_ttempclob('TAR', 'HRXXXXX', p_index_rows.to_clob); 
    for i in 0..p_index_rows.get_size-1 loop
        obj_data    := hcm_util.get_json_t(p_index_rows,to_char(i)); 
        v_codcomp   := hcm_util.get_string_t(obj_data,'codcomp');
        v_codkpi    := hcm_util.get_string_t(obj_data,'codkpi');
        v_kpides    := hcm_util.get_string_t(obj_data,'kpides');

        v_numseq := v_numseq + 1;
        insert into ttemprpt(codempid, codapp, numseq,
                             item1, item2, item3)
        values(global_v_codempid, 'HRAPSKX',v_numseq,'DETAIL', 
               v_codkpi, 
               v_codkpi ||' - '||v_kpides);
        v_seqno := 0;       
        for r1 in c1 loop
          v_numseq := v_numseq + 1;
          v_seqno := v_seqno + 1;
          insert into ttemprpt(codempid, codapp, numseq,
                             item1, item2, item3, 
                             item4, item5, item6, 
                             item7, item8, item9, 
                             item10, item11, item12
                             )
          values(global_v_codempid, 'HRAPSKX',v_numseq,
                 'TABLE', v_codkpi, v_seqno,
                 r1.codempid,get_temploy_name(r1.codempid, global_v_lang), get_tpostn_name(r1.codpos,global_v_lang), 
                 r1.target, r1.mtrfinish, r1.achieve,
                 nvl(r1.mtrrn,0), r1.qtyscor,get_tlistval_name('STAKPI',r1.stakpi,global_v_lang));
        end loop;
    end loop;
    commit;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;  
end;

/

--------------------------------------------------------
--  DDL for Package Body HRRP64X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP64X" is
-- last update: 15/09/2020 17:30

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
    b_index_grpcompy    := hcm_util.get_string_t(json_obj,'p_grpcompy');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codlinef        := hcm_util.get_string_t(json_obj,'p_codlinef');
    b_index_year1          := hcm_util.get_string_t(json_obj,'p_year1');
    b_index_year2          := hcm_util.get_string_t(json_obj,'p_year2');
    b_index_year3          := hcm_util.get_string_t(json_obj,'p_year3');

    --block drilldown
    b_index_codcompp := hcm_util.get_string_t(json_obj,'p_codcompp');
    b_index_dteeffec    := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
    v_error         varchar2(4000);
    v_max_comlevel  number  := 0;
  begin
    -- b_index_comgrp check in frontend
    -- b_index_codlinef check in frontend
    if b_index_codcompy is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompy);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
  end check_index;

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
  end get_index;
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';

    cursor c1 is
      select  a.codcompy , a.codlinef , a.dteeffec , a.dteappr , a.codappr ,
                 a.remarkap ,  a.staorg ,  a.flggroup ,
                 decode(global_v_lang,'101',a.deslinefe ,
                                              '102',a.deslineft ,
                                              '103',a.deslinef3 ,
                                              '104',a.deslinef4 , a.deslinef5) desline
        from thisorg a
       where ( (a.codcompy = b_index_grpcompy and a.flggroup = 'Y') or
                   (a.codcompy = b_index_codcompy and nvl(a.flggroup,'N') = 'N') )
           and a.codlinef = nvl(b_index_codlinef , a.codlinef)
           and to_char(a.dteeffec,'yyyy') in (b_index_year1 ,b_index_year2 ,b_index_year3)
    order by a.codcompy,a.codlinef,a.dteeffec;

  begin

    obj_row := json_object_t();
    for i in c1 loop
          v_flgdata := 'Y';

          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcompy',i.codcompy);
          if nvl(i.flggroup,'N') = 'Y' then
            obj_data.put('desc_codcompy',get_tcodec_name('TCOMPGRP',i.codcompy,global_v_lang)); --ชื่อกลุ่มบริษัท
          else
            obj_data.put('desc_codcompy',get_tcompny_name(i.codcompy,global_v_lang)); --ชื่อบริษัท
          end if;
          obj_data.put('codlinef', i.codlinef);
          obj_data.put('desline', i.desline);
          obj_data.put('dteeffec',to_char(I.dteeffec,'dd/mm/yyyy'));
          obj_data.put('status',get_tlistval_name('STAORG',I.staorg,global_v_lang));
          obj_data.put('approvby',get_temploy_name(i.codappr,global_v_lang));
          obj_data.put('dteapprov' ,to_char(I.dteappr,'dd/mm/yyyy'));

          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;  --for i in c1 loop

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISORG');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail (json_str_input in clob,json_str_output out clob) as
    json_input      json_object_t := json_object_t(json_str_input);
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_complvl       thisorg2.numlevel%type;

    cursor c1 is
      select a.numlevel, a.numorg, a.codcompp, a.codpospr,a.codresp,
             b.codempid,b.codpos
        from thisorg2 a, thisorg3 b
      where a.codcompy  = b.codcompy(+)
          and a.codlinef  = b.codlinef (+)
          and a.dteeffec = b.dteeffec (+)
          and a.numlevel  = b.numlevel (+)
          and a.codcompp = b.codcompp(+)
          and ( (a.codcompy = b_index_grpcompy ) or
                   (a.codcompy = b_index_codcompy ) )
          and a.codlinef = nvl(b_index_codlinef , a.codlinef)
          and a.dteeffec   = b_index_dteeffec
--          and a.codcompp = nvl(b_index_codcompp,a.codcompp)
--          and a.numlevel = nvl(v_complvl,a.numlevel)
     order by a.numlevel, a.numorg, a.codcompp ,b.codempid;
  begin
    v_complvl   := hcm_util.get_string_t(json_input,'p_complvl');
    obj_row     := json_object_t();
    for i in c1 loop
          v_flgdata := 'Y';

          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('level',i.numlevel);
          obj_data.put('numseq', i.numorg);
          obj_data.put('codcompp', i.codcompp);
          obj_data.put('desc_codcompp',get_tcenter_name(i.codcompp ,global_v_lang));
          obj_data.put('desc_codposr',get_tpostn_name(i.codpospr,global_v_lang));
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codpos' ,get_tpostn_name(i.codpos,global_v_lang));

          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;  --for i in c1 loop

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISORG2');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  --<<chart
  procedure get_chart (json_str_input in clob,json_str_output out clob) is

  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_chart(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_chart;
  --
  function gen_assistance(p_codcompp  tcenter.codcomp%type) return json_object_t is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_assi        json_object_t;
    v_rcnt          number := 0;
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    v_qtybgman      number;

    cursor c1 is
      select o2.codcompp,o2.codcompr,o2.numlevel,o2.numorg,
             '' as codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o2.codcompy,o2.codlinef,o2.dteeffec
        from thisorg o1, thisorg2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = b_index_codcompy
         and o1.codlinef    = b_index_codlinef
         and o2.codcompp    = p_codcompp
         and o1.dteeffec    = b_index_dteeffec
         and o2.numlevel - trunc(o2.numlevel) > 0
      order by o2.numlevel,o2.numorg;
  begin
    obj_row         := json_object_t();
    obj_assi        := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      i.codimage  := get_emp_img(i.codresp);
      obj_data.put('orgid',trunc(DBMS_RANDOM.VALUE(1000000000000,9999999999999)));
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('codlinef',i.codlinef);
      obj_data.put('desc_codlinef','');
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcompp);
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if i.numlevel = trunc(i.numlevel) then
        v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' : '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;
      obj_data.put('desc_codcomp',v_desc_codcompp);
      obj_data.put('codcompr',i.codcompr);
      obj_data.put('desc_codcompr',get_tcenter_name(i.codcompr,global_v_lang));
      obj_data.put('complvl',i.numlevel);
      obj_data.put('numorg',i.numorg);
      obj_data.put('codpospr',i.codpospr);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpospr,global_v_lang));
      obj_data.put('codempid',i.codresp);
      obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));
      obj_data.put('image',i.codimage);
      obj_data.put('image_path',i.codimage);
      begin
        select nvl(qtybgman,0)
          into v_qtybgman
          from tmanpwm
         where dteyrbug     = to_number(to_char(i.dteeffec,'yyyy'))
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(i.dteeffec,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_data.put('qtybgman',v_qtybgman);
      obj_data.put('qtyexman',nvl(i.qtyexman,0));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    return obj_row;
  end;
  function gen_children(p_codcompp  tcenter.codcomp%type) return json_object_t is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_assi        json_object_t;
    v_rcnt          number := 0;
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    v_qtybgman      number;
    cursor c1 is
      select o2.codcompp,o2.codcompr,o2.numlevel,o2.numorg,
             '' as codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o2.codcompy,o2.codlinef,o2.dteeffec
        from thisorg o1, thisorg2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = b_index_codcompy
         and o1.codlinef    = b_index_codlinef
         and o2.codcompr    = p_codcompp
         and o1.dteeffec    = b_index_dteeffec
         and o2.numlevel - trunc(o2.numlevel) = 0
      order by o2.numlevel,o2.numorg;

    cursor c2 is
      select o2.codcompp,o2.codcompr,o2.numlevel,o2.numorg,
             '' as codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o2.codcompy,o2.codlinef,o2.dteeffec
        from thisorg o1, thisorg2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = b_index_codcompy
         and o1.codlinef    = b_index_codlinef
         and o2.codcompr    = p_codcompp
         and o1.dteeffec    = b_index_dteeffec
         and o2.numlevel - trunc(o2.numlevel) > 0
      order by o2.numlevel,o2.numorg;
  begin
    obj_row         := json_object_t();
    obj_assi        := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      i.codimage  := get_emp_img(i.codresp);
      obj_data.put('orgid',trunc(DBMS_RANDOM.VALUE(1000000000000,9999999999999)));
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('codlinef',i.codlinef);
      obj_data.put('desc_codlinef','');
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcompp);
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if i.numlevel = trunc(i.numlevel) then
        v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' : '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;
      obj_data.put('desc_codcompnyd',v_desc_codcompp);
      obj_data.put('codcompr',i.codcompr);
      obj_data.put('desc_codcompr',get_tcenter_name(i.codcompr,global_v_lang));
      obj_data.put('complvl',i.numlevel);
      obj_data.put('numorg',i.numorg);
      obj_data.put('codpospr',i.codpospr);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpospr,global_v_lang));
      obj_data.put('codempid',i.codresp);
      obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));
      obj_data.put('image',i.codimage);
      obj_data.put('image_path',i.codimage);
      begin
        select nvl(qtybgman,0)
          into v_qtybgman
          from tmanpwm
         where dteyrbug     = to_number(to_char(i.dteeffec,'yyyy'))
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(i.dteeffec,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_data.put('qtybgman',v_qtybgman);
      obj_data.put('qtyexman',nvl(i.qtyexman,0));
      obj_data.put('assists',gen_assistance(i.codcompp));
      if i.codcompp <> i.codcompr then
        obj_data.put('children',gen_children(i.codcompp));

--      else
--        obj_data.put('assists',obj_assi);
--        obj_row.put(to_char(v_rcnt),obj_data);
--        v_rcnt      := v_rcnt + 1;
      end if;
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    return obj_row;
  end;
  --
  procedure gen_chart (json_str_output out clob) is
    obj_data            json_object_t;
    obj_assist          json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_desc_codcompp     tcenter.namcentt%type;
    v_comp_split        tcenter.codcomp%type;
    v_qtybgman          number;

    cursor c1 is
      select o2.codcompp,o2.codcompr,o2.numlevel,o2.numorg,
             '' as codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o2.codcompy,o2.codlinef,o2.dteeffec
        from thisorg o1, thisorg2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = b_index_codcompy
         and o1.codlinef    = b_index_codlinef
         and o1.dteeffec    = b_index_dteeffec
         and o2.codcompr is null
         and o2.numorg      = 1
         and rownum = 1
      order by o2.numlevel,o2.numorg;

      cursor c2 is
      select o2.codcompp,o2.codcompr,o2.numlevel,o2.numorg,
             '' as codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o2.codcompy,o2.codlinef,o2.dteeffec
        from thisorg o1, thisorg2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = b_index_codcompy
         and o1.codlinef    = b_index_codlinef
         and o1.dteeffec    = b_index_dteeffec
         and o2.codcompr is null
         and o2.numorg      = 1
         and o2.numlevel - trunc(o2.numlevel) > 0
      order by o2.numlevel,o2.numorg;

  begin
    for i in c1 loop
      obj_data    := json_object_t();
      i.codimage  := get_emp_img(i.codresp);
      obj_data.put('coderror','200');
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('codlinef',i.codlinef);
      obj_data.put('desc_codlinef','');
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcompp);
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if i.numlevel = trunc(i.numlevel) then
        v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' : '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;
      obj_data.put('desc_codcomp',v_desc_codcompp);
      obj_data.put('codcompr',i.codcompr);
      obj_data.put('desc_codcompr',get_tcenter_name(i.codcompr,global_v_lang));
      obj_data.put('complvl',i.numlevel);
      obj_data.put('numorg',i.numorg);
      obj_data.put('codpospr',i.codpospr);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpospr,global_v_lang));
      obj_data.put('codempid',i.codresp);
      obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));
      obj_data.put('image',i.codimage);
      obj_data.put('image_path',i.codimage);
      begin
        select qtybgman
          into v_qtybgman
          from tmanpwm
         where dteyrbug     = to_number(to_char(i.dteeffec,'yyyy'))
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(i.dteeffec,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_data.put('qtybgman',nvl(v_qtybgman,0));
      obj_data.put('qtyexman',nvl(i.qtyexman,0));
      if nvl(i.codcompp,'@$%#') <> nvl(i.codcompr,'@$%#') then
        obj_data.put('children',gen_children(i.codcompp));
      end if;

      exit;
    end loop;
    obj_row := json_object_t();
    for r2 in c2 loop
      obj_assist    := json_object_t();
      r2.codimage  := get_emp_img(r2.codresp);
      obj_assist.put('coderror','200');
      obj_assist.put('codcompy',r2.codcompy);
      obj_assist.put('codlinef',r2.codlinef);
      obj_assist.put('desc_codlinef','');
      obj_assist.put('dteeffec',to_char(r2.dteeffec,'dd/mm/yyyy'));
      obj_assist.put('codcomp',r2.codcompp);
      v_comp_split  := get_comp_split(r2.codcompp,r2.numlevel);
      if r2.numlevel = trunc(r2.numlevel) then
        v_desc_codcompp   := get_tcenter_name(r2.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(r2.codcompp),r2.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' : '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;
      obj_assist.put('desc_codcomp',v_desc_codcompp);
      obj_assist.put('codcompr',r2.codcompr);
      obj_assist.put('desc_codcompr',get_tcenter_name(r2.codcompr,global_v_lang));
      obj_assist.put('complvl',r2.numlevel);
      obj_assist.put('numorg',r2.numorg);
      obj_assist.put('codpospr',r2.codpospr);
      obj_assist.put('desc_codpos',get_tpostn_name(r2.codpospr,global_v_lang));
      obj_assist.put('codempid',r2.codresp);
      obj_assist.put('desc_codempid',get_temploy_name(r2.codresp,global_v_lang));
      obj_assist.put('image',r2.codimage);
      obj_assist.put('image_path',r2.codimage);
      begin
        select qtybgman
          into v_qtybgman
          from tmanpwm
         where dteyrbug     = to_number(to_char(r2.dteeffec,'yyyy'))
           and codcomp      = r2.codcompp
           and codpos       = r2.codpospr
           and dtemthbug    = to_number(to_char(r2.dteeffec,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_assist.put('qtybgman',nvl(v_qtybgman,0));
      obj_assist.put('qtyexman',nvl(r2.qtyexman,0));
--      if nvl(i.codcompp,'@$%#') <> nvl(i.codcompr,'@$%#') then
--        obj_assist.put('children',gen_children(i.codcompp));
--      end if;
      obj_row.put(to_char(v_rcnt),obj_assist);
      v_rcnt      := v_rcnt + 1;
    end loop;
    obj_data.put('assists',obj_row);
    json_str_output   := obj_data.to_clob;
  end gen_chart;
end;

/

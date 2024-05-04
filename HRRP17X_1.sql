--------------------------------------------------------
--  DDL for Package Body HRRP17X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP17X" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_comgrp      := hcm_util.get_string_t(json_obj,'p_comgrp');
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codlinef    := hcm_util.get_string_t(json_obj,'p_codlinef');
    b_index_dteeffec    := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    b_index_dteeffec2   := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec2'),'dd/mm/yyyy');
    b_index_codcompst   := hcm_util.get_string_t(json_obj,'p_codcompst');
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_comlevel');
    b_index_flgemp      := hcm_util.get_string_t(json_obj,'p_flgemp');
    b_index_flgrate     := hcm_util.get_string_t(json_obj,'p_flgrate');
    b_index_flgjob      := hcm_util.get_string_t(json_obj,'p_flgjob');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  function get_codlinef_name(para_codcompy   torgprt.codcompy%type,
                             para_dteeffec   date,
                             para_codlinef   torgprt.codlinef%type,
                             para_lang       varchar2) return varchar2 is
    v_desc_codlinef     torgprt.deslinefe%type;
  begin
    begin
      select decode(para_lang,'101',deslinefe
                             ,'102',deslineft
                             ,'103',deslinef3
                             ,'104',deslinef4
                             ,'105',deslinef5)
        into v_desc_codlinef
        from torgprt
       where codcompy   = para_codcompy
         and dteeffec   = para_dteeffec
         and codlinef   = para_codlinef;
    exception when no_data_found then
      v_desc_codlinef := '';
    end;
    return v_desc_codlinef;
  end;
  --
  procedure check_index is
    v_error         varchar2(4000);
    v_max_comlevel  number  := 0;
    v_max_dteeffec  date;
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

    if b_index_codcompst is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompst);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;

      --<<
      if b_index_dteeffec2 is not null then
        begin
          select max(o1.dteeffec)
            into v_max_dteeffec
            from torgprt o1, torgprt2 o2
           where o1.codcompy    = o2.codcompy
             and o1.dteeffec    = o2.dteeffec
             and o1.codlinef    = o2.codlinef
             and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
             and o1.codlinef    = b_index_codlinef
             and o1.dteeffec2   = b_index_dteeffec2
             and (b_index_comgrp is null or (b_index_comgrp is not null and o1.flggroup = 'Y'))
             and o1.dteeffec    <= trunc(sysdate);
        exception when others then
          null;
        end;
      end if;
      -->>
      begin
        select nvl(max(numlevel),0)
          into v_max_comlevel
          from torgprt o1, torgprt2 o2
         where o1.codcompy    = o2.codcompy
           and o1.dteeffec    = o2.dteeffec
           and o1.codlinef    = o2.codlinef
           and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
           and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
             or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
                and o1.dteeffec = v_max_dteeffec
                )
               )
       ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
           and o1.codlinef    = b_index_codlinef
           and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'));
      end;

      if v_max_comlevel = 0 then
        param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TORGPRT');
      elsif v_max_comlevel < b_index_comlevel then
        param_msg_error   := get_error_msg_php('RP0024',global_v_lang);
      end if;
    end if;

  end;
  --
  function gen_children(p_codcompp  tcenter.codcomp%type,p_max_dteeffec date) return json_object_t is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_assi        json_object_t;
    v_rcnt          number := 0;
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    v_dte_index     date;
    v_qtybgman      number;

    v_rcnt_assi          number := 0;
    obj_assi_data        json_object_t;--<< 19/01/2022 #7477
    v_codcompp      torgprt2.codcompp%type; --<< 19/01/2022 #7477

    cursor c1 is
      select o1.codcompy,o1.codlinef,o2.codcompp,o2.codcompr,o2.numlevel,
             o2.numorg,o2.codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o1.dteeffec
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
         and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
           or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
               and o1.dteeffec = p_max_dteeffec
              )
             )
     ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
         and o1.codlinef    = b_index_codlinef
         and o2.numlevel    <= b_index_comlevel
         and o2.numlevel = trunc(o2.numlevel)--<< 19/01/2022 #7477
         and o2.codcompr    = p_codcompp
         and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'))
      order by o2.numlevel,o2.numorg;

    cursor c2 is
      select o1.codcompy,o1.codlinef,o2.codcompp,o2.codcompr,o2.numlevel,
             o2.numorg,o2.codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o1.dteeffec
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
         and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
           or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
               and o1.dteeffec = p_max_dteeffec
              )
             )
     ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
         and o1.codlinef    = b_index_codlinef
         and o2.numlevel    <= b_index_comlevel
         and o2.numlevel <> trunc(o2.numlevel)--<< 19/01/2022 #7477
       and   o2.codcompp = v_codcompp--<< 19/01/2022 #7477
        -- and o2.codcompr    = p_codcompp
         and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'))
      order by o2.numlevel,o2.numorg;  

  begin
    obj_row         := json_object_t();
    obj_assi        := json_object_t();
    v_dte_index     := nvl(b_index_dteeffec,b_index_dteeffec2);
    for i in c1 loop
      obj_data    := json_object_t();
--      obj_data.put('coderror','200');
      obj_data.put('orgid',trunc(DBMS_RANDOM.VALUE(1000000000000,9999999999999)));
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('codlinef',i.codlinef);
      obj_data.put('desc_codlinef',get_codlinef_name(i.codcompy,i.dteeffec,i.codlinef,global_v_lang));
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcompp);
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if i.numlevel = trunc(i.numlevel) then
        v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' - '||v_desc_codcompp;
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
         where dteyrbug     = to_number(to_char(v_dte_index,'yyyy'))
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(v_dte_index,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_data.put('qtybgman',v_qtybgman);
      obj_data.put('qtyexman',nvl(i.qtyexman,0));
      obj_data.put('children',gen_children(i.codcompp,p_max_dteeffec)); ----add p_max_dteeffec


--<< 19/01/2022 #7477
 v_codcompp := i.codcompp;
   obj_assi   := json_object_t();
   v_rcnt_assi :=0;
    for j in c2 loop
        obj_assi_data   := json_object_t();
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if j.numlevel = trunc(j.numlevel) then
        v_desc_codcompp   := get_tcenter_name(j.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(j.codcompp),j.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' - '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;

        obj_assi_data.put('codcompnyd', j.codcompy);
        obj_assi_data.put('codcompy', j.codcompy);
        obj_assi_data.put('codempid', j.codresp);
        obj_assi_data.put('codpos', j.codpospr);
        obj_assi_data.put('complvl', to_char(j.numlevel));
       obj_assi_data.put('desc_codcompnyd', get_tcompnyd_name(get_codcompy(j.codcompp),j.numlevel,v_comp_split,global_v_lang));
        obj_assi_data.put('desc_codempid', get_temploy_name(j.codresp,global_v_lang));
        obj_assi_data.put('desc_codpos', get_tpostn_name(j.codpospr,global_v_lang));
        obj_assi.put(to_char(v_rcnt_assi),obj_assi_data);
        v_rcnt_assi := v_rcnt_assi+1;
       end loop;
        obj_data.put('assists',obj_assi);
-->> 19/01/2022 #7477

--      obj_data.put('assists',obj_assi);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    return obj_row;
  end;
  --
  procedure gen_chart(json_str_output out clob) is
    obj_data        json_object_t;
--    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_rcnt_assi     number := 0;
    v_exist         boolean := false;
    obj_assi        json_object_t;--<< 19/01/2022 #7477
    obj_assi_data   json_object_t;--<< 19/01/2022 #7477
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    v_dte_index     date;
    v_qtybgman      number;
    v_codcomp_st    tcenter.codcomp%type;
    v_max_dteeffec  date;
    v_min_numlvl    number;
    v_comp_st       tcenter.codcomp%type;
    v_codcompp      torgprt2.codcompp%type; --<< 19/01/2022 #7477
    cursor c1 is
      select o1.codcompy,o1.codlinef,o2.codcompp,o2.codcompr,o2.numlevel,
             o2.numorg,o2.codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o1.dteeffec
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
         and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
           or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
               and o1.dteeffec = v_max_dteeffec
              )
             )
     ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
         and o1.codlinef    = b_index_codlinef
         and o2.numlevel    <= b_index_comlevel
--         and o2.codcompp    = v_codcomp_st
         and o2.codcompp    like v_codcomp_st || '%'
          and o2.numlevel = trunc(o2.numlevel)--<< 19/01/2022 #7477
         and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'))
      order by o2.numlevel,o2.numorg;


 cursor c2  is
      select o1.codcompy,o1.codlinef,o2.codcompp,o2.codcompr,o2.numlevel,
             o2.numorg,o2.codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o1.dteeffec
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
         and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
           or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
               and o1.dteeffec = v_max_dteeffec
              )
             )
     ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
         and o1.codlinef    = b_index_codlinef
         and o2.numlevel    <= b_index_comlevel
--         and o2.codcompp    = v_codcomp_st
         and o2.codcompp    like v_codcomp_st || '%'
          and o2.numlevel <> trunc(o2.numlevel)--<< 19/01/2022 #7477 1.1 1.2 2.1
          and   o2.codcompp = v_codcompp--<< 19/01/2022 #7477
         and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'))
      order by o2.numlevel,o2.numorg;

  begin

--    obj_row         := json_object_t();
    v_dte_index     := nvl(b_index_dteeffec,b_index_dteeffec2);
    if b_index_codcompst is null then
      begin
        select dteeffec,numlevel,codcompp
          into v_max_dteeffec,v_min_numlvl,v_comp_st
          from (select o1.dteeffec,o2.numlevel,o2.codcompp
                  from torgprt o1, torgprt2 o2
                 where o1.codcompy    = o2.codcompy
                   and o1.dteeffec    = o2.dteeffec
                   and o1.codlinef    = o2.codlinef
                   and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
                   and o1.codlinef    = b_index_codlinef
                   and (b_index_comgrp is null or (b_index_comgrp is not null and o1.flggroup = 'Y'))
                   and o1.dteeffec       <= trunc(sysdate)
                order by dteeffec desc,numlevel,codcompp)
         where rownum   = 1;
      exception when others then
        null;
      end;
      b_index_codcompst := v_comp_st;
      b_index_dteeffec  := v_max_dteeffec;
    end if;
    --<<
    if b_index_dteeffec2 is not null then
      begin
        select max(o1.dteeffec)
          into v_max_dteeffec
          from torgprt o1, torgprt2 o2
         where o1.codcompy    = o2.codcompy
           and o1.dteeffec    = o2.dteeffec
           and o1.codlinef    = o2.codlinef
           and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
           and o1.codlinef    = b_index_codlinef
           and o1.dteeffec2   = b_index_dteeffec2
           and (b_index_comgrp is null or (b_index_comgrp is not null and o1.flggroup = 'Y'))
           and o1.dteeffec    <= trunc(sysdate);
      exception when others then
        null;
      end;
    end if;
    -->>
    begin
      select nvl(codcompr,b_index_codcompst)
        into v_codcomp_st
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = nvl(b_index_comgrp,b_index_codcompy)
         and ((o1.dteeffec   = b_index_dteeffec and b_index_dteeffec is not null)
           or (o1.dteeffec2  = b_index_dteeffec2 and b_index_dteeffec2 is not null
               and o1.dteeffec = v_max_dteeffec
              )
             )
     ----and (o1.dteeffec   = b_index_dteeffec or o1.dteeffec2  = b_index_dteeffec2)
         and o1.codlinef    = b_index_codlinef
--         and o2.numlevel    <= b_index_comlevel
         and o2.codcompp    = nvl(b_index_codcompst,o2.codcompp)
         and (b_index_comgrp is null or (b_index_comgrp is not null and flggroup = 'Y'))
         and rownum         = 1;
    exception when no_data_found then
      v_codcomp_st    := b_index_codcompst;
    end;

    for i in c1 loop
      v_exist     := true;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('orgid',trunc(DBMS_RANDOM.VALUE(1000000000000,9999999999999)));
      obj_data.put('codcompy',i.codcompy);
      obj_data.put('codlinef',i.codlinef);
      obj_data.put('desc_codlinef',get_codlinef_name(i.codcompy,i.dteeffec,i.codlinef,global_v_lang));
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codcomp',i.codcompp);
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if i.numlevel = trunc(i.numlevel) then
        v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' - '||v_desc_codcompp;
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
         where dteyrbug     = to_number(to_char(v_dte_index,'yyyy'))
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(v_dte_index,'mm'));
      exception when no_data_found then
        v_qtybgman   := 0;
      end;
      obj_data.put('qtybgman',nvl(v_qtybgman,0));
      obj_data.put('qtyexman',nvl(i.qtyexman,0));

     obj_data.put('children',gen_children(i.codcompp,v_max_dteeffec)); ----add v_max_dteeffec
--<< 19/01/2022 #7477
   v_codcompp := i.codcompp;
   obj_assi   := json_object_t();
   v_rcnt_assi :=0;
    for j in c2 loop
        obj_assi_data   := json_object_t();
      v_comp_split  := get_comp_split(i.codcompp,i.numlevel);
      if j.numlevel = trunc(j.numlevel) then
        v_desc_codcompp   := get_tcenter_name(j.codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(j.codcompp),j.numlevel,v_comp_split,global_v_lang);
        end if;
        v_desc_codcompp := v_comp_split||' - '||v_desc_codcompp;
      else
        v_desc_codcompp := 'Assistant';-- Label
      end if;

        obj_assi_data.put('codcompnyd', j.codcompy);
        obj_assi_data.put('codcompy', j.codcompy);
        obj_assi_data.put('codempid', j.codresp);
        obj_assi_data.put('codpos', j.codpospr);
        obj_assi_data.put('complvl', to_char(j.numlevel));
       obj_assi_data.put('desc_codcompnyd', get_tcompnyd_name(get_codcompy(j.codcompp),j.numlevel,v_comp_split,global_v_lang));
     --   obj_assi_data.put('desc_codcompnyd', 'test');
        obj_assi_data.put('desc_codempid', get_temploy_name(j.codresp,global_v_lang));
        obj_assi_data.put('desc_codpos', get_tpostn_name(j.codpospr,global_v_lang));
        obj_assi.put(to_char(v_rcnt_assi),obj_assi_data);
        v_rcnt_assi := v_rcnt_assi+1;
       end loop;
        obj_data.put('assists',obj_assi);
-->> 19/01/2022 #7477

--      obj_row.put(to_char(v_rcnt),obj_data);
--      v_rcnt      := v_rcnt + 1;
    end loop;
    if not v_exist then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TORGPRT');
      return;
    end if;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_chart(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_chart(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_qty_emp_detail(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    v_dteeffec      date;
    cursor c1 is
      select  staappr,codappr,dteappr
      from    torgprt
      where   codcompy  = b_index_codcompy
      and     codlinef  = b_index_codlinef
      and     dteeffec  = v_dteeffec;
  begin
    json_input  := json_object_t(json_str_input);
    v_dteeffec  := to_date(hcm_util.get_string_t(json_input,'p_dteeffec3'),'dd/mm/yyyy');
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('staappr',get_tlistval_name('STAAPPR',i.staappr,global_v_lang));
      obj_data.put('desc_codappr',i.codappr||' - '||get_temploy_name(i.codappr,global_v_lang));
--     obj_data.put('dteappr',nvl(to_char(i.dteappr,'dd/mm/yyyy'),' - '));
    obj_data.put('dteappr',hcm_util.get_date_buddhist_era(i.dteappr));
   --  obj_data.put('dteappr',nvl(to_char(hcm_util.get_date_buddhist_era(i.dteappr),'dd/mm/yyyy'),' - '));
    end loop;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_qty_emp_detail(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qty_emp_detail(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_qty_emp_table(json_str_input in clob,json_str_output out clob) is
    json_input      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_dteeffec      date;
    v_rcnt          number := 0;
    v_desc_codcompp tcenter.namcente%type;
    v_comp_split    tcenter.codcomp%type;
    v_dte_index     date;
    v_qtybgman      number;
    v_sum_qtyexman  number := 0;
    v_sum_qtybgman  number := 0;
    cursor c1 is
      select  codcompp,codpospr,codresp,codcompr,
              numlevel,numorg,qtyexman
      from (
        select  codcompp,codpospr,codresp,codcompr,
                numlevel,numorg,qtyexman
        from    torgprt2
        where   codcompy  = b_index_codcompy
        and     codlinef  = b_index_codlinef
        and     dteeffec  = v_dteeffec
      ) t1
      start with codcompp = nvl(b_index_codcompst,codcompp)
      connect by prior codcompp = codcompr
      order by numlevel,numorg;
  begin
    obj_row     := json_object_t();
    json_input  := json_object_t(json_str_input);
    v_dte_index := nvl(b_index_dteeffec,b_index_dteeffec2);
    v_dteeffec  := to_date(hcm_util.get_string_t(json_input,'p_dteeffec3'),'dd/mm/yyyy');
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('comlevel',i.numlevel);
      obj_data.put('codcompp',i.codcompp);
      v_desc_codcompp   := get_tcenter_name(i.codcompp,global_v_lang);
      if v_desc_codcompp = '***************' then
        v_comp_split    := get_comp_split(i.codcompp,i.numlevel);
        v_desc_codcompp := get_tcompnyd_name(get_codcompy(i.codcompp),i.numlevel,v_comp_split,global_v_lang);
      end if;
      v_desc_codcompp   := replace(replace(v_desc_codcompp,'/',' '),'&',' ');
      obj_data.put('desc_codcompp',v_desc_codcompp);
      obj_data.put('codpospr',i.codpospr);
      obj_data.put('desc_codpospr',get_tpostn_name(i.codpospr,global_v_lang));
      obj_data.put('codresp',i.codresp);
      obj_data.put('desc_codresp',get_temploy_name(i.codresp,global_v_lang));
      begin
        select qtybgman
          into v_qtybgman
          from tmanpwm
         where dteyrbug     = to_char(v_dte_index,'yyyy')
           and codcomp      = i.codcompp
           and codpos       = i.codpospr
           and dtemthbug    = to_number(to_char(v_dte_index,'mm'));
      exception when no_data_found then
        v_qtybgman    := '0';
      end;
      obj_data.put('qtybgman',to_char(v_qtybgman));
      obj_data.put('qtyexman',to_char(nvl(i.qtyexman,0)));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt          := v_rcnt + 1;
      v_sum_qtyexman  := v_sum_qtyexman + nvl(i.qtyexman,0);
      v_sum_qtybgman  := v_sum_qtybgman + nvl(v_qtybgman,0);
    end loop;
    obj_data    := json_object_t();
    obj_data.put('desc_codresp',get_label_name('HRRP17X3',global_v_lang,150));
    obj_data.put('qtybgman',to_char(v_sum_qtybgman));
    obj_data.put('qtyexman',to_char(v_sum_qtyexman));
    obj_row.put(to_char(v_rcnt),obj_data);

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_qty_emp_table(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_qty_emp_table(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_list_emp(json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t := json_object_t(json_str_input);
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

    v_dte_index     date;
    v_codcompp      tcenter.codcomp%type;
    v_comp_split    tcenter.codcomp%type;
    v_desc_codcompp tcenter.naminite%type;
    v_level_row     number;
    v_comlevel      number;
    v_staappr       torgprt.staappr%type;

    v_compp_row     tcenter.codcomp%type;
    v_pospr_row     tpostn.codpos%type;
    v_resp_row      torgprt2.codresp%type;
    v_codjob        tjobcode.codjob%type;

    cursor c_org_2 is
      select  codcompp,codpospr,codresp,codcompr,
              numlevel,numorg,qtyexman
      from (
        select  codcompp,codpospr,codresp,codcompr,
                numlevel,numorg,qtyexman
        from    torgprt2
        where   codcompy  = b_index_codcompy
        and     codlinef  = b_index_codlinef
        and     dteeffec  = b_index_dteeffec
        and     nvl(qtyexman,0) > 0
      ) t1
      start with codcompp = nvl(b_index_codcompst,codcompp)
      connect by prior codcompp = codcompr
      order by numlevel,numorg;

    cursor c_list_emp is
      select codempid,codpos
        from thisorg3
       where codcompy   = b_index_codcompy
         and codlinef   = b_index_codlinef
         and dteeffec   = b_index_dteeffec
         and numlevel   = v_comlevel
         and codcompp   = v_codcompp
         and v_staappr  = 'Y'
      union
      select codempid,codpos
        from temploy1
       where codcomp    = v_codcompp
         and staemp     not in ('0','9')
         and v_staappr  <> 'Y'
      order by codempid;
  begin
    obj_row         := json_object_t();
    v_dte_index     := nvl(b_index_dteeffec,b_index_dteeffec2);

    v_compp_row     := hcm_util.get_string_t(json_input,'p_codcompp');
    v_pospr_row     := hcm_util.get_string_t(json_input,'p_codpospr');
    v_resp_row      := hcm_util.get_string_t(json_input,'p_codresp');
    begin
      select staappr
        into v_staappr
        from torgprt
       where codcompy   = b_index_codcompy
         and codlinef   = b_index_codlinef
         and dteeffec   = b_index_dteeffec;
    exception when no_data_found then
      v_staappr   := 'P';
    end;
    if v_compp_row is not null then
      v_codcompp  := v_compp_row;
      v_comlevel  := b_index_comlevel;
      for r_list_emp in c_list_emp loop
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('comlevel',b_index_comlevel);
        obj_data.put('codcompp',v_codcompp);
        v_desc_codcompp   := get_tcenter_name(v_codcompp,global_v_lang);
        if v_desc_codcompp = '***************' then
          v_comp_split    := get_comp_split(v_codcompp,b_index_comlevel);
          v_desc_codcompp := get_tcompnyd_name(get_codcompy(v_codcompp),b_index_comlevel,v_comp_split,global_v_lang);
        end if;
        obj_data.put('desc_codcompp',v_desc_codcompp);
        obj_data.put('codpospr',v_pospr_row);
        obj_data.put('desc_codpospr',get_tpostn_name(v_pospr_row,global_v_lang));
        obj_data.put('codresp',v_resp_row);
        obj_data.put('desc_codresp',get_temploy_name(v_resp_row,global_v_lang));
        obj_data.put('codempid',r_list_emp.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r_list_emp.codempid,global_v_lang));
        obj_data.put('codpos',r_list_emp.codpos);
        obj_data.put('desc_codpos',get_tpostn_name(r_list_emp.codpos,global_v_lang));

        begin
          select codjob
            into v_codjob
            from tjobpos
           where codcomp    = v_codcompp
             and codpos     = v_pospr_row;
        exception when no_data_found then
          v_codjob  := null;
        end;
        obj_data.put('codjob',v_codjob);
        if v_codjob is not null then
          obj_data.put('desc_codjob',get_tjobcode_name(v_codjob,global_v_lang));
        else
          obj_data.put('desc_codjob','');
        end if;

        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt    := v_rcnt + 1;
      end loop;
    else
      for r_org_2 in c_org_2 loop
        v_codcompp    := r_org_2.codcompp;
        v_comlevel    := r_org_2.numlevel;
        for r_list_emp in c_list_emp loop
          obj_data    := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('comlevel',r_org_2.numlevel);
          obj_data.put('codcompp',r_org_2.codcompp);
          v_desc_codcompp   := get_tcenter_name(r_org_2.codcompp,global_v_lang);
          if v_desc_codcompp = '***************' then
            v_comp_split    := get_comp_split(r_org_2.codcompp,r_org_2.numlevel);
            v_desc_codcompp := get_tcompnyd_name(get_codcompy(r_org_2.codcompp),r_org_2.numlevel,v_comp_split,global_v_lang);
          end if;
          obj_data.put('desc_codcompp',v_desc_codcompp);
          obj_data.put('codpospr',r_org_2.codpospr);
          obj_data.put('desc_codpospr',get_tpostn_name(r_org_2.codpospr,global_v_lang));
          obj_data.put('codresp',r_org_2.codresp);
          obj_data.put('desc_codresp',get_temploy_name(r_org_2.codresp,global_v_lang));
          obj_data.put('codempid',r_list_emp.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r_list_emp.codempid,global_v_lang));
          obj_data.put('codpos',r_list_emp.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r_list_emp.codpos,global_v_lang));

          begin
            select codjob
              into v_codjob
              from tjobpos
             where codcomp    = r_org_2.codcompp
               and codpos     = r_org_2.codpospr;
          exception when no_data_found then
            v_codjob  := null;
          end;
          obj_data.put('codjob',v_codjob);
          if v_codjob is not null then
            obj_data.put('desc_codjob',get_tjobcode_name(v_codjob,global_v_lang));
          else
            obj_data.put('desc_codjob','');
          end if;

          obj_row.put(to_char(v_rcnt),obj_data);
          v_rcnt    := v_rcnt + 1;
        end loop;
      end loop;
    end if;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_list_emp(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_emp(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

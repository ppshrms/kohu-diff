--------------------------------------------------------
--  DDL for Package Body HRRP62U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP62U" as
  procedure initial_value(json_str in clob) is
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_compgrp           := hcm_util.get_string_t(json_obj,'p_compgrp');
    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codlinef          := hcm_util.get_string_t(json_obj,'p_codlinef');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

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
      null;
    end;
    return v_desc_codlinef;
  end;
  --
  procedure check_index is
    v_error   varchar2(4000 char);
  begin
    -- p_compgrp check in frontend
    -- p_codlinef check in frontend
    if p_codcompy is not null then
      v_error   := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if v_error is not null then
        param_msg_error   := v_error;
        return;
      end if;
    end if;
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_chk_flow      boolean := false;
    v_chk_data      varchar2(1) := 'N';
    v_chk_secur     varchar2(1) := 'N';
    v_check         varchar2(50);
    v_approvno      torgprt.approvno%type;
    cursor c1 is
      select codcompy,codlinef,
             dteeffec,staappr,
             get_tlistval_name('STAAPPR',staappr,global_v_lang) as desc_staappr,
             approvno,codemprq,flggroup
        from torgprt
       where codcompy   = nvl(p_compgrp,p_codcompy)
         and codlinef   = nvl(p_codlinef,codlinef)
         and staappr    in ('P','A')
         and ((p_compgrp is not null and nvl(flggroup,'N') = 'Y') or
              (p_codcompy is not null and nvl(flggroup,'N') = 'N'))
      order by codcompy,dteeffec desc,codlinef;
  begin
    obj_row   := json_object_t();
    for i in c1 loop
      v_chk_data    := 'Y';
      v_approvno    := nvl(i.approvno,0) + 1;
      v_chk_flow    := chk_flowmail.check_approve('HRRP14E',i.codemprq,v_approvno,global_v_codempid,null,null,v_check);
      if v_chk_flow then
        v_chk_secur := 'Y';
        obj_data    := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('codcompy',i.codcompy);
        obj_data.put('codlinef',i.codlinef);
        obj_data.put('desc_codlinef',get_codlinef_name(nvl(p_compgrp,p_codcompy),i.dteeffec,i.codlinef,global_v_lang));
        obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
        obj_data.put('staappr',i.staappr);
        obj_data.put('status',i.desc_staappr);
        obj_data.put('flggroup',i.flggroup);
        obj_data.put('codemprq',i.codemprq);
        obj_data.put('desc_codemprq',get_temploy_name(i.codemprq,global_v_lang));
        obj_row.put(to_char(v_rcnt),obj_data);
        v_rcnt      := v_rcnt + 1;
      end if;
    end loop;
    if v_chk_data = 'N' then
      param_msg_error   := get_error_msg_php('HR2055',global_v_lang,'TORGPRT');
      return;
    elsif v_chk_secur = 'N' then
      param_msg_error   := get_error_msg_php('HR3008',global_v_lang);
      return;
    end if;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function gen_children(p_codcompp  tcenter.codcomp%type) return json_object_t is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_assi        json_object_t;
    v_rcnt          number := 0;
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    cursor c1 is
      select o1.codcompy,o1.codlinef,o2.codcompp,o2.codcompr,o2.numlevel,
             o2.numorg,o2.codimage,o2.codpospr,o2.codresp,o2.qtyexman,
             o1.dteeffec
        from torgprt o1, torgprt2 o2
       where o1.codcompy    = o2.codcompy
         and o1.dteeffec    = o2.dteeffec
         and o1.codlinef    = o2.codlinef
         and o1.codcompy    = p_codcompy
         and o1.dteeffec    = p_dteeffec
         and o1.codlinef    = p_codlinef
--         and o2.numlevel    <= b_index_comlevel
         and o2.codcompr    = p_codcompp
      order by o2.numlevel,o2.numorg;
  begin
    obj_row         := json_object_t();
    obj_assi        := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
--      obj_data.put('coderror','200');
--      obj_data.put('orgid',trunc(DBMS_RANDOM.VALUE(1000000000000,9999999999999)));
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
      obj_data.put('qtyexman',nvl(i.qtyexman,0));
      obj_data.put('children',gen_children(i.codcompp));
      obj_data.put('assists',obj_assi);
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    return obj_row;
  end;
  --
  procedure gen_chart(json_str_output out clob) is
    obj_data        json_object_t;
--    obj_row         json_object_t;
    obj_assi        json_object_t;
    v_rcnt          number := 0;
    v_desc_codcompp varchar2(500);
    v_comp_split    varchar2(20);
    cursor c1 is
      select codcompp,codcompr,numlevel,numorg,
             codimage,codpospr,codresp,qtyexman,
             codcompy,codlinef,dteeffec
        from torgprt2
       where codcompy   = p_codcompy
         and dteeffec   = p_dteeffec
         and codlinef   = p_codlinef
      order by numlevel,numorg;
  begin
--    obj_row   := json_object_t();
    obj_assi  := json_object_t();
    obj_data    := json_object_t();

    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
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
      obj_data.put('image',i.codimage);
      obj_data.put('image_path',i.codimage);
      obj_data.put('codpospr',i.codpospr);
      obj_data.put('desc_codpospr',get_tpostn_name(i.codpospr,global_v_lang));
      obj_data.put('codresp',i.codresp);
      obj_data.put('desc_codresp',get_temploy_name(i.codresp,global_v_lang));
      obj_data.put('qtyexman',i.qtyexman);
      obj_data.put('children',gen_children(i.codcompp));
      obj_data.put('assists',obj_assi);
--      obj_row.put(to_char(v_rcnt),obj_data);
--      v_rcnt      := v_rcnt + 1;
      exit;
    end loop;
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_chart(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_chart(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_emp(json_str_input in clob, json_str_output out clob) is
    param_json      json_object_t := json_object_t(json_str_input);
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codcomp       tcenter.codcomp%type;
    v_rcnt          number := 0;
    cursor c1 is
      select codempid,codpos
        from temploy1
       where codcomp    = v_codcomp
         and staemp     not in ('0','9')
      order by codempid;
  begin
    v_codcomp   := hcm_util.get_string_t(param_json,'p_codcomp');
    obj_row     := json_object_t();
    for i in c1 loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('codpos',i.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_emp(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_emp(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail_approve(json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t := json_object_t(json_str_input);
    param_json      json_object_t;
    param_json_row  json_object_t;

    obj_orgprt_row      json_object_t;
    obj_orgprt_data     json_object_t;
    obj_aporg_row       json_object_t;
    obj_aporg_data      json_object_t;
    v_rcnt_org          number := 0;
    v_rcnt_aporg        number := 0;
    v_approvno          number := 0;

    v_codcompy      torgprt.codcompy%type;
    v_dteeffec      date;
    v_codlinef      torgprt.codlinef%type;
    v_flggroup      torgprt.flggroup%type;
    v_flg_true      boolean := true;
    v_flg_false     boolean := false;
    v_codemprq      torgprt.codemprq%type;
    v_check         varchar2(50);
    cursor c_taporg is
      select approvno,staappr,codappr,dteappr,dteeffec2,remarkap
        from taporg
       where codcompy   = v_codcompy
         and dteeffec   = v_dteeffec
         and codlinef   = v_codlinef
      order by approvno;
  begin
    param_json      := hcm_util.get_json_t(json_input,'param_json');
    obj_orgprt_row  := json_object_t();
    for i in 0..(param_json.get_size - 1) loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codcompy        := hcm_util.get_string_t(param_json_row,'codcompy');
      v_dteeffec        := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_codlinef        := hcm_util.get_string_t(param_json_row,'codlinef');
      v_flggroup        := hcm_util.get_string_t(param_json_row,'flggroup');
      v_codemprq        := hcm_util.get_string_t(param_json_row,'codemprq');
      obj_orgprt_data   := json_object_t();

      obj_orgprt_data.put('coderror','200');
      obj_orgprt_data.put('codcompy',v_codcompy);
      if v_flggroup = 'Y' then
        obj_orgprt_data.put('desc_codcompy',get_tcodec_name('TCOMPGRP',v_codcompy,global_v_lang));
      else
        obj_orgprt_data.put('desc_codcompy',get_tcompny_name(v_codcompy,global_v_lang));
      end if;
      obj_orgprt_data.put('dteeffec',to_char(v_dteeffec,'dd/mm/yyyy'));
      obj_orgprt_data.put('codlinef',v_codlinef);
      obj_orgprt_data.put('desc_codlinef',get_codlinef_name(v_codcompy,v_dteeffec,v_codlinef,global_v_lang));

      obj_aporg_row     := json_object_t();
      v_rcnt_aporg      := 0;
      v_approvno        := 0;
      for r_taporg in c_taporg loop
        obj_aporg_data    := json_object_t();
        obj_aporg_data.put('approvno',r_taporg.approvno);
        obj_aporg_data.put('staappr',replace(r_taporg.staappr,'A','Y'));
        obj_aporg_data.put('codappr',r_taporg.codappr);
        obj_aporg_data.put('dteappr',to_char(r_taporg.dteappr,'dd/mm/yyyy'));
        obj_aporg_data.put('dteeffec2',to_char(r_taporg.dteeffec2,'dd/mm/yyyy'));
        obj_aporg_data.put('remarkap',r_taporg.remarkap);
        obj_aporg_data.put('flgdisabled',v_flg_true);
        obj_aporg_row.put(to_char(v_rcnt_aporg),obj_aporg_data);
        v_approvno      := r_taporg.approvno;
        v_rcnt_aporg    := v_rcnt_aporg + 1;
      end loop;
      v_approvno := v_approvno +1;
      if chk_flowmail.check_approve('HRRP14E',v_codemprq,v_approvno,global_v_codempid,null,null,v_check) then
          obj_aporg_data    := json_object_t();
          obj_aporg_data.put('approvno',to_char(v_approvno));
          obj_aporg_data.put('staappr','Y');
          obj_aporg_data.put('codappr',global_v_codempid);
          obj_aporg_data.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
          obj_aporg_data.put('dteeffec2',to_char(trunc(sysdate),'dd/mm/yyyy'));
          obj_aporg_data.put('remarkap','');
          obj_aporg_data.put('flgdisabled',v_flg_false);
          obj_aporg_row.put(to_char(v_rcnt_aporg),obj_aporg_data);
      end if;

      obj_orgprt_data.put('approveseq',obj_aporg_row);
      obj_orgprt_row.put(to_char(v_rcnt_org),obj_orgprt_data);
      v_rcnt_org    := v_rcnt_org + 1;
    end loop;
    json_str_output   := obj_orgprt_row.to_clob;
  end;
  --
  procedure get_detail_approve(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_approve(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure insert_taporg(t_taporg taporg%rowtype) is
  begin
    begin
      insert into taporg(codcompy,dteeffec,codlinef,approvno,dteappr,
                         codappr,dteeffec2,staappr,remarkap,flggroup,
                         codcreate,coduser)
      values (t_taporg.codcompy,t_taporg.dteeffec,t_taporg.codlinef,t_taporg.approvno,t_taporg.dteappr,
              t_taporg.codappr,t_taporg.dteeffec2,t_taporg.staappr,t_taporg.remarkap,t_taporg.flggroup,
              global_v_coduser,global_v_coduser);
    exception when dup_val_on_index then
      update taporg
         set dteappr      = t_taporg.dteappr,
             codappr      = t_taporg.codappr,
             dteeffec2    = t_taporg.dteeffec2,
             staappr      = t_taporg.staappr,
             remarkap     = t_taporg.remarkap,
             flggroup     = t_taporg.flggroup,
             dtecreate    = t_taporg.dtecreate,
             codcreate    = t_taporg.codcreate,
             dteupd       = t_taporg.dteupd,
             coduser      = t_taporg.coduser
       where codcompy     = t_taporg.codcompy
         and dteeffec     = t_taporg.dteeffec
         and codlinef     = t_taporg.codlinef
         and approvno     = t_taporg.approvno;
    end;
  end;
  --
  procedure update_torgprt(t_taporg taporg%rowtype) is
  begin
    update torgprt
       set codappr    = t_taporg.codappr,
           dteappr    = t_taporg.dteappr,
           approvno   = t_taporg.approvno,
           staappr    = t_taporg.staappr,
           dteeffec2  = t_taporg.dteeffec2,
           remarkap   = t_taporg.remarkap,
           coduser    = global_v_coduser
     where codcompy   = t_taporg.codcompy
       and dteeffec   = t_taporg.dteeffec
       and codlinef   = t_taporg.codlinef;
  end;
  --
  procedure insert_thisorg(para_codcompy   torgprt.codcompy%type,
                           para_dteeffec   torgprt.dteeffec%type,
                           para_codlinef   torgprt.codlinef%type) is
  begin
    update thisorg
       set staorg   = 'N',
           coduser  = global_v_coduser
     where codcompy = para_codcompy
       and codlinef = para_codlinef;
    begin
      insert into thisorg(codcompy,codlinef,dteeffec,dteappr,codappr,
                          remarkap,staorg,flggroup,codcreate,coduser,
                          deslinefe,deslineft,deslinef3,deslinef4,deslinef5)
      select codcompy,codlinef,dteeffec,dteappr,codappr,
             remarkap,'A',flggroup,global_v_coduser,global_v_coduser,
             deslinefe,deslineft,deslinef3,
             deslinef4,deslinef5
        from torgprt
       where codcompy   = para_codcompy
         and dteeffec   = para_dteeffec
         and codlinef   = para_codlinef;
    exception when dup_val_on_index then
      null;
    end;
  end;
  --
  procedure insert_thisorg2(para_codcompy   torgprt.codcompy%type,
                            para_dteeffec   torgprt.dteeffec%type,
                            para_codlinef   torgprt.codlinef%type,
                            para_codappr    torgprt.codappr%type,
                            para_dteappr    torgprt.dteappr%type,
                            para_remarkap   torgprt.remarkap%type) is
  begin
    begin
      insert into thisorg2(codcompy,codlinef,dteeffec,numlevel,codcompp,
                           codpospr,codcompr,codlinefpr,dteappr,codappr,
                           remarkap,codresp,qtyexman,numorg,codcreate,
                           coduser)
      select codcompy,codlinef,dteeffec,numlevel,codcompp,
             codpospr,codcompr,codlinefpr,para_dteappr,para_codappr,
             para_remarkap,codresp,qtyexman,numorg,global_v_coduser,
             global_v_coduser
        from torgprt2
       where codcompy   = para_codcompy
         and dteeffec   = para_dteeffec
         and codlinef   = para_codlinef
      order by codcompy,codlinef,dteeffec,numlevel,codcompp;
    exception when dup_val_on_index then
      null;
    end;
  end;
  --
  procedure insert_thisorg3(para_codcompy   torgprt.codcompy%type,
                            para_dteeffec   torgprt.dteeffec%type,
                            para_codlinef   torgprt.codlinef%type) is
  begin
    begin
      insert into thisorg3(codcompy,codlinef,dteeffec,numlevel,codcompp,
                           codempid,codpos,codcreate,coduser)
      select codcompy,codlinef,dteeffec,numlevel,codcompp,
             emp.codempid,emp.codpos,global_v_coduser,global_v_coduser
        from torgprt2 org2, temploy1 emp
       where org2.codcompy    = para_codcompy
         and org2.dteeffec    = para_dteeffec
         and org2.codlinef    = para_codlinef
         and emp.codcomp      = org2.codcompp
         and emp.staemp       in ('1','3')
      order by emp.codempid;
    exception when dup_val_on_index then
      null;
    end;
  end;

  procedure insert_tcenterlogCancel(para_codcompy   torgprt.codcompy%type,
                              para_dteeffec   torgprt.dteeffec%type,
                              para_codlinef   torgprt.codlinef%type,
                              para_codappr    torgprt.codappr%type,
                              para_dteappr    date) is

  cursor c1 is
    select codcompy,dteeffec,codlinef,codcompp
      from torgprt3
     where codcompy    = para_codcompy
       and dteeffec    = para_dteeffec
       and codlinef    = para_codlinef
     union
    select codcompy,dteeffec,codlinef,codcompo
      from torgprt2
     where codcompy    = para_codcompy
       and dteeffec    = para_dteeffec
       and codlinef    = para_codlinef
       and codcompo is not null;
  begin
    for r1 in c1 loop
        begin
          insert into tcenterlog(codcomp,dteeffec,namcente,namcentt,namcent3,
                                 namcent4,namcent5,codcom1,codcom2,codcom3,
                                 codcom4,codcom5,codcom6,codcom7,codcom8,
                                 codcom9,codcom10,codcompy,comlevel,flgact,
                                 compgrp,
                                 codappr,dteappr,
                                 flgcal,
                                 coduser,codcreate)
          select r1.codcompp,r1.dteeffec,ct.namcente,ct.namcentt,namcent3,
                 ct.namcent4,ct.namcent5,ct.codcom1,ct.codcom2,ct.codcom3,
                 ct.codcom4,ct.codcom5,ct.codcom6,ct.codcom7,ct.codcom8,
                 ct.codcom9,ct.codcom10,ct.codcompy,ct.comlevel,'2',
                 ct.compgrp, para_codappr,para_dteappr,
                 case when r1.dteeffec <= trunc(sysdate) then 'Y' else 'N' end,
                 global_v_coduser,global_v_coduser
            from tcenter ct
           where ct.codcomp = r1.codcompp;
        exception when dup_val_on_index then
          null;
        end;

        if r1.dteeffec <= trunc(sysdate) then
            update tcenter
               set flgact = '2'
             where codcomp = r1.codcompp;
        end if;
    end loop;
  end;

  procedure update_tcompgrp(para_codcompy   torgprt.codcompy%type,
                              para_dteeffec   torgprt.dteeffec%type,
                              para_codlinef   torgprt.codlinef%type) is

  cursor c1 is
    select codcompy,codpospr,codresp
      from torgprt2
     where codcompy    = para_codcompy
       and dteeffec    = para_dteeffec
       and codlinef    = para_codlinef
       and numlevel = 0;
  begin
    for r1 in c1 loop
        update tcompgrp
           set codpospr = r1.codpospr,
               codresp = r1.codresp
         where codcodec = r1.codcompy;
    end loop;
  end;

  procedure update_qtyexman(para_codcompy   torgprt.codcompy%type,
                              para_dteeffec   torgprt.dteeffec%type,
                              para_codlinef   torgprt.codlinef%type) is

  cursor c1 is
    select codcompy,dteeffec,codlinef,numlevel,codcompp
      from torgprt2
     where codcompy    = para_codcompy
       and dteeffec    = para_dteeffec
       and codlinef    = para_codlinef
       and flgnew ='Y'
       and numlevel <> 0;
  v_count_qtyexman  number := 0;
  begin
    for r1 in c1 loop
        begin
            select count(codempid)
              into v_count_qtyexman
              from temploy1
             where codcomp = r1.codcompp;
        exception when others then
            v_count_qtyexman := 0;
        end;

        update torgprt2
           set qtyexman = v_count_qtyexman
         where codcompy = r1.codcompy
           and dteeffec = r1.dteeffec
           and codlinef = r1.codlinef
           and numlevel = r1.numlevel
           and codcompp = r1.codcompp;
    end loop;
  end;

  procedure insert_tcenterlog(para_codcompy   torgprt.codcompy%type,
                              para_dteeffec   torgprt.dteeffec%type,
                              para_codlinef   torgprt.codlinef%type,
                              para_codappr    torgprt.codappr%type,
                              para_dteappr    date) is
  begin
    begin
      insert into tcenterlog(codcomp,dteeffec,namcente,namcentt,namcent3,
                             namcent4,namcent5,codcom1,codcom2,codcom3,
                             codcom4,codcom5,codcom6,codcom7,codcom8,
                             codcom9,codcom10,codcompy,comlevel,flgact,
                             compgrp,
                             codappr,dteappr,
                             flgcal,
                             coduser,codcreate)
      select op.codcompp,op.dteeffec,ct.namcompe,ct.namcompt,namcomp3,
             ct.namcomp4,ct.namcomp5,op.codcom1,op.codcom2,op.codcom3,
             op.codcom4,op.codcom5,op.codcom6,op.codcom7,op.codcom8,
             op.codcom9,op.codcom10,op.codcom1,op.numlevel,'1',
             case when og.flggroup = 'Y' then og.codcompy end,
             para_codappr,para_dteappr,
             case when op.dteeffec <= trunc(sysdate) then 'Y' else 'N' end,
             global_v_coduser,global_v_coduser
        from torgprt og, torgprt2 op, tcompnyd ct
       where og.codcompy    = para_codcompy
         and og.dteeffec    = para_dteeffec
         and og.codlinef    = para_codlinef
         and og.codcompy    = op.codcompy
         and og.dteeffec    = op.dteeffec
         and og.codlinef    = op.codlinef
         and op.codcompp    = ct.codcompy(+)
         and op.numlevel    = ct.comlevel(+)
         and op.numlevel    <> 0
         and get_comp_split(op.codcompp,op.numlevel) = ct.codcomp(+)
         and op.flgnew      = 'Y';
    exception when dup_val_on_index then
      null;
    end;
  end;
  --
  procedure insert_tcenter(para_codcompy   torgprt.codcompy%type,
                           para_dteeffec   torgprt.dteeffec%type,
                           para_codlinef   torgprt.codlinef%type,
                           para_codappr    torgprt.codappr%type,
                           para_dteappr    date) is
  begin
    begin
      insert into tcenter(codcomp,namcente,namcentt,namcent3,
                          namcent4,namcent5,codcom1,codcom2,codcom3,
                          codcom4,codcom5,codcom6,codcom7,codcom8,
                          codcom9,codcom10,codcompy,comlevel,flgact,
                          compgrp,
                          comparent,coduser,codcreate)
      select op.codcompp,ct.namcompe,ct.namcompt,namcomp3,
             ct.namcomp4,ct.namcomp5,op.codcom1,op.codcom2,op.codcom3,
             op.codcom4,op.codcom5,op.codcom6,op.codcom7,op.codcom8,
             op.codcom9,op.codcom10,op.codcom1,op.numlevel,'1',
             case when og.flggroup = 'Y' then og.codcompy end,
             op.codcompr,global_v_coduser,global_v_coduser
        from torgprt og, torgprt2 op, tcompnyd ct
       where og.codcompy    = para_codcompy
         and og.dteeffec    = para_dteeffec
         and og.codlinef    = para_codlinef
         and og.codcompy    = op.codcompy
         and og.dteeffec    = op.dteeffec
         and og.codlinef    = op.codlinef
         and op.codcompp    = ct.codcompy(+)
         and op.numlevel    = ct.comlevel(+)
         and op.numlevel    <> 0
         and get_comp_split(op.codcompp,op.numlevel) = ct.codcomp(+)
         and op.flgnew      = 'Y'
         and og.dteeffec <= trunc(sysdate);
    exception when dup_val_on_index then
      null;
    end;
  end;
  --
  procedure send_mail_to_approve(v_codempid   temploy1.codempid%type) is
    v_codapp        varchar2(100) := 'HRRP14E';
    v_o_msg_to      clob;
    v_template_to   clob;
    v_func_appr     clob;
    v_codform       tfwmailh.codform%type;
    v_rowid         varchar2(1000);
    v_error         varchar2(100);

    v_item          varchar2(500) := 'item1,item2,item3,item4,item5';
    v_label         varchar2(500) := 'label1,label2,label3,label4,label5';
    v_file_name     varchar2(500) := 'HRRP62U';
    v_subject       varchar2(1000);
    v_maillang      varchar2(100);
    v_msg_to        clob;
    v_templete_to   clob;
  begin
    v_maillang  := chk_flowmail.get_emp_mail_lang(v_codempid);
    v_subject   := get_label_name('HRRP62U3', v_maillang, 900);
    v_file_name := global_v_codempid||'_'||to_char(sysdate,'yyyymmddhh24miss');
    excel_mail(v_item,v_label,null,global_v_codempid,'HRRP62U',v_file_name);

    begin
        select codform
          into v_codform
          from tfwmailh
         where codapp = 'HRRP14E';
    exception when others then
        v_codform := null;
    end;

    if v_codform is not null then
        chk_flowmail.get_message_result(v_codform, v_maillang, v_msg_to, v_templete_to);
        chk_flowmail.replace_text_frmmail(v_templete_to, null, null, v_subject, v_codform, '1', null, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N',p_file => v_file_name);
        v_error := chk_flowmail.send_mail_to_emp (v_codempid,global_v_codempid, v_msg_to,
                                                  null, v_subject, 'U', v_maillang,
                                                  v_file_name, null, null, 'Oracle', null, 'HRRP62U', v_codempid);
    else
        param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
    end if;

    IF v_error in ('2046','2402') THEN
      param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
    ELSE
      param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
    end if;
  end;
  --
  procedure process_approve(json_str_input in clob,json_str_output out clob) is
    json_input            json_object_t;
    param_json            json_object_t;
    param_json_row        json_object_t;
    param_aporg           json_object_t;
    param_aporg_row       json_object_t;

    v_codcompy            torgprt.codcompy%type;
    v_dteeffec            date;
    v_codlinef            torgprt.codlinef%type;
    v_flggroup            torgprt.flggroup%type;
    v_approvno            torgprt.approvno%type;
    v_codemprq            torgprt.codemprq%type;
    v_codappr             torgprt.codappr%type;
    v_dteappr             torgprt.dteappr%type;
    v_dteeffec2           taporg.dteeffec2%type;
    v_staappr             torgprt.staappr%type;
    v_remarkap            torgprt.remarkap%type;

    t_torgprt             torgprt%rowtype;
    t_taporg              taporg%rowtype;

    v_chk_flow            boolean := false;
    v_check_last          varchar2(1);
    v_desc_codcompy       varchar2(500);
    v_desc_codlinef       varchar2(500);
    v_error_cc            varchar2(500);
    v_rowid               varchar2(1000);
    v_numseq_receiver       number := 0;
    v_numseq       number := 0;
    v_codempid                 ttemprpt.item1%type;
    cursor c1 is
        select distinct item1 codempid
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP62UR';

    cursor c2 is
        select item1 codempid, item2 codcompy, item3 codlinef, to_date(item4,'dd/mm/yyyy') dteeffec,
               item5 desc_codcompy, item6 desc_codlinef
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP62UR'
           and item1 = v_codempid;
  begin
    json_input          := json_object_t(json_str_input);
    param_json          := hcm_util.get_json_t(json_input,'param_json');
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP62U';
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP62UR';
    delete from ttempprm where codempid = global_v_codempid and codapp = 'HRRP62U';
    -- insert temp for gen excel --
    insert into ttempprm (codempid,codapp,namrep,pdate,ppage,
                          label1,label2,label3,label4,label5)
    values(global_v_codempid,'HRRP62U','HRRP62U',to_char(sysdate,'dd/mm/yyyy'),'page1',
           get_label_name('HRRP62U3',global_v_lang,910),
           get_label_name('HRRP62U3',global_v_lang,920),
           get_label_name('HRRP62U3',global_v_lang,930),
           get_label_name('HRRP62U3',global_v_lang,940),
           get_label_name('HRRP62U3',global_v_lang,950));
    --
    for i in 0..(param_json.get_size - 1) loop
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codcompy        := hcm_util.get_string_t(param_json_row,'codcompy');
      v_desc_codcompy   := hcm_util.get_string_t(param_json_row,'desc_codcompy');
      v_dteeffec        := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_codlinef        := hcm_util.get_string_t(param_json_row,'codlinef');
      v_desc_codlinef   := hcm_util.get_string_t(param_json_row,'desc_codlinef');
--      v_flggroup        := hcm_util.get_string_t(param_json_row,'flggroup');
      -----
      begin
        select *
          into t_torgprt
          from torgprt
         where codcompy   = v_codcompy
           and dteeffec   = v_dteeffec
           and codlinef   = v_codlinef;
      exception when no_data_found then
        t_torgprt := null;
      end;

      ------------------
      param_aporg       := hcm_util.get_json_t(param_json_row,'detail');
      param_aporg_row   := hcm_util.get_json_t(param_aporg,to_char(param_aporg.get_size - 1));
      v_approvno        := hcm_util.get_string_t(param_aporg_row,'approvno');
      v_codappr         := hcm_util.get_string_t(param_aporg_row,'codappr');
      v_dteappr         := to_date(hcm_util.get_string_t(param_aporg_row,'dteappr'),'dd/mm/yyyy');
      v_dteeffec2       := to_date(hcm_util.get_string_t(param_aporg_row,'dteeffec2'),'dd/mm/yyyy');
      v_staappr         := hcm_util.get_string_t(param_aporg_row,'staappr');
      v_remarkap        := hcm_util.get_string_t(param_aporg_row,'remarkap');

      v_chk_flow          := chk_flowmail.check_approve('HRRP14E',t_torgprt.codemprq,v_approvno,global_v_codempid,null,null,v_check_last);
      t_taporg.codcompy   := v_codcompy;
      t_taporg.dteeffec   := v_dteeffec;
      t_taporg.codlinef   := v_codlinef;
      t_taporg.approvno   := v_approvno;
      t_taporg.dteappr    := v_dteappr;
      t_taporg.codappr    := v_codappr;
      t_taporg.dteeffec2  := v_dteeffec2;
      t_taporg.remarkap   := v_remarkap;

      begin
          select rowid
            into v_rowid
            from torgprt
           where codcompy   = v_codcompy
             and dteeffec   = v_dteeffec
             and codlinef   = v_codlinef;
      exception when no_data_found then
        v_rowid := null;
      end;

      if v_staappr = 'Y' then
        if v_check_last = 'Y' then
          t_taporg.staappr := 'Y';
          insert_thisorg(v_codcompy,v_dteeffec,v_codlinef);
          insert_thisorg2(v_codcompy,v_dteeffec,v_codlinef,v_codappr,v_dteappr,v_remarkap);
          insert_thisorg3(v_codcompy,v_dteeffec,v_codlinef);
          insert_tcenterlogCancel(v_codcompy,v_dteeffec,v_codlinef,v_codappr,v_dteappr);
          update_tcompgrp(v_codcompy,v_dteeffec,v_codlinef);
          update_qtyexman(v_codcompy,v_dteeffec,v_codlinef);
          insert_tcenterlog(v_codcompy,v_dteeffec,v_codlinef,v_codappr,v_dteappr);
          insert_tcenter(v_codcompy,v_dteeffec,v_codlinef,v_codappr,v_dteappr);
        else
          t_taporg.staappr := 'A';
          chk_flowmail.get_receiver ('HRRP14E', t_torgprt.codemprq, 'U', t_taporg.approvno + 1, null, null, a_receiver, v_qty_receiver);
          for i in 1..v_qty_receiver loop
              v_numseq_receiver := v_numseq_receiver + 1;
              insert into ttemprpt (codempid,codapp,numseq,
                                    item1,item2,item3,item4,item5,item6)
              values(global_v_codempid,'HRRP62UR',v_numseq_receiver,
                     a_receiver(i), v_codcompy, v_codlinef, to_char(v_dteeffec,'dd/mm/yyyy'),
                     v_desc_codcompy,v_desc_codlinef);
          end loop;
        end if;

        begin
          v_error_cc := chk_flowmail.send_mail_reply('HRRP62U', t_torgprt.codemprq, t_torgprt.codemprq , global_v_codempid, global_v_coduser, null, 'HRRP62U3', 50, 'U', t_taporg.staappr, t_taporg.approvno, null, null, 'TORGPRT', v_rowid, '1', null);
        EXCEPTION WHEN OTHERS THEN
          null;
        END;
      elsif v_staappr = 'N' then
        t_taporg.staappr := 'N';

        begin
            v_error_cc := chk_flowmail.send_mail_reply('HRRP62U', t_torgprt.codemprq, t_torgprt.codemprq , global_v_codempid, global_v_coduser, null, 'HRRP62U3', 50, 'U', t_taporg.staappr, t_taporg.approvno, null, null, 'TORGPRT', v_rowid, '1', null);
        EXCEPTION WHEN OTHERS THEN
            null;
        END;

        IF v_error_cc in ('2046','2402') THEN
          param_msg_error_mail := get_error_msg_php('HR2402', global_v_lang);
        ELSE
          param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
        end if;        

        delete from torgprt
         where codcompy   = v_codcompy
           and dteeffec   = v_dteeffec
           and codlinef   = v_codlinef;

        delete from torgprt2
         where codcompy   = v_codcompy
           and dteeffec   = v_dteeffec
           and codlinef   = v_codlinef;

        delete from torgprt3
         where codcompy   = v_codcompy
           and dteeffec   = v_dteeffec
           and codlinef   = v_codlinef;
      end if;

--      t_taporg.flggroup   := v_flggroup;
      if v_dteeffec2 < trunc(sysdate) then
        param_msg_error   := get_error_msg_php('HR8519',global_v_lang);
        exit;
      end if;
      update_torgprt(t_taporg);
      insert_taporg(t_taporg);
    end loop;

    for r1 in c1 loop
        v_codempid  := r1.codempid;
        v_numseq    := 0;
        delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP62U';
        for r2 in c2 loop
            v_codcompy          := r2.codcompy;
            v_desc_codcompy     := r2.desc_codcompy;
            v_codlinef          := r2.codlinef;
            v_desc_codlinef     := r2.desc_codlinef;
            v_dteeffec          := r2.dteeffec;
            v_numseq            := v_numseq + 1;
            insert into ttemprpt (codempid,codapp,numseq,
                                  item1,item2,item3,item4,item5)
            values(global_v_codempid,'HRRP62U',v_numseq,
                   v_codcompy,v_desc_codcompy,v_codlinef,v_desc_codlinef,
                   hcm_util.get_date_buddhist_era(v_dteeffec));
        end loop;
        send_mail_to_approve(v_codempid);
    end loop;
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP62U';
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRP62UR';
    delete from ttempprm where codempid = global_v_codempid and codapp = 'HRRP62U';

    if param_msg_error_mail is not null then
      commit;
      json_str_output   := get_response_message(201,param_msg_error_mail,global_v_lang);
      return;
    elsif param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure approve(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      process_approve(json_str_input,json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

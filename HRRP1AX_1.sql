--------------------------------------------------------
--  DDL for Package Body HRRP1AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP1AX" is
-- last update: 15/09/2020 14:00

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
    b_index_codlinef    := hcm_util.get_string_t(json_obj,'p_codlinef');

    --block drilldown
    b_index_dteeffec    := hcm_util.get_string_t(json_obj,'p_dteeffec');
    b_index_numlevel    := hcm_util.get_string_t(json_obj,'p_numlevel');
    b_index_codcompp    := hcm_util.get_string_t(json_obj,'p_codcompp');

    b_index_codpos    := hcm_util.get_string_t(json_obj,'p_codpos');--User37 #7481 1. RP Module 16/01/2022 

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
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
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_filepath      varchar2(100 char);
    v_month         varchar2(2 char);
    v_codcomp       varchar2(400 char);
    v_codpos        varchar2(400 char);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);

    v_codcompy      varchar2(400 char);
    v_codlinef      varchar2(400 char);
    v_dteeffec      date;
    v_codcompr      varchar2(400 char);

    v_qty           number;--User37 #7481 1. RP Module 16/01/2022 

    cursor c1 is
      select a.codcompy, a.codlinef, b.numlevel, b.codcompp , b.codpospr , b.codresp, b.dteeffec
        from thisorg a, thisorg2 b
       where ((a.codcompy = b_index_grpcompy and a.flggroup = 'Y') or (a.codcompy = b_index_codcompy and nvl(a.flggroup,'N') = 'N'))
         and a.codlinef = nvl(b_index_codlinef , a.codlinef)
         and a.dteeffec = (select max(dteeffec) from thisorg t1
                	       where ((t1.codcompy = b_index_grpcompy and flggroup = 'Y') or (t1.codcompy = b_index_codcompy and t1.flggroup = 'N'))
                             and t1.codlinef = nvl(b_index_codlinef , t1.codlinef)
                             and t1.staorg = 'A' )
         and a.codcompy = b.codcompy
         and a.codlinef = b.codlinef
         and a.dteeffec = b.dteeffec
      order by numlevel , numorg;

    cursor c2 is
      select codcompp,codpospr,qtyexman
        from thisorg2
       where codcompy = v_codcompy
         and codlinef = v_codlinef
         and dteeffec = v_dteeffec
         and codcompr = v_codcompr
      order by numlevel , numorg;

    --<<User37 #7481 1. RP Module 16/01/2022 
    cursor c3 is
      select codcompp , codpos
        from thisorg3
       where codcompy = v_codcompy
         and codlinef = v_codlinef
         and dteeffec = v_dteeffec
         and codcompp = v_codcompr
      group by codcompp , codpos
      order by codcompp , codpos;
    -->>User37 #7481 1. RP Module 16/01/2022 

  begin

    obj_row := json_object_t();
    for i in c1 loop
          v_flgdata := 'Y';
          v_codcompy := i.codcompy;
          v_codlinef := i.codlinef;
          v_dteeffec := i.dteeffec;
          v_codcompr := i.codcompp;

          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numprlvl',i.numlevel); --ระดับที่
          if i.numlevel = 0 then
            obj_data.put('desc_codcompp',get_tcenter_name(i.codcompy,global_v_lang)); --ชื่อกลุ่มบริษัท  ถ้าระดับ = 0
          else
            obj_data.put('codcompp',i.codcompp); --หน่วยงาน
            obj_data.put('desc_codcompp',get_tcenter_name(i.codcompp,global_v_lang)); --หน่วยงาน
          end if;
          obj_data.put('desc_codpospr',get_tpostn_name(i.codpospr,global_v_lang));  --ตำแหน่ง

          obj_data.put('codcompy',i.codcompy);
          obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
          obj_data.put('codempid',i.codresp); --รหัสพนักงานผู้รับผิดชอบ
          obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));--ชื่อ-นามสกุล

          obj_data.put('desc_codcomps',''); --หน่วยงานใต้บังคับบัญชา
          obj_data.put('desc_codposs','');  --ตำแหน่งใต้บังคับบัญชา
          obj_data.put('qty',''); --จำนวน

    ----ผู้ใต้บังคับบัญชา
          v_codempid  := '!@#$%';
          v_rcnt2     := 0;
          --<<User37 #7481 1. RP Module 16/01/2022 
          for k in c3 loop
            v_rcnt := v_rcnt + v_rcnt2;
            v_rcnt := v_rcnt + v_rcnt2;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('numprlvl',i.numlevel); --ระดับที่
            if i.numlevel = 0 then
              obj_data.put('desc_codcompp',get_tcenter_name(i.codcompy,global_v_lang)); --ชื่อกลุ่มบริษัท  ถ้าระดับ = 0
            else
              obj_data.put('codcompp',i.codcompp); --หน่วยงาน
              obj_data.put('desc_codcompp',get_tcenter_name(i.codcompp,global_v_lang)); --หน่วยงาน
            end if;
            obj_data.put('desc_codpospr',get_tpostn_name(i.codpospr,global_v_lang));  --ตำแหน่ง
            obj_data.put('codcompy',i.codcompy);
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_data.put('codempid',i.codresp); --รหัสพนักงานผู้รับผิดชอบ
            obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));--ชื่อ-นามสกุล

            obj_data.put('desc_codcomps',get_tcenter_name(k.codcompp,global_v_lang)); --หน่วยงานใต้บังคับบัญชา
            obj_data.put('desc_codposs',get_tpostn_name(k.codpos,global_v_lang));  --ตำแหน่งใต้บังคับบัญชา
            obj_data.put('codpos',k.codpos);  --ตำแหน่งใต้บังคับบัญชา
            obj_data.put('codlinef',i.codlinef);  --User37 #7482 1. RP Module 16/01/2022 

            begin
              select count(*)
                into v_qty
                from thisorg3
               where codcompy = i.codcompy
                 and codcompp = k.codcompp
                 and codlinef = i.codlinef
                 and dteeffec = i.dteeffec
                 and numlevel = i.numlevel
                 and codpos = k.codpos;
            exception when no_data_found then
              v_qty := null;
            end;

            obj_data.put('qty',v_qty); --จำนวน
            obj_row.put(to_char(v_rcnt-1),obj_data);
            v_rcnt2 := v_rcnt2 + 1;
          end loop;
          /*User37 #7481 1. RP Module 16/01/2022 for k in c2 loop
              v_rcnt := v_rcnt + v_rcnt2;
              obj_data := json_object_t();
              obj_data.put('coderror', '200');
--msg_err2('IN gen_data###2 v_rcnt  =  '||v_rcnt);
              obj_data.put('numprlvl',i.numlevel); --ระดับที่
              if i.numlevel = 0 then
                obj_data.put('desc_codcompp',get_tcenter_name(i.codcompy,global_v_lang)); --ชื่อกลุ่มบริษัท  ถ้าระดับ = 0
              else
                obj_data.put('codcompp',i.codcompp); --หน่วยงาน
                obj_data.put('desc_codcompp',get_tcenter_name(i.codcompp,global_v_lang)); --หน่วยงาน
              end if;
              obj_data.put('desc_codpospr',get_tpostn_name(i.codpospr,global_v_lang));  --ตำแหน่ง
              obj_data.put('codcompy',i.codcompy);
              obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
              obj_data.put('codempid',i.codresp); --รหัสพนักงานผู้รับผิดชอบ
              obj_data.put('desc_codempid',get_temploy_name(i.codresp,global_v_lang));--ชื่อ-นามสกุล
              obj_data.put('desc_codcomps',get_tcenter_name(k.codcompp,global_v_lang)); --หน่วยงานใต้บังคับบัญชา
              obj_data.put('desc_codposs',get_tpostn_name(k.codpospr,global_v_lang));  --ตำแหน่งใต้บังคับบัญชา
              --obj_data.put('qty',k.qtyexman); --จำนวน
              obj_row.put(to_char(v_rcnt-1),obj_data);
              v_rcnt2 := v_rcnt2 + 1;
          end loop;*/
          -->>User37 #7481 1. RP Module 16/01/2022 
          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISORG2');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;

    cursor c1 is
      select a.codempid, a.codcompp, a.codpos
             ,a.codcompy, a.codlinef, a.dteeffec, a.numlevel--User37 #7482 1. RP Module 16/01/2022 
        from thisorg3 a
       where a.codcompy = b_index_codcompy
         and a.codlinef = b_index_codlinef
         and a.dteeffec = to_date(b_index_dteeffec, 'dd/mm/yyyy')
         and a.numlevel = to_number(b_index_numlevel)
         and a.codcompp = b_index_codcompp
         and a.codpos = b_index_codpos--User37 #7481 1. RP Module 16/01/2022 
      order by a.codempid;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';

      flgpass := secur_main.secur3(i.codcompp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then
          v_rcnt := v_rcnt+1;
--msg_err2('IN gen_popup##3 v_rcnt =  '||v_rcnt);
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcompp,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
          --<<User37 #7482 1. RP Module 16/01/2022 
          obj_data.put('codcompy',i.codcompy);
          obj_data.put('codlinef',i.codlinef);
          obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
          obj_data.put('numlevel',i.numlevel);
          obj_data.put('codcompp',i.codcompp);
          -->>User37 #7482 1. RP Module 16/01/2022 
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_rcnt > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISORG3');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
    /*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --
end;

/

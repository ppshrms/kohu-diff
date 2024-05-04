--------------------------------------------------------
--  DDL for Package Body HRCO2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2HX" AS
--last update  redmine3208
procedure initial_value (json_str in clob) AS
 json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  procedure check_index is
    v_secur boolean := false;
  v_codcomp                 temphead.codcomph%type;
  v_codpos                  temphead.codposh%type;
  v_codempid                temphead.codempidh%type;
  begin
    if (p_codcomp is null)and(p_codpos is null)and(p_codempid is null) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if (p_codcomp is not null) then
     begin
            select  count(codcomp) into v_codcomp
            from   tcenter
            where  codcomp like p_codcomp||'%';
            exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
            return;
        end;
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
            select  count(codpos) into v_codpos
            from   tpostn
            where  codpos = p_codpos;
            exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
            return;
        end;
    end if;
    if p_codempid is not null then
      begin
            select  count(codempid) into v_codempid
            from   temploy1
            where  codempid = p_codempid;
            exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
            return;
        end;
        param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

  end check_index;

 procedure get_index (json_str_input in clob, json_str_output out clob) AS
   json_str        json_object_t;
    param_json       json_object_t;
 begin
    initial_value(json_str_input);
    check_index();
--    json_str               := json_object_t(json_str_input);
    if param_msg_error is null then
      delete_ttemprpt;
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack ;
    json_str_output := get_response_message('400', param_msg_error||' '||dbms_utility.format_error_backtrace, global_v_lang);
  END get_index;


  procedure gen_index (json_str_output out clob) AS
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_check_secur       boolean;
    v_check_secur2      boolean;
    v_flgdata           varchar2(2 char);
    v_flgsecur          varchar2(2 char);

    v_image             varchar2(1000 char) := '';
    v_imageh            varchar2(1000 char) := '';
    v_logo_image        varchar2(1000 char) := '';
    v_codempid          temploy1.codempid%type;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_codempidh         temploy1.codempid%type;
    v_codcomph          temploy1.codcomp%type;
    v_codposh           temploy1.codpos%type;
    v_desc_codempidh    temploy1.namempt%type;
    v_desc_codcomph     tcenter.namcente%type;
    v_desc_codposh      tpostn.nampose%type;
    v_emphead_codempid  temploy1.codempid%type;
    v_emphead_codcomp   temploy1.codcomp%type;
    v_emphead_codpos    temploy1.codpos%type;
    v_staemp            temploy1.staemp%type;
    v_codcomp_sec_h     varchar2(1000 char);  -- ST11#8303 || 05/09/2022
    v_codpos_sec_h      varchar2(1000 char);  -- ST11#8303 || 05/09/2022   
    v_flgskip           varchar2(1 char);
    v_numseq            number;

    cursor c_head is
      select a.codempidh,a.codcomph,a.codposh
        from temphead a
       where a.codempidh = nvl(p_codempid , a.codempidh)
         and a.codcomph	like  p_codcomp||'%'
         and a.codposh = nvl(p_codpos,a.codposh )
      union
      select a.codempidh,a.codcomph,a.codposh
        from temphead a
       where (a.codempidh	in (select b.codempid
                                from temploy1 b
                               where b.codcomp like p_codcomp||'%'
                                 and b.codpos = nvl(p_codpos,b.codpos)           ))
               or ((a.codcomph,a.codposh)	in (select b.codcomp,b.codpos
                                                from temploy1 b
                                               where b.codempid = p_codempid  ))
    group by a.codcomph, a.codposh, a.codempidh
    order by codcomph, codposh, codempidh;


    cursor c_heademp is
      --<<nut
      select replace(codempidh,'%','') codempidh,replace(codcomph,'%','') codcomph,replace(codposh,'%','') codposh,typdata
          from(
               select codempidh,codcomph,codposh,'1' typdata
              --  p_codcomph,p_codposh
              from temphead
              where codcomph like p_codcomp||'%'
              and codposh = nvl(p_codpos,codposh)
              and p_codempid is null
              union
              select a.codempidh,a.codcomph,a.codposh,'2' typdata
              -- p_codempidh
              from temphead a,temploy1 b
              where a.codempidh = b.codempid
              and a.codempidh = nvl(p_codempid,a.codempidh)
              and b.codcomp like p_codcomp||'%'
              and b.codpos = nvl(p_codpos,b.codpos)
          )
          order by codcomph,codposh,codempidh,typdata;
      /*select a.codempidh,a.codcomph,a.codposh
        from temphead a
       where a.codempidh = nvl(p_codempid , a.codempidh)
         and a.codcomph	like  p_codcomp||'%'
         and a.codposh = nvl(p_codpos,a.codposh )
     union
      select a.codempidh,a.codcomph,a.codposh
        from temphead a
       where (a.codempidh	in (select b.codempid
                                from temploy1 b
                               where b.codcomp like p_codcomp||'%'
                                 and b.codpos = nvl(p_codpos,b.codpos) ))
               or ((a.codcomph,a.codposh)	in (select b.codcomp,b.codpos
                                                from temploy1 b
                                               where b.codempid = p_codempid  ))
    group by a.codcomph, a.codposh, a.codempidh
    order by codcomph, codposh, codempidh;*/
    -->>nut

    cursor c_emphead is --1
      select codempid,codcomp,codpos
        from temploy1
       where staemp <> 9
         and codcomp = v_codcomph
         and codpos = v_codposh
      union -- -- ST11#8303 || 05/09/2022
         select codempid,codcomp,codpos
         from temploy1
         where staemp <> 9
         and codcomp = nvl(v_codcomp_sec_h,'@#$%')
         and codpos  = nvl(v_codpos_sec_h,'@#$%')        
      order by codempid;
     -- ST11#8303 || 05/09/2022

    cursor c_emplist is
      select codempid,codcomp,codpos
        from temphead
       where codempidh = v_emphead_codempid --รหัสพนักงานหัวหน้างาน
          or (codcomph  = v_emphead_codcomp --หน่วยงานจาก temploy1
          and codposh  = v_emphead_codpos) --ตำแหน่งจาก temploy1
        order by codempid,codcomp,codpos;

    cursor c_emplist2 is
      select codempid,codcomp,codpos
        from temploy1
       where staemp <> 9
         and codcomp = v_codcomp -- หน่วยงานผู้ใต้บังคับบัญชา
         and codpos = v_codpos -- ตำแหน่งผู้ใต้บังคับบัญชา
      order by codempid;

    cursor c_list_emp_head is
      select item2,item3,item4
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = p_codapp
         and item1 = 'HRCO2HXH'
       group by item2,item3,item4
       order by item2,item3,item4;

    cursor c_sub_emp is
      select item2 as codempidh, item3 as codempid
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = p_codapp
         and item1 = 'HRCO2HXS'
       group by item2,item3
       order by item2,item3;
  begin
    v_flgdata   :='N';
    v_flgsecur  :='N';
    v_flgskip   :='N';

    v_rcnt := 0;
    obj_row :=   json_object_t();
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    if p_codempid is not null then
        for r1 in c_heademp loop
                v_flgskip := 'Y';
                v_codempidh    := r1.codempidh;
                v_codcomph     := r1.codcomph;
                v_codposh      := r1.codposh;

                if v_codempidh <> '%' then
                      v_emphead_codempid  := v_codempidh;
                      begin
                        select codcomp, codpos, staemp
                        into v_emphead_codcomp, v_emphead_codpos, v_staemp
                        from temploy1
                        where codempid = v_codempidh;
                      exception when no_data_found then
                        v_staemp := null;
                      end;
                      if v_staemp <> 9 and v_staemp is not null then
                        if v_emphead_codempid = p_codempid then
                              begin
                                insert into ttemprpt( codempid, codapp, numseq,
                                                      item1, item2, item3, item4)
                                values( global_v_codempid, p_codapp, v_numseq,
                                        'HRCO2HXH', v_emphead_codempid,v_emphead_codcomp,v_emphead_codpos);
                              exception when others then
                                null;
                              end;
                                    v_numseq := v_numseq + 1;
                        end if;
                      end if;

                elsif v_codcomph <> '%' and v_codposh <> '%' then
                    begin
                        select codcomp ,codpos into  v_codcomp_sec_h ,v_codpos_sec_h
                        from tsecpos 
                        where codempid = p_codempid
                        and dteeffec = (select max(dteeffec) from tsecpos where codempid = p_codempid)
                        and numseq =  (select max(numseq) from tsecpos 
                                        where codempid = p_codempid
                                          and dteeffec = (select max(dteeffec) from tsecpos 
                                                          where codempid = p_codempid));
                    exception when no_data_found then
                        v_codcomp_sec_h := null;
                        v_codpos_sec_h  := null;                     
                    end;    

                    for r2 in c_emphead loop --2
                        v_emphead_codempid  := r2.codempid;
                        v_emphead_codcomp   := r2.codcomp;
                        v_emphead_codpos    := r2.codpos;

                        v_check_secur       := secur_main.secur2(v_emphead_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
                        if v_check_secur then
                              if v_emphead_codempid = p_codempid then
                                    begin
                                      insert into ttemprpt( codempid, codapp, numseq,
                                                            item1, item2, item3, item4)
                                      values( global_v_codempid, p_codapp, v_numseq,
                                              'HRCO2HXH', v_emphead_codempid, v_emphead_codcomp, v_emphead_codpos);
                                    exception when others then
                                      null;
                                    end;
                                v_numseq := v_numseq + 1;
                                v_flgdata :='Y';
                              end if;
                        end if;
                    end loop;        
                end if;     
        end loop; --for r1 in c_heademp loop

    elsif p_codcomp is not null then
          for r1 in c_head loop
            v_flgskip := 'Y';
            v_codempidh        := r1.codempidh;
            v_codcomph         := r1.codcomph;
            v_codposh          := r1.codposh;

            if v_codcomph <> '%' and v_codposh <> '%' then            
                  begin
                        select codcomp ,codpos into  v_codcomp_sec_h ,v_codpos_sec_h
                        from tsecpos 
                        where codempid = p_codempid
                        and dteeffec = (select max(dteeffec) from tsecpos where codempid = p_codempid)
                        and numseq =  (select max(numseq) from tsecpos 
                                        where codempid = p_codempid
                                          and dteeffec = (select max(dteeffec) from tsecpos 
                                                          where codempid = p_codempid));
                    exception when no_data_found then
                        v_codcomp_sec_h := null;
                        v_codpos_sec_h  := null;                     
                    end;    

                  for r2 in c_emphead loop --3
                        v_emphead_codempid  := r2.codempid;
                        v_emphead_codcomp   := r2.codcomp;
                        v_emphead_codpos    := r2.codpos;

                        v_check_secur     := secur_main.secur2(v_emphead_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
                        if v_check_secur then
                              begin
                                insert into ttemprpt( codempid, codapp, numseq,
                                                      item1, item2, item3, item4)
                                values( global_v_codempid, p_codapp, v_numseq,
                                        'HRCO2HXH', v_emphead_codempid, v_emphead_codcomp, v_emphead_codpos);
                              exception when others then
                                null;
                              end;
                              v_numseq := v_numseq + 1;
                              v_flgdata :='Y';
                        end if;
                  end loop;
            elsif v_codempidh <> '%' then
                  v_emphead_codempid  := v_codempidh;
                  begin
                    select codcomp, codpos, staemp
                    into v_emphead_codcomp, v_emphead_codpos, v_staemp
                    from temploy1
                    where codempid = v_codempidh;
                  exception when no_data_found then
                    v_staemp := null;
                  end;
                  if v_staemp <> 9 and v_staemp is not null then
                        begin
                              insert into ttemprpt( codempid, codapp, numseq,
                                                    item1, item2, item3, item4)
                              values( global_v_codempid, p_codapp, v_numseq,
                                      'HRCO2HXH', v_emphead_codempid,v_emphead_codcomp,v_emphead_codpos);
                        exception when others then
                              null;
                        end;
                        v_numseq := v_numseq + 1;
                  end if;
            end if; --elsif v_codempidh <> '%' then
          end loop; --for r1 in c_head loop
    end if; --if p_codempid is not null then

    -- find Subordinate
    for rh in c_list_emp_head loop
      v_emphead_codempid  := rh.item2; -- codempid head
      v_emphead_codcomp := rh.item3;
      v_emphead_codpos := rh.item4;
      --
      for r3 in c_emplist loop
        v_codempid := r3.codempid;
        v_codcomp := r3.codcomp;
        v_codpos := r3.codpos;
        if v_codcomp <> '%' and v_codpos <> '%' then
          for r4 in c_emplist2 loop
            v_check_secur2     := secur_main.secur2(r4.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if v_check_secur2 then
              begin
                select nvl(namimage,r4.codempid)
                 into v_image
                 from tempimge
                 where codempid = r4.codempid;
              exception when no_data_found then
                v_image := r4.codempid;
              end;
              v_flgdata :='Y';
              begin
                insert into ttemprpt( codempid, codapp, numseq,
                                      item1, item2, item3)
                values( global_v_codempid, p_codapp, v_numseq,
                        'HRCO2HXS',
                        v_emphead_codempid, r4.codempid);
              exception when others then
                null;
              end;
              v_numseq := v_numseq + 1;
            end if;
          end loop;
        elsif v_codempid <> '%' then
          v_check_secur2     := secur_main.secur2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
          begin
            select codcomp,codpos,staemp
            into v_codcomp,v_codpos,v_staemp
            from temploy1
            where codempid = v_codempid;
          exception when no_data_found then
            v_staemp := null;
          end;
          if v_check_secur2 and (v_staemp <> 9 and v_staemp is not null) then
            begin
              select namimage
               into v_image
               from tempimge
               where codempid = v_codempid;
            exception when no_data_found then
              v_image := '';
            end;
            begin
              insert into ttemprpt( codempid, codapp, numseq,
                                    item1, item2, item3)
              values( global_v_codempid, p_codapp, v_numseq,
                      'HRCO2HXS',
                      v_emphead_codempid,v_codempid);
            exception when others then
              null;
            end;
            v_numseq := v_numseq + 1;
          end if;
        end if;
      end loop;
    end loop;


   -- add data to json
    for rec_emp in c_sub_emp loop

      -- boss
      begin
        select nvl(namimage,rec_emp.codempidh)
         into v_imageh
         from tempimge
         where codempid = rec_emp.codempidh;
      exception when no_data_found then
        v_imageh := rec_emp.codempidh;
      end;
      begin
        select codcomp, codpos
        into v_emphead_codcomp, v_emphead_codpos
        from temploy1
        where codempid = rec_emp.codempidh;
      exception when no_data_found then
        null;
      end;
      v_flgdata :='Y';
      obj_data  := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('imageh', v_imageh);
      obj_data.put('logo_imageh', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh);
      obj_data.put('codempidh', rec_emp.codempidh);
      obj_data.put('desc_codempidh', get_temploy_name(rec_emp.codempidh,global_v_lang));
      obj_data.put('desc_codcomph', get_tcenter_name(v_emphead_codcomp,global_v_lang));
      obj_data.put('desc_codposh', get_tpostn_name(v_emphead_codpos,global_v_lang));

      -- subordinate
      begin
        select nvl(namimage,rec_emp.codempid)
         into v_image
         from tempimge
         where codempid = rec_emp.codempid;
      exception when no_data_found then
        v_image := rec_emp.codempid;
      end;
      begin
        select codcomp, codpos
        into v_codcomp, v_codpos
        from temploy1
        where codempid = rec_emp.codempid;
      exception when no_data_found then
        null;
      end;
      obj_data.put('image', v_image);
      obj_data.put('logo_image', '/'||get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_image);
      obj_data.put('codempid', rec_emp.codempid);
      obj_data.put('desc_codempid', get_temploy_name(rec_emp.codempid,global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;
    --

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temphead');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      commit;
      json_str_output := obj_row.to_clob;
    end if;
  END gen_index;
  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
    json_str        json_object_t;
    param_json       json_object_t;
  begin
    initial_value(json_str_input);
    json_str               := json_object_t(json_str_input);
    gen_detail(p_codcomp,p_codpos,p_codempid,json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack ;
    json_str_output := get_response_message('400', param_msg_error||' '||dbms_utility.format_error_backtrace, global_v_lang);
  END get_detail;


  procedure gen_detail (v_codcomp varchar2,v_codpos varchar2,v_codempid varchar2,json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_image            tempimge.namimage%type;
    v_imageh           tempimge.namimage%type;
    v_img_disp         tempimge.namimage%type;
    v_rcnt             number;
    v_numseq           number;
    v_check_secur      boolean;

    v_flgimg          varchar2(2 char) := 'N';
    v_flgskip         varchar2(2 char) := 'N';
    v_codempidb       varchar2(1000 char) := '';
    v_desc_codempidb  varchar2(1000 char) := '';
    v_codcompb        varchar2(1000 char) := '';
    v_desc_codcompb   varchar2(1000 char) := '';
    v_codposb         varchar2(1000 char) := '';
    v_desc_codposb    varchar2(1000 char) := '';
    v_codempidh       varchar2(1000 char) := '';
    v_desc_codempidh  varchar2(1000 char) := '';
    v_codcomph        varchar2(1000 char) := '';
    v_desc_codcomph   varchar2(1000 char) := '';
    v_codposh         varchar2(1000 char) := '';
    v_desc_codposh    varchar2(1000 char) := '';

    cursor c_temphead is
      select numseq, codempid, codcomp, codpos, codempidh, codcomph ,codposh
        from temphead
       where codempidh = nvl(v_codempid,codempidh)
         and codcomph like v_codcomp||'%'
         and codposh = nvl(v_codpos,codposh)
    order by numseq,codempid,codcomp,codpos;
  begin
    v_numseq        := 0;
    v_rcnt          := 0;
    obj_row         :=   json_object_t();
    for r1 in c_temphead loop
      v_flgimg := 'N';
      v_flgskip := 'Y';
      v_codempidb       := '';
      v_desc_codempidb  := '';
      v_codcompb        := '';
      v_desc_codcompb   := '';
      v_codposb         := '';
      v_desc_codposb    := '';
      v_codempidh       := '';
      v_desc_codempidh  := '';
      v_codcomph        := '';
      v_desc_codcomph   := '';
      v_codposh         := '';
      v_desc_codposh    := '';
      v_image           := '';
      v_img_disp        := '';
--      if v_codempid is not null then
        v_check_secur     := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
--      else
--       v_check_secur     := secur_main.secur7(r1.codcomp, global_v_coduser);
--      end if;
      if v_check_secur then
        if r1.codempidh != '%' then
          v_codempidh := r1.codempidh;
          v_desc_codempidh := get_temploy_name(r1.codempidh,global_v_lang);
          begin
            select get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||namimage
             into v_imageh
             from tempimge
             where codempid = r1.codempidh;
          exception when no_data_found then
            v_imageh := '';
          end;
        else
          v_codposh := r1.codposh;
          v_codcomph := r1.codcomph;
          v_desc_codposh := get_tpostn_name(r1.codposh,global_v_lang);
          v_desc_codcomph := get_tcenter_name(r1.codcomph,global_v_lang);
        end if;

        if r1.codempid != '%' then
          v_flgimg := 'N';
          v_flgskip := 'N';
          v_codempidb := r1.codempid;
          v_desc_codempidb := get_temploy_name(r1.codempid,global_v_lang);
          begin
            select namimage
             into v_image
             from tempimge
             where codempid = r1.codempid;
             v_img_disp := v_image;
          exception when no_data_found then
            v_image := '';
            v_img_disp := '';
          end;

          if v_image is not null then
            v_image := get_tfolderd('HRPMC2E1')||'/'|| v_image;
            v_flgimg := 'Y';
          end if;

        else
          v_codcompb := r1.codcomp;
          v_codposb := r1.codpos;
          v_desc_codposb := get_tpostn_name(r1.codpos,global_v_lang);
          v_desc_codcompb := get_tcenter_name(r1.codcomp,global_v_lang);
        end if;
--        if r1.codempid = '' then
--          v_flgskip := 'Y';
--        end if;
        v_numseq  := v_numseq + 1;
        obj_data  := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', v_numseq);
        obj_data.put('codempid',v_codempidb);
        obj_data.put('codcomp',v_codcompb);
        obj_data.put('codpos',v_codposb);
        obj_data.put('codempidh',v_codempidh);
        obj_data.put('codcomph',v_codcomph);
        obj_data.put('codposh',v_codposh);
        obj_data.put('imageh',v_imageh); -- รูปหัวหน้า
        obj_data.put('image',v_image); -- รูปลูกน้อง
--        obj_data.put('logo_image', v_image); -- รูปลูกน้องในรายงาน

--        obj_data.put('image',v_image);
        obj_data.put('logo_image','/'||get_tsetup_value('PATHWORKPHP')||v_img_disp);
        obj_data.put('desc_codempid',v_desc_codempidb);
        obj_data.put('desc_codcom',v_desc_codcompb);
        obj_data.put('desc_codpos',v_desc_codposb);
        obj_data.put('desc_codempidh',v_desc_codempidh);
        obj_data.put('desc_codcomh',v_desc_codcomph);
        obj_data.put('desc_codposh',v_desc_codposh);
        obj_data.put('flgimg',v_flgimg);
        obj_data.put('flgskip',v_flgskip);
        if isInsertReport then
          -- insert ttemprpt for report specific
--          if v_codempidb is not null then
--            begin
--              select get_tfolderd('HRPMC2E1')||'/'||namimage
--               into v_image
--               from tempimge
--               where codempid = r1.codempid;
--            exception when no_data_found then
--              v_image := '';
--            end;
--            obj_data.put('logo_image', get_tsetup_value('PATHWORKPHP')||v_image);
--          end if;
          insert_ttemprpt(obj_data);
        end if;

        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt               := v_rcnt + 1;
      end if;
    end loop;

    json_str_output := obj_row.to_clob;

  END gen_detail;
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    json_codempid       := hcm_util.get_json_t(json_obj, 'list_codempid');
    json_codcomp        := hcm_util.get_json_t(json_obj, 'p_codcomp');
    json_codpos         := hcm_util.get_json_t(json_obj, 'p_codpos');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;
  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    v_codpos          varchar2(100 char);
    v_codcomp         varchar2(100 char);
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      delete_ttemprpt;
      for i in 0..json_codempid.get_size-1 loop
        p_codempid  := hcm_util.get_string_t(json_codempid, to_char(i));
        p_codcomp   := hcm_util.get_string_t(json_codcomp, to_char(i));
        p_codpos    := hcm_util.get_string_t(json_codpos, to_char(i));
        gen_detail(p_codcomp,p_codpos,p_codempid,json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure delete_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = p_codapp;
    exception when others then
      null;
    end;
  end delete_ttemprpt;

  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq            number := 0;
    v_image             tempimge.namimage%type;
    v_imageh            tempimge.namimage%type;
    v_item1             varchar2(1000 char);
    v_item2             varchar2(1000 char);
    v_item3             varchar2(1000 char);
    v_item4             varchar2(1000 char);
    v_item5             varchar2(1000 char);
    v_item6             varchar2(1000 char);
    v_item7             varchar2(1000 char);
    v_item8             varchar2(1000 char);
    v_item9             varchar2(1000 char);
    v_item10            varchar2(1000 char);
    v_item11            varchar2(1000 char);
    v_item12            varchar2(1000 char);
    v_item13            varchar2(1000 char);
    v_item14            varchar2(1000 char);
    v_item15            varchar2(1000 char);
    v_item16            varchar2(1000 char);
    v_codempid          varchar2(1000 char);
    v_codempidh         varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
    v_numseq := v_numseq + 1;
    v_codempid := hcm_util.get_string_t(obj_data, 'codempid');
    begin
      select get_tfolderd('HRPMC2E1')||'/'||namimage
       into v_image
       from tempimge
       where codempid = v_codempid;
    exception when no_data_found then
      v_image := '';
    end;

    v_codempidh := hcm_util.get_string_t(obj_data, 'codempidh');
    begin
      select get_tfolderd('HRPMC2E1')||'/'||namimage
       into v_imageh
       from tempimge
       where codempid = v_codempidh;
    exception when no_data_found then
      v_imageh := '';
    end;
    v_item1 := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
    v_item2 := nvl(hcm_util.get_string_t(obj_data, 'imageh'), '');
    v_item3 := nvl(hcm_util.get_string_t(obj_data, 'codempidh'), '');
    v_item4 := nvl(hcm_util.get_string_t(obj_data, 'desc_codempidh'), '');
    v_item5 := nvl(hcm_util.get_string_t(obj_data, 'codcomph'), '');
    v_item6 := nvl(hcm_util.get_string_t(obj_data, 'desc_codcomh'), '');
    v_item7 := nvl(hcm_util.get_string_t(obj_data, 'codposh'), '');
    v_item8 := nvl(hcm_util.get_string_t(obj_data, 'desc_codposh'), '');
    v_item9 := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
    v_item10 := nvl(hcm_util.get_string_t(obj_data, 'desc_codempid'), '');
    v_item11 := nvl(hcm_util.get_string_t(obj_data, 'codcomp'), '');
    v_item12 := nvl(hcm_util.get_string_t(obj_data, 'desc_codcom'), '');
    v_item13 := nvl(hcm_util.get_string_t(obj_data, 'codpos'), '');
    v_item14 := nvl(hcm_util.get_string_t(obj_data, 'desc_codpos'), '');
    v_item15 := nvl(hcm_util.get_string_t(obj_data, 'logo_image'), '');
    v_item16 := nvl(hcm_util.get_string_t(obj_data, 'flgimg'), 'N');
    begin
      insert
        into ttemprpt( codempid, codapp, numseq, item1, item2, item3, item4, item5,item6, item7, item8, item9, item10, item11, item12, item13, item14,item15,item16)
      values( global_v_codempid, p_codapp, v_numseq,
              v_item1,
              v_item2,
              v_item3,
              v_item4,
              v_item5,
              v_item6,
              v_item7,
              v_item8,
              v_item9,
              v_item10,
              v_item11,
              v_item12,
              v_item13,
              v_item14,
              v_item15,
              v_item16);
    exception when others then
      null;
    end;
  end insert_ttemprpt;
END HRCO2HX;

/

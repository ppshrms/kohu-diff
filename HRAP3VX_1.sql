--------------------------------------------------------
--  DDL for Package Body HRAP3VX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3VX" is
-- last update: 27/08/2020 16:00
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
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numtime');
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');   --p_codempid_queryglobal_v_codempid
        --screen
        b_index_codkpino     := hcm_util.get_string_t(json_obj,'p_codkpino');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --

--<< user25 Date : 10/09/2021 3. AP Module #4435
 procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_temp      varchar2(10 char);
    v_flgSecur  boolean;

  begin
        begin
          select 'X' , staemp
          into v_temp, v_staemp
            from temploy1
           where codempid = b_index_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        end;


      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;

--      if v_staemp = '0' then
--        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
--        return;
--      end if;
   end;
-->> user25 Date : 10/09/2021 3. AP Module #4435

   procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    --<< user25 Date : 10/09/2021 3. AP Module #4435
    if b_index_codempid is not null then
        check_index;
    end if;
    -->> user25 Date : 10/09/2021 3. AP Module #4435
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	boolean := false;

cursor c1 is
        select  dteyreap,numtime,codcomp, objective
        from    tobjdep
       where    dteyreap   = b_index_dteyreap
         and    numtime    = b_index_numtime
         and    codcomp    like b_index_codcomp||'%'
         and    rownum <= 1;

cursor c2 is
        select  dteyreap,numtime,codcomp,codempid, objective
        from    tobjemp
       where    dteyreap   = b_index_dteyreap
         and    numtime    = b_index_numtime
         and    codempid   = b_index_codempid;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
-- mode codcomp
    if  b_index_codcomp is not null then
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
                        obj_data.put('dteyreap',i.dteyreap);
                        obj_data.put('numtime',i.numtime);
                        obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                        obj_data.put('objective',i.objective);
                     obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                 end loop;
            end if; --v_flgdata
            if v_flgdata = 'N' then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBJDEP');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            elsif v_flgsecu = 'N' then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            else
             -- json_str_output := obj_row.to_clob;
              json_str_output := obj_data.to_clob;
            end if;
-- mode codempid
    else
            for j in c2 loop
                v_flgdata := 'Y';
            end loop;
            if v_flgdata = 'Y' then
                v_chksecu := '2';
                for j in c2 loop
                   flgpass := secur_main.secur3(j.codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
                    if flgpass then
                        v_flgsecu := 'Y';
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('image',get_emp_img(j.codempid));
                        obj_data.put('desc_codempid',get_temploy_name(j.codempid,global_v_lang));
                        obj_data.put('codempid',j.codempid);
                        obj_data.put('dteyreap',j.dteyreap);
                        obj_data.put('numtime',j.numtime);
                        obj_data.put('objective',j.objective);
                    -- obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;
            end if; --v_flgdata
            if v_flgdata = 'N' then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBJEMP');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            elsif v_flgsecu = 'N' then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            else
             -- json_str_output := obj_row.to_clob;
              json_str_output := obj_data.to_clob;
            end if;
    end if;
  end;
  --

  procedure get_index_table(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index_table(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgskip       varchar2(1 char) := 'N';
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	boolean;
    v_codempid      temploy1.codempid%type;
    v_com           tcenter.codcomp%type;
    v_codkpi        tkpiemp.codkpi%type;
    v_pctwgt_comp   number:=0;
    v_pctwgt_emp    number:=0;
    --<<User37 #7255 3. AP Module 30/11/2021
    v_typkpio       tkpiemp.typkpi%type := '!';
    v_codkpio       tkpiemp.codkpi%type := '!@#$';
    -->>User37 #7255 3. AP Module 30/11/2021

cursor c1 is
    select dteyreap,numtime,codempid,typkpi,codkpi,kpides,target,mtrfinish,pctwgt,codcomp
      from tkpiemp
     where  dteyreap   =    b_index_dteyreap
       and  numtime    =    b_index_numtime
       and  codcomp   like  b_index_codcomp||'%'
       and  codempid  =     nvl(b_index_codempid,codempid)
       order by codempid,typkpi,codkpi;

cursor c2 is
     select dteyreap,numtime,codempid,codkpi,score,kpides,grade
       from tkpiempg
     where  dteyreap   =     b_index_dteyreap
       and  numtime    =     b_index_numtime
       and  codempid   =     v_codempid
       and  codkpi     =     v_codkpi
       order by score desc;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';

    for i in c1 loop
        v_flgdata := 'Y';
    end loop;


    if v_flgdata = 'Y' then
        v_flgskip := 'Y';
        for i in c1 loop
            v_flgskip := 'N';
            flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
             -- mode codcomp
                if  b_index_codcomp is not null then
                    v_rcnt := v_rcnt+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('image',get_emp_img(i.codempid));
                    obj_data.put('codempid',i.codempid);
                    obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                    obj_data.put('typkpi',i.typkpi);
                    obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
                    obj_data.put('codkpi',i.codkpi);
                    obj_data.put('kpides',i.kpides);
                    obj_data.put('pctwgt',to_char(i.pctwgt,'fm990.00'));

                    v_pctwgt_comp := v_pctwgt_comp+nvl(i.pctwgt,0);
                    obj_data.put('target',i.target);
                    obj_data.put('mtrfinish',to_char(i.mtrfinish,'fm9,999,999,999,990.00'));
                    --adjust--
                    obj_data.put('dteyear',b_index_dteyreap);
                    obj_data.put('numseq',b_index_numtime);
                    obj_data.put('flgskip',v_flgskip);
                    obj_data.put('codcomp',b_index_codcomp);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                else-- mode codemp
                    v_codempid  := i.codempid;
                    v_codkpi    := i.codkpi;
                    v_flgdata2 := 'N';
                    v_flgskip := 'Y';
                        for k in c2 loop
                            v_flgdata2 := 'Y';
                            v_flgskip := 'N';
                            v_rcnt := v_rcnt+1;
                            obj_data := json_object_t();
                            obj_data.put('coderror', '200');
                            obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
                            obj_data.put('typkpi',i.typkpi);
                            obj_data.put('codkpi',i.codkpi);
                            obj_data.put('kpides',i.kpides);
                            obj_data.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
                            --<<User37 #7255 3. AP Module 30/11/2021
                            --v_pctwgt_emp := v_pctwgt_emp+nvl(i.pctwgt,0);
                            if i.typkpi <> v_typkpio and i.codkpi <> v_codkpio then
                              v_pctwgt_emp := v_pctwgt_emp+nvl(i.pctwgt,0);
                              v_typkpio := i.typkpi;
                              v_codkpio := i.codkpi;
                            end if;
                            -->>User37 #7255 3. AP Module 30/11/2021
                            obj_data.put('target',i.target);
                            obj_data.put('mtrfinish',to_char(i.mtrfinish,'fm9,999,999,999,990.00'));

                            obj_data.put('qtyscor',to_char(k.score,'fm990.00'));
                            obj_data.put('gradedes',k.kpides);
                            --adjust--
                            obj_data.put('dteyear',b_index_dteyreap);
                            obj_data.put('numseq',b_index_numtime);
                            obj_data.put('codempid',k.codempid);
                            obj_data.put('grade',k.grade);
                             begin
                               select codcomp
                                 into v_com
                                 from temploy1
                                where codempid = k.codempid;
                               exception when no_data_found then
                                v_com := null;
                             end;
                            obj_data.put('codcomp',v_com);
                            obj_row.put(to_char(v_rcnt-1),obj_data);
                        end loop;

                        if v_flgdata2 = 'N' then
                           v_rcnt := v_rcnt+1;
                            obj_data := json_object_t();
                            obj_data.put('coderror', '200');
                            obj_data.put('typkpi',i.typkpi);
                            obj_data.put('codempid',i.codempid);
                            obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
                            obj_data.put('codkpi',i.codkpi);
                            obj_data.put('kpides',i.kpides);
                            obj_data.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
                            obj_data.put('target',i.target);
                            obj_data.put('mtrfinish',to_char(i.mtrfinish,'fm9,999,999,999,990.00'));
                            obj_data.put('qtyscor','');
                            obj_data.put('gradedes','');
                            obj_data.put('dteyear',b_index_dteyreap);
                            obj_data.put('numseq',b_index_numtime);
                             begin
                               select codcomp
                                 into v_com
                                 from temploy1
                                where codempid = i.codempid;
                               exception when no_data_found then
                                v_com := null;
                             end;
                            obj_data.put('codcomp',v_com);
                            --obj_data.put('flgskip','Y');
                            obj_row.put(to_char(v_rcnt-1),obj_data);
                        end if;

                end if;
            end if;  --flgpass
        end loop; --c1


        if v_flgsecu = 'Y' then
         if  b_index_codcomp is not null then--comp
              if v_rcnt > 0 then
                --- grand total---
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('flgsum','Y');
                obj_data.put('image','');
                obj_data.put('codempid','');
                obj_data.put('desc_codempid','');
                obj_data.put('typkpi','');
                obj_data.put('codkpi','');
                obj_data.put('kpides',get_label_name('HRAP3VXC2',global_v_lang,100));--Sumรวม
                obj_data.put('pctwgt',to_char(v_pctwgt_comp,'fm990.00'));
                obj_data.put('target','');
                obj_data.put('mtrfinish','');
                obj_data.put('flgskip','Y');
                obj_data.put('dteyear',b_index_dteyreap);
                obj_data.put('numseq',b_index_numtime);
                obj_data.put('codcomp',b_index_codcomp);
                obj_row.put(to_char(v_rcnt-1),obj_data);
             end if;
         else --emp
              if v_rcnt > 0 then
                --- grand total---
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('flgsum','Y');
                obj_data.put('typkpi','');
                obj_data.put('codkpi','');
                obj_data.put('kpides',get_label_name('HRAP3VXC2',global_v_lang,100));--Sumรวม
                obj_data.put('pctwgt',to_char(v_pctwgt_emp,'fm990.00'));
                obj_data.put('target','');
                obj_data.put('mtrfinish','');
                obj_data.put('qtyscor','');
                obj_data.put('gradedes','');
                obj_data.put('dteyear',b_index_dteyreap);
                obj_data.put('numseq',b_index_numtime);
                 begin
                   select codcomp
                     into v_com
                     from temploy1
                    where codempid = v_codempid;
                   exception when no_data_found then
                    v_com := null;
                 end;
                obj_data.put('codcomp',v_com);
--               obj_data.put('flgskip','Y');
                obj_row.put(to_char(v_rcnt-1),obj_data);
             end if;
         end if;
      end if;
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TKPIEMP');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
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
  --


  procedure gen_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	boolean;

cursor c1 is
    select  dteyreap,numtime,codempid,typkpi,codkpi,kpides,target,mtrfinish,pctwgt,codcomp,targtstr,targtend
      from  tkpiemp
     where  dteyreap   =    b_index_dteyreap
       and  numtime    =    b_index_numtime
       and  codcomp    like b_index_codcomp ||'%'
       and  codempid   =    b_index_codempid
       and  codkpi     =    b_index_codkpino
       order by codempid,typkpi,codkpi;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    if v_flgdata = 'Y' then
        for i in c1 loop
            flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
                    v_rcnt := v_rcnt+1;

                    obj_data.put('image',get_emp_img(i.codempid));
                    obj_data.put('codempid',i.codempid);
                    obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                    obj_data.put('dteyear',i.dteyreap);
                    obj_data.put('numseq',i.numtime);
                    obj_data.put('codkpi',i.codkpi);
                    obj_data.put('typkpi',i.typkpi);
                    obj_data.put('desc_typkpi',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
                    obj_data.put('kpides',i.kpides);
                    obj_data.put('target',i.target);
                    obj_data.put('mtrfinish',i.mtrfinish);-- #7252
                    obj_data.put('pctwgt',to_char(i.pctwgt,'fm990.00'));
                    obj_data.put('dtestart',to_char(i.targtstr,'dd/mm/yyyy'));
                    obj_data.put('dteend',to_char(i.targtend,'dd/mm/yyyy'));
                -- obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;  --flgpass
        end loop; --c1
    end if; --v_flgdata


    if isInsertReport then
      obj_data.put('item1','DETAIL');
      insert_ttemprpt(obj_data);
    end if;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TKPIEMP');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end;
  -----


  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

procedure gen_detail_table(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    flgpass     	boolean := false;
    v_seq           number :=0;
    v_row           number := 0;
cursor c1 is
    select  dteyreap,numtime,codempid,codkpi,planno,plandes,targtstr,targtend
      from  tkpiemppl
     where  dteyreap   =   b_index_dteyreap
       and  numtime    =   b_index_numtime
       and  codempid   =   b_index_codempid
       and  codkpi     =   b_index_codkpino
       order by planno;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    obj_data := json_object_t();
    if v_flgdata = 'Y' then
        v_seq :=0;
        for i in c1 loop
            --flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
          --  if flgpass then
                v_flgsecu := 'Y';
                v_seq := v_seq+1;
                v_rcnt := v_rcnt+1;
                obj_data.put('coderror', '200');
                obj_data := json_object_t();
                obj_data.put('#',i.planno);
                obj_data.put('plan',i.plandes);
                obj_data.put('dtestart',to_char(i.targtstr,'dd/mm/yyyy'));
                obj_data.put('dteend',to_char(i.targtend,'dd/mm/yyyy'));
                obj_row.put(to_char(v_rcnt-1),obj_data);
           -- end if;  --flgpass

                if isInsertReport then
                  obj_data.put('item1','TABLE');
                  obj_data.put('item2',b_index_codempid);
                  obj_data.put('item3',b_index_codkpino);
                  obj_data.put('item4',v_seq);
                  obj_data.put('item5',i.plandes);
                  obj_data.put('item6',to_char(i.targtstr,'dd/mm/yyyy'));
                  obj_data.put('item7',to_char(i.targtend,'dd/mm/yyyy'));
                  insert_ttemprpt_table(obj_data);
                end if;
        end loop; --c1
    end if; --v_flgdata
    json_str_output := obj_row.to_clob;
  end;
--

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      gen_detail(json_output);
      gen_detail_table(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  ------
  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq        number := 0;
    v_image         tempimge.namimage%type;
    v_folder        tfolderd.folder%type;
    v_has_image     varchar2(1) := 'N';
    v_image2        tempimge.namimage%type;
    v_folder2       tfolderd.folder%type;
    v_has_image2    varchar2(1) := 'N';
    v_codreview     temploy1.codempid%type := '';
    v_codempid      varchar2(100 char) := '';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_item1         ttemprpt.item1%type;
    v_item2         ttemprpt.item2%type;
    v_item3         ttemprpt.item3%type;
    v_item4         ttemprpt.item4%type;
    v_item5         ttemprpt.item5%type;
    v_item6         ttemprpt.item6%type;
    v_item7         ttemprpt.item7%type;
    v_item8         ttemprpt.item8%type;
    v_item9         ttemprpt.item9%type;
    v_item10        ttemprpt.item10%type;
    v_item11        ttemprpt.item11%type;
    v_item12        ttemprpt.item12%type;
    v_item13        ttemprpt.item13%type;
    v_item14        ttemprpt.item14%type;
    v_item15        ttemprpt.item15%type;

  begin
        v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
        v_item2       := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
        v_item3       := nvl(hcm_util.get_string_t(obj_data, 'codkpi'), '');
        v_item4       := nvl(hcm_util.get_string_t(obj_data, 'dteyear'), '');
        v_item5       := nvl(hcm_util.get_string_t(obj_data, 'numseq'), '');
        v_item6       := nvl(hcm_util.get_string_t(obj_data, 'codkpi')||' - '||hcm_util.get_string_t(obj_data, 'kpides'), '');
        v_item7       := nvl(hcm_util.get_string_t(obj_data, 'typkpi') ||' - '||hcm_util.get_string_t(obj_data, 'desc_typkpi'), '');
        v_item8       := nvl(hcm_util.get_string_t(obj_data, 'kpides'), '');
        v_item9       := nvl(hcm_util.get_string_t(obj_data, 'target'), '');
        v_item10      := nvl(hcm_util.get_string_t(obj_data, 'mtrfinish'), '');
        v_item11      := nvl(hcm_util.get_string_t(obj_data, 'pctwgt'), '');
        v_item12      := nvl(hcm_util.get_string_t(obj_data, 'dtestart'), '');
        v_item13      := nvl(hcm_util.get_string_t(obj_data, 'dteend'), '');

    if v_item4 is not null then
       v_item4 := hcm_util.get_year_buddhist_era(to_char(v_item4));
    end if;

    if v_item12 is not null then
       v_item12 := hcm_util.get_date_buddhist_era(to_date(v_item12,'dd/mm/yyyy'));
    end if;

    if v_item13 is not null then
       v_item13 := hcm_util.get_date_buddhist_era(to_date(v_item13,'dd/mm/yyyy'));
    end if;

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

       begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image
          from tempimge
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_image := null;
      end;

      if v_image is not null then
        v_image      := get_tsetup_value('PATHWORKPHP')||v_image;
        v_has_image   := 'Y';
      end if;

      begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image2
          from tempimge
         where codempid = v_codreview;
      exception when no_data_found then
        v_image2 := null;
      end;

      if v_image2 is not null then
        v_image2      := get_tsetup_value('PATHWORKPHP')||v_image2;
        v_has_image2   := 'Y';
      end if;

      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10, item11
               ,item12, item13, item14, item15
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             ,v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, to_char(v_item10,'fm9,999,999,999,990.00'), v_item11
             ,v_item12, v_item13, v_has_image, v_image
        );
      exception when others then
        null;
      end;
  end;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq      number := 0;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;

  begin
    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := nvl(hcm_util.get_string_t(obj_data, 'item2'), '');
    v_item3       := nvl(hcm_util.get_string_t(obj_data, 'item3'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'item4'), '');
    v_item5       := nvl(hcm_util.get_string_t(obj_data, 'item5'), '');
    v_item6       := nvl(hcm_util.get_string_t(obj_data, 'item6'), '');
    v_item7       := nvl(hcm_util.get_string_t(obj_data, 'item7'), '');
    v_item8       := nvl(hcm_util.get_string_t(obj_data, 'item8'), '');
    v_item9       := nvl(hcm_util.get_string_t(obj_data, 'item9'), '');
    v_item10      := nvl(hcm_util.get_string_t(obj_data, 'item10'), '');

    if v_item6 is not null then
       v_item6 := hcm_util.get_date_buddhist_era(to_date(v_item6,'dd/mm/yyyy'));
    end if;

    if v_item7 is not null then
       v_item7 := hcm_util.get_date_buddhist_era(to_date(v_item7,'dd/mm/yyyy'));
    end if;


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

      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             , v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, v_item10
        );
      exception when others then
        null;
      end;
  end;

  -----
end;

/

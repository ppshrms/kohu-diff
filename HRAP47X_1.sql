--------------------------------------------------------
--  DDL for Package Body HRAP47X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP47X" is
-- last update: 14/09/2020 12:00
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken              := hcm_secur.get_v_chken;
        json_obj            := json_object_t(json_str);
        --global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_v_codempid');
       --b_index
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_numperiod');
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
        --screen
        b_index_codpos       := hcm_util.get_string_t(json_obj,'p_codpos');
        b_index_codkpino     := hcm_util.get_string_t(json_obj,'p_kpi_code');
        b_index_kpides       := hcm_util.get_string_t(json_obj,'p_kpides');
        b_index_target       := hcm_util.get_string_t(json_obj,'p_target');
        b_index_pctwgt       := hcm_util.get_string_t(json_obj,'p_pctwgt');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --
  procedure get_data1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_output);
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
    flgpass     	boolean;
    v_codpos        temploy1.codpos%type;

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
        and    codempid   = b_index_codempid
         ;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
-- mode codcomp
    if  b_index_codcomp is not null then


                v_chksecu := '2';
                for i in c1 loop
                    v_flgdata := 'Y';--User37 #7264 26/11/2021 
                    flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
                    if flgpass then
                        v_flgsecu := 'Y';
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('dteyreap',i.dteyreap);
                        obj_data.put('numtime',i.numtime);
                        obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                        obj_data.put('desc_codpos',get_tpostn_name(b_index_codpos,global_v_lang));
                        obj_data.put('objective',i.objective);
--                     obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                 end loop;
                   --<<User37 #7264 26/11/2021 
                   if v_flgdata = 'N' then
                      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBJDEP');
                      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                    elsif v_flgsecu = 'N' then
                      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                    else
                      json_str_output := obj_data.to_clob;
                    end if;
                   --json_str_output := obj_data.to_clob;
                   -->>User37 #7264 26/11/2021 


    /* --<< user25 Date : 14/09/2021  3. AP Module #4324
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
                        obj_data.put('desc_codpos',get_tpostn_name(b_index_codpos,global_v_lang));
                        obj_data.put('objective',i.objective);
                    -- obj_row.put(to_char(v_rcnt-1),obj_data);
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
    */ -->> user25 Date : 14/09/2021  3. AP Module #4324
-- mode codempid
    else
                v_chksecu := '2';
                for j in c2 loop
                   v_flgdata := 'Y';--User37 #7264 26/11/2021 
                   flgpass := secur_main.secur3(j.codcomp,j.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
                    if flgpass then
                        v_flgsecu := 'Y';
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('dteyreap',j.dteyreap);
                        obj_data.put('numtime',j.numtime);
                        obj_data.put('desc_codcomp',get_tcenter_name(j.codcomp,global_v_lang));

                        begin
                            select codpos
                              into v_codpos
                              from temploy1
                             where codempid  =  j.codempid
                               and rownum   <=  1;
                            exception when no_data_found then
                                v_codpos := null;
                        end;
                        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
                        obj_data.put('objective',j.objective);
                    -- obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
                end loop;
                --<<User37 #7264 26/11/2021 
                if v_flgdata = 'N' then
                  param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TOBJEMP');
                  json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                elsif v_flgsecu = 'N' then
                  param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                  json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                else
                  json_str_output := obj_data.to_clob;
                end if;
                --json_str_output := obj_data.to_clob;
                -->>User37 #7264 26/11/2021 
    /* --<< user25 Date : 14/09/2021  3. AP Module #4324
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
                        obj_data.put('dteyreap',j.dteyreap);
                        obj_data.put('numtime',j.numtime);
                        obj_data.put('desc_codcomp',get_tcenter_name(j.codcomp,global_v_lang));

                        begin
                            select codpos
                              into v_codpos
                              from temploy1
                             where codempid  =  j.codempid
                               and rownum   <=  1;
                            exception when no_data_found then
                                v_codpos := null;
                        end;
                        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
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
     */ -->> user25 Date : 14/09/2021  3. AP Module #4324
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
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	boolean;
    v_pctwgt_comp   number:=0;
    v_pctwgt_emp    number:=0;

cursor c1 is
    select dteyreap,numtime,codempid,typkpi,codkpi,kpides,target,mtrfinish,pctwgt,codcomp, achieve, codpos
      from tkpiemp
     where  dteyreap   =    b_index_dteyreap
       and  numtime    =    b_index_numtime
       and  codcomp   like  b_index_codcomp||'%'
       and  nvl(codpos,'#####') = nvl(b_index_codpos,nvl(codpos,'#####'))
       and  codempid  =     nvl(b_index_codempid,codempid)
       order by codempid,decode(typkpi,'D',1,'J',2,'I',3),codkpi;

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
                 flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                 if flgpass then
                    v_flgsecu := 'Y';
                    v_rcnt := v_rcnt+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('image',get_emp_img(i.codempid));
                    obj_data.put('codempid',i.codempid);
                    obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                    obj_data.put('kpi_type',get_tlistval_name('TYPKPI',i.typkpi,global_v_lang));
--                    obj_data.put('kpi_code',i.codkpi);--<< user25 Date : 14/09/2021  3. AP Module #4324
                    obj_data.put('kpicode',i.codkpi);--<< user25 Date : 14/09/2021  3. AP Module #4324
                    obj_data.put('description',i.kpides);
                    obj_data.put('target',i.target);
                    obj_data.put('value',i.pctwgt);
                    obj_data.put('work',i.achieve);
                    obj_data.put('value2',i.mtrfinish);
                    obj_data.put('codpos',i.codpos);
                    obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
                    ---  adjust
                    obj_data.put('dteyreap',b_index_dteyreap);
                    obj_data.put('numtime',b_index_numtime);
                    obj_row.put(to_char(v_rcnt-1),obj_data);
                  end if;  --flgpass1-comp
                end if;  --flgpass2-codemp
        end loop; --c1
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

  procedure get_data3(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data3(json_str_output);
        --delete
        param_msg_error := null;
        v_numseq := 1;
        begin
          delete from ttemprpt
           where codempid = global_v_codempid
             and codapp   = 'HRAP47X';
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
---------

  procedure gen_data3(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	boolean;
    v_codempid      varchar2(40);
    v_codkpi        varchar2(4);
    v_tot_value     number :=0;

    v_descwork      tappkpimth.descwork%type;
    v_kpivalue      tappkpimth.kpivalue%type;
    v_dtereview     tappkpimth.dtereview%type;
    v_codreview     tappkpimth.codreview%type;
    v_commtimpro    tappkpimth.commtimpro%type;
    v_chk           number:=0;

 begin
    obj_row := json_object_t();
     begin
        select  count(*)
        into    v_chk
          from  tappkpimth
         where  codempid   =    b_index_codempid
           and  dteyreap   =    b_index_dteyreap
           and  numtime    =    b_index_numtime
           and  codkpi     =    b_index_codkpino;
    end;

if v_chk > 0 then
    v_flgdata := 'Y';
end if;

if v_flgdata = 'Y' then
   flgpass := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if flgpass then
      v_flgsecu := 'Y';
       v_tot_value := 0;
            for j in 1..12 loop
                      begin
                        select  descwork ,kpivalue,dtereview,codreview,commtimpro
                          into  v_descwork ,v_kpivalue,v_dtereview,v_codreview,v_commtimpro
                          from  tappkpimth
                         where  codempid   =    b_index_codempid
                           and  dteyreap   =    b_index_dteyreap
                           and  numtime    =    b_index_numtime
                           and  codkpi     =    b_index_codkpino
                           and  dtemonth   =    j;
                           exception when no_data_found then
                               v_descwork   := null;
--                               v_kpivalue   := 0;  --<<user25 Date: 14/09/2021 3. AP Module #4324
                               v_kpivalue   := null; --<<user25 Date: 14/09/2021 3. AP Module #4324
                               v_dtereview  := null;
                               v_codreview  := null;
                               v_commtimpro := null;
                        end;
                        v_tot_value := nvl(v_tot_value,0)+nvl(v_kpivalue,0);
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('index_codempid',b_index_codempid);
                        obj_data.put('index_descemp',get_temploy_name(b_index_codempid,global_v_lang));
                        obj_data.put('index_codpos',b_index_codpos||'-'||get_tpostn_name(b_index_codpos,global_v_lang));
                        obj_data.put('index_kpides',b_index_codkpino||'-'||b_index_kpides);
                        obj_data.put('index_target',b_index_target);
                        obj_data.put('index_value',b_index_pctwgt);
                        obj_data.put('month',get_tlistval_name('NAMMTHABB',j,global_v_lang));
                        obj_data.put('result',v_descwork);
                        obj_data.put('value',v_kpivalue);
                        obj_data.put('dtereview',to_char(v_dtereview,'dd/mm/yyyy'));
                        obj_data.put('codempid',v_codreview);
                        obj_data.put('desc_codempid',get_temploy_name(v_codreview,global_v_lang));
                        obj_data.put('improvements',v_commtimpro);
                        obj_row.put(to_char(v_rcnt-1),obj_data);
            end loop;  --month
     end if;  --flgpass
       ---total---------
                    v_rcnt := v_rcnt+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('index_codempid','');
                    obj_data.put('index_descemp','');
                    obj_data.put('index_codpos','');
                    obj_data.put('index_kpides','');
                    obj_data.put('index_target','');
                    obj_data.put('index_value','');
                    obj_data.put('month',get_label_name('HRAP47X2', global_v_lang, '130'));
                    obj_data.put('result','');
                    obj_data.put('value',v_tot_value);
                    obj_data.put('dtereview','');
                    obj_data.put('codempid','');
                    obj_data.put('desc_codempid','');
                    obj_data.put('improvements','');
                    obj_row.put(to_char(v_rcnt-1),obj_data);
end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappkpimth');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  -----

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAP47X';
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
    v_desc           varchar2(400 char);
    flgpass          boolean;
    v_flgsecu        varchar2(1);
    v_chk           number:=0;
    v_kpivalue      tappkpimth.kpivalue%type;

begin
     begin
        select  count(*)
        into    v_chk
          from  tappkpimth
         where  codempid   =    b_index_codempid
           and  dteyreap   =    b_index_dteyreap
           and  numtime    =    b_index_numtime
           and  codkpi     =    b_index_codkpino;
    end;

    if v_chk > 0 then
        v_flgdata := 'Y';
    end if;

    if v_flgdata = 'Y' then
        flgpass := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if flgpass then
          v_flgsecu := 'Y';
            param_msg_error := null;
            v_item1  := '';
            v_item14 := '';
            v_item31 := get_label_name('HRAP47X3', global_v_lang, '10');
    --======================================================
                for j in 1..12 loop
                          begin
                            select  kpivalue
                              into  v_kpivalue
                              from  tappkpimth
                             where  codempid   =    b_index_codempid
                               and  dteyreap   =    b_index_dteyreap
                               and  numtime    =    b_index_numtime
                               and  codkpi     =    b_index_codkpino
                               and  dtemonth   =    j;
                               exception when no_data_found then
                                   v_kpivalue   := 0;
                            end;
                            -----แกน y -----
                            v_item7  := '';
                            v_item8  := '';
                            v_item9  := get_label_name('HRAP47X3', global_v_lang, '20'); --'คะแนน KPI';
                            -----แกน x -----
                            v_item4  := j;
                            v_item5  := get_tlistval_name('NAMMTHABB',j,global_v_lang);
                            v_item6  := b_index_dteyreap;
                           -----ค่าข้อมูล -----
                            v_item10 := v_kpivalue;

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
                end loop; -- loop j
          end if;-- if flgpass
        commit;
    end if;-- if flgdata
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  ------
end;

/

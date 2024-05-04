--------------------------------------------------------
--  DDL for Package Body HRAPS7X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAPS7X" is
-- last update: 20/09/2020 23:53
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken              := hcm_secur.get_v_chken;
        json_obj             := json_object_t(json_str);
        --global
        global_v_coduser     := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd     := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang        := hcm_util.get_string_t(json_obj,'p_lang');
       --b_index
        b_index_codcomp      := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_jobgrade     := hcm_util.get_string_t(json_obj,'p_jobgrade');

        --screen
        b_index_amtsal_st     := to_number(hcm_util.get_string_t(json_obj,'p_amtsal_st'));
        b_index_amtsal_en     := to_number(hcm_util.get_string_t(json_obj,'p_amtsal_en'));
        b_index_amt_maxsal    := to_number(hcm_util.get_string_t(json_obj,'p_amt_maxsal'));

        p_ranksalmin    := to_number(hcm_util.get_string_t(json_obj,'p_ranksalmin'));
        p_ranksalmax    := to_number(hcm_util.get_string_t(json_obj,'p_ranksalmax'));

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --
  procedure get_index1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data1(json_str in clob,json_str_output out clob) is
    json_obj        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_min          number := 0;
    v_max          number := 0;
    v_tpm_count     number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_flgsal        varchar2(1 char) := 'N';--nut 
    v_month         varchar2(2 char);
    v_chksecu       varchar2(1 char);
    flgpass         boolean := false;
    v_amtmaxsa      tsalstr.amtmaxsa%type;
    v_emp           number := 0;
    v_all_emp           number := 0;
    v_codcompy      tcenter.codcompy%type;

    v_emp_tot       number := 0;
    v_job_grade     temploy1.jobgrade%type := '####';
    v_sumhur        number:= 0;
    v_sumday        number:= 0;
    v_summth        number:= 0;

    type t_number is table of number index by binary_integer;
    v_amtsal_st t_number;
    v_amtsal_en t_number;
    b_index_perc_st t_number;
    b_index_perc_en t_number;
    v_chk_min varchar2(1 char) := 'N';

    cursor c1 is
      select  count(a.codempid) cs_emp ,jobgrade
        from  temploy1 a, temploy3 b
       where  a.codcomp     like    b_index_codcomp||'%'
         and  a.jobgrade    =       nvl(b_index_jobgrade,a.jobgrade)
         and  a.staemp      in      ('1','3')
         and a.codempid  = b.codempid
         and ((v_chksecu = 1 )
             or (v_chksecu = '2' and exists (select codcomp
                                               from tusrcom x
                                              where x.coduser = global_v_coduser
                                                and a.codcomp like a.codcomp||'%')
        and a.numlvl between global_v_zminlvl and global_v_zwrklvl))
     group by a.jobgrade
     having count(a.codempid) > 0
     order by a.jobgrade;

    cursor c2_cntemp(pc_jobgrade varchar2) is
      select  a.codempid, a.codempmt, a.dteempmt, a.dteefpos,
              stddec(b.amtincom1,b.codempid,v_chken) amtincom1,
              a.codcomp
        from  temploy1 a, temploy3 b
       where  a.codcomp     like b_index_codcomp||'%'
         and  a.jobgrade    = pc_jobgrade
         and  a.staemp      in ('1','3')
         and  a.codempid    = b.codempid
         and  exists (select codcomp
                        from tusrcom x
                       where x.coduser = global_v_coduser
                         and a.codcomp like a.codcomp||'%')
         and a.numlvl between global_v_zminlvl and global_v_zwrklvl;
 begin
    obj_row     := json_object_t();
    json_obj    := json_object_t(json_str);
    v_codcompy  := hcm_util.get_codcomp_level(b_index_codcomp,1);
    for i in 1..5 loop
        b_index_perc_st(i)     := hcm_util.get_string_t(json_obj,'p_rangemin'||i);
        b_index_perc_en(i)     := hcm_util.get_string_t(json_obj,'p_rangemax'||i);
    end loop;

    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;

     if v_flgdata = 'Y' then
        v_chksecu := '2';
          for i in c1 loop
                v_flgdata := 'Y';
               flgpass := secur_main.secur7(b_index_codcomp,global_v_coduser);
                if flgpass then
                    v_flgsecu := 'Y';
                    ----------------

                      begin
                            select      nvl(amtmaxsa,0) amtmaxsa
                              into      v_amtmaxsa
                              from      tsalstr
                             where      codcompy  = v_codcompy
                               and      jobgrade  = i.jobgrade
                               and      dteyreap  = (select  max(dteyreap)
                                                       from  tsalstr
                                                      where  codcompy  = v_codcompy
                                                      and    dteyreap <= to_char(sysdate,'yyyy'));
                            exception when no_data_found then
                                v_amtmaxsa := 0;
                        end;
                        ----------------------
                     if v_amtmaxsa <> 0 then
                        if nvl(v_job_grade,'####') <> i.jobgrade then
                            if v_all_emp >0 then
                              obj_data := json_object_t();
                              obj_data := hcm_util.get_json_t(obj_row,to_char(v_tpm_count));
                              obj_data.put('qtyemp',to_char(v_all_emp,'fm9,999,999,990'));
                              obj_data.put('ranksalmin',nvl(v_min,0));
                              obj_data.put('ranksalmax',nvl(v_max,0));
                            end if;
                            v_job_grade := i.jobgrade;
                            v_all_emp := 0;
                            v_chk_min := 'N';
                            for k in 1..5 loop
                                v_amtsal_st(k) :=  ((b_index_perc_st(k))/100) * v_amtmaxsa;
                                v_amtsal_en(k) :=  ((b_index_perc_en(k))/100) * v_amtmaxsa;

--                                begin
--                                    select  count(a.codempid)
--                                      into  v_emp
--                                      from  temploy1 a, temploy3 b
--                                     where  a.codcomp     like    b_index_codcomp||'%'
--                                       and  a.jobgrade    = i.jobgrade
--                                       and  a.staemp      in ('1','3')
--                                       and  a.codempid    = b.codempid
--                                         and  get_sal(b.codempid,v_chken,'M')  between    v_amtsal_st(k)
--                                                                                    and   v_amtsal_en(k)
--                                      and  exists (select codcomp
--                                                      from tusrcom x
--                                                     where x.coduser = global_v_coduser
--                                                       and a.codcomp like a.codcomp||'%')
--                                        and a.numlvl between global_v_zminlvl and global_v_zwrklvl
--                                        ;
--                                end;
                                v_emp := 0;
                                for x in c2_cntemp(i.jobgrade) loop
                                  get_wage_income( get_codcompy(x.codcomp),x.codempmt,
                                                   x.amtincom1, 0,
                                                   0, 0,
                                                   0, 0,
                                                   0, 0,
                                                   0, 0,
                                                   v_sumhur,v_sumday,v_summth);-- เอาเเค่ รายได้ตัวแรก
                                  if v_summth between v_amtsal_st(k) and v_amtsal_en(k) then
                                    v_emp := v_emp + 1;
                                  end if;
                                end loop;

                                if b_index_perc_st(k) is not null and nvl(v_emp,0) > 0 then
                                   -- v_rcnt := v_rcnt+1;
                                    v_flgsal := 'Y';--nut 
                                    obj_data := json_object_t();
                                    obj_data.put('coderror', '200');
                                    obj_data.put('jobgrade',i.jobgrade);
                                    obj_data.put('detail',get_tcodec_name('TCODJOBG',i.jobgrade, global_v_lang));
                                    v_amtsal_st(k) :=  ((b_index_perc_st(k))/100) * v_amtmaxsa;
                                    v_amtsal_en(k) :=  ((b_index_perc_en(k))/100) * v_amtmaxsa;
                                    obj_data.put('ragesaldefne',v_amtsal_st(k));
                                    obj_data.put('leveldefind',v_amtsal_en(k));

                                    obj_data.put('ranksalmin',((b_index_perc_st(k))/100) * v_amtmaxsa);
                                    obj_data.put('ranksalmax',((b_index_perc_en(k))/100) * v_amtmaxsa);
                                    obj_data.put('amtmaxsa',nvl(v_amtmaxsa,0));

                                    ---------------
                                        obj_data.put('qtyempragesal',to_char(v_emp,'fm9,999,999,990'));

                                        obj_row.put(to_char(v_rcnt),obj_data);
                                        if  v_emp > 0  then
                                        --  v_min := v_amtsal_st(k);
--                                          v_max := v_amtsal_en(k) ;
                                             v_all_emp := nvl(v_all_emp,0) + v_emp;

                                            if v_chk_min <> 'Y' then
                                                v_chk_min := 'Y';
                                                v_min := ((b_index_perc_st(k))/100) * v_amtmaxsa;
                                                v_max := ((b_index_perc_en(k))/100) * v_amtmaxsa ;
                                                v_tpm_count := v_rcnt;
                                            else
                                                v_max := ((b_index_perc_en(k))/100) * v_amtmaxsa ;
                                            end if;
                                        end if;
                                         v_rcnt := v_rcnt+1;
                                end if;--b_index_perc_st(k) is not null
                            end loop;--loop k
                        end if;

                        if v_all_emp <> 0 then
                            obj_data := json_object_t();
                            obj_data := hcm_util.get_json_t(obj_row,to_char(v_tpm_count));
                            obj_data.put('qtyemp',nvl(v_all_emp,0));
                            obj_data.put('ranksalmin',nvl(v_min,0));
                            obj_data.put('ranksalmax',nvl(v_max,0));
                        end if;
                        ----
                    end if; -- if v_amtmaxsa <> 0
               end if; -- if flgpass
            end loop;--loop i
        end if;--v_flgdata
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TEMPLOY1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    --<<nut 
    elsif v_flgsal = 'N' then
      param_msg_error := get_error_msg_php('AP0070',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    -->>nut 
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --

  procedure get_index2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data2(json_str_input, json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data2(json_str in clob, json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_obj        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number:= 0;
    v_year          number:= 0;
    v_month         number:= 0;
    v_day           number:= 0;
    flgpass     	boolean;
    v_dteeffec      date;
    v_sumhur        number:= 0;
    v_sumday        number:= 0;
    v_summth        number:= 0;
    v_amtmaxsa      tsalstr.amtmaxsa%type;

    type t_number is table of number index by binary_integer;
    v_amtsal_st       t_number;
    v_amtsal_en       t_number;
    b_index_perc_st   t_number;
    b_index_perc_en   t_number;
    cursor c1 is
      select  a.codempid, a.codempmt, a.dteempmt, a.dteefpos,
              stddec(b.amtincom1,b.codempid,v_chken) amtincom1,
--              stddec(b.amtincom2,b.codempid,v_chken)amtincom2,
--              stddec(b.amtincom3,b.codempid,v_chken)amtincom3,
--              stddec(b.amtincom4,b.codempid,v_chken)amtincom4,
--              stddec(b.amtincom5,b.codempid,v_chken)amtincom5,
--              stddec(b.amtincom6,b.codempid,v_chken)amtincom6,
--              stddec(b.amtincom7,b.codempid,v_chken)amtincom7,
--              stddec(b.amtincom8,b.codempid,v_chken)amtincom8,
--              stddec(b.amtincom9,b.codempid,v_chken)amtincom9,
--              stddec(b.amtincom10,b.codempid,v_chken)amtincom10,
              codcomp
        from  temploy1 a, temploy3 b
       where  codcomp     like    b_index_codcomp||'%'
         and  a.jobgrade  = b_index_jobgrade
         and  a.staemp    in ('1','3')
         and  a.codempid  = b.codempid
--         and  get_sal(b.codempid,v_chken,'M')   between  to_number(b_index_amtsal_st)
--                                                     and  to_number(b_index_amtsal_en)
         and ((v_chksecu = 1 )
             or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                   where x.coduser = global_v_coduser
                     and a.codcomp like a.codcomp||'%')
         and a.numlvl between global_v_zminlvl and global_v_zwrklvl))
    order by  a.codempid;


 begin
    obj_row := json_object_t();
    json_obj    := json_object_t(json_str);
    b_index_amtsal_st := p_ranksalmin;
    b_index_amtsal_en := p_ranksalmax;
    for i in 1..5 loop
        b_index_perc_st(i)     := hcm_util.get_string_t(json_obj,'p_rangemin'||i);
        b_index_perc_en(i)     := hcm_util.get_string_t(json_obj,'p_rangemax'||i);
    end loop;

    begin
      select amtmaxsa
        into v_amtmaxsa
        from tsalstr
       where codcompy = b_index_codcomp
         and dteyreap = (select max(dteyreap)
                           from tsalstr
                          where codcompy = b_index_codcomp )
         and jobgrade = b_index_jobgrade;
    exception when no_data_found then
      v_amtmaxsa := 0;
    end;

    v_chksecu := '1';
    for i in c1 loop
      if get_sal(i.codempid,v_chken,'M') between b_index_amtsal_st and b_index_amtsal_en then
        v_flgdata := 'Y';
        exit;
      end if;
    end loop;

    if v_flgdata = 'Y' then
        v_chksecu := '2';
      for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(b_index_codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            get_wage_income(get_codcompy(i.codcomp),i.codempmt,
                             i.amtincom1, 0,
                             0, 0,
                             0, 0,
                             0, 0,
                             0, 0,
                             v_sumhur,v_sumday,v_summth);-- เอาเเค่ รายได้ตัวแรก
          if v_summth between b_index_amtsal_st and b_index_amtsal_en then
              v_flgsecu := 'Y';
              v_rcnt := v_rcnt+1;
              obj_data := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('desc_codcomp',get_tcenter_name(b_index_codcomp,global_v_lang));
              obj_data.put('jobgrade',b_index_jobgrade||'-'||get_tcodec_name('TCODJOBG',b_index_jobgrade,global_v_lang));
              obj_data.put('ragesaldefne',b_index_amtsal_st);
              obj_data.put('leveldefind', b_index_amtsal_en);
              obj_data.put('codempid',i.codempid);
              obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
--                  get_wage_income(get_codcompy(i.codcomp),i.codempmt,
--                                   i.amtincom1, 0,
--                                   0, 0,
--                                   0, 0,
--                                   0, 0,
--                                   0, 0,
--                                   v_sumhur,v_sumday,v_summth);-- เอาเเค่ รายได้ตัวแรก

              obj_data.put('amtsal',v_summth);
--              obj_data.put('amtmaxsa',b_index_amt_maxsal);
              obj_data.put('amtmaxsa',100);
              if b_index_amt_maxsal = 0 then
                  obj_data.put('pctceisal', ' ');
              else
                  obj_data.put('pctceisal',to_char((v_summth/b_index_amt_maxsal)*100,'fm990.00'));
              end if;
              get_service_year(i.dteefpos,sysdate,'Y',v_year,v_month,v_day);
              obj_data.put('agepos',to_char(v_year,'fm90')||'.'||to_char(v_month,'fm90')||'.'||to_char(v_day,'fm90'));
          ----------------
              begin
                  Select  max(dteeffec)
                    into  v_dteeffec
                    from  ttmovemt
                   where  codempid = i.codempid
                     and  stddec(amtincadj1,codempid,v_chken) > 0
                     and  Staupd in ('C','U');
                  exception when no_data_found then
                   v_dteeffec := null;
              end;
          ----------------
              obj_data.put('dteupsalst',to_char(v_dteeffec,'dd/mm/yyyy'));
              obj_row.put(to_char(v_rcnt-1),obj_data);
          end if; -- v_summth between b_index_amtsal_st and b_index_amtsal_en
        end if;  -- flgpass
      end loop;  --loop i
    end if; --v_flgdata
    json_str_output := obj_row.to_clob;
  end;
  --
end;

/

--------------------------------------------------------
--  DDL for Package Body HRRP2FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2FX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteyear     := hcm_util.get_string_t(json_obj,'p_year');
    b_index_comlevel    := hcm_util.get_string_t(json_obj,'p_comlevel');
    b_index_group       := hcm_util.get_string_t(json_obj,'p_group');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure check_index is
    v_codpos            tpostn.codpos%type;
  begin

    if b_index_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if b_index_comlevel is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if b_index_group is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';

    v_col           number := 0;

    cursor c1 is
      select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, ----a.dtemonth,a.numseq,
             b.codpos datagroup,get_tpostn_name(b.codpos,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12 
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODPOS'
         and b.codpos       is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.codpos    

    union all  
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.jobgrade datagroup,get_tcodec_name('TCODJOBG',b.jobgrade,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'JOBGRADE'
         and b.jobgrade     is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.jobgrade
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.codempmt datagroup,get_tcodec_name('TCODEMPL',b.codempmt,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODEMPMT'
         and b.codempmt     is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.codempmt
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.typemp datagroup,get_tcodec_name('TCODCATG',b.typemp,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'TYPEMP'
         and b.typemp       is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.typemp
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             c.codsex datagroup,get_tlistval_name('NAMSEX',c.codsex,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODSEX'
         and c.codsex       is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             c.codsex
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             get_tgrppos(hcm_util.get_codcomp_level(a.codcomp,1),b.codpos) datagroup,get_tcodec_name('TCODGPOS',get_tgrppos(hcm_util.get_codcomp_level(a.codcomp,1),b.codpos),global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODGRPOS'
         and get_tgrppos(hcm_util.get_codcomp_level(a.codcomp,1),b.codpos) is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             get_tgrppos(hcm_util.get_codcomp_level(a.codcomp,1),b.codpos)
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             to_char(b.numlvl) datagroup,to_char(b.numlvl) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'NUMLVL'
         and b.numlvl       is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.numlvl
             
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.codbrlc datagroup,get_tcodec_name('TCODLOCA',b.codbrlc,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODBRLC'
         and b.codbrlc      is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.codbrlc
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.codedlv datagroup,get_tcodec_name('TCODEDUC',b.codedlv,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODEDLV'
         and b.codedlv      is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.codedlv
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.typpayroll datagroup,get_tcodec_name('TCODTYPY',b.typpayroll,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'TYPPAYROLL'
         and b.typpayroll   is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.typpayroll
    
    union all
    select hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel) codcomp_lv, 
             b.codcalen datagroup,get_tcodec_name('TCODWORK',b.codcalen,global_v_lang) desc_datagroup,
            sum(decode(dtemonth,1,1,0)) manpw1,
            sum(decode(dtemonth,2,1,0)) manpw2,
            sum(decode(dtemonth,3,1,0)) manpw3,
            sum(decode(dtemonth,4,1,0)) manpw4,
            sum(decode(dtemonth,5,1,0)) manpw5,
            sum(decode(dtemonth,6,1,0)) manpw6,
            sum(decode(dtemonth,7,1,0)) manpw7,
            sum(decode(dtemonth,8,1,0)) manpw8,
            sum(decode(dtemonth,9,1,0)) manpw9,
            sum(decode(dtemonth,10,1,0)) manpw10,
            sum(decode(dtemonth,11,1,0)) manpw11,
            sum(decode(dtemonth,12,1,0)) manpw12
        from tmanpwd a, tmanpwh b, temploy1 c
       where a.codempid     = b.codempid
         and a.numseq       = b.numseq
         and a.codempid     = c.codempid
         and a.codcomp      like b_index_codcomp||'%'
         and a.dteyear      = b_index_dteyear
         and b_index_group  = 'CODCALEN'
         and b.codcalen     is not null
         and c.staemp       <> '9'
         and a.numseq       = ( select max(x.numseq) 
                                  from tmanpwd x 
                                 where x.codempid = a.codempid
                                   and x.dteyear  = a.dteyear
                                   and x.dtemonth = a.dtemonth)
    group by hcm_util.get_codcomp_level(a.codcomp,b_index_comlevel),
             b.codcalen
--#3066    order by 2,4;
    order by 1,3;
--#3066
    
  begin
    obj_row := json_object_t();

    begin
        select 'Y'--substr(codcomp,1,b_index_comlevel)
        into   v_flgdata
        from   tmanpwd
        where  codcomp  like b_index_codcomp||'%'
        and    dteyear  = b_index_dteyear
        ----and    dtemonth = 1
        and    rownum   = 1;
    exception when no_data_found then 
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tmanpwd');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;
    end;
    for r1 in c1 loop
      v_flgdata := 'Y';
      --if true then -- check secur7
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        --obj_data.put('codcomp_lv', r1.codcomp_lv);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp_lv,global_v_lang));
        --obj_data.put('datagroup', r1.datagroup);
        obj_data.put('branchsex', r1.desc_datagroup);
        obj_data.put('jan', r1.manpw1);
        obj_data.put('feb', r1.manpw2);
        obj_data.put('mar', r1.manpw3);
        obj_data.put('apr', r1.manpw4);
        obj_data.put('may', r1.manpw5);
        obj_data.put('jun', r1.manpw6);
        obj_data.put('jul', r1.manpw7);
        obj_data.put('aug', r1.manpw8);
        obj_data.put('sep', r1.manpw9);
        obj_data.put('oct', r1.manpw10);
        obj_data.put('nov', r1.manpw11);
        obj_data.put('dec', r1.manpw12);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      --end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttalente');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;
  
  procedure get_list_comlevel(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_1 is
      select comlevel, decode(global_v_lang,'101', a.namcente,
                                            '102', a.namcentt,
                                            '103', a.namcent3,
                                            '104', a.namcent4,
                                            '105', a.namcent5) namecomlevel, qtycode
      from   tcompnyc a, tsetcomp b
      where  a.codcompy = hcm_util.get_codcomp_level(b_index_codcomp,1)
      and    a.comlevel = b.numseq
    order by a.comlevel;

  begin
    initial_value(json_str_input);
    
    obj_row := json_object_t();
    for r1 in c_1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', r1.comlevel);
      obj_data.put('namecomlevel', r1.namecomlevel);
      obj_data.put('qtycode', r1.qtycode);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    
    if v_rcnt = 0 then 
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('comlevel', '');
      obj_data.put('namecomlevel', '');
      obj_data.put('qtycode', '');

      obj_row.put(to_char(v_rcnt),obj_data);
    end if;
        json_str_output := obj_row.to_clob;
--     
    
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  
  procedure get_list_group(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_1 is
      select namfld codgroup,decode(global_v_lang,'101', nambrowe,
                                                  '102', nambrowt,
                                                  '103', nambrow3,
                                                  '104', nambrow4,
                                                  '105', nambrow5) namegroup
      from   treport2 
      where  codapp = 'HRRP2FX'
    order by numseq;

  begin
    initial_value(json_str_input);
    
    obj_row := json_object_t();
    for r1 in c_1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('group', r1.codgroup);
      obj_data.put('namegroup', r1.namegroup);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    
--    if v_rcnt = 0 then 
--        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'treport2');
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--     else
        json_str_output := obj_row.to_clob;
--     end if;
    
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  
end;

/

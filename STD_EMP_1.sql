--------------------------------------------------------
--  DDL for Package Body STD_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_EMP" AS

  procedure initial_value(json_str in clob) is
    json_obj      json_object_t;
  begin
    json_obj           := json_object_t(json_str);
    --global
    global_v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd   := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codempid   := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_mnuname    := hcm_util.get_string_t(json_obj,'p_mnuname');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure getdata_tab1(json_str_input in clob, json_str_output out clob) is
    v_codinst     varchar2(4 char);
    v_codminsb    varchar2(4 char);
    v_codedlv     varchar2(4 char);
    v_codmajsb    varchar2(4 char);
    v_yreex				number;
    v_mthex				number;
    v_dayex				number;
    v_yrebd				number;
    v_mthbd				number;
    v_daybd				number;
    v_yrelvl			number;
    v_mthlvl			number;
    v_daylvl			number;
    v_yrepos			number;
    v_mthpos			number;
    v_daypos			number;
    v_amth				number;
    v_amtd				number;
    v_amtm				number;
    v_amtinc1			number:=0;
    v_codcur 			varchar2(30 char);
    v_chken       varchar2(10 char) := hcm_secur.get_v_chken;
    v_salary      varchar2(4000 char);
    v_row         number := 0;
    v_codcomp     varchar2(4000 char);
    v_codpos      varchar2(4000 char);
    v_codjob      varchar2(4000 char);
    v_codempmt    varchar2(4000 char);
    v_typemp      varchar2(4000 char);
    v_typpayroll  varchar2(4000 char);
    v_dteempmt    varchar2(4000 char);
    v_numlvl      number;
    v_secur       boolean := false;
    v_namimage    varchar2(4000 char);
    v_empimgpath  varchar2(4000 char);

    v_codcompy    varchar2(10 char);
    v_currency    varchar2(100 char);
    v_unitcal1    tcontpmd.unitcal1%type;

    v_foldpath    varchar2(4000 char):='';
    v_flgtrn      tempimge.flgtrn%type;
    obj_row       json_object_t;
  cursor c1 is
    select *
    from temploy1
    where codempid = b_index_codempid;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
      for r1 in c1 loop
        v_row := v_row+1;
        v_secur := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_zupdsal = 'Y' then
          begin
            select	to_number(nvl(stddec(amtincom1,codempid,v_chken),0)),codcurr
            into 		v_amtinc1,v_codcur
            from 		temploy3
            where 	codempid = b_index_codempid;
          exception when no_data_found then
            v_salary := null;
          end;
          v_codcompy  := hcm_util.get_codcomp_level(r1.codcomp,'1');
          get_wage_income(v_codcompy,r1.codempmt,v_amtinc1,0,0,0,0,0,0,0,0,0,v_amth,v_amtd,v_amtm );
          v_amth	:= round(v_amth,2);
          v_amtd	:= round(v_amtd,2);
          v_amtm	:= round(v_amtm,2);

          --------weerayut 15/03/2018 redmine
          begin
            select  unitcal1
            into    v_unitcal1
            from    tcontpmd
            where   codcompy  = v_codcompy
            and     codempmt  = r1.codempmt
            and     dteeffec  = ( select  max(dteeffec)
                                  from    tcontpmd
                                  where   codcompy  = v_codcompy
                                  and     codempmt  = r1.codempmt
                                  and     dteeffec  <= trunc(sysdate));
          exception when no_data_found then
            v_unitcal1  := null;
          end;
          --------end------------------------
          v_currency  := get_tcodec_name('TCODCURR',v_codcur,global_v_lang);
          if v_unitcal1 = 'D' then
            v_salary := to_char(v_amtd,'fm999,999,990.90')||'  '||v_currency;
          else
            v_salary := to_char(v_amtm,'fm999,999,990.90')||'  '||v_currency;
          end if;
          ------------------------------------------------------------
        else
          v_salary	:= null;
        end if;
          ------------------------------------------------------------
        get_service_year(r1.dteempmt,nvl(r1.dteeffex,sysdate),'Y',v_yreex,v_mthex,v_dayex);
        get_service_year(r1.dteempdb,sysdate,'Y',v_yrebd,v_mthbd,v_daybd);
        get_service_year(r1.dteeflvl,nvl(r1.dteeffex,sysdate),'Y',v_yrelvl,v_mthlvl,v_daylvl);
        get_service_year(r1.dteefpos,nvl(r1.dteeffex,sysdate),'Y',v_yrepos,v_mthpos,v_daypos);

        begin
          select codinst, codminsb ,codedlv,codmajsb
          into   v_codinst, v_codminsb,v_codedlv,v_codmajsb
          from   teducatn
          where  codempid = b_index_codempid
          and    flgeduc = 1
          and    rownum  = 1 ;
        exception when no_data_found then
          v_codinst := null;
          v_codminsb := null;
        end;

        v_codcomp    := get_tcenter_name(r1.codcomp,global_v_lang);
        v_codpos     := get_tpostn_name(r1.codpos,global_v_lang);
        v_codjob     := get_tjobcode_name(r1.codjob,global_v_lang);
        v_codempmt   := get_tcodec_name('TCODEMPL',r1.codempmt,global_v_lang);
        v_typemp     := get_tcodec_name('TCODCATG',r1.typemp,global_v_lang);
        v_typpayroll := get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang);
        v_dteempmt   := to_char(r1.dteempmt,'dd/mm/yyyy');
        v_numlvl     := nvl(r1.numlvl,0);

        -- get employee image
        begin
          select folder into v_foldpath
            from tfolderd
           where codapp = 'HRPMC2E1';
        exception when no_data_found then
          v_foldpath := '';
        end;

        begin
          select namimage, flgtrn
            into v_namimage, v_flgtrn
            from tempimge
           where codempid = r1.codempid;
           v_empimgpath := hcm_util.get_pathphp('HRPMC2E')||v_namimage;
        exception when no_data_found then
          v_namimage := null;
        end;
        if v_foldpath is not null and v_namimage is not null and nvl(v_flgtrn,'N') = 'Y' then
          v_empimgpath := v_foldpath || '/' || v_namimage;
        else
          v_empimgpath := '';
        end if;
      end loop;
      if global_v_lang = 102 then
        v_dteempmt := to_char(add_months(to_date(v_dteempmt,'dd/mm/yyyy'),543*12),'dd/mm/yyyy');
      end if;
      obj_row := json_object_t();
      obj_row.put('coderror','200');
      obj_row.put('desc_coderror',' ');
      obj_row.put('httpcode','');
      obj_row.put('flg','');
      obj_row.put('empimg',v_empimgpath);
      obj_row.put('codcomp_desc',v_codcomp);
      obj_row.put('codpos_desc',v_codpos);
      obj_row.put('numlvl',v_numlvl);
      obj_row.put('codjob_desc',v_codjob);
      obj_row.put('codempmt_desc',v_codempmt);
      obj_row.put('typemp_desc',v_typemp);
      obj_row.put('typpayroll_desc',v_typpayroll);
      obj_row.put('unitcal1',v_unitcal1);
      obj_row.put('salary',v_salary);
      obj_row.put('dteempmt',v_dteempmt);
      obj_row.put('dteempmt_yr',v_yreex);
      obj_row.put('dteempmt_mt',v_mthex);
      obj_row.put('dteempdb_yr',v_yrebd);
      obj_row.put('dteempdb_mt',v_mthbd);
      obj_row.put('dteeflvl_yr',v_yrelvl);
      obj_row.put('dteeflvl_mt',v_mthlvl);
      obj_row.put('dteefpos_yr',v_yrepos);
      obj_row.put('dteefpos_mt',v_mthpos);
      obj_row.put('codedlv_desc',get_tcodec_name('TCODEDUC',v_codedlv,global_v_lang));
      obj_row.put('codmajsb_desc',get_tcodec_name('TCODMAJR',v_codmajsb,global_v_lang));
      obj_row.put('codinst_desc',get_tcodec_name('TCODINST',v_codinst,global_v_lang));
      obj_row.put('codminsb_desc',get_tcodec_name('TCODSUBJ',v_codminsb,global_v_lang));
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure getdata_tab2(json_str_input in clob, json_str_output out clob) is
    v_total         number := 0;
    v_row           number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
  cursor c1 is
    select numseq,desnoffi,deslstpos,to_char(dtestart,'dd/mm/yyyy')  dtestart ,to_char(dteend,'dd/mm/yyyy') dteend
    from   tapplwex
    where  numappl = b_index_codempid
    order by numseq;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();

    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for r1 in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('total',v_total);
        obj_data.put('numseq',r1.numseq);
        obj_data.put('desnoffi',r1.desnoffi);
        obj_data.put('deslstpos',r1.deslstpos);
        obj_data.put('dtestart',r1.dtestart);
        obj_data.put('dteend',r1.dteend);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if; --v_rcnt

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure getdata_tab3_table1(json_str_input in clob, json_str_output out clob) is
    v_total           number := 0;
    v_row             number := 0;
    v_chken           varchar2(10) := hcm_secur.get_v_chken;
    v_old_salary      number;
    v_amtincadj1_desc number;
    v_flgpass         boolean := false;
    v_secur           boolean := false;
    obj_row           json_object_t;
    obj_data          json_object_t;
  cursor c1 is
    select to_char(dteeffec,'dd/mm/yyyy') dteeffec,amtincom1,amtincadj1,
           codcomp, numlvl --weerayut 29/03/2018
    from   thismove
    where  codempid = b_index_codempid
    and    flgadjin = 'Y'
    order by dteeffec desc;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    v_secur := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);  -- user4 || 27/11/2018 || FMTU610031
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for r1 in c1 loop
        v_row := v_row+1;
        v_flgpass := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal); --weerayut 29/03/2018
        if v_zupdsal = 'Y' then -- user4 || 27/11/2018 || FMTU610031
          v_old_salary := to_number(nvl(stddec(r1.amtincom1,b_index_codempid,v_chken),0)) - to_number(nvl(stddec(r1.amtincadj1,b_index_codempid,v_chken),0));
          v_amtincadj1_desc := to_number(nvl(stddec(r1.amtincadj1,b_index_codempid,v_chken),0));
        else -- user4 || 27/11/2018 || FMTU610031
          v_old_salary 			:= null;
          v_amtincadj1_desc := null;
        end if;	  -- user4 || 27/11/2018 || FMTU610031
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('total',v_total);
        obj_data.put('dteeffec',r1.dteeffec);
        obj_data.put('old_salary',to_char(v_old_salary,'fm999,999,990.90'));
        obj_data.put('amtincadj1_desc',to_char(v_amtincadj1_desc,'fm999,999,990.90'));
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if; --v_rcnt
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure getdata_tab3_table2(json_str_input in clob, json_str_output out clob) is
    v_total           number := 0;
    v_row             number := 0;
    v_chken           varchar2(10) := hcm_secur.get_v_chken;
    obj_row           json_object_t;
    obj_data          json_object_t;
  cursor c1 is
    select dteyreap,grade
    from   tapprais
    where  codempid = b_index_codempid
    order by dteyreap desc;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for r1 in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('total',v_total);
        obj_data.put('dteyreap',r1.dteyreap);
        obj_data.put('grdap',r1.grade);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if; --v_rcnt

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure getdata_tab4(json_str_input in clob, json_str_output out clob) is
    v_total      number := 0;
    v_row        number := 0;
    v_desmist1   varchar2(4000 char);
    obj_row      json_object_t;
    obj_data     json_object_t;
  cursor c1 is
    select dteeffec,codpunsh,  dtestart , dteend
    from   thispun
    where  codempid = b_index_codempid
    order by dteeffec desc ;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for r1 in c1 loop
        begin
          select desmist1 into v_desmist1
          from thismist
          where codempid = b_index_codempid
            and dteeffec = r1.dteeffec;
        exception when no_data_found then v_desmist1 := null;
        end;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('total',v_total);
        obj_data.put('codpunsh_desc',get_tcodec_name('TCODPUNH',r1.codpunsh,global_v_lang));
        obj_data.put('punish_dte',to_char(r1.dtestart,'DD/MM/YYYY')||' - '||to_char(r1.dteend,'DD/MM/YYYY'));
        obj_data.put('desmist1',v_desmist1);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if; --v_rcnt

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure getdata_tab5(json_str_input in clob, json_str_output out clob) is
    v_total      number := 0;
    v_row        number := 0;
    obj_row      json_object_t;
    obj_data     json_object_t;
  cursor c1 is
    select mnuname,nammenut,codapp,grpid,typmenu,
           decode(global_v_lang,'101',nammenue,
                                '102',nammenut,
                                '103',nammenu3,
                                '104',nammenu4,
                                '105',nammenu5 ) nammenu
    from   thrpmmenu
    where  mnuname = b_index_mnuname
    and    typmenu = 'C'
    order  by numseq;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for r1 in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror',' ');
        obj_data.put('httpcode','');
        obj_data.put('flg','');
        obj_data.put('total',v_row);
        obj_data.put('detail',r1.nammenu);
        obj_data.put('codapp',r1.codapp);
        obj_data.put('typmenu',r1.typmenu);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if; --v_rcnt

--    dbms_lob.createtemporary(json_str_output, true);
--    obj_row.to_clob(json_str_output);
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end std_emp;

/

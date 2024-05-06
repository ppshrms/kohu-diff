--------------------------------------------------------
--  DDL for Package Body HRPY96R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY96R" as
  function get_formula (p_codcompy  varchar2, p_dteyreff number, p_numseq number) return varchar2 is
    v_formula  varchar2(4000 char);
  begin
    begin
      select formula into v_formula
        from tcoddtax
       where codcompy = p_codcompy
         and dteyreff = p_dteyreff
         and numseq   = p_numseq;
    exception when no_data_found then
      v_formula := null;
    end;
    return v_formula;
  end;

  function gtempded (p_codempid varchar2,p_typtax varchar2,p_dteyrepay number,p_codeduct varchar2 ) return number is
    v_amtdeduct     number := 0;
    v_amtspded      number := 0;
  begin  --p_typtax   ?????????????????? 1-??????? (??????????) , 2-???????  ,S-??????????
    if p_codeduct in ('PVF', 'SOC') then
      begin
        select  decode(p_codeduct,
                'PVF',stddec(amtproyr,p_codempid,global_v_chken),
                'SOC',stddec(amtsocyr,p_codempid,global_v_chken),0)
          into  v_amtdeduct
          from  ttaxmas
         where  dteyrepay = p_dteyrepay  - global_v_zyear
           and  codempid  = p_codempid;
      exception when no_data_found then
        v_amtdeduct := 0;
      end;
    else
      if p_dteyrepay = to_number(to_char(sysdate,'yyyy')) then
        begin
          select stddec(amtdeduct,codempid,global_v_chken),
                    stddec(amtspded,codempid,global_v_chken)
            into v_amtdeduct,v_amtspded
            from tempded
           where codempid  = p_codempid
             and coddeduct = p_codeduct;
        exception when no_data_found then
          v_amtdeduct:= 0;
          v_amtspded := 0;
        end;
      else
        begin
          select stddec(amtdeduct,codempid,global_v_chken),
                 stddec(amtspded,codempid,global_v_chken)
          into  v_amtdeduct,v_amtspded
          from  tlastempd
          where dteyrepay = p_dteyrepay
            and codempid  = p_codempid
            and coddeduct = p_codeduct;
        exception when no_data_found then
          v_amtdeduct := 0;
          v_amtspded := 0;
        end;
      end if;
    end if;
    --
    if p_typtax = '2' then  --p_typtax   ?????????????????? 1-??????? (??????????) , 2-???????  ,S-??????????
      v_amtdeduct  := v_amtdeduct   + v_amtspded;
    elsif p_typtax = 'S' then  --p_typtax  S-??????????
      v_amtdeduct  := v_amtspded;
    end if;
    --
    return  nvl(v_amtdeduct,0);
  end;

  function get_amtdedemp(p_codempid   varchar2,
                         p_typtax     varchar2,
                         p_dteyrepay  number,
                         p_formula    varchar2) return number is
    v_amtded    number:=0;
    v_formula   varchar2(4000 char);
    v_amt       varchar2(4000 char);
    v_check     varchar2(4000 char);
  begin
    if p_formula is not null then
      v_formula := p_formula;
      v_amt := 0;

      if instr(v_formula,'[') > 0 then
        loop
          v_check := substr(v_formula,instr(v_formula,'[') +1,(instr(v_formula,']') -1) - instr(v_formula,'['));
          exit when v_check is null;
          v_amt := gtempded(p_codempid,p_typtax,p_dteyrepay,v_check);
          v_formula := replace(v_formula,'{['||v_check||']}',v_amt);
        end loop;
        v_amtded := execute_sql('select '||v_formula||' from dual');
      end if;
    end if;
    return (v_amtded);
  end;

  procedure cleartemptable as
  begin
    delete ttemprpt
     where codapp like 'HRPY96R%'
       and codempid = global_v_codempid;
    commit;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    return;
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_dteyrepay  := to_number(hcm_util.get_string_t(obj_detail,'p_dteyrepay'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'p_codcomp');
    p_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid_query');
    p_typrep     := to_number(hcm_util.get_string_t(obj_detail,'p_typrep'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
    v_tmp					 varchar2(10);
  begin
    if p_codempid is not null then
      begin
        select 'X' into v_tmp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      end;
       if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal)  then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
       end if;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
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
    obj_data    json_object_t := json_object_t();
    v_num	    	number := 0;
    v_count	    	number := 0;
    v_codempid	varchar2(600);
    v_amtdeduct number;
    type item is table of varchar2(600) index by binary_integer;
      v_item   item;
    --
    v_amtsun    number;
    v_amtdedf   number;
    v_amtdspf   number;
    v_amtduct   number;
    v_amtpf     number;
    --
    v_flgsecu   boolean := false;
    v_secur     boolean := false;
    v_year   	  number;
    --
    v_fathr_pre1     number := 0;
    v_fathr_pre2     number := 0;
    v_mothr_pre1     number := 0;
    v_mothr_pre2     number := 0;
    --
    v_fathr_status1  number := 0;
    v_fathr_status2  number := 0;
    v_mothr_status1  number := 0;
    v_mothr_status2  number := 0;
    spouse_stalife      tspouse.stalife%type;
    spouse_staincom     tspouse.staincom%type;
    spouse_dtedthsp     tspouse.dtedthsp%type;

    v_amtchldb          number;
    v_amtchlda          number;
    v_tmp_amtchld       number;     
    v_tmp_amtchlb       number;     
    v_tmp_amtchla       number; 

    v_tmp_amt           number;

    v_codcompy          tcompny.codcompy%type;

    v_qtychldb          temploy3.qtychldb%type;
    v_qtychlda          temploy3.qtychlda%type;
    v_qtychldd          temploy3.qtychldd%type;
    v_qtychldi          temploy3.qtychldi%type;

  	cursor c_emp is
      select a.codempid,a.codcomp,a.codpos,a.codtitle,a.stamarry,a.staemp,
             b.numoffid,b.adrcontt,b.codsubdistc,b.coddistc,b.codprovc,b.codpostc,
             b.codsubdistr,b.coddistr,b.codprovr,b.codpostr,
             c.numtaxid,c.typtax,
             decode(global_v_lang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirstt) name,
             decode(global_v_lang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namlast4,'105',namlast5,namlastt) lastname,
             decode(global_v_lang,'101',b.adrconte,'102',b.adrcontt,'103',b.adrcont3,'104',b.adrcont4,'105',b.adrcont5,b.adrcontt) address,
             c.qtychldb,c.qtychlda,c.qtychldd,c.qtychldi
       from  temploy1 a,temploy2 b,temploy3 c
      where  a.codempid = nvl(p_codempid,a.codempid)
        and  a.codcomp  like p_codcomp||'%'
        and  a.codempid = b.codempid
--        and  ((a.staemp in ('1','3')) or (a.staemp = '9' and (to_number(to_char(dteeffex,'yyyy'))) = p_dteyrepay))
        and  b.codempid = c.codempid
      order by a.codcomp,a.codempid;
  begin
    -- clear old temp
    cleartemptable;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    if p_dteyrepay is not null then
      v_year := p_dteyrepay;
    else
      v_year := to_number(to_char(sysdate,'yyyy'));
    end if;

    for i in c_emp loop
      v_count   := v_count + 1;
      v_flgsecu := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        for i in 1..112 loop
          v_item(i) := ' ';
        end loop;          
        v_secur := true;
        v_num   := v_num + 1;
        v_amtdeduct:= 0;
        -- personal information
        v_codempid  := i.codempid;
        v_codcompy  := hcm_util.get_codcomp_level(i.codcomp,1);
        v_item(1)	:= hcm_util.get_date_buddhist_era(sysdate);
        v_item(2)	:= get_tcompny_name(v_codcompy,global_v_lang);
        v_item(3)   := get_tlistval_name('CODTITLE',i.codtitle,global_v_lang)||' '||i.name;
        v_item(4)   := i.lastname;

        v_item(110) := p_codempid;
        v_item(111) := p_codcomp;
        v_item(112) := p_dteyrepay;
        -- numoffid
        v_item(5)   := substr(i.numoffid,1,1);      v_item(6)   := substr(i.numoffid,2,1);
        v_item(7)   := substr(i.numoffid,3,1);      v_item(8)   := substr(i.numoffid,4,1);
        v_item(9)   := substr(i.numoffid,5,1);      v_item(10)  := substr(i.numoffid,6,1);
        v_item(11)  := substr(i.numoffid,7,1);      v_item(12)  := substr(i.numoffid,8,1);
        v_item(13)  := substr(i.numoffid,9,1);      v_item(14)  := substr(i.numoffid,10,1);
        v_item(15)  := substr(i.numoffid,11,1);     v_item(16)  := substr(i.numoffid,12,1);
        v_item(17)  := substr(i.numoffid,13,1);
        -- taxid
        v_item(18)  := substr(i.numtaxid,1,1);      v_item(19)  := substr(i.numtaxid,2,1);
        v_item(20)  := substr(i.numtaxid,3,1);      v_item(21)  := substr(i.numtaxid,4,1);
        v_item(22)  := substr(i.numtaxid,5,1);      v_item(23)  := substr(i.numtaxid,6,1);
        v_item(24)  := substr(i.numtaxid,7,1);      v_item(25)  := substr(i.numtaxid,8,1);
        v_item(26)  := substr(i.numtaxid,9,1);      v_item(27)  := substr(i.numtaxid,10,1);
        v_item(28)  := substr(i.numtaxid,11,1);     v_item(29)  := substr(i.numtaxid,12,1);
        v_item(30)  := substr(i.numtaxid,13,1);
        -- address
        v_item(31)  := i.address;
        v_item(32)  := get_tsubdist_name(i.codsubdistr,global_v_lang);
        v_item(33)  := get_tcoddist_name(i.coddistr,global_v_lang);
        v_item(34)  := get_tcodec_name('TCODPROV',i.codprovr,global_v_lang);
        -- codpost
        v_item(35)  := substr(i.codpostr,1,1);      v_item(36)  := substr(i.codpostr,2,1);
        v_item(37)  := substr(i.codpostr,3,1);      v_item(38)  := substr(i.codpostr,4,1);
        v_item(39)  := substr(i.codpostr,5,1);
        -- codpos / codcomp
        v_item(50)  := get_tpostn_name(i.codpos,global_v_lang);
        v_item(51)  := get_tcenter_name(i.codcomp,global_v_lang);
        -- default null
        v_item(52)  := null;
        v_item(53)  := null;
        --
        -- single status
        if i.stamarry = 'S' then
            v_item(54)          := 'X';
        else
            v_item(54)          := null;
        end if;
        -- married status
        if i.stamarry = 'M' then
            v_item(55)          := 'X';
        else
            v_item(55)          := null;
        end if;
        -- widow status
        if i.stamarry = 'W' then
            v_item(56)          := 'X';
        else
            v_item(56)          := null;
        end if;

        -- death during year
        v_item(57)              := null;

        --	married status 

        if i.stamarry = 'M' and i.typtax = '2' then
            v_item(58)          := 'X';
        else
            v_item(58)          := null;
        end if;   

        if i.stamarry = 'M' and i.typtax = '1' then
            v_item(60)          := 'X';
        else
            v_item(60)          := null;
        end if;        

        -- Divorce status
        if i.stamarry = 'D' then
            v_item(59)          := 'X';
        else
            v_item(59)          := null;
        end if;    

        begin
            select stalife,staincom,dtedthsp
              into spouse_stalife,spouse_staincom,spouse_dtedthsp
              from tspouse
             where codempid = i.codempid;     

            if spouse_stalife = 'N' and to_char(spouse_dtedthsp,'YYYY') = v_year then
                v_item(61)          := 'X';
            else
                v_item(61)          := null;
            end if;
    -->> user18 req.p'Bint 2021/04/29
--            if spouse_staincom = 'Y' then
--                v_item(62)          := 'X';
--                v_item(63)          := null;
--            else
--                v_item(62)          := null;
--                v_item(63)          := 'X';
--            end if;             
        exception when no_data_found then
            v_item(61)          := null;
--            v_item(62)          := null;
--            v_item(63)          := null;
        end;

        if i.stamarry = 'M' then
            if i.typtax = '1' then
                v_item(62)          := 'X';
                v_item(63)          := null;
            else
                v_item(62)          := null;
                v_item(63)          := 'X';
            end if;
        else
            v_item(62)          := null;
            v_item(63)          := null;
        end if;
    --<< user18 req.p'Bint 2021/04/29 

        begin
            select defaultval
              into v_amtchldb
              from tsetdeflt
             where codapp = 'HRPMC2E'
               and numpage = 'HRPMC2E164'
               and seqno = 2;
        exception when others then
            v_amtchldb := 0;
        end;

        begin
            select defaultval
              into v_amtchlda
              from tsetdeflt
             where codapp = 'HRPMC2E'
               and numpage = 'HRPMC2E164'
               and seqno = 3;
        exception when others then
            v_amtchlda := 0;
        end;

        -- total child
        if p_dteyrepay = to_number(to_char(sysdate,'yyyy')) then
            v_item(64)              := nvl(i.qtychldb,0) + nvl(i.qtychlda,0) + nvl(i.qtychldd,0);
            v_item(66)              := nvl(i.qtychlda,0);
            v_qtychldi              := nvl(i.qtychldi,0);
        else
            begin
                select qtychldb, qtychlda, qtychldd, qtychldi
                  into v_qtychldb, v_qtychlda, v_qtychldd, v_qtychldi
                  from tlastded
                 where dteyrepay = p_dteyrepay
                   and codempid = i.codempid;
            exception when no_data_found then
                v_qtychldb  := 0;
                v_qtychlda  := 0;
                v_qtychldd  := 0;
                v_qtychldi  := 0;
            end;
            v_item(64)              := nvl(v_qtychldb,0) + nvl(v_qtychlda,0) + nvl(v_qtychldd,0);
            v_item(66)              := nvl(v_qtychlda,0);
        end if;

        v_tmp_amtchld           := get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 1));
        v_tmp_amtchla           := v_item(66) * v_amtchlda;
        v_tmp_amtchlb           := v_tmp_amtchld - v_tmp_amtchla;

        v_item(65)              := v_tmp_amtchlb / v_amtchldb;

        v_item(67)              := hcm_util.get_split_decimal(v_tmp_amtchlb,'I');
        v_item(68)              := hcm_util.get_split_decimal(v_tmp_amtchlb,'D');

        v_item(69)              := hcm_util.get_split_decimal(v_tmp_amtchla,'I');
        v_item(70)              := hcm_util.get_split_decimal(v_tmp_amtchla,'D');

        v_fathr_status1     := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 2));
        v_fathr_status2     := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 2));
        v_mothr_status1     := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 3));
        v_mothr_status2     := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 3));
        if nvl(v_fathr_status1,0) > 0 then
          v_item(71)            := 'X';
        else
          v_item(71)            := null;
        end if;
        if nvl(v_mothr_status1,0) > 0 then
          v_item(72)            := 'X';
        else
          v_item(72)            := null;
        end if;

        -->> user18 req.p'Bint 2021/04/29
        if v_item(55) = 'X' then -- if married
            if v_item(63) = 'X' then
                if nvl(v_fathr_status2,0) > 0 then
                  v_item(73)            := 'X';
                else
                  v_item(73)            := null;
                end if;
                if nvl(v_mothr_status2,0) > 0 then
                  v_item(74)            := 'X';
                else
                  v_item(74)            := null;
                end if; 

                v_item(77)              := hcm_util.get_split_decimal(nvl(get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 4)),0),'I');
                v_item(78)              := hcm_util.get_split_decimal(nvl(get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 4)),0),'D');
            else
                v_item(73)            := null;
                v_item(74)            := null;
                v_item(77)            := '0';
                v_item(78)            := '00';
            end if;
        else
            v_item(73)            := null;
            v_item(74)            := null;
            v_item(77)            := '0';
            v_item(78)            := '00';
        end if;
        --<< user18 req.p'Bint 2021/04/29

        v_item(75)              := hcm_util.get_split_decimal(nvl(get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 4)),0),'I');
        v_item(76)              := hcm_util.get_split_decimal(nvl(get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 4)),0),'D');

        v_item(79)              := v_qtychldi;
        v_item(80)              := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 5)),'I');
        v_item(81)              := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 5)),'D');
--        -- 6.?????????????????
        v_fathr_pre1 := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 6));
        v_fathr_pre2 := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 6));
        v_mothr_pre1 := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 7));
        v_mothr_pre2 := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 7));

        if nvl(v_fathr_pre1,0) > 0 then
          v_item(82) := 'X';
        else
          v_item(82) := null;
        end if;
        if nvl(v_mothr_pre1,0) > 0 then
          v_item(83) := 'X';
        else
          v_item(83) := null;
        end if;
        if nvl(v_fathr_pre2,0) > 0 then
          v_item(84) := 'X';
        else
          v_item(84) := null;
        end if;
        if nvl(v_mothr_pre2,0) > 0 then
          v_item(85) := 'X';
        else
          v_item(85) := null;
        end if;
        --
        v_tmp_amt           := least(15000,get_amtdedemp(i.codempid,'2',p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 8)));
        v_item(86)          := hcm_util.get_split_decimal(v_tmp_amt,'I');
        v_item(87)          := hcm_util.get_split_decimal(v_tmp_amt,'D');
        --
        v_item(88)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 9)),'I');
        v_item(89)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 9)),'D');
        --
        v_item(90)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 10)),'I');
        v_item(91)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 10)),'D');
        --
        v_item(92)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 11)),'I');
        v_item(93)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 11)),'D');
        --
        v_item(94)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 12)),'I');
        v_item(95)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 12)),'D');
        --
        v_item(96)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 13)),'I');
        v_item(97)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 13)),'D');
        --
        v_item(98)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 14)),'I');
        v_item(99)          := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 14)),'D');
        --
        v_item(100)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 15)),'I');
        v_item(101)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 15)),'D');
        --
        v_item(102)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 16)),'I');
        v_item(103)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 16)),'D');
        --
        v_item(104)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 17)),'I');
        v_item(105)         := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(v_codcompy, p_dteyrepay, 17)),'D');

        if p_typrep = '1' then
            for i in 54..109 loop
              v_item(i) := ' ';
            end loop;       
        end if;
        begin
          insert into ttemprpt
                (codempid,codapp,numseq,
                 item1,item2,item3,item4,
                 item5,item6,item7,item8,item9,
                 item10,item11,item12,item13,item14,
                 item15,item16,item17,
                 item18,item19,item20,item21,item22,
                 item23,item24,item25,item26,item27,
                 item28,item29,item30,item31,item32,
                 item33,item34,item35,item36,item37,
                 item38,item39,item40,item41,item42,
                 item43,item44,item45,item46,item47,
                 item48,item49,item50,item51,item52,
                 item53,item54,item55,item56,item57,
                 item58,item59,item60,item61,item62,
                 item63,item64,item65,item66,item67,
                 item68,item69,item70,item71,item72,
                 item73,item74,item75,item76,item77,
                 item78,item79,item80,item81,item82,
                 item83,item84,item85,item86,item87,
                 item88,item89,item90,item91,item92,
                 item93,item94,item95,item96,item97,
                 item98,item99,item100,item101,item102,
                 item103,item104,item105,item106,item107,
                 item108,item109,item110,item111,item112)
              values
                (global_v_codempid,'HRPY96R',v_num,
                 v_item(1),v_item(2),v_item(3),v_item(4),
                 v_item(5),v_item(6),v_item(7),v_item(8),v_item(9),
                 v_item(10),v_item(11),v_item(12),v_item(13),v_item(14),
                 v_item(15),v_item(16),v_item(17),
                 v_item(18),v_item(19),v_item(20),v_item(21),v_item(22),
                 v_item(23),v_item(24),v_item(25),v_item(26),v_item(27),
                 v_item(28),v_item(29),v_item(30),v_item(31),v_item(32),
                 v_item(33),v_item(34),v_item(35),v_item(36),v_item(37),
                 v_item(38),v_item(39),v_item(40),v_item(41),v_item(42),
                 v_item(43),v_item(44),v_item(45),v_item(46),v_item(47),
                 v_item(48),v_item(49),v_item(50),v_item(51),v_item(52),
                 v_item(53),v_item(54),v_item(55),v_item(56),v_item(57),
                 v_item(58),v_item(59),v_item(60),v_item(61),v_item(62),
                 v_item(63),v_item(64),v_item(65),v_item(66),v_item(67),
                 v_item(68),v_item(69),v_item(70),v_item(71),v_item(72),
                 v_item(73),v_item(74),v_item(75),v_item(76),v_item(77),
                 v_item(78),v_item(79),v_item(80),v_item(81),v_item(82),
                 v_item(83),v_item(84),v_item(85),v_item(86),v_item(87),
                 v_item(88),v_item(89),v_item(90),v_item(91),v_item(92),
                 v_item(93),v_item(94),v_item(95),v_item(96),v_item(97),
                 v_item(98),v_item(99),v_item(100),v_item(101),v_item(102),
                 v_item(103),v_item(104),v_item(105),v_item(106),v_item(107),
                 v_item(108),v_item(109),v_item(110),v_item(111),v_item(112));
         exception when others then null;
         end;
--2407
      elsif v_count = 0 then
         param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'trmploy1');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
      elsif not v_secur then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
--2407
      end if;
    end loop;
    commit;
    --
    obj_data.put('coderror','200');
    obj_data.put('response','Successfully');
    obj_data.put('status',200);
    obj_data.put('message','https://www.google.com/');
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  procedure gen_indexo(json_str_output out clob) as
    obj_data    json_object_t := json_object_t();
    v_num	    	number := 0;
    v_count	    	number := 0;
    v_codempid	varchar2(600);
    v_amtdeduct number;
    type item is table of varchar2(600) index by binary_integer;
      v_item   item;
    v_item1		  varchar2(600); v_item2		varchar2(600);
    v_item3		  varchar2(600); v_item4		varchar2(600);
    v_item5		  varchar2(600); v_item6		varchar2(600);
    v_item7		  varchar2(600); v_item8		varchar2(600);
    v_item9		  varchar2(600); v_item10		varchar2(600);
    v_item11	  varchar2(600); v_item12		varchar2(600);
    v_item13	  varchar2(600); v_item14		varchar2(600);
    v_item15	  varchar2(600); v_item16		varchar2(600);
    v_item17	  varchar2(600); v_item18		varchar2(600);
    v_item19	  varchar2(600); v_item20		varchar2(600);
    v_item21	  varchar2(600); v_item22		varchar2(600);
    v_item23	  varchar2(600); v_item24		varchar2(600);
    v_item25	  varchar2(600); v_item26		varchar2(600);
    v_item27	  varchar2(600); v_item28		varchar2(600);
    v_item29	  varchar2(600); v_item30		varchar2(600);
    v_item31	  varchar2(600); v_item32		varchar2(600);
    v_item33	  varchar2(600); v_item34		varchar2(600);
    v_item35	  varchar2(600); v_item36		varchar2(600);
    v_item37	  varchar2(600); v_item38		varchar2(600);
    v_item39	  varchar2(600); v_item40		varchar2(600);
    v_item41	  varchar2(600); v_item42		varchar2(600);
    v_item43	  varchar2(600); v_item44		varchar2(600);
    v_item45	  varchar2(600); v_item46		varchar2(600);
    v_item47	  varchar2(600); v_item48		varchar2(600);
    v_item49	  varchar2(600); v_item50		varchar2(600);
    v_item51	  varchar2(600); v_item52		varchar2(600);
    v_item53	  varchar2(600); v_item54		varchar2(600);
    v_item55	  varchar2(600); v_item56		varchar2(600);
    v_item57	  varchar2(600); v_item58		varchar2(600);
    v_item59	  varchar2(600); v_item60		varchar2(600);
    v_item61	  varchar2(600); v_item62		varchar2(600);
    v_item63	  varchar2(600); v_item64		varchar2(600);
    v_item65	  varchar2(600); v_item66		varchar2(600);
    v_item67	  varchar2(600); v_item68		varchar2(600);
    v_item69	  varchar2(600); v_item70		varchar2(600);
    v_item71	  varchar2(600); v_item72		varchar2(600);
    v_item73	  varchar2(600); v_item74		varchar2(600);
    v_item75    varchar2(600); v_item76		varchar2(600);
    v_item77    varchar2(600); v_item78		varchar2(600);
    v_item79	  varchar2(600); v_item80		varchar2(600);
    v_item81	  varchar2(600); v_item82		varchar2(600);
    v_item83	  varchar2(600); v_item84		varchar2(600);
    v_item85	  varchar2(600); v_item86		varchar2(600);
    v_item87	  varchar2(600); v_item88		varchar2(600);
    v_item101   varchar2(600);
    v_item102   varchar2(600);
    v_item103   varchar2(600);
    ---Decimal---
    v_item63_decimal        varchar2(600);
    v_item66_decimal        varchar2(600);
    v_item69_decimal        varchar2(600);
    v_item71_decimal        varchar2(600);
    v_item76_decimal        varchar2(600);
    v_item77_decimal        varchar2(600);
    v_item79_decimal        varchar2(600);
    v_item81_decimal        varchar2(600);
    v_item83_decimal        varchar2(600);
    v_item84_decimal        varchar2(600);
    v_item85_decimal        varchar2(600);
    v_item86_decimal        varchar2(600);
    --
    v_item69_number         number;
    v_item76_number         number;
    --

    v_amtsun    number;
    v_amtdedf   number;
    v_amtdspf   number;
    v_amtduct   number;
    v_amtpf     number;
    --
    v_flgsecu   boolean := false;
    v_secur     boolean := false;
    v_year   	  number;
    --
    v_fathr_pre1     number := 0;
    v_fathr_pre2     number := 0;
    v_mothr_pre1     number := 0;
    v_mothr_pre2     number := 0;
    --
    v_fathr_status1  number := 0;
    v_fathr_status2  number := 0;
    v_mothr_status1  number := 0;
    v_mothr_status2  number := 0;

  	cursor c_emp is
      select a.codempid,a.codcomp,a.codpos,a.codtitle,a.stamarry,a.staemp,
             b.numoffid,b.adrcontt,b.codsubdistc,b.coddistc,b.codprovc,b.codpostc,
             b.codsubdistr,b.coddistr,b.codprovr,b.codpostr,
             c.numtaxid,c.qtychedu,c.qtychned,c.typtax,
             decode(global_v_lang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirstt) name,
             decode(global_v_lang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namlast4,'105',namlast5,namlastt) lastname,
             decode(global_v_lang,'101',b.adrconte,'102',b.adrcontt,'103',b.adrcont3,'104',b.adrcont4,'105',b.adrcont5,b.adrcontt) address
       from  temploy1 a,temploy2 b,temploy3 c
      where  a.codempid = nvl(p_codempid,a.codempid)
        and  a.codcomp  like p_codcomp||'%'
        and  a.codempid = b.codempid
        and  ((a.staemp in ('1','3')) or (a.staemp = '9' and (to_number(to_char(dteeffex,'yyyy'))) = p_dteyrepay))
        and  b.codempid = c.codempid
      order by a.codcomp,a.codempid;
  begin
    -- clear old temp
    cleartemptable;

    for i in 1..110 loop
      v_item(i) := ' ';
    end loop;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    if p_dteyrepay is not null then
      v_year := p_dteyrepay;
    else
      v_year := to_number(to_char(sysdate,'yyyy'));
    end if;
    --
--2407
    for i in c_emp loop
      v_count := v_count + 1;
      v_flgsecu := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        v_secur := true;
        v_num := v_num + 1;
        v_amtdeduct:= 0;
        -- set null value
        v_item1		  := null; v_item2		:= null;
        v_item3		  := null; v_item4		:= null; v_item101		:= null;
        v_item5		  := null; v_item6		:= null;
        v_item7		  := null; v_item8		:= null;
        v_item9		  := null; v_item10		:= null;
        v_item11	  := null; v_item12		:= null;
        v_item13	  := null; v_item14		:= null;
        v_item15	  := null; v_item16		:= null;
        v_item17	  := null; v_item18		:= null;
        v_item19	  := null; v_item20		:= null;
        v_item21	  := null; v_item22		:= null;
        v_item23	  := null; v_item24		:= null;
        v_item25	  := null; v_item26		:= null;
        v_item27	  := null; v_item28		:= null;
        v_item29	  := null; v_item30		:= null;
        v_item31	  := null; v_item32		:= null;
        v_item33	  := null; v_item34		:= null;
        v_item35	  := null; v_item36		:= null;
        v_item37	  := null; v_item38		:= null;
        v_item39	  := null; v_item40		:= null;
        v_item41	  := null; v_item42		:= null;
        v_item43	  := null; v_item44		:= null;
        v_item45	  := null; v_item46		:= null;
        v_item47	  := null; v_item48		:= null;
        v_item49	  := null; v_item50		:= null;
        v_item51	  := null; v_item52		:= null;
        v_item53	  := null; v_item54		:= null;
        v_item55	  := null; v_item56		:= null;
        v_item57	  := null; v_item58		:= null;
        v_item59	  := null; v_item60		:= null;
        v_item61	  := null; v_item62		:= null;
        v_item63	  := null; v_item64		:= null;
        v_item65	  := null; v_item66		:= null;
        v_item67	  := null; v_item68		:= null;
        v_item69	  := null; v_item70		:= null;
        v_item71	  := null; v_item72		:= null;
        v_item73	  := null; v_item74		:= null;
        v_item75      := null; v_item76		:= null;
        v_item77	  := null; v_item78		:= null;
        v_item79	  := null; v_item80		:= null;
        v_item81	  := null; v_item82		:= null;
        v_item83	  := null; v_item84		:= null;
        v_item85	  := null; v_item86		:= null;
        v_item87	  := null; v_item88		:= null;
        -- ??????????????????
        v_codempid := i.codempid;
        v_item1	:= hcm_util.get_date_buddhist_era(sysdate);
        v_item2	:= get_tcompny_name(hcm_util.get_codcomp_level(i.codcomp,1),global_v_lang);
        v_item3 := get_tlistval_name('CODTITLE',i.codtitle,global_v_lang)||' '||i.name;
        v_item4 := i.lastname;
        v_item101 := p_codempid;
        v_item102 := p_codcomp;
        v_item103 := p_dteyrepay;
        -- ?????????????????
        v_item5  := substr(i.numoffid,1,1);  v_item6  := substr(i.numoffid,2,1);
        v_item7  := substr(i.numoffid,3,1);  v_item8  := substr(i.numoffid,4,1);
        v_item9  := substr(i.numoffid,5,1);  v_item10 := substr(i.numoffid,6,1);
        v_item11 := substr(i.numoffid,7,1);  v_item12 := substr(i.numoffid,8,1);
        v_item13 := substr(i.numoffid,9,1);  v_item14 := substr(i.numoffid,10,1);
        v_item15 := substr(i.numoffid,11,1); v_item16 := substr(i.numoffid,12,1);
        v_item17 := substr(i.numoffid,13,1);
        -- ??????????????????????
        v_item18 := substr(i.numtaxid,1,1); v_item19 := substr(i.numtaxid,2,1);
        v_item20 := substr(i.numtaxid,3,1); v_item21 := substr(i.numtaxid,4,1);
        v_item22 := substr(i.numtaxid,5,1); v_item23 := substr(i.numtaxid,6,1);
        v_item24 := substr(i.numtaxid,7,1); v_item25 := substr(i.numtaxid,8,1);
        v_item26 := substr(i.numtaxid,9,1); v_item27 := substr(i.numtaxid,10,1);
        v_item28 := substr(i.numtaxid,11,1); v_item29 := substr(i.numtaxid,12,1);
        v_item30 := substr(i.numtaxid,13,1);
        -- ???????
        v_item31 := i.address;
        v_item32 := get_tsubdist_name(i.codsubdistr,global_v_lang);
        v_item33 := get_tcoddist_name(i.coddistr,global_v_lang);
        v_item34 := get_tcodec_name('TCODPROV',i.codprovr,global_v_lang);
        -- ????????????
        v_item35 := substr(i.codpostr,1,1); v_item36 := substr(i.codpostr,2,1);
        v_item37 := substr(i.codpostr,3,1); v_item38 := substr(i.codpostr,4,1);
        v_item39 := substr(i.codpostr,5,1);
        -- ???????-??????
        v_item50 := get_tpostn_name(i.codpos,global_v_lang);
        v_item51 := get_tcenter_name(i.codcomp,global_v_lang);
        -- ????????????????????? default null
        v_item52  := null;
        v_item53  := null;
        --
        -- 1.??????????? --???????????  S-???, M-???????, D-????, W-?????, I-?????????????????
        -- ???
        if i.stamarry = 'S' then
            v_item54        := 'X';
        else
            v_item54        := null;
        end if;
        -- ?????
        if i.stamarry = 'W' then
            v_item55        := 'X';
        else
            v_item55        := null;
        end if;
        -- ????
        if i.stamarry = 'M' then
            v_item56        := 'X';
        else
            v_item56        := null;
        end if;
        -- ????
        if i.stamarry = 'D' then
            v_item57        := 'X';
        else
            v_item57        := null;
        end if;
        -- 2.???????????????????????????
        --	????????????????
        if i.stamarry = 'M' and i.typtax = '1' then
            v_item58        := 'X';
        else
            v_item58        := null;
        end if;
        -- ????????????? default null
        v_item59            := null;
        -- ???????????????????
        if i.stamarry = 'M' and i.typtax = '2' then
            v_item60        := 'X';
        else
            v_item60        := null;
        end if;
        --
        -- 3.???????????
        if nvl(i.qtychedu,0) > 3 then
          v_item61          := 0;
          v_item62          := 3;
        else
          v_item61          := least(nvl(i.qtychned,0),3 - nvl(i.qtychedu,0));
          v_item62          := nvl(i.qtychedu,0);
        end if;

        v_item63            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 1)),'I');
        v_item63_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 1)),'D');
        --
        -- 4.???? ? ????? ???????????????
        v_fathr_status1     := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 3));
        v_fathr_status2     := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 3));
        v_mothr_status1     := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
        v_mothr_status2     := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
        --  ????????? ???????????????
        if nvl(v_fathr_status1,0) > 0 then
          v_item64          := 'X';
        else
          v_item64          := null;
        end if;
        -- ?????????? ???????????????
        if nvl(v_mothr_status1,0) > 0 then
          v_item65          := 'X';
        else
          v_item65          := null;
        end if;
        -- ????????????????
        v_item66            := hcm_util.get_split_decimal(nvl(v_fathr_status1,0) + nvl(v_mothr_status1,0),'I');
        v_item66_decimal    := hcm_util.get_split_decimal(nvl(v_fathr_status1,0) + nvl(v_mothr_status1,0),'D');
        -- ????????? ?????????????????????????
        if nvl(v_fathr_status2,0) > 0 then
          v_item67          := 'X';
        else
          v_item67          := null;
        end if;
        -- ?????????? ?????????????????????????
        if nvl(v_mothr_status2,0) > 0 then
          v_item68          := 'X';
        else
          v_item68          := null;
        end if;
        -- ????????????????
        v_item69_number     := nvl(v_fathr_status2,0) + nvl(v_mothr_status2,0);
        v_item69            := hcm_util.get_split_decimal(v_item69_number,'I');
        v_item69_decimal    := hcm_util.get_split_decimal(v_item69_number,'D');
        -- 5.???????????????????????????????????????
        v_item70            := null;
        v_item71            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 5)),'I');
        v_item71_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 5)),'D');
--        -- 6.?????????????????
--        v_fathr_pre1 := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
--        v_fathr_pre2 := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
--        v_mothr_pre1 := get_amtdedemp(i.codempid,'1',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
--        v_mothr_pre2 := get_amtdedemp(i.codempid,'S',p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4));
        v_fathr_pre1 := 1000;
        v_fathr_pre2 := 2000;
        v_mothr_pre1 := 3000;
        v_mothr_pre2 := 4000;
        -- ????????????????????? ???????????????
        if nvl(v_fathr_pre1,0) > 0 then
          v_item72 := 'X';
        else
          v_item72 := null;
        end if;
        -- ?????????????????????? ???????????????
        if nvl(v_mothr_pre1,0) > 0 then
          v_item73 := 'X';
        else
          v_item73 := null;
        end if;
        -- ????????????????????? ??????????
        if nvl(v_fathr_pre2,0) > 0 then
          v_item74 := 'X';
        else
          v_item74 := null;
        end if;
        -- ?????????????????????? ??????????
        if nvl(v_mothr_pre2,0) > 0 then
          v_item75 := 'X';
        else
          v_item75 := null;
        end if;
        --
        -- ????????????????
        v_item76_number     := least(15000,nvl(v_fathr_pre1,0) + nvl(v_mothr_pre1,0) + nvl(v_fathr_pre2,0) + nvl(v_mothr_pre2,0));
        v_item76            := hcm_util.get_split_decimal(v_item76_number,'I');
        v_item76_decimal    := hcm_util.get_split_decimal(v_item76_number,'D');
        --
        -- 7.??????????????????????????????????
        v_item77            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,null),'I');
        v_item77_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,null),'D');
        --
        -- 8.????????????????????????????????
        v_item78            := null;
        -- 9.???????????????????????????????????????
        v_item79            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,null),'I');
        v_item79_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,null),'D');
        --
        -- 10.??????????????????????????????????????????
        v_item80            := null;
        v_item81            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4)),'I');
        v_item81_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 4)),'D');
        --
        -- 11.???????????????????????????????????????
        v_item82            := null;
        v_item83            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 14)),'I');
        v_item83_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 14)),'D');
        --
        -- 12.??????????????????????????? ???????? ??????????????????????????
        v_item84            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 15)),'I');
        v_item84_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 15)),'D');
        --
        -- 13.????????????????????????????????????
        v_item85            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 16)),'I');
        v_item85_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 16)),'D');
        --
        -- 14.????????????????????
        v_item86            := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 17)),'I');
        v_item86_decimal    := hcm_util.get_split_decimal(get_amtdedemp(i.codempid,i.typtax,p_dteyrepay,get_formula(hcm_util.get_codcomp_level(i.codcomp,1), p_dteyrepay, 17)),'D');
        --
        --
        -- 15.???????????????
        v_item87            := null;
        v_item88            := null;
        --
--        v_item63_decimal    := hcm_util.get_split_decimal(v_item63,'D');
--        v_item66_decimal    := hcm_util.get_split_decimal(v_item66,'D');
--        v_item69_decimal    := hcm_util.get_split_decimal(v_item69,'D');
--        v_item71_decimal    := hcm_util.get_split_decimal(v_item71,'D');
--        v_item76_decimal    := hcm_util.get_split_decimal(v_item76,'D');
--        v_item77_decimal    := hcm_util.get_split_decimal(v_item77,'D');
--        v_item79_decimal    := hcm_util.get_split_decimal(v_item79,'D');
--        v_item81_decimal    := hcm_util.get_split_decimal(v_item81,'D');
--        v_item83_decimal    := hcm_util.get_split_decimal(v_item83,'D');
--        v_item84_decimal    := hcm_util.get_split_decimal(v_item84,'D');
--        v_item85_decimal    := hcm_util.get_split_decimal(v_item85,'D');
--        v_item86_decimal    := hcm_util.get_split_decimal(v_item86,'D');

        if p_typrep = '1' then
            v_item54 := null;
            v_item55 := null;
            v_item56 := null;
            v_item57 := null;
            v_item58 := null;
            v_item59 := null;
            v_item60 := null;
            v_item61 := null;
            v_item62 := null;
            v_item63 := null;
            v_item64 := null;
            v_item65 := null;
            v_item66 := null;
            v_item67 := null;
            v_item68 := null;
            v_item69 := null;
            v_item70 := null;
            v_item71 := null;
            v_item72 := null;
            v_item73 := null;
            v_item74 := null;
            v_item75 := null;
            v_item76 := null;
            v_item77 := null;
            v_item78 := null;
            v_item79 := null;
            v_item80 := null;
            v_item81 := null;
            v_item82 := null;
            v_item83 := null;
            v_item84 := null;
            v_item85 := null;
            v_item86 := null;
            v_item87 := null;
            v_item88 := null;
            v_item63_decimal := null;
            v_item66_decimal := null;
            v_item69_decimal := null;
            v_item71_decimal := null;
            v_item76_decimal := null;
            v_item77_decimal := null;
            v_item79_decimal := null;
            v_item81_decimal := null;
            v_item83_decimal := null;
            v_item84_decimal := null;
            v_item85_decimal := null;
            v_item86_decimal := null;
        end if;
        begin
          insert into ttemprpt
                (codempid,codapp,numseq,
                 item1,item2,item3,item4,
                 item5,item6,item7,item8,item9,
                 item10,item11,item12,item13,item14,
                 item15,item16,item17,
                 item18,item19,item20,item21,item22,
                 item23,item24,item25,item26,item27,
                 item28,item29,item30,item31,item32,
                 item33,item34,item35,item36,item37,
                 item38,item39,item50,item51,item52,
                 item53,item54,item55,item56,item57,
                 item58,item59,item60,item61,item62,
                 item63,item64,item65,item66,item67,
                 item68,item69,item70,item71,item72,
                 item73,item74,item75,item76,item77,
                 item78,item79,item80,item81,item82,
                 item83,item84,item85,item86,item87,
                 item88,
                 ---Decimal---
                 item89,item90,item91,item92,item93,
                 item94,item95,item96,item97,item98,
                 item99,item100, item101, item102, item103)
              values
                (global_v_codempid,'HRPY96R',v_num,
                 v_item1,v_item2,v_item3,v_item4,
                 v_item5,v_item6,v_item7,v_item8,v_item9,
                 v_item10,v_item11,v_item12,v_item13,v_item14,
                 v_item15,v_item16,v_item17,
                 v_item18,v_item19,v_item20,v_item21,v_item22,
                 v_item23,v_item24,v_item25,v_item26,v_item27,
                 v_item28,v_item29,v_item30,v_item31,v_item32,
                 v_item33,v_item34,v_item35,v_item36,v_item37,
                 v_item38,v_item39,v_item50,v_item51,v_item52,
                 v_item53,v_item54,v_item55,v_item56,v_item57,
                 v_item58,v_item59,v_item60,v_item61,v_item62,
                 v_item63,v_item64,v_item65,v_item66,v_item67,
                 v_item68,v_item69,v_item70,v_item71,v_item72,
                 v_item73,v_item74,v_item75,v_item76,v_item77,
                 v_item78,v_item79,v_item80,v_item81,v_item82,
                 v_item83,v_item84,v_item85,v_item86,v_item87,
                 v_item88,
                 ---Decimal---
                 v_item63_decimal,v_item66_decimal,v_item69_decimal,v_item71_decimal,v_item76_decimal,
                 v_item77_decimal,v_item79_decimal,v_item81_decimal,v_item83_decimal,v_item84_decimal,
                 v_item85_decimal,v_item86_decimal, v_item101, v_item102, v_item103);
         exception when others then null;
         end;
--2407
      elsif v_count = 0 then
         param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'trmploy1');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
      elsif not v_secur then
         param_msg_error := get_error_msg_php('HR3007',global_v_lang);
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
--2407
      end if;
    end loop;
    commit;
    --
    obj_data.put('coderror','200');
    obj_data.put('response','Successfully');
    obj_data.put('status',200);
    obj_data.put('message','https://www.google.com/');
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_indexo;

/*  procedure gen_index(json_str_output out clob) as
    obj_data    json := json();
    v_flgsecu   boolean   := false;
    v_secur     boolean   := false;
    v_exist     boolean   := false;
    v_num	    	number    := 0;
    v_amtdeduct number    := 0;
    v_codempid	varchar2(600);
    v_item1		  varchar2(600); v_item2		varchar2(600);
    v_item3		  varchar2(600); v_item4		varchar2(600);
    v_item5		  varchar2(600); v_item6		varchar2(600);
    v_item7		  varchar2(600); v_item8		varchar2(600);
    v_item9		  varchar2(600); v_item10		varchar2(600);
    v_item11	  varchar2(600); v_item12		varchar2(600);
    v_item13	  varchar2(600); v_item14		varchar2(600);
    v_item15	  varchar2(600); v_item16		varchar2(600);
    v_item17	  varchar2(600); v_item18		varchar2(600);
    v_item19	  varchar2(600); v_item20		varchar2(600);
    v_item21	  varchar2(600); v_item22		varchar2(600);
    v_item23	  varchar2(600); v_item24		varchar2(600);
    v_item25	  varchar2(600); v_item26		varchar2(600);
    v_item27	  varchar2(600); v_item28		varchar2(600);
    v_item29	  varchar2(600); v_item30		varchar2(600);
    v_item31	  varchar2(600); v_item32		varchar2(600);
    v_item33	  varchar2(600); v_item34		varchar2(600);
    v_item35	  varchar2(600); v_item36		varchar2(600);
    v_item37	  varchar2(600); v_item38		varchar2(600);
    v_item39	  varchar2(600); v_item40		varchar2(600);
    v_item41	  varchar2(600); v_item42		varchar2(600);
    v_item43	  varchar2(600); v_item44		varchar2(600);
    v_item45	  varchar2(600); v_item46		varchar2(600);
    v_item47	  varchar2(600); v_item48		varchar2(600);
    v_item49	  varchar2(600); v_item50		varchar2(600);
    v_item51	  varchar2(600); v_item52		varchar2(600);
    v_item53	  varchar2(600); v_item54		varchar2(600);
    v_item55	  varchar2(600); v_item56		varchar2(600);
    v_item57	  varchar2(600); v_item58		varchar2(600);
    v_item59	  varchar2(600); v_item60		varchar2(600);
    v_item61	  varchar2(600); v_item62		varchar2(600);
    v_item63	  varchar2(600); v_item64		varchar2(600);
    v_item65  	varchar2(600); v_item66		varchar2(600);
    v_item67	  varchar2(600); v_item68		varchar2(600);
    v_item69	  varchar2(600); v_item70		varchar2(600);
    v_item71	  varchar2(600); v_item72		varchar2(600);
    v_item73	  varchar2(600); v_item74		varchar2(600);
    v_item75    varchar2(600);
    --
    v_O001      number;
    v_O002      number;
    v_O003      number;
    v_E001      number;
    v_E002      number;
    v_E003      number;
    --
    v_tick1		  varchar2(10):= null;
    v_tick2		  varchar2(10):= null;
    v_tick3		  varchar2(10):= null;
    v_tick4		  varchar2(10):= null;
    v_tick5		  varchar2(10):= null;
    --
    v_amtsun    number;
    v_amtdedf   number;
    v_amtdspf   number;
    v_amtduct   number;
    v_amtpf     number;
    v_year   	  number;
    v_amtedu    number;
    v_amtned    number;
    v_qtychned  number;
    v_qtychedu  number;
    v_zupdsal	  varchar2(4);

    cursor c_emp is
      select a.codempid,a.codcomp,a.codpos,a.codtitle,a.stamarry,a.staemp,
             b.numoffid,b.adrcontt,b.codsubdistc,b.coddistc,b.codprovc,b.codpostc,
             b.codsubdistr,b.coddistr,b.codprovr,b.codpostr,
             c.numtaxid,c.qtychedu,c.qtychned,c.typtax,
             decode(global_v_lang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirstt) name,
             decode(global_v_lang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namlast4,'105',namlast5,namlastt) lastname,
             decode(global_v_lang,'101',b.adrrege,'102',b.adrregt,'103',b.adrreg3,'104',b.adrreg4,'105',b.adrreg5,b.adrregt) address
        from temploy1 a,temploy2 b,temploy3 c
       where a.codempid = nvl(p_codempid,a.codempid)
         and a.codcomp  like p_codcomp||'%'
         and a.codempid = b.codempid
         and ((a.staemp in ('1','3')) or (a.staemp = '9' and (to_number(to_char(dteeffex,'yyyy'))- global_v_zyear) = p_dteyrepay))
         and b.codempid = c.codempid
      order by a.codcomp,a.codempid;

    cursor c_masd is
      select numseq,coddeduct, amtdeduct, amtspded
        from ((select t2.numseq,t2.coddeduct,
                      sum(nvl(stddec(t1.amtdeduct,codempid,global_v_chken),0)) amtdeduct,
                      sum(nvl(stddec(t1.amtspded,codempid,global_v_chken),0)) amtspded
                 from tempded t1,tcoddtax t2
                where t1.codempid  = v_codempid
                  and t2.dteyreff  = p_dteyrepay
                  and p_dteyrepay  = to_number(to_char(sysdate,'yyyy'))
                  and t1.coddeduct = t2.coddeduct
                group by t2.numseq,t2.coddeduct)
              union
              (select t2.numseq,t2.coddeduct,
                      sum(nvl(stddec(t1.amtdeduct,codempid,global_v_chken),0)) amtdeduct,
                      sum(nvl(stddec(t1.amtspded,codempid,global_v_chken),0)) amtspded
                 from tlastempd t1,tcoddtax t2
                where t1.codempid  = v_codempid
                  and t1.dteyrepay = p_dteyrepay
                  and p_dteyrepay <> to_number(to_char(sysdate,'yyyy'))
                  and t1.dteyrepay = t2.dteyreff
                  and t1.coddeduct = t2.coddeduct
                group by t2.numseq,t2.coddeduct))
        order by numseq, coddeduct;
  begin
    -- clear old temp
    cleartemptable;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    --
    if p_dteyrepay is not null then
      v_year := p_dteyrepay;
    else
      v_year := to_number(to_char(sysdate,'yyyy'));
    end if;
    --
    for i in c_emp loop
      if ((p_typrep = '1' and i.staemp <> 9) or  p_typrep = '2' ) then
        v_flgsecu := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
          v_secur := true;
          v_num := v_num + 1;
          v_amtdeduct:= 0;
          --
          v_codempid := i.codempid;
          v_item1	:= to_char(sysdate,'dd/mm/yyyy');
          v_item2	:= get_tcompny_name(hcm_util.get_codcomp_level(i.codcomp,'1'),global_v_lang);
          v_item3 := get_tlistval_name('CODTITLE',i.codtitle,global_v_lang)||' '||i.name;
          v_item4 := i.lastname;
          -- ?????????????????
          v_item5  := substr(i.numoffid,1,1);  v_item6  := substr(i.numoffid,2,1);
          v_item7  := substr(i.numoffid,3,1);  v_item8  := substr(i.numoffid,4,1);
          v_item9  := substr(i.numoffid,5,1);  v_item10 := substr(i.numoffid,6,1);
          v_item11 := substr(i.numoffid,7,1);  v_item12 := substr(i.numoffid,8,1);
          v_item13 := substr(i.numoffid,9,1);  v_item14 := substr(i.numoffid,10,1);
          v_item15 := substr(i.numoffid,11,1); v_item16 := substr(i.numoffid,12,1);
          v_item17 := substr(i.numoffid,13,1);
          -- ??????????????????????????
          v_item18 := substr(i.numtaxid,1,1);  v_item19 := substr(i.numtaxid,2,1);
          v_item20 := substr(i.numtaxid,3,1);  v_item21 := substr(i.numtaxid,4,1);
          v_item22 := substr(i.numtaxid,5,1);  v_item23 := substr(i.numtaxid,6,1);
          v_item24 := substr(i.numtaxid,7,1);  v_item25 := substr(i.numtaxid,8,1);
          v_item26 := substr(i.numtaxid,9,1);  v_item27 := substr(i.numtaxid,10,1);
          v_item28 := substr(i.numtaxid,11,1); v_item29 := substr(i.numtaxid,12,1);
          v_item30 := substr(i.numtaxid,13,1);
          -- ???????
          v_item32 := i.address;
          v_item36 := get_tsubdist_name(i.codsubdistr,global_v_lang);
          v_item37 := get_tcoddist_name(i.coddistr,global_v_lang);
          v_item38 := get_tcodec_name('TCODPROV',i.codprovr,global_v_lang);
          -- ????????????
          v_item39 := substr(i.codpostr,1,1); v_item40 := substr(i.codpostr,2,1);
          v_item41 := substr(i.codpostr,3,1); v_item42 := substr(i.codpostr,4,1);
          v_item43 := substr(i.codpostr,5,1);
          -- ???????,??????
          v_item44 := get_tpostn_name(i.codpos,global_v_lang);
          v_item45 := get_tcenter_name(i.codcomp,global_v_lang);
          -- ???????????
          -- ?????
          begin
            select  amtdemax into v_amtedu
              from  tdeductd
             where  dteyreff  = (select max(dteyreff) from tdeductd
                                  where dteyreff  <= p_dteyrepay
                                    and coddeduct = 'D004'
                                    and typdeduct = 'D')
               and  coddeduct = 'D004'
               and  typdeduct = 'D';
          exception when no_data_found then
            v_amtedu := 0;
          end;
          -- ????????
          begin
            select  amtdemax into v_amtned
              from  tdeductd
             where  dteyreff  = (select max(dteyreff) from tdeductd
                                  where dteyreff  <= p_dteyrepay
                                    and coddeduct = 'D005'
                                    and typdeduct = 'D')
               and  coddeduct = 'D005'
               and  typdeduct = 'D';
          exception when no_data_found then
            v_amtned := 0;
          end;
          -- ???????????
          -- ???
          if i.stamarry = 'S' then
              v_tick1 := 'X';
          else
              v_tick1 := null;
          end if;
          -- ?????
          if i.stamarry = 'W' then
              v_tick2 := 'X';
          else
              v_tick2 := null;
          end if;
          --	????????????????
          if i.stamarry = 'M' and i.typtax = '1' then
              v_amtedu := v_amtedu;
              v_amtned := v_amtned;
              v_tick3 := 'X';
          else
              v_tick3 := null;
          end if;
          -- ???????????????????
          if i.stamarry = 'M' and i.typtax = '2' then
              v_tick5 := 'X';
          else
              v_tick5 := null;
          end if;
          --
          v_item50 := nvl(i.qtychedu,0) + nvl(i.qtychned,0);
          v_item51 := least((nvl(i.qtychedu,0) + nvl(i.qtychned,0)),3);
          -- ???????????
          if nvl(i.qtychedu,0) > 3 then
            v_item52 := 0;
            v_item53 := 3;
          else
            v_item53 := nvl(i.qtychedu,0);
            v_item52 := least(nvl(i.qtychned,0),3 - nvl(i.qtychedu,0));
          end if;
          -- Set null
          v_item54 := null; v_item55 := null;
          v_item56 := null; v_item57 := null;
          v_item58 := null; v_item59 := null;
          v_item60 := null; v_item61 := null;
          v_item62 := null; v_item63 := null;
          v_item64 := null; v_item65 := null;
          v_item66 := null; v_item67 := null;
          v_item68 := null; v_item69 := null;
          v_item70 := null; v_item71 := null;
          v_item72 := null; v_item73 := null;
          v_item74 := null; v_item75 := null;
          --
          v_O001    := 0;
          v_O002    := 0;
          v_O003    := 0;
          v_E001    := 0;
          v_E002    := 0;
          v_E003    := 0;
          --
          v_amtsun  := 0;
          v_amtdedf := 0;
          v_amtdspf := 0;
          v_amtduct := 0;
          v_amtpf   := 0;
          --
          begin
            select  stddec(amtproyr,v_codempid,global_v_chken),
                    to_char(stddec(amtsocyr,v_codempid,global_v_chken),'fm999,999,990.00')
              into  v_amtpf, v_item74
              from  ttaxmas
             where  dteyrepay = p_dteyrepay
               and  codempid  = v_codempid;
          exception when no_data_found then
            v_amtpf  := null;
            v_item74 := null;
          end;
          --
          for j in c_masd loop
            v_exist := true;
            if j.amtdeduct > 0 or j.amtspded > 0 then
              if j.coddeduct = 'D025' then			   -- ????????? + ????????????
                v_amtsun := v_amtsun + (j.amtdeduct + j.amtspded);
              elsif j.coddeduct in ('D006') then	 -- ???????????
                if nvl(j.amtdeduct,0) > 0 then     -- ????????????????
                  v_item54 := 'X';
                  v_amtdedf := v_amtdedf + j.amtdeduct;
                else
                  v_item54 := null;
                end if;
                if nvl(j.amtspded,0) > 0 then      -- ???????????
                  v_item56 := 'X';
                  v_amtdspf := v_amtdspf + j.amtspded;
                else
                  v_item56 := null;
                end if;
              elsif j.coddeduct in ('D007') then	 -- ????????????
                if nvl(j.amtdeduct,0) > 0 then     -- ?????????????????
                  v_item55 := 'X';
                  v_amtdedf := v_amtdedf + j.amtdeduct;
                else
                  v_item55 := null;
                end if;
                --
                if nvl(j.amtspded,0) > 0 then      -- ????????????
                  v_item57 := 'X';
                  v_amtdspf := v_amtdspf + j.amtspded;
                else
                  v_item57 := null;
                end if;
              elsif j.coddeduct in ('D014') then	  -- ??????????????????????
                v_item67 := to_char(nvl(j.amtdeduct,0) + nvl(j.amtspded,0),'fm999,999,990.00');
              elsif j.coddeduct in ('D008') then		-- ???????????????
                if nvl(j.amtdeduct,0) > 0 then    -- ????????????????
                  v_item58 := 'X';
                  v_amtduct := v_amtduct + j.amtdeduct;
                else
                  v_item58 := null;
                end if;
                if nvl(j.amtspded,0) > 0 then    --???????????
                  v_item60 := 'X';
                  v_amtduct := v_amtduct + j.amtspded;
                else
                  v_item60 := null;
                end if;
              elsif j.coddeduct in ('D009') then			--????????????????
                if nvl(j.amtdeduct,0) > 0 then   --?????????????????
                  v_item59 := 'X';
                  v_amtduct := v_amtduct + j.amtdeduct;
                else
                  v_item59 := null;
                end if;
                if nvl(j.amtspded,0) > 0 then    --????????????
                  v_item61 := 'X';
                  v_amtduct := v_amtduct + j.amtspded;
                else
                  v_item61 := null;
                end if;
              elsif j.coddeduct in ('D010') then			--????????????????
                v_item69 := to_char((j.amtdeduct + j.amtspded),'fm999,999,990.00');
              elsif j.coddeduct in ('D001','E001','E002','E003') then			--????????????????????
                if j.coddeduct = 'D001' then
                  begin
                    select  stddec(amtproyr,v_codempid,global_v_chken)
                      into 	v_amtpf
                      from  ttaxmas
                     where  dteyrepay = p_dteyrepay
                       and  codempid  = v_codempid;
                  exception when no_data_found then
                    v_amtpf := null;
                  end;
                end if;
                --
                if j.coddeduct in ('E001') then			-- ????????????????
                    v_E001 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;

                if j.coddeduct in ('E002') then			-- ????????????????
                    v_E002 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;

                if j.coddeduct in ('E003') then			-- ????????????????
                    v_E003 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;
                v_item70 := to_char(v_amtpf+v_E001+v_E002+v_E003,'fm999,999,990.00');
              elsif j.coddeduct in ('D011') then			-- RMF
                v_item71 := to_char((nvl(j.amtdeduct,0) + nvl(j.amtspded,0)),'fm999,999,990.00');
              elsif j.coddeduct in ('D012') then			-- LTF
                v_item72 := to_char((nvl(j.amtdeduct,0) + nvl(j.amtspded,0)),'fm999,999,990.00');
              elsif j.coddeduct in ('D013') then			-- ???????????????
                v_item73 := to_char((j.amtdeduct + j.amtspded),'fm999,999,990.00');
              elsif j.coddeduct in ('D002') then			-- ??????????????		???????????
                begin
                  select  to_char(stddec(amtsocyr,v_codempid,global_v_chken),'fm999,999,990.00') into v_item74
                    from  ttaxmas
                   where  dteyrepay = p_dteyrepay
                     and  codempid  = v_codempid;
                exception when no_data_found then
                  v_item74 := null;
                end;
              elsif j.coddeduct in ('O001','O002','O003') then
                if j.coddeduct in ('O001') then			-- ????????????????????
                    v_O001 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;
                --
                if j.coddeduct in ('O002') then			-- ????????????????
                    v_O002 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;
                --
                if j.coddeduct in ('O003') then			-- ??????????
                    v_O003 := (nvl(j.amtdeduct,0) + nvl(j.amtspded,0));
                end if;
                v_item75 := to_char((v_O001+v_O002+v_O003),'fm999,999,990.00');
              end if;
            end if;
          end loop;
          -- ???????????
          v_item50 := nvl(i.qtychedu,0) + nvl(i.qtychned,0);
          v_item51 := least(nvl(to_number(v_item52),0) + nvl(to_number(v_item53),0),3);
          --
          if v_amtsun > 0 then
            v_item64 := to_char(v_amtsun,'fm999,999,990.00');
          end if;
          --
          if v_amtduct > 0 then
            v_item68 := to_char(v_amtduct,'fm999,999,990.00');
          end if;
          --
          if v_amtdedf > 0 then
            v_item65 := to_char(v_amtdedf,'fm999,999,990.00');
          end if;
          --
          if v_amtdspf > 0 then
            v_item66 :=	to_char(v_amtdspf,'fm999,999,990.00');
          end if;
          --
          if p_typrep = '1' then
            insert into ttemprpt
                  (codempid,codapp,numseq,--key
                   item1,item2,item3,item4,
                   item5,item6,item7,item8,item9,							--?????????????????
                   item10,item11,item12,item13,item14,
                   item15,item16,item17,
                   item18,item19,item20,item21,item22,				--?????????????????
                   item23,item24,item25,item26,item27,
                   item28,item29,item30,item31,item32,				--???????
                   item33,item34,item35,item36,item37,
                   item38,item39,item40,item41,item42,
                   item43,item44,item45)
                values
                  (global_v_codempid,'HRPY96R',v_num,
                   v_item1,v_item2,v_item3,v_item4,
                   v_item5,v_item6,v_item7,v_item8,v_item9,
                   v_item10,v_item11,v_item12,v_item13,v_item14,
                   v_item15,v_item16,v_item17,
                   v_item18,v_item19,v_item20,v_item21,v_item22,
                   v_item23,v_item24,v_item25,v_item26,v_item27,
                   null,null,null,null,v_item32,
                   null,null,null,v_item36,v_item37,
                   v_item38,v_item39,v_item40,v_item41,v_item42,
                   v_item43,v_item44,v_item45);
          else
            insert into ttemprpt
                  (codempid,codapp,numseq,--key
                   item1,item2,item3,item4,
                   item5,item6,item7,item8,item9,							--?????????????????
                   item10,item11,item12,item13,item14,
                   item15,item16,item17,
                   item18,item19,item20,item21,item22,				--?????????????????
                   item23,item24,item25,item26,item27,
                   item28,item29,item30,item31,item32,				--???????
                   item33,item34,item35,item36,item37,
                   item38,item39,item40,item41,item42,
                   item43,item44,item45,
                   item46,item47,item48,item49,								--other
                   item50,item51,item52,item53,					--??????????
                   item54,item55,item56,item57,					--??????????-?????(Check box)
                   item58,item59,item60,item61,         --???????????????-?????(Check box)
                   item62,item63,												--RMF,LTF (????)
                   item64,item65,item66,item67,item68,  --?????????
                   item69,item70,item71,item72,item73,
                   item74,item75,item76,
                   item77,item78,item79,item80,item81)
                values
                  (global_v_codempid,'HRPY96R',v_num,
                   v_item1,v_item2,v_item3,v_item4,
                   v_item5,v_item6,v_item7,v_item8,v_item9,
                   v_item10,v_item11,v_item12,v_item13,v_item14,
                   v_item15,v_item16,v_item17,
                   v_item18,v_item19,v_item20,v_item21,v_item22,
                   v_item23,v_item24,v_item25,v_item26,v_item27,
                   null,null,null,null,v_item32,
                   null,null,null,v_item36,v_item37,
                   v_item38,v_item39,v_item40,v_item41,v_item42,
                   v_item43,v_item44,v_item45,
                   null,null,null,null,
                   v_item50,v_item51,v_item52,v_item53,					--??????????
                   v_item54,v_item55,v_item56,v_item57,					--??????????-?????(Check box)
                   v_item58,v_item59,v_item60,v_item61,         --???????????????-?????(Check box)
                   null,null,																		--RMF,LTF (????)
                   v_item64,v_item65,v_item66,v_item67,v_item68,--?????????
                   v_item69,v_item70,v_item71,v_item72,v_item73,
                   v_item74,v_item75,v_codempid,
                   v_tick1,v_tick2,v_tick3,v_tick4,v_tick5);
          end if;
        end if;
      end if; --if :b_index.typrep
    end loop;
    commit;
    --
    obj_data.put('coderror','200');
    obj_data.put('response','Successfully');
    obj_data.put('status',200);
    obj_data.put('message','https://www.google.com/');
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;*/

  procedure check_detail as
  begin
    if p_codempid is not null then
      begin
        select codcomp into p_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      end;
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal)  then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    --
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_detail;

  procedure get_detail(json_str_input in clob,json_str_output out clob)as
    json_str_tmp  clob;--26/11/2020
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
      gen_index(json_str_tmp);--26/11/2020

    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob)as
    obj_rows           json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_chk              number := 0;

    cursor c_tcoddtax is
      select numseq, desdeduct, formula, statement, codcompy,dteyreff
        from tcoddtax
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteyreff = (select max(dteyreff) from tcoddtax
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteyreff <= (p_dteyrepay - global_v_zyear))
      order by numseq;

    cursor c_tcoddtax_default is
      select numseq, desdeduct, formula, statement, codcompy
        from tcoddtax
       where codcompy = 'PPS'
         and dteyreff = 2019
      order by numseq;

  begin
    obj_rows := json_object_t();

    begin
          select count(*)
          into v_chk
        from tcoddtax
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteyreff = (select max(dteyreff) from tcoddtax
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteyreff <= (p_dteyrepay - global_v_zyear));
    end;

    if v_chk > 0 then
        for r1 in c_tcoddtax loop
          obj_data := json_object_t();
          v_rcnt   := v_rcnt + 1;
          obj_data.put('coderror','200');
          obj_data.put('dteyreff',p_dteyrepay - global_v_zyear);
          obj_data.put('numseq',r1.numseq);
          obj_data.put('codcompy',r1.codcompy);
          obj_data.put('desdeduct',r1.desdeduct);
          obj_data.put('formula',r1.formula);
        --obj_data.put('desc_formula',get_logical_name('HRAL92M6',r1.formula,global_v_lang));
          obj_data.put('desc_formula',hcm_formula.get_description(r1.formula,global_v_lang));
          obj_data.put('statement',r1.statement);
          if r1.dteyreff < p_dteyrepay then
            obj_data.put('flgAdd',true);
          else
            obj_data.put('flgAdd',false);
          end if;
          obj_rows.put(to_char(v_rcnt - 1),obj_data);
        end loop;
    else
        for r2 in c_tcoddtax_default loop
          obj_data := json_object_t();
          v_rcnt   := v_rcnt + 1;
          obj_data.put('coderror','200');
          obj_data.put('dteyreff',p_dteyrepay - global_v_zyear);
          obj_data.put('numseq',r2.numseq);
          obj_data.put('codcompy',hcm_util.get_codcomp_level(p_codcomp,1));
          obj_data.put('desdeduct',r2.desdeduct);
          obj_data.put('formula',r2.formula);
    --      obj_data.put('desc_formula',get_logical_name('HRAL92M6',r1.formula,global_v_lang));
          obj_data.put('desc_formula',hcm_formula.get_description(r2.formula,global_v_lang));
          obj_data.put('statement',r2.statement);
          obj_data.put('flg','edit');
          obj_data.put('flgEdit',true);
          obj_data.put('flgAdd',true);
          obj_rows.put(to_char(v_rcnt - 1),obj_data);
        end loop;
    end if;
    json_str_output := obj_rows.to_clob;
  end gen_detail;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
    obj_param_json json_object_t;
    param_json_row json_object_t;
    obj_calculator json_object_t;
    -- get param json
    v_codcompy      tcoddtax.codcompy%type;
    v_dteyreff      tcoddtax.dteyreff%type;
    v_numseq        tcoddtax.numseq%type;
    v_formula       tcoddtax.formula%type;
    v_statement     tcoddtax.statement%type;
    v_desdeduct     tcoddtax.desdeduct%type;
    v_flg           varchar2(100 char);
  begin
    obj_calculator := json_object_t();
    initial_value(json_str_input);
    obj_param_json        := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json,to_char(i));
        --
        v_codcompy        := hcm_util.get_string_t(param_json_row,'codcompy');
        v_dteyreff        := hcm_util.get_string_t(param_json_row,'dteyreff');
        v_numseq          := hcm_util.get_string_t(param_json_row,'numseq');
        v_desdeduct       := hcm_util.get_string_t(param_json_row,'desdeduct');
        obj_calculator    := hcm_util.get_json_t(param_json_row,'desc_calculator');
        v_formula         := hcm_util.get_string_t(obj_calculator, 'code');
        v_statement       := hcm_util.get_string_t(obj_calculator, 'description');
        v_flg             := hcm_util.get_string_t(param_json_row,'flg');
        --
        if param_msg_error is null then
          if v_flg in ('edit','add') then
            begin
              insert into tcoddtax (codcompy,dteyreff,numseq,desdeduct,formula,statement,coduser,codcreate)
                   values (v_codcompy,v_dteyreff,v_numseq,v_desdeduct,v_formula,v_statement,global_v_coduser,global_v_coduser );
            exception when dup_val_on_index then
              update tcoddtax
                 set formula     =  v_formula,
                     statement   =  v_statement,
                     dteupd      =  trunc(sysdate),
                     desdeduct   = v_desdeduct,
                     coduser     =  global_v_coduser
               where codcompy    =  v_codcompy
                 and dteyreff    =  v_dteyreff
                 and numseq      =  v_numseq;
            end;
          end if;
        end if;
      end loop;
      --
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      end if;
    end if;
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;
end HRPY96R;

/

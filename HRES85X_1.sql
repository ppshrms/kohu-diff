--------------------------------------------------------
--  DDL for Package Body HRES85X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES85X" AS

  procedure initial_value(json_str in clob) AS
  json_obj        json_object_t;
  BEGIN
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  END initial_value;

  procedure check_index is
    v_flgsecu				boolean;
    v_zupdsal       varchar2(8);
  begin
    if nvl(p_dteyrepay,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyrepay');
      return;
    end if;

    v_flgsecu := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
    if not v_flgsecu then
      return;
    end if;
  end check_index;

  procedure get_data_emp(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_emp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_emp(json_str_output out clob) is
    obj_data        json_object_t;
    temploy_name    varchar2(500 char);
    v_codcomp       varchar2(100 char);
    v_typpayroll    varchar2(100 char);
  begin
    begin
      select codcomp, typpayroll
        into v_codcomp,v_typpayroll
        from temploy1
      where codempid = b_index_codempid;
        exception when no_data_found then
          v_codcomp        := null;
          v_typpayroll     := null;
    end;

    temploy_name := get_temploy_name(b_index_codempid,global_v_lang);

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('image', b_index_codempid);
    obj_data.put('codempid', b_index_codempid);
    obj_data.put('desc_codempid', temploy_name);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('typpayroll', v_typpayroll);
    obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', v_typpayroll, global_v_lang) );
    json_str_output := obj_data.to_clob;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

   procedure gen_index (json_str_output out clob)as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_result    json_object_t;
   	v_exist				boolean := false;
    v_secur				boolean := false;
    v_flgsecu			boolean := false;
    v_stdate			date;
    v_endate			date;
    v_codempid		temploy1.codempid%type;
    v_flgtax			temploy3.flgtax%type;
    v_codsoc			tcontrpy.codpaypy2%type;
    v_codpf				tcontrpy.codpaypy3%type;
    v_codcomp     varchar2(100);
    i							number;
    v_num					number := 0;
    v_numseq			number := 0;
    v_codapp		  varchar2(4000 char) := 'HRES85X' ;
    v_item1				varchar2(4000 char);
    v_item2				varchar2(4000 char);
    v_item3				varchar2(4000 char);
    v_item4				varchar2(4000 char);
    v_item5				varchar2(4000 char);
    v_item6				varchar2(4000 char);
    v_item11			varchar2(4000 char);
    v_item12			varchar2(4000 char);
    v_item13			varchar2(4000 char);
    v_item14			varchar2(4000 char);
    v_item21			varchar2(4000 char);
    v_item22			varchar2(4000 char);
    v_item23			varchar2(4000 char);
    v_item24			varchar2(4000 char);
    v_item57			varchar2(4000 char);
    v_item81			varchar2(4000 char);
    v_item82			varchar2(4000 char);
    v_item83			varchar2(4000 char);
    v_temp38			number;
    v_temp39			number;
    v_temp40			number;
    v_temp41			number;
    v_temp42			number;
    v_temp43			number;
    v_temp44			number;
    v_temp45			number;
    v_temp47			number;
    v_temp48			number;
    v_temp52			number;
    v_temp53			number;
    v_temp54			number;
    v_temp55			number;
    v_temp56			number;
    v_temp57			number;
    v_temp58			number;
    v_temp59			number;
    v_temp60			number;
    v_temp61			number;
    v_temp62			number;

    v_item63			  varchar2(4000 char);
    v_item64			  varchar2(4000 char);
    v_name          varchar2(4000 char);
    v_desc_codpos   varchar2(4000 char);
    v_folder        tfolderd.folder%type;
    v_has_image     varchar2(1) := 'N';
    v_typsign       tsetsign.typsign%type;
    v_codempid2     tsetsign.codempid%type;
    v_codpos        tsetsign.codpos%type;
    v_signname      tsetsign.signname%type;
    v_posname       tsetsign.posname%type;
    v_namsign       tsetsign.namsign%type;

    v_codsubdistc   temploy2.codsubdistc%type;
    v_coddistc      temploy2.coddistc%type;
    v_codprovc      temploy2.codprovc%type;
    v_codpfinf			tpfmemb.codpfinf%type;
    v_ratebfac			number ;

    v_zupdsal       varchar2(1);
    v_tsetcomp      number;

    v_year          number := 0;
    v_dteprint      date;
    v_sysdate       date  := trunc(sysdate);
    type typpayt is table of varchar2(4) index by binary_integer;
    v_typpayt		typpayt;

   cursor c_emp is
	  select a.codempid, a.codcomp, a.numlvl
	   from temploy1 a
    where a.codempid = nvl(b_index_codempid, a.codempid)
	    and	exists (select codempid
								  from ttaxinc b
								  where b.codempid = a.codempid
								    and dteyrepay  = p_dteyrepay
								    and typpayt is not null)
	   order by a.codempid, a.codcomp;

    cursor c_ttaxinc is
      select hcm_util.get_codcomp_level(codcomp,1)codcompy,
             sum(decode(typpayt, v_typpayt(1), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc1,
             sum(decode(typpayt, v_typpayt(1), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax1,
             sum(decode(typpayt, v_typpayt(2), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc2,
             sum(decode(typpayt, v_typpayt(2), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax2,
             sum(decode(typpayt, v_typpayt(3), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc3,
             sum(decode(typpayt, v_typpayt(3), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax3,
             sum(decode(typpayt, v_typpayt(4), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc4,
             sum(decode(typpayt, v_typpayt(4), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax4,
             sum(decode(typpayt, v_typpayt(5), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc5,
             sum(decode(typpayt, v_typpayt(5), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax5,
             sum(decode(typpayt, v_typpayt(6), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc6,
             sum(decode(typpayt, v_typpayt(6), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax6,
             sum(decode(typpayt, v_typpayt(7), nvl(stddec(amtinc,codempid, v_chken),0),0)) amtinc7,
             sum(decode(typpayt, v_typpayt(7), nvl(stddec(amttax,codempid, v_chken),0),0)) amttax7
      from ttaxinc
      where codempid = v_codempid
        and dteyrepay = p_dteyrepay
        and typpayt is not null
      group by hcm_util.get_codcomp_level(codcomp,1)
      order by hcm_util.get_codcomp_level(codcomp,1);
--
    cursor c_tcodcert is
      select codcodec
        from tcodcert
    order by codcodec;

  begin
    begin
      select  codcomp
      into    v_codcomp
      from    temploy1
      where   codempid    = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    --
    begin
      select codpaypy2, codpaypy3
      into v_codsoc, v_codpf
      from tcontrpy
      where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
        and dteeffec = (select max(dteeffec)
                        from tcontrpy
                        where	codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                          and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TCONTRPY');
    end;

    del_temp('HRES85X',b_index_codempid);
    for i in 1..7 loop
      v_typpayt(i) := null;
    end loop;

    i := 0;
    for r_tcodcert in c_tcodcert loop
      i := i + 1;
      v_typpayt(i) := r_tcodcert.codcodec;
      if i >= 7 then
        exit;
      end if;
    end loop;

    begin
      select numcotax, numcotax, replace(adrcomt,chr(10),' ')
        into v_item2,v_item3,v_item12
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1);
      v_item11 := get_tcompny_name(hcm_util.get_codcomp_level(v_codcomp,1),'102');
    exception when no_data_found then
      v_item2  := null;
      v_item3  := null;
      v_item12 := null;
    end;

  v_dteprint  := v_sysdate;
	v_item23    := get_nammthful(to_char(v_dteprint,'mm'), '102');
	v_item23    := to_char(v_dteprint,'dd')||'  '||v_item23||'  '||hcm_util.get_year_buddhist_era(to_char(v_dteprint,'yyyy'));

    begin
      select sum(qtycode) into v_tsetcomp
      from tsetcomp
      where numseq in (1,2,3);
    end;

    begin
     select nvl(max(numseq),0) into v_numseq
       from ttemprpt
      where codempid = b_index_codempid
        and codapp = v_codapp ;
      v_num   := v_numseq;
--    exception when no_data_found then
--      v_numseq := 0;
    end;
    for r_emp in c_emp loop
      v_exist := true;
        v_secur := true;
        v_codempid := r_emp.codempid;

        v_item13 := get_temploy_name(v_codempid,'102');
        v_item57 := get_tcenter_name(substr(r_emp.codcomp,1,v_tsetcomp),'102');
        begin
          select numoffid,adrcontt ,codsubdistc ,coddistc ,codprovc
            into v_item4,v_item14 ,v_codsubdistc ,v_coddistc ,v_codprovc
            from temploy2
           where codempid = v_codempid;
        exception when no_data_found then
          v_item4        := null;
          v_item14       := null;
          v_codsubdistc  := null;
          v_coddistc     := null;
          v_codprovc     := null;
        end;

        if v_codsubdistc is not null then
          if v_codprovc = '1000' then
             v_item14 := v_item14||' '||get_label_name('HRPY94R',global_v_lang,870)||' '||get_tsubdist_name(v_codsubdistc,global_v_lang);
          else
             v_item14 := v_item14||' '||get_label_name('HRPY94R',global_v_lang,860)||' '||get_tsubdist_name(v_codsubdistc,global_v_lang);
          end if;

        end if;

        if v_coddistc is not null then
           if v_codprovc = '1000' then
              v_item14 := v_item14||' '||get_label_name('HRPY94R',global_v_lang,850)||' '||get_tcoddist_name(v_coddistc,global_v_lang);
           else
              v_item14 := v_item14||' '||get_label_name('HRPY94R',global_v_lang,840)||' '||get_tcoddist_name(v_coddistc,global_v_lang);
           end if;
        end if;

        if v_codprovc is not null then
           v_item14 := v_item14||' '||get_label_name('HRPY94R','102',830)||get_tcodec_name('tcodprov',v_codprovc,'102');
        end if;

        begin
          select numtaxid,flgtax
          into v_item5,v_flgtax
          from temploy3
          where codempid = v_codempid;
        exception when no_data_found then
          v_item5  := null;
          v_flgtax := null;
        end;
  --<<user14||STA3600380
        if v_item5 is not null then
           v_item4 := v_item5;
           v_item5 := null;
        end if;
        --if v_item4 = v_item5 then
        --	v_item5 := null;
        --end if;
  -->>user14||STA3600380

        for r1 in c_ttaxinc loop
          v_year      := hcm_appsettings.get_additional_year;
          v_item6 := to_char(p_dteyrepay)+ v_year;
          v_item1 := substr(v_item6,3,2)||'/'||v_codempid;
          v_temp52 := null;
          --Modify 01/09/2552
          begin
            select numcotax,numcotax,replace(adrcomt,chr(10),' '),signname,a.codcompy
              into v_item2,v_item3,v_item12,v_item81,v_item83
              from tcompny a,tsetsign b
             where a.codcompy = r1.codcompy
              and  a.codcompy = b.codcompy(+)
              and b.coddoc(+) = 'HRPY94R';
            v_item11 := get_tcompny_name(hcm_util.get_codcomp_level(r1.codcompy,1),'102');
          exception when no_data_found then
            v_item2  := null;
            v_item3  := null;
            v_item12 := null;
            v_item81 := null;
            v_item83 := null;
          end;

          --End Modify 01/09/2552

  -->>user14||STA3600380
          --if :b_index.typdata = 2 then
--          if p_typdata = 2 then
              begin
                select numseq
                into v_temp52
                from ttaxrep
                where codempid = v_codempid
                  and codcompy = r1.codcompy
                  and dteyear  = p_dteyrepay;
              exception when no_data_found then
                v_temp52 := null;
              end;
--            else

--            end if;
          --end if;
  -->>user14||STA3600380
          if (r1.amtinc1 <> 0) or (r1.amttax1 <> 0) then
            v_temp38 := r1.amtinc1;
            v_temp39 := r1.amttax1;
          else
            v_temp38 := null;
            v_temp39 := null;
          end if;
          if (r1.amtinc2 <> 0) or (r1.amttax2 <> 0) then
            v_temp53 := r1.amtinc2;
            v_temp54 := r1.amttax2;
          else
            v_temp53 := null;
            v_temp54 := null;
          end if;
          if (r1.amtinc3 <> 0) or (r1.amttax3 <> 0) then
            v_temp55 := r1.amtinc3;
            v_temp56 := r1.amttax3;
          else
            v_temp55 := null;
            v_temp56 := null;
          end if;
          if (r1.amtinc4 <> 0) or (r1.amttax4 <> 0) then
            v_temp40 := r1.amtinc4;
            v_temp41 := r1.amttax4;
          else
            v_temp40 := null;
            v_temp41 := null;
          end if;
          if (r1.amtinc5 <> 0) or (r1.amttax5 <> 0) then
            v_temp57 := r1.amtinc5;
            v_temp58 := r1.amttax5;
          else
            v_temp57 := null;
            v_temp58 := null;
          end if;
          if (r1.amtinc6 <> 0) or (r1.amttax6 <> 0) then
            v_temp59 := r1.amtinc6;
            v_temp60 := r1.amttax6;
          else
            v_temp59 := null;
            v_temp60 := null;
          end if;
          if (r1.amtinc7 <> 0) or (r1.amttax7 <> 0) then
            v_temp61 := r1.amtinc7;
            v_temp62 := r1.amttax7;
          else
            v_temp61 := null;
            v_temp62 := null;
          end if;
          v_item21 := null;
          v_item24 := null;
          if (v_temp59 > 0) or (v_temp60) > 0 then
            v_item21 := get_tcodec_name('TCODCERT',v_typpayt(6),'102');
          end if;
          if (v_temp61 > 0) or (v_temp62 > 0) then
            v_item24 := get_tcodec_name('TCODCERT',v_typpayt(7),'102');
          end if;
          v_temp42 := nvl(r1.amtinc1,0) + nvl(r1.amtinc2,0) + nvl(r1.amtinc3,0) + nvl(r1.amtinc4,0) + nvl(r1.amtinc5,0) + nvl(r1.amtinc6,0) + nvl(r1.amtinc7,0);
          v_temp43 := nvl(r1.amttax1,0) + nvl(r1.amttax2,0) + nvl(r1.amttax3,0) + nvl(r1.amttax4,0) + nvl(r1.amttax5,0) + nvl(r1.amttax6,0) + nvl(r1.amttax7,0);
          if v_temp43 < 0 then
            v_temp43 := 0;
          end if;
          v_item22 := '( '||get_amt_nameth(v_temp43)||' )';
          v_temp47 := 0; v_temp48 := 0;
          if v_flgtax = 1 then
            v_temp48 := 1;
          elsif v_flgtax = 2 THEN
            v_temp47 := 1;
          end if;
          --Modify 13/01/2544
          begin
            select codpfinf
            into	 v_codpfinf
            from   tpfmemb
            where  codempid = v_codempid;
          exception when no_data_found then
            v_codpfinf := null;
          end;
          v_ratebfac := 0 ;
          -->>user19 22/11/2013
          if v_ratebfac <= 0 then
            v_item82 := 'p_numpf';
            begin
              select nvl(stddec(amtpay1,codempid, v_chken),0) + nvl(stddec(amtpay2,codempid, v_chken),0) +
                     nvl(stddec(amtpay3,codempid, v_chken),0) + nvl(stddec(amtpay4,codempid, v_chken),0) +
                     nvl(stddec(amtpay5,codempid, v_chken),0) + nvl(stddec(amtpay6,codempid, v_chken),0) +
                     nvl(stddec(amtpay7,codempid, v_chken),0) + nvl(stddec(amtpay8,codempid, v_chken),0) +
                     nvl(stddec(amtpay9,codempid, v_chken),0) + nvl(stddec(amtpay10,codempid, v_chken),0) +
                     nvl(stddec(amtpay11,codempid, v_chken),0) + nvl(stddec(amtpay12,codempid, v_chken),0)
              into v_temp44
              from tytdinc
              where codcompy = r1.codcompy
                and dteyrepay = p_dteyrepay
                and codempid = v_codempid
                and codpay = v_codpf;
            exception when no_data_found then
              v_temp44 := 0;
            end;
          else
            v_temp44 := 0;
            v_item82 := null;
          end if;
          --End Modify 13/01/254
          begin
            select nvl(stddec(amtpay1,codempid, v_chken),0) + nvl(stddec(amtpay2,codempid, v_chken),0) +
                   nvl(stddec(amtpay3,codempid, v_chken),0) + nvl(stddec(amtpay4,codempid, v_chken),0) +
                   nvl(stddec(amtpay5,codempid, v_chken),0) + nvl(stddec(amtpay6,codempid, v_chken),0) +
                   nvl(stddec(amtpay7,codempid, v_chken),0) + nvl(stddec(amtpay8,codempid, v_chken),0) +
                   nvl(stddec(amtpay9,codempid, v_chken),0) + nvl(stddec(amtpay10,codempid, v_chken),0) +
                   nvl(stddec(amtpay11,codempid, v_chken),0) + nvl(stddec(amtpay12,codempid, v_chken),0)
            into v_temp45
            from tytdinc
            where codcompy = r1.codcompy
              and dteyrepay = p_dteyrepay
              and codempid = v_codempid
              and codpay = v_codsoc;
          exception when no_data_found then
            v_temp45 := 0;
          end;

      begin
        select typsign,codempid,codcomp,
               codpos ,signname,posname,
               namsign
          into v_typsign,v_codempid2,v_codcomp,
               v_codpos ,v_signname,v_posname,
               v_namsign
          from tsetsign
         where codcompy = hcm_util.get_codcomp_level(nvl(v_codcomp,r_emp.codcomp),1)
           and coddoc = 'HRPY94R';

          if v_typsign in ('1','2') then
             if v_typsign = '2' then
              begin
                select codempid
                  into v_codempid2
                  from temploy1
                 where codpos  = v_codpos
                   and codcomp like nvl(v_codcomp,'')||'%'
                   and staemp in ('1','3')
                   and rownum  = 1
                order by codempid;
              exception when no_data_found then
                v_codempid2 := null;
              end;
            end if;
             begin
                select namsign
                  into v_namsign
                  from tempimge
                 where codempid = v_codempid2;
              exception when no_data_found then
                v_namsign := null;
              end;
          begin
            select get_tlistval_name('CODTITLE',codtitle,'102')||namfirstt|| ' ' ||namlastt,
                   get_tpostn_name(codpos,'102')
              into v_name,v_desc_codpos
              from temploy1
             where codempid = v_codempid2;
          exception when no_data_found then
            v_name        := null;
            v_desc_codpos := null;
          end;

              begin
                select folder
                  into v_folder
                  from tfolderd
                 where codapp = 'HRPMC2E2';
              exception when no_data_found then
                v_folder := null;
              end;
            elsif v_typsign = '3' then
              v_name := v_signname;
              v_desc_codpos := v_posname;
              --
              begin
                select folder
                  into v_folder
                  from tfolderd
                 where codapp = 'HRCO02E';
              exception when no_data_found then
                v_folder := null;
              end;
           end if;
          exception when no_data_found then
            null;
          end;

         --<<check existing image
          if v_namsign is not null then
            v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
            v_has_image   := 'Y';
          end if;

          if v_name is not null then
            v_item81 := v_name;
          end if;

          v_num := v_num + 1;
          insert into ttemprpt
            (codapp, codempid, numseq,
             item1,item2,item3,item4,item5,item6,
             item11,item12,item13,item14,
             item21,item22,item23,item24,item56,item57,
             item81,item82,item83,
             temp38,temp39,
             temp40,temp41,temp42,temp43,temp44,temp45,temp47,temp48,
             temp52,temp53,temp54,temp55,temp56,temp57,temp58,temp59,
             temp60,temp61,temp62,item63,item64)
          values
            (v_codapp, global_v_codempid, v_num,
             v_item1,v_item2,'',v_item4,v_item5,v_item6, -- v_item3 => '' || Error Program #7605 || 18/2/2565
             (v_item11),v_item12,v_item13,v_item14,
--             (v_codempid || '   ' || v_item11),v_item12,v_item13,v_item14,
             v_item21,v_item22,v_item23,v_item24,v_codempid,v_item57,--user46
             v_item81,v_item82,v_item83,
             v_temp38,v_temp39,
             v_temp40,v_temp41,v_temp42,v_temp43,v_temp44,v_temp45,v_temp47,v_temp48,
             v_temp52,v_temp53,v_temp54,v_temp55,v_temp56,v_temp57,v_temp58,v_temp59,
             v_temp60,v_temp61,v_temp62,v_namsign,v_has_image);
        end loop; -- for c_ttaxinc
--      end if; -- v_flgsecu
    end loop; -- for c_emp

    if not v_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxinc');
    elsif not v_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);


  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


END HRES85X;

/

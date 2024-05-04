--------------------------------------------------------
--  DDL for Package Body HRPY98R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY98R" as
  function split_number_id (v_item number) return varchar2 as
  begin
    if to_char(v_item) is not null then
        return substr(v_item,1,1)||'-'||
               substr(v_item,2,1)||substr(v_item,3,1)||substr(v_item,4,1)||substr(v_item,5,1)||'-'||
               substr(v_item,6,1)||substr(v_item,7,1)||substr(v_item,8,1)||substr(v_item,9,1)||substr(v_item,10,1)||'-'||
               substr(v_item,11,1)||substr(v_item,12,1)||'-'||
               substr(v_item,13,1);
    else
        return '';
    end if;
  end split_number_id;

  procedure get_page_number (p_record_per_page in number,
                             p_sum_page  out number) as
    v_record      number := 0;
    cursor c_grpemp is
      select t1.codempid,count(t1.codpay) recpay
       from	tinctxpnd t1,ttaxcur t2
      where t1.codempid = t2.codempid
        and t1.dteyrepay = t2.dteyrepay
        and t1.dtemthpay = t2.dtemthpay
        and t1.numperiod = t2.numperiod
        and t1.codcomp like p_codcomp||'%'
        and	t1.dteyrepay = (p_dteyrepay - global_v_zyear)
        and t2.typincom = decode(p_typincom,'A',t2.typincom,p_typincom)
        and t2.typincom in ('3','4','5')
        and to_number(stddec(t1.amttax,t1.codempid,global_v_chken)) > 0
        and t1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
        and exists (select codcomp
                      from tusrcom
                     where coduser = global_v_coduser
                       and t1.codcomp like codcomp||'%')
      group by t1.codempid
      order by t1.codempid;
  begin
    for r_grpemp in c_grpemp loop
      if r_grpemp.recpay > 3 then
        v_record :=	nvl(v_record,0)+r_grpemp.recpay;
      else
        v_record :=	nvl(v_record,0)+3;
      end if;
    end loop;
    p_sum_page := ceil(v_record/p_record_per_page);
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
    p_typrep     := to_number(hcm_util.get_string_t(obj_detail,'p_typrep'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'p_codcomp');
    p_typincom   := hcm_util.get_string_t(obj_detail,'p_typincom');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_detail as
    v_secur     boolean := false;
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;

      v_secur :=  secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
  end;

  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      if p_typrep = 1 then
        gen_detail_sum(json_str_output);
      elsif p_typrep = 2 then
        gen_detail_det(json_str_output);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail_sum(json_str_output out clob) as
    v_numcotax          varchar2(4000 char);

    v_typsign           tsetsign.typsign%type;
    v_codempid          tsetsign.codempid%type;
    v_codcomp           tsetsign.codcomp%type;
    v_codpos            tsetsign.codpos%type;
    v_signname          tsetsign.signname%type;
    v_posname           tsetsign.posname%type;
    v_namsign           tsetsign.namsign%type;
    --
    v_name              varchar2(4000 char);
    v_desc_codpos       varchar2(4000 char);
    v_folder            tfolderd.folder%type;
    --
    v_count             number := 0;
--4913
    v_rec               number := 0;
--4913
    obj_data            json_object_t;
    obj_rows            json_object_t := json_object_t();
    obj_detail          json_object_t := json_object_t();
    obj_json            json_object_t := json_object_t();
    --
    v_namst             varchar2(4000 char);
    v_namcom            varchar2(4000 char);
    v_building          varchar2(4000 char);
    v_roomno            varchar2(4000 char);
    v_floor		          varchar2(4000 char);
    v_village           varchar2(4000 char);
    v_addrno            varchar2(4000 char);
    v_moo               varchar2(4000 char);
    v_soi               varchar2(4000 char);
    v_road              varchar2(4000 char);
    v_codsubdist        varchar2(4000 char);
    v_coddist           varchar2(4000 char);
    v_codprovr          varchar2(4000 char);
    v_zipcode           varchar2(4000 char);
    v_numtele           varchar2(4000 char);
    v_yeartax           varchar2(4000 char);
    v_flgsecu           boolean := false;
    cursor c_compny is
      select codcompy,codsubdist,coddist,codprovr,
             namstt,namcomt,buildingt,roomnot,floort,villaget,addrnot,moot,soit,roadt,
             zipcode,numtele,numfax,email,website,numcotax,
             numacsoc,descomp,dteupd,coduser
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);

    cursor c_tinctxpnd is
      select t1.codcomp,t1.typinc,(count(distinct t1.codempid)) numrec,t1.codempid,
             nvl(sum(to_number(stddec(t1.amtinc,t1.codempid,global_v_chken))),0) amtinc,
             nvl(sum(to_number(stddec(t1.amttax,t1.codempid,global_v_chken))),0) amttax
        from tinctxpnd t1,ttaxcur t2
       where t1.codempid = t2.codempid
         and t1.dteyrepay = t2.dteyrepay
         and t1.dtemthpay = t2.dtemthpay
         and t1.numperiod = t2.numperiod
         and t1.codcomp like p_codcomp||'%'
         and t1.dteyrepay  = (p_dteyrepay - global_v_zyear)
        and t2.typincom = decode(p_typincom,'A',t2.typincom,p_typincom)
        and t2.typincom in ('3','4','5')
--         and to_number(stddec(t1.amttax,t1.codempid,global_v_chken)) > 0
--         and t1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
--         and exists(select codcomp
--                      from tusrcom
--                     where coduser = global_v_coduser
--                       and t1.codcomp like codcomp||'%')
        group by t1.codempid,t1.codcomp,t1.typinc
        order by t1.codempid,t1.codcomp,t1.typinc;

    v_flg_exist         boolean := false;
    v_numrec            number;
    --
    v_numoffid          temploy2.numoffid%type;
    v_numtaxid          temploy3.numtaxid%type;
    v_namfirstt         temploy1.namfirstt%type;
    v_namlastt          temploy1.namlastt%type;
    v_adrregt           temploy2.adrregt%type;
    v_amtinc_all        number := 0;
    v_amttax_all        number := 0;
    -- param default --
    v_attachment        varchar2(1 char) := 'N';
    v_submission        varchar2(1 char) := 'N';
    --
    v_record            number := 0;
    sum_page            number := 0;
    v_has_image   varchar2(1) := 'N';

    v_resultmod    number;
    v_resultdivide number;
    v_numpage number;
  begin

    begin
      delete ttemprpt where codempid = global_v_codempid
                        and codapp   = p_codapp1;
    end;
    --
    for r1 in c_compny loop
      v_namst   	 := r1.namstt;
      v_namcom  	 := r1.namcomt;
      v_building 	 := r1.buildingt;
      v_roomno  	 := r1.roomnot;
      v_floor   	 := r1.floort;
      v_village 	 := r1.villaget;
      v_addrno  	 := r1.addrnot;
      v_moo     	 := r1.moot;
      v_soi     	 := r1.soit;
      v_road    	 := r1.roadt;
      v_numcotax   := split_number_id(r1.numcotax);
      v_codsubdist := get_tsubdist_name(r1.codsubdist,global_v_lang);
      v_coddist    := get_tcoddist_name(r1.coddist,global_v_lang);
      v_codprovr   := get_tcodec_name('TCODPROV',r1.codprovr,global_v_lang);
      v_zipcode    := r1.zipcode;
      v_numtele    := r1.numtele;
      v_yeartax    := p_dteyrepay;
      -- default submission form --
      v_submission := 'Y';
    end loop ;
    --
    if v_village is not null then
      v_village	:= v_village;
    else
      v_village	:= null;
    end if;
    -- get page number --
    get_page_number (20,sum_page);
    --
    begin
      select typsign,codempid,codcomp,
             codpos ,signname,posname,
             namsign
        into v_typsign,v_codempid,v_codcomp,
             v_codpos ,v_signname,v_posname,
             v_namsign
        from tsetsign
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and coddoc = 'HRPY98R';
      --
      if v_typsign in ('1','2') then
          if v_typsign = '2' then
            begin
              select codempid
                into v_codempid
                from temploy1
               where codpos  = v_codpos
                 and codcomp like nvl(v_codcomp,'')||'%'
                 and staemp in ('1','3')
                 and rownum  = 1
              order by codempid;
            exception when no_data_found then
              v_codempid := null;
            end;
          end if;
        begin
          select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||namfirstt|| ' ' ||namlastt,
                 get_tpostn_name(codpos,global_v_lang)
            into v_name,v_desc_codpos
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_name        := null;
          v_desc_codpos := null;
        end;
        --
        begin
          select namsign
            into v_namsign
            from tempimge
           where codempid = v_codempid;
        exception when no_data_found then
          v_namsign := null;
        end;
        --
        begin
          select folder
            into v_folder
            from tfolderd
           where codapp = 'HRPMC2E2';
        exception when no_data_found then
          v_namsign := null;
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
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end;

      --<<check existing image
      if v_namsign is not null then
        v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
        v_has_image   := 'Y';
      end if;
      -->>

    --
    for r1 in c_tinctxpnd loop
      v_flg_exist := true;
--4913
      v_rec := v_rec + 1;
--4913

--    v_flgsecu := true;
      v_flgsecu := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgsecu  then
        v_amtinc_all        := v_amtinc_all + nvl(r1.amtinc,0);
        v_amttax_all        := v_amttax_all + nvl(r1.amttax,0);

        v_count := v_count + 1;
      end if;
    end loop;

    v_resultmod := mod(v_count,7);
    v_resultdivide := floor(v_count/7);

    if v_resultdivide = 0 AND v_resultmod <= 4 then
        v_numpage := 1;
    elsif v_resultmod <= 4 then
        v_numpage := v_resultdivide + 1;
    else
        v_numpage := v_resultdivide + 2;
    end if;


      insert into ttemprpt
          (codempid,codapp   ,numseq  ,
           item1   ,item2    ,item3   ,item4  ,
           item5   ,item6    ,item7   ,item8  ,
           item9   ,item10   ,item11  ,item12 ,
           item13  ,item14   ,item15  ,item16 ,
           item17  ,item18   ,item19  ,item20 ,
           item21  ,
           item22  ,item23   ,item24  ,item25 ,
           item26  ,item27   ,
           item28  ,item29   ,
           item30  ,item31   ,
           item32 ,
           item33,
           item34)
       values
          (global_v_codempid,p_codapp1,(v_count+1),
           -- company address --
           p_dteyrepay  ,p_codcomp     ,p_typincom    ,p_typrep    ,
           v_numcotax ,v_namcom      ,v_building    ,v_roomno    ,
           v_floor      ,v_village     ,v_addrno      ,v_moo       ,
           v_soi        ,v_road        ,v_codsubdist  ,v_coddist   ,
           v_codprovr   ,v_zipcode     ,v_numtele     ,v_yeartax   ,
           v_submission ,
           -- signature --
           v_name       ,v_desc_codpos ,v_folder      ,v_namsign   ,
           -- tinctxpnd count --
           hcm_util.get_split_decimal(v_amtinc_all,'I'),hcm_util.get_split_decimal(v_amtinc_all,'D'), --to_char(r1.amtinc),to_char(trunc((r1.amtinc - floor(r1.amtinc))*100))
           hcm_util.get_split_decimal(v_amttax_all,'I'),hcm_util.get_split_decimal(v_amttax_all,'D'), --to_char(r1.amttax),to_char(trunc((r1.amttax - floor(r1.amttax))*100))
           -- page count --
           to_char(1 + floor(((v_count + 1)/20))) ,sum_page      ,
--           to_char(mod(v_count,20)+1),
           to_char(v_numpage),
           v_has_image,
           v_count);


    obj_data := json_object_t();
    obj_rows.put(to_char(v_count),obj_data);

    obj_json.put('table',obj_rows);
    obj_json.put('process',to_char(v_count));
    obj_json.put('coderror','200');

/* 4913
    if v_flg_exist then
      if v_count > 0 then
        json_str_output := obj_json.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tinctxpnd');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
4913*/
--4913
    if v_rec > 0  then
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      else
        json_str_output := obj_json.to_clob;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tinctxpnd');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
--4913
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail_sum;

  procedure gen_detail_det(json_str_output out clob) as
    v_count       number := 0;
--4913
    v_rec         number := 0;
--4913
    obj_data      json_object_t;
    obj_rows      json_object_t := json_object_t();
    obj_detail    json_object_t := json_object_t();
    obj_json      json_object_t := json_object_t();
    v_codpay4     tcontrpy.codpaypy4%type;
    v_codincom1   tcontpms.codincom1%type;
    v_flg_exist		boolean := false;
    v_secur 			boolean := false;
    v_flgsecu			boolean := false;
    v_numseq 			number	:= 0;
    --
    v_codempid    varchar2(4000 char);
    v_numoffid    varchar2(4000 char);
    v_numtaxid    varchar2(4000 char);
    v_flgtax      varchar2(4000 char);
    v_temp01      varchar2(4000 char);
    v_temp02      varchar2(4000 char);
    v_temp03      varchar2(4000 char);
    v_temp04      varchar2(4000 char);
    v_item01      varchar2(4000 char);
    v_item02      varchar2(4000 char);
    v_item03      varchar2(4000 char);
    v_item04      varchar2(4000 char);
    v_item05      varchar2(4000 char);
    --
    v_amttax      number := 0;
    v_numrec      number := 0;
    sum_page      number := 0;
    --
    v_namfirstt   varchar2(4000 char);
    v_namlastt    varchar2(4000 char);
    v_adrregt     varchar2(4000 char);
    v_address     varchar2(4000 char);
    --
    v_typsign           tsetsign.typsign%type;
    v_codcomp           tsetsign.codcomp%type;
    v_codpos            tsetsign.codpos%type;
    v_signname          tsetsign.signname%type;
    v_posname           tsetsign.posname%type;
    v_namsign           tsetsign.namsign%type;
    v_name              varchar2(4000 char);
    v_desc_codpos       varchar2(4000 char);
    v_folder            varchar2(4000 char);
    --
    cursor c_tinctxpnd is
      select t1.codempid,decode(t1.codpay,v_codpay4,t1.codpay ,v_codincom1) codpay  ,t2.typincom,
             nvl(sum(to_number(stddec(t1.amtinc,t1.codempid,global_v_chken))),0) amtinc,
             nvl(sum(to_number(stddec(t1.amttax,t1.codempid,global_v_chken))),0) amttax
        from tinctxpnd t1,ttaxcur t2
       where t1.codempid   = t2.codempid
         and t1.dteyrepay  = t2.dteyrepay
         and t1.dtemthpay  = t2.dtemthpay
         and t1.numperiod  = t2.numperiod
         and t1.codcomp    like p_codcomp||'%'
         and t1.dteyrepay  = (p_dteyrepay - global_v_zyear)
         and t2.typincom   = decode(p_typincom,'A',t2.typincom,p_typincom)
         and t2.typincom   in ('3','4','5')
--         and t1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
--         and exists(select codcomp
--                      from tusrcom
--                     where coduser = global_v_coduser
--                       and t1.codcomp like codcomp||'%')
      group by t1.codempid,decode(t1.codpay,v_codpay4,t1.codpay ,v_codincom1) ,t2.typincom
      order by t1.codempid,decode(t1.codpay,v_codpay4,t1.codpay ,v_codincom1) ;

    v_amtinc_all number := 0;
    v_amttax_all number := 0;
    v_numcotax varchar2(50 char);
    v_has_image   varchar2(1) := 'N';
  begin
    begin
      delete ttemprpt where codempid = global_v_codempid
                        and codapp   = p_codapp2;
    end;
    --
    begin
      select codincom1
        into v_codincom1
        from tcontpms
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                         from tcontpms
                         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                         and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      v_codincom1 := null;
    end;
    --
    begin
      select codpaypy4
        into v_codpay4
        from tcontrpy
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                         from tcontrpy where codcompy = hcm_util.get_codcomp_level(p_codcomp,1));
    exception when no_data_found then
      v_codpay4 := null;
    end;
    -- get page number --
    get_page_number (20,sum_page);
    --

    for r_tinctxpnd in c_tinctxpnd loop
      v_flg_exist := true;
--4913
      v_rec := v_rec + 1;
--4913
      v_codempid	:= r_tinctxpnd.codempid;
      --v_flgsecu   := true;
      v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgsecu  then
        v_numseq    := v_numseq + 1;
        begin
      /*
          select decode(t2.codprovr,'1000',  get_label_name('HRPY98R',global_v_lang,140)||' '||t2.adrregt ||' '||
                                             get_label_name('HRPMC2E1T2',global_v_lang,170)||get_tsubdist_name(t2.codsubdistr,global_v_lang)||' '||
                                             get_label_name('HRPMC2E1T2',global_v_lang,180)||get_tcoddist_name(t2.coddistr,global_v_lang)||' '||
                                             get_tcodec_name('TCODPROV',t2.codprovr,global_v_lang)||' '||
                                             get_tcodec_name('TCODCNTY',t2.codcntyr,global_v_lang)||' '||t2.codpostr
                                          ,  get_label_name('HRPY98R',global_v_lang,140)||' '||t2.adrregt ||' '||
                                             get_label_name('HRPMC2E1T2',global_v_lang,60)||get_tsubdist_name(t2.codsubdistr,global_v_lang)||' '||
                                             get_label_name('HRPMC2E1T2',global_v_lang,50)||get_tcoddist_name(t2.coddistr,global_v_lang)||' '||
                                             get_label_name('HRPMC2E1T2',global_v_lang,40)||get_tcodec_name('TCODPROV',t2.codprovr,global_v_lang)||' '||
                                             get_tcodec_name('TCODCNTY',t2.codcntyr,global_v_lang)||' '||t2.codpostr
                        )address,
        */
        select   decode(global_v_lang,'101',t2.adrrege,
                                      '102',t2.adrregt,
                                      '103',t2.adrreg3,
                                      '104',t2.adrreg4,
                                      '105',t2.adrreg5,
                                      t2.adrrege) ||' '||
                 get_label_name('HRPMC2E1T2',global_v_lang,decode(t2.codprovr,'1000',170,60))||get_tsubdist_name(t2.codsubdistr,global_v_lang)||' '||
                 get_label_name('HRPMC2E1T2',global_v_lang,decode(t2.codprovr,'1000',180,50))||get_tcoddist_name(t2.coddistr,global_v_lang)||' '||
                 decode(t2.codprovr,'1000',null,get_label_name('HRPMC2E1T2',global_v_lang,40))||
                 get_tcodec_name('TCODPROV',t2.codprovr,global_v_lang)||' '||
                 get_tcodec_name('TCODCNTY',t2.codcntyr,global_v_lang)||' '||t2.codpostr  address ,
                 get_tlistval_name('CODTITLE',t1.codtitle,global_v_lang)||t1.namfirstt,
                 t1.namlastt,
                 t2.numoffid,
                 t3.numtaxid,
                 t3.flgtax
            into v_address,
                 v_namfirstt,
                 v_namlastt,
                 v_numoffid,
                 v_numtaxid,
                 v_flgtax
            from temploy1 t1,temploy2 t2,temploy3 t3
           where t1.codempid = t2.codempid
             and t1.codempid = t3.codempid
             and t1.codempid = v_codempid;
        exception when no_data_found then
          v_address     := null;
          v_namfirstt   := null;
          v_namlastt    := null;
          v_numoffid    := null;
          v_numtaxid    := null;
          v_flgtax      := null;
        end;
        --
        v_temp01 	 := v_numseq;
        v_item01   := r_tinctxpnd.codempid;
        v_item02   := get_temploy_name(r_tinctxpnd.codempid,global_v_lang);
        --
        v_item03   := v_numoffid;
        v_item04   := v_numtaxid;
        v_item05   := get_tinexinf_name(r_tinctxpnd.codpay,global_v_lang);
        v_temp02 	 := r_tinctxpnd.amtinc;
        v_temp04   := r_tinctxpnd.amttax;
           --
        if r_tinctxpnd.typincom = '3' then
          v_temp03 	 := 3;
        elsif r_tinctxpnd.typincom = '4' then
          v_temp03 	 := 5;
        elsif r_tinctxpnd.typincom = '5' then
          v_temp03 	 := 15;
        end if;
        --
        obj_data := json_object_t();
        obj_data.put('numseq',to_char(v_temp01));
        obj_data.put('image',get_emp_img(v_item01));
        obj_data.put('codempid',v_item01);
        obj_data.put('desc_codempid',v_item02);
        obj_data.put('numoffid',v_item03);
        obj_data.put('numtaxid',v_item04);
        obj_data.put('desc_codpay',v_item05);
        obj_data.put('typincom',v_temp03);
        obj_data.put('amtinc',to_char(v_temp02,'fm999999999990.00'));
        obj_data.put('amttax',to_char(v_temp04,'fm999999999990.00'));
        obj_rows.put(to_char(v_count),obj_data);

        v_amtinc_all := v_amtinc_all + v_temp02;
        v_amttax_all := v_amttax_all + v_temp04;
        --
        begin
          select typsign,codempid,codcomp,
                 codpos ,signname,posname,
                 namsign
            into v_typsign,v_codempid,v_codcomp,
                 v_codpos ,v_signname,v_posname,
                 v_namsign
            from tsetsign
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
             and coddoc = 'HRPY98R';
          --
          if v_typsign in ('1','2') then
              if v_typsign = '2' then
                begin
                  select codempid
                    into v_codempid
                    from temploy1
                   where codpos  = v_codpos
                     and codcomp like nvl(v_codcomp,'')||'%'
                     and staemp in ('1','3')
                     and rownum  = 1
                  order by codempid;
                exception when no_data_found then
                  v_codempid := null;
                end;
              end if;
            begin
              select get_tlistval_name('CODTITLE',codtitle,global_v_lang)||namfirstt|| ' ' ||namlastt,
                     get_tpostn_name(codpos,global_v_lang)
                into v_name,v_desc_codpos
                from temploy1
               where codempid = v_codempid;
            exception when no_data_found then
              v_name        := null;
              v_desc_codpos := null;
            end;
            --
            begin
              select namsign
                into v_namsign
                from tempimge
               where codempid = v_codempid;
            exception when no_data_found then
              v_namsign := null;
            end;
            --
            begin
              select folder
                into v_folder
                from tfolderd
               where codapp = 'HRPMC2E2';
            exception when no_data_found then
              v_namsign := null;
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
          else
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
          end if;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSETSIGN');
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          return;
        end;

        --<<check existing image
        if v_namsign is not null then
          v_namsign     := get_tsetup_value('PATHWORKPHP')||v_folder||'/'||v_namsign;
          v_has_image   := 'Y';
        end if;
        -->>

        --

--      v_numoffid := split_number_id(v_numoffid);
--      v_numtaxid := split_number_id(v_numtaxid);
      v_numoffid := rpad(v_numoffid,13,'-');
      v_numtaxid := rpad(v_numtaxid,13,'-');
        -- Get Company Tax Number --
        begin
          select numcotax into v_numcotax
            from tcompny
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
        end;
        v_numcotax := rpad(v_numcotax,13,'-');
--        v_numcotax := split_number_id(v_numcotax);
        --
        begin
          insert into ttemprpt
              (codempid,codapp ,numseq,
               item1,item2,item3,item4,
               item5,item6,item7,item8,item9,
               item10,item11,
               item12,
               item13,item14,item15,item16,item17,
               item18,item19,
               item20,item21,item22,item23,item24,item25,item26)
           values
              (global_v_codempid,p_codapp2,v_numseq,
               p_dteyrepay,p_codcomp,p_typincom,p_typrep ,
               v_numoffid,v_numtaxid,v_flgtax,v_namfirstt,v_namlastt ,
               to_char(1 + floor(((v_count + 1)/20))) ,v_numrec  ,
               to_char(mod(v_count,20)+1),
               v_item05,v_temp02,v_temp03,v_temp04,v_address,
               v_amtinc_all,v_amttax_all,
               -- signature --
               v_name,v_desc_codpos,v_folder,v_namsign,sum_page,v_numcotax,v_has_image);
        end;
        v_count := v_count + 1;
      end if;
    end loop;
    -- comment by user#18 pongsak 18/12/2019
--    obj_data := json();
--    obj_data.put('numtaxid',get_label_name('HRPY93R2',global_v_lang,130)); -- tapplscr
--    obj_data.put('amtinc',v_amtinc_all);
--    obj_data.put('amttax',v_amttax_all);
--    obj_rows.put(to_char(v_count),obj_data);

    obj_json.put('table',obj_rows);
    obj_json.put('process',to_char(v_count));
    obj_json.put('coderror','200');

/* 4913
    if v_flg_exist then
      if v_count > 0 then
        json_str_output :=  obj_json.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tinctxpnd');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
4913 */
--4913
    if v_rec > 0  then
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      else
        json_str_output := obj_json.to_clob;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tinctxpnd');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
--4913
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail_det;
end HRPY98R;

/

--------------------------------------------------------
--  DDL for Package Body HRPYS1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYS1E" as
  function select_amtpay_tsincexp(v_month number,v_year number,v_syncond varchar2,v_codpay varchar2) return varchar2 as
    v_statement  varchar2(4000 char) := '';
    v_amtpay     number := 0;
  begin
    v_statement := 'select nvl(sum(nvl(stddec(amtpay,a.codempid,'''||global_v_chken||'''),0)),0)'||
                   '  from tsincexp  a,temploy1 b, tusrcom c '||
                   ' where codpay    = '''||v_codpay||''' '||
                   '   and dteyrepay = '||v_year||' '||
                   '   and dtemthpay = '||v_month||' '||
                   '   and a.codempid in (select codempid from temploy1 where '||v_syncond||') '||
                   '   and a.codempid = b.codempid '||
                   '   and b.numlvl between '||global_v_numlvlsalst||' and '||global_v_numlvlsalen||' '||
                   '   and b.codcomp  like c.codcomp||''%'' '||
                   '   and c.coduser  = '''||global_v_coduser||'''  ';
    v_amtpay := execute_qty(v_statement);
    return to_char(v_amtpay,'fm999999999990.00');
  exception when others then
    return null;
  end;

  procedure insert_update_tcodgrbug(v_codgrbug in varchar2,v_syncond in varchar2) as
  begin
    insert into tcodgrbug (codcodec,syscond,statement,codcreate,dtecreate,coduser,dteupd)
         values (v_codgrbug,v_syncond,p_statement,global_v_coduser,sysdate,global_v_coduser,sysdate);
  exception when dup_val_on_index then
    update tcodgrbug
       set syscond   = v_syncond,
           statement = p_statement,
           coduser   = global_v_coduser,
           dteupd    = sysdate
     where codcodec  = p_codgrbug;
  end;

  procedure insert_update_ttbudsal_pay(v_dteyear  in varchar2 ,v_codgrbug in varchar2 ,v_codpay   in varchar2,
                                      v_amtpay1   in number   ,v_amtpay2  in number   ,v_amtpay3  in number  ,
                                      v_amtpay4   in number   ,v_amtpay5  in number   ,v_amtpay6  in number  ,
                                      v_amtpay7   in number   ,v_amtpay8  in number   ,v_amtpay9  in number  ,
                                      v_amtpay10  in number   ,v_amtpay11 in number   ,v_amtpay12 in number  ) as
  begin
    insert into ttbudsal (dteyear ,codgrbug,codpay  ,
                          amtpay1 ,amtpay2 ,amtpay3 ,
                          amtpay4 ,amtpay5 ,amtpay6 ,
                          amtpay7 ,amtpay8 ,amtpay9 ,
                          amtpay10,amtpay11,amtpay12,
                          dtecreate, codcreate, coduser, dteupd
                          )
         values (v_dteyear ,v_codgrbug,v_codpay  ,
                 stdenc(v_amtpay1 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay2 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay3 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay4 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay5 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay6 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay7 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay8 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay9 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay10,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay11,v_codgrbug,global_v_chken),
                 stdenc(v_amtpay12,v_codgrbug,global_v_chken),
                 sysdate, global_v_coduser, global_v_coduser, sysdate
                 );
  exception when dup_val_on_index then
    update ttbudsal
       set amtpay1  = stdenc(v_amtpay1 ,v_codgrbug,global_v_chken),
           amtpay2  = stdenc(v_amtpay2 ,v_codgrbug,global_v_chken),
           amtpay3  = stdenc(v_amtpay3 ,v_codgrbug,global_v_chken),
           amtpay4  = stdenc(v_amtpay4 ,v_codgrbug,global_v_chken),
           amtpay5  = stdenc(v_amtpay5 ,v_codgrbug,global_v_chken),
           amtpay6  = stdenc(v_amtpay6 ,v_codgrbug,global_v_chken),
           amtpay7  = stdenc(v_amtpay7 ,v_codgrbug,global_v_chken),
           amtpay8  = stdenc(v_amtpay8 ,v_codgrbug,global_v_chken),
           amtpay9  = stdenc(v_amtpay9 ,v_codgrbug,global_v_chken),
           amtpay10 = stdenc(v_amtpay10,v_codgrbug,global_v_chken),
           amtpay11 = stdenc(v_amtpay11,v_codgrbug,global_v_chken),
           amtpay12 = stdenc(v_amtpay12,v_codgrbug,global_v_chken),
           coduser  = global_v_coduser,
           dteupd   = sysdate
     where dteyear  = v_dteyear
       and codgrbug = v_codgrbug
       and codpay   = v_codpay;
  end;

  procedure insert_update_ttbudsal_budgt(v_dteyear    in varchar2 ,v_codgrbug   in varchar2 ,v_codpay     in varchar2 ,
                                         v_amtbudgt1  in varchar2 ,v_amtbudgt2  in varchar2 ,v_amtbudgt3  in varchar2 ,
                                         v_amtbudgt4  in varchar2 ,v_amtbudgt5  in varchar2 ,v_amtbudgt6  in varchar2 ,
                                         v_amtbudgt7  in varchar2 ,v_amtbudgt8  in varchar2 ,v_amtbudgt9  in varchar2 ,
                                         v_amtbudgt10 in varchar2 ,v_amtbudgt11 in varchar2 ,v_amtbudgt12 in varchar2,
                                         v_percent1  in varchar2 ,v_percent2  in varchar2 ,v_percent3  in varchar2 ,
                                         v_percent4  in varchar2 ,v_percent5  in varchar2 ,v_percent6  in varchar2 ,
                                         v_percent7  in varchar2 ,v_percent8  in varchar2 ,v_percent9  in varchar2 ,
                                         v_percent10 in varchar2 ,v_percent11 in varchar2 ,v_percent12 in varchar2) as
  begin
    insert into ttbudsal (dteyear   ,codgrbug  ,codpay    ,
                          amtbudgt1 ,amtbudgt2 ,amtbudgt3 ,
                          amtbudgt4 ,amtbudgt5 ,amtbudgt6 ,
                          amtbudgt7 ,amtbudgt8 ,amtbudgt9 ,
                          amtbudgt10,amtbudgt11,amtbudgt12,
                          pctbudgt1,pctbudgt2,pctbudgt3,
                          pctbudgt4,pctbudgt5,pctbudgt6,
                          pctbudgt7,pctbudgt8,pctbudgt9,
                          pctbudgt10,pctbudgt11,pctbudgt12,
                          dtecreate, codcreate, coduser, dteupd
                          )
         values (v_dteyear   ,v_codgrbug  ,v_codpay    ,
                 stdenc(v_amtbudgt1 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt2 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt3 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt4 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt5 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt6 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt7 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt8 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt9 ,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt10,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt11,v_codgrbug,global_v_chken),
                 stdenc(v_amtbudgt12,v_codgrbug,global_v_chken),
                 v_percent1,v_percent2,v_percent3,
                 v_percent4,v_percent5,v_percent6,
                 v_percent7,v_percent8,v_percent9,
                 v_percent10,v_percent11,v_percent12,
                 sysdate, global_v_coduser, global_v_coduser, sysdate
                 );
  exception when dup_val_on_index then
    update ttbudsal
       set amtbudgt1  = stdenc(v_amtbudgt1 ,v_codgrbug,global_v_chken),
           amtbudgt2  = stdenc(v_amtbudgt2 ,v_codgrbug,global_v_chken),
           amtbudgt3  = stdenc(v_amtbudgt3 ,v_codgrbug,global_v_chken),
           amtbudgt4  = stdenc(v_amtbudgt4 ,v_codgrbug,global_v_chken),
           amtbudgt5  = stdenc(v_amtbudgt5 ,v_codgrbug,global_v_chken),
           amtbudgt6  = stdenc(v_amtbudgt6 ,v_codgrbug,global_v_chken),
           amtbudgt7  = stdenc(v_amtbudgt7 ,v_codgrbug,global_v_chken),
           amtbudgt8  = stdenc(v_amtbudgt8 ,v_codgrbug,global_v_chken),
           amtbudgt9  = stdenc(v_amtbudgt9 ,v_codgrbug,global_v_chken),
           amtbudgt10 = stdenc(v_amtbudgt10,v_codgrbug,global_v_chken),
           amtbudgt11 = stdenc(v_amtbudgt11,v_codgrbug,global_v_chken),
           amtbudgt12 = stdenc(v_amtbudgt12,v_codgrbug,global_v_chken),
           pctbudgt1  = v_percent1,
           pctbudgt2  = v_percent2,
           pctbudgt3  = v_percent3,
           pctbudgt4  = v_percent4,
           pctbudgt5  = v_percent5,
           pctbudgt6  = v_percent6,
           pctbudgt7  = v_percent7,
           pctbudgt8  = v_percent8,
           pctbudgt9  = v_percent9,
           pctbudgt10 = v_percent10,
           pctbudgt11 = v_percent11,
           pctbudgt12 = v_percent12,
           coduser  = global_v_coduser,
           dteupd   = sysdate
     where dteyear  = v_dteyear
       and codgrbug = v_codgrbug
       and codpay   = v_codpay;
  end;

  function find_budget(v_json json_object_t,v_number number) return number as -- ????????? sort ??????????????
    v_json_child  json_object_t;
    v_index       number;
    v_data        number;
    v_increasing  number;
  begin
    for i in 0..11 loop
      v_json_child := hcm_util.get_json_t(v_json,to_char(i));
      v_index      := to_number(hcm_util.get_string_t(v_json_child,'index'));
      if v_index = v_number then
        v_data := to_number(hcm_util.get_string_t(v_json_child,'budget'));
        v_increasing := to_number(hcm_util.get_string_t(v_json_child,'increasing'));
        if v_data < 0 then
          param_msg_error := get_error_msg_php('HR2023',global_v_lang);
          return null;
        elsif v_data > 999999999.99 then
          param_msg_error := get_error_msg_php('HR2020',global_v_lang);
          return null;
        else
          return v_data;
        end if;
      end if;
    end loop;
    return null;
  end;

  function find_percent(v_json json_object_t,v_number number) return number as -- ????????? sort ??????????????
    v_json_child  json_object_t;
    v_index       number;
    v_data        number;
    v_increasing  number;
  begin
    for i in 0..11 loop
      v_json_child := hcm_util.get_json_t(v_json,to_char(i));
      v_index      := to_number(hcm_util.get_string_t(v_json_child,'index'));
      if v_index = v_number then
        v_data := to_number(hcm_util.get_string_t(v_json_child,'budget'));
        v_increasing := to_number(hcm_util.get_string_t(v_json_child,'increasing'));
        if v_data < 0 then
          param_msg_error := get_error_msg_php('HR2023',global_v_lang);
          return null;
        elsif v_data > 999999999.99 then
          param_msg_error := get_error_msg_php('HR2020',global_v_lang);
          return null;
        else
          return v_increasing;
        end if;
      end if;
    end loop;
    return null;
  end;

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);

    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codgrbug   := hcm_util.get_string_t(obj_detail,'codgrbug');
    p_codpay     := hcm_util.get_string_t(obj_detail,'codpay');

    p_syncond    := hcm_util.get_string_t(obj_detail,'syncond');
    p_statement  := hcm_util.get_string_t(obj_detail,'statement');
    p_month1     := to_number(hcm_util.get_string_t(obj_detail,'month1'));
    p_month2     := to_number(hcm_util.get_string_t(obj_detail,'month2'));
    p_month3     := to_number(hcm_util.get_string_t(obj_detail,'month3'));
    p_month4     := to_number(hcm_util.get_string_t(obj_detail,'month4'));
    p_month5     := to_number(hcm_util.get_string_t(obj_detail,'month5'));
    p_month6     := to_number(hcm_util.get_string_t(obj_detail,'month6'));
    p_month7     := to_number(hcm_util.get_string_t(obj_detail,'month7'));
    p_month8     := to_number(hcm_util.get_string_t(obj_detail,'month8'));
    p_month9     := to_number(hcm_util.get_string_t(obj_detail,'month9'));
    p_month10    := to_number(hcm_util.get_string_t(obj_detail,'month10'));
    p_month11    := to_number(hcm_util.get_string_t(obj_detail,'month11'));
    p_month12    := to_number(hcm_util.get_string_t(obj_detail,'month12'));
    if hcm_util.get_json_t(obj_detail,'param_json') is not null then
        param_json      := hcm_util.get_json_t(obj_detail,'param_json');
    end if;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_codgrbug is not null then
      begin
        select codcodec
          into p_codgrbug
          from tcodgrbug
         where codcodec = p_codgrbug;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrbug');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
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
    v_syncond    varchar2(4000 char);
    v_statement  clob;
    v_amtbudgt1    number;
    v_amtbudgt2    number;
    v_amtbudgt3    number;
    v_amtbudgt4    number;
    v_amtbudgt5    number;
    v_amtbudgt6    number;
    v_amtbudgt7    number;
    v_amtbudgt8    number;
    v_amtbudgt9    number;
    v_amtbudgt10   number;
    v_amtbudgt11   number;
    v_amtbudgt12   number;
    v_amtbudgt_lastyear1    number;
    v_amtbudgt_lastyear2    number;
    v_amtbudgt_lastyear3    number;
    v_amtbudgt_lastyear4    number;
    v_amtbudgt_lastyear5    number;
    v_amtbudgt_lastyear6    number;
    v_amtbudgt_lastyear7    number;
    v_amtbudgt_lastyear8    number;
    v_amtbudgt_lastyear9    number;
    v_amtbudgt_lastyear10   number;
    v_amtbudgt_lastyear11   number;
    v_amtbudgt_lastyear12   number;
    v_percent1              number;
    v_percent2              number;
    v_percent3              number;
    v_percent4              number;
    v_percent5              number;
    v_percent6              number;
    v_percent7              number;
    v_percent8              number;
    v_percent9              number;
    v_percent10             number;
    v_percent11             number;
    v_percent12             number;
    v_amtpay_lastyear1     number;
    v_amtpay_lastyear2     number;
    v_amtpay_lastyear3     number;
    v_amtpay_lastyear4     number;
    v_amtpay_lastyear5     number;
    v_amtpay_lastyear6     number;
    v_amtpay_lastyear7     number;
    v_amtpay_lastyear8     number;
    v_amtpay_lastyear9     number;
    v_amtpay_lastyear10    number;
    v_amtpay_lastyear11    number;
    v_amtpay_lastyear12    number;

    obj_json     json_object_t := json_object_t();
    obj_rows     json_object_t := json_object_t();
    obj_data     json_object_t;
    v_count      number := 0;
    v_token      varchar2(4000 char);
    v_amtpaylastyear number;
    v_percent number;
  begin
    begin
      select syscond,statement
        into v_syncond,v_statement
        from tcodgrbug
       where codcodec = p_codgrbug;
    exception when no_data_found then
      v_syncond := null;
      v_statement := null;
    end;
    begin
      select stddec(amtbudgt1 ,codgrbug,global_v_chken),
             stddec(amtbudgt2 ,codgrbug,global_v_chken),
             stddec(amtbudgt3 ,codgrbug,global_v_chken),
             stddec(amtbudgt4 ,codgrbug,global_v_chken),
             stddec(amtbudgt5 ,codgrbug,global_v_chken),
             stddec(amtbudgt6 ,codgrbug,global_v_chken),
             stddec(amtbudgt7 ,codgrbug,global_v_chken),
             stddec(amtbudgt8 ,codgrbug,global_v_chken),
             stddec(amtbudgt9 ,codgrbug,global_v_chken),
             stddec(amtbudgt10,codgrbug,global_v_chken),
             stddec(amtbudgt11,codgrbug,global_v_chken),
             stddec(amtbudgt12,codgrbug,global_v_chken),
             pctbudgt1, pctbudgt2, pctbudgt3, pctbudgt4,
             pctbudgt5, pctbudgt6, pctbudgt7, pctbudgt8,
             pctbudgt9, pctbudgt10, pctbudgt11, pctbudgt12
        into v_amtbudgt1  ,v_amtbudgt2  ,v_amtbudgt3  ,v_amtbudgt4  ,
             v_amtbudgt5  ,v_amtbudgt6  ,v_amtbudgt7  ,v_amtbudgt8  ,
             v_amtbudgt9  ,v_amtbudgt10 ,v_amtbudgt11 ,v_amtbudgt12,
             v_percent1, v_percent2, v_percent3, v_percent4,
             v_percent5, v_percent6, v_percent7, v_percent8,
             v_percent9, v_percent10, v_percent11, v_percent12
        from ttbudsal
       where dteyear   = p_year
         and codgrbug  = p_codgrbug
         and codpay    = p_codpay;
    exception when no_data_found then
      v_amtbudgt1 := 0; v_amtbudgt2 := 0; v_amtbudgt3 := 0; v_amtbudgt4 := 0;
      v_amtbudgt5 := 0; v_amtbudgt6 := 0; v_amtbudgt7 := 0; v_amtbudgt8 := 0;
      v_amtbudgt9 := 0; v_amtbudgt10 := 0; v_amtbudgt11 := 0; v_amtbudgt12 := 0;
      v_percent1  := 0; v_percent2  := 0; v_percent3  := 0; v_percent4  := 0;
      v_percent5  := 0; v_percent6  := 0; v_percent7  := 0; v_percent8  := 0;
      v_percent9  := 0; v_percent10 := 0; v_percent11 := 0; v_percent12 := 0;
    end;
    begin
      select stddec(amtbudgt1 ,codgrbug,global_v_chken),
             stddec(amtbudgt2 ,codgrbug,global_v_chken),
             stddec(amtbudgt3 ,codgrbug,global_v_chken),
             stddec(amtbudgt4 ,codgrbug,global_v_chken),
             stddec(amtbudgt5 ,codgrbug,global_v_chken),
             stddec(amtbudgt6 ,codgrbug,global_v_chken),
             stddec(amtbudgt7 ,codgrbug,global_v_chken),
             stddec(amtbudgt8 ,codgrbug,global_v_chken),
             stddec(amtbudgt9 ,codgrbug,global_v_chken),
             stddec(amtbudgt10,codgrbug,global_v_chken),
             stddec(amtbudgt11,codgrbug,global_v_chken),
             stddec(amtbudgt12,codgrbug,global_v_chken),
             nvl(stddec(amtpay1,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay2,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay3,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay4,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay5,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay6,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay7,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay8,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay9,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay10,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay11,codgrbug,global_v_chken),0),
             nvl(stddec(amtpay12,codgrbug,global_v_chken),0)
        into v_amtbudgt_lastyear1  ,v_amtbudgt_lastyear2  ,
             v_amtbudgt_lastyear3  ,v_amtbudgt_lastyear4  ,
             v_amtbudgt_lastyear5  ,v_amtbudgt_lastyear6  ,
             v_amtbudgt_lastyear7  ,v_amtbudgt_lastyear8  ,
             v_amtbudgt_lastyear9  ,v_amtbudgt_lastyear10 ,
             v_amtbudgt_lastyear11 ,v_amtbudgt_lastyear12, 
             v_amtpay_lastyear1, v_amtpay_lastyear2, v_amtpay_lastyear3, 
             v_amtpay_lastyear4, v_amtpay_lastyear5, v_amtpay_lastyear6, 
             v_amtpay_lastyear7, v_amtpay_lastyear8, v_amtpay_lastyear9, 
             v_amtpay_lastyear10, v_amtpay_lastyear11, v_amtpay_lastyear12
        from ttbudsal
       where dteyear   = p_year - 1
         and codgrbug  = p_codgrbug
         and codpay    = p_codpay;
    exception when no_data_found then
      v_amtbudgt_lastyear1 := 0; v_amtbudgt_lastyear2 := 0; v_amtbudgt_lastyear3 := 0; v_amtbudgt_lastyear4 := 0;
      v_amtbudgt_lastyear5 := 0; v_amtbudgt_lastyear6 := 0; v_amtbudgt_lastyear7 := 0; v_amtbudgt_lastyear8 := 0;
      v_amtbudgt_lastyear9 := 0; v_amtbudgt_lastyear10 := 0; v_amtbudgt_lastyear11 := 0; v_amtbudgt_lastyear12 := 0;
      v_amtpay_lastyear1  := 0; v_amtpay_lastyear2  := 0; v_amtpay_lastyear3  := 0; v_amtpay_lastyear4  := 0;
      v_amtpay_lastyear5  := 0; v_amtpay_lastyear6  := 0; v_amtpay_lastyear7  := 0; v_amtpay_lastyear8  := 0;
      v_amtpay_lastyear9  := 0; v_amtpay_lastyear10 := 0; v_amtpay_lastyear11 := 0; v_amtpay_lastyear12 := 0;
    end;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear1);
    obj_data.put('lastyear',v_amtpay_lastyear1);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear1,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt1 is not null then
      v_percent := ( ( v_amtbudgt1 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent1,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt1,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
--    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear2);
    obj_data.put('lastyear',v_amtpay_lastyear2);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear2,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt2 is not null then
      v_percent := ( ( v_amtbudgt2 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent2,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt2,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
   --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear3);
    obj_data.put('lastyear',v_amtpay_lastyear3);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear3,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt3 is not null then
      v_percent := ( ( v_amtbudgt3 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent3,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt3,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear4);
    obj_data.put('lastyear',v_amtpay_lastyear4);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear4,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt4 is not null then
      v_percent := ( ( v_amtbudgt4 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent4,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt4,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear5);
    obj_data.put('lastyear',v_amtpay_lastyear5);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear5,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt5 is not null then
      v_percent := ( ( v_amtbudgt5 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent5,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt5,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear6);
    obj_data.put('lastyear',v_amtpay_lastyear6);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear6,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt6 is not null then
      v_percent := ( ( v_amtbudgt6 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent6,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt6,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear7);
    obj_data.put('lastyear',v_amtpay_lastyear7);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear7,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt7 is not null then
      v_percent := ( ( v_amtbudgt7 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent7,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt7,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear8);
    obj_data.put('lastyear',v_amtpay_lastyear8);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear8,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt8 is not null then
      v_percent := ( ( v_amtbudgt8 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent8,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt8,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear9);
    obj_data.put('lastyear',v_amtpay_lastyear9);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear9,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt9 is not null then
      v_percent := ( ( v_amtbudgt9 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent9,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt9,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear10);
    obj_data.put('lastyear',v_amtpay_lastyear10);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear10,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt10 is not null then
      v_percent := ( ( v_amtbudgt10 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent10,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt10,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear11);
    obj_data.put('lastyear',v_amtpay_lastyear11);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear11,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt11 is not null then
      v_percent := ( ( v_amtbudgt11 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent11,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt11,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    --    v_amtpaylastyear := to_number(v_token);
    v_amtpaylastyear := to_number(v_amtpay_lastyear12);
    obj_data.put('lastyear',v_amtpay_lastyear12);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear12,'fm999999999990.00'));
    if v_amtpaylastyear <> 0 and v_amtpaylastyear is not null and v_amtbudgt12 is not null then
      v_percent := ( ( v_amtbudgt12 / v_amtpaylastyear ) * 100  ) - 100;
      if v_percent = -100 then
        v_percent := null;
      end if;
    else
      v_percent := 0;
    end if;
    obj_data.put('increasing',to_char(v_percent12,'fm999999999990.00'));
    obj_data.put('budget'    ,to_char(v_amtbudgt12,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('syncond'  ,v_syncond);
    obj_data.put('desc_statement',get_logical_desc(v_statement));
    obj_data.put('statement',v_statement);
    obj_json.put('detail'   ,obj_data);
    obj_json.put('rows'     ,obj_rows);
    obj_json.put('coderror' ,'200');
--    dbms_lob.createtemporary(json_str_output, true);
--    obj_json.to_clob(json_str_output);
    json_str_output := obj_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure check_process as
  begin
    if p_codgrbug is not null then
      begin
        select codcodec
          into p_codgrbug
          from tcodgrbug
         where codcodec = p_codgrbug;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrbug');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  end check_process;

  procedure get_process(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_process;
    if param_msg_error is null then
        gen_process(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure gen_process(json_str_output out clob) as
    v_syncond    varchar2(4000 char);
    v_amtbudgt   number;
    obj_json     json_object_t := json_object_t();
    obj_rows     json_object_t := json_object_t();
    obj_data     json_object_t;
    v_count      number := 0;
    v_token      varchar2(4000 char);
    v_amtpay1    number;
    v_amtpay2    number;
    v_amtpay3    number;
    v_amtpay4    number;
    v_amtpay5    number;
    v_amtpay6    number;
    v_amtpay7    number;
    v_amtpay8    number;
    v_amtpay9    number;
    v_amtpay10   number;
    v_amtpay11   number;
    v_amtpay12   number;
    v_amtbudgt_lastyear1    number;
    v_amtbudgt_lastyear2    number;
    v_amtbudgt_lastyear3    number;
    v_amtbudgt_lastyear4    number;
    v_amtbudgt_lastyear5    number;
    v_amtbudgt_lastyear6    number;
    v_amtbudgt_lastyear7    number;
    v_amtbudgt_lastyear8    number;
    v_amtbudgt_lastyear9    number;
    v_amtbudgt_lastyear10   number;
    v_amtbudgt_lastyear11   number;
    v_amtbudgt_lastyear12   number;
  begin
    insert_update_tcodgrbug(p_codgrbug,p_syncond);
    begin
      select stddec(amtbudgt1 ,codgrbug,global_v_chken),
             stddec(amtbudgt2 ,codgrbug,global_v_chken),
             stddec(amtbudgt3 ,codgrbug,global_v_chken),
             stddec(amtbudgt4 ,codgrbug,global_v_chken),
             stddec(amtbudgt5 ,codgrbug,global_v_chken),
             stddec(amtbudgt6 ,codgrbug,global_v_chken),
             stddec(amtbudgt7 ,codgrbug,global_v_chken),
             stddec(amtbudgt8 ,codgrbug,global_v_chken),
             stddec(amtbudgt9 ,codgrbug,global_v_chken),
             stddec(amtbudgt10,codgrbug,global_v_chken),
             stddec(amtbudgt11,codgrbug,global_v_chken),
             stddec(amtbudgt12,codgrbug,global_v_chken)
        into v_amtbudgt_lastyear1  ,v_amtbudgt_lastyear2  ,
             v_amtbudgt_lastyear3  ,v_amtbudgt_lastyear4  ,
             v_amtbudgt_lastyear5  ,v_amtbudgt_lastyear6  ,
             v_amtbudgt_lastyear7  ,v_amtbudgt_lastyear8  ,
             v_amtbudgt_lastyear9  ,v_amtbudgt_lastyear10 ,
             v_amtbudgt_lastyear11 ,v_amtbudgt_lastyear12
        from ttbudsal
       where dteyear   = p_year - 1
         and codgrbug  = p_codgrbug
         and codpay    = p_codpay;
    exception when no_data_found then
      null;
    end;
    v_syncond := p_syncond;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear1,'fm999999999990.00'));
    v_amtpay1 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month1,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month1)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear2,'fm999999999990.00'));
    v_amtpay2 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month2,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month2)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear3,'fm999999999990.00'));
    v_amtpay3 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month3,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month3)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear4,'fm999999999990.00'));
    v_amtpay4 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month4,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month4)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear5,'fm999999999990.00'));
    v_amtpay5 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month5,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month5)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear6,'fm999999999990.00'));
    v_amtpay6 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month6,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month6)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear7,'fm999999999990.00'));
    v_amtpay7 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month7,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month7)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear8,'fm999999999990.00'));
    v_amtpay8 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month8,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month8)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear9,'fm999999999990.00'));
    v_amtpay9 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month9,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month9)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear10,'fm999999999990.00'));
    v_amtpay10 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month10,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month10)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear11,'fm999999999990.00'));
    v_amtpay11 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month11,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month11)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    obj_data := json_object_t();
    obj_data.put('index'   ,to_char(v_count + 1));
    obj_data.put('month'   ,get_nammthful(v_count + 1,global_v_lang));
    v_token := select_amtpay_tsincexp(v_count + 1,p_year-1,v_syncond,p_codpay);
    obj_data.put('lastyear',v_token);
    obj_data.put('lastyear_budget',to_char(v_amtbudgt_lastyear12,'fm999999999990.00'));
    v_amtpay12 := to_number(v_token);
    obj_data.put('increasing',to_char(p_month12,'fm999999999990.00'));
    v_amtbudgt := v_token*(100+p_month12)/100;
    obj_data.put('budget'    ,to_char(v_amtbudgt,'fm999999999990.00'));
    obj_rows.put(to_char(v_count),obj_data);
    v_count := v_count + 1;

    insert_update_ttbudsal_pay(p_year-1   ,p_codgrbug ,p_codpay  ,
                              v_amtpay1  ,v_amtpay2  ,v_amtpay3 ,
                              v_amtpay4  ,v_amtpay5  ,v_amtpay6 ,
                              v_amtpay7  ,v_amtpay8  ,v_amtpay9 ,
                              v_amtpay10 ,v_amtpay11 ,v_amtpay12);
    obj_data := json_object_t();
    obj_data.put('syncond'  ,v_syncond);
    obj_data.put('desc_statement',get_logical_desc(p_statement));
    obj_data.put('statement',p_statement);
    obj_json.put('detail'   ,obj_data);
    obj_json.put('rows'     ,obj_rows);
    obj_json.put('coderror' ,'200');
    json_str_output := obj_json.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_process;
  procedure check_save as
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codgrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codgrbug');
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;
    if p_syncond is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'syncond');
      return;
    end if;
    if param_json is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'param_json');
      return;
    end if;
    if p_codgrbug is not null then
      begin
        select codcodec
          into p_codgrbug
          from tcodgrbug
         where codcodec = p_codgrbug;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrbug');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  end;

  procedure post_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      save_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_data(json_str_output out clob) as
    json_obj        json_object_t;
  begin
    insert_update_tcodgrbug(p_codgrbug,p_syncond);
    insert_update_ttbudsal_budgt(p_year, p_codgrbug, p_codpay,
                                 find_budget(param_json,1 ),
                                 find_budget(param_json,2 ),
                                 find_budget(param_json,3 ),
                                 find_budget(param_json,4 ),
                                 find_budget(param_json,5 ),
                                 find_budget(param_json,6 ),
                                 find_budget(param_json,7 ),
                                 find_budget(param_json,8 ),
                                 find_budget(param_json,9 ),
                                 find_budget(param_json,10),
                                 find_budget(param_json,11),
                                 find_budget(param_json,12),
                                 find_percent(param_json,1),
                                 find_percent(param_json,2),
                                 find_percent(param_json,3),
                                 find_percent(param_json,4),
                                 find_percent(param_json,5),
                                 find_percent(param_json,6),
                                 find_percent(param_json,7),
                                 find_percent(param_json,8),
                                 find_percent(param_json,9),
                                 find_percent(param_json,10),
                                 find_percent(param_json,11),
                                 find_percent(param_json,12));
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2200',global_v_lang);
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


  procedure check_delete as
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codgrbug is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codgrbug');
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;
    if p_codgrbug is not null then
      begin
        select codcodec
          into p_codgrbug
          from tcodgrbug
         where codcodec = p_codgrbug;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodgrbug');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
      end;
    end if;
  end;

  procedure post_delete(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_delete;
    if param_msg_error is null then
        delete_data(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_data(json_str_output out clob) as
    v_chkExist    number;
  begin
    begin
      select count(codpay) into v_chkExist
        from ttbudsal
       where codgrbug = p_codgrbug;
      if v_chkExist < 2 then
--        delete tcodgrbug
--         where codcodec  = p_codgrbug;
        begin
          insert into tcodgrbug (codcodec,syscond,statement,coduser,dteupd,codcreate,dtecreate)
               values (p_codgrbug,null,null,global_v_coduser,sysdate,global_v_coduser,sysdate);
        exception when dup_val_on_index then
          update tcodgrbug
             set syscond  = null,
             statement = null,
             coduser = global_v_coduser,
             dteupd  = sysdate
          where codcodec = p_codgrbug;
        end;
      end if;
    end;
    delete ttbudsal
     where dteyear  = p_year
       and codgrbug = p_codgrbug
       and codpay   = p_codpay;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      json_str_output := get_response_message('200',param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_last_budget(json_str_input in clob,json_str_output out clob) as
    obj_json        json_object_t := json_object_t();
    obj_rows        json_object_t := json_object_t();
    obj_data        json_object_t;
    obj_data_budget json_object_t;
    v_codcomp       varchar2(4000 char);
    v_dteyear       number := 0;
    v_cnt           number := 0;
    v_amtbudgt1     number := 0;
    v_amtbudgt2     number := 0;
    v_amtbudgt3     number := 0;
    v_amtbudgt4     number := 0;
    v_amtbudgt5     number := 0;
    v_amtbudgt6     number := 0;
    v_amtbudgt7     number := 0;
    v_amtbudgt8     number := 0;
    v_amtbudgt9     number := 0;
    v_amtbudgt10    number := 0;
    v_amtbudgt11    number := 0;
    v_amtbudgt12    number := 0;

    type amtpay is table of number index by binary_integer;
         v_amtpay		amtpay;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      if p_year is not null and p_codgrbug is not null and p_codpay is not null then
        --
        for i in 1..12 loop
          v_amtpay(i) := 0 ;
        end loop ;
        --
        v_amtbudgt1     := 0;     v_amtbudgt2     := 0;
        v_amtbudgt3     := 0;     v_amtbudgt4     := 0;
        v_amtbudgt5     := 0;     v_amtbudgt6     := 0;
        v_amtbudgt7     := 0;     v_amtbudgt8     := 0;
        v_amtbudgt9     := 0;     v_amtbudgt10    := 0;
        v_amtbudgt11    := 0;     v_amtbudgt12    := 0;
        --
        begin
          select dteyear,
                 nvl(stddec(amtbudgt1,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt2,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt3,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt4,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt5,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt6,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt7,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt8,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt9,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt10,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt11,codgrbug,global_v_chken),0),
                 nvl(stddec(amtbudgt12,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay1,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay2,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay3,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay4,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay5,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay6,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay7,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay8,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay9,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay10,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay11,codgrbug,global_v_chken),0),
                 nvl(stddec(amtpay12,codgrbug,global_v_chken),0)
          into   v_dteyear,   v_amtbudgt1, v_amtbudgt2, v_amtbudgt3,
                 v_amtbudgt4, v_amtbudgt5, v_amtbudgt6,
                 v_amtbudgt7, v_amtbudgt8, v_amtbudgt9,
                 v_amtbudgt10,v_amtbudgt11,v_amtbudgt12,
                 v_amtpay(1), v_amtpay(2), v_amtpay(3),
                 v_amtpay(4), v_amtpay(5), v_amtpay(6),
                 v_amtpay(7), v_amtpay(8), v_amtpay(9),
                 v_amtpay(10),v_amtpay(11),v_amtpay(12)
          from ttbudsal
          where codgrbug = p_codgrbug
            and codpay   = p_codpay
            and dteyear in (select max(dteyear) from ttbudsal
                             where codgrbug = p_codgrbug
                               and codpay   = p_codpay
                               and dteyear < p_year);
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttbudsal');
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end;

        -- budget month 1 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt1);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 2 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt2);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 3 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt3);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 4 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt4);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 5 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt5);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 6 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt6);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 7 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt7);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 8 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt8);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 9 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt9);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 10 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt10);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 11 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt11);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        -- budget month 12 --
        obj_data_budget := json_object_t();
        obj_data_budget.put('namemonth',get_nammthful(v_cnt + 1,global_v_lang));
        obj_data_budget.put('budget',v_amtbudgt12);
        obj_data_budget.put('actual',v_amtpay(v_cnt + 1));

        obj_rows.put(to_char(v_cnt),obj_data_budget);
        v_cnt := v_cnt + 1;
        --
        --
        obj_data := json_object_t();
        obj_data.put('coderror' ,'200');
        obj_data.put('datarows',obj_rows);
        obj_data.put('dteyear',v_dteyear);

        json_str_output := obj_data.to_clob;
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrpys1e;

/

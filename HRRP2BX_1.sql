--------------------------------------------------------
--  DDL for Package Body HRRP2BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP2BX" is
-- last update: 15/04/2019 17:53
-- last update: 21/08/2020 15:47
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken             := hcm_secur.get_v_chken;
        json_obj            := json_object_t(json_str);
        --global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
       --b_index
        b_index_year        := hcm_util.get_string_t(json_obj,'p_year');
        b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
        b_index_codlinef    := hcm_util.get_string_t(json_obj,'p_codlinef');
        b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
        b_index_dteappr     := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
        b_index_codappr     := hcm_util.get_string_t(json_obj,'p_codappr');
        b_index_staappr     := hcm_util.get_string_t(json_obj,'p_staappr');
        b_index_month       := hcm_util.get_string_t(json_obj,'p_month');
        b_index_codcompp    := hcm_util.get_string_t(json_obj, 'p_codcompp');
        b_index_codpospr    := hcm_util.get_string_t(json_obj, 'p_codpospr');
        b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --


  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_month          varchar2(2 char);
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    v_codcompp      varchar2(400 char);
    v_codpospr      varchar2(400 char);

    cursor c1 is
            select b.codcompp, b.codpospr,a.codappr,b.dteappr,b.codresp,
            b.codlinef, b.dteeffec, b.numlevel 
              from thisorg a , thisorg2 b
             where a.codcompy   = nvl(b_index_codcompy,a.codcompy )
               and a.codlinef   = nvl(b_index_codlinef ,a.codlinef)
               and b.codcompp  like b_index_codcomp||'%'
               and ((v_chksecu  = 1 )
                   or (v_chksecu = '2' and exists (select codcomp from tusrcom x
                                                 where x.coduser = global_v_coduser
                                                   and b.codcompp like b.codcompp||'%')
                 ))
               and to_char(a.dteeffec,'yyyy') <= b_index_year
               and a.staorg     = 'A'--acitve
               and nvl(b.dteappr,to_date('01/01/0001','dd/mm/yyyy'))   = nvl(b_index_dteappr,  nvl(b.dteappr,to_date('01/01/0001','dd/mm/yyyy')))
               and nvl(b.codappr,'########')    = nvl(b_index_codappr,nvl(b.codappr,'########')  )
               and a.codcompy   = b.codcompy
               and a.codlinef   = b.codlinef
               and a.dteeffec   = b.dteeffec
          order by b.codcompp, b.codpospr;

    cursor c2 is
            select  nvl(qtyreqyr,0)qtyreqyr ,
                    nvl(qtypromote,0) qtypromote,
                    nvl(qtyreqyr,0)+nvl(qtypromote,0) total,
                    amttotbudgt, codappr, dteappr ,staappr,dtereq,codemprq
             from   tbudget
            where   dteyrbug                = b_index_year
              and   codcomp                 = v_codcompp
              and   nvl(codpos,'####')      = nvl(v_codpospr,nvl(codpos,'####'))
              and   nvl(staappr,'#')        = nvl(b_index_staappr,nvl(staappr,'#'))
         order by   dtereq asc;

 begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;
    if v_flgdata = 'Y' then
        v_chksecu := '2';
        for i in c1 loop
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            v_codcompp    := i.codcompp;
            v_codpospr    := i.codpospr;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codcomp',v_codcompp);
            obj_data.put('desc_codcomp',get_tcenter_name(v_codcompp,global_v_lang));
            obj_data.put('codpos',v_codpospr);
            obj_data.put('desc_codpos',get_tpostn_name(v_codpospr,global_v_lang));
            obj_data.put('addp','');
            obj_data.put('promp','');
            obj_data.put('totalp','');
            obj_data.put('budget','');
            obj_data.put('approvby','');
            obj_data.put('dteappr','');
            obj_data.put('statusappr','');
            obj_data.put('dtereq','');
            obj_data.put('requestby','');
            --<< user25 Date : 02/09/2021 1. RP Module #3840
               --adjust report
            obj_data.put('codcompy',hcm_util.get_codcomp_level(v_codcompp,1));
            obj_data.put('codlinef',i.codlinef);
            obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
            obj_data.put('numlevel',i.numlevel);
            obj_data.put('codcompp',v_codcompp);
            -->> user25 Date : 02/09/2021 1. RP Module #3840

            for k in c2 loop
                obj_data.put('addp',k.qtyreqyr);
                obj_data.put('promp',k.qtypromote);
                obj_data.put('totalp',k.total);
                obj_data.put('budget',to_char(k.amttotbudgt,'fm999,999,990.00'));
                obj_data.put('approvby',get_temploy_name(k.codappr,global_v_lang));
                obj_data.put('dteappr',to_char(k.dteappr,'dd/mm/yyyy'));
                obj_data.put('statusappr',get_tlistval_name('STAAPPR',k.staappr,global_v_lang));
                obj_data.put('dtereq',to_char(k.dtereq,'dd/mm/yyyy'));
                obj_data.put('requestby',get_temploy_name(k.codemprq,global_v_lang));
            end loop;
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if; --v_flgdata
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'thisorg');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --


  procedure get_detail1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail1(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_label         number := 0;
    v_label1        number := 0;
    v_month         number;
    v_qtymonth      number := 0;
    v_qtynew        number := 0;
    v_qtypromote    number := 0;
    v_qtyreti       number := 0;
    v_grand_tot     number := 0;
    v_amt           number := 0;
    cursor c1 is
        select  dteyrbug,codcomp,codpos,dtereq,dtemthbug,qtymonth,qtynew ,qtypromote ,qtyreti
          from  tbudgetm
         where  dteyrbug        = b_index_year
           and  codcomp         = b_index_codcompp
           and  codpos          = b_index_codpospr
           and  trunc(dtereq)   = b_index_dtereq;
  begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    if v_flgdata = 'Y' then
        v_chksecu := '2';
        v_label  := 200;
        v_label1  := 200;
    for n in 1..5 loop
        v_label1 := v_label+n;
        obj_data := json_object_t();
        v_rcnt := v_rcnt+1;
                  for i in c1 loop
                    v_flgdata := 'Y';
                    v_flgsecu := 'Y';
                        for j in 1..12 loop
                            v_month     := j;
                            begin
                                select  nvl(qtymonth,0) ,nvl(qtynew,0) ,nvl(qtypromote,0) ,nvl(qtyreti,0) ,nvl(qtymonth,0)+nvl(qtynew,0)+nvl(qtypromote,0)+nvl(qtyreti,0)
                                  into  v_qtymonth ,v_qtynew ,v_qtypromote,v_qtyreti,v_grand_tot
                                  from  tbudgetm
                                 where  dteyrbug    = b_index_year
                                   and  codcomp     = b_index_codcompp
                                   and  codpos      = b_index_codpospr
                                   and  trunc(dtereq) = b_index_dtereq
                                   and dtemthbug    = v_month;
                                exception when no_data_found then
                                    v_qtymonth      := 0;
                                    v_qtynew        := 0;
                                    v_qtypromote    := 0;
                                    v_qtyreti       := 0;
                                    v_grand_tot     := 0;
                            end;

                            obj_data.put('coderror', '200');
                            obj_data.put('detail',get_label_name('HRRP2BX2' ,global_v_lang ,v_label1) );
                            v_amt := null;
                            if     n = 1 then
                                 v_amt := v_qtymonth;
                            elsif  n = 2 then
                                 v_amt := v_qtynew;
                            elsif  n = 3 then
                                 v_amt := v_qtypromote;
                            elsif  n = 4 then
                                 v_amt := v_qtyreti;
                            elsif  n = 5 then
                                 v_amt := v_grand_tot;
                            end if;
                             obj_data.put('month'||to_char(j),to_char(v_amt,'fm99,999,990'));
                        end loop;
                    exit;
                  end loop;
          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
  end if;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbudgetm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;


  -------
  procedure get_detail2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail2(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_label         number := 0;
    v_label1        number := 0;
    v_month         number;
    v_amtsalmth     number := 0;
    v_amthirebudgt  number := 0;
    v_amtprobudgt   number := 0;
    v_amtresbudgt   number := 0;
    v_amttotbudgt   number := 0;
    v_amtother      number := 0;
    v_amttot        number := 0;
    v_amt           number := 0;
    cursor c1 is
        select  dteyrbug,codcomp,codpos,dtereq,dtemthbug,qtymonth,qtynew ,qtypromote ,qtyreti
          from  tbudgetm
         where  dteyrbug        = b_index_year
           and  codcomp         = b_index_codcompp
           and  codpos          = b_index_codpospr
           and  trunc(dtereq)   = b_index_dtereq;
  begin
    obj_row := json_object_t();
    v_chksecu := '1';
    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    if v_flgdata = 'Y' then
        v_chksecu := '2';
        v_label   := 210;
        v_label1  := 210;
    for n in 1..7 loop
        v_label1 := v_label+n;
        obj_data := json_object_t();
        v_rcnt := v_rcnt+1;
                  for i in c1 loop
                    v_flgdata := 'Y';
                    v_flgsecu := 'Y';
                        for j in 1..12 loop
                            v_month     := j;
                            begin
                                select nvl(amtsalmth,0) ,nvl(amthirebudgt,0) ,nvl(amtprobudgt,0) ,nvl(amtresbudgt,0) ,nvl(amttotbudgt,0), nvl(amtother,0) ,
                                       nvl(amttotbudgt,0)+nvl(amtother,0)
                                into  v_amtsalmth ,v_amthirebudgt ,v_amtprobudgt,v_amtresbudgt,v_amttotbudgt ,v_amtother ,v_amttot
                                 from tbudgetm
                                where dteyrbug     = b_index_year
                                and   codcomp      = b_index_CODCOMPP
                                and   codpos       = b_index_codpospr
                                and  trunc(dtereq) = b_index_dtereq
                                and dtemthbug = v_month;
                                exception when no_data_found then
                                    v_amtsalmth      := 0;
                                    v_amthirebudgt   := 0;
                                    v_amtprobudgt    := 0;
                                    v_amtresbudgt    := 0;
                                    v_amttotbudgt    := 0;
                                    v_amtother       := 0;
                                    v_amttot         := 0;
                            end;
                            obj_data.put('coderror', '200');
                            obj_data.put('detail',get_label_name('HRRP2BX2' ,global_v_lang ,v_label1) );
                            v_amt := null;
                            if     n = 1 then
                                 v_amt := v_amtsalmth;
                            elsif  n = 2 then
                                 v_amt := v_amthirebudgt;
                            elsif  n = 3 then
                                 v_amt := v_amtprobudgt;
                            elsif  n = 4 then
                                 v_amt := v_amtresbudgt;
                            elsif  n = 5 then
                                 v_amt := v_amttotbudgt ;
                            elsif  n = 6 then
                                 v_amt := v_amtother ;
                            elsif  n = 7 then
                                 v_amt := v_amttot ;
                            end if;
                             obj_data.put('month'||to_char(j),to_char(v_amt,'fm99,999,990'));
                        end loop;
                    exit;
                  end loop;
          obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
  end if;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbudgetm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  -----

end;

/

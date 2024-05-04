--------------------------------------------------------
--  DDL for Package Body HRPMBDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMBDE" is
  procedure initial_value(json_str_input in clob) as
    json_obj          json_object_t;
    v_codleave        json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_dteeffec    := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index is
  begin
    if b_index_codcompy is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;
  --
  function gen_index(json_str_input in clob) return clob is
    obj_typemp_data     json_object_t;
    obj_typemp_rows     json_object_t;
    obj_income_data     json_object_t;
    obj_income_rows     json_object_t;
    obj_row             json_object_t;
    v_rcnt_typemp       number  := 0;
    v_rcnt_income       number  := 0;

    v_codcurr           tcontrpy.codcurr%type;
    v_desc_codcurr      tcodcurr.descode%type;
    v_codempmt          temploy1.codempid%type;
    v_break_codempmt    temploy1.codempmt%type  := '!@#$';
    --<<User37 #5130 Final Test Phase 1 V11 01/03/2021
    data_row            json_object_t;
    detail_obj          json_object_t;
    json_obj            json_object_t;
    v_dteeffec          date;
    v_dteeffecs         date;
    v_dteeffecd         date;
    -->>User37 #5130 Final Test Phase 1 V11 01/03/2021

    cursor c_tcodempl is
      select  codcodec,
              decode(global_v_lang,'101',descode
                                  ,'102',descodt
                                  ,'103',descod3
                                  ,'104',descod4
                                  ,'105',descod5) as descod
      from    tcodempl
      where   nvl(flgact,'1') = '1'
      order by codcodec ;

    cursor c_codpay is
      select  pms.codincom1,pms.codincom2,pms.codincom3,pms.codincom4,pms.codincom5,
              pms.codincom6,pms.codincom7,pms.codincom8,pms.codincom9,pms.codincom10,
              pmd.unitcal1,pmd.unitcal2,pmd.unitcal3,pmd.unitcal4,pmd.unitcal5,
              pmd.unitcal6,pmd.unitcal7,pmd.unitcal8,pmd.unitcal9,pmd.unitcal10,
              pmd.amtmax1,pmd.amtmax2,pmd.amtmax3,pmd.amtmax4,pmd.amtmax5,
              pmd.amtmax6,pmd.amtmax7,pmd.amtmax8,pmd.amtmax9,pmd.amtmax10,
              pmd.dteeffec,pmd.formulam,pmd.formulad,pmd.formulah
      from    tcontpms pms ,tcontpmd pmd
      where   pms.codcompy   = b_index_codcompy
       and    pms.dteeffec   = v_dteeffecs
       and    pms.codcompy   = pmd.codcompy(+)
       and    v_codempmt     = pmd.codempmt(+)
       and    v_dteeffecd    = pmd.dteeffec(+)     ;

  begin
    --<<User37 #5130 Final Test Phase 1 V11 01/03/2021
    json_obj     := json_object_t();
    detail_obj   := json_object_t();
    data_row     := json_object_t();
    -->>User37 #5130 Final Test Phase 1 V11 01/03/2021
    obj_typemp_rows   := json_object_t();
    begin
      select max(dteeffec) into v_dteeffecs
      from   tcontpms
      where  codcompy   = b_index_codcompy
      and    dteeffec   <= trunc(sysdate) ;
    exception when others then
       v_dteeffecs  := null ;
    end ;

    begin
      select  codcurr,get_tcodec_name('TCODCURR',codcurr,global_v_lang)
      into    v_codcurr,v_desc_codcurr
      from    tcontrpy
      where   codcompy    = b_index_codcompy
      and     dteeffec    = ( select  max(t2.dteeffec)
                              from    tcontrpy  t2
                              where   t2.codcompy   = b_index_codcompy
                              and     t2.dteeffec   <= trunc(sysdate));
    exception when no_data_found then
      null;
    end;

    --<<User37 #5130 Final Test Phase 1 V11 01/03/2021
    json_obj.put('coderror','200');
    if b_index_dteeffec >= trunc(sysdate) then
        detail_obj.put('flgDisable',false);
        detail_obj.put('warning','');
        v_dteeffec := b_index_dteeffec;
    else
        detail_obj.put('flgDisable',true);
        detail_obj.put('warning',replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400'));
        begin
            select max(dteeffec)
              into v_dteeffec
              from tcontpmd
             where codcompy = b_index_codcompy
               and dteeffec <= b_index_dteeffec;
        exception when no_data_found then
            detail_obj.put('flgDisable',false);
            detail_obj.put('warning','');
        end;
        if v_dteeffec is null then
            detail_obj.put('flgDisable',false);
            detail_obj.put('warning','');
            v_dteeffec := b_index_dteeffec;
        end if;
    end if;
    -->>User37 #5130 Final Test Phase 1 V11 01/03/2021

    for r_tcodempl in c_tcodempl loop
      v_rcnt_typemp     := v_rcnt_typemp + 1;
      obj_typemp_data   := json_object_t();
      obj_row           := json_object_t();
      obj_typemp_data.put('coderror','200');
      obj_typemp_data.put('typemp',r_tcodempl.codcodec);
      obj_typemp_data.put('desc_typemp',r_tcodempl.descod);
      obj_typemp_data.put('codcurr',v_codcurr);
      obj_typemp_data.put('desc_curr',v_desc_codcurr);
      obj_income_rows     := json_object_t();
      v_codempmt          := r_tcodempl.codcodec;
      v_rcnt_income       := 0;
      begin
        select   max(dteeffec) into v_dteeffecd
        from     tcontpmd
        where    codcompy    = b_index_codcompy
        and      codempmt    = v_codempmt
        and      dteeffec   <= v_dteeffec ;
      exception when no_data_found then
        v_dteeffecd := null ;
      end;
      for r_codpay in c_codpay loop
        null;
        if v_codempmt <> v_break_codempmt then
          obj_typemp_data.put('dteeffec',to_char(r_codpay.dteeffec,'dd/mm/yyyy'));
          obj_typemp_data.put('formulam',r_codpay.formulam);
          obj_typemp_data.put('desc_formulam',hcm_formula.get_description(r_codpay.formulam,global_v_lang));
          obj_typemp_data.put('formulad',r_codpay.formulad);
          obj_typemp_data.put('desc_formulad',hcm_formula.get_description(r_codpay.formulad,global_v_lang));
          obj_typemp_data.put('formulah',r_codpay.formulah);
          obj_typemp_data.put('desc_formulah',hcm_formula.get_description(r_codpay.formulah,global_v_lang));
          v_break_codempmt  := v_codempmt;
        end if;

        if r_codpay.codincom1 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom1);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom1,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal1,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax1);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom2 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom2);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom2,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal2,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax2);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom3 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom3);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom3,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal3,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax3);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom4 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom4);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom4,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal4,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax4);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom5 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom5);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom5,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal5,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax5);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom6 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom6);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom6,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal6,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax6);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom7 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom7);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom7,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal7,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax7);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom8 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom8);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom8,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal8,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax8);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom9 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom9);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom9,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal9,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax9);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;
        if r_codpay.codincom10 is not null then
          v_rcnt_income     := v_rcnt_income + 1;
          obj_income_data   := json_object_t();
          obj_income_data.put('codpay',r_codpay.codincom10);
          obj_income_data.put('desc_codpay',get_tinexinf_name(r_codpay.codincom10,global_v_lang));
          obj_income_data.put('unit',nvl(r_codpay.unitcal10,'M'));
          obj_income_data.put('amtmax',r_codpay.amtmax10);
          obj_income_rows.put(to_char(v_rcnt_income - 1),obj_income_data);
        end if;

      end loop;
--      obj_row.put('rows',obj_income_rows);
      obj_typemp_data.put('income',obj_income_rows);
      obj_typemp_rows.put(to_char(v_rcnt_typemp - 1),obj_typemp_data);


    end loop;
    --<<User37 #5130 Final Test Phase 1 V11 01/03/2021
    if b_index_dteeffec >= trunc(sysdate) then
        detail_obj.put('dteeffec',nvl(to_char(b_index_dteeffec,'dd/mm/yyyy'),''));
    else
        detail_obj.put('dteeffec',nvl(to_char(v_dteeffec,'dd/mm/yyyy'),''));
    end if;
    data_row.put('rows',obj_typemp_rows);
    json_obj.put('table',data_row);
    json_obj.put('detail',detail_obj);
    return json_obj.to_clob;
    --return obj_typemp_rows.to_clob;
    -->>User37 #5130 Final Test Phase 1 V11 01/03/2021

  end;
  --
  procedure get_index(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      json_str_output   := gen_index(json_str_input);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_error_msg(json_str_input in clob,json_str_output out clob) is
    obj_data    json_object_t;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('PM0118',get_errorm_name('PM0118',global_v_lang));
    obj_data.put('PM0119',get_errorm_name('PM0119',global_v_lang));
    obj_data.put('PM0120',get_errorm_name('PM0120',global_v_lang));
    obj_data.put('PM0121',get_errorm_name('PM0121',global_v_lang));
    obj_data.put('PM0122',get_errorm_name('PM0122',global_v_lang));
    obj_data.put('PM0126',get_errorm_name('PM0126',global_v_lang));
    json_str_output   := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_index(json_str_input in clob,json_str_output out clob) is
    json_str          json_object_t;
    json_index        json_object_t;
    json_index_row    json_object_t;
    json_income       json_object_t;
    json_income_row   json_object_t;
    v_response_json   json_object_t;
    r_tcontpmd        tcontpmd%rowtype;
    v_found_data      varchar2(1);
    v_unitcal1        tcontpmd.unitcal1%type;
    v_amtmax1         tcontpmd.amtmax1%type;
    type r_income is record (
      unitcal   tcontpmd.unitcal1%type,
      amtmax    tcontpmd.amtmax1%type
    );
    type t_income is table of r_income index by binary_integer;
    v_income    t_income;
  begin
    initial_value(json_str_input);
    json_str          := json_object_t(json_str_input);
    json_index        := hcm_util.get_json_t(json_str,'json_input_str');
    for i in 1..json_index.get_size loop
      json_index_row        := hcm_util.get_json_t(json_index,(i - 1));
      r_tcontpmd.codempmt   := hcm_util.get_string_t(json_index_row,'typemp');
      r_tcontpmd.dteeffec   := to_date(hcm_util.get_string_t(json_index_row,'dteeffec'),'dd/mm/yyyy');
      r_tcontpmd.formulah   := hcm_util.get_string_t(hcm_util.get_json_t(json_index_row,'formulah'),'code');
      r_tcontpmd.formulad   := hcm_util.get_string_t(hcm_util.get_json_t(json_index_row,'formulad'),'code');
      r_tcontpmd.formulam   := hcm_util.get_string_t(hcm_util.get_json_t(json_index_row,'formulam'),'code');
      json_income           := hcm_util.get_json_t(hcm_util.get_json_t(json_index_row,'income'),'rows');
      for k in 1..10 loop
        v_income(k).unitcal := null;
        v_income(k).amtmax  := null;
      end loop;
      for j in 1..json_income.get_size loop
        json_income_row       := hcm_util.get_json_t(json_income,(j - 1));
        v_income(j).unitcal   := hcm_util.get_string_t(json_income_row,'unit');
        v_income(j).amtmax    := hcm_util.get_string_t(json_income_row,'amtmax');
      end loop;

      begin
        select  'Y'
        into    v_found_data
        from    tcontpmd
        where   codcompy    = b_index_codcompy
        and     dteeffec    = b_index_dteeffec
        and     codempmt    = r_tcontpmd.codempmt;
      exception when no_data_found then
        v_found_data  := 'N';
      end;
      if v_found_data = 'N' then
        insert into tcontpmd(codcompy,dteeffec,codempmt,
                            unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
                            unitcal6,unitcal7,unitcal8,unitcal9,unitcal10,
                            amtmax1,amtmax2,amtmax3,amtmax4,amtmax5,
                            amtmax6,amtmax7,amtmax8,amtmax9,amtmax10,
                            formulam,formulad,formulah,codcreate,coduser)
                     values (b_index_codcompy,b_index_dteeffec,r_tcontpmd.codempmt,
                            v_income(1).unitcal,v_income(2).unitcal,v_income(3).unitcal,v_income(4).unitcal,v_income(5).unitcal,
                            v_income(6).unitcal,v_income(7).unitcal,v_income(8).unitcal,v_income(9).unitcal,v_income(10).unitcal,
                            v_income(1).amtmax,v_income(2).amtmax,v_income(3).amtmax,v_income(4).amtmax,v_income(5).amtmax,
                            v_income(6).amtmax,v_income(7).amtmax,v_income(8).amtmax,v_income(9).amtmax,v_income(10).amtmax,
                            r_tcontpmd.formulam,r_tcontpmd.formulad,r_tcontpmd.formulah,global_v_coduser,global_v_coduser);
      else
        update  tcontpmd
        set     unitcal1    = v_income(1).unitcal,
                unitcal2    = v_income(2).unitcal,
                unitcal3    = v_income(3).unitcal,
                unitcal4    = v_income(4).unitcal,
                unitcal5    = v_income(5).unitcal,
                unitcal6    = v_income(6).unitcal,
                unitcal7    = v_income(7).unitcal,
                unitcal8    = v_income(8).unitcal,
                unitcal9    = v_income(9).unitcal,
                unitcal10   = v_income(10).unitcal,
                amtmax1     = v_income(1).amtmax,
                amtmax2     = v_income(2).amtmax,
                amtmax3     = v_income(3).amtmax,
                amtmax4     = v_income(4).amtmax,
                amtmax5     = v_income(5).amtmax,
                amtmax6     = v_income(6).amtmax,
                amtmax7     = v_income(7).amtmax,
                amtmax8     = v_income(8).amtmax,
                amtmax9     = v_income(9).amtmax,
                amtmax10    = v_income(10).amtmax,
                formulam    = r_tcontpmd.formulam,
                formulad    = r_tcontpmd.formulad,
                formulah    = r_tcontpmd.formulah
        where   codcompy    = b_index_codcompy
        and     dteeffec    = b_index_dteeffec
        and     codempmt    = r_tcontpmd.codempmt;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error   := get_error_msg_php('HR2401',global_v_lang);
    end if;
    v_response_json   := json_object_t(get_response_message(null,param_msg_error,global_v_lang));
    json_str_output   := v_response_json.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function process_data return varchar2 is
    v_month         number;
    v_day           number;
    v_hr            number;
    v_dayc          varchar2(20);
    v_hrc           varchar2(20);
    json_str_output clob;
  cursor c1 is
    select a.codempid,codcomp ,codempmt,
           stddec(amtincom1,a.codempid,global_v_chken) amtincom1,
           stddec(amtincom2,a.codempid,global_v_chken) amtincom2,
           stddec(amtincom3,a.codempid,global_v_chken) amtincom3,
           stddec(amtincom4,a.codempid,global_v_chken) amtincom4,
           stddec(amtincom5,a.codempid,global_v_chken) amtincom5,
           stddec(amtincom6,a.codempid,global_v_chken) amtincom6,
           stddec(amtincom7,a.codempid,global_v_chken) amtincom7,
           stddec(amtincom8,a.codempid,global_v_chken) amtincom8,
           stddec(amtincom9,a.codempid,global_v_chken) amtincom9,
           stddec(amtincom10,a.codempid,global_v_chken) amtincom10
    from   temploy1 a,temploy3 b
    where  a.codempid   = b.codempid
    and		 codcomp	    like b_index_codcompy||'%'
    order by codcomp,codempmt;
  begin
    for i in c1 loop
      get_wage_income(b_index_codcompy,i.codempmt,
                      i.amtincom1,i.amtincom2,i.amtincom3,i.amtincom4,i.amtincom5,
                      i.amtincom6,i.amtincom7,i.amtincom8,i.amtincom9,i.amtincom10,
                      v_hr,v_day,v_month);
      v_dayc := stdenc(v_day,i.codempid,global_v_chken);
      v_hrc  := stdenc(v_hr,i.codempid,global_v_chken);
      update  temploy3
      set     amtothr   = v_hrc,
              amtday    = v_dayc,
              coduser   = global_v_coduser
      where codempid    = i.codempid;
    end loop;
    commit;
    param_msg_error   := get_error_msg_php('HR2715',global_v_lang);
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    return json_str_output;
  end;
  --
  procedure process_cal(json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    json_str_output   := process_data;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

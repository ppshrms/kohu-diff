--------------------------------------------------------
--  DDL for Package Body HRRP14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP14E" is

  /* ######### Example #########
    set serveroutput on
    declare
      v_in  clob := '{"p_coduser":"TJS00001", "p_lang":"101", "p_where":"rownum <= 2"}';
    begin
      dbms_output.put_line(hcm_lov_codcomp_by_s.get_codcomp(v_in));
    end;
  ############################## */

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    -- lov params
    p_comgrp           := hcm_util.get_string_t(json_obj,'p_comgrp');
    p_codcompy         := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codlinef         := hcm_util.get_string_t(json_obj,'p_codlinef');
    p_dtetrial         := to_date(hcm_util.get_string_t(json_obj,'p_dtetrial'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    begin
      select codempid
        into global_v_codempid
        from tusrprof
       where coduser = global_v_coduser;
    exception when no_data_found then
      global_v_coduser := null;
    end;
  end;
  --
  function get_codcompst(json_str_input in clob) return T_LOV is
    PRAGMA AUTONOMOUS_TRANSACTION;
    obj_row         T_LOV := T_LOV();
    v_codcomp_full  varchar2(2002 char) := '';
    v_codcomp       varchar2(2000 char);
    v_max_comlevel  number;
    namcent         varchar2(4000 char);
    v_row           number := 0;
    v_where         varchar2(2500 char);
		v_stmt			    varchar2(2500 char);
		v_data1			    varchar2(2500 char);
    v_array_key     varchar2(400 char);
    v_numseq        number := 0;
    v_name_comlevel varchar2(500);
    v_comp_split    varchar2(50);
    v_full_comp     varchar2(50);
    v_flg_exists    boolean := false;

    type arr_1d is table of varchar2(4000 char) index by varchar2(400 char);
    v_array           arr_1d;
    type arr_number is table of number index by binary_integer;
    v_arr_comp_digit  arr_number;

    cursor c_tusrcom is
        select  codcomp,
                hcm_util.get_level_from_codcomp(codcomp) v_level
        from tusrcom where coduser = global_v_coduser
        order by codcomp;

    cursor c_tcenter is
        select codcomp, comlevel
          from tcenter
         where codcomp like v_codcomp || '%' 
           and (p_codcompy is null or codcomp like p_codcompy||'%')
           and flgact = '1'
         order by codcomp;

    cursor c_tcenter2 is
        select codcompy,decode(comlevel,'1',codcom1,'2',codcom2,
                                        '3',codcom3,'4',codcom4,
                                        '5',Codcom5,'6',codcom6,
                                        '7',codcom7,'8',codcom8,
                                        '9',codcom9,'10',codcom10,
                                        codcom1) as comp_split,
               namcente,namcentt,namcent3,namcent4,namcent5,
               comlevel comlevel,
               codcom1,codcom2,codcom3,codcom4,codcom5,
               codcom6,codcom7,codcom8,codcom9,codcom10,
               codcomp
          from tcenter
         where codcomp = v_codcomp_full
            and flgact = '1';
  
    cursor c_torgprt2_2 is
      select codcompy,decode(numlevel,'1',codcom1,'2',codcom2,
                                      '3',codcom3,'4',codcom4,
                                      '5',Codcom5,'6',codcom6,
                                      '7',codcom7,'8',codcom8,
                                      '9',codcom9,'10',codcom10,
                                      codcom1) as comp_split,
             get_tcompnyd_name(codcompy,numlevel,decode(numlevel,'1',codcom1,'2',codcom2,
                                                                 '3',codcom3,'4',codcom4,
                                                                 '5',Codcom5,'6',codcom6,
                                                                 '7',codcom7,'8',codcom8,
                                                                 '9',codcom9,'10',codcom10,
                                                                 codcom1),'101') namcente,
             get_tcompnyd_name(codcompy,numlevel,decode(numlevel,'1',codcom1,'2',codcom2,
                                                                 '3',codcom3,'4',codcom4,
                                                                 '5',Codcom5,'6',codcom6,
                                                                 '7',codcom7,'8',codcom8,
                                                                 '9',codcom9,'10',codcom10,
                                                                 codcom1),'102') namcentt,
             get_tcompnyd_name(codcompy,numlevel,decode(numlevel,'1',codcom1,'2',codcom2,
                                                                 '3',codcom3,'4',codcom4,
                                                                 '5',Codcom5,'6',codcom6,
                                                                 '7',codcom7,'8',codcom8,
                                                                 '9',codcom9,'10',codcom10,
                                                                 codcom1),'103') namcent3,
             get_tcompnyd_name(codcompy,numlevel,decode(numlevel,'1',codcom1,'2',codcom2,
                                                                 '3',codcom3,'4',codcom4,
                                                                 '5',Codcom5,'6',codcom6,
                                                                 '7',codcom7,'8',codcom8,
                                                                 '9',codcom9,'10',codcom10,
                                                                 codcom1),'104') namcent4,
             get_tcompnyd_name(codcompy,numlevel,decode(numlevel,'1',codcom1,'2',codcom2,
                                                                 '3',codcom3,'4',codcom4,
                                                                 '5',Codcom5,'6',codcom6,
                                                                 '7',codcom7,'8',codcom8,
                                                                 '9',codcom9,'10',codcom10,
                                                                 codcom1),'105') namcent5,
             numlevel comlevel,
             codcom1,codcom2,codcom3,codcom4,codcom5,
             codcom6,codcom7,codcom8,codcom9,codcom10,
             codcompp codcomp
        from torgprt2 
       where codcompy = p_codcompy
         and dteeffec = p_dtetrial
         and codlinef = p_codlinef
         and codcompp = v_codcomp_full;
         
    cursor c_setcomp is
      select numseq,qtycode
        from tsetcomp
      order by numseq;

    cursor c_torgprt2 is
      select codcompp
        from torgprt2
       where codcompy = p_codcompy
         and dteeffec = p_dtetrial
         and codlinef = p_codlinef;
  begin
    initial_value(json_str_input);

    for i in 1..10 loop
      v_arr_comp_digit(i)   := 0;
    end loop;  

    for i in c_setcomp loop
      v_numseq                    := v_numseq + 1;
      v_arr_comp_digit(v_numseq)  := i.qtycode;
    end loop;

    begin
      select max(numseq) into v_max_comlevel
        from tsetcomp;
    exception when no_data_found then
      v_max_comlevel := 0;
    end;

    for r_tusrcom in c_tusrcom loop
        v_codcomp := r_tusrcom.codcomp;
        for v_level in 1..r_tusrcom.v_level - 1 loop
            v_codcomp_full := hcm_util.get_codcomp_level(v_codcomp, v_level, '', 'Y');
            v_array(v_codcomp_full) := 'temp';
        end loop;
        for r_tcenter in c_tcenter loop
            v_codcomp_full := r_tcenter.codcomp;
            v_array(v_codcomp_full) := '';
        end loop;
    end loop;
    
    for r_torgprt2 in c_torgprt2 loop
        v_codcomp_full := r_torgprt2.codcompp;
        v_array(v_codcomp_full) := '';
    end loop;

    v_cursor  := dbms_sql.open_cursor;
    v_array_key := v_array.first;

    while v_array_key is not null loop
      v_row := v_row + 1;
      v_codcomp_full := v_array_key;
      v_flg_exists := false;
      for r_tcenter2 in c_tcenter2 loop
        v_flg_exists := true;
        v_name_comlevel := hcm_lov_codcomp.get_comp_level_name(r_tcenter2.codcompy, r_tcenter2.comlevel);
        v_comp_split    := r_tcenter2.comp_split;
        v_full_comp     := nvl(r_tcenter2.codcom1,rpad('0',v_arr_comp_digit(1),'0'))||'-'||
                           nvl(r_tcenter2.codcom2,rpad('0',v_arr_comp_digit(2),'0'))||'-'||
                           nvl(r_tcenter2.codcom3,rpad('0',v_arr_comp_digit(3),'0'))||'-'||
                           nvl(r_tcenter2.codcom4,rpad('0',v_arr_comp_digit(4),'0'))||'-'||
                           nvl(r_tcenter2.codcom5,rpad('0',v_arr_comp_digit(5),'0'))||'-'||
                           nvl(r_tcenter2.codcom6,rpad('0',v_arr_comp_digit(6),'0'))||'-'||
                           nvl(r_tcenter2.codcom7,rpad('0',v_arr_comp_digit(7),'0'))||'-'||
                           nvl(r_tcenter2.codcom8,rpad('0',v_arr_comp_digit(8),'0'))||'-'||
                           nvl(r_tcenter2.codcom9,rpad('0',v_arr_comp_digit(9),'0'))||'-'||
                           nvl(r_tcenter2.codcom10,rpad('0',v_arr_comp_digit(10),'0'))||'-';
        
        if global_v_lang = '101' then
          namcent := r_tcenter2.namcente;
        elsif global_v_lang = '102' then
          namcent := r_tcenter2.namcentt;
        elsif global_v_lang = '103' then
          namcent := r_tcenter2.namcent3;
        elsif global_v_lang = '104' then
          namcent := r_tcenter2.namcent4;
        elsif global_v_lang = '105' then
          namcent := r_tcenter2.namcent5;
        end if;
        obj_row.extend;
        obj_row(obj_row.last) := TYPE_LOV(
                                    '200',' ',
                                    nvl('' , ' '),
                                    nvl(v_comp_split, ' '),
                                    nvl(namcent, ' '),
                                    nvl(to_char(r_tcenter2.comlevel), ' '),
                                    nvl(v_name_comlevel, ' '),
                                    nvl(substr(v_full_comp,1,instr(v_full_comp,'-',1,v_max_comlevel) - 1), ' '),
                                    nvl(v_array(v_codcomp_full), ' '),
                                    nvl('', ' '),
                                    nvl('', ' '),
                                    nvl('', ' '),
                                    nvl('', ' '),
                                    nvl('', ' '),
                                    nvl('', ' ')
                                 );
      end loop;
      
      if not v_flg_exists then
        for r_tcenter2 in c_torgprt2_2 loop
          v_flg_exists := true;
          v_name_comlevel := hcm_lov_codcomp.get_comp_level_name(r_tcenter2.codcompy, r_tcenter2.comlevel);
          v_comp_split    := r_tcenter2.comp_split;
          v_full_comp     := nvl(r_tcenter2.codcom1,rpad('0',v_arr_comp_digit(1),'0'))||'-'||
                             nvl(r_tcenter2.codcom2,rpad('0',v_arr_comp_digit(2),'0'))||'-'||
                             nvl(r_tcenter2.codcom3,rpad('0',v_arr_comp_digit(3),'0'))||'-'||
                             nvl(r_tcenter2.codcom4,rpad('0',v_arr_comp_digit(4),'0'))||'-'||
                             nvl(r_tcenter2.codcom5,rpad('0',v_arr_comp_digit(5),'0'))||'-'||
                             nvl(r_tcenter2.codcom6,rpad('0',v_arr_comp_digit(6),'0'))||'-'||
                             nvl(r_tcenter2.codcom7,rpad('0',v_arr_comp_digit(7),'0'))||'-'||
                             nvl(r_tcenter2.codcom8,rpad('0',v_arr_comp_digit(8),'0'))||'-'||
                             nvl(r_tcenter2.codcom9,rpad('0',v_arr_comp_digit(9),'0'))||'-'||
                             nvl(r_tcenter2.codcom10,rpad('0',v_arr_comp_digit(10),'0'))||'-';
          
          if global_v_lang = '101' then
            namcent := r_tcenter2.namcente;
          elsif global_v_lang = '102' then
            namcent := r_tcenter2.namcentt;
          elsif global_v_lang = '103' then
            namcent := r_tcenter2.namcent3;
          elsif global_v_lang = '104' then
            namcent := r_tcenter2.namcent4;
          elsif global_v_lang = '105' then
            namcent := r_tcenter2.namcent5;
          end if;
          obj_row.extend;
          obj_row(obj_row.last) := TYPE_LOV(
                                      '200',' ',
                                      nvl('' , ' '),
                                      nvl(v_comp_split, ' '),
                                      nvl(namcent, ' '),
                                      nvl(to_char(r_tcenter2.comlevel), ' '),
                                      nvl(v_name_comlevel, ' '),
                                      nvl(substr(v_full_comp,1,instr(v_full_comp,'-',1,v_max_comlevel) - 1), ' '),
                                      nvl(v_array(v_codcomp_full), ' '),
                                      nvl('', ' '),
                                      nvl('', ' '),
                                      nvl('', ' '),
                                      nvl('', ' '),
                                      nvl('', ' '),
                                      nvl('', ' ')
                                   );
        end loop;
      end if;
      
      v_array_key := v_array.NEXT(v_array_key);
    end loop;
    dbms_sql.close_cursor(v_cursor);

    return obj_row;

  exception when others then
    obj_row.extend;
    obj_row(obj_row.first) := TYPE_LOV('400',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace,' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ',
                                       ' ',' ',' ',' ');
    return obj_row;
  end;

end;

/

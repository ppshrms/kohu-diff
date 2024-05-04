--------------------------------------------------------
--  DDL for Package Body HCM_LOV_CODCOMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LOV_CODCOMP" is

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
    param_flg_secur     := nvl(hcm_util.get_string_t(json_obj,'p_flg_secur'),'Y');
    param_where         := hcm_util.get_string_t(json_obj,'p_where');

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
  function get_comp_level_name(p_codcompy varchar2, p_level number) return varchar2 is
    v_return        varchar2(500);
    v_unit_label    tapplscr.desclabele%type;
  begin
    begin
      select decode(global_v_lang,'101', namcente ,
                           '102', namcentt,
                           '103', namcent3,
                           '104', namcent4,
                           '105', namcent5,namcentt) namecomp
      into   v_return
      from   tcompnyc
      where  comlevel    = p_level
      and    codcompy    = p_codcompy;
    exception when no_data_found then
      v_return  := '';
    end;

    v_unit_label  := get_label_name('SCRLABEL',global_v_lang,2490);
    if p_level = 1 then
      v_return      := get_label_name('SCRLABEL',global_v_lang,2250);
    else
      v_return      := nvl(v_return,v_unit_label || ' ' || to_char(p_level)) ;
    end if;
    return v_return;
  end;
  --
  function get_codcomp_new(json_str_input in clob) return T_LOV is
    PRAGMA AUTONOMOUS_TRANSACTION;
    obj_row         T_LOV := T_LOV();
    v_codcomp_full  varchar2(2002 char) := '';
    v_codcomp       varchar2(2000 char);
    v_max_comlevel  number;
    namcent         varchar2(4000 char);
    v_row           number := 0;
    v_where         varchar2(2500 char);
    v_stmt			varchar2(2500 char);
    v_data1			varchar2(2500 char);
    v_flgdata       boolean := true;
    v_array_key     varchar2(400 char);
    v_numseq        number := 0;
    v_name_comlevel varchar2(500 char);
    v_comp_split    varchar2(50 char);
    v_full_comp     varchar2(50 char);
    v_flgtemp       varchar2(50 char);
    v_desc_cancel   varchar2(100 char);

    type arr_1d is table of varchar2(4000 char) index by varchar2(400 char);
    v_array           arr_1d;
    type arr_number is table of number index by binary_integer;
    v_arr_comp_digit  arr_number;

    cursor c_tusrcom is
        select  --hcm_util.get_codcomp_level(codcomp, 1) codcompy,
                codcomp,
                hcm_util.get_level_from_codcomp(codcomp) v_level
        from tusrcom where coduser = global_v_coduser
        order by codcomp;

    cursor c_tcenter is
        select codcomp, comlevel, flgact
          from tcenter
         where codcomp like v_codcomp || '%'
           --and flgact <> '2' -- don't show delete 4449#899 (flgact =2 -> for display in frontend but cannot select)
         order by codcomp;

    cursor c_tcenter2 is
        select codcompy,decode(comlevel,'1',codcom1,'2',codcom2,
                                        '3',codcom3,'4',codcom4,
                                        '5',Codcom5,'6',codcom6,
                                        '7',codcom7,'8',codcom8,
                                        '9',codcom9,'10',codcom10,
                                        codcom1) as comp_split,
               namcente,namcentt,namcent3,namcent4,namcent5,
               comlevel comlevel,flgact,
               codcom1,codcom2,codcom3,codcom4,codcom5,
               codcom6,codcom7,codcom8,codcom9,codcom10
          from tcenter
         where codcomp = v_codcomp_full
      order by codcomp;

    cursor c_setcomp is
      select numseq,qtycode
        from tsetcomp
      order by numseq;
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

    if param_flg_secur = 'Y' then -- check secur
      for r_tusrcom in c_tusrcom loop
          v_codcomp := r_tusrcom.codcomp;
          for v_level in 1..r_tusrcom.v_level - 1 loop -- gen temp for not secur
              v_codcomp_full := hcm_util.get_codcomp_level(v_codcomp, v_level, '', 'Y');
              v_array(v_codcomp_full) := 'temp';
          end loop;
          for r_tcenter in c_tcenter loop
              v_codcomp_full := r_tcenter.codcomp;
              v_array(v_codcomp_full) := '';
          end loop;
      end loop;
    else   -- not check secur
      for r_tcenter in c_tcenter loop
          v_codcomp_full := r_tcenter.codcomp;
          v_array(v_codcomp_full) := '';
      end loop;
    end if;
    if param_where is not null then
      v_where := ' and ('||param_where||') ';
    end if;

    v_cursor  := dbms_sql.open_cursor;
    v_array_key := v_array.first;

    while v_array_key is not null loop
      v_row := v_row + 1;
      v_codcomp_full := v_array_key;
      v_flgdata := true;
      for r_tcenter2 in c_tcenter2 loop
        v_name_comlevel := get_comp_level_name(r_tcenter2.codcompy, r_tcenter2.comlevel);
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
        if param_where is not null then -- if has where param
          v_stmt := ' select ''Y'' from tcenter where codcomp = '''||v_codcomp_full||''''||v_where;

          dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
          dbms_sql.define_column(v_cursor,1,v_data1,1000);
          v_dummy := dbms_sql.execute(v_cursor);
          v_flgdata := false;
          while (dbms_sql.fetch_rows(v_cursor) > 0) loop
            v_flgdata := true;
          end loop;
        end if;

          if v_flgdata then
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

            v_flgtemp := v_array(v_codcomp_full);
            v_desc_cancel := '';
            if nvl(r_tcenter2.flgact,'1') = '2' then
              v_flgtemp := 'delete';
              v_desc_cancel := ' (cancel)';
            end if;

            obj_row.extend;
            obj_row(obj_row.last) := TYPE_LOV(
                                        '200',' ',
                                        nvl('' , ' '),
                                        nvl(v_comp_split, ' '),
                                        nvl(namcent||v_desc_cancel, ' '),
                                        nvl(to_char(r_tcenter2.comlevel), ' '),
                                        nvl(v_name_comlevel, ' '),
                                        nvl(substr(v_full_comp,1,instr(v_full_comp,'-',1,v_max_comlevel) - 1), ' '),
--                                        nvl(v_codcomp_full, ' '),
                                        nvl(v_flgtemp, ' '),
                                        nvl(r_tcenter2.flgact, ' '),
                                        nvl('', ' '),
                                        nvl('', ' '),
                                        nvl('', ' '),
                                        nvl('', ' '),
                                        nvl('', ' ')
                                     );
          end if;
      end loop;
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

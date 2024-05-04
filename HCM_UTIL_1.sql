--------------------------------------------------------
--  DDL for Package Body HCM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_UTIL" is
-- last update: 17/10/2017 11:11
  function get_current_user(json_str_input in clob) return clob is
    json_obj        json_object_t;
    obj_row         json_object_t;
    p_access_token  varchar2(4000 char);
    param_msg_error varchar2(4000 char);
    json_str_output clob;

    cursor c1 is
      select a.email coduser, a.password codpswd, b.name codempid
        from users a, oauth_access_tokens b
       where a.id = b.user_id
         and b.id = p_access_token;
  begin
    obj_row            := json_object_t();
    json_obj           := json_object_t(json_str_input);
    p_access_token     := hcm_util.get_string_t(json_obj,'p_access_token');
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');

    for r1 in c1 loop
      obj_row.put('coderror', '200');
      obj_row.put('desc_coderror', ' ');
      obj_row.put('p_coduser',r1.coduser);
      obj_row.put('p_codpswd',r1.codpswd);
      obj_row.put('p_codempid',r1.codempid);
    end loop;

    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  function get_year return varchar2 is
  begin
    return to_char(sysdate,'yyyy');
  end get_year;
  --
  function get_tinitial(json_str in clob) return clob is
    json_obj      json_object_t;
    obj_row       json_object_t;
    obj_data      json_object_t;
    param_msg_error varchar2(4000 char);
    json_str_output clob;
    v_total       number := 0;
    v_row         number := 0;

    cursor c1 is
      select *
        from tinitial
    order by codapp, numseq;
  begin
    obj_row     := json_object_t();
    json_obj    := json_object_t(json_str);
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

    for r1 in c1 loop
      v_total := v_total + 1;
    end loop;

    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('total', v_total);
      obj_data.put('codapp',r1.codapp);
      obj_data.put('numseq',r1.numseq);
      obj_data.put('datainit1',r1.datainit1);
      obj_data.put('datainit2',r1.datainit2);
      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;
    return obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  function get_tfolder(json_str in clob) return clob is
    json_obj      json_object_t;
    obj_row       json_object_t;
    obj_data      json_object_t;
    param_msg_error varchar2(4000 char);
    json_str_output clob;
    v_total       number := 0;
    v_row         number := 0;
    v_main        varchar2(1000 char) := get_tsetup_value('PATHFILEPHP');
    v_temp        varchar2(1000 char) := get_tsetup_value('PATHTMPPHP');
    v_load        varchar2(1000 char) := get_tsetup_value('PATHWORKPHP');
    v_emp_folder  varchar2(1000 char) := '';
    v_found       varchar2(1) := 'N';
    cursor c1 is
      select *
        from tfolderd
       where codapp like 'HRES%'
          or codapp like 'HRMS%'
          or codapp like 'HRAL%'
          or codapp like 'HRAP%'
          or codapp like 'HRRP%'
          or codapp like 'HRPM%'
          or codapp like 'HRCO%'
          or codapp like 'HRPY%'
          or codapp like 'HRTR%'
          or codapp like 'HRBF%'
          or codapp like 'HRRC%'
          or codapp like 'HREL%'
          or codapp = 'HRLOGO'
          or codapp = 'PROFILEIMG'
    order by codapp;
  begin
    obj_row := json_object_t();
    json_obj    := json_object_t(json_str);
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');

    begin
      select	folder
      into	v_emp_folder
      from	tfolderd
      where	upper(codapp) = upper('HRPMC2E1');
    exception when no_data_found then
      v_emp_folder := 'Employee_img';
    end;

    for r1 in c1 loop
      v_found := 'Y';
      v_total := v_total + 2;
    end loop;

    obj_data := json_object_t();
    v_row := v_row + 1;
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', ' ');
    obj_data.put('total', v_total);
    obj_data.put('main',v_main);
    obj_data.put('temp',v_temp);
    obj_data.put('load',v_load);
    obj_data.put('codapp','EMP');
    obj_data.put('folder',v_emp_folder);
    obj_row.put(to_char(v_row - 1), obj_data);

    obj_data := json_object_t();
    v_row := v_row + 1;
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', ' ');
    obj_data.put('total', v_total);
    obj_data.put('main',v_main);
    obj_data.put('temp',v_temp);
    obj_data.put('load',v_load);
    obj_data.put('codapp','ANNOUNCE');
    obj_data.put('folder','announcement');
    obj_row.put(to_char(v_row - 1), obj_data);

    for r1 in c1 loop
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('total', v_total);
      obj_data.put('main',v_main);
      obj_data.put('temp',v_temp);
      obj_data.put('load',v_load);
      obj_data.put('codapp',r1.codapp);
      obj_data.put('folder',r1.folder);
      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    if v_found = 'N' then
      obj_data := json_object_t();
      v_row := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('total', '1');
      obj_data.put('main',v_main);
      obj_data.put('temp',v_temp);
      obj_data.put('load',v_load);
      obj_data.put('codapp',' ');
      obj_data.put('folder',' ');
      obj_row.put(to_char(v_row - 1), obj_data);
    end if;

    return obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  --
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;
  --
  function get_label(json_str in clob) return clob as
    json_str_output clob;
    json_obj        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    p_codapp        varchar2(100 char);
    p_codlang       varchar2(100 char);
    v_label         varchar2(5000 char);
    v_rcnt          number := 0;

    cursor c_tapplscr is
    select  codapp,numseq,desclabele,desclabelt,desclabel3,desclabel4,desclabel5
      from  tapplscr
     where  lower(codapp) like lower(p_codapp||'%')
     order by  codapp,numseq;
  begin
    json_obj              := json_object_t(json_str);
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
    p_codapp              := hcm_util.get_string_t(json_obj,'p_codapp');
    p_codlang             := hcm_util.get_string_t(json_obj,'p_codlang');

    obj_row := json_object_t();
    for r1 in c_tapplscr loop
      if p_codlang = '101' then
        v_label := r1.desclabele;
      elsif p_codlang = '102' then
        v_label := r1.desclabelt;
      elsif p_codlang = '103' then
        v_label := r1.desclabel3;
      elsif p_codlang = '104' then
        v_label := r1.desclabel4;
      elsif p_codlang = '105' then
        v_label := r1.desclabel5;
      else
        v_label := r1.desclabele;
      end if;
      --
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('codapp', r1.codapp);
      obj_data.put('numseq', to_char(r1.numseq));
      obj_data.put('desclabelt', v_label);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_label;
  --
  function get_coddesc(json_str in clob) return clob as
    json_str_output clob;
    json_obj        json_object_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    p_table         varchar2(1000 char);
    p_colcode       varchar2(5000 char);
    p_coldesc       varchar2(5000 char);
    p_where         varchar2(4000 char);
    v_where         varchar2(4000 char) := '';
    v_where_flgactive varchar2(4000 char) := '';
    v_chk             number;

    v_col           varchar2(1000 char);
    v_cursor			  number;
		v_dummy         integer;
		v_stmt			    varchar2(5000 char);
    v_colcode       varchar2(5000 char);
    v_coldesc       varchar2(5000 char);
    v_rcnt          number := 0;

  begin
    json_obj              := json_object_t(json_str);
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
    p_table               := hcm_util.get_string_t(json_obj,'p_table');
    p_colcode             := hcm_util.get_string_t(json_obj,'p_colcode');
    p_coldesc             := hcm_util.get_string_t(json_obj,'p_coldesc');
    p_where               := hcm_util.get_string_t(json_obj,'p_where');

    obj_row := json_object_t();
    if p_table = 'tyrtrsch' then
      v_col := p_coldesc;
    else
      if global_v_lang = '101' then
        v_col   := p_coldesc||'e';
      elsif global_v_lang = '102' then
        v_col   := p_coldesc||'t';
      elsif global_v_lang = '103' then
        v_col   := p_coldesc||'3';
      elsif global_v_lang = '104' then
        v_col   := p_coldesc||'4';
      elsif global_v_lang = '105' then
        v_col   := p_coldesc||'5';
      else
        v_col   := p_coldesc||'e';
      end if;
    end if;

    --<< user4 || 30/08/2019 || check flgactive is 1
    begin
      select count(*)
        into v_chk
        from user_tab_columns
       where table_name  = upper(p_table)
         and column_name = upper('FLGACT');
    exception when others then
      v_where_flgactive := ' 1 = 1 '; -- default when no condition
    end;
    if v_chk > 0 then
      v_where_flgactive := 'nvl(flgact,''1'') in (''Y'',''1'')';
    else
      v_where_flgactive := ' 1 = 1 '; -- default when no condition
    end if;
    -->> user4 || 30/08/2019 || check flgactive is 1

    if p_where is not null then
      if p_table = 'temploy1' then
        p_where := replace(p_where,p_coldesc,v_col);
      end if;
      v_where := ' where '||p_where||' and '||v_where_flgactive;  -- user4 || 30/08/2019 || check flgactive is 1 || v_where := ' where '||p_where;
    end if;

    v_stmt := 'select '||p_colcode||','||v_col||' from '||p_table||v_where||' order by '||p_colcode;

    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
    dbms_sql.define_column(v_cursor,1,v_colcode,1000);
    dbms_sql.define_column(v_cursor,2,v_coldesc,1000);
    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      dbms_sql.column_value(v_cursor,1,v_colcode);
      dbms_sql.column_value(v_cursor,2,v_coldesc);
      v_rcnt := v_rcnt + 1;
      obj_data := json_object_t();
      obj_data.put('code', v_colcode);
      obj_data.put('description', v_coldesc);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop; -- end while

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_coddesc;
  --
  function file_exists(p_filepath in varchar2) return boolean is
    v_res clob;
  begin
    v_res := httpuritype(p_filepath).getclob();
    return true;
  exception when others then
    return false;
  end;
  --
  --find codincome
  procedure  get_cod_income		(	 p_codcompy  in varchar2 ,
                                 p_codempmt  in varchar2 ,
                                 p_codincom1 out varchar2,
                                 p_codincom2 out varchar2,
                                 p_codincom3 out varchar2,
                                 p_codincom4 out varchar2,
                                 p_codincom5 out varchar2,
                                 p_codincom6 out varchar2,
                                 p_codincom7 out varchar2,
                                 p_codincom8 out varchar2,
                                 p_codincom9 out varchar2,
                                 p_codincom10 out varchar2,
                                 p_unitcal1		out varchar2,
                                 p_unitcal2   out varchar2,
                                 p_unitcal3   out varchar2,
                                 p_unitcal4   out varchar2,
                                 p_unitcal5   out varchar2,
                                 p_unitcal6   out varchar2,
                                 p_unitcal7   out varchar2,
                                 p_unitcal8   out varchar2,
                                 p_unitcal9   out varchar2,
                                 p_unitcal10  out varchar2) IS
   v_dteeffec1 date;
   v_dteeffec2 date;

  BEGIN
    begin
        select codincom1,codincom2,codincom3,codincom4,codincom5,
               codincom6,codincom7,codincom8,codincom9,codincom10
        into   p_codincom1,p_codincom2,p_codincom3,p_codincom4,p_codincom5,
               p_codincom6,p_codincom7,p_codincom8,p_codincom9,p_codincom10
        from  tcontpms
        where dteeffec in (select max(dteeffec)
                           from tcontpms
                           where dteeffec <= sysdate
                           and codcompy = p_codcompy)
          and codcompy = p_codcompy;
    exception when no_data_found then
      null ;
    end;
    begin
        select unitcal1,unitcal2,unitcal3,unitcal4,unitcal5,
               unitcal6,unitcal7,unitcal8,unitcal9,unitcal10
        into   p_unitcal1,p_unitcal2,p_unitcal3,p_unitcal4,p_unitcal5,
               p_unitcal6,p_unitcal7,p_unitcal8,p_unitcal9,p_unitcal10
        from   tcontpmd
        where  codcompy = p_codcompy
        and    codempmt = p_codempmt
        and    dteeffec = (select max(dteeffec)
                            from   tcontpmd
                            where  codcompy  = p_codcompy
                            and    codempmt = p_codempmt
                            and    dteeffec <= sysdate);
    exception when no_data_found then
      null ;
    end;
    if p_codincom1 is null then
       p_unitcal1  := null ;
    end if;
    if p_codincom2 is null then
       p_unitcal2  := null ;
    end if;
    if p_codincom3 is null then
       p_unitcal3  := null ;
    end if;
    if p_codincom4 is null then
       p_unitcal4  := null ;
    end if;
    if p_codincom5 is null then
       p_unitcal5  := null ;
    end if;
    if p_codincom6 is null then
       p_unitcal6  := null ;
    end if;
    if p_codincom7 is null then
       p_unitcal7  := null ;
    end if;
    if p_codincom8 is null then
       p_unitcal8   := null ;
    end if;
    if p_codincom9 is null then
       p_unitcal9  := null ;
    end if;
    if p_codincom10 is null then
       p_unitcal10  := null ;
    end if;

  END get_cod_income;
  --find detail codincome
  procedure get_income (p_lang in varchar2, p_codincom in out varchar2,p_detail  out varchar2) IS
    cursor curr1 is
                select descpaye,descpayt,descpay3,descpay4,descpay5
                from   tinexinf
                where  codpay = p_codincom
                and rownum <= 1;
  BEGIN
    for i in curr1 loop
      if p_lang = '101' then
        p_detail:= i.DESCPAYE;
      elsif p_lang = '102' then
        p_detail := i.DESCPAYT;
      elsif p_lang = '103' then
        p_detail := i.DESCPAY3;
      elsif p_lang = '104' then
        p_detail := i.DESCPAY4;
      elsif p_lang = '105' then
        p_detail := i.DESCPAY5;
      end if;
    end loop ;
  end;

  function get_list_values(json_str_input clob) return clob is
    json_obj        json_object_t;
    v_codapp        varchar2(100 char);
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_codapp     json_object_t;
    json_str_output clob;
    v_rcnt          number := 0;
    v_codcompy      tcompny.codcompy%type;

    cursor c_tlistval is
    select codapp, codlang, numseq, desc_label, list_value, flgused
      from tlistval
     where lower(codapp)  = lower(v_codapp)
       and numseq         > 0
       and nvl(flgused,'Y') = 'Y'
  order by codlang, numseq;

    cursor c_tsetcomp is
      select sc.numseq, cc.namcente, cc.namcentt, cc.namcent3, cc.namcent4, cc.namcent5
        from tsetcomp sc, tcompnyc cc
       where sc.numseq        = cc.comlevel(+)
         and cc.codcompy(+)   = v_codcompy
         and nvl(sc.qtycode,0) > 0
      order by sc.numseq;

  begin
    json_obj      := json_object_t(json_str_input);
    json_codapp   := json_object_t(hcm_util.get_string_t(json_obj, 'p_codapp'));
    v_codcompy    := hcm_util.get_codcomp_level(hcm_util.get_string_t(json_obj,'p_codcomp'),1);
    
    obj_row       := json_object_t();
    for i in 0..json_codapp.get_size-1 loop
      v_codapp    := lower(hcm_util.get_string_t(json_codapp, to_char(i)));
      --
      if upper(v_codapp) = 'TYPREPORT' then
        for r1 in c_tsetcomp loop
          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', '101');
          obj_data.put('value', r1.numseq);
          if r1.numseq = 1 then
            obj_data.put('label', get_label_name('SCRLABEL','101',2250));
          else
            obj_data.put('label', nvl(r1.namcente,get_label_name('SCRLABEL','101',2490)||to_char(r1.numseq)));
          end if;

          obj_row.put(to_char(v_rcnt -1), obj_data);

          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', '102');
          obj_data.put('value', r1.numseq);
          if r1.numseq = 1 then
            obj_data.put('label', get_label_name('SCRLABEL','102',2250));
          else
            obj_data.put('label', nvl(r1.namcentt,get_label_name('SCRLABEL','102',2490)||to_char(r1.numseq)));
          end if;
          obj_row.put(to_char(v_rcnt -1), obj_data);

          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', '103');
          obj_data.put('value', r1.numseq);
          if r1.numseq = 1 then
            obj_data.put('label', get_label_name('SCRLABEL','103',2250));
          else
            obj_data.put('label', nvl(r1.namcent3,get_label_name('SCRLABEL','103',2490)||to_char(r1.numseq)));
          end if;

          obj_row.put(to_char(v_rcnt -1), obj_data);

          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', '104');
          obj_data.put('value', r1.numseq);
          if r1.numseq = 1 then
            obj_data.put('label', get_label_name('SCRLABEL','104',2250));
          else
            obj_data.put('label', nvl(r1.namcent4,get_label_name('SCRLABEL','104',2490)||to_char(r1.numseq)));
          end if;

          obj_row.put(to_char(v_rcnt -1), obj_data);

          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', '105');
          obj_data.put('value', r1.numseq);
          if r1.numseq = 1 then
            obj_data.put('label', get_label_name('SCRLABEL','105',2250));
          else
            obj_data.put('label', nvl(r1.namcent5,get_label_name('SCRLABEL','105',2490)||to_char(r1.numseq)));
          end if;

          obj_row.put(to_char(v_rcnt -1), obj_data);
        end loop;
      else
        begin
          update tlistval
            set flg_call = 'Y'
          where codapp = upper(v_codapp);
        exception when others then null;
        end;
        --
        for r1 in c_tlistval loop
          v_rcnt                := v_rcnt + 1;
          obj_data              := json_object_t();
          obj_data.put('codapp', v_codapp);
          obj_data.put('codlang', r1.codlang);
          obj_data.put('value', r1.list_value);
          obj_data.put('label', r1.desc_label);

          obj_row.put(to_char(v_rcnt -1), obj_data);
        end loop;
      end if;
    end loop;

    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end get_list_values;

  procedure get_listfields(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    json_obj        json_object_t;
  begin
    json_obj    := json_object_t(json_str_input);
    global_v_lang      := hcm_util.get_string_t(json_obj,'p_lang');
    json_str_output := gen_listfields(json_str_input);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  function gen_listfields(json_str_input in clob) return clob is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_obj        json_object_t;

    v_codapps       varchar2(1000 char);
    v_langs         varchar2(1000 char);
    p_lang          varchar2(1000 char);

    json_str_output clob;

    v_row           number := 0;
    cursor c1 is
      select  namtbl||'.'||namfld as namfld,
              decode(v_langs,'101',nambrowe
                            ,'102',nambrowt
                            ,'103',nambrow3
                            ,'104',nambrow4
                            ,'105',nambrow5) as nambrowe,
              lower(datatype) as datatype,
              decode(funcdesc,null,'input','lov') as input -- weerayut 20180104
      from    treport2
      where   instr(v_codapps,codapp) > 0
      order by numseq;
  begin
    json_obj        := json_object_t(json_str_input);
    p_lang          := hcm_util.get_string_t(json_obj,'p_lang');
    v_codapps       := hcm_util.get_string_t(json_obj,'p_codapps');
    v_langs         := hcm_util.get_string_t(json_obj,'p_codlangs');

    if v_codapps is null then
      param_msg_error := get_response_message(null,'HR2045',p_lang);
    end if;

    if param_msg_error is null then
      obj_row         := json_object_t();
      obj_data        := json_object_t();
      for i in c1 loop
        obj_data    := json_object_t();
        v_row := v_row + 1;
        obj_data.put('code', i.namfld);
        obj_data.put('description',i.nambrowe);
        obj_data.put('type',i.datatype);
        obj_data.put('input',i.input);
        obj_row.put(v_row - 1, obj_data);
      end loop;

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,p_lang);
    end if;

    return json_str_output;
  end;

  function get_string(obj json, json_key varchar2) return varchar2 is
  begin
    return to_char(nvl(json_ext.get_string(obj, json_key), json_ext.get_number(obj, json_key)));
  end;

  function get_json(obj json, json_key varchar2) return json is
  begin
    begin
      return json(obj.get(json_key));
    exception when others then
      return json();
    end;
  end;

  function get_string_t(obj json_object_t, json_key varchar2) return varchar2 is
  begin
    return to_char(obj.get_string(json_key));
  end;

  function get_number_t(obj json_object_t, json_key varchar2) return number is
  begin
    return obj.get_number(json_key);
  end;

  function get_clob_t(obj json_object_t, json_key varchar2) return clob is
  begin
    return to_clob(obj.get_clob(json_key));
  end;

  function get_json_t(obj json_object_t, json_key varchar2) return json_object_t is
  begin
    begin
      return nvl(obj.get_object(json_key), json_object_t());
    exception when others then
      return json_object_t();
    end;
  end;

  function get_array_t(obj json_object_t, json_key varchar2) return json_array_t is
  begin
    return nvl(obj.get_array(json_key), json_array_t());
  end;

  function get_boolean_t(obj json_object_t, json_key varchar2) return boolean is
  begin
    return obj.get_boolean(json_key);
  end;

  function translate_logical (v_code varchar2,v_codapp varchar2,v_lang varchar2) return varchar2 as
    v_syncond        varchar2(4000 char);
    v_new_syncond    varchar2(4000 char);
    v_replace_num    varchar2(4000 char);
    v_regexp         varchar2(4000 char) := 'to_number\(''[0-9][0-9]{0,}''\)'; -- regex detect start with to_number(' until end with ')
    cursor c_replace is
      select regexp_substr(v_syncond,v_regexp) replace_char
        from dual;
  begin
    v_syncond     := get_logical_name(v_codapp,v_code,v_lang);
    v_new_syncond := v_syncond;
    for r_replace in c_replace loop -- replace exp. to_number('1') to 1
      -- find char number
      v_replace_num := replace(r_replace.replace_char,'to_number(''','');
      v_replace_num := replace(v_replace_num,''')','');
      -- replace
      v_new_syncond := replace(v_new_syncond,r_replace.replace_char,v_replace_num);
    end loop;
    return v_new_syncond;
  end;

  function translate_statement (v_statement json_object_t,v_codapp varchar2,v_lang varchar2) return json_object_t as
  	v_json              json_object_t;
    v_new_json          json_object_t := json_object_t();
  	v_statement_new     json_object_t;
  	v_codeStmt          varchar2(4000 char);
    v_translate_statement json_object_t;
  begin
    for v_count in 0..v_statement.get_size-1 loop
      v_json := hcm_util.get_json_t(v_statement,to_char(v_count));
      -- translate code to desc
      v_codeStmt      := hcm_util.get_string_t(v_json,'codeStmt');
      if v_codeStmt is not null then
        v_json.put('descStmt',translate_logical (v_codeStmt,v_codapp,v_lang));
      end if;
      v_statement_new := hcm_util.get_json_t(v_json,'statement');
      if v_statement_new is not null then
        v_translate_statement := translate_statement(v_statement_new,v_codapp,v_lang);
        if v_translate_statement.get_size > 0 then
          v_json.put('statement',v_translate_statement);
        end if;
      end if;
      v_new_json.put(to_char(v_count),v_json);
    end loop;
  	return v_new_json;
  end;

  procedure get_logical_description (json_str_input in clob, json_str_output out clob) is
    obj_json         json_object_t := json_object_t(json_str_input);
    obj_data         json_object_t := json_object_t();
    v_lang           varchar2(4000 char);
    v_codapp         treport2.codapp%type;
    v_syncond        varchar2(4000 char);
    v_statement      json_object_t;
  begin
    v_syncond     := hcm_util.get_string_t(obj_json,'syncond');
    v_lang        := hcm_util.get_string_t(obj_json,'p_lang');
    v_codapp      := hcm_util.get_string_t(obj_json,'codapp');
--  	v_statement   := get_json_t(obj_json,'statement');
  	v_statement   := hcm_util.get_json_t(obj_json,'statement');
    obj_data.put('description',translate_logical(v_syncond,v_codapp,v_lang)); -- hcm_util
    obj_data.put('statement',translate_statement(v_statement,v_codapp,v_lang));
    obj_data.put('coderror'   ,'200');

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_logical_list_values (json_str_input in clob, json_str_output out clob) is
    v_row             number := 0;
    p_codapp          varchar2(1000 char);
    json_obj          json_object_t;
    obj_row           json_object_t;
    obj_data          json_object_t;
    cursor c1 is
      select namfld,namtbl,nambrowe,nambrowt,nambrow3,nambrow4,nambrow5,datatype,
             decode(funcdesc,null, 'input', decode(instr(lower(funcdesc), 'get_tlistval_name'), '0', 'lov', 'dropdown')) as inputtype,
             decode(funcdesc,null, '', decode(instr(lower(funcdesc), 'get_tlistval_name'), '0', fldsrh, substr(replace(lower(funcdesc), 'get_tlistval_name('''), 0, instr(replace(lower(funcdesc), 'get_tlistval_name('''), '''') - 1))) field
        from treport2
       where codapp = upper(p_codapp)
    order by numseq;
    cursor c2 is
      select namfld,namtbl,nambrowe,nambrowt,nambrow3,nambrow4,nambrow5,datatype,
             decode(funcdesc,null, 'input', decode(instr(lower(funcdesc), 'get_tlistval_name'), '0', 'lov', 'dropdown')) as inputtype,
             decode(funcdesc,null, '', decode(instr(lower(funcdesc), 'get_tlistval_name'), '0', fldsrh, substr(replace(lower(funcdesc), 'get_tlistval_name('''), 0, instr(replace(lower(funcdesc), 'get_tlistval_name('''), '''') - 1))) field
        from treportq
       where codapp = upper(p_codapp)
    order by numseq;
  begin
    obj_row     := json_object_t();
    json_obj    := json_object_t(json_str_input);
    p_codapp    := hcm_util.get_string_t(json_obj,'p_codapp');
    if upper(p_codapp) like 'QY%' then
      for r2 in c2 loop
        v_row    := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('namfld', r2.namtbl || '.' || r2.namfld);
        obj_data.put('nambrowe', r2.nambrowe);
        obj_data.put('nambrowt', r2.nambrowt);
        obj_data.put('nambrow3', r2.nambrow3);
        obj_data.put('nambrow4', r2.nambrow4);
        obj_data.put('nambrow5', r2.nambrow5);
        obj_data.put('datatype', r2.datatype);
        obj_data.put('inputtype', r2.inputtype);
        obj_data.put('field', r2.field);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      for r1 in c1 loop
        v_row    := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('namfld', r1.namtbl || '.' || r1.namfld);
        obj_data.put('nambrowe', r1.nambrowe);
        obj_data.put('nambrowt', r1.nambrowt);
        obj_data.put('nambrow3', r1.nambrow3);
        obj_data.put('nambrow4', r1.nambrow4);
        obj_data.put('nambrow5', r1.nambrow5);
        obj_data.put('datatype', r1.datatype);
        obj_data.put('inputtype', r1.inputtype);
        obj_data.put('field', r1.field);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_codapp_list (json_str_input in clob, json_str_output out clob) is
    v_row             number := 0;
    p_codapp          varchar2(1000 char);
--    json_obj          json_object_t;
    obj_row           json_object_t;
    obj_data          json_object_t;
    cursor c1 is
      select codapp
        from treport2
      union
      select codapp
        from treportq
      order by codapp;
  begin
    obj_row     := json_object_t();
--    json_obj    := json_object_t(json_str_input);
--    p_codapp    := hcm_util.get_string_t(json_obj,'p_codapp');
--    if upper(p_codapp) like 'QY%' then
--      for r2 in c2 loop
--        v_row    := v_row+1;
--        obj_data := json_object_t();
--        obj_data.put('coderror', '200');
--        obj_data.put('codapp', r2.codapp);
--
--        obj_row.put(to_char(v_row-1),obj_data);
--      end loop;
--    else
    for r1 in c1 loop
      v_row    := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
--    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_imageurl (json_str_input in clob,json_str_output out clob) is
      json_obj		json_object_t;
      json_param	json_object_t;
      json_obj2		json_object_t;
      json_row 		json_object_t;
      v_codempid	varchar2(400 char);
      v_codapp  	varchar2(400 char);
      v_count       number := 0;
  begin
      json_obj 	:= json_object_t(json_str_input);
      v_codempid 	:= hcm_util.get_string_t(json_obj,'p_codempid_query');
      if hcm_util.get_string_t(json_obj,'param_json') is not null then
        json_param    := json_object_t(hcm_util.get_string_t(json_obj,'param_json'));
      end if;
      v_codapp  	:= hcm_util.get_string_t(json_obj,'p_codapp');
      if v_codempid is null and json_param is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteend');
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          return;
      end if;
      if v_codapp is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteend');
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
          return;
      end if;

      json_obj2	:= json_object_t();
      if v_codempid is not null then
          json_obj2.put('image',get_emp_img(v_codempid));
        json_obj2.put('coderror','200');
      else
        for i in 0..(json_param.get_size-1) loop
            v_codempid := hcm_util.get_string_t(json_param,to_char(i));
            json_row := json_object_t();
            json_row.put('image',get_emp_img(v_codempid));
            json_row.put('coderror','200');
            json_obj2.put(to_char(i),json_row);
        end loop;
      end if;
      json_str_output := json_obj2.to_clob;
  end;
  --
  function get_codcomp_level (p_codcomp varchar2,p_level number,p_concat varchar2 default '',p_fulldisp varchar2 default '') return varchar2 as --p_fulldisp='Y'
    v_codcomp         varchar2(4000 char);
    v_codcomp_ret     varchar2(4000 char);
    v_concat          varchar2(1000 char) := '';
    v_least_comlevel  number := 0;
    v_max_comlevel    number := 0;
    v_sub_start       number := 1;
    TYPE t_qtycode IS TABLE OF tsetcomp.qtycode%type INDEX BY BINARY_INTEGER;
    v_qtycode         t_qtycode;
    v_max_qty         tsetcomp.qtycode%type;
    v_qtycode2         number := 0;
  begin
    v_codcomp := replace(p_codcomp,'-');

    if p_level = 1 and p_concat is null and p_fulldisp is null then
        begin
            select qtycode
            into v_qtycode2
            from tsetcomp
            where numseq = 1;
        exception when others then
            v_qtycode2 :=0;
        end;
          v_codcomp_ret := substr(v_codcomp,v_sub_start,v_qtycode2);
        return v_codcomp_ret;
    end if;

    for i in 1..10 loop
      v_qtycode(i) := 0;
    end loop;

    begin
      select max(numseq) into v_max_comlevel
        from tsetcomp;
    end;
    v_max_comlevel := nvl(v_max_comlevel,0);

    begin
      select sum(qtycode) into v_max_qty
        from tsetcomp
       where numseq <= 10;
    exception when others then null;
    end;

    if p_level is not null then
      v_least_comlevel  := least(v_max_comlevel, nvl(p_level,10));
    else
      begin
          select  comlevel
          into    v_least_comlevel
          from    tcenter
          where   rpad(codcomp,v_max_qty,'0') = rpad(v_codcomp,v_max_qty,'0')
          and     comlevel  <> 0;
      exception when others then null;
      end;
    end if;
    v_least_comlevel := nvl(v_least_comlevel,0);

    begin
      select
        max(decode(numseq,1,qtycode)) as l1,
        max(decode(numseq,2,qtycode)) as l2,
        max(decode(numseq,3,qtycode)) as l3,
        max(decode(numseq,4,qtycode)) as l4,
        max(decode(numseq,5,qtycode)) as l5,
        max(decode(numseq,6,qtycode)) as l6,
        max(decode(numseq,7,qtycode)) as l7,
        max(decode(numseq,8,qtycode)) as l8,
        max(decode(numseq,9,qtycode)) as l9,
        max(decode(numseq,10,qtycode)) as l10
      into
        v_qtycode(1),v_qtycode(2),v_qtycode(3),v_qtycode(4),v_qtycode(5),
        v_qtycode(6),v_qtycode(7),v_qtycode(8),v_qtycode(9),v_qtycode(10)
      from tsetcomp;
    end;

    for v_level in 1..v_least_comlevel loop
      if v_sub_start <= length(v_codcomp) then
        v_codcomp_ret   := v_codcomp_ret||v_concat||substr(v_codcomp,v_sub_start,v_qtycode(v_level));
        v_sub_start     := v_sub_start + v_qtycode(v_level);
      end if;
      v_concat  := p_concat;
    end loop;
    if p_fulldisp = 'Y' and (v_max_comlevel - v_least_comlevel) > 0 then
      v_codcomp   := rpad(replace(v_codcomp_ret,p_concat,''),v_max_qty,'0');
      for v_level in (v_least_comlevel + 1)..v_max_comlevel loop
        if v_sub_start <= length(v_codcomp) then
          v_codcomp_ret   := v_codcomp_ret||v_concat||substr(v_codcomp,v_sub_start,v_qtycode(v_level));
          v_sub_start     := v_sub_start + v_qtycode(v_level);
        end if;
      end loop;
    end if;
    return v_codcomp_ret;
  end; -- end get_codcomp_level

  function get_level_from_codcomp (p_codcomp varchar2, flg_ignore_zero varchar2 default 'N') return number is
      v_codcomp       varchar2(100 char);
      v_codcomp_tmp   varchar2(100 char);
      v_codcompy      varchar2(10 char);
      cursor c_tsetcomp is
        select numseq, qtycode
          from tsetcomp
      order by numseq;
      v_sum_qtycode number := 0;

      v_codcomp_length number;
  begin
      v_codcomp     := p_codcomp;
      v_codcomp_tmp := v_codcomp;
      if flg_ignore_zero = 'Y' then
        for i in 1..length(v_codcomp_tmp) loop
          if substr(v_codcomp_tmp, -1) <> '0' then
            v_codcomp := v_codcomp_tmp;
            exit;
          end if;
          v_codcomp_tmp := substr(v_codcomp_tmp, 1, length(v_codcomp_tmp) - 1);
        end loop;
      end if;

      v_codcomp_length := length(v_codcomp);

      v_codcompy := hcm_util.get_codcomp_level(v_codcomp, 1);
      for r_tsetcomp in c_tsetcomp loop
          v_sum_qtycode   := v_sum_qtycode + r_tsetcomp.qtycode;
          if v_sum_qtycode >= v_codcomp_length then
              return r_tsetcomp.numseq;
          end if;
      end loop;
      return 0;
  end;

--  function get_codcomp_level (p_codcomp varchar2,p_level number) return varchar2 as
--    v_codcomp	varchar2(40 char);
--    v_qtycode	number;
--    v_level     number;
--  begin
--    v_codcomp := replace(p_codcomp,'-');
--    if p_level is not null then
--        v_level := p_level;
--    else
--        begin
--          select sum(qtycode) into v_qtycode
--            from tsetcomp
--           where numseq <= 10;
--        exception when others then null;
--        end;
--        begin
--            select  comlevel
--            into    v_level
--            from    tcenter
--            where   rpad(codcomp,v_qtycode,'0') = rpad(v_codcomp,v_qtycode,'0');
--        exception when others then null;
--        end;
--    end if;
--    begin
--      select sum(qtycode) into v_qtycode
--        from tsetcomp
--       where numseq <= v_level;
--    exception when others then null;
--    end;
--    return substr(v_codcomp,1,v_qtycode);
--  end;

--  function get_codcomp_level2 (p_codcomp varchar2, p_level number) return varchar2 is
--    v_codcomp	      varchar2(40 char) := replace(p_codcomp,'-');
--    v_sum_qtycode_prev	number;
--    v_qtycode	      number;
--    v_level_prev    number := p_level - 1;
--    v_level         number := p_level;
--  begin
--    if v_level_prev <= 0 then
--      v_sum_qtycode_prev := 0;
--    else
--      begin
--        select sum(qtycode) into v_sum_qtycode_prev
--          from tsetcomp
--         where numseq = v_level_prev;
--      exception when others then null;
--      end;
--    end if;
--
--    begin
--      select qtycode into v_qtycode
--        from tsetcomp
--       where numseq <= v_level;
--    exception when others then null;
--    end;
--    begin
--        select  codcomp
--        into    v_codcomp
--        from    tcenter
--        where   codcomp = v_codcomp;
--    exception when others then null;
--    end;
--    return substr(v_codcomp, v_sum_qtycode_prev, v_qtycode);
--  end;
  function get_qtyavgwk(p_codcomp varchar2,p_codempid varchar2) return number as
    v_qtyavgwk number;
  begin
    if p_codcomp is not null then
      begin
        select t1.qtyavgwk
	        into v_qtyavgwk
	        from tcontral t1
	       where t1.codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
	         and t1.dteeffec = (select max(dteeffec)
                                from tcontral t3
           	                   where t3.codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
	                               and t3.dteeffec <= sysdate);
      exception when no_data_found then null;
      end;
    elsif p_codempid is not null then
      begin
        select t1.qtyavgwk
	        into v_qtyavgwk
	        from tcontral t1, temploy1 t2
	       where t2.codempid = p_codempid
           and t1.codcompy = hcm_util.get_codcomp_level(t2.codcomp,1)
	         and t1.dteeffec = (select max(dteeffec)
                                from tcontral t3
           	                   where t3.codcompy = hcm_util.get_codcomp_level(t2.codcomp,1)
	                               and t3.dteeffec <= sysdate);
      exception when no_data_found then null;
      end;
    end if;
    return nvl(v_qtyavgwk,480);
  end;

  function get_temploy_field(p_codempid varchar2, p_field varchar2) return varchar2 is
    l_theCursor       integer default dbms_sql.open_cursor;
    l_columnValue     varchar2(4000);
    l_status          integer;
    l_descTbl         dbms_sql.desc_tab;
    l_colCnt          number;

    v_query           clob := 'select ' || p_field || ' from temploy1 where codempid =  ''' || p_codempid || '''';
  begin
    dbms_sql.parse(l_theCursor,v_query,dbms_sql.native);
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl);

    for i in 1 .. l_colCnt loop
      dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
    end loop;

    l_status := dbms_sql.execute(l_theCursor);
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
      for i in 1 .. l_colCnt loop
        dbms_sql.column_value( l_theCursor, i, l_columnValue );
      end loop;
    end loop;
    dbms_sql.close_cursor( l_theCursor );
    return l_columnValue;
  exception when others then dbms_sql.close_cursor( l_theCursor ); RAISE;
  end;

  function get_temphead_codempid(p_codempidh varchar2, p_prefix_emp varchar2 default null) return clob is
    r_codempid  clob;

    v_codempidh varchar2(10 char) := p_codempidh;
    v_codcomph  varchar2(100 char);
    v_codposh   varchar2(4 char);
    v_count     number;
    v_codcomp   varchar2(100 char);
    v_codpos    varchar2(4 char);
    v_concat    varchar2(1 char) := '';

    cursor c_temphead1 is
      select replace(codempid,'%',null) codempid,
             replace(codcomp,'%',null) codcomp,
             replace(codpos,'%',null) codpos
        from temphead
       where codempidh = v_codempidh;

    cursor c_temphead2 is
      select replace(codempid,'%',null) codempid,
             replace(codcomp,'%',null) codcomp,
             replace(codpos,'%',null) codpos
        from temphead
       where codcomph = v_codcomph
         and codposh = v_codposh;

    cursor c_temploy1 is
      select codempid
        from temploy1
       where codcomp = v_codcomp
         and codpos = v_codpos;

    cursor c_temploy1_tsecpos is
      select codcomp, codpos
        from temploy1
       where codempid = v_codempidh
         and staemp in ('1','3')
      union
      select codcomp, codpos
        from tsecpos
       where codempid = v_codempidh
         and dteeffec <= SYSDATE
         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null);
  begin

    begin
      select count(*) into v_count
        from temphead
       where codempidh = v_codempidh;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count > 0 then
      for r_temphead1 in c_temphead1 loop
        if r_temphead1.codempid is not null then
          r_codempid := r_codempid || v_concat || p_prefix_emp || r_temphead1.codempid;
          v_concat := ',';
        else
          v_codcomp := r_temphead1.codcomp;
          v_codpos := r_temphead1.codpos;
          for r_temploy1 in c_temploy1 loop
            r_codempid := r_codempid || v_concat || p_prefix_emp || r_temploy1.codempid;
            v_concat := ',';
          end loop;
        end if;
      end loop;
    else
      for r_temptsec in c_temploy1_tsecpos loop
        v_codcomph := r_temptsec.codcomp;
        v_codposh := r_temptsec.codpos;
        for r_temphead2 in c_temphead2 loop
          if r_temphead2.codempid is not null then
            r_codempid := r_codempid || v_concat || p_prefix_emp || r_temphead2.codempid;
            v_concat := ',';
          else
            v_codcomp := r_temphead2.codcomp;
            v_codpos := r_temphead2.codpos;
            for r_temploy1 in c_temploy1 loop
              r_codempid := r_codempid || v_concat || p_prefix_emp || r_temploy1.codempid;
              v_concat := ',';
            end loop;
          end if;
        end loop;
      end loop;
    end if;

    return r_codempid;
  end;

  function count_temphead_codempid(p_codempidh varchar2) return number is
    r_count     number;
  begin
    r_count := REGEXP_COUNT(get_temphead_codempid(p_codempidh), ',', 1, 'i') + 1;
    return r_count;
  end;

  procedure	cal_dhm_hm (p_day in number,p_hr in number,p_min in number,p_qtyavhwk in number,p_type in varchar2,o_day out number,o_hr out number,o_min out number,o_dhm out varchar) as
  	v_min	number;
  	v_day   number;
  	v_hr	number;
    v_token varchar2(1 char);
  begin
    if p_qtyavhwk is null or p_qtyavhwk = 0 then
        v_min := (nvl(p_hr,0)*60) + nvl(p_min,0);
    else
        v_min := round((nvl(p_day,0)*p_qtyavhwk) + (nvl(p_hr,0)*60) + nvl(p_min,0));
    end if;
    if v_min < 0 then
        v_token := '-';
    else
        v_token := '';
    end if;
  	if p_type = '1' then -- type 1 return +-d:hh:mm
        if p_qtyavhwk is null or p_qtyavhwk = 0 then
            o_day := 0;
            o_hr  := 0;
            o_min := 0;
            o_dhm := '0:00:00';
            return;
        end if;
  		v_day := trunc(v_min/p_qtyavhwk);
  		v_min := v_min - v_day*p_qtyavhwk;
  		v_hr  := trunc(v_min/60);
  		v_min := round(v_min - (v_hr*60));-- User37 Final Test Phase 1 V11 #2921 26/10/2020 v_min - (v_hr*60);
  		o_day := v_day;
  		o_hr  := v_hr;
  		o_min := v_min;
--  		o_dhm := v_token || lpad(to_char(abs(o_day)),2,'0') || ':' || lpad(to_char(abs(o_hr)),2,'0') || ':' || lpad(to_char(abs(o_min)),2,'0');
        --<<User37 Final Test Phase 1 V11 #1569 26/10/2020
        --o_dhm := v_token || to_char(abs(o_day)) || ':' || lpad(to_char(abs(o_hr)),2,'0') || ':' || lpad(to_char(abs(o_min)),2,'0');
        o_dhm := v_token || to_char(abs(o_day),'fm999,990') || ':' || lpad(to_char(abs(o_hr)),2,'0') || ':' || lpad(to_char(abs(o_min)),2,'0');
        -->>User37 Final Test Phase 1 V11 #1569 26/10/2020
  	else                -- type 2 or other return +-hh:mm
  		v_hr  := trunc(v_min/60);
  		v_min := v_min - (v_hr*60);
  		o_day := 0;
  		o_hr  := v_hr;
  		o_min := trunc(v_min);
        --<<User37 Final Test Phase 1 V11 #1569 26/10/2020
  		--o_dhm := v_token || to_char(abs(o_hr)) || ':' || lpad(to_char(abs(o_min)),2,'0');
        o_dhm := v_token || to_char(abs(o_hr),'fm999,990') || ':' || lpad(to_char(abs(o_min)),2,'0');
        -->>User37 Final Test Phase 1 V11 #1569 26/10/2020
  	end if;
  end;

  function cal_dhm_concat (p_qtyday in number, p_qtyavgwk in number) return varchar2 is
    v_min 	number(2);
    v_hour  number(2);
    v_day   number;
    v_num   number;
    v_dhm		varchar2(10);
    v_qtyday number;
    v_con   varchar2(10);
  begin
    v_qtyday := p_qtyday;
    if v_qtyday is not null then
      if v_qtyday < 0 then
          v_qtyday := v_qtyday * (-1);
          v_con    := '-';
      end if;
      v_day		:= trunc(v_qtyday / 1);
      v_num 	:= round(mod((v_qtyday * p_qtyavgwk),p_qtyavgwk),0);
      v_hour	:= trunc(v_num / 60);
      v_min		:= mod(v_num,60);
      v_dhm   := v_con||to_char(v_day)||':'||
                 lpad(to_char(v_hour),2,'0')||':'||
                 lpad(to_char(v_min),2,'0');
    else
      v_dhm := null;
    end if;
    return(v_dhm);
  end;

  function  convert_hour_to_minute (p_hour in varchar2) return number is
    v_hour number;
    v_min  number;
  begin
    --<<User37 Final Test Phase 1 V11 #3279 09/11/2020
    v_hour := substr(replace(p_hour,',',''), '1', instr(replace(p_hour,',',''), ':') - 1);
    v_min  := substr(replace(p_hour,',',''), instr(replace(p_hour,',',''), ':') + 1);
    --v_hour := substr(p_hour, '1', instr(p_hour, ':') - 1);
    --v_min  := substr(p_hour, instr(p_hour, ':') + 1);
    -->>User37 Final Test Phase 1 V11 #3279 09/11/2020
    return (nvl(v_hour,0) * 60 ) + nvl(v_min,0);
  end;

 function  convert_minute_to_hour(p_minute in number,p_base_100 in varchar2 default 'N') return varchar2 is
    v_hour varchar2(10 char);
    v_hour2 varchar2(10 char);
    v_min  varchar2(2 char);
  begin
    if p_minute is not null then
      v_hour := to_char(trunc(p_minute / 60),'fm999,990');--User37 Final Test Phase 1 V11 #3114 29/10/2020 trunc(to_char(p_minute / 60));
      v_hour2 := to_char(trunc(p_minute / 60));
      v_min := lpad(mod(p_minute , 60), 2, '0') ;
      if p_base_100 = 'Y' then -- hh.min
         return to_number(v_hour2) + to_number(to_char(to_number(v_min)/60,'fm990.90'));
      else -- hh:mm
        return v_hour || ':' || v_min ;
      end if;
   else
    return null;
   end if;
  end;

  function  convert_time_to_minute (p_time in varchar2) return number is
    v_hour number;
    v_min  number;
  begin
    v_hour := substr(p_time, '1', instr(p_time, ':') - 1);
    v_min  := substr(p_time, instr(p_time, ':') + 1);
    return (v_hour * 60 ) + v_min;
  end;

  function  convert_minute_to_time(p_minute in number) return varchar2 is
  begin
    return to_char (trunc(sysdate) + p_minute / 24/60, 'hh24:mi');
  end;

  function convert_dtetime_to_date(p_dtetime varchar2) return date is -- return format date with hr24:mi = 00:00
    v_dtetime date;
    v_date varchar2(4000 char);
  begin
    v_dtetime := to_date(p_dtetime,'dd/mm/yyyy hh24:mi');
    v_date := to_char(v_dtetime,'dd/mm/yyyy');
    return to_date(v_date,'dd/mm/yyyy');
  exception when others then return null;
  end;

  function convert_dtetime_to_time(p_dtetime varchar2) return varchar2 is -- return format 'hh24:mi'
    v_date date;
  begin
    v_date := to_date(p_dtetime,'dd/mm/yyyy hh24:mi');
    return to_char(v_date,'hh24mi');
  exception when others then return null;
  end;

  function convert_date_time_to_dtetime(p_date date,p_time varchar2) return varchar2 is -- return format 'dd/mm/yyyy hh24:mi'
    v_date    date;
    v_dtetime varchar2(4000 char);
  begin
    if p_date is null then
      return '';
    elsif p_time is null then
      return to_char(p_date,'dd/mm/yyyy') || ' ' || to_char(to_date('00:00','hh24:mi'),'hh24:mi');
    end if;
    return to_char(p_date,'dd/mm/yyyy') || ' ' || to_char(to_date(p_time,'hh24:mi'),'hh24:mi');
  exception when others then return null;
  end;

  function datediff_to_time(p_datestrt date,p_dateend date) return varchar2 is -- return format 'hh24:mi:ss'
    v_datediff_sec   number;
    v_time           varchar2(100 char);
  begin
    v_datediff_sec := abs(p_dateend - p_datestrt) * 24*60*60;
    begin
      select trunc(v_datediff_sec/3600)||':'||lpad(trunc(mod(v_datediff_sec,3600)/60),2,'0')||':'||lpad(trunc(mod(v_datediff_sec,60)),2,'0') time
        into v_time
        from dual;
    exception when others then
      v_time := null;
    end;
    return v_time;
  end;

  function query_cursor(json_str_input in clob) return sys_refcursor is
    output sys_refcursor;
    v_column varchar2(4000 char);
    param_msg_error varchar2(4000 char);
    json_obj json_object_t := json_object_t(json_str_input);
  BEGIN
    v_column := hcm_util.get_string_t(json_obj, 'p_column');
--    OPEN output FOR 'SELECT ''200'' coderror, '''' response,' || v_column || ' FROM temploy1';
    OPEN output FOR 'SELECT ''200'' coderror, '''' response, temploy1.* FROM temploy1 where rownum <= 500';
    RETURN output;
  EXCEPTION WHEN OTHERS THEN
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    OPEN output FOR 'SELECT ''400'' coderror, ''' || param_msg_error || ''' response from dual';
    RETURN output;
  END;

  procedure set_lang(p_lang varchar2) is
  begin
    global_v_lang := p_lang;
  end set_lang;

  function get_lang return varchar2 is
  begin
    return nvl(global_v_lang,'102');
  end get_lang;

  procedure get_terrorm(json_str_input in clob, json_str_output out clob) is
  json_obj        json_object_t;
  obj_data        json_object_t;
  v_errorno       varchar2(10 char);
  v_description   varchar2(100 char);

  begin
    json_obj := json_object_t(json_str_input);
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    v_errorno         := hcm_util.get_string_t(json_obj,'p_errorno');

    v_description := get_error_msg_php(v_errorno,global_v_lang);
    v_description := replace(v_description,'@#$%400','');
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('description', v_description);

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_terrorm;
    function get_pathphp(p_codapp varchar2) return varchar2 is
    v_folder  varchar2(4000 char);
  begin
    begin
      select folder
        into v_folder
        from tfolderd
       where codapp = upper(p_codapp);
    exception when no_data_found then
      v_folder := null;
    end;

    return get_tsetup_value('PATHWORKPHP')||v_folder||'/';
  end;

  function get_date_buddhist_era(p_date date) return varchar2 is
    v_additional  number;
    v_ret         varchar2(50);
  begin
    v_additional  := hcm_appsettings.get_additional_year;

    if v_additional = 0 then
        v_additional := 543;
    end if;

    if p_date is not null then
      v_ret  := to_char(p_date,'dd/mm')||'/'||to_char(to_number(to_char(p_date,'yyyy')) + v_additional);
    end if;
    return v_ret;
  exception when others then
    return to_char(p_date,'dd/mm/yyyy');
  end;

  function get_year_buddhist_era(p_year varchar2) return varchar2 is
    v_additional  number;
  begin
    v_additional  := hcm_appsettings.get_additional_year;
    if v_additional = 0 then
        v_additional := 543;
    end if;
    return to_char(to_number(p_year) + v_additional);
  exception when others then
    return p_year;
  end;

  function get_date_config(p_date date) return varchar2 is
    v_additional  number;
    v_ret         varchar2(50);
  begin
    v_additional  := nvl(hcm_appsettings.get_additional_year,0);

    if p_date is not null then
      v_ret  := to_char(p_date,'dd/mm')||'/'||to_char(to_number(to_char(p_date,'yyyy')) + v_additional);
    end if;
    return v_ret;
  exception when others then
    return to_char(p_date,'dd/mm/yyyy');
  end;

  function get_year_config(p_year varchar2) return varchar2 is
    v_additional  number;
  begin
    v_additional  := nvl(hcm_appsettings.get_additional_year,0);
    return to_char(to_number(p_year) + v_additional);
  exception when others then
    return p_year;
  end;

  function get_split_decimal(p_number varchar2,p_flg varchar2,p_leng_dec number default 2) return varchar2 is
    v_number    varchar2(101);
    v_ret       varchar2(100);
    v_leng_dec  varchar2(10);
  begin
    if p_leng_dec > 0 then
      v_leng_dec  := '.'||lpad('0',p_leng_dec,'0');
    end if;
    v_number  := to_char(to_number(replace(p_number,',','')),'fm999,999,999,999,999,999,999,990'||v_leng_dec);
    if p_flg = 'D' then
      v_ret   := substr(v_number,instr(v_number,'.') + 1);
    elsif  p_flg = 'I' then
      v_ret   := substr(v_number,1,instr(v_number,'.') - 1);
    end if;
    return v_ret;
  exception when others then
    return 0;
  end;
  --
  function get_tempimge(json_str in clob) return clob is
    json_obj      json_object_t;
    obj_row       json_object_t;
    obj_data      json_object_t;
    param_msg_error varchar2(4000 char);
    json_str_output clob;
    v_row         number  := 0;

    cursor c1 is
      select codempid,namimage,namsign
        from tempimge
    order by codempid;
  begin
    obj_row       := json_object_t();
    json_obj      := json_object_t(json_str);
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');

    for r1 in c1 loop
      obj_data  := json_object_t();
      v_row     := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codempid',r1.codempid);
      obj_data.put('namimage',r1.namimage);
      obj_data.put('namsign',r1.namsign);
      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
    return json_str_output;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    return json_str_output;
  end;
  --
  function get_tempimge_emp(json_str in clob) return clob is
    json_obj      json_object_t;
    obj_row       json_object_t;
    obj_data      json_object_t;
    param_msg_error varchar2(4000 char);
    json_str_output clob;
    v_row         number  := 0;
    v_codempid    varchar2(100 char);
    cursor c1 is
      select codempid,namimage,namsign
        from tempimge
        where codempid = v_codempid
    order by codempid;
  begin
    obj_row       := json_object_t();
    json_obj      := json_object_t(json_str);
    global_v_lang := hcm_util.get_string_t(json_obj,'p_lang');
    v_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    for r1 in c1 loop
      obj_data  := json_object_t();
      v_row     := v_row + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codempid',r1.codempid);
      obj_data.put('namimage',r1.namimage);
      obj_data.put('namsign',r1.namsign);
      obj_row.put(to_char(v_row - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
    return json_str_output;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    return json_str_output;
  end;
  --

  function get_date_excel(p_date date) return date is
    v_year    number;
  begin
    v_year  := to_number(to_char(p_date,'yyyy'));
--    if v_year > 2300 then
    if v_year > (to_number(to_char(sysdate,'yyyy')) + 543/2) then
      v_year  := v_year - 543;
    end if;
    return to_date(to_char(p_date,'dd/mm/')||v_year,'dd/mm/yyyy');
  end;

  function convert_numbank(p_numbank varchar2) return varchar2 is
    v_numbank    varchar2(20 char);
  begin
    v_numbank  := REGEXP_REPLACE(p_numbank,'([[:alnum:]]{3})([[:alnum:]]{1})([[:alnum:]]{5})','\1-\2-\3-');
    return v_numbank;
  end;

  function convert_codempid_to_temp(p_codempid varchar2) return varchar2 is
    v_codempid    varchar2(100 char);
  begin
    v_codempid  := to_char(REGEXP_REPLACE(p_codempid, '[!]|[@]|[#]|[$]|[%]|[&]|[*]|[+]|[-]|[*]|[/]', '0'));
    return v_codempid;
  end;

  function get_codcompy (p_codcomp varchar2) return varchar2 as
    v_codcomp         varchar2(200 char);
    v_codcomp_ret     varchar2(100 char);
    v_qtycode         number := 0;
    v_sub_start       number := 1;

  begin

    begin
        select qtycode
        into v_qtycode
        from tsetcomp
        where numseq = 1;
    exception when others then
        v_qtycode :=0;
    end;

    v_codcomp := replace(p_codcomp,'-');
    v_codcomp_ret := substr(v_codcomp,v_sub_start,v_qtycode);

    return v_codcomp_ret;
  end;

  function get_codcomp_by_level (p_codcomp varchar2, p_level number default 1) return varchar2 as
    v_codcomp         varchar2(200 char);
    v_codcomp_ret     varchar2(100 char);
    v_qtycode         number := 0;
    v_sub_start       number := 1;

  begin

    begin
        select sum(qtycode)
        into v_qtycode
        from tsetcomp
        where numseq <= p_level;
    exception when others then
        v_qtycode :=0;
    end;

    v_codcomp := replace(p_codcomp,'-');
    v_codcomp_ret := substr(v_codcomp,v_sub_start,v_qtycode);

    return v_codcomp_ret;
  end;

end;

/

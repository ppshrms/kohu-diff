--------------------------------------------------------
--  DDL for Package Body GET_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GET_REPORT" as
-- last update: 23/02/2018 12:02

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    -- Not used
    -- v_chken             := hcm_secur.get_v_chken;
    json_obj              := json_object_t(json_str);
    -- global
    global_v_coduser      := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid     := hcm_util.get_string_t(json_obj, 'p_codempid');

    -- index params
    p_codapp              := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_codempid            := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_disp                := upper(hcm_util.get_string_t(json_obj, 'p_disp'));
    p_file_ext            := lower(hcm_util.get_string_t(json_obj, 'p_file_ext'));
    p_condition_disp      := lower(hcm_util.get_string_t(json_obj, 'p_condition_disp'));
    p_summary_disp        := lower(hcm_util.get_string_t(json_obj, 'p_summary_disp'));
    p_no_header           := upper(hcm_util.get_string_t(json_obj, 'p_no_header'));
    p_bottom_line_disp    := upper(hcm_util.get_string_t(json_obj, 'p_bottom_line_disp'));
    p_page_size           := upper(hcm_util.get_string_t(json_obj, 'p_page_size'));
    p_parameter           := hcm_util.get_json_t(json_obj, 'parameter');
    p_logo_codempid_query := upper(hcm_util.get_string_t(json_obj, 'p_logo_codempid_query'));
    p_logo_codcomp_query  := upper(hcm_util.get_string_t(json_obj, 'p_logo_codcomp_query'));

    p_mailto              := hcm_util.get_string_t(json_obj, 'p_mailto');
    p_mailsubject         := hcm_util.get_string_t(json_obj, 'p_mailsubject');
    p_mailbody            := hcm_util.get_string_t(json_obj, 'p_mailbody');
    p_mailattachfile      := hcm_util.get_string_t(json_obj, 'p_mailattachfile');

  end initial_value;

  procedure get_main_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_main_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_main_setup;

  procedure gen_main_setup (json_str_output out clob) is
    v_codapp_use        trepapp.codapp%type;
    v_font_style        varchar2(100 char);
    obj_data            json_object_t := json_object_t();
    cursor c1 is
      select *
        from trepapp
       where codapp = v_codapp_use
       fetch next 1 rows only;
  begin
    v_codapp_use        := get_exists_setup(p_codapp);

    obj_data.put('coderror', '200');

    v_font_style        := get_tsetup_value('FONTREP');
    if v_font_style is null then
      v_font_style      := p_std_font;
    end if;
    obj_data.put('fontrep', v_font_style);

    for r1 in c1 loop
      obj_data.put('margintop', r1.margintop);
      obj_data.put('marginright', r1.marginright);
      obj_data.put('marginbott', r1.marginbott);
      obj_data.put('marginleft', r1.marginleft);
      obj_data.put('widlogo', r1.widlogo);
      obj_data.put('heighlogo', r1.heighlogo);
      obj_data.put('hdcolor', r1.hdcolor);
      obj_data.put('bgcolor1', r1.bgcolor1);
      obj_data.put('bgcolor2', r1.bgcolor2);
      obj_data.put('bgcolor3', r1.bgcolor3);
      obj_data.put('bgcolor4', r1.bgcolor4);
      obj_data.put('bgcolor5', r1.bgcolor5);
      obj_data.put('bgcolor6', r1.bgcolor6);
      obj_data.put('bgcolor7', r1.bgcolor7);
      obj_data.put('bgcolor8', r1.bgcolor8);
      obj_data.put('bgcolor9', r1.bgcolor9);
      obj_data.put('bgcolor10', r1.bgcolor10);
      obj_data.put('rowcolor1', r1.rowcolor1);
      obj_data.put('rowcolor2', r1.rowcolor2);
      obj_data.put('heighcol', r1.heighcol);
      obj_data.put('heighdata', r1.heighdata);
      obj_data.put('heighsum', r1.heighsum);
      obj_data.put('alignft1', r1.alignft1);
      obj_data.put('alignft2', r1.alignft2);
      obj_data.put('alignft3', r1.alignft3);
      obj_data.put('linetab', r1.linetab);
      obj_data.put('linesept', r1.linesept);
      obj_data.put('flgdeflt', r1.flgdeflt);
      obj_data.put('orientation', get_page_orientation(p_codapp));
      obj_data.put('file_type', get_file_extension(p_codapp));
      obj_data.put('condition_disp', get_condition_page(p_codapp));
      obj_data.put('summary_disp', p_summary_disp);
      obj_data.put('no_header', get_show_header(p_codapp));
      obj_data.put('page_size', get_page_size(p_codapp));
      obj_data.put('max_width', get_max_width(get_page_size(p_codapp), get_page_orientation(p_codapp)));
      obj_data.put('folder_image', get_tfolder_image);
      obj_data.put('bottom_line_disp', get_bottom_line_disp);
      obj_data.put('real_codapp', get_real_codapp(p_codapp));
      obj_data.put('file_path', get_file_path);
      obj_data.put('template_path', get_template_path);
      obj_data.put('footerdisp', r1.footerdisp);
    end loop;

    json_str_output := obj_data.to_clob;
  end gen_main_setup;

  procedure get_head_foot_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_head_foot_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_head_foot_setup;

  procedure gen_head_foot_setup (json_str_output out clob) is
    v_codcompy_user     tcompny.namcome%type;
    v_codcompy_logo     tcompny.namcome%type;
    v_codapp_use        trepapp.codapp%type;
    obj_data            json_object_t := json_object_t();
  begin
    v_codapp_use        := get_exists_setup(p_codapp);
    v_codcompy_user     := get_user_codcompy(global_v_codempid);
    v_codcompy_logo     := get_codcompy_logo(p_logo_codempid_query, p_logo_codcomp_query, v_codcompy_user, global_v_lang);
    obj_data.put('coderror', '200');

    obj_data.put('title_name', get_report_title(p_codapp, global_v_lang));
    obj_data.put('title_style', 'vertical-align: top; font-size: 18px; font-weigh: bold; font-color: #3887c9;');
    obj_data.put('company_name_name', get_tcompny_name(v_codcompy_logo, global_v_lang));
--    obj_data.put('company_name_name', get_comp_desc(v_codapp_use, global_v_coduser, v_codcompy_logo, global_v_lang));
--    obj_data.put('company_name_name', 'People Plus Software Co., Ltd.');
    obj_data.put('company_name_style', 'font-size: 10px; font-weigh: bold; font-style: normal;');
    obj_data.put('company_logo_name', get_comp_image(v_codapp_use, global_v_coduser, v_codcompy_logo, global_v_lang));
    obj_data.put('company_logo_style', 'vertical-align: top; font-weigh: bold;');
    obj_data.put('emp_image_name', get_emp_img(p_codempid));
    obj_data.put('emp_image_style', 'width: 50px; height: 50px;');
    obj_data.put('emp_image_disp', p_disp);
    obj_data.put('print_date_name_1', get_description_label(v_codapp_use, 1, global_v_lang));
    obj_data.put('print_date_name_2', get_description_label(v_codapp_use, 2, global_v_lang));
    obj_data.put('print_date_date', get_print_date);
    obj_data.put('print_date_time', get_print_time);
    obj_data.put('print_date_style', '');
    obj_data.put('left_name', get_description_footer(v_codapp_use, 1, global_v_lang));
    obj_data.put('left_style', get_style_footer(v_codapp_use, 1));
    obj_data.put('middle_name', get_description_footer(v_codapp_use, 2, global_v_lang));
    obj_data.put('middle_style', get_style_footer(v_codapp_use, 2));
    obj_data.put('right_name', get_description_footer(v_codapp_use, 3, global_v_lang));
    obj_data.put('right_style', get_style_footer(v_codapp_use, 3));
    obj_data.put('real_codapp', get_real_codapp(p_codapp));

    json_str_output := obj_data.to_clob;
  end gen_head_foot_setup;

  procedure get_style1_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_style1_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_style1_setup;

  procedure gen_style1_setup (json_str_output out clob) is
    v_codapp_use        trepapp.codapp%type;
    obj_data            json_object_t := json_object_t();
    obj_row             json_object_t;
    v_rcnt              number := 0;
    cursor c1 is
      select *
        from trepapp1
       where codapp = v_codapp_use
         and typrep = 1
    order by rowidx, numseq;
  begin
    v_codapp_use        := get_exists_setup(p_codapp, 1);

    for r1 in c1 loop
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codapp', r1.codapp);
      obj_row.put('typrep', r1.typrep);
      obj_row.put('numseq', r1.numseq);
      obj_row.put('style_name', r1.style_name);
      obj_row.put('style_text', r1.style_text);
      obj_row.put('rowidx', r1.rowidx);

      obj_data.put(to_char(v_rcnt), obj_row);
      v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_style1_setup;

  procedure get_style2_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_style2_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_style2_setup;

  procedure gen_style2_setup (json_str_output out clob) is
    v_codapp            trepapp.codapp%type;
    v_keycolumn         varchar2(1000 char);
    obj_data            json_object_t := json_object_t();
    obj_row             json_object_t;
    v_rcnt              number := 0;
    cursor c1 is -- for field in index 
      select *
        from trepapp2
       where codapp = p_codapp
    order by keycolumn;

    cursor c_tadjrep_table is -- for field in adjust 
      select p_codapp codapp,b.column_name keycolumn,b.data_type,b.data_length,a.tbname
        from tadjrept a,user_tab_columns b
       where a.tbname = b.table_name(+)
         and a.codapp = p_codapp
         and b.column_name not in (select keycolumn from trepapp2 where codapp = p_codapp)
      order by a.tbname,b.column_name;
  begin
    -- for field in index 
    for r1 in c1 loop
      for i in 1..2 loop -- codempid, DEFAULT_CODEMPID
        if i = 1 then
          v_keycolumn := r1.keycolumn;
        else
          v_keycolumn := upper('DEFAULT_'||r1.keycolumn);
        end if;
        
        obj_row := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('codapp', r1.codapp);
        obj_row.put('keycolumn', v_keycolumn);
        obj_row.put('style_column', 'text-align: center; vertical-align: middle;'||r1.style_column);
        obj_row.put('style_data', r1.style_data);
  
        obj_data.put(to_char(v_rcnt), obj_row);
        v_rcnt := v_rcnt + 1;
      end loop;
    end loop;

    -- for field in adjust 
    for r_tadjrep_table in c_tadjrep_table loop
      v_keycolumn := upper(r_tadjrep_table.tbname||'_'||r_tadjrep_table.keycolumn);
      
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codapp', r_tadjrep_table.codapp);
      obj_row.put('keycolumn', v_keycolumn);
      if r_tadjrep_table.data_type = 'NUMBER' then
        obj_row.put('style_data', 'text-align: center;');
        obj_row.put('style_column', 'text-align: center; vertical-align: middle; width: 100px;');
      elsif r_tadjrep_table.data_type = 'DATE' then
        obj_row.put('style_data', 'text-align: center;');
        obj_row.put('style_column', 'text-align: center; vertical-align: middle; width: 100px;');
      else
        obj_row.put('style_data', 'text-align: left;');
        obj_row.put('style_column', 'text-align: center; vertical-align: middle; width: 150px;');
      end if;

      obj_data.put(to_char(v_rcnt), obj_row);
      v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_style2_setup;

  procedure get_style3_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_style3_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_style3_setup;

  procedure gen_style3_setup (json_str_output out clob) is
    v_codapp_use        trepapp.codapp%type;
    obj_data            json_object_t := json_object_t();
    obj_row             json_object_t;
    v_rcnt              number := 0;
    cursor c1 is
      select *
        from trepapp3
       where codapp = v_codapp_use
    order by keycolumn;
  begin
    v_codapp_use        := get_exists_setup(p_codapp, 3);

    for r1 in c1 loop
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codapp', r1.codapp);
      obj_row.put('keycolumn', r1.keycolumn);
      obj_row.put('style_spec', r1.style_spec);

      obj_data.put(to_char(v_rcnt), obj_row);
      v_rcnt := v_rcnt + 1;
    end loop;

    json_str_output := obj_data.to_clob;
  end gen_style3_setup;

  procedure get_summary_setup (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_summary_setup (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_summary_setup;

  procedure gen_summary_setup (json_str_output out clob) is
    v_codapp_use        trepapp.codapp%type;
    obj_data            json_object_t := json_object_t();
    obj_row             json_object_t;
    v_rcnt              number := 0;
    cursor c1 is
      select *
        from trepapp1
       where codapp = v_codapp_use
         and typrep = 2
    order by rowidx, numseq;
  begin
    v_codapp_use        := get_exists_setup(p_codapp, 1);

    for r1 in c1 loop
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('codapp', r1.codapp);
      obj_row.put('typrep', r1.typrep);
      obj_row.put('numseq', r1.numseq);
      obj_row.put('style_name', r1.style_name);
      obj_row.put('style_text', r1.style_text);
      obj_row.put('rowidx', r1.rowidx);

      obj_data.put(to_char(v_rcnt), obj_row);
      v_rcnt := v_rcnt + 1;
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_summary_setup;


  function get_exists_setup (v_codapp varchar2, v_table_use number := 0) return varchar2 is
    v_codapp_use        trepapp.codapp%type;
  begin
    if v_table_use = 1 then
      begin
        select codapp
          into v_codapp_use
          from trepapp1
         where codapp = v_codapp
           and typrep = 1
      group by codapp;
      exception when no_data_found then
        v_codapp_use  := p_std_codapp;
      end;
    elsif v_table_use = 2 then
      begin
        select codapp
          into v_codapp_use
          from trepapp2
         where codapp = v_codapp
      group by codapp;
      exception when no_data_found then
        v_codapp_use  := p_std_codapp;
      end;
    elsif v_table_use = 3 then
      begin
        select codapp
          into v_codapp_use
          from trepapp3
         where codapp = v_codapp
      group by codapp;
      exception when no_data_found then
        v_codapp_use  := p_std_codapp;
      end;
    elsif v_table_use = 4 then
      begin
        select codapp
          into v_codapp_use
          from trepapp1
         where codapp = v_codapp
           and typrep = 2
      group by codapp;
      exception when no_data_found then
        v_codapp_use  := p_std_codapp;
      end;
    else
      begin
        select codapp
          into v_codapp_use
          from trepapp
         where codapp = v_codapp
      group by codapp;
      exception when no_data_found then
        v_codapp_use  := p_std_codapp;
      end;
    end if;
    return v_codapp_use;
  end;

  function get_description_label (v_codapp varchar2, v_numseq number, v_lang varchar2) return varchar2 is
    v_flg1              trepapp.flgfoot1%type;
    v_flg2              trepapp.flgfoot2%type;
    v_flg3              trepapp.flgfoot3%type;
    v_descname          trepapp.namprintt%type;
    v_codapp_use        trepapp.codapp%type;
  begin
    v_descname          := '';
    v_codapp_use        := get_exists_setup(v_codapp);

    begin
      select flgfoot1, flgfoot2, flgfoot3
        into v_flg1, v_flg2, v_flg3
        from trepapp
       where codapp = v_codapp_use;
    exception when no_data_found then
      v_flg1 := '';
      v_flg2 := '';
      v_flg3 := '';
    end;

    if v_numseq = 1 then
      begin
        select decode(v_lang, '101', namprinte
                            , '102', namprintt
                            , '103', namprint3
                            , '104', namprint4
                            , '105', namprint5
                            , namprintt)
          into v_descname
          from trepapp
         where codapp = v_codapp_use;
      end;
    elsif v_numseq = 2 then
      begin
        select decode(v_lang, '101', nampagee
                            , '102', nampaget
                            , '103', nampage3
                            , '104', nampage4
                            , '105', nampage5
                            , nampaget)
          into v_descname
          from trepapp
         where codapp = v_codapp_use;
      end;
    else
      if v_numseq = 3 and v_flg1 = 4 then
        begin
          select decode(v_lang, '101', footer1e
                              , '102', footer1t
                              , '103', footer13
                              , '104', footer14
                              , '105', footer15
                              , footer1t)
            into v_descname
            from trepapp
           where codapp = v_codapp_use;
        end;
      elsif v_numseq = 4 and v_flg2 = 4 then
        begin
          select decode(v_lang, '101', footer2e
                              , '102', footer2t
                              , '103', footer23
                              , '104', footer24
                              , '105', footer25
                              , footer2t)
            into v_descname
            from trepapp
           where codapp = v_codapp_use;
        end;
      elsif v_numseq = 5 and v_flg3 = 4 then
        begin
          select decode(v_lang, '101', footer3e
                              , '102', footer3t
                              , '103', footer33
                              , '104', footer34
                              , '105', footer35
                              , footer3t)
            into v_descname
            from trepapp
           where codapp = v_codapp_use;
        end;
      else
        begin
          select desc_label
            into v_descname
            from trptlbl
           where codrept = v_codapp
             and codlang = v_lang
             and numseq = v_numseq;
        exception when no_data_found then
          v_descname    := get_tlistval_name('FOOTER', (v_numseq - 2), v_lang);
        end;
      end if;
    end if;
    return v_descname;
  exception when others then
    return ('***************');
  end;

  function get_report_title (v_codapp varchar2, v_lang varchar2) return varchar2 is
  begin
    return get_tappprof_name(v_codapp, '2', v_lang);
  end;

  function get_codcompy_logo(v_codempid varchar2, v_codcomp1 varchar2, v_user_codcompy varchar2, v_lang varchar2) return varchar2 is
    v_codcompy  tcompny.codcompy%type;
	begin

    if v_codempid is not null then
        --v_codcompy := get_codcompy(v_codempid); 2019-10-1 #Remove by User18:Pongsak
        v_codcompy := get_user_codcompy(v_codempid); -- 2019-10-1 #Add by User18:Pongsak
        if v_codcompy is null then
            v_codcompy := v_user_codcompy;
        end if;
    elsif v_codcomp1 is not null then
        v_codcompy := hcm_util.get_codcomp_level (v_codcomp1,1);
    else
        v_codcompy := v_user_codcompy;
    end if;
    return v_codcompy;
	end ;

  function get_comp_desc (v_codapp varchar2, v_coduser varchar2, v_codcompy varchar2, v_lang varchar2) return varchar2 is
    v_namcompy              tcompny.namcome%type;
  begin
    begin
      select decode(v_lang, '101', namcome,
                            '102', namcomt,
                            '103', namcom3,
                            '104', namcom4,
                            '105', namcom5,
                            namcome)
        into v_namcompy
        from tcompny
       where codcompy = v_codcompy;
    exception when no_data_found then
      v_namcompy          := '';
    end;
    return v_namcompy;
  end;

  function get_comp_image (v_codapp varchar2, v_coduser varchar2, v_codcompy varchar2, v_lang varchar2) return varchar2 is
    v_namimgcom       tcompny.namimgcom%type;
    v_folder          tfolderd.folder%type;
    v_path_logo       varchar2(1000 char);
    v_default_logo    varchar2(1000 char) := '/file_uploads/peopleplus.png';
  begin
    v_path_logo := '/file_uploads/';

    -- folder
    begin
      select folder||'/'
        into v_folder
        from tfolderd
       where codapp = 'HRCO01E1';
    exception when no_data_found then
      v_folder := null;
    end;

    -- image name
    begin
      select namimgcom
        into v_namimgcom
        from tcompny
       where codcompy = v_codcompy;
    exception when no_data_found then
      v_namimgcom := null;
    end;
    if v_namimgcom is null or v_folder is null then
      return v_default_logo;
    end if;

    return v_path_logo||v_folder||v_namimgcom;
--    return '/file_uploads/peopleplus.png';
  end;

  function get_page_orientation (v_codapp varchar2) return varchar2 is
    v_orientation       tappprof.typrep%type;
    v_orientation_full  varchar2(100 char);
  begin
    begin
      select typrep
        into v_orientation
        from tappprof
       where codapp = v_codapp;
    exception when no_data_found then
      v_orientation := 'P';
    end;
    v_orientation   := upper(v_orientation);
    if v_orientation = 'P' then
      v_orientation_full := 'portrait';
    elsif v_orientation = 'L' then
      v_orientation_full := 'landscape';
    else
      v_orientation_full := '';
    end if;
    return v_orientation_full;
  end;

  function get_user_codcompy (v_codempid varchar2) return varchar2 is
    v_codcomp           temploy1.codcomp%type;
  begin
    begin
      select codcomp
        into v_codcomp
        from temploy1
       where codempid = v_codempid
       fetch next 1 rows only;
    exception when no_data_found then
      v_codcomp        := '';
    end;

--    return get_codcompy (v_codcomp);
    return hcm_util.get_codcomp_level (v_codcomp,1);
  end;

  function get_file_extension (v_codapp varchar2) return varchar2 is
    v_codapp_use        trepapp.codapp%type;
  begin
    if p_file_ext in ('pdf', 'xlsx', 'xls') then
      return p_file_ext;
    else
      return 'pdf';
    end if;
  end;

  function get_page_size (v_codapp varchar2) return varchar2 is
    v_codapp_use        trepapp.codapp%type;
  begin
    if p_page_size is not null then
      return p_page_size;
    else
      return 'A4';
    end if;
  end;

  function get_condition_page (v_codapp varchar2) return varchar2 is
    v_codapp_use        trepapp.codapp%type;
  begin
    if p_condition_disp in ('allpage', 'firstpage') then
      return p_condition_disp;
    else
      return 'allpage';
    end if;
  end;

  function get_show_header (v_codapp varchar2) return varchar2 is
    v_codapp_use        trepapp.codapp%type;
  begin
    if p_no_header in ('N', 'Y') then
      return p_no_header;
    else
      return 'N';
    end if;
  end;

  function get_description_footer (v_codapp varchar2, v_numseq number, v_lang varchar2) return varchar2 is
  begin
    if v_numseq = 1 then
      return get_description_label(v_codapp, 3, v_lang);
    elsif v_numseq = 2 then
      return get_description_label(v_codapp, 4, v_lang);
    elsif v_numseq = 3 then
      return get_description_label(v_codapp, 5, v_lang);
    else
      return get_description_label(v_codapp, 3, v_lang);
    end if;
  end;

  function get_style_footer (v_codapp varchar2, v_numseq number := 0) return varchar2 is
    v_align1            trepapp.alignft1%type;
    v_align2            trepapp.alignft2%type;
    v_align3            trepapp.alignft3%type;
    v_style             varchar2(100 char);
  begin
    v_style             := '';
    begin
      select upper(alignft1), upper(alignft2), upper(alignft3)
        into v_align1, v_align2, v_align3
        from trepapp
       where codapp = v_codapp;
    exception when no_data_found then
      v_align1 := '';
      v_align2 := '';
      v_align3 := '';
    end;
    if v_numseq = 1 and v_align1 in ('L', 'C', 'R') then
      v_style := 'font-size: 10px; font-weigh: normal; text-align: ' || get_convert_align(v_align1);
    elsif v_numseq = 2 and v_align2 in ('L', 'C', 'R') then
      v_style := 'font-size: 10px; font-weigh: normal; text-align: ' || get_convert_align(v_align2);
    elsif v_numseq = 3 and v_align3 in ('L', 'C', 'R') then
      v_style := 'font-size: 10px; font-weigh: normal; text-align: ' || get_convert_align(v_align3);
    end if;
    return v_style;
  end;

  function get_convert_align (v_align varchar2) return varchar2 is
    v_style             varchar2(100 char) := '';
  begin
    if v_align = 'L' then
      v_style := 'left';
    elsif v_align = 'C' then
      v_style := 'center';
    elsif v_align = 'R' then
      v_style := 'right';
    end if;
    return v_style;
  end;

  function get_max_width (v_page_size varchar2, v_orienatation varchar2) return number is
    v_max_width         number := 0;
  begin
    if v_page_size = 'A4' then
      if v_orienatation = 'landscape' then
        v_max_width     := 822;
      else
        v_max_width     := 575;
      end if;
    elsif v_page_size = 'A3' then
      if v_orienatation = 'landscape' then
        v_max_width     := 1170;
      else
        v_max_width     := 822;
      end if;
    elsif v_page_size = 'A2' then
      if v_orienatation = 'landscape' then
        v_max_width     := 1664;
      else
        v_max_width     := 1170;
      end if;
    elsif v_page_size = 'A1' then
      if v_orienatation = 'landscape' then
        v_max_width     := 2360;
      else
        v_max_width     := 1664;
      end if;
    else
      v_max_width       := 1000;
    end if;
    return v_max_width;
  end;

  function get_tfolder_image return varchar2 is
    v_folder            varchar2(4000 char);
    v_host_folder       varchar2(4000 char);
    v_pathfile          varchar2(4000 char);
  begin
    v_host_folder := get_tsetup_value('PATHWORKPHP');
    begin
      select folder
        into v_folder
        from tfolderd
       where upper(codapp) = upper('HRPMC2E1');
    exception when no_data_found then
      v_folder := null;
    end;
    v_pathfile := '/' || v_host_folder || v_folder;
    return v_pathfile;
  end;

  function get_bottom_line_disp return varchar2 is
  begin
    if p_bottom_line_disp in ('Y', 'N') then
      return p_bottom_line_disp;
    else
      return 'Y';
    end if;
  end;

  function get_real_codapp (v_codapp varchar2) return varchar2 is
    v_real_codapp tappprof.codapp%type;
  begin
    if v_codapp is not null then
      v_real_codapp := upper(substr(v_codapp, 1, 7));
    else
      v_real_codapp := '';
    end if;
    return v_real_codapp;
  end;

  function get_print_date return varchar2 is
    additional_year       number := 0;
    v_date                date := sysdate;
    v_print_date          varchar2(100 char) := '';
  begin
    additional_year       := hcm_appsettings.get_additional_year;
    v_print_date          := to_char(v_date, 'DD/MM/') || (to_number(to_char(v_date, 'YYYY')) + additional_year);
    return ' ' || v_print_date;
  exception when others then
    return 'Exception::DATE';
  end get_print_date;

  function get_print_time return varchar2 is
  begin
    return ' ' || to_char(sysdate, 'HH24:MI:SS');
  exception when others then
    return 'Exception::TIME';
  end get_print_time;

  function get_file_path return varchar2 is
  begin
    -- Docker version
    return '/usr/local/tomcat/temp/output';
  end get_file_path;

  function get_template_path return varchar2 is
  begin
    -- Docker version
    return '/usr/local/tomcat/temp/jasper/';
  end get_template_path;

  procedure get_setup_template (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_setup_template (json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_setup_template;

  procedure gen_setup_template (json_str_output out clob) is
    v_codapp_use        trepapp.codapp%type;
    v_font_style        varchar2(100 char);
    obj_data            json_object_t := json_object_t();
  begin
    v_codapp_use        := get_exists_setup(p_codapp);

    obj_data.put('coderror', '200');
    obj_data.put('title_name', get_report_title(p_codapp, global_v_lang));
    obj_data.put('file_type', get_file_extension(p_codapp));
    obj_data.put('file_path', get_file_path);
    obj_data.put('template_path', get_template_path);
    obj_data.put('print_date_date', get_print_date);
    obj_data.put('print_date_time', get_print_time);

    json_str_output := obj_data.to_clob;
  end gen_setup_template;

  procedure delete_ttemprpt (json_str_input in clob, json_str_output out clob) is
    v_codempid          ttemprpt.codempid%type;
    v_codapp            ttemprpt.codapp%type;
  begin
    initial_value (json_str_input);
    v_codempid          := hcm_util.get_string_t(p_parameter, 'p_codempid');
    v_codapp            := hcm_util.get_string_t(p_parameter, 'p_codapp');
    if param_msg_error is null then
      if v_codempid is not null and v_codapp is not null then
        begin
          delete
            from ttemprpt
          where upper(codempid) = upper(v_codempid)
            and upper(codapp)   like upper(v_codapp) || '%';
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TTEMPRPT');
      end if;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang, 'TTEMPRPT');
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end delete_ttemprpt;

  procedure get_flag_default (json_str_input in clob, json_str_output out clob) is
    v_flgdeflt          trepapp.flgdeflt%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
        gen_flag_default(json_str_output);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end get_flag_default;

  procedure gen_flag_default (json_str_output out clob) is
    v_flgdeflt          trepapp.flgdeflt%type;
    obj_data            json_object_t;
    v_emaillist         varchar2(1000);
    v_stdflgdeflt       trepapp.flgdeflt%type;
    cursor c_trepappm is
    select email
      from trepappm
     where codapp = p_codapp;
  begin

    BEGIN
        select flgdeflt
          into v_stdflgdeflt
          from trepapp
         where codapp = 'STD';
        exception when others then
            v_flgdeflt := 'P';
    END;

    BEGIN
        select flgdeflt
          into v_flgdeflt
          from trepapp
         where codapp = p_codapp;
        exception when others then
            v_flgdeflt := v_stdflgdeflt;
    END;

    BEGIN
        for c1 in c_trepappm loop
            if v_emaillist is null then
                v_emaillist := c1.email;
            else
                v_emaillist := v_emaillist || ',' || c1.email;
            end if;
        end loop;
        exception when others then
            v_emaillist := '';
    END;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('flgdeflt', v_flgdeflt);
    obj_data.put('emaillist', v_emaillist);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error, global_v_lang);
  end gen_flag_default;
  
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

  procedure sendmail_pdf_report (json_str_input in clob, json_str_output out clob) is
    v_mailfrom          varchar2(200 char);
    v_error             varchar2(1000 char);
    a_mailto            arr_1d;
  begin
    initial_value (json_str_input);

    begin
        select get_tsetup_value('MAILEMAIL')
          into v_mailfrom
          from dual;
          
        a_mailto := explode(',',p_mailto);
        for i in 1..a_mailto.count loop
          v_error := sendmail_attachfile(
                          v_mailfrom,
                          trim(a_mailto(i)),
                          p_mailsubject,
                          p_mailbody,
  --                        null,
                          p_mailattachfile,
                          null,null,null,null);
        end loop;
    end;
    if v_error = '7521' then
      param_msg_error := get_error_msg_php('HR2046',global_v_lang);
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    else
      param_msg_error := v_error;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end sendmail_pdf_report;

end;

/

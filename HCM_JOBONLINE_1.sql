--------------------------------------------------------
--  DDL for Package Body HCM_JOBONLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_JOBONLINE" is
-- last update: 10/01/2021 11:23

  function get_license_jo(json_str_input clob) return clob is
    json_str_output clob;
    obj_data        json_object_t;
  begin
    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('license',nvl(to_char(get_license('', 'JO')), '10'));

    return obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end get_license_jo;

  function get_commoncode_stmt(p_ms_table varchar2) return varchar2 is
    v_stmt    varchar2(4000 char);
  begin
    if p_ms_table = 'ms_country' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodcnty
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_currency' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodcurr
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_degree' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcoddgee
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_district' then
      v_stmt  := 'select coddist code, namdiste labe, namdistt labt, codprov code1, codpost code2, null, null, null
                  from tcoddist
                  order by coddist';
    elsif p_ms_table = 'ms_education' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodeduc
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_institute' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodinst
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_faculty' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodmajr
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_media' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodmedi
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_nationality' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodnatn
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_occupation' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodoccu
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_province' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodprov
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_race' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodregn
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_subject' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodsubj
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_subdistrict' then
      v_stmt  := 'select codsubdist code, namsubdiste labe, namsubdistt labt, coddist code1, codprov code2, null, null, null
                  from tsubdist
                  order by codsubdist';
    elsif p_ms_table = 'ms_relationship' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''flgref'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_secondpos' then
      v_stmt  := 'select codpos code, nampose labe, nampost labt, null, null, null, null, null
                  from tpostn
                  order by codpos';
    elsif p_ms_table = 'ms_prefixname' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''codtitle'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_marital' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''nammarry'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_military' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''nammilit'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_religion' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodreli
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_travelupcountry' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''flgprov'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_traveloverseas' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''flgoversea'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_jobf' then
      v_stmt  := 'select codjob code, namjobe labe, namjobt labt, null, null, null, null, null
                  from tjobcode
                  order by codjob';
    elsif p_ms_table = 'ms_location' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodloca
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_typdoc' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodtydoc
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_lang' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcodlang
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'ms_langscore' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''langscore'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_stadisb' then
      v_stmt  := 'select list_value code,max(decode(codlang,''101'',desc_label,'''')) labe,max(decode(codlang,''102'',desc_label,'''')) labt, null, null, numseq, codapp, null
                  from tlistval
                  where lower(codapp) = ''stadisb'' and numseq <> 0 and codlang in (''101'',''102'')
                  group by numseq,codapp,list_value
                  order by numseq,codapp,list_value';
    elsif p_ms_table = 'ms_typdisp' then
      v_stmt  := 'select codcodec code, descode labe, descodt labt, null, null, null, null, null
                  from tcoddisp
                  where nvl(flgact,''1'') = ''1''
                  order by codcodec';
    elsif p_ms_table = 'user' then
      v_stmt  := 'select a.coduser code, b.namfirste||'' ''||b.namlaste labe, b.namfirstt||'' ''||b.namlastt labt,
                  a.codpswd code1,
                  a.codempid code2,
                  hcm_util.get_codcomp_level(b.codcomp,1) code3, b.codcomp code4, decode(a.flgact,''1'',''O'',''C'') code5
                  from tusrprof a, temploy1 b
                  where a.codempid = b.codempid
                  order by a.coduser';
    elsif p_ms_table = 'usercomp' then
      v_stmt  := 'select coduser code, hcm_util.get_codcomp_level(codcomp,1) labe, null, null, null, null, null, null
                  from tusrcom
                  group by coduser, hcm_util.get_codcomp_level(codcomp,1)';
    elsif p_ms_table = 'ms_compny' then
      v_stmt  := 'select codcompy code, namcome labe, namcomt labt, null, null, null, null, null
                  from tcompny
                  order by codcompy';
    elsif p_ms_table = 'ms_center' then
      v_stmt  := 'select codcomp code, namcente labe, namcentt labt, null, null, null, null, null
                  from tcenter
                  order by codcomp';
    elsif p_ms_table = 'ms_setpass' then
      v_stmt  := 'select to_char(dteeffec,''dd/mm/yyyy'') code, qtypassmax, qtypassmin, qtynumdigit, qtyspecail, qtyalpbup, qtyalpblow, null
                  from tsetpass
                  order by dteeffec';
    end if;
    return v_stmt;
  end;

  function get_commoncode(json_str_input clob) return clob is
    json_str_output clob;
    json_obj        json_object_t;
    json_obj_list   json_object_t;
    array_list      json_array_t;
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;  -- total record of all common code
    v_numseq        number := 0;  -- total record of each common code
    v_param         clob;
    v_count         number;
    v_namfld        varchar2(1000 char);
    v_stmt          varchar2(4000 char);
    v_cursor        number;
    v_dummy         integer;
    v_code          varchar2(1000 char);
    v_labe          varchar2(1000 char);
    v_labt          varchar2(1000 char);
    v_code1         varchar2(1000 char);
    v_code2         varchar2(1000 char);
    v_code3         varchar2(1000 char);
    v_code4         varchar2(1000 char);
    v_code5         varchar2(1000 char);
    v_flgdata       boolean;
    v_flgdata_user  boolean;
  begin
    global_chken := hcm_secur.get_v_chken;
    json_obj     := json_object_t(json_str_input);
    v_param      := hcm_util.get_clob_t(json_obj, 'param');

    -- get all common code
    if v_param = 'null' then
      v_param := '{"json_list":["ms_country","ms_currency","ms_degree","ms_district","ms_education","ms_institute","ms_faculty","ms_media","ms_nationality","ms_occupation","ms_province","ms_race","ms_subject","ms_subdistrict","ms_relationship","ms_secondpos","ms_prefixname","ms_marital","ms_military","ms_religion","ms_travelupcountry","ms_traveloverseas","ms_jobf","ms_location","ms_typdoc","ms_lang","ms_langscore","ms_stadisb","ms_typdisp","user","usercomp","ms_compny","ms_center","ms_setpass"]}';
    end if;

    if v_param <> 'null' then
      json_obj_list := json_object_t(v_param);
      array_list := hcm_util.get_array_t(json_obj_list, 'json_list');

      obj_row := json_object_t();

      v_cursor := dbms_sql.open_cursor;
      for i in 0..array_list.get_size - 1 loop
        v_namfld := array_list.get_string(to_char(i));
        v_flgdata := false;
        v_flgdata_user := false;

        begin
          v_stmt := get_commoncode_stmt(v_namfld);
          dbms_sql.parse(v_cursor,v_stmt,dbms_sql.native);
          dbms_sql.define_column(v_cursor,1,v_code,1000);
          dbms_sql.define_column(v_cursor,2,v_labe,1000);
          dbms_sql.define_column(v_cursor,3,v_labt,1000);
          dbms_sql.define_column(v_cursor,4,v_code1,1000);
          dbms_sql.define_column(v_cursor,5,v_code2,1000);
          dbms_sql.define_column(v_cursor,6,v_code3,1000);
          dbms_sql.define_column(v_cursor,7,v_code4,1000);
          dbms_sql.define_column(v_cursor,8,v_code5,1000);
          v_dummy := dbms_sql.execute(v_cursor);
          v_numseq  := 0;

          while dbms_sql.fetch_rows(v_cursor) > 0 loop
            v_flgdata := true;
            v_code := null;  v_labe := null;  v_labt := null;  v_code1 := null;  v_code2 := null;  v_code3 := null;  v_code4 := null;  v_code5 := null;

            dbms_sql.column_value(v_cursor,1,v_code);
            dbms_sql.column_value(v_cursor,2,v_labe);
            dbms_sql.column_value(v_cursor,3,v_labt);
            dbms_sql.column_value(v_cursor,4,v_code1);
            dbms_sql.column_value(v_cursor,5,v_code2);
            dbms_sql.column_value(v_cursor,6,v_code3);
            dbms_sql.column_value(v_cursor,7,v_code4);
            dbms_sql.column_value(v_cursor,8,v_code5);

            -- get password for user
            v_flgdata_user := false;
            if v_namfld = 'user' then
              begin
                select standard_hash(pwddec(v_code1,v_code,global_chken), 'MD5') into v_code1 from dual;
                v_flgdata_user := true;
              exception when others then
               v_code1 := null;
               v_flgdata_user := false;
              end;
            end if;

            if ((v_namfld = 'user' and  v_flgdata_user) or (v_namfld <> 'user')) then
              v_rcnt := v_rcnt + 1;
              v_numseq := v_numseq + 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('namfld',v_namfld);
              obj_data.put('numseq',v_numseq);
              obj_data.put('code',v_code);
              obj_data.put('labe',v_labe);
              obj_data.put('labt',v_labt);
              obj_data.put('code1',v_code1);
              obj_data.put('code2',v_code2);
              obj_data.put('code3',v_code3);
              obj_data.put('code4',v_code4);
              obj_data.put('code5',v_code5);

              obj_row.put(to_char(v_rcnt - 1), obj_data);
            end if;

          end loop;
        exception when others then null;
        end;

        -- put empty row if not have data
        if ((v_namfld = 'user' and not v_flgdata_user) or (v_namfld <> 'user' and not v_flgdata)) then
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('namfld',v_namfld);
          obj_data.put('numseq','0');
          obj_data.put('code','');
          obj_data.put('labe','');
          obj_data.put('labt','');
          obj_data.put('code1','');
          obj_data.put('code2','');
          obj_data.put('code3','');
          obj_data.put('code4','');
          obj_data.put('code5','');

          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
    end if; -- if v_param <> 'null'

    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end get_commoncode;

  function check_blacklist(json_str_input clob) return clob is
    json_str_output clob;
    json_obj        json_object_t;
    json_obj2       json_object_t;
    json_obj_list   json_array_t;
    obj_data        json_object_t;
    v_param         clob;
    v_codempid      varchar2(100 char);
    v_numoffid      varchar2(100 char);
    v_namappl       clob;
    v_inbcklst      number;
    v_message       clob;
    v_message_resp  clob;
    v_count_total   number := 0;
    v_count_bcklst  number := 0;
    v_concat        clob;
    flg_export      varchar2(1 char);
  begin
    json_obj := json_object_t(json_str_input);
    v_param := hcm_util.get_clob_t(json_obj, 'param');

    if v_param <> 'null' or v_param is not null then
      json_obj_list := json_array_t(v_param);
      v_count_total := json_obj_list.get_size;

      for i in 0..json_obj_list.get_size - 1 loop
        json_obj2 := treat (json_obj_list.get(i) as json_object_t);
        v_numoffid  := hcm_util.get_string_t(json_obj2, 'numoffid');
        v_namappl   := hcm_util.get_clob_t(json_obj2, 'namappl');
        global_v_lang   := hcm_util.get_clob_t(json_obj2, 'lang');

        param_detail_remark2 := substr(get_label_name('HRRC2PB0',global_v_lang,501),1,600);
        param_detail_remark5 := substr(get_label_name('HRRC2PB0',global_v_lang,503),1,600);

        begin
          select  count(*) into v_inbcklst
          from    tbcklst
          where   numoffid    = v_numoffid;
        exception when no_data_found then
          v_inbcklst := 0;
        end;

        if v_inbcklst > 0 then
          v_message := param_detail_remark2;
        end if;

        if v_message is null then
          begin
            select a.codempid
              into v_codempid
              from temploy1 a,temploy2 b
             where a.codempid = b.codempid
               and b.numoffid = v_numoffid
               and a.staemp <> '9';
          exception when no_data_found then
            v_codempid := null;
          end;
          if v_codempid is not null then
            v_message := param_detail_remark5;
          end if;
        end if;

        if v_message is not null then
          v_count_bcklst := v_count_bcklst + 1;
          v_message_resp := v_message_resp||v_concat||v_namappl||': '||v_message;
          v_concat       := ', ';
        end if;
      end loop;
    end if;

    flg_export := 'Y';
    if v_count_total = v_count_bcklst then
      flg_export := 'N';
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('message',v_message_resp);
    obj_data.put('flg_export',flg_export);
    obj_data.put('count_total',to_char(v_count_total));
    obj_data.put('count_bcklst',to_char(v_count_bcklst));

    return obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end check_blacklist;

  procedure initial_value is
  begin
    --global
    if substr(to_char(sysdate,'yyyy'),1,2) = '25' then global_v_zyear := 543;
    else
      global_v_zyear := 0;
    end if;
    global_v_coduser  := '';
    global_v_lang     := '102';
    global_chken      := hcm_secur.get_v_chken;
    --params
    param_v_inapplinf   := 0;
    param_v_inbcklst    := 0;
    param_v_chk         := 0;
    param_v_numappl     := '';
    param_v_codpos      := '';

    param_count2        := 0;
    param_count3        := 0;
    param_count4        := 0;
    param_count5        := 0;
    param_count6        := 0;
    param_count7        := 0;
    param_count8        := 0;
    param_count9        := 0;

    param_sub2_json_str := '';
    param_sub3_json_str := '';
    param_sub4_json_str := '';
    param_sub5_json_str := '';
    param_sub6_json_str := '';
    param_sub7_json_str := '';
    param_sub8_json_str := '';
    param_sub9_json_str := '';

    param_flg_tran      := 'N';
    param_flg_error     := 'N';
    param_flg_error1    := 'N';
    param_flg_error2    := 'N';
    param_flg_error3    := 'N';
    param_flg_error4    := 'N';
    param_flg_error5    := 'N';
    param_flg_error6    := 'N';
    param_flg_error7    := 'N';
    param_flg_error8    := 'N';
    param_flg_error9    := 'N';

    param_flg_tran1     := 'N';
    param_flg_tran2     := 'N';
    param_flg_tran3     := 'N';
    param_flg_tran4     := 'N';
    param_flg_tran5     := 'N';
    param_flg_tran6     := 'N';
    param_flg_tran7     := 'N';
    param_flg_tran8     := 'N';
    param_flg_tran9     := 'N';

    param_flg_remark1   := 'N';
    param_flg_remark2   := 'N';
    param_flg_remark3   := 'N';
    param_flg_remark4   := 'N';

    param_flg_success   := 'N';
    param_detail_error1 := '';
    param_detail_error2 := '';
    param_detail_error3 := '';
    param_detail_error4 := '';
    param_detail_error5 := '';
    param_detail_error6 := '';
    param_detail_error7 := '';
    param_detail_error8 := '';
    param_detail_error9 := '';

    param_detail_remark1 := substr(get_label_name('HRRC2PB0',global_v_lang,500),1,600);
    param_detail_remark2 := substr(get_label_name('HRRC2PB0',global_v_lang,501),1,600);
    param_detail_remark3 := substr(get_label_name('HRRC2PB0',global_v_lang,502),1,600);
    param_detail_remark4 := substr(get_label_name('HRRC2PB0',global_v_lang,504),1,600);
    param_detail_remark5 := substr(get_label_name('HRRC2PB0',global_v_lang,503),1,600);
  end;

  function transfer_applicant(json_str_input clob) return clob is
    json_str_output clob;
    json_obj        json_object_t;
    json_obj2       json_object_t;
  begin
    initial_value;

    json_obj    := json_object_t(json_str_input);
    json_obj2   := json_object_t(hcm_util.get_string_t(json_obj, 'json_str'));

    save_applicant(json_obj2);

    return get_resp_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end transfer_applicant;

  procedure save_applicant(json_obj in json_object_t) is
  begin
    conv_appl(json_obj);

    conv_edu(json_obj);
    conv_exp(json_obj);
    conv_train(json_obj);
    conv_spouse(json_obj);
    conv_rel(json_obj);
    conv_ref(json_obj);
    conv_lng(json_obj);
    conv_doc(json_obj);

    check_param_flg_success;

    if param_flg_success = 'Y' then
      commit;
    else
      rollback;
    end if;
  exception when others then
    param_flg_success := 'N';
    param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    param_flg_remark3 := 'Y';
  end save_applicant;

  procedure check_param_flg_success is
  begin
    if (param_flg_error1 = 'Y'   or
        param_flg_error2 = 'Y'   or
        param_flg_error3 = 'Y'   or
        param_flg_error4 = 'Y'   or
        param_flg_error5 = 'Y'   or
        param_flg_error6 = 'Y'   or
        param_flg_error7 = 'Y'   or
        param_flg_error8 = 'Y'   or
        param_flg_error9 = 'Y')  then
      param_flg_error  := 'Y';
      param_flg_tran   := 'N';
    else
      param_flg_tran   := 'Y';
    end if;

    if (param_flg_error   = 'N'  and
        param_flg_remark1 = 'N'  and
        param_flg_remark2 = 'N'  and
        param_flg_remark3 = 'N'  and
        param_flg_remark4 = 'N'  and
        param_flg_tran    = 'Y') then
      param_flg_success := 'Y';
    else
      param_flg_success := 'N';
    end if;
  end check_param_flg_success;

  procedure put_sub_json(p_filenum in number) is
    sub_json_list        json_array_t;
  begin
    check_param_flg_success;
    if p_filenum = 2 then --edu
      if param_count2 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub2_json_str);
      end if;
      sub_json_list.append(param_detail_error2);
      param_sub2_json_str   := sub_json_list.to_clob;
      param_flg_error2      := 'N';
      param_flg_tran2       := 'N';
      param_detail_error2   := '';
    elsif p_filenum = 3 then --exp
      if param_count3 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub3_json_str);
      end if;
      sub_json_list.append(param_detail_error3);
      param_sub3_json_str   := sub_json_list.to_clob;
      param_flg_error3      := 'N';
      param_flg_tran3       := 'N';
      param_detail_error3   := '';
    elsif p_filenum = 4 then --train
      if param_count4 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub4_json_str);
      end if;
      sub_json_list.append(param_detail_error4);
      param_sub4_json_str   := sub_json_list.to_clob;
      param_flg_error4      := 'N';
      param_flg_tran4       := 'N';
      param_detail_error4   := '';
    elsif p_filenum = 5 then --spouse
      if param_count5 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub5_json_str);
      end if;
      sub_json_list.append(param_detail_error5);
      param_sub5_json_str   := sub_json_list.to_clob;
      param_flg_error5      := 'N';
      param_flg_tran5       := 'N';
      param_detail_error5   := '';
    elsif p_filenum = 6 then --rel
      if param_count6 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub6_json_str);
      end if;
      sub_json_list.append(param_detail_error6);
      param_sub6_json_str   := sub_json_list.to_clob;
      param_flg_error6      := 'N';
      param_flg_tran6       := 'N';
      param_detail_error6   := '';
    elsif p_filenum = 7 then --ref
      if param_count7 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub7_json_str);
      end if;
      sub_json_list.append(param_detail_error7);
      param_sub7_json_str   := sub_json_list.to_clob;
      param_flg_error7      := 'N';
      param_flg_tran7       := 'N';
      param_detail_error7   := '';
    elsif p_filenum = 8 then --lng
      if param_count8 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub8_json_str);
      end if;
      sub_json_list.append(param_detail_error8);
      param_sub8_json_str   := sub_json_list.to_clob;
      param_flg_error8      := 'N';
      param_flg_tran8       := 'N';
      param_detail_error8   := '';
    elsif p_filenum = 9 then --doc
      if param_count9 = 1 then
        sub_json_list         := json_array_t();
      else
        sub_json_list         := json_array_t(param_sub9_json_str);
      end if;
      sub_json_list.append(param_detail_error9);
      param_sub9_json_str   := sub_json_list.to_clob;
      param_flg_error9      := 'N';
      param_flg_tran9       := 'N';
      param_detail_error9   := '';
    end if;
  end put_sub_json;

  procedure conv_appl(json_obj in json_object_t) is
    appl_obj          json_object_t;
    personalinfo_obj  json_object_t;
    emppref_obj       json_object_t;
    addinfo_obj       json_object_t;
    appl_arr          arr;

  begin
    appl_obj          := hcm_util.get_json_t(json_obj, 'appl');
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    emppref_obj       := hcm_util.get_json_t(json_obj, 'emppref');
    addinfo_obj       := hcm_util.get_json_t(json_obj, 'addinfo');

    appl_arr(0)  := hcm_util.get_string_t(personalinfo_obj,'id_type');
    if hcm_util.get_string_t(personalinfo_obj,'id_type') = '1' then
      appl_arr(1)  := hcm_util.get_string_t(personalinfo_obj,'id_num');
    else
      appl_arr(1) := '';
    end if;
    appl_arr(2)  := hcm_util.get_string_t(personalinfo_obj,'prefixname');
    appl_arr(3)  := hcm_util.get_string_t(personalinfo_obj,'firstname_th');
    appl_arr(4)  := hcm_util.get_string_t(personalinfo_obj,'lastname_th');
    appl_arr(5)  := hcm_util.get_string_t(personalinfo_obj,'firstname_en');
    appl_arr(6)  := hcm_util.get_string_t(personalinfo_obj,'lastname_en');

    if hcm_util.get_string_t(appl_obj,'apply_dtm') = '0000-00-00 00:00:00' then
      if (hcm_util.get_string_t(appl_obj, 'create_dtm') is not null and (hcm_util.get_string_t(appl_obj, 'create_dtm') != '0000-00-00' and hcm_util.get_string_t(appl_obj, 'create_dtm') != '0000-00-00 00:00:00')) then
        appl_arr(7)  := to_char(to_date(hcm_util.get_string_t(appl_obj,'create_dtm'),'yyyy-mm-dd hh24:mi:ss'),'dd/mm/yyyy');
      else
        appl_arr(7) := '';
      end if;
    else
      if (hcm_util.get_string_t(appl_obj, 'apply_dtm') is not null and (hcm_util.get_string_t(appl_obj, 'apply_dtm') != '0000-00-00' and hcm_util.get_string_t(appl_obj, 'apply_dtm') != '0000-00-00 00:00:00')) then
        appl_arr(7)  := to_char(to_date(hcm_util.get_string_t(appl_obj,'apply_dtm'),'yyyy-mm-dd hh24:mi:ss'),'dd/mm/yyyy');
      else
        appl_arr(7) := '';
      end if;
    end if;

    appl_arr(8)  := hcm_util.get_string_t(appl_obj,'codpos');
    appl_arr(9)  := hcm_util.get_string_t(appl_obj,'codpos2');

    if (hcm_util.get_string_t(personalinfo_obj, 'birthday') is not null and (hcm_util.get_string_t(personalinfo_obj, 'birthday') != '0000-00-00' and hcm_util.get_string_t(personalinfo_obj, 'birthday') != '0000-00-00 00:00:00')) then
      appl_arr(10)  := to_char(to_date(hcm_util.get_string_t(personalinfo_obj,'birthday'),'yyyy-mm-dd'),'dd/mm/yyyy');
    else
      appl_arr(10) := '';
    end if;

    appl_arr(11)  := hcm_util.get_string_t(personalinfo_obj,'gender');
    appl_arr(12)  := hcm_util.get_string_t(personalinfo_obj,'marital_status');
    appl_arr(13)  := hcm_util.get_string_t(personalinfo_obj,'military_status');
    appl_arr(14)  := hcm_util.get_string_t(personalinfo_obj,'nationality');
    appl_arr(15)  := hcm_util.get_string_t(personalinfo_obj,'race');

    if hcm_util.get_string_t(personalinfo_obj,'id_type') = 2 then
      appl_arr(16)  := hcm_util.get_string_t(personalinfo_obj,'id_num');
    else
      appl_arr(16) := '';
    end if;

    appl_arr(17)  := hcm_util.get_string_t(personalinfo_obj,'street_addr');
    appl_arr(18)  := hcm_util.get_string_t(personalinfo_obj,'subdistrict');
    appl_arr(19)  := hcm_util.get_string_t(personalinfo_obj,'district');
    appl_arr(20)  := hcm_util.get_string_t(personalinfo_obj,'province');
    appl_arr(21)  := hcm_util.get_string_t(personalinfo_obj,'country');
    appl_arr(22)  := hcm_util.get_string_t(personalinfo_obj,'post_code');
    appl_arr(23)  := hcm_util.get_string_t(personalinfo_obj,'mobile');
    appl_arr(24)  := hcm_util.get_string_t(personalinfo_obj,'phone');
    appl_arr(25)  := hcm_util.get_string_t(personalinfo_obj,'email');

    appl_arr(26)  := hcm_util.get_string_t(personalinfo_obj,'regis_street_addr');
    appl_arr(27)  := hcm_util.get_string_t(personalinfo_obj,'regis_subdistrict');
    appl_arr(28)  := hcm_util.get_string_t(personalinfo_obj,'regis_district');
    appl_arr(29)  := hcm_util.get_string_t(personalinfo_obj,'regis_province');
    appl_arr(30)  := hcm_util.get_string_t(personalinfo_obj,'regis_country');
    appl_arr(31)  := hcm_util.get_string_t(personalinfo_obj,'regis_post_code');
    appl_arr(32)  := hcm_util.get_string_t(personalinfo_obj,'regis_mobile');
    appl_arr(33)  := hcm_util.get_string_t(personalinfo_obj,'regis_phone');

    appl_arr(34)  := hcm_util.get_string_t(personalinfo_obj,'avatar');
    appl_arr(35)  := hcm_util.get_string_t(personalinfo_obj,'codblood');
    appl_arr(36)  := hcm_util.get_string_t(personalinfo_obj,'weight');
    appl_arr(37)  := hcm_util.get_string_t(personalinfo_obj,'height');
    appl_arr(38)  := hcm_util.get_string_t(personalinfo_obj,'codrelgn');
    appl_arr(39)  := hcm_util.get_string_t(personalinfo_obj,'numwrkprm');
    appl_arr(40)  := hcm_util.get_string_t(personalinfo_obj,'codmedia');
    appl_arr(41)  := hcm_util.get_string_t(personalinfo_obj,'flgcar');
    appl_arr(42)  := hcm_util.get_string_t(personalinfo_obj,'stadisb');
    appl_arr(43)  := hcm_util.get_string_t(personalinfo_obj,'numdisab');
    appl_arr(44)  := hcm_util.get_string_t(personalinfo_obj,'typdisp');

    if (hcm_util.get_string_t(personalinfo_obj, 'dtedisb') is not null and (hcm_util.get_string_t(personalinfo_obj, 'dtedisb') != '0000-00-00' and hcm_util.get_string_t(personalinfo_obj, 'dtedisb') != '0000-00-00 00:00:00')) then
      appl_arr(45)  := to_char(to_date(hcm_util.get_string_t(personalinfo_obj,'dtedisb'),'yyyy-mm-dd'),'dd/mm/yyyy');
    else
      appl_arr(45)  := '';
    end if;
    if (hcm_util.get_string_t(personalinfo_obj, 'dtedisen') is not null and (hcm_util.get_string_t(personalinfo_obj, 'dtedisen') != '0000-00-00' and hcm_util.get_string_t(personalinfo_obj, 'dtedisen') != '0000-00-00 00:00:00')) then
      appl_arr(46)  := to_char(to_date(hcm_util.get_string_t(personalinfo_obj,'dtedisen'),'yyyy-mm-dd'),'dd/mm/yyyy');
    else
      appl_arr(46)  := '';
    end if;
    appl_arr(47)  := hcm_util.get_string_t(personalinfo_obj,'desdisp');

    appl_arr(48)  := hcm_util.get_string_t(emppref_obj,'expct_salary');
    appl_arr(49)  := hcm_util.get_string_t(addinfo_obj,'addinfo');
    appl_arr(50)  := escapenewline(hcm_util.get_string_t(addinfo_obj,'actstudy'));
    appl_arr(51)  := escapenewline(hcm_util.get_string_t(addinfo_obj,'specabi'));
    appl_arr(52)  := escapenewline(hcm_util.get_string_t(addinfo_obj,'compabi'));
    appl_arr(53)  := hcm_util.get_string_t(addinfo_obj,'typthai');
    appl_arr(54)  := hcm_util.get_string_t(addinfo_obj,'typeng');

    appl_arr(55)  := escapenewline(hcm_util.get_string_t(emppref_obj,'objective'));
    appl_arr(56)  := escapenewline(hcm_util.get_string_t(emppref_obj,'jobf'));
    appl_arr(57)  := hcm_util.get_string_t(emppref_obj,'avail');

    if (hcm_util.get_string_t(emppref_obj, 'dtewkst') is not null and (hcm_util.get_string_t(emppref_obj, 'dtewkst') != '0000-00-00' and hcm_util.get_string_t(emppref_obj, 'dtewkst') != '0000-00-00 00:00:00')) then
      appl_arr(58)  := to_char(to_date(hcm_util.get_string_t(emppref_obj,'dtewkst'),'yyyy-mm-dd'),'dd/mm/yyyy');
    else
      appl_arr(58)  := '';
    end if;

    appl_arr(59)  := hcm_util.get_string_t(emppref_obj,'avail_detail');
    appl_arr(60)  := hcm_util.get_string_t(emppref_obj,'codbrlc');
    appl_arr(61)  := hcm_util.get_string_t(emppref_obj,'province');
    appl_arr(62)  := hcm_util.get_string_t(emppref_obj,'country');

    appl_arr(63)  := hcm_util.get_string_t(addinfo_obj,'flgcivil');
    appl_arr(64)  := hcm_util.get_string_t(addinfo_obj,'lastpost');
    appl_arr(65)  := hcm_util.get_string_t(addinfo_obj,'departmn');
    appl_arr(66)  := hcm_util.get_string_t(addinfo_obj,'stamilit');
    appl_arr(67)  := hcm_util.get_string_t(addinfo_obj,'descmilit');
    appl_arr(68)  := hcm_util.get_string_t(addinfo_obj,'flgordan');
    appl_arr(69)  := hcm_util.get_string_t(addinfo_obj,'flgcase');
    appl_arr(70)  := hcm_util.get_string_t(addinfo_obj,'desdisea');
    appl_arr(71)  := hcm_util.get_string_t(addinfo_obj,'dessymp');
    appl_arr(72)  := hcm_util.get_string_t(addinfo_obj,'flgill');
    appl_arr(73)  := hcm_util.get_string_t(addinfo_obj,'desill');
    appl_arr(74)  := hcm_util.get_string_t(addinfo_obj,'flgarres');
    appl_arr(75)  := hcm_util.get_string_t(addinfo_obj,'desarres');
    appl_arr(76)  := hcm_util.get_string_t(addinfo_obj,'flgknow');
    appl_arr(77)  := hcm_util.get_string_t(addinfo_obj,'name');
    appl_arr(78)  := hcm_util.get_string_t(addinfo_obj,'flgappl');
    appl_arr(79)  := hcm_util.get_string_t(addinfo_obj,'lastpos2');
    appl_arr(80)  := escapenewline(hcm_util.get_string_t(addinfo_obj,'hobby'));
    appl_arr(81)  := hcm_util.get_string_t(addinfo_obj,'agewrkmth');
    appl_arr(82)  := hcm_util.get_string_t(addinfo_obj,'agewrkyr');

    appl_arr(83)  := hcm_util.get_string_t(appl_obj,'statappl');
    appl_arr(84)  := hcm_util.get_string_t(appl_obj,'flgqualify');
    appl_arr(85)  := hcm_util.get_string_t(appl_obj,'job_id');
    appl_arr(86)  := hcm_util.get_string_t(appl_obj,'codcomp');
    appl_arr(87)  := hcm_util.get_string_t(appl_obj,'codpos');

    check_appl(appl_arr);
  end conv_appl;

  procedure conv_edu(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    edu_list          json_array_t;
    edu_obj1          json_object_t;
    edu_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    edu_list := json_array_t(hcm_util.get_array_t(json_obj, 'edu'));

    for i in 0..edu_list.get_size-1 loop
      param_count2 := param_count2 + 1;

      edu_obj1    := treat (edu_list.get(i) as json_object_t);

      edu_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      edu_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      edu_arr(2)  := hcm_util.get_string_t(edu_obj1, 'set_id');
      edu_arr(3)  := hcm_util.get_string_t(edu_obj1, 'country');
      edu_arr(4)  := hcm_util.get_string_t(edu_obj1, 'institute');
      edu_arr(5)  := hcm_util.get_string_t(edu_obj1, 'education');
      edu_arr(6)  := hcm_util.get_string_t(edu_obj1, 'degree');
      edu_arr(7)  := hcm_util.get_string_t(edu_obj1, 'faculty');
      edu_arr(8)  := hcm_util.get_string_t(edu_obj1, 'subject');
      edu_arr(9)  := hcm_util.get_string_t(edu_obj1, 'gpa');
      edu_arr(10) := hcm_util.get_string_t(edu_obj1, 'edu_from');
      edu_arr(11) := hcm_util.get_string_t(edu_obj1, 'edu_to');

      check_edu(edu_arr);
      put_sub_json(2);
    end loop;
  end conv_edu;

  procedure conv_exp(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    exp_list          json_array_t;
    exp_obj1          json_object_t;
    exp_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    exp_list := json_array_t(hcm_util.get_array_t(json_obj, 'exp'));

    for i in 0..exp_list.get_size-1 loop
      param_count3 := param_count3 + 1;

      exp_obj1    := treat (exp_list.get(i) as json_object_t);

      exp_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      exp_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      exp_arr(2)  := hcm_util.get_string_t(exp_obj1, 'set_id');
      exp_arr(3)  := hcm_util.get_string_t(exp_obj1, 'company');
      exp_arr(4)  := hcm_util.get_string_t(exp_obj1, 'country');
      exp_arr(5)  := hcm_util.get_string_t(exp_obj1, 'biztype');
      exp_arr(6)  := hcm_util.get_string_t(exp_obj1, 'position');
      if (hcm_util.get_string_t(exp_obj1, 'emp_from') is not null and (hcm_util.get_string_t(exp_obj1, 'emp_from') != '0000-00-00' and hcm_util.get_string_t(exp_obj1, 'emp_from') != '0000-00-00 00:00:00')) then
        exp_arr(7)  := to_char(to_date(hcm_util.get_string_t(exp_obj1, 'emp_from'),'yyyy-mm-dd'),'dd/mm/yyyy');
      else
        exp_arr(7)  := '';
      end if;
      if (hcm_util.get_string_t(exp_obj1, 'emp_to') is not null and (hcm_util.get_string_t(exp_obj1, 'emp_to') != '0000-00-00' and hcm_util.get_string_t(exp_obj1, 'emp_to') != '0000-00-00 00:00:00')) then
        exp_arr(8)  := to_char(to_date(hcm_util.get_string_t(exp_obj1, 'emp_to'),'yyyy-mm-dd'),'dd/mm/yyyy');
      else
        exp_arr(8)  := '';
      end if;
      exp_arr(9)  := hcm_util.get_string_t(exp_obj1, 'salary');
      exp_arr(10) := hcm_util.get_string_t(exp_obj1, 'currency');
      exp_arr(11) := escapenewline(hcm_util.get_string_t(exp_obj1, 'duty_achieve'));

      check_exp(exp_arr);
      put_sub_json(3);
    end loop;
  end conv_exp;

  procedure conv_train(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    train_list        json_array_t;
    train_obj1        json_object_t;
    train_arr         arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    train_list := json_array_t(hcm_util.get_array_t(json_obj, 'train'));

    for i in 0..train_list.get_size-1 loop
      param_count4 := param_count4 + 1;

      train_obj1    := treat (train_list.get(i) as json_object_t);

      train_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      train_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      train_arr(2)  := hcm_util.get_string_t(train_obj1, 'set_id');
      train_arr(3)  := hcm_util.get_string_t(train_obj1, 'destrain');
      if (hcm_util.get_string_t(train_obj1, 'dtetrain') is not null and (hcm_util.get_string_t(train_obj1, 'dtetrain') != '0000-00-00' and hcm_util.get_string_t(train_obj1, 'dtetrain') != '0000-00-00 00:00:00')) then
        train_arr(4)  := to_char(to_date(hcm_util.get_string_t(train_obj1, 'dtetrain'),'yyyy-mm-dd'),'dd/mm/yyyy');
      else
        train_arr(4)  := '';
      end if;
      if (hcm_util.get_string_t(train_obj1, 'dtetren') is not null and (hcm_util.get_string_t(train_obj1, 'dtetren') != '0000-00-00' and hcm_util.get_string_t(train_obj1, 'dtetren') != '0000-00-00 00:00:00')) then
        train_arr(5)  := to_char(to_date(hcm_util.get_string_t(train_obj1, 'dtetren'),'yyyy-mm-dd'),'dd/mm/yyyy');
      else
        train_arr(5)  := '';
      end if;
      train_arr(6)  := hcm_util.get_string_t(train_obj1, 'desplace');
      train_arr(7)  := hcm_util.get_string_t(train_obj1, 'desinstu');

      check_train(train_arr);
      put_sub_json(4);
    end loop;
  end conv_train;

  procedure conv_spouse(json_obj in json_object_t) is
    personalinfo_obj   json_object_t;
    spouse_list        json_array_t;
    spouse_obj1        json_object_t;
    spouse_arr         arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    spouse_list := json_array_t(hcm_util.get_array_t(json_obj, 'spouse'));

    for i in 0..spouse_list.get_size-1 loop
      param_count5 := param_count5 + 1;

      spouse_obj1    := treat (spouse_list.get(i) as json_object_t);

      spouse_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      spouse_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      spouse_arr(2)  := hcm_util.get_string_t(spouse_obj1, 'codtitle');
      spouse_arr(3)  := hcm_util.get_string_t(spouse_obj1, 'namfirst');
      spouse_arr(4)  := hcm_util.get_string_t(spouse_obj1, 'namlast');
      spouse_arr(5)  := hcm_util.get_string_t(spouse_obj1, 'numoffid');
      spouse_arr(6)  := hcm_util.get_string_t(spouse_obj1, 'stalife');
      spouse_arr(7)  := hcm_util.get_string_t(spouse_obj1, 'desnoffi');
      spouse_arr(8)  := hcm_util.get_string_t(spouse_obj1, 'codspocc');

      check_spouse(spouse_arr);
      put_sub_json(5);
    end loop;
  end conv_spouse;

  procedure conv_rel(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    rel_list          json_array_t;
    rel_obj1          json_object_t;
    rel_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    rel_list := json_array_t(hcm_util.get_array_t(json_obj, 'rel'));

    for i in 0..rel_list.get_size-1 loop
      param_count6 := param_count6 + 1;

      rel_obj1    := treat (rel_list.get(i) as json_object_t);

      rel_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      rel_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      rel_arr(2)  := hcm_util.get_string_t(rel_obj1, 'set_id');
      rel_arr(3)  := hcm_util.get_string_t(rel_obj1, 'namrel');
      rel_arr(4)  := hcm_util.get_string_t(rel_obj1, 'numtelec');
      rel_arr(5)  := hcm_util.get_string_t(rel_obj1, 'adrcomt');

      check_rel(rel_arr);
      put_sub_json(6);
    end loop;
  end conv_rel;

  procedure conv_ref(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    ref_list          json_array_t;
    ref_obj1          json_object_t;
    ref_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    ref_list := json_array_t(hcm_util.get_array_t(json_obj, 'ref'));

    for i in 0..ref_list.get_size-1 loop
      param_count7 := param_count7 + 1;

      ref_obj1    := treat (ref_list.get(i) as json_object_t);

      ref_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      ref_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      ref_arr(2)  := hcm_util.get_string_t(ref_obj1, 'set_id');
      ref_arr(3)  := hcm_util.get_string_t(ref_obj1, 'codtitle');
      ref_arr(4)  := nvl(hcm_util.get_string_t(ref_obj1, 'namfirste'),hcm_util.get_string_t(ref_obj1, 'namfirstt'));
      ref_arr(5)  := hcm_util.get_string_t(ref_obj1, 'namfirstt');
      ref_arr(6)  := nvl(hcm_util.get_string_t(ref_obj1, 'namlaste'),hcm_util.get_string_t(ref_obj1, 'namlastt'));
      ref_arr(7)  := hcm_util.get_string_t(ref_obj1, 'namlastt');
      ref_arr(8)  := hcm_util.get_string_t(ref_obj1, 'flgref');
      ref_arr(9)  := hcm_util.get_string_t(ref_obj1, 'despos');
      ref_arr(10)  := hcm_util.get_string_t(ref_obj1, 'adrcont1');
      ref_arr(11)  := hcm_util.get_string_t(ref_obj1, 'desnoffi');
      ref_arr(12)  := hcm_util.get_string_t(ref_obj1, 'numtele');
      ref_arr(13)  := hcm_util.get_string_t(ref_obj1, 'email');

      check_ref(ref_arr);
      put_sub_json(7);
    end loop;
  end conv_ref;

  procedure conv_lng(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    lng_list          json_array_t;
    lng_obj1          json_object_t;
    lng_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    lng_list := json_array_t(hcm_util.get_array_t(json_obj, 'lng'));

    for i in 0..lng_list.get_size-1 loop
      param_count8 := param_count8 + 1;

      lng_obj1    := treat (lng_list.get(i) as json_object_t);

      lng_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      lng_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      lng_arr(2)  := hcm_util.get_string_t(lng_obj1, 'set_id');
      lng_arr(3)  := hcm_util.get_string_t(lng_obj1, 'codlang');
      lng_arr(4)  := hcm_util.get_string_t(lng_obj1, 'flglist');
      lng_arr(5)  := hcm_util.get_string_t(lng_obj1, 'flgspeak');
      lng_arr(6)  := hcm_util.get_string_t(lng_obj1, 'flgread');
      lng_arr(7)  := hcm_util.get_string_t(lng_obj1, 'flgwrite');

      check_lng(lng_arr);
      put_sub_json(8);
    end loop;
  end conv_lng;

  procedure conv_doc(json_obj in json_object_t) is
    personalinfo_obj  json_object_t;
    doc_list          json_array_t;
    doc_obj1          json_object_t;
    doc_arr           arr;
  begin
    personalinfo_obj  := hcm_util.get_json_t(json_obj, 'personalinfo');
    doc_list := json_array_t(hcm_util.get_array_t(json_obj, 'doc'));

    for i in 0..doc_list.get_size-1 loop
      param_count9 := param_count9 + 1;

      doc_obj1    := treat (doc_list.get(i) as json_object_t);

      doc_arr(0)  := hcm_util.get_string_t(personalinfo_obj, 'id_type');
      doc_arr(1)  := hcm_util.get_string_t(personalinfo_obj, 'id_num');
      doc_arr(2)  := hcm_util.get_string_t(doc_obj1, 'set_id');
      doc_arr(3)  := hcm_util.get_string_t(doc_obj1, 'namdoc');
      doc_arr(4)  := hcm_util.get_string_t(doc_obj1, 'typdoc');
      doc_arr(5)  := hcm_util.get_string_t(doc_obj1, 'flgresume');
      doc_arr(6)  := hcm_util.get_string_t(doc_obj1, 'filedoc');
      doc_arr(7)  := hcm_util.get_string_t(doc_obj1, 'desnote');

      check_doc(doc_arr);
      put_sub_json(9);
    end loop;
  end conv_doc;

  function escapenewline(v_str in varchar2) return varchar2 is
    v_str2 varchar2(4000 char);
  begin
    v_str2 := v_str;
    v_str2 := replace(v_str2, '"\n"', '''\n''');
    v_str2 := replace(v_str2, '"\r"', '''\r''');
    v_str2 := replace(v_str2, '"\r\n"', '''\r\n''');
    v_str2 := replace(v_str2, '"\n\r"', '''\n\r''');
    v_str2 := replace(v_str2, chr(10), '');
    return v_str2;
  end escapenewline;

  function change_date(p_date in varchar2) return date is
    v_year  varchar2(4 char);
    v_year1 number;
    v_date  date;
  begin
    begin
       v_year    := substr(p_date,-4);
       v_year1   := to_number(v_year);
       if  v_year1 > 0 then
           v_year   := to_char(to_number(v_year) + global_v_zyear);
           v_date   := to_date(substr(p_date,1,length(p_date)-4)||v_year,'dd/mm/yyyy');
           return v_date;
       else
           return null;
       end if;
    exception when others then
       return null;
    end ;
  end change_date;

  function chk_import(p_group varchar2,p_id_type varchar2,p_numoffid varchar2, p_dteapplac date) return varchar2 IS
  begin
	if p_group = 'appl' then
	    begin
	      select  count(*) into param_v_inapplinf
	      from    tapplinf
	      where   numoffid    = p_numoffid
	      and     codpos1     = param_v_codpos;
	--      and     statappl    not in  ('10','22','32','42','53','54','62','63');
	    exception when no_data_found then
	      param_v_inapplinf := 0;
	    end;
	end if;

    begin
      select  count(*) into param_v_inbcklst
      from    tbcklst
      where   numoffid    = p_numoffid
        and   p_id_type   = '1';
    exception when no_data_found then
      param_v_inbcklst := 0;
    end;

    begin
      select  count(*) into param_v_chk
      from    tapplinf
      where   numoffid    =   p_numoffid
      and     codpos1     =   param_v_codpos
      and     statappl    in  ('10', '21', '22','32','42','53','54','62','63')
--      and     dteappl     <>  p_dteapplac
      ;
    exception when no_data_found then
      param_v_chk   := 0;
    end;

    if (param_v_inapplinf = 0 or param_v_chk > 0) and param_v_inbcklst = 0 then
      return 'Y';
    else
      return 'N';
    end if;
  end chk_import;

  function chk_import_sub(p_id_type varchar2,p_numoffid varchar2, p_dteapplac date) return varchar2 IS
  begin
    begin
      select  numappl into   param_v_numappl
      from    tapplinf
      where   numoffid    =   p_numoffid
      and     codpos1     =   param_v_codpos;
    exception when no_data_found then
      param_v_numappl := null;
    end;

    if param_v_numappl is not null then
      return 'Y';
    else
      return 'N';
    end if;
  end chk_import_sub;

  function gen_id
    (p_dteyear in number,
     p_typgen  in varchar2,
     p_length  in number,
     p_table   in varchar2,
     p_column  in varchar2) return varchar2 is

    v_year      number;
    v_typfix    tlastid.typfix%type;
    v_codfix    tlastid.codfix%type;
    v_seqno     tlastid.seqno%type;
    v_id        varchar2(20 char);
    v_stmt      varchar2(200 char);
    v_length  number;
  begin
      begin
        select  typfix,codfix,seqno
        into    v_typfix,v_codfix,v_seqno
        from    tlastid
        where   dteyear = (select max(dteyear)
                         from   tlastid
                         where  dteyear <= p_dteyear
                         and        typgen   = p_typgen)
        and         typgen  = p_typgen;
      exception when no_data_found then
        v_typfix := '1';
        v_seqno  := null ;
      end;
      v_length := length(v_seqno);
      v_year     := p_dteyear + 543;
      if nvl(v_length,0) = 0 then
         if p_typgen = 'R' then
            v_length := 4 ;
         else
            v_length := 6 ;
         end if;
      end if;
      loop
            v_seqno := nvl(to_number(v_seqno),0) + 1;
            v_seqno := lpad(v_seqno,v_length,'0');
          if v_typfix = '1' then
            v_id    := substr(v_year,3,2)||v_seqno;
          else
            v_id    := v_codfix||v_seqno;
          end if;
          v_stmt := 'select count(*) from '||p_table||' where '||p_column||' = '''||v_id||'''';
          if not execute_stmt(v_stmt) then
            return(v_id);
          end if;
        end loop;
  end gen_id;

  function gen_detail_error
    (p_value    in varchar2,
     p_table    in varchar2,
     p_column   in varchar2,
     p_mode     in varchar2,
     p_table_setup in varchar2 default null
     ) return varchar2 is

    v_comments varchar2(4000);
    v_tmp      varchar2(4000);
  begin
    begin
      select decode(global_v_lang,'101',descripe,'102',descript,'103',descrip3,'104',descrip4,'105',descrip5)
      into    v_tmp
      from   terrorm
      where  errorno = decode(length(p_mode),6,p_mode, --length=6 char where directly, otherwise, by mode
             --<<User37 STA4 19/07/2018
             --decode(p_mode,'1','HR2045','2','HR2010','3','HR2060','4','HR2020','5','HR2024','6','HR2075','7','HR2057','9','xxxxxx'));
             decode(p_mode,'1','HR2045','2','HR2010','3','HR2060','4','HR2020','5','HR2024','6','HR2075','7','HR2057','8','HR6591','9','xxxxxx'));
             -->>User37 STA4 19/07/2018
    exception when no_data_found then
      v_tmp := null;
    end;

    begin
      select comments
      into    v_comments
      from   user_col_comments
      where  table_name  = upper(p_table)
      and    column_name = upper(p_column);
    exception when no_data_found then
      v_comments := upper(p_column);
    end;

    v_comments := replace(v_comments,',',' | ');

    --<<User37 STA4 17/07/2018
    /*if p_mode = '2' then
      v_tmp := p_value||' '||v_comments||' '||v_tmp||'('||p_table_setup||')';
    else
      v_tmp := p_value||' '||v_comments||' '||v_tmp;--||' ('||p_table||'.'||p_column||')';
    end if;*/
    if p_mode = '2' then
      v_tmp := v_comments||' '||v_tmp||'('||p_table_setup||')';
    else
      v_tmp := v_comments||' '||v_tmp;--||' ('||p_table||'.'||p_column||')';
    end if;
    -->>User37 STA4 17/07/2018

    if p_mode = '7' then
      return v_tmp;
    elsif nvl(v_tmp,'xyz') <> 'xyz' then
      return v_tmp||',';
    else
      return '';
    end if;
  end gen_detail_error;

  function check_data_struc
    (p_value     varchar2,
     p_table    in varchar2,
     p_column   in varchar2,
     p_data_type  in varchar2,
     p_data_length in number
     ) RETURN varchar2 IS

     v_type     varchar2(200);
     v_length   number;
     v_scale    number;
     v_message  varchar2(4000) := '';
     v_chk      boolean;
     v_value_num  varchar2(1000);
     j number;
  begin
    begin
      select data_type, decode(p_data_type,'NUMBER',nvl(data_precision,9999),'DATE',8/*avg_col_len*/,char_length), data_scale
      into    v_type, v_length, v_scale
      from   user_tab_columns
      where  table_name  = upper(p_table)
      and    column_name = upper(p_column);
    exception when no_data_found then
      v_type := null; v_length := 0; v_scale := 0;
    end;

    --data type--
    if p_data_type = 'VARCHAR2' then -- VARCHAR2, to check with user_tab_columns directly
      if p_data_type <> v_type then -- data type mismatch
        v_message := gen_detail_error(p_value,p_table,p_column,'4');
      end if;
    elsif p_data_type = 'NUMBER' then
      v_value_num := trim(ltrim(replace(p_value,','),'0'));
      if check_number(v_value_num) then
        v_message := gen_detail_error(p_value,p_table,p_column,'4');
      end if;
    elsif p_data_type = 'DATE' then
      if check_date(p_value,global_v_zyear) then
        v_message := gen_detail_error(p_value,p_table,p_column,'4');
      end if;
    elsif p_data_type = 'TIME' then
      if check_time(p_value) then
        v_message := gen_detail_error(p_value,p_table,p_column,'4');
      end if;
    end if;

    --data length--
    if not check_number(v_value_num) and p_data_type = 'NUMBER' then
      if instr(v_value_num,'.') <> 0 then -- number have .
        if (length(substr(v_value_num,1,instr(v_value_num,'.')-1)) + length(trim(rtrim(substr(v_value_num,instr(v_value_num,'.')+1),'0'))) > v_length
        or length(trim(rtrim(substr(v_value_num,instr(v_value_num,'.')+1),'0'))) > v_scale) then
          v_message := v_message ||' '|| substr(gen_detail_error(p_value,p_table,p_column,'3'),1,length(gen_detail_error(p_value,p_table,p_column,'3'))-1);
        else
          v_message := substr(v_message,1,length(v_message)-1);
        end if;

      else -- number not have .
        if (length(v_value_num)) > v_length then  -- data precision length over
          v_message := v_message ||' '|| substr(gen_detail_error(p_value,p_table,p_column,'3'),1,length(gen_detail_error(p_value,p_table,p_column,'3'))-1);
        else
          v_message := substr(v_message,1,length(v_message)-1);
        end if;
      end if;
    elsif p_data_type = 'DATE' then
      if length(replace(p_value,'/')) > v_length then -- cut / in date data, 2 characters
        v_message := v_message ||' '|| substr(gen_detail_error(p_value,p_table,p_column,'3'),1,length(gen_detail_error(p_value,p_table,p_column,'3'))-1);
      else
        v_message := substr(v_message,1,length(v_message)-1);
      end if;
    else
      if p_data_length > v_length then -- data length over
        v_message := v_message ||' '|| substr(gen_detail_error(p_value,p_table,p_column,'3'),1,length(gen_detail_error(p_value,p_table,p_column,'3'))-1);
      else
        v_message := substr(v_message,1,length(v_message)-1);
      end if;
    end if;

    --summary message--
    if nvl(v_message,'xyz') <> 'xyz' then
      if v_length = 9999 or p_data_type = 'DATE' then
        return v_message||' ['||v_type||'],';
      elsif v_scale > 0 then
        return v_message||' ['||v_type||'('||v_length||'-'||v_scale||')],';
      else  --p_data_type = 'VARCHAR2', 'NUMBER' lenght (X)
        return v_message||' ['||v_type||'('||v_length||')],';
      end if;
    else
      return '';
    end if;
  end check_data_struc;

  function check_number(p_number in varchar2) return boolean IS
    v_number  number;
    v_error   boolean := false;
  begin
    if p_number is not null then
      begin
        v_number := to_number(p_number);
        v_error := false;
      exception when others then
        v_error := true;
      end;
    end if;
    return(v_error);
  end check_number;

  function check_date (p_date in varchar2, p_zyear in number) return boolean IS
    v_date    date;
    v_error   boolean := false;
    v_year    number;
    v_daymon  varchar2(30);
    v_text    varchar2(30);
  begin
    begin
      if p_date is not null then
        -- Plus Year --
          v_year      := substr(p_date,-4,4);
          v_year      := v_year + p_zyear;
          v_daymon    := substr(p_date,1,length(p_date)-4);
          v_text    := to_char(v_daymon||v_year);
          v_year := null; v_daymon := null;
        -- Plus Year --

        begin
          v_date := to_date(v_text,'dd/mm/yyyy');
          v_error := false;
        exception when others then
          v_error := true;
        end;
      end if;
    exception when others then
      v_error := true;
    end;
    return(v_error);
  end check_date;

  function check_time(p_time in varchar2) return boolean IS
    v_time    date;
    v_error   boolean := false;
  begin
    if p_time is not null then
      begin
        v_time := to_date(p_time,'hh24mi');
        v_error := false;
      exception when others then
        v_error := true;
      end;
    end if;
    return(v_error);
  end check_time;

  procedure check_update (p_numofid in varchar2,p_onumappl out varchar2) is
    v_exist     number:=0;
    v_numappl   varchar2(100 char):='NO_DATA';

    cursor c1 is
      select  numappl
      from    tapplinf
      where   numoffid    =   p_numofid
      and     codpos1     =   param_v_codpos;
  begin
    for i in c1 loop
        v_numappl   :=  i.numappl;
    end loop;
    p_onumappl  := v_numappl;
  end check_update;

  procedure upd_id
  (p_dteyear in number,
   p_typgen  in varchar2,
   p_code      in varchar2,
   p_coduser in varchar2) is

  v_exist     boolean;
  v_typfix    tlastid.typfix%type;
  v_codfix    tlastid.codfix%type;
  v_length  number;
  v_pos     number;
  v_seqno     tlastid.seqno%type;
  v_year    varchar2(4 char);

  cursor c_tlastid is
  select  rowid,codfix
  from    tlastid
  where   dteyear = p_dteyear
  and     typgen  = p_typgen;

  begin
    v_exist := false;
    for r_tlastid in c_tlastid loop
      v_exist := true;
      v_seqno := substr(p_code,nvl(length(r_tlastid.codfix),0)+1);
      update tlastid
      set seqno   = v_seqno ,
          dteupd  = trunc(sysdate),
          coduser = p_coduser
      where rowid = r_tlastid.rowid;
    end loop;

    if not v_exist then
      begin
        select  typfix,codfix
        into    v_typfix,v_codfix
        from    tlastid
        where   dteyear = (select max(dteyear)
                         from   tlastid
                         where  dteyear <= p_dteyear
                         and        typgen   = p_typgen)
        and         typgen  = p_typgen;
      exception when no_data_found then
        v_typfix := '1';
        v_year   := p_dteyear + 543;
        v_codfix := substr(v_year,3,2);
      end;
      v_seqno := substr(p_code,length(v_codfix)+1);
      insert into tlastid
        (dteyear,typgen,typfix,codfix,seqno,
         dteupd,coduser)
      values
        (p_dteyear,p_typgen,v_typfix,v_codfix,v_seqno,
         trunc(sysdate),p_coduser);
    end if;
  end upd_id;

  procedure check_appl(appl_arr in arr) is
    v_detail    varchar2(4000);
    v_error     boolean;
    v_id_type   varchar2(100);
    v_numoffid  varchar2(100);
    v_dteapplac date;

  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf := 0;
    param_v_inbcklst  := 0;
    param_v_chk       := 0;
    param_v_codpos    := appl_arr(8);
    v_id_type     := upper(trim(appl_arr(0)));
    v_numoffid    := upper(trim(appl_arr(1)));
    v_numoffid    := upper(rpad(v_numoffid,13,'0'));
    v_dteapplac   := change_date(appl_arr(7));

    if chk_import('appl', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tapplinf(appl_arr, v_detail) ;

      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1);
      end if;

      if v_error then
        param_flg_error1 := 'Y';
        param_detail_error1   := substr(v_detail,1,4000);
      else
        param_flg_tran1 := 'Y';
        save_appl(appl_arr,v_numoffid,v_dteapplac);
      end if; -- not error
    else --chk_import = 'N'
      if nvl(param_v_inapplinf,0) <> 0 or nvl(param_v_inbcklst,0) <> 0 then
        if nvl(param_v_inapplinf,0) <> 0 then
          param_flg_remark1 := 'Y';
        end if;

        if nvl(param_v_inbcklst,0) <> 0 then
          param_flg_remark2 := 'Y';
        end if;
      end if;
    end if; --chk_import = 'Y'
  end check_appl;

  procedure check_error_tapplinf(appl_arr arr, o_error out varchar2) IS
    i               number := 0;
    j               number ;
    v_table         varchar2(100 char);
    v_error         varchar2(4000 char) := null;
    v_code          varchar2(1000 char) := null;
  begin
    v_table := 'TAPPLINF';
    --start check data section--
    i := i+1; --appl_arr(1)

    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMOFFID','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMOFFID','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(2)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODTITLE','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODTITLE','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = appl_arr(i)
        and    codapp = 'CODTITLE';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODTITLE','2','TLISTVAL');
      end;
    end if;

    i := i+1; --appl_arr(3)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMFIRSTT','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAMFIRSTT','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(4)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMLASTT','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAMLASTT','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(5)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMFIRSTE','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAMFIRSTE','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(6)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMLASTE','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAMLASTE','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(7)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTEAPPL','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DTEAPPL','DATE',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(8)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODPOS1','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPOS1','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codpos into v_code
        from   tpostn
        where  codpos = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPOS1','2','TPOSTN');
      end;
    end if;

    i := i+1; --appl_arr(9)
    if appl_arr(i) is null then
--      v_error := v_error||gen_detail_error('NULL',v_table,'CODPOS2','1');
      null;
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPOS2','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codpos into v_code
        from   tpostn
        where  codpos = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPOS2','2','TPOSTN');
      end;
    end if;

    i := i+1; --appl_arr(10)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTEEMPDB','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DTEEMPDB','DATE',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(11)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODSEX','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('M','F') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODSEX','7')||' "M" or "F",';
      end if;
    end if;

    i := i+1; --appl_arr(12)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'STAMARRY','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'STAMARRY','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = appl_arr(i)
        and    codapp = 'NAMMARRY';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'STAMARRY','2','TLISTVAL');
      end;
    end if;

    i := i+1; --appl_arr(13)
    if appl_arr(i-2) = 'M' and appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'STAMILIT','1');
    elsif appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'STAMILIT','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = appl_arr(i)
        and    codapp = 'NAMMILIT';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'STAMILIT','2','TLISTVAL');
      end;
    end if;

    i := i+1; --appl_arr(14)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODNATNL','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODNATNL','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODNATN
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODNATNL','2','TCODNATN');
      end;
    end if;

    i := i+1; --appl_arr(15)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODORGIN','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODORGIN','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODREGN
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODORGIN','2','TCODREGN');
      end;
    end if;

    i := i+1; --appl_arr(16)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMPASID','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(17)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'ADRCONTT','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'ADRCONTT','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(18)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODSUBDISTC','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codsubdist into v_code
        from   tsubdist
        where  codprov    = appl_arr(i+2)
        and    coddist    = appl_arr(i+1)
        and    codsubdist = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODSUBDISTC','2','TSUBDIST');
      end;
    end if;

    i := i+1; --appl_arr(19)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODDISTC','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select coddist into v_code
        from   tcoddist
        where  codprov = appl_arr(i+1)
        and    coddist = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODDISTC','2','TCODDIST');
      end;
    end if;

    i := i+1; --appl_arr(20)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPROVC','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodprov
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPROVC','2','TCODPROV');
      end;
    end if;

    i := i+1; --appl_arr(21)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODCNTYC','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODCNTYC','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODCNTY
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODCNTYC','2','TCODCNTY');
      end;
    end if;

    i := i+1; --appl_arr(22)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPOSTC','NUMBER',length(appl_arr(i)));

      if length(appl_arr(i)) > 5 then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPOSTC','3');
      end if;
    end if;

    i := i+1; --appl_arr(23)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMTELEM','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMTELEM','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(24)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMTELEH','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(25)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'EMAIL','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'EMAIL','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(26)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'ADRREGT','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'ADRREGT','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(27)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODSUBDISTR','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codsubdist into v_code
        from   tsubdist
        where  codprov    = appl_arr(i+2)
        and    coddist    = appl_arr(i+1)
        and    codsubdist = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODSUBDISTR','2','TSUBDIST');
      end;
    end if;

    i := i+1; --appl_arr(28)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODDISTR','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select coddist into v_code
        from   tcoddist
        where  codprov = appl_arr(i+1)
        and    coddist = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODDISTR','2','TCODDIST');
      end;
    end if;

    i := i+1; --appl_arr(29)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPROVR','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodprov
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPROVR','2','TCODPROV');
      end;
    end if;

    i := i+1; --appl_arr(30)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODCNTYI','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODCNTYI','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODCNTY
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODCNTYI','2','TCODCNTY');
      end;
    end if;

    i := i+1; --appl_arr(31)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODPOSTE','NUMBER',length(appl_arr(i)));

      if length(appl_arr(i)) > 5 then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODPOSTE','3');
      end if;
    end if;

    i := i+1; --appl_arr(32)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMTELEMR','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMTELEMR','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(33)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMTELEHR','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(34) avatar
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAMIMAGE','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(35)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODBLOOD','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(36)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'WEIGHT','NUMBER',length(appl_arr(i)));

      if not(check_number(appl_arr(i))) then
        if to_number(appl_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'WEIGHT','5');
        end if;
      end if;
    end if;

    i := i+1; --appl_arr(37)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'HEIGHT','NUMBER',length(appl_arr(i)));

      if not(check_number(appl_arr(i))) then
        if to_number(appl_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'HEIGHT','5');
        end if;
      end if;
    end if;

    i := i+1; --appl_arr(38)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODRELGN','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodreli
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODRELGN','2','TCODRELI');
      end;
    end if;

    i := i+1; --appl_arr(39)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMPRMID','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(40)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODMEDIA','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodmedi
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODMEDIA','2','TCODMEDI');
      end;
    end if;

    i := i+1; --appl_arr(41)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGCAR','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGCAR','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(42)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'STADISB','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'STADISB','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(43)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NUMDISAB','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(44)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'TYPDISP','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcoddisp
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'TYPDISP','2','TCODDISP');
      end;
    end if;

    i := i+1; --appl_arr(45)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DTEDISB','DATE',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(46)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DTEDISEN','DATE',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(47)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESDISP','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(48)
    if appl_arr(i) is not null then
      v_error := v_error||replace(check_data_struc(appl_arr(i),v_table,'AMTINCFM','NUMBER',length(appl_arr(i))),'VARCHAR2','NUMBER');

      if not(check_number(appl_arr(i))) then
        if to_number(appl_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'AMTINCFM','5');
        end if;
        if to_number(appl_arr(i)) > 9999999.99 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'AMTINCFM','8');
        end if;
      end if;
    end if;

    i := i+1; --appl_arr(49)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'ADDINFO','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(50)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'ACTSTUDY','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(51)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'SPECABI','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(52)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'COMPABI','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(53)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'TYPTHAI','NUMBER',length(appl_arr(i)));

      if not(check_number(appl_arr(i))) then
        if to_number(appl_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'TYPTHAI','5');
        end if;
      end if;
    end if;

    i := i+1; --appl_arr(54)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'TYPENG','NUMBER',length(appl_arr(i)));

      if not(check_number(appl_arr(i))) then
        if to_number(appl_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(appl_arr(i),v_table,'TYPENG','5');
        end if;
      end if;
    end if;

    --TAPPLOTH
    v_table := 'TAPPLOTH';
    i := i+1; --appl_arr(55)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'REASON','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(56)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'JOBDESC','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(57)
    if appl_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'FLGSTRWK','1');
    else
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGSTRWK','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('1','2','3') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGSTRWK','7')||' "1" or "2" or "3",';
      end if;
    end if;

    i := i+1; --appl_arr(58)
    if appl_arr(i-1) = '2' then
      if appl_arr(i) is null then
        v_error := v_error||gen_detail_error('NULL',v_table,'DTEWKST','1');
      else
        v_error := v_error||check_data_struc(appl_arr(i),v_table,'DTEWKST','DATE',length(appl_arr(i)));
      end if;
    end if;

    i := i+1; --appl_arr(59)
    if appl_arr(i-2) = '3' then
      if appl_arr(i) is null then
        v_error := v_error||gen_detail_error('NULL',v_table,'QTYDAYST','1');
      else
        v_error := v_error||check_data_struc(appl_arr(i),v_table,'QTYDAYST','NUMBER',length(appl_arr(i)));

        if not(check_number(appl_arr(i))) then
          if to_number(appl_arr(i)) < 0 then
            v_error := v_error||gen_detail_error(appl_arr(i),v_table,'QTYDAYST','5');
          end if;
        end if;
      end if;
    end if;

    i := i+1; --appl_arr(60)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'CODLOCAT','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodloca
        where  codcodec = appl_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'CODLOCAT','2','TCODLOCA');
      end;
    end if;

    i := i+1; --appl_arr(61)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGPROV','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = appl_arr(i)
        and    codapp = 'FLGPROV';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGPROV','2','TLISTVAL');
      end;
    end if;

    i := i+1; --appl_arr(62)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGOVERSEA','VARCHAR2',length(appl_arr(i)));

      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = appl_arr(i)
        and    codapp = 'FLGOVERSEA';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGOVERSEA','2','TLISTVAL');
      end;
    end if;

    i := i+1; --appl_arr(63)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGCIVIL','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGCIVIL','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(64)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'LASTPOST','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(65)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DEPARTMN','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(66)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGMILIT','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('P','N','O') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGMILIT','7')||' "P" or "N" or "O",';
      end if;
    end if;

    i := i+1; --appl_arr(67)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESEXCEM','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(68)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGORDAN','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGORDAN','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(69)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGCASE','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGCASE','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(70)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESDISEA','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(71)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESSYMP','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(72)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGILL','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGILL','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(73)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESILL','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(74)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGARRES','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGARRES','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(75)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'DESARRES','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(76)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGKNOW','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGKNOW','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(77)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'NAME','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(78)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'FLGAPPL','VARCHAR2',length(appl_arr(i)));

      if appl_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(appl_arr(i),v_table,'FLGAPPL','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; --appl_arr(79)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'LASTPOS2','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(80)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'HOBBY','VARCHAR2',length(appl_arr(i)));
    end if;

    i := i+1; --appl_arr(81)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'AGEWRKMTH','NUMBER',length(appl_arr(i)));

        if not(check_number(appl_arr(i))) then
          if to_number(appl_arr(i)) < 0 then
            v_error := v_error||gen_detail_error(appl_arr(i),v_table,'AGEWRKMTH','5');
          end if;
        end if;
    end if;

    i := i+1; --appl_arr(82)
    if appl_arr(i) is not null then
      v_error := v_error||check_data_struc(appl_arr(i),v_table,'AGEWRKYR','NUMBER',length(appl_arr(i)));

        if not(check_number(appl_arr(i))) then
          if to_number(appl_arr(i)) < 0 then
            v_error := v_error||gen_detail_error(appl_arr(i),v_table,'AGEWRKYR','5');
          end if;
        end if;
    end if;

-------------------------------
    o_error := v_error;
  end check_error_tapplinf;

  procedure check_edu(edu_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf := 0;
    param_v_inbcklst  := 0;
    param_v_chk       := 0;

    v_id_type  := upper(trim(edu_arr(0)));
    v_numoffid := upper(trim(edu_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));

    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('edu', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_teducatn(edu_arr, v_detail);
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error2 := 'Y';
        param_detail_error2   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran2 := 'Y';
          save_edu(edu_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if; --chk_import_sub = 'Y'
  end check_edu;

  procedure check_error_teducatn(edu_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100 char);
    v_error         varchar2(4000 char) := null ;
    v_code          varchar2(1000 char) := null ;
  begin
    v_table := 'TEDUCATN';
    --start check data section--
    i := i+1;
    i := i+1; -- edu_arr(2)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'NUMSEQ','NUMBER',length(edu_arr(i)));
    end if;

    i := i+1; -- edu_arr(3)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODCOUNT','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODCOUNT','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODCNTY
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODCOUNT','2','TCODCNTY');
      end;
    end if;

    i := i+1; -- edu_arr(4)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODINST','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODINST','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODINST
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODINST','2','TCODINST');
      end;
    end if;

    i := i+1; -- edu_arr(5)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODEDLV','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODEDLV','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODEDUC
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODEDLV','2','TCODEDUC');
      end;
    end if;

    i := i+1; -- edu_arr(6)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODDGLV','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODDGLV','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODDGEE
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODDGLV','2','TCODDGEE');
      end;
    end if;

    i := i+1; -- edu_arr(7)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODMAJSB','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODMAJSB','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODMAJR
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODMAJSB','2','TCODMAJR');
      end;
    end if;

    i := i+1; -- edu_arr(8)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODMINSB','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'CODMINSB','VARCHAR2',length(edu_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   TCODSUBJ
        where  codcodec = edu_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(edu_arr(i),v_table,'CODMINSB','2','TCODSUBJ');
      end;
    end if;

    i := i+1; -- edu_arr(9)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMGPA','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'NUMGPA','NUMBER',length(edu_arr(i)));

      if not(check_number(edu_arr(i))) then
        if to_number(edu_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(edu_arr(i),v_table,'NUMGPA','5');
        end if;
      end if;
    end if;

    i := i+1; -- edu_arr(10)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'STAYEAR','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'STAYEAR','NUMBER',length(edu_arr(i)));

      if not(check_number(edu_arr(i))) then
        if to_number(edu_arr(i)) <= 0 or length(edu_arr(i)) <> 4 then
          v_error := v_error||gen_detail_error(edu_arr(i),v_table,'STAYEAR','HR2016');
        end if;
      end if;
    end if;

    i := i+1; -- edu_arr(11)
    if edu_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTEGYEAR','1');
    else
      v_error := v_error||check_data_struc(edu_arr(i),v_table,'DTEGYEAR','NUMBER',length(edu_arr(i)));

      if not(check_number(edu_arr(i))) then
        if to_number(edu_arr(i)) <= 0 or length(edu_arr(i)) <> 4 then
          v_error := v_error||gen_detail_error(edu_arr(i),v_table,'DTEGYEAR','HR2016');
        end if;
      end if;
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_teducatn;

  procedure check_exp(exp_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(exp_arr(0)));
    v_numoffid := upper(trim(exp_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));

    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;

    if chk_import('exp', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tapplwex(exp_arr,v_detail) ;

      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error3 := 'Y';
        param_detail_error3   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran3 := 'Y';
          save_exp(exp_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end;

  procedure check_error_tapplwex(exp_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100 char);
    v_error         varchar2(4000 char) := null ;
    v_code          varchar2(1000 char) := null ;
  begin
    v_table := 'TAPPLWEX';
    --start check data section--
    i := i+1;
    i := i+1;  -- exp_arr(2)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'NUMSEQ','NUMBER',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(3)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESNOFFI','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DESNOFFI','VARCHAR2',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(4)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESOFFI1','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DESOFFI1','VARCHAR2',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(5)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESLSTJOB1','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DESLSTJOB1','VARCHAR2',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(6)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESLSTPOS','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DESLSTPOS','VARCHAR2',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(7)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTESTART','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DTESTART','DATE',length(exp_arr(i)));
    end if;

    i := i+1;     -- exp_arr(8)
    if exp_arr(i) is null then
      null;
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DTEEND','DATE',length(exp_arr(i)));
    end if;

    i := i+1;  -- exp_arr(9)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'AMTINCOM','1');
    else
      v_error := v_error||replace(check_data_struc(exp_arr(i),v_table,'AMTINCOM','NUMBER',length(exp_arr(i))),'VARCHAR2','NUMBER');

      if not(check_number(exp_arr(i))) then
        if to_number(exp_arr(i)) < 0 then
          v_error := v_error||gen_detail_error(exp_arr(i),v_table,'AMTINCOM','5');
        end if;
      end if;
    end if;

    i := i+1;  -- exp_arr(10)
    i := i+1;  -- exp_arr(11)
    if exp_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESJOB','1');
    else
      v_error := v_error||check_data_struc(exp_arr(i),v_table,'DESJOB','VARCHAR2',length(exp_arr(i)));
    end if;

    --end check data section--
    o_error := v_error;
  end check_error_tapplwex;

  procedure check_train(train_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(train_arr(0)));
    v_numoffid := upper(trim(train_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));
    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('train', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      check_error_ttrainbf(train_arr, v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error4 := 'Y';
        param_detail_error4   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran4 := 'Y';
          save_train(train_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_train;

  procedure check_error_ttrainbf(train_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100 char);
    v_error         varchar2(4000 char) := null ;
    v_code          varchar2(1000 char) := null ;
    v_count         number := 0;
  begin
    v_table := 'TTRAINBF';
    --start check data section--
    i := i+1;
    i := i+1; -- train_arr(2)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'NUMSEQ','NUMBER',length(train_arr(i)));
    end if;

    i := i+1; -- train_arr(3)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESTRAIN','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'DESTRAIN','VARCHAR2',length(train_arr(i)));
    end if;

    i := i+1; -- train_arr(4)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTETRAIN','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'DTETRAIN','DATE',length(train_arr(i)));
    end if;

    i := i+1; -- train_arr(5)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DTETREN','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'DTETREN','DATE',length(train_arr(i)));
    end if;

    i := i+1; -- train_arr(6)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESPLACE','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'DESPLACE','VARCHAR2',length(train_arr(i)));
    end if;

    i := i+1; -- train_arr(7)
    if train_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESINSTU','1');
    else
      v_error := v_error||check_data_struc(train_arr(i),v_table,'DESINSTU','VARCHAR2',length(train_arr(i)));
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_ttrainbf;

  procedure check_spouse(spouse_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(spouse_arr(0)));
    v_numoffid := upper(trim(spouse_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));
    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('spouse', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      check_error_tapplfm(spouse_arr, v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error5 := 'Y';
        param_detail_error5   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran5 := 'Y';
          save_spouse(spouse_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_spouse;

  procedure check_error_tapplfm(spouse_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100);
    v_error         varchar2(4000) := null ;
    v_code          varchar2(1000) := null ;
    v_count         number := 0;
    v_name          varchar2(1000) := null ;
  begin
    v_table := 'TAPPLFM';
    --start check data section--
    i := i+1;
    i := i+1; -- spouse_arr(2)
    if spouse_arr(i) is null then
      v_error := v_error||check_data_struc(spouse_arr(i),v_table,'CODTITLE','VARCHAR2',length(spouse_arr(i)));
      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = spouse_arr(i)
        and    codapp = 'CODTITLE';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(spouse_arr(i),v_table,'CODTITLE','2','TLISTVAL');
      end;
    end if;

    v_name := get_tlistval_name('CODTITLE',spouse_arr(i),global_v_lang);

    i := i+1; -- spouse_arr(3)
    if spouse_arr(i) is not null then
      v_error := v_error||check_data_struc(v_name,v_table,'NAMFIRST','VARCHAR2',length(spouse_arr(i)));
    end if;
    v_name := v_name||' '||spouse_arr(i);

    i := i+1; -- spouse_arr(4)
    if spouse_arr(i) is not null then
      v_error := v_error||check_data_struc(v_name,v_table,'NAMLAST','VARCHAR2',length(spouse_arr(i)));
    end if;
    v_name := v_name||' '||spouse_arr(i);

    if v_name is not null then
      v_error := v_error||check_data_struc(v_name,v_table,'NAMSP','VARCHAR2',length(v_name));
    end if;

    i := i+1; -- spouse_arr(5)
    if spouse_arr(i) is not null then
      v_error := v_error||check_data_struc(v_name,v_table,'NUMOFFID','VARCHAR2',length(spouse_arr(i)));
    end if;

    i := i+1; -- spouse_arr(6)
    if spouse_arr(i) is not null then
      v_error := v_error||check_data_struc(spouse_arr(i),v_table,'STALIFE','VARCHAR2',length(spouse_arr(i)));

      if spouse_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(spouse_arr(i),v_table,'STALIFE','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; -- spouse_arr(7)
    if spouse_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESNOFFI','1');
    else
      v_error := v_error||check_data_struc(spouse_arr(i),v_table,'DESNOFFI','VARCHAR2',length(spouse_arr(i)));
    end if;

    i := i+1; -- spouse_arr(8)
    if spouse_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODSPOCC','1');
    else
      v_error := v_error||check_data_struc(spouse_arr(i),v_table,'CODSPOCC','VARCHAR2',length(spouse_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodoccu
        where  codcodec = spouse_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(spouse_arr(i),v_table,'CODSPOCC','2','TCODOCCU');
      end;
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_tapplfm;

  procedure check_rel(rel_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(rel_arr(0)));
    v_numoffid := upper(trim(rel_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));
    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('rel', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tapplrel(rel_arr, v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error6 := 'Y';
        param_detail_error6   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran6 := 'Y';
          save_rel(rel_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_rel;

  procedure check_error_tapplrel(rel_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100);
    v_error         varchar2(4000) := null ;
    v_code          varchar2(1000) := null ;
    v_count         number := 0;
  begin
    v_table := 'TAPPLREL';
    --start check data section--
    i := i+1;
    i := i+1; -- rel_arr(2)
    if rel_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(rel_arr(i),v_table,'NUMSEQ','NUMBER',length(rel_arr(i)));
    end if;

    i := i+1; -- rel_arr(3)
    if rel_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMREL','1');
    else
      v_error := v_error||check_data_struc(rel_arr(i),v_table,'NAMREL','VARCHAR2',length(rel_arr(i)));
    end if;

    i := i+1; -- rel_arr(4)
    if rel_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMTELEC','1');
    else
      v_error := v_error||check_data_struc(rel_arr(i),v_table,'NUMTELEC','VARCHAR2',length(rel_arr(i)));
    end if;

    i := i+1; -- rel_arr(5)
    if rel_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'ADRCOMT','1');
    else
      v_error := v_error||check_data_struc(rel_arr(i),v_table,'ADRCOMT','VARCHAR2',length(rel_arr(i)));
    end if;

    --end check data section--
    o_error := v_error;
  end check_error_tapplrel;

  procedure check_ref(ref_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(ref_arr(0)));
    v_numoffid := upper(trim(ref_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));
    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('ref', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tapplref(ref_arr, v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error7 := 'Y';
        param_detail_error7   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran7 := 'Y';
          save_ref(ref_arr,v_numoffid,v_dteapplac);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_ref;

  procedure check_error_tapplref(ref_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100);
    v_error         varchar2(4000) := null ;
    v_code          varchar2(1000) := null ;
    v_count         number := 0;
  begin
    v_table := 'TAPPLREF';
    --start check data section--
    i := i+1;
    i := i+1; -- ref_arr(2)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NUMSEQ','NUMBER',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(3)
    if ref_arr(i) is null then
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'CODTITLE','VARCHAR2',length(ref_arr(i)));
      v_code := null;
      begin
        select distinct list_value into v_code
        from   tlistval
        where  list_value = ref_arr(i)
        and    codapp = 'CODTITLE';
      exception when no_data_found then
        v_error := v_error||gen_detail_error(ref_arr(i),v_table,'CODTITLE','2','TLISTVAL');
      end;
    end if;

    i := i+1; -- ref_arr(4)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMFIRSTE','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NAMFIRSTE','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(5)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMFIRSTT','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NAMFIRSTT','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(6)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMLASTE','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NAMLASTE','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(7)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMLASTT','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NAMLASTT','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(8)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'FLGREF','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'FLGREF','VARCHAR2',length(ref_arr(i)));

      begin
        select count(*)
          into v_count
          from tlistval
         where codapp = 'FLGREF'
           and list_value = upper(ref_arr(i));
      exception when no_data_found then
        v_error := v_error||gen_detail_error(ref_arr(i),v_table,'FLGREF','7');
      end;
    end if;

    i := i+1; -- ref_arr(9)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESPOS','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'DESPOS','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(10)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'ADRCONT1','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'ADRCONT1','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(11)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'DESNOFFI','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'DESNOFFI','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(12)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMTELE','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'NUMTELE','VARCHAR2',length(ref_arr(i)));
    end if;

    i := i+1; -- ref_arr(13)
    if ref_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'EMAIL','1');
    else
      v_error := v_error||check_data_struc(ref_arr(i),v_table,'EMAIL','VARCHAR2',length(ref_arr(i)));
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_tapplref;

  procedure check_lng(lng_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(lng_arr(0)));
    v_numoffid := upper(trim(lng_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));
    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;
    if chk_import('lng', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tlangabi(lng_arr, v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error8 := 'Y';
        param_detail_error8   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran8 := 'Y';
          save_lng(lng_arr);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_lng;

  procedure check_error_tlangabi(lng_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100);
    v_error         varchar2(4000) := null ;
    v_code          varchar2(1000) := null ;
  begin
    v_table := 'TLANGABI';
    --start check data section--
    i := i+1; -- lng_arr(1)
    if lng_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMOFFID','1');
    else
      v_error := v_error||check_data_struc(lng_arr(i),'TAPPLINF','NUMOFFID','VARCHAR2',length(lng_arr(i)));
    end if;

    i := i+1; -- lng_arr(2)
    i := i+1; -- lng_arr(3)
    if lng_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'CODLANG','1');
    else
      v_error := v_error||check_data_struc(lng_arr(i),v_table,'CODLANG','VARCHAR2',length(lng_arr(i)));
    end if;

    i := i+1; -- lng_arr(4)
    if lng_arr(i) is null and lng_arr(i+1) is null and lng_arr(i+2) is null and lng_arr(i+3) is null  then
        v_error := v_error||gen_detail_error('NULL',v_table,'FLGLIST','1');
    end if;

    if lng_arr(i) is not null then
      v_error := v_error||check_data_struc(lng_arr(i),v_table,'FLGLIST','VARCHAR2',length(lng_arr(i)));
    end if;

    i := i+1; -- lng_arr(5)
    if lng_arr(i) is not null then
      v_error := v_error||check_data_struc(lng_arr(i),v_table,'FLGSPEAK','VARCHAR2',length(lng_arr(i)));
    end if;

    i := i+1; -- lng_arr(6)
    if lng_arr(i) is not null then
      v_error := v_error||check_data_struc(lng_arr(i),v_table,'FLGREAD','VARCHAR2',length(lng_arr(i)));
    end if;

    i := i+1; -- lng_arr(7)
    if lng_arr(i) is not null then
      v_error := v_error||check_data_struc(lng_arr(i),v_table,'FLGWRITE','VARCHAR2',length(lng_arr(i)));
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_tlangabi;

  procedure check_doc(doc_arr in arr) is
    v_detail    varchar2(4000 char);
    v_error     boolean;
    v_id_type   varchar2(100 char);
    v_numoffid  varchar2(100 char);
    v_dteapplac date;
  begin
    v_detail  := null;
    v_error   := false;
    param_v_inapplinf   := 0;
    param_v_inbcklst  := 0;
    param_v_chk         := 0;

    v_id_type  := upper(trim(doc_arr(0)));
    v_numoffid := upper(trim(doc_arr(1)));
    v_numoffid := upper(rpad(v_numoffid,13,'0'));

    begin
      select  max(dteappl) into v_dteapplac
      from    tapplinf
      where   numoffid = v_numoffid
      and     codpos1  = param_v_codpos;
    exception when others then v_dteapplac := to_date('01/01/0001','dd/mm/yyyy');
    end;

    if chk_import('doc', v_id_type,v_numoffid,v_dteapplac) = 'Y' then
      Check_error_tappldoc(doc_arr,v_detail) ;
      if v_detail is not null then
        v_error := true;
        v_detail := substr(v_detail,1,length(v_detail)-1); --delete last , character
      end if;

      if v_error then
        param_flg_error9 := 'Y';
        param_detail_error9   := substr(v_detail,1,4000);
      else
        if chk_import_sub(v_id_type,v_numoffid,v_dteapplac) = 'Y' then
          param_flg_tran9 := 'Y';
          save_doc(doc_arr);
        else
          param_flg_remark4 := 'Y';
        end if;
      end if; -- not error
    else --chk_import_sub = 'N'
      if nvl(param_v_inapplinf,0) <> 0 then
        param_flg_remark1 := 'Y';
      end if;

      if nvl(param_v_inbcklst,0) <> 0 then
        param_flg_remark2 := 'Y';
      end if;
    end if;
  end check_doc;

  procedure check_error_tappldoc(doc_arr in arr, o_error out varchar2) is
    i               number := 0;
    j               number ;
    v_table         varchar2(100 char);
    v_error         varchar2(4000 char) := null ;
    v_code          varchar2(1000 char) := null ;
  begin
    v_table := 'TAPPLDOC';
    --start check data section--
    i := i+1; -- doc_arr(1)
    if doc_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMOFFID','1');
    else
      v_error := v_error||check_data_struc(doc_arr(i),'TAPPLINF','NUMOFFID','VARCHAR2',length(doc_arr(i)));
    end if;

    i := i+1; -- doc_arr(2)
    if doc_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NUMSEQ','1');
    else
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'NUMSEQ','NUMBER',length(doc_arr(i)));
    end if;

    i := i+1; -- doc_arr(3)
    if doc_arr(i) is null then
      v_error := v_error||gen_detail_error('NULL',v_table,'NAMDOC','1');
    else
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'NAMDOC','VARCHAR2',length(doc_arr(i)));
    end if;

    i := i+1; -- doc_arr(4)
    if doc_arr(i) is not null then
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'TYPDOC','VARCHAR2',length(doc_arr(i)));

      v_code := null;
      begin
        select codcodec into v_code
        from   tcodtydoc
        where  codcodec = doc_arr(i);
      exception when no_data_found then
        v_error := v_error||gen_detail_error(doc_arr(i),v_table,'TYPDOC','2','TCODTYDOC');
      end;
    end if;

    i := i+1; -- doc_arr(5)
    if doc_arr(i) is not null then
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'FLGRESUME','VARCHAR2',length(doc_arr(i)));

      if doc_arr(i) not in('Y','N') then
        v_error := v_error||gen_detail_error(doc_arr(i),v_table,'FLGRESUME','7')||' "Y" or "N",';
      end if;
    end if;

    i := i+1; -- doc_arr(6)
    if doc_arr(i) is null then
      if doc_arr(i-3) is not null then -- if has namdoc
        v_error := v_error||gen_detail_error('NULL',v_table,'FILEDOC','1');
      end if;
    else
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'FILEDOC','VARCHAR2',length(doc_arr(i)));
    end if;

    i := i+1; -- doc_arr(7)
    if doc_arr(i) is not null then
      v_error := v_error||check_data_struc(doc_arr(i),v_table,'DESNOTE','VARCHAR2',length(doc_arr(i)));
    end if;
    --end check data section--
    o_error := v_error;
  end check_error_tappldoc;

  --procedure save_appl(appl_arr in arr) is
  procedure save_appl(appl_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numappl   varchar2(20);
    v_dteyear   number := to_char(sysdate,'yyyy');
    v_dteappl   date;
    v_dteempdb  date;
    v_dtedisb   date;
    v_dtedisen  date;
    v_dteupd    date;
    --v_numoffid  varchar2(20);
    --v_dteapplac date;
    v_dteupdacc varchar2(30 char);
    v_namempt   varchar2(200);
    v_namempe   varchar2(200);
    v_numappl_pre_delete    varchar2(30 char);

    cursor c_tapplinf is
      select rowid,codtitle,namfirste,namfirstt,namlaste,namlastt
      from   tapplinf
      where  numoffid = v_numoffid
      and    codpos1  = param_v_codpos;

    cursor c_tapploth is
      select rowid
      from   tapploth
      where  numappl  = v_numappl;
  begin
    check_update(v_numoffid,v_numappl_pre_delete);
    if v_numappl_pre_delete <> 'NO_DATA' then
      v_numappl  := v_numappl_pre_delete;
    else
      v_numappl     := gen_id(v_dteyear ,'A',8,'tapplinf','numappl');
    end if;

    v_dteappl     := change_date(appl_arr(7));
    v_dteempdb    := change_date(appl_arr(10));
    v_dtedisb     := change_date(appl_arr(45));
    v_dtedisen    := change_date(appl_arr(46));
    v_dteupd      := sysdate;
    v_dteupdacc:= to_char(sysdate,'dd/mm/')||to_char(to_number(to_char(sysdate,'yyyy'))-global_v_zyear);
    --<< 'TAPPLINF'
    v_exist := false;
    begin
      for r_tapplinf in c_tapplinf loop
        v_exist := true;
        v_namempe   := get_tlistval_name('CODTITLE',nvl(upper(appl_arr(2)),r_tapplinf.codtitle),'101')||
                       nvl(appl_arr(5),r_tapplinf.namfirste)||'  '||nvl(appl_arr(6),r_tapplinf.namlaste);
        v_namempt   := get_tlistval_name('CODTITLE',nvl(upper(appl_arr(2)),r_tapplinf.codtitle),'102')||
                       nvl(appl_arr(3),r_tapplinf.namfirstt)||'  '||nvl(appl_arr(4),r_tapplinf.namlastt);
        v_namempt   := substr(v_namempt,1,60);
        v_namempe   := substr(v_namempe,1,60);

        update tapplinf
          set  codtitle   = appl_arr(2),
               namfirste  = appl_arr(5),
               namfirstt  = appl_arr(3),
               namfirst3  = appl_arr(5),
               namfirst4  = appl_arr(5),
               namfirst5  = appl_arr(5),
               namlaste   = appl_arr(6),
               namlastt   = appl_arr(4),
               namlast3   = appl_arr(6),
               namlast4   = appl_arr(6),
               namlast5   = appl_arr(6),
               namempe    = v_namempe,
               namempt    = v_namempt,
               namemp3    = v_namempe,
               namemp4    = v_namempe,
               namemp5    = v_namempe,
               dteappl    = v_dteappl,
               codpos1    = appl_arr(8),
               codpos2    = appl_arr(9),
               dteempdb   = v_dteempdb,
               codsex     = appl_arr(11),
               stamarry   = appl_arr(12),
               stamilit   = appl_arr(13),
               codnatnl   = appl_arr(14),
               codorgin   = appl_arr(15),
               numpasid   = appl_arr(16),
               adrconte   = appl_arr(17),
               adrcontt   = appl_arr(17),
               adrcont3   = appl_arr(17),
               adrcont4   = appl_arr(17),
               adrcont5   = appl_arr(17),
               codsubdistc= appl_arr(18),
               coddistc   = appl_arr(19),
               codprovc   = appl_arr(20),
               codcntyc   = appl_arr(21),
               codpostc   = appl_arr(22),
               numtelem   = appl_arr(23),
               numteleh   = appl_arr(24),
               email      = appl_arr(25),
               amtincfm   = appl_arr(48),
               amtincto   = appl_arr(48),
               codmedia   = appl_arr(40),

               adrrege    = appl_arr(26),
               adrregt    = appl_arr(26),
               adrreg3    = appl_arr(26),
               adrreg4    = appl_arr(26),
               adrreg5    = appl_arr(26),
               codsubdistr= appl_arr(27),
               coddistr   = appl_arr(28),
               codprovr   = appl_arr(29),
               codcntyi   = appl_arr(30),
               codposte   = appl_arr(31),
               numtelemr  = appl_arr(32),
               numtelehr  = appl_arr(33),
               namimage   = appl_arr(34),

               addinfo    = appl_arr(49),
               actstudy   = appl_arr(50),
               specabi    = appl_arr(51),
               compabi    = appl_arr(52),
               typthai    = appl_arr(53),
               typeng     = appl_arr(54),

               stadisb    = appl_arr(42),
               numdisab   = appl_arr(43),
               typdisp    = appl_arr(44),
               dtedisb    = v_dtedisb,
               dtedisen   = v_dtedisen,
               desdisp    = appl_arr(47),
               flgcar     = appl_arr(41),

               statappl   = appl_arr(83),
               flgqualify = appl_arr(84),
               numreql    = appl_arr(85),
               codcompl   = appl_arr(86),
               codposl    = appl_arr(87),
               dtefoll    = trunc(sysdate),
               dtetrnjo   = sysdate,
               flgblkls   = 'N',
               codcurr    = '',
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_tapplinf.rowid;
      end loop;

      if not v_exist then
        v_namempe   := get_tlistval_name('CODTITLE',upper(appl_arr(2)),'101')||appl_arr(5)||'  '||appl_arr(6);
        v_namempt   := get_tlistval_name('CODTITLE',upper(appl_arr(2)),'102')||appl_arr(3)||'  '||appl_arr(4);
        v_namempt   := substr(v_namempt,1,60);
        v_namempe   := substr(v_namempe,1,60);

        insert into tapplinf
         (numappl,numoffid,codtitle,
          namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
          namlaste,namlastt,namlast3,namlast4,namlast5,
          namempe,namempt,namemp3,namemp4,namemp5,
          dteappl,codpos1,codpos2,
          dteempdb,codsex,stamarry,
          stamilit,codnatnl,codorgin,numpasid,
          adrconte,adrcontt,adrcont3,adrcont4,adrcont5,
          codsubdistc,coddistc,codprovc,codcntyc,codpostc,
          numtelem,numteleh,email,
          amtincfm,amtincto,codmedia,
          --<
          addinfo,actstudy,specabi,compabi,typthai,typeng,
          -->
          stadisb,numdisab,typdisp,dtedisb,dtedisen,desdisp,flgcar,
          --default
          statappl,flgqualify,dtefoll,dtetrnjo,flgblkls,codcurr,
          adrrege,adrregt,adrreg3,adrreg4,adrreg5,
          codsubdistr,coddistr,codprovr,
          codcntyi,codposte,
          numtelemr,numtelehr,namimage,numreql,codcompl,codposl,
          coduser)
        values
         (v_numappl,v_numoffid,appl_arr(2),
          appl_arr(5),appl_arr(3),appl_arr(5),appl_arr(5),appl_arr(5),
          appl_arr(6),appl_arr(4),appl_arr(6),appl_arr(6),appl_arr(6),
          v_namempe,v_namempt,v_namempe,v_namempe,v_namempe,
          v_dteappl,appl_arr(8),appl_arr(9),
          v_dteempdb,appl_arr(11),appl_arr(12),
          appl_arr(13),appl_arr(14),appl_arr(15),appl_arr(16),
          appl_arr(17),appl_arr(17),appl_arr(17),appl_arr(17),appl_arr(17),
          appl_arr(18),appl_arr(19),appl_arr(20),appl_arr(21),appl_arr(22),
          appl_arr(23),appl_arr(24),appl_arr(25),
          appl_arr(48),appl_arr(48),appl_arr(40),
          --<
          appl_arr(49),appl_arr(50),appl_arr(51),appl_arr(52),appl_arr(53),appl_arr(54),
          -->
          appl_arr(42),appl_arr(43),appl_arr(44),v_dtedisb,v_dtedisen,appl_arr(47),appl_arr(41),
          --default
          appl_arr(83),appl_arr(84),trunc(sysdate),sysdate,'N','',
          appl_arr(26),appl_arr(26),appl_arr(26),appl_arr(26),appl_arr(26),
          appl_arr(27),appl_arr(28),appl_arr(29),
          appl_arr(30),appl_arr(31),
          appl_arr(32),appl_arr(33),appl_arr(34),appl_arr(85),appl_arr(86),appl_arr(87),
          global_v_coduser);
      end if;
      success := 'YES';
    exception when others then
      success := 'NO';
      param_flg_remark3 := 'Y';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
      goto end_check;
    end;
    -->> 'TAPPLINF'

    -- TAPPFOLL
    if success = 'YES' then
      begin
        insert into tappfoll (numappl,dtefoll,statappl,codpos,codcreate,coduser)
        values(v_numappl,trunc(sysdate),appl_arr(83),appl_arr(8),global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        begin
          update tappfoll
             set statappl = appl_arr(83),
                 codpos   = appl_arr(8),
                 coduser  = global_v_coduser
           where numappl  = v_numappl
             and dtefoll  = trunc(sysdate);
        exception when others then
          insert into a(b) values(dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);commit;
        end;
      end;
    end if;

    if success = 'YES' then
      upd_id(v_dteyear,'A',v_numappl,'IMPORT');
      --<< 'TAPPLOTH'
      v_exist := false;
      begin
        for r_tapploth in c_tapploth loop
          v_exist := true;

          update tapploth
            set   reason      = nvl(replace(appl_arr(25),'\r\n',chr(13)||chr(10)),reason),
                  jobdesc     = nvl(replace(appl_arr(26),'\r\n',chr(13)||chr(10)),jobdesc),
                  flgstrwk    = nvl(appl_arr(57),flgstrwk),
                  dtewkst     = nvl(to_date(appl_arr(58),'dd/mm/yyyy'),dtewkst),
                  qtydayst    = nvl(appl_arr(59),qtydayst),
                  codlocat    = nvl(appl_arr(60),codlocat),
                  flgprov     = nvl(appl_arr(61),flgprov),
                  flgoversea  = nvl(appl_arr(62),flgoversea),
                  flgcivil    = nvl(appl_arr(63),flgcivil),
                  lastpost    = nvl(appl_arr(64),lastpost),
                  departmn    = nvl(appl_arr(65),departmn),
                  flgmilit    = nvl(appl_arr(66),flgmilit),
                  desexcem    = nvl(appl_arr(67),desexcem),
                  flgordan    = nvl(appl_arr(68),flgordan),
                  flgcase     = nvl(appl_arr(69),flgcase),
                  desdisea    = nvl(appl_arr(70),desdisea),
                  dessymp     = nvl(appl_arr(71),dessymp),
                  flgill      = nvl(appl_arr(72),flgill),
                  desill      = nvl(appl_arr(73),desill),
                  flgarres    = nvl(appl_arr(74),flgarres),
                  desarres    = nvl(appl_arr(75),desarres),
                  flgknow     = nvl(appl_arr(76),flgknow),
                  name        = nvl(appl_arr(77),name),
                  flgappl     = nvl(appl_arr(78),flgappl),
                  lastpos2    = nvl(appl_arr(79),lastpos2),
                  hobby       = nvl(appl_arr(80),hobby),
                  agewrkmth   = nvl(appl_arr(81),agewrkmth),
                  agewrkyr    = nvl(appl_arr(82),agewrkyr),
                  dteupd      = v_dteupd,
                  coduser     = global_v_coduser
            where rowid = r_tapploth.rowid;
        end loop;

        if not v_exist then
          insert into tapploth
            (numappl,reason,jobdesc,
             flgstrwk,dtewkst,qtydayst,
             codlocat,flgprov,flgoversea,
             flgcivil,lastpost,departmn,
             flgmilit,desexcem,flgordan,
             flgcase,desdisea,dessymp,
             flgill,desill,flgarres,desarres,
             flgknow,name,flgappl,lastpos2,
             hobby,agewrkmth,agewrkyr,
             coduser)
          values
            (v_numappl,replace(appl_arr(25),'\r\n',chr(13)||chr(10)),replace(appl_arr(26),'\r\n',chr(13)||chr(10)),
             appl_arr(57),to_date(appl_arr(58),'dd/mm/yyyy'),appl_arr(59),
             appl_arr(60),appl_arr(61),appl_arr(62),
             appl_arr(63),appl_arr(64),appl_arr(65),
             appl_arr(66),appl_arr(67),appl_arr(68),
             appl_arr(69),appl_arr(70),appl_arr(71),
             appl_arr(72),appl_arr(73),appl_arr(74),appl_arr(75),
             appl_arr(76),appl_arr(77),appl_arr(78),appl_arr(79),
             replace(appl_arr(80),'\r\n',chr(13)||chr(10)),appl_arr(81),appl_arr(82),
             global_v_coduser);
        end if;
      end;
      -->> 'TAPPLOTH'
    else --success = 'NO'
      param_flg_remark3 := 'Y';
    end if;
    <<end_check>>
    null;
  end save_appl;

  procedure save_edu(edu_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_dteupd    date;

    cursor c_teducatn is
      select rowid
      from   teducatn
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(edu_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_teducatn in c_teducatn loop
        v_exist := true;

        update teducatn
          set  codedlv  = edu_arr(5),
               coddglv  = edu_arr(6),
               codmajsb = edu_arr(7),
               codminsb = edu_arr(8),
               codinst  = edu_arr(4),
               codcount = edu_arr(3),
               numgpa   = edu_arr(9),
               stayear  = edu_arr(10),
               dtegyear = edu_arr(11),
               flgeduc  = decode(v_numseqq,1,'1','2'),
               dteupd   = v_dteupd,
               coduser  = global_v_coduser
          where rowid = r_teducatn.rowid;
      end loop;

      if not v_exist then

        insert into teducatn
         (numappl,numseq,
          codedlv,coddglv,codmajsb,
          codminsb,codinst,codcount,
          numgpa,stayear,dtegyear,
          flgeduc,
          coduser)
        values
         (param_v_numappl,v_numseqq,
          edu_arr(5),edu_arr(6),edu_arr(7),
          edu_arr(8),edu_arr(4),edu_arr(3),
          edu_arr(9),edu_arr(10),edu_arr(11),
          decode(v_numseqq,1,'1','2'),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'NO' then
      param_flg_remark3 := 'Y';
    end if;
  end save_edu;

  procedure save_exp(exp_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_desoffi1  varchar2(100 char);
    v_dteupd    date;

    cursor c_tapplwex is
      select rowid
      from   tapplwex
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(exp_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      v_desoffi1 := get_tcodec_name('TCODCNTY',exp_arr(4),102) ;
      for r_tapplwex in c_tapplwex loop
        v_exist := true;

        update tapplwex
          set  desnoffi   = exp_arr(3),
               desoffi1   =  v_desoffi1,
               deslstjob1 = exp_arr(5),
               deslstpos  = exp_arr(6),
               dtestart   = to_date(exp_arr(7),'dd/mm/yyyy'),
               dteend     = to_date(exp_arr(8),'dd/mm/yyyy'),
               amtincom   = stdenc(to_number(exp_arr(9)),numappl,global_chken),
               remark     = exp_arr(11),
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_tapplwex.rowid;
      end loop;

      if not v_exist then

        insert into tapplwex
         (numappl,numseq,
          desnoffi,desoffi1,
          deslstjob1,deslstpos,dtestart,
          dteend,amtincom,remark,
          coduser)
        values
         (param_v_numappl,v_numseqq,
          exp_arr(3),v_desoffi1,
          exp_arr(5),exp_arr(6),to_date(exp_arr(7),'dd/mm/yyyy'),
          to_date(exp_arr(8),'dd/mm/yyyy'),stdenc(to_number(exp_arr(9)),param_v_numappl,global_chken),exp_arr(11),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'YES' then
      update  tapplinf
        set   flgwork = 'Y'
      where   numappl = param_v_numappl;
    else
      param_flg_remark3 := 'Y';
    end if;
  end save_exp;

  procedure save_train(train_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_dteupd    date;

    cursor c_ttrainbf is
      select rowid
      from   ttrainbf
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(train_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_ttrainbf in c_ttrainbf loop
        v_exist := true;

        update ttrainbf
          set  destrain   = train_arr(3),
               dtetrain   = to_date(train_arr(4),'dd/mm/yyyy'),
               dtetren    = to_date(train_arr(5),'dd/mm/yyyy'),
               desplace   = train_arr(6),
               desinstu   = train_arr(7),
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_ttrainbf.rowid;
      end loop;

      if not v_exist then

        insert into ttrainbf
         (numappl,numseq,
          destrain,dtetrain,dtetren,
          desplace,desinstu,
          coduser)
        values
         (param_v_numappl,v_numseqq,
          train_arr(3),to_date(train_arr(4),'dd/mm/yyyy'),to_date(train_arr(5),'dd/mm/yyyy'),
          train_arr(6),train_arr(7),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'YES' then
      update  tapplinf
        set   flgwork = 'Y'
      where   numappl = param_v_numappl;
    else
      param_flg_remark3 := 'Y';
    end if;
  end save_train;

  procedure save_spouse(spouse_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_dteupd    date;
    v_name      varchar2(4000 char);

    cursor c_tapplfm is
      select rowid
      from   tapplfm
      where  numappl  = param_v_numappl;
  begin
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_tapplfm in c_tapplfm loop
        v_exist := true;
        v_name := get_tlistval_name('CODTITLE',spouse_arr(2),global_v_lang)||' '||spouse_arr(3)||' '||spouse_arr(4);
        update tapplfm
          set  codtitle   = spouse_arr(2),
               namsp      = v_name,
               numoffid   = spouse_arr(5),
               desnoffi   = spouse_arr(7),
               codspocc   = spouse_arr(8),
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_tapplfm.rowid;
      end loop;

      if not v_exist then
        v_name := get_tlistval_name('CODTITLE',spouse_arr(2),global_v_lang)||' '||spouse_arr(3)||' '||spouse_arr(4);
        insert into tapplfm
         (numappl,
          codtitle,namsp,numoffid,
          desnoffi,codspocc,
          coduser)
        values
         (param_v_numappl,
          spouse_arr(2),v_name,spouse_arr(5),
          spouse_arr(7),spouse_arr(8),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end;

    if success = 'YES' then
      update  tapplinf
        set   flgwork = 'Y'
      where   numappl = param_v_numappl;
    else
      param_flg_remark3 := 'Y';
    end if;
  end save_spouse;

  procedure save_rel(rel_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_dteupd    date;

    cursor c_tapplrel is
      select rowid
      from   tapplrel
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(rel_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_tapplrel in c_tapplrel loop
        v_exist := true;

        update tapplrel
          set  namrel   = rel_arr(3),
               numtelec = rel_arr(4),
               adrcomt  = rel_arr(5),
               dteupd   = v_dteupd,
               coduser  = global_v_coduser
          where rowid = r_tapplrel.rowid;
      end loop;

      if not v_exist then

        insert into tapplrel
         (numappl,numseq,
          namrel,numtelec,adrcomt,
          coduser)
        values
         (param_v_numappl,v_numseqq,
          rel_arr(3),rel_arr(4),rel_arr(5),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'NO' then
      param_flg_remark3 := 'Y';
    end if;
  end save_rel;

  procedure save_ref(ref_arr in arr, v_numoffid in varchar2, v_dteapplac in date) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_dteupd    date;

    cursor c_tapplref is
      select rowid
      from   tapplref
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(ref_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_tapplref in c_tapplref loop
        v_exist := true;

        update tapplref
          set  codtitle   = ref_arr(3),
               namfirste  = ref_arr(4),
               namfirstt  = ref_arr(5),
               namlaste   = ref_arr(6),
               namlastt   = ref_arr(7),
               namrefe    = get_tlistval_name('CODTITLE',ref_arr(3),'101')||' '||ref_arr(4)||' '||ref_arr(6),
               namreft    = get_tlistval_name('CODTITLE',ref_arr(3),'102')||' '||ref_arr(5)||' '||ref_arr(7),
               flgref     = ref_arr(8),
               despos     = ref_arr(9),
               adrcont1   = ref_arr(10),
               desnoffi   = ref_arr(11),
               numtele    = ref_arr(12),
               email      = ref_arr(13),
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_tapplref.rowid;
      end loop;

      if not v_exist then

        insert into tapplref
         (numappl,numseq,
          codtitle,namfirste,namfirstt,namlaste,namlastt,
          namrefe,
          namreft,
          flgref,despos,adrcont1,desnoffi,
          numtele,email,
          coduser)
        values
         (param_v_numappl,v_numseqq,
          ref_arr(3),ref_arr(4),ref_arr(5),ref_arr(6),ref_arr(7),
          get_tlistval_name('CODTITLE',ref_arr(3),'101')||' '||ref_arr(4)||' '||ref_arr(6),
          get_tlistval_name('CODTITLE',ref_arr(3),'102')||' '||ref_arr(5)||' '||ref_arr(7),
          ref_arr(8),ref_arr(9),ref_arr(10),ref_arr(11),
          ref_arr(12),ref_arr(13),
          global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'NO' then
      param_flg_remark3 := 'Y';
    end if;
  end save_ref;

  procedure save_lng(lng_arr in arr) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_codlang   varchar2(4 char);
    v_dteupd    date;

    cursor c_tlangabi is
      select rowid
      from   tlangabi
      where  numappl  = param_v_numappl
      and    codlang  = v_codlang;
  begin
    v_codlang  := lng_arr(3);
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_tlangabi in c_tlangabi loop
        v_exist := true;

        update tlangabi
          set  codlang  = lng_arr(3),
               flglist  = lng_arr(4),
               flgspeak = lng_arr(5),
               flgread  = lng_arr(6),
               flgwrite = lng_arr(7),
               dteupd   = v_dteupd,
               coduser  = global_v_coduser
          where rowid = r_tlangabi.rowid;
      end loop;

      if not v_exist then

        insert into tlangabi
         (numappl,
          codlang,flglist,
          flgspeak,flgread,
          flgwrite,
          coduser)
        values
         (param_v_numappl,
          lng_arr(3),lng_arr(4),lng_arr(5),
          lng_arr(6),lng_arr(7),global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'NO' then
      param_flg_remark3 := 'Y';
    end if;
  end save_lng;

  procedure save_doc(doc_arr in arr) is
    v_exist     boolean;
    success     varchar2(10 char) := 'NO';
    v_numseqq   number;
    v_dteupd    date;

    cursor c_tappldoc is
      select rowid
      from   tappldoc
      where  numappl  = param_v_numappl
      and    numseq   = v_numseqq;
  begin
    v_numseqq  := to_number(doc_arr(2));
    v_dteupd   := sysdate;
    v_exist := false;
    begin
      for r_tappldoc in c_tappldoc loop
        v_exist := true;

        update tappldoc
          set  namdoc     = doc_arr(3),
               typdoc     = doc_arr(4),
               flgresume  = doc_arr(5),
               filedoc    = doc_arr(6),
               desnote    = doc_arr(7),
               dteupd     = v_dteupd,
               coduser    = global_v_coduser
          where rowid = r_tappldoc.rowid;
      end loop;

      if not v_exist then

        insert into tappldoc
         (numappl,numseq,
          namdoc,typdoc,flgresume,filedoc,
          desnote,coduser)
        values
         (param_v_numappl,v_numseqq,
          doc_arr(3),doc_arr(4),doc_arr(5),doc_arr(6),
          doc_arr(7),global_v_coduser);
      end if;
      success := 'YES';

    exception when others then
      success := 'NO';
      param_detail_remark3 := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    end;

    if success = 'NO' then
      param_flg_remark3 := 'Y';
    end if;
  end save_doc;

  function get_resp_clob return clob is
    v_numoffid       varchar2(13 char);
    v_namemp         varchar2(100 char);
    v_status         varchar2(1000 char);
    v_flg_status     varchar2(10 char);
    sub1_json_list   json_array_t;
    sub2_json_list   json_array_t;
    sub3_json_list   json_array_t;
    sub4_json_list   json_array_t;
    sub5_json_list   json_array_t;
    sub6_json_list   json_array_t;
    sub7_json_list   json_array_t;
    sub8_json_list   json_array_t;
    sub9_json_list   json_array_t;
    status_json_list json_array_t;
    error_json_obj   json_object_t;
    resp_json_obj    json_object_t;
    resp_json_long   long;
    resp_length      int := 0;
    strst            int := 1;
    strsize          int := 600;
    v_clob  clob;
  begin
    status_json_list := json_array_t();
    if param_flg_success = 'Y' then
      v_status  :=  'Success';
      v_flg_status := 's';
    elsif param_flg_remark1 = 'Y' then
      v_status  :=  param_detail_remark1;
      v_flg_status := 'r1';
    elsif param_flg_remark2 = 'Y' then
      v_status  :=  param_detail_remark2;
      v_flg_status := 'r2';
    elsif param_flg_remark3 = 'Y' then
      v_status  :=  param_detail_remark3;
      v_flg_status := 'r3';
    elsif param_flg_error = 'Y' then
      v_status  :=  'Error';
      v_flg_status := 'e';
    elsif param_flg_remark4 = 'Y' then --no numappl
      v_status  :=  param_detail_remark4;
      v_flg_status := 'r4';
    else
      v_status  :=  'Success';
    end if;
    status_json_list.append(v_status);
    status_json_list.append(v_flg_status);

    sub1_json_list := json_array_t();
    sub1_json_list.append(nvl(param_detail_error1,''));

    if param_sub2_json_str is not null then
      sub2_json_list := json_array_t(param_sub2_json_str);
    else
      sub2_json_list := json_array_t();
      sub2_json_list.append('');
    end if;

    if param_sub3_json_str is not null then
      sub3_json_list := json_array_t(param_sub3_json_str);
    else
      sub3_json_list := json_array_t();
      sub3_json_list.append('');
    end if;

    if param_sub4_json_str is not null then
      sub4_json_list := json_array_t(param_sub4_json_str);
    else
      sub4_json_list := json_array_t();
      sub4_json_list.append('');
    end if;

    if param_sub5_json_str is not null then
      sub5_json_list := json_array_t(param_sub5_json_str);
    else
      sub5_json_list := json_array_t();
      sub5_json_list.append('');
    end if;

    if param_sub6_json_str is not null then
      sub6_json_list := json_array_t(param_sub6_json_str);
    else
      sub6_json_list := json_array_t();
      sub6_json_list.append('');
    end if;

    if param_sub7_json_str is not null then
      sub7_json_list := json_array_t(param_sub7_json_str);
    else
      sub7_json_list := json_array_t();
      sub7_json_list.append('');
    end if;

    if param_sub8_json_str is not null then
      sub8_json_list := json_array_t(param_sub8_json_str);
    else
      sub8_json_list := json_array_t();
      sub8_json_list.append('');
    end if;

    if param_sub9_json_str is not null then
      sub9_json_list := json_array_t(param_sub9_json_str);
    else
      sub9_json_list := json_array_t();
      sub9_json_list.append('');
    end if;

    error_json_obj := json_object_t();
    error_json_obj.put('error1',sub1_json_list);
    error_json_obj.put('error2',sub2_json_list);
    error_json_obj.put('error3',sub3_json_list);
    error_json_obj.put('error4',sub4_json_list);
    error_json_obj.put('error5',sub5_json_list);
    error_json_obj.put('error6',sub6_json_list);
    error_json_obj.put('error7',sub7_json_list);
    error_json_obj.put('error8',sub8_json_list);
    error_json_obj.put('error9',sub9_json_list);

    resp_json_obj := json_object_t();
    resp_json_obj.put('coderror','200');
    resp_json_obj.put('status',status_json_list);
    resp_json_obj.put('numappl',nvl(param_v_numappl,''));
    resp_json_obj.put('detail',error_json_obj);
    v_clob := resp_json_obj.to_clob;
    return v_clob;
  end;

end;

/

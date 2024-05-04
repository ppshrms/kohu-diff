--------------------------------------------------------
--  DDL for Package Body HRRC29X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC29X" is
-- last update: 16/02/2021 20:30
 procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_numoffid          := (hcm_util.get_string(json_obj, 'p_numoffid'));
    p_codempid          := (hcm_util.get_string(json_obj, 'p_codempid'));

  end initial_value;
  ----------------------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    v_secur      boolean;
    v_permission boolean := false;

    cursor c1 is
              select t.numoffid, t.namempt, t.codempid, t.codsex, t.desexemp
              from tbcklst t
              where t.numoffid = nvl(p_numoffid,t.numoffid)
              and   t.codempid = nvl(p_codempid,t.codempid)
              order by t.numoffid;

  begin
    obj_row     := json();
    for r1 in c1 loop

              v_rcnt      := v_rcnt+1;
              v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
             -- if v_secur then
                  v_permission  := true;
                  obj_data    := json();
                  obj_data.put('codimage', get_emp_img (r1.codempid));
                  obj_data.put('numoffid', r1.numoffid);
                  obj_data.put('codempid', r1.codempid);
                  if r1.codempid is not null then
                    if get_temploy_name(r1.codempid, global_v_lang) <> '***************' then
                        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
                    else
                        obj_data.put('desc_codempid', r1.namempt);
                      end if;
                  else
                    obj_data.put('desc_codempid', r1.namempt);
                  end if;
                  obj_data.put('desc_codsex', get_tlistval_name('NAMSEX', r1.codsex, global_v_lang));
                  obj_data.put('desexemp', r1.desexemp);
                  obj_data.put('coderror', '200');

                  obj_row.put(to_char(v_rcnt-1),obj_data);
            --  end if;
    end loop;
    if v_rcnt = 0 then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tbcklst');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
    end if;
    if v_permission then
      -- 200 OK
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
      else
        -- error permisssion denied HR3007
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  end gen_index;
----------------------------------------------------------------------------------
procedure get_tbcklst_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_tbcklst_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tbcklst_detail;
----------------------------------------------------------------------------------
procedure gen_tbcklst_detail (json_str_output out clob) is
    obj_data                json;
    v_codempid              tbcklst.codempid%type       := '';
    v_numoffid              tbcklst.numoffid%type       := '';
    v_numappl               tbcklst.numappl%type        := '';
    v_codsex                tbcklst.codsex%type         := '';
    v_dteempdb              tbcklst.dteempdb%type       := '';
    v_numpasid              tbcklst.numpasid%type       := '';
    v_namlcompy             tbcklst.namlcompy%type      := '';
    v_codcomp               tbcklst.codcomp%type        := '';
    v_codpos                tbcklst.codpos%type         := '';
    v_dteempmt              tbcklst.dteempmt%type       := '';
    v_dteeffex              tbcklst.dteeffex%type       := '';
    v_desexemp              tbcklst.desexemp%type       := '';
    t_year		              number  				:= 0;
    t_month   	            number  				:= 0;
    t_day 		              number  				:= 0;
    v_yearlbl               varchar2(100) := get_label_name('HRRC29X1',global_v_lang,280);
    v_mthlbl                varchar2(100) := get_label_name('HRRC29X1',global_v_lang,290);

  begin
    begin
      select t.codempid,  t.numoffid,  t.numappl,    t.codsex,
             t.dteempdb,  t.numpasid,  t.namlcompy,  t.codcomp,
             t.codpos,    t.dteempmt,  t.dteeffex,   t.desexemp
      into   v_codempid,  v_numoffid,  v_numappl,    v_codsex,
             v_dteempdb,  v_numpasid,  v_namlcompy,  v_codcomp,
             v_codpos,    v_dteempmt,  v_dteeffex,   v_desexemp
      from   tbcklst t
      where  t.codempid  = p_codempid;

    exception when no_data_found then
      null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('numoffid', v_numoffid);
    obj_data.put('regno', v_numappl);
    obj_data.put('codsex', v_codsex);
    obj_data.put('desc_codsex', get_tlistval_name('NAMSEX', v_codsex, global_v_lang));
    obj_data.put('dteempdb', to_char(v_dteempdb, 'dd/mm/yyyy'));
    get_service_year(v_dteempdb,sysdate,'Y',t_year,t_month,t_day);
    if t_month = 0 then
      obj_data.put('age', t_year||' '||v_yearlbl);
    else
      obj_data.put('age', t_year||' '||v_yearlbl||' '||t_month||' '||v_mthlbl);
    end if;
    obj_data.put('passport', v_numpasid);
    obj_data.put('desc_company', get_tcenter_name(v_namlcompy, global_v_lang));
    obj_data.put('desc_department', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('desc_position', get_tpostn_name(v_codpos, global_v_lang));
    obj_data.put('stdate_work', to_char(v_dteempmt, 'dd/mm/yyyy'));
    obj_data.put('quitdate_work', to_char(v_dteeffex, 'dd/mm/yyyy'));
    obj_data.put('cause', v_desexemp);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tbcklst_detail;
----------------------------------------------------------------------------------
procedure get_list_mist (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_list_mist(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_list_mist;
----------------------------------------------------------------------------------
procedure gen_list_mist(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c2 is
            select  t.dteeffec, t.numhmref, t.dtemistk, t.codmist
            from    thismist t
            where   t.codempid  = p_codempid  and rownum <= 5
            order by t.dteeffec desc;
  begin

    obj_row     := json();

    for r2 in c2 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('offense_num', r2.numhmref);
      obj_data.put('offense_topic', get_tcodec_name('TCODMIST',r2.codmist, global_v_lang));
      obj_data.put('offense_date', to_char(r2.dteeffec, 'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_list_mist;
----------------------------------------------------------------------------------
procedure get_list_mist_all (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_list_mist_all(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_list_mist_all;
----------------------------------------------------------------------------------
procedure gen_list_mist_all(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c3 is
            select  t.dteeffec, t.numhmref, t.dtemistk, t.codmist, t.desmist1,
                    t2.typpun, t2.numseq, t2.dtestart, t2.dteend, t2.codpunsh
            from    thismist t , thispun t2
            where   t.codempid = t2.codempid (+)
            and     t.dteeffec = t2.dteeffec (+)
            and     t.codempid  = p_codempid
            order by t.dteeffec desc, t2.codpunsh, t2.numseq;
  begin

    obj_row     := json();

    for r3 in c3 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('offense_num', r3.numhmref);
      obj_data.put('offense_topic', get_tcodec_name('TCODMIST',r3.codmist, global_v_lang));
      obj_data.put('offense_date', to_char(r3.dteeffec, 'dd/mm/yyyy'));
      obj_data.put('offense_desc', r3.desmist1);
      obj_data.put('punish_type', get_tlistval_name('NAMTPUN', r3.typpun, global_v_lang));
      obj_data.put('punish_seq', r3.numseq);
      obj_data.put('punish_stdate', to_char(r3.dtestart, 'dd/mm/yyyy'));
      obj_data.put('punish_endate', to_char(r3.dteend, 'dd/mm/yyyy'));
      obj_data.put('punish_code', r3.codpunsh);
      obj_data.put('punish_desc', get_tcodec_name('TCODPUNH', r3.codpunsh, global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_list_mist_all;
----------------------------------------------------------------------------------

end HRRC29X;

/

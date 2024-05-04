--------------------------------------------------------
--  DDL for Package Body HRTR67X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR67X" is
-- last update: 15/02/2021 19:30
procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string(json_obj, 'p_lrunning');

    -- report params
    p_year                 := hcm_util.get_string(json_obj,'p_year');
    p_codcomp              := hcm_util.get_string(json_obj,'p_codcomp');
    p_codcours             := hcm_util.get_string(json_obj,'p_codcours');
    p_generation           := hcm_util.get_string(json_obj,'p_generation');
    p_codempid_query       := hcm_util.get_string(json_obj,'p_codempid_query');
    p_dtecrte              := to_date(hcm_util.get_string(json_obj,'p_dtecrte'),'dd/mm/yyyy'); ----
    p_codcrte              := hcm_util.get_string(json_obj,'p_codcrte');
    p_codcrte_position     := hcm_util.get_string(json_obj,'p_codcrte_position');
    p_remark               := hcm_util.get_string(json_obj,'p_remark');
    p_dtetrst              := hcm_util.get_string(json_obj,'p_dtetrst');
    p_dtetren              := hcm_util.get_string(json_obj,'p_dtetren');
    p_desc_codempid        := hcm_util.get_string(json_obj,'p_desc_codempid');
    p_dtecrte_2            := hcm_util.get_string(json_obj,'p_dtecrte');

    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');
    -- tprocapp
    p_codproc           := upper(hcm_util.get_string(json_obj, 'p_codproc'));
    -- report
    json_coduser        := hcm_util.get_json(json_obj, 'json_coduser');
    p_coduser           := upper(hcm_util.get_string(json_obj, 'p_coduser_query'));
    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));
  end initial_value;

  ----------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    ----------------------------------

    cursor cl_index is
      select t.codempid, t.flgtrevl, t.codcomp
      from thistrnn t
      where t.dteyear = p_year
      and t.codcomp like p_codcomp || '%'
      and t.codcours = p_codcours
      and t.numclseq = p_generation
      order by t.codempid;

  begin
    obj_row     := json();
    for cl in cl_index loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', cl.codempid);
      obj_data.put('image', get_emp_img (cl.codempid));
      obj_data.put('desc_codempid', get_temploy_name(cl.codempid,global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(cl.codcomp,global_v_lang));
      obj_data.put('result', get_tlistval_name ('FLGTREVL' , cl.flgtrevl, global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if isInsertReport = false then
       if v_rcnt = 0 then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
       end if;
    end if;

    if isInsertReport then
      insert_ttemprpt_thistrnn(obj_data);
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_index;
----------------------------------------------------------------------------------
  procedure get_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;
----------------------------------------------------------------------------------
  procedure gen_detail (json_str_output out clob) is
    obj_data                json;
    v_dtetrst               thisclss.dtetrst%type;
    v_dtetren               thisclss.dtetren%type;
    v_dtecrte               thisclss.dtecreate%type;
  begin
    begin
      select t.dtetrst,   t.dtetren,   sysdate
      into   v_dtetrst,   v_dtetren,   v_dtecrte
      from   thisclss t
      where  t.dteyear  = p_year  and t.codcompy = p_codcomp and
             t.codcours = p_codcours and t.numclseq = p_generation;

     exception when no_data_found then
      null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('dtetrst', to_char(v_dtetrst, 'dd/mm/yyyy'));
    obj_data.put('dtetren', to_char(v_dtetren, 'dd/mm/yyyy'));
    obj_data.put('dtecrte', to_char(v_dtecrte, 'dd/mm/yyyy'));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;
----------------------------------------------------------------------------------
  procedure check_index as
    v_tyrtrsch_count           tyrtrsch.numclseq%type;
    v_codcours                 thisclss.codcours%type;
    v_codtparg                 thisclss.codtparg%type;
    v_flgcerti                 thisclss.flgcerti%type;
  begin

    if p_year is not null then
      begin
        select count(t.codcours)
        into   v_tyrtrsch_count
        from   tyrtrsch t
        where  t.dteyear  = p_year  
        and    t.codcompy = p_codcomp 
        and    t.codcours = p_codcours 
        and    t.numclseq = p_generation;
      end;            
      begin
        select t.flgcerti, t.codtparg
        into   v_flgcerti, v_codtparg
        from   thisclss t
        where  t.dteyear  = p_year  
        and    t.codcompy = p_codcomp 
        and    t.codcours = p_codcours 
        and    t.numclseq = p_generation;
      exception when no_data_found then
        v_flgcerti := 'N';
        v_codtparg := null;
      end;

      if v_tyrtrsch_count > 0 and (v_flgcerti = 'N' or v_flgcerti is null) then ----
        param_msg_error := get_error_msg_php('TR0010', global_v_lang);
        return;
      end if;
      if v_codtparg <> '1' then ----
        param_msg_error := get_error_msg_php('TR0010', global_v_lang);
        return;
      end if;
        /*----
        if v_tyrtrsch_count = 0 then
           begin
              select t.codcours,   t.codtparg
              into   v_codcours,   v_codtparg
              from   thisclss t
              where  t.dteyear  = p_year  and t.codcompy = p_codcomp and
                     t.codcours = p_codcours and t.numclseq = p_generation;

           exception when no_data_found then
               v_flgcerti := 'N';
           end;

              if v_flgcerti = 'N' or v_flgcerti is null then
               param_msg_error := get_error_msg_php('TR0010', global_v_lang);
               return;
              end if ;
        end if ;

        if v_tyrtrsch_count = 1 then

           begin
              select t.codcours,   t.flgcerti, t.codtparg
              into   v_codcours,   v_flgcerti, v_codtparg
              from   thisclss t
              where  t.dteyear  = p_year  and t.codcompy = p_codcomp and
                     t.codcours = p_codcours and t.numclseq = p_generation;
            exception when no_data_found then
               v_flgcerti := 'N';
               v_codtparg := null;
            end;

              if v_flgcerti = 'N' or v_flgcerti is null then
               param_msg_error := get_error_msg_php('TR0010', global_v_lang);
               return;
              end if ;

              if v_codtparg > 1 then
               param_msg_error := get_error_msg_php('TR0010', global_v_lang);
               return;
              end if ;

        end if ;*/

    end if;
  end check_index;
----------------------------------------------------------------------------------------
  procedure check_dtecrte as
    v_dtetren        thisclss.dtetren%type;
  begin
    select t.dtetren
    into   v_dtetren
    from   thisclss t
    where  t.dteyear  = p_year  
    and    t.codcompy = p_codcomp 
    and    t.codcours = p_codcours 
    and    t.numclseq = p_generation;
  exception when no_data_found then
    v_dtetren := null;

    if p_dtecrte < v_dtetren then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_dtecrte;
----------------------------------------------------------------------------------------
  procedure update_dtecrte is
  begin
    begin
      update thistrnn set dtecrte = p_dtecrte
      where codempid  = p_codempid_query
      and   dteyear   = p_year
      and   codcomp   like p_codcomp || '%'
      and   codcours  = p_codcours
      and   numclseq  = p_generation;
    exception when others then
      null;
    end;
  end update_dtecrte;
----------------------------------------------------------------------------------------
  procedure clear_ttemprpt is
  begin
    delete ttemprpt
     where codempid = global_v_codempid
       and upper(codapp) like upper(p_codapp) || '%';
  end clear_ttemprpt;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thistrnn(obj_data in json) is
    v_numseq               number := 0;
    v_desc_codempid        varchar2(1000 char);
    v_adrcom               varchar2(1000 char);
    v_tinstitu             varchar2(10 char);
    v_flg_img              varchar2(1 char) := 'N';
    v_com_image            varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp ||'_MAIN';
    exception when no_data_found then
      null;
    end;
    -------------------------------------------------------------------
    begin
      select adrcomt, namimgcom
        into v_adrcom, v_com_image
        from tcompny
       where codcompy = p_codcomp;
    exception when no_data_found then
      null;
    end;
    -------------------------------------------------------------------
    begin
      select t.codinsts
      into  v_tinstitu
      from  thistrnn t
      where t.dteyear = p_year
      and t.codcomp   like p_codcomp || '%'
      and t.codcours  = p_codcours
      and t.numclseq  = p_generation
      and t.codempid  = p_codempid_query;
    exception when no_data_found then
      null;
    end;

    if v_com_image is not null then
      v_com_image   := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRCO01E1')||'/'||v_com_image;
      v_flg_img     := 'Y';
    end if;

    v_numseq                     := v_numseq + 1;
    v_desc_codempid              := p_desc_codempid;
    begin
      insert
        into ttemprpt
           (codempid, codapp, numseq,
             item1, item2, item3, item4, item5, item6, item7, item8, item9, item10,
             item11, item12)
      values
           (global_v_codempid, upper(p_codapp)||'_MAIN', v_numseq,
             upper(get_tcompny_name(p_codcomp,'101')),
             v_adrcom,
             v_desc_codempid,--3
             get_tcourse_name(p_codcours,global_v_lang),
             '(' || p_dtetrst || ' - ' ||p_dtetren || ')',
             get_tinstitu_name(v_tinstitu,global_v_lang),--รหัสสถาบัน
             p_remark,
             get_temploy_name(p_codcrte,global_v_lang),
             p_codcrte_position,
             p_dtecrte_2,
             v_com_image,
             v_flg_img);
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnn;
----------------------------------------------------------------------------------------
  procedure get_position (json_str_input in clob, json_str_output out clob) is
    obj_data        json;
    v_position      temploy1.codpos%type;
  begin
    initial_value (json_str_input);
    v_position := '';
    if param_msg_error is null then
      begin
        select codpos
        into   v_position
        from   temploy1
        where  codempid = p_codempid_query;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('position', get_tpostn_name(v_position, global_v_lang));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_position;
----------------------------------------------------------------------------------------
  procedure gen_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
    p_select_arr                    json;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_coduser.count-1 loop
        p_select_arr     := hcm_util.get_json(json_coduser, to_char(i));
        p_codempid_query := hcm_util.get_string(p_select_arr, 'codempid');
        p_desc_codempid  := hcm_util.get_string(p_select_arr, 'desc_codempid');
        gen_index(json_output);
        update_dtecrte;
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end gen_report;
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------
end HRTR67X;

/

--------------------------------------------------------
--  DDL for Package Body HRTR6FB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6FB" is
-- last update: 28/12/2020 17:40
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
    p_codcomp              := hcm_util.get_string(json_obj,'p_codcompy');
    p_codcompy             := hcm_util.get_string(json_obj,'p_codcompy');
    p_codcours             := hcm_util.get_string(json_obj,'p_codcours');
    p_generation           := hcm_util.get_string(json_obj,'p_generation');
    p_typtest              := hcm_util.get_string(json_obj,'p_typtest');
    p_qtyscore             := hcm_util.get_string(json_obj,'p_qtyscore');
    p_dtetrst              := to_date(json_ext.get_string(json_obj,'p_dtetrst'),'dd/mm/yyyy');
    p_dtetren              := to_date(json_ext.get_string(json_obj,'p_dtetren'),'dd/mm/yyyy');

    -- save index
    json_params         := hcm_util.get_json(json_obj, 'params');
    -- tprocapp
    p_codproc           := upper(hcm_util.get_string(json_obj, 'p_codproc'));
    -- report
    json_coduser        := hcm_util.get_json(json_obj, 'json_coduser');
    p_coduser           := upper(hcm_util.get_string(json_obj, 'p_coduser_query'));
    p_codapp            := upper(hcm_util.get_string(json_obj, 'p_codapp'));
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);--4. TR Module #2983
  end initial_value;
----------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------
  procedure check_generation as
    v_generation        varchar2(4 char) ;
  begin
    -------------------------------------------------
    if p_generation is null then
       begin
        select t.numclseq
        into   v_generation
        from   thistrnn t
        where  t.dteyear  = p_year
        and    t.codcomp like p_codcompy || '%'
        and    t.codcours = p_codcours
        and    t.dtetrst  = p_dtetrst
        and    t.dtetren  = p_dtetren
        and    rownum = '1';

        p_generation := v_generation;
       exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thistrnn');
        return;
      end;
    end if;

  end check_generation;
----------------------------------------------------------------------------------------
  procedure check_thisclss as
    v_generation        varchar2(4 char) ;
  begin
    -------------------------------------------------
    if p_generation is not null then
       begin
        select t.numclseq
        into   v_generation
        from   thisclss t
        where  t.dteyear  = p_year
        and    t.codcompy = p_codcompy
        and    t.codcours = p_codcours
        and    t.numclseq  = p_generation;

       exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'thisclss');
        return;
      end;
    end if;

  end check_thisclss;
----------------------------------------------------------------------------------------
  procedure update_qtyscr (json_str_input in clob, json_str_output out clob) is
    json_row               json;
    v_qtyscore             varchar2(100 char);
    v_codempid             varchar2(100 char);
    v_status               varchar2(2 char);


  begin
    initial_value (json_str_input);
    check_generation;
    check_thisclss;

    if param_msg_error is null then
      for i in 0..json_params.count - 1 loop
        json_row          := hcm_util.get_json(json_params, to_char(i));
        v_codempid        := hcm_util.get_string(json_row, 'codempid');
        v_qtyscore        := hcm_util.get_string(json_row, 'qtyscore');
        v_status          := hcm_util.get_string(json_row, 'status');

        if v_status = 'Y' then

           if p_typtest = '1' then
             begin
            update thistrnn
             set   qtyprescr = round(v_qtyscore,2),
                   coduser   = global_v_coduser
             where codempid = v_codempid
               and dteyear = p_year
               and codcomp like p_codcompy || '%'
               and codcours = p_codcours
               and numclseq = p_generation;
               exception when others then
                param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                json_str_output := get_response_message(400, param_msg_error , global_v_lang);
                rollback ;
                return ;
             end;
           end if ;

           if p_typtest = '2' then
               begin
              update thistrnn
               set   qtyposscr = round(v_qtyscore,2),
                     coduser   = global_v_coduser
               where codempid = v_codempid
                 and dteyear = p_year
                 and codcomp like p_codcompy || '%'
                 and codcours = p_codcours
                 and numclseq = p_generation;
                 exception when others then
                  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                  json_str_output := get_response_message(400, param_msg_error , global_v_lang);
                  rollback ;
                  return ;
              end;
            end if ;
        end if;
      end loop;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end update_qtyscr;
----------------------------------------------------------------------------------------
procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json;
    obj_data        json;
    obj_result      json;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;
    v_sumall        number  := 0;


  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
      v_sumall        := v_rec_tran + v_rec_err;
      if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return ;
      end if ;
    end if;

    obj_row    := json();
    obj_result := json();
    obj_row.put('coderror', '200');
    obj_row.put('complete', v_rec_tran);
    obj_row.put('error', v_rec_err);
    obj_row.put('total', v_sumall);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json();
        obj_data.put('coderror', '200');
        obj_data.put('remark', p_error_code(i));
        obj_data.put('status', p_status(i));
        obj_data.put('desc_status', p_desc_status(i));
        obj_data.put('desc_status_txt', p_desc_status_txt(i));
        obj_data.put('codempid', p_colcodempid(i));
        obj_data.put('qtyscore', p_colqtys(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_import_process;
----------------------------------------------------------------------------------
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json      json;
    param_json_row  json;
    json_obj_list   json_list;
    --
    linebuf       varchar2(6000 char);
    data_file     varchar2(6000 char);
    v_column      number := 2;
    v_error       boolean;
    v_err_code    varchar2(1000 char);
    v_err_filed   varchar2(1000 char);
    v_err_table   varchar2(20 char);
    i             number;
    j             number;
    v_numseq      number := 0;
    v_codcomp	 		            temploy1.codcomp%type;
    v_staemp                  temploy1.staemp%type;
    v_check_codcompy          tcenter.codcompy%type;
    v_chkcodempid             varchar2(100 char);

    -------------------------------------------
    v_codempid    varchar2(100 char);
    v_qtyscore    varchar2(100 char);
    v_status      varchar2(100 char);
    -------------------------------------------

    v_cnt         number := 0;

    type text is table of varchar2(1000) index by binary_integer;
      v_text   text;
      v_filed  text;
    type arr_int is table of integer index by binary_integer;
      v_text_len arr_int ;

  begin

    v_rec_tran  := 0;
    v_rec_error := 0;

    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;

    param_json := hcm_util.get_json(json(json_str_input),'json_coduser');

    for i in 0..param_json.count-1 loop
        param_json_row  := json(param_json.get(to_char(i)));
        json_obj_list   := param_json_row.get_values;

    begin

        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        linebuf     := i;
        v_numseq    := v_numseq;
        v_error     := false;
        --------------------------------------

        v_codempid     := hcm_util.get_string(param_json_row,'codempid'); -- 1
        v_qtyscore     := hcm_util.get_string(param_json_row,'qtyscore'); -- 2


        v_text(1)   := v_codempid;   v_text(2)   := v_qtyscore;

        v_filed(1)  := 'codempid';   v_filed(2)  := 'qtyscore';

        v_text_len(1)  := 10;        v_text_len(2)  := 10;
        data_file := null;

        for j in 1..2 loop
            ------------------------------------------------
            if data_file is null then
                data_file := v_text(j);
              else
                data_file := data_file||','||v_text(j);
            end if;
            ------------------------------------------------
            if nvl(length(v_text(j)),0) > v_text_len(j) then
               v_error	 	 := true;
               v_err_code  := 'HR6591';--HR6591-ข้อมูลเกินข้อจำกัดของระบบ
               v_err_filed := null/*upper(v_filed(j))*/ ;
               continue ;
            end if ;
            ------------------------------------------------    3
            if not v_error then
              if j in (1,2) then
                if v_text(j) is null then
                   v_error	 	 := true;
                   v_err_code  := 'HR2045';
                   v_err_filed := upper(v_filed(j)) ;
                end if ;
              end if ;
              ------------------------------------------------------------
              if j in (1) then
                 if not v_error then
                  begin
                    select t1.codcomp,t1.staemp,t2.codcompy
                      into v_codcomp,v_staemp,v_check_codcompy
                      from temploy1 t1
                      left join tcenter t2 on t2.codcomp = t1.codcomp
                     where t1.codempid = upper(v_text(j));
                  exception when no_data_found then
                  ------ ไม่มีอยู่ในตาราง temploy1
                    v_error     := true;
                    v_err_code  := 'HR2010';--HR2010-ข้อมูลไม่มีอยู่ในฐานข้อมูล
                    v_err_table := 'TEMPLOY1';
                    v_err_filed := 'TEMPLOY1'/*upper(v_filed(j))*/;
                  end;
            --4. TR Module #2983
                  ------- secure 3007
                    if not secur_main.secur2(upper(v_text(j)), global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
                        v_error     := true;
                        v_err_code  := 'HR3007' ;--HR3007-ท่านไม่มีสิทธิ์นำข้อมูลมาใช้งาน
                        v_err_filed := null/*upper(v_filed(j))*/;
                    end if;
            --4. TR Module #2983
                  ------- staemp พนักงาน 0
                  if v_staemp = '0' then
                    v_error     := true;
                    v_err_code  := 'HR2102' ;--HR2102-พนักงานใหม่ยังไม่ผ่านการยืนยันการเป็นพนักงาน
                    v_err_filed := null/*upper(v_filed(j))*/;
                  --end if;
                  ------- p_codcomp พนักงาน ต้องอยู่ในบริษัท
                  elsif v_check_codcompy != p_codcompy then
                    v_error     := true;
                    v_err_code  := 'HR7523' ;--HR7523-พนักงานท่านนี้ไม่อยู่ในหน่วยงานที่ระบุ
                    v_err_filed := null/*upper(v_filed(j))*/;
                  elsif not v_error then
                    begin
                    select t2.codempid
                      into v_chkcodempid
                      from thistrnn t2
                     where t2.codempid  = upper(v_text(j))
                       and t2.dteyear   = p_year
                       and t2.codcomp   like p_codcompy || '%'
                       and t2.codcours  = p_codcours
                       and t2.numclseq  = nvl(p_generation,t2.numclseq)--numclseq >> p_numperiod
                       and rownum = '1';
                    exception when no_data_found then
                    ------ ไม่มีอยู่ในตาราง thistrnn
                      v_error     := true;
                      v_err_code  := 'HR2010';--HR2010-ข้อมูลไม่มีอยู่ในฐานข้อมูล
                      v_err_table := 'THISTRNN';
                      v_err_filed := 'THISTRNN'/*upper(v_filed(j))*/;
                    end;
                  end if;
                 end if ;
              end if ;
              ----------------------------------------------------------------
              if j in (2) then
                 if not v_error then
                  if check_is_number(v_text(j)) != 1 then
                     v_error	 	 := true;
                     v_err_code  := 'HR2020';--HR2020-โปรดแก้ไขข้อมูลที่ไม่ถูกต้อง
                     v_err_filed := upper(v_filed(j)) ;
                  end if ;
                 end if ;
                 -- คะแนนติดลบ
                if not v_error then
                  if check_is_number(v_text(j)) = 1 then
                   if v_text(j) < 0 then
                     v_error	 	 := true;
                     v_err_code  := 'HR2020';--HR2020-โปรดแก้ไขข้อมูลที่ไม่ถูกต้อง
                     v_err_filed := upper(v_filed(j)) ;
                   end if;
                  end if ;
                 end if ;
              end if ;
            end if ;
            ------------------------------------------------
        end loop;

        if not v_error then
              v_rec_tran          := v_rec_tran + 1;
              v_cnt               := v_cnt+1;
              p_text(v_cnt)       := data_file;
              p_error_code(v_cnt) := '';
              p_colcodempid(v_cnt):= v_codempid;
              p_colqtys(v_cnt)    := v_qtyscore;
              p_status(v_cnt)     := 'Y';
              p_desc_status(v_cnt):= '<i class="fas fa-check _text-green"></i>';
              v_status := get_label_name('HRTR6FB1',global_v_lang,130);--'complete';
              p_desc_status_txt(v_cnt):= v_status;   
              p_numseq(v_cnt)     := i;
          else
              v_rec_error         := v_rec_error + 1;
              v_cnt               := v_cnt+1;
              p_text(v_cnt)       := data_file;
              if v_err_filed is null then
                p_error_code(v_cnt) := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang);
              else
                p_error_code(v_cnt) := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||'['||v_err_filed||']';
              end if;
--           p_error_code(v_cnt) := v_err_code||' '||get_errorm_name(v_err_code,global_v_lang)||'['||v_err_filed||']';--replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table),'@#$%400',null)||'['||v_err_filed||']';
              p_colcodempid(v_cnt):= v_codempid;
              p_colqtys(v_cnt)    := v_qtyscore;
              p_status(v_cnt)     := 'N';
              p_desc_status(v_cnt):= '<i class="fas fa-times _text-red"></i>';
              v_status := get_label_name('HRTR6FB1',global_v_lang,140);--Error
              p_desc_status_txt(v_cnt):= v_status;   
              p_numseq(v_cnt)     := i;
          end if ;

    end ;
    end loop ;
  end format_text_json ;
--------------------------------------------------------------------------------------
  function check_is_number(p_string IN VARCHAR2) return integer IS
      v_new_num           number :=0 ;
    begin
            v_new_num := TO_NUMBER(p_string); return 1;
            if v_new_num >= 0 then return 1; else return 0; end if;
            exception when VALUE_ERROR then return 0;
  end check_is_number;
----------------------------------------------------------------------------------------

end HRTR6FB;

/

--------------------------------------------------------
--  DDL for Package Body HRTR75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR75X" is
-- last update: 11/09/2020 15:45

  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index--
    p_codcompy              := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_dteyear               := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_codcours              := hcm_util.get_string_t(json_obj,'p_codcours');
    p_numclseq              := hcm_util.get_string_t(json_obj,'p_numclseq');
    p_codform               := hcm_util.get_string_t(json_obj,'p_codform');
    p_numgrup               := hcm_util.get_string_t(json_obj,'p_numgrup');

    p_codinst               := hcm_util.get_string_t(json_obj,'p_codinst');
    p_codsubj               := hcm_util.get_string_t(json_obj,'p_codsubj');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1)   := 'N';
    v_chkSecur  varchar2(1) := 'N';

    cursor c1 is
        select codcompy
          from tcompny
         where codcompy = p_codcompy;
  begin
    if  p_codcompy is not null then
        for i in c1 loop
            v_data  := 'Y';
            v_flgSecur := secur_main.secur7(p_codcompy,global_v_coduser);
            if v_flgSecur then
                v_chkSecur  := 'Y';
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        elsif v_chkSecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
  end;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	  boolean;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    v_qtynumcl      tyrtrpln.qtynumcl%type;
    cursor c1 is
         select b.codcate,a.codcours,sum(a.qtyppcac) qtyppcac,count(a.numclseq) numclseq,
           sum(a.amttotexp) amttotexp,a.codcompy, a.dteyear
           from thisclss a ,tcourse b
          where a.codcours = b.codcours
             and a.dteyear = p_dteyear
             and a.codcompy = nvl(p_codcompy,a.codcompy)
       group by b.codcate, a.codcours, a.codcompy, a.dteyear
       order by b.codcate, a.codcours;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata   := 'Y';
        v_flgsecu   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcate',i.codcate);
        obj_data.put('desc_codcate',get_tcodec_name('TCODCATE',i.codcate,global_v_lang));
        obj_data.put('codcours',i.codcours);
        obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('qtyppcac',i.qtyppcac);
        obj_data.put('numclseq',i.numclseq);
        obj_data.put('amttotexp',i.amttotexp);
        begin
            select amtclbdg , qtynumcl
              into v_amtclbdg, v_qtynumcl
              from tyrtrpln
             where dteyear = i.dteyear
               and codcompy = i.codcompy
               and codcours = i.codcours;
        exception when others then
            v_amtclbdg := 0;
            v_qtynumcl := 0;
        end;
        obj_data.put('amtclbdg',(v_amtclbdg * v_qtynumcl ));
        obj_data.put('dteyear',i.dteyear);
        obj_data.put('codcompy',i.codcompy);
        obj_data.put('desc_codcompy',get_tcenter_name(i.codcompy,global_v_lang));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISCLSS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;  -- procedure gen_index

  procedure get_course_internal(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_course_internal(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_course_internal (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	    boolean;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    cursor c1 is
         select numclseq,dtetrst,dtetren,codtparg,codhotel,codinsts,qtyppc,amttotexp,amtcost
           from thisclss
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
       order by numclseq;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata   := 'Y';
        v_flgsecu   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numclseq', i.numclseq);
        obj_data.put('dtetrst', to_char(i.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('codtparg', get_tlistval_name('CODTPARG',i.codtparg,global_v_lang));
        obj_data.put('codhotel', get_thotelif_name(i.codhotel,global_v_lang));
        obj_data.put('codinsts', get_tinstitu_name(i.codinsts,global_v_lang));
        obj_data.put('qtyppc', i.qtyppc);
        obj_data.put('amttotexp', i.amttotexp);
        obj_data.put('amtcost', i.amtcost);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISCLSS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;  -- procedure gen_course_internal


  procedure get_training_class(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_training_class(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_training_class (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	    boolean;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    v_qtytrmin       varchar2(10);

    cursor c1 is
         select *
           from thisclss
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and numclseq = p_numclseq;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata   := 'Y';
        v_flgsecu   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcours', i.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(i.codcours,global_v_lang));
        obj_data.put('numclseq', i.numclseq);
        obj_data.put('objective', i.objective);
        obj_data.put('codresp', i.codresp);
        obj_data.put('desc_codresp', get_temploy_name(i.codresp,global_v_lang));
        obj_data.put('codhotel', i.codhotel);
        obj_data.put('desc_codhotel', get_thotelif_name(i.codhotel,global_v_lang));
        obj_data.put('codinsts', i.codinsts);
        obj_data.put('desc_codinsts', get_tinstitu_name(i.codinsts,global_v_lang));
        obj_data.put('dtetrst', to_char(i.dtetrst,'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(i.dtetren,'dd/mm/yyyy'));
        obj_data.put('qtyppcac', nvl(i.qtyppcac,0));
        obj_data.put('v_qtytrmin', get_format_hhmm(i.qtytrmin) );  --i.qtytrmin  Exe. 1:30, 0:05

        obj_data.put('amttotexp',  to_char(i.amttotexp, 'fm999,999,990.00'));
        obj_data.put('amtcost',  to_char(i.amtcost, 'fm999,999,990.00'));
        obj_data.put('numcert', i.numcert);
        obj_data.put('dtecert', to_char(i.dtecert,'dd/mm/yyyy'));
        obj_data.put('typtrain', get_tlistval_name('TYPTRAIN',i.typtrain,global_v_lang));
        obj_data.put('descomptr', i.descomptr);
        if i.flgcerti = 'Y' then
            obj_data.put('flgcerti', get_label_name('HRTR75X2',global_v_lang,'350'));
        else
            obj_data.put('flgcerti', get_label_name('HRTR75X2',global_v_lang,'360'));
        end if;
        obj_data.put('dteprest', to_char(i.dteprest,'dd/mm/yyyy'));
        obj_data.put('dtepreen', to_char(i.dtepreen,'dd/mm/yyyy'));
        obj_data.put('codexampr', i.codexampr ||' - '||get_tcodec_name('TCODEXAM',i.codexampr,global_v_lang));
        obj_data.put('dtepostst', to_char(i.dtepostst,'dd/mm/yyyy'));
        obj_data.put('dteposten', to_char(i.dteposten,'dd/mm/yyyy'));
        obj_data.put('codexampo', i.codexampo ||' - '||get_tcodec_name('TCODEXAM',i.codexampo,global_v_lang));
        obj_data.put('qtytrflw', i.qtytrflw);
        if i.flgcommt = 'Y' then
            obj_data.put('flgcommt', get_label_name('HRTR75X2',global_v_lang,'370'));
        else
            obj_data.put('flgcommt', get_label_name('HRTR75X2',global_v_lang,'380'));
        end if;
        obj_data.put('dtecomexp', to_char(i.dtecomexp,'dd/mm/yyyy'));
        obj_data.put('descommt', i.descommt);
        obj_data.put('descommtn', i.descommtn);
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'THISCLSS');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end gen_training_class;


  procedure get_expense_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_expense_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_expense_detail (json_str_output out clob) is
    obj_data        json_object_t;
    v_codcurr       tcosttr.codcurr%type;
  begin
    begin
        select codcurr
          into v_codcurr
          from tcosttr
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
           and rownum = 1;
    exception when others then
        v_codcurr := '';
    end;

    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcurr', get_tcodec_name('TCODCURR',v_codcurr,global_v_lang));
    json_str_output := obj_data.to_clob;
  end;  -- procedure gen_expense_detail

  procedure get_expense_table(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_expense_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_expense_table (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_desc_codexpn tcodexpn.descode%type;

    cursor c1 is
        select codexpn,amtcost,amttrcost
          from tcosttr
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
      order by codexpn;
  begin
    obj_row := json_object_t();
    for i in c1 loop

        begin select decode(global_v_lang, '101', descode,
                                         '102', descodt,
                                         '103', descod3,
                                         '104', descod4,
                                         '105', descod5)
              into v_desc_codexpn
              from tcodexpn
              where codexpn = i.codexpn;
        exception when no_data_found then
              v_desc_codexpn := null;
        end;

        v_rcnt := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codexpn', i.codexpn);
        obj_data.put('desc_codexpn', v_desc_codexpn);
        obj_data.put('amtcost', i.amtcost);
        obj_data.put('amttrcost', i.amttrcost);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_expense_table
  --

  procedure get_employee_training_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_employee_training_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_employee_training_detail (json_str_output out clob) is
    obj_data        json_object_t;
    v_codcurr       tcosttr.codcurr%type;
    v_numemp        number;
  begin
    begin
        select count(codempid)
          into v_numemp
          from thistrnn
         where dteyear = p_dteyear
           and hcm_util.get_codcomp_level(codcomp,1) = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
    exception when others then
        v_numemp := 0;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('v_numemp', v_numemp);
    json_str_output := obj_data.to_clob;
  end;  -- procedure gen_employee_training_detail

  procedure get_employee_training_table(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_employee_training_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_employee_training_table (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_qtytrhr       number :=0;

    cursor c1 is
        select codempid,codcomp,qtyprescr,qtyposscr,flgtrevl,remarks,qtytrpln,qtytrmin
          from thistrnn
         where dteyear = p_dteyear
           and hcm_util.get_codcomp_level(codcomp,1) = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
  begin
    obj_row := json_object_t();
    for i in c1 loop
        obj_data    := json_object_t();
        v_rcnt := v_rcnt+1;
        obj_data.put('coderror', '200');
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('qtyprescr', i.qtyprescr);
        obj_data.put('qtyposscr', i.qtyposscr);
        obj_data.put('flgtrevl', i.flgtrevl);
        --obj_data.put('temp1', greatest(0,i.qtytrpln - i.qtytrmin));
        v_qtytrhr  := greatest(0,(i.qtytrpln - i.qtytrmin));
        obj_data.put('temp1', get_format_hhmm(v_qtytrhr));  --Exe.1:30, 0:03

        obj_data.put('remarks', i.remarks);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_employee_training_table

  procedure get_course_evaluation_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_course_evaluation_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_course_evaluation_detail (json_str_output out clob) is
    obj_data        json_object_t;
    v_numemp        number;
    v_codform       thisclss.codform%type;
  begin
    begin
        select codform
          into v_codform
          from thisclss
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
    exception when others then
        v_codform := null;
    end;
    begin
        select count(codempid)
          into v_numemp
          from thistrnn
         where dteyear = p_dteyear
           and hcm_util.get_codcomp_level(codcomp,1) = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
    exception when others then
        v_numemp := 0;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codform', v_codform);
    obj_data.put('desc_codform', get_tintview_name(v_codform,global_v_lang));
    obj_data.put('qtyppcac', v_numemp);
    json_str_output := obj_data.to_clob;
  end;  -- procedure gen_course_evaluation_detail

   procedure get_course_evaluation_table1(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_course_evaluation_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_course_evaluation_table1 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_codform       thisclss.codform%type;
    v_qtyscore      tcoursapg.qtyscore%type;

    cursor c1 is
        select codform, numgrup, qtyfscor
          from tintvews
         where codform = v_codform
      order by numgrup;
  begin
    begin
        select codform
          into v_codform
          from thisclss
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq;
    exception when others then
        v_codform := null;
    end;

    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numgrup', i.numgrup);
        obj_data.put('desc_numgrup', get_tintvews_name(v_codform,i.numgrup,global_v_lang));
        obj_data.put('qtyfscor', i.qtyfscor);
        begin
            select qtyscore
              into v_qtyscore
              from tcoursapg
             where dteyear = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq
               and numgrup = i.numgrup;
        exception when others then
            v_qtyscore := 0;
        end;
        obj_data.put('qtyscore', v_qtyscore);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_course_evaluation_table1

   procedure get_course_evaluation_table2(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_course_evaluation_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_course_evaluation_table2 (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;

    cursor c1 is
        select descomment
          from tcoursugg
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
      order by numseq;
  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('descomment', i.descomment);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_course_evaluation_table2

  procedure get_instructor_evaluation(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_instructor_evaluation(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_instructor_evaluation (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    v_stainst      tinstruc.stainst%type;
    cursor c1 is
         select *
           from thisinst
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and numclseq = p_numclseq
       order by codinst,codsubj;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codinst', i.codinst);
        obj_data.put('desc_codinst', get_tinstruc_name(i.codinst,global_v_lang));
        begin
            select stainst
              into v_stainst
              from tinstruc
             where codinst = i.codinst;
        exception when others then
            v_stainst := null;
        end;
        obj_data.put('stainst', get_tlistval_name('STAINST',v_stainst,global_v_lang));
        obj_data.put('codsubj', i.codsubj);
        obj_data.put('desc_codsubj', get_tsubject_name(i.codsubj,global_v_lang));
        obj_data.put('qtyscore', i.qtyscore);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_instructor_evaluation


  procedure get_summary_information(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_summary_information(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_summary_information (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    v_stainst      tinstruc.stainst%type;
    cursor c1 is
         select *
           from tknowleg
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and numclseq = p_numclseq
       order by itemno;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('subject', i.subject);
--        obj_data.put('codknowl', i.codknowl);
        obj_data.put('details', i.details);
        obj_data.put('attfile', i.attfile);
        obj_data.put('path_filename', get_tsetup_value('PATHDOC')||get_tfolderd('HRTR63E')|| '/' || i.attfile);
        obj_data.put('path_link', i.url);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_summary_information

  procedure get_other_information(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_other_information(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_other_information (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_amtclbdg      tyrtrpln.amtclbdg%type;
    v_stainst      tinstruc.stainst%type;
    cursor c1 is
         select descomment
           from thisclsss
          where dteyear = p_dteyear
            and codcompy = p_codcompy
            and codcours = p_codcours
            and numclseq = p_numclseq
       order by numseq;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('descomment', i.descomment);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;  -- procedure gen_other_information


  procedure get_instructor_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_instructor_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_instructor_detail (json_str_output out clob) is
    obj_data        json_object_t;
    v_codform       thisinst.codform%type;
    v_stainst         tinstruc.stainst%type;

  begin
    begin
        select codform
          into v_codform
          from thisinst
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
           and codinst = p_codinst
           and codsubj = p_codsubj;
    exception when others then
        v_codform := null;
    end;

    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
     begin
         select stainst  into v_stainst
           from tinstruc
          where codinst = p_codinst;
     exception when others then
         v_stainst := null;
     end;

    obj_data.put('codform', v_codform);
    obj_data.put('desc_codform', get_tintview_name(v_codform,global_v_lang));
    obj_data.put('desc_codinst', get_tinstruc_name(p_codinst,global_v_lang));
    obj_data.put('codsubj',  get_tsubject_name(p_codsubj,global_v_lang));
    obj_data.put('stainst', get_tlistval_name('STAINST',v_stainst,global_v_lang));

    json_str_output := obj_data.to_clob;
  end gen_instructor_detail;

  procedure get_instructor_table(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_instructor_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_instructor_table (json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_codform       thisclss.codform%type;
    v_qtyscore      tcoursapg.qtyscore%type;

    cursor c1 is
        select codform, numgrup, qtyfscor
          from tintvews
         where codform = v_codform
      order by numgrup;

  begin
    begin
        select codform
          into v_codform
          from thisinst
         where dteyear = p_dteyear
           and codcompy = p_codcompy
           and codcours = p_codcours
           and numclseq = p_numclseq
           and codinst = p_codinst
           and codsubj = p_codsubj;
    exception when others then
        v_codform := null;
    end;

    obj_row := json_object_t();
    for i in c1 loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numgrup', i.numgrup);
        obj_data.put('desc_numgrup', get_tintvews_name(v_codform,i.numgrup,global_v_lang));
        obj_data.put('qtyfscor', i.qtyfscor);

        	begin
             select qtyscore into v_qtyscore
               from tinstapg
              where dteyear		  = p_dteyear
                  and codcompy   = p_codcompy
                  and codcours	= p_codcours
                  and numclseq 	= p_numclseq
                  and codinst  	   = p_codinst
                  and codsubj   	= p_codsubj
                  and numgrup   = i.numgrup;
            exception when no_data_found then
                 v_qtyscore :=null;
         end;

        obj_data.put('qtyscore', v_qtyscore);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end gen_instructor_table;

  procedure get_subcourse_evaluation(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_subcourse_evaluation(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_subcourse_evaluation;

  procedure gen_subcourse_evaluation(json_str_output out clob) is

    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;
    v_rcnt                number := 0;
    v_rcnt2              number := 0;
    v_typabs            varchar2(100 char);

    v_codform            thisclss.codform%type;
    v_numgrup           tintvews.numgrup%type;
    v_grade               tcoursapi.grade%type;
    v_qtyscore           tcoursapi.qtyscore%type;

    cursor c_tintvews is
        select codform,numgrup,decode(global_v_lang,'101',desgrupe,
                                                  '102',desgrupt,
                                                  '103',desgrup3,
                                                  '104',desgrup4,desgrup5) namgroup

          from tintvews
         where codform = p_codform
      order by numgrup;

    cursor c_tintvewd is
        select numgrup,numitem,
               decode(global_v_lang,'101',desiteme,
                                    '102',desitemt,
                                    '103',desitem3,
                                    '104',desitem4,desitem5) namitem,
               decode(global_v_lang,'101',definitt,
                                    '102',definite,
                                    '103',definit3,
                                    '104',definit4,definit5) definit,
               qtyfscor,qtywgt
          from tintvewd
         where codform  = p_codform
           and numgrup = v_numgrup
      order by numitem;

  begin
    obj_row := json_object_t();

    v_rcnt  := 0;
    for c1 in c_tintvews loop
      v_rcnt              := v_rcnt+1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codform', c1.codform);
      obj_data.put('desc_codform', get_tintview_name(c1.codform,global_v_lang));
      obj_data.put('numgrup', c1.numgrup);
      obj_data.put('desc_numgrup', c1.namgroup);
      v_numgrup           := c1.numgrup;

      v_rcnt2               := 0;
      obj_row_child         := json_object_t();
      for c2 in c_tintvewd loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

        begin
          select grade ,qtyscore into v_grade , v_qtyscore
            from tcoursapi
           where dteyear = p_dteyear
             and codcompy = p_codcompy
             and codcours = p_codcours
             and numclseq = p_numclseq
             and numgrup  = c2.numgrup
             and numitem  = c2.numitem;
         exception when no_data_found then
            v_grade         := null;
            v_qtyscore      := 0;
         end;

        obj_data_child.put('numitem', c2.numitem);
        obj_data_child.put('desc_numitem', c2.namitem);
        obj_data_child.put('definit', c2.definit);
        obj_data_child.put('qtywgt', c2.qtywgt);
        obj_data_child.put('grade', v_grade );
        obj_data_child.put('qtyscor', v_qtyscore);
        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;

      obj_data.put('children', obj_row_child);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;

  end gen_subcourse_evaluation;

  procedure get_sub_instructor(json_str_input in clob, json_str_output out clob) is
   begin
    initial_value(json_str_input);
    if param_msg_error is null then
        gen_sub_instructor(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_sub_instructor;

  procedure gen_sub_instructor(json_str_output out clob) is

    obj_row           json_object_t;
    obj_data          json_object_t;
    obj_row_child     json_object_t;
    obj_data_child    json_object_t;
    v_rcnt                number := 0;
    v_rcnt2              number := 0;
    v_typabs            varchar2(100 char);

    v_codform            thisclss.codform%type;
    v_numgrup           tintvews.numgrup%type;
    v_grade               tcoursapi.grade%type;
    v_qtyscore           tcoursapi.qtyscore%type;

    cursor c_tintvews is
      select codform,numgrup,decode(global_v_lang,'101',desgrupe,
                                                                     '102',desgrupt,
                                                                     '103',desgrup3,
                                                                     '104',desgrup4,desgrup5) namgroup

        from tintvews
      where codform = p_codform
    order by numgrup;

      cursor c_tintvewd is
      select numgrup,numitem,
      decode(global_v_lang,'101',desiteme,
                                   '102',desitemt,
                                   '103',desitem3,
                                   '104',desitem4,desitem5) namitem,
      decode(global_v_lang,'101',definitt,
                                  '102',definite,
                                  '103',definit3,
                                  '104',definit4,definit5) definit,
                                  qtyfscor,qtywgt
        from tintvewd
      where codform  = p_codform
          and numgrup = v_numgrup
   order by numitem;

  begin

    obj_row := json_object_t();
    v_rcnt  := 0;
    for c1 in c_tintvews loop
      v_rcnt              := v_rcnt+1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codform', c1.codform);
      obj_data.put('desc_codform', get_tintview_name(c1.codform,global_v_lang));
      obj_data.put('numgrup', c1.numgrup);
      obj_data.put('desc_numgrup', c1.namgroup);
      v_numgrup           := c1.numgrup;

      v_rcnt2              := 0;
      obj_row_child       := json_object_t();
      for c2 in c_tintvewd loop
        v_rcnt2             := v_rcnt2+1;
        obj_data_child      := json_object_t();
        obj_data_child.put('coderror', '200');

        begin
          select grade ,qtyscore into v_grade , v_qtyscore
            from tinstapi
           where dteyear	   = p_dteyear
             and codcompy   = p_codcompy
               and codcours   = p_codcours
               and numclseq  = p_numclseq
               and codinst     = p_codinst
               and codsubj    = p_codsubj
               and numgrup  = c2.numgrup
               and numitem  = c2.numitem;
            exception when no_data_found then
                 v_grade      := null;
                 v_qtyscore  := 0;
         end;

        obj_data_child.put('numitem', c2.numitem);
        obj_data_child.put('desc_numitem', c2.namitem);
        obj_data_child.put('definit', c2.definit);
        obj_data_child.put('qtywgt', c2.qtywgt);
        obj_data_child.put('grade', v_grade );
        obj_data_child.put('qtyscor', v_qtyscore);
        obj_row_child.put(to_char(v_rcnt2-1), obj_data_child);
      end loop;

      obj_data.put('children', obj_row_child);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_sub_instructor;

  function get_format_hhmm (p_qtyhour    number) return varchar2 is
    v_qtytrmin          varchar2(10);
  begin
        begin
            v_qtytrmin := trunc(p_qtyhour)||':'||lpad(mod(nvl(p_qtyhour,0),1)*100,2,'0');
           exception when others then
             v_qtytrmin := null;
        end;
        return v_qtytrmin;
  end get_format_hhmm;

end;

/

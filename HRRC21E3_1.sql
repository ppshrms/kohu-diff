--------------------------------------------------------
--  DDL for Package Body HRRC21E3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E3" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    b_index_numappl     := hcm_util.get_string_t(json_obj,'p_numappl');
  end; -- end initial_value
  --
  procedure initial_tab_education(json_education json_object_t) is
    json_education_row    json_object_t;
  begin
    for i in 0..json_education.get_size-1 loop
      json_education_row                   := hcm_util.get_json_t(json_education,to_char(i));
      p_flg_del_edu(i+1)                   := hcm_util.get_string_t(json_education_row,'flgrow');
      education_tab(i+1).codempid          := hcm_util.get_string_t(json_education_row,'codempid');
      education_tab(i+1).numappl           := hcm_util.get_string_t(json_education_row,'numappl');
      education_tab(i+1).numseq            := hcm_util.get_string_t(json_education_row,'numseq');
      education_tab(i+1).codedlv           := hcm_util.get_string_t(json_education_row,'codedlv');
      education_tab(i+1).coddglv           := hcm_util.get_string_t(json_education_row,'coddglv');
      education_tab(i+1).codmajsb          := hcm_util.get_string_t(json_education_row,'codmajsb');
      education_tab(i+1).codminsb          := hcm_util.get_string_t(json_education_row,'codminsb');
      education_tab(i+1).codinst           := hcm_util.get_string_t(json_education_row,'codinst');
      education_tab(i+1).codcount          := hcm_util.get_string_t(json_education_row,'codcount');
      education_tab(i+1).numgpa            := hcm_util.get_string_t(json_education_row,'numgpa');
      education_tab(i+1).stayear           := hcm_util.get_string_t(json_education_row,'stayear');
      education_tab(i+1).dtegyear          := hcm_util.get_string_t(json_education_row,'dtegyear');
      education_tab(i+1).flgeduc           := hcm_util.get_string_t(json_education_row,'flgeduc');
    end loop;
  end; -- end initial_tab_education
  --
  procedure initial_tab_work_exp(json_work_exp json_object_t) is
    json_work_exp_row    json_object_t;
  begin
    for i in 0..json_work_exp.get_size-1 loop
      json_work_exp_row                   := hcm_util.get_json_t(json_work_exp,to_char(i));
      p_flg_del_work(i+1)                 := hcm_util.get_string_t(json_work_exp_row,'flgrow');
      work_exp_tab(i+1).numappl           := hcm_util.get_string_t(json_work_exp_row,'numappl');
      work_exp_tab(i+1).codempid          := hcm_util.get_string_t(json_work_exp_row,'codempid');
      work_exp_tab(i+1).numseq            := hcm_util.get_string_t(json_work_exp_row,'numseq');
      work_exp_tab(i+1).desnoffi          := hcm_util.get_string_t(json_work_exp_row,'desnoffi');
      work_exp_tab(i+1).deslstjob1        := hcm_util.get_string_t(json_work_exp_row,'deslstjob1');
      work_exp_tab(i+1).deslstpos         := hcm_util.get_string_t(json_work_exp_row,'deslstpos');
      work_exp_tab(i+1).desoffi1          := hcm_util.get_string_t(json_work_exp_row,'desoffi1');
      work_exp_tab(i+1).numteleo          := hcm_util.get_string_t(json_work_exp_row,'numteleo');
      work_exp_tab(i+1).namboss           := hcm_util.get_string_t(json_work_exp_row,'namboss');
      work_exp_tab(i+1).desres            := hcm_util.get_string_t(json_work_exp_row,'desres');
--      work_exp_tab(i+1).amtincom          := hcm_util.get_string_t(json_work_exp_row,'amtincom');
      p_amtincome(i+1)                    := to_number(hcm_util.get_string_t(json_work_exp_row,'amtincom'));
      work_exp_tab(i+1).dtestart          := to_date(hcm_util.get_string_t(json_work_exp_row,'dtestart'),'dd/mm/yyyy');
      work_exp_tab(i+1).dteend            := to_date(hcm_util.get_string_t(json_work_exp_row,'dteend'),'dd/mm/yyyy');
      work_exp_tab(i+1).remark            := hcm_util.get_string_t(json_work_exp_row,'remark');
      work_exp_tab(i+1).dteupd            := hcm_util.get_string_t(json_work_exp_row,'dteupd');
      work_exp_tab(i+1).coduser           := hcm_util.get_string_t(json_work_exp_row,'coduser');
      work_exp_tab(i+1).desjob            := hcm_util.get_string_t(json_work_exp_row,'desjob');
      work_exp_tab(i+1).desrisk           := hcm_util.get_string_t(json_work_exp_row,'desrisk');
      work_exp_tab(i+1).desprotc          := hcm_util.get_string_t(json_work_exp_row,'desprotc');
    end loop;
  end; -- end initial_tab_work_exp
  --
  procedure initial_tab_training(json_training json_object_t) is
    json_training_row    json_object_t;
  begin
    for i in 0..json_training.get_size-1 loop
      json_training_row                   := hcm_util.get_json_t(json_training,to_char(i));
      p_flg_del_trn(i+1)                  := hcm_util.get_string_t(json_training_row,'flgrow');
      training_tab(i+1).codempid          := hcm_util.get_string_t(json_training_row,'codempid');
      training_tab(i+1).numappl           := hcm_util.get_string_t(json_training_row,'numappl');
      training_tab(i+1).numseq            := hcm_util.get_string_t(json_training_row,'numseq');
      training_tab(i+1).destrain          := hcm_util.get_string_t(json_training_row,'destrain');
      training_tab(i+1).dtetren           := to_date(hcm_util.get_string_t(json_training_row,'dtetren'),'dd/mm/yyyy');
      training_tab(i+1).desplace          := hcm_util.get_string_t(json_training_row,'desplace');
      training_tab(i+1).desinstu          := hcm_util.get_string_t(json_training_row,'desinstu');
      training_tab(i+1).dtetrain          := to_date(hcm_util.get_string_t(json_training_row,'dtetrain'),'dd/mm/yyyy');
      training_tab(i+1).filedoc           := hcm_util.get_string_t(json_training_row,'filedoc');
    end loop;
  end; -- end initial_tab_training
  --
  function get_desciption (p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 is
    v_desc     varchar2(500):= p_code;
    v_stament  varchar2(500);
    v_funcdesc varchar2(500);
    v_data_type varchar2(500);
  begin
    if p_code is null then
      return v_desc ;
    end if;

    begin
      select  funcdesc,data_type
      into    v_funcdesc,v_data_type
      from    tcoldesc
      where   codtable  = p_table
      and     codcolmn  = p_field
      and     rownum    = 1 ;
    exception when no_data_found then
       v_funcdesc := null;
    end ;

    if v_funcdesc is not null   then
      v_stament   := 'select '||v_funcdesc||'from dual' ;
      v_stament   := replace(v_stament,'P_CODE',''''||p_code||'''') ;
      v_stament   := replace(v_stament,'P_LANG',global_v_lang) ;
      return execute_desc (v_stament) ;
    else
      if v_data_type = 'DATE' then
        if global_v_zyear = 543   then
          return to_char(add_months(to_date(v_desc,'dd/mm/yyyy'),543*12),'dd/mm/yyyy')	   ;
        else
          return to_char(to_date(v_desc,'dd/mm/yyyy'),'dd/mm/yyyy')	   ;
        end if;
      elsif p_field in ('STAYEAR','DTEGYEAR') then
        return v_desc + global_v_zyear;
      else
        return v_desc ;
      end if;
    end if;
  end; -- end get_desciption
  --
  procedure save_education is
    v_exist				boolean := false;
    v_numseq      number;
  begin
    v_numseq    := 0;
    for n in 1..education_tab.count loop
      v_numseq    := education_tab(n).numseq;
      if p_flg_del_edu(n) = 'delete' then
        delete from teducatn
        where   numappl     = b_index_numappl
        and     numseq      = v_numseq;
      else
        if education_tab(n).numseq > 0 then
          begin
            insert into teducatn
              (codempid,numappl,numseq,
               codedlv,coddglv,codmajsb,codminsb,codinst,
               codcount,numgpa,stayear,dtegyear,flgeduc,
               codcreate,coduser)
            values
              (b_index_numappl,b_index_numappl,v_numseq,
               education_tab(n).codedlv,education_tab(n).coddglv,education_tab(n).codmajsb,education_tab(n).codminsb,education_tab(n).codinst,
               education_tab(n).codcount,education_tab(n).numgpa,education_tab(n).stayear- global_v_zyear,education_tab(n).dtegyear- global_v_zyear,education_tab(n).flgeduc,
               global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            update teducatn
              set	codedlv  = education_tab(n).codedlv,
                  coddglv  = education_tab(n).coddglv,
                  codmajsb = education_tab(n).codmajsb,
                  codminsb = education_tab(n).codminsb,
                  codinst  = education_tab(n).codinst,
                  codcount = education_tab(n).codcount,
                  numgpa   = education_tab(n).numgpa,
                  stayear  = education_tab(n).stayear- global_v_zyear,
                  dtegyear = education_tab(n).dtegyear- global_v_zyear,
                  flgeduc  = education_tab(n).flgeduc,
                  coduser  = global_v_coduser
              where numappl   = b_index_numappl
                and numseq    = v_numseq;
          end;
        end if;
      end if;
    end loop;
  end; -- end save_education
  --
  procedure save_work_exp is
    v_exist				boolean := false;
    v_numseq      number;
    v_numappl     varchar2(100 char);
    v_amtincom    varchar2(20 char);
  begin
    v_numseq    := 0;

    for n in 1..work_exp_tab.count loop
      v_numseq      := work_exp_tab(n).numseq;
      if p_flg_del_work(n) = 'delete' then
        delete from tapplwex
        where   numappl     = b_index_numappl
        and     numseq      = v_numseq;
      else
        if work_exp_tab(n).numseq > 0 then
          v_amtincom    := stdenc(nvl(p_amtincome(n),0),b_index_numappl,global_v_chken);
          begin
            insert into tapplwex
              (codempid,numappl,numseq,
               desnoffi,deslstjob1,deslstpos,desoffi1,
               numteleo,namboss,desres,amtincom,
               dtestart,dteend,remark,
               codcreate,coduser,
               desjob,desrisk,desprotc)
            values
              (b_index_numappl,b_index_numappl,v_numseq,
               work_exp_tab(n).desnoffi,work_exp_tab(n).deslstjob1,work_exp_tab(n).deslstpos,work_exp_tab(n).desoffi1,
               work_exp_tab(n).numteleo,work_exp_tab(n).namboss,work_exp_tab(n).desres,v_amtincom,
               work_exp_tab(n).dtestart,work_exp_tab(n).dteend,work_exp_tab(n).remark,
               global_v_coduser,global_v_coduser,
               work_exp_tab(n).desjob,work_exp_tab(n).desrisk,work_exp_tab(n).desprotc);
          exception when dup_val_on_index then
            update tapplwex
               set desnoffi 	= work_exp_tab(n).desnoffi,
                   deslstjob1 = work_exp_tab(n).deslstjob1,
                   deslstpos 	= work_exp_tab(n).deslstpos,
                   desoffi1 	= work_exp_tab(n).desoffi1,
                   numteleo 	= work_exp_tab(n).numteleo,
                   namboss 		= work_exp_tab(n).namboss,
                   desres 		= work_exp_tab(n).desres,
                   amtincom 	= v_amtincom,
                   dtestart 	= work_exp_tab(n).dtestart,
                   dteend 		= work_exp_tab(n).dteend,
                   remark 		= work_exp_tab(n).remark,
                   coduser 		= global_v_coduser,
                   desjob     = work_exp_tab(n).desjob,
                   desrisk   	= work_exp_tab(n).desrisk,
                   desprotc		= work_exp_tab(n).desprotc
              where numappl   = b_index_numappl
                and numseq    = v_numseq;
          end;
        end if;
      end if;
    end loop;
  end; -- end save_work_exp
  --
  procedure save_training is
    v_exist				boolean := false;
    v_numseq      number;
    cursor c_ttrainbf is
      select  numappl,numseq,codempid,destrain,
              dtetrain,dtetren,desplace,desinstu,
              numrefdoc,filedoc,rowid
      from	  ttrainbf
      where	  numappl = b_index_numappl
      and		  numseq  = v_numseq;
    v_numrefdoc   tappldoc.numrefdoc%type;
  begin
    v_numseq    := 0;
    for n in 1..training_tab.count loop
      v_numseq  := training_tab(n).numseq;
      v_numrefdoc   := null;
      if p_flg_del_trn(n) = 'delete' then
        for i in c_ttrainbf loop
          v_numrefdoc   := i.numrefdoc;
          exit;
        end loop;
        hrrc21e.update_filedoc( b_index_numappl,
                                '',
                                GET_LABEL_NAME('HRRC21E2T3',global_v_lang,10),
                                '0001',
                                global_v_coduser,
                                v_numrefdoc);
        delete from tappldoc
        where   numappl   = b_index_numappl
        and     numrefdoc = ( select  numrefdoc
                              from    ttrainbf
                              where   numappl     = b_index_numappl
                              and     numseq      = v_numseq);

        delete from ttrainbf
        where   numappl     = b_index_numappl
        and     numseq      = v_numseq;

      else
        if training_tab(n).numseq > 0 then
          v_exist       := false;

          begin
            insert into ttrainbf
              (codempid,numappl,numseq,
               destrain,dtetrain,dtetren,desplace,desinstu,
               codcreate,coduser,numrefdoc,filedoc)
            values
              (b_index_numappl,b_index_numappl,v_numseq,
               training_tab(n).destrain,training_tab(n).dtetrain,training_tab(n).dtetren,training_tab(n).desplace,training_tab(n).desinstu,
               global_v_coduser,global_v_coduser,v_numrefdoc,training_tab(n).filedoc);
            ---- insert fildoc ----
            hrrc21e.update_filedoc( b_index_numappl,
                                    training_tab(n).filedoc,
                                    GET_LABEL_NAME('HRRC21E2T3',global_v_lang,10),
                                    '0001',
                                    global_v_coduser,
                                    v_numrefdoc);
            ------------------------
          exception when dup_val_on_index then
            for i in c_ttrainbf loop
              v_exist       := true;
              v_numrefdoc   := i.numrefdoc;

              if nvl(i.filedoc,'#$@') <> nvl(training_tab(n).filedoc,'#$@') then
                hrrc21e.update_filedoc( b_index_numappl,
                                        training_tab(n).filedoc,
                                        GET_LABEL_NAME('HRRC21E2T3',global_v_lang,10),
                                        '0001',
                                        global_v_coduser,
                                        v_numrefdoc);
              end if;
            end loop;
            --
            update ttrainbf
               set destrain = training_tab(n).destrain,
                   dtetrain = training_tab(n).dtetrain,
                   dtetren = training_tab(n).dtetren,
                   desplace = training_tab(n).desplace,
                   desinstu = training_tab(n).desinstu,
                   filedoc = training_tab(n).filedoc,
                   numrefdoc = v_numrefdoc,
                   coduser = global_v_coduser
             where numappl    = b_index_numappl
               and numseq     = v_numseq;
          end;
        end if;
      end if;
    end loop;
  end; -- end save_training
  --
  procedure check_submit_edu(json_str_input in clob) is
    v_str_json      json_object_t;
    v_code          varchar2(100);
    v_codedlv       teducatn.codedlv%type;
    v_coddglv       teducatn.coddglv%type;
    v_codmajsb      teducatn.codmajsb%type;
    v_codminsb      teducatn.codminsb%type;
    v_codinst       teducatn.codinst%type;
    v_codcount      teducatn.codcount%type;
  begin
    v_str_json      := json_object_t(json_str_input);
    v_codedlv       := hcm_util.get_string_t(v_str_json,'codedlv');
    v_coddglv       := hcm_util.get_string_t(v_str_json,'coddglv');
    v_codmajsb      := hcm_util.get_string_t(v_str_json,'codmajsb');
    v_codminsb      := hcm_util.get_string_t(v_str_json,'codminsb');
    v_codinst       := hcm_util.get_string_t(v_str_json,'codinst');
    v_codcount      := hcm_util.get_string_t(v_str_json,'codcount');

    begin
      select  codcodec
      into    v_code
      from    tcodeduc
      where   codcodec = v_codedlv;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEDUC');
      return;
    end;

    begin
      select  codcodec
      into    v_code
      from    tcoddgee
      where   codcodec = v_coddglv;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODDGEE');
      return;
    end;

    if v_codmajsb is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodmajr
        where   codcodec = v_codmajsb;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODMAJR');
        return;
      end;
    end if;

    if v_codminsb is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodsubj
        where   codcodec = v_codminsb;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSUBJ');
        return;
      end;
    end if;

    if v_codinst is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodinst
        where   codcodec = v_codinst;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODINST');
        return;
      end;
    end if;

    if v_codcount is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodcnty
        where   codcodec = v_codcount;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCNTY');
        return;
      end;
    end if;
  end;
  --
  procedure get_education_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_education_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_education_table
  --
  procedure gen_education_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    cursor c_teducatn is
      select  codempid,numappl,numseq,codedlv,coddglv,
              codmajsb,codminsb,codinst,codcount,numgpa,
              stayear,dtegyear,flgeduc,dteupd,coduser
      from    teducatn
      where   numappl = b_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    for i in c_teducatn loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numappl',i.numappl);
      obj_data.put('numseq',i.numseq);
      obj_data.put('codedlv',i.codedlv);
      obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.codedlv,global_v_lang));
      obj_data.put('coddglv',i.coddglv);
      obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',i.coddglv,global_v_lang));
      obj_data.put('codmajsb',i.codmajsb);
      obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
      obj_data.put('codminsb',i.codminsb);
      obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',i.codminsb,global_v_lang));
      obj_data.put('codinst',i.codinst);
      obj_data.put('desc_codinst',get_tcodec_name('TCODINST',i.codinst,global_v_lang));
      obj_data.put('codcount',i.codcount);
      obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',i.codcount,global_v_lang));
      obj_data.put('numgpa',i.numgpa);
      obj_data.put('stayear',i.stayear);
      obj_data.put('dtegyear',i.dtegyear);
      obj_data.put('flgeduc',i.flgeduc);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_education_table
  --
  procedure get_work_exp_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_work_exp_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_work_exp_table
  --
  procedure gen_work_exp_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    cursor c_tapplwex is
      select  numappl,codempid,numseq,desnoffi,deslstjob1,deslstpos,
              desoffi1,numteleo,namboss,desres,amtincom,
              dtestart,dteend,remark,dteupd,coduser,
              desjob,desrisk,desprotc
      from    tapplwex
      where   numappl = b_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    for i in c_tapplwex loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('numappl',i.numappl);
      obj_data.put('codempid',i.codempid);
      obj_data.put('numseq',i.numseq);
      obj_data.put('desnoffi',i.desnoffi);
      obj_data.put('deslstjob1',i.deslstjob1);
      obj_data.put('deslstpos',i.deslstpos);
      obj_data.put('desoffi1',i.desoffi1);
      obj_data.put('numteleo',i.numteleo);
      obj_data.put('namboss',i.namboss);
      obj_data.put('desres',i.desres);
      obj_data.put('amtincom',stddec(i.amtincom,b_index_numappl,global_v_chken));
      obj_data.put('dtestart',to_char(i.dtestart,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('remark',i.remark);
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_data.put('desjob',i.desjob);
      obj_data.put('desrisk',i.desrisk);
      obj_data.put('desprotc',i.desprotc);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_work_exp_table
  --
  procedure get_training_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_training_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_training_table
  --
  procedure gen_training_table(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    cursor c_ttrainbf is
      select  codempid,numappl,numseq,destrain,dtetren,
              desplace,desinstu,dtetrain,dteupd,coduser,
              filedoc
      from    ttrainbf
      where   numappl   = b_index_numappl
      order by numseq;
  begin
    obj_row    := json_object_t();

    for i in c_ttrainbf loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numappl',i.numappl);
      obj_data.put('numseq',i.numseq);
      obj_data.put('destrain',i.destrain);
      obj_data.put('dtetren',to_char(i.dtetren,'dd/mm/yyyy'));
      obj_data.put('desplace',i.desplace);
      obj_data.put('desinstu',i.desinstu);
      obj_data.put('dtetrain',to_char(i.dtetrain,'dd/mm/yyyy'));
      obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
      obj_data.put('coduser',i.coduser);
      obj_data.put('filedoc',i.filedoc);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_training_table
  --
  procedure get_sta_submit_edu(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_submit_edu(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_edu_work(json_str_input in clob, json_str_output out clob) is
    param_json                      json_object_t;
    param_json_education            json_object_t;
    param_json_work_exp             json_object_t;
    param_json_training             json_object_t;
  begin
    initial_value(json_str_input);
    param_json                  := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_json_education        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'education'),'rows');
    param_json_work_exp         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'work_exp'),'rows');
    param_json_training         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'training'),'rows');

    initial_tab_education(param_json_education);
    initial_tab_work_exp(param_json_work_exp);
    initial_tab_training(param_json_training);

    if param_msg_error is null then
      save_education;
      save_work_exp;
      save_training;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_edu_work
  --
end;

/

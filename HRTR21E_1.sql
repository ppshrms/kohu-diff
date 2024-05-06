--------------------------------------------------------
--  DDL for Package Body HRTR21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR21E" AS

    procedure initial_value(json_str in clob) is
        json_obj        json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codinst           := hcm_util.get_string(json_obj, 'codinst');
        p_codempid          := get_codempid_bycodinst(p_codinst);
        p_stainst           := get_tinstruc_stainst(p_codinst);

        json_params         := hcm_util.get_json(json_obj, 'json_input_str');

    end initial_value;

    procedure initial_employee(json_str in clob) is
        json_obj        json := json(json_str);
    begin
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        p_codempid           := hcm_util.get_string(json_obj, 'codempid');
    end initial_employee;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure gen_index(json_str_output out clob) as
        obj_data    json;
        obj_row     json;
        v_row       number := 0;
        cursor c1 is
            select codempid, stainst, namimage, codinst, get_tinstruc_name(codinst, global_v_lang) nameinstruc
            from tinstruc
            order by codinst;
    begin
        obj_row    := json();
        for i in c1 loop
            v_row := v_row + 1;
            obj_data := json();
            obj_data.put('coderror','200');
            if i.stainst = 'E' then
                obj_data.put('image_codapp','HRTR21E');
                obj_data.put('namimage',i.namimage);
            else
                obj_data.put('image_codapp','EMP');
                obj_data.put('namimage',get_emp_img(i.codempid));
            end if;
            obj_data.put('codinst',i.codinst);
            obj_data.put('nameinstruc',i.nameinstruc);
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_index;

    procedure get_tab1_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_tab1_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab1_detail;

    procedure gen_tab1_detail(json_str_output out clob) as
        obj_row           json;
        v_stainst         varchar2(1 char);
        v_codtitle        varchar2(4 char);
        v_namfirste       varchar2(30 char);
        v_namfirstt       varchar2(30 char);
        v_namfirst3       varchar2(30 char);
        v_namfirst4       varchar2(30 char);
        v_namfirst5       varchar2(30 char);
        v_namlaste        varchar2(30 char);
        v_namlastt        varchar2(30 char);
        v_namlast3        varchar2(30 char);
        v_namlast4        varchar2(30 char);
        v_namlast5        varchar2(30 char);
        v_codempid        varchar2(10 char);
        v_codcomp         varchar2(40 char);
        v_codpos          varchar2(4 char);
        v_adrcont         varchar2(200 char);
        v_codprovr        varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_codsubdistr     varchar2(4 char);
        v_desnoffi        varchar2(200 char);
        v_namepos         varchar2(100 char);
        v_numtelc         varchar(25 char);
        v_email           varchar2(50 char);
        v_namimage        varchar2(30 char);
        v_lineid          varchar2(50 char);
        v_codunit         varchar2(1 char);
        v_amtinchg        number(9,2);
        v_desskill        varchar2(1000 char);
        v_desnote         varchar2(1000 char);
        v_filename        varchar2(60 char);

        v_dteupd          date;
        v_coduser         varchar2(50 char);

    begin

        begin
            select stainst, codtitle, namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
                   namlaste, namlastt, namlast3, namlast4, namlast5, codinst,
                   codempid, adrcont, codprovr, coddistr, codsubdistr, desnoffi, namepos,
                   numtelc, email, namimage, lineid, codunit, amtinchg, desskill, desnote, filename,
                   dteupd, coduser
            into v_stainst, v_codtitle, v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5,
                v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5, p_codinst,
                v_codempid, v_adrcont, v_codprovr, v_coddistr, v_codsubdistr, v_desnoffi, v_namepos,
                v_numtelc, v_email, v_namimage, v_lineid, v_codunit, v_amtinchg, v_desskill, v_desnote, v_filename,
                v_dteupd, v_coduser
            from tinstruc
            where codinst = p_codinst;
        exception when no_data_found then
            v_codtitle        := null;
            v_namfirste       := null;
            v_namfirstt       := null;
            v_namfirst3       := null;
            v_namfirst4       := null;
            v_namfirst5       := null;
            v_namlaste        := null;
            v_namlastt        := null;
            v_namlast3        := null;
            v_namlast4        := null;
            v_namlast5        := null;
            v_codempid        := null;
            v_adrcont         := null;
            v_codprovr        := null;
            v_coddistr        := null;
            v_codsubdistr     := null;
            v_desnoffi        := null;
            v_namepos         := null;
            v_numtelc         := null;
            v_email           := null;
            v_namimage        := null;
            v_lineid          := null;
            v_codunit         := '1';
            v_amtinchg        := null;
            v_desskill        := null;
            v_desnote         := null;
            v_filename        := null;
            v_dteupd          := null;
            v_coduser         := null;
        end;

        obj_row := json();
        obj_row.put('codinst', p_codinst);
        obj_row.put('stainst', v_stainst);

        if v_stainst = 'I' then
            begin
                select  codcomp, codpos, codprovc, coddistc, codsubdistc, get_tpostn_name(codpos, global_v_lang),
                        numtelec, email, lineid,
                        decode(global_v_lang,
                            '101',adrconte,
                            '102',adrcontt,
                            '103',adrcont3,
                            '104',adrcont4,
                            '105',adrcont5 , adrconte) adrcont
                into    v_codcomp, v_codpos, v_codprovr, v_coddistr, v_codsubdistr, v_namepos,
                        v_numtelc, v_email, v_lineid, v_adrcont
                from    temploy1 a left join temploy2 b
                on      a.codempid = b.codempid
                where   a.codempid = v_codempid;
            exception when no_data_found then
                v_codcomp       := null;
                v_codpos        := null;
                v_codprovr      := null;
                v_coddistr      := null;
                v_codsubdistr   := null;
                v_namepos       := null;
                v_numtelc       := null;
                v_email         := null;
                v_lineid        := null;
                v_adrcont       := null;
            end;

            begin
                select  namimage
                into    v_namimage
                from    tempimge
                where   codempid = v_codempid;
            exception when no_data_found then
                v_namimage      := null;
            end;

            begin
                select  decode(global_v_lang,
                            '101',adrcome,
                            '102',adrcomt,
                            '103',adrcom3,
                            '104',adrcom4,
                            '105',adrcom5, adrcome) adrcom
                into    v_desnoffi
                from    tcompny
                where   codcompy = get_codcompy(v_codcomp);
            exception when no_data_found then
                v_desnoffi      := null;
            end;

            obj_row.put('codempid', v_codempid);
            obj_row.put('codcomp', v_codcomp);
            obj_row.put('codpos', v_codpos);
        elsif v_stainst = 'E' then
            obj_row.put('codtitle', v_codtitle);
            if global_v_lang = '101' then
                obj_row.put('namfirst', v_namfirste);
                obj_row.put('namlast', v_namlaste);
            elsif global_v_lang = '102' then
                obj_row.put('namfirst', v_namfirstt);
                obj_row.put('namlast', v_namlastt);
            elsif global_v_lang = '103' then
                obj_row.put('namfirst', v_namfirst3);
                obj_row.put('namlast', v_namlast3);
            elsif global_v_lang = '104' then
                obj_row.put('namfirst', v_namfirst4);
                obj_row.put('namlast', v_namlast4);
            elsif global_v_lang = '105' then
                obj_row.put('namfirst', v_namfirst5);
                obj_row.put('namlast', v_namlast5);
            end if;

            obj_row.put('namfirste', v_namfirste);
            obj_row.put('namfirstt', v_namfirstt);
            obj_row.put('namfirst3', v_namfirst3);
            obj_row.put('namfirst4', v_namfirst4);
            obj_row.put('namfirst5', v_namfirst5);
            obj_row.put('namlaste', v_namlaste);
            obj_row.put('namlastt', v_namlastt);
            obj_row.put('namlast3', v_namlast3);
            obj_row.put('namlast4', v_namlast4);
            obj_row.put('namlast5', v_namlast5);
        end if;

        obj_row.put('adrcont', v_adrcont);
        obj_row.put('codprovr', v_codprovr);
        obj_row.put('coddistr', v_coddistr);
        obj_row.put('codsubdistr', v_codsubdistr);
        obj_row.put('desnoffi', v_desnoffi);
        obj_row.put('namepos', v_namepos);
        obj_row.put('numtelc', v_numtelc);
        obj_row.put('email', v_email);
        obj_row.put('namimage', v_namimage);
        obj_row.put('lineid', v_lineid);
        obj_row.put('codunit', v_codunit);
        obj_row.put('amtinchg', v_amtinchg);
        obj_row.put('desskill', v_desskill);
        obj_row.put('desnote', v_desnote);
        obj_row.put('filename', v_filename);

        obj_row.put('dteupd', v_dteupd);
        obj_row.put('coduser', v_coduser);
        obj_row.put('coderror', '200');

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab1_detail;

    procedure get_tab2_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_tab2_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab2_detail;

    procedure gen_tab2_detail(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select codcours, codsubj, instgrd, dtetrlst
            from tcrsinst
            where codinst = p_codinst;
    begin
        obj_row := json();
        for i in c1 loop
            v_row       := v_row + 1;
            obj_data    := json();
            obj_data.put('codcours', i.codcours);
            obj_data.put('codsubj', i.codsubj);
            obj_data.put('instgrd', to_char(i.instgrd,'fm999,999,990.00'));
            obj_data.put('dtetrlst', to_char(i.dtetrlst,'dd/mm/yyyy'));
            obj_data.put('coderror', '200');
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab2_detail;

    procedure get_tab3_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_tab3_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab3_detail;

    procedure gen_tab3_detail(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select codedlv, codmajsb, codinst, codcount
            from teducatn
            where codempid = get_codempid_bycodinst(p_codinst)
            order by codedlv;
        cursor c2 is
            select codedlv, desmajsb, desinstit, codcnty, desnote, numseq
            from tinstedu
            where codinst = p_codinst
            order by codedlv;
    begin
        obj_row := json();

        if p_stainst = 'I' then
            for i in c1 loop
                v_row       := v_row + 1;
                obj_data    := json();
                obj_data.put('desedlv', i.codedlv);
                obj_data.put('desmajsb', get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
                obj_data.put('desinstit', get_tcodec_name('TCODINST',i.codinst,global_v_lang));
                obj_data.put('codcnty', i.codcount);
                obj_data.put('coderror', '200');
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
        elsif p_stainst = 'E' then
            for i in c2 loop
                v_row       := v_row + 1;
                obj_data    := json();
                obj_data.put('desedlv', i.codedlv);
                obj_data.put('desmajsb', i.desmajsb);
                obj_data.put('desinstit', i.desinstit);
                obj_data.put('codcnty', i.codcnty);
                obj_data.put('desnote', i.desnote);
                obj_data.put('numseq', i.numseq);
                obj_data.put('coderror', '200');
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab3_detail;

    procedure get_tab4_detail(json_str_input in clob, json_str_output out clob) as
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        gen_tab4_detail(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab4_detail;

    procedure gen_tab4_detail(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select desc_codcomp, desc_codpos, desc_codjob, dteempmt, dteeffex
            from (select  get_tcenter_name(codcomp, global_v_lang) desc_codcomp,
                          get_tpostn_name(codpos, global_v_lang) desc_codpos,
                          get_tjobcode_name(codjob, global_v_lang) desc_codjob,
                          dteefpos dteempmt, null dteeffex
                  from    temploy1
                  where   codempid = p_codempid
                  union
                  select  desnoffi desc_codcomp, deslstpos desc_codpos, deslstjob1 desc_codjob, dtestart dteempmt, dteend dteeffex
                  from    tapplwex
                  where   codempid = p_codempid)
            order by dteempmt;

        cursor c2 is 
            select t1.desnoffi desc_codcomp, t1.namepos desc_codpos, t1.desjob desc_codjob, t1.dtestart dteempmt, t1.dteend dteeffex, t1.numseq
            from tinstwex t1 left join tinstwex t2
            on (t1.desnoffi = t2.desnoffi and t1.namepos = t2.namepos and t1.desjob = t2.desjob and t1.dtestart < t2.dtestart)
            where t1.codinst = p_codinst and t2.dtestart is null
            order by dteempmt;
    begin
        obj_row := json();

        if p_stainst = 'I' then
            for i in c1 loop
                v_row       := v_row + 1;
                obj_data    := json();
                obj_data.put('desc_codcomp', i.desc_codcomp);
                obj_data.put('desc_codpos', i.desc_codpos);
                obj_data.put('desc_codjob', i.desc_codjob);
                obj_data.put('dteempmt', to_char(i.dteempmt, 'dd/mm/yyyy'));
                obj_data.put('dteeffex', to_char(i.dteeffex, 'dd/mm/yyyy'));
                obj_data.put('coderror', '200');
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
        elsif p_stainst = 'E' then
            for i in c2 loop
                v_row       := v_row + 1;
                obj_data    := json();
                obj_data.put('desc_codcomp', i.desc_codcomp);
                obj_data.put('desc_codpos', i.desc_codpos);
                obj_data.put('desc_codjob', i.desc_codjob);
                obj_data.put('dteempmt', to_char(i.dteempmt, 'dd/mm/yyyy'));
                obj_data.put('dteeffex', to_char(i.dteeffex, 'dd/mm/yyyy'));
                obj_data.put('numseq', i.numseq);
                obj_data.put('coderror', '200');
                obj_row.put(to_char(v_row-1),obj_data);
            end loop;
        end if;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab4_detail;

    procedure get_tab1_employee(json_str_input in clob, json_str_output out clob) as
    begin
      initial_employee(json_str_input);
      if param_msg_error is null then
        gen_tab1_employee(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab1_employee;

    procedure gen_tab1_employee(json_str_output out clob) as
        obj_row           json;
        v_codcomp         varchar2(40 char);
        v_codpos          varchar2(4 char);
        v_adrcont         varchar2(200 char);
        v_codprovr        varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_codsubdistr     varchar2(4 char);
        v_desnoffi        varchar2(200 char);
        v_namepos         varchar2(100 char);
        v_numtelc         varchar(25 char);
        v_email           varchar2(50 char);
        v_namimage        varchar2(30 char);
        v_lineid          varchar2(50 char);
    begin

        obj_row := json();

        begin
            select  codcomp, codpos, codprovc, coddistc, codsubdistc, get_tpostn_name(codpos, global_v_lang),
                    numtelec, email, lineid,
                    decode(global_v_lang,
                        '101',adrconte,
                        '102',adrcontt,
                        '103',adrcont3,
                        '104',adrcont4,
                        '105',adrcont5 , adrconte) adrcont
            into    v_codcomp, v_codpos, v_codprovr, v_coddistr, v_codsubdistr, v_namepos,
                    v_numtelc, v_email, v_lineid, v_adrcont
            from    temploy1 a left join temploy2 b
            on      a.codempid = b.codempid
            where   a.codempid = p_codempid;
        exception when no_data_found then
            v_codcomp       := null;
            v_codpos        := null;
            v_codprovr      := null;
            v_coddistr      := null;
            v_codsubdistr   := null;
            v_namepos       := null;
            v_numtelc       := null;
            v_email         := null;
            v_lineid        := null;
            v_adrcont       := null;
        end;

        begin
            select  namimage
            into    v_namimage
            from    tempimge
            where   codempid = p_codempid;
        exception when no_data_found then
            v_namimage      := null;
        end;

        begin
            select  decode(global_v_lang,
                        '101',adrcome,
                        '102',adrcomt,
                        '103',adrcom3,
                        '104',adrcom4,
                        '105',adrcom5, adrcome) adrcom
            into    v_desnoffi
            from    tcompny
            where   codcompy = get_codcompy(v_codcomp);
        exception when no_data_found then
            v_desnoffi      := null;
        end;

        obj_row.put('codempid', p_codempid);
        obj_row.put('codcomp', v_codcomp);
        obj_row.put('codpos', v_codpos);

        obj_row.put('adrcont', v_adrcont);
        obj_row.put('codprovr', v_codprovr);
        obj_row.put('coddistr', v_coddistr);
        obj_row.put('codsubdistr', v_codsubdistr);
        obj_row.put('desnoffi', v_desnoffi);
        obj_row.put('namepos', v_namepos);
        obj_row.put('numtelc', v_numtelc);
        obj_row.put('email', v_email);
        obj_row.put('namimage', v_namimage);
        obj_row.put('lineid', v_lineid);
        obj_row.put('coderror', '200');

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab1_employee;

    procedure get_tab3_employee(json_str_input in clob, json_str_output out clob) as
    begin
      initial_employee(json_str_input);
      if param_msg_error is null then
        gen_tab3_employee(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab3_employee;

    procedure gen_tab3_employee(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select codedlv, codmajsb, codinst, codcount
            from teducatn
            where codempid = p_codempid
            order by codedlv;
    begin
        obj_row := json();

        for i in c1 loop
            v_row       := v_row + 1;
            obj_data    := json();
            obj_data.put('desedlv', i.codedlv);
            obj_data.put('desmajsb', get_tcodec_name('TCODMAJR',i.codmajsb,global_v_lang));
            obj_data.put('desinstit', get_tcodec_name('TCODINST',i.codinst,global_v_lang));
            obj_data.put('codcnty', i.codcount);
            obj_data.put('coderror', '200');
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab3_employee;

    procedure get_tab4_employee(json_str_input in clob, json_str_output out clob) as
    begin
      initial_employee(json_str_input);
      if param_msg_error is null then
        gen_tab4_employee(json_str_output);
      end if;
      if param_msg_error is not null then
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tab4_employee;

    procedure gen_tab4_employee(json_str_output out clob) as
        obj_row           json;
        obj_data          json;
        v_row             number := 0;
        cursor c1 is
            select desc_codcomp, desc_codpos, desc_codjob, dteempmt, dteeffex
            from (select  get_tcenter_name(codcomp, global_v_lang) desc_codcomp,
                          get_tpostn_name(codpos, global_v_lang) desc_codpos,
                          get_tjobcode_name(codjob, global_v_lang) desc_codjob,
                          dteefpos dteempmt, null dteeffex
                  from    temploy1
                  where   codempid = p_codempid
                  union
                  select  desnoffi desc_codcomp, deslstpos desc_codpos, deslstjob1 desc_codjob, dtestart dteempmt, dteend dteeffex
                  from    tapplwex
                  where   codempid = p_codempid)
            order by dteempmt;
    begin
        obj_row := json();

        for i in c1 loop
            v_row       := v_row + 1;
            obj_data    := json();
            obj_data.put('desc_codcomp', i.desc_codcomp);
            obj_data.put('desc_codpos', i.desc_codpos);
            obj_data.put('desc_codjob', i.desc_codjob);
            obj_data.put('dteempmt', to_char(i.dteempmt, 'dd/mm/yyyy'));
            obj_data.put('dteeffex', to_char(i.dteeffex, 'dd/mm/yyyy'));
            obj_data.put('coderror', '200');
            obj_row.put(to_char(v_row-1),obj_data);
        end loop;

        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end gen_tab4_employee;

    procedure delete_index(json_str_input in clob, json_str_output out clob) as
          param_json_row    json;
          v_codinst         varchar2(10 char);
          v_count_tinstaph  int;
          v_count_tcoursub  int;
          v_count_tyrtrsch  int;
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            for i in 0..json_params.count-1 loop
            v_count_tinstaph    := 0;
            v_count_tcoursub    := 0;
            v_count_tyrtrsch    := 0;
            param_json_row      := hcm_util.get_json(json_params, to_char(i));
             v_codinst          := hcm_util.get_string(param_json_row,'codinstruc');
            if v_codinst is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;
            if param_msg_error is null then
                    begin
                        select count(*) into v_count_tinstaph
                        from tinstaph
                        where codinst = v_codinst;
                        exception when others then
                            null;
                        end;
                    begin
                    select count(*) into v_count_tyrtrsch
                    from tyrtrsch
                    where codinst = v_codinst and rownum = 1;
                    exception when others then
                        null;
                    end;
                    begin
                    select count(*) into v_count_tcoursub
                    from tcoursub
                    where codinst = v_codinst and rownum = 1;
                    exception when others then
                        null;
                    end;
                    if v_count_tinstaph > 0 or v_count_tyrtrsch > 0 or v_count_tcoursub > 0 then
                        param_msg_error := get_error_msg_php('HR1450',global_v_lang);
                    else
                        begin
                            delete from tinstruc
                            where codinst = v_codinst;
                        exception when others then
                            null;
                        end;
                        begin
                            delete from tcrsinst
                            where codinst = v_codinst;
                        exception when others then
                            null;
                        end;
                        begin
                            delete from tinstedu
                            where codinst = v_codinst;
                        exception when others then
                            null;
                        end;
                        begin
                            delete from tinstwex
                            where codinst = v_codinst;
                        exception when others then
                            null;
                        end;
                    end if;
            end if;
        end loop;
        end if;

        if param_msg_error is null then
            param_msg_error := get_error_msg_php('HR2425', global_v_lang);
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        else
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end delete_index;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
      v_tab1            json := hcm_util.get_json(json_params, 'detail_lecturer');
    begin
      initial_value(json_str_input);
      if param_msg_error is null then
        save_tab1(json_str_output);
      end if;

      if param_msg_error is null then
        save_tab2(json_str_output);
      end if;

      if param_msg_error is null then
        save_tab3(json_str_output);
      end if;

      if param_msg_error is null then
        save_tab4(json_str_output);
      end if;

      if param_msg_error is null then
         param_msg_error := get_error_msg_php('HR2401', global_v_lang);
         json_str_output := get_response_message(null, param_msg_error, global_v_lang);
         commit;
      else
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        rollback;
      end if;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure save_tab1(json_str_output out clob) as
        v_tab1            json := hcm_util.get_json(json_params, 'detail_lecturer');
        v_codtitle        varchar2(4 char);
        v_namfirste       varchar2(30 char);
        v_namfirstt       varchar2(30 char);
        v_namfirst3       varchar2(30 char);
        v_namfirst4       varchar2(30 char);
        v_namfirst5       varchar2(30 char);
        v_namlaste        varchar2(30 char);
        v_namlastt        varchar2(30 char);
        v_namlast3        varchar2(30 char);
        v_namlast4        varchar2(30 char);
        v_namlast5        varchar2(30 char);
        v_codempid        varchar2(10 char);
        v_codcomp         varchar2(40 char);
        v_codpos          varchar2(4 char);
        v_adrcont         varchar2(200 char);
        v_codprovr        varchar2(4 char);
        v_coddistr        varchar2(4 char);
        v_codsubdistr     varchar2(4 char);
        v_desnoffi        varchar2(300 char);
        v_namepos         varchar2(100 char);
        v_numtelc         varchar(25 char);
        v_email           varchar2(50 char);
        v_namimage        varchar2(30 char);
        v_lineid          varchar2(50 char);
        v_codunit         varchar2(1 char);
        v_amtinchg        number(9,2);
        v_desskill        varchar2(1000 char);
        v_desnote         varchar2(1000 char);
        v_filename        varchar2(60 char);
        v_staemp          varchar2(1 char);
        v_count_codempid           number := 0;
        v_change_stainst  boolean := false;
        v_stainst_old     varchar2(1  char);
    begin

        p_stainst           := hcm_util.get_string(v_tab1,'stainst');
        p_codinst           := hcm_util.get_string(v_tab1,'codinstruc');
        v_codempid          := hcm_util.get_string(v_tab1,'codempid');
        v_codcomp           := hcm_util.get_string(v_tab1,'codcomp');
        v_codpos            := hcm_util.get_string(v_tab1,'codpos');
        v_codtitle          := hcm_util.get_string(v_tab1,'codtitle');
        v_namfirste         := hcm_util.get_string(v_tab1,'namfirste');
        v_namfirstt         := hcm_util.get_string(v_tab1,'namfirstt');
        v_namfirst3         := hcm_util.get_string(v_tab1,'namfirst3');
        v_namfirst4         := hcm_util.get_string(v_tab1,'namfirst4');
        v_namfirst5         := hcm_util.get_string(v_tab1,'namfirst5');
        v_namlaste          := hcm_util.get_string(v_tab1,'namlaste');
        v_namlastt          := hcm_util.get_string(v_tab1,'namlastt');
        v_namlast3          := hcm_util.get_string(v_tab1,'namlast3');
        v_namlast4          := hcm_util.get_string(v_tab1,'namlast4');
        v_namlast5          := hcm_util.get_string(v_tab1,'namlast5');
        v_adrcont           := hcm_util.get_string(v_tab1,'adrcont');
        v_codprovr          := hcm_util.get_string(v_tab1,'codprovr');
        v_coddistr          := hcm_util.get_string(v_tab1,'coddistr');
        v_codsubdistr       := hcm_util.get_string(v_tab1,'codsubdistr');
        v_desnoffi          := hcm_util.get_string(v_tab1,'desnoffi');
        v_namepos           := hcm_util.get_string(v_tab1,'namepos');
        v_numtelc           := hcm_util.get_string(v_tab1,'numtelc');
        v_email             := hcm_util.get_string(v_tab1,'email');
        v_namimage          := hcm_util.get_string(v_tab1,'namimage');
        v_lineid            := hcm_util.get_string(v_tab1,'lineid');
        v_codunit           := hcm_util.get_string(v_tab1,'codunit');
        v_amtinchg          := hcm_util.get_string(v_tab1,'amtinchg');
        v_desskill          := hcm_util.get_string(v_tab1,'desskill');
        v_desnote           := hcm_util.get_string(v_tab1,'desnote');
        v_filename          := hcm_util.get_string(v_tab1,'filename');

        if p_stainst = 'I' then
            if v_codempid is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            begin
                select  staemp, codtitle, namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
                        namlaste, namlastt, namlast3, namlast4, namlast5
                into    v_staemp, v_codtitle, v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5,
                        v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5
                from temploy1
                where codempid = v_codempid;
            end;

            begin
                select  count(codempid)
                into    v_count_codempid
                from temploy1
                where codempid = v_codempid;
            end;

            if v_count_codempid = 0 or v_staemp = '9' then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'TEMPLOY1');
            end if;

            begin
                select  stainst
                into    v_stainst_old
                from    tinstruc
                where codinst = p_codinst;
            exception when no_data_found then
                v_stainst_old := 'I';
            end;

            if v_stainst_old = 'E' then
                v_change_stainst := true;
            end if;

        elsif p_stainst = 'E' then
            if v_codtitle is null then
                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            end if;

            if global_v_lang = '101' then
                if v_namfirste is null or v_namlaste is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            elsif global_v_lang = '102' then
                if v_namfirstt is null or v_namlastt is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            elsif global_v_lang = '103' then
                if v_namfirst3 is null or v_namlast3 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            elsif global_v_lang = '104' then
                if v_namfirst4 is null or v_namlast4 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            elsif global_v_lang = '105' then
                if v_namfirst5 is null or v_namlast5 is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;
            end if;
        end if;

        if param_msg_error is null then
            begin
                insert into tinstruc(codinst, stainst, codempid, codtitle, namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                            namlaste, namlastt, namlast3, namlast4, namlast5, naminse, naminst, namins3, namins4, namins5,
                            adrcont, codprovr, coddistr, codsubdistr, desnoffi, namepos, numtelc, email, namimage, lineid, codunit,
                            amtinchg, desskill, desnote, filename, dteupd, coduser, codcreate)
                values  (p_codinst, p_stainst, v_codempid,v_codtitle, v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,
                        v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5, v_namfirste ||' '|| v_namlaste, v_namfirstt ||' '|| v_namlastt, v_namfirst3 ||' '|| v_namlast3, v_namfirst4 ||' '|| v_namlast4, v_namfirst5 ||' '|| v_namlast5,
                        v_adrcont, v_codprovr, v_coddistr, v_codsubdistr, v_desnoffi, v_namepos, v_numtelc, v_email, v_namimage, v_lineid, v_codunit,
                        v_amtinchg, v_desskill, v_desnote, v_filename, trunc(sysdate), global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
                begin
                    update  tinstruc
                    set     stainst     = p_stainst,
                            codempid    = v_codempid,
                            codtitle    = v_codtitle,
                            namfirste    = v_namfirste,
                            namfirstt    = v_namfirstt,
                            namfirst3    = v_namfirst3,
                            namfirst4    = v_namfirst4,
                            namfirst5    = v_namfirst5,
                            namlaste    = v_namlaste,
                            namlastt    = v_namlastt,
                            namlast3    = v_namlast3,
                            namlast4    = v_namlast4,
                            namlast5    = v_namlast5,
                            naminse     = v_namfirste ||' '|| v_namlaste,
                            naminst     = v_namfirstt ||' '|| v_namlastt,
                            namins3     = v_namfirst3 ||' '|| v_namlast3,
                            namins4     = v_namfirst4 ||' '|| v_namlast4,
                            namins5     = v_namfirst5 ||' '|| v_namlast5,
                            adrcont     = v_adrcont,
                            codprovr    = v_codprovr,
                            coddistr    = v_coddistr,
                            codsubdistr = v_codsubdistr,
                            desnoffi    = v_desnoffi,
                            namepos     = v_namepos,
                            numtelc     = v_numtelc,
                            email       = v_email,
                            namimage    = v_namimage,
                            lineid      = v_lineid,
                            codunit     = v_codunit,
                            amtinchg    = v_amtinchg,
                            desskill    = v_desskill,
                            desnote     = v_desnote,
                            filename    = v_filename,

                            dteupd      = trunc(sysdate),
                            coduser     = global_v_coduser
                    where   codinst     = p_codinst;
                exception when others then
                    rollback;
                end;

                if v_change_stainst then
                    begin
                        delete from tinstedu
                        where codinst = p_codinst;
                    end;
                    begin
                        delete from tinstwex
                        where codinst = p_codinst;
                    end;
                end if;
            end;
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab1;

    procedure save_tab2(json_str_output out clob) as
        v_tab2            json := hcm_util.get_json(json_params, 'table_teachingHistory');
        v_tab2_table      json := hcm_util.get_json(v_tab2, 'rows');
        param_json_row    json;
        v_codcours        varchar2(6 char);
        v_codsubj         varchar2(6 char);
        v_instgrd         number(5,2);
        v_dtetrlst        date;
        v_flg             varchar2(6 char);
        v_count_codcours  int;
        v_count_codsubj   int;
    begin
        for i in 0..v_tab2_table.count-1 loop
            param_json_row      := hcm_util.get_json(v_tab2_table, to_char(i));
            v_codcours          := hcm_util.get_string(param_json_row,'codcours');
            v_codsubj           := hcm_util.get_string(param_json_row,'codsubj');
            v_instgrd           := hcm_util.get_string(param_json_row,'instgrd');
            v_dtetrlst          := hcm_util.get_string(param_json_row,'dtetrlst');
            v_flg               := hcm_util.get_string(param_json_row,'flg');
            v_count_codcours    := 0;
            v_count_codsubj     := 0;

            if v_flg = 'add' or v_flg = 'edit' then
                if v_codcours is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;

                if v_codsubj is null then
                    param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                end if;

                begin
                    select  count(codcours)
                    into    v_count_codcours
                    from    tcoursub
                    where   codcours = v_codcours;
                end;

                begin
                    select  count(codsubj)
                    into    v_count_codsubj
                    from    tcoursub
                    where   codsubj = v_codsubj;
                end;

                if v_count_codcours = 0 or v_count_codsubj = 0 then
                    param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TCOURSUB');
                end if;
            end if;
        end loop;

        if param_msg_error is null then
            for i in 0..v_tab2_table.count-1 loop
                param_json_row  := hcm_util.get_json(v_tab2_table, to_char(i));
                v_codcours      := hcm_util.get_string(param_json_row,'codcours');
                v_codsubj       := hcm_util.get_string(param_json_row,'codsubj');
                v_instgrd       := hcm_util.get_string(param_json_row,'instgrd');
                v_dtetrlst      := hcm_util.get_string(param_json_row,'dtetrlst');
                v_flg           := hcm_util.get_string(param_json_row,'flg');

                if param_msg_error is null then
                    if v_flg = 'add' then
                        begin
                            insert into tcrsinst(codinst, codcours, codsubj, instgrd, dtetrlst, codcreate, dtecreate)
                            values (p_codinst,v_codcours,v_codsubj,v_instgrd,v_dtetrlst, global_v_coduser, trunc(sysdate));
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TCRSINST');
                        end;
                    elsif v_flg = 'edit' then
                        begin
                            update  tcrsinst
                            set     codsubj   = v_codsubj,
                                    instgrd   = v_instgrd,
                                    dtetrlst   = v_dtetrlst,
                                    dteupd    = trunc(sysdate),
                                    coduser   = global_v_coduser
                            where   codinst = p_codinst and codcours = v_codcours and codsubj = v_codsubj;
                        exception when others then
                            rollback;
                        end;
                    elsif v_flg = 'delete' then
                        begin
                            delete from tcrsinst
                            where codinst = p_codinst and codcours = v_codcours and codsubj = v_codsubj;
                        end;
                    end if;
                end if;
            end loop;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab2;

    procedure save_tab3(json_str_output out clob) as
        v_tab3            json := hcm_util.get_json(json_params, 'table_education');
        v_tab3_table      json := hcm_util.get_json(v_tab3, 'rows');
        param_json_row    json;
        v_codedlv         varchar2(4 char);
        v_desmajsb        varchar2(100 char);
        v_desinstit       varchar2(100 char);
        v_codcnty         varchar2(4 char);
        v_desnote         varchar2(500 char);
        v_flg             varchar2(6 char);
        v_rowId           number(2,0);
        v_count_codcnty   int;
        v_numseq          int;
    begin

        if param_msg_error is null and p_stainst = 'E' then

            for i in 0..v_tab3_table.count-1 loop
                param_json_row  := hcm_util.get_json(v_tab3_table, to_char(i));
                v_codedlv      := hcm_util.get_string(param_json_row,'desedlv');
                v_desmajsb       := hcm_util.get_string(param_json_row,'desmajsb');
                v_desinstit       := hcm_util.get_string(param_json_row,'desinstit');
                v_codcnty      := hcm_util.get_string(param_json_row,'codcnty');
                v_desnote      := hcm_util.get_string(param_json_row,'desnote');
                v_flg           := hcm_util.get_string(param_json_row,'flg');
                v_count_codcnty         := 0;
                if v_flg = 'add' or v_flg = 'edit' then
                    if v_codedlv is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    end if;

                    begin
                        select  count(codcodec)
                        into    v_count_codcnty
                        from    tcodcnty
                        where   codcodec = v_codcnty;
                    end;

                    if v_count_codcnty = 0 then
                        param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TCOURSUB');
                    end if;
                end if;
            end loop;

            if param_msg_error is null then
                for i in 0..v_tab3_table.count-1 loop
                    param_json_row  := hcm_util.get_json(v_tab3_table, to_char(i));
                    v_codedlv       := hcm_util.get_string(param_json_row,'desedlv');
                    v_desmajsb      := hcm_util.get_string(param_json_row,'desmajsb');
                    v_desinstit     := hcm_util.get_string(param_json_row,'desinstit');
                    v_codcnty       := hcm_util.get_string(param_json_row,'codcnty');
                    v_desnote       := hcm_util.get_string(param_json_row,'desnote');
                    v_flg           := hcm_util.get_string(param_json_row,'flg');
                    v_rowId         := hcm_util.get_string(param_json_row,'numseq');
                    v_numseq        := 0;

                    if v_flg = 'add' then
                        begin
                            select nvl(max(numseq), 0)
                            into v_numseq
                            from tinstedu
                            where codinst = p_codinst;
                        end;

                        begin
                            insert into tinstedu(codinst, numseq, codedlv, desmajsb, desinstit, codcnty, desnote, codcreate, dtecreate)
                            values (p_codinst, v_numseq+1, v_codedlv, v_desmajsb,v_desinstit,v_codcnty, v_desnote, global_v_coduser, trunc(sysdate));
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TINSTEDU');
                        end;
                    elsif v_flg = 'edit' then
                        begin
                            update  tinstedu
                            set     desmajsb    =  v_desmajsb,
                                    desinstit   = v_desinstit,
                                    codcnty     = v_codcnty,
                                    desnote     = v_desnote,
                                    dteupd    = trunc(sysdate),
                                    coduser   = global_v_coduser
                            where   codinst = p_codinst and numseq = v_rowId;
                        exception when others then
                            rollback;
                        end;
                    elsif v_flg = 'delete' then
                        begin
                            delete from tinstedu
                            where codinst = p_codinst and numseq = v_rowId;
                        end;
                    end if;
                end loop;
            end if;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab3;

    procedure save_tab4(json_str_output out clob) as
        v_tab4            json := hcm_util.get_json(json_params, 'table_career');
        v_tab4_table      json := hcm_util.get_json(v_tab4, 'rows');
        param_json_row    json;
        v_desnoffi        varchar2(45 char);
        v_namepos         varchar2(100 char);
        v_desjob          varchar2(1000 char);
        v_dtestart        date;
        v_dteend          date;
        v_flg             varchar2(6 char);
        v_numseq          number(2,0);
        v_rowId           number(2,0);
    begin

        if param_msg_error is null and p_stainst = 'E' then
            for i in 0..v_tab4_table.count-1 loop
                param_json_row  := hcm_util.get_json(v_tab4_table, to_char(i));
                v_desnoffi      := hcm_util.get_string(param_json_row,'desc_codcomp');
                v_namepos       := hcm_util.get_string(param_json_row,'desc_codpos');
                v_desjob        := hcm_util.get_string(param_json_row,'desc_codjob');
                v_dtestart      := to_date(hcm_util.get_string(param_json_row,'dteempmt'), 'dd/mm/yyyy');
                v_dteend        := to_date(hcm_util.get_string(param_json_row,'dteeffex'), 'dd/mm/yyyy');
                v_flg           := hcm_util.get_string(param_json_row,'flg');
                v_numseq         := 0;

                if v_flg = 'add' or v_flg = 'edit' then
                    if v_desnoffi is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    end if;

                    if v_namepos is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    end if;

                    if v_dtestart is null then
                        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                    end if;

                    if v_dtestart > to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy') then
                        param_msg_error := get_error_msg_php('HR2025',global_v_lang);
                    end if;

                    if v_dteend > to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy') then
                        param_msg_error := get_error_msg_php('HR2025',global_v_lang);
                    end if;

                    if v_dtestart > v_dteend then
                        param_msg_error := get_error_msg_php('HR2025',global_v_lang);
                    end if;
                end if;
            end loop;

            if param_msg_error is null then
                for i in 0..v_tab4_table.count-1 loop
                    param_json_row  := hcm_util.get_json(v_tab4_table, to_char(i));
                    v_desnoffi      := hcm_util.get_string(param_json_row,'desc_codcomp');
                    v_namepos       := hcm_util.get_string(param_json_row,'desc_codpos');
                    v_desjob        := hcm_util.get_string(param_json_row,'desc_codjob');
                    v_dtestart      := to_date(hcm_util.get_string(param_json_row,'dteempmt'), 'dd/mm/yyyy');
                    v_dteend        := to_date(hcm_util.get_string(param_json_row,'dteeffex'), 'dd/mm/yyyy');
                    v_flg           := hcm_util.get_string(param_json_row,'flg');
                    v_rowId         := hcm_util.get_string(param_json_row,'numseq');

                    v_numseq         := 0;

                    if v_flg = 'add' then
                        begin
                            select nvl(max(numseq), 0)
                            into v_numseq
                            from tinstwex
                            where codinst = p_codinst;
                        end;

                        begin
                            insert into tinstwex(codinst, numseq, desnoffi, namepos, desjob, dtestart, dteend, codcreate, dtecreate)
                            values (p_codinst, v_numseq+1, v_desnoffi, v_namepos, v_desjob, v_dtestart, v_dteend, global_v_coduser, trunc(sysdate));
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005',global_v_lang, 'TINSTWEX');
                        end;
                    elsif v_flg = 'edit' then
                        begin
                            update  tinstwex
                            set     desnoffi    = v_desnoffi,
                                    namepos     = v_namepos,
                                    desjob      = v_desjob,
                                    dtestart    = v_dtestart,
                                    dteend      = v_dteend,
                                    dteupd      = trunc(sysdate),
                                    coduser     = global_v_coduser
                            where   codinst = p_codinst and numseq = v_rowId;
                        end;
                    elsif v_flg = 'delete' then
                        begin
                            delete from tinstwex
                            where codinst = p_codinst and numseq = v_rowId;
                        end;
                    end if;
                end loop;
            end if;
        end if;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_tab4;

    function get_codempid_bycodinst(p_codinst VARCHAR2) return varchar2 is
        v_codempid      varchar2(10 char);
    begin
        begin
            select codempid
            into   v_codempid
            from   tinstruc
            where  codinst  = p_codinst;
        exception when no_data_found then
            v_codempid := null;
        end;
        return v_codempid;
    end get_codempid_bycodinst;

    function get_tinstruc_stainst(p_codinst VARCHAR2) return varchar2 is
        v_stainst      varchar2(1 char);
    begin
        begin
            select stainst
            into   v_stainst
            from   tinstruc
            where  codinst  = p_codinst;
        exception when no_data_found then
            v_stainst := null;
        end;
        return v_stainst;
    end get_tinstruc_stainst;

END HRTR21E;

/

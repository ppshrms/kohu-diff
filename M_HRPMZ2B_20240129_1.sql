--------------------------------------------------------
--  DDL for Package Body M_HRPMZ2B_20240129
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPMZ2B_20240129" as

    procedure initial_value (json_str in clob) is
        json_obj        json_object_t;
        test    clob;
    begin
        json_obj            := json_object_t(json_str);
        -- global
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        p_filename          := hcm_util.get_string_t(json_obj,'p_filename');
        p_typedata          := hcm_util.get_string_t(json_obj,'p_typedata');

        p_tablename         := hcm_util.get_string_t(json_obj,'p_tablename'); 
        p_lovtype           := hcm_util.get_string_t(json_obj,'p_lovtype'); 

        p_dteimptst         := to_date(hcm_util.get_string_t(json_obj,'p_dteimptst'),'dd/mm/yyyyhh24miss');
        p_dteimpten         := to_date(hcm_util.get_string_t(json_obj,'p_dteimpten'),'dd/mm/yyyyhh24miss');

        p_coduser_auto      := nvl(global_v_coduser,'AUTO');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
    end initial_value;

    procedure get_process (json_str_input in clob, json_str_output out clob) is
        out_file            utl_file.File_Type;
        v_filename          varchar2(4000 char);
        v_title             varchar2(4000 char);
        v_task_id           varchar2(4000 char);
        v_file_path         varchar2(4000 char);
        v_chek              varchar2(10 char);
    begin
        initial_value(json_str_input);
        p_path_file := 'UTL_FILE_DIR';

        v_title := get_tsetup_value('PMZ2BT'||p_typedata);
        if p_filename is not null and p_filename like '%'||v_title||'%' then
            param_msg_error := null;
        else
            param_msg_error := get_error_msg_php('PMZ004', global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        if param_msg_error is null then
            process_import_manual(json_str_input,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_process;

    procedure get_set_defaults (json_str_input in clob, json_str_output out clob) is
        v_clob  clob;
    begin
        initial_value(json_str_input);    
        if param_msg_error is null then
            gen_set_defaults(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end get_set_defaults;

    procedure gen_set_defaults(json_str_output out clob) is
        obj_row         json_object_t;
        obj_data        json_object_t;

        v_rcnt          number  := 0;
        v_tablename     ttypecode.tablename%type;
        v_lovname       ttypecode.codapp%type;
        v_datatype      varchar2(100 char);
        v_typedata      varchar2(100 char);

        cursor c_tinitdef is
            select namtbl,namfild,decode(global_v_lang,'101',namfilde,
                                                       '102',namfildt,
                                                       '102',namfild3,
                                                       '102',namfild4,
                                                       '102',namfild5,namfildt) desc_namfild,
                   datavalue,codapp,datatype
              from tinitdef
             where typedata = p_typedata
            order by rownum;

    begin
        obj_row       := json_object_t();
        v_rcnt        := 0;

        for r_tinitdef in c_tinitdef loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('rcnt', to_char(v_rcnt));
            obj_data.put('desc_namfild',r_tinitdef.desc_namfild);
            obj_data.put('datavalue',nvl(r_tinitdef.datavalue,''));
            obj_data.put('typedata',p_typedata);            
            obj_data.put('namtbl',r_tinitdef.namtbl);
            obj_data.put('namfild',r_tinitdef.namfild);
            obj_data.put('lovtype',r_tinitdef.codapp);
            obj_data.put('datatype',r_tinitdef.datatype);
            obj_row.put(to_char(v_rcnt-1), obj_data);
        end loop;
        json_str_output := obj_row.to_clob;
    end gen_set_defaults;


    procedure save_default(json_str_input in clob, json_str_output out clob) as
        param_json          json_object_t;
        param_json_row      json_object_t;
        v_stmt              varchar2(2000 char) := '';
        v_comlvl            varchar2(3 char);
        v_flgcond           number;   
        v_param_json        clob;

        v_datavalue         tinitdef.datavalue%type;
        v_namtbl            tinitdef.namtbl%type;
        v_namfild           tinitdef.namfild%type;

    begin
        initial_value(json_str_input);
        json_input_str      := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
        for i in 0..json_input_str.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(json_input_str, to_char(i));
            v_datavalue     := hcm_util.get_string_t(param_json_row,'datavalue');
            v_namtbl        := hcm_util.get_string_t(param_json_row,'namtbl');
            v_namfild       := hcm_util.get_string_t(param_json_row,'namfild');
            v_flg           := hcm_util.get_string_t(param_json_row,'flg');
            p_typedata      := hcm_util.get_string_t(param_json_row,'typedata');

            update tinitdef set datavalue  = v_datavalue,
                                dteupd     = sysdate,
                                coduser    = global_v_coduser
            where typedata = p_typedata
              and namtbl   = v_namtbl
              and namfild  = v_namfild ;

        end loop;


        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        else
            rollback;
            end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure delete_log_import(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);

        begin
            delete timpfiles 
             where typedata = p_typedata
               and trunc(dteimpt) between p_dteimptst and p_dteimpten;
        end ;

        if param_msg_error is null then
            commit;
            param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        else
            rollback;
            end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure check_header (p_typdate     in varchar2,
                            p_namefile    in varchar2,
                            p_data        in varchar2,
                            p_count       in number ,
                            p_delimiter   in varchar2,
                            p_dteimpt     in varchar2,
                            p_record      in number,
                            p_lang        in varchar2,
                            p_error       in out varchar2) is

      data_file             varchar2(4000 char) ;
      v_delimiter	        varchar2(5 char) := nvl(p_delimiter,','); 
      v_cnt_delimiter       number ;
      j 					number;
      k 					number;	
      v_remark              varchar2(200 char) ;

    begin
        data_file := p_data;
        data_file := replace(data_file,chr(13),'') ;
        data_file := replace(data_file,chr(10),'') ;
        data_file := replace(data_file,chr(13)||chr(10),'') ;
        for i in 1..p_count loop		
            v_head(i) := null;				
        end loop;

        v_cnt_delimiter := 0;
        for i in 1..p_count loop
            v_cnt_delimiter := v_cnt_delimiter + 1;
            k := instr(data_file,p_delimiter,1,1);																							

            if k > 0 then
                v_head(i) := substr(data_file,1,k - 1);
                data_file := substr(data_file,k + 1); -- cut off already retrieved data

                if data_file is null then -- null after delimiter char is a last data, add count + 1 (before out of loop).
                    v_head(i+1) := null;
                    v_cnt_delimiter := v_cnt_delimiter + 1;
                end if;
            else 
                v_head(i) := substr(data_file,1);-- end of data
                data_file := null;
            end if;	
            v_head(i) := trim(v_head(i));
--insert into a(a,d) values(i,v_head(i)); commit; 
        exit when data_file is null;-- and k <= 0;
        end loop;

        if data_file is not null or v_cnt_delimiter <> p_count then -- data over or lack of data 
            v_remark  := get_error_msg_php('PMZ001',p_lang);
            insert_timpfiles(p_typdate,p_dteimpt,p_record,p_namefile,p_data,null,null,null,null,null,null,null,null,null,'N',v_remark);
            p_error := 'Y';
            return ;
        end if;

    end;

    procedure check_detail (p_typdate     in varchar2,
                            p_namefile    in varchar2,
                            p_data        in varchar2,
                            p_count       in number ,
                            p_delimiter   in varchar2,
                            p_dteimpt     in varchar2,
                            p_record      in number,
                            p_lang        in varchar2,
                            p_error       in out varchar2) is

      data_file         varchar2(4000 char) ;
      v_delimiter	    varchar2(5 char) := nvl(p_delimiter,','); 
      v_cnt_delimiter   number ;
      j                 number ;
      k                 number ;
      v_error           varchar2(4000 char) := null ;
      v_remark          varchar2(200 char) ;

    begin
        --01102022|"035189|"P001|"|"|"4500.00  
        data_file := p_data;
        data_file := replace(data_file,chr(13),'') ;
        data_file := replace(data_file,chr(10),'') ;
        data_file := replace(data_file,chr(13)||chr(10),'') ;
        for i in 1..p_count loop		
            v_text(i) := null;				
        end loop;

        v_cnt_delimiter := 0;
        for i in 1..p_count loop
            v_cnt_delimiter := v_cnt_delimiter + 1;
            k := instr(data_file,p_delimiter,1,1) ; 																							        
            if k > 0 then
                v_text(i) := substr(data_file,1,k - 1);
                data_file := substr(data_file,k + 1); -- cut off already retrieved data

                if data_file is null then -- null after delimiter char is a last data, add count + 1 (before out of loop).
                    v_cnt_delimiter := v_cnt_delimiter + 1;
                end if;
            else 
                v_text(i) := substr(data_file,1);-- end of data
                data_file := null;
            end if;	

            v_text(i) := trim(v_text(i));
--insert into a(a,b,d) values(i,v_head(i),v_text(i)); commit; 
            exit when data_file is null;-- and k <= 0;
        end loop;

        if data_file is not null or v_cnt_delimiter <> p_count then -- data over or lack of data 
            v_remark  := get_error_msg_php('PMZ001',p_lang);
            insert_timpfiles(p_typdate,p_dteimpt,p_record,p_namefile,p_data,null,null,null,null,null,null,null,null,null,'N',v_remark);
            p_error := 'Y';
            return ;
        end if;
    end;

    procedure process_import_manual(json_str_input in clob, json_str_output out clob) is
        obj_row         json_object_t;
        obj_row2        json_object_t;
        obj_data        json_object_t;
        obj_data2       json_object_t;

        json_obj        json_object_t;
        obj_param_json  json_object_t;
        param_json_row  json_object_t;

        v_row           number := 0;
        v_sumrec        number  := 0;
        v_sumcomplete   number  := 0;
        v_sumerr        number  := 0;
        v_response      varchar2(4000);
        v_error         varchar2(10);
        v_rcnt          number  := 0;
        v_typedata      varchar2(10);

        v_check         clob;
        v_datarec       clob;
        v_codempid      varchar2(4000 char);
        ---Import Employee Data---
        v_namtitle      varchar2(4000 char);
        v_namtitlt      varchar2(4000 char);
        v_namfirste     varchar2(4000 char);   
        v_namfirstt     varchar2(4000 char);
        v_namlaste      varchar2(4000 char);
        v_namlastt      varchar2(4000 char);
        v_codsex        varchar2(4000 char);
        v_dteempdb      varchar2(4000 char);
        v_stamarry      varchar2(4000 char);
        v_staemp        varchar2(4000 char);
        v_dteempmt      varchar2(4000 char);
        v_codcomp       varchar2(4000 char);
        v_codpos        varchar2(4000 char);
        v_codbrlc       varchar2(4000 char);
        v_codempmt      varchar2(4000 char);
        v_typpayroll    varchar2(4000 char);
        v_typemp        varchar2(4000 char);
        v_codcalen      varchar2(4000 char);
        v_codjob        varchar2(4000 char);
        v_flgatten      varchar2(4000 char);
        v_dteefpos      varchar2(4000 char);
        v_dteeflvl      varchar2(4000 char);
        v_dteeffex      varchar2(4000 char);
        v_dteduepr      varchar2(4000 char);
        v_dteoccup      varchar2(4000 char);
        v_qtydatrq      varchar2(4000 char);
        v_numtelof      varchar2(4000 char);
        v_email         varchar2(4000 char);
        v_codcompr      varchar2(4000 char);
        v_codposre      varchar2(4000 char);
        v_codorgin      varchar2(4000 char);
        v_codnatnl      varchar2(4000 char);
        v_codrelgn      varchar2(4000 char);
        v_codblood      varchar2(4000 char);
        v_stamilit      varchar2(4000 char);
        v_coddomcl      varchar2(4000 char);
        v_numoffid      varchar2(4000 char);
        v_adrissue      varchar2(4000 char);
        v_codprovi      varchar2(4000 char);
        v_dteoffid      varchar2(4000 char);
        v_adrregt       varchar2(4000 char);
        v_codposte      varchar2(4000 char);
        v_codcntyi      varchar2(4000 char);
        v_adrcontt      varchar2(4000 char);
        v_codpostc      varchar2(4000 char);
        v_codcntyc      varchar2(4000 char);
        v_numtelem      varchar2(4000 char);
        v_numlicid      varchar2(4000 char);
        v_dtelicid      varchar2(4000 char);
        v_high          varchar2(4000 char);
        v_weight        varchar2(4000 char);
        v_numpasid      varchar2(4000 char);
        v_dtepasid      varchar2(4000 char);
        v_numprmid      varchar2(4000 char);
        v_dteprmst      varchar2(4000 char);
        v_dteprmen      varchar2(4000 char);
        v_codbank       varchar2(4000 char);
        v_numbank       varchar2(4000 char);
        v_amttranb      varchar2(4000 char);
        v_codbank2      varchar2(4000 char);
        v_numbank2      varchar2(4000 char);
        v_codcurr       varchar2(4000 char);
        v_amtincom1     varchar2(4000 char);
        v_amtincom2     varchar2(4000 char);
        v_amtincom3     varchar2(4000 char);
        v_amtincom4     varchar2(4000 char);
        v_amtincom5     varchar2(4000 char);
        v_amtincom6     varchar2(4000 char);
        v_amtincom7     varchar2(4000 char);
        v_amtincom8     varchar2(4000 char);
        v_amtincom9     varchar2(4000 char);
        v_amtincom10    varchar2(4000 char);
        v_numtaxid      varchar2(4000 char);
        v_numsaid       varchar2(4000 char);
        v_typtax        varchar2(4000 char);
        v_flgtax        varchar2(4000 char);
        v_amtinsu       varchar2(4000 char);
        v_amtint        varchar2(4000 char);
        v_amtdon        varchar2(4000 char);
        v_dtebf         varchar2(4000 char);
        v_amtincbf      varchar2(4000 char);
        v_amttaxbf      varchar2(4000 char);
        v_amtsaid       varchar2(4000 char);
        v_amtpf         varchar2(4000 char);
        v_amtrmf        varchar2(4000 char);
        v_qtychedu      varchar2(4000 char);
        v_qtychned      varchar2(4000 char);
        v_amtinssp      varchar2(4000 char);
        v_amtintsp      varchar2(4000 char);
        v_amtdonsp      varchar2(4000 char);
        v_dtebfsp       varchar2(4000 char);
        v_amtincsp      varchar2(4000 char);
        v_amttaxsp      varchar2(4000 char);
        v_amtsasp       varchar2(4000 char);
        v_amtpfsp       varchar2(4000 char);
        v_namfathr      varchar2(4000 char);
        v_codfnatn      varchar2(4000 char);
        v_codfrelg      varchar2(4000 char);
        v_codfoccu      varchar2(4000 char);
        v_nammothr      varchar2(4000 char);
        v_codmnatn      varchar2(4000 char);
        v_codmrelg      varchar2(4000 char);
        v_codmoccu      varchar2(4000 char);
        v_namcont       varchar2(4000 char);
        v_adrcont1      varchar2(4000 char);
        v_codpost       varchar2(4000 char);
        v_numtele       varchar2(4000 char);
        v_numfax        varchar2(4000 char);
        v_emailf        varchar2(4000 char);
        v_desrelat      varchar2(4000 char);
        v_namspous      varchar2(4000 char);
        v_dtespbd       varchar2(4000 char);
        v_numoffidsp    varchar2(4000 char);
        v_codspocc      varchar2(4000 char);
        v_dtemarry      varchar2(4000 char);
        v_desplreg      varchar2(4000 char);
        v_codsppro      varchar2(4000 char);
        v_codspcty      varchar2(4000 char);
        v_desnoffi      varchar2(4000 char);
        v_desnote       varchar2(4000 char);

        ---Import Children Data---
        v_namchild      varchar2(4000 char);
        v_dtechbd       varchar2(4000 char);      
        v_codsexc       varchar2(4000 char);
        v_codedlvc      varchar2(4000 char);

        ---Import Education Data---
        v_codedlve      varchar2(4000 char);
        v_coddglv       varchar2(4000 char);
        v_codinst       varchar2(4000 char);
        v_codmajsb      varchar2(4000 char);
        v_codminsb      varchar2(4000 char);
        v_codcount      varchar2(4000 char);
        v_numgpa        varchar2(4000 char);
        v_stayear       varchar2(4000 char);
        v_dtegyear      varchar2(4000 char);
        v_flgeduc       varchar2(4000 char);

        ---Import Work Exp Data---
        v_desnoffiw     varchar2(4000 char);
        v_deslstjob1    varchar2(4000 char);  
        v_desoffi1      varchar2(4000 char);
        v_numteleo      varchar2(4000 char);
        v_deslstpos     varchar2(4000 char);
        v_dtestart      varchar2(4000 char);
        v_dteend        varchar2(4000 char);
        v_amtincom      varchar2(4000 char);
        v_desres        varchar2(4000 char);
        v_namboss       varchar2(4000 char);
        v_remarkexp     varchar2(4000 char);

        ---Import Movement Data---
        v_dteeffec      varchar2(4000 char);
        v_codtrn        varchar2(4000 char);
        v_codcompm      varchar2(4000 char);
        v_codposm       varchar2(4000 char);
        v_codbrlcm      varchar2(4000 char);
        v_codempmtm     varchar2(4000 char);
        v_typpayrollm   varchar2(4000 char);
        v_typempm       varchar2(4000 char);
        v_codcalenm     varchar2(4000 char);
        v_codjobm       varchar2(4000 char);
        v_flgattenm     varchar2(4000 char);
        v_stapost2      varchar2(4000 char);
        v_amtincadj1    varchar2(4000 char);
        v_amtincadj2    varchar2(4000 char);
        v_amtincadj3    varchar2(4000 char);
        v_amtincadj4    varchar2(4000 char);
        v_amtincadj5    varchar2(4000 char);
        v_amtincadj6    varchar2(4000 char);
        v_amtincadj7    varchar2(4000 char);
        v_amtincadj8    varchar2(4000 char);
        v_amtincadj9    varchar2(4000 char);
        v_amtincadj10   varchar2(4000 char);
        v_codcurrm      varchar2(4000 char);

        ---Import Termination Data---
        v_dteeffect     varchar2(4000 char);
        v_codexemp      varchar2(4000 char);
        v_numexemp      varchar2(4000 char);
        v_desnotet      varchar2(4000 char);
        v_flgblist      varchar2(4000 char);
        v_flgssm        varchar2(4000 char);

        ---Import Rehire Data---
        v_codnewid      varchar2(4000 char);
        v_dtereemp      varchar2(4000 char);
        v_numreqst      varchar2(4000 char);
        v_codcomprh     varchar2(4000 char);
        v_codposr       varchar2(4000 char);
        v_codbrlcr      varchar2(4000 char);
        v_codempmtr     varchar2(4000 char);
        v_typpayrollr   varchar2(4000 char);
        v_typempr       varchar2(4000 char);
        v_codcalenr     varchar2(4000 char);
        v_codjobr       varchar2(4000 char);        
        v_flgattenr     varchar2(4000 char);
        v_flgreemp      varchar2(4000 char);
        v_qtydatrqr     varchar2(4000 char);
        v_staempr       varchar2(4000 char);
        v_dtedueprr     varchar2(4000 char);
        v_codcurrr      varchar2(4000 char);
        v_numtelofr     varchar2(4000 char);
        v_emailr        varchar2(4000 char);

        --Import Ohter Income Data---
        v_codpay        varchar2(4000 char);
        v_numperiod     varchar2(4000 char);
        v_dtemthpay     varchar2(4000 char);
        v_dteyrepay     varchar2(4000 char);
        v_amtpay        varchar2(4000 char);
        v_dtepaymt      varchar2(4000 char);


        v_cnt_col		number := 0;
        v_dlt           varchar2(10 char) := ',';
        v_numseq        number := 0;
        data_file       varchar2(32767 char);
        v_staerror      varchar2(1 char); 
        v_dteimpt       date;
        v_rec_error     number := 0;
        v_rec_tran      number := 0;
        p_lang          varchar2(3 char) := '102'; 
        v_numcompl		number := 0;
        v_numermap		number := 0;

        cursor c_timpfiles is
            select * from timpfiles
              where typedata = p_typedata
                and dteimpt  = to_date(p_dteimptwdc,'dd/mm/yyyy hh24miss')
            order by namefile,numseq;

    begin
        initial_value(json_str_input);
        json_obj        := json_object_t(json_str_input);
        obj_param_json  := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str')); 
        v_check         := obj_param_json.to_clob;
        v_dteimpt       := to_date(to_char(sysdate,'dd/mm/yyyy hh24miss'),'dd/mm/yyyy hh24miss');
        p_dteimptwdc    := to_char(v_dteimpt,'dd/mm/yyyy hh24miss');   

        for i in 0..obj_param_json.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(obj_param_json,to_char(i));
            v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
            v_datarec       := null; 

            if p_typedata = '10' then
                v_cnt_col := 121;
                ---Import Employee Data---
                v_namtitle      := hcm_util.get_string_t(param_json_row,'namtitle');
                v_namtitlt      := hcm_util.get_string_t(param_json_row,'namtitlt');
                v_namfirste     := hcm_util.get_string_t(param_json_row,'namfirste');   
                v_namfirstt     := hcm_util.get_string_t(param_json_row,'namfirstt');
                v_namlaste      := hcm_util.get_string_t(param_json_row,'namlaste');
                v_namlastt      := hcm_util.get_string_t(param_json_row,'namlastt');
                v_codsex        := hcm_util.get_string_t(param_json_row,'codsex');
                v_dteempdb      := hcm_util.get_string_t(param_json_row,'dteempdb');
                v_stamarry      := hcm_util.get_string_t(param_json_row,'stamarry');
                v_staemp        := hcm_util.get_string_t(param_json_row,'staemp');
                v_dteempmt      := hcm_util.get_string_t(param_json_row,'dteempmt');
                v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
                v_codpos        := hcm_util.get_string_t(param_json_row,'codpos');
                v_codbrlc       := hcm_util.get_string_t(param_json_row,'codbrlc');
                v_codempmt      := hcm_util.get_string_t(param_json_row,'codempmt');
                v_typpayroll    := hcm_util.get_string_t(param_json_row,'typpayroll');
                v_typemp        := hcm_util.get_string_t(param_json_row,'typemp');
                v_codcalen      := hcm_util.get_string_t(param_json_row,'codcalen');
                v_codjob        := hcm_util.get_string_t(param_json_row,'codjob');
                v_flgatten      := hcm_util.get_string_t(param_json_row,'flgatten');
                v_dteefpos      := hcm_util.get_string_t(param_json_row,'dteefpos');
                v_dteeflvl      := hcm_util.get_string_t(param_json_row,'dteeflvl');
                v_dteeffex      := hcm_util.get_string_t(param_json_row,'dteeffex');
                v_dteduepr      := hcm_util.get_string_t(param_json_row,'dteduepr');
                v_dteoccup      := hcm_util.get_string_t(param_json_row,'dteoccup');
                v_qtydatrq      := hcm_util.get_string_t(param_json_row,'qtydatrq');
                v_numtelof      := hcm_util.get_string_t(param_json_row,'numtelof');
                v_email         := hcm_util.get_string_t(param_json_row,'email');
                v_codcompr      := hcm_util.get_string_t(param_json_row,'codcompr');
                v_codposre      := hcm_util.get_string_t(param_json_row,'codposre');
                v_codorgin      := hcm_util.get_string_t(param_json_row,'codorgin');
                v_codnatnl      := hcm_util.get_string_t(param_json_row,'codnatnl');
                v_codrelgn      := hcm_util.get_string_t(param_json_row,'codrelgn');
                v_codblood      := hcm_util.get_string_t(param_json_row,'codblood');
                v_stamilit      := hcm_util.get_string_t(param_json_row,'stamilit');
                v_coddomcl      := hcm_util.get_string_t(param_json_row,'coddomcl');
                v_numoffid      := hcm_util.get_string_t(param_json_row,'numoffid');
                v_adrissue      := hcm_util.get_string_t(param_json_row,'adrissue');
                v_codprovi      := hcm_util.get_string_t(param_json_row,'codprovi');
                v_dteoffid      := hcm_util.get_string_t(param_json_row,'dteoffid');
                v_adrregt       := hcm_util.get_string_t(param_json_row,'adrregt');
                v_codposte      := hcm_util.get_string_t(param_json_row,'codposte');
                v_codcntyi      := hcm_util.get_string_t(param_json_row,'codcntyi');
                v_adrcontt      := hcm_util.get_string_t(param_json_row,'adrcontt');
                v_codpostc      := hcm_util.get_string_t(param_json_row,'codpostc');
                v_codcntyc      := hcm_util.get_string_t(param_json_row,'codcntyc');
                v_numtelem      := hcm_util.get_string_t(param_json_row,'numtelem');
                v_numlicid      := hcm_util.get_string_t(param_json_row,'numlicid');
                v_dtelicid      := hcm_util.get_string_t(param_json_row,'dtelicid');
                v_high          := hcm_util.get_string_t(param_json_row,'high');
                v_weight        := hcm_util.get_string_t(param_json_row,'weight');
                v_numpasid      := hcm_util.get_string_t(param_json_row,'numpasid');
                v_dtepasid      := hcm_util.get_string_t(param_json_row,'dtepasid');
                v_numprmid      := hcm_util.get_string_t(param_json_row,'numprmid');
                v_dteprmst      := hcm_util.get_string_t(param_json_row,'dteprmst');
                v_dteprmen      := hcm_util.get_string_t(param_json_row,'dteprmen');
                v_codbank       := hcm_util.get_string_t(param_json_row,'codbank');
                v_numbank       := hcm_util.get_string_t(param_json_row,'numbank');
                v_amttranb      := hcm_util.get_string_t(param_json_row,'amttranb');
                v_codbank2      := hcm_util.get_string_t(param_json_row,'codbank2');
                v_numbank2      := hcm_util.get_string_t(param_json_row,'numbank2');
                v_codcurr       := hcm_util.get_string_t(param_json_row,'codcurr');
                v_amtincom1     := hcm_util.get_string_t(param_json_row,'amtincom1');
                v_amtincom2     := hcm_util.get_string_t(param_json_row,'amtincom2');
                v_amtincom3     := hcm_util.get_string_t(param_json_row,'amtincom3');
                v_amtincom4     := hcm_util.get_string_t(param_json_row,'amtincom4');
                v_amtincom5     := hcm_util.get_string_t(param_json_row,'amtincom5');
                v_amtincom6     := hcm_util.get_string_t(param_json_row,'amtincom6');
                v_amtincom7     := hcm_util.get_string_t(param_json_row,'amtincom7');
                v_amtincom8     := hcm_util.get_string_t(param_json_row,'amtincom8');
                v_amtincom9     := hcm_util.get_string_t(param_json_row,'amtincom9');
                v_amtincom10    := hcm_util.get_string_t(param_json_row,'amtincom10');
                v_numtaxid      := hcm_util.get_string_t(param_json_row,'numtaxid');
                v_numsaid       := hcm_util.get_string_t(param_json_row,'numsaid');
                v_typtax        := hcm_util.get_string_t(param_json_row,'typtax');
                v_flgtax        := hcm_util.get_string_t(param_json_row,'flgtax');
                v_amtinsu       := hcm_util.get_string_t(param_json_row,'amtinsu');
                v_amtint        := hcm_util.get_string_t(param_json_row,'amtint');
                v_amtdon        := hcm_util.get_string_t(param_json_row,'amtdon');
                v_dtebf         := hcm_util.get_string_t(param_json_row,'dtebf');
                v_amtincbf      := hcm_util.get_string_t(param_json_row,'amtincbf');
                v_amttaxbf      := hcm_util.get_string_t(param_json_row,'amttaxbf');
                v_amtsaid       := hcm_util.get_string_t(param_json_row,'amtsaid');
                v_amtpf         := hcm_util.get_string_t(param_json_row,'amtpf');
                v_amtrmf        := hcm_util.get_string_t(param_json_row,'amtrmf');
                v_qtychedu      := hcm_util.get_string_t(param_json_row,'qtychedu');
                v_qtychned      := hcm_util.get_string_t(param_json_row,'qtychned');
                v_amtinssp      := hcm_util.get_string_t(param_json_row,'amtinssp');
                v_amtintsp      := hcm_util.get_string_t(param_json_row,'amtintsp');
                v_amtdonsp      := hcm_util.get_string_t(param_json_row,'amtdonsp');
                v_dtebfsp       := hcm_util.get_string_t(param_json_row,'dtebfsp');
                v_amtincsp      := hcm_util.get_string_t(param_json_row,'amtincsp');
                v_amttaxsp      := hcm_util.get_string_t(param_json_row,'amttaxsp');
                v_amtsasp       := hcm_util.get_string_t(param_json_row,'amtsasp');
                v_amtpfsp       := hcm_util.get_string_t(param_json_row,'amtpfsp');
                v_namfathr      := hcm_util.get_string_t(param_json_row,'namfathr');
                v_codfnatn      := hcm_util.get_string_t(param_json_row,'codfnatn');
                v_codfrelg      := hcm_util.get_string_t(param_json_row,'codfrelg');
                v_codfoccu      := hcm_util.get_string_t(param_json_row,'codfoccu');
                v_nammothr      := hcm_util.get_string_t(param_json_row,'nammothr');
                v_codmnatn      := hcm_util.get_string_t(param_json_row,'codmnatn');
                v_codmrelg      := hcm_util.get_string_t(param_json_row,'codmrelg');
                v_codmoccu      := hcm_util.get_string_t(param_json_row,'codmoccu');
                v_namcont       := hcm_util.get_string_t(param_json_row,'namcont');
                v_adrcont1      := hcm_util.get_string_t(param_json_row,'adrcont1');
                v_codpost       := hcm_util.get_string_t(param_json_row,'codpost');
                v_numtele       := hcm_util.get_string_t(param_json_row,'numtele');
                v_numfax        := hcm_util.get_string_t(param_json_row,'numfax');
                v_emailf        := hcm_util.get_string_t(param_json_row,'emailf');
                v_desrelat      := hcm_util.get_string_t(param_json_row,'desrelat');
                v_namspous      := hcm_util.get_string_t(param_json_row,'namspous');
                v_dtespbd       := hcm_util.get_string_t(param_json_row,'dtespbd');
                v_numoffidsp    := hcm_util.get_string_t(param_json_row,'numoffidsp');
                v_codspocc      := hcm_util.get_string_t(param_json_row,'codspocc');
                v_dtemarry      := hcm_util.get_string_t(param_json_row,'dtemarry');
                v_desplreg      := hcm_util.get_string_t(param_json_row,'desplreg');
                v_codsppro      := hcm_util.get_string_t(param_json_row,'codsppro');
                v_codspcty      := hcm_util.get_string_t(param_json_row,'codspcty');
                v_desnoffi      := hcm_util.get_string_t(param_json_row,'desnoffi');
                v_desnote       := hcm_util.get_string_t(param_json_row,'desnote');

                v_datarec :=    v_codempid||v_dlt||v_namtitle||v_dlt||v_namtitlt||v_dlt||v_namfirste||v_dlt||v_namfirstt||v_dlt||v_namlaste||v_dlt||v_namlastt||v_dlt||v_codsex||v_dlt||v_dteempdb||v_dlt||v_stamarry||v_dlt||v_staemp||v_dlt||
                                v_dteempmt||v_dlt||v_codcomp||v_dlt||v_codpos||v_dlt||v_codbrlc||v_dlt||v_codempmt||v_dlt||v_typpayroll||v_dlt||v_typemp  ||v_dlt||v_codcalen||v_dlt||v_codjob||v_dlt||v_flgatten||v_dlt||
                                v_dteefpos||v_dlt||v_dteeflvl||v_dlt||v_dteeffex||v_dlt||v_dteduepr||v_dlt||v_dteoccup||v_dlt||v_qtydatrq||v_dlt||v_numtelof||v_dlt||v_email||v_dlt||v_codcompr||v_dlt||v_codposre||v_dlt||
                                v_codorgin||v_dlt||v_codnatnl||v_dlt||v_codrelgn||v_dlt||v_codblood||v_dlt||v_stamilit||v_dlt||v_coddomcl||v_dlt||v_numoffid||v_dlt||v_adrissue||v_dlt||v_codprovi||v_dlt||v_dteoffid||v_dlt||
                                v_adrregt||v_dlt||v_codposte||v_dlt||v_codcntyi||v_dlt||v_adrcontt||v_dlt||v_codpostc||v_dlt||v_codcntyc||v_dlt||v_numtelem||v_dlt||v_numlicid||v_dlt||v_dtelicid||v_dlt||v_high||v_dlt||
                                v_weight||v_dlt||v_numpasid||v_dlt||v_dtepasid||v_dlt||v_numprmid||v_dlt||v_dteprmst||v_dlt||v_dteprmen||v_dlt||v_codbank ||v_dlt||v_numbank ||v_dlt||v_amttranb||v_dlt||v_codbank2||v_dlt||
                                v_numbank2||v_dlt||v_codcurr ||v_dlt||v_amtincom1||v_dlt||v_amtincom2||v_dlt||v_amtincom3||v_dlt||v_amtincom4||v_dlt||v_amtincom5||v_dlt||v_amtincom6||v_dlt||v_amtincom7||v_dlt||v_amtincom8||v_dlt||
                                v_amtincom9||v_dlt||v_amtincom10||v_dlt||v_numtaxid||v_dlt||v_numsaid||v_dlt||v_typtax||v_dlt||v_flgtax||v_dlt||v_amtinsu||v_dlt||v_amtint||v_dlt||v_amtdon||v_dlt||v_dtebf||v_dlt||
                                v_amtincbf||v_dlt||v_amttaxbf||v_dlt||v_amtsaid ||v_dlt||v_amtpf||v_dlt||v_amtrmf||v_dlt||v_qtychedu||v_dlt||v_qtychned||v_dlt||v_amtinssp||v_dlt||v_amtintsp||v_dlt||v_amtdonsp||v_dlt||
                                v_dtebfsp ||v_dlt||v_amtincsp||v_dlt||v_amttaxsp||v_dlt||v_amtsasp||v_dlt||v_amtpfsp||v_dlt||v_namfathr||v_dlt||v_codfnatn||v_dlt||v_codfrelg||v_dlt||v_codfoccu||v_dlt||v_nammothr||v_dlt||
                                v_codmnatn||v_dlt||v_codmrelg||v_dlt||v_codmoccu||v_dlt||v_namcont||v_dlt||v_adrcont1||v_dlt||v_codpost ||v_dlt||v_numtele ||v_dlt||v_numfax||v_dlt||v_emailf||v_dlt||v_desrelat||v_dlt||
                                v_namspous||v_dlt||v_dtespbd ||v_dlt||v_numoffidsp||v_dlt||v_codspocc||v_dlt||v_dtemarry||v_dlt||v_desplreg||v_dlt||v_codsppro||v_dlt||v_codspcty||v_dlt||v_desnoffi||v_dlt||v_desnote;
            elsif p_typedata = '20' then
                v_cnt_col := 5;
                ---Import Children Data---
                v_namchild      := hcm_util.get_string_t(param_json_row,'namchild');    
                v_dtechbd       := hcm_util.get_string_t(param_json_row,'dtechbd');    
                v_codsexc       := hcm_util.get_string_t(param_json_row,'codsex');
                v_codedlvc      := hcm_util.get_string_t(param_json_row,'codedlv'); 

                v_datarec :=    v_codempid||v_dlt||v_namchild||v_dlt||v_dtechbd||v_dlt||v_codsexc||v_dlt||v_codedlvc;
            elsif p_typedata = '30' then
                v_cnt_col := 11;
                ---Import Education Data---
                v_codedlve      := hcm_util.get_string_t(param_json_row,'codedlv');
                v_coddglv       := hcm_util.get_string_t(param_json_row,'coddglv');
                v_codinst       := hcm_util.get_string_t(param_json_row,'codinst');
                v_codmajsb      := hcm_util.get_string_t(param_json_row,'codmajsb');
                v_codminsb      := hcm_util.get_string_t(param_json_row,'codminsb');
                v_codcount      := hcm_util.get_string_t(param_json_row,'codcount');
                v_numgpa        := hcm_util.get_string_t(param_json_row,'numgpa');
                v_stayear       := hcm_util.get_string_t(param_json_row,'stayear');
                v_dtegyear      := hcm_util.get_string_t(param_json_row,'dtegyear');
                v_flgeduc       := hcm_util.get_string_t(param_json_row,'flgeduc');

                v_datarec :=    v_codempid||v_dlt||v_codedlve||v_dlt||v_coddglv||v_dlt||v_codinst||v_dlt||v_codmajsb||v_dlt||v_codminsb||v_dlt||
                                v_codcount||v_dlt||v_numgpa||v_dlt||v_stayear||v_dlt||v_dtegyear||v_dlt||v_flgeduc;
            elsif p_typedata = '40' then
                v_cnt_col := 12;
                ---Import Work Exp Data---
                v_desnoffiw     := hcm_util.get_string_t(param_json_row,'desnoffi');
                v_deslstjob1    := hcm_util.get_string_t(param_json_row,'deslstjob1');  
                v_desoffi1      := hcm_util.get_string_t(param_json_row,'desoffi1');
                v_numteleo      := hcm_util.get_string_t(param_json_row,'numteleo');
                v_deslstpos     := hcm_util.get_string_t(param_json_row,'deslstpos');
                v_dtestart      := hcm_util.get_string_t(param_json_row,'dtestart');
                v_dteend        := hcm_util.get_string_t(param_json_row,'dteend');
                v_amtincom      := hcm_util.get_string_t(param_json_row,'amtincom');
                v_desres        := hcm_util.get_string_t(param_json_row,'desres');
                v_namboss       := hcm_util.get_string_t(param_json_row,'namboss');
                v_remarkexp     := hcm_util.get_string_t(param_json_row,'remark');

                v_datarec :=    v_codempid||v_dlt||v_desnoffiw||v_dlt||v_deslstjob1||v_dlt||v_desoffi1||v_dlt||v_numteleo||v_dlt||v_deslstpos||v_dlt||
                                v_dtestart||v_dlt||v_dteend||v_dlt||v_amtincom||v_dlt||v_desres||v_dlt||v_namboss||v_dlt||v_remarkexp;
            elsif p_typedata = '50' then
                v_cnt_col := 24;
                ---Import Movement Data---
                v_dteeffec      := hcm_util.get_string_t(param_json_row,'dteeffec');
                v_codtrn        := hcm_util.get_string_t(param_json_row,'codtrn');
                v_codcompm      := hcm_util.get_string_t(param_json_row,'codcomp');
                v_codposm       := hcm_util.get_string_t(param_json_row,'codpos');
                v_codbrlcm      := hcm_util.get_string_t(param_json_row,'codbrlc');
                v_codempmtm     := hcm_util.get_string_t(param_json_row,'codempmt');
                v_typpayrollm   := hcm_util.get_string_t(param_json_row,'typpayroll');
                v_typempm       := hcm_util.get_string_t(param_json_row,'typemp');
                v_codcalenm     := hcm_util.get_string_t(param_json_row,'codcalen');
                v_codjobm       := hcm_util.get_string_t(param_json_row,'codjob');
                v_flgattenm     := hcm_util.get_string_t(param_json_row,'flgatten');
                v_stapost2      := hcm_util.get_string_t(param_json_row,'stapost2');
                v_amtincadj1    := hcm_util.get_string_t(param_json_row,'amtincadj1');
                v_amtincadj2    := hcm_util.get_string_t(param_json_row,'amtincadj2');
                v_amtincadj3    := hcm_util.get_string_t(param_json_row,'amtincadj3');
                v_amtincadj4    := hcm_util.get_string_t(param_json_row,'amtincadj4');
                v_amtincadj5    := hcm_util.get_string_t(param_json_row,'amtincadj5');
                v_amtincadj6    := hcm_util.get_string_t(param_json_row,'amtincadj6');
                v_amtincadj7    := hcm_util.get_string_t(param_json_row,'amtincadj7');
                v_amtincadj8    := hcm_util.get_string_t(param_json_row,'amtincadj8');
                v_amtincadj9    := hcm_util.get_string_t(param_json_row,'amtincadj9');
                v_amtincadj10   := hcm_util.get_string_t(param_json_row,'amtincadj10');
                v_codcurrm      := hcm_util.get_string_t(param_json_row,'codcurr');

                v_datarec :=    v_codempid||v_dlt||v_dteeffec||v_dlt||v_codtrn||v_dlt||v_codcompm||v_dlt||v_codposm||v_dlt||v_codbrlcm||v_dlt||
                                v_codempmtm||v_dlt||v_typpayrollm||v_dlt||v_typempm||v_dlt||v_codcalenm||v_dlt||v_codjobm||v_dlt||
                                v_flgattenm||v_dlt||v_stapost2||v_dlt||v_amtincadj1||v_dlt||v_amtincadj2||v_dlt||v_amtincadj3||v_dlt||
                                v_amtincadj4||v_dlt||v_amtincadj5||v_dlt||v_amtincadj6||v_dlt||v_amtincadj7||v_dlt||v_amtincadj8||v_dlt||
                                v_amtincadj9||v_dlt||v_amtincadj10||v_dlt||v_codcurrm;
            elsif p_typedata = '60' then
                v_cnt_col := 7;
                ---Import Termination Data---
                v_dteeffect     := hcm_util.get_string_t(param_json_row,'dteeffec');
                v_codexemp      := hcm_util.get_string_t(param_json_row,'codexemp');
                v_numexemp      := hcm_util.get_string_t(param_json_row,'numexemp');
                v_desnotet      := hcm_util.get_string_t(param_json_row,'desnote');
                v_flgblist      := hcm_util.get_string_t(param_json_row,'flgblist');
                v_flgssm        := hcm_util.get_string_t(param_json_row,'flgssm');

                v_datarec :=    v_codempid||v_dlt||v_dteeffect||v_dlt||v_codexemp||v_dlt||v_numexemp||v_dlt||v_desnotet||v_dlt||v_flgblist||v_dlt||v_flgssm;
            elsif p_typedata = '70' then
                v_cnt_col := 30;
                ---Import Rehire Data---
                v_codnewid      := hcm_util.get_string_t(param_json_row,'codnewid');
                v_dtereemp      := hcm_util.get_string_t(param_json_row,'dtereemp');
                v_numreqst      := hcm_util.get_string_t(param_json_row,'numreqst');
                v_codcomprh     := hcm_util.get_string_t(param_json_row,'codcomp');
                v_codposr       := hcm_util.get_string_t(param_json_row,'codpos');
                v_codbrlcr      := hcm_util.get_string_t(param_json_row,'codbrlc');
                v_codempmtr     := hcm_util.get_string_t(param_json_row,'codempmt');
                v_typpayrollr   := hcm_util.get_string_t(param_json_row,'typpayroll');
                v_typempr       := hcm_util.get_string_t(param_json_row,'typemp');
                v_codcalenr     := hcm_util.get_string_t(param_json_row,'codcalen');
                v_codjobr       := hcm_util.get_string_t(param_json_row,'codjob');        
                v_flgattenr     := hcm_util.get_string_t(param_json_row,'flgatten');
                v_flgreemp      := hcm_util.get_string_t(param_json_row,'flgreemp');
                v_qtydatrqr     := hcm_util.get_string_t(param_json_row,'qtydatrq');
                v_staempr       := hcm_util.get_string_t(param_json_row,'staemp');
                v_dtedueprr     := hcm_util.get_string_t(param_json_row,'dteduepr');
                v_amtincom1     := hcm_util.get_string_t(param_json_row,'amtincom1');
                v_amtincom2     := hcm_util.get_string_t(param_json_row,'amtincom2');
                v_amtincom3     := hcm_util.get_string_t(param_json_row,'amtincom3');
                v_amtincom4     := hcm_util.get_string_t(param_json_row,'amtincom4');
                v_amtincom5     := hcm_util.get_string_t(param_json_row,'amtincom5');
                v_amtincom6     := hcm_util.get_string_t(param_json_row,'amtincom6');
                v_amtincom7     := hcm_util.get_string_t(param_json_row,'amtincom7');
                v_amtincom8     := hcm_util.get_string_t(param_json_row,'amtincom8');
                v_amtincom9     := hcm_util.get_string_t(param_json_row,'amtincom9');
                v_amtincom10    := hcm_util.get_string_t(param_json_row,'amtincom10');
                v_codcurrr      := hcm_util.get_string_t(param_json_row,'codcurr');
                v_numtelofr     := hcm_util.get_string_t(param_json_row,'numtelof');
                v_emailr        := hcm_util.get_string_t(param_json_row,'email');

                v_datarec :=    v_codempid||v_dlt||v_codnewid||v_dlt||v_dtereemp||v_dlt||v_numreqst||v_dlt||v_codcomprh||v_dlt||
                                v_codposr||v_dlt||v_codbrlcr||v_dlt||v_codempmtr||v_dlt||v_typpayrollr||v_dlt||v_typempr||v_dlt||
                                v_codcalenr||v_dlt||v_codjobr||v_dlt||v_flgattenr||v_dlt||v_flgreemp||v_dlt||v_qtydatrqr||v_dlt||
                                v_staempr||v_dlt||v_dtedueprr||v_dlt||v_amtincom1||v_dlt||v_amtincom2||v_dlt||v_amtincom3||v_dlt||
                                v_amtincom4||v_dlt||v_amtincom5||v_dlt||v_amtincom6||v_dlt||v_amtincom7||v_dlt||v_amtincom8||v_dlt||
                                v_amtincom9||v_dlt||v_amtincom10||v_dlt||v_codcurrr||v_dlt||v_numtelofr||v_dlt||v_emailr;
            elsif p_typedata = '80' then
                v_cnt_col := 7;
                --Import Ohter Income Data---
                v_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
                v_numperiod     := hcm_util.get_string_t(param_json_row,'numperiod');
                v_dtemthpay     := hcm_util.get_string_t(param_json_row,'dtemthpay');
                v_dteyrepay     := hcm_util.get_string_t(param_json_row,'dteyrepay');
                v_amtpay        := hcm_util.get_string_t(param_json_row,'amtpay');
                v_dtepaymt      := hcm_util.get_string_t(param_json_row,'dtepaymt');

                v_datarec :=    v_codempid||v_dlt||v_codpay||v_dlt||v_numperiod||v_dlt||v_dtemthpay||v_dlt||v_dteyrepay||v_dlt||v_amtpay||v_dlt||v_dtepaymt;
            end if;
--insert into a(d) values(v_datarec); commit;
            if v_datarec is not null then
                data_file := ltrim(rtrim(v_datarec));  
                v_numseq  := v_numseq + 1;
                <<cal_loop>>
                loop
                --==--header--==--

                    /*if v_numseq = 1 then
                        check_header(p_typedata,p_filename,data_file,v_cnt_col,p_delimeterat,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),v_numseq,global_v_lang,v_staerror);
                        if nvl(v_staerror,'N') = 'Y' then
                            exit cal_loop;
                        end if;	

                    else	*/
                        v_rec_tran := v_rec_tran + 1;
                        v_staerror := 'N';              
                        check_detail(p_typedata,p_filename,data_file,v_cnt_col,p_delimeterat,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),v_numseq,global_v_lang,v_staerror);
                        if nvl(v_staerror,'N') = 'Y' then
                            exit cal_loop;
                        end if;	

                        v_staerror := 'N';
                        if p_typedata = '10' then                           
                            import_employee_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));                               
                        elsif p_typedata = '20' then                              
                            import_children_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));                               
                        elsif p_typedata = '30' then
                            import_education_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        elsif p_typedata = '40' then
                            import_workexp_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        elsif p_typedata = '50' then
                            import_movement_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        elsif p_typedata = '60' then
                            import_termination_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        elsif p_typedata = '70' then
                            import_rehire_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        elsif p_typedata = '80' then
                            import_othincome_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                        end if;  

                        if v_staerror = 'Y' then
                            exit cal_loop;
                        end if;   
                    --end if;
                exit cal_loop;
                end loop;
            end if;

        end loop;

        if param_msg_error is null then
            obj_row := json_object_t();
            param_msg_error := get_error_msg_php('HR2715',global_v_lang);
            v_response      := get_response_message(null,param_msg_error,global_v_lang);

            begin
                select count(*) into v_sumrec
                  from timpfiles
                  where typedata = p_typedata
                    and dteimpt  = to_date(p_dteimptwdc,'dd/mm/yyyy hh24miss');
            exception when no_data_found then
                v_sumrec := 0;        
            end ;

            begin
                select count(*) into v_sumcomplete
                  from timpfiles
                  where typedata = p_typedata
                    and dteimpt  = to_date(p_dteimptwdc,'dd/mm/yyyy hh24miss')
                    and status   = 'Y';
            exception when no_data_found then
                v_sumcomplete := 0;        
            end ;

            begin
                select count(*) into v_sumerr
                  from timpfiles
                  where typedata = p_typedata
                    and dteimpt  = to_date(p_dteimptwdc,'dd/mm/yyyy hh24miss')
                    and status   = 'N';
            exception when no_data_found then
                v_sumerr := 0;        
            end ;

            obj_row.put('coderror', '200');
            obj_row.put('result', obj_data);
            obj_row.put('response', hcm_util.get_string(json(v_response),'response'));
            obj_row.put('tranfer', nvl(v_sumrec,0));
            obj_row.put('complete', nvl(v_sumcomplete,0));
            obj_row.put('error', nvl(v_sumerr,0));
            obj_row2   := json_object_t();
            for r1 in c_timpfiles loop
                v_rcnt          := v_rcnt+1;
                obj_data        := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('numseq', r1.numseq);
                obj_data.put('status', get_tlistval_name('STATEST',r1.status,global_v_lang));
                obj_data.put('remark', r1.remark);
                obj_data.put('datafile', r1.datafile);
                obj_row2.put(to_char(v_rcnt-1), obj_data);
            end loop;           
            obj_row.put('table', obj_row2);
            json_str_output := obj_row.to_clob;

        else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
    end;

    procedure process_import_auto (p_datatype in varchar2) is
        v_sumrec            number(30);
        v_sumerr            number(30);
        v_sumcomplete       number ;
        v_ext               tsetup.value%type;
        v_atmpathdr         tsetup.value%type;
        v_pathfrom          tsetup.value%type;
        v_titlefile         tsetup.value%type;
        v_dteupd            varchar2(100 char);
        v_file_exists       boolean;
        v_file              varchar2(100);
        v_error             varchar2(10);

        cursor c_files is
          select filename,coduser
            from tfilelist
           where codapp   = p_codapp
             and coduser  = p_coduser_auto
        order by filename;

    begin
        global_v_coduser := 'AUTO';
        global_v_lang    := '102';
        v_ext := '.txt';
        v_dteupd         := get_tsetup_value('PMZ2B_DTEUPD');
        v_atmpathdr      := 'UTL_FILE_DIR_PMZ2B';


        p_typedata      := p_datatype;
        v_titlefile     := get_tsetup_value('PMZ2BT'||p_datatype);
        v_pathfrom      := get_tsetup_value('PMZ2BT'||p_datatype||'F');
        p_coduser_auto  := 'AT_PMZ2BT'||p_datatype||'_'||to_char(sysdate,'hh24mi');
        get_dir_list_aws(get_tsetup_value('PMZ2B_S3_BUCKET'),v_pathfrom,v_atmpathdr,p_coduser_auto,p_codapp,v_dteupd);           
        p_path_file     := v_atmpathdr; 

        v_file_exists := false;
        for i_file in c_files loop
            if lower(i_file.filename) like lower(v_titlefile)||'%'||v_ext then
                v_file_exists   := true;
                v_file          := i_file.filename;   

                begin 
                    import_data_auto (p_typedata,v_file,v_error);
                    commit;
                exception when others then
                    v_error := 'ErrIm';
                    goto error_point;
                end;
                remove_file_wdc(v_file,p_path_file);
                <<error_point>>
                null;

            end if;
        end loop;
        delete tfilelist where codapp = p_codapp and coduser = p_coduser_auto; commit;

        begin
            update tsetup set value = to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')
             where codvalue = 'PMZ2B_DTEUPD';
        exception when others then
            null;
        end;        

    end;

    procedure import_data_auto (p_typedata  in varchar,p_namfile in varchar2,p_error out varchar2) is
        v_cnt_col		number := 0;
        in_file         utl_file.File_Type;
        out_file        utl_file.File_Type;
        linebuf         varchar2(32767 char);
        data_file       varchar2(32767 char);
        v_filename      varchar2(1000 char);
        v_sqlerrm       varchar2(1000 char);
        v_numseq        number := 0;
        v_staerror      varchar2(1 char); 
        v_dteimpt       date;
        v_error			boolean;
        v_rec_error     number := 0;
        v_rec_tran      number := 0;
        p_lang          varchar2(3 char) := '102'; 
        v_numcompl		number := 0;
        v_numermap		number := 0;
        v_typedata      varchar2(15 char); 

        invalid_file_name exception;
        pragma exception_init (invalid_file_name, -302000);

    begin

        if p_typedata = '10' then
            v_cnt_col := 121;
        elsif p_typedata = '20' then
            v_cnt_col := 5;
        elsif p_typedata = '30' then
            v_cnt_col := 11;
        elsif p_typedata = '40' then
            v_cnt_col := 12;
        elsif p_typedata = '50' then
            v_cnt_col := 24;
        elsif p_typedata = '60' then
            v_cnt_col := 7;
        elsif p_typedata = '70' then
            v_cnt_col := 30;
        elsif p_typedata = '80' then
            v_cnt_col := 7;
        end if;

        v_dteimpt     := to_date(to_char(sysdate,'dd/mm/yyyy hh24miss'),'dd/mm/yyyy hh24miss');
        p_dteimptwdc  := to_char(v_dteimpt,'dd/mm/yyyy hh24miss');

        if utl_file.is_open(in_file) then
            utl_file.fclose(in_file);
        end if;

        v_filename := p_namfile;
        begin
            in_file := utl_file.fopen(p_path_file,v_filename,'R',32767);
        exception when invalid_file_name then
            p_error  := '1';
            utl_file.fclose(in_file);   
        end;  

        <<main_loop>>
        loop
            utl_file.get_line(in_file,linebuf,32767);   ---,32767
            data_file := ltrim(rtrim(linebuf));  
            begin
                if data_file is not null then

                    v_numseq  := v_numseq + 1;  
                    <<cal_loop>>
                    loop
                        --==--header--==--
                        /*if v_numseq = 1 then
                            check_header(v_typedata,v_filename,data_file,v_cnt_col,p_delimeterat,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),v_numseq,p_lang,v_staerror);
                            if nvl(v_staerror,'N') = 'Y' then
                                p_error     := 'Y' ;
                                v_rec_error := v_rec_error + 1;
                                exit main_loop;
                            end if;	
                        else	*/ 
                            v_rec_tran := v_rec_tran + 1;
                            v_staerror := 'N';              
                            check_detail(v_typedata,v_filename,data_file,v_cnt_col,p_delimeterat,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),v_numseq,p_lang,v_staerror);
                            if nvl(v_staerror,'N') = 'Y' then
                                p_error     := 'Y' ;
                                v_rec_error := v_rec_error + 1;
                                exit cal_loop;
                            end if;	

                            v_staerror := 'N';
                            if p_typedata = '10' then                           
                                import_employee_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));                               
                            elsif p_typedata = '20' then                              
                                import_children_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));                               
                            elsif p_typedata = '30' then
                                import_education_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            elsif p_typedata = '40' then
                                import_workexp_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            elsif p_typedata = '50' then
                                import_movement_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            elsif p_typedata = '60' then
                                import_termination_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            elsif p_typedata = '70' then
                                import_rehire_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            elsif p_typedata = '80' then
                                import_othincome_data(p_filename,data_file,v_zyear,to_char(v_dteimpt,'dd/mm/yyyy hh24miss'),global_v_lang,v_staerror,v_numseq,nvl(global_v_coduser,'AUTO'));
                            end if; 

                            if v_staerror = 'Y' then
                                p_error     := 'Y' ;
                                v_rec_error := v_rec_error + 1;
                                exit cal_loop;
                            end if;   

                        --end if;

                    exit cal_loop;
                    end loop;
                end if;
            exception when others then
                p_error  := '2' ;
            end;
        end loop;

    exception	when no_data_found then
        utl_file.fclose(in_file);	
    when others then
        utl_file.fclose(in_file);	
    end;

    procedure get_mapping_code (p_typcode in varchar2,
                                p_sapcode in varchar2,
                                p_data    in out varchar2,
                                p_error   in out boolean) is

        v_data		    varchar2(1) := 'N';
        v_error         boolean;
        v_hcmcode       tmapcode.hcmcode%type;

        cursor c1 is
            select hcmcode
              from tmapcode a,ttypecode b
             where a.typcode = b.typcode
               and a.sapcode = p_sapcode
               and b.typcode = p_typcode
               and a.sapcode is not null;
    begin
        v_error   := true;
        v_hcmcode := null;
        for i in c1 loop
            if i.hcmcode is not null then
                v_data := 'Y';
                v_hcmcode := i.hcmcode;
                exit;
            end if;
        end loop;
        if v_data = 'Y' then
            v_error := false;
        end if;
        p_error := v_error;
        p_data  := v_hcmcode;
    end;

    procedure insert_tmapcode (p_namfild in varchar2,
                               p_sapcode in varchar2) is

        v_typcode			varchar2(2);
        v_count				number;

    begin
      --tmapcode
        begin
            select typcode into v_typcode
              from ttypecode
             where columnname = p_namfild
               and rownum     = 1;
        exception when no_data_found then
            v_typcode := null;
        end;
        if v_typcode is not null then
            begin
                select count(*) into v_count
                  from tmapcode
                 where typcode  = v_typcode
                   and sapcode  = p_sapcode;
            exception when no_data_found then
                v_count := 0;
            end;
            if v_count = 0 then
                insert into tmapcode (typcode,sapcode,coduser)
                       values        (v_typcode,p_sapcode,global_v_coduser);
            end if;
        end if;
    end;

    procedure get_default_data (p_typdata in varchar2,
                                p_namtbl  in varchar2,
                                p_namfild in varchar2,
                                p_data    in out varchar2) is

        cursor c1 is
          select datavalue 
            from tinitdef
           where typedata = p_typdata
             and namtbl   = p_namtbl
             and namfild  = p_namfild;

    begin
      for i in c1 loop
        p_data := i.datavalue;
        exit;
      end loop;
    end;

    procedure import_employee_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) is


        v_codempid      temploy1.codempid%type;
        v_chknumoffid   temploy1.codempid%type;
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 121;
        v_exist		  	boolean;	
        v_flgpass		boolean;
        v_numerr        number := 0;
        v_count         number := 0;
        v_temploy1      temploy1%rowtype;
        v_temploy2      temploy2%rowtype;
        v_temploy3      temploy3%rowtype;
        v_tfamily       tfamily%rowtype;
        v_tspouse       tspouse%rowtype;
        v_tcontpms      tcontpms%rowtype;
        v_numseq        number := 0;
        v_numoffid      temploy2.numoffid%type;
        v_codtitlett    temploy1.codtitle%type;
        v_codtitlete    temploy1.codtitle%type;
        v_flgchg        varchar2(1 char) := 'N';
        v_namefile      varchar2(200 char) := p_namefile;
        v_dteimpt       varchar2(200 char) := p_dteimpt;
        v_chk           varchar2(1 char) := 'N';
        v_tenum         varchar2(400);
        v_codcom2       tcenter.codcom2%type;
        v_fildname      varchar2(15);

        v_amtothr       number;
        v_amtday        number;
        v_sumincom      number;

        v_temploy1_initial      temploy1%rowtype;
        v_temploy3_initial      temploy3%rowtype;

        type descol is table of varchar2(4000 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_temploy1 is
            select a.*,a.rowid
              from temploy1 a
             where a.codempid = v_temploy1_initial.codempid;

        cursor c_temploy2 is
            select a.*,a.rowid
              from temploy2 a
             where a.codempid = v_temploy1_initial.codempid;

        cursor c_temploy3 is
            select a.*,a.rowid
              from temploy3 a
             where a.codempid = v_temploy1_initial.codempid;

        cursor c_tfamily is
            select a.*,a.rowid
              from tfamily a
             where a.codempid = v_temploy1_initial.codempid;

        cursor c_tspouse is
            select a.*,a.rowid
              from tspouse a
             where a.codempid = v_temploy1_initial.codempid;             

    begin
        for i in 1..v_max loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;			
            v_temploy1  := null;	
            v_temploy2  := null;	
            v_temploy3  := null;	
            v_tcontpms  := null;
            v_temploy1_initial  := null;
            v_temploy3_initial  := null;
            v_numerr    := 0;

            v_codempid  := upper(substr(v_text(1),1,10));
            v_temploy1.codempid := v_codempid;
            v_temploy2.codempid := v_codempid;
            v_temploy3.codempid := v_codempid;

            v_count            := 0;
            v_temploy1_initial := null; 
            begin
                  select * into v_temploy1_initial
                  from  temploy1
                  where codempid = v_codempid
                  and   dteempmt = (select max(dteempmt)
                                      from temploy1
                                     where codempid = v_codempid )
                  and rownum  = 1;
            exception when no_data_found then           
                v_temploy1_initial := null; 
            end;

            if v_temploy1_initial.codempid is not null then
               v_count := 1;
               v_codempid := v_temploy1_initial.codempid ;
            end if;

            v_temploy1.codempid := v_codempid;
            v_temploy2.codempid := v_codempid;

            for i in 1..v_max loop
                -- check required field -----------------------------------------------
                ---(4,8,9,10,11,12,13,14,15,16,22,23,38) then --2,3,5,6,7 -- Old 
                if v_count = 0 then
                    if i in (4,8,9,10,11,12,13,14,15,16,22,23,38) then 
                        if v_text(i) is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('HR2045',p_lang);
                        end if;					
                    end if;	
                end if;
                -- check Lenght field -------------------------------------------------    
				if i in (4,5,6,7) and v_text(i) is not null then
					if length(v_text(i)) > 30 then
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (30)';
					end if;	
				end if;

                if i = 28 then
                    if length(v_text(i)) > 25 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (25)';
                    end if;	                
                end if; 

                if i = 29 then
                    if length(v_text(i)) > 50 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (50)';
                    end if;	                
                end if; 

                if i in (39,48,53,55,117) then
                    if length(v_text(i)) > 20 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (20)';
                    end if;	                
                end if;  

                if i in (42,97,101,105,112,120,121) then
                    if length(v_text(i)) > 100 then 
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (100)';
                    end if;	                
                end if;

                if i in (49,74,75,114) then
                    if length(v_text(i)) > 13 then 
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (13)';
                    end if;	                
                end if; 

                if i in (49,62) then
                    if length(v_text(i)) > 15 then 
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (15)';
                    end if;	                
                end if; 

                -- check format field -------------------------------------------------
                if i in (9,12,22,23,24,25,26,41,50,54,56,57,81,92,113,116) and v_text(i) is not null then
                    v_error := check_date(v_text(i),p_typyear);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang);
                    end if;
                end if;             

                if i in (27,43,46,51,52,60,64,65,66,67,68,69,70,71,72,73,78,79,80,82,83,84,85,86,87,88,89,90,91,93,94,95,96) and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else

                        if i = 60 then
                            v_tenum := null;
                            v_tenum := to_char(to_number(v_text(i)),'fm000.00');
                            if length(v_tenum) > 6 then
                                v_error   := true;
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (6)';
                            end if;
                        end if;

                        if i in (87,88) then
                            v_tenum := null;
                            v_tenum := to_char(to_number(v_text(i)),'fm00');
                            if length(v_tenum) > 2 then
                                v_error   := true;
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (2)';
                            end if;
                        end if;

                        if i in (64,65,66,67,68,69,70,71,72,73,78,79,80,82,83,84,85,86,89,90,91,93,94,95,96) and v_text(i) is not null then
                            v_tenum := null;
                            v_tenum := to_char(to_number(v_text(i)),'fm0000000.00');
                            if length(v_tenum) > 10 then
                                v_error   := true;
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
                            end if;
                        end if;
                    end if; 
                end if;                

                --- check maping code
                if i in (2,3,8,10,11,13,14,15,16,17,18,19,20,27,30,31,32,33,34,35,36,37,40,44,47,58,61,63,98,99,100,102,103,104,115,118,119)  then
                    v_error := false;
                    if i = 2 and v_text(i) is not null then
                        get_mapping_code('A1',v_text(i),v_codtitlete,v_error);
                        v_fildname := 'CODTITLE';
                    elsif i = 3 and v_text(i) is not null then
                        get_mapping_code('A0',v_text(i),v_codtitlett,v_error);
                        v_fildname := 'CODTITLE';
                    elsif i = 8  and v_text(i) is not null then
                        get_mapping_code('A3',v_text(i),v_temploy1.codsex,v_error);   
                        v_fildname := 'CODSEX';
                    elsif i = 10 and v_text(i) is not null then
                        get_mapping_code('A2',v_text(i),v_temploy1.stamarry,v_error);
                        v_fildname := 'STAMARRY';
                    elsif i = 11 and v_text(i) is not null then
                        get_mapping_code('A5',v_text(i),v_temploy1.staemp,v_error);
                        v_fildname := 'STAEMP';
                    elsif i = 13 and v_text(i) is not null then
                        get_mapping_code('E1',v_text(i),v_temploy1.codcomp,v_error);
                        v_fildname := 'CODCOMP';
                    elsif i = 14 and v_text(i) is not null then
                        get_mapping_code('E2',v_text(i),v_temploy1.codpos,v_error);
                        v_fildname := 'CODPOS'; 
                        begin
                            select joblvlst into v_temploy1.numlvl
                              from tjobpos
                             where codpos  = v_temploy1.codpos
                               and codcomp = v_temploy1.codcomp;
                        exception when no_data_found then
                            v_temploy1.numlvl := 0;
                        end ;
                    elsif i = 15 and v_text(i) is not null then
                        get_mapping_code('LO',v_text(i),v_temploy1.codbrlc,v_error);
                        v_fildname := 'CODBRLC';                                                  
                    elsif i = 16 and v_text(i) is not null then
                        get_mapping_code('TE',v_text(i),v_temploy1.codempmt,v_error);
                        v_fildname := 'CODEMPMT';                          
                    elsif i = 17 and v_text(i) is not null then
                        get_mapping_code('PY',v_text(i),v_temploy1.typpayroll,v_error);
                        v_fildname := 'TYPPAYROLL';
                    elsif i = 18 and v_text(i) is not null then
                        get_mapping_code('CG',v_text(i),v_temploy1.typemp,v_error);                        
                        v_fildname := 'TYPEMP';
                    elsif i = 19 and v_text(i) is not null then
                        get_mapping_code('GR',v_text(i),v_temploy1.codcalen,v_error);                        
                        v_fildname := 'CODCALEN';
                    elsif i = 20 and v_text(i) is not null then
                        get_mapping_code('E3',v_text(i),v_temploy1.codjob,v_error);                        
                        v_fildname := 'CODJOB';
                    elsif i = 27 and v_text(i) is not null then
                        get_mapping_code('E4',v_text(i),v_temploy1.flgatten,v_error);                        
                        v_fildname := 'FLGATTEN';
                    elsif i = 30 and v_text(i) is not null then
                        get_mapping_code('E1',v_text(i),v_temploy1.codcompr,v_error);
                        v_fildname := 'CODCOMP';
                    elsif i = 31 and v_text(i) is not null then
                        get_mapping_code('E2',v_text(i),v_temploy1.codposre,v_error);
                        v_fildname := 'CODPOS'; 
                    elsif i = 32 and v_text(i) is not null then
                        get_mapping_code('OR',v_text(i),v_temploy2.codorgin,v_error);
                        v_fildname := 'CODORGIN'; 
                    elsif i = 33 and v_text(i) is not null then
                        get_mapping_code('NT',v_text(i),v_temploy2.codnatnl,v_error);
                        v_fildname := 'CODNATNL'; 
                    elsif i = 34 and v_text(i) is not null then
                        get_mapping_code('RL',v_text(i),v_temploy2.codrelgn,v_error);
                        v_fildname := 'CODRELGN'; 
                    elsif i = 35 and v_text(i) is not null then
                        get_mapping_code('E6',v_text(i),v_temploy2.codblood,v_error);
                        v_fildname := 'CODBLOOD'; 
                    elsif i = 36 and v_text(i) is not null then
                        get_mapping_code('E7',v_text(i),v_temploy1.stamilit,v_error);
                        v_fildname := 'STAMILIT'; 
                    elsif i = 37 and v_text(i) is not null then
                        get_mapping_code('PV',v_text(i),v_temploy2.coddomcl,v_error);
                        v_fildname := 'CODPROVR';                  
                    elsif i = 40 and v_text(i) is not null then
                        get_mapping_code('PV',v_text(i),v_temploy2.codprovi,v_error);
                        v_fildname := 'CODPROVR';                        
                    elsif i = 44 and v_text(i) is not null then
                        get_mapping_code('CT',v_text(i),v_temploy2.codcntyr,v_error);
                        v_fildname := 'CODCNTYR';   
                    elsif i = 47 and v_text(i) is not null then
                        get_mapping_code('CT',v_text(i),v_temploy2.codcntyc,v_error);
                        v_fildname := 'CODCNTYR';   
                    elsif i = 58 and v_text(i) is not null then
                        get_mapping_code('BK',v_text(i),v_temploy3.codbank,v_error);
                        v_fildname := 'CODBANK';  
                    elsif i = 61 and v_text(i) is not null then
                        get_mapping_code('BK',v_text(i),v_temploy3.codbank2,v_error);
                        v_fildname := 'CODBANK';                          
                    elsif i = 63 and v_text(i) is not null then
                        get_mapping_code('CR',v_text(i),v_temploy3.codcurr,v_error);
                        v_fildname := 'CODCURR';                  
                    elsif i = 98 and v_text(i) is not null then
                        get_mapping_code('NT',v_text(i),v_tfamily.codfnatn,v_error);
                        v_fildname := 'CODNATNL';  
                    elsif i = 99 and v_text(i) is not null then
                        get_mapping_code('RL',v_text(i),v_tfamily.codfrelg,v_error);
                        v_fildname := 'CODRELGN';  
                    elsif i = 100 and v_text(i) is not null then
                        get_mapping_code('OC',v_text(i),v_tfamily.codfoccu,v_error);
                        v_fildname := 'CODFOCCU';  
                    elsif i = 102 and v_text(i) is not null then
                        get_mapping_code('NT',v_text(i),v_tfamily.codmnatn,v_error);
                        v_fildname := 'CODNATNL';  
                    elsif i = 103 and v_text(i) is not null then
                        get_mapping_code('RL',v_text(i),v_tfamily.codmrelg,v_error);
                        v_fildname := 'CODRELGN';  
                    elsif i = 104 and v_text(i) is not null then
                        get_mapping_code('OC',v_text(i),v_tfamily.codmoccu,v_error);
                        v_fildname := 'CODFOCCU';  
                    elsif i = 115 and v_text(i) is not null then
                        get_mapping_code('OC',v_text(i),v_tspouse.codspocc,v_error);
                        v_fildname := 'CODFOCCU'; 
                    elsif i = 118 and v_text(i) is not null then
                        get_mapping_code('PV',v_text(i),v_tspouse.codsppro,v_error);
                        v_fildname := 'CODPROVR';  
                    elsif i = 119 and v_text(i) is not null then
                        get_mapping_code('CT',v_text(i),v_tspouse.codspcty,v_error);
                        v_fildname := 'CODCNTYR'; 
                    end if;

                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                        v_namfild(v_numerr)     := v_fildname;
                        v_sapcode(v_numerr)     := v_text(i);	
                    end if;

                    if i = 17 and v_temploy1.typpayroll is null then
                        if v_temploy1.codempmt is not null then
                            get_mapping_code('PY',substr(v_temploy1.codempmt,1,1),v_temploy1.typpayroll,v_error);
                            v_fildname := 'TYPPAYROLL';
                            if v_error then	
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                                v_namfild(v_numerr)     := v_fildname;
                                v_sapcode(v_numerr)     := substr(v_temploy1.codempmt,1,1);	
                            end if;
                        else
                            begin
                                select typpayroll into v_temploy1.typpayroll
                                  from temploy1 
                                 where codempid = v_temploy1.codempid;
                            exception when no_data_found then
                                v_temploy1.typpayroll := null;
                            end;
                            if v_temploy1.typpayroll is null then
                                get_default_data(p_typedata,'TEMPLOY1','TYPPAYROLL',v_temploy1.typpayroll);
                                if v_temploy1.typpayroll is null then
                                    v_numerr  := v_numerr + 1;
                                    v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                                end if;
                            end if;
                        end if;
                    end if;

                    if i = 18 and v_temploy1.typemp is null then
                        if v_temploy1.codempmt is not null then
                            get_mapping_code('CG',substr(v_temploy1.codempmt,1,1),v_temploy1.typemp,v_error);                        
                            v_fildname := 'TYPEMP';
                            if v_error then	
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                                v_namfild(v_numerr)     := v_fildname;
                                v_sapcode(v_numerr)     := substr(v_temploy1.codempmt,1,1);	
                            end if;
                        else
                            begin
                                select typemp into v_temploy1.typemp
                                  from temploy1 
                                 where codempid = v_temploy1.codempid;
                            exception when no_data_found then
                                v_temploy1.typemp := null;
                            end;
                            if v_temploy1.typemp is null then
                                get_default_data(p_typedata,'TEMPLOY1','TYPEMP',v_temploy1.typemp);
                                if v_temploy1.typemp is null then
                                    v_numerr  := v_numerr + 1;
                                    v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                                end if;
                            end if;
                        end if;
                    end if;

                    if i = 19 and v_temploy1.codcalen is null then
                        begin
                            select codcalen into v_temploy1.codcalen
                              from temploy1 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy1.codcalen := null;
                        end;
                        if v_temploy1.codcalen is null then
                            get_default_data(p_typedata,'TEMPLOY1','CODCALEN',v_temploy1.codcalen);
                            if v_temploy1.codcalen is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;

                    if i = 20 and v_temploy1.codjob is null then
                        begin
                            select codjob into v_temploy1.codjob
                              from temploy1 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy1.codjob := null;
                        end;
                        if v_temploy1.codjob is null then
                            get_default_data(p_typedata,'TEMPLOY1','CODJOB',v_temploy1.codjob);
                            if v_temploy1.codjob is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;

                    if i = 21 and v_temploy1.flgatten is null then
                        begin
                            select flgatten into v_temploy1.flgatten
                              from temploy1 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy1.flgatten := null;
                        end;
                        if v_temploy1.numlvl < 60 then
                            v_temploy1.flgatten := 'Y';
                        else
                            v_temploy1.flgatten := 'N';
                        end if;
                        if v_temploy1.flgatten is null then
                            get_default_data(p_typedata,'TEMPLOY1','CODJOB',v_temploy1.flgatten);
                            if v_temploy1.flgatten is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;

                    if i = 36 and v_temploy1.stamilit is null then
                        begin
                            select stamilit into v_temploy1.stamilit
                              from temploy1 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy1.stamilit := null;
                        end;
                        if v_temploy1.stamilit is null then
                            get_default_data(p_typedata,'TEMPLOY1','STAMILIT',v_temploy1.stamilit);
                            if v_temploy1.stamilit is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;
                end if;

                if i = 42  then
                    v_temploy2.adrregt := v_text(i);
                    if v_temploy2.adrregt is null then

                        begin
                            select adrregt into v_temploy2.adrregt
                              from temploy2 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy2.adrregt := null;
                        end;
                        if v_temploy2.adrregt is null then
                            get_default_data(p_typedata,'TEMPLOY2','ADRREGT',v_temploy2.adrregt);
                            if v_temploy2.adrregt is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;
                end if;                

                if i = 45  then
                    v_temploy2.adrcontt := v_text(i);
                    if v_temploy2.adrcontt is null then

                        begin
                            select adrcontt into v_temploy2.adrcontt
                              from temploy2 
                             where codempid = v_temploy1.codempid;
                        exception when no_data_found then
                            v_temploy2.adrcontt := null;
                        end;
                        if v_temploy2.adrcontt is null then
                            get_default_data(p_typedata,'TEMPLOY2','ADRCONTT',v_temploy2.adrcontt);
                            if v_temploy2.adrcontt is null then
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                            end if;
                        end if;
                    end if;
                end if; 


                if i = 38 and v_text(i) is not null then
                    if length(v_text(i)) <> 13 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ015',p_lang);
                    end if;

                    v_temploy2.numoffid := substr(replace(v_text(i),' ',''),1,13);
                    v_chknumoffid := null;
                    begin
                        select a.codempid into v_chknumoffid
                          from temploy2 a, temploy1 b
                         where a.numoffid = v_temploy2.numoffid
                           and a.codempid = b.codempid
                           and b.staemp   = '9'
                           and rownum     = 1;
                    exception when no_data_found then
                        v_chknumoffid := null;
                    end;
                    if v_chknumoffid is null then
                        begin
                            select numoffid into v_numoffid
                              from temploy2
                             where codempid <> v_codempid
                               and numoffid = v_temploy2.numoffid
                               and rownum   = 1;
                        exception when no_data_found then
                            v_numoffid := null;
                        end;
                        if v_numoffid is not null then
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PM0015',p_lang)||' (TEMPLOY2)';						
                        end if;
                    end if;                       

                end if; 
            end loop;---for i in 1..v_max loop 

        exit cal_loop;
        end loop;


        if v_numerr = 0 then

            if v_text(9) is not null then
                v_temploy1.dteempdb := check_dteyre(v_text(9),p_typyear);
            end if;  

            if v_text(12) is not null then
                v_temploy1.dteempmt := check_dteyre(v_text(12),p_typyear);
            end if;      

            if v_text(22) is not null then
                v_temploy1.dteefpos := check_dteyre(v_text(22),p_typyear);
            end if;

            if v_text(23) is not null then
                v_temploy1.dteeflvl := check_dteyre(v_text(23),p_typyear);
            end if; 

            if v_text(24) is not null then
                v_temploy1.dteeffex := check_dteyre(v_text(24),p_typyear);
            end if; 

            if v_text(25) is not null then
                v_temploy1.dteduepr := check_dteyre(v_text(25),p_typyear);
            end if; 

            if v_text(26) is not null then
                v_temploy1.dteoccup := check_dteyre(v_text(26),p_typyear);
            end if; 

            if v_text(41) is not null then
                v_temploy2.dteoffid := check_dteyre(v_text(41),p_typyear);
            end if;             

            if v_text(50) is not null then
                v_temploy2.dtelicid := check_dteyre(v_text(50),p_typyear);
            end if;             

            if v_text(54) is not null then
                v_temploy2.dtepasid := check_dteyre(v_text(54),p_typyear);
            end if;   

            if v_text(56) is not null then
                v_temploy2.dteprmst := check_dteyre(v_text(56),p_typyear);
            end if;   

            if v_text(57) is not null then
                v_temploy2.dteprmen := check_dteyre(v_text(57),p_typyear);
            end if;       

            if v_text(81) is not null then
                v_temploy3.dtebf := check_dteyre(v_text(81),p_typyear);
            end if;   

            if v_text(92) is not null then
                v_temploy3.dtebfsp := check_dteyre(v_text(92),p_typyear);
            end if;  

            if v_text(113) is not null then
                v_tspouse.dtespbd := check_dteyre(v_text(113),p_typyear);
            end if;    

            if v_text(116) is not null then
                v_tspouse.dtemarry := check_dteyre(v_text(116),p_typyear);
            end if;   

            -- Replace Title name
            v_temploy1.namfirste := v_text(4);
            v_temploy1.namlaste  := v_text(6);
            v_temploy1.namfirstt := v_text(5);
            v_temploy1.namlastt  := v_text(7);
            if v_codtitlett is not null or v_codtitlete is not null then
                if global_v_lang = '102' then
                    v_temploy1.codtitle := v_codtitlett;
                else
                    v_temploy1.codtitle := v_codtitlete;
                end if; 
            end if;
            v_temploy1.namempe   := get_tlistval_name('CODTITLE',nvl(v_temploy1.codtitle,v_temploy1_initial.codtitle),'101')||v_temploy1.namfirste||' '||v_temploy1.namlaste;
            v_temploy1.namempt   := get_tlistval_name('CODTITLE',nvl(v_temploy1.codtitle,v_temploy1_initial.codtitle),'102')||v_temploy1.namfirstt||' '||v_temploy1.namlastt;  

            begin
                select codincom1,codincom2,codincom3,codincom4,codincom5,
                       codincom6,codincom7,codincom8,codincom9,codincom10
                  into v_tcontpms.codincom1,v_tcontpms.codincom2,v_tcontpms.codincom3,v_tcontpms.codincom4,v_tcontpms.codincom5,
                       v_tcontpms.codincom6,v_tcontpms.codincom7,v_tcontpms.codincom8,v_tcontpms.codincom9,v_tcontpms.codincom10
                  from tcontpms 
                 where codcompy  = hcm_util.get_codcompy(v_temploy1.codcomp)
                   and  dteeffec = (select max(dteeffec) 
                                      from tcontpms 
                                     where codcompy  = hcm_util.get_codcompy(v_temploy1.codcomp) 
                                       and dteeffec <= trunc(sysdate)  );
            exception when no_data_found then
                null;                         
            end;

            if v_text(64) > 0  and v_tcontpms.codincom1 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 64||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(65) > 0  and v_tcontpms.codincom2 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 35||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(66) > 0  and v_tcontpms.codincom3 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 66||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(67) > 0  and v_tcontpms.codincom4 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 67||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(68) > 0  and v_tcontpms.codincom5 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 68||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(69) > 0  and v_tcontpms.codincom6 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 69||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(70) > 0  and v_tcontpms.codincom7 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 70||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(71) > 0  and v_tcontpms.codincom8 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 71||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(72) > 0  and v_tcontpms.codincom9 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 72||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            if v_text(73) > 0  and v_tcontpms.codincom10 is null then
                v_error   := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)  := 73||' - '||get_errorm_name('HR2055',p_lang)||' (TCONTPMS)';	                
            end if;

            v_temploy3_initial.amtincom1 := null; v_temploy3_initial.amtincom2 := null; v_temploy3_initial.amtincom3 := null; v_temploy3_initial.amtincom4 := null; v_temploy3_initial.amtincom5 := null;
            v_temploy3_initial.amtincom6 := null; v_temploy3_initial.amtincom7 := null; v_temploy3_initial.amtincom8 := null; v_temploy3_initial.amtincom9 := null; v_temploy3_initial.amtincom10 := null;
            if v_temploy1_initial.codempid is not null and v_temploy1_initial.staemp <> '0' then
                begin
                    select to_char(stddec(amtincom1,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom2,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom3,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom4,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom5,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom6,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom7,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom8,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom9,v_temploy1.codempid,v_chken),'fm9999999999990.00') ,
                           to_char(stddec(amtincom10,v_temploy1.codempid,v_chken),'fm9999999999990.00')
                      into v_temploy3_initial.amtincom1,v_temploy3_initial.amtincom2,
                           v_temploy3_initial.amtincom3,v_temploy3_initial.amtincom4,
                           v_temploy3_initial.amtincom5,v_temploy3_initial.amtincom6,
                           v_temploy3_initial.amtincom7,v_temploy3_initial.amtincom8,
                           v_temploy3_initial.amtincom9,v_temploy3_initial.amtincom10
                      from temploy3
                     where codempid = v_codempid;
                exception when no_data_found then
                     null;
                end;

                if  v_temploy1.staemp is not null and nvl(v_temploy1.staemp,'!@#') 	 <> nvl(upper(v_temploy1_initial.staemp),nvl(v_temploy1.staemp,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 11||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.dteempmt is not null and nvl(to_char(v_temploy1.dteempmt,'dd/mm/yyyy'),trunc(sysdate)) <> nvl(to_char(v_temploy1_initial.dteempmt,'dd/mm/yyyy'),nvl(to_char(v_temploy1.dteempmt,'dd/mm/yyyy'),trunc(sysdate)))  then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 12||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.codcomp is not null and nvl(v_temploy1.codcomp,'!@#') 	 <> nvl(upper(v_temploy1_initial.codcomp),nvl(v_temploy1.codcomp,'!@#'))  then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 13||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;                

                if  v_temploy1.codpos is not null and nvl(v_temploy1.codpos,'!@#') 	 <> nvl(upper(v_temploy1_initial.codpos),nvl(v_temploy1.codpos,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 14||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.codbrlc is not null and nvl(v_temploy1.codbrlc,'!@#') 	 <> nvl(upper(v_temploy1_initial.codbrlc),nvl(v_temploy1.codbrlc,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 15||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.codempmt is not null and nvl(v_temploy1.codempmt,'!@#') 	 <> nvl(upper(v_temploy1_initial.codempmt),nvl(v_temploy1.codempmt,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 16||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.typpayroll is not null and nvl(v_temploy1.typpayroll,'!@#') 	 <> nvl(upper(v_temploy1_initial.typpayroll),nvl(v_temploy1.typpayroll,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 17||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.typemp is not null and nvl(v_temploy1.typemp,'!@#') 	 <> nvl(upper(v_temploy1_initial.typemp),nvl(v_temploy1.typemp,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 18||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.codcalen is not null and nvl(v_temploy1.codcalen,'!@#') 	 <> nvl(upper(v_temploy1_initial.codcalen),nvl(v_temploy1.codcalen,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 19||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.codjob is not null and nvl(v_temploy1.codjob,'!@#') 	 <> nvl(upper(v_temploy1_initial.codjob),nvl(v_temploy1.codjob,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 20||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                if  v_temploy1.flgatten is not null and nvl(v_temploy1.flgatten,'!@#') 	 <> nvl(upper(v_temploy1_initial.flgatten),nvl(v_temploy1.flgatten,'!@#'))   then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 21||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

                v_temploy3.amtincom1  := v_text(64);
                v_temploy3.amtincom2  := v_text(65);
                v_temploy3.amtincom3  := v_text(66);
                v_temploy3.amtincom4  := v_text(67);
                v_temploy3.amtincom5  := v_text(68);
                v_temploy3.amtincom6  := v_text(69);
                v_temploy3.amtincom7  := v_text(70);
                v_temploy3.amtincom8  := v_text(71);
                v_temploy3.amtincom9  := v_text(72);
                v_temploy3.amtincom10 := v_text(73);

                if v_temploy3.amtincom1 is not null and nvl(v_temploy3.amtincom1,0)  <> nvl(v_temploy3_initial.amtincom1,nvl(v_temploy3.amtincom1,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 64||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom2 is not null and nvl(v_temploy3.amtincom2,0)  <> nvl(v_temploy3_initial.amtincom2,nvl(v_temploy3.amtincom2,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 65||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom3 is not null and nvl(v_temploy3.amtincom3,0)  <> nvl(v_temploy3_initial.amtincom3,nvl(v_temploy3.amtincom3,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 66||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom4 is not null and nvl(v_temploy3.amtincom4,0)  <> nvl(v_temploy3_initial.amtincom4,nvl(v_temploy3.amtincom4,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 67||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom5 is not null and nvl(v_temploy3.amtincom5,0)  <> nvl(v_temploy3_initial.amtincom5,nvl(v_temploy3.amtincom5,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 68||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom6 is not null and nvl(v_temploy3.amtincom6,0)  <> nvl(v_temploy3_initial.amtincom6,nvl(v_temploy3.amtincom6,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 69||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom7 is not null and nvl(v_temploy3.amtincom7,0)  <> nvl(v_temploy3_initial.amtincom7,nvl(v_temploy3.amtincom7,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 70||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom8 is not null and nvl(v_temploy3.amtincom8,0)  <> nvl(v_temploy3_initial.amtincom8,nvl(v_temploy3.amtincom8,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 71||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom9 is not null and nvl(v_temploy3.amtincom9,0)  <> nvl(v_temploy3_initial.amtincom9,nvl(v_temploy3.amtincom9,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 72||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;
                if v_temploy3.amtincom10 is not null and nvl(v_temploy3.amtincom10,0)  <> nvl(v_temploy3_initial.amtincom10,nvl(v_temploy3.amtincom10,0) ) then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 73||' - '||get_errorm_name('PMZ008',global_v_lang);
                end if;

            end if;

        end if;

        -- insert for data error
        if v_numerr > 0 then
           p_error   := 'Y';
           for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;  
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_temploy1.codempid,v_temploy1.codcomp,null,null,null,null,null,null,null,'N',v_remark);           

        else
            v_remark   := null;  

            --temploy1
            v_temploy1.namfirst3 := v_temploy1.namfirste;
            v_temploy1.namfirst4 := v_temploy1.namfirste;
            v_temploy1.namfirst5 := v_temploy1.namfirste;
            v_temploy1.namlast3  := v_temploy1.namlaste;
            v_temploy1.namlast4  := v_temploy1.namlaste;
            v_temploy1.namlast5  := v_temploy1.namlaste;
            v_temploy1.namemp3   := v_temploy1.namempe;
            v_temploy1.namemp4   := v_temploy1.namempe;
            v_temploy1.namemp5   := v_temploy1.namempe;               

            if v_temploy1_initial.codempid is null then
                if v_temploy1.dteeflvl is null then
                    v_temploy1.dteeflvl  := v_temploy1.dteempmt;
                end if;

                if v_temploy1.dteefpos is null then
                    v_temploy1.dteefpos  := v_temploy1.dteempmt;
                end if;

                if v_temploy1.dteoccup is null then
                    v_temploy1.dteoccup  := v_temploy1.dteempmt;
                end if;
            end if;

            v_temploy1.qtydatrq     := v_text(27) ;
            v_temploy1.numtelof     := v_text(28) ;
            v_temploy1.email        := v_text(29) ;

            ---Defult data---
            v_temploy1.maillang  := 'TH'; 
            v_temploy1.numappl   := v_temploy1.codempid;
            v_temploy1.dteefstep := v_temploy1.dteempmt; 
            v_temploy1.flgatten  := 'Y';
            v_temploy1.stadisb   := 'N';

            if v_temploy1.dteempmt is not null then
                v_temploy1.dteduepr  := v_temploy1.dteempmt + 118;         
            end if;

            v_temploy1.jobgrade := 'NA';

            v_exist   := false;
            for r_temploy1 in c_temploy1 loop
                v_exist   := true;

                upd_log1(r_temploy1.codempid,'temploy1','11','codtitle','C',r_temploy1.codtitle,v_temploy1.codtitle,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namfirste','C',r_temploy1.namfirste,v_temploy1.namfirste,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namfirstt','C',r_temploy1.namfirstt,v_temploy1.namfirstt,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namfirst3','C',r_temploy1.namfirst3,v_temploy1.namfirst3,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namfirst4','C',r_temploy1.namfirst4,v_temploy1.namfirst4,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namfirst5','C',r_temploy1.namfirst5,v_temploy1.namfirst5,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namlaste','C',r_temploy1.namlaste,v_temploy1.namlaste,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namlastt','C',r_temploy1.namlastt,v_temploy1.namlastt,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namlast3','C',r_temploy1.namlast3,v_temploy1.namlast3,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namlast4','C',r_temploy1.namlast4,v_temploy1.namlast4,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','namlast5','C',r_temploy1.namlast5,v_temploy1.namlast5,'N',v_temploy1_initial.codcomp,p_coduser);                
                upd_log1(r_temploy1.codempid,'temploy1','11','dteempdb','D',to_char(r_temploy1.dteempdb,'dd/mm/yyyy'),to_char(v_temploy1_initial.dteempdb,'dd/mm/yyyy'),'N',v_temploy1.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','codsex','C',r_temploy1.codsex,v_temploy1.codsex,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','11','stamarry','C',r_temploy1.stamarry,v_temploy1.stamarry,'N',v_temploy1_initial.codcomp,p_coduser);    
                upd_log1(r_temploy1.codempid,'temploy1','13','dteeflvl','D',to_char(r_temploy1.dteeflvl,'dd/mm/yyyy'),to_char(v_temploy1_initial.dteeflvl,'dd/mm/yyyy'),'N',v_temploy1.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','13','dteefpos','D',to_char(r_temploy1.dteefpos,'dd/mm/yyyy'),to_char(v_temploy1_initial.dteefpos,'dd/mm/yyyy'),'N',v_temploy1.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','13','dteoccup','D',to_char(r_temploy1.dteoccup,'dd/mm/yyyy'),to_char(v_temploy1_initial.dteoccup,'dd/mm/yyyy'),'N',v_temploy1.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','13','numtelof','C',r_temploy1.numtelof,v_temploy1.numtelof,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy1.codempid,'temploy1','13','email','C',r_temploy1.email,v_temploy1.email,'N',v_temploy1_initial.codcomp,p_coduser);

                update temploy1 set	codtitle 	= nvl(v_temploy1.codtitle,codtitle),
                                    namfirste	= nvl(v_temploy1.namfirste,namfirste),
                                    namfirstt	= nvl(v_temploy1.namfirstt,namfirstt),
                                    namfirst3	= nvl(v_temploy1.namfirste,namfirste),
                                    namfirst4	= nvl(v_temploy1.namfirste,namfirste),
                                    namfirst5	= nvl(v_temploy1.namfirste,namfirste),
                                    namlaste    = nvl(v_temploy1.namlaste,namlaste),
                                    namlastt	= nvl(v_temploy1.namlastt,namlastt),
                                    namlast3	= nvl(v_temploy1.namlaste,namlaste),
                                    namlast4	= nvl(v_temploy1.namlaste,namlaste),
                                    namlast5	= nvl(v_temploy1.namlaste,namlaste),
                                    namempe		= nvl(v_temploy1.namempe,namempe),
                                    namempt		= nvl(v_temploy1.namempt,namempt),
                                    namemp3		= nvl(v_temploy1.namempe,namempe),
                                    namemp4		= nvl(v_temploy1.namempe,namempe),
                                    namemp5		= nvl(v_temploy1.namempe,namempe),
                                    dteempdb	= nvl(v_temploy1.dteempdb,dteempdb),
                                    stamarry	= nvl(v_temploy1.stamarry,stamarry),
                                    codsex		= nvl(v_temploy1.codsex,codsex),
                                    numlvl      = nvl(v_temploy1.numlvl,numlvl),
                                    dteeflvl	= nvl(v_temploy1.dteeflvl,dteeflvl),
                                    dteefpos	= nvl(v_temploy1.dteefpos,dteefpos),
                                    dteoccup	= nvl(v_temploy1.dteoccup,dteoccup),
                                    flgatten    = nvl(v_temploy1.flgatten,flgatten),
                                    qtydatrq	= nvl(v_temploy1.qtydatrq,qtydatrq),
                                    numtelof	= nvl(v_temploy1.numtelof,numtelof),
                                    email		= nvl(v_temploy1.email,email),
                                    dteeffex	= nvl(v_temploy1.dteeffex,dteeffex),	                                  
                                    dteduepr	= nvl(v_temploy1.dteduepr,dteduepr),
                                    dteefstep   = nvl(v_temploy1.dteempmt,dteefstep),
                                    numappl		= nvl(v_temploy1.codempid,codempid),
                                    coduser	    = global_v_coduser                                    
                where codempid = r_temploy1.codempid;

            end loop;

            if not v_exist then
                insert into temploy1 (codempid,codtitle,namfirste,
                                      namfirstt,namfirst3,namfirst4,
                                      namfirst5,namlaste,namlastt,
                                      namlast3,namlast4,namlast5,
                                      namempe,namempt,namemp3,
                                      namemp4,namemp5,dteempdb,
                                      stamarry,codsex,dteempmt,
                                      codcomp,codpos,dteefpos,
                                      numlvl,dteeflvl,staemp,
                                      dteeffex,flgatten,codbrlc,
                                      codempmt,typpayroll,codjob,
                                      typemp,dteoccup,dteduepr,
                                      qtydatrq,numtelof,email,
                                      jobgrade,codgrpgl,stamilit,
                                      dteefstep,numdisab,stadisb,
                                      dtedisb,dtedisen,desdisp,
                                      numappl,codcalen,codcreate,
                                      coduser)
                    values           (v_temploy1.codempid,v_temploy1.codtitle,v_temploy1.namfirste,
                                      v_temploy1.namfirstt,v_temploy1.namfirst3,v_temploy1.namfirst4,
                                      v_temploy1.namfirst5,v_temploy1.namlaste,v_temploy1.namlastt,
                                      v_temploy1.namlast3,v_temploy1.namlast4,v_temploy1.namlast5,
                                      v_temploy1.namempe,v_temploy1.namempt,v_temploy1.namemp3,
                                      v_temploy1.namemp4,v_temploy1.namemp5,v_temploy1.dteempdb,
                                      v_temploy1.stamarry,v_temploy1.codsex,v_temploy1.dteempmt,
                                      v_temploy1.codcomp,v_temploy1.codpos,v_temploy1.dteefpos,
                                      v_temploy1.numlvl,v_temploy1.dteeflvl,v_temploy1.staemp,
                                      v_temploy1.dteeffex,v_temploy1.flgatten,v_temploy1.codbrlc,
                                      v_temploy1.codempmt,v_temploy1.typpayroll,v_temploy1.codjob,
                                      v_temploy1.typemp,v_temploy1.dteoccup,v_temploy1.dteduepr,
                                      v_temploy1.qtydatrq,v_temploy1.numtelof,v_temploy1.email,
                                      v_temploy1.jobgrade,v_temploy1.codgrpgl,v_temploy1.stamilit,
                                      v_temploy1.dteefstep,v_temploy1.numdisab,v_temploy1.stadisb,
                                      v_temploy1.dtedisb,v_temploy1.dtedisen,v_temploy1.desdisp,                                                                               
                                      v_temploy1.numappl,v_temploy1.codcalen,global_v_coduser,
                                      global_v_coduser);


                v_chk := 'N' ;
                begin
                    select 'Y' into v_chk
                      from ttnewemp
                     where codempid = v_temploy1.codempid;
                exception when no_data_found then
                    v_chk := 'N' ;
                end ;

                if v_chk = 'N'  then
                    insert into ttnewemp (codempid,dteempmt,codempmt,
                                          numreqst,codcomp,codpos,
                                          codjob,numlvl,codbrlc,
                                          codcalen,flgatten,qtydatrq,
                                          dteduepr,staemp,codedlv,
                                          typemp,typpayroll,flgupd,
                                          codcreate,coduser)
                                  select  codempid,dteempmt,codempmt,
                                          numreqst,codcomp,codpos,
                                          codjob,numlvl,codbrlc,
                                          codcalen,flgatten,qtydatrq,
                                          dteduepr,staemp,codedlv,
                                          typemp,typpayroll,'N',
                                          codcreate,coduser
                                     from temploy1
                                    where codempid = v_temploy1.codempid;
                end if;

                upd_tempded (v_temploy1,p_coduser) ;

            end if;

            -- temploy2
            v_temploy2.adrrege  := nvl(v_temploy2.adrrege,v_text(42)) ;
            v_temploy2.adrregt  := nvl(v_temploy2.adrregt,v_text(42)) ;
            v_temploy2.adrcontt := nvl(nvl(v_temploy2.adrcontt,v_text(45)),v_temploy2.adrregt) ;
            v_temploy2.adrconte := nvl(nvl(v_temploy2.adrconte,v_text(45)),v_temploy2.adrrege) ;
            v_temploy2.adrissue := v_text(39);
            v_temploy2.codpostr := v_text(43); 
            v_temploy2.numtelec := v_text(48);    
            v_temploy2.numlicid := v_text(49);    
            v_temploy2.high     := v_text(51);    
            v_temploy2.weight   := v_text(52);  
            v_temploy2.numpasid := v_text(53);  
            v_temploy2.numprmid := v_text(55);  

            v_exist   := false; 
            for r_temploy2 in c_temploy2 loop
                v_exist   := true;

                upd_log1(r_temploy2.codempid,'temploy2','11','codorgin','C',r_temploy2.codorgin,v_temploy2.codorgin,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','codnatnl','C',r_temploy2.codnatnl,v_temploy2.codnatnl,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','codrelgn','C',r_temploy2.codrelgn,v_temploy2.codrelgn,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','codblood','C',r_temploy2.codblood,v_temploy2.codblood,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','coddomcl','C',r_temploy2.coddomcl,v_temploy2.coddomcl,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','numoffid','C',r_temploy2.numoffid,v_temploy2.numoffid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','adrissue','C',r_temploy2.adrissue,v_temploy2.adrissue,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','codprovi','C',r_temploy2.codprovi,v_temploy2.codprovi,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','dteoffid','D',to_char(r_temploy2.dteoffid,'dd/mm/yyyy'),to_char(v_temploy2.dteoffid,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);              
                upd_log1(r_temploy2.codempid,'temploy2','11','numtelec','C',r_temploy2.numtelec,v_temploy2.numtelec,'N',v_temploy1_initial.codcomp,p_coduser);                  
                upd_log1(r_temploy2.codempid,'temploy2','11','numlicid','C',r_temploy2.numlicid,v_temploy2.numlicid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','dtelicid','D',to_char(r_temploy2.dtelicid,'dd/mm/yyyy'),to_char(v_temploy2.dtelicid,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','weight','N',r_temploy2.weight,v_temploy2.weight,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','high','N',r_temploy2.high,v_temploy2.high,'N',v_temploy1_initial.codcomp,p_coduser);      
                upd_log1(r_temploy2.codempid,'temploy2','11','numpasid','C',r_temploy2.numpasid,v_temploy2.numpasid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','dtepasid','D',to_char(r_temploy2.dtepasid,'dd/mm/yyyy'),to_char(v_temploy2.dtepasid,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','numprmid','C',r_temploy2.numprmid,v_temploy2.numprmid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','dteprmst','D',to_char(r_temploy2.dteprmst,'dd/mm/yyyy'),to_char(v_temploy2.dteprmst,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','11','dteprmen','D',to_char(r_temploy2.dteprmen,'dd/mm/yyyy'),to_char(v_temploy2.dteprmen,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);

                upd_log1(r_temploy2.codempid,'temploy2','12','adrregt','C',r_temploy2.adrregt,v_temploy2.adrregt,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','12','codcntyr','C',r_temploy2.codcntyr,v_temploy2.codcntyr,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','12','codpostr','N',r_temploy2.codpostr,v_temploy2.codpostr,'N',v_temploy1_initial.codcomp,p_coduser);         
                upd_log1(r_temploy2.codempid,'temploy2','12','adrcontt','C',r_temploy2.adrcontt,v_temploy2.adrcontt,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','12','codcntyc','C',r_temploy2.codcntyc,v_temploy2.codcntyc,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy2.codempid,'temploy2','12','codpostc','N',r_temploy2.codpostc,v_temploy2.codpostc,'N',v_temploy1_initial.codcomp,p_coduser);

                update temploy2 set	  adrregt	    = nvl(v_temploy2.adrregt,adrregt),
                                      adrrege		= nvl(v_temploy2.adrrege,adrrege),													 
                                      adrreg3		= nvl(v_temploy2.adrregt,adrrege),
                                      adrreg4		= nvl(v_temploy2.adrregt,adrrege),
                                      adrreg5		= nvl(v_temploy2.adrregt,adrrege),	
                                      codcntyr	    = nvl(v_temploy2.codcntyr,codcntyr),
                                      codpostr	    = nvl(v_temploy2.codpostr,codpostr),
                                      adrcontt	    = nvl(v_temploy2.adrcontt,adrcontt),
                                      adrconte		= nvl(v_temploy2.adrconte,adrconte),												 
                                      adrcont3		= nvl(v_temploy2.adrcontt,adrconte),
                                      adrcont4		= nvl(v_temploy2.adrcontt,adrconte),
                                      adrcont5		= nvl(v_temploy2.adrcontt,adrconte),
                                      codcntyc	    = nvl(v_temploy2.codcntyc,codcntyc),
                                      codpostc	    = nvl(v_temploy2.codpostc,codpostc),                                      
                                      codorgin	    = nvl(v_temploy2.codorgin,codorgin),
                                      codnatnl	    = nvl(v_temploy2.codnatnl,codnatnl),
                                      codrelgn	    = nvl(v_temploy2.codrelgn,codrelgn),
                                      codblood	    = nvl(v_temploy2.codblood,codblood),
                                      coddomcl	    = nvl(v_temploy2.coddomcl,coddomcl),
                                      numoffid	    = nvl(v_temploy2.numoffid,numoffid),
                                      adrissue	    = nvl(v_temploy2.adrissue,adrissue),
                                      codprovi	    = nvl(v_temploy2.codprovi,codprovi),
                                      dteoffid	    = nvl(v_temploy2.dteoffid,dteoffid),
                                      numtelec	    = nvl(v_temploy2.numtelec,numtelec),
                                      numlicid		= nvl(v_temploy2.numlicid,numlicid),
                                      dtelicid		= nvl(v_temploy2.dtelicid,dtelicid),
                                      high			= nvl(v_temploy2.high,high),
                                      weight		= nvl(v_temploy2.weight,weight),	
                                      numpasid      = nvl(v_temploy2.numpasid,numpasid),                                     
                                      dtepasid      = nvl(v_temploy2.dtepasid,dtepasid),
                                      numprmid	    = nvl(v_temploy2.numprmid,numprmid),
                                      dteprmst		= nvl(v_temploy2.dteprmst,dteprmst),
                                      dteprmen		= nvl(v_temploy2.dteprmen,dteprmen),                                         
                                      coduser		= p_coduser
                where codempid =r_temploy2.codempid;   

            end loop;

            if not v_exist then
              insert into temploy2 (codempid,adrrege,adrregt,
                                    adrreg3,adrreg4,adrreg5,
                                    codcntyr,codpostr,adrconte,
                                    adrcontt,adrcont3,adrcont4,
                                    adrcont5,codcntyc,codpostc,
                                    numtelec,codblood,weight,
                                    high,codrelgn,codorgin,
                                    codnatnl,coddomcl,numoffid,
                                    adrissue,codprovi,dteoffid,
                                    codclnsc,numlicid,dtelicid,
                                    numpasid,dtepasid,numprmid,
                                    dteprmst,dteprmen,codcreate,
                                    coduser)
                      values       (v_temploy2.codempid,v_temploy2.adrrege,v_temploy2.adrregt,
                                    v_temploy2.adrreg3,v_temploy2.adrreg4,v_temploy2.adrreg5,
                                    v_temploy2.codcntyr,v_temploy2.codpostr,v_temploy2.adrconte,
                                    v_temploy2.adrcontt,v_temploy2.adrcont3,v_temploy2.adrcont4,
                                    v_temploy2.adrcont5,v_temploy2.codcntyc,v_temploy2.codpostc,
                                    v_temploy2.numtelec,v_temploy2.codblood,v_temploy2.weight,
                                    v_temploy2.high,v_temploy2.codrelgn,v_temploy2.codorgin,
                                    v_temploy2.codnatnl,v_temploy2.coddomcl,v_temploy2.numoffid,
                                    v_temploy2.adrissue,v_temploy2.codprovi,v_temploy2.dteoffid,
                                    v_temploy2.codclnsc,v_temploy2.numlicid,v_temploy2.dtelicid,
                                    v_temploy2.numpasid,v_temploy2.dtepasid,v_temploy2.numprmid,
                                    v_temploy2.dteprmst,v_temploy2.dteprmen,p_coduser,
                                    p_coduser);

            end if;  

            --temploy3
            v_temploy3.numbank  := v_text(59);
            if v_text(60) > 0 then
                v_temploy3.amttranb := stdenc(nvl(v_text(60),0),v_temploy1.codempid,v_chken);  
                v_temploy3.amtbank  := 100;
            end if;
            v_temploy3.numbank2 := v_text(62); 
            if v_temploy3.codbank2 is not null then
                v_temploy3.amtbank  := 50;
            end if;

            v_temploy3.flgtax     := nvl(v_temploy3.flgtax,'1'); 
            v_temploy3.typtax     := nvl(v_temploy3.typtax,'1'); 
            v_temploy3.typincom   := '1';   
            v_temploy3.flgslip    := '1';   
            v_temploy3.amtincom1  := stdenc(nvl(v_text(64),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom2  := stdenc(nvl(v_text(65),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom3  := stdenc(nvl(v_text(66),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom4  := stdenc(nvl(v_text(67),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom5  := stdenc(nvl(v_text(68),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom6  := stdenc(nvl(v_text(69),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom7  := stdenc(nvl(v_text(70),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom8  := stdenc(nvl(v_text(71),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom9  := stdenc(nvl(v_text(72),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincom10 := stdenc(nvl(v_text(73),0),v_temploy1.codempid,v_chken);

            v_temploy3.numtaxid   := nvl(v_text(74),v_temploy2.numoffid);
            v_temploy3.numsaid    := nvl(v_text(75),v_temploy2.numoffid);

            v_temploy3.amtincbf   := stdenc(nvl(v_text(82),0),v_temploy1.codempid,v_chken);
            v_temploy3.amttaxbf   := stdenc(nvl(v_text(83),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtsaid    := stdenc(nvl(v_text(84),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtpf      := stdenc(nvl(v_text(85),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtincsp   := stdenc(nvl(v_text(93),0),v_temploy1.codempid,v_chken);
            v_temploy3.amttaxsp   := stdenc(nvl(v_text(64),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtsasp    := stdenc(nvl(v_text(64),0),v_temploy1.codempid,v_chken);
            v_temploy3.amtpfsp    := stdenc(nvl(v_text(64),0),v_temploy1.codempid,v_chken);
            v_temploy3.qtychldb   := v_text(87);
            v_temploy3.qtychlda   := v_text(88);

            get_wage_income(hcm_util.get_codcomp_level(v_temploy1.codcomp,1),v_temploy1.codempmt,
                            nvl(v_text(64),0),nvl(v_text(65),0),
                            nvl(v_text(66),0),nvl(v_text(67),0),
                            nvl(v_text(68),0),nvl(v_text(69),0),
                            nvl(v_text(70),0),nvl(v_text(71),0),
                            nvl(v_text(72),0),nvl(v_text(73),0),
                            v_amtothr,v_amtday,v_sumincom);

            v_temploy3.amtothr    := stdenc(v_amtothr,v_temploy1.codempid,v_chken);
            v_temploy3.amtday     := stdenc(v_amtday,v_temploy1.codempid,v_chken);

            v_exist   := false;
            for r_temploy3 in c_temploy3 loop
                v_exist := true;
                upd_log1(r_temploy3.codempid,'temploy3','15','codcurr','C',r_temploy3.codcurr,v_temploy3.codcurr,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','numtaxid','C',r_temploy3.numtaxid,v_temploy3.numtaxid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','numsaid','C',r_temploy3.numsaid,v_temploy3.numsaid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','flgtax','C',r_temploy3.flgtax,v_temploy3.flgtax,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','typtax','C',r_temploy3.typtax,v_temploy3.typtax,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','codbank','C',r_temploy3.codbank,v_temploy3.codbank,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','numbank','N',r_temploy3.numbank,v_temploy3.numbank,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','amtbank','C',r_temploy3.amtbank,v_temploy3.amtbank,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','amttranb','C',r_temploy3.amttranb,v_temploy3.amttranb,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','codbank2','C',r_temploy3.codbank2,v_temploy3.codbank2,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','161','numbank2','C',r_temploy3.numbank2,v_temploy3.numbank2,'N',v_temploy1_initial.codcomp,p_coduser);                
                upd_log1(r_temploy3.codempid,'temploy3','164','qtychldb','N',r_temploy3.qtychldb,v_temploy3.qtychldb,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','164','qtychlda','N',r_temploy3.qtychlda,v_temploy3.qtychlda,'N',v_temploy1_initial.codcomp,p_coduser);                
                upd_log1(r_temploy3.codempid,'temploy3','162','dtebf','D',to_char(r_temploy3.dtebf,'dd/mm/yyyy'),to_char(v_temploy3.dtebf,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','162','amtincbf','C',r_temploy3.amtincbf,v_temploy3.amtincbf,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','162','amttaxbf','C',r_temploy3.amttaxbf,v_temploy3.amttaxbf,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','162','amtpf','C',r_temploy3.amtpf,v_temploy3.amtpf,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','162','amtsaid','C',r_temploy3.amtsaid,v_temploy3.amtsaid,'Y',v_temploy1_initial.codcomp,p_coduser);                
                upd_log1(r_temploy3.codempid,'temploy3','171','dtebfsp','D',to_char(r_temploy3.dtebfsp,'dd/mm/yyyy'),to_char(v_temploy3.dtebfsp,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','171','amtincsp','C',r_temploy3.amtincsp,v_temploy3.amtincsp,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','171','amttaxsp','C',r_temploy3.amttaxsp,v_temploy3.amttaxsp,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','171','amtsasp','C',r_temploy3.amtsasp,v_temploy3.amtsasp,'Y',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_temploy3.codempid,'temploy3','171','amtpfsp','C',r_temploy3.amtpfsp,v_temploy3.amtpfsp,'Y',v_temploy1_initial.codcomp,p_coduser);

                update temploy3 set	    codcurr     = v_temploy3.codcurr,
                                        numtaxid    = v_temploy3.numtaxid,
                                        numsaid     = v_temploy3.numsaid,
                                        flgtax      = v_temploy3.flgtax,
                                        typtax      = v_temploy3.typtax,
                                        typincom    = v_temploy3.typincom,
                                        codbank     = v_temploy3.codbank,
                                        numbank     = v_temploy3.numbank,
                                        amtbank     = v_temploy3.amtbank,
                                        amttranb    = v_temploy3.amttranb,
                                        codbank2    = v_temploy3.codbank2,
                                        numbank2    = v_temploy3.numbank2,
                                        qtychldb    = v_temploy3.qtychldb,
                                        qtychlda    = v_temploy3.qtychlda,
                                        flgslip     = v_temploy3.flgslip,
                                        dtebf       = v_temploy3.dtebf,
                                        amtincbf    = v_temploy3.amtincbf,
                                        amttaxbf    = v_temploy3.amttaxbf,
                                        amtpf       = v_temploy3.amtpf,
                                        amtsaid     = v_temploy3.amtsaid,
                                        dtebfsp     = v_temploy3.dtebfsp,
                                        amtincsp    = v_temploy3.amtincsp,
                                        amttaxsp    = v_temploy3.amttaxsp,
                                        amtsasp     = v_temploy3.amtsasp,
                                        amtpfsp     = v_temploy3.amtpfsp,
                                        coduser	  	= p_coduser
                where codempid = r_temploy3.codempid;
            end loop;

            if not v_exist then
                insert into temploy3 (codempid,codcurr,amtincom1,
                                      amtincom2,amtincom3,amtincom4,
                                      amtincom5,amtincom6,amtincom7,
                                      amtincom8,amtincom9,amtincom10,
                                      amtothr,amtday,numtaxid,
                                      numsaid,flgtax,typtax,
                                      typincom,codbank,numbank,
                                      amtbank,amttranb,codbank2,
                                      numbank2,qtychldb,qtychlda,
                                      dtebf,amtincbf,amttaxbf,
                                      amtpf,amtsaid,dtebfsp,
                                      amtincsp,amttaxsp,amtsasp,
                                      amtpfsp,flgslip,codcreate,
                                      coduser)
                      values         (v_temploy3.codempid,v_temploy3.codcurr,v_temploy3.amtincom1,
                                      v_temploy3.amtincom2,v_temploy3.amtincom3,v_temploy3.amtincom4,
                                      v_temploy3.amtincom5,v_temploy3.amtincom6,v_temploy3.amtincom7,
                                      v_temploy3.amtincom8,v_temploy3.amtincom9,v_temploy3.amtincom10,
                                      v_temploy3.amtothr,v_temploy3.amtday,v_temploy3.numtaxid,
                                      v_temploy3.numsaid,v_temploy3.flgtax,v_temploy3.typtax,
                                      v_temploy3.typincom,v_temploy3.codbank,v_temploy3.numbank,
                                      v_temploy3.amtbank,v_temploy3.amttranb,v_temploy3.codbank2,
                                      v_temploy3.numbank2,v_temploy3.qtychldb,v_temploy3.qtychlda,
                                      v_temploy3.dtebf,v_temploy3.amtincbf,v_temploy3.amttaxbf,
                                      v_temploy3.amtpf,v_temploy3.amtsaid,v_temploy3.dtebfsp,
                                      v_temploy3.amtincsp,v_temploy3.amttaxsp,v_temploy3.amtsasp,
                                      v_temploy3.amtpfsp,v_temploy3.flgslip,p_coduser,
                                      p_coduser);
            end if;

            -- tfamily
            v_exist   := false; 

            v_tfamily.codempid  := v_codempid; 
            v_tfamily.namfatht 	:= v_text(97);
            v_tfamily.nammotht	:= v_text(101);
            v_tfamily.namcontt	:= v_text(105);
            v_tfamily.adrcont1	:= v_text(106);
            v_tfamily.codpost	:= v_text(107);
            v_tfamily.numtele	:= v_text(108);
            v_tfamily.numfax	:= v_text(109);
            v_tfamily.email		:= v_text(110);
            v_tfamily.desrelat 	:= v_text(111); 

            for r_tfamily in c_tfamily loop
                v_exist       := true;

                upd_log1(r_tfamily.codempid,'tfamily','33','namfatht','C',r_tfamily.namfatht,v_tfamily.namfatht,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfnatn','C',r_tfamily.codfnatn,v_tfamily.codfnatn,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfrelg','C',r_tfamily.codfrelg,v_tfamily.codfrelg,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfoccu','C',r_tfamily.codfoccu,v_tfamily.codfoccu,'N',v_temploy1_initial.codcomp,p_coduser);

                upd_log1(r_tfamily.codempid,'tfamily','33','nammotht','C',r_tfamily.nammotht,v_tfamily.nammotht,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfnatn','C',r_tfamily.codmnatn,v_tfamily.codmnatn,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfrelg','C',r_tfamily.codmrelg,v_tfamily.codmrelg,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codfoccu','C',r_tfamily.codmoccu,v_tfamily.codmoccu,'N',v_temploy1_initial.codcomp,p_coduser);

                upd_log1(r_tfamily.codempid,'tfamily','33','adrcont1','C',null,v_tfamily.adrcont1,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','codpost','N',null,v_tfamily.codpost,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','numtele','C',null,v_tfamily.numtele,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','numfax','C',null,v_tfamily.numfax,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','email','C',null,v_tfamily.email,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tfamily.codempid,'tfamily','33','desrelat','C',null,v_tfamily.desrelat,'N',v_temploy1_initial.codcomp,p_coduser);

                update tfamily set namfatht = nvl(v_tfamily.namfatht,namfatht),
                                   codfnatn = nvl(v_tfamily.codfnatn,codfnatn),
                                   codfrelg = nvl(v_tfamily.codfnatn,codfrelg),
                                   codfoccu = nvl(v_tfamily.codfoccu,codfoccu),
                                   nammotht = nvl(v_tfamily.nammotht,nammotht),
                                   codmnatn = nvl(v_tfamily.codmnatn,codmnatn),
                                   codmrelg = nvl(v_tfamily.codmrelg,codmrelg),
                                   codmoccu = nvl(v_tfamily.codmoccu,codmoccu),
                                   namcontt = nvl(v_tfamily.namcontt,namcontt),
                                   adrcont1 = nvl(v_tfamily.adrcont1,adrcont1),
                                   codpost  = nvl(v_tfamily.codpost,codpost),
                                   numtele  = nvl(v_tfamily.numtele,numtele),
                                   numfax   = nvl(v_tfamily.numfax,numfax),
                                   email    = nvl(v_tfamily.email,email),
                                   desrelat = nvl(v_tfamily.desrelat,desrelat),
                                   coduser  = p_coduser
                where codempid = r_tfamily.codempid;
            end loop;

            if not v_exist then
                insert into tfamily (codempid,namfatht,codfnatn,
                                     codfrelg,codfoccu,staliff,
                                     nammotht,codmnatn,codmrelg,
                                     codmoccu,stalifm,namcontt,
                                     adrcont1,codpost,numtele,
                                     numfax,email,desrelat,
                                     codcreate,coduser)
                        values      (v_tfamily.codempid,v_tfamily.namfatht,v_tfamily.codfnatn,
                                     v_tfamily.codfrelg,v_tfamily.codfoccu,'Y',
                                     v_tfamily.nammotht,v_tfamily.codmnatn,v_tfamily.codmrelg,
                                     v_tfamily.codmoccu,'Y',v_tfamily.namcontt,
                                     v_tfamily.adrcont1,v_tfamily.codpost,v_tfamily.numtele,
                                     v_tfamily.numfax,v_tfamily.email,v_tfamily.desrelat,
                                     p_coduser,p_coduser);
            end if;

			-- tspouse
			v_exist   := false; 

			v_tspouse.codempid  := v_codempid;
			v_tspouse.namspt 	:= v_text(112);
			v_tspouse.numoffid	:= v_text(114);
			v_tspouse.desplreg	:= v_text(117);
			v_tspouse.desnoffi	:= v_text(120);
			v_tspouse.desnote	:= v_text(121); 

            for r_tspouse in c_tspouse loop
                v_exist       := true;

                upd_log1(r_tspouse.codempid,'tspouse','31','namspt','C',r_tspouse.namspt,v_tspouse.namspt,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','dtespbd','D',to_char(r_tspouse.dtespbd,'dd/mm/yyyy'),to_char(v_tspouse.dtespbd,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','numoffid','C',r_tspouse.numoffid,v_tspouse.numoffid,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','codspocc','C',r_tspouse.codspocc,v_tspouse.codspocc,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','dtemarry','D',to_char(r_tspouse.dtemarry,'dd/mm/yyyy'),to_char(v_tspouse.dtemarry,'dd/mm/yyyy'),'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','desplreg','C',r_tspouse.desplreg,v_tspouse.desplreg,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','codsppro','C',r_tspouse.codsppro,v_tspouse.codsppro,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','codspcty','C',r_tspouse.codspcty,v_tspouse.codspcty,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','desnoffi','C',r_tspouse.desnoffi,v_tspouse.desnoffi,'N',v_temploy1_initial.codcomp,p_coduser);
                upd_log1(r_tspouse.codempid,'tspouse','31','desnote','C',r_tspouse.desnote,v_tspouse.desnote,'N',v_temploy1_initial.codcomp,p_coduser);

                update tspouse set namspt       = nvl(v_tspouse.namspt,namspt),
                                   dtespbd      = nvl(v_tspouse.dtespbd,dtespbd),
                                   numoffid     = nvl(v_tspouse.numoffid,numoffid),
                                   codspocc     = nvl(v_tspouse.codspocc,codspocc),
                                   dtemarry     = nvl(v_tspouse.dtemarry,dtemarry),
                                   desplreg     = nvl(v_tspouse.desplreg,desplreg),
                                   codsppro     = nvl(v_tspouse.codsppro,codsppro),
                                   codspcty     = nvl(v_tspouse.codspcty,codspcty),
                                   desnoffi     = nvl(v_tspouse.desnoffi,desnoffi),
                                   desnote      = nvl(v_tspouse.desnote,desnote),
                                   coduser      = p_coduser
                where codempid = r_tspouse.codempid;
            end loop;

            if not v_exist then
                insert into tspouse (codempid,namspt,dtespbd,
                                     numoffid,numtaxid,codspocc,
                                     stalife,dtemarry,desplreg,
                                     codsppro,codspcty,desnoffi,
                                     desnote,codcreate,coduser)
                       values       (v_tspouse.codempid,v_tspouse.namspt,v_tspouse.dtespbd,
                                     v_tspouse.numoffid,v_tspouse.numoffid,v_tspouse.codspocc,
                                     'Y',v_tspouse.dtemarry,v_tspouse.desplreg,
                                     v_tspouse.codsppro,v_tspouse.codspcty,v_tspouse.desnoffi,
                                     v_tspouse.desnote,p_coduser,p_coduser);
            end if;

            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_temploy1.codempid,v_temploy1.codcomp,null,null,null,null,null,null,null,'Y',v_remark);           
        end if;

    end;


    procedure import_children_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) is

        v_codempid      temploy1.codempid%type;
        v_codcomp       temploy1.codcomp%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_dteempmt      temploy1.dteempmt%type;
        v_namefile      varchar2(200 char) := p_namefile;
        v_dteimpt       varchar2(200 char) := p_dteimpt;
        v_chk           varchar2(1 char) := 'N';
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 5;
        v_exist		  	boolean;	
        v_numerr        number := 0;	

        v_tchildrn      tchildrn%rowtype;
        v_namchild      varchar2(200 char);
        v_numseq        number := 0;

        type descol is table of varchar2(2500 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_tchildrn is
            select a.rowid,a.*
              from tchildrn a
             where a.codempid = v_tchildrn.codempid
               and (a.namche = v_namchild or a.namcht = v_namchild);

    begin
        v_numerr    := 0;
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;
        v_tchildrn := null;

        v_codempid  := upper(substr(v_text(1),1,10));
        v_tchildrn.codempid := v_codempid;

        begin
            select codcomp,typpayroll,dteempmt
              into v_codcomp,v_typpayroll,v_dteempmt
              from temploy1 a,temploy3 b
             where a.codempid = v_codempid
               and a.codempid = b.codempid(+)
               and rownum = 1 ;
        exception when no_data_found then
            v_numerr  := v_numerr + 1;
            v_remarkerr(v_numerr) := 1||' - '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
        end ;

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;			


            for i in 1..v_max loop
                if i in (1,3) and v_text(i) is null then
                    v_error   := true;
                    v_numerr  :=  + v_numerr + 1;
                    v_remarkerr(v_numerr)	:=  i||' - '||get_errorm_name('HR2045',p_lang); 
                end if;   

                if i  = 2 then
                    if length(v_text(i)) > 100 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (100)';
                    end if; 
                end if;

                if i = 3 and v_text(i) is not null then
                    v_error := check_date(v_text(i),v_zyear);
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang); 
                    end if;                   
                end if;

                if i = 4 and v_text(i) is not null then
                    get_mapping_code('A3',v_text(i),v_tchildrn.codsex,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODSEX';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 5 and v_text(i) is not null then
                    get_mapping_code('ED',v_text(i),v_tchildrn.codedlv,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODEDLV';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

            end loop;

        exit cal_loop;
        end loop;

        if v_numerr = 0 then
            get_default_data(p_typedata,'TCHILDRN','STACHLD',v_tchildrn.stachld);
            if v_tchildrn.stachld is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','STALIFE')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;

            get_default_data(p_typedata,'TCHILDRN','STALIFE',v_tchildrn.stalife);
            if v_tchildrn.stalife is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','STALIFE')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;

            get_default_data(p_typedata,'TCHILDRN','FLGINC',v_tchildrn.flginc);
            if v_tchildrn.flginc is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','FLGINC')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;

            get_default_data(p_typedata,'TCHILDRN','FLGEDLV',v_tchildrn.flgedlv);
            if v_tchildrn.flgedlv is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','FLGEDLV')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;

            get_default_data(p_typedata,'TCHILDRN','FLGDEDUCT',v_tchildrn.flgdeduct);
            if v_tchildrn.flgdeduct is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','FLGDEDUCT')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;

            get_default_data(p_typedata,'TCHILDRN','STABF',v_tchildrn.stabf);
            if v_tchildrn.stabf is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)   := get_comments_column('TCHILDRN','STABF')||' - '||get_errorm_name('PMZ007',p_lang);		           
            end if;
        end if;

        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;   
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tchildrn.codempid,v_codcomp,null,null,null,null,null,null,null,'N',v_remark);           
        else
            v_exist   := false; 

            v_tchildrn.namcht   := v_text(2);
            v_tchildrn.dtechbd  := check_dteyre(v_text(3),v_zyear); 

            for r_tchildrn in c_tchildrn loop
                v_exist := true;
                --upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'codtitle','N','numseq',null,null,'C',r_tchildrn.codtitle,v_tchildrn.codtitle,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'namche','N','numseq',null,null,'C',r_tchildrn.namche,v_tchildrn.namcht,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'namcht','N','numseq',null,null,'C',r_tchildrn.namcht,v_tchildrn.namcht,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'namch3','N','numseq',null,null,'C',r_tchildrn.namch3,v_tchildrn.namcht,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'namch4','N','numseq',null,null,'C',r_tchildrn.namch4,v_tchildrn.namcht,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'namch5','N','numseq',null,null,'C',r_tchildrn.namch5,v_tchildrn.namcht,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'dtechbd','N','numseq',null,null,'D',to_char(r_tchildrn.dtechbd,'dd/mm/yyyy'),to_char(v_tchildrn.dtechbd,'dd/mm/yyyy'),'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'codsex','N','numseq',null,null,'C',r_tchildrn.codsex,v_tchildrn.codsex,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'codedlv','N','numseq',null,null,'C',r_tchildrn.codedlv,v_tchildrn.codedlv,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'stachld','N','numseq',null,null,'C',r_tchildrn.stachld,v_tchildrn.stachld,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'stalife','N','numseq',null,null,'C',r_tchildrn.stalife,v_tchildrn.stalife,'N',v_codcomp,p_coduser);      
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'flginc','N','numseq',null,null,'C',r_tchildrn.flginc,v_tchildrn.flginc,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'flgedlv','N','numseq',null,null,'C',r_tchildrn.flgedlv,v_tchildrn.flgedlv,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'flgdeduct','N','numseq',null,null,'C',r_tchildrn.flgdeduct,v_tchildrn.flgdeduct,'N',v_codcomp,p_coduser);
                upd_log2(r_tchildrn.codempid,'tchildrn','32',r_tchildrn.numseq,'stabf','N','numseq',null,null,'C',r_tchildrn.stabf,v_tchildrn.stabf,'N',v_codcomp,p_coduser);

                update tchildrn set namche      = v_tchildrn.namcht,
                                    namcht      = v_tchildrn.namcht,
                                    namch3      = v_tchildrn.namcht,
                                    namch4      = v_tchildrn.namcht,
                                    namch5      = v_tchildrn.namcht,
                                    dtechbd     = v_tchildrn.dtechbd,
                                    codsex      = v_tchildrn.codsex,
                                    codedlv     = v_tchildrn.codedlv,
                                    stachld     = v_tchildrn.stachld, 
                                    stalife     = v_tchildrn.stalife, 
                                    flginc      = v_tchildrn.flginc, 
                                    flgedlv     = v_tchildrn.flgedlv, 
                                    flgdeduct   = v_tchildrn.flgdeduct, 
                                    stabf       = v_tchildrn.stabf,                                    
                                    coduser     = p_coduser_auto
                where rowid = r_tchildrn.rowid;
            end loop;

            if not v_exist then
                begin
                    select nvl(max(numseq),0) + 1 into v_numseq
                      from tchildrn
                    where codempid = v_tchildrn.codempid;
                exception when no_data_found then
                    v_numseq := 1;
                end;

                insert into tchildrn (codempid,numseq,namche,
                                      namcht,namch3,namch4,
                                      namch5,dtechbd,codsex,
                                      codedlv,stachld,stalife,
                                      flginc,flgedlv,flgdeduct,
                                      stabf,dtecreate,codcreate,
                                      dteupd,coduser)
                        values       (v_tchildrn.codempid,v_numseq,v_tchildrn.namche,
                                      v_tchildrn.namcht,v_tchildrn.namch3,v_tchildrn.namch4,
                                      v_tchildrn.namch5,v_tchildrn.dtechbd,v_tchildrn.codsex,
                                      v_tchildrn.codedlv,v_tchildrn.stachld,v_tchildrn.stalife,
                                      v_tchildrn.flginc,v_tchildrn.flgedlv,v_tchildrn.flgdeduct,
                                      v_tchildrn.stabf,trunc(sysdate),p_coduser_auto,
                                      trunc(sysdate),p_coduser_auto);
            end if;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tchildrn.codempid,v_codcomp,null,null,null,null,null,null,null,'Y',v_remark); 
        end if;
    end;

    procedure import_education_data (p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) is

        v_codempid      temploy1.codempid%type;
        v_codcomp       temploy1.codcomp%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_dteempmt      temploy1.dteempmt%type;
        v_namefile      varchar2(200 char) := p_namefile;
        v_dteimpt       varchar2(200 char) := p_dteimpt;
        v_chk           varchar2(1 char) := 'N';
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 11;
        v_exist		  	boolean;	
        v_numerr        number := 0;
        v_tenum         number;

        v_teducatn      teducatn%rowtype;    
        v_numappl       varchar2(200 char);
        v_numseq        number := 0;

        type descol is table of varchar2(2500 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_teducatn is
            select a.rowid,a.*
              from teducatn a
             where nvl(a.numappl,a.codempid)  = v_numappl
               and a.codempid = v_teducatn.codempid
               and a.codedlv  = v_teducatn.codedlv
               and a.codmajsb = v_teducatn.codmajsb;

    begin
        v_numerr    := 0;
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;
        v_teducatn := null;

        v_codempid  := upper(substr(v_text(1),1,10));
        v_teducatn.codempid := v_codempid;
        v_numappl   := get_numappl(v_codempid);

        if  v_text(1) is null then
            v_error   := true;
            v_numerr  :=  + v_numerr + 1;
            v_remarkerr(v_numerr)	:=  1||' - '||get_errorm_name('HR2045',p_lang); 
        else
            begin
                select codcomp,typpayroll,dteempmt
                  into v_codcomp,v_typpayroll,v_dteempmt
                  from temploy1 a,temploy3 b
                 where a.codempid = v_codempid
                   and a.codempid = b.codempid(+)
                   and rownum = 1 ;
            exception when no_data_found then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr) := 1||' - '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
            end ;            
        end if;  

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;			

            for i in 1..v_max loop
                if i = 2 and v_text(i) is null then
                    v_error   := true;
                    v_numerr  :=  + v_numerr + 1;
                    v_remarkerr(v_numerr)	:=  i||' - '||get_errorm_name('HR2045',p_lang); 
                end if;   

                if i  in (9,10) then
                    if length(v_text(i)) > 4 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (4)';
                    end if; 

                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm0000');
                        if length(v_tenum) > 4 then
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (4)';
                        end if;
                    end if;     

                end if;

                if i = 8 and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm0.00');
                        if length(v_tenum) > 4 then
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := get_errorm_name('PMZ002',p_lang)||' (3,2)';
                        end if;
                    end if;                
                end if;

                if i = 2 and v_text(i) is not null then
                    get_mapping_code('ED',v_text(i),v_teducatn.codedlv,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODEDLV';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 3 and v_text(i) is not null then
                    get_mapping_code('DG',v_text(i),v_teducatn.coddglv,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODDGLV';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 4 and v_text(i) is not null then
                    get_mapping_code('IN',v_text(i),v_teducatn.codinst,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODINST';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 5 and v_text(i) is not null then
                    get_mapping_code('IN',v_text(i),v_teducatn.codmajsb,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODMAJSB';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 6 and v_text(i) is not null then
                    get_mapping_code('SB',v_text(i),v_teducatn.codminsb,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODMINSB';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 7 and v_text(i) is not null then
                    get_mapping_code('CT',v_text(i),v_teducatn.codcount,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODCOUNT';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

                if i = 11 and v_text(i) is not null then
                    get_mapping_code('A7',v_text(i),v_teducatn.flgeduc,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'FLGEDUC';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

            end loop;

        exit cal_loop;
        end loop;


        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;   
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_teducatn.codempid,v_codcomp,null,null,null,null,null,null,null,'N',v_remark);           
        else
            v_exist   := false; 

            v_teducatn.numgpa   := v_text(8);
            v_teducatn.stayear  := v_text(9);
            v_teducatn.dtegyear := v_text(10);

            for r_teducatn in c_teducatn loop
                v_exist := true;

                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'codedlv','N','numseq',null,null,'C',r_teducatn.codedlv,v_teducatn.codedlv,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'coddglv','N','numseq',null,null,'C',r_teducatn.coddglv,v_teducatn.coddglv,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'codmajsb','N','numseq',null,null,'C',r_teducatn.codmajsb,v_teducatn.codmajsb,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'codminsb','N','numseq',null,null,'C',r_teducatn.codminsb,v_teducatn.codminsb,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'codinst','N','numseq',null,null,'C',r_teducatn.codinst,v_teducatn.codinst,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'codcount','N','numseq',null,null,'C',r_teducatn.codcount,v_teducatn.codcount,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'numgpa','N','numseq',null,null,'N',r_teducatn.numgpa,v_teducatn.numgpa,'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'stayear','N','numseq',null,null,'N',r_teducatn.stayear,(v_teducatn.stayear - v_zyear),'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'dtegyear','N','numseq',null,null,'N',r_teducatn.dtegyear,(v_teducatn.dtegyear - v_zyear),'N',v_codcomp,p_coduser);
                upd_log2(r_teducatn.codempid,'teducatn','21',r_teducatn.numseq,'flgeduc','N','numseq',null,null,'C',r_teducatn.flgeduc,v_teducatn.flgeduc,'N',v_codcomp,p_coduser);

                update teducatn set codedlv     = nvl(v_teducatn.codedlv,codedlv),
                                    coddglv     = nvl(v_teducatn.coddglv,coddglv),
                                    codmajsb    = nvl(v_teducatn.codmajsb,codmajsb),
                                    codminsb    = nvl(v_teducatn.codminsb,codminsb),
                                    codinst     = nvl(v_teducatn.codinst,codinst),
                                    codcount    = nvl(v_teducatn.codcount,codcount),
                                    numgpa      = nvl(v_teducatn.numgpa,numgpa),
                                    stayear     = nvl((v_teducatn.stayear - v_zyear),stayear),
                                    dtegyear    = nvl((v_teducatn.dtegyear - v_zyear),dtegyear),
                                    flgeduc     = nvl(v_teducatn.flgeduc,flgeduc), 
                                    coduser     = p_coduser_auto
                where rowid = r_teducatn.rowid;


                if v_teducatn.flgeduc = '1' then
                    update temploy1 set codedlv  = v_teducatn.codedlv,
                                        codmajsb = v_teducatn.codmajsb
                    where codempid = v_teducatn.codempid;

                    update teducatn set flgeduc  = '2'
                     where numappl   = v_numappl
                       and numseq   <> r_teducatn.numseq;                    
                end if;

            end loop;

            if not v_exist then
                begin
                    select nvl(max(numseq),0) + 1 into v_numseq
                      from teducatn
                     where numappl   = v_numappl;
                exception when no_data_found then
                    v_numseq := 1;
                end;

                insert into teducatn   (codempid,numappl,numseq,
                                        codedlv,coddglv,codmajsb,codminsb,codinst,
                                        codcount,numgpa,stayear,dtegyear,flgeduc,
                                        codcreate,coduser)
                       values          (v_teducatn.codempid,v_numappl,v_numseq,
                                        v_teducatn.codedlv,v_teducatn.coddglv,v_teducatn.codmajsb,v_teducatn.codminsb,v_teducatn.codinst,
                                        v_teducatn.codcount,v_teducatn.numgpa,(v_teducatn.stayear - global_v_zyear),(v_teducatn.dtegyear - global_v_zyear),v_teducatn.flgeduc,
                                        global_v_coduser,global_v_coduser);

                if v_teducatn.flgeduc = '1' then
                    update temploy1 set codedlv  = v_teducatn.codedlv,
                                        codmajsb = v_teducatn.codmajsb
                    where codempid = v_teducatn.codempid;

                    update teducatn set flgeduc  = '2'
                     where numappl   = v_numappl
                       and numseq   <> v_numseq;   
                end if;

            end if;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_teducatn.codempid,v_codcomp,null,null,null,null,null,null,null,'Y',v_remark); 
        end if;
    end;


    procedure import_workexp_data (p_namefile   in varchar2,
                                   p_data       in varchar2,
                                   p_typyear    in varchar2,
                                   p_dteimpt    in varchar2,
                                   p_lang       in varchar2,
                                   p_error      in out varchar2,
                                   p_record     in number,
                                   p_coduser    in varchar2) is

        v_codempid      temploy1.codempid%type;
        v_codcomp       temploy1.codcomp%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_dteempmt      temploy1.dteempmt%type;
        v_namefile      varchar2(200 char) := p_namefile;
        v_dteimpt       varchar2(200 char) := p_dteimpt;
        v_chk           varchar2(1 char) := 'N';
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 12;
        v_exist		  	boolean;	
        v_numerr        number := 0;
        v_tenum         number;

        v_tapplwex      tapplwex%rowtype;    
        v_numappl       varchar2(200 char);
        v_numseq        number := 0;
        v_amtincom      tapplwex.amtincom%type;

        type descol is table of varchar2(2500 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

    begin
        v_numerr    := 0;
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;
        v_tapplwex := null;

        v_codempid  := upper(substr(v_text(1),1,10));
        v_tapplwex.codempid := v_codempid;
        v_numappl   := get_numappl(v_codempid);

        if  v_text(1) is null then
            v_error   := true;
            v_numerr  :=  + v_numerr + 1;
            v_remarkerr(v_numerr)	:=  1||' - '||get_errorm_name('HR2045',p_lang); 
        else
            begin
                select codcomp,typpayroll,dteempmt
                  into v_codcomp,v_typpayroll,v_dteempmt
                  from temploy1 a,temploy3 b
                 where a.codempid = v_codempid
                   and a.codempid = b.codempid(+)
                   and rownum = 1 ;
            exception when no_data_found then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr) := 1||' - '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
            end ;            
        end if;  

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;			

            for i in 1..v_max loop
                if i in (2,6,7,8) and v_text(i) is null then
                    v_error   := true;
                    v_numerr  :=  + v_numerr + 1;
                    v_remarkerr(v_numerr)	:=  i||' - '||get_errorm_name('HR2045',p_lang); 
                end if;   

                if i  in (2,6,10,11) then
                    if length(v_text(i)) > 45 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (45)';
                    end if;   
                end if;

                if i  in (3,4) then
                    if length(v_text(i)) > 100 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (100)';
                    end if;   
                end if;

                if i  = 5 then
                    if length(v_text(i)) > 20 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (20)';
                    end if;   
                end if;

                if i  = 12 then
                    if length(v_text(i)) > 500 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (500)';
                    end if;   
                end if;

                if i in (7,8) and v_text(i) is not null then
                    v_error := check_date(v_text(i),v_zyear);
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang); 
                    end if;                   
                end if;

                if i = 9 and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm0000000.00');
                        if length(v_tenum) > 10 then
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
                        end if;
                    end if;                
                end if;

            end loop;

        exit cal_loop;
        end loop;


        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;   
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tapplwex.codempid,v_codcomp,null,null,null,null,null,null,null,'N',v_remark);           
        else
            v_exist   := false; 
            v_tapplwex.desnoffi     := v_text(2);
            v_tapplwex.deslstjob1   := v_text(3);
            v_tapplwex.desoffi1     := v_text(4);
            v_tapplwex.numteleo     := v_text(5);
            v_tapplwex.deslstpos    := v_text(6);
            v_tapplwex.dtestart     := check_dteyre(v_text(7),v_zyear); 
            v_tapplwex.dteend       := check_dteyre(v_text(8),v_zyear); 
            v_tapplwex.amtincom     := v_text(9);
            v_amtincom              := stdenc(nvl(v_tapplwex.amtincom,0),v_tapplwex.codempid,v_chken);
            v_tapplwex.desres       := v_text(10);
            v_tapplwex.namboss      := v_text(11);
            v_tapplwex.remark       := v_text(12);

            begin
                select nvl(max(numseq),0) + 1 into v_numseq
                  from tapplwex
                 where numappl   = v_numappl;
            exception when no_data_found then
                v_numseq := 1;
            end;

            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'desnoffi','N','numseq',null,null,'C',null,v_tapplwex.desnoffi,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'deslstjob1','N','numseq',null,null,'C',null,v_tapplwex.deslstjob1,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'deslstpos','N','numseq',null,null,'C',null,v_tapplwex.deslstpos,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'desoffi1','N','numseq',null,null,'C',null,v_tapplwex.desoffi1,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'numteleo','N','numseq',null,null,'C',null,v_tapplwex.numteleo,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'namboss','N','numseq',null,null,'C',null,v_tapplwex.namboss,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'desres','N','numseq',null,null,'C',null,v_tapplwex.desres,'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'amtincom','N','numseq',null,null,'C',null,v_amtincom,'Y',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'dtestart','N','numseq',null,null,'D',null,to_char(v_tapplwex.dtestart,'dd/mm/yyyy'),'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'dteend','N','numseq',null,null,'D',null,to_char(v_tapplwex.dteend,'dd/mm/yyyy'),'N',v_codcomp,p_coduser);
            upd_log2(v_tapplwex.codempid,'tapplwex','22',v_numseq,'remark','N','numseq',null,null,'C',null,v_tapplwex.remark,'N',v_codcomp,p_coduser);

            insert into tapplwex   (codempid,numappl,numseq,
                                    desnoffi,deslstjob1,desoffi1,
                                    numteleo,deslstpos,dtestart,
                                    dteend,amtincom,desres,
                                    namboss,remark,codcreate,
                                    coduser)
            values                 (v_tapplwex.codempid,v_numappl,v_numseq,
                                    v_tapplwex.desnoffi,v_tapplwex.deslstjob1,v_tapplwex.desoffi1,
                                    v_tapplwex.numteleo,v_tapplwex.deslstpos,v_tapplwex.dtestart,
                                    v_tapplwex.dteend,v_amtincom,v_tapplwex.desres,
                                    v_tapplwex.namboss,v_tapplwex.remark,global_v_coduser,
                                    global_v_coduser);

            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tapplwex.codempid,v_codcomp,null,null,null,null,null,null,null,'Y',v_remark); 
        end if;
    end;


    procedure import_movement_data ( p_namefile   in varchar2,
                                     p_data       in varchar2,
                                     p_typyear    in varchar2,
                                     p_dteimpt    in varchar2,
                                     p_lang       in varchar2,
                                     p_error      in out varchar2,
                                     p_record     in number,
                                     p_coduser    in varchar2) is

        v_typedata      varchar2(1 char); 
        v_codempid      temploy1.codempid%type;
        v_codempidmt    temploy1.codempid%type;
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 24;
        v_exist		  	boolean;	
        v_numerr        number := 0;
        v_flgerrb       varchar2(1 char);
        v_tenum         number;
        v_transtat      varchar2(3 char);
        v_count         number := 0;
        v_caseiud       varchar2(3 char);

        ------------------------------------------------------------
        v_codpos        temploy1.codpos%type;
        v_codcomp  	    temploy1.codcomp%type;
        v_numlvl        number;	
        v_ttmovemt      ttmovemt%rowtype;
        v_ttexempt      ttexempt%rowtype;

        v_codcompt 		ttmovemt.codcompt%type;
        v_codposnow 	ttmovemt.codposnow%type;
        v_codjobt 		ttmovemt.codjobt%type;
        v_numlvlt 		number;
        v_codbrlct 		ttmovemt.codbrlct%type;
        v_codcalet      ttmovemt.codcalet%type;			
        v_flgattet      ttmovemt.flgattet%type;			 
        v_codedlv       ttmovemt.codedlv%type;			
        v_codsex        temploy1.codsex%type;			
        v_codempmtt     ttmovemt.codempmtt%type;		
        v_typpayrolt    ttmovemt.typpayrolt%type;			
        v_typempt       ttmovemt.typempt%type;	
        v_codgrpglt     ttmovemt.codgrpglt%type;	
        v_jobgradet     ttmovemt.jobgradet%type;	
        v_stapost2      ttmovemt.stapost2%type := '0';
        v_flgadjin      ttmovemt.flgadjin%type;	
        v_tfincadj_initial      tfincadj%rowtype;
        v_dteempmt      date;	
        v_staemp    	varchar2(1 char);
        v_codcurr       varchar2(4 char);
        v_typmove       varchar2(1 char);
        v_numseq        number;
        v_maxperiod     varchar2(10 char);
        v_minperiod     varchar2(10 char);

        v_amt1      	number;
        v_amt2      	number;
        v_amt3      	number;
        v_amt4      	number;
        v_amt5      	number;
        v_amt6      	number;
        v_amt7      	number;
        v_amt8      	number;
        v_amt9      	number;
        v_amt10     	number;
        v_amth          number;
        v_amtadj1       number;
        v_amtadj2       number;
        v_amtadj3       number;
        v_amtadj4       number;
        v_amtadj5       number;
        v_amtadj6       number;
        v_amtadj7       number;
        v_amtadj8       number;
        v_amtadj9       number;
        v_amtadj10      number;
        v_seq			number;
        v_flgchg        varchar2(1 char);

        v_amtincom1 	temploy3.amtincom1%type;
        v_amtincom2		temploy3.amtincom1%type;
        v_amtincom3 	temploy3.amtincom1%type;
        v_amtincom4 	temploy3.amtincom1%type;
        v_amtincom5 	temploy3.amtincom1%type;
        v_amtincom6 	temploy3.amtincom1%type;
        v_amtincom7 	temploy3.amtincom1%type;
        v_amtincom8	 	temploy3.amtincom1%type;
        v_amtincom9 	temploy3.amtincom1%type;
        v_amtincom10 	temploy3.amtincom1%type;
        v_amtothr    	number;
        v_amtday	    number;
        v_amtmth	    number;

        v_sumhur		number := 0;
        v_sumday		number := 0;
        v_summth		number := 0;

        v_staupd        varchar2(1);
        tm_numseq       number := 0;
        v_maxdata       number := 0;
        v_loop			number := 0;
        v_maxeeffec     date;
        v_seqpminf      number;

        v_sum           number ;
        v_err           number ;
        v_secur         number;
        v_errsecur      number;
        v_codcom2       varchar2(10 char);
        v_fildname      varchar2(100 char);

        type descol is table of varchar2(2500 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_ttmovemt is
            select  dteeffec,numseq,codtrn,codcomp,codpos,codjob,
                    numlvl,codbrlc,codcalen,flgatten,stapost2,
                    codempmt,typpayroll,typemp,staupd,flgadjin,
                    codgrpgl,jobgrade,
                    stddec(amtincom1,codempid,v_chken) amtincom1,
                    stddec(amtincom2,codempid,v_chken) amtincom2,
                    stddec(amtincom3,codempid,v_chken) amtincom3,
                    stddec(amtincom4,codempid,v_chken) amtincom4,
                    stddec(amtincom5,codempid,v_chken) amtincom5,
                    stddec(amtincom6,codempid,v_chken) amtincom6,
                    stddec(amtincom7,codempid,v_chken) amtincom7,
                    stddec(amtincom8,codempid,v_chken) amtincom8,
                    stddec(amtincom9,codempid,v_chken) amtincom9,
                    stddec(amtincom10,codempid,v_chken) amtincom10
              from ttmovemt
             where codempid  = v_codempid
               and dteeffec  = v_ttmovemt.dteeffec
               and codtrn    = v_ttmovemt.codtrn
             order by numseq desc;

        cursor c_ttmovemt_u is
        select rowid,codcompt,codcomp,codposnow,codpos,codjobt,codjob,
                numlvlt,numlvl,codbrlct,codbrlc,codcalet,codcalen,numseq,
                flgattet,flgatten,codempmtt,codempmt,typpayrolt,typpayroll,
                typempt,typemp,flgadjin,codtrn,stapost2,staupd,
                amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
                amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,
                amtincadj1,amtincadj2,amtincadj3,amtincadj4,amtincadj5,
                amtincadj6,amtincadj7,amtincadj8,amtincadj9,amtincadj10,
                codgrpglt,dteefpos,dteeflvl,dteefstep,
                jobgrade,jobgradet
          from	ttmovemt
         where	codempid = v_codempid
           and  dteeffec = v_ttmovemt.dteeffec
           and  codtrn   = v_ttmovemt.codtrn
           and	staupd in('C','U');

        cursor c_ttcancel is
            select rowid
              from ttcancel
             where codempid = v_codempid
               and dteeffec = v_ttmovemt.dteeffec
               and codtrn	= v_ttmovemt.codtrn
               and numseq   = v_numseq;

    begin
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;
        <<cal_loop>>
        loop
            v_error     := false;
            v_flgchg    := 'N'; 
            v_remark    := null;		
            v_ttmovemt  := null;	    

            v_codempid  := upper(substr(v_text(1),1,10));
            if v_text(1) is null then
              v_error   := true;
              v_numerr  :=  + v_numerr + 1;
              v_remarkerr(v_numerr)	:=  1||' - '||get_errorm_name('HR2045',p_lang);  
            end if;

            if length(v_text(1)) > 10 then 
              v_error   := true;
              v_numerr  := v_numerr + 1;
              v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
            end if;

            v_ttmovemt.codempid := v_codempid;			

            begin
                select  a.codcomp,a.codpos,a.codjob,a.numlvl,a.codbrlc,
                        a.staemp,a.codcalen,a.flgatten,a.codedlv,a.codsex,
                        a.codempmt,a.typpayroll,a.typemp,a.dteempmt,
                        a.codgrpgl,a.jobgrade,b.codcurr
                  into  v_codcompt,v_codposnow,v_codjobt,v_numlvlt,v_codbrlct,
                        v_staemp,v_codcalet,v_flgattet,v_codedlv,v_codsex,
                        v_codempmtt,v_typpayrolt,v_typempt,v_dteempmt,
                        v_codgrpglt,v_jobgradet,v_codcurr
                  from temploy1 a,temploy3 b
                 where a.codempid = v_codempid
                   and a.codempid = b.codempid ;
                if v_staemp = '9' then
                    v_error	  := true;
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2101',p_lang);
                elsif v_staemp = '0' then
                    v_error	  := true;
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2102',p_lang);
                end if;
            exception when no_data_found then
                v_error	  := true;
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2010',p_lang)||' (TEMPLOY1)';
            end;
            v_codcomp := v_codcompt;
            v_codpos  := v_codposnow;
            v_numlvl  := v_numlvlt;

            for i in 1..v_max loop
                -- check required field
                --if i in (1,2,3,4,5,6,7,8,9,10,11,12,13) then 
                if i in (1,2,4,5,6,7) then 
                    if v_text(i) is null then
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('HR2045',p_lang);
                    end if;		

                    if i = 2 and v_text(i) is not null then
                        v_error := check_date(v_text(i),v_zyear);
                        if v_error then	
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('COZ005',p_lang);
                        else
                            v_ttmovemt.dteeffec  := check_dteyre(v_text(i),v_zyear);    
                        end if;

                    end if;

                end if;		

              if i = 3 then
                    if v_text(i) is not null then
                        get_mapping_code('MT',v_text(i),v_ttmovemt.codtrn,v_error);
                        if v_error then	
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ003',p_lang);		
                            v_namfild(v_numerr)     := 'CODTRN';
                            v_sapcode(v_numerr)     := v_text(i);
                        end if;
                    else
                        get_default_data(p_typedata,'TTMOVEMT','CODTRN',v_ttmovemt.codtrn);
                        if v_ttmovemt.codtrn is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    end if;

                    begin		
                        select typmove 	into v_typmove
                          from tcodmove
                         where codcodec = v_ttmovemt.codtrn;				
                    exception when no_data_found then 
                        v_typmove := null;
                    end;

                    if v_typmove not in ('M','A') then
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ009',p_lang);
                    end if;

                    if v_ttmovemt.codtrn in ('0001','0002','0003','0004','0005','0006','0007') then
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PM0036',p_lang)||' ('||v_text(i)||')';
                    end if;
                end if;

                --- check maping code
                if i in (4,5,6,7,8,9,10,11,12,13,24) then
                    v_error := false;
                    if i = 4 and v_text(i) is not null then
                        get_mapping_code('E1',v_text(i),v_ttmovemt.codcomp,v_error);
                        v_fildname := 'CODCOMP';
                    elsif i = 5 and v_text(i) is not null then
                        get_mapping_code('E2',v_text(i),v_ttmovemt.codpos,v_error);
                        v_fildname := 'CODPOS';
                    elsif i = 6 and v_text(i) is not null then
                        get_mapping_code('LO',v_text(i),v_ttmovemt.codbrlc,v_error);
                        v_fildname := 'CODBRLC';
                    elsif i = 7 and v_text(i) is not null then
                        get_mapping_code('TE',v_text(i),v_ttmovemt.codempmt,v_error);
                        v_fildname := 'CODEMPMT';
                    elsif i = 8 and v_text(i) is not null then
                        get_mapping_code('PY',v_text(i),v_ttmovemt.typpayroll,v_error);
                        v_fildname := 'TYPPAYROLL';
                    elsif i = 9 and v_text(i) is not null then
                        get_mapping_code('CG',v_text(i),v_ttmovemt.typemp,v_error);
                        v_fildname := 'TYPEMP';
                    elsif i = 10 and v_text(i) is not null then
                        get_mapping_code('GR',v_text(i),v_ttmovemt.codcalen,v_error);
                        v_fildname := 'CODCALEN';
                    elsif i = 11 and v_text(i) is not null then
                        get_mapping_code('E3',v_text(i),v_ttmovemt.codjob,v_error);
                        v_fildname := 'CODJOB';
                    elsif i = 12 and v_text(i) is not null then
                        get_mapping_code('E4',v_text(i),v_ttmovemt.flgatten,v_error);
                        v_fildname := 'FLGATTEN';
                    elsif i = 13 and v_text(i) is not null then
                        get_mapping_code('E5',v_text(i),v_ttmovemt.stapost2,v_error);
                        v_fildname := 'STAPOST2';
                    elsif i = 24 and v_text(i) is not null then
                        get_mapping_code('CR',v_text(i),v_ttmovemt.codcurr,v_error);
                        v_fildname := 'CODCURR';
                    end if;
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                        v_namfild(v_numerr)     := v_fildname;
                        v_sapcode(v_numerr)     := v_text(i);
                    end if;

                    if i = 8 and v_ttmovemt.typpayroll is null then
                        get_default_data(p_typedata,'TTMOVEMT','TYPPAYROLL',v_ttmovemt.typpayroll);
                        if v_ttmovemt.typpayroll is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 9 and v_ttmovemt.typemp is null then
                        get_default_data(p_typedata,'TTMOVEMT','TYPEMP',v_ttmovemt.typemp);
                        if v_ttmovemt.typemp is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 10 and v_ttmovemt.codcalen is null then
                        get_default_data(p_typedata,'TTMOVEMT','CODCALEN',v_ttmovemt.codcalen);
                        if v_ttmovemt.codcalen is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 11 and v_ttmovemt.codjob is null then
                        get_default_data(p_typedata,'TTMOVEMT','CODJOB',v_ttmovemt.codjob);
                        if v_ttmovemt.codjob is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 12 and v_ttmovemt.flgatten is null then
                        get_default_data(p_typedata,'TTMOVEMT','FLGATTEN',v_ttmovemt.flgatten);
                        if v_ttmovemt.flgatten is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 13 and v_ttmovemt.stapost2 is null then
                        get_default_data(p_typedata,'TTMOVEMT','STAPOST2',v_ttmovemt.stapost2);
                        if v_ttmovemt.stapost2 is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);	
                        end if;
                    elsif i = 24 and v_ttmovemt.codcurr is null then
                        get_default_data(p_typedata,'TTMOVEMT','CODCURR',v_ttmovemt.codcurr);
                        if v_ttmovemt.codcurr is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);
                        end if;
                    end if;

                end if;

                if v_typmove = 'A' then
                    if i in (14,15,16,17,18,19,20,21,22,23) and v_text(i) is not null then
                        v_ttmovemt.flgadjin := 'Y';
                        v_error := check_number(v_text(i));
                        if v_error then	
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                        else    
                            v_tenum := null;
                            v_tenum := to_char(to_number(v_text(i)),'fm0000000.00');
                            if length(v_tenum) > 10 then
                                v_error   := true;
                                v_numerr  := v_numerr + 1;
                                v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
                            end if;
                        end if;
                    end if;
                end if;

            end loop; --for i in 1..v_max loop

        exit cal_loop;
        end loop;


        if v_numerr = 0 then
            v_ttmovemt.dteeffec  := check_dteyre(v_text(2),v_zyear); 

            v_count := 0;
            begin
                select count(*) into v_count
                  from ttmovemt
                 where codempid = v_codempid
                   and dteeffec = v_ttmovemt.dteeffec
                   and codtrn   = v_ttmovemt.codtrn;
            exception when no_data_found then
                v_count := 0;
            end;
            v_caseiud := 'I';
            if v_count <> 0 then
                v_caseiud := 'U';
            end if;

            v_count := 0;
            begin
                select count(*) into v_count
                  from ttmovemt
                 where codempid = v_codempid
                   and dteeffec = v_ttmovemt.dteeffec
                   and codtrn   = v_ttmovemt.codtrn
                   and staupd   = 'U';
            exception when no_data_found then
                v_count := 0;
            end;            

            if v_count <> 0 then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PMZ010',p_lang); 
            end if;

            if v_caseiud = 'I' then
                v_count := 0;
                begin
                    select count(*) into v_count
                      from ttmovemt
                     where codempid = v_codempid
                       and dteeffec > v_ttmovemt.dteeffec
                       and codtrn   = v_ttmovemt.codtrn;
                exception when no_data_found then
                    v_count := 0;
                end;

                if v_count <> 0 then
                    v_error   := true;
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= get_errorm_name('PM0060',p_lang); 
                else
                    begin
                        select nvl(max(numseq),1) into v_ttmovemt.numseq
                          from ttmovemt
                         where codempid = v_codempid
                           and dteeffec = v_ttmovemt.dteeffec;
                    exception when no_data_found then
                        v_ttmovemt.numseq := 1;
                    end;                             
                end if;

                if to_char(v_ttmovemt.dteeffec,'dd/mm/yyyy') < to_char(v_dteempmt,'dd/mm/yyyy') then
                    v_error   := true;
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= get_errorm_name('PMZ011',p_lang); 
                end if;

            end if;
        end if;

        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;  
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttmovemt.codempid,v_codcomp,to_char(v_ttmovemt.dteeffec,'dd/mm/yyyy'),v_ttmovemt.codtrn,null,null,null,null,null,'N',v_remark);           
        else
            v_exist   := false;   

            begin
                select staupd,numseq,flgadjin into v_staupd,v_numseq,v_flgadjin
                  from ttmovemt
                 where codempid = v_codempid
                   and dteeffec = v_ttmovemt.dteeffec
                   and codtrn   = v_ttmovemt.codtrn
                   and rownum   = 1;
            exception when no_data_found then
                v_staupd := 'U';
                v_numseq := 1;
            end;  

            v_ttmovemt.codcomp     := nvl(v_ttmovemt.codcomp,v_codcompt);
            v_ttmovemt.codpos      := nvl(v_ttmovemt.codpos,v_codposnow);
            v_ttmovemt.codbrlc     := nvl(v_ttmovemt.codbrlc,v_codbrlct);
            v_ttmovemt.codempmt    := nvl(v_ttmovemt.codempmt,v_codempmtt);
            v_ttmovemt.typpayroll  := nvl(v_ttmovemt.typpayroll,v_typpayrolt);
            v_ttmovemt.typemp      := nvl(v_ttmovemt.typemp,v_typempt);
            v_ttmovemt.codgrpgl    := nvl(v_ttmovemt.codgrpgl,v_codgrpglt);
            v_ttmovemt.jobgrade    := nvl(v_ttmovemt.jobgrade,v_jobgradet);
            v_ttmovemt.numlvl      := nvl(v_ttmovemt.numlvl,v_numlvlt);

            begin
                select   codcurr,
                         stddec(amtincom1,codempid,v_chken),
                         stddec(amtincom2,codempid,v_chken),
                         stddec(amtincom3,codempid,v_chken),
                         stddec(amtincom4,codempid,v_chken),
                         stddec(amtincom5,codempid,v_chken),
                         stddec(amtincom6,codempid,v_chken),
                         stddec(amtincom7,codempid,v_chken),
                         stddec(amtincom8,codempid,v_chken),
                         stddec(amtincom9,codempid,v_chken),
                         stddec(amtincom10,codempid,v_chken)
                into     v_codcurr,
                         v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                         v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
                 from temploy3
                where codempid = v_codempid ;
            end;

            v_sumhur	  := 0; v_sumday	  := 0; v_summth	  := 0;			
            get_wage_income (upper(substr(v_ttmovemt.codcomp,1,3)),upper(v_ttmovemt.codempmt),
                             v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                             v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10,
                             v_sumhur,v_sumday,v_summth);		

            v_amth := nvl(v_sumhur,0);        

            v_ttmovemt.amtincom1  		:= stdenc(nvl(v_amtincom1,0),v_codempid,v_chken);
            v_ttmovemt.amtincom2  		:= stdenc(nvl(v_amtincom2,0),v_codempid,v_chken);
            v_ttmovemt.amtincom3  		:= stdenc(nvl(v_amtincom3,0),v_codempid,v_chken);
            v_ttmovemt.amtincom4  		:= stdenc(nvl(v_amtincom4,0),v_codempid,v_chken);
            v_ttmovemt.amtincom5  		:= stdenc(nvl(v_amtincom5,0),v_codempid,v_chken);
            v_ttmovemt.amtincom6  		:= stdenc(nvl(v_amtincom6,0),v_codempid,v_chken);
            v_ttmovemt.amtincom7  		:= stdenc(nvl(v_amtincom7,0),v_codempid,v_chken);
            v_ttmovemt.amtincom8  		:= stdenc(nvl(v_amtincom8,0),v_codempid,v_chken);
            v_ttmovemt.amtincom9  		:= stdenc(nvl(v_amtincom9,0),v_codempid,v_chken);
            v_ttmovemt.amtincom10 		:= stdenc(nvl(v_amtincom10,0),v_codempid,v_chken);
            v_ttmovemt.amtothr 		    := stdenc(nvl(v_amth,0),v_codempid,v_chken);

            v_amtadj1 := nvl(v_text(14),0);
            v_amtadj2 := nvl(v_text(15),0);
            v_amtadj3 := nvl(v_text(16),0);
            v_amtadj4 := nvl(v_text(17),0);
            v_amtadj5 := nvl(v_text(18),0);
            v_amtadj6 := nvl(v_text(19),0);
            v_amtadj7 := nvl(v_text(20),0);
            v_amtadj8 := nvl(v_text(21),0);
            v_amtadj9 := nvl(v_text(22),0);
            v_amtadj10 := nvl(v_text(23),0);

            if  nvl(v_amtadj1,0) <> v_amtincom1 or nvl(v_amtadj2,0) <> v_amtincom2 or
                nvl(v_amtadj3,0) <> v_amtincom3 or nvl(v_amtadj4,0) <> v_amtincom4 or
                nvl(v_amtadj5,0) <> v_amtincom5 or nvl(v_amtadj6,0) <> v_amtincom6 or
                nvl(v_amtadj7,0) <> v_amtincom7 or nvl(v_amtadj8,0) <> v_amtincom8 or
                nvl(v_amtadj9,0) <> v_amtincom9 or nvl(v_amtadj10,0) <> v_amtincom10 then
                v_ttmovemt.flgadjin  := 'Y';
            else
                v_ttmovemt.flgadjin  := 'N';
            end if;

            if v_ttmovemt.flgadjin = 'Y' then

                v_amt1  := nvl(v_amtadj1,0) ;
                v_amt2  := nvl(v_amtadj2,0) ;
                v_amt3  := nvl(v_amtadj3,0) ;
                v_amt4  := nvl(v_amtadj4,0) ;
                v_amt5  := nvl(v_amtadj5,0) ;
                v_amt6  := nvl(v_amtadj6,0) ;
                v_amt7  := nvl(v_amtadj7,0) ;
                v_amt8  := nvl(v_amtadj8,0) ;
                v_amt9  := nvl(v_amtadj9,0) ;
                v_amt10 := nvl(v_amtadj10,0) ;

                v_amtadj1  := nvl(v_amt1,0) - v_amtincom1;
                v_amtadj2  := nvl(v_amt2,0) - v_amtincom2;
                v_amtadj3  := nvl(v_amt3,0) - v_amtincom3;
                v_amtadj4  := nvl(v_amt4,0) - v_amtincom4;
                v_amtadj5  := nvl(v_amt5,0) - v_amtincom5;
                v_amtadj6  := nvl(v_amt6,0) - v_amtincom6;
                v_amtadj7  := nvl(v_amt7,0) - v_amtincom7;
                v_amtadj8  := nvl(v_amt8,0) - v_amtincom8;
                v_amtadj9  := nvl(v_amt9,0) - v_amtincom9;
                v_amtadj10 := nvl(v_amt10,0) - v_amtincom10;

            end if;

            for r_ttmovemt in c_ttmovemt loop
                v_exist   := true;
                if  nvl(r_ttmovemt.codcomp,'!@#') 	= nvl(upper(v_ttmovemt.codcomp),nvl(r_ttmovemt.codcomp,'!@#'))    	 and
                    nvl(r_ttmovemt.codpos,'!@#') 	= nvl(upper(v_ttmovemt.codpos),nvl(r_ttmovemt.codpos,'!@#'))    	 and
                    nvl(r_ttmovemt.codjob,'!@#') 	= nvl(upper(v_ttmovemt.codjob),nvl(r_ttmovemt.codjob,'!@#'))    	 and
                    nvl(r_ttmovemt.numlvl,'999') 	= nvl(v_ttmovemt.numlvl,nvl(r_ttmovemt.numlvl,'999'))           	 and
                    nvl(r_ttmovemt.codempmt,'#') 	= nvl(upper(v_ttmovemt.codempmt),nvl(r_ttmovemt.codempmt,'#'))  	 and
                    nvl(r_ttmovemt.typpayroll,'#')  = nvl(upper(v_ttmovemt.typpayroll),nvl(r_ttmovemt.typpayroll,'#'))   and
                    nvl(r_ttmovemt.typemp,'#')	    = nvl(upper(v_ttmovemt.typemp),nvl(r_ttmovemt.typemp,'#'))           and
                    nvl(r_ttmovemt.codbrlc,'!@#') 	= nvl(upper(v_ttmovemt.codbrlc),nvl(r_ttmovemt.codbrlc,'!@#'))  	 and
                    nvl(r_ttmovemt.codcalen,'!@#')  = nvl(upper(v_ttmovemt.codcalen),nvl(r_ttmovemt.codcalen,'!@#')) 	 and
                    nvl(r_ttmovemt.flgatten,'#')    = nvl(upper(v_ttmovemt.flgatten),nvl(r_ttmovemt.flgatten,'#')) 	     and				 
                    nvl(r_ttmovemt.amtincom1,0)	    = nvl(v_amt1,nvl(r_ttmovemt.amtincom1,0))   and
                    nvl(r_ttmovemt.amtincom2,0)	    = nvl(v_amt2,nvl(r_ttmovemt.amtincom2,0))   and  
                    nvl(r_ttmovemt.amtincom3,0)	    = nvl(v_amt3,nvl(r_ttmovemt.amtincom3,0))   and  
                    nvl(r_ttmovemt.amtincom4,0)	    = nvl(v_amt4,nvl(r_ttmovemt.amtincom4,0))   and  
                    nvl(r_ttmovemt.amtincom5,0)	    = nvl(v_amt5,nvl(r_ttmovemt.amtincom5,0))   and  
                    nvl(r_ttmovemt.amtincom6,0)	    = nvl(v_amt6,nvl(r_ttmovemt.amtincom6,0))   and  
                    nvl(r_ttmovemt.amtincom7,0)	    = nvl(v_amt7,nvl(r_ttmovemt.amtincom7,0))   and  
                    nvl(r_ttmovemt.amtincom8,0)	    = nvl(v_amt8,nvl(r_ttmovemt.amtincom8,0))   and  
                    nvl(r_ttmovemt.amtincom9,0)	    = nvl(v_amt9,nvl(r_ttmovemt.amtincom9,0))   and  
                    nvl(r_ttmovemt.amtincom10,0)    = nvl(v_amt10,nvl(r_ttmovemt.amtincom10,0)) then

                    v_flgchg := 'N';
                else
                    v_flgchg := 'Y' ;
                end if;
                v_seq := r_ttmovemt.numseq;           
                exit;
            end loop;

            if not v_exist or v_flgchg = 'Y' then

                v_sumhur	  := 0; v_sumday	  := 0; v_summth	  := 0;			
                get_wage_income (upper(substr(v_ttmovemt.codcomp,1,3)),upper(v_ttmovemt.codempmt),
                                   nvl(v_amt1,0),nvl(v_amt2,0),nvl(v_amt3,0),nvl(v_amt4,0),nvl(v_amt5,0),
                                   nvl(v_amt6,0),nvl(v_amt7,0),nvl(v_amt8,0),nvl(v_amt9,0),nvl(v_amt10,0),
                                   v_sumhur,v_sumday,v_summth);	

                v_amtothr := nvl(v_sumhur,0);

                if upper(nvl(v_ttmovemt.flgadjin,'N')) = 'Y'  then
                    v_ttmovemt.amtincom1  		:= stdenc(nvl(v_amt1,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom2  		:= stdenc(nvl(v_amt2,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom3  		:= stdenc(nvl(v_amt3,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom4  		:= stdenc(nvl(v_amt4,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom5  		:= stdenc(nvl(v_amt5,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom6  		:= stdenc(nvl(v_amt6,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom7  		:= stdenc(nvl(v_amt7,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom8  		:= stdenc(nvl(v_amt8,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom9  		:= stdenc(nvl(v_amt9,0),v_codempid,v_chken);
                    v_ttmovemt.amtincom10 		:= stdenc(nvl(v_amt10,0),v_codempid,v_chken);
                    v_ttmovemt.amtothr 		    := stdenc(nvl(v_amtothr,0),v_codempid,v_chken);

                    v_ttmovemt.amtincadj1  		:= stdenc(nvl(v_amtadj1,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj2  		:= stdenc(nvl(v_amtadj2,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj3  		:= stdenc(nvl(v_amtadj3,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj4  		:= stdenc(nvl(v_amtadj4,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj5  		:= stdenc(nvl(v_amtadj5,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj6  		:= stdenc(nvl(v_amtadj6,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj7  		:= stdenc(nvl(v_amtadj7,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj8  		:= stdenc(nvl(v_amtadj8,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj9  		:= stdenc(nvl(v_amtadj9,0),v_codempid,v_chken);
                    v_ttmovemt.amtincadj10 		:= stdenc(nvl(v_amtadj10,0),v_codempid,v_chken);

                else
                    v_ttmovemt.amtincadj1 := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj2  := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj3 := stdenc(0,v_codempid,v_chken); 
                    v_ttmovemt.amtincadj4 := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj5  := stdenc(0,v_codempid,v_chken);
                    v_ttmovemt.amtincadj6 := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj7  := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj8 := stdenc(0,v_codempid,v_chken); 
                    v_ttmovemt.amtincadj9 := stdenc(0,v_codempid,v_chken); v_ttmovemt.amtincadj10 := stdenc(0,v_codempid,v_chken);
                end if;		

                if nvl(v_staupd,'U') = 'U' then
                    tm_numseq := 0;
                    begin
                        select max(numseq) into tm_numseq
                          from ttmovemt
                         where codempid  = v_codempid
                           and dteeffec  = v_ttmovemt.dteeffec;
                    exception when no_data_found then
                        tm_numseq := 0;
                    end;
                    tm_numseq := nvl(tm_numseq,0) + 1;

                    insert into ttmovemt (codempid,dteeffec,numseq,
                                          codtrn,codcomp,codpos,
                                          codjob,numlvl,codbrlc,
                                          codempmt,typpayroll,typemp,
                                          codcalen,flgatten,stapost2,
                                          codcompt,codposnow,codjobt,
                                          numlvlt,codbrlct,codempmtt,
                                          typpayrolt,typempt,codcalet,
                                          flgattet,amtincom1,amtincom2,
                                          amtincom3,amtincom4,amtincom5,
                                          amtincom6,amtincom7,amtincom8,
                                          amtincom9,amtincom10,amtincadj1,
                                          amtincadj2,amtincadj3,amtincadj4,
                                          amtincadj5,amtincadj6,amtincadj7,
                                          amtincadj8,amtincadj9,amtincadj10,
                                          codedlv,codsex,staupd,
                                          amtothr,codcurr,flgadjin,
                                          numreqst,desnote,jobgrade,
                                          codgrpgl,jobgradet,codgrpglt,
                                          codcreate,coduser                                     
                                          )
                            values       (v_codempid,v_ttmovemt.dteeffec,tm_numseq,
                                          upper(v_ttmovemt.codtrn),upper(v_ttmovemt.codcomp),upper(v_ttmovemt.codpos),
                                          upper(v_ttmovemt.codjob),v_ttmovemt.numlvl,upper(v_ttmovemt.codbrlc),
                                          upper(v_ttmovemt.codempmt),upper(v_ttmovemt.typpayroll),v_ttmovemt.typemp,
                                          upper(v_ttmovemt.codcalen),upper(v_ttmovemt.flgatten),nvl(v_ttmovemt.stapost2,'0'),
                                          v_codcompt,v_codposnow,v_codjobt,
                                          v_numlvlt,v_codbrlct,v_codempmtt,
                                          v_typpayrolt,v_typempt,v_codcalet,
                                          v_flgattet,v_ttmovemt.amtincom1,v_ttmovemt.amtincom2,
                                          v_ttmovemt.amtincom3,v_ttmovemt.amtincom4,v_ttmovemt.amtincom5,
                                          v_ttmovemt.amtincom6,v_ttmovemt.amtincom7,v_ttmovemt.amtincom8,
                                          v_ttmovemt.amtincom9,v_ttmovemt.amtincom10,v_ttmovemt.amtincadj1,
                                          v_ttmovemt.amtincadj2,v_ttmovemt.amtincadj3,v_ttmovemt.amtincadj4,
                                          v_ttmovemt.amtincadj5,v_ttmovemt.amtincadj6,v_ttmovemt.amtincadj7,
                                          v_ttmovemt.amtincadj8,v_ttmovemt.amtincadj9,v_ttmovemt.amtincadj10,
                                          v_codedlv,v_codsex,'C',
                                          v_ttmovemt.amtothr,v_ttmovemt.codcurr,upper(nvl(v_ttmovemt.flgadjin,'N')),
                                          v_ttmovemt.numreqst,v_ttmovemt.desnote,v_ttmovemt.jobgrade,
                                          v_ttmovemt.codgrpgl,v_jobgradet,v_codgrpglt,
                                          p_coduser,p_coduser
                                          );

                    begin
                        select numseq into v_seqpminf
                          from ttpminf
                         where codempid  = v_codempid
                           and dteeffec  = v_ttmovemt.dteeffec
                           and codtrn    = v_ttmovemt.codtrn
                           and numseq    = tm_numseq
                           and rownum    = 1;
                    exception when no_data_found then 
                        v_seqpminf := null;
                    end ;

                    --create data to table 'ttpminf'
                    if  v_seqpminf is null then

                        insert into ttpminf(codempid,dteeffec,numseq,
                                            codtrn,codcomp,codpos,
                                            codjob,numlvl,codempmt,
                                            codcalen,codbrlc,typpayroll,
                                            typemp,flgatten,flgal,
                                            flgrp,flgap,flgbf,
                                            flgtr,flgpy,staemp,
                                            coduser)
                              values       (v_codempid,v_ttmovemt.dteeffec,tm_numseq,
                                            v_ttmovemt.codtrn,v_ttmovemt.codcompt,v_ttmovemt.codposnow,
                                            v_ttmovemt.codjobt,v_ttmovemt.numlvlt,v_ttmovemt.codempmtt,
                                            v_ttmovemt.codcalet,v_ttmovemt.codbrlct,v_ttmovemt.typpayrolt,
                                            v_ttmovemt.typempt,v_ttmovemt.flgattet,'N',
                                            'N','N','N',
                                            'N','N',v_staemp,
                                            p_coduser);
                    else
                        update ttpminf set 	codcomp    = v_ttmovemt.codcompt,
                                            codpos     = v_ttmovemt.codposnow,
                                            codjob     = v_ttmovemt.codjobt,
                                            numlvl     = v_ttmovemt.numlvlt,
                                            codempmt   = v_ttmovemt.codempmtt,
                                            codcalen   = v_ttmovemt.codcalet,
                                            codbrlc    = v_ttmovemt.codbrlct,
                                            typpayroll = v_ttmovemt.typpayrolt,
                                            typemp     = v_ttmovemt.typempt,
                                            flgatten   = v_ttmovemt.flgattet ,
                                            staemp     = v_staemp ,
                                            flgal      = 'N',
                                            flgrp      = 'N',
                                            flgap      = 'N',
                                            flgbf      = 'N',
                                            flgtr      = 'N',
                                            flgpy      = 'N',
                                            coduser    = p_coduser
                        where codempid  = v_codempid
                          and dteeffec  = v_ttmovemt.dteeffec 
                          and codtrn    = v_ttmovemt.codtrn;
                    end if;

                else		
                    update ttmovemt set codtrn      = upper(v_ttmovemt.codtrn),
                                        codcomp 	= upper(v_ttmovemt.codcomp),
                                        codpos		= upper(v_ttmovemt.codpos),
                                        codjob		= upper(v_ttmovemt.codjob),
                                        codbrlc 	= upper(v_ttmovemt.codbrlc),
                                        codempmt    = upper(v_ttmovemt.codempmt),
                                        typpayroll  = upper(v_ttmovemt.typpayroll),
                                        typemp 		= upper(v_ttmovemt.typemp),	
                                        numlvl 		= v_ttmovemt.numlvl, 
                                        codcalen 	= upper(v_ttmovemt.codcalen),
                                        jobgrade	= upper(v_ttmovemt.jobgrade),
                                        codgrpgl	= upper(v_ttmovemt.codgrpgl), 
                                        flgatten    = upper(v_ttmovemt.flgatten),
                                        stapost2 	= upper(v_ttmovemt.stapost2),
                                        flgadjin 	= upper(v_ttmovemt.flgadjin),
                                        amtincom1   = v_ttmovemt.amtincom1,
                                        amtincom2   = v_ttmovemt.amtincom2,
                                        amtincom3   = v_ttmovemt.amtincom3,
                                        amtincom4   = v_ttmovemt.amtincom4,
                                        amtincom5   = v_ttmovemt.amtincom5,
                                        amtincom6   = v_ttmovemt.amtincom6,
                                        amtincom7   = v_ttmovemt.amtincom7,
                                        amtincom8   = v_ttmovemt.amtincom8,
                                        amtincom9   = v_ttmovemt.amtincom9,
                                        amtincom10  = v_ttmovemt.amtincom10,
                                        amtincadj1  = v_ttmovemt.amtincadj1,
                                        amtincadj2  = v_ttmovemt.amtincadj2,
                                        amtincadj3  = v_ttmovemt.amtincadj3,
                                        amtincadj4  = v_ttmovemt.amtincadj4,
                                        amtincadj5  = v_ttmovemt.amtincadj5,
                                        amtincadj6  = v_ttmovemt.amtincadj6,
                                        amtincadj7  = v_ttmovemt.amtincadj7,
                                        amtincadj8  = v_ttmovemt.amtincadj8,
                                        amtincadj9  = v_ttmovemt.amtincadj9,
                                        amtincadj10 = v_ttmovemt.amtincadj10,
                                        amtothr 	= v_ttmovemt.amtothr,
                                        codcurr 	= v_ttmovemt.codcurr,	
                                        coduser 	= p_coduser
                        where codempid = v_codempid
                          and dteeffec = v_ttmovemt.dteeffec
                          and codtrn   = v_ttmovemt.codtrn
                          and numseq   = nvl(v_seq,1);
                end if;
                hrpm91b_batch.process_movement(null,trunc(sysdate),p_coduser,v_ttmovemt.codempid,v_ttmovemt.dteeffec,v_ttmovemt.codtrn,v_sum,v_err,v_secur,v_errsecur);
            end if;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttmovemt.codempid,v_codcomp,to_char(v_ttmovemt.dteeffec,'dd/mm/yyyy'),v_ttmovemt.codtrn,null,null,null,null,null,'Y',v_remark);           
        end if;

    end;


    procedure import_termination_data ( p_namefile   in varchar2,
                                        p_data       in varchar2,
                                        p_typyear    in varchar2,
                                        p_dteimpt    in varchar2,
                                        p_lang       in varchar2,
                                        p_error      in out varchar2,
                                        p_record     in number,
                                        p_coduser    in varchar2) is

        v_codempid      temploy1.codempid%type;
        v_remark        varchar2(500 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 7;
        v_exist		  	boolean;	
        v_flgpass		boolean;
        v_tenum         varchar2(200 char); 
        v_flgerrb       varchar2(1 char);
        v_flgchg        varchar2(1 char) := 'N';
        v_numerr        number := 0;

        v_ttexempt      ttexempt%rowtype;
        v_codtrn        varchar2(4 char) := '0006';
        v_codcomp   	ttexempt.codcomp%type;
        v_codpos    	ttexempt.codpos%type;
        v_codjob    	ttexempt.codjob%type;
        v_codempmt  	ttexempt.codempmt%type;
        v_numlvl    	temploy1.numlvl%type;
        v_codsex    	ttexempt.codsex%type;
        v_codedlv   	ttexempt.codedlv%type;
        v_staemp    	temploy1.staemp%type;
        v_qtywkday  	number;
        v_dteempmt  	date;
        v_flgatten		temploy1.flgatten%type;
        v_codcalen		temploy1.codcalen%type;
        v_codbrlc		temploy1.codbrlc%type;
        v_typpayroll	temploy1.typpayroll%type;
        v_typemp		temploy1.typemp%type;
        v_typemprq      temploy1.staemp%type;
        v_jobgrade      temploy1.jobgrade%type;
        v_codgrpgl      temploy1.codgrpgl%type;
        v_staupd        varchar2(4 char);

        v_totwkday 		number;
        v_amtincom1 	temploy3.amtincom1%type;
        v_amtincom2 	temploy3.amtincom1%type;
        v_amtincom3 	temploy3.amtincom1%type;
        v_amtincom4 	temploy3.amtincom1%type;
        v_amtincom5 	temploy3.amtincom1%type;
        v_amtincom6 	temploy3.amtincom1%type;
        v_amtincom7 	temploy3.amtincom1%type;
        v_amtincom8 	temploy3.amtincom1%type;
        v_amtincom9 	temploy3.amtincom1%type;
        v_amtincom10 	temploy3.amtincom1%type;
        v_amtsalt       temploy3.amtincom1%type;
        v_amtotht 		temploy3.amtincom1%type;
        v_amtothtn 		temploy3.amtincom1%type;
        v_seqpminf      number := 0;
        v_numdata       number := 0;

        v_maxperiod     varchar2(10 char);
        v_minperiod     varchar2(10 char);  
        v_fildname      varchar2(100 char);  
        v_sum           number ;
        v_err           number ;
        v_secur         number;
        v_errsecur      number;


        type descol is table of varchar2(4000 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_ttexempt is
            select dteeffec
              from ttexempt
             where codempid  = v_codempid
               and dteeffec  = v_ttexempt.dteeffec;

    begin
        for i in 1..100 loop
            v_remarkerr(i)  := null;
            v_namfild(i)    := null;
            v_sapcode(i)    := null;
        end loop;
        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;				
            v_ttexempt  := null;
            v_numerr    := 0;

            if v_text(1) is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2045',p_lang);
            else
                v_codempid  := upper(substr(v_text(1),1,10));
                v_ttexempt.codempid := v_codempid;                
            end if;

            if v_codempid is not null then
                begin
                    select codcomp,codpos,codjob,codempmt,numlvl,
                           codsex,codedlv,staemp,qtywkday,dteempmt,
                           flgatten,codcalen,codbrlc,typpayroll,typemp,
                           jobgrade,codgrpgl
                      into v_codcomp,v_codpos,v_codjob,v_codempmt,v_numlvl,
                           v_codsex,v_codedlv,v_staemp,v_qtywkday,v_dteempmt,
                           v_flgatten,v_codcalen,v_codbrlc,v_typpayroll,v_typemp,
                           v_jobgrade,v_codgrpgl
                      from temploy1
                     where codempid = v_codempid;
                exception when no_data_found then
                    v_codcomp := null;
                    v_codpos  := null;
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2010',p_lang)||' (TEMPLOY1)';
                end;

                if v_staemp = '9' then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2101',p_lang);
                end if;

                begin
                    select stddec(amtincom1,codempid,v_chken),stddec(amtincom2,codempid,v_chken),stddec(amtincom3,codempid,v_chken),stddec(amtincom4,codempid,v_chken),stddec(amtincom5,codempid,v_chken),
                           stddec(amtincom6,codempid,v_chken),stddec(amtincom7,codempid,v_chken),stddec(amtincom8,codempid,v_chken),stddec(amtincom9,codempid,v_chken),stddec(amtincom10,codempid,v_chken)
                      into v_amtincom1,v_amtincom2,v_amtincom3,v_amtincom4,v_amtincom5,
                           v_amtincom6,v_amtincom7,v_amtincom8,v_amtincom9,v_amtincom10
                      from temploy3
                     where codempid = v_codempid;
                exception	when no_data_found then		
                    null;
                end;      
                v_ttexempt.codempid := v_codempid;      
            end if;

            v_ttexempt.codexemp := null; v_ttexempt.flgssm := null;	 v_ttexempt.codreq := null;		


            for i in 1..v_max loop
                -- check required field -----------------------------------------------   
                if i in (2,3,7) then
                    if v_text(i) is null then
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('HR2045',p_lang);
                    end if;

                    if i = 2 and v_text(i) is not null then
                        v_error := check_date(v_text(i),p_typyear);
                        if v_error then	
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang);
                        end if;
                    end if;
                end if;
                -- check Lenght field ------------------------------------------------- 
                if i = 4 then
                    if length(v_text(i)) > 16 then 
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (16)';
                    end if;	                
                end if; 

                if i = 5 then
                    if length(v_text(i)) > 1000 then 
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (100)';
                    end if;	                
                end if;   

                --- check maping code
                if i in (3,6,7) then
                    v_error := false;
                    if i = 3 and v_text(i) is not null then
                        get_mapping_code('EX',v_text(i),v_ttexempt.codexemp,v_error);
                        v_fildname := 'CODEXEMP';
                    elsif i = 6 and v_text(i) is not null then
                        get_mapping_code('T1',v_text(i),v_ttexempt.flgblist,v_error);
                        v_fildname := 'FLGBLIST';
                    elsif i = 7 and v_text(i) is not null then
                        get_mapping_code('T2',v_text(i),v_ttexempt.flgssm,v_error);
                        v_fildname := 'FLGSSM';
                    end if;

                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                        v_namfild(v_numerr)     := v_fildname;
                        v_sapcode(v_numerr)     := v_text(i);
                    end if;

                    if i = 6 and v_ttexempt.flgblist is null then
                        get_default_data(p_typedata,'TTEXEMPT','FLGBLIST',v_ttexempt.flgblist);
                        if v_ttexempt.flgblist is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if; 
                    end if;

                end if;

            end loop; -- for i in 1..v_max loop

        exit cal_loop;
        end loop;

        v_ttexempt.dteeffec  := check_dteyre(v_text(2),p_typyear); 
        if to_date(to_char(v_ttexempt.dteeffec,'dd/mm/yyyy'),'dd/mm/yyyy') < to_date(to_char(v_dteempmt,'dd/mm/yyyy'),'dd/mm/yyyy')  then
            v_numerr  := v_numerr + 1;
            v_remarkerr(v_numerr)	:= get_errorm_name('PM0035',p_lang);
        end if;	

        if v_numerr = 0 then

            begin
                select max(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'))
                  into v_maxperiod
                  from ttaxcur
                 where codempid   = v_ttexempt.codempid;
            exception when no_data_found then
                v_maxperiod := null; 
            end;

            begin
                select min(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'))
                  into v_minperiod
                  from tdtepay
                 where codcompy	   = hcm_util.get_codcomp_level(v_codcomp,1)
                   and typpayroll  = v_typpayroll
                   and v_ttexempt.dteeffec  <= dteend ;
            exception when no_data_found then
                v_minperiod := null; 
            end;

            if v_maxperiod is not null and v_minperiod is not null then
                 if v_maxperiod >= v_minperiod then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= get_errorm_name('PY0072',p_lang);
                end if;
            end if;


            v_staupd := null;
            begin
                select staupd into v_staupd
                 from ttexempt
                where codempid  = v_codempid
                  and dteeffec  = v_ttexempt.dteeffec;
            exception when no_data_found then
                v_staupd := null;
            end;

            if v_staupd = 'U' then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PMZ010',p_lang);    
            end if;

        end if;

        ---insert for data error
        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;   
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttexempt.codempid,v_codcomp,to_char(v_ttexempt.dteeffec,'dd/mm/yyyy'),null,v_ttexempt.codexemp,null,null,null,null,'N',v_remark);           
        else

            if nvl(v_staupd,'N') <> 'U' then
                v_ttexempt.dteeffec  := null;
                if v_text(2) is not null then
                    v_ttexempt.dteeffec  := check_dteyre(v_text(2),p_typyear); 
               end if;	

                v_exist   := false;

                v_amtsalt	         := round(v_amtincom1,2);

                v_amtotht 		     := nvl(v_amtincom2,0) + nvl(v_amtincom3,0) + nvl(v_amtincom4,0) + nvl(v_amtincom5,0)
                                      + nvl(v_amtincom6,0) + nvl(v_amtincom7,0) + nvl(v_amtincom8,0) + nvl(v_amtincom9,0)+ nvl(v_amtincom10,0);

                v_totwkday 		    := (v_ttexempt.dteeffec - v_dteempmt) + v_qtywkday;
                v_ttexempt.numexemp := v_text(4);
                v_ttexempt.desnote  := v_text(5);

                begin
                    select numseq into v_seqpminf
                      from ttpminf
                     where codempid  = v_codempid
                       and dteeffec  = v_ttexempt.dteeffec
                       and codtrn    = v_codtrn;
                exception when no_data_found then 
                    v_seqpminf := 1;
                end ;

                --create data to table 'ttpminf'
                if  v_seqpminf is null then

                    insert into ttpminf(codempid,dteeffec,numseq,
                                        codtrn,codcomp,codpos,
                                        codjob,numlvl,codempmt,
                                        codcalen,codbrlc,typpayroll,
                                        typemp,flgatten,flgal,
                                        flgrp,flgap,flgbf,
                                        flgtr,flgpy,staemp,
                                        coduser)
                          values       (v_codempid,v_ttexempt.dteeffec,1,
                                        v_codtrn,v_codcomp,v_codpos,
                                        v_codjob,v_numlvl,v_codempmt,
                                        v_codcalen,v_codbrlc,v_typpayroll,
                                        v_typemp,v_flgatten,'N',
                                        'N','N','N',
                                        'N','N',v_staemp,
                                        p_coduser);
                else
                    update ttpminf set 	codcomp    = v_codcomp,
                                        codpos     = v_codpos,
                                        codjob     = v_codjob,
                                        numlvl     = v_numlvl,
                                        codempmt   = v_codempmt,
                                        codcalen   = v_codcalen,
                                        codbrlc    = v_codbrlc,
                                        typpayroll = v_typpayroll,
                                        typemp     = v_typemp,
                                        flgatten   = v_flgatten ,
                                        staemp     = v_staemp ,
                                        flgal      = 'N',
                                        flgrp      = 'N',
                                        flgap      = 'N',
                                        flgbf      = 'N',
                                        flgtr      = 'N',
                                        flgpy      = 'N',
                                        coduser    = p_coduser
                    where codempid  = v_codempid
                      and dteeffec  = v_ttexempt.dteeffec +1
                      and codtrn    = v_codtrn;
                end if;

                v_exist   := false;
                for r_ttexempt in c_ttexempt loop
                    v_exist   := true;

                    update ttexempt set flgblist = nvl(upper(v_ttexempt.flgblist),'N'),
                                        codexemp = v_ttexempt.codexemp,
                                        flgssm   = upper(v_ttexempt.flgssm),
                                        desnote  = v_ttexempt.desnote,
                                        coduser  = p_coduser
                    where codempid = v_codempid
                      and dteeffec = r_ttexempt.dteeffec;

                end loop;

                if not v_exist then
                    insert into ttexempt (codempid,dteeffec,codexemp,
                                          codcomp,codjob,codpos,
                                          codempmt,numlvl,desnote,
                                          amtsalt,amtotht,codsex,
                                          codedlv,totwkday,flgblist,
                                          flgssm,staupd,numexemp,
                                          codreq,codcreate,coduser)
                          values        (v_ttexempt.codempid,v_ttexempt.dteeffec,v_ttexempt.codexemp,
                                         v_codcomp,v_codjob,v_codpos,
                                         v_codempmt,v_numlvl,v_ttexempt.desnote,
                                         stdenc(nvl(v_amtsalt,0),v_codempid,v_chken),stdenc(nvl(v_amtotht,0),v_codempid,v_chken),v_codsex,
                                         v_codedlv,v_totwkday,nvl(upper(v_ttexempt.flgblist),'N'),
                                         upper(v_ttexempt.flgssm),'C',v_ttexempt.numexemp,
                                         v_ttexempt.codreq,p_coduser,p_coduser);   
                end if;
                hrpm91b_batch.process_movement(null,trunc(sysdate),p_coduser,v_ttexempt.codempid,v_ttexempt.dteeffec,v_codtrn,v_sum,v_err,v_secur,v_errsecur);
            end if;  
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttexempt.codempid,v_codcomp,to_char(v_ttexempt.dteeffec,'dd/mm/yyyy'),null,v_ttexempt.codexemp,null,null,null,null,'Y',v_remark);           
        end if;

    end;

    procedure import_rehire_data (  p_namefile   in varchar2,
                                    p_data       in varchar2,
                                    p_typyear    in varchar2,
                                    p_dteimpt    in varchar2,
                                    p_lang       in varchar2,
                                    p_error      in out varchar2,
                                    p_record     in number,
                                    p_coduser    in varchar2) is

        v_codempid      temploy1.codempid%type;
        v_remark        varchar2(500 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 30;
        v_exist		  	boolean;	
        v_flgpass		boolean;
        v_tenum         varchar2(200 char); 
        v_flgerrb       varchar2(1 char);
        v_flgchg        varchar2(1 char) := 'N';
        v_numerr        number := 0;
        v_statrans      varchar2(10 char);        

        v_ttrehire      ttrehire%rowtype;
        v_codtrn        varchar2(15 char):= '0002' ;
        v_codcomp       temploy1.codcomp%type;
        v_codpos        temploy1.codpos%type;
        v_codbrlc       temploy1.codbrlc%type;
        v_codempmt      temploy1.codempmt%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_staemp        temploy1.staemp%type;
        v_typemp	    temploy1.typemp%type;
        v_codcalen      temploy1.codcalen%type;
        v_codjob        temploy1.codjob%type;
        v_numlvl    	temploy1.numlvl%type;
        v_flgatten      temploy1.flgatten%type;
        v_jobgrade      temploy1.jobgrade%type;
        v_codgrpgl      temploy1.codgrpgl%type;
        v_dteeffex      temploy1.dteeffex%type;
        v_sumhur		number := 0;
        v_sumday		number := 0;
        v_summth		number := 0;
        v_staupd        varchar2(1 char);
        v_amtothr       temploy3.amtincom1%type;
        v_codnewid      temploy1.codempid%type;

        v_maxperiod     varchar2(10 char);
        v_minperiod     varchar2(10 char);  
        v_fildname      varchar2(100 char);  
        v_sum           number ;
        v_err           number ;
        v_secur         number;
        v_errsecur      number;
        v_seqpminf      number;

        type descol is table of varchar2(4000 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_ttrehire is
            select *
              from ttrehire
             where codempid  = v_ttrehire.codempid
              and dtereemp   = v_ttrehire.dtereemp;

        cursor c_temploy1 is
            select a.codempid
              from temploy1 a,temploy3 b
             where a.codempid = v_ttrehire.codempid
               and a.codempid = b.codempid 
            order by staemp ;

    begin
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;				
            v_ttrehire  := null;	

            if v_text(1) is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2045',p_lang);
            else
                v_codempid  := upper(substr(v_text(1),1,10));
                v_ttrehire.codempid := v_codempid;                   
            end if;

            if v_ttrehire.codempid is not null then
                begin
                    select codcomp,codpos,staemp,codbrlc,codempmt,
                           typpayroll,typemp,codcalen,codjob,numlvl,
                           flgatten,dteeffex,jobgrade,codgrpgl,a.codempid
                      into v_codcomp,v_codpos,v_staemp,v_codbrlc,v_codempmt,
                           v_typpayroll,v_typemp,v_codcalen,v_codjob,v_numlvl,
                           v_flgatten,v_dteeffex,v_jobgrade,v_codgrpgl,v_ttrehire.codempid
                      from temploy1 a,temploy3 b
                     where a.codempid = v_codempid
                       and a.codempid = b.codempid(+)
                       and rownum = 1 ;
                exception when no_data_found then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr) := 1||' - '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
                end ;
                if v_staemp <> '9' then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR7595',p_lang);
                end if;   
                if v_staemp = '0' then
                    v_numerr  := v_numerr + 1;
                    v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2102',p_lang);
                end if;
            end if;

           for i in 1..v_max loop
                -- check required field -----------------------------------------------   
                if i in (2,3,5,6,7,8) then--,9,10,11,12,13,14,16) then
                    if v_text(i) is null then
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('HR2045',p_lang);
                    end if;

                    if i = 3 and v_text(i) is not null then
                        v_error := check_date(v_text(i),p_typyear);
                        if v_error then	
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang);
                        end if;
                    end if;

                end if;

                -- check Lenght field ------------------------------------------------- 
                if i = 4 and v_text(i) is not null then
                    if length(v_text(i)) > 15 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (15)';
                    end if;	                
                end if; 

                if i = 29 and v_text(i) is not null then
                    if length(v_text(i)) > 25 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (25)';
                    end if;	                
                end if; 

                if i = 30 and v_text(i) is not null then
                    if length(v_text(i)) > 50 then 
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (50)';
                    end if;	                
                end if; 

                if i = 15 and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm000');
                        if length(v_tenum) > 3 then

                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (3)';
                        end if;
                    end if;
                end if;   

                if i = 17 and v_text(i) is not null then
                    v_error := check_date(v_text(i),p_typyear);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= get_errorm_name('PMZ005',p_lang);
                    end if;
                end if;

                if i in (18,19,20,21,22,23,24,25,26,27) and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm0000000.00');
                        if length(v_tenum) > 10 then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
                        end if;
                    end if;
                end if;   

                --- check maping code
                if i in (5,6,7,8,9,10,11,12,13,14,28) then
                    v_error := false;
                    if i = 5 and v_text(i) is not null then
                        get_mapping_code('E1',v_text(i),v_ttrehire.codcomp,v_error);
                        v_fildname := 'CODCOMP';
                    elsif i = 6 and v_text(i) is not null then
                        get_mapping_code('E2',v_text(i),v_ttrehire.codpos,v_error);
                        v_fildname := 'CODPOS';
                    elsif i = 7 and v_text(i) is not null then
                        get_mapping_code('LO',v_text(i),v_ttrehire.codbrlc,v_error);
                        v_fildname := 'CODBRLC';
                    elsif i = 8 and v_text(i) is not null then
                        get_mapping_code('TE',v_text(i),v_ttrehire.codempmt,v_error);
                        v_fildname := 'CODEMPMT';
                    elsif i = 9 and v_text(i) is not null then
                        get_mapping_code('PY',v_text(i),v_ttrehire.typpayroll,v_error);
                        v_fildname := 'TYPPAYROLL';
                    elsif i = 10 and v_text(i) is not null then
                        get_mapping_code('CG',v_text(i),v_ttrehire.typemp,v_error);
                        v_fildname := 'TYPEMP';                        
                    elsif i = 11 and v_text(i) is not null then
                        get_mapping_code('GR',v_text(i),v_ttrehire.codcalen,v_error);
                        v_fildname := 'CODCALEN';    
                    elsif i = 12 and v_text(i) is not null then
                        get_mapping_code('E3',v_text(i),v_ttrehire.codjob,v_error);
                        v_fildname := 'CODJOB';   
                    elsif i = 13 and v_text(i) is not null then
                        get_mapping_code('E4',v_text(i),v_ttrehire.flgatten,v_error);
                        v_fildname := 'FLGATTEN';   
                    elsif i = 14 and v_text(i) is not null then
                        get_mapping_code('R1',v_text(i),v_ttrehire.flgreemp,v_error);
                        v_fildname := 'FLGREEMP';   
                    elsif i = 16 and v_text(i) is not null then
                        get_mapping_code('A5',v_text(i),v_ttrehire.staemp,v_error);
                        v_fildname := 'STAEMP';   
                    elsif i = 28 and v_text(i) is not null then
                        get_mapping_code('CR',v_text(i),v_ttrehire.codcurr,v_error);
                        v_fildname := 'CODCURR'; 
                    end if;

                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang)||' ('||v_text(i)||')' ;
                        v_namfild(v_numerr)     := v_fildname;
                        v_sapcode(v_numerr)     := v_text(i);
                    end if;

                    if i = 9 and v_ttrehire.typpayroll is null then
                        get_default_data(p_typedata,'TTREHIRE','TYPPAYROLL',v_ttrehire.typpayroll);
                        if v_ttrehire.typpayroll is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 10 and v_ttrehire.typemp is null then
                        get_default_data(p_typedata,'TTREHIRE','TYPEMP',v_ttrehire.typemp);
                        if v_ttrehire.typemp is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 11 and v_ttrehire.codcalen is null then
                        get_default_data(p_typedata,'TTREHIRE','CODCALEN',v_ttrehire.codcalen);
                        if v_ttrehire.codcalen is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 12 and v_ttrehire.codjob is null then
                        get_default_data(p_typedata,'TTREHIRE','CODJOB',v_ttrehire.codjob);
                        if v_ttrehire.codjob is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 13 and v_ttrehire.flgatten is null then
                        get_default_data(p_typedata,'TTREHIRE','FLGATTEN',v_ttrehire.flgatten);
                        if v_ttrehire.flgatten is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);		           
                        end if;
                    elsif i = 14 and v_ttrehire.flgreemp is null then
                        get_default_data(p_typedata,'TTREHIRE','FLGREEMP',v_ttrehire.flgreemp);
                        if v_ttrehire.flgreemp is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);	
                        end if;
                    elsif i = 16 and v_ttrehire.staemp is null then
                        get_default_data(p_typedata,'TTREHIRE','STAEMP',v_ttrehire.staemp);
                        if v_ttrehire.staemp is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);	
                        end if;
                    elsif i = 28 and v_ttrehire.codcurr is null then
                        get_default_data(p_typedata,'TTREHIRE','CODCURR',v_ttrehire.codcurr);
                        if v_ttrehire.codcurr is null then
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ007',p_lang);
                        end if;
                    end if;

                end if;

            end loop; -- for i in 1..v_max loop

        exit cal_loop;
        end loop;

        if v_numerr = 0 then
            v_ttrehire.dtereemp  := check_dteyre(v_text(3),p_typyear); 
            v_ttrehire.numreqst  := v_text(4); 
            --v_ttrehire.qtydatrq  := v_text(15); 
            if v_text(17) is not null then
                v_ttrehire.dteduepr  := check_dteyre(v_text(17),p_typyear); 
            end if;
            --v_ttrehire.numtelof  := v_text(29); 
            --v_ttrehire.email     := v_text(30); 

            begin
                select staupd into v_staupd
                  from ttrehire
                 where codempid = v_ttrehire.codempid
                   and dtereemp = v_ttrehire.dtereemp;
            exception when no_data_found then
                v_staupd := null;
            end;

            if v_ttrehire.dtereemp < v_dteeffex then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr) := get_errorm_name('PMZ012',p_lang);
            end if; 

            if nvl(v_staupd,'N') = 'U' then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr) := get_errorm_name('PMZ010',p_lang);
            end if;

        end if;

       ---insert for data error
        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;    
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttrehire.codempid,v_codcomp,to_char(v_ttrehire.dtereemp,'dd/mm/yyyy'),null,null,null,null,null,null,'N',v_remark);          
        else
            v_remark   := null;

            v_ttrehire.staemp   := nvl(v_ttrehire.staemp,'3');
            v_ttrehire.amtothr  := null;

            v_sumhur	  := 0; v_sumday	  := 0; v_summth	  := 0;
            get_wage_income(b_var_codcompy,upper(v_ttrehire.codempmt),
                            nvl(v_text(18),0), nvl(v_text(19),0) ,
                            nvl(v_text(20),0), nvl(v_text(21),0) ,
                            nvl(v_text(22),0), nvl(v_text(23),0) ,
                            nvl(v_text(24),0), nvl(v_text(25),0) ,
                            nvl(v_text(26),0), nvl(v_text(27),0),
                            v_sumhur ,v_sumday,v_summth );

            v_ttrehire.amtincom1 := stdenc(nvl(v_text(18),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom2 := stdenc(nvl(v_text(19),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom3 := stdenc(nvl(v_text(20),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom4 := stdenc(nvl(v_text(21),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom5 := stdenc(nvl(v_text(22),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom6 := stdenc(nvl(v_text(23),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom7 := stdenc(nvl(v_text(24),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom8 := stdenc(nvl(v_text(25),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom9 := stdenc(nvl(v_text(26),0),v_ttrehire.codempid,v_chken);
            v_ttrehire.amtincom10 := stdenc(nvl(v_text(27),0),v_ttrehire.codempid,v_chken);
            v_amtothr := stdenc(nvl(v_sumhur,0),v_ttrehire.codempid,v_chken);


            begin
                select numseq into v_seqpminf
                  from ttpminf
                 where codempid  = v_codempid
                   and dteeffec  = v_ttrehire.dtereemp
                   and codtrn    = v_codtrn;
            exception when no_data_found then 
                v_seqpminf := 1;
            end ;

            --create data to table 'ttpminf'
            if  v_seqpminf is null then

                insert into ttpminf(codempid,dteeffec,numseq,
                                    codtrn,codcomp,codpos,
                                    codjob,numlvl,codempmt,
                                    codcalen,codbrlc,typpayroll,
                                    typemp,flgatten,flgal,
                                    flgrp,flgap,flgbf,
                                    flgtr,flgpy,staemp,
                                    coduser)
                      values       (v_codempid,v_ttrehire.dtereemp,1,
                                    v_codtrn,v_codcomp,v_codpos,
                                    v_codjob,v_numlvl,v_codempmt,
                                    v_codcalen,v_codbrlc,v_typpayroll,
                                    v_typemp,v_flgatten,'N',
                                    'N','N','N',
                                    'N','N',v_staemp,
                                    p_coduser);
            else
                update ttpminf set 	codcomp    = v_codcomp,
                                    codpos     = v_codpos,
                                    codjob     = v_codjob,
                                    numlvl     = v_numlvl,
                                    codempmt   = v_codempmt,
                                    codcalen   = v_codcalen,
                                    codbrlc    = v_codbrlc,
                                    typpayroll = v_typpayroll,
                                    typemp     = v_typemp,
                                    flgatten   = v_flgatten ,
                                    staemp     = v_staemp ,
                                    flgal      = 'N',
                                    flgrp      = 'N',
                                    flgap      = 'N',
                                    flgbf      = 'N',
                                    flgtr      = 'N',
                                    flgpy      = 'N',
                                    coduser    = p_coduser
                where codempid  = v_codempid
                  and dteeffec  = v_ttrehire.dtereemp
                  and codtrn    = v_codtrn;
            end if;

            v_exist   := false;
            for r_ttrehire in c_ttrehire loop
                v_exist   := true;
                update ttrehire set numreqst    = v_ttrehire.numreqst,
                                    codcomp     = v_ttrehire.codcomp,
                                    codpos      = v_ttrehire.codpos,
                                    flgreemp    = v_ttrehire.flgreemp,
                                    codnewid    = v_ttrehire.codempid,
                                    staemp      = v_ttrehire.staemp,
                                    codempmt    = v_ttrehire.codempmt,
                                    typpayroll  = v_ttrehire.typpayroll,
                                    codcalen    = v_ttrehire.codcalen,
                                    codjob      = v_ttrehire.codjob,
                                    typemp      = v_ttrehire.typemp,
                                    jobgrade    = v_ttrehire.jobgrade,
                                    codgrpgl    = v_ttrehire.codgrpgl,
                                    numlvl      = v_ttrehire.numlvl,
                                    flgatten    = v_ttrehire.flgatten,
                                    codcurr     = v_ttrehire.codcurr,
                                    amtincom1   = v_ttrehire.amtincom1,
                                    amtincom2   = v_ttrehire.amtincom2,
                                    amtincom3   = v_ttrehire.amtincom3,
                                    amtincom4   = v_ttrehire.amtincom4,
                                    amtincom5   = v_ttrehire.amtincom5,
                                    amtincom6   = v_ttrehire.amtincom6,
                                    amtincom7   = v_ttrehire.amtincom7,
                                    amtincom8   = v_ttrehire.amtincom8,
                                    amtincom9   = v_ttrehire.amtincom9,
                                    amtincom10  = v_ttrehire.amtincom10,
                                    amtothr     = v_ttrehire.amtothr,
                                    coduser     = p_coduser
                        where codempid = v_ttrehire.codempid
                          and dtereemp = v_ttrehire.dtereemp;

            end loop;

            if not v_exist then
                insert into ttrehire (codempid,dtereemp,numreqst,
                                      codcomp,codpos,flgreemp,
                                      codnewid,dteduepr,staemp,
                                      codbrlc,codempmt,typpayroll,
                                      codcalen,codjob,typemp,
                                      jobgrade,codgrpgl,numlvl,
                                      flgatten,codcurr,amtincom1,
                                      amtincom2,amtincom3,amtincom4,
                                      amtincom5,amtincom6,amtincom7,
                                      amtincom8,amtincom9,amtincom10,
                                      amtothr,staupd,flgmove,
                                      codcreate,coduser)
                values               (v_ttrehire.codempid,v_ttrehire.dtereemp,v_ttrehire.numreqst,
                                      v_ttrehire.codcomp,v_ttrehire.codpos,v_ttrehire.flgreemp,
                                      v_ttrehire.codnewid,v_ttrehire.dteduepr,v_ttrehire.staemp,
                                      v_ttrehire.codbrlc,v_ttrehire.codempmt,v_ttrehire.typpayroll,
                                      v_ttrehire.codcalen,v_ttrehire.codjob,v_ttrehire.typemp,
                                      v_ttrehire.jobgrade,v_ttrehire.codgrpgl,v_ttrehire.numlvl,
                                      v_ttrehire.flgatten,v_ttrehire.codcurr,v_ttrehire.amtincom1,
                                      v_ttrehire.amtincom2,v_ttrehire.amtincom3,v_ttrehire.amtincom4,
                                      v_ttrehire.amtincom5,v_ttrehire.amtincom6,v_ttrehire.amtincom7,
                                      v_ttrehire.amtincom8,v_ttrehire.amtincom9,v_ttrehire.amtincom10,
                                      v_ttrehire.amtothr,'C','R',
                                      p_coduser,p_coduser);
            end if;

            hrpm91b_batch.process_movement(null,trunc(sysdate),p_coduser,v_ttrehire.codempid,v_ttrehire.dtereemp,v_codtrn,v_sum,v_err,v_secur,v_errsecur);

            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_ttrehire.codempid,v_codcomp,to_char(v_ttrehire.dtereemp,'dd/mm/yyyy'),null,null,null,null,null,null,'Y',v_remark);  
        end if;
    end;


    procedure import_othincome_data (  p_namefile   in varchar2,
                                       p_data       in varchar2,
                                       p_typyear    in varchar2,
                                       p_dteimpt    in varchar2,
                                       p_lang       in varchar2,
                                       p_error      in out varchar2,
                                       p_record     in number,
                                       p_coduser    in varchar2) is

        v_codcompy      tcenter.codcompy%type;
        v_codempid      temploy1.codempid%type;
        v_codpos        temploy1.codpos%type;
        v_codcomp  	    temploy1.codcomp%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_staemp        temploy1.staemp%type;
        v_numlvl        temploy1.numlvl%type;
        v_codjob        temploy1.codjob%type;
        v_codempmt      temploy1.codempmt%type;
        v_typemp        temploy1.typemp%type;
        v_codbrlc       temploy1.codbrlc%type;
        v_codcalen      temploy1.codcalen%type;
        v_jobgrade      temploy1.jobgrade%type;
        v_codgrpgl      temploy1.codgrpgl%type;
        v_dteempmt      date;
        v_dteeffex      date;
        v_namefile      varchar2(200 char) := p_namefile;
        v_dteimpt       varchar2(200 char) := p_dteimpt;
        v_chk           varchar2(1 char) := 'N';
        v_remark        varchar2(4000 char); 	
        v_total         number := 0;
        v_error			boolean;
        v_typcode       varchar2(2 char);
        v_max       	number:= 7;
        v_exist		  	boolean;	
        v_numerr        number := 0;
        v_tenum         number;

        v_tothinc       tothinc%rowtype;    
        v_numseq        number := 0;
        v_dtestrt       date;
        v_dteend        date;
        v_dtepaymt      date;
        v_dtepayimp     date;
        v_dteyrepay     number;
        v_dtemthpay     number;
        v_numperiod     number;        
        v_amthour       number;
        v_amtday        number;
        v_amtmth        number;
        v_prevperiod    varchar2(15);
        v_maxperiod     varchar2(15);        
        v_codpaypy5     tcontrpy.codpaypy5%type;
        v_costcent      tcenter.costcent%type;
        v_dtemovemt     date := trunc(sysdate);

        type descol is table of varchar2(2500 char) index by binary_integer;
            v_remarkerr   descol;
            v_namfild     descol;
            v_sapcode     descol;

        cursor c_tothinc_ud is
            select codcompw, qtypayda, qtypayhr, qtypaysc, stddec(amtpay,codempid,v_chken) amtpay, codsys
              from tothinc2
             where codempid	    = v_tothinc.codempid
               and dteyrepay	= (v_tothinc.dteyrepay - global_v_zyear)
               and dtemthpay	= v_tothinc.dtemthpay
               and numperiod	= v_tothinc.numperiod
               and codpay		= v_tothinc.codpay
               and codcompw     = v_codcomp;

    begin
        v_numerr    := 0;
        for i in 1..100 loop
            v_remarkerr(i) := null;
            v_namfild(i)   := null;
            v_sapcode(i)   := null;
        end loop;
        v_tothinc := null;

        v_codempid  := upper(substr(v_text(1),1,10));
        v_tothinc.codempid := v_codempid;

        if  v_text(1) is null then
            v_error   := true;
            v_numerr  :=  + v_numerr + 1;
            v_remarkerr(v_numerr)	:=  1||' - '||get_errorm_name('HR2045',p_lang); 
        else

            begin
                select dteempmt,dteeffex,codpos,typpayroll,staemp,numlvl,
                       codjob,codempmt,typemp,codbrlc,codcalen,codcomp,
                       jobgrade,codgrpgl
                  into v_dteempmt,v_dteeffex,v_codpos,v_typpayroll,v_staemp,v_numlvl,
                       v_codjob,v_codempmt,v_typemp,v_codbrlc,v_codcalen,v_codcomp,
                       v_jobgrade,v_codgrpgl
                  from temploy1
                 where codempid = v_codempid ;
                 v_codcompy := hcm_util.get_codcomp_level(v_codcomp,'1');
            exception when no_data_found then
                null;
            end;

            begin
                select codcomp,typpayroll,dteempmt,staemp,typemp
                  into v_codcomp,v_typpayroll,v_dteempmt,v_staemp,v_typemp
                  from temploy1 a,temploy3 b
                 where a.codempid = v_codempid
                   and a.codempid = b.codempid(+)
                   and rownum = 1 ;
                   v_codcompy := hcm_util.get_codcomp_level(v_codcomp,'1');
            exception when no_data_found then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr) := 1||' - '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
            end ;   

            if v_staemp = '9' then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= 1||' - '||get_errorm_name('HR2101',p_lang);
            end if;

        end if;   

        <<cal_loop>>
        loop
            v_error     := false;
            v_remark    := null;			

            for i in 1..v_max loop
                if  v_text(i) is null then
                    v_error   := true;
                    v_numerr  :=  + v_numerr + 1;
                    v_remarkerr(v_numerr)	:=  i||' - '||get_errorm_name('HR2045',p_lang); 
                end if;   

                if i  in (3,4) then
                    if length(v_text(i)) > 2 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (2)';
                    end if;   
                end if;

                if i  = 5 then
                    if length(v_text(i)) > 4 then 
                      v_error   := true;
                      v_numerr  := v_numerr + 1;
                      v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ002',p_lang)||' (4)';
                    end if;   
                end if;

                if i = 7 and v_text(i) is not null then
                    v_error := check_date(v_text(i),v_zyear);
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)	:= i||' - '||get_errorm_name('PMZ005',p_lang); 
                    end if;                   
                end if;

                if i = 6 and v_text(i) is not null then
                    v_error := check_number(v_text(i));
                    if v_error then	
                        v_error   := true;
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ006',p_lang);
                    else    
                        v_tenum := null;
                        v_tenum := to_char(to_number(v_text(i)),'fm0000000.00');
                        if length(v_tenum) > 10 then
                            v_error   := true;
                            v_numerr  := v_numerr + 1;
                            v_remarkerr(v_numerr)  := i||' - '||get_errorm_name('PMZ002',p_lang)||' (10)';
                        end if;
                    end if;                
                end if;

                if i = 2 and v_text(i) is not null then
                    get_mapping_code('A6',v_text(i),v_tothinc.codpay,v_error);
                    if v_error then	
                        v_numerr  := v_numerr + 1;
                        v_remarkerr(v_numerr)   := i||' - '||get_errorm_name('PMZ003',p_lang);		
                        v_namfild(v_numerr)     := 'CODPAY';
                        v_sapcode(v_numerr)     := v_text(i);
                    end if; 
                end if;

            end loop;

        exit cal_loop;
        end loop;

        if v_numerr = 0 then
            v_tothinc.numperiod := v_text(3);
            v_tothinc.dtemthpay := v_text(4);
            v_tothinc.dteyrepay := v_text(5);
            v_dtepayimp := check_dteyre(v_text(7),v_zyear); 

            begin
                select codpay
                  into v_tothinc.codpay
                  from tinexinfc 
                 where codcompy  = v_codcompy
                   and codpay    = v_tothinc.codpay;
            exception when no_data_found then	
                v_tothinc.codpay := null;
            end;
            if v_tothinc.codpay is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PY0044',global_v_lang);
            end if;

            begin
                select dtestrt,dteend,dtepaymt into v_dtestrt,v_dteend,v_dtepaymt
                  from tdtepay
                 where codcompy   = v_codcompy
                   and typpayroll = v_typpayroll
                   and numperiod  = v_tothinc.numperiod
                   and dtemthpay  = v_tothinc.dtemthpay
                   and dteyrepay  = v_tothinc.dteyrepay;
            exception when no_data_found then
                v_dtestrt := null;
            end;  

            if v_dtepaymt is not null and v_dtepaymt < trunc(sysdate) then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PMZ013',global_v_lang);
            end if;

            if v_dtestrt is null then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('HR2010',global_v_lang)||' (TDTEPAY)';
            end if;   

            begin
                select max(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0')) into v_maxperiod
                  from tdtepay
                 where codcompy   = v_codcompy
                   and typpayroll = v_typpayroll
                   and flgcal     = 'Y';
            exception when no_data_found then
                v_maxperiod := null;
            end;

            if  (v_tothinc.dteyrepay||lpad(v_tothinc.dtemthpay,2,'0')||lpad(v_tothinc.numperiod,2,'0')) < v_maxperiod then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PMZ014',global_v_lang);                
            end if;

            begin
                select codpaypy5 into v_codpaypy5
                  from tcontrpy
                 where codcompy = v_codcompy
                   and dteeffec = (select max(dteeffec)
                                    from tcontrpy
                                   where codcompy = v_codcompy
                                     and dteeffec <= sysdate);
            exception when no_data_found then 
                null;
            end;

            if v_tothinc.codpay = v_codpaypy5 then
                v_numerr  := v_numerr + 1;
                v_remarkerr(v_numerr)	:= get_errorm_name('PY0019',global_v_lang);
            end if;

        end if;

        if v_numerr > 0 then
            p_error   := 'Y';

            for i in 1..v_numerr loop
                if i = 1 then
                    v_remark := v_remarkerr(i);
                else
                    v_remark := substr(v_remark||','||v_remarkerr(i),1,4000);
                end if;   
                if v_namfild(i) is not null then
                    insert_tmapcode(v_namfild(i),v_sapcode(i));	
                end if;
            end loop;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tothinc.codempid,v_codcomp,null,null,null,null,null,null,null,'N',v_remark);           
        else
            v_exist   := false; 
            v_tothinc.amtpay := v_text(6);

            begin
                select costcent into v_costcent from tcenter where codcomp = v_codcomp;
            exception when no_data_found then
                v_costcent := null;
            end;

            std_al.get_movemt(v_codempid,v_dtepayimp,'C','C',v_codcomp,
                              v_codpos,v_numlvl,v_codjob,v_codempmt,v_typemp,
                              v_typpayroll,v_codbrlc,v_codcalen,v_jobgrade,v_codgrpgl,
                              v_amthour,v_amtday,v_amtmth);

            if v_tothinc.amtpay <> 0 then

                begin
                    insert into tothinc(codempid,dteyrepay,dtemthpay,
                                        numperiod,codpay,codcomp,
                                        typpayroll,typemp,ratepay,
                                        amtpay,codsys,costcent,
                                        codcreate,coduser)

                    values             (v_tothinc.codempid,v_tothinc.dteyrepay,v_tothinc.dtemthpay,
                                        v_tothinc.numperiod,v_tothinc.codpay,v_codcomp,
                                        v_typpayroll,v_typemp,stdenc(v_amtday,v_tothinc.codempid,v_chken),
                                        stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),'PY',v_costcent,
                                        global_v_coduser,global_v_coduser);

                exception when dup_val_on_index then
                    update tothinc set  codcomp     = v_codcomp,
                                        typpayroll  = v_typpayroll,
                                        typemp      = v_typemp,
                                        amtpay      = stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),
                                        coduser     = global_v_coduser
                    where  codempid  = v_tothinc.codempid
                      and  dteyrepay = v_tothinc.dteyrepay
                      and  dtemthpay = v_tothinc.dtemthpay
                      and  numperiod = v_tothinc.numperiod
                      and  codpay    = v_tothinc.codpay ;
                end;

                for r1 in c_tothinc_ud loop
                    v_exist := true;

                    if r1.codcompw != v_codcomp or r1.codcompw is null then
                        v_numseq := v_numseq + 1;
                        insert into tlogothinc (numseq,codempid,dteyrepay,
                                                dtemthpay,numperiod,codpay,
                                                codcomp,desfld,desold,
                                                desnew,codcreate,coduser)
                        values                 (v_numseq,v_tothinc.codempid,v_tothinc.dteyrepay,
                                                v_tothinc.dtemthpay,v_tothinc.numperiod,v_tothinc.codpay,
                                                v_codcomp,'CODCOMPW',r1.codcompw,
                                                v_codcomp,global_v_coduser,global_v_coduser);                    
                    end if;

                    if nvl(r1.amtpay,0) <> v_tothinc.amtpay then
                        v_numseq := v_numseq + 1;
                        insert into tlogothinc (numseq,codempid,dteyrepay,
                                                dtemthpay,numperiod,codpay,
                                                codcomp,desfld,desold,
                                                desnew,codcreate,coduser)
                        values                 (v_numseq,v_tothinc.codempid,v_tothinc.dteyrepay,
                                                v_tothinc.dtemthpay,v_tothinc.numperiod,v_tothinc.codpay,
                                                v_codcomp,'AMTPAY',stdenc(r1.amtpay,v_tothinc.codempid,v_chken),
                                                stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),global_v_coduser,global_v_coduser);    
                    end if;


                    update tothinc2 set codcompw   = v_codcomp,
                                        amtpay     = stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),
                                        costcent   = v_costcent,
                                        coduser    = global_v_coduser,
                                        codcreate  = global_v_coduser
                    where  codempid  = v_tothinc.codempid
                      and  dteyrepay = v_tothinc.dteyrepay
                      and  dtemthpay = v_tothinc.dtemthpay
                      and  numperiod = v_tothinc.numperiod
                      and  codpay    = v_tothinc.codpay 
                      and  codcompw  = v_codcomp;

                end loop;

                if not v_exist then
                    v_numseq := v_numseq+1;
                    begin
                        insert into tlogothinc (numseq,codempid,dteyrepay,
                                                dtemthpay,numperiod,codpay,
                                                codcomp,desfld,desold,
                                                desnew,codcreate,coduser)
                        values                 (v_numseq,v_tothinc.codempid,v_tothinc.dteyrepay,
                                                v_tothinc.dtemthpay,v_tothinc.numperiod,v_tothinc.codpay,
                                                v_codcomp,'AMTPAY',null,
                                                stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),global_v_coduser,global_v_coduser);
                    end;

                    insert into tothinc2 (codempid,dteyrepay,dtemthpay,
                                          numperiod,codpay,codcompw,
                                          amtpay,costcent,codsys,
                                          codcreate, coduser)

                    values               (v_tothinc.codempid,v_tothinc.dteyrepay,v_tothinc.dtemthpay,
                                          v_tothinc.numperiod,v_tothinc.codpay,v_codcomp,
                                          stdenc(v_tothinc.amtpay,v_tothinc.codempid,v_chken),v_costcent,'PY',
                                          global_v_coduser,global_v_coduser);

                end if;

            end if;
            insert_timpfiles(p_typedata,p_dteimpt,p_record,p_namefile,p_data,v_tothinc.codempid,v_codcomp,null,null,null,null,null,null,null,'Y',v_remark); 
        end if;
    end;

    procedure insert_timpfiles (p_typedata  in varchar2,
                                p_dteimpt   in varchar2,
                                p_numseq    in number,
                                p_namefile  in varchar2,
                                p_datafile  in varchar2,                             
                                p_codempid  in varchar2,
                                p_codcomp   in varchar2,
                                p_dteeffec  in varchar2,
                                p_codtrn    in varchar2,
                                p_codexemp  in varchar2,
                                p_dteyrepay in number,
                                p_dtemthpay in number,
                                p_numperiod in number,
                                p_codpay    in varchar2,
                                p_status    in varchar2,
                                p_remarks   in varchar2) is

        v_count       number := 0;
        v_remarks     varchar2(4000 char);

    begin
        v_count := 0;
        begin
            select count(*) into v_count
              from timpfiles
             where typedata = p_typedata
               and dteimpt  = to_date(p_dteimpt,'dd/mm/yyyy hh24miss')
               and numseq   = nvl(p_numseq,1);
        exception when no_data_found then
            v_count := 0;
        end;
        if p_status = 'N' then
            v_remarks := p_codempid||'-'||replace(p_remarks,'@#$%400','');
        else
            v_remarks := replace(p_remarks,'@#$%400','');
        end if;
        --ประเภทข้อมูล (ประเภทข้อมูล 10 - ข้อมูลส่วนตัว, 20 - ข้อมูลบุตร, 30 - ข้อมูลการศึกษา, 40 - ข้อมูลประสบการณ์ทำงาน, 50 - ข้อมูลเคลื่อนไหว, 60 - ข้อมูลพ้นสภาพ, 70 – ข้อมูลกลับเข้าทำงานใหม่, 80 - ข้อมูลรายได้อื่นๆ )
        if v_count = 0 then
            insert into timpfiles ( typedata,dteimpt,numseq,
                                    namefile,datafile,codempid,
                                    codcomp,dteeffec,codtrn,
                                    codexemp,dteyrepay,dtemthpay,
                                    numperiod,codpay,status,
                                    remark)
                   values         ( p_typedata,to_date(p_dteimpt,'dd/mm/yyyy hh24miss'),p_numseq,
                                    p_namefile,p_datafile,p_codempid,
                                    p_codcomp,to_date(p_dteeffec,'dd/mm/yyyy'),p_codtrn,
                                    p_codexemp,p_dteyrepay,p_dtemthpay,
                                    p_numperiod,p_codpay,p_status,
                                    v_remarks);
        else
            update timpfiles set codempid   = p_codempid,
                                 codcomp    = p_codcomp,
                                 dteeffec   = to_date(p_dteeffec,'dd/mm/yyyy'),
                                 codtrn     = p_codtrn,
                                 codexemp   = p_codexemp,
                                 dteyrepay  = p_dteyrepay,
                                 dtemthpay  = p_dtemthpay,
                                 numperiod  = p_numperiod,
                                 codpay     = p_codpay,
                                 datafile   = p_datafile,
                                 status     = p_status,
                                 remark     = v_remarks
                 where typedata = p_typedata
                   and dteimpt  = to_date(p_dteimpt,'dd/mm/yyyy hh24miss')
                   and numseq   = p_numseq;
        end if;
    end;

    function get_comments_column (p_tablename in varchar2,p_namefield in varchar2) return varchar2 is
        v_comments      varchar2(4000 char);
    begin
        begin
            select comments into v_comments
             from user_col_comments
            where table_name  = p_tablename
              and column_name = p_namefield;    	
        exception when others then
            v_comments := null ;
        end ;
        return v_comments;
    end;

    function check_dteyre (p_date in varchar2,p_zyear in varchar2) return varchar2 is
        v_date		date;
        v_error		boolean := false;
        v_year      number;
        v_daymon	varchar2(30);
        v_mon       varchar2(30 char);
        v_day       varchar2(30 char);
        v_text		varchar2(30);
    begin

        if p_date is not null then
            -- plus year --
            v_year			:= substr(p_date,-4,4);
            v_year			:= v_year + p_zyear;	
            v_day           := substr(p_date,1,length(p_date)-8);
            v_mon           := substr(p_date,length(v_day)+2,2);                
            v_daymon        := v_day||'/'||v_mon||'/';
            v_text			:= v_daymon||to_char(v_year);	       
            v_year          := null; 
            v_daymon        := null;
            -- plus year --
            v_date          := to_date(v_text,'dd/mm/yyyy');
        end if;

        return(v_date);
    end;

    function check_date (p_date in varchar2, p_zyear in number)   return boolean is

        v_date      date;
        v_error     boolean := false;
        v_year    	number;
        v_daymon    varchar2(30 char);
        v_mon       varchar2(30 char);
        v_day       varchar2(30 char);
        v_text      varchar2(30 char);

    begin
            if p_date is not null then

                begin
                    v_date  := to_date(p_date,'dd/mm/yyyy');
                    v_error := false;
                exception when others then
                    v_error := true;
                end;

                if length(p_date) <> 10 then 
                    v_error := true;
                end if;

                if not v_error then 
                    -- plus year --
                    v_year      := substr(p_date,-4,4);
                    v_year      := v_year + p_zyear;    
                    v_day       := substr(p_date,1,length(p_date)-8);
                    v_mon       := substr(p_date,length(v_day)+2,2);    
                    v_daymon    := v_day||'/'||v_mon||'/';
                    v_text      := v_daymon||to_char(v_year);    
                    v_year      := null; 
                    v_daymon    := null;
                    -- plus year --

                    begin
                        v_date  := to_date(v_text,'dd/mm/yyyy');
                        v_error := false;
                    exception when others then
                        v_error := true;
                    end;    
                end if;
            end if;

        return(v_error);
    end;

    function check_number (p_number in varchar2) return boolean is    
        v_number     number;
        v_error        boolean := false;
    begin
        if p_number is not null then
            begin
                v_number := to_number(p_number);            
                v_error  := false;
            exception when others then
                v_error := true;
            end;    
        end if;
        return(v_error);
    end;

    procedure upd_log1(p_codempid   in varchar2,
                       p_codtable   in varchar2,
                       p_numpage    in varchar2,
                       p_fldedit    in varchar2,
                       p_typdata    in varchar2,
                       p_desold     in varchar2,
                       p_desnew     in varchar2,
                       p_flgenc     in varchar2,
                       p_codcomp    in varchar2,
                       p_coduser    in varchar2) is

        v_exist     boolean := false;


        cursor c_ttemlog1 is
            select rowid
              from ttemlog1
             where codempid = p_codempid
               and dteedit  = sysdate
               and numpage  = p_numpage
               and fldedit  = upper(p_fldedit);

    begin
        if (p_desold is null and p_desnew is not null) or
           (p_desold is not null and p_desnew is null) or
           (p_desold <> p_desnew) then
           for r_ttemlog1 in c_ttemlog1 loop
                v_exist := true;
                update ttemlog1
                set    codcomp  = p_codcomp,
                       desold   = p_desold,
                       desnew   = p_desnew,
                       flgenc   = p_flgenc,
                       codtable = upper(p_codtable),
                       dteupd   = trunc(sysdate),
                       coduser  = p_coduser
                where  rowid = r_ttemlog1.rowid;
           end loop;
                if not v_exist then
                    insert into  ttemlog1
                                        (
                                         codempid,dteedit,numpage,
                                         fldedit,codcomp,desold,
                                         desnew,flgenc,codtable,
                                         dteupd,coduser
                                         )
                            values
                                        (
                                         p_codempid,sysdate,p_numpage,
                                         upper(p_fldedit),p_codcomp,p_desold,
                                         p_desnew,p_flgenc,upper(p_codtable),
                                         trunc(sysdate),p_coduser
                                         );
                end if;
        end if;
    end;

    procedure upd_log2(p_codempid   in varchar2,
                       p_codtable   in varchar2,
                       p_numpage    in varchar2,
                       p_numseq     in number,
                       p_fldedit    in varchar2,
                       p_typkey     in varchar2,
                       p_fldkey     in varchar2,
                       p_codseq     in varchar2,
                       p_dteseq     in varchar2,
                       p_typdata    in varchar2,
                       p_desold     in varchar2,
                       p_desnew     in varchar2,
                       p_flgenc     in varchar2,
                       p_codcomp    in varchar2,
                       p_coduser    in varchar2 ) is

        v_exist     boolean := false;

        cursor c_ttemlog2 is
          select rowid
            from ttemlog2
           where codempid   = p_codempid
             and dteedit    = sysdate
             and numpage    = p_numpage
             and numseq     = p_numseq
             and fldedit    = upper(p_fldedit);

    begin

        if (p_desold is null and p_desnew is not null) or
             (p_desold is not null and p_desnew is null) or
             (p_desold <> p_desnew) then
           for r_ttemlog2 in c_ttemlog2 loop
                v_exist := true;
                update ttemlog2
                set    typkey   = p_typkey,
                       fldkey   = upper(p_fldkey),
                       codseq   = p_codseq,
                       dteseq   = to_date(p_dteseq,'dd/mm/yyyy'),
                       codcomp  = p_codcomp,
                       desold   = p_desold,
                       desnew   = p_desnew,
                       flgenc   = p_flgenc,
                       codtable = upper(p_codtable),
                       dteupd   = trunc(sysdate),
                       coduser  = p_coduser
                where  rowid = r_ttemlog2.rowid;
           end loop;
                if not v_exist then
                    insert into  ttemlog2
                                        (
                                         codempid,dteedit,numpage,
                                         numseq,fldedit,codcomp,
                                         typkey,fldkey,codseq,
                                         dteseq,desold,desnew,
                                         flgenc,codtable,dteupd,
                                         coduser
                                         )
                    values
                                        (
                                         p_codempid,sysdate,p_numpage,
                                         p_numseq,upper(p_fldedit),p_codcomp,
                                         p_typkey,p_fldkey,p_codseq,
                                         to_date(p_dteseq,'dd/mm/yyyy'),p_desold,p_desnew,
                                         p_flgenc,upper(p_codtable),trunc(sysdate),
                                         p_coduser
                                         );
                end if;
        end if;

    end;

    procedure upd_log3(p_codempid   in varchar2,
                       p_codtable	in varchar2,
                       p_numpage 	in varchar2,
                       p_typdeduct 	in varchar2,
                       p_coddeduct 	in varchar2,
                       p_desold 	in varchar2,
                       p_desnew 	in varchar2,
                       p_codcomp    in varchar2,
                       p_upd	    in out boolean) is

        v_exist		boolean := false;

        cursor c_ttemlog3 is
            select rowid
              from ttemlog3
             where codempid  = p_codempid
               and dteedit	 = sysdate
               and numpage	 = p_numpage
               and typdeduct = p_typdeduct
               and coddeduct = p_coddeduct;
    begin
        if (p_desold is null and p_desnew is not null) or
            (p_desold is not null and p_desnew is null) or
            (p_desold <> p_desnew) then
            p_upd := true;
            for r_ttemlog3 in c_ttemlog3 loop
                v_exist := true;
                update ttemlog3 set codcomp     = p_codcomp,
                                    desold      = p_desold,
                                    desnew      = p_desnew,
                                    codtable    = upper(p_codtable),
                                    codcreate   = global_v_coduser,
                                    coduser     = global_v_coduser
                where  rowid = r_ttemlog3.rowid;
            end loop;
            if not v_exist then
                insert into  ttemlog3
                (codempid,dteedit,numpage,typdeduct,coddeduct,
                codcomp,desold,desnew,codtable,codcreate,coduser)
                values
                (p_codempid,sysdate,p_numpage,p_typdeduct,p_coddeduct,
                p_codcomp,p_desold,p_desnew,upper(p_codtable),global_v_coduser,global_v_coduser);
            end if;
        end if;
    end; -- end upd_log3


    function get_numappl(p_codempid varchar2) return varchar2 is
        v_numappl   temploy1.numappl%type;
    begin
        begin
            select nvl(numappl,codempid)
              into v_numappl
              from  temploy1
             where codempid = p_codempid;
        exception when no_data_found then
            v_numappl := p_codempid;
        end;
        return v_numappl;
    end; -- end get_numappl

    procedure upd_tempded (p_temploy1     temploy1%rowtype,p_coduser in varchar2) is

        v_amtdeduct         tempded.amtdeduct%type;
        v_codempid          temploy1.codempid%type;
        v_codcompy          tcompny.codcompy%type;
        v_amtdedect_dec     number;

        v_exist			    boolean;
        v_upd				boolean;
        v_dteyrepay	        number;
        v_coddeduct         tempded.coddeduct%type;
        v_amtspded          tempded.amtdeduct%type;
        v_typdata           varchar2(10 char);

        cursor c_tempded is
            select amtdeduct,amtspded,rowid
              from tempded
             where codempid  = p_temploy1.codempid
               and coddeduct = v_coddeduct;

        cursor c_tlastempd is
            select rowid
              from tlastempd
             where dteyrepay = v_dteyrepay
               and codempid  = p_temploy1.codempid
               and coddeduct = v_coddeduct;

        cursor c_tdeductd_e is
          select coddeduct,flgdef,amtdemax
            from tdeductd
           where dteyreff = (select max(dteyreff)
                               from tdeductd
                              where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                                and codcompy  = v_codcompy)
             and typdeduct   = 'E'
             and codcompy    = v_codcompy
             and coddeduct   <> 'E001'
          order by coddeduct;

        cursor c_tdeductd_d is
            select coddeduct,flgdef,amtdemax
              from tdeductd
             where dteyreff  = (select max(dteyreff)
                                  from tdeductd
                                 where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                                   and codcompy  = v_codcompy)
               and codcompy  = v_codcompy
               and typdeduct = 'D'
               and coddeduct not in ('D001','D002')
            order by coddeduct;

        cursor c_tdeductd_o is
            select coddeduct,flgdef,amtdemax
              from tdeductd
             where dteyreff  = (select max(dteyreff)
                                  from tdeductd
                                 where dteyreff <= to_number(to_char(sysdate,'yyyy')) - global_v_zyear
                                   and codcompy  = v_codcompy)
               and codcompy  = v_codcompy
               and typdeduct = 'O'
            order by coddeduct;

    begin
        begin
            select codempid,hcm_util.get_codcomp_level(codcomp,1)
              into v_codempid,v_codcompy
              from temploy1
             where codempid    = p_temploy1.codempid;
        exception when no_data_found then
            v_codempid  := '';
        end;
        v_dteyrepay     := to_number(to_char(sysdate,'yyyy')) - global_v_zyear;

        for k in 1..2 loop
            if k = 1 then
                v_typdata := 'E';
            else
                v_typdata := 'S';
            end if;

            for i in c_tdeductd_e loop
                if v_typdata = 'E' then
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        if i.flgdef = 'Y'  then
                            v_amtdedect_dec := i.amtdemax;
                        else
                            v_amtdedect_dec := 0;
                        end if;
                    end;
                else
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        v_amtdedect_dec   := 0;
                    end;                    
                end if;

                v_coddeduct := i.coddeduct;
                v_amtdeduct := stdenc(0,p_temploy1.codempid,v_chken);
                v_amtspded  := stdenc(0,p_temploy1.codempid,v_chken);

                if v_typdata = 'E' then
                    v_amtdeduct   := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                else
                    v_amtspded    := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                end if;

                v_exist := false;	v_upd := false;
                for i in c_tempded loop
                    v_exist := true;
                    if v_typdata = 'E' then
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtdeduct,v_amtdeduct,p_temploy1.codcomp,v_upd);
                        v_amtspded := i.amtspded;
                    else
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtspded,v_amtspded,p_temploy1.codcomp,v_upd);
                        v_amtdeduct := i.amtdeduct;
                    end if;
                    if v_upd then
                        update tempded set	amtdeduct = v_amtdeduct,
                                            amtspded  = v_amtspded,
                                            coduser   = global_v_coduser,
                                            codcreate = global_v_coduser
                        where rowid = i.rowid;
                    end if;
                end loop;

                if not v_exist then
                    v_upd := true;
                    insert into tempded (codempid,coddeduct,amtdeduct,
                                         amtspded,dteupd,coduser)
                    values              (p_temploy1.codempid,v_coddeduct,v_amtdeduct,
                                         v_amtspded,trunc(sysdate),global_v_coduser);
                end if;

                if v_upd or not v_exist then
                    v_exist := false;
                    for r_tlastempd in c_tlastempd loop
                        v_exist := true;
                        update tlastempd set codcomp   = p_temploy1.codcomp,
                                             amtdeduct = v_amtdeduct,
                                             amtspded  = v_amtspded,
                                             coduser   = global_v_coduser
                        where rowid = r_tlastempd.rowid;
                    end loop;

                    if not v_exist then
                        insert into tlastempd (dteyrepay,codempid,coddeduct,
                                               codcomp,amtdeduct,amtspded,
                                               codcreate,coduser)
                        values                (v_dteyrepay,p_temploy1.codempid,v_coddeduct,
                                               p_temploy1.codcomp,v_amtdeduct,v_amtspded,
                                               global_v_coduser,global_v_coduser);
                    end if;
                end if;            
            end loop;

            for i in c_tdeductd_d loop
                if v_typdata = 'E' then
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        if i.flgdef = 'Y'  then
                            v_amtdedect_dec := i.amtdemax;
                        else
                            v_amtdedect_dec := 0;
                        end if;
                    end;
                else
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        v_amtdedect_dec   := 0;
                    end;                    
                end if;

                v_coddeduct := i.coddeduct;
                v_amtdeduct := stdenc(0,p_temploy1.codempid,v_chken);
                v_amtspded  := stdenc(0,p_temploy1.codempid,v_chken);

                if v_typdata = 'E' then
                    v_amtdeduct   := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                else
                    v_amtspded    := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                end if;

                v_exist := false;	v_upd := false;
                for i in c_tempded loop
                    v_exist := true;
                    if v_typdata = 'E' then
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtdeduct,v_amtdeduct,p_temploy1.codcomp,v_upd);
                        v_amtspded := i.amtspded;
                    else
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtspded,v_amtspded,p_temploy1.codcomp,v_upd);
                        v_amtdeduct := i.amtdeduct;
                    end if;
                    if v_upd then
                        update tempded set	amtdeduct = v_amtdeduct,
                                            amtspded  = v_amtspded,
                                            coduser   = global_v_coduser,
                                            codcreate = global_v_coduser
                        where rowid = i.rowid;
                    end if;
                end loop;

                if not v_exist then
                    v_upd := true;
                    insert into tempded (codempid,coddeduct,amtdeduct,
                                         amtspded,dteupd,coduser)
                    values              (p_temploy1.codempid,v_coddeduct,v_amtdeduct,
                                         v_amtspded,trunc(sysdate),global_v_coduser);
                end if;

                if v_upd or not v_exist then
                    v_exist := false;
                    for r_tlastempd in c_tlastempd loop
                        v_exist := true;
                        update tlastempd set codcomp   = p_temploy1.codcomp,
                                             amtdeduct = v_amtdeduct,
                                             amtspded  = v_amtspded,
                                             coduser   = global_v_coduser
                        where rowid = r_tlastempd.rowid;
                    end loop;

                    if not v_exist then
                        insert into tlastempd (dteyrepay,codempid,coddeduct,
                                               codcomp,amtdeduct,amtspded,
                                               codcreate,coduser)
                        values                (v_dteyrepay,p_temploy1.codempid,v_coddeduct,
                                               p_temploy1.codcomp,v_amtdeduct,v_amtspded,
                                               global_v_coduser,global_v_coduser);
                    end if;
                end if;            
            end loop;

            for i in c_tdeductd_o loop
                if v_typdata = 'E' then
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        if i.flgdef = 'Y'  then
                            v_amtdedect_dec := i.amtdemax;
                        else
                            v_amtdedect_dec := 0;
                        end if;
                    end;
                else
                    begin
                        select amtspded into v_amtdeduct
                          from tempded
                         where codempid	  = p_temploy1.codempid
                           and coddeduct  = i.coddeduct;
                        v_amtdedect_dec   := stddec(v_amtdeduct,p_temploy1.codempid,v_chken);
                    exception when no_data_found then
                        v_amtdedect_dec   := 0;
                    end;                    
                end if;

                v_coddeduct := i.coddeduct;
                v_amtdeduct := stdenc(0,p_temploy1.codempid,v_chken);
                v_amtspded  := stdenc(0,p_temploy1.codempid,v_chken);

                if v_typdata = 'E' then
                    v_amtdeduct   := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                else
                    v_amtspded    := stdenc(nvl(v_amtdedect_dec,0),p_temploy1.codempid,v_chken);
                end if;

                v_exist := false;	v_upd := false;
                for i in c_tempded loop
                    v_exist := true;
                    if v_typdata = 'E' then
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtdeduct,v_amtdeduct,p_temploy1.codcomp,v_upd);
                        v_amtspded := i.amtspded;
                    else
                        upd_log3(p_temploy1.codempid,'tempded','163','E',v_coddeduct,i.amtspded,v_amtspded,p_temploy1.codcomp,v_upd);
                        v_amtdeduct := i.amtdeduct;
                    end if;
                    if v_upd then
                        update tempded set	amtdeduct = v_amtdeduct,
                                            amtspded  = v_amtspded,
                                            coduser   = global_v_coduser,
                                            codcreate = global_v_coduser
                        where rowid = i.rowid;
                    end if;
                end loop;

                if not v_exist then
                    v_upd := true;
                    insert into tempded (codempid,coddeduct,amtdeduct,
                                         amtspded,dteupd,coduser)
                    values              (p_temploy1.codempid,v_coddeduct,v_amtdeduct,
                                         v_amtspded,trunc(sysdate),global_v_coduser);
                end if;

                if v_upd or not v_exist then
                    v_exist := false;
                    for r_tlastempd in c_tlastempd loop
                        v_exist := true;
                        update tlastempd set codcomp   = p_temploy1.codcomp,
                                             amtdeduct = v_amtdeduct,
                                             amtspded  = v_amtspded,
                                             coduser   = global_v_coduser
                        where rowid = r_tlastempd.rowid;
                    end loop;

                    if not v_exist then
                        insert into tlastempd (dteyrepay,codempid,coddeduct,
                                               codcomp,amtdeduct,amtspded,
                                               codcreate,coduser)
                        values                (v_dteyrepay,p_temploy1.codempid,v_coddeduct,
                                               p_temploy1.codcomp,v_amtdeduct,v_amtspded,
                                               global_v_coduser,global_v_coduser);
                    end if;
                end if;            
            end loop;            

        end loop; --k

    end;

end m_hrpmz2b_20240129;

/

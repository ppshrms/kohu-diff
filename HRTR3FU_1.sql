--------------------------------------------------------
--  DDL for Package Body HRTR3FU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR3FU" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj            := json(json_str_input);
        global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codcompy          := upper(hcm_util.get_string(json_obj,'codcompy'));
        p_year              := hcm_util.get_string(json_obj,'year');
        p_codcours          := hcm_util.get_string(json_obj,'codcours');

    end initial_value;

    procedure gen_index(json_str_output out clob) as
      obj_rows            json;
      obj_data            json;
      v_row               number := 0;
      v_secure_true       number := 0;
      p_check             varchar2(6);
      v_response          long;
      v_approveno         number;

      cursor c1 is
        select approvno,codcours,codcate,plancond,codtparg,qtyptpln,qtyptbdg,amtpbdg,amtclbdg,codrespn,
               staappr,dteappr ----
          from tyrtrpln a
         where a.dteyear  = p_year
           and a.codcompy = p_codcompy
           and (a.staappr <> 'Y' or a.staappr is null)
      order by a.codcours;

    begin
      obj_rows := json();
      for i in c1 loop
        v_row           := v_row + 1;
        v_approveno     := nvl(i.approvno,0) + 1;
        if chk_flowmail.check_approve( 'HRTR34E', i.CODRESPN, v_approveno, global_v_codempid,null, null, p_check) = true then
          v_secure_true := v_secure_true + 1;
          obj_data := json();

          obj_data.put('amtpbdg',i.amtpbdg);
          obj_data.put('amtclbdg',i.amtclbdg);
          obj_data.put('approvno',i.approvno);
          obj_data.put('approvnoD',i.approvno);
          obj_data.put('codcate',i.codcate);
          obj_data.put('desc_codcate',get_tcodec_name('TCODCATE', i.codcate,global_v_lang));
          obj_data.put('codcours',i.codcours);
          obj_data.put('desc_codcours',get_tcourse_name(i.codcours,global_v_lang));
          obj_data.put('codtparg',i.codtparg);
          obj_data.put('desc_codtparg',get_tlistval_name('CODTPARG', i.codtparg,global_v_lang));
          obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
          obj_data.put('plancond',i.plancond);
          obj_data.put('desc_plancond',get_tlistval_name('STACOURS',i.plancond,global_v_lang));
          obj_data.put('qtyptbdg',i.qtyptbdg);
          obj_data.put('qtyptpln',i.qtyptpln);
          obj_data.put('staappr',i.staappr);
          obj_data.put('desc_staappr',get_tlistval_name('ESSTAREQ', i.staappr,global_v_lang));
          obj_rows.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
      if v_secure_true = 0 and v_row > 0 then
        param_msg_error := get_error_msg_php('HR3008',global_v_lang);
        return;
      end if;
      if v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TYRTRPLN');
        return;
      else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
      end if;
    end gen_index;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_year is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
              from TCOMPNY
             where codcompy like p_codcompy
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

    end check_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    procedure check_detail as
        v_temp varchar2(1 char);
        v_has_codemp BOOLEAN := false;
    begin
        if p_year is null or p_codcours is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

    end check_detail;

    procedure gen_detail(json_str_output out clob) as
        obj_result      json;
        obj_rows        json;
        obj_data        json;
        v_row           number := 0;
        v_secure_true   number := 0;
        p_check         varchar2(6);
        v_approveno     number;

        cursor c1 is
            select approvno,codcours,codcate,plancond,codtparg,qtyptpln,qtyptbdg,amtpbdg,amtclbdg,amttot,codhotel,codinsts,qtynumcl,codrespn
              from TYRTRPLN a
             where a.dteyear = p_year
               and a.codcompy = p_codcompy
               and ( a.staappr <> 'Y' or  a.staappr is null)
               and a.codcours = p_codcours;
    begin

        obj_rows := json();
        for i in c1 loop
            v_row           := v_row+1;
            v_approveno     := nvl(i.approvno,0)+1;
            if chk_flowmail.check_approve( 'HRTR34E', i.CODRESPN, v_approveno,global_v_codempid ,null, null, p_check) = true then
                v_secure_true := v_secure_true+1;
                obj_data := json();
                obj_data.put('amtclbdg',i.amtclbdg);
                obj_data.put('amtpbdg',i.amtpbdg);
                obj_data.put('amttot',i.amttot);
                obj_data.put('approvno',i.approvno);
                obj_data.put('codcate',i.codcate);
                obj_data.put('desc_codcate',get_tcodec_name('TCODCATE', i.CODCATE,global_v_lang));
                obj_data.put('codcours',i.codcours);
                obj_data.put('desc_codcours',get_tcourse_name(i.CODCOURS,global_v_lang));
                obj_data.put('codhotel',i.codhotel);
                obj_data.put('codinsts',i.CODINSTS);
                obj_data.put('desc_codinsts',get_tinstitu_name(i.codinsts,global_v_lang));
                obj_data.put('codtparg',i.codtparg);
                obj_data.put('desc_codtparg',get_tlistval_name('CODTPARG', i.CODTPARG,global_v_lang));
                obj_data.put('desc_codhotel',get_thotelif_name(i.codhotel,global_v_lang));
                obj_data.put('plancond',i.plancond);
                obj_data.put('desc_plancond',get_tlistval_name('STACOURS',i.plancond,global_v_lang));
                obj_data.put('qtynumcl',i.QTYNUMCL);
                obj_data.put('qtyptbdg',i.qtyptbdg);
                obj_data.put('qtyptpln',i.qtyptpln);

                obj_rows.put(to_char(v_row-1),obj_data);
            end if;
        end loop;
        if v_secure_true = 0 and v_row > 0 then
            param_msg_error := get_error_msg_php('HR3008',global_v_lang);
            return;
        end if;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TIDPPLAN');
            return;
        else
            dbms_lob.createtemporary(json_str_output, true);
            obj_rows.to_clob(json_str_output);
        end if;
    end gen_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure check_savedetail as
        v_temp varchar2(1 char);
    begin
        if p_year is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        begin
            select 'X' into v_temp
              from TCOMPNY
             where codcompy like p_codcompy
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end check_savedetail;

    procedure update_detail(data_obj json) as
        v_qtyptbdg      tyrtrpln.qtyptbdg%type;
        v_qtynumcl      tyrtrpln.qtynumcl%type;
        v_amtpbdg       tyrtrpln.amtpbdg%type;
        v_amtclbdg      tyrtrpln.amtclbdg%type;
        v_amttot        tyrtrpln.amttot%type;
    begin
        v_qtyptbdg      := to_number(hcm_util.get_string(data_obj,'qtyptbdg'));
        v_qtynumcl      := to_number(hcm_util.get_string(data_obj,'qtynumcl'));
        v_amtpbdg       := to_number(hcm_util.get_string(data_obj,'amtpbdg'));
        v_amtclbdg      := to_number(hcm_util.get_string(data_obj,'amtclbdg'));
        v_amttot        := to_number(hcm_util.get_string(data_obj,'amttot'));

        if v_qtyptbdg is null or v_qtynumcl is null or v_amtpbdg is null or v_amtclbdg is null or v_amttot is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        elsif v_qtyptbdg < 0 or v_qtynumcl < 0 or v_amtpbdg < 0 or v_amtclbdg < 0 or v_amttot < 0 then
            param_msg_error := get_error_msg_php('HR2023',global_v_lang);
            return;
        else
            update tyrtrpln
               set qtyptbdg = v_qtyptbdg,
                   qtynumcl = v_qtynumcl,
                   amtpbdg = v_amtpbdg,
                   amtclbdg = v_amtclbdg,
                   amttot  = v_amttot,
                   dteupd  =  sysdate,
                   coduser =  global_v_coduser
             where codcours  = p_codcours
               and dteyear  = p_year
               and codcompy  = p_codcompy;
        end if;
    end update_detail;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj        json;
    begin
        initial_value(json_str_input);
        json_obj        := json(json_str_input);
        param_json      := hcm_util.get_json(json_obj,'param_json');
        check_savedetail;
        if param_msg_error is null then
            update_detail(param_json);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure gen_index_approve(json_str_output out clob) as
        obj_rows        json;
        obj_data        json;
        v_row           number := 0;
        v_secure_true   number := 0;
        v_lastapprove   number := 0;
        p_check         varchar2(6);
        v_check         boolean;
        v_codrespn      tyrtrpln.codrespn%type;
        v_approveno     number;
        v_numseq    number;

        cursor c1 is
            select distinct approvno,dteappr,codappr,remark,staappr
              from taptrpln a
             where a.dteyear = p_year
               and a.codcompy = p_codcompy
               and rownum = 1
               and exists (select item1 
                             from ttemprpt 
                            where codempid = global_v_codempid 
                              and codapp ='HRTR3FUH' 
                              and item1 = a.codcours)
          order by a.APPROVNO;

        cursor c2 is
            select approvno,codcours,codcate,plancond,codtparg,qtyptpln,qtyptbdg,amtpbdg,amtclbdg,amttot,codhotel,codinsts,qtynumcl,codrespn
              from TYRTRPLN a
             where a.dteyear = p_year
               and a.codcompy = p_codcompy
               and ( a.staappr <> 'Y' or  a.staappr is null);
    begin
        obj_rows := json();
        delete ttemprpt where codapp = 'HRTR3FUH' and codempid = global_v_codempid;
        v_numseq    := 0;
        for r2 in c2 loop
            v_numseq := v_numseq +1 ;
            v_approveno := 1;
            if chk_flowmail.check_approve( 'HRTR34E', r2.CODRESPN, v_approveno,global_v_codempid ,null, null, p_check) then
                insert into ttemprpt(codapp,codempid,numseq,item1)
                values('HRTR3FUH',global_v_codempid,v_numseq, r2.codcours);
            end if;
        end loop;

        for i in c1 loop
            v_row           := v_row+1;
            v_secure_true   := v_secure_true+1;
            v_lastapprove   := nvl(i.APPROVNO,0);
            obj_data        := json();
            obj_data.put('approvno',nvl(i.APPROVNO,0));
            obj_data.put('dteappr',to_char(i.DTEAPPR,'dd/mm/yyyy'));
            obj_data.put('codappr',i.CODAPPR);
            obj_data.put('remark',i.REMARK);
            obj_data.put('staappr',i.STAAPPR);
            obj_data.put('numseq',v_row);
            obj_data.put('flgDisabled',true);
            obj_rows.put(to_char(v_row-1),obj_data);
        end loop;

        v_row           := v_row+1;
        v_secure_true   := v_secure_true+1;
        obj_data        := json();

        begin
            select distinct codrespn
              into v_codrespn
              from tyrtrpln a
             where a.dteyear = p_year
               and a.codcompy = p_codcompy
               and ( a.staappr <> 'Y' or  a.staappr is null)
               and exists (select item1 
                             from ttemprpt 
                            where codempid = global_v_codempid 
                              and codapp ='HRTR3FUH' 
                              and item1 = a.codcours)
               and rownum = 1;
        exception when no_data_found then
            v_codrespn := null;
        end;
        v_approveno := v_lastapprove+1;
        --v_check := chk_flowmail.check_approve( 'HRTR34E', v_codrespn, v_approveno,global_v_codempid ,null, null, p_check);
        v_check := true; v_approveno := 1; --redmine8214
        if v_check then
            obj_data.put('approvno',v_approveno);
            obj_data.put('dteappr',to_char(sysdate,'dd/mm/yyyy'));
            obj_data.put('codappr',global_v_codempid);
            obj_data.put('remark','');
            obj_data.put('staappr','');
            obj_data.put('numseq',v_row);
            obj_data.put('flgDisabled',false);
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end gen_index_approve;

    procedure index_approve(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index_approve(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end index_approve;

-- แจ้งผู้บันทึก/ผู้รับผิดชอบหลักสูตร  HRTR3FUCC
    procedure send_mail_respn(table_req VARCHAR) as
        json_obj            json;
        v_codrespn          tyrtrpln.codrespn%TYPE;
        v_codform           TFWMAILH.codform%TYPE;

        v_rowid             varchar(20);
        v_error             long;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
        v_subject           varchar2(500 char);

        v_count             number;
        v_excel_filename    varchar2(1000 char);
        v_filepath          varchar2(1000 char);
        v_column            varchar2(1000 char);
        v_labels            varchar2(1000 char);
        v_approvno          tyrtrpln.approvno%type;

        cursor c_codrespn is
            select codrespn,approvno
              from tyrtrpln
             where dteyear = p_year
               and codcompy = p_codcompy
               and staappr in ('A','Y')
               and codappr = p_codappr
               and dteappr = p_dteappr
          group by codrespn,approvno
          order by codrespn,approvno;

        cursor c_excel is --export Excel
            select codcours,codtparg,qtynumcl,qtyptbdg,amtpbdg,amtclbdg,amttot
              from tyrtrpln
             where dteyear = p_year
               and codcompy = p_codcompy
               and codrespn = v_codrespn
               and codappr = p_codappr
               and dteappr = p_dteappr
               and approvno = v_approvno
               and staappr in ('A','Y')
          order by codcours;
    begin

        v_subject   := get_label_name('HRTR3FU', global_v_lang, 10);
        v_codform   := 'HRTR3FUCC';

        for i in c_codrespn loop
            v_msg_to        := '';
            v_templete_to   := '';

            v_approvno  := i.approvno;

            begin
                select rowid into v_rowid
                  from temploy1
                 where codempid = i.codrespn;
            exception when no_data_found then
                v_rowid := null;
            end;
            if v_rowid is not null then
                begin
                    delete from ttemprpt
                     where codempid = global_v_codempid
                       and codapp   = 'HRTR3FUCC';
                exception when others then
                    null;
                end;
                begin
                    delete from ttempprm
                     where codempid = global_v_codempid
                       and codapp   = 'HRTR3FUCC';
                exception when others then
                    null;
                end;
                begin
                    insert into ttempprm (codempid, codapp, label1, label2, label3, label4, label5, label6, label7)
                        values (global_v_codempid, 'HRTR3FUCC', get_label_name('HRTR3FUP1', global_v_lang, 30), get_label_name('HRTR3FUP1', global_v_lang, 40), get_label_name('HRTR3FUP1', global_v_lang, 90), get_label_name('HRTR3FUP2', global_v_lang, 40), get_label_name('HRTR3FUP2', global_v_lang, 60), get_label_name('HRTR3FUP2', global_v_lang, 80), get_label_name('HRTR3FUP2', global_v_lang, 100));
                    exception when dup_val_on_index then
                        param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTEMPPRM');
                end;
                v_count     := 0;
                v_codrespn  := i.codrespn;
                for j in c_excel loop
                    v_count := v_count+1;
                    begin
                        insert into ttemprpt (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7)
                             values (global_v_codempid, 'HRTR3FUCC', v_count, j.codcours, get_tcourse_name(j.codcours,global_v_lang), get_tlistval_name('CODTPARG', j.codtparg,global_v_lang), j.qtynumcl, j.qtyptbdg, to_char(j.amtclbdg,'fm9,999,999,990.00'), to_char(j.amttot,'fm9,999,999,990.00'));---05/07/2021
                        exception when dup_val_on_index then
                            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTEMPRPT');
                    end;
                end loop;
                commit;
                v_excel_filename      := global_v_codempid || '_excelmail';
                v_filepath            := get_tsetup_value('PATHEXCEL') || v_excel_filename;
                v_column              := 'item1, item2, item3, item4, item5, item6, item7';
                v_labels              := 'label1, label2, label3, label4, label5, label6, label7';
                excel_mail(v_column, v_labels, null, global_v_codempid, 'HRTR3FUCC', v_excel_filename);
                v_error := chk_flowmail.send_mail_reply('HRTR3FU', i.codrespn, null , global_v_codempid, global_v_coduser, v_excel_filename, 'HRTR3FU', 10, 'U', 'Y', i.approvno, null, null, table_req, v_rowid, '1', 'Oracle');
            end if;
        end loop;
    end send_mail_respn;

 --แจ้งอนุมัติแผนฝึกอบรมประจำปี  (HRTR3FUTO)
    procedure send_mail_approve(table_req VARCHAR, v_rowid VARCHAR, v_approvno TYRTRPLN.approvno%TYPE) as
        json_obj            json;
        v_codform           TFWMAILH.codform%TYPE;
        v_codapp            TFWMAILH.codapp%TYPE;
        v_codrespn          tyrtrpln.codrespn%TYPE;

        v_error             long;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr         varchar2(500 char);
        v_subject           varchar2(500 char);

        v_count             number;
        v_excel_filename    varchar2(1000 char);
        v_filepath          varchar2(1000 char);
        v_column            varchar2(1000 char);
        v_labels            varchar2(1000 char);

        cursor c_excel is --export Excel
            select codcours,codtparg,qtynumcl,qtyptbdg,amtpbdg,amtclbdg,amttot
              from tyrtrpln
             where dteyear = p_year
               and codcompy = p_codcompy
               and ( staappr <> 'Y' or staappr is null )
          order by codcours;

    begin

        v_subject   := get_label_name('HRTR3FU', global_v_lang, 10);
        v_codform   := 'HRTR3FUTO';
        v_codapp    := 'HRTR3FU';

        begin
            delete from ttemprpt
             where codempid = global_v_codempid
               and codapp   = v_codapp;
        exception when others then
            null;
        end;
        begin
            delete from ttempprm
             where codempid = global_v_codempid
               and codapp   = v_codapp;
        exception when others then
            null;
        end;
        begin
            insert into ttempprm (codempid, codapp, namrep,pdate,ppage,
                                  label1, label2, label3, label4, label5, label6, label7)
                values (global_v_codempid, v_codapp,'namrep',to_char(sysdate,'dd/mm/yyyy'),'page1',
                        get_label_name('HRTR3FUP1', global_v_lang, 30), get_label_name('HRTR3FUP1', global_v_lang, 40), get_label_name('HRTR3FUP1', global_v_lang, 90),
                        get_label_name('HRTR3FUP2', global_v_lang, 40), get_label_name('HRTR3FUP2', global_v_lang, 60), get_label_name('HRTR3FUP2', global_v_lang, 80),
                        get_label_name('HRTR3FUP2', global_v_lang, 100));
        exception when dup_val_on_index then
            param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'ttempprm');
        end;
        v_count := 0;
        for j in c_excel loop
            v_count := v_count+1;
            begin
                insert into ttemprpt (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7)
                     values (global_v_codempid, v_codapp, v_count, j.codcours, get_tcourse_name(j.codcours,global_v_lang), get_tlistval_name('CODTPARG', j.codtparg,global_v_lang), j.qtynumcl, j.qtyptbdg, to_char(j.amtclbdg,'fm9,999,999,990.00'), to_char(j.amttot,'fm9,999,999,990.00'));--05/07/2021
                exception when dup_val_on_index then
                    param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'TTEMPRPT');
            end;
        end loop;
        commit;

        v_excel_filename      := global_v_codempid || '_excelmail';
        v_filepath            := get_tsetup_value('PATHEXCEL') || v_excel_filename;
        v_column              := 'item1, item2, item3, item4, item5, item6, item7';
        v_labels              := 'label1, label2, label3, label4, label5, label6, label7';

        excel_mail(v_column, v_labels, null, global_v_codempid, v_codapp, v_excel_filename);

        v_error := chk_flowmail.send_mail_for_approve('HRTR34E', global_v_codempid, global_v_codempid, global_v_coduser, v_excel_filename, 'HRTR3FU', 10, 'U', 'Y', v_approvno+1, null, null,table_req,v_rowid, '1', 'Oracle');
    end send_mail_approve;

    procedure check_update_approve(param_json json) as
        v_temp          varchar2(1 char);
        p_check         varchar2(6);

        v_dteyear       TYRTRPLN.dteyear%TYPE;
        v_codcompy      TYRTRPLN.codcompy%TYPE;
        v_codcours      TYRTRPLN.codcours%TYPE;
        v_codrespn      TYRTRPLN.codrespn%TYPE;
        v_old_approvno  TYRTRPLN.approvno%TYPE;

        v_approvno      TYRTRPLN.approvno%TYPE;
        v_codappr       TYRTRPLN.codappr%TYPE;
        v_dteappr       TYRTRPLN.dteappr%TYPE;
        v_remark        TYRTRPLN.remark%TYPE;

        v_codrespn_each TYRTRPLN.codrespn%TYPE;

        v_rowid         varchar(20);
        v_numseq        number;
        v_staappr       TYRTRPLN.staappr%TYPE;
        v_checkapp      boolean;

        cursor c1 is
            select dteyear,codcompy,codcours,codrespn,approvno
              from TYRTRPLN a
             where a.dteyear = p_year
               and a.codcompy = p_codcompy
               and (a.staappr <> 'Y' or a.staappr is null)
          order by a.CODCOURS;

       cursor c2codrespn is
            select codrespn
              from TYRTRPLN
             where dteyear = p_year
               and codcompy = p_codcompy
               and staappr = 'Y'
          group by codrespn
          order by codrespn;
    begin
        if p_year is null or p_codcompy is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        v_codappr   := upper(hcm_util.get_string(param_json,'codappr'));
        v_dteappr   := to_date(hcm_util.get_string(param_json,'dteappr'),'dd/mm/yyyy');
        p_codappr   := v_codappr;
        p_dteappr   := v_dteappr;
        v_remark    := (hcm_util.get_string(param_json,'remark'));

        for i in c1 loop
            v_approvno := nvl( i.approvno,0)+1;
            v_checkapp := chk_flowmail.check_approve( 'HRTR34E', i.codrespn, v_approvno,global_v_codempid ,null, null, p_check);
			if v_checkapp then
                if p_check = 'Y' then
                    v_staappr := 'Y';
                else
                    v_staappr := 'A';
                end if;
                begin
                    insert into taptrpln(dteyear,codcompy,codcours,approvno,codappr,dteappr,staappr,remark,codcreate,coduser)
                    values (p_year,i.codcompy,i.codcours,v_approvno,v_codappr,v_dteappr,v_staappr,v_remark,global_v_coduser,global_v_coduser);
                exception when dup_val_on_index then
                    update TAPTRPLN
                       set codappr = v_codappr,
                           dteappr = v_dteappr,
                           staappr = v_staappr,
                           remark = v_remark
                     where dteyear = p_year
                       and codcompy = i.codcompy
	                   and codcours = i.codcours
	                   and approvno = v_approvno;
                end;

                update TYRTRPLN
                   set codappr = v_codappr,
                       dteappr = v_dteappr,
                       approvno = v_approvno,
                       staappr = v_staappr,
                       remarkap = v_remark,
                       coduser =  global_v_coduser
                 where dteyear = i.dteyear
                   and codcompy = i.codcompy
                   and codcours = i.codcours;
            end if;
        end loop;

        begin
			select rowid into v_rowid
			  from temploy1
             where codempid = v_codappr;
		exception when no_data_found then
			v_rowid := null;
		end;
    -- ส่ง mail   ไปยังผู้อนุมัติ
--        if p_check <> 'Y' then
        if v_checkapp AND p_check = 'N' then
            send_mail_approve('TEMPLOY1', v_rowid, v_approvno);
        end if;
    -- แจ้ง Mail ผู้บันทึก/ผู้รับผิดชอบหลักสูตร
--        if p_check = 'Y' then
            send_mail_respn('TEMPLOY1');
--        end if;
    end check_update_approve;

    procedure update_approve(json_str_input in clob, json_str_output out clob) as
        json_obj        json;
        v_response      long;
        v_numseq        number;
    begin
        initial_value(json_str_input);
        json_obj        := json(json_str_input);
        param_json      := hcm_util.get_json(json_obj,'param_json');

        if param_msg_error is null then
            check_update_approve(json_obj);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end update_approve;
END HRTR3FU;

/

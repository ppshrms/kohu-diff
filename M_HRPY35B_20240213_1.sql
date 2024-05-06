--------------------------------------------------------
--  DDL for Package Body M_HRPY35B_20240213
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRPY35B_20240213" as

    procedure initial_value (json_str in clob) is
        json_obj        json_object_t;
    begin
        json_obj            := json_object_t(json_str);
        -- global
        v_chken             := hcm_secur.get_v_chken;
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

        p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
        p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
        p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
        p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
        p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');

        p_typetext          := hcm_util.get_string_t(json_obj,'p_typetext');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    end initial_value;

    procedure chk_tsincexp is
        v_flgpass	boolean;
        v_data      varchar2(1):='N';
        v_count     number :=0;

    cursor c_tsincexp is
      select b.codcomp,a.codempid
      from tsincexp a,temploy1 b
      where a.codempid = b.codempid
        and b.codcomp like p_codcompy||'%'
        and a.dteyrepay = p_dteyrepay
        and a.dtemthpay = p_dtemthpay
        and a.numperiod = nvl(p_numperiod,a.numperiod)
      group by b.codcomp,a.codempid
      order by b.codcomp,a.codempid;

    begin
        for r1 in c_tsincexp loop
            v_count := v_count+1;
            v_flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            if v_flgpass then
                v_data := 'Y';
                exit;
            end if;
        end loop;

        if v_data = 'N' and  v_count = 0   then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TSINCEXP');
        elsif not v_flgpass then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        end if;
    end;

    function cal_hhmiss(p_st	date,p_en date) return varchar is
        v_num   number	:= 0;
        v_sc   	number	:= 0;
        v_mi   	number	:= 0;
        v_hr   	number	:= 0;
        v_time  varchar2(500);
    begin
        v_num	:=  ((p_en - p_st) * 86400) + 1; 
        v_hr    :=  trunc(v_num/3600);
        v_mi    :=  mod(v_num,3600);
        v_sc    :=  mod(v_mi,60);
        v_mi    :=  trunc(v_mi/60);
        v_time  :=  lpad(v_hr,2,0)||':'||lpad(v_mi,2,0)||':'||lpad(v_sc,2,0);
        return(v_time);
    end;

    procedure check_index is
        v_codcodec    varchar2(10 char);
        v_codcompy    varchar2(100 char);
        v_secur       boolean;
    begin
        begin
            select codcompy
              into v_codcompy
              from tcompny
             where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
        end;

        if p_typpayroll is not null then
            begin
                select codcodec
                into v_codcodec
                from tcodtypy
                where codcodec = p_typpayroll;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODTYPY');
            end;
        end if;

    v_secur := secur_main.secur7(p_codcompy,global_v_coduser);
    if not v_secur then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
    end if;
    chk_tsincexp;
  end check_index;

    procedure exp_text is
        v_periodst		tgltrans.numperiod%type;
        v_perioden		tgltrans.numperiod%type;
        v_period		varchar2(7);
        v_sysdate		varchar2(8);
        out_file   		UTL_FILE.File_Type;
        data_file 		varchar2(500);
        v_tab           varchar2(500 char) := 'char(9)';

        v_poskeydb      taccodb.poskeydb%type;
        v_poskeycr      taccodb.poskeycr%type;
        v_poskey        taccodb.poskeycr%type;
        v_amtpos        varchar2(500 char);  
        v_costcnte      varchar2(500 char);  

        cursor c_tgltrans	is
          select apcode,costcent,codacc,scodacc,typpaymt,flgdrcr,
                  decode(flgdrcr,'DR',sum(to_number(stddec(amtgl,codcompy,v_chken))),0) amtdr,
                  decode(flgdrcr,'CR',to_number(sum(stddec(amtgl,codcompy,v_chken))),0) amtcr
           from tgltrans
          where codcompy   = p_codcompy
            and dteyrepay  = p_dteyrepay
            and dtemthpay  = p_dtemthpay
            and numperiod between v_periodst and v_perioden
          group by apcode,costcent,codacc,scodacc,typpaymt,flgdrcr
          order by apcode,costcent,codacc,scodacc,typpaymt,flgdrcr desc;

    begin
        if nvl(p_numperiod,0) > 0 then
            v_periodst := p_numperiod;
            v_perioden := p_numperiod;
        else
            v_periodst := 1;
            v_perioden := 9;
        end if;

        v_period := lpad(to_char(p_numperiod),1,'0')||
                    lpad(p_dtemthpay,2,'0')||
                    lpad(to_char(p_dteyrepay),4,'0');

        v_sysdate  := to_char(sysdate,'ddmm')||
                      ltrim(to_char(to_number(to_char(sysdate,'yyyy')),'0000'));

        p_filename := hcm_batchtask.gen_filename(lower('HRPY35B'||'_'||global_v_coduser),'txt',global_v_batch_dtestrt);
        --
        std_deltemp.upd_ttempfile(p_filename,'A');
        --
        out_file 	:= UTL_FILE.Fopen(p_file_dir,p_filename,'w');

        if p_typetext = '1' then
            for r_tgltrans in c_tgltrans loop
                begin  
                    select poskeydb,poskeycr into v_poskeydb,v_poskeycr
                      from taccodb
                     where codacc = r_tgltrans.codacc;
                exception when no_data_found then
                    null;
                end;

                if r_tgltrans.amtdr <> 0 then
                    v_poskey := v_poskeydb;
                    v_amtpos := ltrim(to_char((r_tgltrans.amtdr * 100),'000000000000'));
                elsif r_tgltrans.amtcr <> 0 then
                    v_poskey := v_poskeycr;
                    v_amtpos := ltrim(to_char((r_tgltrans.amtcr * 100),'000000000000'));
                end if;

                data_file := ''||v_tab||
                            ''||v_tab||
                            to_char(sysdate,'DDMMYYYY')||v_tab||
                            ''||v_tab||
                            'THAI'||v_tab||
                            to_char(sysdate,'DDMMYYYY')||v_tab||
                            '00'||v_tab||
                            'THB'||v_tab||
                            ''||v_tab||
                            '1'||v_tab||
                            v_poskey||v_tab||
                            ''||v_tab||
                            v_costcnte||v_tab||
                            v_amtpos||v_tab||
                            r_tgltrans.costcent||v_tab||
                            ''||v_tab||''||v_tab||''||v_tab||''||v_tab||''||v_tab||''||v_tab||''||v_tab||''||v_tab||'';   

                if data_file is not null then
                    UTL_FILE.Put_line(out_file,data_file);
                end if;

                v_numrec := v_numrec + 1;

            end loop; -- for c_tgltrans      
        else
            for r_tgltrans in c_tgltrans loop
                data_file :=   rpad(r_tgltrans.costcent,10,' ')||
                               rpad(r_tgltrans.codacc,10,' ')||
                               rpad(r_tgltrans.scodacc,10,' ')||
                               ltrim(to_char((r_tgltrans.amtdr * 100),'000000000000'))||
                               ltrim(to_char((r_tgltrans.amtcr * 100),'000000000000'))||
                               rpad(r_tgltrans.apcode,5,' ')||
                               rpad(get_taccap_name(r_tgltrans.apcode,global_v_lang),41,' ')||
                               rpad(r_tgltrans.typpaymt,1,' ')||
                               rpad(v_period,9,' ')||
                               rpad(v_sysdate,10,' ');

                if data_file is not null then
                    UTL_FILE.Put_line(out_file,data_file);
                end if;

                v_numrec := v_numrec + 1;

            end loop; -- for c_tgltrans        
        end if;

        UTL_FILE.FClose(out_file);
        sync_log_file(p_filename);
    end;

    procedure get_process(json_str_input in clob, json_str_output out clob) is
    begin

        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            process_data(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;

        -- set complete batch process
        hcm_batchtask.finish_batch_process(
                                            p_codapp    => global_v_batch_codapp,
                                            p_coduser   => global_v_coduser,
                                            p_codalw    => global_v_batch_codalw,
                                            p_dtestrt   => global_v_batch_dtestrt,
                                            p_flgproc   => global_v_batch_flgproc,
                                            p_qtyproc   => global_v_batch_qtyproc,
                                            p_qtyerror  => global_v_batch_qtyerror,
                                            p_filename1 => global_v_batch_filename,
                                            p_pathfile1 => global_v_batch_pathfile,
                                            p_oracode   => param_msg_error
                                            );

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);

        -- exception batch process
        hcm_batchtask.finish_batch_process(
                                            p_codapp  => global_v_batch_codapp,
                                            p_coduser => global_v_coduser,
                                            p_codalw  => global_v_batch_codalw,
                                            p_dtestrt => global_v_batch_dtestrt,
                                            p_flgproc => 'N',
                                            p_oracode => param_msg_error
                                            );
    end get_process;

    procedure process_data(json_str_output out clob) is
        obj_data        json_object_t;
        obj_detail      json_object_t;
        obj_main        json_object_t;
        v_data          varchar2(1 char) := 'N';
        v_flgsecur      varchar2(1 char) := 'N';
        v_flg           varchar2(1 char);
        data_file 		varchar2(4000 char);
        v_exist			varchar2(1) := 'N';
        v_secur			varchar2(1) := 'N';
        v_numproc  	    number:= 5;
        v_qtyproc       number:= 0;
        v_qtyerr        number:= 0;
        v_dtestr  	    date;
        v_dteend  	    date;
        v_periodst	    number;
        v_perioden	    number;

        v_time          varchar2(100 char);
        v_err           varchar2(4000 char);
        v_response      varchar2(4000 char);

        v_rcnt  number := 0;
        obj_row         json_object_t;
        obj_result      json_object_t;

        cursor c_error is
            select item01,item02,item03,temp31
            from ttemperr
           where coduser = nvl(global_v_coduser , 'TJS00010')
             and codapp  like 'HRPY35B%'
          order by numseq;

    begin

        check_index;
        v_dtestr := sysdate;

        if nvl(p_numperiod,0) > 0 then
            v_periodst := p_numperiod;
            v_perioden := p_numperiod;
        else
            v_periodst := 1;
            v_perioden := 9;
        end if;

		delete tgltrans
		 where codcompy   = p_codcompy
           and dteyrepay  = p_dteyrepay
		   and dtemthpay  = p_dtemthpay
		   and numperiod between v_periodst and v_perioden;

        commit;
        hrpy35b_batch.start_process(p_codcompy,
                                    p_dteyrepay,
                                    p_dtemthpay,
                                    p_numperiod,
                                    p_typpayroll,
                                    global_v_coduser);
        -------------------------------------------------------
        v_numrec  := 0;
        exp_text;
        -------------------------------------------------------
        v_numproc   := nvl(get_tsetup_value('QTYPARALLEL'),5);

        v_numerr  := 0;
		for j in 1..v_numproc loop
		  begin
		   select qtyproc,qtyerr
		     into v_qtyproc,v_qtyerr
		     from tprocount
		    where codapp  like 'HRPY35B%'
		      and coduser = global_v_coduser
		      and flgproc = 'Y'
		      and numproc = j;
		  exception when no_data_found then
		  	 v_qtyproc  := 0;
		  	 v_qtyerr   := 0;
		  end;

		  v_numerr  := nvl(v_numerr,0) + nvl(v_qtyerr,0);
		end loop;

		if nvl(v_numrec,0) > 0 or nvl(v_numerr,0) > 0 then
			v_exist := 'Y';
		end if;
		----------------------------------------------------------------------
		v_dteend := sysdate;
		v_time   := cal_hhmiss(v_dtestr,v_dteend);
		----------------------------------------------------------------------
        ----------
        begin
           select codempid||' - '||remark
             into v_err
             from tprocount
            where codapp  like 'HRPY35B%'
              and coduser = global_v_coduser
              and flgproc = 'E'
              and rownum  = 1 ;
          exception when no_data_found then
             v_err := null ;
          end;
        ----------

        if v_exist = 'N' then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TGLTRANS');
          rollback;
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            obj_detail:= json_object_t();
            obj_detail.put('coderror', '200');
            obj_detail.put('numrec', nvl(v_numrec,0));
            --redmine #1934
            obj_detail.put('numerr', nvl(v_numerr,0));
            --redmine #1934

            -- set complete batch process
            global_v_batch_flgproc  := 'Y';
            global_v_batch_qtyproc  := nvl(v_numrec,0);
            --redmine #1934
            global_v_batch_qtyerror := nvl(v_numerr,0);
            --redmine #1934
            global_v_batch_filename := p_filename;
            global_v_batch_pathfile := p_file_path || p_filename;

            --redmine #1934
            obj_row       :=    json_object_t;
            obj_result    :=    json_object_t;
            if nvl(v_numerr,0) > 0 then
              for i in c_error loop
                    v_rcnt      := v_rcnt + 1;
                    obj_data    := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('codempid', i.item01);
                    obj_data.put('desc_codempid', get_temploy_name(i.item01,global_v_lang));
                    obj_data.put('codpay', i.item02);
                    if nvl(i.item03,'N') <> 'N' then
                        obj_data.put('desc_codpay', get_tinexinf_name(i.item02,global_v_lang));
                    else
                        obj_data.put('desc_codpay', get_tinexinf_name(i.item02,global_v_lang));
                    end if;

                    obj_data.put('amtpay', i.temp31);
                    obj_data.put('desnote', get_label_name('HRPY35B2',global_v_lang,'110'));
                    obj_result.put(to_char(v_rcnt-1),obj_data);
              end loop;

              obj_row.put('rows', obj_result);
            end if;
            --redmine #1934
            param_msg_error   := get_error_msg_php('HR2715',global_v_lang);
            v_response        := get_response_message(null,param_msg_error,global_v_lang);
            obj_main          :=    json_object_t;
            obj_main.put('coderror', '200');
            obj_main.put('detail', obj_detail);
            obj_main.put('message', p_file_path || p_filename);
            obj_main.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
            obj_main.put('table', obj_row);
            json_str_output   := obj_main.to_clob;
        end if;

    exception when others then
        param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

        -- exception batch process
        hcm_batchtask.finish_batch_process(
                                            p_codapp  => global_v_batch_codapp,
                                            p_coduser => global_v_coduser,
                                            p_codalw  => global_v_batch_codalw,
                                            p_dtestrt => global_v_batch_dtestrt,
                                            p_flgproc => 'N',
                                            p_oracode => param_msg_error
                                            );
    end process_data;

    procedure get_lastperiod(json_str_input in clob, json_str_output out clob) is
        obj_data        json_object_t;
        v_data          varchar2(1 char) := 'N';
        v_flgsecur      varchar2(1 char) := 'N';
        v_flg           varchar2(1 char);
        v_dteupd        date;
        v_numperiod     number;
        v_dtemthpay     number;
        v_dteyrepay     number;
        v_numtext       varchar2(100 char);
    begin
        initial_value(json_str_input);
        check_index;
        begin
            select dteupd,numperiod,dtemthpay,dteyrepay
            into v_dteupd,v_numperiod,v_dtemthpay,v_dteyrepay
            from tgltrans
            where codcompy = p_codcompy
            and dteupd = (select max(dteupd)
                            from tgltrans
                            where codcompy = p_codcompy)
                            and rownum = 1;
            v_numtext   := nvl(v_numperiod,0)||'/'||nvl(v_dtemthpay,0)||'/'||nvl(v_dteyrepay,0);
        exception when no_data_found then
            v_dteupd    := null;
            v_numperiod := null;
            v_dtemthpay := null;
            v_dteyrepay := null;
        end;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('lastdate', to_char(v_dteupd,'dd/mm/yyyy'));
        obj_data.put('lastperiod', v_numtext);        

        json_str_output := obj_data.to_clob;

    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_lastperiod;

    function check_index_batchtask(json_str_input clob) return varchar2 is
        v_response    varchar2(4000 char);
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is not null then
            v_response := replace(param_msg_error,'@#$%400');
        end if;
        return v_response;
    end;

  --
    procedure gen_text_file(json_str_output out clob) as
        obj_row         json_object_t;
        obj_data        json_object_t;
        obj_result      json_object_t;
        v_error         varchar2(1000 char);
        v_flgsecu       boolean := false;
        v_rec_tran      number;
        v_rec_err       number;
        v_numseq        varchar2(1000 char);
        v_rcnt          number  := 0;

        cursor c_error is
            select item01,item02,item03,temp31
            from ttemperr
            where coduser = nvl(global_v_coduser , 'TJS00010')
            and codapp  like 'HRPY35B%'
            order by numseq;

    begin

        obj_row    := json_object_t();
        obj_result := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('numrec', v_numrec);
        obj_row.put('numerr', v_numerr);
        obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

        for i in c_error loop
            v_rcnt      := v_rcnt + 1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', i.item01);
            obj_data.put('codempid_desc', get_temploy_name(i.item01,global_v_lang));
            obj_data.put('codpay', i.item02);
            if nvl(i.item03,'N') <> 'N' then
                obj_data.put('codpay_desc', get_tinexinf_name(i.item02,global_v_lang));
            else
                obj_data.put('codpay_desc', get_tinexinf_name(i.item02,global_v_lang));
            end if;

            obj_data.put('amtpay', i.temp31);
            obj_data.put('desnote', get_label_name('HRPY35B2',global_v_lang,'110'));
            obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;

        obj_row.put('datadisp', obj_result);

        json_str_output := obj_row.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;


end M_HRPY35B_20240213;

/

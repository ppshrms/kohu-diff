--------------------------------------------------------
--  DDL for Package Body PY_TINEXINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PY_TINEXINF" AS

    PROCEDURE initial_value (
        json_str IN CLOB
    ) IS
        json_obj json_object_t;
    BEGIN
        json_obj := json_object_t(json_str);
        global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
        global_v_type_year  := hcm_util.get_string_t(json_obj, 'p_type_year');
    END initial_value;

    FUNCTION check_date (
        p_date  IN VARCHAR2
    ) RETURN BOOLEAN IS
        v_date  DATE;
        v_error BOOLEAN := false;
    BEGIN
        IF p_date IS NOT NULL THEN
            BEGIN
                v_date := to_date(p_date, 'dd/mm/yyyy');				
            EXCEPTION
                WHEN OTHERS THEN
                    v_error := true;
                    RETURN ( v_error );
            END;
        END IF;

        RETURN ( v_error );
    END;

	FUNCTION get_result (
        v_rec_tran   IN NUMBER,
        v_rec_err    IN NUMBER
    ) RETURN CLOB IS
        obj_row    json_object_t;
        obj_data   json_object_t;
        obj_result json_object_t;
		v_rcnt     NUMBER := 0;
    BEGIN
	
        --send result to web
        IF param_msg_error IS NULL THEN
            obj_row := json_object_t();
            obj_result := json_object_t();
            obj_row.put('coderror', '200');
            IF v_msgerror IS NULL THEN
                obj_row.put('rec_tran', v_rec_tran);
                obj_row.put('rec_err', v_rec_err);
                obj_row.put('response', replace(get_error_msg_php('HR2715', global_v_lang), '@#$%200', NULL));
            ELSE
                obj_row.put('response', v_msgerror);
                obj_row.put('flg', 'warning');
            END IF;

			--??
            IF p_numseq.EXISTS(p_numseq.first) THEN
                FOR i IN p_numseq.first..p_numseq.last LOOP
                    v_rcnt := v_rcnt + 1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('text', p_text(i));
                    obj_data.put('error_code', p_error_code(i));
                    obj_data.put('numseq', p_numseq(i) + 1);
                    obj_result.put(to_char(v_rcnt - 1), obj_data);
                END LOOP;
            END IF;

            --RETURN obj_row.put('datadisp', obj_result).to_clob;
             RETURN null;
        ELSE
            RETURN get_response_message('400', param_msg_error, global_v_lang);
        END IF;

    END;


    PROCEDURE get_process_py_tpfmemb (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS        
        
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
        
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tpfmemb(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);        

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tpfmemb;


    PROCEDURE get_process_py_tinexinf (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tinexinf(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tinexinf;
	
	PROCEDURE get_process_py_tempinc (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tempinc(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tempinc;
	
	
	PROCEDURE get_process_py_taccodb (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_taccodb(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_taccodb;

    PROCEDURE get_process_py_tempded (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tempded(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tempded;
    
    PROCEDURE get_process_py_tempded_sp (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tempded_sp(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tempded_sp;

    PROCEDURE get_process_py_tsincexp (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        --validate_excel_py_tsincexp(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tsincexp;

	PROCEDURE get_process_py_tcoscent (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    ) AS
        v_rec_tran NUMBER := 0;
        v_rec_err  NUMBER := 0;
    BEGIN
        initial_value(json_str_input);
        validate_excel_py_tcoscent(json_str_input, v_rec_tran, v_rec_err);
    	json_str_output := get_result(v_rec_tran, v_rec_err);

    EXCEPTION
        WHEN OTHERS THEN
            param_msg_error := dbms_utility.format_error_stack
                               || ' '
                               || dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    END get_process_py_tcoscent;


    PROCEDURE validate_excel_py_tinexinf (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 16;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
        v_codpay         tinexinf.codpay%TYPE;
        v_descpaye       tinexinf.descpaye%TYPE;
        v_descpayt       tinexinf.descpayt%TYPE;
        v_descpay3       tinexinf.descpay3%TYPE;
        v_descpay4       tinexinf.descpay4%TYPE;
        v_descpay5       tinexinf.descpay5%TYPE;
        v_typpay         tinexinf.typpay%TYPE;
        v_flgtax         tinexinf.flgtax%TYPE;
        v_flgfml         tinexinf.flgfml%TYPE;
        v_flgpvdf        tinexinf.flgpvdf%TYPE;
        v_flgwork        tinexinf.flgwork%TYPE;
        v_flgsoc         tinexinf.flgsoc%TYPE;
        v_flgcal         tinexinf.flgcal%TYPE;
        v_flgform        tinexinf.flgform%TYPE;
        v_typinc         tinexinf.typinc%TYPE;
        v_typpayr        tinexinf.typpayr%TYPE;
        v_typpayt        tinexinf.typpayt%TYPE;
        v_grppay         tinexinf.grppay%TYPE;
        v_typincpnd      tinexinf.typincpnd%TYPE;
        v_typincpnd50    tinexinf.typincpnd50%TYPE;
        v_codtax         ttaxtab.codtax%TYPE;
        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
       
        chk_len          leng; --aaa
        v_cnt number; --aa
    BEGIN
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
        for i in 0..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	  := false;   
            
			v_codpay   := hcm_util.get_string_t(param_json_row,'codpay');
			v_descpayt   := hcm_util.get_string_t(param_json_row,'descpayt');
			v_descpaye   := hcm_util.get_string_t(param_json_row,'descpaye');
			v_typpay   := hcm_util.get_string_t(param_json_row,'typpay');
			v_typinc   := hcm_util.get_string_t(param_json_row,'typinc');
			v_typpayr   := hcm_util.get_string_t(param_json_row,'typpayr');
			v_typpayt   := hcm_util.get_string_t(param_json_row,'typpayt');
			v_typincpnd  := hcm_util.get_string_t(param_json_row,'typincpnd');
			v_typincpnd50  := hcm_util.get_string_t(param_json_row,'typincpnd50');
			v_flgcal  := hcm_util.get_string_t(param_json_row,'flgcal');
			v_flgsoc  := hcm_util.get_string_t(param_json_row,'flgsoc');
			v_flgtax  := hcm_util.get_string_t(param_json_row,'flgtax');
			v_flgwork  := hcm_util.get_string_t(param_json_row,'flgwork');
			v_flgpvdf   := hcm_util.get_string_t(param_json_row,'flgpvdf');
			v_flgfml   := hcm_util.get_string_t(param_json_row,'flgfml');
			v_codtax   := hcm_util.get_string_t(param_json_row,'codtax');
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codpay;
                v_text(2)   := v_descpayt;
                v_text(3)   := v_descpaye;
                v_text(4)   := v_typpay;
                v_text(5)   := v_typinc;
                v_text(6)   := v_typpayr;
                v_text(7)   := v_typpayt;
                v_text(8)  := v_typincpnd;
                v_text(9)  := v_typincpnd50;
                v_text(10)  := v_flgcal;
                v_text(11)  := v_flgsoc;
                v_text(12)  := v_flgtax;
                v_text(13)  := v_flgwork;
                v_text(14)   := v_flgpvdf;
                v_text(15)   := v_flgfml;
                v_text(16)   := v_codtax;
    
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
                    data_file := data_file||','||v_text(i);
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 1,2,3,4,6,10,11,12,13,14,15
                for i in 1..v_column loop
                  if i in (1,2,3,4,6,10,11,12,13,14,15) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                
                --check incorrect data
                --4.TYPPAY
                if ((v_text(4) < 1) or (v_text(4) > 7)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(4);
                    exit cal_loop;
                end if;
                  
                --10.FLGCAL
                if ((v_text(10) <> 'Y') or (v_text(10) <> 'N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(10);
                    exit cal_loop;
                end if;
    
                --11.FLGSOC
                if ((v_text(11) <> 'Y') or (v_text(11) <> 'N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(11);
                    exit cal_loop;
                end if;	
                
                --12.FLGTAX
                if ((v_text(12) <> 1) or (v_text(11) <> 2)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(12);
                    exit cal_loop;
                end if;	
    
                --13.FLGWORK
                if ((v_text(13) <> 'Y') or (v_text(13) <> 'N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(13);
                    exit cal_loop;
                end if;
                  
                --14.FLGPVDF
                if ((v_text(13) <> 'Y') or (v_text(13) <> 'N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(13);
                   exit cal_loop;
                end if;
    
                --15.FLGFML
                if ((v_text(15) < 1) or (v_text(15) > 10)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(15);
                    exit cal_loop;
                end if;				
                exit cal_loop;
            end loop; -- cal_loop
                 
            
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TINEXINF where codpay = v_codpay;
                        
                        insert into TINEXINF (	CODPAY, 
												DESCPAYE, 
												DESCPAYT, 
												DESCPAY3, 
												DESCPAY4, 
												DESCPAY5, 
												TYPPAY, 
												FLGTAX, 
												FLGFML, 
												FLGPVDF, 
												FLGWORK, 
												FLGSOC, 
												FLGCAL, 
												FLGFORM, 
												TYPINC, 
												TYPPAYR, 
												TYPPAYT, 
												GRPPAY, 
												TYPINCPND, 
												TYPINCPND50,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codpay, 
												v_descpaye, 
												v_descpayt, 
												v_descpaye, 
												v_descpaye, 
												v_descpaye, 
												v_typpay, 
												v_flgtax, 
												v_flgfml, 
												v_flgpvdf, 
												v_flgwork, 
												v_flgsoc, 
												v_flgcal, 
												'N', 
												v_typinc, 
												v_typpayr, 
												v_typpayt, 
												case when v_typpay in (1, 2, 3) 
														then 1
													when  v_typpay in (4, 5)
														then 2
													when v_typpay = 7
														then 3
													else null
												end, 
												v_typincpnd, 
												v_typincpnd50, 
												trunc(sysdate),												
												global_v_coduser, 
												trunc(sysdate),												 
												global_v_coduser
											);
                        
                    end;
                    
                    if (v_codtax is not null) then 
                        begin 
                            delete from TTAXTAB where codpay = v_codpay;
                            
                            insert into TTAXTAB (	CODPAY, 
													CODTAX, 
													DTECREATE, 
													CODCREATE, 
													DTEUPD, 
													CODUSER
												)
										values(		v_codpay, 
													v_codtax, 
													trunc(sysdate), 
													global_v_coduser, 
													trunc(sysdate),										 
													global_v_coduser
												);
                            
                        end;
                    end if;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
    end loop;   
END validate_excel_py_tinexinf;


PROCEDURE validate_excel_py_tpfmemb (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
        v_codempid		tpfmemb.codempid%TYPE;
		v_nummember		tpfmemb.nummember%TYPE;
		v_dteeffec		tpfmemb.dteeffec%TYPE;
		v_codpfinf		tpfmemb.codpfinf%TYPE;
		v_codplan		tpfmemb.codplan%TYPE;
		v_dteeffecp		tpfirinf.dteeffec%TYPE;
		v_flgemp		tpfmemb.flgemp%TYPE;
		v_dtereti		tpfmemb.dtereti%TYPE;
		v_codreti		tpfmemb.codreti%TYPE;
		v_amtcaccu		tpfmemb.amtcaccu%TYPE;
		v_amtcretn		tpfmemb.amtcretn%TYPE;
		v_amteaccu		tpfmemb.amteaccu%TYPE;
		v_amteretn		tpfmemb.amteretn%TYPE;
		v_amtinteccu	tpfmemb.amtinteccu%TYPE;
		v_amtintaccu	tpfmemb.amtintaccu%TYPE;
		v_flgconded		tpfmemb.flgconded%TYPE;
		v_flgdpvf		tpfmemrt.flgdpvf%TYPE; 
		v_dteeffert		tpfmemrt.dteeffec%TYPE;
		v_ratecret		tpfmemrt.ratecret%TYPE;
		v_ratecsbt		tpfmemrt.ratecsbt%TYPE;


        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
        for i in 0..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	  := false;   
            
			v_codempid   := hcm_util.get_string_t(param_json_row,'codempid');
			v_nummember   := hcm_util.get_string_t(param_json_row,'nummember');
			v_dteeffec   := hcm_util.get_string_t(param_json_row,'dteeffec');
			v_codpfinf   := hcm_util.get_string_t(param_json_row,'codpfinf');
			v_codplan   := hcm_util.get_string_t(param_json_row,'codplan');
			v_dteeffecp   := hcm_util.get_string_t(param_json_row,'dteeffecp');
			v_flgemp   := hcm_util.get_string_t(param_json_row,'flgemp');
			v_dtereti  := hcm_util.get_string_t(param_json_row,'dtereti');
			v_codreti  := hcm_util.get_string_t(param_json_row,'codreti');
			v_amtcaccu  := hcm_util.get_string_t(param_json_row,'amtcaccu');
			v_amtcretn  := hcm_util.get_string_t(param_json_row,'amtcretn');
			v_amteaccu  := hcm_util.get_string_t(param_json_row,'amteaccu');
			v_amteretn  := hcm_util.get_string_t(param_json_row,'amteretn');
			v_amtinteccu   := hcm_util.get_string_t(param_json_row,'amtinteccu');
			v_amtintaccu   := hcm_util.get_string_t(param_json_row,'amtintaccu');
			v_flgconded   := hcm_util.get_string_t(param_json_row,'flgconded');
			v_flgdpvf  := hcm_util.get_string_t(param_json_row,'flgdpvf');
			v_dteeffert   := hcm_util.get_string_t(param_json_row,'dteeffert');
			v_ratecret   := hcm_util.get_string_t(param_json_row,'ratecret');
			v_ratecsbt   := hcm_util.get_string_t(param_json_row,'ratecsbt');
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codempid;
                v_text(2)   := v_nummember;
                v_text(3)   := v_dteeffec;
                v_text(4)   := v_codpfinf;
                v_text(5)   := v_codplan;
                v_text(6)   := v_dteeffecp;
                v_text(7)   := v_flgemp;
                v_text(8)  := v_dtereti;
                v_text(9)  := v_codreti;
                v_text(10)  := v_amtcaccu;
                v_text(11)  := v_amtcretn;
                v_text(12)  := v_amteaccu;
                v_text(13)  := v_amteretn;
                v_text(14)   := v_amtinteccu;
                v_text(15)   := v_amtintaccu;
                v_text(16)   := v_flgconded;
				v_text(17)  := v_flgdpvf;
                v_text(18)   := v_dteeffert;
                v_text(19)   := v_ratecret;
                v_text(20)   := v_ratecsbt;
    
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
                    data_file := data_file||','||v_text(i);
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 1,2,3,4,6,10,11,12,13,14,15
                for i in 1..v_column loop
                  if i in (1,2,3,4,5,6,7,16,17,18,19,20) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data
                --7.FLGEMP
                if (v_text(7) not in (0,1,2)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(7);
                    exit cal_loop;
                end if;
                  
                --16.FLGCONDED
                if (v_text(17) not in (0,1)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(16);
                    exit cal_loop;
                end if;
    
                --17.FLGDPVF
                if (v_text(17) not in (0,1)) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(17);
                    exit cal_loop;
                end if;	
                			
                exit cal_loop;
            end loop; -- cal_loop
                 
            
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TPFMEMB  where codempid  = v_codempid ;
                        
                        insert into TPFMEMB (	CODEMPID,
												DTEEFFEC,
												FLGEMP,
												NUMMEMBER,
												CODPFINF,
												CODPLAN,
												DTERETI,
												CODRETI,
												AMTCACCU,
												AMTCRETN,
												AMTEACCU,
												AMTERETN,
												AMTINTECCU,
												AMTINTACCU,
												DTECAL,
												CODCOMP,
												TYPPAYROLL,
												RATEERET,
												RATECRET,
												QTYWKEN,
												FLGCONDED,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codempid,
												v_dteeffec,
												v_flgemp,
												v_nummember,
												v_codpfinf,
												v_codplan,
												v_dtereti,
												v_codreti,
												v_amtcaccu,
												v_amtcretn,
												v_amteaccu,
												v_amteretn,
												v_amtinteccu,
												v_amtintaccu,
												null,
												null,
												null,
												null,
												null,
												null,
												v_flgconded, 
												trunc(sysdate),
												global_v_coduser, 
												trunc(sysdate), 												 
												global_v_coduser
											);
                        
                    
						delete from TPFMEMRT  where codempid  = v_codempid and dteeffec = v_dteeffert;
                        
                        insert into TPFMEMRT (	CODEMPID,
												DTEEFFEC,												
												FLGDPVF,
												RATECRET,
												RATECSBT,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codempid,												
												v_dteeffert,
												v_flgdpvf,
												v_ratecret,
												v_ratecsbt, 
												trunc(sysdate), 
												global_v_coduser, 
												trunc(sysdate), 												 
												global_v_coduser
											);
                    
						delete from TPFIRINF  where codempid  = v_codempid and dteeffec = v_dteeffecp;
                        
                        insert into TPFIRINF (	CODEMPID,
												DTEEFFEC,
												CODPLAN,
												CODPFINF,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codempid,
												v_dteeffecp,
												v_codplan,
												v_codpfinf, 
												trunc(sysdate), 
												global_v_coduser, 
												trunc(sysdate), 												 
												global_v_coduser
											);
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_tpfmemb;
	
	PROCEDURE validate_excel_py_tempinc (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
        v_codempid		tempinc.codempid%TYPE;
		v_codpay		tempinc.codpay%TYPE;
		v_dtestrt		tempinc.dtestrt%TYPE;
		v_dteend		tempinc.dteend%TYPE;
		v_dtecancl		tempinc.dtecancl%TYPE;
		v_amtfix		tempinc.amtfix%TYPE;
		v_periodpay		tempinc.periodpay%TYPE;
		v_flgprort		tempinc.flgprort%TYPE;

        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
        for i in 0..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	  := false;   
            
			v_codempid  := hcm_util.get_string_t(param_json_row,'codempid');
			v_codpay   	:= hcm_util.get_string_t(param_json_row,'codpay');
			v_dtestrt   := hcm_util.get_string_t(param_json_row,'dtestrt');
			v_dteend   	:= hcm_util.get_string_t(param_json_row,'dteend');
			v_dtecancl  := hcm_util.get_string_t(param_json_row,'dtecancl');
			v_amtfix   	:= hcm_util.get_string_t(param_json_row,'amtfix');
			v_periodpay := hcm_util.get_string_t(param_json_row,'periodpay');
			v_flgprort  := hcm_util.get_string_t(param_json_row,'flgprort');
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codempid;
                v_text(2)   := v_codpay;
                v_text(3)   := v_dtestrt;
                v_text(4)   := v_dteend;
                v_text(5)   := v_dtecancl;
                v_text(6)   := v_amtfix;
                v_text(7)   := v_periodpay;
                v_text(8)   := v_flgprort;
				
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
                    data_file := data_file||','||v_text(i);
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 
                for i in 1..v_column loop
                  if i in (1,2,3,6,7,8) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data
                --7.PERIODPAY
                if (v_text(7) not in ('1','2','3','4','5','6','7','8','9','N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(7);
                    exit cal_loop;
                end if;
                  
                --8.FLGPRORT
                if (v_text(8) not in ('Y','N')) then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_field := v_field(8);
                    exit cal_loop;
                end if;
                    			
                exit cal_loop;
            end loop; -- cal_loop
                 
            
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TEMPINC   where codempid  = v_codempid and codpay = v_codpay and dtestrt = v_dtestrt;
                        
                        insert into TEMPINC (	CODEMPID,
												CODPAY,
												DTESTRT,
												DTEEND,
												DTECANCL,
												AMTFIX,
												PERIODPAY,
												FLGPRORT,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codempid,
												v_codpay,
												v_dtestrt,
												v_dteend,
												v_dtecancl,
												v_amtfix,
												v_periodpay,
												v_flgprort, 
												trunc(sysdate),
												global_v_coduser, 
												trunc(sysdate),												 
												global_v_coduser
											);   
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_tempinc;
	
	
	PROCEDURE validate_excel_py_taccodb (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
		v_codacc		taccodb.codacc%TYPE;
		v_desacce		taccodb.desacce%TYPE;
		v_desacct		taccodb.desacct%TYPE;
		v_desacc3		taccodb.desacc3%TYPE;
		v_desacc4		taccodb.desacc4%TYPE;
		v_desacc5		taccodb.desacc5%TYPE;

        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
        for i in 0..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	:= false;   
            
			v_codacc	:= hcm_util.get_string_t(param_json_row,'codacc');
			v_desacce   := hcm_util.get_string_t(param_json_row,'desacce');
			v_desacct   := hcm_util.get_string_t(param_json_row,'desacct');
			v_desacc3   := hcm_util.get_string_t(param_json_row,'desacc3');
			v_desacc4   := hcm_util.get_string_t(param_json_row,'desacc4');
			v_desacc5   := hcm_util.get_string_t(param_json_row,'desacc5');
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codacc;
                v_text(2)   := v_desacce;
                v_text(3)   := v_desacct;
                v_text(4)   := v_desacc3;
                v_text(5)   := v_desacc4;
                v_text(6)   := v_desacc5;
				
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
                    data_file := data_file||','||v_text(i);
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 
                for i in 1..v_column loop
                  if i in (1,2,3) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data                
                    			
                exit cal_loop;
            end loop; -- cal_loop
                             
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TACCODB    where codacc  = v_codacc;
                        
                        insert into TACCODB  (	CODACC,
												DESACCE,
												DESACCT,
												DESACC3,
												DESACC4,
												DESACC5,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_codacc,
												v_desacce,
												v_desacct,
												v_desacc3,
												v_desacc4,
												v_desacc5,
												trunc(sysdate), 
												global_v_coduser, 
												trunc(sysdate), 												 
												global_v_coduser
											);
                    
                    
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_taccodb;
	
	
	PROCEDURE validate_excel_py_tcoscent (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
		v_costcent		tcoscent.costcent%TYPE;
		v_namcente		tcoscent.namcente%TYPE;
		v_namcentt		tcoscent.namcentt%TYPE;
		v_namcent3		tcoscent.namcent3%TYPE;
		v_namcent4		tcoscent.namcent4%TYPE;
		v_namcent5		tcoscent.namcent5%TYPE;

        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
        for i in 0..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	:= false;   
            
			v_costcent	 := hcm_util.get_string_t(param_json_row,'costcent');
			v_namcente   := hcm_util.get_string_t(param_json_row,'namcente');
			v_namcentt   := hcm_util.get_string_t(param_json_row,'namcentt');
			v_namcent3   := hcm_util.get_string_t(param_json_row,'namcent3');
			v_namcent4   := hcm_util.get_string_t(param_json_row,'namcent4');
			v_namcent5   := hcm_util.get_string_t(param_json_row,'namcent5');
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_costcent;
                v_text(2)   := v_namcente;
                v_text(3)   := v_namcentt;
                v_text(4)   := v_namcent3;
                v_text(5)   := v_namcent4;
                v_text(6)   := v_namcent5;
				
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
                    data_file := data_file||','||v_text(i);
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 
                for i in 1..v_column loop
                  if i in (1,2,3) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data                
                    			
                exit cal_loop;
            end loop; -- cal_loop
                             
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TCOSCENT     where costcent  = v_costcent;
                        
                        insert into TCOSCENT(	COSTCENT,
												NAMCENTE,
												NAMCENTT,
												NAMCENT3,
												NAMCENT4,
												NAMCENT5,
												DTECREATE, 
												CODCREATE, 
												DTEUPD, 
												CODUSER
											)
                        
									values(		v_costcent,
												v_namcente,
												v_namcentt,
												v_namcent3,
												v_namcent4,
												v_namcent5,
												trunc(sysdate),
												global_v_coduser, 
												trunc(sysdate), 												 
												global_v_coduser
											);                    
                    
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_tcoscent;

PROCEDURE validate_excel_py_tempded (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
        v_codempid		tempded.codempid%TYPE;
		v_coddeduct		tempded.coddeduct%TYPE;
		v_amtdeduct		tempded.amtdeduct%TYPE;
		v_amtspded		tempded.amtspded%TYPE;


        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
		
		TYPE code IS
            TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER;
		arr_code_deduct		code;
		
		TYPE amount IS
            TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		arr_amt_deduct	amount;
			
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
		--keep array column code starting index (row:0, col:1) (row:0, col:2) ... (row:0, col:40)
		param_json_row  := hcm_util.get_json_t(param_data,to_char(0));
		for i in 1..param_column.get_size-1 loop
			arr_code_deduct(i) := hcm_util.get_string_t(param_json_row,'column' || to_char(i));
		end loop;
				
        for i in 1..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	  := false;   
            
			v_codempid   := hcm_util.get_string_t(param_json_row,'codempid');
			
			--keep amount deduct
			for i in 1..param_column.get_size-1 loop
				arr_amt_deduct(i) := hcm_util.get_string_t(param_json_row,'column' || to_char(i));
			end loop;
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codempid;
                --v_text(2)   := arr_amt_deduct(i);
                
    
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
					if v_text(i) is not null then
						data_file := data_file||','||v_text(i);
					end if;
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 1,2,3,4,6,10,11,12,13,14,15
                for i in 1..2 loop
                  if i in (1,2) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data               
                			
                exit cal_loop;
            end loop; -- cal_loop
                 
            
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TEMPDED   where codempid  = v_codempid and amtspded = 0 ;
						/*
                        delete from TLASTDED   
							where 
								case when v_global_type_year = 'BE' then
										codempid  = v_codempid and dteyrepay +543 =  to_char(sysdate,'YYYY')
									else
										codempid  = v_codempid and dteyrepay  =  to_char(sysdate,'YYYY')
								end;
						*/
						delete from TLASTDED   	where codempid  = v_codempid and dteyrepay = to_char(sysdate,'YYYY');
						delete from TLASTEMPD   where codempid  = v_codempid and dteyrepay = to_char(sysdate,'YYYY') and amtspded = 0 ;
						
						for i in 1..param_column.get_size-1 loop
							 						
							if (arr_amt_deduct(i) > 0) then
								begin
									insert into TEMPDED (	CODEMPID,
															CODDEDUCT,
															AMTDEDUCT,
															AMTSPDED,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		v_codempid,
															arr_code_deduct(i),
															arr_amt_deduct(i),
															0, 
															trunc(sysdate),
															global_v_coduser, 
															trunc(sysdate), 												 
															global_v_coduser
														);
								exception
									when DUP_VAL_ON_INDEX then
										update TEMPDED set AMTDEDUCT = arr_amt_deduct(i)
										where 	codempid  = v_codempid 
												and coddeduct = arr_code_deduct(i)
												and amtspded <> 0 ;
												
								end;		
								
								begin
									insert into TLASTDED (	DTEYREPAY,
															CODEMPID,
															CODCOMP,
															TYPTAX,
															FLGTAX,
															AMTINCBF,
															AMTTAXBF,
															AMTPF,
															AMTSAID,
															AMTINCSP,
															AMTTAXSP,
															AMTSASP,
															AMTPFSP,
															STAMARRY,
															DTEYRRELF,
															DTEYRRELT,
															AMTRELAS,
															AMTTAXREL,
															STATEMENT,
															QTYCHLDB,
															QTYCHLDA,
															QTYCHLDD,
															QTYCHLDI,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		to_char(sysdate,'YYYY'),
															v_codempid,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															trunc(sysdate), 
															global_v_coduser, 
															trunc(sysdate), 												 
															global_v_coduser
														);	
												
								end;
								
								begin 	
									insert into TLASTEMPD (	DTEYREPAY,
															CODEMPID,
															CODDEDUCT,
															CODCOMP,
															AMTDEDUCT,
															AMTSPDED,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		to_char(sysdate,'YYYY'),
															v_codempid,
															arr_code_deduct(i),
															null,
															arr_amt_deduct(i), 
															0,
															trunc(sysdate), 
															global_v_coduser, 
															trunc(sysdate),												 
															global_v_coduser
														);
								exception
									when DUP_VAL_ON_INDEX then
										update TLASTEMPD set AMTDEDUCT = arr_amt_deduct(i)
										where 	dteyrepay = to_char(sysdate,'YYYY')
												and codempid  = v_codempid 
												and coddeduct = arr_code_deduct(i)
												and amtspded <> 0 ;
												
								end;
								
							end if;
						end loop;
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_tempded;
        
PROCEDURE validate_excel_py_tempded_sp (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    ) IS

        param_json       json_object_t;
        param_data       json_object_t;
        param_column     json_object_t;
        param_column_row json_object_t;
        param_json_row   json_object_t;
        json_obj_list    json_list;
        v_filename       VARCHAR2(1000);
        linebuf          VARCHAR2(6000);
        data_file        VARCHAR2(6000);
        v_column         NUMBER := 20;
        v_error          BOOLEAN;
        v_err_code       VARCHAR2(1000);
        v_err_field      VARCHAR2(1000);
        v_err_table      VARCHAR2(20);
        v_comments       VARCHAR2(1000);
        v_namtbl         VARCHAR2(300);
        i                NUMBER;
        j                NUMBER;
        k                NUMBER;
        v_numseq         NUMBER := 0;
        v_num            NUMBER := 0;
        v_codempid		tempded.codempid%TYPE;
		v_coddeduct		tempded.coddeduct%TYPE;
		v_amtdeduct		tempded.amtdeduct%TYPE;
		v_amtspded		tempded.amtspded%TYPE;


        TYPE text IS
            TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
        v_text           text;
        v_field          text;
        TYPE leng IS 
			TABLE OF NUMBER INDEX BY BINARY_INTEGER;       
        chk_len         leng; --aaa
        v_cnt 			number; --aa
		
		TYPE code IS
            TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER;
		arr_code_deduct		code;
		
		TYPE amount IS
            TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		arr_amt_deduct	amount;
			
    BEGIN
		/*
        for i in 1..v_column loop
            if i in (1, 5, 6, 7, 8, 9, 16) then
                chk_len(i) := 4;
            elsif i in (2, 3) then
                chk_len(i) := 150;
            else
                chk_len(i) := 1;
            end if;
        end loop;
        --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
        */
		v_rec_tran  := 0;
        v_rec_error := 0;
        --
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;
        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        --??
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');
        param_column := hcm_util.get_json_t(param_json, 'p_columns');
        --p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
        
        --เก็บ ทุกแถว หรือ 1 แถว ??
        -- get text columns from json
        for i in 0..param_column.get_size-1 loop
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
        
		--keep array column code starting index (row:0, col:1) (row:0, col:2) ... (row:0, col:40)
		param_json_row  := hcm_util.get_json_t(param_data,to_char(0));
		for i in 1..param_column.get_size-1 loop
			arr_code_deduct(i) := hcm_util.get_string_t(param_json_row,'column' || to_char(i));
		end loop;
				
        for i in 1..param_data.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
            begin
            v_err_code  := null;
            v_err_field := null;
            v_err_table := null;
            linebuf     := i;
            v_numseq    := v_numseq;
            v_error 	  := false;   
            
			v_codempid   := hcm_util.get_string_t(param_json_row,'codempid');
			
			--keep amount deduct
			for i in 1..param_column.get_size-1 loop
				arr_amt_deduct(i) := hcm_util.get_string_t(param_json_row,'column' || to_char(i));
			end loop;
			
			
            --v_numseq ??
            if v_numseq = 0 then
              <<cal_loop>> loop
                v_text(1)   := v_codempid;
                --v_text(2)   := arr_amt_deduct(i);
                
    
                -- push row values
                data_file := null;
                for i in 1..v_column loop
                  if data_file is null then
                    data_file := v_text(i);
                  else
					if v_text(i) is not null then
						data_file := data_file||','||v_text(i);
					end if;
                  end if;
                end loop;
            
                --1.Validate --           
                --check require data column 1,2,3,4,6,10,11,12,13,14,15
                for i in 1..2 loop
                  if i in (1,2) and v_text(i) is null then
                    v_error	 	  := true;
                    v_err_code  := 'HR2045';
                    v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                    exit cal_loop;
                  end if;
                end loop;
                
                --check length all column
                --chk_len:= leng(4, 150, 150, 1, 4, 4, 4, 4, 4, 1 ,1 ,1 ,1 ,1 ,1 ,4);
                /*
				for i in 1..v_column loop
                    if( i <> 2 and i <> 3) then            
                      if ((v_text(i) is not null) and (length(v_text(i)) <> chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;
                    elsif (i = 2 or i = 3) then
                       if ((v_text(i) is not null) and (length(v_text(i)) > chk_len(i))) then
                        v_error	 	  := true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(i);
                        exit cal_loop;
                      end if;                 
                    end if;
                end loop;
                */
				
                --check incorrect data               
                			
                exit cal_loop;
            end loop; -- cal_loop
                 
            
                --2.CRUD table--
                if not v_error then
                    begin
                        delete from TEMPDED   where codempid  = v_codempid and amtdeduct = 0 ;
						/*
                        delete from TLASTDED   
							where 
								case when v_global_type_year = 'BE' then
										codempid  = v_codempid and dteyrepay +543 =  to_char(sysdate,'YYYY')
									else
										codempid  = v_codempid and dteyrepay  =  to_char(sysdate,'YYYY')
								end;
						*/
						delete from TLASTDED   	where codempid  = v_codempid and dteyrepay = to_char(sysdate,'YYYY');
						delete from TLASTEMPD   where codempid  = v_codempid and dteyrepay = to_char(sysdate,'YYYY') and amtdeduct = 0 ;
						
                        --save all code deduct
						for i in 1..param_column.get_size-1 loop
							
                            v_coddeduct	:= arr_code_deduct(i); 	
                            v_amtspded	:= arr_amt_deduct(i);
                            
							if (v_amtspded > 0) then
								begin
									insert into TEMPDED (	CODEMPID,
															CODDEDUCT,
															AMTDEDUCT,
															AMTSPDED,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		v_codempid,
															v_coddeduct,
															0,
															v_amtspded, 
															trunc(sysdate),
															global_v_coduser, 
															trunc(sysdate), 												 
															global_v_coduser
														);
								exception
									when DUP_VAL_ON_INDEX then
										update TEMPDED set AMTSPDED = v_amtspded
										where 	codempid  = v_codempid 
												and coddeduct = v_coddeduct
												and amtdeduct <> 0 ;
												
								end;		
								
								begin
									insert into TLASTDED (	DTEYREPAY,
															CODEMPID,
															CODCOMP,
															TYPTAX,
															FLGTAX,
															AMTINCBF,
															AMTTAXBF,
															AMTPF,
															AMTSAID,
															AMTINCSP,
															AMTTAXSP,
															AMTSASP,
															AMTPFSP,
															STAMARRY,
															DTEYRRELF,
															DTEYRRELT,
															AMTRELAS,
															AMTTAXREL,
															STATEMENT,
															QTYCHLDB,
															QTYCHLDA,
															QTYCHLDD,
															QTYCHLDI,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		to_char(sysdate,'YYYY'),
															v_codempid,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															trunc(sysdate), 
															global_v_coduser, 
															trunc(sysdate), 												 
															global_v_coduser
														);	
												
								end;
								
								begin 	
									insert into TLASTEMPD (	DTEYREPAY,
															CODEMPID,
															CODDEDUCT,
															CODCOMP,
															AMTDEDUCT,
															AMTSPDED,
															DTECREATE, 
															CODCREATE, 
															DTEUPD, 
															CODUSER
														)
									
												values(		to_char(sysdate,'YYYY'),
															v_codempid,
															v_coddeduct,
															null,
                                                            0,
															v_amtspded,
															trunc(sysdate), 
															global_v_coduser, 
															trunc(sysdate),												 
															global_v_coduser
														);
								exception
									when DUP_VAL_ON_INDEX then
										update TLASTEMPD set AMTSPDED = v_amtspded
										where 	dteyrepay = to_char(sysdate,'YYYY')
												and codempid  = v_codempid 
												and coddeduct = v_coddeduct
												and amtdeduct <> 0 ;
												
								end;
								
							end if;
						end loop;
                    end;
                ELSE
                    v_rec_error := v_rec_error + 1;
                    v_cnt := v_cnt + 1;
                    p_text(v_cnt) := data_file;
                    p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, NULL, false), '@#$%400', NULL)
                                           || '['
                                           || v_err_field
                                           || ']';
            
                    p_numseq(v_cnt) := i;
                end if; --not v_error
            
            end if; --v_numseq = 0
            commit;
        exception when others then
            param_msg_error := get_error_msg_php('HR2508',global_v_lang);      
        end;
		end loop;  
	END validate_excel_py_tempded_sp;
    
END py_tinexinf;

/

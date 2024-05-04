--------------------------------------------------------
--  DDL for Package Body HRCOCVB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCOCVB" AS

function check_date(p_date  in varchar2) return boolean is
    v_date  date;
    v_error boolean := false;
  begin
    if p_date is not null then
      begin
       v_date := to_date(p_date, 'dd/mm/yyyy');				
      exception when others then
        v_error := true;
        return ( v_error );
      end;
    end if;
    return ( v_error );
  end;
  --
  function check_number(p_number  in varchar2) return boolean is
    v_number  number;
    v_error   boolean := false;
  begin
    if p_number is not null then
      begin
       v_number := to_number(p_number);				
      exception when others then
        v_error := true;
        return ( v_error );
      end;
    end if;
    return ( v_error );
  end;
  --
  function check_year(p_year  in number) return number is
    p_zyear		number;
    chkreg 		varchar2(2);
  begin
    chkreg := global_v_type_year;
    if chkreg = 'BE' then
        if p_year > 2500 then
          p_zyear := -543;
        else
          p_zyear := 0;
        end if;
    else 
       p_zyear := 0;
    end if;
    
    return p_year + p_zyear ;
  end;
  --
  function check_dteyre (p_date in varchar2)
  return date is
    v_date		date;
    v_error		boolean := false;
    v_year    number;
    v_daymon	varchar2(30);
    v_text		varchar2(30);
    p_zyear		number;
    chkreg 		varchar2(30);
  begin
  /* 
   --old code
     begin     
      select value into chkreg
      from v$nls_parameters where parameter = 'NLS_CALENDAR';
      if chkreg = 'Thai Buddha' then    
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := 0;
        else
          p_zyear := 543;
       end if;
      else
       if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
       else
          p_zyear := 0;
       end if;
      end if;
    end;
  */
  chkreg := global_v_type_year;
    if chkreg = 'BE' then
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
        else
          p_zyear := 0;
        end if;
    else 
       p_zyear := 0;
    end if;


    if p_date is not null then
      -- plus year --
      v_year			:= substr(p_date,-4,4);
      v_year			:= v_year + p_zyear;
      v_daymon		:= substr(p_date,1,length(p_date)-4);
      v_text			:= v_daymon||to_char(v_year);
      v_year      := null;
      v_daymon    := null;
      -- plus year --
      v_date := to_date(v_text,'dd/mm/yyyy');
    end if;

    return(v_date);   
  end;
  --
  
procedure initial_value(json_str in clob) is 
    json_obj json_object_t;
  begin
    json_obj := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_type_year  := hcm_util.get_string_t(json_obj, 'p_type_year');    
    global_v_lang 		:= '102'; 
  end;
  --
  
procedure get_process(json_str_input in clob, json_str_output out clob) is
    v_floore         tcompny.floore%type;
    v_floort         tcompny.floort%type;
  begin
  
--      p_codproc   := hcm_util.get_json_t(json_object_t(json_str_input),'p_codproc');
--      p_codmove   := hcm_util.get_json_t(json_object_t(json_str_input),'p_codmove');
--      if p_codproc = 'HRCOCVBPM' then
--        if p_codproc = 'HRCOCVBPM' then
--          hrcocvb_batch.get_process_pm_temploy1(json_str_input);
--        end if;
--      end if;
    null;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack|| ' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;
  
  
  
	procedure get_process_pm_temploy1 (json_str_input  in clob,
                                       json_str_output out clob) is
        p_rec_tran number := 0;
        p_rec_err  number := 0;
    begin
        initial_value(json_str_input);
        validate_excel_pm_temploy1(json_str_input, p_rec_tran, p_rec_err);
    	json_str_output := get_result(p_rec_tran, p_rec_err);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end;


	procedure validate_excel_pm_temploy1 (json_str_input in clob,
                                        p_rec_tran     out number,
                                        p_rec_error    out number) is
    
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    data_file        varchar2(6000);--เก็บข้อความทุกคอลัมน์ในแต่ละแถว
    v_column         number := 8;
    v_error          boolean;
    v_err_code       varchar2(1000);
    v_err_field      varchar2(1000);
    v_err_table      varchar2(20);
    i                number;
    v_numseq         number := 0;
    v_num            number := 0;
    v_cnt 			 number := 0;       
	v_codempid		temploy1.codempid%type;
	v_codtitle		temploy1.codtitle%type;
	v_namfirste		temploy1.namfirste%type;
	v_namfirstt		temploy1.namfirstt%type;
	v_namfirst3		temploy1.namfirst3%type;
	v_namfirst4		temploy1.namfirst4%type;
	v_namfirst5		temploy1.namfirst5%type;
	v_namlaste		temploy1.namlaste%type;
	v_namlastt		temploy1.namlastt%type;
	v_namlast3		temploy1.namlast3%type;
	v_namlast4		temploy1.namlast4%type;
	v_namlast5		temploy1.namlast5%type;
	v_namempe		temploy1.namempe%type;
	v_namempt		temploy1.namempt%type;
	v_namemp3		temploy1.namemp3%type;
	v_namemp4		temploy1.namemp4%type;
	v_namemp5		temploy1.namemp5%type;
	v_nickname		temploy1.nickname%type;
	v_nicknamt		temploy1.nicknamt%type;
	v_nicknam3		temploy1.nicknam3%type;
	v_nicknam4		temploy1.nicknam4%type;
	v_nicknam5		temploy1.nicknam5%type;
	v_dteempdb		temploy1.dteempdb%type;
	v_stamarry		temploy1.stamarry%type;
	v_codsex		temploy1.codsex%type;
	v_stamilit		temploy1.stamilit%type;
	v_dteempmt		temploy1.dteempmt%type;
	v_dteretire		temploy1.dteretire%type;
	v_codcomp		temploy1.codcomp%type;
	v_codpos		temploy1.codpos%type;
	v_numlvl		temploy1.numlvl%type;
	v_staemp		temploy1.staemp%type;
	v_dteeffex		temploy1.dteeffex%type;
	v_flgatten		temploy1.flgatten%type;
	v_codbrlc		temploy1.codbrlc%type;
	v_codempmt		temploy1.codempmt%type;
	v_typpayroll	temploy1.typpayroll%type;
	v_typemp		temploy1.typemp%type;
	v_codcalen		temploy1.codcalen%type;
	v_codjob		temploy1.codjob%type;
	v_codcompr		temploy1.codcompr%type;
	v_codposre		temploy1.codposre%type;
	v_dteeflvl		temploy1.dteeflvl%type;
	v_dteefpos		temploy1.dteefpos%type;
	v_dteduepr		temploy1.dteduepr%type;
	v_dteoccup		temploy1.dteoccup%type;
	v_qtydatrq		temploy1.qtydatrq%type;
	v_numtelof		temploy1.numtelof%type;
	v_nummobile		temploy1.nummobile%type;
	v_email			temploy1.email%type;
	v_lineid		temploy1.lineid%type;
	v_numreqst		temploy1.numreqst%type;
	v_numappl		temploy1.numappl%type;
	v_ocodempid		temploy1.ocodempid%type;
	v_flgreemp		temploy1.flgreemp%type;
	v_dtereemp		temploy1.dtereemp%type;
	v_dteredue		temploy1.dteredue%type;
	v_qtywkday		temploy1.qtywkday%type;
	v_codedlv		temploy1.codedlv%type;
	v_codmajsb		temploy1.codmajsb%type;
	v_numreqc		temploy1.numreqc%type;
	v_codposc		temploy1.codposc%type;
	v_flgreq		temploy1.flgreq%type;
	v_stareq		temploy1.stareq%type;
	v_codappr		temploy1.codappr%type;
	v_dteappr		temploy1.dteappr%type;
	v_staappr		temploy1.staappr%type;
	v_remarkap		temploy1.remarkap%type;
	v_codreq		temploy1.codreq%type;
	v_jobgrade		temploy1.jobgrade%type;
	v_dteefstep		temploy1.dteefstep%type;
	v_codgrpgl		temploy1.codgrpgl%type;
	v_stadisb		temploy1.stadisb%type;
	v_numdisab		temploy1.numdisab%type;
	v_typdisp		temploy1.typdisp%type;
	v_dtedisb		temploy1.dtedisb%type;
	v_dtedisen		temploy1.dtedisen%type;
	v_desdisp		temploy1.desdisp%type;
	v_typtrav		temploy1.typtrav%type;
	v_qtylength		temploy1.qtylength%type;
	v_carlicen		temploy1.carlicen%type;
	v_typfuel		temploy1.typfuel%type;
	v_codbusno		temploy1.codbusno%type;
	v_codbusrt		temploy1.codbusrt%type;
	v_maillang		temploy1.maillang%type;
	v_dteprgntst	temploy1.dteprgntst%type;
	v_flgpdpa		temploy1.flgpdpa%type;
	v_dtepdpa		temploy1.dtepdpa%type;
	v_approvno		temploy1.approvno%type;
	v_dtecreate		temploy1.dtecreate%type;
	v_codcreate		temploy1.codcreate%type;
	v_dteupd		temploy1.dteupd%type;
	v_coduser		temploy1.coduser%type;

    
    type text is table of varchar2(1000 char) index by binary_integer;
    v_text           text;--เก็บค่าแต่ละคอลัมน์
    v_field          text;--เก็บชื่อคำอธิบายแต่ละคอลัมน์
    
    type leng is table of number index by binary_integer;       
    chk_len          leng;--เก็บความกว้างของแต่ละคอลัมน์ 
   
    v_chk_exists     number;
    v_int_temp		 number;
   
    begin
	
        --read json        
        param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
        param_data   := hcm_util.get_json_t(param_json, 'p_filename');        
        param_column := hcm_util.get_json_t(param_json, 'p_columns');       
        v_column := param_column.get_size; 
        
        --assign chk_len := leng(10,4,30,30,30,30,45,45,10,1,1,1,10,10,40,4,99,1,10,1,4,4,4,4,4,4,4,4,10,10,10,10,10,999,25,25,50,50,10,10,1,13,4,10,10,500,1,5,10,1,4,4,3,1,10);
        for i in 1..v_column loop
            if i in (1,9,13,14,19,29,30,31,32,33,39,40,44,45,49,55) then
                chk_len(i) := 10;
            elsif i in (2,16,21,22,23,24,25,26,27,28,43,51,52) then
                chk_len(i) := 4;
			elsif i in (3,4,5,6) then
                chk_len(i) := 30;
			elsif i in (7,8) then
                chk_len(i) := 45;
			elsif i in (10,11,12,18,20,41,47,50,54) then
                chk_len(i) := 1;
			elsif i in (15) then
                chk_len(i) := 40;
			elsif i in (17) then
                chk_len(i) := 99;
			elsif i in (34) then
                chk_len(i) := 999;
			elsif i in (35,36) then
                chk_len(i) := 25;
			elsif i in (37,38) then
                chk_len(i) := 50;
			elsif i in (42) then
                chk_len(i) := 13;
			elsif i in (46) then
                chk_len(i) := 500;
			elsif i in (48) then
                chk_len(i) := 5;
			elsif i in (53) then
                chk_len(i) := 3;
            else
                chk_len(i) := 0;
            end if;
        end loop;        
        
		
        --default transaction success and error
		p_rec_tran  := 0;
        p_rec_error := 0;
        
        --assign null to v_field which keep array column name
        for i in 1..v_column loop
          v_field(i) := null;
        end loop;                       
        
        --read columns name       
        for i in 0..param_column.get_size-1 loop          
          param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
          v_num             := v_num + 1;
          v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
        end loop;
                 
        --read data each rows 
        for i in 0..param_data.get_size-1 loop            
            param_json_row  := hcm_util.get_json_t(param_data,to_char(i));         
               
            begin
                v_err_code  := null;
                v_err_field := null;
                v_err_table := null;
                v_error 	:= false;           
           				
				v_text(1)    	:= hcm_util.get_string_t(param_json_row,'codempid');
				v_text(2)    	:= hcm_util.get_string_t(param_json_row,'codtitle');
				v_text(3)    	:= hcm_util.get_string_t(param_json_row,'namfirste');
				v_text(4)    	:= hcm_util.get_string_t(param_json_row,'namfirstt');
				v_text(5)    	:= hcm_util.get_string_t(param_json_row,'namlaste');
				v_text(6)    	:= hcm_util.get_string_t(param_json_row,'namlastt');
				v_text(7)    	:= hcm_util.get_string_t(param_json_row,'nickname');
				v_text(8)    	:= hcm_util.get_string_t(param_json_row,'nicknamt');
				v_text(9)    	:= hcm_util.get_string_t(param_json_row,'dteempdb');
				v_text(10)   	:= hcm_util.get_string_t(param_json_row,'stamarry');          
				v_text(11)   	:= hcm_util.get_string_t(param_json_row,'codsex');
				v_text(12)   	:= hcm_util.get_string_t(param_json_row,'stamilit');
				v_text(13)   	:= hcm_util.get_string_t(param_json_row,'dteempmt');
				v_text(14)   	:= hcm_util.get_string_t(param_json_row,'dteretire');
				v_text(15)   	:= hcm_util.get_string_t(param_json_row,'codcomp');
				v_text(16)   	:= hcm_util.get_string_t(param_json_row,'codpos');
				v_text(17)   	:= hcm_util.get_string_t(param_json_row,'numlvl');
				v_text(18)   	:= hcm_util.get_string_t(param_json_row,'staemp');
				v_text(19)   	:= hcm_util.get_string_t(param_json_row,'dteeffex');
				v_text(20)   	:= hcm_util.get_string_t(param_json_row,'flgatten');
				v_text(21)		:= hcm_util.get_string_t(param_json_row,'codbrlc');
				v_text(22)		:= hcm_util.get_string_t(param_json_row,'codempmt');
				v_text(23)		:= hcm_util.get_string_t(param_json_row,'typpayroll');
				v_text(24)		:= hcm_util.get_string_t(param_json_row,'typemp');
				v_text(25)		:= hcm_util.get_string_t(param_json_row,'codcalen');
				v_text(26)		:= hcm_util.get_string_t(param_json_row,'codjob');
				v_text(27)		:= hcm_util.get_string_t(param_json_row,'jobgrade');
				v_text(28)		:= hcm_util.get_string_t(param_json_row,'codgrpgl');
				v_text(29)		:= hcm_util.get_string_t(param_json_row,'dteeflvl');
				v_text(30)		:= hcm_util.get_string_t(param_json_row,'dteefpos');
				v_text(31)		:= hcm_util.get_string_t(param_json_row,'dteefstep');
				v_text(32)		:= hcm_util.get_string_t(param_json_row,'dteduepr');
				v_text(33)		:= hcm_util.get_string_t(param_json_row,'dteoccup');
				v_text(34)		:= hcm_util.get_string_t(param_json_row,'qtydatrq');
				v_text(35)		:= hcm_util.get_string_t(param_json_row,'numtelof');
				v_text(36)		:= hcm_util.get_string_t(param_json_row,'nummobile');
				v_text(37)		:= hcm_util.get_string_t(param_json_row,'email');
				v_text(38)		:= hcm_util.get_string_t(param_json_row,'lineid');
				v_text(39)		:= hcm_util.get_string_t(param_json_row,'numappl');
				v_text(40)		:= hcm_util.get_string_t(param_json_row,'ocodempid');
				v_text(41)		:= hcm_util.get_string_t(param_json_row,'stadisb');
				v_text(42)		:= hcm_util.get_string_t(param_json_row,'numdisab');
				v_text(43)		:= hcm_util.get_string_t(param_json_row,'typdisp');
				v_text(44)		:= hcm_util.get_string_t(param_json_row,'dtedisb');
				v_text(45)		:= hcm_util.get_string_t(param_json_row,'dtedisen');
				v_text(46)		:= hcm_util.get_string_t(param_json_row,'desdisp');
				v_text(47)		:= hcm_util.get_string_t(param_json_row,'typtrav');
				v_text(48)		:= hcm_util.get_string_t(param_json_row,'qtylength');
				v_text(49)		:= hcm_util.get_string_t(param_json_row,'carlicen');
				v_text(50)		:= hcm_util.get_string_t(param_json_row,'typfuel');
				v_text(51)		:= hcm_util.get_string_t(param_json_row,'codbusno');
				v_text(52)		:= hcm_util.get_string_t(param_json_row,'codbusrt');
				v_text(53)		:= hcm_util.get_string_t(param_json_row,'maillang');
				v_text(54)		:= hcm_util.get_string_t(param_json_row,'flgpdpa');
				v_text(55)		:= hcm_util.get_string_t(param_json_row,'dtepdpa');
                          
                <<cal_loop>> loop      
                    --concat all data values each rows 
                    data_file := v_text(1);
                    for i in 2..v_column loop                     
                        data_file := data_file||','||v_text(i);                     
                    end loop;
                                        
                    --1.validate --                                
                    for i in 1..v_column loop
                        --check require data column
                        if i in (1,2,3,4,5,6,9,10,11,13,15,16,17,18,20,21,22,23,24,25,26,27,28,29,30,31) then  
                            if v_text(i) is  null or length(trim(v_text(i))) is null then
                                v_error	 	:= true;
                                v_err_code  := 'HR2045';
                                v_err_field := v_field(i); --ต้องแก้เก็บ error ทั้งหมด
                                exit cal_loop;
                            end if;
                        end if;
                    
                        --check length all columns     
                        if v_text(i) is not null or length(trim(v_text(i))) is not null then                               
                            if length(v_text(i)) > chk_len(i) then                                
                                v_error	 	:= true;
                                v_err_code  := 'HR2020';
                                v_err_field := v_field(i);
                                exit cal_loop;
                            end if;   
                        end if;

                        --check date format
                        if i in (9,13,14,19,29,30,31,32,33) then
                            if v_text(i) is not null or length(trim(v_text(i))) is not null then
                                if check_date(v_text(i)) then                         
                                    v_error	 	:= true;
                                    v_err_code  := 'HR2020';
                                    v_err_field := v_field(i);
                                    exit cal_loop;                    
                                end if;  
                            end if;
                        end if;
                    end loop;	
										
					--assign value to var
					v_codempid		:= v_text(1);
					v_codtitle		:= v_text(2);
					v_namfirste		:= v_text(3);
					v_namfirstt		:= v_text(4);
					v_namlaste		:= v_text(5);
					v_namlastt		:= v_text(6);
					v_nickname		:= v_text(7);
					v_nicknamt		:= v_text(8);
					v_dteempdb	:= v_text(9);
					if v_text(9) is not null or length(trim(v_text(9))) is not null then
						v_dteempdb	:= check_dteyre(v_text(9));
					end if; 						
					--v_stamarry     := v_text(10);
					v_codsex		:= v_text(11);
					v_stamilit		:= v_text(12);
					if v_codsex = 'F' then
						v_stamilit	:= null;
					end if;
					v_dteempmt		:= v_text(13);
					if v_text(13) is not null or length(trim(v_text(13))) is not null then
						v_dteempmt	:= check_dteyre(v_text(13));
					end if;
					v_dteretire		:= v_text(14);
					if v_text(14) is not null or length(trim(v_text(14))) is not null then
						v_dteretire	:= check_dteyre(v_text(14));
					end if;
					v_codcomp		:= v_text(15);
					v_codpos		:= v_text(16);
					v_numlvl		:= v_text(17);
					v_staemp		:= v_text(18);
					v_dteeffex		:= v_text(19);
					if v_text(19) is not null or length(trim(v_text(19))) is not null then
						v_dteeffex	:= check_dteyre(v_text(19));
					end if;
					v_flgatten		:= v_text(20);
					v_codbrlc		:= v_text(21);
					v_codempmt		:= v_text(22);
					v_typpayroll	:= v_text(23);
					v_typemp		:= v_text(24);
					v_codcalen		:= v_text(25);
					v_codjob		:= v_text(26);
					v_jobgrade		:= v_text(27);
					v_codgrpgl		:= v_text(28);
					v_dteeflvl		:= v_text(29);
					if v_text(29) is not null or length(trim(v_text(29))) is not null then
						v_dteeflvl	:= check_dteyre(v_text(29));
					end if;
					v_dteefpos		:= v_text(30);
					if v_text(30) is not null or length(trim(v_text(30))) is not null then
						v_dteefpos	:= check_dteyre(v_text(30));
					end if;
					v_dteefstep		:= v_text(31);
					if v_text(31) is not null or length(trim(v_text(31))) is not null then
						v_dteefstep	:= check_dteyre(v_text(31));
					end if;
					v_dteduepr		:= v_text(32);
					if v_text(32) is not null or length(trim(v_text(32))) is not null then
						v_dteduepr	:= check_dteyre(v_text(32));
					end if;		
					v_dteoccup		:= v_text(33);
					if v_text(33) is not null or length(trim(v_text(33))) is not null then
						v_dteoccup	:= check_dteyre(v_text(33));
					end if;				
					v_qtydatrq		:= v_text(34);
					v_numtelof		:= v_text(35);
					v_nummobile	:= v_text(36);
					v_email			:= v_text(37);
					v_lineid		    := v_text(38);
					v_numappl		:= v_text(39);
					v_ocodempid	:= v_text(40);
					v_stadisb		:= v_text(41);
					v_numdisab		:= v_text(42);
					v_typdisp		:= v_text(43);
					v_dtedisb		:= v_text(44);
					if v_text(44) is not null or length(trim(v_text(44))) is not null then
						v_dtedisb	:= check_dteyre(v_text(44));
					end if;	
					v_dtedisen		:= v_text(45);
					if v_text(45) is not null or length(trim(v_text(45))) is not null then
						v_dtedisen	:= check_dteyre(v_text(45));
					end if;	
					v_desdisp		:= v_text(46);
					v_typtrav		:= v_text(47);
					v_qtylength		:= v_text(48);
					v_carlicen		:= v_text(49);
					v_typfuel		:= v_text(50);
					v_codbusno		:= v_text(51);
					v_codbusrt		:= v_text(52);
					v_maillang		:= v_text(53);
					v_flgpdpa		:= v_text(54);
					v_dtepdpa		:= v_text(55);
					if v_text(55) is not null or length(trim(v_text(55))) is not null then
						v_dtepdpa	:= check_dteyre(v_text(55));
					end if;	
					
                    
                    --check incorrect data      
                    --check codtitle  
                    if v_codtitle not in ('003','004','005') then
                        v_error	 	   := true;
                        v_err_code    := 'HR2020';
                        v_err_field     := v_field(5);
                        exit cal_loop;
                    end if;
                           
                    --check dteempdb 
					select floor(months_between(sysdate, v_dteempdb) /12) into v_int_temp from dual;
					if v_int_temp < 18 then
						v_error	 	:= true;
                        v_err_code  := 'PM0014';
                        v_err_field := v_field(9);                                
                        exit cal_loop;
					end if;
                    
					--check stamarry 
                    if(v_stamarry not in ('S','M','D','W','I')) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(10);
                        exit cal_loop;
                    end if;
					
					--check codsex 
                    if(v_codsex not in ('M','F')) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(8);
                        exit cal_loop;
                    end if;
					 
					--check stamilit 
                    if(v_codsex = 'M' and ((v_stamilit is null) or length(trim(v_stamilit)) is null)) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(12);
                        exit cal_loop;
                    end if;
					
					if(v_codsex = 'M' and v_stamilit not in ('P','N','O') ) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(12);
                        exit cal_loop;
                    end if;
					
					--check codcomp				
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcenter  
                        where codcomp  = v_codcomp;
                    exception when no_data_found then  
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(15);
                        v_err_table := 'TCENTER';
                        exit cal_loop;
                    end;
					
					--check codpos				
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tpostn   
                        where codpos  = v_codpos;
                    exception when no_data_found then  
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(15);
                        v_err_table := 'TPOSTN';
                        exit cal_loop;
                    end;					
                        
					--check staemp 
                    if(v_staemp not in ('0','1','3','9')) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(18);
                        exit cal_loop;
                    end if;
                    					
					--check dteeffex 
                    if(v_staemp = '9' and ((v_dteeffex is null) or length(trim(v_dteeffex)) is null)) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(19);
                        exit cal_loop;
                    end if;
					
					if((v_dteeffex is not null) or length(trim(v_dteeffex)) is not null) then
						if v_dteeffex < v_dteempmt then
							v_error	 	:= true;
							v_err_code  := 'HR5017';
							v_err_field := v_field(19);
							exit cal_loop;
						end if;	
                    end if;
					
					--check flgatten 
                    if(v_flgatten not in ('Y','N','O')) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(20);
                        exit cal_loop;
                    end if;
										
                    --check codbrlc 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodloca  
                        where codcodec = v_codbrlc;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(21);
                        v_err_table := 'TCODLOCA';
                        exit cal_loop;
                    end;
                    
                    --check codempmt 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodempl   
                        where codcodec = v_codempmt;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(22);
                        v_err_table := 'TCODEMPL';
                        exit cal_loop;
                    end;

					--check typpayroll 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodtypy    
                        where codcodec = v_typpayroll;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(23);
                        v_err_table := 'TCODTYPY';
                        exit cal_loop;
                    end;

					--check typemp 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodcatg     
                        where codcodec = v_typemp;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(24);
                        v_err_table := 'TCODCATG';
                        exit cal_loop;
                    end;

					--check codcalen 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodwork      
                        where codcodec = v_codcalen;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(25);
                        v_err_table := 'TCODWORK';
                        exit cal_loop;
                    end;
					
					--check codjob 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tjobcode       
                        where codjob = v_codjob;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(26);
                        v_err_table := 'TJOBCODE';
                        exit cal_loop;
                    end;
					
                    --check jobgrade 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from TCODJOBG        
                        where codcodec = v_jobgrade;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(27);
                        v_err_table := 'TCODJOBG';
                        exit cal_loop;
                    end;
					
					--check codgrpgl 
                    v_chk_exists := 0;
                    begin 
                        select 1 into v_chk_exists from tcodgrpgl         
                        where codcodec = v_codgrpgl;
                    exception when no_data_found then 
                        v_error	 	:= true;
                        v_err_code  := 'HR2010';
                        v_err_field := v_field(28);
                        v_err_table := 'TCODGRPGL';
                        exit cal_loop;
                    end;
					
					--check dteduepr 
                    if(v_staemp in ('1','3') and ((v_dteduepr is null) or length(trim(v_dteduepr)) is null)) then
                        v_error	 	:= true;
                        v_err_code  := 'HR2045';
                        v_err_field := v_field(32);
                        exit cal_loop;
                    end if;
					
					--check stadisb 
                    if v_stadisb is not null or length(trim(v_stadisb)) is not null then
                        if v_stadisb not in ('Y','N') then
                            v_error	 	:= true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(41);
                            exit cal_loop;
                        end if;
                    end if;
					
					--check flgpdpa 
                     if v_flgpdpa is not null or length(trim(v_flgpdpa)) is not null then
                        if v_flgpdpa not in ('Y','N' )then
                            v_error	 	:= true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(54);
                            exit cal_loop;
                        end if;
                    end if;
					
					--check numdisab, typdisp, dtedisb, dtedisen, desdisp
					 if v_flgpdpa = 'Y' then
						 for i in 42..46 loop
							if (v_text(i) is null or length(trim(v_text(i))) is null) then
								v_error	 	:= true;
								v_err_code  := 'HR2045';
								v_err_field := v_field(i);
								exit cal_loop;
							end if;
						 end loop;
					 end if;
					 
					 --check typdisp 
                    if v_typdisp is not null or length(trim(v_typdisp)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcoddisp       
                            where codcodec = v_typdisp;
                        exception when no_data_found then 
                            v_error	 	:= true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(43);
                            v_err_table := 'TCODDISP';
                            exit cal_loop;
                        end;
					 end if;
					 					 
					--check typtrav 
                    if v_typtrav is not null or length(trim(v_typtrav)) is not null then
                        if(v_typtrav not in ('1','2','3'))then
                            v_error	 	:= true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(47);
                            exit cal_loop;
                        end if; 
                    end if; 
					 
					--check typfuel 
                    if v_typfuel is not null or length(trim(v_typfuel)) is not null then
                        if(v_typfuel not in ('1','2'))then
                            v_error	 	:= true;
                            v_err_code  := 'HR2020';
                            v_err_field := v_field(50);
                            exit cal_loop;
                        end if; 
                    end if;

					--check cobusno 
                    if v_codbusno is not null or length(trim(v_codbusno)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodbusno        
                            where codcodec = v_codbusno;
                        exception when no_data_found then 
                            v_error	 	:= true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(51);
                            v_err_table := 'TCODBUSNO';
                            exit cal_loop;
                        end;
                    end if;
					
					--check cobusrt 
                    if v_codbusrt is not null or length(trim(v_codbusrt)) is not null then
                        v_chk_exists := 0;
                        begin 
                            select 1 into v_chk_exists from tcodbusrt         
                            where codcodec = v_codbusrt;
                        exception when no_data_found then 
                            v_error	 	:= true;
                            v_err_code  := 'HR2010';
                            v_err_field := v_field(52);
                            v_err_table := 'TCODBUSRT';
                            exit cal_loop;
                        end;
                    end if;
					
					--check maillang 
                    if(v_maillang not in ('101','102'))then
                        v_error	 	:= true;
                        v_err_code  := 'HR2020';
                        v_err_field := v_field(53);
                        exit cal_loop;
                    end if; 
                    
                    exit cal_loop;
                end loop;
                                 
                --2.crud table--
                if not v_error then      
					
					v_namfirst3	    := v_namfirste;
					v_namfirst4	    := v_namfirste;
					v_namfirst5 	:= v_namfirste;
					v_namlast3  	:= v_namlaste;
					v_namlast4  	:= v_namlaste;
					v_namlast5 	:= v_namlaste;
					v_namempe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'101'))) || ltrim(rtrim(v_namfirste))||' '||ltrim(rtrim(v_namlaste)),1,60);
					v_namempt   	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'102'))) || ltrim(rtrim(v_namfirstt))||' '||ltrim(rtrim(v_namlastt)),1,60);
					v_namemp3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'103'))) || ltrim(rtrim(v_namfirst3))||' '||ltrim(rtrim(v_namlast3)),1,60);
					v_namemp4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'104'))) || ltrim(rtrim(v_namfirst4))||' '||ltrim(rtrim(v_namlast4)),1,60);
					v_namemp5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',v_codtitle,'105'))) || ltrim(rtrim(v_namfirst5))||' '||ltrim(rtrim(v_namlast5)),1,60);
					v_nicknam3	    := v_nickname;
					v_nicknam4 	:= v_nickname;
					v_nicknam5  	:= v_nickname;
					v_codcompr	:= null;
					v_codposre	    := null;
					v_numreqst	    := null;
					v_flgreemp	    := null;
					v_dtereemp  	:= null;
					v_dteredue	    := null;
					v_qtywkday  	:= null;
					v_codedlv	    := null;
					v_codmajsb	    := null;
					v_numreqc	    := null;
					v_codposc	    := null;
					v_flgreq	        := null;
					v_stareq	        := null;
					v_codappr	    := null;
					v_dteappr	    := null;
					v_staappr	    := null;
					v_remarkap  	:= null;
					v_codreq	    := null;
					v_approvno  	:= null;
					                    
                    begin 
						delete from temploy1 where codempid  = v_codempid;                        
													 
						insert into temploy1(codempid,codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                                        namlaste,namlastt,namlast3,namlast4,namlast5,
                                                        namempe,namempt,namemp3,namemp4,namemp5,
                                                        nickname,nicknamt,nicknam3,nicknam4,nicknam5,
                                                        dteempdb,stamarry,codsex,stamilit,dteempmt,
                                                        dteretire,codcomp,codpos,numlvl,staemp,
                                                        dteeffex,flgatten,codbrlc,codempmt,typpayroll,
                                                        typemp,codcalen,codjob,codcompr,codposre,
                                                        dteeflvl,dteefpos,dteduepr,dteoccup,qtydatrq,
                                                        numtelof,nummobile,email,lineid,numreqst,numappl,
                                                        ocodempid,flgreemp,dtereemp,dteredue,qtywkday,codedlv,
                                                        codmajsb,numreqc,codposc,flgreq,stareq,codappr,
                                                        dteappr,staappr,remarkap,codreq,jobgrade,dteefstep,
                                                        codgrpgl,stadisb,numdisab,typdisp,dtedisb,dtedisen,
                                                        desdisp,typtrav,qtylength,carlicen,typfuel,codbusno,
                                                        codbusrt,maillang,dteprgntst,flgpdpa,dtepdpa,approvno,
                                                        dtecreate, codcreate, dteupd, coduser)  
                                        values  (v_codempid,v_codtitle,v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,
                                                        v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,
                                                        v_namempe,v_namempt,v_namemp3,v_namemp4,v_namemp5,
                                                        v_nickname,v_nicknamt,v_nicknam3,v_nicknam4,v_nicknam5,
                                                        v_dteempdb,v_stamarry,v_codsex,v_stamilit,v_dteempmt,
                                                        v_dteretire,v_codcomp,v_codpos,v_numlvl,v_staemp,
                                                        v_dteeffex,v_flgatten,v_codbrlc,v_codempmt,v_typpayroll,
                                                        v_typemp,v_codcalen,v_codjob,v_codcompr,v_codposre,
                                                        v_dteeflvl,v_dteefpos,v_dteduepr,v_dteoccup,v_qtydatrq,
                                                        v_numtelof,v_nummobile,v_email,v_lineid,v_numreqst,v_numappl,
                                                        v_ocodempid,v_flgreemp,v_dtereemp,v_dteredue,v_qtywkday,v_codedlv,
                                                        v_codmajsb,v_numreqc,v_codposc,v_flgreq,v_stareq,v_codappr,
                                                        v_dteappr,v_staappr,v_remarkap,v_codreq,v_jobgrade,v_dteefstep,
                                                        v_codgrpgl,v_stadisb,v_numdisab,v_typdisp,v_dtedisb,v_dtedisen,
                                                        v_desdisp,v_typtrav,v_qtylength,v_carlicen,v_typfuel,v_codbusno,
                                                        v_codbusrt,v_maillang,v_dteprgntst,v_flgpdpa,v_dtepdpa,v_approvno,
                                                        trunc(sysdate), global_v_coduser, trunc(sysdate), global_v_coduser);	
											
                    end;
                else        
                    p_rec_error := p_rec_error + 1;                   
                    v_cnt := v_cnt + 1;                    
                    p_text(v_cnt) := data_file;                    
                    p_error_code(v_cnt) := '[' || v_err_field || '] - ' || replace(get_error_msg_php(v_err_code, global_v_lang, v_err_table, null, false), '@#$%400', null);
                    p_numseq(v_cnt) := i; 
                end if;            
            
                commit;
            exception when others then  
                param_msg_error := get_error_msg_php('HR2508',global_v_lang);                  
            end;
		end loop;  
       
	end;	
  
  function get_result(p_rec_tran   in number,
                      p_rec_err    in number) return clob is     
    obj_row    json_object_t;
    obj_data   json_object_t;
    obj_result json_object_t;
    v_rcnt     number := 0;
  begin
    if param_msg_error is null then
      obj_row := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      if v_msgerror is null then
        obj_row.put('rec_tran', p_rec_tran);
        obj_row.put('rec_err', p_rec_err);
        obj_row.put('response', replace(get_error_msg_php('HR2715', global_v_lang), '@#$%200', null));
      else
        obj_row.put('response', v_msgerror);
        obj_row.put('flg', 'warning');
      end if;

      --??
      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first..p_numseq.last loop
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt - 1), obj_data);
        end loop;
      end if;
      
      obj_row.put('datadisp', obj_result);
      return obj_row.to_clob;
    else
     return get_response_message('400', param_msg_error, global_v_lang);
    end if;
  end;
END HRCOCVB;

/

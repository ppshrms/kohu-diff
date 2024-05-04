--------------------------------------------------------
--  DDL for Package Body HRMS13X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS13X" is
-- last update: 23/05/2017 15:16
  procedure initial_value(json_str in clob) as
    json_obj      json_object_t;
    json_obj2     json_object_t;
  begin
    json_obj                := json_object_t(json_str);
    -- global
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');

    -- index
    b_index_codempid      := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp'); -- ___001%
    b_index_sql_statement := hcm_util.get_string_t(json_obj,'p_sql_statement');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  PROCEDURE check_index IS
    flgpass 	boolean;
    v_codcomp tcenter.codcomp%type := null;
    v_where 	varchar2(25) := null;
    ab 				VARCHAR2(50);
    chk  			NUMBER;
    v_codtency   varchar2(10);
  BEGIN
    if b_index_codempid is null  and b_index_codcomp is null and b_index_sql_statement is null  then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;

    if b_index_codempid is not null then
       begin
          select codempid
          into  b_index_codempid
          from  temploy1
          where codempid = b_index_codempid ;
       exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
       end ;
       begin
          flgpass := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if  not flgpass then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
          end if;
       end;

       b_index_sql_statement  := '';
       b_index_codcomp        := null;
     end if;
     if b_index_codcomp is not null then
         param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
         if param_msg_error is not null then return; end if;
     end if;
  end;
  --
  procedure gen_data (json_str_output out clob) is
    v_cursor	  number;
    v_secur     varchar2(1) := 'Y';
    v_num1			number 		 := 0;
	  v_where     varchar2(100);
	  v_statment  varchar2(4000);
	  v_dummy     integer;
	  v_flgpass	  boolean;
    v_codapp		varchar2(100) := 'HRPM81X';
	  v_data_file varchar2(2500);
	  v_data      varchar2(1) := 'N';
	  v_std_col   number := 7;
    type descol is table of varchar2(2500) index by binary_integer;
    data_file 	descol;
	  v_sql_statement  varchar2(4000);
	  flgincome	  varchar2(1);
	  v_zupdsal   varchar2(1);
	  v_flgsal		boolean;

    v_rcnt      number;
    obj_row     json_object_t;
    obj_data    json_object_t;
  begin
    v_rcnt := 0;
    obj_row := json_object_t();

	  if b_index_codempid is not null then
	  	 v_sql_statement := ' codempid ='''||b_index_codempid ||'''' ;
	  else
	  	if b_index_codcomp is not null then
	  	    v_sql_statement := ' codcomp like '''||b_index_codcomp ||'%''' ;
	  	   if b_index_sql_statement is not null then
	  	      v_sql_statement := v_sql_statement||' and '||replace(b_index_sql_statement,'V_HRMS11','b');
         end if;
	  	else
		  	 v_sql_statement := replace(b_index_sql_statement,'V_HRMS11','b');
		  end if;
	  end if;

	  if v_sql_statement like '%NAMFIRSTE%' then
	  	 if  global_v_lang = '102' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMFIRSTE','NAMFIRSTT') ;
	  	 elsif  global_v_lang = '103' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMFIRSTE','NAMFIRST3') ;
	  	 elsif  global_v_lang = '104' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMFIRSTE','NAMFIRST4') ;
	  	 elsif  global_v_lang = '105' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMFIRSTE','NAMFIRST5') ;
	  	 end if;
	  end if;
	  if v_sql_statement like '%NAMLASTE%' then
	  	 if  global_v_lang = '102' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMLASTE','NAMLASTT') ;
	  	 elsif  global_v_lang = '103' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMLASTE','NAMLAST3') ;
	  	 elsif  global_v_lang = '104' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMLASTE','NAMLAST4') ;
	  	 elsif  global_v_lang = '105' then
	  	 	   v_sql_statement := replace(v_sql_statement,'NAMLASTE','NAMLAST5') ;
	  	 end if;

	  end if;

	  v_statment := 'select a.codempid, get_temploy_name(a.codempid,'||global_v_lang||'), '||
   	              'get_tcenter_name(a.codcomp,'||global_v_lang||'), '||
   	              'get_tpostn_name(a.codpos,'||global_v_lang||'), '||
   	              'a.numlvl, to_char(a.dteempmt,''dd/mm/yyyy''), a.codcomp'||
   	              ' from temploy1 a'||
   	              ' where a.codempid in (select b.codempid from v_hrms11 b'||
   	                                   ' where '||v_sql_statement||
   	                                   '   and a.codempid = b.codempid)'||
                  '  and a.staemp in (''1'',''3'')'||
   	              ' order by codempid';
	--User8/Nirantee Modify check secur 22/08/2011 13:50
 		if 	v_sql_statement like '%AMTINCOM%' then
 			  flgincome := 'Y';
 		else
 				flgincome := 'N';
		end if;

	--User8/Nirantee Modify check secur 22/08/2011 13:50
    v_cursor  := dbms_sql.open_cursor;
    dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);
    for j in 1..(v_std_col) loop
        dbms_sql.define_column(v_cursor,j,v_data_file,250);
		end loop;
    v_dummy := dbms_sql.execute(v_cursor);
    while (dbms_sql.fetch_rows(v_cursor) > 0) loop
      v_data := 'Y';
      dbms_sql.column_value(v_cursor,7,v_data_file);
      data_file(7)  := v_data_file ;

      dbms_sql.column_value(v_cursor,5,v_data_file);
      data_file(5)  := v_data_file ;
      v_flgpass := secur_main.secur1(data_file(7),data_file(5),global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal);
      if v_flgpass = true then
        if flgincome = 'Y' then
            v_flgsal	:=	secur_main.secur1(data_file(7),data_file(5),global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            if v_zupdsal = 'Y' then  	--User8/Nirantee Modify check secur 22/08/2011 13:50
               v_secur  := 'Y';
               v_num1   := v_num1 + 1;
               for j in 1..v_std_col loop
                  dbms_sql.column_value(v_cursor,j,v_data_file);
                  data_file(j) := v_data_file;
               end loop;
               v_rcnt := nvl(v_rcnt,0) + 1;
               ttemfilt_item01  := data_file(1);
               ttemfilt_item02  := data_file(2);
               ttemfilt_item03  := data_file(3);
               ttemfilt_item04  := data_file(4);
               ttemfilt_item05  := data_file(5);
               ttemfilt_date01  := to_date(data_file(6),'dd/mm/yyyy');
               ttemfilt_numseq  := v_rcnt;
               ttemfilt_codapp  := v_codapp;
               ttemfilt_coduser := global_v_coduser;
               --
               obj_data := json_object_t();
               obj_data.put('coderror','200');
               obj_data.put('desc_coderror','');
               obj_data.put('httpcode','');
               obj_data.put('flg','');
               obj_data.put('total', v_num1);
               obj_data.put('image',get_emp_img(ttemfilt_item01));
               obj_data.put('codempid',ttemfilt_item01);
               obj_data.put('desc_codempid',ttemfilt_item02);
               obj_data.put('desc_codcomp',ttemfilt_item03);
               obj_data.put('desc_codpos',ttemfilt_item04);
               obj_data.put('numlvl',ttemfilt_item05);
               obj_data.put('dteempmt',to_char(ttemfilt_date01,'dd/mm/yyyy'));

               obj_row.put(to_char(v_rcnt-1),obj_data);
               --next_record;
            end if;
          elsif flgincome = 'N' then
               v_secur  := 'Y';
               v_num1   := v_num1 + 1;
               for j in 1..v_std_col loop
                   dbms_sql.column_value(v_cursor,j,v_data_file);
                   data_file(j) := v_data_file;
               end loop;
               v_rcnt := nvl(v_rcnt,0) + 1;
               ttemfilt_item01  := data_file(1);
               ttemfilt_item02  := data_file(2);
               ttemfilt_item03  := data_file(3);
               ttemfilt_item04  := data_file(4);
               ttemfilt_item05  := data_file(5);
               ttemfilt_date01  := to_date(data_file(6),'dd/mm/yyyy');
               ttemfilt_numseq  := v_rcnt;
               ttemfilt_codapp  := v_codapp;
               ttemfilt_coduser := global_v_coduser;
               --
               obj_data := json_object_t();
               obj_data.put('coderror','200');
               obj_data.put('desc_coderror','');
               obj_data.put('httpcode','');
               obj_data.put('flg','');
               obj_data.put('total', v_num1);
               obj_data.put('image',get_emp_img(ttemfilt_item01));
               obj_data.put('codempid',ttemfilt_item01);
               obj_data.put('desc_codempid',ttemfilt_item02);
               obj_data.put('desc_codcomp',ttemfilt_item03);
               obj_data.put('desc_codpos',ttemfilt_item04);
               obj_data.put('numlvl',ttemfilt_item05);
               obj_data.put('dteempmt',to_char(ttemfilt_date01,'dd/mm/yyyy'));

               obj_row.put(to_char(v_rcnt-1),obj_data);
               --next_record;
        end if;
     end if;

    end loop; -- end while

		if v_secur = 'N' then
			obj_row := json_object_t();
      obj_row.put('coderror','400');
      obj_row.put('desc_coderror',get_error_msg_php('HR3007',global_v_lang));
		end if;
    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    else
      json_str_output := obj_row.to_clob;
    end if;
    --resp_json_str := obj_row.to_char;
--    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str in clob, json_str_output out clob) as
  begin
    initial_value(json_str);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/

--------------------------------------------------------
--  DDL for Package Body HRAP3RB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3RB" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
    param_search    json_object_t;--User37 #4460 14/09/2021 
  begin
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    b_index_filename    := hcm_util.get_string_t(json_obj, 'p_filename');
    b_index_dteyreap    := hcm_util.get_string_t(json_obj, 'p_dteyreap');
    b_index_numtime     := hcm_util.get_string_t(json_obj, 'p_numtime');
    b_index_derimiter   := hcm_util.get_string_t(json_obj, 'p_erimiter');  
    b_index_dteimpot    := to_date(hcm_util.get_string_t(json_obj,'p_dteimpot'),'dd/mm/yyyy hh24:mi:ss');   
    b_index_codimpot    := global_v_codempid;

    v_column(1)           := 'codempid';
    v_column(2)           := 'codcomp';   
    v_column(3)           := 'codaplvl';
    v_column(4)           := 'qtybeh';
    v_column(5)           := 'qtycmp';
    v_column(6)           := 'qtykpic';
    v_column(7)           := 'qtykpid';
    v_column(8)           := 'qtykpie';
    v_column(9)           := 'remark';
    --<< #7893||USER39}}26/04/2022
    for i in 1..20 loop
       v_text(i) := null;
       v_head(i) := null;
    end loop;
    -- #7893||USER39}}26/04/2022

    --<<User37 #4460 14/09/2021 
    param_search      := hcm_util.get_json_t(json_obj, 'search');
    b_index_dteyreap  := to_number(hcm_util.get_string_t(param_search,'year'));
    b_index_numtime   := to_number(hcm_util.get_string_t(param_search,'no'));
    param_upload      := hcm_util.get_json_t(param_search, 'uploadfile');
    -->>User37 #4460 14/09/2021 

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  function check_submit return varchar2 is
    v_errorfile         varchar2(100 char);
    linebuf  	        varchar2(6000 char);
    data_file 		    varchar2(6000 char);
    v_error				boolean;
    v_exist				boolean;
    v_codempid		    temploy1.codempid%type;
    v_codcomp		    temploy1.codcomp%type;
    v_staemp            temploy1.staemp%type;
    v_qtybeh            tappemp.qtybeh%type;
    v_qtycmp            tappemp.qtycmp%type;
    v_qtykpic           tappemp.qtykpic%type;
    v_qtykpid           tappemp.qtykpid%type;
    v_qtykpie           tappemp.qtykpie%type;
    v_remark    	    varchar2(30000 char);--User37 #4460 14/09/2021 tappemp.remark%type;
    v_flgsecu			boolean;
    v_zupdsal   	    varchar2(4 char) ;
    v_flg_error         varchar2(2000 char);
    v_update            varchar2(1 char);
    v_max               number;
  begin
    v_error 	 := false;
    v_remark     := null;
    v_total      := v_total + 1;
    v_codempid 	 := upper(trim(substr(v_text(1),1,10))); 

    --<<User37 #4460 14/09/2021 
    /*for i in 1..9 loop
        if i  in (1,2,3) then
            if v_text(i) is null then
                v_error     := true;
                v_remark    := get_errorm_name('HR2045',global_v_lang)||' ('||v_head(i)||')';
                v_rec_error := v_rec_error + 1; return  v_remark;
            end if;
        end if;   

        if i = 1 then
            v_error := hcm_validate.check_length(v_text(i),'TEMPLOY1','CODEMPID',v_max);
            if v_error then
                v_remark	:= get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
                v_rec_error := v_rec_error + 1; return  v_remark;
            end if;
            if v_codempid is not null then
                begin
                    select codempid,staemp into v_codempid,v_staemp
                      from temploy1
                     where codempid = v_codempid;
                  if v_staemp = '9' then
                    v_error	  := true;
                    v_remark	:= get_errorm_name('HR2101',global_v_lang);
                    v_rec_error := v_rec_error + 1; return  v_remark;
                  elsif v_staemp = '0' then
                    v_error	  := true;
                    v_remark	:= get_errorm_name('HR2102',global_v_lang);
                    v_rec_error := v_rec_error + 1; return  v_remark;
                  end if;
                exception when no_data_found then
                    v_error	  := true;
                    v_remark	:= get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
                    v_rec_error := v_rec_error + 1; return  v_remark;
                end;                
            end if;
            v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if not v_flgsecu then
                v_error	  := true;
                v_remark	:= get_errorm_name('HR3007',global_v_lang);
                v_rec_error := v_rec_error + 1; return  v_remark;
            end if;
        elsif i = 2 then
            v_text(i) := upper(v_text(i));
            v_error   := hcm_validate.check_length(v_text(i),'tcenter','codcomp',v_max);
            if v_error then
              v_remark	:= get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
              v_rec_error := v_rec_error + 1; return  v_remark;
            end if;
            v_error := hcm_validate.check_tcodcodec('tcenter','codcomp = '''||v_text(i)||''' ');
            if v_error then
              v_remark := get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
              v_rec_error := v_rec_error + 1; return  v_remark;
            end if;    
        elsif i = 3 then
            v_text(i) := upper(v_text(i));
            v_error   := hcm_validate.check_length(v_text(i),'tcodaplv','codcodec',v_max);
            if v_error then
              v_remark	:= get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
              v_rec_error := v_rec_error + 1; return  v_remark;
            end if;
            v_error := hcm_validate.check_tcodcodec('tcodaplv','codcodec = '''||v_text(i)||''' ');
            if v_error then
              v_remark := get_errorm_name('HR2010',global_v_lang)||' (TCODAPLV)';
              v_rec_error := v_rec_error + 1; return  v_remark;
            end if; 
        elsif i in (4,5,6,7,8) then
            if v_text(i) is not null then
                v_error := hcm_validate.check_number(v_text(i));
                if v_error then
                    v_remark := get_errorm_name('HR2816',global_v_lang)||' ('||v_head(i)||' - '||v_text(i)||')';
                    v_rec_error := v_rec_error + 1; return  v_remark;
                end if;
--                v_error :=  hcm_validate.check_length(v_text(i),6);
                if length(v_text(i)) > 6 then
                    v_remark	:= get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: 6)';
                    v_rec_error := v_rec_error + 1; return  v_remark;
                end if; 
                if not v_error then
                    if i = 4 then
                        v_qtybeh := v_text(i);
                    elsif i = 5 then
                        v_qtycmp := v_text(i);
                    elsif i = 6 then
                        v_qtykpic := v_text(i);
                    elsif i = 7 then
                        v_qtykpid := v_text(i);
                    elsif i = 8 then
                        v_qtykpie := v_text(i);
                    end if;
                end if;
            end if;
        end if;       
    end loop;--for i in 1..9 loop

    if v_qtybeh is null and v_qtycmp is null and v_qtykpic is null and v_qtykpid is null and v_qtykpie is null  then
        v_error     := true;
        v_remark    := get_errorm_name('HR2045',global_v_lang)||' ('||v_head(4)||')';
        v_rec_error := v_rec_error + 1; return  v_remark;
    end if;
    if v_qtykpic is not null or v_qtykpid is not null or v_qtykpie is not null then
        if v_qtykpic is null then
            v_error     := true;
            v_remark    := get_errorm_name('HR2045',global_v_lang)||' ('||v_head(6)||')'; 
            v_rec_error := v_rec_error + 1; return  v_remark;
        end if;
        if v_qtykpid is null then
            v_error     := true;
            v_remark    := get_errorm_name('HR2045',global_v_lang)||' ('||v_head(7)||')';   
            v_rec_error := v_rec_error + 1; return  v_remark;
        end if;
        if v_qtykpie is null then
            v_error     := true;
            v_remark    := get_errorm_name('HR2045',global_v_lang)||' ('||v_head(8)||')';    
            v_rec_error := v_rec_error + 1; return  v_remark;
        end if;
    end if;

    return  v_remark;*/
    for i in 1..9 loop
       if i  in (1,2,3) then
            if v_text(i) is not null then
                v_error     := true;
                v_remark    := v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(i)||')';
            end if;
        end if;  

        if i = 1 then
            v_error := hcm_validate.check_length(v_text(i),'TEMPLOY1','CODEMPID',v_max);
            if v_error then
                v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
            end if;
            if v_codempid is not null then
                begin
                    select codempid,staemp into v_codempid,v_staemp
                      from temploy1
                     where codempid = v_codempid;
                  if v_staemp = '9' then
                    v_error	  := true;
                    v_remark	:= v_remark||','||get_errorm_name('HR2101',global_v_lang);
                  elsif v_staemp = '0' then
                    v_error	  := true;
                    v_remark	:= v_remark||','||get_errorm_name('HR2102',global_v_lang);
                  end if;
                exception when no_data_found then
                    v_error	  := true;
                    v_remark	:= v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
                end;                
            end if;
            v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if not v_flgsecu then
                v_error	  := true;
                v_remark	:= v_remark||','||get_errorm_name('HR3007',global_v_lang);
            end if;
        elsif i = 2 then
            v_text(i) := upper(v_text(i));
            v_error   := hcm_validate.check_length(v_text(i),'tcenter','codcomp',v_max);
            if v_error then
              v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
            end if;
            v_error := hcm_validate.check_tcodcodec('tcenter','codcomp = '''||v_text(i)||''' ');
            if v_error then
              v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
            end if;    
        elsif i = 3 then
            v_text(i) := upper(v_text(i));
            v_error   := hcm_validate.check_length(v_text(i),'tcodaplv','codcodec',v_max);
            if v_error then
              v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: '||v_max||')';
            end if;
            v_error := hcm_validate.check_tcodcodec('tcodaplv','codcodec = '''||v_text(i)||''' ');
            if v_error then
              v_remark := v_remark||','||get_errorm_name('HR2010',global_v_lang)||' (TCODAPLV)';
            end if; 
        elsif i in (4,5,6,7,8) then
            if v_text(i) is not null then
                v_error := hcm_validate.check_number(v_text(i));
                if v_error then
                    v_remark := v_remark||','||get_errorm_name('HR2816',global_v_lang)||' ('||v_head(i)||' - '||v_text(i)||')';
                end if;
--                v_error :=  hcm_validate.check_length(v_text(i),6);
                if length(v_text(i)) > 6 then
                    v_remark	:= v_remark||','||get_errorm_name('HR6591',global_v_lang)||' ('||v_head(i)||' Max: 6)';
                end if; 
                if v_remark is null then
                if i = 4 then
                    v_qtybeh := v_text(i);
                elsif i = 5 then
                    v_qtycmp := v_text(i);
                elsif i = 6 then
                    v_qtykpic := v_text(i);
                elsif i = 7 then
                    v_qtykpid := v_text(i);
                elsif i = 8 then
                    v_qtykpie := v_text(i);
                end if;
                end if;
            end if;
        end if;       
    end loop;--for i in 1..9 loop

    if v_qtybeh is null and v_qtycmp is null and v_qtykpic is null and v_qtykpid is null and v_qtykpie is null  then
        v_error     := true;
        v_remark    := v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(4)||')';
    end if;
    if v_qtykpic is not null or v_qtykpid is not null or v_qtykpie is not null then
        if v_qtykpic is null then
            v_error     := true;
            v_remark    := v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(6)||')';        
        end if;
        if v_qtykpid is null then
            v_error     := true;
            v_remark    := v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(7)||')';        
        end if;
        if v_qtykpie is null then
            v_error     := true;
            v_remark    := v_remark||','||get_errorm_name('HR2045',global_v_lang)||' ('||v_head(8)||')';        
        end if;
    end if;

    if v_error then
      v_flg_error := 'Y';
      v_rec_error := v_rec_error + 1;
    else
      v_rec_tran := v_rec_tran + 1;
      v_update    := 'N' ;
      --waiting HRAP31E for process ded score total
      ---------------------------------------------

    end if;
    return  substr(v_remark,2,4000);
    -->>User37 #4460 14/09/2021 
  end check_submit;

  procedure validate_field_submit(json_str_input in clob,json_str_output out clob) is
    json_str            json_object_t;
    param_import        json_object_t;
    param_import_row    json_object_t;
    v_error_remark      varchar2(4000);
    obj_data            json_object_t;
    obj_row             json_object_t;
    --<<User37 #4460 14/09/2021 
    obj_data2           json_object_t;
    obj_data3           json_object_t;
    obj_data4           json_object_t;
    param_import_col    json_object_t;
    data_row            json_object_t;
    data_row2           json_object_t;
    v_new               number  := 0;
    v_unchnge           number  := 0;
    v_edit              number  := 0;
    v_dteyreap          number;
    v_numtime           number;
    v_chk               varchar2(1 char);
    v_qtypuns           number;
    v_qtyta             number; 
    v_pctdbon           number;
    v_pctdsal           number;
    v_flgsal            tappemp.flgsal%type;
    v_flgbonus          tappemp.flgbonus%type;
    -->>User37 #4460 14/09/2021 
    v_rcnt              number  := 0;
    v_date              date  := sysdate;
  begin
    --<<User37 #4460 14/09/2021 
    param_import        := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    param_import_row    := hcm_util.get_json_t(json_object_t(param_import),'dataRows');
    param_import_col    := hcm_util.get_json_t(json_object_t(param_import),'columns');

    json_str    := json_object_t(json_str_input);
    v_dteyreap  := to_number(hcm_util.get_string_t(json_str,'year'));
    v_numtime   := to_number(hcm_util.get_string_t(json_str,'no'));

    obj_data    := json_object_t();
    obj_data2   := json_object_t();

    obj_data.put('coderror','200');
    obj_row     := json_object_t();
    for i in 0..param_import_col.get_size-1 loop
        data_row    := hcm_util.get_json_t(param_import_col,to_char(i));
        v_head(i+1) := hcm_util.get_string_t(data_row,'key');
    end loop;
    for i in 0..param_import_row.get_size-1 loop
      data_row2    := hcm_util.get_json_t(param_import_row,to_char(i));
      for j in 0..param_import_col.get_size-1 loop
        v_text(j+1)         := hcm_util.get_string_t(data_row2,v_head(j+1));
      end loop;
      v_error_remark      := check_submit;
      obj_data3 := json_object_t();
      v_rcnt        := v_rcnt + 1;
      obj_data3.put('coderror','200');
      if v_error_remark is null then
        obj_data3.put('statsicon','<i class="fa fa-check _text-green"></i>');
        obj_data3.put('stats','Y');
        begin
          select 'Y'
            into v_chk
            from tappemp
           where codempid = v_text(1)
             and dteyreap = v_dteyreap
             and numtime = v_numtime;
          begin
            select 'Y'
              into v_chk
              from tappemp
             where codempid = v_text(1)
               and dteyreap = v_dteyreap
               and numtime  = v_numtime
               and qtybeh3  = v_text(4)
               and qtycmp3  = v_text(5)
               and qtykpic  = v_text(6)
               and qtykpid  = v_text(7)
               and qtykpie3 = v_text(8)
               and remark3  = v_text(9);
            v_unchnge := v_unchnge + 1;
          exception when no_data_found then 
            v_edit := v_edit + 1;
          end;
        exception when no_data_found then
          v_new := v_new + 1;
        end;
        obj_data3.put('remark',v_text(9));
        p_codempid := upper(v_text(1));
        p_codcomp := upper(v_text(2));
        p_codaplvl := upper(v_text(3));
      else
        obj_data3.put('statsicon','<i class="fa fa-times _text-red"></i>');
        obj_data3.put('stats','N');
        obj_data3.put('remark',v_error_remark);
        p_codempid := null;
        p_codcomp := null;
        p_codaplvl := null;
      end if;
      obj_data3.put('codempid',p_codempid);
      obj_data3.put('desc_codempid',get_temploy_name(v_text(1),global_v_lang));
      gen_workingtime_detail(v_qtypuns,v_qtyta,v_pctdbon,v_pctdsal,v_flgsal,v_flgbonus);
      obj_data3.put('wrktme',v_qtyta);
      obj_data3.put('brektme',v_qtypuns);
      obj_data3.put('flgsal',nvl(v_flgsal,'Y'));
      obj_data3.put('flgbonus',nvl(v_flgbonus,'N'));
      obj_data3.put('pctdbon',v_pctdbon);
      obj_data3.put('pctdsal',v_pctdsal);
      obj_data3.put('codcomp',p_codcomp);
      obj_data3.put('codaplvl',p_codaplvl);
      obj_data3.put('qtybeh',v_text(4));
      obj_data3.put('qtycmp',v_text(5));
      obj_data3.put('qtykpic',v_text(6));
      obj_data3.put('qtykpid',v_text(7));
      obj_data3.put('qtykpie',v_text(8));
      obj_row.put(to_char(v_rcnt - 1), obj_data3);
    end loop;

--    obj_data2.put('dtetim',to_date('10/05/2021','dd/mm/yyyy'));
    obj_data2.put('dtetim',to_char(hcm_util.get_date_buddhist_era(v_date) || ' ' ||to_char(v_date,'HH24:MI')));
    obj_data2.put('total',v_rcnt);
    obj_data2.put('new',v_new);
    obj_data2.put('error',v_rec_error);
    obj_data2.put('unchnge',v_unchnge);
    obj_data2.put('edit',v_edit);
    obj_data.put('detail',obj_data2);
    obj_data4 := json_object_t();
    if v_rcnt = 0 then
      obj_data4.put('rows','[]');
    else
      obj_data4.put('rows',obj_row);
    end if;
    obj_data.put('table',obj_data4);
    json_str_output := obj_data.to_clob;
    /*param_import    := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    obj_row         := json_object_t();

    for i in 1..9 loop
      v_head(i)   := get_label_name('HRAP3RBC2',global_v_lang, to_char((i*10)));
    end loop;
    for i in 0..param_import.get_size-1 loop
      obj_data      := json_object_t();
      v_rcnt        := v_rcnt + 1;
      obj_data.put('coderror','200');
      param_import_row    := hcm_util.get_json_t(param_import,to_char(i));
      for k in 1..v_column.count loop
        v_text(k)         := hcm_util.get_string_t(param_import_row,v_column(k));
        obj_data.put(v_column(k),v_text(k));
      end loop;
      v_error_remark      := substr(check_submit,500);
      if v_error_remark is not null then
        obj_data.put('flgerror','Y');
        obj_data.put('descerror',v_error_remark);
      else
        obj_data.put('flgerror','N');
        obj_data.put('descerror','');
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_row.to_clob;*/
    -->>User37 #4460 14/09/2021 
  end;

  procedure submit_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    validate_field_submit(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure insupd_tappemp(p_new out number,p_no_change out number,p_update out number) is

    v_update        varchar2(1 char);
    v_codempid      temploy1.codempid%type;
    v_exist		    boolean := false;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_numlvl        temploy1.numlvl%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c_tappemp is
        select codempid,dteyreap,numtime,qtybeh3,qtycmp3,qtykpie3,qtykpic,qtykpid
          from tappemp
         where codempid = v_codempid
           and dteyreap = b_index_dteyreap
           and numtime  = b_index_numtime;

  begin
    --<<User37 #4460 14/09/2021 
    v_codempid 	:= upper(p_codempid);
    for r_tappemp in c_tappemp loop
      v_exist   := true;           
      if r_tappemp.qtybeh3 	 = nvl(p_qtybeh,r_tappemp.qtybeh3)  and
        r_tappemp.qtycmp3 	 = nvl(p_qtycmp,r_tappemp.qtycmp3)  and              
        r_tappemp.qtykpic 	 = nvl(p_qtykpic,r_tappemp.qtykpic)  and
        r_tappemp.qtykpid 	 = nvl(p_qtykpid,r_tappemp.qtykpid)  and
        r_tappemp.qtykpie3 	 = nvl(p_qtykpie,r_tappemp.qtykpie3) then
        p_no_change    := p_no_change + 1; 
      else
        v_update := 'Y' ;
      end if;
    end loop;

    if not v_exist then
      begin
        select codcomp,codpos,numlvl,jobgrade 
          into v_codcomp,v_codpos,v_numlvl,v_jobgrade
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;

      insert into tappemp (codempid,dteyreap,numtime,
                           codcomp,codpos,numlvl,
                           codaplvl,jobgrade,flgappr,
                           qtybeh3,qtycmp3,qtykpic,
                           qtykpid,qtykpie3,qtytot3,
                           qtyta,qtypuns,flgsal,
                           flgbonus,pctdbon,pctdsal,
                           remark3,codcreate,coduser)
                   values (v_codempid,b_index_dteyreap,b_index_numtime,
                           v_codcomp,v_codpos,v_numlvl,
                           p_codaplvl,v_jobgrade,'C',
                           p_qtybeh,p_qtycmp,p_qtykpic,
                           p_qtykpid,p_qtykpie,(nvl(p_qtybeh,0) + nvl(p_qtycmp,0) + nvl(p_qtykpie,0)),
                           p_qtyta,p_qtypuns,p_flgsal,
                           p_flgbonus,p_pctdbon,p_pctdsal,
                           p_remark,global_v_coduser,global_v_coduser);
      p_new   := p_new + 1;
    elsif v_update = 'Y' then
      update tappemp set qtybeh3      = p_qtybeh,
                         qtycmp3      = p_qtycmp,
                         qtykpic      = p_qtykpic,
                         qtykpid      = p_qtykpid,  
                         qtykpie3     = p_qtykpie,
                         qtytot3      = nvl(p_qtybeh,0) + nvl(p_qtycmp,0) + nvl(p_qtykpie,0),
                         qtyta        = p_qtyta,
                         qtypuns      = p_qtypuns,
                         flgsal       = p_flgsal,
                         flgbonus     = p_flgbonus,
                         pctdbon      = p_pctdbon,
                         pctdsal      = p_pctdsal,
                         remark3      = p_remark,
                         coduser      = global_v_coduser
                   where codempid = v_codempid
                     and dteyreap = b_index_dteyreap
                     and numtime  = b_index_numtime;          
      p_update   := p_update + 1; 
    end if;
    /*p_new         := 0;
    p_no_change   := 0;
    p_update      := 0;
    for i in 1..v_rec_text.count loop
        v_rec_tran  := v_rec_tran + 1;
        v_update    := 'N' ;
        v_codempid 	:= upper(trim(substr(v_rec_text(i)(1),1,10)));
        v_exist     := false; 
        for r_tappemp in c_tappemp loop
            v_exist   := true;           
            if r_tappemp.qtybeh3 	 = nvl(upper(v_rec_text(i)(4)),r_tappemp.qtybeh3)  and
               r_tappemp.qtycmp3 	 = nvl(upper(v_rec_text(i)(5)),r_tappemp.qtycmp3)  and              
               r_tappemp.qtykpic 	 = nvl(upper(v_rec_text(i)(6)),r_tappemp.qtykpic)  and
               r_tappemp.qtykpid 	 = nvl(upper(v_rec_text(i)(7)),r_tappemp.qtykpid)  and
               r_tappemp.qtykpie3 	 = nvl(upper(v_rec_text(i)(8)),r_tappemp.qtykpie3) then
               p_no_change    := p_no_change + 1; 
            else
                v_update := 'Y' ;
            end if;
        end loop;

        if not v_exist then
            begin
                select codcomp,codpos,numlvl,jobgrade 
                  into v_codcomp,v_codpos,v_numlvl,v_jobgrade
                  from temploy1
                 where codempid = v_codempid;
            exception when no_data_found then
                 null;
            end;

            insert into tappemp (codempid,dteyreap,numtime,
                                 codcomp,codpos,numlvl,
                                 codaplvl,jobgrade,flgappr,
                                 qtybeh3,qtycmp3,qtykpic,
                                 qtykpid,qtykpie3,qtytot3,
                                 qtyta,qtypuns,flgsal,
                                 flgbonus,pctdbon,pctdsal,
                                 remark3,codcreate,coduser)
                   values       (v_codempid,b_index_dteyreap,b_index_numtime,
                                 v_codcomp,v_codpos,v_numlvl,
                                 upper(v_rec_text(i)(3)),v_jobgrade,'C',
                                 v_rec_text(i)(4),v_rec_text(i)(5),v_rec_text(i)(6),
                                 v_rec_text(i)(7),v_rec_text(i)(8),(nvl(v_rec_text(i)(4),0) + nvl(v_rec_text(i)(5),0) + nvl(v_rec_text(i)(8),0)),
                                 0,0,'Y',
                                 'Y',0,0,
                                 v_rec_text(i)(9),global_v_coduser,global_v_coduser);
            p_new   := p_new + 1;
        elsif v_update = 'Y' then
            update tappemp set qtybeh3      = v_rec_text(i)(4),
                               qtycmp3      = v_rec_text(i)(5),
                               qtykpic      = v_rec_text(i)(6),
                               qtykpid      = v_rec_text(i)(7),  
                               qtykpie3     = v_rec_text(i)(8),
                               qtytot3      = nvl(v_rec_text(i)(4),0) + nvl(v_rec_text(i)(5),0) + nvl(v_rec_text(i)(8),0),
                               qtyta        = 0,
                               qtypuns      = 0,
                               flgsal       = 'Y',
                               flgbonus     = 'Y',
                               pctdbon      = 0,
                               pctdsal      = 0,
                               remark3      = v_rec_text(i)(9),
                               coduser      = global_v_coduser
            where codempid = v_codempid
              and dteyreap = b_index_dteyreap
              and numtime  = b_index_numtime;                   
            p_update   := p_update + 1; 
        end if;

    end loop;--1..v_rec_text.count*/
    -->>User37 #4460 14/09/2021 
  end;

  procedure generate_field_save(json_str_input in clob) is
    json_str          json_object_t;
    param_import      json_object_t;
    param_import_row  json_object_t;
    v_col_cnt         number;
  begin
    param_import    := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    v_col_cnt       := v_column.count;
    for i in 1..v_col_cnt loop
      v_head(i)   := get_label_name('HRAP3RBC2',global_v_lang, to_char((i*10)));
    end loop;

    for i in 0..param_import.get_size-1 loop
      param_import_row    := hcm_util.get_json_t(param_import,to_char(i));
      for k in 1..v_col_cnt loop
        v_rec_text(i+1)(k)           := hcm_util.get_string_t(param_import_row,v_column(k));
      end loop;
      v_rec_text(i+1)(v_col_cnt+1)   := hcm_util.get_string_t(param_import_row,'flgerror');
      v_rec_text(i+1)(v_col_cnt+2)   := hcm_util.get_string_t(param_import_row,'descerror');
      v_total                        := v_total + 1;
    end loop;
  end;

  procedure comfirm_data (json_str_input in clob, json_str_output out clob) is
    v_new           number;
    v_no_change     number;
    v_update        number;
    v_response      varchar2(4000 char);

    obj_row         json_object_t;
    --<<User37 #4460 14/09/2021 
    json_obj        json_object_t;
    obj_data        json_object_t;
    obj_data2       json_object_t;
    obj_data3       json_object_t;
    obj_data4       json_object_t;
    data_row        json_object_t;
    -->>User37 #4460 14/09/2021 
  begin
    initial_value(json_str_input);
    --<<User37 #4460 14/09/2021 
    json_obj        := json_object_t(json_str_input);
    obj_data        := hcm_util.get_json_t(json_obj,'param_json');
    obj_data2       := hcm_util.get_json_t(json_obj,'search');
    b_index_dteyreap  := to_number(hcm_util.get_string_t(obj_data2,'year'));
    b_index_numtime   := to_number(hcm_util.get_string_t(obj_data2,'no'));
    obj_data3        := hcm_util.get_json_t(obj_data,'table');
    obj_data4        := hcm_util.get_json_t(obj_data3,'rows');
    for i in 0..obj_data4.get_size-1 loop
      data_row    := hcm_util.get_json_t(obj_data4,to_char(i));
      p_stats  := hcm_util.get_string_t(data_row,'stats');
      if p_stats = 'Y' then
        p_codempid  := hcm_util.get_string_t(data_row,'codempid');
        p_qtybeh    := to_number(hcm_util.get_string_t(data_row,'qtybeh'));
        p_qtycmp    := to_number(hcm_util.get_string_t(data_row,'qtycmp'));
        p_qtykpic   := to_number(hcm_util.get_string_t(data_row,'qtykpic'));
        p_qtykpid   := to_number(hcm_util.get_string_t(data_row,'qtykpid'));
        p_qtykpie   := to_number(hcm_util.get_string_t(data_row,'qtykpie'));
        p_remark    := hcm_util.get_string_t(data_row,'remark');
        p_codaplvl  := upper(hcm_util.get_string_t(data_row,'codaplvl'));
        p_codcomp   := upper(hcm_util.get_string_t(data_row,'codcomp'));
        p_qtyta     := to_number(hcm_util.get_string_t(data_row,'wrktme'));
        p_qtypuns   := to_number(hcm_util.get_string_t(data_row,'brektme'));
        p_flgsal    := hcm_util.get_string_t(data_row,'flgsal');
        p_flgbonus  := hcm_util.get_string_t(data_row,'flgbonus');
        p_pctdbon   := to_number(hcm_util.get_string_t(data_row,'pctdsal'));
        p_pctdsal   := to_number(hcm_util.get_string_t(data_row,'pctdsal'));
        insupd_tappemp(v_new,v_no_change,v_update);
        commit;
      end if;
    end loop;
    obj_row         := json_object_t();
    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response      := get_response_message(null,param_msg_error,global_v_lang);
    obj_row.put('coderror','200');
    obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

    --obj_data2         := json_object_t();
    --obj_data2.put('rows','[]');
    --obj_row.put('table',obj_data2);
    /*generate_field_save(json_str_input);
    insupd_tappemp(v_new,v_no_change,v_update);
    commit;

    obj_row         := json_object_t();
    param_msg_error := get_error_msg_php('HR2715',global_v_lang);
    v_response      := get_response_message(null,param_msg_error,global_v_lang);
    obj_row.put('coderror','200');
    obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
    --obj_row.put('tranrecord',v_rec_tran);
    --obj_row.put('errrecord',v_rec_error);
    obj_row.put('new',v_new);
    obj_row.put('nochange',v_no_change);
    obj_row.put('update',v_update);*/
    -->>User37 #4460 14/09/2021 

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end comfirm_data;

  --<<User37 #4460 14/09/2021 
  procedure gen_workingtime_detail(p_qtypuns out number, p_qtyta out number, p_pctdbon out number,
                                   p_pctdsal out number, p_flgsal out varchar2, p_flgbonus out varchar2) is
    v_dtebhstr          tstdisd.dtebhstr%type;
    v_dtebhend          tstdisd.dtebhend%type;

    v_dteeffec          tattpreh.dteeffec%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;

    v_qtyleav           number;
    v_qtyscor           number;
    v_flgsal            tattpre2.flgsal%type;
    v_summary_flgsal    tattpre2.flgsal%type := 'Y';
    v_pctdedsal         tattpre2.pctdedsal%type;
    v_sum_pctdedsal     tattpre2.pctdedsal%type := 0;
    v_flgbonus          tattpre2.flgbonus%type;
    v_summary_flgbonus  tattpre2.flgbonus%type := 'Y';
    v_pctdedbon         tattpre2.pctdedbon%type;
    v_sum_pctdedbon     tattpre2.pctdedbon%type := 0;
    v_qtypunsh          number;
    v_scoreta           number;
    v_scorepunsh        number;

    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;

    v_tappemp_qtyta     tappemp.qtyta%type;
    v_tappemp_qtypuns   tappemp.qtypuns%type;
    v_tappemp_flgsal    tappemp.flgsal%type;
    v_tappemp_flgbonus  tappemp.flgbonus%type;
    v_tappemp_pctdbon   tappemp.pctdbon%type;
    v_tappemp_pctdsal   tappemp.pctdsal%type;
    v_codcompy          tattpre1.codcompy%type; 

    v_taplvl_codcomp        taplvl.codcomp%type;
    v_taplvl_dteeffec       taplvl.dteeffec%type;

    cursor c_tappempta is
        select *
          from tappempta
         where codempid = p_codempid
           and dteyreap = b_index_dteyreap
           and numtime = b_index_numtime;

    cursor c_tappempmt is
        select *
          from tappempmt
         where codempid = p_codempid
           and dteyreap = b_index_dteyreap
           and numtime = b_index_numtime;

    cursor c_tattpre1 is
        select 1 type,codgrplv
          from tattpre1
         where codcompy = v_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'N'
         union
        select 2 type,codgrplv
          from tattpre1
         where codcompy = v_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'N'
           and flglate = 'Y'
         union
        select 3 type,codgrplv
          from tattpre1
         where codcompy = v_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
           and flgabsc = 'Y'
           and flglate = 'N'
      order by type;

    cursor c_tattpre3 is
        select codpunsh
          from tattpre3
         where codcompy = v_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec
      order by codpunsh;

  begin
    v_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
    begin
      select dtebhstr, dtebhend
        into v_dtebhstr, v_dtebhend
        from tstdisd
       where dteyreap = b_index_dteyreap
         and numtime = b_index_numtime
         and codcomp = v_codcompy
         and codaplvl = p_codaplvl;
    exception when no_data_found then
      null;
    end; 

    begin
      select qtyta, qtypuns, flgsal, flgbonus, pctdbon, pctdsal
        into v_tappemp_qtyta, v_tappemp_qtypuns, v_tappemp_flgsal, v_tappemp_flgbonus, v_tappemp_pctdbon, v_tappemp_pctdsal
        from tappemp
       where codempid = p_codempid
         and dteyreap = b_index_dteyreap
         and numtime = b_index_numtime;
    exception when no_data_found then
      null;
    end;

    begin
      select dteeffec, scorfta, scorfpunsh
        into v_dteeffec, v_scorfta, v_scorfpunsh
        from tattpreh
       where codcompy = v_codcompy
         and codaplvl = p_codaplvl
         and dteeffec = (select max(dteeffec)
                           from tattpreh
                          where codcompy = v_codcompy
                            and codaplvl = p_codaplvl
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      null;
    end;

    hrap31e.get_taplvl_where(p_codcomp,p_codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

    begin
      select pctta, pctpunsh
        into v_pctta, v_pctpunsh
        from taplvl
       where codcomp = v_taplvl_codcomp
         and codaplvl = p_codaplvl
         and dteeffec = v_taplvl_dteeffec;
    exception when no_data_found then
      v_pctta     := 0;
      v_pctpunsh  := 0;
    end;
    ----------------------------------------------------------------
    if v_tappemp_qtyta is not null or v_tappemp_qtypuns is not null then
      v_summary_flgsal      := v_tappemp_flgsal;
      v_summary_flgbonus    := v_tappemp_flgbonus;
      v_sum_pctdedsal       := v_tappemp_pctdsal;
      v_sum_pctdedbon       := v_tappemp_pctdbon;

      v_scoreta             := v_scorfta;
      for r_tappempta in c_tappempta loop
        v_scoreta       := v_scoreta - nvl(r_tappempta.qtyscor,0);
      end loop;
      v_scorepunsh      := v_scorfpunsh;
      for r_tappempmt in c_tappempmt loop
        v_scorepunsh            := v_scorepunsh - nvl(r_tappempmt.qtyscor,0);
      end loop;
    else
      v_scoreta := v_scorfta;
      for r_tattpre1 in c_tattpre1 loop
        if r_tattpre1.type = 1 then
          select nvl(sum(qtyday),0)
            into v_qtyleav
            from tleavetr a, tattprelv b
           where a.codempid = p_codempid
             and a.dtework between v_dtebhstr and v_dtebhend
             and a.codleave = b.codleave
             and b.codaplvl = p_codaplvl
             and b.dteeffec = v_dteeffec
             and b.codgrplv = r_tattpre1.codgrplv;
        elsif r_tattpre1.type = 2 then
          select sum(nvl(qtytlate,0) + nvl(qtytearly,0))
            into v_qtyleav
            from tlateabs
           where codempid = p_codempid
             and dtework between v_dtebhstr and v_dtebhend;
        elsif r_tattpre1.type = 3 then
          select sum(nvl(qtytabs,0))
            into v_qtyleav
            from tlateabs
           where codempid = p_codempid
             and dtework between v_dtebhstr and v_dtebhend;
        end if;

        begin
          select scorded, flgsal, pctdedsal, flgbonus, pctdedbon
            into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
            from tattpre2
           where codcompy = v_codcompy
             and codaplvl = p_codaplvl
             and dteeffec = v_dteeffec
             and codgrplv = r_tattpre1.codgrplv
             and v_qtyleav between qtymin and qtymax
          order by qtymin;
        exception when no_data_found then
          v_qtyscor := 0;
          v_flgsal    := 'Y';
          v_pctdedsal := 0;
          v_flgbonus  := 'Y';
          v_pctdedbon := 0;
        end;

        v_scoreta           := v_scoreta - nvl(v_qtyscor,0);
        v_sum_pctdedsal     := v_sum_pctdedsal + v_pctdedsal;
        v_sum_pctdedbon     := v_sum_pctdedbon + v_pctdedbon;
        if v_flgsal = 'N' then
          v_summary_flgsal := 'N';
        end if;
        if v_flgbonus = 'N' then
          v_summary_flgbonus := 'N';
        end if;
      end loop;
      v_scorepunsh      := v_scorfpunsh;
      for r_tattpre3 in c_tattpre3 loop
        select count(*)
          into v_qtypunsh
          from thispun
         where codempid = p_codempid
           and codpunsh = r_tattpre3.codpunsh
           and dteeffec between v_dtebhstr and v_dtebhend;

        begin
          select scoreded, flgsal, pctdedsal, flgbonus, pctdedbonus
            into v_qtyscor, v_flgsal, v_pctdedsal, v_flgbonus, v_pctdedbon
            from tattpre4
           where codcompy = v_codcompy
             and codaplvl = p_codaplvl
             and dteeffec = v_dteeffec
             and codpunsh = r_tattpre3.codpunsh
             and v_qtypunsh between qtymin and qtymax
          order by qtymin;
        exception when no_data_found then
          v_qtyscor       := 0;
          v_flgsal        := 'Y';
          v_pctdedsal     := 0;
          v_flgbonus      := 'Y';
          v_pctdedbon     := 0;
        end;

        v_scorepunsh            := v_scorepunsh - nvl(v_qtyscor,0);
        v_sum_pctdedsal         := v_sum_pctdedsal + v_pctdedsal;
        v_sum_pctdedbon         := v_sum_pctdedbon + v_pctdedbon;
        if v_flgsal = 'N' then
          v_summary_flgsal := 'N';
        end if;
        if v_flgbonus = 'N' then
          v_summary_flgbonus := 'N';
        end if;
      end loop;

      if v_summary_flgsal = 'N' then
        v_sum_pctdedsal := 0;
      end if;
      if v_summary_flgbonus = 'N' then
        v_sum_pctdedbon := 0;
      end if;
    end if;

    v_scoreta             := greatest(v_scoreta,0);
    v_scorepunsh          := greatest(v_scorepunsh,0);

    if nvl(v_scorfta,0) <> 0 then
      p_qtyta     := round((v_scoreta/v_scorfta*100),2);
    else
      p_qtyta     := null;
    end if;
    if nvl(v_scorfpunsh,0) <> 0 then
      p_qtypuns   := round((v_scorepunsh/v_scorfpunsh*100),2);
    else
      p_qtypuns     := null;
    end if;
    p_pctdbon   := v_sum_pctdedbon;
    p_pctdsal   := v_sum_pctdedsal;
    p_flgsal    := v_flgsal;
    p_flgbonus  := v_flgbonus;
  end;
  -->>User37 #4460 14/09/2021 

END HRAP3RB;

/

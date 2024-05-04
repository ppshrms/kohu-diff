--------------------------------------------------------
--  DDL for Package Body HRPY5XX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5XX" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');


    p_coddeduct         := hcm_util.get_json_t(json_obj, 'p_coddeduct');


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_temp				      number;
    v_typpayroll        varchar2(100 char);
  begin
    if p_typpayroll is not null then
      begin
        select codcodec into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
    --
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;

--  procedure check_save is
--    v_empid     varchar2(100 char);
--    v_comp      varchar2(100 char);
--    v_empid1    varchar2(100 char);
--    v_pos       varchar2(100 char);
--  begin
--
--    begin
--      select codempid,codpos,codcomp
--        into v_empid,v_pos,v_comp
--        from temploy1
--       where codempid = v_codempid
--         and codcomp  like p_codcomp||'%';
--    exception when no_data_found then
--      v_empid := null;
--      v_pos   := null;
--    end;
--    -- chk null
--    if v_empid is null then
--      param_msg_error := get_error_msg_php('HR7523', global_v_lang, 'TEMPLOY1');
--    end if;
--    --chk dup
--    begin
--      select codempid
--        into v_empid1
--        from tlstrevn
--       where dteyear  = p_dteyear
--         and codempid = v_codempid;
--    exception when no_data_found then
--      v_empid1 := null;
--    end;
--    if v_empid1 is not null then
--      param_msg_error := get_error_msg_php('HR2005', global_v_lang, 'codempid');
--    end if;
--
--    if v_codempid is null then
--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,v_codempid);
--      if param_msg_error is not null then.
--        return;
--      end if;
--    end if;
--  end check_save;

  procedure save_index(json_str_input in clob, json_str_output out clob) is
    v_maxrcnt           number := 0;
    v_rcnt              number := 0;
    v_coddeduct         varchar2(100 char);

  begin
    initial_value(json_str_input);
    v_maxrcnt := p_coddeduct.get_size;
    for i in 0..v_maxrcnt - 1 loop
      v_rcnt      := i + 1;
      v_coddeduct := hcm_util.get_string_t(p_coddeduct, to_char(i));

      begin
        insert into trepdisp (coduser, codapp, numseq, coddisp, codcreate)
                      values (global_v_coduser, v_codapp, v_rcnt,v_coddeduct,global_v_coduser);
      exception when dup_val_on_index then
        update trepdisp
          set coddisp   = v_coddeduct,
              codcreate = global_v_coduser
        where coduser = global_v_coduser
          and codapp  = v_codapp
          and numseq  = v_rcnt;
      end;
    end loop;
    delete from trepdisp
          where coduser = global_v_coduser
            and codapp  = v_codapp
            and numseq  > v_rcnt;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end save_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    obj_deduct        json_object_t;
    v_row             number := 0;
    v_secur           boolean := false;
    v_flgsecu         boolean := false;
    --v_pos             varchar2(100 char);
    v_rcnt            number := 0;
    v_amtsocyr        number;
    v_amtproyr        number;
    v_amtdeduct       number;
    v_amtspded        number;
    v_amt             number;
    v_type            varchar2(1 char);
    v_count           number;
    v_flgdata         varchar2(1 char) := 'N';

    cursor c1 is
      select codempid,codcomp,numlvl
        from temploy1
       where codcomp like p_codcomp||'%'
         and typpayroll = p_typpayroll
         and staemp in ('1','3','9')
      order by codempid;

    cursor c2 is
      select coddisp
        from trepdisp
       where coduser = global_v_coduser
         and codapp  = v_codapp
      order by numseq;

--    cursor c3 is
--      select coddeduct,decode(v_type,'E',nvl(stddec(amtdeduct,codempid,:global.chken),0),
--                                         nvl(stddec(amtspded,codempid,:global.chken),0) ) amtdeduct
--        from tempded
--       where codempid  = v_emp
--         and coddeduct = v_code;

  begin
    begin
      select count(*)
        into v_count
        from trepdisp
       where coduser = global_v_coduser
         and codapp  = v_codapp;
    exception when others then null;
      v_count := 0;
    end;

    for r1 in c1 loop
      v_flgdata            := 'Y';
      exit;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tempded');
      json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      return;
    end if;



    for r1 in c1 loop
      v_flgsecu := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

      if v_flgsecu then

        v_secur := true;
        for j in 1..2 loop
						v_amtsocyr := 0;
						v_amtproyr := 0;

						begin
				   	  select nvl(stddec(amtsocyr,codempid,v_chken),0),
				   					 nvl(stddec(amtproyr,codempid,v_chken),0)
				   		  into v_amtsocyr,v_amtproyr
					   		from ttaxmas
					   	 where codempid = r1.codempid
					   		 and dteyrepay = to_number(to_char(sysdate,'YYYY'));
				   	exception when others then null;
              v_amtsocyr := 0;
				   		v_amtproyr := 0;
				   	end;

            v_row := v_row + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            if j = 1 then
              obj_data.put('image', get_emp_img(r1.codempid));
              obj_data.put('codempid', r1.codempid);
              obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
              v_type := 'E';
            --obj_data.put('codcomp', r1.codcomp);
            else
              obj_data.put('image', '');
              obj_data.put('codempid', '');
              obj_data.put('desc_codempid',get_label_name('HRPY5XX',global_v_lang,'90'));
              v_type := 'S';
            end if;
            obj_deduct := json_object_t();
            for r2 in c2 loop
              if r2.coddisp is not null then
                if r2.coddisp = 'E001' and v_type = 'E' then
								  v_amt := greatest(v_amtproyr - 10000,0);
							  elsif r2.coddisp = 'D001' and v_type = 'E' then
								  v_amt := least(v_amtproyr,10000);
							  elsif r2.coddisp = 'D002' and v_type = 'E' then
								  v_amt := v_amtsocyr;
								else
                  begin
                    select nvl(stddec(amtdeduct,codempid,v_chken),0),
                           nvl(stddec(amtspded,codempid,v_chken),0)
                      into v_amtdeduct,v_amtspded
                      from tempded
                     where codempid  = r1.codempid
                       and coddeduct = r2.coddisp;
                  exception when others then null;
                    v_amtdeduct := 0;
                    v_amtspded := 0;
                  end;
                    if v_type = 'E' then
                      v_amt := v_amtdeduct;
                    else
                      v_amt := v_amtspded;
                    end if;
--								  v_code := name_in(':tcdedprt.codded'||h) ;
--								  for j in c2 loop
--									  v_amt := j.amtdeduct;
--								  end loop;
			   				end if;

                v_rcnt  := v_rcnt + 1;
                obj_data.put('coddeduct'||to_char(v_rcnt), v_amt);
                --obj_deduct.put(get_tcodeduct_name(to_char(r2.coddisp),global_v_lang) , v_amt);
              end if;
            end loop;
            obj_data.put('coddisp_count', v_count);

--            obj_data.put('codinc', obj_codinc);
--            obj_data.put('codded', obj_codded);

--      param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,r1.codempid);
--      if param_msg_error is null then
--        begin
--          select codpos
--            into v_pos
--            from temploy1
--           where codempid = r1.codempid;
--        exception when no_data_found then
--          v_pos   := null;
--        end;

--        v_row := v_row + 1;
--        obj_data := json();
--        obj_data.put('coderror', '200');
        --obj_data.put('codempid', r1.codempid);
        --obj_data.put('desc_codpos', get_tpostn_name(v_pos,global_v_lang));
        --obj_data.put('codcomp', r1.codcomp);

          obj_row.put(to_char(v_row - 1), obj_data);
          v_rcnt := 0;
        end loop;
      end if;
    end loop;

    if v_flgdata = 'Y' and not v_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_detail;

  procedure get_index(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t := json_object_t();
    obj_data        json_object_t;
    obj_coddeduct   json_object_t;
    v_rcnt          number := 0;
    v_codapp        varchar2(100 char) := 'HRPY5XX';

    cursor c1 is
      select coddisp
        from trepdisp
       where coduser = global_v_coduser
         and codapp  = v_codapp
    order by numseq;

--    cursor c2 is
--      select coddeduct
--        from tcodeductc a
--       where codcompy = p_codcomp;
--         and not exists (select coddisp
--                           from trepdisp b
--                          where a.coddeduct = b.coddisp
--                            and coduser = global_v_coduser
--                            and codapp  = v_codapp)
--      order by coddeduct;

  begin
    initial_value(json_str_input);
    obj_coddeduct := json_object_t();
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      for r1 in c1 loop
        v_rcnt := v_rcnt + 1;
        obj_coddeduct.put(to_char(v_rcnt - 1), to_char(r1.coddisp));
      end loop;
      obj_data.put('deduct', obj_coddeduct);

      --obj_data.put('choosededuct', r1.coddisp);
      --obj_data.put('desc_coddeduct', get_tcodeduct_name(r1.coddeduct,global_v_lang));
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure get_deduct(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t := json_object_t();
    obj_data        json_object_t;
    obj_coddeduct   json_object_t;
    v_row           number := 0;

    cursor c1 is
      select coddeduct,get_tcodeduct_name(coddeduct,global_v_lang) desc_coddeduct
        from tcodeductc a
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
--         and not exists (select coddisp
--                           from trepdisp b
--                          where a.coddeduct = b.coddisp
--                            and coduser = global_v_coduser
--                            and codapp  = v_codapp)
      order by coddeduct;

  begin
    initial_value(json_str_input);
    check_index;
    obj_coddeduct := json_object_t();

    for r1 in c1 loop
      v_row := v_row + 1;
      obj_coddeduct.put(r1.coddeduct, r1.desc_coddeduct);
    end loop;

    if v_row = 0 then
       param_msg_error := get_error_msg_php('HR2055', global_v_lang,'trepdisp');
       json_str_output := get_response_message('400', param_msg_error, global_v_lang);
        return;
    end if;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('deduct', obj_coddeduct);




    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end get_deduct;

  procedure get_textfile(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_textfile(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_textfile;

  procedure gen_textfile(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_data          json_object_t;
    v_secur           varchar2(1 char) := 'N';
    v_flgsecu         boolean := false;
    v_data            varchar2(1 char) := 'N';
    v_amtsocyr        number;
    v_amtproyr        number;
    v_amtdeduct       number;
    v_amtspded        number;
    v_amt             number;
    v_type            varchar2(1 char);
    v_count           number;
    v_response        varchar2(4000 char);
    out_file   			  UTL_FILE.File_Type;
    data_file 			  varchar2(4000 char);
    v_filename    	  varchar2(255 char);
    v_header			    varchar2(4000 char)	:= ' ';
    v_codempid			  varchar2(4000 char)	:= ' ';
    v_fullname			  varchar2(4000 char)	:= ' ';
    v_netamt          varchar2(4000 char)	:= ' ';

    cursor c1 is
      select codempid,codcomp,numlvl
        from temploy1
       where codcomp like p_codcomp||'%'
         and typpayroll = p_typpayroll
         and staemp in ('1','3','9')
      order by codempid;

    cursor c2 is
      select coddisp
        from trepdisp
       where coduser = global_v_coduser
         and codapp  = v_codapp
      order by coddisp;
  begin
    v_filename  := lower('HRPY5XX'||'_'||global_v_coduser)||'.log';
    --
    std_deltemp.upd_ttempfile(lower('HRPY5XX'||'_'||global_v_coduser)||'.log','A');
    --
    out_file 	:= UTL_FILE.Fopen(p_file_dir,v_filename,'w');
    begin
      select count(*)
        into v_count
        from trepdisp
       where coduser = global_v_coduser
         and codapp  = v_codapp;
    exception when others then null;
      v_count := 0;
    end;
    for r2 in c2 loop
      v_header := v_header||',"'||get_tcodeduct_name(to_char(r2.coddisp),global_v_lang)||'"';
    end loop;
    -- Write Header to text file
    data_file := get_label_name('HRPY5XX',global_v_lang,'60')||','||
                 get_label_name('HRPY5XX',global_v_lang,'70')||v_header;
    --UTL_FILE.Put_line(out_file,data_file);
    data_file := convert(data_file,'TH8TISASCII');
    if data_file is not null then
      UTL_FILE.Put_line(out_file,data_file);
    end if;

    for r1 in c1 loop
      v_flgsecu := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_flgsecu then
        v_secur := 'Y';
        for j in 1..2 loop
						v_amtsocyr := 0;
						v_amtproyr := 0;

						begin
				   	  select nvl(stddec(amtsocyr,codempid,v_chken),0),
				   					 nvl(stddec(amtproyr,codempid,v_chken),0)
				   		  into v_amtsocyr,v_amtproyr
					   		from ttaxmas
					   	 where codempid = r1.codempid
					   		 and dteyrepay = to_number(to_char(sysdate,'YYYY'));
				   	exception when others then null;
              v_amtsocyr := 0;
				   		v_amtproyr := 0;
				   	end;

            if j = 1 then
              v_codempid := '"'||r1.codempid||'"';
              v_fullname := ',"'||get_temploy_name(r1.codempid, global_v_lang)||'"';
              v_type := 'E';
            else
              v_codempid := '"'||r1.codempid||'"';
              v_fullname := ',"'||get_label_name('HRPY5XX',global_v_lang,'90')||'"';
              v_type := 'S';
            end if;

            for r2 in c2 loop
              v_data := 'Y';
              if r2.coddisp is not null then
                if r2.coddisp = 'E001' and v_type = 'E' then
								  v_amt := greatest(v_amtproyr - 10000,0);
							  elsif r2.coddisp = 'D001' and v_type = 'E' then
								  v_amt := least(v_amtproyr,10000);
							  elsif r2.coddisp = 'D002' and v_type = 'E' then
								  v_amt := v_amtsocyr;
								else
                  begin
                    select nvl(stddec(amtdeduct,codempid,v_chken),0),
                           nvl(stddec(amtspded,codempid,v_chken),0)
                      into v_amtdeduct,v_amtspded
                      from tempded
                     where codempid  = r1.codempid
                       and coddeduct = r2.coddisp;
                  exception when others then null;
                    v_amtdeduct := 0;
                    v_amtspded := 0;
                  end;
                    if v_type = 'E' then
                      v_amt := v_amtdeduct;
                    else
                      v_amt := v_amtspded;
                    end if;
			   				end if;
                v_netamt := v_netamt||',"'||nvl(v_amt,0)||'"';
              end if;
            end loop;
          -- Write Detail to text file
          data_file := '"'||v_codempid||'","'||v_fullname||'"'||v_netamt;
          --UTL_FILE.Put_line(out_file,data_file);
          data_file := convert(data_file,'TH8TISASCII');
          if data_file is not null then
            UTL_FILE.Put_line(out_file,data_file);
          end if;

          v_netamt := '';
        end loop;
      end if;
    end loop;

    UTL_FILE.FClose(out_file);

    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'trepdisp');
   	elsif v_secur = 'N'   then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
		end if;

    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
--      obj_data.put('numrec', nvl(v_cntrec,0));
      obj_data.put('path',p_file_path || v_filename);

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));


      json_str_output := obj_data.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_textfile;

end HRPY5XX;

/

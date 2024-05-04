--------------------------------------------------------
--  DDL for Package Body HRCO0AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO0AE" AS
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin

    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    param_msg_error     := '';
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codjobgrp         := hcm_util.get_string_t(json_obj,'jobgroup');
    p_namjobgrp         := hcm_util.get_string_t(json_obj,'namjobgrp');
    p_namjobgrpe        := hcm_util.get_string_t(json_obj,'namjobgrpe');
    p_namjobgrpt        := hcm_util.get_string_t(json_obj,'namjobgrpt');
    p_namjobgrp3        := hcm_util.get_string_t(json_obj,'namjobgrp3');
    p_namjobgrp4        := hcm_util.get_string_t(json_obj,'namjobgrp4');
    p_namjobgrp5        := hcm_util.get_string_t(json_obj,'namjobgrp5');

    p_codtency          := hcm_util.get_string_t(json_obj,'codtency');
    p_namtncy           := hcm_util.get_string_t(json_obj,'namtncy');
    p_namtncye          := hcm_util.get_string_t(json_obj,'namtncye');
    p_namtncyt          := hcm_util.get_string_t(json_obj,'namtncyt');
    p_namtncy3          := hcm_util.get_string_t(json_obj,'namtncy3');
    p_namtncy4          := hcm_util.get_string_t(json_obj,'namtncy4');
    p_namtncy5          := hcm_util.get_string_t(json_obj,'namtncy5');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure check_index1 is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codjobgrp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codjobgrp');
      return;
    end if;
  end;
  --
  procedure check_index2 is
    error_secur VARCHAR2(4000 CHAR);
    v_chk_exist        TCODJOBGRP.jobgroup%TYPE;
  begin
    if p_codtency is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codtency');
      return;
    end if;
    begin
      select CODTENCY
      into v_chk_exist
      from tcomptnc
      where CODTENCY = p_codtency;

    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcomptnc');
      return;
    end;
  end;
  --
  procedure check_save2 is
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codjobgrp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codjobgrp');
      return;
    end if;
    if p_codtency is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_codtency');
      return;
    end if;
  end;
  --
  procedure gen_tcodjobgrp (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
    cursor    c1 is
        select   JOBGROUP,NAMJOBGRPE,NAMJOBGRPT,NAMJOBGRP3,NAMJOBGRP4,NAMJOBGRP5,
                 decode(global_v_lang,'101',NAMJOBGRPE
                                     ,'102',NAMJOBGRPT
                                     ,'103',NAMJOBGRP3
                                     ,'104',NAMJOBGRP4
                                     ,'105',NAMJOBGRP5) as NAMJOBGRP
        from     tcodjobgrp
        order by jobgroup;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('jobgroup', i.JOBGROUP);
      obj_data.put('namjobgrp', i.NAMJOBGRP);
      obj_data.put('namjobgrpe', i.NAMJOBGRPE);
      obj_data.put('namjobgrpt', i.NAMJOBGRPT);
      obj_data.put('namjobgrp3', i.NAMJOBGRP3);
      obj_data.put('namjobgrp4', i.NAMJOBGRP4);
      obj_data.put('namjobgrp5', i.NAMJOBGRP5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcodjobgrp (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tcodjobgrp(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_codjobgrp (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt      number  := 0;
    cursor c1 is
        SELECT distinct TCOMPTNC.CODTENCY,
                        TCOMPTNC.NAMTNCYE,
                        TCOMPTNC.NAMTNCYT,
                        TCOMPTNC.NAMTNCY3,
                        TCOMPTNC.NAMTNCY4,
                        TCOMPTNC.NAMTNCY5,
                        decode(global_v_lang,'101',TCOMPTNC.NAMTNCYE
                                            ,'102',TCOMPTNC.NAMTNCYT
                                            ,'103',TCOMPTNC.NAMTNCY3
                                            ,'104',TCOMPTNC.NAMTNCY4
                                            ,'105',TCOMPTNC.NAMTNCY5) as NAMTNCY
        FROM TCOMPTNC
        INNER JOIN tjobgroup
        ON tcomptnc.codtency = tjobgroup.codtency
        where tjobgroup.jobgroup = p_codjobgrp;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codtency', i.CODTENCY);
      obj_data.put('namtncy', i.NAMTNCY);
      obj_data.put('namtncye', i.NAMTNCYE);
      obj_data.put('namtncyt', i.NAMTNCYT);
      obj_data.put('namtncy3', i.NAMTNCY3);
      obj_data.put('namtncy4', i.NAMTNCY4);
      obj_data.put('namtncy5', i.NAMTNCY5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_codjobgrp (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_codjobgrp(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcodjobgrp_detail (json_str_output out clob) is
    obj_row            json_object_t;
     cursor    c1 is
        select   JOBGROUP,NAMJOBGRPE,NAMJOBGRPT,NAMJOBGRP3,NAMJOBGRP4,NAMJOBGRP5,
                 decode(global_v_lang,'101',NAMJOBGRPE
                                     ,'102',NAMJOBGRPT
                                     ,'103',NAMJOBGRP3
                                     ,'104',NAMJOBGRP4
                                     ,'105',NAMJOBGRP5) as NAMJOBGRP
        from  tcodjobgrp
        where JOBGROUP = p_codjobgrp
        order by jobgroup;
  begin
    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('jobgroup', p_codjobgrp);
    for i in c1 loop
      obj_row.put('namjobgrp', i.NAMJOBGRP);
      obj_row.put('namjobgrpe', i.NAMJOBGRPE);
      obj_row.put('namjobgrpt', i.NAMJOBGRPT);
      obj_row.put('namjobgrp3', i.NAMJOBGRP3);
      obj_row.put('namjobgrp4', i.NAMJOBGRP4);
      obj_row.put('namjobgrp5', i.NAMJOBGRP5);
    end loop;
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcodjobgrp_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_tcodjobgrp_detail(json_str_output);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcomptnc_detail (json_str_output out clob) is
    obj_row            json_object_t;
    v_chk_exist        TCODJOBGRP.jobgroup%TYPE;
     cursor c1 is
        select CODTENCY,NAMTNCYE,NAMTNCYT,NAMTNCY3,NAMTNCY4,NAMTNCY5,
               decode(global_v_lang,'101',NAMTNCYE
                                   ,'102',NAMTNCYT
                                   ,'103',NAMTNCY3
                                   ,'104',NAMTNCY4
                                   ,'105',NAMTNCY5) as NAMTNCY
        from tcomptnc
        where CODTENCY = p_codtency
        order by CODTENCY;
  begin
    obj_row   := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codtency', p_codtency);
    for i in c1 loop
      obj_row.put('namtncy', i.NAMTNCY);
      obj_row.put('namtncye', i.NAMTNCYE);
      obj_row.put('namtncyt', i.NAMTNCYT);
      obj_row.put('namtncy3', i.NAMTNCY3);
      obj_row.put('namtncy4', i.NAMTNCY4);
      obj_row.put('namtncy5', i.NAMTNCY5);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcomptnc_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index2;

    if param_msg_error is null then
      gen_tcomptnc_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_tcompskil (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number  := 0;
    v_chk_exist        number  := 0;
     cursor c1 is
        select CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,
               decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        from tcodskil
        where CODCODEC IN (select codskill from tjobgroup where jobgroup = p_codjobgrp and  codtency = p_codtency)
--          and CODCODEC IN (select codskill from TCOMPSKIL where codtency = p_codtency)
        order by CODCODEC;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
      for i in c1 loop
        obj_data    := json_object_t();
        v_rcnt      := v_rcnt + 1;
        obj_data.put('coderror', '200');
        obj_data.put('codcodec', i.CODCODEC);
        obj_data.put('descod', i.DESCOD);
        obj_data.put('descode', i.DESCODE);
        obj_data.put('descodt', i.DESCODT);
        obj_data.put('descod3', i.DESCOD3);
        obj_data.put('descod4', i.DESCOD4);
        obj_data.put('descod5', i.DESCOD5);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure default_codskill (json_str_output out clob) is
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number  := 0;
    v_chk_exist        number  := 0;
     cursor c1 is
        select CODCODEC,DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5,
               decode(global_v_lang,'101',DESCODE
                                   ,'102',DESCODT
                                   ,'103',DESCOD3
                                   ,'104',DESCOD4
                                   ,'105',DESCOD5) as DESCOD
        from tcodskil
        where CODCODEC IN (select codskill from TCOMPSKIL where codtency = p_codtency)
        order by CODCODEC;
  begin
    obj_row   := json_object_t();
    v_rcnt    := 0;
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codcodec', i.CODCODEC);
      obj_data.put('descod', i.DESCOD);
      obj_data.put('descode', i.DESCODE);
      obj_data.put('descodt', i.DESCODT);
      obj_data.put('descod3', i.DESCOD3);
      obj_data.put('descod4', i.DESCOD4);
      obj_data.put('descod5', i.DESCOD5);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tcompskil (json_str_input in clob,json_str_output out clob) is
    v_chk_exist   varchar(10 char);
  begin
    initial_value(json_str_input);
    begin
      select distinct codtency
      into v_chk_exist
      from tjobgroup
      where jobgroup = p_codjobgrp
      and codtency = p_codtency;
    exception when no_data_found then
      v_chk_exist := null;
    end;
    if v_chk_exist is not null then
      gen_tcompskil(json_str_output);
    else
      default_codskill(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json          json_object_t;
    param_data          json_object_t;
    param_column        json_object_t;
    param_column_row    json_object_t;
    param_json_row      json_object_t;
    json_obj_list       json_list;
    --
    data_file           varchar2(6000);
    v_column            number := 7;
    v_error             boolean;
    v_err_code          varchar2(1000);
    v_err_filed         varchar2(1000);
    v_err_table         varchar2(20);
    i                   number;
    j                   number;
    k                   number;
    v_numseq            number := 0;

    v_code              varchar2(100);
    v_flgsecu           boolean;
    v_cnt               number := 0;
    v_dteleave          date;
    v_coderr            varchar2(4000 char);
    v_num               number := 0;

    type text is table of varchar2(4000) index by binary_integer;
    v_text              text;
    v_filed             text;

    v_chk_compskil      TCOMPSKIL.CODTENCY%TYPE;
    v_chk_exist         number :=0;
    v_chk_codtency      varchar2(100);
    v_chk_dup_codskil   varchar2(100);
    v_chk_codskil       varchar2(100);
    v_chk_codjobgrp     varchar2(100);
    v_chk_jobgrp        varchar2(100);

    v_jobgroup          varchar2(4);
    v_namjobgrpe        varchar2(150);
    v_namjobgrpt        varchar2(150);
    v_namjobgrp3        varchar2(150);
    v_namjobgrp4        varchar2(150);
    v_namjobgrp5        varchar2(150);
    v_codtency          varchar2(4);
    v_codskill          varchar2(4);


  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
        -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    for r1 in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;

        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,'jobgroup');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'namjobgrpe');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'namjobgrpt');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'namjobgrp3');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'namjobgrp4');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'namjobgrp5');
          v_text(7)   := hcm_util.get_string_t(param_json_row,'codtency');
          v_text(8)   := hcm_util.get_string_t(param_json_row,'codskill');

          data_file := null;
          for i in 1..8 loop
              data_file := v_text(1)||', '||v_text(2)||', '||v_text(3)||', '||v_text(4)||', '||v_text(5)||', '||v_text(6)||', '||v_text(7)||', '||v_text(8);
              if v_text(i) is null and (i = 1 or i = 7 or i = 8) then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                if i = 1 then
                  v_err_table := 'TCODJOBGRP';
                elsif i = 7 then
                  v_err_table := 'TCOMPTNC';
                else
                  v_err_table := 'TCODSKIL';
                end if;
                exit cal_loop;
              end if;
          end loop;
         -- 1.jobgrp
           i := 1;
           if length(v_text(i)) > 4 then
             v_error     := true;
             v_err_code  := 'HR6591';
             v_err_filed := v_filed(i);
              exit cal_loop;
           end if;
           v_jobgroup := upper(v_text(i));

        -- 2.namjobgrpe
           i := 2;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namjobgrpe := upper(v_text(i));

        -- 3.namjobgrpt
           i := 3;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namjobgrpt := upper(v_text(i));

        -- 4.namjobgrp3
           i := 4;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namjobgrp3 := upper(v_text(i));

        -- 5.namjobgrp4
           i := 5;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namjobgrp4 := upper(v_text(i));

        -- 6.namjobgrp5
           i := 6;
           if v_text(i) is not null then
             if length(v_text(i)) > 150 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           v_namjobgrp5 := upper(v_text(i));

        -- 7.codtency
           i := 7;
           if v_text(i) is not null then
             if length(v_text(i)) > 4 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;

           begin
             select CODTENCY
             into v_chk_codtency
             from tcomptnc
             where CODTENCY = upper(v_text(i));
           exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TCOMPSKIL';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
           end;
           v_codtency := upper(v_text(i));

        -- 8.codskil
           i := 8;
           if v_text(i) is not null then
             if length(v_text(i)) > 4 then
               v_error     := true;
               v_err_code  := 'HR6591';
               v_err_filed := v_filed(i);
                exit cal_loop;
             end if;
           end if;
           begin
             select CODCODEC
             into v_chk_codskil
             from tcodskil
             where CODCODEC = upper(v_text(i));
           exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TCODSKIL';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
            end;

            begin
                select  codtency
                into    v_chk_dup_codskil
                from    tjobgroup
                where   jobgroup = upper(v_text(1))
                and     codtency <> upper(v_text(7))
                and     codskill = upper(v_text(8))
                and     rownum = 1;
            exception when no_data_found then
              v_chk_dup_codskil := null;
            end;
            if v_chk_dup_codskil is not null then
                v_error     := true;
                v_err_code  := 'CO0010';
                v_err_table := 'TJOBGROUP';
                v_err_filed := upper(v_text(8));
                exit cal_loop;
            end if;
            v_codskill := upper(v_text(8));
          exit cal_loop;
        end loop;

        if not v_error then
            v_rec_tran := v_rec_tran + 1;

          begin
              select JOBGROUP
              into v_chk_jobgrp
              from tcodjobgrp
              where JOBGROUP = upper(v_codtency);

          exception when no_data_found then
              v_chk_jobgrp := null;
          end;

          begin
            if v_chk_jobgrp is null then
              insert into tcodjobgrp (JOBGROUP,NAMJOBGRPE,NAMJOBGRPT,NAMJOBGRP3,NAMJOBGRP4,NAMJOBGRP5)
              values (v_jobgroup, v_namjobgrpe, v_namjobgrpt, v_namjobgrp3, v_namjobgrp4, v_namjobgrp5);
            else
              update tcodjobgrp
              set JOBGROUP = v_jobgroup,
                  NAMJOBGRPE  = v_namjobgrpe,
                  NAMJOBGRPT  = v_namjobgrpt,
                  NAMJOBGRP3  = v_namjobgrp3,
                  NAMJOBGRP4  = v_namjobgrp4,
                  NAMJOBGRP5  = v_namjobgrp5
              where jobgroup = v_jobgroup;
            end if;
          exception when others then
             param_msg_error := get_error_msg_php('HR2508',global_v_lang);
          end;

          begin
              select JOBGROUP
              into v_chk_codjobgrp
              from TJOBGROUP
              where JOBGROUP = upper(v_jobgroup)
              and CODTENCY = upper(v_codtency)
              and CODSKILL = upper(v_codskill);
          exception when no_data_found then
              v_chk_codjobgrp := null;
          end;

          if v_chk_codjobgrp is null then
            begin
                insert into TJOBGROUP (JOBGROUP,CODTENCY,CODSKILL)
                values (v_jobgroup, v_codtency, v_codskill);
            exception when others then
              param_msg_error := get_error_msg_php('HR2508',global_v_lang);
            end;
          end if;
        else  --if error
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
--          GET_ERRORM_NAME (v_err_code,global_v_lang)||v_err_table ||'('||v_err_filed||')';
--          replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1+1;
        end if;

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
  --
  procedure delete_tcodjobgrp (json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_count         number;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

      p_flg         := hcm_util.get_string_t(param_json_row,'flg');
      p_codjobgrp    := hcm_util.get_string_t(param_json_row,'jobgroup');

      if(p_flg = 'delete') then
        begin
            select count(*)
              into v_count
              from tjobpos
             where JOBGROUP = p_codjobgrp;
        exception when others then
            v_count := 0;
        end;
        
        if v_count > 0 then 
            param_msg_error := get_error_msg_php('HR1450',global_v_lang);
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            rollback;
            return;
        else
            Delete TCODJOBGRP where jobgroup = p_codjobgrp;
            Delete TJOBGROUP where jobgroup = p_codjobgrp;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_tcodjobgrp (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_check_exisitng number:=0;
  begin
    initial_value(json_str_input);
--    check_save_tcomptnc;

    if param_msg_error is null then

      begin
          select count(jobgroup)
          into v_check_exisitng
          from tcodjobgrp
          where jobgroup = p_codjobgrp;

          if v_check_exisitng > 0 then
            UPDATE tcodjobgrp
            SET namjobgrpe = p_namjobgrpe,
                namjobgrpt = p_namjobgrpt,
                namjobgrp3 = p_namjobgrp3,
                namjobgrp4 = p_namjobgrp4,
                namjobgrp5 = p_namjobgrp5
            WHERE jobgroup = p_codjobgrp;
          else
            insert into tcodjobgrp (jobgroup,namjobgrpe,namjobgrpt,namjobgrp3,namjobgrp4,namjobgrp5)
            values (p_codjobgrp, p_namjobgrpe, p_namjobgrpt, p_namjobgrp3, p_namjobgrp4, p_namjobgrp5);
          end if;
      exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end;
      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop

        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg         := hcm_util.get_string_t(param_json_row,'flg');
        p_codtency     := hcm_util.get_string_t(param_json_row,'codtency');

        if(p_flg = 'delete') then
          begin
            delete tjobgroup
            where jobgroup = p_codjobgrp
            and codtency = p_codtency;
          end;
        end if;
      end loop;
      if param_msg_error is null then
       param_msg_error := get_error_msg_php('HR2401',global_v_lang);
       commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
  --
  procedure save_tjobgroup (json_str_input in clob, json_str_output out clob) as
    param_json        json_object_t;
    param_json_row    json_object_t;
    v_chk_exist       varchar(10 char);
    v_chk_codskil     varchar(10 char);
    v_chk_codtency    varchar(10 char);
    v_codskill        varchar(10 char);
    v_chk_jobgroup number:=0;
    cursor c1 is
        select CODCODEC
        from tcodskil
        where CODCODEC IN (select codskill from TCOMPSKIL where codtency = p_codtency)
        order by CODCODEC;
  begin
    initial_value(json_str_input);
--    check_save_tcomptnc;
    check_save2;
    if param_msg_error is null then

      select count(jobgroup)
      into v_chk_jobgroup
      from tcodjobgrp
      where jobgroup = p_codjobgrp;

      if v_chk_jobgroup > 0 then
        UPDATE tcodjobgrp
        SET namjobgrpe = p_namjobgrpe,
            namjobgrpt = p_namjobgrpt,
            namjobgrp3 = p_namjobgrp3,
            namjobgrp4 = p_namjobgrp4,
            namjobgrp5 = p_namjobgrp5
        WHERE jobgroup = p_codjobgrp;
      else
        insert into tcodjobgrp (jobgroup,namjobgrpe,namjobgrpt,namjobgrp3,namjobgrp4,namjobgrp5)
        values (p_codjobgrp, p_namjobgrpe, p_namjobgrpt, p_namjobgrp3, p_namjobgrp4, p_namjobgrp5);
      end if;
      begin
        select distinct codtency
        into v_chk_exist
        from tjobgroup
        where jobgroup = p_codjobgrp
        and codtency = p_codtency;
      exception when no_data_found then
        v_chk_exist := null;
      end;

      if v_chk_exist is null then
        for i in c1 loop
          insert into tjobgroup (JOBGROUP,CODTENCY,CODSKILL)
          values (p_codjobgrp, p_codtency, i.CODCODEC);
        end loop;
      end if;
      param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
      for i in 0..param_json.get_size-1 loop

        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_flg           := hcm_util.get_string_t(param_json_row,'flg');
        p_codskill      := hcm_util.get_string_t(param_json_row,'codskill');
        p_old_codskil   := hcm_util.get_string_t(param_json_row,'codskillOld');

        if p_flg = 'delete' then
          begin
            delete tjobgroup
            where jobgroup = p_codjobgrp
            and codtency = p_codtency
            and codskill = p_codskill;
          end;
        end if;
        if p_flg = 'add' or p_flg = 'edit' then
          begin
            select codcodec
            into v_chk_codskil
            from tcodskil
            where codcodec = p_codskill;
          exception when no_data_found then
            rollback;
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODSKIL');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end;

          begin
            select distinct codskill
            into v_chk_codskil
            from tjobgroup
            where jobgroup = p_codjobgrp
            and codtency =  p_codtency
            and codskill = p_codskill;
          exception when no_data_found then
            v_chk_codskil := null;
          end;
          if v_chk_codskil is not null then
            rollback;
            param_msg_error := get_error_msg_php('HR2005',global_v_lang,'TJOBGROUP');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end if;

          begin
            select codtency
            into v_chk_codtency
            from tjobgroup
            where jobgroup = p_codjobgrp
            and codtency <>  p_codtency
            and codskill =  p_codskill;

          exception when no_data_found then
            v_chk_codtency := null;
          end;

          if v_chk_codtency is not null then
            rollback;
            param_msg_error := get_error_msg_php('CO0010',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end if;





          if p_flg = 'add' then
            insert into tjobgroup (JOBGROUP,CODTENCY,CODSKILL)
            values (p_codjobgrp, p_codtency, p_codskill);
          else
            update tjobgroup
            set CODSKILL = p_codskill
            where JOBGROUP = p_codjobgrp
            and CODTENCY = p_codtency
            and CODSKILL = p_old_codskil;
          end if;
        end if;
      end loop;
      if param_msg_error is null then
       param_msg_error := get_error_msg_php('HR2401',global_v_lang);
       commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
END HRCO0AE;

/

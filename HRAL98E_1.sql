--------------------------------------------------------
--  DDL for Package Body HRAL98E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL98E" is

  --grant create any directory to ST11;
  --grant drop any directory to ST11;

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_typmatch  := hcm_util.get_string_t(json_obj,'p_typmatch');

    p_typmatch        := hcm_util.get_string_t(json_obj,'typmatch');
    p_nammatch        := hcm_util.get_string_t(json_obj,'nammatch');
    p_codest          := to_number(hcm_util.get_string_t(json_obj,'codest'));
    p_codeen          := to_number(hcm_util.get_string_t(json_obj,'codeen'));
    p_flagst          := to_number(hcm_util.get_string_t(json_obj,'flagst'));
    p_flagen          := to_number(hcm_util.get_string_t(json_obj,'flagen'));
    p_dayst           := to_number(hcm_util.get_string_t(json_obj,'dayst'));
    p_dayen           := to_number(hcm_util.get_string_t(json_obj,'dayen'));
    p_monthst         := to_number(hcm_util.get_string_t(json_obj,'monthst'));
    p_monthen         := to_number(hcm_util.get_string_t(json_obj,'monthen'));
    p_yearst          := to_number(hcm_util.get_string_t(json_obj,'yearst'));
    p_yearen          := to_number(hcm_util.get_string_t(json_obj,'yearen'));
    p_hourst          := to_number(hcm_util.get_string_t(json_obj,'hourst'));
    p_houren          := to_number(hcm_util.get_string_t(json_obj,'houren'));
    p_minst           := to_number(hcm_util.get_string_t(json_obj,'minst'));
    p_minen           := to_number(hcm_util.get_string_t(json_obj,'minen'));
    p_mchnost         := to_number(hcm_util.get_string_t(json_obj,'mchnost'));
    p_mchnoen         := to_number(hcm_util.get_string_t(json_obj,'mchnoen'));
    p_codrecin        := hcm_util.get_string_t(json_obj,'codrecin');
    p_codrecout       := hcm_util.get_string_t(json_obj,'codrecout');
    p_pathfrom        := hcm_util.get_string_t(json_obj,'pathfrom');
    p_pathto          := hcm_util.get_string_t(json_obj,'pathto');
    p_patherror       := hcm_util.get_string_t(json_obj,'patherror');

  end initial_value;
  --
  procedure check_index is
    v_code    varchar2(100);
  begin
    if p_codest > p_codeen then
      param_msg_error := '1'||get_error_msg_php('HR2057',global_v_lang,'codest');
      return;
    end if;

    if p_flagst > p_flagen then
      param_msg_error := '2'||get_error_msg_php('HR2057',global_v_lang,'codest');
      return;
    end if;

    if p_dayst > p_dayen then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'dayst');
      return;
    end if;

    if p_monthst > p_monthen then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'monthst');
      return;
    end if;

    if p_yearst > p_yearen then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'yearst');
      return;
    end if;

    if p_hourst > p_houren then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'hourst');
      return;
    end if;

    if p_minst > p_minen then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'minst');
      return;
    end if;

    if p_mchnost > p_mchnoen then
      param_msg_error := get_error_msg_php('HR2057',global_v_lang,'mchnost');
      return;
    end if;
  end check_index;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row		    number := 0;
    cursor c1 is
      select typmatch,nammatch,codrecin,codrecout
        from ttexttrn
    order by typmatch;
  begin
    initial_value(json_str_input);
    obj_row    := json_object_t();

    for i in c1 loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('typmatch',i.typmatch);
      obj_data.put('nammatch',i.nammatch);
      obj_data.put('codrecin',i.codrecin);
      obj_data.put('codrecout',i.codrecout);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row           json_object_t;
    v_typmatch        varchar2(500 char);
    v_nammatch        varchar2(500 char);
    v_codest          number;
    v_codeen          number;
    v_flagst          number;
    v_flagen          number;
    v_dayst           number;
    v_dayen           number;
    v_monthst         number;
    v_monthen         number;
    v_yearst          number;
    v_yearen          number;
    v_hourst          number;
    v_houren          number;
    v_minst           number;
    v_minen           number;
    v_mchnost         number;
    v_mchnoen         number;
    v_codrecin        varchar2(100 char);
    v_codrecout       varchar2(100 char);
    v_pathfrom        varchar2(200 char);
    v_pathto          varchar2(200 char);
    v_patherror       varchar2(200 char);
  begin
    initial_value(json_str_input);
    begin
      select typmatch,nammatch,codest,codeen,flagst,flagen,dayst,dayen,monthst,monthen,yearst,yearen,
             hourst,houren,minst,minen,mchnost,mchnoen,codrecin,codrecout,pathfrom,pathto,patherror
        into v_typmatch,v_nammatch,v_codest,v_codeen,v_flagst,v_flagen,v_dayst,v_dayen,v_monthst,v_monthen,v_yearst,v_yearen,
             v_hourst,v_houren,v_minst,v_minen,v_mchnost,v_mchnoen,v_codrecin,v_codrecout,v_pathfrom,v_pathto,v_patherror
        from ttexttrn
       where typmatch = b_index_typmatch;
    exception when no_data_found then
      v_typmatch := '';
      v_nammatch := '';
      v_codest   := '';
      v_codeen   := '';
      v_flagst   := '';
      v_flagen   := '';
      v_dayst    := '';
      v_dayen    := '';
      v_monthst  := '';
      v_monthen  := '';
      v_yearst   := '';
      v_yearen   := '';
      v_hourst   := '';
      v_houren   := '';
      v_minst    := '';
      v_minen    := '';
      v_mchnost  := '';
      v_mchnoen  := '';
      v_codrecin  := '';
      v_codrecout := '';
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('typmatch', v_typmatch);
    obj_row.put('nammatch', v_nammatch);
    obj_row.put('codest', v_codest);
    obj_row.put('codeen', v_codeen);
    obj_row.put('flagst', v_flagst);
    obj_row.put('flagen', v_flagen);
    obj_row.put('dayst', v_dayst);
    obj_row.put('dayen', v_dayen);
    obj_row.put('monthst', v_monthst);
    obj_row.put('monthen', v_monthen);
    obj_row.put('yearst', v_yearst);
    obj_row.put('yearen', v_yearen);
    obj_row.put('hourst', v_hourst);
    obj_row.put('houren', v_houren);
    obj_row.put('minst', v_minst);
    obj_row.put('minen', v_minen);
    obj_row.put('mchnost', v_mchnost);
    obj_row.put('mchnoen', v_mchnoen);
    obj_row.put('codrecin', v_codrecin);
    obj_row.put('codrecout', v_codrecout);
    obj_row.put('pathfrom', v_pathfrom);
    obj_row.put('pathto', v_pathto);
    obj_row.put('patherror', v_patherror);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure save_data(json_str_input in clob, json_str_output out clob) is
    v_count         number;
    v_sysplat       varchar2(100 char);
    v_directory     varchar2(4000 char);
    v_basename      tsetup.value%type;
    cursor c1 is
        select * from table(RDSADMIN.RDS_FILE_UTIL.LISTDIR(v_directory)) order by mtime;
  begin
    initial_value(json_str_input);
    check_index;
    v_sysplat  := get_tsetup_value('SYSPLATFORM');
    v_basename := get_tsetup_value('LBASENAME');

    if param_msg_error is null then

        if p_pathfrom is not null and p_pathto is not null and p_patherror is not null then
            begin
               if lower(v_sysplat) <> 'aws' then
                    execute immediate ('create or replace directory utl_file_dir_'||v_basename||'_'||p_typmatch||'_1 as '''||p_pathfrom||'''');
                    execute immediate ('create or replace directory utl_file_dir_'||v_basename||'_'||p_typmatch||'_2 as '''||p_pathto||'''');
                    execute immediate ('create or replace directory utl_file_dir_'||v_basename||'_'||p_typmatch||'_3 as '''||p_patherror||'''');
                    commit;
                else
                    for i in 1..3 loop
                        v_directory := upper('utl_file_dir_'||v_basename||'_'||p_typmatch||'_' || i);

                        begin
                            select count(*) into v_count
                            from all_directories 
                            where directory_name = v_directory;
                        exception when others then
                            v_count := 0;
                        end;
                        if v_count > 0 then
                            for r1 in c1 loop
                                if r1.type = 'file' then
                                    utl_file.fremove(v_directory,r1.filename);
                                end if;
                            end loop;
                            rdsadmin.rdsadmin_util.drop_directory(v_directory);
                        end if;
                        rdsadmin.rdsadmin_util.create_directory(v_directory);
                    end loop;

                end if;
            exception when others then
                rollback;
                param_msg_error := get_error_msg_php('HR8820',global_v_lang);
            end;
        end if;
      if param_msg_error is null then
          begin
            insert into ttexttrn(typmatch, nammatch, codrecin, codrecout, codest, codeen, flagst, flagen,
                                 dayst, dayen, monthst, monthen, yearst, yearen, hourst, houren, minst,
                                 minen, mchnost, mchnoen, pathfrom, pathto, patherror, codcreate, dteupd, coduser)
                         values (p_typmatch, p_nammatch, p_codrecin, p_codrecout, p_codest, p_codeen, p_flagst, p_flagen,
                                 p_dayst, p_dayen, p_monthst, p_monthen, p_yearst, p_yearen, p_hourst, p_houren, p_minst,
                                 p_minen, p_mchnost, p_mchnoen, p_pathfrom, p_pathto, p_patherror, global_v_coduser, trunc(sysdate), global_v_coduser);
                    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          exception when dup_val_on_index then
            begin
              update  ttexttrn
              set     nammatch = p_nammatch,
                      codrecin = p_codrecin,
                      codrecout= p_codrecout,
                      codest   = p_codest,
                      codeen   = p_codeen,
                      flagst   = p_flagst,
                      flagen   = p_flagen,
                      dayst    = p_dayst,
                      dayen    = p_dayen,
                      monthst  = p_monthst,
                      monthen  = p_monthen,
                      yearst   = p_yearst,
                      yearen   = p_yearen,
                      hourst   = p_hourst,
                      houren   = p_houren,
                      minst    = p_minst,
                      minen    = p_minen,
                      mchnost  = p_mchnost,
                      mchnoen  = p_mchnoen,
                      pathfrom = p_pathfrom,
                      pathto   = p_pathto,
                      patherror = p_patherror,
                      dteupd   = trunc(sysdate),
                      coduser  = global_v_coduser
              where   typmatch = p_typmatch;
                    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            exception when others then
              rollback;
            end;
          end;
        end if;

    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_data;

  procedure delete_data(json_str_input in clob,json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

--       begin
--          execute immediate ('drop directory utl_file_dir_'||p_typmatch||'_1');
--          execute immediate ('drop directory utl_file_dir_'||p_typmatch||'_2');
--          execute immediate ('drop directory utl_file_dir_'||p_typmatch||'_3');
--          commit;
--        exception when others then
--          param_msg_error := get_error_msg_php('HR8820',global_v_lang);
--          rollback;
--        end;
      if param_msg_error is null then
         for i in 0..param_json.get_size-1 loop
            param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
            p_typmatch      := hcm_util.get_string_t(param_json_row,'typmatch');

            begin
              delete from ttexttrn
                    where typmatch = p_typmatch;
            end;
        end loop;
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
      else
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_data;

end HRAL98E;

/

--------------------------------------------------------
--  DDL for Package Body HRES49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES49X" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_query_codempid  := hcm_util.get_string_t(json_obj,'p_query_codempid');
    v_codapp          := 'HRES49X';

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure clear_ttemprpt is
  begin
    begin
        delete
        from  ttemprpt
        where codempid = global_v_codempid
          and codapp   = v_codapp;
    exception when others then
        null;
    end;
  end clear_ttemprpt;

  function get_max_numseq return number as
    p_numseq         number;
    max_numseq       number;
  begin
--  get max numseq
    begin
      select max(numseq) into max_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = v_codapp;
    exception when no_data_found then
      max_numseq := 0;
    end;
    if max_numseq is null then
        max_numseq := 0 ;
    end if;
    p_numseq := max_numseq+1;
    return p_numseq;
  end;

  procedure check_index as
    v_temp      varchar(1 char);
  begin
--   check null parameter
    if p_query_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
--  check codempid
    begin
      select 'X' into v_temp
        from temploy1
       where codempid = p_query_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;
  end check_index;

  function check_statement (v_codempid temploy1.codempid%type, v_syncond tobfcde.syncond%type, v_table varchar2 default 'TEMPLOY1') return boolean AS ----
    v_flgfound        boolean := false;
    v_statment        varchar2(1000 char);
    v_staemp          temploy1.staemp%type;
    v_codcomp         temploy1.codcomp%type;
    v_codpos          temploy1.codpos%type;
    v_numlvl          temploy1.numlvl%type;
    v_codjob          temploy1.codjob%type;
    v_codempmt        temploy1.codempmt%type;
    v_typemp          temploy1.typemp%type;
    v_typpayroll      temploy1.typpayroll%type;
    v_codbrlc         temploy1.codbrlc%type;
    v_codcalen        temploy1.codcalen%type;
    v_jobgrade        temploy1.jobgrade%type;
    v_codgrpgl        temploy1.codgrpgl%type;
    v_dteeffec        ttmovemt.dteeffec%type;
    v_amthour         number;
    v_amtday          number;
    v_amtmth          number;

  begin
    if v_syncond is not null then
      v_flgfound        := false;
      v_dteeffec        := trunc(sysdate); --to_date('31/12/' || to_char(p_dteyeen),'dd/mm/yyyy');
      begin
        select staemp, codcomp, codpos, numlvl, codjob, codempmt, typemp, typpayroll, codbrlc, codcalen, jobgrade, codgrpgl
          into v_staemp, v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl
          from temploy1
         where codempid = v_codempid;
      exception when no_data_found then
        null;
      end;
      std_al.get_movemt (v_codempid, v_dteeffec, 'C', 'U',
                         v_codcomp, v_codpos, v_numlvl, v_codjob, v_codempmt, v_typemp, v_typpayroll, v_codbrlc, v_codcalen, v_jobgrade, v_codgrpgl,
                         v_amthour, v_amtday, v_amtmth);
      v_statment := v_syncond;
      v_statment := replace(v_statment, v_table || '.STAEMP','''' || v_staemp || '''');
      v_statment := replace(v_statment, v_table || '.CODCOMP','''' || v_codcomp || '''');
      v_statment := replace(v_statment, v_table || '.CODPOS','''' || v_codpos || '''');
      v_statment := replace(v_statment, v_table || '.NUMLVL', v_numlvl);
      v_statment := replace(v_statment, v_table || '.CODJOB','''' || v_codjob || '''');
      v_statment := replace(v_statment, v_table || '.CODEMPMT','''' || v_codempmt || '''');
      v_statment := replace(v_statment, v_table || '.TYPEMP','''' || v_typemp || '''');
      v_statment := replace(v_statment, v_table || '.TYPPAYROLL','''' || v_typpayroll || '''');
      v_statment := replace(v_statment, v_table || '.CODBRLC','''' || v_codbrlc || '''');
      v_statment := replace(v_statment, v_table || '.CODCALEN','''' || v_codcalen || '''');
      v_statment := replace(v_statment, v_table || '.JOBGRADE','''' || v_jobgrade || '''');
      v_statment := replace(v_statment, v_table || '.CODGRPGL','''' || v_codgrpgl || '''');
      v_statment := 'select count(*) from dual where ' || v_statment;
      v_flgfound := execute_stmt(v_statment);
      return v_flgfound;
    end if;
    return true;
  end check_statement;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    obj_rows2       json_object_t;
    obj_data2       json_object_t;
    v_row2          number := 0;
    obj_data3       json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_amtalwyr      tobfcft.amtalwyr%type;
    v_amtwidrw      tobfsum.amtwidrw%type;
    v_dtestart      tobfcft.dtestart%type;
    v_amtalw        tobfcftd.amtalw%type;
    v_qtytalw       tobfcdet.qtyalw%type;
    v_statement     long;
    v_syncond       tobfcde.syncond%type;
    v_codunit       tobfcde.codunit%type;
    v_flgfamily     tobfcde.flgfamily%type;
    v_typrelate     tobfcde.typrelate%type;
    v_desnote       tobfcde.desnote%type;
    v_amtvalue      tobfcde.amtvalue%type;
    v_flglimit      tobfcde.flglimit%type;
    v_syncond2      tobfcdet.syncond%type;
    v_namimage      tobfcde.namimage%type;
    v_tobfbgyr_dteeffec      tobfbgyr.dteeffec%type;
    v_tobfbgyr_syncond       tobfbgyr.syncond%type;

--    v_amtalwyr      tobfbgyr.amtalwyr%type;

    v_codobf        tobfcdet.codobf%type;
    v_typebf        tobfcde.typebf%type;
    v_flgcond       boolean;
    v_flgemp        boolean;
    v_flgsetup      boolean;
    v_balance       number;

    cursor c1 is
        select codobf
         from  tobfcompy
        where  codcompy = get_codcompy(v_codcomp)
    ----      and    codobf in (select codobf from tobfcde where typegroup = '2')
        order by codobf;

    cursor c_tobfcdet is ----
      select qtyalw,qtytalw,syncond
        from tobfcdet
       where codobf = v_codobf
    order by numobf;

    cursor c_tobfbgyr is ----
      select dteeffec, numseq, syncond, amtalwyr
        from tobfbgyr
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tobfbgyr
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and trunc(dteeffec) <= trunc(sysdate))
    order by numseq;

  begin
--  get data from temploy1
    begin
        select codcomp,codpos into v_codcomp,v_codpos
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_codcomp := '';
        v_codpos := '';
    end;
--  get max date from tobfcft
    begin
        select max(dtestart) into v_dtestart
        from  tobfcft
        where codempid = p_query_codempid ----;
        and   dtestart <= sysdate; ----
    exception when no_data_found then
        v_dtestart := '';
    end;

    --get data from tobfcft
    begin
      select  nvl(amtalwyr,0) into v_amtalwyr
        from tobfcft
       where codempid = p_query_codempid
         and dtestart = v_dtestart;
    exception when no_data_found then ----v_amtalwyr := 0;
      for j in c_tobfbgyr loop ----
        if check_statement(p_query_codempid, j.syncond, 'V_HRBF41') then
          v_amtalwyr := hral71b_batch.cal_formula(p_query_codempid, j.amtalwyr, j.dteeffec);
          exit;
        end if;
      end loop;
              when too_many_rows then v_amtalwyr := 0;
--      , amtalwyr
--      , v_amtalwyr

      begin
        select dteeffec, syncond into v_tobfbgyr_dteeffec, v_tobfbgyr_syncond
          from tobfbgyr
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tobfbgyr
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1))
        order by numseq;
      exception when no_data_found then
        null;
      end;
    end;

    --get data from tobfsum
    begin
      select nvl(sum(amtwidrw),0) into v_amtwidrw
        from tobfsum
       where codempid = p_query_codempid
         and dteyre = to_number(to_char(sysdate,'yyyy'))
         --
         and dtemth = 13;
    exception when no_data_found then
      v_amtwidrw := 0;
    end;

    obj_rows := json_object_t();
    obj_data := json_object_t();
    obj_data.put('coderror',200);
    obj_data.put('image',p_query_codempid);
    obj_data.put('codempid',p_query_codempid);
    obj_data.put('desc_codempid',get_temploy_name(p_query_codempid,global_v_lang));
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('codpos',v_codpos);
    obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
    obj_data.put('amtalwyr',to_char(v_amtalwyr,'fm999,999,990.00'));
    obj_data.put('amtwidrw',to_char(greatest(v_amtalwyr - v_amtwidrw,0),'fm999,999,990.00'));
    obj_rows2 := json_object_t();
    for i in c1 loop
      v_flgemp    := false; ----
      v_flgsetup  := false; ----

      --get data from tobfsum
      begin
        select nvl(sum(amtwidrw),0) into v_amtwidrw
          from tobfsum
         where codempid = p_query_codempid
           and dteyre = to_number(to_char(sysdate,'yyyy'))
           and codobf = i.codobf
           and dtemth = 13;
      exception when no_data_found then
          v_amtwidrw := 0;
      end;

      -- get data from tobfcftd
      begin
        select amtalw,qtytalw into v_amtalw,v_qtytalw
        from tobfcftd
        where codempid = p_query_codempid
          and dtestart = v_dtestart
          and codobf = i.codobf;

        v_balance := greatest((v_amtalw - v_amtwidrw) ,0); ----
        v_flgemp  := true; ----
      exception when no_data_found then
        v_amtalw  := 0;
        v_qtytalw := 0;
        v_balance := 0; ----
        v_flgemp  := false; ----
      end;

      if not v_flgemp then ----v_amtalw = 0 and v_qtytalw = 0 then
        begin
          select syncond,amtvalue,typebf
          into v_syncond,v_amtvalue,v_typebf
          from tobfcde
          where codobf = i.codobf;
        exception when no_data_found then
          v_syncond   := '';
          v_amtvalue  := 0;
          v_typebf    := '';
        end;
        if v_syncond is not null then
          v_syncond := 'and ('||v_syncond||')';
        end if;
        --
        v_codobf := i.codobf;
        for r1 in c_tobfcdet loop
          v_flgcond := false;
          if r1.syncond is not null then
            v_syncond2 := ' AND ('||r1.syncond||')';
          else
            v_syncond2 := null;
          end if;
          v_statement := 'select count(*) '||
                         'from V_HRBF41 '||
                         'where codempid =  '''||p_query_codempid||''' '||
                         v_syncond||' '||
                         v_syncond2;
          v_flgcond := execute_stmt(v_statement);
          if v_flgcond then
            if v_typebf = 'C' then
              v_amtalw := r1.qtyalw;
            else -- 'T'
              v_amtalw := r1.qtyalw * v_amtvalue;
            end if;
            v_qtytalw := r1.qtytalw;
            v_balance := greatest((v_amtalw - v_amtwidrw) ,0);
            v_flgsetup := true; ----
            exit;
          end if;
        end loop;
      else
        null;
      end if;    

      if v_flgemp or v_flgsetup then ----Show codobf box
      v_row2 := v_row2 + 1;
      obj_data2 := json_object_t();
      obj_data3 := json_object_t();
      obj_data2.put('codobf',i.codobf);
      obj_data2.put('codobf_name',get_tobfcde_name(i.codobf,global_v_lang));
      ----obj_data.put('balance',to_char(v_amtalw - v_amtwidrw,'fm999,999,990.00'));
      -- set drilldown object
      begin
          select namimage,syncond,codunit,amtvalue,flglimit,flgfamily,typrelate,desnote
          into v_namimage,v_syncond,v_codunit,v_amtvalue,v_flglimit,v_flgfamily,v_typrelate,v_desnote
          from tobfcde
          where codobf = i.codobf;
      exception when no_data_found then
          v_namimage  := '';
          v_syncond   := '';
          v_codunit   := '';
          v_amtvalue  := '';
          v_flglimit  := '';
          v_flgfamily := '';
          v_typrelate := '';
          v_desnote   := '';
      end;
      if v_syncond is not null then
        v_syncond := 'and ' || v_syncond;
      end if;
      if v_namimage is not null then
--          begin
--              select 'file_uploads/'||folder||'/'||v_namimage into v_namimage
--              from tfolderd
--              where codapp = 'HRBF41E';
--          exception when no_data_found then
--              v_namimage := v_namimage;
--          end;
        v_namimage := get_tsetup_value('PATHDOC')||get_tfolderd('HRBF41E1')||'/'||v_namimage;
      end if;

      obj_data2.put('image',v_namimage);
      obj_data2.put('codunit_name',get_tcodunit_name(v_codunit,global_v_lang));
      obj_data2.put('amtvalue',to_char(v_amtalw,'fm999,999,990.00'));
      obj_data2.put('flgfamily_name',get_tlistval_name('FLGYESNO',v_flgfamily,global_v_lang));
      obj_data2.put('flglimit_name',get_tlistval_name('TYPELIMIT',v_flglimit,global_v_lang));
      obj_data2.put('typrelate_name',get_tlistval_name('TYPRELATE',v_typrelate,global_v_lang));
      obj_data2.put('desnote',v_desnote);
      obj_data2.put('amtwidrw',to_char(v_amtwidrw,'fm999,999,990.00'));

      obj_data2.put('coderror',200);

      ----
      obj_data2.put('amtalw',to_char(v_amtalw,'fm999,999,990.00'));
      obj_data2.put('qtytalw',to_char(v_qtytalw,'fm999,990'));
      obj_data2.put('balance',to_char(v_balance,'fm999,999,990.00'));

/*
      if v_amtalw = 0 and v_qtytalw = 0 then
          declare
              type rc_tobfcdet is record (
                  amtalw     number,
                  qtytalw    number
              );
              type tb_tobfcdet is table of rc_tobfcdet index by pls_integer;

          codobf_data      tb_tobfcdet;

          begin
              begin
                  select 'and '||syncond into v_syncond2
                  from tobfcdet
                  where codobf = i.codobf
                    and numobf = (select max(numobf)
                                  from tobfcdet
                                  where codobf = i.codobf);
              exception when no_data_found then
                  v_syncond2 := '';
              end;
              v_syncond := replace(v_syncond,'V_HRBF41.CODREL','E') ;
              v_syncond2 := replace(v_syncond2,'V_HRBF41.CODREL','E') ;
              v_statement := 'select tobfcftd.amtalw,tobfcftd.qtytalw '||
                             'from V_HRBF41,tobfcftd '||
                             'where tobfcftd.codobf = '||''''||i.codobf||''''||' '||
                             'and V_HRBF41.codempid = tobfcftd.codempid '||
                             'and tobfcftd.codempid = '||''''||p_query_codempid||''''||' '||
                             v_syncond||' '||
                             v_syncond2||' '||
                             'and rownum = 1'
                             ;
              execute immediate v_statement bulk collect into codobf_data;

              obj_data2.put('amtalw','');
              obj_data2.put('qtytalw','');
              obj_data2.put('balance','');
              for i2 in 1..codobf_data.count loop
                  obj_data2.put('amtalw',to_char(codobf_data(i2).amtalw,'fm999,999,990.00'));
                  obj_data2.put('qtytalw',to_char(codobf_data(i2).qtytalw,'fm999,999,990.00'));
                  obj_data2.put('balance','b2:'||to_char((codobf_data(i2).amtalw - v_amtwidrw),'fm999,999,990.00'));
              end loop;
          end;
      else
          obj_data2.put('amtalw',to_char(v_amtalw,'fm999,999,990.00'));
          obj_data2.put('qtytalw',to_char(v_qtytalw,'fm999,999,990.00'));
          obj_data2.put('balance','b3:'||to_char((v_amtalw - v_amtwidrw),'fm999,999,990.00'));
      end if;
*/
--      obj_data2.put('drilldown',obj_data3);
      obj_rows2.put(to_char(v_row2-1),obj_data2);
      end if; ----
    end loop;

    obj_data.put('table',obj_rows2);
    obj_rows.put(to_char(v_row),obj_data);

    if v_row2 = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tobfsum');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure gen_report(json_str_output out clob) as
    v_max_numseq    number;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_amtalwyr      tobfcft.amtalwyr%type;
    v_amtwidrw      tobfsum.amtwidrw%type;
    v_dtestart      tobfcft.dtestart%type;
    v_amtalw        tobfcftd.amtalw%type;
    v_qtytalw       tobfcdet.qtyalw%type;
    v_statement     long;
    v_namimage      tobfcde.namimage%type;

    cursor c1 is
      select codobf
      from tobfcompy
      where codcompy = get_codcompy(v_codcomp)
      order by codobf;

    cursor c_tobfbgyr is ----
      select dteeffec, numseq, syncond, amtalwyr
        from tobfbgyr
       where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tobfbgyr
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and trunc(dteeffec) <= trunc(sysdate))
    order by numseq;
  begin
  --  get data from temploy1
    begin
        select codcomp,codpos into v_codcomp,v_codpos
        from temploy1
        where codempid = p_query_codempid;
    exception when no_data_found then
        v_codcomp := '';
        v_codpos := '';
    end;
--  get max date from tobfcft
    begin
      select max(dtestart) into v_dtestart
      from tobfcft
      where codempid = p_query_codempid ----;
      and   dtestart <= sysdate; ----
    exception when no_data_found then
      v_dtestart := '';
    end;
--  get data from tobfcft
    begin
      select amtalwyr into v_amtalwyr
      from tobfcft
      where codempid = p_query_codempid
        and dtestart = v_dtestart;
    exception when no_data_found then
      ----v_amtalwyr := 0;
      for j in c_tobfbgyr loop ----
        if check_statement(p_query_codempid, j.syncond, 'V_HRBF41') then
          v_amtalwyr := hral71b_batch.cal_formula(p_query_codempid, j.amtalwyr, j.dteeffec);
          exit;
        end if;
      end loop;
    end;
--  get data from tobfsum
    begin
        select sum(amtwidrw) into v_amtwidrw
        from tobfsum
        where codempid = p_query_codempid
          and dteyre = to_number(to_char(sysdate,'yyyy'))
          and dtemth = 13;
    exception when no_data_found then
        v_amtwidrw := 0;
    end;
--  insert header
    v_max_numseq := get_max_numseq;
    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
    values(global_v_codempid, v_codapp,v_max_numseq, p_query_codempid, get_temploy_name(p_query_codempid,global_v_lang), get_tcenter_name(v_codcomp,global_v_lang), get_tpostn_name(v_codpos,global_v_lang), v_amtalwyr, v_amtalwyr - v_amtwidrw,'header',v_codpos);

    for i in c1 loop
      -- get data from tobfcftd
      begin
        select amtalw,qtytalw into v_amtalw,v_qtytalw
          from tobfcftd
         where codempid = p_query_codempid
           and dtestart = v_dtestart
           and codobf = i.codobf;
      exception when no_data_found then
        v_amtalw := 0;
        v_qtytalw := 0;
      end;

      begin
        select namimage
          into v_namimage
          from tobfcde
         where codobf = i.codobf;
      exception when no_data_found then
        v_namimage  := '';
      end;
      if v_namimage is not null then
        begin
          select 'file_uploads/'||folder||'/'||v_namimage into v_namimage
            from tfolderd
           where codapp = 'HRBF41E';
        exception when no_data_found then
            v_namimage := v_namimage;
        end;
      end if;
      --  insert list card
      v_max_numseq := get_max_numseq;
      begin
        insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4)
             values (global_v_codempid,v_codapp,v_max_numseq,get_tobfcde_name(i.codobf,global_v_lang),v_amtalw - v_amtwidrw,v_namimage,'list_codheal');
      end;
    end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    return;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure get_report(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    clear_ttemprpt;
    if param_msg_error is null then
      gen_report(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_report;
end hres49x;

/

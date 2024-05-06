--------------------------------------------------------
--  DDL for Package Body HRES72E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES72E" as
  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dteyear           := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'dd/mm/yyyy');
    p_limit     	      := to_number(replace(hcm_util.get_string_t(json_obj,'p_limit'),',',''));
    p_balance 	        := to_number(hcm_util.get_string_t(json_obj,'p_balance'));
    param_json          := hcm_util.get_json_t(json_obj,'param_json');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure check_detail is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_temp      varchar2(10 char);
    v_flgSecur  boolean;
  begin
    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    begin
      select 'X' into v_temp
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      return;
    end;
    if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_zupdsal) = false then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
  end;

  procedure gen_detail(json_str_output out clob)as
    obj_result      json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codempid      temploy1.codempid%type;
    v_codcomp       tcenter.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_staemp        temploy1.staemp%type;
    v_numlvl        temploy1.numlvl%type;
    v_codbrlc       temploy1.codbrlc%type;
    v_typemp        temploy1.typemp%type;
    v_jobgrade      temploy1.jobgrade%type;

    v_dteeffec      tobfbgyr.dteeffec%type;
    v_syncond       tobfbgyr.syncond%type;
    v_amtalwyr      tobfbgyr.amtalwyr%type;
    v_cond          tobfbgyr.syncond%type;
    v_cond2         tobfbgyr.syncond%type;
    v_stmt          varchar2(2000 char);
    v_stmt2         varchar2(2000 char);
    v_flgcal        boolean := false;
    v_flgcond1      number := 0;
    v_flgcond2      number := 0;
    v_amtlimit      number;
    v_rcnt          number := 0;
    v_codobf		    tobfcde.codobf%type;
    v_namimage		  tobfcde.namimage%type;
    v_codunit		    tobfcde.codunit%type;
    v_amtvalue		  tobfcde.amtvalue%type;
    v_desnote		    tobfcde.desnote%type;
    v_flglimit		  tobfcde.flglimit%type;
    v_flgfamily		  tobfcde.flgfamily%type;
    v_typrelate		  tobfcde.typrelate%type;
    v_desobf		    tobfcde.desobfe%type;
    v_typegroup		  tobfcde.typegroup%type;
    v_typebf		    tobfcde.typebf%type;
    v_qtyalw		    tobfcdet.qtyalw%type;
    v_amtalw		    number := 0;
    v_sumamtalw     number := 0;
    tobfcftd_qtyalw  tobfcftd.qtyalw%type;
    tobfcde_syncond   tobfcde.syncond%type;

    tobfcft_dtestart      tobfcft.dtestart%type;
    tobfcft_amtalwyr      tobfcft.amtalwyr%type;
    v_flgselect     varchar2(2 char);
    v_flgExist      varchar2(2 char);
    v_pathworkphp   varchar2(1000) := get_tsetup_value('PATHWORKPHP');

    cursor c1 is
      select codobf
        from tobfcompy
       where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
       order by codobf;

    cursor c2 is
      select *
        from tobfcdet
       where codobf = v_codobf
       order by numobf;
  begin
    begin
      select codcomp,codpos, staemp, numlvl, codbrlc, typemp, jobgrade
        into v_codcomp, v_codpos, v_staemp, v_numlvl, v_codbrlc, v_typemp, v_jobgrade
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    begin
      select dteeffec, syncond, amtalwyr into v_dteeffec, v_syncond, v_amtalwyr
       from ( select dteeffec, syncond, amtalwyr
          from tobfbgyr
         where codcompy =  hcm_util.get_codcomp_level(v_codcomp, 1)
           and dteeffec = (select max(dteeffec)
                             from tobfbgyr
                            where codcompy =  hcm_util.get_codcomp_level(v_codcomp, 1)
                              and dteeffec <= sysdate )
        order by numseq Desc
        ) where rownum=1;
    exception when no_data_found then null;
    end;
    begin
      select dtestart, amtalwyr into tobfcft_dtestart, tobfcft_amtalwyr
        from tobfcft
       where codempid =  p_codempid
         and dtestart = (select max(dtestart)
                           from tobfcft
                          where codempid =  p_codempid
                            and to_number(to_char(dtestart,'yyyy')) = to_number(to_char(sysdate,'yyyy')) );
      v_flgExist := 'Y';
    exception when no_data_found then
      v_flgExist := 'N';
      begin
        select dtestart, amtalwyr into tobfcft_dtestart, tobfcft_amtalwyr
          from tobfcft
         where codempid =  p_codempid
           and dtestart = (select max(dtestart)
                             from tobfcft
                            where codempid =  p_codempid
                              and dtestart <= sysdate );
      exception when no_data_found then
        v_flgExist := 'N';
      end;
    end;
    obj_row := json_object_t();
    for r1 in c1 loop
      v_codobf := r1.codobf;
      begin
        select namimage,codunit,amtvalue,desnote,flglimit,flgfamily,typrelate,
               typegroup, syncond, typebf,
               decode(global_v_lang,'101',desobfe
                                   ,'102',desobft
                                   ,'103',desobf3
                                   ,'104',desobf4
                                   ,'105',desobf5) as desobf
        into v_namimage,v_codunit,v_amtvalue,v_desnote,v_flglimit,v_flgfamily,v_typrelate,
             v_typegroup, tobfcde_syncond, v_typebf,
             v_desobf
        from tobfcde
        where codobf = v_codobf;
      exception when no_data_found then
        null;
      end;
      if v_typegroup = 2 then
        if tobfcde_syncond is not null then
          v_cond := 'and (' || tobfcde_syncond;
          v_cond := replace(v_cond,'V_HRBF41.CODREL','E') ;
          v_stmt :=  'select count(*)'||
                     'from V_HRBF41,tobfcde,TCLNSINF '||
                     'where tobfcde.codobf = '||''''||v_codobf||''''||' '||
                     'and V_HRBF41.codempid = '||''''||p_codempid||''''||
                     'and V_HRBF41.codempid = TCLNSINF.codempid(+) '||
                     v_cond||') '||
                     'and rownum = 1';

          execute immediate v_stmt into v_flgcond1;
        end if;
        if v_flgcond1 > 0 then
          for r2 in c2 loop
            if r2.syncond is not null then
              v_cond2 := 'and (' || r2.syncond;
              v_cond2 := replace(v_cond2,'V_HRBF41.CODREL','E') ;
              v_stmt2 := 'select count(*)'||
                         'from V_HRBF41,tobfcde,TCLNSINF '||
                         'where tobfcde.codobf = '||''''||v_codobf||''''||' '||
                         'and V_HRBF41.codempid = '||''''||p_codempid||''''||
                         'and V_HRBF41.codempid = TCLNSINF.codempid(+) '||
                         v_cond2||') '||
                         'and rownum = 1';
              execute immediate v_stmt2 into v_flgcond2;
              if v_flgcond2 > 0 then
                if v_namimage is not null then
                  begin
                      select v_pathworkphp||'/'||folder||'/'||v_namimage into v_namimage
                      from tfolderd
                      where codapp = 'HRBF41E1';
                  exception when no_data_found then
                      v_namimage := v_namimage;
                  end;
                end if;
                begin
                  select qtyalw into tobfcftd_qtyalw
                    from tobfcftd
                   where codempid = p_codempid
                     and dtestart = tobfcft_dtestart
                     and codobf = v_codobf;
                     v_flgselect := 'Y';
                exception when no_data_found then
                  tobfcftd_qtyalw := 0;
                  v_flgselect := 'N';
                end;
                --
                if v_typebf = 'C' then
                  if v_flglimit = 'M' then
                    v_amtalw := r2.qtyalw * 12;
                  elsif v_flglimit in ('Y','A') then
                    v_amtalw := r2.qtyalw;
                  end if;
                elsif v_typebf = 'T' then
                  if v_flglimit = 'M' then
                    v_amtalw := (r2.qtyalw * v_amtvalue) * 12;
                  elsif v_flglimit in ('Y','A') then
                    v_amtalw := (r2.qtyalw * v_amtvalue);
                  end if;
                end if;
                v_rcnt      := v_rcnt+1;
                obj_data    := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('codobf', r1.codobf );
                obj_data.put('desobf', v_desobf);
--                obj_data.put('amtvalue', v_amtvalue );
                obj_data.put('amtvalue', to_char(v_amtvalue,'fm999,999,990.00') );
                obj_data.put('namimage', v_namimage );
                obj_data.put('flgselect', v_flgselect );
                obj_data.put('codunit', get_tcodec_name('tcodunit', v_codunit, global_v_lang) );
                obj_data.put('flglimit', v_flglimit);
                obj_data.put('desc_flglimit', get_tlistval_name('TYPELIMIT', v_flglimit, global_v_lang ));
                obj_data.put('flgfamily', v_flgfamily );
                obj_data.put('desc_flgfamily', get_tlistval_name('FLGYESNO', v_flgfamily, global_v_lang ) );
                obj_data.put('typrelate', get_tlistval_name('TYPRELATE', v_typrelate,global_v_lang ) );
--                obj_data.put('qtyalw', v_amtalw ); -- จำนวนที่เบิกได้สูงสุด
                obj_data.put('qtyalw', to_char(v_amtalw,'fm999,999,990.00') ); -- จำนวนที่เบิกได้สูงสุด
                obj_data.put('qtytalw', r2.qtytalw ); -- จำนวนครั้งที่เบิกได้สูงสุด
--                obj_data.put('qtywidrw', tobfcftd_qtyalw ); -- จำนวนที่เบิกแล้วสะสม
                obj_data.put('qtywidrw', to_char(tobfcftd_qtyalw,'fm999,999,990.00') ); -- จำนวนที่เบิกแล้วสะสม
                obj_data.put('balance', to_char((v_amtalw - tobfcftd_qtyalw), 'fm999,999,990.00')); -- คงเหลือ
                obj_data.put('desnote', v_desnote );
                obj_row.put(to_char(v_rcnt-1),obj_data);
                v_sumamtalw := v_sumamtalw + tobfcftd_qtyalw;
                exit;
              end if;
            end if;
          end loop;
        end if;
      end if;
    end loop;
    v_flgcal := false;
    v_cond := '';
    if v_syncond is not null then
      v_cond := v_syncond;
      v_cond := replace(v_cond,'TEMPLOY1.STAEMP',''''||v_staemp||'''');
      v_cond := replace(v_cond,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''');
      v_cond := replace(v_cond,'TEMPLOY1.NUMLVL',v_numlvl);
      v_cond := replace(v_cond,'TEMPLOY1.CODBRLC',''''||v_codbrlc||'''');
      v_cond := replace(v_cond,'TEMPLOY1.TYPEMP',''''||v_typemp||'''');
      v_cond := replace(v_cond,'TEMPLOY1.JOBGRADE',''''||v_jobgrade||'''');
      v_stmt := 'select count(*) from dual where '||v_cond;
      v_flgcal := execute_stmt(v_stmt);
    end if;
    v_amtlimit := 0;
    if v_flgcal then
      v_amtlimit  := hral71b_batch.cal_formula(p_codempid, v_amtalwyr, v_dteeffec);
    end if;
    v_dteeffec := tobfcft_dtestart;
    if v_flgExist = 'Y' then
      v_amtlimit := tobfcft_amtalwyr;
    end if;
    obj_result    := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('codempid', p_codempid);
    obj_result.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang));
    obj_result.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_result.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
    obj_result.put('limit', to_char(v_amtlimit,'fm999,999,990.00'));
    obj_result.put('balance', v_amtlimit - v_sumamtalw);
    obj_result.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
    obj_result.put('table', obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
   procedure check_save (param_json in json_object_t)is
    data_row          json_object_t;
    v_codobf          tobfcde.codobf%type;
    v_flgselect       varchar2(2 char);
    v_chkexist        number := 0;
    v_chkDup          number := 0;
    v_chkSel          number := 0;
  begin

    if p_balance < 0 then
      param_msg_error := get_error_msg_php('BF0073',global_v_lang);
      return;
    end if;


    if trunc(p_dteeffec) < trunc(sysdate) then
      param_msg_error := get_error_msg_php('HR8519',global_v_lang);
      return;
    end if;
    begin
      select count(*) into v_chkexist
        from tobfcft
       where codempid= p_codempid
         and dtestart = p_dteeffec;
    end;
    if v_chkexist = 0 then
      begin
        select count(*) into v_chkDup
          from tobfcft
         where codempid= p_codempid
           and trunc(p_dteeffec) between dtestart and nvl(dteend, trunc(p_dteeffec));
      end;

      if v_chkDup > 0 then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      end if;
    end if;

    for i in 0..param_json.get_size-1 loop
      data_row      := hcm_util.get_json_t(param_json,to_char(i));
      v_codobf      := hcm_util.get_string_t(data_row, 'codobf');
      v_flgselect   := hcm_util.get_string_t(data_row, 'flgselect');



      begin
        select count(*) into v_chkexist
          from tobfinf
         where codempid = p_codempid
           and codobf = v_codobf;
      end;

      if v_flgselect = 'Y' then
        v_chkSel := v_chkSel+1;
        if v_chkexist > 0 then
          param_msg_error := get_error_msg_php('HR2020',global_v_lang);
          exit;
        end if;
      end if;
    end loop;

    if v_chkSel = 0 then
     param_msg_error  := get_label_name('SCRLABEL' ,global_v_lang,1770);
   end if;

  exception when others then
		param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
  end;

  procedure save_data (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    data_row        json_object_t;
    v_response      varchar2(4000 char);
    v_codobf        tobfcde.codobf%type;
    v_codcomp       temploy1.codcomp%type;
    v_flgselect     varchar2(2 char);
    v_tobfcde       tobfcde%rowtype;
    v_qtyalw        tobfcdet.qtyalw%type;
    v_qtytalw       tobfcdet.qtytalw%type;
    v_flglimit      tobfcftd.flglimit%type;
    v_amtvalue      number;
    v_amtalw        number;
    v_chkexist      number;
  begin
    initial_value(json_str_input);
    check_save(param_json);
    if param_msg_error is null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      for i in 0..param_json.get_size-1 loop
        data_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_codobf      := hcm_util.get_string_t(data_row, 'codobf');
        v_flgselect   := hcm_util.get_string_t(data_row, 'flgselect');
        v_flglimit    := hcm_util.get_string_t(data_row, 'flglimit');
        v_qtyalw      := to_number(hcm_util.get_string_t(data_row, 'qtyalw'));
        v_qtytalw     := to_number(hcm_util.get_string_t(data_row, 'qtytalw'));
        v_amtvalue    := to_number(hcm_util.get_string_t(data_row, 'amtvalue'));

        begin
          select *
            into v_tobfcde
            from tobfcde
           where codobf = v_codobf;
        exception when no_data_found then
          null;
        end;
        if v_tobfcde.typebf = 'C' then
          v_amtalw  := v_qtyalw;
        elsif v_tobfcde.typebf = 'T' then
          v_amtalw  := v_qtyalw * v_tobfcde.amtvalue;
        end if;
        if v_flgselect = 'Y' then
          begin
            insert into tobfcftd (codempid,dtestart,codobf,
                                  flglimit,amtvalue,qtyalw,qtytalw,amtalw,
                                  dtecreate,codcreate,coduser
                                  )
                 values (p_codempid, p_dteeffec, v_codobf,
                         v_flglimit, v_tobfcde.amtvalue, v_qtyalw, v_qtytalw, v_amtalw,
                         sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
          begin
            select count(*) into v_chkexist
              from tobfcft
             where codempid = p_codempid
               and dtestart = p_dteeffec;
          end;
          if v_chkexist = 0 then
            begin
              insert into tobfcft (codempid,dtestart,dteend,codcomp,codappr,dteappr,amtalwyr, dtecreate, codcreate, coduser)
              values (p_codempid, p_dteeffec, '', v_codcomp, p_codempid, p_dteeffec,p_limit, sysdate, global_v_coduser, global_v_coduser);
            exception when dup_val_on_index then
              null;
            end;
          else
            begin
              update tobfcft
              set dteend = '',
                  codcomp = v_codcomp,
                  codappr = p_codempid,
                  dteappr = p_dteeffec,
                  amtalwyr = p_limit,
                  dteupd = sysdate,
                  coduser = global_v_coduser
              where codempid = p_codempid
              and dtestart = p_dteeffec;
            exception when dup_val_on_index then
              null;
            end;
          end if;
        elsif v_flgselect = 'N' then
          delete tobfcftd
           where codempid = p_codempid
             and dtestart = p_dteeffec
             and codobf = v_codobf;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      rollback;
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;
end hres72e;

/

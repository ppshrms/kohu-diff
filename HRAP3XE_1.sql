--------------------------------------------------------
--  DDL for Package Body HRAP3XE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3XE" as
    procedure initial_value (json_str in clob) is
      json_obj        json_object_t;
  begin
      v_chken             := hcm_secur.get_v_chken;

      json_obj            := json_object_t(json_str);
      -- global
      global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

      -- index params
      p_dteyreap          := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
      p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
      p_codreq            := hcm_util.get_string_t(json_obj,'p_codreq');
      p_grade             := hcm_util.get_string_t(json_obj,'p_grade');
      p_param_json        := hcm_util.get_json_t(json_obj,'params');

      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
      v_flgsecu		boolean;
      v_numlvl		temploy1.numlvl%type;
      v_staemp        temploy1.staemp%type;
      v_codreq        varchar2(40 char);
  begin
      if p_dteyreap is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
          return;
      end if;

      if p_codcomp is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
          return;
      end if;

      if p_dteyreap <= 0 then
          param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
          return;
      end if;

      b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);

      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
          return;
      end if;
  end;
  procedure check_process is
      v_flgsecu		boolean;
      v_numlvl		temploy1.numlvl%type;
      v_staemp        temploy1.staemp%type;
      v_codreq        varchar2(40 char);
  begin
      if p_dteyreap is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
          return;
      end if;

      if p_codcomp is null  then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
          return;
      end if;

      if p_dteyreap <= 0 then
          param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
          return;
      end if;

      b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);

      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
          return;
      end if;
--      if length(p_codcomp) < 40 then
--          p_codcomp := p_codcomp||'%';
--      end if;

  end;
  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_exist         boolean := false;
    v_numemp        number := 0;
    v_amtbudg       number := 0;
    v_sum_amtbudg       number := 0;
    v_tapbudgt_amtbudg       number := 0;
    v_coduser       tstdis.coduser%type;
    v_dteupd        date;

    cursor c_tstdis  is
      select grade,pctwkstr,pctwkend,pctemp,pctpostr,pctpoend,coduser,dteupd,
             decode(global_v_lang,'101',desgrade
                                 ,'102',desgradt
                                 ,'103',desgrad3
                                 ,'104',desgrad4
                                 ,'105',desgrad5) as desgrad
        from tstdis
       where codcomp = p_codcomp
         and dteyreap = p_dteyreap
      order by grade;

  begin
    obj_row  := json_object_t();
    v_rcnt   := 0;
    for i in c_tstdis loop
        v_rcnt       := v_rcnt+1;
        obj_data     := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('grade', i.grade);
        obj_data.put('desc_grade', i.desgrad);
        obj_data.put('pctwkstr', i.pctwkstr);
        obj_data.put('pctwkend', i.pctwkend);
        obj_data.put('pctpostr', i.pctpostr);
        obj_data.put('pctpoend', i.pctpoend);

        v_numemp := 0;
        begin
            select count(codempid),nvl(sum(stddec(amtbudg,codempid,v_chken)),0) into v_numemp,v_amtbudg
             from tappraism
            where codcomp  like p_codcomp||'%' --= get_compful(p_codcomp)
              and dteyreap = p_dteyreap
              and grade    = i.grade;
        exception when no_data_found then
            begin
                select count(codempid) into v_numemp
                 from tappemp
                where codcomp  = p_codcomp
                  and dteyreap = p_dteyreap
                  and numtime  = (select numtime
                                    from tstdisd
                                   where codcomp  = p_codcomp
                                     and dteyreap = p_dteyreap
                                     and flgsal   in ('Y','A')
--#5552
                                     and exists(select codaplvl
                                                  from tempaplvl
                                                 where dteyreap = p_dteyreap
                                                   and numseq  = tstdisd.numtime
                                                   and codaplvl = tstdisd.codaplvl
                                                   and codempid = tappemp.codempid )
--#5552
                                     )
                  and grdap    = i.grade;
            exception when no_data_found then
                v_numemp := 0;
            end;
        end;
        v_sum_amtbudg := v_sum_amtbudg + v_amtbudg;
        obj_data.put('numemp', v_numemp);
        obj_data.put('amtbudg', v_amtbudg);
        v_coduser := i.coduser;
        v_dteupd  := i.dteupd;
        obj_row.put(to_char(v_rcnt), obj_data);
    end loop;
    begin
      select amtbudg into v_tapbudgt_amtbudg
      from tapbudgt
       where codcomp = p_codcomp
         and dteyreap = p_dteyreap;
    exception when no_data_found then null;
    end;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      if v_rcnt = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TSTDIS');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        obj_result  := json_object_t();
        obj_result.put('coderror', '200');
        obj_result.put('raise_salary',to_char(v_tapbudgt_amtbudg,'fm999,999,990.00'));
        obj_result.put('different',to_char(v_tapbudgt_amtbudg - v_sum_amtbudg,'fm999,999,990.00'));
        obj_result.put('dteappr',to_char(v_dteupd,'dd/mm/yyyy'));
        obj_result.put('codempap',get_codempid(v_coduser));
        obj_result.put('table',obj_row);
        json_str_output := obj_result.to_clob;
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end;

  procedure get_process(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      check_process;
      if param_msg_error is null then
        process_data(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure process_data(json_str_output out clob) as
      obj_row         json_object_t := json_object_t();
      obj_row2        json_object_t := json_object_t();
      obj_data        json_object_t;
      obj_data2       json_object_t;
      param_json_row  json_object_t;
      v_row           number := 0;
      v_flgpass		boolean := true;
      p_codapp        varchar2(100 char) := 'HRAP3XE';
      v_numproc       number := nvl(get_tsetup_value('QTYPARALLEL'),2);
      v_response      varchar2(4000);
      v_countemp      number := 0 ;
      v_data          varchar2(1 char) := 'N';
      v_check         varchar2(1 char) := 'Y';

      v_codpos        varchar2(100 char);
      v_typpayroll    varchar2(100 char);
      v_numlvl        number;
      v_jobgrade      varchar2(100 char);
      v_qtywork       number;
      v_amtbudg       number;

      v_flg	          varchar2(1000 char);
      v_flggrade	    varchar2(100 char);
      v_grade	        tstdis.grade%type;
--<<user25 Date : 29/10/2021 3. AP Module #4417
      v_percst        tstdis.pctpostr%type;
      v_percen        tstdis.pctpoend%type;
       v_percstOld    tstdis.pctpostr%type;
      v_percenOld     tstdis.pctpoend%type;
-->>user25 Date : 29/10/2021 3. AP Module #4417
      cursor c_tstdis  is
          select grade,pctpostr,pctpoend,pctactstr,pctactend
            from tstdis
           where codcomp  = p_codcomp
             and dteyreap = p_dteyreap
             and pctpostr is not null
          order by grade;

  begin
      for i in c_tstdis loop
          v_data := 'Y';
          exit;
      end loop;

      if v_data = 'N' then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSTDIS');
      end if;
      insert_data_parallel (p_codapp,global_v_coduser,v_numproc)  ;

      hrap3xe_batch.start_process('HRAP3XE',global_v_coduser,v_numproc,p_codapp,p_codcomp,p_dteyreap,p_param_json.to_clob)  ;
--      for i in c_tstdis loop

      for i in 0..p_param_json.get_size-1 loop
          param_json_row  := hcm_util.get_json_t(p_param_json,to_char(i));
          v_grade         := hcm_util.get_string_t(param_json_row,'grade');

 --<<user25 Date : 29/10/2021 3. AP Module #4417
         v_percst         := hcm_util.get_string_t(param_json_row,'percst');
         v_percen         := hcm_util.get_string_t(param_json_row,'percen');
         v_percstOld      := hcm_util.get_string_t(param_json_row,'percstOld');
         v_percenOld      := hcm_util.get_string_t(param_json_row,'percenOld');
          begin
             update tstdis
             set pctpostr = v_percst,
                 pctpoend = v_percen,
                 coduser  = global_v_coduser
           where codcomp  = p_codcomp
             and dteyreap = p_dteyreap
             and grade = v_grade;
          exception when  others then
            null;
          end;
 -->>user25 Date : 29/10/2021 3. AP Module #4417

          v_row   := v_row + 1;
          obj_data2 := json_object_t();
          obj_data2.put('coderror','200');
          v_countemp := 0;
          begin
              select count(codempid),sum(stddec(amtbudg,codempid,v_chken)) into v_countemp,v_amtbudg
                from tappraism
               where dteyreap = p_dteyreap
                 and codcomp  = p_codcomp
                 and grade    = v_grade;
--                 and grade    = i.grade;
          exception when no_data_found then
              v_countemp := 0;
          end;
          obj_data2.put('numemp', v_countemp);
          obj_data2.put('amtbudg', v_amtbudg);
          obj_row2.put(to_char(v_row - 1), obj_data2);
      end loop;

      if param_msg_error is null then
          obj_row := json_object_t();
          obj_data := json_object_t();
          param_msg_error := get_error_msg_php('HR2715',global_v_lang);
          v_response        := get_response_message(null,param_msg_error,global_v_lang);
          obj_row.put('coderror', '200');
          obj_row.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
          obj_data.put('table', obj_row2);
          json_str_output := obj_row.to_clob;
      else
        rollback;
        json_str_output := get_response_message(400,param_msg_error,global_v_lang);
      end if;
  exception when others then
      rollback;
      param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;


  procedure  insert_data_parallel (p_codapp  in varchar2,
                                   p_coduser in varchar2,
                                   p_proc    in out number)  as
      v_num       number ;
      v_proc      number := p_proc ;
      v_numproc   number := 0;
      v_rec       number ;
      v_flgsecu   boolean := false;
      v_secur     boolean := false;
      v_flgfound  boolean := false;
      v_chk_emp   boolean := false;
      v_zupdsal   varchar2(1);
      v_numtime   number;
      v_grade     varchar2(2 char);

      cursor c_tstdis  is
          select grade,pctwkstr,pctwkend,pctemp,pctpostr,pctpoend
            from tstdis
           where codcomp  = p_codcomp
             and dteyreap = p_dteyreap
          order by grade;

      cursor c_tappemp is
          select distinct codempid,codcomp,numlvl
            from tappemp a
           where dteyreap = p_dteyreap
             and codcomp  like p_codcomp||'%'
             and flgsal  = 'Y'
             --and grdap   = v_grade
             and exists  (select codaplvl from tstdisd b
                           where a.codcomp   like b.codcomp||'%'
                             and b.dteyreap  = a.dteyreap
                             and b.numtime   = a.numtime
                             and b.flgsal    = 'Y'
--#5552
                             and exists(select codaplvl
                                          from tempaplvl
                                         where dteyreap = b.dteyreap
                                           and numseq  = b.numtime
                                           and codaplvl = b.codaplvl
                                           and codempid = a.codempid )
--#5552
             )
          order by codempid;

  begin
      delete tprocemp where codapp = p_codapp and coduser = p_coduser;
      commit ;

      begin
          select numtime into v_numtime
            from tstdisd
           where codcomp  = p_codcomp
             and dteyreap = p_dteyreap
             and flgsal   = 'Y'
--#5552
             and exists(select codaplvl
                          from tempaplvl
                         where dteyreap = tstdisd.dteyreap
                           and numseq  = tstdisd.numtime
                           and codaplvl = tstdisd.codaplvl)
--#5552
             and rownum   = 1;
      exception when no_data_found then
          v_numtime := 1;
      end;

      for r_tstdis in c_tstdis loop
          v_grade   := r_tstdis.grade;
          v_chk_emp := false;
          for i in c_tappemp loop
              v_chk_emp  := true;
              v_flgfound := true;
              v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
              if v_flgsecu then
                  v_secur   := true;
                  begin
                      insert into tprocemp (codapp,coduser,numproc,codempid)
                             values        (p_codapp,p_coduser,v_numproc + 1,i.codempid);
                  exception when  dup_val_on_index then
                    null;
                  end;
              end if;
          end loop;
          if v_chk_emp then
            v_numproc := v_numproc + 1;
          end if;
      end loop;

      if not v_flgfound then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
      else
        if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
      end if;

      p_proc := v_numproc;
      commit;
   exception when others then
      param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_data_parallel;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row		        number := 0;
    v_amtpay        number := 0;
    v_jobgrade      temploy1.jobgrade%type;
    v_amtsaln       number := 0;
    v_amtceiling    number := 0;
    v_amtminsal     number := 0;
    v_overmax       number;
    v_belowmin      number;
    v_desc_grade      tstdis.desgradt%type;

    cursor c_tappraism is
      select grade,codempid,amtsalo,amtmidsal,pctsal,amtbudg,amtsaln,amtceiling,amtminsal,amtover
        from tappraism
       where codcomp  like p_codcomp||'%'
         and dteyreap = p_dteyreap
         and grade    = nvl(p_grade,grade)
      order by grade,codempid;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tappraism loop
        v_row      := v_row + 1;
        obj_data := json_object_t();
        begin
           select decode(global_v_lang,'101',desgrade
                                       ,'102',desgradt
                                       ,'103',desgrad3
                                       ,'104',desgrad4
                                       ,'105',desgrad5) as desgrad
            into v_desc_grade
            from tstdis
           where codcomp = p_codcomp
             and dteyreap = p_dteyreap
             and grade = i.grade;
        exception when no_data_found then
          null;
        end;
        obj_data.put('coderror', '200');
        obj_data.put('grade', i.grade);
        obj_data.put('desc_grade', v_desc_grade);
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
--        obj_data.put('amtsalo', i.amtsalo);
        obj_data.put('amtsalo', stddec(i.amtsalo,i.codempid,v_chken));
        begin
            select jobgrade into v_jobgrade
              from temploy1
             where codempid = i.codempid;
        exception when no_data_found then
             v_jobgrade := null;
        end;
        obj_data.put('desc_jobgrade', get_tcodec_name('TCODJOBG',v_jobgrade,global_v_lang));
--        obj_data.put('amtmidsal', i.amtmidsal);
        obj_data.put('amtmidsal', stddec(i.amtmidsal,i.codempid,v_chken));
        obj_data.put('pctsal', i.pctsal);
        obj_data.put('amtbudg', stddec(i.amtbudg,i.codempid,v_chken));
        obj_data.put('amtsaln', stddec(i.amtsaln,i.codempid,v_chken));
        v_amtsaln       := (stddec(i.amtsaln,i.codempid,v_chken));
        v_amtceiling    := (stddec(i.amtceiling,i.codempid,v_chken));
        v_amtminsal     := (stddec(i.amtminsal,i.codempid,v_chken));
        v_overmax  := 0;
        v_belowmin := 0;
--        if v_amtsaln > v_amtceiling then
--            v_overmax := v_amtsaln - v_amtceiling; --ex  max50000 sal52000 >> 2000
--        end if;
        v_overmax := (stddec(i.amtover,i.codempid,v_chken));
        obj_data.put('overmax', v_overmax);

        if v_amtsaln < v_amtminsal then
            v_belowmin := v_amtminsal- v_amtsaln;--ex  min 30000 sal2900 >> 1000
        end if;
        obj_data.put('belowmin', v_belowmin);

        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

end hrap3xe;

/

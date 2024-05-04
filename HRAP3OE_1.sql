--------------------------------------------------------
--  DDL for Package Body HRAP3OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3OE" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index

    p_dteyreap            := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime             := hcm_util.get_string_t(json_obj,'p_numtime');
    p_codcomp             := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid            := hcm_util.get_string_t(json_obj,'p_codempid');
    p_codaplvl            := hcm_util.get_string_t(json_obj,'p_codaplvl');
    p_dteyreapQuery       := hcm_util.get_string_t(json_obj,'p_dteyreapQuery');
    p_numtimeQuery        := hcm_util.get_string_t(json_obj,'p_numtimeQuery');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --Redmine #5552
  function get_codaplvl(p_dteyreap in number,
                        p_numseq   in number,
                        p_codempid in varchar2) return varchar2 is
    l_num   number;
    v_codaplvl      tstdisd.codaplvl%type;
  begin
      begin
           select codaplvl into v_codaplvl
            from tempaplvl
           where dteyreap = p_dteyreap
             and numseq  = p_numseq
             and codempid = p_codempid;
      exception when others then
        v_codaplvl := null;
      end;

    return v_codaplvl;
  exception when value_error then return Null;
  end;
  --Redmine #5552
  --
  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
		obj_respone		  json_object_t;
		obj_respone_data  varchar2(1000 char);

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;
    v_codcomp       tcenter.codcomp%type;
    v_flgtypap      tstdisd.flgtypap%type;
    v_dteapstr      tstdisd.dteapstr%type;
    v_codaplvl          tstdisd.codaplvl%type;

    cursor c1 is
      select numseq,flgappr,codcompap,codpospap,codempap,flgdisp
        from tappasgn
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codcomp = nvl(p_codcomp,'%')
         and codaplvl = nvl(p_codaplvl,'%')
         and codempid = nvl(p_codempid,'%')
      order by numseq;

    cursor c_tstdisd is
      select flgtypap
        from tstdisd
       where nvl(p_codcomp,v_codcomp) like codcomp||'%'
         and dteyreap = p_dteyreap
         and numtime = p_numtime
       order by codcomp desc;
  begin
    if p_dteyreapQuery is not null and p_numtimeQuery is not null then
      p_isCopy  :=  'Y';
      v_flgAdd  := true;
    end if;
    if p_codempid is not null then
      begin
        select codcomp into v_codcomp
        from temploy1
        where codempid = p_codempid;
        exception when no_data_found then v_codcomp := null; --<< user25 Date : 17/11/2021 #7184
      end;

--Redmine #5552
      v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, p_codempid);
--Redmine #5552

    end if;

    begin
      select flgtypap, dteapstr into v_flgtypap, v_dteapstr
        from tstdisd
       where nvl(p_codcomp,v_codcomp) like codcomp||'%'
         and codaplvl = nvl(p_codaplvl,codaplvl)
         and dteyreap = p_dteyreap
         and numtime = p_numtime
--Redmine #5552
         and codaplvl = nvl(v_codaplvl, codaplvl)
         and rownum = 1
--Redmine #5552
       order by codcomp desc;
    exception when no_data_found then
      null;
    end;
    if trunc(sysdate) > v_dteapstr  then
      p_isEdit  :=  'N';
      v_response          := get_error_msg_php('HR1501', global_v_lang);
      json_str_output     := get_response_message(NULL, v_response, global_v_lang);
      obj_respone         := json_object_t(json_str_output);
      obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
    end if;
    obj_row := json_object_t();
    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', r1.numseq);
      obj_data.put('flgappr', r1.flgappr);
      obj_data.put('desc_flgappr', get_tlistval_name('TYPWKFLOW', r1.flgappr, global_v_lang));
      obj_data.put('codcompap', r1.codcompap);
      obj_data.put('desc_codcompap', r1.codcompap || '-' || get_tcenter_name(r1.codcompap, global_v_lang));
      obj_data.put('codposap', r1.codpospap);
      obj_data.put('desc_codposap', r1.codpospap || '-' || get_tpostn_name(r1.codpospap, global_v_lang));
      obj_data.put('codempap', r1.codempap);
      obj_data.put('desc_codempap', r1.codempap || '-' || get_temploy_name(r1.codempap, global_v_lang));
      obj_data.put('flgdisp', r1.flgdisp);
      obj_data.put('desc_flgdisp', get_tlistval_name('FLGDISP', r1.flgdisp, global_v_lang));
      obj_data.put('flgAdd', v_flgAdd);
      obj_data.put('flgtypap', v_flgtypap);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_result := json_object_t();
    obj_result.put('coderror', '200');
    obj_result.put('isCopy', p_isCopy);
    obj_result.put('isEdit', p_isEdit);
    obj_result.put('response', obj_respone_data);
    obj_result.put('flgtypap', v_flgtypap);
    obj_result.put('desc_flgtypap', get_tlistval_name('FLGTYPAP', v_flgtypap, global_v_lang));
    obj_result.put('table', obj_row);

    json_str_output := obj_result.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
    v_codcomp   tcenter.codcomp%type;
    v_staemp    temploy1.staemp%type;
    v_flgSecur  boolean;
    v_count     number := 0;
    v_codaplvl  varchar2(100 char);
    v_flgExsit  varchar2(2 char);
  begin
    if p_dteyreap is null or p_numtime is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    if p_codcomp is not null and p_codaplvl is not null then
      begin
        select codcomp into v_codcomp
          from tcenter
         where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
      begin
        select codcodec into v_codaplvl
          from tcodaplv
         where codcodec = p_codaplvl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODAPLV');
        return;
      end;
      begin
        select count(*) into v_count
          from taplvl a
         where a.codaplvl = p_codaplvl
           and a.codcomp  = p_codcomp
           and a.dteeffec = (select max(b.dteeffec)
                               from taplvl b
                              where b.codaplvl = a.codaplvl
                                and b.codcomp  = a.codcomp
                                and b.dteeffec <= trunc(sysdate));
      end;
      if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TAPLVL');
        return;
      end if;
    elsif p_codempid is not null then
      begin
        select staemp into v_staemp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flgSecur := secur_main.secur2(p_codempid, global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if not v_flgSecur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_copy_list(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    cursor c1 is
      select dteyreap,numtime,codcomp,codaplvl
        from tappasgn
       where codcomp <> '%' --User37 #4166 04/10/2021
       group by dteyreap,numtime,codcomp,codaplvl
       order by dteyreap desc ,numtime desc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteyreap', i.dteyreap);
      obj_data.put('numtime', i.numtime);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('desc_codcomp', i.codcomp || '-' || get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('codaplvl', i.codaplvl);
      obj_data.put('desc_codaplvl', i.codaplvl || '-' || get_tcodec_name('TCODAPLV', i.codaplvl, global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_copy_list(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_copy_list(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_save(json_str_input in clob) is
    v_codcomp         tcenter.codcomp%type;
    v_codpos          tpostn.codpos%type;
    v_staemp          temploy1.staemp%type;
    param_json        json_object_t;
    param_json_row    json_object_t;
    obj_detail        json_object_t;
    obj_table1        json_object_t;

    v_numseq      tappasgn.numseq%type;
    v_flgappr     tappasgn.flgappr%type;
    v_codcompap   tappasgn.codcompap%type;
    v_codposap    tappasgn.codpospap%type;
    v_codempap    tappasgn.codempap%type;
    v_flgdisp     tappasgn.flgdisp%type;
    v_flgdispOld  tappasgn.flgdisp%type;

    v_flg	        varchar2(1000 char);
    v_isCopy      varchar2(2 char);
    v_cnt_flgdisp1   number := 0;
    v_cnt_flgdisp2   number := 0;
  begin
    obj_detail    := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    obj_table1    := hcm_util.get_json_t(json_object_t(json_str_input),'params');

    p_dteyreap    := hcm_util.get_string_t(obj_detail,'dteyear');
    p_numtime     := hcm_util.get_string_t(obj_detail,'numtime');
    p_codcomp     := nvl(hcm_util.get_string_t(obj_detail,'codcomp'),'%');
    p_codempid    := nvl(hcm_util.get_string_t(obj_detail,'codempid'),'%');
    p_codaplvl    := nvl(hcm_util.get_string_t(obj_detail,'codaplvl'),'%');
    v_isCopy      := hcm_util.get_string_t(obj_detail,'isCopy');

    for i in 0..obj_table1.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(obj_table1,to_char(i));
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_flgappr       := hcm_util.get_string_t(param_json_row,'flgappr');
      v_codcompap     := hcm_util.get_string_t(param_json_row,'codcompap');
      v_codposap      := hcm_util.get_string_t(param_json_row,'codposap');
      v_codempap      := hcm_util.get_string_t(param_json_row,'codempap');
      v_flgdisp       := hcm_util.get_string_t(param_json_row,'flgdisp');
      v_flgdispOld    := hcm_util.get_string_t(param_json_row,'flgdispOld');
      if v_flg <> 'delete' and v_isCopy <> 'Y' then
        if v_codcompap is not null then
          begin
            select codcomp into v_codcomp
              from tcenter
             where codcomp = get_compful(v_codcompap);
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
            exit;
          end;
        end if;
        if v_codposap is not null then
          begin
            select codpos into v_codpos
              from tpostn
             where codpos = v_codposap;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPOSTN');
            exit;
          end;
        end if;
        if v_codempap is not null then
          begin
            select staemp into v_staemp
            from temploy1
            where codempid = v_codempap;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            exit;
          end;
          if v_staemp = '9' then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            exit;
          end if;
        end if;
--        if v_flgdisp = '1' and v_flgdisp <> v_flgdispOld then
--          v_cnt_flgdisp1 := v_cnt_flgdisp1 + 1;
--          begin
--            select count(*) + 1 into v_cnt_flgdisp1
--            from tappasgn
--             where dteyreap = p_dteyreap
--               and numtime = p_numtime
--               and codcomp = nvl(p_codcomp,'%')
--               and codaplvl = nvl(p_codaplvl,'%')
--               and codempid = nvl(p_codempid,'%')
--               and flgdisp = v_flgdisp;
--          end;
--        elsif v_flgdisp = '3' and v_flgdisp <> v_flgdispOld then
--          v_cnt_flgdisp2  := v_cnt_flgdisp2 + 1;
--          begin
--            select count(*) + 1 into v_cnt_flgdisp2
--            from tappasgn
--             where dteyreap = p_dteyreap
--               and numtime = p_numtime
--               and codcomp = nvl(p_codcomp,'%')
--               and codaplvl = nvl(p_codaplvl,'%')
--               and codempid = nvl(p_codempid,'%')
--               and flgdisp = v_flgdisp;
--          end;
--        end if;

--        if v_cnt_flgdisp1 > 1 then
--          param_msg_error := get_error_msg_php('AP0049', global_v_lang);
--          exit;
--        end if;
--        if v_cnt_flgdisp2 > 1 then
--          param_msg_error := get_error_msg_php('AP0050', global_v_lang);
--          exit;
--        end if;
      end if;
    end loop;
  end;
  --
  procedure post_save(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_save(json_str_input);
    if param_msg_error is null then
      save_data(json_str_input);
      if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        rollback;
        return;
      end if;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_data (json_str_input in clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    obj_detail    json_object_t;
    obj_stmt      json_object_t;
    obj_form1     json_object_t;
    obj_form2     json_object_t;
    obj_table1    json_object_t;
    obj_table2    json_object_t;

    v_numseq      tappasgn.numseq%type;
    v_flgappr     tappasgn.flgappr%type;
    v_codcompap   tappasgn.codcompap%type;
    v_codposap    tappasgn.codpospap%type;
    v_codempap    tappasgn.codempap%type;
    v_flgtypap    tstdisd.flgtypap%type;
    v_flgdisp     tappasgn.flgdisp%type;

    v_flg	        varchar2(1000 char);
    v_isCopy      varchar2(2 char);
    v_isEdit      varchar2(2 char);
    v_flgappr_last  tappasgn.flgappr%type;
    v_cnt_flgdisp1  number;
    v_cnt_flgdisp2  number;

    cursor c1 is
        select flgappr
          from tappasgn
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomp = nvl(p_codcomp,'%')
           and codaplvl = nvl(p_codaplvl,'%')
           and codempid = nvl(p_codempid,'%')
      order by numseq;

  begin
    obj_detail    := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    obj_table1    := hcm_util.get_json_t(json_object_t(json_str_input),'params');

    p_dteyreap    := hcm_util.get_string_t(obj_detail,'dteyear');
    p_numtime     := hcm_util.get_string_t(obj_detail,'numtime');
    p_codcomp     := nvl(hcm_util.get_string_t(obj_detail,'codcomp'),'%');
    p_codempid    := nvl(hcm_util.get_string_t(obj_detail,'codempid'),'%');
    p_codaplvl    := nvl(hcm_util.get_string_t(obj_detail,'codaplvl'),'%');
    v_flgtypap    := hcm_util.get_string_t(obj_detail,'flgtypap');
    v_isCopy      := hcm_util.get_string_t(obj_detail,'isCopy');
    v_isEdit      := hcm_util.get_string_t(obj_detail,'isEdit');

    if param_msg_error is null then
      if v_isCopy = 'Y' then
        begin
          delete tappasgn
           where dteyreap = p_dteyreap
             and numtime = p_numtime
             and codcomp = nvl(p_codcomp,'%')
             and codaplvl = nvl(p_codaplvl,'%')
             and codempid = nvl(p_codempid,'%');
        end;
      end if;

      for i in 0..obj_table1.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(obj_table1,to_char(i));
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_flg           := hcm_util.get_string_t(param_json_row,'flg');
        v_flgappr       := hcm_util.get_string_t(param_json_row,'flgappr');
        v_codcompap     := hcm_util.get_string_t(param_json_row,'codcompap');
        v_codposap      := hcm_util.get_string_t(param_json_row,'codposap');
        v_codempap      := hcm_util.get_string_t(param_json_row,'codempap');
        v_flgdisp       := hcm_util.get_string_t(param_json_row,'flgdisp');
        if v_flg = 'add' then
          if v_numseq is null then
            select nvl(max(numseq),0) + 1 into v_numseq
              from tappasgn
             where dteyreap = p_dteyreap
               and numtime = p_numtime
               and codcomp = nvl(p_codcomp,'%')
               and codaplvl = nvl(p_codaplvl,'%')
               and codempid = nvl(p_codempid,'%');
          end if;
          begin
              insert into tappasgn(dteyreap,numtime,codcomp,codempid,codaplvl,numseq,
                                   flgappr,codcompap,codpospap,codempap,flgdisp,
                                   codcreate,coduser)
              values (p_dteyreap, p_numtime, p_codcomp, p_codempid, p_codaplvl, v_numseq,
                      v_flgappr, v_codcompap, v_codposap, v_codempap, v_flgdisp,
                      global_v_coduser, global_v_coduser);
            end;
        elsif v_flg = 'edit' then
            begin
              update tappasgn
                 set flgappr	=	v_flgappr,
                     codcompap	=	v_codcompap,
                     codpospap	=	v_codposap,
                     codempap	=	v_codempap,
                     flgdisp	=	v_flgdisp,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where dteyreap = p_dteyreap
                 and numtime = p_numtime
                 and codcomp = nvl(p_codcomp,'%')
                 and codaplvl = nvl(p_codaplvl,'%')
                 and codempid = nvl(p_codempid,'%')
                 and numseq = v_numseq;
            end;
        elsif v_flg = 'delete' then
            begin
              delete tappasgn
               where dteyreap = p_dteyreap
                 and numtime = p_numtime
                 and codcomp = nvl(p_codcomp,'%')
                 and codaplvl = nvl(p_codaplvl,'%')
                 and codempid = nvl(p_codempid,'%')
                 and numseq = v_numseq;
            end;
        end if;
      end loop;

      v_flgappr_last := '9';
      for r1 in c1 loop
--        if r1.flgappr = '5' and v_flgappr_last <> '1' then
--            param_msg_error := get_error_msg_php('AP0069',global_v_lang);
--            exit;
--        end if;
        if r1.flgappr = '5' and v_flgappr_last not in ('1','5') and v_flgtypap = 'T'
        then
          param_msg_error := get_error_msg_php('AP0052',global_v_lang);
          exit;
        end if;
        v_flgappr_last   := r1.flgappr;
      end loop;
      begin
        select count(*) into v_cnt_flgdisp1
          from tappasgn
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomp = nvl(p_codcomp,'%')
           and codaplvl = nvl(p_codaplvl,'%')
           and codempid = nvl(p_codempid,'%')
           and flgdisp = 1;
      end;
      if v_cnt_flgdisp1 > 1 then
        param_msg_error := get_error_msg_php('AP0049', global_v_lang);
        return;
      end if;
      begin
        select count(*) into v_cnt_flgdisp2
        from tappasgn
         where dteyreap = p_dteyreap
           and numtime = p_numtime
           and codcomp = nvl(p_codcomp,'%')
           and codaplvl = nvl(p_codaplvl,'%')
           and codempid = nvl(p_codempid,'%')
           and flgdisp = 3;
      end;
      if v_cnt_flgdisp2 > 1 then
        param_msg_error := get_error_msg_php('AP0050', global_v_lang);
      end if;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure post_process (json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
    obj_detail    json_object_t;
    obj_stmt      json_object_t;
    obj_form1     json_object_t;
    obj_form2     json_object_t;
    obj_table1    json_object_t;
    obj_table2    json_object_t;

    v_numseq      tappasgn.numseq%type;
    v_flgappr     tappasgn.flgappr%type;
    v_codcompap   tappasgn.codcompap%type;
    v_codposap    tappasgn.codpospap%type;
    v_codempap    tappasgn.codempap%type;
    v_flgdisp     tappasgn.flgdisp%type;
    v_flgtypap    tstdisd.flgtypap%type;
    v_dteapstr    tstdisd.dteapstr%type;
    v_dteapend    tstdisd.dteapend%type;

    v_flg	        varchar2(1000 char);
    v_isCopy      varchar2(2 char);
    v_isEdit      varchar2(2 char);
    v_isExist     varchar2(2 char) := 'N';

    v_tmp_codcomph  temphead.codcomph%type := '';
    v_tmp_codposh   temphead.codposh%type := '';
    v_tmp_codempidh temphead.codempidh%type := '';
    v_tmp_stapost   tsecpos.stapost2%type := '';

    tappfm_codapman	tappfm.codapman%type;
    tappfm_codpos	  tappfm.codpos%type;
    tappfm_codcomp	tappfm.codcomp%type;

    temploy1_codpos	  temploy1.codpos%type;
    temploy1_codcomp	temploy1.codcomp%type;
    taplvl_codcomp    taplvl.codcomp%type := '';
    taplvl_codaplvl   taplvl.codaplvl%type  := '';
    v_codaplvl          tstdisd.codaplvl%type;
    v_flgpass         boolean := false;

    cursor c1 is
      select a.codempid,a.codcomp,a.codpos,a.numseq, a.codaplvl
        from tempaplvl a
       where a.dteyreap = p_dteyreap
         and a.numseq = p_numtime
         and a.codcomlvl = nvl(p_codcomp,a.codcomlvl)
         and a.codaplvl = nvl(p_codaplvl,a.codaplvl)
         and a.codempid = nvl(p_codempid,a.codempid)
       order by codempid;

    cursor c2 is
      select numseq,flgappr,codcompap,codpospap,codempap,flgdisp
        from tappasgn
       where dteyreap = p_dteyreap
         and numtime = p_numtime
         and codcomp = nvl(p_codcomp,codcomp)
         and codaplvl = nvl(p_codaplvl,codaplvl)
         and codempid = nvl(p_codempid,codempid)
         /*
         and nvl(p_codcomp,codcomp) like codcomp
         and nvl(p_codaplvl,codaplvl) like codaplvl
         and nvl(p_codempid,codempid) like codempid
         */
       order by numseq;

    cursor c3 is
      select a.codempid, a.codcomp, a.codpos
        from temploy1 a
       where a.codcomp like p_codcomp||'%'
         and a.codempid = nvl(p_codempid, a.codempid)
         and a.staemp <> '9'
       order by codempid;

  begin
    initial_value(json_str_input);
    check_save(json_str_input);

    -- first phase , save data before process
    save_data(json_str_input);
    --
    obj_detail    := hcm_util.get_json_t(json_object_t(json_str_input),'detail');
    obj_table1    := hcm_util.get_json_t(json_object_t(json_str_input),'params');

    p_dteyreap    := hcm_util.get_string_t(obj_detail,'dteyear');
    p_numtime     := hcm_util.get_string_t(obj_detail,'numtime');
    p_codcomp     := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codempid    := hcm_util.get_string_t(obj_detail,'codempid');
    p_codaplvl    := hcm_util.get_string_t(obj_detail,'codaplvl');
    v_flgtypap    := hcm_util.get_string_t(obj_detail,'flgtypap');
    v_isCopy      := hcm_util.get_string_t(obj_detail,'isCopy');
    v_isEdit      := hcm_util.get_string_t(obj_detail,'isEdit');

    -- second phase, process data
    if param_msg_error is null then
      for r1 in c1 loop
        v_isExist := 'Y';
        exit;
      end loop;
      begin
        delete tappfm
         where numtime = p_numtime
           and dteyreap = p_dteyreap
           and codempid = nvl(p_codempid, codempid)
           and codcomp like nvl(p_codcomp||'%', codcomp)
           and codaplvl = nvl(p_codaplvl,codaplvl)
           and flgappr is null;
      end;

      if v_isExist = 'Y' then
            for r1 in c1 loop
                p_codempid_query := r1.codempid;
                for r2 in c2 loop
                        if r2.flgappr = '1' then
                              get_head( r1.codcomp , r1.codpos , v_tmp_codcomph, v_tmp_codposh, v_tmp_codempidh, v_tmp_stapost);
                              tappfm_codapman :=  v_tmp_codempidh;
                              tappfm_codpos   :=  v_tmp_codposh;
                              tappfm_codcomp  :=  v_tmp_codcomph;
                              p_codempid_query := v_tmp_codempidh; --#7186||USER39||15/12/2021
                        elsif r2.flgappr = '2' then
                              tappfm_codapman :=  '';
                              tappfm_codpos   :=  r2.codpospap;
                              tappfm_codcomp  :=  r2.codcompap;
                        elsif r2.flgappr = '3' then
                              tappfm_codapman :=  r2.codempap;
                              tappfm_codpos   :=  '';
                              tappfm_codcomp  :=  '';
                              if tappfm_codapman is not null then
                                begin
                                  select codcomp, codpos into tappfm_codcomp, tappfm_codpos
                                    from temploy1
                                   where codempid = tappfm_codapman;
                                   exception when no_data_found then tappfm_codcomp := null; tappfm_codpos := null;--<< user25 Date : 17/11/2021 #7184
                                end;
                              end if;
                        elsif r2.flgappr = '4' then
                              tappfm_codapman :=  r1.codempid;
                              tappfm_codpos   :=  '';
                              tappfm_codcomp  :=  '';
                              if tappfm_codapman is not null then
                                begin
                                  select codcomp, codpos into tappfm_codcomp, tappfm_codpos
                                    from temploy1
                                   where codempid = tappfm_codapman;
                                   exception when no_data_found then tappfm_codcomp := null; tappfm_codpos := null; --<< user25 Date : 17/11/2021 #7184
                                end;
                              end if;
                        elsif r2.flgappr = '5' then
                              begin
                                select codposap, codcompap into  v_codposap, v_codcompap
                                from tappfm
                                where codempid = r1.codempid
                                and dteyreap = p_dteyreap
                                and numtime = p_numtime
                                and numseq = r2.numseq - 1;
                              exception when no_data_found then
                                v_codposap  := ''; v_codcompap  := '';
                              end;
                              get_head( v_codcompap , v_codposap , v_tmp_codcomph, v_tmp_codposh, v_tmp_codempidh, v_tmp_stapost);
                              tappfm_codapman :=  v_tmp_codempidh;
                              tappfm_codpos   :=  v_tmp_codposh;
                              tappfm_codcomp  :=  v_tmp_codcomph;
                              p_codempid_query := v_tmp_codempidh;
                        end if;
                        ---
                        /* insert */
                        begin
                          select codcomp, codpos into temploy1_codcomp, temploy1_codpos
                            from temploy1
                           where codempid = r1.codempid;
                           exception when no_data_found then  temploy1_codcomp := null; temploy1_codpos:= null; --<< user25 Date : 17/11/2021 #7184
                        end;

                        begin
            --Redmine #5552
                          v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, r1.codempid);
            --Redmine #5552

                          select dteapstr, dteapend into v_dteapstr, v_dteapend
                            from tstdisd
                           where nvl(p_codcomp,temploy1_codcomp) like codcomp||'%'
                             and codaplvl = p_codaplvl
                             and dteyreap = p_dteyreap
                             and numtime = p_numtime
            --Redmine #5552
                             and codaplvl = nvl(v_codaplvl, codaplvl)
                             and rownum = 1
            --Redmine #5552
                           order by codcomp desc;
                        exception when no_data_found then
                          null;
                        end;

                        begin
                          insert into tappfm (codempid,dteyreap,numtime,numseq,
                                              codapman,codposap,codcompap,codcomp,codpos,codaplvl,
                                              flgtypap,dteapstr,dteapend,flgappr,flgapman,
                                              codcreate,coduser)
                          values (r1.codempid, p_dteyreap, p_numtime, r2.numseq,
                                  tappfm_codapman, tappfm_codpos, tappfm_codcomp, temploy1_codcomp, temploy1_codpos, r1.codaplvl,
                                  v_flgtypap, v_dteapstr, v_dteapend, '', r2.flgdisp,
                                  global_v_coduser, global_v_coduser);
                        exception when dup_val_on_index then
                            begin
                              update tappfm
                                 set codapman = tappfm_codapman,
                                     codposap = tappfm_codpos,
                                     codcompap = tappfm_codcomp,
                                     codcomp  =  temploy1_codcomp,
                                     codpos   = temploy1_codpos,
                                     codaplvl = r1.codaplvl,
                                     flgtypap = v_flgtypap,
                                     dteapstr = v_dteapstr,
                                     dteapend = v_dteapend,
                                     flgappr  =  '',
                                     flgapman = r2.flgdisp,
                                     codcreate = global_v_coduser,
                                     coduser   = global_v_coduser
                               where codempid = r1.codempid
                                 and dteyreap = p_dteyreap
                                 and numtime  = p_numtime
                                 and numseq = r2.numseq;
                            end;
                        end;
                    ---
                end loop;
            end loop;

      elsif v_isExist = 'N' then

            for r3 in c3 loop
                  get_conap(r3.codcomp, r3.codpos, r3.codempid, taplvl_codcomp, taplvl_codaplvl, v_flgpass);--joy
                  if v_flgpass then
                    begin

                      insert into tempaplvl (DTEYREAP, NUMSEQ, CODEMPID,
                      CODAPLVL, CODCOMLVL, CODCOMP, CODPOS, CODCREATE, CODUSER)
                        values (p_dteyreap, p_numtime, r3.codempid,
                        taplvl_codaplvl, taplvl_codcomp, r3.codcomp, r3.codpos,
                        global_v_coduser, global_v_coduser);
                  --<< user20 Date: 01/09/2021  AP Module- #3582
                    exception when dup_val_on_index then
                      begin
                        update tempaplvl
                           set codaplvl = taplvl_codaplvl,
                               codcomlvl = taplvl_codcomp,
                               codcomp = r3.codcomp,
                               codpos = r3.codpos,
                               codcreate = global_v_coduser,
                               coduser    = global_v_coduser
                         where dteyreap = p_dteyreap
                           and numseq = p_numtime
                           and codempid = r3.codempid;
                      end;
                  --<< user20 Date: 01/09/2021  AP Module- #3582
                    end;
                  end if;
            end loop;

            for r1 in c1 loop
                p_codempid_query := r1.codempid;
                for r2 in c2 loop
            begin
              delete tappfm
               where codempid = r1.codempid
                 and numseq = r2.numseq
                 and numtime = p_numtime
                 and dteyreap = p_dteyreap
                 and flgappr is null;
            end;

            if r2.flgappr = '1' then
              get_head( r1.codcomp , r1.codpos , v_tmp_codcomph, v_tmp_codposh, v_tmp_codempidh, v_tmp_stapost);
              tappfm_codapman :=  v_tmp_codempidh;
              tappfm_codpos   :=  v_tmp_codposh;
              tappfm_codcomp  :=  v_tmp_codcomph;
            elsif r2.flgappr = '2' then
              tappfm_codapman :=  '';
              tappfm_codpos   :=  r2.codpospap;
              tappfm_codcomp  :=  r2.codcompap;
            elsif r2.flgappr = '3' then
              tappfm_codapman :=  r2.codempap;
              tappfm_codpos   :=  '';
              tappfm_codcomp  :=  '';
              if tappfm_codapman is not null then
                begin
                  select codcomp, codpos into tappfm_codcomp, tappfm_codpos
                    from temploy1
                   where codempid = tappfm_codapman;
                   exception when no_data_found then tappfm_codcomp := null; tappfm_codpos := null; --<< user25 Date : 17/11/2021 #7184
                end;
              end if;
            elsif r2.flgappr = '4' then
              tappfm_codapman :=  r1.codempid;
              tappfm_codpos   :=  '';
              tappfm_codcomp  :=  '';
              if tappfm_codapman is not null then
                begin
                  select codcomp, codpos into tappfm_codcomp, tappfm_codpos
                    from temploy1
                   where codempid = tappfm_codapman;
                   exception when no_data_found then tappfm_codcomp := null; tappfm_codpos := null;--<< user25 Date : 17/11/2021 #7184
                end;
              end if;
            elsif r2.flgappr = '5' then
              begin
                select codposap, codcompap into  v_codposap, v_codcompap
                from tappfm
                where codempid = r1.codempid
                and dteyreap = p_dteyreap
                and numtime = p_numtime
                and numseq = r2.numseq - 1;
              exception when no_data_found then
                v_codposap  := ''; v_codcompap  := '';
              end;
              get_head( v_codcompap , v_codposap , v_tmp_codcomph, v_tmp_codposh, v_tmp_codempidh, v_tmp_stapost);
              tappfm_codapman :=  v_tmp_codempidh;
              tappfm_codpos   :=  v_tmp_codposh;
              tappfm_codcomp  :=  v_tmp_codcomph;
              p_codempid_query := v_tmp_codempidh;
            end if;
            ---
            /* insert */
            begin
              select codcomp, codpos into temploy1_codcomp, temploy1_codpos
                from temploy1
               where codempid = r1.codempid;
               exception when no_data_found then  temploy1_codcomp  := null;  temploy1_codpos  := null; --<< user25 Date : 17/11/2021 #7184
            end;
            begin
--Redmine #5552
              v_codaplvl := get_codaplvl(p_dteyreap, p_numtime, r1.codempid);
--Redmine #5552
              select dteapstr, dteapend into v_dteapstr, v_dteapend
                from tstdisd
               where nvl(p_codcomp,temploy1_codcomp) like codcomp||'%'
                 and codaplvl = p_codaplvl
                 and dteyreap = p_dteyreap
                 and numtime = p_numtime
--Redmine #5552
                 and codaplvl = nvl(v_codaplvl, codaplvl)
                 and rownum = 1
--Redmine #5552
               order by codcomp desc;
            exception when no_data_found then
              null;
            end;
            begin
              insert into tappfm (codempid,dteyreap,numtime,numseq,
                                  codapman,codposap,codcompap,codcomp,codpos,codaplvl,
                                  flgtypap,dteapstr,dteapend,flgappr,flgapman,
                                  codcreate,coduser)
              values (r1.codempid, p_dteyreap, p_numtime, r2.numseq,
                      tappfm_codapman, tappfm_codpos, tappfm_codcomp, temploy1_codcomp, temploy1_codpos, r1.codaplvl,
                      v_flgtypap, v_dteapstr, v_dteapend, '', r2.flgdisp,
                      global_v_coduser, global_v_coduser);
--<< user20 Date: 01/09/2021  AP Module- #3582
              exception when dup_val_on_index then
                begin
                  update tappfm
                     set codapman = tappfm_codapman,
                         codposap = tappfm_codpos,
                         codcompap = tappfm_codcomp,
                         codcomp  =  temploy1_codcomp,
                         codpos   = temploy1_codpos,
                         codaplvl = r1.codaplvl,
                         flgtypap = v_flgtypap,
                         dteapstr = v_dteapstr,
                         dteapend = v_dteapend,
                         flgappr  =  '',
                         flgapman = r2.flgdisp,
                         codcreate = global_v_coduser,
                         coduser   = global_v_coduser
                   where codempid = r1.codempid
                     and dteyreap = p_dteyreap
                     and numtime  = p_numtime
                     and numseq = r2.numseq;
                end;
--<< user20 Date: 01/09/2021  AP Module- #3582
            end;
            ---
          end loop;
            end loop;
      end if;
      --

    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_head( v_tmp_codcomp in varchar2,
                      v_tmp_codpos in varchar2,
                      v_tmp_codcomph out varchar2,
                      v_tmp_codposh out varchar2,
                      v_tmp_codempidh out varchar2,
                      v_tmp_stapost out varchar2) is

    v_codempidh   temphead.codempidh%type := ''; --from temphead, temphead
    v_codcomph    temphead.codcomph%type := '';
    v_codposh     temphead.codposh%type := '';
    v_stapost     tsecpos.stapost2%type := ''; -- from tsecpos
    v_chk_head1   varchar2(1) := 'N';

    cursor c_head1 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
              decode(codempidh,'%',2,1) sorting
      from    temphead
      where   codempid = p_codempid_query
      order by sorting,numseq;

    cursor c_head2 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
              decode(codempidh,'%',2,1) sorting
      from    temphead
      where   codcomp = v_tmp_codcomp
      and     codpos  = v_tmp_codpos
      order by sorting,numseq;
  begin
    v_chk_head1  := 'N' ;
    for j in c_head1 loop
      v_chk_head1  := 'Y' ;
      if j.codempidh  is not null then
        v_codempidh := j.codempidh ;
      else
        v_codcomph  := j.codcomph ;
        v_codposh   := j.codposh ;
      end if;
      exit;
    end loop;
    if 	v_chk_head1 = 'N' then
      for j in c_head2 loop
        v_chk_head1  := 'Y' ;
        if j.codempidh  is not null then
          v_codempidh := j.codempidh ;
        else
          v_codcomph  := j.codcomph ;
          v_codposh   := j.codposh ;
        end if;
        exit;
      end loop;
    end if;
    if v_codcomph is not null then
      begin
        select codempid into v_codempidh
          from temploy1
         where codcomp  = v_codcomph
           and codpos   = v_codposh
           and staemp   in  ('1','3')
           and rownum   = 1;
           v_stapost := null;
      exception when no_data_found then
        begin
          select codempid,stapost2 into v_codempidh,v_stapost
            from tsecpos
           where codcomp	= v_codcomph
             and codpos	  = v_codposh
             and dteeffec <= sysdate
             and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
             and rownum   = 1;
        exception when no_data_found then
          v_codempidh := null;
          v_stapost := null;
        end;
      end;
    end if;
    v_tmp_codcomph      := v_codcomph;
    v_tmp_codposh       := v_codposh;
    v_tmp_codempidh     := v_codempidh;
    v_tmp_stapost       := v_stapost;
--<<#7186||USER39||15/12/2021
    if v_codempidh is not null then
       begin
           select codcomp,codpos into v_tmp_codcomph ,v_tmp_codposh
           from temploy1 where codempid = v_codempidh;
       exception when no_data_found then
           v_tmp_codcomph := null;
           v_tmp_codposh  := null;
       end;
    end if;
-->>#7186||USER39||15/12/2021
  end; -- end get_head
  --
  --
  procedure get_conap(v_tmp_codcomp in varchar2,
                      v_tmp_codpos in varchar2,
                      v_tmp_codempid in varchar2,
                      taplvl_codcomp out varchar2,
                      taplvl_codaplvl out varchar2,
                      v_flgpass out boolean) is

    v_check       boolean;
    v_statement   varchar2(1000 char) := '';

    cursor c1 is
      select a.codcomp, a.codaplvl, a.condap
        from taplvl a
       where v_tmp_codcomp like a.codcomp||'%'
       and a.codaplvl = nvl(p_codaplvl, codaplvl)
       and a.dteeffec = (select max(dteeffec)
                         from taplvl b
                         where b.codaplvl = a.codaplvl
                         and b.codcomp = a.codcomp
                         and dteeffec <= trunc(sysdate))
                         order by a.codcomp desc,codaplvl;
  begin
    v_flgpass := false;
    for r1 in c1 loop
      v_statement := 'select count(*) from v_hrap14e where codempid = '''|| v_tmp_codempid ||'''' || 'and staemp <> 9 and (' || r1.condap||')';
      v_check := execute_stmt(v_statement);
      if v_check then
        taplvl_codcomp := r1.codcomp;
        taplvl_codaplvl := r1.codaplvl;
        v_flgpass := true;
        exit;
      end if;
    end loop;

  end;
  --
  procedure gen_tappfm_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_response      varchar2(1000 char);
    v_flggrade      tapbudgt.flggrade%type;
    v_formusal      tapbudgt.formusal%type;
    v_statement     tapbudgt.statement%type;
    cursor c1 is
      select a.codempid, a.numseq, a.codapman, a.codposap, a.codcompap, a.codaplvl, flgapman
        from tappfm a
       where a.dteyreap = p_dteyreap
         and a.numtime = p_numtime
         and a.codcomp like  p_codcomp||'%'
         and a.codaplvl = nvl(p_codaplvl,a.codaplvl)
         and a.codempid = nvl(p_codempid,a.codempid)
       order by a.codaplvl ,a.codempid, a.numseq;
  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numseq', i.numseq);
      obj_data.put('codempid', i.codempid);
      obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
      obj_data.put('desc_codaplvl', get_tcodec_name('TCODAPLV', i.codaplvl, global_v_lang));
      obj_data.put('desc_codempidap', get_temploy_name(i.codapman, global_v_lang));
      obj_data.put('desc_codcompap', get_tcenter_name(i.codcompap, global_v_lang));
      obj_data.put('desc_codposap', get_tpostn_name(i.codposap, global_v_lang));
      obj_data.put('desc_flgdisp', get_tlistval_name('FLGDISP', i.flgapman, global_v_lang));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_tappfm_data(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tappfm_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure post_import_process(json_str_input in clob, json_str_output out clob) as
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

    if param_msg_error is not null then
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        --
        obj_row    := json_object_t();
        obj_result := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('rec_tran', v_rec_tran);
        obj_row.put('rec_err', v_rec_err);
        obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        --
        if p_numseq.exists(p_numseq.first) then
          for i in p_numseq.first .. p_numseq.last
          loop
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
    end if;
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

    v_code              varchar2(100);
    v_flgsecu           boolean;
    v_cnt               number := 0;
    v_dteleave          date;
    v_coderr            varchar2(4000 char);
    v_num               number := 0;
    v_count             number := 0;

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

    v_dteyreap          tappasgn.dteyreap%type;
    v_numtime           tappasgn.numtime%type;
    v_codcomp           tappasgn.codcomp%type;
    v_codempid          tappasgn.codempid%type;
    v_codaplvl          tappasgn.codaplvl%type;
    v_numseq            tappasgn.numseq%type;
    v_flgappr           tappasgn.flgappr%type;
    v_codcompap         tappasgn.codcompap%type;
    v_codposap          tappasgn.codpospap%type;
    v_codempap          tappasgn.codempap%type;
    v_flgtypap          tstdisd.flgtypap%type;
    v_flgdisp           tappasgn.flgdisp%type;

    v_tmp_codempap      temploy1.staemp%type;
    v_tmp_codcomp       tappasgn.codcomp%type;
    v_tmp_codposap      tappasgn.codpospap%type;
    v_tmp_codaplvl      tappasgn.codaplvl%type;
    v_staemp            temploy1.staemp%type;

    v_cnt_flgdisp1      number := 0;
    v_cnt_flgdisp2      number := 0;

    v_flgappr_last      tappasgn.flgappr%type;

    v_flgappr_last_loop      tappasgn.flgappr%type := '9';

    cursor c1 is
        select flgappr
          from tappasgn
         where dteyreap = v_dteyreap
           and numtime = v_numtime
           and codcomp = nvl(v_codcomp,'%')
           and codaplvl = nvl(v_codaplvl,'%')
           and codempid = nvl(v_codempid,'%')
      order by numseq;
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
          v_text(1)   := hcm_util.get_string_t(param_json_row,'dteyearap');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'numtime');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'codcomp');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'codaplvl');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'codempid');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'numseq');
          v_text(7)   := hcm_util.get_string_t(param_json_row,'flgappr');
          v_text(8)   := hcm_util.get_string_t(param_json_row,'codcompap');
          v_text(9)   := hcm_util.get_string_t(param_json_row,'codposap');
          v_text(10)  := hcm_util.get_string_t(param_json_row,'codempidap');
          v_text(11)  := hcm_util.get_string_t(param_json_row,'flgdisp');
--
          data_file := null;
          for i in 1..11 loop
            data_file := v_text(1)||', '||v_text(2)||', '||v_text(3)||', '||v_text(4)||', '||v_text(5)||', '||v_text(6)||', '||v_text(7)||', '||v_text(8)||', '||v_text(9)||', '||v_text(10)||', '||v_text(11);
            if v_text(i) is null then
              if i = 1 or i = 2 or i = 6 or i = 7 or i = 11 then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
            end if;
          end loop;
          if v_text(3) is null and v_text(4) is null and v_text(5) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            exit cal_loop;
          end if;
          -- 1. dteyreap
          i := 1;
          if length(v_text(i)) > 4 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif not regexp_like(v_text(i), '^[[:digit:]]+$') then
            v_error	 	  := true;
            v_err_code  := 'CO0020';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_dteyreap := v_text(i);

          -- 2. numtime
          i := 2;
          if length(v_text(i)) > 2 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif not regexp_like(v_text(i), '^[[:digit:]]+$') then
            v_error	 	  := true;
            v_err_code  := 'CO0020';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_numtime := v_text(i);

          -- 3. codcomp
          i := 3;
          if length(v_text(i)) > 40 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            if v_text(4) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_filed := v_filed(4);
              exit cal_loop;
            end if;
            begin
              select codcomp into v_tmp_codcomp
                from tcenter
               where codcomp = get_compful(v_text(i));
            exception when no_data_found then
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TCENTER';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end;
            if not secur_main.secur7(v_text(i), global_v_coduser) then
              v_error	 	  := true;
              v_err_code  := 'HR3007';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_codcomp := nvl(v_text(i),'%');

          -- 4. codaplvl
          i := 4;
          if length(v_text(i)) > 4 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            if v_text(3) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_filed := v_filed(3);
              exit cal_loop;
            end if;
            begin
              select codcodec into v_tmp_codaplvl
                from tcodaplv
               where codcodec = v_text(i);
            exception when no_data_found then
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TCODAPLV';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end;
            begin
              select count(*) into v_count
                from taplvl a
               where a.codaplvl = v_text(i)
                 and a.codcomp  = v_text(3)
                 and a.dteeffec = (select max(b.dteeffec)
                                     from taplvl b
                                    where b.codaplvl = a.codaplvl
                                      and b.codcomp  = a.codcomp
                                      and b.dteeffec <= trunc(sysdate));
            end;
            if v_count = 0 then
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TAPLVL';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_codaplvl := nvl(v_text(i),'%');

          -- 5. codempid
          i := 5;
          if length(v_text(i)) > 10 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            begin
              select staemp into v_staemp
              from temploy1
              where codempid = v_text(i);
            exception when no_data_found then
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TEMPLOY1';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end;
            if not secur_main.secur2(v_text(i), global_v_coduser,global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
              v_error	 	  := true;
              v_err_code  := 'HR3007';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
            if v_staemp = '9' then
              v_error	 	  := true;
              v_err_code  := 'HR2101';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_codempid := nvl(v_text(i),'%');

          -- 6. numseq
          i := 6;
          if length(v_text(i)) > 2 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_numseq := v_text(i);

          -- 7. flgappr
          i := 7;
          if length(v_text(i)) > 1 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
--          elsif v_flgappr_last_loop <> '1' and v_text(i) = '5' then
--            v_error     := true;
--            v_err_code  := 'AP0069';
--            v_err_filed := v_filed(i);
--            exit cal_loop;
          elsif v_flgappr_last_loop not in ('1','5') and v_text(i) = '5' then
            begin
              select flgtypap into v_flgtypap
                from tstdisd
               where v_codcomp like codcomp||'%'
                 and codaplvl = nvl(v_codaplvl,codaplvl)
                 and dteyreap = v_dteyreap
                 and numtime = v_numtime
                 and rownum = 1
               order by codcomp desc;
            exception when no_data_found then
              v_flgtypap := null;
            end;
            if v_flgtypap = 'T' then
              v_error     := true;
              v_err_code  := 'AP0052';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_flgappr := v_text(i);

          -- 8. codcompap
          i := 8;
          if length(v_text(i)) > 40 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            if v_text(7) = '2' then
              if v_text(9) is null then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(9);
                exit cal_loop;
              end if;
              begin
                select codcomp into v_tmp_codcomp
                  from tcenter
                 where codcomp = get_compful(v_text(i));
              exception when no_data_found then
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TCENTER';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end;
            else
              v_error     := true;
              v_err_code  := 'HR2020';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_codcompap := v_text(i);

          -- 9. codposap
          i := 9;
          if length(v_text(i)) > 4 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            if v_text(7) = '2' then
              if v_text(8) is null then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(8);
                exit cal_loop;
              end if;
              begin
                select codpos into v_tmp_codposap
                  from tpostn
                 where codpos = v_text(i);
              exception when no_data_found then
                v_error	 	  := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TPOSTN';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end;
            else
              v_error     := true;
              v_err_code  := 'HR2020';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;
          v_codposap := v_text(i);

          -- 10. codempidap
          i := 10;
          if length(v_text(i)) > 10 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null then
            if v_text(7) <> '3' then
              v_error     := true;
              v_err_code  := 'HR2020';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
            begin
              select staemp into v_tmp_codempap
                from temploy1
               where codempid = v_text(i);
            exception when no_data_found then
              v_error	 	  := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TEMPLOY1';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end;
            if v_tmp_codempap = '9' then
              v_error	 	  := true;
              v_err_code  := 'HR2101';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          elsif v_text(i) is null and v_text(7) = '3' then
            v_error     := true;
            v_err_code  := 'HR2045';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_codempap := v_text(i);

          -- 11. flgdisp
          i := 11;
          if length(v_text(i)) > 1 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif v_text(i) is not null and v_text(i) not in ('1','2','3','4')then
              v_error     := true;
              v_err_code  := 'HR2020';
              v_err_filed := v_filed(i);
              exit cal_loop;
          end if;

          if v_text(i) = '1' then
            begin
              select count(*) into v_cnt_flgdisp1
              from tappasgn
               where dteyreap = v_dteyreap
                 and numtime = v_numtime
                 and codcomp = nvl(v_codcomp,'%')
                 and codaplvl = nvl(v_codaplvl,'%')
                 and codempid = nvl(v_codempid,'%')
                 and flgdisp = v_text(i)
                 and numseq <> v_numseq;
            end;

            v_cnt_flgdisp1  := v_cnt_flgdisp1 + 1;
            if v_cnt_flgdisp1 > 1 then
              v_error     := true;
              v_err_code  := 'AP0049';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          elsif v_text(i) = '3' then
            begin
              select count(*) into v_cnt_flgdisp2
              from tappasgn
               where dteyreap = v_dteyreap
                 and numtime = v_numtime
                 and codcomp = nvl(v_codcomp,'%')
                 and codaplvl = nvl(v_codaplvl,'%')
                 and codempid = nvl(v_codempid,'%')
                 and flgdisp = v_text(i)
                 and numseq <> v_numseq;
            end;
            v_cnt_flgdisp2  := v_cnt_flgdisp2 + 1;
            if v_cnt_flgdisp2 > 1 then
              v_error     := true;
              v_err_code  := 'AP0050';
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
          end if;

          v_flgdisp := v_text(i);

          exit cal_loop;
        end loop;
--
        if not v_error then
          v_rec_tran := v_rec_tran + 1;
          begin
            insert into tappasgn(dteyreap,numtime,codcomp,codempid,codaplvl,numseq,
                                 flgappr,codcompap,codpospap,codempap,flgdisp,
                                 codcreate,coduser)
            values (v_dteyreap, v_numtime, v_codcomp, v_codempid, v_codaplvl, v_numseq,
                    v_flgappr, v_codcompap, v_codposap, v_codempap, v_flgdisp,
                    global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            begin
              update tappasgn
                 set flgappr	=	v_flgappr,
                     codcompap	=	v_codcompap,
                     codpospap	=	v_codposap,
                     codempap	=	v_codempap,
                     flgdisp	=	v_flgdisp,
                     dteupd = sysdate,
                     coduser = global_v_coduser
               where dteyreap = v_dteyreap
                 and numtime = v_numtime
                 and codcomp = nvl(v_codcomp,'%')
                 and codaplvl = nvl(v_codaplvl,'%')
                 and codempid = nvl(v_codempid,'%')
                 and numseq = v_numseq;
            end;
            v_flgappr_last_loop := v_flgappr;
          end;

          -- check after save
          v_flgappr_last := '9';
          for r1 in c1 loop
--            if r1.flgappr = '5' and v_flgappr_last <> '1' then
--              param_msg_error := get_error_msg_php('AP0069',global_v_lang);
--              exit;
              if r1.flgappr = '5' and v_flgappr_last not in ('1','5') then
                begin
                  select flgtypap into v_flgtypap
                    from tstdisd
                   where v_codcomp like codcomp||'%'
                     and codaplvl = nvl(v_codaplvl,codaplvl)
                     and dteyreap = v_dteyreap
                     and numtime = v_numtime
                     and rownum = 1
                   order by codcomp desc;
                exception when no_data_found then
                  v_flgtypap := null;
                end;
                if v_flgtypap = 'T' then
                  param_msg_error := get_error_msg_php('AP0052',global_v_lang);
                  exit;
                end if;
            end if;
            v_flgappr_last   := r1.flgappr;
          end loop;
        else  --if error
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
----          GET_ERRORM_NAME (v_err_code,global_v_lang)||v_err_table ||'('||v_err_filed||')';
----          replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1+1;
        end if;
--
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
  --
end hrap3oe;

/

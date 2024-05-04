--------------------------------------------------------
--  DDL for Package Body HREL52X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HREL52X" as
  procedure initial_value(json_str in varchar2) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    p_zyear             := HCM_APPSETTINGS.get_additional_year;

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_codcours          := hcm_util.get_string_t(json_obj,'p_codcours');
    p_codcatexm         := hcm_util.get_string_t(json_obj,'p_codcatexm');
    p_codexam           := hcm_util.get_string_t(json_obj,'p_codexam');
    p_typtest           := hcm_util.get_string_t(json_obj,'p_typtest');
    
    p_obj_data          := hcm_util.get_json_t(json_obj,'param');
    p_obj_search        := hcm_util.get_json_t(json_obj,'paramSearch');
    
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  procedure gen_index(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row             json_object_t;
    
    v_row               number := 0;
    v_count             number := 0;

    cursor c1 is
--      select a.codexam, decode('1',a.typtest,'1','2') as typtest,
      select a.codexam, decode(a.typtest,'1','1','2') as typtest,
             count(a.codempid) as codempid,sum(decode('Y',a.statest,1,0)) as statest,
             avg(b.qtyscore) as qtyscore, max(a.score) as maxscore, avg(a.score) as avgscore
        from ttestemp a , tvtest b
       where a.codexam   = b.codexam
         and nvl(a.codcomp,a.codcompl) like p_codcomp||'%'
         and (p_codcours is not null and a.codcours  = p_codcours or p_codcours is null)
         and a.codexam = nvl(p_codexam,a.codexam) 
         and b.codcatexm = nvl(p_codcatexm,b.codcatexm)
         and a.dtetest between p_dtestrt and p_dteend
         and ((typtest = '1'
               and exists(select tusrcom.codcomp
                      from tusrcom
                     where tusrcom.coduser = global_v_coduser
                       and a.codcompl  like tusrcom.codcomp || '%'))  
             or (typtest in ('2','3','4','5') 
                 and exists(select tusrcom.codcomp
                              from tusrcom
                             where tusrcom.coduser = global_v_coduser
                               and a.codcomp like tusrcom.codcomp || '%')
                 and exists(select codempid
                              from temploy1
                             where codempid = a.codempid
                               and numlvl between global_v_zminlvl and global_v_zwrklvl)))
         
    group by a.codexam, decode(a.typtest,'1','1','2')   
    order by a.codexam, decode(a.typtest,'1','1','2');

  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codexam', r1.codexam);
      obj_data.put('namexam', get_tvtest_name(r1.codexam, global_v_lang));
      obj_data.put('desc_typtest', get_tlistval_name('TYPTEST' , r1.typtest, global_v_lang));
      obj_data.put('typtest', r1.typtest);
      obj_data.put('numexam', r1.codempid);
      obj_data.put('numpass', r1.statest);
      obj_data.put('fscore', r1.qtyscore);
      obj_data.put('hscore', r1.maxscore);
      obj_data.put('ascore', to_char(r1.avgscore,'fm999,990.00'));
      --
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TTESTEMP');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else 
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
     --
  procedure check_index is
    v_count_comp  number := 0;
    v_chkExist    number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null or p_dtestrt is null or p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcatexm is null and p_codexam is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    --
    begin
      select count(*) into v_count_comp
        from tcenter
       where codcomp like p_codcomp || '%' ;
    exception when others then null;
    end;
    
    if v_count_comp < 1 then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
      return;
    end if;
    v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
    if not v_secur then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    --
    
    if p_codcours is not null then
      begin
        select count(*) into v_chkExist
          from tcourse
         where codcours = p_codcours;
      exception when others then null;
      end;
      
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
        return;
      end if;
    end if;
    --
    if p_codcatexm is not null then
      begin
        select count(*) into v_chkExist
          from tcodcatexm
         where codcodec = p_codcatexm;
      exception when others then null;
      end;
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCATEXM');
        return;
      end if;
    end if;
    --
    
    if p_codexam is not null then
      begin
        select count(*) into v_chkExist
          from tvtest
         where codexam = p_codexam;
      exception when others then null;
      end;
      
      if v_chkExist < 1 then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXAM');
        return;
      end if;
    end if;
    
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;
  
  procedure get_index (json_str_input in clob,json_str_output out clob) is
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_data            json_object_t;
    obj_data_child      json_object_t;
    obj_row             json_object_t;
    obj_row_child       json_object_t;
    
    v_row               number := 0;
    v_row_child         number := 0;
    v_count             number := 0;
    v_remark            varchar2(500 char);
    cursor c1 is
      select a.codempid, a.namtest, decode('1',a.typtest,'1','2') as typtest,
             a.qtyscore, a.score, a.statest 
        from ttestemp a
       where a.codexam   = p_codexam
         and decode(a.typtest,'1','1','2') = p_typtest
         and nvl(a.codcomp,a.codcompl) like p_codcomp||'%'
         and (p_codcours is not null and a.codcours  = p_codcours or p_codcours is null)
         and a.dtetest between p_dtestrt and p_dteend
          and ((a.typtest = '1'
               and exists(select tusrcom.codcomp
                      from tusrcom
                     where tusrcom.coduser = global_v_coduser
                       and a.codcompl  like tusrcom.codcomp || '%'))  
             or (a.typtest in ('2','3','4','5') 
                 and exists(select tusrcom.codcomp
                              from tusrcom
                             where tusrcom.coduser = global_v_coduser
                               and a.codcomp like tusrcom.codcomp || '%')
                 and exists(select codempid
                              from temploy1
                             where codempid = a.codempid
                               and numlvl between global_v_zminlvl and global_v_zwrklvl)))
       order by a.codempid;

  begin
    obj_row := json_object_t();
    v_count := 0;
    for r1 in c1 loop
      obj_data   := json_object_t();
      v_count    := v_count + 1;
      obj_data.put('coderror', '200');
      obj_data.put('codappl', r1.codempid);
      obj_data.put('namtest', r1.namtest);
      obj_data.put('typtest', get_tlistval_name('TYPTEST' , r1.typtest, global_v_lang));
      obj_data.put('qtyscore', r1.qtyscore);
      obj_data.put('score', r1.score);
      obj_data.put('statest', r1.statest );
      begin
        select remark into v_remark
          from tvtesta 
         where codexam = p_codexam
           and r1.score between scorest and scoreen;
      exception when no_data_found then 
        v_remark := '';
      end;
      obj_data.put('remark', v_remark);
      --
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'TTESTEMP');
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else 
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail (json_str_input in clob,json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  --
  procedure gen_report(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    param_json_row    json_object_t;
    v_numseq      number := 0;
    v_number      number := 0;
    
    v_item5      varchar2(500 char);
    v_remark      varchar2(500 char);
    v_codexam	    varchar2(100 char);
    v_typtest	    varchar2(100 char);
    v_empname	    varchar2(200 char);
    
    cursor c1 is
      select a.codempid, a.namtest, decode('1',a.typtest,'1','2') as typtest,
             a.qtyscore, a.score, a.statest 
        from ttestemp a
       where a.codexam = v_codexam
         and decode(a.typtest,'1','1','2') = v_typtest
         and nvl(a.codcomp,a.codcompl) like p_codcomp||'%'
         and (p_codcours is not null and a.codcours  = p_codcours or p_codcours is null)
         and a.dtetest between p_dtestrt and p_dteend
       order by a.codempid;
  begin
    initial_value(json_str_input);
    
    p_codcomp           := hcm_util.get_string_t(p_obj_search,'codcomp');
    p_dtestrt           := to_date(hcm_util.get_string_t(p_obj_search,'datest'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(p_obj_search,'dateen'),'dd/mm/yyyy');
    p_codcours          := hcm_util.get_string_t(p_obj_search,'codcours');
    p_codcatexm         := hcm_util.get_string_t(p_obj_search,'codcatexm');
    p_codexam           := hcm_util.get_string_t(p_obj_search,'codexam');

    begin
      delete ttemprpt
       where codempid = global_v_codempid
         and codapp = 'HREL52X';
    end;
    begin
      select nvl(max(numseq) + 1,1) into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp = 'HREL52X';
    exception when no_data_found then
      v_numseq := 1;
    end;
    for i in 0..p_obj_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(p_obj_data,to_char(i));
      v_codexam	      := hcm_util.get_string_t(param_json_row, 'codexam');
      v_typtest	      := hcm_util.get_string_t(param_json_row, 'typtest');
      
      v_item5 := to_char(add_months(p_dtestrt,p_zyear*12),'dd/mm/yyyy') || ' - ' || to_char(add_months(p_dteend,p_zyear*12),'dd/mm/yyyy');
      begin
        insert into ttemprpt (codempid,codapp,numseq,
                              item1, item2, item3, item4, item5)
           values (global_v_codempid, 'HREL52X',v_numseq,
                   'DETAIL', v_codexam, v_codexam || ' - ' || get_tvtest_name(v_codexam, global_v_lang), get_tcenter_name(p_codcomp, global_v_lang), v_item5);
      end;
      v_numseq := v_numseq + 1;
      v_number := 0;
      for r1 in c1 loop
        begin
          select remark into v_remark
            from tvtesta 
           where codexam = v_codexam
             and r1.score between scorest and scoreen;
        exception when no_data_found then 
          v_remark := '';
        end;
        
        if r1.typtest = 1 then
          begin
            select  decode(global_v_lang,'101',namempe,
                                  '102',namempt,
                                  '103',namemp3,
                                  '104',namemp4,
                                  '105',namemp5) as namemp
             into v_empname
            from tappoinf a, tapplinf b
          where a.numappl = b.numappl
             and codlogin = r1.codempid;
          exception when no_data_found then
            v_empname := '';
          end;
        else
          v_empname := get_temploy_name(r1.codempid, global_v_lang);
        end if;
        
        
        v_number := v_number + 1;
        begin
          insert into ttemprpt (codempid,codapp,numseq,
                                item1, item2, item3, item4, item5, item6, 
                                item7, item8, item9, item10)
             values (global_v_codempid, 'HREL52X',v_numseq,
                     'TABLE',v_codexam, v_number, r1.codempid, v_empname, get_tlistval_name('TYPTEST' , r1.typtest, global_v_lang), 
                     r1.qtyscore, r1.score, get_tlistval_name('STATEST', r1.statest, global_v_lang), v_remark);
        end;
        v_numseq := v_numseq + 1;
      end loop;
    end loop;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end hrel52x;

/

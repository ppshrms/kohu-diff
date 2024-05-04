--------------------------------------------------------
--  DDL for Package Body HRRC1DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC1DX" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dteopenst   := to_date(hcm_util.get_string_t(json_obj,'p_dteopenst'),'dd/mm/yyyy');
    b_index_dteopenen   := to_date(hcm_util.get_string_t(json_obj,'p_dteopenen'),'dd/mm/yyyy');

    p_numreqst          := hcm_util.get_string_t(json_obj,'p_numreqst');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codjob            := hcm_util.get_string_t(json_obj,'p_codjob');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end If;

    if b_index_dteopenst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;    
    end if;

    if b_index_dteopenen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;    
    end if;  

    if b_index_dteopenen <  b_index_dteopenst then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;    
    end if;  

  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;

    cursor c_treqest2 is
      select numreqst,codpos,codcomp,codjob,flgrecut,dteopen,qtyreq,dteclose
        from treqest2
       where codcomp  like b_index_codcomp||'%'
         and dteopen between b_index_dteopenst and b_index_dteopenen
      order by codcomp,codpos;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    obj_result := json_object_t();
    for i in c_treqest2 loop
        v_flgdata   := 'Y';
        v_secur     := secur_main.secur7(i.codcomp, global_v_coduser);
        if v_secur then
            v_flgsecur  := 'Y';
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp,global_v_lang) );
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
            obj_data.put('desc_codjob', get_tjobcode_name(i.codjob,global_v_lang) );
            obj_data.put('qtyreq', i.qtyreq);
            obj_data.put('dteopen', to_char(i.dteopen,'dd/mm/yyyy'));
            obj_data.put('dteclose', to_char(i.dteclose,'dd/mm/yyyy'));
            obj_data.put('desc_flgrecut', get_tlistval_name('FLGRECUT',i.flgrecut,global_v_lang) );

            obj_data.put('numreqst', i.numreqst);           
            obj_data.put('flgrecut', i.flgrecut);  
            obj_data.put('codpos', i.codpos);  
            obj_data.put('codjob', i.codjob); 

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if; 
    end loop;
    if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_jobdesc(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		  number := 0;
    v_jobdesc     treqest2.desnote%type;
    v_remarks     treqest1.desnote%type;

  begin
    initial_value(json_str_input);
    begin
      select b.desnote, a.desnote into v_jobdesc,v_remarks
        from treqest1 a , treqest2 b
       where a.numreqst  = b.numreqst
         and a.numreqst  = p_numreqst
         and b.codpos    = p_codpos;  
    exception when no_data_found then
        v_jobdesc := null;
        v_remarks := null;
    end;

    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numreqst', p_numreqst);
    obj_data.put('desc_codpos', get_tpostn_name(p_codpos,global_v_lang));
    obj_data.put('jobdesc', v_jobdesc);
    obj_data.put('remarks', v_remarks);
    obj_row.put(to_char(0), obj_data);

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);   
  end get_detail_jobdesc;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
         initial_value(json_str_input);
         gen_detail(json_str_output);
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

  procedure gen_detail(json_str_output out clob) as
        obj_result      json_object_t;
        obj_rows        json_object_t;
        obj_data        json_object_t;
        obj_syncond     json_object_t;
        v_row           number := 0;
        rec_tjobcode    tjobcode%rowtype;
        v_amtcolla      tjobcode.amtcolla%type;
        v_amtguarntr    varchar2(11 char);
        v_namjob        tjobcode.namjobe%type;
        v_desguar       tjobcode.desguar%type;
        v_desjob        tjobcode.desjob%type;
        v_dteupd        tjobcode.dteupd%type;
        v_coduser       tjobcode.coduser%type;
        v_qtyguar       tjobcode.qtyguar%type;
        v_statement     tjobcode.statement%type;
        v_syncond       tjobcode.syncond%type;
        v_codempid      temploy1.codempid%type;
        v_desc_syncond  varchar2(4000 char);

        cursor c1 is
          select * 
            from tjobdet
           where codjob = p_codjob
           order by itemno;

       cursor c2 is
          select * 
          from tjobresp
          where codjob = p_codjob
          order by itemno;

      cursor c3 is
          select * 
          from tjobeduc
          where codjob = p_codjob
          order by seqno;
    begin
        begin
            select amtcolla,amtguarntr,desguar,desjob, dteupd, coduser,
                   qtyguar,statement,syncond,decode(global_v_lang,'101',namjobe
                                                                 ,'102',namjobt
                                                                 ,'103',namjob3
                                                                 ,'104',namjob4
                                                                 ,'105',namjob5) as namjob
              into v_amtcolla,v_amtguarntr,v_desguar,v_desjob, v_dteupd, v_coduser,
                   v_qtyguar,v_statement,v_syncond, v_namjob
              from tjobcode 
             where codjob = p_codjob;
        exception when no_data_found then null;
        end;
        v_codempid := get_codempid(v_coduser);
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desjob',nvl(v_desjob,''));
        obj_data.put('syncond',get_logical_desc(v_statement));
        obj_data.put('amtcolla',nvl(to_char(v_amtcolla,'fm999,999,990.00'),'') ||' '|| get_label_name('HRRC1DXC3', global_v_lang, 100));
        obj_data.put('qtyguar',nvl(v_qtyguar,''));
        obj_data.put('amtguarntr',nvl(to_char(v_amtguarntr,'fm999,999,990.00'),'') ||' '|| get_label_name('HRRC1DXC3', global_v_lang, 100));
        obj_data.put('desguar',nvl(v_desguar,''));
        obj_data.put('dteupdte',to_char(v_dteupd,'dd/mm/yyyy'));
        obj_data.put('editer',get_temploy_name(v_codempid, global_v_lang));
        obj_data.put('codupdte',v_codempid);
        obj_data.put('image', get_emp_img(v_codempid));--nut 

        --tab1
        obj_rows := json_object_t();
        for i in c1 loop
            v_row := v_row+1;
            obj_result := json_object_t();
            obj_result.put('coderror', '200');
            obj_result.put('itemno',i.itemno);
            obj_result.put('namitem',i.namitem);
            obj_result.put('descrip',i.descrip);
            obj_rows.put(to_char(v_row-1),obj_result);
        end loop;
        obj_data.put('tab1',obj_rows);
        --tab2
        obj_rows := json_object_t();
        v_row := 0;
        for i in c2 loop
            v_row := v_row+1;
            obj_result := json_object_t();
            obj_result.put('itemno',i.itemno);
            obj_result.put('namitem',i.namitem);
            obj_result.put('descrip',i.descrip);
            obj_rows.put(to_char(v_row-1),obj_result);
        end loop;
        obj_data.put('tab2',obj_rows);
        --tab3
        obj_rows := json_object_t();
        v_row := 0;
        for i in c3 loop
            v_row := v_row+1;
            obj_result := json_object_t();
            obj_result.put('seqno',i.seqno);
            obj_result.put('codedlv',get_tcodec_name('tcodeduc', i.codedlv, global_v_lang));
            obj_result.put('codmajsb',get_tcodec_name('tcodmajr', i.codmajsb, global_v_lang));
            obj_result.put('numgpa',to_char(i.numgpa,'fm90.00'));
            obj_rows.put(to_char(v_row-1),obj_result);
        end loop;
        obj_data.put('tab3',obj_rows);

        json_str_output := obj_data.to_clob;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;



END HRRC1DX;

/

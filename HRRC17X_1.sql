--------------------------------------------------------
--  DDL for Package Body HRRC17X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC17X" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codemprc    := hcm_util.get_string_t(json_obj,'p_codemprc');
    b_index_dtereqst    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    b_index_dtereqen    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    b_index_stareq      := hcm_util.get_string_t(json_obj,'p_stareq');

    p_numreqst          := hcm_util.get_string_t(json_obj,'numreqst');
    p_codpos            := hcm_util.get_string_t(json_obj,'codpos');

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

    if b_index_dtereqst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;    
    end if;

    if b_index_dtereqen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;    
    end if;   

    if b_index_dtereqen < b_index_dtereqst then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;    
    end if; 

    if b_index_stareq is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;    
    end if;

    if b_index_codemprc is not null then
      begin
        select codempid into b_index_codemprc
          from temploy1
         where codempid = b_index_codemprc
           and staemp   in ('1','3');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(b_index_codemprc,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
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
    v_qtyreq        number := 0;
    v_qtyact        number := 0;
    v_qtyapp        number := 0;

    cursor c_treqest is
      select a.numreqst,b.codpos,a.dtereq,a.codemprc,b.flgrecut,
             a.stareq,(a.dterec - a.dtereq) + 1 qtyday,b.qtyreq,b.qtyact,(b.qtyreq - b.qtyact) qtybal
        from treqest1 a, treqest2 b
       where a.numreqst   = b.numreqst
         and a.codcomp    like b_index_codcomp||'%'
         and a.codemprc   = nvl(b_index_codemprc,a.codemprc)
         and a.stareq     = b_index_stareq
         and a.dtereq     between b_index_dtereqst and b_index_dtereqen
      order by numreqst,codpos;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    obj_result := json_object_t();
    for i in c_treqest loop
        v_flgdata   := 'Y';
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numreqst', i.numreqst);
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
        obj_data.put('dtereq', to_char(i.dtereq,'dd/mm/yyyy'));
        obj_data.put('codemprc', i.codemprc);
        obj_data.put('desc_codemprc', get_temploy_name(i.codemprc,global_v_lang) );
        obj_data.put('desc_flgrecut', get_tlistval_name('FLGRECUT',i.flgrecut,global_v_lang) );
        obj_data.put('desc_stareq', get_tlistval_name('TSTAREQ',i.stareq,global_v_lang) );
        obj_data.put('qtyday', round(i.qtyday,2));
        obj_data.put('qtyreq', round(i.qtyreq,2));
        obj_data.put('qtyact', round(i.qtyact,2));
        obj_data.put('qtybal', round(i.qtybal,2));       
--        obj_data.put('codpos', round(i.codpos,2));
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_statusreq(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row		    number := 0;
    v_dtereq        date;
    v_numreqst      treqest1.numreqst%type;
    v_codpos        temploy1.codpos%type;
    v_dtepost       date;
    v_dtechoose     date;
    v_dteintview    date;  
    v_dteappchse    date;

  begin
    initial_value(json_str_input);

    begin
      select a.dtereq,b.numreqst,b.codpos,b.dtepost,b.dtechoose,b.dteintview,b.dteappchse
        into v_dtereq,v_numreqst,v_codpos,v_dtepost,v_dtechoose,v_dteintview,v_dteappchse
        from treqest1 a , treqest2 b
       where a.numreqst  = b.numreqst
         and a.numreqst  = p_numreqst
         and b.codpos    = p_codpos;  
    exception when no_data_found then
        null;
    end;
    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numreqst', v_numreqst);
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang) );
    obj_data.put('dtereq', to_char(v_dtereq,'dd/mm/yyyy'));
    obj_data.put('dtepost', to_char(v_dtepost,'dd/mm/yyyy'));
    obj_data.put('qtypsot', round((v_dtepost - v_dtereq) + 1) );    
    obj_data.put('dtechoose', to_char(v_dtechoose,'dd/mm/yyyy'));
    obj_data.put('qtychoose', round((v_dtechoose - v_dtepost) + 1) ); 
    obj_data.put('dteintview', to_char(v_dteintview,'dd/mm/yyyy'));
    obj_data.put('qtyintview', round((v_dteintview - v_dtechoose) + 1) ); 
    obj_data.put('dteappchse', to_char(v_dteappchse,'dd/mm/yyyy'));
    obj_data.put('qtyappchse', round((v_dteappchse - v_dteintview) + 1) ); 
    obj_data.put('qtyall', (round((v_dtepost - v_dtereq) + 1) + round((v_dtechoose - v_dtepost) + 1) + round((v_dteintview - v_dtechoose) + 1)) ); 
    
    obj_row.put(to_char(0), obj_data);
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);   
  end get_detail_statusreq;

END HRRC17X;

/

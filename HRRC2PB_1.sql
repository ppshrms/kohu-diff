--------------------------------------------------------
--  DDL for Package Body HRRC2PB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC2PB" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_numreqst          := hcm_util.get_string_t(json_obj, 'p_numreqst');
    p_numreqen          := hcm_util.get_string_t(json_obj, 'p_numreqen');
    p_data_import       := hcm_util.get_json_t(json_obj, 'p_data_import');
    p_data_sheet        := hcm_util.get_json_t(p_data_import, 'dataSheet');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_secur             boolean := false;
    v_count             number := 0;
  begin
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
      
        begin
            select count(*) into v_count
              from treqest1
             where codcomp like p_codcomp||'%' ;
        exception when no_data_found then
            v_count := 0;
        end;  
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TREQEST1');
            return;
        end if;       
    end if;
    
    if p_numreqst is not null then
        begin
            select count(*) into v_count
              from treqest1
             where numreqst = p_numreqst ;
        exception when no_data_found then
            v_count := 0;
        end;  
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TREQEST1');
            return;
        end if;           
    end if;
    
    if p_numreqen is not null then
        begin
            select count(*) into v_count
              from treqest1
             where numreqst = p_numreqen ;
        exception when no_data_found then
            v_count := 0;
        end;  
        if v_count = 0 then
            param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TREQEST1');
            return;
        end if;            
    end if;
    
    if p_numreqst is not null and p_numreqen is not null then 
        if p_numreqst > p_numreqen then
            param_msg_error := get_error_msg_php('HR2022', global_v_lang);
            return;
        end if;
    end if;                                                                                                  
  end check_index;
  
  procedure process_data (json_str_input in clob, json_str_output out clob) is
    obj_row                         json_object_t;
    obj_data                        json_object_t;
    obj_main                        json_object_t;
    json_obj                        json_object_t;
    v_response                      varchar2(4000);
    
    tapplinf_response               json_object_t;
    tapplinf_complete_all           number := 0;
    tapplinf_error_all              number := 0;
    
    teducatn_response               json_object_t;
    teducatn_complete_all           number := 0;
    teducatn_error_all              number := 0;
    
    tapplwex_response               json_object_t;
    tapplwex_complete_all           number := 0;
    tapplwex_error_all              number := 0;
    
    ttrainbf_response               json_object_t;
    ttrainbf_complete_all           number := 0;
    ttrainbf_error_all              number := 0;
    
    tapploth_response               json_object_t;
    tapploth_complete_all           number;
    tapploth_error_all              number;
    
    tapplfm_response                json_object_t;
    tapplfm_complete_all            number := 0;
    tapplfm_error_all               number := 0;
    
    tapplrel_response               json_object_t;
    tapplrel_complete_all           number := 0;
    tapplrel_error_all              number := 0;
    
    tapplref_response               json_object_t;
    tapplref_complete_all           number := 0;
    tapplref_error_all              number := 0;
    
    tlangabi_response               json_object_t;
    tlangabi_complete_all           number := 0;
    tlangabi_error_all              number := 0;
    
    addinfo_response                json_object_t;
    addinfo_complete_all            number := 0;
    addinfo_error_all               number := 0;
    
    tappldoc_response               json_object_t;      
    tappldoc_complete_all           number := 0;      
    tappldoc_error_all              number := 0;  
    
    v_email                         varchar2(100 char);
    v_msg                           clob;
    v_error                         varchar2(4000 char);
    
    cursor c_treqest1 is
        select codemprc
          from treqest1
         where numreqst = global_v_numreqst;
  begin
    initial_value(json_str_input);
    check_index;
    json_obj                    := json_object_t();
    tapplinf_response           := json_object_t();
    teducatn_response           := json_object_t();
    tapplwex_response           := json_object_t();
    ttrainbf_response           := json_object_t();
    tapploth_response           := json_object_t();
    tapplfm_response            := json_object_t();
    tapplrel_response           := json_object_t();
    tapplref_response           := json_object_t();
    tlangabi_response           := json_object_t();
    addinfo_response            := json_object_t();
    tappldoc_response           := json_object_t();        
    if param_msg_error is null then
        p_addinfo                 := hcm_util.get_json_t(p_data_sheet, 'p_addinfo');
        p_doc                     := hcm_util.get_json_t(p_data_sheet, 'p_doc');
        p_edu                     := hcm_util.get_json_t(p_data_sheet, 'p_edu');
        p_emppref                 := hcm_util.get_json_t(p_data_sheet, 'p_emppref');
        p_exp                     := hcm_util.get_json_t(p_data_sheet, 'p_exp');
        p_info                    := hcm_util.get_json_t(p_data_sheet, 'p_info');
        p_lng                     := hcm_util.get_json_t(p_data_sheet, 'p_lng');
        p_ref                     := hcm_util.get_json_t(p_data_sheet, 'p_ref');
        p_rel                     := hcm_util.get_json_t(p_data_sheet, 'p_rel');
        p_spouse                  := hcm_util.get_json_t(p_data_sheet, 'p_spouse');
        p_train                   := hcm_util.get_json_t(p_data_sheet, 'p_train');
        
        obj_row         := json_object_t();
        
        --1.tapplinf
        insert_tapplinf(tapplinf_response, tapplinf_complete_all, tapplinf_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '1');
        obj_data.put('iconimage', 'fas fa-user');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'90'));
        obj_data.put('complete', tapplinf_complete_all);
        obj_data.put('error', tapplinf_error_all);
        obj_data.put('table', tapplinf_response);   
        obj_row.put(to_char(0), obj_data);
        
        --2.teducatn
        insert_teducatn(teducatn_response, teducatn_complete_all ,teducatn_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '2');
        obj_data.put('iconimage', 'fas fa-graduation-cap');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'100'));
        obj_data.put('complete', teducatn_complete_all);
        obj_data.put('error', teducatn_error_all);
        obj_data.put('table', teducatn_response);   
        obj_row.put(to_char(1), obj_data);
        
        --3.tapplwex
        insert_tapplwex(tapplwex_response, tapplwex_complete_all ,tapplwex_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '3');
        obj_data.put('iconimage', 'fas fa-briefcase');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'100'));
        obj_data.put('complete', tapplwex_complete_all);
        obj_data.put('error', tapplwex_error_all);
        obj_data.put('table', tapplwex_response);   
        obj_row.put(to_char(2), obj_data);
        
        --4.ttrainbf
        insert_ttrainbf(ttrainbf_response, ttrainbf_complete_all ,ttrainbf_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '4');
        obj_data.put('iconimage', 'fas fa-chalkboard-teacher');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'120'));
        obj_data.put('complete', ttrainbf_complete_all);
        obj_data.put('error', ttrainbf_error_all);
        obj_data.put('table', ttrainbf_response);   
        obj_row.put(to_char(3), obj_data);
        
        --5.tapploth
        insert_tapploth(tapploth_response, tapploth_complete_all ,tapploth_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '5');
        obj_data.put('iconimage', 'fas fa-flag');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'130'));
        obj_data.put('complete', tapploth_complete_all);
        obj_data.put('error', tapploth_error_all);
        obj_data.put('table', tapploth_response);   
        obj_row.put(to_char(4), obj_data);
        
        --6.tapplfm
        insert_tapplfm(tapplfm_response, tapplfm_complete_all ,tapplfm_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '6');
        obj_data.put('iconimage', 'fas fa-heart');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'140'));
        obj_data.put('complete', tapplfm_complete_all);
        obj_data.put('error', tapplfm_error_all);
        obj_data.put('table', tapplfm_response);   
        obj_row.put(to_char(5), obj_data);
        
        --7.tapplrel
        insert_tapplrel(tapplrel_response, tapplrel_complete_all ,tapplrel_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '7');
        obj_data.put('iconimage', 'fas fa-users');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'150'));
        obj_data.put('complete', tapplrel_complete_all);
        obj_data.put('error', tapplrel_error_all);
        obj_data.put('table', tapplrel_response);   
        obj_row.put(to_char(6), obj_data);
        
        --8.tapplref
        insert_tapplref(tapplref_response, tapplref_complete_all ,tapplref_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '8');
        obj_data.put('iconimage', 'fas fa-user-friends');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'160'));
        obj_data.put('complete', tapplref_complete_all);
        obj_data.put('error', tapplref_error_all);
        obj_data.put('table', tapplref_response);   
        obj_row.put(to_char(7), obj_data);
        
        --9.tlangabi
        insert_tlangabi(tlangabi_response, tlangabi_complete_all ,tlangabi_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '9');
        obj_data.put('iconimage', 'fas fa-language');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'170'));
        obj_data.put('complete', tlangabi_complete_all);
        obj_data.put('error', tlangabi_error_all);
        obj_data.put('table', tlangabi_response);   
        obj_row.put(to_char(8), obj_data);
        
        --10.addinfo
        insert_addinfo(addinfo_response, addinfo_complete_all ,addinfo_error_all);
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '10');
        obj_data.put('iconimage', 'fas fa-comment-dots');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'180'));
        obj_data.put('complete', addinfo_complete_all);
        obj_data.put('error', addinfo_error_all);
        obj_data.put('table', addinfo_response);   
        obj_row.put(to_char(9), obj_data);
        
        --11.tappldoc
        insert_tappldoc(tappldoc_response, tappldoc_complete_all ,tappldoc_error_all);     
        obj_data        := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('numseq', '11');
        obj_data.put('iconimage', 'fas fa-file-alt');
        obj_data.put('detail', get_label_name('HRRC2PB1',global_v_lang,'190'));
        obj_data.put('complete', tappldoc_complete_all);
        obj_data.put('error', tappldoc_error_all);
        obj_data.put('table', tappldoc_response);
        obj_row.put(to_char(10), obj_data);
        
        if (tapplinf_error_all + teducatn_error_all + tapplwex_error_all + ttrainbf_error_all + 
            tapploth_error_all + tapplfm_error_all + tapplrel_error_all + tapplref_error_all + 
            tlangabi_error_all + addinfo_error_all + tappldoc_error_all = 0) then
              
              begin
                  select decode(global_v_lang,'101',messagee,
                                       '102',messaget,
                                       '103',message3,
                                       '104',message4,
                                       '105',message5,
                                       '101',messagee) msg
                  into  v_msg
                  from  tfrmmail
                  where codform = 'HRRC2PB' ;
            exception when others then
              v_msg := null ;
            end ;  
            
            for r1 in c_treqest1 loop
                begin
                    select email
                      into v_email
                      from temploy1
                     where codempid = r1.codemprc;                
                exception when no_data_found then
                    v_email := null;
                end;
                
                if v_email is not null then
                    v_error := send_mail(v_email,v_msg);
                end if;
            end loop;
        end if;
        
        obj_main        := json_object_t();
        obj_main.put('coderror', '200'); 
        obj_main.put('response', hcm_util.get_string_t(json_object_t(get_response_message(null,get_error_msg_php('HR2715',global_v_lang),global_v_lang)),'response')); 
        obj_main.put('table', obj_row);
        json_str_output := obj_main.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end process_data;
  
  procedure insert_tapplinf(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    v_error         varchar2(4000 char);
    
    tmp_adrcontt    varchar2(4000);
    tmp_adrregt     varchar2(4000);
    tmp_codblood    varchar2(4000);
    tmp_codcntyc    varchar2(4000);
    tmp_codcntyi    varchar2(4000);
    tmp_coddistc    varchar2(4000);
    tmp_coddistr    varchar2(4000);
    tmp_codmedia    varchar2(4000);
    tmp_codnatnl    varchar2(4000);
    tmp_codorgin    varchar2(4000);
    tmp_codpos1     varchar2(4000);
    tmp_codpos2     varchar2(4000);
    tmp_codpostc    varchar2(4000);
    tmp_codpostr    varchar2(4000);
    tmp_codprovc    varchar2(4000);
    tmp_codprovr    varchar2(4000);
    tmp_codrelgn    varchar2(4000);
    tmp_codsex      varchar2(4000);
    tmp_codsubdistc varchar2(4000);
    tmp_codsubdistr varchar2(4000);
    tmp_codtitle    varchar2(4000);
    tmp_desdisp     varchar2(4000);
    tmp_dteappl     varchar2(4000);
    tmp_dtedisb     varchar2(4000);
    tmp_dtedisen    varchar2(4000);
    tmp_dteempdb    varchar2(4000);
    tmp_dtetrnsfer  varchar2(4000);
    tmp_email       varchar2(4000);
    tmp_flgcar      varchar2(4000);
    tmp_flgqualify  varchar2(4000);
    tmp_height      varchar2(4000);
    tmp_namfirste   varchar2(4000);
    tmp_namfirstt   varchar2(4000);
    tmp_namimage    varchar2(4000);
    tmp_namlaste    varchar2(4000);
    tmp_namlastt    varchar2(4000);
    tmp_numdisab    varchar2(4000);
    tmp_numoffid    varchar2(4000);
    tmp_numreql     varchar2(4000);
    tmp_numteleh    varchar2(4000);
    tmp_numtelehr   varchar2(4000);
    tmp_numtelem    varchar2(4000);
    tmp_numtelemr   varchar2(4000);
    tmp_stadisb     varchar2(4000);
    tmp_stamarry    varchar2(4000);
    tmp_stamilit    varchar2(4000);
    tmp_statappl    varchar2(4000);
    tmp_typdisp     varchar2(4000);
    tmp_weight      varchar2(4000); 
    
    v_tapplinf                  tapplinf%rowtype;
    parameter_groupid           varchar2(100);
    parameter_year              number;
    parameter_month             number;
    parameter_running           varchar2(100);
    v_table                     varchar2(10);
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;
    
    v_last_numappl          varchar2(100);
    v_num_appl              number;
    v_chk                   varchar2(1) := 'N';
    cursor c1 is 
      select numappl
        from tapplinf
      order by 1 desc;
    
    
    
  begin
    check_index;
    if param_msg_error is null then
        p_info                      := hcm_util.get_json_t(p_info,to_char(0));
        tmp_adrcontt                := hcm_util.get_string_t(p_info, 'adrcontt');
        tmp_adrregt                 := hcm_util.get_string_t(p_info, 'adrregt');
        tmp_codblood                := hcm_util.get_string_t(p_info, 'codblood');
        tmp_codcntyc                := hcm_util.get_string_t(p_info, 'codcntyc');
        tmp_codcntyi                := hcm_util.get_string_t(p_info, 'codcntyi');
        tmp_coddistc                := hcm_util.get_string_t(p_info, 'coddistc');
        tmp_coddistr                := hcm_util.get_string_t(p_info, 'coddistr');
        tmp_codmedia                := hcm_util.get_string_t(p_info, 'codmedia');
        tmp_codnatnl                := hcm_util.get_string_t(p_info, 'codnatnl');
        tmp_codorgin                := hcm_util.get_string_t(p_info, 'codorgin');
        tmp_codpos1                 := hcm_util.get_string_t(p_info, 'codpos1');
        tmp_codpos2                 := hcm_util.get_string_t(p_info, 'codpos2');
        tmp_codpostc                := hcm_util.get_string_t(p_info, 'codpostc');
        tmp_codpostr                := hcm_util.get_string_t(p_info, 'codpostr');
        tmp_codprovc                := hcm_util.get_string_t(p_info, 'codprovc');
        tmp_codprovr                := hcm_util.get_string_t(p_info, 'codprovr');
        tmp_codrelgn                := hcm_util.get_string_t(p_info, 'codrelgn');
        tmp_codsex                  := hcm_util.get_string_t(p_info, 'codsex');
        tmp_codsubdistc             := hcm_util.get_string_t(p_info, 'codsubdistc');
        tmp_codsubdistr             := hcm_util.get_string_t(p_info, 'codsubdistr');
        tmp_codtitle                := hcm_util.get_string_t(p_info, 'codtitle');
        tmp_desdisp                 := hcm_util.get_string_t(p_info, 'desdisp');
        tmp_dteappl                 := hcm_util.get_string_t(p_info, 'dteappl');
        tmp_dtedisb                 := hcm_util.get_string_t(p_info, 'dtedisb');
        tmp_dtedisen                := hcm_util.get_string_t(p_info, 'dtedisen');
        tmp_dteempdb                := hcm_util.get_string_t(p_info, 'dteempdb');
        tmp_dtetrnsfer              := hcm_util.get_string_t(p_info, 'dtetrnsfer');
        tmp_email                   := hcm_util.get_string_t(p_info, 'email');
        tmp_flgcar                  := hcm_util.get_string_t(p_info, 'flgcar');
        tmp_flgqualify              := hcm_util.get_string_t(p_info, 'flgqualify');
        tmp_height                  := hcm_util.get_string_t(p_info, 'height');
        tmp_namfirste               := hcm_util.get_string_t(p_info, 'namfirste');
        tmp_namfirstt               := hcm_util.get_string_t(p_info, 'namfirstt');
        tmp_namimage                := hcm_util.get_string_t(p_info, 'namimage');
        tmp_namlaste                := hcm_util.get_string_t(p_info, 'namlaste');
        tmp_namlastt                := hcm_util.get_string_t(p_info, 'namlastt');
        tmp_numdisab                := hcm_util.get_string_t(p_info, 'numdisab');
        tmp_numoffid                := replace(hcm_util.get_string_t(p_info, 'numoffid'),'''','');
        tmp_numreql                 := hcm_util.get_string_t(p_info, 'numreql');
        tmp_numteleh                := hcm_util.get_string_t(p_info, 'numteleh');
        tmp_numtelehr               := hcm_util.get_string_t(p_info, 'numtelehr');
        tmp_numtelem                := hcm_util.get_string_t(p_info, 'numtelem');
        tmp_numtelemr               := hcm_util.get_string_t(p_info, 'numtelemr');
        tmp_stadisb                 := hcm_util.get_string_t(p_info, 'stadisb');
        tmp_stamarry                := hcm_util.get_string_t(p_info, 'stamarry');
        tmp_stamilit                := hcm_util.get_string_t(p_info, 'stamilit');
        tmp_statappl                := hcm_util.get_string_t(p_info, 'statappl');
        tmp_typdisp                 := hcm_util.get_string_t(p_info, 'typdisp');
        tmp_weight                  := hcm_util.get_string_t(p_info, 'weight');

        check_error(tmp_adrcontt, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'ADRCONTT', 'TEXT', obj_response);
        check_error(tmp_adrregt, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'ADRREGT', 'TEXT', obj_response);
        check_error(tmp_codblood, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODBLOOD', 'TEXT', obj_response);
        check_error(tmp_codcntyc, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODCNTYC', 'TEXT', obj_response);
        check_error(tmp_codcntyi, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODCNTYI', 'TEXT', obj_response);
        check_error(tmp_coddistc, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODDISTC', 'TEXT', obj_response);
        check_error(tmp_coddistr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODDISTR', 'TEXT', obj_response);
        check_error(tmp_codmedia, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODMEDIA', 'TEXT', obj_response);
        check_error(tmp_codnatnl, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODNATNL', 'TEXT', obj_response);
        check_error(tmp_codorgin, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODORGIN', 'TEXT', obj_response);
        check_error(tmp_codpos1, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPOS1', 'TEXT', obj_response);
        check_error(tmp_codpos2, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPOS2', 'TEXT', obj_response);
        check_error(tmp_codpostc, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPOSTC', 'TEXT', obj_response);
        check_error(tmp_codpostr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPOSTE', 'NUMBER', obj_response);
        check_error(tmp_codprovc, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPROVC', 'TEXT', obj_response);
        check_error(tmp_codprovr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODPROVR', 'TEXT', obj_response);
        check_error(tmp_codrelgn, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODRELGN', 'TEXT', obj_response);
        check_error(tmp_codsex, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODSEX', 'TEXT', obj_response);
        check_error(tmp_codsubdistc, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODSUBDISTC', 'TEXT', obj_response);
        check_error(tmp_codsubdistr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODSUBDISTR', 'TEXT', obj_response);
        check_error(tmp_codtitle, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODTITLE', 'TEXT', obj_response);
        check_error(tmp_desdisp, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DESDISP', 'TEXT', obj_response);
        check_error(tmp_dteappl, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DTEAPPL', 'DATE', obj_response);
        check_error(tmp_dtedisb, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DTEDISB', 'DATE', obj_response);
        check_error(tmp_dtedisen, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DTEDISEN', 'DATE', obj_response);
        check_error(tmp_dteempdb, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DTEEMPDB', 'DATE', obj_response);
        check_error(tmp_dtetrnsfer, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'DTETRNJO', 'DATE', obj_response);
        check_error(tmp_email, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'EMAIL', 'TEXT', obj_response);
        check_error(tmp_flgcar, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'FLGCAR', 'FLG', obj_response);
        check_error(tmp_flgqualify, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'FLGQUALIFY', 'FLG', obj_response);
        check_error(tmp_height, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'HEIGHT', 'NUMBER', obj_response);
        check_error(tmp_namfirste, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NAMFIRSTE', 'TEXT', obj_response);
        check_error(tmp_namfirstt, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NAMFIRSTT', 'TEXT', obj_response);
        check_error(tmp_namimage, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NAMIMAGE', 'TEXT', obj_response);
        check_error(tmp_namlaste, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NAMLASTE', 'TEXT', obj_response);
        check_error(tmp_namlastt, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NAMLASTT', 'TEXT', obj_response);
        check_error(tmp_numdisab, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMDISAB', 'TEXT', obj_response);
        check_error(tmp_numoffid, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMOFFID', 'NUMOFFID', obj_response);
        check_error(tmp_numreql, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMREQL', 'NUMREQL', obj_response);
        check_error(tmp_numteleh, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMTELEH', 'TEXT', obj_response);
        check_error(tmp_numtelehr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMTELEHR', 'TEXT', obj_response);
        check_error(tmp_numtelem, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMTELEM', 'TEXT', obj_response);
        check_error(tmp_numtelemr, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'NUMTELEMR', 'TEXT', obj_response);
        check_error(tmp_stadisb, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'STADISB', 'FLG', obj_response);
        check_error(tmp_stamarry, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'STAMARRY', 'TEXT', obj_response);
        check_error(tmp_stamilit, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'STAMILIT', 'TEXT', obj_response);
        check_error(tmp_statappl, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'STATAPPL', 'TEXT', obj_response);
        check_error(tmp_typdisp, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'TYPDISP', 'TEXT', obj_response);
        check_error(tmp_weight, 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'WEIGHT', 'NUMBER', obj_response);
    end if;
    
    if v_num_error_row = 0 then
        v_tapplinf.dteappl          := to_date(tmp_dteappl,'dd/mm/yyyy');
        v_tapplinf.codposl          := tmp_codpos1;
        v_tapplinf.codpos1          := tmp_codpos1;
        v_tapplinf.codpos2          := tmp_codpos2;
        v_tapplinf.numreql          := tmp_numreql;
        v_tapplinf.statappl         := tmp_statappl;
        v_tapplinf.flgqualify       := tmp_flgqualify;
        v_tapplinf.dtetrnjo         := to_date(tmp_dtetrnsfer,'dd/mm/yyyy');
        v_tapplinf.namimage         := tmp_namimage;
        v_tapplinf.codtitle         := tmp_codtitle;
        v_tapplinf.namfirste        := tmp_namfirste;
        v_tapplinf.namlaste         := tmp_namlaste;
        v_tapplinf.namfirstt        := tmp_namfirstt;
        v_tapplinf.namlastt         := tmp_namlastt;
        v_tapplinf.namfirst3        := tmp_namfirste;
        v_tapplinf.namlast3         := tmp_namlaste;
        v_tapplinf.namfirst4        := tmp_namfirste;
        v_tapplinf.namlast4         := tmp_namlaste;
        v_tapplinf.namfirst5        := tmp_namfirste;
        v_tapplinf.namlast5         := tmp_namlaste;
        v_tapplinf.dteempdb         := to_date(tmp_dteempdb,'dd/mm/yyyy');
        v_tapplinf.codsex           := tmp_codsex;
        v_tapplinf.numoffid         := tmp_numoffid;
        v_tapplinf.stamarry         := tmp_stamarry;
        v_tapplinf.stamilit         := tmp_stamilit;
        v_tapplinf.codblood         := tmp_codblood;
        v_tapplinf.weight           := tmp_weight;
        v_tapplinf.height           := tmp_height;
        v_tapplinf.codrelgn         := tmp_codrelgn;
        v_tapplinf.codnatnl         := tmp_codnatnl;
        v_tapplinf.codorgin         := tmp_codorgin;
        v_tapplinf.codmedia         := tmp_codmedia;
        v_tapplinf.flgcar           := tmp_flgcar;
        v_tapplinf.adrcontt         := tmp_adrcontt;
        v_tapplinf.codcntyc         := tmp_codcntyc;
        v_tapplinf.codprovc         := tmp_codprovc;
        v_tapplinf.coddistc         := tmp_coddistc;
        v_tapplinf.codsubdistc      := tmp_codsubdistc;
        v_tapplinf.codpostc         := tmp_codpostc;
        v_tapplinf.numtelem         := tmp_numtelem;
        v_tapplinf.numteleh         := tmp_numteleh;
        v_tapplinf.email            := tmp_email;
        v_tapplinf.adrregt          := tmp_adrregt;
        v_tapplinf.codcntyi         := tmp_codcntyi;
        v_tapplinf.codprovr         := tmp_codprovr;
        v_tapplinf.coddistr         := tmp_coddistr;
        v_tapplinf.codsubdistr      := tmp_codsubdistr;
        v_tapplinf.codposte         := tmp_codpostr;
        v_tapplinf.numtelemr        := tmp_numtelemr;
        v_tapplinf.numtelehr        := tmp_numtelehr;
        v_tapplinf.stadisb          := tmp_stadisb;
        v_tapplinf.numdisab         := tmp_numdisab;
        v_tapplinf.typdisp          := tmp_typdisp;
        v_tapplinf.dtedisb          := to_date(tmp_dtedisb,'dd/mm/yyyy');
        v_tapplinf.dtedisen         := to_date(tmp_dtedisen,'dd/mm/yyyy');
        v_tapplinf.desdisp          := tmp_desdisp;
        
        v_tapplinf.namempe          := get_tlistval_name('CODTITLE',tmp_codtitle,'101')||tmp_namfirste||' '||tmp_namlaste;
        v_tapplinf.namempt          := get_tlistval_name('CODTITLE',tmp_codtitle,'102')||tmp_namfirstt||' '||tmp_namlastt;
        v_tapplinf.namemp3          := v_tapplinf.namempe;
        v_tapplinf.namemp4          := v_tapplinf.namempe;
        v_tapplinf.namemp5          := v_tapplinf.namempe;
        v_tapplinf.adrconte         := tmp_adrcontt;
        v_tapplinf.adrcont3         := tmp_adrcontt;
        v_tapplinf.adrcont4         := tmp_adrcontt;
        v_tapplinf.adrcont5         := tmp_adrcontt;
        v_tapplinf.adrrege          := tmp_adrregt;
        v_tapplinf.adrreg3          := tmp_adrregt;
        v_tapplinf.adrreg4          := tmp_adrregt;
        v_tapplinf.adrreg5          := tmp_adrregt;
        
        begin
            select codcomp
              into v_tapplinf.codcompl
              from treqest2
             where numreqst = v_tapplinf.numreql
               and codpos = v_tapplinf.codpos1;        
        exception when no_data_found then
            v_tapplinf.codcompl := '';
        end;
        
        select count(*)
          into v_count_tapplinf
          from tapplinf
         where numoffid = v_tapplinf.numoffid
           and numreql = v_tapplinf.numreql;
        
        if v_count_tapplinf = 0 then
           
          --gen numappl
          for i in c1 loop
            begin
              v_num_appl    := to_number(i.numappl);
              if substr(nvl(v_num_appl,'XX'),1,2) <> to_char(sysdate,'yy') then
                v_num_appl    := 1;
              else
                v_num_appl    := to_number(substr(v_num_appl,-8));
              end if;
              v_last_numappl  := to_char(sysdate,'yy')||lpad(v_num_appl,8,'0');
              exit;
            exception when others then
              null;
            end;
          end loop;
          v_last_numappl  := nvl(v_last_numappl,to_char(sysdate,'yy')||'00000001');
          for i in 1..100 loop
            begin
              select 'Y'
                into v_chk
                from tapplinf
               where numappl  = v_last_numappl;
              v_last_numappl  := to_number(v_last_numappl) + 1;
            exception when no_data_found then
              p_numappl := v_last_numappl;
              exit;
            end;
          end loop;            
            
            begin
                insert into tapplinf(numappl,dteappl,codpos1,codpos2,numreql,statappl,flgqualify,
                                     dtetrnjo,namimage,codtitle,namfirste,namlaste,
                                     namfirstt,namlastt,dteempdb,codsex,numoffid,stamarry,stamilit,
                                     codblood,weight,height,codrelgn,codnatnl,codorgin,codmedia,flgcar,
                                     adrcontt,codcntyc,codprovc,coddistc,codsubdistc,codpostc,
                                     numtelem,numteleh,email,adrregt,codcntyi,codprovr,coddistr,
                                     codsubdistr,codposte,numtelemr,numtelehr,stadisb,numdisab,
                                     typdisp,dtedisb,dtedisen,desdisp,codposl,codcompl,
                                     namfirst3,namfirst4,namfirst5,
                                     namlast3,namlast4,namlast5,
                                     namempe,namempt,namemp3,namemp4,namemp5,
                                     adrconte,adrcont3,adrcont4,adrcont5,
                                     adrrege,adrreg3,adrreg4,adrreg5
                                     )
                values ( p_numappl,v_tapplinf.dteappl,v_tapplinf.codpos1,v_tapplinf.codpos2,v_tapplinf.numreql,v_tapplinf.statappl,v_tapplinf.flgqualify,
                         v_tapplinf.dtetrnjo,v_tapplinf.namimage,v_tapplinf.codtitle,v_tapplinf.namfirste,v_tapplinf.namlaste,
                         v_tapplinf.namfirstt,v_tapplinf.namlastt,v_tapplinf.dteempdb,v_tapplinf.codsex,v_tapplinf.numoffid,v_tapplinf.stamarry,v_tapplinf.stamilit,
                         v_tapplinf.codblood,v_tapplinf.weight,v_tapplinf.height,v_tapplinf.codrelgn,v_tapplinf.codnatnl,v_tapplinf.codorgin,v_tapplinf.codmedia,v_tapplinf.flgcar,
                         v_tapplinf.adrcontt,v_tapplinf.codcntyc,v_tapplinf.codprovc,v_tapplinf.coddistc,v_tapplinf.codsubdistc,v_tapplinf.codpostc,
                         v_tapplinf.numtelem,v_tapplinf.numteleh,v_tapplinf.email,v_tapplinf.adrregt,v_tapplinf.codcntyi,v_tapplinf.codprovr,v_tapplinf.coddistr,
                         v_tapplinf.codsubdistr,v_tapplinf.codposte,v_tapplinf.numtelemr,v_tapplinf.numtelehr,v_tapplinf.stadisb,v_tapplinf.numdisab,
                         v_tapplinf.typdisp,v_tapplinf.dtedisb,v_tapplinf.dtedisen,v_tapplinf.desdisp,v_tapplinf.codposl,v_tapplinf.codcompl,
                         v_tapplinf.namfirst3,v_tapplinf.namfirst4,v_tapplinf.namfirst5,
                         v_tapplinf.namlast3,v_tapplinf.namlast4,v_tapplinf.namlast5,
                         v_tapplinf.namempe,v_tapplinf.namempt,v_tapplinf.namemp3,v_tapplinf.namemp4,v_tapplinf.namemp5,
                         v_tapplinf.adrconte,v_tapplinf.adrcont3,v_tapplinf.adrcont4,v_tapplinf.adrcont5,
                         v_tapplinf.adrrege,v_tapplinf.adrreg3,v_tapplinf.adrreg4,v_tapplinf.adrreg5);
            
                insert into tappfoll (numappl,dtefoll,statappl,codrej,
                                      remark,codappr,numreqst,codpos,
                                      dtecreate,codcreate,dteupd,coduser)   
                values (p_numappl,v_tapplinf.dtetrnjo,v_tapplinf.statappl,null,
                                      null,null,v_tapplinf.numreql,v_tapplinf.codpos1,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
                v_num_complete_all                  := v_num_complete_all + 1;
            exception when others then
                v_num_error_all := v_num_error_all + 1;
            end;
        else
            begin
              select numappl
                into p_numappl
                from tapplinf
               where numoffid = v_tapplinf.numoffid
                 and dteappl = (select max(dteappl) 
                                  from tapplinf
                                 where numoffid = v_tapplinf.numoffid);            
            exception when others then null; end;

            v_num_complete_all                  := v_num_complete_all + 1;
        end if;
    else
        v_num_error_all := v_num_error_all + 1;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapplinf;

  procedure insert_teducatn(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row  json_object_t;
    
    tmp_codcount                varchar2(4000); 
    tmp_coddglv                 varchar2(4000); 
    tmp_codedlv                 varchar2(4000); 
    tmp_codinst                 varchar2(4000); 
    tmp_codmajsb                varchar2(4000); 
    tmp_codminsb                varchar2(4000); 
    tmp_dtegyear                varchar2(4000); 
    tmp_numgpa                  varchar2(4000); 
    tmp_numseq                  varchar2(4000); 
    tmp_stayear                 varchar2(4000); 
    
    v_teducatn                  teducatn%rowtype;
    
    max_dtegyear                number;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;
  begin
--    if v_count_tapplinf = 0 then
        delete teducatn 
         where numappl = p_numappl;
        
        for i in 0..p_edu.get_size-1 loop 
            v_num_error_row := 0;
            param_json_row              := hcm_util.get_json_t(p_edu,to_char(i));
            tmp_codcount                := hcm_util.get_string_t(param_json_row, 'codcount');
            tmp_coddglv                 := hcm_util.get_string_t(param_json_row, 'coddglv');
            tmp_codedlv                 := hcm_util.get_string_t(param_json_row, 'codedlv');
            tmp_codinst                 := hcm_util.get_string_t(param_json_row, 'codinst');
            tmp_codmajsb                := hcm_util.get_string_t(param_json_row, 'codmajsb');
            tmp_codminsb                := hcm_util.get_string_t(param_json_row, 'codminsb');
            tmp_dtegyear                := hcm_util.get_string_t(param_json_row, 'dtegyear');
            tmp_numgpa                  := hcm_util.get_string_t(param_json_row, 'numgpa');
            tmp_numseq                  := hcm_util.get_string_t(param_json_row, 'numseq');
            tmp_stayear                 := hcm_util.get_string_t(param_json_row, 'stayear');  

            check_error(tmp_codcount, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODCOUNT', 'TEXT', obj_response);
            check_error(tmp_coddglv, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODDGLV', 'TEXT', obj_response);
            check_error(tmp_codedlv, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODEDLV', 'TEXT', obj_response);
            check_error(tmp_codinst, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODINST', 'TEXT', obj_response);
            check_error(tmp_codmajsb, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODMAJSB', 'TEXT', obj_response);
            check_error(tmp_codminsb, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'CODMINSB', 'TEXT', obj_response);
            check_error(tmp_dtegyear, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'DTEGYEAR', 'NUMBER', obj_response);
            check_error(tmp_numgpa, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'NUMGPA', 'NUMBER', obj_response);
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'NUMSEQ', 'NUMBER', obj_response);
            check_error(tmp_stayear, i + 1, v_rcnt, v_num_error_row , 'TEDUCATN', 'STAYEAR', 'NUMBER', obj_response);
            
            if v_num_error_row = 0 then
                v_teducatn.codcount         := tmp_codcount;
                v_teducatn.coddglv          := tmp_coddglv;
                v_teducatn.codedlv          := tmp_codedlv;
                v_teducatn.codinst          := tmp_codinst;
                v_teducatn.codmajsb         := tmp_codmajsb;
                v_teducatn.codminsb         := tmp_codminsb;
                v_teducatn.dtegyear         := tmp_dtegyear;
                v_teducatn.numgpa           := tmp_numgpa;
                v_teducatn.numseq           := tmp_numseq;
                v_teducatn.stayear          := tmp_stayear;  
                
                begin
                    insert into teducatn(numappl,numseq,codempid,codedlv,coddglv,
                                         codmajsb,codminsb,codinst,codcount,
                                         numgpa,stayear,dtegyear,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_teducatn.numseq,null,v_teducatn.codedlv,v_teducatn.coddglv,
                             v_teducatn.codmajsb,v_teducatn.codminsb,v_teducatn.codinst,v_teducatn.codcount,
                             v_teducatn.numgpa,v_teducatn.stayear,v_teducatn.dtegyear,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
        
        select max(dtegyear)
          into max_dtegyear
          from teducatn
         where numappl = p_numappl;
         
        update teducatn  
           set flgeduc = decode(dtegyear,max_dtegyear,'1','2')
         where numappl = p_numappl;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_teducatn;
  
  procedure insert_tapplwex(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row  json_object_t;
    
    tmp_amtincom                varchar2(4000); 
    tmp_codcurr                 varchar2(4000); 
    tmp_desjob                  varchar2(4000); 
    tmp_deslstjob1              varchar2(4000); 
    tmp_deslstpos               varchar2(4000); 
    tmp_desnoffi                varchar2(4000); 
    tmp_dteend                  varchar2(4000); 
    tmp_dtestart                varchar2(4000); 
    tmp_numseq                  varchar2(4000); 
    
    v_tapplwex                  tapplwex%rowtype;
    v_tapplinf                  tapplinf%rowtype;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;
  begin
--    if v_count_tapplinf = 0 then
        delete tapplwex 
         where numappl = p_numappl;
        
        for i in 0..p_exp.get_size-1 loop 
            v_num_error_row             := 0;
            param_json_row              := hcm_util.get_json_t(p_exp,to_char(i));
            tmp_amtincom                := hcm_util.get_string_t(param_json_row, 'amtincom');
            tmp_codcurr                 := hcm_util.get_string_t(param_json_row, 'codcurr');
            tmp_desjob                  := hcm_util.get_string_t(param_json_row, 'desjob');
            tmp_deslstjob1              := hcm_util.get_string_t(param_json_row, 'deslstjob1');
            tmp_deslstpos               := hcm_util.get_string_t(param_json_row, 'deslstpos');
            tmp_desnoffi                := hcm_util.get_string_t(param_json_row, 'desnoffi');
            tmp_dteend                  := hcm_util.get_string_t(param_json_row, 'dteend');
            tmp_dtestart                := hcm_util.get_string_t(param_json_row, 'dtestart');
            tmp_numseq                  := hcm_util.get_string_t(param_json_row, 'numseq');

            check_error(tmp_amtincom, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'AMTINCOM', 'NUMBER', obj_response);
            check_error(tmp_codcurr, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'CODCURR', 'TEXT', obj_response);
            check_error(tmp_desjob, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DESJOB', 'TEXT', obj_response);
            check_error(tmp_deslstjob1, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DESLSTJOB1', 'TEXT', obj_response);
            check_error(tmp_deslstpos, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DESLSTPOS', 'TEXT', obj_response);
            check_error(tmp_desnoffi, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DESNOFFI', 'TEXT', obj_response);
            check_error(tmp_dteend, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DTEEND', 'DATE', obj_response);
            check_error(tmp_dtestart, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'DTESTART', 'DATE', obj_response);
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TAPPLWEX', 'NUMSEQ', 'NUMBER', obj_response);
            
            if v_num_error_row = 0 then
                v_tapplwex.amtincom         := stdenc(tmp_amtincom,p_numappl,v_chken);
                v_tapplwex.desjob           := tmp_desjob;
                v_tapplwex.deslstjob1       := tmp_deslstjob1;
                v_tapplwex.deslstpos        := tmp_deslstpos;
                v_tapplwex.desnoffi         := tmp_desnoffi;
                v_tapplwex.dteend           := to_date(tmp_dteend,'dd/mm/yyyy');
                v_tapplwex.dtestart         := to_date(tmp_dtestart,'dd/mm/yyyy');
                v_tapplwex.numseq           := tmp_numseq;
                v_tapplinf.codcurr          := tmp_codcurr;
                begin
                    insert into tapplwex(numappl,numseq,codempid,desnoffi,deslstjob1,
                                         deslstpos,desoffi1,numteleo,namboss,
                                         desres,amtincom,dtestart,dteend,
                                         codtypwrk,desjob,desrisk,desprotc,remark,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tapplwex.numseq,null,v_tapplwex.desnoffi,v_tapplwex.deslstjob1,
                             v_tapplwex.deslstpos,null,null,null,
                             null,v_tapplwex.amtincom,v_tapplwex.dtestart,v_tapplwex.dteend,
                             null,v_tapplwex.desjob,null,null,null,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                             
                    update tapplinf 
                       set codcurr = v_tapplinf.codcurr
                     where numappl = p_numappl;
                     
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapplwex;
    
  procedure insert_ttrainbf(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row              json_object_t;
   
    tmp_desinstu                varchar2(4000); 
    tmp_desplace                varchar2(4000); 
    tmp_destrain                varchar2(4000); 
    tmp_dtetrain                varchar2(4000); 
    tmp_dtetren                 varchar2(4000); 
    tmp_numseq                  varchar2(4000); 
    
    v_ttrainbf                  ttrainbf%rowtype;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;

  begin
--    if v_count_tapplinf = 0 then
        delete ttrainbf 
         where numappl = p_numappl;
        
        for i in 0..p_train.get_size-1 loop 
            v_num_error_row             := 0;
            param_json_row              := hcm_util.get_json_t(p_train,to_char(i));
            tmp_desinstu                := hcm_util.get_string_t(param_json_row, 'desinstu');
            tmp_desplace                := hcm_util.get_string_t(param_json_row, 'desplace');
            tmp_destrain                := hcm_util.get_string_t(param_json_row, 'destrain');
            tmp_dtetrain                := hcm_util.get_string_t(param_json_row, 'dtetrain');
            tmp_dtetren                 := hcm_util.get_string_t(param_json_row, 'dtetren');
            tmp_numseq                  := hcm_util.get_string_t(param_json_row, 'numseq');

            check_error(tmp_desinstu, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'DESINSTU', 'TEXT', obj_response);
            check_error(tmp_desplace, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'DESPLACE', 'TEXT', obj_response);
            check_error(tmp_destrain, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'DESTRAIN', 'TEXT', obj_response);
            check_error(tmp_dtetrain, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'DTETRAIN', 'DATE', obj_response);
            check_error(tmp_dtetren, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'DTETREN', 'DATE', obj_response);
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TTRAINBF', 'NUMSEQ', 'NUMBER', obj_response);
            
            if v_num_error_row = 0 then
                v_ttrainbf.desinstu         := tmp_desinstu;
                v_ttrainbf.desplace         := tmp_desplace;
                v_ttrainbf.destrain         := tmp_destrain;
                v_ttrainbf.dtetrain         := to_date(tmp_dtetrain,'dd/mm/yyyy');
                v_ttrainbf.dtetren          := to_date(tmp_dtetren,'dd/mm/yyyy');
                v_ttrainbf.numseq           := tmp_numseq;
                
                begin
                    insert into ttrainbf(numappl,numseq,codempid,destrain,dtetrain,
                                         dtetren,desplace,desinstu,filedoc,numrefdoc,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_ttrainbf.numseq,null,v_ttrainbf.destrain,v_ttrainbf.dtetrain,
                             v_ttrainbf.dtetren,v_ttrainbf.desplace,v_ttrainbf.desinstu,null,null,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_ttrainbf;
   
  procedure insert_tapploth(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row  json_object_t;
    
    tmp_codlocat                varchar2(4000); 
    tmp_dtewkst                 varchar2(4000); 
    tmp_flgoversea              varchar2(4000); 
    tmp_flgprov                 varchar2(4000); 
    tmp_flgstrwk                varchar2(4000); 
    tmp_jobdesc                 varchar2(4000); 
    tmp_qtydayst                varchar2(4000); 
    tmp_reason                  varchar2(4000); 
        
    v_tapploth                  tapploth%rowtype;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;
  begin
--    if v_count_tapplinf = 0 then
        for i in 0..p_emppref.get_size-1 loop 
            v_num_error_row             := 0;
            param_json_row              := hcm_util.get_json_t(p_emppref,to_char(i));
            tmp_codlocat                := hcm_util.get_string_t(param_json_row, 'codlocat');
            tmp_dtewkst                 := hcm_util.get_string_t(param_json_row, 'dtewkst');
            tmp_flgoversea              := hcm_util.get_string_t(param_json_row, 'flgoversea');
            tmp_flgprov                 := hcm_util.get_string_t(param_json_row, 'flgprov');
            tmp_flgstrwk                := hcm_util.get_string_t(param_json_row, 'flgstrwk');
            tmp_jobdesc                 := hcm_util.get_string_t(param_json_row, 'jobdesc');
            tmp_qtydayst                := hcm_util.get_string_t(param_json_row, 'qtydayst');
            tmp_reason                  := hcm_util.get_string_t(param_json_row, 'reason');
            
            check_error(tmp_codlocat, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'CODLOCAT', 'TEXT', obj_response);
            check_error(tmp_dtewkst, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DTEWKST', 'DATE', obj_response);
            check_error(tmp_flgoversea, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGOVERSEA', 'FLG', obj_response);
            check_error(tmp_flgprov, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGPROV', 'FLG', obj_response);
            check_error(tmp_flgstrwk, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGSTRWK', 'TEXT', obj_response);
            check_error(tmp_jobdesc, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'JOBDESC', 'TEXT', obj_response);
            check_error(tmp_qtydayst, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'QTYDAYST', 'NUMBER', obj_response);
            check_error(tmp_reason, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'REASON', 'TEXT', obj_response);            
            
            if v_num_error_row = 0 then
                v_tapploth.codlocat         := tmp_codlocat;
                v_tapploth.dtewkst          := tmp_dtewkst;
                v_tapploth.flgoversea       := tmp_flgoversea;
                v_tapploth.flgprov          := tmp_flgprov;
                v_tapploth.flgstrwk         := tmp_flgstrwk;
                v_tapploth.jobdesc          := tmp_jobdesc;
                v_tapploth.qtydayst         := tmp_qtydayst;
                v_tapploth.reason           := tmp_reason;
                
                begin
                    insert into tapploth(numappl,reason,jobdesc,codlocat,flgprov,
                                         flgoversea,flgstrwk,dtewkst,qtydayst,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tapploth.reason,v_tapploth.jobdesc,v_tapploth.codlocat,v_tapploth.flgprov,
                             v_tapploth.flgoversea,v_tapploth.flgstrwk,v_tapploth.dtewkst,v_tapploth.qtydayst,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);                
                exception when dup_val_on_index then
                    update tapploth
                       set reason = v_tapploth.reason,
                           jobdesc = v_tapploth.jobdesc,
                           codlocat = v_tapploth.codlocat,
                           flgprov = v_tapploth.flgprov,
                           flgoversea = v_tapploth.flgoversea,
                           flgstrwk = v_tapploth.flgstrwk,
                           dtewkst = v_tapploth.dtewkst,
                           qtydayst = v_tapploth.qtydayst,
                           coduser = global_v_coduser,
                           dteupd = sysdate
                     where numappl = p_numappl;
                when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapploth;

  procedure insert_tapplfm(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row              json_object_t;
    
    tmp_codspocc                varchar2(4000); 
    tmp_codtitle                varchar2(4000); 
    tmp_desnoffi                varchar2(4000); 
    tmp_namfirst                varchar2(4000); 
    tmp_namlast                 varchar2(4000); 
    tmp_numoffid                varchar2(4000); 
    tmp_stalife                 varchar2(4000); 
    
    v_tapplfm                   tapplfm%rowtype;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;

  begin
--    if v_count_tapplinf = 0 then
        delete tapplfm 
         where numappl = p_numappl;
        
        for i in 0..p_spouse.get_size-1 loop
            v_num_error_row             := 0; 
            param_json_row              := hcm_util.get_json_t(p_spouse,to_char(i));
            tmp_codspocc                := hcm_util.get_string_t(param_json_row, 'codspocc');
            tmp_codtitle                := hcm_util.get_string_t(param_json_row, 'codtitle');
            tmp_desnoffi                := hcm_util.get_string_t(param_json_row, 'desnoffi');
            tmp_namfirst                := hcm_util.get_string_t(param_json_row, 'namfirst');
            tmp_namlast                 := hcm_util.get_string_t(param_json_row, 'namlast');
            tmp_numoffid                := hcm_util.get_string_t(param_json_row, 'numoffid');
            tmp_stalife                 := hcm_util.get_string_t(param_json_row, 'stalife');

            check_error(tmp_codspocc, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'CODSPOCC', 'TEXT', obj_response);
            check_error(tmp_codtitle, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'CODTITLE', 'TEXT', obj_response);
            check_error(tmp_desnoffi, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'DESNOFFI', 'TEXT', obj_response);
            check_error(tmp_namfirst, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'NAMFIRST', 'TEXT', obj_response);
            check_error(tmp_namlast, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'NAMLAST', 'TEXT', obj_response);
            check_error(tmp_numoffid, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'NUMOFFID', 'TEXT', obj_response);
            check_error(tmp_stalife, i + 1, v_rcnt, v_num_error_row , 'TAPPLFM', 'STALIFE', 'FLG', obj_response);
            
            if v_num_error_row = 0 then
                v_tapplfm.codspocc          := tmp_codspocc;
                v_tapplfm.codtitle          := tmp_codtitle;
                v_tapplfm.desnoffi          := tmp_desnoffi;
                v_tapplfm.namfirst          := tmp_namfirst;
                v_tapplfm.namlast           := tmp_namlast;
                v_tapplfm.numoffid          := tmp_numoffid;
                v_tapplfm.stalife           := tmp_stalife;
                
                begin
                    insert into tapplfm(numappl,codtitle,namfirst,namlast,namsp,
                                        numoffid,stalife,codspocc,desnoffi,
                                        dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tapplfm.codtitle,v_tapplfm.namfirst,v_tapplfm.namlast,get_tlistval_name('CODTITLE',v_tapplfm.codtitle,'102')||' '||v_tapplfm.namfirst||' '||v_tapplfm.namlast,
                             v_tapplfm.numoffid,v_tapplfm.stalife,v_tapplfm.codspocc,v_tapplfm.desnoffi,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapplfm;   
  
  procedure insert_tapplrel(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row              json_object_t;
    
    tmp_adrcomt                 varchar2(4000); 
    tmp_namrel                  varchar2(4000); 
    tmp_numseq                  varchar2(4000); 
    tmp_numtelec                varchar2(4000); 
        
    v_tapplrel                  tapplrel%rowtype;
    
    v_num_error_row             number := 0;
    v_rcnt                      number := 0;

  begin
--    if v_count_tapplinf = 0 then
        delete tapplrel 
         where numappl = p_numappl;
        
        for i in 0..p_rel.get_size-1 loop 
            v_num_error_row             := 0; 
            param_json_row              := hcm_util.get_json_t(p_rel,to_char(i));
            tmp_adrcomt                 := hcm_util.get_string_t(param_json_row, 'adrcomt');
            tmp_namrel                  := hcm_util.get_string_t(param_json_row, 'namrel');
            tmp_numseq                  := hcm_util.get_string_t(param_json_row, 'numseq');
            tmp_numtelec                := hcm_util.get_string_t(param_json_row, 'numtelec');

            check_error(tmp_adrcomt, i + 1, v_rcnt, v_num_error_row , 'TAPPLREL', 'ADRCOMT', 'TEXT', obj_response);
            check_error(tmp_namrel, i + 1, v_rcnt, v_num_error_row , 'TAPPLREL', 'NAMREL', 'TEXT', obj_response);
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TAPPLREL', 'NUMSEQ', 'NUMBER', obj_response);
            check_error(tmp_numtelec, i + 1, v_rcnt, v_num_error_row , 'TAPPLREL', 'NUMTELEC', 'TEXT', obj_response);
            
            if v_num_error_row = 0 then
                v_tapplrel.adrcomt          := tmp_adrcomt;
                v_tapplrel.namrel           := tmp_namrel;
                v_tapplrel.numseq           := tmp_numseq;
                v_tapplrel.numtelec         := tmp_numtelec;
                begin
                    insert into tapplrel(numappl,numseq,codemprl,namrel,numtelec,adrcomt,
                                        dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tapplrel.numseq,null,v_tapplrel.namrel,v_tapplrel.numtelec,v_tapplrel.adrcomt,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapplrel;     
  
  procedure insert_tapplref(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row                  json_object_t;
    
    tmp_adrcont1                    varchar2(4000); 
    tmp_codtitle                    varchar2(4000); 
    tmp_desnoffi                    varchar2(4000); 
    tmp_despos                      varchar2(4000); 
    tmp_email                       varchar2(4000); 
    tmp_flgref                      varchar2(4000); 
    tmp_namfirste                   varchar2(4000); 
    tmp_namfirstt                   varchar2(4000); 
    tmp_namlaste                    varchar2(4000); 
    tmp_namlastt                    varchar2(4000); 
    tmp_numseq                      varchar2(4000); 
    tmp_numtele                     varchar2(4000); 
        
    v_tapplref                      tapplref%rowtype;
    
    v_num_error_row                 number := 0;
    v_rcnt                          number := 0;

  begin
--    if v_count_tapplinf = 0 then
        delete tapplref 
         where numappl = p_numappl;
        
        for i in 0..p_ref.get_size-1 loop 
            v_num_error_row                 := 0; 
            param_json_row                  := hcm_util.get_json_t(p_ref,to_char(i));
            tmp_adrcont1                    := hcm_util.get_string_t(param_json_row, 'adrcont1');
            tmp_codtitle                    := hcm_util.get_string_t(param_json_row, 'codtitle');
            tmp_desnoffi                    := hcm_util.get_string_t(param_json_row, 'desnoffi');
            tmp_despos                      := hcm_util.get_string_t(param_json_row, 'despos');
            tmp_email                       := hcm_util.get_string_t(param_json_row, 'email');
            tmp_flgref                      := hcm_util.get_string_t(param_json_row, 'flgref');
            tmp_namfirste                   := hcm_util.get_string_t(param_json_row, 'namfirste');
            tmp_namfirstt                   := hcm_util.get_string_t(param_json_row, 'namfirstt');
            tmp_namlaste                    := hcm_util.get_string_t(param_json_row, 'namlaste');
            tmp_namlastt                    := hcm_util.get_string_t(param_json_row, 'namlastt');
            tmp_numseq                      := hcm_util.get_string_t(param_json_row, 'numseq');
            tmp_numtele                     := hcm_util.get_string_t(param_json_row, 'numtele');

            check_error(tmp_adrcont1, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'ADRCONT1', 'TEXT', obj_response);
            check_error(tmp_codtitle, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'CODTITLE', 'TEXT', obj_response);
            check_error(tmp_desnoffi, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'DESNOFFI', 'TEXT', obj_response);
            check_error(tmp_despos, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'DESPOS', 'TEXT', obj_response);
            check_error(tmp_email, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'EMAIL', 'TEXT', obj_response);
            check_error(tmp_flgref, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'FLGREF', 'TEXT', obj_response);
            check_error(tmp_namfirste, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NAMFIRSTE', 'TEXT', obj_response);
            check_error(tmp_namfirstt, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NAMFIRSTT', 'TEXT', obj_response);
            check_error(tmp_namlaste, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NAMLASTE', 'TEXT', obj_response);
            check_error(tmp_namlastt, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NAMLASTT', 'TEXT', obj_response);
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NUMSEQ', 'NUMBER', obj_response);
            check_error(tmp_numtele, i + 1, v_rcnt, v_num_error_row , 'TAPPLREF', 'NUMTELE', 'TEXT', obj_response);

            if v_num_error_row = 0 then
                v_tapplref.adrcont1             := tmp_adrcont1;
                v_tapplref.codtitle             := tmp_codtitle;
                v_tapplref.desnoffi             := tmp_desnoffi;
                v_tapplref.despos               := tmp_despos;
                v_tapplref.email                := tmp_email;
                v_tapplref.flgref               := tmp_flgref;
                v_tapplref.namfirste            := tmp_namfirste;
                v_tapplref.namfirstt            := tmp_namfirstt;
                v_tapplref.namlaste             := tmp_namlaste;
                v_tapplref.namlastt             := tmp_namlastt;
                v_tapplref.numseq               := tmp_numseq;
                v_tapplref.numtele              := tmp_numtele;
                
                v_tapplref.namfirst3            := tmp_namfirste;
                v_tapplref.namfirst4            := tmp_namfirste;
                v_tapplref.namfirst5            := tmp_namfirste;
                v_tapplref.namlast3             := tmp_namlaste;
                v_tapplref.namlast4             := tmp_namlaste;
                v_tapplref.namlast5             := tmp_namlaste;
                v_tapplref.namrefe              := get_tlistval_name('CODTITLE',tmp_codtitle,'101')||' '||tmp_namfirste||' '||tmp_namlaste;
                v_tapplref.namreft              := get_tlistval_name('CODTITLE',tmp_codtitle,'102')||' '||tmp_namfirstt||' '||tmp_namlastt;
                v_tapplref.namref3              := v_tapplref.namrefe;
                v_tapplref.namref4              := v_tapplref.namrefe;
                v_tapplref.namref5              := v_tapplref.namrefe;
                
                begin
                    insert into tapplref(numappl,numseq,codtitle,
                                         namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                         namlaste,namlastt,namlast3,namlast4,namlast5,
                                         namrefe,namreft,namref3,namref4,namref5,
                                         flgref,despos,adrcont1,desnoffi,numtele,email,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tapplref.numseq,v_tapplref.codtitle,
                             v_tapplref.namfirste,v_tapplref.namfirstt,v_tapplref.namfirst3,v_tapplref.namfirst4,v_tapplref.namfirst5,
                             v_tapplref.namlaste,v_tapplref.namlastt,v_tapplref.namlast3,v_tapplref.namlast4,v_tapplref.namlast5,
                             v_tapplref.namrefe,v_tapplref.namreft,v_tapplref.namref3,v_tapplref.namref4,v_tapplref.namref5,
                             v_tapplref.flgref,v_tapplref.despos,v_tapplref.adrcont1,v_tapplref.desnoffi,v_tapplref.numtele,v_tapplref.email,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tapplref;  
   
  procedure insert_tlangabi(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row                  json_object_t;

    tmp_codlang                     varchar2(4000); 
    tmp_flglist                     varchar2(4000); 
    tmp_flgread                     varchar2(4000); 
    tmp_flgspeak                    varchar2(4000); 
    tmp_flgwrite                    varchar2(4000); 
        
    v_tlangabi                      tlangabi%rowtype;
    
    v_num_error_row                 number := 0;
    v_rcnt                          number := 0;
  begin
--    if v_count_tapplinf = 0 then
        delete tlangabi 
         where numappl = p_numappl;
        
        for i in 0..p_lng.get_size-1 loop 
            v_num_error_row := 0;
            param_json_row                  := hcm_util.get_json_t(p_lng,to_char(i));
            tmp_codlang                     := hcm_util.get_string_t(param_json_row, 'codlang');
            tmp_flglist                     := hcm_util.get_string_t(param_json_row, 'flglist');
            tmp_flgread                     := hcm_util.get_string_t(param_json_row, 'flgread');
            tmp_flgspeak                    := hcm_util.get_string_t(param_json_row, 'flgspeak');
            tmp_flgwrite                    := hcm_util.get_string_t(param_json_row, 'flgwrite');
            
            check_error(tmp_codlang, i + 1, v_rcnt, v_num_error_row , 'TLANGABI', 'CODLANG', 'TEXT', obj_response);
            check_error(tmp_flglist, i + 1, v_rcnt, v_num_error_row , 'TLANGABI', 'FLGLIST', 'FLGLANG', obj_response);
            check_error(tmp_flgread, i + 1, v_rcnt, v_num_error_row , 'TLANGABI', 'FLGREAD', 'FLGLANG', obj_response);
            check_error(tmp_flgspeak, i + 1, v_rcnt, v_num_error_row , 'TLANGABI', 'FLGSPEAK', 'FLGLANG', obj_response);
            check_error(tmp_flgwrite, i + 1, v_rcnt, v_num_error_row , 'TLANGABI', 'FLGWRITE', 'FLGLANG', obj_response);
            
            if v_num_error_row = 0 then
                v_tlangabi.codlang              := tmp_codlang;
                v_tlangabi.flglist              := tmp_flglist;
                v_tlangabi.flgread              := tmp_flgread;
                v_tlangabi.flgspeak             := tmp_flgspeak;
                v_tlangabi.flgwrite             := tmp_flgwrite;
                
                begin
                    insert into tlangabi(numappl,codlang,codempid,
                                         flglist,flgspeak,flgread,flgwrite,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tlangabi.codlang,null,
                             v_tlangabi.flglist,v_tlangabi.flgspeak,v_tlangabi.flgread,v_tlangabi.flgwrite,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);
                    
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tlangabi;    
  
  procedure insert_addinfo(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row  json_object_t;
 
    tmp_actstudy                            varchar2(4000); 
    tmp_specabi                             varchar2(4000); 
    tmp_compabi                             varchar2(4000); 
    tmp_addinfo                             varchar2(4000); 
    tmp_typthai                             varchar2(4000); 
    tmp_typeng                              varchar2(4000); 
    tmp_flgcivil                            varchar2(4000); 
    tmp_lastpost                            varchar2(4000); 
    tmp_departmn                            varchar2(4000); 
    tmp_stamilit                            varchar2(4000); 
    tmp_desexcem                            varchar2(4000); 
    tmp_flgordan                            varchar2(4000); 
    tmp_flgcase                             varchar2(4000); 
    tmp_desdisea                            varchar2(4000); 
    tmp_dessymp                             varchar2(4000); 
    tmp_flgill                              varchar2(4000); 
    tmp_desill                              varchar2(4000); 
    tmp_flgarres                            varchar2(4000); 
    tmp_desarres                            varchar2(4000); 
    tmp_flgknow                             varchar2(4000); 
    tmp_name                                varchar2(4000); 
    tmp_flgappl                             varchar2(4000); 
    tmp_lastpos2                            varchar2(4000); 
    tmp_agewrkyr                            varchar2(4000); 
    tmp_agewrkmth                           varchar2(4000); 
    tmp_hobby                               varchar2(4000); 
    
    v_tapplinf                              tapplinf%rowtype;
    v_tapploth                              tapploth%rowtype;
    
    v_num_error_row                         number := 0;
    v_rcnt                                  number := 0;
  begin
--    if v_count_tapplinf = 0 then
        for i in 0..p_addinfo.get_size-1 loop 
            v_num_error_row := 0;
            param_json_row                          := hcm_util.get_json_t(p_addinfo,to_char(i));
            tmp_actstudy                            := hcm_util.get_string_t(param_json_row, 'actstudy');
            tmp_specabi                             := hcm_util.get_string_t(param_json_row, 'specabi');
            tmp_compabi                             := hcm_util.get_string_t(param_json_row, 'compabi');
            tmp_addinfo                             := hcm_util.get_string_t(param_json_row, 'addinfo');
            tmp_typthai                             := hcm_util.get_string_t(param_json_row, 'typthai');
            tmp_typeng                              := hcm_util.get_string_t(param_json_row, 'typeng');
            tmp_flgcivil                            := hcm_util.get_string_t(param_json_row, 'flgcivil');
            tmp_lastpost                            := hcm_util.get_string_t(param_json_row, 'lastpost');
            tmp_departmn                            := hcm_util.get_string_t(param_json_row, 'departmn');
            tmp_stamilit                            := hcm_util.get_string_t(param_json_row, 'stamilit');
            tmp_desexcem                            := hcm_util.get_string_t(param_json_row, 'desexcem');
            tmp_flgordan                            := hcm_util.get_string_t(param_json_row, 'flgordan');
            tmp_flgcase                             := hcm_util.get_string_t(param_json_row, 'flgcase');
            tmp_desdisea                            := hcm_util.get_string_t(param_json_row, 'desdisea');
            tmp_dessymp                             := hcm_util.get_string_t(param_json_row, 'dessymp');
            tmp_flgill                              := hcm_util.get_string_t(param_json_row, 'flgill');
            tmp_desill                              := hcm_util.get_string_t(param_json_row, 'desill');
            tmp_flgarres                            := hcm_util.get_string_t(param_json_row, 'flgarres');
            tmp_desarres                            := hcm_util.get_string_t(param_json_row, 'desarres');
            tmp_flgknow                             := hcm_util.get_string_t(param_json_row, 'flgknow');
            tmp_name                                := hcm_util.get_string_t(param_json_row, 'name');
            tmp_flgappl                             := hcm_util.get_string_t(param_json_row, 'flgappl');
            tmp_lastpos2                            := hcm_util.get_string_t(param_json_row, 'lastpos2');
            tmp_agewrkyr                            := hcm_util.get_string_t(param_json_row, 'agewrkyr');
            tmp_agewrkmth                           := hcm_util.get_string_t(param_json_row, 'agewrkmth');
            tmp_hobby                               := hcm_util.get_string_t(param_json_row, 'hobby');

            check_error(tmp_actstudy, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'ACTSTUDY', 'TEXT', obj_response);
            check_error(tmp_specabi, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'SPECABI', 'TEXT', obj_response);
            check_error(tmp_compabi, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'COMPABI', 'TEXT', obj_response);
            check_error(tmp_addinfo, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'ADDINFO', 'TEXT', obj_response);
            check_error(tmp_typthai, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'TYPTHAI', 'NUMBER', obj_response);
            check_error(tmp_typeng, i + 1, v_rcnt, v_num_error_row , 'TAPPLINF', 'TYPENG', 'NUMBER', obj_response);
            check_error(tmp_flgcivil, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGCIVIL', 'FLG', obj_response);
            check_error(tmp_lastpost, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'LASTPOST', 'TEXT', obj_response);
            check_error(tmp_departmn, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DEPARTMN', 'TEXT', obj_response);
            check_error(tmp_stamilit, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'STAMILIT', 'FLG', obj_response);
            check_error(tmp_desexcem, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DESEXCEM', 'TEXT', obj_response);
            check_error(tmp_flgordan, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGORDAN', 'FLG', obj_response);
            check_error(tmp_flgcase, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGCASE', 'FLG', obj_response);
            check_error(tmp_desdisea, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DESDISEA', 'TEXT', obj_response);
            check_error(tmp_dessymp, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DESSYMP', 'TEXT', obj_response);
            check_error(tmp_flgill, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGILL', 'FLG', obj_response);
            check_error(tmp_desill, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DESILL', 'TEXT', obj_response);
            check_error(tmp_flgarres, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGARRES', 'FLG', obj_response);
            check_error(tmp_desarres, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'DESARRES', 'TEXT', obj_response);
            check_error(tmp_flgknow, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGKNOW', 'FLG', obj_response);
            check_error(tmp_name, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'NAME', 'TEXT', obj_response);
            check_error(tmp_flgappl, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'FLGAPPL', 'FLG', obj_response);
            check_error(tmp_lastpos2, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'LASTPOS2', 'TEXT', obj_response);
            check_error(tmp_agewrkyr, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'AGEWRKYR', 'NUMBER', obj_response);
            check_error(tmp_agewrkmth, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'AGEWRKMTH', 'NUMBER', obj_response);
            check_error(tmp_hobby, i + 1, v_rcnt, v_num_error_row , 'TAPPLOTH', 'HOBBY', 'TEXT', obj_response);
            
            if v_num_error_row = 0 then
                v_tapplinf.actstudy                     := tmp_actstudy;
                v_tapplinf.specabi                      := tmp_specabi;
                v_tapplinf.compabi                      := tmp_compabi;
                v_tapplinf.addinfo                      := tmp_addinfo;
                v_tapplinf.typthai                      := tmp_typthai;
                v_tapplinf.typeng                       := tmp_typeng;
                v_tapploth.flgcivil                     := tmp_flgcivil;
                v_tapploth.lastpost                     := tmp_lastpost;
                v_tapploth.departmn                     := tmp_departmn;
                v_tapplinf.stamilit                     := tmp_stamilit;
                v_tapploth.flgmilit                     := tmp_stamilit;
                v_tapploth.desexcem                     := tmp_desexcem;
                v_tapploth.flgordan                     := tmp_flgordan;
                v_tapploth.flgcase                      := tmp_flgcase;
                v_tapploth.desdisea                     := tmp_desdisea;
                v_tapploth.dessymp                      := tmp_dessymp;
                v_tapploth.flgill                       := tmp_flgill;
                v_tapploth.desill                       := tmp_desill;
                v_tapploth.flgarres                     := tmp_flgarres;
                v_tapploth.desarres                     := tmp_desarres;
                v_tapploth.flgknow                      := tmp_flgknow;
                v_tapploth.name                         := tmp_name;
                v_tapploth.flgappl                      := tmp_flgappl;
                v_tapploth.lastpos2                     := tmp_lastpos2;
                v_tapploth.agewrkyr                     := tmp_agewrkyr;
                v_tapploth.agewrkmth                    := tmp_agewrkmth;
                v_tapploth.hobby                        := tmp_hobby;
                
                begin
                    update tapplinf
                       set actstudy = v_tapplinf.actstudy,
                           specabi = v_tapplinf.specabi,
                           compabi = v_tapplinf.compabi,
                           addinfo = v_tapplinf.addinfo,
                           typthai = v_tapplinf.typthai,
                           typeng = v_tapplinf.typeng,
                           stamilit = v_tapplinf.stamilit
                     where numappl = p_numappl;
                    
                    
                    update tapploth
                       set flgcivil = v_tapploth.flgcivil,
                           lastpost = v_tapploth.lastpost,
                           departmn = v_tapploth.departmn,
                           flgmilit = v_tapploth.flgmilit,
                           desexcem = v_tapploth.desexcem,
                           flgordan = v_tapploth.flgordan,
                           flgcase = v_tapploth.flgcase,
                           desdisea = v_tapploth.desdisea,
                           dessymp = v_tapploth.dessymp,
                           flgill = v_tapploth.flgill,
                           desill = v_tapploth.desill,
                           flgarres = v_tapploth.flgarres,
                           desarres = v_tapploth.desarres,
                           flgknow = v_tapploth.flgknow,
                           name = v_tapploth.name,
                           flgappl = v_tapploth.flgappl,
                           lastpos2 = v_tapploth.lastpos2,
                           agewrkyr = v_tapploth.agewrkyr,
                           agewrkmth = v_tapploth.agewrkmth,
                           hobby = v_tapploth.hobby
                     where numappl = p_numappl;
                     
                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_addinfo;   
  
  procedure insert_tappldoc(obj_response  in out json_object_t, v_num_complete_all in out number, v_num_error_all in out number) is
    param_json_row                      json_object_t;
    
    tmp_numseq                          varchar2(4000); 
    tmp_namdoc                          varchar2(4000); 
    tmp_typdoc                          varchar2(4000); 
    tmp_flgresume                       varchar2(4000); 
    tmp_filedoc                         varchar2(4000); 
    tmp_desnote                         varchar2(4000); 
        
    v_tappldoc                          tappldoc%rowtype;
    
    v_num_error_row                     number := 0;
    v_rcnt                              number := 0;
  begin
--    if v_count_tapplinf = 0 then
        delete tappldoc 
         where numappl = p_numappl;
        
        for i in 0..p_lng.get_size-1 loop 
            v_num_error_row := 0;
            param_json_row                      := hcm_util.get_json_t(p_lng,to_char(i));
            tmp_numseq                          := hcm_util.get_string_t(param_json_row, 'numseq');
            tmp_namdoc                          := hcm_util.get_string_t(param_json_row, 'namdoc');
            tmp_typdoc                          := hcm_util.get_string_t(param_json_row, 'typdoc');
            tmp_flgresume                       := hcm_util.get_string_t(param_json_row, 'flgresume');
            tmp_filedoc                         := hcm_util.get_string_t(param_json_row, 'filedoc');
            tmp_desnote                         := hcm_util.get_string_t(param_json_row, 'desnote');
            
            -- check error
            check_error(tmp_numseq, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'NUMSEQ', 'NUMBER', obj_response);
            check_error(tmp_namdoc, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'NAMDOC', 'TEXT', obj_response);
            check_error(tmp_typdoc, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'TYPDOC', 'TEXT', obj_response);
            check_error(tmp_flgresume, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'FLGRESUME', 'TEXT', obj_response);
            check_error(tmp_filedoc, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'FILEDOC', 'TEXT', obj_response);
            check_error(tmp_desnote, i + 1, v_rcnt, v_num_error_row , 'TAPPLDOC', 'DESNOTE', 'TEXT', obj_response);

            if v_num_error_row = 0 then
                v_tappldoc.numseq                   := tmp_numseq;
                v_tappldoc.namdoc                   := tmp_namdoc;
                v_tappldoc.typdoc                   := tmp_typdoc;
                v_tappldoc.flgresume                := tmp_flgresume;
                v_tappldoc.filedoc                  := tmp_filedoc;
                v_tappldoc.desnote                  := tmp_desnote;
                begin
                    insert into tappldoc(numappl,numseq,codempid,typdoc,namdoc,
                                         filedoc,dterecv,dtedocen,numdoc,desnote,
                                         flgresume,numrefdoc,
                                         dtecreate,codcreate,dteupd,coduser)
                    values ( p_numappl,v_tappldoc.numseq,null,v_tappldoc.typdoc,v_tappldoc.namdoc,
                             v_tappldoc.filedoc,sysdate,null,null,v_tappldoc.desnote,
                             v_tappldoc.flgresume,null,
                             sysdate,global_v_coduser,sysdate,global_v_coduser);  

                    v_num_complete_all                  := v_num_complete_all + 1;
                exception when others then
                    v_num_error_all := v_num_error_all + 1;
                end;
            else
                v_num_error_all := v_num_error_all + 1;
            end if;
        end loop;
--    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end insert_tappldoc;   
  
  procedure check_error(p_item in varchar2, p_line in number, p_numseq in out number,p_num_error_row in out number , p_table in varchar2, p_column in varchar2, p_type in varchar2, obj_response in out json_object_t) is
    obj_data            json_object_t;
    v_chk_error         boolean;
    v_count             number;
  begin
    -- check error
    if p_type = 'NUMBER' then
        v_chk_error := hcm_validate.check_number(p_item);
        if v_chk_error then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);                
        end if;
    elsif p_type = 'TEXT' then
        v_chk_error := hcm_validate.check_length(p_item, p_table, p_column, p_max);
        if v_chk_error then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', p_item||'--'||replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);                
        end if;  
    elsif p_type = 'NUMREQL' then
        v_chk_error := hcm_validate.check_length(p_item, p_table, p_column, p_max);
        if v_chk_error then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);                
        else
            if p_numreqst is not null and p_numreqen is not null then
                if p_item not between p_numreqst and p_numreqen then 
                    p_num_error_row := p_num_error_row + 1;
                    obj_data        := json_object_t();
                    p_numseq        := p_numseq + 1;
                    obj_data.put('coderror', '200');
                    obj_data.put('numseq', p_numseq);
                    obj_data.put('line', p_line);
                    obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
                    obj_data.put('detail', replace(get_error_msg_php('HR8861',global_v_lang),'@#$%400',''));
                    obj_response.put(to_char(p_numseq-1), obj_data);
                end if;
            end if;
            
            begin
                select count(*)
                  into v_count
                  from treqest1
                 where numreqst = p_item
                   and codcomp like p_codcomp||'%';
            exception when no_data_found then
                v_count := 0;
            end;
            
            if v_count = 0 then
                p_num_error_row := p_num_error_row + 1;
                obj_data        := json_object_t();
                p_numseq        := p_numseq + 1;
                obj_data.put('coderror', '200');
                obj_data.put('numseq', p_numseq);
                obj_data.put('line', p_line);
                obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
                obj_data.put('detail', replace(get_error_msg_php('HR8861',global_v_lang),'@#$%400',''));
                obj_response.put(to_char(p_numseq-1), obj_data);            
            end if;        
        end if;  
    elsif p_type = 'NUMOFFID' then
        v_chk_error := hcm_validate.check_length(p_item, p_table, p_column, p_max);
        if v_chk_error then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);                
        else
            begin
                select count(*)
                  into v_count
                  from temploy1 a, temploy2 b
                 where a.codempid = b.codempid
                   and b.numoffid = p_item
                   and a.staemp <> '9';
            exception when no_data_found then
                v_count := 0;
            end;
            
            if v_count > 0 then
                p_num_error_row := p_num_error_row + 1;
                obj_data        := json_object_t();
                p_numseq        := p_numseq + 1;
                obj_data.put('coderror', '200');
                obj_data.put('numseq', p_numseq);
                obj_data.put('line', p_line);
                obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
                obj_data.put('detail', get_error_msg_php('HR8862',global_v_lang));
                obj_response.put(to_char(p_numseq-1), obj_data);            
            end if;        
        end if;
    elsif p_type = 'FLG' then
        if p_item not in ('Y','N') then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);
        end if;   
    elsif p_type = 'FLGLANG' then
        if p_item not in ('1','2','3') then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);
        end if;  
    elsif p_type = 'DATE' then
        v_chk_error := hcm_validate.check_date(p_item);
        if v_chk_error then
            p_num_error_row := p_num_error_row + 1;
            obj_data        := json_object_t();
            p_numseq        := p_numseq + 1;
            obj_data.put('coderror', '200');
            obj_data.put('numseq', p_numseq);
            obj_data.put('line', p_line);
            obj_data.put('data', get_tcoldesc_name(p_table,p_column,global_v_lang));
            obj_data.put('detail', replace(get_error_msg_php('HR2020',global_v_lang),'@#$%400',''));
            obj_response.put(to_char(p_numseq-1), obj_data);
        end if;
    end if;

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end check_error;      
end HRRC2PB;

/

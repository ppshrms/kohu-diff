--------------------------------------------------------
--  DDL for Package Body HRRC21E7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC21E7" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    b_index_numappl     := hcm_util.get_string_t(json_obj,'p_numappl');
  end; -- end initial_value
  --
  procedure gen_skill(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;

    cursor c_cmptncy is
      select codtency,null as numseq,get_tcodec_name('TCODSKIL',codtency,global_v_lang) as descskil,grade
        from tcmptncy
       where numappl    = b_index_numappl
      union
      select '' as codtency,numseq,descskil,grade
        from tcmptncy2
       where numappl    = b_index_numappl
      order by codtency;
  begin
    obj_row           := json_object_t();
    for i in c_cmptncy loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codtency',i.codtency);
      obj_data.put('descskil',i.descskil);
      obj_data.put('grade',i.grade);
      obj_data.put('numseq',i.numseq);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_skill (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_skill(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_other_talent(json_str_output out clob) is
    obj_table         json_object_t;
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    
    v_actstudy        tapplinf.actstudy%type;
    v_specabi         tapplinf.specabi%type;
    v_compabi         tapplinf.compabi%type;
    v_addinfo         tapplinf.addinfo%type;
    v_typthai         tapplinf.typthai%type;
    v_typeng          tapplinf.typeng%type;
    
    cursor c_cmptncy is
      select codlang,flglist,flgspeak,flgread,flgwrite
        from tlangabi
       where numappl    = b_index_numappl
      order by codlang;
  begin
    obj_data   := json_object_t();
    begin
      select actstudy,specabi,compabi,addinfo,typthai,typeng
        into v_actstudy,v_specabi,v_compabi,v_addinfo,v_typthai,v_typeng
        from tapplinf
       where numappl    = b_index_numappl;
    exception when no_data_found then
      null;
    end;
    obj_data.put('coderror','200');
    obj_data.put('actstudy',v_actstudy);
    obj_data.put('specabi',v_specabi);
    obj_data.put('compabi',v_compabi);
    obj_data.put('addinfo',v_addinfo);
    obj_data.put('typthai',v_typthai);
    obj_data.put('typeng',v_typeng);
    
    obj_row    := json_object_t();
    for i in c_cmptncy loop
      obj_table   := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_table.put('codlang',i.codlang);
      obj_table.put('flglist',i.flglist);
      obj_table.put('flgspeak',i.flgspeak);
      obj_table.put('flgread',i.flgread);
      obj_table.put('flgwrite',i.flgwrite);
      obj_row.put(to_char(v_rcnt - 1), obj_table);
    end loop;
    obj_data.put('table',obj_row);
    json_str_output   := obj_data.to_clob;
  end;
  --
  procedure get_other_talent (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
--    check_index;
    if param_msg_error is null then
      gen_other_talent(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_oth_skill(param_tapplinf json_object_t,param_table json_object_t) is
    param_oth_talent_row json_object_t;
    v_actstudy      tapplinf.actstudy%type;
    v_specabi       tapplinf.specabi%type;
    v_compabi       tapplinf.compabi%type;
    v_addinfo       tapplinf.addinfo%type;
    v_typthai       tapplinf.typthai%type;
    v_typeng        tapplinf.typeng%type;
    
    t_tlangabi        tlangabi%rowtype;
    v_flg_oth_talent  varchar2(100);
  begin
    v_actstudy     := hcm_util.get_string_t(param_tapplinf,'actstudy');
    v_specabi      := hcm_util.get_string_t(param_tapplinf,'specabi');
    v_compabi      := hcm_util.get_string_t(param_tapplinf,'compabi');
    v_addinfo      := hcm_util.get_string_t(param_tapplinf,'addinfo');
    v_typthai      := hcm_util.get_string_t(param_tapplinf,'typthai');
    v_typeng       := hcm_util.get_string_t(param_tapplinf,'typeng');

    update tapplinf
       set actstudy     = v_actstudy,
           specabi      = v_specabi,
           compabi      = v_compabi,
           addinfo      = v_addinfo,
           typthai      = v_typthai,
           typeng       = v_typeng,
           coduser      = global_v_coduser
     where numappl      = b_index_numappl;

    for i in 0..param_table.get_size - 1 loop
      param_oth_talent_row    := hcm_util.get_json_t(param_table,to_char(i));
      t_tlangabi.codlang      := hcm_util.get_string_t(param_oth_talent_row,'codlang');
      t_tlangabi.flglist      := hcm_util.get_string_t(param_oth_talent_row,'flglist');
      t_tlangabi.flgspeak     := hcm_util.get_string_t(param_oth_talent_row,'flgspeak');
      t_tlangabi.flgread      := hcm_util.get_string_t(param_oth_talent_row,'flgread');
      t_tlangabi.flgwrite     := hcm_util.get_string_t(param_oth_talent_row,'flgwrite');
      v_flg_oth_talent        := hcm_util.get_string_t(param_oth_talent_row,'flg');
      if v_flg_oth_talent in ('add','edit') then
        begin
          insert into tlangabi(numappl,codlang,codempid,flglist,flgspeak,
                               flgread,flgwrite,codcreate,coduser)
          values (b_index_numappl,t_tlangabi.codlang,t_tlangabi.codempid,t_tlangabi.flglist,t_tlangabi.flgspeak,
                  t_tlangabi.flgread,t_tlangabi.flgwrite,global_v_lang,global_v_lang);
        exception when dup_val_on_index then
          update tlangabi
             set flglist      = t_tlangabi.flglist,
                 flgspeak     = t_tlangabi.flgspeak,
                 flgread      = t_tlangabi.flgread,
                 flgwrite     = t_tlangabi.flgwrite,
                 coduser      = global_v_coduser
           where numappl      = b_index_numappl
             and codlang      = t_tlangabi.codlang;
        end;
      else
        delete from tlangabi
         where numappl      = b_index_numappl
           and codlang      = t_tlangabi.codlang;
      end if;
      
    end loop;
     
  end;
  --
  procedure save_skill(p_codtency   tcmptncy.codtency%type,
                       p_descskil   tcmptncy2.descskil%type,
                       p_grade      tcmptncy.grade%type,
                       p_numseq     tcmptncy2.numseq%type) is
    v_numseq      number;
  begin
    if p_codtency is null then
      if p_numseq is null then
        select nvl(max(numseq),0) + 1
          into v_numseq
          from tcmptncy2
         where numappl      = b_index_numappl;
      else
        v_numseq    := p_numseq;
      end if;
      
      begin       
        insert into tcmptncy2(numappl,numseq,codempid,descskil,grade,codcreate,coduser)
        values (b_index_numappl,v_numseq,b_index_numappl,p_descskil,p_grade,global_v_lang,global_v_lang);
      exception when dup_val_on_index then
        update tcmptncy2
           set descskil     = p_descskil,
               grade        = p_grade,
               coduser      = global_v_coduser
         where numappl      = b_index_numappl
           and numseq       = v_numseq;
      end;
    else
      begin       
        insert into tcmptncy(numappl,codtency,codempid,grade,codcreate,coduser)
        values (b_index_numappl,p_codtency,b_index_numappl,p_grade,global_v_lang,global_v_lang);
      exception when dup_val_on_index then
        update tcmptncy
           set grade        = p_grade,
               coduser      = global_v_coduser
         where numappl      = b_index_numappl
           and codtency     = p_codtency;
      end;
    end if;
  end;
  --
  procedure save_talent(json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    param_json_skill        json_object_t;
    param_json_skill_row    json_object_t;
    param_json_oth_skill    json_object_t;
    param_json_table        json_object_t;
    t_tapplfm               tapplfm%rowtype;
    
    v_codtency              tcmptncy.codtency%type;
    v_descskil              tcmptncy2.descskil%type;
    v_grade                 tcmptncy2.grade%type;
    v_numseq                tcmptncy2.numseq%type;
    v_flg                   varchar2(100);
    
  begin
    initial_value(json_str_input);
    param_json              := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_json_skill        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'competency'),'rows');
    param_json_oth_skill    := hcm_util.get_json_t(param_json,'lang_abi');
    param_json_table        := hcm_util.get_json_t(hcm_util.get_json_t(param_json_oth_skill,'table'),'rows');

    if param_msg_error is null then
      for i in 0..param_json_skill.get_size - 1 loop
        param_json_skill_row  := hcm_util.get_json_t(param_json_skill,to_char(i));
        v_codtency      := hcm_util.get_string_t(param_json_skill_row,'codtency');
        v_descskil      := hcm_util.get_string_t(param_json_skill_row,'descskil');
        v_grade         := hcm_util.get_string_t(param_json_skill_row,'grade');
        v_numseq        := hcm_util.get_string_t(param_json_skill_row,'numseq');
        v_flg           := hcm_util.get_string_t(param_json_skill_row,'flg');
        if v_flg in ('add','edit') then
          save_skill(v_codtency,v_descskil,v_grade,v_numseq);
        else
          delete from tcmptncy
           where numappl    = b_index_numappl
             and codtency   = v_codtency;
             
          delete from tcmptncy2
           where numappl    = b_index_numappl
             and numseq     = v_numseq;   
        end if;
      end loop;
      
      save_oth_skill(param_json_oth_skill,param_json_table);
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

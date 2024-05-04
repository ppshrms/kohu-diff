--------------------------------------------------------
--  DDL for Package Body HRBF3XU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3XU" is
-- last update: 16/09/2020 11:24
  procedure initial_value(json_str in clob) is
    json_obj                json_object_t;
  begin
    v_chken                 := hcm_secur.get_v_chken;
    json_obj                := json_object_t(json_str);
    --global
    global_v_coduser        := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid       := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd        := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang           := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index--
    p_codcomp             := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_numpolicyo          := hcm_util.get_string_t(json_obj,'p_numpolicyo');
    p_numpolicyn          := hcm_util.get_string_t(json_obj,'p_numpolicyn');
    p_numinsur            := hcm_util.get_string_t(json_obj,'p_numinsur');
    p_coduser             := hcm_util.get_string_t(json_obj,'p_coduser');
    p_codlang             := hcm_util.get_string_t(json_obj,'p_lang');
    p_type                := hcm_util.get_string_t(json_obj,'p_calculat');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure check_index as
    v_numisro1      tisrinf.numisr%type;
    v_numisro2      tisrinf.numisr%type;
    v_numisrn1      tisrinf.numisr%type;
    v_numisrn2      tisrinf.numisr%type;
    v_dtehlpen      tisrinf.dtehlpen%type;
    v_dtehlpen_old  tisrinf.dtehlpen%type;
    v_dtehlpst_new  tisrinf.dtehlpen%type;
    v_codisrp1      number :=0;
    v_codisrp2      number :=0;
    v_codisrp       tisrpinf.codisrp%type;


  begin
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
----------
    if p_numpolicyo is not null then
      begin
        select numisr
          into v_numisro1
          from tisrinf
         where numisr = p_numpolicyo;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TISRINF');
          return;
      end;

      if v_numisro1 is not null then
        begin
            select numisr
              into v_numisro2
              from TISRINF
             where numisr = p_numpolicyo
               and p_codcomp like codcompy||'%'
               and rownum = 1;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TISRINF');
            return;
        end;
      end if;
    end if;
 ----------
    begin
      select numisr
        into v_numisrn1
        from TISRINF
       where numisr = p_numpolicyn;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TISRINF');
        return;
    end;
    if v_numisrn1 is not null then
      begin
          select numisr
            into v_numisrn2
            from tisrinf
           where numisr = p_numpolicyn
             and p_codcomp like codcompy||'%'
             and rownum = 1;
      exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TISRINF');
          return;
      end;
      if v_numisrn2 is not null then
        begin
          select dtehlpen
            into v_dtehlpen
            from tisrinf
           where numisr = p_numpolicyn
             and dtehlpen >= trunc(sysdate);
        exception when no_data_found then
          param_msg_error := get_error_msg_php('BF0050', global_v_lang);
          return;
        end;
      end if;
    end if;
-----------
    if p_type = '2' then --- ต่อกรมธรรณ์
        begin
          select count(codisrp)
            into v_codisrp1
            from tisrpinf
           where numisr = p_numpolicyo;
        exception when no_data_found then
          v_codisrp1 := 0;
        end;

         begin
          select count(codisrp)
            into v_codisrp2
            from tisrpinf
           where numisr = p_numpolicyn;
        exception when no_data_found then
          v_codisrp1 := 0;
        end;

        if v_codisrp1 <> v_codisrp2 then
            param_msg_error := get_error_msg_php('BF0075', global_v_lang);
            return;
        else

           begin
               select codisrp 
               into  v_codisrp 
               from
                   (
                        select codisrp
                          from tisrpinf
                         where numisr = p_numpolicyo

                    minus

                        select codisrp
                          from tisrpinf
                         where numisr = p_numpolicyn
                    );
                param_msg_error := get_error_msg_php('BF0079', global_v_lang);
                return;     
            exception when no_data_found then   null;         
           end;
        end if;
     ----------

         begin
          select dtehlpen
            into v_dtehlpen_old
            from tisrinf
           where numisr = p_numpolicyo;
        exception when no_data_found then
          v_dtehlpen_old := null;
        end;

        begin
          select dtehlpst
            into v_dtehlpst_new
            from tisrinf
           where numisr = p_numpolicyn;
        exception when no_data_found then
          v_dtehlpst_new := null;
        end;

        if v_dtehlpst_new <> (v_dtehlpen_old+1) then
            param_msg_error := get_error_msg_php('BF0076', global_v_lang);
            return;
        end if;


    end if;
  end;

  procedure get_process(json_str_input in clob, json_str_output out clob) as
    obj_data json_object_t;
    v_response varchar(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      hrbf3xu_batch.start_process(p_codcomp,
                                  p_numpolicyn,
                                  p_numpolicyo,
                                  p_type,
                                  p_coduser,
                                  p_codlang,
                                  p_numinsur);

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
      obj_data.put('numinsur', p_numinsur);

      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

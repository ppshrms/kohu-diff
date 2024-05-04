--------------------------------------------------------
--  DDL for Package Body HRPY95R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY95R" as
  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');

    p_dteyrepay  := to_number(hcm_util.get_string_t(obj_detail,'p_dteyrepay'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'p_codcomp');
    p_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
    v_staemp		   varchar2(1000 char);
    v_numlvl       number := 0;
    v_codempid     varchar2(1000 char);
    v_secur			   boolean := false;
  begin
    if p_codempid is not null then
      begin
        select staemp,codcomp,numlvl
          into v_staemp,p_codcomp,v_numlvl
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
      end;
      --
      if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
      end if;
      --
			v_secur := secur_main.secur1(p_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
			if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
			end if;
    else
      v_secur := secur_main.secur7(p_codcomp,global_v_coduser);
      if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    --
    begin
      select flgfml  into p_flgfml
      from 	 tcontrpy
      where  codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
      and 	 dteeffec = (select max(dteeffec)
                           from tcontrpy
                          where	codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate));
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcontrpy');
      return;
    end;

--    begin
--      select codempid into v_codempid
--        from ttaxmas
--       where codempid   = nvl(p_codempid, codempid)
--         and codcomp    = nvl(p_codcomp, codcomp)
--         and dteyrepay  = p_dteyrepay
--         and rownum     = 1;
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttaxmas');
--      return;
--    end;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob)as
    obj_rows             json_object_t;
    obj_data             json_object_t;
    v_rcnt               number := 0;
    v_flg_exist          boolean := false;
    v_flg_permission     boolean := false;
    cursor c_ttaxcodd is
      select numseq,desdeduct,formula,dteyreff
        from ttaxcodd
       where dteyreff = (select max(dteyreff)
                           from ttaxcodd
                          where dteyreff <= p_dteyrepay)
      order by numseq;
  begin
    obj_rows := json_object_t();
--    for r1 in c_ttaxcodd loop
--      v_flg_exist := true;
--      exit;
--     end loop;
--    if not v_flg_exist then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcodd');
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
    for r1 in c_ttaxcodd loop
      obj_data := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteyreff', r1.dteyreff);
--      obj_data.put('dteyreff', p_dteyrepay - global_v_zyear);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('desdeduct', r1.desdeduct);
      obj_data.put('formula', r1.formula);
      if r1.dteyreff <> p_dteyrepay then
        obj_data.put('flgAdd', true);
      else
        obj_data.put('flgAdd', false);
      end if;
      obj_data.put('desc_formula',get_logical_name('HRAL92M6',r1.formula,global_v_lang));

      obj_rows.put(to_char(v_rcnt),obj_data);
      v_rcnt   := v_rcnt + 1;
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure save_process (json_str_input in clob, json_str_output out clob) as
    obj_param_json  json_object_t;
    param_json_row  json_object_t;
    obj_calculator  json_object_t;
    -- get param json
    v_dteyreff      ttaxcodd.dteyreff%type;
    v_numseq        ttaxcodd.numseq%type;
    v_formula       ttaxcodd.formula%type;
    v_desdeduct     ttaxcodd.desdeduct%type;
    v_flg           varchar2(100 char);
    v_exit          varchar2(1);
    v_max_qty       number := 0;
    v_secur         varchar2(1);
  begin
    obj_calculator := json_object_t();
    initial_value(json_str_input);
    --
    if p_codcomp is null then
      begin
        select codcomp
          into p_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when others then
        null;
      end;
    end if;
    begin
      select sum(qtycode) into v_max_qty
        from tsetcomp
       where numseq <= 10;
    exception when others then null;
    end;
    --
    if length(p_codcomp) < v_max_qty then
       p_codcomp := p_codcomp||'%';
    end if;
    obj_param_json        := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..obj_param_json.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(obj_param_json,to_char(i));
        --
        v_dteyreff        := hcm_util.get_string_t(param_json_row,'dteyreff');
        v_numseq          := hcm_util.get_string_t(param_json_row,'numseq');
        v_desdeduct       := hcm_util.get_string_t(param_json_row,'desdeduct');
        obj_calculator    := hcm_util.get_json_t(param_json_row,'desc_calculator');
        v_formula         := hcm_util.get_string_t(obj_calculator, 'code');
        v_flg             := hcm_util.get_string_t(param_json_row,'flg');
        --
        if param_msg_error is null then
          if v_flg = 'edit' then
            begin
              update ttaxcodd set formula     =  v_formula,
                                  desdeduct   =  v_desdeduct,
                                  dteupd      =  trunc(sysdate),
                                  coduser     =  global_v_coduser
                            where dteyreff    =  v_dteyreff
                              and numseq      =  v_numseq;
            end;
          elsif v_flg = 'delete' then
            begin
              delete ttaxcodd where dteyreff = v_dteyreff and numseq = v_numseq;
            end;
          elsif v_flg = 'add' then
            if v_numseq is null then
              begin
                select nvl(max(numseq)+1,1) into v_numseq
                  from ttaxcodd
                 where dteyreff = p_dteyrepay;
              exception when no_data_found then
                v_numseq := 1;
              end;
            end if;
            begin
              insert into ttaxcodd(dteyreff, numseq, desdeduct, formula)
              values (p_dteyrepay, v_numseq, v_desdeduct, v_formula);
            exception when dup_val_on_index then
              update ttaxcodd set formula     =  v_formula,
                                    desdeduct   =  v_desdeduct,
                                    dteupd      =  trunc(sysdate),
                                    coduser     =  global_v_coduser
                              where dteyreff    =  p_dteyrepay
                                and numseq      =  v_numseq;
            end;
          end if;
        end if;
      end loop;

      if param_msg_error is null then
        hrpy95r_batch.start_process2(p_codempid,p_codcomp,p_dteyrepay,v_chken,global_v_zyear,global_v_coduser,global_v_lang,v_exit,v_secur,global_v_codempid);
        if v_exit = 'N' then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxmas');
          rollback;
        elsif v_secur = 'N' then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          rollback;
        else
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
        end if;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_process;

  --Redmine #5585
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
/*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --Redmine #5585
end HRPY95R;

/

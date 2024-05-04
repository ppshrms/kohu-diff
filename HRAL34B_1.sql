--------------------------------------------------------
--  DDL for Package Body HRAL34B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL34B" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_stdate            := to_date(hcm_util.get_string_t(json_obj,'p_stdate'),'dd/mm/yyyy');
    p_endate            := to_date(hcm_util.get_string_t(json_obj,'p_endate'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_staemp      varchar2(1 char);
    v_flgsecu     boolean	:= null;
    v_codcomp     varchar2(4000 char);
  begin
    if p_codempid is not null then
      begin
        select codcomp into p_codcomp
        from   temploy1
        where  codempid = p_codempid;
        v_flgsecu := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codempid');
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1.codempid');
        return;
      end;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_stdate > p_endate then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'stdate');
      return;
    end if;
  end;

  procedure get_data_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_flgsecu       boolean := false;
    rt_tcontral	    tcontral%rowtype;
    v_exists_rec    boolean := false;
    cursor c_emp is
      select codempid
        from temploy1
       where codempid = nvl(p_codempid,codempid)
         and codcomp like p_codcomp
         and (staemp in ('1','3')
          or (staemp = '9' and dteeffex >= p_stdate))
      order by codempid;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);

      -- finish batch process
      hcm_batchtask.finish_batch_process(
        p_codapp   => global_v_batch_codapp,
        p_coduser  => global_v_coduser,
        p_codalw   => global_v_batch_codalw,
        p_dtestrt  => global_v_batch_dtestrt,
        p_flgproc  => 'N',
        p_qtyproc  => global_v_batch_qtyproc,
        p_qtyerror => global_v_batch_qtyerror,
        p_oracode  => param_msg_error
      );
      return;
    end if;
    /*begin
  		select * into rt_tcontral
  		  from tcontral
  		 where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
  		  and  dteeffec = (select max(dteeffec)
  					      				 from tcontral
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
										  	    and dteeffec <= sysdate)
			  and  rownum <= 1;
  	exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
  	end;
    if param_msg_error is null then*/
      p_numrec := 0;
      for r_emp in c_emp loop
        v_flgsecu := secur_main.secur2(r_emp.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
          v_exists_rec := true;
          std_al.cal_tattence(r_emp.codempid,p_stdate,p_endate,global_v_coduser,p_numrec);
        end if;
      end loop;
      if v_exists_rec then
        commit;
        obj_row    := json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('numrec', to_char(p_numrec,'fm999,999,999,990'));
        obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
        json_str_output := obj_row.to_clob;

        -- set complete batch process 
        global_v_batch_flgproc  := 'Y';
        global_v_batch_qtyproc  := p_numrec;
      else
        rollback;
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    /*else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;*/

    -- finish batch process
    hcm_batchtask.finish_batch_process(
      p_codapp   => global_v_batch_codapp,
      p_coduser  => global_v_coduser,
      p_codalw   => global_v_batch_codalw,
      p_dtestrt  => global_v_batch_dtestrt,
      p_flgproc  => global_v_batch_flgproc,
      p_qtyproc  => global_v_batch_qtyproc,
      p_qtyerror => global_v_batch_qtyerror,
      p_oracode  => param_msg_error
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    -- exception batch process
    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end;

  function check_index_batchtask(json_str_input clob) return varchar2 is
    v_response    varchar2(4000 char);
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is not null then
      v_response := replace(param_msg_error,'@#$%400');
    end if;
    return v_response;
  end;
end HRAL34B;

/

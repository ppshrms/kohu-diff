--------------------------------------------------------
--  DDL for Package Body HRAP3JB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3JB" AS

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_dteyreap');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcompy    := get_comp_split(b_index_codcomp,1);
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
  begin
    if nvl(b_index_dteyreap,0) = 0 then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteyreap');
      return;
    end if;
    if b_index_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcomp);
        if param_msg_error is not null then
          return;
        end if;
    end if;
  end check_index;

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
    v_rcnt          number := 0;
    v_exist         boolean := false;
    v_codpay        varchar2(10 char);
    v_codcompy      varchar2(10 char);

    cursor c_tapppy is
        select codcomp,typpayroll,numperiod,dtemthpay,dteyrepay,dteyreap
          from tapppy
         where dteyreap = b_index_dteyreap
           and codcomp  like b_index_codcomp||'%'
        order by typpayroll,numperiod,dtemthpay,dteyrepay;


    cursor c_tcontrap is
        select a.codpay
         from tcontrap a
        where a.codcompy  = v_codcompy
          and a.dteyreap  = (select max(b.dteyreap)
                               from tcontrap b
                              where b.codcompy = a.codcompy);

  begin
    obj_row  := json_object_t();
    v_rcnt   := 0;
    for i in c_tapppy loop
        v_rcnt       := v_rcnt+1;
        obj_data     := json_object_t();
        obj_data.put('coderror', '200');
        v_codcompy   := get_comp_split(i.codcomp,1);
        obj_data.put('typpayroll', i.typpayroll);
        obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', i.typpayroll, global_v_lang));
        v_codpay := null;
        for j in c_tcontrap loop
            v_codpay := j.codpay;
            exit;
        end loop;
        obj_data.put('codpay', v_codpay);
        obj_data.put('desc_codpay', get_tinexinf_name(v_codpay,global_v_lang));
        obj_data.put('numperiod', to_char(i.numperiod));
        obj_data.put('dtemthpay', i.dtemthpay);
        obj_data.put('name_month', get_tlistval_name('NAMMTHFUL',i.dtemthpay,global_v_lang));
        obj_data.put('dteyrepay', i.dteyrepay);
        obj_data.put('numrec', '');
--        obj_data.put('codcompy', v_codcompy);
        obj_data.put('codcomp', i.codcomp);
        obj_row.put(to_char(v_rcnt), obj_data);
    end loop;

--    if v_rcnt = 0 then
--        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'TAPPPY');
--        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
--    else
        json_str_output := obj_row.to_clob;
--    end if;
  end;

  procedure check_transfer_data is
    v_numperiod     number;
    v_dtemthpay     number;
    v_dteyrepay     number;
    v_typpayroll    temploy1.typpayroll%type;
    v_rec1          number := 0;
    v_rec2          number := 0;

    cursor c_tdtepay is
        select numperiod,dtemthpay,dteyrepay
          from tdtepay
         where codcompy   = p_codcompy
           and typpayroll = p_typpayroll
           and flgcal     = 'Y'
        order by dteyrepay desc,dtemthpay desc, numperiod desc;

  begin
    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;

    begin
        select codcodec into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'typpayroll');
        return;
    end;

    for j in c_tdtepay loop
        v_numperiod := j.numperiod;
        v_dtemthpay := j.dtemthpay;
        v_dteyrepay := j.dteyrepay;
        exit;
    end loop;

    if p_dteyrepay||lpad(p_dtemthpay,2,'0')||p_numperiod < v_dteyrepay||lpad(v_dtemthpay,2,'0')||v_numperiod then
        param_msg_error := get_error_msg_php('HR7517', global_v_lang);
        return;
    end if;

    begin
        select count(codempid) into v_rec1
          from tapprais
         where typpayroll  = p_typpayroll
           and dteyreap    = b_index_dteyreap
           and stddec(amtlums,codempid,v_chken) > 0
           and flgtrnpy = 'N';
    exception when no_data_found then
        v_rec1 := 0;
    end;

    begin
        select count(codempid) into v_rec2
          from tapprais
         where typpayroll  = p_typpayroll
           and dteyreap    = b_index_dteyreap
           and dteyrepay   = p_dteyrepay
           and dtemthpay   = p_dtemthpay
           and periodpay   = p_numperiod
           and stddec(amtlums,codempid,v_chken) > 0
           and flgtrnpy = 'Y';
    exception when no_data_found then
        v_rec2 := 0;
    end;

    if v_rec1 = 0 and v_rec2 <> 0 then
        param_msg_error := get_error_msg_php('AP0011', global_v_lang);
        return;
    end if;

    if v_rec1 = 0 and v_rec2 = 0 then
        param_msg_error := p_typpayroll||'-'||b_index_dteyreap||'-'||p_dteyrepay||'-'||p_dtemthpay||'-'||p_numperiod||'-'||get_error_msg_php('HR2055', global_v_lang, 'tapprais');
        return;
    end if;

  end check_transfer_data;

  procedure post_transfer_data (json_str_input in clob, json_str_output out clob) is
    param_json      json_object_t;
    param_json_row  json_object_t;
    data_row        clob;
    v_flg           varchar2(1000);
    obj_data        json_object_t;
    obj_row         json_object_t;
    json_obj        json_object_t;
    v_rcnt          number := 0;
    v_response      varchar2(1000);
    v_loop number := 0;


  begin
    param_json := hcm_util.get_json_t(hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str'),'table');
    initial_value(json_str_input);
    json_obj := json_object_t();
    if param_msg_error is null then
      obj_row  := json_object_t();
      v_rcnt   := 0;
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json, to_char(i));
        p_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
        p_typpayroll    := hcm_util.get_string_t(param_json_row,'typpayroll');
        p_codpay        := hcm_util.get_string_t(param_json_row,'codpay');
        p_numperiod     := hcm_util.get_string_t(param_json_row,'numperiod');
        p_dtemthpay     := hcm_util.get_string_t(param_json_row,'dtemthpay');
        p_dteyrepay     := hcm_util.get_string_t(param_json_row,'dteyrepay');
        p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
        check_transfer_data;
        if param_msg_error is null then
            transfer_data;
            v_rcnt       := v_rcnt+1;
            obj_data     := json_object_t();
            obj_data.put('typpayroll', p_typpayroll);
            obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', p_typpayroll, global_v_lang));
            obj_data.put('codpay', p_codpay);
            obj_data.put('desc_codpay', get_tinexinf_name(p_codpay,global_v_lang));
            obj_data.put('numperiod', to_char(p_numperiod));
            obj_data.put('dtemthpay', p_dtemthpay);
            obj_data.put('name_month', get_tlistval_name('NAMMTHFUL',p_dtemthpay,global_v_lang));
            obj_data.put('dteyrepay', p_dteyrepay);
            obj_data.put('numrec', nvl(p_numrec,0));
            obj_row.put(to_char(v_rcnt-1), obj_data);
        else
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            rollback;
            return;
        end if;
      end loop;
      data_row := obj_row.to_clob;
      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response := get_response_message(null,param_msg_error,global_v_lang);

        json_obj.put('coderror',hcm_util.get_string_t(json_object_t(v_response),'coderror'));
        json_obj.put('desc_coderror',hcm_util.get_string_t(json_object_t(v_response),'desc_coderror'));
        json_obj.put('response',hcm_util.get_string_t(json_object_t(v_response),'response'));
        json_obj.put('rows',data_row);
        commit;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        rollback;
      end if;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
      return;
    end if;
    json_str_output := json_obj.to_clob;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end post_transfer_data;

  procedure transfer_data is
    v_flgsecu		boolean;
    v_codempid	    temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
    v_flgfound      boolean := false;

    cursor c_tapprais is
        select a.codempid,a.dteyreap,a.codcomp,a.dteyrepay,
               a.dtemthpay,a.periodpay,a.typpayroll,b.typemp,a.numlvl,
               stddec(a.amtlums,a.codempid,v_chken) amtlums
          from tapprais a,temploy1 b
         where a.codempid   = b.codempid
           and b.codcomp    like p_codcomp||'%'
           and a.typpayroll = p_typpayroll
           and a.dteyreap   = b_index_dteyreap
           and stddec(a.amtlums,a.codempid,v_chken) > 0
           and a.flgtrnpy   = 'N'
           and a.staappr    <> 'P'
           and a.codempid   > ' '
        order by a.codempid,a.dteyreap,a.codcomp;

    cursor c_tapppy is
        select dteyreap,codcomp,typpayroll,numperiod,dtemthpay,dteyrepay
          from tapppy
         where dteyreap   = b_index_dteyreap
           and codcomp    = v_codcomp
           and typpayroll = p_typpayroll;

  begin
    for r_emp in c_tapprais loop
        << main_loop >> loop
            v_codempid := r_emp.codempid;
            v_codcomp  := r_emp.codcomp;
            v_flgsecu := secur_main.secur2(r_emp.codcomp,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if not v_flgsecu then
                exit main_loop;
            end if;

            --create tothinc
            ins_tothinc(r_emp.codempid,p_dteyrepay,p_dtemthpay,p_numperiod,p_codpay,r_emp.codcomp,r_emp.typpayroll,r_emp.typemp,r_emp.amtlums,'AP');
            --update tapprais
            update tapprais set flgtrnpy  = 'Y',
                                dteyrepay = p_dteyrepay,
                                dtemthpay = p_dtemthpay,
                                periodpay = p_numperiod,
                                dtetrnpy  = to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                                coduser   = global_v_coduser
            where codempid = r_emp.codempid
              and dteyreap = p_dteyreap ;

            for r_tapppy in c_tapppy loop
                v_flgfound := true;
                update tapppy set numperiod = p_numperiod,
                                  dtemthpay = p_dtemthpay,
                                  dteyrepay = p_dteyrepay,
                                  coduser   = global_v_coduser
                where dteyreap   = r_tapppy.dteyreap
                  and codcomp    = r_tapppy.codcomp
                  and typpayroll = r_tapppy.typpayroll   ;
            end loop;
            if not v_flgfound then
                insert into tapppy (dteyreap,codcomp,typpayroll,
                                    numperiod,dtemthpay,dteyrepay,
                                    codcreate,coduser)
                        values     (b_index_dteyreap,r_emp.codcomp,r_emp.typpayroll,
                                    p_numperiod,p_dtemthpay,p_dteyrepay,
                                    global_v_coduser,global_v_coduser);
            end if;
        exit main_loop;
        end loop;
    end loop;
  end;

  procedure ins_tothinc (v_codempid   in temploy1.codempid%type,
                         v_dteyrepay  in tothinc.dteyrepay%type,
                         v_dtemthpay  in tothinc.dtemthpay%type,
                         v_numperiod  in tothinc.numperiod%type,
                         v_codpay     in tothinc.codpay%type,
                         v_codcomp	  in tothinc.codcomp%type,
                         v_typpayroll in tothinc.typpayroll%type,
                         v_typemp	  in tothinc.typemp%type,
                         v_amtpay     in tothinc.amtpay%type,
                         v_codsys     in tothinc.codsys%type) is

	  v_amtpaynet     	varchar2(40 char);
	  v_count           number := 0;
      v_codcompw        temploy1.codcomp%type;
      v_codcompgl       temploy1.codcomp%type;
      v_flgfound        boolean := false;


      cursor c_tothinc2 is
        select rowid,codempid,amtpay
          from tothinc2
         where codempid   = v_codempid
           and dteyrepay  = v_dteyrepay
           and dtemthpay  = v_dtemthpay
           and numperiod  = v_numperiod
           and codpay     = v_codpay
           and codcompw   = v_codcompw;

  begin

      v_codcompw  := v_codcomp;
      begin
        select costcent into v_codcompgl
          from tcenter
         where codcomp = v_codcompw;
      exception when no_data_found then
        v_codcompgl := null;
      end;

        begin
            select count(codempid) into  v_count
              from tothinc
             where codempid  = v_codempid
               and dteyrepay = v_dteyrepay
               and dtemthpay = v_dtemthpay
               and numperiod = v_numperiod
               and codpay    = v_codpay;
        exception when no_data_found then
            v_count := 0;
        end;
		if v_count = 0 then
            v_amtpaynet := stdenc(round(v_amtpay,2),v_codempid,v_chken);
            insert into tothinc(codempid,dteyrepay,dtemthpay,
                                numperiod,codpay,codcomp,
                                typpayroll,amtpay,codsys,
                                typemp,coduser,codcreate)
                   values      (v_codempid,v_dteyrepay,v_dtemthpay,
                                v_numperiod,v_codpay,v_codcomp,
                                v_typpayroll,v_amtpaynet,v_codsys,
                                v_typemp,global_v_coduser,global_v_coduser);
        p_numrec := nvl(p_numrec,0) + 1;
     end if;

    for r_tothinc2 in c_tothinc2 loop
        v_flgfound := true;
        v_amtpaynet := nvl(stddec(r_tothinc2.amtpay,r_tothinc2.codempid,v_chken),0) + nvl(stddec(v_amtpay,r_tothinc2.codempid,v_chken),0);

        update tothinc2
           set amtpay     = stdenc(v_amtpaynet,codempid,v_chken),
               costcent   = v_codcompgl,
               codsys	  = 'AP',
               coduser    = global_v_coduser
         where rowid = r_tothinc2.rowid;
    end loop;

    if not v_flgfound then
        v_amtpaynet := stdenc(round(v_amtpay,2),v_codempid,v_chken);
        insert into tothinc2 (codempid,dteyrepay,dtemthpay,
                              numperiod,codpay,codcompw,
                              costcent,amtpay,codsys,
                              coduser,codcreate)
               values        (v_codempid,v_dteyrepay,v_dtemthpay,
                              v_numperiod,v_codpay,v_codcompw,
                              v_codcompgl,v_amtpaynet,'AP',
                              global_v_coduser,global_v_coduser);
    end if;

  end;


  procedure get_codpay (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_codpay(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codpay;

  procedure gen_codpay (json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_exist         boolean := false;
    v_codpay        varchar2(10 char);
    v_codcompy      varchar2(10 char);

    cursor c_tcontrap is
        select a.codpay
         from tcontrap a
        where a.codcompy  = v_codcompy
          and a.dteyreap  = (select max(b.dteyreap)
                               from tcontrap b
                              where b.codcompy = a.codcompy);

  begin
    obj_data  := json_object_t();
    v_rcnt   := 0;
    v_codcompy   := get_comp_split(b_index_codcomp,1);
    for j in c_tcontrap loop
        v_codpay := j.codpay;
        exit;
    end loop;
    obj_data.put('coderror', '200');
    obj_data.put('codpay', v_codpay);
    obj_data.put('desc_codpay', get_tinexinf_name(v_codpay,global_v_lang));
    obj_data.put('desc_typpayroll', get_tcodec_name('tcodtypy', p_typpayroll, global_v_lang));

    json_str_output := obj_data.to_clob;
  end;
END HRAP3JB;

/

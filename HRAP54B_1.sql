--------------------------------------------------------
--  DDL for Package Body HRAP54B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP54B" as


procedure initial_value (json_str in clob) is
    json_obj        json;
begin
    v_chken             := hcm_secur.get_v_chken;

    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid    := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    -- index params
    p_dteyreap          := to_number(hcm_util.get_string(json_obj,'p_dteyreap'));
    p_numtime           := to_number(hcm_util.get_string(json_obj,'p_numtime'));
    p_codbon            := hcm_util.get_string(json_obj,'p_codbon');
    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_codreq            := hcm_util.get_string(json_obj,'p_codreq');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

end initial_value;

procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_staemp        temploy1.staemp%type;
    v_codreq        varchar2(40 char);
    v_codbon        varchar2(40 char);
begin
    if p_dteyreap is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
        return;
    end if;

    if p_numtime is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numtime');
        return;
    end if;

    if p_codbon is null  then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codbon');
        return;
    end if;

    if p_codcomp is null  then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
        return;
    end if;

    if p_codreq is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codreq');
        return;
    end if;

    if p_dteyreap <= 0 then
        param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
        return;
    end if;

    b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
    if param_msg_error is not null then
        return;
    end if;
    /*if length(p_codcomp) < 40 then
        p_codcomp := p_codcomp||'%';
    end if;*/

    begin
        select codcodec into v_codbon
          from tcodbons
         where codcodec = p_codbon;
    exception when no_data_found then
        v_codbon := null;
    end;
    if v_codbon is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCODBONS');
        return;
    end if;

    begin
        select codempid,staemp
          into v_codreq,v_staemp
          from temploy1
         where codempid = p_codreq;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
        return;
    end;

    if v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102', global_v_lang,'p_codreq');
        return;
    elsif v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang,'p_codreq');
        return;
    end if;

end;

procedure  insert_data_parallel (p_codapp  in varchar2,
                                 p_coduser in varchar2,
                                 p_proc    in out number) is

    v_num       number ;
    v_proc      number := p_proc ;
    v_numproc   number ;
    v_rec       number ;
    v_flgsecu   boolean := false;
    v_secur     boolean := false;
    v_flgfound  boolean := false;
    v_zupdsal   varchar2(1);

    cursor c_temploy is
        select codempid,codcomp,numlvl
          from temploy1
         where codcomp  like p_codcomp||'%'
           and staemp   in('1','3')
        order by codempid;

begin
    delete tprocemp where codapp = p_codapp and coduser = p_coduser  ; commit;
    commit ;

    begin
        select count(codempid) into  v_rec
          from temploy1
         where codcomp  like p_codcomp||'%'
           and staemp   in('1','3');
    end;
    v_num    := greatest(trunc(v_rec/v_proc),1);
    v_rec    := 0;

    for i in c_temploy loop
        v_flgfound := true;
        v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_flgsecu then
            v_secur   := true;
            v_rec     := v_rec + 1 ;
            v_numproc := trunc(v_rec / v_num) + 1 ;
            if v_numproc > v_proc then
                v_numproc  := v_proc ;
            end if;

            insert into tprocemp (codapp,coduser,numproc,codempid)
                   values        (p_codapp,p_coduser,v_numproc,i.codempid);
        end if;
    end loop;

    if not v_flgfound then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
    end if;

    if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;

    p_proc := v_numproc;
    commit;

end;

procedure get_process (json_str_input in clob, json_str_output out clob) is
begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_process;

procedure process_data(json_str_output out clob) is
    obj_row         json := json();
    obj_row2        json := json();
    obj_data        json;
    obj_data2       json;
    v_row           number := 0;
    v_flgpass		boolean := true;
    p_codapp        varchar2(100 char) := 'HRAP54B';
    v_numproc       number := 1 ;
    v_response      varchar2(4000);
    v_countemp      number := 0 ;
    v_data          varchar2(1 char) := 'N';
    v_check         varchar2(1 char) := 'Y';
    v_count         number := 0;

    v_numemp        number := 0 ;
    v_amtbon        number := 0 ;
    v_amtsal        number := 0 ;
    v_qtybon        number := 0 ;
    v_grdyear       number;
    v_grdnumtime    number;
    v_flgbonus      varchar2(1 char) ;

    cursor c_ttbonus is
        select dteyreap,numtime,codbon,codempid,codcomp,
               codpos,jobgrade,
               typpayroll,dteempmt,qtydaybon,grade,
               amtsal,amtsalc,qtybon,amtbon,pctdedbo
          from ttbonus
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codcomp like p_codcomp||'%'
           and codbon   = p_codbon
        order by codempid;
begin

    begin
        select count(*) into v_count
          from ttbonparh
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codcomp  = p_codcomp
           and codbon   = p_codbon
           and codappr  is not null
           and dteappr  is not null;
    exception when no_data_found then
        v_count := 0;
    end;

    if v_count <> 0 then
        delete from tbonus
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codbon   = p_codbon;

        for i in c_ttbonus loop
            begin
                select grdyear,grdnumtime
                  into v_grdyear,v_grdnumtime
                  from tbonparh
                 where codbon   = i.codbon
                   and dteyreap = i.dteyreap
                   and numtime  = i.numtime
                   and i.codcomp like codcomp||'%'
                   and codcomp = (select max(codcomp) --–เช็คตรงนี้เพื่อหาหน่วยงานที่ใกล้ตัวพนักงานที่สุดเพียง 1 เงื่อนไขการจ่ายโบนัส
                                    from tbonparh
                                   where codbon   = i.codbon
                                     and dteyreap = i.dteyreap
                                     and numtime  = i.numtime
                                     and i.codcomp	like codcomp||'%')
                   and rownum <= 1;
            exception when no_data_found then
                null;
            end;

            begin
                select flgbonus into v_flgbonus
                  from tappemp
                 where codempid = i.codempid
                   and dteyreap = v_grdyear
                   and numtime  = v_grdnumtime;
            exception when no_data_found then
                v_flgbonus   := 'N';
            end;

            insert into tbonus  (dteyreap,numtime,codbon,
                                 codempid,codcomp,typpayroll,
                                 dteempmt,qtydaybon,grade,
                                 amtsal,amtsalc,qtybon,
                                 amtbon,flgbonus,pctdedbo,
                                 amtnbon,desnote,codcombn,
                                 codreq,flgtrnpy,staappr,
                                 codpos,jobgrade,
                                 codcreate,coduser)
                    values      (i.dteyreap,i.numtime,i.codbon,
                                 i.codempid,i.codcomp,i.typpayroll,
                                 i.dteempmt,i.qtydaybon,i.grade,
                                 i.amtsal,i.amtsalc,i.qtybon,
                                 i.amtbon,v_flgbonus,i.pctdedbo,
                                 i.amtbon,null,i.codcomp,
                                 p_codreq,'N','P',
                                 i.codpos,i.jobgrade,
                                 global_v_coduser,global_v_coduser  );

        end loop;
    else
        insert_data_parallel (p_codapp,global_v_coduser,v_numproc)  ;
        hraps9b_batch.start_process('HRAP54B',global_v_coduser,global_v_lang,v_numproc,p_codapp,p_dteyreap,p_numtime,p_codcomp,p_codbon)  ;
    end if;
    -->> Output

    begin
        select count(codempid), sum(stddec(amtbon,codempid,v_chken)) , sum(stddec(amtsal,codempid,v_chken))
          into v_numemp,v_amtbon,v_amtsal
          from tbonus
         where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codcomp  like p_codcomp||'%'
           and codbon   = p_codbon;
    exception when no_data_found then
        null;
    end;

    if nvl(v_amtsal,0) <> 0 then
        v_qtybon := round(v_amtbon / v_amtsal,2);
    end if;

    obj_data := json();
    obj_data.put('coderror', '200');
    obj_data.put('numemp', nvl(v_numemp,0));
    obj_data.put('amtbon', nvl(v_amtbon,0));
    obj_data.put('qtybon', nvl(v_qtybon,0));

    if param_msg_error is null then
        obj_row := json();
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response      := get_response_message(null,param_msg_error,global_v_lang);
        obj_row.put('coderror', '200');
        obj_row.put('result', obj_data);
        obj_row.put('response', hcm_util.get_string(json(v_response),'response'));
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
end;


  procedure get_detail_payment(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_main        json_object_t;
    obj_data_head   json_object_t;
    obj_row         json_object_t;
    v_row		    number := 0;
    v_amtpay        number := 0;
    v_amtbon        number := 0;
    v_difbudg       number := 0;
    v_amtbudg       number;
    v_ratecond      varchar2(1000 char);
    v_typbon        varchar2(1 char);

    cursor c_tbonus is
      select codempid,grade,numcond,codpos,jobgrade,dteempmt,qtybon,pctdedbo,
             stddec(amtsal,codempid,v_chken) amtsal,
             stddec(amtnbon,codempid,v_chken) amtnbon
        from tbonus
       where dteyreap  = p_dteyreap
         and numtime   = p_numtime
         and codbon    = p_codbon
      order by codcomp,codempid,codpos;

  begin
    initial_value(json_str_input);

    begin
        select typbon,amtbudg into v_typbon,v_amtbudg
          from ttbonparh
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codbon   = p_codbon;
    exception when no_data_found then
        v_typbon  := 1;
        v_amtbudg := 0;
    end;

    obj_row := json_object_t();
    for i in c_tbonus loop
        v_row      := v_row + 1;
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
--        if v_typbon = 1 then
--            obj_data.put('grade', i.grade);
--        else
--            obj_data.put('numcond', i.numcond);
--            begin
--                select ratecond into v_ratecond
--                  from ttbonparc
--                 where codcomp  = p_codcomp
--                   and dteyreap = p_dteyreap
--                   and numtime  = p_numtime
--                   and codbon   = p_codbon
--                   and numseq   = i.numcond;
--            exception when no_data_found then
--                null;
--            end;
--            obj_data.put('ratecond', v_ratecond);
--        end if;
--        obj_data.put('codempid', i.codempid);
--        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
--        obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang));
--        obj_data.put('jobgrade', i.jobgrade);
--        obj_data.put('dteempmt', to_char(i.dteempmt,'dd/mm/yyyy'));
--        obj_data.put('amtsal', i.amtsal );
--        obj_data.put('qtybon', i.qtybon);
--        obj_data.put('pctdedbo', i.pctdedbo);
--        obj_data.put('amtnbon', i.amtnbon);

        if v_typbon = 1 then
            obj_data.put('grade', i.grade);
        else
            obj_data.put('seqno', i.numcond);
            begin
                select ratecond into v_ratecond
                  from ttbonparc
                 where codcomp  = p_codcomp
                   and dteyreap = p_dteyreap
                   and numtime  = p_numtime
                   and codbon   = p_codbon
                   and numseq   = i.numcond;
            exception when no_data_found then
                null;
            end;
            obj_data.put('detail', v_ratecond);
        end if;

        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang));
        obj_data.put('jobgrade', i.jobgrade);
        obj_data.put('dtewkstart', to_char(i.dteempmt,'dd/mm/yyyy'));
        obj_data.put('qtysal', i.amtsal );
        obj_data.put('payrate', i.qtybon);
        obj_data.put('pctdbon', i.pctdedbo);
        obj_data.put('amount', i.amtnbon);


        v_amtbon := v_amtbon + nvl(i.amtnbon,0);
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;

    v_difbudg := v_amtbon - v_amtbudg;
    obj_data_head := json_object_t();
    obj_data_head.put('coderror', '200');
    obj_data_head.put('amtpaybon', nvl(v_amtbon,0));
    obj_data_head.put('amtdiff', nvl(v_difbudg,0));
    if v_typbon = 1 then
        obj_data_head.put('setcondin', 'A');
    else
        obj_data_head.put('setcondin', 'C');
    end if;
    obj_main := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('header', obj_data_head);
    obj_main.put('table', obj_row);

    if param_msg_error is null then
      json_str_output := obj_main.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail_payment;

	procedure sendmail (json_str_input in clob, json_str_output out clob) as
		json_obj		    Json_object_t;
		v_codform		    tfwmailh.codform %type;
		v_msg_to            clob;
		v_template_to       clob;
		v_func_appr         tfwmailh.codappap%type;
		v_rowid             rowid;
		v_error			    terrorm.errorno%type;
		tbonus_codempid	    tbonus.codempid%type;
		tbonus_codreq		tbonus.codempid%type;
		flg			        number;
		obj_respone		    Json_object_t;
		obj_respone_data    varchar(500);
		obj_sum			    Json_object_t;
        v_approvno          tbonus.approvno%type;

        cursor c_tbonus is
          select codempid,staappr,
                 rowid rwid
            from tbonus
           where dteyreap  = p_dteyreap
             and numtime   = p_numtime
             and codbon    = p_codbon
          order by codcomp,codempid,codpos;
	begin
        initial_value(json_str_input);

        for r1 in c_tbonus loop
            begin
                v_error := chk_flowmail.send_mail_for_approve('HRAP54B', r1.codempid, global_v_codempid, global_v_coduser, null, 'HRAP54BP2', 210, 'E', 'P', 1, null, null,'TBONUS',r1.rwid, '1', null);
            exception when others then
                v_error := '2403';
            end;            
        end loop; 

        IF v_error in ('2046','2402') THEN
            param_msg_error := get_error_msg_php('HR2046', global_v_lang);
        ELSE
            param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
        END IF;

        if param_msg_error_mail is null then
          json_str_output := get_response_message(200,param_msg_error,global_v_lang);
        else
          json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
	end ;
end HRAP54B;

/

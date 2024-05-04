--------------------------------------------------------
--  DDL for Package Body HRAP39B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP39B" as

procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
begin
    v_chken             := hcm_secur.get_v_chken;

    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    -- index params
    p_dteyreap          := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codreq            := hcm_util.get_string_t(json_obj,'p_codreq');
    p_param_json        := hcm_util.get_json_t(json_obj,'params');


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

end initial_value;


procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_staemp        temploy1.staemp%type;
    v_codreq        varchar2(40 char);
begin
    if p_dteyreap is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
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
    end if; */

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
      v_numproc   number := 0;
      v_rec       number ;
      v_flgsecu   boolean := false;
      v_secur     boolean := false;
      v_flgfound  boolean := false;
      v_chk_emp   boolean := false;
      v_zupdsal   varchar2(1);
      v_numtime   number;
      v_grade     varchar2(2 char);

    cursor c_tstdis  is
        select grade,pctwkstr,pctwkend,pctemp,pctpostr,pctpoend
          from tstdis
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
        order by grade;

      cursor c_tappemp is
          select distinct codempid,codcomp,numlvl
            from tappemp a
           where dteyreap = p_dteyreap
             and codcomp  like p_codcomp||'%'
             and flgsal  = 'Y'
             and exists  (select 1 from tstdisd b
                           where a.codcomp   like b.codcomp||'%'
                             and b.dteyreap  = a.dteyreap
                             and b.numtime   = a.numtime
                             and b.flgsal    = 'Y'
--#5552
                             and exists(select codaplvl
                                          from tempaplvl
                                         where dteyreap = a.dteyreap
                                           and numseq  = a.numtime
                                           and codaplvl = b.codaplvl
                                           and codempid = a.codempid)
--#5552
                             )
          order by codempid;

begin
        delete tprocemp where codapp = p_codapp and coduser = p_coduser  ; commit;
        commit ;

        for r_tstdis in c_tstdis loop
          v_grade   := r_tstdis.grade;
          v_chk_emp := false;
          for i in c_tappemp loop
              v_chk_emp := true;
              v_flgfound := true;
              v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
              if v_flgsecu then
                  v_secur   := true;

                  insert into tprocemp (codapp,coduser,numproc,codempid)
                         values        (p_codapp,p_coduser,v_numproc + 1,i.codempid);

              end if;
          end loop;
          if v_chk_emp then
            v_numproc := v_numproc + 1;
          end if;
        end loop;

        if not v_flgfound then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPEMP');
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
    param_json_row  json_object_t;
    v_row           number := 0;
    v_flgpass		boolean := true;
    p_codapp        varchar2(100 char) := 'HRAP39B';
    v_numproc       number := 1 ;
    v_response      varchar2(4000);
    v_countemp      number := 0 ;
    v_data          varchar2(1 char) := 'N';
    v_check         varchar2(1 char) := 'Y';

    v_codpos        varchar2(100 char);
    v_typpayroll    varchar2(100 char);
    v_numlvl        number;
    v_jobgrade      varchar2(100 char);
    v_qtywork       number;


    cursor c_tstdis  is
        select pctpostr,pctpoend,pctactstr,pctactend
          from tstdis
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
           and pctactstr is not null
        order by grade;

    cursor c_tappraism is
        select  a.codempid,a.dteyreap,a.codcomp,a.flgsal,a.qtypuns,a.qtyta,a.grade,
                a.qtyscor,a.pctsal,a.pctdsal,a.amtmidsal,a.amtsalo,a.amtbudg,a.amtsaln,
                a.amtceiling,a.amtminsal,a.amtover,a.amtpayover,
                b.codpos,b.typpayroll,b.numlvl,
                b.jobgrade,trunc(months_between(trunc(sysdate),b.dteempmt)) qtywork
          from tappraism a, temploy1 b
         where a.codcomp  like p_codcomp ||'%'
           and a.dteyreap = p_dteyreap
           and a.codempid = b.codempid
        order by a.codempid;
begin

    v_check := 'Y';
    for i in c_tstdis loop
        v_data := 'Y';
        if nvl(i.pctpostr,0) <> nvl(i.pctactstr,0) and nvl(i.pctpoend,0) <> nvl(i.pctactend,0) then
            v_check := 'N';
            exit;
        end if;
    end loop;

    if v_data = 'N' then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSTDIS');
    end if;

    if v_check = 'Y' then
        delete tapprais where codcomp like p_codcomp ||'%' and dteyreap = p_dteyreap;
        commit;

        for i in c_tappraism loop
            insert into tapprais (  codempid,dteyreap,codcomp,
                                    codpos,typpayroll,numlvl,
                                    jobgrade,qtywork,flgsal,
                                    qtypuns,qtyta,grade,
                                    qtyscore,pctcalsal,pctdsal,
                                    pctadjsal,amtmidsal,amtsal,
                                    amtbudg,amtsaln,amtceiling,
                                    amtminsal,amtover,amtlums,
                                    flgtrnpm,flgtrnpy,staappr,
                                    codcreate,coduser)
                           values   (i.codempid,i.dteyreap,i.codcomp,
                                    i.codpos,i.typpayroll,i.numlvl,
                                    i.jobgrade,i.qtywork,i.flgsal,
                                    i.qtypuns,i.qtyta,i.grade,
                                    i.qtyscor,i.pctsal,i.pctdsal,
                                    null,i.amtmidsal,i.amtsalo,
                                    i.amtbudg,i.amtsaln,i.amtceiling,
                                    i.amtminsal,i.amtover,i.amtpayover,
                                    'N','N','P',
                                    global_v_coduser,global_v_coduser);
        end loop;
    else
        insert_data_parallel (p_codapp,global_v_coduser,v_numproc)  ;
        hrap3xe_batch.start_process('HRAP39B',global_v_coduser,v_numproc,p_codapp,p_codcomp,p_dteyreap,p_param_json.to_clob)  ;
    end if;

    if param_msg_error is null then
        obj_row := json();
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response        := get_response_message(null,param_msg_error,global_v_lang);
        obj_row.put('coderror', '200');
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

procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		  number := 0;
    v_amtpay      number := 0;

    cursor c_tapprais is
      select codempid,jobgrade,grade,pctcalsal,pctadjsal,
             stddec(amtmidsal,codempid,v_chken) amtmidsal,
             stddec(amtminsal,codempid,v_chken) amtminsal,
             stddec(amtsal,codempid,v_chken) amtsal,
             stddec(amtsaln,codempid,v_chken) amtsaln,
             stddec(amtover,codempid,v_chken) amtover
        from tapprais
       where codcomp   like p_codcomp||'%'
         and dteyreap  = p_dteyreap
      order by codempid;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tapprais loop
        v_row      := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image',get_emp_img(i.codempid));
        obj_data.put('codempid',i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
        obj_data.put('jobgrade', get_tcodec_name('TCODJOBG',i.jobgrade,global_v_lang));
        obj_data.put('amtmidsal', nvl(i.amtmidsal,0));
        obj_data.put('grade', i.grade);
        obj_data.put('pctupsal', nvl(i.pctadjsal, i.pctcalsal));
        obj_data.put('amtsal', nvl(i.amtsal,0));
        obj_data.put('amtsaln', nvl(i.amtsaln,0));
        obj_data.put('amtover', nvl(i.amtover,0));
        obj_data.put('amtbelmn', nvl(i.amtminsal,0) - nvl(i.amtsaln,0));

        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

	procedure sendmail (json_str_input in clob, json_str_output out clob) as
		json_obj		    Json_object_t;
		v_codform		    tfwmailh.codform %type;
		v_msg_to            clob;
		v_template_to       clob;
		v_func_appr         tfwmailh.codappap%type;
		v_rowid             rowid;
		v_error			    terrorm.errorno%type;
		tapprais_codempid	tapprais.codempid%type;
		tapprais_codreq		tapprais.codempid%type;
		flg			        number;
		obj_respone		    Json_object_t;
		obj_respone_data    varchar(500);
		obj_sum			    Json_object_t;
        v_approvno          tapprais.approvno%type;
	begin
		json_obj            := Json_object_t(json_str_input);
		v_rowid             := hcm_util.get_string_t(json_obj,'v_rowid');
		tapprais_codempid   := hcm_util.get_string_t(json_obj,'param_codempid');
		tapprais_codreq     := hcm_util.get_string_t(json_obj,'param_codsend');
		flg                 := hcm_util.get_string_t(json_obj,'v_flag_confirm');
		if (flg = '0') then
			param_msg_error     := get_error_msg_php('HR0007', global_v_lang);
			json_str_output     := Get_response_message(NULL, param_msg_error,global_v_lang);
			obj_respone         := Json_object_t(json_str_output);
			obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
			obj_sum             := Json_object_t();
			obj_sum.put('coderror','200');
			obj_sum.put('flg_send',true);
			obj_sum.put('desc_coderror',obj_respone_data);
			json_str_output := obj_sum.to_clob;
		else
            begin
                select nvl(approvno,0) + 1
                  into v_approvno
                  from tapprais
                 where rowid = v_rowid;
            exception when no_data_found then
				v_approvno := 1;
			end;

            v_error := chk_flowmail.send_mail_for_approve('HRAP39B', tapprais_codempid, tapprais_codreq, global_v_coduser, null, 'HRAP39BP1', 99, 'E', 'P', v_approvno, null, null,'TAPPRAIS',v_rowid, '1', null);

			param_msg_error     := get_error_msg_php('HR'||v_error, global_v_lang);
			json_str_output     := Get_response_message(NULL, param_msg_error,global_v_lang);
			obj_respone         := Json_object_t(json_str_output);
			obj_respone_data    := hcm_util.get_string_t(obj_respone, 'response');
			obj_sum             := Json_object_t();
			obj_sum.put('coderror','200');
			obj_sum.put('flg_send',false);
			obj_sum.put('desc_coderror',obj_respone_data);
			json_str_output := obj_sum.to_clob;
		end if;
  exception when others then
		param_msg_error := get_error_msg_php('HR7522', global_v_lang);
		json_str_output := get_response_message('400', param_msg_error, global_v_lang);
	end ;

end HRAP39B;

/

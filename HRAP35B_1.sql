--------------------------------------------------------
--  DDL for Package Body HRAP35B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP35B" as

  procedure initial_value (json_str in clob) is
      json_obj        json_object_t;
  begin
      v_chken             := hcm_secur.get_v_chken;

      json_obj            := json_object_t(json_str);
      -- global
      global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
      global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
      global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

      -- index params
      p_dteyreap          := to_number(hcm_util.get_string_t(json_obj,'p_dteyreap'));
      p_numtime           := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
      p_codcacultr        := hcm_util.get_string_t(json_obj,'p_codcacultr');
      p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
      p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
      p_codreq            := hcm_util.get_string_t(json_obj,'p_codreq');
      p_flgcal            := hcm_util.get_string_t(json_obj,'p_flgcal');


      hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
      v_flgsecu		    boolean;
      v_numlvl		    temploy1.numlvl%type;
      v_staemp          temploy1.staemp%type;
      v_codreq          varchar2(40 char);
      v_exist			varchar2(1) := 'N';
      v_pctkpicp        number;
      v_pctkpirt        number;
      v_qtyscorn        number;
      v_qtyscor         number;
      v_dteapend        tstdisd.dteapend%type;

    cursor c_tappemp is
        select a.codempid,dteyreap,numtime,a.codaplvl,b.staemp,a.codcomp,
               qtybeh3,qtycmp3,qtykpie3,qtykpid,qtykpic,qtytot3,qtyta,qtypuns,flgappr
          from tappemp a,temploy1 b
         where dteyreap   = p_dteyreap
           and numtime    = p_numtime
           and a.codcomp  like p_codcomp||'%'
           and a.codempid = nvl(p_codempid,a.codempid)
           and a.codempid = b.codempid
        order by a.codempid;

  begin
      if p_dteyreap is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
          return;
      end if;
      if p_numtime is null then
          param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numtime');
          return;
      end if;
      if p_codcomp is null and p_codempid is null then
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
      if p_numtime <= 0 then
          param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_numtime');
          return;
      end if;

      if p_codempid is not null then
        p_codcomp := null;
      else
        b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);
      end if;

      if p_codcomp is not null then
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
          if param_msg_error is not null then
              return;
          end if;
          if length(p_codcomp) < 40 then
              p_codcomp := p_codcomp||'%';
          end if;
      else
          begin
              select codcomp,typpayroll,numlvl,staemp
                into p_codcomp,b_var_typpayroll,v_numlvl,v_staemp
                from temploy1
               where codempid = p_codempid;

              if v_staemp = '0' then
                  param_msg_error := get_error_msg_php('HR2102', global_v_lang,'p_codempid');
                  return;
              elsif v_staemp = '9' then
                  param_msg_error := get_error_msg_php('HR2101', global_v_lang,'p_codempid');
                  return;
              end if;

              b_var_codcompy := hcm_util.get_codcomp_level(p_codcomp,1);
              v_flgsecu      := secur_main.secur1(p_codcomp,v_numlvl,global_v_coduser,
                                                  global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
              if not v_flgsecu then
                param_msg_error := get_error_msg_php('HR3007', global_v_lang);
                return;
              end if;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TEMPLOY1');
              return;
          end;
    end if;

      begin
        select dteapend into v_dteapend
          from tstdisd
         where p_codcomp like codcomp||'%'
           and dteyreap  = p_dteyreap
           and numtime   = p_numtime
--#5552
           and exists(select codaplvl
                      from tempaplvl
                     where dteyreap = p_dteyreap
                       and numseq  = p_numtime
                       and codaplvl = tstdisd.codaplvl
                       and codempid = nvl(p_codempid, codempid))
--#5552
               and rownum = 1;
        exception when no_data_found then
           v_dteapend := trunc(sysdate);
      end;

       /* #7449  user18 2022/01/06
      if trunc(sysdate) < v_dteapend then
          param_msg_error := get_error_msg_php('AP0064', global_v_lang);
          return;
      end if;  #7449  user18 2022/01/06 */ 


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

      for r_tappemp in c_tappemp loop
        v_exist := 'Y';

        begin
            select pctkpicp,pctkpirt
              into v_pctkpicp,v_pctkpirt
              from taplvl
             where r_tappemp.codcomp like codcomp||'%'
               and codaplvl = r_tappemp.codaplvl
               and dteeffec = (select max(dteeffec)
                                 from taplvl
                                where r_tappemp.codcomp like codcomp||'%'
                                  and codaplvl = r_tappemp.codaplvl
                                  and dteeffec <= trunc(sysdate))
            order by codcomp desc;
        exception when no_data_found then
            null;
        end;

        if nvl(v_pctkpicp,0) <> 0 then
            begin
                select sum(qtyscorn) into v_qtyscorn
                  from tkpidph
                 where dteyreap = r_tappemp.dteyreap
                   and numtime  = r_tappemp.numtime
                   and codcomp  = r_tappemp.codcomp;
            exception when no_data_found then
               v_qtyscorn := 0;
            end;
            if nvl(v_qtyscorn,0) = 0 then
              param_msg_error := get_error_msg_php('AP0062', global_v_lang); --'ยังไม่ได้บันทึกการประเมิน KPI หน่วยงาน';
              return;
              exit;
            end if;
        end if;

        if nvl(v_pctkpirt,0) <> 0 then
            begin
                select sum(qtyscor)  into v_qtyscor
                  from tkpicmph
                 where dteyreap = r_tappemp.dteyreap
                   and codcompy = hcm_util.get_codcomp_level(r_tappemp.codcomp,1);
            exception when no_data_found then
               v_qtyscor := 0;
            end;
            if nvl(v_qtyscor,0) = 0 then
              param_msg_error := get_error_msg_php('AP0063', global_v_lang, 'p_codcomp'); --'ยังไม่ได้บันทึกการประเมิน KPI องค์กร';
              return;
              exit;
            end if;
        end if;
      --exit;
      end loop;

    if v_exist = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPEMP');
      return;
    end if;

  end;

  procedure process_data(json_str_output out clob) is
    obj_data        json_object_t;
    v_flg           varchar2(1 char);
    v_exist			varchar2(1) := 'N';
    v_numproc  	    number:= 5;
    v_qtyproc       number:= 0;
    v_qtyerr        number:= 0;
    v_dteend  	    date;
    v_numerr	    number;
    v_err           varchar2(4000 char);
    v_response      varchar2(4000 char);
    v_numrec	    number;
    v_numqtyproc    number;
  begin
    if p_flgcal = '1' then
      hrap35b_batch.start_process (p_dteyreap,
                                   p_numtime,
                                   p_codcomp,
                                   p_codempid,
                                   p_codreq,
                                   p_flgcal,
                                   global_v_coduser,
                                   global_v_lang);
    elsif p_flgcal = '2' then
      hrap35b_batch.start_process_9box (p_dteyreap,
                                         p_numtime,
                                         p_codcomp,
                                         p_codempid,
                                         p_codreq,
                                         p_flgcal,
                                         global_v_coduser,
                                         global_v_lang);
    end if;
    -------------------------------------------------------
		v_numrec  := 0;
--		exp_text;
		-------------------------------------------------------
		v_numproc   := nvl(get_tsetup_value('QTYPARALLEL'),5);

	  v_numerr  := 0;
		for j in 1..v_numproc loop
		  begin
		   select qtyproc,qtyerr
		     into v_qtyproc,v_qtyerr
		     from tprocount
		    where codapp  like 'HRPY35B%'
		      and coduser = global_v_coduser
		      and flgproc = 'Y'
		      and numproc = j;
		  exception when no_data_found then
		  	 v_qtyproc  := 0;
		  	 v_qtyerr   := 0;
		  end;

		  v_numerr  := nvl(v_numerr,0) + nvl(v_qtyerr,0);
          v_numqtyproc := nvl(v_numqtyproc,0) + nvl(v_qtyproc,0);
		end loop;
		----------------------------------------------------------------------
		v_dteend := sysdate;
		----------------------------------------------------------------------
    ----------
    begin
	   select codempid||' - '||remark
	     into v_err
	     from tprocount
	    where codapp  like 'HRPY35B%'--= v_codapp
	      and coduser = global_v_coduser
	      and flgproc = 'E'
	      and rownum  = 1 ;
	  exception when no_data_found then
	  	 v_err := null ;
	  end;
    ----------

    /*if v_numqtyproc = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TAPPEMP');
      rollback;
    end if;*/
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      commit;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numrec', nvl(v_numrec,0));
--      obj_data.put('message',p_file_path || p_filename);

      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      v_response := get_response_message(null,param_msg_error,global_v_lang);
      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));

      json_str_output := obj_data.to_clob;
    end if;
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

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row		  number := 0;
    v_amtpay      number := 0;

    cursor c_tappemp is
      select codempid,qtyta,qtypuns,qtybeh3,qtycmp3,qtykpie3,qtykpid,qtykpic,qtytot3,grdappr
        from tappemp
       where codcomp   like p_codcomp||'%'
         and dteyreap  = p_dteyreap
         and numtime   = p_numtime
         and codempid  = nvl(p_codempid,codempid)
         and flgconflhd = 'Y'
         and flgappr    = 'C'
      order by codempid;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for i in c_tappemp loop
        v_row      := v_row + 1;
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codempid',i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang) );
        obj_data.put('qtytapuns', nvl(i.qtyta,0) + nvl(i.qtypuns,0));
        obj_data.put('qtybeh', nvl(i.qtybeh3,0));
        obj_data.put('qtycmp', nvl(i.qtycmp3,0));
        obj_data.put('qtykpi', nvl(i.qtykpie3,0) + nvl(i.qtykpid,0) + nvl(i.qtykpic,0));
        obj_data.put('qtytot', nvl(i.qtytot3,0));
        obj_data.put('grade', i.grdappr);

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

end HRAP35B;

/

--------------------------------------------------------
--  DDL for Package Body HRPM4JD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPM4JD" is
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
--    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_dteeffec    := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy hh24:mi:ss');
    b_index_dteeffecen  := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy hh24:mi:ss');
    b_index_codtrn      := hcm_util.get_string_t(json_obj,'p_codtrn');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;
  --
  procedure check_index is
    v_numlvl    temploy1.numlvl%type;
    v_flgsecu   boolean := false;
    v_secure    varchar2(2000 char);
  begin
    if b_index_codempid is not null then
      begin
        select staemp,numlvl,typpayroll,dteoccup
        into   b_index_staemp,v_numlvl,b_index_typpayroll,b_index_dteoccup
        from   temploy1
        where  codempid = b_index_codempid;
      exception when others then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end ;

      if b_index_staemp = '0' then
        param_msg_error   := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;

      v_flgsecu   := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flgsecu then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

    if b_index_codcomp is not null then
      v_secure    := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcomp);
      if v_secure is not null then
        param_msg_error   := v_secure;
        return;
      end if;
    end if;
  end; --check_index
  --
  function chk_max_movemt(p_codempid varchar2,p_dteeffec date,p_numseq number) return boolean is
    cursor c1 is
      select codempid,dteeffec,numseq
      from	 ttmovemt
      where	 codempid = p_codempid
      and		 staupd in('C','U')
    union
      select codempid,dtereemp dteeffec,1 numseq
      from	 ttrehire
      where	 codempid = p_codempid
      and		 staupd in('C','U')
    union
      select codempid,dteduepr dteeffec,1 numseq
      from	 ttprobat
      where	 codempid = p_codempid
      and		 staupd in('C','U')
    union
      select codempid,dteeffec dteeffec,1 numseq
      from	 ttmistk
      where	 codempid = p_codempid
      and		 staupd in('C','U')
    union
      select codempid,dteeffec dteeffec,1 numseq
      from	 ttexempt
      where	 codempid = p_codempid
      and		 staupd in('C','U')
    order by dteeffec desc,numseq desc;
  begin
    for i in c1 loop
			if (i.dteeffec > p_dteeffec) or (i.dteeffec = p_dteeffec and i.numseq > p_numseq) then
				return(false);
			end if;
			exit;
		end loop;
		return(true);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_data          json_object_t;
    obj_row           json_object_t;
    v_rcnt            number  := 0;
    v_chk             boolean := true;
    v_response        varchar2(4000);
    cursor c1 is
      select codempid,dteeffec , numseq,codtrn,codcomp,codpos
      from	 ttmovemt
      where	 codempid   = nvl(b_index_codempid, codempid)
      and    codcomp    like b_index_codcomp||'%'
      and    codtrn     = nvl(b_index_codtrn, codtrn)
      and		 dteeffec between b_index_dteeffec and nvl(b_index_dteeffecen,dteeffec)
      and		 staupd in('C','U')
    union
      select codempid,dtereemp dteeffec,1 numseq,'0002' codtrn ,codcomp,codpos
      from	 ttrehire
      where	 codempid   = nvl(b_index_codempid, codempid)
      and    codcomp    like b_index_codcomp||'%'
      and    nvl(b_index_codtrn,'0002') = '0002'
      and		 dtereemp between b_index_dteeffec and nvl(b_index_dteeffecen,dtereemp)
      and		 staupd in('C','U')
    union
      select codempid,dteduepr dteeffec,1 numseq,decode(typproba,'1','0003', '2','0004') codtrn,codcomp,codpos
      from	 ttprobat
      where	 codempid   = nvl(b_index_codempid, codempid)
      and    codcomp    like b_index_codcomp||'%'
      and    nvl(b_index_codtrn,decode(typproba,'1','0003', '2','0004')) = decode(typproba,'1','0003', '2','0004')
      and		 dteduepr between b_index_dteeffec and nvl(b_index_dteeffecen,dteduepr)
      and		 staupd in('C','U')
    union
      select codempid,dteeffec dteeffec,1 numseq,'0005' codtrn ,codcomp,codpos
      from	 ttmistk
      where	 codempid   = nvl(b_index_codempid, codempid)
      and    codcomp    like b_index_codcomp||'%'
      and    nvl(b_index_codtrn,'0005') = '0005'
      and		 dteeffec between b_index_dteeffec and nvl(b_index_dteeffecen,dteeffec)
      and		 staupd in('C','U')
    union
      select codempid,dteeffec dteeffec,1 numseq,'0006' codtrn ,codcomp,codpos
      from	 ttexempt
      where	 codempid   = nvl(b_index_codempid, codempid)
      and    codcomp    like b_index_codcomp||'%'
      and    nvl(b_index_codtrn,'0006') = '0006'
      and		 dteeffec between b_index_dteeffec and nvl(b_index_dteeffecen,dteeffec)
      and		 staupd in('C','U')
    order by dteeffec desc,numseq desc;
  begin
    obj_row         := json_object_t();
--    param_msg_error := get_error_msg_php('HR8830',global_v_lang);
--    v_response      := get_response_message(null,param_msg_error,global_v_lang);
--    v_response      := replace(hcm_util.get_string(json(v_response),'response'),'HR8830 ','');
    for i in c1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('numseq',i.numseq);
      obj_data.put('codtrn',i.codtrn);
      obj_data.put('desc_codtrn',i.codtrn||'-'||get_tcodec_name('TCODMOVE',i.codtrn,global_v_lang));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
      obj_data.put('codpos',i.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
      if i.codtrn = '0003' then
        obj_data.put('typproba','1');
      elsif i.codtrn = '0004' then
        obj_data.put('typproba','2');
      end if;
--      v_chk := chk_max_movemt(b_index_codempid,i.dteeffec,i.numseq);
--      if not v_chk then
--        obj_data.put('flgactive','N');
--        obj_data.put('remark',v_response);
--      else
--        obj_data.put('flgactive','Y');
--        obj_data.put('remark','');
--      end if;
      obj_row.put(to_char(v_rcnt - 1),obj_data);
      end loop;
    json_str_output := obj_row.to_clob;
  end;
  -- end validate_field_submit
  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure save_cancel_ttmovemt (json_str_input in clob, json_str_output out clob) is
    obj_row           json_object_t;
    v_rcnt            number  := 0;
    v_chk             boolean := true;
    v_response        varchar2(4000);

    v_flgselect        varchar2(10);
    v_dteeffec         date;
    v_numseq           number;
    v_codtrn           ttmovemt.codtrn%type;
    v_codempid         temploy1.codempid%type;
    v_typproba         varchar2(20);

    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json    := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    for i in 0..param_json.get_size-1 loop
      v_rcnt  := i;
      param_json_row    := hcm_util.get_json_t(param_json,to_char(i));
      v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
      v_codtrn        := hcm_util.get_string_t(param_json_row,'codtrn');
      v_typproba      := hcm_util.get_string_t(param_json_row,'typproba');
      v_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
      v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');
        v_chk := chk_max_movemt(v_codempid,v_dteeffec,v_numseq);
        if not v_chk then
          param_msg_error := get_error_msg_php('HR8830',global_v_lang);
          v_response      := get_response_message(null,param_msg_error,global_v_lang);
          v_response      := hcm_util.get_string_t(json_object_t(v_response),'response');
--          v_response      := replace(hcm_util.get_string(json(v_response),'response'),'HR8830 ','');
          exit;
        end if;

        v_codtrn        := hcm_util.get_string_t(param_json_row,'codtrn');
        v_typproba      := hcm_util.get_string_t(param_json_row,'typprobat');
        v_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'),'dd/mm/yyyy');
        v_numseq        := hcm_util.get_string_t(param_json_row,'numseq');

        if v_codtrn	= '0002' then
          hrpm4jd_batch.cancel_ttrehire(v_codempid,v_dteeffec,v_codtrn,global_v_coduser);
        elsif v_codtrn	in ('0003','0004') then
          hrpm4jd_batch.cancel_ttprobat(v_codempid,v_dteeffec,v_codtrn,v_typproba,global_v_coduser);
        elsif v_codtrn	= '0005' then
          hrpm4jd_batch.cancel_ttmistk(v_codempid,v_dteeffec,v_codtrn,global_v_coduser);
--<< user20 Date: 07/09/2021  PM Module- #6140
          if v_codtrn = 'ERR' then
                param_msg_error   := get_error_msg_php('PM0090',global_v_lang);
          end if;
--<< user20 Date: 07/09/2021  PM Module- #6140
        elsif v_codtrn = '0006' then
          hrpm4jd_batch.cancel_ttexempt(v_codempid,v_dteeffec,v_codtrn,global_v_coduser);
        else
          hrpm4jd_batch.cancel_ttmovemt(v_codempid,v_dteeffec,v_codtrn,v_numseq,global_v_coduser);
        end if;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      rollback;
      obj_row   := json_object_t();
      obj_row.put('coderror','200');
      obj_row.put('response',v_response);
      obj_row.put('errorrowindex',to_char(v_rcnt));
      json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end HRPM4JD;

/

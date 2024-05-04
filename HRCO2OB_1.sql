--------------------------------------------------------
--  DDL for Package Body HRCO2OB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2OB" is
  procedure initial_value(json_str in clob) is
    json_obj                    json_object_t;
  begin
    v_chken                     := hcm_secur.get_v_chken;
    json_obj                    := json_object_t(json_str);
    global_v_coduser            := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd            := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang               := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid           := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codposo                   := upper(hcm_util.get_string_t(json_obj, 'p_codposo'));
    p_codcompao                 := upper(hcm_util.get_string_t(json_obj, 'p_codcompao'));
    p_functype                  := upper(hcm_util.get_string_t(json_obj, 'p_functype'));
    p_codempido                 := upper(hcm_util.get_string_t(json_obj, 'p_codempido'));
    p_codcompan                 := upper(hcm_util.get_string_t(json_obj, 'p_codcompan'));
    p_codposn                   := upper(hcm_util.get_string_t(json_obj, 'p_codposn'));
    p_codempidn                 := upper(hcm_util.get_string_t(json_obj, 'p_codempidn'));
    p_codapp                    := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_codapp          twkfunct.codapp%type;
    v_codcomp         tcenter.codcomp%type;
    v_codpos          tpostn.codpos%type;
    v_codempid        temploy1.codempid%type;
    v_flgsecu         boolean := false;
  begin
    if p_codapp is not null then
      begin
        select codapp
          into v_codapp
          from twkfunct
         where codapp = p_codapp;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'twkfunct');
        return;
      end;
    end if;
    if p_codcompao is not null then
      begin
        select codcomp
          into v_codcomp
          from tcenter
         where codcomp = p_codcompao;
        v_flgsecu := secur_main.secur7(p_codcompao, global_v_coduser);
        if not v_flgsecu  then
          param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
    end if;
    if p_codcompan is not null then
      begin
        select codcomp
          into v_codcomp
          from tcenter
         where codcomp = p_codcompan;
        v_flgsecu := secur_main.secur7(p_codcompan, global_v_coduser);
        if not v_flgsecu  then
          param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
    end if;
    if p_codposo is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codposo;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
    if p_codposn is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codposn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
    if p_codempido is not null then
      begin
        select codempid
          into v_codempid
          from temploy1
         where codempid = p_codempido;
        v_flgsecu := secur_main.secur2(p_codempido, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if not v_flgsecu  then
          param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    end if;
    if p_codempidn is not null then
      begin
        select codempid
          into v_codempid
          from temploy1
         where codempid = p_codempidn;
        v_flgsecu := secur_main.secur2(p_codempidn, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
        if not v_flgsecu  then
          param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    end if;
  end;

  procedure data_process(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      if p_functype ='R' then
        if p_codempidn is not null then
          p_typeapp :='4';
        else
          p_typeapp :='3';
        end if;
        begin
          update twkflowd
            set codcompa = p_codcompan,
                codposa  = p_codposn,
                codempa  = p_codempidn,
                typeapp  = p_typeapp,
                coduser  = global_v_coduser
          where nvl(codcompa, '!@#') = nvl(p_codcompao, '!@#')
            and nvl(codposa, '!@#')  = nvl(p_codposo, '!@#')
            and nvl(codempa, '!@#')  = nvl(p_codempido, '!@#');
        end;
      end if;
      begin
        update tempaprq a
            set a.codcompap = p_codcompan,
                a.codposap  = p_codposn,
                a.codempap  = p_codempidn,
                coduser     = global_v_coduser
          where nvl(a.codcompap, '!@#') = nvl(p_codcompao, '!@#')
            and nvl(a.codposap, '!@#')  = nvl(p_codposo, '!@#')
            and nvl(a.codempap, '!@#')  = nvl(p_codempido, '!@#')
            and a.codapp                = nvl(p_codapp, a.codapp)
            and (
                exists(select b.codempid from tempch b     where a.codapp = 'HRES32E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tmovereq b   where a.codapp = 'HRES34E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from trefreq b    where a.codapp = 'HRES36E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tcompln b    where a.codapp = 'HRES3BE' and a.codempid = b.codempid ) -- and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tleaverq b   where a.codapp = 'HRES62E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.seqno  and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tloanreq b   where a.codapp = 'HRES77E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from ttimereq b   where a.codapp = 'HRES6AE' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tworkreq b   where a.codapp = 'HRES6DE' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.seqno  and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from ttrnreq b    where a.codapp = 'HRES6IE' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from ttotreq b    where a.codapp = 'HRES6KE' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tleavecc b   where a.codapp = 'HRES6ME' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.seqno  and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tmedreq b    where a.codapp = 'HRES71E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tobfreq b    where a.codapp = 'HRES74E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from ttravreq b   where a.codapp = 'HRES81E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tresreq b    where a.codapp = 'HRES86E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tjobreq b    where a.codapp = 'HRES88E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from ttrncerq b   where a.codapp = 'HRES91E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr  in('P','A'))
             or exists(select b.codempid from ttrncanrq b  where a.codapp = 'HRES93E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.stappr  in('P','A'))
             or exists(select b.codempid from treplacerq b where a.codapp = 'HRES95E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tpfmemrq b   where a.codapp = 'HRESS2E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.seqno  and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
             or exists(select b.codempid from tircreq b    where a.codapp = 'HRESS4E' and a.codempid = b.codempid and a.dtereq = b.dtereq and a.numseq = b.numseq and a.approvno =(nvl(b.approvno,0)+1) and b.staappr in('P','A'))
            );
      end;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end data_process;
end HRCO2OB;

/

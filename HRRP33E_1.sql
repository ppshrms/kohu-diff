--------------------------------------------------------
--  DDL for Package Body HRRP33E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP33E" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    logic			    json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');

    p_condition         := hcm_util.get_string_t(json_obj,'p_condition');
    p_stasuccr          := hcm_util.get_string_t(json_obj,'p_stasuccr');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_dteposdue         := to_date(hcm_util.get_string_t(json_obj,'p_dteposdue'),'ddmmyyyy');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_datarows          := hcm_util.get_json_t(json_obj,'p_datarows');
    p_codemprq          := hcm_util.get_string_t(json_obj,'p_codemprq');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_code1         varchar2(3000);
    v_code2         varchar2(3000);
    v_code3         varchar2(3000);
    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;

    v_cursor        number;
    v_codcomp       tpromote.codcomp%type;
    v_idx           number := 0;
    v_codcompn      temploy1.codcomp%type;
    v_codposn       temploy1.codpos%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_dteposdue     tposempd.dteposdue%type;
    v_tsuccpln      tsuccpln%rowtype;
    v_staappr       tpromote.staappr%type;
    cursor c1 is
        select *
          from tpromote
         where get_compful(codcomp) like p_codcomp||'%'
           and codpos = p_codpos    
           --and dtereq = p_dtereq  --#7131 || User39 || 06/11/2021
           and to_char(dtereq,'dd/mm/yyyy') = to_char(p_dtereq,'dd/mm/yyyy')   --#7131 || User39 || 06/11/2021        
           /*and ((p_condition = '1' and stapromote = '4') or (p_condition = '2' and stapromote in ('1','2','3')))*/;
    cursor c2 is
        select *
          from tpromoted
         where get_compful(codcomp) = get_compful(v_codcomp)
           and codpos = p_codpos
           --and dtereq = p_dtereq  --#7131 || User39 || 06/11/2021
           and to_char(dtereq,'dd/mm/yyyy') = to_char(p_dtereq,'dd/mm/yyyy')  --#7131 || User39 || 06/11/2021                  
      order by codempid;

    cursor c3 is
        select a.*
          from tposempd a
         where get_compful(a.codcomp) like p_codcomp||'%'
           and a.codpos = p_codpos          
           and a.dteposdue = p_dteposdue
           and not exists ( select codempid
                              from tpromoted
                             where get_compful(codcomp) like p_codcomp||'%'
                               and codpos = p_codpos
                               --and dtereq = p_dtereq  --#7131 || User39 || 06/11/2021
                               and to_char(dtereq,'dd/mm/yyyy') = to_char(p_dtereq,'dd/mm/yyyy') --#7131 || User39 || 06/11/2021                              
                               and codempid = a.codempid )
      order by codempid;

    cursor c4 is
        select *
          from tsuccpln
         where get_compful(codcomp) like p_codcomp||'%'
           and codpos = p_codpos
           and numseq = nvl(p_numseq,numseq)                    
           and stasuccr = nvl(p_stasuccr,stasuccr)
           and not exists ( select codempid
                              from tpromoted
                             where get_compful(codcomp) like p_codcomp||'%'
                               and codpos = p_codpos
                               --and dtereq = p_dtereq  --#7131 || User39 || 06/11/2021
                               and to_char(dtereq,'dd/mm/yyyy') = to_char(p_dtereq,'dd/mm/yyyy')  --#7131 || User39 || 06/11/2021                              
                               and codempid = tsuccpln.codempid )
      order by numseq;
  begin
    --table
    v_rcnt  := 0;
    obj_row := json_object_t();
--    v_staappr := 'P'; --#7131 || User39 || 06/11/2021

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_codcomp     := r1.codcomp;
      --v_staappr     := r1.staappr;   --#7131 || User39 || 06/11/2021
      v_staappr     := nvl(r1.staappr,'P');  --#7131 || User39 || 06/11/2021
      for r2 in c2 loop
        v_flgsecu := secur_main.secur2(r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
            v_rcnt        := v_rcnt+1;
            begin
                select codcomp, codpos
                  into v_codcompn, v_codposn
                  from temploy1
                 where codempid = r2.codempid;
            exception when no_data_found then
                v_codcompn  := NULL;
                v_codposn  := NULL;
            end;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(get_emp_img(r2.codempid),r2.codempid));
            obj_data.put('codempid',r2.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r2.codempid,global_v_lang));
            obj_data.put('codcompn',v_codcompn);
            obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
            obj_data.put('codposn',v_codposn);
            obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
            obj_data.put('staappr',r2.staappr);
            obj_data.put('flgAdd',false);
            obj_data.put('flgFirstLoad',true);

            if r1.stapromote = '4' then
                begin
                    select dteposdue
                      into v_dteposdue
                      from tposempd
                     where get_compful(codcomp) like p_codcomp||'%'
                       and codpos = p_codpos
                       and codempid = r2.codempid;
                exception when no_data_found then
                    v_dteposdue := null;
                    begin
                        select *
                          into v_tsuccpln
                          from tsuccpln
                         where get_compful(codcomp) like p_codcomp||'%'
                           and codpos = p_codpos
                           and codempid = r2.codempid
                           and rownum = 1;

                        obj_data.put('numseq',v_tsuccpln.numseq);
                        obj_data.put('stasuccr',v_tsuccpln.stasuccr);
                        obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', v_tsuccpln.stasuccr, global_v_lang));
                        obj_data.put('dteappr',to_char(v_tsuccpln.dteappr,'dd/mm/yyyy'));
                        obj_data.put('codappr',v_tsuccpln.codappr);
                        obj_data.put('desc_codappr',get_temploy_name(v_tsuccpln.codappr,global_v_lang));
                        obj_data.put('dteyear',v_tsuccpln.dteyear);
                        obj_data.put('numtime',v_tsuccpln.numtime);
                    exception when no_data_found then
                        v_tsuccpln := null;
                    end;
                end;
                obj_data.put('dteposdue',to_char(v_dteposdue,'dd/mm/yyyy'));
            else
                begin
                    select *
                      into v_tsuccpln
                      from tsuccpln
                     where get_compful(codcomp) like p_codcomp||'%'
                       and codpos = p_codpos
                       and numseq = nvl(p_numseq,numseq)
                       and stasuccr = nvl(p_stasuccr,stasuccr)
                       and rownum = 1 --User37 #7022 04/10/2021 
                       and codempid = r2.codempid;
                exception when no_data_found then
                    begin
                        select *
                          into v_tsuccpln
                          from tsuccpln
                         where get_compful(codcomp) like p_codcomp||'%'
                           and codpos = p_codpos
                           and stasuccr = nvl(p_stasuccr,stasuccr)
                           and codempid = r2.codempid
                           and rownum = 1;
                    exception when no_data_found then
                        begin
                            select *
                              into v_tsuccpln
                              from tsuccpln
                             where get_compful(codcomp) like p_codcomp||'%'
                               and codpos = p_codpos
                               and codempid = r2.codempid
                               and rownum = 1;
                        exception when no_data_found then
                            v_tsuccpln := null;
                            begin
                                select dteposdue
                                  into v_dteposdue
                                  from tposempd
                                 where get_compful(codcomp) like p_codcomp||'%'
                                   and codpos = p_codpos
                                   and codempid = r2.codempid;
                                obj_data.put('dteposdue',to_char(v_dteposdue,'dd/mm/yyyy'));
                            exception when no_data_found then
                                v_dteposdue := null;
                            end;
                        end;
                    end;
                end;

                obj_data.put('numseq',v_tsuccpln.numseq);
                obj_data.put('stasuccr',v_tsuccpln.stasuccr);
                obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', v_tsuccpln.stasuccr, global_v_lang));
                obj_data.put('dteappr',to_char(v_tsuccpln.dteappr,'dd/mm/yyyy'));
                obj_data.put('codappr',v_tsuccpln.codappr);
                obj_data.put('desc_codappr',get_temploy_name(v_tsuccpln.codappr,global_v_lang));
                obj_data.put('dteyear',v_tsuccpln.dteyear);
                obj_data.put('numtime',v_tsuccpln.numtime);
            end if;

            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    end loop;

    if v_staappr = 'P' then
        if p_condition = '1' then
          for r3 in c3 loop
            v_flgsecu := secur_main.secur2(r3.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_flgsecu then
                v_rcnt        := v_rcnt+1;
                select codcomp, codpos
                  into v_codcompn, v_codposn
                  from temploy1
                 where codempid = r3.codempid;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('image', nvl(get_emp_img(r3.codempid),r3.codempid));
                obj_data.put('codempid',r3.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r3.codempid,global_v_lang));
                obj_data.put('codcompn',v_codcompn);
                obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
                obj_data.put('dteposdue',to_char(r3.dteposdue,'dd/mm/yyyy'));
                obj_data.put('codposn',v_codposn);
                obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
                obj_data.put('flgAdd',true);
                obj_data.put('flgFirstLoad',true);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
          end loop;
        elsif p_condition = '2' then
          for r4 in c4 loop
            v_flgsecu := secur_main.secur2(r4.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_flgsecu then
                v_rcnt        := v_rcnt+1;
                select codcomp, codpos
                  into v_codcompn, v_codposn
                  from temploy1
                 where codempid = r4.codempid;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('image', nvl(get_emp_img(r4.codempid),r4.codempid));
                obj_data.put('codempid',r4.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r4.codempid,global_v_lang));
                obj_data.put('codcompn',v_codcompn);
                obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
                obj_data.put('codposn',v_codposn);
                obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
                obj_data.put('numseq',r4.numseq);
                obj_data.put('stasuccr',r4.stasuccr);
                obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', r4.stasuccr, global_v_lang));
                obj_data.put('dteappr',to_char(r4.dteappr,'dd/mm/yyyy'));
                obj_data.put('codappr',r4.codappr);
                obj_data.put('desc_codappr',get_temploy_name(r4.codappr,global_v_lang));
                obj_data.put('dteyear',r4.dteyear);
                obj_data.put('numtime',r4.numtime);
                obj_data.put('flgAdd',true);
                obj_data.put('flgFirstLoad',true);
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
          end loop;
        end if;
    end if;
    json_str_output := obj_row.to_clob;
  end;

  --
  procedure get_date(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_flgdata       varchar2(1 char) := 'N';
    v_dtereq        tpromote.dtereq%type;
    v_codemprq      tpromote.codemprq%type;
    cursor c1 is
        select *
          from tpromote
         where get_compful(codcomp) like p_codcomp||'%'
           and codpos = p_codpos
           and dtereq = p_dtereq;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if param_msg_error is null then
        for r1 in c1 loop
            v_flgdata       := 'Y';
            v_dtereq        := r1.dtereq;
            v_codemprq      := r1.codemprq;
            obj_row.put('flg','edit');
            obj_row.put('staappr',r1.staappr);
            if r1.staappr = 'P' then
                obj_row.put('flgDisabled',false);
            else
                obj_row.put('flgDisabled',true);
                obj_row.put('msgerror',replace(get_error_msg_php('TR0013',global_v_lang),'@#$%400'));
            end if;
        end loop;
        if v_flgdata = 'N' then
--            v_dtereq        := p_dtereq;
            v_dtereq        := trunc(sysdate);
            v_codemprq      := global_v_codempid;
            obj_row.put('flg','add');
            obj_row.put('staappr','P');
            obj_row.put('flgDisabled',false);
        end if;

        obj_row.put('dtereq',to_char(v_dtereq,'dd/mm/yyyy'));
        obj_row.put('codemprq',v_codemprq);
        obj_row.put('coderror', '200');
        json_str_output := obj_row.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    cursor c1 is
        select *
          from tcenter
         where codcomp = get_compful(p_codcomp);
    cursor c2 is
        select *
          from tpostn
         where codpos = p_codpos;
  begin
    /*if p_codcomp is null or p_codpos is null or p_dtereq is null
       or p_condition is null
       or (p_condition = '1' and p_dteposdue is null)
       or (p_condition = '2' and p_stasuccr is null) then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang,'TCENTER');
        return;
    end if;*/
    if  p_codcomp is not null then
        for i in c1 loop
            v_data  := 'Y';
            v_flgSecur := secur_main.secur7(p_codcomp,global_v_coduser);
            if v_flgSecur then
                v_chkSecur  := 'Y';
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        elsif v_chkSecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
    v_data  := 'N';
    if p_codpos is not null then
        for i in c2 loop
            v_data  := 'Y';
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
            return;
        end if;
    end if;
  end;

  procedure check_save is
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    v_codempid  temploy1.codempid%type;
    v_flgsecu   boolean;
    v_zupdsal   varchar2(400 char);
    v_staemp    temploy1.staemp%type;
  begin
  null;
    if p_flg = 'add' then
        if p_dtereq < trunc(sysdate) then
            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
            return;
        end if;
    end if;

    if p_codemprq is not null then
        begin
            select codempid
              into v_codempid
              from temploy1
             where codempid = p_codemprq;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

        v_flgsecu := secur_main.secur2(p_codemprq,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codemprq;

        if v_staemp = '9' then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        elsif v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            return;
        end if;
    end if;
  end;
  procedure get_data_codempid(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data_codempid(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_codempid(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_code1         varchar2(3000);
    v_code2         varchar2(3000);
    v_code3         varchar2(3000);
    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;

    v_cursor        number;
    v_codcomp       varchar2(100);
    v_idx           number := 0;
    v_codcompn      temploy1.codcomp%type;
    v_codposn       temploy1.codpos%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_staemp        temploy1.staemp%type;

    cursor c1 is
        select *
          from tposempd
         where get_compful(codcomp) like p_codcomp||'%'
           and codpos = p_codpos
           and codempid = p_codempid_query
      order by codempid;

    cursor c2 is
        select *
          from tsuccpln
         where get_compful(codcomp)like p_codcomp||'%'
           and codpos = p_codpos
           and codempid = p_codempid_query
      order by codempid;
  begin
    --table
    v_rcnt  := 0;
    obj_data := json_object_t();

    begin
        select staemp,codcomp,codpos
          into v_staemp,v_codcompn,v_codposn
          from temploy1
         where codempid = p_codempid_query;
    exception when no_data_found then
        param_msg_error     := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end;

    if v_codcompn = p_codcomp and v_codposn = p_codpos then
        param_msg_error     := get_error_msg_php('RP0038',global_v_lang);
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_staemp = '9' then
        param_msg_error     := get_error_msg_php('HR2101',global_v_lang);
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_staemp = '0' then
        param_msg_error     := get_error_msg_php('HR2102',global_v_lang);
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if p_condition = '1' then
      for r1 in c1 loop
        v_flgdata := 'Y';
        v_flgsecu := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
            v_rcnt        := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
            obj_data.put('codempid',r1.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('codcompn',v_codcompn);
            obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
            obj_data.put('dteposdue',to_char(r1.dteposdue,'dd/mm/yyyy'));
            obj_data.put('codposn',v_codposn);
            obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
            obj_data.put('flgAdd',true);
            obj_data.put('staappr','P');
        end if;
      end loop;

      if v_flgdata = 'N' then
        param_msg_error     := get_error_msg_php('HR2055',global_v_lang,'TPOSEMPD');
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
      elsif not v_flgsecu then
        param_msg_error     := get_error_msg_php('HR3007',global_v_lang);
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    elsif p_condition = '2' then
      for r2 in c2 loop
        v_flgdata := 'Y';
        v_flgsecu := secur_main.secur2(r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgsecu then
            v_rcnt        := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', nvl(get_emp_img(r2.codempid),r2.codempid));
            obj_data.put('codempid',r2.codempid);
            obj_data.put('desc_codempid',get_temploy_name(r2.codempid,global_v_lang));
            obj_data.put('codcompn',v_codcompn);
            obj_data.put('desc_codcompn',get_tcenter_name(v_codcompn,global_v_lang));
            obj_data.put('codposn',v_codposn);
            obj_data.put('desc_codposn',get_tpostn_name(v_codposn,global_v_lang));
            obj_data.put('numseq',r2.numseq);
            obj_data.put('stasuccr',r2.stasuccr);
            obj_data.put('desc_stasuccr',GET_TLISTVAL_NAME('STASUCCR', r2.stasuccr, global_v_lang));
            obj_data.put('dteappr',to_char(r2.dteappr,'dd/mm/yyyy'));
            obj_data.put('codappr',r2.codappr);
            obj_data.put('desc_codappr',get_temploy_name(r2.codappr,global_v_lang));
            obj_data.put('dteyear',r2.dteyear);
            obj_data.put('numtime',r2.numtime);
            obj_data.put('flgAdd',true);
            obj_data.put('staappr','P');
        end if;
      end loop;
      if v_flgdata = 'N' then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSUCCPLN');
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    end if;
    json_str_output := obj_data.to_clob;
  end;
  procedure save_index(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_stapromote    tpromote.stapromote%type;
    v_codempid      tpromoted.codempid%type;
    v_codempido     tpromoted.codempid%type;
    v_flg           varchar2(50);
    v_msg_to        clob;
    v_templete_to   clob;
    v_func_appr     tfwmailh.codappap%type;
    v_rowid         rowid;
    v_error			    terrorm.errorno%type;
    v_codform		    tfwmailh.codform %type;
    v_staemp        temploy1.staemp%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(400);
    v_staappr       tpromote.staappr%type;
  begin
    initial_value(json_str_input);
    check_save;
    if p_condition = '1' then
        v_stapromote := '4';
    elsif p_condition = '2' then
        v_stapromote := p_stasuccr;
    end if;
    if param_msg_error is null then
        begin
            for i in 0..p_datarows.get_size-1 loop
                obj_row     := json_object_t();
                obj_row     := hcm_util.get_json_t(p_datarows,to_char(i));
                v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
                v_flg       := hcm_util.get_string_t(obj_row,'flg');

                if v_flg in ('add','edit') then
                    begin
                        select staemp
                          into v_staemp
                          from temploy1
                         where codempid = v_codempid;
                    exception when no_data_found then
                        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                    end;

                    v_flgsecu := secur_main.secur2(v_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                    if not v_flgsecu then
                        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                    end if;

                    if v_staemp = '9' then
                        param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                    elsif v_staemp = '0' then
                        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
                    end if;

                    if param_msg_error is not null then
                        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                        return;
                    end if;
                end if;
            end loop;

            begin
                insert into tpromote (codcomp,codpos,dtereq,codemprq,stapromote,staappr,dtecreate,codcreate,dteupd,coduser)
                values (p_codcomp, p_codpos, p_dtereq, p_codemprq, v_stapromote, 'P', sysdate, global_v_coduser, sysdate, global_v_coduser);
            exception when dup_val_on_index then
                update tpromote
                   set codemprq = p_codemprq,
                       stapromote = v_stapromote,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codcomp = p_codcomp
                       and codpos = p_codpos
                       and dtereq = p_dtereq;
            end;

            begin
              select staappr
                into v_staappr
                from tpromote
               where codcomp = p_codcomp
                 and codpos = p_codpos
                 and dtereq = p_dtereq
                 and rownum = 1; -- #7130 || User39 || 06/11/2021
            exception when no_data_found then
                v_staappr := 'P';
            end;

            if v_staappr != 'P' then
                rollback;
                param_msg_error := get_error_msg_php('TR0013',global_v_lang);
                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                return;
            end if;

            for i in 0..p_datarows.get_size-1 loop
                obj_row     := json_object_t();
                obj_row     := hcm_util.get_json_t(p_datarows,to_char(i));
                v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
                v_codempido := hcm_util.get_string_t(obj_row,'codempidOld');
                v_flg       := hcm_util.get_string_t(obj_row,'flg');

                if v_flg = 'add' then
                    insert into tpromoted (codcomp,codpos,dtereq,codempid,staappr,dtecreate,codcreate,dteupd,coduser)
                    values (p_codcomp, p_codpos, p_dtereq, v_codempid, 'P', sysdate, global_v_coduser, sysdate, global_v_coduser);
                elsif v_flg = 'edit' then
                    update tpromoted
                       set codempid = v_codempid
                     where codcomp = p_codcomp
                       and codpos = p_codpos
                       and dtereq = p_dtereq
                       and codempid = v_codempido;
                elsif v_flg = 'delete' then
                    delete tpromoted
                     where codcomp = p_codcomp
                       and codpos = p_codpos
                       and dtereq = p_dtereq
                       and codempid = v_codempido;
                end if;

                if v_flg in ('add','edit') then

                    begin 
                      select rowid
                      into v_rowid
                      from tpromoted
                     where codcomp = p_codcomp
                       and codpos = p_codpos
                       and dtereq = p_dtereq
                       and codempid = v_codempid
                       and rownum = 1; -- #7130 || User39 || 06/11/2021;
                    exception when no_data_found then -- #7130 || User39 || 06/11/2021;
                       v_rowid := null; -- #7130 || User39 || 06/11/2021;
                    end;

                    begin
                        v_error := chk_flowmail.send_mail_for_approve('HRRP33E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRRP33E1', 230, 'E', 'P', 1, null, null,'TPROMOTED',v_rowid, '1', null);
                       EXCEPTION WHEN OTHERS THEN
                        v_error := '2403';
                    END;

                    IF v_error in ('2046','2402') THEN
                        param_msg_error := get_error_msg_php('HR2402', global_v_lang);
                    ELSE
                        param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
                    END IF;

--                    if param_msg_error_mail is not null then
--                        json_str_output := get_response_message(200,param_msg_error_mail,global_v_lang);
--                    else
--                        json_str_output := get_response_message(200,param_msg_error,global_v_lang);
--                    end if;
--
--                    begin
--                      chk_flowmail.get_message('HRRP33E', global_v_lang, v_msg_to, v_templete_to, v_func_appr);
--                      chk_flowmail.replace_text_frmmail(v_templete_to, 'TPROMOTED', v_rowid, get_label_name('HRRP33E1', global_v_lang, 230), v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to);
--                      v_error := chk_flowmail.send_mail_to_approve('HRRP33E', v_codempid, null, v_msg_to, null, get_label_name('HRRP33E1', global_v_lang, 230), 'E', 'P', global_v_lang,1,null,null);
--                    exception when others then
--                      param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
--                    end;
                end if;
            end loop;
            commit;
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
        if param_msg_error_mail is null then
          param_msg_error := get_error_msg_php('HR2402',global_v_lang);
          json_str_output := get_response_message(200,param_msg_error,global_v_lang);
        else
          json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_successor_history(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_successor_history(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_successor_history(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
        select *
          from tsuccpln
         where codempid = p_codempid_query
           and stasuccr <> '4'
      order by dteyear, numtime;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteyear', r1.dteyear);
      obj_data.put('numtime', r1.numtime);
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos',r1.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('numseq',r1.numseq);
      obj_data.put('stasuccr',r1.stasuccr);
      obj_data.put('desc_stasuccr',get_tlistval_name('STASUCCR', r1.stasuccr,global_v_lang));
      obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
      obj_data.put('codappr',r1.codappr || ' - ' || get_temploy_name(r1.codappr,global_v_lang));
      obj_data.put('remarkap',r1.remarkap);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;

  procedure get_competency(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_competency(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_competency(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codtency      tjobposskil.codtency%type;
    v_grade         tcmptncy.grade%type := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_idx           number := 0;
    cursor c1 is
        select *
          from tjobposskil
         where get_compful(codcomp) = get_compful(v_codcomp)
           and codpos = v_codpos
      order by codtency, grade;

    cursor c2 is
        select grade
          from tcmptncy
         where codempid = p_codempid_query
           and codtency = v_codtency
      order by codtency, grade;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();
    begin
      select codcomp,codpos into v_codcomp, v_codpos
      from temploy1
      where codempid = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    begin
        delete ttemprpt
         where codapp = 'HRRP33E'
           and codempid = global_v_codempid;
    end;
    for r1 in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      v_codtency    := r1.codskill;
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid_query,global_v_lang));
      obj_data.put('codcomp',p_codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(p_codcomp,global_v_lang));
      obj_data.put('codpos',p_codpos);
      obj_data.put('desc_codpos',get_tpostn_name(p_codpos,global_v_lang));
      obj_data.put('codtency', r1.codtency);
      obj_data.put('desc_codtency', get_tcomptnc_name(r1.codtency,global_v_lang));
      obj_data.put('codskill', r1.codskill);
      obj_data.put('desc_codskill',get_tcodec_name ('TCODSKIL', r1.codskill,global_v_lang));
      obj_data.put('expect_grade', nvl(r1.grade,0));
      for r2 in c2 loop
        v_grade := r2.grade;
      end loop;
      obj_data.put('grade', nvl(v_grade,0));
      obj_data.put('gap', -greatest(0,nvl(r1.grade,0) - nvl(v_grade,0)));
      obj_row.put(to_char(v_rcnt-1),obj_data);

      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRP33E',v_idx,
              r1.codskill, get_tcodec_name ('TCODSKIL', r1.codskill,global_v_lang),
              get_label_name('HRRP33E3',global_v_lang,40),get_label_name('HRRP33E3',global_v_lang,130),
              nvl(r1.grade,0),get_label_name('HRRP33E3',global_v_lang,5));

      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRP33E',v_idx,
              r1.codskill, get_tcodec_name ('TCODSKIL', r1.codskill,global_v_lang),
              get_label_name('HRRP33E3',global_v_lang,50),get_label_name('HRRP33E3',global_v_lang,130),
              v_grade,get_label_name('HRRP33E3',global_v_lang,5));

    end loop;
    json_str_output := obj_row.to_clob;
  end;

  procedure get_performance_history(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_performance_history(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_performance_history(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codtency      tjobposskil.codtency%type;
    v_grade         tcmptncy.grade%type := 0;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_dteyreap      tapprais.dteyreap%type;
    v_codempid      tapprais.codempid%type;
    v_idx           number := 0;
    v_percent       number := 0;
    v_codep         number := 0;
    cursor c1 is
        select codempid,dteyreap, codcomp, codpos, qtyscore, grade, amtsal, amtsaln
          from tapprais
         where codempid = p_codempid_query
           and dteyreap <= to_char(sysdate,'yyyy')
      order by dteyreap desc;

    cursor c2 is
        select qtykpie3, qtybeh3, qtycmp3, qtytot3,qtypuns + qtyta as qtypunsta
          from tappemp
         where codempid = v_codempid
           and dteyreap = v_dteyreap
           and numtime = (select max(numtime)
                            from tappemp
                           where codempid = v_codempid
                             and dteyreap = v_dteyreap);
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();
      begin
        delete
          from ttemprpt
         where codapp = 'HRRP33E2'
           and codempid = global_v_codempid;
      end;
    for r1 in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      v_codempid    := r1.codempid;
      v_dteyreap    := r1.dteyreap;
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid_query,global_v_lang));
      obj_data.put('dteyreap',r1.dteyreap);
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos',r1.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('qtyscore', to_char(nvl(r1.qtyscore,0),'fm999999999990.00'));
      obj_data.put('grade', r1.grade);
      for r2 in c2 loop
        obj_data.put('qtypunsta', to_char(nvl(r2.qtypunsta,0),'fm999999999990.00'));
        obj_data.put('qtykpie3', to_char(nvl(r2.qtykpie3,0),'fm999999999990.00'));
        obj_data.put('qtybeh3', to_char(nvl(r2.qtybeh3,0),'fm999999999990.00'));
        obj_data.put('qtycmp3', to_char(nvl(r2.qtycmp3,0),'fm999999999990.00'));
        obj_data.put('qtytot3', to_char(nvl(r2.qtytot3,0) + nvl(r2.qtypunsta,0),'fm999999999990.00'));
          v_codep := 0;
          v_idx := v_idx + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item7, item8,item9, item10,item31)
          values (global_v_codempid, 'HRRP33E2',v_idx,
                  get_label_name('HRRP33E4',global_v_lang,170), hcm_util.get_year_buddhist_era(r1.dteyreap), hcm_util.get_year_buddhist_era(r1.dteyreap),
                  v_codep,get_label_name('HRRP33E4',global_v_lang,200),get_label_name('HRRP33E4',global_v_lang,60),
                  nvl(r2.qtypunsta,0),get_label_name('HRRP33E4',global_v_lang,5));

          v_idx := v_idx + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item7, item8,item9, item10,item31)
          values (global_v_codempid, 'HRRP33E2',v_idx,
                  get_label_name('HRRP33E4',global_v_lang,170), hcm_util.get_year_buddhist_era(r1.dteyreap), hcm_util.get_year_buddhist_era(r1.dteyreap),
                  v_codep,get_label_name('HRRP33E4',global_v_lang,80),get_label_name('HRRP33E4',global_v_lang,60),
                  nvl(r2.qtybeh3,0),get_label_name('HRRP33E4',global_v_lang,5));

          v_idx := v_idx + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item7, item8,item9, item10,item31)
          values (global_v_codempid, 'HRRP33E2',v_idx,
                  get_label_name('HRRP33E4',global_v_lang,170), hcm_util.get_year_buddhist_era(r1.dteyreap), hcm_util.get_year_buddhist_era(r1.dteyreap),
                  v_codep,get_label_name('HRRP33E4',global_v_lang,90),get_label_name('HRRP33E4',global_v_lang,60),
                  nvl(r2.qtycmp3,0),get_label_name('HRRP33E4',global_v_lang,5));

          v_idx := v_idx + 1;
          v_codep := v_codep + 1;
          insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item7, item8,item9, item10,item31)
          values (global_v_codempid, 'HRRP33E2',v_idx,
                  get_label_name('HRRP33E4',global_v_lang,170), hcm_util.get_year_buddhist_era(r1.dteyreap), hcm_util.get_year_buddhist_era(r1.dteyreap),
                  v_codep,get_label_name('HRRP33E4',global_v_lang,70),get_label_name('HRRP33E4',global_v_lang,60),
                  nvl(r2.qtykpie3,0),get_label_name('HRRP33E4',global_v_lang,5));

      end loop;
      obj_data.put('amtsal', to_char(nvl(stddec(r1.amtsal,v_codempid,v_chken),0),'fm999999999990.00'));
      obj_data.put('amtsaln', to_char(nvl(stddec(r1.amtsaln,v_codempid,v_chken),0),'fm999999999990.00'));

      obj_row.put(to_char(v_rcnt-1),obj_data);

      if nvl(stddec(r1.amtsal,v_codempid,v_chken),0) > 0 then
        v_percent := nvl(stddec(r1.amtsaln,v_codempid,v_chken),0) - nvl(stddec(r1.amtsal,v_codempid,v_chken),0);
        v_percent := round((v_percent * 100) / nvl(stddec(r1.amtsal,v_codempid,v_chken),0),2);
      else
        v_percent := 100;
      end if;
      v_idx := v_idx + 1;
      insert into ttemprpt (codempid,codapp,numseq,item1, item4,item5, item8,item9, item10,item31)
      values (global_v_codempid, 'HRRP33E2',v_idx,
              get_label_name('HRRP33E4',global_v_lang,180), hcm_util.get_year_buddhist_era(r1.dteyreap), hcm_util.get_year_buddhist_era(r1.dteyreap),
              get_label_name('HRRP33E4',global_v_lang,190),get_label_name('HRRP33E4',global_v_lang,190),
              v_percent,
              get_label_name('HRRP33E4',global_v_lang,5));

      if v_rcnt = 5 then
        exit;
      end if;
    end loop;
    json_str_output := obj_row.to_clob;
  end;


  procedure get_career_plan(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_career_plan(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_plan(json_str_output out clob) is
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    cursor c1 is
        select *
          from tposemph
         where codempid = p_codempid_query;
  begin
    v_rcnt          := 0;
    obj_data        := json_object_t();

    begin
        select codcomp, codpos
          into v_codcomp, v_codpos
          from temploy1
         where codempid = p_codempid_query;
    exception when others then
        v_codcomp := '';
        v_codpos := '';
    end;
    obj_data.put('coderror', '200');
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('codpos', v_codpos);
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));

    for r1 in c1 loop
      obj_data.put('codreview', r1.codreview);
      obj_data.put('desc_codreview', get_temploy_name(r1.codreview,global_v_lang));
      obj_data.put('dtereview', to_char(r1.dtereview,'dd/mm/yyyy'));
      obj_data.put('descstr', r1.descstr);
      obj_data.put('descweek', r1.descweek);
      obj_data.put('descoop', r1.descoop);
      obj_data.put('descthreat', r1.descthreat);
      obj_data.put('shorttrm', r1.shorttrm);
      obj_data.put('midterm', r1.midterm);
      obj_data.put('longtrm', r1.longtrm);
    end loop;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_career_path(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_career_path(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_career_path(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_codtency      tjobposskil.codtency%type;
    v_grade         tcmptncy.grade%type := 0;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_dteyreap      tapprais.dteyreap%type;
    v_codempid      tapprais.codempid%type;
    cursor c1 is
        select *
          from tposempd
         where codempid = p_codempid_query
      order by numseq;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid_query);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid_query,global_v_lang));
      obj_data.put('numseq',r1.numseq);
      obj_data.put('codlinef',r1.codlinef);
      obj_data.put('desc_codlinef',get_tfunclin_name(hcm_util.get_codcomp_level(r1.codcomp,1),r1.codlinef,global_v_lang));
      obj_data.put('codcomp',r1.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos',r1.codpos);
      obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('dteposdue', to_char(r1.dteposdue,'dd/mm/yyyy'));
      obj_data.put('dteefpos', to_char(r1.dteefpos,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  end;
end;

/

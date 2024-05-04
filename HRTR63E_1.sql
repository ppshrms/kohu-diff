--------------------------------------------------------
--  DDL for Package Body HRTR63E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR63E" is
-- last update: 10/02/2021 18:35
 procedure initial_value(json_str in clob) is
    json_obj   json := json(json_str);
  begin
    global_v_coduser  := json_ext.get_string(json_obj,'p_coduser');
    global_v_codempid := json_ext.get_string(json_obj,'p_codempid');
    global_v_lang     := json_ext.get_string(json_obj,'p_lang');

    p_codapp          := (hcm_util.get_string(json_obj, 'p_codapp'));
    p_codproc         := upper(hcm_util.get_string(json_obj, 'p_codproc'));

    p_dteyear         := (hcm_util.get_string(json_obj, 'p_dteyear'));
    p_codcompy        := (hcm_util.get_string(json_obj, 'p_codcompy'));
    p_codcours        := (hcm_util.get_string(json_obj, 'p_codcours'));
    p_numclseq        := to_number((hcm_util.get_string(json_obj, 'p_numclseq')));
    p_codform         := (hcm_util.get_string(json_obj, 'p_codform'));
    p_codempid        := (hcm_util.get_string(json_obj, 'p_codempid_query'));
    p_codinst         := (hcm_util.get_string(json_obj, 'p_codinst'));
    p_codsubj         := (hcm_util.get_string(json_obj, 'p_codsubj'));

    json_params       := hcm_util.get_json(json_obj, 'params');
    param_msg_error   := '';
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
----------------------------------------------------------------------------------
procedure check_index as
    v_count_codcompy           number :=0 ;
    v_count_codcours           number :=0 ;
  begin
    if p_dteyear is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcompy is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    else
        select count(*)
        into v_count_codcompy
        from tcompny t
        where t.codcompy = p_codcompy;

        if v_count_codcompy = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
           return;
        end if ;

        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
           param_msg_error := get_error_msg_php('HR3007',global_v_lang);
           return;
        end if;
    end if;

    if p_codcours is not null then
       select count(*)
        into v_count_codcours
        from tcourse t
        where t.codcours = p_codcours;

        if v_count_codcours = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
           return;
        end if ;
    end if;

  end check_index;
----------------------------------------------------------------------------------------
procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_index;
----------------------------------------------------------------------------------
procedure gen_index(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c1 is
            select distinct *
            from(select a.dteyear, a.codcours, get_tcourse_name(a.codcours,global_v_lang) as desc_codcours,
                   a.codcompy, a.numclseq, a.dtetrst, a.dtetren, a.dteupd
                   from tyrtrsch a
                   where nvl(a.flgconf,'Y') = 'Y'
                         and a.codtparg = '1'
                         and a.dteyear = p_dteyear
                         and a.codcompy = p_codcompy
                         and a.codcours = nvl(p_codcours,a.codcours)
                         and a.numclseq = nvl(p_numclseq,a.numclseq)
                         and not exists(
                             select b.numclseq
                             from thisclss b
                             where b.dteyear = a.dteyear
                                   and b.codcompy = a.codcompy
                                   and b.codcours = a.codcours
                                   and b.numclseq = a.numclseq
                         )
                   union
                   select a.dteyear, a.codcours, get_tcourse_name(a.codcours,global_v_lang) as desc_codcours, a.codcompy, a.numclseq, a.dtetrst, a.dtetren, a.dteupd
                   from thisclss a
                   where dteyear = p_dteyear
                         and codcompy = p_codcompy
                         and a.codcours = nvl(p_codcours,a.codcours)
                         and a.numclseq = nvl(p_numclseq,a.numclseq)
                         and codtparg = '1'
                   order by codcours,numclseq desc
                   );
  begin
    obj_row     := json();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('codcours', r1.codcours);
      obj_data.put('desc_codcours', r1.desc_codcours);
      obj_data.put('numclseq', r1.numclseq);
      obj_data.put('dtetrst', to_char(r1.dtetrst, 'dd/mm/yyyy'));
      obj_data.put('dtetren', to_char(r1.dtetren, 'dd/mm/yyyy'));
      obj_data.put('dteinput', to_char(r1.dteupd, 'dd/mm/yyyy'));
      obj_data.put('dteyear', r1.dteyear);
      obj_data.put('codcompy', r1.codcompy);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_index;
----------------------------------------------------------------------------------
procedure get_thisclss_detail (json_str_input in clob, json_str_output out clob) is
          v_count_check       number := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       v_count_check   := check_count_thisclss(p_dteyear,p_codcompy,p_codcours,p_numclseq);
       if v_count_check = 0 then
          gen_tyrtrsch(json_str_output);
       else
          gen_thisclss_detail(json_str_output);
       end if;
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_thisclss_detail;
----------------------------------------------------------------------------------
procedure gen_thisclss_detail (json_str_output out clob) is
    obj_data                json;
    v_dteyear               thisclss.dteyear%type        := '';
    v_codcompy              thisclss.codcompy%type       := '';
    v_codcours              thisclss.codcours%type       := '';
    v_numclseq              thisclss.numclseq%type       := '';
    v_objective             thisclss.objective%type      := '';
    v_codresp               thisclss.codresp%type        := '';
    v_codhotel              thisclss.codhotel%type       := '';
    v_codinsts              thisclss.codinsts%type       := '';
    v_dtetrst               thisclss.dtetrst%type        := '';
    v_dtetren               thisclss.dtetren%type        := '';
    v_qtyppc                thisclss.qtyppc%type         := '';
    v_qtytrmin              thisclss.qtytrmin%type       := '';
    v_amttotexp             thisclss.amttotexp%type      := '';
    v_amtcost               thisclss.amtcost%type        := '';
    v_numcert               thisclss.numcert%type        := '';
    v_dtecert               thisclss.dtecert%type        := '';
    v_typtrain              thisclss.typtrain%type       := '';
    v_descomptr             thisclss.descomptr%type      := '';
    v_dteprest              thisclss.dteprest%type       := '';
    v_dtepreen              thisclss.dtepreen%type       := '';
    v_codexampr             thisclss.codexampr%type      := '';
    v_dtepostst             thisclss.dtepostst%type      := '';
    v_dteposten             thisclss.dteposten%type      := '';
    v_codexampo             thisclss.codexampo%type      := '';
    v_qtytrflw              thisclss.qtytrflw%type       := '';
    v_flgcommt              thisclss.flgcommt%type       := '';
    v_dtecomexp             thisclss.dtecomexp%type      := '';
    v_descommt              thisclss.descommt%type       := '';
    v_descommtn             thisclss.descommtn%type      := '';
    v_codtparg              thisclss.codtparg%type       := '';
    v_flgcerti              thisclss.flgcerti%type       := '';
    v_codform               thisclss.codform%type       := '';

  begin
    begin
      select t.dteyear,   t.codcompy,  t.codcours,  t.numclseq,
             t.objective, t.codresp,   t.codhotel,  t.codinsts,
             t.dtetrst,   t.dtetren,   t.qtyppc,    t.qtytrmin,
             t.amttotexp, t.amtcost,   t.numcert,   t.dtecert,
             t.typtrain,  t.descomptr, t.dteprest,  t.dtepreen,
             t.codexampr, t.dtepostst, t.dteposten, t.codexampo,
             t.qtytrflw,  t.flgcommt,  t.dtecomexp, t.descommt,
             t.descommtn, t.codtparg,  t.flgcerti, t.codform
      into   v_dteyear,   v_codcompy,  v_codcours,  v_numclseq,
             v_objective, v_codresp,   v_codhotel,  v_codinsts,
             v_dtetrst,   v_dtetren,   v_qtyppc,    v_qtytrmin,
             v_amttotexp, v_amtcost,   v_numcert,   v_dtecert,
             v_typtrain,  v_descomptr, v_dteprest,  v_dtepreen,
             v_codexampr, v_dtepostst, v_dteposten, v_codexampo,
             v_qtytrflw,  v_flgcommt,  v_dtecomexp, v_descommt,
             v_descommtn, v_codtparg,  v_flgcerti,  v_codform
      from   thisclss t
      where  t.dteyear  = p_dteyear
             and t.codcompy = p_codcompy
             and t.codcours = p_codcours
             and t.numclseq = p_numclseq
             and t.codtparg = '1';

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('dteyear', v_dteyear);
    obj_data.put('codcompy', v_codcompy);
    obj_data.put('codcours', v_codcours);
    obj_data.put('numclseq', v_numclseq);
    obj_data.put('codtparg', v_codtparg);
    obj_data.put('objective', v_objective);
    obj_data.put('codresp', v_codresp);
    obj_data.put('codhotel', v_codhotel);
    obj_data.put('codinsts', v_codinsts);
    obj_data.put('dtetrst', to_char(v_dtetrst, 'dd/mm/yyyy'));
    obj_data.put('dtetren', to_char(v_dtetren, 'dd/mm/yyyy'));
    obj_data.put('qtyppc', v_qtyppc);
    obj_data.put('qtytrmin', floor( nvl(v_qtytrmin, 0) / 60 )||'.'||mod(NVL(v_qtytrmin, 0),60));
    obj_data.put('amttotexp', v_amttotexp);
    obj_data.put('amtcost', v_amtcost);
    obj_data.put('numcert', v_numcert);
    obj_data.put('dtecert', to_char(v_dtecert, 'dd/mm/yyyy'));
    obj_data.put('typtrain', v_typtrain);
    obj_data.put('descomptr', v_descomptr);
    obj_data.put('dteprest', to_char(v_dteprest, 'dd/mm/yyyy'));
    obj_data.put('dtepreen', to_char(v_dtepreen, 'dd/mm/yyyy'));
    obj_data.put('codexampr', v_codexampr);
    obj_data.put('dtepostst', to_char(v_dtepostst, 'dd/mm/yyyy'));
    obj_data.put('dteposten', to_char(v_dteposten, 'dd/mm/yyyy'));
    obj_data.put('codexampo', v_codexampo);
    obj_data.put('qtytrflw', v_qtytrflw);
    obj_data.put('flgcommt', v_flgcommt);
    obj_data.put('dtecomexp', to_char(v_dtecomexp, 'dd/mm/yyyy'));
    obj_data.put('descommt', v_descommt);
    obj_data.put('descommtn', v_descommtn);
    obj_data.put('flgcerti', v_flgcerti);
    obj_data.put('codform', v_codform);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_thisclss_detail;
----------------------------------------------------------------------------------
procedure gen_tyrtrsch (json_str_output out clob) is
    obj_data                json;
    v_dteyear               tyrtrsch.dteyear%type;
    v_codcompy              tyrtrsch.codcompy%type;
    v_codcours              tyrtrsch.codcours%type;
    v_numclseq              tyrtrsch.numclseq%type;
    v_codtparg              tyrtrsch.codtparg%type;
    v_codresp               tyrtrsch.codresp%type;
    v_codhotel              tyrtrsch.codhotel%type;
    v_codinsts              tyrtrsch.codinsts%type;
    v_dtetrst               tyrtrsch.dtetrst%type;
    v_dtetren               tyrtrsch.dtetren%type;
    v_qtyemp                tyrtrsch.qtyemp%type;
    v_qtytrmin              tyrtrsch.qtytrmin%type;
    v_flgcerti              tyrtrsch.flgcerti%type;
    v_dteprest              tyrtrsch.dteprest%type;
    v_dtepreen              tyrtrsch.dtepreen%type;
    v_codexampr             tyrtrsch.codexampr%type;
    v_dtepostst             tyrtrsch.dtepostst%type;
    v_dteposten             tyrtrsch.dteposten%type;
    v_codexampo             tyrtrsch.codexampo%type;
    v_qtytrflw              tcourse.qtytrflw%type;
  begin
    begin
      select t.dteyear,       t.codcompy,  t.codcours,  t.numclseq,
             '1' as codtparg, t.codresp,   t.codhotel,  t.codinsts,
             t.dtetrst,       t.dtetren,   t.qtyemp,    t.qtytrmin,
             t.flgcerti,      t.dteprest,  t.dtepreen,  t.codexampr,
             t.dtepostst,     t.dteposten, t.codexampo,
             (select qtytrflw from tcourse where codcours = p_codcours and ROWNUM = 1) as qtytrflw
      into   v_dteyear,       v_codcompy,  v_codcours,  v_numclseq,
             v_codtparg,      v_codresp,   v_codhotel,  v_codinsts,
             v_dtetrst,       v_dtetren,   v_qtyemp,    v_qtytrmin,
             v_flgcerti,      v_dteprest,  v_dtepreen,  v_codexampr,
             v_dtepostst,     v_dteposten, v_codexampo, v_qtytrflw

      from tyrtrsch t
      where t.dteyear  = p_dteyear
             and t.codcompy = p_codcompy
             and t.codcours = p_codcours
             and t.numclseq = p_numclseq
             and t.codtparg = '1'
             and ROWNUM = 1;

    exception when no_data_found then
          json_str_output := get_response_message(null, '', global_v_lang);
          return;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('dteyear', v_dteyear);
    obj_data.put('codcompy', v_codcompy);
    obj_data.put('codcours', v_codcours);
    obj_data.put('numclseq', v_numclseq);
    obj_data.put('codtparg', v_codtparg);
    obj_data.put('codresp', v_codresp);
    obj_data.put('codhotel', v_codhotel);
    obj_data.put('codinsts', v_codinsts);
    obj_data.put('dtetrst', to_char(v_dtetrst, 'dd/mm/yyyy'));
    obj_data.put('dtetren', to_char(v_dtetren, 'dd/mm/yyyy'));
    obj_data.put('qtyppc', v_qtyemp);
    obj_data.put('qtytrmin', v_qtytrmin);
    obj_data.put('flgcerti', v_flgcerti);
    obj_data.put('dteprest', to_char(v_dteprest, 'dd/mm/yyyy'));
    obj_data.put('dtepreen', to_char(v_dtepreen, 'dd/mm/yyyy'));
    obj_data.put('codexampr', v_codexampr);
    obj_data.put('dtepostst', to_char(v_dtepostst, 'dd/mm/yyyy'));
    obj_data.put('dteposten', to_char(v_dteposten, 'dd/mm/yyyy'));
    obj_data.put('codexampo', v_codexampo);
    obj_data.put('qtytrflw', v_qtytrflw);
    --obj_data.to_clob(json_str_output);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tyrtrsch;
----------------------------------------------------------------------------------
procedure get_tcosttr_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcosttr_detail (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tcosttr_detail;
----------------------------------------------------------------------------------
procedure gen_tcosttr_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c_tcosttr is
            select  t.dteyear, t.codcompy, t.codcours, t.numclseq, t.codexpn, t.amtcost, t.amttrcost
            from    tcosttr t
            where   dteyear  = p_dteyear
                    and codcompy = p_codcompy
                    and codcours = p_codcours
                    and numclseq = p_numclseq;
  begin

    obj_row     := json();
    for r_tcosttr in c_tcosttr loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dteyear', r_tcosttr.dteyear);
      obj_data.put('codcompy', r_tcosttr.codcompy);
      obj_data.put('codcours', r_tcosttr.codcours);
      obj_data.put('numclseq', r_tcosttr.numclseq);
      obj_data.put('codexpn', r_tcosttr.codexpn);
      obj_data.put('amtcost', r_tcosttr.amtcost);
      obj_data.put('amttrcost', r_tcosttr.amttrcost);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_tcosttr_detail;
----------------------------------------------------------------------------------
function check_count_thisclss(p_dteyear in varchar2, p_codcompy in varchar2, p_codcours in varchar2, p_numclseq in varchar2) return number IS
    v_count    number := 0;

   begin
    begin
      select count(*)
             into v_count
      from   thisclss t
      where  t.dteyear  = p_dteyear
             and t.codcompy = p_codcompy
             and t.codcours = p_codcours
             and t.numclseq = p_numclseq;

      exception when no_data_found then
          null;
    end;
  return  v_count ;
END;
--------------------------------------------------------------------------
procedure get_thistrnn_detail (json_str_input in clob, json_str_output out clob) as
  v_count_check    number := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       v_count_check   := check_count_thisclss(p_dteyear,p_codcompy,p_codcours,p_numclseq);
       if v_count_check = 0 then
          gen_tpotentp(json_str_output);
       else
          gen_thistrnn_detail(json_str_output);
       end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thistrnn_detail;
----------------------------------------------------------------------------------
procedure gen_thistrnn_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c_thistrnn is
            select  t.codempid, t.dteyear, t.codcours, t.numclseq, t.codcomp,
                    t.qtyprescr, t.qtyposscr, t.flgtrevl, t.qtytrmin, t.remarks,
                    get_tcenter_name(t.codcomp, global_v_lang) as desc_codcomp,
                     CASE
                      WHEN
                        (
                            (substr( t.qtytrpln , 1, instr(t.qtytrpln,'.')-1 ) * 60 )+(RPAD(SUBSTR( to_char(t.qtytrpln), instr( to_char(t.qtytrpln) ,'.', -1) + 1), 2, '0'))
                        ) - (
                            (substr( t.qtytrmin , 1, instr(t.qtytrmin,'.')-1 ) * 60 ) + (RPAD(SUBSTR( to_char(t.qtytrmin), instr( to_char(t.qtytrmin) ,'.', -1) + 1), 2, '0'))
                        ) >= 0
                      --) > 0--4. TR Module#3900
                      THEN
                         to_char(floor(
                           ((
                                (substr( t.qtytrpln , 1, instr(t.qtytrpln,'.')-1 ) * 60 )+(RPAD(SUBSTR( to_char(t.qtytrpln), instr( to_char(t.qtytrpln) ,'.', -1) + 1), 2, '0'))
                            ) - (
                                (substr( t.qtytrmin , 1, instr(t.qtytrmin,'.')-1 ) * 60 ) + (RPAD(SUBSTR( to_char(t.qtytrmin), instr( to_char(t.qtytrmin) ,'.', -1) + 1), 2, '0'))
                            ))
                          /60)||'.'||mod(
                              ((
                                  (substr( t.qtytrpln , 1, instr(t.qtytrpln,'.')-1 ) * 60 )+(RPAD(SUBSTR( to_char(t.qtytrpln), instr( to_char(t.qtytrpln) ,'.', -1) + 1), 2, '0'))
                              ) - (
                                  (substr( t.qtytrmin , 1, instr(t.qtytrmin,'.')-1 ) * 60 ) + (RPAD(SUBSTR( to_char(t.qtytrmin), instr( to_char(t.qtytrmin) ,'.', -1) + 1), 2, '0'))
                              ))
                          ,60))
                      ELSE (select to_char(nvl(sum(a.qtytrabs),0))
                      from tpotentpd a
                      where a.dteyear = p_dteyear and
                            a.codcompy = p_codcompy and
                            a.numclseq = p_numclseq and
                            a.codcours = p_codcours and
                            a.codempid = t.codempid)
                    END as qtytrabs
            from    thistrnn t
            where   t.dteyear  = p_dteyear
                    and t.codcomp like p_codcompy || '%'
                    and t.codcours = p_codcours
                    and t.numclseq = p_numclseq
            order by t.codempid;
  begin

    obj_row     := json();

    for r_thistrnn in c_thistrnn loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codempid', r_thistrnn.codempid);
      obj_data.put('dteyear', r_thistrnn.dteyear);
      obj_data.put('codcomp', r_thistrnn.codcomp);
      obj_data.put('codcours', r_thistrnn.codcours);
      obj_data.put('numclseq', r_thistrnn.numclseq);
      obj_data.put('qtypretst', r_thistrnn.qtyprescr);
      obj_data.put('qtypostst', r_thistrnn.qtyposscr);
      obj_data.put('flgtrevl', nvl(r_thistrnn.flgtrevl,'N'));
      obj_data.put('qtytrmin', r_thistrnn.qtytrmin);
      obj_data.put('remark', r_thistrnn.remarks);
      obj_data.put('desc_codcomp', r_thistrnn.desc_codcomp);
      obj_data.put('qtytrabs', r_thistrnn.qtytrabs);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_thistrnn_detail;
----------------------------------------------------------------------------------
procedure gen_tpotentp(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c_thistrnn is
           select t.dteyear, t.codcompy, t.numclseq, t.codcours,
                  t.codempid ,t.codcomp, get_tcenter_name(t.codcomp, global_v_lang) as desc_codcomp
           from tpotentp t
           where t.dteyear = p_dteyear
                and t.codcompy = p_codcompy
                and t.codcours = p_codcours
                and t.numclseq = p_numclseq
                and t.staappr = 'Y'
                and t.codtparg = '1'
           order by t.codempid;
  begin

    obj_row     := json();

    for r_thistrnn in c_thistrnn loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codempid', r_thistrnn.codempid);
      obj_data.put('dteyear', r_thistrnn.dteyear);
      obj_data.put('codcomp', r_thistrnn.codcomp);
      obj_data.put('codcours', r_thistrnn.codcours);
      obj_data.put('numclseq', r_thistrnn.numclseq);
      obj_data.put('desc_codcomp', r_thistrnn.desc_codcomp);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_tpotentp;
----------------------------------------------------------------------------------
procedure get_tcoursapg_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcoursapg_index (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tcoursapg_index;
----------------------------------------------------------------------------------
  procedure gen_tcoursapg_index(json_str_output out clob) is
    obj_data                json;
    obj_row                 json;
    obj_row_sub             json;
    obj_sub_data            json;
    v_rcnt                  number := 0;
    v_rcnt_sub              number := 0;
    cursor c_tcoursapg is
            select   t.dteyear, t.codcours, t.numclseq, t.codcompy,
                     t.numgrup,
                     t.qtyfscor,
                     t.qtyscore,
                     (
                       select c.codform
                       from thisclss c
                       where c.dteyear = p_dteyear
                             and c.codcompy = p_codcompy
                             and c.codcours = p_codcours
                             and c.numclseq = p_numclseq
                             and c.codtparg = '1'
                      ) as codform
            from     tcoursapg t
            where    t.dteyear  = p_dteyear
                     and t.codcompy = p_codcompy
                     and t.codcours = p_codcours
                     and t.numclseq = p_numclseq
            order by t.numgrup;

     cursor c_tcoursapi(c_dteyear in varchar2,c_codcompy in varchar2,c_codcours in varchar2,c_numclseq in varchar2,c_numgrup in varchar2,c_codform in varchar2)  is
            select t.numgrup,t.numitem,t.qtyfscor,t.grade,t.qtyscore, c_codform as codform
            from tcoursapi t
            where t.dteyear = c_dteyear
                  and t.codcompy = c_codcompy
                  and t.codcours = c_codcours
                  and t.numclseq = c_numclseq
                  and t.numgrup = c_numgrup;
  begin
    obj_row     := json();
    for r_tcoursapg in c_tcoursapg loop
        v_rcnt_sub              := 0;
        obj_row_sub             := json();
        for r_tcoursapi in c_tcoursapi(r_tcoursapg.dteyear,r_tcoursapg.codcompy,r_tcoursapg.codcours,r_tcoursapg.numclseq,r_tcoursapg.numgrup,r_tcoursapg.codform) loop
            v_rcnt_sub                 := v_rcnt_sub+1;
            obj_sub_data               := json();
            obj_sub_data.put('numgrup', r_tcoursapi.numgrup);
            obj_sub_data.put('numseq', r_tcoursapi.numitem);
            obj_sub_data.put('weight', r_tcoursapi.qtyfscor);
            obj_sub_data.put('grade', r_tcoursapi.grade);
            obj_sub_data.put('qtyscor', r_tcoursapi.qtyscore);
            obj_sub_data.put('codform', r_tcoursapi.codform);
            obj_sub_data.put('detail', get_tintvewd_name(r_tcoursapi.codform,r_tcoursapi.numgrup,r_tcoursapi.numitem,global_v_lang));
            obj_sub_data.put('defini', get_definite_name(r_tcoursapi.codform,r_tcoursapi.numgrup,r_tcoursapi.numitem));
            obj_sub_data.put('rcnt', v_rcnt_sub);
            obj_row_sub.put(to_char(v_rcnt_sub-1),obj_sub_data);
        end loop;

      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dteyear', r_tcoursapg.dteyear);
      obj_data.put('codcompy', r_tcoursapg.codcompy);
      obj_data.put('codcours', r_tcoursapg.codcours);
      obj_data.put('numclseq', r_tcoursapg.numclseq);
      obj_data.put('part', r_tcoursapg.numgrup);
      obj_data.put('totscor', r_tcoursapg.qtyfscor);
      obj_data.put('avgscor', r_tcoursapg.qtyscore);
      obj_data.put('codform', r_tcoursapg.codform);
      obj_data.put('detail', get_tintvews_name(r_tcoursapg.codform, r_tcoursapg.numgrup, global_v_lang));
      obj_data.put('eval_grd', obj_row_sub);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_tcoursapg_index;
----------------------------------------------------------------------------------
function get_definite_name(p_codform in varchar2, p_numgrup in varchar2, p_numitem in varchar2) return varchar2 IS
   v_definite    varchar2(1000 char);
   begin
    begin
      select decode(global_v_lang, '101', t.definite,
                                   '102', t.definitt,
                                   '103', t.definit3,
                                   '104', t.definit4,
                                   '105', t.definit5,
                                   t.definite) as definit
      into   v_definite
      from   tintvewd t
      where  t.codform  = p_codform
             and t.numgrup = p_numgrup
             and t.numitem = p_numitem;
      exception when no_data_found then
          null;
    end;
  return  v_definite ;
END;
--------------------------------------------------------------------------
  procedure get_tyrtrsubj_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tyrtrsubj_index (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tyrtrsubj_index;
----------------------------------------------------------------------------------
procedure gen_tyrtrsubj_index(json_str_output out clob) is
    obj_data         json;
    obj_row          json;
    v_rcnt           number := 0;
    v_rcnt_2         number := 0;
    v_count_flg      number := 0;
    v_codform        varchar2(1000 char);
    v_qtyscore       number := 0;

    cursor c_tyrtrsubj is
            select   t.codsubj, t.dteyear, t.codcours, t.numclseq, t.codcompy,
                     t.codinst, (select c.stainst from tinstruc c where c.codinst = t.codinst) as stainst,
                     t2.qtyscore, t2.codform
            from     tyrtrsubj t, thisinst t2
            where    t.dteyear  = p_dteyear
                     and t.codcompy = p_codcompy
                     and t.codcours = p_codcours
                     and t.numclseq = p_numclseq
                     and t.codinst = t2.codinst (+)
                     and t.dteyear = t2.dteyear (+)
                     and t.codcompy = t2.codcompy (+)
                     and t.codcours = t2.codcours (+)
                     and t.numclseq = t2.numclseq (+)
            order by t.codsubj, t.codinst;

     cursor c_tcoursub is
            select t.codcours, t.codsubj, t.codinst, t.qtytrhr, t2.qtyscore,
                   (select c.stainst from tinstruc c where c.codinst = t.codinst) as stainst
            from tcoursub t , thisinst t2
            where t.codcours = p_codcours
            and t.codcours = t2.codcours (+)
            and t.codsubj =t2.codsubj (+)
            and t.codinst = t2.codinst (+)
            order by t.codsubj,t.codinst;

  begin

    obj_row     := json();
    for r_flg in c_tyrtrsubj loop
        v_count_flg := 1;
        exit;
    end loop;
    if v_count_flg = 1 then
       for r_tyrtrsubj in c_tyrtrsubj loop

         v_rcnt      := v_rcnt+1;
         obj_data    := json();
         obj_data.put('coderror', '200');
         obj_data.put('desc_coderror', ' ');
         obj_data.put('httpcode', '');
         obj_data.put('flg', '');
         obj_data.put('rcnt', v_rcnt);
         obj_data.put('dteyear', r_tyrtrsubj.dteyear);
         obj_data.put('codcompy', r_tyrtrsubj.codcompy);
         obj_data.put('codcours', r_tyrtrsubj.codcours);
         obj_data.put('numclseq', r_tyrtrsubj.numclseq);
         obj_data.put('codinst', r_tyrtrsubj.codinst);
         obj_data.put('desc_codinst', get_tinstruc_name(r_tyrtrsubj.codinst, global_v_lang));
         obj_data.put('status', r_tyrtrsubj.stainst);
         obj_data.put('desc_status', get_tlistval_name('STAINST', r_tyrtrsubj.stainst, global_v_lang));
         obj_data.put('codsubj', r_tyrtrsubj.codsubj);
         obj_data.put('desc_codsubj', get_tsubject_name(r_tyrtrsubj.codsubj, global_v_lang));
         begin
            select nvl(sum(qtyscore),0)
              into v_qtyscore
              from tinstapg
             where dteyear  = p_dteyear
               and codcompy = p_codcompy
               and codcours = p_codcours
               and numclseq = p_numclseq;
            exception when no_data_found then
                v_qtyscore := 0;
         end;
      -- obj_data.put('avgscor', r_tyrtrsubj.qtyscore);
         obj_data.put('avgscor', v_qtyscore);
         obj_data.put('codform', r_tyrtrsubj.codform);
         obj_row.put(to_char(v_rcnt-1),obj_data);
       end loop;
    end if;

    v_rcnt_2        := 0;
    if v_count_flg = 0 then
       for r_tcoursub in c_tcoursub loop
         begin
            select t.codform
            into   v_codform
            from   TINSTAPH t
            where  t.dteyear = p_dteyear
                and t.codcompy = p_codcompy
                and t.codcours = p_codcours
                and t.numclseq = p_numclseq
                and t.codinst = r_tcoursub.codinst
                and t.codsubj = r_tcoursub.codsubj;
            exception when no_data_found then
                v_codform := '';
          end;
         v_rcnt_2      := v_rcnt_2+1;
         obj_data    := json();
         obj_data.put('coderror', '200');
         obj_data.put('desc_coderror', ' ');
         obj_data.put('httpcode', '');
         obj_data.put('flg', '');
         obj_data.put('rcnt', v_rcnt_2);
         obj_data.put('codinst', r_tcoursub.codinst);
         obj_data.put('desc_codinst', get_tinstruc_name(r_tcoursub.codinst, global_v_lang));
         obj_data.put('status', r_tcoursub.stainst);
         obj_data.put('desc_status', get_tlistval_name('STAINST', r_tcoursub.stainst, global_v_lang));
         obj_data.put('codsubj', r_tcoursub.codsubj);
         obj_data.put('desc_codsubj', get_tsubject_name(r_tcoursub.codsubj, global_v_lang));
         obj_data.put('avgscor',r_tcoursub.qtyscore);
         obj_data.put('dteyear', p_dteyear);
         obj_data.put('codcompy', p_codcompy);
         obj_data.put('codcours', p_codcours);
         obj_data.put('numclseq', p_numclseq);
         obj_data.put('codform', v_codform);
         obj_row.put(to_char(v_rcnt_2-1),obj_data);
       end loop;
    end if;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

end gen_tyrtrsubj_index;
----------------------------------------------------------------------------------
  procedure get_tknowleg_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tknowleg_detail (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tknowleg_detail;
----------------------------------------------------------------------------------
  procedure gen_tknowleg_detail(json_str_output out clob) is
    obj_data                                    json;
    obj_row                                     json;
    v_rcnt                                      number := 0;
    cursor c_tknowleg is
            select   itemno, dteyear, codcours, numclseq, codcompy,
                     subject, details, attfile, url
            from     tknowleg
            where    dteyear  = p_dteyear  and codcompy = p_codcompy and
                     codcours = p_codcours and numclseq = p_numclseq
            order by itemno;
  begin

    obj_row     := json();
    for r_tknowleg in c_tknowleg loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dteyear', r_tknowleg.dteyear);
      obj_data.put('codcompy', r_tknowleg.codcompy);
      obj_data.put('codcours', r_tknowleg.codcours);
      obj_data.put('numclseq', r_tknowleg.numclseq);
      obj_data.put('itemno', r_tknowleg.itemno);
      obj_data.put('desc_codsubj', r_tknowleg.subject);
      obj_data.put('detail', r_tknowleg.details);
      obj_data.put('filename', r_tknowleg.attfile);
      obj_data.put('url', r_tknowleg.url);
      obj_data.put('path_filename', get_tsetup_value('PATHDOC')||get_tfolderd('HRTR63E')|| '/' || r_tknowleg.attfile);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_tknowleg_detail;
----------------------------------------------------------------------------------
  procedure get_thisclsss_index (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thisclsss_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_thisclsss_index;
----------------------------------------------------------------------------------
  procedure gen_thisclsss_index(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c_thisclsss is
            select   numseq, dteyear, codcours, numclseq, codcompy,
                     descomment
            from     thisclsss
            where    dteyear  = p_dteyear  and codcompy = p_codcompy and
                     codcours = p_codcours and numclseq = p_numclseq
            order by numseq;
  begin

    obj_row     := json();
    for r_thisclsss in c_thisclsss loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dteyear', r_thisclsss.dteyear);
      obj_data.put('codcompy', r_thisclsss.codcompy);
      obj_data.put('codcours', r_thisclsss.codcours);
      obj_data.put('numclseq', r_thisclsss.numclseq);
      obj_data.put('numseq', r_thisclsss.numseq);
      obj_data.put('desothers', r_thisclsss.descomment);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_thisclsss_index;
----------------------------------------------------------------------------------
  procedure get_tcoursugg_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcoursugg_detail (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcoursugg_detail;
----------------------------------------------------------------------------------
  procedure gen_tcoursugg_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    cursor c_tcoursugg is
            select   numseq, dteyear, codcours, numclseq, codcompy,
                     descomment
            from     tcoursugg
            where    dteyear  = p_dteyear  and codcompy = p_codcompy and
                     codcours = p_codcours and numclseq = p_numclseq
            order by numseq;
  begin

    obj_row     := json();
    for r_tcoursugg in c_tcoursugg loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('dteyear', r_tcoursugg.dteyear);
      obj_data.put('codcompy', r_tcoursugg.codcompy);
      obj_data.put('codcours', r_tcoursugg.codcours);
      obj_data.put('numclseq', r_tcoursugg.numclseq);
      obj_data.put('numseq', r_tcoursugg.numseq);
      obj_data.put('descomment', r_tcoursugg.descomment);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_tcoursugg_detail;
----------------------------------------------------------------------------------
procedure check_codform as
    v_count_codform           number :=0 ;
  begin
    if p_codform is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    else
        select count(*)
        into v_count_codform
        from tintview t
        where t.codform = p_codform;

        if v_count_codform = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tintview');
           return;
        end if ;
    end if;
end check_codform;
----------------------------------------------------------------------------------------
procedure get_eval_course(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_codform;
    if param_msg_error is null then
      gen_eval_course (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_eval_course;
----------------------------------------------------------------------------------
procedure gen_eval_course(json_str_output out clob) is
    obj_data                json;
    obj_row                 json;
    obj_row_sub             json;
    obj_sub_data            json;
    v_rcnt                  number := 0;
    v_rcnt_sub              number := 0;

    cursor c_tintvews is
            select t.codform, t.numgrup, t.qtyfscor
            from tintvews t
            where t.codform = p_codform
            order by t.numgrup;

     cursor c_tintvewd(c_numgrup in varchar2)  is
            select t.codform, t.numgrup, t.numitem ,t.qtyfscor, t.qtywgt
            from tintvewd t
            where t.codform = p_codform
                  and t.numgrup = c_numgrup
            order by t.numitem;
  begin

    obj_row     := json();
    for r_tintvews in c_tintvews loop
        v_rcnt_sub              := 0;
        obj_row_sub             := json();
        for r_tintvewd in c_tintvewd(r_tintvews.numgrup) loop
            v_rcnt_sub                 := v_rcnt_sub+1;
            obj_sub_data               := json();
            obj_sub_data.put('numgrup', r_tintvewd.numgrup);
            obj_sub_data.put('numseq', r_tintvewd.numitem);
            obj_sub_data.put('weight', r_tintvewd.qtywgt);
            obj_sub_data.put('qtyscor', 0);
            obj_sub_data.put('codform', r_tintvewd.codform);
            obj_sub_data.put('detail', get_tintvewd_name(p_codform,r_tintvewd.numgrup,r_tintvewd.numitem,global_v_lang));
            obj_sub_data.put('defini', get_definite_name(p_codform,r_tintvewd.numgrup,r_tintvewd.numitem));
            obj_sub_data.put('rcnt', v_rcnt_sub);
            obj_row_sub.put(to_char(v_rcnt_sub-1),obj_sub_data);
        end loop;

      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('part', r_tintvews.numgrup);
      obj_data.put('totscor', r_tintvews.qtyfscor);
      obj_data.put('avgscor', 0);
      obj_data.put('codform', r_tintvews.codform);
      obj_data.put('detail', get_tintvews_name(r_tintvews.codform, r_tintvews.numgrup, global_v_lang));
      obj_data.put('eval_grd', obj_row_sub);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_eval_course;
----------------------------------------------------------------------------------
procedure get_tinstapg(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tinstapg (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_tinstapg;
----------------------------------------------------------------------------------
procedure gen_tinstapg(json_str_output out clob) is
    obj_data                json;
    obj_row                 json;
    obj_row_sub             json;
    obj_sub_data            json;
    v_rcnt                  number := 0;
    v_rcnt_sub              number := 0;

    cursor c_tinstapg is
            select t.dteyear, t.codcompy, t.codcours, t.numclseq, t.codinst,
                   t.codsubj, t.numgrup, t.qtyfscor, t.qtyscore,
                   t2.codform
            from tinstapg t
            left join TINSTAPH t2
                 on t2.codinst = t.codinst
                    and t2.codsubj = t.codsubj
                    and t2.dteyear = t.dteyear
                    and t2.codcompy = t.codcompy
                    and t2.codcours = t.codcours
                    and t2.numclseq = t.numclseq
            where t.dteyear = p_dteyear
                  and t.codcompy = p_codcompy
                  and t.codcours = p_codcours
                  and t.numclseq = p_numclseq
                  and t.codinst = p_codinst
                  and t.codsubj = p_codsubj

            order by t.numgrup;

     cursor c_tinstapi(c_dteyear in varchar2,c_codcompy in varchar2,c_codcours in varchar2,c_numclseq in varchar2,c_numgrup in varchar2,c_codform in varchar2,c_codinst in varchar2,c_codsubj in varchar2)  is
            select t.numgrup,t.numitem,t.qtyfscor,t.grade,t.qtyscore, c_codform as codform
            from tinstapi t
            where t.dteyear = c_dteyear
                  and t.codcompy = c_codcompy
                  and t.codcours = c_codcours
                  and t.numclseq = c_numclseq
                  and t.numgrup = c_numgrup
                  and t.codinst = c_codinst
                  and t.codsubj = c_codsubj
            order by t.numitem;
  begin

    obj_row     := json();
    for r_tinstapg in c_tinstapg loop

        v_rcnt_sub              := 0;
        obj_row_sub             := json();
        for r_tcoursapi in c_tinstapi(r_tinstapg.dteyear,r_tinstapg.codcompy,r_tinstapg.codcours,r_tinstapg.numclseq,r_tinstapg.numgrup,r_tinstapg.codform,r_tinstapg.codinst,r_tinstapg.codsubj) loop
            v_rcnt_sub                 := v_rcnt_sub+1;
            obj_sub_data               := json();
            obj_sub_data.put('numgrup', r_tcoursapi.numgrup);
            obj_sub_data.put('numseq', r_tcoursapi.numitem);
            obj_sub_data.put('weight', r_tcoursapi.qtyfscor);
            obj_sub_data.put('grade', r_tcoursapi.grade);
            obj_sub_data.put('qtyscor', r_tcoursapi.qtyscore);
            obj_sub_data.put('codform', r_tcoursapi.codform);
            obj_sub_data.put('codform_desc', get_tintview_name(r_tcoursapi.codform,global_v_lang));
            obj_sub_data.put('detail', get_tintvewd_name(r_tcoursapi.codform,r_tcoursapi.numgrup,r_tcoursapi.numitem,global_v_lang));
            obj_sub_data.put('defini', get_definite_name(r_tcoursapi.codform,r_tcoursapi.numgrup,r_tcoursapi.numitem));
            obj_sub_data.put('rcnt', v_rcnt_sub);
            obj_row_sub.put(to_char(v_rcnt_sub-1),obj_sub_data);
        end loop;

      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('part', r_tinstapg.numgrup);
      obj_data.put('totscor', r_tinstapg.qtyfscor);
      obj_data.put('avgscor',r_tinstapg.qtyscore);
      obj_data.put('codform', r_tinstapg.codform);
      obj_data.put('detail', get_tintvews_name(r_tinstapg.codform, r_tinstapg.numgrup, global_v_lang));
      obj_data.put('codinst', r_tinstapg.codinst);
      obj_data.put('codsubj', r_tinstapg.codsubj);
      obj_data.put('eval_grd', obj_row_sub);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_tinstapg;
----------------------------------------------------------------------------------
procedure get_eval_instructor(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_codform;
    if param_msg_error is null then
      gen_eval_instructor (json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_eval_instructor;
----------------------------------------------------------------------------------
procedure gen_eval_instructor(json_str_output out clob) is
    obj_data                json;
    obj_row                 json;
    obj_row_sub             json;
    obj_sub_data            json;
    v_rcnt                  number := 0;
    v_rcnt_sub              number := 0;

    cursor c_tintvews is
            select t.codform, t.numgrup, t.qtyfscor
            from tintvews t
            where t.codform = p_codform
            order by t.numgrup;

     cursor c_tintvewd(c_numgrup in varchar2)  is
            select t.codform, t.numgrup, t.numitem ,t.qtyfscor, t.qtywgt
            from tintvewd t
            where t.codform = p_codform
                  and t.numgrup = c_numgrup;
  begin

    obj_row     := json();

    for r_tintvews in c_tintvews loop
        v_rcnt_sub              := 0;
        obj_row_sub             := json();
        for r_tintvewd in c_tintvewd(r_tintvews.numgrup) loop
            v_rcnt_sub                 := v_rcnt_sub+1;
            obj_sub_data               := json();
            obj_sub_data.put('numgrup', r_tintvewd.numgrup);
            obj_sub_data.put('numseq', r_tintvewd.numitem);
            obj_sub_data.put('weight', r_tintvewd.qtywgt);
            obj_sub_data.put('qtyscor', 0);
            obj_sub_data.put('codform', r_tintvewd.codform);
            obj_sub_data.put('codform_desc', get_tintview_name(r_tintvewd.codform,global_v_lang));
            obj_sub_data.put('detail', get_tintvewd_name(p_codform,r_tintvewd.numgrup,r_tintvewd.numitem,global_v_lang));
            obj_sub_data.put('defini', get_definite_name(p_codform,r_tintvewd.numgrup,r_tintvewd.numitem));
            obj_sub_data.put('rcnt', v_rcnt_sub);
            obj_row_sub.put(to_char(v_rcnt_sub-1),obj_sub_data);
        end loop;

      v_rcnt      := v_rcnt+1;
      obj_data    := json();

      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('part', r_tintvews.numgrup);
      obj_data.put('totscor', r_tintvews.qtyfscor);
      obj_data.put('avgscor',0);
      obj_data.put('codform', r_tintvews.codform);
      obj_data.put('detail', get_tintvews_name(r_tintvews.codform, r_tintvews.numgrup, global_v_lang));
      obj_data.put('codinst', p_codinst);
      obj_data.put('codsubj', p_codsubj);
      obj_data.put('eval_grd', obj_row_sub);
      obj_row.put(to_char(v_rcnt-1),obj_data);

    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_eval_instructor;
----------------------------------------------------------------------------------
procedure save_all (json_str_input in clob,json_str_output out clob) is
    json_thisclss_obj              json;
    json_tcosttr_obj               json;
    json_thisclsss_obj             json;
    json_tknowleg_obj              json;
    json_tcoursugg_obj             json;
    json_thistrnn_obj              json;
    json_tcoursaph_obj             json;
    json_tcoursapg_obj             json;
    json_tab5_all_obj              json;
    begin
      initial_value (json_str_input);
      p_codcompy         := hcm_util.get_string(json_params,'p_codcompy');
      p_dteyear          := hcm_util.get_string(json_params,'p_dteyear');
      p_codcours         := hcm_util.get_string(json_params,'p_codcours');
      p_numclseq         := hcm_util.get_string(json_params,'p_numclseq');
      p_codform          := hcm_util.get_string(json_params,'p_codform');
      json_thisclss_obj  := hcm_util.get_json(json_params, 'tab1');
      check_validate_save_tab1 (json_thisclss_obj);

           if param_msg_error is null then
              save_thisclss (json_thisclss_obj);
               if param_msg_error is not null then
                  rollback ;
                  json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
                  return ;
               end if;
           else
               json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
              return ;
           end if;
      ------------------------------------------------------------
       json_tcosttr_obj  := hcm_util.get_json(json_params, 'tab2');
       save_tcosttr (json_tcosttr_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thistrnn_obj  := hcm_util.get_json(json_params, 'tab3');
       save_thistrnn (json_thistrnn_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       if p_codform is not null then
         json_tcoursaph_obj  := hcm_util.get_json(json_params, 'sumScoreCourse');
         save_tcoursaph (json_tcoursaph_obj) ;
         if param_msg_error is not null then
            rollback ;
            json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
            return ;
         end if;

         json_tcoursapg_obj  := hcm_util.get_json(json_params, 'tab4_eval');
         save_tcoursapg (json_tcoursapg_obj) ;
         if param_msg_error is not null then
            rollback ;
            json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
            return ;
         end if;

       end if;
       ------------------------------------------------------------
       json_tcoursugg_obj  := hcm_util.get_json(json_params, 'tab4_suggest');
       save_tcoursugg (json_tcoursugg_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_tab5_all_obj  := hcm_util.get_json(json_params, 'tab5');

       save_tinstapg (json_tab5_all_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_tinstaph (json_tab5_all_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_thisinst (json_tab5_all_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_tinscour;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       save_tcrsinst;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_tknowleg_obj  := hcm_util.get_json(json_params, 'tab6');
       save_tknowleg (json_tknowleg_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thisclsss_obj  := hcm_util.get_json(json_params, 'tab7');
       save_thisclsss (json_thisclsss_obj) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
   exception when others then
    rollback ;
    param_msg_error   := get_error_msg_php('HR2020', global_v_lang);
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
end save_all;
--------------------------------------------------------------------------
procedure check_validate_save_tab1 (json_thisclss_obj in json) is
    v_dtetrst              thisclss.dtetrst%type;
    v_dtetren              thisclss.dtetren%type;
    v_typtrain             thisclss.typtrain%type;
    v_descomptr            thisclss.descomptr%type;
    v_codresp              thisclss.codresp%type;
    v_codhotel             thisclss.codhotel%type;
    v_codinsts             thisclss.codinsts%type;
    v_qtytrmin             thisclss.qtytrmin%type;
    v_count_codresp        number := 0;
    v_count_codhotel       number := 0;
    v_count_codinsts       number := 0;
  begin
    v_dtetrst              := to_date(hcm_util.get_string(json_thisclss_obj, 'dtetrst'),'dd/mm/yyyy');
    v_dtetren              := to_date(hcm_util.get_string(json_thisclss_obj, 'dtetren'),'dd/mm/yyyy');
    v_qtytrmin             := to_number(REPLACE(hcm_util.get_string(json_thisclss_obj, 'qtytrmin'), ':', '.'));
    v_typtrain             := hcm_util.get_string(json_thisclss_obj, 'typtrain');
    v_descomptr            := hcm_util.get_string(json_thisclss_obj, 'descomptr');
    v_codresp              := hcm_util.get_string(json_thisclss_obj, 'codresp');
    v_codhotel             := hcm_util.get_string(json_thisclss_obj, 'codhotel');
    v_codinsts             := hcm_util.get_string(json_thisclss_obj, 'codinsts');

    if v_dtetrst is null or v_dtetren is null or v_qtytrmin is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
           return;
    end if;
    if v_dtetrst > v_dtetren then
       param_msg_error := get_error_msg_php('HR2021',global_v_lang);
           return;
    end if;
    -------------------------------------------------
    if v_dtetrst > sysdate then
       param_msg_error := get_error_msg_php('HR1508',global_v_lang);
           return;
    end if;
    -------------------------------------------------
    if v_typtrain is not null then
       if v_descomptr is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
           return;
       end if;
       if v_typtrain = '11' and v_qtytrmin < 6 then
          param_msg_error := get_error_msg_php('TR0044',global_v_lang);
           return;
       end if;
       if v_typtrain = '12' and v_qtytrmin < 18 then
          param_msg_error := get_error_msg_php('TR0045',global_v_lang);
           return;
       end if;
    end if;
    -------------------------------------------------
    if v_codresp is not null then
        select count(*)
        into v_count_codresp
        from temploy1 t
        where upper(t.codempid) = upper(v_codresp);

        if v_count_codresp = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
           return;
        end if ;
    end if;
    -------------------------------------------------
    if v_codhotel is not null then
        select count(*)
        into   v_count_codhotel
        from thotelif t
        where upper(t.codhotel) = upper(v_codhotel);

        if v_count_codhotel = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'THOTELIF');
           return;
        end if ;
    end if;
    -------------------------------------------------
    if v_codinsts is not null then
        select count(*)
        into   v_count_codinsts
        from tinstitu t
        where upper(t.codinsts) = upper(v_codinsts);

        if v_count_codinsts = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TINSTITU');
           return;
        end if ;
    end if;
end check_validate_save_tab1;
----------------------------------------------------------------------------------------
procedure save_thisclss(json_thisclss_obj in json) is
    v_dteyear               thisclss.dteyear%type;
    v_codcompy              thisclss.codcompy%type;
    v_codcours              thisclss.codcours%type;
    v_numclseq              thisclss.numclseq%type;
    v_objective             thisclss.objective%type;
    v_codresp               thisclss.codresp%type;
    v_codhotel              thisclss.codhotel%type;
    v_codinsts              thisclss.codinsts%type;
    v_dtetrst               thisclss.dtetrst%type;
    v_dtetren               thisclss.dtetren%type;
    v_qtyppc                thisclss.qtyppc%type;
    v_qtytrmin              varchar2(100 char);
    v_amttotexp             thisclss.amttotexp%type;
    v_amtcost               thisclss.amtcost%type;
    v_numcert               thisclss.numcert%type;
    v_dtecert               thisclss.dtecert%type;
    v_typtrain              thisclss.typtrain%type;
    v_descomptr             thisclss.descomptr%type;
    v_dteprest              thisclss.dteprest%type;
    v_dtepreen              thisclss.dtepreen%type;
    v_codexampr             thisclss.codexampr%type;
    v_dtepostst             thisclss.dtepostst%type;
    v_dteposten             thisclss.dteposten%type;
    v_codexampo             thisclss.codexampo%type;
    v_qtytrflw              thisclss.qtytrflw%type;
    v_flgcommt              thisclss.flgcommt%type;
    v_dtecomexp             thisclss.dtecomexp%type;
    v_descommt              thisclss.descommt%type;
    v_descommtn             thisclss.descommtn%type;
    v_codtparg              thisclss.codtparg%type;
    v_flgcerti              thisclss.flgcerti%type;
    v_dtemonth              thisclss.dtemonth%type;
    v_costcent              thisclss.costcent%type;
    v_codform               thisclss.codform%type;

    v_qtytrmin_hour         number;
    v_qtytrmin_minute       number;
    v_qtytrmin_save         number;

    begin
    v_codcompy             := p_codcompy;
    v_dteyear              := p_dteyear;
    v_codcours             := p_codcours;
    v_numclseq             := p_numclseq;
    v_codform              := p_codform;
    v_codresp              := hcm_util.get_string(json_thisclss_obj, 'codresp');
    v_codhotel             := hcm_util.get_string(json_thisclss_obj, 'codhotel');
    v_codinsts             := hcm_util.get_string(json_thisclss_obj, 'codinsts');
    v_dtetrst              := to_date(hcm_util.get_string(json_thisclss_obj, 'dtetrst'),'dd/mm/yyyy');
    v_dtetren              := to_date(hcm_util.get_string(json_thisclss_obj, 'dtetren'),'dd/mm/yyyy');
    v_qtyppc               := hcm_util.get_string(json_thisclss_obj, 'qtyppc');
    v_qtytrmin             := REPLACE(hcm_util.get_string(json_thisclss_obj, 'qtytrmin'), ':', '.');
    v_amttotexp            := hcm_util.get_string(json_thisclss_obj, 'amttotexp');
    v_amtcost              := hcm_util.get_string(json_thisclss_obj, 'amtcost');
    v_numcert              := hcm_util.get_string(json_thisclss_obj, 'numcert');
    v_dtecert              := to_date(hcm_util.get_string(json_thisclss_obj, 'dtecert'),'dd/mm/yyyy');
    v_typtrain             := hcm_util.get_string(json_thisclss_obj, 'typtrain');
    v_descomptr            := hcm_util.get_string(json_thisclss_obj, 'descomptr');
    v_dteprest             := to_date(hcm_util.get_string(json_thisclss_obj, 'dteprest'),'dd/mm/yyyy');
    v_dtepreen             := to_date(hcm_util.get_string(json_thisclss_obj, 'dtepreen'),'dd/mm/yyyy');
    v_codexampr            := hcm_util.get_string(json_thisclss_obj, 'codexampr');
    v_dtepostst            := to_date(hcm_util.get_string(json_thisclss_obj, 'dtepostst'),'dd/mm/yyyy');
    v_dteposten            := to_date(hcm_util.get_string(json_thisclss_obj, 'dteposten'),'dd/mm/yyyy');
    v_codexampo            := hcm_util.get_string(json_thisclss_obj, 'codexampo');
    v_qtytrflw             := hcm_util.get_string(json_thisclss_obj, 'qtytrflw');
    v_flgcommt             := hcm_util.get_string(json_thisclss_obj, 'flgcommt');
    v_dtecomexp            := to_date(hcm_util.get_string(json_thisclss_obj, 'dtecomexp'),'dd/mm/yyyy');
    v_descommt             := hcm_util.get_string(json_thisclss_obj, 'descommt');
    v_descommtn            := hcm_util.get_string(json_thisclss_obj, 'descommtn');
    v_codtparg             := '1';
    v_flgcerti             := hcm_util.get_string(json_thisclss_obj, 'flgcerti');
    v_objective            := hcm_util.get_string(json_thisclss_obj, 'objective');
    v_dtemonth             := to_number(to_char(v_dtetrst,'mm'));
    v_qtytrmin_hour        := nvl(to_number(SUBSTR(v_qtytrmin , 1, instr(v_qtytrmin,'.')-1 )),0);
    v_qtytrmin_minute      := nvl(to_number(SUBSTR(v_qtytrmin, INSTR(v_qtytrmin,'.', -1) + 1)),0);
    v_qtytrmin_save        := (v_qtytrmin_hour*60) + v_qtytrmin_minute;

    begin
       select t.costcent
           into v_costcent
           from tcenter t
           where t.codcompy = p_codcompy
                 and t.comlevel = 1
                 and rownum = 1;
    exception when no_data_found then
       v_costcent  := '';
    end;

        begin
             insert into thisclss
               (
                 codcompy,  dteyear,   codcours,  numclseq,  codresp,
                 codhotel,  codinsts,  dtetrst,   dtetren,   qtyppc,
                 qtytrmin,  amttotexp, amtcost,   numcert,   dtecert,
                 typtrain,  descomptr, dteprest,  dtepreen,  codexampr,
                 dtepostst, dteposten, codexampo, qtytrflw,  flgcommt,
                 dtecomexp, descommt,  descommtn, codtparg,  flgcerti,
                 objective, codcreate, dtecreate, dtemonth,  costcent,
                 coduser,   codform
               )
             values
               (
                 v_codcompy,  v_dteyear,   v_codcours,  v_numclseq,  v_codresp,
                 v_codhotel,  v_codinsts,  v_dtetrst,   v_dtetren,   v_qtyppc,
                 v_qtytrmin_save,  v_amttotexp, v_amtcost,   v_numcert,   v_dtecert,
                 v_typtrain,  v_descomptr, v_dteprest,  v_dtepreen,  v_codexampr,
                 v_dtepostst, v_dteposten, v_codexampo, v_qtytrflw,  v_flgcommt,
                 v_dtecomexp, v_descommt,  v_descommtn, v_codtparg,  v_flgcerti,
                 v_objective, global_v_coduser, sysdate, v_dtemonth, v_costcent,
                 global_v_coduser, v_codform
               );
          exception when DUP_VAL_ON_INDEX then

                update thisclss set
                       codresp   = v_codresp,
                       codhotel  = v_codhotel ,
                       codinsts  = v_codinsts ,
                       dtetrst   = v_dtetrst ,
                       dtetren   = v_dtetren ,
                       qtyppc    = v_qtyppc ,
                       qtytrmin  = v_qtytrmin_save ,
                       amttotexp = v_amttotexp ,
                       amtcost   = v_amtcost ,
                       numcert   = v_numcert ,
                       dtecert   = v_dtecert ,
                       typtrain  = v_typtrain ,
                       descomptr = v_descomptr ,
                       dteprest  = v_dteprest ,
                       dtepreen  = v_dtepreen ,
                       codexampr = v_codexampr ,
                       dtepostst = v_dtepostst ,
                       dteposten = v_dteposten ,
                       codexampo = v_codexampo ,
                       qtytrflw  = v_qtytrflw ,
                       flgcommt  = v_flgcommt ,
                       dtecomexp = v_dtecomexp ,
                       descommt  = v_descommt,
                       descommtn = v_descommtn,
                       flgcerti  = v_flgcerti,
                       objective = v_objective,
                       dtemonth = v_dtemonth,
                       costcent = v_costcent,
                       codform = v_codform,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                where codcompy = p_codcompy
                and upper(codcours) = upper(p_codcours)
                and dteyear = p_dteyear
                and numclseq = v_numclseq
                and codtparg = '1';
          end;
    exception when others then
   param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thisclss ;
--------------------------------------------------------------------------
procedure save_tcosttr (json_tcosttr_obj in json) is
    json_tcosttr_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codcompy                tcosttr.codcompy%type;
    v_dteyear                 tcosttr.dteyear%type;
    v_codcours                tcosttr.codcours%type;
    v_numclseq                tcosttr.numclseq%type;
    v_codexpn                 tcosttr.codexpn%type;
    v_dtemonth                tcosttr.dtemonth%type;
    v_amtcost                 tcosttr.amtcost%type;
    v_amttrcost               tcosttr.amttrcost%type;
    v_codcurr                 tcosttr.codcurr%type;
begin
    json_tcosttr_obj_rows := json_tcosttr_obj ;

    for i in 0..json_tcosttr_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tcosttr_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_codexpn        := hcm_util.get_string(json_row, 'codexpn');
      v_amtcost        := hcm_util.get_string(json_row, 'amtcost');
      v_amttrcost      := hcm_util.get_string(json_row, 'amttrcost');

      select to_number(to_char(dtetrst,'mm'))
          into   v_dtemonth
          from   thisclss
          where  codcompy = v_codcompy
             and upper(codcours) = upper(v_codcours)
             and dteyear = v_dteyear
             and numclseq = v_numclseq;

      select codcurr
      into v_codcurr
      from tcontrpy
      where codcompy = v_codcompy
            and dteeffec = (select max(dteeffec) from tcontrpy where codcompy = v_codcompy and dteeffec  <= trunc(sysdate));
      ---------------------------------
      if v_flg = 'delete' then

          delete from tcosttr t
                 where t.codcompy = v_codcompy
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.codexpn = v_codexpn;
      elsif v_flg = 'add' then
          insert into tcosttr
                 (
                  codcompy, codcours, dteyear,   numclseq, codcreate, dtecreate, coduser,
                  codexpn,  amtcost,  amttrcost, dtemonth, codcurr
                 )
          values
                 (
                 v_codcompy, v_codcours, v_dteyear,   v_numclseq, global_v_coduser, sysdate, global_v_coduser,
                 v_codexpn,  v_amtcost,  v_amttrcost, v_dtemonth, v_codcurr
                 );
      else
          update tcosttr
          set codexpn = v_codexpn,
              amtcost = v_amtcost,
              amttrcost = v_amttrcost,
              dtemonth = v_dtemonth,
              codcurr = v_codcurr,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codcompy = v_codcompy
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and codexpn = v_codexpn;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcosttr ;
--------------------------------------------------------------------------
procedure save_thisclsss (json_thisclsss_obj in json) is
    json_thisclsss_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codcompy                thisclsss.codcompy%type;
    v_dteyear                 thisclsss.dteyear%type;
    v_codcours                thisclsss.codcours%type;
    v_numclseq                thisclsss.numclseq%type;
    v_numseq                  thisclsss.numseq%type;
    v_descomment              thisclsss.descomment%type;
begin
    json_thisclsss_obj_rows := json_thisclsss_obj ;

    for i in 0..json_thisclsss_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thisclsss_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_descomment     := hcm_util.get_string(json_row, 'desothers');
      v_numseq         := hcm_util.get_string(json_row, 'numseq');
      ---------------------------------
      if v_flg = 'delete' then
          delete from thisclsss t
                 where t.codcompy = v_codcompy
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
            select nvl(max(numseq),0)+1
            into   v_numseq
            from   thisclsss
            where  codcompy = v_codcompy
               and upper(codcours) = upper(v_codcours)
               and dteyear = v_dteyear
               and numclseq = v_numclseq;
          insert into thisclsss
                 (
                  codcompy, codcours, dteyear,   numclseq, codcreate, dtecreate, coduser,
                  numseq,   descomment
                 )
          values
                 (
                 v_codcompy, v_codcours, v_dteyear,   v_numclseq, global_v_coduser, sysdate, global_v_coduser,
                 v_numseq,   v_descomment
                 );
      else
          update thisclsss
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codcompy = v_codcompy
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thisclsss;
--------------------------------------------------------------------------
procedure save_tknowleg (json_tknowleg_obj in json) is
    json_tknowleg_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codcompy                tknowleg.codcompy%type;
    v_dteyear                 tknowleg.dteyear%type;
    v_codcours                tknowleg.codcours%type;
    v_numclseq                tknowleg.numclseq%type;
    v_itemno                  tknowleg.itemno%type;
    v_codtparg                tknowleg.codtparg%type;
    v_subject                 tknowleg.subject%type;
    v_details                 tknowleg.details%type;
    v_attfile                 tknowleg.attfile%type;
    v_url                     tknowleg.url%type;
begin
    json_tknowleg_obj_rows := json_tknowleg_obj ;

    for i in 0..json_tknowleg_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tknowleg_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_codtparg       := '1';
      v_subject        := hcm_util.get_string(json_row, 'desc_codsubj');
      v_details        := hcm_util.get_string(json_row, 'detail');
      v_attfile        := hcm_util.get_string(json_row, 'filename');
      v_url            := hcm_util.get_string(json_row, 'url');
      v_itemno         := hcm_util.get_string(json_row, 'itemno');
      ---------------------------------
      if v_flg = 'delete' then
          delete from tknowleg t
                 where t.itemno = v_itemno;
      elsif v_flg = 'add' then

          select nvl(max(itemno),0)+1
          into   v_itemno
          from   tknowleg;

          insert into tknowleg
                 (
                  codcompy, codcours, dteyear, numclseq, codcreate, dtecreate, coduser,
                  codtparg, subject,  details, attfile,  url,       itemno
                 )
          values
                 (
                 v_codcompy, v_codcours, v_dteyear, v_numclseq, global_v_coduser, sysdate, global_v_coduser,
                 v_codtparg, v_subject,  v_details, v_attfile,  v_url,            v_itemno
                 );
      else
          update tknowleg
          set subject = v_subject,
              details = v_details,
              attfile = v_attfile,
              url = v_url,
              dteupd = sysdate,
              coduser = global_v_coduser,
              codcompy = v_codcompy
          where itemno = v_itemno;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tknowleg;
--------------------------------------------------------------------------
procedure save_tcoursugg (json_tcoursugg_obj in json) is
    json_tcoursugg_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codcompy                tcoursugg.codcompy%type;
    v_dteyear                 tcoursugg.dteyear%type;
    v_codcours                tcoursugg.codcours%type;
    v_numclseq                tcoursugg.numclseq%type;
    v_numseq                  tcoursugg.numseq%type;
    v_descomment              tcoursugg.descomment%type;
begin
    json_tcoursugg_obj_rows := json_tcoursugg_obj ;

    for i in 0..json_tcoursugg_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tcoursugg_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_descomment     := hcm_util.get_string(json_row, 'descomment');
      v_numseq         := hcm_util.get_string(json_row, 'numseq');
      ---------------------------------
      if v_flg = 'delete' then

          delete from tcoursugg t
                 where t.codcompy = v_codcompy
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
            select nvl(max(numseq),0)+1
            into   v_numseq
            from   tcoursugg
            where  codcompy = v_codcompy
               and upper(codcours) = upper(v_codcours)
               and dteyear = v_dteyear
               and numclseq = v_numclseq;
          insert into tcoursugg
                 (
                  codcompy, codcours, dteyear,   numclseq, codcreate, dtecreate,coduser,
                  numseq,   descomment
                 )
          values
                 (
                 v_codcompy, v_codcours, v_dteyear,   v_numclseq, global_v_coduser, sysdate, global_v_coduser,
                 v_numseq,   v_descomment
                 );
      else
          update tcoursugg
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codcompy = v_codcompy
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcoursugg;
--------------------------------------------------------------------------
procedure save_thistrnn (json_thistrnn_obj in json) is
    json_thistrnn_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thistrnn.codempid%type;
    v_dteyear                 thistrnn.dteyear%type;
    v_codcours                thistrnn.codcours%type;
    v_numclseq                thistrnn.numclseq%type;

    v_input_qtyprescr         number := 0;
    v_input_qtyposscr         number := 0;
    v_flgtrevl                thistrnn.flgtrevl%type;
    v_qtyprescr               thistrnn.qtyprescr%type;
    v_qtyposscr               thistrnn.qtyposscr%type;
    v_remarks                 thistrnn.remarks%type;
    v_codcompy                thisclss.codcompy%type;
    v_qtytrabs_param          varchar2(100 char);

    i_dtemonth                thisclss.dtemonth%type;
    i_qtytrmin_select         thisclss.qtytrmin%type;
    i_codhotel                thisclss.codhotel%type;
    i_codinsts                thisclss.codinsts%type;
    i_dtetrst                 thisclss.dtetrst%type;
    i_dtetren                 thisclss.dtetren%type;
    i_timestr                 thisclss.timestr%type;
    i_timeend                 thisclss.timeend%type;
    i_amtcost                 thisclss.amtcost%type;
    i_numcert                 thisclss.numcert%type;
    i_typtrain                thisclss.typtrain%type;
    i_descomptr               thisclss.descomptr%type;
    i_dtecert                 thisclss.dtecert%type;
    i_qtytrflw                thisclss.qtytrflw%type;
    i_flgcommt                thisclss.flgcommt%type;
    i_dtecomexp               thisclss.dtecomexp%type;
    i_descommt                thisclss.descommt%type;
    i_descommtn               thisclss.descommtn%type;

    i_qtytrpln                thistrnn.qtytrpln%type;
    i_pcttr                   thistrnn.pcttr%type;
    i_codcomp                 thistrnn.codcomp%type;
    i_codpos                  thistrnn.codpos%type;
    i_dtetrflw                thistrnn.dtetrflw%type;
    i_costcent                thistrnn.costcent%type;
    i_qtytrmin_save           thistrnn.qtytrmin%type;

    v_qtytrabs_hour           number;
    v_qtytrabs_minute         number;
    v_qtytrabs                number;
    i_qtytrmin                number;
begin
    json_thistrnn_obj_rows := json_thistrnn_obj ;

    for i in 0..json_thistrnn_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thistrnn_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      v_codcompy        := p_codcompy;
      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;

      v_codempid              := hcm_util.get_string(json_row, 'codempid');
      v_flgtrevl              := hcm_util.get_string(json_row, 'flgtrevl');
      v_remarks               := hcm_util.get_string(json_row, 'remark');
      v_qtytrabs_param        := REPLACE(hcm_util.get_string(json_row, 'qtytrabs'), ':', '.');
      v_input_qtyprescr       := hcm_util.get_string(json_row, 'qtypretst');
      v_input_qtyposscr       := hcm_util.get_string(json_row, 'qtypostst');

      v_qtytrabs_hour        := nvl(to_number(SUBSTR(v_qtytrabs_param , 1, instr(v_qtytrabs_param,'.')-1 )),0);
      v_qtytrabs_minute      := nvl(to_number(SUBSTR(v_qtytrabs_param, INSTR(v_qtytrabs_param,'.', -1) + 1)),0);
      v_qtytrabs             := (v_qtytrabs_hour*60) + v_qtytrabs_minute;

      check_validate_score_save_tab3(v_input_qtyprescr,v_input_qtyposscr);
      if param_msg_error is not null then
            return;
      else
            v_qtyprescr   := v_input_qtyprescr;
            v_qtyposscr   := v_input_qtyposscr;
      end if;

      if v_flg = 'add' then
         check_validate_save_tab3(json_row);
         if param_msg_error is not null then
            return;
         end if;
      end if;
      begin
      select to_number(to_char(t.dtetrst,'mm')) as dtemonth,
              t.qtytrmin,
              t.codhotel,  t.codinsts, t.dtetrst,  t.dtetren,
              t.timestr,   t.timeend,
              t.amtcost,   t.numcert,
              t.typtrain,  t.descomptr, t.dtecert,  t.qtytrflw, t.flgcommt,
              t.dtecomexp, t.descommt,  t.descommtn
      into    i_dtemonth,  i_qtytrmin_select,
              i_codhotel,  i_codinsts, i_dtetrst,  i_dtetren,
              i_timestr,   i_timeend,
              i_amtcost,   i_numcert,
              i_typtrain,  i_descomptr, i_dtecert,  i_qtytrflw, i_flgcommt,
              i_dtecomexp, i_descommt,  i_descommtn
      from thisclss t
      where t.dteyear = v_dteyear and
            t.codcompy = v_codcompy and
            t.codcours = v_codcours and
            t.numclseq = v_numclseq;
    exception when no_data_found then
          null;
    end;

    i_qtytrmin             := i_qtytrmin_select;
    i_qtytrmin_save        := greatest(i_qtytrmin_select - v_qtytrabs,0);
    i_dtetrflw             := add_months(i_dtetren,i_qtytrflw);
    i_qtytrpln             := i_qtytrmin;
    i_pcttr                := (i_qtytrmin/ i_qtytrpln) * 100;
    begin
        select t.codcomp, t.codpos,t2.costcent
        into i_codcomp, i_codpos, i_costcent
        from temploy1 t
        left join tcenter t2 on t.codcomp = t2.codcomp
        where t.codempid = v_codempid;
    exception when no_data_found then
                     null;
    end;
    i_qtytrmin := i_qtytrmin - v_qtytrabs;
      if v_flg = 'delete' then

          delete from thistrnn t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq;

      elsif v_flg = 'add' then
          insert into thistrnn
                  (
                       codempid, dteyear, codcours, numclseq, qtyprescr, qtyposscr, flgtrevl, remarks,
                       dtemonth,  qtytrmin,
                       codtparg,  codhotel,  codinsts, dtetrst,  dtetren,
                       timestr,   timeend,
                       amtcost,   numcert,
                       typtrain,  descomptr, dtecert,  qtytrflw, flgcommt,
                       dtecomexp, descommt,  descommtn,
                       codcomp,   codpos,    dtetrflw, qtytrpln, pcttr, costcent,
                       dtecreate, codcreate, dteupd,    coduser
                  )
                values
                  (
                       v_codempid, v_dteyear, v_codcours, v_numclseq, v_qtyprescr, v_qtyposscr, v_flgtrevl, v_remarks,
                       i_dtemonth, floor( nvl(i_qtytrmin_save, 0) / 60 )||'.'||mod(nvl(i_qtytrmin_save,0),60),
                       '1',  i_codhotel,  i_codinsts, i_dtetrst,  i_dtetren,
                       i_timestr,   i_timeend,
                       i_amtcost,   i_numcert,
                       i_typtrain,  i_descomptr, i_dtecert,  i_qtytrflw, i_flgcommt,
                       i_dtecomexp, i_descommt,  i_descommtn,
                       i_codcomp,   i_codpos,    i_dtetrflw,floor( nvl(i_qtytrpln, 0) / 60 )||'.'||mod(nvl(i_qtytrpln,0),60), i_pcttr, i_costcent,
                       sysdate, global_v_coduser, sysdate, global_v_coduser
                  );
      else
          update thistrnn
          set qtyprescr = v_qtyprescr,
              qtyposscr = v_qtyposscr,
              flgtrevl = v_flgtrevl,
              remarks = v_remarks,
              dtemonth = i_dtemonth,
              qtytrmin = floor( nvl(i_qtytrmin_save, 0) / 60 )||'.'||mod(nvl(i_qtytrmin_save,0),60),
              codtparg = '1',
              codhotel = i_codhotel,
              codinsts = i_codinsts,
              dtetrst = i_dtetrst,
              dtetren = i_dtetren,
              timestr = i_timestr,
              timeend = i_timeend,
              amtcost = i_amtcost,
              numcert = i_numcert,
              typtrain = i_typtrain,
              descomptr = i_descomptr,
              dtecert = i_dtecert,
              qtytrflw = i_qtytrflw,
              flgcommt = i_flgcommt,
              dtecomexp = i_dtecomexp,
              descommt = i_descommt,
              descommtn = i_descommtn,
              codcomp = i_codcomp,
              codpos = i_codpos,
              dtetrflw = i_dtetrflw,
              qtytrpln = floor( nvl(i_qtytrpln, 0) / 60 )||'.'||mod(nvl(i_qtytrpln,0),60),
              pcttr = i_pcttr,
              dteupd = sysdate,
              coduser = global_v_coduser,
              costcent = i_costcent
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq;
      end if;
      if v_flg != 'delete' then
         begin
         update tpotentp
             set flgatend = 'Y',
                 dtetrst  = i_dtetrst,
                 dtetren = i_dtetren
             where codcompy = v_codcompy
                   and upper(codcours) = upper(v_codcours)
                   and dteyear = v_dteyear
                   and numclseq = v_numclseq
                   and codempid = v_codempid;
        end;
      end if;

    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnn;
--------------------------------------------------------------------------
procedure save_tcoursaph(json_tcoursaph_obj in json) is
    v_dteyear               tcoursaph.dteyear%type;
    v_codcompy              tcoursaph.codcompy%type;
    v_codcours              tcoursaph.codcours%type;
    v_numclseq              tcoursaph.numclseq%type;
    v_qtyfscor              tcoursaph.qtyfscor%type;
    v_qtyscore              tcoursaph.qtyscore%type;

    begin
    v_codcompy             := p_codcompy;
    v_dteyear              := p_dteyear;
    v_codcours             := p_codcours;
    v_numclseq             := p_numclseq;
    v_qtyfscor             := hcm_util.get_string(json_tcoursaph_obj, 'sumTotscor');
    v_qtyscore             := hcm_util.get_string(json_tcoursaph_obj, 'sumAvgscor');

        begin
             insert into tcoursaph
               (
                 codcompy,  dteyear,   codcours,  numclseq,
                 qtyfscor,  qtyscore,
                 codcreate, dtecreate, coduser, dteupd
               )
             values
               (
                 v_codcompy,  v_dteyear,   v_codcours,  v_numclseq,
                 v_qtyfscor,  v_qtyscore,
                 global_v_coduser, sysdate, global_v_coduser, sysdate
               );
          exception when DUP_VAL_ON_INDEX then

                update tcoursaph set
                       qtyfscor  = v_qtyfscor,
                       qtyscore  = v_qtyscore ,
                       dteupd    = sysdate,
                       coduser   = global_v_coduser
                where codcompy = p_codcompy
                and upper(codcours) = upper(p_codcours)
                and dteyear = p_dteyear
                and numclseq = v_numclseq;
          end;
    exception when others then
   param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcoursaph ;
--------------------------------------------------------------------------
procedure save_tcoursapg (json_tcoursapg_obj in json) is
    json_tcoursapg_obj_rows    json;
    json_tcoursapi_obj_rows     json;
    json_row                   json;
    v_codcompy                 tcoursapg.codcompy%type;
    v_dteyear                  tcoursapg.dteyear%type;
    v_codcours                 tcoursapg.codcours%type;
    v_numclseq                 tcoursapg.numclseq%type;
    v_numgrup                  tcoursapg.numgrup%type;
    v_qtyfscor                 tcoursapg.qtyfscor%type;
    v_qtyscore                 tcoursapg.qtyscore%type;
    json_tcoursapi_obj         json;
begin
    json_tcoursapg_obj_rows := json_tcoursapg_obj ;

    for i in 0..json_tcoursapg_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tcoursapg_obj_rows, to_char(i));
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_numgrup       := hcm_util.get_string(json_row, 'part');
      v_qtyfscor      := hcm_util.get_string(json_row, 'totscor');
      v_qtyscore      := hcm_util.get_string(json_row, 'avgscor');

      ---------------------------------
      begin
             insert into tcoursapg
               (
                 codcompy, codcours, dteyear, numclseq, codcreate, dtecreate,coduser, dteupd,
                  numgrup, qtyfscor, qtyscore
               )
             values
               (
                 v_codcompy, v_codcours, v_dteyear, v_numclseq, global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_numgrup,  v_qtyfscor, v_qtyscore
               );
       exception when DUP_VAL_ON_INDEX then

             update tcoursapg
             set numgrup  = v_numgrup,
                 qtyfscor = v_qtyfscor,
                 qtyscore = v_qtyscore,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codcompy = v_codcompy
                   and upper(codcours) = upper(v_codcours)
                   and dteyear = v_dteyear
                   and numclseq = v_numclseq
                   and numgrup = v_numgrup;
        end;

        json_tcoursapi_obj_rows     := hcm_util.get_json(json_row, 'eval_grd');
        json_tcoursapi_obj              := hcm_util.get_json(json_tcoursapi_obj_rows, 'rows');

        for j in 0..json_tcoursapi_obj.count - 1 loop
            save_tcoursapi (json_tcoursapi_obj) ;
            if param_msg_error is not null then
               return ;
            end if;
        end loop;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcoursapg;
--------------------------------------------------------------------------
procedure save_tcoursapi (json_tcoursapi_obj in json) is
    json_tcoursapi_obj_rows   json;
    json_row                  json;
    v_codcompy                tcoursapi.codcompy%type;
    v_dteyear                 tcoursapi.dteyear%type;
    v_codcours                tcoursapi.codcours%type;
    v_numclseq                tcoursapi.numclseq%type;
    v_numgrup                 tcoursapi.numgrup%type;
    v_numitem                 tcoursapi.numitem%type;
    v_qtyfscor                tcoursapi.qtyfscor%type;
    v_grade                   tcoursapi.grade%type;
    v_qtyscore                tcoursapi.qtyscore%type;
begin
    json_tcoursapi_obj_rows := json_tcoursapi_obj ;

    for i in 0..json_tcoursapi_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tcoursapi_obj_rows, to_char(i));
      ---------------------------------
      if p_codcompy is not null then
        v_codcompy := p_codcompy ;
      else
        v_codcompy := hcm_util.get_string(json_row, 'codcompy') ;
      end if;

      if p_dteyear is not null then
        v_dteyear := p_dteyear ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      if p_numclseq is not null then
        v_numclseq := p_numclseq ;
      else
        v_numclseq := hcm_util.get_string(json_row, 'numclseq') ;
      end if;
      v_numgrup     := hcm_util.get_string(json_row, 'numgrup');
      v_numitem     := hcm_util.get_string(json_row, 'numseq');
      v_qtyfscor    := hcm_util.get_string(json_row, 'weight');
      v_grade       := hcm_util.get_string(json_row, 'grade');
      v_qtyscore    := hcm_util.get_string(json_row, 'qtyscor');

      ---------------------------------
      begin
             insert into tcoursapi
               (
                 codcompy, codcours, dteyear, numclseq, codcreate, dtecreate,coduser, dteupd,
                 numgrup, numitem, qtyfscor, grade, qtyscore
               )
             values
               (
                 v_codcompy, v_codcours, v_dteyear, v_numclseq, global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_numgrup, v_numitem, v_qtyfscor, v_grade, v_qtyscore
               );
       exception when DUP_VAL_ON_INDEX then

             update tcoursapi
             set qtyfscor = v_qtyfscor,
                 grade    = v_grade,
                 qtyscore = v_qtyscore,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codcompy = v_codcompy
                   and upper(codcours) = upper(v_codcours)
                   and dteyear = v_dteyear
                   and numclseq = v_numclseq
                   and numgrup = v_numgrup
                   and numitem = v_numitem;
        end;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcoursapi;
--------------------------------------------------------------------------
procedure save_tinstaph (json_tab5_all_obj in json) is
    json_tinstaph_obj_rows    json;
    json_row                   json;
    json_detail_row            json;
    v_codinst                  tinstaph.codinst%type;
    v_codsubj                  tinstaph.codsubj%type;
    v_codform                  tinstaph.codform%type;
    v_qtyempap                 tinstaph.qtyempap%type;
    v_qtyscore                 tinstaph.qtyscore%type;
    v_qtyfscor                 tinstaph.qtyfscor%type;
begin
    json_tinstaph_obj_rows := json_tab5_all_obj ;

    for i in 0..json_tinstaph_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tinstaph_obj_rows, to_char(i));
      json_detail_row   := hcm_util.get_json(json_row, 'detail');

      ---------------------------------
      v_codinst       := hcm_util.get_string(json_detail_row, 'codinst');
      v_codsubj       := hcm_util.get_string(json_detail_row, 'codsubj');
      v_codform       := hcm_util.get_string(json_detail_row, 'codform');
      v_qtyscore      := hcm_util.get_string(json_detail_row, 'sumTotscor');
      v_qtyfscor      := hcm_util.get_string(json_detail_row, 'sumAvgscor');
      ---------------------------------
      begin
        select count(distinct(t.numclseq))
        into v_qtyempap
        from tinstapg t
        where codcompy = p_codcompy
                   and upper(codcours) = upper(p_codcours)
                   and dteyear = p_dteyear
                   and numclseq = p_numclseq
                   and codinst = v_codinst
                   and codsubj = v_codsubj;
      exception when no_data_found then
            v_qtyempap := '';
      end;
      begin
             insert into tinstaph
               (
                 codcompy, codcours, dteyear, numclseq, codcreate, dtecreate,coduser, dteupd,
                 codinst, codsubj, codform, qtyscore, qtyfscor, qtyempap
               )
             values
               (
                 p_codcompy, p_codcours, p_dteyear, p_numclseq, global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_codinst,  v_codsubj, v_codform, v_qtyscore, v_qtyfscor, v_qtyempap
               );
       exception when DUP_VAL_ON_INDEX then

             update tinstaph
             set codform  = v_codform,
                 qtyfscor = v_qtyfscor,
                 qtyscore = v_qtyscore,
                 qtyempap = v_qtyempap,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codcompy = p_codcompy
                   and upper(codcours) = upper(p_codcours)
                   and dteyear = p_dteyear
                   and numclseq = p_numclseq
                   and codinst = v_codinst
                   and codsubj = v_codsubj;
        end;

    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tinstaph;
--------------------------------------------------------------------------
procedure save_tinstapg (json_tab5_all_obj in json) is
    json_tinstapg_obj_rows                  json;
    json_row                                json;
    json_eval_instructor_subject            json;
    json_eval_instructor_subject_rows       json;
    json_eval_row                           json;
    json_detail_row                         json;
    json_tinstapi_obj_rows                  json;
    json_tinstapi_obj                       json;
    v_codsubj                               tinstapg.codsubj%type;
    v_codinst                               tinstapg.codinst%type;
    v_numgrup                               tinstapg.numgrup%type;
    v_qtyfscor                              tinstapg.qtyfscor%type;
    v_qtyscore                              tinstapg.qtyscore%type;
begin
    json_tinstapg_obj_rows := json_tab5_all_obj ;

    for i in 0..json_tinstapg_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tinstapg_obj_rows, to_char(i));
      json_detail_row   := hcm_util.get_json(json_row, 'detail');
      v_codinst       := hcm_util.get_string(json_detail_row, 'codinst');
      v_codsubj       := hcm_util.get_string(json_detail_row, 'codsubj');

      json_eval_instructor_subject   := hcm_util.get_json(json_row, 'eval_instructor_subject');
      json_eval_instructor_subject_rows   := hcm_util.get_json(json_eval_instructor_subject, 'rows');

      for j in 0..json_eval_instructor_subject_rows.count - 1 loop
          json_eval_row          := hcm_util.get_json(json_eval_instructor_subject_rows, to_char(j));
          v_numgrup       := hcm_util.get_string(json_eval_row, 'part');
          v_qtyfscor       := hcm_util.get_string(json_eval_row, 'totscor');
          v_qtyscore       := hcm_util.get_string(json_eval_row, 'avgscor');

          begin
             insert into tinstapg
               (
                 codcompy, codcours, dteyear, numclseq, codcreate, dtecreate,coduser, dteupd,
                 codinst, codsubj, numgrup, qtyscore, qtyfscor
               )
             values
               (
                 p_codcompy, p_codcours, p_dteyear, p_numclseq, global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_codinst,  v_codsubj, v_numgrup, v_qtyscore, v_qtyfscor
               );
         exception when DUP_VAL_ON_INDEX then

               update tinstapg
               set qtyfscor = v_qtyfscor,
                   qtyscore = v_qtyscore,
                   dteupd   = sysdate,
                   coduser  = global_v_coduser
               where codcompy = p_codcompy
                     and upper(codcours) = upper(p_codcours)
                     and dteyear = p_dteyear
                     and numclseq = p_numclseq
                     and codinst = v_codinst
                     and codsubj = v_codsubj
                     and numgrup = v_numgrup;
          end;
          json_tinstapi_obj_rows     := hcm_util.get_json(json_eval_row, 'eval_grd');
          json_tinstapi_obj          := hcm_util.get_json(json_tinstapi_obj_rows, 'rows');

          for k in 0..json_tinstapi_obj.count - 1 loop
              save_tinstapi (json_tinstapi_obj, v_codinst, v_codsubj) ;
              if param_msg_error is not null then
                 return ;
              end if;
          end loop;
      end loop;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tinstapg;
--------------------------------------------------------------------------
procedure save_tinstapi (json_tinstapi_obj in json, c_codinst in varchar2, c_codsubj in varchar2) is
    json_tinstapi_obj_rows    json;
    json_row                  json;
    v_numgrup                 tinstapi.numgrup%type;
    v_numitem                 tinstapi.numitem%type;
    v_qtyfscor                tinstapi.qtyfscor%type;
    v_grade                   tinstapi.grade%type;
    v_qtyscore                tinstapi.qtyscore%type;
begin
    json_tinstapi_obj_rows := json_tinstapi_obj ;

    for i in 0..json_tinstapi_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tinstapi_obj_rows, to_char(i));
      v_numgrup     := hcm_util.get_string(json_row, 'numgrup');
      v_numitem     := hcm_util.get_string(json_row, 'numseq');
      v_qtyfscor    := hcm_util.get_string(json_row, 'weight');
      v_grade       := hcm_util.get_string(json_row, 'grade');
      v_qtyscore    := hcm_util.get_string(json_row, 'qtyscor');
      begin
             insert into tinstapi
               (
                 codcompy, codcours, dteyear, numclseq, codcreate, dtecreate,coduser, dteupd,
                 numgrup, numitem, qtyfscor, grade, qtyscore, codinst, codsubj
               )
             values
               (
                 p_codcompy, p_codcours, p_dteyear, p_numclseq, global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_numgrup, v_numitem, v_qtyfscor, v_grade, v_qtyscore, c_codinst, c_codsubj
               );
       exception when DUP_VAL_ON_INDEX then

             update tinstapi
             set qtyfscor = v_qtyfscor,
                 grade    = v_grade,
                 qtyscore = v_qtyscore,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codcompy = p_codcompy
                   and upper(codcours) = upper(p_codcours)
                   and dteyear = p_dteyear
                   and numclseq = p_numclseq
                   and numgrup = v_numgrup
                   and numitem = v_numitem
                   and codinst = c_codinst
                   and codsubj = c_codsubj;
        end;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tinstapi;
--------------------------------------------------------------------------
procedure save_thisinst (json_tab5_all_obj in json) is
    json_thisinst_obj_rows    json;
    json_row                   json;
    json_detail_row            json;
    v_codinst                  thisinst.codinst%type;
    v_codsubj                  thisinst.codsubj%type;
    v_codform                  thisinst.codform%type;
    v_qtyscore                 thisinst.qtyscore%type;
    v_grade                    thisinst.grade%type;
begin
    json_thisinst_obj_rows := json_tab5_all_obj ;
    for i in 0..json_thisinst_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thisinst_obj_rows, to_char(i));
      json_detail_row   := hcm_util.get_json(json_row, 'detail');
      v_codinst       := hcm_util.get_string(json_detail_row, 'codinst');
      v_codsubj       := hcm_util.get_string(json_detail_row, 'codsubj');
      v_codform       := hcm_util.get_string(json_detail_row, 'codform');
      v_qtyscore      := hcm_util.get_string(json_detail_row, 'sumTotscor');
--<< user20 Date: 16/09/2021  #6890      v_grade         := TRUNC(hcm_util.get_string(json_detail_row, 'sumAvgscor'));
      v_grade         := hcm_util.get_string(json_detail_row, 'sumAvgscor');
--<< user20 Date: 16/09/2021  #6890

      begin
             update thisinst
             set codform  = v_codform,
                 grade = v_grade,
                 qtyscore = v_qtyscore,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codcompy = p_codcompy
                   and upper(codcours) = upper(p_codcours)
                   and dteyear = p_dteyear
                   and numclseq = p_numclseq
                   and codinst = v_codinst
                   and codsubj = v_codsubj;
       end;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thisinst;
--------------------------------------------------------------------------
procedure save_tinscour is
    v_codinsts              thisclss.codinsts%type;
    v_dtetrst               thisclss.dtetrst%type;
    v_sum_score             tinscour.qtyscore%type;

 begin
    begin
       select t.codinsts, t.dtetrst
           into v_codinsts, v_dtetrst
           from thisclss t
           where t.dteyear = p_dteyear
                 and t.codcompy = p_codcompy
                 and t.codcours = p_codcours
                 and t.numclseq = p_numclseq;
    exception when no_data_found then
       return;
    end;

    if v_codinsts is not null then
       begin
            select avg(t2.qtyscore)
            into v_sum_score
            from thisclss t, thisinst t2
            where t.dteyear = p_dteyear
                and t.codcompy = p_codcompy
                and t.codcours = p_codcours
                and t.numclseq = p_numclseq
                and t.codinsts is not null
                and t.dteyear = t2.dteyear
                and t.codcompy = t2.codcompy
                and t.codcours = t2.codcours
                and t.numclseq = t2.numclseq;
        exception when no_data_found then
           return;
        end;

        begin
             insert into tinscour
               (
                 codcreate, dtecreate,coduser, dteupd,
                 codinsts, codcours, dtetrlst, qtyscore
               )
             values
               (
                 global_v_coduser, sysdate, global_v_coduser, sysdate,
                 v_codinsts, p_codcours, v_dtetrst, v_sum_score
               );
       exception when DUP_VAL_ON_INDEX then

             update tinscour
             set dtetrlst = v_dtetrst,
                 qtyscore = v_sum_score,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
             where codinsts = v_codinsts
                   and codcours = p_codcours;
        end;
    end if;

    exception when others then
   param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tinscour ;
--------------------------------------------------------------------------
procedure save_tcrsinst is
    v_rcnt                  number := 0;
    cursor c_tinstaph is
            select t.codinst, t.codsubj,t.qtyscore, t.codcours
            from tinstaph t
            where t.dteyear = p_dteyear
                and t.codcompy = p_codcompy
                and t.codcours = p_codcours
                and t.numclseq = p_numclseq;
  begin
    for r_tinstaph in c_tinstaph loop
      v_rcnt      := v_rcnt+1;
      begin
             update tcrsinst t
             set t.instgrd = r_tinstaph.qtyscore,
                 t.dtetrlst = (select max(a.dtetrain)
                                from ttrsubjd a
                                where a.dteyear = p_dteyear
                                      and a.codcompy = p_codcompy
                                      and a.codcours = p_codcours
                                      and a.numclseq = p_numclseq
                                      and a.codsubj = r_tinstaph.codsubj
                                      and a.codinst = r_tinstaph.codinst)
             where t.codinst = r_tinstaph.codinst
                   and t.codcours = r_tinstaph.codcours
                   and t.codsubj = r_tinstaph.codsubj;
        end;

    end loop;

    exception when others then
   param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_tcrsinst ;
--------------------------------------------------------------------------
procedure check_validate_save_tab3 (json_row in json) is
    v_codempid              thistrnn.codempid%type;
    v_staemp                temploy1.staemp%type;
    v_check_codcompy        tcenter.codcompy%type;
    v_count_codempid        number := 0;
    v_count_dup_pk          number := 0;
  begin
    v_codempid             := hcm_util.get_string(json_row, 'codempid');
    -------------------------------------------------
    if v_codempid is not null then
        select count(t.codempid)
        into   v_count_codempid
        from temploy1 t
        where upper(t.codempid) = upper(v_codempid);

        if v_count_codempid = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
           return;
        end if ;

        select t1.staemp,t2.codcompy
        into v_staemp,v_check_codcompy
        from temploy1 t1
        left join tcenter t2 on t2.codcomp = t1.codcomp
        where t1.codempid = upper(v_codempid);

        if v_staemp = 0 then
           param_msg_error := get_error_msg_php('HR2102',global_v_lang);
           return;
        end if ;

        if v_check_codcompy != p_codcompy then
           param_msg_error := get_error_msg_php('HR7523',global_v_lang);
           return;
        end if ;

        select count(*)
        into v_count_dup_pk
        from thistrnn t
        where t.codempid = v_codempid
              and t.dteyear = p_dteyear
              and t.codcours = p_codcours
              and t.numclseq = p_numclseq;

        if v_count_dup_pk > 0 then
           param_msg_error := get_error_msg_php('HR2005',global_v_lang,'thistrnn');
           return;
        end if ;
    end if;

end check_validate_save_tab3;
----------------------------------------------------------------------------------------
procedure check_validate_score_save_tab3 (v_input_qtyprescr in number, v_input_qtyposscr in number) is
  begin
  if v_input_qtyprescr > 999.99 or v_input_qtyposscr > 999.99 then
     param_msg_error := get_error_msg_php('HR6591',global_v_lang);
           return;
  end if;
  if v_input_qtyprescr < -999.99 or v_input_qtyposscr < -999.99 then
     param_msg_error := get_error_msg_php('HR2020',global_v_lang);
           return;
  end if;
end check_validate_score_save_tab3;
----------------------------------------------------------------------------------------
procedure delete_index (json_str_input in clob, json_str_output out clob) is
    json_row            json;
    v_flg               varchar2(100 char);
    v_codcours          thisclss.codcours%type;
    v_codcompy          thisclss.codcompy%type;
    v_dteyear           thisclss.dteyear%type;
    v_numclseq          thisclss.numclseq%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.count - 1 loop
        json_row          := hcm_util.get_json(json_params, to_char(i));
        v_flg             := hcm_util.get_string(json_row, 'flg');
        v_codcours        := hcm_util.get_string(json_row, 'codcours');
        v_codcompy        := hcm_util.get_string(json_row, 'codcompy');
        v_dteyear         := hcm_util.get_string(json_row, 'dteyear');
        v_numclseq        := hcm_util.get_string(json_row, 'numclseq');
        if v_flg = 'delete' then
           begin
                 delete from thisclss
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tcosttr
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thistrnn
                 where codcours = v_codcours
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq
                       and codtparg = '1';

                 delete from tcoursaph
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tinstaph
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thisclsss
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tknowleg
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;
                 -----------------------------------
                 delete from tcoursapg
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tcoursapi
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tcoursugg
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tinstaph
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tinstapg
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tinstapi
                 where codcours = v_codcours
                       and codcompy = v_codcompy
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;
           end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end delete_index;
----------------------------------------------------------------------------------
procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json;
    obj_data        json;
    obj_result      json;
    v_rec_tran      number;
    v_rec_err       number;
    v_rcnt          number  := 0;

  begin
    initial_value(json_str_input);
    check_thisclass_import(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang); return;
    end if;

    obj_row    := json();
    obj_result := json();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));

    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i)+1);
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
----------------------------------------------------------------------------------
procedure check_thisclass_import(json_str_input in clob) as
    v_count           number :=0 ;

    v_dteyear                 thisclss.dteyear%type;
    v_codcours                thisclss.codcours%type;
    v_numclseq                thisclss.numclseq%type;
    v_codcompy                thisclss.codcompy%type;
    param_json                json;
  begin
    param_json   := hcm_util.get_json(json(json_str_input),'param_json');
    v_dteyear    := hcm_util.get_string(param_json,'p_dteyear');
    v_codcours   := hcm_util.get_string(param_json,'p_codcours');
    v_numclseq   := hcm_util.get_string(param_json,'p_numclseq');
    v_codcompy   := hcm_util.get_string(param_json,'p_codcompy');

    if v_dteyear is not null and v_codcours is not null and v_numclseq is not null and v_codcompy is not null then

       select count(*)
       into v_count
       from thisclss t
       where t.dteyear = v_dteyear
            and t.codcompy = v_codcompy
            and t.codcours = v_codcours
            and t.numclseq = v_numclseq;

        if v_count = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thisclss');
           return;
        end if ;
    end if;

  end check_thisclass_import;
----------------------------------------------------------------------------------------
procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json                json;
    param_data                json;
    param_column              json;
    param_column_row          json;
    param_json_row            json;
    --
    data_file                 varchar2(6000 char);
    v_column                  number := 9;
    v_error                   boolean;
    v_err_code                varchar2(1000 char);
    v_err_filed               varchar2(1000 char);
    v_err_table               varchar2(20 char);
    i                         number;
    v_numseq                  number := 0;
    v_flgsecu                 boolean;
    v_codcomp                 temploy1.codcomp%type;
    v_numlvl                  temploy1.numlvl%type;
    v_cnt                     number := 0;
    v_zupdsal                 varchar2(4);
    v_num                     number := 0;

    v_dteyear                 thistrnn.dteyear%type;
    v_codcours                thistrnn.codcours%type;
    v_numclseq                thistrnn.numclseq%type;
    v_codcompy                thisclss.codcompy%type;

    v_codempid                temploy1.codempid%type;
    v_result                  thistrnn.flgtrevl%type;
    v_qtypretst               thistrnn.qtyprescr%type;
    v_qtypostst               thistrnn.qtyposscr%type;
    v_remark                  thistrnn.remarks%type;
    v_staemp                  temploy1.staemp%type;
    v_check_codcompy          tcenter.codcompy%type;

    i_dtemonth                thisclss.dtemonth%type;
    i_qtytrmin                thisclss.qtytrmin%type;
    i_codhotel                thisclss.codhotel%type;
    i_codinsts                thisclss.codinsts%type;
    i_dtetrst                 thisclss.dtetrst%type;
    i_dtetren                 thisclss.dtetren%type;
    i_timestr                 thisclss.timestr%type;
    i_timeend                 thisclss.timeend%type;
    i_amtcost                 thisclss.amtcost%type;
    i_numcert                 thisclss.numcert%type;
    i_typtrain                thisclss.typtrain%type;
    i_descomptr               thisclss.descomptr%type;
    i_dtecert                 thisclss.dtecert%type;
    i_qtytrflw                thisclss.qtytrflw%type;
    i_flgcommt                thisclss.flgcommt%type;
    i_dtecomexp               thisclss.dtecomexp%type;
    i_descommt                thisclss.descommt%type;
    i_descommtn               thisclss.descommtn%type;

    i_qtytrpln                thistrnn.qtytrpln%type;
    i_pcttr                   thistrnn.pcttr%type;
    i_codcomp                 thistrnn.codcomp%type;
    i_codpos                  thistrnn.codpos%type;
    i_dtetrflw                thistrnn.dtetrflw%type;
    i_costcent                thistrnn.costcent%type;
    i_min                     thistrnn.qtytrmin%type;
    i_min_select              thistrnn.qtytrmin%type;
    i_min_hour                number;
    i_min_minute              number;

    type text is table of varchar2(4000) index by binary_integer;
      v_text   text;
      v_filed  text;
    type arr_int is table of integer index by binary_integer;
      v_text_len arr_int ;

  begin
    v_rec_tran  := 0;
    v_rec_error := 0;

    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json(json(json_str_input),'param_json');
    param_data   := hcm_util.get_json(param_json, 'p_filename');
    param_column := hcm_util.get_json(param_json, 'p_columns');

    v_dteyear    := hcm_util.get_string(param_json,'p_dteyear');
    v_codcours   := hcm_util.get_string(param_json,'p_codcours');
    v_numclseq   := hcm_util.get_string(param_json,'p_numclseq');
    v_codcompy   := hcm_util.get_string(param_json,'p_codcompy');

    begin
      select to_number(to_char(t.dtetrst,'mm')) as dtemonth,
              t.qtytrmin,
              t.codhotel,  t.codinsts, t.dtetrst,  t.dtetren,
              t.timestr,   t.timeend,
              t.amtcost,   t.numcert,
              t.typtrain,  t.descomptr, t.dtecert,  t.qtytrflw, t.flgcommt,
              t.dtecomexp, t.descommt,  t.descommtn
      into    i_dtemonth,  i_qtytrmin,
              i_codhotel,  i_codinsts, i_dtetrst,  i_dtetren,
              i_timestr,   i_timeend,
              i_amtcost,   i_numcert,
              i_typtrain,  i_descomptr, i_dtecert,  i_qtytrflw, i_flgcommt,
              i_dtecomexp, i_descommt,  i_descommtn
      from thisclss t
      where t.dteyear = v_dteyear and
            t.codcompy = v_codcompy and
            t.codcours = v_codcours and
            t.numclseq = v_numclseq;
    exception when no_data_found then
          null;
    end;

    -- get text columns from json
    for i in 0..param_column.count-1 loop
      param_column_row  := json(param_column.get(to_char(i)));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string(param_column_row,'name');
    end loop;
    ---------------------------------------
    for r1 in 0..param_data.count-1 loop
      param_json_row  := hcm_util.get_json(param_data, to_char(r1));
      begin
        v_err_code       := null;
        v_err_filed      := null;
        v_err_table      := null;
        v_numseq         := v_numseq;
        v_error          := false;

        if v_numseq = 0 then
          <<cal_loop>> loop
            v_text(1)   := hcm_util.get_string(param_json_row,'codempid');
            v_text(2)   := hcm_util.get_string(param_json_row,'result');
            v_text(3)   := hcm_util.get_string(param_json_row,'qtypretst');
            v_text(4)   := hcm_util.get_string(param_json_row,'qtypostst');
            v_text(5)   := hcm_util.get_string(param_json_row,'remark');

            v_text_len(1)  := 10;
            v_text_len(2)  := 1;
            v_text_len(5)  := 100;

            ------- loop เก็บข้อมูลจาก excel ตอนแสดง error
            data_file := null;
            for i in 1..5 loop
                if i = 1 then
                   if v_text(i) is null then
                      v_error     := true;
                      v_err_code  := 'HR2045';
                      v_err_filed := v_filed(i);
                      exit cal_loop;
                    end if;
                end if;

              if data_file is null then
                data_file := v_text(i);
              else
                data_file := data_file||'|'||v_text(i);
              end if;
            end loop;
            ------- loop validate
            for i in 1..5 loop
                ------- loop validate lenght
              if i in (1,2,5) then
                if nvl(length(v_text(i)),0) > v_text_len(i) then
                   v_error     := true;
                   v_err_code  := 'HR6591';
                   v_err_filed := v_filed(i) ;
                   exit cal_loop;
                end if ;
              end if ;

              if i in (3,4) then
                 ------- loop validate number or string
                 if check_is_number(v_text(i)) != 1 then
                     v_error     := true;
                     v_err_code  := 'HR6591';
                     v_err_filed := v_filed(i) ;
                     exit cal_loop;
                 end if;

                 ------- loop validate max
                 if v_text(i) > 999.99 then
                    v_error    := true;
                    v_err_code  := 'HR6591';
                    v_err_filed := v_filed(i) ;
                    exit cal_loop;
                 end if;

              end if;

            end loop;
            ------- loop validate 1.codempid
            i := 1;
            begin
              select t1.codcomp,t1.numlvl,t1.staemp,t2.codcompy
                into v_codcomp,v_numlvl,v_staemp,v_check_codcompy
                from temploy1 t1
                left join tcenter t2 on t2.codcomp = t1.codcomp
               where t1.codempid = upper(v_text(i));
              -- ห้ามลบ ต้องใช้
              v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
              if not v_flgsecu then
                v_error     := true;
                v_err_code  := 'HR3007';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
            exception when no_data_found then
            ------ ไม่มีอยู่ในตาราง
              v_error     := true;
              v_err_code  := 'HR2010';
              v_err_table := 'TEMPLOY1';
              v_err_filed := upper(v_filed(i));
              exit cal_loop;
            end;
            ------- staemp พนักงาน 0
            if v_staemp = '0' then
              v_error     := true;
              v_err_code  := 'HR2102' ;
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;

            if v_check_codcompy != v_codcompy then
              v_error     := true;
              v_err_code  := 'HR7523' ;
              v_err_filed := v_filed(i);
              exit cal_loop;
            end if;
            v_codempid := upper(v_text(1));

            ------- loop validate 2.result
            i := 2;
            if upper(v_text(i)) <> 'P' and upper(v_text(i)) <> 'F' then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(i);
                exit cal_loop;
            end if;
            v_result := upper(v_text(i));

            ------- loop validate 3.qtypretst
            i := 3;
            if v_text(i) < -999.99 then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(i);
                exit cal_loop;
            end if;
            v_qtypretst := v_text(i);

            ------- loop validate 4.qtypostst
            i := 4;
            if v_text(i) < -999.99 then
                v_error     := true;
                v_err_code  := 'HR2020';
                v_err_filed := v_filed(i);
                exit cal_loop;
            end if;
            v_qtypostst := v_text(i);

            i := 5;
            v_remark := v_text(i);

            v_err_code := null;
            exit cal_loop;
          end loop; -- cal_loop



    --2.insert/update --
          if not v_error then
            v_rec_tran := v_rec_tran + 1;
            i_dtetrflw := add_months(i_dtetren,i_qtytrflw);
            i_qtytrpln       := i_qtytrmin;
            i_pcttr          := (i_qtytrmin/ i_qtytrpln) * 100;

            ---------- หา i_codcomp, i_codpos
            begin
                select t.codcomp, t.codpos,t2.costcent
                into i_codcomp, i_codpos, i_costcent
                from temploy1 t, tcenter t2
                where t.codempid = v_codempid and
                      t2.codcomp = t.codcomp;
            exception when no_data_found then
                     null;
            end;

            begin
                select nvl(sum(t.qtytrabs),0)*60
                into i_min_select
                from tpotentpd t
                where t.dteyear = v_dteyear and
                      t.codcompy = v_codcompy and
                      t.numclseq = v_numclseq and
                      t.codcours = v_codcours and
                      t.codempid = v_codempid;
            exception when no_data_found then
                     i_min_select := 0;
            end;

            i_min_hour        := nvl(to_number(SUBSTR(i_min_select , 1, instr(i_min_select,'.')-1 )),0);
            i_min_minute      := nvl(to_number(SUBSTR(i_min_select, INSTR(i_min_select,'.', -1) + 1)),0);
            i_min             := (i_min_hour*60) + i_min_minute;

            i_qtytrmin := i_qtytrmin - i_min;

            begin
                insert into thistrnn
                  (
                       codempid, dteyear, codcours, numclseq, qtyprescr, qtyposscr, flgtrevl, remarks,
                       dtemonth,  qtytrmin,
                       codtparg,  codhotel,  codinsts, dtetrst,  dtetren,
                       timestr,   timeend,
                       amtcost,   numcert,
                       typtrain,  descomptr, dtecert,  qtytrflw, flgcommt,
                       dtecomexp, descommt,  descommtn,
                       codcomp,   codpos,    dtetrflw, qtytrpln, pcttr, costcent,
                       dtecreate, codcreate, dteupd,    coduser
                  )
                values
                  (
                       v_codempid, v_dteyear, v_codcours, v_numclseq, v_qtypretst, v_qtypostst, v_result, v_remark,
                       i_dtemonth,  i_qtytrmin,
                       '1',  i_codhotel,  i_codinsts, i_dtetrst,  i_dtetren,
                       i_timestr,   i_timeend,
                       i_amtcost,   i_numcert,
                       i_typtrain,  i_descomptr, i_dtecert,  i_qtytrflw, i_flgcommt,
                       i_dtecomexp, i_descommt,  i_descommtn,
                       i_codcomp,   i_codpos,    i_dtetrflw, i_qtytrpln, i_pcttr, i_costcent,
                       sysdate, global_v_coduser, sysdate, global_v_coduser
                  );
              exception when DUP_VAL_ON_INDEX then
                update thistrnn
                   set qtyprescr = v_qtypretst,
                       qtyposscr = v_qtypostst,
                       flgtrevl = v_result,
                       remarks = v_remark,
                       dtemonth = i_dtemonth,
                       qtytrmin = i_qtytrmin,
                       codtparg = '1',
                       codhotel = i_codhotel,
                       codinsts = i_codinsts,
                       dtetrst = i_dtetrst,
                       dtetren = i_dtetren,
                       timestr = i_timestr,
                       timeend = i_timeend,
                       amtcost = i_amtcost,
                       numcert = i_numcert,
                       typtrain = i_typtrain,
                       descomptr = i_descomptr,
                       dtecert = i_dtecert,
                       qtytrflw = i_qtytrflw,
                       flgcommt = i_flgcommt,
                       dtecomexp = i_dtecomexp,
                       descommt = i_descommt,
                       descommtn = i_descommtn,
                       codcomp = i_codcomp,
                       codpos = i_codpos,
                       dtetrflw = i_dtetrflw,
                       qtytrpln = i_qtytrpln,
                       pcttr = i_pcttr,
                       dteupd = sysdate,
                       coduser = global_v_coduser,
                       costcent = i_costcent
                 where dteyear = v_dteyear
                       and v_codempid = v_codempid
                       and codcours = v_codcours
                       and numclseq = v_numclseq;
              end ;
            ----------------------------------------------
            commit;
          else
            v_rec_error      := v_rec_error + 1;
            v_cnt            := v_cnt+1;
            p_text(v_cnt)       := data_file;
            p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table),'@#$%400',null)||'['||v_err_filed||']';
            p_numseq(v_cnt)     := r1;
          end if;
        end if;
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
----------------------------------------------------------------------------------
function check_is_number(p_string IN VARCHAR2) return integer IS
    v_new_num           number :=0 ;
  begin
    v_new_num := TO_NUMBER(p_string); return 1;
  exception when VALUE_ERROR then
            return 0;
end check_is_number;
----------------------------------------------------------------------------------------
procedure get_qtytrabs (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_qtytrabs(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
end get_qtytrabs;
----------------------------------------------------------------------------------
procedure gen_qtytrabs(json_str_output out clob) is
    obj_data                json;
    v_qtytrabs              tpotentpd.qtytrabs%type        := '';

  begin
    begin
      select nvl(sum(t.qtytrabs),0)
      into v_qtytrabs
      from tpotentpd t
      where t.dteyear = p_dteyear and
            t.codcompy = p_codcompy and
            t.numclseq = p_numclseq and
            t.codcours = p_codcours and
            t.codempid = p_codempid;

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('qtytrabs', v_qtytrabs);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

end gen_qtytrabs;
----------------------------------------------------------------------------------
procedure get_des_codcomp (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_des_codcomp(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
end get_des_codcomp;
----------------------------------------------------------------------------------
procedure gen_des_codcomp(json_str_output out clob) is
    obj_data                json;
    v_des_codcomp           tcenter.namcente%type;

  begin
    begin
      select get_tcenter_name(t.codcomp,global_v_lang)
      into v_des_codcomp
      from temploy1 t
      where t.codempid = p_codempid;

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('des_codcomp', v_des_codcomp);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

end gen_des_codcomp;
----------------------------------------------------------------------------------
procedure get_tcontrpy (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_tcontrpy(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
end get_tcontrpy;
----------------------------------------------------------------------------------
procedure gen_tcontrpy(json_str_output out clob) is
    obj_data                json;
    v_codcurr               tcontrpy.codcurr%type;

  begin
    begin
      select t.codcurr
      into v_codcurr
      from tcontrpy t
      where t.codcompy = p_codcompy
            and t.dteeffec = ( select max(t2.dteeffec)
                               from tcontrpy t2
                               where t2.codcompy = p_codcompy
                               and t2.dteeffec  <= trunc(sysdate)
                              );

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codcurr', get_tcodec_name('TCODCURR',v_codcurr,global_v_lang));
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);

end gen_tcontrpy;
----------------------------------------------------------------------------------
procedure get_tcourse_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
       gen_tcourse_detail(json_str_output);
    end if;

    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tcourse_detail;
----------------------------------------------------------------------------------
procedure gen_tcourse_detail (json_str_output out clob) is
    obj_data                json;
    v_cours_desc            varchar2(4000 char);
    v_codcate_desc          varchar2(4000 char);
    v_typtrain_desc         varchar2(4000 char);
    v_syncond_desc          varchar2(4000 char);
    v_descours              tcourse.descours%type;
    v_amtbudg               tcourse.amtbudg%type;

  begin
    begin
      select
        t.codcours || ' ' || get_tcourse_name(t.codcours,global_v_lang),
        get_tcodec_name('TCODCATE',t.codcate,global_v_lang),
        get_tlistval_name('TYPTRAIN', t.typtrain,global_v_lang),
        t.descours,
        t.amtbudg,
        get_logical_name('HRTR11E', t.syncond,global_v_lang)
      into
        v_cours_desc, v_codcate_desc, v_typtrain_desc, v_descours, v_amtbudg, v_syncond_desc
      from tcourse t
      where upper(t.codcours) = upper(p_codcours);

    exception when no_data_found then
          null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('cours_desc', v_cours_desc);
    obj_data.put('codcate_desc', v_codcate_desc);
    obj_data.put('typtrain_desc', v_typtrain_desc);
    obj_data.put('descours', v_descours);
    obj_data.put('amtbudg', v_amtbudg);
    obj_data.put('syncond_desc', v_syncond_desc);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||SQLERRM||'87878787';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tcourse_detail;

end HRTR63E;

/

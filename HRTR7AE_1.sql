--------------------------------------------------------
--  DDL for Package Body HRTR7AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7AE" is
-- last update: 19/01/2021 15:20
 procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj            := json(json_str_input);

    global_v_coduser    := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang       := json_ext.get_string(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string(json_obj,'p_codempid_query');
    p_year              := hcm_util.get_string(json_obj,'p_year');
    p_codcours          := hcm_util.get_string(json_obj,'p_codcours');
    p_dtetrst           := to_date(json_ext.get_string(json_obj,'p_dtetrst'),'ddmmyyyy');

    json_params       := hcm_util.get_json(json_obj, 'params');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
----------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------
  procedure check_index as
    v_codcomp           temploy1.codcomp%type;
    v_flgsecu           boolean := false;
  begin
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codempid is not null then
      v_codcomp := hcm_util.get_temploy_field(p_codempid, 'codcomp');
      if v_codcomp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');

          v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          end if;
      end if;
    end if;
  end check_index;
----------------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    v_codcours      thistrnn.codcours%type;
    v_codcate       tcourse.codcate%type;
    v_dtetrst       thistrnn.dtetrst%type;
    v_dtetren       thistrnn.dtetren%type;
    v_numclseq      thistrnn.numclseq%type;
    ----------------------------------

    cursor c_thistrnn is
            select
            t.codcours, c.codcate,
            t.dtetrst, t.dtetren, t.numclseq
      into   v_codcours, v_dtetrst, v_codcate, v_dtetren, v_numclseq
      from thistrnn t
      join tcourse c on t.codcours = c.codcours
      where t.codtparg = '2'
      and t.dteyear = p_year
      and t.codempid = p_codempid;

  begin
    obj_row     := json();
    for r_thistrnn in c_thistrnn loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');
        obj_data.put('codcours', r_thistrnn.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(r_thistrnn.codcours, global_v_lang));
        obj_data.put('desc_category', r_thistrnn.codcate);
        obj_data.put('dtetrst', to_char(r_thistrnn.dtetrst, 'dd/mm/yyyy'));
        obj_data.put('dtetren', to_char(r_thistrnn.dtetren, 'dd/mm/yyyy'));
        obj_data.put('codempid', p_codempid);
        obj_data.put('dteyear', p_year);
        obj_data.put('numclseq', r_thistrnn.numclseq);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_index;
----------------------------------------------------------------------------------------
  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_search;
  if param_msg_error is null then
     json_str_output := get_response_message(null,param_msg_error,global_v_lang);
     return;
  else
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
----------------------------------------------------------------------------------------
  procedure check_search as
    v_count_codcours    number ;
    v_count             number ;
  begin
    -------------------------------------------------
    if p_codempid is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -------------------------------------------------
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -------------------------------------------------
    if p_codcours is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -------------------------------------------------
    if p_dtetrst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    -------------------------------------------------
    select count(t.codcours)
    into   v_count_codcours
    from tcourse t
    where upper(t.codcours) = upper(p_codcours);

    if v_count_codcours = 0 then
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcourse');
       return;
    end if ;
    -------------------------------------------------
    select count(t.numclseq)
    into   v_count
    from thistrnn t
    where t.codempid = p_codempid
    and upper(t.codcours) = upper(p_codcours)
    and t.dteyear = p_year
    and p_dtetrst between (t.dtetrst + 1) and t.dtetren
    and t.codtparg = '2';

    if v_count > 0 then
       param_msg_error := get_error_msg_php('HR2025',global_v_lang);
       return;
    end if ;

  end check_search;
----------------------------------------------------------------------------------------
procedure get_thistrnn(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thistrnn(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_thistrnn;
----------------------------------------------------------------------------------------
procedure gen_thistrnn(json_str_output out clob) as
    obj_data               json;
    v_codempid             thistrnn.codempid%type;
    v_dteyear              thistrnn.dteyear%type;
    v_codcours             thistrnn.codcours%type;
    v_dtetrst              thistrnn.dtetrst%type;
    v_codtparg             thistrnn.codtparg%type;
    v_dtetren              thistrnn.dtetren%type;
    v_codhotel             thistrnn.codhotel%type;
    v_codinsts             thistrnn.codinsts%type;
    v_codinst              thistrnn.codinst%type;
    v_qtytrpln             thistrnn.qtytrpln%type;
    v_amtcost              thistrnn.amtcost%type;
    v_numcert              thistrnn.numcert%type;
    v_dtecert              thistrnn.dtecert%type;
    v_descomptr            thistrnn.descomptr%type;
    v_flgcommt             thistrnn.flgcommt%type;
    v_dtecomexp            thistrnn.dtecomexp%type;
    v_descommt             thistrnn.descommt%type;
    v_descommtn            thistrnn.descommtn%type;
    v_flgtrain             thistrnn.flgtrain%type;
    v_qtytrflw             thistrnn.qtytrflw%type;
    v_content              thistrnn.content%type;
    v_naminse              thistrnn.naminse%type;
    v_naminst              thistrnn.naminst%type;
    v_namins3              thistrnn.namins3%type;
    v_namins4              thistrnn.namins4%type;
    v_namins5              thistrnn.namins5%type;
    v_namins               thistrnn.naminse%type;
    v_flgdef               boolean:= false;

  begin
    begin
      select t.codempid,t.dteyear,t.codcours,t.dtetrst,t.codtparg,t.dtetren, t.codhotel,t.codinsts,t.codinst,
      t.qtytrpln,t.amtcost,t.numcert,t.dtecert,t.descomptr,t.flgcommt,t.dtecomexp,
      t.descommt,t.descommtn,t.flgtrain,t.qtytrflw,t.content,
      t.naminse,t.naminst,t.namins3,t.namins4,t.namins5,
      decode(global_v_lang, '101', t.naminse,
                            '102', t.naminst,
                            '103', t.namins3,
                            '104', t.namins4,
                            '105', t.namins5,
                            t.naminse) as namins
      into   v_codempid,v_dteyear,v_codcours,v_dtetrst,v_codtparg,v_dtetren, v_codhotel,v_codinsts,v_codinst,
      v_qtytrpln,v_amtcost,v_numcert,v_dtecert,v_descomptr,v_flgcommt,v_dtecomexp,
      v_descommt,v_descommtn,v_flgtrain,v_qtytrflw,v_content,
      v_naminse,v_naminst,v_namins3,v_namins4,v_namins5,v_namins
      from   thistrnn t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst)
            and t.codtparg = '2';

    exception when no_data_found then

        begin
          select t2.dtetrst, t2.dtetren, t2.codhotel, t2.codinsts, t2.codinst, t2.amtclbdg,
          floor( nvl(t2.qtytrmin, 0) / 60 )||'.'||mod(NVL(t2.qtytrmin, 0),60) as qtytrmin
          into v_dtetrst, v_dtetren, v_codhotel, v_codinsts, v_codinst, v_amtcost, v_qtytrpln
          from tyrtrsch t2
          where t2.codtparg = '2'
            and t2.dteyear = p_year
            and upper(t2.codcompy) = upper(get_codcompy_by_codempid(p_codempid))
            and upper(t2.codcours) = upper(p_codcours)
            and t2.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst);
        exception when no_data_found then
             null;
             v_flgdef := true;
        end;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('dteyear', p_year);
    obj_data.put('codcours', p_codcours);
    if v_flgdef then
       obj_data.put('dtetrst',to_char(to_date(p_dtetrst,'yyyy-mm-dd HH24:MI:SS'),'dd/mm/yyyy'));
       obj_data.put('dtetren',to_char(to_date(p_dtetrst,'yyyy-mm-dd HH24:MI:SS'),'dd/mm/yyyy'));
    else
       obj_data.put('dtetrst', nvl( to_char(v_dtetrst, 'dd/mm/yyyy'),''));
       obj_data.put('dtetren', nvl( to_char(v_dtetren, 'dd/mm/yyyy'),''));
    end if;
    obj_data.put('codtparg', v_codtparg);
    obj_data.put('codhotel', v_codhotel);
    obj_data.put('codinsts', v_codinsts);
    obj_data.put('codinst', v_codinst);
    obj_data.put('qtytrpln', v_qtytrpln);
    obj_data.put('amtcost', v_amtcost);
    obj_data.put('numcert', v_numcert);
    obj_data.put('dtecert', nvl( to_char(v_dtecert, 'dd/mm/yyyy'),''));
    obj_data.put('descomptr', v_descomptr);
    obj_data.put('flgcommt', v_flgcommt);
    obj_data.put('dtecomexp', nvl( to_char(v_dtecomexp, 'dd/mm/yyyy'),''));
    obj_data.put('descommt', v_descommt);
    obj_data.put('descommtn', v_descommtn);
    obj_data.put('flgtrain', v_flgtrain);
    obj_data.put('qtytrflw', v_qtytrflw);
    obj_data.put('content', v_content);
    obj_data.put('naminse', v_naminse);
    obj_data.put('naminst', v_naminst);
    obj_data.put('namins3', v_namins3);
    obj_data.put('namins4', v_namins4);
    obj_data.put('namins5', v_namins5);
    obj_data.put('namins', v_namins);


    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);

  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace||'777'||SQLERRM;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_thistrnn;
----------------------------------------------------------------------------------------
procedure get_thistrnf(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thistrnf(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thistrnf;
----------------------------------------------------------------------------------------
procedure gen_thistrnf(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    ----------------------------------

    cursor c_thistrnf is
      select t.filename, t.descfile, t.numclseq ,t.numseq
      from thistrnf t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst)
      order by t.numseq;

  begin
    obj_row     := json();
    for r_thistrnf in c_thistrnf loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('filename', r_thistrnf.filename);
        obj_data.put('descfile', r_thistrnf.descfile);
        obj_data.put('numclseq', r_thistrnf.numclseq);
        obj_data.put('numseq', r_thistrnf.numseq);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
end gen_thistrnf;
----------------------------------------------------------------------------------------
procedure get_thistrnb(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thistrnb(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thistrnb;
----------------------------------------------------------------------------------------
  procedure gen_thistrnb(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c_thistrnb is
      select t.descomment, t.numclseq, t.numseq
      from thistrnb t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst)
      order by t.numseq;

  begin
    obj_row     := json();
    for r_thistrnb in c_thistrnb loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('descomment', r_thistrnb.descomment);
        obj_data.put('numclseq', r_thistrnb.numclseq);
        obj_data.put('numseq', r_thistrnb.numseq);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_thistrnb;
----------------------------------------------------------------------------------------
procedure get_thistrns(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thistrns(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thistrns;
----------------------------------------------------------------------------------------
procedure gen_thistrns(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c_thistrns is
      select t.descomment, t.numclseq, t.numseq
      from thistrns t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst)
      order by t.numseq;

  begin
    obj_row     := json();
    for r_thistrns in c_thistrns loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');
        obj_data.put('descomment', r_thistrns.descomment);
        obj_data.put('numclseq', r_thistrns.numclseq);
        obj_data.put('numseq', r_thistrns.numseq);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
end gen_thistrns;
----------------------------------------------------------------------------------------
  procedure get_tknowleg(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tknowleg(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_tknowleg;
----------------------------------------------------------------------------------------
procedure gen_tknowleg(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c_tknowleg is
      select t.subject,t.details,t.attfile,t.url,t.itemno
      from tknowleg t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst)
      order by t.itemno;

  begin
    obj_row     := json();
    for r_tknowleg in c_tknowleg loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');
        obj_data.put('subject', r_tknowleg.subject);
        obj_data.put('details', r_tknowleg.details);
        obj_data.put('attfile', r_tknowleg.attfile);
        obj_data.put('url', r_tknowleg.url);
        obj_data.put('itemno', r_tknowleg.itemno);
        obj_data.put('path_filename', '/file_uploads/'||get_tfolderd('HRTR7AE')||'/'||r_tknowleg.attfile);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
end gen_tknowleg;
----------------------------------------------------------------------------------------
procedure get_thistrnp(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thistrnp(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thistrnp;
----------------------------------------------------------------------------------------
procedure gen_thistrnp(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c_thistrnp is
      select t.descplan, t.dtestr,t.dteend,t.descomment,t.numclseq,t.numseq
      from thistrnp t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst);

  begin
    obj_row     := json();
    for r_thistrnp in c_thistrnp loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('descplan', r_thistrnp.descplan);
        obj_data.put('dtestr', to_char(r_thistrnp.dtestr, 'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(r_thistrnp.dteend, 'dd/mm/yyyy'));
        obj_data.put('descomment', r_thistrnp.descomment);
        obj_data.put('numclseq', r_thistrnp.numclseq);
        obj_data.put('numseq', r_thistrnp.numseq);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
end gen_thistrnp;
----------------------------------------------------------------------------------------
procedure get_thiscost(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_thiscost(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_thiscost;
----------------------------------------------------------------------------------------
procedure gen_thiscost(json_str_output out clob) as
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;

    cursor c_thiscost is
      select t.codexpn,t.typexpn,t.amtcost,t.numclseq,t.amttrcost
      from thiscost t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_year
            and t.numclseq = get_numclseq(p_codcours,p_year,p_dtetrst);

  begin
    obj_row     := json();
    for r_thiscost in c_thiscost loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('codexpn', r_thiscost.codexpn);
        obj_data.put('typexpn', r_thiscost.typexpn);
        obj_data.put('amtcost', r_thiscost.amtcost);
        obj_data.put('numclseq', r_thiscost.numclseq);
        obj_data.put('qtypaysend', r_thiscost.amttrcost);
        obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
end gen_thiscost;
----------------------------------------------------------------------------------------
procedure save_all (json_str_input in clob,json_str_output out clob) is
    json_thistrnn_obj     json;
    json_thistrnf_obj     json;
    json_thistrnb_obj     json;
    json_thistrns_obj     json;
    json_tknowleg_obj     json;
    json_thistrnp_obj     json;
    json_thiscost_obj     json;
    begin
      initial_value (json_str_input);
      p_codempid         := hcm_util.get_string(json_params,'p_codempid_query');
      p_year             := hcm_util.get_string(json_params,'p_year');
      p_codcours         := hcm_util.get_string(json_params,'p_codcours');
      p_dtetrst          := to_date(hcm_util.get_string(json_params,'p_dtetrst'),'ddmmyyyy');

      json_thistrnn_obj  := hcm_util.get_json(json_params, 'tab1Detail');
      check_validate_save_tab1 (json_thistrnn_obj);
           if param_msg_error is null then
              save_thistrnn (json_thistrnn_obj,param_msg_error);
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
       json_thistrnf_obj  := hcm_util.get_json(json_params, 'tab1');
       save_thistrnf (json_thistrnf_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thistrnb_obj  := hcm_util.get_json(json_params, 'tab21');
       save_thistrnb (json_thistrnb_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thistrns_obj  := hcm_util.get_json(json_params, 'tab22');
       param_msg_error := '22';
       save_thistrns (json_thistrns_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_tknowleg_obj  := hcm_util.get_json(json_params, 'tab3');
       save_tknowleg (json_tknowleg_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thistrnp_obj  := hcm_util.get_json(json_params, 'tab4');
       save_thistrnp (json_thistrnp_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
       ------------------------------------------------------------
       json_thiscost_obj  := hcm_util.get_json(json_params, 'tab5');
       save_thiscost (json_thiscost_obj,param_msg_error) ;
       if param_msg_error is not null then
          rollback ;
          json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
          return ;
       end if;
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
procedure save_thistrnn (json_thistrnn_obj in json  , param_msg_error out varchar2) is
    v_codempid             thistrnn.codempid%type;
    v_dteyear              thistrnn.dteyear%type;
    v_codcours             thistrnn.codcours%type;
    v_dtetrst              thistrnn.dtetrst%type;
    v_codtparg             thistrnn.codtparg%type;
    v_numclseq             thistrnn.numclseq%type;
    v_dtetren              thistrnn.dtetren%type;
    v_codhotel             thistrnn.codhotel%type;
    v_codinsts             thistrnn.codinsts%type;
    v_codinst              thistrnn.codinst%type;
    v_qtytrpln             thistrnn.qtytrpln%type;
    v_qtytrmin             thistrnn.qtytrmin%type;
    v_amtcost              thistrnn.amtcost%type;
    v_numcert              thistrnn.numcert%type;
    v_dtecert              thistrnn.dtecert%type;
    v_descomptr            thistrnn.descomptr%type;
    v_flgcommt             thistrnn.flgcommt%type;
    v_dtecomexp            thistrnn.dtecomexp%type;
    v_descommt             thistrnn.descommt%type;
    v_descommtn            thistrnn.descommtn%type;
    v_flgtrain             thistrnn.flgtrain%type;
    v_qtytrflw             thistrnn.qtytrflw%type;
    v_content              thistrnn.content%type;
    v_naminse              thistrnn.naminse%type;
    v_naminst              thistrnn.naminst%type;
    v_namins3              thistrnn.namins3%type;
    v_namins4              thistrnn.namins4%type;
    v_namins5              thistrnn.namins5%type;
    v_namins               thistrnn.naminse%type;
    v_dtemonth             thistrnn.dtemonth%type;
    v_codcomp              thistrnn.codcomp%type;
    v_codpos               thistrnn.codpos%type;
    v_costcent             thistrnn.costcent%type;
    v_dtetrflw             thistrnn.dtetrflw%type;

    begin
    v_codempid             := p_codempid;
    v_dteyear              := nvl(to_number(p_year), '');
    v_codcours             := p_codcours;
    v_dtetrst              := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtetrst'),'dd/mm/yyyy');
    v_codtparg             := '2';
    v_dtetren              := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtetren'),'dd/mm/yyyy');

    v_codhotel             := hcm_util.get_string(json_thistrnn_obj, 'codhotel');
    v_codinsts             := hcm_util.get_string(json_thistrnn_obj, 'codinsts');
    v_codinst              := hcm_util.get_string(json_thistrnn_obj, 'codinst');
    v_qtytrpln             := to_number(REPLACE(hcm_util.get_string(json_thistrnn_obj, 'qtytrpln'), ':', '.'));
    v_qtytrmin             := v_qtytrpln;
    v_amtcost              := to_number(hcm_util.get_string(json_thistrnn_obj, 'amtcost'));

    v_numcert              := hcm_util.get_string(json_thistrnn_obj, 'numcert');
    v_dtecert              := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtecert'),'dd/mm/yyyy');
    v_descomptr            := hcm_util.get_string(json_thistrnn_obj, 'descomptr');
    v_flgcommt             := hcm_util.get_string(json_thistrnn_obj, 'flgcommt');
    v_dtecomexp            := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtecomexp'),'dd/mm/yyyy');
    v_descommt             := hcm_util.get_string(json_thistrnn_obj, 'descommt');
    v_descommtn            := hcm_util.get_string(json_thistrnn_obj, 'descommtn');
    v_flgtrain             := hcm_util.get_string(json_thistrnn_obj, 'flgtrain');
    v_qtytrflw             := hcm_util.get_string(json_thistrnn_obj, 'qtytrflw');

    v_content              := hcm_util.get_string(json_thistrnn_obj, 'content');
    v_naminse              := hcm_util.get_string(json_thistrnn_obj, 'naminse');
    v_naminst              := hcm_util.get_string(json_thistrnn_obj, 'naminst');
    v_namins3              := hcm_util.get_string(json_thistrnn_obj, 'namins3');
    v_namins4              := hcm_util.get_string(json_thistrnn_obj, 'namins4');
    v_namins5              := hcm_util.get_string(json_thistrnn_obj, 'namins5');
    v_namins               := hcm_util.get_string(json_thistrnn_obj, 'namins');
    v_dtemonth             := to_number(to_char(v_dtetrst,'mm'));
    v_codcomp              := get_codcomp_by_codempid(p_codempid);
    v_codpos               := get_codpos_by_codempid(p_codempid);
    v_costcent             := get_costcent_by_codcomp(v_codcomp);
    v_dtetrflw             := add_months(v_dtetren,v_qtytrflw);

    if global_v_lang = '101' then
      v_naminse := v_namins;
    elsif global_v_lang = '102' then
      v_naminst := v_namins;
    elsif global_v_lang = '103' then
      v_namins3 := v_namins;
    elsif global_v_lang = '104' then
      v_namins4 := v_namins;
    elsif global_v_lang = '105' then
      v_namins5 := v_namins;
    end if;

    v_numclseq     := get_numclseq(p_codcours,p_year,p_dtetrst);
        begin
             insert into thistrnn
               (
                 codtparg, dtetren, codhotel, codinsts, codinst, qtytrpln, amtcost, numcert,
                 dtecert, descomptr, flgcommt, dtecomexp, descommt, descommtn, flgtrain, qtytrflw,
                 content, naminse, naminst, namins3, namins4, namins5, dtemonth,
                 numclseq, codempid, dteyear, codcours, dtetrst, codcomp, codpos, qtytrmin, pcttr,
                 costcent, dtetrflw, codcreate, coduser
               )
             values
               (
                 v_codtparg, v_dtetren, v_codhotel, v_codinsts, v_codinst, v_qtytrpln, v_amtcost, v_numcert,
                 v_dtecert, v_descomptr, v_flgcommt, v_dtecomexp, v_descommt, v_descommtn, v_flgtrain, v_qtytrflw,
                 v_content, v_naminse, v_naminst, v_namins3, v_namins4, v_namins5, v_dtemonth,
                 v_numclseq, v_codempid, v_dteyear ,v_codcours, v_dtetrst, v_codcomp, v_codpos, v_qtytrmin, 100,
                 v_costcent, v_dtetrflw, global_v_coduser, global_v_coduser
               );
          exception when DUP_VAL_ON_INDEX then

                update thistrnn set
                       codtparg =  v_codtparg,
                       dtetren =  v_dtetren ,
                       codhotel =  v_codhotel ,
                       codinsts =  v_codinsts ,
                       codinst =  v_codinst ,
                       qtytrpln =  v_qtytrpln ,
                       amtcost =  v_amtcost ,
                       numcert =  v_numcert ,
                       dtecert =  v_dtecert ,
                       descomptr =  v_descomptr ,
                       flgcommt =  v_flgcommt ,
                       dtecomexp =  v_dtecomexp ,
                       descommt =  v_descommt ,
                       descommtn =  v_descommtn ,
                       flgtrain =  v_flgtrain ,
                       qtytrflw =  v_qtytrflw ,
                       content =  v_content ,
                       naminse =  v_naminse ,
                       naminst =  v_naminst ,
                       namins3 =  v_namins3 ,
                       namins4 =  v_namins4 ,
                       namins5 =  v_namins5 ,
                       dtemonth = v_dtemonth,
                       codcomp = v_codcomp,
                       codpos = v_codpos,
                       qtytrmin = v_qtytrmin,
                       pcttr = 100,
                       costcent = v_costcent,
                       dtetrflw = v_dtetrflw,
                       coduser = global_v_coduser
                where codempid = p_codempid
                and upper(codcours) = upper(p_codcours)
                and dteyear = p_year
                and numclseq = v_numclseq
                and codtparg = '2';
          end;
    exception when others then
   param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnn ;
--------------------------------------------------------------------------
procedure check_validate_save_tab1 (json_thistrnn_obj in json) is
    v_codhotel             thistrnn.codhotel%type;
    v_codinsts             thistrnn.codinsts%type;
    v_codinst              thistrnn.codinst%type;
    v_dtetrst              thistrnn.dtetrst%type;
    v_dtetren              thistrnn.dtetren%type;
    v_dtecomexp            thistrnn.dtecomexp%type;
    v_numcert              thistrnn.numcert%type;
    v_descomptr            thistrnn.descomptr%type;
    v_count_codhotel       number := 0;
    v_count_codinsts       number := 0;
    v_count_codinst        number := 0;
  begin
    v_codhotel             := hcm_util.get_string(json_thistrnn_obj, 'codhotel');
    v_codinsts             := hcm_util.get_string(json_thistrnn_obj, 'codinsts');
    v_codinst              := hcm_util.get_string(json_thistrnn_obj, 'codinst');
    v_dtetrst              := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtetrst'),'dd/mm/yyyy');
    v_dtetren              := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtetren'),'dd/mm/yyyy');
    v_dtecomexp            := to_date(hcm_util.get_string(json_thistrnn_obj, 'dtecomexp'),'dd/mm/yyyy');
    v_numcert              := hcm_util.get_string(json_thistrnn_obj, 'numcert');
    v_descomptr            := hcm_util.get_string(json_thistrnn_obj, 'descomptr');

    if v_codhotel is not null then
        select count(t.codhotel)
        into   v_count_codhotel
        from thotelif t
        where upper(t.codhotel) = upper(v_codhotel);

        if v_count_codhotel = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'thotelif');
           return;
        end if ;
    end if;
    -------------------------------------------------
    if v_codinsts is not null then
        select count(t.codinsts)
        into   v_count_codinsts
        from tinstitu t
        where upper(t.codinsts) = upper(v_codinsts);

        if v_count_codinsts = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinstitu');
           return;
        end if ;
    end if;
    -------------------------------------------------
    if v_codinst is not null then
        select count(t.codinst)
        into   v_count_codinst
        from tinstruc t
        where upper(t.codinst) = upper(v_codinst);

        if v_count_codinst = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinstitu');
           return;
        end if ;
    end if;
    -------------------------------------------------
    if v_dtetrst > v_dtetren then
       param_msg_error := get_error_msg_php('HR2021',global_v_lang);
           return;
    end if;
    -------------------------------------------------
    if v_dtetrst < sysdate then -- softberry || 2/05/2023 || #9351 || if v_dtetrst > sysdate then 
       param_msg_error := get_error_msg_php('HR1508',global_v_lang);
           return;
    end if;
    -------------------------------------------------
    if v_dtecomexp < v_dtetren then
       param_msg_error := get_error_msg_php('TR0019',global_v_lang);
           return;
    end if;
    -------------------------------------------------
    if v_numcert is not null then
        if v_descomptr is null then
           param_msg_error := get_error_msg_php('HR2045',global_v_lang);
           return;
        end if ;
    end if;
    -------------------------------------------------
end check_validate_save_tab1;
----------------------------------------------------------------------------------------
procedure save_thistrnf (json_thistrnf_obj in json  , param_msg_error out varchar2) is
    json_thistrnf_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thistrnf.codempid%type;
    v_dteyear                 thistrnf.dteyear%type;
    v_codcours                thistrnf.codcours%type;
    v_numclseq                thistrnf.numclseq%type;
    v_numseq                  thistrnf.numseq%type;
    v_filename                thistrnf.filename%type;
    v_descfile                thistrnf.descfile%type;
begin
    json_thistrnf_obj_rows := json_thistrnf_obj ;

    for i in 0..json_thistrnf_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thistrnf_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;
      v_filename        := hcm_util.get_string(json_row, 'filename');
      v_descfile        := hcm_util.get_string(json_row, 'descfile');
      v_numclseq        := hcm_util.get_string(json_row, 'numclseq');
      v_numseq          := hcm_util.get_string(json_row, 'numseq');
      ---------------------------------
      if v_flg = 'delete' then

          delete from thistrnf t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);
          select nvl(max(numseq),0)+1
          into   v_numseq
          from   thistrnf
          where  codempid = v_codempid
             and upper(codcours) = upper(v_codcours)
             and dteyear = v_dteyear
             and numclseq = v_numclseq;
          --------------------------------------
          insert into thistrnf
                 (codempid, codcours, dteyear, numclseq, numseq, filename, descfile, codcreate, dtecreate )
          values
                 (v_codempid, v_codcours, v_dteyear , v_numclseq, v_numseq, v_filename, v_descfile, global_v_coduser, sysdate );
      else
          update thistrnf
          set filename = v_filename,
              descfile = v_descfile,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnf ;
--------------------------------------------------------------------------
procedure save_thistrnb (json_thistrnb_obj in json  , param_msg_error out varchar2) is
    json_thistrnb_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thistrnb.codempid%type;
    v_dteyear                 thistrnb.dteyear%type;
    v_codcours                thistrnb.codcours%type;
    v_numclseq                thistrnb.numclseq%type;
    v_numseq                  thistrnb.numseq%type;
    v_descomment              thistrnb.descomment%type;
begin

    json_thistrnb_obj_rows := json_thistrnb_obj ;

    for i in 0..json_thistrnb_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thistrnb_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;
      v_descomment      := hcm_util.get_string(json_row, 'descomment');
      v_numseq          := hcm_util.get_string(json_row, 'numseq');
      v_numclseq        := hcm_util.get_string(json_row, 'numclseq');

      ---------------------------------
      if v_flg = 'delete' then

          delete from thistrnb t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);

          select nvl(max(numseq),0)+1
          into   v_numseq
          from   thistrnb
          where  codempid = v_codempid
             and upper(codcours) = upper(v_codcours)
             and dteyear = v_dteyear
             and numclseq = v_numclseq;
          --------------------------------------
          insert into thistrnb
                 (codempid, codcours, dteyear, numclseq, numseq, descomment, codcreate, dtecreate )
          values
                 (v_codempid, v_codcours, v_dteyear , v_numclseq, v_numseq, v_descomment, global_v_coduser, sysdate );
      else
          update thistrnb
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;
exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnb ;
--------------------------------------------------------------------------
procedure save_thistrns (json_thistrns_obj in json  , param_msg_error out varchar2) is
    json_thistrns_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thistrns.codempid%type;
    v_dteyear                 thistrns.dteyear%type;
    v_codcours                thistrns.codcours%type;
    v_numclseq                thistrns.numclseq%type;
    v_numseq                  thistrns.numseq%type;
    v_descomment              thistrns.descomment%type;
    begin
    json_thistrns_obj_rows := json_thistrns_obj ;

    for i in 0..json_thistrns_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thistrns_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;
      v_descomment      := hcm_util.get_string(json_row, 'descomment');
      v_numseq          := hcm_util.get_string(json_row, 'numseq');
      v_numclseq        := hcm_util.get_string(json_row, 'numclseq');
      ---------------------------------
      if v_flg = 'delete' then
          delete from thistrns t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);
          select nvl(max(numseq),0)+1
          into   v_numseq
          from   thistrns
          where  codempid = v_codempid
             and upper(codcours) = upper(v_codcours)
             and dteyear = v_dteyear
             and numclseq = v_numclseq;
          --------------------------------------
          insert into thistrns
                 (codempid, codcours, dteyear, numclseq, numseq, descomment, codcreate, dtecreate )
          values
                 (v_codempid, v_codcours, v_dteyear , v_numclseq, v_numseq, v_descomment, global_v_coduser, sysdate );
      else
          update thistrns
          set descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;

exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrns ;
--------------------------------------------------------------------------
procedure save_tknowleg (json_tknowleg_obj in json  , param_msg_error out varchar2) is
    json_tknowleg_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);

    v_dteyear                 tknowleg.dteyear%type;
    v_codempid                tknowleg.codempid%type;
    v_codcours                tknowleg.codcours%type;
    v_numclseq                tknowleg.numclseq%type;
    v_codtparg                tknowleg.codtparg%type;
    v_subject                 tknowleg.subject%type;
    v_details                 tknowleg.details%type;
    v_attfile                 tknowleg.attfile%type;
    v_url                     tknowleg.url%type;
    v_itemno                  tknowleg.itemno%type;
    v_codcompy                tknowleg.codcompy%type;
    begin
    json_tknowleg_obj_rows := json_tknowleg_obj ;

    for i in 0..json_tknowleg_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_tknowleg_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;
      v_codtparg       := '2';
      v_subject        := hcm_util.get_string(json_row, 'subject');
      v_numclseq       := hcm_util.get_string(json_row, 'numclseq');
      v_details        := hcm_util.get_string(json_row, 'details');
      v_attfile        := hcm_util.get_string(json_row, 'attfile');
      v_url            := hcm_util.get_string(json_row, 'url');
      v_itemno         := hcm_util.get_string(json_row, 'itemno');
      v_codcompy       := get_codcompy_by_codempid(p_codempid);
      ---------------------------------
      if v_flg = 'delete' then
          delete from tknowleg t
                 where t.itemno = v_itemno;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);
          select nvl(max(itemno),0)+1
          into   v_itemno
          from   tknowleg;
          --------------------------------------
          insert into tknowleg
                 (
                 dteyear, codempid, codcours, numclseq, codtparg,
                 subject, details, attfile, url, itemno, codcreate, dtecreate, codcompy
                 )
          values
                 (
                 v_dteyear, v_codempid , v_codcours, v_numclseq, v_codtparg,
                 v_subject, v_details, v_attfile, v_url, v_itemno, global_v_coduser, sysdate , v_codcompy
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
end save_tknowleg ;
--------------------------------------------------------------------------
procedure save_thistrnp (json_thistrnp_obj in json  , param_msg_error out varchar2) is
    json_thistrnp_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thistrnp.codempid%type;
    v_dteyear                 thistrnp.dteyear%type;
    v_codcours                thistrnp.codcours%type;
    v_numclseq                thistrnp.numclseq%type;
    v_numseq                  thistrnp.numseq%type;
    v_descplan                thistrnp.descplan%type;
    v_dtestr                  thistrnp.dtestr%type;
    v_dteend                  thistrnp.dteend%type;
    v_descomment              thistrnp.descomment%type;
    begin
    json_thistrnp_obj_rows := json_thistrnp_obj ;

    for i in 0..json_thistrnp_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thistrnp_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;

      v_numseq          := hcm_util.get_string(json_row, 'numseq');
      v_numclseq        := hcm_util.get_string(json_row, 'numclseq');
      v_descplan        := hcm_util.get_string(json_row, 'descplan');
      v_dtestr          := to_date(hcm_util.get_string(json_row, 'dtestr'),'dd/mm/yyyy');
      v_dteend          := to_date(hcm_util.get_string(json_row, 'dteend'),'dd/mm/yyyy');
      v_descomment      := hcm_util.get_string(json_row, 'descomment');
      ---------------------------------
      if v_dteend < v_dtestr then
         param_msg_error := get_error_msg_php('HR2021',global_v_lang);
         return;
      end if;
      if v_flg = 'delete' then
          delete from thistrnp t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq
                       and t.numseq = v_numseq;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);
          select nvl(max(numseq),0)+1
          into   v_numseq
          from   thistrnp
          where  codempid = v_codempid
             and upper(codcours) = upper(v_codcours)
             and dteyear = v_dteyear
             and numclseq = v_numclseq;
          --------------------------------------
          insert into thistrnp
                 (codempid, codcours, dteyear, numclseq, numseq, descplan, dtestr, dteend, descomment, codcreate, dtecreate )
          values
                 (v_codempid, v_codcours, v_dteyear , v_numclseq, v_numseq, v_descplan, v_dtestr, v_dteend, v_descomment, global_v_coduser, sysdate );
      else
          update thistrnp
          set descplan = v_descplan,
              dtestr = v_dtestr,
              dteend = v_dteend,
              descomment = v_descomment,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and numseq = v_numseq;
      end if;
    end loop;

exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thistrnp ;
--------------------------------------------------------------------------
procedure save_thiscost (json_thiscost_obj in json  , param_msg_error out varchar2) is
    json_thiscost_obj_rows    json;
    json_row                  json;
    v_flg                     varchar2(100 char);
    v_codempid                thiscost.codempid%type;
    v_dteyear                 thiscost.dteyear%type;
    v_codcours                thiscost.codcours%type;
    v_numclseq                thiscost.numclseq%type;

    v_codexpn                 thiscost.codexpn%type;
    v_codexpn_old             thiscost.codexpn%type;
    v_typexpn                 thiscost.typexpn%type;
    v_amtcost                 thiscost.amtcost%type;
    v_amttrcost               thiscost.amttrcost%type;
    v_dup                     number:=0;
    begin
    json_thiscost_obj_rows := json_thiscost_obj ;
    for i in 0..json_thiscost_obj_rows.count - 1 loop
      json_row          := hcm_util.get_json(json_thiscost_obj_rows, to_char(i));
      v_flg             := hcm_util.get_string(json_row, 'flg');
      ---------------------------------
      if p_codempid is not null then
        v_codempid := p_codempid ;
      else
        v_codempid := hcm_util.get_string(json_row, 'codempid') ;
      end if;

      if p_year is not null then
        v_dteyear := p_year ;
      else
        v_dteyear := hcm_util.get_string(json_row, 'dteyear') ;
      end if;

      if p_codcours is not null then
        v_codcours := p_codcours ;
      else
        v_codcours := hcm_util.get_string(json_row, 'codcours') ;
      end if;
      v_numclseq        := hcm_util.get_string(json_row, 'numclseq');
      v_codexpn         := hcm_util.get_string(json_row, 'codexpn');
      v_typexpn         := hcm_util.get_string(json_row, 'typexpn');
      v_codexpn_old     := hcm_util.get_string(json_row, 'codexpnOld');
      v_amtcost         := to_number(hcm_util.get_string(json_row, 'amtcost'));
      v_amttrcost       := to_number(hcm_util.get_string(json_row, 'qtypaysend'));
      ---------------------------------
      if v_codexpn is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang);
         return;
      end if;
      if v_typexpn is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang);
         return;
      end if;
      if v_amtcost is null then
         param_msg_error := get_error_msg_php('HR2045',global_v_lang);
         return;
      end if;
      if v_amttrcost > v_amtcost then
         param_msg_error := get_error_msg_php('HR2020',global_v_lang);
         return;
      end if;
      ---------------------------------
      if v_flg = 'delete' then
          delete from thiscost t
                 where t.codempid = v_codempid
                       and upper(t.codcours) = upper(v_codcours)
                       and t.dteyear = v_dteyear
                       and t.numclseq = v_numclseq;
      elsif v_flg = 'add' then
          v_numclseq        := get_numclseq(p_codcours,p_year,p_dtetrst);
          begin
            select distinct count(*)
                   into v_dup
            from thiscost t
            where t.codempid = v_codempid
                  and upper(t.codcours) = upper(v_codcours)
                  and t.dteyear = v_dteyear
                  and t.numclseq = v_numclseq
                  and t.codexpn = v_codexpn;
            exception when no_data_found then
              null;
          end;
          if v_dup > 0 then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'THISCOST');
              return;
          end if;
          insert into thiscost
                 (
                 codempid, codcours, dteyear, numclseq, codexpn, typexpn,
                 amtcost, amttrcost, codcreate, dtecreate, coduser
                 )
          values
                 (
                 v_codempid, v_codcours, v_dteyear , v_numclseq, v_codexpn, v_typexpn,
                 v_amtcost,v_amttrcost, global_v_coduser, sysdate, global_v_coduser
                 );
      else
          if v_codexpn_old = v_codexpn then
             update thiscost
          set codexpn = v_codexpn,
              typexpn = v_typexpn,
              amtcost = v_amtcost,
              amttrcost = v_amttrcost,
              dteupd = sysdate,
              coduser = global_v_coduser
          where codempid = v_codempid
                and upper(codcours) = upper(v_codcours)
                and dteyear = v_dteyear
                and numclseq = v_numclseq
                and codexpn = v_codexpn;

          else
              begin
                select distinct count(*)
                       into v_dup
                from thiscost t
                where t.codempid = v_codempid
                      and upper(t.codcours) = upper(v_codcours)
                      and t.dteyear = v_dteyear
                      and t.numclseq = v_numclseq
                      and t.codexpn = v_codexpn;
                exception when no_data_found then
                  null;
              end;
            if v_dup > 0 then
                param_msg_error := get_error_msg_php('HR2005',global_v_lang,'THISCOST');
                return;
            end if;
              update thiscost
            set codexpn = v_codexpn,
                typexpn = v_typexpn,
                amtcost = v_amtcost,
                amttrcost = v_amttrcost,
                dteupd = sysdate,
                coduser = global_v_coduser
            where codempid = v_codempid
                  and upper(codcours) = upper(v_codcours)
                  and dteyear = v_dteyear
                  and numclseq = v_numclseq
                  and codexpn = v_codexpn_old;
          end if;
      end if;
    end loop;

exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
end save_thiscost ;
--------------------------------------------------------------------------
function get_numclseq(p_codcours in varchar2,p_year in varchar2,p_dtetrst in date) return number IS
    v_numclseq    number := 0;

   begin
    begin
      select t.numclseq
             into v_numclseq
      from  thistrnn t
      where t.codempid = p_codempid ----
      and   t.dteyear = p_year
      and   t.codcours = p_codcours
      and   t.dtetrst = p_dtetrst
      and   t.codtparg = '2'
      and   rownum = 1; ----

      exception when no_data_found then
       begin
          select t.numclseq ----
          into  v_numclseq
          from  tyrtrsch t
          where t.dteyear = p_year
          and   t.codcompy = get_codcompy_by_codempid(p_codempid)
          and   t.codcours = p_codcours
          and   t.dtetrst = p_dtetrst
          and   t.codtparg = '2'
          and   rownum = 1; ----
        exception when no_data_found then
          begin
            select nvl(max(t.numclseq),0)+1
             into v_numclseq
              from thistrnn t
              where upper(t.codcours) = upper(p_codcours)
                    and t.dteyear = p_year
                    and t.codtparg = '2';
          exception when no_data_found then
            null;
          end;
        end;
        /*----
        select nvl(max(t.numclseq),0)+1
             into v_numclseq
        from thistrnn t
        where upper(t.codcours) = upper(p_codcours)
              and t.dteyear = p_year
              and t.codtparg = '2';*/
      end;

  return  v_numclseq ;
END;
--------------------------------------------------------------------------
function get_codcomp_by_codempid(p_codempid in varchar2) return varchar2 IS
    v_codcomp    varchar2(40 char);

   begin
    begin
      select t.codcomp
             into v_codcomp
      from temploy1 t
      where t.codempid = p_codempid;

      exception when no_data_found then
        v_codcomp := null;
      end;

  return  v_codcomp ;
END;
--------------------------------------------------------------------------
function get_codpos_by_codempid(p_codempid in varchar2) return varchar2 IS
    v_codpos    varchar2(4 char);

   begin
    begin
      select t.codpos
             into v_codpos
      from temploy1 t
      where t.codempid = p_codempid;

      exception when no_data_found then
        v_codpos := null;
      end;

  return  v_codpos ;
END;
--------------------------------------------------------------------------
function get_costcent_by_codcomp(v_codcomp in varchar2) return varchar2 IS
    v_costcent    varchar2(40 char);

   begin
    begin
      select costcent into v_costcent
      from tcenter
      where codcomp = v_codcomp;

      exception when no_data_found then
        v_costcent := null;
      end;

  return  v_costcent ;
END;
--------------------------------------------------------------------------
function get_codcompy_by_codempid(p_codempid in varchar2) return varchar2 IS
    v_codcompy    varchar2(4 char);
    v_codcomp     varchar2(40 char);

   begin
   v_codcomp     := get_codcomp_by_codempid(p_codempid);
    begin
      select t.codcompy into v_codcompy
      from tcenter t
      where t.codcomp = v_codcomp;

      exception when no_data_found then
        v_codcompy := null;
      end;

  return  v_codcompy ;
END;
--------------------------------------------------------------------------
  procedure get_descommt_by_codcours(json_str_input in clob, json_str_output out clob) as
    obj_data               json;
    v_descommt             tcourse.descommt%type;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
        select t.descommt
        into   v_descommt
        from tcourse t
        where t.codcours = p_codcours ;
    end if;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('descommt', v_descommt);
    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_descommt_by_codcours;
----------------------------------------------------------------------------------------
procedure delete_index (json_str_input in clob, json_str_output out clob) is
    json_row            json;
    v_flg               varchar2(100 char);
    v_codcours          thistrnn.codcours%type;
    v_codempid          thistrnn.codempid%type;
    v_dteyear           thistrnn.dteyear%type;
    v_numclseq          thistrnn.numclseq%type;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      for i in 0..json_params.count - 1 loop
        json_row          := hcm_util.get_json(json_params, to_char(i));
        v_flg             := hcm_util.get_string(json_row, 'flg');
        v_codcours        := hcm_util.get_string(json_row, 'codcours');
        v_codempid        := hcm_util.get_string(json_row, 'codempid');
        v_dteyear         := hcm_util.get_string(json_row, 'dteyear');
        v_numclseq        := hcm_util.get_string(json_row, 'numclseq');

        if v_flg = 'delete' then
           begin
                 delete from thistrnn
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thistrnb
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thistrns
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thistrnp
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thiscost
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from tknowleg
                 where codcours = v_codcours
                       and codempid = v_codempid
                       and dteyear = v_dteyear
                       and numclseq = v_numclseq;

                 delete from thistrnf
                 where codcours = v_codcours
                       and codempid = v_codempid
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

end HRTR7AE;

/

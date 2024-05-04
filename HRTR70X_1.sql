--------------------------------------------------------
--  DDL for Package Body HRTR70X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR70X" is
-- last update: 14/02/2021 20:30
 procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj            := json(json_str_input);

    global_v_coduser    := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang       := json_ext.get_string(json_obj,'p_lang');

    p_codempid          := hcm_util.get_string(json_obj,'p_codempid_query');
    p_dtetrst           := to_date(json_ext.get_string(json_obj,'p_dtetrst'),'ddmmyyyy');
    p_dtetren           := to_date(json_ext.get_string(json_obj,'p_dtetren'),'ddmmyyyy');
    p_dteyear           := hcm_util.get_string(json_obj,'p_dteyear');
    p_codcours          := hcm_util.get_string(json_obj,'p_codcours');
    p_numclseq          := hcm_util.get_string(json_obj,'p_numclseq');

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
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_index;
----------------------------------------------------------------------------------------
  procedure check_index as
    v_codempid_count           temploy1.codempid%type;
    v_flgsecu                  boolean := false;
  begin
    if p_codempid is not null then

        select count(t.codempid)
        into   v_codempid_count
        from temploy1 t
        where t.codempid = p_codempid;

        if v_codempid_count = 0 then
           param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
           return;
        end if ;

        v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if not v_flgsecu  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
        end if;

        if p_dtetrst > p_dtetren  then
            param_msg_error := get_error_msg_php('HR2021', global_v_lang);
            return;
        end if;

    end if;

  end check_index;
----------------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;
    v_flgsecu                         boolean := false;
    v_flgfound                        boolean := false;

    cursor c_thistrnn_1 is
            select
            t.codempid,t.dtetrst, t.dtetren, t.codcours, t.codinsts, t.dteyear, t.numclseq,
            get_tcourse_name(t.codcours,global_v_lang) as desc_codcours,
            get_tinstitu_name(t.codinsts,global_v_lang) as desc_codinsts,
            (
                select sum(c.amttrcost) from thiscost c
                where c.codempid = t.codempid
                  and c.dteyear = t.dteyear
                  and upper(c.codcours) = upper(t.codcours)
                  and c.numclseq = t.numclseq
            ) as amttrexp
      from thistrnn t
      where t.codtparg = '2'
      and t.codempid = p_codempid
      and (
          (t.dtetrst between p_dtetrst and p_dtetren) OR (t.dtetren between p_dtetrst and p_dtetren)OR
          (p_dtetrst between t.dtetrst  and t.dtetren) OR (p_dtetren between  t.dtetrst  and t.dtetren )
      )
      order by t.dtetrst,t.codcours;

      cursor c_thistrnn_2 is
            select
            t.codempid,t.dtetrst, t.dtetren, t.codcours, t.codinsts, t.dteyear, t.numclseq,
            get_tcourse_name(t.codcours,global_v_lang) as desc_codcours,
            get_tinstitu_name(t.codinsts,global_v_lang) as desc_codinsts,
            (
                select sum(c.amttrcost) from thiscost c
                where c.codempid = t.codempid
                  and c.dteyear = t.dteyear
                  and upper(c.codcours) = upper(t.codcours)
                  and c.numclseq = t.numclseq
            ) as amttrexp
      from thistrnn t
      where t.codtparg = '2'
      and t.codempid = p_codempid
      order by t.dtetrst,t.codcours;

  begin
    obj_row         := json();
    v_rcnt          := 0;
    if p_dtetrst is not null then
      for r_thistrnn in c_thistrnn_1 loop
        v_flgfound    := true;
        v_flgsecu     := secur_main.secur2(r_thistrnn.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if v_flgsecu then
          v_rcnt      := v_rcnt+1;
          obj_data    := json();

          obj_data.put('coderror', '200');
          obj_data.put('codcours', r_thistrnn.codcours);
          obj_data.put('desc_codcours', r_thistrnn.desc_codcours);
          obj_data.put('desc_codinsts', r_thistrnn.desc_codinsts);
          obj_data.put('dtetrst', to_char(r_thistrnn.dtetrst, 'dd/mm/yyyy'));
          obj_data.put('dtetren', to_char(r_thistrnn.dtetren, 'dd/mm/yyyy'));
          obj_data.put('amttrexp', r_thistrnn.amttrexp);
          obj_data.put('dteyear', r_thistrnn.dteyear);
          obj_data.put('numclseq', r_thistrnn.numclseq);
          obj_data.put('codempid', p_codempid);

          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    else
      for r_thistrnn in c_thistrnn_2 loop
        v_flgfound    := true;
        v_flgsecu     := secur_main.secur2(r_thistrnn.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if v_flgsecu then
          v_rcnt      := v_rcnt+1;
          obj_data    := json();

          obj_data.put('coderror', '200');
          obj_data.put('codcours', r_thistrnn.codcours);
          obj_data.put('desc_codcours', r_thistrnn.desc_codcours);
          obj_data.put('desc_codinsts', r_thistrnn.desc_codinsts);
          obj_data.put('dtetrst', to_char(r_thistrnn.dtetrst, 'dd/mm/yyyy'));
          obj_data.put('dtetren', to_char(r_thistrnn.dtetren, 'dd/mm/yyyy'));
          obj_data.put('amttrexp', r_thistrnn.amttrexp);
          obj_data.put('dteyear', r_thistrnn.dteyear);
          obj_data.put('numclseq', r_thistrnn.numclseq);
          obj_data.put('codempid', p_codempid);

          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    end if;
    if v_flgfound then
      if v_rcnt > 0 then
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
      else
        param_msg_error   := get_error_msg_php('HR3007', global_v_lang, 'TUSRPROF');
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'THISTRNN');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index;
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
    v_dtetrst              thistrnn.dtetrst%type;
    v_codtparg             thistrnn.codtparg%type;
    v_dtetren              thistrnn.dtetren%type;
    v_codhotel             thistrnn.codhotel%type;
    v_codinsts             thistrnn.codinsts%type;
    v_amtcost              thistrnn.amtcost%type;
    v_numcert              thistrnn.numcert%type;
    v_dtecert              thistrnn.dtecert%type;
    v_descomptr            thistrnn.descomptr%type;
    v_flgtrain             thistrnn.flgtrain%type;
    v_desc_codtparg        varchar2(50 char);
    v_desc_codinsts        tinstitu.naminste%type;
    v_desc_codinst         varchar2(1000 char);
    v_desc_codhotel        thotelif.namhotee%type;
    v_qtytrmin             thistrnn.qtytrmin%type;
    v_desc_flgtrain        varchar2(50 char);
    v_content              thistrnn.content%type;
    v_flg_img              varchar2(1 char) := 'N';
    v_emp_image            varchar2(1000 char);
  begin
    begin
      select
      t.codtparg,
      get_tlistval_name('TCODTPARG',t.codtparg,global_v_lang) as desc_codtparg,
      t.codinsts,
      get_tinstitu_name(t.codinsts,global_v_lang) as desc_codinsts,
      decode(   t.codinst,
                NULL, decode (
                                global_v_lang, '101', t.naminse,
                                '102', t.naminst,
                                '103', t.namins3,
                                '104', t.namins4,
                                '105', t.namins5,
                                t.naminse
                             ),
                get_tinstruc_name(t.codinst,global_v_lang)
             ) AS desc_codinst,
       t.codhotel,
       get_thotelif_name(t.codhotel,global_v_lang) as desc_codhotel,
       t.dtetrst, t.dtetren, t.qtytrmin,
       (
             select sum(c.amtcost)
             from thistrnn c
             where c.dteyear = t.dteyear
                   and upper(c.codcours) = upper(t.codcours)
                   and c.numclseq = t.numclseq
       ) as amtcost,
       t.numcert, t.dtecert, t.descomptr, t.flgtrain,
       decode(t.flgtrain,'Y',get_label_name('HRTR70X2',global_v_lang,'430'),get_label_name('HRTR70X2',global_v_lang,'440')) AS desc_flgtrain,
       t.content
    into v_codtparg, v_desc_codtparg, v_codinsts, v_desc_codinsts, v_desc_codinst, v_codhotel, v_desc_codhotel,
         v_dtetrst, v_dtetren, v_qtytrmin, v_amtcost, v_numcert, v_dtecert, v_descomptr, v_flgtrain,
         v_desc_flgtrain, v_content
    from thistrnn t
    where t.codempid = p_codempid
        and t.dteyear = p_dteyear
        and upper(t.codcours) = upper(p_codcours)
        and t.numclseq = p_numclseq;

    exception when no_data_found then
        null;
    end;
    obj_data          := json();
    obj_data.put('coderror', '200');
    obj_data.put('codtparg', v_codtparg);
    obj_data.put('desc_codtparg', v_desc_codtparg);
    obj_data.put('dtetrst', nvl( to_char(v_dtetrst, 'dd/mm/yyyy'),''));
    obj_data.put('dtetren', nvl( to_char(v_dtetren, 'dd/mm/yyyy'),''));
    obj_data.put('codinsts', v_codhotel);
    obj_data.put('desc_codinsts', v_desc_codinsts);
    obj_data.put('desc_codinst', v_desc_codinst);
    obj_data.put('codhotel', v_codhotel);
    obj_data.put('desc_codhotel', v_desc_codhotel);
    obj_data.put('qtytrmin', v_qtytrmin);
    obj_data.put('dtecert', nvl( to_char(v_dtecert, 'dd/mm/yyyy'),''));
    obj_data.put('amtcost', v_amtcost);
    obj_data.put('numcert', v_numcert);
    obj_data.put('descomptr', v_descomptr);
    obj_data.put('flgtrain', v_flgtrain);
    obj_data.put('desc_flgtrain', v_desc_flgtrain);
    obj_data.put('content', v_content);
    obj_data.put('desc_codcours', get_tcourse_name(p_codcours,global_v_lang));
    obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));

    v_emp_image                   := get_emp_img(p_codempid);
    if v_emp_image is not null and v_emp_image <> p_codempid then
      v_emp_image   := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_emp_image;
      v_flg_img     := 'Y';
    end if;
    obj_data.put('img_codempid', v_emp_image);
    obj_data.put('flg_img', v_flg_img);

    if isInsertReport then
      insert_ttemprpt_thistrnn(obj_data);
    end if;
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
    cursor c_thistrnf is
      select t.filename, t.descfile, t.numclseq ,t.numseq
      from thistrnf t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_dteyear
            and t.numclseq = p_numclseq
      order by t.numseq;

  begin
    obj_row     := json();
    for r_thistrnf in c_thistrnf loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('descfile', r_thistrnf.descfile);
        obj_data.put('filename', r_thistrnf.filename);
        obj_data.put('path_filename', '/file_uploads/'||get_tfolderd('HRTR7AE')||'/'||r_thistrnf.filename);--#3219
--      obj_data.put('path_filename', r_thistrnf.filename);
        obj_data.put('url', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRTR7AE')||'/'||r_thistrnf.filename);
        obj_data.put('path_link', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRTR7AE')||'/'||r_thistrnf.filename);

        obj_row.put(to_char(v_rcnt-1),obj_data);

        if isInsertReport then
          insert_ttemprpt_thistrnf(obj_data);
        end if;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_thistrnf;
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
    v_desc_codexpn tcodexpn.descode%type;
    cursor c_thiscost is
      select t.codexpn,
             get_tlistval_name('TYPEXPN', t.typexpn, global_v_lang) as desc_typexpn,
             t.typexpn,t.amtcost,t.amttrcost
      from thiscost t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_dteyear
            and t.numclseq = p_numclseq;

  begin
    obj_row     := json();
    for r_thiscost in c_thiscost loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        begin select decode(global_v_lang, '101', descode,
                                         '102', descodt,
                                         '103', descod3,
                                         '104', descod4,
                                         '105', descod5)
              into v_desc_codexpn
              from tcodexpn
              where codexpn = r_thiscost.codexpn;
        exception when no_data_found then
              v_desc_codexpn := null;
        end;

        obj_data.put('coderror', '200');

        obj_data.put('codexpn', r_thiscost.codexpn);
        obj_data.put('desc_codexpn', v_desc_codexpn);
        obj_data.put('desc_typexpn', r_thiscost.desc_typexpn);
        obj_data.put('amtcost', r_thiscost.amtcost);
        obj_data.put('amttrcost', r_thiscost.amttrcost);
        obj_row.put(to_char(v_rcnt-1),obj_data);

        if isInsertReport then
          insert_ttemprpt_thiscost(obj_data);
        end if;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_thiscost;
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
            and t.dteyear = p_dteyear
            and t.numclseq = p_numclseq
      order by t.numseq;

  begin
    obj_row     := json();
    for r_thistrnb in c_thistrnb loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');
        obj_data.put('descomment', r_thistrnb.descomment);
        obj_row.put(to_char(v_rcnt-1),obj_data);

        if isInsertReport then
          insert_ttemprpt_thistrnb(obj_data);
        end if;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_thistrnb;
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
    obj_data                           json;
    obj_row                            json;
    v_rcnt                             number := 0;
    cursor c_tknowleg is
      select t.subject,t.details,t.attfile,t.url,t.itemno
      from tknowleg t
      where t.codempid = p_codempid
            and upper(t.codcours) = upper(p_codcours)
            and t.dteyear = p_dteyear
            and t.numclseq = p_numclseq
            and t.codtparg = '2'
            and t.codcompy = get_codcompy_by_codempid(p_codempid)
      order by t.itemno;

  begin
    obj_row     := json();
    for r_tknowleg in c_tknowleg loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json();

        obj_data.put('coderror', '200');

        obj_data.put('subject', r_tknowleg.subject);
        obj_data.put('attfile', r_tknowleg.attfile);
        obj_data.put('url', r_tknowleg.url);
        obj_data.put('itemno', r_tknowleg.itemno);
       -- obj_data.put('path_filename', r_tknowleg.attfile);
        obj_data.put('path_filename', '/file_uploads/'||get_tfolderd('HRTR7AE')||'/'||r_tknowleg.attfile);--#3219
        obj_data.put('path_link', r_tknowleg.url);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        if isInsertReport then
          insert_ttemprpt_tknowleg(obj_data);
        end if;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_tknowleg;
----------------------------------------------------------------------------------------
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
            and t.dteyear = p_dteyear
            and t.numclseq = p_numclseq;

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
        obj_row.put(to_char(v_rcnt-1),obj_data);
        if isInsertReport then
          insert_ttemprpt_thistrnp(obj_data);
        end if;
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end gen_thistrnp;
----------------------------------------------------------------------------------------
procedure initial_report(json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');
    p_codapp            := hcm_util.get_string(json_obj,'p_codapp');

    begin
      json_select_arr   := json(json_obj.get('p_params_select'));
      if json_select_arr.count = 0 then
        json_select_arr := null;
      end if;
    exception when others then
      null;
    end;
  end initial_report;
----------------------------------------------------------------------------------------
procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output                     clob;
    p_select_arr                    json;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_select_arr.count-1 loop
        p_select_arr        := hcm_util.get_json(json_select_arr, to_char(i));
        p_codempid          := hcm_util.get_string(p_select_arr, 'codempid');
        p_dteyear           := hcm_util.get_string(p_select_arr, 'dteyear');
        p_codcours          := hcm_util.get_string(p_select_arr, 'codcours');
        p_numclseq          := hcm_util.get_string(p_select_arr, 'numclseq');

        gen_thistrnn(json_output);
        gen_thistrnf(json_output);
        gen_thiscost(json_output);
        gen_thistrnb(json_output);
        gen_tknowleg(json_output);
        gen_thistrnp(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;
----------------------------------------------------------------------------------------
procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp) like upper(p_codapp) || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thistrnn(obj_data in json) is
    v_numseq               number := 0;
    v_dtetrst              varchar2(1000 char);
    v_codtparg             thistrnn.codtparg%type;
    v_dtetren              varchar2(1000 char);
    v_codhotel             thistrnn.codhotel%type;
    v_codinsts             thistrnn.codinsts%type;
    v_amtcost              thistrnn.amtcost%type;
    v_numcert              thistrnn.numcert%type;
    v_dtecert              varchar2(1000 char);
    v_descomptr            thistrnn.descomptr%type;
    v_flgtrain             thistrnn.flgtrain%type;
    v_desc_codtparg        varchar2(1000 char);
    v_desc_codinsts        tinstitu.naminste%type;
    v_desc_codinst         varchar2(1000 char);
    v_desc_codhotel        thotelif.namhotee%type;
    v_qtytrmin             thistrnn.qtytrmin%type;
    v_desc_flgtrain        varchar2(1000 char);
    v_content              thistrnn.content%type;
    v_desc_codcours        varchar2(1000 char);
    v_desc_codempid        varchar2(1000 char);
    v_img_codempid         varchar2(1000 char);
    v_flg_img              varchar2(2 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_MAIN';
    exception when no_data_found then
      null;
    end;
    v_numseq                     := v_numseq + 1;
    v_codtparg                   := hcm_util.get_string(obj_data, 'codtparg');
    v_desc_codtparg              := hcm_util.get_string(obj_data, 'desc_codtparg');
    v_dtetrst                    := hcm_util.get_string(obj_data, 'dtetrst');
    v_dtetren                    := hcm_util.get_string(obj_data, 'dtetren');
    v_codinsts                   := hcm_util.get_string(obj_data, 'codinsts');
    v_desc_codinsts              := hcm_util.get_string(obj_data, 'desc_codinsts');
    v_desc_codinst               := hcm_util.get_string(obj_data, 'desc_codinst');
    v_codhotel                   := hcm_util.get_string(obj_data, 'codhotel');
    v_desc_codhotel              := hcm_util.get_string(obj_data, 'desc_codhotel');
    v_qtytrmin                   := hcm_util.get_string(obj_data, 'qtytrmin');
    v_dtecert                    := hcm_util.get_string(obj_data, 'dtecert');
    v_amtcost                    := hcm_util.get_string(obj_data, 'amtcost');
    v_numcert                    := hcm_util.get_string(obj_data, 'numcert');
    v_descomptr                  := hcm_util.get_string(obj_data, 'descomptr');
    v_flgtrain                   := hcm_util.get_string(obj_data, 'flgtrain');
    v_desc_flgtrain              := hcm_util.get_string(obj_data, 'desc_flgtrain');
    v_content                    := hcm_util.get_string(obj_data, 'content');
    v_desc_codcours              := hcm_util.get_string(obj_data, 'desc_codcours');
    v_desc_codempid              := hcm_util.get_string(obj_data, 'desc_codempid');
    v_img_codempid               := hcm_util.get_string(obj_data, 'img_codempid');
    v_flg_img                    := hcm_util.get_string(obj_data, 'flg_img');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq, item1,
             item2, item3, item4, item5, item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15, item16, item17, item18, item19, item20,
             item21, item22, item23, item24, item25, item26, item27
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_MAIN', v_numseq, '1',
             p_codempid,
             upper(p_codcours),
             p_dteyear,
             p_numclseq,
             v_codtparg,
             v_desc_codtparg,
             hcm_util.get_date_buddhist_era(TO_DATE(v_dtetrst, 'dd/mm/yyyy')),
             hcm_util.get_date_buddhist_era(TO_DATE(v_dtetren, 'dd/mm/yyyy')),
             v_codinsts,
             v_desc_codinsts,
             v_desc_codinst,
             v_codhotel,
             v_desc_codhotel,
             v_qtytrmin,
             hcm_util.get_date_buddhist_era(TO_DATE(v_dtecert, 'dd/mm/yyyy')),
             trim(TO_CHAR(v_amtcost,'999,999,999,999.99')),
             v_numcert,
             v_descomptr,
             v_flgtrain,
             v_desc_flgtrain,
             v_content,
             v_desc_codcours,
             v_desc_codempid,
             v_img_codempid,
             v_flg_img,
             get_ref_year(global_v_lang,'0',p_dteyear)
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
end insert_ttemprpt_thistrnn;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thistrnf(obj_data in json) is
    v_numseq            number := 0;
    v_seq               number := 1;
    v_descfile          thistrnf.descfile%type;
    v_filename          thistrnf.filename%type;
    v_path_filename     thistrnf.filename%type;
    v_url               varchar2(1000 char);
    v_path_link         varchar2(1000 char);
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB_1';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB_1'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_dteyear
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;
    v_descfile                  := hcm_util.get_string(obj_data, 'descfile');
    v_filename                  := hcm_util.get_string(obj_data, 'filename');
    v_path_filename             := hcm_util.get_string(obj_data, 'path_filename');
    v_url                       := hcm_util.get_string(obj_data, 'url');
    v_path_link                 := hcm_util.get_string(obj_data, 'path_link');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB_1', v_numseq,
             v_seq, p_codempid, p_codcours, p_dteyear, p_numclseq,
             v_descfile, v_filename, v_path_filename, v_url, v_path_link
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnf;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thiscost(obj_data in json) is
    v_numseq              number := 0;
    v_seq                 number := 1;
    v_codexpn             thiscost.codexpn%type;
    v_desc_codexpn        varchar2(1000 char);
    v_desc_typexpn        varchar2(1000 char);
    v_amtcost             varchar2(1000 char);
    v_amttrcost           varchar2(1000 char);
--    v_amtcost             thiscost.amtcost%type;
--    v_amttrcost           thiscost.amttrcost%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB_2';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB_2'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_dteyear
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;
    v_codexpn                   := hcm_util.get_string(obj_data, 'codexpn');
    v_desc_codexpn              := hcm_util.get_string(obj_data, 'desc_codexpn');
    v_desc_typexpn              := hcm_util.get_string(obj_data, 'desc_typexpn');
    v_amtcost                   := nvl(to_char(hcm_util.get_string(obj_data, 'amtcost'), 'fm999,999,990.00'), ' ');
    v_amttrcost                 := nvl(to_char(hcm_util.get_string(obj_data, 'amttrcost'), 'fm999,999,990.00'), ' ');
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB_2', v_numseq, v_seq,
             p_codempid,
             p_codcours,
             p_dteyear,
             p_numclseq,
             v_codexpn,
             v_desc_codexpn,
             v_desc_typexpn,
             v_amtcost,
             v_amttrcost
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thiscost;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thistrnb(obj_data in json) is
    v_numseq              number := 0;
    v_seq                 number := 1;
    v_descomment          thistrnb.descomment%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB_3';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB_3'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_dteyear
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;
    v_descomment                := hcm_util.get_string(obj_data, 'descomment');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1,
             item2, item3, item4, item5,item6
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB_3', v_numseq, v_seq,
             p_codempid,
             p_codcours,
             p_dteyear,
             p_numclseq,
             v_descomment
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnb;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_tknowleg(obj_data in json) is
    v_numseq              number := 0;
    v_seq                 number := 1;
    v_subject             tknowleg.subject%type;
    v_attfile             tknowleg.attfile%type;
    v_url                 tknowleg.url%type;
    v_itemno              tknowleg.itemno%type;
    v_path_filename       varchar2(2000 char);
    v_path_link           tknowleg.url%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB_4';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB_4'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_dteyear
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;
    v_subject                   := hcm_util.get_string(obj_data, 'subject');
    v_attfile                   := hcm_util.get_string(obj_data, 'attfile');
    v_url                       := hcm_util.get_string(obj_data, 'url');
    v_itemno                    := hcm_util.get_string(obj_data, 'itemno');
    v_path_filename             := hcm_util.get_string(obj_data, 'path_filename');
    v_path_link                 := hcm_util.get_string(obj_data, 'path_link');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1,
             item2, item3, item4, item5,item6, item7, item8, item9, item10, item11
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB_4', v_numseq, v_seq,
             p_codempid,
             p_codcours,
             p_dteyear,
             p_numclseq,
             v_subject,
             v_attfile,
             v_url,
             v_itemno,
             v_path_filename,
             v_path_link
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_tknowleg;
----------------------------------------------------------------------------------------
procedure insert_ttemprpt_thistrnp(obj_data in json) is
    v_numseq              number := 0;
    v_seq                 number := 1;
    v_descplan            thistrnp.descplan%type;
    v_dtestr              varchar2(1000 char);
    v_dteend              varchar2(1000 char);
    v_descomment          thistrnp.descomment%type;
  begin
    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and upper(codapp)   = upper(p_codapp)||'_SUB_5';
    exception when no_data_found then
      null;
    end;

    begin
      select nvl(max(item1), 0)
        into v_seq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = upper(p_codapp)||'_SUB_5'
         and item2 = p_codempid
         and item3 = p_codcours
         and item4 = p_dteyear
         and item5 = p_numclseq;
    exception when no_data_found then
      null;
    end;
    v_numseq                    := v_numseq + 1;
    v_seq                       := v_seq + 1;
    v_descplan                  := hcm_util.get_string(obj_data, 'descplan');
    v_dtestr                    := hcm_util.get_string(obj_data, 'dtestr');
    v_dteend                    := hcm_util.get_string(obj_data, 'dteend');
    v_descomment                := hcm_util.get_string(obj_data, 'descomment');

    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,item1,
             item2, item3, item4, item5,item6, item7, item8, item9
           )
      values
           (
             global_v_codempid, upper(p_codapp)||'_SUB_5', v_numseq, v_seq,
             p_codempid,
             p_codcours,
             p_dteyear,
             p_numclseq,
             v_descplan,
             hcm_util.get_date_buddhist_era(TO_DATE(v_dtestr, 'dd/mm/yyyy')),
             hcm_util.get_date_buddhist_era(TO_DATE(v_dteend, 'dd/mm/yyyy')),
             v_descomment
           );
    exception when others then
      null;
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt_thistrnp;
----------------------------------------------------------------------------------------

end HRTR70X;

/

--------------------------------------------------------
--  DDL for Package Body HRTR66X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR66X" is
-- last update: 19/01/2021 15:30
 procedure initial_value(json_str_input in clob) as
    json_obj json;
  begin
    json_obj            := json(json_str_input);

    global_v_coduser    := json_ext.get_string(json_obj,'p_coduser');
    global_v_lang       := json_ext.get_string(json_obj,'p_lang');

    p_year              := hcm_util.get_string(json_obj,'p_year');
    p_codcomp_query     := hcm_util.get_string(json_obj,'p_codcomp_query');
    p_month             := hcm_util.get_string(json_obj,'p_month');

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
    v_flgsecu                  boolean := false;
    v_count_codcomp            number := 0;
  begin
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp_query is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    else
        select count(t.codcomp)
        into   v_count_codcomp
        from tcenter t
        where upper(t.codcomp) like upper(p_codcomp_query)||'%';

        if v_count_codcomp = 0 then
           param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
           return;
        end if ;
        v_flgsecu := secur_main.secur7(p_codcomp_query,global_v_coduser);
        if not v_flgsecu then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcomp');
          return;
        end if;
    end if;
    if p_month is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
end check_index;
----------------------------------------------------------------------------------------
procedure gen_index(json_str_output out clob) as
    obj_data                          json;
    obj_row                           json;
    v_rcnt                            number := 0;
    v_flgsecu                         boolean := false;
    v_flgfound                        boolean := false;
    p_codcomp                         temploy1.codcomp%type;
    p_codpos                          temploy1.codpos%type;
    v_codehead                        temphead.codempidh%type;

    cursor c_thistrnn is
            select
            t.codempid,t.codcomp,t.codpos,
            get_temploy_name(t.codempid,global_v_lang) as desc_codempid,
            t.codcours,
            get_tcourse_name(t.codcours,global_v_lang) as desc_codcours,
            t.numclseq,
            t.dtetrst, t.dtetren,t.dtetrflw,
            get_tlistval_name('TCODTPARG',t.codtparg,global_v_lang) as codtparg
      from thistrnn t
      where to_number(to_char(t.dtetrflw, 'mm')) = p_month
            and to_number(to_char(t.dtetrflw, 'yyyy')) = p_year
            and upper(t.codcomp)  like upper(p_codcomp_query)||'%'
      order by t.codcours,t.dteyear,t.dtetrst,t.numclseq;

  begin
    obj_row     := json();
    v_rcnt              := 0;
    for r_thistrnn in c_thistrnn loop
        v_flgfound  := true;
        v_flgsecu   := secur_main.secur2(r_thistrnn.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
        if v_flgsecu then
          v_rcnt      := v_rcnt+1;
          obj_data    := json();
          p_codcomp   := r_thistrnn.codcomp;
          p_codpos    := r_thistrnn.codpos;
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(r_thistrnn.codempid));
          obj_data.put('codempid', r_thistrnn.codempid);
          obj_data.put('desc_codempid', r_thistrnn.desc_codempid);
          obj_data.put('codcours', r_thistrnn.codcours);
          obj_data.put('desc_codcours', r_thistrnn.desc_codcours);
          obj_data.put('numclseq', r_thistrnn.numclseq);
          obj_data.put('dtetrst', to_char(r_thistrnn.dtetrst, 'dd/mm/yyyy'));
          obj_data.put('dtetren', to_char(r_thistrnn.dtetren, 'dd/mm/yyyy'));
          obj_data.put('dtetrflw', to_char(r_thistrnn.dtetrflw, 'dd/mm/yyyy'));
          obj_data.put('codtparg', r_thistrnn.codtparg);
          obj_data.put('dteyear', p_year);
          v_codehead := get_head(r_thistrnn.codempid, p_codcomp, p_codpos);
          obj_data.put('desc_codempidh', get_temploy_name(v_codehead,global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;


    end loop;
    if v_flgfound then
      if v_rcnt > 0 then
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
      else
        param_msg_error   := get_error_msg_php('HR3007', global_v_lang, 'tusrprof');
        json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'thistrnn');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;

exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
end gen_index;
----------------------------------------------------------------------------------------
function get_head(p_codempid in varchar2, p_codcomp in varchar2, p_codpos in varchar2) return varchar2 IS
    v_exist         varchar2(1 char);
    v_codehead      temphead.codempidh%type;
    v_codempidh   temphead.codempidh%type := ''; --from temphead, temphead
    v_codcomph    temphead.codcomph%type := '';
    v_codposh     temphead.codposh%type := '';

    cursor c_tempheadl is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
            decode(codempidh,'%',2,1) sorting
        from temphead
       where codempid = p_codempid
    order by sorting,numseq;

    cursor c_temphead2 is
      select  replace(codempidh,'%',null) codempidh,
              replace(codcomph,'%',null) codcomph,
              replace(codposh,'%',null) codposh,
               decode(codempidh,'%',2,1) sorting
        from temphead
       where codcomp = p_codcomp
        and  codpos = p_codpos
   order by  sorting,numseq;

    begin
    ----- set codcomph----
    v_exist := 'N' ;
    for j in c_tempheadl loop
      v_exist  := 'Y'; -- adisak added 22/08/2022
      if j.codempidh  is not null then
        v_codempidh := j.codempidh ;
      else
        v_codcomph  := j.codcomph ;
        v_codposh   := j.codposh ;
      end if;
      exit;
    end loop;

    if v_exist = 'N' then
      for j in c_temphead2 loop
        v_exist  := 'Y' ;
        if j.codempidh  is not null then
          v_codempidh := j.codempidh ;
        else
          v_codcomph  := j.codcomph ;
          v_codposh   := j.codposh ;
        end if;
        exit;
      end loop;
    end if;    
    --

    if v_codcomph is not null then
      begin
        select codempid into v_codempidh
          from temploy1
         where codcomp  = v_codcomph
           and codpos   = v_codposh
           and staemp   in  ('1','3')
           and rownum   = 1;
      exception when no_data_found then
            begin
              select codempid
                into v_codempidh
                from tsecpos
               where codcomp  = v_codcomph
                 and codpos	  = v_codposh
                 and dteeffec <= sysdate
                 and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                 and rownum   = 1;
            exception when no_data_found then
              v_codempidh := null;
            end;
      end;
    end if;    
    v_codehead := v_codempidh;
    return  v_codehead ;
end;
----------------------------------------------------------------------------------------
procedure get_pos(p_codempid in varchar2, p_codcomp out varchar2, p_codpos out varchar2) is

    v_codcomp             temploy1.codcomp%type;
    v_codpos              temploy1.codpos%type;

  begin
    begin
      select t.codcomp, t.codpos
        into v_codcomp, v_codpos
      from temploy1 t
      where t.codempid = p_codempid;

      exception when no_data_found then
        null;
      end;
    p_codcomp      := v_codcomp;
    p_codpos       := v_codpos;
  end;
----------------------------------------------------------------------------------------
procedure send_email(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
  if param_msg_error is null then
    mailing(json_str_output);
  else
    json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    return;
  end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end send_email;
----------------------------------------------------------------------------------------
procedure mailing(json_str_output out clob) as
    p_codcomp                           temploy1.codcomp%type;
    p_codpos                            temploy1.codpos%type;
    v_msg_to                            clob ;
    v_template_to                       clob ;
    v_func_appr                         varchar2(255);
    v_numseq                            number ;
    v_message                           clob ;
    v_excel_file_name                   varchar2(255 char) ;
    v_item                              varchar2(255 char) ;
    v_label                             varchar2(255 char) ;
    v_subject                           varchar2(1000 char) ;
    v_tempfile                          varchar2(255 char) ;
    v_error                             varchar2(4000) ;
    v_mail_lang                         varchar2(10);
    v_numseq_superv                     number := 0;
    v_codapp                            varchar2(30);
    -------------------------------------------
    type text is table of varchar2(1000) index by binary_integer;
    a_label text;
    -------------------------------------------
    v_seq   number ;
    cursor c_thistrnn_superv is
        select distinct mt1.superv_codempid, mt2.email
          from ( select get_head(t.codempid, t.codcomp, t.codpos) as superv_codempid
                   from thistrnn t
                  where to_number(to_char(t.dtetrflw, 'mm')) = p_month
                    and to_number(to_char(t.dtetrflw, 'yyyy')) = p_year
                    and upper(t.codcomp)  like upper(p_codcomp_query)||'%' ) mt1, temploy1 mt2
         where mt1.superv_codempid = mt2.codempid ;
    -------------------------------------------
    cursor c_thistrnn (v_superv_codempid in varchar2) is
        select mt.*
          from ( select t.codempid codempid,
                        get_temploy_name(t.codempid,v_mail_lang) as desc_codempid,
                        t.codcours,
                        get_tcourse_name(t.codcours,v_mail_lang) as desc_codcours,
                        t.numclseq,
                        t.dtetrst, t.dtetren,t.dtetrflw,t.dteyear,
                        get_tlistval_name('TCODTPARG',t.codtparg,v_mail_lang) as codtparg ,
                        get_head(t.codempid, t.codcomp, t.codpos) as superv_codempid
                   from thistrnn t
                  where to_number(to_char(t.dtetrflw, 'mm')) = p_month
                    and to_number(to_char(t.dtetrflw, 'yyyy')) = p_year
                    and upper(t.codcomp) like upper(p_codcomp_query)||'%' ) mt
         where mt.superv_codempid = v_superv_codempid
      order by mt.codcours,mt.dteyear,mt.dtetrst,mt.numclseq;

begin
    ----------------------------------------------------------
    for a in 1..8 loop
        a_label(a) := null;
    end loop;

    for r_thistrnn_superv in c_thistrnn_superv loop
        v_numseq_superv := v_numseq_superv + 1;
        v_codapp        := 'HRTR66XMA'/*||v_numseq_superv*/;
        begin
          select decode(lower(maillang),'en','101','th','102',maillang)
            into v_mail_lang
            from temploy1
           where codempid = r_thistrnn_superv.superv_codempid;
        exception when no_data_found then v_mail_lang := '101';
        end;
        if v_mail_lang not in ('101','102','103','104','105') or v_mail_lang is null then
          v_mail_lang  := '101';
        end if;

        a_label(1)  := get_label_name('HRTR66XEXC',v_mail_lang,1010);
        a_label(2)  := get_label_name('HRTR66XEXC',v_mail_lang,1011);
        a_label(3)  := get_label_name('HRTR66XEXC',v_mail_lang,1012);
        a_label(4)  := get_label_name('HRTR66XEXC',v_mail_lang,1013);
        a_label(5)  := get_label_name('HRTR66XEXC',v_mail_lang,1014);
        a_label(6)  := get_label_name('HRTR66XEXC',v_mail_lang,1015);
        a_label(7)  := get_label_name('HRTR66XEXC',v_mail_lang,1016);
        a_label(8)  := get_label_name('HRTR66XEXC',v_mail_lang,1017);

        ----------------------------------------------------------
        delete ttempprm where codempid = global_v_coduser and codapp = v_codapp;
        insert into ttempprm (codempid,codapp,namrep,pdate,ppage,label1,label2,label3,label4,label5,label6,label7,label8)
        values (global_v_coduser ,v_codapp,'subject',to_char(sysdate,'dd/mm/yyyy'),'Page No :',a_label(1),a_label(2),a_label(3),a_label(4),a_label(5),a_label(6),a_label(7),a_label(8));

        ----------------------------------------------------------
        delete ttemprpt where codempid = global_v_coduser and codapp = v_codapp;
        v_numseq := 0 ;

        begin
            select decode(v_mail_lang,101,descode,102,descodt,103,descod3,104,descod4,105,descod5,descode)
              into v_subject
              from tfrmmail 
             where codform = 'HRTR66X1';
        exception when no_data_found then
            v_subject := get_label_name('HRTR66XEXC',v_mail_lang,1000);
        end;

        chk_flowmail.get_message_result('HRTR66X1', v_mail_lang, v_msg_to, v_template_to);
        -------------------------------------------------
        for r_thistrnn in c_thistrnn (r_thistrnn_superv.superv_codempid) loop
            v_numseq := v_numseq + 1;
            insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7,item8)
            values(global_v_coduser,v_codapp,v_numseq,r_thistrnn.codempid,r_thistrnn.desc_codempid,r_thistrnn.codcours,r_thistrnn.desc_codcours,
                   r_thistrnn.numclseq, hcm_util.get_date_buddhist_era(r_thistrnn.dtetrst), hcm_util.get_date_buddhist_era(r_thistrnn.dtetren), hcm_util.get_date_buddhist_era(r_thistrnn.dtetrflw) );
        end loop ;
        commit;
        -------------------------------------------------
        v_excel_file_name   := r_thistrnn_superv.superv_codempid || '_' || to_char(sysdate,'hh24miss');
        v_item              := ' item1,item2,item3,item4,item5,item6,item7,item8 ' ;
        v_label             := ' label1,label2,label3,label4,label5,label6,label7,label8 ' ;
        excel_mail(v_item,v_label,null,global_v_coduser,v_codapp,v_excel_file_name);
        v_message           := replace(v_template_to,'[P_MESSAGE]', replace(replace(v_msg_to,chr(10),'<br>'),' ','&nbsp;'));
        v_message           := replace(v_message,'[P_OTHERMSG]', '') ;--v_msg_assign);
        v_message           := replace(v_message,'[PARA_FROM]', null);
        v_message           := replace(v_message,'[PARAM-TO]',get_temploy_name(r_thistrnn_superv.superv_codempid,v_mail_lang));
        v_message           := replace(v_message,'<PARAM1>', r_thistrnn_superv.superv_codempid||' '||get_temploy_name(r_thistrnn_superv.superv_codempid,v_mail_lang));
        v_message           := replace(v_message,'<PARAM2>', v_subject);
        v_message           := replace(v_message,'[PARAM-LINK]', '<a href="'||get_tsetup_value('PATHMOBILE')||'"><b>APPROVE</b></a>');
        v_message           := replace(v_message,'([PARA_POSITION])', null);
        v_message           := replace(v_message,'[PARA_POSITION]', null);
        v_message           := replace(v_message,'&nbsp;', ' ');
        v_tempfile          := get_tsetup_value('PATHEXCEL')||v_excel_file_name||'.xls';
        begin
            v_error         := SendMail_AttachFile(get_tsetup_value('MAILEMAIL'),r_thistrnn_superv.email,v_subject,v_message,v_excel_file_name,null,null,null,null,r_thistrnn_superv.superv_codempid,'HRTR6CE','Oracle');
        exception when others then
            json_str_output     := get_response_message('200', 'HR7522'||' '||get_errorm_name('HR7522',global_v_lang), global_v_lang); return;
            return;
        end;
    end loop ;
    ----------------------------------------------------------
    if param_msg_error is null then
        json_str_output     := get_response_message('200', 'HR2046'||' '||get_errorm_name('HR2046',global_v_lang), global_v_lang); return;
    end if;
exception when others then
    param_msg_error         := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    json_str_output         := get_response_message('400', param_msg_error, global_v_lang);
end mailing;
----------------------------------------------------------------------------------------

end HRTR66X;

/

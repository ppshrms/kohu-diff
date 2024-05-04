--------------------------------------------------------
--  DDL for Package Body AUTO_SENDMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AUTO_SENDMAIL" is
-- last update: 24/02/2021 18:01

  procedure set_column_label(p_codform      in varchar2) is
    cursor c1 is
      select decode(p_lang_mail, '101', descripe
                               , '102', descript
                               , '103', descrip3
                               , '104', descrip4
                               , '105', descrip5) as desc_label,
             b.codtable,b.ffield,b.flgdesc
        from tfrmmail a,tfrmmailp b
       where a.codform   = p_codform
         and a.codform   = b.codform
       order by b.numseq;
    v_index         number;
    v_sum_length    number;
    v_codtable      varchar2(15 char);
    v_codcolmn      varchar2(60 char);
    v_funcdesc      varchar2(200 char);
    v_data_type     varchar2(200 char);
    v_max_col       number;
    type t_array_num is table of number index by binary_integer;
      p_col_length    t_array_num;
  BEGIN

    for x in 1..p_max_column loop
      p_column_label(x)   := null;
    end loop;

    --<< for column numseq
    v_index         := 1;
    p_col_length(1) := 2;
    v_sum_length    := 2;
    -->> for column numseq

    for i in c1 loop
      v_codtable    := i.codtable;
      v_codcolmn    := i.ffield;
      v_index       := v_index + 1;
      exit when v_index > p_max_column;
      begin
        select funcdesc ,data_type into v_funcdesc, v_data_type
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
        v_funcdesc := null;
      end;

      if v_data_type = 'DATE' then
        p_col_length(v_index) := 2;
      elsif v_codcolmn like 'TIM%' then
        p_col_length(v_index) := 2;
      elsif v_data_type = 'NUMBER' or (v_codcolmn like 'COD%' and nvl(i.flgdesc,'N') <> 'Y') then
        p_col_length(v_index) := 3;
      else
        p_col_length(v_index) := 5;
      end if;

      v_sum_length                  := v_sum_length + p_col_length(v_index);
      p_column_label(v_index - 1)   := i.desc_label;
    end loop;
    -- cal width column
    v_max_col     := least(p_max_column,p_col_length.count);
    for n in 1..v_max_col loop
      p_column_width(n)   := to_char(trunc(p_col_length(n)*100/v_sum_length));
    end loop;
  end;
  --
  procedure get_column_value(p_codempid     in temploy1.codempid%type,
                             p_rowid        in varchar2,
                             p_codform      in varchar2) is
    v_codtable    varchar2(15 char);
    v_codcolmn    varchar2(60 char);
    v_funcdesc    varchar2(200 char);
    v_flgchksal   varchar2(1 char);
    v_statmt      clob;
    v_value       varchar2(500 char);
    v_data_type   varchar2(200 char);

    v_codempid_req    temploy1.codempid%type;
    v_col_index   number;

    cursor c1 is
      select b.fparam,b.ffield,
             b.codtable,c.fwhere,
             'select '||b.ffield||' from '||b.codtable||' where '||c.fwhere as stm ,flgdesc
          from tfrmmail a,tfrmmailp b,tfrmtab c
          where a.codform   = p_codform
            and a.codform   = b.codform
            and a.typfrm    = c.typfrm
            and b.codtable  = c.codtable
       order by b.numseq;
  BEGIN
    v_col_index   := 0;
    for x in 1..p_max_column loop
      p_column_value(x)   := null;
    end loop;
    for i in c1 loop
      v_codtable    := i.codtable;
      v_codcolmn    := i.ffield;
      v_col_index   := v_col_index + 1;

      begin
        select funcdesc ,flgchksal, data_type into v_funcdesc,v_flgchksal,v_data_type
          from tcoldesc
         where codtable = v_codtable
           and codcolmn = v_codcolmn;
      exception when no_data_found then
        v_funcdesc    := null;
        v_flgchksal   := 'N' ;
      end;

      if nvl(i.flgdesc,'N') = 'N' then
        v_funcdesc := null;
      end if;

      if v_flgchksal = 'Y' then
        v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'NUMBER' and i.ffield not in ('NUMSEQ','SEQNO') then
        v_statmt  := 'select to_char('||i.ffield||',''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_funcdesc is not null and i.flgdesc = 'Y' then
        v_funcdesc := replace(v_funcdesc,'P_CODE',i.ffield) ;
        v_funcdesc := replace(v_funcdesc,'P_LANG',p_lang_mail) ;
        v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
        v_funcdesc := replace(v_funcdesc,'P_TEXT',global_v_chken) ;
        v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'DATE' then
        v_statmt  := 'select to_char('||i.ffield||',''dd/mm/yyyy'') from '||i.codtable ||' where  '||i.fwhere ;
      else
        v_statmt  := i.stm ;
      end if;

      v_statmt    := replace(v_statmt,'[#CODEMPID]',p_codempid);
      v_statmt    := replace(v_statmt,'[#ROWID]',p_rowid);

      v_value   := execute_desc(v_statmt) ;
      if i.ffield like 'TIM%' then
        if v_value is not null then
          declare
            v_chk_length    number;
          begin
            select  char_length
            into    v_chk_length
            from    user_tab_columns
            where   table_name    = i.codtable
            and     column_name   = i.ffield;
            if v_chk_length = 4 then
              v_value   := substr(lpad(v_value,4,'0'),1,2)||':'||substr(lpad(v_value,4,'0'),-2,2);
            end if;
          exception when no_data_found then
            null;
          end;
        else
          v_value := ' ';
        end if;
      end if;

      if v_flgchksal = 'Y' then
        v_value   := null ;
      end if;
      if (i.ffield like 'TIM%') or (i.ffield like 'COD%' and nvl(i.flgdesc,'N') <> 'Y') or (v_data_type = 'DATE') or (i.ffield in ('NUMSEQ','SEQNO')) then
        p_text_align(v_col_index)   := 'center';
      elsif v_data_type = 'NUMBER' then
        p_text_align(v_col_index)   := 'right';
      else
        p_text_align(v_col_index)   := 'left';
      end if;
      p_column_value(v_col_index)  := v_value;
    end loop;
  end;
  --
  procedure get_codform(p_codapp varchar2,p_msg_to out varchar2,p_msg_cc out varchar2) is
  begin
    begin
      select  codfrmto,codfrmcc
      into    p_msg_to,p_msg_cc
      from    twkflpf
      where   codapp  = p_codapp;
    exception when no_data_found then
      p_msg_to    := null;
      p_msg_cc    := null;
    end;
  end;
  --
  function gen_data_mail(p_codempid_temp varchar2, p_codapp_temp varchar2, p_codappr varchar2, p_codapp varchar2,p_codfrm_to varchar2,p_codfrm_cc varchar2, p_subject varchar2, p_loop_no number) return varchar2 is
    v_data_table     clob;
    v_data_list      clob;
    v_chkmax         varchar2(1 char);
    v_bgcolor        varchar2(20 char);
    v_msg_to         clob;
    v_msg_cc         clob;
    v_msg            clob;
    v_msg1           clob;
    v_template_to    clob;
    v_template_cc    clob;
    v_template       clob;
    v_func_appr      varchar2(20 char);
    v_codfrm         tfrmmail.codform%type;
    v_subject        varchar2(1000 char);
    v_max_col        number := 0;
    v_num            number := 0;
    v_email          varchar2(100 char);
    v_error          varchar2(4000 char);
    v_limit_row      number := 50;
    v_count_row      number;
    v_count_round    number;

    cursor c1 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = p_codempid_temp
         and codapp   = p_codapp_temp
         and item8    = p_codappr
         and rownum   <= v_limit_row
    order by item8,item3,item2,item4;
  begin
    p_zyear     := pdk.check_year(p_lang_mail);
    chk_workflow.get_message(p_codapp,null,p_lang_mail,v_msg_to,v_msg_cc,v_template_to,v_template_cc,v_func_appr);
    if p_loop_no = 1 then
      v_msg1        := v_msg_to;
      v_template    := v_template_to;
      v_codfrm      := p_codfrm_to;
    elsif p_loop_no = 2 then
      v_msg1        := v_msg_cc;
      v_template    := v_template_cc;
      v_codfrm      := p_codfrm_cc;
    else
      v_msg1        := v_msg_to;
      v_template    := v_template_to;
      v_codfrm      := p_codfrm_to;
    end if;
    v_subject := p_subject;
    if p_loop_no = 3 then
      v_subject := p_subject||'('||get_label_name('ESS',p_lang_mail,10)||')';
    end if;
    v_msg      := v_msg1;

    -- Start set column label name
    set_column_label(v_codfrm);
    v_max_col  := least(p_max_column,p_column_width.count - 1);

    -- ## LOOP DATA START ## --
    -- check count for sendmail
    begin
        select count(*) 
          into v_count_row
          from ttemprpt2
         where codempid = p_codempid_temp
           and codapp   = p_codapp_temp
           and item8    = p_codappr;
    exception when others then
        v_count_row := 0;
    end;
    
    v_count_round := ceil(v_count_row/v_limit_row);
    
    for round in 1..v_count_round loop
        -- TABLE HEADER
        v_data_table := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
        v_data_table := v_data_table||'<tr class="TextBody" bgcolor="#006699">
                             <td width="'||p_column_width(1)||'%"  height="20" align="center"><font color="#FFFFFF">'||get_label_name('ESS', p_lang_mail, 20)||'</font></td>';
        for x in 1..v_max_col loop
          v_data_table  := v_data_table||'<td width="'||p_column_width(x + 1)||'%" align="center"><font color="#FFFFFF">'||p_column_label(x)||'</font></td>';
        end loop;
        v_data_table  := v_data_table||'</tr>';
    
        -- TABLE BODY
        v_num      := 0;
        v_chkmax   := 'N';
        v_data_list := ''; -- LIST CONTENT
        for j in c1 loop
          /*if v_num >= p_nummax then
            v_chkmax   := 'Y';
          end if;*/
          v_num  := v_num + 1 ;
          if mod(v_num,2) = 1 then
            v_bgcolor := '"#EFF4F8"' ;
          else
            v_bgcolor := '"#FFFFFF"' ;
          end if;
          if v_chkmax = 'N' then
            get_column_value(j.codempid,j.row_id,v_codfrm);
            v_data_table  := v_data_table||'<tr class="TextBody"  bgcolor='||v_bgcolor||'>
                                 <td height="15" align="center">'||v_num||'</td>';
            v_data_list := v_data_list||'<div>';  -- LIST CONTENT
            for x in 1..v_max_col loop
              v_data_table  := v_data_table||'<td align="'||p_text_align(x)||'">'||p_column_value(x)||'</td>';
              v_data_list   := v_data_list||'<div>'||p_column_label(x)||': '||p_column_value(x)||'</div>';  -- LIST CONTENT
            end loop;
            v_data_table  := v_data_table||'</tr>';
            v_data_list := v_data_list||'</div>';  -- LIST CONTENT
          end if;  --v_chkmax
        end loop;--for j in c3 loop
        v_data_table     := v_data_table||'</table>';
        -- ## LOOP DATA END ## --
    
        /*if v_chkmax = 'Y' then
          v_data_table := null;
          replace_text(p_codapp,p_loop_no,v_num,v_msg);
        end if;*/
    
        begin
          select email
            into v_email
            from temploy1
           where codempid = p_codappr;
        exception when no_data_found then null;
        end;
    
        replace_text_app(v_msg,v_template,p_loop_no,v_func_appr,p_codappr,v_email,v_data_table,v_data_list,get_tsetup_value('MAILEMAIL'),v_subject);
    
        begin
          v_error := send_mail(v_email,v_msg,p_codappr,v_func_appr);
        exception when others then
          rollback;
          insert_ttemprpt('AUTOSENDMAIL',nvl(v_func_appr,'AUTOSENDMAIL'),dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace,'email = '||v_email,'codappr = '||p_codappr,'length of message = '||length(v_msg),to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
          v_error := '7522';
          return v_error;
        end;
    end loop; -- for round in 1..v_count_round loop
    return v_error;
  end;
  --
  procedure hrms33u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES32E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);
    v_typchg         varchar2(20 char);

    type typ_ is table of varchar2(250 char) index by binary_integer;
      v_type    typ_;

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.typchg,a.routeno,a.approvno,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid as row_id
        from tempch a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and a.typchg   = b.typchg
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N')
    order by a.dtereq,a.codempid,a.numseq,a.typchg;

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,i.typchg,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,i.typchg,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.numseq,i.typchg,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,10);

        v_type(1)   := get_label_name('HRES32EC1',p_lang_mail,60);
        v_type(2)   := get_label_name('HRES32EC1',p_lang_mail,70);
        v_type(3)   := get_label_name('HRES32EC1',p_lang_mail,80);
        v_type(4)   := get_label_name('HRES32EC1',p_lang_mail,90);
        v_type(5)   := get_label_name('HRES32EC1',p_lang_mail,100);
        v_type(6)   := get_label_name('HRES32EC1',p_lang_mail,110);
        v_type(7)   := get_label_name('HRES32ET7',p_lang_mail,10);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            if j.typchg = '1' then
              v_typchg := 'HRES32E1';
            elsif j.typchg = '2' then  -- tab2 data
              v_typchg := 'HRES32E2';
            elsif j.typchg = '3' then  -- education
              v_typchg := 'HRES32E3';
            elsif j.typchg = '4' then  -- children
              v_typchg := 'HRES32E4';
            elsif j.typchg = '5' then  -- honour's
              v_typchg := 'HRES32E5';
            elsif j.typchg = '6' then  -- trainning
              v_typchg := 'HRES32E6';
            elsif j.typchg = '7' then  -- others
              v_typchg := 'HRES32E7';
            end if;

            update tapempch
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and typreq   = v_typchg
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms33u
  --
  procedure hrms63u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES62E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.seqno,a.routeno,a.approvno,a.codleave,a.dtestrt,a.timstrt,a.dteend,a.timend,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid as row_id
        from tleaverq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.seqno    = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,30);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            update taplverq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and seqno    = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop

--    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms63u
  --
  procedure hrms6lu is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES6KE';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dtestrt,a.dteend,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from ttotreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,60);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            update taptotrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms6lu
  --
  procedure hrms6nu is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES6ME';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.seqno,a.routeno,a.approvno,a.codleave,a.dtestrt,a.dteend,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tleavecc a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.seqno    = b.numseq
         and b.codapp   = v_codapp
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,70);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            update taplvecc
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and seqno    = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms6nu
  --
  procedure hrms6bu is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES6AE';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dtework,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from ttimereq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and a.dtework  = b.dtework
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,40);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            update taptimrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and dtework  = to_date(j.dtework,'dd/mm/yyyy')
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hres6bu
  --
  procedure hrms6eu is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES6DE';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.seqno,a.routeno,a.approvno,a.dtework,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tworkreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.seqno    = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.seqno,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,50);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            update tapwrkrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and seqno    = to_number(j.numseq)
               and dtework  = to_date(j.dtework,'dd/mm/yyyy')
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms6eu
  --
  procedure hrms6ju is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES6IE';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.numclseq,a.codcours,a.codtparg,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
                   a.namcourse,a.rowid row_id
        from ttrnreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                                 i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                                    i.row_id,null,null,null,null,
                                    v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
          get_next_approve_R('AUTOTOR',v_codapp_temp,
                             v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                             i.row_id,null,null,null,null,
                             i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,110);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update taptrnrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hres6ju
  --
  procedure hrms72u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES71E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,
     0  amtreq,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tmedreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,120);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapmedrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hres72u
  --
  procedure hrms75u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES74E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,
      --a.amtreq,
      b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tobfreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,130);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapobfrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms75u
  --
  procedure hrms78u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES77E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.codlon,
      --a.amtlonreq,
      b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tloanreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,140);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update taploanrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hres78u
  --
  procedure hrms37u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES36E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid as row_id
        from trefreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,'HRES36E',null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,20);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapempch
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and typreq   = j.typchg
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms37u
  --
  procedure hrms3cu is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES3BE';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtecompl,a.routeno,a.numcomp,a.codcomp,a.typcompl,b.flgsend,b.flgagency,a.dteinput,a.stacompl, --user8 : 20/09/2017 : STA3600466 ||add column dteinput,stacompl
             a.rowid row_id
        from tcompln a,tautomail b
       where a.codempid = b.codempid
         and a.dtecompl = b.dtereq
         and a.numcomp  = to_char(b.numseq)
         and b.codapp   = v_codapp
         and a.stacompl = 'N'
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtecompl,i.numcomp,null,null,0,
                         i.row_id,null,null,null,null);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - i.dteinput)*1440)) >= v_hrtotal and i.stacompl = 'N' then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtecompl,i.numcomp,null,null,0,
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,100);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms3cu
  --
  procedure hrms85u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES81E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dtestrt,a.timstrt,a.dteend,a.timend,a.location,a.amtreq,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from ttravreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,150);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update taptrvrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms85u
  --
  procedure hrms89u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES88E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.codcomp,a.codpos,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tjobreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,160);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapjobrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms89u
  --
  procedure hrms87u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES86E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dteeffec,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
      from tresreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,80);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapresrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms87u
  --
  procedure hrmss3u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRESS2E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.seqno,a.routeno,a.approvno,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tpfmemrq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.seqno    = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.seqno,'HRESS2E',null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.seqno,'HRESS2E',null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.seqno,'HRESS2E',null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,90);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapempch
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and typreq   = 'HRESS2E'
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrmss3u
  --
  procedure hrmss5u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRESS4E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from tircreq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq    = b.numseq
         and b.codapp   = v_codapp
         and a.staappr in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,'HRESS4E',null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,'HRESS4E',null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,'HRESS4E',null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,190);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update tapempch
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and typreq   = 'HRESS4E'
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hress5u
  --
  procedure hrms92u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES91E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dteyear,a.numclseq,a.codcours,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from ttrncerq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.staappr  in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,170);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update taptrcerq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms92u
  --
  procedure hrms94u is
    v_codappr        varchar2(100 char);
    v_error          varchar2(10 char);
    v_codapp         varchar2(20 char) := 'HRES93E';
    v_codapp_temp    varchar2(30 char) := v_codapp||to_char(sysdate,'ddmmyyyyhh24miss');
    v_codempid_temp  varchar2(30 char);
    v_codfrm_to      tfrmmail.codform%type;
    v_codfrm_cc      tfrmmail.codform%type;
    v_typecc         varchar2(1 char);
    v_codempap       varchar2(30 char);
    v_codcompap      varchar2(40 char);
    v_codposap       varchar2(20 char);
    v_hrtotal        number := 0;
    v_subject        varchar2(4000 char);

    cursor c1 is
      select a.codempid,a.dtereq,a.numseq,a.routeno,a.approvno,a.dteyear,a.numclseq,a.codcours,b.flgsend,b.flgagency,a.dteapph,a.dteinput, --user8 : 21/09/2017 : STA3600466 ||add column dteapph,dteinput
             a.rowid row_id
        from ttrncanrq a,tautomail b
       where a.codempid = b.codempid
         and a.dtereq   = b.dtereq
         and a.numseq   = b.numseq
         and b.codapp   = v_codapp
         and a.stappr  in ('P','A')
         and(nvl(b.flgsend,'N')   = 'N'
          or nvl(b.flgagency,'N') = 'N');

    cursor c2 is
      select distinct item8 as codappr
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
    order by item8;

    cursor c3 is
      select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
             item8 as codempap,item9 as codcompap,item10 as codposap,
             item11 as row_id,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5
        from ttemprpt2
       where codempid = v_codempid_temp
         and codapp   = v_codapp_temp
         and item8    = v_codappr
    order by item8,item3,item2,item4;

  begin
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
    para_numseq := 0;
    get_codform(v_codapp,v_codfrm_to,v_codfrm_cc);

    for i in c1 loop
      if nvl(i.flgsend,'N') = 'N' then
        get_next_approve('AUTOTO',v_codapp_temp,
                         v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                         i.row_id,null,null,null,null);
        --
        find_cc(i.codempid,i.routeno,i.approvno,v_typecc,v_codempap,v_codcompap,v_codposap);
        get_next_approve_CC('AUTOCC',v_codapp_temp,
                            v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                            i.row_id,null,null,null,null,
                            v_codempap,v_codcompap,v_codposap);
      end if; --nvl(b.flgsend,'N') = 'N'
      --
      if nvl(i.flgagency,'N') = 'N' then
        begin
          select hrtotal into v_hrtotal
          from twkflpf
          where codapp =  v_codapp;
        exception when others then
          v_hrtotal := null;
        end;
        if trunc(((sysdate - nvl(i.dteapph,i.dteinput))*1440)) >= v_hrtotal then
        get_next_approve_R('AUTOTOR',v_codapp_temp,
                           v_codapp,i.codempid,i.dtereq,i.numseq,null,null,nvl(i.approvno,0),
                           i.row_id,null,null,null,null,
                           i.routeno);
        end if;
      end if; --nvl(b.flgagency,'N') = 'N'
    end loop; --for i in c1 loop
    --
    for k in 1..3 loop
      if k = 1 then
        v_codempid_temp := 'AUTOTO';
      elsif k = 2 then
        v_codempid_temp := 'AUTOCC';
      else
        v_codempid_temp := 'AUTOTOR';
      end if;
      for i in c2 loop
        v_codappr  := i.codappr;
        get_emp_mail_lang(v_codappr);

        v_subject := get_label_name('AUTOSENDMAIL',p_lang_mail,180);

        v_error    := gen_data_mail(v_codempid_temp,v_codapp_temp,v_codappr,v_codapp,v_codfrm_to,v_codfrm_cc,v_subject,k);
        if v_error = '7521' then
          for j in c3 loop
             update taptrcanrq
               set dtesnd   = sysdate
             where codempid = j.codempid
               and dtereq   = to_date(j.dtereq,'dd/mm/yyyy')
               and numseq   = to_number(j.numseq)
               and approvno = to_number(j.approvno);

            if k in (1,3) then
              upd_tautomail(v_codapp,j.codempid,to_date(j.dtereq,'dd/mm/yyyy'),to_number(j.numseq),j.typchg,to_date(j.dtework,'dd/mm/yyyy'),k);
            end if;
            commit;
          end loop; --for j in c3 loop
        end if;

      end loop; --for i in c2 loop
    end loop; --for k in 1..2 loop
    delete ttemprpt2 where codapp = v_codapp_temp; commit;
  end;  --hrms94u
  --
  procedure find_cc( p_codempid  in  varchar2,
                     p_routeno   in  varchar2 ,
                     p_approvno  in  number,
                     p_typecc    out varchar2 ,
                     p_codempap  in out varchar2 ,
                     p_codcompap in out varchar2 ,
                     p_codposap  in out varchar2 ) is

  v_exist    varchar2(1 char);
  v_codcomp  tcenter.codcomp%type;
  v_codpos   tpostn.codpos%type;

  cursor c_temphead1 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codempid = p_codempid
    order by codempidh;

  cursor c_temphead2 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from temphead
     where codcomp  = v_codcomp
       and codpos   = v_codpos
    order by codcomph,codposh;
  begin
    begin
      select typecc ,codcompc, codposc ,codempc
        into p_typecc ,p_codcompap, p_codposap ,p_codempap
        from twkflowd
       where routeno  = p_routeno
         and numseq   = nvl(p_approvno,0)+1 ;
    exception when no_data_found then
      p_typecc    := null;
      p_codcompap := null;
      p_codposap  := null;
      p_codempap  := null;
    end ;

    if p_typecc = '1' then  --Head
      v_exist := 'N';
      for j in c_temphead1 loop
        p_codempap  := j.codempidh;
        p_codcompap := j.codcomph;
        p_codposap  := j.codposh;
        v_exist := 'Y';
      end loop;
      if v_exist = 'N' then
        begin
          select codcomp,codpos
            into v_codcomp,v_codpos
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then null;
        end;
        for j in c_temphead2 loop
          p_codempap  := j.codempidh;
          p_codcompap := j.codcomph;
          p_codposap  := j.codposh;
        end loop;
      end if;--v_exist
    elsif p_typecc = '2' then --Head Organize
      p_codempap  := null ;
      if p_approvno = 1 then --Step 1
        begin
          select codcomp,codpos
            into p_codcompap,p_codposap
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then
           p_codcompap := null;
           p_codposap  := null;
        end;
      end if;
/*
      begin
        select codcompr,codposre
          into p_codcompap,p_codposap
          from torgprt
         where codcompp = p_codcompap
           and codpospr = p_codposap
           and flgappr  = 'A'
           and codcompr is not null
           and rownum   = 1;
      exception when no_data_found then
        p_codcompap := null;
        p_codposap  := null;
      end ;
*/
    elsif p_typecc in ('3','4') then -- Department,position ,-- Employee
      null;
    end if;
  end;
  --
  procedure replace_text(p_codapp    in varchar2,
                          p_type     in varchar2,
                          p_totemp   in number,
                          p_msg      out clob) is

    data_file  clob;
    crlf       varchar2(2 char):= chr( 13 ) || chr( 10 );
    v_codform  varchar2(15 char);
    v_msg_to   clob;
    v_msg_cc   clob;

    cursor c1 is
      select codapp,codfrmto,codfrmcc,codappap,dtetotal,hrtotal,dteupd,coduser
        from twkflpf
       where codapp =  p_codapp;
  begin
    for i in c1 loop
      v_msg_to    := i.codfrmto ;
      v_msg_cc    := i.codfrmcc ;
    end loop ;

    if p_type in (1,3) then
      v_codform   := v_msg_to;
    else
      v_codform   := v_msg_cc;
    end if;

    begin
      select decode(p_lang_mail,'101',message4,'102',message5,message4) msg
        into data_file
         from tfrmmail
       where codform = v_codform;
    exception when others then data_file := null;
    end;
    -- Replace Text
    if data_file like ('%<param-01>%') then
      data_file := replace(data_file ,'<param-01>', to_char(p_totemp,'fm999,999,990'));
    end if;
    p_msg := crlf||crlf||data_file;
  end; -- Function Replace Text
  --
  procedure replace_text_app(p_msg        in out clob,
                             p_template   in varchar2,
                             p_mail_type  in varchar2,
                             p_func_appr  in varchar2,
                             p_codappr    in varchar2,
                             p_email      in varchar2,
                             p_data_table in clob,
                             p_data_list  in clob,
                             p_from       in varchar2,
                             p_subject    in varchar2 ) is
    data_file     clob;
    crlf          clob:= chr( 13 ) || chr( 10 );
    v_http        varchar2(100 char);
    v_message     clob;
    v_template    clob;
    v_codform     varchar2(15);
    --
  begin
    begin
      select decode(p_lang_mail,'101',messagee,
                                '102',messaget,
                                '103',message3,
                                '104',message4,
                                '105',message5,messagee) msg
        into v_template
        from tfrmmail
       where codform = 'TEMPLATE';
    exception when others then v_template := '<html><body>[P_MESSAGE]</body></html>';
    end;

    v_http      := get_tsetup_value('PATHMOBILE');
    v_message   := p_msg;
    v_message   := replace_with_clob(replace_with_clob(v_message,chr(10),'<br>'),' ','&nbsp;') ;
    v_message   := replace_with_clob(v_template,'[P_MESSAGE]',v_message);
    v_message   := replace_with_clob(v_message,'&lt;', '<');
    v_message   := replace_with_clob(v_message,'&gt;', '>');

    data_file   := v_message ;
    p_msg       := 'From: ' ||p_from|| crlf ||
                   'To: '||p_email||crlf||
                   'Subject: '||p_subject||crlf||
                   'Content-Type: text/html';

    -- Replace Text
    if data_file like ('%[TABLE]%') then
      data_file  := replace_with_clob(data_file  ,'[TABLE]', p_data_table);
    end if;
    if data_file like ('%[LIST]%') then
      data_file  := replace_with_clob(data_file  ,'[LIST]', p_data_list);
    end if;

    if data_file like ('%[PARAM-LINK]%') then
--      data_file  := replace(data_file  ,'[PARAM-LINK]', '<a href="'||v_http||'"><span style="background: #1155cc;color: #fff;padding: 10px 20px;margin-left: 20px;text-align:center;margin-top:10px;"><b>APPROVE</b></span></a>');
      data_file  := replace_with_clob(data_file  ,'[PARAM-LINK]', '<a href="'||v_http||'"><b>APPROVE</b></a>');
    end if;
    if data_file like ('%[PARAM-TO]%') then
      data_file  := replace_with_clob(data_file  ,'[PARAM-TO]', get_temploy_dear(p_codappr,p_lang_mail));      
      --data_file  := replace(data_file  ,'[PARAM-TO]', get_temploy_name(p_codappr,p_lang_mail));
      
    end if;
    if data_file like ('%[PARAM-SUBJECT]%') then
      data_file  := replace_with_clob(data_file  ,'[PARAM-SUBJECT]', get_tappprof_name(p_func_appr,1,p_lang_mail));
    end if;

    if data_file like ('%<PARAM-LINK>%') then
--      data_file  := replace(data_file  ,'<PARAM-LINK>', '<a href="'||v_http||'"><span style="background: #1155cc;color: #fff;padding: 10px 20px;margin-left: 20px;text-align:center;margin-top:10px;"><b>APPROVE</b></span></a>');
      data_file  := replace_with_clob(data_file  ,'<PARAM-LINK>', '<a href="'||v_http||'"><b>APPROVE</b></a>');
    end if;
    
    if data_file like ('%&lt;PARAM-LINK&gt;%') then
     data_file  := replace_with_clob(data_file  ,'&lt;PARAM-LINK&gt;', '<a href="'||v_http||'"><b>APPROVE</b></a>');
    end if;
    
    if data_file like ('%<PARAM-TO>%') then
      data_file  := replace_with_clob(data_file  ,'<PARAM-TO>', get_temploy_name(p_codappr,p_lang_mail));
    end if;
    if data_file like ('%<PARAM-SUBJECT>%') then
      data_file  := replace_with_clob(data_file  ,'<PARAM-SUBJECT>', get_tappprof_name(p_func_appr,1,p_lang_mail));
    end if;

    p_msg := p_msg||crlf||crlf||data_file;
  end; -- Function Replace Text
  --
  function formattime(ptime varchar2) return varchar2 is
    v_time varchar2(20);
    hh     varchar2(2);
    mm     varchar2(2);
  begin
    v_time := ptime;
    hh     := substr(v_time,1,2);
    mm     := substr(v_time,3,2);
    if(v_time = '') or (v_time is null)then
      return v_time;
    else
      return (hh || ':' || mm);
    end if;
  end;
  --
  procedure get_next_approve(p_codempid_temp in varchar2,
                             p_codapp_temp   in varchar2,
                             p_codapp        in varchar2,
                             p_codempid      in varchar2,
                             p_dtereq         in date,
                             p_numseq        in number,
                             p_typchg        in varchar2,
                             p_dtework        in date,
                             p_approveno     in number,
                             p_detail1       in varchar2,
                             p_detail2       in varchar2,
                             p_detail3       in varchar2,
                             p_detail4       in varchar2,
                             p_detail5       in varchar2) is

  v_codempid    temploy1.codempid%type;
  v_codcomp     tcenter.codcomp%type;
  v_codpos      tpostn.codpos%type;
  v_codempas    temploy1.codempid%type;
  v_codcomas    tcenter.codcomp%type;
  v_codposas    tpostn.codpos%type;

  cursor c1 is
    select codapp,codempid,dtereq,numseq,approvno,seqno,
           replace(codempap,'%') codempap,
           replace(codcompap,'%') codcompap,
           replace(codposap,'%') codposap
      from tempaprq
     where codapp   = p_codapp
       and codempid = p_codempid
       and dtereq   = p_dtereq
        and numseq   = p_numseq
       and approvno = nvl(p_approveno,0)+1
  order by numseq;

  cursor c2 is
    select codempid,codcomp,codpos
      from temploy1
     where((codcomp  = v_codcomp
       and codpos    = v_codpos)
        or(codempid in  (select codempid
                           from tsecpos
                          where codcomp = v_codcomp
                            and codpos  = v_codpos
                            and dteeffec <= sysdate
                            and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) )) )
       and staemp in ('1','3')
  order by codempid ;

  cursor c3 is
    select item1 as codapp,item2 as codempid,item3 as dtereq,item4 as numseq,item5 as typchg,item6 as dtework,item7 as approvno,
           item8 as codempap,item9 as codcompap,item10 as codposap,
           item11 as detail1,item12 as detail2,item13 as detail3,item14 as detail4,item15 as detail5,rowid
      from ttemprpt2
     where codempid = p_codempid_temp
       and codapp   = p_codapp_temp
       and nvl(item21,'N') <> 'Y'
       and nvl(item22,'N') =  'N'
  order by item8;

  cursor c4 is
    select codempas,codcomas,codposas
      from tassignm
     where codempid  = v_codempid
       and codcomp   = v_codcomp
       and codpos    = v_codpos
       and dtestrt  <= sysdate
       and(dteend   >= trunc(sysdate) or dteend is null)
       and flgassign in ('E','P');

  cursor c5 is
    select codempid
      from temploy1
     where codempid <> v_codempid
       and codempid  = nvl(v_codempas,codempid)
       and codcomp   = nvl(v_codcomas,codcomp)
       and codpos    = nvl(v_codposas,codpos)
       and staemp in ('1','3')
    union
    select codempid
      from tsecpos
     where codempid <> v_codempid
       and codempid  = nvl(v_codempas,codempid)
       and codcomp   = nvl(v_codcomas,codcomp)
       and codpos    = nvl(v_codposas,codpos)
       and dteeffec <= sysdate
       and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null);

  begin
    for i in c1 loop
      if i.codempap is not null then
        begin
          select codcomp,codpos
            into v_codcomp,v_codpos
            from temploy1
           where codempid = i.codempap;
        exception when no_data_found then
          v_codcomp := null;
          v_codpos  := null;
        end;
        para_numseq := nvl(para_numseq,0) + 1;
         insert into ttemprpt2(codempid,codapp,numseq,
                               item1,item2,item3,item4,item5,item6,item7,
                               item8,item9,item10,
                               item11,item12,item13,item14,item15)
                       values(p_codempid_temp,p_codapp_temp,para_numseq,
                              p_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_typchg,to_char(p_dtework,'dd/mm/yyyy'),p_approveno,
                              i.codempap,v_codcomp,v_codpos,
                              p_detail1,p_detail2,p_detail3,p_detail4,p_detail5);
     else
        v_codcomp := i.codcompap;
        v_codpos  := i.codposap;
        for j in c2 loop
          para_numseq := nvl(para_numseq,0) + 1;
           insert into ttemprpt2(codempid,codapp,numseq,
                                 item1,item2,item3,item4,item5,item6,item7,
                                 item8,item9,item10,
                                 item11,item12,item13,item14,item15)
                         values(p_codempid_temp,p_codapp_temp,para_numseq,
                                p_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_typchg,to_char(p_dtework,'dd/mm/yyyy'),p_approveno,
                                j.codempid,v_codcomp,v_codpos,
                                p_detail1,p_detail2,p_detail3,p_detail4,p_detail5);
        end loop;
      end if;
    end loop;--for i in c1 loop
    commit;
    --
    for r3 in c3 loop
      v_codempid  := r3.codempap;
      v_codcomp   := r3.codcompap;
      v_codpos    := r3.codposap;
      for r4 in c4 loop
        v_codempas := r4.codempas;
        v_codcomas := r4.codcomas;
        v_codposas := r4.codposas;
        for r5 in c5 loop
          para_numseq := nvl(para_numseq,0) + 1;
          begin
            select codcomp,codpos
              into v_codcomp,v_codpos
              from temploy1
             where codempid = r5.codempid;
          exception when no_data_found then
            v_codcomp := null;
            v_codpos  := null;
          end;

           insert into ttemprpt2(codempid,codapp,numseq,
                                 item1,item2,item3,item4,item5,item6,item7,
                                 item8,item9,item10,
                                 item11,item12,item13,item14,item15,
                                 item22)
                         values(p_codempid_temp,p_codapp_temp,para_numseq,
                                r3.codapp,r3.codempid,r3.dtereq,r3.numseq,r3.typchg,r3.dtework,r3.approvno,
                                r5.codempid,v_codcomp,v_codpos,
                                r3.detail1,r3.detail2,r3.detail3,r3.detail4,r3.detail5,
                                'Y');
        end loop;--c5
      end loop;--c4
      update ttemprpt2
         set item21 = 'Y'
       where rowid  = r3.rowid;
    end loop;--c3
    commit;
  end;
  --
  procedure get_next_approve_CC(p_codempid_temp in varchar2,
                                p_codapp_temp   in varchar2,
                                p_codapp        in varchar2,
                                p_codempid       in varchar2,
                                p_dtereq        in date,
                                p_numseq        in number,
                                p_typchg         in varchar2,
                                 p_dtework       in date,
                                p_approveno     in number,
                                p_detail1       in varchar2,
                                p_detail2       in varchar2,
                                p_detail3       in varchar2,
                                p_detail4       in varchar2,
                                 p_detail5       in varchar2,
                                 p_codempap      in varchar2,
                                 p_codcompap     in varchar2,
                                 p_codposap      in varchar2) is

    v_codcomp      tcenter.codcomp%type;
    v_codpos       tpostn.codpos%type;

  cursor c1 is
    select codempid,codcomp,codpos
      from temploy1
     where((codcomp  = v_codcomp
       and codpos    = v_codpos)
        or(codempid in  (select codempid
                           from tsecpos
                          where codcomp = v_codcomp
                            and codpos  = v_codpos
                            and dteeffec <= sysdate
                            and(nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) )) )
       and staemp in ('1','3')
     order by codempid;

  begin
    if p_codempap is not null then
      para_numseq := nvl(para_numseq,0) + 1;
       insert into ttemprpt2(codempid,codapp,numseq,
                             item1,item2,item3,item4,item5,item6,item7,
                             item8,item9,item10,
                             item11,item12,item13,item14,item15)
                     values(p_codempid_temp,p_codapp_temp,para_numseq,
                            p_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_typchg,to_char(p_dtework,'dd/mm/yyyy'),p_approveno,
                            p_codempap,null,null,
                            p_detail1,p_detail2,p_detail3,p_detail4,p_detail5);
    elsif p_codcompap is not null then
      v_codcomp := p_codcompap;
      v_codpos  := p_codposap;
      for j in c1 loop
        para_numseq := nvl(para_numseq,0) + 1;
         insert into ttemprpt2(codempid,codapp,numseq,
                               item1,item2,item3,item4,item5,item6,item7,
                               item8,item9,item10,
                               item11,item12,item13,item14,item15)
                       values(p_codempid_temp,p_codapp_temp,para_numseq,
                              p_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_typchg,to_char(p_dtework,'dd/mm/yyyy'),p_approveno,
                              j.codempid,null,null,
                              p_detail1,p_detail2,p_detail3,p_detail4,p_detail5);
      end loop;
    end if;
    commit;
  end;
  --
  procedure get_next_approve_R(p_codempid_temp in varchar2,
                               p_codapp_temp   in varchar2,
                               p_codapp        in varchar2,
                               p_codempid      in varchar2,
                               p_dtereq         in date,
                               p_numseq        in number,
                               p_typchg        in varchar2,
                                p_dtework        in date,
                               p_approveno     in number,
                               p_detail1       in varchar2,
                               p_detail2       in varchar2,
                               p_detail3       in varchar2,
                               p_detail4       in varchar2,
                                p_detail5       in varchar2,
                               p_routeno       in varchar2) is

  cursor c1 is
    select codempid
      from twkflowde
     where routeno = p_routeno
       and numseq  = nvl(p_approveno,0)+1
  order by numseq,codempid;

  begin
    for j in c1 loop
      para_numseq := nvl(para_numseq,0) + 1;
       insert into ttemprpt2(codempid,codapp,numseq,
                             item1,item2,item3,item4,item5,item6,item7,
                             item8,item9,item10,
                             item11,item12,item13,item14,item15)
                     values(p_codempid_temp,p_codapp_temp,para_numseq,
                            p_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,p_typchg,to_char(p_dtework,'dd/mm/yyyy'),p_approveno,
                            j.codempid,null,null,
                            p_detail1,p_detail2,p_detail3,p_detail4,p_detail5);
    end loop;
    commit;
  end;
  --
  procedure upd_tautomail(p_codapp varchar2, p_codempid varchar2, p_dtereq date, p_numseq number, p_typchg varchar2, p_dtework date, p_flag number) is
  begin
    if p_flag = 1 then
      update tautomail
         set flgsend   = 'Y'
       where codapp    = p_codapp
         and codempid  = p_codempid
         and dtereq    = p_dtereq
         and numseq    = p_numseq
         and typchg    = nvl(p_typchg,typchg)
         and dtework   = nvl(p_dtework,dtework);
    elsif p_flag = 3 then
      update tautomail
         set flgagency = 'Y'
       where codapp    = p_codapp
         and codempid  = p_codempid
         and dtereq    = p_dtereq
         and numseq    = p_numseq
         and typchg    = nvl(p_typchg,typchg)
         and dtework   = nvl(p_dtework,dtework);
    end if;--p_flag = 1
    commit;
  end;

  procedure get_emp_mail_lang(p_codempid  in  varchar2) is
    v_lang varchar2(3 char);
  begin
    begin
      select decode(lower(maillang),'en','101','th','102',maillang)
        into v_lang
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then v_lang := '101';
    end;
    if v_lang not in ('101','102','103','104','105') or v_lang is null then
      v_lang  := '101';
    end if;
  
    p_lang_mail := v_lang;
  end;

end;

/

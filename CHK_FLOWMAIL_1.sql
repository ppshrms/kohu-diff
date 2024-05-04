--------------------------------------------------------
--  DDL for Package Body CHK_FLOWMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CHK_FLOWMAIL" IS


  procedure set_column_label(p_codform      in varchar2) is
    cursor c1 is
      select decode(p_lang_mail, '101', descripe
                               , '102', descript
                               , '103', descrip3
                               , '104', descrip4
                               , '105', descrip5) as desc_label,
             b.codtable,b.ffield,b.flgdesc
        from tfrmmail a,tfrmmailp b,tfrmtab c
       where a.codform   = p_codform
         and a.codform   = b.codform
         and a.typfrm    = c.typfrm
         and b.codtable  = c.codtable
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
      elsif upper(i.ffield) = 'CODPSWD' then
          v_statmt  := 'select pwddec('||i.ffield||',coduser,'''||global_v_chken||''') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'NUMBER' and i.ffield not in ('NUMSEQ','SEQNO') then
        v_statmt  := 'select to_char('||i.ffield||',''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_funcdesc is not null and i.flgdesc = 'Y' then
        v_funcdesc := replace(v_funcdesc,'P_CODE',i.ffield) ;
        v_funcdesc := replace(v_funcdesc,'P_LANG',p_lang_mail) ;
        v_funcdesc := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
        v_funcdesc := replace(v_funcdesc,'P_TEXT',global_v_chken) ;
        v_statmt  := 'select '||v_funcdesc||' from '||i.codtable ||' where  '||i.fwhere ;
      elsif v_data_type = 'DATE' then
        v_statmt  := 'select hcm_util.get_date_buddhist_era('||i.ffield||') from '||i.codtable ||' where '||i.fwhere ;
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

procedure get_message(p_codapp      in varchar2 ,
                      p_lang        in varchar2,
                      o_msg_to      out clob  ,
                      p_template_to out clob  ,
                      p_func_appr   out varchar2) is
    v_msg_to    long ;
begin
    begin
        select codform,codappap
          into v_msg_to,p_func_appr
          from tfwmailh
         where codapp = upper(p_codapp);
    exception when no_data_found then
      null;
    end;

     if v_msg_to is not null then
        begin
          select decode(p_lang,'101',messagee,
                               '102',messaget,
                               '103',message3,
                               '104',message4,
                               '105',message5,
                               '101',messagee) msg
            into o_msg_to
            from tfrmmail
           where codform = v_msg_to;
        exception when others then
          o_msg_to := null ;
        end ;
     end if;
     if p_func_appr is not null then
         begin
            select decode(p_lang,'101',messagee,
                                 '102',messaget,
                                 '103',message3,
                                 '104',message4,
                                 '105',message5,
                                 '101',messagee) msg
              into p_template_to
              from tfrmmail
--             where codform = 'TEMPLATETO' ;
             where codform = 'TEMPLATE' ;
         exception when others then
            p_template_to := null ;
         end ;
     else
         begin
            select decode(p_lang,'101',messagee,
                                 '102',messaget,
                                 '103',message3,
                                 '104',message4,
                                 '105',message5,
                                 '101',messagee) msg
            into  p_template_to
            from  tfrmmail
            where codform = 'TEMPLATE' ;
--            where codform = 'TEMPLATECC' ;
         exception when others then
            p_template_to := null ;
         end ;
     end if;
end; -- get_message

procedure get_message_reply(p_codapp      in varchar2,
                            p_lang        in varchar2,
                            p_staappr     in varchar2,
                            o_msg_to      out clob,
                            o_template_to out clob) is
    v_msg_to    long ;
    v_codform     tfwmailh.codform%type;
    v_codformno   tfwmailh.codformno%type;
begin
    begin
        select codform,codformno
          into v_codform,v_codformno
          from tfwmailh
         where codapp = upper(p_codapp);
    exception when no_data_found then
      null;
    end;

    if p_staappr = 'N' then
        v_codform   := v_codformno;
    end if;

    if v_codform is not null then
      begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5) msg
        into o_msg_to
        from tfrmmail
        where codform = v_codform ;
      exception when others then
        o_msg_to := null ;
      end ;
      begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
        into  o_template_to
        from  tfrmmail
--        where codform = 'TEMPLATECC' ;
        where codform = 'TEMPLATE' ;
      exception when others then
        o_template_to := null ;
      end ;
    end if;

end; -- get_message_reply

procedure get_message_result(p_codform      in varchar2 ,
                             p_lang        in varchar2,
                             o_msg_to      out clob  ,
                             p_template_to out clob) is
    v_msg_to    long ;
begin
    begin
      select decode(p_lang,'101',messagee,
                           '102',messaget,
                           '103',message3,
                           '104',message4,
                           '105',message5,
                           '101',messagee) msg
        into o_msg_to
        from tfrmmail
       where codform = p_codform ;
    exception when others then
      o_msg_to := null ;
    end ;
    begin
        select decode(p_lang,'101',messagee,
                             '102',messaget,
                             '103',message3,
                             '104',message4,
                             '105',message5,
                             '101',messagee) msg
          into p_template_to
          from tfrmmail
         where codform = 'TEMPLATE' ;
--         where codform = 'TEMPLATECC' ;
    exception when others then
        p_template_to := null ;
    end ;
end; -- get_message

function check_approve (p_codapp   in varchar2,
                        p_codempid in varchar2,
                        p_approvno in out number,--(nvl(a.approvno,0) + 1)
                        p_codappr  in varchar2,
                        p_codcomp  in varchar2, -- from transaction
                        p_codpos   in varchar2, -- from transaction
                        p_check    out varchar2)   --out Y/N/HR2010
                        return boolean is

  v_statment      clob;
  v_syncond       tfwmailc.syncond%type;
  v_numseq        tfwmaile.numseq%type;
  v_qty           number := 0;
  v_codempid      temploy1.codempid%type;
  --
  v_codcomp       temploy1.codcomp%type;
  v_codpos        temploy1.codpos%type;
  v_numlvl        temploy1.numlvl%type;
  v_codempmt      temploy1.codempmt%type;
  v_typemp        temploy1.typemp%type;
  --
  v_max_approv    tfwmaile.seqno%type := 0;

  cursor c_tfwmailc is
      select codapp,numseq,syncond--,statement
        from tfwmailc
       where codapp = p_codapp
    order by numseq;

  cursor c_tfwmaile is
      select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
        from tfwmaile
       where codapp = p_codapp
         and numseq = v_numseq
         and (seqno = p_approvno Or seqno = v_max_approv)
    order by seqno desc;

  cursor c1 is
    select codcomp,codpos
      from (
              select codcomp,codpos
                from temploy1
               where codempid = p_codappr
                 and staemp in ('1','3')
               union
              select codcomp,codpos
                from tsecpos
               where codempid = p_codappr
                 and dteeffec <= sysdate
                 and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
            )
    order by codcomp,codpos;

    begin
      v_codempid := p_codempid;
      v_numseq   := 0;
      if p_codcomp is not null and p_codpos is not null then
        v_codcomp  := p_codcomp;
        v_codpos   := p_codpos;
        begin
           select numlvl, codempmt, typemp
             into v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
      else
        begin
           select codcomp, codpos, numlvl, codempmt, typemp
             into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
      end if;
      --
      for r1 in c_tfwmailc loop
        v_syncond := r1.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',to_char(v_numlvl)) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;

          v_qty := EXECUTE_QTY(v_statment) ;
          if v_qty > 0 then
            v_numseq  := r1.numseq;
            exit ;
          end if;
        end if;
      end loop;  --c_tfwmaild;

      if nvl(v_numseq,0) = 0 then
         p_check  := 'HR2010';   --HR2010 No Data(tfwmailc)
         return false;
      end if;-- if  nvl(v_numseq,0) = 0 then
      --
      p_check  := 'N';
      --

      begin
         select max(seqno)
           into v_max_approv
           from tfwmaile
          where codapp = p_codapp
            and numseq = v_numseq;
      exception when no_data_found then
         v_max_approv := 0 ;
      end ;
      --
      if v_max_approv = p_approvno then
         p_check := 'Y';  --last Approve
      end if;
      --
      for r2 in c_tfwmaile loop
        if r2.flgappr = 'D' then -- D-By Position - Department
          for j in c1 loop
            if j.codcomp = r2.codcompap and j.codpos = r2.codposap then
              p_approvno := r2.seqno;
              if v_max_approv = p_approvno then
                 p_check := 'Y';  --last Approve
              end if;
              return true;
              exit;
            end if;
          end loop;
        elsif r2.flgappr = 'E' then -- E-By Employee
          if p_codappr = r2.codempap then
            p_approvno := r2.seqno;
            if v_max_approv = p_approvno then
                p_check := 'Y';  --last Approve
            end if;
            return true;
            exit;
          end if;
        end if;
      end loop;  --c_tfwmaile
      return false;
    end;
--  procedure get_emp_mail_lang(p_codempid  in  varchar2) is
--    v_lang varchar2(3 char);
--  begin
--    begin
--      select decode(lower(maillang),'en','101','th','102',maillang)
--        into v_lang
--        from temploy1
--       where codempid = p_codempid;
--    exception when no_data_found then v_lang := '101';
--    end;
--    if v_lang not in ('101','102','103','104','105') or v_lang is null then
--      v_lang  := '101';
--    end if;
--
--    p_lang_mail := v_lang;
--  end;

--function get_emp_mail_lang(p_codempid   in varchar2) return varchar2 is -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 28/03/2024 | Fix issue 4449#1746
function get_emp_mail_lang(p_codempid   in varchar2,p_default_lang in varchar2 default '101') return varchar2 is 
    v_lang varchar2(3 char);
begin
    begin
      select decode(lower(maillang),'en','101','th','102',maillang)
        into v_lang
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then v_lang := p_default_lang; -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 28/03/2024 | v_lang := '101'; | Fix issue 4449#1746
    end;
    if v_lang not in ('101','102','103','104','105') or v_lang is null then
      v_lang  := p_default_lang; -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 28/03/2024 | v_lang := '101'; | Fix issue 4449#1746
    end if;
    p_lang_mail := v_lang;
    return v_lang;
end;

function check_codappr (p_codapp   in varchar2,
                        p_codappr  in varchar2 )
                        return boolean is

  v_codcomp       temploy1.codcomp%type;
  v_codpos        temploy1.codpos%type;
  v_numlvl        temploy1.numlvl%type;
  v_codempmt      temploy1.codempmt%type;
  v_typemp        temploy1.typemp%type;

  cursor c_tfwmaile is
      select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
        from tfwmaile
       where codapp = p_codapp
    order by numseq, seqno, approvno;

  cursor c1 is
    select codcomp, codpos
      from (
              select codcomp,codpos
                from temploy1
               where codempid = p_codappr
                 and staemp in  ('1','3')
               union
              select codcomp,codpos
                from tsecpos
               where codempid = p_codappr
                 and dteeffec <= sysdate
                 and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
            )
    order by codcomp, codpos;
begin
    begin
       select codcomp, codpos, numlvl, codempmt, typemp
         into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
         from temploy1
        where codempid = p_codappr;
    exception when no_data_found then
        null;
    end;

  for r2 in c_tfwmaile loop
    if r2.flgappr = 'D' then -- D-By Position - Department
       for j in c1 loop
          if j.codcomp = r2.codcompap and j.codpos = r2.codposap then
            return true;
            exit;
          end if;
       end loop;
    elsif r2.flgappr = 'E' then -- E-By Employee
      if p_codappr = r2.codempap then
        return true;
        exit;
      end if;
    end if;
  end loop;  --c_tfwmaile
  return false;  --HR3008    à¸—à¹ˆà¸²à¸™à¹„à¸¡à¹ˆà¸¡à¸µà¸ªà¸´à¸—à¸˜à¸´à¹Œà¸­à¸™à¸¸à¸¡à¸±à¸•à¸´à¸‚à¹‰à¸­à¸¡à¸¹à¸¥
end;


function send_mail_to_approve (p_codapp    in varchar2 ,
                               p_codempid  in varchar2,
                               p_codrcord  in varchar2,
                               p_msg_to    in clob,
                               p_file      in long,
                               p_subject   in varchar2,
                               p_fromtype  in varchar2,
                               p_staappr   in varchar2,
                               p_lang      in number,
                               p_approvno  in number,
                               p_codcomp   in varchar2,
                               p_codpos    in varchar2,
                               p_attach_mode in varchar2 default null)
                               return varchar2 is

    v_msg               clob := p_msg_to ;
    v_error             varchar2(4000 char) ;
    v_codempid          temploy1.codempid%type ;
    msg_error           varchar2(10 char) := 'aaaa' ;
    v_coduser           varchar2(10 char) ;
    v_temp              varchar2(4000 char) := null;
    v_subject           varchar2(4000 char) := p_subject;
    v_send              number := 0;
    v_codcomp           tcenter.codcomp%type;
    v_codpos            tpostn.codpos%type ;
    v_codcomp2          tcenter.codcomp%type;
    v_codpos2           tpostn.codpos%type ;
    v_codcompap         tcenter.codcomp%type;
    v_codposap          tpostn.codpos%type;
    v_codcomph          tcenter.codcomp%type;
    v_codposh           tpostn.codpos%type;
    v_email             varchar2(100 char);
    v_disperr           varchar2(600 char):='2401';
    v_found             varchar2(4 char);
    v_emailfr           varchar2(100 char);
    v_semail            varchar2(100 char);

    v_numlvl            temploy1.numlvl%type;
    v_codempmt          temploy1.codempmt%type;
    v_typemp            temploy1.typemp%type;
    v_syncond           tfwmailc.syncond%type;
    v_statment          tfwmailc.syncond%type;
    v_numseq            number:=0;
    v_qty               number:=0;

    cursor c_tfwmailc is
    select codapp, numseq, syncond
      from tfwmailc
     where codapp = p_codapp
  order by numseq;

    cursor c_tfwmaile is
    select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
      from tfwmaile
     where codapp = p_codapp
       and numseq = v_numseq
       and seqno  = p_approvno
  order by numseq;

  cursor c1 is
        select codempid
          from (
                  select codempid
                    from temploy1
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and staemp in ('1','3')
                   union
                  select codempid
                    from tsecpos
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and dteeffec <= sysdate
                     and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                )
      order by codempid;
  v_codappap tfwmailh.codappap%type;
begin
    begin
        select codappap
          into v_codappap
          from tfwmailh
         where codapp = p_codapp;
    exception when no_data_found then
        v_codappap := null;
    end;

    v_codempid := p_codempid;
    if p_codcomp is not null and p_codpos is not null then
        v_codcomp  := p_codcomp;
        v_codpos   := p_codpos;
        begin
           select numlvl, codempmt, typemp
             into v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    else
        begin
           select codcomp, codpos, numlvl, codempmt, typemp
             into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    end if;

    begin
        select email
          into v_emailfr
          from temploy1
         where codempid = p_codrcord;
    exception when no_data_found then
        v_emailfr := null;
    end;

    begin
        select email
          into v_semail
          from temploy1
         where codempid = v_codempid
           and staemp in ('1','3')
           and email is not null;
    exception when no_data_found then
        v_semail := v_emailfr;
    end ;

    for r1 in c_tfwmailc loop
        v_syncond := r1.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;
          v_qty := EXECUTE_QTY(v_statment) ;
          if v_qty > 0 then
            v_numseq := r1.numseq;
            exit ;
          end if;
        end if;
    end loop;  --c_tfwmailc;
    -- attach file
    v_temp := null;
    if p_file is not null then
        v_temp := p_file;
    end if;
    for r2 in c_tfwmaile loop
         v_msg  := p_msg_to ;
         v_send := v_send + 1;
         if r2.flgappr = 'D' then
            v_codcompap := r2.codcompap;
            v_codposap  := r2.codposap;
            for r3 in c1 loop
                v_msg := p_msg_to ;
                begin
                    select coduser
                      into v_coduser
                      from tusrprof
                     where codempid = r3.codempid
                       and rownum = 1;
                exception when no_data_found then
                    v_coduser := null;
                end ;

                begin
                    select email
                      into v_email
                      from temploy1
                     where codempid = r3.codempid
                       and staemp in ('1','3')
                       and email is not null;
                exception when no_data_found then
                    v_email := null;
                end ;
                if p_codempid = r3.codempid and p_fromtype = 'U' then
                    null;
                else
                    if v_email is not null then
                        v_msg   := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                        v_msg   := replace(v_msg ,'[P_CODUSER]',v_coduser);
                        v_msg   := replace(v_msg ,'[P_LANG]',p_lang);
                        v_msg   := replace(v_msg ,'[PARAM1]', get_temploy_name(r3.codempid, p_lang));
                        v_msg   := replace(v_msg ,'[PARAMEMPAP]', get_temploy_name(r3.codempid, p_lang)); -- softberry || 26/04/2023 || #8759
                        v_msg   := replace(v_msg ,'[PARAM2]', v_subject);
                        v_msg   := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                        v_msg   := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r3.codempid, p_lang));  --06/02/2021
                        if v_temp is not null then
                            v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                            p_recipients    => lower(v_email),
                                                            p_subject       => v_subject,
                                                            p_data          => v_msg,
                                                            p_filename1     => v_temp,
                                                            p_filename2     => null,
                                                            p_filename3     => null,
                                                            p_filename4     => null,
                                                            p_filename5     => null,
                                                            p_codappr       => r3.codempid,
                                                            p_codapp        => v_codappap,
                                                            p_attach_mode   => p_attach_mode);
                        else
                            v_error    := send_mail(lower(v_email),v_msg,r3.codempid,v_codappap);
                        end if;
                    end if;
                end if;
            end loop;
         elsif r2.flgappr = 'E' then
            begin
                select coduser
                  into v_coduser
                  from tusrprof
                 where codempid = r2.codempap
                   and rownum = 1;
            exception when no_data_found then
                v_coduser := null;
            end ;

            begin
                select email
                  into v_email
                  from temploy1
                 where codempid = r2.codempap
                   and staemp in ('1','3')
                   and email is not null;
            exception when no_data_found then
                v_email := null;
            end ;
          if p_codempid = r2.codempap and p_fromtype = 'U' then
            null;
          else
            if v_msg is null then
                v_error := '7526';
            elsif v_email is not null then
                v_msg       := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg       := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg       := replace(v_msg ,'[P_LANG]',to_char(p_lang));
                v_msg       := replace(v_msg ,'[PARAM1]', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'[PARAMEMPAP]', get_temploy_name(r2.codempap,p_lang)); -- softberry || 26/04/2023 || #8759
                v_msg       := replace(v_msg ,'[PARAM2]', v_subject); 
                v_msg       := replace(v_msg ,'<PARAM1>', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'<PARAM2>', v_subject);
                v_msg       := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                v_msg       := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r2.codempap,p_lang));  --06/02/2021
                if v_temp is not null then
                    v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                    p_recipients    => lower(v_email),
                                                    p_subject       => v_subject,
                                                    p_data          => v_msg,
                                                    p_filename1     => v_temp,
                                                    p_filename2     => null,
                                                    p_filename3     => null,
                                                    p_filename4     => null,
                                                    p_filename5     => null,
                                                    p_codappr       => r2.codempap,
                                                    p_codapp        => v_codappap,
                                                    p_attach_mode   => p_attach_mode);
                else
                    v_error    := send_mail(lower(v_email),v_msg,r2.codempap,v_codappap);
                end if;
            end if;
          end if;
        end if;
    end loop;

    if v_send > 0 then
        if v_error = '7521' then
            if  p_fromtype = 'E' then
               --return '2046';
               v_disperr := '2046';
            elsif p_fromtype = 'U' then
               --return '2402';
               v_disperr := '2402';
            end if;
        elsif v_error = '7522' then
            --return '7522';
            v_disperr := '7522';
        elsif v_error is null then
            --return '2401';
            v_disperr := '2401';
        end if;
    else
        if  p_fromtype = 'E' then
           --return '7525';
           v_disperr := '7525';
        else
           --return '2401';
           v_disperr := '2401';
        end if;
    end if;
    return v_disperr;
end;


function send_mail_for_approve (p_codapp          in varchar2 ,
                                 p_codempid         in varchar2,
                                 p_codrcord         in varchar2,
                                 p_coduser          in varchar2,
                                 p_file             in long,
                                 p_subject_codapp   in varchar2,
                                 p_subject_numseq   in number,
                                 p_fromtype         in varchar2,
                                 p_staappr          in varchar2,
                                 p_approvno         in number,
                                 p_codcomp          in varchar2,
                                 p_codpos           in varchar2,
                                 p_table_req        in varchar2,
                                 p_rowid            in varchar2,
                                 p_typparam         in varchar2,
                                 p_attach_mode      in varchar2 default null)
                               return varchar2 is
    p_msg_to            clob;     -- temp
    p_lang              varchar2(4000 char) ;-- temp
    v_codfrm_to         tfwmailh.codform%TYPE;
    v_template_to       clob;
    v_msg               clob;
    v_func_appr         tfwmailh.codappap%type;
    v_error             varchar2(4000 char) ;
    v_codempid          temploy1.codempid%type ;
    msg_error           varchar2(10 char) := 'aaaa' ;
    v_coduser           varchar2(10 char) ;
    v_temp              varchar2(4000 char) := null;
    v_subject           varchar2(4000 char) ;
    v_send              number := 0;
    v_codcomp           tcenter.codcomp%type;
    v_codpos            tpostn.codpos%type ;
    v_codcomp2          tcenter.codcomp%type;
    v_codpos2           tpostn.codpos%type ;
    v_codcompap         tcenter.codcomp%type;
    v_codposap          tpostn.codpos%type;
    v_codcomph          tcenter.codcomp%type;
    v_codposh           tpostn.codpos%type;
    v_email             varchar2(100 char);
    v_disperr           varchar2(600 char):='2401';
    v_found             varchar2(4 char);
    v_emailfr           varchar2(100 char);
    v_semail            varchar2(100 char);

    v_numlvl            temploy1.numlvl%type;
    v_codempmt          temploy1.codempmt%type;
    v_typemp            temploy1.typemp%type;
    v_syncond           tfwmailc.syncond%type;
    v_statment          tfwmailc.syncond%type;
    v_numseq            number:=0;
    v_qty               number:=0;

    cursor c_tfwmailc is
    select codapp, numseq, syncond
      from tfwmailc
     where codapp = p_codapp
  order by numseq;

    cursor c_tfwmaile is
    select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
      from tfwmaile
     where codapp = p_codapp
       and numseq = v_numseq
       and seqno  = p_approvno
  order by numseq;

  cursor c1 is
        select codempid
          from (
                  select codempid
                    from temploy1
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and staemp in ('1','3')
                   union
                  select codempid
                    from tsecpos
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and dteeffec <= sysdate
                     and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                )
      order by codempid;
  v_codappap tfwmailh.codappap%type;
begin
    begin
        select codappap
          into v_codappap
          from tfwmailh
         where codapp = p_codapp;
    exception when no_data_found then
        v_codappap := null;
    end;

    v_codempid := p_codempid;
    if p_codcomp is not null and p_codpos is not null then
        v_codcomp  := p_codcomp;
        v_codpos   := p_codpos;
        begin
           select numlvl, codempmt, typemp
             into v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    else
        begin
           select codcomp, codpos, numlvl, codempmt, typemp
             into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    end if;

    begin
        select email
          into v_emailfr
          from temploy1
         where codempid = p_codrcord;
    exception when no_data_found then
        v_emailfr := null;
    end;

    begin
        select email
          into v_semail
          from temploy1
         where codempid = v_codempid
           and staemp in ('1','3')
           and email is not null;
    exception when no_data_found then
        v_semail := v_emailfr;
    end ;

    begin
        select codform
          into v_codfrm_to
          from tfwmailh
         where codapp = p_codapp;
    exception when no_data_found then
        v_codfrm_to := null;
    end;

    for r1 in c_tfwmailc loop
        v_syncond := r1.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;
          v_qty := EXECUTE_QTY(v_statment) ;
          if v_qty > 0 then
            v_numseq := r1.numseq;
            exit ;
          end if;
        end if;
    end loop;  --c_tfwmailc;
    -- attach file
    v_temp := null;
    if p_file is not null then
        v_temp := p_file;
    end if;

    if v_temp is not null then
        p_flg_header := false;
    else
        p_flg_header := true;
    end if;

    for r2 in c_tfwmaile loop
--         v_msg  := p_msg_to ;
         v_send := v_send + 1;
         if r2.flgappr = 'D' then
            v_codcompap := r2.codcompap;
            v_codposap  := r2.codposap;
            for r3 in c1 loop
--                v_msg := p_msg_to ;
                begin
                    select coduser
                      into v_coduser
                      from tusrprof
                     where codempid = r3.codempid
                       and rownum = 1;
                exception when no_data_found then
                    v_coduser := null;
                end ;

                begin
                    select email
                      into v_email
                      from temploy1
                     where codempid = r3.codempid
                       and staemp in ('1','3')
                       and email is not null;
                exception when no_data_found then
                    v_email := null;
                end ;

                p_lang := get_emp_mail_lang(r3.codempid);

                if p_codempid = r3.codempid and p_fromtype = 'U' then
                    null;
                else
                    if v_email is not null then
                        v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
                        get_message(p_codapp, p_lang, v_msg, v_template_to, v_func_appr);
                        replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', v_func_appr, p_coduser, p_lang, v_msg, 'Y', v_temp);

                        v_msg   := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                        v_msg   := replace(v_msg ,'[P_CODUSER]',v_coduser);
                        v_msg   := replace(v_msg ,'[P_LANG]',p_lang);
                        v_msg   := replace(v_msg ,'[PARAM1]', get_temploy_name(r3.codempid, p_lang));
                        v_msg   := replace(v_msg ,'[PARAM2]', v_subject);
                        v_msg   := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                        v_msg   := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r3.codempid, p_lang));  --06/02/2021
                        if v_temp is not null then
                            v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                            p_recipients    => lower(v_email),
                                                            p_subject       => v_subject,
                                                            p_data          => v_msg,
                                                            p_filename1     => v_temp,
                                                            p_filename2     => null,
                                                            p_filename3     => null,
                                                            p_filename4     => null,
                                                            p_filename5     => null,
                                                            p_codappr       => r3.codempid,
                                                            p_codapp        => v_codappap,
                                                            p_attach_mode   => p_attach_mode);
                        else
                            v_error    := send_mail(lower(v_email),v_msg,r3.codempid,v_codappap);
                        end if;
                    end if;
                end if;
            end loop;
         elsif r2.flgappr = 'E' then
            begin
                select coduser
                  into v_coduser
                  from tusrprof
                 where codempid = r2.codempap
                   and rownum = 1;
            exception when no_data_found then
                v_coduser := null;
            end ;

            begin
                select email
                  into v_email
                  from temploy1
                 where codempid = r2.codempap
                   and staemp in ('1','3')
                   and email is not null;
            exception when no_data_found then
                v_email := null;
            end ;

            p_lang := get_emp_mail_lang(r2.codempap);
          if p_codempid = r2.codempap and p_fromtype = 'U' then
            null;
          else
            v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
            chk_flowmail.get_message(p_codapp, p_lang, v_msg, v_template_to, v_func_appr);
            chk_flowmail.replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', v_func_appr, p_coduser, p_lang, v_msg, 'Y', v_temp);
            if v_msg is null then
                v_error := '7526';
            elsif v_email is not null then
                v_msg       := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg       := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg       := replace(v_msg ,'[P_LANG]',to_char(p_lang));
                v_msg       := replace(v_msg ,'[PARAM1]', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'[PARAM2]', v_subject);
                v_msg       := replace(v_msg ,'<PARAM1>', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'<PARAM2>', v_subject);
                v_msg       := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                v_msg       := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r2.codempap,p_lang));  --06/02/2021
                if v_temp is not null then
                    v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                    p_recipients    => lower(v_email),
                                                    p_subject       => v_subject,
                                                    p_data          => v_msg,
                                                    p_filename1     => v_temp,
                                                    p_filename2     => null,
                                                    p_filename3     => null,
                                                    p_filename4     => null,
                                                    p_filename5     => null,
                                                    p_codappr       => r2.codempap,
                                                    p_codapp        => v_codappap,
                                                    p_attach_mode   => p_attach_mode);
                else
                    v_error    := send_mail(lower(v_email),v_msg,r2.codempap,v_codappap);
                end if;
            end if;
          end if;
        end if;
    end loop;

    if v_send > 0 then
        if v_error = '7521' then
            if  p_fromtype = 'E' then
               v_disperr := '2046';
            elsif p_fromtype = 'U' then
               v_disperr := '2402';
            end if;
        elsif v_error = '7522' then
            v_disperr := '7522';
        elsif v_error is null then
            v_disperr := '2401';
        end if;
    else
        if  p_fromtype = 'E' then
           v_disperr := '7525';
        else
           v_disperr := '2401';
        end if;
    end if;
    commit;
    return v_disperr;
end;

  function send_mail_reply(p_codapp    in varchar2 ,
                           p_codempid  in varchar2,
                           p_codreq    in varchar2,
                           p_codappr   in varchar2,
                           p_coduser   in varchar2,
                           p_file      in long,
                           p_subject_codapp in varchar2,
                           p_subject_numseq in number,
                           p_fromtype  in varchar2,
                           p_staappr   in varchar2,
                           p_approvno  in number,
                           p_codcomp   in varchar2,
                           p_codpos    in varchar2,
                           p_table_req        in varchar2,
                           p_rowid            in varchar2,
                           p_typparam         in varchar2,
                           p_attach_mode    in varchar2 default null)
                           return varchar2 is
    p_lang              varchar2(4000 char) ;-- temp
    v_codfrm_to         tfwmailh.codform%TYPE;
    v_codfrm_no         tfwmailh.codformno%TYPE;
    v_codfrm_cc         tfwmailh.codform%TYPE;
    v_template_to       clob;
    v_template_cc       clob;
    v_template_no       clob;
    v_msg               clob;
    v_msg_cc            clob;
    v_msg_no            clob;
    v_error             varchar2(4000 char) ;
    v_codempid          temploy1.codempid%type ;
    msg_error           varchar2(10 char) := 'aaaa' ;
    v_coduser           varchar2(10 char) ;
    v_temp              varchar2(4000 char) := null;

    v_subject           varchar2(4000 char);
    v_send              number := 0;
    v_codcomp           tcenter.codcomp%type;
    v_codpos            tpostn.codpos%type ;
    v_codcomp2          tcenter.codcomp%type;
    v_codpos2           tpostn.codpos%type ;
    v_codcompap         tcenter.codcomp%type;
    v_codposap          tpostn.codpos%type;
    v_codcomph          tcenter.codcomp%type;
    v_codposh           tpostn.codpos%type;
    v_email             varchar2(100 char);
    v_disperr           varchar2(600 char):='2401';
    v_found             varchar2(4 char);
    v_emailfr           varchar2(100 char);
    v_semail            varchar2(100 char);

    v_numlvl            temploy1.numlvl%type;
    v_codempmt          temploy1.codempmt%type;
    v_typemp            temploy1.typemp%type;
    v_syncond           tfwmailc.syncond%type;
    v_statment          tfwmailc.syncond%type;
    v_numseq            number:=0;
    v_qty               number:=0;

    cursor c_tfwmailc is
    select codapp, numseq, syncond
      from tfwmailc
     where codapp = p_codapp
  order by numseq;

    cursor c_tfwmaile is
    select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
      from tfwmaile
     where codapp = p_codapp
       and numseq = v_numseq
       and seqno  = p_approvno
  order by numseq;

  cursor c1 is
        select codempid
          from (
                  select codempid
                    from temploy1
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and staemp in ('1','3')
                   union
                  select codempid
                    from tsecpos
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and dteeffec <= sysdate
                     and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                )
      order by codempid;
  begin
    p_column_label          := p_column_empty;
    p_column_value          := p_column_empty;
    p_column_width          := p_column_empty;
    p_text_align            := p_column_empty;

    v_codempid := p_codempid;
    if p_codcomp is not null and p_codpos is not null then
        v_codcomp  := p_codcomp;
        v_codpos   := p_codpos;
        begin
           select numlvl, codempmt, typemp
             into v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    else
        begin
           select codcomp, codpos, numlvl, codempmt, typemp
             into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    end if;

    begin
        select email
          into v_emailfr
          from temploy1
         where codempid = p_codreq;
    exception when no_data_found then
        v_emailfr := null;
    end;

    begin
        select email
          into v_semail
          from temploy1
         where codempid = v_codempid
           and staemp in ('1','3')
           and email is not null;
    exception when no_data_found then
        v_semail := v_emailfr;
    end;

    begin
        select codform, codformno
          into v_codfrm_cc, v_codfrm_no
          from tfwmailh
         where codapp = p_codapp;
    exception when no_data_found then
        v_codfrm_cc := null;
        v_codfrm_no := null;
    end;

    if p_staappr = 'N' then
        v_codfrm_to := v_codfrm_no;
    else
        v_codfrm_to := v_codfrm_cc;
    end if;

    for r1 in c_tfwmailc loop
        v_syncond := r1.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;
          v_qty := EXECUTE_QTY(v_statment) ;
          if v_qty > 0 then
            v_numseq := r1.numseq;
            exit ;
          end if;
        end if;
    end loop;  --c_tfwmailc;
    -- attach file
    v_temp := null;
    if p_file is not null then
        v_temp := p_file;
    end if;

    if v_temp is not null then
        p_flg_header := false;
    else
        p_flg_header := true;
    end if;

    for r2 in c_tfwmaile loop
        v_send := v_send + 1;
        if r2.flgappr = 'D' then
            v_codcompap := r2.codcompap;
            v_codposap  := r2.codposap;
            for r3 in c1 loop
                begin
                    select coduser
                      into v_coduser
                      from tusrprof
                     where codempid = r3.codempid
                       and rownum = 1;
                exception when no_data_found then
                    v_coduser := null;
                end ;

                v_coduser := nvl(v_coduser,p_coduser);

                begin
                    select email
                      into v_email
                      from temploy1
                     where codempid = r3.codempid
                       and staemp in ('1','3')
                       and email is not null;
                exception when no_data_found then
                    v_email := null;
                end ;

                p_lang := get_emp_mail_lang(r3.codempid);

                if v_email is not null then
                    v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
                    get_message_reply(p_codapp, p_lang, p_staappr, v_msg, v_template_to);
                    replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', null, v_coduser, p_lang, v_msg, 'Y', v_temp);

                    v_msg   := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                    v_msg   := replace(v_msg ,'[P_CODUSER]',v_coduser);
                    v_msg   := replace(v_msg ,'[P_LANG]',p_lang);
                    v_msg   := replace(v_msg ,'[PARAM1]', get_temploy_name(r3.codempid, p_lang));
                    v_msg   := replace(v_msg ,'[PARAM2]', v_subject);
                    v_msg   := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                    v_msg   := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r3.codempid, p_lang));  --06/02/2021
                    if v_temp is not null then
                        v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                        p_recipients    => lower(v_email),
                                                        p_subject       => v_subject,
                                                        p_data          => v_msg,
                                                        p_filename1     => v_temp,
                                                        p_filename2     => null,
                                                        p_filename3     => null,
                                                        p_filename4     => null,
                                                        p_filename5     => null,
                                                        p_codappr       => r3.codempid,
                                                        p_codapp        => null,
                                                        p_attach_mode   => p_attach_mode);
                    else
                        v_error    := send_mail(lower(v_email),v_msg,r3.codempid,null);
                    end if;
                end if;
            end loop;
        elsif r2.flgappr = 'E' then
            begin
                select coduser
                  into v_coduser
                  from tusrprof
                 where codempid = r2.codempap
                   and rownum = 1;
            exception when no_data_found then
                v_coduser := null;
            end;

            v_coduser := nvl(v_coduser,p_coduser);

            begin
                select email
                  into v_email
                  from temploy1
                 where codempid = r2.codempap
                   and staemp in ('1','3')
                   and email is not null;
            exception when no_data_found then
                v_email := null;
            end ;
            p_lang := get_emp_mail_lang(r2.codempap);

            v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
            get_message_reply(p_codapp, p_lang, p_staappr, v_msg, v_template_to);
            replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', null, v_coduser, p_lang, v_msg, 'Y', v_temp);
            if v_msg is null then
                v_error := '7526';
            elsif v_email is not null then
                v_msg       := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg       := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg       := replace(v_msg ,'[P_LANG]',to_char(p_lang));
                v_msg       := replace(v_msg ,'[PARAM1]', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'[PARAM2]', v_subject);
                v_msg       := replace(v_msg ,'<PARAM1>', get_temploy_name(r2.codempap,p_lang));
                v_msg       := replace(v_msg ,'<PARAM2>', v_subject);
                v_msg       := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                v_msg       := replace(v_msg ,'[PARAM-TO]',get_temploy_name(r2.codempap,p_lang));  --06/02/2021
                if v_temp is not null then
                    v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                    p_recipients    => lower(v_email),
                                                    p_subject       => v_subject,
                                                    p_data          => v_msg,
                                                    p_filename1     => v_temp,
                                                    p_filename2     => null,
                                                    p_filename3     => null,
                                                    p_filename4     => null,
                                                    p_filename5     => null,
                                                    p_codappr       => r2.codempap,
                                                    p_codapp        => null,
                                                    p_attach_mode   => p_attach_mode);
                else
                    v_error    := send_mail(lower(v_email),v_msg,r2.codempap,null);
                end if;
            end if;
        elsif r2.flgappr = 'O' then
            begin
                select coduser
                  into v_coduser
                  from tusrprof
                 where codempid = v_codempid
                   and rownum = 1;
            exception when no_data_found then
                v_coduser := null;
            end ;

            v_coduser := nvl(v_coduser,p_coduser);

            begin
                select email
                  into v_email
                  from temploy1
                 where codempid = v_codempid
                   and staemp in ('1','3')
                   and email is not null;
            exception when no_data_found then
                v_email := null;
            end ;
            p_lang := get_emp_mail_lang(v_codempid);

            v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
            get_message_reply(p_codapp, p_lang, p_staappr, v_msg, v_template_to);

            replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', null, v_coduser, p_lang, v_msg, 'Y', v_temp);
            if v_msg is null then
                v_error := '7526';
            elsif v_email is not null then
                v_msg       := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg       := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg       := replace(v_msg ,'[P_LANG]',to_char(p_lang));
                v_msg       := replace(v_msg ,'[PARAM1]', get_temploy_name(v_codempid,p_lang));
                v_msg       := replace(v_msg ,'[PARAM2]', v_subject);
                v_msg       := replace(v_msg ,'<PARAM1>', get_temploy_name(v_codempid,p_lang));
                v_msg       := replace(v_msg ,'<PARAM2>', v_subject);
                v_msg       := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                v_msg       := replace(v_msg ,'[PARAM-TO]',get_temploy_name(v_codempid,p_lang));  --06/02/2021
                if v_temp is not null then
                    v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                    p_recipients    => lower(v_email),
                                                    p_subject       => v_subject,
                                                    p_data          => v_msg,
                                                    p_filename1     => v_temp,
                                                    p_filename2     => null,
                                                    p_filename3     => null,
                                                    p_filename4     => null,
                                                    p_filename5     => null,
                                                    p_codappr       => v_codempid,
                                                    p_codapp        => null,
                                                    p_attach_mode   => p_attach_mode);
                else
                    v_error    := send_mail(lower(v_email),v_msg,v_codempid,null);
                end if;
            end if;
        elsif r2.flgappr = 'I' then
            begin
                select coduser
                  into v_coduser
                  from tusrprof
                 where codempid = p_codreq
                   and rownum = 1;
            exception when no_data_found then
                v_coduser := null;
            end ;

            v_coduser := nvl(v_coduser,p_coduser);
            begin
                select email
                  into v_email
                  from temploy1
                 where codempid = p_codreq
                   and staemp in ('1','3')
                   and email is not null;
            exception when no_data_found then
                v_email := null;
            end ;
            p_lang := get_emp_mail_lang(p_codreq);

            v_subject := get_label_name(p_subject_codapp, p_lang, p_subject_numseq);
            get_message_reply(p_codapp, p_lang, p_staappr, v_msg, v_template_to);
            chk_flowmail.replace_text_frmmail(v_template_to, p_table_req, p_rowid, v_subject, v_codfrm_to, '1', null, v_coduser, p_lang, v_msg, 'Y', v_temp);
            if v_msg is null then
                v_error := '7526';
            elsif v_email is not null then
                v_msg       := replace(v_msg ,'[PARA_DATE]', to_char(sysdate,'dd/mm/yyyy'));
                v_msg       := replace(v_msg ,'[P_CODUSER]',v_coduser);
                v_msg       := replace(v_msg ,'[P_LANG]',to_char(p_lang));
                v_msg       := replace(v_msg ,'[PARAM1]', get_temploy_name(p_codreq,p_lang));
                v_msg       := replace(v_msg ,'[PARAM2]', v_subject);
                v_msg       := replace(v_msg ,'<PARAM1>', get_temploy_name(p_codreq,p_lang));
                v_msg       := replace(v_msg ,'<PARAM2>', v_subject);
                v_msg       := replace(v_msg ,'[P_EMAIL]',lower(v_email));  --16/11/2010
                v_msg       := replace(v_msg ,'[PARAM-TO]',get_temploy_name(p_codreq,p_lang));  --06/02/2021
                if v_temp is not null then
                    v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                                    p_recipients    => lower(v_email),
                                                    p_subject       => v_subject,
                                                    p_data          => v_msg,
                                                    p_filename1     => v_temp,
                                                    p_filename2     => null,
                                                    p_filename3     => null,
                                                    p_filename4     => null,
                                                    p_filename5     => null,
                                                    p_codappr       => p_codreq,
                                                    p_codapp        => null,
                                                    p_attach_mode   => p_attach_mode);

                else
                    v_error    := send_mail(lower(v_email),v_msg,p_codreq,null);
                end if;
            end if;
        end if;
    end loop;

    if v_send > 0 then
        if v_error = '7521' then
            if  p_fromtype = 'E' then
               v_disperr := '2046';
            elsif p_fromtype = 'U' then
               v_disperr := '2402';
            end if;
        elsif v_error = '7522' then
            v_disperr := '7522';
        elsif v_error is null then
            v_disperr := '2401';
        end if;
    else
        if  p_fromtype = 'E' then
           v_disperr := '7525';
        else
           v_disperr := '2401';
        end if;
    end if;
    return v_disperr;
end;

function send_mail_to_emp (p_codempid  in varchar2,
                                        p_codrcord   in varchar2,
                                        p_msg_to    in clob,
                                        p_file           in long,
                                        p_subject     in varchar2,
                                        p_fromtype   in varchar2,
                                        p_lang          in number,
                                        p_filename1 in varchar2 default null,
                                        p_filename2 in varchar2 default null,
                                        p_filename3 in varchar2 default null,
                                        p_attach_mode in varchar2 default null,
                                        p_fixemail in varchar2 default null,
                                        p_func_appr  in varchar2 default null,
                                        p_codappr    in varchar2 default null)
                                        return varchar2 is

    v_msg               clob := p_msg_to ;
    v_error             varchar2(4000 char) ;
    v_codempid          temploy1.codempid%type ;
    msg_error           varchar2(10 char) := 'aaaa' ;
    v_coduser           temploy1.coduser%type;
    v_temp              varchar2(4000 char) := null;
    v_subject           varchar2(4000 char) := p_subject;
    v_send              number := 0;
    v_email             temploy1.email%type;
    v_disperr           varchar2(600 char):='2401';
    v_found             varchar2(4 char);
    v_emailfr           temploy1.email%type;
    v_semail            temploy1.email%type;

    v_numseq            number:=0;
    v_qty               number:=0;
    v_param1            varchar2(1000);

begin
    if p_fixemail is null then
        v_codempid := p_codempid;
        begin
            select email
              into v_email
              from temploy1
             where codempid = v_codempid
--               and staemp in ('1','3')
               and email is not null;
        exception when no_data_found then
            v_email := null;
        end ;
        begin
            select email
              into v_semail
              from temploy1
             where codempid = p_codrcord
               and email is not null;
        exception when no_data_found then
            v_semail := v_email;
        end ;
    else
        begin
            select email
              into v_semail
              from temploy1
             where codempid = p_codrcord
               and staemp in ('1','3')
               and email is not null;
        exception when no_data_found then
            v_semail := p_fixemail;
        end ;
        v_email := p_fixemail;
    end if;

    if p_codempid is not null then
        v_param1    := get_temploy_name(p_codempid, p_lang);
    else
        v_param1 := v_email;
    end if;

    -- attach file
    v_temp := null;
    if v_msg is null then
        v_error := '7526';
    elsif v_email is not null then
        v_send := 1;
        v_msg   := replace(v_msg ,'[PARA_DATE]'  ,to_char(sysdate,'dd/mm/yyyy'));
        v_msg   := replace(v_msg ,'[P_CODUSER]'  ,v_coduser);
        v_msg   := replace(v_msg ,'[P_LANG]'        ,to_char(p_lang));
        v_msg   := replace(v_msg ,'[PARAM1]'       ,v_param1);
        v_msg   := replace(v_msg ,'[PARAM2]'       ,v_subject);
        v_msg   := replace(v_msg ,'<PARAM1>'       ,v_param1);
        v_msg   := replace(v_msg ,'<PARAM2>'       ,v_subject);
        v_msg   := replace(v_msg ,'[P_EMAIL]'      ,lower(v_email));
        v_msg   := replace(v_msg ,'[PARAM-TO]',v_param1);  --06/02/2021

        if p_filename1 is not null or p_filename2 is not null or p_filename3 is not null then
            v_error := sendmail_attachfile( p_sender        => lower(v_semail),
                                            p_recipients    => lower(v_email),
                                            p_subject       => v_subject,
                                            p_data          => v_msg,
                                            p_filename1     => p_filename1,
                                            p_filename2     => p_filename2,
                                            p_filename3     => p_filename3,
                                            p_filename4     => null,
                                            p_filename5     => null,
                                            p_codappr       => p_codappr,
                                            p_codapp        => p_func_appr,
                                            p_attach_mode   => p_attach_mode);
        else
            v_error    := send_mail(lower(v_email),v_msg,p_codappr,p_func_appr);
        end if;
    end if;
    if v_send > 0 then
        if v_error = '7521' then
            if  p_fromtype = 'E' then
               v_disperr := '2046';
            elsif p_fromtype = 'U' then
               v_disperr := '2402';
            end if;
        elsif v_error = '7522' then
            v_disperr := '7522';
        elsif v_error is null then
            v_disperr := '2401';
        end if;
    else
        if v_error = '7526' then
            v_disperr := '7526';
        elsif  p_fromtype = 'E' then
           v_disperr := '7525';
        else
           v_disperr := '2401';
        end if;
    end if;
    return v_disperr;
end;

procedure check_attachfile (p_codapp   in varchar2,
                            p_codempid in varchar2,
                            p_coduser  in varchar2,
                            p_approvno in number,
                            p_codcomp  in varchar2,
                            p_codpos   in varchar2) is

    v_codempid          temploy1.codempid%type;
    v_codcomp           tcenter.codcomp%type;
    v_codpos            tpostn.codpos%type ;
    v_codcomp2          tcenter.codcomp%type;
    v_codpos2           tpostn.codpos%type ;
    v_codcompap         tcenter.codcomp%type;
    v_codposap          tpostn.codpos%type;
    v_num               number := 0;
    v_codapp            varchar2(10 char) := substr(p_codapp,1,7);

    v_numlvl            temploy1.numlvl%type;
    v_codempmt          temploy1.codempmt%type;
    v_typemp            temploy1.typemp%type;
    v_syncond           tfwmailc.syncond%type;
    v_statment          tfwmailc.syncond%type;
    v_numseq            number := 0;
    v_qty               number := 0;

       cursor c_tfwmailc is
       select codapp, numseq, syncond
         from tfwmailc
        where codapp = p_codapp
     order by numseq;

       cursor c_tfwmaile is
       select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
         from tfwmaile
        where codapp  = p_codapp
          and numseq  = v_numseq
          and seqno   = p_approvno
     order by numseq;

  cursor c1 is
        select codempid
          from (
                  select codempid
                    from temploy1
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and staemp in ('1','3')
                   union
                  select codempid
                    from tsecpos
                   where codcomp = v_codcompap
                     and codpos = v_codposap
                     and dteeffec <= sysdate
                     and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                )
     order by codempid;

begin
    v_codempid := p_codempid;

    if p_codcomp is not null and p_codpos is not null then
        v_codcomp  := p_codcomp;
        v_codpos   := p_codpos;
    else
        begin
           select codcomp, codpos, numlvl, codempmt, typemp
             into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
             from temploy1
            where codempid = v_codempid;
        exception when no_data_found then
            null;
        end;
    end if;

    begin
        select nvl(max(numseq),0)
          into v_num
          from ttemprpt
         where codempid = p_coduser
           and codapp = p_codapp;
    exception when no_data_found then
        v_num := 0;
    end;

    for r1 in c_tfwmailc loop
        v_syncond := r1.syncond ;
        if v_syncond is not null then
          v_statment := v_syncond ;
          v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
          v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
          v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;
          v_qty := EXECUTE_QTY(v_statment) ;
          if v_qty > 0 then
            v_numseq := r1.numseq;
            exit;
          end if;
        end if;
    end loop;  --c_tfwmailc;

    for r2 in c_tfwmaile loop
        if r2.flgappr = 'D' then
            v_codcompap := r2.codcompap;
            v_codposap  := r2.codposap;
            for r3 in c1 loop
                v_num  := v_num + 1;
                insert into ttemprpt(codempid, codapp, numseq, item1, item2)
                     values (p_coduser, p_codapp, v_num, v_codempid, r3.codempid);
            end loop;
        elsif r2.flgappr = 'E' then
            v_num  := v_num + 1;
            insert into ttemprpt(codempid, codapp, numseq, item1, item2)
                 values (p_coduser, p_codapp, v_num, v_codempid, r2.codempap);
        end if;
    end loop;
    commit;
end;

  function check_exists_column (p_table varchar2, p_column varchar2) return boolean is
    v_chk   number;
  begin
    begin
      select count(*)
        into v_chk
        from user_tab_columns
       where table_name  = upper(p_table)
         and column_name = upper(p_column);
    exception when others then
      v_chk := 0;
    end;

    if v_chk > 0 then
      return true;
    else
      return false;
    end if;
  end;
  --
  function replace_clob (in_source in clob, in_search in varchar2, in_replace in clob) return clob is
    l_pos pls_integer;
  begin
    l_pos := instr(in_source, in_search);

    if l_pos > 0 then
      return substr(in_source, 1, l_pos-1) || in_replace || substr(in_source, l_pos + length(in_search));
    end if;

    return in_source;
  end replace_clob;
  --
--replace_text_frmmail
  procedure replace_text_frmmail (p_template     in clob,
                                  p_table_req    in varchar2,
                                  p_rowid        in varchar2,
                                  p_subject      in varchar2,
                                  p_codform      in varchar2,
                                  p_typparam     in varchar2,
                                  p_func_appr    in varchar2,
                                  p_coduser      in varchar2,
                                  p_lang         in varchar2,
                                  p_msg          in out clob,
                                  p_chkparam    in varchar2 default 'Y' ,
                                  p_file   in long  default null) is

    data_file       clob;
    crlf            varchar2( 2 ) := chr( 13 ) || chr( 10 );
    v_http          varchar2(1000 char);
    v_message       clob;
    v_template      clob;
    v_codpos        temploy1.codpos%type;
    p_codappr       temploy1.codempid%type := get_codempid(p_coduser);
    v_email         temploy1.email%type;

    v_codlang       varchar2(3);
    v_codtable      varchar2(15);
    v_codcolmn      varchar2(60);
    v_funcdesc      varchar2(200);
    v_flgchksal     varchar2(1);
    v_statmt        long;
    v_item          varchar2(500);
    v_value         varchar2(500);
    v_data_type     varchar2(200);

    v_codempid_req  temploy1.codempid%type;

    v_max_col        number := 0;
    v_data_table     clob;
    v_data_list      clob;
    v_chkmax         varchar2(1 char);
    v_num            number := 0;
    v_bgcolor        varchar2(20 char);

    cursor c1 is
        select b.fparam, b.ffield,
               decode(v_codlang ,'101',descripe
                                ,'102',descript
                                ,'103',descrip3
                                ,'104',descrip4
                                ,'105',descrip5) as descript,
               b.codtable, c.fwhere,
               'select '||b.ffield||' from '||b.codtable||' where '||c.fwhere as stm,
               flgdesc
          from tfrmmail a,tfrmmailp b,tfrmtab c
         where a.codform   = p_codform
           and a.codform   = b.codform
           and a.typfrm    = c.typfrm
           and b.codtable  = c.codtable
           and nvl(a.typparam,'1')  = p_typparam
           and b.flgstd    = 'N'
      order by b.numseq;
  BEGIN
     v_http := get_tsetup_value('PATHMOBILE') ;
     begin
          select codpos, email
            into v_codpos, v_email
            from temploy1
           where codempid = p_codappr;
     exception when no_data_found then
          v_codpos := null;
          v_email  := null;
     end;

     v_message   := p_msg ;
     v_template  := p_template ;
     v_message   := replace_clob(v_template,'[P_MESSAGE]', replace(replace(v_message,chr(10),'<br>'),' ','&nbsp;'));
     v_message   := replace(v_message,'&lt;', '<');
     v_message   := replace(v_message,'&gt;', '>');
     data_file   := v_message ;
     p_msg :=   'From: ' ||lower(v_email)|| crlf ||
                'To: [P_EMAIL]'||crlf||
                'Subject: '||p_subject||crlf||
                'Content-Type: text/html;';

     if upper(p_table_req) in ('TORGPRT','TBUDGET','TTEMADJ1') then
        if check_exists_column(p_table_req, 'codemprq') then
            execute immediate 'select codemprq from '||p_table_req||' where rowid = '''||p_rowid||''' ' into v_codempid_req;
        end if;
     else
        if check_exists_column(p_table_req, 'codempid') then
          execute immediate 'select codempid from '||p_table_req||' where rowid = '''||p_rowid||''' ' into v_codempid_req;
        end if;
     end if;

     for i in c1 loop
        v_codtable := i.codtable;
        v_codcolmn := i.ffield;
        begin
            select funcdesc, flgchksal, data_type
              into v_funcdesc, v_flgchksal, v_data_type
              from tcoldesc
             where codtable = v_codtable
               and codcolmn = v_codcolmn;
        exception when no_data_found then
          v_funcdesc    := null;
          v_flgchksal   := 'N' ;
        end;
        begin
            select codlang
              into v_codlang
              from tfmrefr
             where codform = p_codform;
        exception when no_data_found then
            v_codlang := p_lang;
        end;
        v_codlang := nvl(v_codlang,p_lang);

        if nvl(i.flgdesc,'N') = 'N' then
          v_funcdesc := null;
        end if;
        if v_flgchksal = 'Y' then
          if upper(p_table_req) in ('TORGPRT','TBUDGET','TTEMADJ1') then
            v_statmt  := 'select to_char(stddec('||i.ffield||',codemprq,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
          else
            v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
          end if;
--          v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
        elsif upper(i.ffield) = 'CODPSWD' then
          v_statmt  := 'select pwddec('||i.ffield||',coduser,'''||global_v_chken||''') from '||i.codtable ||' where  '||i.fwhere ;
        elsif v_funcdesc is not null then
          v_funcdesc    := replace(v_funcdesc,'P_CODE',i.ffield) ;
          v_funcdesc    := replace(v_funcdesc,'P_LANG',v_codlang) ;
          v_funcdesc    := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
          v_funcdesc    := replace(v_funcdesc,'P_TEXT',global_v_chken) ;
          v_statmt      := 'select '||v_funcdesc||' from '||i.codtable ||' where '||i.fwhere ;
        elsif v_data_type = 'DATE' then
          v_statmt  := 'select hcm_util.get_date_buddhist_era('||i.ffield||') from '||i.codtable ||' where '||i.fwhere ;
        else
          v_statmt  := i.stm ;
        end if;

        v_statmt    := replace(v_statmt,'[#CODEMPID]',v_codempid_req);
        v_statmt    := replace(v_statmt,'[#ROWID]',p_rowid);
        v_value     := execute_desc(v_statmt) ;
        if i.ffield like 'TIM%' then
            if v_value is not null then
                declare v_chk_length number;
                begin
                    select char_length
                      into v_chk_length
                      from user_tab_columns
                     where table_name = i.codtable
                       and column_name = i.ffield;
                    if v_chk_length = 4 then
                        v_value := substr(lpad(v_value,4,'0'),1,2)||':'||substr(lpad(v_value,4,'0'),-2,2);
                    end if;
                exception when no_data_found then
                    null;
                end;
            else
                v_value := ' - ';
            end if;
        end if;

        if i.ffield like 'AMT%' and v_data_type = 'NUMBER' then
            v_value := to_char(v_value,'fm999,999,999,990.00');
        end if;

--        if v_flgchksal = 'Y' then
--            v_value := null ;
--        end if;

        --data_file := replace(data_file,i.fparam,v_value);
        if (p_chkparam = 'Y') or (p_chkparam = 'N'   and v_value is not null)  then
            data_file := replace(data_file,i.fparam,v_value);
        end if;

     end loop;

     -- Start set column label name
     set_column_label(p_codform);
     v_max_col  := least(p_max_column,p_column_width.count - 1);

     -- ## LOOP DATA START ## --
     -- TABLE HEADER 
     v_data_table := '<table width="100%" border="0" cellpadding="0" cellspacing="1" bordercolor="#FFFFFF">';
     v_data_table := v_data_table||'<tr class="TextBody" bgcolor="#006699">
                         <td width="'||p_column_width(1)||'%"  height="20" align="center"><font color="#FFFFFF">'||get_label_name('ESS', p_lang_mail, 20)||'</font></td>';
     for x in 1..v_max_col loop
        v_data_table  := v_data_table||'<td width="'||p_column_width(x + 1)||'%" align="center"><font color="#FFFFFF">'||p_column_label(x)||'</font></td>';
     end loop;
     v_data_table  := v_data_table||'</tr>';

     -- TABLE BODY
     v_num          := 0;
     v_chkmax       := 'N';
     v_data_list    := ''; -- LIST CONTENT

     v_num          := v_num + 1 ;
     if mod(v_num,2) = 1 then
        v_bgcolor := '"#EFF4F8"' ;
     else
        v_bgcolor := '"#FFFFFF"' ;
     end if;

     if v_chkmax = 'N' then
        get_column_value(v_codempid_req,p_rowid,p_codform);
        v_data_table    := v_data_table||'<tr class="TextBody"  bgcolor='||v_bgcolor||'>
                             <td height="15" align="center">'||v_num||'</td>';
        v_data_list     := v_data_list||'<div>';  -- LIST CONTENT
        for x in 1..v_max_col loop
            v_data_table  := v_data_table||'<td align="'||p_text_align(x)||'">'||p_column_value(x)||'</td>';
            v_data_list   := v_data_list||'<div>'||p_column_label(x)||': '||p_column_value(x)||'</div>';  -- LIST CONTENT
        end loop;
        v_data_table    := v_data_table||'</tr>';
        v_data_list     := v_data_list||'</div>';  -- LIST CONTENT
     end if;  --v_chkmax
     v_data_table     := v_data_table||'</table>';

     if data_file like ('%[TABLE]%') then
        data_file  := replace(data_file  ,'[TABLE]', v_data_table);
     end if;
     if data_file like ('%[LIST]%') then
        data_file  := replace(data_file  ,'[LIST]', v_data_list);
     end if;

     if data_file like ('%[PARAM-LINK]%') then
        data_file  := replace(data_file  ,'[PARAM-LINK]', '<a href="'||v_http||'"><b>APPROVE</b></a>');
     end if;
     if data_file like ('%[P_DATA]%') then
        data_file  := replace(data_file  ,'[P_DATA]', '');
     end if;
     if data_file like ('%[PARA_FROM]%') then
        data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_codappr,v_codlang));
     end if;
     if data_file like ('%[PARA_POSITION]%') then
        data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,v_codlang));
     end if;
     if data_file like ('%[HTTP]%') then
        data_file  := replace(data_file  ,'[HTTP]', v_http);
     end if;

     if p_file is not null /*or data_file like 'From:%To:%Subject:%Content-Type:%'*/ then
        p_flg_header := false;
     else
        p_flg_header := true;
     end if;



     if lower(get_tsetup_value('SYSPLATFORM')) = 'aws' and p_flg_header = false then
        p_msg := data_file;
     else
        p_msg := p_msg||crlf||crlf||data_file;
     end if;
  end;  --  procedure replace_text_frmmail
  -- end replace_text_frmmail

--replace_param
  procedure replace_param (p_table_req    in varchar2,
                           p_rowid        in varchar2,
                           p_codform      in varchar2,
                           p_typparam     in varchar2,
                           p_lang         in varchar2,
                           p_msg          in out clob,
                           p_chkparam    in varchar2 default 'Y') is

    data_file       clob;
    crlf            varchar2( 2 ) := chr( 13 ) || chr( 10 );
    v_http          varchar2(1000 char);
    v_message       clob;
    v_template      clob;
    v_codpos        temploy1.codpos%type;
    v_email         temploy1.email%type;

    v_codlang       varchar2(3);
    v_codtable      varchar2(15);
    v_codcolmn      varchar2(60);
    v_funcdesc      varchar2(200);
    v_flgchksal     varchar2(1);
    v_statmt        long;
    v_item          varchar2(500);
    v_value         varchar2(500);
    v_data_type     varchar2(200);

    v_codempid_req  temploy1.codempid%type;

    v_max_col        number := 0;
    v_data_table     clob;
    v_data_list      clob;
    v_chkmax         varchar2(1 char);
    v_num            number := 0;
    v_bgcolor        varchar2(20 char);

    cursor c1 is
        select b.fparam, b.ffield,
               decode(v_codlang ,'101',descripe
                                ,'102',descript
                                ,'103',descrip3
                                ,'104',descrip4
                                ,'105',descrip5) as descript,
               b.codtable, c.fwhere,
               'select '||b.ffield||' from '||b.codtable||' where '||c.fwhere as stm,
               flgdesc
          from tfrmmail a,tfrmmailp b,tfrmtab c
         where a.codform   = p_codform
           and a.codform   = b.codform
           and a.typfrm    = c.typfrm
           and b.codtable  = c.codtable
           and upper(b.codtable) = upper(p_table_req)
           and nvl(a.typparam,'1')  = p_typparam
           and b.flgstd    = 'N'
      order by b.numseq;
  BEGIN
     v_message   := p_msg ;
     data_file   := v_message ;

     if upper(p_table_req) in ('TORGPRT','TBUDGET','TTEMADJ1') then
        if check_exists_column(p_table_req, 'codemprq') then
            execute immediate 'select codemprq from '||p_table_req||' where rowid = '''||p_rowid||''' ' into v_codempid_req;
        end if;
     else
        if check_exists_column(p_table_req, 'codempid') then
        commit;
          execute immediate 'select codempid from '||p_table_req||' where rowid = '''||p_rowid||''' ' into v_codempid_req;
        end if;
     end if;

     for i in c1 loop
        v_codtable := i.codtable;
        v_codcolmn := i.ffield;
        begin
            select funcdesc, flgchksal, data_type
              into v_funcdesc, v_flgchksal, v_data_type
              from tcoldesc
             where codtable = v_codtable
               and codcolmn = v_codcolmn;
        exception when no_data_found then
          v_funcdesc    := null;
          v_flgchksal   := 'N' ;
        end;
        begin
            select codlang
              into v_codlang
              from tfmrefr
             where codform = p_codform;
        exception when no_data_found then
            v_codlang := p_lang;
        end;
        v_codlang := nvl(v_codlang,p_lang);

        if nvl(i.flgdesc,'N') = 'N' then
          v_funcdesc := null;
        end if;
        if v_flgchksal = 'Y' then
          v_statmt  := 'select to_char(stddec('||i.ffield||',codempid,'''||global_v_chken||'''),''fm999,999,999,990.00'') from '||i.codtable ||' where  '||i.fwhere ;
        elsif v_funcdesc is not null then
          v_funcdesc    := replace(v_funcdesc,'P_CODE',i.ffield) ;
          v_funcdesc    := replace(v_funcdesc,'P_LANG',v_codlang) ;
          v_funcdesc    := replace(v_funcdesc,'P_CODEMPID','CODEMPID') ;
          v_funcdesc    := replace(v_funcdesc,'P_TEXT',global_v_chken) ;
          v_statmt      := 'select '||v_funcdesc||' from '||i.codtable ||' where '||i.fwhere ;
        elsif v_data_type = 'DATE' then
          v_statmt  := 'select hcm_util.get_date_buddhist_era('||i.ffield||') from '||i.codtable ||' where '||i.fwhere ;
        else
          v_statmt  := i.stm ;
        end if;

        v_statmt    := replace(v_statmt,'[#CODEMPID]',v_codempid_req);
        v_statmt    := replace(v_statmt,'[#ROWID]',p_rowid);
        v_value     := execute_desc(v_statmt) ;
        if i.ffield like 'TIM%' then
            if v_value is not null then
                declare v_chk_length number;
                begin
                    select char_length
                      into v_chk_length
                      from user_tab_columns
                     where table_name = i.codtable
                       and column_name = i.ffield;
                    if v_chk_length = 4 then
                        v_value := substr(lpad(v_value,4,'0'),1,2)||':'||substr(lpad(v_value,4,'0'),-2,2);
                    end if;
                exception when no_data_found then
                    null;
                end;
            else
                v_value := ' - ';
            end if;
        end if;

        if i.ffield like 'AMT%' and v_data_type = 'NUMBER' then
            v_value := to_char(v_value,'fm999,999,999,990.00');
        end if;

        if v_flgchksal = 'Y' then
            v_value := null ;
        end if;

        --data_file := replace(data_file,i.fparam,v_value);
        if (p_chkparam = 'Y') or (p_chkparam = 'N'   and v_value is not null)  then
            data_file := replace(data_file,i.fparam,v_value);
        end if;
     end loop;
     p_msg := data_file;
  end;  --  procedure replace_param
  -- end replace_param

    procedure get_receiver (p_codapp        in varchar2 ,
                            p_codempid      in varchar2,
                            p_fromtype      in varchar2,
                            p_approvno      in number,
                            p_codcomp       in varchar2,
                            p_codpos        in varchar2,
                            a_receiver      out t_array_var2,
                            v_qty_receiver  out number) is
        v_codempid          temploy1.codempid%type ;
        v_codcomp           tcenter.codcomp%type;
        v_codpos            tpostn.codpos%type ;
        v_codcompap         tcenter.codcomp%type;
        v_codposap          tpostn.codpos%type;

        v_numlvl            temploy1.numlvl%type;
        v_codempmt          temploy1.codempmt%type;
        v_typemp            temploy1.typemp%type;
        v_syncond           tfwmailc.syncond%type;
        v_statment          tfwmailc.syncond%type;
        v_numseq            number:=0;
        v_qty               number:=0;

        cursor c_tfwmailc is
            select codapp, numseq, syncond
              from tfwmailc
             where codapp = p_codapp
          order by numseq;

        cursor c_tfwmaile is
            select codapp, numseq, seqno, flgappr, codcompap, codposap, codempap
              from tfwmaile
             where codapp = p_codapp
               and numseq = v_numseq
               and seqno  = p_approvno
          order by numseq;

        cursor c1 is
            select codempid
              from (
                      select codempid
                        from temploy1
                       where codcomp = v_codcompap
                         and codpos = v_codposap
                         and staemp in ('1','3')
                       union
                      select codempid
                        from tsecpos
                       where codcomp = v_codcompap
                         and codpos = v_codposap
                         and dteeffec <= sysdate
                         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                    )
          order by codempid;
    begin
        v_qty_receiver := 0;
        v_codempid := p_codempid;
        if p_codcomp is not null and p_codpos is not null then
            v_codcomp  := p_codcomp;
            v_codpos   := p_codpos;
            begin
               select numlvl, codempmt, typemp
                 into v_numlvl, v_codempmt, v_typemp
                 from temploy1
                where codempid = v_codempid;
            exception when no_data_found then
                null;
            end;
        else
            begin
               select codcomp, codpos, numlvl, codempmt, typemp
                 into v_codcomp, v_codpos, v_numlvl, v_codempmt, v_typemp
                 from temploy1
                where codempid = v_codempid;
            exception when no_data_found then
                null;
            end;
        end if;

        for r1 in c_tfwmailc loop
            v_syncond := r1.syncond ;
            if v_syncond is not null then
              v_statment := v_syncond ;
              v_statment := replace(v_statment,'TEMPLOY1.CODCOMP',''''||v_codcomp||'''') ;
              v_statment := replace(v_statment,'TEMPLOY1.CODPOS',''''||v_codpos||'''') ;
              v_statment := replace(v_statment,'TEMPLOY1.NUMLVL',v_numlvl) ;
              v_statment := replace(v_statment,'TEMPLOY1.CODEMPMT',''''||v_codempmt||'''') ;
              v_statment := replace(v_statment,'TEMPLOY1.TYPEMP',''''||v_typemp||'''') ;
              v_statment := replace(v_statment,'TEMPLOY1.CODEMPID',''''||v_codempid||'''') ;
              v_statment := 'select count(*) from temploy1 where '||v_statment||' and codempid ='''||v_codempid||'''' ;
              v_qty := EXECUTE_QTY(v_statment) ;
              if v_qty > 0 then
                v_numseq := r1.numseq;
                exit ;
              end if;
            end if;
        end loop;  --c_tfwmailc;

        for r2 in c_tfwmaile loop
             if r2.flgappr = 'D' then
                v_codcompap := r2.codcompap;
                v_codposap  := r2.codposap;
                for r3 in c1 loop
                    if p_codempid = r3.codempid and p_fromtype = 'U' then
                        null;
                    else
                        v_qty_receiver := v_qty_receiver + 1;
                        a_receiver(v_qty_receiver) := r3.codempid;
                    end if;
                end loop;
             elsif r2.flgappr = 'E' then
                if p_codempid = r2.codempap and p_fromtype = 'U' then
                    null;
                else
                    v_qty_receiver := v_qty_receiver + 1;
                    a_receiver(v_qty_receiver) := r2.codempap;
                end if;
            end if;
        end loop;
    end;
END;

/

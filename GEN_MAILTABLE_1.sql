--------------------------------------------------------
--  DDL for Package Body GEN_MAILTABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "GEN_MAILTABLE" IS


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

procedure get_message(p_codform     in varchar2,
                      p_lang        in varchar2,
                      o_msg_to      out clob,
                      data_table    in out clob,
                      data_list     in out clob,
                      p_module      in varchar2,
                      p_column_label in t_array_var2,
                      p_column_value in t_array_var2,
                      p_column_width in t_array_var2) is
    v_msg_to    long ;

    v_max_col        number := 0;
    v_data_table     clob;
    v_data_list      clob;
    v_num            number := 0;
    v_chkmax         varchar2(1 char);
    v_bgcolor        varchar2(20 char);
begin
    p_lang_mail := p_lang;
    -- Start set column label name
--    set_column_label(p_codform);
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
--    get_column_value(v_codempid_req,p_rowid,p_codform);
--    v_data_table    := v_data_table||'<tr class="TextBody"  bgcolor='||v_bgcolor||'>
--                         <td height="15" align="center">'||v_num||'</td>';
--    v_data_list     := v_data_list||'<div>';  -- LIST CONTENT
--    for x in 1..v_max_col loop
--        v_data_table  := v_data_table||'<td align="'||p_text_align(x)||'">'||p_column_value(x)||'</td>';
--        v_data_list   := v_data_list||'<div>'||p_column_label(x)||': '||p_column_value(x)||'</div>';  -- LIST CONTENT
--    end loop;
--    v_data_table    := v_data_table||'</tr>';
--    v_data_list     := v_data_list||'</div>';  -- LIST CONTENT
--    v_data_table     := v_data_table||'</table>';
--    if data_file like ('%[TABLE]%') then
--       data_file  := replace(data_file  ,'[TABLE]', v_data_table);
--    end if;
--    if data_file like ('%[LIST]%') then
--       data_file  := replace(data_file  ,'[LIST]', v_data_list);
--    end if;    
end; -- get_message


function get_emp_mail_lang(p_codempid   in varchar2) return varchar2 is
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
    return v_lang;
end;

END;

/

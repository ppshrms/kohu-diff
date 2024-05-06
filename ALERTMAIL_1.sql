--------------------------------------------------------
--  DDL for Package Body ALERTMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "ALERTMAIL" 
is
   vp_memono    varchar2(100 char);
   vp_dteeffec  varchar2(100 char);
   vp_syncond   varchar2(1000 char);
   vp_codempid  varchar2(100 char);
   vp_table     varchar2(100 char);


  procedure run_alert is
  begin
    alertmail.check_proc (null,null,null);
  end  ;

  procedure check_proc (p_memono in varchar2,p_dteeffec in date,p_type in varchar) is
   v_msg      clob;
   v_table    varchar2(100 char);
   v_num      number(10) := 0;
   v_check    varchar2(4000 char);
   v_err      number;
   v_sql      clob;
   v_filename varchar2(400  char);
   v_where    varchar2(4000 char);

   cursor c is
     select *
     from  tmailalert a
     where memono   = nvl(p_memono,memono)
     and   dteeffec = nvl(p_dteeffec,dteeffec)
     and   flgeffec = 'A'
     and   ((dtelast + qtydayr <= sysdate  or dtelast is null ) or p_type = 'TEST') ;

  cursor c1(v_memono varchar2,v_dteeffec date) is
     select rownum,tname
     from  tmailaled
     where dteeffec = v_dteeffec
     and   memono  = v_memono;

  BEGIN

     vp_memono    := null;
     vp_dteeffec  := null;
     vp_syncond   := null;
     vp_codempid  := null;
     vp_table     := null;
     for mail in c loop
       v_table := null;
       for maild in c1(mail.memono,mail.dteeffec) loop
         if maild.rownum = 1 then
           v_table := maild.tname;
         else
           v_table := v_table||','||maild.tname;
         end if;
       end loop;

       if mail.syncond is not null then
        v_where := ' where '||mail.syncond;
       end if;
       v_num := execute_sql('select count(*) from '||v_table||v_where);
       v_msg := mail.message;
       -------- clear data -----------
       v_sql := 'delete from ttempprm where codempid = '''||mail.codempid||''' and codapp = '''||mail.memono||'''';
       execute immediate v_sql;

       v_sql := 'delete from ttemprpt where codempid = '''||mail.codempid||''' and codapp = '''||mail.memono||'''';
       execute immediate v_sql;

       if v_num > 0 then
         loop
            v_check   := substr(v_msg,instr(v_msg,'[') +1,(instr(v_msg,']') -1) - instr(v_msg,'['));
            exit when v_check is null;
            v_msg     := replace(v_msg,'['||v_check||']',v_num);
  	     end loop;

         vp_memono    := mail.memono;
         vp_dteeffec  := mail.dteeffec;
         vp_syncond   := mail.syncond;
         vp_codempid  := mail.codempid;
         vp_table     := v_table;

         inst_data(mail.memono,mail.dteeffec,mail.syncond,mail.codempid,v_table,v_filename);
         --if nvl(p_type,'XX') <> 'TEST' then
         check_mail(mail.codempid,mail.memono,mail.dteeffec ,mail.subject,v_msg,v_filename);
         --end if;
       end if;
       if nvl(p_type,'XX') <> 'TEST' then
           update  tmailalert
           set    dtelast = trunc(sysdate)
           where  memono   = mail.memono
           and    dteeffec = mail.dteeffec ;
           commit ;
       end if;
     end loop;
END check_proc;

-------------------------------------------------------------

 PROCEDURE Check_mail (p_empidf   in varchar2,
                       p_memono   in varchar2,
                       p_dteeffec in date ,
                       p_subject  in varchar2,
                       p_msg      in clob,
                       p_filename in varchar2 ) is

   v_error          varchar2(4000 char);
   v_fromname       varchar2(4000 char);
   v_email          temploy1.email%type;
   v_codposre       varchar2(4000 char);
   v_codcomp        varchar2(4000 char);
   v_template       clob;
   v_message        clob;
   data_file        clob;
   v_codpos         varchar2(4000 char);
   v_filename       varchar2(100 char);
   v_emp            varchar2(4000 char);
   v_tab            varchar2(1000 char);
   v_sql_ins1       varchar2(30000 char);
   v_sql_ins2       varchar2(30000 char);
   vp_filename      varchar2(100 char);
   vp_syncond_old   varchar2(4000 char);
   v_prefix         varchar2(100 char);
   v_prefix_emp     varchar2(100 char);
   vp_h_emp         varchar2(100 char);

  cursor c_department is
    select codempid from(
                      		select codempid
                      		  from   temploy1
                      		  where  codcomp	= v_codcomp
                      	    and    codpos	= v_codposre
                          	and    staemp in  ('1','3')
                      		union
                            select codempid
                      		  from   tsecpos
                      		  where  codcomp = v_codcomp
                      		  and    codpos  = v_codposre
                      	    and    dteeffec <= sysdate
                      		  and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null))
		order by codempid;

   cursor c_tmailasgn is
        select *
        from  tmailasgn
        where memono = p_memono
        and   dteeffec = p_dteeffec;

   cursor c2(v_memono varchar2,v_dteeffec date) is
        select rownum,pfield,pdesct,flgdesc
        from  tmailrep
         where dteeffec = v_dteeffec
          and  memono   = v_memono
     order by  numseq;

--STA4-1701||2/11/2017||user39
   cursor c_emp is
         select distinct item1 empid from ttemprpt
         where codempid = vp_codempid
         and   codapp = 'HRPM1HEZ'
         and   nvl(item2,'@#$') = nvl(vp_h_emp,nvl(item2,'@#$'))
         order by empid
         ;

    cursor c_heademp is
         select distinct item2 h_empid from ttemprpt
         where codempid = vp_codempid
         and   codapp = 'HRPM1HEZ'
         order by h_empid
         ;
--STA4-1701||2/11/2017||user39
  begin

    delete from ttemprpt where codapp = 'HRPM1HEZ'; commit;

    begin
      select get_temploy_name(codempid,'102'),email,codpos
      into   v_fromname,v_email,v_codpos
      from   temploy1
      where  codempid  = p_empidf;
    exception when others then
          v_fromname := null ;
    end;
    begin
      select messaget
      into  v_template
      from  tfrmmail
      where codform = 'TEMPLATEAL' ;
    exception when others then
      v_template := null ;
    end ;
    v_message   := p_msg ;
    v_message   := replace(v_template,'[P_MESSAGE]', v_message);

    for i in c_tmailasgn loop
          data_file       := v_message ;
          data_file       := replace(data_file ,'[P_OTHERMSG]',i.message);
          if data_file like ('%[PARA_FROM]%') then
            data_file  := replace(data_file  ,'[PARA_FROM]', get_temploy_name(p_empidf,'102'));
          end if;
          if data_file like ('%[PARA_POSITION]%') then
        	   data_file  := replace(data_file  ,'[PARA_POSITION]',get_tpostn_name(v_codpos,'102'));
          end if;
          if i.flgappr = '5' then
              vp_h_emp := null;
              delete ttemprpt where codempid = vp_codempid and codapp = 'HRPM1HEZ'; commit;
              if (vp_table is not null)  and  instr(vp_table,',') > 0 then
                 v_prefix := substr(vp_table,1,instr(vp_table,',')-1);
                 v_prefix_emp := v_prefix||'.codempid';
              else
                 v_prefix_emp := 'codempid';
              end if;
              v_sql_ins1 := 'select  rownum '||','||v_prefix_emp||','||'''HRPM1HEZ''  ,'||''''||vp_codempid||''''||'  from '||vp_table||' where '||vp_syncond;
              v_sql_ins2 := 'insert into ttemprpt(numseq,item1,codapp,codempid) '||'('||v_sql_ins1||')';

              execute immediate v_sql_ins2;
              for y in c_emp loop
                vp_syncond_old := vp_syncond;
                vp_syncond := vp_syncond||' and '||v_prefix_emp||' = '''||y.empid||'''';
                inst_data(vp_memono,vp_dteeffec,vp_syncond,vp_codempid,vp_table,vp_filename);
                v_error := send_msg (v_email,y.empid,data_file,p_subject,vp_filename);
                vp_syncond := vp_syncond_old;
              end loop;
          elsif i.flgappr = '1' then
              delete ttemprpt where codempid = vp_codempid and codapp = 'HRPM1HEZ'; commit;
              if (vp_table is not null)  and  instr(vp_table,',') > 0 then
                   v_prefix := substr(vp_table,1,instr(vp_table,',')-1);
                   v_prefix_emp := v_prefix||'.codempid';
              else
                   v_prefix_emp := 'codempid';
              end if;
              v_sql_ins1 := 'select  rownum '||','||'alertmail.gen_header('||v_prefix_emp||')'||','||v_prefix_emp||','||'''HRPM1HEZ''  ,'||''''||vp_codempid||''''||'  from '||vp_table||
              ' where '||vp_syncond||' and alertmail.gen_header('||v_prefix_emp||') is not null';
              v_sql_ins2 := 'insert into ttemprpt(numseq,item2,item1,codapp,codempid) '||'('||v_sql_ins1||')';
              execute immediate v_sql_ins2;
              vp_h_emp := null;
              for x in c_heademp loop
                 vp_h_emp := x.h_empid;
                 v_emp := null;
                 for d in c_emp loop
                    if v_emp is null then 
                        v_emp := ''''||d.empid||'''';
                    else
                        v_emp := v_emp||','''||d.empid||'''';
                    end if;
                 end loop;
--                 v_emp := substr(v_emp,1,instr(v_emp,',',-1)-1);
                 vp_syncond_old := vp_syncond;
                 if v_emp is not null then
                    vp_syncond := vp_syncond||' and '||v_prefix_emp||' in ('||v_emp||')';
                 end if;
                 inst_data(vp_memono,vp_dteeffec,vp_syncond,vp_codempid,vp_table,vp_filename);
                 v_error := send_msg (v_email,vp_h_emp,data_file,p_subject,vp_filename);
                 vp_syncond := vp_syncond_old;
              end loop;
          elsif i.flgappr = '4' then
             v_error := Send_Msg (v_email,i.codempap,data_file,p_subject,p_filename);
          elsif i.flgappr = '3' then
             v_codcomp  := i.codcompap ;
             v_codposre := i.codposap ;
             for j in c_department loop
                 v_error := Send_Msg (v_email,j.codempid,data_file,p_subject,p_filename);
             end loop;
          end if;
    end loop;
--STA4-1701||2/11/2017||user39
  exception when others then
   null;
  END ;
  --------------------------- Send msg
  FUNCTION Send_Msg (p_fromname in varchar2,
                      p_codempid in varchar2,
                      p_msg      in clob,
                      p_subj     in varchar2,
                      p_filename in varchar2) RETURN VARCHAR2 IS
      v_msg        clob;
      v_id         varchar2(4000 char) ;
      v_idemp      varchar2(4000 char) ;
      v_name       varchar2(4000 char);
      v_emailt     varchar2(4000 char);
      v_error      varchar2(4000 char);
      v_http       varchar2(4000 char);
      v_filename   varchar2(4000 char);
      crlf         char(2) := CHR(10) || CHR(13);
  BEGIN

    begin
      select email,get_temploy_name(codempid,'102')
      into   v_emailt,v_name
      from   temploy1
      where  codempid  = p_codempid;
    exception when others then
       v_emailt := null ;
    end;

    if v_emailt is not null then
        v_msg      := p_msg;
        v_msg      := replace(v_msg ,'<PARAM1>', v_name);
        if p_filename is not null then
            v_filename := get_tsetup_value('PATHEXCEL')||p_filename ;
        else
            v_filename := null ;
        end if;
--        v_filename := null ;
        v_error    := SendMail_AttachFile(get_tsetup_value('MAILEMAIL'),v_emailt,p_subj,v_msg,v_filename,null,null,null,null,null,null,'Oracle');
    end if;
    return v_error ;
  END Send_Msg;

  procedure inst_data(v_memono   in varchar2,
                      v_dteeffec in date,
                      v_criteria in varchar2,
                      v_coduser  in varchar2,
                      v_table    in varchar2,
                      p_filename out varchar2) as
       v_sql        varchar2(4000 char);
       v_num1       number  := 0;
       v_field      varchar2(4000 char);
       v_desc       varchar2(4000 char);
       v_label      varchar2(4000 char);
       v_trpt       varchar2(4000 char);
       v_data       varchar2(4000 char);
       p_codapp     varchar2(4000 char);
       p_coduser    varchar2(4000 char);

        cur         pls_integer;        -- cursor
        x           pls_integer;        -- dummy
        col_cnt     pls_integer;
        dtab        dbms_sql.desc_tab;
        l_anydata   anydata;
        l_vc2       varchar2(32767);
        l_number    number;
        l_vc        varchar(32767);
        l_date      date;
        l_raw       raw(32767);
        l_ch        char;
        l_clob      clob;
        l_blob      blob;
        l_bfile     bfile;
        v_sql1      varchar2(2500);
        v_itemnum   number ;
        v_comp_pos  varchar2(500 char);
        v_codempid  temploy1.codempid%type;

        v_filename  varchar2(100 char);

        v_tab       varchar2(100 char);
        v_col       varchar2(100 char);
        v_func      varchar2(400 char);
        v_flgchksal tcoldesc.flgchksal%type;
        v_chken      varchar2(4 char):= hcm_secur.get_v_chken;

    cursor c2(v_memono varchar2,v_dteeffec date) is
        select rownum,pfield,pdesct,flgdesc
        from tmailrep
        where dteeffec = v_dteeffec
        and   memono     = v_memono
        order by numseq;

   begin
     v_field    := null;
     v_desc     := null;
     v_num1     := 0;

     for prep in c2(v_memono,v_dteeffec) loop

             v_tab   := substr(prep.pfield,1,instr(prep.pfield,'.')-1 )    ;
             v_col   := substr(prep.pfield,instr(prep.pfield,'.')+1 ) ;
             begin
                 select funcdesc , flgchksal
                   into v_func , v_flgchksal
                 from   tcoldesc
                 where  codtable = v_tab
                 and    CODCOLMN = v_col
                 and    rownum = 1 ;
             exception when others then
               v_func       :=  null ;
               v_flgchksal  := null;
             end ;
       if nvl(v_flgchksal,'N') = 'Y' then
              v_col  := 'stddec('||prep.pfield||','||v_tab||'.codempid,'||v_chken||')';
        else
         if nvl(prep.flgdesc,'N') = 'Y' then
             v_col  := prep.pfield ;
             if v_func is not null then
                 v_col  := replace(v_func,'P_CODE', prep.pfield) ;
                 v_col  := replace(v_col,'P_LANG', 102) ;
             end if;
         else
              v_col  := prep.pfield ;
          end if;
      end if;

         v_num1 := v_num1 + 1;
         if prep.rownum = 1 then
            v_field     := v_col||' p1';
            v_desc      := ''''||prep.pdesct||'''';
            v_label     := 'label1';
            v_trpt      := 'item1';
         else
            v_field     := v_field||','||v_col||' p'||v_num1;
            v_desc      := v_desc||','''||prep.pdesct||'''';
            v_label     := v_label||','||'label'||prep.rownum;
            v_trpt      := v_trpt||','||'item'||prep.rownum;
         end if;
     end loop;

     p_codapp   := v_memono;
     p_coduser  := v_coduser;
     if v_field is not null then
          delete from ttempprm where codempid = p_coduser and codapp = p_codapp; commit;
          -------- insert label ------------
          v_sql := 'insert into ttempprm(codempid,codapp,namrep,pdate,ppage,'||v_label||') '||
                       ' values ('''||p_coduser||''','''||p_codapp||''','''||p_codapp||''','||'''DATE/TIME'','' :'','||v_desc||')';
          EXECUTE IMMEDIATE v_sql;
          ----- insert data----------------
          v_sql := 'select '||v_field ||' from '||v_table ||' where '||v_criteria;

          if v_field like '%CODEMPID%' then
              v_itemnum := substr(substr(v_field,instr(v_field,'CODEMPID') + 10),1,instr(substr(v_field,instr(v_field,'CODEMPID') +10),',') -1);
              v_trpt := v_trpt||',item48,item49,item50';
          end if;
              ----------------
          v_num1 := 0;
          cur := dbms_sql.open_cursor;
          dbms_sql.parse(cur,v_sql,dbms_sql.native);
          dbms_sql.describe_columns(cur,col_cnt,dtab);
          for i in 1 .. col_cnt loop

              case dtab(i).col_type
              when 1 then
                  dbms_sql.define_column(cur,i,l_vc2,dtab(i).col_max_len);
              when 2 then
                  dbms_sql.define_column(cur,i,l_number);
              when 9 then
                  dbms_sql.define_column(cur,i,l_vc,dtab(i).col_max_len);
              when 12 then
                  dbms_sql.define_column(cur,i,l_date);
              when 23 then
                  dbms_sql.define_column_raw(cur,i,l_raw,dtab(i).col_max_len);
              when 96 then
                  dbms_sql.define_column_char(cur,i,l_ch,dtab(i).col_max_len);
              when 112 then
                  dbms_sql.define_column(cur,i,l_clob);
              when 113 then
                  dbms_sql.define_column(cur,i,l_blob);
              when 114 then
                  dbms_sql.define_column(cur,i,l_bfile);
              end case;
          end loop;
          x := dbms_sql.execute(cur);

          while dbms_sql.fetch_rows(cur) != 0 loop
              v_data     := null;
              v_codempid := null;
              v_comp_pos := ','''||null||''','''||null||''','''||null||'''';
              for i in 1 .. col_cnt loop

                  if i > 1 then
                     v_data := v_data||',';
                  end if;
                  case dtab(i).col_type
                  when 1 then
                      dbms_sql.column_value(cur,i,l_vc2);
                      l_anydata := ANYDATA.ConvertVarchar2(l_vc2);
                      v_data := v_data||''''||l_vc2||'''';
                       if v_itemnum = i then
                          v_codempid := l_vc2;
                      end if;
                  when 2 then
                      dbms_sql.column_value(cur,i,l_number);
                      l_anydata := ANYDATA.ConvertNumber(l_number);
                      v_data := v_data||''''||l_number||'''';
                  when 9 then
                      dbms_sql.column_value(cur,i,l_vc);
                      l_anydata := ANYDATA.ConvertVarchar(l_vc);
                      v_data := v_data||''''||l_vc||'''';
                  when 12 then
                      dbms_sql.column_value(cur,i,l_date);
                      l_anydata := anydata.convertdate(l_date);
                      v_data := v_data||''''||to_char(l_date,'dd/mm/yyyy')||'''';
                  when 23 then
                      dbms_sql.column_value(cur,i,l_raw);
                      l_anydata := ANYDATA.ConvertRaw(l_raw);
                      v_data := v_data||''''||l_raw||'''';
                  when 96 then
                      dbms_sql.column_value(cur,i,l_ch);
                      l_anydata := ANYDATA.ConvertChar(l_ch);
                      v_data := v_data||''''||l_ch||'''';
                  when 112 then
                      dbms_sql.column_value(cur,i,l_clob);
                      l_anydata := ANYDATA.ConvertClob(l_clob);
                      v_data := v_data||l_clob||'''';
                  end case;
              end loop;
              v_num1 := v_num1 + 1;

              if v_codempid is not null then
                begin
                    select ','''||codempid||''','''||codcompr||''','''||codposre||''''
                    into  v_comp_pos
                    from  temploy1
                    where codempid = v_codempid;
               exception when others then
                    v_comp_pos := ','''||null||''','''||null||''','''||null||'''';
               end;

              end if;
              if v_field like '%CODEMPID%' then
                 v_data := v_data||v_comp_pos;
              end if;
              ----------------


              v_sql1 := 'insert into ttemprpt(codempid,codapp,numseq,'||v_trpt||') '||
                            ' values ('''||p_coduser||''','''||p_codapp||''','||v_num1||','||v_data||')';
              EXECUTE IMMEDIATE v_sql1;
          end loop;
          dbms_sql.close_cursor(cur);
          commit;
--              v_filename := lower(p_codapp||'_'||p_coduser||'.xls');
          v_filename := p_coduser||'_'||to_char(sysdate,'yyyymmddhh24mi');

        --- Gen Excel file ---------
          if v_trpt like '%item48,item49,item50' then
             v_trpt := substr(v_trpt,1,instr(v_trpt,',item48,item49,item50') - 1);
             EXCEL_MAIL(v_trpt,v_label,null,p_coduser,p_codapp,v_filename);
             p_filename := v_filename ;
          end if;
         delete from ttemprpt where codempid = p_coduser and  codapp = p_codapp; commit;
    end if; -- end if of v_field is not null
  end inst_data;

  --STA4-1701||2/11/2017||user39
  function gen_header(p_codempid varchar2) return varchar2
  is
    v_codcomp varchar2(100 char);
    v_codpos  varchar2(100 char);
    v_exist   varchar2(10 char);
    v_head    varchar2(100 char);

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
      v_exist := 'N' ;
      v_head  := null;
      for j in c_temphead1 loop
          v_exist := 'Y' ;
          v_head := j.codempidh;
          exit;
      end loop;

      if v_exist = 'N' then
        begin
          select codcomp,codpos
            into v_codcomp,v_codpos
            from temploy1
           where codempid = p_codempid ;
        exception when no_data_found then null;
        end;
        for j in c_temphead2 loop
          v_head  :=  j.codempidh;
          exit;
        end loop;
      end if;

      return v_head;
    end   gen_header;
--STA4-1701||2/11/2017||user39
 end alertmail;

/

--------------------------------------------------------
--  DDL for Package Body HRPMC2E6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E6" is
-- last update: 17/9/2020 19:15

  function get_numappl(p_codempid varchar2) return varchar2 is
    v_numappl   temploy1.numappl%type;
  begin
    begin
      select  nvl(numappl,codempid)
      into    v_numappl
      from    temploy1
      where   codempid = p_codempid;
    exception when no_data_found then
      v_numappl := p_codempid;
    end;
    return v_numappl;
  end; -- end get_numappl
  --
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    begin
      select  codcomp
      into    work_codcomp
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      null;
    end;
  end; -- end initial_value
  --
  function get_default_value(p_codapp varchar2,p_numpage varchar2,p_table varchar2,p_field varchar2) return varchar2 is
    v_default   varchar2(150 char)  := '';
  begin
    begin
      select  defaultval
      into    v_default
      from    tsetdeflt
      where   codapp      = upper(p_codapp)
      and     numpage     = upper(p_numpage)
      and     tablename   = upper(p_table)
      and     fieldname   = upper(p_field);
    exception when no_data_found then
      null;
    end;
    return v_default;
  end; -- end get_default_value
  --
  function get_desciption (p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 is
    v_desc     varchar2(500):= p_code;
    v_stament  varchar2(500);
    v_funcdesc varchar2(500);
    v_data_type varchar2(500);
  begin
    if p_code is null then
      return v_desc ;
    end if;

    begin
      select  funcdesc,data_type
      into    v_funcdesc,v_data_type
      from    tcoldesc
      where   codtable  = p_table
      and     codcolmn  = p_field
      and     rownum    = 1 ;
    exception when no_data_found then
       v_funcdesc := null;
    end ;

    if v_funcdesc is not null   then
      v_stament   := 'select '||v_funcdesc||'from dual' ;
      v_stament   := replace(v_stament,'P_CODE',''''||p_code||'''') ;
      v_stament   := replace(v_stament,'P_LANG',global_v_lang) ;
      return execute_desc (v_stament) ;
    else
      if v_data_type = 'DATE' then
        if global_v_zyear = 543   then
          return to_char(add_months(to_date(v_desc,'dd/mm/yyyy'),543*12),'dd/mm/yyyy')	   ;
        else
          return to_char(to_date(v_desc,'dd/mm/yyyy'),'dd/mm/yyyy')	   ;
        end if;
      elsif p_field in ('STAYEAR','DTEGYEAR') then
        return v_desc + global_v_zyear;
      else
        return v_desc ;
      end if;
    end if;
  end; -- end get_desciption
  --
  procedure check_alter(json_str_input in clob) is
    json_str            json_object_t;
    v_column_name       user_tab_columns.column_name%type;
    v_char_length       user_tab_columns.char_length%type;
    v_data_precision    user_tab_columns.data_precision%type;
    v_data_scale        user_tab_columns.data_scale%type;
    v_itemtype          tempothd.itemtype%type;
    v_maxlength         number;
    v_max_preci         number;
    v_max_scale         number;
    v_codlist           varchar2(100 char);
    
    v_codlist_data      json_object_t;
    v_codlist_data_row  json_object_t;
    v_cod_value         varchar2(20 char);
    v_stmt              varchar2(2000);
    v_list_used         number;
    v_flgDel            boolean;
  begin
    json_str              := json_object_t(json_str_input);
    v_column_name         := hcm_util.get_string_t(json_str,'column_name');
    v_char_length         := hcm_util.get_string_t(json_str,'char_length');
    v_data_precision      := hcm_util.get_string_t(json_str,'data_precision');
    v_data_scale          := hcm_util.get_string_t(json_str,'data_scale');
    v_itemtype            := hcm_util.get_string_t(json_str,'itemtype');
    v_codlist             := hcm_util.get_string_t(json_str,'codlist');
    v_codlist_data        := hcm_util.get_json_t(json_str,'codlist_data');

    begin
      execute immediate ' select max(length('||v_column_name||')) from tempothr ' into v_maxlength;
    exception when others then
      null;
    end;
    v_maxlength   := nvl(v_maxlength,0);
    if v_itemtype in ('1','4') then -- string, ddl
      if v_maxlength > v_char_length then
        param_msg_error   := get_error_msg_php('PM0091',global_v_lang); --redmine PM-2245
        return;
      end if;
      if v_itemtype = '4' then
        for i in 0..v_codlist_data.get_size - 1 loop
          v_codlist_data_row    := hcm_util.get_json_t(v_codlist_data,to_char(i));
          v_cod_value           := hcm_util.get_string_t(v_codlist_data_row,'value');
          v_flgDel              := hcm_util.get_boolean_t(v_codlist_data_row,'flgDel');
          if v_flgDel then
            v_stmt      := 'select count(*) from tempothr where '||v_column_name||' = '''||v_cod_value||''' ';
            v_list_used := execute_qty(v_stmt);
            if v_list_used > 0 then
              param_msg_error   := get_error_msg_php('PM0090',global_v_lang);
              return;
            end if;
          end if;
        end loop;
      end if;
    elsif v_itemtype = '2' then -- number
      begin
        select  data_precision, data_scale
        into    v_max_preci, v_max_scale
        from    user_tab_columns
        where   table_name    = 'TEMPOTHR'
        and     column_name   = v_column_name;
      exception when no_data_found then
        v_max_preci   := 0;
        v_max_scale   := 0;
      end;
      if (v_max_preci > (v_data_precision + v_data_scale) or v_max_scale > v_data_scale) and v_maxlength > 0 then
        param_msg_error   := get_error_msg_php('HR1440',global_v_lang);
        return;
      end if;
    end if;

    if instr(v_column_name,chr(32)) > 0 then 
        param_msg_error   := get_error_msg_php('PM0142',global_v_lang);
        return;
    end if;


  end; -- end check_alter
  --
  procedure upd_log1
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_fldedit 	in varchar2,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	    in out boolean) is

     v_exist		 boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

    cursor c_ttemlog1 is
      select rowid
      from   ttemlog1
      where  codempid = p_codempid_query
      and		 dteedit	= sysdate
      and		 numpage	= p_numpage
      and    fldedit  = upper(p_fldedit);
  begin
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;
--      if :parameter.codapp in ('PMC2','RECRUIT') then sssssssssssssssssssssssssssssss
        p_upd := true;
        for r_ttemlog1 in c_ttemlog1 loop
          v_exist := true;
          update ttemlog1
          set    codcomp 	= work_codcomp,
                 desold 	= v_desold,
                 desnew 	= v_desnew,
                 flgenc 	= p_flgenc,
                 codtable = upper(p_codtable),
                 dteupd 	= trunc(sysdate),
                 coduser 	= global_v_coduser
          where  rowid = r_ttemlog1.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog1
            (codempid,dteedit,numpage,fldedit,codcomp,
             desold,desnew,flgenc,codtable,dteupd,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,upper(p_fldedit),work_codcomp,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),trunc(sysdate),global_v_coduser);
        end if;
    end if;
  end; -- end upd_log1
  --
  procedure save_tcoldesc is
    v_column_id     tcoldesc.column_id%type;
    v_codcolmn      tcoldesc.codcolmn%type;
    v_funcdesc      tcoldesc.funcdesc%type;
    v_data_type     user_tab_columns.data_type%type;
    v_comment       varchar2(60 char);
    v_table_name    varchar2(100) := 'TEMPOTHR';
    cursor c_cols is
      select  table_name, column_name, comments
      from    user_col_comments
      where   table_name    = v_table_name
      order by table_name,column_name;
  begin
    for r_cols in c_cols loop
      v_codcolmn    := r_cols.column_name;
      v_comment     := substr(r_cols.comments,1,60);
      begin
        select    column_id,data_type
        into      v_column_id,v_data_type
        from      user_tab_columns
        where     table_name    = v_table_name
        and       column_name   = v_codcolmn;
      exception when no_data_found then
        v_column_id     := 0;
        v_data_type     := null;
      end;
      begin
        select    funcdesc into v_funcdesc
        from      treport2
        where     namfld    = v_codcolmn
        and       funcdesc  is not null
        and       rownum    <= 1;
      exception when no_data_found then
        v_funcdesc    := null;
      end;
      begin
        select    codtable
        into      v_table_name
        from      tcoldesc
        where     codtable    = v_table_name
        and       codcolmn    = v_codcolmn;

        update    tcoldesc
        set       column_id   = v_column_id,
                  data_type   = v_data_type,
                  funcdesc    = v_funcdesc
        where     codtable    = v_table_name
        and       codcolmn    = v_codcolmn;
      exception when others then
        insert into tcoldesc(codtable,column_id,codcolmn,descole,descolt,descol3,descol4,descol5,
                             funcdesc,flgchksal,data_type,flgdisp,coduser)
                    values (v_table_name,v_column_id,v_codcolmn,v_comment,v_comment,v_comment,v_comment,v_comment,
                            v_funcdesc,'N',v_data_type,'Y',global_v_coduser);
      end;
    end loop;

    delete  tcoldesc
    where   codtable = v_table_name
    and     codcolmn not in (select   column_name
                              from    user_col_comments
                              where table_name  = v_table_name);
    commit;
  end; -- end save_tcoldesc
  --
  procedure save_treport is
    v_codcolmn    tcoldesc.codcolmn%type;
    v_data_type   varchar2(60 char);
    v_comment     treport2.nambrowe%type;
    v_numseq      number;
    v_numseq2     number    := 1700;
    v_count       number    := 0;
    v_table_name  varchar2(100 char) := 'TEMPOTHR';
    cursor c_cols is
      select    a.table_name,a.column_name,a.comments,b.data_type
      from      user_col_comments a, user_tab_columns b
      where     a.table_name    = b.table_name
      and       a.column_name   = b.column_name
      and       a.table_name    = v_table_name
      and       a.column_name like 'USR%'
      order by b.column_id;
  begin
    if v_table_name in ('TEMPOTHR') then
      delete  treport2
      where   codapp  = 'HRPMA1X'
      and     namtbl  = 'TEMPOTHR'
      and     numseq  > 1700;

      v_numseq2   := 1700;
      for r_cols in c_cols loop
        v_codcolmn    := r_cols.column_name;
        v_comment     := substr(r_cols.comments,1,60);
        begin
          select    data_type
          into      v_data_type
          from      user_tab_columns
          where     table_name    = 'TEMPOTHR'
          and       column_name   = v_codcolmn;
        exception when no_data_found then
          v_data_type    := null;
        end;
        begin
          select    max(numseq) into v_numseq2
          from      treport2
          where     codapp = 'HRPMA1X';
        end;
        v_numseq2   := v_numseq2 + 5;

        insert into treport2(codapp,numseq,namfld,nambrowe,nambrowt,
                              nambrow3,nambrow4,nambrow5,flgdisp,
                              namtbl,datatype)
                      values ('HRPMA1X',v_numseq2,v_codcolmn,v_comment,v_comment,
                              v_comment,v_comment,v_comment,'Y','TEMPOTHR',v_data_type);
        --<<imsert treport
        begin
          select    count(*)
          into      v_count
          from      treport
          where     codtable    = v_table_name
          and       codcolmn    = v_codcolmn;
        end;

        if v_count <> 0 then
          update  treport
          set     descole   = v_comment,
                  descolt   = v_comment,
                  descol3   = v_comment,
                  descol4   = v_comment,
                  descol5   = v_comment,
                  flgchksal = null,
                  coduser   = global_v_coduser
          where   codtable  = v_table_name
          and     codcolmn  = v_codcolmn;
        else
          begin
            select    max(numseq) into v_numseq
            from      treport
            where     codtable    = v_table_name;
          end;

          v_numseq    := nvl(v_numseq,0) + 10;
          v_numseq    := nvl(v_numseq,0) + 10;
          insert into treport(codtable,numseq,codcolmn,descole,
                              descolt,descol3,descol4,descol5,
                              flgchksal,coduser)
                      values (v_table_name,v_numseq,v_codcolmn,v_comment,
                              v_comment,v_comment,v_comment,v_comment,
                              'N',global_v_coduser);
        end if; --v_count <> 0 then
      end loop;

      delete treport
      where codtable = v_table_name
      and   codcolmn not in (select   column_name
                             from     user_col_comments
                             where    table_name    = v_table_name);
      commit;
    end if;
  end; -- end save_treport
  --
  procedure save_tempothd(p_column_name tempothd.column_name%type,
                          p_itemtype    tempothd.itemtype%type,
                          p_codlist     tempothd.codlist%type,
                          p_essstat     tempothd.essstat%type,
                          p_flg         varchar2,
                          p_desclabele  tempothd.desclabele%type,
                          p_desclabelt  tempothd.desclabelt%type,
                          p_desclabel3  tempothd.desclabel3%type,
                          p_desclabel4  tempothd.desclabel4%type,
                          p_desclabel5  tempothd.desclabel5%type ) is
  begin
    if p_flg = 'add' then
      insert into tempothd(column_name,itemtype,codlist,essstat,codcreate,coduser,
                           desclabele,desclabelt,desclabel3,desclabel4,desclabel5 )
                   values (p_column_name,p_itemtype,p_codlist,p_essstat,global_v_coduser,global_v_coduser,
                           p_desclabele,p_desclabelt,p_desclabel3,p_desclabel4,p_desclabel5 );
    elsif p_flg = 'edit' then
      update  tempothd
      set     codlist     = p_codlist,
              essstat     = p_essstat,
              desclabele  = p_desclabele,
              desclabelt  = p_desclabelt,
              desclabel3  = p_desclabel3,
              desclabel4  = p_desclabel4,
              desclabel5  = p_desclabel5,
              coduser     = global_v_coduser
      where   column_name = p_column_name;
    elsif p_flg = 'delete' then
      delete from tempothd where column_name = p_column_name;
    end if;

  end; -- end save_tempothd
  --
  procedure save_tlistval(p_col_name        varchar2,
                          p_codlist         tempothd.column_name%type,
                          v_codlist_data    json_object_t,
                          p_flg             varchar2) is
    v_json_data_rows    json_object_t;
    v_value             tlistval.list_value%type;
    v_desce             tlistval.desc_label%type;
    v_desct             tlistval.desc_label%type;
    v_desc3             tlistval.desc_label%type;
    v_desc4             tlistval.desc_label%type;
    v_desc5             tlistval.desc_label%type;
    v_flg_del           boolean;
  begin
    if p_flg in ('add','edit') then
      delete from tlistval
      where codapp = p_codlist;
      for i in 0..v_codlist_data.get_size-1 loop
        v_json_data_rows      := hcm_util.get_json_t(v_codlist_data,to_char(i));
        v_value               := hcm_util.get_string_t(v_json_data_rows,'value');
        v_desce               := hcm_util.get_string_t(v_json_data_rows,'desc_valuee');
        v_desct               := hcm_util.get_string_t(v_json_data_rows,'desc_valuet');
        v_desc3               := hcm_util.get_string_t(v_json_data_rows,'desc_value3');
        v_desc4               := hcm_util.get_string_t(v_json_data_rows,'desc_value4');
        v_desc5               := hcm_util.get_string_t(v_json_data_rows,'desc_value5');
        v_flg_del             := hcm_util.get_boolean_t(v_json_data_rows,'flgDel');
        if not nvl(v_flg_del,false) then
          insert into tlistval(codapp,codlang,numseq,desc_label,list_value,flgused,coduser)
                       values (p_codlist,'101',(i + 1),v_desce,v_value,null,global_v_coduser);
          insert into tlistval(codapp,codlang,numseq,desc_label,list_value,flgused,coduser)
                       values (p_codlist,'102',(i + 1),v_desct,v_value,null,global_v_coduser);
          insert into tlistval(codapp,codlang,numseq,desc_label,list_value,flgused,coduser)
                       values (p_codlist,'103',(i + 1),v_desc3,v_value,null,global_v_coduser);
          insert into tlistval(codapp,codlang,numseq,desc_label,list_value,flgused,coduser)
                       values (p_codlist,'104',(i + 1),v_desc4,v_value,null,global_v_coduser);
          insert into tlistval(codapp,codlang,numseq,desc_label,list_value,flgused,coduser)
                       values (p_codlist,'105',(i + 1),v_desc5,v_value,null,global_v_coduser);
        end if;
      end loop;
    elsif p_flg = 'delete' then
      delete from tlistval
      where codapp = p_codlist;
    end if;
  end; -- end save_tlistval
  --
  procedure alter_table_tempothr(param_json_table json_object_t) is
    param_json_data_rows      json_object_t;
    v_codlist_data            json_object_t;
    v_column_id               user_tab_columns.column_id%type;
    v_column_name             user_tab_columns.column_name%type;
    v_itemtype                tempothd.itemtype%type;
    v_char_length             user_tab_columns.char_length%type;
    v_data_scale              user_tab_columns.data_scale%type;
    v_data_precision          user_tab_columns.data_precision%type;
    v_scrlabel                tapplscr.desclabele%type;
    v_scrlabele               tapplscr.desclabele%type;
    v_scrlabelt               tapplscr.desclabele%type;
    v_scrlabel3               tapplscr.desclabele%type;
    v_scrlabel4               tapplscr.desclabele%type;
    v_scrlabel5               tapplscr.desclabele%type;
    v_essstat                 tempothd.essstat%type;
    v_codlist                 tempothd.codlist%type;
    v_stmt                    varchar2(500);
    v_flg                     varchar2(20);
    v_table_name              varchar2(100) := 'TEMPOTHR';
    v_flguse                  tlistval.flgused%type;
    v_error_code              varchar2(10);
  begin
    for i in 0..param_json_table.get_size-1 loop
      param_msg_error         := null;
      v_stmt                  := null;
      param_json_data_rows    := hcm_util.get_json_t(param_json_table,to_char(i));
      v_column_id             := hcm_util.get_string_t(param_json_data_rows,'column_id');
      v_column_name           := hcm_util.get_string_t(param_json_data_rows,'column_name');
      v_itemtype              := hcm_util.get_string_t(param_json_data_rows,'itemtype');
      v_char_length           := hcm_util.get_string_t(param_json_data_rows,'char_length');
      v_data_scale            := hcm_util.get_string_t(param_json_data_rows,'data_scale');
      v_data_precision        := hcm_util.get_string_t(param_json_data_rows,'data_precision');
      v_scrlabel              := hcm_util.get_string_t(param_json_data_rows,'desclabel');
      v_scrlabele             := hcm_util.get_string_t(param_json_data_rows,'desclabele');
      v_scrlabelt             := hcm_util.get_string_t(param_json_data_rows,'desclabelt');
      v_scrlabel3             := hcm_util.get_string_t(param_json_data_rows,'desclabel3');
      v_scrlabel4             := hcm_util.get_string_t(param_json_data_rows,'desclabel4');
      v_scrlabel5             := hcm_util.get_string_t(param_json_data_rows,'desclabel5');
      v_codlist               := hcm_util.get_string_t(param_json_data_rows,'codlist');
      v_flg                   := hcm_util.get_string_t(param_json_data_rows,'flg');
      v_essstat               := hcm_util.get_string_t(param_json_data_rows,'essstat');
      v_codlist_data          := hcm_util.get_json_t(param_json_data_rows,'codlist_data');

      if v_flg = 'add' then
        v_column_name   := 'USR_'||v_column_name;
        v_stmt          := ' alter table tempothr add ';
      elsif v_flg = 'edit' then
        v_stmt  := ' alter table tempothr modify ';
      elsif v_flg = 'delete' then
        v_stmt  := ' alter table tempothr drop column '||v_column_name;
      end if;

      if v_flg != 'delete' then
        if v_itemtype in ('1','4') then -- text
          v_stmt  := v_stmt||v_column_name||' varchar2('||v_char_length||' char) ';
        elsif v_itemtype = '2' then -- number
          if nvl(v_data_scale,0) > 0 then
            v_stmt  := v_stmt||v_column_name||' number('||(nvl(v_data_precision,0) + v_data_scale)||','||v_data_scale||') ';
          elsif nvl(v_data_precision,0) > 0 then
            v_stmt  := v_stmt||v_column_name||' number('||v_data_precision||') ';
          else
            v_stmt  := v_stmt||v_column_name||' number ';
          end if;
        elsif v_itemtype = '3' then -- date
          v_stmt  := v_stmt||v_column_name||' date ';
        end if;
      end if;

      begin
        execute immediate v_stmt;
      exception when others then
        param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        v_error_code := substr(param_msg_error,5,5);
        if v_error_code = '01439' then
          param_msg_error   := get_error_msg_php('HR1439',global_v_lang);
        elsif v_error_code = '01440' then
          param_msg_error   := get_error_msg_php('HR1440',global_v_lang);
        elsif v_error_code = '01430' then
          param_msg_error   := get_error_msg_php('HR8518',global_v_lang);
        elsif v_error_code = '01441' then
          param_msg_error   := get_error_msg_php('PM0091',global_v_lang);  --redmine PM-2245
        elsif v_error_code = '01727' then
          param_msg_error   := get_error_msg_php('HR1727',global_v_lang);
        elsif v_error_code = '01728' then
          param_msg_error   := get_error_msg_php('HR1728',global_v_lang);
        elsif v_error_code = '01754' then
          param_msg_error   := get_error_msg_php('HR1754',global_v_lang);
        elsif v_error_code = '00910' then
          param_msg_error   := get_error_msg_php('HR0910',global_v_lang);
        else
          if instr(v_column_name,chr(32)) > 0 then 
            param_msg_error   := get_error_msg_php('PM0142',global_v_lang);
          else
            param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          end if;
        end if;
      end;

      if param_msg_error is null then
        save_tempothd(v_column_name,v_itemtype,v_codlist,v_essstat,v_flg,
                      v_scrlabele,v_scrlabelt,v_scrlabel3,v_scrlabel4,v_scrlabel5);
        if v_codlist is not null then
          save_tlistval(v_column_name,v_codlist,v_codlist_data,v_flg);
        end if;
      end if;
    end loop;
  end; -- alter_table_tempothr
  --
  procedure save_tempothr(param_json_others   json_object_t) is
    v_exist				    boolean := false;
    v_upd					    boolean := false;
    v_numseq          number;
    v_numappl         temploy1.numappl%type;
    param_json_others_row     json_object_t;
    v_column_name     user_tab_columns.column_name%type;
    v_column_value    varchar2(4000 char);
    v_column_type     tempothd.itemtype%type;
    v_base_value      varchar2(4000 char);

    v_stmt_upd        varchar2(4000 char)   := ' ';
    v_col_insert      varchar2(4000 char)   := ' ';
    v_val_insert      varchar2(4000 char)   := ' ';
    cursor c1 is
      select  '1'
      from    tempothr
      where   numappl   = v_numappl;
  begin
    v_numappl     := get_numappl(p_codempid_query);
    for r1 in c1 loop
      v_exist   := true;
      exit;
    end loop;
    for i in 0..param_json_others.get_size-1 loop
      param_json_others_row   := hcm_util.get_json_t(param_json_others,to_char(i));
      v_column_name   := hcm_util.get_string_t(param_json_others_row,'column_name');
      v_column_value  := hcm_util.get_string_t(param_json_others_row,'column_value');
      v_column_type   := hcm_util.get_string_t(param_json_others_row,'itemtype');
      v_base_value        := null;

      if v_column_type in ('1','4') then -- 1 = text, 4 = dropdown
        begin
          execute immediate ' select '||v_column_name||' from tempothr where numappl = '''||v_numappl||''' ' INTO v_base_value;
        exception when others then
          v_base_value    := null;
        end;
        upd_log1('tempothr','61',v_column_name,'C',v_base_value,v_column_value,'N',v_upd);
        v_stmt_upd       := v_stmt_upd||v_column_name||' = '''||v_column_value||''',';
        v_col_insert     := v_col_insert||v_column_name||',';
        v_val_insert     := v_val_insert||''''||v_column_value||''',';
      elsif v_column_type in ('2') then -- 2 = number
        begin
          execute immediate ' select '||v_column_name||' from tempothr where numappl = '''||v_numappl||''' ' INTO v_base_value;
        exception when others then
          v_base_value    := null;
        end;
        upd_log1('tempothr','61',v_column_name,'N',v_base_value,v_column_value,'N',v_upd);
        v_stmt_upd       := v_stmt_upd||v_column_name||' = '''||to_char(v_column_value)||''',';
        v_col_insert     := v_col_insert||v_column_name||',';
        v_val_insert     := v_val_insert||''''||v_column_value||''',';
      elsif v_column_type in ('3') then -- 3 = date
        begin
          execute immediate ' select to_char('||v_column_name||',''dd/mm/yyyy'') from tempothr where numappl = '''||v_numappl||''' ' INTO v_base_value;
        exception when others then
          v_base_value    := null;
        end;
        upd_log1('tempothr','61',v_column_name,'D',v_base_value,v_column_value,'N',v_upd);
        v_stmt_upd       := v_stmt_upd||v_column_name||' = to_date('''||v_column_value||''',''dd/mm/yyyy''),';
        v_col_insert     := v_col_insert||v_column_name||',';
        v_val_insert     := v_val_insert||'to_date('''||v_column_value||''',''dd/mm/yyyy''),';
      end if;
    end loop;
    if v_exist then
      if v_upd then
        execute immediate ' update tempothr set '||v_stmt_upd||'coduser = '''||global_v_coduser||''' where numappl = '''||v_numappl||'''';
      end if;
    else
      execute immediate ' insert into tempothr(numappl,codempid,'||v_col_insert||'codcreate,coduser)
                                       values ('''||v_numappl||''','''||p_codempid_query||''','||v_val_insert||''''||global_v_coduser||''','''||global_v_coduser||''') ';
    end if;
  end; -- end save_tempothr
  --
  procedure get_others_table(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_others_table(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_others_table
  --
  procedure get_flg_secure(json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    v_flg_secure    varchar2(10)  := 'N';
  begin
    initial_value(json_str_input);
    begin
      select  decode(typeuser,'4','Y','N')
      into    v_flg_secure
      from    tusrprof
      where   coduser   = global_v_coduser;
    exception when no_data_found then
      v_flg_secure  := 'N';
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('flgsecure',v_flg_secure);

    dbms_lob.createtemporary(json_str_output, true);
    obj_data.to_clob(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_others_table
  --
  procedure gen_others_table(json_str_output out clob) is
    obj_row               json_object_t;
    obj_data              json_object_t;
    obj_row_codlist       json_object_t;
    obj_data_codlist      json_object_t;

    v_rowcnt              number;
    v_rowcnt_codlist      number;

    v_numappl             temploy1.numappl%type;
    v_value               varchar2(4000 char);
    v_codapp              tlistval.codapp%type;
    v_colist_flgused      tlistval.flgused%type;
    v_exists                varchar2(1) := 'N';
    v_flg_delete           varchar2(1) := 'N';

    cursor c1 is
      -- itemtype 1 = Text, 2 = Number, 3 = Date, 4 = Dropdown List
      select  tusr.column_id, toth.column_name, toth.itemtype,
              tusr.char_length, tusr.data_scale, (tusr.data_precision - tusr.data_scale) as data_precision,toth.codlist,
              desclabele,desclabelt,desclabel3,desclabel4,desclabel5,
              decode(global_v_lang,'101',desclabele
                                  ,'102',desclabelt
                                  ,'103',desclabel3
                                  ,'104',desclabel4
                                  ,'105',desclabel5) as  desclabel,
              toth.essstat
      from    user_tab_columns tusr, tempothd toth, user_col_comments cmm
      where   tusr.table_name          = 'TEMPOTHR'
      and     tusr.column_name         like 'USR_%'
      and     tusr.column_name         = toth.column_name
      and     tusr.table_name          = cmm.table_name(+)
      and     tusr.column_name         = cmm.column_name(+)
      order by tusr.column_id;

    cursor c_tlistval is
      select  codapp,numseq,list_value,
              get_tlistval_name(codapp,list_value,global_v_lang) as desc_value,
              max(decode(codlang,'101',desc_label)) as desc_valuee,
              max(decode(codlang,'102',desc_label)) as desc_valuet,
              max(decode(codlang,'103',desc_label)) as desc_value3,
              max(decode(codlang,'104',desc_label)) as desc_value4,
              max(decode(codlang,'105',desc_label)) as desc_value5
      from    tlistval
      where   codapp      = v_codapp
      and     list_value  is not null
      group by codapp,numseq,list_value
      order by numseq;
  begin
    obj_row       := json_object_t();
    v_rowcnt      := 0;
    v_numappl     := get_numappl(p_codempid_query);

    begin
      select  'Y'
      into    v_exists
      from    tempothr
      where   numappl     = v_numappl;
    exception when no_data_found then
      v_exists  := 'N';
    end;

    for i in c1 loop
      obj_data          := json_object_t();
      obj_row_codlist   := json_object_t();
      v_value           := null;
      v_rowcnt          := v_rowcnt + 1;
      v_rowcnt_codlist  := 0;
      v_codapp          := i.codlist;

      if v_exists = 'Y' then
        begin
          if i.itemtype = '3' then
            execute immediate ' select to_char('||i.column_name||',''dd/mm/yyyy'') from tempothr where numappl = '''||v_numappl||''' ' INTO v_value;
          else
            execute immediate ' select '||i.column_name||' from tempothr where numappl = '''||v_numappl||''' ' INTO v_value;
          end if;
        exception when others then
          v_value   := '';
        end;
      else
        begin
          select  defaultval
          into    v_value
          from    tsetdeflh h, tsetdeflt d
          where   h.codapp            = 'HRPMC2E6'
          and     h.numpage           = 'HRPMC2E6'
          and     d.tablename         = 'TEMPOTHR'
          and     nvl(h.flgdisp,'Y')  = 'Y'
          and     h.codapp            = d.codapp
          and     h.numpage           = d.numpage
          and     d.fieldname         = i.column_name
          and     rownum  = 1;
        exception when no_data_found then
          v_value   := '';
        end;
      end if;

      begin
        select  'Y'
        into    v_colist_flgused
        from    tlistval
        where   codapp            = i.codlist
        and     nvl(flgused,'N')  = 'Y'
        and     rownum            = 1;
      exception when no_data_found then
        v_colist_flgused    := 'N';
      end;

      obj_data.put('coderror','200');
      obj_data.put('column_id',i.column_id);
      obj_data.put('column_name',i.column_name);
      obj_data.put('column_value',v_value);
      obj_data.put('itemtype',i.itemtype);
      obj_data.put('desc_itemtype',get_tlistval_name('ITEMTYPE',i.itemtype,global_v_lang));
      if i.itemtype in ('1','4') then
        obj_data.put('data_length',i.char_length);
      elsif i.itemtype = '2' and i.data_precision is not null and i.data_scale is not null then
        obj_data.put('data_length','('||i.data_precision||', '||i.data_scale||')');
      end if;
      obj_data.put('char_length',i.char_length);
      obj_data.put('data_scale',nvl(i.data_scale,'2'));
      obj_data.put('data_precision',nvl(i.data_precision,'22'));
      obj_data.put('codlist',i.codlist);
      for j in c_tlistval loop
        obj_data_codlist    := json_object_t();
        v_rowcnt_codlist    := v_rowcnt_codlist + 1;

        obj_data_codlist.put('value',j.list_value);
        obj_data_codlist.put('desc_value',j.desc_value);
        obj_data_codlist.put('desc_valuee',j.desc_valuee);
        obj_data_codlist.put('desc_valuet',j.desc_valuet);
        obj_data_codlist.put('desc_value3',j.desc_value3);
        obj_data_codlist.put('desc_value4',j.desc_value4);
        obj_data_codlist.put('desc_value5',j.desc_value5);
        obj_row_codlist.put(to_char(v_rowcnt_codlist - 1),obj_data_codlist);
      end loop;
      obj_data.put('codlist_data',obj_row_codlist);
      obj_data.put('codlist_flgused',v_colist_flgused);
      obj_data.put('desclabel',i.desclabel);
      obj_data.put('desclabele',i.desclabele);
      obj_data.put('desclabelt',i.desclabelt);
      obj_data.put('desclabel3',i.desclabel3);
      obj_data.put('desclabel4',i.desclabel4);
      obj_data.put('desclabel5',i.desclabel5);
      obj_data.put('flg_query','Y');
      obj_data.put('essstat',i.essstat);
      obj_data.put('desc_essstat',get_tlistval_name('ESSSTAT',i.essstat,global_v_lang));

--<<redmine PM-2246
      begin
         execute immediate ' select ''N'' from tempothr where '||i.column_name||' is not null and rownum = 1' INTO v_flg_delete;
      exception when others then
            v_flg_delete   := 'Y';
      end;
      obj_data.put('flg_delete',v_flg_delete);  --N-cannot Delete (disable icon Trash) ,Y-can Delete
-->>redmine PM-2246

      obj_row.put(to_char(v_rowcnt - 1), obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- end gen_others_table
  --
  procedure get_submit_alter(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_alter(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_col
  --
  procedure get_popup_change_others(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_others(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_popup_change_others
  --
  procedure gen_popup_change_others(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    json_obj      json_object_t;
    v_rcnt        number  := 0;
    v_numpage     varchar2(100);
    v_dteempmt    date;

    cursor c1 is
      select  '1' typedit,codempid,dteedit,numpage,fldedit,null as typkey,null as fldkey,
              desold,desnew,flgenc,codtable,coduser,null codedit
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '2' typedit,codempid,dteedit,numpage,fldedit,typkey,fldkey,
              desold,desnew,flgenc,codtable,coduser,
              decode(typkey,'N',to_char(numseq),
                            'C',codseq,
                            'D',to_char(dteseq,'dd/mm/yyyy'),null) as codedit
      from    ttemlog2
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '3' typedit,codempid,dteedit,numpage,typdeduct as fldedit,null as typkey,null as fldkey,
              desold,desnew,'Y' flgenc,codtable,coduser,coddeduct codedit
      from    ttemlog3
      where   codempid = p_codempid_query
      and     numpage = v_numpage
      order by dteedit desc,codedit;
  begin
    json_obj        := json_object_t(json_str_input);
    v_numpage       := hcm_util.get_string_t(json_obj,'numpage');
    obj_row         := json_object_t();

    begin
      select  dteempmt into v_dteempmt
      from    temploy1
      where   codempid  = p_codempid_query;
		exception when no_data_found then
			v_dteempmt  := null;
		end;

    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('typedit',i.typedit);
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteedit',to_char(i.dteedit,'dd/mm/yyyy hh24:mi:ss'));
      obj_data.put('numpage',i.numpage);
      obj_data.put('fldedit',i.fldedit);
      if i.typedit = '3' then
        obj_data.put('data1',get_tlistval_name('TYPEDEDUCT',i.fldedit,global_v_lang));
        obj_data.put('data2',get_tcodeduct_name(i.codedit,global_v_lang));
      else
        if i.fldedit = 'DTEDUEPR' then
          obj_data.put('data1','ctrl_label4.di_v150');
        else
          obj_data.put('data1',get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang));
        end if;
        obj_data.put('data2',i.codedit);
      end if;
      obj_data.put('typkey',i.typkey);
      obj_data.put('fldkey',i.fldkey);
      if i.flgenc = 'Y' then
        obj_data.put('desold',to_char(stddec(i.desold,p_codempid_query,global_v_chken),'999,999,990.00'));
        obj_data.put('desnew',to_char(stddec(i.desnew,p_codempid_query,global_v_chken),'999,999,990.00'));
      else
        if i.fldedit = 'DTEDUEPR' then
          if i.desold is not null then
            obj_data.put('desold',(add_months(to_date(i.desold,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
          if i.desnew is not null then
            obj_data.put('desnew',(add_months(to_date(i.desnew,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
        else
          obj_data.put('desold',get_desciption (i.codtable,i.fldedit,i.desold));
          obj_data.put('desnew',get_desciption (i.codtable,i.fldedit,i.desnew));
        end if;
      end if;
      obj_data.put('flgenc',i.flgenc);
      obj_data.put('codtable',i.codtable);
      obj_data.put('coduser',i.coduser);
      obj_data.put('codedit',i.codedit);
      obj_data.put('exphighli',get_tsetup_value('SET_HIGHLIGHT'));
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  end; -- gen_popup_change_others
  --
  procedure alter_table(json_str_input in clob, json_str_output out clob) is
    param_json                json_object_t;
    param_json_table          json_object_t;
    param_json_listval        json_object_t;
    param_json_listval_rows   json_object_t;
  begin
    initial_value(json_str_input);
    param_json           := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));

    alter_table_tempothr(param_json);
    save_tcoldesc;
    save_treport;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_talent
  --
  procedure save_others_data(json_str_input in clob, json_str_output out clob) is
    param_json              json_object_t;
    param_json_others       json_object_t;
  begin
    initial_value(json_str_input);
    param_json  := json_object_t(json_str_input);
    param_json_others  := hcm_util.get_json_t(param_json,'json_input_str');
    param_json_others  := hcm_util.get_json_t(param_json_others,'rows');
    

    save_tempothr(param_json_others);

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_others_data
  --
end;

/

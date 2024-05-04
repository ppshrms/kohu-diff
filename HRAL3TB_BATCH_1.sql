--------------------------------------------------------
--  DDL for Package Body HRAL3TB_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3TB_BATCH" is
  procedure delete_directory_file(p_directory varchar2) is
      cursor c1 is
          select * from table(RDSADMIN.RDS_FILE_UTIL.LISTDIR(p_directory)) order by mtime;
  begin
      for r1 in c1 loop
          if r1.type = 'file' then
              utl_file.fremove(p_directory,r1.filename);
          end if;
      end loop;
  end;

  procedure import_data is
    v_file        varchar2(100);
    v_error       varchar2(10);
    v_path_move	  varchar2(200);

    v_atmpathfrom   tsetup.value%type;
    v_atmpathto     tsetup.value%type;
    v_atmpatherr    tsetup.value%type;
    v_atmpathtemp   tsetup.value%type;
    v_atmflag       tsetup.value%type;
    v_atmflgabs     tsetup.value%type;
    v_atmflgabs1    tsetup.value%type;
    v_atmflgabs2    tsetup.value%type;
    v_atmflgabs3    tsetup.value%type;
    v_atmflgabs4    tsetup.value%type;
    v_atmflgabs5    tsetup.value%type;
    v_atmflgyear    tsetup.value%type;
    v_amttimtran    tsetup.value%type;
    v_yre           number;
    v_ext           tsetup.value%type;
    v_sysplat       varchar2(100 char);
    v_task_id_1     varchar2(100 char);
    v_task_id_2     varchar2(100 char);
    v_file_exists   boolean;
    v_dteupd        varchar2(100 char);
    v_basename      tsetup.value%type;

    cursor c_ttexttrn is
      select typmatch,pathfrom,pathto,patherror
        from ttexttrn
    order by typmatch;

    cursor c_files is
      select filename
        from tfilelist
       where codapp   = p_codapp
         and coduser  = p_coduser_auto
    order by filename;

  begin
    delete tfilelist where codapp = p_codapp and coduser = p_coduser_auto; commit;
    p_sysdate  := sysdate;
    v_sysplat := get_tsetup_value('SYSPLATFORM');
    v_basename := get_tsetup_value('LBASENAME');
    begin
      select get_tsetup_value('atmfileext') into v_ext
        from dual;
      if v_ext is null then
        v_ext := '.txt';
      end if;
    exception when no_data_found then
      v_ext := '.txt';
    end;

    -- get last datetime of sync time from s3
    v_dteupd := get_tsetup_value('AL3TB_DTEUPD');

    for r1 in c_ttexttrn loop
      if v_basename is not null then
        v_atmpathfrom := 'UTL_FILE_DIR_'||v_basename||'_'||r1.typmatch||'_1';
        v_atmpathto   := 'UTL_FILE_DIR_'||v_basename||'_'||r1.typmatch||'_2';
        v_atmpatherr  := 'UTL_FILE_DIR_'||v_basename||'_'||r1.typmatch||'_3';
      else
        v_atmpathfrom := 'UTL_FILE_DIR_'||r1.typmatch||'_1';
        v_atmpathto   := 'UTL_FILE_DIR_'||r1.typmatch||'_2';
        v_atmpatherr  := 'UTL_FILE_DIR_'||r1.typmatch||'_3';
      end if;
      if r1.pathfrom is not null then
        begin
          delete_directory_file(v_atmpathto);
          delete_directory_file(v_atmpatherr);

          p_coduser_auto := 'AT_'||r1.typmatch||'_'||to_char(sysdate,'hh24mi');
          if lower(v_sysplat) <> 'aws' then
            get_dir_list(r1.pathfrom,p_coduser_auto,p_codapp);
          else
            get_dir_list_aws(get_tsetup_value('AL3TB_S3_BUCKET'),r1.pathfrom,v_atmpathfrom,p_coduser_auto,p_codapp,v_dteupd);
          end if;

          v_file_exists := false;
          for i_file in c_files loop
            if lower(i_file.filename) like '%'||v_ext then
              v_file_exists := true;
              v_file := i_file.filename;
              p_path_file := v_atmpathfrom;
              begin
                import_text(v_file,v_error,r1.typmatch);
                commit;
              exception when others then
                v_error := 'ErrIm';
                goto error_point;
              end;
              v_path_move := v_atmpathto;
              cal_tattence(r1.typmatch);
              commit;
              <<error_point>>
              null;
              if v_error is not null then
                v_path_move := v_atmpatherr;
              end if;

              utl_file.fcopy( p_path_file,v_file,v_path_move,v_file,1,null);
              if lower(v_sysplat) <> 'aws' then -- don't remove until find solution for remove file in S3
                utl_file.fremove(p_path_file, v_file);
              end if;
            end if; --if i_file.filename like '%'||v_ext
          end loop; --for i_file in c_files

          if lower(v_sysplat) = 'aws' and v_file_exists then
            -- upload file to s3
            v_task_id_1 :=  rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
                              p_bucket_name    =>  get_tsetup_value('AL3TB_S3_BUCKET'),
                              p_prefix         =>  '',
                              p_s3_prefix      =>  r1.pathto, -- folder in S3
                              p_directory_name =>  v_atmpathto
                            );
            v_task_id_2 :=  rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
                              p_bucket_name    =>  get_tsetup_value('AL3TB_S3_BUCKET'),
                              p_prefix         =>  '',
                              p_s3_prefix      =>  r1.patherror, -- folder in S3
                              p_directory_name =>  v_atmpatherr
                            );
           end if;
        exception when others then null;
        end;
      end if;
    end loop; -- for r1 in c_ttexttrn loop

    -- update last datetime of sync time from s3
    begin
      update tsetup
         set value = to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')
       where codvalue = 'AL3TB_DTEUPD';
    exception when others then
      null;
    end;
    --
    cal_tlateabs;
    commit;
    --
    begin
      delete tautolog where codapp = p_codapp and dtecall = p_sysdate;

      insert into tautolog(codapp,dtecall,dteprost,dteproen,status,remark,coduser)
            values(p_codapp,p_sysdate,p_sysdate,sysdate,'C',null,p_coduser_auto);
    end;
    commit;
  end;
  ----
  procedure import_text (p_filename in varchar2,p_error out varchar2,p_typmatch varchar2) is
    in_file         utl_file.file_type;
    linebuf         varchar2(32767);
    v_text          varchar2(4000);
    v_codempid      temploy1.codempid%type;
    v_codbadge      tatmfile.codbadge%type;
    v_codrecod      tatmfile.codrecod%type;
    v_date          tatmfile.dtedate%type;
    v_time          tatmfile.timtime%type;
    v_mchno         tatmfile.mchno%type;
    v_dtetime       tatmfile.dtetime%type;
    v_day           varchar2(2);
    v_month         varchar2(2);
    v_year          varchar2(4);
    v_hour          varchar2(2);
    v_min           varchar2(2);
    v_codest        ttexttrn.codest%type;
    v_codeen        ttexttrn.codeen%type;
    v_flagst        ttexttrn.flagst%type;
    v_flagen        ttexttrn.flagen%type;
    v_dayst         ttexttrn.dayst%type;
    v_dayen         ttexttrn.dayen%type;
    v_monthst       ttexttrn.monthst%type;
    v_monthen       ttexttrn.monthen%type;
    v_yearst        ttexttrn.yearst%type;
    v_yearen        ttexttrn.yearen%type;
    v_hourst        ttexttrn.hourst%type;
    v_houren        ttexttrn.houren%type;
    v_minst         ttexttrn.minst%type;
    v_minen         ttexttrn.minen%type;
    v_mchnost       ttexttrn.mchnost%type;
    v_mchnoen       ttexttrn.mchnoen%type;
    v_flgfound      boolean;
    v_filename      varchar2(200);

    cursor c_tatmfile is
      select codbadge,dtetime,flgtranal,rowid
        from tatmfile
       where codbadge = v_codbadge
         and dtetime  = v_dtetime;

    cursor c_tempcard is
      select numcard,dtestrt,dteend,codempid,dtereturn
        from tempcard
       where numcard  = v_codbadge
         and dtestrt <= v_date
    order by dtestrt desc;

  begin
      p_error := null;
      begin
          select codest,codeen,flagst,flagen,dayst,dayen,monthst,monthen,
                 yearst,yearen,hourst,houren,minst,minen,mchnost,mchnoen
          into   v_codest,v_codeen,v_flagst,v_flagen,v_dayst,v_dayen,v_monthst,v_monthen,
                 v_yearst,v_yearen,v_hourst,v_houren,v_minst,v_minen,v_mchnost,v_mchnoen
          from   ttexttrn
          where  typmatch = p_typmatch;
      exception when no_data_found then
         return;
      end;

      v_filename := p_filename;
      in_file    := utl_file.fopen(p_path_file,v_filename,'R',32767);
      loop
       utl_file.get_line(in_file,linebuf,32767);
       v_text := linebuf; -- user22 : 09/02/2016 : STA3590210 || v_text := ltrim(rtrim(linebuf));
       begin
        if v_text is not null then
          v_codbadge := upper(rtrim(substr(v_text,v_codest,((v_codeen - v_codest) + 1))));
          if v_flagst > 0 then
            v_codrecod := substr(v_text,v_flagst,((v_flagen - v_flagst) + 1));
          else
            v_codrecod := null;
          end if;
          v_day			 := lpad(substr(v_text,v_dayst,((v_dayen - v_dayst) + 1)),2,'0');
          v_month		 := lpad(substr(v_text,v_monthst,((v_monthen - v_monthst) + 1)),2,'0');
          if ((v_yearen  - v_yearst) + 1) = 2 then
            if to_number(lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0')) < 30 then
              v_year := '20'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
            else
              v_year := '25'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
            end if;
          else
            v_year   := lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),4,'0');
          end if;
          if to_number(v_year) < 2500 then
            v_year   := to_char(to_number(v_year) + v_zyear);
          else
            if v_zyear = 0 then
              v_year := to_char(to_number(v_year) - 543);
            end if;
          end if;
          v_hour		 := lpad(substr(v_text,v_hourst,((v_houren  - v_hourst) + 1)),2,'0');
          v_min			 := lpad(substr(v_text,v_minst,((v_minen   - v_minst) + 1)),2,'0');
          if v_mchnost > 0 then
            v_mchno	 := substr(v_text,v_mchnost,((v_mchnoen - v_mchnost) + 1));
          else
            v_mchno	 := null;
          end if;
          v_date     := to_date(v_day||'/'||v_month||'/'||v_year,'dd/mm/yyyy');
          v_time		 := v_hour||v_min;
          v_dtetime  := to_date(to_char(v_date,'dd/mm/yyyy')||v_time,'dd/mm/yyyyhh24mi');
          v_codempid := substr(v_codbadge,1,10);

          for r_tempcard in c_tempcard loop
            if (v_date between r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend)) or
               (v_date >= r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend) is null) then
              v_codempid := r_tempcard.codempid;
              exit;
            end if;
          end loop;
          v_flgfound  := false;
          for r_tatmfile in c_tatmfile loop
            v_flgfound := true;
            if r_tatmfile.flgtranal = 'N' then
              update tatmfile set codrecod = v_codrecod,
                                  codempid = v_codempid,
                                  mchno    = v_mchno,
                                  typmatch = p_typmatch,
                                  coduser  = p_coduser_auto
              where rowid = r_tatmfile.rowid;
            end if;
          end loop;
          if not v_flgfound then
            insert into tatmfile(codbadge,dtetime,codrecod,dtedate,timtime,flgtranal,codempid,mchno,typmatch,codcreate,coduser)
                        values(v_codbadge,v_dtetime,v_codrecod,v_date,v_time,'N',v_codempid,v_mchno,p_typmatch,p_coduser_auto,p_coduser_auto);
          end if;
        end if; -- v_text is not null
      exception	 when others then
        begin
          v_date     := to_date(v_day||'/'||v_month||'/'||v_year,'dd/mm/yyyy');
          begin
            v_dtetime  := to_date(to_char(v_date,'dd/mm/yyyy')||v_time,'dd/mm/yyyyhh24mi');
          exception when others then
            p_error  := 'HR2047';
          end;
        exception when others then
          p_error  := 'HR2047';
        end;
        -- p_error  := sqlerrm;
        p_error  := sqlerrm;
      end;
    end loop;
    exception when no_data_found then
      utl_file.fclose(in_file);
    when others then
      p_error  := sqlerrm;
      utl_file.fclose(in_file);
  end;
  ----

  procedure import_text_file(json_str_input in clob,
                             p_typmatch     varchar2,
                             p_coduser      varchar2,
                             p_error        out varchar2,
                             p_sumtrn       out varchar2,
                             p_sumerr       out varchar2,
                             p_text         out data_error_array,
                             p_numseq       out data_error_array) is  -- user3 : 28/06/2018
    v_text          varchar2(4000);
    v_cnt           number := 0;
    v_codempid      temploy1.codempid%type;
    v_codbadge      tatmfile.codbadge%type;
    v_codrecod      tatmfile.codrecod%type;
    v_date          tatmfile.dtedate%type;
    v_time          tatmfile.timtime%type;
    v_mchno         tatmfile.mchno%type;
    v_dtetime       tatmfile.dtetime%type;
    v_day           varchar2(2);
    v_month         varchar2(2);
    v_year          varchar2(4);
    v_hour          varchar2(2);
    v_min           varchar2(2);
    v_codest        ttexttrn.codest%type;
    v_codeen        ttexttrn.codeen%type;
    v_flagst        ttexttrn.flagst%type;
    v_flagen        ttexttrn.flagen%type;
    v_dayst         ttexttrn.dayst%type;
    v_dayen         ttexttrn.dayen%type;
    v_monthst       ttexttrn.monthst%type;
    v_monthen       ttexttrn.monthen%type;
    v_yearst        ttexttrn.yearst%type;
    v_yearen        ttexttrn.yearen%type;
    v_hourst        ttexttrn.hourst%type;
    v_houren        ttexttrn.houren%type;
    v_minst         ttexttrn.minst%type;
    v_minen         ttexttrn.minen%type;
    v_mchnost       ttexttrn.mchnost%type;
    v_mchnoen       ttexttrn.mchnoen%type;
    v_flgfound      boolean;
    v_filename      varchar2(200);
    v_str           varchar2(4000);
    v_data_json     json_object_t;
    param_json      json_object_t;
    --
    cursor c_tatmfile is
      select codbadge,dtetime,flgtranal,rowid
        from tatmfile
       where codbadge = v_codbadge
         and dtetime  = v_dtetime;

    cursor c_tempcard is
      select numcard,dtestrt,dteend,codempid,dtereturn
        from tempcard
       where numcard  = v_codbadge
         and dtestrt <= v_date
    order by dtestrt desc;

  begin
    p_text   := new data_error_array();
    p_numseq := new data_error_array();
    p_error  := null;
    begin
        select codest,codeen,flagst,flagen,dayst,dayen,monthst,monthen,
               yearst,yearen,hourst,houren,minst,minen,mchnost,mchnoen
        into   v_codest,v_codeen,v_flagst,v_flagen,v_dayst,v_dayen,v_monthst,v_monthen,
               v_yearst,v_yearen,v_hourst,v_houren,v_minst,v_minen,v_mchnost,v_mchnoen
        from   ttexttrn
        where  typmatch = p_typmatch;
    exception when no_data_found then null;
       return;
    end;
    --
    p_sumtrn := 0;
    p_sumerr := 0;
    --
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    v_data_json  := hcm_util.get_json_t(param_json,'p_filename');
    -- get data row from json --
    for i in 0..v_data_json.get_size-1 loop
       v_text := hcm_util.get_string_t(v_data_json,to_char(i));
       v_cnt  := v_cnt + 1;
       begin
        if v_text is not null then
          v_codbadge := upper(rtrim(substr(v_text,v_codest,((v_codeen - v_codest) + 1))));
          if v_flagst > 0 then
            v_codrecod := substr(v_text,v_flagst,((v_flagen - v_flagst) + 1));
          else
            v_codrecod := null;
          end if;
          v_day			 := lpad(substr(v_text,v_dayst,((v_dayen - v_dayst) + 1)),2,'0');
          v_month		 := lpad(substr(v_text,v_monthst,((v_monthen - v_monthst) + 1)),2,'0');
          if ((v_yearen  - v_yearst) + 1) = 2 then
            if to_number(lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0')) < 30 then
              v_year := '20'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
            else
              v_year := '25'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
            end if;
          else
            v_year   := lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),4,'0');
          end if;
          if to_number(v_year) < 2500 then
            v_year   := to_char(to_number(v_year) + v_zyear);
          else
            if v_zyear = 0 then
              v_year := to_char(to_number(v_year) - 543);
            end if;
          end if;
          v_hour		 := lpad(substr(v_text,v_hourst,((v_houren  - v_hourst) + 1)),2,'0');
          v_min			 := lpad(substr(v_text,v_minst,((v_minen   - v_minst) + 1)),2,'0');
          if v_mchnost > 0 then
            v_mchno	 := substr(v_text,v_mchnost,((v_mchnoen - v_mchnost) + 1));
          else
            v_mchno	 := null;
          end if;
          v_date     := to_date(v_day||'/'||v_month||'/'||v_year,'dd/mm/yyyy');
          v_time		 := v_hour||v_min;
          v_dtetime  := to_date(to_char(v_date,'dd/mm/yyyy')||v_time,'dd/mm/yyyyhh24mi');
          v_codempid := substr(v_codbadge,1,10);
          for r_tempcard in c_tempcard loop
            if (v_date between r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend)) or
               (v_date >= r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend) is null) then
              v_codempid := r_tempcard.codempid;
              exit;
            end if;
          end loop;

          v_flgfound  := false;
          for r_tatmfile in c_tatmfile loop
            v_flgfound := true;
            if r_tatmfile.flgtranal = 'N' then
              update tatmfile
                 set codrecod = v_codrecod,
                     codempid = v_codempid,
                     mchno    = v_mchno,
                     typmatch = p_typmatch,
                     coduser  = p_coduser
               where rowid = r_tatmfile.rowid;
              p_sumtrn := p_sumtrn + 1;
            end if;
          end loop;
          if not v_flgfound then
            insert into tatmfile(codbadge,dtetime,codrecod,dtedate,timtime,flgtranal,codempid,mchno,typmatch,codcreate,coduser)
                          values(v_codbadge,v_dtetime,v_codrecod,v_date,v_time,'N',v_codempid,v_mchno,p_typmatch,p_coduser,p_coduser);
            p_sumtrn := p_sumtrn + 1;
          end if;
        end if; -- v_text is not null
      exception	 when others then
          p_text.extend;
          p_numseq.extend;
          -- return array --
          p_sumerr            := p_sumerr + 1;
          p_text(p_sumerr)    := v_text;
          p_numseq(p_sumerr)  := v_cnt;
          begin
            v_date     := to_date(v_day||'/'||v_month||'/'||v_year,'dd/mm/yyyy');
            begin
              v_dtetime  := to_date(to_char(v_date,'dd/mm/yyyy')||v_time,'dd/mm/yyyyhh24mi');
            exception when others then
              p_error  := 'HR2047';
            end;
          exception when others then
            p_error  := 'HR2047';
          end;
          -- p_error  := sqlerrm;
      end;
    end loop;
  exception when no_data_found then
    null;
  when others then
    p_error  := sqlerrm;
  end import_text_file;

  procedure import_text_json (json_str_input in clob,p_error out varchar2,p_sumtrn out varchar2,p_sumerr out varchar2,p_typmatch varchar2) is
    param_json      json;
    param_json_row  json;
    linebuf         varchar2(32767);
    v_text          varchar2(4000);
    v_codempid      temploy1.codempid%type;
    v_codbadge      tatmfile.codbadge%type;
    v_codrecod      tatmfile.codrecod%type;
    v_date          tatmfile.dtedate%type;
    v_time          tatmfile.timtime%type;
    v_mchno         tatmfile.mchno%type;
    v_dtetime       tatmfile.dtetime%type;
    v_day           varchar2(2);
    v_month         varchar2(2);
    v_year          varchar2(4);
    v_hour          varchar2(2);
    v_min           varchar2(2);
    v_codest        ttexttrn.codest%type;
    v_codeen        ttexttrn.codeen%type;
    v_flagst        ttexttrn.flagst%type;
    v_flagen        ttexttrn.flagen%type;
    v_dayst         ttexttrn.dayst%type;
    v_dayen         ttexttrn.dayen%type;
    v_monthst       ttexttrn.monthst%type;
    v_monthen       ttexttrn.monthen%type;
    v_yearst        ttexttrn.yearst%type;
    v_yearen        ttexttrn.yearen%type;
    v_hourst        ttexttrn.hourst%type;
    v_houren        ttexttrn.houren%type;
    v_minst         ttexttrn.minst%type;
    v_minen         ttexttrn.minen%type;
    v_mchnost       ttexttrn.mchnost%type;
    v_mchnoen       ttexttrn.mchnoen%type;
    v_flgfound      boolean;
    v_filename      varchar2(200);

    json_obj_list   json_list;
    cursor c_tatmfile is
      select codbadge,dtetime,flgtranal,rowid
        from tatmfile
       where codbadge = v_codbadge
         and dtetime  = v_dtetime;

    cursor c_tempcard is
      select numcard,dtestrt,dteend,codempid,dtereturn
        from tempcard
       where numcard  = v_codbadge
         and dtestrt <= v_date
    order by dtestrt desc;

  begin
      begin
          select codest,codeen,flagst,flagen,dayst,dayen,monthst,monthen,
                 yearst,yearen,hourst,houren,minst,minen,mchnost,mchnoen
          into   v_codest,v_codeen,v_flagst,v_flagen,v_dayst,v_dayen,v_monthst,v_monthen,
                 v_yearst,v_yearen,v_hourst,v_houren,v_minst,v_minen,v_mchnost,v_mchnoen
          from   ttexttrn
          where  typmatch = p_typmatch;
      exception when no_data_found then
         p_error  := 1;
         return;
      end;

      p_sumtrn := 0;
      p_sumerr := 0;
      param_json := json(hcm_util.get_string(json(json_str_input),'param_json'));
      for i in 0..param_json.count-1 loop
        param_json_row  := hcm_util.get_json(param_json,to_char(i));
        json_obj_list   := param_json_row.get_values;
        v_text          := regexp_replace(json_obj_list.to_char,'\"|\]|\[|\ ','');

        begin
          if v_text is not null then
            v_codbadge := upper(rtrim(substr(v_text,v_codest,((v_codeen - v_codest) + 1))));
            if v_flagst > 0 then
              v_codrecod := substr(v_text,v_flagst,((v_flagen - v_flagst) + 1));
            else
              v_codrecod := null;
            end if;
            v_day			 := lpad(substr(v_text,v_dayst,((v_dayen - v_dayst) + 1)),2,'0');
            v_month		 := lpad(substr(v_text,v_monthst,((v_monthen - v_monthst) + 1)),2,'0');
            if ((v_yearen  - v_yearst) + 1) = 2 then
              if to_number(lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0')) < 30 then
                v_year := '20'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
              else
                v_year := '25'||lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),2,'0');
              end if;
            else
              v_year   := lpad(substr(v_text,v_yearst,((v_yearen  - v_yearst) + 1)),4,'0');
            end if;
            if to_number(v_year) < 2500 then
              v_year   := to_char(to_number(v_year) + v_zyear);
            else
              if v_zyear = 0 then
                v_year := to_char(to_number(v_year) - 543);
              end if;
            end if;
            v_hour		 := lpad(substr(v_text,v_hourst,((v_houren  - v_hourst) + 1)),2,'0');
            v_min			 := lpad(substr(v_text,v_minst,((v_minen   - v_minst) + 1)),2,'0');
            if v_mchnost > 0 then
              v_mchno	 := substr(v_text,v_mchnost,((v_mchnoen - v_mchnost) + 1));
            else
              v_mchno	 := null;
            end if;
            v_date     := to_date(v_day||'/'||v_month||'/'||v_year,'dd/mm/yyyy');
            v_time		 := v_hour||v_min;
            v_dtetime  := to_date(to_char(v_date,'dd/mm/yyyy')||v_time,'dd/mm/yyyyhh24mi');
            v_codempid := substr(v_codbadge,1,10);
            for r_tempcard in c_tempcard loop
              if (v_date between r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend)) or
                 (v_date >= r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend) is null) then
                v_codempid := r_tempcard.codempid;
                exit;
              end if;
            end loop;
            v_flgfound  := false;
            for r_tatmfile in c_tatmfile loop
              v_flgfound := true;
              if r_tatmfile.flgtranal = 'N' then
                update tatmfile set codrecod = v_codrecod,
                                    codempid = v_codempid,
                                    mchno    = v_mchno,
                                    coduser  = p_coduser_auto
                where rowid = r_tatmfile.rowid;
                p_sumtrn := p_sumtrn + 1; -- user3 : 28/06/2018
              end if;
            end loop;
            if not v_flgfound then
              insert into tatmfile(codbadge,dtetime,codrecod,dtedate,timtime,flgtranal,codempid,mchno,typmatch,coduser)
                          values(v_codbadge,v_dtetime,v_codrecod,v_date,v_time,'N',v_codempid,v_mchno,p_typmatch,p_coduser_auto);
              p_sumtrn := p_sumtrn + 1; -- user3 : 28/06/2018
            end if;
          end if;
        exception	 when others then
            p_sumerr := p_sumerr + 1; -- user3 : 28/06/2018
            p_error  := 2 ;
        end;
      end loop;
    exception when no_data_found then
      null;
    when others then
      p_error  := 3 ;
  end import_text_json;

  procedure cal_tattence(p_typmatch  in varchar2) is-- tatmfile --> tattence

    v_codcompy   tcontral.codcompy%type;
    v_codempid   temploy1.codempid%type;
    v_rec	  	   number;
    v_codrecin   ttexttrn.codrecin%type;
    v_codrecout  ttexttrn.codrecout%type;
    v_rectran    number;
    v_recerr     number;

    cursor c_emp is
      select codempid,codcomp,codcalen
        from temploy1
       where codempid in ( select codempid
                             from tatmfile
                            where dteupd >= trunc(p_sysdate)
                              and coduser = p_coduser_auto)
      order by codempid;

    cursor c_tempcard is
      select numcard,dtestrt,dteend,dtereturn,codempid
        from tempcard
       where codempid  = v_codempid
    order by numcard,dtestrt;

    cursor c_tcontral is
      select codcompy,dteeffec,rowid
        from tcontral
       where codcompy = v_codcompy
    order by codcompy,dteeffec for update;

  begin
    for r_emp in c_emp loop
      v_codempid := r_emp.codempid;
      for r_tempcard in c_tempcard loop
        update tatmfile
           set codempid  = r_tempcard.codempid
         where codbadge  = r_tempcard.numcard
           and(dtedate between r_tempcard.dtestrt and nvl(r_tempcard.dtereturn,r_tempcard.dteend)
            or(dtedate >= r_tempcard.dtestrt      and nvl(r_tempcard.dtereturn,r_tempcard.dteend) is null));
        commit;
      end loop;
      --
      transfer_time(r_emp.codempid,null,null,p_coduser_auto,'A',v_rectran,v_recerr);
      upd_att_log(r_emp.codempid,p_coduser_auto,null,null,'A');

      v_codcompy := hcm_util.get_codcomp_level(r_emp.codcomp,1);
      for r_tcontral in c_tcontral loop
        update tcontral
           set dayetrn = sysdate,
               coduser = p_coduser_auto
        where rowid = r_tcontral.rowid;
      end loop;
    end loop;
  end;
  ----
  procedure transfer_time(p_codempid  in temploy1.codempid%type,
                          p_dtestrt   in date,
                          p_dteend    in date,
                          p_coduser   in varchar2,
                         -- p_typmatch  in varchar2,
                          p_mode      in varchar2, --'M = Manual , A = Auto'
                          p_rectran   in out number,
                          p_recerr    in out number) is-- tatmfile --> tattence

    v_codrecin	 ttexttrn.codrecin%type;
    v_codrecout  ttexttrn.codrecout%type;
    v_codbadge   tatmfile.codbadge%type;
    v_dtework    tattence.dtework%type;
    v_timtime    tatmfile.timtime%type;
    v_flgupd     boolean;
    rt_tattence  tattence%rowtype;
    rt_tattprev  tattence%rowtype;
    rt_tattnext  tattence%rowtype;
    v_stampinst  tatmfile.dtetime%type;
    v_stampinen  tatmfile.dtetime%type;
    v_stampoutst tatmfile.dtetime%type;
    v_stampouten tatmfile.dtetime%type;
    v_flgfound   boolean;
    v_dtestrt    date;
    v_dteend     date;
    v_chk_e_dtework   date := to_date('01/01/0001','dd/mm/yyyy');

    /*cursor c_tatmfile is
      select codbadge,dtetime,codrecod,dtedate,timtime,mchno,flgtranal,codempid,timupd,dtecreate,codcreate,dteupd,coduser,typmatch,nvl(flginput,'1') as flginput
        from tatmfile
       where codempid = p_codempid
         and(
            (p_mode <> 'A'
         and dtetime  > (v_dtestrt - 1)
         and dtetime <= (v_dteend + 1))
          or(p_mode = 'A'
         and(
            (nvl(flginput,'1') = '1'
         and dtetime  > (v_dtestrt - 1)
         and dtetime <= (v_dteend + 1))
          or (nvl(flginput,'1') = '2'
         and dtetime >= (sysdate - 30)))))
    order by codempid,dtetime;*/

    cursor c_tatmfile is
      select codbadge,dtetime,codrecod,dtedate,timtime,mchno,flgtranal,codempid,timupd,dtecreate,codcreate,dteupd,coduser,typmatch,nvl(flginput,'1') as flginput
        from tatmfile
       where codempid = p_codempid
         and(
            (p_mode <> 'A'
         and dtedate >= (v_dtestrt - 1)
         and dtedate <= (v_dteend + 1))
          or(p_mode = 'A'
         and(
            (nvl(flginput,'1') = '1'
         and dtedate >= (v_dtestrt - 1)
         and dtedate <= (v_dteend + 1))
          or (nvl(flginput,'1') = '2'
         and dtedate >= (sysdate - 30)))))
    order by codempid,dtetime;

    cursor c_terror is
      select rowid
        from terror
       where dtework  = v_dtework
         and codbadge = v_codbadge
         and timtime  = v_timtime;

  begin
    p_coduser_all := p_coduser;
    if p_mode <> 'A' then --from HRAL3TB function
      v_dtestrt := p_dtestrt;
      v_dteend  := p_dteend;
    else --job Execute
      begin
        select min(dtedate),max(dtedate)
          into v_dtestrt,v_dteend
          from tatmfile
         where codempid  = p_codempid
           and dteupd   >= trunc(p_sysdate)
           and coduser   = p_coduser;
      exception when no_data_found then null;
      end;
    end if;
    --
    update tattence set dtein  = null, timin  = null, dteout = null, timout = null, newshift = null, coduser = p_coduser
     where codempid = p_codempid
       and dtework  between v_dtestrt and v_dteend;
    --
    p_stamptime := 0;
    for r_tatmfile in c_tatmfile loop
      <<atm_loop>>
      loop
        begin
          select codrecin,codrecout
            into v_codrecin,v_codrecout
            from ttexttrn
           where typmatch  = r_tatmfile.typmatch;
        exception when no_data_found then
          v_codrecin  := null;
          v_codrecout := null;
        end;
        v_codbadge := r_tatmfile.codbadge;
        v_dtework  := r_tatmfile.dtedate;
        v_timtime  := r_tatmfile.timtime;

        /*for r_terror in c_terror loop
          delete terror where rowid = r_terror.rowid;
        end loop;*/
        v_flgupd  := false;
        get_tattence(p_codempid,v_dtework,rt_tattence);
        get_tattence(p_codempid,v_dtework - 1,rt_tattprev);
        if rt_tattence.codempid is not null or rt_tattprev.codempid is not null then
          --if r_tatmfile.codrecod is not null and r_tatmfile.codrecod = v_codrecin then
          if r_tatmfile.codrecod is not null and
            ((r_tatmfile.flginput = '1' and r_tatmfile.codrecod = v_codrecin) or
             (r_tatmfile.flginput = '2' and r_tatmfile.codrecod = 'I')) then
            -- STAMP IN -- TODAY
            if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
              upd_att_in_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;
            end if;
            -- STAMP IN -- YESTERDAY
            if rt_tattprev.codempid is not null then
              if rt_tattprev.dtein is null or
                (rt_tattprev.dtein is not null and to_date(to_char(rt_tattprev.dtein,'dd/mm/yyyy')||rt_tattprev.timin,'dd/mm/yyyyhh24mi') > r_tatmfile.dtetime) then
                upd_att_in(rt_tattprev,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;
            end if;
            -- STAMP IN -- TOMORROW
            if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
              get_tattence(p_codempid,v_dtework + 1,rt_tattnext);
              if rt_tattnext.codempid is not null then
                upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;
            end if;
          --elsif r_tatmfile.codrecod is not null and r_tatmfile.codrecod = v_codrecout then
          elsif r_tatmfile.codrecod is not null and
              ((r_tatmfile.flginput = '1' and r_tatmfile.codrecod = v_codrecout) or
               (r_tatmfile.flginput = '2' and r_tatmfile.codrecod = 'O')) then
--<< user22 : 03/12/2021 : NXP ||
            if rt_tattprev.dtein is null then
                -- STAMP OUT -- TODAY
                if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
                  upd_att_out_today(rt_tattence,r_tatmfile,v_flgupd);
                  if v_flgupd then
                    exit atm_loop;
                  end if;
                end if;
                -- STAMP OUT -- YESTERDAY
                if rt_tattprev.codempid is not null then
                     upd_att_out(rt_tattprev,r_tatmfile,v_flgupd);
                    if v_flgupd then
                      exit atm_loop;
                    end if;
                end if;
            else
                -- STAMP OUT -- YESTERDAY
                if rt_tattprev.codempid is not null then
                     upd_att_out(rt_tattprev,r_tatmfile,v_flgupd);
                    if v_flgupd then
                      exit atm_loop;
                    end if;
                end if;
                -- STAMP OUT -- TODAY
                if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
                  upd_att_out_today(rt_tattence,r_tatmfile,v_flgupd);
                  if v_flgupd then
                    exit atm_loop;
                  end if;
                end if;
            end if;
            /*
            -- STAMP OUT -- TODAY
            if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
              upd_att_out_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;
            end if;
            -- STAMP OUT -- YESTERDAY
            if rt_tattprev.codempid is not null then
              --if rt_tattprev.dtein is not null or (rt_tattprev.dtein is null and rt_tattprev.typwork not in ('H','S','T')) then
                 upd_att_out(rt_tattprev,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              --end if;
            end if;*/
-->> user22 : 03/12/2021 : NXP ||
          else -- no flag
            if rt_tattprev.codempid is not null then
              -- STAMP IN -- YESTERDAY
              if rt_tattprev.dtein is null or
                (rt_tattprev.dtein is not null and to_date(to_char(rt_tattprev.dtein,'dd/mm/yyyy')||rt_tattprev.timin,'dd/mm/yyyyhh24mi') > r_tatmfile.dtetime) then
                upd_att_in(rt_tattprev,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;
                -- STAMP OUT -- YESTERDAY
              if rt_tattprev.dtein is not null or
                 (rt_tattprev.dtein is null and rt_tattprev.typwork not in ('H','S','T')) then
                 upd_att_out(rt_tattprev,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;
            end if;	-- rt_tattprev.codempid is not null

            if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
              -- STAMP IN -- TODAY
              upd_att_in_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;

              -- STAMP OUT -- TODAY
              upd_att_out_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;

              -- STAMP IN -- TOMORROW
              get_tattence(p_codempid,v_dtework + 1,rt_tattnext);
              if rt_tattnext.codempid is not null then
                upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;

                -- CHECK STAMP TIME IN DUPLICATE
                time_stamp(rt_tattence.codshift,rt_tattence.dtework,
                           v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
                if (r_tatmfile.dtetime between v_stampinst and v_stampinen) then
                  null;
                else
                  upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
                  if v_flgupd then
                    exit atm_loop;
                  end if;
                end if;
              end if; -- r_tatmfile.codrecod = p_codrecin
            end if; -- rt_tattence.dtework <= v_dteend
          end if; -- v_codrecin is not null
        /*else
          v_flgfound := false;
          for r_terror in c_terror loop
            v_flgfound := true;
            update terror set codrecod = r_tatmfile.codrecod,
                              coderr   = 'AL0020',
                              coduser  = p_coduser
            where  rowid = r_terror.rowid;
          end loop;
          if not v_flgfound then
            insert into terror(dtework,codbadge,timtime,codrecod,coderr,codcreate,coduser)
                        values(v_dtework,r_tatmfile.codbadge,r_tatmfile.timtime,
                               r_tatmfile.codrecod,'AL0020',p_coduser,p_coduser);
          end if;
          p_recerr := nvl(p_recerr,0) + 1;*/
        end if;	-- not exist tattence(today)
        exit atm_loop;
      end loop; -- atm_loop

      if v_flgupd then
        update tatmfile
           set flgtranal = 'Y',
               coduser   = p_coduser
         where codbadge  = r_tatmfile.codbadge
           and dtetime   = r_tatmfile.dtetime;
        p_rectran := nvl(p_rectran,0) + 1;
      else
        if rt_tattence.dtework <= v_dteend then
          update tatmfile
             set flgtranal = 'N',
                 coduser   = p_coduser
           where codbadge  = r_tatmfile.codbadge
             and dtetime   = r_tatmfile.dtetime;
        end if;
      end if;
    end loop; -- for c_tatmfile
  end;
  ----
/*

  procedure transfer_time_original(p_codempid  in temploy1.codempid%type,
                          p_dtestrt   in date,
                          p_dteend    in date,
                          p_coduser   in varchar2,
                         -- p_typmatch  in varchar2,
                          p_mode      in varchar2, --'M = Manual , A = Auto'
                          p_rectran   in out number,
                          p_recerr    in out number) is-- tatmfile --> tattence

    v_codrecin	 ttexttrn.codrecin%type;
    v_codrecout  ttexttrn.codrecout%type;
    v_codbadge   tatmfile.codbadge%type;
    v_dtework    tattence.dtework%type;
    v_timtime    tatmfile.timtime%type;
    v_flgupd     boolean;
    rt_tattence  tattence%rowtype;
    rt_tattprev  tattence%rowtype;
    rt_tattnext  tattence%rowtype;
    v_stampinst  tatmfile.dtetime%type;
    v_stampinen  tatmfile.dtetime%type;
    v_stampoutst tatmfile.dtetime%type;
    v_stampouten tatmfile.dtetime%type;
    v_flgfound   boolean;
    v_dtestrt    date;
    v_dteend     date;
    v_chk_e_dtework   date := to_date('01/01/0001','dd/mm/yyyy');


    cursor c_tatmfile is
      select codbadge,dtetime,codrecod,dtedate,timtime,mchno,flgtranal,codempid,timupd,dtecreate,codcreate,dteupd,coduser,typmatch,flginput
        from tatmfile
       where codempid = p_codempid
         and(
            (p_mode <> 'A'
         and dtetime  > (v_dtestrt - 1)
         and dtetime <= (v_dteend + 2))
          or(p_mode = 'A'
         and(
            (nvl(flginput,'1') = '1'
         and dtetime  > (v_dtestrt - 1)
         and dtetime <= (v_dteend + 2))
          or (nvl(flginput,'1') = '2'
         and dtetime >= (sysdate - 30)))))
    order by codempid,dtetime;

    cursor c_terror is
      select rowid
        from terror
       where dtework  = v_dtework
         and codbadge = v_codbadge
         and timtime  = v_timtime;

  begin
    p_coduser_all := p_coduser;
    if p_mode <> 'A' then --from HRAL3TB function
      v_dtestrt := p_dtestrt;
      v_dteend  := p_dteend;
    else --job Execute
      begin
        select min(dtedate),max(dtedate)
          into v_dtestrt,v_dteend
          from tatmfile
         where codempid  = p_codempid
           and dteupd   >= trunc(p_sysdate)
           and coduser   = p_coduser;
      exception when no_data_found then null;
      end;
    end if;
    --
    update tattence set dtein  = null, timin  = null, dteout = null, timout = null, newshift = null, coduser = p_coduser
     where codempid = p_codempid
       and dtework  between v_dtestrt and v_dteend;
    --
    p_stamptime := 0;
    for r_tatmfile in c_tatmfile loop
      <<atm_loop>>
      loop
        begin
          select codrecin,codrecout
            into v_codrecin,v_codrecout
            from ttexttrn
           where typmatch  = r_tatmfile.typmatch;
        exception when no_data_found then
          v_codrecin  := null;
          v_codrecout := null;
        end;
        v_codbadge := r_tatmfile.codbadge;
        v_dtework  := r_tatmfile.dtedate;
        v_timtime  := r_tatmfile.timtime;

        for r_terror in c_terror loop
          delete terror where rowid = r_terror.rowid;
        end loop;
        v_flgupd  := false;
        get_tattence(p_codempid,v_dtework,rt_tattence);
        get_tattence(p_codempid,v_dtework - 1,rt_tattprev);

        if rt_tattence.codempid is not null or rt_tattprev.codempid is not null then
          if rt_tattprev.codempid is not null then
            if rt_tattprev.dtein is null or
              (rt_tattprev.dtein is not null and to_date(to_char(rt_tattprev.dtein,'dd/mm/yyyy')||rt_tattprev.timin,'dd/mm/yyyyhh24mi') > r_tatmfile.dtetime) then
              -- STAMP IN -- YESTERDAY
              if nvl(r_tatmfile.codrecod,'!@#$%^&') = nvl(v_codrecin,nvl(r_tatmfile.codrecod,'!@#$%^&')) then
                upd_att_in(rt_tattprev,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;

              -- STAMP OUT -- YESTERDAY
              if nvl(r_tatmfile.codrecod,'!@#$%^&') = nvl(v_codrecout,nvl(r_tatmfile.codrecod,'!@#$%^&')) then
                if rt_tattprev.dtein is not null or
                   (rt_tattprev.dtein is null and rt_tattprev.typwork not in ('H','S','T')) then
                   upd_att_out(rt_tattprev,r_tatmfile,v_flgupd);
                  if v_flgupd then
                    exit atm_loop;
                  end if;
                end if;
              end if;
            end if; -- rt_tattence.dtein is null
          end if;	-- rt_tattprev.codempid is not null

          if rt_tattence.dtework <= v_dteend and rt_tattence.codempid is not null then
            -- STAMP IN -- TODAY
            if nvl(r_tatmfile.codrecod,'!@#$%^&') = nvl(v_codrecin,nvl(r_tatmfile.codrecod,'!@#$%^&')) then
              upd_att_in_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;
            end if;

            -- STAMP OUT -- TODAY
            if nvl(r_tatmfile.codrecod,'!@#$%^&') = nvl(v_codrecout,nvl(r_tatmfile.codrecod,'!@#$%^&')) then
              upd_att_out_today(rt_tattence,r_tatmfile,v_flgupd);
              if v_flgupd then
                exit atm_loop;
              end if;
            end if;

            -- STAMP IN -- TOMORROW
            if nvl(r_tatmfile.codrecod,'!@#$%^&') = nvl(v_codrecin,nvl(r_tatmfile.codrecod,'!@#$%^&')) then
              get_tattence(p_codempid,v_dtework + 1,rt_tattnext);
              if rt_tattnext.codempid is not null then
                upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;

              -- CHECK STAMP TIME IN DUPLICATE
              time_stamp(rt_tattence.codshift,rt_tattence.dtework,
                         v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
              if (r_tatmfile.dtetime between v_stampinst and v_stampinen) then
                null;
              else
                upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
                if v_flgupd then
                  exit atm_loop;
                end if;
              end if;
            end if; -- r_tatmfile.codrecod = p_codrecin
          end if; -- rt_tattence.dtework <= v_dteend
--          v_dtework;
--          upd_att_in(rt_tattnext,r_tatmfile,v_flgupd);
--          if v_flgupd then
--            exit atm_loop;
--          end if;
        else
          v_flgfound := false;
          for r_terror in c_terror loop
            v_flgfound := true;
            update terror set codrecod = r_tatmfile.codrecod,
                              coderr   = 'AL0020',
                              coduser  = p_coduser
            where  rowid = r_terror.rowid;
          end loop;
          if not v_flgfound then
            insert into terror(dtework,codbadge,timtime,codrecod,coderr,codcreate,coduser)
                        values(v_dtework,r_tatmfile.codbadge,r_tatmfile.timtime,
                               r_tatmfile.codrecod,'AL0020',p_coduser,p_coduser);
          end if;
          p_recerr := nvl(p_recerr,0) + 1;
        end if;	-- not exist tattence(today)
        exit atm_loop;
      end loop; -- atm_loop

      if v_flgupd then
        update tatmfile
           set flgtranal = 'Y',
               coduser   = p_coduser
         where codbadge  = r_tatmfile.codbadge
           and dtetime   = r_tatmfile.dtetime;
        p_rectran := nvl(p_rectran,0) + 1;
      else
        if rt_tattence.dtework <= v_dteend then
          update tatmfile
             set flgtranal = 'N',
                 coduser   = p_coduser
           where codbadge  = r_tatmfile.codbadge
             and dtetime   = r_tatmfile.dtetime;
        end if;
      end if;
    end loop; -- for c_tatmfile
  end;
  ----
*/
  procedure cal_tlateabs is
    rt_tcontral     tcontral%rowtype;
    v_numrec        number := 0;
    v_dtest					date;

    cursor c_emp is
      select codempid,dtework,codcomp
        from tattence
       where dtework between (trunc(sysdate) - 1) and trunc(sysdate)
    order by codempid,dtework;
  begin
    for r_emp in c_emp loop
      std_al.cal_tattence(r_emp.codempid,r_emp.dtework,r_emp.dtework,p_coduser_auto,v_numrec);
    end loop;
  end;
  ----
  procedure get_tattence (p_codempid in temploy1.codempid%type,
                          p_dtework  in tattence.dtework%type,
                          r_tattence in out tattence%rowtype) is
  begin
      select * into r_tattence
      from   tattence
      where  codempid = p_codempid
      and    dtework  = p_dtework;
  exception when no_data_found then
      r_tattence := null;
  end;
  ----
  procedure upd_att_in (p_r_tattence  in tattence%rowtype,
                        p_r_tatmfile  in tatmfile%rowtype,
                        p_flgupd      in out boolean)    is
    v_stampinst   tatmfile.dtetime%type;
    v_stampinen   tatmfile.dtetime%type;
    v_stampoutst  tatmfile.dtetime%type;
    v_stampouten  tatmfile.dtetime%type;
  begin
    if p_r_tattence.dtein is null then
      time_stamp(p_r_tattence.codshift,p_r_tattence.dtework,
                 v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
      if p_r_tatmfile.dtetime between v_stampinst and v_stampinen then
        update tattence set dtein  	 = p_r_tatmfile.dtedate,
                            timin  	 = p_r_tatmfile.timtime,
                            newshift = p_r_tattence.codshift,
                            coduser  = p_coduser_all
        where codempid = p_r_tattence.codempid
        and   dtework  = p_r_tattence.dtework;
        p_flgupd := true;
        p_stamptime := 1;
      end if;
    end if;
  end;
  ----
  procedure time_stamp (p_codshift   in tattence.codshift%type,
                        p_dtework  	 in tattence.dtework%type,
                        p_stampinst  out tatmfile.dtetime%type,
                        p_stampinen  out tatmfile.dtetime%type,
                        p_stampoutst out tatmfile.dtetime%type,
                        p_stampouten out tatmfile.dtetime%type) is
  rt_tshiftcd tshiftcd%rowtype;
  v_dtework   tattence.dtework%type;
  begin
    select * into rt_tshiftcd
    from tshiftcd
    where codshift = p_codshift
    order by codshift;
      if to_number(rt_tshiftcd.stampinst) > to_number(rt_tshiftcd.timstrtw) then
        v_dtework := p_dtework - 1;
      else
        v_dtework := p_dtework;
      end if;
      p_stampinst := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampinst,'dd/mm/yyyyhh24mi');
      if to_number(rt_tshiftcd.stampinen) < to_number(rt_tshiftcd.stampinst) then
        v_dtework := v_dtework + 1;
      end if;
      p_stampinen := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampinen,'dd/mm/yyyyhh24mi');

      if to_number(rt_tshiftcd.timstrtw) > to_number(rt_tshiftcd.timendw) then
        v_dtework := p_dtework + 1;
      else
        v_dtework := p_dtework;
      end if;
      if to_number(rt_tshiftcd.stampoutst) > to_number(rt_tshiftcd.timendw) then
        v_dtework := v_dtework - 1;
      end if;
      p_stampoutst := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampoutst,'dd/mm/yyyyhh24mi');
      if to_number(rt_tshiftcd.stampouten) < to_number(rt_tshiftcd.stampoutst) then
        v_dtework := v_dtework + 1;
      end if;
      p_stampouten := to_date(to_char(v_dtework,'dd/mm/yyyy')||rt_tshiftcd.stampouten,'dd/mm/yyyyhh24mi');
  exception when no_data_found then
    p_stampinst  := null;
    p_stampinen  := null;
    p_stampoutst := null;
    p_stampouten := null;
  end;
  ----
  procedure upd_att_out (p_r_tattence in tattence%rowtype,
                         p_r_tatmfile in tatmfile%rowtype,
                         p_flgupd     in out boolean)   is
  v_stampinst   tatmfile.dtetime%type;
  v_stampinen   tatmfile.dtetime%type;
  v_stampoutst  tatmfile.dtetime%type;
  v_stampouten  tatmfile.dtetime%type;
  begin
    time_stamp(p_r_tattence.codshift,p_r_tattence.dtework,
               v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
    if (p_r_tattence.dteout is null or
       (p_r_tattence.dteout is not null and p_stamptime < p_timtran)) and  (p_r_tattence.typwork in ('W','H','T')  or (p_r_tattence.typwork = 'L' and p_r_tattence.timin is not null)  ) and
       (p_r_tatmfile.dtetime between v_stampoutst and v_stampouten)   then
        update tattence set dteout 	 = p_r_tatmfile.dtedate,
                            timout 	 = p_r_tatmfile.timtime,
                            coduser  = p_coduser_all
        where codempid = p_r_tattence.codempid
        and   dtework  = p_r_tattence.dtework;
        p_flgupd := true;
        p_stamptime := p_stamptime + 1;
    end if;
  end;
  ----
  procedure upd_att_in_today (p_r_tattence in tattence%rowtype,
                              p_r_tatmfile in tatmfile%rowtype,
                              p_flgupd     in out boolean) is
    v_stampinst   tatmfile.dtetime%type;
    v_stampinen   tatmfile.dtetime%type;
    v_stampoutst  tatmfile.dtetime%type;
    v_stampouten  tatmfile.dtetime%type;
    v_codshift		tshiftcd.codshift%type;
    last_codshift		tshiftcd.codshift%type;
    v_grpshift		tshiftcd.grpshift%type;
    v_codempid    tattence.codempid%type;
    v_codcomp     tattence.codcomp%type;
    v_dtework     tattence.dtework%type;
		v_strtw       date;
		v_endw        date;
		v_dtestrtw    tattence.dtestrtw%type;
		v_dteendw     tattence.dteendw%type;
		v_timstrtw    tshiftcd.timstrtw%type;
		v_timendw     tshiftcd.timendw%type;
		v_strtb       date;
		v_endb        date;
		v_dtestrtb    tattence.dtework%type;
		v_dteendb     tattence.dtework%type;
		v_timstrtb    tshiftcd.timstrtw%type;
		v_timendb     tshiftcd.timendw%type;
		v_minbrk      number;
		v_minlv	      number;
		t_minlv	      number;
    v_minlbk 	    number;
		v_strtle      date;
		v_endle       date;
    v_stampin     date;
    v_qtylate     tlateabs.qtylate%type;
		v_typabs      tcontal3.typabs%type;
		v_min         number;
    /*cursor c1 is
      select codshift,timstrtw,timendw
        from tshiftcd
       where grpshift = v_grpshift
    order by round(abs(to_date(timstrtw,'hh24.mi') - to_date(p_r_tatmfile.timtime,'hh24.mi'))* 1440);*/

    cursor c2 is
      select codshift,timstrtw,timendw,timstrtb,timendb,qtydaywk
        from tshiftcd
       where grpshift = v_grpshift
    order by codshift;

		cursor c_tleavetr is
		  select rowid,timstrt,timend,qtymin,qtyday
		    from tleavetr
		   where codempid = v_codempid
		     and dtework  = v_dtework
		order by codempid,dtework,timstrt;

		cursor c_tcontal3 is
		  select qtymin
 		    from tcontal3
		   where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
		     and dteeffec = (select max(dteeffec)
                           from tcontal3
                          where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                            and dteeffec <= sysdate)
		     and typabs   = v_typabs
		     and v_min between qtyminst and qtyminen;

  begin
--insert_temp2('AAA','AAA',1,to_char(p_r_tattence.dtein,'dd/mm/yyyy'),null,null,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
    if p_r_tattence.dtein is null then
      time_stamp(p_r_tattence.codshift,p_r_tattence.dtework,
                 v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
--insert_temp2('AAA','AAA',2,to_char(v_stampinst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinen,'dd/mm/yyyy  hh24:mi'),to_char(v_stampoutst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampouten,'dd/mm/yyyy  hh24:mi'),null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
      if p_r_tatmfile.dtetime between v_stampinst and v_stampinen then
--insert_temp2('AAA','AAA',3,to_char(p_r_tatmfile.dtetime,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinen,'dd/mm/yyyy  hh24:mi'),null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
        update tattence
           set dtein    = p_r_tatmfile.dtedate,
               timin    = p_r_tatmfile.timtime,
               newshift = p_r_tattence.codshift,
               coduser  = p_coduser_all
         where codempid = p_r_tattence.codempid
           and dtework  = p_r_tattence.dtework;
        p_flgupd := true;
        p_stamptime := 1;
        return;
      end if;
      --
      begin
        select grpshift	into v_grpshift
          from tshiftcd
         where codshift = p_r_tattence.codshift;
      exception when no_data_found then v_grpshift := null;
      end;
      if v_grpshift is not null then
--insert_temp2('AAA','AAA',4,v_grpshift,null,null,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
        /*begin
          select flggrpshift into v_flggrpshift
            from tcontral
           where codcompy = hcm_util.get_codcomp_level(p_r_tattence.codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontral
                              where codcompy  = hcm_util.get_codcomp_level(p_r_tattence.codcomp,1)
                                and dteeffec <= sysdate)
             and rownum <= 1;
        exception when no_data_found then null;
        end;
        if v_flggrpshift = '1' then
          for r1 in c1 loop
            v_codshift := r1.codshift;
            v_timstrtw := r1.timstrtw;
            v_timendw	 := r1.timendw;
            time_stamp(v_codshift,p_r_tattence.dtework,
                       v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
            if p_r_tatmfile.dtetime between v_stampinst and v_stampinen then
              v_dtestrtw := p_r_tattence.dtework;
              if v_timstrtw > v_timendw then
                v_dteendw := p_r_tattence.dtework + 1;
              else
                v_dteendw := p_r_tattence.dtework;
              end if;
              update tattence set codshift = v_codshift,
                                  dtestrtw = v_dtestrtw,
                                  timstrtw = v_timstrtw,
                                  dteendw  = v_dteendw,
                                  timendw  = v_timendw,
                                  dtein  	 = p_r_tatmfile.dtedate,
                                  timin  	 = p_r_tatmfile.timtime,
                                  newshift = p_r_tattence.codshift,
                                  coduser  = p_coduser_all
              where codempid = p_r_tattence.codempid
              and   dtework  = p_r_tattence.dtework;
              p_flgupd := true;
              p_stamptime := 1;
              return;
            end if; -- p_r_tatmfile.dtetime between v_stampinst and v_stampinen
          end loop;
        else -- v_flggrpshift = '2'*/
          last_codshift := null;
          for r1 in c2 loop
            time_stamp(r1.codshift,p_r_tattence.dtework,
                       v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
            if p_r_tatmfile.dtetime between v_stampinst and v_stampinen then
              last_codshift := r1.codshift;
            end if;
          end loop;
--insert_temp2('AAA','AAA',5,last_codshift,null,null,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
          --
          for r1 in c2 loop
            v_codshift := r1.codshift;
            v_timstrtw := r1.timstrtw;
            v_timendw	 := r1.timendw;
            time_stamp(v_codshift,p_r_tattence.dtework,
                       v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
--insert_temp2('AAA','AAA',6,v_codshift,to_char(v_stampinst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinen,'dd/mm/yyyy  hh24:mi'),to_char(v_stampoutst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampouten,'dd/mm/yyyy  hh24:mi'),null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
            if p_r_tatmfile.dtetime between v_stampinst and v_stampinen then
              v_dtestrtw := p_r_tattence.dtework;
              if v_timstrtw > v_timendw then
                v_dteendw := p_r_tattence.dtework + 1;
              else
                v_dteendw := p_r_tattence.dtework;
              end if;
--insert_temp2('AAA','AAA',7,to_char(p_r_tatmfile.dtetime,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinst,'dd/mm/yyyy  hh24:mi'),to_char(v_stampinen,'dd/mm/yyyy  hh24:mi'),null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
              if v_codshift <> last_codshift then
                v_strtw   := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||v_timstrtw,'dd/mm/yyyyhh24mi');
                v_endw    := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');
                v_stampin := p_r_tatmfile.dtetime;
                if v_stampin > v_strtw then
                  if r1.timstrtb is not null and r1.timendb is not null then
                    if v_timstrtb < v_timstrtw then
                      v_dtestrtb := v_dtestrtw + 1;
                    else
                      v_dtestrtb := v_dtestrtw;
                    end if;
                    if r1.timstrtb > r1.timendb then
                      v_dteendb := v_dtestrtb + 1;
                    else
                      v_dteendb := v_dtestrtb;
                    end if;
                    v_strtb := to_date(to_char(v_dtestrtb,'dd/mm/yyyy')||r1.timstrtb,'dd/mm/yyyyhh24mi');
                    v_endb  := to_date(to_char(v_dteendb,'dd/mm/yyyy')||r1.timendb,'dd/mm/yyyyhh24mi');
                  else
                    v_strtb := null; v_dtestrtb := null;
                    v_endb  := null; v_dteendb  := null;
                  end if;

                  v_qtylate  := 0; v_minbrk := 0; v_minlv := 0; v_minlbk := 0;
                  v_qtylate  := std_al.Cal_Min_Dup(v_strtw,v_stampin,v_strtw,v_endw);
                  v_minbrk   := std_al.Cal_Min_Dup(v_strtw,v_stampin,v_strtb,v_endb);
                  v_qtylate  := v_qtylate - v_minbrk;
                  v_codempid := p_r_tattence.codempid;
                  v_dtework  := p_r_tattence.dtework;
                  for r_tleavetr in c_tleavetr loop
                    if r_tleavetr.timstrt < p_r_tattence.timstrtw then
                      v_strtle := to_date(to_char(p_r_tattence.dtestrtw + 1,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    else
                      v_strtle := to_date(to_char(p_r_tattence.dtestrtw,'dd/mm/yyyy')||r_tleavetr.timstrt,'dd/mm/yyyyhh24mi');
                    end if;
                    if r_tleavetr.timstrt < r_tleavetr.timend then
                      v_endle  := to_date(to_char(v_strtle,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    else
                      v_endle  := to_date(to_char(v_strtle + 1,'dd/mm/yyyy')||r_tleavetr.timend,'dd/mm/yyyyhh24mi');
                    end if;
                    t_minlv  := std_al.Cal_Min_Dup(v_strtw,v_stampin,v_strtle,v_endle);
                    v_minlv  := v_minlv  + t_minlv;
                    if t_minlv > 0 and v_minbrk > 0 then
                      v_minlbk := v_minlbk + least(std_al.Cal_Min_Dup(v_strtb,v_endb,v_strtle,v_endle),v_minbrk);
                      v_minlv  := v_minlv - v_minlbk;
                    end if;
                  end loop; -- c_tleavetr loop
                  v_qtylate := v_qtylate - v_minlv;
                  if v_qtylate > r1.qtydaywk then
                    v_qtylate := r1.qtydaywk;
                  elsif v_qtylate < 0 then
                    v_qtylate := 0;
                  end if;
                  -- Round up minute(Late)
                  v_typabs  := '1';
                  v_min     := v_qtylate;
                  v_codcomp := p_r_tattence.codcomp;
                  for r_tcontal3 in c_tcontal3 loop
                    v_min := r_tcontal3.qtymin;
                  end loop;
                  v_qtylate := v_min;
                /*std_al.cal_tlateabs(p_r_tattence.codempid,p_r_tattence.dtework,p_r_tattence.typwork,p_r_tattence.codshift,
                                    to_date(to_char(p_r_tatmfile.dtetime,'dd/mm/yyyy'),'dd/mm/yyyy'),to_char(p_r_tatmfile.dtetime,'hh24mi'),p_r_tattence.dteendw,p_r_tattence.timendw,p_coduser_all,'N',
                                    v_timlate,v_timear,v_timabs,v_rec);*/
                  if v_qtylate > 0 then
                    goto next_loop;
                  end if;
                end if; -- v_stampin > v_strtw
              end if; -- v_codshift <> last_codshift
--insert_temp2('AAA','AAA',8,v_qtylate,null,null,null,null,null,null,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));  -- boy
              update tattence set codshift = v_codshift,
                                  dtestrtw = v_dtestrtw,
                                  timstrtw = v_timstrtw,
                                  dteendw  = v_dteendw,
                                  timendw  = v_timendw,
                                  dtein  	 = p_r_tatmfile.dtedate,
                                  timin  	 = p_r_tatmfile.timtime,
                                  newshift = p_r_tattence.codshift,
                                  coduser  = p_coduser_all
              where codempid = p_r_tattence.codempid
              and   dtework  = p_r_tattence.dtework;
              p_flgupd := true;
              p_stamptime := 1;
              return;
              <<next_loop>> null;
            end if; -- p_r_tatmfile.dtetime between v_stampinst and v_stampinen
          end loop;
        --end if; -- v_flggrpshift = '1'
      end if;  -- v_grpshift is not null
    end if;--p_r_tattence.dtein is null
  end;
  ----
  procedure upd_att_out_today ( p_r_tattence  in tattence%rowtype,
                                p_r_tatmfile  in tatmfile%rowtype,
                                p_flgupd      in out boolean)	is
    v_stampinst   tatmfile.dtetime%type;
    v_stampinen   tatmfile.dtetime%type;
    v_stampoutst  tatmfile.dtetime%type;
    v_stampouten  tatmfile.dtetime%type;
    v_codshift		tshiftcd.codshift%type;
    v_grpshift		tshiftcd.grpshift%type;
    v_dtestrtw		date;
    v_timstrtw		tshiftcd.timstrtw%type;
    v_dteendw			date;
    v_timendw			tshiftcd.timendw%type;
    v_log					varchar2(1) := 'N';

    cursor c1 is
      select codshift,timstrtw,timendw
        from tshiftcd
       where grpshift = v_grpshift
    order by codshift;

  begin
    if (p_r_tattence.dteout is null or
       (p_r_tattence.dteout is not null and p_stamptime < p_timtran)) then
      time_stamp(p_r_tattence.codshift,p_r_tattence.dtework,
                 v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
      if (p_r_tatmfile.dtetime between v_stampoutst and v_stampouten) then
        update tattence
           set dteout   = p_r_tatmfile.dtedate,
               timout   = p_r_tatmfile.timtime,
               coduser  = p_coduser_all
         where codempid = p_r_tattence.codempid
           and dtework  = p_r_tattence.dtework;
        p_flgupd := true;
        p_stamptime := p_stamptime + 1;
        return;
      end if;
      --
--<< Bint || 02/03/2021 || https://hrmsd.peopleplus.co.th:4448/redmine/issues/1828
      /*if p_r_tattence.dtein is null then
        begin
          select grpshift	into v_grpshift
          from   tshiftcd
          where  codshift = p_r_tattence.codshift;
        exception when no_data_found then v_grpshift := null;
        end;
        if v_grpshift is not null then
          for r1 in c1 loop
            v_codshift := r1.codshift;
            v_timstrtw := r1.timstrtw;
            v_timendw	 := r1.timendw;
            time_stamp(v_codshift,p_r_tattence.dtework,
                       v_stampinst,v_stampinen,v_stampoutst,v_stampouten);
            if p_r_tatmfile.dtetime between v_stampoutst and v_stampouten then
              v_dtestrtw := p_r_tattence.dtework;
              if v_timstrtw > v_timendw then
                v_dteendw := p_r_tattence.dtework + 1;
              else
                v_dteendw := p_r_tattence.dtework;
              end if;

              update tattence set codshift = v_codshift,
                                  dtestrtw = v_dtestrtw,
                                  timstrtw = v_timstrtw,
                                  dteendw  = v_dteendw,
                                  timendw  = v_timendw,
                                  dteout 	 = p_r_tatmfile.dtedate,
                                  timout 	 = p_r_tatmfile.timtime,
                                  newshift = p_r_tattence.codshift,
                                  coduser  = p_coduser_all
              where codempid = p_r_tattence.codempid
              and   dtework  = p_r_tattence.dtework;
              p_flgupd := true;
              p_stamptime := p_stamptime + 1;
              return;
            end if;
          end loop;
        end if;
      end if;*/--p_r_tattence.dtein is null
-->> Bint || 02/03/2021 || https://hrmsd.peopleplus.co.th:4448/redmine/issues/1828
    end if;
  end;
  ----
  procedure upd_att_log (p_codempid temploy1.codempid%type,
                         p_coduser  in varchar2,
                         p_dtestrt  in date,
                         p_dteend   in date,
                         p_mode     in varchar2) is --'M = Manual , A = Auto')
    v_dtework   tattence.dtework%type;
    v_dtein     tattence.dtein%type;
    v_timin     tattence.timin%type;
    v_dteout    tattence.dteout%type;
    v_timout    tattence.timout%type;
    v_dtei			date;
    v_dteo			date;
    v_date			date;

    cursor c_tattence is
      select codempid,dtework,dtein,timin,dteout,timout,rowid
        from tattence
       where codempid = p_codempid
         and ((p_mode = 'M' and dtework between (p_dtestrt - 2) and p_dteend)
          or  (p_mode = 'A' and dteupd  >= trunc(p_sysdate)
                            and coduser  = p_coduser))
    order by codempid,dtework;

    cursor c_tchkin is
      select dtein,timin,dteout,timout
        from tchkin
       where codempid = p_codempid
         and dtework  = v_dtework;

    cursor c_tlogtime is
      select a.dtework ,decode(timinnew,null,dteinnew,nvl(dteinnew ,b.dtestrtw)) dteinnew ,timinnew,dteoutnew,timoutnew
        from tlogtime a ,tattence b
       where a.codempid = b.codempid
         and a.dtework  = b.dtework
         and a.codempid = p_codempid
         and a.dtework  = v_dtework
         and (a.dteinnew is not null or a.dteoutnew is not null)
    order by a.dteupd;

  begin
    for r_tattence in c_tattence loop
      v_dtework  := r_tattence.dtework;
      v_dtein	   := r_tattence.dtein;
      v_timin	   := r_tattence.timin;
      v_dteout   := r_tattence.dteout;
      v_timout   := r_tattence.timout;
      v_dtei     := to_date(to_char(r_tattence.dtein,'dd/mm/yyyy')||r_tattence.timin,'dd/mm/yyyyhh24mi');
      v_dteo     := to_date(to_char(r_tattence.dteout,'dd/mm/yyyy')||r_tattence.timout,'dd/mm/yyyyhh24mi');
      --tchkin
      for r2 in c_tchkin loop
        if r2.dtein is not null then
          v_date := to_date(to_char(r2.dtein,'dd/mm/yyyy')||r2.timin,'dd/mm/yyyyhh24mi');
          v_dtei := least(nvl(v_dtei,(sysdate+99999)),v_date);
        end if;
        if r2.dteout is not null then
          v_date := to_date(to_char(r2.dteout,'dd/mm/yyyy')||r2.timout,'dd/mm/yyyyhh24mi');
          v_dteo := greatest(nvl(v_dteo,(sysdate-99999)),v_date);
        end if;
      end loop;

      if v_dtei is not null then
        v_dtein	:= trunc(v_dtei);
        v_timin	:= to_char(v_dtei,'hh24mi');
      end if;
      if v_dteo is not null then
        v_dteout := trunc(v_dteo);
        v_timout := to_char(v_dteo,'hh24mi');
      end if;

      --tlogtime
      for i in c_tlogtime loop
        v_dtein	   := nvl(i.dteinnew,v_dtein);
        v_timin	   := nvl(i.timinnew,v_timin);
        v_dteout   := nvl(i.dteoutnew,v_dteout);
        v_timout   := nvl(i.timoutnew,v_timout);
      end loop;
      update tattence
         set dtein    = nvl(v_dtein,dtein),
             timin    = nvl(v_timin,timin),
             dteout   = nvl(v_dteout,dteout),
             timout   = nvl(v_timout,timout)
       where rowid = r_tattence.rowid;
    end loop;
  end;
end HRAL3TB_BATCH;

/

--------------------------------------------------------
--  DDL for Package Body HRMS33U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS33U" is
-- last update: 27/09/2022 10:44

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    --v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    --global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codempid            := upper(hcm_util.get_string_t(json_obj,'p_codempid_query'));

    p_dtest               := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen               := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr             := hcm_util.get_string_t(json_obj,'p_staappr');
    p_start               := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    p_end                 := to_number(hcm_util.get_string_t(json_obj,'p_end'));
    v_codappr             := pdk.check_codempid(global_v_coduser);

    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    b_index_dtereq_st   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');
    --
    b_index_dtereq      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    b_index_v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'v_dtereq'),'dd/mm/yyyy');
    b_index_numseq      := nvl(hcm_util.get_string_t(json_obj,'p_numseq'),b_index_numseq);
    b_index_typchg      := hcm_util.get_string_t(json_obj,'p_typchg');

    begin
      select codcomp,hcm_util.get_codcomp_level(codcomp,1)
        into b_index_codcomp,p_codcompy
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      null;
    end;

    -- set to use
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;


  procedure upd_log1(p_codempid   in varchar2,
                   p_codtable   in varchar2,
                   p_numpage    in varchar2,
                   p_fldedit    in varchar2,
                   p_typdata    in varchar2,
                   p_desold     in varchar2,
                   p_desnew     in varchar2,
                   p_flgenc     in varchar2,
                   p_codcomp    in varchar2,
                   p_coduser    in varchar2,
                   p_lang       in varchar2 ) IS

    v_exist     boolean := false;

    cursor c_ttemlog1 is
    select rowid
      from ttemlog1
     where codempid = p_codempid
       and dteedit  = sysdate
       and numpage  = p_numpage
       and fldedit  = upper(p_fldedit);

  begin
      if (p_desold is null and p_desnew is not null) or
         (p_desold is not null and p_desnew is null) or
         (p_desold <> p_desnew) then
         for r_ttemlog1 in c_ttemlog1 loop
              v_exist := true;
              update ttemlog1
              set    codcomp  = p_codcomp,
                     desold   = p_desold,
                     desnew   = p_desnew,
                     flgenc   = p_flgenc,
                     codtable = upper(p_codtable),
                     dteupd   = trunc(sysdate),
                     coduser  = p_coduser
              where  rowid = r_ttemlog1.rowid;
         end loop;
              if not v_exist then
                  insert into  ttemlog1
                                      (
                                       codempid,dteedit,numpage,
                                       fldedit,codcomp,desold,
                                       desnew,flgenc,codtable,
                                       dteupd,coduser
                                       )
                          values
                                      (
                                       p_codempid,sysdate,p_numpage,
                                       upper(p_fldedit),p_codcomp,p_desold,
                                       p_desnew,p_flgenc,upper(p_codtable),
                                       trunc(sysdate),p_coduser
                                       );
              end if;
      end if;
  end;
  --

  procedure upd_log2(p_codempid   in varchar2,
                     p_codtable   in varchar2,
                     p_numpage    in varchar2,
                     p_numseq     in number,
                     p_fldedit    in varchar2,
                     p_typkey     in varchar2,
                     p_fldkey     in varchar2,
                     p_codseq     in varchar2,
                     p_dteseq     in date,
                     p_typdata    in varchar2,
                     p_desold     in varchar2,
                     p_desnew     in varchar2,
                     p_flgenc     in varchar2,
                     p_codcomp    in varchar2,
                     p_coduser    in varchar2,
                     p_lang       in varchar2 ) IS

      v_exist     boolean := false;

      cursor c_ttemlog2 is
        select rowid
          from ttemlog2
         where codempid   = p_codempid
           and dteedit    = sysdate
           and numpage    = p_numpage
           and numseq     = p_numseq
           and fldedit    = upper(p_fldedit);

  begin
      if (p_desold is null and p_desnew is not null) or
           (p_desold is not null and p_desnew is null) or
           (p_desold <> p_desnew) then
         for r_ttemlog2 in c_ttemlog2 loop
              v_exist := true;
              update ttemlog2
              set    typkey   = p_typkey,
                     fldkey   = upper(p_fldkey),
                     codseq   = p_codseq,
                     dteseq   = p_dteseq,
                     codcomp  = p_codcomp,
                     desold   = p_desold,
                     desnew   = p_desnew,
                     flgenc   = p_flgenc,
                     codtable = upper(p_codtable),
                     dteupd   = trunc(sysdate),
                     coduser  = p_coduser
              where  rowid = r_ttemlog2.rowid;
         end loop;
              if not v_exist then
                  insert into  ttemlog2
                                      (
                                       codempid,dteedit,numpage,
                                       numseq,fldedit,codcomp,
                                       typkey,fldkey,codseq,
                                       dteseq,desold,desnew,
                                       flgenc,codtable,dteupd,
                                       coduser
                                       )
                  values
                                      (
                                       p_codempid,sysdate,p_numpage,
                                       p_numseq,upper(p_fldedit),p_codcomp,
                                       p_typkey,p_fldkey,p_codseq,
                                       p_dteseq,p_desold,p_desnew,
                                       p_flgenc,upper(p_codtable),trunc(sysdate),
                                       p_coduser
                                       );
              end if;
      end if;

  end;
  --

  procedure upd_log3 (p_codempid  in varchar2,
                      p_codtable  in varchar2,
                      p_numpage   in varchar2,
                      p_typdeduct in varchar2,
                      p_coddeduct in varchar2,
                      p_desold    in varchar2,
                      p_desnew    in varchar2,
                      p_codcomp   in varchar2,
                      p_coduser   in varchar2,
                      p_lang      in varchar2 ) IS

      v_exist     boolean := false;

      cursor c_ttemlog3 is
        select rowid
          from ttemlog3
         where codempid  = p_codempid
           and dteedit   = sysdate
           and numpage   = p_numpage
           and typdeduct = p_typdeduct
           and coddeduct = p_coddeduct;

  begin
      if (p_desold is null and p_desnew is not null) or
         (p_desold is not null and p_desnew is null) or
         (p_desold <> p_desnew) then
         for r_ttemlog3 in c_ttemlog3 loop
              v_exist := true;
              update ttemlog3
              set    codcomp  = p_codcomp,
                     desold   = p_desold,
                     desnew   = p_desnew,
                     codtable = upper(p_codtable),
                     dteupd   = trunc(sysdate),
                     coduser  = p_coduser
              where  rowid = r_ttemlog3.rowid;
         end loop;
              if not v_exist then
                  insert into  ttemlog3
                                      (
                                       codempid,dteedit,numpage,
                                       typdeduct,coddeduct,codcomp,
                                       desold,desnew,codtable,
                                       dteupd,coduser
                                       )
                  values
                                      (
                                       p_codempid,sysdate,p_numpage,
                                       p_typdeduct,p_coddeduct,p_codcomp,
                                       p_desold,p_desnew,upper(p_codtable),
                                       trunc(sysdate),p_coduser);
              end if;
      end if;
  end;
  --

  procedure update_temploy1(p_coduser     in varchar2,
                          p_codempid    in varchar2,
                          p_dtereq      in date,
                          p_numseq      in number,
                          p_lang        in varchar2,
                          p_desnote     in varchar2) IS

          e_codtitle      varchar2(60 char)  := null;  e_namfirste     varchar2(60 char) := null;
          e_namfirstt     varchar2(60 char)  := null;  e_namfirst3     varchar2(60 char) := null;
          e_namfirst4     varchar2(60 char)  := null;  e_namfirst5     varchar2(60 char) := null;
          e_namlaste      varchar2(60 char)  := null;  e_namlastt      varchar2(60 char) := null;
          e_namlast3      varchar2(60 char)  := null;  e_namlast4      varchar2(60 char) := null;
          e_namlast5      varchar2(60 char)  := null;  e_namempe       varchar2(60 char) := null;
          e_namempt       varchar2(60 char)  := null;  e_namemp3       varchar2(60 char) := null;
          e_namemp4       varchar2(60 char)  := null;  e_namemp5       varchar2(60 char) := null;
          e_nickname      varchar2(60 char)  := null;  e_nicknamt      varchar2(60 char) := null;
          e_nicknam3      varchar2(60 char)  := null;  e_nicknam4      varchar2(60 char) := null;
          e_nicknam5      varchar2(60 char)  := null;
          n_codtitle      varchar2(60 char)  := null;  n_namfirste     varchar2(60 char) := null;
          n_namfirstt     varchar2(60 char)  := null;  n_namfirst3     varchar2(60 char) := null;
          n_namfirst4     varchar2(60 char)  := null;  n_namfirst5     varchar2(60 char) := null;
          n_namlaste      varchar2(60 char)  := null;  n_namlastt      varchar2(60 char) := null;
          n_namlast3      varchar2(60 char)  := null;  n_namlast4      varchar2(60 char) := null;
          n_namlast5      varchar2(60 char)  := null;  n_namempe       varchar2(60 char) := null;
          n_namempt       varchar2(60 char)  := null;  n_namemp3       varchar2(60 char) := null;
          n_namemp4       varchar2(60 char)  := null;  n_namemp5       varchar2(60 char) := null;
          n_nickname      varchar2(60 char)  := null;  n_nicknamt      varchar2(60 char) := null;
          n_nicknam3      varchar2(60 char)  := null;  n_nicknam4      varchar2(60 char) := null;
          n_nicknam5      varchar2(60 char)  := null;

          v_titlenamen    varchar2(500 char);
          v_titlenamee    varchar2(500 char);

          v_codcomp       tcenter.codcomp%type;
          v_dtereq        thisname.dtechg%type;
          v_numseq        number := 0;
          v_titlee        varchar2(500 char);
          v_titlet        varchar2(500 char);
          v_title3        varchar2(500 char);
          v_title4        varchar2(500 char);
          v_title5        varchar2(500 char);

    cursor c_temeslog1 is
        select fldedit,desnew
          from temeslog1
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and numpage  = 11;

  begin

       begin
           select codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                  namlaste,namlastt,namlast3,namlast4,namlast5,
                  namempe,namempt,namemp3,namemp4,namemp5,codcomp
           into
                  e_codtitle,e_namfirste,e_namfirstt,e_namfirst3,e_namfirst4 ,e_namfirst5,
                  e_namlaste,e_namlastt ,e_namlast3 ,e_namlast4 ,e_namlast5,
                  e_namempe ,e_namempt  ,e_namemp3  ,e_namemp4  ,e_namemp5,v_codcomp
           from   temploy1
           where  codempid = p_codempid;
       exception when others then
         null;
       end ;

       begin
           select codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                  namlaste,namlastt,namlast3,namlast4,namlast5,
                  nickname,nicknamt,nicknam3,nicknam4,nicknam5
           into
                  n_codtitle,n_namfirste,n_namfirstt,n_namfirst3,n_namfirst4 ,n_namfirst5,
                  n_namlaste,n_namlastt ,n_namlast3 ,n_namlast4 ,n_namlast5,
                  n_nickname,n_nicknamt,n_nicknam3,n_nicknam4,n_nicknam5
           from   temploy1
           where  codempid = p_codempid;
       exception when others then
         null;
       end ;

      for i in c_temeslog1 loop
          if i.fldedit = 'CODTITLE' then
              n_codtitle      := i.desnew ;
          elsif i.fldedit = 'NAMFIRSTE' then
              n_namfirste     := i.desnew ;
          elsif i.fldedit = 'NAMFIRSTT' then
              n_namfirstt     := i.desnew ;
          elsif i.fldedit = 'NAMFIRST3' then
              n_namfirst3     := i.desnew ;
          elsif i.fldedit = 'NAMFIRST4' then
              n_namfirst4     := i.desnew ;
          elsif i.fldedit = 'NAMFIRST5' then
              n_namfirst5     := i.desnew ;
          elsif i.fldedit = 'NAMLASTE' then
              n_namlaste     := i.desnew ;
          elsif i.fldedit = 'NAMLASTT' then
              n_namlastt     := i.desnew ;
          elsif i.fldedit = 'NAMLAST3' then
              n_namlast3     := i.desnew ;
          elsif i.fldedit = 'NAMLAST4' then
              n_namlast4     := i.desnew ;
          elsif i.fldedit = 'NAMLAST5' then
              n_namlast5     := i.desnew ;
          elsif i.fldedit = 'NICKNAME' then
              n_nickname     := i.desnew ;
          elsif i.fldedit = 'NICKNAMT' then
              n_nicknamt     := i.desnew ;
          elsif i.fldedit = 'NICKNAM3' then
              n_nicknam3     := i.desnew ;
          elsif i.fldedit = 'NICKNAM4' then
              n_nicknam4     := i.desnew ;
          elsif i.fldedit = 'NICKNAM5' then
              n_nicknam5     := i.desnew ;
          end if;
      end loop;


      v_titlee := get_tlistval_name('CODTITLE',nvl(n_codtitle,e_codtitle),'101');
      v_titlet := get_tlistval_name('CODTITLE',nvl(n_codtitle,e_codtitle),'102');
      v_title3 := get_tlistval_name('CODTITLE',nvl(n_codtitle,e_codtitle),'103');
      v_title4 := get_tlistval_name('CODTITLE',nvl(n_codtitle,e_codtitle),'104');
      v_title5 := get_tlistval_name('CODTITLE',nvl(n_codtitle,e_codtitle),'105');

      v_titlenamen := get_tlistval_name('CODTITLE',n_codtitle,p_lang);
      v_titlenamee := get_tlistval_name('CODTITLE',e_codtitle,p_lang);

      if  n_codtitle  is not null  or n_namfirste is not null  or n_namlaste  is not null  then
            n_namempe := substr(v_titlee||nvl(n_namfirste,e_namfirste)||' '||nvl(n_namlaste,e_namlaste),1,60) ;
            e_namempe := substr(get_tlistval_name('CODTITLE',e_codtitle,'101')||e_namfirste||' '||e_namlaste,1,60) ;
      else
            n_namempe := null ;
            e_namempe := null ;
      end if;

      if  n_codtitle  is not null  or n_namfirstt is not null  or n_namlastt  is not null  then
            n_namempt := substr(v_titlet||nvl(n_namfirstt,e_namfirstt)||' '||nvl(n_namlastt,e_namlastt),1,60) ;
            e_namempt := substr(get_tlistval_name('CODTITLE',e_codtitle,'102')||e_namfirstt||' '||e_namlastt,1,60) ;
      else
            n_namempt := null ;
            e_namempt := null ;
      end if;

      if  n_codtitle  is not null  or n_namfirst3 is not null  or n_namlast3  is not null  then
            n_namemp3 := substr(v_title3||nvl(n_namfirst3,e_namfirst3)||' '||nvl(n_namlast3,e_namlast3),1,60) ;
            e_namemp3 := substr(get_tlistval_name('CODTITLE',e_codtitle,'103')||e_namfirst3||' '||e_namlast3,1,60) ;
      else
            n_namemp3 := null ;
            e_namemp3 := null ;
      end if;

      if  n_codtitle  is not null  or n_namfirst4 is not null  or n_namlast4  is not null  then
            n_namemp4 := substr(v_title4||nvl(n_namfirst4,e_namfirst4)||' '||nvl(n_namlast4,e_namlast4),1,60) ;
            e_namemp4 := substr(get_tlistval_name('CODTITLE',e_codtitle,'104')||e_namfirst4||' '||e_namlast4,1,60) ;
      else
            n_namemp4 := null ;
            e_namemp4 := null ;
      end if;

      if   n_codtitle  is not null  or n_namfirst5 is not null  or n_namlast5  is not null  then
          n_namemp5 := substr(v_title5||nvl(n_namfirst5,e_namfirst5)||' '||nvl(n_namlast5,e_namlast5),1,60) ;
          e_namemp5 := substr(get_tlistval_name('CODTITLE',e_codtitle,'105')||e_namfirst5||' '||e_namlast5,1,60) ;
      else
          n_namemp5 := null ;
          e_namemp5 := null ;
      end if;

      upd_log1(p_codempid,'temploy1','11','codtitle' ,'C',e_codtitle ,n_codtitle ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namfirste','C',e_namfirste,n_namfirste,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namfirstt','C',e_namfirstt,n_namfirstt,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namfirst3','C',e_namfirst3,n_namfirst3,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namfirst4','C',e_namfirst4,n_namfirst4,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namfirst5','C',e_namfirst5,n_namfirst5,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namlaste' ,'C',e_namlaste ,n_namlaste ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namlastt' ,'C',e_namlastt ,n_namlastt ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namlast3' ,'C',e_namlast3 ,n_namlast3 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namlast4' ,'C',e_namlast4 ,n_namlast4 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','namlast5' ,'C',e_namlast5 ,n_namlast5 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','nickname' ,'C',e_nickname ,n_nickname ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','nicknamt' ,'C',e_nicknamt ,n_nicknamt ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','nicknam3' ,'C',e_nicknam3 ,n_nicknam3 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','nicknam4' ,'C',e_nicknam4 ,n_nicknam4 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log1(p_codempid,'temploy1','11','nicknam5' ,'C',e_nicknam5 ,n_nicknam5 ,'N',v_codcomp,p_coduser,p_lang);

      begin
      update temploy1
                      set codtitle  = nvl(n_codtitle, codtitle ),
                          namfirste = nvl(n_namfirste, namfirste  ),
                          namfirstt = nvl(n_namfirstt, namfirstt  ),
                          namfirst3 = nvl(n_namfirst3, namfirst3  ),
                          namfirst4 = nvl(n_namfirst5, namfirst4  ),
                          namfirst5 = nvl(n_namfirst5, namfirst5  ),
                          namlaste  = nvl(n_namlaste, namlaste  ),
                          namlastt  = nvl(n_namlastt, namlastt  ),
                          namlast3  = nvl(n_namlast3, namlast3  ),
                          namlast4  = nvl(n_namlast4, namlast4  ),
                          namlast5  = nvl(n_namlast5, namlast5  ),
                          namempe   = nvl(n_namempe,  namempe   ),
                          namempt   = nvl(n_namempt,  namempt   ),
                          namemp3   = nvl(n_namemp3,  namemp3   ),
                          namemp4   = nvl(n_namemp4,  namemp4   ),
                          namemp5   = nvl(n_namemp5,  namemp5   ),
                          nickname   = nvl(n_nickname,  nickname   ),
                          nicknamt   = nvl(n_nicknamt,  nicknamt   ),
                          nicknam3   = nvl(n_nicknam3,  nicknam3   ),
                          nicknam4   = nvl(n_nicknam4,  nicknam4   ),
                          nicknam5   = nvl(n_nicknam5,  nicknam5   ),
                          coduser   = p_coduser,
                          dteupd    = to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')--:tnamech.dteupd
                    where codempid = p_codempid;
      end ;

      begin
          select count(*) into v_numseq
           from thisname
          where codempid = p_codempid;
      exception when no_data_found then
          v_numseq := 0;
      end;
      v_numseq := v_numseq + 1;
      v_dtereq := trunc(sysdate);
      upd_log2(p_codempid,'thisname','11',v_numseq,'codtitle' ,'D','dtechg',null,v_dtereq,'C',e_codtitle ,n_codtitle ,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namfirste','D','dtechg',null,v_dtereq,'C',e_namfirste,n_namfirste,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namfirstt','D','dtechg',null,v_dtereq,'C',e_namfirstt,n_namfirstt,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namfirst3','D','dtechg',null,v_dtereq,'C',e_namfirst3,n_namfirst3,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namfirst4','D','dtechg',null,v_dtereq,'C',e_namfirst4,n_namfirst4,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namfirst5','D','dtechg',null,v_dtereq,'C',e_namfirst5,n_namfirst5,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namlaste' ,'D','dtechg',null,v_dtereq,'C',e_namlaste ,n_namlaste ,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namlastt' ,'D','dtechg',null,v_dtereq,'C',e_namlastt ,n_namlastt ,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namlast3' ,'D','dtechg',null,v_dtereq,'C',e_namlast3 ,n_namlast3 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namlast4' ,'D','dtechg',null,v_dtereq,'C',e_namlast4 ,n_namlast4 ,'N',v_codcomp,p_coduser,p_lang);
      upd_log2(p_codempid,'thisname','11',v_numseq,'namlast5' ,'D','dtechg',null,v_dtereq,'C',e_namlast5 ,n_namlast5 ,'N',v_codcomp,p_coduser,p_lang);


       if n_codtitle  is  null then
        e_codtitle  := n_codtitle;
       end if;

       if n_namfirste is  null then
        e_namfirste := n_namfirste;
       end if;

       if n_namfirstt is  null then
        e_namfirstt := n_namfirstt;
       end if;

       if n_namfirst3 is  null then
        e_namfirst3 := n_namfirst3;
       end if;
       if n_namfirst4 is  null then
        e_namfirst4 := n_namfirst4;
       end if;
       if n_namfirst5 is  null then
        e_namfirst5 := n_namfirst5;
       end if;

       if n_namlaste is  null then
        e_namlaste := n_namlaste;
       end if;
       if n_namlastt is  null then
        e_namlastt := n_namlastt;
       end if;
       if n_namlast3 is  null then
        e_namlast3 := n_namlast3;
       end if;
       if n_namlast4 is  null then
        e_namlast4 := n_namlast4;
       end if;
       if n_namlast5 is  null then
        e_namlast5 := n_namlast5;
       end if;

          begin
              update  thisname
                  set codtitle  = nvl(n_codtitle ,codtitle ) ,
                      namfirste = nvl(n_namfirste,namfirste) ,
                      namfirstt = nvl(n_namfirstt,namfirstt) ,
                      namfirst3 = nvl(n_namfirst3,namfirst3) ,
                      namfirst4 = nvl(n_namfirst4,namfirst4) ,
                      namfirst5 = nvl(n_namfirst5,namfirst5) ,
                      namlaste  = nvl(n_namlaste ,namlaste ) ,
                      namlastt  = nvl(n_namlastt ,namlastt ) ,
                      namlast3  = nvl(n_namlast3 ,namlast3 ) ,
                      namlast4  = nvl(n_namlast4 ,namlast4 ) ,
                      namlast5  = nvl(n_namlast5 ,namlast5 ) ,
                      namempe   = nvl(n_namempe, namempe   ) ,
                      namempt   = nvl(n_namempt, namempt   ) ,
                      namemp3   = nvl(n_namemp3, namemp3   ) ,
                      namemp4   = nvl(n_namemp4, namemp4   ) ,
                      namemp5   = nvl(n_namemp5, namemp5   ) ,
                      coduser   = p_coduser ,
                      dteupd    = to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') ,
                      deschang  = p_desnote
              where   codempid  = p_codempid
              and     dtechg    = p_dtereq;

              if sql%notfound then
                  insert into thisname
                                    (
                                     codempid,dtechg,codtitle,namfirste,namfirstt,
                                     namfirst3,namfirst4,namfirst5,namlaste,namlastt,
                                     namlast3,namlast4,namlast5,namempe,namempt,
                                     namemp3,namemp4,namemp5,coduser,deschang
                                     )
                       values
                                    (
                                     p_codempid,p_dtereq,e_codtitle,e_namfirste,e_namfirstt,
                                     e_namfirst3,e_namfirst4,e_namfirst5,e_namlaste,e_namlastt,
                                     e_namlast3,e_namlast4,e_namlast5,e_namempe,e_namempt,
                                     e_namemp3,e_namemp4,e_namemp5,p_coduser,p_desnote
                                     );
              end if;
          end ;

  end;
  --

  procedure update_expense(p_coduser  in varchar2,
                           p_codempid in varchar2,
                           p_codcomp  in varchar2,
                           p_dtereq   in varchar2,
                           p_numseq   in number,
                           p_lang     in varchar2) IS

      v_exist         boolean;
      v_upd           boolean;
      v_dteyrepay     number;
      v_amtdeduct     varchar2(20 char);
      v_coddeduct     varchar2(20 char);


      cursor c_tempded is
          select amtdeduct,amtspded,rowid
            from tempded
           where codempid  = p_codempid
             and coddeduct = v_coddeduct;

      cursor c_tlastempd is
          select rowid
            from tlastempd
           where dteyrepay = v_dteyrepay
             and codempid  = p_codempid;

      cursor c_temeslog3 is
          select codempid,numpage,coddeduct,typdeduct,desnew,
                 stddec(desnew,codempid,v_chken) amt
            from temeslog3
           where codempid = p_codempid
             and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq   = p_numseq
             and numpage  in ('281','282','283');
  begin
      for i in c_temeslog3 loop
          if nvl(i.amt,0) >= 0 then
              v_dteyrepay := to_number(to_char(sysdate,'yyyy')) - v_zyear;
              v_coddeduct := i.coddeduct;
              v_amtdeduct := i.desnew;
              v_exist := false;
              v_upd   := false;

              for j in c_tempded loop
                  v_exist := true;
                  v_upd   := true;
                  if i.typdeduct = 'E' then
                      upd_log3(p_codempid,'tempded','281',i.typdeduct,i.coddeduct,j.amtdeduct,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'D' then
                      upd_log3(p_codempid,'tempded','282',i.typdeduct,i.coddeduct,j.amtdeduct,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'O' then
                      upd_log3(p_codempid,'tempded','283',i.typdeduct,i.coddeduct,j.amtdeduct,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  end if;

                  update tempded
                  set    amtdeduct = i.desnew,
                         coduser   = p_coduser
                  where  codempid  = i.codempid
                    and  coddeduct = i.coddeduct;
              end loop;

              if not v_exist   then
                 v_upd := true;
                  if i.typdeduct = 'E' then
                      upd_log3(p_codempid,'tempded','281',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'D' then
                      upd_log3(p_codempid,'tempded','282',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'O' then
                      upd_log3(p_codempid,'tempded','283',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  end if;
                 insert into tempded
                            (codempid,coddeduct,amtdeduct,coduser)
                      values
                            (i.codempid,i.coddeduct,i.desnew,p_coduser);
              end if;

              if v_upd or not v_exist then
                  v_exist := false;
                  for r_tlastempd in c_tlastempd loop
                      v_exist := true;
                      update tlastempd
                          set codcomp    = p_codcomp,
                              amtdeduct  = v_amtdeduct,
                              dteupd     = trunc(sysdate),
                              coduser    = p_coduser
                          where rowid = r_tlastempd.rowid;
                  end loop;
                  if not v_exist then
                      insert into tlastempd
                                          (
                                           dteyrepay,codempid,coddeduct,
                                           codcomp,amtdeduct,amtspded,
                                           dteupd,coduser
                                           )
                              values
                                          (
                                           v_dteyrepay,p_codempid,v_coddeduct,
                                           p_codcomp,v_amtdeduct,null,
                                           trunc(sysdate),p_coduser
                                           );
                  end if;
              end if;

          end if;
      end loop;

  end ; --- end procedure update_expense
  --
  procedure update_expensesp(p_coduser  in varchar2,
                             p_codempid in varchar2,
                             p_codcomp  in varchar2,
                             p_dtereq   in varchar2,
                             p_numseq   in number,
                             p_lang     in varchar2) IS

      v_exist         boolean;
      v_upd           boolean;
      v_dteyrepay     number;
      v_amtdeduct     varchar2(20 char);
      v_coddeduct     varchar2(20 char);

      cursor c_tempded is
          select amtspded,rowid
            from tempded
           where codempid  = p_codempid
             and coddeduct = v_coddeduct;

      cursor c_tlastempd is
          select rowid
            from tlastempd
           where dteyrepay = v_dteyrepay
             and codempid  = p_codempid;

      cursor c_temeslog3 is
          select codempid,numpage,coddeduct,typdeduct,desnew,
                 stddec(desnew,codempid,v_chken) amt
            from temeslog3
           where codempid = p_codempid
             and dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
             and numseq   = p_numseq
             and numpage  in ('881','882','883'); --user36 STA3590329 01/11/2016
  begin
      for i in c_temeslog3 loop
          if nvl(i.amt,0) >= 0 then
              v_dteyrepay := to_number(to_char(sysdate,'yyyy')) - v_zyear;
              v_coddeduct := i.coddeduct;
              v_amtdeduct := i.desnew;
              v_exist := false;
              v_upd   := false;

              for j in c_tempded loop
                  v_exist := true;
                  v_upd   := true;
                  if i.typdeduct = 'E' then
                      upd_log3(p_codempid,'tempded','281',i.typdeduct,i.coddeduct,j.amtspded,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'D' then
                      upd_log3(p_codempid,'tempded','282',i.typdeduct,i.coddeduct,j.amtspded,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'O' then
                      upd_log3(p_codempid,'tempded','283',i.typdeduct,i.coddeduct,j.amtspded,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  end if;

                  update tempded
                  set    amtspded  = i.desnew,
                         coduser   = p_coduser
                  where  codempid  = i.codempid
                    and  coddeduct = i.coddeduct;
              end loop;

              if not v_exist then
                 v_upd := true;
                  if i.typdeduct = 'E' then
                      upd_log3(p_codempid,'tempded','281',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'D' then
                      upd_log3(p_codempid,'tempded','282',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  elsif i.typdeduct = 'O' then
                      upd_log3(p_codempid,'tempded','283',i.typdeduct,i.coddeduct,null,v_amtdeduct,p_codcomp,p_coduser,p_lang);
                  end if;
                 insert into tempded
                            (codempid,coddeduct,amtspded,coduser)
                      values
                            (i.codempid,i.coddeduct,i.desnew,p_coduser);
              end if;

              if v_upd or not v_exist then
                  v_exist := false;
                  for r_tlastempd in c_tlastempd loop
                      v_exist := true;
                      update tlastempd
                          set codcomp    = p_codcomp,
                              amtspded   = v_amtdeduct,
                              dteupd     = trunc(sysdate),
                              coduser    = p_coduser
                          where rowid = r_tlastempd.rowid;
                  end loop;
                  if not v_exist then
                      insert into tlastempd
                                          (
                                           dteyrepay,codempid,coddeduct,
                                           codcomp,amtdeduct,amtspded,
                                           dteupd,coduser
                                           )
                              values
                                          (
                                           v_dteyrepay,p_codempid,v_coddeduct,
                                           p_codcomp,null,v_amtdeduct,
                                           trunc(sysdate),p_coduser
                                           );
                  end if;
              end if;

          end if;
      end loop;

  end; --- end procedure update_expensesp

  function get_adrcont_name( p_codempid   varchar2,
                           p_flg        number,
                           p_lang       varchar2) return varchar2 is

     v_data       varchar2(200 char);
     v_adrreg     varchar2(200 char);
     v_adrcont    varchar2(200 char);

  begin
      begin
          select decode(p_lang,'101',adrrege,
                               '102',adrregt,
                               '103',adrreg3,
                               '104',adrreg4,
                               '105',adrreg5,adrrege),
                 decode(p_lang,'101',adrconte,
                               '102',adrcontt,
                               '103',adrcont3,
                               '104',adrcont4,
                               '105',adrcont5,adrconte)

            into v_adrreg,v_adrcont
            from temploy2
           where codempid = p_codempid;
      exception when no_data_found then null;
      end;

      if p_flg  = 1 then
          v_data := v_adrreg;
      elsif p_flg = 2 then
          v_data := v_adrcont;
      end if;
    return v_data;
  end;
  --

  procedure move_document (p_filename in varchar2) is
    v_pathdoces   varchar2(500 char) := get_tsetup_value('PATHDOCES');
    v_folder      varchar2(65 char);
  begin
      begin
          select folder into v_folder
            from tfolderd
           where codapp = 'HRPMC2E';
      exception when no_data_found then
          null;
      end;
      htp.print('<html>');
      htp.print('<head>');
      htp.print('<title>Move File Path</title>');
      htp.print('<script language="javascript">');
      htp.print('function move_file() {');
      htp.print('  var WshShell = new ActiveXObject("WScript.Shell");');
      htp.print('  WshShell.Run("%comspec% /c for %f in ('||p_filename||') do move %f '||v_pathdoces||v_folder||'\\ ");');
      htp.print('  WshShell.Quit;');
      htp.print('  window.close();');
      htp.print('}');
      htp.print('function auto_page() {');
      htp.print('  setTimeout("move_file()",2000);');
      htp.print('}');
      htp.print('</script>');
      htp.print('</head>');
      htp.print('<body leftmargin="0" onLoad="auto_page()" topmargin="0" onUnload="move_file()">');
      htp.print('</body>');
      htp.print('</html>');
  end;
  --

  function get_desc_temeslog1(p_codempid in varchar2,
                              p_dtereq  in date,
                              p_numseq  in number,
                              p_fldedit in varchar2) RETURN varchar2 IS

     v_desnew      temeslog1.desnew%type;
  begin
     begin
          select desnew
            into v_desnew
            from temeslog1
           where codempid = p_codempid
             and dtereq   = p_dtereq
             and numseq   = p_numseq
             and numpage  = 53
             and fldedit  =  p_fldedit;
          exception when no_data_found then
                v_desnew  := null;
     end;
     return(v_desnew);
  end;
  --


  procedure get_index(json_str_input in clob, json_str_output out clob) is
  json_obj      json_object_t;
  obj_row       json_object_t;
  obj_data      json_object_t;



  v_codpos      varchar2(4 char);
  v_nextappr    varchar2(1000 char);
  v_dtest       date;
  v_dteen       date;
  v_rcnt        number;
  v_appno       varchar2(100 char);
  v_chk         varchar2(100 char) := ' ';
  v_row         number := 0;

  type typ_ is table of varchar2(250 char) index by binary_integer;
  v_type    typ_;

    cursor c_hrms33u_c1 is
      select codempid,dtereq,numseq,typ,staappr,appno,
           codappr,remarkap,rouno,codecomp,
           dteappr,qtyapp,dteinput,dteapph,rcnt,
           get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status
      from(select codempid,dtereq,numseq,typ,staappr,appno,
                  codappr,remarkap,rouno,codecomp,
                  dteappr,qtyapp,dteinput,dteapph,rownum rcnt
             from (select codempid,dtereq,numseq,typ,staappr,a.approvno appno,
                          codappr,remarkap,a.routeno rouno,a.codcomp codecomp,
                          a.dteappr,b.approvno qtyapp,dteinput,dteapph
                     from (select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                                  codappr,remarkap,routeno,codcomp,
                                  dteappr,dteinput,dteapph
                            from tempch
                           where staappr in ('P','A')) a ,twkflowh b
                where ('Y' = chk_workflow.check_privilege('HRES32E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
                       -- Replace Approve
                       or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                                   from twkflowde c
                                                                  where c.routeno  = a.routeno
                                                                    and c.codempid = v_codappr)
                             and    trunc(((sysdate - nvl(a.dteapph,a.dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES32E')))

                  and a.routeno  = b.routeno
                  and a.codcomp  like p_codcomp||'%'
                  and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                         order by codempid,dtereq,typ,numseq))

        order by rcnt;

    cursor c_hrms33u_c2 is
      select codempid,dtereq,numseq,typ,staappr,approvno,
            codappr,remarkap,routeno,codcomp,
            dteappr,rcnt,
            get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status
                from (select codempid,dtereq,numseq,typ,staappr,approvno,
                             codappr,remarkap,routeno,codcomp,
                             dteappr,rownum rcnt
                from (select codempid,dtereq,numseq,typ,staappr,approvno,
                             codappr,remarkap,routeno,codcomp,
                             dteappr
                from (select codempid,dtereq,numseq,typchg typ ,staappr,approvno,
                             codappr,remarkap,routeno,codcomp,
                             dteappr
                  from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 1
                   and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E1'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             union
             select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                    codappr,remarkap,routeno,codcomp,
                    dteappr
               from tempch
             where codcomp like p_codcomp||'%'
               and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and typchg   = 2
               and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                   from tapempch
                                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                    and codappr = v_codappr
                                                    and typreq  = 'HRES32E2'
                                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             union
             select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                   codappr,remarkap,routeno,codcomp,
                   dteappr
               from tempch
             where codcomp like p_codcomp||'%'
               and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and typchg   = 3
               and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                   from tapempch
                                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                    and codappr = v_codappr
                                                    and typreq  = 'HRES32E3'
                                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             union
             select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                   codappr,remarkap,routeno,codcomp,
                   dteappr
               from tempch
             where codcomp like p_codcomp||'%'
               and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and typchg   = 4
               and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                   from tapempch
                                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                    and codappr = v_codappr
                                                    and typreq  = 'HRES32E4'
                                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             union
             select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                   codappr,remarkap,routeno,codcomp,
                   dteappr
               from tempch
             where codcomp like p_codcomp||'%'
               and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and typchg   = 5
               and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                   from tapempch
                                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                    and codappr = v_codappr
                                                    and typreq  = 'HRES32E5'
                                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             union
             select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                   codappr,remarkap,routeno,codcomp,
                   dteappr
               from tempch
             where codcomp like p_codcomp||'%'
               and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and typchg   = 6
               and (codempid ,dtereq,numseq) in (select codempid,dtereq,numseq
                                                   from tapempch
                                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                    and codappr = v_codappr
                                                    and typreq  = 'HRES32E6'
                                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )

               )
     order by  codempid,dtereq,typ,numseq))

     order by rcnt;

  begin
    initial_value(json_str_input);

      v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
      v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');

      -- count total records
      if p_staappr = 'P' then
          begin
              select count(codempid) into v_rcnt
                from (select codempid,dtereq,numseq,typchg typ ,staappr,approvno,
                             codappr,remarkap,routeno,codcomp,
                             dteappr,dteinput,dteapph
                        from tempch
                       where staappr in ('P','A')
                         and typchg = 1
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 2
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 3
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 4
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 5
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 6
                union
                     select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                            codappr,remarkap,routeno,codcomp,
                            dteappr,dteinput,dteapph
                       from tempch
                      where staappr in ('P','A')
                        and typchg = 7) a ,twkflowh b


              where ('Y' = chk_workflow.check_privilege('HRES32E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
                          -- Replace Approve
                          or ((a.routeno,nvl(a.approvno,0)+ 1) in (  select routeno,numseq
                                                                       from twkflowde c
                                                                      where c.routeno  = a.routeno
                                                                        and c.codempid = v_codappr)
                               and    trunc(((sysdate - nvl(a.dteapph,a.dteinput))*1440)) >= (select  hrtotal  from twkflpf where codappr ='HRES32E')))

                and a.routeno = b.routeno
                and a.codcomp like p_codcomp||'%'
                and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
             order by codempid,dtereq,typ,numseq;

        exception when no_data_found then
            null;
        end;
      else
          begin
          select count(codempid) into v_rcnt
            from (select codempid,dtereq,numseq,typchg typ ,staappr,approvno,
                         codappr,remarkap,routeno,codcomp,
                         dteappr
                    from tempch
                   where codcomp like p_codcomp||'%'
                     and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                     and typchg   = 1
                     and (codempid,dtereq,numseq) in (select codempid,dtereq,numseq
                                                        from tapempch
                                                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                         and codappr = v_codappr
                                                         and typreq  = 'HRES32E1'
                                                         and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
            union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 2
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E2'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
            union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 3
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E3'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
            union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 4
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E4'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
            union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 5
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E5'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
               union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 6
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E6'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
               union
                 select codempid,dtereq ,numseq,typchg typ ,staappr,approvno,
                       codappr,remarkap,routeno,codcomp,
                       dteappr
                   from tempch
                 where codcomp like p_codcomp||'%'
                   and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
                   and typchg   = 7
                   and (codempid,dtereq,numseq) in ( select codempid,dtereq,numseq
                                                       from tapempch
                                                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                        and codappr = v_codappr
                                                        and typreq  = 'HRES32E7'
                                                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )

                   )

             order by  codempid;
        exception when no_data_found then
           null;
        end;
      end if;
      --

      v_type(1)   := get_label_name('HRES32EC1',global_v_lang,60);
      v_type(2)   := get_label_name('HRES32EC1',global_v_lang,70);
      v_type(3)   := get_label_name('HRES32EC1',global_v_lang,80);
      v_type(4)   := get_label_name('HRES32EC1',global_v_lang,90);
      v_type(5)   := get_label_name('HRES32EC1',global_v_lang,100);
      v_type(6)   := get_label_name('HRES32EC1',global_v_lang,110);
      v_type(7)   := get_label_name('HRES32ET7',global_v_lang,10);
      obj_row := json_object_t();
      -- get data
      if p_staappr = 'P' then

        for r1 in c_hrms33u_c1 loop
          v_appno  := nvl(r1.appno,0) + 1;
          if nvl(r1.appno,0)+1 = r1.qtyapp then
             v_chk := 'E' ;
          else
             v_chk := v_appno;
          end if;
          --
          v_row := v_row + 1;
         obj_data := json_object_t();
         obj_data.put('coderror','200');
         obj_data.put('desc_coderror','');
         obj_data.put('approvno', nvl(v_appno, ''));
         obj_data.put('chk_appr', nvl(v_chk, ''));
         obj_data.put('codempid', nvl(r1.codempid, ''));
         obj_data.put('desc_codempid', nvl(get_temploy_name(r1.codempid,global_v_lang),' '));
         obj_data.put('image',get_emp_img(r1.codempid));
         obj_data.put('dtereq', nvl(to_char(r1.dtereq,'dd/mm/yyyy'),' '));
         obj_data.put('numseq', nvl(r1.numseq, ''));
         obj_data.put('typ', nvl(r1.typ, ''));
         obj_data.put('desc_typ', nvl(v_type(r1.typ), ''));
         obj_data.put('status', nvl(r1.status, ''));
         obj_data.put('staappr', nvl(r1.staappr, ''));
         obj_data.put('desc_codappr', nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
         obj_data.put('dteappr', nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
         obj_data.put('remark', nvl(r1.remarkap, ''));
         obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
       obj_row.put(to_char(v_row-1), obj_data);
        end loop;
      else

        for r1 in c_hrms33u_c2 loop
          --
          v_nextappr := null;
          if r1.staappr = 'A' then
            v_nextappr := chk_workflow.get_next_approve('HRES32E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
          end if;
          --

         v_row := v_row + 1;
         obj_data := json_object_t();
         obj_data.put('coderror','200');
         obj_data.put('desc_coderror','');
         obj_data.put('approvno', nvl(v_appno, ''));
         obj_data.put('chk_appr', nvl(v_chk, ''));
         obj_data.put('codempid', nvl(r1.codempid, ''));
         obj_data.put('desc_codempid', nvl(get_temploy_name(r1.codempid,global_v_lang),' '));
         obj_data.put('image',get_emp_img(r1.codempid));
         obj_data.put('dtereq', nvl(to_char(r1.dtereq,'dd/mm/yyyy'),' '));
         obj_data.put('numseq', nvl(r1.numseq, ''));
         obj_data.put('typ', nvl(r1.typ, ''));
         obj_data.put('desc_typ', nvl(v_type(r1.typ), ''));
         obj_data.put('status', nvl(r1.status, ''));
         obj_data.put('staappr', nvl(r1.staappr, ''));
         obj_data.put('desc_codappr', nvl(get_temploy_name(r1.codappr,global_v_lang),' '));
         obj_data.put('dteappr', nvl(to_char(r1.dteappr,'dd/mm/yyyy'),' '));
         obj_data.put('remark', nvl(r1.remarkap, ''));
         obj_data.put('desc_codempap', nvl(v_nextappr, ''));
         obj_row.put(to_char(v_row-1), obj_data);

        end loop;
      end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_index;
  --
--
  -- name_change
  procedure get_detail2_tab1(json_str_input in clob, json_str_output out clob) is
    obj_row                 json_object_t;
    v_rcnt                  number := 0;
    v_num                   number := 0;
    v_concat                varchar2(1 char);
    --
    tab2_stamilit_flg       varchar2(10 char) := 'N';
    tab2_adrrege_flg        varchar2(10 char) := 'N';
    tab2_adrregt_flg        varchar2(10 char) := 'N';
    tab2_adrreg3_flg        varchar2(10 char) := 'N';
    tab2_adrreg4_flg        varchar2(10 char) := 'N';
    tab2_adrreg5_flg        varchar2(10 char) := 'N';
    adrreg_flg              varchar2(10 char) := 'N';
    tab2_codsubdistr_flg    varchar2(10 char) := 'N';
    tab2_coddistr_flg       varchar2(10 char) := 'N';
    tab2_codprovr_flg       varchar2(10 char) := 'N';
    tab2_codcntyr_flg       varchar2(10 char) := 'N';
    tab2_codpostr_flg       varchar2(10 char) := 'N';
    tab2_adrconte_flg       varchar2(10 char) := 'N';
    tab2_adrcontt_flg       varchar2(10 char) := 'N';
    tab2_adrcont3_flg       varchar2(10 char) := 'N';
    tab2_adrcont4_flg       varchar2(10 char) := 'N';
    tab2_adrcont5_flg       varchar2(10 char) := 'N';
    adrcont_flg             varchar2(10 char) := 'N';
    tab2_codsubdistc_flg    varchar2(10 char) := 'N';
    tab2_coddistc_flg       varchar2(10 char) := 'N';
    tab2_codprovc_flg       varchar2(10 char) := 'N';
    tab2_codcntyc_flg       varchar2(10 char) := 'N';
    tab2_codpostc_flg       varchar2(10 char) := 'N';
    tab2_numtelec_flg       varchar2(10 char) := 'N';
    tab2_numoffid_flg       varchar2(10 char) := 'N';
    tab2_adrissue_flg       varchar2(10 char) := 'N';
    tab2_codprovi_flg       varchar2(10 char) := 'N';
    tab2_dteoffid_flg       varchar2(10 char) := 'N';
    tab2_numlicid_flg       varchar2(10 char) := 'N';
    tab2_dtelicid_flg       varchar2(10 char) := 'N';
    tab2_numpasid_flg       varchar2(10 char) := 'N';
    tab2_dtepasid_flg       varchar2(10 char) := 'N';
    tab2_numprmid_flg       varchar2(10 char) := 'N';
    tab2_dteprmst_flg       varchar2(10 char) := 'N';
    tab2_dteprmen_flg       varchar2(10 char) := 'N';
    tab2_stamarry_flg       varchar2(10  char) := 'N';
    tab2_email_emp_flg      varchar2(10  char) := 'N';
    tab2_nummobile_flg      varchar2(10 char) := 'N';
    tab2_lineid_flg         varchar2(10 char) := 'N';
    tab2_numvisa_flg        varchar2(10 char) := 'N';
    tab2_dtevisaexp_flg     varchar2(10 char) := 'N';
    tab2_codclnsc_flg       varchar2(10 char) := 'N';
    tab2_dteretire_flg      varchar2(10 char) := 'N';
    tab2_codbank_flg        varchar2(10 char) := 'N';
    tab2_numbank_flg        varchar2(10 char) := 'N';
    tab2_numbrnch_flg       varchar2(10 char) := 'N';
    tab2_codbank2_flg       varchar2(10 char) := 'N';
    tab2_numbank2_flg       varchar2(10 char) := 'N';
    tab2_numbrnch2_flg      varchar2(10 char) := 'N';
    tab2_amtbank_flg        varchar2(10 char) := 'N';
    tab2_amttranb_flg       varchar2(10 char) := 'N';
    tab2_qtychedu_flg       varchar2(10 char) := 'N';
    tab2_qtychned_flg       varchar2(10 char) := 'N';
    tab2_namspe_flg         varchar2(10 char) := 'N';
    tab2_namspt_flg         varchar2(10 char) := 'N';
    tab2_namsp3_flg         varchar2(10 char) := 'N';
    tab2_namsp4_flg         varchar2(10 char) := 'N';
    tab2_namsp5_flg         varchar2(10 char) := 'N';
    tab2_numspid_flg        varchar2(10 char) := 'N';
    tab2_dtespbd_flg        varchar2(10 char) := 'N';
    tab2_codspocc_flg       varchar2(10 char) := 'N';
    tab2_desnoffi_flg       varchar2(10 char) := 'N';
    tab2_dtemarry_flg       varchar2(10 char) := 'N';
    tab2_desplreg_flg       varchar2(10 char) := 'N';
    tab2_codsppro_flg       varchar2(10 char) := 'N';
    tab2_codspcty_flg       varchar2(10 char) := 'N';
    tab2_desnote_flg        varchar2(10 char) := 'N';
    tab2_codtitle_flg       varchar2(10 char) := 'N';
    tab2_namfirste_flg      varchar2(10 char) := 'N';
    tab2_namfirstt_flg      varchar2(10 char) := 'N';
    tab2_namfirst3_flg      varchar2(10 char) := 'N';
    tab2_namfirst4_flg      varchar2(10 char) := 'N';
    tab2_namfirst5_flg      varchar2(10 char) := 'N';
    namfirst_flg            varchar2(10 char) := 'N';
    tab2_namlaste_flg       varchar2(10 char) := 'N';
    tab2_namlastt_flg       varchar2(10 char) := 'N';
    tab2_namlast3_flg       varchar2(10 char) := 'N';
    tab2_namlast4_flg       varchar2(10 char) := 'N';
    tab2_namlast5_flg       varchar2(10 char) := 'N';
    namlast_flg             varchar2(10 char) := 'N';
    tab2_codempidsp_flg     varchar2(10  char)   := 'N';
    tab2_stalife_flg        varchar2(10  char)   := 'N';
    tab2_dtedthsp_flg       varchar2(10  char)   := 'N';
    tab2_staincom_flg       varchar2(10  char)   := 'N';
    tab2_numfasp_flg        varchar2(10  char)   := 'N';
    tab2_nummosp_flg        varchar2(10  char)   := 'N';
    tab2_filename_flg       varchar2(10  char)   := 'N';
    tab2_typtrav_flg        varchar2(10 char)   := 'N';
    tab2_qtylength_flg      varchar2(10 char)   := 'N';
    tab2_carlicen_flg       varchar2(10 char)   := 'N';
    tab2_typfuel_flg        varchar2(10 char)   := 'N';
    tab2_codbusno_flg       varchar2(10 char)   := 'N';
    tab2_codbusrt_flg       varchar2(10 char)   := 'N';
    v_folder              varchar2(100);
    path_filename           varchar2(1000 char);


    cursor c_temeslog1 is
    select *
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  like '2%';


  begin
  initial_value(json_str_input);
    begin
      select stamilit,adrrege,adrregt,adrreg3,adrreg4,
             adrreg5,codsubdistr,coddistr,codprovr,codcntyr,
             codpostr,adrconte,adrcontt,adrcont3,adrcont4,
             adrcont5,codsubdistc,coddistc,codprovc,codcntyc,
             codpostc,numtelec,numoffid,adrissue,codprovi,
             dteoffid,numlicid,dtelicid,numpasid,dtepasid,
             numprmid,dteprmst,dteprmen,b.stamarry,b.email,
             b.nummobile,b.lineid,a.numvisa,a.codclnsc,b.dteretire,
             b.typtrav,b.carlicen,b.typfuel,b.qtylength,b.codbusno,b.codbusrt
      into   tab2_stamilit,tab2_adrrege,tab2_adrregt,tab2_adrreg3,tab2_adrreg4,
             tab2_adrreg5,tab2_codsubdistr,tab2_coddistr,tab2_codprovr,tab2_codcntyr,
             tab2_codpostr,tab2_adrconte,tab2_adrcontt,tab2_adrcont3,tab2_adrcont4,
             tab2_adrcont5,tab2_codsubdistc,tab2_coddistc,tab2_codprovc,tab2_codcntyc,
             tab2_codpostc,tab2_numtelec,tab2_numoffid,tab2_adrissue,tab2_codprovi,
             tab2_dteoffid,tab2_numlicid,tab2_dtelicid,tab2_numpasid,tab2_dtepasid,
             tab2_numprmid,tab2_dteprmst,tab2_dteprmen,tab2_stamarry,tab2_email_emp,
             tab2_nummobile,tab2_lineid,tab2_numvisa,tab2_codclnsc,tab2_dteretire,
             tab2_typtrav,tab2_carlicen,tab2_typfuel,tab2_qtylength,tab2_codbusno,tab2_codbusrt
        from temploy2 a,temploy1 b
       where b.codempid = b_index_codempid
         and a.codempid (+)= b.codempid;
      exception when no_data_found then
        tab2_stamilit := null;    tab2_adrrege  := null;      tab2_adrregt  := null;
        tab2_adrreg3  := null;    tab2_adrreg4  := null;      tab2_adrreg5  := null;
        tab2_codsubdistr := null; tab2_coddistr := null;      tab2_codprovr := null;
        tab2_codcntyr := null;    tab2_codpostr := null;      tab2_adrconte := null;
        tab2_adrcontt := null;    tab2_adrcont3 := null;      tab2_adrcont4 := null;
        tab2_adrcont5 := null;    tab2_codsubdistc  := null;  tab2_coddistc := null;
        tab2_codprovc := null;    tab2_codcntyc := null;      tab2_codpostc := null;
        tab2_numtelec := null;    tab2_numoffid := null;      tab2_adrissue := null;
        tab2_codprovi := null;    tab2_dteoffid := null;      tab2_numlicid := null;
        tab2_dtelicid := null;    tab2_numpasid := null;      tab2_dtepasid := null;
        tab2_numprmid := null;    tab2_dteprmst := null;      tab2_dteprmen := null;
        tab2_stamarry := null;    tab2_email_emp:= null;      tab2_nummobile := null;
        tab2_lineid   := null;    tab2_numvisa  := null;      tab2_codclnsc := null;
        tab2_dteretire  := null;  tab2_typtrav  := null;      tab2_qtylength := null;
        tab2_carlicen := null;    tab2_typfuel  := null;      tab2_codbusno  := null;
        tab2_codbusrt := null;
      end;

      begin
        select codbank,numbank,codbank2,numbank2,amtbank,
               qtychedu,qtychned,stddec(amttranb,b_index_codempid,v_chken),numbrnch,numbrnch2
        into   tab2_codbank,tab2_numbank,tab2_codbank2,tab2_numbank2,tab2_amtbank,
               tab2_qtychedu,tab2_qtychned,tab2_amttranb,tab2_numbrnch,tab2_numbrnch2
        from   temploy3
        where  codempid  = b_index_codempid ;
      exception when no_data_found then
        null;
      end;

      begin
         select
--                namspous,numoffid,dtespbd,codspocc,replace(desnoffi, CHR(10), ' '),
--                dtemarry,desplreg,codsppro,codspcty,desnote,codtitle,namfirst,namlast,
                codempidsp,namimgsp,codtitle,
                namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                namlaste,namlastt,namlast3,namlast4,namlast5,
                namspe,namspt,namsp3,namsp4,namsp5,
                numoffid,numtaxid,codspocc,dtespbd,stalife,staincom,
                dtedthsp,desnoffi,numfasp,nummosp,dtemarry,
                codsppro,codspcty,desplreg,desnote,filename,numrefdoc
--         into   tab2_namspous,tab2_numspid,tab2_dtespbd,tab2_codspocc,tab2_desnoffi,
--                tab2_dtemarry,tab2_desplreg,tab2_codsppro,tab2_codspcty,tab2_desnote,
--                tab2_codtitle,tab2_namfirst,tab2_namlast
         into   tab2_codempidsp,tab2_namimgsp,tab2_codtitle,
                tab2_namfirste,tab2_namfirstt,tab2_namfirst3,tab2_namfirst4,tab2_namfirst5,
                tab2_namlaste,tab2_namlastt,tab2_namlast3,tab2_namlast4,tab2_namlast5,
                tab2_namspe,tab2_namspt,tab2_namsp3,tab2_namsp4,tab2_namsp5,
                tab2_numoffid,tab2_numtaxid,tab2_codspocc,tab2_dtespbd,tab2_stalife,tab2_staincom,
                tab2_dtedthsp,tab2_desnoffi,tab2_numfasp,tab2_nummosp,tab2_dtemarry,
                tab2_codsppro,tab2_codspcty,tab2_desplreg,tab2_desnote,tab2_filename,tab2_numrefdoc
         from   tspouse
         where  codempid  = b_index_codempid ;
      exception when no_data_found then
          null;
      END ;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'STAMILIT' then
          tab2_stamilit := i.desnew;
          tab2_stamilit_flg := 'Y';
        elsif i.fldedit = 'ADRREGE' then
          tab2_adrrege  := i.desnew;
          tab2_adrrege_flg := 'Y';
          adrreg_flg       := 'Y';
        elsif i.fldedit = 'ADRREGT' then
          tab2_adrregt  := i.desnew;
          tab2_adrregt_flg := 'Y';
          adrreg_flg       := 'Y';
        elsif i.fldedit = 'ADRREG3' then
          tab2_adrreg3  := i.desnew;
          tab2_adrreg3_flg := 'Y';
          adrreg_flg       := 'Y';
        elsif i.fldedit = 'ADRREG4' then
          tab2_adrreg4  := i.desnew;
          tab2_adrreg4_flg := 'Y';
          adrreg_flg       := 'Y';
        elsif i.fldedit = 'ADRREG5' then
          tab2_adrreg5  := i.desnew;
          tab2_adrreg5_flg := 'Y';
          adrreg_flg       := 'Y';
        elsif i.fldedit = 'CODSUBDISTR' then
          tab2_codsubdistr  := i.desnew;
          tab2_codsubdistr_flg := 'Y';
        elsif i.fldedit = 'CODDISTR' then
          tab2_coddistr  := i.desnew;
          tab2_coddistr_flg := 'Y';
        elsif i.fldedit = 'CODPROVR' then
          tab2_codprovr  := i.desnew;
          tab2_codprovr_flg := 'Y';
        elsif i.fldedit = 'CODCNTYR' then
          tab2_codcntyr  := i.desnew;
          tab2_codcntyr_flg := 'Y';
        elsif i.fldedit = 'CODPOSTR' then
          tab2_codpostr  := i.desnew;
          tab2_codpostr_flg := 'Y';
        elsif i.fldedit = 'ADRCONTE' then
          tab2_adrconte  := i.desnew;
          tab2_adrconte_flg := 'Y';
          adrcont_flg       := 'Y';
        elsif i.fldedit = 'ADRCONTT' then
          tab2_adrcontt  := i.desnew;
          tab2_adrcontt_flg := 'Y';
          adrcont_flg       := 'Y';
        elsif i.fldedit = 'ADRCONT3' then
          tab2_adrcont3  := i.desnew;
          tab2_adrcont3_flg := 'Y';
          adrcont_flg       := 'Y';
        elsif i.fldedit = 'ADRCONT4' then
          tab2_adrcont4  := i.desnew;
          tab2_adrcont4_flg := 'Y';
          adrcont_flg       := 'Y';
        elsif i.fldedit = 'ADRCONT5' then
          tab2_adrcont5  := i.desnew;
          tab2_adrcont5_flg := 'Y';
          adrcont_flg       := 'Y';
        elsif i.fldedit = 'CODSUBDISTC' then
          tab2_codsubdistc  := i.desnew;
          tab2_codsubdistc_flg := 'Y';
        elsif i.fldedit = 'CODDISTC' then
          tab2_coddistc  := i.desnew;
          tab2_coddistc_flg := 'Y';
        elsif i.fldedit = 'CODPROVC' then
          tab2_codprovc  := i.desnew;
          tab2_codprovc_flg := 'Y';
        elsif i.fldedit = 'CODCNTYC' then
          tab2_codcntyc  := i.desnew;
          tab2_codcntyc_flg := 'Y';
        elsif i.fldedit = 'CODPOSTC' then
          tab2_codpostc  := i.desnew;
          tab2_codpostc_flg := 'Y';
        elsif i.fldedit = 'NUMTELEC' then
          tab2_numtelec  := i.desnew;
          tab2_numtelec_flg := 'Y';
        elsif i.fldedit = 'NUMOFFID' then
          tab2_numoffid  := i.desnew;
          tab2_numoffid_flg := 'Y';
        elsif i.fldedit = 'ADRISSUE' then
          tab2_adrissue  := i.desnew;
          tab2_adrissue_flg := 'Y';
        elsif i.fldedit = 'CODPROVI' then
          tab2_codprovi  := i.desnew;
          tab2_codprovi_flg := 'Y';
        elsif i.fldedit = 'DTEOFFID' then
          tab2_dteoffid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteoffid_flg := 'Y';
        elsif i.fldedit = 'NUMLICID' then
          tab2_numlicid  := i.desnew;
          tab2_numlicid_flg := 'Y';
        elsif i.fldedit = 'DTELICID' then
          tab2_dtelicid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtelicid_flg := 'Y';
        elsif i.fldedit = 'NUMPASID' then
          tab2_numpasid  := i.desnew;
          tab2_numpasid_flg := 'Y';
        elsif i.fldedit = 'DTEPASID' then
          tab2_dtepasid  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtepasid_flg := 'Y';
        elsif i.fldedit = 'NUMPRMID' then
          tab2_numprmid  := i.desnew;
          tab2_numprmid_flg := 'Y';
        elsif i.fldedit = 'DTEPRMST' then
          tab2_dteprmst  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteprmst_flg := 'Y';
        elsif i.fldedit = 'DTEPRMEN' then
          tab2_dteprmen  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteprmen_flg := 'Y';
        elsif i.fldedit = 'STAMARRY' then
          tab2_stamarry  := i.desnew;
          tab2_stamarry_flg := 'Y';
        elsif i.fldedit = 'EMAIL_EMP' then
          tab2_email_emp  := i.desnew;
          tab2_email_emp_flg := 'Y';
        elsif i.fldedit = 'NUMMOBILE' then
          tab2_nummobile  := i.desnew;
          tab2_nummobile_flg := 'Y';
        elsif i.fldedit = 'LINEID' then
          tab2_lineid  := i.desnew;
          tab2_lineid_flg := 'Y';
        elsif i.fldedit = 'NUMVISA' then
          tab2_numvisa  := i.desnew;
          tab2_numvisa_flg := 'Y';
        elsif i.fldedit = 'DTEVISAEXP' then
          tab2_dtevisaexp  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtevisaexp_flg := 'Y';
        elsif i.fldedit = 'CODCLNSC' then
          tab2_codclnsc  := i.desnew;
          tab2_codclnsc_flg := 'Y';
        elsif i.fldedit = 'DTERETIRE' then
          tab2_dteretire  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dteretire_flg := 'Y';
        elsif i.fldedit = 'CODBANK' then
          tab2_codbank  := i.desnew;
          tab2_codbank_flg := 'Y';
        elsif i.fldedit = 'NUMBANK' then
          tab2_numbank  := i.desnew;
          tab2_numbank_flg := 'Y';
        elsif i.fldedit = 'NUMBRNCH' then
          tab2_numbrnch  := i.desnew;
          tab2_numbrnch_flg := 'Y';
        elsif i.fldedit = 'CODBANK2' then
          tab2_codbank2  := i.desnew;
          tab2_codbank2_flg := 'Y';
        elsif i.fldedit = 'NUMBANK2' then
          tab2_numbank2  := i.desnew;
          tab2_numbank2_flg := 'Y';
        elsif i.fldedit = 'NUMBRNCH2' then
          tab2_numbrnch2  := i.desnew;
          tab2_numbrnch2_flg := 'Y';
        elsif i.fldedit = 'AMTBANK' then
          tab2_amtbank  := i.desnew;
          tab2_amtbank_flg := 'Y';
        elsif i.fldedit = 'AMTTRANB' then
          tab2_amttranb  := stddec(i.desnew,b_index_codempid,v_chken);
          tab2_amttranb_flg := 'Y';
        elsif i.fldedit = 'QTYCHEDU' then
          tab2_qtychedu  := i.desnew;
          tab2_qtychedu_flg := 'Y';
        elsif i.fldedit = 'QTYCHNED' then
          tab2_qtychned  := i.desnew;
          tab2_qtychned_flg := 'Y';
        elsif i.fldedit = 'NAMSPE' then
          tab2_namspe  := i.desnew;
          tab2_namspe_flg := 'Y';
        elsif i.fldedit = 'NAMSPT' then
          tab2_namspt  := i.desnew;
          tab2_namspt_flg := 'Y';
        elsif i.fldedit = 'NAMSP3' then
          tab2_namsp3  := i.desnew;
          tab2_namsp3_flg := 'Y';
        elsif i.fldedit = 'NAMSP4' then
          tab2_namsp4  := i.desnew;
          tab2_namsp4_flg := 'Y';
        elsif i.fldedit = 'NAMSP5' then
          tab2_namsp5  := i.desnew;
          tab2_namsp5_flg := 'Y';
        elsif i.fldedit = 'NUMSPID' then
          tab2_numspid  := i.desnew;
          tab2_numspid_flg := 'Y';
        elsif i.fldedit = 'DTESPBD' then
          tab2_dtespbd  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtespbd_flg := 'Y';
        elsif i.fldedit = 'CODSPOCC' then
          tab2_codspocc  := i.desnew;
          tab2_codspocc_flg := 'Y';
        elsif i.fldedit = 'DESNOFFI' then
          tab2_desnoffi  := i.desnew;
          tab2_desnoffi_flg := 'Y';
        elsif i.fldedit = 'DTEMARRY' then
          tab2_dtemarry  := to_date(i.desnew,'dd/mm/yyyy');
          tab2_dtemarry_flg := 'Y';
        elsif i.fldedit = 'DESPLREG' then
          tab2_desplreg  := i.desnew;
          tab2_desplreg_flg := 'Y';
        elsif i.fldedit = 'CODSPPRO' then
          tab2_codsppro  := i.desnew;
          tab2_codsppro_flg := 'Y';
        elsif i.fldedit = 'CODSPCTY' then
          tab2_codspcty  := i.desnew;
          tab2_codspcty_flg := 'Y';
        elsif i.fldedit = 'DESNOTE' then
          tab2_desnote  := i.desnew;
          tab2_desnote_flg := 'Y';
        elsif i.fldedit = 'CODTITLE' then
          tab2_codtitle   := i.desnew;
          tab2_codtitle_flg := 'Y';
        elsif i.fldedit = 'NAMFIRSTE' then
          tab2_namfirste  := i.desnew;
          tab2_namfirste_flg := 'Y';
          namfirst_flg       := 'Y';
        elsif i.fldedit = 'NAMFIRSTT' then
          tab2_namfirstt  := i.desnew;
          tab2_namfirstt_flg := 'Y';
          namfirst_flg       := 'Y';
        elsif i.fldedit = 'NAMFIRST3' then
          tab2_namfirst3  := i.desnew;
          tab2_namfirst3_flg := 'Y';
          namfirst_flg       := 'Y';
        elsif i.fldedit = 'NAMFIRST4' then
          tab2_namfirst4  := i.desnew;
          tab2_namfirst4_flg := 'Y';
          namfirst_flg       := 'Y';
        elsif i.fldedit = 'NAMFIRST5' then
          tab2_namfirst5  := i.desnew;
          tab2_namfirst5_flg := 'Y';
          namfirst_flg       := 'Y';
        elsif i.fldedit = 'NAMLASTE' then
          tab2_namlaste  := i.desnew;
          tab2_namlaste_flg := 'Y';
          namlast_flg       := 'Y';
        elsif i.fldedit = 'NAMLASTT' then
          tab2_namlastt  := i.desnew;
          tab2_namlastt_flg := 'Y';
          namlast_flg       := 'Y';
        elsif i.fldedit = 'NAMLAST3' then
          tab2_namlast3  := i.desnew;
          tab2_namlast3_flg := 'Y';
          namlast_flg       := 'Y';
        elsif i.fldedit = 'NAMLAST4' then
          tab2_namlast4  := i.desnew;
          tab2_namlast4_flg := 'Y';
          namlast_flg       := 'Y';
        elsif i.fldedit = 'NAMLAST5' then
          tab2_namlast5  := i.desnew;
          tab2_namlast5_flg := 'Y';
          namlast_flg       := 'Y';
        elsif i.fldedit = 'CODEMPIDSP' then
          tab2_codempidsp  := i.desnew;
          tab2_codempidsp_flg := 'Y';
        elsif i.fldedit = 'STALIFE' then
          tab2_stalife  := i.desnew;
          tab2_stalife_flg := 'Y';
        elsif i.fldedit = 'DTEDTHSP' then
          tab2_dtedthsp     := i.desnew;
          tab2_dtedthsp_flg := 'Y';
        elsif i.fldedit = 'STAINCOM' then
          tab2_staincom  := i.desnew;
          tab2_staincom_flg := 'Y';
        elsif i.fldedit = 'NUMFASP' then
          tab2_numfasp  := i.desnew;
          tab2_numfasp_flg := 'Y';
        elsif i.fldedit = 'NUMMOSP' then
          tab2_nummosp  := i.desnew;
          tab2_nummosp_flg := 'Y';
        elsif i.fldedit = 'TYPTRAV' then
          tab2_typtrav  := i.desnew;
          tab2_typtrav_flg := 'Y';
        elsif i.fldedit = 'QTYLENGTH' then
          tab2_qtylength  := i.desnew;
          tab2_qtylength_flg := 'Y';
        elsif i.fldedit = 'CARLICEN' then
          tab2_carlicen  := i.desnew;
          tab2_carlicen_flg := 'Y';
        elsif i.fldedit = 'TYPFUEL' then
          tab2_typfuel  := i.desnew;
          tab2_typfuel_flg := 'Y';
        elsif i.fldedit = 'CODBUSNO' then
          tab2_codbusno  := i.desnew;
          tab2_codbusno_flg := 'Y';
        elsif i.fldedit = 'CODBUSRT' then
          tab2_codbusrt  := i.desnew;
          tab2_codbusrt_flg := 'Y';
        elsif i.fldedit = 'FILENAME' then
          tab2_filename  := i.desnew;
          tab2_filename_flg := 'Y';
        END IF;

      end loop;
      --
      begin
        select decode(global_v_lang ,'101',tab2_adrrege
                                    ,'102',tab2_adrregt
                                    ,'103',tab2_adrreg3
                                    ,'104',tab2_adrreg4
                                    ,'105',tab2_adrreg5,tab2_adrrege)
        into   tab2_adrreg
        from   dual ;
      end;

      begin
        select decode(global_v_lang ,'101',tab2_adrconte
                                     ,'102',tab2_adrcontt
                                     ,'103',tab2_adrcont3
                                     ,'104',tab2_adrcont4
                                     ,'105',tab2_adrcont5,tab2_adrconte)
        into   tab2_adrcont
        from   dual ;
      end ;
      if global_v_lang = '101' then
        tab2_namfirst   := tab2_namfirste;
        tab2_namlast    := tab2_namlaste;
      elsif global_v_lang = '102' then
        tab2_namfirst   := tab2_namfirstt;
        tab2_namlast    := tab2_namlastt;
      elsif global_v_lang = '103' then
        tab2_namfirst   := tab2_namfirst3;
        tab2_namlast    := tab2_namlast3;
      elsif global_v_lang = '104' then
        tab2_namfirst   := tab2_namfirst4;
        tab2_namlast    := tab2_namlast4;
      elsif global_v_lang = '105' then
        tab2_namfirst   := tab2_namfirst5;
        tab2_namlast    := tab2_namlast5;
      end if;
      --
      tab2_dessubdistr      := get_tsubdist_name(tab2_codsubdistr,global_v_lang) ;
      tab2_desdistr         := get_tcoddist_name(tab2_coddistr,global_v_lang) ;
      tab2_desprovr         := get_tcodec_name('TCODPROV',tab2_codprovr,global_v_lang);
      tab2_descntyr         := get_tcodec_name('TCODCNTY',tab2_codcntyr,global_v_lang);
      tab2_dessubdistc      := get_tsubdist_name(tab2_codsubdistc,global_v_lang) ;
      tab2_desdistc         := get_tcoddist_name(tab2_coddistc,global_v_lang) ;
      tab2_desprovc         := get_tcodec_name('TCODPROV',tab2_codprovc,global_v_lang);
      tab2_descntyc         := get_tcodec_name('TCODCNTY',tab2_codcntyc,global_v_lang);
      tab2_desprovi         := get_tcodec_name('TCODPROV',tab2_codprovi,global_v_lang);
      tab2_desc_codbank     := get_tcodec_name('TCODBANK',tab2_codbank,global_v_lang);
      tab2_desc_codbank2    := get_tcodec_name('TCODBANK',tab2_codbank2,global_v_lang);
      tab2_desc_codspocc    := get_tcodec_name('TCODOCCU',tab2_codspocc,global_v_lang);
      TAB2_DESC_CODSPPRO    := GET_TCODEC_NAME('TCODPROV',TAB2_CODSPPRO,GLOBAL_V_LANG);
      tab2_desc_codspcty    := get_tcodec_name('TCODCNTY',tab2_codspcty,global_v_lang);
      -- add data
      v_folder              := get_tfolderd('HRPMC2E3');
      path_filename         := get_tsetup_value('PATHDOC')||v_folder||'/'||tab2_filename;
      obj_row := json_object_t();
      obj_row.put('coderror', '200');
      obj_row.put('desc_coderror', ' ');
      obj_row.put('httpcode', ' ');
      obj_row.put('flg', ' ');
      --display data
      obj_row.put('stamilit',tab2_stamilit);
      obj_row.put('adrreg',tab2_adrreg);
      obj_row.put('adrrege',tab2_adrrege);
      obj_row.put('adrregt',tab2_adrregt);
      obj_row.put('adrreg3',tab2_adrreg3);
      obj_row.put('adrreg4',tab2_adrreg4);
      obj_row.put('adrreg5',tab2_adrreg5);
      obj_row.put('codsubdistr',tab2_codsubdistr);
      obj_row.put('coddistr',tab2_coddistr);
      obj_row.put('codprovr',tab2_codprovr);
      obj_row.put('codcntyr',tab2_codcntyr);
      obj_row.put('codpostr',tab2_codpostr);
      obj_row.put('adrcont',tab2_adrcont);
      obj_row.put('adrconte',tab2_adrconte);
      obj_row.put('adrcontt',tab2_adrcontt);
      obj_row.put('adrcont3',tab2_adrcont3);
      obj_row.put('adrcont4',tab2_adrcont4);
      obj_row.put('adrcont5',tab2_adrcont5);
      obj_row.put('codsubdistc',tab2_codsubdistc);
      obj_row.put('coddistc',tab2_coddistc);
      obj_row.put('codprovc',tab2_codprovc);
      obj_row.put('codcntyc',tab2_codcntyc);
      obj_row.put('codpostc',tab2_codpostc);
      obj_row.put('numtelec',tab2_numtelec);
      --detail2 tab2
      obj_row.put('numoffid',tab2_numoffid);
      obj_row.put('adrissue',tab2_adrissue);
      obj_row.put('codprovi',tab2_codprovi);
      obj_row.put('dteoffid',to_char(tab2_dteoffid,'dd/mm/yyyy'));
      obj_row.put('numlicid',tab2_numlicid);
      obj_row.put('dtelicid',to_char(tab2_dtelicid,'dd/mm/yyyy'));
      obj_row.put('numpasid',tab2_numpasid);
      obj_row.put('dtepasid',to_char(tab2_dtepasid,'dd/mm/yyyy'));
      obj_row.put('numprmid',tab2_numprmid);
      obj_row.put('dteprmst',to_char(tab2_dteprmst,'dd/mm/yyyy'));
      obj_row.put('dteprmen',to_char(tab2_dteprmen,'dd/mm/yyyy'));
      obj_row.put('stamarry',tab2_stamarry);
      obj_row.put('email_emp',tab2_email_emp);
      obj_row.put('nummobile',tab2_nummobile);
      obj_row.put('lineid',tab2_lineid);
      obj_row.put('numvisa',tab2_numvisa);
      obj_row.put('dtevisaexp',to_char(tab2_dtevisaexp,'dd/mm/yyyy'));
      obj_row.put('codclnsc',tab2_codclnsc);
      obj_row.put('dteretire',to_char(tab2_dteretire,'dd/mm/yyyy'));

      obj_row.put('codbank',tab2_codbank);
      obj_row.put('numbank',tab2_numbank);
      obj_row.put('numbrnch',tab2_numbrnch);
      obj_row.put('codbank2',tab2_codbank2);
      obj_row.put('numbank2',tab2_numbank2);
      obj_row.put('numbrnch2',tab2_numbrnch2);
      obj_row.put('amtbank',tab2_amtbank);
      obj_row.put('amttranb',tab2_amttranb);

      obj_row.put('qtychedu',tab2_qtychedu);
      obj_row.put('qtychned',tab2_qtychned);
      obj_row.put('namspe',tab2_namspe);
      obj_row.put('namspt',tab2_namspt);
      obj_row.put('namsp3',tab2_namsp3);
      obj_row.put('namsp4',tab2_namsp4);
      obj_row.put('namsp5',tab2_namsp5);
      obj_row.put('codtitle',tab2_codtitle);
      obj_row.put('namfirst',tab2_namfirst);
      obj_row.put('namfirste',tab2_namfirste);
      obj_row.put('namfirstt',tab2_namfirstt);
      obj_row.put('namfirst3',tab2_namfirst3);
      obj_row.put('namfirst4',tab2_namfirst4);
      obj_row.put('namfirst5',tab2_namfirst5);
      obj_row.put('namlast',tab2_namlast);
      obj_row.put('namlaste',tab2_namlaste);
      obj_row.put('namlastt',tab2_namlastt);
      obj_row.put('namlast3',tab2_namlast3);
      obj_row.put('namlast4',tab2_namlast4);
      obj_row.put('namlast5',tab2_namlast5);
      obj_row.put('codempidsp',tab2_codempidsp);
      obj_row.put('stalife',tab2_stalife);
      obj_row.put('dtedthsp',to_char(tab2_dtedthsp,'dd/mm/yyyy'));
      obj_row.put('staincom',tab2_staincom);
      obj_row.put('numfasp',tab2_numfasp);
      obj_row.put('nummosp',tab2_nummosp);
      obj_row.put('filename',tab2_filename);
      obj_row.put('numspid',tab2_numspid);
      obj_row.put('dtespbd',to_char(tab2_dtespbd,'dd/mm/yyyy'));
      obj_row.put('codspocc',tab2_codspocc);
      obj_row.put('desnoffi',tab2_desnoffi);
      obj_row.put('dtemarry',to_char(tab2_dtemarry,'dd/mm/yyyy'));
      obj_row.put('desplreg',tab2_desplreg);
      obj_row.put('codsppro',tab2_codsppro);
      obj_row.put('codspcty',tab2_codspcty);

      obj_row.put('desnote',tab2_desnote);
      obj_row.put('dessubdistr',tab2_dessubdistr);
      obj_row.put('desdistr',tab2_desdistr);
      obj_row.put('desprovr',tab2_desprovr);
      obj_row.put('descntyr',tab2_descntyr);
      obj_row.put('dessubdistc',tab2_dessubdistc);
      obj_row.put('desdistc',tab2_desdistc);
      obj_row.put('desprovc',tab2_desprovc);
      obj_row.put('descntyc',tab2_descntyc);
      obj_row.put('desprovi',tab2_desprovi);
      obj_row.put('desc_codbank',tab2_desc_codbank);
      obj_row.put('desc_codbank2',tab2_desc_codbank2);
      obj_row.put('desc_codspocc',tab2_desc_codspocc);
      obj_row.put('desc_codsppro',tab2_desc_codsppro);
      obj_row.put('desc_codspcty',tab2_desc_codspcty);
      obj_row.put('stamilit_flg',tab2_stamilit_flg);
      obj_row.put('adrrege_flg',tab2_adrrege_flg);
      obj_row.put('adrregt_flg',tab2_adrregt_flg);
      obj_row.put('adrreg3_flg',tab2_adrreg3_flg);
      obj_row.put('adrreg4_flg',tab2_adrreg4_flg);
      obj_row.put('adrreg5_flg',tab2_adrreg5_flg);
      obj_row.put('codsubdistr_flg',tab2_codsubdistr_flg);
      obj_row.put('coddistr_flg',tab2_coddistr_flg);
      obj_row.put('codprovr_flg',tab2_codprovr_flg);
      obj_row.put('codcntyr_flg',tab2_codcntyr_flg);
      obj_row.put('codpostr_flg',tab2_codpostr_flg);
      obj_row.put('adrconte_flg',tab2_adrconte_flg);
      obj_row.put('adrcontt_flg',tab2_adrcontt_flg);
      obj_row.put('adrcont3_flg',tab2_adrcont3_flg);
      obj_row.put('adrcont4_flg',tab2_adrcont4_flg);
      obj_row.put('adrcont5_flg',tab2_adrcont5_flg);
      obj_row.put('codsubdistc_flg',tab2_codsubdistc_flg);
      obj_row.put('coddistc_flg',tab2_coddistc_flg);
      obj_row.put('codprovc_flg',tab2_codprovc_flg);
      obj_row.put('codcntyc_flg',tab2_codcntyc_flg);
      obj_row.put('codpostc_flg',tab2_codpostc_flg);
      obj_row.put('numtelec_flg',tab2_numtelec_flg);
      obj_row.put('numoffid_flg',tab2_numoffid_flg);
      obj_row.put('adrissue_flg',tab2_adrissue_flg);
      obj_row.put('codprovi_flg',tab2_codprovi_flg);
      obj_row.put('dteoffid_flg',tab2_dteoffid_flg);
      obj_row.put('numlicid_flg',tab2_numlicid_flg);
      obj_row.put('dtelicid_flg',tab2_dtelicid_flg);
      obj_row.put('numpasid_flg',tab2_numpasid_flg);
      obj_row.put('dtepasid_flg',tab2_dtepasid_flg);
      obj_row.put('numprmid_flg',tab2_numprmid_flg);
      obj_row.put('dteprmst_flg',tab2_dteprmst_flg);
      obj_row.put('dteprmen_flg',tab2_dteprmen_flg);
      obj_row.put('stamarry_flg',tab2_stamarry_flg);
      obj_row.put('email_emp_flg',tab2_email_emp_flg);
      obj_row.put('nummobile_flg',tab2_nummobile_flg);
      obj_row.put('lineid_flg',tab2_lineid_flg);
      obj_row.put('numvisa_flg',tab2_numvisa_flg);
      obj_row.put('codclnsc_flg',tab2_codclnsc_flg);
      obj_row.put('dteretire_flg',tab2_dteretire_flg);
      obj_row.put('codbank_flg',tab2_codbank_flg);
      obj_row.put('numbank_flg',tab2_numbank_flg);
      obj_row.put('numbrnch_flg',tab2_numbrnch_flg);
      obj_row.put('codbank2_flg',tab2_codbank2_flg);
      obj_row.put('numbank2_flg',tab2_numbank2_flg);
      obj_row.put('numbrnch2_flg',tab2_numbrnch2_flg);
      obj_row.put('amtbank_flg',tab2_amtbank_flg);
      obj_row.put('amttranb_flg',tab2_amttranb_flg);
      obj_row.put('qtychedu_flg',tab2_qtychedu_flg);
      obj_row.put('qtychned_flg',tab2_qtychned_flg);
      obj_row.put('namspe_flg',tab2_namspe_flg);
      obj_row.put('namspt_flg',tab2_namspt_flg);
      obj_row.put('namsp3_flg',tab2_namsp3_flg);
      obj_row.put('namsp4_flg',tab2_namsp4_flg);
      obj_row.put('namsp5_flg',tab2_namsp5_flg);
      obj_row.put('codempidsp_flg',tab2_codempidsp_flg);
      obj_row.put('stalife_flg',tab2_stalife_flg);
      obj_row.put('dtedthsp_flg',tab2_dtedthsp_flg);
      obj_row.put('staincom_flg',tab2_staincom_flg);
      obj_row.put('numfasp_flg',tab2_numfasp_flg);
      obj_row.put('nummosp_flg',tab2_nummosp_flg);
      obj_row.put('filename_flg',tab2_filename_flg);
      obj_row.put('numspid_flg',tab2_numspid_flg);
      obj_row.put('dtespbd_flg',tab2_dtespbd_flg);
      obj_row.put('codspocc_flg',tab2_codspocc_flg);
      obj_row.put('desnoffi_flg',tab2_desnoffi_flg);
      obj_row.put('dtemarry_flg',tab2_dtemarry_flg);
      obj_row.put('desplreg_flg',tab2_desplreg_flg);
      obj_row.put('codsppro_flg',tab2_codsppro_flg);
      obj_row.put('codspcty_flg',tab2_codspcty_flg);
      obj_row.put('desnote_flg',tab2_desnote_flg);
      obj_row.put('typtrav',tab2_typtrav);
      obj_row.put('qtylength',tab2_qtylength);
      obj_row.put('carlicen',tab2_carlicen);
      obj_row.put('typfuel',tab2_typfuel);
      obj_row.put('codbusno',tab2_codbusno);
      obj_row.put('codbusrt',tab2_codbusrt);
      obj_row.put('typtrav_flg',tab2_typtrav_flg);
      obj_row.put('qtylength_flg',tab2_qtylength_flg);
      obj_row.put('carlicen_flg',tab2_carlicen_flg);
      obj_row.put('typfuel_flg',tab2_typfuel_flg);
      obj_row.put('codbusno_flg',tab2_codbusno_flg);
      obj_row.put('codbusrt_flg',tab2_codbusrt_flg);

      obj_row.put('adrreg_flg',adrreg_flg);
      obj_row.put('adrcont_flg',adrcont_flg);
      obj_row.put('dtevisaexp_flg',tab2_dtevisaexp_flg);
      obj_row.put('path_filename',path_filename);
      obj_row.put('codtitle_flg',tab2_codtitle_flg);
      obj_row.put('namfirst_flg',namfirst_flg);
      obj_row.put('namlast_flg',namlast_flg);
      --
      json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab1;
  --
  procedure get_detail2_tab5(json_str_input in clob, json_str_output out clob) is
    obj_row              json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_folder            varchar2(100);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB3';
    tab3_codempfa       tfamily.codempfa%type;
    tab3_codtitlf       tfamily.codtitlf%type;
    tab3_namfstf        tfamily.namfstfe%type;
    tab3_namfstfe       tfamily.namfstfe%type;
    tab3_namfstft       tfamily.namfstft%type;
    tab3_namfstf3       tfamily.namfstf3%type;
    tab3_namfstf4       tfamily.namfstf4%type;
    tab3_namfstf5       tfamily.namfstf5%type;
    tab3_namlstf        tfamily.namlstfe%type;
    tab3_namlstfe       tfamily.namlstfe%type;
    tab3_namlstft       tfamily.namlstft%type;
    tab3_namlstf3       tfamily.namlstf3%type;
    tab3_namlstf4       tfamily.namlstf4%type;
    tab3_namlstf5       tfamily.namlstf5%type;
    tab3_namfath        tfamily.namfathe%type;
    tab3_namfathe       tfamily.namfathe%type;
    tab3_namfatht       tfamily.namfatht%type;
    tab3_namfath3       tfamily.namfath3%type;
    tab3_namfath4       tfamily.namfath4%type;
    tab3_namfath5       tfamily.namfath5%type;
    tab3_numofidf       tfamily.numofidf%type;
    tab3_dtebdfa        tfamily.dtebdfa%type;
    tab3_codfnatn       tfamily.codfnatn%type;
    tab3_codfrelg       tfamily.codfrelg%type;
    tab3_codfoccu       tfamily.codfoccu%type;
    tab3_staliff        tfamily.staliff%type;
    tab3_dtedeathf      tfamily.dtedeathf%type;
    tab3_filenamf       tfamily.filenamf%type;
    tab3_numrefdocf     tfamily.numrefdocf%type;
    tab3_codempmo       tfamily.codempmo%type;
    tab3_codtitlm       tfamily.codtitlm%type;
    tab3_namfstm        tfamily.namfstme%type;
    tab3_namfstme       tfamily.namfstme%type;
    tab3_namfstmt       tfamily.namfstmt%type;
    tab3_namfstm3       tfamily.namfstm3%type;
    tab3_namfstm4       tfamily.namfstm4%type;
    tab3_namfstm5       tfamily.namfstm5%type;
    tab3_namlstm        tfamily.namlstme%type;
    tab3_namlstme       tfamily.namlstme%type;
    tab3_namlstmt       tfamily.namlstmt%type;
    tab3_namlstm3       tfamily.namlstm3%type;
    tab3_namlstm4       tfamily.namlstm4%type;
    tab3_namlstm5       tfamily.namlstm5%type;
    tab3_nammoth        tfamily.nammothe%type;
    tab3_nammothe       tfamily.nammothe%type;
    tab3_nammotht       tfamily.nammotht%type;
    tab3_nammoth3       tfamily.nammoth3%type;
    tab3_nammoth4       tfamily.nammoth4%type;
    tab3_nammoth5       tfamily.nammoth5%type;
    tab3_numofidm       tfamily.numofidm%type;
    tab3_dtebdmo        tfamily.dtebdmo%type;
    tab3_codmnatn       tfamily.codmnatn%type;
    tab3_codmrelg       tfamily.codmrelg%type;
    tab3_codmoccu       tfamily.codmoccu%type;
    tab3_stalifm        tfamily.stalifm%type;
    tab3_dtedeathm      tfamily.dtedeathm%type;
    tab3_filenamm       tfamily.filenamm%type;
    tab3_numrefdocm     tfamily.numrefdocm%type;
    tab3_codtitlc       tfamily.codtitlc%type;
    tab3_namfstc        tfamily.namfstce%type;
    tab3_namfstce       tfamily.namfstce%type;
    tab3_namfstct       tfamily.namfstct%type;
    tab3_namfstc3       tfamily.namfstc3%type;
    tab3_namfstc4       tfamily.namfstc4%type;
    tab3_namfstc5       tfamily.namfstc5%type;
    tab3_namlstc        tfamily.namlstce%type;
    tab3_namlstce       tfamily.namlstce%type;
    tab3_namlstct       tfamily.namlstct%type;
    tab3_namlstc3       tfamily.namlstc3%type;
    tab3_namlstc4       tfamily.namlstc4%type;
    tab3_namlstc5       tfamily.namlstc5%type;
    tab3_namcont        tfamily.namconte%type;
    tab3_namconte       tfamily.namconte%type;
    tab3_namcontt       tfamily.namcontt%type;
    tab3_namcont3       tfamily.namcont3%type;
    tab3_namcont4       tfamily.namcont4%type;
    tab3_namcont5       tfamily.namcont5%type;
    tab3_adrcont1       tfamily.adrcont1%type;
    tab3_codpost        tfamily.codpost%type;
    tab3_numtele        tfamily.numtele%type;
    tab3_numfax         tfamily.numfax%type;
    tab3_email          tfamily.email%type;
    tab3_desrelat       tfamily.desrelat%type;
    tab3_desc_codfnatn  varchar2(4000 char);
    tab3_desc_codfrelg  varchar2(4000 char);
    tab3_desc_codfoccu  varchar2(4000 char);
    tab3_desc_codmnatn  varchar2(4000 char);
    tab3_desc_codmrelg  varchar2(4000 char);
    tab3_desc_codmoccu  varchar2(4000 char);
    tab3_namfath_flg    varchar2(10 char) := 'N';
    tab3_namfathe_flg   varchar2(10 char) := 'N';
    tab3_namfatht_flg   varchar2(10 char) := 'N';
    tab3_namfath3_flg   varchar2(10 char) := 'N';
    tab3_namfath4_flg   varchar2(10 char) := 'N';
    tab3_namfath5_flg   varchar2(10 char) := 'N';
    tab3_codfnatn_flg   varchar2(10 char) := 'N';
    tab3_codfrelg_flg   varchar2(10 char) := 'N';
    tab3_codfoccu_flg   varchar2(10 char) := 'N';
    tab3_numofidf_flg   varchar2(10 char) := 'N';
    tab3_nammoth_flg    varchar2(10 char) := 'N';
    tab3_nammothe_flg   varchar2(10 char) := 'N';
    tab3_nammotht_flg   varchar2(10 char) := 'N';
    tab3_nammoth3_flg   varchar2(10 char) := 'N';
    tab3_nammoth4_flg   varchar2(10 char) := 'N';
    tab3_nammoth5_flg   varchar2(10 char) := 'N';
    tab3_codmrelg_flg   varchar2(10 char) := 'N';
    tab3_codmnatn_flg   varchar2(10 char) := 'N';
    tab3_codmoccu_flg   varchar2(10 char) := 'N';
    tab3_numofidm_flg   varchar2(10 char) := 'N';
    tab3_namcont_flg    varchar2(10 char) := 'N';
    tab3_namconte_flg   varchar2(10 char) := 'N';
    tab3_namcontt_flg   varchar2(10 char) := 'N';
    tab3_namcont3_flg   varchar2(10 char) := 'N';
    tab3_namcont4_flg   varchar2(10 char) := 'N';
    tab3_namcont5_flg   varchar2(10 char) := 'N';
    tab3_adrcont1_flg   varchar2(10 char) := 'N';
    tab3_codpost_flg    varchar2(10 char) := 'N';
    tab3_numtele_flg    varchar2(10 char) := 'N';
    tab3_numfax_flg     varchar2(10 char) := 'N';
    tab3_email_flg      varchar2(10 char) := 'N';
    tab3_desrelat_flg   varchar2(10 char) := 'N';
    --new column
    tab3_codtitlf_flg    varchar2(10 char) := 'N';
    tab3_namfstfe_flg    varchar2(10 char) := 'N';
    tab3_namfstft_flg    varchar2(10 char) := 'N';
    tab3_namfstf3_flg    varchar2(10 char) := 'N';
    tab3_namfstf4_flg    varchar2(10 char) := 'N';
    tab3_namfstf5_flg    varchar2(10 char) := 'N';
    namfstf_flg          varchar2(10 char) := 'N';
    tab3_namlstfe_flg    varchar2(10 char) := 'N';
    tab3_namlstft_flg    varchar2(10 char) := 'N';
    tab3_namlstf3_flg    varchar2(10 char) := 'N';
    tab3_namlstf4_flg    varchar2(10 char) := 'N';
    tab3_namlstf5_flg    varchar2(10 char) := 'N';
    namlstf_flg          varchar2(10 char) := 'N';
    tab3_codtitlm_flg    varchar2(10 char) := 'N';
    tab3_namfstme_flg    varchar2(10 char) := 'N';
    tab3_namfstmt_flg    varchar2(10 char) := 'N';
    tab3_namfstm3_flg    varchar2(10 char) := 'N';
    tab3_namfstm4_flg    varchar2(10 char) := 'N';
    tab3_namfstm5_flg    varchar2(10 char) := 'N';
    namfstm_flg          varchar2(10 char) := 'N';
    tab3_namlstme_flg    varchar2(10 char) := 'N';
    tab3_namlstmt_flg    varchar2(10 char) := 'N';
    tab3_namlstm3_flg    varchar2(10 char) := 'N';
    tab3_namlstm4_flg    varchar2(10 char) := 'N';
    tab3_namlstm5_flg    varchar2(10 char) := 'N';
    namlstm_flg          varchar2(10 char) := 'N';
    tab3_codtitlc_flg    varchar2(10 char) := 'N';
    tab3_namfstce_flg    varchar2(10 char) := 'N';
    tab3_namfstct_flg    varchar2(10 char) := 'N';
    tab3_namfstc3_flg    varchar2(10 char) := 'N';
    tab3_namfstc4_flg    varchar2(10 char) := 'N';
    tab3_namfstc5_flg    varchar2(10 char) := 'N';
    namfstc_flg          varchar2(10 char) := 'N';
    tab3_namlstce_flg    varchar2(10 char) := 'N';
    tab3_namlstct_flg    varchar2(10 char) := 'N';
    tab3_namlstc3_flg    varchar2(10 char) := 'N';
    tab3_namlstc4_flg    varchar2(10 char) := 'N';
    tab3_namlstc5_flg    varchar2(10 char) := 'N';
    namlstc_flg          varchar2(10 char) := 'N';
    tab3_codempfa_flg    varchar2(10 char) := 'N';
    tab3_codempmo_flg    varchar2(10 char) := 'N';

    tab3_dtebdfa_flg     varchar2(10 char) := 'N';
    tab3_staliff_flg     varchar2(10 char) := 'N';
    tab3_dtedeathf_flg   varchar2(10 char) := 'N';
    tab3_filenamf_flg    varchar2(10 char) := 'N';
    tab3_dtebdmo_flg     varchar2(10 char) := 'N';
    tab3_stalifm_flg     varchar2(10 char) := 'N';
    tab3_dtedeathm_flg   varchar2(10 char) := 'N';
    tab3_filenamm_flg    varchar2(10 char) := 'N';

    path_filenamf       varchar2(4000 char);
    path_filenamm       varchar2(4000 char);

    --Cursor
    cursor c_temeslog1 is
    select *
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = 25;
    begin
    initial_value(json_str_input);
      begin
        select /*namfathr,codfnatn,codfrelg,
               codfoccu,numofidf,nammothr,
               codmnatn,codmrelg,codmoccu,
               numofidm,namcont,adrcont1,
               codpost,numtele,numfax,
               email,desrelat*/
                codempfa,codtitlf,
                namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
                namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
                namfathe,namfatht,namfath3,namfath4,namfath5,
                numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
                staliff,dtedeathf,filenamf,numrefdocf,
                codempmo,codtitlm,
                namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
                namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
                nammothe,nammotht,nammoth3,nammoth4,nammoth5,
                numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,
                stalifm,dtedeathm,filenamm,numrefdocm,
                codtitlc,
                namfstce,namfstct,namfstc3,namfstc4,namfstc5,
                namlstce,namlstct,namlstc3,namlstc4,namlstc5,
                namconte,namcontt,namcont3,namcont4,namcont5,
                adrcont1,codpost,numtele,numfax,email,desrelat
          into /*tab3_namfathr,tab3_codfnatn,tab3_codfrelg,
               tab3_codfoccu,tab3_numofidf,tab3_nammothr,
               tab3_codmnatn,tab3_codmrelg,tab3_codmoccu,
               tab3_numofidm,tab3_namcont,tab3_adrcont1,
               tab3_codpost,tab3_numtele,tab3_numfax,
               tab3_email,tab3_desrelat*/
                tab3_codempfa,tab3_codtitlf,
                tab3_namfstfe,tab3_namfstft,tab3_namfstf3,tab3_namfstf4,tab3_namfstf5,
                tab3_namlstfe,tab3_namlstft,tab3_namlstf3,tab3_namlstf4,tab3_namlstf5,
                tab3_namfathe,tab3_namfatht,tab3_namfath3,tab3_namfath4,tab3_namfath5,
                tab3_numofidf,tab3_dtebdfa,tab3_codfnatn,tab3_codfrelg,tab3_codfoccu,
                tab3_staliff,tab3_dtedeathf,tab3_filenamf,tab3_numrefdocf,
                tab3_codempmo,tab3_codtitlm,
                tab3_namfstme,tab3_namfstmt,tab3_namfstm3,tab3_namfstm4,tab3_namfstm5,
                tab3_namlstme,tab3_namlstmt,tab3_namlstm3,tab3_namlstm4,tab3_namlstm5,
                tab3_nammothe,tab3_nammotht,tab3_nammoth3,tab3_nammoth4,tab3_nammoth5,
                tab3_numofidm,tab3_dtebdmo,tab3_codmnatn,tab3_codmrelg,tab3_codmoccu,
                tab3_stalifm,tab3_dtedeathm,tab3_filenamm,tab3_numrefdocm,
                tab3_codtitlc,
                tab3_namfstce,tab3_namfstct,tab3_namfstc3,tab3_namfstc4,tab3_namfstc5,
                tab3_namlstce,tab3_namlstct,tab3_namlstc3,tab3_namlstc4,tab3_namlstc5,
                tab3_namconte,tab3_namcontt,tab3_namcont3,tab3_namcont4,tab3_namcont5,
                tab3_adrcont1,tab3_codpost,tab3_numtele,tab3_numfax,tab3_email,tab3_desrelat
          from tfamily
         where codempid  = b_index_codempid ;
      exception when no_data_found then
        -- *father*                           *mother*                            *contact*
        tab3_codempfa       := null;        tab3_codempmo       := null;        tab3_codtitlc       := null;
        tab3_codtitlf       := null;        tab3_codtitlm       := null;        tab3_namfstce       := null;
        tab3_namfstfe       := null;        tab3_namfstme       := null;        tab3_namfstct       := null;
        tab3_namfstft       := null;        tab3_namfstmt       := null;        tab3_namfstc3       := null;
        tab3_namfstf3       := null;        tab3_namfstm3       := null;        tab3_namfstc4       := null;
        tab3_namfstf4       := null;        tab3_namfstm4       := null;        tab3_namfstc5       := null;
        tab3_namfstf5       := null;        tab3_namfstm5       := null;        tab3_namlstce       := null;
        tab3_namlstfe       := null;        tab3_namlstme       := null;        tab3_namlstct       := null;
        tab3_namlstft       := null;        tab3_namlstmt       := null;        tab3_namlstc3       := null;
        tab3_namlstf3       := null;        tab3_namlstm3       := null;        tab3_namlstc4       := null;
        tab3_namlstf4       := null;        tab3_namlstm4       := null;        tab3_namlstc5       := null;
        tab3_namlstf5       := null;        tab3_namlstm5       := null;        tab3_namconte       := null;
        tab3_namfathe       := null;        tab3_nammothe       := null;        tab3_namcontt       := null;
        tab3_namfatht       := null;        tab3_nammotht       := null;        tab3_namcont3       := null;
        tab3_namfath3       := null;        tab3_nammoth3       := null;        tab3_namcont4       := null;
        tab3_namfath4       := null;        tab3_nammoth4       := null;        tab3_namcont5       := null;
        tab3_namfath5       := null;        tab3_nammoth5       := null;        tab3_adrcont1       := null;
        tab3_numofidf       := null;        tab3_numofidm       := null;        tab3_codpost        := null;
        tab3_dtebdfa        := null;        tab3_dtebdmo        := null;        tab3_numtele        := null;
        tab3_codfnatn       := null;        tab3_codmnatn       := null;        tab3_numfax         := null;
        tab3_codfrelg       := null;        tab3_codmrelg       := null;        tab3_email          := null;
        tab3_codfoccu       := null;        tab3_codmoccu       := null;        tab3_desrelat       := null;
        tab3_staliff        := null;        tab3_stalifm        := null;
        tab3_dtedeathf      := null;        tab3_dtedeathm      := null;
        tab3_filenamf       := null;        tab3_filenamm       := null;
        tab3_numrefdocf     := null;        tab3_numrefdocm     := null;
      end ;
      --
      v_folder          := get_tfolderd('HRPMC2E');
      for i in c_temeslog1 loop
        if i.fldedit = 'NAMFATHE' then
          tab3_namfathe := i.desnew;
          tab3_namfathe_flg := 'Y';
        elsif i.fldedit = 'NAMFATHT' then
          tab3_namfatht := i.desnew;
          tab3_namfatht_flg := 'Y';
        elsif i.fldedit = 'NAMFATH3' then
          tab3_namfath3 := i.desnew;
          tab3_namfath3_flg := 'Y';
        elsif i.fldedit = 'NAMFATH4' then
          tab3_namfath4 := i.desnew;
          tab3_namfath4_flg := 'Y';
        elsif i.fldedit = 'NAMFATH5' then
          tab3_namfath5 := i.desnew;
          tab3_namfath5_flg := 'Y';
        elsif i.fldedit = 'CODFNATN' then
          tab3_codfnatn  := i.desnew;
          tab3_codfnatn_flg := 'Y';
        elsif i.fldedit = 'CODFRELG' then
          tab3_codfrelg  := i.desnew;
          tab3_codfrelg_flg := 'Y';
        elsif i.fldedit = 'CODFOCCU' then
          tab3_codfoccu  := i.desnew;
          tab3_codfoccu_flg := 'Y';
        elsif i.fldedit = 'NUMOFIDF' then
          tab3_numofidf  := i.desnew;
          tab3_numofidf_flg := 'Y';
        elsif i.fldedit = 'NAMMOTHE' then
          tab3_nammothe  := i.desnew;
          tab3_nammothe_flg := 'Y';
        elsif i.fldedit = 'NAMMOTHT' then
          tab3_nammotht  := i.desnew;
          tab3_nammotht_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH3' then
          tab3_nammoth3  := i.desnew;
          tab3_nammoth3_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH4' then
          tab3_nammoth4  := i.desnew;
          tab3_nammoth4_flg := 'Y';
        elsif i.fldedit = 'NAMMOTH5' then
          tab3_nammoth5  := i.desnew;
          tab3_nammoth5_flg := 'Y';
        elsif i.fldedit = 'CODMNATN' then
          tab3_codmnatn  := i.desnew;
          tab3_codmnatn_flg := 'Y';
        elsif i.fldedit = 'CODMRELG' then
          tab3_codmrelg  := i.desnew;
          tab3_codmrelg_flg := 'Y';
        elsif i.fldedit = 'CODMOCCU' then
          tab3_codmoccu  := i.desnew;
          tab3_codmoccu_flg := 'Y';
        elsif i.fldedit = 'NUMOFIDM' then
          tab3_numofidm  := i.desnew;
          tab3_numofidm_flg := 'Y';
        elsif i.fldedit = 'NAMCONTE' then
          tab3_namconte  := i.desnew;
          tab3_namconte_flg := 'Y';
        elsif i.fldedit = 'NAMCONTT' then
          tab3_namcontt  := i.desnew;
          tab3_namcontt_flg := 'Y';
        elsif i.fldedit = 'NAMCONT3' then
          tab3_namcont3  := i.desnew;
          tab3_namcont3_flg := 'Y';
        elsif i.fldedit = 'NAMCONT4' then
          tab3_namcont4  := i.desnew;
          tab3_namcont4_flg := 'Y';
        elsif i.fldedit = 'NAMCONT5' then
          tab3_namcont5  := i.desnew;
          tab3_namcont5_flg := 'Y';
        elsif i.fldedit = 'ADRCONT1' then
          tab3_adrcont1  := i.desnew;
          tab3_adrcont1_flg := 'Y';
        elsif i.fldedit = 'CODPOST' then
          tab3_codpost  := i.desnew;
          tab3_codpost_flg := 'Y';
        elsif i.fldedit = 'NUMTELE' then
          tab3_numtele  := i.desnew;
          tab3_numtele_flg := 'Y';
        elsif i.fldedit = 'NUMFAX' then
          tab3_numfax  := i.desnew;
          tab3_numfax_flg := 'Y';
        elsif i.fldedit = 'EMAIL' then
          tab3_email  := i.desnew;
          tab3_email_flg := 'Y';
        elsif i.fldedit = 'DESRELAT' then
          tab3_desrelat  := i.desnew;
          tab3_desrelat_flg := 'Y';
        ---- new
        elsif i.fldedit = 'CODTITLF' then
          tab3_codtitlf  := i.desnew;
          tab3_codtitlf_flg := 'Y';
        elsif i.fldedit = 'NAMFSTFE' then
          tab3_namfstfe  := i.desnew;
          tab3_namfstfe_flg := 'Y';
          namfstf_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTFT' then
          tab3_namfstft  := i.desnew;
          tab3_namfstft_flg := 'Y';
          namfstf_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTF3' then
          tab3_namfstf3  := i.desnew;
          tab3_namfstf3_flg := 'Y';
          namfstf_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTF4' then
          tab3_namfstf4  := i.desnew;
          tab3_namfstf4_flg := 'Y';
          namfstf_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTF5' then
          tab3_namfstf5  := i.desnew;
          tab3_namfstf5_flg := 'Y';
          namfstf_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTFE' then
          tab3_namlstfe  := i.desnew;
          tab3_namlstfe_flg := 'Y';
          namlstf_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTFT' then
          tab3_namlstft  := i.desnew;
          tab3_namlstft_flg := 'Y';
          namlstf_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTF3' then
          tab3_namlstf3  := i.desnew;
          tab3_namlstf3_flg := 'Y';
          namlstf_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTF4' then
          tab3_namlstf4  := i.desnew;
          tab3_namlstf4_flg := 'Y';
          namlstf_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTF5' then
          tab3_namlstf5  := i.desnew;
          tab3_namlstf5_flg := 'Y';
          namlstf_flg       := 'Y';
        elsif i.fldedit = 'CODTITLM' then
          tab3_codtitlm  := i.desnew;
          tab3_codtitlm_flg := 'Y';
        elsif i.fldedit = 'NAMFSTME' then
          tab3_namfstme  := i.desnew;
          tab3_namfstme_flg := 'Y';
          namfstm_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTMT' then
          tab3_namfstmt  := i.desnew;
          tab3_namfstmt_flg := 'Y';
          namfstm_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTM3' then
          tab3_namfstm3  := i.desnew;
          tab3_namfstm3_flg := 'Y';
          namfstm_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTM4' then
          tab3_namfstm4  := i.desnew;
          tab3_namfstm4_flg := 'Y';
          namfstm_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTM5' then
          tab3_namfstm5  := i.desnew;
          tab3_namfstm5_flg := 'Y';
          namfstm_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTME' then
          tab3_namlstme  := i.desnew;
          tab3_namlstme_flg := 'Y';
          namlstm_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTMT' then
          tab3_namlstmt  := i.desnew;
          tab3_namlstmt_flg := 'Y';
          namlstm_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTM3' then
          tab3_namlstm3  := i.desnew;
          tab3_namlstm3_flg := 'Y';
          namlstm_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTM4' then
          tab3_namlstm4  := i.desnew;
          tab3_namlstm4_flg := 'Y';
          namlstm_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTM5' then
          tab3_namlstm5  := i.desnew;
          tab3_namlstm5_flg := 'Y';
          namlstm_flg       := 'Y';
        elsif i.fldedit = 'CODTITLC' then
          tab3_codtitlc  := i.desnew;
          tab3_codtitlc_flg := 'Y';
        elsif i.fldedit = 'NAMFSTCE' then
          tab3_namfstce  := i.desnew;
          tab3_namfstce_flg := 'Y';
          namfstc_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTCT' then
          tab3_namfstct  := i.desnew;
          tab3_namfstct_flg := 'Y';
          namfstc_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTC3' then
          tab3_namfstc3  := i.desnew;
          tab3_namfstc3_flg := 'Y';
          namfstc_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTC4' then
          tab3_namfstc4  := i.desnew;
          tab3_namfstc4_flg := 'Y';
          namfstc_flg       := 'Y';
        elsif i.fldedit = 'NAMFSTC5' then
          tab3_namfstc5  := i.desnew;
          tab3_namfstc5_flg := 'Y';
          namfstc_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTCE' then
          tab3_namlstce  := i.desnew;
          tab3_namlstce_flg := 'Y';
          namlstc_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTCT' then
          tab3_namlstct  := i.desnew;
          tab3_namlstct_flg := 'Y';
          namlstc_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTC3' then
          tab3_namlstc3  := i.desnew;
          tab3_namlstc3_flg := 'Y';
          namlstc_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTC4' then
          tab3_namlstc4  := i.desnew;
          tab3_namlstc4_flg := 'Y';
          namlstc_flg       := 'Y';
        elsif i.fldedit = 'NAMLSTC5' then
          tab3_namlstc5  := i.desnew;
          tab3_namlstc5_flg := 'Y';
          namlstc_flg       := 'Y';
        elsif i.fldedit = 'CODEMPFA' then
          tab3_codempfa  := i.desnew;
          tab3_codempfa_flg := 'Y';
        elsif i.fldedit = 'CODEMPMO' then
          tab3_codempmo  := i.desnew;
          tab3_codempmo_flg := 'Y';
        elsif i.fldedit = 'DTEBDFA' then
          tab3_dtebdfa  := i.desnew;
          tab3_dtebdfa_flg := 'Y';
        elsif i.fldedit = 'STALIFF' then
          tab3_staliff  := i.desnew;
          tab3_staliff_flg := 'Y';
        elsif i.fldedit = 'DTEDEATHF' then
          tab3_dtedeathf  := i.desnew;
          tab3_dtedeathf_flg := 'Y';
        elsif i.fldedit = 'FILENAMF' then
          tab3_filenamf  := i.desnew;
          tab3_filenamf_flg := 'Y';
        elsif i.fldedit = 'DTEBDMO' then
          tab3_dtebdmo  := i.desnew;
          tab3_dtebdmo_flg := 'Y';
        elsif i.fldedit = 'STALIFM' then
          tab3_stalifm  := i.desnew;
          tab3_stalifm_flg := 'Y';
        elsif i.fldedit = 'DTEDEATHM' then
          tab3_dtedeathm  := i.desnew;
          tab3_dtedeathm_flg := 'Y';
        elsif i.fldedit = 'FILENAMM' then
          tab3_filenamm  := i.desnew;
          tab3_filenamm_flg := 'Y';
        end if;
      end loop;
      --
      if global_v_lang = '101' then
        tab3_namfath    := tab3_namfathe;
        tab3_nammoth    := tab3_nammothe;
        tab3_namcont    := tab3_namconte;
        tab3_namfstf    := tab3_namfstfe;
        tab3_namlstf    := tab3_namlstfe;
        tab3_namfstm    := tab3_namfstme;
        tab3_namlstm    := tab3_namlstme;
        tab3_namfstc    := tab3_namfstce;
        tab3_namlstc    := tab3_namlstce;
      elsif global_v_lang = '102' then
        tab3_namfath    := tab3_namfatht;
        tab3_nammoth    := tab3_nammotht;
        tab3_namcont    := tab3_namcontt;
        tab3_namfstf    := tab3_namfstft;
        tab3_namlstf    := tab3_namlstft;
        tab3_namfstm    := tab3_namfstmt;
        tab3_namlstm    := tab3_namlstmt;
        tab3_namfstc    := tab3_namfstct;
        tab3_namlstc    := tab3_namlstct;
      elsif global_v_lang = '103' then
        tab3_namfath    := tab3_namfath3;
        tab3_nammoth    := tab3_nammoth3;
        tab3_namcont    := tab3_namcont3;
        tab3_namfstf    := tab3_namfstf3;
        tab3_namlstf    := tab3_namlstf3;
        tab3_namfstm    := tab3_namfstm3;
        tab3_namlstm    := tab3_namlstm3;
        tab3_namfstc    := tab3_namfstc3;
        tab3_namlstc    := tab3_namlstc3;
      elsif global_v_lang = '104' then
        tab3_namfath    := tab3_namfath4;
        tab3_nammoth    := tab3_nammoth4;
        tab3_namcont    := tab3_namcont4;
        tab3_namfstf    := tab3_namfstf4;
        tab3_namlstf    := tab3_namlstf4;
        tab3_namfstm    := tab3_namfstm4;
        tab3_namlstm    := tab3_namlstm4;
        tab3_namfstc    := tab3_namfstc4;
        tab3_namlstc    := tab3_namlstc4;
      elsif global_v_lang = '105' then
        tab3_namfath    := tab3_namfath5;
        tab3_nammoth    := tab3_nammoth5;
        tab3_namcont    := tab3_namcont5;
        tab3_namfstf    := tab3_namfstf5;
        tab3_namlstf    := tab3_namlstf5;
        tab3_namfstm    := tab3_namfstm5;
        tab3_namlstm    := tab3_namlstm5;
        tab3_namfstc    := tab3_namfstc5;
        tab3_namlstc    := tab3_namlstc5;
      end if;
      tab3_desc_codfnatn  := get_tcodec_name('TCODNATN',tab3_codfnatn,global_v_lang);
      tab3_desc_codfrelg  := get_tcodec_name('TCODRELI',tab3_codfrelg,global_v_lang);
      tab3_desc_codfoccu  := get_tcodec_name('TCODOCCU',tab3_codfoccu,global_v_lang);
      tab3_desc_codmnatn  := get_tcodec_name('TCODNATN',tab3_codmnatn,global_v_lang);
      tab3_desc_codmrelg  := get_tcodec_name('TCODRELI',tab3_codmrelg,global_v_lang);
      tab3_desc_codmoccu  := get_tcodec_name('TCODOCCU',tab3_codmoccu,global_v_lang);
        -- add data
        path_filenamf         := get_tsetup_value('PATHDOC')||v_folder||'/'||tab3_filenamf;
        path_filenamm         := get_tsetup_value('PATHDOC')||v_folder||'/'||tab3_filenamm;
        obj_row :=  json_object_t();
        obj_row.put('coderror', '200');
        obj_row.put('desc_coderror', ' ');
        obj_row.put('httpcode', ' ');
        obj_row.put('flg', ' ');
        -- display data
        obj_row.put('namfath',tab3_namfath);
        obj_row.put('namfathe',tab3_namfathe);
        obj_row.put('namfatht',tab3_namfatht);
        obj_row.put('namfath3',tab3_namfath3);
        obj_row.put('namfath4',tab3_namfath4);
        obj_row.put('namfath5',tab3_namfath5);
        obj_row.put('codfnatn',tab3_codfnatn);
        obj_row.put('codfrelg',tab3_codfrelg);
        obj_row.put('codfoccu',tab3_codfoccu);
        obj_row.put('numofidf',tab3_numofidf);
        obj_row.put('nammoth',tab3_nammoth);
        obj_row.put('nammothe',tab3_nammothe);
        obj_row.put('nammotht',tab3_nammotht);
        obj_row.put('nammoth3',tab3_nammoth3);
        obj_row.put('nammoth4',tab3_nammoth4);
        obj_row.put('nammoth5',tab3_nammoth5);
        obj_row.put('codmnatn',tab3_codmnatn);
        obj_row.put('codmrelg',tab3_codmrelg);
        obj_row.put('codmoccu',tab3_codmoccu);
        obj_row.put('numofidm',tab3_numofidm);
        obj_row.put('namcont',tab3_namcont);
        obj_row.put('namconte',tab3_namconte);
        obj_row.put('namcontt',tab3_namcontt);
        obj_row.put('namcont3',tab3_namcont3);
        obj_row.put('namcont4',tab3_namcont4);
        obj_row.put('namcont5',tab3_namcont5);
        obj_row.put('adrcont1',tab3_adrcont1);
        obj_row.put('codpost',tab3_codpost);
        obj_row.put('numtele',tab3_numtele);
        obj_row.put('numfax',tab3_numfax);
        obj_row.put('email',tab3_email);
        obj_row.put('desrelat',tab3_desrelat);
        obj_row.put('desc_codfnatn',tab3_desc_codfnatn);
        obj_row.put('desc_codfrelg',tab3_desc_codfrelg);
        obj_row.put('desc_codfoccu',tab3_desc_codfoccu);
        obj_row.put('desc_codmnatn',tab3_desc_codmnatn);
        obj_row.put('desc_codmrelg',tab3_desc_codmrelg);
        obj_row.put('desc_codmoccu',tab3_desc_codmoccu);
        obj_row.put('namfathe_flg',tab3_namfathe_flg);
        obj_row.put('namfatht_flg',tab3_namfatht_flg);
        obj_row.put('namfath3_flg',tab3_namfath3_flg);
        obj_row.put('namfath4_flg',tab3_namfath4_flg);
        obj_row.put('namfath5_flg',tab3_namfath5_flg);
        obj_row.put('codfnatn_flg',tab3_codfnatn_flg);
        obj_row.put('codfrelg_flg',tab3_codfrelg_flg);
        obj_row.put('codfoccu_flg',tab3_codfoccu_flg);
        obj_row.put('numofidf_flg',tab3_numofidf_flg);
        obj_row.put('nammothe_flg',tab3_nammothe_flg);
        obj_row.put('nammotht_flg',tab3_nammotht_flg);
        obj_row.put('nammoth3_flg',tab3_nammoth3_flg);
        obj_row.put('nammoth4_flg',tab3_nammoth4_flg);
        obj_row.put('nammoth5_flg',tab3_nammoth5_flg);
        obj_row.put('codmnatn_flg',tab3_codmnatn_flg);
        obj_row.put('codmrelg_flg',tab3_codmrelg_flg);
        obj_row.put('codmoccu_flg',tab3_codmoccu_flg);
        obj_row.put('numofidm_flg',tab3_numofidm_flg);
        obj_row.put('namconte_flg',tab3_namconte_flg);
        obj_row.put('namcontt_flg',tab3_namcontt_flg);
        obj_row.put('namcont3_flg',tab3_namcont3_flg);
        obj_row.put('namcont4_flg',tab3_namcont4_flg);
        obj_row.put('namcont5_flg',tab3_namcont5_flg);
        obj_row.put('adrcont1_flg',tab3_adrcont1_flg);
        obj_row.put('codpost_flg',tab3_codpost_flg);
        obj_row.put('numtele_flg',tab3_numtele_flg);
        obj_row.put('numfax_flg',tab3_numfax_flg);
        obj_row.put('email_flg',tab3_email_flg);
        obj_row.put('desrelat_flg',tab3_desrelat_flg);
        -----new
        obj_row.put('codempfa',tab3_codempfa);
        obj_row.put('codtitlf',tab3_codtitlf);
        obj_row.put('namfstf',tab3_namfstf);
        obj_row.put('namfstfe',tab3_namfstfe);
        obj_row.put('namfstft',tab3_namfstft);
        obj_row.put('namfstf3',tab3_namfstf3);
        obj_row.put('namfstf4',tab3_namfstf4);
        obj_row.put('namfstf5',tab3_namfstf5);
        obj_row.put('namlstf',tab3_namlstf);
        obj_row.put('namlstfe',tab3_namlstfe);
        obj_row.put('namlstft',tab3_namlstft);
        obj_row.put('namlstf3',tab3_namlstf3);
        obj_row.put('namlstf4',tab3_namlstf4);
        obj_row.put('namlstf5',tab3_namlstf5);
        obj_row.put('codempmo',tab3_codempmo);
        obj_row.put('codtitlm',tab3_codtitlm);
        obj_row.put('namfstm',tab3_namfstm);
        obj_row.put('namfstme',tab3_namfstme);
        obj_row.put('namfstmt',tab3_namfstmt);
        obj_row.put('namfstm3',tab3_namfstm3);
        obj_row.put('namfstm4',tab3_namfstm4);
        obj_row.put('namfstm5',tab3_namfstm5);
        obj_row.put('namlstm',tab3_namlstm);
        obj_row.put('namlstme',tab3_namlstme);
        obj_row.put('namlstmt',tab3_namlstmt);
        obj_row.put('namlstm3',tab3_namlstm3);
        obj_row.put('namlstm4',tab3_namlstm4);
        obj_row.put('namlstm5',tab3_namlstm5);
        obj_row.put('namfstc',tab3_namfstc);
        obj_row.put('namfstce',tab3_namfstce);
        obj_row.put('namfstct',tab3_namfstct);
        obj_row.put('namfstc3',tab3_namfstc3);
        obj_row.put('namfstc4',tab3_namfstc4);
        obj_row.put('namfstc5',tab3_namfstc5);
        obj_row.put('codtitlc',tab3_codtitlc);
        obj_row.put('namlstc',tab3_namlstc);
        obj_row.put('namlstce',tab3_namlstce);
        obj_row.put('namlstct',tab3_namlstct);
        obj_row.put('namlstc3',tab3_namlstc3);
        obj_row.put('namlstc4',tab3_namlstc4);
        obj_row.put('namlstc5',tab3_namlstc5);
        obj_row.put('codempfa_flg',tab3_codempfa_flg);
        obj_row.put('codtitlf_flg',tab3_codtitlf_flg);
        obj_row.put('namfstfe_flg',tab3_namfstfe_flg);
        obj_row.put('namfstft_flg',tab3_namfstft_flg);
        obj_row.put('namfstf3_flg',tab3_namfstf3_flg);
        obj_row.put('namfstf4_flg',tab3_namfstf4_flg);
        obj_row.put('namfstf5_flg',tab3_namfstf5_flg);
        obj_row.put('namlstfe_flg',tab3_namlstfe_flg);
        obj_row.put('namlstft_flg',tab3_namlstft_flg);
        obj_row.put('namlstf3_flg',tab3_namlstf3_flg);
        obj_row.put('namlstf4_flg',tab3_namlstf4_flg);
        obj_row.put('namlstf5_flg',tab3_namlstf5_flg);
        obj_row.put('codempmo_flg',tab3_codempmo_flg);
        obj_row.put('codtitlm_flg',tab3_codtitlm_flg);
        obj_row.put('namfstme_flg',tab3_namfstme_flg);
        obj_row.put('namfstmt_flg',tab3_namfstmt_flg);
        obj_row.put('namfstm3_flg',tab3_namfstm3_flg);
        obj_row.put('namfstm4_flg',tab3_namfstm4_flg);
        obj_row.put('namfstm5_flg',tab3_namfstm5_flg);
        obj_row.put('namlstme_flg',tab3_namlstme_flg);
        obj_row.put('namlstmt_flg',tab3_namlstmt_flg);
        obj_row.put('namlstm3_flg',tab3_namlstm3_flg);
        obj_row.put('namlstm4_flg',tab3_namlstm4_flg);
        obj_row.put('namlstm5_flg',tab3_namlstm5_flg);
        obj_row.put('codtitlc_flg',tab3_codtitlc_flg);
        obj_row.put('namfstce_flg',tab3_namfstce_flg);
        obj_row.put('namfstct_flg',tab3_namfstct_flg);
        obj_row.put('namfstc3_flg',tab3_namfstc3_flg);
        obj_row.put('namfstc4_flg',tab3_namfstc4_flg);
        obj_row.put('namfstc5_flg',tab3_namfstc5_flg);
        obj_row.put('namlstce_flg',tab3_namlstce_flg);
        obj_row.put('namlstct_flg',tab3_namlstct_flg);
        obj_row.put('namlstc3_flg',tab3_namlstc3_flg);
        obj_row.put('namlstc4_flg',tab3_namlstc4_flg);
        obj_row.put('namlstc5_flg',tab3_namlstc5_flg);

        obj_row.put('dtebdfa',to_char(tab3_dtebdfa,'dd/mm/yyyy'));
        obj_row.put('staliff',tab3_staliff);
        obj_row.put('dtedeathf',to_char(tab3_dtedeathf,'dd/mm/yyyy'));
        obj_row.put('filenamf',tab3_filenamf);
        obj_row.put('dtebdmo',to_char(tab3_dtebdmo,'dd/mm/yyyy'));
        obj_row.put('stalifm',tab3_stalifm);
        obj_row.put('dtedeathm',to_char(tab3_dtedeathm,'dd/mm/yyyy'));
        obj_row.put('filenamm',tab3_filenamm);
        obj_row.put('dtebdfa_flg',tab3_dtebdfa_flg);
        obj_row.put('staliff_flg',tab3_staliff_flg);
        obj_row.put('dtedeathf_flg',tab3_dtedeathf_flg);
        obj_row.put('filenamf_flg',tab3_filenamf_flg);
        obj_row.put('dtebdmo_flg',tab3_dtebdmo_flg);
        obj_row.put('stalifm_flg',tab3_stalifm_flg);
        obj_row.put('dtedeathm_flg',tab3_dtedeathm_flg);
        obj_row.put('filenamm_flg',tab3_filenamm_flg);

        obj_row.put('namfstf_flg',namfstf_flg);
        obj_row.put('namlstf_flg',namlstf_flg);
        obj_row.put('namfstm_flg',namfstm_flg);
        obj_row.put('namlstm_flg',namlstm_flg);
        obj_row.put('namfstc_flg',namfstc_flg);
        obj_row.put('namlstc_flg',namlstc_flg);
        obj_row.put('path_filenamf',path_filenamf);
        obj_row.put('path_filenamm',path_filenamm);


        json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab5;

  procedure get_detail2_tab6(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_TAB2_RELATIVES';
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    tab4_staappr        varchar2(4000 char);
    tab4_dteinput       varchar2(4000 char);
    tab4_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    flg_status          varchar2(10 char) := 'N';
    numseq_flg          varchar2(10 char) := 'N';
    codemprl_flg        varchar2(10 char) := 'N';
    namrel_flg          varchar2(10 char) := 'N';
    numtelec_flg        varchar2(10 char) := 'N';
    adrcomt_flg         varchar2(10 char) := 'N';

    --Cursor
    cursor c_trelatives is
      select numseq,codemprl,namrele,namrelt,namrel3,namrel4,namrel5,numtelec,adrcomt,
             decode(global_v_lang,'101',namrele
                                 ,'102',namrelt
                                 ,'103',namrel3
                                 ,'104',namrel4
                                 ,'105',namrel5) as namrel
        from trelatives
       where codempid = b_index_codempid
    order by numseq;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    = v_numseq;

    cursor c1 is
      select distinct(seqno) as seqno
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    not in (select numseq
                                from trelatives
                               where codempid = b_index_codempid)
      order by seqno;

    cursor c2(p_doc_seqno number) is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 26
         and seqno    = p_doc_seqno
      order by seqno;
    --
  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();

    for r1 in c_trelatives loop
      tab2_relatives_numseq        := r1.numseq;
      tab2_relatives_codemprl      := r1.codemprl;
      tab2_relatives_namrele       := r1.namrele;
      tab2_relatives_namrelt       := r1.namrelt;
      tab2_relatives_namrel3       := r1.namrel3;
      tab2_relatives_namrel4       := r1.namrel4;
      tab2_relatives_namrel5       := r1.namrel5;
      tab2_relatives_numtelec      := r1.numtelec;
      tab2_relatives_adrcomt       := r1.adrcomt;
      v_num := v_num + 1;
      obj_data := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('numseq',tab2_relatives_numseq);
      obj_data.put('codemprl',tab2_relatives_codemprl);
      obj_data.put('namrel',r1.namrel);
      obj_data.put('namrele',tab2_relatives_namrele);
      obj_data.put('namrelt',tab2_relatives_namrelt);
      obj_data.put('namrel3',tab2_relatives_namrel3);
      obj_data.put('namrel4',tab2_relatives_namrel4);
      obj_data.put('namrel5',tab2_relatives_namrel5);
      obj_data.put('numtelec',tab2_relatives_numtelec);
      obj_data.put('adrcomt',tab2_relatives_adrcomt);
      tab4_status := null;

      v_numseq := r1.numseq;
      for i in c_temeslog2 loop
        tab4_status := i.status;
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
        else
          obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
        end if;

        if i.fldedit = 'NUMSEQ' then
            flg_status := 'Y';
            numseq_flg := 'Y';
        end if;
        if i.fldedit = 'CODEMPRL' then
            flg_status := 'Y';
            codemprl_flg := 'Y';
        end if;
        if i.fldedit in ('NAMRELE','NAMRELT','NAMREL3','NAMREL4','NAMREL5') then
            flg_status := 'Y';
            namrel_flg := 'Y';
        end if;
        if i.fldedit = 'NUMTELEC' then
            flg_status := 'Y';
            numtelec_flg := 'Y';
        end if;
        if i.fldedit = 'ADRCOMT' then
            flg_status := 'Y';
            adrcomt_flg := 'Y';
        end if;

        --<<User37 #644 4.ES.MS Module 28/04/2021 
        if global_v_lang = 101 and i.fldedit = 'NAMRELE' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 102 and i.fldedit = 'NAMRELT' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 103 and i.fldedit = 'NAMREL3' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 104 and i.fldedit = 'NAMREL4' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 105 and i.fldedit = 'NAMREL5' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        -->>User37 #644 4.ES.MS Module 28/04/2021 

        obj_data.put('flg_status',flg_status);
        obj_data.put('numseq_flg',numseq_flg);
        obj_data.put('codemprl_flg',codemprl_flg);
        obj_data.put('namrel_flg',namrel_flg);
        obj_data.put('numtelec_flg',numtelec_flg);
        obj_data.put('adrcomt_flg',adrcomt_flg);

        begin
          select staappr into tab4_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 2;
        exception when no_data_found then
          tab4_staappr := 'P';
        end;
      end loop;
      obj_data.put('desc_status',get_tlistval_name('STACHG',nvl(tab4_status,'N'),global_v_lang));
      obj_row.put(to_char(v_num-1),obj_data);
    end loop;

    v_num := nvl(v_num,0);
    for x in c1 loop
      v_num := v_num + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', ' ');
      obj_data.put('flg', ' ');
      obj_data.put('total',   v_rcnt);
      obj_data.put('rcnt',    v_num);
      for i in c2(x.seqno) loop
        tab4_numseq   := i.seqno;
        obj_data.put('desc_status',get_tlistval_name('STACHG',i.status,global_v_lang));
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else
          obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
        end if;

        if global_v_lang = 101 and i.fldedit = 'NAMRELE' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 102 and i.fldedit = 'NAMRELT' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 103 and i.fldedit = 'NAMREL3' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 104 and i.fldedit = 'NAMREL4' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if global_v_lang = 105 and i.fldedit = 'NAMREL5' then
          obj_data.put(lower('NAMREL'),i.desnew);
        end if;
        if i.fldedit = 'NUMSEQ' then
            flg_status := 'Y';
            numseq_flg := 'Y';
        end if;
        if i.fldedit = 'CODEMPRL' then
            flg_status := 'Y';
            codemprl_flg := 'Y';
        end if;
        if i.fldedit in ('NAMRELE','NAMRELT','NAMREL3','NAMREL4','NAMREL5') then
            flg_status := 'Y';
            namrel_flg := 'Y';
        end if;
        if i.fldedit = 'NUMTELEC' then
            flg_status := 'Y';
            numtelec_flg := 'Y';
        end if;
        if i.fldedit = 'ADRCOMT' then
            flg_status := 'Y';
            adrcomt_flg := 'Y';
        end if;
        obj_data.put('flg_status',flg_status);
        obj_data.put('numseq_flg',numseq_flg);
        obj_data.put('codemprl_flg',codemprl_flg);
        obj_data.put('namrel_flg',namrel_flg);
        obj_data.put('numtelec_flg',numtelec_flg);
        obj_data.put('adrcomt_flg',adrcomt_flg);

      end loop;
      begin
        select staappr into tab4_staappr
          from tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and typchg   = 2;
      exception when no_data_found then
        tab4_staappr := 'A';
      end;
      obj_data.put('no',v_num);
      obj_data.put('numseq',tab4_numseq);
      obj_data.put('v_staappr',tab4_staappr);
      obj_row.put(to_char(v_num-1),obj_data);
    end loop;

   json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab6;

    --  hres32e_detail_tab8_e
  procedure get_detail2_tab8_table1(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_1';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    v_amtdeduct         varchar2(20);
    v_amtspded          varchar2(20);
    v_coddeduct         varchar2(20);
    tab8_coddeduct      varchar2(4000 char);
    tab8_desdeduct      varchar2(4000 char);
    tab8_v_amtdeduct    varchar2(4000 char);
    tab8_v_amtdeduct_spous varchar2(4000 char);
    tab8_amtdeduct      varchar2(4000 char);
    tab8_typdeduct      varchar2(4000 char);
    tab8_qtychned       varchar2(4000 char);
    tab8_qtychedu       varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    flg_new_e           varchar2(4000 char);
    amtdeduct_flg       varchar2(10 char) := 'N';
    amtdeduct_spous_flg varchar2(10 char) := 'N';
    flg_status          varchar2(10 char) := 'N';

    --Cursor
    cursor c_e is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and codcompy = p_codcompy)
         and typdeduct = 'E'
         and codcompy = p_codcompy
         AND coddeduct NOT IN ('E001');
      --
      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq    = b_index_dtereq
         and numseq    = b_index_numseq
         and numpage   in (281,881)
         AND typdeduct = 'E'
         AND coddeduct NOT IN ('E001');
    --
    begin
    initial_value(json_str_input);
      begin
        select count(*) into v_rcnt from(
          select coddeduct
            from tdeductd
           where dteyreff  = (select max(dteyreff)
                                from tdeductd
                               where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                               and codcompy = p_codcompy)
             and typdeduct = 'E'
             and codcompy = p_codcompy
             and coddeduct not in ('E001'));
      end;
      obj_row  := json_object_t();
      if v_rcnt > 0 then
        --
        for i in c_e loop
          begin
            select amtdeduct into v_amtdeduct
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'E';
          exception when no_data_found then
            v_amtdeduct :=  null;
          end;

          if v_amtdeduct is null then
            begin
              select amtdeduct into v_amtdeduct
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtdeduct :=  null;
            end;
          end if;
          -- for amtdeduct_spous
          begin
            select amtspded into v_amtspded
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'E';
          exception when no_data_found then
            v_amtspded := null;
          end;
          if v_amtspded is null then
            begin
              select amtspded into v_amtspded
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtspded := null;
            end;
          end if;
          --------------------
          if i.coddeduct is not null then
            tab8_coddeduct   := i.coddeduct;
            tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
            tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
            tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
            tab8_amtdeduct   := v_amtdeduct;
            tab8_typdeduct   := i.typdeduct;
            flg_new_e   := 'N';
            --
            for j in c_temeslog3 loop
              v_coddeduct := j.coddeduct;
              if tab8_coddeduct = v_coddeduct then
                if j.numpage = 281 then
                  tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
                  amtdeduct_flg    := 'Y';
                  flg_status       := 'Y';
                elsif j.numpage = 881 then
                  tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
                  amtdeduct_spous_flg    := 'Y';
                  flg_status             := 'Y';
                end if;
                flg_new_e   := 'Y';
              end if;
            end loop;
            --
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('total',v_rcnt);
            obj_data.put('rcnt' ,v_num);
            obj_data.put('coddeduct',tab8_coddeduct);
            obj_data.put('desdeduct',tab8_desdeduct);
--            obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
            obj_data.put('typdeduct',tab8_typdeduct);
            obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
            obj_data.put('qtychned',nvl(tab8_qtychned,0));
            obj_data.put('flg_new_e',nvl(flg_new_e,0));
            obj_data.put('amtdeduct_flg',nvl(amtdeduct_flg,'N'));
            obj_data.put('amtdeduct_spous_flg',nvl(amtdeduct_spous_flg,'N'));
            obj_data.put('flg_status',nvl(flg_status,'N'));

            obj_row.put(to_char(v_num-1),obj_data);
          end if;
        end loop;
        --
      end if; --v_rcnt

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab8_table1;

  --  hres32e_detail_tab8_2
  procedure get_detail2_tab8_table2(json_str_input in clob, json_str_output out clob) is
  obj_row             json_object_t;
  obj_data            json_object_t;
  v_rcnt              number := 0;
  v_num               number := 0;
  v_concat            varchar2(1 char);
  --
  global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_2';
  --
  v_numappl           varchar2(4000 char);
  v_codcomp           varchar2(4000 char);
  v_numseq            varchar2(100 char);
  v_amtdeduct         varchar2(20);
  v_amtspded          varchar2(20);
  v_coddeduct         varchar2(20);
  tab8_coddeduct      varchar2(4000 char);
  tab8_desdeduct      varchar2(4000 char);
  tab8_v_amtdeduct    varchar2(4000 char);
  tab8_v_amtdeduct_spous varchar2(4000 char);
  tab8_amtdeduct      varchar2(4000 char);
  tab8_typdeduct      varchar2(4000 char);
  tab8_qtychned       varchar2(4000 char);
  tab8_qtychedu       varchar2(4000 char);
  v_year              varchar2(4000 char);
  v_date              varchar2(4000 char);
  v_des               varchar2(4000 char);
  flg_new_d           varchar2(4000 char);
  tab8_qtychned_flg   varchar2(20):= 'N';
  tab8_qtychedu_flg   varchar2(20):= 'N';
  amtdeduct_flg       varchar2(10 char) := 'N';
  amtdeduct_spous_flg varchar2(10 char) := 'N';
  flg_status          varchar2(10 char) := 'N';

    --Cursor
    cursor c_d is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and codcompy = p_codcompy)
         and typdeduct = 'D'
         and codcompy = p_codcompy
         and coddeduct not in ('D001','D002');

      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq    = b_index_dtereq
         and numseq    = b_index_numseq
         and numpage   in (282,882)
         and typdeduct = 'D'
         and coddeduct not in ('D001','D002');

      cursor c_temeslog1 is
      select fldedit,desnew
        from temeslog1
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  in (2,222);

    begin
    initial_value(json_str_input);
      begin
        select count(*)
          into v_rcnt
          from( select coddeduct
                  from tdeductd
                 where dteyreff  = ( select max(dteyreff)
                                       from tdeductd
                                      where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                                      and codcompy = p_codcompy)
               and typdeduct = 'D'
               and codcompy = p_codcompy
               and coddeduct not in ('D001','D002'));
      end;
      obj_row  := json_object_t();
      if v_rcnt > 0 then
       begin
          select qtychedu,qtychned
          into   tab8_qtychedu,tab8_qtychned
          from   temploy3
          where  codempid  = b_index_codempid ;
       exception when no_data_found then
          tab8_qtychedu := 0 ;
          tab8_qtychned := 0 ;
       end ;

      for i in c_d loop
        begin
          select amtdeduct into v_amtdeduct
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'D';
        exception when no_data_found then
          v_amtdeduct :=  null;
        end;
        if v_amtdeduct is null then
          begin
            select amtdeduct into v_amtdeduct
              from tempded
             where codempid  = b_index_codempid
               and coddeduct = i.coddeduct;
          exception when no_data_found then
            v_amtdeduct :=  null;
          end;
        end if;
        -- for amtdeduct_spous
        begin
          select amtspded into v_amtspded
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'D';
        exception when no_data_found then
          v_amtspded := null;
        end;
        if v_amtspded is null then
          begin
            select amtspded into v_amtspded
              from tempded
             where codempid  = b_index_codempid
               and coddeduct = i.coddeduct;
          exception when no_data_found then
            v_amtspded := null;
          end;
        end if;
        --------------------
        if i.coddeduct is not null then
          tab8_coddeduct   := i.coddeduct;
          tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
          tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
          tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
          tab8_amtdeduct   := v_amtdeduct;
          tab8_typdeduct   := i.typdeduct;
          flg_new_d   := 'N';

          for j in c_temeslog3 loop
            v_coddeduct := j.coddeduct;
            if tab8_coddeduct = v_coddeduct then
              if j.numpage = 282 then
                tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
                amtdeduct_flg    := 'Y';
                flg_status       := 'Y';
              elsif j.numpage = 882 then
                tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
                amtdeduct_spous_flg    := 'Y';
                flg_status             := 'Y';
              end if;
              flg_new_d   := 'Y';
            end if;
          end loop;

          for k in c_temeslog1 loop
            if k.fldedit = 'QTYCHNED' then
            tab8_qtychned := k.desnew;
            tab8_qtychned_flg := 'Y';
            elsif k.fldedit = 'QTYCHEDU' then
            tab8_qtychedu := k.desnew;
            tab8_qtychedu_flg := 'Y';
            end if;
          end loop;
          v_num := v_num + 1;
          -- add data
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
          obj_data.put('coddeduct',tab8_coddeduct);
          obj_data.put('desdeduct',tab8_desdeduct);
--          obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
          obj_data.put('amtdeduct',tab8_v_amtdeduct);
          obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
          obj_data.put('typdeduct',tab8_typdeduct);
          obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
          obj_data.put('qtychned',nvl(tab8_qtychned,0));
          obj_data.put('flg_new_d',nvl(flg_new_d,0));
          obj_data.put('qtychned_flg',nvl(tab8_qtychned_flg,0));
          obj_data.put('qtychedu_flg',nvl(tab8_qtychedu_flg,0));
          obj_data.put('amtdeduct_flg',nvl(amtdeduct_flg,'N'));
          obj_data.put('amtdeduct_spous_flg',nvl(amtdeduct_spous_flg,'N'));
          obj_data.put('flg_status',nvl(flg_status,'N'));

          obj_row.put(to_char(v_num-1),obj_data);
        end if;
      end loop;
      --
      end if; --v_rcnt
      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab8_table2;

  --  hres32e_detail_tab8_3
  procedure get_detail2_tab8_table3(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_coddeduct         varchar2(20);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB8_3';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    v_amtdeduct         varchar2(20);
    v_amtspded          varchar2(20);
    tab8_coddeduct      varchar2(4000 char);
    tab8_desdeduct      varchar2(4000 char);
    tab8_v_amtdeduct    varchar2(4000 char);
    tab8_v_amtdeduct_spous varchar2(4000 char);
    tab8_amtdeduct      varchar2(4000 char);
    tab8_typdeduct      varchar2(4000 char);
    tab8_qtychned       varchar2(4000 char);
    tab8_qtychedu       varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    flg_new_o           varchar2(4000 char);
    amtdeduct_flg       varchar2(10 char) := 'N';
    amtdeduct_spous_flg varchar2(10 char) := 'N';
    flg_status          varchar2(10 char) := 'N';

    --Cursor
    cursor c_o is
      select coddeduct,typdeduct
        from tdeductd
       where dteyreff  = (select max(dteyreff)
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and codcompy = p_codcompy)
         and typdeduct = 'O'
         and codcompy = p_codcompy;

      cursor c_temeslog3 is
      select *
        from temeslog3
       where codempid  = b_index_codempid
         and dtereq    = b_index_dtereq
         and numseq    = b_index_numseq
         and numpage   in (283,883)
         and typdeduct = 'O';

    begin
     initial_value(json_str_input);
      begin
        select count(*)
          into v_rcnt
          from ( select coddeduct
                  from tdeductd
                 where dteyreff  = (  select max(dteyreff)
                                      from tdeductd
                                      where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                                      and codcompy = p_codcompy)
          and typdeduct = 'O'
          and codcompy = p_codcompy);
      end;
      obj_row := json_object_t();
      if v_rcnt > 0 then
        --
        for i in c_o loop
        begin
          select amtdeduct into v_amtdeduct
            from tempdech
           where codempid  = b_index_codempid
             and dtereq    = b_index_dtereq
             and coddeduct = i.coddeduct
             and typdeduct = 'O';
            exception when no_data_found then
              v_amtdeduct :=  null;
          end;
          if v_amtdeduct is null then
            begin
              select amtdeduct into v_amtdeduct
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtdeduct :=  null;
            end;
          end if;
          -- for amtdeduct_spous
          begin
            select amtspded into v_amtspded
              from tempdech
             where codempid  = b_index_codempid
               and dtereq    = b_index_dtereq
               and coddeduct = i.coddeduct
               and typdeduct = 'O';
          exception when no_data_found then
            v_amtspded := null;
          end;
          if v_amtspded is null then
            begin
              select amtspded into v_amtspded
                from tempded
               where codempid  = b_index_codempid
                 and coddeduct = i.coddeduct;
            exception when no_data_found then
              v_amtspded := null;
            end;
          end if;
          --------------------
          if i.coddeduct is not null then
            tab8_coddeduct   := i.coddeduct;
            tab8_desdeduct   := get_tcodeduct_name(i.coddeduct,global_v_lang);
            tab8_v_amtdeduct := stddec(v_amtdeduct,b_index_codempid,v_chken);
            tab8_v_amtdeduct_spous := stddec(v_amtspded,b_index_codempid,v_chken);
            tab8_amtdeduct   := v_amtdeduct;
            tab8_typdeduct   := i.typdeduct;
            flg_new_o   := 'N';

            for j in c_temeslog3 loop
              v_coddeduct := j.coddeduct;
              if tab8_coddeduct = v_coddeduct then
                if j.numpage = 283 then
                  tab8_v_amtdeduct := stddec(j.desnew,b_index_codempid,v_chken);
                  amtdeduct_flg    := 'Y';
                  flg_status       := 'Y';
                elsif j.numpage = 883 then
                  tab8_v_amtdeduct_spous := stddec(j.desnew,b_index_codempid,v_chken);
                  amtdeduct_spous_flg    := 'Y';
                  flg_status             := 'Y';
                end if;
                flg_new_o   := 'Y';
              end if;
            end loop;
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('coddeduct',tab8_coddeduct);
            obj_data.put('desdeduct',tab8_desdeduct);
--            obj_data.put('v_amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct',tab8_v_amtdeduct);
            obj_data.put('amtdeduct_spous',tab8_v_amtdeduct_spous);
            obj_data.put('typdeduct',tab8_typdeduct);
            obj_data.put('qtychedu',nvl(tab8_qtychedu,0));
            obj_data.put('qtychned',nvl(tab8_qtychned,0));
            obj_data.put('flg_new_o',nvl(flg_new_o,0));
            obj_data.put('amtdeduct_flg',nvl(amtdeduct_flg,'N'));
            obj_data.put('amtdeduct_spous_flg',nvl(amtdeduct_spous_flg,'N'));
            obj_data.put('flg_status',nvl(flg_status,'N'));

            obj_row.put(to_char(v_num-1),obj_data);
          end if;
        end loop;
      end if; --v_rcnt
      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab8_table3;

  procedure get_detail2_tab9(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB4';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    tab4_numseq         varchar2(4000 char);
    tab4_typdoc         varchar2(4000 char);
    tab4_namtydoc       varchar2(4000 char);
    tab4_namdoc         varchar2(4000 char);
    tab4_dterecv        varchar2(4000 char);
    tab4_dtedocen       varchar2(4000 char);
    tab4_numdoc         varchar2(4000 char);
    tab4_filedoc        varchar2(4000 char);
    tab4_desnote        varchar2(4000 char);
    tab4_status         varchar2(4000 char);
    tab4_flgresume      tappldoc.flgresume%type;
    tab4_coduser        tappldoc.coduser%type;
    tab4_dteupd         date;
    v_numseq            varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    tab4_staappr        varchar2(4000 char);
    tab4_dteinput       varchar2(4000 char);
    tab4_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    path_filename       varchar2(400 char);
    flg_status          varchar2(10 char) := 'N';
    numseq_flg          varchar2(10 char) := 'N';
    typdoc_flg          varchar2(10 char) := 'N';
    namdoc_flg          varchar2(10 char) := 'N';
    dterecv_flg         varchar2(10 char) := 'N';
    dtedocen_flg        varchar2(10 char) := 'N';
    numdoc_flg          varchar2(10 char) := 'N';
    filedoc_flg         varchar2(10 char) := 'N';
    flgresume_flg       varchar2(10 char) := 'N';
    desnote_flg         varchar2(10 char) := 'N';

    --Cursor
    cursor c_tappldoc is
      select numappl,numseq,codempid,namdoc,filedoc,dterecv,dteupd,coduser,typdoc,
      dtedocen,numdoc,desnote,flgresume
        from tappldoc
       where numappl = v_numappl
    order by numseq;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    = v_numseq;

    cursor c1 is
      select distinct(seqno) as seqno
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    not in (select numseq
                                from tappldoc
                               where numappl = v_numappl)
      order by seqno;

    cursor c2(p_doc_seqno number) is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 29
         and seqno    = p_doc_seqno
      order by seqno;
    --
    begin
    initial_value(json_str_input);
      obj_row  := json_object_t();
      begin
        select numappl,codcomp
          into v_numappl,v_codcomp
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
        v_codcomp  := null;
      end;

      if v_numappl is not null then
        begin
          select count(*) into v_rcnt from(
            select numseq
              from tappldoc
             where numappl = v_numappl
          union
            select distinct(seqno)
              from temeslog2
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and numpage  = 29
               and seqno    not in (select numseq
                                      from tappldoc
                                     where numappl = v_numappl));
        end;

        if v_rcnt > 0 then
          for r1 in c_tappldoc loop

            tab4_numseq   := r1.numseq;
            tab4_typdoc   := r1.typdoc;
            tab4_namtydoc := get_tcodec_name('TCODTYDOC',r1.typdoc,global_v_lang);
            tab4_namdoc   := r1.namdoc;
            tab4_dterecv  := to_char(r1.dterecv,'dd/mm/yyyy');
            tab4_dtedocen := to_char(r1.dtedocen,'dd/mm/yyyy');
            tab4_numdoc   := r1.numdoc;
            tab4_filedoc  := r1.filedoc;
            tab4_desnote  := r1.desnote;
            tab4_flgresume  := r1.flgresume;
            tab4_dteupd     := r1.dteupd;
            tab4_coduser    := r1.coduser;
            v_numseq := r1.numseq;
            v_num := v_num + 1;

            path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||tab4_filedoc;

            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab4_numseq);
            obj_data.put('typdoc',tab4_typdoc);
            obj_data.put('namtydoc',tab4_namtydoc);
            obj_data.put('namdoc',tab4_namdoc);
            obj_data.put('dterecv',tab4_dterecv);
            obj_data.put('dtedocen',tab4_dtedocen);
            obj_data.put('numdoc',tab4_numdoc);
            obj_data.put('filedoc',tab4_filedoc||'0000');
            obj_data.put('desnote',tab4_desnote);
            obj_data.put('flgresume',tab4_flgresume);
            obj_data.put('dteupd',to_char(tab4_dteupd,'dd/mm/yyyy'));
            obj_data.put('coduser',tab4_coduser);
            obj_data.put('path_filename',path_filename);
            tab4_status := null;
            for i in c_temeslog2 loop
              tab4_status := i.status;
              if substr(i.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
              else
                obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
                obj_data.put('namtydoc',get_tcodec_name('TCODTYDOC',tab4_typdoc,global_v_lang)); --user35 || 19/09/2017
              end if;
              if i.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
              end if;
              if i.fldedit = 'TYPDOC' then
                flg_status := 'Y';
                typdoc_flg := 'Y';
              end if;
              if i.fldedit = 'NAMDOC' then
                flg_status := 'Y';
                namdoc_flg := 'Y';
              end if;
              if i.fldedit = 'DTERECV' then
                flg_status := 'Y';
                dterecv_flg := 'Y';
              end if;
              if i.fldedit = 'DTEDOCEN' then
                flg_status := 'Y';
                dtedocen_flg := 'Y';
              end if;
              if i.fldedit = 'NUMDOC' then
                flg_status := 'Y';
                numdoc_flg := 'Y';
              end if;
              if i.fldedit = 'FILEDOC' then
                flg_status := 'Y';
                filedoc_flg := 'Y';
                path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')|| '/' || i.desnew;
              end if;
              if i.fldedit = 'FLGRESUME' then
                flg_status := 'Y';
                flgresume_flg := 'Y';
              end if;
              if i.fldedit = 'DESNOTE' then
                flg_status := 'Y';
                desnote_flg := 'Y';
              end if;
              obj_data.put('flg_status',flg_status);
              obj_data.put('numseq_flg',numseq_flg);
              obj_data.put('typdoc_flg',typdoc_flg);
              obj_data.put('namdoc_flg',namdoc_flg);
              obj_data.put('dterecv_flg',dterecv_flg);
              obj_data.put('dtedocen_flg',dtedocen_flg);
              obj_data.put('numdoc_flg',filedoc_flg);
              obj_data.put('filedoc_flg',filedoc_flg);
              obj_data.put('flgresume_flg',flgresume_flg);
              obj_data.put('desnote_flg',desnote_flg);
              obj_data.put('path_filename',path_filename);
              begin
                select staappr into tab4_staappr
                  from tempch
                 where codempid = b_index_codempid
                   and dtereq   = b_index_dtereq
                   and numseq   = b_index_numseq
                   and typchg   = 2;
              exception when no_data_found then
                tab4_staappr := 'P';
              end;
            end loop;
            obj_data.put('desc_status',get_tlistval_name('STACHG',nvl(tab4_status,'N'),global_v_lang));
            obj_row.put(to_char(v_numseq-1),obj_data);
          end loop;

          v_num := nvl(v_numseq,0);
          for x in c1 loop
            v_num := v_num + 1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            for i in c2(x.seqno) loop
              tab4_numseq   := i.seqno;
              obj_data.put('desc_status',get_tlistval_name('STACHG',i.status,global_v_lang));
              if substr(i.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
              else
                obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
                if i.fldedit = 'TYPDOC' then
                  obj_data.put('new_namtydoc',get_tcodec_name('TCODTYDOC',tab4_typdoc,global_v_lang));  --user35 || 19/09/2017
                end if;
              end if;
              if i.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
              end if;
              if i.fldedit = 'TYPDOC' then
                flg_status := 'Y';
                typdoc_flg := 'Y';
              end if;
              if i.fldedit = 'NAMDOC' then
                flg_status := 'Y';
                namdoc_flg := 'Y';
              end if;
              if i.fldedit = 'DTERECV' then
                flg_status := 'Y';
                dterecv_flg := 'Y';
              end if;
              if i.fldedit = 'DTEDOCEN' then
                flg_status := 'Y';
                dtedocen_flg := 'Y';
              end if;
              if i.fldedit = 'NUMDOC' then
                flg_status := 'Y';
                numdoc_flg := 'Y';
              end if;
              if i.fldedit = 'FILEDOC' then
                flg_status := 'Y';
                filedoc_flg := 'Y';
                path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')|| '/' || i.desnew;
              end if;
              if i.fldedit = 'FLGRESUME' then
                flg_status := 'Y';
                flgresume_flg := 'Y';
              end if;
              if i.fldedit = 'DESNOTE' then
                flg_status := 'Y';
                desnote_flg := 'Y';
              end if;
              obj_data.put('flg_status',flg_status);
              obj_data.put('numseq_flg',numseq_flg);
              obj_data.put('typdoc_flg',typdoc_flg);
              obj_data.put('namdoc_flg',namdoc_flg);
              obj_data.put('dterecv_flg',dterecv_flg);
              obj_data.put('dtedocen_flg',dtedocen_flg);
              obj_data.put('numdoc_flg',filedoc_flg);
              obj_data.put('filedoc_flg',filedoc_flg);
              obj_data.put('flgresume_flg',flgresume_flg);
              obj_data.put('desnote_flg',desnote_flg);
              obj_data.put('path_filename',path_filename);
            end loop;
            begin
              select staappr into tab4_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 2;
            exception when no_data_found then
              tab4_staappr := 'A';
            end;
            obj_data.put('no',v_num);
            obj_data.put('numseq',tab4_numseq);
            obj_data.put('v_staappr',tab4_staappr);
            obj_row.put(to_char(v_num-1),obj_data);
          end loop;
        end if;
      end if;

      json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail2_tab9;

  procedure get_detail1(json_str_input in clob, json_str_output out clob) is
    obj_row               json_object_t;
    v_rcnt                number := 0;
    v_num                 number := 0;
    v_concat              varchar2(1 char);
    tab1_n_codtitle_flg   varchar2(20 char)   := 'N';
    tab1_n_name_flg       varchar2(20 char)   := 'N';
    tab1_n_last_flg       varchar2(20 char)   := 'N';
    tab1_n_nick_flg       varchar2(20 char)   := 'N';
    global_v_codapp       varchar2(4000 char) := 'HRES32E_DETAIL_TAB1';
    v_name                temploy1.namfirste%type;
    v_last                temploy1.namlaste%type;
    v_nick                temploy1.nickname%type;
  -- Cursor
  cursor c_temploy1 is
    select codtitle,namfirste,namfirstt,namfirst3,namfirst4,
           namfirst5,namlaste,namlastt,namlast3,namlast4,namlast5,
           nickname,nicknamt,nicknam3,nicknam4,nicknam5
      from temploy1
     where codempid = b_index_codempid;

  cursor c_temeslog1 is
    select fldedit,desnew
      from temeslog1
     where codempid = b_index_codempid
       and dtereq   = b_index_dtereq
       and numseq   = b_index_numseq
       and numpage  = 11;
    --
    begin
    initial_value(json_str_input);
      for i in c_temploy1 loop
        tab1_codtitle     := i.codtitle;
        tab1_namfirste    := i.namfirste;
        tab1_namfirstt    := i.namfirstt;
        tab1_namfirst3    := i.namfirst3;
        tab1_namfirst4    := i.namfirst4;
        tab1_namfirst5    := i.namfirst5;
        tab1_namlaste     := i.namlaste;
        tab1_namlastt     := i.namlastt;
        tab1_namlast3     := i.namlast3;
        tab1_namlast4     := i.namlast4;
        tab1_namlast5     := i.namlast5;
        tab1_nickname     := i.nickname;
        tab1_nicknamt     := i.nicknamt;
        tab1_nicknam3     := i.nicknam3;
        tab1_nicknam4     := i.nicknam4;
        tab1_nicknam5     := i.nicknam5;
      end loop;

      begin
        select desnote,staappr,dteinput,dtecancel
          into tab1_desnote,tab1_staappr,tab1_dteinput,tab1_dtecancel
          from tempch
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and typchg   = 1;
      exception when no_data_found then
        tab1_staappr := 'P';
        tab1_desnote := null;
      end;

      tab1_p_codtitle := tab1_codtitle;
      if global_v_lang = '101' then
        tab1_p_name  := tab1_namfirste;
        tab1_p_last  := tab1_namlaste;
        tab1_p_nick  := tab1_nickname;
        v_name       := tab1_namfirste;
        v_last       := tab1_namlaste;
        v_nick       := tab1_nickname;
      elsif global_v_lang = '102' then
        tab1_p_name  := tab1_namfirstt;
        tab1_p_last  := tab1_namlastt;
        tab1_p_nick  := tab1_nicknamt;
        v_name       := tab1_namfirstt;
        v_last       := tab1_namlastt;
        v_nick       := tab1_nicknamt;
      elsif global_v_lang = '103' then
        tab1_p_name  := tab1_namfirst3;
        tab1_p_last  := tab1_namlast3;
        tab1_p_nick  := tab1_nicknam3;
        v_name       := tab1_namfirst3;
        v_last       := tab1_namlast3;
        v_nick       := tab1_nicknam3;
      elsif global_v_lang = '104' then
        tab1_p_name  := tab1_namfirst4;
        tab1_p_last  := tab1_namlast4;
        tab1_p_nick  := tab1_nicknam4;
        v_name       := tab1_namfirst4;
        v_last       := tab1_namlast4;
        v_nick       := tab1_nicknam4;
      elsif global_v_lang = '105' then
        tab1_p_name  := tab1_namfirst5;
        tab1_p_last  := tab1_namlast5;
        tab1_p_nick  := tab1_nicknam5;
        v_name       := tab1_namfirst5;
        v_last       := tab1_namlast5;
        v_nick       := tab1_nicknam5;
      end if;
      --
      for i in c_temeslog1 loop
        if i.fldedit = 'CODTITLE' then
          tab1_n_codtitle := i.desnew ;
          tab1_n_codtitle_flg := 'Y';
--<< user28 || 12/03/2019 || redmind #6317
        elsif i.fldedit = 'NAMFIRSTE' then
          tab1_n_namee     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRSTT' then
          tab1_n_namet     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
-->> user28 || 12/03/2019 || redmind #6317
        elsif i.fldedit = 'NAMFIRST3' then
          tab1_n_name3     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST4' then
          tab1_n_name4     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMFIRST5' then
          tab1_n_name5     := i.desnew ;
          tab1_n_name      := i.desnew ;
          tab1_n_name_flg := 'Y';
        elsif i.fldedit = 'NAMLASTE' then
          tab1_n_laste     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLASTT' then
          tab1_n_lastt     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST3' then
          tab1_n_last3     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST4' then
          tab1_n_last4     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NAMLAST5' then
          tab1_n_last5     := i.desnew ;
          tab1_n_last      := i.desnew ;
          tab1_n_last_flg := 'Y';
        elsif i.fldedit = 'NICKNAME' then
          tab1_n_nicke     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := 'Y';
        elsif i.fldedit = 'NICKNAMT' then
          tab1_n_nickt     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := 'Y';
        elsif i.fldedit = 'NICKNAM3' then
          tab1_n_nick3     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := 'Y';
        elsif i.fldedit = 'NICKNAM4' then
          tab1_n_nick4     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := 'Y';
        elsif i.fldedit = 'NICKNAM5' then
          tab1_n_nick5     := i.desnew ;
          tab1_n_nick      := i.desnew ;
          tab1_n_nick_flg  := 'Y';
        end if;
      end loop;

      obj_row := json_object_t();
      obj_row.put('coderror','200');
      obj_row.put('desc_coderror','');
      obj_row.put('httpcode','');
      obj_row.put('flg','');
      obj_row.put('codtitle',tab1_codtitle);
      obj_row.put('desc_codtitle',get_tlistval_name('CODTITLE',tab1_codtitle,global_v_lang));
      obj_row.put('n_codtitle',tab1_n_codtitle);
      --<< user28 || 12/03/2019 || redmind #6317
      obj_row.put('name',v_name);
      obj_row.put('namee',tab1_namfirste);
      obj_row.put('namet',tab1_namfirstt);
      obj_row.put('name3',tab1_namfirst3);
      obj_row.put('name4',tab1_namfirst4);
      obj_row.put('name5',tab1_namfirst5);
      obj_row.put('last',v_last);
      obj_row.put('laste',tab1_namlaste);
      obj_row.put('lastt',tab1_namlastt);
      obj_row.put('last3',tab1_namlast3);
      obj_row.put('last4',tab1_namlast4);
      obj_row.put('last5',tab1_namlast5);
      obj_row.put('nick',v_nick);
      obj_row.put('nicke',tab1_nickname);
      obj_row.put('nickt',tab1_nicknamt);
      obj_row.put('nick3',tab1_nicknam3);
      obj_row.put('nick4',tab1_nicknam4);
      obj_row.put('nick5',tab1_nicknam5);
      obj_row.put('n_name',tab1_n_name);
      obj_row.put('n_namee',tab1_n_namee);
      obj_row.put('n_namet',tab1_n_namet);
      obj_row.put('n_name3',tab1_n_name3);
      obj_row.put('n_name4',tab1_n_name4);
      obj_row.put('n_name5',tab1_n_name5);
      obj_row.put('n_last',tab1_n_last);
      obj_row.put('n_laste',tab1_n_laste);
      obj_row.put('n_lastt',tab1_n_lastt);
      obj_row.put('n_last3',tab1_n_last3);
      obj_row.put('n_last4',tab1_n_last4);
      obj_row.put('n_last5',tab1_n_last5);
      obj_row.put('n_nick',tab1_n_nick);
      obj_row.put('n_nicke',tab1_n_nicke);
      obj_row.put('n_nickt',tab1_n_nickt);
      obj_row.put('n_nick3',tab1_n_nick3);
      obj_row.put('n_nick4',tab1_n_nick4);
      obj_row.put('n_nick5',tab1_n_nick5);
      -->> user28 || 12/03/2019 || redmind #6317
      obj_row.put('desnote',tab1_desnote);
      obj_row.put('n_codtitle_flg',tab1_n_codtitle_flg);
      obj_row.put('codtitle_flg',tab1_n_codtitle_flg);
      obj_row.put('n_name_flg',tab1_n_name_flg);
      obj_row.put('n_last_flg',tab1_n_last_flg);

      obj_row.put('n_nick_flg',tab1_n_nick_flg);

       json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_detail1;

  procedure get_education(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_numseq            varchar2(100 char);
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB6';
    tab6_numseq         varchar2(4000 char);
    tab6_codedlv        varchar2(4000 char);
    tab6_codinst        varchar2(4000 char);
    tab6_coddglv        varchar2(4000 char);
    tab6_codmajsb       varchar2(4000 char);
    tab6_codminsb       varchar2(4000 char);
    tab6_numgpa         varchar2(4000 char);
    tab6_dtegyear       varchar2(4000 char);
    tab6_stayear        varchar2(4000 char);
    tab6_flgeduc        varchar2(4000 char);
    tab6_codcount       varchar2(4000 char);
    tab6_staappr        varchar2(4000 char);
    tab6_codcomp        varchar2(4000 char);
    tab6_codempid       varchar2(4000 char);
    tab6_desc_codedlv   varchar2(4000 char);
    tab6_desc_coddglv   varchar2(4000 char);
    tab6_desc_codmajsb  varchar2(4000 char);
    tab6_desc_codminsb  varchar2(4000 char);
    tab6_desc_codinst   varchar2(4000 char);
    tab6_desc_codcount  varchar2(4000 char);
    tab6_desc_flgeduc   varchar2(4000 char);
    tab6_flgupdat       varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);
    flg_status          varchar2(10 char) := 'N';
    numseq_flg          varchar2(10 char) := 'N';
    codedlv_flg         varchar2(10 char) := 'N';
    flgeduc_flg         varchar2(10 char) := 'N';
    coddglv_flg         varchar2(10 char) := 'N';
    codmajsb_flg        varchar2(10 char) := 'N';
    codminsb_flg        varchar2(10 char) := 'N';
    codinst_flg         varchar2(10 char) := 'N';
    codcount_flg        varchar2(10 char) := 'N';
    numgpa_flg          varchar2(10 char) := 'N';
    stayear_flg         varchar2(10 char) := 'N';
    dtegyear_flg        varchar2(10 char) := 'N';

    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,codedlv,coddglv,
             codmajsb,codminsb,codinst,codcount,
             numgpa,stayear,dtegyear,flgeduc
        from teducatn
       where numappl = v_numappl
      order by 1;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 31
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 31
         and seqno   not in (select numseq from teducatn
                              where numappl = v_numappl)
      order by seqno;

  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
      into v_numappl,v_codcomp
      from   temploy1
      where  codempid = b_index_codempid  ;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      begin
        select count(*) into v_rcnt from(
          select numseq
          from teducatn
         where numappl = v_numappl
        union
        select distinct(seqno)
          from temeslog2
         where codempid = b_index_codempid
           and dtereq   = b_index_dtereq
           and numseq   = b_index_numseq
           and numpage  = 31
           and seqno   not in (select numseq from teducatn
                               where numappl = v_numappl));
      end;

      if v_rcnt > 0 then
        for i in c1 loop
          tab6_numseq         := i.numseq ;
          tab6_codedlv        := i.codedlv;
          tab6_codinst        := i.codinst;
          tab6_coddglv        := i.coddglv ;
          tab6_codmajsb       := i.codmajsb;
          tab6_codminsb       := i.codminsb;
          tab6_numgpa         := i.numgpa;
          tab6_dtegyear       := i.dtegyear;
          tab6_stayear        := i.stayear;
          tab6_flgeduc        := i.flgeduc;
          tab6_codcount       := i.codcount;
          tab6_staappr        := 'P';
          tab6_codcomp        := v_codcomp;
          tab6_codempid       := b_index_codempid;
          tab6_desc_codedlv   := get_tcodec_name('TCODEDUC',tab6_codedlv,global_v_lang);
          tab6_desc_coddglv   := get_tcodec_name('TCODDGEE',tab6_coddglv,global_v_lang);
          tab6_desc_codmajsb  := get_tcodec_name('TCODMAJR',tab6_codmajsb,global_v_lang);
          tab6_desc_codminsb  := get_tcodec_name('TCODSUBJ',tab6_codminsb,global_v_lang);
          tab6_desc_codinst   := get_tcodec_name('TCODINST',tab6_codinst,global_v_lang);
          tab6_desc_codcount  := get_tcodec_name('TCODCNTY',tab6_codcount,global_v_lang);
          tab6_desc_flgeduc   := get_tlistval_name('FLGEDUC',tab6_flgeduc,global_v_lang);
          tab6_flgupdat       := 'N' ;
          tab6_status         := 'N';
          tab6_desc_status    := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          v_numseq := i.numseq ;
          v_num := v_num + 1;
          -- add data
          tab6_new_flg := 'N';
          obj_data := json_object_t();

          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
          obj_data.put('numseq',tab6_numseq);
          obj_data.put('codedlv',tab6_codedlv);
          obj_data.put('codinst',tab6_codinst);
          obj_data.put('coddglv',tab6_coddglv);
          obj_data.put('codmajsb',tab6_codmajsb);
          obj_data.put('codminsb',tab6_codminsb);
          obj_data.put('numgpa',tab6_numgpa);
          obj_data.put('dtegyear',tab6_dtegyear);
          obj_data.put('stayear',tab6_stayear);
          obj_data.put('flgeduc',tab6_flgeduc);
          obj_data.put('codcount',tab6_codcount);
          obj_data.put('staappr',tab6_staappr);
          obj_data.put('codcomp',tab6_codcomp);
          obj_data.put('codempid',tab6_codempid);
          obj_data.put('desc_codedlv',tab6_desc_codedlv);
          obj_data.put('desc_coddglv',tab6_desc_coddglv);
          obj_data.put('desc_codmajsb',tab6_desc_codmajsb);
          obj_data.put('desc_codminsb',tab6_desc_codminsb);
          obj_data.put('desc_codinst',tab6_desc_codinst);
          obj_data.put('desc_codcount',tab6_desc_codcount);
          obj_data.put('desc_flgeduc',tab6_desc_flgeduc);
          obj_data.put('flgupdat',tab6_flgupdat);
          obj_data.put('new_flg',tab6_new_flg);

          for j in c_temeslog2 loop
            if substr(j.fldedit,1,3) = 'DTE' and j.fldedit <> 'DTEGYEAR' then
              v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
              v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
              v_des  := v_date||'/'||v_year;
              obj_data.put(lower(j.fldedit),v_des); --user35 || 19/09/2017
            else
              obj_data.put(lower(j.fldedit),j.desnew);
              if j.fldedit = 'CODEDLV' then
                obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODDGLV' then
                obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODMAJSB' then
                obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODMINSB' then
                obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODINST' then
                obj_data.put('desc_codinst',get_tcodec_name('TCODINST',j.desnew,global_v_lang));
              elsif j.fldedit = 'CODCOUNT' then
                obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',j.desnew,global_v_lang));
              elsif j.fldedit = 'FLGEDUC' then
                obj_data.put('desc_flgeduc',get_tlistval_name('FLGEDUC',j.desnew,global_v_lang));
              end if;
            end if;

            if j.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
            end if;
            if j.fldedit = 'CODEDLV' then
                flg_status := 'Y';
                codedlv_flg := 'Y';
            end if;
            if j.fldedit = 'FLGEDUC' then
                flg_status := 'Y';
                flgeduc_flg := 'Y';
            end if;
            if j.fldedit = 'CODDGLV' then
                flg_status := 'Y';
                coddglv_flg := 'Y';
            end if;
            if j.fldedit = 'CODMAJSB' then
                flg_status := 'Y';
                codmajsb_flg := 'Y';
            end if;
            if j.fldedit = 'CODMINSB' then
                flg_status := 'Y';
                codminsb_flg := 'Y';
            end if;
            if j.fldedit = 'CODINST' then
                flg_status := 'Y';
                codinst_flg := 'Y';
            end if;
            if j.fldedit = 'CODCOUNT' then
                flg_status := 'Y';
                codcount_flg := 'Y';
            end if;
            if j.fldedit = 'NUMGPA' then
                flg_status := 'Y';
                numgpa_flg := 'Y';
            end if;
            if j.fldedit = 'STAYEAR' then
                flg_status := 'Y';
                stayear_flg := 'Y';
            end if;
            if j.fldedit = 'DTEGYEAR' then
                flg_status := 'Y';
                dtegyear_flg := 'Y';
            end if;
            obj_data.put('flg_status',flg_status);
            obj_data.put('numseq_flg',numseq_flg);
            obj_data.put('codedlv_flg',codedlv_flg);
            obj_data.put('flgeduc_flg',flgeduc_flg);
            obj_data.put('coddglv_flg',coddglv_flg);
            obj_data.put('codmajsb_flg',codmajsb_flg);
            obj_data.put('codminsb_flg',codminsb_flg);
            obj_data.put('codinst_flg',codinst_flg);
            obj_data.put('codcount_flg',codcount_flg);
            obj_data.put('numgpa_flg',numgpa_flg);
            obj_data.put('stayear_flg',stayear_flg);
            obj_data.put('dtegyear_flg',dtegyear_flg);
            --<<user36 JAS590255 20/04/2016
            tab6_status      := j.status;
            tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);
            -->>user36 JAS590255 20/04/2016
            begin
              select staappr into tab6_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 3;
            exception when no_data_found then
              tab6_staappr := 'P';
            end;
          end loop;

          obj_data.put('status',tab6_status);
          obj_data.put('desc_status',tab6_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
        end loop;
        --
        for i in c2 loop
          --v_new_exist := true;
          if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
--            obj_data.put('numseq',tab6_numseq); weerayut 20/12/2017
            obj_data.put('numseq',i.seqno);
            obj_data.put('staappr',tab6_staappr);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
          end if;
          --add data
          tab6_numseq := i.seqno;
          v_numseq    := i.seqno;
          tab6_status      := i.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          tab6_new_flg := 'Y';
          if substr(i.fldedit,1,3) = 'DTE' and i.fldedit <> 'DTEGYEAR' then
            v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
          else
            obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
            if i.fldedit = 'CODEDLV' then
              obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODDGLV' then
              obj_data.put('desc_coddglv',get_tcodec_name('TCODDGEE',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODMAJSB' then
              obj_data.put('desc_codmajsb',get_tcodec_name('TCODMAJR',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODMINSB' then
              obj_data.put('desc_codminsb',get_tcodec_name('TCODSUBJ',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODINST' then
              obj_data.put('desc_codinst',get_tcodec_name('TCODINST',i.desnew,global_v_lang));
            elsif i.fldedit = 'CODCOUNT' then
              obj_data.put('desc_codcount',get_tcodec_name('TCODCNTY',i.desnew,global_v_lang));
            elsif i.fldedit = 'FLGEDUC' then
              obj_data.put('desc_flgeduc',get_tlistval_name('FLGEDUC',i.desnew,global_v_lang));
            end if;
          end if;

          if i.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
            end if;
            if i.fldedit = 'CODEDLV' then
                flg_status := 'Y';
                codedlv_flg := 'Y';
            end if;
            if i.fldedit = 'FLGEDUC' then
                flg_status := 'Y';
                flgeduc_flg := 'Y';
            end if;
            if i.fldedit = 'CODDGLV' then
                flg_status := 'Y';
                coddglv_flg := 'Y';
            end if;
            if i.fldedit = 'CODMAJSB' then
                flg_status := 'Y';
                codmajsb_flg := 'Y';
            end if;
            if i.fldedit = 'CODMINSB' then
                flg_status := 'Y';
                codminsb_flg := 'Y';
            end if;
            if i.fldedit = 'CODINST' then
                flg_status := 'Y';
                codinst_flg := 'Y';
            end if;
            if i.fldedit = 'CODCOUNT' then
                flg_status := 'Y';
                codcount_flg := 'Y';
            end if;
            if i.fldedit = 'NUMGPA' then
                flg_status := 'Y';
                numgpa_flg := 'Y';
            end if;
            if i.fldedit = 'STAYEAR' then
                flg_status := 'Y';
                stayear_flg := 'Y';
            end if;
            if i.fldedit = 'DTEGYEAR' then
                flg_status := 'Y';
                dtegyear_flg := 'Y';
            end if;
            obj_data.put('flg_status',flg_status);
            obj_data.put('numseq_flg',numseq_flg);
            obj_data.put('codedlv_flg',codedlv_flg);
            obj_data.put('flgeduc_flg',flgeduc_flg);
            obj_data.put('coddglv_flg',coddglv_flg);
            obj_data.put('codmajsb_flg',codmajsb_flg);
            obj_data.put('codminsb_flg',codminsb_flg);
            obj_data.put('codinst_flg',codinst_flg);
            obj_data.put('codcount_flg',codcount_flg);
            obj_data.put('numgpa_flg',numgpa_flg);
            obj_data.put('stayear_flg',stayear_flg);
            obj_data.put('dtegyear_flg',dtegyear_flg);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
          obj_data.put('status',i.status);
          obj_data.put('desc_status',tab6_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
        end loop;

--        if v_new_exist then
--          --add last row
--          obj_row.put('coderror', '200');
--          obj_row.put('desc_coderror', ' ');
--          obj_row.put('httpcode', ' ');
--          obj_row.put('flg', ' ');
--          obj_row.put('total',   v_rcnt);
--          obj_row.put('rcnt',    v_num);
--          obj_row.put('numseq',tab6_numseq);
--          obj_row.put('staappr',tab6_staappr);
--          obj_row.put('new_flg',tab6_new_flg);
--        end if;
      end if; --v_rcnt
    end if; --v_numappl
       json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_education;

  procedure get_work_exp(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_numseq            varchar2(100 char);
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB6';
    tab_work_exp_numappl           tapplwex.numappl%type;
    tab_work_exp_numseq            tapplwex.numseq%type;
    tab_work_exp_codempid          tapplwex.codempid%type;
    tab_work_exp_desnoffi          tapplwex.desnoffi%type;
    tab_work_exp_deslstjob1        tapplwex.deslstjob1%type;
    tab_work_exp_deslstpos         tapplwex.deslstpos%type;
    tab_work_exp_desoffi1          tapplwex.desoffi1%type;
    tab_work_exp_numteleo          tapplwex.numteleo%type;
    tab_work_exp_namboss           tapplwex.namboss%type;
    tab_work_exp_desres            tapplwex.desres%type;
    tab_work_exp_amtincom          tapplwex.amtincom%type;
    tab_work_exp_dtestart          tapplwex.dtestart%type;
    tab_work_exp_dteend            tapplwex.dteend%type;
    tab_work_exp_codtypwrk         tapplwex.codtypwrk%type;
    tab_work_exp_desjob            tapplwex.desjob%type;
    tab_work_exp_desrisk           tapplwex.desrisk%type;
    tab_work_exp_desprotc          tapplwex.desprotc%type;
    tab_work_exp_remark            tapplwex.remark%type;
    tab_work_exp_desc_codtypwrk    varchar2(4000 char);
    tab6_flgupdat                  varchar2(4000 char);
    tab6_dteinput                  varchar2(4000 char);
    tab6_dtecancel                 varchar2(4000 char);
    v_first                        boolean := true;
    v_new_exist                    boolean := false;
    tab6_new_flg                   varchar2(4000 char);
    flg_status                     varchar2(10 char) := 'N';
    numseq_flg                     varchar2(10 char) := 'N';
    desnoffi_flg                   varchar2(10 char) := 'N';
    deslstjob1_flg                 varchar2(10 char) := 'N';
    deslstpos_flg                  varchar2(10 char) := 'N';
    desjob_flg                     varchar2(10 char) := 'N';
    desrisk_flg                    varchar2(10 char) := 'N';
    desprotc_flg                   varchar2(10 char) := 'N';
    desoffi1_flg                   varchar2(10 char) := 'N';
    numteleo_flg                   varchar2(10 char) := 'N';
    namboss_flg                    varchar2(10 char) := 'N';
    desres_flg                     varchar2(10 char) := 'N';
    amtincom_flg                   varchar2(10 char) := 'N';
    dtestart_flg                   varchar2(10 char) := 'N';
    dteend_flg                     varchar2(10 char) := 'N';
    remark_flg                     varchar2(10 char) := 'N';



    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,desnoffi,deslstjob1,
             deslstpos,desoffi1,numteleo,namboss,desres,
             amtincom,dtestart,dteend,codtypwrk,desjob,
             desrisk,desprotc,remark,dteupd,coduser
        from tapplwex
       where numappl = v_numappl
      order by 1;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 32
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 32
         and seqno   not in (select numseq from tapplwex
                              where numappl = v_numappl)
      order by seqno;

  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
      into v_numappl,v_codcomp
      from   temploy1
      where  codempid = b_index_codempid  ;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c1 loop
        tab_work_exp_numappl           := i.numappl;
        tab_work_exp_numseq            := i.numseq;
        tab_work_exp_codempid          := i.codempid;
        tab_work_exp_desnoffi          := i.desnoffi;
        tab_work_exp_deslstjob1        := i.deslstjob1;
        tab_work_exp_deslstpos         := i.deslstpos;
        tab_work_exp_desoffi1          := i.desoffi1;
        tab_work_exp_numteleo          := i.numteleo;
        tab_work_exp_namboss           := i.namboss;
        tab_work_exp_desres            := i.desres;
        tab_work_exp_amtincom          := i.amtincom;
        tab_work_exp_dtestart          := i.dtestart;
        tab_work_exp_dteend            := i.dteend;
        tab_work_exp_codtypwrk         := i.codtypwrk;
        tab_work_exp_desjob            := i.desjob;
        tab_work_exp_desrisk           := i.desrisk;
        tab_work_exp_desprotc          := i.desprotc;
        tab_work_exp_remark            := i.remark;
        tab_work_exp_desc_codtypwrk    := get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang);
        tab6_staappr                   := 'P';
--        tab6_codcomp                   := v_codcomp;
--        tab6_codempid                  := b_index_codempid;
        tab6_flgupdat                  := 'N' ;
        tab6_status                    := 'N';
        tab6_desc_status               := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        v_numseq := i.numseq ;
        v_num := v_num + 1;
        -- add data
        tab6_new_flg := 'N';
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numappl',tab_work_exp_numappl);
        obj_data.put('numseq',tab_work_exp_numseq);
        obj_data.put('codempid',tab_work_exp_codempid);
        obj_data.put('desnoffi',tab_work_exp_desnoffi);
        obj_data.put('deslstjob1',tab_work_exp_deslstjob1);
        obj_data.put('deslstpos',tab_work_exp_deslstpos);
        obj_data.put('desoffi1',tab_work_exp_desoffi1);
        obj_data.put('numteleo',tab_work_exp_numteleo);
        obj_data.put('namboss',tab_work_exp_namboss);
        obj_data.put('desres',tab_work_exp_desres);
        obj_data.put('amtincom',tab_work_exp_amtincom);
        obj_data.put('dtestart',to_char(tab_work_exp_dtestart,'dd/mm/yyyy'));
        obj_data.put('dteend',to_char(tab_work_exp_dteend,'dd/mm/yyyy'));
        obj_data.put('codtypwrk',tab_work_exp_codtypwrk);
        obj_data.put('desjob',tab_work_exp_desjob);
        obj_data.put('desrisk',tab_work_exp_desrisk);
        obj_data.put('desprotc',tab_work_exp_desprotc);
        obj_data.put('remark',tab_work_exp_remark);
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_data.put('desc_codtypwrk',tab_work_exp_desc_codtypwrk);
        obj_data.put('flgupdat',tab6_flgupdat);
        obj_data.put('new_flg',tab6_new_flg);

        for j in c_temeslog2 loop
          if substr(j.fldedit,1,3) = 'DTE' and j.fldedit <> 'DTEGYEAR' then
            v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(j.fldedit),v_des); --user35 || 19/09/2017
          else
            obj_data.put(lower(j.fldedit),j.desnew);
            obj_data.put('desc_codtypwrk',get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang));
          end if;

           if j.fldedit = 'NUMSEQ' then
              flg_status := 'Y';
              numseq_flg := 'Y';
           end if;
           if j.fldedit = 'DESNOFFI' then
              flg_status := 'Y';
              desnoffi_flg := 'Y';
           end if;
           if j.fldedit = 'DESLSTJOB1' then
              flg_status := 'Y';
              deslstjob1_flg := 'Y';
           end if;
           if j.fldedit = 'DESLSTPOS' then
              flg_status := 'Y';
              deslstpos_flg := 'Y';
           end if;
           if j.fldedit = 'DESJOB' then
              flg_status := 'Y';
              desjob_flg := 'Y';
           end if;
           if j.fldedit = 'DESRISK' then
              flg_status := 'Y';
              desrisk_flg := 'Y';
           end if;
           if j.fldedit = 'DESPROTC' then
              flg_status := 'Y';
              desprotc_flg := 'Y';
           end if;
           if j.fldedit = 'DESOFFI1' then
              flg_status := 'Y';
              desoffi1_flg := 'Y';
           end if;
           if j.fldedit = 'NUMTELEO' then
              flg_status := 'Y';
              numteleo_flg := 'Y';
           end if;
           if j.fldedit = 'NAMBOSS' then
              flg_status := 'Y';
              namboss_flg := 'Y';
           end if;
           if j.fldedit = 'DESRES' then
              flg_status := 'Y';
              desres_flg := 'Y';
           end if;
           if j.fldedit = 'AMTINCOM' then
              flg_status := 'Y';
              amtincom_flg := 'Y';
           end if;
           if j.fldedit = 'DTESTART' then
              flg_status := 'Y';
              dtestart_flg := 'Y';
           end if;
           if j.fldedit = 'DTEEND' then
              flg_status := 'Y';
              dteend_flg := 'Y';
           end if;
           if j.fldedit = 'REMARK' then
              flg_status := 'Y';
              remark_flg := 'Y';
           end if;
           obj_data.put('flg_status',flg_status);
           obj_data.put('numseq_flg',numseq_flg);
           obj_data.put('desnoffi_flg',desnoffi_flg);
           obj_data.put('deslstjob1_flg',deslstjob1_flg);
           obj_data.put('deslstpos_flg',deslstpos_flg);
           obj_data.put('desjob_flg',desjob_flg);
           obj_data.put('desrisk_flg',desrisk_flg);
           obj_data.put('desprotc_flg',desprotc_flg);
           obj_data.put('desoffi1_flg',desoffi1_flg);
           obj_data.put('numteleo_flg',numteleo_flg);
           obj_data.put('namboss_flg',namboss_flg);
           obj_data.put('desres_flg',desres_flg);
           obj_data.put('amtincom_flg',amtincom_flg);
           obj_data.put('dtestart_flg',dtestart_flg);
           obj_data.put('dteend_flg',dteend_flg);
           obj_data.put('remark_flg',remark_flg);
          --<<user36 JAS590255 20/04/2016
          tab6_status      := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);
          -->>user36 JAS590255 20/04/2016
          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;

        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
      --
      for i in c2 loop
        --v_new_exist := true;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
          -- add row
          v_num := v_num +1;
          obj_data := json_object_t();

          obj_data.put('coderror', '200');
          obj_data.put('desc_coderror', ' ');
          obj_data.put('httpcode', ' ');
          obj_data.put('flg', ' ');
          -- display data
          obj_data.put('total',   v_rcnt);
          obj_data.put('rcnt',    v_num);
--            obj_data.put('numseq',tab6_numseq); weerayut 20/12/2017
          obj_data.put('numseq',i.seqno);
          obj_data.put('staappr',tab6_staappr);
          obj_data.put('flgupdat',tab6_flgupdat);
          obj_data.put('new_flg',tab6_new_flg);
        end if;
        --add data
        tab6_numseq := i.seqno;
        v_numseq    := i.seqno;
        tab6_status      := i.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' and i.fldedit <> 'DTEGYEAR' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des); --user35 || 19/09/2017
        else
          obj_data.put(lower(i.fldedit),i.desnew); --user35 || 19/09/2017
          obj_data.put('desc_codtypwrk',get_tcodec_name('TCODTYPWRK',tab_work_exp_codtypwrk,global_v_lang));
        end if;

          if i.fldedit = 'NUMSEQ' then
              flg_status := 'Y';
              numseq_flg := 'Y';
           end if;
           if i.fldedit = 'DESNOFFI' then
              flg_status := 'Y';
              desnoffi_flg := 'Y';
           end if;
           if i.fldedit = 'DESLSTJOB1' then
              flg_status := 'Y';
              deslstjob1_flg := 'Y';
           end if;
           if i.fldedit = 'DESLSTPOS' then
              flg_status := 'Y';
              deslstpos_flg := 'Y';
           end if;
           if i.fldedit = 'DESJOB' then
              flg_status := 'Y';
              desjob_flg := 'Y';
           end if;
           if i.fldedit = 'DESRISK' then
              flg_status := 'Y';
              desrisk_flg := 'Y';
           end if;
           if i.fldedit = 'DESPROTC' then
              flg_status := 'Y';
              desprotc_flg := 'Y';
           end if;
           if i.fldedit = 'DESOFFI1' then
              flg_status := 'Y';
              desoffi1_flg := 'Y';
           end if;
           if i.fldedit = 'NUMTELEO' then
              flg_status := 'Y';
              numteleo_flg := 'Y';
           end if;
           if i.fldedit = 'NAMBOSS' then
              flg_status := 'Y';
              namboss_flg := 'Y';
           end if;
           if i.fldedit = 'DESRES' then
              flg_status := 'Y';
              desres_flg := 'Y';
           end if;
           if i.fldedit = 'AMTINCOM' then
              flg_status := 'Y';
              amtincom_flg := 'Y';
           end if;
           if i.fldedit = 'DTESTART' then
              flg_status := 'Y';
              dtestart_flg := 'Y';
           end if;
           if i.fldedit = 'DTEEND' then
              flg_status := 'Y';
              dteend_flg := 'Y';
           end if;
           if i.fldedit = 'REMARK' then
              flg_status := 'Y';
              remark_flg := 'Y';
           end if;
           obj_data.put('flg_status',flg_status);
           obj_data.put('numseq_flg',numseq_flg);
           obj_data.put('desnoffi_flg',desnoffi_flg);
           obj_data.put('deslstjob1_flg',deslstjob1_flg);
           obj_data.put('deslstpos_flg',deslstpos_flg);
           obj_data.put('desjob_flg',desjob_flg);
           obj_data.put('desrisk_flg',desrisk_flg);
           obj_data.put('desprotc_flg',desprotc_flg);
           obj_data.put('desoffi1_flg',desoffi1_flg);
           obj_data.put('numteleo_flg',numteleo_flg);
           obj_data.put('namboss_flg',namboss_flg);
           obj_data.put('desres_flg',desres_flg);
           obj_data.put('amtincom_flg',amtincom_flg);
           obj_data.put('dtestart_flg',dtestart_flg);
           obj_data.put('dteend_flg',dteend_flg);
           obj_data.put('remark_flg',remark_flg);

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 3;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --v_numappl
       json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_work_exp;

  procedure get_childen(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL_TAB7';
    v_numappl           varchar2(4000 char);
    v_codcomp           varchar2(4000 char);
    v_numseq            varchar2(100 char);
    tab7_numseq         tchildrn.numseq%type;
    tab7_codtitle       tchildrn.codtitle%type;
    tab7_namfirst       tchildrn.namfirste%type;
    tab7_namfirste      tchildrn.namfirste%type;
    tab7_namfirstt      tchildrn.namfirstt%type;
    tab7_namfirst3      tchildrn.namfirst3%type;
    tab7_namfirst4      tchildrn.namfirst4%type;
    tab7_namfirst5      tchildrn.namfirst5%type;
    tab7_namlast        tchildrn.namlaste%type;
    tab7_namlaste       tchildrn.namlaste%type;
    tab7_namlastt       tchildrn.namlastt%type;
    tab7_namlast3       tchildrn.namlast3%type;
    tab7_namlast4       tchildrn.namlast4%type;
    tab7_namlast5       tchildrn.namlast5%type;
    tab7_namch          tchildrn.namche%type;
    tab7_namche         tchildrn.namche%type;
    tab7_namcht         tchildrn.namcht%type;
    tab7_namch3         tchildrn.namch3%type;
    tab7_namch4         tchildrn.namch4%type;
    tab7_namch5         tchildrn.namch5%type;
    tab7_numoffid       tchildrn.numoffid%type;
    tab7_dtechbd        tchildrn.dtechbd%type;
    tab7_codsex         tchildrn.codsex%type;
    tab7_codedlv        tchildrn.codedlv%type;
    tab7_stachld        tchildrn.stachld%type;
    tab7_stalife        tchildrn.stalife%type;
    tab7_dtedthch       tchildrn.dtedthch%type;
    tab7_flginc         tchildrn.flginc%type;
    tab7_flgedlv        tchildrn.flgedlv%type;
    tab7_flgdeduct      tchildrn.flgdeduct%type;
    tab7_stabf          tchildrn.stabf%type;
    tab7_filename       tchildrn.filename%type;
    tab7_desc_codtitle  varchar2(500 char);
    tab7_desc_codsex    varchar2(500 char);
    v_desflgedlv        varchar2(500 char);
    v_desflgded         varchar2(500 char);
    tab7_flgupdat       varchar2(4000 char);
    tab7_staappr        varchar2(4000 char);
    tab7_status         varchar2(4000 char);
    tab7_desc_status    varchar2(4000 char);
    tab7_new_flg        varchar2(4000 char);
    v_year              varchar2(4000 char);
    v_date              varchar2(4000 char);
    v_des               varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    v_label_edu_y       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,190);
    v_label_edu_n       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,200);
    v_label_ded_y       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,220);
    v_label_ded_n       varchar2(500) := get_label_name('HRES32EP4',global_v_lang,230);
    path_filename       varchar2(100 char);
    flg_status          varchar2(10 char) := 'N';
    numseq_flg          varchar2(10 char) := 'N';
    codtitle_flg        varchar2(10 char) := 'N';
    namfirst_flg        varchar2(10 char) := 'N';
    namlast_flg         varchar2(10 char) := 'N';
    numoffid_flg        varchar2(10 char) := 'N';
    dtechbd_flg         varchar2(10 char) := 'N';
    codsex_flg          varchar2(10 char) := 'N';
    codeduc_flg         varchar2(10 char) := 'N';
    stachld_flg         varchar2(10 char) := 'N';
    stalife_flg         varchar2(10 char) := 'N';
    flginc_flg          varchar2(10 char) := 'N';
    flgedlv_flg         varchar2(10 char) := 'N';
    flgdeduct_flg       varchar2(10 char) := 'N';
    stabf_flg           varchar2(10 char) := 'N';
    filename_flg        varchar2(10 char) := 'N';
    
    v_flg_name          boolean;
    --Cursor
    cursor c1 is
      select --numseq,dtechbd,namchild,codsex,codedlv,numoffid,flgedlv,flgdeduct
             numseq,codtitle,
             namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
             namlaste,namlastt,namlast3,namlast4,namlast5,
             namche,namcht,namch3,namch4,namch5,
             numoffid,dtechbd,codsex,codedlv,stachld,
             stalife,dtedthch,flginc,flgedlv,flgdeduct,
             stabf,filename,numrefdoc
        from tchildrn
       where codempid = b_index_codempid
      order by numseq  ;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 41
         and seqno    = v_numseq;

    cursor c_2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 41
         and seqno   not in (select numseq from tchildrn
                                          where codempid = b_index_codempid)
      order by seqno;
    ---
    begin
      initial_value(json_str_input);
      begin
        select count(*) into v_rcnt from(
          select numseq
            from tchildrn
       where codempid = b_index_codempid
        union
          select distinct(seqno)
            from temeslog2
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and numpage  = 41
             and seqno   not in (select numseq from tchildrn
                                              where codempid = b_index_codempid));
      end;
      --
    obj_row  := json_object_t();
    if v_rcnt > 0 then
      --
      for i in c1 loop
        tab7_numseq          := i.numseq;
        tab7_codtitle        := i.codtitle;
        tab7_namfirste       := i.namfirste;
        tab7_namfirstt       := i.namfirstt;
        tab7_namfirst3       := i.namfirst3;
        tab7_namfirst4       := i.namfirst4;
        tab7_namfirst5       := i.namfirst5;
        tab7_namlaste        := i.namlaste;
        tab7_namlastt        := i.namlastt;
        tab7_namlast3        := i.namlast3;
        tab7_namlast4        := i.namlast4;
        tab7_namlast5        := i.namlast5;
        tab7_namche          := i.namche;
        tab7_namcht          := i.namcht;
        tab7_namch3          := i.namch3;
        tab7_namch4          := i.namch4;
        tab7_namch5          := i.namch5;
        tab7_numoffid        := i.numoffid;
        tab7_dtechbd         := i.dtechbd;
        tab7_codsex          := i.codsex;
        tab7_codedlv         := i.codedlv;
        tab7_stachld         := i.stachld;
        tab7_stalife         := i.stalife;
        tab7_dtedthch        := i.dtedthch;
        tab7_flginc          := i.flginc;
        tab7_flgedlv         := i.flgedlv;
        tab7_flgdeduct       := i.flgdeduct;
        tab7_stabf           := i.stabf;
        tab7_filename        := i.filename;
        path_filename        := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||tab7_filename;


        tab7_desc_codtitle   := get_tlistval_name('CODTITLE',i.codtitle,global_v_lang);
        tab7_desc_codsex     := get_tlistval_name('NAMSEX',i.codsex,global_v_lang);

        if i.flgedlv = 'N' then
          v_desflgedlv  := v_label_edu_n;
        else
          v_desflgedlv  := v_label_edu_y;
        end if;
        if i.flgdeduct = 'N' then
          v_desflgded  := v_label_ded_y;
        else
          v_desflgded  := v_label_ded_y;
        end if;

        if global_v_lang = '101' then
          tab7_namfirst   := tab7_namfirste;
          tab7_namlast    := tab7_namlaste;
          tab7_namch      := tab7_namche;
        elsif global_v_lang = '102' then
          tab7_namfirst   := tab7_namfirstt;
          tab7_namlast    := tab7_namlastt;
          tab7_namch      := tab7_namcht;
        elsif global_v_lang = '103' then
          tab7_namfirst   := tab7_namfirst3;
          tab7_namlast    := tab7_namlast3;
          tab7_namch      := tab7_namch3;
        elsif global_v_lang = '104' then
          tab7_namfirst   := tab7_namfirst4;
          tab7_namlast    := tab7_namlast4;
          tab7_namch      := tab7_namch4;
        elsif global_v_lang = '105' then
          tab7_namfirst   := tab7_namfirst5;
          tab7_namlast    := tab7_namlast5;
          tab7_namch      := tab7_namch5;
        end if;

        tab7_status       := 'N';
        tab7_desc_status  := get_tlistval_name('STACHG',tab7_status,global_v_lang);
        v_numseq := i.numseq ;
        v_num := v_num + 1;
        -- add data
        tab7_new_flg := 'N';
        obj_data := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('numseq',tab7_numseq);
        obj_data.put('codtitle',tab7_codtitle);
        obj_data.put('namfirst',tab7_namfirst);
        obj_data.put('namfirste',tab7_namfirste);
        obj_data.put('namfirstt',tab7_namfirstt);
        obj_data.put('namfirst3',tab7_namfirst3);
        obj_data.put('namfirst4',tab7_namfirst4);
        obj_data.put('namfirst5',tab7_namfirst5);
        obj_data.put('namlast',tab7_namlast);
        obj_data.put('namlaste',tab7_namlaste);
        obj_data.put('namlastt',tab7_namlastt);
        obj_data.put('namlast3',tab7_namlast3);
        obj_data.put('namlast4',tab7_namlast4);
        obj_data.put('namlast5',tab7_namlast5);
        obj_data.put('namchild',tab7_namch);
        obj_data.put('namche',tab7_namche);
        obj_data.put('namcht',tab7_namcht);
        obj_data.put('namch3',tab7_namch3);
        obj_data.put('namch4',tab7_namch4);
        obj_data.put('namch5',tab7_namch5);
        obj_data.put('numoffid',tab7_numoffid);
        obj_data.put('dtechbd',to_char(tab7_dtechbd,'dd/mm/yyyy'));
        obj_data.put('codsex',tab7_codsex);
        obj_data.put('codedlv',tab7_codedlv);
        obj_data.put('stachld',tab7_stachld);
        obj_data.put('stalife',tab7_stalife);
        obj_data.put('dtedthch',to_char(tab7_dtedthch,'dd/mm/yyyy'));
        obj_data.put('flginc',tab7_flginc);
        obj_data.put('flgedlv',tab7_flgedlv);
        obj_data.put('flgdeduct',tab7_flgdeduct);
        obj_data.put('stabf',tab7_stabf);
        obj_data.put('filename',tab7_filename);
        obj_data.put('desc_codtitle',tab7_desc_codtitle);
        obj_data.put('desc_codsex',tab7_desc_codsex);
        obj_data.put('desc_flgedlv',v_desflgedlv);
        obj_data.put('desc_flgdeduct',v_desflgded);
        obj_data.put('flgupdat',tab7_flgupdat);
        obj_data.put('staappr',tab7_staappr);
        obj_data.put('new_flg',tab7_new_flg);
        obj_data.put('path_filename',path_filename);

        for j in c_temeslog2 loop
          if substr(j.fldedit,1,3) = 'DTE' then
            v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
            v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm') ;
            v_des  := v_date||'/'||v_year;
            obj_data.put(lower(j.fldedit),v_des);  --user35 || 19/09/2017
          else
            if lower(j.fldedit) = 'codsex' then
              obj_data.put('desc_codsex',get_tlistval_name('NAMSEX',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'codedlv' then
              obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'codtitle' then
              obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',j.desnew,global_v_lang));
            elsif lower(j.fldedit) = 'flgedlv' then
              v_desflgedlv  := '';
              if j.desnew = 'N' then
                v_desflgedlv  := v_label_edu_n;
              else
                v_desflgedlv  := v_label_edu_y;
              end if;
              obj_data.put('desc_flgedlv',v_desflgedlv);
            elsif lower(j.fldedit) = 'flgdeduct' then
              v_desflgded   := '';
              if j.desnew = 'N' then
                v_desflgded  := v_label_ded_n;
              else
                v_desflgded  := v_label_ded_y;
              end if;
              obj_data.put('desc_flgdeduct',v_desflgded);
            end if;
            if global_v_lang = '101' and j.fldedit = 'NAMCHE' then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '102' and j.fldedit = 'NAMCHT'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '103' and j.fldedit = 'NAMCH3'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '104' and j.fldedit = 'NAMCH4'  then
              obj_data.put('namchild',j.desnew);
            elsif global_v_lang = '105' and j.fldedit = 'NAMCH5'  then
              obj_data.put('namchild',j.desnew);
            end if;
            obj_data.put(lower(j.fldedit),j.desnew);
          end if;

          if j.fldedit = 'NUMSEQ' then
              flg_status := 'Y';
              numseq_flg := 'Y';
          end if;
          if j.fldedit = 'CODTITLE' then
              flg_status := 'Y';
              codtitle_flg := 'Y';
          end if;
          if j.fldedit in ('NAMFIRSTE','NAMFIRSTT','NAMFIRST3','NAMFIRST4','NAMFIRST5') then
              flg_status := 'Y';
              namfirst_flg := 'Y';
          end if;
          if j.fldedit in ('NAMLASTE','NAMLASTT','NAMLAST3','NAMLAST4','NAMLAST5') then
              flg_status := 'Y';
              namlast_flg := 'Y';
          end if;
          if j.fldedit = 'NUMOFFID' then
              flg_status := 'Y';
              numoffid_flg := 'Y';
          end if;
          if j.fldedit = 'DTECHBD' then
              flg_status := 'Y';
              dtechbd_flg := 'Y';
          end if;
          if j.fldedit = 'CODSEX' then
              flg_status := 'Y';
              codsex_flg := 'Y';
          end if;
          if j.fldedit = 'CODEDUC' then
              flg_status := 'Y';
              codeduc_flg := 'Y';
          end if;
          if j.fldedit = 'STACHLD' then
              flg_status := 'Y';
              stachld_flg := 'Y';
          end if;
          if j.fldedit = 'STALIFE' then
              flg_status := 'Y';
              stalife_flg := 'Y';
          end if;
          if j.fldedit = 'FLGINC' then
              flg_status := 'Y';
              flginc_flg := 'Y';
          end if;
          if j.fldedit = 'FLGEDLV' then
              flg_status := 'Y';
              flgedlv_flg := 'Y';
          end if;
          if j.fldedit = 'FLGDEDUCT' then
              flg_status := 'Y';
              flgdeduct_flg := 'Y';
          end if;
          if j.fldedit = 'STABF' then
              flg_status := 'Y';
              stabf_flg := 'Y';
          end if;
          if j.fldedit = 'FILENAME' then
              flg_status := 'Y';
              filename_flg := 'Y';
          end if;
          obj_data.put('flg_status',flg_status);
          obj_data.put('numseq_flg',numseq_flg);
          obj_data.put('codtitle_flg',codtitle_flg);
          obj_data.put('namfirst_flg',namfirst_flg);
          obj_data.put('namlast_flg',namlast_flg);
          obj_data.put('numoffid_flg',numoffid_flg);
          obj_data.put('dtechbd_flg',dtechbd_flg);
          obj_data.put('codsex_flg',codsex_flg);
          obj_data.put('codeduc_flg',codeduc_flg);
          obj_data.put('stachld_flg',stachld_flg);
          obj_data.put('stalife_flg',stalife_flg);
          obj_data.put('flginc_flg',flginc_flg);
          obj_data.put('flgedlv_flg',flgedlv_flg);
          obj_data.put('flgdeduct_flg',flgdeduct_flg);
          obj_data.put('stabf_flg',stabf_flg);
          obj_data.put('filename_flg',filename_flg);

          tab7_status      := j.status;
          tab7_desc_status := get_tlistval_name('STACHG',tab7_status,global_v_lang);

          begin
            select staappr into tab7_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 4;
          exception when no_data_found then
            tab7_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab7_status);
        obj_data.put('desc_status',tab7_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for i in c_2 loop
--        v_new_exist := true;
        tab7_numseq := i.seqno;
        
        ---------- set first name
        if global_v_lang = '101' and i.fldedit = 'NAMFIRSTE' then
            obj_data.put('namfirst',i.DESNEW);
        elsif global_v_lang = '102' and i.fldedit = 'NAMFIRSTT'  then
            obj_data.put('namfirst',i.DESNEW);
        elsif global_v_lang = '103' and i.fldedit = 'NAMFIRST3'  then
            obj_data.put('namfirst',i.DESNEW);
        elsif global_v_lang = '104' and i.fldedit = 'NAMFIRST4'  then
            obj_data.put('namfirst',i.DESNEW);
        elsif global_v_lang = '105' and i.fldedit = 'NAMFIRST5'  then
            obj_data.put('namfirst',i.DESNEW);
        end if;
        
        -------- set last name
        if global_v_lang = '101' and i.fldedit = 'NAMLASTE' then
            obj_data.put('namlast',i.DESNEW);
        elsif global_v_lang = '102' and i.fldedit = 'NAMLASTT'  then
            obj_data.put('namlast',i.DESNEW);
        elsif global_v_lang = '103' and i.fldedit = 'NAMLAST3'  then
            obj_data.put('namlast',i.DESNEW);
        elsif global_v_lang = '104' and i.fldedit = 'NAMLAST4'  then
            obj_data.put('namlast',i.DESNEW);
        elsif global_v_lang = '105' and i.fldedit = 'NAMLAST5'  then
            obj_data.put('namlast',i.DESNEW);
        end if;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab7_numseq);
            obj_data.put('flgupdat',tab7_flgupdat);
            obj_data.put('new_flg',tab7_new_flg);
        end if;
        --add data
        v_numseq := i.seqno;
        tab7_status      := i.status;
        tab7_desc_status := get_tlistval_name('STACHG',tab7_status,global_v_lang);

        tab7_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else
          if lower(i.fldedit) = 'codsex' then
            obj_data.put('desc_codsex',get_tlistval_name('NAMSEX',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'codedlv' then
            obj_data.put('desc_codedlv',get_tcodec_name('TCODEDUC',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'codtitle' then
            obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',i.desnew,global_v_lang));
          elsif lower(i.fldedit) = 'flgedlv' then
            v_desflgedlv  := '';
            if i.desnew = 'N' then
              v_desflgedlv  := v_label_edu_n;
            else
              v_desflgedlv  := v_label_edu_y;
            end if;
            obj_data.put('desc_flgedlv',v_desflgedlv);
          elsif lower(i.fldedit) = 'flgdeduct' then
            v_desflgded   := '';
            if i.desnew = 'N' then
              v_desflgded  := v_label_ded_n;
            else
              v_desflgded  := v_label_ded_y;
            end if;
            obj_data.put('desc_flgdeduct',v_desflgded);
          end if;

          if global_v_lang = '101' and i.fldedit = 'NAMCHE' then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '102' and i.fldedit = 'NAMCHT'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '103' and i.fldedit = 'NAMCH3'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '104' and i.fldedit = 'NAMCH4'  then
            obj_data.put('namchild',i.desnew);
          elsif global_v_lang = '105' and i.fldedit = 'NAMCH5'  then
            obj_data.put('namchild',i.desnew);
          end if;

          obj_data.put(lower(i.fldedit),i.desnew);
        end if;
          if i.fldedit = 'NUMSEQ' then
              flg_status := 'Y';
              numseq_flg := 'Y';
          end if;
          if i.fldedit = 'CODTITLE' then
              flg_status := 'Y';
              codtitle_flg := 'Y';
          end if;
          if i.fldedit in ('NAMFIRSTE','NAMFIRSTT','NAMFIRST3','NAMFIRST4','NAMFIRST5') then
              flg_status := 'Y';
              namfirst_flg := 'Y';
          end if;
          if i.fldedit in ('NAMLASTE','NAMLASTT','NAMLAST3','NAMLAST4','NAMLAST5') then
              flg_status := 'Y';
              namlast_flg := 'Y';
          end if;
          if i.fldedit = 'NUMOFFID' then
              flg_status := 'Y';
              numoffid_flg := 'Y';
          end if;
          if i.fldedit = 'DTECHBD' then
              flg_status := 'Y';
              dtechbd_flg := 'Y';
          end if;
          if i.fldedit = 'CODSEX' then
              flg_status := 'Y';
              codsex_flg := 'Y';
          end if;
          if i.fldedit = 'CODEDUC' then
              flg_status := 'Y';
              codeduc_flg := 'Y';
          end if;
          if i.fldedit = 'STACHLD' then
              flg_status := 'Y';
              stachld_flg := 'Y';
          end if;
          if i.fldedit = 'STALIFE' then
              flg_status := 'Y';
              stalife_flg := 'Y';
          end if;
          if i.fldedit = 'FLGINC' then
              flg_status := 'Y';
              flginc_flg := 'Y';
          end if;
          if i.fldedit = 'FLGEDLV' then
              flg_status := 'Y';
              flgedlv_flg := 'Y';
          end if;
          if i.fldedit = 'FLGDEDUCT' then
              flg_status := 'Y';
              flgdeduct_flg := 'Y';
          end if;
          if i.fldedit = 'STABF' then
              flg_status := 'Y';
              stabf_flg := 'Y';
          end if;
          if i.fldedit = 'FILENAME' then
              flg_status := 'Y';
              filename_flg := 'Y';
          end if;
          obj_data.put('flg_status',flg_status);
          obj_data.put('numseq_flg',numseq_flg);
          obj_data.put('codtitle_flg',codtitle_flg);
          obj_data.put('namfirst_flg',namfirst_flg);
          obj_data.put('namlast_flg',namlast_flg);
          obj_data.put('numoffid_flg',numoffid_flg);
          obj_data.put('dtechbd_flg',dtechbd_flg);
          obj_data.put('codsex_flg',codsex_flg);
          obj_data.put('codeduc_flg',codeduc_flg);
          obj_data.put('stachld_flg',stachld_flg);
          obj_data.put('stalife_flg',stalife_flg);
          obj_data.put('flginc_flg',flginc_flg);
          obj_data.put('flgedlv_flg',flgedlv_flg);
          obj_data.put('flgdeduct_flg',flgdeduct_flg);
          obj_data.put('stabf_flg',stabf_flg);
          obj_data.put('filename_flg',filename_flg);
        if i.fldedit = 'FILENAME' then
           path_filename := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||i.desnew;
           obj_data.put('path_filename',path_filename);
        end if;
        begin
          select staappr into tab7_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab7_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab7_desc_status);

          obj_row.put(to_char(v_num-1),obj_data);
      end loop;

    end if; -- v_rcnt
       json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_childen;

  procedure get_competency(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_codtency          tcmptncy.codtency%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB1';
    v_desc_typtency     tcomptnc.namtncye%type;
    v_numseq            number  := 0;
    tab6_flgupdat       varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);
    v_typtency          tcompskil.codtency%type;
    flg_status          varchar2(10 char) := 'N';
    --Cursor
    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 51
         and codseq   = v_codtency;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 51
         and codseq   not in (select  jd.codskill
                              from    temploy1 emp, tjobposskil jd, tcmptncy cpt
                              where   emp.codempid    = b_index_codempid
                              and     emp.codcomp     = jd.codcomp
                              and     emp.codpos      = jd.codpos
                              and     emp.numappl     = cpt.numappl(+)
                              and     jd.codskill     = cpt.codtency(+)
                              union all
                              select  cpt.codtency as codskill
                              from    temploy1 emp, tcmptncy cpt, tcompskil skl
                              where   emp.codempid    = b_index_codempid
                              and     emp.numappl     = cpt.numappl
                              and     cpt.codtency    = skl.codskill(+)
                              and     not exists (select  1
                                                  from    tjobposskil jd
                                                  where   jd.codpos     = emp.codpos
                                                  and     jd.codcomp    = emp.codcomp
                                                  and     jd.codskill   = cpt.codtency
                                                  and     jd.codtency   = skl.codtency))
      order by seqno;

    cursor c_tcmptncy is
      select  emp.numappl,jd.codtency as typtency,jd.codskill,cpt.grade,'JD' as typjd
      from    temploy1 emp, tjobposskil jd, tcmptncy cpt
      where   emp.codempid    = b_index_codempid
      and     emp.codcomp     = jd.codcomp
      and     emp.codpos      = jd.codpos
      and     emp.numappl     = cpt.numappl(+)
      and     jd.codskill     = cpt.codtency(+)
      union all
      select  emp.numappl,nvl(skl.codtency,'N/A') as typtency,cpt.codtency as codskill,cpt.grade,'NA' as typjd
      from    temploy1 emp, tcmptncy cpt, tcompskil skl
      where   emp.codempid    = b_index_codempid
      and     emp.numappl     = cpt.numappl
      and     cpt.codtency    = skl.codskill(+)
      and     not exists (select  1
                          from    tjobposskil jd
                          where   jd.codpos     = emp.codpos
                          and     jd.codcomp    = emp.codcomp
                          and     jd.codskill   = cpt.codtency
                          and     jd.codtency   = skl.codtency)
      order by typjd,typtency;
  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_tcmptncy loop
        v_num       := v_num + 1;
        obj_data    := json_object_t();

        obj_data.put('coderror','200');
        obj_data.put('numappl',i.numappl);
        obj_data.put('typtency',i.typtency);
        if i.typtency is null then
          v_desc_typtency   := null;
        elsif i.typtency = 'N/A' then
          v_desc_typtency   := i.typtency;
        else
          v_desc_typtency   := get_tcomptnc_name(i.typtency,global_v_lang);
        end if;
        obj_data.put('desc_typtency',v_desc_typtency);
        obj_data.put('codtency',i.codskill);
        obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
        obj_data.put('grade',i.grade);
        obj_data.put('typjd',i.typjd);
        --
        flg_status := 'N';
        v_codtency    := i.codskill;
        for j in c_temeslog2 loop
          if j.fldedit = 'CODTENCY' then
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',j.desnew,global_v_lang));
          else
            obj_data.put(lower(j.fldedit),j.desnew);
          end if;
          flg_status := 'Y';
          tab6_status      := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);
        obj_data.put('flg_status',flg_status);
        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for i in c2 loop
        tab6_status := i.seqno;
        if nvl(v_numseq,i.seqno) <> i.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            begin
              select  codtency
              into    v_typtency
              from    tcompskil
              where   codskill  = i.codseq
              and     rownum    = 1;
            exception when no_data_found then
              v_typtency  := 'N/A';
            end;
            obj_data.put('typtency',v_typtency);
            if v_typtency = 'N/A' then
              v_desc_typtency   := v_typtency;
            else
              v_desc_typtency   := get_tcomptnc_name(v_typtency,global_v_lang);
            end if;
            obj_data.put('desc_typtency',v_desc_typtency);
            obj_data.put('codtency',i.codseq);
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.codseq,global_v_lang));
            flg_status := 'Y';
            obj_data.put('flg_status',flg_status);
        end if;
        --add data
        v_numseq := i.seqno;
        tab6_status      := i.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if substr(i.fldedit,1,3) = 'DTE' then
          v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
          v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
          v_des  := v_date||'/'||v_year;
          obj_data.put(lower(i.fldedit),v_des);  --user35 || 19/09/2017
        else

          if i.fldedit = 'CODTENCY' then
            obj_data.put('desc_codtency',get_tcodec_name('TCODSKIL',i.desnew,global_v_lang));
          else
            obj_data.put(lower(i.fldedit),i.desnew);
          end if;
        end if;

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',i.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
        json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_competency;

  procedure get_lang_abi(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_codlang           tlangabi.codlang%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB1';
    v_numseq            number  := 0;
    tab6_flgupdat       varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);
    flg_status          varchar2(10 char) := 'N';
    --Cursor
    cursor c_tlangabi is
      select  numappl,codlang,codempid,
              flglist,flgspeak,flgread,flgwrite
      from    tlangabi
      where   numappl   = v_numappl
      order by codlang;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 52
--         and fldkey   = 'CODLANG'
         and codseq   = v_codlang;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 52
--         and fldkey   = 'CODLANG'
         and codseq   not in (select codlang from tlangabi
                              where numappl = v_numappl)
      order by seqno;
  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_tlangabi loop
        v_num       := v_num + 1;
        obj_data    := json_object_t();

        obj_data.put('coderror','200');
        obj_data.put('numappl',i.numappl);
        obj_data.put('codlang',i.codlang);
        obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',i.codlang,global_v_lang));
        obj_data.put('flglist',i.flglist);
        obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',i.flglist,global_v_lang));
        obj_data.put('flgspeak',i.flgspeak);
        obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',i.flgspeak,global_v_lang));
        obj_data.put('flgread',i.flgread);
        obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',i.flgread,global_v_lang));
        obj_data.put('flgwrite',i.flgwrite);
        obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',i.flgwrite,global_v_lang));
        --
        flg_status := 'N';
        v_codlang    := i.codlang;
        for j in c_temeslog2 loop
          if j.fldedit = 'CODLANG' then
            obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGLIST' then
            obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGSPEAK' then
            obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGREAD' then
            obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          elsif j.fldedit = 'FLGWRITE' then
            obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
          end if;
          obj_data.put(lower(j.fldedit),j.desnew);
          tab6_status      := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);
          flg_status := 'Y';
          obj_data.put('flg_status',flg_status);
          obj_data.put('desc_flgread',flg_status);
          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 3;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for j in c2 loop
        tab6_status := j.seqno;
        if nvl(v_numseq,j.seqno) <> j.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            obj_data.put('codlang',j.codseq);
            flg_status := 'Y';
            obj_data.put('flg_status',flg_status);
            obj_data.put('desc_flgread',flg_status);
        end if;
        --add data
        v_numseq := j.seqno;
        tab6_status      := j.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if j.fldedit = 'codlang' then
          obj_data.put('desc_codlang',get_tcodec_name('TCODLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGLIST' then
          obj_data.put('desc_flglist',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGSPEAK' then
          obj_data.put('desc_flgspeak',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGREAD' then
          obj_data.put('desc_flgread',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        elsif j.fldedit = 'FLGWRITE' then
          obj_data.put('desc_flgwrite',get_tlistval_name('FLGLANG',j.desnew,global_v_lang));
        end if;
        obj_data.put(lower(j.fldedit),j.desnew);
        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',j.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
        json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_lang_abi;

  procedure get_his_reward(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_num               number := 0;
    v_concat            varchar2(1 char);
    v_numappl           varchar2(100 char);
    v_codcomp           varchar2(100 char);
    v_dteinput          thisrewd.dteinput%type;
    v_date              varchar2(100 char);
    v_year              varchar2(100 char);
    v_des               varchar2(100 char);
    global_v_codapp     varchar2(4000 char) := 'HRES32E_DETAIL5_TAB3';
    v_numseq            number  := 0;
    tab6_flgupdat       varchar2(4000 char);
    tab6_dteinput       varchar2(4000 char);
    tab6_dtecancel      varchar2(4000 char);
    v_first             boolean := true;
    v_new_exist         boolean := false;
    tab6_new_flg        varchar2(4000 char);
    flg_status          varchar2(10 char) := 'N';
    dteinput_flg        varchar2(10 char) := 'N';
    typrewd_flg         varchar2(10 char) := 'N';
    numhmref_flg        varchar2(10 char) := 'N';
    desrewd1_flg        varchar2(10 char) := 'N';
    filename_flg        varchar2(10 char) := 'N';
    path_filename       varchar2(100 char);

    --Cursor
    cursor c_thisrewd is
      select  codempid,dteinput,typrewd,desrewd1,
              numhmref,dteupd,coduser,filename
      from    thisrewd
      where   codempid    = b_index_codempid
      order by dteinput;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 53
         and dteseq   = v_dteinput;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 53
         and dteseq   not in (select dteinput from thisrewd
                              where codempid = b_index_codempid)
      order by seqno;
  begin
  initial_value(json_str_input);
    obj_row  := json_object_t();
    begin
      select numappl,codcomp
        into v_numappl,v_codcomp
        from temploy1
       where codempid = b_index_codempid;
    exception when no_data_found then
      v_numappl  := null;
      v_codcomp  := null;
    end;

    if v_numappl is not null then
      for i in c_thisrewd loop
        v_num       := v_num + 1;
        path_filename       := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||i.filename;
        obj_data    := json_object_t();

        obj_data.put('coderror','200');
        obj_data.put('codempid',i.codempid);
        obj_data.put('dteinput',to_char(i.dteinput,'dd/mm/yyyy'));
        obj_data.put('typrewd',i.typrewd);
        obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',i.typrewd,global_v_lang));
        obj_data.put('desrewd1',i.desrewd1);
        obj_data.put('numhmref',i.numhmref);
        obj_data.put('filename',i.filename);
        obj_data.put('dteupd',to_char(i.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser',i.coduser);
        obj_data.put('path_filename',path_filename);
        --
        v_dteinput    := i.dteinput;
        for j in c_temeslog2 loop
          if j.fldedit = 'TYPREWD' then
            obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',j.desnew,global_v_lang));
          end if;
          obj_data.put(lower(j.fldedit),j.desnew);
          tab6_status      := j.status;
          tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

          if j.fldedit = 'DTEINPUT' then
            flg_status := 'Y';
            dteinput_flg := 'Y';
          end if;
          if j.fldedit = 'TYPREWD' then
            flg_status := 'Y';
            typrewd_flg := 'Y';
          end if;
          if j.fldedit = 'NUMHMREF' then
            flg_status := 'Y';
            numhmref_flg := 'Y';
          end if;
          if j.fldedit = 'DESREWD1' then
            flg_status := 'Y';
            desrewd1_flg := 'Y';
          end if;
          if j.fldedit = 'FILENAME' then
            flg_status := 'Y';
            filename_flg := 'Y';
          end if;
          obj_data.put('flg_status',flg_status);
          obj_data.put('dteinput_flg',dteinput_flg);
          obj_data.put('typrewd_flg',typrewd_flg);
          obj_data.put('numhmref_flg',numhmref_flg);
          obj_data.put('desrewd1_flg',desrewd1_flg);
          obj_data.put('filename_flg',filename_flg);

          begin
            select staappr into tab6_staappr
              from tempch
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and typchg   = 5;
          exception when no_data_found then
            tab6_staappr := 'P';
          end;
        end loop;
        obj_data.put('status',tab6_status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;

      for j in c2 loop
        tab6_status := j.seqno;
        if nvl(v_numseq,j.seqno) <> j.seqno or v_num = 0 then
            -- add row
            v_num := v_num +1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('flg', ' ');
            obj_data.put('httpcode', ' ');
            -- display data
            obj_data.put('rcnt',v_num);
            obj_data.put('numseq',tab6_status);
            obj_data.put('flgupdat',tab6_flgupdat);
            obj_data.put('new_flg',tab6_new_flg);
            obj_data.put('dteinput',to_char(j.dteseq,'dd/mm/yyyy'));

            flg_status := 'Y';
            obj_data.put('flg_status',flg_status);

        end if;
        --add data
        v_numseq := j.seqno;
        tab6_status      := j.status;
        tab6_desc_status := get_tlistval_name('STACHG',tab6_status,global_v_lang);

        tab6_new_flg := 'Y';
        if j.fldedit = 'TYPREWD' then
          obj_data.put('desc_typrewd',get_tcodec_name('TCODREWD',j.desnew,global_v_lang));
        end if;
        obj_data.put(lower(j.fldedit),j.desnew);

        begin
          select staappr into tab6_staappr
            from tempch
           where codempid = b_index_codempid
             and dtereq   = b_index_dtereq
             and numseq   = b_index_numseq
             and typchg   = 4;
        exception when no_data_found then
          tab6_staappr := 'P';
        end;
        obj_data.put('status',j.status);
        obj_data.put('desc_status',tab6_desc_status);

        obj_row.put(to_char(v_num-1),obj_data);
      end loop;
    end if; --if v_numappl
        json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_his_reward;

  procedure get_ttrainbf(json_str_input in clob, json_str_output out clob) is
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_rcnt                number := 0;
    v_num                 number := 0;
    v_concat              varchar2(1 char);
    global_v_codapp       varchar2(4000 char) := 'HRES32E_DETAIL_TAB10';
    v_numappl             varchar2(4000 char);
    v_codcomp             varchar2(4000 char);
    v_numseq              varchar2(100 char);
    v_year                varchar2(4000 char);
    v_date                varchar2(4000 char);
    v_des                 varchar2(4000 char);
    tab10_numseq          varchar2(4000 char);
    tab10_destrain        varchar2(4000 char);
    tab10_desc_destrain   varchar2(4000 char);
    tab10_dtetr           varchar2(4000 char);
    tab10_dtetrain        varchar2(4000 char);
    tab10_dtetren         varchar2(4000 char);
    tab10_desplace        varchar2(4000 char);
    tab10_desinstu        varchar2(4000 char);
    tab10_flgupdat        varchar2(4000 char);
    tab10_status          varchar2(4000 char);
    tab10_desc_status     varchar2(4000 char);
    tab10_staappr         varchar2(4000 char);
    tab10_filedoc         varchar2(4000 char);
    v_first               boolean := true;
    v_new_exist           boolean := false;
    path_filename         varchar2(400 char);
    flg_status            varchar2(10 char) := 'N';
    numseq_flg            varchar2(10 char) := 'N';
    destrain_flg          varchar2(10 char) := 'N';
    dtetrain_flg          varchar2(10 char) := 'N';
    desplace_flg          varchar2(10 char) := 'N';
    desinstu_flg          varchar2(10 char) := 'N';
    filedoc_flg           varchar2(10 char) := 'N';
    
    --Cursor
    cursor c1 is
      select numappl,numseq,codempid,destrain,dtetrain,
             dtetren,desplace,desinstu,filedoc
        from ttrainbf
       where numappl = v_numappl
      order by numseq ;

    cursor c_temeslog2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 61
         and seqno    = v_numseq;

    cursor c2 is
      select *
        from temeslog2
       where codempid = b_index_codempid
         and dtereq   = b_index_dtereq
         and numseq   = b_index_numseq
         and numpage  = 61
         and seqno   not in ( select numseq from ttrainbf
                                            where numappl = v_numappl)
      order by seqno;
    ---
    begin
    initial_value(json_str_input);
      begin
        select numappl,codcomp
        into v_numappl,v_codcomp
        from   temploy1
        where  codempid = b_index_codempid;
      exception when no_data_found then
        v_numappl  := null;
        v_codcomp  := null;
      end;
    obj_row := json_object_t();
      if v_numappl is not null then
        begin
          select count(*) into v_rcnt from(
            select numseq
              from ttrainbf
             where numappl = v_numappl
          union
            select distinct(seqno)
              from temeslog2
             where codempid = b_index_codempid
               and dtereq   = b_index_dtereq
               and numseq   = b_index_numseq
               and numpage  = 61
               and seqno   not in (select numseq
                                    from ttrainbf
                                    where numappl = v_numappl));
        end;

      if v_rcnt > 0 then
        --
          for i in c1 loop
            tab10_numseq   := i.numseq ;
            tab10_destrain := i.destrain;
            tab10_desc_destrain := replace(i.destrain,chr(10),' ');
            tab10_dtetr    := to_char(i.dtetrain,'dd/mm/yyyy')||' - '||to_char(i.dtetren,'dd/mm/yyyy');
            tab10_dtetrain := to_char(i.dtetrain,'dd/mm/yyyy');
            tab10_dtetren  := to_char(i.dtetren,'dd/mm/yyyy') ;
            tab10_desplace := i.desplace ;
            tab10_desinstu := i.desinstu  ;
            tab10_flgupdat := 'N' ;
            tab10_status := 'N' ;
            tab10_desc_status := get_tlistval_name('STACHG',tab10_status,global_v_lang);
            tab10_filedoc    := i.filedoc  ;
            path_filename := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||tab10_filedoc;
            v_numseq := i.numseq ;
            v_num := v_num + 1;
            -- add data
            obj_data := json_object_t();

            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('total',   v_rcnt);
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab10_numseq);
            obj_data.put('destrain',tab10_destrain);
            obj_data.put('desc_destrain',tab10_desc_destrain);
            obj_data.put('dtetr',tab10_dtetr);
            obj_data.put('dtetrain',tab10_dtetrain);
            obj_data.put('dtetren',tab10_dtetren);
            obj_data.put('desplace',tab10_desplace);
            obj_data.put('desinstu',tab10_desinstu);
            obj_data.put('flgupdat',tab10_flgupdat);
            --<<user36 JAS590255 21/04/2016
            obj_data.put('status',tab10_status);
            obj_data.put('desc_status',tab10_desc_status);
            obj_data.put('filedoc',tab10_filedoc);
            obj_data.put('path_filename',path_filename);
            -->>user36 JAS590255 21/04/2016

            for j in c_temeslog2 loop
              if substr(j.fldedit,1,3) = 'DTE' then
                v_year := to_number(to_char(to_date(j.desnew,'dd/mm/yyyy'),'yyyy'));
                v_date := to_char(to_date(j.desnew,'dd/mm/yyyy'),'dd/mm');
                v_des  := v_date||'/'||v_year;
                obj_data.put(lower(j.fldedit),j.desnew);
              else
                obj_data.put(lower(j.fldedit),j.desnew);
                obj_data.put('desc_destrain',replace(tab10_destrain,chr(10),' '));
                obj_data.put('dtetrain',tab10_dtetrain);
                obj_data.put('dtetren',tab10_dtetren);
              end if;

              if j.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
              end if;
              if j.fldedit = 'DESTRAIN' then
                flg_status := 'Y';
                destrain_flg := 'Y';
              end if;
              if j.fldedit = 'DTETRAIN' then
                flg_status := 'Y';
                dtetrain_flg := 'Y';
              end if;
              if j.fldedit = 'DESPLACE' then
                flg_status := 'Y';
                desplace_flg := 'Y';
              end if;
              if j.fldedit = 'DESINSTU' then
                flg_status := 'Y';
                desinstu_flg := 'Y';
              end if;
              if j.fldedit = 'FILEDOC' then
                flg_status := 'Y';
                filedoc_flg := 'Y';
              end if;
              obj_data.put('flg_status',flg_status);
              obj_data.put('numseq_flg',numseq_flg);
              obj_data.put('destrain_flg',destrain_flg);
              obj_data.put('dtetrain_flg',dtetrain_flg);
              obj_data.put('desplace_flg',desplace_flg);
              obj_data.put('desinstu_flg',desinstu_flg);
              obj_data.put('filedoc_flg',filedoc_flg);


              --<<user36 JAS590255 20/04/2016
              obj_data.put('status',j.status);
              obj_data.put('desc_status',get_tlistval_name('STACHG',j.status,global_v_lang));
              -->>user36 JAS590255 20/04/2016
            end loop;

            begin
              select staappr into tab10_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 6;
            exception when no_data_found then
                tab10_staappr := 'P';
            end;

            obj_row.put(to_char(v_num-1),obj_data);
          end loop;
          --
          v_numseq  := null;
          obj_data  := json_object_t();
          for i in c2 loop
            v_new_exist := true;
            if nvl(v_numseq,i.seqno) <> i.seqno then
              v_num := v_num + 1;
              obj_data.put('coderror', '200');
              obj_data.put('desc_coderror', ' ');
              obj_data.put('flg', ' ');
              obj_data.put('httpcode', ' ');
              -- display data
              obj_data.put('rcnt',    v_num);
              obj_data.put('numseq',tab10_numseq);
              obj_data.put('flgupdat',tab10_flgupdat);
              obj_data.put('status',tab10_status);
              obj_data.put('desc_status',tab10_desc_status);
              obj_row.put(to_char(v_num-1),obj_data);
              obj_data := json_object_t();
            end if;
            --add data
            tab10_numseq  := i.seqno;
            v_numseq      := i.seqno;
            tab10_status      := i.status;
            tab10_desc_status := get_tlistval_name('STACHG',tab10_status,global_v_lang);
            if substr(i.fldedit,1,3) = 'DTE' then
              v_year := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy'));
              v_date := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
              v_des  := v_date||'/'||v_year;
               obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
            else
              obj_data.put(lower(i.fldedit),i.desnew);  --user35 || 19/09/2017
            end if;

            if i.fldedit = 'NUMSEQ' then
                flg_status := 'Y';
                numseq_flg := 'Y';
              end if;
              if i.fldedit = 'DESTRAIN' then
                flg_status := 'Y';
                destrain_flg := 'Y';
              end if;
              if i.fldedit = 'DTETRAIN' then
                flg_status := 'Y';
                dtetrain_flg := 'Y';
              end if;
              if i.fldedit = 'DESPLACE' then
                flg_status := 'Y';
                desplace_flg := 'Y';
              end if;
              if i.fldedit = 'DESINSTU' then
                flg_status := 'Y';
                desinstu_flg := 'Y';
              end if;
              if i.fldedit = 'FILEDOC' then
                flg_status := 'Y';
                filedoc_flg := 'Y';
                obj_data.put('filedoc',i.desnew);
                path_filename := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||i.desnew;
                obj_data.put('path_filename',path_filename);
              end if;
              obj_data.put('flg_status',flg_status);
              obj_data.put('numseq_flg',numseq_flg);
              obj_data.put('destrain_flg',destrain_flg);
              obj_data.put('dtetrain_flg',dtetrain_flg);
              obj_data.put('desplace_flg',desplace_flg);
              obj_data.put('desinstu_flg',desinstu_flg);
              obj_data.put('filedoc_flg',filedoc_flg);


            begin
              select staappr into tab10_staappr
                from tempch
               where codempid = b_index_codempid
                 and dtereq   = b_index_dtereq
                 and numseq   = b_index_numseq
                 and typchg   = 6;
            exception when no_data_found then
                tab10_staappr := 'P';
            end;
          end loop;

          if v_new_exist then
            --add last row
            v_num := v_num + 1;
            obj_data.put('coderror', '200');
            obj_data.put('desc_coderror', ' ');
            obj_data.put('httpcode', ' ');
            obj_data.put('flg', ' ');
            -- display data
            obj_data.put('rcnt',    v_num);
            obj_data.put('numseq',tab10_numseq);
            obj_data.put('flgupdat',tab10_flgupdat);
            obj_data.put('status',tab10_status);
            obj_data.put('desc_status',tab10_desc_status);
            obj_row.put(to_char(v_num-1),obj_data);
          end if;

      end if; --v_rcnt
    end if;
        json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end get_ttrainbf;
  --
  procedure approve(p_coduser         in varchar2,
                    p_lang            in varchar2,
                    p_total           in varchar2,
                    p_status          in varchar2,
                    p_remark_appr     in varchar2,
                    p_remark_not_appr in varchar2,
                    p_dteappr         in varchar2,
                    p_appseq          in number,
                    p_chk             in varchar2,
                    p_codempid        in varchar2,
                    p_numseq          in number,
                    p_dtereq          in varchar2,
                    p_typ             in number) is

    --  Request
    v_codapp    varchar2(10 char)   := 'HRES32E';
    rq_codempid varchar2(10 char);
    rq_dtereq   date ;
    rq_numseq   number := 0;
    rq_typ      number ;
    rq_approvno number ;
    rq_chk      varchar2(10 char);
    v_approvno  number := null;
    ap_approvno number := null;
    v_count     number := 0;
    v_staappr   varchar2(1 char);
    p_codappr   varchar2(10 char) := pdk.check_codempid(p_coduser);
    v_codeappr  varchar2(10 char);
    v_approv    varchar2(10 char);
    v_desc      varchar2(2000 char) := get_label_name('HRESZXEC2',p_lang,80)||' '||get_label_name('HRESZXEC2',p_lang,110);-- user22 : 04/07/2016 : STA3590287 || v_desc      varchar2(2000 char);
    v_appseq    number;

    v_tempch    tempch%rowtype;
    v_tnamech   tempch%rowtype;
    v_teductch  tempch%rowtype;
    v_tchildch  tempch%rowtype;
    v_trewdreq  tempch%rowtype;
    v_ttrainch  tempch%rowtype;
    v_numappl   varchar2(20 char) ;
    edu         number ;
    v_numseqbf  number ;
    k           number := 0 ;
    v_child     number := 0 ;
    offid       varchar2(103 char);
    pos         varchar2(40 char);
    job         varchar2(40 char);
    num         number;
    v_remark    varchar2(4000 char);

    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(40 char);
    v_routeno    varchar2(150 char);
    v_numseq     number := 0;
    v_dteinput   date;

    v_years     number;
    v_dates     varchar2(500 char) ;
    v_dess      varchar2(500 char) ;
    v_codcomp   tcenter.codcomp%type;
    v_stmt      varchar2(500 char);
    v_found     number;
    v_fldedit   varchar2(500 char);
    v_num       number := 0;

    v_dtechbd   varchar2(500 char) ;
    v_dtetrain  varchar2(500 char) ;
    v_dtetren   varchar2(500 char) ;
    v_dtedthch   varchar2(500 char) ;

    v_dterecv   varchar2(500 char) ;
    v_dtedocen  varchar2(500 char) ;
    v_return    varchar2(1 char) ;
    v_pathdoces varchar2(5000 char) := get_tsetup_value('PATHDOCES');
    v_filemove  varchar2(5000 char):= null;

    v_typrewd        varchar2(40 char);
    v_desrewd1       varchar2(150 char);
    v_numhmref       varchar2(160 char);
    v_filename       varchar2(160 char);
    v_folder         varchar2(650 char);

    v_numseqdoc      number := 0;
    v_countedu       number := 0;
    v_countchl       number := 0;
    v_counttrn       number := 0;
    v_countdoc       number := 0;
    v_countrel       number := 0;
    v_max_approv     number;
    v_countapplwex   number := 0;
    v_countcmptncy   number := 0;
    v_countlangabi   number := 0;
    v_counthisrewd   number := 0;

    v_dtestart       varchar2(500 char) ;
    v_dteend         varchar2(500 char) ;
    v_codseq         varchar2(150 char);
    v_row_id         varchar2(200 char);
    
    v_chk_empoth     varchar2(1 char)   := 'N';
    v_stmt_upd       varchar2(4000 char)   := ' ';
    v_col_insert     varchar2(4000 char)   := ' ';
    v_val_insert     varchar2(4000 char)   := ' ';
    
    type v_data is table of varchar2(250 char) index by binary_integer;
        v_arrnumseq         v_data;
        v_arrcodedlv        v_data;
        v_arrcoddglv        v_data;
        v_arrcodminsb       v_data;
        v_arrnumgpa         v_data;
        v_arrdtegyear       v_data;
        v_arrcodcount       v_data;
        v_arrcodinst        v_data;
        v_arrcodmajsb       v_data;
        v_arrflgeduc        v_data;
        v_arrstayear        v_data;

        v_arrnamfirste       v_data;
        v_arrnamfirstt       v_data;
        v_arrnamfirst3       v_data;
        v_arrnamfirst4       v_data;
        v_arrnamfirst5       v_data;
        v_arrnamlaste        v_data;
        v_arrnamlastt        v_data;
        v_arrnamlast3        v_data;
        v_arrnamlast4        v_data;
        v_arrnamlast5        v_data;
        v_arrnamche          v_data;
        v_arrnamcht          v_data;
        v_arrnamch3          v_data;
        v_arrnamch4          v_data;
        v_arrnamch5          v_data;
        v_arrdtechbd        v_data;
        v_arrcodsex         v_data;
        v_arrnumoffid       v_data;
        v_arrflgedlv        v_data;
        v_arrflgdeduct      v_data;
        v_arrstachld        v_data;
        v_arrstalife        v_data;
        v_arrdtedthch       v_data;
        v_arrflginc         v_data;
        v_arrstabf          v_data;
        v_arrfilename       v_data;
        v_arrcodtitle       v_data;


        v_arrdestrain       v_data;
        v_arrdtetrain       v_data;
        v_arrdtetren        v_data;
        v_arrdesplace       v_data;
        v_arrdesinstu       v_data;


        v_arrtypdoc         v_data;
        v_arrnamdoc         v_data;
        v_arrdterecv        v_data;
        v_arrdtedocen       v_data;
        v_arrnumdoc         v_data;
        v_arrfiledoc        v_data;
        v_arrdesnote        v_data;
        v_arrflgresume      v_data;

        v_arrcodemprl       v_data;
        v_arrnamrele        v_data;
        v_arrnamrelt        v_data;
        v_arrnamrel3        v_data;
        v_arrnamrel4        v_data;
        v_arrnamrel5        v_data;
        v_arrnumtelec       v_data;
        v_arradrcomt        v_data;

        v_arrdesnoffi       v_data;
        v_arrdeslstjob1     v_data;
        v_arrdeslstpos      v_data;
        v_arrdesoffi1       v_data;
        v_arrnumteleo       v_data;
        v_arrnamboss        v_data;
        v_arrdesres         v_data;
        v_arramtincom       v_data;
        v_arrdtestart       v_data;
        v_arrdteend         v_data;
        v_arrdesjob         v_data;
        v_arrdesrisk        v_data;
        v_arrdesprotc       v_data;
        v_arrremark         v_data;

        v_arrgrade          v_data;
        v_arrcodtency       v_data;
        v_arrflglist          v_data;
        v_arrflgspeak          v_data;
        v_arrflgread          v_data;
        v_arrflgwrite          v_data;
        v_arrcodlang          v_data;

        v_arrdteinput        v_data;
        v_arrtyprewd        v_data;
        v_arrdesrewd1        v_data;
        v_arrnumhmref        v_data;

    cursor c_trewdreq is
        select codempid,dtereq
          from tempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typchg   = '5';

    cursor c_temploy2 is
        select a.*,a.rowid,b.email,b.stamarry,b.stamilit,b.lineid,b.nummobile,b.dteretire,
               b.typtrav,b.carlicen,b.typfuel,b.qtylength,b.codbusno,b.codbusrt
          from temploy2 a,temploy1 b
         where a.codempid = rq_codempid
           and a.codempid = b.codempid;

    cursor c_tspouse is
        select a.*,a.rowid
          from tspouse a
         where a.codempid = rq_codempid;

    cursor c_tfamily is
        select a.*,a.rowid
          from tfamily a
         where a.codempid = rq_codempid;

    cursor c_temeslog1 is
        select fldedit,desnew
          from temeslog1
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  like '2%';

   cursor c_tappldoc is
        select numappl,numseq,codempid,typdoc,namdoc,dterecv,dtedocen,filedoc,numdoc,desnote,flgresume,rowid
          from tappldoc
         where numappl  = v_numappl
           and numseq   = v_numseq;

    cursor c_doclog1 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '29';

    cursor c_doclog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '29'
           and seqno    not in (select numseq from tappldoc
                                             where numappl = v_numappl)
        order by seqno;

    cursor c_teducatn is
        select a.*,a.rowid
          from teducatn a
         where numappl  = v_numappl
          and  a.numseq   = v_numseq;

    cursor c_edulog1 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '31';

    cursor c_edulog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '31'
           and seqno    not in (select numseq from teducatn
                                             where numappl = v_numappl)
        order by seqno;

    cursor c_tapplwex is
        select a.*,a.rowid
          from tapplwex a
         where a.codempid = rq_codempid
          and  a.numseq   = v_numseq;

    cursor c_applwexlog1 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '32';

    cursor c_applwexlog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '32'
           and seqno    not in (select numseq from teducatn
                                             where numappl = v_numappl)
        order by seqno;

    cursor c_tchildrn is
        select a.*,a.rowid
          from tchildrn a
         where a.codempid = rq_codempid
           and a.numseq   = v_numseq;

    cursor c_chillog1 is
        SELECT *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '41';

    cursor c_chillog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '41'
           and seqno    not in (select numseq from tchildrn
                                             where codempid = rq_codempid)
        order by seqno;

    cursor c_trelatives is
        select a.*,a.rowid
          from trelatives a
         where a.codempid = rq_codempid
           and a.numseq   = v_numseq;

    cursor c_relativeslog1 is
        SELECT *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '26';

      cursor c_relativeslog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '26'
           and seqno    not in (select numseq from trelatives
                                             where codempid = rq_codempid)
        order by seqno;

    cursor c_thisrewd is
        select a.*,a.rowid
          from thisrewd a
         where a.codempid = rq_codempid
           and a.dteinput = v_dteinput;

    cursor c_hisrewdlog1 is
        SELECT *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '53';

    cursor c_hisrewdlog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '53'
           and seqno    not in (select numseq from thisrewd
                                             where codempid = rq_codempid
                                             and dteinput=dteseq)
        order by seqno;

    cursor c_tcmptncy is
        select a.*,a.rowid
          from tcmptncy a
         where numappl  = v_numappl
            and codtency = v_codseq;
    cursor c_cmptncylog1 is
        SELECT *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '51';

    cursor c_cmptncylog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '51'
           and seqno    not in (select numseq from tcmptncy
                                             where numappl = v_numappl
                                             and codtency =  codseq)
        order by seqno;

    cursor c_tlangabi is
        select a.*,a.rowid
          from tlangabi a
         where numappl  = v_numappl
            and codlang = v_codseq;

     cursor c_langabilog1 is
        SELECT *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '52';

    cursor c_langabilog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '52'
           and seqno    not in (select numseq from tlangabi
                                             where numappl = v_numappl
                                             and codlang =  codseq)
        order by seqno;
    cursor c_ttrainbf is
        select a.*,a.rowid
          from ttrainbf a
         where a.codempid = rq_codempid
          and  a.numseq   = v_numseq;

    cursor c_trnlog1 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '61';

    cursor c_trnlog2 is
        select *
          from temeslog2
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '61'
           and seqno    not in (select numseq from ttrainbf
                                             where numappl = v_numappl)
        order by seqno;

    cursor c_spouslog is
        select fldedit,desnew
          from temeslog1
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '24'
           and fldedit in ('NAMFIRSTE','NAMFIRSTT','NAMFIRST3','NAMFIRST4','NAMFIRST5','NAMLASTE','NAMLASTT',
                           'NAMLAST3','NAMLAST4','NAMLAST5','NAMSPE','NAMSPT','NAMSP3','NAMSP4','NAMSP5',
                           'NUMSPID','CODSPOCC','DESNOFFI','CODSPPRO','CODSPCTY','DESPLREG','DESNOTE','DTESPBD','DTEMARRY');

    cursor c_familylog is
        select fldedit,desnew
          from temeslog1
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '25'
           and fldedit in  ('NAMFSTFE','NAMFSTFT','NAMFSTF3','NAMFSTF4','NAMFSTF5','NAMLSTFE','NAMLSTFT',
                            'NAMLSTF3','NAMLSTF4','NAMLSTF5','NAMFATHE','NAMFATHT','NAMFATH3','NAMFATH4','NAMFATH5',
                            'NAMFSTME','NAMFSTMT','NAMFSTM3','NAMFSTM4','NAMFSTM5','NAMLSTME','NAMLSTMT','NAMLSTM3',
                            'NAMLSTM4','NAMLSTM5','NAMMOTHE','NAMMOTHT','NAMMOTH3','NAMMOTH4','NAMMOTH5','NAMFSTCE',
                            'NAMFSTCT','NAMFSTC3','NAMFSTC4','NAMFSTC5','NAMLSTCE','NAMLSTCT','NAMLSTC3','NAMLSTC4',
                            'NAMLSTC5','NAMCONTE','NAMCONTT','NAMCONT3','NAMCONT4','NAMCONT5','CODFNATN','CODFRELG',
                            'CODFOCCU','NUMOFIDF','CODMNATN','CODMRELG','CODMOCCU','NUMOFIDM','ADRCONT1','CODPOST',
                            'NUMTELE','NUMFAX','EMAIL','DESRELAT') ;
    cursor c_temeslog1_2 is
        select fldedit,desnew
          from temeslog1
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and numpage  = '41';


   cursor c_temploy3 is
        select *
          from temploy3
         where codempid = rq_codempid ;
         
    cursor c_empothlog1 is
      select fldedit,desold,desnew,itemtype
        from temeslog1 elog, tempothd othc 
       where elog.fldedit   = othc.column_name
         and codempid       = rq_codempid
         and dtereq         = rq_dtereq
         and numseq         = rq_numseq
         and numpage        = '71';

  begin
    v_staappr := p_status;
    v_zyear   := pdk.check_year(p_lang);
    if v_staappr = 'A' then
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
    --
    v_appseq := p_appseq;
    rq_chk   := p_chk;
    rq_codempid   := p_codempid;
    rq_typ        := p_typ;
    rq_numseq     := p_numseq;

    k             := 0 ;
    rq_dtereq     := to_date(p_dtereq,'dd/mm/yyyy');

    begin
        select codcomp,numappl into v_codcomp,v_numappl
          from temploy1
         where codempid = rq_codempid;
    exception when no_data_found then
        null;
    end;

    if rq_typ = 1 then -- name  change
        begin
           select *
             into v_tnamech
             from tempch
            where codempid = rq_codempid
              and dtereq   = rq_dtereq
              and numseq   = rq_numseq
              and typchg   = rq_typ;
        exception when others then
            v_tnamech :=  null;
        end;
        begin
            select approvno into v_max_approv
            from   twkflowh
            where  routeno = v_tnamech.routeno ;
        exception when no_data_found then
            v_max_approv := 0 ;
        end ;
        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select  count(*)   into  v_count
          from  tapempch
         where  codempid = rq_codempid
           and  dtereq   = rq_dtereq
           and  numseq   = rq_numseq
           and  typreq   = 'HRES32E1'
           and  approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E1',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E1'
                   and approvno = ap_approvno;
        end if;

        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;


        chk_workflow.find_next_approve(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 || ,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
              v_approv := chk_workflow.check_next_step2(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E1',null,v_approvno,p_codappr);
              --v_approv := chk_workflow.chk_nextstep(v_codapp,v_tnamech.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
              --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E1'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E1',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate

                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E1'
                            and approvno = v_approvno;
                    end if;
                   --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                   chk_workflow.find_next_approve(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_tnamech.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;
        end if;
        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
           rq_chk := 'E' ;
        end if;
        v_staappr := p_status;
        if rq_chk = 'E' and p_status = 'A' then
           v_staappr := 'Y';
        end if;

        update tempch set staappr   = v_staappr,
                          codappr   = v_codeappr,
                          approvno  = v_approvno,
                          dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                          remarkap  = v_remark ,
                          dteapph   = sysdate,
                          coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

        if v_staappr = 'Y' then
          update_temploy1(p_coduser,rq_codempid,rq_dtereq,rq_numseq,p_lang,v_tnamech.desnote);
        end if;

    elsif rq_typ = 2 then -- personal data

        begin
            select *
              into v_tempch
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
            v_tempch :=  null;
        end;
        begin
          select approvno into v_max_approv
          from   twkflowh
          where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;
        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select count(*)   into  v_count
          from tapempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typreq   = 'HRES32E2'
           and approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E2',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E2'
                   and approvno = ap_approvno;
        end if;

        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 ||
                v_approv := chk_workflow.check_next_step2(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E2',null,v_approvno,p_codappr);
                --v_approv := chk_workflow.chk_nextstep(v_codapp,v_tempch.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
                --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E2'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E2',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate
                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E2'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;

                --chk_workflow.find_next_approve(v_codapp,v_tempch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

             end loop ;
        end if;

        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
           rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then

           v_staappr := 'Y';
            --- address
            for i in c_temeslog1 loop
                for j in c_temploy2 loop
                    if i.fldedit = 'ADRREGE' then
                        upd_log1(rq_codempid,'temploy2','12','adrrege','C',j.adrrege,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRREGT' then
                        upd_log1(rq_codempid,'temploy2','12','adrregt','C',j.adrregt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRREG3' then
                        upd_log1(rq_codempid,'temploy2','12','adrreg3','C',j.adrreg3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRREG4' then
                        upd_log1(rq_codempid,'temploy2','12','adrreg4','C',j.adrreg4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRREG5' then
                        upd_log1(rq_codempid,'temploy2','12','adrreg5','C',j.adrreg5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODDISTR' then
                        upd_log1(rq_codempid,'temploy2','12','coddistr','C',j.coddistr,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPROVR' then
                        upd_log1(rq_codempid,'temploy2','12','codprovr','C',j.codprovr,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODCNTYR' then
                        upd_log1(rq_codempid,'temploy2','12','codcntyr','C',j.codcntyr,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPOSTR' then
                        upd_log1(rq_codempid,'temploy2','12','codpostr','N',j.codpostr,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONTE' then
                        upd_log1(rq_codempid,'temploy2','12','adrconte','C',j.adrconte,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONTT' then
                        upd_log1(rq_codempid,'temploy2','12','adrcontt','C',j.adrcontt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONT3' then
                        upd_log1(rq_codempid,'temploy2','12','adrcont3','C',j.adrcont3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONT4' then
                        upd_log1(rq_codempid,'temploy2','12','adrcont4','C',j.adrcont4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONT5' then
                        upd_log1(rq_codempid,'temploy2','12','adrcont5','C',j.adrcont5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODSUBDISTR' then
                        upd_log1(rq_codempid,'temploy2','12','codsubdistr','C',j.codsubdistr,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODSUBDISTC' then
                        upd_log1(rq_codempid,'temploy2','12','codsubdistc','C',j.codsubdistc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODDISTC' then
                        upd_log1(rq_codempid,'temploy2','12','coddistc','C',j.coddistc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPROVC' then
                        upd_log1(rq_codempid,'temploy2','12','codprovc','C',j.codprovc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODCNTYC' then
                        upd_log1(rq_codempid,'temploy2','12','codcntyc','C',j.codcntyc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPOSTC' then
                        upd_log1(rq_codempid,'temploy2','12','codpostc','N',j.codpostc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMTELEC' then
                        upd_log1(rq_codempid,'temploy2','11','numtelec','C',j.numtelec,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMPASID' then
                        upd_log1(rq_codempid,'temploy2','11','numpasid','C',j.numpasid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEPASID' then
                        upd_log1(rq_codempid,'temploy2','11','dtepasid','D',to_char(j.dtepasid,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMOFFID' then
                        upd_log1(rq_codempid,'temploy2','11','numoffid','C',j.numoffid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRISSUE' then
                        upd_log1(rq_codempid,'temploy2','11','adrissue','C',j.adrissue,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPROVI' then
                        upd_log1(rq_codempid,'temploy2','11','codprovi','C',j.codprovi,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEOFFID' then
                        upd_log1(rq_codempid,'temploy2','11','dteoffid','D',to_char(j.dteoffid,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMLICID' then
                        upd_log1(rq_codempid,'temploy2','11','numlicid','C',j.numlicid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTELICID' then
                        upd_log1(rq_codempid,'temploy2','11','dtelicid','D',to_char(j.dtelicid,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STAMILIT' then
                        upd_log1(rq_codempid,'temploy1','11','stamilit','C',j.stamilit,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STAMARRY' then
                        upd_log1(rq_codempid,'temploy1','11','stamarry','C',j.stamarry,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMPRMID' then
                        upd_log1(rq_codempid,'temploy2','11','numprmid','C',j.numprmid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEPRMST' then
                        upd_log1(rq_codempid,'temploy2','11','dteprmst','D',to_char(j.dteprmst,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEPRMEN' then
                        upd_log1(rq_codempid,'temploy2','11','dteprmen','D',to_char(j.dteprmen,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'LINEID' then
                        upd_log1(rq_codempid,'temploy1','11','lineid','C',j.lineid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMMOBILE' then
                        upd_log1(rq_codempid,'temploy1','11','nummobile','C',j.nummobile,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODCLNSC' then
                        upd_log1(rq_codempid,'temploy2','11','codclnsc','C',j.codclnsc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMVISA' then
                        upd_log1(rq_codempid,'temploy2','11','numvisa','C',j.codclnsc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEVISAEXP' then
                        upd_log1(rq_codempid,'temploy2','11','dtevisaexp','C',to_char(j.dtevisaexp,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTERETIRE' then
                        upd_log1(rq_codempid,'temploy1','11','dteretire','C',j.dteretire,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'EMAIL_EMP' then
                        upd_log1(rq_codempid,'temploy1','11','email','C',j.email,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'TYPTRAV' then
                        upd_log1(rq_codempid,'temploy1','14','typtrav','C',j.typtrav,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CARLICEN' then
                        upd_log1(rq_codempid,'temploy1','14','carlicen','C',j.carlicen,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'TYPFUEL' then
                        upd_log1(rq_codempid,'temploy1','14','typfuel','C',j.typfuel,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'QTYLENGTH' then
                        upd_log1(rq_codempid,'temploy1','14','qtylength','C',j.qtylength,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODBUSNO' then
                        upd_log1(rq_codempid,'temploy1','14','codbusno','C',j.codbusno,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODBUSRT' then
                        upd_log1(rq_codempid,'temploy1','14','codbusrt','C',j.codbusrt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;
                    v_fldedit := substr(i.fldedit,1,length(i.fldedit) - 1);
                    if i.fldedit in ('STAMARRY','LINEID','NUMMOBILE','STAMILIT','EMAIL_EMP',
                                     'TYPTRAV','CARLICEN','TYPFUEL','QTYLENGTH','CODBUSNO','CODBUSRT') then
                        v_stmt := 'update temploy1 set '||replace(i.fldedit,'EMAIL_EMP','EMAIL')||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    elsif i.fldedit in ('DTERETIRE') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';
                        v_stmt  := 'update temploy1 set '||i.fldedit||' = '||v_dess||', '||
                                   ' coduser = '''||p_coduser||''' '||
                                   ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);

                    elsif i.fldedit in ('DTEPASID','DTEOFFID','DTELICID','DTEPRMST','DTEPRMEN') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';
                        v_stmt  := 'update temploy2 set '||i.fldedit||' = '||v_dess||', '||
                                   ' coduser = '''||p_coduser||''' '||
                                   ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);

                    elsif (v_fldedit in ('ADRREG','ADRCONT') or i.fldedit in ('CODDISTR','CODPROVR','CODCNTYR','CODPOSTR','CODSUBDISTR','CODSUBDISTC','CODDISTC','CODPROVC','CODCNTYC','CODPOSTC','NUMTELEC','NUMPASID','NUMOFFID','ADRISSUE','CODPROVI','NUMLICID','NUMPRMID','CODCLNSC','NUMVISA','DTEVISAEXP'))
                          and i.fldedit <> 'ADRCONT1' then
                        v_stmt := 'update temploy2 set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;

                --xxxxx
                for j in c_temploy3 loop
                    if i.fldedit = 'CODBANK' then
                        upd_log1(rq_codempid,'temploy3','161','codbank','C',j.codbank,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMBANK' then
                        upd_log1(rq_codempid,'temploy3','161','numbank','C',j.numbank,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'AMTBANK' then
                        upd_log1(rq_codempid,'temploy3','161','amtbank','N',j.amtbank,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODBANK2' then
                        upd_log1(rq_codempid,'temploy3','161','codbank2','C',j.codbank2,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMBANK2' then
                        upd_log1(rq_codempid,'temploy3','161','numbank2','C',j.numbank2,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'AMTTRANB' then
                        upd_log1(rq_codempid,'temploy3','161','amttranb','C',j.amttranb,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMBRNCH' then
                        upd_log1(rq_codempid,'temploy3','161','numbrnch','C',j.numbrnch,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMBRNCH2' then
                        upd_log1(rq_codempid,'temploy3','161','numbrnch2','C',j.numbrnch2,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    v_stmt    := null;
                    v_fldedit := substr(i.fldedit,1,length(i.fldedit) - 1);
                    if i.fldedit in ('CODBANK','NUMBANK','CODBANK2','NUMBANK2' )then
                        v_stmt := 'update temploy3 set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    elsif i.fldedit in ('AMTBANK','AMTTRANB','NUMBRNCH','NUMBRNCH2') then
                        v_stmt := 'update temploy3 set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i in c_temeslog1_2 loop
                --xxxxx
                for j in c_temploy3 loop
                    if i.fldedit = 'QTYCHEDU' then
                        upd_log1(rq_codempid,'temploy3','32','qtychedu','C',j.qtychedu,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'QTYCHNED' then
                        upd_log1(rq_codempid,'temploy3','32','qtychned','C',j.qtychned,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    v_stmt    := null;
                    v_fldedit := substr(i.fldedit,1,length(i.fldedit) - 1);
                    if i.fldedit in ('QTYCHEDU','QTYCHNED') then
                        v_stmt := 'update temploy3 set '||i.fldedit||' = '||nvl(i.desnew,0)||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            --- tspouse
            for i in c_spouslog loop
                begin
                 select count(*) into v_count
                   from tspouse
                  where codempid = rq_codempid ;
                end;
                if v_count = 0 then
                   insert into tspouse (codempid,coduser,codcreate) values(rq_codempid,p_coduser,p_coduser) ;
                   commit;
                end if;
                exit;
            end loop;

            for i in c_temeslog1 loop
                for j in c_tspouse loop
                    if i.fldedit = 'CODTITLE' then
                        upd_log1(rq_codempid,'tspouse','31','codtitle','C',j.namfirste,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRSTE' then
                        upd_log1(rq_codempid,'tspouse','31','namfirste','C',j.namfirste,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRSTE' then
                        upd_log1(rq_codempid,'tspouse','31','namfirste','C',j.namfirste,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRSTT' then
                        upd_log1(rq_codempid,'tspouse','31','namfirstt','C',j.namfirstt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST3' then
                        upd_log1(rq_codempid,'tspouse','31','namfirst3','C',j.namfirst3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST4' then
                        upd_log1(rq_codempid,'tspouse','31','namfirst4','C',j.namfirst4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST5' then
                        upd_log1(rq_codempid,'tspouse','31','namfirst5','C',j.namfirst5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLASTE' then
                        upd_log1(rq_codempid,'tspouse','31','namlaste','C',j.namlaste,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLASTT' then
                        upd_log1(rq_codempid,'tspouse','31','namlastt','C',j.namlastt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST3' then
                        upd_log1(rq_codempid,'tspouse','31','namlast3','C',j.namlast3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST4' then
                        upd_log1(rq_codempid,'tspouse','31','namlast4','C',j.namlast4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST5' then
                        upd_log1(rq_codempid,'tspouse','31','namlast5','C',j.namlast5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMSPE' then
                        upd_log1(rq_codempid,'tspouse','31','namspe','C',j.namspe,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMSPT' then
                        upd_log1(rq_codempid,'tspouse','31','namspt','C',j.namspt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMSP3' then
                        upd_log1(rq_codempid,'tspouse','31','namsp3','C',j.namsp3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMSP4' then
                        upd_log1(rq_codempid,'tspouse','31','namsp4','C',j.namsp4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMSP5' then
                        upd_log1(rq_codempid,'tspouse','31','namsp5','C',j.namsp5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    if i.fldedit = 'NUMSPID' then
                        upd_log1(rq_codempid,'tspouse','31','numoffid','C',j.numoffid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    --<<User37 #1923 Final Test Phase 1 V11 19/03/2021
                    /*if i.fldedit = 'NUMOFFID' then
                        upd_log1(rq_codempid,'tspouse','31','numoffid','C',j.numoffid,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;*/
                    -->>User37 #1923 Final Test Phase 1 V11 19/03/2021

                    if i.fldedit = 'CODSPOCC' then
                        upd_log1(rq_codempid,'tspouse','31','codspocc','C',j.codspocc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTESPBD' then
                        upd_log1(rq_codempid,'tspouse','31','dtespbd','D',to_char(j.dtespbd,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESNOFFI' then
                        upd_log1(rq_codempid,'tspouse','31','desnoffi','C',j.desnoffi,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEMARRY' then
                        upd_log1(rq_codempid,'tspouse','31','dtemarry','D',to_char(j.dtemarry,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODSPPRO' then
                        upd_log1(rq_codempid,'tspouse','31','codsppro','C',j.codsppro,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODSPCTY' then
                        upd_log1(rq_codempid,'tspouse','31','codspcty','C',j.codspcty,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESPLREG' then
                        upd_log1(rq_codempid,'tspouse','31','desplreg','C',j.desplreg,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESNOTE' then
                        upd_log1(rq_codempid,'tspouse','31','desnote','C',j.desnote,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    if i.fldedit = 'CODEMPIDSP' then
                        upd_log1(rq_codempid,'tspouse','31','codempidsp','C',j.codempidsp,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMIMGSP' then
                        upd_log1(rq_codempid,'tspouse','31','namimgsp','C',j.namimgsp,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STALIFE' then
                        upd_log1(rq_codempid,'tspouse','31','stalife','C',j.stalife,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STAINCOM' then
                        upd_log1(rq_codempid,'tspouse','31','staincom','C',j.staincom,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEDTHSP' then
                        upd_log1(rq_codempid,'tspouse','31','dtedthsp','C',j.dtedthsp,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMFASP' then
                        upd_log1(rq_codempid,'tspouse','31','numfasp','C',j.numfasp,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMMOSP' then
                        upd_log1(rq_codempid,'tspouse','31','nummosp','C',j.nummosp,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FILENAME' then
                        upd_log1(rq_codempid,'tspouse','31','filename','C',j.filename,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;


                    v_stmt    := null;
                    if i.fldedit in ('DTESPBD','DTEMARRY','DTEDTHSP') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update tspouse set '||i.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);

                    elsif i.fldedit = 'NUMSPID' then
                        v_stmt := 'update tspouse set numoffid = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    --<<User37 #1923 Final Test Phase 1 V11 19/03/2021
                    /*elsif i.fldedit = 'NUMOFFID' then
                        v_stmt := 'update tspouse set numoffid = '''||i.desnew||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);*/
                    -->>User37 #1923 Final Test Phase 1 V11 19/03/2021
                    elsif i.fldedit in ('CODTITLE','NAMFIRSTE','NAMFIRSTT','NAMFIRST3','NAMFIRST4','NAMFIRST5','NAMLASTE','NAMLASTT',
                                        'NAMLAST3','NAMLAST4','NAMLAST5','NAMSPE','NAMSPT','NAMSP3','NAMSP4','NAMSP5',
                                        'CODSPOCC','DESNOFFI','CODSPPRO','CODSPCTY','DESPLREG','DESNOTE','NAMFIRST','NAMLAST',
                                        'CODEMPIDSP','NAMIMGSP','STALIFE','STAINCOM','NUMFASP','NUMMOSP','FILENAME') then --<< User46 Weerayut STA4 Patch 6 08-05-2019 Error #6485
                        v_stmt := 'update tspouse set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            --- tfamily
            for i in c_familylog loop
                begin
                 select count(*) into v_count
                   from tfamily
                  where codempid = rq_codempid ;
                end;
                if v_count = 0 then
                   insert into tfamily (codempid,codcreate,coduser) values (rq_codempid,p_coduser,p_coduser) ;
                   commit;
                end if;
                exit;
            end loop;

            for i in c_temeslog1 loop
                for j in c_tfamily loop
                    if i.fldedit = 'NAMFSTFE' then
                        upd_log1(rq_codempid,'tfamily','33','namfstfe','C',j.namfstfe,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTFT' then
                        upd_log1(rq_codempid,'tfamily','33','namfstft','C',j.namfstft,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTF3' then
                        upd_log1(rq_codempid,'tfamily','33','namfstf3','C',j.namfstf3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTF4' then
                        upd_log1(rq_codempid,'tfamily','33','namfstf4','C',j.namfstf4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTF5' then
                        upd_log1(rq_codempid,'tfamily','33','namfstf5','C',j.namfstf5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTFE' then
                        upd_log1(rq_codempid,'tfamily','33','namlstfe','C',j.namlstfe,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTFT' then
                        upd_log1(rq_codempid,'tfamily','33','namlstft','C',j.namlstft,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTF3' then
                        upd_log1(rq_codempid,'tfamily','33','namlstf3','C',j.namlstf3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTF4' then
                        upd_log1(rq_codempid,'tfamily','33','namlstf4','C',j.namlstf4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTF5' then
                        upd_log1(rq_codempid,'tfamily','33','namlstf5','C',j.namlstf5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFATHE' then
                        upd_log1(rq_codempid,'tfamily','33','namfathe','C',j.namfathe,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFATHT' then
                        upd_log1(rq_codempid,'tfamily','33','namfatht','C',j.namfatht,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFATH3' then
                        upd_log1(rq_codempid,'tfamily','33','namfath3','C',j.namfath3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFATH4' then
                        upd_log1(rq_codempid,'tfamily','33','namfath4','C',j.namfath4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFATH5' then
                        upd_log1(rq_codempid,'tfamily','33','namfath5','C',j.namfath5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTME' then
                        upd_log1(rq_codempid,'tfamily','33','namfstme','C',j.namfstme,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTMT' then
                        upd_log1(rq_codempid,'tfamily','33','namfstmt','C',j.namfstmt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTM3' then
                        upd_log1(rq_codempid,'tfamily','33','namfstm3','C',j.namfstm3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTM4' then
                        upd_log1(rq_codempid,'tfamily','33','namfstm4','C',j.namfstm4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTM5' then
                        upd_log1(rq_codempid,'tfamily','33','namfstm5','C',j.namfstm5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTME' then
                        upd_log1(rq_codempid,'tfamily','33','namlstme','C',j.namlstme,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTMT' then
                        upd_log1(rq_codempid,'tfamily','33','namlstmt','C',j.namlstmt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTM3' then
                        upd_log1(rq_codempid,'tfamily','33','namlstm3','C',j.namlstm3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTM4' then
                        upd_log1(rq_codempid,'tfamily','33','namlstm4','C',j.namlstm4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTM5' then
                        upd_log1(rq_codempid,'tfamily','33','namlstm5','C',j.namlstm5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMMOTHE' then
                        upd_log1(rq_codempid,'tfamily','33','nammothe','C',j.nammothe,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMMOTHT' then
                        upd_log1(rq_codempid,'tfamily','33','nammotht','C',j.nammotht,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMMOTH3' then
                        upd_log1(rq_codempid,'tfamily','33','nammoth3','C',j.nammoth3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMMOTH4' then
                        upd_log1(rq_codempid,'tfamily','33','nammoth4','C',j.nammoth4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMMOTH5' then
                        upd_log1(rq_codempid,'tfamily','33','nammoth5','C',j.nammoth5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTCE' then
                        upd_log1(rq_codempid,'tfamily','33','namfstce','C',j.namfstce,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTCT' then
                        upd_log1(rq_codempid,'tfamily','33','namfstct','C',j.namfstct,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTC3' then
                        upd_log1(rq_codempid,'tfamily','33','namfstc3','C',j.namfstc3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTC4' then
                        upd_log1(rq_codempid,'tfamily','33','namfstc4','C',j.namfstc4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFSTC5' then
                        upd_log1(rq_codempid,'tfamily','33','namfstc5','C',j.namfstc5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTCE' then
                        upd_log1(rq_codempid,'tfamily','33','namlstce','C',j.namlstce,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTCT' then
                        upd_log1(rq_codempid,'tfamily','33','namlstct','C',j.namlstct,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTC3' then
                        upd_log1(rq_codempid,'tfamily','33','namlstc3','C',j.namlstc3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTC4' then
                        upd_log1(rq_codempid,'tfamily','33','namlstc4','C',j.namlstc4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLSTC5' then
                        upd_log1(rq_codempid,'tfamily','33','namlstc5','C',j.namlstc5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCONTE' then
                        upd_log1(rq_codempid,'tfamily','33','namconte','C',j.namconte,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCONTT' then
                        upd_log1(rq_codempid,'tfamily','33','namcontt','C',j.namcontt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCONT3' then
                        upd_log1(rq_codempid,'tfamily','33','namcont3','C',j.namcont3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCONT4' then
                        upd_log1(rq_codempid,'tfamily','33','namcont4','C',j.namcont4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCONT5' then
                        upd_log1(rq_codempid,'tfamily','33','namcont5','C',j.namcont5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;


                    if i.fldedit = 'CODFNATN' then
                        upd_log1(rq_codempid,'tfamily','33','codfnatn','C',j.codfnatn,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODFRELG' then
                        upd_log1(rq_codempid,'tfamily','33','codfrelg','C',j.codfrelg,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODFOCCU' then
                        upd_log1(rq_codempid,'tfamily','33','codfoccu','C',j.codfoccu,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMOFIDF' then
                        upd_log1(rq_codempid,'tfamily','33','numofidf','C',j.numofidf,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    if i.fldedit = 'CODMNATN' then
                        upd_log1(rq_codempid,'tfamily','33','codmnatn','C',j.codmnatn,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODMRELG' then
                        upd_log1(rq_codempid,'tfamily','33','codmrelg','C',j.codmrelg,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODMOCCU' then
                        upd_log1(rq_codempid,'tfamily','33','codmoccu','C',j.codmoccu,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMOFIDM' then
                        upd_log1(rq_codempid,'tfamily','33','numofidm','C',j.numofidm,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    if i.fldedit = 'DTEBDFA' then
                        upd_log1(rq_codempid,'tfamily','33','dtebdfa','C',j.dtebdfa,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEDEATHF' then
                        upd_log1(rq_codempid,'tfamily','33','dtedeathf','C',j.dtedeathf,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEBDMO' then
                        upd_log1(rq_codempid,'tfamily','33','dtebdmo','C',j.dtebdmo,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEDEATHM' then
                        upd_log1(rq_codempid,'tfamily','33','dtedeathm','C',j.dtedeathm,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODEMPFA' then
                        upd_log1(rq_codempid,'tfamily','33','codempfa','C',j.codempfa,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODTITLF' then
                        upd_log1(rq_codempid,'tfamily','33','codtitlf','C',j.codtitlf,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STALIFF' then
                        upd_log1(rq_codempid,'tfamily','33','staliff','C',j.staliff,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FILENAMF' then
                        upd_log1(rq_codempid,'tfamily','33','filenamf','C',j.filenamf,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODEMPMO' then
                        upd_log1(rq_codempid,'tfamily','33','codempmo','C',j.codempmo,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODTITLM' then
                        upd_log1(rq_codempid,'tfamily','33','codtitlm','C',j.codtitlm,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STALIFM' then
                        upd_log1(rq_codempid,'tfamily','33','stalifm','C',j.stalifm,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FILENAMM' then
                        upd_log1(rq_codempid,'tfamily','33','filenamm','C',j.filenamm,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODTITLC' then
                        upd_log1(rq_codempid,'tfamily','33','codtitlc','C',j.codtitlc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'ADRCONT1' then
                        upd_log1(rq_codempid,'tfamily','33','adrcont1','C',j.adrcont1,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODPOST' then
                        upd_log1(rq_codempid,'tfamily','33','codpost','C',j.codpost,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMTELE' then
                        upd_log1(rq_codempid,'tfamily','33','numtele','C',j.numtele,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMFAX' then
                        upd_log1(rq_codempid,'tfamily','33','numfax','C',j.numfax,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'EMAIL' then
                        upd_log1(rq_codempid,'tfamily','33','email','C',j.email,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESRELAT' then
                        upd_log1(rq_codempid,'tfamily','33','desrelat','C',j.desrelat,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;
                    if i.fldedit in ('DTEBDFA','DTEDEATHF','DTEBDMO','DTEDEATHM') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update tfamily set '||i.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);

                    elsif i.fldedit in ('NAMFSTFE','NAMFSTFT','NAMFSTF3','NAMFSTF4','NAMFSTF5',
                                     'NAMLSTFE','NAMLSTFT','NAMLSTF3','NAMLSTF4','NAMLSTF5',
                                     'NAMFATHE','NAMFATHT','NAMFATH3','NAMFATH4','NAMFATH5',
                                     'NAMFSTME','NAMFSTMT','NAMFSTM3','NAMFSTM4','NAMFSTM5',
                                     'NAMLSTME','NAMLSTMT','NAMLSTM3','NAMLSTM4','NAMLSTM5',
                                     'NAMMOTHE','NAMMOTHT','NAMMOTH3','NAMMOTH4','NAMMOTH5',
                                     'NAMFSTCE','NAMFSTCT','NAMFSTC3','NAMFSTC4','NAMFSTC5',
                                     'NAMLSTCE','NAMLSTCT','NAMLSTC3','NAMLSTC4','NAMLSTC5',
                                     'NAMCONTE','NAMCONTT','NAMCONT3','NAMCONT4','NAMCONT5',
                                     'CODFNATN','CODFRELG','CODFOCCU','NUMOFIDF','CODMNATN',
                                     'CODMRELG','CODMOCCU','NUMOFIDM','ADRCONT1','CODPOST','NUMTELE',
                                     'NUMFAX','EMAIL','DESRELAT','CODEMPFA','CODTITLF','STALIFF',
                                     'FILENAMF','CODEMPMO','CODTITLM','STALIFM','FILENAMM','CODTITLC') then
                        v_stmt := 'update tfamily set '||i.fldedit||' = '''||i.desnew||''' '||
                                  ' where codempid = '''||rq_codempid||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            -- Relatives
            for i in c_relativeslog1 loop
                v_numseq := i.seqno;
                for j in c_trelatives loop
                    if i.fldedit = 'CODEMPRL' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'codemprl'  ,'N','numseq',null,null,'C',j.codemprl,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMRELE' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'namrele' ,'N','numseq',null,null,'C',j.namrele,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMRELT' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'namrelt' ,'N','numseq',null,null,'C',j.namrelt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMREL3' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'namrel3' ,'N','numseq',null,null,'C',j.namrel3,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMREL4' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'namrel4' ,'N','numseq',null,null,'C',j.namrel4,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMREL5' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'namrel5' ,'N','numseq',null,null,'C',j.namrel5,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NUMTELEC' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'numtelec' ,'N','numseq',null,null,'C',j.numtelec,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'ADRCOMT' then
                        upd_log2(rq_codempid,'trelatives','34',v_numseq,'adrcomt' ,'N','numseq',null,null,'C',j.adrcomt,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt  := null;
                    if i.fldedit in  ('CODEMPRL','NAMRELE','NAMRELT','NAMREL3','NAMREL4','NAMREL5','NUMTELEC','ADRCOMT') then

                        v_stmt := 'update trelatives set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);

                    end if;
                end loop;
            end loop;

            for j in 1..50 loop

                v_arrnumseq(j)     := null;
                v_arrcodemprl(j)   := null;
                v_arrnamrele(j)    := null;
                v_arrnamrelt(j)    := null;
                v_arrnamrel3(j)    := null;
                v_arrnamrel4(j)    := null;
                v_arrnamrel5(j)    := null;
                v_arrnumtelec(j)   := null;
                v_arradrcomt(j)    := null;

            end loop;

            v_num    := 0;
            v_numseq := null;
            for i_relatives2 in c_relativeslog2 loop
                if nvl(v_numseq,0) <> i_relatives2.seqno then
                    v_numseq := i_relatives2.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i_relatives2.seqno;
                end if;

                if i_relatives2.fldedit = 'CODEMPRL' then
                    v_arrcodemprl(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NAMRELE' then
                    v_arrnamrele(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NAMRELT' then
                    v_arrnamrelt(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NAMREL3' then
                    v_arrnamrel3(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NAMREL4' then
                    v_arrnamrel4(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NAMREL5' then
                    v_arrnamrel5(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'NUMTELEC' then
                    v_arrnumtelec(v_num)   := i_relatives2.desnew;
                elsif i_relatives2.fldedit = 'ADRCOMT' then
                    v_arradrcomt(v_num)   := i_relatives2.desnew;
                end if;
            end loop;

            if v_num <> 0 then
                for i_num in 1..v_num loop

                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'codemprl'  ,'N','numseq',null,null,'C',null,v_arrcodemprl(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'namrele'  ,'N','numseq',null,null,'C',null,v_arrnamrele(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'namrelt'  ,'N','numseq',null,null,'C',null,v_arrnamrelt(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'namrel3'  ,'N','numseq',null,null,'C',null,v_arrnamrel3(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'namrel4'  ,'N','numseq',null,null,'C',null,v_arrnamrel4(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'namrel5'  ,'N','numseq',null,null,'C',null,v_arrnamrel5(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'numtelec'  ,'N','numseq',null,null,'C',null,v_arrnumtelec(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'trelatives','34',v_arrnumseq(i_num),'adrcomt'  ,'N','numseq',null,null,'C',null,v_arradrcomt(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);

                    begin
                        select count(*) into v_countrel
                          from trelatives
                         where codempid = rq_codempid
                           and numseq   = v_arrnumseq(i_num);
                    exception when no_data_found then
                        v_countrel := 0;
                    end;

                    if v_countrel = 0 then
                        insert into trelatives
                                    (codempid,numseq,
                                    codemprl,namrele,namrelt,namrel3,namrel4,namrel5,
                                    numtelec,adrcomt,codcreate,coduser)
                        values
                                    (rq_codempid,v_arrnumseq(i_num),
                                    v_arrcodemprl(i_num),v_arrnamrele(i_num),v_arrnamrelt(i_num),v_arrnamrel3(i_num),v_arrnamrel4(i_num),v_arrnamrel5(i_num),
                                    v_arrnumtelec(i_num),v_arradrcomt(i_num),p_coduser,p_coduser);
                    else
                        update trelatives set codemprl  = v_arrcodemprl(i_num),
                                            namrele  = v_arrnamrele(i_num),
                                            namrelt  = v_arrnamrelt(i_num),
                                            namrel3  = v_arrnamrel3(i_num),
                                            namrel4  = v_arrnamrel4(i_num),
                                            namrel5  = v_arrnamrel5(i_num),
                                            numtelec  = v_arrnumtelec(i_num),
                                            adrcomt  = v_arradrcomt(i_num),
                                            coduser = p_coduser
                         where codempid = rq_codempid
                           and numseq   = v_arrnumseq(i_num);
                    end if;

                end loop;
            end if;

            -- Document
            begin
                select folder into v_folder
                  from tfolderd
                 where codapp = 'HRES32E';
            exception when no_data_found then
                null;
            end;

            for i in c_doclog1 loop
                v_numseq := i.seqno;
                for j in c_tappldoc loop
                    if i.fldedit = 'TYPDOC' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'typdoc'  ,'N','numseq',null,null,'C',j.typdoc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NAMDOC' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'namdoc'  ,'N','numseq',null,null,'C',j.namdoc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'DTERECV' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'dterecv' ,'N','numseq',null,null,'D',to_char(j.dterecv,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'DTEDOCEN' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'dtedocen','N','numseq',null,null,'D',to_char(j.dtedocen,'dd/mm/yyyy'),i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'NUMDOC' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'numdoc'  ,'N','numseq',null,null,'C',j.numdoc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'FILEDOC' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'filedoc' ,'N','numseq',null,null,'C',j.filedoc,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'DESNOTE' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'desnote' ,'N','numseq',null,null,'C',j.desnote,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    elsif i.fldedit = 'FLGRESUME' then
                        upd_log2(rq_codempid,'tappldoc','19',v_numseq,'flgresume' ,'N','numseq',null,null,'C',j.flgresume,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt  := null;
                    if i.fldedit in  ('DTERECV','DTEDOCEN') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update tappldoc set '||i.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where numappl  = '''||v_numappl||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    else
                        v_stmt := 'update tappldoc set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where numappl  = '''||v_numappl||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);

                    end if;
                end loop;
            end loop;

            for j in 1..50 loop
                v_arrnumseq(j)   := null;
                v_arrtypdoc(j)   := null;
                v_arrnamdoc(j)   := null;
                v_arrdterecv(j)  := null;
                v_arrdtedocen(j) := null;
                v_arrnumdoc(j)   := null;
                v_arrfiledoc(j)  := null;
                v_arrdesnote(j)  := null;
                v_arrflgresume(j)  := null;
            end loop;

            v_num    := 0;
            v_numseq := null;
            for i_doclog2 in c_doclog2 loop
                if nvl(v_numseq,0) <> i_doclog2.seqno then
                    v_numseq := i_doclog2.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i_doclog2.seqno;
                end if;

                if i_doclog2.fldedit = 'TYPDOC' then
                    v_arrtypdoc(v_num)   := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'NAMDOC' then
                    v_arrnamdoc(v_num)   := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'DTERECV' then
                    v_arrdterecv(v_num)  := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'DTEDOCEN' then
                    v_arrdtedocen(v_num) := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'NUMDOC' then
                    v_arrnumdoc(v_num)   := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'FILEDOC' then
                    v_arrfiledoc(v_num)  := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'DESNOTE' then
                    v_arrdesnote(v_num)  := i_doclog2.desnew;
                elsif i_doclog2.fldedit = 'FLGRESUME' then
                    v_arrflgresume(v_num)  := i_doclog2.desnew;
                end if;
            end loop;

            if v_num <> 0 then
                for i_num in 1..v_num loop

                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'typdoc'  ,'N','numseq',null,null,'C',null,v_arrtypdoc(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'namdoc'  ,'N','numseq',null,null,'C',null,v_arrnamdoc(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'dterecv' ,'N','numseq',null,null,'D',null,to_char(to_date(v_arrdterecv(i_num),'dd/mm/yyyy'),'dd/mm/yyyy'),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'dtedocen','N','numseq',null,null,'D',null,to_char(to_date(v_arrdtedocen(i_num),'dd/mm/yyyy'),'dd/mm/yyyy'),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'numdoc'  ,'N','numseq',null,null,'C',null,v_arrnumdoc(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'filedoc' ,'N','numseq',null,null,'C',null,v_arrfiledoc(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'desnote' ,'N','numseq',null,null,'C',null,v_arrdesnote(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tappldoc','19',v_arrnumseq(i_num),'flgresume' ,'N','numseq',null,null,'C',null,v_arrflgresume(i_num),'N',v_tempch.codcomp,p_coduser,p_lang);

                    v_dterecv := null;
                    if v_arrdterecv(i_num) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdterecv(i_num),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdterecv(i_num),'dd/mm/yyyy'),'dd/mm') ;
                        v_dterecv  := v_dates||'/'||v_years;
                    end if;

                    v_dtedocen := null;
                    if v_arrdtedocen(i_num) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdtedocen(i_num),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdtedocen(i_num),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtedocen  := v_dates||'/'||v_years;
                    end if;

                    begin
                        select count(*) into v_countdoc
                          from tappldoc
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(i_num);
                    exception when no_data_found then
                        v_countdoc := 0;
                    end;

                    if v_countdoc = 0 then
                      insert into tappldoc
                                  (numappl,numseq,codempid,
                                   typdoc,namdoc,
                                   dterecv,dtedocen,
                                   numdoc,filedoc,desnote,flgresume,
                                   coduser,codcreate)
                      values
                                  (v_numappl,v_arrnumseq(i_num),rq_codempid,
                                   v_arrtypdoc(i_num),v_arrnamdoc(i_num),
                                   to_date(v_dterecv,'dd/mm/yyyy'),to_date(v_dtedocen,'dd/mm/yyyy'),
                                   v_arrnumdoc(i_num),v_arrfiledoc(i_num),v_arrdesnote(i_num),v_arrflgresume(i_num),
                                   p_coduser,p_coduser);
                    else
                      update tappldoc set typdoc    = v_arrtypdoc(i_num),
                                          namdoc    = v_arrnamdoc(i_num),
                                          dterecv   = to_date(v_dterecv,'dd/mm/yyyy'),
                                          dtedocen  = to_date(v_dtedocen,'dd/mm/yyyy'),
                                          numdoc    = v_arrnumdoc(i_num),
                                          filedoc   = v_arrfiledoc(i_num),
                                          desnote   = v_arrdesnote(i_num),
                                          flgresume   = v_arrflgresume(i_num),
                                          coduser   = p_coduser
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(i_num);
                    end if;
                    --
                    --v_filemove := v_filemove||' '||v_pathdoces||v_folder||'\\'||v_arrfiledoc(i_num);  -- NOT USE
                    v_filemove := v_arrfiledoc(i_num);
--                    move_file('UTL_FILE_DOCRQ','UTL_FILE_DOCAP',v_filemove,v_filemove);
                    --
                end loop;
            end if;

            update_expense(p_coduser,rq_codempid,v_tempch.codcomp,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,p_lang);
            update_expensesp(p_coduser,rq_codempid,v_tempch.codcomp,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,p_lang);
            --move_document(v_filemove); -- NOT USE
        end if;

        update tempch
           set staappr   = v_staappr,
               codappr   = v_codeappr,
               approvno  = v_approvno,
               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
               remarkap  = v_remark ,
               dteapph   = sysdate,
               coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

    elsif rq_typ = 3 then -- education data
        begin
            select *
              into v_teductch
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
            v_teductch :=  null;
        end;
        begin
          select approvno into v_max_approv
          from   twkflowh
          where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;

        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select count(*)   into  v_count
          from tapempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typreq   = 'HRES32E3'
           and approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E3',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E3'
                   and approvno = ap_approvno;
        end if;
        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;


        chk_workflow.find_next_approve(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 ||
                v_approv := chk_workflow.check_next_step2(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E3',null,v_approvno,p_codappr);
                --v_approv := chk_workflow.chk_nextstep(v_codapp,v_teductch.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
                --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E3'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E3',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate

                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E3'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_teductch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;
        end if;
        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
              rq_chk := 'E' ;
        end if;
        if rq_chk = 'E' and p_status = 'A' then
           v_staappr := 'Y';

           begin
            select numoffid into offid
              from temploy2
             where codempid = rq_codempid;
           exception when no_data_found then null;
           end;

           begin
                select nvl(count(numseq),0) into edu
                 from  teducatn
                where  numappl = v_numappl;
            exception when no_data_found then null;
            end;


            for i_edulog1 in c_edulog1 loop
                v_numseq := i_edulog1.seqno;
                for j in c_teducatn loop
                    if i_edulog1.fldedit = 'CODEDLV' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'codedlv','N','numseq',null,null,'C',j.codedlv,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'CODDGLV' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'coddglv','N','numseq',null,null,'C',j.coddglv,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'CODMAJSB' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'codmajsb','N','numseq',null,null,'C',j.codmajsb,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'CODMINSB' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'codminsb','N','numseq',null,null,'C',j.codminsb,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'CODINST' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'codinst','N','numseq',null,null,'C',j.codinst,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'CODCOUNT' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'codcount','N','numseq',null,null,'C',j.codcount,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'NUMGPA' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'numgpa','N','numseq',null,null,'N',j.numgpa,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'STAYEAR' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'stayear','N','numseq',null,null,'N',j.stayear,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'DTEGYEAR' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'dtegyear','N','numseq',null,null,'N',j.dtegyear,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_edulog1.fldedit = 'FLGEDUC' then
                        upd_log2(rq_codempid,'teducatn','21',v_numseq,'flgeduc','N','numseq',null,null,'C',j.flgeduc,i_edulog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;
                    v_stmt := 'update teducatn set '||i_edulog1.fldedit||' = '''||i_edulog1.desnew||''', '||
                              ' coduser = '''||p_coduser||''' '||
                              ' where codempid = '''||rq_codempid||''' '||
                              '   and numseq   = '''||v_numseq||''' ';
                    v_found := execute_delete(v_stmt);
                end loop;
            end loop;

            for i_index in 1..50 loop
                v_arrnumseq(i_index)         := null;
                v_arrcodedlv(i_index)        := null;
                v_arrcoddglv(i_index)        := null;
                v_arrcodmajsb(i_index)       := null;
                v_arrcodminsb(i_index)       := null;
                v_arrcodinst(i_index)        := null;
                v_arrcodcount(i_index)       := null;
                v_arrnumgpa(i_index)         := null;
                v_arrstayear(i_index)        := null;
                v_arrdtegyear(i_index)       := null;
                v_arrflgeduc(i_index)        := null;
            end loop;

            v_num    := 0;
            v_numseq := null;
            for i_edulog2 in c_edulog2 loop
                if nvl(v_numseq,0) <> i_edulog2.seqno then
                    v_numseq := i_edulog2.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i_edulog2.seqno;
                end if;

                if i_edulog2.fldedit = 'CODEDLV' then
                    v_arrcodedlv(v_num)  := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'CODDGLV' then
                    v_arrcoddglv(v_num)  := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'CODMAJSB' then
                    v_arrcodmajsb(v_num) := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'CODMINSB' then
                    v_arrcodminsb(v_num) := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'CODINST' then
                    v_arrcodinst(v_num)  := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'CODCOUNT' then
                    v_arrcodcount(v_num) := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'NUMGPA' then
                    v_arrnumgpa(v_num)   := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'STAYEAR' then
                    v_arrstayear(v_num)  := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'DTEGYEAR' then
                    v_arrdtegyear(v_num) := i_edulog2.desnew;
                end if;
                if i_edulog2.fldedit = 'FLGEDUC' then
                    v_arrflgeduc(v_num)  := i_edulog2.desnew;
                end if;
            end loop;

            if v_num <> 0 then
                for j in 1..v_num loop

                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'codedlv','N','numseq',null,null,'C',null,v_arrcodedlv(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'coddglv','N','numseq',null,null,'C',null,v_arrcoddglv(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'codmajsb','N','numseq',null,null,'C',null,v_arrcodmajsb(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'codminsb','N','numseq',null,null,'C',null,v_arrcodminsb(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'codinst','N','numseq',null,null,'C',null,v_arrcodinst(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'codcount','N','numseq',null,null,'C',null,v_arrcodcount(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'numgpa','N','numseq',null,null,'N',null,v_arrnumgpa(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'stayear','N','numseq',null,null,'N',null,v_arrstayear(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'dtegyear','N','numseq',null,null,'N',null,v_arrdtegyear(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'teducatn','21',v_arrnumseq(j),'flgeduc','N','numseq',null,null,'C',null,v_arrflgeduc(j),'N',v_teductch.codcomp,p_coduser,p_lang);

                    begin
                        select count(*) into v_countedu
                          from teducatn
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(j);
                    exception when no_data_found then
                        v_countedu := 0;
                    end;

                    if v_countedu = 0 then
                        insert into teducatn
                                    (numappl,numseq,codedlv,
                                     coddglv,codminsb,numgpa,
                                     dtegyear,codcount,codinst,
                                     codmajsb,flgeduc,stayear,
                                     coduser,codempid,codcreate)
                        values
                                    (v_numappl,v_arrnumseq(j),v_arrcodedlv(j),
                                     v_arrcoddglv(j),v_arrcodminsb(j),v_arrnumgpa(j),
                                     v_arrdtegyear(j),v_arrcodcount(j),v_arrcodinst(j),
                                     v_arrcodmajsb(j),v_arrflgeduc(j),v_arrstayear(j),
                                     p_coduser,rq_codempid,p_coduser)   ;
                    else
                        update  teducatn set codedlv  = v_arrcodedlv(j),
                                             coddglv  = v_arrcoddglv(j),
                                             codminsb = v_arrcodminsb(j),
                                             numgpa   = v_arrnumgpa(j),
                                             dtegyear = v_arrdtegyear(j),
                                             codcount = v_arrcodcount(j),
                                             codinst  = v_arrcodinst(j),
                                             codmajsb = v_arrcodmajsb(j),
                                             flgeduc  = v_arrflgeduc(j),
                                             stayear  = v_arrstayear(j),
                                             coduser  = p_coduser
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(j);

                    end if;
                    --
                    if   v_arrflgeduc(j) = '1' then
                         update teducatn
                          set    flgeduc = '2',coduser = p_coduser
                          where  numappl = v_numappl
                          and    flgeduc = '1'
                          and    numseq  <> v_arrnumseq(j) ;

                          update temploy1
                          set    codedlv  = v_arrcodedlv(j),
                                 codmajsb = v_arrcodmajsb(j),
                                 coduser = p_coduser
                          where  codempid = rq_codempid ;

                    end if;
                end loop;

            end if;

            -- Work Exp

            for i_applwexlog1 in c_applwexlog1 loop
                v_numseq := i_applwexlog1.seqno;
                for j in c_tapplwex loop
                    if i_applwexlog1.fldedit = 'DESNOFFI' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desnoffi','N','numseq',null,null,'C',j.desnoffi,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESLSTJOB1' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'deslstjob1','N','numseq',null,null,'C',j.deslstjob1,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESLSTPOS' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'deslstpos','N','numseq',null,null,'C',j.deslstpos,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESOFFI1' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desoffi1','N','numseq',null,null,'C',j.desoffi1,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'NUMTELEO' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'numteleo','N','numseq',null,null,'C',j.numteleo,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'NAMBOSS' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'namboss','N','numseq',null,null,'C',j.namboss,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESRES' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desres','N','numseq',null,null,'C',j.desres,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'AMTINCOM' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'amtincom','N','numseq',null,null,'C',j.amtincom,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DTESTART' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'dtestart','N','numseq',null,null,'C',j.dtestart,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DTEEND' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'dteend','N','numseq',null,null,'C',j.dteend,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESJOB' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desjob','N','numseq',null,null,'C',j.desjob,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESRISK' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desrisk','N','numseq',null,null,'C',j.desrisk,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'DESPROTC' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'desprotc','N','numseq',null,null,'C',j.desprotc,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i_applwexlog1.fldedit = 'REMARK' then
                        upd_log2(rq_codempid,'tapplwex','22',v_numseq,'remark','N','numseq',null,null,'C',j.remark,i_applwexlog1.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;


                    v_stmt    := null;
                    if i_applwexlog1.fldedit in  ('DTESTART','DTEEND') then
                        v_years := to_number(to_char(to_date(i_applwexlog1.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i_applwexlog1.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update tapplwex set '||i_applwexlog1.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid  = '''||rq_codempid||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    else
                        v_stmt := 'update tapplwex set '||i_applwexlog1.fldedit||' = '''||i_applwexlog1.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i_index in 1..50 loop
                v_arrdesnoffi(i_index)         := null;
                v_arrdeslstjob1(i_index)       := null;
                v_arrdeslstpos(i_index)        := null;
                v_arrdesoffi1(i_index)         := null;
                v_arrnumteleo(i_index)         := null;
                v_arrnamboss(i_index)          := null;
                v_arrdesres(i_index)           := null;
                v_arramtincom(i_index)         := null;
                v_arrdtestart(i_index)         := null;
                v_arrdteend(i_index)           := null;
                v_arrdesjob(i_index)           := null;
                v_arrdesrisk(i_index)          := null;
                v_arrdesprotc(i_index)         := null;
                v_arrremark(i_index)           := null;
            end loop;

            v_num    := 0;
            v_numseq := null;
            for i_applwexlog2 in c_applwexlog2 loop
                if nvl(v_numseq,0) <> i_applwexlog2.seqno then
                    v_numseq := i_applwexlog2.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i_applwexlog2.seqno;
                end if;

                if i_applwexlog2.fldedit = 'DESNOFFI' then
                    v_arrdesnoffi(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESLSTJOB1' then
                    v_arrdeslstjob1(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESLSTPOS' then
                    v_arrdeslstpos(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESOFFI1' then
                    v_arrdesoffi1(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'NUMTELEO' then
                    v_arrnumteleo(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'NAMBOSS' then
                    v_arrnamboss(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESRES' then
                    v_arrdesres(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'AMTINCOM' then
                    v_arramtincom(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DTESTART' then
                    v_arrdtestart(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DTEEND' then
                    v_arrdteend(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESJOB' then
                    v_arrdesjob(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESRISK' then
                    v_arrdesrisk(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'DESPROTC' then
                    v_arrdesprotc(v_num)  := i_applwexlog2.desnew;
                end if;
                if i_applwexlog2.fldedit = 'REMARK' then
                    v_arrremark(v_num)  := i_applwexlog2.desnew;
                end if;

            end loop;

            if v_num <> 0 then
                for j in 1..v_num loop

                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desnoffi','N','numseq',null,null,'C',null,v_arrdesnoffi(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'deslstjob1','N','numseq',null,null,'C',null,v_arrdeslstjob1(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'deslstpos','N','numseq',null,null,'C',null,v_arrdeslstpos(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desoffi1','N','numseq',null,null,'C',null,v_arrdesoffi1(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'numteleo','N','numseq',null,null,'C',null,v_arrnumteleo(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'namboss','N','numseq',null,null,'C',null,v_arrnamboss(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desres','N','numseq',null,null,'C',null,v_arrdesres(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'amtincom','N','numseq',null,null,'C',null,v_arramtincom(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'dtestart','N','numseq',null,null,'D',null,v_arrdtestart(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'dteend','N','numseq',null,null,'D',null,v_arrdteend(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desjob','N','numseq',null,null,'C',null,v_arrdesjob(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desrisk','N','numseq',null,null,'C',null,v_arrdesrisk(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'desprotc','N','numseq',null,null,'C',null,v_arrdesprotc(j),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tapplwex','22',v_arrnumseq(j),'remark','N','numseq',null,null,'C',null,v_arrremark(j),'N',v_teductch.codcomp,p_coduser,p_lang);

--                    upd_log2(rq_codempid,'tapplwex','19',v_arrnumseq(j),'dterecv' ,'N','numseq',null,null,'D',null,to_char(to_date(v_arrdterecv(i_num),'dd/mm/yyyy'),'dd/mm/yyyy'),'N',v_tempch.codcomp,p_coduser,p_lang);

                    begin
                        select count(*) into v_countapplwex
                          from tapplwex
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(j);
                    exception when no_data_found then
                        v_countapplwex := 0;
                    end;

                    v_dtestart := null;
                    if v_arrdtestart(j) is not null then
                        v_years     := to_number(to_char(to_date(v_arrdtestart(j),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates     := to_char(to_date(v_arrdtestart(j),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtestart  := v_dates||'/'||v_years;
                    end if;
                    v_dteend := null;
                    if v_arrdteend(j) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdteend(j),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdteend(j),'dd/mm/yyyy'),'dd/mm') ;
                        v_dteend   := v_dates||'/'||v_years;
                    end if;

                    if v_countapplwex = 0 then
                        insert into tapplwex
                                    (numappl,numseq,
                                     desnoffi,deslstjob1,deslstpos,desoffi1,
                                     numteleo,namboss,desres,amtincom,
                                     dtestart,dteend,
                                     desjob,desrisk,desprotc,remark,
                                     coduser,codempid,codcreate)
                        values
                                    (v_numappl,v_arrnumseq(j),
                                     v_arrdesnoffi(j),v_arrdeslstjob1(j),v_arrdeslstpos(j),v_arrdesoffi1(j),
                                     v_arrnumteleo(j),v_arrnamboss(j),v_arrdesres(j),v_arramtincom(j),
                                     to_date(v_dtestart,'dd/mm/yyyy'),to_date(v_dteend,'dd/mm/yyyy'),
                                     v_arrdesjob(j),v_arrdesrisk(j),v_arrdesprotc(j),v_arrremark(j),
                                     p_coduser,rq_codempid,p_coduser)   ;
                    else
                        update  tapplwex set desnoffi  = v_arrdesnoffi(j),
                                             deslstjob1  = v_arrdeslstjob1(j),
                                             deslstpos = v_arrdeslstpos(j),
                                             desoffi1   = v_arrdesoffi1(j),
                                             numteleo = v_arrnumteleo(j),
                                             namboss = v_arrnamboss(j),
                                             amtincom  = v_arramtincom(j),
                                             dtestart = to_date(v_dtestart,'dd/mm/yyyy'),
                                             dteend  = to_date(v_dteend,'dd/mm/yyyy'),
                                             desjob  = v_arrdesjob(j),
                                             desrisk  = v_arrdesrisk(j),
                                             desprotc  = v_arrdesprotc(j),
                                             remark  = v_arrremark(j),
                                             coduser  = p_coduser
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(j);

                    end if;
                    --

                end loop;

            end if;
            -----------
      end if;

        update tempch
        set staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            remarkap  = v_remark ,
            dteapph   = sysdate,
            coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

    elsif rq_typ = 4 then -- children data
        begin
            select *
              into v_tchildch
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
            v_tchildch :=  null;
        end;
        begin
                  select approvno into v_max_approv
                  from   twkflowh
                  where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;

        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
            select count(*)   into  v_count
              from tapempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typreq   = 'HRES32E4'
               and approvno = ap_approvno;
        exception when no_data_found then
            v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E4',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate

                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E4'
                   and approvno = ap_approvno;
        end if;

        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;
        v_codempap  :=  p_codappr;

        chk_workflow.find_next_approve(v_codapp,v_tchildch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
                v_approv := chk_workflow.check_next_step2(v_codapp,v_tchildch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E4',null,v_approvno,p_codappr);

                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E4'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E4',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate
                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E4'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tchildch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_tchildch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_tchildch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;
        end if;

        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
            rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then
            v_staappr := 'Y';
            v_child   := 0 ;
            begin
                select max(numseq) into v_child
                  from tchildrn
                 where codempid = rq_codempid;
            exception when no_data_found then
                v_child := 0;
            end;
            --
            FOR I IN C_CHILLOG1 LOOP
                --v_numseq := i.numseq;
                v_numseq := i.seqno;

                for j in c_tchildrn loop
                    if i.fldedit = 'NAMFIRSTE' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namfirste','N','numseq',null,null,'C',j.namfirste,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRSTT' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namfirstt','N','numseq',null,null,'C',j.namfirstt,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST3' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namfirst3','N','numseq',null,null,'C',j.namfirst3,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST4' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namfirst4','N','numseq',null,null,'C',j.namfirst4,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMFIRST5' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namfirst5','N','numseq',null,null,'C',j.namfirst5,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLASTE' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namlaste','N','numseq',null,null,'C',j.namlaste,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLASTT' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namlastt','N','numseq',null,null,'C',j.namlastt,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST3' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namlast3','N','numseq',null,null,'C',j.namlast3,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST4' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namlast4','N','numseq',null,null,'C',j.namlast4,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMLAST5' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namlast5','N','numseq',null,null,'C',j.namlast5,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCHE' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namche','N','numseq',null,null,'C',j.namche,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCHT' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namcht','N','numseq',null,null,'C',j.namcht,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCH3' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namch3','N','numseq',null,null,'C',j.namch3,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCH4' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namch4','N','numseq',null,null,'C',j.namch4,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NAMCH5' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'namch5','N','numseq',null,null,'C',j.namch5,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTECHBD' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'dtechbd','N','numseq',null,null,'D',to_char(j.dtechbd,'dd/mm/yyyy'),i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODSEX' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'codsex','N','numseq',null,null,'C',j.codsex,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODEDLV' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'codedlv','N','numseq',null,null,'C',j.codedlv,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMOFFID' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'numoffid','N','numseq',null,null,'C',j.numoffid,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FLGEDLV' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'flgedlv','N','numseq',null,null,'C',j.flgedlv,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FLGDEDUCT' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'flgdeduct','N','numseq',null,null,'C',j.flgdeduct,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'CODTITLE' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'codtitle','N','numseq',null,null,'C',j.codtitle,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STACHLD' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'stachld','N','numseq',null,null,'C',j.stachld,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STALIFE' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'stalife','N','numseq',null,null,'C',j.stalife,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTEDTHCH' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'dtedthch','N','numseq',null,null,'D',j.dtedthch,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FLGINC' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'flginc','N','numseq',null,null,'C',j.flginc,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'STABF' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'stabf','N','numseq',null,null,'C',j.stabf,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FILENAME' then
                        upd_log2(rq_codempid,'tchildrn','32',v_numseq,'filename','N','numseq',null,null,'C',j.filename,i.desnew,'N',v_tchildch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;

                    if i.fldedit in ('DTECHBD','DTEDTHCH') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update tchildrn set '||i.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    else
                        v_stmt := 'update tchildrn set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i in 1..20 loop
                v_arrnumseq(i)   := null;
                v_arrdtechbd(i)  := null;
                v_arrcodsex(i)   := null;
                v_arrcodedlv(i)  := null;
                v_arrnumoffid(i) := null;
                v_arrflgedlv(i)  := null;
                v_arrflgdeduct(i) := null;
                v_arrstachld(i)   := null;
                v_arrstalife(i)   := null;
                v_arrdtedthch(i)  := null;
                v_arrflginc(i)    := null;
                v_arrstabf(i)     := null;
                v_arrfilename(i)  := null;
                v_arrcodtitle(i)  := null;

                v_arrnamfirste(i) := null;
                v_arrnamfirstt(i) := null;
                v_arrnamfirst3(i) := null;
                v_arrnamfirst4(i) := null;
                v_arrnamfirst5(i) := null;
                v_arrnamlaste(i) := null;
                v_arrnamlastt(i) := null;
                v_arrnamlast3(i) := null;
                v_arrnamlast4(i) := null;
                v_arrnamlast5(i) := null;
                v_arrnamche(i) := null;
                v_arrnamcht(i) := null;
                v_arrnamch3(i) := null;
                v_arrnamch4(i) := null;
                v_arrnamch5(i) := null;

            end loop;

            v_num    := 0;
            v_numseq := null;
            for i in c_chillog2 loop


                if nvl(v_numseq,0) <> i.seqno then
                    v_numseq := i.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i.seqno;
                end if;

                if i.fldedit = 'NAMFIRSTE' then
                   v_arrnamfirste(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMFIRSTT' then
                   v_arrnamfirstt(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMFIRST3' then
                   v_arrnamfirst3(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMFIRST4' then
                   v_arrnamfirst4(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMLASTE' then
                   v_arrnamlaste(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMLASTT' then
                    v_arrnamlastt(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMLAST3' then
                   v_arrnamlast3(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMLAST4' then
                   v_arrnamlast4(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMLAST5' then
                   v_arrnamlast5(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMFIRST5' then
                   v_arrnamfirst5(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMCHE' then
                   v_arrnamche(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMCHT' then
                   v_arrnamcht(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMCH3' then
                   v_arrnamch3(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMCH4' then
                   v_arrnamch4(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'NAMCH5' then
                   v_arrnamch5(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'DTECHBD' then
                    v_arrdtechbd(v_num)   := i.desnew;
                end if;
                if i.fldedit = 'CODSEX' then
                    v_arrcodsex(v_num)    := i.desnew;
                end if;
                if i.fldedit = 'CODEDLV' then
                    v_arrcodedlv(v_num)   := i.desnew;
                end if;
                if i.fldedit = 'NUMOFFID' then
                    v_arrnumoffid(v_num)  := i.desnew;
                end if;
                if i.fldedit = 'FLGEDLV' then
                    v_arrflgedlv(v_num)   := i.desnew;
                end if;
                if i.fldedit = 'FLGDEDUCT' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                 if i.fldedit = 'CODTITLE' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                 if i.fldedit = 'STACHLD' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                 if i.fldedit = 'STALIFE' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                if i.fldedit = 'DTEDTHCH' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                 if i.fldedit = 'FLGINC' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                if i.fldedit = 'STABF' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;
                 if i.fldedit = 'FILENAME' then
                    v_arrflgdeduct(v_num) := i.desnew;
                end if;

            end loop;

            if v_num <> 0 then
                for i in 1..v_num loop

                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namfirste','N','numseq',null,null,'C',null,v_arrnamfirste(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namfirstt','N','numseq',null,null,'C',null,v_arrnamfirstt(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namfirst3','N','numseq',null,null,'C',null,v_arrnamfirst3(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namfirst4','N','numseq',null,null,'C',null,v_arrnamfirst4(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namfirst5','N','numseq',null,null,'C',null,v_arrnamfirst5(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namlaste','N','numseq',null,null,'C',null,v_arrnamlaste(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namlastt','N','numseq',null,null,'C',null,v_arrnamlastt(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namlast3','N','numseq',null,null,'C',null,v_arrnamlast3(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namlast4','N','numseq',null,null,'C',null,v_arrnamlast4(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namlast5','N','numseq',null,null,'C',null,v_arrnamlast5(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namche','N','numseq',null,null,'C',null,v_arrnamche(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namcht','N','numseq',null,null,'C',null,v_arrnamcht(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namch3','N','numseq',null,null,'C',null,v_arrnamch3(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namch4','N','numseq',null,null,'C',null,v_arrnamch4(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'namch5','N','numseq',null,null,'C',null,v_arrnamch5(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'dtechbd','N','numseq',null,null,'D',null,to_char(to_date(v_arrdtechbd(i),'dd/mm/yyyy'),'dd/mm/yyyy'),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'codsex','N','numseq',null,null,'C',null,v_arrcodsex(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'codedlv','N','numseq',null,null,'C',null,v_arrcodedlv(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'numoffid','N','numseq',null,null,'C',null,v_arrnumoffid(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'flgedlv','N','numseq',null,null,'C',null,v_arrflgedlv(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'flgdeduct','N','numseq',null,null,'C',null,v_arrflgdeduct(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'codtitle','N','numseq',null,null,'C',null,v_arrcodtitle(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'stachld','N','numseq',null,null,'C',null,v_arrstachld(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'stalife','N','numseq',null,null,'C',null,v_arrstalife(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'dtedthch','N','numseq',null,null,'D',null,to_char(to_date(v_arrdtedthch(i),'dd/mm/yyyy'),'dd/mm/yyyy'),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'flginc','N','numseq',null,null,'C',null,v_arrflginc(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'stabf','N','numseq',null,null,'C',null,v_arrstabf(i),'N',v_tchildch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tchildrn','32',v_arrnumseq(i),'filename','N','numseq',null,null,'C',null,v_arrfilename(i),'N',v_tchildch.codcomp,p_coduser,p_lang);

                    v_dtechbd := null;
                    if v_arrdtechbd(i) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdtechbd(i),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdtechbd(i),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtechbd  := v_dates||'/'||v_years;
                    end if;

                    v_dtedthch := null;
                    if v_arrdtedthch(i) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdtedthch(i),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdtedthch(i),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtedthch  := v_dates||'/'||v_years;
                    end if;

                    begin
                        select count(*) into v_countchl
                          from tchildrn
                         where codempid = rq_codempid
                           and numseq   = v_arrnumseq(i);
                    exception when no_data_found then
                        v_countchl := 0;
                    end;

                    if v_countchl = 0 then
                        insert into tchildrn
                                    (codempid,numseq,
                                    namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                                    namlaste,namlastt,namlast3,namlast4,namlast5,
                                    namche,namcht,namch3,namch4,namch5,
                                     dtechbd,codsex,codedlv,
                                     numoffid,flgedlv,flgdeduct,
                                     codtitle,stachld,stalife,
                                     dtedthch,flginc,stabf,filename,
                                     coduser,codcreate)
                        values
                                    (rq_codempid,v_arrnumseq(i),
                                    v_arrnamfirste(i),v_arrnamfirstt(i),v_arrnamfirst3(i),v_arrnamfirst4(i),v_arrnamfirst5(i),
                                    v_arrnamlaste(i),v_arrnamlastt(i),v_arrnamlast3(i),v_arrnamlast4(i),v_arrnamlast5(i),
                                    v_arrnamche(i),v_arrnamcht(i),v_arrnamch3(i),v_arrnamch4(i),v_arrnamch5(i),
                                     to_date(v_dtechbd,'dd/mm/yyyy'),v_arrcodsex(i),v_arrcodedlv(i),
                                     v_arrnumoffid(i),v_arrflgedlv(i),v_arrflgdeduct(i),
                                     v_arrcodtitle(i),v_arrstachld(i),v_arrstalife(i),
                                     to_date(v_dtedthch,'dd/mm/yyyy'),v_arrflginc(i),v_arrstabf(i),v_arrfilename(i),
                                     p_coduser,p_coduser);
                    else
                        update tchildrn set dtechbd   = to_date(v_dtechbd,'dd/mm/yyyy'),
                                            namfirste  = v_arrnamfirste(i),
                                            namfirstt  = v_arrnamfirstt(i),
                                            namfirst3  = v_arrnamfirst3(i),
                                            namfirst4  = v_arrnamfirst4(i),
                                            namfirst5  = v_arrnamfirst5(i),
                                            namlaste  = v_arrnamlaste(i),
                                            namlastt  = v_arrnamlastt(i),
                                            namlast3  = v_arrnamlast3(i),
                                            namlast4  = v_arrnamlast4(i),
                                            namlast5  = v_arrnamlast5(i),
                                            namche  = v_arrnamche(i),
                                            namcht  = v_arrnamcht(i),
                                            namch3  = v_arrnamch3(i),
                                            namch4  = v_arrnamch4(i),
                                            namch5  = v_arrnamch5(i),
                                            codsex    = v_arrcodsex(i),
                                            codedlv   = v_arrcodedlv(i),
                                            numoffid  = v_arrnumoffid(i),
                                            flgedlv   = v_arrflgedlv(i),
                                            flgdeduct = v_arrflgdeduct(i),
                                            codtitle = v_arrcodtitle(i),
                                            stachld = v_arrstachld(i),
                                            stalife = v_arrstalife(i),
                                            flginc = v_arrflginc(i),
                                            stabf = v_arrstabf(i),
                                            filename = v_arrfilename(i),
                                            dtedthch   = to_date(v_dtedthch,'dd/mm/yyyy'),
                                            coduser   = p_coduser
                         where codempid = rq_codempid
                           and numseq   = v_arrnumseq(i);
                    end if;
                end loop;
            end if;
        end if;

       update tempch
        set staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            remarkap  = v_remark ,
            dteapph   = sysdate,
            coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

    elsif rq_typ = 5 then -- reward data
        begin
            select *
              into v_trewdreq
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
                v_trewdreq :=  null;
        end;
        begin
                  select approvno into v_max_approv
                  from   twkflowh
                  where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;
        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select count(*)   into  v_count
          from tapempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typreq   = 'HRES32E5'
           and approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E5',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E5'
                   and approvno = ap_approvno;
        end if;
        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 ||
                v_approv := chk_workflow.check_next_step2(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E5',null,v_approvno,p_codappr);
                --v_approv := chk_workflow.chk_nextstep(v_codapp,v_trewdreq.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
                --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E5'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E5',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate
                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E5'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_trewdreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;

        end if;
        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
              rq_chk := 'E' ;
        end if;
        if rq_chk = 'E' and p_status = 'A' then
        v_staappr := 'Y';--User37 #2169 Final Test Phase 1 V11 16/02/2021
        --////// Compentency
            FOR I IN C_cmptncylog1 LOOP
                v_numseq := i.seqno;
                v_codseq := i.codseq;

                for j in c_tcmptncy loop
                    if i.fldedit = 'GRADE' then
                        upd_log2(rq_codempid,'tcmptncy','51',v_numseq,'grade','N','codtency',null,null,'C',j.grade,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                     if i.fldedit = 'CODTENCY' then
                        upd_log2(rq_codempid,'tcmptncy','51',v_numseq,'codtency','N','codtency',null,null,'C',j.codtency,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;

                    if i.fldedit in ('GRADE','CODTENCY') then

                        v_stmt := 'update tcmptncy set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and codtency   = '''||v_codseq||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i in 1..20 loop
                v_arrcodtency(i)   := null;
                v_arrgrade(i)  := null ;
              end loop;

            v_num    := 0;
            v_numseq := null;
            for i in c_cmptncylog2 loop



                if nvl(v_numseq,0) <> i.seqno then
                    v_numseq := i.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i.seqno;
                end if;

                v_arrcodtency(v_num) := i.codseq;

                if i.fldedit = 'GRADE' then
                   v_arrgrade(v_num)  := i.desnew;
                end if;



            end loop;

            if v_num <> 0 then
                for i in 1..v_num loop

                    upd_log2(rq_codempid,'tcmptncy','51',v_arrnumseq(i),'grade','N','codtency',null,null,'C',null,v_arrgrade(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
--                    upd_log2(rq_codempid,'tcmptncy','51',v_arrnumseq(i),'codtency','N','codtency',null,null,'C',null,v_arrcodtency(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);


                    begin
                        select count(*) into v_countcmptncy
                          from tcmptncy
                         where codempid = rq_codempid
                           and codtency   = v_arrcodtency(i);
                    exception when no_data_found then
                        v_countchl := 0;
                    end;

                    if v_countcmptncy = 0 then
                        insert into tcmptncy
                                    (codempid,numappl,
                                    codtency,grade,
                                     coduser,codcreate)
                        values
                                    (rq_codempid,v_numappl,
                                     v_arrcodtency(i),v_arrgrade(i),
                                     p_coduser,p_coduser);
                    else
                        update tcmptncy set codtency = v_arrcodtency(i),
                                            grade = v_arrgrade(i),
                                            coduser   = p_coduser
                         where codempid = rq_codempid
                           and numappl   = v_numappl;
                    end if;
                end loop;
            end if;
        --////
        --////// His Reward
            FOR I IN c_hisrewdlog1 LOOP
                v_numseq := i.seqno;
                v_dteinput := i.dtereq;

                for j in c_thisrewd loop
                    if i.fldedit = 'TYPREWD' then
                        upd_log2(rq_codempid,'thisrewd','53',v_numseq,'typrewd','N','dteinput',null,null,'C',j.typrewd,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                     if i.fldedit = 'DESREWD1' then
                        upd_log2(rq_codempid,'thisrewd','53',v_numseq,'desrewd1','N','dteinput',null,null,'C',j.desrewd1,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'NUMHMREF' then
                        upd_log2(rq_codempid,'thisrewd','53',v_numseq,'numhmref','N','dteinput',null,null,'C',j.numhmref,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FILENAME' then
                        upd_log2(rq_codempid,'thisrewd','53',v_numseq,'filename','N','dteinput',null,null,'C',j.filename,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;

                    if i.fldedit in ('TYPREWD','DESREWD1','NUMHMREF','FILENAME') then

                        v_stmt := 'update thisrewd set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where codempid = '''||rq_codempid||''' '||
                                  '   and dteinput   = '''||rq_dtereq||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i in 1..20 loop
                v_arrnumseq(i)   := null;
                v_arrdteinput(i)   := null;
                v_arrtyprewd(i)   := null;
                v_arrdesrewd1(i)  := null ;
                v_arrnumhmref(i)  := null ;
                v_arrfilename(i)  := null ;
              end loop;

            v_num    := 0;
            v_numseq := null;
            for i in c_hisrewdlog2 loop
                v_codseq := i.codseq;

                if nvl(v_numseq,0) <> i.seqno then
                    v_numseq := i.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i.seqno;
                end if;
                v_arrdteinput(v_num) := i.dtereq;

                if i.fldedit = 'TYPREWD' then
                   v_arrtyprewd(v_num)  := i.desnew;
                end if;
                 if i.fldedit = 'DESREWD1' then
                    v_arrdesrewd1(v_num) := i.desnew;
                end if;
                if i.fldedit = 'NUMHMREF' then
                    v_arrnumhmref(v_num) := i.desnew;
                end if;
                if i.fldedit = 'FILENAME' then
                    v_arrfilename(v_num) := i.desnew;
                end if;

            end loop;

            if v_num <> 0 then
                for i in 1..v_num loop

                    upd_log2(rq_codempid,'thisrewd','53',v_arrnumseq(i),'typrewd','N','dteinput',null,null,'C',null,v_arrtyprewd(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'thisrewd','53',v_arrnumseq(i),'desrewd1','N','dteinput',null,null,'C',null,v_arrdesrewd1(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'thisrewd','53',v_arrnumseq(i),'numhmref','N','dteinput',null,null,'C',null,v_arrnumhmref(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'thisrewd','53',v_arrnumseq(i),'filename','N','dteinput',null,null,'C',null,v_arrfilename(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);

                    begin
                        select count(*) into v_counthisrewd
                          from thisrewd
                         where codempid = rq_codempid
                           and dteinput   = rq_dtereq;
                    exception when no_data_found then
                        v_countchl := 0;
                    end;

                    if v_counthisrewd = 0 then
                        insert into thisrewd
                                    (codempid,
                                    typrewd,desrewd1,numhmref,filename,
                                     dteinput,coduser,codcreate)
                        values
                                    (rq_codempid,
                                     v_arrtyprewd(i),v_arrdesrewd1(i),v_arrnumhmref(i),v_arrfilename(i),
                                     v_arrdteinput(i),p_coduser,p_coduser);
                    else
                        update thisrewd set  typrewd  = v_arrtyprewd(i),
                                            desrewd1 = v_arrdesrewd1(i),
                                            numhmref  = v_arrnumhmref(i),
                                            filename = v_arrfilename(i),
                                            coduser  = p_coduser
                         where codempid = rq_codempid;
                    end if;
                end loop;

            end if;
            --////
            --////// Language Ability
            --<<User37 #1925 Final Test Phase 1 V11 15/02/2021
            FOR I IN c_langabilog1 LOOP
                v_numseq := i.seqno;

                for j in c_tlangabi loop
                    if i.fldedit = 'FLGLIST' then
                        upd_log2(rq_codempid,'tlangabi','52',v_numseq,'flglist','N','codlang',null,null,'C',j.flglist,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                     if i.fldedit = 'FLGSPEAK' then
                        upd_log2(rq_codempid,'tlangabi','52',v_numseq,'flgspeak','N','codlang',null,null,'C',j.flgspeak,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FLGREAD' then
                        upd_log2(rq_codempid,'tlangabi','52',v_numseq,'flgread','N','codlang',null,null,'C',j.flgread,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'FLGWRITE' then
                        upd_log2(rq_codempid,'tlangabi','52',v_numseq,'flgwrite','N','codlang',null,null,'C',j.flgwrite,i.desnew,'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt    := null;

                    if i.fldedit in ('FLGLIST','FLGSPEAK','FLGREAD','FLGWRITE') then

                        v_stmt := 'update tlangabi set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where numappl = '''||v_numappl||''' '||
                                  '   and codlang   = '''||j.codlang||''' ';
                        v_found := execute_delete(v_stmt);
                    end if;
                end loop;
            end loop;

            for i in 1..20 loop
                v_arrnumseq(i)   := null;
                v_arrcodlang(i)   := null;
                v_arrflglist(i)   := null;
                v_arrflgspeak(i)  := null ;
                v_arrflgread(i)  := null ;
                v_arrflgwrite(i)  := null ;
              end loop;

            v_num    := 0;
            v_numseq := null;
            for i in c_langabilog2 loop
                v_codseq := i.codseq;

                if nvl(v_numseq,0) <> i.seqno then
                    v_numseq := i.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i.seqno;
                end if;
                v_arrcodlang(v_num) := i.codseq;

                if i.fldedit = 'FLGLIST' then
                   v_arrflglist(v_num)  := i.desnew;
                end if;
                 if i.fldedit = 'FLGSPEAK' then
                    v_arrflgspeak(v_num) := i.desnew;
                end if;
                if i.fldedit = 'FLGREAD' then
                    v_arrflgread(v_num) := i.desnew;
                end if;
                if i.fldedit = 'FLGWRITE' then
                    v_arrflgwrite(v_num) := i.desnew;
                end if;

            end loop;

            if v_num <> 0 then
                for i in 1..v_num loop

                    upd_log2(rq_codempid,'tlangabi','52',v_arrnumseq(i),'flglist','N','codlang',null,null,'C',null,v_arrflglist(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tlangabi','52',v_arrnumseq(i),'flgspeak','N','codlang',null,null,'C',null,v_arrflgspeak(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tlangabi','52',v_arrnumseq(i),'flgread','N','codlang',null,null,'C',null,v_arrflgread(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'tlangabi','52',v_arrnumseq(i),'flgwrite','N','codlang',null,null,'C',null,v_arrflgwrite(i),'N',v_trewdreq.codcomp,p_coduser,p_lang);

                    begin
                        select count(*) into v_countlangabi
                          from tlangabi
                         where numappl = v_numappl
                           and codlang   = v_arrcodlang(v_num);
                    exception when no_data_found then
                        v_countchl := 0;
                    end;

                    if v_countlangabi = 0 then
                        insert into tlangabi
                                    (numappl,codlang,
                                     flglist,flgspeak,flgread,flgwrite,
                                     dtecreate,codcreate,dteupd,coduser)
                        values
                                    (v_numappl,v_arrcodlang(i),
                                     v_arrflglist(i),v_arrflgspeak(i),v_arrflgread(i),v_arrflgwrite(i),
                                     sysdate,p_coduser,sysdate,p_coduser);
                    else
                        update tlangabi set  flglist = v_arrflglist(i),
                                             flgspeak = v_arrflgspeak(i),
                                             flgread = v_arrflgread(i),
                                             flgwrite = v_arrflgwrite(i),
                                             dteupd  = sysdate,
                                             coduser  = p_coduser
                         where numappl = v_numappl
                           and codlang   = v_arrcodlang(v_num);
                    end if;
                end loop;

            end if;
            --////
            -->>User37 #1925 Final Test Phase 1 V11 15/02/2021
      end if;
     update tempch
        set staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            remarkap  = v_remark ,
            dteapph   = sysdate,
            coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

    elsif rq_typ = 6 then -- education data
        begin
            select *
              into v_ttrainch
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
            v_ttrainch :=  null;
        end;
        begin
                  select approvno into v_max_approv
                  from   twkflowh
                  where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;
        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select count(*)   into  v_count
          from tapempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typreq   = 'HRES32E6'
           and approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E6',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E6'
                   and approvno = ap_approvno;
        end if;
        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 ||
                v_approv := chk_workflow.check_next_step2(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E6',null,v_approvno,p_codappr);
                -- v_approv := chk_workflow.chk_nextstep(v_codapp,v_ttrainch.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
                --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E6'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E6',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate
                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E6'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;

        end if;
        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
              rq_chk := 'E' ;
        end if ;
        if rq_chk = 'E' and p_status = 'A' then
           v_staappr := 'Y';

           begin
                select nvl(count(numseq),0) into v_numseqbf
                from   ttrainbf
                where  numappl = v_numappl;
            exception when no_data_found then
               v_numseqbf := null;
            end;

            for i in c_trnlog1 loop
                v_numseq := i.seqno;
                for j in c_ttrainbf loop
                    if i.fldedit = 'DESTRAIN' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'destrain','N','numseq',null,null,'C',j.destrain,i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTETRAIN' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'dtetrain','N','numseq',null,null,'D',to_char(j.dtetrain,'dd/mm/yyyy'),i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DTETREN' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'dtetren','N','numseq',null,null,'D',to_char(j.dtetren,'dd/mm/yyyy'),i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESPLACE' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'desplace','N','numseq',null,null,'C',j.desplace,i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                    if i.fldedit = 'DESINSTU' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'desinstu','N','numseq',null,null,'C',j.desinstu,i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;
                     if i.fldedit = 'FILEDOC' then
                        upd_log2(rq_codempid,'ttrainbf','23',v_numseq,'filedoc','N','numseq',null,null,'C',j.filedoc,i.desnew,'N',v_teductch.codcomp,p_coduser,p_lang);
                    end if;

                    v_stmt  := null;
                    if i.fldedit in  ('DTETRAIN','DTETREN') then
                        v_years := to_number(to_char(to_date(i.desnew,'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates := to_char(to_date(i.desnew,'dd/mm/yyyy'),'dd/mm') ;
                        v_dess  := ' to_date('''||(v_dates||'/'||v_years)||''',''dd/mm/yyyy'')';

                        v_stmt := 'update ttrainbf set '||i.fldedit||' = '||v_dess||', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where numappl  = '''||v_numappl||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);
                    else
                        v_stmt := 'update ttrainbf set '||i.fldedit||' = '''||i.desnew||''', '||
                                  ' coduser = '''||p_coduser||''' '||
                                  ' where numappl  = '''||v_numappl||''' '||
                                  '   and numseq   = '''||v_numseq||''' ';
                        v_found := execute_delete(v_stmt);

                    end if;
                end loop;
            end loop;

            for i in 1..20 loop
                v_arrnumseq(i)   := null;
                v_arrdestrain(i) := null;
                v_arrdtetrain(i) := null;
                v_arrdtetren(i)  := null;
                v_arrdesplace(i) := null;
                v_arrdesinstu(i) := null;
                v_arrfiledoc(i) := null;
            end loop;

            v_num    := 0;
            v_numseq := null;
            for i in c_trnlog2 loop
                if nvl(v_numseq,0) <> i.seqno then
                    v_numseq := i.seqno;
                    v_num    := v_num + 1;
                    v_arrnumseq(v_num) := i.seqno;
                end if;

                if i.fldedit = 'DESTRAIN' then
                    v_arrdestrain(v_num)    := i.desnew;
                end if;
                if i.fldedit = 'DTETRAIN' then
                    v_arrdtetrain(v_num)    := i.desnew;
                end if;
                if i.fldedit = 'DTETREN' then
                    v_arrdtetren(v_num)     := i.desnew;
                end if;
                if i.fldedit = 'DESPLACE' then
                    v_arrdesplace(v_num)    := i.desnew;
                end if;
                if i.fldedit = 'DESINSTU' then
                    v_arrdesinstu(v_num)    := i.desnew;
                end if;
                 if i.fldedit = 'FILEDOC' then
                    v_arrfiledoc(v_num)    := i.desnew;
                end if;
            end loop;

            if v_num <> 0 then
                for i in 1..v_num loop

                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'destrain','N','numseq',null,null,'C',null,v_arrdestrain(i),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'dtetrain','N','numseq',null,null,'D',null,v_arrdtetrain(i),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'dtetren','N','numseq',null,null,'D',null,v_arrdtetren(i),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'desplace','N','numseq',null,null,'C',null,v_arrdesplace(i),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'desinstu','N','numseq',null,null,'C',null,v_arrdesinstu(i),'N',v_teductch.codcomp,p_coduser,p_lang);
                    upd_log2(rq_codempid,'ttrainbf','23',v_arrnumseq(i),'filedoc','N','numseq',null,null,'C',null,v_arrfiledoc(i),'N',v_teductch.codcomp,p_coduser,p_lang);

                    v_dtetrain := null;
                    if v_arrdtetrain(i) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdtetrain(i),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdtetrain(i),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtetrain  := v_dates||'/'||v_years;
                    end if;
                    v_dtetren  := null;
                    if v_arrdtetren(i) is not null then
                        v_years    := to_number(to_char(to_date(v_arrdtetren(i),'dd/mm/yyyy'),'yyyy')) + v_zyear;
                        v_dates    := to_char(to_date(v_arrdtetren(i),'dd/mm/yyyy'),'dd/mm') ;
                        v_dtetren  := v_dates||'/'||v_years;
                    end if;

                    begin
                        select count(*) into v_counttrn
                          from ttrainbf
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(i);
                    exception when no_data_found then
                        v_counttrn := 0;
                    end;

                    if v_counttrn = 0 then
                        insert into ttrainbf
                                    (codempid,numappl,numseq,
                                     destrain,dtetrain,dtetren,
                                     desplace,desinstu,filedoc,coduser,codcreate)
                        values
                                    (rq_codempid,v_numappl,v_arrnumseq(i),
                                     v_arrdestrain(i),to_date(v_dtetrain,'dd/mm/yyyy'),to_date(v_dtetren,'dd/mm/yyyy'),
                                     v_arrdesplace(i),v_arrdesinstu(i),v_arrfiledoc(i),p_coduser,p_coduser);
                    else
                        update ttrainbf set destrain = v_arrdestrain(i),
                                            dtetrain = to_date(v_dtetrain,'dd/mm/yyyy'),
                                            dtetren  = to_date(v_dtetren,'dd/mm/yyyy'),
                                            desplace = v_arrdesplace(i),
                                            desinstu = v_arrdesinstu(i),
                                            filedoc  = v_arrfiledoc(i),
                                            coduser  = p_coduser
                         where numappl = v_numappl
                           and numseq  = v_arrnumseq(i);
                    end if;

                end loop;
            end if;
      end if;
        update tempch
        set staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            remarkap  = v_remark ,
            dteapph   = sysdate,
            coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;
    elsif rq_typ = 7 then -- others data
        begin
            select *
              into v_ttrainch
              from tempch
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq
               and typchg   = rq_typ;
        exception when others then
            v_ttrainch :=  null;
        end;
        begin
                  select approvno into v_max_approv
                  from   twkflowh
                  where  routeno = v_tempch.routeno ;
        exception when no_data_found then
                  v_max_approv := 0 ;
        end ;
        ap_approvno :=  v_appseq;
        -- step 1 => insert table request detail
        begin
        select count(*)   into  v_count
          from tapempch
         where codempid = rq_codempid
           and dtereq   = rq_dtereq
           and numseq   = rq_numseq
           and typreq   = 'HRES32E7'
           and approvno = ap_approvno;
        exception when no_data_found then
         v_count := 0;
        end;

        if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,
                                 typreq,approvno,codappr,
                                 dteappr,staappr,remark,
                                 dteapph,coduser
                                 )
                 values         (
                                 rq_codempid,rq_dtereq,rq_numseq,
                                 'HRES32E7',ap_approvno,p_codappr,
                                 to_date(p_dteappr,'dd/mm/yyyy'),
                                 v_staappr,v_remark,sysdate,
                                 p_coduser
                                 );
        else
                update tapempch
                   set codappr  = p_codappr,
                       dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                       staappr  = v_staappr,
                       remark   = v_remark,
                       coduser  = p_coduser,
                       dteapph  = sysdate
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and typreq   = 'HRES32E7'
                   and approvno = ap_approvno;
        end if;
        -- step 2 => check next step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if p_status = 'A' and rq_chk <> 'E'  then
             loop
--<< user22 : 04/07/2016 : STA3590287 ||
                v_approv := chk_workflow.check_next_step2(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,'HRES32E7',null,v_approvno,p_codappr);
                -- v_approv := chk_workflow.chk_nextstep(v_codapp,v_ttrainch.routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
                --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
-->> user22 : 04/07/2016 : STA3590287 ||
                if  v_approv is not null then
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                          select count(*) into v_count
                            from tapempch
                           where codempid = rq_codempid
                             and dtereq   = rq_dtereq
                             and numseq   = rq_numseq
                             and typreq   = 'HRES32E7'
                             and approvno = v_approvno;
                    exception when no_data_found then  v_count := 0;
                    end;
                    if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,
                                             typreq,approvno,codappr,
                                             dteappr,staappr,remark,
                                             dteapph,coduser
                                             )
                                values      (
                                             rq_codempid,rq_dtereq,rq_numseq,
                                             'HRES32E7',v_approvno,v_codeappr,
                                             to_date(p_dteappr,'dd/mm/yyyy'),'A',v_desc,
                                             sysdate,p_coduser
                                             );
                    else
                        update tapempch
                           set codappr   = v_codeappr,
                               dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                               staappr   = 'A',
                               remark    = v_desc,
                               coduser   = p_coduser,
                               dteapph   = sysdate
                          where codempid = rq_codempid
                            and dtereq   = rq_dtereq
                            and numseq   = rq_numseq
                            and typreq   = 'HRES32E7'
                            and approvno = v_approvno;
                    end if;
                    --v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                    chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                else
                    exit ;
                end if;
                --chk_workflow.find_next_approve(v_codapp,v_ttrainch.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);
             end loop ;

        end if;
        -- step 3 => update table request and insert transaction
        if v_max_approv = v_approvno then
            rq_chk := 'E' ;
        end if ;
        if rq_chk = 'E' and p_status = 'A' then
             v_staappr := 'Y';
  
             begin
                  select 'Y' into v_chk_empoth
                  from   tempothr
                  where  numappl = v_numappl;
              exception when no_data_found then
                 v_chk_empoth := 'N';
              end;
  
              for i in c_empothlog1 loop
                if i.itemtype = '2' then
--                  upd_log1('tempothr','61',i.fldedit,'N',i.desold,i.desnew,'N',v_upd);
                  upd_log1(rq_codempid,'tempothr','61',i.fldedit,'N',i.desold,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                  v_stmt_upd      := v_stmt_upd||i.fldedit||' = '''||to_char(i.desnew)||''',';
                  v_col_insert    := v_col_insert||i.fldedit||',';
                  v_val_insert    := v_val_insert||''''||to_char(i.desnew)||''',';
                elsif i.itemtype = '3' then
--                  upd_log1('tempothr','61',i.fldedit,'D',i.desold,i.desnew,'N',v_upd);
                  upd_log1(rq_codempid,'tempothr','61',i.fldedit,'D',i.desold,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                  v_stmt_upd      := v_stmt_upd||i.fldedit||' = to_date('''||i.desnew||''',''dd/mm/yyyy''),';
                  v_col_insert    := v_col_insert||i.fldedit||',';
                  v_val_insert    := v_val_insert||'to_date('''||i.desnew||''',''dd/mm/yyyy''),';
                else
--                  upd_log1('tempothr','61',i.fldedit,'C',i.desold,i.desnew,'N',v_upd);
                  upd_log1(rq_codempid,'tempothr','61',i.fldedit,'C',i.desold,i.desnew,'N',v_tempch.codcomp,p_coduser,p_lang);
                  v_stmt_upd      := v_stmt_upd||i.fldedit||' = '''||i.desnew||''',';
                  v_col_insert    := v_col_insert||i.fldedit||',';
                  v_val_insert    := v_val_insert||''''||i.desnew||''',';
                end if;
              end loop;
              
              if v_chk_empoth = 'Y' then
                execute immediate ' update tempothr set '||v_stmt_upd||'coduser = '''||p_coduser||''' where numappl = '''||v_numappl||'''';
              else
                execute immediate ' insert into tempothr(numappl,codempid,'||v_col_insert||'codcreate,coduser)
                                                 values ('''||v_numappl||''','''||rq_codempid||''','||v_val_insert||''''||p_coduser||''','''||p_coduser||''') ';
              end if;
          end if;
        update tempch
        set staappr   = v_staappr,
            codappr   = v_codeappr,
            approvno  = v_approvno,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            remarkap  = v_remark ,
            dteapph   = sysdate,
            coduser   = p_coduser
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_numseq
          and typchg   = rq_typ;

    end if; --- end if rq_typ

    commit ;

    begin
      select rowid
        into v_row_id
        from tempch
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq
         and typchg   = rq_typ;
    end;

    begin 
      chk_workflow.sendmail_to_approve( p_codapp        => 'HRES32E',
                                        p_codtable_req  => 'tempch',
                                        p_rowid_req     => v_row_id,
                                        p_codtable_appr => 'tapempch',
                                        p_codempid      => rq_codempid,
                                        p_dtereq        => rq_dtereq,
                                        p_seqno         => rq_numseq,
                                        p_typchg        => 'HRES32E'||rq_typ,
                                        p_staappr       => v_staappr,
                                        p_approvno      => v_approvno,
                                        p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                        p_subject_mail_numseq  => '10',
                                        p_lang          => global_v_lang,
                                        p_coduser       => global_v_coduser);
    exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
      end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  END;  -- Procedure Approve
  --

  procedure process_approve(json_str_input in clob, json_str_output out clob) is
--    global_json_obj       json :=  json(global_json_str);
    v_coduser             varchar2(100 char);
    v_remark_appr         varchar2(4000 char);
    v_remark_not_appr     varchar2(4000 char);
    json_obj        json_object_t;
    json_obj2       json_object_t;
    param_json      json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100);
    v_appseq        number;
    v_chk           varchar2(10);
    v_numseq        number;
    v_codempid      varchar2(100);
    v_dtereq        varchar2(100);
    v_typ           number;
    v_concat        varchar2(100);
    errm_str        varchar2(4000);
    resp_obj        json_object_t :=  json_object_t();
    resp_str        varchar2(4000 char);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    v_coduser         := hcm_util.get_string_t(json_obj, 'p_coduser');
    v_remark_appr     := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    v_remark_not_appr := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
    p_lang            := hcm_util.get_string_t(json_obj, 'p_lang');
    param_json        := hcm_util.get_json_t(json_obj, 'param_json');

    v_rowcount := param_json.get_size;
    for i in 0..param_json.get_size-1 loop
      json_obj2   := hcm_util.get_json_t(param_json, to_char(i));
      v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
      v_numseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
      v_dtereq    := hcm_util.get_string_t(json_obj2, 'p_dtereq');
      v_typ       := to_number(hcm_util.get_string_t(json_obj2, 'p_typ'));

      v_staappr := nvl(v_staappr, 'A');
      approve(v_coduser,p_lang,to_char(v_rowcount),v_staappr,v_remark_appr,v_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,v_codempid,v_numseq,v_dtereq,v_typ);
      exit when param_msg_error is not null;
    end loop;
    --p_result := web_service_essonline.get_resp_json_str('success','Approve Complete.. !!',null);
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,p_lang);
      rollback;
    else
      if param_msg_error_mail is not null then
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    --p_result := web_service_essonline.get_resp_json_str('error',DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace,null);
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',errm_str,p_lang);
  end process_approve;
  --
  procedure insert_tempch(v_coduser in varchar2,v_codcomp in varchar2,v_codempid in varchar2,v_numseq in number,v_dtereq in date,v_routeno in varchar2) as
  begin
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'1',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,'test-reason',
        null,null,sysdate,v_coduser);
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'2',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,null,
        null,null,sysdate,v_coduser);
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'3',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,null,
        null,null,sysdate,v_coduser);
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'4',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,null,
        null,null,sysdate,v_coduser);
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'5',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,null,
        null,null,sysdate,v_coduser);
      insert into tempch
        (codempid,dtereq,typchg,numseq,
        codcomp,approvno,staappr,codappr,
        dteappr,remarkap,routeno,
        codinput,dteinput,
        dtecancel,flgsend,dtesnd,desnote,
        dteapph,flgagency,dteupd,coduser)
      values
        (v_codempid,v_dtereq,'6',v_numseq,
        v_codcomp,null,'P',null,
        null,null,v_routeno,
        null,sysdate,
        null,null,null,null,
        null,null,sysdate,v_coduser);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400', param_msg_error,global_v_lang);
  end;
  --
  procedure gen_others_data(json_str_output out clob) is
    obj_row               json_object_t;
    obj_data              json_object_t;
    obj_row_codlist       json_object_t;
    obj_data_codlist      json_object_t;

    v_rowcnt              number;
    v_rowcnt_codlist      number;

    v_numappl             temploy1.numappl%type;
    v_value               varchar2(4000 char);
    v_value_n             varchar2(4000 char);
    v_codapp              tlistval.codapp%type;
    v_colist_flgused      tlistval.flgused%type;
    v_exists              varchar2(1) := 'N';
    v_flg_delete          varchar2(1) := 'N';

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
      where   tusr.table_name         = 'TEMPOTHR'
      and     tusr.column_name        like 'USR_%'
      and     tusr.column_name        = toth.column_name
      and     tusr.table_name         = cmm.table_name(+)
      and     tusr.column_name        = cmm.column_name(+)
      and     toth.essstat            <> '1'
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
    begin
      select numappl
        into v_numappl
        from temploy1
       where codempid     = b_index_codempid;
    exception when no_data_found then
      v_numappl := null;
    end;

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
        select desold, desnew
          into v_value, v_value_n
          from temeslog1
         where codempid   = b_index_codempid
           and dtereq     = b_index_dtereq
           and numseq     = b_index_numseq
           and numpage    = 71
           and fldedit    = upper(i.column_name);
      exception when no_data_found then
        v_value_n := v_value;
      end;

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
      if i.itemtype = '4' then
        obj_data.put('column_value',get_tlistval_name(i.codlist,v_value,global_v_lang));
        obj_data.put('column_value_n',get_tlistval_name(i.codlist,v_value_n,global_v_lang));
      else
        obj_data.put('column_value',v_value);
        obj_data.put('column_value_n',v_value_n);
      end if;
      if nvl(v_value,'$!#@') <> nvl(v_value_n,'$!#@') then
        obj_data.put('n_value_flg','Y');
      else
        obj_data.put('n_value_flg','N');
      end if;
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

      begin
        execute immediate ' select ''N'' from tempothr where '||i.column_name||' is not null and rownum = 1' INTO v_flg_delete;
      exception when others then
        v_flg_delete   := 'Y';
      end;
      obj_data.put('flg_delete',v_flg_delete);  --N-cannot Delete (disable icon Trash) ,Y-can Delete

      obj_row.put(to_char(v_rowcnt - 1), obj_data);
    end loop;
    json_str_output   := obj_row.to_clob;
  end;
  --
  procedure get_others_data(json_str in clob, json_str_output out clob) is
  begin
    initial_value(json_str);
    if param_msg_error is null then
      gen_others_data(json_str_output);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/

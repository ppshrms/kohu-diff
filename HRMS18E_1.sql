--------------------------------------------------------
--  DDL for Package Body HRMS18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS18E" is

  procedure initial_value(json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    --global
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_codempid   := hcm_util.get_string_t(json_obj,'p_codempidQuery');
    p_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codcalen   := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_month      := hcm_util.get_string_t(json_obj,'p_month');
    p_year       := hcm_util.get_string_t(json_obj,'p_year');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_token varchar2(4 char);
  begin
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
          return;
        end if;
    end if;

    if p_codcalen is not null then
      begin
        select codcodec
          into v_token
          from tcodwork
         where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
        return;
      end;
    end if;
  end;

  procedure check_save is
    v_start	        date;
    v_end	          date;
  begin
    if v_stdate is null or v_endate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

--    if v_codshift is null then
--      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--      return;
--    end if;

    if v_codshift is not null then
        begin
          select codshift,timstrtw,timendw
          into   v_codshift,v_timstrtw,v_timendw
          from   tshiftcd
          where  codshift = v_codshift;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang);
          return;
        end;
    end if;

    v_start := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
    v_end   := last_day(v_start);
    if v_stdate not between v_start and v_end then
      param_msg_error := get_error_msg_php('HR2041',global_v_lang,'stdate');
      return;
    end if;
    if v_stdate < to_char(sysdate, 'dd/mm/yyyy') then
      param_msg_error := get_error_msg_php('HR2041 ',global_v_lang,'stdate');
      return;
    end if;
    if v_endate not between v_start and v_end then
      param_msg_error := get_error_msg_php('HR2041',global_v_lang,'endate');
      return;
    end if;
    if v_stdate > v_endate then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'stdate > endate');
      return;
    end if;
  end;

  procedure check_addemp is
    v_codcalen    varchar2(100 char);
    v_codcomp     varchar2(100 char);
    v_total       number;
  begin
    if p_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid);
      if param_msg_error is not null then
          return;
      end if;
    end if;

    ---?????????????????????????? TATTENCE ?????????????? ??????? ---
    begin
      select count(*)
        into v_total
        from tattence
       where codempid = p_codempid
         and dtework  between v_stdate and v_endate;
    exception when no_data_found then
      v_total := 0;
    end;
    if v_total = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tattence');
    end if;
    -----------------------

   ---????????????????????????????????????????????????????????????????---
    begin
      select codcomp,codcalen
        into v_codcomp,v_codcalen
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      v_codcomp := null;
    end;
--    if hcm_util.get_codcomp_level(p_codcomp,1) <> get_tgrpwork_codcomp(v_codcomp,v_codcalen) then
    if p_codcomp <> get_tgrpwork_codcomp(v_codcomp,v_codcalen) then
      param_msg_error := get_error_msg_php('AL0063',global_v_lang);
    end if;
    -----------------------

    ---?????????????????? ???????????????????????????????---
    begin
      select count(codempid)
        into v_total
        from temploy1 a
       where get_tgrpwork_codcomp(get_tattence_codcomp(codempid,v_stdate,v_endate),null) = p_codcomp
         and exists(select codcalen
                      from tattence b
                     where a.codempid = b.codempid
                       and dtework between v_stdate and v_endate
                       and codcalen = p_codcalen)
         and codempid = p_codempid;
    exception when no_data_found then
      v_total := 0;
    end;
    if v_total > 0 then
      param_msg_error := get_error_msg_php('HR2005',global_v_lang,'codempid');
    end if;
    -----------------------
  end;

  procedure check_index_traditional is
  begin
    if p_year is null then
      param_msg_error  := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;

  procedure save_tlogtime (p_codempid in varchar2,
                           p_dtework  in date,
                           p_dteupd   in date) is

    v_dtestrtw_o    tlogtime.dteoutnew%type;
    v_dteendw_o     tlogtime.dteoutnew%type;
    v_codchng_o     tlogtime.codchngold%type;
    v_codshift_o    tlogtime.codshifold%type;
    v_typwork_o     tlogtime.typworkold%type;

    v_dtestrtw      tlogtime.dteoutnew%type;
    v_dteendw       tlogtime.dteoutnew%type;
    v_codchng       tlogtime.codchngnew%type;
    v_codshift      tlogtime.codshifnew%type;
    v_typwork       tlogtime.typworknew%type;
    v_chk           number;
    v_dtein         date;
    v_dteout        date;

  begin
    if((nvl(to_char(tattence_dtestrtw),'!@#$') <> nvl(to_char(tattence_dtestrtw_o),'!@#$')) or
        (nvl(to_char(tattence_dteendw),'!@#$')  <> nvl(to_char(tattence_dteendw_o),'!@#$')) and
        (tattence_dtestrtw is not null and tattence_dtestrtw_o is not null and
        tattence_dteendw is not null and tattence_dteendw_o is not null)) or
        (nvl(tattence_typwork,'!@#$')  <> nvl(tattence_typwork_o,'!@#$')) or
        (nvl(tattence_codshift,'!@#$') <> nvl(tattence_codshift_o,'!@#$')) then

        -- if tattence_dtestrtw_o = tattence_dtestrtw then
        --   v_dtestrtw_o	:= null;
        --   v_dtestrtw	  := null;
        -- else
        --   v_dtestrtw_o := tattence_dtestrtw_o;
        --   v_dtestrtw   := tattence_dtestrtw;
        -- end if;

        -- if tattence_dteendw_o = tattence_dteendw then
        --   v_dteendw_o	:= null;
        --   v_dteendw		:= null;
        -- else
        --   v_dteendw_o	:= tattence_dteendw_o;
        --   v_dteendw		:= tattence_dteendw;
        -- end if;

        -- begin
        --   select dtein,dteout
        --     into v_dtein,v_dteout
        --     from tattence
        --    where codempid = p_codempid
        --      and dtework  = p_dtework;
        -- exception when no_data_found then
        --   v_dtein  := null;
        --   v_dteout := null;
        -- end;
        -- if v_dtein is null then
          v_dtestrtw_o      := null;
          v_dtestrtw        := null;
        -- end if;
        -- if v_dteout is null then
          v_dteendw_o       := null;
          v_dteendw         := null;
        -- end if;

        -- codshif
        if tattence_codshift_o = tattence_codshift then
          v_codshift_o	:= null;
          v_codshift		:= null;
        else
          v_codshift_o	:= tattence_codshift_o;
          v_codshift		:= tattence_codshift;
        end if;

        if tattence_typwork_o = tattence_typwork then
          v_typwork_o   := null;
          v_typwork     := null;
        else
          v_typwork_o   := tattence_typwork_o;
          v_typwork     := tattence_typwork;
        end if;

        --codchng
        v_codchng_o     := null;
        v_codchng       := null;
        --  if tattence_codchng_o = tattence_codchng then
        --    v_codchng_o	:= null;
        --    v_codchng		:= null;
        --  else
        --    v_codchng_o	:= tattence_codchng_o;
        --    v_codchng		:= tattence_codchng;
        --  end if;

        begin
          select count(*) into v_chk
          from tlogtime
          where codempid = p_codempid
          and dtework = p_dtework
          and dteupd = p_dteupd;
        exception when no_data_found then
          v_chk := 0;
        end;

        if v_chk = 0 then
          insert into tlogtime(codempid,dtework,dteupd,codcreate,
                               codshift,coduser,codcomp,
                               dteinold,dteoutold,codchngold,codshifold,typworkold,
                               dteinnew,dteoutnew,codchngnew,codshifnew,typworknew)
                        values(p_codempid,p_dtework,sysdate,global_v_coduser,
                               tattence_codshift,global_v_coduser,tattence_codcomp,
                               v_dtestrtw_o,v_dteendw_o,v_codchng_o,v_codshift_o,v_typwork_o,
                               v_dtestrtw,v_dteendw,v_codchng,v_codshift,v_typwork);
        else
          update tlogtime set
                  codshift   = tattence_codshift,
                  coduser    = global_v_coduser,
                  codcomp    = tattence_codcomp,
                  codchngold = v_codchng_o,
                  codshifold = v_codshift_o,
                  typworkold = v_typwork_o,
                  codchngnew = v_codchng,
                  codshifnew = v_codshift,
                  typworknew = v_typwork
                where codempid = p_codempid
                and dtework = p_dtework
                and dteupd = sysdate;
        end if;
        commit;
    end if;
  end save_tlogtime;

  procedure get_groupplan(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_stdate      date;
    v_endate      date;
    v_total       number := 0;
    v_row         number := 0;
    v_day         number := 0;
    o_codcalen    varchar2(400 char) := '!@#$';
    o_codcomp     varchar2(400 char) := '!@#$';
    v_first       boolean := true;
    v_desc_codcalen varchar2(4000 char) := '';
    v_codcomp     varchar2(400 char);
    v_codcalen    varchar2(400 char);
	cursor c_tgrpplan is
    select codcomp,codcalen
          from tgrpplan p
--         where(codcomp||'%' like p_codcomp||'%' or p_codcomp||'%' like codcomp||'%')
         where codcomp like p_codcomp||'%'
           and codcalen = nvl(p_codcalen,codcalen)
           and dtework between v_stdate and v_endate
      group by codcomp,codcalen
      order by codcomp,codcalen;

  cursor c_tgrpplan2 is
    select codcomp,dtework,codcalen,typwork,codshift
        from tgrpplan
       where codcomp 	= v_codcomp
         and codcalen = v_codcalen
         and dtework  between v_stdate and v_endate
    group by codcomp,dtework,codcalen,typwork,codshift
    order by dtework;

  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      obj_row  := json_object_t();
      v_stdate := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
      v_endate := last_day(v_stdate);

      for r1 in c_tgrpplan loop
        v_total := 1;
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, r1.codcomp);
        if param_msg_error is not null then
          exit;
        end if;
        v_codcomp  := r1.codcomp;
        v_codcalen := r1.codcalen;
        if r1.codcomp <> o_codcomp then
          o_codcalen := '!@#$';
          v_day := 0;
          v_first := true;
        end if;
        for r2 in c_tgrpplan2 loop
          v_day := v_day + 1;
          if r2.codcalen <> o_codcalen then
            if v_first = false then
              obj_row.put(to_char(v_row-1),obj_data);
            end if;
            v_first := false;
            v_row := v_row + 1;
            v_day := 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('codcomp', nvl(r2.codcomp, ''));
            obj_data.put('desc_codcomp', get_tcenter_name(r2.codcomp, global_v_lang));
            obj_data.put('codcalen', nvl(r2.codcalen, ''));
            begin
              select decode(global_v_lang, '101', descode,
                                           '102', descodt,
                                           '103', descod3,
                                           '104', descod4,
                                           '105', descod5,
                                                  descode)
                into v_desc_codcalen
                from tcodwork
               where codcodec = r2.codcalen;
            exception when no_data_found then
              v_desc_codcalen := '';
            end;
            obj_data.put('desc_codcalen', nvl(v_desc_codcalen, ''));
          end if;
          obj_data.put('month', lpad(to_char(p_month),2,'0'));
          obj_data.put('year', p_year);
          obj_data.put('typwork'||lpad(to_char(v_day),2,'0'), nvl(r2.typwork, ''));
          obj_data.put('codshift'||lpad(to_char(v_day),2,'0'), nvl(r2.codshift, ''));
          o_codcalen := r2.codcalen;
          o_codcomp  := r2.codcomp;
        end loop;
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
      json_str_output := obj_row.to_clob;
    end if;

    if param_msg_error is null and v_total = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TGRPPLAN');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    elsif param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_groupemp(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_stdate		  date;
    v_endate		  date;
    v_codempid    varchar2(100 char);
    v_total       number := 0;
    v_row         number := 0;
    v_day         number := 0;
    o_codempid    varchar2(400 char) := '!@#$';
    v_first       boolean := true;
    v_date        date;
    v_dteempmt    date;
    v_dteeffex    date;
    v_log_edit    varchar2(1 char);

	cursor c_temploy1 is
    select codempid,codcomp,numlvl
      from temploy1 a
     where get_tgrpwork_codcomp(get_tattence_codcomp(codempid,v_stdate,v_endate),null) = p_codcomp
       and exists(select codcalen
                    from tattence b
                   where a.codempid = b.codempid
                     and dtework between v_stdate and v_endate
                     and codcalen = p_codcalen)
  order by codempid;

  cursor c_tattence is
    select codcomp,dtework,codcalen,typwork,codshift
        from tattence
       where codempid = v_codempid
         and dtework  between v_stdate and v_endate
    order by dtework;

  begin
    initial_value(json_str_input);
    check_index;

    if param_msg_error is null then
      obj_row  := json_object_t();
      v_stdate := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
      v_endate := last_day(v_stdate);

      for r1 in c_temploy1 loop
        param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, r1.codempid);
        if param_msg_error is null then
          v_codempid  := r1.codempid;
          for r2 in c_tattence loop
            v_day := v_day + 1;
            if r1.codempid <> o_codempid then
              if v_first = false then
                obj_row.put(to_char(v_row-1),obj_data);
              end if;
              v_first := false;
              v_row := v_row + 1;
              v_day := 1;
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('codempid',v_codempid);
              obj_data.put('desc_codempid',get_temploy_name(v_codempid,global_v_lang));
              obj_data.put('codcomp',r2.codcomp);
              begin
                select dteempmt,dteeffex
                  into v_dteempmt,v_dteeffex
                  from temploy1
                 where codempid = v_codempid;
              exception when no_data_found then
                v_dteempmt := null;
                v_dteeffex := null;
              end;
              obj_data.put('dteempmt',to_char(v_dteempmt,'dd/mm/yyyy'));
              obj_data.put('dteeffex',to_char(v_dteeffex,'dd/mm/yyyy'));
              v_date := v_stdate;
              loop
                obj_data.put('month', lpad(to_char(p_month),2,'0'));
                obj_data.put('year', p_year);
                obj_data.put('codcalen', p_codcalen);
                obj_data.put('codcalen'||to_char(v_date,'dd'),'');
                obj_data.put('typwork'||to_char(v_date,'dd'),'');
                obj_data.put('codshift'||to_char(v_date,'dd'),'');
                v_log_edit      := get_log_exists(v_codempid, v_date);
                obj_data.put('flglog'||to_char(v_date,'dd'), v_log_edit);
              exit when v_date = v_endate;
                v_date := v_date+1;
              end loop;
            end if;
            obj_data.put('month', lpad(to_char(p_month),2,'0'));
            obj_data.put('year', p_year);
            obj_data.put('codcalen'||to_char(r2.dtework,'dd'),nvl(r2.codcalen, ''));
            obj_data.put('typwork'||to_char(r2.dtework,'dd'),nvl(r2.typwork, ''));
            obj_data.put('codshift'||to_char(r2.dtework,'dd'),nvl(r2.codshift, ''));
            o_codempid := v_codempid;
          end loop;
          obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return ;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_addemp(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    v_codempid    varchar2(100 char);
    v_row         number := 0;
    v_day         number := 0;
    o_codempid    varchar2(400 char) := '!@#$';
    v_date        date;
    v_codcalen    varchar2(100 char);
    v_typwork     varchar2(100 char);
    v_codshift    varchar2(100 char);
    v_dteempmt    date;
    v_dteeffex    date;
    v_codcomp     varchar2(100 char);

	cursor c1 is
    select codcomp,dtework,codcalen,typwork,codshift
      from tattence
     where codempid = p_codempid
       and dtework  between v_stdate and v_endate
  order by dtework;

  cursor c2 is
    select codcomp,dtework,codcalen,typwork,codshift
      from tgrpplan
     where codcomp 	= p_codcomp
       and codcalen = p_codcalen
       and dtework  between v_stdate and v_endate
  group by codcomp,dtework,codcalen,typwork,codshift
  order by dtework;

  begin
    initial_value(json_str_input);
    v_stdate := to_date('01/'||p_month||'/'||to_char(p_year),'dd/mm/yyyy');
    v_endate := last_day(v_stdate);
    check_addemp;

    if param_msg_error is null then
      obj_row  := json_object_t();

      for r1 in c1 loop
        if r1.dtework >= sysdate then
          for r2 in c2 loop
            if r1.dtework = r2.dtework  then
              v_codcalen := r2.codcalen;
              v_typwork  := r2.typwork;
              v_codshift := r2.codshift;
            end if;
          end loop;
        else
          v_codcalen := r1.codcalen;
          v_typwork  := r1.typwork;
          v_codshift := r1.codshift;
        end if;

        v_day := v_day + 1;
        if p_codempid <> o_codempid then
          v_row := v_row + 1;
          v_day := 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codempid',p_codempid);
          obj_data.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
          obj_data.put('codcomp',r1.codcomp);
          begin
            select dteempmt,dteeffex
              into v_dteempmt,v_dteeffex
              from temploy1
             where codempid = p_codempid;
          exception when no_data_found then
            v_dteempmt := null;
            v_dteeffex := null;
          end;
          obj_data.put('dteempmt',to_char(v_dteempmt,'dd/mm/yyyy'));
          obj_data.put('dteeffex',to_char(v_dteeffex,'dd/mm/yyyy'));
          v_date := v_stdate;
          loop
            obj_data.put('month', lpad(to_char(p_month),2,'0'));
            obj_data.put('year', p_year);
            obj_data.put('codcalen'||to_char(v_date,'dd'),'');
            obj_data.put('typwork'||to_char(v_date,'dd'),'');
            obj_data.put('codshift'||to_char(v_date,'dd'),'');
          exit when v_date = v_endate;
            v_date := v_date+1;
          end loop;
        end if;
        obj_data.put('month', lpad(to_char(p_month),2,'0'));
        obj_data.put('year', p_year);
        obj_data.put('codcalen'||to_char(r1.dtework,'dd'),nvl(v_codcalen, ''));
        obj_data.put('typwork'||to_char(r1.dtework,'dd'),nvl(v_typwork, ''));
        obj_data.put('codshift'||to_char(r1.dtework,'dd'),nvl(v_codshift, ''));
        o_codempid := p_codempid;
      end loop;
      obj_row.put(to_char(v_row-1),obj_data);
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_groupplan(json_str_input  in clob,json_str_output out clob) is
    json_obj      json_object_t := json_object_t(json_str_input);
    param_json    json_object_t;
    v_day         json_object_t;
    v_codempid    varchar2(10);
    v_dtestrtw    date;
    v_dteendw     date;
    v_secur			  boolean;
    v_flgdh       varchar2(1);
    v_mon         varchar2(3);
    v_tue         varchar2(3);
    v_wed         varchar2(3);
    v_thu         varchar2(3);
    v_fri         varchar2(3);
    v_sat         varchar2(3);
    v_sun         varchar2(3);
    v_typwork     varchar2(1);
    p_day1        varchar2(1);
    p_day2        varchar2(1);
    p_day3        varchar2(1);
    p_day4        varchar2(1);
    p_day5        varchar2(1);
    p_day6        varchar2(1);
    p_day7        varchar2(1);

    v_temp     varchar2(100);
    v_tmp_check     varchar2(1000 char);
    json_dtestrtw   json_object_t := json_object_t();
    json_dteendw    json_object_t := json_object_t();
    json_typwork    json_object_t := json_object_t();
    json_codshift   json_object_t := json_object_t();

  cursor c_tgrpplan is
		select dtework,typwork,codshift
		  from tgrpplan
		 where codcomp  = p_codcomp
		   and codcalen = p_codcalen
		   and dtework 	between v_stdate and v_endate
	order by dtework;

  cursor c1 is
    select a.codempid,a.codcomp,a.dtework,a.codcalen,a.typwork,a.codshift,b.numlvl,to_char(dtework,'dy') daynam
		  from tattence a,temploy1 b
		 where a.codempid = b.codempid
       and a.codcomp  = p_codcomp
       and a.codcalen = p_codcalen
       and a.dtework between v_stdate and v_endate;

  cursor c_old_tattence is
    select codempid, dtework, codcalen, codcomp, dtestrtw, dteendw, typwork, codshift, codempid||to_char(dtework, 'yyyymmdd') key_check
      from tattence
     where codcomp  like p_codcomp || '%'
       and codcalen = p_codcalen
       and dtework between v_stdate and v_endate;

  begin
    initial_value(json_str_input);

    v_stdate   := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteworkf')),'dd/mm/yyyy');
    v_endate   := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteworkt')),'dd/mm/yyyy');
    v_codshift := hcm_util.get_string_t(json_obj,'p_codshift');
    v_flgdh    := hcm_util.get_string_t(json_obj,'p_flgdh');
    v_flglog   := hcm_util.get_string_t(json_obj,'p_flglog');
    param_json := hcm_util.get_json_t(json_obj,'json_input_str');
    v_day      := hcm_util.get_json_t(param_json,to_char(0));
    v_mon      := hcm_util.get_string_t(v_day,'mon');
    v_tue      := hcm_util.get_string_t(v_day,'tue');
    v_wed      := hcm_util.get_string_t(v_day,'wed');
    v_thu      := hcm_util.get_string_t(v_day,'thu');
    v_fri      := hcm_util.get_string_t(v_day,'fri');
    v_sat      := hcm_util.get_string_t(v_day,'sat');
    v_sun      := hcm_util.get_string_t(v_day,'sun');

    check_save;

    if param_msg_error is null then
      if v_mon = 'Y' then p_day2 := '2'; else p_day2 := ''; end if;
      if v_tue = 'Y' then p_day3 := '3'; else p_day3 := ''; end if;
      if v_wed = 'Y' then p_day4 := '4'; else p_day4 := ''; end if;
      if v_thu = 'Y' then p_day5 := '5'; else p_day5 := ''; end if;
      if v_fri = 'Y' then p_day6 := '6'; else p_day6 := ''; end if;
      if v_sat = 'Y' then p_day7 := '7'; else p_day7 := ''; end if;
      if v_sun = 'Y' then p_day1 := '1'; else p_day1 := ''; end if;

      for r1 in c_old_tattence loop
        json_dtestrtw.put(r1.key_check, r1.dtestrtw);
        json_dteendw.put(r1.key_check, r1.dteendw);
        json_typwork.put(r1.key_check, r1.typwork);
        json_codshift.put(r1.key_check, r1.codshift);
      end loop;

      if v_flgdh = 'Y' then
        update tgrpplan
           set typwork  = 'W',
               coduser  = global_v_coduser,
               dteupd   = trunc(sysdate)
         where codcomp	= p_codcomp
           and codcalen = p_codcalen
           and dtework  between v_stdate and v_endate
           and typwork  = 'H';

        update tgrpplan
           set typwork  = 'H',
               coduser  = global_v_coduser,
               dteupd   = trunc(sysdate)
         where codcomp	= p_codcomp
           and codcalen = p_codcalen
           and dtework  between v_stdate and v_endate
           and typwork  = 'W'
           and to_number(to_char(to_date(lpad(to_char(dtework,'dd'),2,'0')||'/' ||
               to_char(dtework,'mm/yyyy'),'dd/mm/yyyy'),'d'))
            in (p_day2,p_day3,p_day4,p_day5,p_day6,p_day7,p_day1);

          for r1 in c1 loop -- update table2
            v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
            if v_secur then
              for i in c_tgrpplan loop
                update tattence
                   set typwork  = i.typwork,
                       coduser  = global_v_coduser,
                       dteupd   = trunc(sysdate)
                 where codempid = r1.codempid
                   and dtework  = i.dtework
                   and typwork	<> 'L'
                   and (not exists (select tlogtime.codempid
                                      from tlogtime
                                     where tlogtime.codempid = tattence.codempid
                                       and tlogtime.dtework = tattence.dtework)
                        or v_flglog = 'Y'
                        );
              end loop;
            end if;
          end loop; -- end update table2
      end if;

      if v_codshift is not null or v_codshift <> '' then
        update tgrpplan
           set codshift = v_codshift,
               coduser  = global_v_coduser,
               dteupd   = trunc(sysdate)
         where codcomp	= p_codcomp
           and codcalen = p_codcalen
           and dtework  between v_stdate and v_endate;

        for r1 in c1 loop -- update table2
          v_secur := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if v_secur then
            for i in c_tgrpplan loop
              update tattence
                 set codshift = i.codshift,
                     coduser  = global_v_coduser,
                     dteupd   = trunc(sysdate)
               where codempid = r1.codempid
                 and dtework  = i.dtework
                 and typwork	<> 'L'
                 and (not exists (select tlogtime.codempid
                                    from tlogtime
                                   where tlogtime.codempid = tattence.codempid
                                     and tlogtime.dtework = tattence.dtework)
                      or v_flglog = 'Y'
                      );
            end loop;
          end if;
        end loop; -- end update table2
      end if;
      for r1 in c_old_tattence loop
        begin
          select codcomp,typwork,codshift,dtestrtw,dteendw, codempid||to_char(dtework, 'yyyymmdd')
            into tattence_codcomp,tattence_typwork,tattence_codshift,tattence_dtestrtw,tattence_dteendw,v_tmp_check
            from tattence
           where codempid = r1.codempid
             and codcomp like r1.codcomp||'%'
             and codcalen = r1.codcalen
             and dtework  = r1.dtework;
        exception when no_data_found then
          tattence_typwork  := null;
          tattence_codshift := null;
          tattence_dtestrtw := null;
          tattence_dteendw  := null;
        end;
        tattence_dtestrtw_o := hcm_util.get_string_t(json_dtestrtw, v_tmp_check);
        tattence_dteendw_o  := hcm_util.get_string_t(json_dteendw, v_tmp_check);
        tattence_typwork_o  := hcm_util.get_string_t(json_typwork, v_tmp_check);
        tattence_codshift_o := hcm_util.get_string_t(json_codshift, v_tmp_check);
        save_tlogtime(r1.codempid, r1.dtework, sysdate);
      end loop;
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;

  procedure save_groupemp(json_str_input  in clob,json_str_output out clob) is
    json_obj      json_object_t := json_object_t(json_str_input);
    json_obj2     json_object_t;
    param_json1   json_object_t;
    param_json2   json_object_t;
    v_day         json_object_t;
    v_dtestrtw    date;
    v_dteendw     date;
    v_secur			  boolean;
    v_flgdh       varchar2(1);
    v_mon         varchar2(3);
    v_tue         varchar2(3);
    v_wed         varchar2(3);
    v_thu         varchar2(3);
    v_fri         varchar2(3);
    v_sat         varchar2(3);
    v_sun         varchar2(3);
    v_typwork     varchar2(1);
    p_day1        varchar2(1);
    p_day2        varchar2(1);
    p_day3        varchar2(1);
    p_day4        varchar2(1);
    p_day5        varchar2(1);
    p_day6        varchar2(1);
    p_day7        varchar2(1);

    v_tmp_check    varchar2(1000 char);
    json_dtestrtw   json_object_t := json_object_t();
    json_dteendw    json_object_t := json_object_t();
    json_typwork    json_object_t := json_object_t();
    json_codshift   json_object_t := json_object_t();

  cursor c_old_tattence is
    select codempid, dtework, codcalen, codcomp, dtestrtw, dteendw, typwork, codshift, codempid||to_char(dtework, 'yyyymmdd') key_check
      from tattence
     where codempid = p_codempid
       and codcomp  = p_codcomp
       and codcalen = p_codcalen
       and dtework between v_stdate and v_endate;

  begin
    initial_value(json_str_input);
    v_stdate   := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteworkf')),'dd/mm/yyyy');
    v_endate   := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteworkt')),'dd/mm/yyyy');
    v_codshift := hcm_util.get_string_t(json_obj,'p_codshift');
    v_flgdh    := hcm_util.get_string_t(json_obj,'p_flgdh');
    v_flglog   := hcm_util.get_string_t(json_obj,'p_flglog');
    param_json1 := hcm_util.get_json_t(json_obj, 'json_input_str1');
    v_day      := hcm_util.get_json_t(param_json1,to_char(0));
    v_mon      := hcm_util.get_string_t(v_day,'mon');
    v_tue      := hcm_util.get_string_t(v_day,'tue');
    v_wed      := hcm_util.get_string_t(v_day,'wed');
    v_thu      := hcm_util.get_string_t(v_day,'thu');
    v_fri      := hcm_util.get_string_t(v_day,'fri');
    v_sat      := hcm_util.get_string_t(v_day,'sat');
    v_sun      := hcm_util.get_string_t(v_day,'sun');

    check_save;

    if param_msg_error is null then
      if v_mon = 'Y' then p_day2 := '2'; else p_day2 := ''; end if;
      if v_tue = 'Y' then p_day3 := '3'; else p_day3 := ''; end if;
      if v_wed = 'Y' then p_day4 := '4'; else p_day4 := ''; end if;
      if v_thu = 'Y' then p_day5 := '5'; else p_day5 := ''; end if;
      if v_fri = 'Y' then p_day6 := '6'; else p_day6 := ''; end if;
      if v_sat = 'Y' then p_day7 := '7'; else p_day7 := ''; end if;
      if v_sun = 'Y' then p_day1 := '1'; else p_day1 := ''; end if;


      param_json2 := hcm_util.get_json_t(json_obj, 'json_input_str2');
      for i in 0..param_json2.get_size-1 loop
        json_obj2   := hcm_util.get_json_t(param_json2,to_char(i));
        p_codempid  := hcm_util.get_string_t(json_obj2, 'codempid');
        p_codcomp   := hcm_util.get_string_t(json_obj2, 'codcomp');
        p_codcalen  := hcm_util.get_string_t(json_obj2, 'codcalen');

        for r1 in c_old_tattence loop
          json_dtestrtw.put(r1.key_check, r1.dtestrtw);
          json_dteendw.put(r1.key_check, r1.dteendw);
          json_typwork.put(r1.key_check, r1.typwork);
          json_codshift.put(r1.key_check, r1.codshift);
        end loop;

        if v_flgdh = 'Y' then
          update tattence
             set typwork  = 'W',
                 coduser  = global_v_coduser,
                 dteupd   = trunc(sysdate)
           where codempid = p_codempid
             and dtework  between v_stdate and v_endate
             and typwork 	= 'H'
             and (not exists (select tlogtime.codempid
                                from tlogtime
                               where tlogtime.codempid = tattence.codempid
                                 and tlogtime.dtework = tattence.dtework)
                  or v_flglog = 'Y'
                  );

          update tattence
             set typwork  = 'H',
                 coduser  = global_v_coduser,
                 dteupd   = trunc(sysdate)
           where codempid = p_codempid
             and dtework  between v_stdate and v_endate
             and typwork 	= 'W'
             and to_number(to_char(to_date(lpad(to_char(dtework,'dd'),2,'0')||'/' ||
                 to_char(dtework,'mm/yyyy'),'dd/mm/yyyy'),'d'))
              in (p_day2,p_day3,p_day4,p_day5,p_day6,p_day7,p_day1)
             and (not exists (select tlogtime.codempid
                                from tlogtime
                               where tlogtime.codempid = tattence.codempid
                                 and tlogtime.dtework = tattence.dtework)
                  or v_flglog = 'Y'
                  );
        end if;

        if v_codshift is not null or v_codshift <> '' then
          update tattence
             set codshift = v_codshift,
                 coduser  = global_v_coduser,
                 dteupd   = trunc(sysdate)
           where codempid = p_codempid
             and dtework  between v_stdate and v_endate
             and typwork <> 'L'
             and (not exists (select tlogtime.codempid
                                from tlogtime
                               where tlogtime.codempid = tattence.codempid
                                 and tlogtime.dtework = tattence.dtework)
                  or v_flglog = 'Y'
                  );
        end if;
        for r1 in c_old_tattence loop
          begin
            select codcomp,typwork,codshift,dtestrtw,dteendw, codempid||to_char(dtework, 'yyyymmdd')
              into tattence_codcomp,tattence_typwork,tattence_codshift,tattence_dtestrtw,tattence_dteendw,v_tmp_check
              from tattence
             where codempid = r1.codempid
               and codcomp like r1.codcomp||'%'
               and codcalen = r1.codcalen
               and dtework  = r1.dtework;
          exception when no_data_found then
            tattence_typwork  := null;
            tattence_codshift := null;
            tattence_dtestrtw := null;
            tattence_dteendw  := null;
          end;
          tattence_dtestrtw_o := hcm_util.get_string_t(json_dtestrtw, v_tmp_check);
          tattence_dteendw_o  := hcm_util.get_string_t(json_dteendw, v_tmp_check);
          tattence_typwork_o  := hcm_util.get_string_t(json_typwork, v_tmp_check);
          tattence_codshift_o := hcm_util.get_string_t(json_codshift, v_tmp_check);
          save_tlogtime(r1.codempid, r1.dtework, sysdate);
        end loop;
      end loop; -- end json_obj loop
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;

  procedure index_save(json_str_input in clob,json_str_output out clob) is
    json_objp     json_object_t := json_object_t(json_str_input);
    json_objd     json_object_t;
    json_objt1    json_object_t;
    json_obj1     json_object_t;
    json_objt2    json_object_t;
    json_obj2     json_object_t;
    v_month       number;
    v_year        number;
    v_dtework	    date;
    v_codshift    varchar2(10 char);
    v_typwork     varchar2(1 char);
    v_timstrtw    varchar2(10 char);
    v_timendw     varchar2(10 char);
    v_dtestrtw    date;
    v_dteendw     date;
    v_secur			  boolean;
    p_flg         varchar2(10 char);
    v_codcomp     varchar2(4000 char);
    v_codempmt    varchar2(4000 char);
    v_flgatten    varchar2(4000 char);
    v_typpayroll  varchar2(4000 char);
    v_temp        varchar2(4000 char);

    objResponse     json_object_t;
    v_msg_response  varchar2(1000 char);
  begin
    initial_value(json_str_input);
    --json_objd  := json(json_objp.get(to_char('detail')));
    v_month    := to_number(hcm_util.get_string_t(json_objp,'month'));
    v_year     := to_number(hcm_util.get_string_t(json_objp,'year'));
    p_codcalen := hcm_util.get_string_t(json_objp,'codcalen');
--    json_objt1 := json(hcm_util.get_string_t(json_objp,'json_input_str1'));
    json_objt1 := hcm_util.get_json_t(json_objp,'json_input_str1');
    for i in 0..json_objt1.get_size-1 loop
      json_obj1  := hcm_util.get_json_t(json_objt1,to_char(i));
      p_codcalen := hcm_util.get_string_t(json_obj1,'codcalen');
      p_codcomp  := hcm_util.get_string_t(json_obj1,'codcomp');
      v_codshift       := hcm_util.get_string_t(json_obj1,'codshift');
      for v_day in 1..31 loop
        v_typwork        := hcm_util.get_string_t(json_obj1,'typwork'||lpad(to_char(v_day), 2, '0'));
        v_codshift       := hcm_util.get_string_t(json_obj1,'codshift'||lpad(to_char(v_day), 2, '0'));
        -- validate
        if v_codshift is not null then
          begin
            select codshift
              into v_temp
              from tshiftcd
             where codshift = v_codshift;
          exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tshiftcd');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end;
          begin
            select codshift
              into v_temp
              from tshifcom
             where codshift = v_codshift
               and codcompy = hcm_util.get_codcomp_level(p_codcomp,'1');
          exception when no_data_found then
            param_msg_error := get_error_msg_php('AL0061',global_v_lang,'tshifcom');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
          end;
        end if;

        if v_typwork is not null or v_codshift is not null then
          v_dtework := to_date(lpad(to_char(v_day), 2, '0')||'/'||lpad(to_char(v_month), 2, '0')||'/'||to_char(v_year), 'dd/mm/yyyy');
          update tgrpplan
             set codshift = nvl(v_codshift, codshift),
                 typwork  = nvl(v_typwork, typwork),
                 coduser  = global_v_coduser
           where codcomp like p_codcomp||'%'
             and dtework  = v_dtework
             and codcalen = p_codcalen;
        end if;
      end loop;
    end loop;

--    json_objt2 := json(hcm_util.get_string_t(json_objp,'json_input_str2'));
    json_objt2 := hcm_util.get_json_t(json_objp,'json_input_str2');
    for i in 0..json_objt2.get_size-1 loop
      json_obj2    := hcm_util.get_json_t(json_objt2,to_char(i));
      p_codempid   := hcm_util.get_string_t(json_obj2,'codempid');
      v_codcomp    := hcm_util.get_string_t(json_obj2,'codcomp');
      p_flg        := hcm_util.get_string_t(json_obj2,'flg');
      for v_day in 1..31 loop
        v_typwork  := hcm_util.get_string_t(json_obj2,'typwork'||lpad(to_char(v_day), 2, '0'));
        v_codshift := hcm_util.get_string_t(json_obj2,'codshift'||lpad(to_char(v_day), 2, '0'));

        if v_typwork is not null or v_codshift is not null then
          v_dtework := to_date(lpad(to_char(v_day), 2, '0')||'/'||lpad(to_char(v_month), 2, '0')||'/'||to_char(v_year), 'dd/mm/yyyy');
          v_msg_response := ' [' || p_codempid || ' - ' || get_temploy_name(p_codempid, global_v_lang) || ' ' || to_char(v_dtework, 'dd/mm/') || (to_number(to_char(v_dtework, 'yyyy')) + hcm_appsettings.get_additional_year) || ']';
          if v_codshift is not null then
            begin
              select codshift,timstrtw,timendw
              into   v_codshift,v_timstrtw,v_timendw
              from   tshiftcd
              where  codshift = v_codshift;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tshiftcd');
              -- json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              objResponse     := json_object_t(get_response_message(null,param_msg_error,global_v_lang));
              objResponse.put('response', hcm_util.get_string_t(objResponse, 'response') || v_msg_response);
              json_str_output := objResponse.to_clob;
              return;
            end;
            begin
              select codshift
                into v_temp
                from tshifcom
               where codshift = v_codshift
                 and codcompy = hcm_util.get_codcomp_level(v_codcomp,'1');
            exception when no_data_found then
              param_msg_error := get_error_msg_php('AL0061',global_v_lang,'tshifcom');
              -- json_str_output := get_response_message(null,param_msg_error,global_v_lang);
              objResponse     := json_object_t(get_response_message(null,param_msg_error,global_v_lang));
              objResponse.put('response', hcm_util.get_string_t(objResponse, 'response') || v_msg_response);
              json_str_output := objResponse.to_clob;
              return;
            end;
            v_dtestrtw := v_dtework;
            if v_timstrtw < v_timendw then
              v_dteendw := v_dtestrtw;
            else
              v_dteendw := v_dtestrtw + 1;
            end if;
          else
            v_dtestrtw := null;
            v_dteendw  := null;
            v_timstrtw := null;
            v_timendw  := null;
          end if;

          if p_flg = 'edit' then
            ------------ find old value for log --------------
            begin
              select codcomp,typwork,codshift,dtestrtw,dteendw
                into tattence_codcomp,tattence_typwork_o,tattence_codshift_o,tattence_dtestrtw_o,tattence_dteendw_o
                from tattence
               where codempid = p_codempid
                 and codcomp like v_codcomp||'%'
                 and codcalen = p_codcalen
                 and dtework  = v_dtework;
            exception when no_data_found then
              tattence_typwork_o  := null;
              tattence_codshift_o := null;
              tattence_dtestrtw_o := null;
              tattence_dteendw_o  := null;
            end;
            tattence_dtestrtw := v_dtestrtw;
            tattence_dteendw  := v_dteendw;
            if v_codshift is null then
              tattence_codshift := tattence_codshift_o;
            else
              tattence_codshift := v_codshift;
            end if;
            if v_typwork is null then
              tattence_typwork  := tattence_typwork_o;
            else
              tattence_typwork  := v_typwork;
            end if;
            ------------------------------------
            update tattence
               set codshift = nvl(v_codshift, codshift),
                   typwork  = nvl(v_typwork, typwork),
                   dtestrtw = nvl(v_dtestrtw, dtestrtw),
                   dteendw  = nvl(v_dteendw, dteendw),
                   timstrtw = nvl(v_timstrtw, timstrtw),
                   timendw  = nvl(v_timendw, timendw),
                   coduser  = global_v_coduser
             where codempid = p_codempid
               and dtework  = v_dtework;
            ------------ save log --------------
            save_tlogtime(p_codempid,v_dtework,sysdate);
            ------------------------------------
          end if;
       end if;
      end loop;
    end loop;
    commit;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;

  procedure get_traditional_days(json_str_input in clob,json_str_output out clob) is
    v_row     number := 0;

    cursor c1 is
      select dtedate, listagg(codcalen, ',') within group (order by dtedate) as codcalen
        from tgholidy
       where dteyear = p_year
         and codcomp = p_codcomp
         and codcalen = nvl(p_codcalen, codcalen)
         and typwork = 'T'
    group by dtedate;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    check_index;
    check_index_traditional;
    if param_msg_error is null then
      for r1 in c1 loop
        v_row := v_row + 1;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('year', to_char(r1.dtedate, 'yyyy'));
        obj_data.put('month', to_char(r1.dtedate, 'mm'));
        obj_data.put('day', to_char(r1.dtedate, 'dd'));
        obj_data.put('codcalen', nvl(r1.codcalen, ''));

        obj_row.put(to_char(v_row-1), obj_data);
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return ;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_shutdown_days(json_str_input in clob,json_str_output out clob) is
    v_row     number := 0;

    cursor c1 is
      select dtedate, listagg(codcalen, ',') within group (order by dtedate) as codcalen
        from tgholidy
       where dteyear = p_year
         and codcomp = p_codcomp
         and codcalen = nvl(p_codcalen, codcalen)
         and typwork = 'S'
    group by dtedate;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    check_index;
    check_index_traditional;
    if param_msg_error is null then
      for r1 in c1 loop
        v_row := v_row + 1;

        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('year', to_char(r1.dtedate, 'yyyy'));
        obj_data.put('month', to_char(r1.dtedate, 'mm'));
        obj_data.put('day', to_char(r1.dtedate, 'dd'));
        obj_data.put('codcalen', nvl(r1.codcalen, ''));

        obj_row.put(to_char(v_row-1), obj_data);
      end loop;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return ;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_log_exists (v_check_codempid varchar2, v_check_date date) return varchar2 is
    v_check_log       varchar2(1 char);
  begin
    begin
      select 'Y'
        into v_check_log
        from tlogtime
       where codempid = v_check_codempid
         and dtework = v_check_date
         and rownum <= 1;
    exception when no_data_found then
      v_check_log       := 'N';
    end;
    return v_check_log;
  end get_log_exists;

end HRMS18E;

/

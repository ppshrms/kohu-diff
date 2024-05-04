--------------------------------------------------------
--  DDL for Package Body HCM_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_MENU" is
  function set_url(p_url varchar2) return varchar2 is
    v_url   varchar2(4000 char);
  begin
    v_url := p_url;
    if v_url is not null then
      if instr(v_url, 'http://') <> '1' and instr(v_url, 'https://') <> '1' then
        v_url := 'http://'||v_url;
      end if;
    end if;
    return v_url;
  end;

  function check_url_permission(p_coduser varchar2,p_codproc varchar2) return boolean is
    v_flgauth     tusrproc.flgauth%type;
    v_secur       boolean := true;
  begin
    begin
      select flgauth
        into v_flgauth
        from tusrproc
       where codproc = upper(p_codproc)
         and coduser = upper(p_coduser);
    exception when no_data_found then
      v_flgauth := '1';
    end;

    if nvl(v_flgauth,'1') = '1' then
      v_secur := false;
    end if;

    return v_secur;
  end;

  function get_menu(p_coduser varchar2) return clob is
    obj_row           json_object_t;
    obj_data_module   json_object_t;
    obj_data1         json_object_t;
    obj_data2         json_object_t;
    obj_data3         json_object_t;
    obj_data4         json_object_t;
    obj_lv1           json_object_t;
    obj_lv2           json_object_t;
    obj_lv3           json_object_t;
    obj_lv4           json_object_t;
    obj_description   json_object_t;
    cnt_lv1           number;
    cnt_lv2           number;
    cnt_lv3           number;
    cnt_lv4           number;
    v_module          varchar2(4000 char);
    v_numseq1         number;
    v_numseq2         number;
    v_numseq3         number;
    v_numseq4         number;
    v_output          clob;
    v_typeuser        tusrprof.typeuser%type;
    v_codproc         tprocess.codproc%type;
    v_code            varchar2(4000 char);
    v_url             varchar2(4000 char);
    v_secur_module    boolean;
    v_secur_codapp    boolean;
    v_license         number := 0;
    p_type_license    varchar2(10 char);
    p_license         number;
    p_license_Emp     number;

    cursor c_modules is
       select a.codproc,
              decode(a.codproc, '1.RP', 'RP',
                                '2.RC', 'RC',
                                '3.PM', 'PM',
                                '4.AL', 'AL',
                                '5.BF', 'BF',
                                '6.PY', 'PY',
                                '7.AP', 'AP',
                                '8.TR', 'TR',
                                '9.ES', 'ES',
                                'A.MS', 'MS',
                                'B.EL', 'EL',
                                a.codproc) module,
              'menu' type,
              b.desproce desappe,
              b.desproct desappt,
              b.desproc3 desapp3,
              b.desproc4 desapp4,
              b.desproc5 desapp5,
              substr(a.codproc,-2) icon,
              b.codimage codimage
         from tusrproc a, tprocess b
        where a.codproc = b.codproc
          and a.coduser = upper(p_coduser)
          and (a.codproc in ('1.RP','2.RC','3.PM','4.AL','5.BF','6.PY','7.AP','8.TR','9.ES','A.MS','B.EL') or b.linkurl is null)
       order by a.codproc;

    cursor c_lv1 is
      select decode(substr(a.codapp,5,1), 'M', 'menu', 'function') type,
             a.numseq1,a.numseq2,a.numseq3,a.numseq4,a.codapp,a.desappe,a.desappt,a.desapp3,a.desapp4,a.desapp5,a.linkurl
        from tprocapp a,tusrproc b
       where a.codproc = b.codproc(+)
         and a.codproc = v_module
         and b.coduser = upper(p_coduser)
         and (a.linkurl is null or b.flgauth <> '1')
         and a.numseq2 = 0
         and a.numseq3 = 0
         and a.numseq4 = 0
      order by numseq1,numseq2,numseq3,numseq4;

    cursor c_lv2 is
      select decode(substr(a.codapp,5,1), 'M', 'menu', 'function') type,
             a.numseq1,a.numseq2,a.numseq3,a.numseq4,a.codapp,a.desappe,a.desappt,a.desapp3,a.desapp4,a.desapp5,a.linkurl
        from tprocapp a,tusrproc b
       where a.codproc = b.codproc(+)
         and a.codproc = v_module
         and b.coduser = upper(p_coduser)
         and (a.linkurl is null or b.flgauth <> '1')
         and a.numseq1 = v_numseq1
         and a.numseq3 = 0
         and a.numseq4 = 0
         and a.numseq1 <> 0
         and a.numseq2 <> 0
      order by numseq1,numseq2,numseq3,numseq4;

    cursor c_lv3 is
      select decode(substr(a.codapp,5,1), 'M', 'menu', 'function') type,
             a.numseq1,a.numseq2,a.numseq3,a.numseq4,a.codapp,a.desappe,a.desappt,a.desapp3,a.desapp4,a.desapp5,a.linkurl
        from tprocapp a,tusrproc b
       where a.codproc = b.codproc(+)
         and a.codproc = v_module
         and b.coduser = upper(p_coduser)
         and (a.linkurl is null or b.flgauth <> '1')
         and a.numseq1 = v_numseq1
         and a.numseq2 = v_numseq2
         and a.numseq4 = 0
         and a.numseq1 <> 0
         and a.numseq2 <> 0
         and a.numseq3 <> 0
      order by numseq1,numseq2,numseq3,numseq4;

    cursor c_language is
      select codlang,namabb
        from tlanguage;

    cursor c_linkurl is
       select a.codproc,
              'url' type,
              b.desproce desappe,
              b.desproct desappt,
              b.desproc3 desapp3,
              b.desproc4 desapp4,
              b.desproc5 desapp5,
              'url' icon,
              b.codimage codimage,
              b.linkurl url
         from tusrproc a, tprocess b
        where a.codproc = b.codproc
          and a.coduser = upper(p_coduser)
          and b.linkurl is not null
          and a.flgauth <> '1'
          and a.codproc not in ('1.RP','2.RC','3.PM','4.AL','5.BF','6.PY','7.AP','8.TR','9.ES','A.MS','B.EL')
       order by a.codproc;

  begin
    obj_row  := json_object_t();
    for r_modules in c_modules loop
      v_module := r_modules.codproc;

      if v_module in ('1.RP','2.RC','3.PM','4.AL','5.BF','6.PY','7.AP','8.TR','9.ES','A.MS','B.EL') then
        v_license := get_license('', substr(v_module,3,2));
        --<< license ess
        std_sc.get_license_Info(p_type_license, p_license, p_license_Emp);
        if v_module in ('9.ES','A.MS') and nvl(p_type_license,'1') = '2' then
            if p_license > 0 then -- has license
                v_license := p_license;
            end if;
        end if;
        -->> license ess
      else
        v_license := 999;
      end if;

      if v_license > 0 then
        obj_lv1 := json_object_t();
        cnt_lv1 := 0;
        for r_lv1 in c_lv1 loop -- menu expand level 1
          cnt_lv1 := cnt_lv1 + 1;
          obj_lv2 := json_object_t();
          cnt_lv2 := 0;
          v_numseq1 := r_lv1.numseq1;
          for r_lv2 in c_lv2 loop -- menu expand level 2
            cnt_lv2 := cnt_lv2 + 1;
            obj_lv3 := json_object_t();
            cnt_lv3 := 0;
            v_numseq2 := r_lv2.numseq2;
            for r_lv3 in c_lv3 loop -- menu expand level 3
              cnt_lv3 := cnt_lv3 + 1;
              obj_data3 := json_object_t();
              obj_data3.put('type', r_lv3.type);
              obj_data3.put('codproc', r_modules.codproc);

              -- set linkurl
              v_code := nvl(r_lv3.codapp,'');
              v_url  := '';
              if r_lv3.linkurl is not null then
                v_url  := set_url(r_lv3.linkurl);
                v_code := v_url;
              end if;
              obj_data3.put('code', v_code);
              obj_data3.put('url', v_url);

              obj_description := json_object_t();
              for r_language in c_language loop
                if r_language.codlang = '101' then
                  obj_description.put('en', r_lv3.desappe);
                elsif r_language.codlang = '102' then
                  obj_description.put('th', r_lv3.desappt);
                elsif r_language.codlang = '103' then
                  obj_description.put(lower(r_language.codlang), r_lv3.desapp3);
                elsif r_language.codlang = '104' then
                  obj_description.put(lower(r_language.codlang), r_lv3.desapp4);
                elsif r_language.codlang = '105' then
                  obj_description.put(lower(r_language.codlang), r_lv3.desapp5);
                end if;
              end loop;
              obj_data3.put('description', obj_description);
              obj_lv3.put(to_char(cnt_lv3-1), obj_data3);
            end loop; -- end menu expand level 3
            obj_data2 := json_object_t();
            obj_data2.put('type', r_lv2.type);
            obj_data2.put('codproc', r_modules.codproc);

            -- set linkurl
            v_code := nvl(r_lv2.codapp,'');
            v_url  := '';
            if r_lv2.linkurl is not null then
              v_url  := set_url(r_lv2.linkurl);
              v_code := v_url;
            end if;
            obj_data2.put('code', v_code);
            obj_data2.put('url', v_url);

            obj_description := json_object_t();
            for r_language in c_language loop
              if r_language.codlang = '101' then
                obj_description.put('en', r_lv2.desappe);
              elsif r_language.codlang = '102' then
                obj_description.put('th', r_lv2.desappt);
              elsif r_language.codlang = '103' then
                obj_description.put(lower(r_language.codlang), r_lv2.desapp3);
              elsif r_language.codlang = '104' then
                obj_description.put(lower(r_language.codlang), r_lv2.desapp4);
              elsif r_language.codlang = '105' then
                obj_description.put(lower(r_language.codlang), r_lv2.desapp5);
              end if;
            end loop;
            obj_data2.put('description', obj_description);
            obj_data2.put('children', obj_lv3);
            obj_lv2.put(to_char(cnt_lv2-1), obj_data2);
          end loop; -- end menu expand level 2
          obj_data1 := json_object_t();
          obj_data1.put('type', r_lv1.type);
          obj_data1.put('codproc', r_modules.codproc);

          -- set linkurl
          v_code := nvl(r_lv1.codapp,'');
          v_url  := '';
          if r_lv1.linkurl is not null then
            v_url  := set_url(r_lv1.linkurl);
            v_code := v_url;
          end if;
          obj_data1.put('code', v_code);
          obj_data1.put('url', v_url);

          obj_description := json_object_t();
          for r_language in c_language loop
            if r_language.codlang = '101' then
              obj_description.put('en', r_lv1.desappe);
            elsif r_language.codlang = '102' then
              obj_description.put('th', r_lv1.desappt);
            elsif r_language.codlang = '103' then
              obj_description.put(lower(r_language.codlang), r_lv1.desapp3);
            elsif r_language.codlang = '104' then
              obj_description.put(lower(r_language.codlang), r_lv1.desapp4);
            elsif r_language.codlang = '105' then
              obj_description.put(lower(r_language.codlang), r_lv1.desapp5);
            end if;
          end loop;
          obj_data1.put('description', obj_description);
          obj_data1.put('children', obj_lv2);
          obj_lv1.put(to_char(cnt_lv1-1), obj_data1);
        end loop; -- end menu expand level 1
        obj_data_module := json_object_t();
        obj_data_module.put('type', r_modules.type);
        obj_data_module.put('codproc', r_modules.codproc);
        obj_data_module.put('code', r_modules.module);
        obj_data_module.put('icon', lower(r_modules.icon));
        obj_data_module.put('codimage', r_modules.codimage);
        obj_description := json_object_t();
        for r_language in c_language loop
          if r_language.codlang = '101' then
            obj_description.put('en', r_modules.desappe);
          elsif r_language.codlang = '102' then
            obj_description.put('th', r_modules.desappt);
          elsif r_language.codlang = '103' then
            obj_description.put(lower(r_language.codlang), r_modules.desapp3);
          elsif r_language.codlang = '104' then
            obj_description.put(lower(r_language.codlang), r_modules.desapp4);
          elsif r_language.codlang = '105' then
            obj_description.put(lower(r_language.codlang), r_modules.desapp5);
          end if;
        end loop;
        obj_data_module.put('description', obj_description);
        obj_data_module.put('children', obj_lv1);
        obj_row.put(r_modules.codproc,obj_data_module);
      end if; -- if v_license > 0 then
    end loop;

    -- link url menu
    for r_linkurl in c_linkurl loop
      v_codproc := r_linkurl.codproc;
      obj_lv1 := json_object_t();
      obj_data_module := json_object_t();
      obj_data_module.put('type', 'link');
      obj_data_module.put('codproc', v_codproc);

      v_code := v_codproc;
      if v_code = 'C.JO' then -- Job online
        v_codproc := 'JO';
      elsif v_code = 'D.RE' then -- Report
        v_codproc := 'RE';
      elsif v_code = 'E.AD' then  -- Advance Payroll
        v_codproc := 'ADPY';
      end if;
      obj_data_module.put('code', r_linkurl.desappe);     -- for display
      obj_data_module.put('url', set_url(r_linkurl.url)); -- for link url
      obj_data_module.put('icon', lower(v_codproc));      -- for css class
      obj_data_module.put('codimage', r_linkurl.codimage);-- for icon image
      obj_description := json_object_t();
      for r_language in c_language loop
        if r_language.codlang = '101' then
          obj_description.put('en', r_linkurl.desappe);
        elsif r_language.codlang = '102' then
          obj_description.put('th', r_linkurl.desappt);
        elsif r_language.codlang = '103' then
          obj_description.put(lower(r_language.codlang), r_linkurl.desapp3);
        elsif r_language.codlang = '104' then
          obj_description.put(lower(r_language.codlang), r_linkurl.desapp4);
        elsif r_language.codlang = '105' then
          obj_description.put(lower(r_language.codlang), r_linkurl.desapp5);
        end if;
      end loop;
      obj_data_module.put('description', obj_description);
      obj_data_module.put('children', obj_lv1);
      obj_row.put(v_codproc,obj_data_module);
    end loop;

    /* -- don't use this code (hard code)
    --<< Menu Job Online
    v_path_jobonline := get_tsetup_value('PATHJOBONLINE');
    if v_path_jobonline is not null then
      obj_lv1 := json_object_t();
      obj_data_module := json_object_t();
      obj_data_module.put('type', 'link');
      obj_data_module.put('codproc', 'JO');
      obj_data_module.put('code', 'JOB');
      obj_data_module.put('url', v_path_jobonline);
      obj_data_module.put('icon', lower('jo'));
      obj_data_module.put('codimage', '14_jo.png');
      obj_description := json_object_t();
      for r_language in c_language loop
        if r_language.codlang = '101' then
          obj_description.put('en', 'Job Online');
        elsif r_language.codlang = '102' then
          obj_description.put('th', 'Job Online');
        else
          obj_description.put(lower(r_language.codlang), 'Job Online');
        end if;
      end loop;
      obj_data_module.put('description', obj_description);
      obj_data_module.put('children', obj_lv1);
      obj_row.put('JO',obj_data_module);
    end if;
    -->> END Menu Job Online

    --<< Menu Script Case
    begin
      select typeuser
        into v_typeuser
        from tusrprof
       where coduser = upper(p_coduser);
    exception when no_data_found then
      null;
    end;
    v_path_scriptcase := get_tsetup_value('PATHSCASE');
    if v_path_scriptcase is not null then
      if v_typeuser in ('1','4') then
        obj_lv1 := json_object_t();
        obj_data_module := json_object_t();
        obj_data_module.put('type', 'link');
        obj_data_module.put('codproc', 'RE');
        obj_data_module.put('code', 'Report');
        obj_data_module.put('url', v_path_scriptcase);
        obj_data_module.put('icon', lower('re'));
        obj_data_module.put('codimage', '15_re.png');
        obj_description := json_object_t();
        for r_language in c_language loop
          if r_language.codlang = '101' then
            obj_description.put('en', 'Report');
          elsif r_language.codlang = '102' then
            obj_description.put('th', 'รายงาน');
          else
            obj_description.put(lower(r_language.codlang), 'Report');
          end if;
        end loop;
        obj_data_module.put('description', obj_description);
        obj_data_module.put('children', obj_lv1);
        obj_row.put('RE',obj_data_module);
      end if;
    end if;
    -->> END Menu Script Case

    --<< Menu Advance Payroll
    v_path_advpayroll := get_tsetup_value('PATHADVPAYROLL');
    if v_path_advpayroll is not null then
      obj_lv1 := json_object_t();
      obj_data_module := json_object_t();
      obj_data_module.put('type', 'link');
      obj_data_module.put('codproc', 'ADPY');
      obj_data_module.put('code', 'Advance Payroll');
      obj_data_module.put('url', v_path_advpayroll);
      obj_data_module.put('icon', lower('adpy'));
      obj_data_module.put('codimage', '18-adv-payroll.png');
      obj_description := json_object_t();
      for r_language in c_language loop
        if r_language.codlang = '101' then
          obj_description.put('en', 'Advance Payroll');
        elsif r_language.codlang = '102' then
          obj_description.put('th', 'Advance Payroll');
        else
          obj_description.put(lower(r_language.codlang), 'Advance Payroll');
        end if;
      end loop;
      obj_data_module.put('description', obj_description);
      obj_data_module.put('children', obj_lv1);
      obj_row.put('ADPY',obj_data_module);
    end if;
    -->> END Menu Advance Payroll
    */

    return obj_row.to_clob;
  end;
end;
-- last update: 07/08/2018 13:51

/

--------------------------------------------------------
--  DDL for Package Body HRCO2LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2LX" as
  procedure initial_value(json_str_input in clob) is
    json_obj json_object_t;
  begin
    json_obj          := json_object_t(json_str_input);
    global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

    p_routeno         := upper(hcm_util.get_string_t(json_obj,'routeno'));
    p_codpos          := upper(hcm_util.get_string_t(json_obj,'codpos'));
    p_codcomp         := upper(hcm_util.get_string_t(json_obj,'codcomp'));
    p_codempa         := upper(hcm_util.get_string_t(json_obj,'codempa'));

    p_codapp          := upper(hcm_util.get_string_t(json_obj,'codapp'));
    p_seqno           := to_number(hcm_util.get_string_t(json_obj,'seqno'));
  end initial_value;

  procedure check_index as
      v_temp      varchar2(4 char);
  begin
      -- ให้ระบุ Rounte No หรือ รหัสตำแหน่ง และรหัสหน่วยงาน หรือ รหัสผู้อนุมัติ
      if p_routeno is null and ((p_codpos is null) and (p_codcomp is null)) and p_codempa is null then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'1.)routeno='||p_routeno||' + codpos='||p_codpos||' + codcomp='||p_codcomp||' + codempa'||p_codempa);
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;

      -- กรณีที่ระบุรหัสตาแหน่ง ต้องบังคับให้รหัสหน่วยงาน ด้วย
      if (p_codpos is not null) and (p_codcomp is null) then
--            param_msg_error := get_error_msg_php('HR2045',global_v_lang,'2.)routeno='||p_routeno||' + codpos='||p_codpos||' + codcomp='||p_codcomp||' + codempa'||p_codempa);
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;

      -- กรณีที่ระบุ Index ทั้ง Rounte No และ รหัสตาแหน่ง และรหัสหน่วยงาน และ รหัสผู้อนุมัติ ค่า Index รหัสตาแหน่ง และรหัสหน่วยงาน และ รหัสผู้อนุมัติ ออก
      if (p_routeno is not null) and (p_codpos is not null) and (p_codcomp is not null) and (p_codempa is not null) then
          p_codpos := null;
          p_codcomp := null;
          p_codempa := null;
      end if;

      -- กรณีที่ระบุ Index ทั้ง รหัสตาแหน่ง และรหัสหน่วยงาน และ รหัสผู้อนุมัติ ค่า Index รหัสผู้อนุมัติ ออก
      if (p_codpos is not null) and (p_codcomp is not null) and (p_codempa is not null) then
          p_codempa := null;
      end if;

      -- รหัส Route No. ต้องมีข้อมูลในตาราง TWKFLOWH
      if p_routeno is not null then
          begin
              select 'X' into v_temp
              from twkflowh
              where routeno = p_routeno;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'twkflowh');
              return;
          end;
      end if;

      -- รหัส รหัสตาแหน่ง ต้องมีข้อมูลในตาราง TPOSTN
      if p_codpos is not null then
          begin
              select 'X' into v_temp
              from tpostn
              where codpos = p_codpos;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
              return;
          end;
      end if;

      -- รหัส รหัสหน่วยงาน ต้องมีข้อมูลในตาราง TCENTER
      if p_codcomp is not null then
          begin
              select 'X' into v_temp
              from tcenter
              where codcomp like p_codcomp||'%'
              fetch first 1 rows only;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
              return;
          end;
      end if;

      -- รหัส รหัสผู้อนุมัติ ต้องมีข้อมูลในตาราง TEMPLOY1
      if p_codempa is not null then
          begin
              select 'X' into v_temp
              from temploy1
              where codempid = p_codempa;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
              return;
          end;
      end if;
  end check_index;

  procedure gen_data(json_str_output out clob) as
      obj_result  json_object_t;
      obj_data    json_object_t;
      v_row       number := 0;
      v_routeno     twkflph.routeno%type;
      v_codpos      twkflowd.codposa%type;
      v_codcomp     twkflowd.codcompa%type;
      v_codempa     twkflowd.codempa%type;
      v_codposa     twkflowd.codposa%type;
      v_codcompa    twkflowd.codcompa%type;
      v_flgskip     varchar2(1 char) := 'N';
      v_desc_typrep varchar2(1000 char) := '';
      v_lvlrouteno  varchar2(10 char) := '';
      v_approvno    twkflowh.approvno%type;
      v_numseq      twkflowd.numseq%type;
      v_seqno       twkflph.seqno%type;
      v_statement   twkflph.statement%type;
      cursor c1 is
        select a.codapp, a.routeno,a.seqno,a.syncond,to_char(a.statement) as statement,
                '' as codempid,'' as codcomp,'' as codpos,'1' tpyrep
          from twkflph a
         where a.routeno  = nvl( p_routeno , a.routeno)
           and (a.routeno in (select routeno from twkflowd c
                              where nvl(c.codcompa,'%') = nvl(p_codcomp, nvl(c.codcompa,'%'))
                              and nvl(c.codposa,'%') = nvl(p_codpos ,nvl(c.codposa,'%'))
                              and nvl(c.codempa,'%') = nvl(p_codempa,nvl(c.codempa,'%'))))
        union
        select b.codapp, b.routeno, 0 as seqno, '' as syncond , null as statement,
               b.codempid as codempid, b.codcomp as codcomp, b.codpos as codpos,decode(b.codempid,'%','3','2') tpyrep
          from temproute b
         where b.routeno  =   nvl( p_routeno , b.routeno)
           and (b.routeno in (select routeno from twkflowd c
                              where nvl(c.codcompa,'%') = nvl(p_codcomp,nvl(c.codcompa,'%'))
                              and nvl(c.codposa,'%') = nvl(p_codpos,nvl(c.codposa,'%'))
                              and nvl(c.codempa,'%') = nvl(p_codempa,nvl(c.codempa,'%'))))
         order by codapp, routeno, tpyrep;

  begin
      obj_result := json_object_t();
    for r1 in c1 loop
      v_routeno := r1.routeno;
      v_seqno   := null;
      if r1.tpyrep = '1' then
        begin
          select approvno
            into v_approvno
            from twkflowh
           where routeno = r1.routeno;
        exception when no_data_found then
          v_approvno  := 0;
        end;
        v_lvlrouteno  := ''||v_approvno;
        v_desc_typrep := get_label_name('HRCO2MX1',global_v_lang,70);
        v_seqno       := r1.seqno;
        v_statement   := get_logical_desc(r1.statement);
      elsif r1.tpyrep = '2' then
        begin
          select numseq
            into v_numseq
            from twkflowd
           where routeno = r1.routeno
             and typeapp = 4
             and codempa = r1.codempid
             and rownum = 1;
        exception when no_data_found then
          v_numseq  := 0;
        end;
        begin
          select approvno
            into v_approvno
            from twkflowh
           where routeno = r1.routeno;
        exception when no_data_found then
          v_approvno  := 0;
        end;
        v_lvlrouteno  := v_numseq||'/'||v_approvno;
        v_desc_typrep := get_label_name('HRCO2MX1',global_v_lang,80);
        v_statement   := r1.codempid ||' - '||get_temploy_name(r1.codempid, global_v_lang);
      elsif r1.tpyrep = '3' then
          begin
            select approvno
              into v_approvno
              from twkflowh
             where routeno = r1.routeno;
          exception when no_data_found then
            v_approvno  := 0;
          end;
          begin
            select numseq
              into v_numseq
              from twkflowd
             where routeno = r1.routeno
               and typeapp = 3
               and codempa = r1.codempid
               and rownum = 1;
          exception when no_data_found then
            v_numseq  := 0;
          end;
          v_lvlrouteno  := v_numseq||'/'||v_approvno;
          v_desc_typrep := get_label_name('HRCO2MX1',global_v_lang,90);
          v_statement   := r1.codcomp ||'-'||get_tcenter_name(r1.codcomp, global_v_lang)|| ' ' ||r1.codpos ||'-'||get_tpostn_name(r1.codpos, global_v_lang);
      end if;
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('codapp',r1.codapp);
      obj_data.put('namapp',get_tappprof_name(r1.codapp,1,global_v_lang));
      obj_data.put('seqno',r1.seqno);
      obj_data.put('routeno',r1.routeno);
      obj_data.put('desc_routeno',r1.routeno || ' - ' || get_twkflowh_name(r1.routeno, global_v_lang));
      obj_data.put('lvlrouteno',v_lvlrouteno);
      obj_data.put('typeapp',v_desc_typrep);
      obj_data.put('seqno',v_seqno);
      obj_data.put('syncond',v_statement);

      obj_result.put(to_char(v_row - 1),obj_data);
    end loop;
    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TWKFLPH');      
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := obj_result.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_data;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  function get_form_name(v_codform varchar2) return varchar2 as
    tfrmmail_rec    tfrmmail%rowtype;
  begin
      begin
        select * into tfrmmail_rec
        from tfrmmail
        where codform = v_codform;
      exception when no_data_found then
        return '';
      end;
      if global_v_lang = '101' then
        return tfrmmail_rec.descode;
      elsif global_v_lang = '102' then
        return tfrmmail_rec.descodt;
      elsif global_v_lang = '103' then
        return tfrmmail_rec.descod3;
      elsif global_v_lang = '104' then
        return tfrmmail_rec.descod4;
      elsif global_v_lang = '105' then
        return tfrmmail_rec.descod5;
      else
        return tfrmmail_rec.descode;
      end if;
  end;

  procedure get_workflow(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    v_row           number := 0;
    v_codapp        twkflpf.codapp%type;
    v_codfrmto      twkflpf.codfrmto%type;
    v_codfrmcc      twkflpf.codfrmcc%type;
    v_codappap      twkflpf.codappap%type;
    v_dtetotal      twkflpf.dtetotal%type;
    v_hrtotal       twkflpf.hrtotal%type;
    cursor c_twkflpr is
        select codapp,codempid
        from twkflpr
        where codapp = p_codapp;

  begin
    initial_value(json_str_input);
    begin
      select a.codapp,a.codfrmto,a.codfrmcc,a.codappap,a.dtetotal,a.hrtotal
        into v_codapp,v_codfrmto,v_codfrmcc,v_codappap,v_dtetotal,v_hrtotal
        from twkflpf a
       where a.codapp = p_codapp;
    exception when no_data_found then
      v_codapp    :=  '';   v_codfrmto    :=  '';  v_codfrmcc   :=  '';
      v_codappap  :=  '';   v_dtetotal    :=  '';  v_hrtotal    :=  '';
    end;
    obj_data   := json_object_t();
    obj_data.put('coderror','200');
    obj_data.put('codapp', v_codapp||' - '||get_tappprof_name(v_codapp,1,global_v_lang));
    obj_data.put('codfrmto', v_codfrmto||' - '||get_form_name(v_codfrmto));
    obj_data.put('codfrmcc', v_codfrmcc||' - '||get_form_name(v_codfrmcc));
    obj_data.put('codappap', v_codappap||' - '||get_tappprof_name(v_codappap,1,global_v_lang));
    obj_data.put('seqno', p_seqno);
    obj_data.put('dtetotal', hcm_util.convert_minute_to_hour(v_dtetotal));
    obj_data.put('hrtotal', hcm_util.convert_minute_to_hour(v_hrtotal));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_workflow;

  procedure get_workflow_tab1(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    v_row       number := 0;
    v_seqno         twkflph.seqno%type;
    v_syncond       twkflph.syncond%type;
    v_routeno       twkflph.routeno%type;
    v_codfrmap      twkflph.codfrmap%type;
    v_codfrmno      twkflph.codfrmno%type;
    v_typreplya     twkflph.typreplya%type;
    v_typreplyn     twkflph.typreplyn%type;
    v_typreplyar    twkflph.typreplyar%type;
    v_typreplynr    twkflph.typreplynr%type;
    v_statement     twkflph.statement%type;
    v_strseq        twkflph.strseq%type;

  begin
    initial_value(json_str_input);
    begin
      select b.seqno,b.syncond,b.routeno,b.codfrmap,b.codfrmno,b.typreplya,
             b.typreplyn,b.typreplyar,b.typreplynr,b.statement, strseq
        into v_seqno,v_syncond,v_routeno,v_codfrmap,v_codfrmno,v_typreplya,
             v_typreplyn,v_typreplyar,v_typreplynr,v_statement, v_strseq
        from twkflph b
       where b.codapp = p_codapp 
         and b.seqno = p_seqno;
    exception when no_data_found then
      v_seqno     :=  '';   v_syncond     :=  '';  v_routeno    :=  '';
      v_codfrmap  :=  '';   v_codfrmno    :=  '';  v_typreplya  :=  '';
      v_typreplyn :=  '';   v_typreplyar  :=  '';  v_typreplynr :=  '';
    end;
      obj_data   := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('seqno', v_seqno);
      obj_data.put('strseq', v_strseq);
      obj_data.put('syncond', v_syncond);
      obj_data.put('statement', v_statement);
      obj_data.put('syncond_desc', get_logical_name('HRCO2JE',v_syncond,global_v_lang));
      obj_data.put('routeno', v_routeno);
      obj_data.put('codfrmap', v_codfrmap);
      obj_data.put('codfrmno', v_codfrmno);
      obj_data.put('typreplya', v_typreplya);
      obj_data.put('typreplyn', v_typreplyn);
      obj_data.put('typreplyar', v_typreplyar);
      obj_data.put('typreplynr', v_typreplynr);

      json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_workflow_tab1;
  procedure get_workflow_tab2(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_row       number := 0;
    cursor c_twkflpr is
      select codapp,codempid
      from twkflpr
      where codapp = p_codapp;
  begin
    initial_value(json_str_input);
--    if param_msg_error is null then
    obj_row    := json_object_t();
    for r1 in c_twkflpr loop
      v_row := v_row + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(r1.codempid));
      obj_data.put('codempid', r1.codempid);
      obj_data.put('namemp', get_temploy_name(r1.codempid,global_v_lang));
      obj_row.put(to_char(v_row - 1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_workflow_tab2;
end hrco2lx;

/

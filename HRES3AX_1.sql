--------------------------------------------------------
--  DDL for Package Body HRES3AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES3AX" is
-- last update: 15/04/2019 16:40

  procedure initial_value(json_str in clob) is
  json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_f_name      := hcm_util.get_string_t(json_obj,'p_fullname');
    b_index_l_name      := hcm_util.get_string_t(json_obj,'p_lastname');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_stdate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_stdate')),'dd/mm/yyyy');
    b_index_endate      := to_date(trim(hcm_util.get_string_t(json_obj,'p_endate')),'dd/mm/yyyy');
    b_index_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
    v_codcomp   varchar2(4000 char);
    v_codpos    varchar2(4000 char);
  begin
    if b_index_stdate is null  then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;

    if b_index_endate is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;

    if b_index_stdate > b_index_endate then
       param_msg_error := get_error_msg_php('HR2021',global_v_lang);
       return;
    end if;

    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codpos is not null then
      begin
        select codpos into v_codpos
          from tpostn
         where codpos = b_index_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
        return;
      end;
    end if;
  end;
  --
  procedure gen_data(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
    v_zupdsal       varchar2(1);
    v_data          number := 0;

    cursor c1 is
      select codempid,codcomp,codpos,dteempmt
        from temploy1
       where (upper(namfirste) like '%'||upper(b_index_f_name)||'%'
          or upper(namfirstt) like '%'||upper(b_index_f_name)||'%'
          or upper(namfirst3) like '%'||upper(b_index_f_name)||'%'
          or upper(namfirst4) like '%'||upper(b_index_f_name)||'%'
          or upper(namfirst5) like '%'||upper(b_index_f_name)||'%')
         and (upper(namlaste) like '%'||upper(b_index_l_name)||'%'
          or upper(namlastt) like '%'||upper(b_index_l_name)||'%'
          or upper(namlast3) like '%'||upper(b_index_l_name)||'%'
          or upper(namlast4) like '%'||upper(b_index_l_name)||'%'
          or upper(namlast5) like '%'||upper(b_index_l_name)||'%')
          and codcomp like b_index_codcomp||'%'
          and dteempmt between b_index_stdate and b_index_endate
          and codpos   = nvl(b_index_codpos,codpos)
          and staemp <> '9'
          /*
          and (codempid = b_index_codempid or
              (codempid <> b_index_codempid
              and numlvl between global_v_zminlvl and global_v_zwrklvl
              and 0 <> (select count(ts.codcomp)
                          from tusrcom ts
                         where ts.coduser = global_v_coduser
                           and codcomp like ts.codcomp||'%'
                           and rownum <= 1 )))*/
         order by dteempmt desc,codempid;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_data := v_data+1;
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
          v_flgsecur := 'Y';
          v_rcnt := v_rcnt + 1;
          obj_data := json_object_t();
          obj_data.put('coderror','200');
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('codcomp',r1.codcomp);
          obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
          obj_data.put('codpos',r1.codpos);
          obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
          obj_data.put('dteempmt',to_char(r1.dteempmt,'dd/mm/yyyy'));
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

  if v_data  = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'temploy1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  else
       if v_flgsecur = 'N' then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        else
          json_str_output := obj_row.to_clob;
        end if;
  end if;
--    if v_flgdata = 'Y' then
--      json_str_output := obj_row.to_clob;
--    else
--      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'temploy1');
--      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--    end if;
  end;
  --
  function get_head(p_codempid in varchar2,p_codcomnp in varchar2,p_codpos in varchar2) return varchar2 is
  	v_codcomph    tcenter.codcomp%type;
    v_codposh     varchar2(4 char);
    v_codemph     temploy1.codempid%type;
    v_stapost     varchar2(1 char);
    v_head1       varchar2(1 char):= 'N';

    cursor c_head1 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from  temphead
      where codempid = p_codempid
      order by numseq;

    cursor c_head2 is
    select replace(codempidh,'%',null) codempidh,
           replace(codcomph,'%',null) codcomph,
           replace(codposh,'%',null) codposh
      from  temphead
      where codcomp = p_codcomnp
      and   codpos  = p_codpos
      order by numseq;
   begin
   -- Find Head
        for j in c_head1 loop
          v_head1  := 'Y' ;
          if j.codempidh  is not null then
             v_codemph := j.codempidh ;
          else
            v_codcomph := j.codcomph ;
            v_codposh  := j.codposh ;
          end if;
          exit;
        end loop;
        if 	v_head1 = 'N' then
            for j in c_head2 loop
                  v_head1  := 'Y' ;
                  if j.codempidh  is not null then
                     v_codemph := j.codempidh ;
                  else
                    v_codcomph := j.codcomph ;
                    v_codposh  := j.codposh ;
                  end if;
                  exit;
            end loop;
        end if;

        if v_codcomph is not null then
            begin
                select codempid into v_codemph
                  from temploy1
                 where codcomp  = v_codcomph
                   and codpos   = v_codposh
                   and staemp   in  ('1','3')
                   and rownum   = 1;
                   v_stapost := null;
            exception when no_data_found then
                begin
                 select codempid,stapost2 into v_codemph,v_stapost
                   from tsecpos
                  where codcomp	= v_codcomph
                    and codpos	  = v_codposh
                    and dteeffec <= sysdate
                    and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null)
                    and rownum   = 1;
                exception when no_data_found then
                    v_codemph := null;
                    v_stapost := null;
                end;
            end;
		end if;
    return v_codemph;
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_popup(json_str_output out clob) as
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_numtelof          temploy1.numtelof%type;
    temploy1_numtelec   varchar2(100 char);
    temploy1_desc_super varchar2(100 char);

    cursor c1 is
      select codempid,codcomp,codpos,email
        from temploy1
       where codempid = b_index_codempid;

  begin
    obj_row  := json_object_t();
    for r1 in c1 loop
      -- find numtel
      begin
        select numtelec into temploy1_numtelec
          from temploy2
         where codempid = r1.codempid;
      exception when no_data_found then
        temploy1_numtelec := null;
      end;
      --
      begin
        select numtelof into v_numtelof
          from temploy1
         where codempid = r1.codempid;
      exception when no_data_found then
        v_numtelof := null;
      end;
      if v_numtelof is not null then
         if temploy1_numtelec is null then
            temploy1_numtelec  := v_numtelof;
         else
            temploy1_numtelec  := temploy1_numtelec||' ( '||v_numtelof||' )';
         end if;
      end if;

      obj_row.put('coderror','200');
      obj_row.put('codempid',r1.codempid);
      obj_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
      obj_row.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
      obj_row.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
      obj_row.put('email',r1.email);
      obj_row.put('numtelec',temploy1_numtelec);
      temploy1_desc_super := get_head(r1.codempid,r1.codcomp,r1.codpos);
      obj_row.put('desc_super',temploy1_desc_super||' - '||get_temploy_name(temploy1_desc_super, global_v_lang));
    end loop;

    json_str_output := obj_row.to_clob;
  end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRPMB5E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMB5E" is
-- last update: 04/01/2018 12:23
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin

    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    -- index
    p_codcompy          := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'dd/mm/yyyy');
    p_dteeffeChar          := to_char(p_dteeffec,'yyyymmdd');

    dateNow             := CURRENT_DATE;
  end initial_value;
  procedure initial_value_detail (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    -- index
    p_codcompy          := upper(hcm_util.get_string_t(json_obj,'p_codcompy'));
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'dd/mm/yyyy');
    p_dteeffeChar       := to_char(p_dteeffec,'yyyymmdd');
    p_codfrm            := hcm_util.get_string_t(json_obj,'p_codfrm');
  end initial_value_detail;

  function check_index return varchar2 as
  begin
    if p_codcompy is null then
      return get_error_msg_php('HR2045',global_v_lang,'codcompy');
    else
      return hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    end if;

    if p_dteeffec is null then
      return get_error_msg_php('HR2045',global_v_lang,'dteeffec');
    end if;
  end;

  procedure getIndex (json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        param_msg_error := check_index;
        if param_msg_error is not null then
            json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
        else
            genIndex(json_str_output);
        end if;

  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
procedure genIndex (json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_sub_data        json_object_t;
    obj_main            json_object_t;
    v_rcnt              number := 0;
    p_codcompid         varchar2( 100 char);
    v_response          varchar2(1000 char);
     cursor c_2 is
        select *
          from tincpos
         where codcompy = p_codcompy
           and trunc(dteeffec) = p_dteeffecquery;
  begin
    gen_flg_status;
    obj_row     := json_object_t();
    if v_flgDisabled then
        v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
    end if;    
    for r1 in c_2 loop
      obj_data          := json_object_t();
      obj_sub_data      := json_object_t();
      v_rcnt            := v_rcnt + 1;

      obj_data.put('coderror', '200');
      obj_data.put('flgAdd', isAdd);
      obj_data.put('rownumber', v_rcnt);
      obj_data.put('codcompy', r1.codcompy);
      obj_data.put('codfrm', r1.codfrm);
      obj_data.put('dteeffec', to_char(p_dteeffec,'DD/MM/YYYY'));
      obj_data.put('dteeffeco', to_char(p_dteeffecquery,'DD/MM/YYYY'));

      if global_v_lang = '102' then
         obj_data.put('namfrm', r1.namfrmt);
      elsif global_v_lang = '101' then
         obj_data.put('namfrm', r1.namfrme);
      elsif global_v_lang = '103' then
         obj_data.put('namfrm', r1.namfrm3);
      elsif global_v_lang = '104' then
         obj_data.put('namfrm', r1.namfrm4);
      elsif global_v_lang = '105' then
         obj_data.put('namfrm', r1.namfrm5);
      end if;
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    obj_main    := json_object_t();
    obj_main.put('coderror', '200');
    obj_main.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
    obj_main.put('isAdd', isAdd);
    obj_main.put('isEdit', isEdit);
    obj_main.put('msqerror', v_response);
    obj_main.put('table', obj_row);

    json_str_output := obj_main.to_clob;
  end;
  procedure getDetail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value_detail(json_str_input);
    gen_flg_status;
    genDetail(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure genDetail (json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    obj_sub_detail          json_object_t;
    obj_detail              json_object_t;
    obj_detail_con          json_object_t;
    obj_sub_detail_grp      json_object_t;
    obj_rowdetail           json_object_t;
    obj_changelabel         json_object_t;
    v_rcnt                  number := 0;
    v_count                 number := 0;
    v_response              varchar2(4000 char);

    cursor c_tincpos is
       select t.*, to_char(t.dteeffec,'dd/mm/yyyy') dateeffect, 
              get_logical_name('HRPM16E',syncond,global_v_lang) logicdesc
         from tincpos t
        where dteeffec = p_dteeffecquery
          and codfrm = p_codfrm
          and codcompy = p_codcompy;

    cursor c_tcontpms is
        select * 
          from (
                select codincom1, get_tinexinf_name(codincom1,global_v_lang) desc1, codincom2, get_tinexinf_name(codincom2,global_v_lang) desc2,
                       codincom3, get_tinexinf_name(codincom3,global_v_lang) desc3, codincom4, get_tinexinf_name(codincom4,global_v_lang) desc4,
                       codincom5, get_tinexinf_name(codincom5,global_v_lang) desc5, codincom6, get_tinexinf_name(codincom6,global_v_lang) desc6,
                       codincom7, get_tinexinf_name(codincom7,global_v_lang) desc7, codincom8, get_tinexinf_name(codincom8,global_v_lang) desc8,
                       codincom9, get_tinexinf_name(codincom9,global_v_lang) desc9, codincom10, get_tinexinf_name(codincom10,global_v_lang) desc10
                  from tcontpms
                 where codcompy = p_codcompy
                   and dteeffec <= p_dteeffec
--                   and dteeffec <= p_dteeffecquery
              order by dteeffec desc )num
         where rownum = 1;
        tcontpms_rec    c_tcontpms%ROWTYPE;
  begin
    OPEN c_tcontpms;
    FETCH c_tcontpms INTO tcontpms_rec;
    for r1 in c_tincpos loop
        v_syncond           := r1.syncond;
        v_statement         := r1.statement;
        v_logicdesc         := r1.logicdesc ;
        v_dteeffec          := r1.dateeffect;
        v_dteeffecD         := r1.dteeffec;
        v_mode              := 'edit';
        v_amtproba1         := stddec(r1.amtproba1,p_codfrm,v_chken) ;
        v_amtpacup1         := stddec(r1.amtpacup1,p_codfrm,v_chken) ;
        v_amtproba2         := stddec(r1.amtproba2,p_codfrm,v_chken) ;
        v_amtpacup2         := stddec(r1.amtpacup2,p_codfrm,v_chken) ;
        v_amtproba3         := stddec(r1.amtproba3,p_codfrm,v_chken) ;
        v_amtpacup3         := stddec(r1.amtpacup3,p_codfrm,v_chken) ;
        v_amtproba4         := stddec(r1.amtproba4,p_codfrm,v_chken) ;
        v_amtpacup4         := stddec(r1.amtpacup4,p_codfrm,v_chken) ;
        v_amtproba5         := stddec(r1.amtproba5,p_codfrm,v_chken) ;
        v_amtpacup5         := stddec(r1.amtpacup5,p_codfrm,v_chken) ;
        v_amtproba6         := stddec(r1.amtproba6,p_codfrm,v_chken) ;
        v_amtpacup6         := stddec(r1.amtpacup6,p_codfrm,v_chken) ;
        v_amtproba7         := stddec(r1.amtproba7,p_codfrm,v_chken) ;
        v_amtpacup7         := stddec(r1.amtpacup7,p_codfrm,v_chken) ;
        v_amtproba8         := stddec(r1.amtproba8,p_codfrm,v_chken) ;
        v_amtpacup8         := stddec(r1.amtpacup8,p_codfrm,v_chken) ;
        v_amtproba9         := stddec(r1.amtproba9,p_codfrm,v_chken) ;
        v_amtpacup9         := stddec(r1.amtpacup9,p_codfrm,v_chken) ;
        v_amtproba10        := stddec(r1.amtproba10,p_codfrm,v_chken) ;
        v_amtpacup10        := stddec(r1.amtpacup10,p_codfrm,v_chken) ;
       if global_v_lang = '102' then
             v_namfrm           := r1.namfrmt   ;
        elsif global_v_lang = '101' then
             v_namfrm           := r1.namfrme   ;
        elsif global_v_lang = '103' then
             v_namfrm           := r1.namfrm3   ;
          elsif global_v_lang = '104' then
             v_namfrm           := r1.namfrm4   ;
          elsif global_v_lang = '105' then
             v_namfrm           := r1.namfrm5   ;
        end if;
        v_namfrme           := r1.namfrme   ;
        v_namfrmt           := r1.namfrmt   ;
        v_namfrm3           := r1.namfrm3   ;
        v_namfrm4           := r1.namfrm4   ;
        v_namfrm5           := r1.namfrm5   ;
    end loop;
--    obj_changelabel := json_object_t();
--    obj_changelabel.put('namfrm', nvl(v_namfrm,''));
--    obj_changelabel.put('namfrmt', nvl(v_namfrmt,''));
--    obj_changelabel.put('namfrme', nvl(v_namfrme,''));
--    obj_changelabel.put('namfrm3', nvl(v_namfrm3,''));
--    obj_changelabel.put('namfrm4', nvl(v_namfrm4,''));
--    obj_changelabel.put('namfrm5', nvl(v_namfrm5,''));

    obj_row     := json_object_t();
    v_rcnt      := v_rcnt + 1;
    obj_sub_detail        := json_object_t();
    obj_detail            := json_object_t();
    obj_detail_con        := json_object_t();
    obj_sub_detail_grp    := json_object_t();
    obj_rowdetail         := json_object_t();


    obj_detail.put('coderror',200);
    obj_detail.put('codfrm',p_codfrm);
    obj_detail_con.put('code', v_syncond);
    obj_detail_con.put('description', get_logical_name('HRPM16E',v_syncond,global_v_lang));
    obj_detail_con.put('statement',nvl(v_statement,'[]'));
    obj_detail.put('syncond', obj_detail_con);
    obj_detail.put('namfrm', nvl(v_namfrm,''));
    obj_detail.put('namfrmt', nvl(v_namfrmt,''));
    obj_detail.put('namfrme', nvl(v_namfrme,''));
    obj_detail.put('namfrm3', nvl(v_namfrm3,''));
    obj_detail.put('namfrm4', nvl(v_namfrm4,''));
    obj_detail.put('namfrm5', nvl(v_namfrm5,''));

    if tcontpms_rec.codincom1 is not null then
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom1);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc1);
      obj_sub_detail.put('amtproba', v_amtproba1);
      obj_sub_detail.put('amtpacup', v_amtpacup1);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom2 is not null then
      obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom2);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc2);
      obj_sub_detail.put('amtproba', v_amtproba2);
      obj_sub_detail.put('amtpacup', v_amtpacup2);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
     end if;


    if tcontpms_rec.codincom3 is not null then
      obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom3);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc3);
      obj_sub_detail.put('amtproba', v_amtproba3);
      obj_sub_detail.put('amtpacup', v_amtpacup3);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom4 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom4);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc4);
      obj_sub_detail.put('amtproba', v_amtproba4);
      obj_sub_detail.put('amtpacup', v_amtpacup4);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom5 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom5);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc5);
      obj_sub_detail.put('amtproba', v_amtproba5);
      obj_sub_detail.put('amtpacup', v_amtpacup5);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom6 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom6);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc6);
      obj_sub_detail.put('amtproba', v_amtproba6);
      obj_sub_detail.put('amtpacup', v_amtpacup6);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom7 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom7);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc7);
      obj_sub_detail.put('amtproba', v_amtproba7);
      obj_sub_detail.put('amtpacup', v_amtpacup7);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom8 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom8);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc8);
      obj_sub_detail.put('amtproba', v_amtproba8);
      obj_sub_detail.put('amtpacup', v_amtpacup8);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom9 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom9);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc9);
      obj_sub_detail.put('amtproba', v_amtproba9);
      obj_sub_detail.put('amtpacup', v_amtpacup9);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
    if tcontpms_rec.codincom10 is not null then
       obj_sub_detail := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_sub_detail.put('coderror', '200');
      obj_sub_detail.put('rownumber',v_rcnt - 1);
      obj_sub_detail.put('codincom', tcontpms_rec.codincom10);
      obj_sub_detail.put('desc_codincom', tcontpms_rec.desc10);
      obj_sub_detail.put('amtproba', v_amtproba10);
      obj_sub_detail.put('amtpacup', v_amtpacup10);
      obj_sub_detail_grp.put(to_char(v_rcnt - 1), obj_sub_detail);
    end if;
      obj_rowdetail.put('rows', obj_sub_detail_grp);

      obj_detail.put('table', obj_rowdetail);

      if v_flgDisabled then
        v_response  := replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null);
      end if;
      obj_detail.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
      obj_detail.put('isAdd', isAdd);
      obj_detail.put('isEdit', isEdit);
      obj_detail.put('msqerror', v_response);
--      obj_row.put(0, obj_detail);
    json_str_output := obj_detail.to_clob;
  end;
  procedure genIndexOld (json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_codempid    varchar2( 100 char);

    cursor c_temploy1 is
      select codempid, codcomp
        from temploy1
       where codcomp = nvl(p_codcompy, codcomp);
  begin

    obj_row     := json_object_t();
    for r1 in c_temploy1 loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;

      obj_data.put('coderror', '200');
      obj_data.put('rownumber', v_rcnt);
      obj_data.put('codempid', r1.codempid);
      obj_data.put('codcomp', r1.codcomp);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end;

    procedure save_detail (json_str_input in clob, json_str_output out clob) is
        json_obj            json_object_t;
        param_json          json_object_t;
        param_json_row      json_object_t;
        param_json_namfrm   json_object_t;
        obj_syncond         json_object_t;
        v_rownum            number;
        index_json           json_object_t;
        p_codfrm_detail      tincpos.CODFRM%type;
        v_flgAdd            boolean;
        v_flgDelete         boolean;
        v_tincpos           tincpos%rowtype;
        begin
            initial_value_detail(json_str_input);
            json_obj            := json_object_t(json_str_input);
            index_json          := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'p_index'),'rows');
            p_codfrm_detail     := hcm_util.get_string_t(json_obj,'p_codfrm');

            for i in 0..index_json.get_size-1 loop
                param_json_row  := hcm_util.get_json_t(index_json,to_char(i));
                p_codcompy      := hcm_util.get_string_t(param_json_row,'codcompy');
                p_dteeffec      := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'), 'dd/mm/yyyy');
                p_dteeffeco     := to_date(hcm_util.get_string_t(param_json_row,'dteeffeco'), 'dd/mm/yyyy');
                p_codfrm      := hcm_util.get_string_t(param_json_row,'codfrm');
                v_flgAdd        := hcm_util.get_boolean_t(param_json_row,'flgAdd');
                v_flgDelete     := hcm_util.get_boolean_t(param_json_row,'flgDelete');

                if p_codfrm <> p_codfrm_detail then
                    if v_flgDelete then
                      begin
                        delete from tincpos
                              where codcompy = p_codcompy
                               and dteeffec = p_dteeffec
                               and codfrm = p_codfrm;
                      end;
                    elsif v_flgAdd then  
                        begin
                            select * 
                              into v_tincpos
                              from tincpos
                             where codcompy = p_codcompy
                               and dteeffec = p_dteeffeco
                               and codfrm = p_codfrm;
                        exception when no_data_found then
                            v_tincpos := null;
                        end;
                        begin
                            insert into tincpos (codcompy,dteeffec,codfrm,
                                                 namfrme,namfrmt,namfrm3,namfrm4,namfrm5,
                                                 syncond,
                                                 amtproba1,amtproba2,amtproba3,amtproba4,amtproba5,
                                                 amtproba6,amtproba7,amtproba8,amtproba9,amtproba10,
                                                 amtpacup1,amtpacup2,amtpacup3,amtpacup4,amtpacup5,
                                                 amtpacup6,amtpacup7,amtpacup8,amtpacup9,amtpacup10,
                                                 dtecreate,codcreate,dteupd,coduser,statement)
                            values (p_codcompy,p_dteeffec,v_tincpos.codfrm,
                                                 v_tincpos.namfrme,v_tincpos.namfrmt,v_tincpos.namfrm3,v_tincpos.namfrm4,v_tincpos.namfrm5,
                                                 v_tincpos.syncond,
                                                 v_tincpos.amtproba1,v_tincpos.amtproba2,v_tincpos.amtproba3,v_tincpos.amtproba4,v_tincpos.amtproba5,
                                                 v_tincpos.amtproba6,v_tincpos.amtproba7,v_tincpos.amtproba8,v_tincpos.amtproba9,v_tincpos.amtproba10,
                                                 v_tincpos.amtpacup1,v_tincpos.amtpacup2,v_tincpos.amtpacup3,v_tincpos.amtpacup4,v_tincpos.amtpacup5,
                                                 v_tincpos.amtpacup6,v_tincpos.amtpacup7,v_tincpos.amtpacup8,v_tincpos.amtpacup9,v_tincpos.amtpacup10,
                                                 sysdate,global_v_coduser,sysdate,global_v_coduser,v_tincpos.statement);
                        exception when dup_val_on_index then
                            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
                            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
                            return;
                        end;
                    end if;
                end if;
            end loop;

            obj_syncond         := hcm_util.get_json_t(json_obj,'p_syncond');
            v_syncond           := hcm_util.get_string_t(obj_syncond, 'code');
            v_statement         := hcm_util.get_string_t(obj_syncond, 'statement');
            p_codfrm            := hcm_util.get_string_t(json_obj,'p_codfrm');
            v_namfrm            := hcm_util.get_string_t(json_obj,'p_namfrm');
            v_namfrme           := hcm_util.get_string_t(json_obj,'p_namfrme');
            v_namfrmt           := hcm_util.get_string_t(json_obj,'p_namfrmt');
            v_namfrm3           := hcm_util.get_string_t(json_obj,'p_namfrm3');
            v_namfrm4           := hcm_util.get_string_t(json_obj,'p_namfrm4');
            v_namfrm5           := hcm_util.get_string_t(json_obj,'p_namfrm5');
            param_json          := hcm_util.get_json_t(hcm_util.get_json_t(json_obj, 'param_json'),'rows');

            for i in 0..param_json.get_size-1 loop
                param_json_row       := hcm_util.get_json_t(param_json,to_char(i));
                v_rownum             := hcm_util.get_string_t(param_json_row, 'rownumber');
                if v_rownum = 0 then
                    v_amtproba1      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup1      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 1 then
                    v_amtproba2      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup2      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 2 then
                    v_amtproba3      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup3      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 3 then
                    v_amtproba4      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup4      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 4 then
                    v_amtproba5      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup5      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 5 then
                    v_amtproba6      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup6      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 6 then
                    v_amtproba7      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup7      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 7 then
                    v_amtproba8      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup8      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 8 then
                    v_amtproba9      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup9      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                elsif v_rownum = 9 then
                    v_amtproba10      := stdenc(hcm_util.get_string_t(param_json_row, 'amtproba'),p_codfrm,v_chken);
                    v_amtpacup10      := stdenc(hcm_util.get_string_t(param_json_row, 'amtpacup'),p_codfrm,v_chken);
                end if;
            end loop;
            save_detail_main;
            if param_msg_error is null then
                param_msg_error := get_error_msg_php('HR2401',global_v_lang);
            end if;
            json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
      end save_detail;

    procedure save_detail_main is
        begin
             begin
                update tincpos 
                   set namfrme = v_namfrme, namfrmt = v_namfrmt, namfrm3 = v_namfrm3, namfrm4 = v_namfrm4, namfrm5 = v_namfrm5,
                       syncond = v_syncond, amtproba1 = nvl(v_amtproba1,amtproba1), amtproba2 = nvl(v_amtproba2,amtproba2), amtproba3 = nvl(v_amtproba3,amtproba3), amtproba4 = nvl(v_amtproba4,amtproba4), amtproba5 = nvl(v_amtproba5,amtproba5),
                       amtproba6 = nvl(v_amtproba6,amtproba6), amtproba7 = nvl(v_amtproba7,amtproba7), amtproba8 = nvl(v_amtproba8,amtproba8), amtproba9 = nvl(v_amtproba9,amtproba9), amtproba10 = nvl(v_amtproba10,amtproba10),
                       amtpacup1 = nvl(v_amtpacup1,amtpacup1), amtpacup2 = nvl(v_amtpacup2,amtpacup2), amtpacup3 = nvl(v_amtpacup3,amtpacup3), amtpacup4 = nvl(v_amtpacup4,amtpacup4), amtpacup5  = nvl(v_amtpacup5,amtpacup5),
                       amtpacup6 = nvl(v_amtpacup6,amtpacup6), amtpacup7 = nvl(v_amtpacup7,amtpacup7), amtpacup8 = nvl(v_amtpacup8,amtpacup8), amtpacup9 = nvl(v_amtpacup9,amtpacup9), amtpacup10 = nvl(v_amtpacup10,amtpacup10),
                       coduser = global_v_coduser,statement = v_statement
                 where codcompy =  p_codcompy
                   and dteeffec = p_dteeffec
                   and codfrm = p_codfrm;
                if sql%rowcount = 0 then
                    insert into tincpos (codcompy,dteeffec,codfrm,namfrme,namfrmt,namfrm3,namfrm4,namfrm5,
                                syncond,amtproba1,amtproba2,amtproba3,amtproba4,amtproba5,amtproba6,amtproba7,
                                amtproba8,amtproba9,amtproba10,amtpacup1,amtpacup2,amtpacup3,amtpacup4,amtpacup5,
                                amtpacup6,amtpacup7,amtpacup8,amtpacup9,amtpacup10,codcreate,coduser,statement)
                    values (p_codcompy, p_dteeffec, p_codfrm, v_namfrme, v_namfrmt, v_namfrm3, v_namfrm4, v_namfrm5,
                            v_syncond, v_amtproba1, v_amtproba2, v_amtproba3, v_amtproba4, v_amtproba5, v_amtproba6,
                            v_amtproba7, v_amtproba8, v_amtproba9, v_amtproba10, v_amtpacup1, v_amtpacup2, v_amtpacup3,
                            v_amtpacup4, v_amtpacup5, v_amtpacup6, v_amtpacup7, v_amtpacup8, v_amtpacup9, v_amtpacup10,
                            global_v_coduser, global_v_coduser,v_statement);
                end if;
            exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;    
            end;
        commit;
        exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    end save_detail_main;

    procedure save_index (json_str_input in clob, json_str_output out clob) is
    begin
        save_index_data(json_str_input, json_str_output);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);

    exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400', param_msg_error, global_v_lang);
    end save_index;

    procedure save_index_data (json_str_input in clob, json_str_output out clob) is
        json_str            json_object_t;
        param_json          json_object_t;
        param_json_row      json_object_t;
        v_dteeffec          date;
        v_flgAdd            boolean;
        v_flgDelete         boolean;
        v_flg               varchar2(1000);
        v_tincpos           tincpos%rowtype;
      begin
        json_str               := json_object_t(json_str_input);
        param_json             := hcm_util.get_json_t(json_str, 'param_json');
        for i in 0..param_json.get_size-1 loop
            param_json_row      := hcm_util.get_json_t(param_json,to_char(i));
            p_codfrm            := hcm_util.get_string_t(param_json_row, 'codfrm');
            p_codcompy          := hcm_util.get_string_t(param_json_row, 'codcompy');
            p_dteeffec          := to_date(hcm_util.get_string_t(param_json_row,'dteeffec'), 'dd/mm/yyyy');
            p_dteeffeco         := to_date(hcm_util.get_string_t(param_json_row,'dteeffeco'), 'dd/mm/yyyy');
            v_flg               := hcm_util.get_string_t(param_json_row,'flg');
            if v_flg = 'delete' then
                begin
                    delete tincpos
                     where codfrm = p_codfrm
                       and codcompy = p_codcompy
                       and dteeffec = p_dteeffec;
                    commit;
                exception when others then 
                    null;
                end;
            elsif v_flg = 'add' then  
                begin
                    select * 
                      into v_tincpos
                      from tincpos
                     where codcompy = p_codcompy
                       and dteeffec = p_dteeffeco
                       and codfrm = p_codfrm;
                exception when no_data_found then
                    v_tincpos := null;
                end;
                begin
                    insert into tincpos (codcompy,dteeffec,codfrm,
                                         namfrme,namfrmt,namfrm3,namfrm4,namfrm5,
                                         syncond,
                                         amtproba1,amtproba2,amtproba3,amtproba4,amtproba5,
                                         amtproba6,amtproba7,amtproba8,amtproba9,amtproba10,
                                         amtpacup1,amtpacup2,amtpacup3,amtpacup4,amtpacup5,
                                         amtpacup6,amtpacup7,amtpacup8,amtpacup9,amtpacup10,
                                         dtecreate,codcreate,dteupd,coduser,statement)
                    values (p_codcompy,p_dteeffec,v_tincpos.codfrm,
                                         v_tincpos.namfrme,v_tincpos.namfrmt,v_tincpos.namfrm3,v_tincpos.namfrm4,v_tincpos.namfrm5,
                                         v_tincpos.syncond,
                                         v_tincpos.amtproba1,v_tincpos.amtproba2,v_tincpos.amtproba3,v_tincpos.amtproba4,v_tincpos.amtproba5,
                                         v_tincpos.amtproba6,v_tincpos.amtproba7,v_tincpos.amtproba8,v_tincpos.amtproba9,v_tincpos.amtproba10,
                                         v_tincpos.amtpacup1,v_tincpos.amtpacup2,v_tincpos.amtpacup3,v_tincpos.amtpacup4,v_tincpos.amtpacup5,
                                         v_tincpos.amtpacup6,v_tincpos.amtpacup7,v_tincpos.amtpacup8,v_tincpos.amtpacup9,v_tincpos.amtpacup10,
                                         sysdate,global_v_coduser,sysdate,global_v_coduser,v_tincpos.statement);
                exception when dup_val_on_index then
                    null;
                end;
            end if;
        end loop;
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end save_index_data;


  procedure gen_flg_status as
    v_dteeffec        date;
    v_count           number := 0;
    v_maxdteeffec     date;
  begin
    begin
     select count(*) into v_count
       from tincpos
      where codcompy = p_codcompy
       and dteeffec  = p_dteeffec;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then
      select max(dteeffec) into v_maxdteeffec
        from tincpos
       where codcompy = p_codcompy
         and dteeffec <= p_dteeffec;

      if v_maxdteeffec is null then
        select min(dteeffec) into v_maxdteeffec
          from tincpos
         where codcompy = p_codcompy
           and dteeffec > p_dteeffec;
        if v_maxdteeffec is null then
            v_flgDisabled       := false;
        else 
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        end if;
      else  
        if p_dteeffec < trunc(sysdate) then
            v_flgDisabled       := true;
            p_dteeffecquery     := v_maxdteeffec;
            p_dteeffec          := v_maxdteeffec;
        else
            v_flgDisabled       := false;
            p_dteeffecquery     := v_maxdteeffec;
        end if;
      end if;
    else
      if p_dteeffec < trunc(sysdate) then
        v_flgDisabled := true;
      else
        v_flgDisabled := false;
      end if;
      p_dteeffecquery := p_dteeffec;
    end if;

    if p_dteeffecquery < p_dteeffec then
        isAdd           := true; 
        isEdit          := false;
    else
        isAdd           := false;
        isEdit          := not v_flgDisabled;
    end if;

--    if forceAdd = 'Y' then
--      isEdit := false;
--      isAdd  := true;
--    end if;
  end;
end HRPMB5E;

/

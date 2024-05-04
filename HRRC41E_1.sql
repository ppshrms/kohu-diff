--------------------------------------------------------
--  DDL for Package Body HRRC41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC41E" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
  begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
  begin
--  get index parameter
    p_codcomp       := hcm_util.get_string_t(data_obj, 'p_codcomp');
    p_dteempmtst    := to_date(hcm_util.get_string_t(data_obj, 'p_dteempmtst') ,'dd/mm/yyyy');
    p_dteempmten    := to_date(hcm_util.get_string_t(data_obj, 'p_dteempmten') ,'dd/mm/yyyy');
--  gen id parameter
    p_numappl       := hcm_util.get_string_t(data_obj, 'p_numappl');
    p_dteempmt      := to_date(hcm_util.get_string_t(data_obj, 'p_dteempmt') ,'dd/mm/yyyy');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

    if p_dteempmtst > p_dteempmten then
        param_msg_error := get_error_msg_php('HR2021', global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure insert_or_update_temploy1(v_codempid varchar2, v_tapplinf tapplinf%rowtype) as
    v_numlvl         temploy1.numlvl%type;
    v_dteduepr       temploy1.dteduepr%type;
    v_qtyduepr       tapplcfm.qtyduepr%type;
  begin
    begin
        select joblvlst into v_numlvl
        from tjobpos
        where codpos = v_tapplinf.codposc
          and codcomp = v_tapplinf.codcomp;
    exception when no_data_found then
        v_numlvl := '';
    end;

    /*begin
        select qtyduepr into v_qtyduepr
        from tapplcfm
        where numdoc = v_tapplinf.numdoc;
    exception when no_data_found then
        v_qtyduepr := 0;
    end;*/

    if v_tapplinf.qtyduepr > 0 then
      v_dteduepr := v_tapplinf.dteempmt + v_tapplinf.qtyduepr - 1;
    else
      v_dteduepr := null;
    end if;

    insert into temploy1
        (
            codempid, namfirste, namfirstt, namfirst3, namfirst4, namfirst5,
            namlaste, namlastt, namlast3, namlast4, namlast5, namempe, namempt,
            namemp3, namemp4, namemp5, nickname, nicknamt, nicknam3, nicknam4,
            nicknam5, dteempdb, stamarry, codsex, stamilit, dteempmt, codcomp,
            codpos, numlvl, staemp, flgatten, codbrlc, codempmt, dteduepr, qtydatrq,
            numtelof, nummobile, email, numappl, codposc, stadisb, numdisab, typdisp,
            dtedisb, dtedisen, desdisp, codcreate, coduser,staappr,numreqst
        )
    values
        (
            v_codempid, v_tapplinf.namfirste, v_tapplinf.namfirstt, v_tapplinf.namfirst3, v_tapplinf.namfirst4,
            v_tapplinf.namfirst5, v_tapplinf.namlaste, v_tapplinf.namlastt, v_tapplinf.namlast3, v_tapplinf.namlast4,
            v_tapplinf.namlast5, v_tapplinf.namempe, v_tapplinf.namempt, v_tapplinf.namemp3, v_tapplinf.namemp4,
            v_tapplinf.namemp5, v_tapplinf.nickname, v_tapplinf.nickname, v_tapplinf.nickname, v_tapplinf.nickname,
            v_tapplinf.nickname, v_tapplinf.dteempdb, v_tapplinf.stamarry, v_tapplinf.codsex, v_tapplinf.stamilit,
            v_tapplinf.dteempmt, v_tapplinf.codcomp, v_tapplinf.codposc, v_numlvl, '0', 'Y', v_tapplinf.codbrlc1,
            v_tapplinf.codempmt, v_dteduepr, v_tapplinf.qtywkemp, v_tapplinf.numteleh, v_tapplinf.numtelem, v_tapplinf.email,
            v_tapplinf.numappl, v_tapplinf.codposc, v_tapplinf.stadisb, v_tapplinf.numdisab, v_tapplinf.typdisp,
            v_tapplinf.dtedisb, v_tapplinf.dtedisen, v_tapplinf.desdisp, global_v_lang, global_v_lang, 'P',v_tapplinf.numreqc
        );
  end insert_or_update_temploy1;

  procedure insert_or_update_temploy2(v_codempid varchar2, v_tapplinf tapplinf%rowtype) as
  begin
    insert into temploy2
        (
            codempid, adrrege, adrregt, adrreg3, adrreg4, adrreg5,
            codsubdistr, coddistr, codprovr, codcntyr, codpostr,
            adrconte, adrcontt, adrcont3, adrcont4, adrcont5,
            codsubdistc, coddistc, codprovc, codcntyc, codpostc,
            numtelec, codblood, weight, high, codrelgn, codorgin,
            codnatnl, coddomcl, numoffid, adrissue, codprovi,
            dteoffid, numlicid, dtelicid, numpasid, dtepasid,
            codcreate, coduser

        )
    values
        (
            v_codempid, v_tapplinf.adrrege, v_tapplinf.adrregt, v_tapplinf.adrreg3, v_tapplinf.adrreg4,
            v_tapplinf.adrreg5, v_tapplinf.codsubdistr, v_tapplinf.coddistr, v_tapplinf.codprovr, v_tapplinf.codcntyi,
            v_tapplinf.codposte, v_tapplinf.adrconte, v_tapplinf.adrcontt, v_tapplinf.adrcont3, v_tapplinf.adrcont4,
            v_tapplinf.adrcont5, v_tapplinf.codsubdistc, v_tapplinf.coddistc, v_tapplinf.codprovc, v_tapplinf.codcntyc,
            v_tapplinf.codposte, v_tapplinf.numteleh, v_tapplinf.codblood, v_tapplinf.weight, v_tapplinf.height, v_tapplinf.codrelgn,
            v_tapplinf.codorgin, v_tapplinf.codnatnl, v_tapplinf.coddomcl, v_tapplinf.numoffid, v_tapplinf.adrissue, v_tapplinf.codprov,
            v_tapplinf.dteoffid, v_tapplinf.numlicid, v_tapplinf.dtelicid, v_tapplinf.numpasid, v_tapplinf.dtepasid,
            global_v_lang, global_v_lang
        );
  end;

  procedure insert_temploy3(v_codempid varchar2, v_tapplinf tapplinf%rowtype) as
    v_amtincom1     tapplcfm.amtincom1%type;
    v_amtincom2     tapplcfm.amtincom1%type;
    v_amtincom3     tapplcfm.amtincom1%type;
    v_amtincom4     tapplcfm.amtincom1%type;
    v_amtincom5     tapplcfm.amtincom1%type;
    v_amtincom6     tapplcfm.amtincom1%type;
    v_amtincom7     tapplcfm.amtincom1%type;
    v_amtincom8     tapplcfm.amtincom1%type;
    v_amtincom9     tapplcfm.amtincom1%type;
    v_amtincom10    tapplcfm.amtincom1%type;

  begin
    begin
        select amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
               amtincom6, amtincom7, amtincom8, amtincom9, amtincom10
        into v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
             v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
        from tapplcfm
        where numappl = p_numappl
          and stasign = 'Y';
    exception when no_data_found then
        v_amtincom1  := '';
        v_amtincom2  := '';
        v_amtincom3  := '';
        v_amtincom4  := '';
        v_amtincom5  := '';
        v_amtincom6  := '';
        v_amtincom7  := '';
        v_amtincom8  := '';
        v_amtincom9  := '';
        v_amtincom10 := '';
    end;

    insert into temploy3
        (
            codempid, codcurr, amtincom1, amtincom2, amtincom3, amtincom4, amtincom5,
            amtincom6, amtincom7, amtincom8, amtincom9, amtincom10, numtaxid,
            numsaid, flgtax, typtax, typincom, codcreate, coduser
        )
    values
        (
            v_codempid, v_tapplinf.codcurr, v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4 ,v_amtincom5,
            v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10, v_tapplinf.numtaxid,
            v_tapplinf.numsaid, '1', '1', '1', global_v_coduser, global_v_coduser
        );
  end insert_temploy3;

  procedure insert_tspouse(v_codempid varchar2) as
    v_tapplfm      tapplfm%rowtype;
  begin
    begin
        select * into v_tapplfm
        from tapplfm
        where numappl = p_numappl;
    exception when no_data_found then
        v_tapplfm := null;
    end;

    insert into tspouse
        (
            codempid, codempidsp, namimgsp, codtitle, namfirste,
            namfirstt, namfirst3, namfirst4, namfirst5, namlaste,
            namlastt, namlast3, namlast4, namlast5, namspe, namspt,
            namsp3, namsp4, namsp5, numoffid, codspocc, codcreate, coduser
        )
    values
        (
            v_codempid, v_tapplfm.codempidsp, v_tapplfm.namimgsp, v_tapplfm.codtitle, v_tapplfm.namfirst,
            v_tapplfm.namfirst, v_tapplfm.namfirst, v_tapplfm.namfirst, v_tapplfm.namfirst, v_tapplfm.namlast,
            v_tapplfm.namlast, v_tapplfm.namlast, v_tapplfm.namlast, v_tapplfm.namlast, v_tapplfm.namsp,
            v_tapplfm.namsp, v_tapplfm.namsp, v_tapplfm.namsp, v_tapplfm.namsp, v_tapplfm.numoffid, v_tapplfm.codspocc,
            global_v_coduser, global_v_coduser
        );

  end insert_tspouse;

  procedure insert_trelatives(v_codempid varchar2) as
    v_max   number;
    cursor c1 is
        select *
        from tapplrel
        where numappl = p_numappl
        order by numseq;
  begin
    for i in c1 loop
        begin
            select max(numseq)+1 into v_max
            from trelatives
            where codempid = v_codempid;
        exception when no_data_found then
            v_max := null;
        end;

        if v_max is null then
            v_max := 1;
        end if;

        begin
            insert into trelatives
                (
                    namrele,namrelt,namrel3,namrel4,namrel5,numtelec,adrcomt,codempid, numseq,codcreate, coduser
                )
            values
                (
                    i.namrel,i.namrel,i.namrel,i.namrel,i.namrel,i.numtelec,i.adrcomt,v_codempid, v_max,global_v_coduser, global_v_coduser
                );
        exception when dup_val_on_index then
            update trelatives
            set coduser = global_v_coduser,
                namrele = i.namrel,
                namrelt = i.namrel,
                namrel3 = i.namrel,
                namrel4 = i.namrel,
                namrel5 = i.namrel,
                numtelec = i.numtelec,
                adrcomt =  i.adrcomt
            where codempid = v_codempid
              and numseq = v_max;
        end;
    end loop;
  end insert_trelatives;

  procedure update_tapplinf(v_codempid varchar2) as
  begin
    update tapplinf
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tapplinf;

  procedure update_tappldoc(v_codempid varchar2) as
  begin
    update tappldoc
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tappldoc;

  procedure update_tapplref(v_codempid varchar2) as
  begin
    update tapplref
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tapplref;

  procedure update_tapplwex(v_codempid varchar2) as
  begin
    update tapplwex
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tapplwex;

  procedure update_ttrainbf(v_codempid varchar2) as
  begin
    update ttrainbf
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_ttrainbf;

  procedure update_teducatn(v_codempid varchar2) as
  begin
    update teducatn
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_teducatn;

  procedure update_tcmptncy(v_codempid varchar2) as
  begin
    update tcmptncy
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tcmptncy;

  procedure update_tcmptncy2(v_codempid varchar2) as
  begin
    update tcmptncy2
    set codempid = v_codempid,
        coduser = global_v_coduser
    where numappl = p_numappl;

  end update_tcmptncy2;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
--<< softberry || 10/03/2023 || #8767
    v_letter        varchar2(4000 char);  
    v_temp          varchar(1 char);
    v_numreq        tapplcfm.numreqrq%type;
-->> softberry || 10/03/2023 || #8767    
    cursor c1 is
        select numappl, codempid, codpos, codcomp, dteempmt, get_temploy_name(codempid, global_v_lang) as namemptt
        from temploy1
        where codcomp like p_codcomp || '%'
          and dteempmt between p_dteempmtst and p_dteempmten
          and staemp = 0
          and numappl is not null

        union

        select numappl, codempid, codposc as codpos, codcomp, dteempmt,
              decode(global_v_lang, '101', a.namempe,
                                    '102', a.namempt,
                                    '103', a.namemp3,
                                    '104', a.namemp4,
                                    '105', a.namemp5) namemptt
        from tapplinf a
        where codcomp like p_codcomp || '%'
          and dteempmt between p_dteempmtst and p_dteempmten
          and statappl = '51'
          and codempid is null
        order by numappl;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('numappl', i.numappl);
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('namemptt', i.namemptt);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('desc_codposc', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('dteapps1', to_char(i.dteempmt, 'dd/mm/yyyy'));
--<< softberry || 10/03/2023 || #8767
        v_letter := get_label_name('HRRC41E',global_v_lang,120);
        begin
            select b.numreqrq  into v_numreq
            from tapplinf a, tapplcfm b
            where a.numappl = i.numappl
            and b.numappl = a.numappl
            and b.numdoc = a.numdoc
            and rownum = 1;
        exception when no_data_found then
          v_numreq := null;
        end;
        begin
            select 'x' into v_temp
            from tapplcfmd a
            where a.numappl = i.numappl
            and a.numreqrq = v_numreq
            and a.codposrq = i.codpos
            and a.numreqrq is not null 
            and rownum = 1;
        exception when no_data_found then
          v_letter := '';
        end;   
-->> softberry || 10/03/2023 || #8767         
        obj_data.put('letter', v_letter); -->> softberry || 10/03/2023 || #8767 || obj_data.put('letter', get_label_name('HRRC41E',global_v_lang,120));
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    if  v_row = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    end if;

  end gen_index;

  procedure gen_id_for_obj as
    v_groupid   long;
    v_id        long;
    v_year      number;
    v_month     number;
    v_running   long;
    v_table     long;
    v_error     long;
    v_tapplinf       tapplinf%rowtype;
  begin
    begin
       select * into v_tapplinf
         from tapplinf
        where numappl = p_numappl;
    exception when no_data_found then
      v_tapplinf := null;
    end;
    std_genid2.gen_id(v_tapplinf.codcomp, v_tapplinf.codempmt, v_tapplinf.codbrlc1, v_tapplinf.dteempmt, v_groupid, v_id,v_year, v_month, v_running, v_table, v_error);
    if v_error is not null then
      param_msg_error   := get_error_msg_php(v_error,global_v_lang,v_table);
      return;
    end if;
    std_genid2.upd_id(v_groupid, v_year, v_month, v_running, global_v_coduser);

    insert_or_update_temploy1(v_id, v_tapplinf);
    insert_or_update_temploy2(v_id, v_tapplinf);
    insert_temploy3(v_id, v_tapplinf);
    insert_tspouse(v_id);
    insert_trelatives(v_id);
    update_tapplinf(v_id);
    update_tappldoc(v_id);
    update_tapplref(v_id);
    update_tapplwex(v_id);
    update_teducatn(v_id);
    update_ttrainbf(v_id);
    update_tcmptncy(v_id);
    update_tcmptncy2(v_id);

  end gen_id_for_obj;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

  procedure get_id(json_str_input in clob, json_str_output out clob) AS
      json_obj       json_object_t;
    data_obj       json_object_t;

    v_codempid      temploy1.codempid%type;
  begin
    initial_current_user_value(json_str_input);
    json_obj    := json_object_t(json_str_input);
    param_json  := hcm_util.get_json_t(json_obj,'param_json');
    for i in 0..param_json.get_size -1 loop
        data_obj := hcm_util.get_json_t(param_json,to_char(i));
        initial_params(data_obj);
        v_codempid := hcm_util.get_string_t(data_obj, 'codempid');
--        if v_codempid is null then
         gen_id_for_obj;  --03/11/2022

--        end if;
    end loop;
    if param_msg_error is null then
        commit;
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
        rollback;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_id;

  procedure gen_message ( v_codform in varchar2, o_message1 out clob, o_namimglet out varchar2,
                          o_message2 out clob, o_typemsg2 out long, o_message3 out clob) is
  begin
    begin
      select message, namimglet into o_message1, o_namimglet
        from tfmrefr
       where codform = v_codform;
    exception when no_data_found then
      o_message1  := null;
      o_namimglet := null;
    end;
    begin
      select message, typemsg
        into o_message2, o_typemsg2
        from tfmrefr2
       where codform = v_codform;
    exception when no_data_found then
      o_message2 := null;
      o_typemsg2 := null;
    end;
    begin
      select message
        into o_message3
        from tfmrefr3
       where codform = v_codform;
    exception when no_data_found then
      o_message3 := null;
    end;
  end;

  function replace_html_param(v_param clob,v_codpos varchar2,v_numreq varchar) return varchar2 is
    v_result    clob;
    cursor c1 is
        select fparam,fvalue
        from tapplcfmd
        where numappl = p_numappl
        and numreqrq = v_numreq
        and codposrq = v_codpos;
  begin
    v_result := v_param;
    for i in c1 loop
        v_result := replace(v_result,i.fparam,i.fvalue);
    end loop;
    return v_result;
  end replace_html_param;

  function gen_html_tab_incom(v_codpos varchar2,v_numreq varchar2, v_sum out varchar2) return clob is
    rec_tapplcfm    tapplcfm%rowtype;
    v_str           clob;
    v_chken         varchar2(10 char);
    v_num number;
  begin
    v_chken := hcm_secur.get_v_chken;
    begin
        select *
          into rec_tapplcfm
          from tapplcfm
         where numappl = p_numappl
           and codposrq = v_codpos
           and numreqrq = v_numreq;
    exception when no_data_found then
      v_sum := '0.00';
      return v_str;
    end;
    v_num := stddec(rec_tapplcfm.amttotal, rec_tapplcfm.numappl, v_chken);
    v_sum := to_char(v_num,'fm9,999,990.00');
    if rec_tapplcfm.codincom1 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom1||' - '||get_tinexinf_name ( rec_tapplcfm.codincom1, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom1, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal1, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom2 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom2||' - '||get_tinexinf_name ( rec_tapplcfm.codincom2, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom2, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal2, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom3 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom3||' - '||get_tinexinf_name ( rec_tapplcfm.codincom3, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom3, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal3, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom4 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom4||' - '||get_tinexinf_name ( rec_tapplcfm.codincom4, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom4, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal4, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom5 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom5||' - '||get_tinexinf_name ( rec_tapplcfm.codincom5, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom5, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal5, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom6 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom6||' - '||get_tinexinf_name ( rec_tapplcfm.codincom6, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom6, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal6, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom7 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom7||' - '||get_tinexinf_name ( rec_tapplcfm.codincom7, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom7, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal7, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom8 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom8||' - '||get_tinexinf_name ( rec_tapplcfm.codincom8, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom8, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal8, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom9 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom9||' - '||get_tinexinf_name ( rec_tapplcfm.codincom9, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom9, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal9, global_v_lang)||'</td>
            </tr>';
    end if;
    if rec_tapplcfm.codincom10 is not null then
        v_str := v_str||'
            <tr>
                <td>'||rec_tapplcfm.codincom10||' - '||get_tinexinf_name ( rec_tapplcfm.codincom10, global_v_lang)||'</td>
                <td>'||stddec(rec_tapplcfm.amtincom10, rec_tapplcfm.numappl, v_chken)||'</td>
                <td>'||get_tlistval_name('NAMEUNIT', rec_tapplcfm.unitcal10, global_v_lang)||'</td>
            </tr>';
    end if;
    if v_str is not null then
        v_str := '<table>
                    <tr>
                        <td>'||get_label_name('HRRC41E',global_v_lang,140)||'</td>
                        <td>'||get_label_name('HRRC41E',global_v_lang,150)||'</td>
                        <td>'||get_label_name('HRRC41E',global_v_lang,160)||'</td>
                    </tr>'
                    ||v_str||
                 '</table>';
    end if;
    return v_str;
  end gen_html_tab_incom;

  procedure gen_html_message (json_str_output out clob) AS
    v_codform         tfmrefr.codform%type;
    v_codempid        tapplinf.codempid%type;
    v_codpos          tapplcfm.codposrq%type;
    v_numreq          tapplcfm.numreqrq%type;
    o_message1        clob;
    o_namimglet       tfmrefr.namimglet%type;
    o_message2        clob;
    o_typemsg2        tfmrefr2.typemsg%type;
    o_message3        clob;

    obj_data          json_object_t;
    v_rcnt            number := 0;

    v_namimglet       tfmrefr.namimglet%type;
    tfmrefr_message   tfmrefr.message%type;
    tfmrefr2_message  tfmrefr2.message%type;
    tfmrefr2_typemsg  tfmrefr2.typemsg%type;
    tfmrefr3_message  tfmrefr3.message%type;

    type html_array   is varray(3) of clob;
    list_msg_html     html_array;

    v_sum             varchar2(20 char);
  begin
    begin
        select b.codform,a.codempid,b.codposrq,b.numreqrq into v_codform,v_codempid,v_codpos,v_numreq
        from tapplinf a, tapplcfm b
        where a.numappl = p_numappl
        and b.numappl = a.numappl
        and b.numdoc = a.numdoc;
    exception when no_data_found then
        v_codform := null;
    end;

    gen_message(v_codform, o_message1, o_namimglet, o_message2, o_typemsg2, o_message3);
    list_msg_html := html_array(o_message1,o_message2,o_message3);

    if o_namimglet is not null then
        o_namimglet := get_tsetup_value('PATHDOC')||get_tfolderd('HRPMB9E')||'/'||o_namimglet;
    end if;

    o_message1 := replace_html_param(o_message1,v_codpos,v_numreq);
    o_message2 := replace(o_message2,'[PARAM-TABSAL]',gen_html_tab_incom(v_codpos,v_numreq,v_sum));
    o_message2 := replace(o_message2,'[PARAM-AMTNET]',v_sum);
    o_message2 := replace_html_param(o_message2,v_codpos,v_numreq);
    o_message3 := replace_html_param(o_message3,v_codpos,v_numreq);


    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('head_html',o_message1);
    obj_data.put('body_html',o_message2);
    obj_data.put('footer_html',o_message3);
    obj_data.put('head_letter', o_namimglet);

  json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_html_message;

  procedure get_html_message(json_str_input in clob, json_str_output out clob) AS
  begin
        initial_current_user_value(json_str_input);
        initial_params(json_object_t(json_str_input));
    if param_msg_error is null then
      gen_html_message(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_html_message;

    procedure send_mail_a(v_rowid VARCHAR, v_approvno TYRTRPLN.approvno%TYPE) as
        json_obj        json_object_t;
        v_codform       TFWMAILH.codform%TYPE;
        v_codapp        TFWMAILH.codapp%TYPE;
        v_codrespn      tyrtrpln.codrespn%TYPE;

        table_req       long;
        v_error            long;
        v_msg_to            clob;
        v_templete_to       clob;
        v_func_appr           varchar2(500 char);
        v_subject           varchar2(500 char);
    begin

        v_codapp := 'HRRC41E';
        table_req := 'TAPPLINF';

        begin
            select codform into v_codform
            from tfwmailh
            where codapp = v_codapp;
        exception when no_data_found then
            v_codform  := 'HRRC41ETO';
        end;

        begin
            select  decode(global_v_lang, '101', a.descode,
                                        '102', a.descodt,
                                        '103', a.descod3,
                                        '104', a.descod4,
                                        '105', a.descod5) into v_subject
            from tfrmmail a
            where codform = v_codform;
        exception when no_data_found then
            v_subject  := '';
        end;

        chk_flowmail.get_message(v_codapp, global_v_lang, v_msg_to, v_templete_to, v_func_appr);
        chk_flowmail.replace_text_frmmail(v_templete_to, table_req, v_rowid, v_subject, v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to,'N');

        v_error := chk_flowmail.send_mail_to_approve('HRRC43U', global_v_codempid, null, v_msg_to, NULL, v_subject, 'U', 'Y' , global_v_lang, v_approvno, null, null);

    end send_mail_a;

    procedure send_email(json_str_input in clob, json_str_output out clob) as
        v_rowid     varchar(20);
        v_numappl  TAPPLINF.numappl%type;
        json_obj    json_object_t;
    begin
        initial_current_user_value(json_str_input);
        json_obj    := json_object_t(json_str_input);
        param_json  := hcm_util.get_json_t(json_obj,'param_json');
        for i in 0..param_json.get_size-1 loop
            v_numappl     := hcm_util.get_string_t(param_json, to_char(i));
            begin
                select rowid into v_rowid
                from TAPPLINF
                where numappl = v_numappl;
            exception when no_data_found then
                v_rowid := null;
            end;
            if  v_rowid is not null then
                send_mail_a(v_rowid, 1);
            end if;
        end loop;

        if param_msg_error is not null then
            rollback;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            commit;
            param_msg_error := get_error_msg_php('HR2046',global_v_lang);
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end send_email;

END HRRC41E;

/

--------------------------------------------------------
--  DDL for Package Body HRAL3IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL3IX" as
-- last update: 04/04/2018 13:42
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    -- index params
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_codcomp           := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
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
  end get_data;

  procedure gen_data (json_str_output out clob) is
    v_flgdata           varchar2(1 char) := 'N';
    v_flgsecur          varchar2(1 char) := 'N';
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    causeupdte          varchar2(100 char);
    dataupdte           varchar2(100 char);
    oldval              varchar2(100 char);
    newval              varchar2(100 char);
    v_codcomp           varchar2(50 char);
    v_lvlst             number;
    v_lvlen             number;
    v_namcentlvl        varchar2(4000 char);
    v_namcent           varchar2(4000 char);
    v_comlevel          number;
    v_codempid          TEMPLOY1.CODEMPID%TYPE;
    v_check_secur       boolean;
    cursor c1 is
      select * from (
        select a.codcomp, b.codempid, a.numlvl, b.dtework, b.dteupd, b.codshift, b.coduser, b.rowid as rowin,
               qtylateo, qtylaten,
               qtyearlyo, qtyearlyn,
               qtyabsento, qtyabsentn,
               qtynostamo, qtynostamn,
               null as dteinold, null as timinold,
               null as dteinnew, null as timinnew,
               null as dteoutold, null as timoutold,
               null as dteoutnew, null as timoutnew,
               null as codchngold, null as codchngnew,
               null as codshifold, null as codshifnew,
               null as typworkold, null as typworknew,
               null as codcalenold, null as codcalennew,
               null as flgattenold, null as flgattennew,
               1 as insert_type
          from temploy1 a, tloglate b
         where b.codempid = a.codempid
           and b.codempid = nvl(p_codempid, b.codempid)
           and trunc(b.dtework) between p_dtestrt and p_dteend
           and a.codcomp like p_codcomp || '%'
--           and (b.qtynostamo is not null or b.qtynostamn is not null)

         union

        select a.codcomp, a.codempid, a.numlvl, b.dtework, b.dteupd, b.codshift, b.coduser, b.rowid as rowin,
               null as qtylateo, null as qtylaten,
               null as qtyearlyo, null as qtyearlyn,
               null as qtyabsento, null as qtyabsentn,
               b.qtynostamo, b.qtynostamn,
               b.dteinold, b.timinold,
               b.dteinnew, b.timinnew,
               b.dteoutold, b.timoutold,
               b.dteoutnew, b.timoutnew,
               b.codchngold, b.codchngnew,
               b.codshifold, b.codshifnew,
               b.typworkold, b.typworknew,
               b.codcalenold, b.codcalennew,
               b.flgattenold, b.flgattennew,
               2 as insert_type
          from temploy1 a, tlogtime b
         where a.codempid = b.codempid
           and a.codempid = nvl(p_codempid, a.codempid)
           and a.codcomp like p_codcomp || '%'
           and b.dtework between p_dtestrt and p_dteend
           and (b.qtynostamo is null or b.qtynostamn is null
                --check exists in tloglate
                or exists(select * from tloglate c
                           where c.codempid  = b.codempid
                             and c.dtework   = b.dtework
                             and c.qtynostamo = b.qtynostamo
                             and c.qtynostamn = b.qtynostamn))
      )
      order by codcomp, dteupd, coduser, codempid, dtework desc;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in c1 loop
      v_flgdata             := 'Y';
      v_codempid            := r1.codempid;
      v_check_secur         := SECUR_MAIN.SECUR2(v_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_check_secur then
        v_flgsecur          := 'Y';
        causeupdte          := '';
        dataupdte           := '';

        if r1.codchngnew is not null then
          causeupdte := get_tcodec_name('TCODTIME', r1.codchngnew, global_v_lang);
        end if;

        if r1.insert_type = 1 then

          if nvl(r1.codcalenold, '@#') <> nvl(r1.codcalennew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 50);
            oldval    := r1.codcalenold;
            newval    := r1.codcalennew;
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.typworkold, '@#') <> nvl(r1.typworknew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 60);
            oldval    := r1.typworkold;
            newval    := r1.typworknew;
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.codshifold, '@#') <> nvl(r1.codshifnew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 70);
            oldval    := r1.codshifold;
            newval    := r1.codshifnew;
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.dteinold, to_date('01/01/2000', 'DD/MM/YYYY')) <> nvl(r1.dteinnew, to_date('01/01/2000', 'DD/MM/YYYY')) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 80);
            oldval    := to_char(r1.dteinold,'DD/MM/YYYY');
            newval    := to_char(r1.dteinnew,'DD/MM/YYYY');
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if substr(r1.timinold, 1, 2) || ':' || substr(r1.timinold, 3, 2) <> substr(r1.timinnew, 1, 2) || ':' || substr(r1.timinnew, 3, 2) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 90);
            if r1.timinold is not null then
              oldval    := substr(r1.timinold, 1, 2) || ':' || substr(r1.timinold, 3, 2);
            end if;
            if r1.timinnew is not null then
              newval    := substr(r1.timinnew, 1, 2) || ':' || substr(r1.timinnew, 3, 2);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.dteoutold, to_date('01/01/2000', 'DD/MM/YYYY')) <>  nvl(r1.dteoutnew, to_date('01/01/2000', 'DD/MM/YYYY')) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 100);
            oldval    := to_char(r1.dteoutold,'DD/MM/YYYY');
            newval    := to_char(r1.dteoutnew,'DD/MM/YYYY');
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if substr(r1.timoutold, 1, 2) || ':' || substr(r1.timoutold, 3, 2) <> substr(r1.timoutnew, 1, 2) || ':' || substr(r1.timoutnew, 3, 2) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 110);
            if r1.timoutold is not null then
              oldval    := substr(r1.timoutold, 1, 2) || ':' || substr(r1.timoutold, 3, 2);
            end if;
            if r1.timoutnew is not null then
              newval    := substr(r1.timoutnew, 1, 2) || ':' || substr(r1.timoutnew, 3, 2);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.codchngold, '@#$') <> nvl(r1.codchngnew, '@#$') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 120);
            oldval    := get_tlistval_name('CODCHNG',r1.codchngold,global_v_lang);
          --newval    := get_tlistval_name('CODCHNG',r1.codchngnew,global_v_lang);
            newval    := get_tcodec_name('TCODTIME',r1.codchngnew, global_v_lang);
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
--          if nvl(r1.qtynostamo, 0) <> nvl(r1.qtynostamn, 0) then
--            dataupdte := get_label_name('HRAL3IX', global_v_lang, 130);
--            oldval    := r1.qtynostamo;
--            newval    := r1.qtynostamn;
--            obj_data        := json();
--            obj_data.put('coderror', '200');
--            obj_data.put('codempid', r1.codempid);
--            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
--            obj_data.put('codcomp', r1.codcomp);
--            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
--            obj_data.put('codshift', r1.codshift);
--            obj_data.put('image', get_emp_img(r1.codempid));
--            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
--            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
--            obj_data.put('coduser', r1.coduser);
--            obj_data.put('causeupdte', causeupdte);
--            obj_data.put('dataupdte', dataupdte);
--            obj_data.put('oldval', oldval);
--            obj_data.put('newval', newval);
--
--            obj_row.put(to_char(v_rcnt), obj_data);
--            v_rcnt          := v_rcnt + 1;
--          end if;
          if nvl(r1.flgattenold, '@#') <> nvl(r1.flgattennew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 140);
            oldval    := r1.flgattenold;
            newval    := r1.flgattennew;
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtylateo, 0) > 0 or nvl(r1.qtylaten, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 10);
            oldval    := hcm_util.convert_minute_to_time(r1.qtylateo);
            newval    := hcm_util.convert_minute_to_time(r1.qtylaten);
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtyearlyo, 0) > 0 or nvl(r1.qtyearlyn, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 20);
            oldval    := hcm_util.convert_minute_to_time(r1.qtyearlyo);
            newval    := hcm_util.convert_minute_to_time(r1.qtyearlyn);
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtyabsento, 0) > 0 or nvl(r1.qtyabsentn, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 30);
            oldval    := hcm_util.convert_minute_to_time(r1.qtyabsento);
            newval    := hcm_util.convert_minute_to_time(r1.qtyabsentn);
            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
        else
          if nvl(r1.codcalenold, '@#') <> nvl(r1.codcalennew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 50);
            oldval    := r1.codcalenold;
            newval    := r1.codcalennew;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.typworkold, '@#') <> nvl(r1.typworknew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 60);
            oldval    := r1.typworkold;
            newval    := r1.typworknew;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.codshifold, '@#') <> nvl(r1.codshifnew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 70);
            oldval    := r1.codshifold;
            newval    := r1.codshifnew;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.dteinold, to_date('01/01/2000', 'DD/MM/YYYY')) <> nvl(r1.dteinnew, to_date('01/01/2000', 'DD/MM/YYYY')) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 80);
            oldval    := to_char(r1.dteinold,'DD/MM/YYYY');
            if oldval is not null then
              oldval := to_char(r1.dteinold,'DD/MM/') || (to_number(to_char(r1.dteinold,'YYYY')) + hcm_appsettings.get_additional_year);
            end if;
            newval    := to_char(r1.dteinnew,'DD/MM/YYYY');
            if newval is not null then
              newval := to_char(r1.dteinnew,'DD/MM/') || (to_number(to_char(r1.dteinnew,'YYYY')) + hcm_appsettings.get_additional_year);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if substr(r1.timinold, 1, 2) || ':' || substr(r1.timinold, 3, 2) <> substr(r1.timinnew, 1, 2) || ':' || substr(r1.timinnew, 3, 2) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 90);
            if r1.timinold is not null then
              oldval    := substr(r1.timinold, 1, 2) || ':' || substr(r1.timinold, 3, 2);
            end if;
            if r1.timinnew is not null then
              newval    := substr(r1.timinnew, 1, 2) || ':' || substr(r1.timinnew, 3, 2);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.dteoutold, to_date('01/01/2000', 'DD/MM/YYYY')) <>  nvl(r1.dteoutnew, to_date('01/01/2000', 'DD/MM/YYYY')) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 100);
            oldval    := to_char(r1.dteoutold,'DD/MM/YYYY');
            if oldval is not null then
              oldval := to_char(r1.dteoutold,'DD/MM/') || (to_number(to_char(r1.dteoutold,'YYYY')) + hcm_appsettings.get_additional_year);
            end if;
            newval    := to_char(r1.dteoutnew,'DD/MM/YYYY');
            if newval is not null then
              newval := to_char(r1.dteoutnew,'DD/MM/') || (to_number(to_char(r1.dteoutnew,'YYYY')) + hcm_appsettings.get_additional_year);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if substr(r1.timoutold, 1, 2) || ':' || substr(r1.timoutold, 3, 2) <> substr(r1.timoutnew, 1, 2) || ':' || substr(r1.timoutnew, 3, 2) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 110);
            if r1.timoutold is not null then
              oldval    := substr(r1.timoutold, 1, 2) || ':' || substr(r1.timoutold, 3, 2);
            end if;
            if r1.timoutnew is not null then
              newval    := substr(r1.timoutnew, 1, 2) || ':' || substr(r1.timoutnew, 3, 2);
            end if;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.codchngold, '@#$') <> nvl(r1.codchngnew, '@#$') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 120);
            oldval    := get_tlistval_name('CODCHNG',r1.codchngold,global_v_lang);
          --newval    := get_tlistval_name('CODCHNG',r1.codchngnew,global_v_lang);
            newval    := get_tcodec_name('TCODTIME',r1.codchngnew, global_v_lang);
            obj_data  := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtynostamo, 0) <> nvl(r1.qtynostamn, 0) then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 130);
            oldval    := r1.qtynostamo;
            newval    := r1.qtynostamn;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.flgattenold, '@#') <> nvl(r1.flgattennew, '@#') then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 140);
            oldval    := r1.flgattenold;
            newval    := r1.flgattennew;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtylateo, 0) > 0 or nvl(r1.qtylaten, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 10);
            oldval    := hcm_util.convert_minute_to_time(r1.qtylateo);
            newval    := hcm_util.convert_minute_to_time(r1.qtylaten);

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtyearlyo, 0) > 0 or nvl(r1.qtyearlyn, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 20);
            oldval    := hcm_util.convert_minute_to_time(r1.qtyearlyo);
            newval    := hcm_util.convert_minute_to_time(r1.qtyearlyn);

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtyabsento, 0) > 0 or nvl(r1.qtyabsentn, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 30);
            oldval    := hcm_util.convert_minute_to_time(r1.qtyabsento);
            newval    := hcm_util.convert_minute_to_time(r1.qtyabsentn);

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
          if nvl(r1.qtynostamo, 0) > 0 or nvl(r1.qtynostamn, 0) > 0 then
            dataupdte := get_label_name('HRAL3IX', global_v_lang, 40);
            oldval    := r1.qtynostamo;
            newval    := r1.qtynostamn;

            obj_data        := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('dtework', to_char(r1.dtework, 'DD/MM/YYYY'));
            obj_data.put('codshift', r1.codshift);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('dteupd', to_char(r1.dteupd,'DD/MM/YYYY'));
            obj_data.put('timupd', to_char(r1.dteupd,'HH24:MI:SS'));
            obj_data.put('coduser', r1.coduser);
            obj_data.put('causeupdte', causeupdte);
            obj_data.put('dataupdte', dataupdte);
            obj_data.put('oldval', oldval);
            obj_data.put('newval', newval);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt          := v_rcnt + 1;
          end if;
        end if;

      end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tlogtime');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
			json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;

end HRAL3IX;

/

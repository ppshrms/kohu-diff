--------------------------------------------------------
--  DDL for Package Body HRAL1LB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL1LB" is
-- last update: 13/02/2018 10:13
  procedure initial_value(json_str in clob) is
    p_year          varchar2(100 char);
    json_obj        json_object_t;
    v_codcalen      varchar2(100 char);
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_batch_dtestrt := to_date(hcm_util.get_string_t(json_obj,'p_dtetim'),'dd/mm/yyyyhh24miss');

    --get_holiday
    p_codcomp   := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_codcalen  := upper(hcm_util.get_string_t(json_obj,'p_codcalen'));
    p_year      := hcm_util.get_string_t(json_obj,'p_dteyear');
    p_dteyear   := to_number(p_year);
    --set_holiday
    p_dtewrkst  := to_date(hcm_util.get_string_t(json_obj,'p_dtewrkst'), 'DD/MM/YYYY');
    p_dtewrken  := to_date(hcm_util.get_string_t(json_obj,'p_dtewrken'), 'DD/MM/YYYY');

    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcomp');
      return;
    else
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcalen is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcalen');
      return;
    else
      begin
        select codcodec
          into v_codcalen
          from tcodwork
          where codcodec = p_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodwork');
        return;
      end;
    end if;

    if p_dteyear is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dteyear');
      return;
    end if;

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index_save is
  begin
    if p_dtewrkst is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtewrkst');
      return;
    elsif p_dtewrken is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'dtewrken');
      return;
    end if;

    if to_number(to_char(p_dtewrkst,'yyyy')) <> p_dteyear then
      param_msg_error := get_error_msg_php('HR2025',global_v_lang, 'dtewrkst');
      return;
    end if;
    if to_number(to_char(p_dtewrken,'yyyy')) <> p_dteyear then
      param_msg_error := get_error_msg_php('HR2025',global_v_lang, 'dtewrken');
      return;
    end if;
    if p_dtewrkst > p_dtewrken then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang, 'dtewrkst');
      return;
    end if;
  end;

  procedure get_holiday(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_holiday(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_holiday;

  procedure gen_holiday(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    objLang         json_object_t;

    v_rcnt          number;
--<<user46 fix issue std 18/10/2021
--    cursor c_tgholidy is
--      select nvl(ghd.codcomp,p_codcomp) as codcomp,nvl(ghd.dteyear,hd.dteyear) as dteyear,nvl(ghd.dtedate,hd.dtedate) as dtedate,
--             nvl(ghd.typwork,hd.typwork) as typwork,nvl(ghd.desholdye,hd.desholdye) as desholdye,nvl(ghd.desholdyt,hd.desholdyt) as desholdyt,
--             nvl(ghd.desholdy3,hd.desholdy3) as desholdy3,nvl(ghd.desholdy4,hd.desholdy4) as desholdy4,nvl(ghd.desholdy5,hd.desholdy5) as desholdy5,
--             decode(global_v_lang, '101', nvl(ghd.desholdye,hd.desholdye),
--                                   '102', nvl(ghd.desholdyt,hd.desholdyt),
--                                   '103', nvl(ghd.desholdy3,hd.desholdy3),
--                                   '104', nvl(ghd.desholdy4,hd.desholdy4),
--                                   '105', nvl(ghd.desholdy5,hd.desholdy5),
--                                   '') desholdy,
--             nvl(ghd.dteupd,hd.dteupd) as dteupd, nvl(ghd.coduser,hd.coduser) as coduser, count(1) over() as totalrec
--        from tgholidy ghd full outer join
--             tholiday hd on (ghd.dteyear = hd.dteyear
--                             and hcm_util.get_codcomp_level(ghd.codcomp,1) = hd.codcompy
--                             and ghd.dtedate = hd.dtedate)
--       where nvl(ghd.dteyear,hd.dteyear) = p_dteyear
--         and nvl(upper(ghd.codcalen),p_codcalen) = p_codcalen
--         and p_codcomp like nvl(ghd.codcomp,hd.codcompy||'%') -- || '%'
--    order by dtedate ASC;

   cursor c_tgholidy is
      select codcomp, dteyear, dtedate, typwork,desholdye,desholdyt,desholdy3,desholdy4,desholdy5,
             decode(global_v_lang, '101', desholdye,
                                   '102', desholdyt,
                                   '103', desholdy3,
                                   '104', desholdy4,
                                   '105', desholdy5,
                                   '') desholdy,
             dteupd, coduser, count(1) over() as totalrec
        from tgholidy
       where dteyear = p_dteyear
         and upper(codcalen) = p_codcalen
         and codcomp = p_codcomp -- || '%'
    order by dtedate ASC;

    cursor c_tholiday is
      select codcompy, dteyear, dtedate, typwork,desholdye,desholdyt,desholdy3,desholdy4,desholdy5,
             decode(global_v_lang, '101', desholdye,
                                   '102', desholdyt,
                                   '103', desholdy3,
                                   '104', desholdy4,
                                   '105', desholdy5,
                                   '') desholdy,
             dteupd, coduser, count(1) over() as totalrec
        from tholiday
       where dteyear = p_dteyear
         and upper(codcompy) = hcm_util.get_codcomp_level(p_codcomp, 1)
    order by dtedate ASC;
-->>
  begin
    v_rcnt     := 0;
    obj_row    := json_object_t();
    for i in c_tgholidy loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('dteyear',i.dteyear + global_v_zyear);
      obj_data.put('dtedate',to_char(i.dtedate, 'DD/MM/YYYY'));
      obj_data.put('typwork',i.typwork);
      obj_data.put('desholdy',i.desholdy);
      obj_data.put('desholdye',i.desholdye);
      obj_data.put('desholdyt',i.desholdyt);
      obj_data.put('desholdy3',i.desholdy3);
      obj_data.put('desholdy4',i.desholdy4);
      obj_data.put('desholdy5',i.desholdy5);

      obj_data.put('dteupd',i.dteupd);
      obj_data.put('coduser',i.coduser);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if obj_row.get_size = 0 then
      for i in c_tholiday loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();

        obj_data.put('coderror', '200');
        obj_data.put('codcomp', i.codcompy);
        obj_data.put('dteyear',i.dteyear + global_v_zyear);
        obj_data.put('dtedate',to_char(i.dtedate, 'DD/MM/YYYY'));
        obj_data.put('typwork',i.typwork);
        obj_data.put('desholdy',i.desholdy);
        obj_data.put('desholdye',i.desholdye);
        obj_data.put('desholdyt',i.desholdyt);
        obj_data.put('desholdy3',i.desholdy3);
        obj_data.put('desholdy4',i.desholdy4);
        obj_data.put('desholdy5',i.desholdy5);

        obj_data.put('dteupd',i.dteupd);
        obj_data.put('coduser',i.coduser);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end gen_holiday;
  --
  procedure set_holiday(json_str_input in clob, json_str_output out clob) as
    v_dteeffec          date;
    v_dtework           date;
    v_dtelast           date;
    vv_stdate           date;
    v_exist             boolean;
    --v_flgworkth         varchar2(100 char);
    v_codcomp           varchar2(100 char);
    cursor c_codcomp is
      select codcomp, dteeffec, startday
        from tgrpwork a
       where codcomp like p_codcomp || '%'
         and codcalen = p_codcalen
         and dteeffec = (select max(dteeffec)
                           from tgrpwork b
                          where b.codcomp like p_codcomp || '%'
                            and b.codcalen  = p_codcalen
                            and b.dteeffec <= trunc(sysdate)
                            and a.codcomp = b.codcomp)
      group by codcomp,dteeffec,startday
      order by codcomp;
    cursor c_tgrpwork is
      select codshift, qtydwpp, qtydhpp, qtydaych ,numseq
        from tgrpwork
       where codcomp = v_codcomp
         and codcalen = p_codcalen
         and dteeffec = v_dteeffec
    order by numseq asc;
    cursor c_tgrpwork2 is
      select codshift, qtydwpp, qtydhpp, qtydaych ,numseq
        from tgrpwork
       where codcomp = v_codcomp
         and codcalen = p_codcalen
         and dteeffec = v_dteeffec
      order by numseq desc;
    cursor c_tgrpyear is
      select rowid
        from tgrpyear
       where codcomp = v_codcomp
         and codcalen = p_codcalen
         and dteyear  = (p_dteyear - global_v_zyear)
         and dtewrkst = p_dtewrkst
         and dtewrken = p_dtewrken
         and coduser  = global_v_coduser;
  begin
    initial_value(json_str_input);
    check_index_save;
    if param_msg_error is null then
      set_tgholidy(json_str_input);
      if param_msg_error is null then
       -- v_flgworkth       := ''; std_al.check_group_th(p_codcomp, p_codcalen);
        v_dteeffec   := null;
        p_index_recs := 0;

        for r_codcomp in c_codcomp loop
          v_codcomp  := r_codcomp.codcomp;
          v_dteeffec := r_codcomp.dteeffec;
          if v_dteeffec is not null then
            /*13/02/2021 cancel
            begin
              select dtework into v_dtelast
                from tgrpplan
               where codcomp = v_codcomp
                 and codcalen = p_codcalen
                 and dtework  = (select max (dtework)
                                  from tgrpplan
                                 where codcomp = v_codcomp
                                   and codcalen = p_codcalen);

insert_ttemprpt('AL1LB','AL1LB','found last=',v_codcomp||to_char(v_dteeffec,'dd/mm/yyyy'),to_char(v_dtelast,'dd/mm/yyyy'),null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
              if v_dtelast > p_dtewrkst then --#2450 20/01/2021
                v_dtelast := p_dtewrkst - 1;
insert_ttemprpt('AL1LB','AL1LB','found last_2=',v_codcomp||to_char(v_dteeffec,'dd/mm/yyyy'),to_char(v_dtelast,'dd/mm/yyyy'),null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
              end if;
            exception when no_data_found then
              v_dtelast := trunc(p_dtewrkst,'month') - 1;
insert_ttemprpt('AL1LB','AL1LB','Not found, last=',v_codcomp||to_char(v_dteeffec,'dd/mm/yyyy'),to_char(v_dtelast,'dd/mm/yyyy'),null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
            end;

--insert_ttemprpt('AL1LB','AL1LB','v_dtelast=',v_codcomp||to_char(v_dteeffec,'dd/mm/yyyy'),to_char(v_dtelast,'dd/mm/yyyy'),null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
            */
            begin --13/02/2021
              select max(dtewrken) into v_dtelast
                from tgrpyear
               where codcomp  = v_codcomp
                 and codcalen = p_codcalen
                 and dteyear  = (p_dteyear - global_v_zyear);

              if v_dtelast > p_dtewrkst then --#2450 20/01/2021
                v_dtelast := p_dtewrkst - 1;
              end if;
            end;
            if v_dtelast is null then
              v_dtelast := trunc(p_dtewrkst,'month') - 1;
            end if;

            --13/02/2021
            begin
              select next_day(p_dtewrkst, r_codcomp.startday) - 7
                into vv_stdate
                from dual;
              v_dtework := vv_stdate - 1;
            exception when no_data_found then
              v_dtework := null;
            end;
            /*begin
              select next_day(p_dtewrkst - 1, r_codcomp.startday)
                into vv_stdate
                from dual;
              v_dtework := vv_stdate - 1;
            exception when no_data_found then
              v_dtework := null;
            end;*/

            <<forward>>
            while v_dtework <= p_dtewrken loop
              for r_tgrpwork in c_tgrpwork loop
                for i in 1..r_tgrpwork.qtydaych loop
                  -- Gen 'W' forward
                  for j in 1..r_tgrpwork.qtydwpp loop --????????????? ????? ??????
                    v_dtework := v_dtework + 1;
                    if v_dtework > p_dtewrken then
                       exit forward;
                    end if;
                     gen_data(v_codcomp, v_dtework,'W',r_tgrpwork.codshift);
                  end loop;
                  -- Gen 'H' forward
                  for j in 1..r_tgrpwork.qtydhpp loop --????????????? ???? ??????
                    v_dtework := v_dtework + 1;
                    if v_dtework > p_dtewrken then
                       exit forward;
                    end if;
                     gen_data(v_codcomp, v_dtework,'H',r_tgrpwork.codshift);
                  end loop;
                end loop;	-- for i in 1..r_tgrpwork.qtydaych loop
              end loop; -- for c_tgrpwork
              if v_dtework < p_dtewrkst then
                exit forward;
              end if;
            end loop; -- forward

            v_dtework := vv_stdate;
            <<backward>>
            while v_dtework > v_dtelast loop
              for r_tgrpwork2 in c_tgrpwork2 loop
                for i in 1..r_tgrpwork2.qtydaych loop
                  -- Gen 'H' backward
                  for j in 1..r_tgrpwork2.qtydhpp loop --????????????? ???? ??????
                    v_dtework := v_dtework - 1;
                    if v_dtework <= v_dtelast then
                       exit backward;
                    end if;
                    gen_data(v_codcomp, v_dtework,'H',r_tgrpwork2.codshift);
                  end loop;
                  -- Gen 'W' backward
                  for j in 1..r_tgrpwork2.qtydwpp loop --????????????? ????? ??????
                    v_dtework := v_dtework - 1;
                    if v_dtework <= v_dtelast then
                       exit backward;
                    end if;
                    gen_data(v_codcomp, v_dtework,'W',r_tgrpwork2.codshift);
                  end loop;
                end loop;	-- for i in 1..r_tgrpwork2.qtydaych loop
              end loop; -- for c_tgrpwork2
              if v_dtework = p_dtewrkst then
                exit backward;
              end if;
            end loop; -- backward
            if p_index_recs > 0 then
              v_exist := false;
              for r_tgrpyear in c_tgrpyear loop
                v_exist := true;
                update tgrpyear set dteupd = trunc(sysdate)
                  where rowid = r_tgrpyear.rowid;
              end loop;
              if not v_exist then
                insert into tgrpyear
                  (codcomp,codcalen,dteyear,
                   dtewrkst,dtewrken,codcreate,dteupd,coduser)
                values
                  (v_codcomp, p_codcalen, (p_dteyear - global_v_zyear),
                   p_dtewrkst, p_dtewrken, global_v_coduser, trunc(sysdate), global_v_coduser);
              end if;

            end if;
          end if;
        end loop;
        commit;
        --- update tattence
        gen_tattence;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

    hcm_batchtask.finish_batch_process(
      p_codapp    => global_v_batch_codapp,
      p_coduser   => global_v_coduser,
      p_codalw    => global_v_batch_codalw,
      p_dtestrt   => global_v_batch_dtestrt,
      p_flgproc   => global_v_batch_flgproc,
      p_qtyproc   => global_v_batch_qtyproc,
      p_qtyerror  => global_v_batch_qtyerror,
      p_oracode   => param_msg_error
    );
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

    hcm_batchtask.finish_batch_process(
      p_codapp  => global_v_batch_codapp,
      p_coduser => global_v_coduser,
      p_codalw  => global_v_batch_codalw,
      p_dtestrt => global_v_batch_dtestrt,
      p_flgproc => 'N',
      p_oracode => param_msg_error
    );
  end set_holiday;

  procedure set_tgholidy(json_str_input in clob) is
    json_input_obj            json_object_t;
    json_param_obj            json_object_t;
    json_row                  json_object_t;
    v_detailDelete            json_object_t;

    v_dtedate                 date;
    v_typwork                 varchar2(4000 char);
    v_desholdye               varchar2(4000 char);
    v_desholdyt               varchar2(4000 char);
    v_desholdy3               varchar2(4000 char);
    v_desholdy4               varchar2(4000 char);
    v_desholdy5               varchar2(4000 char);
    v_detail                  varchar2(4000 char);
    v_codcomp                 varchar2(100 char);

    cursor c_tgrpwork is
      select distinct(codcomp)
        from tgrpwork
       where codcomp like p_codcomp || '%';

  begin
    json_input_obj        := json_object_t(json_str_input);
    json_param_obj        := hcm_util.get_json_t(json_input_obj,'param_json');
--<<user46 fix issue std 18/10/2021
--    v_detailDelete        := hcm_util.get_json_t(json_input_obj,'detailDelete');
    begin
      delete from tgholidy
            where codcomp   = p_codcomp
              and codcalen  = p_codcalen
              and dteyear   = p_dteyear;
--              and dtedate = to_date(v_detail, 'DD/MM/YYYY');
    end;
/*    for i in 0..v_detailDelete.get_size-1 loop
      v_detail := hcm_util.get_string_t(v_detailDelete, to_char(i));
      begin
        delete from tgholidy
              where codcomp = p_codcomp
                and codcalen = p_codcalen
                and dteyear = to_number(to_char(to_date(v_detail, 'DD/MM/YYYY'), 'YYYY'))
                and dtedate = to_date(v_detail, 'DD/MM/YYYY');
      end;
    end loop;*/
-->>
    for i in 0..json_param_obj.get_size-1 loop
      json_row    := hcm_util.get_json_t(json_param_obj,to_char(i));
      v_dtedate   := to_date(hcm_util.get_string_t(json_row,'dtedate'), 'DD/MM/YYYY');
      v_typwork   := hcm_util.get_string_t(json_row,'typwork');
      v_desholdye := hcm_util.get_string_t(json_row,'desholdye');
      v_desholdyt	:= hcm_util.get_string_t(json_row,'desholdyt');
      v_desholdy3	:= hcm_util.get_string_t(json_row,'desholdy3');
      v_desholdy4	:= hcm_util.get_string_t(json_row,'desholdy4');
      v_desholdy5	:= hcm_util.get_string_t(json_row,'desholdy5');

      if global_v_lang = '101' then
        v_desholdye := hcm_util.get_string_t(json_row,'desholdy');
      end if;
      if global_v_lang = '102' then
        v_desholdyt := hcm_util.get_string_t(json_row,'desholdy');
      end if;
      if global_v_lang = '103' then
        v_desholdy3 := hcm_util.get_string_t(json_row,'desholdy');
      end if;
      if global_v_lang = '104' then
        v_desholdy4 := hcm_util.get_string_t(json_row,'desholdy');
      end if;
      if global_v_lang = '105' then
        v_desholdy5 := hcm_util.get_string_t(json_row,'desholdy');
      end if;
      if to_char(v_dtedate, 'YYYY') = to_char(p_dteyear) then
        for r1 in c_tgrpwork loop
          v_codcomp := r1.codcomp;
            begin
              insert into tgholidy
              (codcomp, codcalen, dteyear, dtedate, typwork, desholdye, desholdyt, desholdy3, desholdy4, desholdy5, codcreate, coduser)
              values
              (v_codcomp, p_codcalen, p_dteyear, v_dtedate, v_typwork, v_desholdye, v_desholdyt, v_desholdy3, v_desholdy4, v_desholdy5, global_v_coduser, global_v_coduser);
            exception when DUP_VAL_ON_INDEX then
              update tgholidy
                 set typwork   = v_typwork,
                     desholdye = v_desholdye,
                     desholdyt = v_desholdyt,
                     desholdy3 = v_desholdy3,
                     desholdy4 = v_desholdy4,
                     desholdy5 = v_desholdy5,
                     coduser   = global_v_coduser
              where codcalen = p_codcalen
                and codcomp = p_codcomp
                and dteyear = p_dteyear
                and dtedate = v_dtedate;
        end;
       end loop;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;

  procedure gen_data (b_codcomp in varchar2, b_dtework in date, b_typwork in varchar2, b_codshift in varchar2) is
  v_typwork               varchar2(100 char);
  v_typhol                varchar2(100 char);
  v_flgfound              boolean;
  cursor c_tgrpplan is
    select rowid
      from tgrpplan
     where codcomp = b_codcomp
       and codcalen = p_codcalen
       and dtework  = b_dtework;
  begin
    v_typwork := b_typwork;
    begin
      select typwork into v_typwork
        from tgholidy
       where codcomp = b_codcomp
         and codcalen = p_codcalen
         and dteyear = to_number(to_char(b_dtework,'yyyy')) - global_v_zyear
         and dtedate = b_dtework
         and rownum <= 1;
--      if not(instr(p_flgworkth, v_typhol) > 0 and b_typwork = 'H') then
--        v_typwork := v_typhol;
--      end if;
    exception when no_data_found then
      null;
    end;

    v_flgfound := false;
    for r_tgrpplan in c_tgrpplan loop
      v_flgfound := true;
      update tgrpplan set typwork  = v_typwork,
              codshift = b_codshift,
              coduser  = global_v_coduser
      where rowid = r_tgrpplan.rowid;
    end loop;
    if not v_flgfound then
      insert into tgrpplan
        (codcomp,codcalen,dtework,
         typwork,codshift,codcreate,coduser)
      values
        (b_codcomp, p_codcalen, b_dtework,
         v_typwork, b_codshift,global_v_coduser,global_v_coduser);
    end if;
    p_index_recs := p_index_recs + 1;
  end;

  procedure get_list_codcompy(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_list_codcompy(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_list_codcompy;

  procedure gen_list_codcompy(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number;
    cursor c_tgrpyear is
      select codcomp, codcalen, dteyear, dtewrkst, dtewrken, dteupd, coduser, count(1) over() as totalrec
        from tgrpyear
       where codcomp like p_codcomp || '%'
         --and upper(codcalen) = nvl(upper(p_codcalen), codcalen)
         and dteyear = (p_dteyear - global_v_zyear)
    order by codcomp, dteyear;
  begin
    v_rcnt     := 0;
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    for i in c_tgrpyear loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',nvl(get_tcenter_name(i.codcomp, global_v_lang), i.codcomp));
      obj_data.put('codcalen', to_char(i.codcalen));
      obj_data.put('desc_codcalen', get_tcodec_name('tcodwork', to_char(i.codcalen), global_v_lang));
      obj_data.put('dteyear', to_char(i.dteyear));
      obj_data.put('dtewrkst', to_char(i.dtewrkst, 'DD/MM/YYYY'));
      obj_data.put('dtewrken', to_char(i.dtewrken, 'DD/MM/YYYY'));
      obj_data.put('dteupd', to_char(i.dteupd, 'DD/MM/YYYY'));
      obj_data.put('coduser', to_char(i.coduser));
      obj_data.put('desc_coduser', to_char(i.coduser));
--      obj_data.put('desc_coduser',nvl(get_temploy_name(i.coduser, global_v_lang), i.coduser));

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_list_codcompy;
  --
  procedure get_last_dtework(json_str_input in clob, json_str_output out clob) as
    obj_data          json_object_t;
    v_dtework         date;
  begin
    begin
      select max(dtework) into v_dtework
        from tgrpplan
       where codcomp like p_codcomp || '%'
         and codcalen = p_codcalen;
    exception when no_data_found then
      v_dtework         := null;
    end;
    obj_data          := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dtework', to_char(v_dtework, 'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_last_dtework;
  --
  procedure check_index is
    v_codcalen  temploy1.codcalen%type;
    v_flgfound  boolean;

    cursor c_temploy1 is
      select codcalen
        from temploy1
       where codcomp like p_codcomp || '%'
         and((p_codcalen is not null and codcalen = p_codcalen)
          or p_codcalen is null)
         and((staemp in('1','3'))
          or (staemp = '9' and dteeffex >= p_dtewrkst))
    group by codcalen;
  begin
    if p_dtewrkst is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dtewrkst');
    elsif p_dtewrken is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'p_dtewrken');
    elsif p_dtewrkst > p_dtewrken then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang,'p_dtewrkst');
    end if;

--    if :b_index.codempid is not null then
--      begin
--        select codcalen
--          into v_codcalen
--          from temploy1
--         where codempid = :b_index.codempid;
--      exception when no_data_found then	null;
--      end;
--
--      begin
--        select codcalen into v_codcalen
--          from tgrpplan
--         where codcompy = substr(:b_index.codcomp,1,3)
--           and codcalen = v_codcalen
--           and dtework  between :b_index.stdate and :b_index.endate
--           and rownum <= 1;
--      exception when no_data_found then
--        msg_error('tgrpplan','HR2010','b_index.stdate');
--      end;
--    else
      v_flgfound := false;
      for r_temploy1 in c_temploy1 loop
        v_codcalen := r_temploy1.codcalen;
        begin
          select codcalen into v_codcalen
            from tgrpplan
           where codcomp = p_codcomp
             and codcalen = v_codcalen
             and dtework  between p_dtewrkst and p_dtewrken
             and rownum <= 1;
          v_flgfound := true;
          exit;
        exception when no_data_found then null;
        end;
      end loop;
      if not v_flgfound then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tgrpplan');
        --msg_error('tgrpplan','HR2010','b_index.stdate');
      end if;
    --end if;
  end;
  --
  function gen_char(p_langth number) return varchar2 is
    v_num      number := 0;
    v_dtestart date ;
    v_dteend   date ;
    v_time     varchar2(100);
    n          number := 0 ;
    v_cod      varchar2(100);
    v_recs     number;
    type char_type is table of varchar2(1) index by binary_integer;
			 v_char		char_type;
  begin
  	 for i in 0..9 loop
  	 	 n := n + 1 ;
  	   v_char(n) := i;
  	 end loop;
  	 for i in 65..90 loop
  	 	 n := n + 1 ;
  	   v_char(n) := chr(i);
  	 end loop ;
     for i in 97..122 loop
  	 	 n := n + 1 ;
  	   v_char(n) := chr(i);
     end loop ;
     v_cod := null ;
     for i in 1..p_langth loop
   	   	   n      := trunc(dbms_random.value(1,62)) ;
     	     v_cod  := v_cod ||v_char(n);
   	   end loop ;
      return upper(v_cod) ;
  end;
  --
  procedure Insert_data_to_process(p_codapp in varchar2,p_coduser in varchar2,p_proc in number,p_cnt_process out number) is
    v_num      number ;
    v_proc     number := p_proc ;
    v_numproc  number ;
    v_rec      number ;
    v_flgsecu  boolean ;
    v_zupdsal  varchar2(1);
    v_flgfound boolean ;
  	v_cnt				number;
  	v_rownumst	number;
  	v_rownumen	number;

  cursor c_temploy1 is
    select distinct codempid,b.codcomp,b.codcalen,numlvl,staemp,dteempmt,dteeffex,typpayroll,flgatten,codempmt
      from temploy1 b,tgrpwork a
     where b.codcomp like p_codcomp || '%'
       and a.codcomp like p_codcomp || '%'
       and b.codcalen = a.codcalen
       and ((p_codcalen is not null and b.codcalen = p_codcalen) or p_codcalen is null)
       and ((staemp in('1','3'))	or (staemp = '9' and dteeffex >= p_dtewrkst))
       and b.numlvl between global_v_zminlvl and global_v_zwrklvl
       and 0 <> (select count(ts.codcomp)
                   from tusrcom ts
                  where ts.coduser = global_v_coduser
                    and b.codcomp like ts.codcomp||'%'
                    and rownum <= 1 )
    order by codempid;
  begin
    for i in c_temploy1 loop
      v_flgfound := true;
      insert into tprocemp(codapp,coduser,numproc,codempid)
                    values(p_codapp,p_coduser,999,i.codempid);
    end loop;

		-- change numproc
  	begin
  		select count(*) into v_cnt
  		  from tprocemp
  		 where codapp  = p_codapp
  		   and coduser = p_coduser;
  	end;
  	if v_cnt > 0 then
      p_cnt_process   := v_cnt;
  		v_rownumst := 1;
	  	for i in 1..p_proc loop
	  		if v_cnt < p_proc then
	  			v_rownumen := v_cnt;
	  		else
	  			v_rownumen := ceil(v_cnt/p_proc);
  			end if;
	  		--
	  		update tprocemp
	  		   set numproc = i
	   		 where codapp  = p_codapp
	  		   and coduser = p_coduser
	  		   and numproc = 999
	  		   and rownum  between v_rownumst and v_rownumen;
	  	end loop;
	  end if;
	  commit;
    /*begin
      select count(distinct codempid)
        into v_rec
        from temploy1 b,tgrpwork a
       where b.codcomp like p_codcomp || '%'
         and b.codcomp  = a.codcomp
         and b.codcalen = a.codcalen
         and ((p_codcalen is not null and b.codcalen = p_codcalen) or p_codcalen is null)
         and ((staemp in('1','3'))	or (staemp = '9' and dteeffex >= p_dtewrkst))
         and b.numlvl between global_v_zminlvl and global_v_zwrklvl
         and 0 <> (select count(ts.codcomp)
                     from tusrcom ts
                    where ts.coduser = global_v_coduser
                      and b.codcomp like ts.codcomp||'%'
                      and rownum <= 1 );
    exception when others then
        null;
    end ;

    v_num := greatest(trunc(v_rec / v_proc),1);

    v_rec := 0;
    for i in c_temploy1 loop
      v_flgfound := true;
        v_rec     := v_rec + 1;
        v_numproc := trunc(v_rec / v_num) + 1;
        if v_numproc > v_proc then
           v_numproc  := v_proc;
        end if;
        insert into tprocemp(codapp,coduser,numproc,codempid)
                      values(p_codapp,p_coduser,v_numproc,i.codempid);
    end loop;*/
    if not v_flgfound then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
    else
      commit;
    end if;
  end;

  procedure gen_tattence as
    v_numproc  number := nvl(get_tsetup_value('QTYPARALLEL'),2);
    v_zupdsal  varchar2(4);
    v_ok       boolean;
    v_flgsecu  boolean;
    v_flgfound boolean;
		v_stmt			varchar2(1000);
		v_interval	varchar2(50);
		v_finish		varchar2(1);
    --v_timeout  number:= get_tsetup_value('TIMEOUT') ;
    /*jobno1     number;
    jobno2     number;
    jobno3     number;
    jobno4     number;
    jobno5     number;
    job_count  number;
    v_recs     number;
    */
    v_dtestr   date;
    v_dteend   date;
    v_coduser  varchar2(10);
    v_codapp   varchar2(10);
    v_cnt_process number := 0;
		type a_number is table of number index by binary_integer;
  		 a_jobno	a_number;

  begin
    check_index;
    if param_msg_error is null then
      --v_recs := 0;
      v_flgfound := false;
      --:b_index.v_dtestr := sysdate;
      v_coduser := global_v_coduser ;
      v_codapp  := upper('HRAL23B'||gen_char(2));

      delete tprocount where codapp = v_codapp and coduser = v_coduser;
      delete tprocemp  where codapp = v_codapp and coduser = v_coduser;

      Insert_data_to_process(v_codapp,v_coduser,v_numproc,v_cnt_process);

      if param_msg_error is null then
        --Change Date To ?.?. ????? Database ???????? ?.?.
        if to_char(sysdate,'yyyy') > 2500 then
          v_dtestr := to_date(to_char(p_dtewrkst,'dd/mm/')||(to_char(p_dtewrkst,'yyyy')-543),'dd/mm/yyyy');
          v_dteend := to_date(to_char(p_dtewrken,'dd/mm/')||(to_char(p_dtewrken,'yyyy')-543),'dd/mm/yyyy');
        else
          v_dtestr := p_dtewrkst;
          v_dteend := p_dtewrken;
        end if;

        for i in 1..v_numproc loop
          v_stmt := 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''','||i||',to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;';
          dbms_job.submit(a_jobno(i),v_stmt,sysdate,v_interval);
          commit;
        end loop;
        --
        v_finish := 'N';
        loop
          for i in 1..v_numproc loop
            dbms_lock.sleep(10);
            begin
              select 'N' into v_finish
                from user_jobs
               where job = a_jobno(i);
              exit;
            exception when no_data_found then v_finish := 'Y';
            end;
          end loop;
          if v_finish = 'Y' then
            exit;
          end if;
        end loop;
 /*
        dbms_job.submit(jobno1, 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''',1,to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;', sysdate,null);commit ;
        dbms_job.submit(jobno2, 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''',2,to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;', sysdate,null);commit ;
        dbms_job.submit(jobno3, 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''',3,to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;', sysdate,null);commit ;
        dbms_job.submit(jobno4, 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''',4,to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;', sysdate,null);commit ;
        dbms_job.submit(jobno5, 'begin hral23b_batch.start_process('''||v_codapp||''','''||v_coduser||''',5,to_date('''||to_char(v_dtestr,'dd/mm/yyyy')||''',''dd/mm/yyyy''),to_date('''||to_char(v_dteend,'dd/mm/yyyy')||''',''dd/mm/yyyy'')); end ;', sysdate,null);commit ;

        loop
           select count(*) into job_count from user_jobs where job in (jobno1,jobno2,jobno3,jobno4,jobno5);
           if job_count = 0 then
             begin

              select sum(qtyproc)
                into v_recs
                from tprocount
               where codapp  = v_codapp
                 and coduser = v_coduser;
             end ;
             exit;
           end if;
        end loop;*/
        commit ;
        --:b_index.v_dteend := sysdate;
        --:b_index.v_time   := cal_hhmiss(:b_index.v_dtestr,:b_index.v_dteend);
        --alert_error.error_data('HR2715',:global.v_lang);
        global_v_batch_qtyproc  := v_cnt_process;
        global_v_batch_flgproc  := 'Y';
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      end if;
    end if;
  end;


END HRAL1LB;

/

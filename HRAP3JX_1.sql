--------------------------------------------------------
--  DDL for Package Body HRAP3JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3JX" is
-- last update: 27/08/2020 15:06

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');    --07/10/2020

    --block b_index
    b_index_dteyreap1   := to_number(hcm_util.get_string_t(json_obj,'p_year1'));
    b_index_dteyreap2   := to_number(hcm_util.get_string_t(json_obj,'p_year2'));
    b_index_dteyreap3   := to_number(hcm_util.get_string_t(json_obj,'p_year3'));
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
  --b_index_codempid    := hcm_util.get_string_t(json_obj,'codempid');--07/10/2020
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chk           number;
    v_percent       number;
    v_qtyscore      number;
    v_pctadjsal     number;
    v_grade         varchar2(10);

    cursor c1 is
        select codempid,codcomp,numlvl,codpos
          from tapprais
         where (dteyreap = b_index_dteyreap1
                or dteyreap = b_index_dteyreap2
                or dteyreap = b_index_dteyreap3)
           and codcomp like b_index_codcomp||'%'
        group by codcomp,codempid,numlvl,codpos
        order by codempid;
--        order by codcomp,codempid,numlvl,codpos;
  begin

    obj_row := json_object_t();
    for i in c1 loop
        v_flgdata := 'Y';
      --  v_flgsecu := 'Y';

        flgpass := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('number',v_rcnt);
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_pos', get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('score1', '');
            obj_data.put('score2', '');
            obj_data.put('score3', '');
            obj_data.put('percent1', '');
            obj_data.put('percent2', '');
            obj_data.put('percent3', '');
            obj_data.put('grade1', '');
            obj_data.put('grade2', '');
            obj_data.put('grade3', '');

            if b_index_dteyreap1 is not null then
                begin
                    select qtyscore,pctadjsal,grade
                      into v_qtyscore,v_pctadjsal,v_grade
                      from tapprais
                     where codempid = i.codempid
                       and dteyreap = b_index_dteyreap1;
                exception when no_data_found then
                    v_qtyscore  := null;
                    v_pctadjsal := null;
                    v_grade     := null;
                end;
                obj_data.put('score1',to_char(v_qtyscore,'fm999,990.00'));
                obj_data.put('percent1',to_char(v_pctadjsal,'fm999,990.00'));
                obj_data.put('grade1',v_grade);
            end if;
            if b_index_dteyreap2 is not null then
                begin
                    select qtyscore,pctadjsal,grade
                      into v_qtyscore,v_pctadjsal,v_grade
                      from tapprais
                     where codempid = i.codempid
                       and dteyreap = b_index_dteyreap2;
                exception when no_data_found then
                    v_qtyscore  := null;
                    v_pctadjsal := null;
                    v_grade     := null;
                end;
                obj_data.put('score2',to_char(v_qtyscore,'fm999,990.00'));
                obj_data.put('percent2',to_char(v_pctadjsal,'fm999,990.00'));
                obj_data.put('grade2',v_grade);
            end if;
            if b_index_dteyreap3 is not null then
                begin
                    select qtyscore,pctadjsal,grade
                      into v_qtyscore,v_pctadjsal,v_grade
                      from tapprais
                     where codempid = i.codempid
                       and dteyreap = b_index_dteyreap3;
                exception when no_data_found then
                    v_qtyscore  := null;
                    v_pctadjsal := null;
                    v_grade     := null;
                end;
                obj_data.put('score3',to_char(v_qtyscore,'fm999,990.00'));
                obj_data.put('percent3',to_char(v_pctadjsal,'fm999,990.00'));
                obj_data.put('grade3',v_grade);
            end if;
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapprais');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_data_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_data_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    obj_rowmain     json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;

    cursor c1 is
        select codempid,codcomp,numlvl,codpos,grade,qtyscore,pctadjsal,amtsaln
          from tapprais
         where codempid = p_codempid
           and dteyreap = (select max(dteyreap)
--#5673                             from tappemp
                             from tapprais
--#5673
                            where codempid = p_codempid
                              and dteyreap <= to_char(sysdate,'yyyy'));
  begin
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    for i in c1 loop
        v_flgdata := 'Y';
        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if i.codempid = global_v_codempid then
            flgpass     := true;
            v_zupdsal   := 'Y';
        end if;
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_emp',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_pos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('grade',i.grade);
            obj_data.put('score',i.qtyscore);
            obj_data.put('percent','');
            obj_data.put('sallast','');
            if v_zupdsal = 'Y' then
                obj_data.put('percent',to_char(i.pctadjsal,'fm999,999,990.00'));
                obj_data.put('sallast',to_char(stddec(i.amtsaln,i.codempid,v_chken),'fm999,999,990.00'));
            end if;
            exit;
        end if;
    end loop;

   --07/10/2020
    if isInsertReport then
      obj_data.put('item1','DETAIL');
      insert_ttemprpt(obj_data);
    end if;
  --07/10/2020

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tapprais');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_data.to_clob;
    end if;
  end;
  --

  procedure get_data_table(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_table(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	  boolean;
    v_zupdsal   	  varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_yre number ;
    v_chk_yre number := 1234;

    v_pctadjsal     tapprais.pctadjsal%type;
    v_amtbudg       tapprais.amtbudg%type;
    v_amtadj        tapprais.amtadj%type;
    v_amtsaln       tapprais.amtsaln%type;

    cursor c1 is
      select codempid,codcomp,dteyreap,numtime,grdap,
             nvl(qtyta,0)qtyta,nvl(qtypuns,0)qtypuns,nvl(qtybeh,0)qtybeh,
             nvl(qtycmp,0)qtycmp,nvl(qtykpie,0)qtykpie,nvl(qtykpid,0)qtykpid,
             nvl(qtykpic,0)qtykpic,nvl(qtytotnet,0)qtytotnet
        from tappemp
       where (dteyreap = nvl(b_index_dteyreap1,0)
              or dteyreap = nvl(b_index_dteyreap2,0)
              or dteyreap = nvl(b_index_dteyreap3,0))
         and codempid = p_codempid
      order by dteyreap desc,numtime desc;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
               --v_flgsecu := 'Y';

        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if i.codempid = global_v_codempid then
            flgpass := true;
        end if;
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
--#5673            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('dteyreap',hcm_util.get_year_buddhist_era(to_char(i.dteyreap)));
--#5673
            obj_data.put('numtime',i.numtime);
            obj_data.put('grdap',i.grdap);
--#5673            obj_data.put('qtyta',to_char(i.qtyta,'fm999,999,990.00'));
--#5673            obj_data.put('qtypuns',to_char(i.qtypuns,'fm999,999,990.00'));
            obj_data.put('qtypuns',to_char((nvl(i.qtyta,0) + nvl(i.qtypuns,0)) / 2,'fm999,999,990.00'));
--#5673
            obj_data.put('qtybeh',to_char(i.qtybeh,'fm999,999,990.00'));
            obj_data.put('qtycmp',to_char(i.qtycmp,'fm999,999,990.00'));
            obj_data.put('qtykpie',to_char(i.qtykpie,'fm999,999,990.00'));
            obj_data.put('qtykpid',to_char(i.qtykpid,'fm999,999,990.00'));
            obj_data.put('qtykpic',to_char(i.qtykpic,'fm999,999,990.00'));
            obj_data.put('qtytot',to_char(i.qtytotnet,'fm999,999,990.00'));

            -- for HRESH5X
            begin
                select pctadjsal, amtbudg, amtadj, amtsaln
                  into v_pctadjsal, v_amtbudg, v_amtadj, v_amtsaln
                  from tapprais
                 where codempid = p_codempid
                   and dteyreap = i.dteyreap;
            exception when no_data_found then
                v_pctadjsal := null;
                v_amtbudg   := null;
                v_amtadj    := null;
                v_amtsaln   := null;
            end;

            obj_data.put('pctadjsal',v_pctadjsal);
            obj_data.put('amtbudg',stddec(v_amtbudg,i.codempid,v_chken));
            obj_data.put('amtsaln',stddec(v_amtsaln,i.codempid,v_chken));

            obj_row.put(to_char(v_rcnt-1),obj_data);

         --07/10/2020

        if isInsertReport then
               if i.dteyreap <> v_chk_yre then
                  v_yre := i.dteyreap;
               else
                  v_yre := null;
               end if;
          obj_data.put('item1','TABLE');
          obj_data.put('item2',p_codempid);
          obj_data.put('item3',v_yre);
          --obj_data.put('item3',i.dteyreap);
          obj_data.put('item4',i.numtime);
          obj_data.put('item5',i.grdap);
          obj_data.put('item6',to_char(i.qtyta,'fm999,999,990.00'));
          obj_data.put('item7',to_char(i.qtypuns,'fm999,999,990.00'));
          obj_data.put('item8',to_char(i.qtybeh,'fm999,999,990.00'));
          obj_data.put('item9',to_char(i.qtycmp,'fm999,999,990.00'));
          obj_data.put('item10',to_char(i.qtykpie,'fm999,999,990.00'));
          obj_data.put('item11',to_char(i.qtykpid,'fm999,999,990.00'));
          obj_data.put('item12',to_char(i.qtykpic,'fm999,999,990.00'));
          obj_data.put('item13',to_char(i.qtytotnet,'fm999,999,990.00'));
          insert_ttemprpt_table(obj_data);
          v_chk_yre := i.dteyreap;
        end if;
        --07/10/2020

        end if;
    end loop;
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_dteyreap1   := to_number(hcm_util.get_string_t(json_obj,'p_year1'));
    b_index_dteyreap2   := to_number(hcm_util.get_string_t(json_obj,'p_year2'));
    b_index_dteyreap3   := to_number(hcm_util.get_string_t(json_obj,'p_year3'));
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_report;
---

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;

  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;

      for i in 0..json_index_rows.get_size-1 loop
        p_index_rows       := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codempid         := hcm_util.get_string_t(p_index_rows, 'codempid');
        b_index_dteyreap1   := to_number(hcm_util.get_string_t(p_index_rows,'year1'));
        b_index_dteyreap2   := to_number(hcm_util.get_string_t(p_index_rows,'year2'));
        b_index_dteyreap3   := to_number(hcm_util.get_string_t(p_index_rows,'year3'));
        gen_data_detail(json_output);
        gen_data_table(json_output);
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  ------
  procedure insert_ttemprpt(obj_data in json_object_t) is
    v_numseq        number := 0;
    v_image         tempimge.namimage%type;
    v_folder        tfolderd.folder%type;
    v_has_image     varchar2(1) := 'N';
    v_image2        tempimge.namimage%type;
    v_folder2       tfolderd.folder%type;
    v_has_image2    varchar2(1) := 'N';
    v_codreview     temploy1.codempid%type := '';
    v_codempid      varchar2(100 char) := '';
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_item1         ttemprpt.item1%type;
    v_item2         ttemprpt.item2%type;
    v_item3         ttemprpt.item3%type;
    v_item4         ttemprpt.item4%type;
    v_item5         ttemprpt.item5%type;
    v_item6         ttemprpt.item6%type;
    v_item7         ttemprpt.item7%type;
    v_item8         ttemprpt.item8%type;
    v_item9         ttemprpt.item9%type;
    v_item10        ttemprpt.item10%type;
    v_item11        ttemprpt.item11%type;
    v_item12        ttemprpt.item12%type;
    v_item13        ttemprpt.item13%type;
    v_item14        ttemprpt.item14%type;
    v_item15        ttemprpt.item15%type;

  begin
        v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
        v_item2       := nvl(hcm_util.get_string_t(obj_data, 'codempid'), '');
        v_item3       := nvl(hcm_util.get_string_t(obj_data, 'desc_emp'), '');
        v_item4       := nvl(hcm_util.get_string_t(obj_data, 'desc_pos'), '');
        v_item5       := nvl(hcm_util.get_string_t(obj_data, 'grade'), '');
        v_item6       := nvl(hcm_util.get_string_t(obj_data, 'score'), '');
        v_item7       := nvl(hcm_util.get_string_t(obj_data, 'percent'), '');
        v_item8       := nvl(hcm_util.get_string_t(obj_data, 'sallast'), '');
        v_item9       := nvl(hcm_util.get_string_t(obj_data, ''), '');
        v_item10      := nvl(hcm_util.get_string_t(obj_data, ''), '');
        v_item11      := nvl(hcm_util.get_string_t(obj_data, ''), '');
        v_item12      := nvl(hcm_util.get_string_t(obj_data, ''), '');
        v_item13      := nvl(hcm_util.get_string_t(obj_data, ''), '');


    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;
      v_numseq := v_numseq + 1;
       begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image
          from tempimge
         where codempid = p_codempid;
      exception when no_data_found then
        v_image := null;
      end;

      if v_image is not null then
        v_image      := get_tsetup_value('PATHWORKPHP')||v_image;
        v_has_image   := 'Y';
      end if;

      begin
        select get_tfolderd('HRPMC2E1')||'/'||namimage
          into v_image2
          from tempimge
         where codempid = v_codreview;
      exception when no_data_found then
        v_image2 := null;
      end;

      if v_image2 is not null then
        v_image2      := get_tsetup_value('PATHWORKPHP')||v_image2;
        v_has_image2   := 'Y';
      end if;


      begin
       insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10, item11
               ,item12, item13, item14, item15
             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             ,v_item4,v_item5,v_item6, v_item7, v_item8, v_has_image, v_image, v_item11
             ,v_item12, v_item13, v_item14, v_item15
        );
      exception when others then
        null;
      end;
  end;

  procedure insert_ttemprpt_table(obj_data in json_object_t) is
    v_numseq      number := 0;
    v_item1       ttemprpt.item1%type;
    v_item2       ttemprpt.item2%type;
    v_item3       ttemprpt.item3%type;
    v_item4       ttemprpt.item4%type;
    v_item5       ttemprpt.item5%type;
    v_item6       ttemprpt.item6%type;
    v_item7       ttemprpt.item7%type;
    v_item8       ttemprpt.item8%type;
    v_item9       ttemprpt.item9%type;
    v_item10      ttemprpt.item10%type;
    v_item11      ttemprpt.item11%type;
    v_item12      ttemprpt.item12%type;
    v_item13      ttemprpt.item13%type;
    v_item14      ttemprpt.item14%type;
    v_item15      ttemprpt.item15%type;

  begin
    v_item1       := nvl(hcm_util.get_string_t(obj_data, 'item1'), '');
    v_item2       := nvl(hcm_util.get_string_t(obj_data, 'item2'), '');
    v_item3       := nvl(hcm_util.get_string_t(obj_data, 'item3'), '');
    v_item4       := nvl(hcm_util.get_string_t(obj_data, 'item4'), '');
    v_item5       := nvl(hcm_util.get_string_t(obj_data, 'item5'), '');
    v_item6       := nvl(hcm_util.get_string_t(obj_data, 'item6'), '');
    v_item7       := nvl(hcm_util.get_string_t(obj_data, 'item7'), '');
    v_item8       := nvl(hcm_util.get_string_t(obj_data, 'item8'), '');
    v_item9       := nvl(hcm_util.get_string_t(obj_data, 'item9'), '');
    v_item10      := nvl(hcm_util.get_string_t(obj_data, 'item10'), '');
    v_item11      := nvl(hcm_util.get_string_t(obj_data, 'item11'), '');
    v_item12      := nvl(hcm_util.get_string_t(obj_data, 'item12'), '');
    v_item13      := nvl(hcm_util.get_string_t(obj_data, 'item13'), '');

    begin
      select nvl(max(numseq), 0)
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then
      null;
    end;

    if v_item3 is not null then
       v_item3 := hcm_util.get_year_buddhist_era(to_char(v_item3));
    end if;



      v_numseq := v_numseq + 1;

      begin
        insert
          into ttemprpt
             (
               codempid, codapp, numseq, item1, item2, item3
               , item4, item5, item6, item7, item8, item9, item10
               , item11,item12,item13

             )
        values
             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             , v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, v_item10
             , v_item11, v_item12, v_item13
        );
      exception when others then
        null;
      end;
  end;
----

end;

/

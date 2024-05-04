--------------------------------------------------------
--  DDL for Package Body HRAP3HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3HX" is
-- last update: 03/11/2020 10:30

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_vyear 	    := hcm_appsettings.get_additional_year;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');    --07/10/2020

    --block b_index
    b_index_dteyear   := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_numtime   := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codaplvl  := hcm_util.get_string_t(json_obj,'p_codaplvl');
    b_index_codempid  := hcm_util.get_string_t(json_obj,'codempid');
    p_codempid        := hcm_util.get_string_t(json_obj,'p_codempid_query');
    if nvl(p_codempid,' ') = ' ' then
        p_codempid := b_index_codempid;
    end if;

    if nvl(p_codform,' ') = ' ' then
        p_codform := hcm_util.get_string_t(json_obj,'p_codform');
    end if;
    --block drilldown
    if nvl(b_index_codaplvl,' ') = ' ' then
        p_codaplvl  := b_index_codaplvl;
    end if;
--    p_codcompy := hcm_util.get_codcomp_level(i.codcomp , 1);
--    p_codcompy  := hcm_util.get_string_t(json_obj,'p_codcompy');

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
  procedure get_data_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);

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
  procedure get_data_table1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table2(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table3(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table3(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table4(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table4(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table5(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table5(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table6(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table6(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table7(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table7(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table8(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table8(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table9(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table9(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table10(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table10(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_data_table11(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
--    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_table11(json_str_output);
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
      select codempid, codcomp, codpos, numlvl, codaplvl, dteyreap,
             (nvl(qtyta,0) + nvl(qtypuns,0)) qtyta_puns,                   --เวลามาทำงาน + ผิดวินัย
             (nvl(qtybeh,0) + nvl(qtybeh2,0) + nvl(qtybeh3,0)) Behavior,   --พฤติกรรม
             (nvl(qtycmp,0) + nvl(qtycmp2,0) + nvl(qtycmp3,0)) Competency, --ข้อมูลศักยภาพ (Competency)
             (nvl(qtykpie,0) + nvl(qtykpie2,0) + nvl(qtykpie3,0)) Kpi,     --KPI
             1 total, grdappr
        from tappemp
       where dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and nvl(codcomp,'%') like b_index_codcomp || '%'
         and nvl(codaplvl,'%') like b_index_codaplvl || '%'
         and codempid = nvl(p_codempid,codempid)
         and flgappr = 'C'
      order by codempid;
  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
      --  v_flgsecu := 'Y';

        flgpass := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
--       flgpass := true;
        if flgpass then

            b_index_dteyear1 := i.dteyreap;
            begin
                select sum(nvl(qtybeh3,0) + nvl(qtycmp3,0) + nvl(qtykpie3,0)) level3 ,
                       sum(nvl(qtybeh2,0) + nvl(qtycmp2,0) + nvl(qtykpie2,0)) level2 ,
                       sum(nvl(qtybeh ,0) + nvl(qtycmp ,0) + nvl(qtykpie ,0)) level1
                  into v_level3, v_level2, v_level1
                  from tappemp
                 where dteyreap = b_index_dteyear
                   and numtime  = b_index_numtime
                   and codempid = i.codempid; --p_codempid;

                if v_level3 > 0 then    v_level:= 3;
                elsif v_level2 > 0 then v_level:= 2;
                else                    v_level:= 1;
                end if;
                exception when no_data_found then
                  v_level3 := 0;
                  v_level2 := 0;
                  v_level1 := 0;
                  v_level  := 1;
            end;

            begin
              select decode(v_level , 1, nvl(qtybeh,0), 2, nvl(qtybeh2,0)  , 3, nvl(qtybeh3,0) , nvl(qtybeh,0) ) Behavior,   --พฤติกรรม
                     decode(v_level , 1, nvl(qtycmp,0), 2, nvl(qtycmp2,0)  , 3, nvl(qtycmp3,0) , nvl(qtycmp,0) ) Competency, --ข้อมูลศักยภาพ (Competency)
                     decode(v_level , 1, nvl(qtykpie,0), 2, nvl(qtykpie2,0)  , 3, nvl(qtykpie3,0) , nvl(qtykpie,0) ) Kpi     --KPI
                into v_Behavior, v_Competency, v_Kpi
                from tappemp
               where dteyreap = b_index_dteyear
                 and numtime  = b_index_numtime
                 and codempid =  i.codempid;--p_codempid;
                exception when no_data_found then
                  v_Behavior := 0;
                  v_Competency := 0;
                  v_Kpi := 0;
            end;

            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            v_total := i.qtyta_puns + v_Behavior + v_Competency + v_Kpi;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            obj_data.put('number',v_rcnt);
            obj_data.put('image', get_emp_img(i.codempid));
            --adjust
            --<<user25 Date:14/09/2021 3. AP Module #4493
            obj_data.put('dteyreap',b_index_dteyear);
            obj_data.put('numtime',b_index_numtime);
            -->>user25 Date:14/09/2021 3. AP Module #4493
            obj_data.put('codempid',i.codempid);
            obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('desc_group',get_tcodec_name('TCODAPLV',i.codaplvl,global_v_lang));

--------------
            obj_data.put('appemptamt',i.qtyta_puns);  --เวลามาทำงาน + ผิดวินัย
            obj_data.put('intviewd',v_Behavior);      --พฤติกรรม
            obj_data.put('appcmpc',v_Competency);  --ข้อมูลศักยภาพ (Competency)
            obj_data.put('kpi',v_Kpi);
            obj_data.put('total',v_total);
            obj_data.put('grade',i.grdappr);
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
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
  --
  procedure gen_data_detail(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
      select codempid, codcomp, codpos, numlvl, codaplvl, codform,
             (nvl(qtyta,0) + nvl(qtypuns,0)) qtyta_puns,                   --เวลามาทำงาน + ผิดวินัย
             decode(v_level , 1, nvl(qtybeh,0), 2, nvl(qtybeh2,0)  , 3, nvl(qtybeh3,0) , nvl(qtybeh,0) ) Behavior,   --พฤติกรรม
             decode(v_level , 1, nvl(qtycmp,0), 2, nvl(qtycmp2,0)  , 3, nvl(qtycmp3,0) , nvl(qtycmp,0) ) Competency, --ข้อมูลศักยภาพ (Competency)
             decode(v_level , 1, nvl(qtykpie,0), 2, nvl(qtykpie2,0)  , 3, nvl(qtykpie3,0) , nvl(qtykpie,0) ) Kpi,     --KPI
             qtytot3,
             flgsal, pctdsal, flgbonus, pctdbon,
             1 total, grdappr, remark, remark2, remark3,
             dteconfemp, dteconfhd, dteconflhd, commtimpro
        from tappemp
       where dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and codempid = p_codempid
      order by codempid;

    v_codcompy      varchar2(100 char);
    v_dteapstr      date;
    v_dteapend      date;
    v_period_date   varchar2(100 char);
    v_emp_name      varchar2(100 char);
    v_emp_name2     varchar2(100 char);
    v_compny_name   varchar2(100 char);
    v_comp_name     varchar2(100 char);
    v_pos_name      varchar2(100 char);

    v_codapman      varchar2(100 char);
    desc_codapman   varchar2(100 char);
    desc_codapman2  varchar2(100 char);
    v_codposap      varchar2(100 char);
    desc_codposap   varchar2(100 char);
    desc_codposap2  varchar2(100 char);

    v_codapprman    varchar2(100 char);
    desc_codapprman varchar2(100 char);
    desc_codapprman2 varchar2(100 char);
    v_codposappr    varchar2(100 char);
    desc_codposappr varchar2(100 char);
    desc_codposappr2 varchar2(100 char);
    v_qtytot3       varchar2(100 char);
    v_grade         varchar2(100 char);
    v_flgsal        varchar2(100 char);
    v_flgbonus      varchar2(100 char);


  begin
    obj_row := json_object_t();

    begin
        select sum(nvl(qtybeh3,0) + nvl(qtycmp3,0) + nvl(qtykpie3,0)) level3 ,
               sum(nvl(qtybeh2,0) + nvl(qtycmp2,0) + nvl(qtykpie2,0)) level2 ,
               sum(nvl(qtybeh ,0) + nvl(qtycmp ,0) + nvl(qtykpie ,0)) level1
          into v_level3, v_level2, v_level1
          from tappemp
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;

        if v_level3 > 0 then    v_level:= 3;
        elsif v_level2 > 0 then v_level:= 2;
        else                    v_level:= 1;
        end if;
        exception when no_data_found then
          v_level3 := 0;
          v_level2 := 0;
          v_level1 := 0;
          v_level  := 1;
    end;

    for i in c1 loop
        v_flgdata := 'Y';
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            obj_data.put('number',v_rcnt);

            v_codcompy := hcm_util.get_codcomp_level(i.codcomp , 1);
            p_codcompy := hcm_util.get_codcomp_level(i.codcomp , 1);
            p_codcomp  := i.codcomp;

            p_codaplvl := i.codaplvl;
            p_codform  := i.codform;

--ประเมินผลตั้งแต่วันที่ (item5)
          begin
            select dteapstr, dteapend
              into v_dteapstr, v_dteapend
              from tstdisd
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codcomp  like v_codcompy
--#5552
               and exists(select codaplvl
                          from tempaplvl
                         where dteyreap = b_index_dteyear
                           and numseq  = b_index_numtime
                           and codaplvl = tstdisd.codaplvl
                           and codempid = p_codempid)
--#5552
               and rownum = 1;
--                v_period_date := to_char(v_dteapstr , 'dd/mm/yyyy')||' - '||to_char(v_dteapend , 'dd/mm/yyyy');
              v_period_date := to_char(v_dteapstr, 'dd/mm/')||to_char(to_number(to_char(v_dteapstr, 'yyyy')) + nvl(global_vyear,0));
              v_period_date := v_period_date||' - '||to_char(v_dteapend, 'dd/mm/')||to_char(to_number(to_char(v_dteapend, 'yyyy')) + nvl(global_vyear,0));
            exception when no_data_found then
              v_period_date := null;
              v_dteapstr    := null;
              v_dteapend    := null;
          end;

          p_dteapstr := v_dteapstr;
          p_dteapend := v_dteapend;

--บริษัท (item6)
          v_compny_name := v_codcompy ||' - '|| get_tcompny_name(v_codcompy, global_v_lang);

--รหัสพนักงาน (item7)
          v_emp_name := i.codempid ||' - '|| get_temploy_name(i.codempid,global_v_lang);

--ชื่อพนักงาน (item8)
          v_emp_name2 := get_temploy_name(i.codempid,global_v_lang);

--หน่วยงาน (item9)
          v_comp_name := get_tcenter_name(i.codcomp,global_v_lang);

--ตำแหน่ง (item10)
          v_pos_name := get_tpostn_name(i.codpos,global_v_lang);

--รหัสหัวหน้างาน (item11 - 12)

         if i.flgsal = 'Y' then
          v_flgsal  :=  get_label_name('HRAP3HX1', global_v_lang, '230');
        else
          v_flgsal  :=  get_label_name('HRAP3HX1', global_v_lang, '240');
         end if;

        if i.flgbonus = 'Y' then
          v_flgbonus  :=  get_label_name('HRAP3HX1', global_v_lang, '230');
        else
          v_flgbonus  :=  get_label_name('HRAP3HX1', global_v_lang, '240');
         end if;

          begin
            select codapman,   codposap
              into v_codapman, v_codposap       --รหัสผู้ประเมิน, ตำแหน่งผู้ประเมิน
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = i.codempid
               and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = i.codempid
                                and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                                );
                desc_codapman  := v_codapman ||' - '|| get_temploy_name(v_codapman,global_v_lang);
                desc_codapman2 := get_temploy_name(v_codapman,global_v_lang);
                desc_codposap  := v_codposap ||' - '|| get_tpostn_name(v_codposap,global_v_lang);
                desc_codposap  := get_tpostn_name(v_codposap,global_v_lang);
                desc_codposap2 := get_tpostn_name(v_codposap,global_v_lang);--User37 #7467 3. AP Module 11/01/2021 
            exception when no_data_found then
              v_codapman     := null;
              desc_codapman  := null;
              desc_codapman2 := null;
              v_codposap     := null;
              desc_codposap  := null;
              desc_codposap2 := null;
          end;

--รหัสผู้อนุมัติ (item13 - 14)
          begin
            select codapman,     codposap
              into v_codapprman, v_codposappr     --รหัสผู้อนุมัติ, ตำแหน่งผู้อนุมัติ
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = i.codempid
               and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = i.codempid
                                and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                                );
                desc_codapprman  := v_codapprman ||' - '|| get_temploy_name(v_codapprman,global_v_lang);
                desc_codapprman2 := get_temploy_name(v_codapprman,global_v_lang);
                desc_codposappr  := v_codposappr ||' - '|| get_tpostn_name(v_codposappr,global_v_lang);
                desc_codposappr2 := get_tpostn_name(v_codposappr,global_v_lang);
            exception when no_data_found then
              v_codapprman     := null;
              desc_codapprman  := null;
              desc_codapprman2 := null;
              v_codposappr     := null;
              desc_codposappr  := null;
              desc_codposappr2 := null;
          end;

--คะแนน(item15),เกรด(item16)
          v_qtytot3 := to_char(i.qtytot3 , 'fm999,999,990.00');
          v_grade := i.grdappr;


          obj_data.put('number',v_rcnt);
          obj_data.put('item1','DETAIL');
          obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
          obj_data.put('item3',b_index_numtime);
          obj_data.put('item4',i.codempid);
          obj_data.put('item5',v_period_date);
          obj_data.put('item6',v_compny_name);
          obj_data.put('item7',v_emp_name);
          obj_data.put('item8',v_emp_name2);

          obj_data.put('item9',v_comp_name);
          obj_data.put('item10',v_pos_name);

          obj_data.put('item11',desc_codapman);
          obj_data.put('item12',desc_codposap);

          obj_data.put('item13',v_codapprman);
          obj_data.put('item14',desc_codposappr);

          obj_data.put('item15',v_qtytot3);
          obj_data.put('item16',v_grade);

          obj_data.put('item17',v_flgsal);
          obj_data.put('item18',i.pctdsal);

          obj_data.put('item19','');--NOT USED

          obj_data.put('item20',v_flgbonus);
          obj_data.put('item21',i.pctdbon);
          obj_data.put('item22',i.codform||' - '||get_tintview_name(i.codform,global_v_lang));
          obj_data.put('item23',i.remark);
          obj_data.put('item24',i.remark2);
          obj_data.put('item25',i.remark3);
          obj_data.put('item26',' ');--User37 #7467 3. AP Module 11/01/2021 obj_data.put('item26',i.commtimpro);
          obj_data.put('item27',v_emp_name2);
          obj_data.put('item28',v_pos_name);
--          obj_data.put('item29',to_char(i.dteconfemp,'dd/mm/yyyy'));
          obj_data.put('item29',to_char(i.dteconfemp, 'dd/mm/')||to_char(to_number(to_char(i.dteconfemp, 'yyyy')) + nvl(global_vyear,0)));
          obj_data.put('item30','');--NOT USED
          obj_data.put('item31',desc_codapman2);
          obj_data.put('item32',desc_codposap2);
--          obj_data.put('item33',to_char(i.dteconfhd,'dd/mm/yyyy'));
          obj_data.put('item33',to_char(i.dteconfhd, 'dd/mm/')||to_char(to_number(to_char(i.dteconfhd, 'yyyy')) + nvl(global_vyear,0)));
          obj_data.put('item34','');--NOT USED
          obj_data.put('item35',desc_codapprman2);
          obj_data.put('item36',desc_codposappr2);
--          obj_data.put('item37',to_char(i.dteconflhd,'dd/mm/yyyy'));
          obj_data.put('item37',to_char(i.dteconflhd, 'dd/mm/')||to_char(to_number(to_char(i.dteconflhd, 'yyyy')) + nvl(global_vyear,0)));
          obj_data.put('item38','');
          obj_data.put('item39','');
          obj_data.put('item40','');

          obj_row.put(to_char(v_rcnt-1),obj_data);
---


          insert_ttemprpt(obj_data);
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
  --
  procedure gen_data_table1(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
      select codempid, codcomp, codpos, numlvl, codaplvl,
             (nvl(qtyta,0) + nvl(qtypuns,0)) qtyta_puns,                   --เวลามาทำงาน + ผิดวินัย
             (nvl(qtybeh,0) + nvl(qtybeh2,0) + nvl(qtybeh3,0)) Behavior,   --พฤติกรรม
             (nvl(qtycmp,0) + nvl(qtycmp2,0) + nvl(qtycmp3,0)) Competency, --ข้อมูลศักยภาพ (Competency)
             (nvl(qtykpie,0) + nvl(qtykpie2,0) + nvl(qtykpie3,0)) Kpi,     --KPI
             1 total, grdappr
        from tappemp
       where dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and nvl(codcomp,'%') like b_index_codcomp || '%'
         and nvl(codaplvl,'%') like b_index_codaplvl || '%'
         and codempid = nvl(p_codempid,codempid)
         and flgappr = 'C'
      order by codempid;

    v_weigth1      number;

    v_totwei_kpi number;
    v_pctta      number;
    v_pctpunsh   number;
    v_pctbeh     number;
    v_pctcmp     number;
    v_pctkpicp   number;
    v_pctkpiem   number;
    v_pctkpirt   number;

    v_qtyta      number;
    v_qtypuns    number;
    v_qtybeh     number;
    v_qtybeh2    number;
    v_qtybeh3    number;
    v_qtycmp     number;
    v_qtycmp2    number;
    v_qtycmp3    number;
    v_qtykpie    number;
    v_qtykpie2   number;
    v_qtykpie3   number;

    v_totscor1      number;
    v_totscor2      number;
    v_totscor3      number;
    v_totscor4      number;
    --<<User37 #7268 30/12/2021 
    v_codcomp_lvl   varchar2(100 char);
    v_dteeffec_lvl  date;
    -->>User37 #7268 30/12/2021 

    --<<User37 #7467 3. AP Module 11/01/2021 
    v_qtykpid       number;
    v_qtykpic       number;
    -->>User37 #7467 3. AP Module 11/01/2021 

  begin
    obj_row := json_object_t();

--เวลามาทำงาน/ผิดวินัย


    --Weightเวลามาทำงาน , น.น. การผิดวินัย
      get_taplvl_where(p_codempid, p_codcomp, p_codaplvl, nvl(p_dteapend , sysdate), v_codcomp_lvl,v_dteeffec_lvl);--User37 #7268 30/12/2021 

      begin
        select pctta, pctpunsh, pctbeh, pctcmp, pctkpicp, pctkpirt, pctkpiem
          into v_pctta, v_pctpunsh, v_pctbeh, v_pctcmp, v_pctkpicp, v_pctkpirt, v_pctkpiem
          from taplvl
         where codcomp  = v_codcomp_lvl--User37 #7268 30/12/2021 p_codcomp
           and codaplvl = p_codaplvl
           --<<User37 #7268 30/12/2021 
           and dteeffec = v_dteeffec_lvl;
           /*and dteeffec = (select max(dteeffec)
                             from taplvl
                            where codcomp = p_codcomp
                              and codaplvl = p_codaplvl
                              and dteeffec <= nvl(p_dteapend , sysdate) );*/
           -->>User37 #7268 30/12/2021 
          v_weigth1 := nvl(v_pctta,0) + nvl(v_pctpunsh,0);
          v_totwei_kpi := nvl(v_pctkpicp,0) + nvl(v_pctkpirt,0) + nvl(v_pctkpiem,0);
/*
pctta	  น.น. time attendance
pctpunsh  น.น. การผิดวินัย
pctbeh	  น.น. พฤติกรรม
pctcmp	  น.น. ศักยภาพ (Competency)
pctkpicp  น.น. kpi บริษัท
pctkpirt  น.น. kpi routine (หน่วยงาน)
pctkpiem  น.น. kpi เฉพาะบุคคล
*/
        exception when no_data_found then
          v_weigth1  := 0;
          v_pctta    := 0;
          v_pctpunsh := 0;
          v_pctbeh   := 0;
          v_pctcmp   := 0;
          v_pctkpicp := 0;
          v_pctkpirt := 0;
          v_pctkpiem := 0;
          v_totwei_kpi := 0;
      end;

    --คะแนนที่ได้(เวลามาทำงาน) , คะแนนผิดวินัยที่ได้
      begin
        select nvl(qtyta,0) , nvl(qtypuns,0),                   --เวลามาทำงาน + ผิดวินัย
               nvl(qtybeh,0), nvl(qtybeh2,0), nvl(qtybeh3,0),   --พฤติกรรม
               nvl(qtycmp,0), nvl(qtycmp2,0), nvl(qtycmp3,0),   --ข้อมูลศักยภาพ (Competency)
               nvl(qtykpie,0),nvl(qtykpie2,0),nvl(qtykpie3,0)   --KPI
               ,nvl(qtykpid,0),nvl(qtykpic,0)--User37 #7467 3. AP Module 11/01/2021 
          into v_qtyta , v_qtypuns,              --เวลามาทำงาน + ผิดวินัย
               v_qtybeh, v_qtybeh2, v_qtybeh3,   --พฤติกรรม
               v_qtycmp, v_qtycmp2, v_qtycmp3,   --ข้อมูลศักยภาพ (Competency)
               v_qtykpie,v_qtykpie2,v_qtykpie3   --KPI
               ,v_qtykpid,v_qtykpic--User37 #7467 3. AP Module 11/01/2021 

          from tappemp
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;
        exception when no_data_found then
          v_qtyta   := 0; v_qtypuns := 0;
          v_qtybeh  := 0; v_qtybeh2 := 0;  v_qtybeh3  := 0;
          v_qtycmp  := 0; v_qtycmp2 := 0;  v_qtycmp3  := 0;
          v_qtykpie := 0; v_qtykpie2 := 0; v_qtykpie3 := 0;
      end;
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
---เวลามาทำงาน + ผิดวินัย (OK)
      if nvl(v_weigth1,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,191)); ---เวลามาทำงาน + ผิดวินัย
      obj_data.put('item6',to_char(v_weigth1, 'fm999,999,990.00'));   --weigth เวลามาทำงาน + ผิดวินัย
      obj_data.put('item7',to_char((v_qtyta+v_qtypuns), 'fm999,999,990.00'));--User37 #7467 3. AP Module 11/01/2021 obj_data.put('item7',' ');
      obj_data.put('item8',' ');
      obj_data.put('item9',' ');
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;--User37 #7268 30/12/2021 
--พฤติกรรม
      if nvl(v_pctbeh,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,192)); ---พฤติกรรม
      --พฤติกรรม
      obj_data.put('item6',to_char(v_pctbeh, 'fm999,999,990.00'));   --WEIGHT
      obj_data.put('item7',to_char(v_qtybeh, 'fm999,999,990.00'));   --คะแนนพนักงาน
      obj_data.put('item8',to_char(v_qtybeh2, 'fm999,999,990.00'));  --คะแนนหัวหน้างาน
      obj_data.put('item9',to_char(v_qtybeh3, 'fm999,999,990.00'));  --คะแนนผู้ประเมินสุดท้าย
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

--ศักยภาพ (Competency)
      if nvl(v_pctcmp,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,193)); ---ศักยภาพ (Competency)
      --ศักยภาพ (Competency)
      obj_data.put('item6',to_char(v_pctcmp, 'fm999,999,990.00'));   --WEIGHT
      obj_data.put('item7',to_char(v_qtycmp, 'fm999,999,990.00'));   --คะแนนพนักงาน
      obj_data.put('item8',to_char(v_qtycmp2, 'fm999,999,990.00'));  --คะแนนหัวหน้างาน
      obj_data.put('item9',to_char(v_qtycmp3, 'fm999,999,990.00'));  --คะแนนผู้ประเมินสุดท้าย
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

--KPI(HEAD)
      if nvl(v_totwei_kpi,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,194)); ---KPI
      --KPI
      obj_data.put('item6',to_char(v_totwei_kpi, 'fm999,999,990.00'));   --WEIGHT KPI องค์กร
      obj_data.put('item7',' ');
      obj_data.put('item8',' ');
      obj_data.put('item9',' ');
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

--- KPI องค์กร
      if nvl(v_pctkpicp,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,195)); --- KPI องค์กร
      --- KPI องค์กร
      obj_data.put('item6',to_char(v_pctkpicp, 'fm999,999,990.00'));   --WEIGHT KPI องค์กร
      obj_data.put('item7',to_char(v_qtykpic, 'fm999,999,990.00'));   --User37 #7467 3. AP Module 11/01/2021 obj_data.put('item7',' ');
      obj_data.put('item8',' ');
      obj_data.put('item9',' ');
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

--- KPI หน่วยงาน
      if nvl(v_pctkpirt,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,196)); --- KPI หน่วยงาน
      --- KPI หน่วยงาน
      obj_data.put('item6',to_char(v_pctkpirt, 'fm999,999,990.00'));   --WEIGHT KPI หน่วยงาน
      obj_data.put('item7',to_char(v_qtykpid, 'fm999,999,990.00'));   --User37 #7467 3. AP Module 11/01/2021 obj_data.put('item7',' ');
      obj_data.put('item8',' ');
      obj_data.put('item9',' ');
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

--- KPI บุคคล
      if nvl(v_pctkpiem,0) > 0 then --User37 #7268 30/12/2021 
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE1');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);

      obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,197)); --- KPI บุคคล
      --- KPI บุคคล
      obj_data.put('item6',to_char(v_pctkpiem, 'fm999,999,990.00'));   --WEIGHT KPI บุคคล
      obj_data.put('item7',to_char(v_qtykpie, 'fm999,999,990.00'));   --คะแนนพนักงาน
      obj_data.put('item8',to_char(v_qtykpie2, 'fm999,999,990.00'));  --คะแนนหัวหน้างาน
      obj_data.put('item9',to_char(v_qtykpie3, 'fm999,999,990.00'));  --คะแนนผู้ประเมินสุดท้าย
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
      end if;

---TOTAL
      v_totscor1 := nvl(v_weigth1,0) + nvl(v_pctbeh,0) + nvl(v_pctcmp,0) + nvl(v_totwei_kpi,0); --TOTAL WEIGHT
      v_totscor2 := nvl(v_qtybeh,0) + nvl(v_qtycmp,0) + nvl(v_qtykpie,0); --TOTAL พนักงาน
      v_totscor3 := nvl(v_qtybeh2,0) + nvl(v_qtycmp2,0) + nvl(v_qtykpie2,0); --TOTAL หัวหน้างาน
      v_totscor4 := nvl(v_qtybeh3,0) + nvl(v_qtycmp3,0) + nvl(v_qtykpie3,0); --TOTAL ผู้ประเมินสุดท้าย

      if nvl(v_totscor1,0) > 0 or nvl(v_totscor2,0) > 0 or nvl(v_totscor3,0) > 0 or nvl(v_totscor4,0) > 0 then --TOTAL
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('number',v_rcnt);
          obj_data.put('item1','TABLE1');
          obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
          obj_data.put('item3',b_index_numtime);
          obj_data.put('item4',p_codempid);

          obj_data.put('item5',get_label_name ('HRAP3HX1' , global_v_lang ,200)); --- TOTAL
          ---TOTAL WEIGHT
          obj_data.put('item6',to_char(v_totscor1, 'fm999,999,990.00'));  --TOTAL WEIGHT
          obj_data.put('item7',to_char(v_totscor2, 'fm999,999,990.00'));  --TOTAL พนักงาน
          obj_data.put('item8',to_char(v_totscor3, 'fm999,999,990.00'));  --TOTAL หัวหน้างาน
          obj_data.put('item9',to_char(v_totscor4, 'fm999,999,990.00'));  --TOTAL ผู้ประเมินสุดท้าย
          obj_row.put(to_char(v_rcnt-1),obj_data);
          insert_ttemprpt(obj_data);
      end if;

/*
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
*/
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure gen_data_table2(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
      select codempid, codcomp, codpos, numlvl, codaplvl,
             (nvl(qtyta,0) + nvl(qtypuns,0)) qtyta_puns,                   --เวลามาทำงาน + ผิดวินัย
             (nvl(qtybeh,0) + nvl(qtybeh2,0) + nvl(qtybeh3,0)) Behavior,   --พฤติกรรม
             (nvl(qtycmp,0) + nvl(qtycmp2,0) + nvl(qtycmp3,0)) Competency, --ข้อมูลศักยภาพ (Competency)
             (nvl(qtykpie,0) + nvl(qtykpie2,0) + nvl(qtykpie3,0)) Kpi,     --KPI
             1 total, grdappr
        from tappemp
       where dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and nvl(codcomp,'%') like b_index_codcomp || '%'
         and nvl(codaplvl,'%') like b_index_codaplvl || '%'
         and codempid = nvl(p_codempid,codempid)
         and flgappr = 'C'
      order by codempid;

    v_scorfta       number;
    v_scorfpunsh    number;
    v_qtyscor1      number;
    v_qtyscor2      number;
    v_qtyscor3      number;
    v_qtyscor4      number;
    v_qtyscor5      number;
    v_qtyscor6      number;
    v_qtyscor7      number;
    v_qtyscor8      number;
    v_totscor1      number;
    v_totscor2      number;
    v_totscor3      number;
    v_totscor4      number;
    v_totscor5      number;
    --<<User37 #7268 30/12/2021 
    v_codcomp_lvl   varchar2(100 char);
    v_dteeffec_lvl  date;
    -->>User37 #7268 30/12/2021 

  begin
    obj_row := json_object_t();

--เวลามาทำงาน/ผิดวินัย
    --คะแนนเต็ม
      begin
    --คะแนนเต็ม Time Attendance, คะแนนเต็มการผิดวินัย  Misconduct
        select scorfta, scorfpunsh
          into v_scorfta, v_scorfpunsh
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = (select max(dteeffec)
                             from tattpreh
                            where codcompy = p_codcompy
                              and codaplvl = p_codaplvl );
        exception when no_data_found then
          v_scorfta    := 0;
          v_scorfpunsh := 0;
      end;
      v_totscor1 := nvl(v_scorfta,0) + nvl(v_scorfpunsh,0);
------------------------------------------
    --คะแนนที่ถูกหัก(เวลามาทำงาน)
      begin
        select sum(qtyscor) into v_qtyscor1
          from tappempta
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;
        exception when no_data_found then
          v_qtyscor1 := 0;
      end;
    --คะแนนที่ถูกหัก(การทำผิดวินัย)
      begin
        select sum(qtyscor) into v_qtyscor2
          from tappempmt
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;
        exception when no_data_found then
          v_qtyscor2 := 0;
      end;
      v_totscor2 := nvl(v_qtyscor1,0) + nvl(v_qtyscor2,0);
------------------------------------------
    --คะแนนที่ได้(เวลามาทำงาน) , คะแนนผิดวินัยที่ได้
      begin
        select sum(qtyta), sum(qtypuns) into v_qtyscor3, v_qtyscor4
          from tappemp
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;
        exception when no_data_found then
          v_qtyscor3 := 0;
          v_qtyscor4 := 0;
      end;
      v_totscor3 := nvl(v_qtyscor3,0) + nvl(v_qtyscor4,0);
------------------------------------------
    --Weightเวลามาทำงาน , น.น. การผิดวินัย
      get_taplvl_where(p_codempid, p_codcomp, p_codaplvl, nvl(p_dteapend , sysdate), v_codcomp_lvl,v_dteeffec_lvl);--User37 #7268 30/12/2021 
      begin
        select pctta, pctpunsh into v_qtyscor5, v_qtyscor6
          from taplvl
         where codcomp  = v_codcomp_lvl--User37 #7268 30/12/2021 p_codcomp
           and codaplvl = p_codaplvl
           --<<User37 #7268 30/12/2021 
           and dteeffec = v_dteeffec_lvl;
           /*and dteeffec = (select max(dteeffec)
                             from taplvl
                            where codcomp = p_codcomp
                              and codaplvl = p_codaplvl );*/
           -->>User37 #7268 30/12/2021 
        exception when no_data_found then
          v_qtyscor5 := 0;
          v_qtyscor6 := 0;
      end;
      v_totscor4 := nvl(v_qtyscor5,0) + nvl(v_qtyscor6,0);
------------------------------------------

      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);

---คะแนนเต็มเวลามาทำงาน > 0
        if v_scorfta > 0 then  --คะแนนเต็มเวลามาทำงาน > 0
            v_qtyscor7 := v_qtyscor3 * v_qtyscor5;  --คะแนนที่ได้(เวลามาทำงาน) * Weightเวลามาทำงาน
            v_totscor5 := nvl(v_totscor5,0) + nvl(v_qtyscor7,0);

            obj_data.put('number',v_rcnt);
            obj_data.put('item1','TABLE2');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
            obj_data.put('item5',get_label_name ('HRAP3HX2' , global_v_lang ,71)); --'เวลามาทำงาน'
            obj_data.put('item6',to_char(v_scorfta, 'fm999,999,990.00'));   --คะแนนเต็มเวลามาทำงาน (Time Attendance)
            obj_data.put('item7',to_char(v_qtyscor1, 'fm999,999,990.00'));   --คะแนนที่ถูกหัก(เวลามาทำงาน)
            obj_data.put('item8',to_char(v_qtyscor3, 'fm999,999,990.00'));   --คะแนนที่ได้(เวลามาทำงาน)
            obj_data.put('item9',to_char(v_qtyscor5, 'fm999,999,990.00'));   --Weightเวลามาทำงาน
            obj_data.put('item10',to_char(v_qtyscor7, 'fm999,999,990.00'));  --สุทธิเวลามาทำงาน
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
        end if;

---คะแนนเต็มการผิดวินัย > 0
        if v_scorfpunsh > 0 then  --คะแนนเต็มการผิดวินัย > 0
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            obj_data.put('number',v_rcnt);
            v_qtyscor8 := v_qtyscor4 * v_qtyscor6;  --คะแนนผิดวินัยที่ได้ * น.น. การผิดวินัย
            v_totscor5 := nvl(v_totscor5,0) + nvl(v_qtyscor8,0);
            obj_data.put('number',v_rcnt);
            obj_data.put('item1','TABLE2');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
            obj_data.put('item5',get_label_name ('HRAP3HX2' , global_v_lang ,72)); --'การทำผิดวินัย'
            obj_data.put('item6',to_char(v_scorfpunsh, 'fm999,999,990.00'));   --คะแนนเต็มการผิดวินัย
            obj_data.put('item7',to_char(v_qtyscor2, 'fm999,999,990.00'));   --คะแนนที่ถูกหัก(การทำผิดวินัย)
            obj_data.put('item8',to_char(v_qtyscor4, 'fm999,999,990.00'));   --คะแนนผิดวินัยที่ได้
            obj_data.put('item9',to_char(v_qtyscor6, 'fm999,999,990.00'));   --น.น. การผิดวินัย
            obj_data.put('item10',to_char(v_qtyscor8, 'fm999,999,990.00'));  --สุทธิการผิดวินัย
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
        end if;

---TOTAL
        if nvl(v_scorfta,0) > 0 or nvl(v_scorfpunsh,0) > 0 then --คะแนนเต็มเวลามาทำงาน > 0 ,คะแนนเต็มการผิดวินัย > 0
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            v_qtyscor8 := v_qtyscor4 * v_qtyscor6;  --คะแนนผิดวินัยที่ได้ * น.น. การผิดวินัย
            --User37 #7268 30/12/2021 v_totscor5 := nvl(v_totscor5,0) + nvl(v_qtyscor8,0);
            obj_data.put('number',v_rcnt);
            obj_data.put('item1','TABLE2');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
            obj_data.put('item5',get_label_name ('HRAP3HX2' , global_v_lang ,73)); --'TOTAL'
            obj_data.put('item6',to_char(v_totscor1, 'fm999,999,990.00'));   --รวมคะแนนเต็ม
            obj_data.put('item7',to_char(v_totscor2, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
            obj_data.put('item8',to_char(v_totscor3, 'fm999,999,990.00'));   --รวมคะแนนที่ได้
            obj_data.put('item9',to_char(v_totscor4, 'fm999,999,990.00'));   --รวมน.น.
            obj_data.put('item10',to_char(v_totscor5, 'fm999,999,990.00'));  --รวมสุทธิ
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
        end if;

/*
    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table3(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
        select codgrplv, qtyleav, qtyscor
          from tappempta
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by codgrplv;

    v_total1      number := 0;
    v_total2      number := 0;

  begin
    obj_row := json_object_t();


--เวลามาทำงาน/ผิดวินัย
    for i in c1 loop
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;
      v_total1 := v_total1 + nvl(i.qtyleav , 0);
      v_total2 := v_total2 + nvl(i.qtyscor , 0);

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE3');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
--      obj_data.put('item5', i.codgrplv); --'กลุ่มการลา'
      obj_data.put('item5', get_tlistval_name('GRPLEAVE',i.codgrplv,global_v_lang)); --'กลุ่มการลา'
      obj_data.put('item6',to_char(i.qtyleav,'fm999,999,990'));
      obj_data.put('item7',to_char(i.qtyscor,'fm999,999,990.00'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
    end loop;

---TOTAL
    if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0 then --จำนวนครั้ง > 0 ,คะแนนที่ถูกหัก > 0
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE3');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);

        obj_data.put('item5',get_label_name ('HRAP3HX2' , global_v_lang ,115)); --'TOTAL'
        obj_data.put('item6',to_char(v_total1, 'fm999,999,990'));   --รวมจำนวนครั้ง
        obj_data.put('item7',to_char(v_total2, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);
    end if;

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table4(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    cursor c1 is
        select codpunsh, qtypunsh, qtyscor
          from tappempmt
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by codpunsh;

    v_total1      number := 0;
    v_total2      number := 0;

  begin
    obj_row := json_object_t();
--เวลามาทำงาน/ผิดวินัย
    for i in c1 loop
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;
      v_total1 := v_total1 + nvl(i.qtypunsh , 0);
      v_total2 := v_total2 + nvl(i.qtyscor , 0);

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE4');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
----
      obj_data.put('item5', get_tcodec_name('TCODPUNH',i.codpunsh,global_v_lang)); --'รหัสการลงโทษ'
      obj_data.put('item6',to_char(i.qtypunsh,'fm999,999,990'));
      obj_data.put('item7',to_char(i.qtyscor,'fm999,999,990.00'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
    end loop;

---TOTAL
    if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0 then --จำนวนครั้ง > 0 ,คะแนนที่ถูกหัก > 0
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE4');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);
        obj_data.put('item5',get_label_name ('HRAP3HX2' , global_v_lang ,153)); --'TOTAL'
        obj_data.put('item6',to_char(v_total1, 'fm999,999,990'));   --รวมจำนวนครั้ง
        obj_data.put('item7',to_char(v_total2, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);
    end if;

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table5(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    v_maxseq3       number;--User37 #7268 30/12/2021 

    cursor c1 is
        select numgrup , decode(global_v_lang, '101',desgrupe, '102',desgrupt, '103',desgrup3
                                             , '104',desgrup4, '105',desgrup5, desgrupt) desgrup
          from tintvews
         where codform = p_codform
      order by numgrup;

    v_seq         number := 0;
    v_qtyscor     varchar2(400);
    v_qtyscorn    varchar2(400);
    v_total1      number := 0;
    v_total2      number := 0;
    v_total3      number := 0;

  begin
    obj_row := json_object_t();



--เวลามาทำงาน/ผิดวินัย
    for i in c1 loop
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;
      v_seq := v_seq + 1;

      --<<User37 #7268 30/12/2021 
      /*begin
          select qtyscor , qtyscorn
            into v_qtyscor , v_qtyscorn
            from tappbehg
           where dteyreap = b_index_dteyear
             and numtime  = b_index_numtime
             and codempid = p_codempid
             and numgrup = i.numgrup
             and numseq = (select max(numseq)
                             from tappbehg
                             where dteyreap = b_index_dteyear
                             and numtime  = b_index_numtime
                             and codempid = p_codempid
                             and numgrup = i.numgrup );
            exception when no_data_found then
              v_qtyscor  := 0;
              v_qtyscorn := 0;
      end;*/

      --3-ผู้ประเมินสุดท้าย
      begin
        select numseq
          into v_maxseq3
          from tappfm
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
           and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
           and numseq = (select max(numseq)
                           from tappfm
                          where dteyreap = b_index_dteyear
                            and numtime  = b_index_numtime
                            and codempid = p_codempid
                            and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                         );
      exception when no_data_found then
        v_maxseq3 := null;
      end;

      begin
        select sum(qtyscorn/pctwgt),sum(qtyscorn)
          into v_qtyscor,v_qtyscorn
          from tappbehi a
         where a.dteyreap = b_index_dteyear
           and a.numtime  = b_index_numtime
           and a.codempid = p_codempid
           and a.numgrup = i.numgrup
           and a.numseq = v_maxseq3;
      exception when no_data_found then
        v_qtyscor   := null;
        v_qtyscorn  := null;
      end;
      -->>User37 #7268 30/12/2021 

      v_total1 := v_total1 + 0;
      v_total2 := v_total2 + nvl(v_qtyscor, 0);
      v_total3 := v_total3 + nvl(v_qtyscorn, 0);

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE5');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
----
      obj_data.put('item5',to_char(v_seq,'fm999,999,990'));
      obj_data.put('item6',i.desgrup);

      obj_data.put('item7',' ');
      obj_data.put('item8',to_char(v_qtyscor,'fm999,999,990.00'));
      obj_data.put('item9',to_char(v_qtyscorn,'fm999,999,990.00'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
    end loop;

---TOTAL
    if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0  or nvl(v_total3,0) > 0 then
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE5');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);
        obj_data.put('item5',' ');
        obj_data.put('item6',get_label_name ('HRAP3HX2' , global_v_lang ,153)); --'TOTAL'
        obj_data.put('item7',to_char(v_total1, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item8',to_char(v_total2, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item9',to_char(v_total3, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);
    end if;

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table6(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    v_numgrup     number;
    cursor c1 is
        select numgrup , decode(global_v_lang, '101',desgrupe, '102',desgrupt, '103',desgrup3
                                             , '104',desgrup4, '105',desgrup5, desgrupt) desgrup
          from tintvews
         where codform = p_codform
      order by numgrup;

    cursor c2 is
        select numgrup, numitem , decode(global_v_lang, '101',desiteme, '102',desitemt, '103',desitem3
                                         , '104',desitem4, '105',desitem5, desitemt) desitem
          from tintvewd
         where codform = p_codform
           and numgrup = v_numgrup
      order by numgrup , numitem;

    v_seq         number := 0;
    v_seq2        number := 0;
    v_maxseq1     number := 0;
    v_maxseq2     number := 0;
    v_maxseq3     number := 0;
    v_qtycmp1     number := 0;
    v_qtycmp2     number := 0;
    v_qtycmp3     number := 0;
    v_qtyscorn1   number := 0;
    v_qtyscorn2   number := 0;
    v_qtyscorn3   number := 0;
    v_qtybeh1     number := 0;
    v_qtybehf1    number := 0;
    v_qtybeh2     number := 0;
    v_qtybehf2    number := 0;
    v_qtybeh3     number := 0;
    v_qtybehf3    number := 0;
    v_pctwgt      number := 0;
    v_remark      varchar2(500);

    v_qtyscor     varchar2(400);
    v_qtyscorn    varchar2(400);
    v_total1      number := 0;
    v_total2      number := 0;
    v_total3      number := 0;
    v_total4      number := 0;
    v_total5      number := 0;
    v_total6      number := 0;
    v_total7      number := 0;

  begin
    obj_row := json_object_t();



--เวลามาทำงาน/ผิดวินัย
    for i in c1 loop
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_numgrup := i.numgrup;
      v_rcnt := v_rcnt+1;
      v_seq  := v_seq + 1;
      v_seq2 := 0;

      v_total1 := v_total1 + 0;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE6');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
----
      obj_data.put('item5',get_label_name ('HRAP3HX3' , global_v_lang ,30) ||' '||to_char(v_seq,'fm999,999,990')); --'ส่วนที่'
      obj_data.put('item6',i.desgrup);
      obj_data.put('item7',' ');
      obj_data.put('item8',' ');
      obj_data.put('item9',' ');
      obj_data.put('item10',' ');
      obj_data.put('item11',' ');
      obj_data.put('item12',' ');
      obj_data.put('item13',' ');
      obj_data.put('item14',' ');
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);

        for j in c2 loop
------------------------------------------
            v_rcnt := v_rcnt+1;
            v_seq2 := v_seq2 + 1;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('number',v_seq2);
            obj_data.put('item1','TABLE6');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
----
            obj_data.put('item5',to_char(j.numitem,'fm999,999,990'));
            obj_data.put('item6',j.desitem);
----------------------------------
          v_pctwgt := 0;
          v_remark := null;
          --1-พนักงาน
          begin
            select numseq, qtybeh into v_maxseq1, v_qtybeh1
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq1 := null;
             v_qtybeh1 := null;
          end;

          begin
            select pctwgt,   qtyscorn, remark
                   ,qtyscorn/pctwgt qtybeh1--User37 #7268 30/12/2021 
              into v_pctwgt, v_qtyscorn1, v_remark   --คะแนน คะแนนสุทธิ
                   ,v_qtybeh1--User37 #7268 30/12/2021 
              from tappbehi a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.numgrup = i.numgrup
               and a.numitem = j.numitem
               and a.numseq = v_maxseq1;
            exception when no_data_found then
              v_qtyscorn1 := null;
          end;
          --2-หัวหน้า
          begin
            select numseq, qtybeh into v_maxseq2, v_qtybeh2
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq2 := null;
             v_qtybeh2 := null;
          end;

          begin
            select pctwgt,   qtyscorn, remark
                   ,qtyscorn/pctwgt qtybeh2--User37 #7268 30/12/2021 
              into v_pctwgt, v_qtyscorn2, v_remark   --คะแนน คะแนนสุทธิ
                   ,v_qtybeh2--User37 #7268 30/12/2021 
              from tappbehi a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.numgrup = i.numgrup
               and a.numitem = j.numitem
               and a.numseq = v_maxseq2;
            exception when no_data_found then
              v_qtyscorn2 := null;
          end;
          --3-ผู้ประเมินสุดท้าย
          begin
            select numseq, qtybeh into v_maxseq3, v_qtybeh3
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq3 := null;
             v_qtybeh3 := null;
          end;

          begin
            select pctwgt,   qtyscorn, remark
                   ,qtyscorn/pctwgt qtybeh3--User37 #7268 30/12/2021 
              into v_pctwgt, v_qtyscorn3, v_remark   --คะแนน คะแนนสุทธิ
                   ,v_qtybeh3--User37 #7268 30/12/2021 
              from tappbehi a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.numgrup = i.numgrup
               and a.numitem = j.numitem
               and a.numseq = v_maxseq3;
            exception when no_data_found then
              v_qtyscorn3 := null;
          end;
----------------------------------
            v_total1 := nvl(v_total1,0) + nvl(v_pctwgt,0);
            v_total2 := nvl(v_total2,0) + nvl(v_qtybeh1,0);
            v_total3 := nvl(v_total3,0) + nvl(v_qtybeh2,0);
            v_total4 := nvl(v_total4,0) + nvl(v_qtybeh3,0);
            v_total5 := nvl(v_total5,0) + nvl(v_qtyscorn1,0);
            v_total6 := nvl(v_total6,0) + nvl(v_qtyscorn2,0);
            v_total7 := nvl(v_total7,0) + nvl(v_qtyscorn3,0);

            obj_data.put('item7',to_char(v_pctwgt,'fm999,999,990.00'));  --Weight%
            obj_data.put('item8',to_char(v_qtybeh1,'fm999,999,990.00'));
            obj_data.put('item9',to_char(v_qtybeh2,'fm999,999,990.00'));
            obj_data.put('item10',to_char(v_qtybeh3,'fm999,999,990.00'));
            obj_data.put('item11',to_char(v_qtyscorn1,'fm999,999,990.00'));
            obj_data.put('item12',to_char(v_qtyscorn2,'fm999,999,990.00'));
            obj_data.put('item13',to_char(v_qtyscorn3,'fm999,999,990.00'));
            obj_data.put('item14',v_remark);
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
        end loop;
    end loop;

---TOTAL
    if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0  or nvl(v_total3,0) > 0  or nvl(v_total4,0) > 0   or
       nvl(v_total5,0) > 0 or nvl(v_total6,0) > 0  or nvl(v_total7,0) > 0 then
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE6');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);
        obj_data.put('item5',' ');
        obj_data.put('item6',get_label_name ('HRAP3HX2' , global_v_lang ,153)); --'TOTAL'
        obj_data.put('item7',to_char(v_total1, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item8',to_char(v_total2, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item9',to_char(v_total3, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item10',to_char(v_total4, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item11',to_char(v_total5, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item12',to_char(v_total6, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_data.put('item13',to_char(v_total7, 'fm999,999,990.00'));   --รวมคะแนนที่ถูกหัก
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);
    end if;

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table7(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    v_numgrup     number;
    v_pctwgt      number := 0;
    v_codtency    varchar2(100);
    v_codtency2   varchar2(100);
    v_codskill    varchar2(100);

    cursor c1 is
        select distinct codtency codtency , codskill
          from tappcmps
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by codtency , codskill;

    cursor c2 is
        select gradexpct, grade, qtyscor
          from tappcmps
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
           and codtency = v_codtency
           and codskill = v_codskill
           and numseq = (select max(numseq)
                           from tappcmps
                          where dteyreap = b_index_dteyear
                            and numtime  = b_index_numtime
                            and codempid = p_codempid
                            and codtency = v_codtency
                            and codskill = v_codskill
                           );

    v_seq         number := 0;
    v_seq2        number := 0;
    v_maxseq1     number := 0;
    v_maxseq2     number := 0;
    v_maxseq3     number := 0;
    v_qtycmp1     number := 0;
    v_qtycmp2     number := 0;
    v_qtycmp3     number := 0;
    v_qtyscorn1   number := 0;
    v_qtyscorn2   number := 0;
    v_qtyscorn3   number := 0;
    v_qtybeh1     number := 0;
    v_qtybehf1    number := 0;
    v_qtybeh2     number := 0;
    v_qtybehf2    number := 0;
    v_qtybeh3     number := 0;
    v_qtybehf3    number := 0;
    v_remark      varchar2(500);

    v_gradexpct   varchar2(10);
    v_grade       varchar2(10);
    v_qtyscor     varchar2(400);
    v_qtyscorn    varchar2(400);
    v_total1      number := 0;
    v_total2      number := 0;
    v_total3      number := 0;
    v_total4      number := 0;
    v_total5      number := 0;
    v_total6      number := 0;
    v_total7      number := 0;
    v_total8      number := 0;

  begin
    obj_row := json_object_t();


--เวลามาทำงาน/ผิดวินัย
    for i in c1 loop
------------------------------------------
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_codtency := i.codtency;
      v_codskill := i.codskill;
      v_codtency2 := null;
--      v_rcnt := v_rcnt+1;
      v_seq  := v_seq + 1;
      v_seq2 := 0;

      v_total1 := v_total1 + 0;

        for j in c2 loop
------------------------------------------
            v_rcnt := v_rcnt+1;
            v_seq2 := v_seq2 + 1;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('number',v_rcnt);
            obj_data.put('item1','TABLE7');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
            obj_data.put('item5',get_tcomptnc_name(i.codtency,global_v_lang));

          v_pctwgt := 0;
          v_remark := null;
----------------------------------
          --1-พนักงาน
          begin
            select numseq, qtycmp into v_maxseq1, v_qtycmp1
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq1 := null;
             v_qtycmp1 := null;
          end;

          begin
            select qtyscor, gradexpct , grade, remark
              into v_qtyscorn1, v_gradexpct , v_grade, v_remark
              from tappcmps a
             where a.dteyreap = b_index_dteyear

               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.codtency = i.codtency
               and a.codskill = i.codskill
               and a.numseq = nvl(v_maxseq1,0);
            exception when no_data_found then
              v_qtyscorn1 := null;
              v_gradexpct := null;
              v_grade := null;
          end;

          begin
            select pctwgt, qtyscor, qtyscorn
            into v_pctwgt, v_qtycmp1, v_qtyscorn1
              from tappcmpc
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and codtency = i.codtency
               and numseq = v_maxseq1;
            exception when no_data_found then
             v_pctwgt    := null;
             v_qtycmp1   := null;
             v_qtyscorn1 := null;
          end;

          --2-หัวหน้า
          begin
            select numseq, qtycmp into v_maxseq2, v_qtycmp2
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq2 := null;
             v_qtycmp2 := null;
          end;

          begin
            select qtyscor, gradexpct , grade, remark
              into v_qtyscorn2, v_gradexpct , v_grade, v_remark
              from tappcmps a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.codtency = i.codtency
               and a.codskill = i.codskill
               and a.numseq = v_maxseq2;
            exception when no_data_found then
              v_qtyscorn2 := null;
          end;

          begin
            select pctwgt, qtyscor, qtyscorn
            into v_pctwgt, v_qtycmp2, v_qtyscorn2
              from tappcmpc
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and codtency = i.codtency
               and numseq = v_maxseq2;
            exception when no_data_found then
             v_pctwgt    := null;
             v_qtycmp2   := null;
             v_qtyscorn2 := null;
          end;

          --3-ผู้ประเมินสุดท้าย
          begin
            select numseq, qtycmp into v_maxseq3, v_qtycmp3
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq3 := null;
             v_qtycmp3 := null;
          end;

          begin
            select qtyscor, gradexpct , grade, remark
              into v_qtyscorn3, v_gradexpct , v_grade, v_remark
              from tappcmps a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.codtency = i.codtency
               and a.codskill = i.codskill
               and a.numseq = v_maxseq3;
            exception when no_data_found then
              v_qtyscorn3 := null;
          end;

          begin
            select pctwgt, qtyscor, qtyscorn
            into v_pctwgt, v_qtycmp3, v_qtyscorn3
              from tappcmpc
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and codtency = i.codtency
               and numseq = v_maxseq3;
            exception when no_data_found then
             v_pctwgt    := null;
             v_qtycmp3   := null;
             v_qtyscorn3 := null;
          end;

----------------------------------
            obj_data.put('item6',to_char(v_pctwgt,'fm999,999,990.00'));  --Weight%
            obj_data.put('item7',i.codskill);
            obj_data.put('item8',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
            obj_data.put('item9',v_gradexpct);
            obj_data.put('item10',v_grade);
--------------------
            obj_data.put('item11',to_char(v_qtycmp1,'fm999,999,990.00'));
            obj_data.put('item12',to_char(v_qtycmp2,'fm999,999,990.00'));
            obj_data.put('item13',to_char(v_qtycmp3,'fm999,999,990.00'));
            obj_data.put('item14',to_char(v_qtyscorn1,'fm999,999,990.00'));
            obj_data.put('item15',to_char(v_qtyscorn2,'fm999,999,990.00'));
            obj_data.put('item16',to_char(v_qtyscorn3,'fm999,999,990.00'));
--------------------
            obj_data.put('item17',v_remark);
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
----
--            v_total1 := nvl(v_total1,0) + nvl(v_gradexpct,0);
--            v_total2 := nvl(v_total2,0) + nvl(v_grade,0);
            v_total3 := nvl(v_total3,0) + nvl(v_qtycmp1,0);
            v_total4 := nvl(v_total4,0) + nvl(v_qtycmp2,0);
            v_total5 := nvl(v_total5,0) + nvl(v_qtycmp3,0);
            v_total6 := nvl(v_total6,0) + nvl(v_qtyscorn1,0);
            v_total7 := nvl(v_total7,0) + nvl(v_qtyscorn2,0);
            v_total8 := nvl(v_total8,0) + nvl(v_qtyscorn3,0);
        end loop;
    end loop;

---TOTAL
    if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0  or nvl(v_total3,0) > 0  or nvl(v_total4,0) > 0 or
       nvl(v_total5,0) > 0 or nvl(v_total6,0) > 0  or nvl(v_total7,0) > 0  or nvl(v_total8,0) > 0  then
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE7');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);
        obj_data.put('item5',' ');
        obj_data.put('item6',' ');
        obj_data.put('item7',' ');
        obj_data.put('item8',get_label_name ('HRAP3HX2' , global_v_lang ,153)); --'TOTAL'
--        obj_data.put('item9',to_char(v_total1, 'fm999,999,990.00'));    --รวมระดับที่คาดหวัง
        obj_data.put('item9',' ');
--        obj_data.put('item10',to_char(v_total2, 'fm999,999,990.00'));   --รวมระดับที่ได้
        obj_data.put('item10',' ');
        obj_data.put('item11',to_char(v_total3, 'fm999,999,990.00'));   --รวมคะแนนที่ได้ พนักงาน
        obj_data.put('item12',to_char(v_total4, 'fm999,999,990.00'));   --รวมคะแนนที่ได้ หัวหน้างาน
        obj_data.put('item13',to_char(v_total5, 'fm999,999,990.00'));   --รวมคะแนนที่ได้ ผู้ประเมินสุดท้าย
        obj_data.put('item14',to_char(v_total6, 'fm999,999,990.00'));   --รวมคะแนนสุทธิ พนักงาน
        obj_data.put('item15',to_char(v_total7, 'fm999,999,990.00'));   --รวมคะแนนสุทธิ หัวหน้างาน
        obj_data.put('item16',to_char(v_total8, 'fm999,999,990.00'));   --รวมคะแนนสุทธิ ผู้ประเมินสุดท้าย
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);
    end if;

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table8(json_str_output out clob) is
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

    v_total         number;

    v_level         number;
    v_level1        number;
    v_level2        number;
    v_level3        number;
    v_Behavior      number;--พฤติกรรม
    v_Competency    number;--ข้อมูลศักยภาพ (Competency)
    v_Kpi           number;--KPI

    v_numgrup     number;
    v_pctwgt      number := 0;
    v_codtency    varchar2(100);
    v_codtency2   varchar2(100);
    v_codskill    varchar2(100);
    v_typkpi      varchar2(10);

    cursor c1 is
--           รหัส KPI,เป้าหมาย, มูลค่า,     Weight%,ผลงานล่าสุด, คะแนนสุทธิ
      select codkpi, target, mtrfinish, pctwgt, achieve, qtyscorn
             ,kpides--User37 #7268 30/12/2021 
        from tkpiemp
       where dteyreap = b_index_dteyear
         and numtime  = b_index_numtime
         and codempid = nvl(p_codempid,codempid)
         and typkpi   = v_typkpi
      order by codempid;

    cursor c2 is
        select gradexpct, grade, qtyscor
          from tappcmps
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
           and codtency = v_codtency
           and codskill = v_codskill
           and numseq = (select max(numseq)
                           from tappcmpc
                          where dteyreap = b_index_dteyear
                            and numtime  = b_index_numtime
                            and codempid = p_codempid
                            and codtency = v_codtency
                            and codskill = v_codskill
                           );

    v_descwork   varchar2(1000);
    v_qtykpic     number := 0;
    v_qtykpid     number := 0;
    v_seq         number := 0;
    v_seq2        number := 0;
    v_maxseq1     number := 0;
    v_maxseq2     number := 0;
    v_maxseq3     number := 0;
    v_qtykpi1     number := 0;
    v_qtykpi2     number := 0;
    v_qtykpi3     number := 0;
    v_qtyscorn1   number := 0;
    v_qtyscorn2   number := 0;
    v_qtyscorn3   number := 0;
    v_qtybeh1     number := 0;
    v_qtybehf1    number := 0;
    v_qtybeh2     number := 0;
    v_qtybehf2    number := 0;
    v_qtybeh3     number := 0;
    v_qtybehf3    number := 0;
    v_remark      varchar2(500);

    v_gradexpct   varchar2(10);
    v_grade       varchar2(10);
    v_qtyscor1    number := 0;
    v_qtyscor2    number := 0;
    v_qtyscor3    number := 0;
    v_total1      number := 0;
    v_total2      number := 0;
    v_total3      number := 0;
    v_total4      number := 0;
    v_total5      number := 0;
    v_total6      number := 0;
    v_total7      number := 0;
    v_total8      number := 0;

    v_cnt         number := 0;--User37 #7268 30/12/2021 

  begin
    obj_row := json_object_t();
    begin
        select qtykpic, qtykpid -- KPI หน่วยงาน, องค์กร
          into v_qtykpic, v_qtykpid
          from tappemp
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid;
        exception when no_data_found then
         v_qtykpic := null;
         v_qtykpid := null;
    end;

    for v_loop in 1..3 loop --ประเภท KPI (D-Department KPI, J-Funtional KPI, I-Individual KPI)
        if v_loop = 1 then
            v_typkpi := 'D';  --D-Department KPI
        elsif v_loop = 2 then
            v_typkpi := 'J';  --J-Funtional KPI
        else
            v_typkpi := 'I';  --I-Individual KPI
        end if;

        --<<User37 #7268 30/12/2021 
        v_cnt := 0;--User37 #7268 30/12/2021 
        begin
          select count(*)
            into v_cnt
            from tkpiemp
           where dteyreap = b_index_dteyear
             and numtime  = b_index_numtime
             and codempid = nvl(p_codempid,codempid)
             and typkpi   = v_typkpi;
        exception when no_data_found then
          v_cnt := 0;--User37 #7268 30/12/2021 
        end;
        if v_cnt > 0 then
        -->>User37 #7268 30/12/2021 

    --KPI (Header)
        v_rcnt   := v_rcnt+1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('number',v_rcnt);
        obj_data.put('item1','TABLE8');
        obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
        obj_data.put('item3',b_index_numtime);
        obj_data.put('item4',p_codempid);
        ----
        --<<User37 #7268 30/12/2021 
        if v_typkpi = 'D' then  --D-Department KPI
          obj_data.put('item6',get_label_name ('HRAP3HX5' , global_v_lang ,21)); --'KPI หน่วยงาน'
        elsif v_typkpi = 'J' then  --J-Funtional KPI
          obj_data.put('item6',get_label_name ('HRAP3HX5' , global_v_lang ,22)); --'Functional KPI'
        elsif v_typkpi = 'I' then  --I-Individual KPI
          obj_data.put('item6',get_label_name ('HRAP3HX5' , global_v_lang ,23)); --'Individual KPI'
        end if;
        obj_data.put('item5',' ');
        /*obj_data.put('item5',get_label_name ('HRAP3HX5' , global_v_lang ,21)); --'KPI หน่วยงาน'
        obj_data.put('item6',' ');*/
        -->>User37 #7268 30/12/2021 
        obj_data.put('item7',' ');
        obj_data.put('item8',' ');
        obj_data.put('item9',' ');
        obj_data.put('item10',' ');
        obj_data.put('item11',' ');
        obj_data.put('item12',' ');
        obj_data.put('item13',' ');
        obj_data.put('item14',' ');
        obj_data.put('item15',' ');
        obj_data.put('item16',' ');
        obj_data.put('item17',' ');
        obj_data.put('item19',v_typkpi);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        insert_ttemprpt(obj_data);

    --KPI (Detail)
        for i in c1 loop
          v_flgdata := 'Y';
          v_flgsecu := 'Y';
          v_codtency2 := null;
          v_rcnt := v_rcnt+1;
          v_seq  := v_seq + 1;
          v_seq2 := 0;
          v_remark := null;

          v_total1 := v_total1 + 0;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('number',v_rcnt);
          obj_data.put('item1','TABLE8');
          obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
          obj_data.put('item3',b_index_numtime);
          obj_data.put('item4',p_codempid);
          ----
          obj_data.put('item5',i.codkpi);
          obj_data.put('item6',i.kpides);--User37 #7268 30/12/2021 obj_data.put('item6',' ');
          obj_data.put('item7',i.target);  --เป้าหมาย
          obj_data.put('item8',to_char(i.mtrfinish,'fm999,999,990.00'));  --มูลค่า
          obj_data.put('item9',to_char(i.pctwgt,'fm999,999,990.00'));  --Weight%

          begin
            select descwork into v_descwork
              from tappkpimth
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and codkpi   = i.codkpi
               and dtemonth = (select max(dtemonth)
                               from tappkpimth
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and codkpi   = i.codkpi );
            exception when no_data_found then
             v_descwork := null;
          end;

          --1-พนักงาน (คะแนน)
          begin
            select numseq, qtykpi into v_maxseq1, v_qtykpi1
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '1'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq1 := null;
             v_qtykpi1 := null;
          end;

          --คะแนนที่ได้, คะแนนสุทธิ, หมายเหตุ
          begin
            select qtyscor, qtyscorn, remark
              into v_qtyscor1, v_qtyscorn1, v_remark
              from tappkpid  a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.kpino  = i.codkpi
               and a.numseq = v_maxseq1;
            exception when no_data_found then
              v_qtyscor1  := 0;
              v_qtyscorn1 := 0;
          end;

          --2-หัวหน้า
          begin
            select numseq, qtykpi into v_maxseq2, v_qtykpi2
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '2'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq2 := null;
             v_qtykpi2 := null;
          end;

          --คะแนนที่ได้, คะแนนสุทธิ, หมายเหตุ
          begin
            select qtyscor, qtyscorn, remark
              into v_qtyscor2, v_qtyscorn2, v_remark
              from tappkpid  a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.kpino  = i.codkpi
               and a.numseq = v_maxseq2;
            exception when no_data_found then
              v_qtyscor2  := 0;
              v_qtyscorn2 := 0;
          end;

          --3-ผู้ประเมินสุดท้าย
          begin
            select numseq, qtykpi into v_maxseq3, v_qtykpi3
              from tappfm
             where dteyreap = b_index_dteyear
               and numtime  = b_index_numtime
               and codempid = p_codempid
               and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
               and numseq = (select max(numseq)
                               from tappfm
                              where dteyreap = b_index_dteyear
                                and numtime  = b_index_numtime
                                and codempid = p_codempid
                                and flgapman = '3'  --ประเมินในฐานะ (1-พนักงาน, 2-หัวหน้า, 3-ผู้ประเมินสุดท้าย, 4-คนอื่นๆ)
                               );
            exception when no_data_found then
             v_maxseq3 := null;
             v_qtykpi3 := null;
          end;

          --คะแนนที่ได้, คะแนนสุทธิ, หมายเหตุ
          begin
            select qtyscor, qtyscorn, remark
              into v_qtyscor3, v_qtyscorn3, v_remark
              from tappkpid  a
             where a.dteyreap = b_index_dteyear
               and a.numtime  = b_index_numtime
               and a.codempid = p_codempid
               and a.kpino  = i.codkpi
               and a.numseq = v_maxseq3;
            exception when no_data_found then
              v_qtyscor3  := 0;
              v_qtyscorn3 := 0;
          end;

          obj_data.put('item10',v_descwork);                              --ผลงานล่าสุด
          obj_data.put('item11',to_char(v_qtyscor1,'fm999,999,990.00'));  --คะแนนที่ได้ พนง.
          obj_data.put('item12',to_char(v_qtyscor2,'fm999,999,990.00'));  --คะแนนที่ได้ หัวหน้า
          obj_data.put('item13',to_char(v_qtyscor3,'fm999,999,990.00'));  --คะแนนที่ได้ ผู้ประเมินสุดท้าย
          obj_data.put('item14',to_char(v_qtyscorn1,'fm999,999,990.00'));  --คะแนนสุทธิ พนง.
          obj_data.put('item15',to_char(v_qtyscorn2,'fm999,999,990.00'));  --คะแนนสุทธิ หัวหน้า
          obj_data.put('item16',to_char(v_qtyscorn3,'fm999,999,990.00'));  --คะแนนสุทธิ ผู้ประเมินสุดท้าย
          obj_data.put('item17',v_remark);  --หมายเหตุ
          insert_ttemprpt(obj_data);--User37 #7268 30/12/2021 
    ----
          v_total1 := nvl(v_total1,0) + nvl(i.pctwgt,0);  --Weight%
          v_total2 := nvl(v_total2,0) + nvl(v_qtyscor1,0); --คะแนนที่ได้ พนง.
          v_total3 := nvl(v_total3,0) + nvl(v_qtyscor2,0); --คะแนนที่ได้ หัวหน้า
          v_total4 := nvl(v_total4,0) + nvl(v_qtyscor3,0); --คะแนนที่ได้ ผู้ประเมินสุดท้าย
          v_total5 := nvl(v_total5,0) + nvl(v_qtyscorn1,0); --คะแนนสุทธิ พนง.
          v_total6 := nvl(v_total6,0) + nvl(v_qtyscorn2,0); --คะแนนสุทธิ หัวหน้า
          v_total7 := nvl(v_total7,0) + nvl(v_qtyscorn3,0); --คะแนนสุทธิ ผู้ประเมินสุดท้าย
    ----------------------------------
        end loop;  --for i in c1 loop

    ---TOTAL
        if nvl(v_total1,0) > 0 or nvl(v_total2,0) > 0  or nvl(v_total3,0) > 0  or nvl(v_total4,0) > 0 or
           nvl(v_total5,0) > 0 or nvl(v_total6,0) > 0  or nvl(v_total7,0) > 0  then
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('number',v_rcnt);
            obj_data.put('item1','TABLE8');
            obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
            obj_data.put('item3',b_index_numtime);
            obj_data.put('item4',p_codempid);
            obj_data.put('item5',' ');
            obj_data.put('item6',get_label_name ('HRAP3HX2' , global_v_lang ,153)); --'TOTAL'
            obj_data.put('item7',' ');
            obj_data.put('item8',' ');
            obj_data.put('item9',to_char(v_total1, 'fm999,999,990.00'));   --Weight%
            obj_data.put('item10',' ');
            obj_data.put('item11',to_char(v_total2, 'fm999,999,990.00'));   --คะแนนที่ได้ พนง.
            obj_data.put('item12',to_char(v_total3, 'fm999,999,990.00'));   --คะแนนที่ได้ หัวหน้า
            obj_data.put('item13',to_char(v_total4, 'fm999,999,990.00'));   --คะแนนที่ได้ ผู้ประเมินสุดท้าย
            obj_data.put('item14',to_char(v_total5, 'fm999,999,990.00'));   --คะแนนสุทธิ พนง.
            obj_data.put('item15',to_char(v_total6, 'fm999,999,990.00'));   --คะแนนสุทธิ หัวหน้า
            obj_data.put('item16',to_char(v_total7, 'fm999,999,990.00'));   --คะแนนสุทธิ ผู้ประเมินสุดท้าย
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);
        end if;
        end if;--User37 #7268 30/12/2021 
    end loop; --for v_loop in 1..3 loop --ประเภท KPI (D-Department KPI, J-Funtional KPI, I-Individual KPI)

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table9(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);

    cursor c1 is
        select codtency , codskill, gradexpct, grade
          from tappcmpf
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by codtency , codskill;

  begin
    obj_row := json_object_t();

    for i in c1 loop
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE9');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
      ----
      obj_data.put('item5',get_tcomptnc_name(i.codtency,global_v_lang));
      obj_data.put('item6',i.codskill);
      obj_data.put('item7',get_tcodec_name('TCODSKIL',i.codskill,global_v_lang));
      obj_data.put('item8',to_char(i.gradexpct,'fm999,999,990.00'));  --Level ที่คาดหวัง
      obj_data.put('item9',to_char(i.grade,'fm999,999,990.00'));      --Level ที่ได้
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
----------------------------------
    end loop;  --for i in c1 loop

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table10(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);

    cursor c1 is
        select codcours
          from tapptrnf
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by codcours;

  begin
    obj_row := json_object_t();

    for i in c1 loop
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE10');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
      ----
      obj_data.put('item5',i.codcours);
      obj_data.put('item6',get_tcourse_name(i.codcours,global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
    end loop;  --for i in c1 loop

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --

  procedure gen_data_table11(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_codempid      varchar2(100 char);

    cursor c1 is
        select coddevp, desdevp
          from tappdevf
         where dteyreap = b_index_dteyear
           and numtime  = b_index_numtime
           and codempid = p_codempid
      order by coddevp;

  begin
    obj_row := json_object_t();

    for i in c1 loop
      v_flgdata := 'Y';
      v_flgsecu := 'Y';
      v_rcnt := v_rcnt+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('number',v_rcnt);
      obj_data.put('item1','TABLE11');
      obj_data.put('item2',b_index_dteyear + nvl(global_vyear,0));
      obj_data.put('item3',b_index_numtime);
      obj_data.put('item4',p_codempid);
      ----
      obj_data.put('item5',to_char(v_rcnt,'fm999,999,990'));
      obj_data.put('item6',i.desdevp);
      obj_row.put(to_char(v_rcnt-1),obj_data);
      insert_ttemprpt(obj_data);
    end loop;  --for i in c1 loop

/*    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;*/
    json_str_output := obj_row.to_clob;
  end;
  --
/*
  procedure get_data_table(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_tablea(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data_tablea(json_str_output out clob) is
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

    cursor c1 is
      select codempid,codcomp,dteyreap,numtime,grdap,
             nvl(qtyta,0)qtyta,nvl(qtypuns,0)qtypuns,nvl(qtybeh,0)qtybeh,
             nvl(qtycmp,0)qtycmp,nvl(qtykpie,0)qtykpie,nvl(qtykpid,0)qtykpid,
             nvl(qtykpic,0)qtykpic,nvl(qtytotnet,0)qtytotnet
        from tappemp
       where (dteyreap = nvl(b_index_dteyear,0)
              or dteyreap = nvl(b_index_numtime,0))
         and codempid = p_codempid
      order by dteyreap desc,numtime desc;

  begin
    obj_row := json_object_t();

    for i in c1 loop
        v_flgdata := 'Y';
               --v_flgsecu := 'Y';

        flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if flgpass then
            v_flgsecu := 'Y';
            v_rcnt := v_rcnt+1;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('dteyreap',i.dteyreap);
            obj_data.put('numtime',i.numtime);
            obj_data.put('grdap',i.grdap);
            obj_data.put('qtyta',to_char(i.qtyta,'fm999,999,990.00'));
            obj_data.put('qtypuns',to_char(i.qtypuns,'fm999,999,990.00'));
            obj_data.put('qtybeh',to_char(i.qtybeh,'fm999,999,990.00'));
            obj_data.put('qtycmp',to_char(i.qtycmp,'fm999,999,990.00'));
            obj_data.put('qtykpie',to_char(i.qtykpie,'fm999,999,990.00'));
            obj_data.put('qtykpid',to_char(i.qtykpid,'fm999,999,990.00'));
            obj_data.put('qtykpic',to_char(i.qtykpic,'fm999,999,990.00'));
            obj_data.put('qtytot',to_char(i.qtytotnet,'fm999,999,990.00'));
            obj_row.put(to_char(v_rcnt-1),obj_data);
            insert_ttemprpt(obj_data);

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

*/
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_dteyear   := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_numtime   := to_number(hcm_util.get_string_t(json_obj,'p_numtime'));
    b_index_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codaplvl  := hcm_util.get_string_t(json_obj,'p_codaplvl');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_report;
---

  procedure clear_ttemprpt is
  begin
    begin
      delete from ttemprpt where codempid = global_v_codempid and codapp like p_codapp||'%';
      if global_v_codempid is null then
          delete from ttemprpt where codapp = 'HRAP3HX';
      end if;
      commit;
    exception when others then null;
    end;
  end clear_ttemprpt;


  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;

  begin
    initial_report(json_str_input);
    clear_ttemprpt;
    isInsertReport := true;
    if param_msg_error is null then
      global_vyear := hcm_appsettings.get_additional_year;
      for i in 0..json_index_rows.get_size-1 loop
--      for i in 0..1 loop
        p_index_rows       := hcm_util.get_json_t(json_index_rows, to_char(i));
        p_codempid         := hcm_util.get_string_t(p_index_rows, 'codempid');
/*
        if nvl(p_codempid,' ') = ' ' then
            p_codempid := hcm_util.get_string_t(p_index_rows, 'p_codempid');
        end if;
*/
        get_data_detail(json_str_input ,json_str_output);

        get_data_table1(json_str_input ,json_str_output);

        get_data_table2(json_str_input ,json_str_output);

        get_data_table3(json_str_input ,json_str_output);

        get_data_table4(json_str_input ,json_str_output);

        get_data_table5(json_str_input ,json_str_output);

        get_data_table6(json_str_input ,json_str_output);

        get_data_table7(json_str_input ,json_str_output);

        get_data_table8(json_str_input ,json_str_output);

        get_data_table9(json_str_input ,json_str_output);

        get_data_table10(json_str_input ,json_str_output);

        get_data_table11(json_str_input ,json_str_output);
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
    v_item16        ttemprpt.item16%type;
    v_item17        ttemprpt.item17%type;
    v_item18        ttemprpt.item18%type;
    v_item19        ttemprpt.item19%type;
    v_item20        ttemprpt.item20%type;
    v_item21        ttemprpt.item21%type;
    v_item22        ttemprpt.item22%type;
    v_item23        ttemprpt.item23%type;
    v_item24        ttemprpt.item24%type;
    v_item25        ttemprpt.item25%type;
    v_item26        ttemprpt.item26%type;
    v_item27        ttemprpt.item27%type;
    v_item28        ttemprpt.item28%type;
    v_item29        ttemprpt.item29%type;
    v_item30        ttemprpt.item30%type;
    v_item31        ttemprpt.item31%type;
    v_item32        ttemprpt.item32%type;
    v_item33        ttemprpt.item33%type;
    v_item34        ttemprpt.item34%type;
    v_item35        ttemprpt.item35%type;
    v_item36        ttemprpt.item36%type;
    v_item37        ttemprpt.item37%type;
    v_item38        ttemprpt.item38%type;
    v_item39        ttemprpt.item39%type;
    v_item40        ttemprpt.item40%type;

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
    v_item14      := nvl(hcm_util.get_string_t(obj_data, 'item14'), '');
    v_item15      := nvl(hcm_util.get_string_t(obj_data, 'item15'), '');
    v_item16      := nvl(hcm_util.get_string_t(obj_data, 'item16'), '');
    v_item17      := nvl(hcm_util.get_string_t(obj_data, 'item17'), '');
    v_item18      := nvl(hcm_util.get_string_t(obj_data, 'item18'), '');
    v_item19      := nvl(hcm_util.get_string_t(obj_data, 'item19'), '');
    v_item20      := nvl(hcm_util.get_string_t(obj_data, 'item20'), '');
    v_item21      := nvl(hcm_util.get_string_t(obj_data, 'item21'), '');
    v_item22      := nvl(hcm_util.get_string_t(obj_data, 'item22'), '');
    v_item23      := nvl(hcm_util.get_string_t(obj_data, 'item23'), '');
    v_item24      := nvl(hcm_util.get_string_t(obj_data, 'item24'), '');
    v_item25      := nvl(hcm_util.get_string_t(obj_data, 'item25'), '');
    v_item26      := nvl(hcm_util.get_string_t(obj_data, 'item26'), '');
    v_item27      := nvl(hcm_util.get_string_t(obj_data, 'item27'), '');
    v_item28      := nvl(hcm_util.get_string_t(obj_data, 'item28'), '');
    v_item29      := nvl(hcm_util.get_string_t(obj_data, 'item29'), '');
    v_item30      := nvl(hcm_util.get_string_t(obj_data, 'item30'), '');
    v_item31      := nvl(hcm_util.get_string_t(obj_data, 'item31'), '');
    v_item32      := nvl(hcm_util.get_string_t(obj_data, 'item32'), '');
    v_item33      := nvl(hcm_util.get_string_t(obj_data, 'item33'), '');
    v_item34      := nvl(hcm_util.get_string_t(obj_data, 'item34'), '');
    v_item35      := nvl(hcm_util.get_string_t(obj_data, 'item35'), '');
    v_item36      := nvl(hcm_util.get_string_t(obj_data, 'item36'), '');
    v_item37      := nvl(hcm_util.get_string_t(obj_data, 'item37'), '');
    v_item38      := nvl(hcm_util.get_string_t(obj_data, 'item38'), '');
    v_item39      := nvl(hcm_util.get_string_t(obj_data, 'item39'), '');
    v_item40      := nvl(hcm_util.get_string_t(obj_data, 'item40'), '');
    begin
      select nvl(max(numseq),0) into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = p_codapp;
    exception when no_data_found then  null;
    end;
    v_numseq := v_numseq + 1;


    begin
        select namimage  into v_image
          from tempimge
         where codempid = p_codempid;
      exception when no_data_found then
        v_image := null;
    end;

    if v_image is not null then
        v_image      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_image;
        v_has_image  := 'Y';
    end if;

    begin
        select namimage   into v_image2
          from tempimge
         where codempid = v_codreview;
      exception when no_data_found then
        v_image2 := null;
    end;

    if v_image2 is not null then
        v_image2     := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_image2;
        v_has_image2 := 'Y';
    end if;

    begin

       insert into ttemprpt
             ( codempid, codapp, numseq
               , item1, item2, item3, item4, item5, item6, item7, item8, item9, item10
               , item11,item12,item13,item14,item15,item16,item17,item18,item19,item20
               , item21,item22,item23,item24,item25,item26,item27,item28,item29,item30
               , item31,item32,item33,item34,item35,item36,item37,item38,item39,item40
             )
        values
             ( global_v_codempid, p_codapp, v_numseq
--             ( global_v_coduser, p_codapp, v_numseq
             ,v_item1,v_item2,v_item3,v_item4,v_item5,v_item6,v_item7,v_item8,v_item9,v_item10
             ,v_item11,v_item12,v_item13,v_item14,v_item15,v_item16,v_item17,v_item18,v_item19,v_item20
             ,v_item21,v_item22,v_item23,v_item24,v_item25,v_item26,v_item27,v_item28,v_item29,v_item30
             ,v_item31,v_item32,v_item33,v_item34,v_item35,v_item36,v_item37,v_item38,v_has_image, v_image
        );
       commit;
      exception when others then  null;
    end;
  end;
/*
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
--             ( global_v_codempid, p_codapp, v_numseq, v_item1,v_item2,v_item3
             ( global_v_coduser, p_codapp, v_numseq, v_item1,v_item2,v_item3
             , v_item4,v_item5,v_item6, v_item7, v_item8, v_item9, v_item10
             , v_item11, v_item12, v_item13
        );
      exception when others then
        null;
      end;
  end;
*/
----
  --
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'AP3H';

  begin
    null;
 /*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --
  --<<User37 #7268 30/12/2021 
  procedure get_taplvl_where(p_codempid in varchar2, p_codcomp_in in varchar2, p_codaplvl in varchar2,
                             p_dteapend_in in date, p_codcomp_out out varchar2, p_dteeffec out date) as
    v_check         boolean;
    v_statement     clob;

    cursor c1 is
      select a.codcomp, a.codaplvl, a.condap, a.dteeffec
        from taplvl a
       where p_codcomp_in like a.codcomp||'%'
         and a.codaplvl = p_codaplvl
         and a.dteeffec = (select max(b.dteeffec)
                             from taplvl b
                            where b.codaplvl = a.codaplvl
                              and b.codcomp = a.codcomp
                              and b.codaplvl = p_codaplvl
                              and dteeffec <= trunc(p_dteapend_in))
    order by a.codcomp desc,codaplvl;
  begin
    for r1 in c1 loop
      v_statement := 'select count(*) from v_hrap14e where codempid = '''||p_codempid || ''' and staemp <> 9 and '|| r1.condap;
      v_check     := EXECUTE_STMT(v_statement);
      if v_check then
        p_dteeffec := r1.dteeffec;
        p_codcomp_out := r1.codcomp;
        exit;
      end if;
    end loop;
  end;
  -->>User37 #7268 30/12/2021 
end;

/

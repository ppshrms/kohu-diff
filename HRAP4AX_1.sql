--------------------------------------------------------
--  DDL for Package Body HRAP4AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4AX" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_syncond     := hcm_util.get_string_t(json_obj,'p_syncond');
    b_index_grade       := hcm_util.get_string_t(json_obj,'p_grade');
    b_index_qtygrade    := hcm_util.get_string_t(json_obj,'p_qtygrade');
    b_index_score       := hcm_util.get_string_t(json_obj,'p_score');
    b_index_qtyscore    := hcm_util.get_string_t(json_obj,'p_qtyscore');
    b_index_yearst      := hcm_util.get_string_t(json_obj,'p_yearst');
    b_index_yearen      := hcm_util.get_string_t(json_obj,'p_yearen');

    p_codempid_detail   := hcm_util.get_string_t(json_obj,'p_codempid_detail');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_codpos            tpostn.codpos%type;
  begin

    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
    v_chken         varchar2(4000 char) := hcm_secur.get_v_chken;

    v_salhur		number := 0;
	v_salday		number := 0;
	v_salary		number := 0;
    v_cond          varchar2(4000 char);
    v_stmt          varchar2(4000 char);
    v_flgfound      boolean;
v_codempid temploy1.codempid%type;



   cursor c_chkemp is
      select count(*),a.codempid
        from tappemp a
       where a.codcomp like b_index_codcomp||'%'
         and a.dteyreap between b_index_yearst and b_index_yearen
                and ( ((b_index_grade is not null and b_index_grade <> 'ALL') or b_index_score is not null
               )
             or
               (b_index_grade = 'ALL' and b_index_score is null
               )
            )
          group by a.codempid
          having count(*) >= nvl(nvl(b_index_qtygrade,-1),nvl(b_index_qtyscore,-1))
          order by a.codempid;


  cursor c1 is
      select a.codempid,dteyreap,a.codcomp,numtime,grdap,qtyadjtot,
             a.codpos,a.jobgrade,a.codaplvl,a.numlvl,
             b.dteempmt,b.codempmt,
             stddec(c.amtincom1,a.codempid,v_chken) amtincom1,
             stddec(c.amtincom2,a.codempid,v_chken) amtincom2,
             stddec(c.amtincom3,a.codempid,v_chken) amtincom3,
             stddec(c.amtincom4,a.codempid,v_chken) amtincom4,
             stddec(c.amtincom5,a.codempid,v_chken) amtincom5,
             stddec(c.amtincom6,a.codempid,v_chken) amtincom6,
             stddec(c.amtincom7,a.codempid,v_chken) amtincom7,
             stddec(c.amtincom8,a.codempid,v_chken) amtincom8,
             stddec(c.amtincom9,a.codempid,v_chken) amtincom9,
             stddec(c.amtincom10,a.codempid,v_chken) amtincom10
        from tappemp a,temploy1 b,temploy3 c
       where a.codempid = b.codempid
         and b.codempid = c.codempid
         and a.codcomp like b_index_codcomp||'%'
         and a.codempid = v_codempid
         and ( ((b_index_grade is not null and b_index_grade <> 'ALL') or b_index_score is not null )
                 and 'Y' = check_grd_continue(a.codempid,b_index_yearst,b_index_yearen,dteyreap,numtime,b_index_grade,b_index_qtygrade,b_index_score,b_index_qtyscore,a.grdap,a.qtyadjtot)

             or
               (b_index_grade = 'ALL' and b_index_score is null
               )
            )
         and dteyreap between b_index_yearst and b_index_yearen
    order by a.codempid,dteyreap,numtime;

  begin

    obj_row := json_object_t();
    for k in c_chkemp loop
    v_codempid := k.codempid;  
    for i in c1 loop

        v_flgfound := true;
        if b_index_syncond is not null then
            v_cond := b_index_syncond;
/* #4505
            v_cond := replace(v_cond,'CODPOS',''''||i.codpos||'''');
            v_cond := replace(v_cond,'JOBGRADE',''''||i.jobgrade||'''');
            v_cond := replace(v_cond,'CODAPLVL',''''||i.codaplvl||'''');
            v_cond := replace(v_cond,'NUMLVL',i.numlvl);
*/
--#4505
            v_cond := replace(v_cond,'TAPPRAIS.CODPOS',''''||i.codpos||'''');
            v_cond := replace(v_cond,'TAPPRAIS.JOBGRADE',''''||i.jobgrade||'''');
            v_cond := replace(v_cond,'TAPPRAIS.CODAPLVL',''''||i.codaplvl||'''');
            v_cond := replace(v_cond,'TAPPRAIS.NUMLVL',i.numlvl);
            v_stmt := 'select count(*) from dual where '||v_cond;
--#4505
            v_flgfound := execute_stmt(v_stmt);
        end if;
        if v_flgfound then
          v_flgdata := 'Y';
          v_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if v_secur then
            v_flgsecur := 'Y';
            v_rcnt := v_rcnt + 1;

            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('image', get_emp_img(i.codempid));
            obj_data.put('codempid', i.codempid);
            obj_data.put('desc_codempid', get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('dteempmt', to_char(i.dteempmt,'dd/mm/yyyy'));
            if v_zupdsal = 'Y' then
                get_wage_income(i.codcomp,i.codempmt,
                                nvl(i.amtincom1,0),nvl(i.amtincom2,0),nvl(i.amtincom3,0),nvl(i.amtincom4,0),nvl(i.amtincom5,0),
                                nvl(i.amtincom6,0),nvl(i.amtincom7,0),nvl(i.amtincom8,0),nvl(i.amtincom9,0),nvl(i.amtincom10,0),
                                v_salhur,v_salday,v_salary);
                obj_data.put('salary', to_char(v_salary,'fm999999999990.00'));
            else
                obj_data.put('salary', '');
            end if;
            obj_data.put('dteyreap', (i.dteyreap /*+ global_v_zyear*/));
            obj_data.put('numtime', i.numtime);
            obj_data.put('qtytot', to_char(i.qtyadjtot,'fm9990.00'));
            obj_data.put('grdap', i.grdap);
            obj_row.put(to_char(v_rcnt-1),obj_data);
          end if;
        end if;
    end loop;--- i

    -----
end loop;--- loop k

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappemp');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  procedure get_dropdown (json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;

    cursor c_1 is
        select grade  from ( select  grade, ROW_NUMBER() OVER (PARTITION BY grade ORDER BY pctwkstr desc) r
          from tstdis
         where codcomp like b_index_codcomp||'%'
           and dteyreap between b_index_yearst and b_index_yearen
     order by pctwkstr desc) t1 where r =1;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    for r1 in c_1 loop
      v_rcnt      := v_rcnt+1;
      obj_data     := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('grade', r1.grade);
      obj_data.put('descgrade', r1.grade);

      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_rcnt = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TSTDIS');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
        v_rcnt      := v_rcnt+1;
        obj_data     := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('grade', 'ALL');
        obj_data.put('descgrade', get_label_name('HRAP4AX1',global_v_lang,200));

        obj_row.put(to_char(v_rcnt-1),obj_data);
        json_str_output := obj_row.to_clob;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/

--------------------------------------------------------
--  DDL for Package Body HRRP32X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP32X" as
  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codcompe    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpose     := hcm_util.get_string_t(json_obj,'p_codpos');

    p_codcompe          := hcm_util.get_string_t(json_obj,'p_codcompe');
    p_codpose           := hcm_util.get_string_t(json_obj,'p_codpose');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec') ,'ddmmyyyy');
    p_gen               := hcm_util.get_string_t(json_obj,'p_gen');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end;

  procedure check_index is
    v_codpos            tpostn.codpos%type;
  begin

    if b_index_codcompe is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcompe);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codpose is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = b_index_codpose;
      exception when no_data_found then
        v_codpos := null;
      end;
      if v_codpos is null then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
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

  procedure  insert_graph (json_str_output in json_object_t) as
     v_col_json            json_object_t;
     v_row_json            json_object_t;
     v_seq                 number := 1;
     v_row                 varchar2(200 char);
     v_qty1              varchar2(200 char);
     v_qty2                 varchar2(200 char);
     v_qty3              varchar2(200 char);
     v_data                varchar2(200 char);
     v_col_desc                varchar2(200 char);
     graph_x_desc          varchar2(200 char);
     graph_y_desc          varchar2(200 char);
     v_desc_codpos          varchar2(200 char);
     v_codpos          varchar2(200 char);

     --<<User37 #7487 1. RP Module 18/01/2022 
     v_desc_codcomp         varchar2(200 char);
     v_codcomp              varchar2(200 char);
     -->>User37 #7487 1. RP Module 18/01/2022 

     type x_col is table of varchar2(100) index by binary_integer;
      a_col x_col;

     begin

     a_col(1) := get_label_name('HRRP32X1',global_v_lang,80);
     a_col(2) := get_label_name('HRRP32X1',global_v_lang,90);
     a_col(3) := get_label_name('HRRP32X1',global_v_lang,100);

           for i in 1..json_str_output.get_size loop
                v_row_json      := hcm_util.get_json_t(json_str_output,i-1);
                v_qty1           := hcm_util.get_string_t(v_row_json, 'qty1');
                v_qty2          := hcm_util.get_string_t(v_row_json, 'qty2');
                v_qty3           := hcm_util.get_string_t(v_row_json, 'qty3');
                v_desc_codpos           := hcm_util.get_string_t(v_row_json, 'desc_codpos');
                v_codpos           := hcm_util.get_string_t(v_row_json, 'codpos');
                --<<User37 #7487 1. RP Module 18/01/2022 
                v_desc_codcomp      := hcm_util.get_string_t(v_row_json, 'desc_codcomp');
                v_codcomp           := hcm_util.get_string_t(v_row_json, 'codcomp');
                -->>User37 #7487 1. RP Module 18/01/2022 


                graph_y_desc    := get_label_name('HRRP32X1','102',70);
                graph_x_desc    := get_label_name('HRRP32X1','102',20);

                for j in 1..a_col.count loop
                  if j = 1 then
                    v_data := v_qty1;
                  elsif j = 2 then
                    v_data := v_qty2;
                  elsif j = 3 then
                    v_data := v_qty3;
                  end if;
                  v_col_desc := a_col(j);

                      INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                      ITEM1,
                      ITEM2,
                      ITEM3,
                      ITEM4,
                      ITEM5,ITEM9,
                      ITEM10,ITEM8,
                      ITEM31,ITEM12,ITEM13,ITEM6)
                      VALUES (global_v_codempid, 'HRRP32X', v_seq,
                      '',
                      '',
                      '',
                      --<<User37 #7487 1. RP Module 18/01/2022 
                      /*v_codpos,
                      v_desc_codpos,graph_y_desc,*/
                      v_codcomp||v_codpos,
                      v_desc_codcomp||':'||v_desc_codpos,graph_y_desc,
                      -->>User37 #7487 1. RP Module 18/01/2022 
                      v_data, v_col_desc,
                      get_label_name('HRRP32X1',global_v_lang,160),
                      '',null,graph_x_desc);
                      v_seq := v_seq + 1;
               end loop;
           end loop;
 end;

  procedure gen_index(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;

    v_cntemp        number := 0;
    v_cntbaby       number := 0;
    v_cntgenx       number := 0;
    v_cntgeny       number := 0;
    v_cntall        number := 0;

    cursor c1 is
      select codcompe, codpose, dteeffec
        from ttalente a
       where codcompe   like b_index_codcompe || '%'
         and codpose    = nvl(b_index_codpose,codpose)
         and dteeffec   = (select max(dteeffec)
                            from ttalente b
                           where b.codcompe = a.codcompe
                             and b.codpose  = a.codpose)
    group by codcompe, codpose, dteeffec
    order by codcompe, codpose, dteeffec;
  begin

      begin
          delete
            from ttemprpt
           where codapp = 'HRRP32X'
             and codempid = global_v_codempid;
      end;

    obj_row := json_object_t();
    commit;
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_secur := secur_main.secur7(r1.codcompe,global_v_coduser);
      if v_secur then
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;

        v_cntbaby := 0;
        v_cntgenx := 0;
        v_cntgeny := 0;
        v_cntall  := 0;
        --Baby Boomer--
        begin
         select count(a.codempid) into v_cntbaby
           from ttalente a, temploy1 b
          where a.codempid   = b.codempid
            and a.codcompe   = r1.codcompe
            and a.codpose    = r1.codpose
            and a.dteeffec   = r1.dteeffec
            and a.staappr    = 'Y'
            and get_generation(b.dteempdb) = '0001'; ----(sysdate - b.dteempdb) + 1 between (50 * 365) and  (60 * 365);
        end;
        --Gen X--
        begin
         select count(a.codempid) into v_cntgenx
           from ttalente a, temploy1 b
          where a.codempid   = b.codempid
            and a.codcompe   = r1.codcompe
            and a.codpose    = r1.codpose
            and a.dteeffec   = r1.dteeffec
            and a.staappr    = 'Y'
            and get_generation(b.dteempdb) = '0002'; ----(sysdate - b.dteempdb) + 1 between (35 * 365) and  (49 * 365);
        end;
        --Gen Y--
        begin
         select count(a.codempid) into v_cntgeny
           from ttalente a, temploy1 b
          where a.codempid   = b.codempid
            and a.codcompe   = r1.codcompe
            and a.codpose    = r1.codpose
            and a.dteeffec   = r1.dteeffec
            and a.staappr    = 'Y'
            and get_generation(b.dteempdb) = '0003'; ----(sysdate - b.dteempdb) + 1 between (14 * 365) and  (34 * 365);
        end;
        v_cntall := v_cntbaby + v_cntgenx + v_cntgeny;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codcomp', r1.codcompe);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcompe,global_v_lang));
        obj_data.put('codpos', r1.codpose);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpose,global_v_lang));
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('qty1', v_cntbaby);
        obj_data.put('qty2', v_cntgenx);
        obj_data.put('qty3', v_cntgeny);
        obj_data.put('sum', v_cntall);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          insert_graph(obj_row);
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttalente');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

  procedure get_index_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    obj_rowmain     json_object_t;

    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	  boolean;
    v_zupdsal   	  varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_dteeffec      ttalente.dteeffec%type;
    v_codcreate     ttalente.codcreate%type;

  begin
    begin
      select dteeffec,codcreate
        into v_dteeffec,v_codcreate
        from ttalente a
--       where codcompe   = nvl(b_index_codcompe,codcompe)
       where codcompe   like b_index_codcompe||'%'
         and codpose    = nvl(b_index_codpose,codpose)
         and dteeffec   = (select max(dteeffec)
                            from ttalente b
--                           where b.codcompe = nvl(b_iDndex_codcompe,codcompe)
                           where b.codcompe   like b_index_codcompe||'%'
                             and b.codpose  = nvl(b_index_codpose,codpose))
         and rownum = 1;
    exception when no_data_found then
      v_dteeffec := null;
      v_codcreate := null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteselect', to_char(v_dteeffec,'dd/mm/yyyy')); ----**
    obj_data.put('selectby', get_codempid(v_codcreate)||' - '||get_temploy_name(get_codempid(v_codcreate),global_v_lang) ); ----**
    obj_data.put('codlist1', '0001');
    obj_data.put('desc_codlist1', get_tcodec_name('tcodgenrt','0001',global_v_lang));
    obj_data.put('codlist2', '0002');
    obj_data.put('desc_codlist2', get_tcodec_name('tcodgenrt','0002',global_v_lang));
    obj_data.put('codlist3', '0003');
    obj_data.put('desc_codlist3', get_tcodec_name('tcodgenrt','0003',global_v_lang));

    json_str_output := obj_data.to_clob;
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    --check_detail;
    gen_detail(json_str_output);

    if param_msg_error is not null then
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean := false;

    v_day           number;
	v_month         number;
	v_year          number;

    cursor c1 is
      --Baby Boomer--
      select a.codempid, a.codcompe, a.codpose, a.jobgrade, b.dteempmt, b.dteempdb ,b.qtywkday ,b.dteeffex, a.dteeffec, a.codcomp
      from  ttalente a, temploy1 b
      where a.codempid   = b.codempid
        and a.codcompe   = p_codcompe
        and a.codpose    = p_codpose
        and a.dteeffec   = p_dteeffec
        and a.staappr    = 'Y'
        and get_generation(b.dteempdb) = '0001' ----(sysdate - b.dteempdb) + 1 between (50 * 365) and  (60 * 365)
        and p_gen = '0001'
      union all
      --Gen X--
      select a.codempid, a.codcompe, a.codpose, a.jobgrade, b.dteempmt, b.dteempdb ,b.qtywkday ,b.dteeffex, a.dteeffec, a.codcomp
      from  ttalente a, temploy1 b
      where a.codempid   = b.codempid
        and a.codcompe   = p_codcompe
        and a.codpose    = p_codpose
        and a.dteeffec   = p_dteeffec
        and a.staappr    = 'Y'
        and get_generation(b.dteempdb) = '0002' ----(sysdate - b.dteempdb) + 1 between (35 * 365) and  (49 * 365)
        and p_gen = '0002'
      union all
      --Gen Y--
      select a.codempid, a.codcompe, a.codpose, a.jobgrade, b.dteempmt, b.dteempdb ,b.qtywkday ,b.dteeffex, a.dteeffec, a.codcomp
      from  ttalente a, temploy1 b
      where a.codempid   = b.codempid
        and a.codcompe   = p_codcompe
        and a.codpose    = p_codpose
        and a.dteeffec   = p_dteeffec
        and a.staappr    = 'Y'
        and get_generation(b.dteempdb) = '0003' ----(sysdate - b.dteempdb) + 1 between (14 * 365) and  (34 * 365)
        and p_gen = '0003'
      union all
      --All Gen--
      select a.codempid, a.codcompe, a.codpose, a.jobgrade, b.dteempmt, b.dteempdb ,b.qtywkday ,b.dteeffex, a.dteeffec, a.codcomp
      from  ttalente a, temploy1 b
      where a.codempid   = b.codempid
        and a.codcompe   = p_codcompe
        and a.codpose    = p_codpose
        and a.dteeffec   = p_dteeffec
        and a.staappr    = 'Y'
        ----and (sysdate - b.dteempdb) + 1 between (14 * 365) and  (60 * 365) --14 to 60 years old.
        and p_gen = 'ALL'
    order by 1;

  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      v_flgdata := 'Y';
      v_secur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_flgsecur := 'Y';
        v_rcnt := v_rcnt + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcompe,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpose,global_v_lang));
        obj_data.put('jobgrad', get_tcodec_name('TCODJOBG',r1.jobgrade,global_v_lang));
        get_service_year(r1.dteempmt + nvl(r1.qtywkday,0),nvl(r1.dteeffex,sysdate),'Y',v_year,v_month,v_day);
        obj_data.put('agework', to_char(v_year)||'('||to_char(v_month)||')');
        get_service_year(r1.dteempdb,sysdate,'Y',v_year,v_month,v_day);
        obj_data.put('age', to_char(v_year)||'('||to_char(v_month)||')');
        obj_data.put('dteeffec', to_char(r1.dteeffec,'dd/mm/yyyy'));
        obj_data.put('codcomp', r1.codcomp);
        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    if v_flgdata = 'Y' then
        if v_flgsecur = 'Y' then
          json_str_output := obj_row.to_clob;
        else
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttalente');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  end;

end;

/

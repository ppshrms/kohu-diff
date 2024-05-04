--------------------------------------------------------
--  DDL for Package Body HRAP3WE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3WE" is

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_dteyreap          := hcm_util.get_string_t(json_obj,'p_dteyreap');
    p_numtime           := hcm_util.get_string_t(json_obj,'p_numtime');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
--    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'), 'ddmmyyyy');

    p_flgimport         := hcm_util.get_string_t(json_obj,'flgimport');

    p_table             := hcm_util.get_json_t(json_obj,'p_table');
    p_params            := hcm_util.get_json_t(json_obj,'p_params');
    p_dteupd            := to_date(hcm_util.get_string_t(json_obj,'p_dteupd'), 'dd/mm/yyyy');
    p_coduser           := hcm_util.get_string_t(json_obj,'p_codadj');
    p_score             := hcm_util.get_string_t(json_obj,'p_score');
   hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure check_index is
    v_count_comp  number := 0;
    v_secur  boolean := false;
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
      return;
    else
      begin
            select count(*) into v_count_comp
            from tcenter
            where codcomp like p_codcomp || '%' ;
        exception when others then null;
        end;
        if v_count_comp < 1 then
             param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
             return;
        end if;
         v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
          if not v_secur then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
    end if;


  end;

  procedure gen_index(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;
    v_flggrade          varchar2(2 char);
    v_max_dteadj        tappemp.dteadj%type := sysdate;
    v_max_codadj        tappemp.codadj%type := global_v_codempid;

    cursor c1 is
      select codempid,codpos,qtyta,qtypuns,qtybeh3,qtycmp3,qtykpie3,qtytotnet,qtytot3,
             grdap,grdadj,dteupd,coduser,codcreate,dteadj,codadj
        from tappemp
       where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codcomp  like p_codcomp || '%'
         and flgappr  = 'C'
         order by codempid;


    begin
        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

            for r1 in c1 loop
              v_count := v_count +1;

               v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
              if v_flgsecu then
                v_chksecu := true;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('score1',(nvl(r1.qtyta,0)+nvl(r1.qtypuns,0)));
                obj_data.put('score2',r1.qtybeh3);
                obj_data.put('score3',r1.qtycmp3);
                obj_data.put('score4',r1.qtykpie3);
                obj_data.put('total',r1.qtytot3);
                obj_data.put('gradeo',r1.grdap);
                obj_data.put('graden',r1.grdadj);
                obj_data.put('scorenew',r1.qtytotnet);
                obj_data.put('dteupd',to_char(r1.dteadj, 'dd/mm/yyyy'));
                obj_data.put('desc_coduser',get_temploy_name(r1.codadj,global_v_lang));
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
                if r1.dteadj is not null then
                    if (trunc(v_max_dteadj) <> trunc(sysdate) and r1.dteadj > v_max_dteadj) or trunc(v_max_dteadj) = trunc(sysdate) then
                        v_max_dteadj := r1.dteadj;
                        v_max_codadj := r1.codadj;
                    end if;
                end if;
--                if (r1.dteadj > v_max_dteadj) then
--                    v_max_dteadj := r1.dteadj;
--                    v_max_codadj := r1.codadj;
--                end if;
                end if;
            end loop;

        exception when others then null;
        end;

        begin
          select flggrade into v_flggrade
            from tapbudgt
           where codcomp  = p_codcomp
             and dteyreap = (
                        select max(dteyreap)
                         from tapbudgt
                        where codcomp = p_codcomp                   
                          and dteyreap <= p_dteyreap
                    );
        exception when others then
          v_flggrade := 'N';
        end;

        if v_flggrade = '2' then
          v_flggrade := 'Y';
        else
          v_flggrade := 'N';
        end if;

          obj_result.put('coderror', '200');
          if v_max_dteadj is null then
              obj_result.put('dteupd', to_char(sysdate,'dd/mm/yyyy'));
              obj_result.put('coduser', global_v_codempid);
          else
              obj_result.put('dteupd', to_char(v_max_dteadj,'dd/mm/yyyy'));
              obj_result.put('coduser', v_max_codadj);
          end if;
          obj_result.put('flggrade', v_flggrade);
          obj_result.put('table', obj_row);
        if v_count = 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tappemp');
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        elsif not v_chksecu  then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;

        json_str_output := obj_result.to_clob;
  end gen_index;

  procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure  insert_graph (json_str_output in json_object_t) as
     v_col_json            json_object_t;
     v_row_json            json_object_t;
     v_seq                 number := 1;
     v_row                 varchar2(200 char);
     v_grade              varchar2(200 char);
     v_qtyres                 varchar2(200 char);
     v_qtyin              varchar2(200 char);
     v_data                varchar2(200 char);
     v_col_desc                varchar2(200 char);
     graph_x_desc          varchar2(200 char);
     graph_y_desc          varchar2(200 char);

     type x_col is table of varchar2(100) index by binary_integer;
      a_col x_col;

     begin

     a_col(1) := get_label_name('HRAP3WE2',global_v_lang,60);
     a_col(2) := get_label_name('HRAP3WE2',global_v_lang,70);

           for i in 1..json_str_output.get_size loop
                v_row_json      := hcm_util.get_json_t(json_str_output,i-1);
                v_grade           := hcm_util.get_string_t(v_row_json, 'grade');
                v_qtyin          := hcm_util.get_string_t(v_row_json, 'qtyin');
                v_qtyres           := hcm_util.get_string_t(v_row_json, 'qtyres');


                graph_y_desc    := get_label_name('HRAP3WE2','102',70);

                for j in 1..a_col.count loop
                  if j = 1 then
                    v_data := v_qtyin;
                  else
                    v_data := v_qtyres;
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
                      VALUES (global_v_codempid, 'HRAP3WE', v_seq,
                      '',
                      '',
                      '',
                      v_grade,
                      v_grade,graph_y_desc,
                      v_data, v_col_desc,
                      get_label_name('HRAP3WE2',global_v_lang,10),
                      '',null,graph_x_desc);
                      v_seq := v_seq + 1;
               end loop;
           end loop;
 end;

  procedure gen_popup(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result            json_object_t;
    v_row               number := 0;
    v_all_emp           number := 0;
    v_array             number := 0;
    v_sum_per           number := 0;
    type grade is table of varchar2(2 ) index by binary_integer;
      a_grade grade;
    type grade2 is table of varchar2(10 ) index by binary_integer;
      v_grade grade2;

    cursor c1 is
      select grade,pctemp
        from tstdis
       where codcomp  like p_codcomp || '%'
         and dteyreap = (
                        select max(dteyreap)
                        from tstdis
                        where codcomp like p_codcomp || '%'
                          and dteyreap <= p_dteyreap
                    )
        order by grade ;

      cursor c2 is
      select grdap,count(grdap) count_grdap
        from tappemp
      where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codcomp  like p_codcomp || '%'
         and flgappr  = 'C'
         group by grdap
         order by grdap
       ;


    begin
        begin
          delete
            from ttemprpt
           where codapp = 'HRAP3WE'
             and codempid = global_v_codempid;
        end;

        for r2 in c2 loop
          v_array := v_array + 1;
          a_grade(v_array) := r2.grdap;
          v_grade(v_array) := r2.count_grdap;
          v_all_emp := v_all_emp + r2.count_grdap;
        end loop;

        obj_result := json_object_t;
        obj_row := json_object_t();

        begin

            for r1 in c1 loop
              obj_data := json_object_t();
              obj_data.put('coderror','200');

              for i in 1..a_grade.count loop

                if a_grade(i) = r1.grade then
                  obj_data.put('grade',r1.grade);
                  obj_data.put('qtyin',(r1.pctemp * v_all_emp));
                  obj_data.put('qtyres',v_grade(i));
                  obj_data.put('percent',to_char((v_grade(i)/v_all_emp)*100,'9999999999990.00'));
                  v_sum_per   := v_sum_per + to_number(to_char((v_grade(i)/v_all_emp)*100,'9999999999990.00'));
                  if v_sum_per <> 100 and i = a_grade.count then
                    obj_data.put('percent',to_number(to_char((v_grade(i)/v_all_emp)*100,'9999999999990.00')) + (100 - v_sum_per));
                  end if;
                  obj_row.put(to_char(v_row), obj_data);
                  v_row        := v_row + 1;

                end if;
              end loop;
            end loop;

        exception when others then
         null;
        end;
        insert_graph(obj_row);
        json_str_output := obj_row.to_clob;
  end;

  procedure get_popup (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then

            gen_popup(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_process(json_str_input in clob,json_str_output out clob) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    v_error_remark   varchar2(4000);
    obj_data         json_object_t;
    obj_row          json_object_t;
    obj_result       json_object_t;
    json_result      json_object_t;
    v_rcnt           number  := 0;
    v_codcomp        temploy1.codcomp%type;
    v_codempid       tappemp.codempid%type;
    v_grdadj         tappemp.grdadj%type;
    v_qtyadjtot      tappemp.qtyadjtot%type;
    v_column	     number := 3;
    v_error		     boolean;
    v_err_code  	 varchar2(1000 char);
    v_err_field  	 varchar2(1000 char);
    v_err_table		 varchar2(20 char);
    v_flgfound  	 boolean;
    v_cnt			 number := 0;
    v_num            number := 0;
    v_rec_tran            number := 0;
    v_rec_error            number := 0;
    v_concat         varchar2(10 char);
    data_file 		   varchar2(6000 char);


    type text is table of varchar2(1000 char) index by binary_integer;
      v_text   text;
      v_field  text;
      v_key    text;

  begin
    obj_row := json_object_t();
    for i in 1..v_column loop
      v_field(i) := null;
      v_key(i)   := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    p_dteyreap   := hcm_util.get_string_t(param_json, 'p_year');
    p_numtime    := hcm_util.get_string_t(param_json, 'p_numperiod');
    p_dteupd    := to_date(hcm_util.get_string_t(param_json, 'p_dteupd'), 'dd/mm/yyyy');
    p_coduser    := hcm_util.get_string_t(param_json, 'p_coduser');

    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_field(v_num)    := hcm_util.get_string_t(param_column_row,'name');
      v_key(v_num)      := hcm_util.get_string_t(param_column_row,'key');
    end loop;

    for rw in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(rw));
      begin
        v_err_code  := null;
        v_err_field := null;
        v_err_table := null;
        v_error 	  := false;
        --
        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,v_key(1));  -- codempid
          v_text(2)   := hcm_util.get_string_t(param_json_row,v_key(2));  -- grdadj
          v_text(3)   := hcm_util.get_string_t(param_json_row,v_key(3));  -- qtyadjtot

          -- push row values
          data_file := null;
          v_concat := null;
          for i in 1..v_column loop
            data_file := data_file||v_concat||v_text(i);
            v_concat  := '|';
          end loop;

          -- check null
          if v_text(1) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(1);
            exit cal_loop;
          end if;

          --1.codempid
          if v_text(1) is not null then
            begin
              select codempid into v_codempid
              from tappemp
              where codempid = v_text(1)
              and numtime = p_numtime
              and dteyreap = p_dteyreap
              and flgappr = 'C';
            exception when others then
              v_error     := true;
              v_err_code  := 'HR2055';
              v_err_table := 'tappemp';
              v_err_field := v_field(1);
              exit cal_loop;
            end;
          end if;

          begin
            select codcomp into v_codcomp
              from temploy1
             where codempid = v_text(1);
          exception when others then
            v_codcomp := null;
          end;
          --2.grdadj
          if v_text(2) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(2);
            exit cal_loop;
          end if;
          if v_text(3) is null then
            v_error	 	  := true;
            v_err_code  := 'HR2045';
            v_err_field := v_field(3);
            exit cal_loop;
          end if;

          if v_text(2) is not null and v_text(3) is not null then
            begin
              select grade into v_grdadj
              from tstdis
              where codcomp like hcm_util.get_codcomp_level(v_codcomp,1) || '%'
              and grade = v_text(2)
              and dteyreap = (
                        select max(dteyreap)
                         from tstdis
                        where codcomp like hcm_util.get_codcomp_level(v_codcomp,1) || '%'
                          and dteyreap <= p_dteyreap
                          and grade = v_text(2)
                    )
              and v_text(3) between pctwkstr and pctwkend;
            exception when others then
              v_error     := true;
              v_err_code  := 'HR2023' ;
              v_err_table := 'TSTDIS';
              v_err_field := v_field(2);
              exit cal_loop;
            end;

            exit cal_loop;
          end if;


          --3.qtyadjtot
          if v_text(3) < 0 then
            v_error     := true;
            v_err_code  := 'HR2020' ;
            v_err_table := 'TSTDIS';
            v_err_field := v_field(3);
            exit cal_loop;
          end if;
          if v_text(3) > 100 then
            v_error     := true;
            v_err_code  := 'HR6591' ;
            v_err_table := 'TSTDIS';
            v_err_field := v_field(3);
            exit cal_loop;
          end if;


          exit cal_loop;
        end loop; -- cal_loop

        -- update status
        if not v_error then
          v_rec_tran := v_rec_tran + 1;
          begin
            update tappemp
              set codadj        = p_coduser,
                  dteadj        = p_dteupd,
                  grdadj        = v_text(2),
                  grdap         = v_text(2),
                  qtyadjtot     = v_text(3),
                  qtytotnet     = v_text(3)
              where codempid    = v_text(1)
              and numtime = p_numtime
              and dteyreap = p_dteyreap;
          exception when others then
            null;
          end;
        else
          v_rec_error     := v_rec_error + 1;
          v_cnt           := v_cnt+1;
          obj_data   := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('numseq', v_cnt);
          obj_data.put('error_code', replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null));
          obj_data.put('text', data_file);
          obj_row.put(to_char(v_cnt-1),obj_data);
        end if;--not v_error

      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
          json_result       := json_object_t(get_response_message(null, get_error_msg_php('HR2715', global_v_lang), global_v_lang));
          obj_data   := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('rec_tran', v_rec_tran);
          obj_data.put('rec_err', v_rec_error);
          obj_data.put('response', hcm_util.get_string_t(json_result, 'response'));

          obj_result := json_object_t();
          obj_result.put('details', obj_data);
          obj_result.put('table', obj_row);
    json_str_output := obj_result.to_clob;
  end;

  procedure post_process (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    save_process(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save_index (i_grdadj in varchar2, i_qtyadjtot in varchar2, i_codempid in varchar2) is
   p_temp               varchar2(100 char);
   v_secur              boolean := false;
   tstdis_codcomp       tstdis.codcomp%type;
   tstdis_dteyreap      tstdis.dteyreap%type;
  begin
    begin
        select codcomp, dteyreap
          into tstdis_codcomp, tstdis_dteyreap
          from tstdis
         where p_codcomp like codcomp || '%'
           and dteyreap <= p_dteyreap
           and rownum = 1
         order by codcomp desc, dteyreap desc;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tstdis');
        return;
    end;


--    begin
--        select grade
--          into v_grade
--          from tstdis
--         where codcomp  = tstdis_codcomp
--           and dteyreap = tstdis_dteyreap
--             and p_score between pctwkstr and pctwkend ;
--    exception when no_data_found then
--        v_grade := null;
--    end;


    if i_grdadj is not null then
      begin
--        select grade
--          into p_temp
--          from tstdis
--       where codcomp  like p_codcomp || '%'
--         and grade = i_grdadj
--         and dteyreap = (
--                        select max(dteyreap)
--                        from tstdis
--                        where codcomp like p_codcomp || '%'
--                          and dteyreap <= p_dteyreap
--                          and grade = i_grdadj
--                    )
--         and rownum = 1
--      order by codcomp desc ;
        select grade
          into p_temp
          from tstdis
         where codcomp  = tstdis_codcomp
           and grade = i_grdadj
           and dteyreap = tstdis_dteyreap;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tstdis');
        return;
      end;
    end if;

    if i_qtyadjtot is not null then
      begin
          select grade into p_temp
          from tstdis
          where codcomp = tstdis_codcomp
          and grade = i_grdadj
          and dteyreap = tstdis_dteyreap
          and i_qtyadjtot between pctwkstr and pctwkend;

--          select grade into p_temp
--          from tstdis
--          where codcomp like hcm_util.get_codcomp_level(p_codcomp,1) || '%'
--          and grade = i_grdadj
--          and dteyreap = (
--                    select max(dteyreap)
--                     from tstdis
--                    where codcomp like hcm_util.get_codcomp_level(p_codcomp,1) || '%'
--                      and dteyreap <= p_dteyreap
--                      and grade = i_grdadj
--                )
--          and i_qtyadjtot between pctwkstr and pctwkend;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tstdis');
        return;
      end;
    end if;

    if i_codempid is not null then
--      begin
--         select staemp into p_temp
--         from temploy1
--         where codempid = i_codempid;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
--        return;
--      end;
--
--      if p_temp = 9 then
--         param_msg_error := get_error_msg_php('HR2101',global_v_lang);
--         return;
--      elsif p_temp = 0 then
--         param_msg_error := get_error_msg_php('HR2102',global_v_lang);
--         return;
--      end if;
         v_secur := secur_main.secur2(i_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
           if not v_secur  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
    end if;
  end;


  procedure save_index(json_str_input in clob,json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    param_json2      json_object_t;
    v_flg           boolean;
    v_numseq        varchar2(100 char);
    v_codempid      tappemp.codempid%type;
    v_qtyadjtot      tappemp.codempid%type;
    v_grdadj      tappemp.grdadj%type;
  begin

    param_json2 := hcm_util.get_json_t(json_object_t(json_str_input),'p_table');
    param_json := hcm_util.get_json_t(json_object_t(param_json2),'rows');

    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        v_flg           := hcm_util.get_boolean_t(param_json_row,'flgEdit');
        v_grdadj        := hcm_util.get_string_t(param_json_row,'graden');
        v_qtyadjtot     := hcm_util.get_string_t(param_json_row,'scorenew');
        v_codempid      := hcm_util.get_string_t(param_json_row,'codempid');

        if v_flg  then
           check_save_index (v_grdadj, v_qtyadjtot, v_codempid);
           if param_msg_error is null then
              begin
                update tappemp
                  set codadj        = p_coduser,
                      dteadj        = p_dteupd,
                      grdadj        = v_grdadj,
                      grdap         = v_grdadj,
                      qtyadjtot     = v_qtyadjtot,
                      qtytotnet     = v_qtyadjtot
                  where codempid = v_codempid
                  and numtime = p_numtime
                  and dteyreap = p_dteyreap;
              exception when others then
                null;
              end;
            else
              exit;
            end if;
          end if;
      end loop;
     end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    end if;
  end save_index;

  procedure post_save_index(json_str_input in clob,json_str_output out clob) as
  v_staemp    temploy1.staemp%type;
  begin
    initial_value(json_str_input);
      begin
         select staemp into v_staemp
         from temploy1
         where codempid = p_coduser;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;

      if v_staemp = 9 then
         param_msg_error := get_error_msg_php('HR2101',global_v_lang);
      elsif v_staemp = 0 then
         param_msg_error := get_error_msg_php('HR2102',global_v_lang);
      end if;

    if param_msg_error is null then
      save_index(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_grade(json_str_output out clob) is
    obj_result            json_object_t;
    v_grade             tstdis.grade%type;
    tstdis_codcomp      tstdis.codcomp%type;
    tstdis_dteyreap     tstdis.dteyreap%type;
  begin
    obj_result := json_object_t;

    select codcomp, dteyreap
      into tstdis_codcomp, tstdis_dteyreap
      from tstdis
     where p_codcomp like codcomp || '%'
       and dteyreap <= p_dteyreap
       and rownum = 1
     order by codcomp desc, dteyreap desc;

    begin
        select grade
          into v_grade
          from tstdis
         where codcomp  = tstdis_codcomp
           and dteyreap = tstdis_dteyreap
             and p_score between pctwkstr and pctwkend ;
    exception when no_data_found then
        v_grade := null;
    end;

    obj_result.put('coderror', '200');
    obj_result.put('graden', v_grade);
    json_str_output := obj_result.to_clob;
  end;

  procedure get_grade (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then

            gen_grade(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end hrap3we;

/

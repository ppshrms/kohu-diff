--------------------------------------------------------
--  DDL for Package Body HRAP33E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP33E" is

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
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_flgconfemp        := hcm_util.get_string_t(json_obj,'p_flgconfemp');
    p_dteconfemp        := to_date(hcm_util.get_string_t(json_obj,'p_dteconfemp'), 'ddmmyyyy');
    p_flgconfhd         := hcm_util.get_string_t(json_obj,'p_flgconfhd');
    p_dteconfhd         := to_date(hcm_util.get_string_t(json_obj,'p_dteconfhd'), 'ddmmyyyy');
    p_flgconflhd        := hcm_util.get_string_t(json_obj,'p_flgconflhd');
    p_dteconflhd        := to_date(hcm_util.get_string_t(json_obj,'p_dteconflhd'), 'ddmmyyyy');

    p_dtest               := to_date(hcm_util.get_string_t(json_obj,'dtest'), 'dd/mm/yyyy'); --<< user25 Date : 16/09/2021 3. AP Module #4302
    p_dteen               := to_date(hcm_util.get_string_t(json_obj,'dteen'), 'dd/mm/yyyy'); --<< user25 Date : 16/09/2021 3. AP Module #4302

    p_table               := hcm_util.get_json_t(json_obj,'p_table');
    p_params               := hcm_util.get_json_t(json_obj,'p_params');
    p_dteupd               := to_date(hcm_util.get_string_t(json_obj,'p_dteupd'), 'dd/mm/yyyy');
    p_coduser               := hcm_util.get_string_t(json_obj,'p_codadj');
   hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end;

  procedure convert_month_to_year_month(in_month in number, out_year out number, out_month out number)as
  begin
    out_year := (in_month/12);
    out_year := FLOOR(out_year);
    out_month := in_month - (out_year *12) ;
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
    v_dteapend          date;
    t_taplvl            taplvl%rowtype;

    cursor c1 is
    /*--<< user25 Date : 16/09/2021 3. AP Module #4302
      select codempid,codpos,qtyta,qtypuns,qtybeh3,qtycmp3,qtykpie3,qtytot3,
             grdap,grdadj,dteupd,coduser,codcreate,dteadj,codadj,flgsal,flgbonus,pctdbon,pctdsal
        from tappemp
       where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codcomp  like p_codcomp || '%'
         and flgappr  = 'C';
     */

   select a.codempid,a.codpos,a.qtyta,a.qtypuns,a.qtybeh3,a.qtycmp3,a.qtykpie3,a.qtytot3,
             a.grdap,a.grdadj,a.dteupd,a.coduser,a.codcreate,a.dteadj,a.codadj,a.flgsal,a.flgbonus,a.pctdbon,a.pctdsal,
             a.codcomp,a.codaplvl,a.qtykpic,a.qtykpid
        from tappemp a
       where a.dteyreap = p_dteyreap
         and a.numtime  = p_numtime
         and a.codcomp  like p_codcomp || '%'
         and a.flgappr  = 'C'
         and ((p_dtest is not null and a.codempid in  (  select b.codempid
                                                        from  tappfm b
                                                        where b.dteyreap = p_dteyreap
                                                        and  b.numtime  = p_numtime
                                                        and b.codcomp  like p_codcomp || '%'
                                                        and nvl(b.dteapman,to_date('01/01/0001','dd/mm/yyyy')) between nvl(p_dtest,nvl(b.dteapman,to_date('01/01/0001','dd/mm/yyyy')))
                                                                                                                and     nvl(p_dteen,nvl(b.dteapman,to_date('31/12/9999','dd/mm/yyyy')))
                                                        )
                                            ) or  p_dtest is  null )
         order by a.codempid;
        -->> user25 Date : 16/09/2021 3. AP Module #4302

        begin
            obj_result := json_object_t;
            obj_row := json_object_t();

            begin
                for r1 in c1 loop
                  v_count := v_count +1;
                  v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
                  if v_flgsecu then

                    begin
                        select dteapend
                          into v_dteapend
                          from tstdisd
                         where codcomp = hcm_util.get_codcomp_level(r1.codcomp,1)
                           and dteyreap = p_dteyreap
                           and numtime = p_numtime
                           and codaplvl = r1.codaplvl;
                    exception when no_data_found then
                        v_dteapend := null;
                    end; 

                    v_global_dteapend := v_dteapend;
                    get_taplvl_where(r1.codcomp,r1.codaplvl,v_taplvl_codcomp,v_taplvl_dteeffec);

                    select *
                      into t_taplvl
                      from taplvl
                     where codcomp = v_taplvl_codcomp
                       and codaplvl = r1.codaplvl
                       and dteeffec = v_taplvl_dteeffec;    

                v_chksecu := true;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('image',get_emp_img(r1.codempid));
                obj_data.put('codempid',r1.codempid);
                obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
                obj_data.put('codpos',r1.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(r1.codpos,global_v_lang));
                obj_data.put('qtytapuns',((nvl(r1.qtyta,0) * nvl(t_taplvl.pctta,0)) /100) + ((nvl(r1.qtypuns,0) * nvl(t_taplvl.pctpunsh,0)) /100));
                obj_data.put('qtybeh',(nvl(r1.qtybeh3,0) * nvl(t_taplvl.pctbeh,0)) / 100);
                obj_data.put('qtycmp',(nvl(r1.qtycmp3,0) * nvl(t_taplvl.pctcmp,0)) /100);
                obj_data.put('qtykpi',((nvl(r1.qtykpic,0) * nvl(t_taplvl.pctkpirt,0)) /100) +  ((nvl(r1.qtykpid,0) * nvl(t_taplvl.pctkpicp,0)) /100) + ((nvl(r1.qtykpie3,0) * nvl(t_taplvl.pctkpiem,0)) / 100));
                obj_data.put('amount',r1.qtytot3);
                obj_data.put('grade',r1.grdap);
                obj_data.put('flgupsal',r1.flgsal);
                obj_data.put('pctdsal',r1.pctdsal);
                if r1.flgsal = 'Y' then
                  obj_data.put('html_flgupsal','<div class="badge-custom _bg-green"><i class="fa fa-check-circle"></i>Yes</div>');
                else
                  obj_data.put('html_flgupsal','<div class="badge-custom _bg-red"><i class="fa fa-times-circle"></i>No</div>');
                end if;
                obj_data.put('flgbonus',r1.flgbonus);
                obj_data.put('pctdbon',r1.pctdbon);
                if r1.flgbonus = 'Y' then
                  obj_data.put('html_flgbonus','<div class="badge-custom _bg-green"><i class="fa fa-check-circle"></i>Yes</div>');
                else
                  obj_data.put('html_flgbonus','<div class="badge-custom _bg-red"><i class="fa fa-times-circle"></i>No</div>');
                end if;
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;
                end if;
            end loop;

        exception when others then null;
        end;

        begin
          select flggrade into v_flggrade
            from tapbudgt
           where codcomp  like p_codcomp || '%'
             and dteyreap = (
                        select max(dteyreap)
                         from tapbudgt
                        where codcomp like p_codcomp || '%'
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


        if v_count = 0 then
          param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tappemp');
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        elsif not v_chksecu  then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('403',param_msg_error,global_v_lang);
          return;
        end if;

        json_str_output := obj_row.to_clob;
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

     a_col(1) := get_label_name('hrap33e2',global_v_lang,60);
     a_col(2) := get_label_name('hrap33e2',global_v_lang,70);

           for i in 1..json_str_output.get_size loop
                v_row_json      := hcm_util.get_json_t(json_str_output,i-1);
                v_grade           := hcm_util.get_string_t(v_row_json, 'grade');
                v_qtyin          := hcm_util.get_string_t(v_row_json, 'qtyin');
                v_qtyres           := hcm_util.get_string_t(v_row_json, 'qtyres');


                graph_y_desc    := get_label_name('hrap33e2','102',70);

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
                      VALUES (global_v_codempid, 'hrap33e', v_seq,
                      '',
                      '',
                      '',
                      v_grade,
                      v_grade,graph_y_desc,
                      v_data, v_col_desc,
                      get_label_name('hrap33e2',global_v_lang,10),
                      '',null,graph_x_desc);
                      v_seq := v_seq + 1;
               end loop;
           end loop;
 end;

  procedure gen_detail_header(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result            json_object_t;
    v_row               number := 0;
    v_all_emp           number := 0;
    v_array             number := 0;
    v_sum_per           number := 0;
    v_qtywork           number := 0;
    v_codapman          temploy1.codempid%type;
    v_codapman_a        temploy1.codempid%type;
    v_year              number:=0;
    v_month             number:=0;

    cursor c1 is
      select dteapstr,dteapend
        from tstdisd
       where codcomp  like p_codcomp || '%'
--       and dteyreap <=
         and dteyreap = (select max(dteyreap)
                           from tstdisd
                          where codcomp like p_codcomp || '%'
                            and dteyreap <= p_dteyreap
                            and numtime = p_numtime)
          and numtime = p_numtime;

      cursor c2 is
      select codcomp,codpos,flgsal,flgbonus,pctdbon,pctdsal
        from tappemp
      where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codempid  = p_codempid;

      cursor c3 is
      select codapman,codposap,codcompap
        from tappfm
      where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codempid  = p_codempid
         and flgapman = '2'
         and numseq = ( select max(numseq)
                          from tappfm
                         where dteyreap = p_dteyreap
                            and numtime = p_numtime
                           and codempid = p_codempid
                           and flgapman = '2')
            ;

          cursor c4 is
          select codapman,codposap,codcompap
            from tappfm
          where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codempid  = p_codempid
             and flgapman = '3'
             and numseq = ( select max(numseq)
                              from tappfm
                             where dteyreap = p_dteyreap
                                and numtime = p_numtime
                               and codempid = p_codempid
                               and flgapman = '3')
                ;

    begin

        obj_result := json_object_t;
        obj_row := json_object_t();

        begin
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            for r1 in c1 loop
              obj_data.put('dteapstr',to_char(r1.dteapstr,'dd/mm/yyyy'));
              obj_data.put('dteapend',to_char(r1.dteapend,'dd/mm/yyyy'));
             end loop;
             for r2 in c2 loop
              obj_data.put('codcomp',r2.codcomp);
              obj_data.put('codpos',r2.codpos);
              obj_data.put('desc_codpos',get_tpostn_name(r2.codpos,global_v_lang));
              obj_data.put('pctupsalbrkn',r2.pctdsal);
             end loop;
             for r3 in c3 loop
              v_codapman := r3.codapman;
              if v_codapman is null then
                begin
                  select codempid
                    into v_codapman
                  from temploy1
                  where codpos = r3.codposap
                    and codcomp = r3.codcompap
                    and rownum = 1;
                end;
              end if;
--              obj_data.put('codsuprvisr',get_temploy_name(v_codapman,global_v_lang));
              obj_data.put('codsuprvisr',v_codapman);
             end loop;

             for r4 in c4 loop
              v_codapman := r4.codapman;
              if v_codapman is null then
                begin
                  select codempid
                    into v_codapman
                  from temploy1
                  where codpos = r4.codposap
                    and codcomp = r4.codcompap
                    and rownum = 1;
                end;
              end if;
--              obj_data.put('codappr',get_temploy_name(v_codapman_a,global_v_lang));
              obj_data.put('codappr',v_codapman);
             end loop;

              begin
                  select qtywork
                    into v_qtywork
                  from v_temploy
                  where codempid = p_codempid;
              end;
              convert_month_to_year_month(v_qtywork,v_year,v_month);

            obj_data.put('agewrkyr',v_year);
            obj_data.put('agewrkmth',v_month);
        exception when others then
         null;
        end;

        json_str_output := obj_data.to_clob;
  end;

  procedure get_detail_header (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_header(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;
    v_flggrade          varchar2(2 char);
    v_codform           tappemp.codform%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_pctbeh            taplvl.pctbeh%type;
    v_pctcmp            taplvl.pctcmp%type;
    v_pctkpiem          taplvl.pctkpiem%type;
    v_pctkpicp          taplvl.pctkpicp%type;
    v_pctkpirt          taplvl.pctkpirt%type;

    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_qtybeh            tappemp.qtybeh%type;
    v_qtybeh2           tappemp.qtybeh2%type;
    v_qtybeh3           tappemp.qtybeh3%type;
    v_qtycmp            tappemp.qtycmp%type;
    v_qtycmp2           tappemp.qtycmp2%type;
    v_qtycmp3           tappemp.qtycmp3%type;
    v_qtykpie           tappemp.qtykpie%type;
    v_qtykpie2          tappemp.qtykpie2%type;
    v_qtykpie3          tappemp.qtykpie3%type;
    v_qtykpic           tappemp.qtykpic%type;
    v_qtykpid           tappemp.qtykpid%type;

    begin
        begin
          select codform, qtyta, qtypuns, qtybeh, qtybeh2, qtybeh3,
                 qtycmp, qtycmp2, qtycmp3, qtykpie, qtykpie2, qtykpie3,
                 qtykpic,qtykpid
            into v_codform,v_qtyta,v_qtypuns, v_qtybeh, v_qtybeh2, v_qtybeh3,
                 v_qtycmp, v_qtycmp2, v_qtycmp3, v_qtykpie, v_qtykpie2, v_qtykpie3,
                 v_qtykpic,v_qtykpid
            from tappemp
          where dteyreap = p_dteyreap
             and numtime  = p_numtime
             and codempid  = p_codempid;
        exception when no_data_found then
          v_codform  := null;
          v_qtyta  := null;
          v_qtypuns := null;
          v_qtybeh  := null;
          v_qtybeh2  := null;
          v_qtybeh3  := null;
          v_qtycmp  := null;
          v_qtycmp2  := null;
          v_qtycmp3  := null;
          v_qtykpie  := null;
          v_qtykpie2  := null;
          v_qtykpie3  := null;
        end;

       begin
          select pctta,pctpunsh,pctbeh,pctcmp,pctkpiem,pctkpicp,pctkpirt
          into v_pctta,v_pctpunsh,v_pctbeh,v_pctcmp,v_pctkpiem,v_pctkpicp,v_pctkpirt
          from taplvl
          where p_codcomp like codcomp|| '%'
            and codform = v_codform
            and dteeffec = (select max(dteeffec)
                              from taplvl
                             where p_codcomp like codcomp|| '%'
                               and codform = v_codform
                               and dteeffec <= (select dteapend
                                                  from tstdisd
                                                 where p_codcomp like codcomp|| '%'
                                                   and dteyreap = p_dteyreap
                                                   and numtime = p_numtime
--#5552
                                                   and exists(select codaplvl
                                                              from tempaplvl
                                                             where dteyreap = p_dteyreap
                                                               and numseq  = p_numtime
                                                               and codaplvl = tstdisd.codaplvl
                                                               and codempid = nvl(p_codempid, codempid) )
--#5552
                                                )
                            );
      exception when no_data_found then
          v_pctta  := null;
          v_pctpunsh  := null;
          v_pctbeh  := null;
          v_pctcmp  := null;
          v_pctkpiem  := null;
       end;


        obj_result := json_object_t;
        obj_row := json_object_t();
        begin
          if (nvl(v_pctta,0) + nvl(v_pctpunsh,0)) > 0 then
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_row + 1);
              obj_data.put('assecompnt',get_label_name('HRAP14E',global_v_lang,140) || '/' || get_label_name('HRAP14E',global_v_lang,150));
              obj_data.put('weight',(v_pctta + v_pctpunsh));
              obj_data.put('empother',((nvl(v_qtyta,0) * nvl(v_pctta,0)) / 100) + ((nvl(v_qtypuns,0) * nvl(v_pctpunsh,0)) / 100));
              obj_data.put('supervisor',((nvl(v_qtyta,0) * nvl(v_pctta,0)) / 100) + ((nvl(v_qtypuns,0) * nvl(v_pctpunsh,0)) / 100));
              obj_data.put('approval',((nvl(v_qtyta,0) * nvl(v_pctta,0)) / 100) + ((nvl(v_qtypuns,0) * nvl(v_pctpunsh,0)) / 100));
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end if;
          if nvl(v_pctbeh,0) > 0 then
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_row + 1);
              obj_data.put('assecompnt',get_label_name('HRAP14E',global_v_lang,180));
              obj_data.put('weight',v_pctbeh);
              obj_data.put('empother',(nvl(v_qtybeh,0) * nvl(v_pctbeh,0)) / 100);
              obj_data.put('supervisor',(nvl(v_qtybeh2,0) * nvl(v_pctbeh,0)) / 100);
              obj_data.put('approval',(nvl(v_qtybeh3,0) * nvl(v_pctbeh,0)) / 100);
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end if;
          if nvl(v_pctcmp,0) > 0 then
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_row + 1);
              obj_data.put('assecompnt',get_label_name('HRAP33EP3',global_v_lang,30));
              obj_data.put('weight',v_pctcmp);
              obj_data.put('empother',(nvl(v_qtycmp,0) * nvl(v_pctcmp,0)) /100);
              obj_data.put('supervisor',(nvl(v_qtycmp2,0) * nvl(v_pctcmp,0)) /100);
              obj_data.put('approval',(nvl(v_qtycmp3,0) * nvl(v_pctcmp,0)) /100);
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end if;
          if (nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0) > 0) then
              obj_data := json_object_t();
              obj_data.put('coderror','200');
              obj_data.put('numseq',v_row + 1);
              obj_data.put('assecompnt',get_label_name('HRAP33EP3',global_v_lang,40));
              obj_data.put('weight',nvl(v_pctkpicp,0) + nvl(v_pctkpiem,0) + nvl(v_pctkpirt,0));
              obj_data.put('empother',((nvl(v_qtykpic,0) * nvl(v_pctkpirt,0)) /100) +  ((nvl(v_qtykpid,0) * nvl(v_pctkpicp,0)) /100) + ((nvl(v_qtykpie,0) * nvl(v_pctkpiem,0)) / 100));
              obj_data.put('supervisor',((nvl(v_qtykpic,0) * nvl(v_pctkpirt,0)) /100) +  ((nvl(v_qtykpid,0) * nvl(v_pctkpicp,0)) /100) + ((nvl(v_qtykpie2,0) * nvl(v_pctkpiem,0)) / 100));
              obj_data.put('approval',((nvl(v_qtykpic,0) * nvl(v_pctkpirt,0)) /100) +  ((nvl(v_qtykpid,0) * nvl(v_pctkpicp,0)) /100) + ((nvl(v_qtykpie3,0) * nvl(v_pctkpiem,0)) / 100));
              obj_row.put(to_char(v_row), obj_data);
              v_row        := v_row + 1;
          end if;

        exception when others then null;
        end;

        json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_table (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_meaasge(json_str_output out clob) is
    obj_data            json_object_t;

      cursor c1 is
      select remark,remark2,remark3,commtimpro
        from tappemp
      where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codempid  = p_codempid;

    begin

           obj_data := json_object_t();
           obj_data.put('coderror','200');
              for r1 in c1 loop
                obj_data.put('remark',r1.remark);
                obj_data.put('remark2',r1.remark2);
                obj_data.put('remark3',r1.remark3);
                obj_data.put('commtimpro',r1.commtimpro);
               end loop;
        json_str_output := obj_data.to_clob;
  end;

  procedure get_detail_meaasge (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then

            gen_detail_meaasge(json_str_output);
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
    v_error_remark    varchar2(4000);
    obj_data          json_object_t;
    obj_row           json_object_t;
    obj_result           json_object_t;
    json_result           json_object_t;
    v_rcnt            number  := 0;
    v_codcomp        temploy1.codcomp%type;
    v_codempid        tappemp.codempid%type;
    v_grdadj          tappemp.grdadj%type;
    v_qtyadjtot       tappemp.qtyadjtot%type;
    v_column			   number := 3;
    v_error				   boolean;
    v_err_code  	   varchar2(1000 char);
    v_err_field  	   varchar2(1000 char);
    v_err_table		   varchar2(20 char);
    v_flgfound  	   boolean;
    v_cnt					   number := 0;
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
              set codadj = p_coduser,
                  dteadj = p_dteupd,
                  grdadj = v_text(2),
                  grdap  = v_text(2),
                  qtyadjtot  = v_text(3)
              where codempid = v_text(1)
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

   procedure gen_detail_competency_table(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;


    cursor c1 is
    select codskill,codtency,grade,gradexpct
        from tappcmpf
       where codempid  = p_codempid
              and dteyreap = p_dteyreap
              and numtime = p_numtime
              and grade < gradexpct
            order by codskill;
      begin

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin
            for r1 in c1 loop
              v_count := v_count +1;

                v_chksecu := true;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codtency',r1.codtency);
                obj_data.put('codskill',r1.codskill);
                obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
                obj_data.put('gradexpct',r1.gradexpct);
                obj_data.put('grade',r1.grade);
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;

            end loop;

        exception when others then null;
        end;


        json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_table (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        check_index();
        if param_msg_error is null then
            gen_detail_competency_table(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_competency_course(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;


    cursor c1 is
    select codcours
        from tapptrnf
       where codempid  = p_codempid
              and dteyreap = p_dteyreap
              and numtime = p_numtime
            order by codcours;
      begin

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin
            for r1 in c1 loop
              v_count := v_count +1;
                v_chksecu := true;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codcours',r1.codcours);
                obj_data.put('desc_codcours',get_tcourse_name(r1.codcours,global_v_lang));
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;

            end loop;

        exception when others then null;
        end;

        json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_course (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_competency_course(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

   procedure gen_detail_competency_develop(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_row               number := 0;
    v_count             number := 0;
    v_flgsecu           boolean := false;
    v_chksecu           boolean := false;
    v_dteeffec          date;


    cursor c1 is
    select coddevp,desdevp
        from tappdevf
       where codempid  = p_codempid
              and dteyreap = p_dteyreap
              and numtime = p_numtime
            order by coddevp;
      begin

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin
            for r1 in c1 loop
              v_count := v_count +1;


                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('coddevp',r1.coddevp);
                obj_data.put('desdevp',r1.desdevp);
                obj_row.put(to_char(v_row), obj_data);
                v_row        := v_row + 1;

            end loop;

        exception when others then null;
        end;

        json_str_output := obj_row.to_clob;
  end ;

  procedure get_detail_competency_develop (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail_competency_develop(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_approve(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result            json_object_t;
    v_row               number := 0;
    v_all_emp           number := 0;
    v_array             number := 0;
    v_sum_per           number := 0;
    v_qtywork           number := 0;
    v_codapman          temploy1.codempid%type;
    v_codapman_a        temploy1.codempid%type;
    v_year              number:=0;
    v_month             number:=0;

      cursor c1 is
      select flgconfemp,dteconfemp,flgconfhd,dteconfhd,flgconflhd,dteconflhd
        from tappemp
      where dteyreap = p_dteyreap
         and numtime  = p_numtime
         and codempid  = p_codempid;

    begin

        begin
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            for r1 in c1 loop
              obj_data.put('flgconfemp',r1.flgconfemp);
              obj_data.put('dteconfemp',to_char(r1.dteconfemp,'dd/mm/yyyy'));
              obj_data.put('flgconfhd',r1.flgconfhd);
              obj_data.put('dteconfhd',to_char(r1.dteconfhd,'dd/mm/yyyy'));
              obj_data.put('flgconflhd',r1.flgconflhd);
              obj_data.put('dteconflhd',to_char(r1.dteconflhd,'dd/mm/yyyy'));
             end loop;

        exception when others then
         null;
        end;

        json_str_output := obj_data.to_clob;
  end;

  procedure get_detail_approve (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then

            gen_detail_approve(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_punishment(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;

    begin

       begin
          select sum(qtyscor)
          into  v_qtyscor_ta
          from tappempta
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_qtyscor_ta := null;
        end;

        begin
          select sum(qtyscor)
          into  v_qtyscor_puns
          from tappempmt
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_qtyscor_puns := null;
        end;

        begin
          select codaplvl,qtyta,qtypuns,codform
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        begin
          select scorfta,scorfpunsh
          into   v_scorfta,v_scorfpunsh
          from tattpreh
       where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
              and codaplvl = v_codaplvl
              and dteeffec = (
                        select max(dteeffec)
                         from tattpreh
                        where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
                          and codaplvl = v_codaplvl
                          and dteeffec <= sysdate
                    );
        exception when no_data_found then
          v_scorfta := null;
          v_scorfpunsh := null;
        end;

        begin
           select pctta,pctpunsh
           into v_pctta,v_pctpunsh
           from taplvl
          where codcomp  like p_codcomp || '%'
            and codform = v_codform
            and dteeffec = (select max(dteeffec)
                              from taplvl
                             where codcomp  like p_codcomp || '%'
                               and codform = v_codform
                               and dteeffec <= (select dteapend
                                                  from tstdisd
                                                 where codcomp  like p_codcomp || '%'
                                                   and dteyreap = p_dteyreap
                                                   and numtime = p_numtime
--#5552
                                                   and exists(select codaplvl
                                                              from tempaplvl
                                                             where dteyreap = p_dteyreap
                                                               and numseq  = p_numtime
                                                               and codaplvl = tstdisd.codaplvl
                                                               and codempid = nvl(p_codempid, codempid) )
--#5552
                                                )
                            );
        exception when no_data_found then
          v_pctta := null;
          v_pctpunsh := null;
        end;

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('detail',get_label_name('HRAP14E',global_v_lang,140));
                obj_data.put('qtyscorf',v_scorfta);
                obj_data.put('qtyscorbrkn',v_qtyscor_ta);
                obj_data.put('points',v_qtyta);
                obj_data.put('weight',v_pctta);
                obj_data.put('qtynet',(nvl(v_pctta,0)*nvl(v_qtyta,0)));
                obj_row.put(to_char(0), obj_data);

                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('detail',get_label_name('HRAP14E',global_v_lang,150));
                obj_data.put('qtyscorf',v_scorfpunsh);
                obj_data.put('qtyscorbrkn',v_qtyscor_puns);
                obj_data.put('points',v_qtypuns);
                obj_data.put('weight',v_pctpunsh);
                obj_data.put('qtynet',(nvl(v_pctpunsh,0)*nvl(v_qtypuns,0)));
                obj_row.put(to_char(1), obj_data);


           obj_result.put('coderror','200');
           obj_result.put('scorfpunsh',(v_scorfta+v_scorfpunsh));
           obj_result.put('pintpunsh',(v_qtyta+v_qtypuns));
           obj_result.put('table',obj_row);

        exception when others then null;
        end;

        json_str_output := obj_result.to_clob;
  end ;

  procedure get_punishment (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_punishment(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_leavegroup(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_row               number := 0;

     cursor c1 is
        select codgrplv,qtyleav,qtyscor
          from tappempta
          where codempid = p_codempid
            and  dteyreap = p_dteyreap
            and  numtime = p_numtime
            order by codgrplv;

    begin

       begin
          select sum(qtyscor)
          into  v_qtyscor_ta
          from tappempta
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_qtyscor_ta := null;
        end;

        begin
          select codaplvl,qtyta,qtypuns,codform
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        begin
          select scorfta
          into   v_scorfta
          from tattpreh
       where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
              and codaplvl = v_codaplvl
              and dteeffec = (
                        select max(dteeffec)
                         from tattpreh
                        where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
                          and codaplvl = v_codaplvl
                          and dteeffec <= sysdate
                    );
        exception when no_data_found then
          v_scorfta := null;
          v_scorfpunsh := null;
        end;


        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

              for r1 in c1 loop
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codgrplv',r1.codgrplv);
                obj_data.put('desc_codgrplv',get_tlistval_name('GRPLEAVE',r1.codgrplv,global_v_lang));
                obj_data.put('qtyleav',r1.qtyleav);
                obj_data.put('qtyscor',r1.qtyscor);
                obj_row.put(to_char(v_row), obj_data);
                v_row := v_row + 1;
               end loop;
           obj_result.put('coderror','200');
           obj_result.put('scorfleavgrp',v_scorfta);
           obj_result.put('pintleavgrp',(v_scorfta-v_qtyscor_ta));
           obj_result.put('table',obj_row);

        exception when others then null;
        end;

        json_str_output := obj_result.to_clob;
  end ;

  procedure get_leavegroup (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_leavegroup(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_comingwork(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_row               number := 0;


     cursor c1 is
        select codpunsh,qtypunsh,qtyscor
          from tappempmt
          where codempid = p_codempid
            and  dteyreap = p_dteyreap
            and  numtime = p_numtime
            order by codpunsh;

    begin

       begin
          select sum(qtyscor)
          into  v_qtyscor_puns
          from tappempmt
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_qtyscor_puns := null;
        end;

        begin
          select codaplvl,qtyta,qtypuns,codform
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        begin
          select scorfta
          into   v_scorfpunsh
          from tattpreh
       where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
              and codaplvl = v_codaplvl
              and dteeffec = (
                        select max(dteeffec)
                         from tattpreh
                        where codcompy  = hcm_util.get_codcomp_level(p_codcomp,1)
                          and codaplvl = v_codaplvl
                          and dteeffec <= sysdate
                    );
        exception when no_data_found then
          v_scorfta := null;
          v_scorfpunsh := null;
        end;


        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

              for r1 in c1 loop
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codpunsh',r1.codpunsh);
                obj_data.put('desc_codpunsh',get_tcodec_name('TCODPUNH', r1.codpunsh, global_v_lang));
                obj_data.put('qtypunsh',r1.qtypunsh);
                obj_data.put('qtyscor',r1.qtyscor);
                obj_row.put(to_char(v_row), obj_data);
                v_row := v_row + 1;
               end loop;
           obj_result.put('coderror','200');
           obj_result.put('scorfcomngwrk',v_scorfpunsh);
           obj_result.put('pintcomngwrk',(v_scorfpunsh-v_qtyscor_puns));
           obj_result.put('table',obj_row);

        exception when others then null;
        end;

        json_str_output := obj_result.to_clob;
  end ;

  procedure get_comingwork (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_comingwork(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_behavior(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_row               number := 0;
    v_numseq            tappbehi.numseq%type;
    v_numtime            tappbehi.numtime%type;
    v_numgrup            tappbehi.numgrup%type;
    v_numitem            tappbehi.numitem%type;
    v_temp_no            varchar2(50 char) := '!@#';

     cursor c1 is
        select numgrup,numitem,qtywgt,decode(global_v_lang,'101', desiteme ,
                                 '102', desitemt,
                                 '103', desitem3,
                                 '104', desitem4,
                                 '105', desitem5,desiteme) desitem
          from tintvewd
          where codform = v_codform
            order by numgrup,numitem;

      cursor c2 is
        select grdscor,qtyscorn,flgapman,remark
          from tappbehi a,tappfm b
          where a.codempid  = p_codempid
          and a.dteyreap = p_dteyreap
          and a.numtime  = p_numtime
--          and a.numseq  = (
--                        select max(numseq)
--                          from tappbehi
--                         where a.codempid  = p_codempid
--                           and a.dteyreap = p_dteyreap
--                           and a.numtime  = v_numitem
--                    )
           and a.numgrup  = v_numgrup
           and a.numitem  = v_numitem
           and a.codempid  = b.codempid
            and a.dteyreap = b.dteyreap
            and a.numtime  = b.numtime
            and a.numseq  = b.numseq
            group by grdscor,qtyscorn,flgapman,remark
            order by flgapman
           ;

    begin


        begin
          select codaplvl,qtyta,qtypuns,codform
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

              for r1 in c1 loop
                v_numgrup := r1.numgrup;
                v_numitem := r1.numitem;

                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('numgrup',r1.numgrup);
                if v_temp_no = '!@#' or v_temp_no <> v_numgrup then
                    obj_data.put('number','ส่วนที่ '||v_numgrup);
                    v_temp_no := v_numgrup;
                    obj_row.put(to_char(v_row), obj_data);
                    v_row := v_row + 1;
                else
                  obj_data.put('number',r1.numitem);
                end if;

                obj_data.put('number',r1.numitem);
                obj_data.put('detail',r1.desitem);
                obj_data.put('qtywgt',r1.qtywgt);

                  for r2 in c2 loop

                    if r2.flgapman = 1 then
                      obj_data.put('qtyempothergrde',r2.grdscor);
                      obj_data.put('qtyempotherscrnt',r2.qtyscorn);
                    elsif r2.flgapman = 2 then
                      obj_data.put('qtysuprvisrgrde',r2.grdscor);
                      obj_data.put('qtysuprvisrscrnt',r2.qtyscorn);
                    elsif r2.flgapman = 3 then
                      obj_data.put('qtyapprgrde',r2.grdscor);
                      obj_data.put('qtyapprscrnt',r2.qtyscorn);
                    end if;
                     obj_data.put('remark',r2.remark);
                  end loop;

                obj_row.put(to_char(v_row), obj_data);
                v_row := v_row + 1;
               end loop;
           obj_result.put('coderror','200');
           obj_result.put('codform',v_codform);
           obj_result.put('table',obj_row);

        exception when others then null;
        end;

        json_str_output := obj_result.to_clob;
  end ;

  procedure get_behavior (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_behavior(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_competency(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_data2           json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_row               number := 0;
    v_numseq            tappbehi.numseq%type;
    v_numtime            tappbehi.numtime%type;
    v_numgrup            tappbehi.numgrup%type;
    v_numitem            tappbehi.numitem%type;
    v_codskill_temp       tappcmps.codtency%type := '!@#';

     cursor c1 is
        select a.numtime,a.codtency,b.qtyscor,a.qtyscorn,a.pctwgt,
               b.codskill,b.gradexpct,b.grade,b.remark,flgapman,b.numseq
          from tappcmpc a, tappcmps b ,tappfm c
          where a.codempid  = p_codempid
          and a.dteyreap = p_dteyreap
          and a.numtime  = p_numtime
--          and a.numseq  = (
--                        select max(numseq)
--                          from tappcmpc
--                         where a.codempid  = p_codempid
--                           and a.dteyreap = p_dteyreap
--                           and a.numtime  = v_numtime
--                    )
          and a.codempid  = b.codempid
          and a.dteyreap = b.dteyreap
          and a.numtime  = b.numtime
          and a.numseq  = b.numseq
          and a.codtency  = b.codtency
          and a.codempid  = c.codempid
            and a.dteyreap = c.dteyreap
            and a.numtime  = c.numtime
            and a.numseq  = c.numseq
            group by a.numtime,a.codtency,b.qtyscor,a.qtyscorn,a.pctwgt,
               b.codskill,b.gradexpct,b.grade,b.remark,flgapman,b.numseq
          order by a.codtency,b.codskill,b.numseq ;

    begin

        begin
          select codaplvl,qtyta,qtypuns,codform
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin
         obj_data2 := json_object_t();
              for r1 in c1 loop
                v_numtime := r1.numtime;
                if v_codskill_temp <> '!@#' and v_codskill_temp <> r1.codskill then
                  obj_row.put(to_char(v_row), obj_data2);
                  v_row := v_row + 1;
                  obj_data2 := json_object_t();
                  v_codskill_temp  := r1.codskill;
                end if;
                v_codskill_temp  := r1.codskill;

                obj_data := obj_data2;
                obj_data.put('coderror','200');
                obj_data.put('codtency',r1.codtency);
                obj_data.put('qtyscor',r1.qtyscor);
                obj_data.put('qtyscorn',r1.qtyscorn);
                obj_data.put('pctwgt',r1.pctwgt);
                obj_data.put('codskill',r1.codskill);
                obj_data.put('desc_codskill',get_tcodec_name('TCODSKIL',r1.codskill, global_v_lang));
                obj_data.put('gradexpct',r1.gradexpct);
                obj_data.put('remark',r1.remark);

                if r1.flgapman = 1 then
                  obj_data.put('qtyempotherlevl',r1.grade);
                  obj_data.put('qtyempotherscor',r1.qtyscor);
                elsif r1.flgapman = 2 then
                  obj_data.put('qtysuprvisrlevl',r1.grade);
                  obj_data.put('qtysuprvisrscor',r1.qtyscor);
                elsif r1.flgapman = 3 then
                  obj_data.put('qtyapprlevl',r1.grade);
                  obj_data.put('qtyapprscor',r1.qtyscor);
                end if;
                obj_data2 := obj_data;
               end loop;

          obj_row.put(to_char(v_row), obj_data);
        exception when others then null;
        end;

        json_str_output := obj_row.to_clob;
  end ;

  procedure get_competency (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);

        if param_msg_error is null then
            gen_competency(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_kpi(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_result          json_object_t;
    v_qtyscor_ta        tappempta.qtyscor%type;
    v_qtyscor_puns      tappempmt.qtyscor%type;
    v_codaplvl          tappemp.codaplvl%type;
    v_qtykpie3          tappemp.qtykpie3%type;
    v_qtyta             tappemp.qtyta%type;
    v_qtypuns           tappemp.qtypuns%type;
    v_codform           tappemp.codform%type;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;
    v_pctta             taplvl.pctta%type;
    v_pctpunsh          taplvl.pctpunsh%type;
    v_row               number := 0;
    v_codkpi            tkpiemp.codkpi%type;

     cursor c1 is
        select typkpi,kpides,target,mtrfinish,pctwgt,achieve,codkpi
          from tkpiemp
          where codempid  = p_codempid
          and dteyreap = p_dteyreap
          and numtime  = p_numtime
          order by   decode (typkpi,'D',1, 'J',2, 'I',3,1),codkpi ;

      cursor c2 is
        select qtyscor,qtyscorn,remark,flgapman,typkpi,a.numseq
          from tappkpid a ,tappfm b
          where a.codempid  = p_codempid
          and a.dteyreap = p_dteyreap
          and a.numtime  = p_numtime
          and a.kpino  = v_codkpi
--          and a.numseq  = (
--                        select max(numseq)
--                          from tappcmpc
--                         where a.codempid  = p_codempid
--                           and a.dteyreap = p_dteyreap
--                           and a.numtime  = v_numtime
--                    )

          and a.codempid  = b.codempid
            and a.dteyreap = b.dteyreap
            and a.numtime  = b.numtime
            and a.numseq  = b.numseq
            group by qtyscor,qtyscorn,remark,flgapman,typkpi,a.numseq
          order by typkpi,a.numseq ;

    begin

        begin
          select codaplvl,qtyta,qtypuns,codform,qtykpie3
          into  v_codaplvl,v_qtyta,v_qtypuns,v_codform,v_qtykpie3
          from tappemp
            where dteyreap = p_dteyreap
           and numtime  = p_numtime
           and codempid  = p_codempid;
        exception when no_data_found then
          v_codaplvl := null;
          v_qtyta := null;
          v_qtypuns := null;
        end;

        obj_result := json_object_t;
        obj_row := json_object_t();
        begin

              for r1 in c1 loop


                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('codkpi',r1.codkpi);
                obj_data.put('detail',r1.kpides);
                obj_data.put('goal',r1.target);
                obj_data.put('value',r1.mtrfinish);
                obj_data.put('weight',r1.pctwgt);
                obj_data.put('works',r1.achieve);

                v_codkpi := r1.codkpi;
                for r2 in c2 loop
                    if r2.flgapman = 1 then
                      obj_data.put('qtyempotherpint',r2.qtyscor);
                      obj_data.put('qtyempotherscrnet',r2.qtyscorn);
                    elsif r2.flgapman = 2 then
                      obj_data.put('qtysuprvisrpint',r2.qtyscor);
                      obj_data.put('qtysuprvisrscrnet',r2.qtyscorn);
                    elsif r2.flgapman = 3 then
                      obj_data.put('qtyapprpint',r2.qtyscor);
                      obj_data.put('qtyapprscrnet',r2.qtyscorn);
                    end if;
                     obj_data.put('remark',r2.remark);

                  end loop;

                obj_row.put(to_char(v_row), obj_data);
                v_row := v_row + 1;
               end loop;
           obj_result.put('coderror','200');
           obj_result.put('qtyscorenet',v_qtykpie3);
           obj_result.put('table',obj_row);

        exception when others then null;
        end;

        json_str_output := obj_result.to_clob;
  end ;

  procedure get_kpi (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_kpi(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_save_index (i_grdadj in varchar2, i_qtyadjtot in varchar2, i_codempid in varchar2) is
   p_temp varchar2(100 char);
   v_secur  boolean := false;
  begin

    if i_grdadj is not null then
      begin
        select grade
          into p_temp
          from tstdis
       where codcomp  like p_codcomp || '%'
         and grade = i_grdadj
         and dteyreap = (
                        select max(dteyreap)
                        from tstdis
                        where codcomp like p_codcomp || '%'
                          and dteyreap <= p_dteyreap
                          and grade = i_grdadj
                    );
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tstdis');
        return;
      end;
    end if;

    if i_qtyadjtot is not null then
      begin
              select grade into p_temp
              from tstdis
              where codcomp like hcm_util.get_codcomp_level(p_codcomp,1) || '%'
              and grade = i_grdadj
              and dteyreap = (
                        select max(dteyreap)
                         from tstdis
                        where codcomp like hcm_util.get_codcomp_level(p_codcomp,1) || '%'
                          and dteyreap <= p_dteyreap
                          and grade = i_grdadj
                    )
              and i_qtyadjtot between pctwkstr and pctwkend;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tstdis');
        return;
      end;
    end if;

    if i_codempid is not null then
      begin
         select staemp into p_temp
         from temploy1
         where codempid = i_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;

      if p_temp = 9 then
         param_msg_error := get_error_msg_php('HR2101',global_v_lang);
         return;
      elsif p_temp = 0 then
         param_msg_error := get_error_msg_php('HR2102',global_v_lang);
         return;
      end if;
         v_secur := secur_main.secur2(i_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
           if not v_secur  then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
    end if;
  end;

  procedure upd_tappemp is
  begin

    begin
      update tappemp
        set  flgconfemp = p_flgconfemp,
             dteconfemp = p_dteconfemp,
              flgconfhd = p_flgconfhd,
              dteconfhd = p_dteconfhd,
             flgconflhd = p_flgconflhd,
             dteconflhd = p_dteconflhd,
                coduser = global_v_coduser
         where codempid = p_codempid
           and dteyreap = p_dteyreap
            and numtime = p_numtime;
    exception when others then
      null;
    end;

  end;

  procedure save_index(json_str_input in clob,json_str_output out clob) as
    param_json_row  json_object_t;
    param_json      json_object_t;
    param_json2      json_object_t;
  begin

    param_json2 := hcm_util.get_json_t(json_object_t(json_str_input),'p_table');
    param_json := hcm_util.get_json_t(json_object_t(param_json2),'table');

    if param_json.get_size > 0 then
      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
        p_codempid      := hcm_util.get_string_t(param_json_row,'codempid');
        if param_msg_error is null then
          upd_tappemp;
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
  begin
    initial_value(json_str_input);
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

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
  begin

        if param_msg_error is null then
          upd_tappemp;
        end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    end if;
  end save_detail;

  procedure post_save_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      save_detail(json_str_input,json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date) as
    cursor c_taplvl is
      select dteeffec,codcomp
        from taplvl
       where p_codcomp_in like codcomp||'%'
         and codaplvl = p_codaplvl
         and dteeffec <= v_global_dteapend
      order by codcomp desc,dteeffec desc;
  begin
    for r_taplvl in c_taplvl loop
      p_dteeffec := r_taplvl.dteeffec;
      p_codcomp_out := r_taplvl.codcomp;
      exit;
    end loop;
  end;
end hrap33e;

/

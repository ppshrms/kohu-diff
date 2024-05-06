--------------------------------------------------------
--  DDL for Package Body HRAP4FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4FX" is
-- last update: 02/09/2020 21:00
  procedure initial_value(json_str in clob) is
      json_obj        json_object_t;
      begin
        v_chken             := hcm_secur.get_v_chken;
        json_obj            := json_object_t(json_str);
        --global
        global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
        global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
        global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
        --b_index
        b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
        b_index_dteyreap    := hcm_util.get_string_t(json_obj,'p_year');
        b_index_numtime     := hcm_util.get_string_t(json_obj,'p_seqno');
        --screen
--        b_index_codkpino    := hcm_util.get_string_t(json_obj,'p_codkpino');
--        b_index_grade       := hcm_util.get_string_t(json_obj,'p_grade');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
      end initial_value;
  --


procedure get_data1(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data1(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --


  procedure gen_data1(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_obj           tobjective.objective%type;

 begin
    obj_row := json_object_t();
            begin
                select objective
                  into v_obj
                  from tobjective
                 where dteyreap =  b_index_dteyreap
                   and codcompy =  b_index_codcompy;
                exception when no_data_found then
                    v_obj := null;
            end;
   --<< user25 Date: 14/09/2021 3. AP Module #4326
        /*
           if v_obj is not null then
                v_flgdata := 'Y';
            end if;

            if v_flgdata = 'Y' then
                    flgpass := secur_main.secur7(b_index_codcompy,global_v_coduser);
                    if flgpass then
                        v_flgsecu := 'Y';
                        v_rcnt := v_rcnt+1;
                        obj_data := json_object_t();
                        obj_data.put('coderror', '200');
                        obj_data.put('objective',v_obj);
                     --   obj_row.put(to_char(v_rcnt-1),obj_data);
                    end if;
            end if; --v_flgdata
            if v_flgdata = 'N' then
              param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobjective');
              json_str_output := get_response_message(null, param_msg_error, global_v_lang);
            elsif v_flgsecu = 'N' then
              param_msg_error := get_error_msg_php('HR3007',global_v_lang);
              json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            else
             -- json_str_output := obj_row.to_clob;
              json_str_output := obj_data.to_clob;
            end if;
            */
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('objective',v_obj);
            json_str_output := obj_data.to_clob;
      -->> user25 Date: 14/09/2021 3. AP Module #4326
  end;
  --

  procedure get_data2(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data2(json_str_output);
        --delete
        param_msg_error := null;
        v_numseq := 1;
        begin
          delete from ttemprpt
           where codempid = global_v_codempid
             and codapp   = 'HRAP4FX';
        exception when others then
          rollback;
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
          return;
        end;
        gen_graph;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --

  procedure gen_data2(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgdata2      varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';
    v_chksecu       varchar2(1);
    v_dteyrbug      number;
    flgpass     	boolean;
    v_codempid      temploy1.codempid%type;
    v_codkpi        tkpicmph.codkpi%type;
    v_color         tkpicmpg.color%type;
    v_desgrade      tkpicmpg.desgrade%type;
    v_tot_score     number :=0;

cursor c1 is
    select a.balscore, b.grade, a.codkpi, a.kpides, a.target,  a.kpivalue, b.achieve, b.mtrfinish, b.qtyscor, b.stakpi
    from  tkpicmph  a,  tkpicmphs  b
    where a.dteyreap      = b_index_dteyreap
    and   a.codcompy      = b_index_codcompy
    and   b.numtime       = b_index_numtime
    and   a.dteyreap      = b.dteyreap
    and   a.codcompy      = b.codcompy
    and   a.codkpi        = b.codkpi
    order by a.balscore, a.codkpi;

    v2_bscchk       varchar2(100 char):= '!@#$%$'; 

 begin
    obj_row := json_object_t();
    v_chksecu := '1';

    for i in c1 loop
        v_flgdata := 'Y';
    end loop;

    if v_flgdata = 'Y' then
        for i in c1 loop
            flgpass := secur_main.secur7(b_index_codcompy,global_v_coduser);
            if flgpass then
                v_flgsecu := 'Y';
                    v_rcnt := v_rcnt+1;
                    obj_data := json_object_t();
                    obj_data.put('coderror', '200');
                    obj_data.put('year',b_index_dteyreap);
                    obj_data.put('seqno',b_index_numtime);
                    obj_data.put('codcompy',b_index_codcompy);
                    obj_data.put('bsc',i.balscore);
 --<< #7273 || USER39 || 27/11/2021                   
                    if v2_bscchk <> i.balscore then
                        v2_bscchk := i.balscore;
                        obj_data.put('desc_bsc',get_tlistval_name('BALSCORE',i.balscore,global_v_lang));
                    else
                        obj_data.put('desc_bsc','   ');
                    end if;
-->> #7273 || USER39 || 27/11/2021                                                           
                    begin
                        select color, desgrade
                          into v_color, v_desgrade
                          from tkpicmpg
                         where dteyreap     = b_index_dteyreap
                           and codcompy     = b_index_codcompy
                           and codkpi       = i.codkpi
                           and grade        = i.grade;
                    exception when no_data_found then
                            v_color     := null;
                            v_desgrade  := null;
                    end;

                   --<<user25 Date : 14/09/2021 3. AP Module #4326
                      obj_data.put('color',v_color);
                      if v_color is null then
                        obj_data.put('tag','');
                      else
                        obj_data.put('tag','<i class="fas fa-circle" style="color: '||v_color||';"></i>');
                      end if ;
                     -->>user25 Date : 14/09/2021 3. AP Module #4326

                    obj_data.put('kpino',i.codkpi);
                    obj_data.put('desc_kpi',i.kpides);
                    obj_data.put('target',i.target);
                    obj_data.put('volumn',to_char(nvl(i.kpivalue,0),'fm999,999,999,990.00')); -- #7273 || USER39 || 27/11/2021
                    obj_data.put('port',i.achieve);
                    obj_data.put('volumn2',to_char(nvl(i.mtrfinish,0),'fm999,999,999,990.00')); -- #7273 || USER39 || 27/11/2021
                    obj_data.put('grade',v_desgrade);
                    obj_data.put('score',i.qtyscor);
                    v_tot_score := nvl(v_tot_score,0) + nvl(i.qtyscor,0);
                    obj_data.put('result',get_tlistval_name('STAKPI',i.stakpi,global_v_lang));
                 obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;  --flgpass
        end loop; --c1

--                    v_rcnt := v_rcnt+1;
--                    obj_data := json_object_t();
--                    obj_data.put('coderror', '200');
--                    obj_data.put('year','');
--                    obj_data.put('seqno','');
--                    obj_data.put('codcompy','');
--                    obj_data.put('bsc','');
--                    obj_data.put('desc_bsc','');
--                    obj_data.put('color','');
--                    obj_data.put('kpino','');
--                    obj_data.put('desc_kpi','');
--                    obj_data.put('target','');
--                    obj_data.put('volumn','');
--                    obj_data.put('port','');
--                    obj_data.put('volumn2','');
--                    obj_data.put('grade',get_label_name('HRAP4FX1', global_v_lang, '100'));
--                    obj_data.put('score',v_tot_score);
--                    obj_data.put('result','');
--                   obj_row.put(to_char(v_rcnt-1),obj_data);
    end if; --v_flgdata

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tkpicmph');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  -----

  procedure gen_graph is
    obj_data    json_object_t;
    v_codempid  ttemprpt.codempid%type := global_v_codempid;
    v_codapp    ttemprpt.codapp%type := 'HRAP4FX';
--    v_numseq    ttemprpt.numseq%type := 0;
    v_item1     ttemprpt.item1%type;
    v_item2     ttemprpt.item2%type;
    v_item3     ttemprpt.item3%type;
    v_item4     ttemprpt.item4%type;
    v_item5     ttemprpt.item5%type;
    v_item6     ttemprpt.item6%type;
    v_item7     ttemprpt.item7%type;
    v_item8     ttemprpt.item8%type;
    v_item9     ttemprpt.item9%type;
    v_item10    ttemprpt.item10%type;
    v_item14    ttemprpt.item14%type;
    v_item31    ttemprpt.item31%type;
    j                varchar2(10 char);
    v_numitem7       number := 0;
    v_numitem14      number := 0;
    v_numseq2        number;
    v_flgdata        varchar2(1 char) := 'N';
  --  v_dteyreap       number := 0;
    v_qty_policy     number := 0;
    v_qty_actual     number := 0;
    v_desc           varchar2(400 char);
    v_seq_grd        number :=0;
    v_seq_yre        number :=0;
    v_cs1            number :=0;
    v_cs             number :=0;
    flgpass          boolean;
    v_per_policy    varchar2(40 char);
    v_flgsecu varchar2(1);

cursor c1 is
    select a.balscore, b.grade, a.codkpi, a.kpides, a.target,  a.kpivalue, b.achieve, b.mtrfinish, b.qtyscor, b.stakpi
    from  tkpicmph  a,  tkpicmphs  b
    where a.dteyreap      = b_index_dteyreap
    and   a.codcompy      = b_index_codcompy
    and   b.numtime       = b_index_numtime
    and   a.dteyreap      = b.dteyreap
    and   a.codcompy      = b.codcompy
    and   a.codkpi        = b.codkpi
    order by a.balscore, a.codkpi;

begin
    for i in c1 loop
        v_flgdata := 'Y';
        exit;
    end loop;

    if v_flgdata = 'Y' then
        param_msg_error := null;
        v_item1  := '';
        v_item2  := '';
        v_item14 := '';
        v_item31 := get_label_name('HRAP4FX1', global_v_lang, '210');
        v_seq_grd := 0;
        for i in c1 loop
            flgpass := secur_main.secur7(b_index_codcompy,global_v_coduser);
            if flgpass then
            v_flgsecu := 'Y';
            v_flgdata := 'Y';
            v_seq_grd := v_seq_grd+1;
            v_item2 :=  get_tlistval_name('BALSCORE',i.balscore,global_v_lang);
            ----------แกน X
            v_item6  := null;--get_label_name('HRAP4FX3', global_v_lang, '20');
            v_item4  := v_seq_grd;
            v_item5  := i.codkpi||'-'||i.kpides;
            ----------แกน Y

            v_item7  := null;
            v_item8  := get_label_name('HRAP4FX1', global_v_lang, '130');
            v_item9  := get_label_name('HRAP4FX1', global_v_lang, '130');--get_label_name('HRAP4FX3', global_v_lang, '30');
            v_item10 := to_char(nvl(i.qtyscor,0),'fm990.00');   ----------ค่าข้อมูล
           ----------Insert ttemprpt
            begin
             insert into ttemprpt
                (codempid, codapp, numseq, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item31, item14)
              values
                (v_codempid, v_codapp, v_numseq, v_item1, v_item2, v_item3, v_item4, v_item5, v_item6, v_item7, v_item8, v_item9, v_item10, v_item31, v_item14 );
            exception when dup_val_on_index then
              rollback;
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'ttemprpt');
              return;
            end;
             v_numseq := v_numseq + 1;
         end if;-- if flgpass
       end loop;--loop i
       commit;
     end if;-- if flgdata
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
end;

/

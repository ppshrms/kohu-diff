--------------------------------------------------------
--  DDL for Package Body HRAP17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP17E" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    logic			    json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');

    p_condition         := hcm_util.get_string_t(json_obj,'p_condition');
    p_stasuccr          := hcm_util.get_string_t(json_obj,'p_stasuccr');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_dteposdue         := to_date(hcm_util.get_string_t(json_obj,'p_dteposdue'),'ddmmyyyy');
    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_datarows          := hcm_util.get_json_t(json_obj,'p_datarows');
    p_codemprq          := hcm_util.get_string_t(json_obj,'p_codemprq');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codcompy            := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_codaplvl            := hcm_util.get_string_t(json_obj,'p_codaplvl');
    p_dteeffec            := to_date(hcm_util.get_string_t(json_obj,'p_dteeffec'),'ddmmyyyy');
    p_codgrplv            := hcm_util.get_string_t(json_obj,'p_codgrplv');
    p_codpunsh            := hcm_util.get_string_t(json_obj,'p_codpunsh');
  end initial_value;
  --
  procedure get_leave(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_leave(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_leave(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row_leave       json_object_t;
    obj_leave           json_object_t;
    obj_tattprelv       json_object_t;
    obj_row_tattprelv   json_object_t;
    obj_tattpre2        json_object_t;
    obj_row_tattpre2    json_object_t;

    v_rcnt_leave    number := 0;
    v_rcnt_table1   number := 0;
    v_rcnt_table2   number := 0;
    v_zupdsal       varchar2(4000 char);
    v_codgrplv      tattprelv.codgrplv%type;
    v_dteeffec      tattpreh.dteeffec%type;
    v_flgAdd        boolean;
    cursor c1 is
        select *
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec;

    cursor c_tattpre1 is
        select *
          from tattpre1
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
      order by codgrplv;

    cursor c_tattprelv is
        select *
          from tattprelv
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codgrplv = v_codgrplv
      order by codleave;

    cursor c_tattpre2 is
        select *
          from tattpre2
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codgrplv = v_codgrplv
      order by numseq;
  begin
    obj_data      := json_object_t();
    begin
        select max(dteeffec)
          into v_dteeffec
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec <= p_dteeffec;
    exception when others then
        v_dteeffec := null;
    end;

    if v_dteeffec is null then
        begin
            select min(dteeffec)
              into v_dteeffec
              from tattpreh
             where codcompy = p_codcompy
               and codaplvl = p_codaplvl
               and dteeffec > p_dteeffec;
        exception when others then
            v_dteeffec := null;
        end;
    end if;

    obj_row_leave := json_object_t();
    obj_data.put('coderror', '200');
    if v_dteeffec is null then
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_data.put('flgDisabled', false);
        obj_data.put('flg', 'add');
        obj_data.put('scorfta', '');
        obj_data.put('table', obj_row_leave);
    else
        for r1 in c1 loop
            if p_dteeffec < trunc(sysdate) then
                obj_data.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
                obj_data.put('flgDisabled', true);
                obj_data.put('flg', '');
                obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
                v_flgAdd := false;
            else
                obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
                obj_data.put('flgDisabled', false);
                if v_dteeffec = p_dteeffec then
                    obj_data.put('flg', 'edit');
                    v_flgAdd := false;
                else
                    obj_data.put('flg', 'add');
                    v_flgAdd := true;
                end if;
            end if;

--            if v_dteeffec = p_dteeffec then
--                if v_dteeffec < trunc(sysdate) then
--                    obj_data.put('flgDisabled', true);
--                    obj_data.put('flg', '');
--                    obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
--                else
--                    obj_data.put('flgDisabled', false);
--                    obj_data.put('flg', 'edit');
--                end if;
--            else
--                obj_data.put('flgDisabled', true);
--                obj_data.put('flg', '');
--                obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
--            end if;

            obj_data.put('scorfta', r1.scorfta);
            v_rcnt_leave  := 0;
            for r_tattpre1 in c_tattpre1 loop
                v_rcnt_leave    := v_rcnt_leave + 1;
                obj_leave       := json_object_t();
                v_codgrplv      := r_tattpre1.codgrplv;
                obj_leave.put('flgAdd', v_flgAdd);
                obj_leave.put('codgrplv', r_tattpre1.codgrplv);
                obj_leave.put('desc_codgrplv', get_tlistval_name('GRPLEAVE',r_tattpre1.codgrplv,global_v_lang) );
                obj_leave.put('desc_unit', get_tlistval_name('FLGUNIT',r_tattpre1.flgunit,global_v_lang));

                if r_tattpre1.flgabsc = 'Y' then
                  obj_leave.put('flgleave', '2');
                elsif r_tattpre1.flglate = 'Y' then
                  obj_leave.put('flgleave', '3');
                else
                  obj_leave.put('flgleave', '1');
                end if;

                obj_row_tattprelv   := json_object_t();
                v_rcnt_table1       := 0;
                for r_tattprelv in c_tattprelv loop
                    v_rcnt_table1   := v_rcnt_table1 + 1;
                    obj_tattprelv   := json_object_t();
                    obj_tattprelv.put('codleave', r_tattprelv.codleave);
                    obj_tattprelv.put('flgAdd', v_flgAdd);
                    obj_row_tattprelv.put(to_char(v_rcnt_table1-1), obj_tattprelv);
                end loop;
                obj_leave.put('table1', obj_row_tattprelv);

                obj_row_tattpre2   := json_object_t();
                v_rcnt_table2       := 0;
                for r_tattpre2 in c_tattpre2 loop
                    v_rcnt_table2   := v_rcnt_table2 + 1;
                    obj_tattpre2    := json_object_t();
                    obj_tattpre2.put('tmp_numseq', r_tattpre2.numseq);
                    obj_tattpre2.put('qtymin', r_tattpre2.qtymin);
                    obj_tattpre2.put('qtymax', r_tattpre2.qtymax);
                    obj_tattpre2.put('scorded', r_tattpre2.scorded);
                    obj_tattpre2.put('flgsal_', r_tattpre2.flgsal);
                    obj_tattpre2.put('flgsal', r_tattpre2.flgsal);
                    obj_tattpre2.put('flgbonus_', r_tattpre2.flgbonus);
                    obj_tattpre2.put('flgbonus', r_tattpre2.flgbonus);
                    obj_tattpre2.put('pctdedbon', r_tattpre2.pctdedbon);
                    obj_tattpre2.put('pctdedsal', r_tattpre2.pctdedsal);
                    obj_tattpre2.put('flgAdd', v_flgAdd);
                    obj_row_tattpre2.put(to_char(v_rcnt_table2-1), obj_tattpre2);
                end loop;
                obj_leave.put('table2', obj_row_tattpre2);
                obj_row_leave.put(to_char(v_rcnt_leave-1), obj_leave);
            end loop;
            obj_data.put('table', obj_row_leave);
        end loop;
    end if;
    json_str_output := obj_data.to_clob;
  end;

  procedure get_grpleave(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_grpleave(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure gen_grpleave(json_str_output out clob) is
    obj_leave           json_object_t;
    obj_tattprelv       json_object_t;
    obj_row_tattprelv   json_object_t;
    obj_tattpre2        json_object_t;
    obj_row_tattpre2    json_object_t;

    v_rcnt_table1       number := 0;
    v_rcnt_table2       number := 0;
    v_dteeffec          tattpreh.dteeffec%type;
    v_flgunit           tattpre1.flgunit%type;
    v_flgabsc           tattpre1.flgabsc%type;
    v_flglate           tattpre1.flglate%type;
    v_flgleave          varchar2(1 char);

    cursor c_tattprelv is
        select *
          from tattprelv
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codgrplv = p_codgrplv
      order by codleave;

    cursor c_tattpre2 is
        select *
          from tattpre2
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codgrplv = p_codgrplv
      order by numseq;
  begin
      begin
        select max(dteeffec)
          into v_dteeffec
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec <= p_dteeffec;
      exception when others then
        v_dteeffec := p_dteeffec;
      end;
      if v_dteeffec is null then
        v_dteeffec := p_dteeffec;
      end if;

      begin
        select flgunit, flgabsc, flglate
          into v_flgunit, v_flgabsc, v_flglate
          from tattpre1
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codgrplv = p_codgrplv;

          if v_flgabsc = 'Y' then
            v_flgleave :=  '2';
          elsif v_flglate = 'Y' then
            v_flgleave :=  '3';
          else
            v_flgleave :=  '1';
          end if;
      exception when others then
        v_flgunit := null;
        v_flgleave := '';
      end;



      obj_leave      := json_object_t();
      obj_leave.put('coderror', '200');
      obj_leave.put('codgrplv', p_codgrplv);
      obj_leave.put('desc_codgrplv', get_tlistval_name('GRPLEAVE',p_codgrplv,global_v_lang));
      obj_leave.put('desc_unit', get_tlistval_name('FLGUNIT',v_flgunit,global_v_lang));
      obj_leave.put('flgleave', v_flgleave);
      obj_row_tattprelv   := json_object_t();
      v_rcnt_table1       := 0;
      for r_tattprelv in c_tattprelv loop
          v_rcnt_table1   := v_rcnt_table1 + 1;
          obj_tattprelv   := json_object_t();
          obj_tattprelv.put('codleave', r_tattprelv.codleave);
          obj_row_tattprelv.put(to_char(v_rcnt_table1-1), obj_tattprelv);
      end loop;
      obj_leave.put('table1', obj_row_tattprelv);

      obj_row_tattpre2    := json_object_t();
      v_rcnt_table2       := 0;
      for r_tattpre2 in c_tattpre2 loop
          v_rcnt_table2   := v_rcnt_table2 + 1;
          obj_tattpre2    := json_object_t();
          obj_tattpre2.put('tmp_numseq', r_tattpre2.numseq);
          obj_tattpre2.put('qtymin', r_tattpre2.qtymin);
          obj_tattpre2.put('qtymax', r_tattpre2.qtymax);
          obj_tattpre2.put('scorded', r_tattpre2.scorded);
          obj_tattpre2.put('flgsal_', r_tattpre2.flgsal);
          obj_tattpre2.put('flgsal', r_tattpre2.flgsal);
          obj_tattpre2.put('flgbonus_', r_tattpre2.flgbonus);
          obj_tattpre2.put('flgbonus', r_tattpre2.flgbonus);
          obj_tattpre2.put('pctdedbon', r_tattpre2.pctdedbon);
          obj_tattpre2.put('pctdedsal', r_tattpre2.pctdedsal);
          obj_row_tattpre2.put(to_char(v_rcnt_table2-1), obj_tattpre2);
      end loop;
      obj_leave.put('table2', obj_row_tattpre2);
      json_str_output := obj_leave.to_clob;
  end;

  procedure get_breakdiscipline(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_breakdiscipline(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_breakdiscipline(json_str_output out clob) is
    obj_data            json_object_t;
    obj_row_punsh       json_object_t;
    obj_punsh           json_object_t;
    obj_tattpre4        json_object_t;
    obj_row_tattpre4    json_object_t;

    v_rcnt_punsh    number := 0;
    v_rcnt_table4   number := 0;
    v_codpunsh      tattpre3.codpunsh%type;
    v_dteeffec      tattpreh.dteeffec%type;
    v_flgAdd        boolean;

    cursor c1 is
        select *
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec = v_dteeffec;

    cursor c_tattpre3 is
        select *
          from tattpre3
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
      order by codpunsh;

    cursor c_tattpre4 is
        select *
          from tattpre4
         where codcompy = p_codcompy
           and dteeffec = v_dteeffec
           and codaplvl = p_codaplvl
           and codpunsh = v_codpunsh
      order by numseq;
  begin
    obj_data := json_object_t();
    begin
        select max(dteeffec)
          into v_dteeffec
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec <= p_dteeffec;
    exception when others then
        v_dteeffec := null;
    end;

    if v_dteeffec is null then
        begin
            select min(dteeffec)
              into v_dteeffec
              from tattpreh
             where codcompy = p_codcompy
               and codaplvl = p_codaplvl
               and dteeffec > p_dteeffec;
        exception when others then
            v_dteeffec := null;
        end;
    end if;

    obj_row_punsh := json_object_t();
    obj_data.put('coderror', '200');
    if v_dteeffec is null then
        obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
        obj_data.put('flgDisabled', false);
        obj_data.put('flg', 'add');
        obj_data.put('scorfpunsh', '');
        obj_data.put('table', obj_row_punsh);
    else
        for r1 in c1 loop
            if p_dteeffec < trunc(sysdate) then
                obj_data.put('dteeffec', to_char(v_dteeffec,'dd/mm/yyyy'));
                obj_data.put('flgDisabled', true);
                obj_data.put('flg', '');
                obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
                v_flgAdd := false;
            else
                obj_data.put('dteeffec', to_char(p_dteeffec,'dd/mm/yyyy'));
                obj_data.put('flgDisabled', false);
                if v_dteeffec = p_dteeffec then
                    obj_data.put('flg', 'edit');
                    v_flgAdd    := false;
                else
                    obj_data.put('flg', 'add');
                    v_flgAdd    := true;
                end if;
            end if;
--            if v_dteeffec = p_dteeffec then
--                if v_dteeffec < trunc(sysdate) then
--                    obj_data.put('flgDisabled', true);
--                    obj_data.put('flg', '');
--                    obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
--                else
--                    obj_data.put('flgDisabled', false);
--                    obj_data.put('flg', 'edit');
--                end if;
--            else
--                obj_data.put('flgDisabled', true);
--                obj_data.put('flg', '');
--                obj_data.put('msgerror', replace(get_error_msg_php('HR1501',global_v_lang),'@#$%400',null));
--            end if;

            obj_data.put('scorfpunsh', r1.scorfpunsh);

            v_rcnt_punsh  := 0;
            for r_tattpre3 in c_tattpre3 loop
              v_rcnt_punsh    := v_rcnt_punsh + 1;
              obj_punsh       := json_object_t();
              v_codpunsh      := r_tattpre3.codpunsh;
              obj_punsh.put('codpunsh', r_tattpre3.codpunsh);
              obj_punsh.put('desc_codpunsh', get_tcodec_name('TCODPUNH', r_tattpre3.codpunsh, global_v_lang));
              obj_punsh.put('desc_unit', get_tlistval_name('FLGUNIT','2',global_v_lang));
              obj_punsh.put('flgAdd', v_flgAdd);
              obj_row_tattpre4    := json_object_t();
              v_rcnt_table4       := 0;
              for r_tattpre4 in c_tattpre4 loop
                  v_rcnt_table4   := v_rcnt_table4 + 1;
                  obj_tattpre4    := json_object_t();
                  obj_tattpre4.put('tmp_numseq', r_tattpre4.numseq);
                  obj_tattpre4.put('qtymin', r_tattpre4.qtymin);
                  obj_tattpre4.put('qtymax', r_tattpre4.qtymax);
                  obj_tattpre4.put('scoreded', r_tattpre4.scoreded);
                  obj_tattpre4.put('flgsal_', r_tattpre4.flgsal);
                  obj_tattpre4.put('flgsal', r_tattpre4.flgsal);
                  obj_tattpre4.put('flgbonus_', r_tattpre4.flgbonus);
                  obj_tattpre4.put('flgbonus', r_tattpre4.flgbonus);
                  obj_tattpre4.put('pctdedbonus', r_tattpre4.pctdedbonus);
                  obj_tattpre4.put('pctdedsal', r_tattpre4.pctdedsal);
                  obj_tattpre4.put('flgAdd', v_flgAdd);
                  obj_row_tattpre4.put(to_char(v_rcnt_table4-1), obj_tattpre4);
              end loop;
              obj_punsh.put('table', obj_row_tattpre4);
              obj_row_punsh.put(to_char(v_rcnt_punsh-1), obj_punsh);
            end loop;
            obj_data.put('table', obj_row_punsh);
        end loop;
    end if;
    json_str_output := obj_data.to_clob;
  end;
  procedure get_punsh(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_punsh(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_punsh(json_str_output out clob) is
    obj_punsh           json_object_t;
    obj_tattpre4        json_object_t;
    obj_row_tattpre4    json_object_t;
    v_rcnt_table4       number := 0;
    v_dteeffec          tattpreh.dteeffec%type;

    cursor c_tattpre4 is
        select *
          from tattpre4
         where codcompy = p_codcompy
           and dteeffec = p_dteeffec
           and codaplvl = p_codaplvl
           and codpunsh = p_codpunsh
      order by numseq;
  begin
      begin
        select max(dteeffec)
          into v_dteeffec
          from tattpreh
         where codcompy = p_codcompy
           and codaplvl = p_codaplvl
           and dteeffec <= p_dteeffec;
      exception when others then
        v_dteeffec := p_dteeffec;
      end;
      if v_dteeffec is null then
        v_dteeffec := p_dteeffec;
      end if;

      obj_punsh := json_object_t();
      obj_punsh.put('coderror', '200');
      obj_punsh.put('codpunsh', p_codpunsh);
      obj_punsh.put('desc_codpunsh', get_tcodec_name('TCODPUNH', p_codpunsh, global_v_lang));
      obj_punsh.put('desc_unit', get_tlistval_name('FLGUNIT','2',global_v_lang));

      obj_row_tattpre4    := json_object_t();
      v_rcnt_table4       := 0;
      for r_tattpre4 in c_tattpre4 loop
          v_rcnt_table4   := v_rcnt_table4 + 1;
          obj_tattpre4    := json_object_t();
          obj_tattpre4.put('tmp_numseq', r_tattpre4.numseq);
          obj_tattpre4.put('qtymin', r_tattpre4.qtymin);
          obj_tattpre4.put('qtymax', r_tattpre4.qtymax);
          obj_tattpre4.put('scoreded', r_tattpre4.scoreded);
          obj_tattpre4.put('flgsal_', r_tattpre4.flgsal);
          obj_tattpre4.put('flgsal', r_tattpre4.flgsal);
          obj_tattpre4.put('flgbonus_', r_tattpre4.flgbonus);
          obj_tattpre4.put('flgbonus', r_tattpre4.flgbonus);
          obj_tattpre4.put('pctdedbonus', r_tattpre4.pctdedbonus);
          obj_tattpre4.put('pctdedsal', r_tattpre4.pctdedsal);
          obj_row_tattpre4.put(to_char(v_rcnt_table4-1), obj_tattpre4);
        end loop;
      obj_punsh.put('table', obj_row_tattpre4);
      json_str_output := obj_punsh.to_clob;
  end;

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcompy is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcompy');
      return;
    end if;
    if p_codcompy is not null then
      begin
        select codcompy
        into   p_codcompy
        from   tcompny
        where  codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
        return;
      end;
    end if;
    error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
    if error_secur is not null then
      param_msg_error := error_secur;
      return;
    end if;
    if p_codaplvl is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codaplvl');
      return;
    end if;
    if p_codaplvl is not null then
      begin
        select codcodec
        into   p_codaplvl
        from   tcodaplv
        where  codcodec = p_codaplvl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODAPLV');
        return;
      end;
    end if;
  end;

  procedure check_save is
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    v_codempid  temploy1.codempid%type;
    v_flgsecu   boolean;
    v_zupdsal   varchar2(400 char);
    v_staemp    temploy1.staemp%type;
  begin
  null;
    if  p_flg ='add' then
        if p_dtereq < trunc(sysdate) then
            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
            return;
        end if;
    end if;

    if p_codemprq is not null then
        begin
            select codempid
              into v_codempid
              from temploy1
             where codempid = p_codemprq;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

        v_flgsecu := secur_main.secur2(p_codemprq,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codemprq;

        if v_staemp = '9' then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        elsif v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            return;
        end if;
    end if;
  end;

  procedure chack_grade_dup(json_input in json_object_t, chkDup out boolean ) as
    json_obj    json_object_t;
    v_chk       boolean := true;
    v_row       json_object_t;
    v_qtymin    number;
    v_qtymax    number;
    v_row2      json_object_t;
    v_qtymin2   number;
    v_qtymax2   number;
    vc_row      number;
  begin
    json_obj := json_input;
  for i in 0..json_obj.get_size-1 loop
    v_row        := json_object_t();
    v_row        := hcm_util.get_json_t(json_obj,to_char(i));
    v_qtymin     := to_number(hcm_util.get_string_t(v_row,'qtymin'));
    v_qtymax     := to_number(hcm_util.get_string_t(v_row,'qtymax'));
    vc_row       := i;

    if v_qtymin > v_qtymax then
      chkDup := false;
      exit;
    end if;

      for x in 0..json_obj.get_size-1 loop
       if vc_row <> x then
        v_row2        := json_object_t();
        v_row2        := hcm_util.get_json_t(json_obj,to_char(x));
        v_qtymin2     := to_number(hcm_util.get_string_t(v_row2,'qtymin'));
        v_qtymax2     := to_number(hcm_util.get_string_t(v_row2,'qtymax'));

        if v_qtymin2 > v_qtymax2 then
          chkDup := false;
          exit;
        end if;
          if v_qtymin2 between v_qtymin and  v_qtymax-1 then
            chkDup := false;
            exit;
          elsif v_qtymax2-1 between v_qtymin and  v_qtymax-1 then
            chkDup := false;
            exit;
          end if;
        end if;
      end loop;
  end loop;

  end;

  procedure save_index(json_str_input in clob, json_str_output out clob) as
    v_flg               varchar2(50);
    json_obj            json_object_t;
    v_break_json        json_object_t;
    v_leave_json        json_object_t;
    v_scorfta           tattpreh.scorfta%type;
    v_scorfpunsh        tattpreh.scorfpunsh%type;

    v_grplv_json        json_object_t;
    v_grplv_row         json_object_t;
    v_codgrplv          tattpre1.codgrplv%type;
    v_flgleave          varchar2(1);
    v_flgunit           tattpre1.flgunit%type;
    v_flgDelete         boolean;
    v_flgAdd            boolean;
    v_flgEdit           boolean;
    v_flgabsc           tattpre1.flgabsc%type;
    v_flglate           tattpre1.flglate%type;
    v_table1_json       json_object_t;
    v_table1_row        json_object_t;
    v_table2_json       json_object_t;
    v_table2_row        json_object_t;
    tb1_flgDelete       boolean;
    tb1_flgAdd          boolean;
    tb1_flgEdit         boolean;
    tb2_flgDelete       boolean;
    tb2_flgAdd          boolean;
    tb2_flgEdit         boolean;
    v_codleave          tattprelv.codleave%type;
    v_codleaveOld       tattprelv.codleave%type;
    v_numseq            tattpre2.numseq%type;
    v_qtymin            tattpre2.qtymin%type;
    v_qtymax            tattpre2.qtymax%type;
    v_scorded           tattpre2.scorded%type;
    v_flgsal            tattpre2.flgsal%type;
    v_flgbonus          tattpre2.flgbonus%type;
    v_pctdedbon         tattpre2.pctdedbon%type;
    v_pctdedsal         tattpre2.pctdedsal%type;

    v_codpunsh_json     json_object_t;
    v_codpunsh_row      json_object_t;
    v_codpunsh          tattpre3.codpunsh%type;
    chkDup              boolean;
  begin
    initial_value(json_str_input);
--    check_save;
    json_obj            := json_object_t(json_str_input);
    v_leave_json        := hcm_util.get_json_t(json_obj,'p_leave_json');
    v_break_json        := hcm_util.get_json_t(json_obj,'p_break_json');
    v_scorfta           := to_number(hcm_util.get_string_t(v_leave_json,'scorfta'));
    v_scorfpunsh        := to_number(hcm_util.get_string_t(v_break_json,'scorfpunsh'));
    v_grplv_json        := hcm_util.get_json_t(hcm_util.get_json_t(v_leave_json,'table'),'rows');
    v_flg               := hcm_util.get_string_t(v_leave_json,'flg');

    v_codpunsh_json     := hcm_util.get_json_t(hcm_util.get_json_t(v_break_json,'table'),'rows');

    if param_msg_error is null then
        begin
            begin
                insert into tattpreh (codcompy,codaplvl,dteeffec,scorfta,scorfpunsh,
                                      dtecreate,codcreate,dteupd,coduser)
                              values (p_codcompy,p_codaplvl,p_dteeffec,v_scorfta,v_scorfpunsh,
                                      sysdate,global_v_coduser,sysdate,global_v_coduser);
            exception when DUP_VAL_ON_INDEX then
                update tattpreh
                   set scorfta = v_scorfta,
                       scorfpunsh = v_scorfpunsh,
                       dteupd = sysdate,
                       coduser = global_v_coduser
                 where codcompy = p_codcompy
                   and codaplvl = p_codaplvl
                   and dteeffec = p_dteeffec;
            end;
            for i in 0..v_grplv_json.get_size-1 loop
                v_grplv_row     := json_object_t();
			       	  v_grplv_row     := hcm_util.get_json_t(v_grplv_json,to_char(i));
                v_codgrplv      := hcm_util.get_string_t(v_grplv_row,'codgrplv');
                v_flgleave      := hcm_util.get_string_t(v_grplv_row,'flgleave');
                v_flgDelete     := hcm_util.get_boolean_t(v_grplv_row,'flgDelete');
                v_flgAdd        := hcm_util.get_boolean_t(v_grplv_row,'flgAdd');
                v_flgEdit       := hcm_util.get_boolean_t(v_grplv_row,'flgEdit');
                v_table1_json   := hcm_util.get_json_t(hcm_util.get_json_t(v_grplv_row,'table1'),'rows');
                v_table2_json   := hcm_util.get_json_t(hcm_util.get_json_t(v_grplv_row,'table2'),'rows');

                chack_grade_dup(v_table2_json, chkDup);

                if not chkDup then
                   param_msg_error := get_error_msg_php('HR2880',global_v_lang);
                   json_str_output := get_response_message('400',param_msg_error,global_v_lang);
                   return;
                end if;

                if v_flgleave = '1' then
                    v_flgunit   := '1';
                    v_flgabsc   := 'N';
                    v_flglate   := 'N';
                elsif v_flgleave = '2' then
                    v_flgunit   := '1';
                    v_flgabsc   := 'Y';
                    v_flglate   := 'N';
                else
                    v_flgunit   := '2';
                    v_flgabsc   := 'N';
                    v_flglate   := 'Y';
                end if;

                if v_flgAdd then
                    insert into tattpre1 (codcompy,codaplvl,dteeffec,codgrplv,flgunit,
                                          flgabsc,flglate,dtecreate,codcreate,dteupd,coduser)
                                  values (p_codcompy,p_codaplvl,p_dteeffec,v_codgrplv,v_flgunit,
                                          v_flgabsc,v_flglate,sysdate,global_v_coduser,sysdate,global_v_coduser);

                    for i in 0..v_table1_json.get_size-1 loop
                        v_table1_row     := json_object_t();
                        v_table1_row     := hcm_util.get_json_t(v_table1_json,to_char(i));
                        tb1_flgDelete    := hcm_util.get_boolean_t(v_table1_row,'flgDelete');
                        tb1_flgAdd       := hcm_util.get_boolean_t(v_table1_row,'flgAdd');
                        tb1_flgEdit      := hcm_util.get_boolean_t(v_table1_row,'flgEdit');
                        v_codleave       := hcm_util.get_string_t(v_table1_row,'codleave');
                        if not tb1_flgDelete then
                            insert into tattprelv (codcompy,codaplvl,dteeffec,codgrplv,codleave,
                                                   dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codgrplv,v_codleave,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        end if;
                    end loop;
                    v_numseq := 0;
                    for i in 0..v_table2_json.get_size-1 loop
                        v_table2_row        := json_object_t();
                        v_table2_row        := hcm_util.get_json_t(v_table2_json,to_char(i));
                        tb2_flgDelete       := hcm_util.get_boolean_t(v_table2_row,'flgDelete');
                        tb2_flgAdd          := hcm_util.get_boolean_t(v_table2_row,'flgAdd');
                        tb2_flgEdit         := hcm_util.get_boolean_t(v_table2_row,'flgEdit');
                        v_qtymin            := to_number(hcm_util.get_string_t(v_table2_row,'qtymin'));
                        v_qtymax            := to_number(hcm_util.get_string_t(v_table2_row,'qtymax'));
                        v_scorded           := to_number(hcm_util.get_string_t(v_table2_row,'scorded'));
                        v_flgsal            := hcm_util.get_string_t(v_table2_row,'flgsal');
                        v_flgbonus          := hcm_util.get_string_t(v_table2_row,'flgbonus');
                        v_pctdedbon         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedbon'));
                        v_pctdedsal         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedsal'));

                        if not tb2_flgDelete or tb2_flgAdd then
                            v_numseq    := v_numseq + 1;
                            insert into tattpre2 (codcompy,codaplvl,dteeffec,codgrplv,numseq,
                                                  qtymin,qtymax,scorded,flgsal,flgbonus,
                                                  pctdedbon,pctdedsal,
                                                  dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codgrplv,
                                                   v_numseq,v_qtymin,v_qtymax,v_scorded,v_flgsal,v_flgbonus,
                                                   v_pctdedbon,v_pctdedsal,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        end if;
                    end loop;
                elsif v_flgDelete then
                    begin
                        delete tattpre1
                         where codcompy = p_codcompy
                           and codaplvl = p_codaplvl
                           and dteeffec = p_dteeffec
                           and codgrplv = v_codgrplv;
                    exception when others then
                        null;
                    end;

                    begin
                        delete tattprelv
                         where codcompy = p_codcompy
                           and codaplvl = p_codaplvl
                           and dteeffec = p_dteeffec
                           and codgrplv = v_codgrplv;
                    exception when others then
                        null;
                    end;

                    begin
                        delete tattpre2
                         where codcompy = p_codcompy
                           and codaplvl = p_codaplvl
                           and dteeffec = p_dteeffec
                           and codgrplv = v_codgrplv;
                    exception when others then
                        null;
                    end;
                else
                    update tattpre1
                       set flgunit = v_flgunit,
                           flgabsc = v_flgabsc,
                           flglate = v_flglate,
                           dteupd = sysdate,
                           coduser = global_v_coduser
                     where codcompy = p_codcompy
                       and codaplvl = p_codaplvl
                       and dteeffec = p_dteeffec
                       and codgrplv = v_codgrplv;

                    for i in 0..v_table1_json.get_size-1 loop
                        v_table1_row     := json_object_t();
                        v_table1_row     := hcm_util.get_json_t(v_table1_json,to_char(i));
                        tb1_flgDelete    := hcm_util.get_boolean_t(v_table1_row,'flgDelete');
                        tb1_flgAdd       := hcm_util.get_boolean_t(v_table1_row,'flgAdd');
                        tb1_flgEdit      := hcm_util.get_boolean_t(v_table1_row,'flgEdit');
                        v_codleave       := hcm_util.get_string_t(v_table1_row,'codleave');
                        v_codleaveOld    := hcm_util.get_string_t(v_table1_row,'codleaveOld');

                        if tb1_flgAdd then
                            insert into tattprelv (codcompy,codaplvl,dteeffec,codgrplv,codleave,
                                                   dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codgrplv,v_codleave,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        elsif tb1_flgEdit then
                            begin
                                update tattprelv
                                   set codleave = v_codleave,
                                       dteupd = sysdate,
                                       coduser = global_v_coduser
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codgrplv = v_codgrplv
                                   and codleave = v_codleaveOld;
                            exception when others then
                                null;
                            end;
                        elsif tb1_flgDelete then
                            begin
                                delete tattprelv
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codgrplv = v_codgrplv
                                   and codleave = v_codleaveOld;
                            exception when others then
                                null;
                            end;
                        end if;
                    end loop;
                    v_numseq := 0;
                    for i in 0..v_table2_json.get_size-1 loop
                        v_table2_row        := json_object_t();
                        v_table2_row        := hcm_util.get_json_t(v_table2_json,to_char(i));
                        tb2_flgDelete       := hcm_util.get_boolean_t(v_table2_row,'flgDelete');
                        tb2_flgAdd          := hcm_util.get_boolean_t(v_table2_row,'flgAdd');
                        tb2_flgEdit         := hcm_util.get_boolean_t(v_table2_row,'flgEdit');
                        v_qtymin            := to_number(hcm_util.get_string_t(v_table2_row,'qtymin'));
                        v_qtymax            := to_number(hcm_util.get_string_t(v_table2_row,'qtymax'));
                        v_scorded           := to_number(hcm_util.get_string_t(v_table2_row,'scorded'));
                        v_flgsal            := hcm_util.get_string_t(v_table2_row,'flgsal');
                        v_flgbonus          := hcm_util.get_string_t(v_table2_row,'flgbonus');
                        v_pctdedbon         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedbon'));
                        v_pctdedsal         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedsal'));
                        if tb2_flgAdd then
                            begin
                                select nvl(max(numseq),0)
                                  into v_numseq
                                  from tattpre2
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codgrplv = v_codgrplv;
                            exception when others then
                                v_numseq := 0;
                            end;
                            v_numseq    := nvl(v_numseq,0) + 1;
                            insert into tattpre2 (codcompy,codaplvl,dteeffec,codgrplv,numseq,
                                                  qtymin,qtymax,scorded,flgsal,flgbonus,
                                                  pctdedbon,pctdedsal,
                                                  dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codgrplv,
                                                   v_numseq,v_qtymin,v_qtymax,v_scorded,v_flgsal,v_flgbonus,
                                                   v_pctdedbon,v_pctdedsal,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        elsif tb2_flgEdit then
                            v_numseq := hcm_util.get_string_t(v_table2_row,'tmp_numseq');
                            update tattpre2
                               set qtymin = v_qtymin,
                                   qtymax = v_qtymax,
                                   scorded = v_scorded,
                                   flgsal = v_flgsal,
                                   flgbonus = v_flgbonus,
                                   pctdedbon = v_pctdedbon,
                                   pctdedsal = v_pctdedsal,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where codcompy = p_codcompy
                               and codaplvl = p_codaplvl
                               and dteeffec = p_dteeffec
                               and codgrplv = v_codgrplv
                               and numseq = v_numseq;
                        elsif tb2_flgDelete then
                            v_numseq := hcm_util.get_string_t(v_table2_row,'tmp_numseq');
                            if v_numseq is not null then
                                delete tattpre2
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codgrplv = v_codgrplv
                                   and numseq = v_numseq;
                            end if;
                        end if;
                    end loop;
                end if;
            end loop;

            for i in 0..v_codpunsh_json.get_size-1 loop
                v_codpunsh_row      := json_object_t();
				v_codpunsh_row      := hcm_util.get_json_t(v_codpunsh_json,to_char(i));
                v_codpunsh          := hcm_util.get_string_t(v_codpunsh_row,'codpunsh');
                v_flgDelete         := hcm_util.get_boolean_t(v_codpunsh_row,'flgDelete');
                v_flgAdd            := hcm_util.get_boolean_t(v_codpunsh_row,'flgAdd');
                v_flgEdit           := hcm_util.get_boolean_t(v_codpunsh_row,'flgEdit');
                v_table2_json       := hcm_util.get_json_t(hcm_util.get_json_t(v_codpunsh_row,'table'),'rows');

                if v_flgAdd then
                    insert into tattpre3 (codcompy,codaplvl,dteeffec,codpunsh,
                                          dtecreate,codcreate,dteupd,coduser)
                                  values (p_codcompy,p_codaplvl,p_dteeffec,v_codpunsh,
                                          sysdate,global_v_coduser,sysdate,global_v_coduser);
                    v_numseq := 0;
                    for i in 0..v_table2_json.get_size-1 loop
                        v_table2_row        := json_object_t();
                        v_table2_row        := hcm_util.get_json_t(v_table2_json,to_char(i));
                        tb2_flgDelete       := hcm_util.get_boolean_t(v_table2_row,'flgDelete');
                        tb2_flgAdd          := hcm_util.get_boolean_t(v_table2_row,'flgAdd');
                        tb2_flgEdit         := hcm_util.get_boolean_t(v_table2_row,'flgEdit');
                        v_qtymin            := to_number(hcm_util.get_string_t(v_table2_row,'qtymin'));
                        v_qtymax            := to_number(hcm_util.get_string_t(v_table2_row,'qtymax'));
                        v_scorded           := to_number(hcm_util.get_string_t(v_table2_row,'scoreded'));
                        v_flgsal            := hcm_util.get_string_t(v_table2_row,'flgsal');
                        v_flgbonus          := hcm_util.get_string_t(v_table2_row,'flgbonus');
                        v_pctdedbon         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedbonus'));
                        v_pctdedsal         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedsal'));

                        if not tb2_flgDelete or tb2_flgAdd then
                            v_numseq    := v_numseq + 1;
                            insert into tattpre4 (codcompy,codaplvl,dteeffec,codpunsh,numseq,
                                                  qtymin,qtymax,scoreded,flgsal,flgbonus,
                                                  pctdedbonus,pctdedsal,
                                                  dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codpunsh,
                                                   v_numseq,v_qtymin,v_qtymax,v_scorded,v_flgsal,v_flgbonus,
                                                   v_pctdedbon,v_pctdedsal,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        end if;
                    end loop;
                elsif v_flgDelete then
                    begin
                        delete tattpre3
                         where codcompy = p_codcompy
                           and codaplvl = p_codaplvl
                           and dteeffec = p_dteeffec
                           and codpunsh = v_codpunsh;
                    exception when others then
                        null;
                    end;

                    begin
                        delete tattpre4
                         where codcompy = p_codcompy
                           and codaplvl = p_codaplvl
                           and dteeffec = p_dteeffec
                           and codpunsh = v_codpunsh;
                    exception when others then
                        null;
                    end;
                else
                    v_numseq := 0;
                    for i in 0..v_table2_json.get_size-1 loop
                        v_table2_row        := json_object_t();
                        v_table2_row        := hcm_util.get_json_t(v_table2_json,to_char(i));
                        tb2_flgDelete       := hcm_util.get_boolean_t(v_table2_row,'flgDelete');
                        tb2_flgAdd          := hcm_util.get_boolean_t(v_table2_row,'flgAdd');
                        tb2_flgEdit         := hcm_util.get_boolean_t(v_table2_row,'flgEdit');
                        v_qtymin            := to_number(hcm_util.get_string_t(v_table2_row,'qtymin'));
                        v_qtymax            := to_number(hcm_util.get_string_t(v_table2_row,'qtymax'));
                        v_scorded           := to_number(hcm_util.get_string_t(v_table2_row,'scoreded'));
                        v_flgsal            := hcm_util.get_string_t(v_table2_row,'flgsal');
                        v_flgbonus          := hcm_util.get_string_t(v_table2_row,'flgbonus');
                        v_pctdedbon         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedbonus'));
                        v_pctdedsal         := to_number(hcm_util.get_string_t(v_table2_row,'pctdedsal'));
                        if tb2_flgAdd then
                            begin
                                select nvl(max(numseq),0)
                                  into v_numseq
                                  from tattpre4
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codpunsh = v_codpunsh;
                            exception when others then
                                v_numseq := 0;
                            end;
                            v_numseq    := nvl(v_numseq,0) + 1;
                            insert into tattpre4 (codcompy,codaplvl,dteeffec,codpunsh,numseq,
                                                  qtymin,qtymax,scoreded,flgsal,flgbonus,
                                                  pctdedbonus,pctdedsal,
                                                  dtecreate,codcreate,dteupd,coduser)
                                           values (p_codcompy,p_codaplvl,p_dteeffec,v_codpunsh,
                                                   v_numseq,v_qtymin,v_qtymax,v_scorded,v_flgsal,v_flgbonus,
                                                   v_pctdedbon,v_pctdedsal,
                                                   sysdate,global_v_coduser,sysdate,global_v_coduser);
                        elsif tb2_flgEdit then
                            v_numseq := hcm_util.get_string_t(v_table2_row,'tmp_numseq');
                            update tattpre4
                               set qtymin = v_qtymin,
                                   qtymax = v_qtymax,
                                   scoreded = v_scorded,
                                   flgsal = v_flgsal,
                                   flgbonus = v_flgbonus,
                                   pctdedbonus = v_pctdedbon,
                                   pctdedsal = v_pctdedsal,
                                   dteupd = sysdate,
                                   coduser = global_v_coduser
                             where codcompy = p_codcompy
                               and codaplvl = p_codaplvl
                               and dteeffec = p_dteeffec
                               and codpunsh = v_codpunsh
                               and numseq = v_numseq;
                        elsif tb2_flgDelete then
                            v_numseq := hcm_util.get_string_t(v_table2_row,'tmp_numseq');
                            if v_numseq is not null then
                                delete tattpre4
                                 where codcompy = p_codcompy
                                   and codaplvl = p_codaplvl
                                   and dteeffec = p_dteeffec
                                   and codpunsh = v_codpunsh
                                   and numseq = v_numseq;
                            end if;
                        end if;
                    end loop;
                end if;
            end loop;

            commit;
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;

        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/

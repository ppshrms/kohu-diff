--------------------------------------------------------
--  DDL for Package Body HRRC33X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC33X" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    v_chken             := hcm_secur.get_v_chken;

    p_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codpos      := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_codexam     := hcm_util.get_string_t(json_obj,'p_codexam');
    p_typtest     := hcm_util.get_string_t(json_obj,'p_typtest');
    p_typetest    := hcm_util.get_string_t(json_obj,'p_typetest');
    p_dtetest     := to_date(hcm_util.get_string_t(json_obj,'p_dtetest'), 'dd/mm/yyyy');
    p_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is
    v_chkdata   varchar2(10 char);
    v_codcomp   tcenter.codcomp%type;
    v_codpos    tpostn.codpos%type;
  begin
    begin
      select codcomp into v_codcomp
        from tcenter
       where codcomp = get_compful(p_codcomp);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
      return;
    end;
    if not secur_main.secur7(p_codcomp, global_v_coduser) then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    begin
      select codpos into v_codpos
        from tpostn
       where codpos = p_codpos;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TPOSTN');
      return;
    end;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;
  end check_index;

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         boolean;
    v_stasign       tapplcfm.stasign%type;
    v_namimage      tapplinf.namimage%type;
    v_countpass     number := 0;
    v_countfail     number := 0;
    cursor c1 is
      select numappl, dteappoi , qtyfscore , qtyscoreavg, codasapl , b.codcomp, a.codexam
        from tappoinf a , treqest2 b
       where a.numreqrq = b.numreqst
         and a.codposrq = b.codpos ----
         and codasapl   is not null ----
         and b.codcomp  like p_codcomp||'%'
         and a.codposrq = nvl(p_codpos, codposrq)
         and a.dteappoi between p_dtestrt and p_dteend
         and a.typappty = '1'
         and a.qtyscoreavg is not null
       order by a.numappl ;
  begin
    obj_row := json_object_t();

    for r1 in c1 loop
      begin
        select namimage into v_namimage
        from tapplinf
        where numappl = r1.numappl;
      exception when no_data_found then
        v_namimage := '';
      end;
      v_flgdata := 'Y';
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', v_namimage);
      obj_data.put('numappl', r1.numappl);
      obj_data.put('codempid', r1.numappl);
      obj_data.put('desc_codempid', get_tapplinf_name (r1.numappl, global_v_lang ));
      obj_data.put('codexam', r1.codexam);
      obj_data.put('desc_codexam', get_tcodec_name ('TCODEXAM', r1.codexam, global_v_lang ));
      obj_data.put('qtyscore', r1.qtyscoreavg);
      obj_data.put('scorfull', r1.qtyfscore);
      obj_data.put('dteappoi', to_char(r1.dteappoi, 'dd/mm/yyyy'));
      obj_data.put('result', get_tlistval_name('CODASAPL', r1.codasapl,global_v_lang));
      if r1.codasapl = 'P' then
        v_countpass := v_countpass + 1;
      else
        v_countfail := v_countfail + 1;
      end if;
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    if v_flgdata = 'N' then
      param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'tappoinf');
      json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    else
      obj_result := json_object_t();
      obj_result.put('coderror', '200');
      obj_result.put('qtyall', v_rcnt);
      obj_result.put('qtypass', v_countpass);
      obj_result.put('qtynpass', v_countfail);
      obj_result.put('table', obj_row);
      json_str_output := obj_result.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
  --
  procedure post_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      format_text_json(json_str_input, v_rec_tran, v_rec_err);
    end if;
    --
    obj_row    := json_object_t();
    obj_result := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('rec_tran', v_rec_tran);
    obj_row.put('rec_err', v_rec_err);
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    --
    if p_numseq.exists(p_numseq.first) then
      for i in p_numseq.first .. p_numseq.last
      loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('text', p_text(i));
        obj_data.put('error_code', p_error_code(i));
        obj_data.put('numseq', p_numseq(i));
        obj_result.put(to_char(v_rcnt-1),obj_data);
      end loop;
    end if;

    obj_row.put('datadisp', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json          json_object_t;
    param_data          json_object_t;
    param_column        json_object_t;
    param_column_row    json_object_t;
    param_json_row      json_object_t;
    --
    data_file           varchar2(6000);
    v_column            number := 7;
    v_error             boolean;
    v_err_code          varchar2(1000);
    v_err_filed         varchar2(1000);
    v_err_table         varchar2(20);
    i                   number;
    j                   number;
    k                   number;
    v_cnt               number := 0;
    v_num               number := 0;
    v_chkexist          number := 0;

    type text is table of varchar2(4000) index by binary_integer;
    v_text              text;
    v_filed             text;
    v_numseq            number;
    v_numappl           tappoinf.numappl%type;
    v_numreqrq		      tappoinf.numreqrq%type;
    v_codposrq		      tappoinf.codposrq%type;
    v_numapseq		      tappoinf.numapseq%type;
    v_codexam		        tappoinf.codexam%type;
    v_qtyfscore		      tappoinf.qtyfscore%type;
    v_qtyscoreavg	      tappoinf.qtyscoreavg%type;
    v_codasapl	        tappoinf.codasapl%type;
    v_codcomp           tapplinf.codcompl%type;
    cursor c_texampos is
      select scorpass
        from texampos
       where v_codcomp like codcomp||'%'
         and codpos    = v_codposrq
         and codexam   = v_codexam
      order by codcomp desc;
  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
        -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;

    for r1 in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        v_numseq    := v_numseq;
        v_error 	  := false;

        <<cal_loop>> loop
          v_text(1)   := hcm_util.get_string_t(param_json_row,'numappl');
          v_text(2)   := hcm_util.get_string_t(param_json_row,'numreqrq');
          v_text(3)   := hcm_util.get_string_t(param_json_row,'codposrq');
          v_text(4)   := hcm_util.get_string_t(param_json_row,'numapseq');
          v_text(5)   := hcm_util.get_string_t(param_json_row,'codexam');
          v_text(6)   := hcm_util.get_string_t(param_json_row,'qtyfscore');
          v_text(7)   := hcm_util.get_string_t(param_json_row,'qtyscoreavg');

          data_file := null;
          for i in 1..7 loop
            data_file := v_text(1)||', '||v_text(2)||', '||v_text(3)||', '||v_text(4)||', '||v_text(5)||', '||v_text(6)||', '||v_text(7);
            if v_text(i) is null then
--              if i = 1 or i = 2 or i = 6 or i = 7 then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                exit cal_loop;
--              end if;
            end if;
          end loop;
          -- 1. numappl
          i := 1;
          if length(v_text(i)) > 10 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_numappl := v_text(i);
          -- 2. numreqrq
          i := 2;
          if length(v_text(i)) > 15 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_numreqrq := v_text(i);

          -- 3. codposrq
          i := 3;
          if length(v_text(i)) > 4 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_codposrq := nvl(v_text(i),'%');

          -- 4. numapseq
          i := 4;
          if length(v_text(i)) > 2 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          elsif not regexp_like(v_text(i), '^[[:digit:]]+$') then
            v_error	 	  := true;
            v_err_code  := 'CO0020';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_numapseq := nvl(v_text(i),'%');

          -- 5. codexam
          i := 5;
          if length(v_text(i)) > 4 then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_codexam := nvl(v_text(i),'%');

          -- 6. qtyfscore
          i := 6;
          if not regexp_like(v_text(i), '^[[:digit:]]+$') then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_qtyfscore := v_text(i);

          -- 7. qtyscoreavg
          i := 7;
          if not regexp_like(v_text(i), '^[[:digit:]]+$') then
            v_error     := true;
            v_err_code  := 'HR6591';
            v_err_filed := v_filed(i);
            exit cal_loop;
          end if;
          v_qtyscoreavg := v_text(i);

          if v_qtyscoreavg > v_qtyfscore then
            v_error     := true;
            v_err_code  := 'HR2020';
            v_err_filed := v_filed(6);
            exit cal_loop;
          end if;

          begin
            select count(*) into v_chkexist
              from tappoinf
             where numappl = v_numappl
               and numreqrq = v_numreqrq
               and codposrq = v_codposrq
               and numapseq = v_numapseq;
          end;
          if v_chkexist = 0 then
            v_error     := true;
            v_err_code  := 'HR2055';
            v_err_table := 'TAPPOINF';
--            v_err_filed := v_filed(1);
            exit cal_loop;
          end if;
          exit cal_loop;
        end loop;
--
        if not v_error then
          v_rec_tran := v_rec_tran + 1;

          v_codcomp := null;
          begin
            select codcompl into v_codcomp
              from tapplinf
             where numappl  = v_numappl;
          exception when no_data_found then null;
          end;
          --v_codasapl := null;
          v_codasapl := 'F';
          for i in c_texampos loop
            if v_qtyscoreavg >= i.scorpass then
              v_codasapl := 'P';
            --else
              --v_codasapl := 'F';
            end if;
            exit;
          end loop;

          begin
            select count(*) into v_chkexist
              from tappoinf
             where numappl  = v_numappl
               and numreqrq = v_numreqrq
               and codposrq = v_codposrq
               and numapseq = v_numapseq;
          end;
          if v_chkexist = 0 then
            begin
              insert into tappoinf(numappl,numreqrq,codposrq,numapseq,codexam,qtyfscore,qtyscoreavg,codasapl,
                                   codcreate,coduser)
              values (v_numappl,v_numreqrq,v_codposrq,v_numapseq,v_codexam,v_qtyfscore,v_qtyscoreavg,v_codasapl,
                      global_v_coduser, global_v_coduser);
            end;
          else
            begin
              update tappoinf
                 set codexam     = v_codexam,
                     qtyfscore   = v_qtyfscore,
                     qtyscoreavg = v_qtyscoreavg,
                     codasapl    = v_codasapl
               where numappl = v_numappl
                 and numreqrq = v_numreqrq
                 and codposrq = v_codposrq
                 and numapseq = v_numapseq;
            end;
          end if;
        else  --if error
          v_rec_error      := v_rec_error + 1;
          v_cnt            := v_cnt+1;
          -- puch value in array
          p_text(v_cnt)       := data_file;
          p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
          p_numseq(v_cnt)     := r1+1;
        end if;
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;
  procedure get_index_popup(json_str_input clob, json_str_output out clob) is
  begin
        initial_value(json_str_input);
        gen_index_popup(json_str_output);
        null;
  end get_index_popup;
  procedure gen_index_popup(json_str_output out clob) is
        v_count             number;
        v_qtydone           number;
        v_score             number;
        v_rcnt              number  := 0;
        json_obj_data       json_object_t;
        json_obj_row        json_object_t;
        json_response       json_object_t;

        cursor c1 is
            select codquest, decode(global_v_lang, '101',namsubje, '102',namsubj2, '103',namsubj3, '104',namsubj4,
                '105',namsubj5,namsubje) as numsubj, qtyexam, qtyscore
            from TVQUEST
            where codexam = p_codexam
--            where codexam = 'BOY2'
            order by codquest;
  begin
        select count(codempid) into v_count
        from ttestemp
        where codempid = p_codempid
        and codexam = p_codexam
        and typtest = p_typtest
        and typetest = p_typetest
        and dtetest = p_dtetest;
--        where codempid = 'K000053002'
--        and codexam = 'KAI2'
--        and typtest = 1
--        and typetest = 1
--        and dtetest = to_date('29/01/2021', 'dd/mm/yyyy');

        if v_count <= 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang, 'TTESTEMP');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;

        json_obj_row        := json_object_t();
        json_response       := json_object_t();
        for r1 in c1 loop
            v_rcnt := v_rcnt + 1;
            json_obj_data       := json_object_t();
            select count(codempid), nvl(sum(score), 0)
                into v_qtydone, v_score
                from ttestempd
                where codempid    = p_codempid
                and codexam       = p_codexam
                and dtetest       = p_dtetest
                and typtest       = p_typtest
                and typetest      = p_typetest
                and codquest      = r1.codquest
                and(answer is not null or numans is not null);
            json_obj_data.put('numsubj', r1.numsubj);
            json_obj_data.put('qtyexam', r1.qtyexam);
            json_obj_data.put('qtydone', v_qtydone);
            json_obj_data.put('score', v_score);
            json_obj_row.put('coderror', 200);

            json_obj_row.put(to_char(v_rcnt - 1), json_obj_data);
        end loop;

        json_response.put('coderror', 200);
        json_response.put('codexam', p_codexam);
        json_response.put('desc_codexam', get_tcodec_name ('TCODEXAM', p_codexam, global_v_lang));
        json_response.put('tvtest_name', get_tvtest_name ( p_codexam, global_v_lang)); -- softberry || 29/03/2023 || #9257
        json_response.put('table', json_obj_row);

        json_str_output := json_response.to_clob;
  end gen_index_popup;
  --
end hrrc33x;

/

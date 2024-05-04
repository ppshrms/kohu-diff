--------------------------------------------------------
--  DDL for Package Body HRAP18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP18E" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_codcompy    := hcm_util.get_string_t(json_obj,'p_codcompy');
    b_index_codaplvl    := hcm_util.get_string_t(json_obj,'p_codaplvl'); --03/03/2021

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --Redmine #5552
  function get_codaplvl(p_dteyreap in number,
                        p_numseq   in number,
                        p_codempid in varchar2) return varchar2 is
    v_codaplvl  tstdisd.codaplvl%type;
  begin
      begin
           select codaplvl into v_codaplvl
            from tempaplvl
           where dteyreap = p_dteyreap
             and numseq  = p_numseq
             and codempid = p_codempid;
      exception when others then
        v_codaplvl := null;
      end;

    return v_codaplvl;
  exception when value_error then return Null;
  end;
  --Redmine #5552

  procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_rowC        json_object_t;
    obj_data        json_object_t;
    obj_dataC       json_object_t;
    obj_result      json_object_t;

    v_rcnt          number := 0;
    v_rcnt2         number := 0;
    v_response      varchar2(1000 char);
    v_flgAdd        boolean := false;
    v_dteyreap      tstdisd.dteyreap%type;
    v_codcomp       tstdisd.codcomp%type;

    cursor c1 is
      select codcomp,dteyreap
        from tstdisd
       where codcomp  like b_index_codcompy||'%'
         and codaplvl = b_index_codaplvl --03/03/2021
       group by dteyreap, codcomp
       order by dteyreap desc;

    cursor c2 is
      select codcomp, numtime, flgtypap, dteapstr, dteapend, dtebhstr, dtebhend, dteaplast, qtyalert1, qtyalert2, flgsal
        from tstdisd
       where codcomp = v_codcomp
         and dteyreap = v_dteyreap
         and codaplvl = b_index_codaplvl --03/03/2021
       order by dteyreap desc;

  begin
    obj_row := json_object_t();
    for i in c1 loop
      v_rcnt := v_rcnt+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('year', i.dteyreap);
      obj_data.put('codcomp', i.codcomp);
      v_dteyreap  := i.dteyreap;
      v_codcomp   := i.codcomp;

      v_rcnt2 := 0;
      obj_rowC := json_object_t();
      for r2 in c2 loop
        obj_dataC := json_object_t();
        obj_dataC.put('coderror', '200');
        obj_dataC.put('numtime', nvl(r2.numtime,''));
        obj_dataC.put('flgtypap', nvl(r2.flgtypap,''));
        obj_dataC.put('dteapstr', to_char(nvl(r2.dteapstr,''),'dd/mm/yyyy'));
        obj_dataC.put('dteapend', to_char(nvl(r2.dteapend,''),'dd/mm/yyyy'));
        obj_dataC.put('dtebhstr', to_char(nvl(r2.dtebhstr,''),'dd/mm/yyyy'));
        obj_dataC.put('dtebhend', to_char(nvl(r2.dtebhend,''),'dd/mm/yyyy'));
        obj_dataC.put('dteaplast', to_char(nvl(r2.dteaplast,''),'dd/mm/yyyy'));
        obj_dataC.put('qtyalert1', nvl(r2.qtyalert1,''));
        obj_dataC.put('qtyalert2', nvl(r2.qtyalert2,''));
        obj_dataC.put('flgsal', nvl(r2.flgsal,''));

        obj_rowC.put(to_char(v_rcnt2),obj_dataC);
        v_rcnt2 := v_rcnt2 + 1;
      end loop;
      obj_data.put('children', obj_rowC);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure check_index is
     v_codcompy   tcompny.codcompy%type;
     v_codaplvl   tstdisd.codaplvl%type;
  begin

    if b_index_codcompy is not null then
      begin
        select codcompy into v_codcompy
          from tcompny
         where codcompy = b_index_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCOMPNY');
        return;
      end;
      if not secur_main.secur7(b_index_codcompy, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    --<<03/03/2021
    if b_index_codaplvl is not null then
      begin
        select codcodec into v_codaplvl
          from tcodaplv
         where codcodec = b_index_codaplvl;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCODAPLV');
        return;
      end;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    -->>03/03/2021
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
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
  end;

  --
  procedure check_save(json_str_input in clob) is
    param_json        json_object_t;
    param_json_row    json_object_t;
    obj_children      json_object_t;
    obj_row_children  json_object_t;

    v_chkDup	        number := 0;
    v_flgP	        varchar2(1000 char);
    v_flgC	        varchar2(1000 char);
    v_dteyreap      tstdisd.dteyreap%type;
    v_dteyreapOld   tstdisd.dteyreap%type;
    v_codcomp       tstdisd.codcomp%type;
    v_no	          tstdisd.numtime%type;
    v_evalperodtest	tstdisd.dteapstr%type;
    v_evalperodten	tstdisd.dteapend%type;
    v_behvrperodtest	  tstdisd.dtebhstr%type;
    v_behvrperodten	    tstdisd.dtebhend%type;
    v_lstdyassrecrd	    tstdisd.dteaplast%type;
    v_numdyadvncedtest	tstdisd.qtyalert1%type;
    v_numdyadvncedten	  tstdisd.qtyalert2%type;
    v_calslryincres	    tstdisd.flgsal%type;
    v_flgtypap	        tstdisd.flgtypap%type;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flgP          := hcm_util.get_string_t(param_json_row,'flg');
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      v_dteyreap      := hcm_util.get_string_t(param_json_row,'year');
      obj_children    := hcm_util.get_json_t(param_json_row,'children');
      for j in 0..obj_children.get_size-1 loop
        obj_row_children    := hcm_util.get_json_t(obj_children,to_char(j));
        v_flgC              := hcm_util.get_string_t(obj_row_children,'flg');
        v_no		  			    := hcm_util.get_string_t(obj_row_children,'no');
        v_evalperodtest		  := to_date(hcm_util.get_string_t(obj_row_children,'evalperodtest'),'dd/mm/yyyy');
        v_evalperodten		  := to_date(hcm_util.get_string_t(obj_row_children,'evalperodten'),'dd/mm/yyyy');
        v_behvrperodtest		:= to_date(hcm_util.get_string_t(obj_row_children,'behvrperodtest'),'dd/mm/yyyy');
        v_behvrperodten		  := to_date(hcm_util.get_string_t(obj_row_children,'behvrperodten'),'dd/mm/yyyy');
        v_lstdyassrecrd		  := to_date(hcm_util.get_string_t(obj_row_children,'lstdyassrecrd'),'dd/mm/yyyy');
        v_numdyadvncedtest	:= hcm_util.get_string_t(obj_row_children,'numdyadvncedtest');
        v_numdyadvncedten		:= hcm_util.get_string_t(obj_row_children,'numdyadvncedten');
        v_calslryincres		  := hcm_util.get_string_t(obj_row_children,'calslryincres');
        v_flgtypap		  		:= hcm_util.get_string_t(obj_row_children,'flgtypap');

--<< user20 Date: 11/09/2021  #5525
        if v_numdyadvncedtest < v_numdyadvncedten then
            param_msg_error := get_error_msg_php('HR2020', global_v_lang);
            return;
        end if;
--<< user20 Date: 11/09/2021  #5525

--        begin
--          select count(*) into v_chkDup
--            from tstdisd
--           where codcomp  = v_codcomp
--             and dteyreap = v_dteyreap
--             and codaplvl = b_index_codaplvl --03/03/2021
--             and (v_evalperodtest between dteapstr and dteapend or v_evalperodten between dteapstr and dteapend )
--             and numtime <> v_no;
--        end;
--        if v_chkDup > 0 then
--          param_msg_error := get_error_msg_php('PY0007', global_v_lang);
--          return;
--        end if;
--
--        begin
--          select count(*) into v_chkDup
--            from tstdisd
--           where codcomp = v_codcomp
--             and dteyreap = v_dteyreap
--             and codaplvl = b_index_codaplvl
--             and (v_behvrperodtest between dtebhstr and dtebhend
--                  or v_behvrperodten between dtebhstr and dtebhend)
--             and numtime <> v_no;
--        end;
--        if v_chkDup > 0 then
--          param_msg_error := get_error_msg_php('PY0007', global_v_lang);
--          return;
--        end if;
      end loop;
    end loop;
  end;

  procedure check_after_save(json_str_input in clob) is
    param_json          json_object_t;
    param_json_row      json_object_t;
    obj_children        json_object_t;
    obj_row_children    json_object_t;

    v_chkDup	        number := 0;
    v_flgP	            varchar2(1000 char);
    v_flgC	            varchar2(1000 char);
    v_dteyreap          tstdisd.dteyreap%type;
    v_dteyreapOld       tstdisd.dteyreap%type;
    v_codcomp           tstdisd.codcomp%type;
    v_no	            tstdisd.numtime%type;
    v_evalperodtest	    tstdisd.dteapstr%type;
    v_evalperodten	    tstdisd.dteapend%type;
    v_behvrperodtest	tstdisd.dtebhstr%type;
    v_behvrperodten	    tstdisd.dtebhend%type;
    v_lstdyassrecrd	    tstdisd.dteaplast%type;
    v_numdyadvncedtest	tstdisd.qtyalert1%type;
    v_numdyadvncedten	tstdisd.qtyalert2%type;
    v_calslryincres	    tstdisd.flgsal%type;
    v_flgtypap	        tstdisd.flgtypap%type;
    v_count_numtime     number;
    v_count_notcal      number;
    v_count_cal         number;
    v_count_calavg      number;
  begin
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

    for i in 0..param_json.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flgP          := hcm_util.get_string_t(param_json_row,'flg');
      v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
      v_dteyreap      := hcm_util.get_string_t(param_json_row,'year');
      obj_children    := hcm_util.get_json_t(param_json_row,'children');
      for j in 0..obj_children.get_size-1 loop
        obj_row_children        := hcm_util.get_json_t(obj_children,to_char(j));
        v_flgC                  := hcm_util.get_string_t(obj_row_children,'flg');
        v_no		  			:= hcm_util.get_string_t(obj_row_children,'no');
        v_evalperodtest		    := to_date(hcm_util.get_string_t(obj_row_children,'evalperodtest'),'dd/mm/yyyy');
        v_evalperodten		    := to_date(hcm_util.get_string_t(obj_row_children,'evalperodten'),'dd/mm/yyyy');
        v_behvrperodtest		:= to_date(hcm_util.get_string_t(obj_row_children,'behvrperodtest'),'dd/mm/yyyy');
        v_behvrperodten		    := to_date(hcm_util.get_string_t(obj_row_children,'behvrperodten'),'dd/mm/yyyy');
        v_lstdyassrecrd		    := to_date(hcm_util.get_string_t(obj_row_children,'lstdyassrecrd'),'dd/mm/yyyy');
        v_numdyadvncedtest	    := hcm_util.get_string_t(obj_row_children,'numdyadvncedtest');
        v_numdyadvncedten		:= hcm_util.get_string_t(obj_row_children,'numdyadvncedten');
        v_calslryincres		    := hcm_util.get_string_t(obj_row_children,'calslryincres');
        v_flgtypap		  		:= hcm_util.get_string_t(obj_row_children,'flgtypap');
        if v_flgC in('add','edit') then
    --<< user20 Date: 11/09/2021  #5525
            if v_numdyadvncedtest < v_numdyadvncedten then
                param_msg_error := get_error_msg_php('HR2020', global_v_lang);
                return;
            end if;
    --<< user20 Date: 11/09/2021  #5525

            begin
              select count(*) into v_chkDup
                from tstdisd
               where codcomp  = v_codcomp
                 and dteyreap = v_dteyreap
                 and codaplvl = b_index_codaplvl --03/03/2021
                 and (v_evalperodtest between dteapstr and dteapend or v_evalperodten between dteapstr and dteapend )
                 and numtime <> v_no;
            end;
            if v_chkDup > 0 then
              param_msg_error := get_error_msg_php('PY0007', global_v_lang);
              return;
            end if;

            begin
              select count(*) into v_chkDup
                from tstdisd
               where codcomp = v_codcomp
                 and dteyreap = v_dteyreap
                 and codaplvl = b_index_codaplvl
                 and (v_behvrperodtest between dtebhstr and dtebhend
                      or v_behvrperodten between dtebhstr and dtebhend)
                 and numtime <> v_no;
            end;
            if v_chkDup > 0 then
              param_msg_error := get_error_msg_php('PY0007', global_v_lang);
              return;
            end if;

              begin
                  select count(numtime)
                    into v_count_numtime
                    from tstdisd
                   where codcomp  = b_index_codcompy
                     and codaplvl = b_index_codaplvl --03/03/2021
                     and dteyreap = v_dteyreap;
              exception when others then
                v_count_numtime := 0;
              end;

              if v_count_numtime > 1 then
                  begin
                      select count(numtime)
                        into v_count_notcal
                        from tstdisd
                       where codcomp  = b_index_codcompy
                         and codaplvl = b_index_codaplvl --03/03/2021
                         and dteyreap = v_dteyreap
                         and flgsal = 'N';
                  exception when others then
                    v_count_notcal := 0;
                  end;
                  begin
                      select count(numtime)
                        into v_count_cal
                        from tstdisd
                       where codcomp  = b_index_codcompy
                         and codaplvl = b_index_codaplvl --03/03/2021
                         and dteyreap = v_dteyreap
                         and flgsal = 'Y';
                  exception when others then
                    v_count_cal := 0;
                  end;
                  begin
                      select count(numtime)
                        into v_count_calavg
                        from tstdisd
                       where codcomp  = b_index_codcompy
                         and codaplvl = b_index_codaplvl --03/03/2021
                         and dteyreap = v_dteyreap
                         and flgsal = 'A';
                  exception when others then
                    v_count_calavg := 0;
                  end;

                  if v_count_notcal = v_count_numtime or v_count_cal = v_count_numtime then
                    param_msg_error := get_error_msg_php('AP0067',global_v_lang);
                    exit;
                  elsif v_count_calavg > 0 and v_count_cal >0 then
                    param_msg_error := get_error_msg_php('AP0068',global_v_lang);
                    exit;
                  end if;
              end if;
        end if;
      end loop;
    end loop;
  end;
  --
  procedure save_index (json_str_input in clob, json_str_output out clob) as
    param_json          json_object_t;
    param_json_row      json_object_t;
    obj_children        json_object_t;
    obj_row_children    json_object_t;

    v_flgP	            varchar2(1000 char);
    v_flgC	            varchar2(1000 char);
    v_dteyreap          tstdisd.dteyreap%type;
    v_dteyreapOld       tstdisd.dteyreap%type;
    v_codcomp           tstdisd.codcomp%type;
    v_no	            tstdisd.numtime%type;
    v_evalperodtest	    tstdisd.dteapstr%type;
    v_evalperodten	    tstdisd.dteapend%type;
    v_behvrperodtest	tstdisd.dtebhstr%type;
    v_behvrperodten	    tstdisd.dtebhend%type;
    v_lstdyassrecrd	    tstdisd.dteaplast%type;
    v_numdyadvncedtest	tstdisd.qtyalert1%type;
    v_numdyadvncedten	tstdisd.qtyalert2%type;
    v_calslryincres	    tstdisd.flgsal%type;
    v_flgtypap	        tstdisd.flgtypap%type;
    v_count_numtime     number;
    v_count_notcal      number;
    v_count_cal         number;
    v_count_calavg      number;
  begin
    initial_value(json_str_input);
    check_save(json_str_input);
    param_json    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    if param_msg_error is null then
        for i in 0..param_json.get_size-1 loop
          param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
          v_flgP          := hcm_util.get_string_t(param_json_row,'flg');
          v_codcomp       := hcm_util.get_string_t(param_json_row,'codcomp');
          v_dteyreap      := hcm_util.get_string_t(param_json_row,'year');
          obj_children    := hcm_util.get_json_t(param_json_row,'children');
          for j in 0..obj_children.get_size-1 loop
            obj_row_children        := hcm_util.get_json_t(obj_children,to_char(j));
            v_flgC                  := hcm_util.get_string_t(obj_row_children,'flg');
            v_no		  			:= hcm_util.get_string_t(obj_row_children,'no');
            v_evalperodtest		    := to_date(hcm_util.get_string_t(obj_row_children,'evalperodtest'),'dd/mm/yyyy');
            v_evalperodten		    := to_date(hcm_util.get_string_t(obj_row_children,'evalperodten'),'dd/mm/yyyy');
            v_behvrperodtest		:= to_date(hcm_util.get_string_t(obj_row_children,'behvrperodtest'),'dd/mm/yyyy');
            v_behvrperodten		    := to_date(hcm_util.get_string_t(obj_row_children,'behvrperodten'),'dd/mm/yyyy');
            v_lstdyassrecrd		    := to_date(hcm_util.get_string_t(obj_row_children,'lstdyassrecrd'),'dd/mm/yyyy');
            v_numdyadvncedtest	    := hcm_util.get_string_t(obj_row_children,'numdyadvncedtest');
            v_numdyadvncedten		:= hcm_util.get_string_t(obj_row_children,'numdyadvncedten');
            v_calslryincres		    := hcm_util.get_string_t(obj_row_children,'calslryincres');
            v_flgtypap		  		:= hcm_util.get_string_t(obj_row_children,'flgtypap');
            if v_flgC = 'add' then
              begin
                insert into tstdisd(codcomp,
                                    codaplvl, --03/03/2021
                                    dteyreap,numtime,
                                    flgtypap,dteapstr,dteapend,dtebhstr,dtebhend, dteaplast,
                                    qtyalert1,qtyalert2,flgsal,
                                    codcreate,coduser)
                    values (b_index_codcompy,
                            b_index_codaplvl, --03/03/2021
                            v_dteyreap,v_no,
                            v_flgtypap,v_evalperodtest,v_evalperodten,v_behvrperodtest,v_behvrperodten,v_lstdyassrecrd,
                            v_numdyadvncedtest,v_numdyadvncedten,v_calslryincres,
                            global_v_coduser, global_v_coduser);
              exception when dup_val_on_index then
                param_msg_error := get_error_msg_php('HR2005', global_v_lang);
                json_str_output := get_response_message(null,param_msg_error,global_v_lang);
                return;
              end;
            elsif v_flgC = 'delete' then
              begin
                delete tstdisd
                 where codcomp  = b_index_codcompy
                   and codaplvl = b_index_codaplvl --03/03/2021
                   and dteyreap = v_dteyreap
                   and numtime  = v_no;
              end;
            elsif v_flgC = 'edit' then
              begin
                update tstdisd
                   set flgtypap = v_flgtypap,
                       dteapstr = v_evalperodtest,
                       dteapend = v_evalperodten,
                       dtebhstr = v_behvrperodtest,
                       dtebhend = v_behvrperodten,
                       dteaplast = v_lstdyassrecrd,
                       qtyalert1 = v_numdyadvncedtest,
                       qtyalert2 = v_numdyadvncedten,
                       flgsal = v_calslryincres,
                       dteupd  = trunc(sysdate),
                       coduser = global_v_coduser
                 where codcomp  = b_index_codcompy
                   and codaplvl = b_index_codaplvl --03/03/2021
                   and dteyreap = v_dteyreap
                   and numtime  = v_no;
              end;
            end if;
          end loop;
        end loop;
        check_after_save(json_str_input);
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end hrap18e;

/

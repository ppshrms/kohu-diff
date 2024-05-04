--------------------------------------------------------
--  DDL for Package Body HRAP3EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP3EX" as

procedure initial_value (json_str in clob) is
    json_obj        json;
begin
    v_chken             := hcm_secur.get_v_chken;

    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj,'p_lang');

    -- index params
    p_dteyreap          := to_number(hcm_util.get_string(json_obj,'p_dteyreap'));
    p_codcomp           := hcm_util.get_string(json_obj,'p_codcomp');
    p_codreq            := hcm_util.get_string(json_obj,'p_codreq');


    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

end initial_value;



procedure check_index is
    v_flgsecu		boolean;
    v_numlvl		temploy1.numlvl%type;
    v_staemp        temploy1.staemp%type;
    v_codreq        varchar2(40 char);
begin
    if p_dteyreap is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyreap');
        return;
    end if;

    if p_codcomp is null  then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
        return;
    end if;

    if p_dteyreap <= 0 then
        param_msg_error := get_error_msg_php('HR2024', global_v_lang, 'p_dteyreap');
        return;
    end if;

    b_var_codcompy   := hcm_util.get_codcomp_level(p_codcomp,1);

    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
    if param_msg_error is not null then
        return;
    end if;
    if length(p_codcomp) < 40 then
        p_codcomp := p_codcomp||'%';
    end if;

end;

procedure get_process(json_str_input in clob, json_str_output out clob) as
begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      process_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
end get_process;

procedure process_data(json_str_output out clob) as
    obj_row         json := json();
    obj_row2        json := json();
    obj_data        json;
    obj_data2       json;
    v_row           number := 0;
    v_flgpass		boolean := true;
    p_codapp        varchar2(100 char) := 'HRAP3EX';
    v_numproc       number := nvl(get_tsetup_value('QTYPARALLEL'),2);
    v_response      varchar2(4000);
    v_countemp      number := 0 ;
    v_data          varchar2(1 char) := 'N';
    v_check         varchar2(1 char) := 'Y';

    v_codpos        varchar2(100 char);
    v_typpayroll    varchar2(100 char);
    v_numlvl        number;
    v_jobgrade      varchar2(100 char);
    v_qtywork       number;

    cursor c_tstdis  is
        select grade,pctpostr,pctpoend,pctactstr,pctactend
          from tstdis
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
           and pctpostr is not null
        order by grade;

begin
    for i in c_tstdis loop
        v_data := 'Y';
        exit;
    end loop;

    if v_data = 'N' then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TSTDIS');
    end if;

    insert_data_parallel (p_codapp,global_v_coduser,v_numproc)  ;

    hrap3ex_batch.get_parameter (p_codcomp,
                                 p_dteyreap,
                                 global_v_coduser,
                                 global_v_lang);

    hrap3ex_batch.start_process('HRAP3EX',global_v_coduser,v_numproc,p_codapp)  ;

    for i in c_tstdis loop
        v_row   := v_row + 1;
        obj_data2 := json();
        obj_data2.put('coderror','200');
        v_countemp := 0;
        begin
            select count(*) into v_countemp
              from tappraism
             where dteyreap = p_dteyreap
               and codcomp  = p_codcomp
               and grade    = i.grade;
        exception when no_data_found then
            v_countemp := 0;
        end;
        obj_data2.put('numemp', v_countemp);
        obj_row2.put(to_char(v_row - 1), obj_data2);
    end loop;

    if param_msg_error is null then
        obj_row := json();
        param_msg_error := get_error_msg_php('HR2715',global_v_lang);
        v_response        := get_response_message(null,param_msg_error,global_v_lang);
        obj_row.put('coderror', '200');
        obj_row.put('response', hcm_util.get_string(json(v_response),'response'));
        obj_data.put('table', obj_row2);
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
end process_data;


procedure  insert_data_parallel (p_codapp  in varchar2,
                                 p_coduser in varchar2,
                                 p_proc    in out number)  as
    v_num       number ;
    v_proc      number := p_proc ;
    v_numproc   number ;
    v_rec       number ;
    v_flgsecu   boolean := false;
    v_secur     boolean := false;
    v_flgfound  boolean := false;
    v_zupdsal   varchar2(1);
    v_numtime   number;
    v_grade     varchar2(2 char);

    cursor c_tstdis  is
        select grade,pctwkstr,pctwkend,pctemp,pctpostr,pctpoend
          from tstdis
         where codcomp  = p_codcomp
           and dteyreap = p_dteyreap
        order by grade;

    cursor c_tappemp is
        select codempid,codcomp,numlvl
          from tappemp
         where dteyreap = p_dteyreap
           and codcomp  like p_codcomp
           and numtime  = v_numtime
           and grdap    = v_grade
        order by codempid;

begin
    delete tprocemp where codapp = p_codapp and coduser = p_coduser  ; commit;
    commit ;

    begin
        select numtime into v_numtime
          from tstdisd
         where codcomp  = p_dteyreap
           and dteyreap = p_dteyreap
           and flgsal   = 'Y'
           and rownum   = 1;
    exception when no_data_found then
        v_numtime := 1;
    end;

    for r_tstdis in c_tstdis loop
       v_grade   := r_tstdis.grade;
       v_numproc := v_numproc + 1;
        for i in c_tappemp loop
            v_flgfound := true;
            v_flgsecu  := secur_main.secur1(i.codcomp,i.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            if v_flgsecu then
                v_secur   := true;

                insert into tprocemp (codapp,coduser,numproc,codempid)
                       values        (p_codapp,p_coduser,v_numproc,i.codempid);

            end if;
        end loop;
    end loop;

    if not v_flgfound then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
    end if;

    if not v_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;

    p_proc := v_numproc;
    commit;
end insert_data_parallel;

end HRAP3EX;


/

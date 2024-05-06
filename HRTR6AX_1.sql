--------------------------------------------------------
--  DDL for Package Body HRTR6AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR6AX" AS

    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_dteyear   :=  hcm_util.get_string(json_obj,'p_dteyear');
        p_codcompy  :=  hcm_util.get_string(json_obj,'p_codcompy');
        p_numclseq  :=  hcm_util.get_string(json_obj,'p_numclseq');
        p_codcours  :=  hcm_util.get_string(json_obj,'p_codcours');

    end initial_value;

    procedure check_index as
        v_temp  varchar2(1 char);
        v_temp2 varchar2(1 char);
    begin
--      validate codcompy
        if p_codcompy is null or p_codcompy is null or p_codcours is null or p_numclseq is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

--      check codcompy in tcompny
        begin
            select 'X' into v_temp
            from tcompny
            where codcompy = p_codcompy;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOMPNY');
            return;
        end;

--      check secure7
        if secur_main.secur7(p_codcompy,global_v_coduser) = false then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

--      check codcours in tcours
        begin
            select 'X' into v_temp2
            from tcourse
            where codcours = p_codcours;
         exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCOURSE');
            return;
        end;

    end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json;
    obj_data        json;
    v_dteappr       ttrncerq.dteappr%type;
    v_codcancel     varchar2(100 char);
    v_number        varchar2(100 char);
    v_dtetrst       tpotentp.dtetrst%type;
    v_dtetren       tpotentp.dtetren%type;
    v_row           number := 0;
    v_secur         varchar2(1 char) := 'N';
    v_chk_secur     boolean := false;
      cursor c1 is
            select '1' typedata,b.codempid,b.codcomp,b.codpos,dtetrain dtetrain,'' remarkcancel,remark remarkabs
            from tpotentpd a,temploy1 b
            where a.codempid = b.codempid
            and a.dteyear = p_dteyear
            and a.codcompy  = p_codcompy
            and a.codcours  = p_codcours
            and a.numclseq  = p_numclseq
            and nvl(a.qtytrabs,0) > 0
            union
            select '2' typedata,b.codempid,b.codcomp,b.codpos,dtetrst dtetrain,'' remarkcancel,'' remarkabs
            from tpotentp a,temploy1 b
            where a.codempid = b.codempid
            and a.dteyear = p_dteyear
            and a.codcompy  = p_codcompy
            and a.numclseq  = p_numclseq
            and a.codcours  = p_codcours
            and a.flgatend  = 'C'
            order by codempid,dtetrain;
  begin
    obj_rows := json();
    obj_data := json();
    for i in c1 loop
        v_chk_secur := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_chk_secur then
            v_secur := 'Y';
            v_row := v_row+1;
            obj_data := json();
            v_number := v_row;
            begin
                select dtetrst,dtetren into v_dtetrst,v_dtetren
                from tpotentp
                where dteyear = p_dteyear
                  and codcompy  = p_codcompy
                  and codcours  = p_codcours
                  and numclseq  = p_numclseq
                  and rownum = 1;
            exception when no_data_found then
                v_dtetrst := '';
                v_dtetren := '';
            end;
            obj_data.put('dtetrst',to_char(v_dtetrst,'dd/mm/yyyy'));
            obj_data.put('dtetren',to_char(v_dtetren,'dd/mm/yyyy'));
            obj_data.put('no',v_number);
            obj_data.put('image',get_emp_img(i.codempid));
            obj_data.put('codempid',i.codempid);
            obj_data.put('emp_name',get_temploy_name(i.codempid,global_v_lang));
            obj_data.put('company_name',get_tcenter_name(i.codcomp,global_v_lang));
            if i.typedata = '1' then
                obj_data.put('dtetrain',to_char(i.dtetrain,'dd/mm/yyyy'));
                obj_data.put('dtecancel','');
                obj_data.put('because_cancel','');
                obj_data.put('remarkabs',i.remarkabs);
            end if;
            if i.typedata = '2' then
                begin
                    select dteappr,codcancel into v_dteappr,v_codcancel
                    from ttrncerq
                    where dteyear  = p_dteyear
                      and codcompy = p_codcompy
                      and codcours = p_codcours
                      and numclseq = p_numclseq
                      and codempid = i.codempid
                      and rownum = 1;
                exception when no_data_found then
                    v_dteappr := '';
                    v_codcancel := '';
                end;
                obj_data.put('dtetrain','');
                obj_data.put('dtecancel',to_char(v_dteappr,'dd/mm/yyyy'));
                obj_data.put('because_cancel',get_tcodec_name('tcodtrcn',v_codcancel,global_v_lang));
                obj_data.put('remarkabs','');
            end if;
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

   if obj_rows.count() = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tpotentp');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    if v_secur = 'Y' then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);

  END get_index;

END HRTR6AX;

/

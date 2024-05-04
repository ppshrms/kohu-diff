--------------------------------------------------------
--  DDL for Package Body HRAP4IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAP4IX" is
-- last update: 15/04/2019 17:53

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
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_year        := to_number(hcm_util.get_string_t(json_obj,'p_year'));
    b_index_qty         := to_number(hcm_util.get_string_t(json_obj,'p_qty'));
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecu       varchar2(1 char) := 'N';

    v_codempid      varchar2(100 char);
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_chksecu       varchar2(1);
    v_chk           number;
    v_flgappr       varchar2(1);

    cursor c1 is
      select codempid,codaplvl,codcomp,codpos
        from tempaplvl
       where dteyreap = b_index_year
         and numseq = b_index_qty
         and codcomp like b_index_codcomp||'%'
      order by codaplvl,codempid;

  begin
    obj_row := json_object_t();
    for i in c1 loop
        begin
            select count(codempid)
              into v_chk
              from tappfm
             where codempid = i.codempid
               and dteyreap = b_index_year
               and numtime = b_index_qty
               and nvl(flgappr,'P') <> 'C';
        exception when no_data_found then
            v_chk := 0;
        end;
        --insert into nut values (v_chk); commit;
        if v_chk > 0 then
            v_flgdata := 'Y';
            flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then
                v_flgsecu := 'Y';
                v_rcnt := v_rcnt+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200');
                obj_data.put('image', get_emp_img(i.codempid));
                obj_data.put('codempid',i.codempid);
                obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
                obj_data.put('desc_codaplvl',get_tcodec_name('TCODAPLV',i.codaplvl,global_v_lang));
                begin
                    select count(codempid)
                      into v_chk
                      from tappfm
                     where codempid = i.codempid
                       and dteyreap = b_index_year
                       and numtime = b_index_qty;
                exception when no_data_found then
                    v_chk := 0;
                end;
                obj_data.put('cntapall',v_chk);
                begin
                    select count(codempid)
                      into v_chk
                      from tappfm
                     where codempid = i.codempid
                       and dteyreap = b_index_year
                       and numtime = b_index_qty
                       and nvl(flgappr,'P') = 'C';
                exception when no_data_found then
                    v_chk := 0;
                end;
                obj_data.put('cntapcom',v_chk);
                obj_data.put('dteyreap',b_index_year);
                obj_data.put('numseq',b_index_qty);

                begin
                    select flgappr
                      into v_flgappr
                      from tappemp
                     where codempid = i.codempid
                       and dteyreap = b_index_year
                       and numtime = b_index_qty;
                exception when no_data_found then
                    v_flgappr := null;
                end;
                obj_data.put('desc_flgappr',get_tlistval_name('APSTATUS',v_flgappr,global_v_lang));
                obj_row.put(to_char(v_rcnt-1),obj_data);
            end if;
        end if;
    end loop;

    if v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tempaplvl');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecu = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      json_str_output := obj_row.to_clob;
    end if;
  end;
  --
  procedure get_popup(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_popup(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_popup(json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    flgpass     	boolean;
    v_zupdsal   	varchar2(4);
    v_sumhur        number;
    v_sumday        number;
    v_summth        number;
    v_codcompap     tappfm.codcompap%type;
    v_codposap      tappfm.codposap%type;
    v_codpos        varchar2(100);
    v_codap         varchar2(20);

    cursor c1 is
      select numseq,codapman,codposap,codcompap,flgappr
        from tappfm
       where codempid = b_index_codempid
         and dteyreap = b_index_year
         and numtime = b_index_qty
         order by numseq;

    cursor c2 is
      select codempid
        from temploy1
       where codcomp = v_codcompap
         and codpos  = v_codposap
         and staemp in ('1','3')
      union
      select codempid
        from tsecpos
       where codcomp = v_codcompap
         and codpos = v_codposap
         and dteeffec <= SYSDATE
         and (nvl(dtecancel,dteend) >= trunc(sysdate) or nvl(dtecancel,dteend) is null) ;
  begin

    obj_row := json_object_t();
    for i in c1 loop
      v_flgdata := 'Y';

       --<<User37 #7272 ST11 29/11/2021  
       --flgpass := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);  --<<user25 date: 15/09/2021 3. AP Module #4325
       flgpass := secur_main.secur2(i.codapman,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
       -->>User37 #7272 ST11 29/11/2021   
       if flgpass then--<<user25 date: 15/09/2021 3. AP Module #4325
          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          v_codcompap   := i.codcompap;
          v_codposap    := i.codposap;
          if i.codapman is not null then
            obj_data.put('image', get_emp_img(i.codapman));
            obj_data.put('codapman',i.codapman);
            obj_data.put('desc_codapman', get_temploy_name(i.codapman,global_v_lang));
            begin
                select codpos
                  into v_codpos
                  from temploy1
                 where codempid = i.codapman;
            exception when no_data_found then
                v_codpos := null;
            end;
            obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
          else
            obj_data.put('image', '');
            obj_data.put('codapman','');
            obj_data.put('desc_codapman', '');
            obj_data.put('desc_codpos', '');
            for j in c2 loop
                obj_data.put('image', get_emp_img(j.codempid));
                obj_data.put('codapman',j.codempid);
                obj_data.put('desc_codapman', get_temploy_name(j.codempid,global_v_lang));
                begin
                    select codpos
                      into v_codpos
                      from temploy1
                     where codempid = j.codempid;
                exception when no_data_found then
                    v_codpos := null;
                end;
                obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
                exit;
            end loop;
          end if;
          obj_data.put('desc_flgappr', get_tlistval_name('APSTATUS',i.flgappr,global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_flgdata = 'Y' then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tappfm');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;
  --
end;

/

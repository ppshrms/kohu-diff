--------------------------------------------------------
--  DDL for Package Body HRRC19X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC19X" AS

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereqst    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'),'dd/mm/yyyy');
    b_index_dtereqen    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqen'),'dd/mm/yyyy');
    b_index_flgrecut    := hcm_util.get_string_t(json_obj,'p_flgrecut');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure check_index is

  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end If;

    if b_index_dtereqst is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_dtereqen is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;

    if b_index_dtereqen < b_index_dtereqst then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;

  end check_index;

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

  procedure gen_index (json_str_output out clob) as
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_flgsecur      varchar2(1 char) := 'N';
    v_secur         boolean;
    v_qtyreq        number := 0;
    v_qtyapp        number := 0;
    v_qtyintview    number := 0;
    v_qtychoose     number := 0;
    v_qtyact        number := 0;
    v_sumqtyreq        number := 0;
    v_sumqtyapp        number := 0;
    v_sumqtyintview    number := 0;
    v_sumqtychoose     number := 0;
    v_sumqtyact        number := 0;
    v_totalqtyreq        number := 0;
    v_totalqtyapp        number := 0;
    v_totalqtyintview    number := 0;
    v_totalqtychoose     number := 0;
    v_totalqtyact        number := 0;
    v_flgrecut      treqest2.flgrecut%type;
    v_chkflgrecut   treqest2.flgrecut%type;

    cursor c_treqest is
      select a.numreqst,a.codemprc,a.dtereq,b.flgrecut,a.codcomp,b.codpos,b.qtyreq
        from treqest1 a, treqest2 b
       where a.numreqst = b.numreqst
         and a.codcomp  like b_index_codcomp||'%'
         and a.dtereq   between b_index_dtereqst and b_index_dtereqen
         and (b.flgrecut = b_index_flgrecut or b_index_flgrecut is null)
      order by b.flgrecut,a.numreqst,b.codpos,a.codcomp;

  begin
    obj_row    := json_object_t();
    obj_data   := json_object_t();
    obj_result := json_object_t();
    for i in c_treqest loop
        v_flgdata   := 'Y';
        v_secur     := secur_main.secur7(i.codcomp, global_v_coduser);
        if v_flgrecut is null then
          v_flgrecut := i.flgrecut;
        end if;

        if v_secur then
            if i.flgrecut = 'E' then
                begin
                    select count(*) into v_qtyapp
                      from tapplinf
                     where numreql  = i.numreqst
                       and codposl	= i.codpos;
                exception when no_data_found then
                    v_qtyapp := null;
                end;

                begin
                    select count(*) into v_qtyintview
                      from tapplinf
                     where numreql  = i.numreqst
                       and codposl	= i.codpos
                       and statappl in ('21','31'); --- 21 => คัดเลือกเพื่อเรียกสัมภาษณ์, 31 => เรียกสัมภาษณ์
                exception when no_data_found then
                    v_qtyintview := null;
                end;

                begin
                    select count(*) into v_qtychoose
                      from tapplinf
                     where numreql  = i.numreqst
                       and codposl	= i.codpos
                       and statappl in ('51','61','62'); --- 51 => คัดเลือกเป็นพนักงาน, 61 => บรรจุ, 62  => สละสิทธิการเข้าทำงาน
                exception when no_data_found then
                    v_qtychoose := null;
                end;

                begin
                    select count(*) into v_qtyact
                      from tapplinf
                     where numreql  = i.numreqst
                       and codposl	= i.codpos
                       and statappl = '61'; --- 61 => บรรจุ
                exception when no_data_found then
                    v_qtychoose := null;
                end;
            end if;

             if i.flgrecut = 'I' then
                begin
                    select count(*) into v_qtyapp
                      from tappeinf
                     where numreqst = i.numreqst
                       and codpos	= i.codpos;
                exception when no_data_found then
                    v_qtyapp := null;
                end;

                begin
                    select count(*) into v_qtyintview
                      from tappeinf
                     where numreqst = i.numreqst
                       and codpos	= i.codpos
                       and dteappoi is not null;
                exception when no_data_found then
                    v_qtyintview := null;
                end;

                begin
                    select count(*) into v_qtychoose
                      from tappeinf
                     where numreqst = i.numreqst
                       and codpos	= i.codpos
                       and dtestrt is not null;
                exception when no_data_found then
                    v_qtychoose := null;
                end;

                begin
                    select count(*) into v_qtyact
                      from tappeinf
                     where numreqst = i.numreqst
                       and codpos	= i.codpos
                       and status = 'Y';
                exception when no_data_found then
                    v_qtyact := null;
                end;
            end if;

            --add sum
            if v_flgrecut <> i.flgrecut then
              v_rcnt      := v_rcnt+1;
              obj_data    := json_object_t();
              obj_data.put('coderror', '200');
              obj_data.put('desc_codcomp', get_label_name('HRRC19X1',global_v_lang,140));
              obj_data.put('qtyreq', v_sumqtyreq);  -- sum จำนวนที่เปิดรับ
              obj_data.put('qtyapp', v_sumqtyapp);    -- sum จำนวนผู่สมัคร
              obj_data.put('qtyintview', v_sumqtyintview);     -- sum จำนวนเรียกสัมภาษณ์
              obj_data.put('qtychoose', v_sumqtychoose);   -- sum จำนวนคัดเลือก
              obj_data.put('qtyact', v_sumqtyact);    -- sum บรรจุ
              obj_row.put(to_char(v_rcnt-1),obj_data);

              v_sumqtyreq := 0;
              v_sumqtyapp := 0;
              v_sumqtyintview := 0;
              v_sumqtychoose  := 0;
              v_sumqtyact := 0;
            end if;
            v_sumqtyreq :=  v_sumqtyreq + i.qtyreq;
            v_sumqtyapp :=  v_sumqtyapp + v_qtyapp;
            v_sumqtyintview :=  v_sumqtyintview + v_qtyintview;
            v_sumqtychoose  :=  v_sumqtychoose + v_qtychoose;
            v_sumqtyact :=  v_sumqtyact + v_qtyact;

            v_totalqtyreq   :=  v_totalqtyreq + i.qtyreq;
            v_totalqtyapp   :=  v_totalqtyapp + v_qtyapp;
            v_totalqtyintview   :=  v_totalqtyintview + v_qtyintview;
            v_totalqtychoose    :=  v_totalqtychoose + v_qtychoose;
            v_totalqtyact   :=  v_totalqtyact + v_qtyact;
            v_flgrecut := i.flgrecut;
            --
            v_flgsecur  := 'Y';
            v_rcnt      := v_rcnt+1;
            obj_data    := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_flgrecut', get_tlistval_name('FLGRECUT2',i.flgrecut,global_v_lang) );
            obj_data.put('numreqst', i.numreqst);
            obj_data.put('desc_codpos', get_tpostn_name(i.codpos,global_v_lang) );
            obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp,global_v_lang) );
            obj_data.put('qtyreq', i.qtyreq);-- จำนวนที่เปิดรับ

            obj_data.put('qtyapp', v_qtyapp);    --จำนวนผู่สมัคร
            obj_data.put('qtyintview', v_qtyintview);     --จำนวนเรียกสัมภาษณ์
            obj_data.put('qtychoose', v_qtychoose);   --จำนวนคัดเลือก
            obj_data.put('qtyact', v_qtyact);    --บรรจุ
            --
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
    end loop;
    v_rcnt      := v_rcnt+1;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codcomp', get_label_name('HRRC19X1',global_v_lang,140));
    obj_data.put('qtyreq', v_sumqtyreq);  -- sum จำนวนที่เปิดรับ
    obj_data.put('qtyapp', v_sumqtyapp);    -- sum จำนวนผู่สมัคร
    obj_data.put('qtyintview', v_sumqtyintview);     -- sum จำนวนเรียกสัมภาษณ์
    obj_data.put('qtychoose', v_sumqtychoose);   -- sum จำนวนคัดเลือก
    obj_data.put('qtyact', v_sumqtyact);    -- sum บรรจุ
    obj_row.put(to_char(v_rcnt-1),obj_data);

    v_rcnt      := v_rcnt+1;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_codcomp', get_label_name('HRRC19X1',global_v_lang,150));
    obj_data.put('qtyreq', v_totalqtyreq);  -- Total จำนวนที่เปิดรับ
    obj_data.put('qtyapp', v_totalqtyapp);    -- Total จำนวนผู่สมัคร
    obj_data.put('qtyintview', v_totalqtyintview);     -- Total จำนวนเรียกสัมภาษณ์
    obj_data.put('qtychoose', v_totalqtychoose);   -- Total จำนวนคัดเลือก
    obj_data.put('qtyact', v_totalqtyact);    -- Total บรรจุ
    obj_row.put(to_char(v_rcnt-1),obj_data);


    if v_flgdata = 'N' then
        param_msg_error      := get_error_msg_php('HR2055', global_v_lang, 'treqest2');
        json_str_output      := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
        json_str_output := obj_row.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

END HRRC19X;

/

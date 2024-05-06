--------------------------------------------------------
--  DDL for Package Body HRRP4DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRP4DX" is
-- last update: 11/08/2020 14:00

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    --block b_index
    b_index_codcomp    := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codpos     := hcm_util.get_string_t(json_obj,'p_codpos');
    b_index_dteyear    := hcm_util.get_string_t(json_obj,'p_dteyear');
    b_index_numtime    := hcm_util.get_string_t(json_obj,'p_numtime');
    b_index_typerep    := hcm_util.get_string_t(json_obj,'p_typerep');  --แสดงข้อมูลตาม (1-ตามลำดับ , 2-ตามสถานะ)
    b_index_stasuccr   := hcm_util.get_string_t(json_obj,'p_stasuccr');  --สถานะ

    --block drilldown
    ---
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
    flgpass     	boolean;
    v_zupdsal   	varchar2(4 char);
    v_numseq        number;
    v_imageh        tempimge.namimage%type;
    v_folder        tfolderd.folder%type;
    v_has_image     varchar2(1) := 'N';
    v_codemid       temploy1.codempid%type;

    cursor c1 is
      select codempid, codcompe, codpose, stasuccr, numseq,
             codcomp, codpos, dteyear, numtime --<< user25 Date : 03/09/2021 1. RP Module #3079
        from tsuccpln
       where codcomp like b_index_codcomp||'%'
         and codpos = b_index_codpos
         and dteyear = nvl(to_number(b_index_dteyear),dteyear)
         and numtime = nvl(to_number(b_index_numtime),numtime)
         and stasuccr = nvl(b_index_stasuccr, stasuccr)
      order by numseq, codempid;

  begin
    obj_row := json_object_t();

    if b_index_typerep = '1' or b_index_stasuccr = '1' then
      BEGIN
          DELETE ttemprpt
           WHERE codempid = global_v_codempid
             AND codapp = 'HRRP4DX';
      EXCEPTION WHEN OTHERS THEN
        NULL;
      END;
      begin
          select codempid
            into v_codemid
            from temploy1
           where codcomp = b_index_codcomp
             and codpos = b_index_codpos
             and rownum = 1;
      exception when no_data_found then
        v_codemid := null ;
      end;

      INSERT INTO ttemprpt ( codempid, codapp, numseq, item1,
                             item2)
                    VALUES ( global_v_codempid, 'HRRP4DX', 1, 'DETAIL',
                             v_codemid || ' - ' || get_temploy_name(v_codemid,global_v_lang));

    end if;

    begin
        select nvl(max(numseq),0)
          into v_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRRP4DX';
    exception when others then
        v_numseq := 0;
    end;
    v_numseq := nvl(v_numseq,0) + 1;

    for i in c1 loop
      v_flgdata := 'Y';
      flgpass := secur_main.secur3(i.codcompe,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if flgpass then


          v_rcnt := v_rcnt+1;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('seq',v_rcnt);
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid',i.codempid);

          obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
          obj_data.put('desc_codcomp',get_tcenter_name(i.codcompe,global_v_lang));
          obj_data.put('desc_codpos',get_tpostn_name(i.codpose,global_v_lang));
          obj_data.put('status',get_tlistval_name('STASUCCR', i.stasuccr,global_v_lang));
          obj_data.put('numseq',i.numseq);
          --<< user25 Date : 03/09/2021 1. RP Module #3079
          -----adjust report
         obj_data.put('codcomp',i.codcomp);
         obj_data.put('codpos',i.codpos);
         obj_data.put('dteyear',i.dteyear);
         obj_data.put('numtime',i.numtime);
          -->> user25 Date : 03/09/2021 1. RP Module #3079
          obj_data.put('codcompn',i.codcompe);
          obj_data.put('desc_codcompn',get_tcenter_name(i.codcompe,global_v_lang));
          obj_data.put('codposn',i.codpose);
          obj_data.put('desc_codposn',get_tpostn_name(i.codpose,global_v_lang));

          obj_row.put(to_char(v_rcnt-1),obj_data);

          v_has_image   := 'N';
          begin
            select namimage
              into v_imageh
              from tempimge
             where codempid = i.codempid;
          exception when no_data_found then
            v_imageh := null;
          end;

          if v_imageh is not null then
              v_imageh      := get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRPMC2E1')||'/'||v_imageh;
              v_has_image   := 'Y';
          else
              v_has_image   := 'Y';
              v_imageh      := get_tsetup_value('PATHWORKPHP')||'default-emp.png';
          end if;

          INSERT INTO ttemprpt ( codempid, codapp, numseq, item1, item2,
                                 item4, item5,
                                 item6, item7,
                                 item8, item9,
                                 item10, item11,item12)
                        VALUES ( global_v_codempid, 'HRRP4DX', v_numseq, 'TABLE'||to_char(nvl(b_index_stasuccr,1)), v_rcnt,
                                 v_imageh, v_has_image,
                                 i.codempid, get_temploy_name(i.codempid,global_v_lang),
                                 get_tcenter_name(i.codcompe,global_v_lang),get_tpostn_name(i.codpose,global_v_lang),
                                 get_tlistval_name('STASUCCR', i.stasuccr,global_v_lang),i.numseq,b_index_stasuccr);
          v_numseq := v_numseq + 1;
      end if;-- flgpass
    end loop;

    if v_rcnt > 0 then
        json_str_output := obj_row.to_clob;
    else
      if v_flgdata = 'Y' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tsuccpln');
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);

    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_detail(json_str_output out clob) is
    obj_data        json_object_t;
    v_codemid       varchar2(4000 char);

  begin
    begin
      select codempid into v_codemid
      from temploy1
      where codcomp like b_index_codcomp || '%'
         and codpos = b_index_codpos
         and rownum = 1;
    exception when no_data_found then
      v_codemid := null ;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid_curpos',v_codemid || '-' || get_temploy_name(v_codemid,global_v_lang));

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
end;

/

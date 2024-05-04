--------------------------------------------------------
--  DDL for Package Body HRMS1AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS1AX" is
-- last update: 15/04/2019 17:51
-- last update: 25/11/2020 16:43

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    b_index_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    p_path              := hcm_util.get_string_t(json_obj,'p_path');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure check_index is
  begin
    if b_index_codempid is null and b_index_codcomp is null and b_index_codcalen is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if b_index_codempid is not null then
      b_index_codcomp   := null;
      b_index_codcalen  := null;
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
      if param_msg_error is not null then
        return;
      end if;
    else
      if b_index_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
        if param_msg_error is not null then
          return;
        end if;
      end if;

      if b_index_codcalen is not null then
        begin
          select codcodec into b_index_codcalen
            from tcodwork
           where codcodec = b_index_codcalen;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODWORK');
          return;
        end;
      end if;
    end if;

    if b_index_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    elsif b_index_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if b_index_dtestrt > b_index_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;
  end;
  --
  function set_time_format(p_time varchar2) return varchar2 is
    v_hh    varchar2(10 char);
    v_mm    varchar2(10 char);
    v_ret   varchar2(1000 char);
    v_time  varchar2(1000 char);
  begin
    if p_time is not null then
      v_time  := lpad(p_time,4,'0');
      v_hh    := substr(v_time,1,2);
      v_mm    := substr(v_time,3,2);
      v_ret   := v_hh||':'||v_mm;
    end if;
    return v_ret;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) is
    obj_row    json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_folder      varchar(200 char);
    v_filenameo   varchar2(4000 char);
    v_flgsecu       varchar2(1 char) := 'N';
    v_flgdata     varchar(1 char) := 'N';
    flgpass       boolean := false;

    cursor c_tchkin is
      select a.codempid,a.dtework,a.typwork,a.codshift,
             a.timstrtw,a.timendw,a.timin as timstrt,a.timout as timend,a.codcomp,b.codpos,
             c.codcust,decode(c.codcust,'999',d.namcust,get_tcust_name(c.codcust,global_v_lang)) as desc_codcust,
             decode(c.codcust,'999','',c.latitudei||', '||c.longitudei) as coordinates,c.timin, c.seqno,
             c.timout,c.filenamei,c.filenameo,get_tcodec_name('TCODREASON',c.codreason,'102') desc_codreason
        from tattence a, temploy1 b, tchkin c, tcustsurv d
       where a.codempid     = b.codempid
         and b.codempid     = nvl(b_index_codempid,b.codempid)
         and b.codcomp 	    like b_index_codcomp||'%'
         and b.codcalen     = nvl(b_index_codcalen,b.codcalen)
         and a.dtework 	    between b_index_dtestrt and b_index_dteend
         and a.dtework      = c.dtework
         and a.codempid     = c.codempid
         and c.codcustsurv  = d.codcustsurv(+)
         /*
         and (a.codempid = global_v_codempid or
             (a.codempid <> global_v_codempid
               and b.numlvl between global_v_zminlvl and global_v_zwrklvl
               and 0 <> (select count(ts.codcomp)
                           from tusrcom ts
                          where ts.coduser = global_v_coduser
                            and b.codcomp like ts.codcomp||'%'
                            and rownum    <= 1 ) ))
         */
      order by b.codcomp,a.codempid,a.dtework desc,c.seqno desc;
    begin

   for i in c_tchkin loop
        v_flgdata := 'Y';
   end loop;

    if  v_flgdata = 'Y' then               
            v_rcnt      := 0;
            begin
              select  folder
              into    v_folder
              from    tfolderd
              where   codapp = 'HRES6OE';
            exception when no_data_found then
              v_folder  := 'temp';
            end;
            obj_row  := json_object_t();
            for i in c_tchkin loop
            flgpass := secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
            if flgpass then 
             v_flgsecu := 'Y';
                  v_rcnt := v_rcnt+1;
                  if i.filenameo is not null then
                    v_filenameo := p_path||v_folder||'/'||i.filenameo;
                  else
                    v_filenameo := ' ';
                  end if;
                  obj_data := json_object_t();
                  obj_data.put('coderror', '200');
                  obj_data.put('desc_coderror', ' ');
                  obj_data.put('httpcode', '');
                  obj_data.put('flg', '');
                  obj_data.put('seqno',i.seqno);
                  obj_data.put('codempid',i.codempid);
                  obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
                  obj_data.put('codpos',i.codpos);
                  obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
                  obj_data.put('codcomp',i.codcomp);
                  obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
                  obj_data.put('dtework',to_char(i.dtework,'dd/mm/yyyy'));
                  obj_data.put('typwork',i.typwork);
                  obj_data.put('codshift',i.codshift);
                  obj_data.put('timbstr',set_time_format(i.timstrtw));
                  obj_data.put('timbend',set_time_format(i.timendw));
                  obj_data.put('timdstr',set_time_format(i.timin));
                  obj_data.put('timdend',set_time_format(i.timout));
                  obj_data.put('codcust',i.codcust);
                  obj_data.put('location',i.desc_codcust);
                  obj_data.put('desc_codreason',i.desc_codreason);
                  obj_data.put('coordinates',i.coordinates);
                  obj_data.put('filenamei', p_path||v_folder||'/'||i.filenamei);
                  obj_data.put('filenameo',v_filenameo);
                  obj_row.put(to_char(v_rcnt-1),obj_data);
                  end if; 
            end loop;
   end if; --v_flgdata


        if v_flgdata = 'N' then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCHKIN');
          json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        elsif v_flgsecu = 'N' then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
          json_str_output := obj_row.to_clob;
--          json_str_output := obj_data.to_clob; -- fix issue #5382 user18 02/03/2021
        end if;

   /*
            json_str_output := obj_row.to_clob;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    */


     end;
end;

/

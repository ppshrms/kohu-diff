--------------------------------------------------------
--  DDL for Package Body HRPMS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMS2X" AS

   procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
    v_token varchar2(4000 char) := '';
    v_token2 varchar2(4000 char) := '';
    v_codleave  json_object_t;

  begin
    json_obj            := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codtrn            := hcm_util.get_string_t(json_obj,'p_codtrn');
    p_column            := hcm_util.get_string_t(json_obj,'p_column');
    p_comlevel          := hcm_util.get_string_t(json_obj,'p_comlevel');
    p_row               := hcm_util.get_string_t(json_obj,'p_row');
    p_yearst            := hcm_util.get_string_t(json_obj,'p_yearst');
    p_monthst           := hcm_util.get_string_t(json_obj,'p_monthst');
    p_yearen            := hcm_util.get_string_t(json_obj,'p_yearen');
    p_monthen           := hcm_util.get_string_t(json_obj,'p_monthen');

    p_column_data       := hcm_util.get_json_t(json_obj, 'p_column_data');
    p_row_data          := hcm_util.get_json_t(json_obj, 'p_row_data');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as obj_row json_object_t;
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

  procedure check_index is
    flgsecu boolean := false;
  begin

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_row = p_column then
      param_msg_error := get_error_msg_php('HR2020',global_v_lang);
      return;
    end if;

 --- check  date--
--     if p_monthst is null then
--          param_msg_error := 'D'||get_error_msg_php('HR2045',global_v_lang, '');
--          return ;
--     end if;

--      if p_yearst is null then
--          param_msg_error := 'A'||get_error_msg_php('HR2045',global_v_lang, '');
--          return ;
--     end if;

--     if p_monthen is null then
--          param_msg_error := 'B'||get_error_msg_php('HR2045',global_v_lang, '');
--          return ;
--     end if;

     if p_yearen is null then
          param_msg_error := 'C'||get_error_msg_php('HR2045',global_v_lang, '');
          return ;
     end if;

    if p_yearst =  p_yearen then
         if  p_monthen < p_monthst then
             param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
              return ;
         end if;
    else
         if  p_yearen < p_yearst then
              param_msg_error := get_error_msg_php('HR2029',global_v_lang, '');
              return ;
         end if;
    end if;
   -----
  end check_index;

  procedure gen_detail(json_str_output out clob) as
    obj_data            json_object_t;
    obj_row             json_object_t;
    json_obj            json_object_t;
    obj_result          json_object_t;
    obj_data_temp       json_object_t;
    obj_row_temp        json_object_t;
    v_rcnt              number := 0;
    v_total             number := 0;
    v_sum_digits        number := 0;
    v_tmp               number := 0;
    v_max               number := 0;
    stdate              varchar2(50) := p_yearst||lpad(nvl(p_monthst,'1'),2,'0');--User37 #5705 1.PM Module 16/04/2021 p_yearst||lpad(p_monthst,2,'0');
    endate              varchar2(50) := p_yearen||lpad(nvl(p_monthen,'12'),2,'0');--User37 #5705 1.PM Module 16/04/2021 p_yearen||lpad(p_monthen,2,'0');
    v_row               varchar2(50);
    v_column            varchar2(50);
    v_codtrn            varchar2(50);
    v_stdate            varchar2(50);
    v_month             varchar2(50);
    v_chkdata           varchar2(1) := 'N';--User37 Final Test Phase 1 V11 #2780 30/11/2020
    --<<User37 #5705 1.PM Module 16/04/2021
    v_total_all         number := 0;
    v_tmp_all           number := 0;
    v_chkdata_all       varchar2(1) := 'N';
    -->>User37 #5705 1.PM Module 16/04/2021
    json_graph_data     json_object_t;

    json_graph_row      json_object_t;
  begin

    begin
      delete
        from ttemprpt
       where codapp = 'HRPMS2X'
         and codempid = global_v_codempid;
    end;

    obj_row := json_object_t();
    json_graph_data := json_object_t();
    json_graph_col := json_object_t();
    json_graph_row := json_object_t();
    begin
        select sum(nvl(qtycode,0)) into v_sum_digits
        from tsetcomp
        where numseq <= p_comlevel;
      end;

    if p_row = 1 and p_column = 2 then
      for i in 0..p_row_data.get_size -1 loop
          v_row        := hcm_util.get_string_t(p_row_data, to_char(i));
          v_total := 0;
          json_obj := json_object_t();
          json_obj.put('codcomp',v_row);
          json_obj.put('desc_codcomp',get_tcenter_name(v_row,global_v_lang));
          json_obj.put('month','');
          json_obj.put('desc_month','');
          json_obj.put('graph_x_desc',get_label_name('HRPMS2XC1',global_v_lang,120));
          json_obj.put('graph_y_desc',get_label_name('HRPMS2XC1',global_v_lang,220));

          for j in 0..p_column_data.get_size -1 loop
             v_codtrn   := hcm_util.get_string_t(p_column_data, to_char(j));
             v_tmp      :=  0 ;
             if v_codtrn is not null then
                v_max := v_max +1 ;
                 if v_codtrn = '0005' then
                    begin
                       select count(distinct(b.codempid))
                         into   v_tmp
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                          and   exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                          and   a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021 and   a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)--User37 #5705 1.PM Module 16/04/2021 and   substr(b.codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into   v_tmp
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                else
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp_all
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and  exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                          and   a.numlvl between global_v_zminlvl and global_v_zwrklvl--and   a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)--User37 #5705 1.PM Module 16/04/2021 and   substr(b.codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                          and   b.codtrn = v_codtrn
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp_all
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)
                          and   b.codtrn = v_codtrn
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                end if;

                        /*
                if v_codtrn = '0005' then
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismist
                       where  substr(codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                       and    to_char(dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                else
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismove
                       where  substr(codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                       and    codtrn = v_codtrn
                       and    to_char(dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                end if;
                */
                v_total := v_total + v_tmp;
                v_total_all := v_total_all + v_tmp_all;--User37 #5705 1.PM Module 16/04/2021
                json_obj.put('param'||(j+1),v_tmp);
                json_obj.put('codtrn',v_codtrn);
                json_obj.put('desc_codtrn',get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));
                json_graph_data.put('desc'||(j+1),get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));
                json_graph_col.put((j+1),json_graph_data);
				    end if;
          end loop;

          --<<User37 Final Test Phase 1 V11 #2780 30/11/2020
          if v_total <> 0 then
            v_chkdata := 'Y';
          end if;
          -->>User37 Final Test Phase 1 V11 #2780 30/11/2020
          --<<User37 #5705 1.PM Module 16/04/2021
          if v_total_all <> 0 then
            v_chkdata_all := 'Y';
          end if;
          -->>User37 #5705 1.PM Module 16/04/2021

          json_obj.put('total',v_total);
          json_obj.put('coderror',200);
          obj_row.put((i+1),json_obj);

      end loop;
    elsif p_row = 1 and p_column = 3 then
      for i in 0..p_row_data.get_size -1 loop
          v_row        := hcm_util.get_string_t(p_row_data, to_char(i));
          v_total := 0;
          json_obj := json_object_t();
          json_obj.put('codcomp',v_row);
          json_obj.put('desc_codcomp',get_tcenter_name(v_row,global_v_lang));
          json_obj.put('month','');
          json_obj.put('desc_month','');
          json_obj.put('graph_x_desc',get_label_name('HRPMS2XC1',global_v_lang,120));
          json_obj.put('graph_y_desc',get_label_name('HRPMS2XC1',global_v_lang,220));
          json_obj.put('codcomp',v_row);
          for j in 0..p_column_data.get_size -1 loop
              v_month    := hcm_util.get_string_t(p_column_data, to_char(j));
              v_stdate   := p_yearen||lpad(v_month,2,'0');
              v_codtrn   := p_codtrn;
              v_tmp      :=  0 ;
             if v_codtrn is not null then
                v_max := v_max +1 ;
                 if v_codtrn = '0005' then
                    begin
                       select count(distinct(b.codempid))
                         into   v_tmp
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                          and   exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                          and   a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021 and   a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)--User37 #5705 1.PM Module 16/04/2021 and   substr(b.codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into   v_tmp_all
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                else
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and  exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')and a.codcomp like a.codcomp||'%')
                          and   a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021 and   a.numlvl between global_v_numlvlsalst and global_v_numlvlsalen
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)--User37 #5705 1.PM Module 16/04/2021 and   substr(b.codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                          and   b.codtrn = v_codtrn
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp_all
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and   substr(b.codcomp,1,v_sum_digits) =  substr( v_row ,1, v_sum_digits)--User37 #5705 1.PM Module 16/04/2021 and   substr(b.codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                          and   b.codtrn = v_codtrn
                          and   to_char(b.dteeffec,'yyyymm') between  stdate and  endate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                end if;
                /*
                if v_codtrn = '0005' then
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismist
                       where  substr(codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                       and    to_char(dteeffec,'yyyymm') =  v_stdate ;
                    end;

                else
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismove
                       where  substr(codcomp,1,v_sum_digits) like  substr( v_row ,1, v_sum_digits)
                       and    codtrn = v_codtrn
                       and    to_char(dteeffec,'yyyymm') =  v_stdate ;
                    end;
                end if;
                */
                v_total := v_total + v_tmp;
                v_total_all := v_total_all + v_tmp;--User37 #5705 1.PM Module 16/04/2021
                json_obj.put('param'||(j+1),v_tmp);
				    end if;
                json_obj.put('codtrn',p_codtrn);
                json_obj.put('desc_codtrn',get_tcodec_name('TCODMOVE',p_codtrn,global_v_lang));

                json_graph_data.put('desc'||(j+1),get_tlistval_name('NAMMTHFUL',v_month,global_v_lang));
                json_graph_col.put((j+1),json_graph_data);
          end loop;

          --<<User37 Final Test Phase 1 V11 #2780 30/11/2020
          if v_total <> 0 then
            v_chkdata := 'Y';
          end if;
          -->>User37 Final Test Phase 1 V11 #2780 30/11/2020
          --<<User37 #5705 1.PM Module 16/04/2021
          if v_total_all <> 0 then
            v_chkdata_all := 'Y';
          end if;
          -->>User37 #5705 1.PM Module 16/04/2021

          json_obj.put('total',v_total);
          json_obj.put('coderror',200);
          obj_row.put((i+1),json_obj);
      end loop;
     elsif p_row = 2 and p_column = 3 then
      for i in 0..p_row_data.get_size -1 loop
          v_codtrn        := hcm_util.get_string_t(p_row_data, to_char(i));
          v_total := 0;
          json_obj := json_object_t();
          json_obj.put('codcomp','');
          json_obj.put('desc_codcomp','');
          json_obj.put('month','');
          json_obj.put('desc_month','');
          json_obj.put('graph_x_desc',get_label_name('HRPMS2XC1',global_v_lang,170));
          json_obj.put('graph_y_desc',get_label_name('HRPMS2XC1',global_v_lang,220));
          v_tmp      :=  0 ;
          for j in 0..p_column_data.get_size -1 loop
              v_month   := hcm_util.get_string_t(p_column_data, to_char(j));
              v_stdate   := p_yearen||lpad(v_month,2,'0');
              v_tmp  :=  0 ; 
             if v_codtrn is not null then
                v_max := v_max +1 ;

                if v_codtrn = '0005' then
                    begin
                       select  count(distinct(b.codempid))
                         into   v_tmp
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                          and   exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                       and    a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021
                       and    b.codcomp like p_codcomp || '%'
                       and    to_char(b.dteeffec,'yyyymm') =  v_stdate ;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select  count(distinct(b.codempid))
                         into   v_tmp_all
                         from   temploy1 a, thismist b
                        where   a.codempid = b.codempid
                       and    b.codcomp like p_codcomp || '%'
                       and    to_char(b.dteeffec,'yyyymm') =  v_stdate ;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021

                else
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and   exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                          and  a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021
                          and  b.codcomp like p_codcomp || '%'
                          and  b.codtrn   = v_codtrn
                          and  to_char(b.dteeffec,'yyyymm') =  v_stdate ;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp_all
                         from  temploy1 a, thismove b
                        where  a.codempid = b.codempid
                          and  b.codcomp like p_codcomp || '%'
                          and  b.codtrn   = v_codtrn
                          and  to_char(b.dteeffec,'yyyymm') =  v_stdate ;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                end if;

                /*
                if v_codtrn = '0005' then
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismist
                       where  codcomp like p_codcomp || '%'
                       and    to_char(dteeffec,'yyyymm') =  v_stdate ;
                    end;

                else
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismove
                       where  codcomp like p_codcomp || '%'
                       and    codtrn = v_codtrn
                       and    to_char(dteeffec,'yyyymm') =  v_stdate ;
                    end;
                end if;
                */

                v_total := v_total + v_tmp;
                v_total_all := v_total_all + v_tmp_all;--User37 #5705 1.PM Module 16/04/2021
                json_obj.put('param'||(j+1),v_tmp);
                end if;

                json_graph_data.put('desc'||(j+1),get_tlistval_name('NAMMTHFUL',v_month,global_v_lang));
                json_graph_col.put((j+1),json_graph_data);
          end loop;
          json_obj.put('codtrn',v_codtrn);
          json_obj.put('desc_codtrn',get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));

          --<<User37 Final Test Phase 1 V11 #2780 30/11/2020
          if v_total <> 0 then
            v_chkdata := 'Y';
          end if;
          -->>User37 Final Test Phase 1 V11 #2780 30/11/2020
          --<<User37 #5705 1.PM Module 16/04/2021
          if v_total_all <> 0 then
            v_chkdata_all := 'Y';
          end if;
          -->>User37 #5705 1.PM Module 16/04/2021

          json_obj.put('total',v_total);
          json_obj.put('coderror',200);
          obj_row.put((i+1),json_obj);
      end loop;
    elsif p_row = 3 and p_column = 2 then
      for i in 0..p_row_data.get_size -1 loop
          v_month        := hcm_util.get_string_t(p_row_data, to_char(i));
          v_stdate   := p_yearen||lpad(v_month,2,'0');
          v_total := 0;
          json_obj := json_object_t();
          json_obj.put('codcomp','');
          json_obj.put('desc_codcomp','');
          json_obj.put('month',v_month);
          json_obj.put('desc_month',get_tlistval_name('NAMMTHFUL',v_month,global_v_lang));
          json_obj.put('graph_x_desc',get_label_name('HRPMS2XC1',global_v_lang,160));
          json_obj.put('graph_y_desc',get_label_name('HRPMS2XC1',global_v_lang,220));
          for j in 0..p_column_data.get_size -1 loop
             v_codtrn   := hcm_util.get_string_t(p_column_data, to_char(j));
             v_tmp      := 0 ;
             if v_codtrn is not null then
                v_max := v_max +1 ;
                v_tmp  := 0 ;
                if v_codtrn = '0005' then
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp
                         from  temploy1 a, thismist b
                        where  a.codempid = b.codempid
                          and  exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like x.codcomp||'%')--User37 #5705 1.PM Module 16/04/2021 and a.codcomp like a.codcomp||'%')
                          and  a.numlvl between global_v_zminlvl and global_v_zwrklvl--User37 #5705 1.PM Module 16/04/2021
                          and  b.codcomp like p_codcomp || '%'
                          and  to_char(b.dteeffec,'yyyymm') =  v_stdate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                         into  v_tmp_all
                         from  temploy1 a, thismist b
                        where  a.codempid = b.codempid
                          and  b.codcomp like p_codcomp || '%'
                          and  to_char(b.dteeffec,'yyyymm') =  v_stdate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                else
                    begin
                       select count(distinct(b.codempid))
                       into   v_tmp
                        from  temploy1 a, thismove b
                       where  a.codempid = b.codempid
                         and  exists (select codcomp
                                        from tusrcom x
                                       where x.coduser = global_v_coduser
                                         and a.codcomp like a.codcomp||'%')
                         and   b.codcomp like p_codcomp || '%'
                         and   b.codtrn = v_codtrn
                         and   to_char(b.dteeffec,'yyyymm') =  v_stdate;
                    end;
                    --<<User37 #5705 1.PM Module 16/04/2021
                    begin
                       select count(distinct(b.codempid))
                       into   v_tmp_all
                        from  temploy1 a, thismove b
                       where  a.codempid = b.codempid
                         and   b.codcomp like p_codcomp || '%'
                         and   b.codtrn = v_codtrn
                         and   to_char(b.dteeffec,'yyyymm') =  v_stdate;
                    end;
                    -->>User37 #5705 1.PM Module 16/04/2021
                end if;
                /*
                if v_codtrn = '0005' then
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismist
                       where  codcomp like p_codcomp || '%'
                       and    to_char(dteeffec,'yyyymm') =  v_stdate;
                    end;
                else
                    begin
                       select count(distinct(codempid))
                       into   v_tmp
                       from   thismove
                       where  codcomp like p_codcomp || '%'
                       and    codtrn = v_codtrn
                       and    to_char(dteeffec,'yyyymm') =  v_stdate;
                    end;
                end if;
                */
                v_total := v_total + v_tmp;
                v_total_all := v_total_all + v_tmp_all;--User37 #5705 1.PM Module 16/04/2021
                json_obj.put('param'||(j+1),v_tmp);                
                json_obj.put('codtrn',v_codtrn);
                json_obj.put('desc_codtrn',get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));

                json_graph_data.put('desc'||(j+1),get_tcodec_name('TCODMOVE',v_codtrn,global_v_lang));
                json_graph_col.put((j+1),json_graph_data);
				    end if;
          end loop;

          --<<User37 Final Test Phase 1 V11 #2780 30/11/2020
          if v_total <> 0 then
            v_chkdata := 'Y';
          end if;
          -->>User37 Final Test Phase 1 V11 #2780 30/11/2020
          --<<User37 #5705 1.PM Module 16/04/2021
          if v_total_all <> 0 then
            v_chkdata_all := 'Y';
          end if;
          -->>User37 #5705 1.PM Module 16/04/2021

          json_obj.put('total',v_total);
          json_obj.put('coderror',200);
          obj_row.put((i+1),json_obj);
      end loop;
    end if;
    --<<User37 #5705 1.PM Module 16/04/2021
    if nvl(v_chkdata_all,'N') = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    elsif nvl(v_chkdata,'N') = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang,'');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    /*if nvl(v_chkdata,'N') = 'N' then--User37 Final Test Phase 1 V11 #2780 30/11/2020 v_total = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;*/
    -->>User37 #5705 1.PM Module 16/04/2021
    else
      insert_graph(obj_row);
      json_str_output := obj_row.to_clob;
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure  insert_graph (json_str_output in json_object_t) as
     v_col_json            json_object_t;
     v_row_json            json_object_t;
     v_seq                 number := 1;
     v_no                   number := 1;
     v_row                 varchar2(200 char);
     v_row_desc            varchar2(200 char);
     v_col                 varchar2(200 char);
     v_col_desc            varchar2(200 char);
     v_data                varchar2(200 char);
     graph_x_desc          varchar2(200 char);
     graph_y_desc          varchar2(200 char);
     begin
           for i in 1..json_str_output.get_size loop
                v_row_json      := hcm_util.get_json_t(json_str_output,i);
                v_row_desc      := hcm_util.get_string_t(v_row_json, 'desc_codcomp');
                v_row           := hcm_util.get_string_t(v_row_json, 'codcomp');
                if  p_row = 2 and p_column = 3 then
                    v_row_desc      := hcm_util.get_string_t(v_row_json, 'desc_codtrn');
                    v_row           := hcm_util.get_string_t(v_row_json, 'codtrn');
                elsif  p_row = 3 and p_column = 2 then
                    v_row_desc      := hcm_util.get_string_t(v_row_json, 'desc_month');
                    v_row           := hcm_util.get_string_t(v_row_json, 'month');
                end if;
                graph_x_desc    := hcm_util.get_string_t(v_row_json, 'graph_x_desc');
                graph_y_desc    := hcm_util.get_string_t(v_row_json, 'graph_y_desc');
                 for j in 1..p_column_data.get_size loop
                     v_col_json    := hcm_util.get_json_t (json_graph_col,j);
                     v_col_desc    := hcm_util.get_string_t(v_col_json, 'desc'||j);
                     v_col         := hcm_util.get_string_t(p_column_data, j);
                     v_data         := hcm_util.get_string_t(v_row_json, 'param'||j);

                            INSERT INTO TTEMPRPT (CODEMPID,CODAPP,NUMSEQ,
                            ITEM1,
                            ITEM2,
                            ITEM3,
                            ITEM4,
                            ITEM5,ITEM9,
                            ITEM10,ITEM7, ITEM8,
                            ITEM31,ITEM12,ITEM13,ITEM6)
                            VALUES (global_v_codempid, 'HRPMS2X', v_seq,
                            '',
                            '',
                            '',
                            lpad(v_no, 2, '0'),
                            v_row_desc,graph_y_desc,
                            v_data, j, v_col_desc,
                            get_label_name('HRPMS2XC1',global_v_lang,210), '', null, graph_x_desc);
                            v_seq := v_seq + 1;
                    end loop;
                    v_no := v_no + 1;
           end loop;
 end;


  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    json_obj        json_object_t;
    json_obj2       json_object_t;
    json_obj3       json_object_t;
    json_data       json_object_t;
    json_row        json_object_t;
    json_col        json_object_t;
    json_row2       json_object_t;

    json_out_col    json_object_t := json_object_t();
    json_out_row    json_object_t := json_object_t();

    json_empty      json_object_t := json_object_t();

    v_count         number := 0;
    v_count2        number := 0;
    v_sum_digits    number := 0;
    v_secur         boolean := false;
    v_permission    boolean := false;
    v_codcompy      tcenter.codcompy%type;
    cursor c_codmove is
        select t1.codcodec,decode(global_v_lang,'101',t1.DESCODE,
                                                 '102',t1.DESCODT,
                                                 '103',t1.DESCOD3,
                                                 '104',t1.DESCOD4,
                                                 '105',t1.DESCOD5) desc_codmove
        from    tcodmove t1
        order by codcodec;

    cursor c_tcenter is
      select substr(codcomp,1,v_sum_digits)  codcomp
      from tcenter
      where flgact = '1'
        and codcomp like p_codcomp ||'%'
      group by substr(codcomp,1,v_sum_digits)
    order by substr(codcomp,1,v_sum_digits);

    cursor c_month is
        select *
        from tlistval
        where codapp = 'NAMMTHFUL'
        and codlang = global_v_lang
        and numseq >0
        order by numseq;

  begin
    json_obj := json_object_t();
    json_obj2 := json_object_t();
    json_obj3 := json_object_t();
    json_data := json_object_t();

    json_col := json_object_t();
    json_row := json_object_t();
    begin
      select sum(nvl(qtycode,0)) into v_sum_digits
      from tsetcomp
      where numseq <= p_comlevel;
    end;

    if p_column = 2 then
      for r1 in c_codmove loop
              json_obj := json_object_t();
              json_obj.put('code',r1.codcodec);
              json_obj.put('desc_code',r1.desc_codmove);
              json_col.put(to_char(v_count),json_obj);
              v_count := v_count + 1;
      end loop;

      json_obj3.put('rows',json_col);
      json_obj2.put('rows',json_empty);
      json_out_col.put('listFields',json_obj3);
      json_out_col.put('formatFields',json_obj2);

      json_obj2 := json_object_t();
      json_obj3 := json_object_t();
      v_count := 0;
    elsif p_column =3 then
      for r1 in c_month loop
              json_obj := json_object_t();
              json_obj.put('code',r1.LIST_VALUE);
              json_obj.put('desc_code',r1.DESC_LABEL);
              json_col.put(to_char(v_count),json_obj);
              v_count := v_count + 1;
      end loop;
      json_obj3.put('rows',json_col);
      json_obj2.put('rows',json_empty);
      json_out_col.put('listFields',json_obj3);
      json_out_col.put('formatFields',json_obj2);

      json_obj2 := json_object_t();
      json_obj3 := json_object_t();
      v_count := 0;
    end if;

    if p_row = 1 then
    for r1 in c_tcenter loop
      v_secur := secur_main.secur7(r1.codcomp,global_v_coduser);
      if v_secur then
            v_permission  := true;
            json_obj := json_object_t();
            json_obj.put('code',r1.codcomp);
            json_obj.put('desc_code',get_tcenter_name(r1.codcomp,global_v_lang));
            json_row.put(to_char(v_count),json_obj);
            v_count := v_count + 1;
      end if;
    end loop;
      json_obj3.put('rows',json_row);
      json_obj2.put('rows',json_empty);
      json_out_row.put('listFields',json_obj3);
      json_out_row.put('formatFields',json_obj2);

      json_obj2 := json_object_t();
      json_obj3 := json_object_t();
      v_count := 0;
    elsif p_row =2  then
       for r1 in c_codmove loop
           json_obj := json_object_t();
           json_obj.put('code',r1.codcodec);
           json_obj.put('desc_code',r1.desc_codmove);
           json_row.put(to_char(v_count),json_obj);
           v_count := v_count + 1;
       end loop;
        json_obj3.put('rows',json_row);
        json_obj2.put('rows',json_empty);
        json_out_row.put('listFields',json_obj3);
        json_out_row.put('formatFields',json_obj2);

        json_obj2 := json_object_t();
        json_obj3 := json_object_t();
        v_count := 0;
    elsif p_row =3  then
       for r1 in c_month loop
           json_obj := json_object_t();
           json_obj.put('code',r1.LIST_VALUE);
           json_obj.put('desc_code',r1.DESC_LABEL);
           json_row.put(to_char(v_count),json_obj);
           v_count := v_count + 1;
      end loop;
      json_obj3.put('rows',json_row);
      json_obj2.put('rows',json_empty);
      json_out_row.put('listFields',json_obj3);
      json_out_row.put('formatFields',json_obj2);

      json_obj2 := json_object_t();
      json_obj3 := json_object_t();
      v_count := 0;
    end if;
    if p_row = 1 then
      if v_permission then
        json_data.put('coderror','200');
        json_data.put('column',json_out_col);
        json_data.put('row',json_out_row);
        json_str_output := json_data.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      end if;
    else
        json_data.put('coderror','200');
        json_data.put('column',json_out_col);
        json_data.put('row',json_out_row);
        json_str_output := json_data.to_clob;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
END HRPMS2X;

/

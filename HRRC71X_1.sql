--------------------------------------------------------
--  DDL for Package Body HRRC71X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC71X" is
-- last update: 10/03/2021 18:30
procedure initial_value (json_str in clob) is
    json_obj        json;
  begin
    json_obj            := json(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string(json_obj, 'p_codempid');

    p_codcomp           := (hcm_util.get_string(json_obj, 'p_codcomp'));
    p_codpos            := (hcm_util.get_string(json_obj, 'p_codpos'));
    p_dtestrt           := to_date(json_ext.get_string(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(json_ext.get_string(json_obj,'p_dteend'),'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  ----------------------------------------------------------------------------------
  procedure check_index is
    v_flgsecu2        boolean := false;
  begin
    if p_codcomp is not null then
      v_flgsecu2 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flgsecu2 then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang, 'codcomp');
        return;
      end if;
    end if;
  end check_index;
  ----------------------------------------------------------------------------------
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
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
----------------------------------------------------------------------------------
  procedure gen_index(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    v_flgdata   varchar2(1 char) := 'N';
    v_flgsecur  varchar2(1 char) := 'N';
    v_secur     boolean;
    v_count     number;
    v_zupdsal   varchar2(50 char);

--<< user22 : 19/03/2022 : ST11 ||
    cursor c1 is
       select c.dtereq, c.numreqst, b.codcomp, b.codpos, b.codempr, a.dteeffex, c.stareq
         from temploy1 a, treqest2 b, treqest1 c
        where a.codempid  = b.codempr
          and b.numreqst  = c.numreqst
          and a.codcomp  like (p_codcomp ||'%')
          and a.codpos    = p_codpos        
          and a.dteeffex between  p_dtestrt and  p_dteend
          and exists( select e.numreqst
                        from treqest2 e
                       where b.rowid         = e.rowid
                         and e.codrearq      = '3'
                         and nvl(e.qtyact,0) = 0)
      order by dtereq desc,b.numreqst desc;
/*    cursor c1 is
            select distinct a.codcomp, a.codpos, b.numreqst, a.dteeffex, b.codempr,
            (select c.dtereq from treqest1 c where c.numreqst  = b.numreqst ) as dtereq ,
            (select get_tlistval_name('TSTAREQ',c.stareq, global_v_lang) from treqest1 c where c.numreqst  = b.numreqst ) as stareq_desc,
            (select count(nvl(codempid,0)) from tapplinf where  numreql = b.numreqst and codcomp like a.codcomp || '%' and codposl = a.codpos ) v_cs_emp,
            (select count(*) from temploy1 where numreqst = b.numreqst) as c_numreq
            from temploy1 a, treqest2 b
            where a.codcomp like (p_codcomp ||'%')
            and a.codpos    = p_codpos
            and a.codcomp   like (b.codcomp ||'%')
            and a.codpos    = b.codpos
            and a.codempid  = b.codempr
            and a.dteeffex between  p_dtestrt and  p_dteend
            and not exists( select numreqst
                from treqest2 c
               where c.codcomp   like (p_codcomp ||'%')
                 and  c.codpos   = p_codpos
                 and  nvl(c.qtyact,0) = 0
                 and  c.codrearq = '3'
                 and  c.codpos = b.codpos
                 and  c.numreqst = b.numreqst)
            order by dtereq desc,b.numreqst desc;*/
-->> user22 : 19/03/2022 : ST11 ||            
  begin
    obj_row     := json();
    for r1 in c1 loop
      v_flgdata   := 'Y';
      v_secur  := secur_main.secur2(r1.codempr,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
          v_flgsecur  := 'Y';
          v_rcnt      := v_rcnt+1;
          obj_data    := json();

          obj_data.put('coderror', '200');
          obj_data.put('dtereq', to_char(r1.dtereq, 'dd/mm/yyyy'));
          obj_data.put('numreqst', r1.numreqst);
          obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
          obj_data.put('codempr', r1.codempr);
          obj_data.put('desc_codempr', get_temploy_name(r1.codempr, global_v_lang));
          obj_data.put('dteeffex', to_char(r1.dteeffex, 'dd/mm/yyyy'));
          begin
            select count(numreql)
              into v_count
              from tapplinf 
             where numreql   = r1.numreqst 
               and codcompl  = r1.codcomp
               and codposl   = r1.codpos;
          end;
          obj_data.put('qtyregis', v_count);
          obj_data.put('stareq_desc', get_tlistval_name('TSTAREQ',r1.stareq, global_v_lang));
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_flgdata = 'N' then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    elsif v_flgsecur = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
        return;
    else
        dbms_lob.createtemporary(json_str_output, true);
        obj_row.to_clob(json_str_output);
    end if;
  end gen_index;
----------------------------------------------------------------------------------

end HRRC71X;

/

--------------------------------------------------------
--  DDL for Package Body HRPYB2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYB2E" as
-- last update: 17/09/2020 20:00

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codpfinf      := upper(hcm_util.get_string_t(json_obj,'codpfinf'));
        p_codcomp       := upper(hcm_util.get_string_t(json_obj,'codcomp'));
        p_codempid      := upper(hcm_util.get_string_t(json_obj,'codempid'));
        p_flgemp        := hcm_util.get_string_t(json_obj,'flgemp');
        p_dtedueprst    := to_date(hcm_util.get_string_t(json_obj,'dtedueprst'),'dd/mm/yyyy');
        p_dtedueprnd    := to_date(hcm_util.get_string_t(json_obj,'dtedueprnd'),'dd/mm/yyyy');

        p_codplan      := upper(hcm_util.get_string_t(json_obj,'codplan'));

        -- ถ้าระบุ รหัสพนักงานให้ Clear ค่า รหัสกองทุน และหน่วยงาน
        if p_codempid is not null then
            p_codpfinf := null;
            p_codcomp  := null;
        end if;
    end initial_value;

    procedure initial_value_new(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codpfinf      := upper(hcm_util.get_string_t(json_obj,'codpfinf'));
        p_codempid      := upper(hcm_util.get_string_t(json_obj,'codempid'));
        p_codplan      := upper(hcm_util.get_string_t(json_obj,'codplan'));

    end initial_value_new;

    procedure check_index as
        v_temp varchar2(1 char);
        v_secur boolean;
    begin
        -- บังคับใส่ข้อมูล รหัสกองทุน หรือ รหัสหน่วยงาน หรือ รหัสพนักงาน
        if (p_codpfinf is null) or (p_codcomp is null) or (p_codempid is null) or p_flgemp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
        -- กรณีที่ เลือกสถานะสมาชิก = ใหม่ (3)
        if p_flgemp = '3' then
            -- ระบบจะบังคับให้ระบุ รหัสหน่วยงาน และ ช่วงวันที่ทดลองงานตั้งแต่ และ ถึง
--            if p_dtedueprst is null or p_dtedueprnd is null then
--                param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--                return;
--            end if;

            -- ถ้าระบุวันที่สิ้นสุด น้อยกว่ากว่าที่เริ่มต้นให้ Alert HR2021
            if p_dtedueprst > p_dtedueprnd then
                param_msg_error := get_error_msg_php('HR2021',global_v_lang);
                return;
            end if;
        end if;
        -- รหัสกองทุน รหัสที่ระบุต้องมีอยู่ในตาราง TCODPFINF (หากไม่พบข้อมูล Alert HR2010 TCODPFINF)
        if p_codpfinf is not null then
            begin
                select 'X' into v_temp from tcodpfinf where codcodec = p_codpfinf;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPFINF');
                return;
            end;
        end if;
        -- รหัสหน่วยงาน รหัสที่ระบุต้องมีอยู่ในตาราง TCENTER (หากไม่พบข้อมูล Alert HR2010 TCENTER)
        if p_codcomp is not null then
            begin
                select 'X' into v_temp from tcenter where codcomp like p_codcomp||'%' and rownum = 1;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
                return;
            end;
            -- หน่วยงาน ให้ Check Security หากไม่มีสิทธิ์ Alert HR3007
            param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;
        -- รหัสพนักงาน รหัสพนักงานต้องมีอยู่ในตาราง TEMPLOY(lov_emp1) (หากไม่พบข้อมูล Alert HR2010 TEMPLOY1)
        if p_codempid is not null then
            begin
                select 'X' into v_temp from temploy1 where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;
            -- รหัสพนักงานให้ Check Security หากไม่มีสิทธิ์ Alert HR3007
--            param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,p_codempid);
--            if param_msg_error is not null then
--                return;
--            end if;
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;
    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_secur     boolean;
        v_min_dteduepr  temploy1.dteduepr%type;
        v_max_dteduepr  temploy1.dteduepr%type;
/* --<< user20 Date: 01/09/2021  PY Module- #6571
        cursor c1 is
            select a.codempid, b.codcomp, a.codpfinf, a.codplan,a.flgemp, a.dteeffec, a.dtereti, b.dteempmt,b.dteduepr
            from tpfmemb a, temploy1 b
            where codpfinf = nvl(p_codpfinf,codpfinf)
                and b.codcomp like p_codcomp||'%'
                and b.codcomp like nvl(p_codcomp||'%' , b.codcomp)
                and a.codempid = b.codempid
                and b.staemp not in ('0','9')
                and flgemp = p_flgemp
                and b.codempid = nvl(p_codempid,b.codempid)
            order by b.codempid;
--<< user20 Date: 01/09/2021  PY Module- #6571 */

--<< user20 Date: 01/09/2021  PY Module- #6571
        cursor c1 is
          --<< user4 Date: 10/11/2022 
            /*select b.codempid, b.codcomp, a.codpfinf, a.codplan,a.flgemp, a.dteeffec, a.dtereti, b.dteempmt,b.dteduepr
            from tpfmemb a, temploy1 b
            where b.codempid = nvl(p_codempid,b.codempid)
                and b.codcomp like nvl(p_codcomp||'%' , b.codcomp)
                and b.codcomp like p_codcomp||'%'
                and a.codempid(+) = b.codempid
                and b.staemp not in ('0')
            order by b.codempid;*/
          select a.codempid, b.codcomp, a.codpfinf, a.codplan,a.flgemp, a.dteeffec, a.dtereti, b.dteempmt,b.dteduepr
            from tpfmemb a, temploy1 b
            where codpfinf = nvl(p_codpfinf,codpfinf)
                and b.codcomp like p_codcomp||'%'
                and b.codcomp like nvl(p_codcomp||'%' , b.codcomp)
                and a.codempid = b.codempid
                and b.staemp not in ('0')--and b.staemp not in ('0','9')
                and flgemp = p_flgemp
                and b.codempid = nvl(p_codempid,b.codempid)
            order by b.codempid;
          -->> user4 Date: 10/11/2022 
--<< user20 Date: 01/09/2021  PY Module- #6571

        cursor c_emp is
            select codempid, codcomp, dteempmt, dteduepr, dteempdb,
                codpos, typemp, codempmt, typpayroll,staemp,
                numlvl, jobgrade
            from temploy1
            where codcomp like nvl(p_codcomp||'%',codcomp)
                and trunc(dteduepr) between p_dtedueprst and p_dtedueprnd
                and staemp in (1,3)
                and codempid not in (select codempid from tpfmemb)
            order by codempid;
    begin
        obj_rows := json_object_t();
        -- ถ้าเลือกสถานะสมาชิกเป็น (1-ปัจจุบัน,2-ลาออก) ให้อ่านข้อมูลจาก TPFMEMB Join TEMPLOY1
        if p_flgemp in ('1','2') then
            for r1 in c1 loop
                -- Check Security โดยใช้ secur_main.secur3
                v_secur := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if v_secur = true then
                    v_row := v_row + 1;
                    obj_data := json_object_t();
                    obj_data.put('image',get_emp_img(r1.codempid));
                    obj_data.put('codempid',r1.codempid);
                    obj_data.put('namemp',get_temploy_name(r1.codempid,global_v_lang));
                    obj_data.put('codpfinf',r1.codpfinf);
                    obj_data.put('desc_codpfinf',r1.codpfinf||' - '||get_tcodec_name('TCODPFINF',r1.codpfinf,global_v_lang));
                    obj_data.put('codplan',r1.codplan);
                    obj_data.put('desc_codplan',r1.codplan||' - '||get_tcodec_name('TCODPFPLN',r1.codplan,global_v_lang));
                    obj_data.put('flgemp',r1.flgemp);
                    obj_data.put('desc_flgemp',get_tlistval_name('FLGEMP',r1.flgemp,global_v_lang));
                    obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
                    obj_data.put('dtereti',to_char(r1.dtereti,'dd/mm/yyyy'));
                    obj_data.put('dteempmt',to_char(r1.dteempmt,'dd/mm/yyyy'));
                    obj_data.put('dteduepr',to_char(r1.dteduepr,'dd/mm/yyyy'));
                    obj_rows.put(to_char(v_row-1),obj_data);
                end if;
            end loop;
        elsif p_flgemp = '3' then
            if p_dtedueprst is null or p_dtedueprnd is null then
                select min(dteduepr),max(dteduepr)
                  into v_min_dteduepr,v_max_dteduepr from temploy1
                 where codcomp like nvl(p_codcomp||'%',codcomp)
                   and staemp in (1,3)
                   and codempid not in (select codempid from tpfmemb);

                p_dtedueprst := nvl(p_dtedueprst,v_min_dteduepr);
                p_dtedueprnd := nvl(p_dtedueprnd,v_max_dteduepr);
            end if;
            for r2 in c_emp loop
                v_secur := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if v_secur = true then
                    v_row := v_row + 1;
                    obj_data := json_object_t();
                    obj_data.put('image',get_emp_img(r2.codempid));
                    obj_data.put('codempid',r2.codempid);
                    obj_data.put('namemp',get_temploy_name(r2.codempid,global_v_lang));
                    obj_data.put('dteempmt',to_char(r2.dteempmt,'dd/mm/yyyy'));
                    obj_data.put('dteduepr',to_char(r2.dteduepr,'dd/mm/yyyy'));
                    obj_rows.put(to_char(v_row-1),obj_data);
                end if;
            end loop;
        end if;

        if obj_rows.get_size() = 0 then
            if p_flgemp in ('1','2') then
                -- หากไม่พบข้อมูลให้ Alert HR2055 (TPFMEMB)
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPFMEMB');
            else
                -- หากไม่พบข้อมูลให้ Alert HR2055 (TEMPLOY1)
                param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
            end if;
        end if;
        json_str_output := obj_rows.to_clob;
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
--        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

    function get_tpfeinf_numseq(v_codcompy varchar2) return number as
        v_codcomp   temploy1.codcomp%type;
        v_codpos    temploy1.codpos%type;
        v_typemp    temploy1.typemp%type;
        v_codempmt  temploy1.codempmt%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_staemp    temploy1.staemp%type;
        v_dteempmt  temploy1.dteempmt%type;
        v_qtywork   number;
        v_ages      number;
        v_numlvl    temploy1.numlvl%type;
        v_jobgrade  temploy1.jobgrade%type;
        v_numseq    tpfeinf.numseq%type;
        v_syncond   varchar2(1000 char);
        v_stmt      varchar2(1000 char);
        v_flgfound  boolean;
        cursor c_tpfeinf is
            select codcompy, dteeffec, numseq, syncond, flgconret, flgconded
            from tpfeinf
            where codcompy = v_codcompy
            and dteeffec = (select max(dteeffec)
                            from tpfhinf
                            where codcompy = v_codcompy
                            and dteeffec <= sysdate)
            order by numseq;
    begin
        begin
            select dteempmt, codcomp, typpayroll, codpos, typemp,
                   staemp, codempmt, numlvl, jobgrade,
                   trunc(months_between(sysdate,dteempmt)) qtywork,
                   trunc((months_between(sysdate,dteempdb)/12)) ages
            into   v_dteempmt, v_codcomp, v_typpayroll, v_codpos, v_typemp,
                   v_staemp, v_codempmt, v_numlvl, v_jobgrade, v_qtywork, v_ages
            from   temploy1
            where  codempid = p_codempid;
        exception when no_data_found then
            null;
        end;
        for i in c_tpfeinf loop
            v_numseq := i.numseq;
            v_syncond := i.syncond;
            v_syncond := replace(v_syncond,'V_TEMPLOY.CODEMPID',''''||p_codempid||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.CODCOMP',''''||v_codcomp||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.CODPOS',''''||v_codpos||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.TYPEMP',''''||v_typemp||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.CODEMPMT',''''||v_codempmt||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.TYPPAYROLL',''''||v_typpayroll||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.STAEMP',''''||v_staemp||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.DTEEMPMT',''''||v_dteempmt||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.QTYWORK',''''||v_qtywork||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.AGES',''''||v_ages||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.NUMLVL',''''||v_numlvl||'''');
            v_syncond := replace(v_syncond,'V_TEMPLOY.JOBGRADE',''''||v_jobgrade||'''');
            v_syncond := replace(v_syncond,'TPFMEMB.CODPFINF',''''||p_codpfinf||'''');
            v_stmt := 'select count(*) from dual where '||v_syncond;
            v_flgfound := execute_stmt(v_stmt);
            if v_flgfound then
                return v_numseq;
            end if;
        end loop;
        return v_numseq;
    end get_tpfeinf_numseq;
  --
  function get_plan_table(p_codempid  temploy1.codempid%type,
                          p_codcompy  tcompny.codcompy%type) return json_object_t is
    obj_plan_data     json_object_t;
    obj_plan_row      json_object_t;
    v_rcnt            number := 0;
    v_dteeffec        date;
    v_sum_pctinvt     number := 0;

    cursor c_tpfpcinf is
      select ir.dteeffec, ir.codpfinf, ir.codplan, pc.codpolicy, pc.pctinvt
        from tpfirinf ir, tpfpcinf pc
       where ir.codempid  = p_codempid
         and pc.codcompy  = p_codcompy
         and ir.codpfinf  = pc.codpfinf
         and ir.codplan   = pc.codplan
         and pc.dteeffec  = (select max(dteeffec)
                               from tpfpcinf
                              where codcompy  = p_codcompy
                                and codpfinf  = pc.codpfinf
                                and codplan   = pc.codplan
                                and dteeffec  <= ir.dteeffec)
      order by ir.dteeffec,ir.codplan, pc.codpolicy;
  begin
    obj_plan_row    := json_object_t();
    for r1 in c_tpfpcinf loop
      if nvl(v_dteeffec,r1.dteeffec) <> r1.dteeffec then
        obj_plan_data := json_object_t();
        v_dteeffec    := r1.dteeffec;
        obj_plan_data.put('desc_codpolicy',get_label_name('HRPYB2E',global_v_lang,590));
        obj_plan_data.put('pctinvt',to_char(v_sum_pctinvt,'fm990.00'));
        obj_plan_row.put(to_char(v_rcnt),obj_plan_data);
        v_rcnt        := v_rcnt + 1;
        v_sum_pctinvt := 0;
      end if;
      obj_plan_data := json_object_t();
      obj_plan_data.put('coderror','200');
      obj_plan_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_plan_data.put('codplan',r1.codplan);
      obj_plan_data.put('desc_codplan',get_tcodec_name('TCODPFPLN',r1.codplan,global_v_lang));
      obj_plan_data.put('codpolicy',r1.codpolicy);
      obj_plan_data.put('desc_codpolicy',get_tcodec_name('TCODPFPLC',r1.codpolicy,global_v_lang));
      obj_plan_data.put('pctinvt',to_char(r1.pctinvt,'fm990.00'));
      obj_plan_row.put(to_char(v_rcnt),obj_plan_data);
      v_rcnt        := v_rcnt + 1;
      v_sum_pctinvt := v_sum_pctinvt + r1.pctinvt;
      v_dteeffec    := nvl(v_dteeffec,r1.dteeffec);
    end loop;
    --Last record--
    if v_rcnt > 0 then
      obj_plan_data := json_object_t();
      obj_plan_data.put('desc_codpolicy','   '||get_label_name('HRPYB2E',global_v_lang,590));
      obj_plan_data.put('pctinvt',to_char(v_sum_pctinvt,'fm990.00'));
      obj_plan_row.put(to_char(v_rcnt),obj_plan_data);
    end if;
    return obj_plan_row;
  end;
  --
  function get_rate_table(p_codempid  temploy1.codempid%type) return json_object_t is
    obj_rate_data     json_object_t;
    obj_rate_row      json_object_t;
    v_rcnt            number := 0;

    cursor c_tpfmemrt is
      select codempid, dteeffec, flgdpvf, ratecret
        from tpfmemrt
       where codempid   = p_codempid
      order by dteeffec;
  begin
    obj_rate_row    := json_object_t();
    for r1 in c_tpfmemrt loop
      obj_rate_data := json_object_t();
      obj_rate_data.put('coderror','200');
      obj_rate_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
      obj_rate_data.put('flgdpvf',r1.flgdpvf);
      obj_rate_data.put('ratecret',r1.ratecret);
      obj_rate_row.put(to_char(v_rcnt),obj_rate_data);
      v_rcnt  := v_rcnt + 1;
    end loop;
    return obj_rate_row;
  end;
  --
  function get_member(t_tpfmemb tpfmemb%rowtype) return json_object_t is
    obj_member          json_object_t;
    obj_member_detail   json_object_t;
    obj_plan            json_object_t;
    obj_rate            json_object_t;

    v_codcompy          tcompny.codcompy%type;
    v_numseq            tpfdinf.numseq%type;
    v_flgdpvf           tpfmemrt.flgdpvf%type;
    v_ratecret          tpfmemrt.ratecret%type;
    v_flgresign         tpfhinf.flgresign%type;
    v_ratecsbt          tpfdinf.ratecsbt%type;
    v_rateesbt          tpfdinf.rateesbt%type;
    v_flgconded         tpfmemb.flgconded%type;

    v_found             varchar2(1);
    v_qtywork           number;
    v_workage_day       number;
    v_workage_month     number;
    v_workage_year      number;
    v_empage_day        number;
    v_empage_month      number;
    v_empage_year       number;
    v_cond              varchar2(4000 char);
    v_stmt              varchar2(4000 char);
    v_day2              number;
    v_month2            number;
    v_year2             number;
    v_flgfound          boolean;
    cursor c_tpfmemb is
      select t1.codempid ,t1.dteempmt,t1.dteempdb,t2.dteeffec,
             t2.nummember,t2.flgemp,
             t1.codcomp,t1.codpos,t1.typemp,t1.codempmt,t1.typpayroll,
             t1.staemp,t1.numlvl,t1.jobgrade,t2.codpfinf
        from temploy1 t1,tpfmemb t2
       where t1.codempid  = p_codempid
         and t1.codempid  = t2.codempid(+);

    cursor c_tpfeinf is
      select numseq,syncond,flgconded,flgconret
        from tpfeinf
       where codcompy   = v_codcompy
         and dteeffec   = (select max(dteeffec)
                             from tpfhinf
                            where codcompy  = v_codcompy
                              and dteeffec  <= trunc(sysdate))
      order by numseq;
  begin
    begin
      select 'Y'
        into v_found
        from tpfmemb
       where codempid = p_codempid;
    exception when no_data_found then
      v_found   := 'N';
    end;

    v_codcompy := nvl(get_codcompy(t_tpfmemb.codcomp),hcm_util.get_codcomp_level(t_tpfmemb.codcomp,1));
    if v_codcompy is null then
      begin
       select nvl(get_codcompy(codcomp),hcm_util.get_codcomp_level(codcomp,1))
         into v_codcompy
         from temploy1
        where codempid = p_codempid;
      end;
    end if;

    obj_member_detail := json_object_t();

    if v_found = 'N' then
      obj_member_detail.put('codcompy',v_codcompy);
      obj_member_detail.put('codpfinf','');
      obj_member_detail.put('codplan','');
      obj_member_detail.put('dteeffec',to_char(sysdate,'dd/mm/yyyy'));
      obj_member_detail.put('dtereti','');
      obj_member_detail.put('flgemp','1');
      obj_member_detail.put('codreti','');
      obj_member_detail.put('nummember',p_codempid);
      obj_member_detail.put('flgedit','Add');
    else
      obj_member_detail.put('codcompy',v_codcompy);
      obj_member_detail.put('codpfinf',t_tpfmemb.codpfinf);
      obj_member_detail.put('codplan',t_tpfmemb.codplan);
      obj_member_detail.put('dteeffec',to_char(t_tpfmemb.dteeffec,'dd/mm/yyyy'));
      obj_member_detail.put('dtereti',to_char(t_tpfmemb.dtereti,'dd/mm/yyyy'));
      obj_member_detail.put('flgemp',t_tpfmemb.flgemp);
      obj_member_detail.put('codreti',t_tpfmemb.codreti);
      obj_member_detail.put('nummember',t_tpfmemb.nummember);
      obj_member_detail.put('flgedit','Edit');
    end if;

    begin
      select flgdpvf,ratecret
        into v_flgdpvf,v_ratecret
        from tpfmemrt
       where codempid = p_codempid
         and dteeffec = (select max(dteeffec)
                           from tpfmemrt
                          where codempid = p_codempid
                            and dteeffec <= sysdate)
      order by dteeffec;
    exception when no_data_found then
      v_flgdpvf  := null;
      v_ratecret := null;
    end;

    for r3 in c_tpfmemb loop
      get_service_year(r3.dteempmt,sysdate,'Y',v_workage_year,v_workage_month,v_workage_day);
      get_service_year(r3.dteempdb,sysdate,'Y',v_empage_year ,v_empage_month ,v_empage_day);

      for r2 in c_tpfeinf loop
        v_qtywork := v_workage_year * 12 + v_workage_month;
        v_cond := r2.syncond;
        v_cond := replace(v_cond,'V_TEMPLOY.CODEMPID'  ,''''||r3.codempid||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.CODCOMP'   ,''''||r3.codcomp||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.CODPOS'    ,''''||r3.codpos||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.TYPEMP'    ,''''||r3.typemp||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.CODEMPMT'  ,''''||r3.codempmt||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.TYPPAYROLL',''''||r3.typpayroll||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.STAEMP'    ,''''||r3.staemp||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.DTEEMPMT'  ,'to_date('''||to_char(r3.dteempmt,'dd/mm/yyyy')||''',''dd/mm/yyyy'')');
        v_cond := replace(v_cond,'V_TEMPLOY.QTYWORK'   ,v_qtywork);
        v_cond := replace(v_cond,'V_TEMPLOY.AGES'      ,v_empage_year);
        v_cond := replace(v_cond,'V_TEMPLOY.NUMLVL'    ,''''||r3.numlvl||'''');
        v_cond := replace(v_cond,'V_TEMPLOY.JOBGRADE'  ,''''||r3.jobgrade||'''');
        v_cond := replace(v_cond,'TPFMEMB.CODPFINF'    ,''''||r3.codpfinf||'''');
        v_stmt := 'select count(*) from dual where '||v_cond;
        v_flgfound := execute_stmt(v_stmt);
        if v_flgfound then
          if r2.flgconded = '1' then
            get_service_year(r3.dteeffec,sysdate,'Y',v_year2 ,v_month2 ,v_day2);
            v_month2 := (v_year2 * 12) + v_month2;
          elsif r2.flgconded = '2' then
            get_service_year(r3.dteempmt,sysdate,'Y',v_year2 ,v_month2 ,v_day2);
            v_month2 := (v_year2 * 12) + v_month2;
          else
            v_year2  := null;
            v_month2 := null;
            v_day2   := null;
          end if;
          v_flgconded   := r2.flgconded;
          exit;
        end if;
      end loop;
    end loop;

    if not v_flgfound and v_found = 'N' then
      param_msg_error := get_error_msg_php('PY0051',global_v_lang);
      return obj_member;
    end if;

    v_numseq := get_tpfeinf_numseq(v_codcompy);
    begin
      select ratecsbt, rateesbt
        into v_ratecsbt, v_rateesbt
        from tpfdinf
       where codcompy   = v_codcompy
         and numseq     = v_numseq
         and dteeffec   = (select max(dteeffec)
                             from tpfdinf
                            where dteeffec  <= trunc(sysdate)
                              and codcompy  = v_codcompy
                              and numseq    = v_numseq
                              and v_month2 between qtywkst and qtywken)
         and v_month2 between qtywkst and qtywken
         and rownum   <= 1;
    exception when no_data_found then
      v_ratecsbt  := null;
      v_rateesbt  := null;
    end;

    begin
      select flgresign
        into v_flgresign
        from tpfhinf
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                      from tpfhinf
                      where codcompy = v_codcompy
                      and dteeffec < sysdate);
    exception when no_data_found then
        v_flgresign := 'N';
    end;

    obj_member_detail.put('ratecsbt',nvl(v_ratecsbt,0));
    obj_member_detail.put('ratecret',nvl(v_ratecret,0));
    obj_member_detail.put('rateesbt',nvl(v_rateesbt,0));
    if v_flgdpvf = '2' then
      obj_member_detail.put('disp_rate',nvl(v_ratecret,0));
    else
      obj_member_detail.put('disp_rate',nvl(v_rateesbt,0));
    end if;
    obj_member_detail.put('flgresign',v_flgresign);
    obj_member_detail.put('qtywken',v_month2);
    obj_member_detail.put('flgconded',v_flgconded);
    obj_plan      := get_plan_table(p_codempid,get_codcompy(t_tpfmemb.codcomp));
    obj_rate      := get_rate_table(p_codempid);

    obj_member    := json_object_t();
    obj_member.put('member_detail', obj_member_detail);
    obj_member.put('plan_table', obj_plan);
    obj_member.put('rate_table', obj_rate);

    return obj_member;
  end;
  --
  procedure gen_detail(json_str_output out clob) as
    obj_member        json_object_t;
    obj_benefic_row   json_object_t;
    obj_benefic_data  json_object_t;
    obj_result        json_object_t;

    v_row             number := 0;
    rec_tpfmemb       tpfmemb%rowtype;
    v_staemp          temploy1.staemp%type;

    cursor c_tpficinf is
      select codempid,numseq,nampfic,adrpfic,desrel,ratepf
        from tpficinf
       where codempid = p_codempid
      order by numseq;

    begin
      begin
        select * into rec_tpfmemb
          from tpfmemb
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;

      begin
        select staemp into v_staemp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_staemp    := null;
      end;

      obj_benefic_row   := json_object_t();
      for r4 in c_tpficinf loop
          obj_benefic_data := json_object_t();
          obj_benefic_data.put('numseq',r4.numseq);
          obj_benefic_data.put('nampfic',r4.nampfic);
          obj_benefic_data.put('adrpfic',r4.adrpfic);
          obj_benefic_data.put('desrel',r4.desrel);
          obj_benefic_data.put('ratepf',r4.ratepf);
          obj_benefic_row.put(to_char(v_row),obj_benefic_data);
          v_row := v_row + 1;
      end loop;

      obj_member    := get_member(rec_tpfmemb);

      obj_result := json_object_t();
      obj_result.put('coderror','200');
      obj_result.put('codempid',get_codempid(rec_tpfmemb.coduser));
      obj_result.put('coduser',rec_tpfmemb.coduser);
      obj_result.put('dteupd',to_char(rec_tpfmemb.dteupd,'dd/mm/yyyy'));
      obj_result.put('desc_coduser',get_temploy_name(get_codempid(rec_tpfmemb.coduser),global_v_lang));
--      obj_result.put('member',obj_member);
      if v_staemp = '9' then
        obj_result.put('msg_reponse',get_terrorm_name('HR2101',global_v_lang));
      end if;
      obj_result.put('member_detail',hcm_util.get_json_t(obj_member,'member_detail'));
      obj_result.put('plan_table',hcm_util.get_json_t(obj_member,'plan_table'));
      obj_result.put('rate_table',hcm_util.get_json_t(obj_member,'rate_table'));
      obj_result.put('benefic_table',obj_benefic_row);
      json_str_output := obj_result.to_clob;
    end gen_detail;
  --
    procedure check_get_detail as
        v_temp      varchar2(1 char);
        v_dteeffex  temploy1.dteeffex%type;
    begin
        if p_codempid is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        else
            begin
                select 'X', dteeffex into v_temp, v_dteeffex from temploy1 where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
                return;
            end;

--            param_msg_error := hcm_secur.secur_codempid(global_v_coduser,global_v_lang,p_codempid);
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;

/*--<< user20 Date: 01/09/2021  PY Module- #6571
            if v_dteeffex <= trunc(sysdate) then
              param_msg_error := get_error_msg_php('HR2101',global_v_lang);
              return;
            end if;
--<< user20 Date: 01/09/2021  PY Module- #6571 */
        end if;
    end check_get_detail;

    procedure get_detail(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_get_detail;
        if param_msg_error is null then
            gen_detail(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_detail;

    procedure upd_log
       (p_numpage varchar2,
        p_fldedit varchar2,
        p_typkey varchar2,
        p_desold varchar2,
        p_desnew varchar2,
        p_codtable varchar2,
        p_numseq number,
        p_codseq varchar2 default null,
        p_dteseq date default null) as

        v_datenew 	 date;
        v_dateold 	 date;
        v_desnew 	 varchar2(500) ;
        v_desold 	 varchar2(500) ;
        v_codcomp    varchar2(40) ;
    begin
        if (p_desold is null and p_desnew is not null) or
        (p_desold is not null and p_desnew is null) or
        (p_desold <> p_desnew) then
            v_desnew := p_desnew ;
            v_desold := p_desold ;
            if  p_typkey = 'D' then
                if  p_desnew is not null and global_v_zyear = 543 then
                    v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
                    v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
                end if;
                if  p_desold is not null and global_v_zyear = 543 then
                    v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
                    v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
                end if;
            end if;
            begin
                select codcomp into v_codcomp
                from temploy1
                where codempid = p_codempid;
            end;
            insert into tpfmlog (codempid,dteedit,numpage,numseq,fldedit,typkey,fldkey,
                                 codcomp,desold,desnew,codtable,codseq,codcreate,coduser,dteseq)
            values (p_codempid,sysdate,p_numpage,p_numseq,p_fldedit,p_typkey,p_fldedit,
                    v_codcomp,v_desold,v_desnew,p_codtable,p_codseq,global_v_coduser,global_v_coduser,p_dteseq);
        end if;
    exception when others then
        rollback;
    end upd_log;
  --
    procedure validate_save(param_tab1 json_object_t,param_tab2 json_object_t) as
        v_codpfinf  tpfphinf.codpfinf%type;
        v_codplan   tpfmemb.codplan%type;
        v_dteeffec  tpfmemb.dteeffec%type;
        v_dtereti   tpfmemb.dtereti%type;
        v_flgemp    tpfmemb.flgemp%type;
        v_codreti   tpfmemb.codreti%type;

        json_member  json_object_t;
        json_tpfmemrt       json_object_t;
        obj_tpfmemrt        json_object_t;
        obj_tab2            json_object_t;

        v_codcompy  tcenter.codcompy%type;
        v_temp      varchar2(1 char);
        v_flgsys    varchar2(1 char);
        v_syncond   varchar2(1000 char);
        v_stmt      varchar2(1000 char);
        v_flgfound  boolean;

        v_codcomp   temploy1.codcomp%type;
        v_codpos    temploy1.codpos%type;
        v_typemp    temploy1.typemp%type;
        v_codempmt  temploy1.codempmt%type;
        v_typpayroll    temploy1.typpayroll%type;
        v_staemp    temploy1.staemp%type;
        v_dteempmt  temploy1.dteempmt%type;
        v_qtywork   number;
        v_ages      number;
        v_numlvl    temploy1.numlvl%type;
        v_jobgrade  temploy1.jobgrade%type;
        v_numseq    tpfeinf.numseq%type;

        v_flgresign tpfhinf.flgresign%type;
        v_qtyremth  tpfhinf.qtyremth%type;

        p_tpfmemrt_flg_delete boolean;
        p_flgdpvf   tpfmemrt.flgdpvf%type;
        p_ratecret  tpfmemrt.ratecret%type;
        p_ratepf    tpficinf.ratepf%type;
        p_pctsum    number :=0;

        v_flgemp_old    tpfmemb.flgemp%type;
        v_count     number :=0;
        v_resign    date;
        v_chk       varchar2(1);

        cursor c_tpfeinf is
          select codcompy, dteeffec, numseq, syncond, flgconret, flgconded
            from tpfeinf
           where codcompy = v_codcompy
             and dteeffec = (select max(dteeffec)
                               from tpfhinf
                              where codcompy = v_codcompy
                                and dteeffec <= trunc(sysdate))
          order by numseq;

        cursor c_tpfregst is
            select *
            from tpfregst
            where codempid = p_codempid
            order by dteeffec desc;
    begin
      json_member := hcm_util.get_json_t(param_tab1,'detail');
      v_codpfinf  := upper(hcm_util.get_string_t(json_member,'codpfinf'));
      v_codplan   := hcm_util.get_string_t(json_member,'codplan');
      v_dteeffec  := to_date(hcm_util.get_string_t(json_member,'dteeffec'),'dd/mm/yyyy');
      v_dtereti   := to_date(hcm_util.get_string_t(json_member,'dtereti'),'dd/mm/yyyy');
      v_flgemp    := hcm_util.get_string_t(json_member,'flgemp');
      v_codreti   := hcm_util.get_string_t(json_member,'codreti');
      json_tpfmemrt := hcm_util.get_json_t(json_member,'table1');

      begin
          select flgemp into v_flgemp_old from tpfmemb where codempid = p_codempid;
      exception when no_data_found then
          v_flgemp_old := '0';
      end;

      -- get codcompy
      begin
          select nvl(get_codcompy(codcomp),hcm_util.get_codcomp_level(codcomp,'1')) into v_codcompy from temploy1
          where codempid = p_codempid;
      exception when no_data_found then
          v_codcompy := null;
      end;

      -- อ่านข้อมูล วันที่มีผล, สถานะสมัครสมาชิกใหม่เมื่อลาออก ,สมัครสมาชิกใหม่ครั้งที่ 2 ภายในระยะเวลา(เดือน) จากตาราง TPFHINF where รหัสบริษัท และวันทีมีผลบังคับใช้ล่าสุดที่น้อยกว่าวันที่   SYSDATE
      begin
--<<redmine PY-2408
          --select dteeffec, flgresign, qtyremth  into v_dteeffec, v_flgresign, v_qtyremth
-->>redmine PY-2408
          select flgresign, qtyremth  into  v_flgresign, v_qtyremth
          from tpfhinf
          where codcompy = v_codcompy
          and dteeffec = (select max(dteeffec)
                          from tpfhinf
                          where codcompy = v_codcompy
                          and dteeffec < sysdate);
      exception when no_data_found then
          null;
      end;
      -- เช็คเงื่อนไข กองทุน โดยอ่านข้อมูลจากตาราง TPFEINF และมาเช็คกับเงื่อนไขของพนักงานจาก   TEMPLOY1
      begin
          select dteempmt, codcomp, typpayroll, codpos, typemp,
                 staemp, codempmt, numlvl, jobgrade,
                 trunc(months_between(sysdate,dteempmt)) qtywork,
                 trunc((months_between(sysdate,dteempdb)/12)) ages
          into   v_dteempmt, v_codcomp, v_typpayroll, v_codpos, v_typemp,
                 v_staemp, v_codempmt, v_numlvl, v_jobgrade, v_qtywork, v_ages
          from   temploy1
          where  codempid = p_codempid;
      exception when no_data_found then
          null;
      end;

      -- ถ้าระบุ วันสมัครกองทุน น้อยกว่า วันที่เข้างาน ให้ Alert PY0016 วันที่เป็นสมาชิกต้องมากกว่าวันที่เข้าท างาน
      if v_dteeffec < v_dteempmt then
          param_msg_error := get_error_msg_php('PY0016',global_v_lang);
          return;
      end if;

      if v_dtereti is  null then
        begin
          select 'Y'
            into v_chk
            from tpfpcinf
           where codcompy   = v_codcompy
             and codpfinf   = v_codpfinf
             and codplan    = v_codplan
             and dteeffec   = (select max(dteeffec)
                                 from tpfpcinf
                                where codcompy  = v_codcompy
                                  and codpfinf  = v_codpfinf
                                  and codplan   = v_codplan
                                  and dteeffec  <= trunc(v_dteeffec))--User37 #2361 Final Test Phase 1 V11 08/02/2021 trunc(sysdate))
             and rownum     <= 1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPFPCINF');
          return;
        end;
      end if;

      -- ข้อมูลผู้รับผลประโยชน์
      for i in 0..param_tab2.get_size-1 loop
        obj_tab2      := hcm_util.get_json_t(param_tab2,to_char(i));
        p_ratepf      := to_number(hcm_util.get_string_t(obj_tab2,'ratepf'));
        p_tpfmemrt_flg_delete := hcm_util.get_boolean_t(obj_tab2,'flgDelete');
        -- หากมีการระบุ ชื่อ ให้   Validate บังคับให้ระบุ   %ผลประโยชน์ ด้วย
--        if p_tpfmemrt_flgedit != 'delete' and p_ratepf is null then
        if not p_tpfmemrt_flg_delete and p_ratepf is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;
--        if p_tpfmemrt_flgedit != 'delete' then
        if not p_tpfmemrt_flg_delete then
            p_pctsum := p_pctsum + p_ratepf;
        end if;
      end loop;

      if param_tab2.get_size > 0 then
          -- ผลรวมของ%   ผลประโยชน์ ต้องไม่เกิน 100   หากระบุเกินให้   Alert PY0052
          if p_pctsum != 100 then
              param_msg_error := get_error_msg_php('PY0052',global_v_lang);
              return;
          end if;
      end if;
      if (v_flgemp_old = '1' and v_flgemp = '1') or (v_flgemp_old = '0' and v_flgemp = '1') then

          -- ข้อมูลที่ต้องระบุ รหัสกองทุน,แผนการลงทุน,วันที่สมัคร หากไม่ระบุให้ Alert HR2045
          if v_codpfinf is null or v_codplan is null or v_dteeffec is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
              return;
          end if;

          v_flgsys := 'N';
          for i in c_tpfeinf loop
              v_numseq := i.numseq;
              v_syncond := i.syncond;
              v_syncond := replace(v_syncond,'V_TEMPLOY.CODEMPID',''''||p_codempid||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.CODCOMP',''''||v_codcomp||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.CODPOS',''''||v_codpos||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.TYPEMP',''''||v_typemp||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.CODEMPMT',''''||v_codempmt||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.TYPPAYROLL',''''||v_typpayroll||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.STAEMP',''''||v_staemp||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.DTEEMPMT',''''||v_dteempmt||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.QTYWORK',''''||v_qtywork||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.AGES',''''||v_ages||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.NUMLVL',''''||v_numlvl||'''');
              v_syncond := replace(v_syncond,'V_TEMPLOY.JOBGRADE',''''||v_jobgrade||'''');
              v_syncond := replace(v_syncond,'TPFMEMB.CODPFINF',''''||v_codpfinf||'''');
              v_stmt := 'select count(*) from dual where '||v_syncond;
              v_flgfound := execute_stmt(v_stmt);
              if v_flgfound then
                  v_flgsys := 'Y';
                  exit;
              end if;
          end loop;

          -- หากระบุ กองทุน ที่ไม่สิทธิ์ให้   Alert   PY0051 - พนักงานไม่อยู่ในเงื่อนไขของกองทุนฯ
          if v_flgsys = 'N' then
              param_msg_error := get_error_msg_php('PY0051',global_v_lang);
              return;
          end if;

          -- อัตราการหักเงินส่วนของพนักงาน
          for i in 0..json_tpfmemrt.get_size-1 loop
              obj_tpfmemrt := hcm_util.get_json_t(json_tpfmemrt,to_char(i));
              p_flgdpvf := hcm_util.get_string_t(obj_tpfmemrt,'flgdpvf');
              p_ratecret := hcm_util.get_string_t(obj_tpfmemrt,'ratecret');
              -- กรณีที่เลือกก าหนดเอง ให้บังคับระบุ   %   อัตราหากไม่ระบุให้   Alert HR2045
              if p_flgdpvf = '2' and p_ratecret is null then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
          end loop;
      elsif v_flgemp_old = '1' and v_flgemp = '2' then
          -- ให้ระบุ วันที่ลาออก และ รหัสเหตุผลการลาออก หากไม่ระบุ ให้   Alert HR2045
          if v_dtereti is null or v_codreti is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
              return;
          end if;

          -- รหัสสาเหตุการลาออก ต้องมีข้อมูลในตาราง TCODEXEM   หากไม่พบข้อมูล   Alert HR2010 (TCODEXEM)
          begin
              select 'X' into v_temp from tcodexem where codcodec = v_codreti;
          exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEXEM');
              return;
          end;

          --  ถ้าระบุวันที่ลาออกน้อยกว่าวันที่สมัครเป็น สมาชิก ให้   Alert PY0017  วันที่ลาออกต้องมากกว่าวันที่เป็นสมาชิก
          if v_dtereti < v_dteeffec then
              param_msg_error := get_error_msg_php('PY0017',global_v_lang);
              return;
          end if;
--2364 ถ้าระบุวันที่ลาออกย้อนหลัง ในเดือนที่คำนวณภาษีไปแล้ว
/*
          begin
              select 'X' into v_temp
                from tdtepay t1 ,ttaxcur t2
               where t2.codempid = p_codempid
                 and t2.codcompy = t1.codcompy
                 and t2.dteyrepay = t1.dteyrepay
                 and t2.dtemthpay = t1.dtemthpay
                 and t2.numperiod = t1.numperiod
                 and v_dtereti <= t1.dteend
                 and rownum = 1;
              param_msg_error := get_error_msg_php('PY0067',global_v_lang);
              return;
          exception when no_data_found then null;
          end;
          */
--2364
      elsif v_flgemp_old = '2' and v_flgemp = '1' then
          -- หากระบุวันที่สมัครในช่วงวันที่ลาออกให้   Alert Alert PY0050 - วันที่สมัครสมาชิกต้องไม่อยู่ในช่วงวันที่สมัครและลาออกเดิม
          begin
              select count(*) into v_count
              from tpfregst
              where codempid = p_codempid
              and v_dteeffec between dteeffec and dtereti
              and dtereti is not null;
          end;
          if v_count <> 0 then
              param_msg_error := get_error_msg_php('PY0050',global_v_lang);
              return;
          end if;

          -- วันที่สมัครใหม่ต้องอยู่ในช่วงระยะเวลาที่กำหนด หากเกินให้ Alert PY0049- ไม่สามารถสมัครสมาชิกใหม่ได้เนื่องจากลาออกไม่ครบกำหนด
          if v_flgresign = 'Y' and v_qtyremth is not null then
              for r_reti in c_tpfregst loop
                  v_resign := add_months(r_reti.dtereti,v_qtyremth);
                  exit;
              end loop;
              if v_dteeffec < v_resign then--user37 #2367 Final Test Phase 1 V11 07/02/2021 v_dteeffec > v_resign then
                  param_msg_error := get_error_msg_php('PY0049',global_v_lang);
                  return;
              end if;
          end if;
      end if;

      if v_flgemp_old = '1' and v_flgemp = '2' then

        if v_dtereti > v_dteeffec then
          begin
            select count(*) into v_count
              from tdtepay
             where v_dtereti < dteend
               and codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and typpayroll = v_typpayroll
               and flgcal = 'Y'
             order by dteend Desc;
          exception when no_data_found then
            null;
          end;
        end if;
/*
        if v_count > 0 then
            param_msg_error := get_error_msg_php('PY0072',global_v_lang);
            return;
        end if;
*/
      end if;

    end validate_save;

    procedure save_data(param_tab1 json_object_t,param_tab2 json_object_t,json_str_output out clob) as
      tab1_flgedit        varchar2(10 char);
      tab1_dteeffec       tpfmemb.dteeffec%type;
      tab1_flgemp         tpfmemb.flgemp%type;
      tab1_nummember      tpfmemb.nummember%type;
      tab1_codpfinf       tpfmemb.codpfinf%type;
      tab1_codplan        tpfmemb.codplan%type;
      tab1_dtereti        tpfmemb.dtereti%type;
      tab1_codreti        tpfmemb.codreti%type;
      tab1_qtywken        tpfmemb.qtywken%type;
      tab1_flgconded      tpfmemb.flgconded%type;
      tab1_ratecsbt       tpfmemb.ratecret%type;
      tab1_rateesbt       tpfmemb.rateeret%type;

      json_member         json_object_t;
      json_tpfmemrt       json_object_t;
      obj_tpfmemrt        json_object_t;
      tpfmemrt_flgedit    varchar2(10 char);
      tpfmemrt_dteeffec   tpfmemrt.dteeffec%type;
      tpfmemrt_flgdpvf    tpfmemrt.flgdpvf%type;
      tpfmemrt_ratecret   tpfmemrt.ratecret%type;

      obj_tab2            json_object_t;
      tab2_flg_add        boolean;
      tab2_flg_edit       boolean;
      tab2_flg_delete     boolean;
      tab2_numseq         tpficinf.numseq%type;
      tab2_nampfic        tpficinf.nampfic%type;
      tab2_adrpfic        tpficinf.adrpfic%type;
      tab2_desrel         tpficinf.desrel%type;
      tab2_ratepf         tpficinf.ratepf%type;
      v_new_numseq        number:=0;
      v_log_numseq        number:=0;
      rec_tpfmemb         tpfmemb%rowtype;
      rec_old_tpfmemb     tpfmemb%rowtype;
      rec_old_tpficinf    tpficinf%rowtype;
      rec_old_tpfmemrt    tpfmemrt%rowtype;
      v_temp              varchar2(1 char);
      rec_temploy1        temploy1%rowtype;

      v_numseq            tpfdinf.numseq%type;
      rec_tpfdinf         tpfdinf%rowtype;
      v_flgdpvf           tpfmemrt.flgdpvf%type;
      v_rateeret          tpfmemb.rateeret%type;
      v_ratecret          tpfmemb.ratecret%type;

      v_sysdate             date  := trunc(sysdate);
      function get_log_numseq(p_numpage varchar2) return number is
        v_log_seq   number;
      begin
        select nvl(max(numseq),0)+1 into v_log_seq
          from tpfmlog
         where codempid = p_codempid
           and trunc(dteedit) = v_sysdate
           and numpage = 'HRPYB2C20';
        return v_log_seq;
      end;
    begin
      json_member     := hcm_util.get_json_t(param_tab1,'detail');
      tab1_flgedit    := hcm_util.get_string_t(json_member,'flgedit');
      tab1_dteeffec   := to_date(hcm_util.get_string_t(json_member,'dteeffec'),'dd/mm/yyyy');
      tab1_flgemp     := hcm_util.get_string_t(json_member,'flgemp');
      tab1_nummember  := hcm_util.get_string_t(json_member,'nummember');
      tab1_codpfinf   := upper(hcm_util.get_string_t(json_member,'codpfinf'));
      tab1_codplan    := hcm_util.get_string_t(json_member,'codplan');
      tab1_dtereti    := to_date(hcm_util.get_string_t(json_member,'dtereti'),'dd/mm/yyyy');
      tab1_codreti    := hcm_util.get_string_t(json_member,'codreti');
      tab1_qtywken    := hcm_util.get_string_t(json_member,'qtywken');
      tab1_flgconded  := hcm_util.get_string_t(json_member,'flgconded');
      tab1_ratecsbt   := to_number(hcm_util.get_string_t(json_member,'ratecsbt'));
      tab1_rateesbt   := to_number(hcm_util.get_string_t(json_member,'rateesbt'));
      json_tpfmemrt   := hcm_util.get_json_t(param_tab1,'table1');

      -- Tab รายละเอียดสมาชิก เก็บข้อมูล ลงที่ตาราง TPFMEMB
      v_log_numseq  := get_log_numseq('HRPYB2C10');
      begin
        select *
          into rec_temploy1
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        rec_temploy1 := null;
      end;

      begin
        select *
          into rec_old_tpfmemb
          from tpfmemb
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;

      if tab1_flgedit = 'Add' then
        -- วันที่สมัคร
        insert into tpfmemb (codempid,dteeffec,flgemp,nummember,codpfinf
                            ,codplan,dtereti,codreti,codcreate,coduser
                            ,codcomp,typpayroll,qtywken,flgconded)
        values (p_codempid,tab1_dteeffec,tab1_flgemp,tab1_nummember,tab1_codpfinf,
                tab1_codplan,tab1_dtereti,tab1_codreti,global_v_coduser,global_v_coduser,
                rec_temploy1.codcomp,rec_temploy1.typpayroll,tab1_qtywken,tab1_flgconded);
        --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C10','CODEMPID','C',null,p_codempid,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','DTEEFFEC','D',null,to_char(tab1_dteeffec,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','FLGEMP','C',null,tab1_flgemp,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','NUMMEMBER','C',null,tab1_nummember,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODPFINF','C',null,tab1_codpfinf,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODPLAN','C',null,tab1_codplan,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','DTERETI','D',null,to_char(tab1_dtereti,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODRETI','C',null,tab1_codreti,'TPFMEMB',v_log_numseq);

        v_log_numseq  := get_log_numseq('HRPYB2C11');
        insert into tpfirinf (codempid,dteeffec,codplan,codpfinf,
                              codcreate,coduser)
        values (p_codempid,tab1_dteeffec,tab1_codplan,tab1_codpfinf,
                global_v_coduser,global_v_coduser);
        --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C11','DTEEFFEC','D',null,to_char(tab1_dteeffec,'dd/mm/yyyy'),'TPFIRINF',v_log_numseq,tab1_codplan);
        --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C11','CODPLAN','C',null,tab1_codplan,'TPFIRINF',v_log_numseq,tab1_codplan);
        upd_log('HRPYB2C11','CODPFINF','C',null,tab1_codpfinf,'TPFIRINF',v_log_numseq,tab1_codplan);
      elsif tab1_flgedit = 'Edit' then
        if rec_old_tpfmemb.codcomp is null or rec_old_tpfmemb.typpayroll is null then
          update tpfmemb
             set codcomp = rec_temploy1.codcomp,
                 typpayroll = rec_temploy1.typpayroll
           where codempid = p_codempid;
        end if;

        update tpfmemb set
            dteeffec = tab1_dteeffec,
            flgemp = tab1_flgemp,
            nummember = tab1_nummember,
            codpfinf = tab1_codpfinf,
            codplan = tab1_codplan,
            dtereti = tab1_dtereti,
            codreti = tab1_codreti,
            qtywken = tab1_qtywken,
            flgconded = tab1_flgconded,
            coduser = global_v_coduser
        where codempid = p_codempid;

        if rec_old_tpfmemb.flgemp = '2' and tab1_flgemp = '1' then
          update tpfmemb
             set amtcaccu = null,
                 amtcretn = null,
                 amteaccu = null,
                 amteretn = null,
                 amtinteccu = null,
                 amtintaccu = null,
                 rateeret = null,
                 ratecret = null
           where codempid = p_codempid;
        end if;
        upd_log('HRPYB2C10','DTEEFFEC','D',to_char(rec_old_tpfmemb.dteeffec,'dd/mm/yyyy'),to_char(tab1_dteeffec,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','FLGEMP','C',rec_old_tpfmemb.flgemp,tab1_flgemp,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','NUMMEMBER','C',rec_old_tpfmemb.nummember,tab1_nummember,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODPFINF','C',rec_old_tpfmemb.codpfinf,tab1_codpfinf,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODPLAN','C',rec_old_tpfmemb.codplan,tab1_codplan,'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','DTERETI','D',to_char(rec_old_tpfmemb.dtereti,'dd/mm/yyyy'),to_char(tab1_dtereti,'dd/mm/yyyy'),'TPFMEMB',v_log_numseq);
        upd_log('HRPYB2C10','CODRETI','C',rec_old_tpfmemb.codreti,tab1_codreti,'TPFMEMB',v_log_numseq);

        if tab1_codplan <> rec_old_tpfmemb.codplan or tab1_codpfinf <> rec_old_tpfmemb.codpfinf then
          v_log_numseq  := get_log_numseq('HRPYB2C11');
          insert into tpfirinf (codempid,dteeffec,codplan,codpfinf,
                                codcreate,coduser)
          values (p_codempid,v_sysdate,tab1_codplan,tab1_codpfinf,
                  global_v_coduser,global_v_coduser);
          --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C11','DTEEFFEC','D',null,to_char(v_sysdate,'dd/mm/yyyy'),'TPFIRINF',v_log_numseq,tab1_codplan);
          --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C11','CODPLAN','C',rec_old_tpfmemb.codplan,tab1_codplan,'TPFIRINF',v_log_numseq,tab1_codplan);
          upd_log('HRPYB2C11','CODPFINF','C',rec_old_tpfmemb.codpfinf,tab1_codpfinf,'TPFIRINF',v_log_numseq,tab1_codplan);
        end if;
      end if;
      -- Tab ข้อมูลผู้รับผลประโยชน์ เก็บข้อมูล ลงที่ตาราง TPFICINF
      for i in 0..param_tab2.get_size-1 loop
          obj_tab2 := hcm_util.get_json_t(param_tab2,to_char(i));
          tab2_numseq  := hcm_util.get_string_t(obj_tab2,'numseq');
          tab2_nampfic := hcm_util.get_string_t(obj_tab2,'nampfic');
          tab2_adrpfic := hcm_util.get_string_t(obj_tab2,'adrpfic');
          tab2_desrel  := hcm_util.get_string_t(obj_tab2,'desrel');
          tab2_ratepf  := hcm_util.get_string_t(obj_tab2,'ratepf');
          tab2_flg_add    := hcm_util.get_boolean_t(obj_tab2,'flgAdd');
          tab2_flg_edit   := hcm_util.get_boolean_t(obj_tab2,'flgEdit');
          tab2_flg_delete := hcm_util.get_boolean_t(obj_tab2,'flgDelete');

          v_log_numseq  := get_log_numseq('HRPYB2C20');
          if tab2_flg_add then
              begin
                  select nvl(max(numseq),0)+1 into v_new_numseq
                  from tpficinf
                  where codempid = p_codempid;
              end;
              insert into tpficinf (codempid,numseq,nampfic,adrpfic,desrel,ratepf,codcreate,coduser)
              values (p_codempid,v_new_numseq,tab2_nampfic,tab2_adrpfic,tab2_desrel,tab2_ratepf,global_v_coduser,global_v_coduser);
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 ('HRPYB2C20','CODEMPID','C',null,p_codempid,'TPFICINF',v_log_numseq,1);
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C20','NUMSEQ','N',null,to_char(v_new_numseq),'TPFICINF',v_log_numseq,2);
              upd_log('HRPYB2C20','NAMPFIC','C',null,tab2_nampfic,'TPFICINF',v_log_numseq,3);
              upd_log('HRPYB2C20','ADRPFIC','C',null,tab2_adrpfic,'TPFICINF',v_log_numseq,4);
              upd_log('HRPYB2C20','DESREL','C',null,tab2_desrel,'TPFICINF',v_log_numseq,5);
              upd_log('HRPYB2C20','RATEPF','N',null,to_char(tab2_ratepf),'TPFICINF',v_log_numseq,6);
          elsif tab2_flg_edit then
              begin
                  select * into rec_old_tpficinf
                  from tpficinf
                  where codempid = p_codempid
                  and numseq = tab2_numseq;
              end;
              upd_log('HRPYB2C20','NAMPFIC','C',rec_old_tpficinf.nampfic,tab2_nampfic,'TPFICINF',v_log_numseq,3);
              upd_log('HRPYB2C20','ADRPFIC','C',rec_old_tpficinf.adrpfic,tab2_adrpfic,'TPFICINF',v_log_numseq,4);
              upd_log('HRPYB2C20','DESREL','C',rec_old_tpficinf.desrel,tab2_desrel,'TPFICINF',v_log_numseq,5);
              upd_log('HRPYB2C20','RATEPF','N',to_char(rec_old_tpficinf.ratepf),to_char(tab2_ratepf),'TPFICINF',v_log_numseq,6);
              update tpficinf set
                  nampfic = tab2_nampfic,
                  adrpfic = tab2_adrpfic,
                  desrel  = tab2_desrel,
                  ratepf  = tab2_ratepf,
                  coduser = global_v_coduser
              where codempid = p_codempid
              and numseq = tab2_numseq;
          elsif tab2_flg_delete then
              begin
                  select * into rec_old_tpficinf
                  from tpficinf
                  where codempid = p_codempid
                  and numseq = tab2_numseq;
              end;
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C20','CODEMPID','C',rec_old_tpficinf.codempid,null,'TPFICINF',v_log_numseq,1);
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C20','NUMSEQ','N',to_char(rec_old_tpficinf.numseq),null,'TPFICINF',v_log_numseq,2);
              upd_log('HRPYB2C20','NAMPFIC','C',rec_old_tpficinf.nampfic,null,'TPFICINF',v_log_numseq,3);
              upd_log('HRPYB2C20','ADRPFIC','C',rec_old_tpficinf.adrpfic,null,'TPFICINF',v_log_numseq,4);
              upd_log('HRPYB2C20','DESREL','C',rec_old_tpficinf.desrel,null,'TPFICINF',v_log_numseq,5);
              upd_log('HRPYB2C20','RATEPF','N',to_char(rec_old_tpficinf.ratepf),null,'TPFICINF',v_log_numseq,6);
              delete from tpficinf
              where codempid = p_codempid
              and numseq = tab2_numseq;
          end if;
      end loop;

      v_log_numseq  := get_log_numseq('HRPYB2C20');
      -- ข้อมูลสมาชิกลาออก เก็บข้อมูลตาราง TPFREGST
      if tab1_flgedit = 'Edit' and tab1_flgemp = '2' then
        begin
          insert into tpfregst (codempid,dtereti,dteeffec,codreti,amtcaccu,amtcretn,
                                amteaccu,amteretn,amtinteccu,amtintaccu,rateeret,ratecret,
                                codpfinf,codplan,codcreate,coduser)
          values (p_codempid,tab1_dtereti,rec_old_tpfmemb.dteeffec,tab1_codreti,
                  rec_old_tpfmemb.amtcaccu,rec_old_tpfmemb.amtcretn,rec_old_tpfmemb.amteaccu,rec_old_tpfmemb.amteretn,
                  rec_old_tpfmemb.amtinteccu,rec_old_tpfmemb.amtintaccu,rec_old_tpfmemb.rateeret,rec_old_tpfmemb.ratecret,
                  tab1_codpfinf,tab1_codplan,global_v_coduser,global_v_coduser);
        exception when dup_val_on_index then
          update tpfregst
             set dteeffec    = rec_old_tpfmemb.dteeffec,
                 codreti     = tab1_codreti,
                 amtcaccu    = rec_old_tpfmemb.amtcaccu,
                 amtcretn    = rec_old_tpfmemb.amtcretn,
                 amteaccu    = rec_old_tpfmemb.amteaccu,
                 amteretn    = rec_old_tpfmemb.amteretn,
                 amtinteccu  = rec_old_tpfmemb.amtinteccu,
                 amtintaccu  = rec_old_tpfmemb.amtintaccu,
                 rateeret    = rec_old_tpfmemb.rateeret,
                 ratecret    = rec_old_tpfmemb.ratecret,
                 codpfinf    = tab1_codpfinf,
                 codplan     = tab1_codplan,
                 coduser     = global_v_coduser
          where codempid = p_codempid
            and dtereti = tab1_dtereti;
        end;
      end if;
      -- อัตราการหักเงินส่วนของพนักงาน  บันทึกข้อมูลลงตาราง TPFMEMRT
      for i in 0..(json_tpfmemrt.get_size - 1) loop
          obj_tpfmemrt := hcm_util.get_json_t(json_tpfmemrt,to_char(i));
          tpfmemrt_dteeffec := to_date(hcm_util.get_string_t(obj_tpfmemrt,'dteeffec'),'dd/mm/yyyy');
          tpfmemrt_flgdpvf  := hcm_util.get_string_t(obj_tpfmemrt,'flgdpvf');
          tpfmemrt_ratecret := to_number(hcm_util.get_string_t(obj_tpfmemrt,'ratecret'));
          tpfmemrt_flgedit  := hcm_util.get_string_t(obj_tpfmemrt,'flg');

          begin
            select *
              into rec_old_tpfmemrt
              from tpfmemrt
             where codempid = p_codempid
               and dteeffec = tpfmemrt_dteeffec;
          exception when no_data_found then
            null;
          end;

          v_log_numseq  := get_log_numseq('HRPYB2C12');
          if tpfmemrt_flgedit = 'add' then
            begin
              insert into tpfmemrt (codempid,dteeffec,flgdpvf,ratecret,ratecsbt,
                                    codcreate,coduser)
              values (p_codempid,tpfmemrt_dteeffec,tpfmemrt_flgdpvf,tpfmemrt_ratecret,tab1_ratecsbt,
                      global_v_coduser,global_v_coduser);
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C12','CODEMPID','C',null,p_codempid,'TPFMEMRT',v_log_numseq);
              --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C12','DTEEFFEC','D',null,to_char(tpfmemrt_dteeffec,'dd/mm/yyyy'),'TPFMEMRT',v_log_numseq);
              upd_log('HRPYB2C12','FLGDPVF','C',null,tpfmemrt_flgdpvf,'TPFMEMRT',v_log_numseq);
              upd_log('HRPYB2C12','RATECRET','N',null,to_char(tpfmemrt_ratecret),'TPFMEMRT',v_log_numseq, null, tpfmemrt_dteeffec);
            exception when dup_val_on_index then
              param_msg_error := get_error_msg_php('HR2005',global_v_lang,'tpfmemrt');
              exit;
            end;
          elsif tpfmemrt_flgedit = 'edit' then
            upd_log('HRPYB2C12','FLGDPVF','C',rec_old_tpfmemrt.flgdpvf,tpfmemrt_flgdpvf,'TPFMEMRT',v_log_numseq);
            upd_log('HRPYB2C12','RATECRET','N',rec_old_tpfmemrt.ratecret,to_char(tpfmemrt_ratecret),'TPFMEMRT',v_log_numseq, null, tpfmemrt_dteeffec);
            update tpfmemrt set
                flgdpvf = tpfmemrt_flgdpvf,
                ratecret = tpfmemrt_ratecret,
                ratecsbt = tab1_ratecsbt,
                coduser = global_v_coduser
            where codempid = p_codempid
            and dteeffec = tpfmemrt_dteeffec;
          elsif tpfmemrt_flgedit = 'delete' then
            --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C12','CODEMPID','C',p_codempid,null,'TPFMEMRT',v_log_numseq);
            --User37 Final Test Phase 1 V11 #2400 26/11/2020 upd_log('HRPYB2C12','DTEEFFEC','D',to_char(rec_old_tpfmemrt.dteeffec,'dd/mm/yyyy'),null,'TPFMEMRT',v_log_numseq);
            upd_log('HRPYB2C12','FLGDPVF','C',rec_old_tpfmemrt.flgdpvf,null,'TPFMEMRT',v_log_numseq);
            upd_log('HRPYB2C12','RATECRET','N',rec_old_tpfmemrt.ratecret,null,'TPFMEMRT',v_log_numseq);
            delete from tpfmemrt
             where codempid = p_codempid
               and dteeffec = tpfmemrt_dteeffec;
          end if;
      end loop;
      -- search rateeret,ratecret
      v_numseq := get_tpfeinf_numseq(get_codcompy(rec_temploy1.codcomp));
      begin
          select * into rec_tpfdinf
            from tpfdinf
           where codcompy = get_codcompy(rec_temploy1.codcomp)
--               and dteeffec <= nvl(tab1_dteeffec,sysdate)
             and dteeffec = (select max(dteeffec)
                               from tpfdinf
                              where dteeffec <= sysdate
                                and codcompy =get_codcompy(rec_temploy1.codcomp)
                                and numseq = v_numseq)
             and numseq = v_numseq
             and (select trunc(months_between(sysdate,dteempmt))
                    from temploy1
                   where codempid = p_codempid)
                  between qtywkst and qtywken;
      exception when no_data_found then
          rec_tpfdinf := null;
      end;

      begin
          select flgdpvf,ratecret
          into v_flgdpvf,v_ratecret
          from tpfmemrt
          where codempid = p_codempid
          and dteeffec = (select max(dteeffec)
                            from tpfmemrt
                           where codempid = p_codempid
                             and dteeffec <= sysdate)
          order by dteeffec;
      exception when no_data_found then
          v_flgdpvf  := null;
          v_ratecret := null;
      end;
      if v_flgdpvf = '2' then
          v_rateeret := v_ratecret;
      else
          v_rateeret := rec_tpfdinf.rateesbt;
      end if;

      -- update
      begin
          update tpfmemb
          set rateeret = v_rateeret,
              ratecret = rec_tpfdinf.ratecsbt
          where codempid = p_codempid;
      end;
      -- /rateeret,ratecret

      if param_msg_error is null then
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
          commit;
      else
          json_str_output := get_response_message('400',param_msg_error,global_v_lang);
          rollback;
      end if;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    exception when others then
        rollback;
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_data;

    procedure save_detail(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        json_tab1   json_object_t;
        json_tab2   json_object_t;
    begin
        initial_value(json_str_input);
        json_obj    := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');

        json_tab1   := hcm_util.get_json_t(json_obj,'tab1');
        json_tab2   := hcm_util.get_json_t(json_obj,'tab2');
        validate_save(json_tab1,json_tab2);
        if param_msg_error is null then
            save_data(json_tab1,json_tab2,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end save_detail;

    procedure gen_tpfpcinf(json_str_input in clob, json_str_output out clob) as
        json_obj    json_object_t;
        obj_rows    json_object_t;
        obj_data    json_object_t;
        v_row       number := 0;
        v_codcompy  tpfpcinf.codcompy%type;
        v_codpfinf  tpfpcinf.codpfinf%type;
        v_codplan   tpfpcinf.codplan%type;
        cursor c_tpfpcinf is
            select codcompy,codpfinf,codpolicy,pctinvt, codplan
            from tpfpcinf
            where codpfinf = v_codpfinf
            and codplan = v_codplan
            and codcompy = v_codcompy
            and dteeffec = (select max(dteeffec) from tpfpcinf
                            where codpfinf = v_codpfinf
                            and codplan = v_codplan
                            and codcompy = v_codcompy
                            and dteeffec <= trunc(sysdate))
            order by codpolicy;
    begin
        json_obj    := json_object_t(json_str_input);
        v_codpfinf  := upper(hcm_util.get_string_t(json_obj,'codpfinf'));
        v_codplan   := upper(hcm_util.get_string_t(json_obj,'codplan'));
        begin
            select nvl(get_codcompy(codcomp),hcm_util.get_codcomp_level(codcomp,'1')) into v_codcompy
            from temploy1
            where codempid = p_codempid;
        exception when no_data_found then
            v_codcompy := null;
        end;
        obj_rows := json_object_t();
        for r1 in c_tpfpcinf loop
                v_row := v_row + 1;
                obj_data := json_object_t();
                obj_data.put('codplan',r1.codplan);
                obj_data.put('desc_codplan',r1.codplan||' - '||get_tcodec_name('TCODPFPLN',r1.codplan,global_v_lang));
                obj_data.put('codpolicy',r1.codpolicy);
                obj_data.put('desc_codpolicy',r1.codpolicy||' - '||get_tcodec_name('TCODPFPLC',r1.codpolicy,global_v_lang));
                obj_data.put('qtycompst',r1.pctinvt);
                obj_rows.put(to_char(v_row-1),obj_data);
        end loop;
        json_str_output := obj_rows.to_clob;
    end gen_tpfpcinf;

    procedure get_tpfpcinf(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_tpfpcinf(json_str_input,json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_tpfpcinf;
  procedure gen_tpfregst(json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_rcnt        number  := 0;
    cursor c_tpfregst is
      select dtereti,dteeffec,codreti,codpfinf,codplan
        from tpfregst
       where codempid   = p_codempid
      order by dtereti;

  begin
    obj_row   := json_object_t();
    for i in c_tpfregst loop
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('dteeffec',to_char(i.dteeffec,'dd/mm/yyyy'));
      obj_data.put('codpfinf',i.codpfinf);
      obj_data.put('desc_codpfinf',get_tcodec_name('TCODPFINF',i.codpfinf,global_v_lang));
      obj_data.put('codplan',i.codplan);
      obj_data.put('desc_codplan',get_tcodec_name('TCODPFPLN',i.codplan,global_v_lang));
      obj_data.put('dtereti',to_char(i.dtereti,'dd/mm/yyyy'));
      obj_data.put('codreti',i.codreti);
      obj_data.put('desc_codreti',get_tcodec_name('TCODEXEM',i.codreti,global_v_lang));
      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt      := v_rcnt + 1;
    end loop;

    json_str_output     := obj_row.to_clob;
  end;
  --
  procedure get_history(json_str_input in clob, json_str_output out clob) as
  begin
      initial_value(json_str_input);
      if param_msg_error is null then
          gen_tpfregst(json_str_output);
      else
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_plan(json_str_output out clob) as
    obj_data        json_object_t;
    obj_row   json_object_t;
    v_codcompy  tcenter.codcompy%type;


    v_row             number := 0;
    rec_tpfmemb       tpfmemb%rowtype;

    cursor c1 is
      select codplan, get_tcodec_name('TCODPFPLN',codplan,global_v_lang) desc_codplan,
                get_tcodec_name('TCODPFPLC',codpolicy,global_v_lang) desc_codpolicy,
                pctinvt,dteeffec
                from tpfpcinf a
                where codpfinf = p_codpfinf
                and codplan = p_codplan
                and codcompy = v_codcompy
                and dteeffec = (select max(b.dteeffec)
                                   from tpfpcinf b
                                  where b.codcompy = a.codcompy
                                    and b.codpfinf = a.codpfinf
                                    and b.codplan  = a.codplan
                                    and b.dteeffec <= trunc(sysdate))
                order by codplan,codpolicy;

    begin

      begin
        select hcm_util.get_codcomp_level(codcomp,1) into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        null;
      end;

      obj_row   := json_object_t();
      for r1 in c1 loop
          obj_data := json_object_t();
          obj_data.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
          obj_data.put('desc_codplan',r1.desc_codplan);
          obj_data.put('desc_codpolicy',r1.desc_codpolicy);
          obj_data.put('pctinvt',r1.pctinvt);
          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row + 1;
      end loop;

      json_str_output := obj_row.to_clob;
    end ;

  procedure get_detail_plan(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value_new(json_str_input);
        if param_msg_error is null then
            gen_detail_plan(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end ;

end HRPYB2E;

/

--------------------------------------------------------
--  DDL for Package Body HRBF5LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5LX" AS
-- last update: 26/01/2021 16:01
    procedure initial_value(json_str_input in clob) is
        json_obj json;
    begin
        json_obj          := json(json_str_input);
        global_v_coduser  := hcm_util.get_string(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codlon            := upper(hcm_util.get_string(json_obj,'codlon'));
        p_codcomp           := upper(hcm_util.get_string(json_obj,'codcomp'));
        p_codempid          := upper(hcm_util.get_string(json_obj,'codempid'));
        p_dte_st            := to_date(hcm_util.get_string(json_obj,'dte_st'),'dd/mm/yyyy');
        p_dte_en            := to_date(hcm_util.get_string(json_obj,'dte_en'),'dd/mm/yyyy');

    end initial_value;

    procedure check_index as
        v_temp varchar2(1 char);
    begin
        if p_dte_st is null or p_dte_en is null or (p_codcomp is null and p_codempid is null)   then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_dte_st > p_dte_en then
            param_msg_error := get_error_msg_php('HR2021',global_v_lang);
            return;
        end if;

        if p_codempid is not null then
            begin
                select 'Y' into v_temp
                from temploy1 a
                where a.codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            end;
        end if;

        if p_codcomp is not null then
            -- ('HR3007')
            param_msg_error :=  HCM_SECUR.secur_codcomp( global_v_coduser, global_v_lang, p_codcomp);
            if param_msg_error is not null then
                return;
            end if;
        end if;

        if p_codlon is not null then
            begin
                select 'Y' into v_temp
                from ttyploan a
                where a.codlon = p_codlon;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TTYPLOAN');
            end;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        obj_rows    json;
        obj_child    json;
        obj_data_child    json;
        v_row       number := 0;
        v_row_secur number := 0;
        v_row_child number := 0;
        v_numcont           tloaninf.numcont%type;

        v_sum       number := 0;

        v_amtpfinen           tloanpay.amtpfinen%type;
        v_amtinten           tloanpay.amtinten%type;

        v_dtestrt          ttrepayh.dtestrt%type;
        v_type             varchar2(1);
        v_flgincst          varchar2(1);

        cursor c1 is
            select a.codcomp, a.numcont, a.codempid, a.codlon, a.amtnpfin
            from tloaninf a
            where codcomp like nvl(p_codcomp,a.codcomp)||'%'
            and codempid = nvl(p_codempid,a.codempid)
            and codlon = nvl(p_codlon,a.codlon)
            and (a.dtestcal between p_dte_st and p_dte_en
            or ( exists ( select b.numcont
                        from ttrepayh b
                        where b.dtestrt between p_dte_st and p_dte_en
                        and b.dteend between p_dte_st and p_dte_en
                        and b.numcont = a.numcont)
            or exists ( select c.numcont
                        from tloanpay c
                        where c.dterepmt between p_dte_st and p_dte_en)
            or exists ( select d.numcont
                        from tloanadj d
                        where d.dteeffec between p_dte_st and p_dte_en
                        and d.numcont = a.numcont)
            ))
            order by a.codempid,a.codlon,a.numcont;

        cursor c_dtestrt is
            select dtestrt dtestrt, 'ttrepayh' tname, 1 type
            from ttrepayh
            where numcont = v_numcont
            and dtestrt between p_dte_st and p_dte_en
            union
            select dterepmt dtestrt, 'tloanpay' tname, 2 type
            from tloanpay
            where numcont = v_numcont
            and dterepmt between p_dte_st and p_dte_en
            union
            select dteeffec dtestrt, 'tloanadj' tname, 3 type
            from tloanadj
            where numcont = v_numcont
            and dteeffec between p_dte_st and p_dte_en
            --order by dtestrt;
            order by dtestrt,type;

        cursor c_1_int is
            select dtestrt,nvl(amtintst,0) amtintst
            from ttrepayh
            where numcont = v_numcont
            and dtestrt = v_dtestrt
            and nvl(amtintst,0) > 0
            and v_type = '1'
            order by dtestrt;

        cursor c_2_prin is
            select dtestrt,nvl(amtprinc,0) amtprinc
            from ttrepayh
            where numcont = v_numcont
            and dtestrt = v_dtestrt
            and v_type = '1'
            order by dtestrt;

       cursor c_amtprinc is
            select dtestrt,nvl(amtprinc,0) amtprinc
            from ttrepayh
            where numcont = v_numcont
            and dtestrt = (select max(dtestrt)
                                 from ttrepayh
                              where numcont = v_numcont
                                  and dtestrt <= v_dtestrt)
            order by dtestrt;

        cursor c_3_intcal is
            select dtestrt,nvl(amtintrest,0) amtintrest
            from ttrepayh
            where numcont = v_numcont
            and dtestrt = v_dtestrt
            and v_type = '1'
            order by dtestrt;

        cursor c_4_payp is
            select nvl(amtpfin,0) amtpfin, nvl(amtpint,0) amtpint, nvl(amtpfinen,0) amtpfinen, nvl(amtinten,0) amtinten, dterepmt, typtran
            from tloanpay
            where numcont = v_numcont
            and dterepmt = v_dtestrt
            and v_type = '2'
            order by dterepmt, typtran;

        cursor c_5_adjpay is
            select nvl(amtlonn,0) amtlonn,nvl(amtpintn,0) amtpintn,nvl(amtlono,0) amtlono, nvl(amtpinto,0) amtpinto, dteadjust
            from tloanadj
            where numcont = v_numcont
            and typtran = '1'
            and dteeffec = v_dtestrt
            and v_type = '3'
            order by dteeffec;

        cursor c_6_adjint is
            select ratelono,nvl(ratelonn,0) ratelonn, dteadjust
            from tloanadj
            where numcont = v_numcont
            and typtran = '4'
            and ratelono <> nvl(ratelonn,ratelono)
            and dteeffec = v_dtestrt
            and v_type = '3'
            order by dteeffec;

        cursor c_7_adjprin is
            select nvl(amtpfinn,0) amtpfinn, amtpfino, dteadjust, amtpinto2,amtlonn,amtlono,amtpintn2
            from tloanadj
            where numcont = v_numcont
            and typtran = '3'
            and amtpfino <> nvl(amtpfinn,amtpfino)
            and dteeffec = v_dtestrt
            and v_type = '3'
            order by dteeffec;

        cursor c_8_adjint is
            select  amtpinto2,nvl(amtpintn2,0) amtpintn2, dteadjust, amtlono,amtpfinn,amtpfino
            from tloanadj
            where numcont = v_numcont
            and typtran = '3'
            and amtpinto2 <> nvl(amtpintn2,amtpinto2)
            and dteeffec = v_dtestrt
            and v_type = '3'
            order by dteeffec;

        cursor c_9_adjint is
            select formulao, formulan, dteadjust
            from tloanadj
            where numcont = v_numcont
              and typtran = '3'
              and ratelono <> nvl(ratelonn, ratelono)
              and dteeffec = v_dtestrt
              and v_type = '3'
            order by dteeffec;

        cursor c_10_adjint is
            select formulao,formulan, dteadjust
            from tloanadj
            where numcont = v_numcont
            and typtran = '4'
            and formulao <> nvl(formulan,formulao)
            and dteeffec = v_dtestrt
            and v_type = '3'
            order by dteeffec;

    begin
        obj_rows := json();
        obj_child  := json();
        for i in c1 loop
            v_row := v_row+1;
            if secur_main.secur3(i.codcomp,i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) = true then
                v_row_secur := v_row_secur+1;
                v_sum := 0;
                v_numcont := i.numcont;
                v_row_child := 0;
                v_flgincst    := 'N';

                for j in c_dtestrt loop

                    v_type   := j.type;
                    v_dtestrt := j.dtestrt;
                    if v_row != 1 then
                        for k in c_1_int loop  --ttrepayh
                            v_row_child := v_row_child+1;
                            obj_data_child := json;
                            obj_data_child.put('codlon',i.codlon);
                            obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                            obj_data_child.put('image',get_emp_img(i.codempid));
                            obj_data_child.put('codempid',i.codempid);
                            obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                            obj_data_child.put('numcont',i.numcont);
                            obj_data_child.put('dtestrt','');
                            obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'160')); -- 'ดอกเบี้ยค้างชำระ ยกมา'
                            obj_data_child.put('debit',k.amtintst);
                            obj_data_child.put('credit','');
                            v_sum := v_sum + k.amtintst;
                            obj_data_child.put('remain',k.amtintst);
                            obj_child.put(to_char(v_row_child-1),obj_data_child);
                        end loop;
                    end if;

                    if v_flgincst   = 'N' then
                    	for k in c_2_prin loop  --ttrepayh
	                 		v_flgincst  := 'Y';
	                        v_row_child := v_row_child+1;
	                        obj_data_child := json;
	                        obj_data_child.put('codlon',i.codlon);
	                        obj_data_child.put('codlon_desc', get_ttyploan_name(i.codlon,global_v_lang));

	                        obj_data_child.put('image',get_emp_img(i.codempid));
	                        obj_data_child.put('codempid',i.codempid);
	                        obj_data_child.put('codempid_desc', get_temploy_name(i.codempid,global_v_lang));

	                        obj_data_child.put('numcont',i.numcont);
	                        obj_data_child.put('dtestrt','');
	                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'170')); --'เงินต้นยกมา'
	                        obj_data_child.put('debit', k.amtprinc);
	                        obj_data_child.put('credit','');
	                        v_sum := v_sum + k.amtprinc;
	                        obj_data_child.put('remain',v_sum);
	                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    	end loop;

	                     if v_flgincst   = 'N' then
	                           for l in c_amtprinc loop  --ttrepayh
	                               v_flgincst  := 'Y';
	                               v_row_child := v_row_child+1;
	                               obj_data_child := json;
	                               obj_data_child.put('codlon',i.codlon);
	                               obj_data_child.put('codlon_desc', get_ttyploan_name(i.codlon,global_v_lang));

	                               obj_data_child.put('image',get_emp_img(i.codempid));
	                               obj_data_child.put('codempid',i.codempid);
	                               obj_data_child.put('codempid_desc', get_temploy_name(i.codempid,global_v_lang));

	                               obj_data_child.put('numcont',i.numcont);
	                               obj_data_child.put('dtestrt','');
	                               obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'170')); --'เงินต้นยกมา'
	                               obj_data_child.put('debit', l.amtprinc);
	                               obj_data_child.put('credit','');
	                               v_sum := v_sum + l.amtprinc;
	                               obj_data_child.put('remain',v_sum);
	                               obj_child.put(to_char(v_row_child-1),obj_data_child);
	                           end loop;
	                   end if ;--v_flgincst   = 'N'
                   end if;-- if v_flgincst   = 'N' then


                    for k in c_3_intcal loop  --ttrepayh
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dtestrt,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'180')); --'ดอกเบี้ย'
                        obj_data_child.put('debit',k.amtintrest);
                        obj_data_child.put('credit','');
                        v_sum := v_sum + k.amtintrest;
                        obj_data_child.put('remain', v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_4_payp loop  --tloanpay
                        v_amtpfinen := k.amtpfinen;
                        v_amtinten  := k.amtinten;

                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dterepmt,'dd/mm/yyyy'));
                        --obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'190')||' '||k.typtran); -- 'ชำระเงินต้น'
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'190')||'  ('||get_tlistval_name( 'TYPTRAN',k.typtran,global_v_lang)||')'  ); -- 'ชำระเงินต้น'


                        obj_data_child.put('debit','');
                        obj_data_child.put('credit',k.amtpfin);
                        v_sum := v_sum - k.amtpfin;
                        obj_data_child.put('remain',v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);

                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dterepmt,'dd/mm/yyyy'));
                        --obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'200')||' '||k.typtran); -- 'ชำระดอกเบี้ย'
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'200')||'  ('||get_tlistval_name( 'TYPTRAN',k.typtran,global_v_lang)||')'  );  -- 'ชำระดอกเบี้ย'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit',k.amtpint);
                        v_sum := v_sum - k.amtpint;
                        obj_data_child.put('remain', v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_5_adjpay loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'210')); -- 'แก้ไขการผ่อนชำระครั้งสุดท้าย ชำระเงินต้น'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit',k.amtlonn);
                        v_sum := v_sum + k.amtlono - k.amtlonn;
                        obj_data_child.put('remain', v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);

                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'220')); -- 'แก้ไขการผ่อนชำระครั้งสุดท้าย ชำระดอกเบี้ย'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit',k.amtpintn);
                        v_sum := v_sum + k.amtpinto - k.amtpintn;
                        obj_data_child.put('remain', v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_6_adjint loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'230')||' '||to_char(k.ratelono)||'%'||' => '||to_char(k.ratelonn)||'%'); -- 'แก้ไขอัตราดอกเบี้ย'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit','');
                        obj_data_child.put('remain', '');
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_10_adjint loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'230')||' '||hcm_formula.get_description(k.formulao,global_v_lang)||'%'||' => '||hcm_formula.get_description(k.formulan,global_v_lang)||'%'); -- 'แก้ไขอัตราดอกเบี้ย'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit','');
                        obj_data_child.put('remain', '');
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_7_adjprin loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'240')||' '||to_char(k.amtpfino,'fm99,999,990.00')||' => '||to_char(k.amtpfinn,'fm99,999,990.00') ); -- 'เงินต้นค้างชำระ'
                        obj_data_child.put('debit','');

                        obj_data_child.put('credit','');

                        v_sum := nvl(k.amtpfinn,0) + nvl(k.amtpinto2,0);

                        obj_data_child.put('remain',v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_8_adjint loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'250')||' '||to_char(k.amtpinto2,'fm99,999,990.00')||' => '||to_char(k.amtpintn2,'fm99,999,990.00')); --'ดอกเบี้ยค้างชำระ'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit','');
                        if k.amtpfinn is null then 
                          v_sum := nvl(k.amtpintn2,0) + nvl(k.amtpfino,0);
                        else
                          v_sum := nvl(k.amtpintn2,0) + nvl(k.amtpfinn,0);
                        end if;

                        obj_data_child.put('remain', v_sum);
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;

                    for k in c_9_adjint loop  --tloanadj
                        v_row_child := v_row_child+1;
                        obj_data_child := json;
                        obj_data_child.put('codlon',i.codlon);
                        obj_data_child.put('codlon_desc',get_ttyploan_name(i.codlon,global_v_lang));

                        obj_data_child.put('image',get_emp_img(i.codempid));
                        obj_data_child.put('codempid',i.codempid);
                        obj_data_child.put('codempid_desc',get_temploy_name(i.codempid,global_v_lang));

                        obj_data_child.put('numcont',i.numcont);
                        obj_data_child.put('dtestrt',to_char(k.dteadjust,'dd/mm/yyyy'));
                        obj_data_child.put('detail',get_label_name('HRBF5LX',global_v_lang,'260')||' '||to_char(k.formulao)||' => '||to_char(k.formulan)); --'แก้ไขสูตรคำนวณดอกเบี้ย'
                        obj_data_child.put('debit','');
                        obj_data_child.put('credit', '');
                        obj_data_child.put('remain', '');
                        obj_child.put(to_char(v_row_child-1),obj_data_child);
                    end loop;
                end loop;
            end if;
        end loop;
        if v_row_secur = 0  and v_row > 0 then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
        if v_row = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLOANINF');
        end if;
        dbms_lob.createtemporary(json_str_output, true);
        obj_child.to_clob(json_str_output);
    end gen_index;

    procedure get_index(json_str_input in clob, json_str_output out clob) as
    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        end if;
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

END HRBF5LX;

/

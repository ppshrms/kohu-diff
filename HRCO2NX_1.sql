--------------------------------------------------------
--  DDL for Package Body HRCO2NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO2NX" as

    procedure initial_value(json_str_input in clob) is
        json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

        hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

        p_codapp        := upper(hcm_util.get_string_t(json_obj,'codapp'));
        p_codcomp       := upper(hcm_util.get_string_t(json_obj,'codcomp'));
        p_codpos        := upper(hcm_util.get_string_t(json_obj,'codpos'));
        p_codempid      := hcm_util.get_string_t(json_obj,'codempid');

    end initial_value;

    procedure check_index as
        v_temp      varchar2(4 char);
    begin
        --  ฟิลด์ที่บังคับใส่ข้อมูล
        if p_codapp is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codcomp is null and p_codempid is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            return;
        end if;

        if p_codempid is not null then
            p_codcomp := null;
            p_codpos  := null;
        end if;

        -- รหัสต้องมีข้อมูลในตารางที่กำหนด
        begin
            select 'X' into v_temp
            from twkfunct
            where codapp = p_codapp;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'twkfunct');
            return;
        end;

        if p_codempid is not null then
            begin
                select 'X' into v_temp
                from temploy1
                where codempid = p_codempid;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
                return;
            end;
        end if;

        if p_codcomp is not null then
            begin
                select 'X' into v_temp
                from tcenter
                where codcomp like p_codcomp||'%'
                fetch first 1 rows only;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcenter');
                return;
            end;
        end if;

        if p_codpos is not null then
            begin
                select 'X' into v_temp
                from tpostn
                where codpos = p_codpos;
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tpostn');
                return;
            end;
        end if;

        -- รหัสพนักงานที่ระบุ ต้องไม่เป็นพนักงานพ้นสภาพ temploy1.staemp != 9
        if p_codempid is not null then
            begin
                select 'X' into v_temp
                from temploy1
                where codempid = p_codempid
                and staemp <> '9';
            exception when no_data_found then
                param_msg_error := get_error_msg_php('HR2101',global_v_lang);
                return;
            end;
        end if;

        -- รหัสหน่วยงาน check secur_main.secur7
        if p_codcomp is not null then
            if secur_main.secur7(p_codcomp,global_v_coduser) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

        -- รหัสพนักงาน check secur_main.secur2
        if p_codempid is not null then
            if secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) = false then
                param_msg_error := get_error_msg_php('HR3007',global_v_lang);
                return;
            end if;
        end if;

    end check_index;

    procedure find_route(p_codapp   in  varchar2,
                 p_codempid in  varchar2,
                 p_routeno  out varchar2,
                 p_seqno    out number,
                 p_strseq   out number)  is

    v_stmt      varchar2(2000) ;
    v_codcomp   tcenter.codcomp%type;
    v_codpos    varchar2(10);

/* redmine #5306
    cursor c_temproute is
        select routeno
        from temproute
         where codapp      = p_codapp
           and p_codempid  like codempid
           and v_codcomp   like codcomp
           and v_codpos    like codpos
    order by codempid desc,codcomp desc;
redmine #5306 */

-- redmine #5306
    cursor c_temproute is
        select routeno
        from temproute
         where codapp      = p_codapp
           and p_codempid  like codempid||'%'
           and v_codcomp   like codcomp||'%'
           and v_codpos    like codpos||'%'
    order by codempid desc,codcomp desc;
-- redmine #5306

    cursor c_twkflph is
        select routeno,syncond,seqno,1  as strseq
          from twkflph
         where codapp = p_codapp
    order by seqno ;

    begin
        begin
        select codcomp,codpos into v_codcomp,v_codpos
          from temploy1
         where codempid = p_codempid;
        exception when no_data_found then null;
        end;

        for i in c_temproute loop
            p_routeno := i.routeno;
            p_seqno	  := 1;
            p_strseq  := 1;
            return;
        end loop;

        for i in c_twkflph loop
            if i.syncond is null then
                p_routeno := i.routeno;
                p_seqno		:= i.seqno;
                p_strseq  := i.strseq;
                return;
            else
                v_stmt := 'select count(codempid) from temploy1 where ( '||i.syncond||' ) and codempid ='''||p_codempid||'''' ;
                if execute_qty(v_stmt) > 0 then
                    p_routeno := i.routeno;
                    p_seqno		:= i.seqno;
                    p_strseq  := i.strseq;
                    exit;
                end if;
            end if;
        end loop ;
    end find_route;

    procedure gen_data (json_str_output out clob) as
        v_routeno     varchar2(10 char);
        v_strseq      number;
        v_first       varchar2(1 char);
        v_first2      varchar2(1 char);
        v_codapp2     varchar2(100 char);
        v_seq         number;
        v_codapp_seq  number  := 0;
        v_flgpass     boolean;
        v_found       varchar2(1 char);
        obj_row       json_object_t;
        obj_data      json_object_t;
        v_row         number := 0;
        flg_data      varchar2(1 char);
        v_flgskip     varchar2(1):= 'N';

        -- ข้อมูลพนักงาน
        cursor c_temploy1 is
            select codempid,codcomp,codpos,rowid
            from temploy1
            where codempid like nvl(p_codempid,'%') 
              and codcomp like p_codcomp||'%' 
              and codpos = nvl(p_codpos,codpos) 
              and staemp <> '9'
            order by codempid;

        -- ลำดับที่อนุมัติ
        cursor c_twkflowd is
            select a.routeno,a.numseq,typeapp,codcompa,codposa,codempa
            from twkflowd a,twkflowh b
            where
                a.routeno = b.routeno and
                a.routeno = v_routeno;
--            order by a.numseq;

        cursor c_ttemprpt is
            select item1 as codappr
            from ttemprpt
            where
                codempid = global_v_coduser and
                codapp like v_codapp2||'%'
            group by item1
            order by item1;

        -- อ่านข้อมูลตาราง temp table โดยอ่าน item2,item3,item4 จาก ttemprpt
        cursor c_ttemprpt2 is
            select item2 as codempa,item3 as codcompa,item4 as codposa
            from ttemprpt
            where
                codempid = global_v_coduser and
                codapp like v_codapp2||'%'
            group by item2,item3,item4
            order by item2,item3,item4;

        r1count  number := 0;
    begin
        obj_row := json_object_t();
        for r1 in c_temploy1 loop
--            v_routeno   := chk_workflow.find_route(p_codapp,r1.codempid);
            find_route(p_codapp,r1.codempid,v_routeno,v_seq,v_strseq);
            v_strseq    := chk_workflow.find_strseq(p_codapp,r1.codempid);
            if v_routeno is not null then
                flg_data := 'Y';
                -- รหัสพนักงาน check secur_main.secur2
                v_flgpass := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
                if v_flgpass = true then
                    -- clear ข้อมูลใน temp table เพื่อ insert data ใหม่
                    delete ttemprpt
                    where
                        codempid = global_v_codempid and
                        codapp like p_codapp||'%';

                    v_first2 := 'Y';
                    for r2 in c_twkflowd loop
                        if v_first2 = 'Y' then
                            v_first2 := 'N';
--                            v_codapp2 := v_codapp||to_char(r2.numseq);
                            v_codapp2 := p_codapp||to_char(r2.numseq);
                            gen_approval_list(r1.codempid,r2.routeno,r2.numseq,v_codapp2,global_v_coduser);
                        else
--                            v_codapp2 := v_codapp||to_char(r2.numseq-1);
                            v_codapp2 := p_codapp||to_char(r2.numseq-1);
                            v_codapp_seq := 0;
                            for r3 in c_ttemprpt loop
                                v_codapp_seq := v_codapp_seq+1;
                                v_codapp2 := p_codapp||to_char(r2.numseq)||to_char(v_codapp_seq);
                                gen_approval_list(r3.codappr,r2.routeno,r2.numseq,v_codapp2,global_v_coduser);
                            end loop; -- c_ttemprpt
                        end if;

--                        v_codapp2 := v_codapp||to_char(r2.numseq);
                        v_codapp2 := p_codapp||to_char(r2.numseq);
                        for r4 in c_ttemprpt2 loop
                            v_found := 'Y';
                            v_first := 'N';
                            v_row := v_row+1;

                            v_flgskip := 'N';
                            if r4.codempa is null then
                              v_flgskip := 'Y';
                            end if;

                            obj_data := json_object_t();
                            obj_data.put('coderror', '200');
                            obj_data.put('desc_coderror', ' ');
                            obj_data.put('codempid',r1.codempid);
                            obj_data.put('image',get_emp_img(r1.codempid));
                            obj_data.put('employ_name',get_temploy_name(r1.codempid,global_v_lang));
                            obj_data.put('routeno',v_routeno);
                            obj_data.put('condtno',v_seq);
                            obj_data.put('numseq',r2.numseq);
                            obj_data.put('typeapp',get_tlistval_name('TYPEAPP',r2.typeapp,global_v_lang));
                            obj_data.put('codcompa',get_tcenter_name(r4.codcompa,global_v_lang));
                            obj_data.put('codposa',get_tpostn_name(r4.codposa,global_v_lang));
--                            obj_data.put('codcompa',get_tcenter_name(r2.codcompa,global_v_lang));
--                            obj_data.put('codposa',get_tpostn_name(r2.codposa,global_v_lang));
--                            obj_data.put('codempa',r4.codempa);
                            obj_data.put('_codempid',r4.codempa);
                            if r4.codcompa is not null then
                              obj_data.put('flgbreak','Y');
                            end if;
                            obj_data.put('_image',get_emp_img(r4.codempa));
                            obj_data.put('employa_name',get_temploy_name(r4.codempa,global_v_lang));
                            obj_data.put('flgskip', v_flgskip);

                            obj_row.put(to_char(v_row-1),obj_data);
                        end loop; -- c_ttemprpt2
                    end loop; -- c_twkflowd
                end if; -- v_flgpass
            end if; -- v_routeno is not null
        end loop;

        -- กรณีไม่พบข้อมูลให้ HR2055 ค้นหาข้อมูลที่ต้องการในฐานข้อมูลไม่พบ(TEMPROUTE)
        if obj_row.get_size() = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temproute');
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
        end if;

        json_str_output := obj_row.to_clob;
    end gen_data;

     procedure get_index (json_str_input in clob, json_str_output out clob) as

    begin
        initial_value(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_data(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

  --
  procedure msg_err2(p_error in varchar2) is
    v_numseq    number;
    v_codapp    varchar2(30):= 'MSG';

  begin
    null;
 /*
    begin
      select max(numseq) into v_numseq
        from ttemprpt
       where codapp   = v_codapp
         and codempid = v_codapp;
    end;
    v_numseq  := nvl(v_numseq,0) + 1;
    insert into ttemprpt (codempid,codapp,numseq, item1)
                   values(v_codapp,v_codapp,v_numseq, p_error);
    commit;
    -- */
  end;
  --

end HRCO2NX;

/

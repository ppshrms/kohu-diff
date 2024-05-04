--------------------------------------------------------
--  DDL for Package Body HRBF3ZU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF3ZU" is
-- last update: 07/08/2020 09:40

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    logic			    json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_numisr            := hcm_util.get_string_t(json_obj,'p_numisr');

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtechng           := to_date(hcm_util.get_string_t(json_obj,'p_dtechng'),'ddmmyyyy');

    p_index_rows        := hcm_util.get_json_t(json_obj,'p_index_rows');
    p_selected_rows     := hcm_util.get_json_t(json_obj,'p_selected_rows');

    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'ddmmyyyy');

    p_condition         := hcm_util.get_string_t(json_obj,'p_condition');
    p_stasuccr          := hcm_util.get_string_t(json_obj,'p_stasuccr');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_dteposdue         := to_date(hcm_util.get_string_t(json_obj,'p_dteposdue'),'ddmmyyyy');


    p_codemprq          := hcm_util.get_string_t(json_obj,'p_codemprq');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
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
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_data(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;

    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    v_secur         varchar2(1 char) := 'N';
    v_flgpass     	boolean;

    v_sub_col       varchar2(1) := 'N';
    v_num           number(10) := 0;

    v_cursor        number;
    v_codcomp       varchar2(100);
    v_idx           number := 0;
    v_codcompn      temploy1.codcomp%type;
    v_codposn       temploy1.codpos%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(4000 char);
    v_approvno      number;
    v_check         varchar2(500 char);

    cursor c1 is
        select t2.codcomp, t1.codempid, t1.numisr, t1.dteedit, t1.codedit,
               t1.codisrp, t1.approvno, t2.codpos, nvl(t1.staappr,'P') staappr, t1.dteappr, t1.dtechng
          from tchgins1 t1, temploy1 t2
         where t1.codempid = t2.codempid
           and t2.codcomp like p_codcomp || '%'
           and t1.numisr = nvl(p_numisr,t1.numisr)
           and trunc(t1.dtechng) between p_dtestr and p_dteend
           and nvl(t1.staappr,'P') in ('P','A');
  begin
    --table
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_approvno    := nvl(r1.approvno,0) + 1; --31/08/2021
      v_flgpass     := chk_flowmail.check_approve('HRBF36E', r1.codempid, v_approvno, global_v_codempid, r1.codcomp, r1.codpos, v_check);  
      if (v_flgpass) then
          v_secur       := 'Y';
          obj_data      := json_object_t();
          v_rcnt        := v_rcnt + 1;
          obj_data.put('coderror', '200');
          obj_data.put('image', nvl(get_emp_img(r1.codempid), r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid, global_v_lang));
          obj_data.put('numisr',r1.numisr);
          obj_data.put('codisrp',get_tcodec_name('TCODISRP', r1.codisrp, global_v_lang));
          obj_data.put('dteedit',to_char(r1.dteedit,'dd/mm/yyyy'));
          obj_data.put('codedit',r1.codedit);
        --obj_data.put('desc_codedit',get_temploy_name(get_codempid(r1.codedit), global_v_lang));--<< user25 Date : 30/08/2021 5. BF Module #6785
          obj_data.put('desc_codedit',get_temploy_name(r1.codedit, global_v_lang));--<< user25 Date : 30/08/2021 5. BF Module #6785
          obj_data.put('staappr',get_tlistval_name('STAAPPR', r1.staappr, global_v_lang));
          obj_data.put('last_approvno',nvl(r1.approvno,0));
          obj_data.put('last_dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('dtechng',to_char(r1.dtechng,'dd/mm/yyyy'));
          obj_data.put('approvno',v_approvno);
          obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_flgdata = 'Y' AND v_secur = 'Y' then
      json_str_output := obj_row.to_clob;
    elsif v_flgdata = 'N' then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TCHGINS1');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    elsif v_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3008', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end;

  --
  procedure get_date(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
        select *
          from tchgins1
         where codempid = p_codempid_query
           and numisr = p_numisr
           and trunc(dtechng) = p_dtechng;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    if param_msg_error is null then
        for r1 in c1 loop
            obj_row.put('dtechng',to_char(r1.dtechng,'dd/mm/yyyy'));
            obj_row.put('dteeffec',to_char(r1.dteeffec,'dd/mm/yyyy'));
            obj_row.put('coderror', '200');
        end loop;
        json_str_output := obj_row.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_index is
    v_flgSecur  boolean;
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    cursor c1 is
        select *
          from tcenter
         where codcomp like p_codcomp||'%';--User37 #4147 BF - PeoplePlus 19/02/2021 codcomp = p_codcomp
    cursor c2 is
        select *
          from tpostn
         where codpos = p_codpos;
  begin
  null;
    if  p_codcomp is not null then
        for i in c1 loop
            v_data  := 'Y';
            v_flgSecur := secur_main.secur7(p_codcomp,global_v_coduser);
            if v_flgSecur then
                v_chkSecur  := 'Y';
            end if;
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
            return;
        elsif v_chkSecur = 'N' then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;
    end if;
    v_data  := 'N';
    if p_codpos is not null then
        for i in c2 loop
            v_data  := 'Y';
        end loop;
        if v_data = 'N' then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TPOSTN');
            return;
        end if;
    end if;
  end;

  procedure check_save is
    v_data      varchar2(1) := 'N';
    v_chkSecur  varchar2(1) := 'N';
    v_codempid  temploy1.codempid%type;
    v_flgsecu   boolean;
    v_zupdsal   varchar2(400 char);
    v_staemp    temploy1.staemp%type;
  begin
  null;
    if  p_flg ='add' then
        if p_dtereq < trunc(sysdate) then
            param_msg_error := get_error_msg_php('HR8519',global_v_lang);
            return;
        end if;
    end if;

    if p_codemprq is not null then
        begin
            select codempid
              into v_codempid
              from temploy1
             where codempid = p_codemprq;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
            return;
        end;

        v_flgsecu := secur_main.secur2(p_codemprq,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_flgsecu then
            param_msg_error := get_error_msg_php('HR3007',global_v_lang);
            return;
        end if;

        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codemprq;

        if v_staemp = '9' then
            param_msg_error := get_error_msg_php('HR2101',global_v_lang);
            return;
        elsif v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102',global_v_lang);
            return;
        end if;
    end if;
  end;
  procedure get_index_approve(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index_approve(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure gen_index_approve(json_str_output out clob) is
    obj_data_main   json_object_t;
    obj_row_main    json_object_t;
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_row           json_object_t;

    v_rcnt_main     number := 0;
    v_rcnt          number := 0;
    v_codempid      temploy1.codempid%type;
    v_numisr        tchgins1.numisr%type;
    v_dtechng       tchgins1.dtechng%type;
    v_approvno      number;
    v_flgpass     	boolean;
    v_check         varchar2(500 char);

    cursor c1 is
        select *
          from tapinsrer
         where codempid = v_codempid
           and numisr = v_numisr
           and trunc(dtechng) = v_dtechng
           and approvno < v_approvno
           order by approvno;
  begin

    v_rcnt_main     := 0;
    obj_row_main    := json_object_t();
    for i in 0..p_index_rows.get_size-1 loop
        v_row           := json_object_t();
        v_row           := hcm_util.get_json_t(p_index_rows,to_char(i));
        v_codempid      := hcm_util.get_string_t(v_row,'codempid');
        v_numisr        := hcm_util.get_string_t(v_row,'numisr');
        v_dtechng       := to_date(hcm_util.get_string_t(v_row,'dtechng'),'dd/mm/yyyy');
        v_approvno      := to_number(hcm_util.get_string_t(v_row,'approvno'));

        v_rcnt_main     := v_rcnt_main + 1;
        v_flgpass       := chk_flowmail.check_approve('HRBF36E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
        obj_row         := json_object_t();
        v_rcnt := 0;
        for r1 in c1 loop
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();
            obj_data.put('codempid',v_codempid);
            obj_data.put('dtechng',to_char(v_dtechng,'dd/mm/yyyy'));
            obj_data.put('numisr',v_numisr);
            obj_data.put('numseq',r1.approvno);
            obj_data.put('approvno',r1.approvno);
            obj_data.put('codappr',r1.codappr);
            obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('staappr',r1.staappr);
            obj_data.put('remark',r1.remark);
            obj_data.put('disabled',true);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;

        if v_flgpass then
            v_rcnt          := v_rcnt + 1;
            obj_data        := json_object_t();
            obj_data.put('codempid',v_codempid);
            obj_data.put('dtechng',to_char(v_dtechng,'dd/mm/yyyy'));
            obj_data.put('numisr',v_numisr);
            obj_data.put('numseq',v_approvno);
            obj_data.put('approvno',v_approvno);
            obj_data.put('codappr',global_v_codempid);
            obj_data.put('dteappr',to_char(trunc(sysdate),'dd/mm/yyyy'));
            obj_data.put('staappr','Y');
            obj_data.put('remark','');
            obj_data.put('disabled',false);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;

        obj_data_main   := json_object_t();
        obj_data_main.put('coderror', '200');
        obj_data_main.put('codempid',v_codempid);
        obj_data_main.put('desc_codempid',get_temploy_name(v_codempid, global_v_lang));
        obj_data_main.put('detail',obj_row);
        obj_row_main.put(to_char(v_rcnt_main-1),obj_data_main);
    end loop;

    json_str_output := obj_row_main.to_clob;
  end;
  procedure send_approve(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    v_codempid      tchgins1.codempid%type;
    v_numisr        tchgins1.numisr%type;
    v_dtechng       tchgins1.dtechng%type;
    v_approvno      tchgins1.approvno%type;
    v_codappr       tchgins1.codappr%type;
    v_dteappr       tchgins1.dteappr%type;
    v_remark        tchgins1.remark%type;
    v_staappr       tchgins1.staappr%type;
    v_staappr2      tchgins1.staappr%type;
    v_msg_to        clob;
	v_templete_to   clob;
    v_func_appr     tfwmailh.codappap%type;
    v_rowid         rowid;
    v_error			terrorm.errorno%type;
	v_codform		tfwmailh.codform%type;
    v_flgsecu       boolean;
    v_zupdsal       varchar2(400);

    v_flgpass       boolean;
    v_check         varchar2(500 char);
    v_flgchng       tchgins1.flgchng%type;
    v_amtpmium      number;
    v_unit          varchar2(500);
    v_error_cc      varchar2(4000);

    cursor c1 is
        select *
          from tchgins1
         where codempid=  v_codempid
           and numisr = v_numisr
           and trunc(dtechng) = v_dtechng;

    cursor c2 is
        select *
          from tchgins2
         where codempid=  v_codempid
           and numisr = v_numisr
           and trunc(dtechng) = v_dtechng;

    cursor c3 is
        select *
          from tchgins3
         where codempid=  v_codempid
           and numisr = v_numisr
           and trunc(dtechng) = v_dtechng;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
        begin
            for i in 0..p_selected_rows.get_size-1 loop
                obj_row     := json_object_t();
				obj_row     := hcm_util.get_json_t(p_selected_rows,to_char(i));
                v_codempid  := hcm_util.get_string_t(obj_row,'codempid');
                v_numisr    := hcm_util.get_string_t(obj_row,'numisr');
                v_dtechng   := to_date(hcm_util.get_string_t(obj_row,'dtechng'),'dd/mm/yyyy');
                v_approvno  := hcm_util.get_string_t(obj_row,'approvno');
                v_codappr   := hcm_util.get_string_t(obj_row,'codappr');
                v_dteappr   := to_date(hcm_util.get_string_t(obj_row,'dteappr'),'dd/mm/yyyy');
                v_remark    := hcm_util.get_string_t(obj_row,'remark');
                v_staappr   := hcm_util.get_string_t(obj_row,'staappr');

                insert into tapinsrer (numisr,codempid,dtechng,approvno,codappr,dteappr,
                                       staappr,remark,dtecreate,codcreate,dteupd,coduser)
                values (v_numisr,v_codempid,v_dtechng,v_approvno,v_codappr,v_dteappr,
                                       v_staappr,v_remark,sysdate,global_v_coduser,sysdate,global_v_coduser);

                if v_staappr = 'N' then
                    update tchgins1
                       set staappr = v_staappr,
                           approvno = v_approvno,
                           codappr = v_codappr,
                           dteappr = v_dteappr,
                           remarkap = v_remark
                     where codempid = v_codempid
                       and numisr = v_numisr
                       and trunc(dtechng) = v_dtechng;
                else
                    v_flgpass := chk_flowmail.check_approve('HRBF36E', v_codempid, v_approvno, global_v_codempid, null, null, v_check);
                    if v_check = 'Y' then
                        v_staappr2 := 'Y';
                    else
                        v_staappr2 := 'A';
                    end if;
                    update tchgins1
                       set staappr = v_staappr2,
                           approvno = v_approvno,
                           codappr = v_codappr,
                           dteappr = v_dteappr,
                           remarkap = v_remark
                     where codempid = v_codempid
                       and numisr = v_numisr
                       and trunc(dtechng) = v_dtechng;
                    if v_check = 'N' then
                        select rowid
                          into v_rowid
                          from tchgins1
                         where codempid = v_codempid
                           and numisr = v_numisr
                           and trunc(dtechng) = v_dtechng;
                        begin
                            v_error := chk_flowmail.send_mail_for_approve('HRBF36E', v_codempid, global_v_codempid, global_v_coduser, null, 'HRBF3ZU1', 230, 'U', v_staappr, v_approvno + 1, null, null,'TCHGINS1',v_rowid, '1', null);
                        EXCEPTION WHEN OTHERS THEN
                            v_error := '2403';
                        END;

                        IF v_error in ('2046','2402') THEN
                            param_msg_error := get_error_msg_php('HR2402', global_v_lang);
                        ELSE
                            param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
                        END IF;
                    else
                        begin
                            select flgchng
                              into v_flgchng
                              from tchgins1
                             where codempid = v_codempid
                               and numisr = v_numisr
                               and trunc(dtechng) = v_dtechng;
                        exception when others then
                            v_flgchng := '';
                        end;

                        if v_flgchng = '2' then
                            begin
                                update tinsrer
                                   set flgemp = 2
                                 where codempid = v_codempid
                                   and numisr = v_numisr;

                                delete tinsrdp
                                 where codempid = v_codempid
                                   and numisr = v_numisr;

                                delete tbficinf
                                 where codempid = v_codempid
                                   and numisr = v_numisr;
                            exception when others then
                                null;
                            end;
                        elsif v_flgchng = '3' then
                            for r1 in c1 loop
                                update tinsrer
                                   set codisrp = r1.codisrp,
                                       flgisr = r1.flgisr,
                                       dtehlpst = r1.dtehlpst,
                                       dtehlpen = r1.dtehlpen,
                                       amtisrp = r1.amtisrp,
                                       codecov = r1.codecov,
                                       codfcov = r1.codfcov,
                                       amtpmiumme = r1.amtpmiumme,
                                       amtpmiumye = r1.amtpmiumye,
                                       amtpmiummc = r1.amtpmiummc,
                                       amtpmiumyc = r1.amtpmiumyc
                                 where codempid = v_codempid
                                   and numisr = v_numisr;
                            end loop;

                            for r2 in c2 loop
                                if r2.flgchng = '1' then
                                    insert into tinsrdp (codempid,numisr,numseq,nameinsr,typrelate,
                                                         dteempdb,codsex,dtecreate,codcreate,dteupd,coduser)
                                    values (r2.codempid,r2.numisr,r2.numseq,r2.nameinsr,r2.typrelate,
                                            r2.dteempdb,r2.codsex,r2.dtecreate,r2.codcreate,r2.dteupd,r2.coduser);
                                elsif r2.flgchng = '2' then
                                    delete tinsrdp
                                     where codempid = r2.codempid
                                       and numisr = r2.numisr
                                       and numseq = r2.numseq;
                                end if;
                            end loop;

                            for r3 in c3 loop
                                if r3.flgchng = '1' then
                                    insert into tbficinf (codempid,numisr,numseq,nambfisr,typrelate,
                                                          ratebf,dtecreate,codcreate,dteupd,coduser)
                                    values (r3.codempid,r3.numisr,r3.numseq,r3.nambfisr,r3.typrelate,
                                            r3.ratebf,r3.dtecreate,r3.codcreate,r3.dteupd,r3.coduser);
                                elsif r3.flgchng = '2' then
                                    delete tbficinf
                                     where codempid = r3.codempid
                                       and numisr = r3.numisr
                                       and numseq = r3.numseq;
                                end if;
                            end loop;
                        end if;
                    end if;
                end if;

                select rowid
                  into v_rowid
                  from tchgins1
                 where codempid = v_codempid
                   and numisr = v_numisr
                   and trunc(dtechng) = v_dtechng;

                begin
                    v_error_cc := chk_flowmail.send_mail_reply('HRBF3ZU', v_codempid, null , global_v_codempid, global_v_coduser, null, 'HRBF3ZU1', 240, 'U', v_staappr, v_approvno, null, null, 'TCHGINS1', v_rowid, '1', null);
                EXCEPTION WHEN OTHERS THEN
                    v_error_cc := '2403';
                END;

                IF v_error in ('2046','2402') THEN
                    param_msg_error := get_error_msg_php('HR2402', global_v_lang);
                ELSE
                    param_msg_error_mail := get_error_msg_php('HR2403', global_v_lang);
                END IF;

            end loop;
            commit;
        exception when others then
            rollback;
            param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end;
        if param_msg_error_mail is not null then
            json_str_output := get_response_message(200,param_msg_error_mail,global_v_lang);
        else
            json_str_output := get_response_message(200,param_msg_error,global_v_lang);
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_change_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_change_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_change_detail(json_str_output out clob) is
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_qtyf          number;
    v_qtyfo         number;
    cursor c1 is
        select *
          from tchgins1
         where codempid = p_codempid_query
           and numisr = p_numisr
           and trunc(dtechng) = p_dtechng;
  begin
    v_rcnt          := 0;
    obj_data        := json_object_t();

    for r1 in c1 loop
      obj_data.put('coderror', '200');
      obj_data.put('codisrpo', r1.codisrpo);
      obj_data.put('desc_codisrpo', get_tcodec_name('TCODISRP', r1.codisrpo, global_v_lang));
      obj_data.put('codisrp', r1.codisrp);
      obj_data.put('desc_codisrp', get_tcodec_name('TCODISRP', r1.codisrp, global_v_lang));
      obj_data.put('dtehlpst', to_char(r1.dtehlpst,'dd/mm/yyyy'));
      obj_data.put('dtehlpsto', to_char(r1.dtehlpsto,'dd/mm/yyyy'));
      obj_data.put('dtehlpen', to_char(r1.dtehlpen,'dd/mm/yyyy'));
      obj_data.put('dtehlpeno', to_char(r1.dtehlpeno,'dd/mm/yyyy'));
      obj_data.put('amtisrp', to_char(nvl(r1.amtisrp,0),'fm999,999,999,990.00'));
      obj_data.put('amtisrpo', to_char(nvl(r1.amtisrpo,0),'fm999,999,999,990.00'));

      --<< user25 Date : 31/08/2021 #6786
--      if r1.codecovo = 'Y' and r1.codfcovo = 'Y' then
--        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,170));
--      elsif r1.codecovo = 'Y' then
--        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,160));
--      else
--        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,270));
--      end if;
--      
--      if r1.codecov = 'Y' and r1.codfcov = 'Y' then
--        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,170));
--      elsif r1.codecov = 'Y' then
--        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,160));
--      else
--        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,270));
--      end if;

      if r1.codecovo = 'Y' and r1.codfcovo = 'N' then
        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,160));
      elsif r1.codecovo = 'N' and r1.codfcovo = 'Y' then
        obj_data.put('desc_codcovo', get_label_name('HRBF3ZU2',global_v_lang,170));
      else
        obj_data.put('desc_codcovo', '');
      end if;

      if r1.codecov = 'Y' and r1.codfcov = 'N' then
        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,160));
      elsif r1.codecov = 'N' and r1.codfcov = 'Y' then
        obj_data.put('desc_codcov', get_label_name('HRBF3ZU2',global_v_lang,170));
      else
        obj_data.put('desc_codcov', '');
      end if;
       -->> user25 Date : 31/08/2021 #6786    

      if nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiummc,0) > 0 then
        obj_data.put('flgmonth',true);
      else
        obj_data.put('flgmonth',false);
      end if;
      obj_data.put('amtpmiumm', to_char(nvl(r1.amtpmiumme,0) + nvl(r1.amtpmiummc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummo', to_char(nvl(r1.amtpmiummeo,0) + nvl(r1.amtpmiummco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumy', to_char(nvl(r1.amtpmiumye,0) + nvl(r1.amtpmiumyc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyo', to_char(nvl(r1.amtpmiumyeo,0) + nvl(r1.amtpmiumyco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumme', to_char(nvl(r1.amtpmiumme,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummeo', to_char(nvl(r1.amtpmiummeo,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumye', to_char(nvl(r1.amtpmiumye,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyeo', to_char(nvl(r1.amtpmiumyeo,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummc', to_char(nvl(r1.amtpmiummc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiummco', to_char(nvl(r1.amtpmiummco,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyc', to_char(nvl(r1.amtpmiumyc,0),'fm999,999,999,990.00'));
      obj_data.put('amtpmiumyco', to_char(nvl(r1.amtpmiumyco,0),'fm999,999,999,990.00'));
      obj_data.put('remark',r1.remark);
      obj_data.put('dteupdate',to_char(r1.dteupd,'dd/mm/yyyy'));
      obj_data.put('updateby',get_codempid(r1.coduser) || ' - ' || get_temploy_name(get_codempid(r1.coduser),global_v_lang));

      begin
          select count(numseq)
            into v_qtyfo
            from tinsrdp
           where codempid = p_codempid_query
             and numisr = p_numisr;
      exception when others then
        v_qtyfo := 0;
      end;

      begin
          select count(numseq)
            into v_qtyf
            from tchgins2
           where codempid = p_codempid_query
             and numisr = p_numisr
             and trunc(dtechng) = p_dtechng;
      exception when others then
        v_qtyf := 0;
      end;

      obj_data.put('qtyf',v_qtyf);
      obj_data.put('qtyfo',v_qtyfo);

    end loop;
    json_str_output := obj_data.to_clob;
  end;


  procedure get_list_insured(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_list_insured(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_list_insured(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
        select *
          from tchgins2
         where codempid = p_codempid_query
           and numisr = p_numisr
           and trunc(dtechng) = p_dtechng
      order by numseq;

    cursor c2 is
        select *
          from tinsrdp
         where codempid = p_codempid_query
           and numisr = p_numisr
      order by numseq;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('numisr', r1.numisr);
      obj_data.put('dtechng', to_char(r1.dtechng,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('nameinsr', r1.nameinsr);
      obj_data.put('typrelate', r1.typrelate);
      obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r1.typrelate,global_v_lang));
      obj_data.put('dteempdb', to_char(r1.dteempdb,'dd/mm/yyyy'));
      obj_data.put('flgchng', get_tlistval_name('FLGCHNG',r1.flgchng,global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'N' then
        for r2 in c2 loop
          v_rcnt        := v_rcnt+1;
          obj_data      := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codempid', r2.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
          obj_data.put('numisr', r2.numisr);
          obj_data.put('dtechng', '');
          obj_data.put('numseq', r2.numseq);
          obj_data.put('nameinsr', r2.nameinsr);
          obj_data.put('typrelate', r2.typrelate);
          obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r2.typrelate,global_v_lang));
          obj_data.put('dteempdb', to_char(r2.dteempdb,'dd/mm/yyyy'));
          obj_data.put('flgchng', '');
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;

  procedure get_beneficiary(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_beneficiary(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_beneficiary(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    v_flgdata       varchar2(1 char) := 'N';
    cursor c1 is
        select *
          from tchgins3
         where codempid = p_codempid_query
           and numisr = p_numisr
           and trunc(dtechng) = p_dtechng
      order by numseq;

    cursor c2 is
        select *
          from tbficinf
         where codempid = p_codempid_query
           and numisr = p_numisr
      order by numseq;
  begin
    v_rcnt  := 0;
    obj_row := json_object_t();

    for r1 in c1 loop
      v_flgdata     := 'Y';
      v_rcnt        := v_rcnt+1;
      obj_data      := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', r1.codempid);
      obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
      obj_data.put('numisr', r1.numisr);
      obj_data.put('dtechng', to_char(r1.dtechng,'dd/mm/yyyy'));
      obj_data.put('numseq', r1.numseq);
      obj_data.put('nambfisr', r1.nambfisr);
      obj_data.put('typrelate', r1.typrelate);
      obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r1.typrelate,global_v_lang));
      obj_data.put('ratebf', to_char(nvl(r1.ratebf,0),'fm9,999,999.00'));
      obj_data.put('flgchng', get_tlistval_name('FLGCHNG',r1.flgchng,global_v_lang));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if v_flgdata = 'N' then
        for r2 in c2 loop
          v_rcnt        := v_rcnt+1;
          obj_data      := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codempid', r2.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r2.codempid,global_v_lang));
          obj_data.put('numisr', r2.numisr);
          obj_data.put('dtechng', '');
          obj_data.put('numseq', r2.numseq);
          obj_data.put('nambfisr', r2.nambfisr);
          obj_data.put('typrelate', r2.typrelate);
          obj_data.put('desc_typrelate', get_tlistval_name('TYPRELATE',r2.typrelate,global_v_lang));
          obj_data.put('ratebf', to_char(nvl(r2.ratebf,0),'fm9,999,999.00'));
          obj_data.put('flgchng', '');
          obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end if;

    json_str_output := obj_row.to_clob;
  end;
end;

/

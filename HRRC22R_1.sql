--------------------------------------------------------
--  DDL for Package Body HRRC22R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC22R" as

    procedure initial_current_user_value(json_str_input in clob) as
        json_obj        json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');
    end initial_current_user_value;

    procedure initial_params(json_str_input in clob) as
        json_obj        json_object_t;
    begin
        json_obj        := json_object_t(json_str_input);
        p_numapplst     := upper(hcm_util.get_string_t(json_obj,'p_numapplst'));
        p_numapplen     := upper(hcm_util.get_string_t(json_obj,'p_numapplen'));
    end initial_params;

    procedure check_index as
        v_temp      varchar2(1 char);
    begin
        begin
            select 'X' into v_temp
              from tapplinf
             where numappl = p_numapplst;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TAPPLINF');
            return;
        end;

        begin
            select 'X' into v_temp
              from tapplinf
             where numappl = p_numapplen;
        exception when no_data_found then
            param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TAPPLINF');
            return;
        end;

        if p_numapplst > p_numapplen then
            param_msg_error := get_error_msg_php('HR2022',global_v_lang);
            return;
        end if;

    end check_index;

    procedure gen_index(json_str_output out clob) as
        v_numseq    number := 0;
        v_numappl   tapplinf.numappl%type;
        v_label     varchar2(400 char);
        cursor c1 is
            select a.namimage,a.codtitle,decode(global_v_lang,'101',a.namfirste,'102',a.namfirstt,'103',a.namfirst3,'104',a.namfirst4,'105',a.namfirst5) namfirst
                    ,decode(global_v_lang,'101',a.namlaste,'102',a.namlastt,'103',a.namlast3,'104',a.namlast4,'105',a.namlast5) namlast
                    ,a.nickname,a.dteappl,a.codpos1,a.codpos2,a.codbrlc1,a.codbrlc2,a.codbrlc3,a.amtincfm,a.amtincto,a.codcurr
                    ,a.codmedia,a.flgcar,a.carlicid,a.flgwork,a.dteempdb,a.coddomcl,a.codsex,a.numoffid,a.adrissue,a.dteoffid
                    ,a.codprov,a.stamarry,a.stamilit,a.numtaxid,a.numsaid,a.codblood,a.weight,a.height,a.codrelgn,a.codorgin
                    ,a.codnatnl,a.numlicid,a.dtelicid,a.numpasid,a.dtepasid,a.numprmid,a.dteprmst,a.dteprmen
                    ,decode(global_v_lang,'101',a.adrrege,'102',a.adrregt,'103',a.adrreg3,'104',a.adrreg4,'105',a.adrreg5) adrreg,a.codprovr
                    ,a.coddistr,a.codsubdistr,a.codcntyi,a.codposte,a.numtelemr,a.numtelehr
                    ,decode(global_v_lang,'101',a.adrconte,'102',a.adrcontt,'103',a.adrcont3,'104',a.adrcont4,'105',a.adrcont5) adrcont
                    ,a.codprovc,a.coddistc,a.codsubdistc,a.codcntyc,a.codpostc,a.numtelem,a.numteleh,a.email,a.stadisb,a.numdisab
                    ,a.typdisp,a.dtedisb,a.dtedisen,a.desdisp,b.codtitlc,b.namfstc,b.namlstc,b.desrelat,b.adrcont1,b.codpost
                    ,b.numtele,b.numfax,b.email as email_b,c.reason,c.flgstrwk,c.jobdesc,c.codlocat,c.flgprov,c.flgoversea
                    ,b.codempidsp,b.namimgsp,b.codtitle as codtitle_b,b.namfirst as namfirst_b,b.namlast as namlast_b
                    ,b.numoffid as numoffid_b,b.stalife,b.codspocc,b.desnoffi,a.actstudy,a.specabi,a.compabi,a.addinfo,a.typthai,a.typeng,c.flgcivil
                    ,c.lastpost,c.departmn,c.flgmilit,c.desexcem,c.flgordan,c.flgcase,c.desdisea,c.dessymp,c.flgill,c.desill
                    ,c.flgarres,c.desarres,c.flgknow,c.name,c.flgappl,c.lastpos2,trunc(c.qtydayst/365) years
                    ,trunc(mod(c.qtydayst,365)/12) month,c.hobby,a.numappl
              from tapplinf a,tapplfm b,tapploth c
             where a.numappl between p_numapplst and p_numapplen
                and a.numappl = b.numappl (+)
                and a.numappl = c.numappl (+)
                --and a.numappl = b.numappl
                --and a.numappl = c.numappl
             order by a.numappl;

        cursor c2 is
            select typdoc,namdoc,filedoc,flgresume,rownum
              from tappldoc
             where numappl = v_numappl
          order by numseq;

        cursor c3 is
            select codedlv,coddglv,codmajsb,codinst,codcount,rownum
              from teducatn
             where numappl = v_numappl
          order by numseq;

        cursor c4 is
            select desnoffi,desoffi1,deslstpos,dtestart,dteend,rownum
              from tapplwex
             where numappl = v_numappl
          order by numseq;

        cursor c5 is
            select destrain,dtetrain,dtetren,desplace,desinstu,rownum
              from ttrainbf
             where numappl = v_numappl
          order by numseq;

        cursor c6 is
            select namrel
              from tapplrel
             where numappl = v_numappl
          order by numseq;

        cursor c7 is
            select decode(global_v_lang,'101',namrefe,'102',namreft,'103',namref3,'104',namref4,'105',namref5) namref
                ,flgref,despos,desnoffi
              from tapplref
              where numappl = v_numappl
           order by numseq;

        cursor c8 is
            select codtency,get_tcodec_name('TCODSKIL',codtency,global_v_lang) descskil,get_tlistval_name('GRADSKIL',grade,global_v_lang) desgrade
              from TCMPTNCY
             where numappl = v_numappl
            union
            select '' codtency,descskil,get_tlistval_name('GRADSKIL',grade,global_v_lang) desgrade
              from TCMPTNCY2
             where numappl = v_numappl
          order by codtency,descskil;

        cursor c9 is
            select codlang,flglist,flgspeak,flgread,flgwrite
              from tlangabi
             where numappl = v_numappl;
    begin
        delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRC22R';
        for i in c1 loop
            v_numseq := v_numseq+1;
            insert into ttemprpt(codempid,codapp,numseq,item1,item2
                -- general
                ,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18,item19
                -- personal
                ,item20,item21,item22,item23,item24,item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35
                ,item36,item37,item38,item39,item40,item41,item42,item43
                -- address
                ,item44,item45,item46,item47,item48,item49,item50,item51,item52,item53,item54,item55,item56,item57,item58,item59
                ,item60
                -- disabled
                ,item61,item62,item63,item64,item65,item66
                -- contact emergency
                ,item67,item68,item69,item70,item71,item72,item73,item74,item75
                -- preference
                ,item76,item77,item78,item79,item80,item81
                -- spouse
                ,item82,item83,item84,item85,item86,item87,item88,item89,item90
                -- skill other
                ,item91,item92,item93,item94,item95,item96
                -- other
                ,item97,item98,item99,item100,item101,item102,item103,item104,item105,item106,item107,item108,item109,item110
                ,item111,item112,item113,item114,item115
                )
            values(global_v_codempid,'HRRC22R',v_numseq,'MAIN',i.numappl
                -- general
                ,get_tlistval_name('CODTITLE',i.codtitle,global_v_lang)
                ,i.namfirst,i.namlast,i.nickname,get_tfolderd('HRRC21E1')||'/'||i.namimage,to_char(i.dteappl,'dd/mm/yyyy'),get_tpostn_name(i.codpos1,global_v_lang) -- softberry || 13/02/2023 || #9091 || ,i.namfirst,i.namlast,i.nickname,i.namimage,to_char(i.dteappl,'dd/mm/yyyy'),get_tpostn_name(i.codpos1,global_v_lang) 
                ,get_tpostn_name(i.codpos2,global_v_lang),get_tcodec_name('TCODLOCA',i.codbrlc1,global_v_lang)
                ,get_tcodec_name('TCODLOCA',i.codbrlc2,global_v_lang),get_tcodec_name('TCODLOCA',i.codbrlc3,global_v_lang)
                ,ltrim(to_char(i.amtincfm,'999,999,999,999.99'))||' - '||ltrim(to_char(i.amtincto,'999,999,999,999.99'))
                ,get_tcodec_name('TCODCURR',i.codcurr,global_v_lang),get_tcodec_name('TCODMEDI',i.codmedia,global_v_lang),i.flgcar
                ,i.carlicid,i.flgwork
                -- personal
                ,i.numoffid,to_char(i.dteoffid,'dd/mm/yyyy'),i.adrissue,get_tcodec_name('TCODPROV',i.codprov,global_v_lang)
                ,i.numtaxid,i.numsaid,i.numpasid,to_char(i.dtepasid,'dd/mm/yyyy'),i.numlicid,to_char(i.dtelicid,'dd/mm/yyyy')
                ,to_char(i.dteempdb,'dd/mm/yyyy'),get_tcodec_name('TCODPROV',i.coddomcl,global_v_lang)
                ,get_tlistval_name('NAMSEX',i.codsex,global_v_lang),i.weight,i.height,i.codblood,get_tcodec_name('TCODREGN',i.codorgin,global_v_lang)
                ,get_tcodec_name('TCODNATN',i.codnatnl,global_v_lang),get_tcodec_name('TCODRELI',i.codrelgn,global_v_lang)
                ,get_tlistval_name('NAMMARRY',i.stamarry,global_v_lang),get_tlistval_name('NAMMILIT',i.stamilit,global_v_lang)
                ,i.numprmid,to_char(i.dteprmst,'dd/mm/yyyy'),to_char(i.dteprmen,'dd/mm/yyyy')
                -- address
                ,i.adrreg,get_tcoddist_name(i.coddistr,global_v_lang),get_tsubdist_name(i.codsubdistr,global_v_lang)
                ,get_tcodec_name('TCODPROV',i.codprovr,global_v_lang),get_tcodec_name('TCODCNTY',i.codcntyi,global_v_lang)
                ,i.codposte,i.numtelemr,i.numtelehr,i.adrcont,get_tcoddist_name(i.coddistc,global_v_lang)
                ,get_tsubdist_name(i.codsubdistc,global_v_lang),get_tcodec_name('TCODPROV',i.codprovc,global_v_lang)
                ,get_tcodec_name('TCODCNTY',i.codcntyc,global_v_lang),i.codpostc,i.numtelem,i.numteleh,i.email
                -- disabled
                ,get_tlistval_name('STADISB',i.stadisb,global_v_lang),i.numdisab,get_tcodec_name('TCODDISP',i.typdisp,global_v_lang),to_char(i.dtedisb,'dd/mm/yyyy')
                ,to_char(i.dtedisen,'dd/mm/yyyy'),i.desdisp
                -- contact emergency
                ,get_tlistval_name('CODTITLE',i.codtitlc,global_v_lang),i.namfstc,i.namlstc,i.adrcont1,i.codpost,i.numtele
                ,i.numfax,i.email_b,i.desrelat
                -- preference
                ,i.reason,i.flgstrwk,i.jobdesc,get_tcodec_name('TCODPROV',i.codlocat,global_v_lang),i.flgprov,i.flgoversea
                -- spouse
                ,i.codempidsp,get_tlistval_name('CODTITLE',i.codtitle_b,global_v_lang),i.namfirst_b,i.namlast_b,i.numoffid_b,i.stalife,'วันที่เสียชีวิต'
                ,get_tcodec_name('TCODOCCU',i.codspocc,global_v_lang),i.desnoffi
                -- skill other
                ,i.actstudy,i.specabi,i.typthai,i.typeng,i.compabi,i.addinfo
                -- other
                ,i.flgcivil,i.lastpost,i.departmn,i.flgmilit,i.desexcem,i.flgordan,i.flgcase,i.desdisea,i.dessymp,i.flgill
                ,i.desill,i.flgarres,i.desarres,i.flgknow,i.name,i.flgappl,i.lastpos2,i.years,i.hobby
                );
                -- document
                v_numappl := i.numappl;
                for i2 in c2 loop
                    v_numseq := v_numseq+1;
                    if i2.flgresume = 'Y' then
                        v_label := get_label_name('HRRC22R',global_v_lang,80);
                    else
                        v_label := get_label_name('HRRC22R',global_v_lang,90);
                    end if;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
                    values(global_v_codempid,'HRRC22R',v_numseq,'DOC',i.numappl,i2.rownum,get_tcodec_name('TCODTYDOC',i2.typdoc,global_v_lang)
                        ,i2.namdoc,i2.filedoc,v_label);
                end loop;
                -- education
                for i3 in c3 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
                    values(global_v_codempid,'HRRC22R',v_numseq,'EDU',i.numappl,get_tcodec_name('TCODEDUC',i3.codedlv,global_v_lang)
                        ,get_tcodec_name('TCODDGEE',i3.coddglv,global_v_lang),get_tcodec_name('TCODMAJR',i3.codmajsb,global_v_lang)
                        ,get_tcodec_name('TCODINST',i3.codinst,global_v_lang),get_tcodec_name('TCODCNTY',i3.codcount,global_v_lang));
                end loop;
                -- work experience
                for i4 in c4 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
                    values(global_v_codempid,'HRRC22R',v_numseq,'WRK',i.numappl,i4.desnoffi,i4.desoffi1,i4.deslstpos
                        ,to_char(i4.dtestart,'dd/mm/yyyy'),to_char(i4.dteend,'dd/mm/yyyy'));
                end loop;
                -- training
                for i5 in c5 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
                    values(global_v_codempid,'HRRC22R',v_numseq,'TRN',i.numappl,i5.destrain,to_char(i5.dtetrain,'dd/mm/yyyy')
                        ,to_char(i5.dtetren,'dd/mm/yyyy'),i5.desplace,i5.desinstu);
                end loop;
                -- relative
                for i6 in c6 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3)
                    values(global_v_codempid,'HRRC22R',v_numseq,'REL',i.numappl,i6.namrel);
                end loop;
                -- reference person
                for i7 in c7 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6)
                    values(global_v_codempid,'HRRC22R',v_numseq,'REF',i.numappl,i7.namref,get_tlistval_name('FLGREF',i7.flgref,global_v_lang)
                        ,i7.despos,i7.desnoffi);
                end loop;
                -- competency
                for i8 in c8 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5)
                    values(global_v_codempid,'HRRC22R',v_numseq,'CPT',i.numappl,i8.codtency,i8.descskil,i8.desgrade);
                end loop;
                -- lang ability
                for i9 in c9 loop
                    v_numseq := v_numseq+1;
                    insert into ttemprpt(codempid,codapp,numseq,item1,item2,item3,item4,item5,item6,item7)
                    values(global_v_codempid,'HRRC22R',v_numseq,'LAB',i.numappl,get_tcodec_name('TCODLANG',i9.codlang,global_v_lang)
                        ,get_tlistval_name('FLGLANG',i9.flglist,global_v_lang),get_tlistval_name('FLGLANG',i9.flgspeak,global_v_lang)
                        ,get_tlistval_name('FLGLANG',i9.flgread,global_v_lang),get_tlistval_name('FLGLANG',i9.flgwrite,global_v_lang));
                end loop;
        end loop;
        if v_numseq = 0 then
            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TAPPLINF');
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
        return;
    end gen_index;

    procedure get_index(json_str_input in clob,json_str_output out clob) as
    begin
        initial_current_user_value(json_str_input);
        initial_params(json_str_input);
        check_index;
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end get_index;

end HRRC22R;

/

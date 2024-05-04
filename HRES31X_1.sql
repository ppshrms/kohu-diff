--------------------------------------------------------
--  DDL for Package Body HRES31X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES31X" is
-- last update: 01/12/2017 10:29

  procedure saveimagesprofile(p_file_name in varchar2,p_file_data in blob,p_codempid in varchar2,p_coduser in varchar2,r_message out varchar2,r_file_data out blob) is
    p_data      blob;
    p_message   varchar2(4000 char);
  begin
      begin
        -- Insert Table
          INSERT INTO TEMPIMGE(CODEMPID,CODIMAGE,NAMIMAGE,DTEUPD,CODUSER)
          VALUES(p_codempid,p_file_data,p_file_name,sysdate,p_coduser);

        --write to file
        --ExportBlob(ORA_DIR ||  p_file_name,p_file_data);
      EXCEPTION when DUP_VAL_ON_INDEX then

          begin
            update  TEMPIMGE set
            codimage   = p_file_data,
            namimage   = p_file_name,
            dteupd     = sysdate,
            coduser    = p_coduser
            where codempid = p_codempid;

            --write to file
            --ExportBlob(ORA_DIR ||  p_file_name,p_file_data);
          EXCEPTION when DUP_VAL_ON_INDEX then
            r_message     := '{"status": "error", "message": "'|| sqlerrm||'"}';
          end;

      end;

      commit;
      r_file_data   := p_file_data;
      r_message     := '{"status": "success", "message": "Save Prpfile Success"}';

  exception when others then
    r_message     := '{"status": "error", "message": "'|| sqlerrm||'"}';
  end saveimagesprofile;

  procedure getimagesprofile(p_codempid in varchar2, r_file_name out varchar2,r_codempid out varchar2,r_file_data out blob) is
    p_file_data blob;
    p_file_name varchar2(4000 char);
  begin
    begin
      select  codimage,namimage
      into p_file_data,p_file_name
      from tempimge where codempid=p_codempid;
    exception when no_data_found then
      p_file_data := null;
      p_file_name := null;
      r_codempid := null;
    end;
      -- Return Data
      r_file_data := p_file_data;
      r_file_name := p_file_name;
      r_codempid  := p_codempid;

  end;
  --
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    p_start             := to_number(hcm_util.get_string_t(json_obj,'p_start'));
    p_end               := to_number(hcm_util.get_string_t(json_obj,'p_end'));
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid');

    --tab13_popup
    v_codtency    := hcm_util.get_string_t(json_obj,'p_codtency');

  end initial_value;
  --
  function set_data(p_data varchar2) return varchar2 is
  begin
    return nvl(trim(p_data),'-');
  end;
  --
  function get_amt_incom (p_codempid in varchar2) return number is
    v_codcomp  tcenter.codcomp%type ;
    v_codempmt temploy1.codempid%type ;
    v_netamt1  varchar2(20 char) ;
    v_netamt2  varchar2(20 char) ;
    v_netamt3  varchar2(20 char) ;
    v_netamt4  varchar2(20 char) ;
    v_netamt5  varchar2(20 char) ;
    v_netamt6  varchar2(20 char) ;
    v_netamt7  varchar2(20 char) ;
    v_netamt8  varchar2(20 char) ;
    v_netamt9  varchar2(20 char) ;
    v_netamt10 varchar2(20 char) ;
    v_total    number ;
    v_sumday   number ;
  begin
     begin
        select  codcomp,codempmt
        into    v_codcomp,v_codempmt
        from    temploy1
        where   codempid = p_codempid ;
     exception when others then
       return 0 ;
     end;
     --
     begin
        select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
               amtincom6,amtincom7,amtincom8,amtincom9,amtincom10
        into   v_netamt1,v_netamt2,v_netamt3,v_netamt4,v_netamt5,
               v_netamt6,v_netamt7,v_netamt8,v_netamt9,v_netamt10
        from   temploy3
        where   codempid = p_codempid ;
     exception when others then
        return 0 ;
     end ;
     --
     v_netamt1	:= null;
     v_netamt2	:= null;
     v_netamt3	:= null;
     v_netamt4	:= null;
     v_netamt5	:= null;
     v_netamt6	:= null;
     v_netamt7	:= null;
     v_netamt8	:= null;
     v_netamt9	:= null;
     v_netamt10	:= null;
     get_wage_income (hcm_util.get_codcomp_level(v_codcomp,'1') , v_codempmt,
                      nvl(v_netamt1,0), nvl(v_netamt2,0), nvl(v_netamt3,0), nvl(v_netamt4,0), nvl(v_netamt5,0),
                      nvl(v_netamt6,0), nvl(v_netamt7,0), nvl(v_netamt8,0), nvl(v_netamt9,0), nvl(v_netamt10,0),
                      v_sumday ,v_sumday,v_total);
/*                      
     v_netamt1	:= stddec(v_netamt1,p_codempid,v_chken);
     v_netamt2	:= stddec(v_netamt2,p_codempid,v_chken);
     v_netamt3	:= stddec(v_netamt3,p_codempid,v_chken);
     v_netamt4	:= stddec(v_netamt4,p_codempid,v_chken);
     v_netamt5	:= stddec(v_netamt5,p_codempid,v_chken);
     v_netamt6	:= stddec(v_netamt6,p_codempid,v_chken);
     v_netamt7	:= stddec(v_netamt7,p_codempid,v_chken);
     v_netamt8	:= stddec(v_netamt8,p_codempid,v_chken);
     v_netamt9	:= stddec(v_netamt9,p_codempid,v_chken);
     v_netamt10	:= stddec(v_netamt10,p_codempid,v_chken);
     get_wage_income (hcm_util.get_codcomp_level(v_codcomp,'1') , v_codempmt,
                      nvl(v_netamt1,0), nvl(v_netamt2,0), nvl(v_netamt3,0), nvl(v_netamt4,0), nvl(v_netamt5,0),
                      nvl(v_netamt6,0), nvl(v_netamt7,0), nvl(v_netamt8,0), nvl(v_netamt9,0), nvl(v_netamt10,0),
                      v_sumday ,v_sumday,v_total);
 */                     

     return   v_total;
  end;
  --
  --get_personal_data
  procedure hres31x_tab1(json_str_input in clob, json_str_output out clob) as
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_dteempdb          date;
    dteempdb_y			number := 0;
    dteempdb_m			number := 0;
    v_tchildrn			number := 0;
    v_stamarry 			varchar2(20 char);
    v_codsex		    varchar2(20 char);
    v_codedlv		    varchar2(4 char);
    v_codinst		    varchar2(100 char);
    v_desnoffi			varchar2(100 char);
    v_numappl		    varchar2(100 char);
    v_numtelof	   	    varchar2(25 char);
    v_dteempmt          date;
    dteempmt_y			number := 0;
    dteempmt_m			number := 0;
    v_codcomp		   	tcenter.codcomp%type;
    v_codcomp2	   	    varchar2(100 char);
    v_codpos		   	varchar2(4 char);
    v_staemp		    varchar2(5 char);
    v_dteoccup			date;
    v_typpayroll		varchar2(5 char);
    v_dteefpos			date;
    v_codempmt			varchar2(5 char);
    v_qtywkday			number := 0;
    v_day				number := 0;
    v_namimage          varchar2(500 char);

  begin
    initial_value(json_str_input);
    obj_data := json_object_t();
    begin
      select get_tlistval_name('CODTITLE',codtitle,global_v_lang),
             decode(global_v_lang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirste) namfirste,
             decode(global_v_lang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namlast4,'105',namlast5,namlaste) namlaste,
             dteempdb,stamarry,codsex,codedlv,numappl,numtelof,dteempmt,codcomp,codpos,dteempmt,staemp,dteoccup,typpayroll,dteefpos,codempmt,qtywkday
      into   detail_namtitlt,detail_namfirstt,detail_namlastt,
             v_dteempdb,v_stamarry ,v_codsex,v_codedlv,v_numappl,v_numtelof,v_dteempmt,v_codcomp,v_codpos,v_dteempmt,v_staemp,v_dteoccup,v_typpayroll,v_dteefpos,v_codempmt,v_qtywkday
      from   temploy1
      where  codempid = b_index_codempid;
    exception when no_data_found then
        null;
    end;
    --
    begin
      select count(codempid) into v_tchildrn
      from tchildrn
      where codempid    = b_index_codempid;
      detail_tchildrn	:= v_tchildrn;
    exception when no_data_found then
      detail_tchildrn	:= 0;
    end;
    --
     begin
      select  namimage
      into    v_namimage
      from    tempimge
      where   codempid  = b_index_codempid;
    exception when no_data_found then
      v_namimage  := null;
    end;
    --
    detail_stamarry := get_tlistval_name('NAMMARRY',v_stamarry,global_v_lang);
    detail_codsex   := get_tlistval_name('NAMSEX',v_codsex,global_v_lang);
    detail_codedlv	:= get_tcodec_name('TCODEDUC',v_codedlv,global_v_lang);
    --
    begin
      select codinst into v_codinst
      from teducatn
      where numappl = v_numappl
        and	flgeduc = '1'
        and rownum  <= 1;
      detail_codinst := get_tcodec_name('TCODINST',v_codinst,global_v_lang);
    exception when OTHERS then
      detail_codinst := null;
    end;
    --
    begin
      select desnoffi into v_desnoffi
        from tapplwex
        where numappl = v_numappl
          and dteend  = (select max(dteend) from tapplwex
                          where numappl = v_numappl)
          and rownum  <= 1;
      detail_desnoffi := v_desnoffi;
    exception when others then
        detail_desnoffi := null;
    end;
    --
    detail_numtelof			 := v_numtelof;
    --
    detail_codcomp 	  := get_tcenter_name(v_codcomp,global_v_lang);
    detail_codpos	    := get_tpostn_name(v_codpos,global_v_lang);
    detail_dteempmt   := to_char(v_dteempmt,'dd/mm/yyyy');
    detail_staemp     := get_tlistval_name('NAMESTAT',v_staemp,global_v_lang);
    detail_dteoccup   := to_char(v_dteoccup,'dd/mm/yyyy');
    detail_codempmt   := get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang);
    detail_dteefpos   := to_char(v_dteefpos,'dd/mm/yyyy');
    detail_typpayroll := get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang);
    detail_amtincom   := get_amt_incom(b_index_codempid);
    --
    if v_dteempmt <= sysdate then
      get_service_year(v_dteempmt - nvl(v_qtywkday,0),sysdate,'Y',dteempmt_y,dteempmt_m,v_day);
      detail_dteempmt_y  := dteempmt_y;
      detail_dteempmt_m  := dteempmt_m;
    end if;
    --
    if v_dteempdb <= sysdate then
      get_service_year(v_dteempdb,sysdate,'Y',dteempdb_y,dteempdb_m,v_day);
      detail_dteempdb_y  := dteempdb_y;
      detail_dteempdb_m  := dteempdb_m;
    end if;

    --<<user36 STA3590227 23/02/2016
    detail_numappl	:= v_numappl;
    detail_codpos 	:= v_codpos;
    detail_codcomp	:= v_codcomp;
    -->>user36 STA3590227 23/02/2016
    --
    v_rcnt := v_rcnt+1;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('desc_coderror', ' ');
    obj_data.put('httpcode', '');
    obj_data.put('flg', '');
    obj_data.put('rcnt', v_rcnt);
    obj_data.put('namtitlt', set_data(detail_namtitlt));
    obj_data.put('namfirstt', set_data(detail_namfirstt));
    obj_data.put('namlastt', set_data(detail_namlastt));
    obj_data.put('dteempdb_y', set_data(detail_dteempdb_y));
    obj_data.put('dteempdb_m', set_data(detail_dteempdb_m));
    obj_data.put('tchildrn', set_data(detail_tchildrn));
    obj_data.put('stamarry', set_data(detail_stamarry));
    obj_data.put('codsex', set_data(detail_codsex));
    obj_data.put('codedlv', set_data(detail_codedlv));
    obj_data.put('codinst', set_data(detail_codinst));
    obj_data.put('desnoffi', set_data(detail_desnoffi));
    obj_data.put('numtelof', set_data(detail_numtelof));
    obj_data.put('dteempmt_y', set_data(detail_dteempmt_y));
    obj_data.put('dteempmt_m', set_data(detail_dteempmt_m));
    obj_data.put('codcomp', set_data(detail_codcomp));
    obj_data.put('codpos', set_data(detail_codpos));
    obj_data.put('staemp', set_data(detail_staemp));
    obj_data.put('codempmt', set_data(detail_codempmt));
    obj_data.put('typpayroll', set_data(detail_typpayroll));
    obj_data.put('dteempmt', set_data(detail_dteempmt));
    obj_data.put('dteoccup', set_data(detail_dteoccup));
    obj_data.put('dteefpos', set_data(detail_dteefpos));
    obj_data.put('amtincom', set_data(to_char(detail_amtincom,'fm999,999,990.00')));
    obj_data.put('namimage', v_namimage);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hres31x_tab1;
  --index

  procedure hres31x_tab2(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    v_codsex			  varchar2(200 char);
    v_codrelgn			  varchar2(4 char);
    v_coddomcl			  varchar2(4 char);
    v_codorgin			  varchar2(4 char);
    v_codnatnl			  varchar2(4 char);
    v_stamarry			  varchar2(1 char);
    v_stamilit			  varchar2(1 char);
    --Data
    parameter_p_type      varchar2(4000 char);
    detail1_nickname      varchar2(4000 char);
    detail1_codblood      varchar2(4000 char);
    detail1_weight        varchar2(4000 char);
    detail1_high          varchar2(4000 char);
    detail1_codorgin      varchar2(4000 char);
    detail1_codnatnl      varchar2(4000 char);
    detail1_numappl       varchar2(4000 char);
    detail1_numlicid      varchar2(4000 char);
    detail1_dtelicid      varchar2(4000 char);
    detail1_numpasid      varchar2(4000 char);
    detail1_dtepasid      varchar2(4000 char);
    detail1_numprmid      varchar2(4000 char);
    detail1_dteprmst      varchar2(4000 char);
    detail1_dteprmen      varchar2(4000 char);
    detail1_coddomcl      varchar2(4000 char);
    detail1_adrregt       varchar2(4000 char);
    detail1_dessubdistr   varchar2(4000 char);
    detail1_desdistr      varchar2(4000 char);
    detail1_desprovr      varchar2(4000 char);
    detail1_descntyr      varchar2(4000 char);
    detail1_adrconte      varchar2(4000 char);
    detail1_dessubdistc   varchar2(4000 char);
    detail1_desdistc      varchar2(4000 char);
    detail1_desprovc      varchar2(4000 char);
    detail1_descntyc      varchar2(4000 char);
    detail1_codpostc      varchar2(4000 char);
    detail1_numtelec      varchar2(4000 char);
    detail1_coddistr      varchar2(4000 char);
    detail1_dteempdb      varchar2(4000 char);
    detail1_codsubdistr   varchar2(4000 char);
    detail1_numoffid      varchar2(4000 char);
    detail1_adrissue      varchar2(4000 char);
    v_codprovi            varchar2(4000 char);
    detail1_dteoffid      varchar2(4000 char);
    detail1_codprovr      varchar2(4000 char);
    detail1_codcntyr      varchar2(4000 char);
    detail1_codpostr      varchar2(4000 char);
    detail1_codsubdistc   varchar2(4000 char);
    detail1_coddistc      varchar2(4000 char);
    detail1_codprovc      varchar2(4000 char);
    detail1_codcntyc      varchar2(4000 char);
    detail1_stamarry      varchar2(4000 char);
    detail1_stamilit      varchar2(4000 char);
    detail1_codprovi      varchar2(4000 char);
    detail1_codrelgn      VARCHAR2(4000 CHAR);
    detail1_nummobile     VARCHAR2(4000 CHAR);
    detail1_lineid        VARCHAR2(4000 CHAR);
    detail1_numvisa       VARCHAR2(4000 CHAR);
    detail1_dtevisaexp    VARCHAR2(4000 CHAR);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select decode( global_v_lang,'101',a.nickname,'102',a.nicknamt,'103',a.nicknam3,'104',a.nicknam4,'105',a.nicknam5,a.nickname) nickname,
             a.codsex,
             decode( global_v_lang,'101',b.adrrege,'102',b.adrregt,'103',b.adrreg3,'104',b.adrreg4,'105',b.adrreg5,b.adrrege),
             codsubdistr, coddistr, codprovr ,codcntyr ,codpostr,
             decode( global_v_lang,'101',b.adrconte,'102',b.adrcontt,'103',b.adrcont3,'104',b.adrcont4,'105',b.adrcont5,b.adrconte),
             codsubdistc, coddistc, codprovc ,codcntyc, codpostc, numtelec ,
             b.codblood,b.weight,b.high,b.codrelgn,b.coddomcl,
             b.codorgin,b.codnatnl,to_char(a.dteempdb,'dd/mm/yyyy'),a.stamarry,a.stamilit,b.numoffid,b.adrissue,b.codprovi,to_char(b.dteoffid,'dd/mm/yyyy'),a.numappl,b.numlicid,to_char(b.dtelicid,'dd/mm/yyyy'),b.numpasid,to_char(b.dtepasid,'dd/mm/yyyy'),b.numprmid,
             to_char(b.dteprmst,'dd/mm/yyyy'),to_char(b.dteprmen,'dd/mm/yyyy'),
             a.nummobile,a.lineid,b.numvisa,to_char(b.dtevisaexp,'dd/mm/yyyy') dtevisaexp 
      into   detail1_nickname,v_codsex,detail1_adrregt,
             detail1_codsubdistr, detail1_coddistr, detail1_codprovr ,detail1_codcntyr ,detail1_codpostr,
             detail1_adrconte,
             detail1_codsubdistc, detail1_coddistc, detail1_codprovc, detail1_codcntyc ,detail1_codpostc, detail1_numtelec,
             detail1_codblood,detail1_weight,detail1_high,v_codrelgn,v_coddomcl,
             v_codorgin,v_codnatnl,detail1_dteempdb,v_stamarry,v_stamilit,detail1_numoffid,detail1_adrissue,v_codprovi,detail1_dteoffid,detail1_numappl,detail1_numlicid,detail1_dtelicid,detail1_numpasid,detail1_dtepasid,detail1_numprmid,
             detail1_dteprmst,detail1_dteprmen,detail1_nummobile,detail1_lineid,detail1_numvisa,detail1_dtevisaexp
      from   temploy1 a ,temploy2 b
      where  a.codempid = b_index_codempid
      and    a.codempid = b.codempid ;
    exception when  no_data_found then
      null;
    end;
    --
    detail1_dessubdistr  := get_tsubdist_name(detail1_codsubdistr,global_v_lang);
    detail1_desdistr     := get_tcoddist_name(detail1_coddistr,global_v_lang);
    detail1_desprovr     := get_tcodec_name('TCODPROV',detail1_codprovr,global_v_lang);
    detail1_descntyr     := get_tcodec_name('TCODCNTY',detail1_codcntyr,global_v_lang);

    detail1_dessubdistc  := get_tsubdist_name(detail1_codsubdistc,global_v_lang);
    detail1_desdistc     := get_tcoddist_name(detail1_coddistc,global_v_lang);
    detail1_desprovc     := get_tcodec_name('TCODPROV',detail1_codprovc,global_v_lang);
    detail1_descntyc     := get_tcodec_name('TCODCNTY',detail1_codcntyc,global_v_lang);

    detail1_coddomcl	 := get_tcodec_name('TCODPROV',v_coddomcl,global_v_lang);
    detail1_codorgin	 := get_tcodec_name('TCODREGN',v_codorgin,global_v_lang);
    detail1_codnatnl	 := get_tcodec_name('TCODNATN',v_codnatnl,global_v_lang);
    --
    detail1_stamarry     := get_tlistval_name('NAMMARRY',v_stamarry,global_v_lang);
    detail1_stamilit     := get_tlistval_name('NAMMILIT',v_stamilit,global_v_lang);
    DETAIL1_CODPROVI	 := get_tcodec_name('TCODPROV',V_CODPROVI,GLOBAL_V_LANG);
    detail1_codrelgn	 := get_tcodec_name('TCODRELI',v_codrelgn,global_v_lang);
    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('nicknam',set_data(detail1_nickname));
    obj_row.put('codblood',set_data(detail1_codblood));
    obj_row.put('v_weight',set_data(detail1_weight));
    obj_row.put('v_high',set_data(detail1_high));
    obj_row.put('codrelgn',set_data(detail1_codrelgn));
    obj_row.put('codorgin',set_data(detail1_codorgin));
    obj_row.put('codnatnl',set_data(detail1_codnatnl));
    obj_row.put('numappl',set_data(detail1_numappl));
    obj_row.put('numlicid',set_data(detail1_numlicid));
    obj_row.put('dtelicid',set_data(detail1_dtelicid));
    obj_row.put('numpasid',set_data(detail1_numpasid));
    obj_row.put('dtepasid',set_data(detail1_dtepasid));
    obj_row.put('numprmid',set_data(detail1_numprmid));
    obj_row.put('dteprmst',set_data(detail1_dteprmst));
    obj_row.put('dteprmen',set_data(detail1_dteprmen));
    obj_row.put('dteempdb',set_data(detail1_dteempdb));
    obj_row.put('stamarry',set_data(detail1_stamarry));
    obj_row.put('stamilit',set_data(detail1_stamilit));
    obj_row.put('coddomcl',set_data(detail1_coddomcl));
    obj_row.put('numoffid',set_data(detail1_numoffid));
    obj_row.put('adrissue',set_data(detail1_adrissue));
    obj_row.put('codprovi',set_data(detail1_codprovi));
    obj_row.put('dteoffid',set_data(detail1_dteoffid));
    obj_row.put('adrregt',set_data(detail1_adrregt));
    obj_row.put('dessubdistr',set_data(detail1_dessubdistr));
    obj_row.put('desdistr',set_data(detail1_desdistr));
    obj_row.put('desprovr',set_data(detail1_desprovr));
    obj_row.put('descntyr',set_data(detail1_descntyr));
    obj_row.put('codpostr',set_data(detail1_codpostr));
    obj_row.put('adrconte',set_data(detail1_adrconte));
    obj_row.put('dessubdistc',set_data(detail1_dessubdistc));
    obj_row.put('desdistc',set_data(detail1_desdistc));
    obj_row.put('desprovc',set_data(detail1_desprovc));
    obj_row.put('descntyc',set_data(detail1_descntyc));
    obj_row.put('codpostc',set_data(detail1_codpostc));
    obj_row.put('numtelec',set_data(detail1_numtelec));
    obj_row.put('nummobile',set_data(detail1_nummobile));
    obj_row.put('lineid',set_data(detail1_lineid));
    obj_row.put('numvisa',set_data(detail1_numvisa));
    obj_row.put('dtevisaexp',set_data(detail1_dtevisaexp));
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hres31x_tab2;

  --get_employments_data
  procedure hres31x_tab3(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_codcomp			temploy1.codcomp%type;
    v_codcomp2			temploy1.codcomp%type;
    v_codpos		   	temploy1.codpos%type;
    v_codbrlc		   	temploy1.codbrlc%type;
    v_codempmt			temploy1.codempmt%type;
    v_typpayroll		temploy1.typpayroll%type;
    v_typemp			temploy1.typemp%type;
    v_codcalen			temploy1.codcalen%type;
    v_codjob			temploy1.codjob%type;
    v_staemp			temploy1.staemp%type;
    v_flgatten			temploy1.flgatten%type;
    v_jobgrad			temploy1.jobgrade%type;
    v_codgrpgl			temploy1.codgrpgl%type;
    v_dteefstep         date;
    v_dteempmt          date;
    v_dteduepr          date;
    v_qtydatrq			number := 0;
    v_dteupd			date;
    v_coduser			temploy1.codempid%type;
    v_stadisb			varchar2(8 char);
    v_typdisp			varchar2(8 char);
    v_numdisab			varchar2(20 char);
    v_flgreemp			varchar2(1 char);
    v_ocodempid			temploy1.codempid%type;
    v_dtereemp			date;
    v_dteredue			date;
    v_qtyredue			number := 0;
    --Data
    detail2_dteempmt    varchar2(4000 char);
    detail2_dteefstep   varchar2(4000 char);
    detail2_numlvl      varchar2(4000 char);
    detail2_dteeffex    varchar2(4000 char);
    detail2_dteeflvl    varchar2(4000 char);
    detail2_email       varchar2(4000 char);
    detail2_dteoccup    varchar2(4000 char);
    detail2_numreqst    varchar2(4000 char);
    detail2_dteefpos    varchar2(4000 char);
    detail2_numtelof    varchar2(4000 char);
    detail2_codcomp     varchar2(4000 char);
    detail2_codpos      varchar2(4000 char);
    detail2_codbrlc	    varchar2(4000 char);
    detail2_codempmt	varchar2(4000 char);
    detail2_typpayroll  varchar2(4000 char);
    detail2_typemp	    varchar2(4000 char);
    detail2_codcalen    varchar2(4000 char);
    detail2_codjob		varchar2(4000 char);
    detail2_jobgrad		varchar2(4000 char);
    detail2_codgrpgl	varchar2(4000 char);
    detail2_qtydtepr	varchar2(4000 char);
    detail2_staemp	    varchar2(4000 char);
    detail2_flgatten	varchar2(4000 char);
    detail2_qtyyear		varchar2(4000 char);
    detail2_qtymonth 	varchar2(4000 char);
    detail2_dteupd      varchar2(4000 char);
    detail2_coduser  	varchar2(4000 char);
    detail2_typdisp  	varchar2(4000 char);
    detail2_desdisp  	varchar2(4000 char);
    detail2_flgreemp  	varchar2(4000 char);
    detail2_namabb  	varchar2(4000 char);
    detail2_dtedisb  	varchar2(4000 char);
    detail2_dtedisen  	varchar2(4000 char);    

  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select dteempmt,to_char(dteempmt,'dd/mm/yyyy'),codcomp,codpos,codbrlc,codempmt,
             typpayroll,typemp,codcalen,codjob,jobgrade,codgrpgl,to_char(dteefstep,'dd/mm/yyyy'),numlvl,
             to_char(dteeffex,'dd/mm/yyyy'),to_char(dteeflvl,'dd/mm/yyyy'),dteduepr,
             qtydatrq,email,to_char(dteoccup,'dd/mm/yyyy'),numreqst,staemp,flgatten,
             to_char(dteefpos,'dd/mm/yyyy'),numtelof,dteupd,coduser,stadisb,typdisp,desdisp,
             numdisab,to_char(dtedisb,'dd/mm/yyyy') dtedisb,to_char(dtedisen,'dd/mm/yyyy') dtedisen,flgreemp,ocodempid,dtereemp,dteredue

      into   v_dteempmt,detail2_dteempmt,v_codcomp,v_codpos,v_codbrlc,v_codempmt,
             v_typpayroll,v_typemp,v_codcalen,v_codjob,v_jobgrad,v_codgrpgl,detail2_dteefstep,detail2_numlvl,
             detail2_dteeffex,detail2_dteeflvl,v_dteduepr,v_qtydatrq,
             detail2_email,detail2_dteoccup,detail2_numreqst,v_staemp,v_flgatten,
             detail2_dteefpos,detail2_numtelof,v_dteupd,v_coduser,v_stadisb,v_typdisp,detail2_desdisp,
             v_numdisab,detail2_dtedisb,detail2_dtedisen,v_flgreemp,v_ocodempid,v_dtereemp,v_dteredue
      from   temploy1
      where  codempid = b_index_codempid ;
    exception when  no_data_found then
      null;
    end;
    --
    if (v_dteduepr is not null) or (v_dteempmt is not null) then
      if (v_dteduepr - v_dteempmt) <> 0 then
         detail2_qtydtepr := v_dteduepr - v_dteempmt + 1 ;
      end if;
    else
      detail2_qtydtepr := '0';
    end if;
    --
    detail2_staemp 		 := get_tlistval_name('NAMESTAT',v_staemp,global_v_lang);
    detail2_flgatten	 := get_tlistval_name('NAMSTAMP',v_flgatten,global_v_lang);
    detail2_qtyyear		 := trunc(v_qtydatrq / 12);
    detail2_qtymonth   := mod(v_qtydatrq,12);
    detail2_dteupd     := to_char(v_dteupd,'dd/mm/yyyy');
    detail2_coduser    := v_coduser;
    detail2_typdisp    := get_tcodec_name('TCODDISP',v_typdisp,global_v_lang);
    detail2_flgreemp   := get_tlistval_name('NAMREHIR',v_flgreemp,global_v_lang);
    v_qtyredue         := v_dteredue - v_dtereemp;

    --
    detail2_codcomp     := get_tcenter_name(v_codcomp,global_v_lang);
    detail2_codpos      := get_tpostn_name(v_codpos,global_v_lang);
    detail2_codbrlc	    := get_tcodec_name('TCODLOCA',v_codbrlc,global_v_lang);
    detail2_codempmt	  := get_tcodec_name('TCODEMPL',v_codempmt,global_v_lang);
    detail2_typpayroll	:= get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang);
    detail2_typemp			:= get_tcodec_name('TCODCATG',v_typemp,global_v_lang);
    detail2_codcalen		:= get_tcodec_name('TCODWORK',v_codcalen,global_v_lang);
    detail2_codjob			:= get_tjobcode_name(v_codjob,global_v_lang);
    detail2_jobgrad	  	:= get_tcodec_name('TCODJOBG',v_jobgrad,global_v_lang);
    detail2_codgrpgl		:= get_tcodec_name('TCODGRPGL',v_codgrpgl,global_v_lang);
    detail2_namabb		  := get_tpostninit_name(v_codpos,global_v_lang);
    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('dteempmt',set_data(detail2_dteempmt));
    obj_row.put('codcomp',set_data(detail2_codcomp));
    obj_row.put('codpos',set_data(detail2_codpos));
    obj_row.put('codbrlc',set_data(detail2_codbrlc));
    obj_row.put('codempmt',set_data(detail2_codempmt));
    obj_row.put('typpayroll',set_data(detail2_typpayroll));
    obj_row.put('typemp',set_data(detail2_typemp));
    obj_row.put('codcalen',set_data(detail2_codcalen));
    obj_row.put('codjob',set_data(detail2_codjob));
    obj_row.put('jobgrad',set_data(detail2_jobgrad));
    obj_row.put('codgrpgl',set_data(detail2_codgrpgl));
    obj_row.put('dteefstep',set_data(detail2_dteefstep));
    obj_row.put('qtydtepr',set_data(detail2_qtydtepr));
    obj_row.put('qtyyear',set_data(detail2_qtyyear));
    obj_row.put('qtymonth',set_data(detail2_qtymonth));
    obj_row.put('email',set_data(detail2_email));
    obj_row.put('numlvl',set_data(detail2_numlvl));
    obj_row.put('dteeffex',set_data(detail2_dteeffex));
    obj_row.put('dteeflvl',set_data(detail2_dteeflvl));
    obj_row.put('dteoccup',set_data(detail2_dteoccup));
    obj_row.put('numreqst',set_data(detail2_numreqst));
    obj_row.put('staemp',set_data(detail2_staemp));
    obj_row.put('flgatten',set_data(detail2_flgatten));
    obj_row.put('dteefpos',set_data(detail2_dteefpos));
    obj_row.put('numtelof',set_data(detail2_numtelof));
    obj_row.put('dteupd',set_data(detail2_dteupd));
    obj_row.put('coduser',set_data(detail2_coduser));
    obj_row.put('namabb',set_data(detail2_namabb));
    obj_row.put('stadisb',set_data(v_stadisb));
    obj_row.put('typdisp',set_data(detail2_typdisp));
    obj_row.put('desdisp',set_data(detail2_desdisp));
    obj_row.put('numdisab',set_data(v_numdisab));
    obj_row.put('dtedisb',set_data(detail2_dtedisb));
    obj_row.put('dtedisen',set_data(detail2_dtedisen));
    obj_row.put('flgreemp',set_data(detail2_flgreemp));
    obj_row.put('ocodempid',set_data(v_ocodempid));
    obj_row.put('qtyredue',set_data(v_qtyredue));
    obj_row.put('dtereemp',set_data(to_char(v_dtereemp,'dd/mm/yyyy')));
    obj_row.put('dteredue',set_data(to_char(v_dteredue,'dd/mm/yyyy')));
    json_str_output:=obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hres31x_tab3;

  --get_income_data
  procedure hres31x_tab4_table(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_rcnt      number := 0;
    v_details   varchar2(4000 char);
    v_detail    varchar2(20 char);
    v_code      varchar2(50 char);
    v_codes     varchar2(50 char);
    v_amtincom  varchar2(50 char);
    v_codcomp   tcenter.codcomp%type;
    v_codempmt  temploy1.codempmt%type;
    v_sumhur	  number := 0;
    v_summth	  number := 0;
    v_sumday	  number := 0;
    detail3_codcurr   varchar2(4000 char);
    detail3_codcomp   varchar2(4000 char);


    type arr is table of varchar2(600 char) index by binary_integer;
    v_unit              arr;
    detail3_v_unit      arr;
    detail3_v_code      arr;
    detail3_amtincom    arr;
    detail3_v_details   arr;
    detail3_v_amt       arr;

  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    --initial array
    for i in 1..10 loop
      v_unit(i)           := '';
      detail3_v_unit(i)   := '';
      detail3_v_code(i)   := '';
      detail3_amtincom(i) := '';
      detail3_v_details(i):= '';
      detail3_v_amt(i)    := '';
    end loop;
    --
    begin
      select b.codcurr,a.codempmt,a.codcomp
      into  detail3_codcurr,v_codempmt,detail3_codcomp
      from  temploy1 a,tcontrpy b
      where a.codempid = b_index_codempid
      and		b.codcompy = hcm_util.get_codcomp_level(a.codcomp,'1')
      and		dteeffec in ( select max(dteeffec)
                          from tcontrpy
                          where dteeffec <= sysdate
                            and codcompy = hcm_util.get_codcomp_level(a.codcomp,'1'));
    exception when no_data_found then
        null;
    end;
    --
    begin
      select amtincom1,amtincom2,amtincom3,amtincom4,amtincom5,
             amtincom6,amtincom7,amtincom8,amtincom9,amtincom10,amtproadj
      into   detail3_amtincom(1),detail3_amtincom(2),detail3_amtincom(3),detail3_amtincom(4),detail3_amtincom(5),
             detail3_amtincom(6),detail3_amtincom(7),detail3_amtincom(8),detail3_amtincom(9),detail3_amtincom(10),detail3_amtproadj
      from  temploy3
      where codempid = b_index_codempid;
    exception when no_data_found then
      detail3_amtincom(1)			:= 0;
      detail3_amtincom(2)			:= 0;
      detail3_amtincom(3)			:= 0;
      detail3_amtincom(4)			:= 0;
      detail3_amtincom(5)			:= 0;
      detail3_amtincom(6)			:= 0;
      detail3_amtincom(7)			:= 0;
      detail3_amtincom(8)			:= 0;
      detail3_amtincom(9)			:= 0;
      detail3_amtincom(10)		:= 0;
    end;
     --
    for i in 1..10 loop
      v_amtincom := stddec(detail3_amtincom(i),b_index_codempid,v_chken);

      if detail3_v_code(i) is null then
        detail3_amtincom(i) := 0;
        detail3_v_amt(i) := 0;
      end if;
    end loop ;
    --
    hcm_util.get_cod_income(hcm_util.get_codcomp_level(detail3_codcomp,'1'),v_codempmt,
                                                  detail3_v_code(1), detail3_v_code(2),
                                                  detail3_v_code(3), detail3_v_code(4),
                                                  detail3_v_code(5), detail3_v_code(6),
                                                  detail3_v_code(7), detail3_v_code(8),
                                                  detail3_v_code(9), detail3_v_code(10),
                                                  v_unit(1),v_unit(2),v_unit(3),v_unit(4),v_unit(5),
                                                  v_unit(6),v_unit(7),v_unit(8),v_unit(9),v_unit(10));
    --
    for i in 1..10 loop
      hcm_util.get_income(global_v_lang,detail3_v_code(i),detail3_v_details(i));
      if v_unit(i)  is not null then
        detail3_v_unit(i) := get_tlistval_name('NAMEUNIT',v_unit(i),global_v_lang);
      end if;
      if detail3_v_code(i) is null then
        detail3_v_amt(i) := null;
      end if;
    end loop;
     --
    parameter_codempmt := v_codempmt;

    --find_totnet
    get_wage_income(hcm_util.get_codcomp_level(detail3_codcomp,'1'),parameter_codempmt,
                    nvl(detail3_v_amt(1),0), nvl(detail3_v_amt(2),0) ,
                    nvl(detail3_v_amt(3),0), nvl(detail3_v_amt(4),0) ,
                    nvl(detail3_v_amt(5),0), nvl(detail3_v_amt(6),0) ,
                    nvl(detail3_v_amt(7),0), nvl(detail3_v_amt(8),0) ,
                    nvl(detail3_v_amt(9),0), nvl(detail3_v_amt(10),0),
                    v_sumhur ,v_sumday,v_summth );

                    v_sumhur	:= round(v_sumhur,2);
                    v_sumday	:= round(v_sumday,2);
                    v_summth	:= round(v_summth,2);

--      detail3_m_amttot  := nvl(v_summth,0); --per months
--      detail3_d_amttot  := nvl(v_sumday,0); --per days
--      detail3_h_amttot  := nvl(v_sumhur,0); --per hours

--    detail3_m_amttot  := set_data(hcm_secur.hcmenc(to_char(nvl(v_summth,0),'fm999,999,990.00'))); --per months
    detail3_m_amttot  := set_data((to_char(nvl(v_summth,0),'fm999,999,990.00'))); --per months
--    detail3_d_amttot  := set_data(hcm_secur.hcmenc(to_char(nvl(v_sumday,0),'fm999,999,990.00'))); --per days
    detail3_d_amttot  := set_data((to_char(nvl(v_sumday,0),'fm999,999,990.00'))); --per days
--    detail3_h_amttot  := set_data(hcm_secur.hcmenc(to_char(nvl(v_sumhur,0),'fm999,999,990.00'))); --per hours
    detail3_h_amttot  := set_data((to_char(nvl(v_sumhur,0),'fm999,999,990.00'))); --per hours

   -- detail3_amtproadj := stddec(detail3_amtproadj,b_index_codempid,v_chken);
     detail3_amtproadj :=  set_data((to_char(stddec(detail3_amtproadj,b_index_codempid,v_chken),'fm999,999,990.00')));

    --
    detail3_desc_codecurr  := get_tcodec_name('TCODCURR',detail3_codcurr,global_v_lang);
    --
    obj_data := json_object_t();
    for i in 1..10 loop
      if detail3_v_amt(i) is not null then
        v_rcnt := v_rcnt+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt', to_char(v_rcnt));
        obj_data.put('code', set_data(0)); --obj_data.put('code', set_data(detail3_v_code(i)));
        obj_data.put('desc_income', set_data(detail3_v_details(i)));
        obj_data.put('unit', set_data(detail3_v_unit(i)));
        obj_data.put('qtyincome', set_data(to_char(detail3_v_amt(i),'fm999,999,990.00')));
        --
        obj_data.put('hour_income', detail3_h_amttot);
        obj_data.put('day_income', detail3_d_amttot);
        obj_data.put('month_income', detail3_m_amttot);


        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;

    -- set total
--    if v_rcnt > 0 then
--      json_ext.put(obj_row, '0.total', to_char(v_rcnt));
--    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
  --
  procedure hres31x_tab4(json_str_input in clob, json_str_output out clob) as
    obj_json                json_object_t;
    obj_json2               json_object_t;
    obj_row                 json_object_t;
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    hres31x_tab4_table(json_str_input,json_str_output);
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('desc_codecurr', detail3_desc_codecurr);
    obj_row.put('hour_income', detail3_h_amttot);
    obj_row.put('day_income', detail3_d_amttot);
    obj_row.put('month_income', detail3_m_amttot);
    obj_row.put('amtproadj', detail3_amtproadj);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);

  end;

  --get_tax_data_tab1
  procedure hres31x_tab5_1(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_count             number := 0;
    v_flgtax			varchar2(1 char);
    v_typtax			varchar2(1 char);
    v_codbank 			varchar2(4 char);
    v_codbank2			varchar2(4 char);
    v_dteupd			date;
    v_coduser           temploy1.codempid%type;
    v_amtincbf          varchar2(30 char);
    v_amttaxbf          varchar2(30 char);
    v_amtpf             varchar2(30 char);
    v_amtsaid           varchar2(30 char);
    v_amtincsp          varchar2(30 char);
    v_amttaxsp          varchar2(30 char);
    v_amtpfsp           varchar2(30 char);
    v_amtsasp           varchar2(30 char);
    --Data
    detail4_numtaxid    varchar2(4000 char);
    detail4_numsaid     varchar2(4000 char);
    detail4_numbank     varchar2(4000 char);
    detail4_amtbank     varchar2(4000 char);
    detail4_numbank2    varchar2(4000 char);
    detail4_dtebf       varchar2(4000 char);
    detail4_dtebfsp     varchar2(4000 char);
    detail4_amtincbf    varchar2(4000 char);
    detail4_amttaxbf    varchar2(4000 char);
    detail4_amtpf       varchar2(4000 char);
    detail4_amtsaid     varchar2(4000 char);
    detail4_amtincsp    varchar2(4000 char);
    detail4_amttaxsp    varchar2(4000 char);
    detail4_amtpfsp     varchar2(4000 char);
    detail4_amtsasp     varchar2(4000 char);
    detail4_tax_deduct  varchar2(4000 char);
    detail4_tax_payment varchar2(4000 char);
    detail4_codbank1	varchar2(4000 char);
    detail4_codbank2    varchar2(4000 char);
    detail4_frsmemb     varchar2(4000 char);
    detail4_codcln      varchar2(4000 char);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select b.numtaxid,b.numsaid,flgtax, typtax,
             b.codbank,b.numbank,b.amtbank,b.codbank2,b.numbank2,
             b.dtebf,b.amtincbf,b.amttaxbf,b.amtpf,b.amtsaid,
             b.dtebfsp,b.amtincsp,b.amttaxsp,b.amtpfsp, b.amtsasp,
             b.dteupd,b.coduser
      into   detail4_numtaxid,detail4_numsaid,v_flgtax,v_typtax,
             v_codbank,detail4_numbank,detail4_amtbank,v_codbank2,detail4_numbank2,
             detail4_dtebf,v_amtincbf,v_amttaxbf,v_amtpf,v_amtsaid,
             detail4_dtebfsp,v_amtincsp,v_amttaxsp,v_amtpfsp,v_amtsasp,
             v_dteupd,v_coduser
      from   temploy1 a, temploy3 b
      where  a.codempid = b_index_codempid
      and    a.codempid = b.codempid
      and    rownum     = 1;
    exception when no_data_found then
      null;
    end;
    --
    begin
      select to_char(frsmemb,'dd/mm/yyyy'),get_tclninf_name(codclnok,global_v_lang)
        into detail4_frsmemb,detail4_codcln
        from  tssmemb
       where  codempid = b_index_codempid;
    exception when no_data_found then
      detail4_frsmemb := null;
    end;
    --
    detail4_amtincbf      := stddec(v_amtincbf,b_index_codempid,v_chken);
    detail4_amttaxbf      := stddec(v_amttaxbf,b_index_codempid,v_chken);
    detail4_amtpf         := stddec(v_amtpf,b_index_codempid,v_chken);
    detail4_amtsaid       := stddec(v_amtsaid,b_index_codempid,v_chken);

    detail4_amtincsp      := stddec(v_amtincsp,b_index_codempid,v_chken);
    detail4_amttaxsp      := stddec(v_amttaxsp,b_index_codempid,v_chken);
    detail4_amtpfsp       := stddec(v_amtpfsp,b_index_codempid,v_chken);
    detail4_amtsasp       := stddec(v_amtsasp,b_index_codempid,v_chken);

    detail4_tax_deduct    := get_tlistval_name('NAMTSTAT',v_flgtax,global_v_lang);
    detail4_tax_payment   := get_tlistval_name('NAMTAXDD',v_typtax,global_v_lang);
    detail4_codbank1	  := get_tcodec_name('TCODBANK',v_codbank,global_v_lang);
    detail4_codbank2	  := get_tcodec_name('TCODBANK',v_codbank2,global_v_lang);
    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('numtaxid',set_data(detail4_numtaxid));
    obj_row.put('tax_deduct',set_data(detail4_tax_deduct));
    obj_row.put('tax_payment',set_data(detail4_tax_payment));
    obj_row.put('numsaid',set_data(detail4_numsaid));
    obj_row.put('frsmemb',set_data(detail4_frsmemb));
    obj_row.put('codcln',set_data(detail4_codcln));
    obj_row.put('codbank1',set_data(detail4_codbank1));
    obj_row.put('numbank',set_data(detail4_numbank));
    obj_row.put('amtbank',set_data(to_char(detail4_amtbank,'fm990.00')));
    obj_row.put('codbank2',set_data(detail4_codbank2));
    obj_row.put('numbank2',set_data(detail4_numbank2));

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_tax_data_tab2
  procedure hres31x_tab5_2(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_count             number := 0;
    v_flgtax			varchar2(1 char);
    v_typtax			varchar2(1 char);
    v_codbank 			varchar2(4 char);
    v_codbank2			varchar2(4 char);
    v_dteupd			date;
    v_coduser           temploy1.codempid%type;
    v_amtincbf          varchar2(30 char);
    v_amttaxbf          varchar2(30 char);
    v_amtpf             varchar2(30 char);
    v_amtsaid           varchar2(30 char);
    v_amtincsp          varchar2(30 char);
    v_amttaxsp          varchar2(30 char);
    v_amtpfsp           varchar2(30 char);
    v_amtsasp           varchar2(30 char);
    v_typincom          varchar2(1 char);
    v_amttranb          varchar2(20 char);
    --Data
    detail4_numtaxid    varchar2(4000 char);
    detail4_numsaid     varchar2(4000 char);
    detail4_numbank     varchar2(4000 char);
    detail4_amtbank     varchar2(4000 char);
    detail4_numbank2    varchar2(4000 char);
    detail4_dtebf       varchar2(4000 char);
    detail4_dtebfsp     varchar2(4000 char);
    detail4_amtincbf    varchar2(4000 char);
    detail4_amttaxbf    varchar2(4000 char);
    detail4_amtpf       varchar2(4000 char);
    detail4_amtsaid     varchar2(4000 char);
    detail4_amtincsp    varchar2(4000 char);
    detail4_amttaxsp    varchar2(4000 char);
    detail4_amtpfsp     varchar2(4000 char);
    detail4_amtsasp     varchar2(4000 char);
    detail4_tax_deduct  varchar2(4000 char);
    detail4_tax_payment varchar2(4000 char);
    detail4_codbank1	varchar2(4000 char);
    detail4_codbank2    varchar2(4000 char);
    detail4_frsmemb     varchar2(4000 char);
    detail4_codcln      varchar2(4000 char);
    detail4_typincom    varchar2(4000 char);
    detail4_amttranb    varchar2(4000 char);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select b.numtaxid,b.numsaid,flgtax, typtax,
             b.codbank,b.numbank,b.amtbank,b.codbank2,b.numbank2,
             to_char(b.dtebf,'dd/mm/yyyy'),b.amtincbf,b.amttaxbf,b.amtpf,b.amtsaid,
             to_char(b.dtebfsp,'dd/mm/yyyy'),b.amtincsp,b.amttaxsp,b.amtpfsp, b.amtsasp,
             B.DTEUPD,B.CODUSER, b.typincom, b.amttranb
      into   detail4_numtaxid,detail4_numsaid,v_flgtax,v_typtax,
             v_codbank,detail4_numbank,detail4_amtbank,v_codbank2,detail4_numbank2,
             detail4_dtebf,v_amtincbf,v_amttaxbf,v_amtpf,v_amtsaid,
             detail4_dtebfsp,v_amtincsp,v_amttaxsp,v_amtpfsp,v_amtsasp,
             v_dteupd,v_coduser, v_typincom, v_amttranb
      from   temploy1 a, temploy3 b
      where  a.codempid = b_index_codempid
      and    a.codempid = b.codempid
      and    rownum     = 1;
    exception when no_data_found then
      null;
    end;
    --
    begin
      select to_char(frsmemb,'dd/mm/yyyy'),get_tclninf_name(codclnok,global_v_lang)
        into detail4_frsmemb,detail4_codcln
        from  tssmemb
       where  codempid = b_index_codempid;
    exception when no_data_found then
      detail4_frsmemb := null;
    end;
    --
    detail4_amtincbf      := stddec(v_amtincbf,b_index_codempid,v_chken);
    detail4_amttaxbf      := stddec(v_amttaxbf,b_index_codempid,v_chken);
    detail4_amtpf         := stddec(v_amtpf,b_index_codempid,v_chken);
    detail4_amtsaid       := stddec(v_amtsaid,b_index_codempid,v_chken);

    detail4_amtincsp      := stddec(v_amtincsp,b_index_codempid,v_chken);
    detail4_amttaxsp      := stddec(v_amttaxsp,b_index_codempid,v_chken);
    detail4_amtpfsp       := stddec(v_amtpfsp,b_index_codempid,v_chken);
    detail4_amtsasp       := stddec(v_amtsasp,b_index_codempid,v_chken);

    detail4_tax_deduct    := get_tlistval_name('NAMTSTAT',v_flgtax,global_v_lang);
    detail4_tax_payment   := get_tlistval_name('NAMTAXDD',v_typtax,global_v_lang);
    detail4_codbank1	  := get_tcodec_name('TCODBANK',v_codbank,global_v_lang);
    detail4_codbank2	  := get_tcodec_name('TCODBANK',v_codbank2,global_v_lang);
    detail4_typincom	  := get_tlistval_name('TYPINCOM',v_typincom,global_v_lang);
    detail4_amttranb      := stddec(v_amttranb,b_index_codempid,v_chken);
    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('dtebf',set_data(detail4_dtebf));
    obj_row.put('amtincbf',set_data(to_char(detail4_amtincbf,'fm999,999,990.00')));
    obj_row.put('amttaxbf',set_data(to_char(detail4_amttaxbf,'fm999,999,990.00')));
    obj_row.put('amtpf',set_data(to_char(detail4_amtpf,'fm999,999,990.00')));
    obj_row.put('amtsaid',set_data(to_char(detail4_amtsaid,'fm999,999,990.00')));
    obj_row.put('dtebfsp',set_data(detail4_dtebfsp));
    obj_row.put('amtincsp',set_data(to_char(detail4_amtincsp,'fm999,999,990.00')));
    obj_row.put('amttaxsp',set_data(to_char(detail4_amttaxsp,'fm999,999,990.00')));
    obj_row.put('amtpfsp',set_data(to_char(detail4_amtpfsp,'fm999,999,990.00')));
    obj_row.put('amtsasp',set_data(to_char(detail4_amtsasp,'fm999,999,990.00')));
    obj_row.put('dteupd',set_data(to_char(v_dteupd,'dd/mm/yyyy')));
    obj_row.put('coduser',set_data(v_coduser));
    obj_row.put('typincom',set_data(detail4_typincom));
    obj_row.put('amttranb',set_data(to_char(detail4_amttranb,'fm999,999,990.00')));

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_tax_data_tab3
  procedure hres31x_tab5_3(json_str_input in clob, json_str_output out clob) as
    obj_data                  json_object_t;
    obj_row                   json_object_t;
    v_codcomp                 temploy1.codcomp%type;
    v_count                   number := 0;
    v_rcnt                    number := 0;
    v_flgtax				  varchar2(1 char);
    v_typtax				  varchar2(1 char);
    v_codbank 			      varchar2(4 char);
    v_codbank2			      varchar2(4 char);
    v_dteupd				  date;
    v_coduser                 temploy1.codempid%type;
    v_amtincbf                varchar2(30 char);
    v_amttaxbf                varchar2(30 char);
    v_amtpf                   varchar2(30 char);
    v_amtsaid                 varchar2(30 char);
    v_amtincsp                varchar2(30 char);
    v_amttaxsp                varchar2(30 char);
    v_amtpfsp                 varchar2(30 char);
    v_amtsasp                 varchar2(30 char);
    --Data
    tempded_codempid          varchar2(4000 char);
    tempded_coddeduct         varchar2(4000 char);
    tempded_desc_coddeduct    varchar2(4000 char);
    tempded_v_amtdeduct       varchar2(4000 char);
    tempded_v_amtspded        varchar2(4000 char);

    --Cursor
    cursor c_tdeductd is
      select coddeduct
        from tdeductd
       where typdeduct = 'E'
         and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
         and coddeduct <> 'E001'
         and dteyreff  = (select max(dteyreff )
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and   codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                           );                     

  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    begin
      select codcomp 
      into v_codcomp
      from temploy1
      where codempid = b_index_codempid;
    exception when no_data_found then
      v_codcomp := '';
    end;
    select count(*)
      into v_rcnt
      from tdeductd
     where typdeduct = 'E'
       and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
       and coddeduct <> 'E001'
       and dteyreff  = (select max(dteyreff )
                          from tdeductd
                         where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                         );
    --
    if v_rcnt > 0 then
      for i in c_tdeductd loop
        v_count := v_count + 1;
        --
        tempded_codempid        := b_index_codempid;
        tempded_coddeduct       := i.coddeduct;
        tempded_desc_coddeduct  := get_tcodeduct_name(i.coddeduct,global_v_lang);
        --
        begin
          select stddec(amtdeduct,b_index_codempid,v_chken),
                 stddec(amtspded,b_index_codempid,v_chken)
            into tempded_v_amtdeduct,tempded_v_amtspded
            from tempded
           where codempid  = b_index_codempid
             and coddeduct = i.coddeduct;
        exception when no_data_found then
          tempded_v_amtdeduct := 0;
          tempded_v_amtspded  := 0;
        end;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('coddeduct',set_data(tempded_coddeduct));
        obj_data.put('desc_coddeduct',set_data(tempded_desc_coddeduct));
        obj_data.put('v_amtdeduct',set_data(to_char(tempded_v_amtdeduct,'fm999,999,990.00')));
        obj_data.put('v_amtspded',set_data(to_char(tempded_v_amtspded,'fm999,999,990.00')));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop; --c1
    end if; --v_rcnt

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_tax_data_tab4
  procedure hres31x_tab5_4(json_str_input in clob, json_str_output out clob) as
    obj_data                  json_object_t;
    obj_row                   json_object_t;
    v_codcomp                 temploy1.codcomp%type;    
    v_count                   number := 0;
    v_rcnt                    number := 0;
    v_flgtax				  varchar2(1 char);
    v_typtax				  varchar2(1 char);
    v_codbank 			      varchar2(4 char);
    v_codbank2			      varchar2(4 char);
    v_dteupd				  date;
    v_coduser                 temploy1.codempid%type;
    v_amtincbf                varchar2(30 char);
    v_amttaxbf                varchar2(30 char);
    v_amtpf                   varchar2(30 char);
    v_amtsaid                 varchar2(30 char);
    v_amtincsp                varchar2(30 char);
    v_amttaxsp                varchar2(30 char);
    v_amtpfsp                 varchar2(30 char);
    v_amtsasp                 varchar2(30 char);
    --Data
    tempded2_codempid         varchar2(4000 char);
    tempded2_coddeduct        varchar2(4000 char);
    tempded2_desc_coddeduct   varchar2(4000 char);
    tempded2_v_amtdeduct      varchar2(4000 char);
    tempded2_v_amtspded       varchar2(4000 char);
    tempded2_qtychedu         varchar2(4000 char);
    tempded2_qtychned         varchar2(4000 char);
    tempded2_qtychldb         temploy3.qtychldb%type;
    tempded2_qtychlda         temploy3.qtychlda%type;
    tempded2_qtychldd         temploy3.qtychldd%type;
    tempded2_qtychldi         temploy3.qtychldi%type;
    --Cursor
    cursor c_tdeductd2 is
      select coddeduct
        from tdeductd
       where typdeduct = 'D'
         and coddeduct not in ('D001','D002')
         and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
         and dteyreff  = (select max(dteyreff )
                            from tdeductd
                           where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                           and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                           );

  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    --
    begin
      select codcomp 
      into v_codcomp
      from temploy1
      where codempid = b_index_codempid;
    exception when no_data_found then
      v_codcomp := '';
    end;

    select count(*)
      into v_rcnt
      from tdeductd
     where typdeduct = 'D'
       and coddeduct not in ('D001','D002')
       and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
       and dteyreff  = (select max(dteyreff )
                          from tdeductd
                         where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                         and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                         );
    --
    if v_rcnt > 0 then
      for i in c_tdeductd2 loop
        v_count := v_count + 1;
        --
        tempded2_codempid        := b_index_codempid;
        tempded2_coddeduct       := i.coddeduct;
        tempded2_desc_coddeduct  := get_tcodeduct_name(i.coddeduct,global_v_lang);
        --
        begin
          select qtychldb,qtychlda,qtychldd,qtychldi
          into	 tempded2_qtychldb,tempded2_qtychlda,tempded2_qtychldd,tempded2_qtychldi
          from 	 temploy3
          where  codempid = b_index_codempid;
        exception when no_data_found then
          tempded2_qtychedu := 0;
          tempded2_qtychned := 0;
        end;
        --
        begin
          select stddec(amtdeduct,b_index_codempid,v_chken),
                 stddec(amtspded,b_index_codempid,v_chken)
            into tempded2_v_amtdeduct,tempded2_v_amtspded
            from tempded
           where codempid  = b_index_codempid
             and coddeduct = i.coddeduct;
        exception when no_data_found then
          tempded2_v_amtdeduct := 0;
          tempded2_v_amtspded  := 0;
        end;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('coddeduct',set_data(tempded2_coddeduct));
        obj_data.put('desc_coddeduct',set_data(tempded2_desc_coddeduct));
        obj_data.put('v_amtdeduct',set_data(to_char(tempded2_v_amtdeduct,'fm999,999,990.00')));
        obj_data.put('v_amtspded',set_data(to_char(tempded2_v_amtspded,'fm999,999,990.00')));
        obj_data.put('qtychldb',set_data(tempded2_qtychldb));
        obj_data.put('qtychlda',set_data(tempded2_qtychlda));
        obj_data.put('qtychldd',set_data(tempded2_qtychldd));
        obj_data.put('qtychldi',set_data(tempded2_qtychldi));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop; --c1
    end if; --v_rcnt
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

   --get_tax_data_tab5
  procedure hres31x_tab5_5(json_str_input in clob, json_str_output out clob) as
    obj_data                  json_object_t;
    obj_row                   json_object_t;
    v_codcomp                 temploy1.codcomp%type;     
    v_count                   number := 0;
    v_rcnt                    number := 0;
    v_flgtax				  varchar2(1 char);
    v_typtax				  varchar2(1 char);
    v_codbank 			      varchar2(4 char);
    v_codbank2			      varchar2(4 char);
    v_dteupd				  date;
    v_coduser                 temploy1.codempid%type;
    v_amtincbf                varchar2(30 char);
    v_amttaxbf                varchar2(30 char);
    v_amtpf                   varchar2(30 char);
    v_amtsaid                 varchar2(30 char);
    v_amtincsp                varchar2(30 char);
    v_amttaxsp                varchar2(30 char);
    v_amtpfsp                 varchar2(30 char);
    v_amtsasp                 varchar2(30 char);
    --Data
    tempded3_codempid         varchar2(4000 char);
    tempded3_coddeduct        varchar2(4000 char);
    tempded3_desc_coddeduct   varchar2(4000 char);
    tempded3_v_amtdeduct      varchar2(4000 char);
    tempded3_v_amtspded       varchar2(4000 char);

    --Cursor
  	cursor c_tdeductd3 is
		select coddeduct
		  from tdeductd
		 where typdeduct = 'O'
           and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
		   and dteyreff = (select max(dteyreff )
                         from tdeductd
                        where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                        and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                        );
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    begin
      select codcomp 
      into v_codcomp
      from temploy1
      where codempid = b_index_codempid;
    exception when no_data_found then
      v_codcomp := '';
    end;

    select count(*)
      into v_rcnt
      from tdeductd
     where typdeduct = 'O'
       and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
       and dteyreff = (select max(dteyreff )
                         from tdeductd
                        where dteyreff <= to_number(to_char(sysdate,'yyyy'))
                        and codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                        );
    --
    if v_rcnt > 0 then
      for i in c_tdeductd3 loop
        v_count := v_count + 1;
        --
        tempded3_codempid        := b_index_codempid;
        tempded3_coddeduct       := i.coddeduct;
        tempded3_desc_coddeduct  := get_tcodeduct_name(i.coddeduct,global_v_lang);
        --
        begin
          select stddec(amtdeduct,b_index_codempid,v_chken),
                 stddec(amtspded,b_index_codempid,v_chken)
            into tempded3_v_amtdeduct,tempded3_v_amtspded
            from tempded
           where codempid  = b_index_codempid
             and coddeduct = i.coddeduct;
        exception when no_data_found then
          tempded3_v_amtdeduct := 0;
          tempded3_v_amtspded  := 0;
        end;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('coddeduct',set_data(tempded3_coddeduct));
        obj_data.put('desc_coddeduct',set_data(tempded3_desc_coddeduct));
        obj_data.put('v_amtdeduct',set_data(to_char(tempded3_v_amtdeduct,'fm999,999,990.00')));
        obj_data.put('v_amtspded',set_data(to_char(tempded3_v_amtspded,'fm999,999,990.00')));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop; --c1
    end if; --v_rcnt

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_education_data
  procedure hres31x_tab6_table(json_str_input in clob, json_str_output out clob) as
    obj_row    json_object_t;
    obj_data   json_object_t;
    v_count    number := 0;
    v_rcnt     number := 0;
    --Data
    detail5_numseq	    varchar2(4000 char);
    detail5_codedlv	    varchar2(4000 char);
    detail5_codmajsb	varchar2(4000 char);
    detail5_codcount	varchar2(4000 char);
    detail5_numgpa	    varchar2(4000 char);
    detail5_flgeduc 	varchar2(4000 char);
    detail5_coddglv 	varchar2(4000 char);
    detail5_codinst 	varchar2(4000 char);
    detail5_codminsb	varchar2(4000 char);
    detail5_stayear	    varchar2(4000 char);

    --cursor
    cursor c_teducatn is
      select b.numseq,b.codedlv,b.codmajsb,b.codcount,b.numgpa,
             b.flgeduc,b.coddglv,b.codinst,b.codminsb,b.dtegyear,b.stayear
      from   temploy1 a,teducatn b
      where  b.numappl  = a.numappl
      and    a.codempid = b_index_codempid
      order by numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from temploy1 a,teducatn b
     where b.numappl  = a.numappl
       and a.codempid = b_index_codempid
    order by numseq;

    if v_rcnt > 0 then
      for r in c_teducatn loop
        v_count := v_count + 1;
        --
        detail5_numseq	 := r.numseq;
        detail5_codedlv  := get_tcodec_name('TCODEDUC',r.codedlv,global_v_lang);
        detail5_codmajsb := get_tcodec_name('TCODMAJR',r.codmajsb,global_v_lang);
        detail5_codcount := get_tcodec_name('TCODCNTY',r.codcount,global_v_lang);
        detail5_numgpa   := r.numgpa;
        detail5_flgeduc  := get_tlistval_name('FLGEDUC',r.flgeduc,global_v_lang);
        detail5_coddglv  := get_tcodec_name('TCODDGEE',r.coddglv,global_v_lang);
        detail5_codinst  := get_tcodec_name('TCODINST',r.codinst,global_v_lang);
        detail5_codminsb := get_tcodec_name('TCODSUBJ',r.codminsb,global_v_lang);
        --
        if (r.stayear is not null) and (r.dtegyear is not null) then
           detail5_stayear := to_char(r.stayear+v_additional)||' - '||to_char(r.dtegyear+v_additional);
        elsif r.stayear is null then
           detail5_stayear :=  ' - '||to_char(r.dtegyear+v_additional);
        elsif r.dtegyear is null then
           detail5_stayear :=  to_char(r.stayear+v_additional)||' - ';
        else
           detail5_stayear := null;
        end if;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail5_numseq));
        obj_data.put('codedlv',set_data(detail5_codedlv));
        obj_data.put('coddglv',set_data(detail5_coddglv));
        obj_data.put('codmajsb',set_data(detail5_codmajsb));
        obj_data.put('codinst',set_data(detail5_codinst));
        obj_data.put('codminsb',set_data(detail5_codminsb));
        obj_data.put('codcount',set_data(detail5_codcount));
        obj_data.put('numgpa',set_data(detail5_numgpa));
        obj_data.put('stayear',set_data(detail5_stayear));
        obj_data.put('flgeduc',set_data(detail5_flgeduc));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('codedlv',set_data(''));
      obj_data.put('coddglv',set_data(''));
      obj_data.put('codmajsb',set_data(''));
      obj_data.put('codinst',set_data(''));
      obj_data.put('codminsb',set_data(''));
      obj_data.put('codcount',set_data(''));
      obj_data.put('numgpa',set_data(''));
      obj_data.put('stayear',set_data(''));
      obj_data.put('flgeduc',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_experiences_data
  procedure hres31x_tab7_table(json_str_input in clob, json_str_output out clob) as
    obj_row    json_object_t;
    obj_data   json_object_t;
    v_count    number := 0;
    v_rcnt     number := 0;
    --Data
    detail6_numseq  		  varchar2(4000 char);
    detail6_desnoffi	      varchar2(4000 char);
    detail6_deslstjob1 	      varchar2(4000 char);
    detail6_deslstpos   	  varchar2(4000 char);
    detail6_dtestart   	      varchar2(4000 char);
    detail6_dteend  	      varchar2(4000 char);
    detail6_desres        	  varchar2(4000 char);
    detail6_wrk_location	  varchar2(4000 char);
    detail6_telnum			  varchar2(4000 char);
    detail6_leader			  varchar2(4000 char);
    detail6_salnow			  varchar2(4000 char);
    detail6_remark			  varchar2(4000 char);
    detail6_desjob			  varchar2(4000 char);
    detail6_desrisk			  varchar2(4000 char);
    detail6_desprotc		  varchar2(4000 char);

    --cursor
    cursor c_tapplwex is
      select b.numseq,b.desnoffi,b.deslstjob1,deslstpos,
             b.dtestart,b.dteend,b.desres,b.desoffi1,b.numteleo,
             b.namboss,stddec(b.amtincom,b.numappl,v_chken) amtincom,b.remark,
             b.desjob, b.desrisk, b.desprotc
      from   temploy1 a,tapplwex b
      where  b.numappl  = a.numappl
      and    a.codempid = b_index_codempid
      order by numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from   temploy1 a,tapplwex b
      where  b.numappl  = a.numappl
      and    a.codempid = b_index_codempid
      order by numseq;

    --
    if v_rcnt > 0 then
      for r in c_tapplwex loop
        v_count := v_count + 1;
          --
        detail6_numseq  	      := r.numseq;
        detail6_desnoffi  	    := r.desnoffi;
        detail6_deslstjob1      := r.deslstjob1;
        detail6_deslstpos       := r.deslstpos;
        detail6_dtestart        := hcm_util.get_date_buddhist_era(r.dtestart);
        detail6_dteend          := hcm_util.get_date_buddhist_era(r.dteend);
        detail6_desres          := r.desres;
        detail6_wrk_location	:= r.desoffi1;
        detail6_telnum			:= r.numteleo;
        detail6_leader			:= r.namboss;
        detail6_salnow			:= r.amtincom;
        detail6_remark			:= r.remark;
        detail6_desjob			:= r.desjob;
        detail6_desrisk			:= r.desrisk;
        detail6_desprotc		:= r.desprotc;
          --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail6_numseq));
        obj_data.put('desnoffi',set_data(detail6_desnoffi));
        obj_data.put('deslstjob1',set_data(detail6_deslstjob1));
        obj_data.put('deslstpos',set_data(detail6_deslstpos));
        obj_data.put('dtestart',set_data(detail6_dtestart));
        obj_data.put('dteend',set_data(detail6_dteend));
        obj_data.put('desres',set_data(detail6_desres));
        obj_data.put('wrk_location',set_data(detail6_wrk_location));
        obj_data.put('telnum',set_data(detail6_telnum));
        obj_data.put('leader',set_data(detail6_leader));
        obj_data.put('salnow',set_data(to_char(detail6_salnow,'fm999,999,999,990.00')));
        obj_data.put('remark',set_data(detail6_remark));
        obj_data.put('desjob',set_data(detail6_desjob));
        obj_data.put('desrisk',set_data(detail6_desrisk));
        obj_data.put('desprotc',set_data(detail6_desprotc));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('desnoffi',set_data(''));
      obj_data.put('deslstjob1',set_data(''));
      obj_data.put('deslstpos',set_data(''));
      obj_data.put('dtestart',set_data(''));
      obj_data.put('dteend',set_data(''));
      obj_data.put('desres',set_data(''));
      obj_data.put('wrk_location',set_data(''));
      obj_data.put('telnum',set_data(''));
      obj_data.put('leader',set_data(''));
      obj_data.put('salnow',set_data(''));
      obj_data.put('remark',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_parents_data
  procedure hres31x_tab8(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_codfnatn          varchar2(4 char);
    v_codfrelg          varchar2(4 char);
    v_codfoccu	        varchar2(4 char);
    v_codmnatn          varchar2(4 char);
    v_codmrelg          varchar2(4 char);
    v_codmoccu	        varchar2(4 char);
    v_codempfa	        varchar2(10 char);
    v_dtebdfa	        date;
    v_staliff	        varchar2(100 char);
    v_stalifm	        varchar2(100 char);
    v_filenamf	        varchar2(100 char);
    v_filenamm	        varchar2(100 char);
    v_codempmo	        varchar2(100 char);
    v_dtebdmo	        date;
    v_folder	        varchar2(100 char);
    --Data
    detail7_namfathr    varchar2(4000 char);
    detail7_codfrelg    varchar2(4000 char);
    detail7_codfoccu    varchar2(4000 char);
    detail7_numofidf    varchar2(4000 char);
    detail7_codfnatn    varchar2(4000 char);
    detail7_nammothr    varchar2(4000 char);
    detail7_codmrelg    varchar2(4000 char);
    detail7_codmoccu    varchar2(4000 char);
    detail7_numofidm    varchar2(4000 char);
    detail7_codmnatn    varchar2(4000 char);
    detail7_namcont     varchar2(4000 char);
    detail7_adrcont1    varchar2(4000 char);
    detail7_codpost     varchar2(4000 char);
    detail7_numfax      varchar2(4000 char);
    detail7_desrelat    varchar2(4000 char);
    detail7_numtele     varchar2(4000 char);
    detail7_email       varchar2(4000 char);
    detail7_dteupd      varchar2(4000 char);
    detail7_coduser     varchar2(4000 char);
    detail7_staliff     varchar2(4000 char);
    detail7_stalifm     varchar2(4000 char);
    path_filenamf       varchar2(4000 char);
    path_filenamm       varchar2(4000 char);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    begin
      select  decode(global_v_lang,'101',namfathe,'102',namfatht,'103',namfath3,'104',namfath4,'105',namfath5,namfathe) namfathe,
              codfnatn,codfrelg,codfoccu,
              decode(global_v_lang,'101',nammothe,'102',nammotht,'103',nammoth3,'104',nammoth4,'105',nammoth5,nammothe) nammothe,
              codmnatn,codmrelg,codmoccu,
              decode(global_v_lang,'101',namconte,'102',namcontt,'103',namcont3,'104',namcont4,'105',namcont5,namconte) namconte
              ,adrcont1,codpost,numfax,desrelat,numtele,email,to_char(dteupd,'dd/mm/yyyy'),
              coduser,numofidf,numofidm,codempfa,dtebdfa,staliff,stalifm,filenamf,filenamm,codempmo,dtebdmo
      into    detail7_namfathr,v_codfnatn,v_codfrelg,v_codfoccu,
              detail7_nammothr,v_codmnatn,v_codmrelg,v_codmoccu,
              detail7_namcont,detail7_adrcont1,detail7_codpost,detail7_numfax,
              detail7_desrelat,detail7_numtele,detail7_email,detail7_dteupd,detail7_coduser,detail7_numofidf,detail7_numofidm,
              v_codempfa,v_dtebdfa,v_staliff,v_stalifm,v_filenamf,v_filenamm,v_codempmo,v_dtebdmo
      from  	tfamily
      where   codempid = b_index_codempid
      and     rownum   = 1;
    exception when no_data_found then
      null;
    end;
    --
    v_folder          := get_tfolderd('HRPMC2E');
    detail7_codfrelg	:= get_tcodec_name('TCODRELI',v_codfrelg,global_v_lang);
    detail7_codfnatn	:= get_tcodec_name('TCODNATN',v_codfnatn,global_v_lang);
    detail7_codfoccu	:= get_tcodec_name('TCODOCCU',v_codfoccu,global_v_lang);
    detail7_codmrelg	:= get_tcodec_name('TCODRELI',v_codmrelg,global_v_lang);
    detail7_codmnatn	:= get_tcodec_name('TCODNATN',v_codmnatn,global_v_lang);
    detail7_codmoccu	:= get_tcodec_name('TCODOCCU',v_codmoccu,global_v_lang);

    if v_staliff = 'Y' then
      detail7_staliff     := get_label_name('HRPMC2E3P2',global_v_lang,130);
    elsif v_staliff = 'N' then
      detail7_staliff     := get_label_name('HRPMC2E3P2',global_v_lang,140);
    end if;
    if v_stalifm = 'Y' then
      detail7_stalifm     := get_label_name('HRPMC2E3P2',global_v_lang,130);
    elsif v_stalifm = 'N' then
      detail7_stalifm     := get_label_name('HRPMC2E3P2',global_v_lang,140);
    end if;

    path_filenamf         := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||v_folder||'/'||v_filenamf;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||v_folder||'/'||v_filenamf;
    path_filenamm         := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||v_folder||'/'||v_filenamm;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||v_folder||'/'||v_filenamm;
    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('namfathr',set_data(detail7_namfathr));
    obj_row.put('codfrelg',set_data(detail7_codfrelg));
    obj_row.put('codfoccu',set_data(detail7_codfoccu));
    obj_row.put('numofidf',set_data(detail7_numofidf));
    obj_row.put('codfnatn',set_data(detail7_codfnatn));
    obj_row.put('nammothr',set_data(detail7_nammothr));
    obj_row.put('codmrelg',set_data(detail7_codmrelg));
    obj_row.put('codmoccu',set_data(detail7_codmoccu));
    obj_row.put('numofidm',set_data(detail7_numofidm));
    obj_row.put('codmnatn',set_data(detail7_codmnatn));
    obj_row.put('namcont',set_data(detail7_namcont));
    obj_row.put('adrcont1',set_data(detail7_adrcont1));
    obj_row.put('codpost',set_data(detail7_codpost));
    obj_row.put('numfax',set_data(detail7_numfax));
    obj_row.put('desrelat',set_data(detail7_desrelat));
    obj_row.put('numtele',set_data(detail7_numtele));
    obj_row.put('email',set_data(detail7_email));
    obj_row.put('dteupd',set_data(detail7_dteupd));
    obj_row.put('coduser',set_data(detail7_coduser));

    obj_row.put('codempfa',set_data(v_codempfa));
    obj_row.put('dtebdfa',set_data(hcm_util.get_date_buddhist_era(v_dtebdfa)));
    obj_row.put('staliff',set_data(detail7_staliff));
    obj_row.put('stalifm',set_data(detail7_stalifm));
    obj_row.put('filenamf',set_data(v_filenamf));
    obj_row.put('filenamm',set_data(v_filenamm));
    obj_row.put('path_filenamf',set_data(path_filenamf));
    obj_row.put('path_filenamm',set_data(path_filenamm));
    obj_row.put('codempmo',set_data(v_codempmo));
    obj_row.put('dtebdmo',set_data(hcm_util.get_date_buddhist_era(v_dtebdmo)));

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure hres31x_tab8_table(json_str_input in clob, json_str_output out clob) as
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_flgdata          boolean := false;
    cursor c1 is
      select  decode(global_v_lang,'101',namrele,'102',namrelt,'103',namrel3,'104',namrel4,'105',namrel5,namrele) namrel,
              codemprl,numtelec,adrcomt
      from  	trelatives
      where   codempid = b_index_codempid
      order by numseq;

  begin

    obj_row := json_object_t();
    initial_value(json_str_input);

    for r1 in c1 loop
      v_rcnt := v_rcnt+1;
      v_flgdata := true;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', '');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('namrel', r1.namrel);
      obj_data.put('codemprl', r1.codemprl);
      obj_data.put('numtelec', r1.numtelec);
      obj_data.put('adrcomt', r1.adrcomt);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    if not v_flgdata then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', '');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('namrel', '');
      obj_data.put('codemprl', '');
      obj_data.put('numtelec', '');
      obj_data.put('adrcomt', '');
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_spouse_data
  procedure hres31x_tab9(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    v_codfnatn          varchar2(4 char);
    v_codfrelg          varchar2(4 char);
    v_codfoccu	        varchar2(4 char);
    v_codmnatn          varchar2(4 char);
    v_codmrelg          varchar2(4 char);
    v_codmoccu	        varchar2(4 char);
    v_codempidsp	    varchar2(10 char);
    v_stalife	        varchar2(1 char);
    v_staincom	        varchar2(1 char);
    v_folder	        varchar2(100 char);
    v_folder_img        varchar2(100 char);
    --Data
    detail8_namspous    varchar2(4000 char);
    detail8_numoffid    varchar2(4000 char);
    detail8_dtespbd     varchar2(4000 char);
    detail8_codspocc    varchar2(4000 char);
    detail8_desnoffi    varchar2(4000 char);
    detail8_dtemarry    varchar2(4000 char);
    detail8_codsppro    varchar2(4000 char);
    detail8_codspcty    varchar2(4000 char);
    detail8_desplreg    varchar2(4000 char);
    detail8_desnote     varchar2(4000 char);
    detail8_idf         varchar2(4000 char);
    detail8_idm         varchar2(4000 char);
    detail8_dteupd      varchar2(4000 char);
    detail8_coduser     varchar2(4000 char);
    v_codspocc          varchar2(4000 char);
    v_codsppro          varchar2(4000 char);
    v_codspcty          varchar2(4000 char);
    detail8_stalife     varchar2(100 char);
    detail8_staincom    varchar2(100 char);
    detail8_namimgsp    varchar2(100 char);
    detail8_filename    varchar2(500 char); 
    path_filename       varchar2(1000 char);
    path_namimgsp       varchar2(1000 char);
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
     begin
      select  numoffid,codspocc,to_char(dtespbd,'dd/mm/yyyy'),desnoffi,
              to_char(dtemarry,'dd/mm/yyyy'),codsppro,codspcty,desplreg,desnote,to_char(dteupd,'dd/mm/yyyy'),coduser,numfasp,nummosp,
              codempidsp, stalife, staincom, namimgsp, filename,
              decode(global_v_lang,'101',namspe,'102',namspt,'103',namsp3,'104',namsp4,'105',namsp5,namspe) namspe
      into    detail8_numoffid,v_codspocc,detail8_dtespbd,detail8_desnoffi,
              detail8_dtemarry,v_codsppro,v_codspcty,detail8_desplreg,detail8_desnote,
              detail8_dteupd,detail8_coduser,detail8_idf,detail8_idm,
              v_codempidsp, v_stalife, v_staincom, detail8_namimgsp, detail8_filename,
              detail8_namspous
      from 		tspouse
      where   codempid = b_index_codempid
      and     rownum   = 1;
    exception when no_data_found then
      null;
    end;
    --
    v_folder            := get_tfolderd('HRPMC2E3');
    v_folder_img        := get_tfolderd('HRPMC2E1');
    detail8_codspocc	:= get_tcodec_name('TCODOCCU',v_codspocc,global_v_lang);
    detail8_codsppro	:= get_tcodec_name('TCODPROV',v_codsppro,global_v_lang);
    detail8_codspcty	:= get_tcodec_name('TCODCNTY',v_codspcty,global_v_lang);
    if v_stalife = 'Y' then
      detail8_stalife     := get_label_name('HRPMC2E3P2',global_v_lang,130);
    elsif v_stalife = 'N' then
      detail8_stalife     := get_label_name('HRPMC2E3P2',global_v_lang,140);
    end if;
    if v_staincom = 'Y' then
      detail8_staincom     := get_label_name('HRPMC2E3P2',global_v_lang,160);
    elsif v_staincom = 'N' then
      detail8_staincom     := get_label_name('HRPMC2E3P2',global_v_lang,170);
    end if;
    path_filename          := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||v_folder||'/'||detail8_filename;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||v_folder||'/'||detail8_filename;
    path_namimgsp          := get_tsetup_value('PATHDOC')||v_folder_img||'/'||detail8_namimgsp;

    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('namspous',set_data(detail8_namspous));
    obj_row.put('numoffid',set_data(detail8_numoffid));
    obj_row.put('codspocc',set_data(detail8_codspocc));
    obj_row.put('dtespbd',set_data(detail8_dtespbd));
    obj_row.put('desnoffi',set_data(detail8_desnoffi));
    obj_row.put('dtemarry',set_data(detail8_dtemarry));
    obj_row.put('codsppro',set_data(detail8_codsppro));
    obj_row.put('codspcty',set_data(detail8_codspcty));
    obj_row.put('desplreg',set_data(detail8_desplreg));
    obj_row.put('desnote',set_data(detail8_desnote));
    obj_row.put('idf',set_data(detail8_idf));
    obj_row.put('idm',set_data(detail8_idm));
    obj_row.put('dteupd',set_data(detail8_dteupd));
    obj_row.put('coduser',set_data(detail8_coduser));
    obj_row.put('codempidsp',set_data(v_codempidsp));
    obj_row.put('stalife',set_data(detail8_stalife));
    obj_row.put('staincom',set_data(detail8_staincom));
    obj_row.put('namimgsp',set_data(detail8_namimgsp));
    obj_row.put('filename',set_data(detail8_filename));
    obj_row.put('path_filename',set_data(path_filename));
    obj_row.put('path_namimgsp',set_data(path_namimgsp));
    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_children_data
  procedure hres31x_tab10_table(json_str_input in clob, json_str_output out clob) as
    obj_row    json_object_t;
    obj_data   json_object_t;
    v_count number := 0;
    v_rcnt  number := 0;
    --Data
    detail9_numseq        varchar2(4000 char);
    detail9_namchild      varchar2(4000 char);
    detail9_dtechbd       varchar2(4000 char);
    detail9_codsex        varchar2(4000 char);
    detail9_codedlv       varchar2(4000 char);
    detail9_numoffid      varchar2(4000 char);
    detail9_desflgedlv    varchar2(4000 char);
    detail9_desflgded     varchar2(4000 char);
    detail9_stachld       varchar2(4000 char);
    detail9_stalife       varchar2(4000 char);
    detail9_flginc        varchar2(100 char);
    detail9_filename      varchar2(100 char);
    path_filename         varchar2(100 char);
    --cursor
    cursor c_tchildrn is
      select all numseq,
                decode(global_v_lang,'101',namche,'102',namcht,'103',namch3,'104',namch4,'105',namch5,namche) namche,
                dtechbd,codsex,codedlv,stachld,stalife,flginc,filename,
                 numoffid,flgedlv,flgdeduct
      from 			 tchildrn
      where 		 codempid = b_index_codempid
      order by numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from tchildrn
     where codempid = b_index_codempid
    order by numseq;
    --
    if v_rcnt >0 then
      for r in c_tchildrn loop
        detail9_numseq  	  := r.numseq;
        detail9_namchild  	  := r.namche;
        detail9_numoffid 	  := r.numoffid;
        detail9_dtechbd  	  := hcm_util.get_date_buddhist_era(r.dtechbd);
        detail9_codsex 		  := get_tlistval_name('NAMSEX',r.codsex,global_v_lang);
        detail9_desflgedlv	  := get_tlistval_name('FLGEDU',r.flgedlv,global_v_lang);
        detail9_desflgded	  := get_tlistval_name('FLGLOW',r.flgdeduct,global_v_lang);
        detail9_codedlv       := get_tcodec_name('TCODEDUC',r.codedlv,global_v_lang);
        if r.stachld = 'Y' then
          detail9_stachld     := get_label_name('HRPMC2E3P2',global_v_lang,100);
        elsif r.stachld = 'N' then
          detail9_stachld     := get_label_name('HRPMC2E3P2',global_v_lang,110);
        end if;
        if r.stalife = 'Y' then
          detail9_stalife     := get_label_name('HRPMC2E3P2',global_v_lang,130);
        elsif r.stalife = 'N' then
          detail9_stalife     := get_label_name('HRPMC2E3P2',global_v_lang,140);
        end if;
        if r.flginc = 'Y' then
          detail9_flginc     := get_label_name('HRPMC2E3P2',global_v_lang,160);
        elsif r.flginc = 'N' then
          detail9_flginc     := get_label_name('HRPMC2E3P2',global_v_lang,170);
        end if;
        detail9_filename     := r.filename;
        path_filename        := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail9_filename;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail9_filename;
        --
        v_count := v_count +1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail9_numseq));
        obj_data.put('namchild',set_data(detail9_namchild));
        obj_data.put('numoffid',set_data(detail9_numoffid));
        obj_data.put('dtechbd',set_data(detail9_dtechbd));
        obj_data.put('codsex',set_data(detail9_codsex));
        obj_data.put('desflgedlv',set_data(detail9_desflgedlv));
        obj_data.put('desflgded',set_data(detail9_desflgded));
        obj_data.put('codedlv',set_data(detail9_codedlv));
        obj_data.put('stachld',set_data(detail9_stachld));
        obj_data.put('stalife',set_data(detail9_stalife));
        obj_data.put('flginc',set_data(detail9_flginc));
        obj_data.put('filename',set_data(detail9_filename));
        obj_data.put('path_filename',set_data(path_filename));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count +1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('namchild',set_data(''));
      obj_data.put('numoffid',set_data(''));
      obj_data.put('dtechbd',set_data(''));
      obj_data.put('codsex',set_data(''));
      obj_data.put('desflgedlv',set_data(''));
      obj_data.put('desflgded',set_data(''));
      obj_data.put('codedlv',set_data(''));
      obj_data.put('stachld',set_data(''));
      obj_data.put('stalife',set_data(''));
      obj_data.put('flginc',set_data(''));
      obj_data.put('filename',set_data(''));
      obj_data.put('path_filename',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_guarantee1_data
  procedure hres31x_tab11_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    v_codempgrt           varchar2(10 char);
    v_codpost             number;
    v_numtele             varchar2(20 char);
    v_numfax              varchar2(20 char);
    v_email               varchar2(30 char);
    v_codident            varchar2(1 char);
    v_numoffid            varchar2(20 char);
    v_despos              varchar2(35 char);
    v_adroffi             varchar2(100 char);
    v_codposto            number;
    --Data
    detail10_numseq       varchar2(4000 char);
    detail10_namguar      varchar2(4000 char);
    detail10_desrelat     varchar2(4000 char);
    detail10_desoccup     varchar2(4000 char);
    detail10_dtegucon     varchar2(4000 char);
    detail10_dteguexp     varchar2(4000 char);
    detail10_dteguabd     varchar2(4000 char);
    detail10_dteguret     varchar2(4000 char);
    detail10_adrcont      varchar2(4000 char);
    detail10_codident     varchar2(4000 char);
    detail10_dteidexp     varchar2(4000 char);
    detail10_desnote      varchar2(4000 char);
    detail10_amtmthin     varchar2(4000 char);

    --cursor
    cursor c_tguarntr is
      select numseq,namguare,namguart,namguar3,namguar4,namguar5,
             desrelat ,codoccup,dtegucon,dteguexp,codempgrt,dteguabd,dteguret,adrcont,
             codpost,numtele,numfax,email,codident,numoffid,dteidexp,desnote,despos,
             amtmthin,adroffi,codposto
      from  tguarntr
      where codempid = b_index_codempid
      order by numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from tguarntr
     where codempid = b_index_codempid
    order by numseq;
    --
    if v_rcnt > 0 then
      for i in c_tguarntr loop
        --
        detail10_numseq			:= i.numseq;
        if global_v_lang = '101' then
          detail10_namguar	:= i.namguare;
        elsif global_v_lang = '102' then
          detail10_namguar	:= i.namguart;
        elsif global_v_lang = '103' then
          detail10_namguar	:= i.namguar3;
        elsif global_v_lang = '104' then
          detail10_namguar	:= i.namguar4;
        elsif global_v_lang = '105' then
          detail10_namguar	:= i.namguar5;
        end if;
        detail10_desrelat   := i.desrelat;
        detail10_desoccup   := get_tcodec_name('TCODOCCU',i.codoccup,global_v_lang);
        detail10_dtegucon   := hcm_util.get_date_buddhist_era(i.dtegucon);
        detail10_dteguexp   := hcm_util.get_date_buddhist_era(i.dteguexp);
        detail10_dteguexp   := hcm_util.get_date_buddhist_era(i.dteguexp);
        v_codempgrt         := i.codempgrt;
        detail10_dteguabd   := hcm_util.get_date_buddhist_era(i.dteguabd);
        detail10_dteguret   := hcm_util.get_date_buddhist_era(i.dteguret);
        detail10_adrcont    := i.adrcont;
        v_codpost           := i.codpost;
        v_numtele           := i.numtele;
        v_numfax            := i.numfax;
        v_email             := i.email;
        detail10_codident   := get_tlistval_name('CODIDENT',i.codident,global_v_lang);
        v_numoffid          := i.numoffid;
        detail10_dteidexp   := hcm_util.get_date_buddhist_era(i.dteidexp);
        detail10_desnote    := i.desnote;
        v_despos            := i.despos;
        detail10_amtmthin   := stddec(i.amtmthin,b_index_codempid,v_chken);
        v_adroffi           := i.adroffi;
        v_codposto          := i.codposto;

        --
        v_count := v_count +1;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail10_numseq));
        obj_data.put('namguar',set_data(detail10_namguar));
        obj_data.put('dtegucon',set_data(detail10_dtegucon));
        obj_data.put('dteguexp',set_data(detail10_dteguexp));
        obj_data.put('desrelat',set_data(detail10_desrelat));
        obj_data.put('desoccup',set_data(detail10_desoccup));
        obj_data.put('codempgrt',set_data(v_codempgrt));
        obj_data.put('dteguabd',set_data(detail10_dteguabd));
        obj_data.put('dteguret',set_data(detail10_dteguret));
        obj_data.put('adrcont',set_data(detail10_adrcont));
        obj_data.put('codpost',set_data(v_codpost));
        obj_data.put('numtele',set_data(v_numtele));
        obj_data.put('numfax',set_data(v_numfax));
        obj_data.put('email',set_data(v_email));
        obj_data.put('codident',set_data(detail10_codident));
        obj_data.put('numoffid',set_data(v_numoffid));
        obj_data.put('dteidexp',set_data(detail10_dteidexp));
        obj_data.put('desnote',set_data(detail10_desnote));
        obj_data.put('despos',set_data(v_despos));
        obj_data.put('amtmthin',set_data(to_char(detail10_amtmthin,'fm999,999,990.00')));
        obj_data.put('adroffi',set_data(v_adroffi));
        obj_data.put('codposto',set_data(v_codposto));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count +1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('namguar',set_data(''));
      obj_data.put('dtegucon',set_data(''));
      obj_data.put('dteguexp',set_data(''));
      obj_data.put('desrelat',set_data(''));
      obj_data.put('desoccup',set_data(''));
      obj_data.put('codempgrt',set_data(''));
      obj_data.put('dteguabd',set_data(''));
      obj_data.put('dteguret',set_data(''));
      obj_data.put('adrcont',set_data(''));
      obj_data.put('codpost',set_data(''));
      obj_data.put('numtele',set_data(''));
      obj_data.put('numfax',set_data(''));
      obj_data.put('email',set_data(''));
      obj_data.put('codident',set_data(''));
      obj_data.put('numoffid',set_data(''));
      obj_data.put('dteidexp',set_data(''));
      obj_data.put('desnote',set_data(''));
      obj_data.put('despos',set_data(''));
      obj_data.put('amtmthin',set_data(''));
      obj_data.put('adroffi',set_data(''));
      obj_data.put('codposto',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_guarantee2_data
  procedure hres31x_tab12_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    v_status              varchar2(1 char);
    v_filename            varchar2(60 char);
    v_qtyperiod           number;
    v_flgded              varchar2(1 char);
    v_folder              varchar2(100 char);
    --Data
    detail11_numcolla     varchar2(4000 char);
    detail11_numdocum     varchar2(4000 char);
    detail11_descolla 	  varchar2(4000 char);
    detail11_amtcolla	  varchar2(4000 char);
    detail11_descoll	  varchar2(4000 char);
    detail11_dtecolla	  varchar2(4000 char);
    detail11_dteeffec	  varchar2(4000 char);
    detail11_dtertdoc	  varchar2(4000 char);
    detail11_status		  varchar2(4000 char);
    path_filename         varchar2(4000 char);
    detail11_flgded		  varchar2(4000 char);
    detail11_dtestrt	  varchar2(4000 char);
    detail11_dteend		  varchar2(4000 char);
    detail11_amtded		  varchar2(4000 char);
    detail11_amtdedcol	  varchar2(4000 char);
    --cursor
    cursor c_tcolltrl is
      select codempid,numcolla,numdocum,typcolla,amtcolla,descoll,dtecolla,dteeffec,dtertdoc,
             status,dteupd,coduser,filename,amtdedcol,qtyperiod,flgded,dtestrt,dteend,amtded
      from  tcolltrl
      where codempid = b_index_codempid
      order by numcolla;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
    into v_rcnt
    from  tcolltrl
    where codempid = b_index_codempid
    order by numcolla;
    --
    if v_rcnt > 0 then
      for i in c_tcolltrl loop
        --
        v_count := v_count + 1;
        --
        v_folder            := get_tfolderd('HRPMC2E');
        detail11_numcolla		:= i.numcolla;
        detail11_numdocum		:= i.numdocum;
        detail11_descolla 	:= get_tcodec_name('TCODCOLA',i.typcolla,global_v_lang);
        detail11_amtcolla		:= to_char(stddec(i.amtcolla,i.codempid,v_chken),'fm999,999,990.00');
        detail11_descoll		:= i.descoll;
        detail11_dtecolla   := hcm_util.get_date_buddhist_era(i.dtecolla);
        detail11_dteeffec   := hcm_util.get_date_buddhist_era(i.dteeffec);
        detail11_dtertdoc   := hcm_util.get_date_buddhist_era(i.dtertdoc);
        if i.status = 'A' then
          detail11_status   := get_label_name('HRPMC2E4P2',global_v_lang,130);
        elsif i.status = 'C' then
          detail11_status   := get_label_name('HRPMC2E4P2',global_v_lang,140);
        end if;
        v_filename		      := i.filename;
        path_filename       := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||v_folder||'/'||v_filename;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||v_folder||'/'||v_filename;
        detail11_amtdedcol	:= to_char(stddec(i.amtdedcol,i.codempid,v_chken),'fm999,999,990.00');
        v_qtyperiod		      := i.qtyperiod;
        if i.flgded = 'Y' then
          detail11_flgded   := get_label_name('HRPMC2E4P2',global_v_lang,200);
        elsif i.flgded = 'N' then
          detail11_flgded   := get_label_name('HRPMC2E4P2',global_v_lang,210);
        end if;
        detail11_dtestrt    := hcm_util.get_date_buddhist_era(i.dtestrt);
        detail11_dteend     := hcm_util.get_date_buddhist_era(i.dteend);
        detail11_amtded		  := to_char(stddec(i.amtded,i.codempid,v_chken),'fm999,999,990.00');

        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numcolla',set_data(detail11_numcolla));
        obj_data.put('descolla',set_data(detail11_descolla));
        obj_data.put('amtcolla',set_data(detail11_amtcolla));
        obj_data.put('numdocum',set_data(detail11_numdocum));
        obj_data.put('descoll',set_data(detail11_descoll));
        obj_data.put('dtecolla',set_data(detail11_dtecolla));
        obj_data.put('dteeffec',set_data(detail11_dteeffec));
        obj_data.put('dtertdoc',set_data(detail11_dtertdoc));
        obj_data.put('status',set_data(detail11_status));
        obj_data.put('filename',set_data(v_filename));
        obj_data.put('path_filename',set_data(path_filename));
        obj_data.put('amtdedcol',set_data(detail11_amtdedcol));
        obj_data.put('qtyperiod',set_data(v_qtyperiod));
        obj_data.put('flgded',set_data(detail11_flgded));
        obj_data.put('dtestrt',set_data(detail11_dtestrt));
        obj_data.put('dteend',set_data(detail11_dteend));
        obj_data.put('amtded',set_data(detail11_amtded));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_rcnt));
      obj_data.put('rcnt',to_char(v_rcnt));
      obj_data.put('numcolla',set_data(''));
      obj_data.put('descolla',set_data(''));
      obj_data.put('amtcolla',set_data(''));
      obj_data.put('numdocum',set_data(''));
      obj_data.put('descoll',set_data(''));
      obj_data.put('dtecolla',set_data(''));
      obj_data.put('dteeffec',set_data(''));
      obj_data.put('dtertdoc',set_data(''));
      obj_data.put('status',set_data(''));
      obj_data.put('filename',set_data(''));
      obj_data.put('path_filename',set_data(''));
      obj_data.put('amtdedcol',set_data(''));
      obj_data.put('qtyperiod',set_data(''));
      obj_data.put('flgded',set_data(''));
      obj_data.put('dtestrt',set_data(''));
      obj_data.put('dteend',set_data(''));
      obj_data.put('amtded',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_competency_data (get typtency)
  procedure hres31x_tab13_table_type(json_str_input in clob, json_str_output out clob) as
    obj_typtency_data       json_object_t;
    obj_typtency_row        json_object_t;
    count_typtency          number := 0;
    json_str_output_index   clob;
    v_typtency	            varchar2(20) := '!@#$';
    --Data
    detail12_typtency       varchar2(4000 char);
    detail12_desc_typtency  varchar2(4000 char);

    cursor c_tcmptncy is
      select b.codtency typtency,a.codtency,a.grade,a.dteupd,a.coduser
      from	 tcmptncy a, tjobposskil b
      where	 b.codpos 	= detail_codpos
      and 	 b.codskill	= a.codtency
      and 	 b.codcomp 	= detail_codcomp
      and		 a.numappl 	= detail_numappl
      order by b.codtency,a.codtency;

    cursor c_tcmptncy_not is
      select c.codtency typtency,a.codtency,a.grade,a.dteupd,a.coduser
      from	 tcmptncy a, tcompskil b, tcomptnc c
      where	 not exists(select tjobpos.codtency
                        from 	 tjobposskil tjobpos
                        where  tjobpos.codpos = detail_codpos
                        and 	 tjobpos.codskill = a.codtency
                        and 	 tjobpos.codcomp = detail_codcomp)
      and		 a.numappl 		 = detail_numappl
      and		 b.codskill (+)= a.codtency
      and		 c.codtency (+)= b.codtency
      order by c.codtency,a.codtency;
  begin
    obj_typtency_row := json_object_t();
    initial_value(json_str_input);
    -- call for get detail_codcomp, detail_numappl, detail_numappl
    hres31x_tab1(json_str_input, json_str_output_index);

    for r in c_tcmptncy loop
      if v_typtency <> r.typtency then
        v_typtency 						  := r.typtency;
        detail12_typtency 		  := r.typtency;
        --
        if detail12_typtency is null then
          detail12_desc_typtency := null;
        elsif detail12_typtency = 'N/A' then
          detail12_desc_typtency := detail12_typtency;
        else
          detail12_desc_typtency := get_tcomptnc_name(detail12_typtency,global_v_lang);
        end if;
        count_typtency := count_typtency + 1;
        obj_typtency_data := json_object_t();
        obj_typtency_data.put('flg', '');
        obj_typtency_data.put('coderror', '200');
        obj_typtency_data.put('desc_coderror', ' ');
        obj_typtency_data.put('httpcode', '');
        obj_typtency_data.put('typtency', set_data(detail12_typtency));
        obj_typtency_data.put('desc_typtency', set_data(detail12_desc_typtency));
        obj_typtency_row.put(to_char(count_typtency-1),obj_typtency_data);
      end if;
    end loop;

    for i in c_tcmptncy_not loop
      if v_typtency <> nvl(i.typtency,'N/A') then
        v_typtency 						  := nvl(i.typtency,'N/A');
        detail12_typtency 		  := nvl(i.typtency,'N/A');
        --
        if detail12_typtency is null then
           detail12_desc_typtency := null;
        elsif detail12_typtency = 'N/A' then
           detail12_desc_typtency := detail12_typtency;
        else
           detail12_desc_typtency := get_tcomptnc_name(detail12_typtency,global_v_lang);
        end if;
        count_typtency := count_typtency + 1;
        obj_typtency_data := json_object_t();
        obj_typtency_data.put('flg', '');
        obj_typtency_data.put('coderror', '200');
        obj_typtency_data.put('desc_coderror', ' ');
        obj_typtency_data.put('httpcode', '');
        obj_typtency_data.put('typtency', set_data(detail12_typtency));
        obj_typtency_data.put('desc_typtency', set_data(detail12_desc_typtency));
        obj_typtency_row.put(to_char(count_typtency-1),obj_typtency_data);
      end if;
    end loop;

    if count_typtency = 0 then
      count_typtency := count_typtency + 1;
      obj_typtency_data := json_object_t();
      obj_typtency_data.put('flg', '');
      obj_typtency_data.put('coderror', '200');
      obj_typtency_data.put('desc_coderror', ' ');
      obj_typtency_data.put('httpcode', '');
      obj_typtency_data.put('typtency', set_data(''));
      obj_typtency_data.put('desc_typtency', set_data(''));
      obj_typtency_row.put('0',obj_typtency_data);
    end if;

    json_str_output := obj_typtency_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_competency_data
  procedure hres31x_tab13_table(json_str_input in clob, json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    json_str_output_index   clob;
    v_count                 number := 0;
    v_rcnt                  number := 0;
    v_typtency	            varchar2(20) := '!@#$';
    --Data
    detail12_typtency       varchar2(4000 char);
    detail12_desc_typtency  varchar2(4000 char);
    detail12_codtency       varchar2(4000 char);
    detail12_desc_codtency  varchar2(4000 char);
    detail12_grade          varchar2(4000 char);
    detail12_fscore         varchar2(4000 char);

    cursor c_tcmptncy is
      select b.codtency typtency,a.codtency,a.grade,a.dteupd,a.coduser
      from	 tcmptncy a, tjobposskil b
      where	 b.codpos 	= detail_codpos
      and 	 b.codskill	= a.codtency
      and 	 b.codcomp 	= detail_codcomp
      and		 a.numappl 	= detail_numappl
      order by b.codtency,a.codtency;

    cursor c_tcmptncy_not is
      select c.codtency typtency,a.codtency,a.grade,a.dteupd,a.coduser
      from	 tcmptncy a, tcompskil b, tcomptnc c
      where	 not exists(select tjobpos.codtency
                        from 	 tjobposskil tjobpos
                        where  tjobpos.codpos = detail_codpos
                        and 	 tjobpos.codskill = a.codtency
                        and 	 tjobpos.codcomp = detail_codcomp)
      and		 a.numappl 		 = detail_numappl
      and		 b.codskill (+)= a.codtency
      and		 c.codtency (+)= b.codtency
      order by c.codtency,a.codtency;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    -- call for get detail_codcomp, detail_numappl, detail_numappl
    hres31x_tab1(json_str_input, json_str_output_index);

    for r in c_tcmptncy loop
      v_count := v_count + 1;
      if v_typtency <> r.typtency then
        v_typtency 						  := r.typtency;
        detail12_typtency 		  := r.typtency;
      end if;
      detail12_codtency 			:= r.codtency;
      detail12_desc_codtency  := get_tcodec_name('TCODSKIL',r.codtency,global_v_lang);
      detail12_grade 				  := r.grade;

      -- get fscore
      if detail12_typtency is null then
        detail12_desc_typtency := null;
      elsif detail12_typtency = 'N/A' then
        detail12_desc_typtency := detail12_typtency;
      else
        detail12_desc_typtency := get_tcomptnc_name(detail12_typtency,global_v_lang);
      end if;

      begin
        select max(grade)
          into detail12_fscore
          from tskilscor
         where codskill = detail12_codtency;
      exception when no_data_found then
        null;
      end;
      --
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('flgrow','');
      obj_data.put('typtency',set_data(detail12_typtency));
      obj_data.put('desc_typtency',set_data(detail12_desc_typtency));
      obj_data.put('codtency',set_data(detail12_codtency));
      obj_data.put('desc_codtency',set_data(detail12_desc_codtency));
      obj_data.put('grad',set_data(detail12_grade));
      obj_data.put('fscore',set_data(detail12_fscore));
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;

    for i in c_tcmptncy_not loop
      v_count := v_count + 1;
      if v_typtency <> nvl(i.typtency,'N/A') then
        v_typtency 						  := nvl(i.typtency,'N/A');
        detail12_typtency 		  := nvl(i.typtency,'N/A');
      end if;
      detail12_codtency 			:= i.codtency;
      detail12_desc_codtency  := get_tcodec_name('TCODSKIL',i.codtency,global_v_lang);
      detail12_grade    			:= i.grade;

      if detail12_typtency is null then
         detail12_desc_typtency := null;
      elsif detail12_typtency = 'N/A' then
         detail12_desc_typtency := detail12_typtency;
      else
         detail12_desc_typtency := get_tcomptnc_name(detail12_typtency,global_v_lang);
      end if;

      begin
        select max(grade)
          into detail12_fscore
          from tskilscor
         where codskill = detail12_codtency;
      exception when no_data_found then
        null;
      end;
      --
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('flgrow','gray');
      obj_data.put('typtency',set_data(detail12_typtency));
      obj_data.put('desc_typtency',set_data(detail12_desc_typtency));
      obj_data.put('codtency',set_data(detail12_codtency));
      obj_data.put('desc_codtency',set_data(detail12_desc_codtency));
      obj_data.put('grad',set_data(detail12_grade));
      obj_data.put('fscore',set_data(detail12_fscore));
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;

    -- set total
--    if v_count > 0 then
--      json_ext.put(obj_row, '0.total', to_char(v_count));
--    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_langauge_data
  procedure hres31x_tab13_table_lang(json_str_input in clob, json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    json_str_output_index   clob;
    v_count                 number := 0;
    v_rcnt                  number := 0;
    v_codlang	            varchar2(20) := '!@#$';
    --Data
    v_desc_codlang          varchar2(100 char);
    v_flglist               varchar2(100 char);
    v_flgspeak              varchar2(100 char);
    v_flgread               varchar2(100 char);
    v_flgwrite              varchar2(100 char);

    cursor c1 is
      select codlang,flgwrite,flgspeak,flgread,flglist
      from	 tlangabi
      where	 numappl 	= detail_numappl
      order by dteupd;

  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    -- call for get detail_codcomp, detail_numappl, detail_numappl
    hres31x_tab1(json_str_input, json_str_output_index);

    for r1 in c1 loop
      v_count := v_count + 1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
      obj_data.put('codlang',set_data(r1.codlang));
      obj_data.put('desc_codlang',set_data(r1.codlang));
      obj_data.put('flglist',set_data(r1.flglist));
      obj_data.put('flgspeak',set_data(r1.flgspeak));
      obj_data.put('flgread',set_data(r1.flgread));
      obj_data.put('flgwrite',set_data(r1.flgwrite));
      obj_row.put(to_char(v_count-1),obj_data);
    end loop;


    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure hres31x_tab13_popup(json_str_input in clob, json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_count                 number := 0;
    v_rcnt                  number := 0;

    cursor c1 is
      select grade
        from tskilscor
        where codskill = v_codtency
      order by grade desc;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
    into v_rcnt
    from tskilscor
    where codskill = v_codtency;

    if v_rcnt > 0 then
      for i in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('grade',set_data(i.grade));
        obj_data.put('desc_grade',set_data(get_tskilscor_name(v_codtency,i.grade,global_v_lang)));
        obj_data.put('grade',set_data(to_char(i.grade,'fm990.00')));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_training_data
  procedure hres31x_tab14_table(json_str_input in clob, json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_count                 number := 0;
    v_rcnt                  number := 0;
    --Data
    detail18_numseq         varchar2(4000 char);
    detail18_destrain       varchar2(4000 char);
    detail18_dtetrain	    varchar2(4000 char);
    detail18_dtetren	    varchar2(4000 char);
    detail18_desplace       varchar2(4000 char);
    detail18_desinstu       varchar2(4000 char);
    detail18_filedoc        varchar2(60 char);
    path_filedoc            varchar2(400 char);

    --cursor
    cursor c1 is
     select numappl,numseq,codempid,destrain,dtetrain,dtetren,desplace,desinstu,
            dteupd,coduser,filedoc
       from ttrainbf
      where codempid = b_index_codempid
      order by numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
    into v_rcnt
    from ttrainbf
    where codempid = b_index_codempid
    order by numseq;



    if v_rcnt > 0 then
      for i in c1 loop
        v_count := v_count + 1;
        --
        detail18_numseq    := i.numseq;
        detail18_destrain  := i.destrain;
        detail18_dtetrain		 := hcm_util.get_date_buddhist_era(i.dtetrain);
        detail18_dtetren		 := hcm_util.get_date_buddhist_era(i.dtetren);
        detail18_desplace  := i.desplace;
        detail18_desinstu  := i.desinstu;
        detail18_filedoc   := i.filedoc;
        path_filedoc := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail18_filedoc;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail18_filedoc;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail18_numseq));
        obj_data.put('destrain',set_data(detail18_destrain));
        obj_data.put('dtetrain',set_data(detail18_dtetrain));
        obj_data.put('dtetren',set_data(detail18_dtetren));
        obj_data.put('desplace',set_data(detail18_desplace));
        obj_data.put('desinstu',set_data(detail18_desinstu));
        obj_data.put('filedoc',set_data(detail18_filedoc));
        obj_data.put('path_filedoc',set_data(path_filedoc));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('destrain',set_data(''));
      obj_data.put('dtetrain',set_data(''));
      obj_data.put('dtetren',set_data(''));
      obj_data.put('desplace',set_data(''));
      obj_data.put('desinstu',set_data(''));
      obj_data.put('filedoc',set_data(''));
      obj_data.put('path_filedoc',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --get_internal_training_data
  procedure hres31x_tab14_table_internal(json_str_input in clob, json_str_output out clob) as
    obj_row                 json_object_t;
    obj_data                json_object_t;
    v_count                 number := 0;
    v_rcnt                  number := 0;
    v_codcours              varchar2(10 char);
    v_desc_codcours         varchar2(400 char);
    v_dtetrst               date;
    v_dtetren               date;
    v_amtcost               number := 0;
    v_qtytrmin              number := 0;


    --cursor
    cursor c1 is
     select codcours,dtetrst,dtetren,amtcost,qtytrmin
       from thistrnn
      where codempid = b_index_codempid
      order by dtetrst;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);

     for r1 in c1 loop
        v_count := v_count + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('desc_codcours',set_data(get_tcourse_name(r1.codcours,global_v_lang)));
        obj_data.put('dtetrst',set_data(hcm_util.get_date_buddhist_era(r1.dtetrst)));
        obj_data.put('dtetren',set_data(hcm_util.get_date_buddhist_era(r1.dtetren)));
        obj_data.put('amtcost',set_data(to_char(r1.amtcost,'fm999,999,990.00')));
        obj_data.put('qtytrmin',set_data(r1.qtytrmin));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;


    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

--  get_honors_data
  procedure hres31x_tab15_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    --Data
    detail14_dteinput     varchar2(4000 char);
    detail14_typrewd      varchar2(4000 char);
    detail14_desrewd1     varchar2(4000 char);
    detail14_numhmref     varchar2(4000 char);
    detail14_filename     varchar2(60 char);
    path_filename         varchar2(400 char);
    --cursor
    cursor c_thisrewd is
      select dteinput,typrewd,desrewd1,numhmref,filename
      from   thisrewd
      where  codempid = b_index_codempid
      order by dteinput desc;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from   thisrewd
      where  codempid = b_index_codempid
      order by dteinput desc;

    --
    if v_rcnt > 0 then
      for r in c_thisrewd loop
        v_count := v_count + 1;
        --
        detail14_dteinput   := hcm_util.get_date_buddhist_era(r.dteinput);
        detail14_typrewd	  := get_tcodec_name('TCODREWD',r.typrewd,global_v_lang);
        detail14_desrewd1   := r.desrewd1;
        detail14_numhmref   := r.numhmref;
        detail14_filename   := r.filename;
        path_filename       := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail14_filename;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||get_tfolderd('HRPMC2E')||'/'||detail14_filename;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('dteinput',set_data(detail14_dteinput));
        obj_data.put('typrewd',set_data(detail14_typrewd));
        obj_data.put('desrewd1',set_data(detail14_desrewd1));
        obj_data.put('numhmref',set_data(detail14_numhmref));
        obj_data.put('filename',set_data(detail14_filename));
        obj_data.put('path_filename',set_data(path_filename));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('dteinput',set_data(''));
      obj_data.put('typrewd',set_data(''));
      obj_data.put('desrewd1',set_data(''));
      obj_data.put('numhmref',set_data(''));
      obj_data.put('filename',set_data(''));
      obj_data.put('path_filename',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --  get_name_change_data
  procedure hres31x_tab16_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    --Data
    detail15_dtechg 	  varchar2(4000 char);
    detail15_namtitle 	  varchar2(4000 char);
    detail15_namfirste 	  varchar2(4000 char);
    detail15_namlaste     varchar2(4000 char);
    detail15_deschang     varchar2(4000 char);

    --cursor
    cursor c_thisname is
      select  dtechg,
              get_tlistval_name('CODTITLE',codtitle,global_v_lang) namtitle,
              decode(global_v_lang,'101',namfirste,'102',namfirstt,'103',namfirst3,'104',namfirst4,'105',namfirst5,namfirste) namfirste,
              decode(global_v_lang,'101',namlaste,'102',namlastt,'103',namlast3,'104',namfirst4,'105',namfirst5,namlaste) namlaste,
              deschang
        from 	thisname
        where codempid = b_index_codempid
        order by dtechg desc;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
    into v_rcnt
    from 	thisname
    where codempid = b_index_codempid
    order by dtechg desc;
    --
    if v_rcnt > 0 then
      for r in c_thisname loop
        v_count := v_count + 1;
        --
        detail15_dtechg 	 := hcm_util.get_date_buddhist_era(r.dtechg);
        detail15_namtitle  := r.namtitle;
        detail15_namfirste := r.namfirste;
        detail15_namlaste  := r.namlaste;
        detail15_deschang  := r.deschang;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('dtechg',set_data(detail15_dtechg));
        obj_data.put('namtitle',set_data(detail15_namtitle));
        obj_data.put('namfirste',set_data(detail15_namfirste));
        obj_data.put('namlaste',set_data(detail15_namlaste));
        obj_data.put('deschang',set_data(detail15_deschang));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('dtechg',set_data(''));
      obj_data.put('namtitle',set_data(''));
      obj_data.put('namfirste',set_data(''));
      obj_data.put('namlaste',set_data(''));
      obj_data.put('deschang',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  -- get_document_data
  procedure hres31x_tab17_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    v_folder              varchar2(4000 char);
    v_flgresume           varchar2(1 char);
    --Data
    detail16_numseq       varchar2(4000 char);
    detail16_namdoc 	  varchar2(4000 char);
    detail16_path_filedoc varchar2(4000 char);
    detail16_filedoc 	  varchar2(4000 char);
    detail16_dterecv 	  varchar2(4000 char);
    detail16_typdoc 	  varchar2(4000 char);
    detail16_dtedocen 	  varchar2(4000 char);
    detail16_numdoc 	  varchar2(4000 char);
    detail16_desnote	  varchar2(4000 char);
    detail16_numappl	  varchar2(4000 char);
    detail16_flgresume	  varchar2(4000 char);
    --cursor
    cursor c_tappldoc is
      select all  b.numappl,a.numseq,a.namdoc,a.filedoc,a.dterecv,a.typdoc,a.dtedocen,a.numdoc,a.desnote,a.flgresume
      from     tappldoc a,temploy1 b
      where    a.numappl  = b.numappl
      and      b.codempid = b_index_codempid
      order by a.numseq ;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from tappldoc a,temploy1 b
      where a.numappl  = b.numappl
      and b.codempid = b_index_codempid
      order by a.numseq ;
    --
    begin
      select folder into v_folder
        from tfolderd
       where codapp = 'HRPMC2E';
    exception when no_data_found then
      v_folder := null;
    end;
    --
    if v_rcnt > 0 then
      for r in c_tappldoc loop
        v_count := v_count + 1;
        --
        detail16_numappl 		  := r.numappl;
        detail16_numseq 		  := r.numseq;
        detail16_namdoc 		  := r.namdoc;
        detail16_filedoc 	    := r.filedoc;
        detail16_path_filedoc := get_tsetup_value('PATHAPI')||get_tsetup_value('PATHDOC')||v_folder||'/'||r.filedoc;--User37 #5399 Final Test Phase 1 V11 05/03/2021 get_tsetup_value('PATHDOC')||v_folder||'/'||r.filedoc;
        detail16_dterecv 	    := hcm_util.get_date_buddhist_era(r.dterecv);
        detail16_typdoc 		  := get_tcodec_name('TCODTYDOC',r.typdoc,global_v_lang);
        detail16_dtedocen 	  := hcm_util.get_date_buddhist_era(r.dtedocen);
        detail16_numdoc 		  := r.numdoc;
        detail16_desnote		  := r.desnote;
        v_flgresume           := r.flgresume;
        if v_flgresume = 'Y' then
          detail16_flgresume  := get_label_name('HRPMC2E1P9',global_v_lang,100);
        elsif v_flgresume = 'N' then
          detail16_flgresume  := get_label_name('HRPMC2E1P9',global_v_lang,110);
        end if;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail16_numappl));
        obj_data.put('numappl',set_data(detail16_numseq));
        obj_data.put('typdoc',set_data(detail16_typdoc));
        obj_data.put('namdoc',set_data(detail16_namdoc));
        obj_data.put('dterecv',set_data(detail16_dterecv));
        obj_data.put('dtedocen',set_data(detail16_dtedocen));
        obj_data.put('numdoc',set_data(detail16_numdoc));
        obj_data.put('filedoc',set_data(detail16_filedoc));
        obj_data.put('path_filedoc',set_data(detail16_path_filedoc));
        obj_data.put('desnote',set_data(detail16_desnote));
        obj_data.put('flgresume',set_data(detail16_flgresume));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('numappl',set_data(''));
      obj_data.put('typdoc',set_data(''));
      obj_data.put('namdoc',set_data(''));
      obj_data.put('dterecv',set_data(''));
      obj_data.put('dtedocen',set_data(''));
      obj_data.put('numdoc',set_data(''));
      obj_data.put('filedoc',set_data(''));
      obj_data.put('path_filedoc',set_data(''));
      obj_data.put('desnote',set_data(''));
      obj_data.put('flgresume',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  -- get_reference_data
  procedure hres31x_tab18_table(json_str_input in clob, json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_count               number := 0;
    v_rcnt                number := 0;
    --Data
    detail17_numseq       varchar2(4000 char);
    detail17_flgref       varchar2(4000 char);
    detail17_desnoffi     varchar2(4000 char);
    detail17_numtele      varchar2(4000 char);
    detail17_codoccup     varchar2(4000 char);
    detail17_namref       varchar2(4000 char);
    detail17_despos       varchar2(4000 char);
    detail17_adrcont1     varchar2(4000 char);
    detail17_email        varchar2(4000 char);
    detail17_remark       varchar2(4000 char);
    detail17_codempref    varchar2(10 char);

    --cursor
    cursor c_tapplref is
      select all  a.numappl,a.numseq,a.flgref,a.desnoffi,a.numtele,
                  a.codoccup,
                   decode(global_v_lang,'101',a.namrefe,'102',a.namreft,'103',a.namref3,'104',a.namref4,'105',a.namref5,a.namrefe) namrefe,
                  a.despos,a.adrcont1,a.email,a.remark,codempref
      from     		tapplref a
      where    		a.codempid  = b_index_codempid
      order by    numseq;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from tapplref a
      where a.codempid  = b_index_codempid
      order by numseq;
    --
    if v_rcnt > 0 then
      for r in c_tapplref loop
        v_count := v_count + 1;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        detail17_numseq    := r.numseq;
        detail17_flgref    := get_tlistval_name('FLGREF',r.flgref,global_v_lang);
        detail17_desnoffi  := r.desnoffi;
        detail17_numtele   := r.numtele;
        detail17_codoccup  := get_tcodec_name('TCODOCCU',r.codoccup,global_v_lang);
        detail17_namref    := r.namrefe;
        detail17_despos    := r.despos;
        detail17_adrcont1  := r.adrcont1;
        detail17_email     := r.email;
        detail17_remark    := r.remark;
        detail17_codempref := r.codempref;
        --
--        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('numseq',set_data(detail17_numseq));
        obj_data.put('namref',set_data(detail17_namref));
        obj_data.put('flgref',set_data(detail17_flgref));
        obj_data.put('desnoffi',set_data(detail17_desnoffi));
        obj_data.put('despos',set_data(detail17_despos));
        obj_data.put('numtele',set_data(detail17_numtele));
        obj_data.put('adrcont1',set_data(detail17_adrcont1));
        obj_data.put('email',set_data(detail17_email));
        obj_data.put('codoccup',set_data(detail17_codoccup));
        obj_data.put('remark',set_data(detail17_remark));
        obj_data.put('codempref',set_data(detail17_codempref));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop;
    else
      v_count := v_count + 1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_coderror', ' ');
      obj_data.put('httpcode', '');
      obj_data.put('flg', '');
--      obj_data.put('total',to_char(v_count));
      obj_data.put('rcnt',to_char(v_count));
      obj_data.put('numseq',set_data(''));
      obj_data.put('namref',set_data(''));
      obj_data.put('flgref',set_data(''));
      obj_data.put('desnoffi',set_data(''));
      obj_data.put('despos',set_data(''));
      obj_data.put('numtele',set_data(''));
      obj_data.put('adrcont1',set_data(''));
      obj_data.put('email',set_data(''));
      obj_data.put('codoccup',set_data(''));
      obj_data.put('remark',set_data(''));
      obj_data.put('codempref',set_data(''));
      obj_row.put(to_char(v_count-1),obj_data);
    end if;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  -- get_reference_data
  procedure hres31x_tab19_table(json_str_input in clob, json_str_output out clob) as
    obj_row      json_object_t;
    obj_data     json_object_t;
    v_count      number := 0;
    v_count1     number := 0;
    v_count2     number := 0;
    v_rcnt       number := 0;
    v_type       user_tab_columns.data_type%type;
    --
    v_value      varchar2(4000);
    v_stmt       varchar2(4000);
    v_format_number varchar2(150);
    v_numappl    temploy1.numappl%type;
  --cursor
  cursor c1 is
    select column_id,usr.column_name,data_type,data_length,
            data_scale,data_precision,table_name,oth.itemtype,oth.codlist,
            decode(global_v_lang,'101',desclabele
                                ,'102',desclabelt
                                ,'103',desclabel3
                                ,'104',desclabel4
                                ,'105',desclabel5) as  desclabel --<< user46 24/09/2021 Ref. TNT-HR2101
    from user_tab_columns usr, tempothd oth
    where table_name    = 'TEMPOTHR'
    and usr.column_name = oth.column_name
    and usr.column_name like 'USR_%'
    and essstat <> '1'
    order by column_id;
  begin
    obj_row    := json_object_t();
    initial_value(json_str_input);
    select count(*)
      into v_rcnt
      from user_tab_columns usr, tempothd oth
     where table_name    = 'TEMPOTHR'
       and usr.column_name = oth.column_name
       and usr.column_name like 'USR_%'
       and essstat <> '1';
    begin
      select numappl
        into v_numappl
        from temploy1
       where codempid   = b_index_codempid;
    exception when no_data_found then
      null;
    end;
    if v_rcnt > 0 then
      for i in c1 loop
        v_count := v_count + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
--<< user46 27/09/2021 re-code
        begin
          if i.itemtype = '2' then
            select reverse(regexp_replace('0'||rpad('9',i.data_precision - i.data_scale - 1,'9'), '(\d{3})', '\1,',1))
              into v_format_number
              from dual;
            if mod(i.data_precision - i.data_scale, 3) = 0 then
              v_format_number := 'fm'||substr(v_format_number,2);
            else
              v_format_number := 'fm'||v_format_number;
            end if;
            if nvl(i.data_scale,0) > 0 then
              v_format_number := v_format_number||'.'||rpad('0',i.data_scale,'0');
            end if;
            v_stmt    := 'select to_char('||i.column_name||','''||v_format_number||''') from tempothr where numappl = '''||v_numappl||'''';
            v_value   := execute_desc(v_stmt);
          elsif i.itemtype = '3' then
            v_stmt    := 'select hcm_util.get_date_buddhist_era('||i.column_name||') from tempothr where numappl = '''||v_numappl||'''';
            v_value   := execute_desc(v_stmt);
          else
            v_stmt    := 'select '||i.column_name||' from tempothr where numappl = '''||v_numappl||'''';
            v_value   := execute_desc(v_stmt);
            if i.itemtype = '4' then
              v_value   := get_tlistval_name(i.codlist,v_value,global_v_lang);
            end if;
          end if;
        exception when others then
          v_value := '';
        end;
        obj_data.put('desother',i.desclabel);
        obj_data.put('desvalue',set_data(v_value));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop; --c1
/*      get_data_tempothr; 
      for v in 1..detail18_desother.count loop
        v_count := v_count+1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('desc_coderror', ' ');
        obj_data.put('httpcode', '');
        obj_data.put('flg', '');
        obj_data.put('rcnt',to_char(v_count));
        obj_data.put('desother',set_data(detail18_desother(v)));
        obj_data.put('desvalue',set_data(detail18_desvalue(v)));
        obj_row.put(to_char(v_count-1),obj_data);
      end loop; --length(detail18_desother) */
-->> user46 27/09/2021 re-code
    end if; --v_rcnt

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  procedure hres31x_tab20(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;

    --Data
    detail20_typtrav     varchar2(100 char);
    detail20_carlicen    varchar2(100 char);
    detail20_typfuel     varchar2(100 char);
    detail20_qtylength   number;
    detail20_codbusno    varchar2(100 char);
    detail20_codbusrt    varchar2(100 char);


  begin
    obj_row := json_object_t();
    initial_value(json_str_input);

     begin
      select  typtrav,carlicen,typfuel,qtylength,codbusno,codbusrt
      into    detail20_typtrav,detail20_carlicen,detail20_typfuel,detail20_qtylength,detail20_codbusno,detail20_codbusrt
      from 		temploy1
      where   codempid = b_index_codempid
      and     rownum   = 1;
    exception when no_data_found then
      null;
    end;
    --
--    detail20_codbusno	:= get_tcodec_name('TCODOCCU',v_codspocc,global_v_lang);
--    detail20_codbusrt	:= get_tcodec_name('TCODPROV',v_codsppro,global_v_lang);
--    detail20_typfuel	:= get_tcodec_name('TCODCNTY',v_codspcty,global_v_lang);
--    detail20_typtrav	:= get_tcodec_name('TCODCNTY',v_codspcty,global_v_lang);


    --
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('typtrav',set_data(get_tlistval_name('TYPTRAV',detail20_typtrav,global_v_lang)));
    obj_row.put('carlicen',set_data(detail20_carlicen));
    obj_row.put('typfuel',set_data(get_tlistval_name('TYPFUEL',detail20_typfuel,global_v_lang)));
    obj_row.put('qtylength',set_data(detail20_qtylength));
    obj_row.put('codbusno',set_data(get_tcodec_name('TCODBUSNO',detail20_codbusno,global_v_lang)));
    obj_row.put('codbusrt',set_data(get_tcodec_name('TCODBUSRT',detail20_codbusrt,global_v_lang)));

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  --
  function get_max_column (p_table  user_tab_columns.table_name%type) return user_tab_columns.column_id%type is
    v_max          user_tab_columns.column_id%type;
  begin
     begin
         select count(*)
           into v_max
           from user_tab_columns usr, tempothd oth
          where table_name    = 'TEMPOTHR'
            and usr.column_name = oth.column_name
            and usr.column_name like 'USR_%'     -- show column_name usr_% only
            and data_type <> 'LONG RAW'
            and essstat <> '1';
         exception when no_data_found then
            v_max := 0;
     end;
     return(v_max);

  end;
  --
  function get_statment (p_table  user_tab_columns.table_name%type) return varchar2 is
    --cursor
    cursor c1 is
       select column_name,data_type
         from user_tab_columns
        where table_name = p_table
          and column_name like 'USR_%'     -- show column_name usr_% only
    order by column_id;
    --
    v_statment          varchar2(4000 char):=null;
    v_comma             varchar2(1 char):= ',';
  begin
        for j in c1 loop
          if j.data_type <> 'LONG RAW' then
             if v_statment is null then
                v_statment := j.column_name;
             else
                v_statment := v_statment||v_comma||j.column_name;
             end if;
          end if;
        end loop;
    return(v_statment);
  end;
  --
  procedure get_data_tempothr is
    v_cursor       number;
    v_statment     varchar2(4000 char);
    v_dummy        integer;
    v_data_file    varchar2(3000 char);
    v_statmt       varchar2(4000 char);
    v_where        varchar2(4000 char);
    v_num          number;
    v_count        number;
    flg_data       varchar2(1 char):= 'N';

  begin
      v_num  := get_max_column('TEMPOTHR');      --want show column_name usr_% only
      if v_num <> 0 Then
        --v_conn     := dbms_sql.default_connection;
        v_statmt   := get_statment('TEMPOTHR');  --want show column_name usr_% only
        v_where    := 'codempid = '''||b_index_codempid||'''';

        v_statment := 'select '||v_statmt||
                      ' from TEMPOTHR '||
                      ' where '||v_where;

        v_cursor   := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursor,v_statment,dbms_sql.native);

        for j in 1..v_num  loop
          dbms_sql.define_column(v_cursor,j,v_data_file,500);
          detail18_desvalue(j) := null;
        end loop;

        v_dummy := dbms_sql.execute(v_cursor);

        loop
         if dbms_sql.fetch_rows(v_cursor) = 0 then
            exit;
         end if;

         for j in 1..v_num  loop
           if detail18_datatype(j) = 'LONG RAW' then
             detail18_desvalue(j) := null;
           else
             dbms_sql.column_value(v_cursor,j,v_data_file);
             detail18_desvalue(j) := v_data_file;
           end if;
         end loop;
        end loop;
        dbms_sql.close_cursor(v_cursor);
      end if;
  end;
  --
  function get_col_comments (p_column   user_col_comments.column_name%type,
                           p_table    user_col_comments.table_name%type)
                           return user_col_comments.comments%type is
   v_comments         user_col_comments.comments%type;

  begin
      begin
          select comments
            into v_comments
            from user_col_comments
           where column_name  = p_column
             and table_name   = p_table
             and rownum <= 1;
      exception when no_data_found then
         v_comments := null;
      end;

  return(v_comments);
  end;
  --
END;

/
